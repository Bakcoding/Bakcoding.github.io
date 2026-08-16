---
title: "[궁금시리즈] 11-8. 병렬 프로그래밍에서 자주 하는 실수 총정리"
excerpt: "C#"
categories:
  - CSharp
series: question-series
tags:
  - CSharp
permalink: /programming/11-8-parallel-programming-mistakes/
toc: true
toc_sticky: true
date: 2026-08-16 12:00:38 +0900
last_modified_at: 2026-08-16 12:00:38 +0900
---

## 들어가며

병렬 코드는 실행 Thread를 늘리는 것으로 완성되지 않는다.

```cs
Task.Run(() => UpdateEnemies());
```

한 줄로 Main Thread 밖에서 실행할 수 있지만 다음 질문이 남는다.

```text
공유 데이터를 동시에 수정하는가?
Unity Object에 접근하는가?
작업이 실패하면 누가 예외를 받는가?
Scene이 끝나면 어떻게 취소하는가?
결과가 오래된 객체에 적용될 수 있는가?
실제로 순차 코드보다 빠른가?
```

병렬 프로그래밍의 문제는 일반 버그보다 재현하기 어렵다. Thread 실행 순서는 매번 바뀌고 로그를 추가한 것만으로 Timing이 달라질 수 있다.

정확한 결과가 나와도 Lock 대기와 Context Switch 때문에 더 느릴 수 있다. 빠르게 실행되어도 종료할 수 없거나 부분 결과가 남으면 안정적인 시스템이 아니다.

```text
Correctness
결과와 상태가 올바른가?

Liveness
Deadlock 없이 계속 진행하는가?

Lifecycle
취소, 예외와 종료를 처리하는가?

Performance
전체 Frame이 실제로 개선되는가?
```

네 가지 기준을 함께 만족해야 병렬화가 프로젝트에 의미가 있다.

---

## 개념 설명

### 비동기와 병렬을 혼동한다

```cs
string data = await File.ReadAllTextAsync(path);
```

이 코드는 파일 응답을 기다리는 동안 호출 Thread를 Block하지 않는 비동기 I/O다. 여러 CPU Core가 파일 읽기 계산을 나누는 병렬 처리와 목적이 다르다.

```cs
Result[] results = await Task.Run(() =>
{
    Result[] output = new Result[inputs.Length];

    Parallel.For(0, inputs.Length, i =>
    {
        output[i] = Calculate(inputs[i]);
    });

    return output;
});
```

CPU Bound 계산을 여러 Core에 나누는 구조다.

### 공유 상태를 그대로 둔다

```cs
Parallel.ForEach(items, item =>
{
    results.Add(Process(item));
});
```

`List<T>`에 여러 Worker가 동시에 Add하면 안전하지 않다.

```text
Worker별 지역 결과
↓
Thread Safe Queue 또는 Partition 결과
↓
마지막에 한 번 병합
```

Lock을 붙이기 전에 공유 쓰기 자체를 줄인다.

### Thread 수를 성능으로 생각한다

Thread가 많아도 CPU Core 수는 늘지 않는다.

```text
CPU Bound Thread 증가
↓
Context Switch 증가
↓
Cache 경쟁 증가
↓
다른 Engine Thread의 실행 시간 감소
```

사용 가능한 Core를 Unity의 Rendering, Physics, Audio와 Job System도 함께 사용한다.

### Main Thread 제약을 무시한다

대부분의 UnityEngine Object API는 Main Thread에서 사용해야 한다.

```cs
Task.Run(() =>
{
    enemy.transform.position = nextPosition;
});
```

자신이 만든 Lock으로 감싸도 Unity API의 Thread 제약이 바뀌지 않는다.

### 결과의 시간 유효성을 놓친다

Worker가 계산하는 동안 대상이 Despawn되거나 Pool에서 다른 용도로 재사용될 수 있다.

Thread Safe한 Queue로 전달한 결과도 현재 게임 상태에는 오래된 값일 수 있다.

---

## 코드 예제

### Fire-and-forget으로 예외를 잃는다

```cs
public void StartCalculation()
{
    _ = Task.Run(() => Calculate());
}
```

호출자는 완료, 실패와 취소를 알 수 없다.

Task를 반환해 수명 소유자가 관찰하도록 만든다.

```cs
public Task<Result> CalculateAsync(
    Input input,
    CancellationToken cancellationToken)
{
    return Task.Run(
        () => Calculate(input, cancellationToken),
        cancellationToken);
}
```

```cs
try
{
    Result result = await CalculateAsync(input, token);
    Apply(result);
}
catch (OperationCanceledException)
    when (token.IsCancellationRequested)
{
    // 예상된 취소
}
catch (Exception exception)
{
    Debug.LogException(exception);
}
```

### Main Thread에서 Result 호출

```cs
Task<Result> task = CalculateAsync(input, token);
Result result = task.Result;
```

Main Thread가 완료될 때까지 Block된다. Continuation이 Main Thread를 필요로 하는 구조라면 서로 기다리는 Deadlock도 생길 수 있다.

```cs
Result result = await CalculateAsync(input, token);
```

또는 Frame 사이에 완료를 확인하고 완료된 결과만 적용한다.

### Lock 안에서 긴 작업

```cs
lock (gate)
{
    Result result = Calculate(input);
    results.Add(result);
}
```

독립 계산까지 Lock 안에 있어 Worker가 한 번에 하나씩 실행된다.

```cs
Result result = Calculate(input);

lock (gate)
{
    results.Add(result);
}
```

더 나아가 Worker별 결과를 사용하면 공유 Lock 횟수를 줄일 수 있다.

### Cancellation을 시작 전에만 확인한다

```cs
if (cancellationToken.IsCancellationRequested)
{
    return;
}

CalculateForTenSeconds();
```

긴 계산 중 취소가 들어와도 10초 동안 응답하지 않는다.

```cs
for (int i = 0; i < chunks.Length; i++)
{
    cancellationToken.ThrowIfCancellationRequested();
    Process(chunks[i]);
}
```

확인 빈도가 너무 높으면 비용이 추가되고 너무 낮으면 취소가 늦어진다. Chunk 크기와 필요한 응답 시간을 기준으로 정한다.

### 중복 반환

충돌과 수명 종료가 같은 Frame에 Pool 반환을 요청할 수 있다.

```cs
private int released;

public void ReleaseOnce()
{
    if (Interlocked.Exchange(ref released, 1) != 0)
    {
        return;
    }

    resultQueue.Enqueue(handle);
}
```

원자적 상태 전환으로 한 번만 Queue에 넣는다. 실제 GameObject 비활성화와 Pool 반환은 Main Thread에서 수행한다.

### 오래된 결과 적용 방지

```cs
public readonly record struct EntityHandle(
    int Id,
    int Generation);
```

```cs
foreach (CalculationResult result in completedResults)
{
    if (!registry.TryGet(
            result.Handle,
            out Entity? entity))
    {
        continue;
    }

    entity.Apply(result);
}
```

ID와 Generation으로 계산을 요청한 객체가 아직 같은 세대인지 확인한다.

### Job Dependency 누락

```cs
JobHandle writeHandle = writeJob.Schedule();
JobHandle readHandle = readJob.Schedule();
```

두 Job이 같은 NativeArray를 쓰고 읽는다면 Dependency를 연결한다.

```cs
JobHandle writeHandle = writeJob.Schedule();
JobHandle readHandle = readJob.Schedule(writeHandle);
```

Safety System 오류를 피하려고 Restriction을 끄는 대신 실제 데이터 순서를 표현한다.

### NativeContainer Dispose 누락

```cs
NativeArray<float> values = new(
    count,
    Allocator.Persistent);
```

Job 완료와 Container 해제를 같은 소유자 수명에 둔다.

```cs
public void Dispose()
{
    handle.Complete();

    if (values.IsCreated)
    {
        values.Dispose();
    }
}
```

Dispose를 먼저 호출하면 실행 중인 Job이 해제된 Memory에 접근할 수 있다.

---

## 내부 동작

### Check-then-act Race

```cs
if (!dictionary.ContainsKey(id))
{
    dictionary.Add(id, value);
}
```

확인과 변경 사이에 다른 Thread가 상태를 바꿀 수 있다.

```text
Thread A: 없음 확인
Thread B: 없음 확인
Thread A: 추가
Thread B: 추가 시도
```

복합 규칙을 하나의 Critical Section으로 묶거나 `TryAdd()` 같은 Atomic API를 사용한다.

### Lock Ordering과 Deadlock

```text
Thread A
Player Lock 획득 → Inventory Lock 대기

Thread B
Inventory Lock 획득 → Player Lock 대기
```

Lock 획득 순서를 전체 시스템에서 통일하고, Lock 안에서 외부 Callback과 동기식 대기를 호출하지 않는다.

### Thread Pool Starvation

```cs
Task.Run(() => blockingEvent.WaitOne());
```

이런 작업이 많이 쌓이면 Thread Pool Worker가 대기에 묶인다.

```text
모든 Worker가 Blocking
↓
새 Task가 Queue에서 대기
↓
Continuation도 실행 지연
↓
완료를 기다리는 호출자도 지연
```

I/O에는 비동기 API를 사용하고 오래 유지되는 Blocking Loop가 필요하면 전용 Thread를 검토한다.

### Nested Parallelism

```cs
Parallel.ForEach(groups, group =>
{
    Parallel.ForEach(group.Items, Process);
});
```

중첩 Parallel이 CPU Core를 추가하지 않는다. 같은 Worker 자원에서 Partitioning과 Scheduling 비용이 늘 수 있다.

전체 Item이나 바깥 Group 중 하나의 계층을 병렬화한다.

### Oversubscription

Task Thread Pool과 Unity Job System을 동시에 최대 병렬도로 사용하면 동일한 Core를 두 Scheduler가 경쟁할 수 있다.

```text
Task Worker
+ Job Worker
+ Render Thread
+ Physics
+ Audio
```

각 시스템 Benchmark에서는 빠르지만 통합 Frame에서는 Context Switch와 Cache 경쟁으로 느려질 수 있다.

### False Sharing

Worker별 Counter가 서로 다른 Field여도 같은 Cache Line에 있으면 Core 사이의 Cache 무효화가 반복될 수 있다.

정확성은 맞지만 병렬 효율이 낮아지는 문제다. Worker를 늘린 뒤 성능이 더 이상 증가하지 않는다면 Lock 외에 Memory Bandwidth와 Cache Layout도 확인한다.

### 부분 완료

병렬 작업 하나가 실패해도 다른 작업은 이미 결과를 작성했을 수 있다.

```text
Worker A 성공 → result[0] 작성
Worker B 실패 → 예외
Worker C 성공 → result[2] 작성
```

전체 결과를 폐기할지 성공 결과를 유지할지, 재시도 시 중복 부작용이 없는지 정책을 정해야 한다.

---

## 실제 Unity에서는?

### Worker에는 Snapshot만 전달한다

```text
Main Thread
Transform과 Component에서 값 읽기
↓
Immutable Snapshot 또는 NativeContainer
↓
Worker에서 순수 계산
↓
Result Queue 또는 JobHandle
↓
Main Thread에서 유효성 확인 후 적용
```

Unity Object 참조를 Worker Delegate가 캡처하지 않도록 경계를 분명히 한다.

### Scene 수명과 Cancellation을 연결한다

```cs
private CancellationTokenSource? lifetime;

private void OnEnable()
{
    lifetime = new CancellationTokenSource();
    RunAsync(lifetime.Token).Forget();
}

private void OnDisable()
{
    lifetime?.Cancel();
    lifetime?.Dispose();
    lifetime = null;
}
```

예시는 수명 연결의 개념을 보여 준다. 실제로는 진행 중인 Task가 Token 사용을 끝내기 전에 Source를 Dispose하지 않도록 완료 관찰과 종료 순서를 구성해야 한다.

Fire-and-forget Helper를 사용하더라도 예외 처리 정책을 명시한다.

### Job Complete를 너무 빨리 호출하지 않는다

```cs
JobHandle handle = job.Schedule();
handle.Complete();
```

정확하지만 Main Thread와 Worker가 겹쳐 실행할 시간이 거의 없다.

```text
Frame 초반 Schedule
↓
Job과 독립적인 Main Thread 작업
↓
결과가 필요한 직전 Complete
```

Profiler에서 `WaitForJobGroup` 시간이 줄었는지 확인한다.

### Main Thread Queue를 무제한으로 비우지 않는다

```cs
while (results.TryDequeue(out Result result))
{
    Apply(result);
}
```

Worker 결과가 몰리면 결과 적용이 Main Thread Spike가 된다.

```cs
int processed = 0;

while (processed < maxPerFrame &&
       results.TryDequeue(out Result result))
{
    Apply(result);
    processed++;
}
```

생산 속도가 소비 속도보다 빠르면 Queue Memory가 계속 증가하므로 Backpressure와 오래된 결과 폐기 정책도 필요하다.

### Domain Reload와 Static Worker

Editor의 Domain Reload 설정에 따라 Static Queue, Task와 상태가 다음 Play Session에 영향을 줄 수 있다.

```text
새 요청 차단
↓
이전 Worker 취소
↓
완료 또는 안전한 종료 확인
↓
Queue 비우기
↓
새 Session 상태 초기화
```

Queue만 비우면 이전 Worker가 종료 후 다시 결과를 넣을 수 있다.

### Profiler에서 Wait와 Worker를 함께 본다

```text
Worker가 실제로 동시에 실행되는가?
Main Thread는 어디서 기다리는가?
Lock을 기다리는 시간이 계산보다 긴가?
Job Worker가 다른 Engine Job을 지연시키는가?
결과 적용이 새로운 Spike를 만드는가?
```

작업 함수의 시간만 보고 판단하지 않는다.

### Target Platform에서 종료까지 테스트한다

```text
작업 중 Scene 전환
Application Pause와 Resume
작업 중 취소
네트워크 실패
Player 종료
낮은 Core 수와 Thermal Throttling
```

Desktop Editor에서 잘 실행된다는 사실만으로 모바일, Web과 Console의 Thread 제약과 성능을 보장할 수 없다.

---

## 실무에서 자주 하는 오해

### async 메서드는 모두 병렬로 실행된다

Async는 대기 중 호출 흐름을 Block하지 않는 구조일 수 있다. CPU 계산이 여러 Core에서 동시에 실행된다는 뜻은 아니다.

### Task.Run을 사용하면 Unity API도 안전하다

Thread Pool Worker로 이동할 뿐 UnityEngine Object의 Main Thread 제약은 그대로다.

### Lock을 많이 사용하면 안전성이 높아진다

일관되지 않은 Lock은 상태를 보호하지 못하고 중첩 Lock은 Deadlock 위험을 높인다. 보호할 불변 조건과 Lock 순서를 정해야 한다.

### Concurrent Collection이면 전체 알고리즘이 Thread Safe하다

개별 연산은 안전해도 조회 후 변경 같은 여러 단계 규칙은 Race가 생길 수 있다.

### CancellationToken을 전달하면 즉시 취소된다

작업이 Token을 확인하거나 취소 가능한 API를 호출해야 멈추는 협력적 취소다.

### Background Thread이므로 종료 처리는 필요 없다

Process 종료를 유지하지 않을 뿐 저장, Queue, Native Resource와 예외를 안전하게 정리해 주지는 않는다.

### Job Safety 오류는 Attribute로 끄면 해결된다

경고를 없앨 뿐 데이터 충돌이 안전해지는 것은 아니다. Dependency와 Index별 접근 규칙을 먼저 수정한다.

### Worker가 많을수록 처리 속도가 높다

Core 경쟁, Context Switch, Cache와 Memory Bandwidth 한계로 특정 지점부터 이득이 줄거나 성능이 악화될 수 있다.

### 병렬 함수가 빨라졌으면 전체 Frame도 빨라졌다

입력 복사, Scheduling, Complete 대기와 결과 적용이 추가될 수 있다. 다른 Unity Worker의 지연도 포함해 전체 Frame을 비교해야 한다.

### 테스트에서 한 번 성공했으면 Thread Safe하다

Race는 Timing에 따라 드물게 나타난다. 반복 테스트와 함께 공유 상태, 소유권과 동기화 규칙을 구조적으로 검토해야 한다.

---

## 마무리

병렬 프로그래밍의 실수는 Thread API 하나를 잘못 선택해서만 생기지 않는다.

공유 상태, 작업 수명과 결과 적용 시점을 설계하지 않은 상태에서 실행 위치만 Worker로 옮길 때 문제가 시작된다.

```text
CPU Bound 작업인가?
↓
독립 데이터 단위로 나눌 수 있는가?
↓
공유 쓰기를 없애거나 최소화했는가?
↓
취소, 예외와 부분 실패를 처리하는가?
↓
Unity Object 적용을 Main Thread로 분리했는가?
↓
작업 중 대상이 사라지는 경우를 처리하는가?
↓
Target Player에서 전체 Frame을 비교했는가?
```

안정적인 병렬 구조는 Worker 수보다 데이터 소유권이 명확하다.

```text
Main Thread가 입력 Snapshot 소유
Worker가 독립 계산 소유
Queue가 결과 전달 소유
Main Thread가 결과 검증과 적용 소유
Lifecycle Owner가 취소와 종료 소유
```

병렬화가 복잡도만 늘리고 측정 가능한 이득이 없다면 순차 구현이 더 좋은 선택이다. 단순한 순차 기준을 유지해야 병렬 구현의 정확성과 성능을 계속 비교할 수 있다.

---

## 핵심 정리

- 비동기는 대기 흐름을 관리하고 병렬 처리는 여러 Core에서 CPU 계산을 동시에 수행하는 개념이다.
- 병렬화 전에 Shared Mutable State를 줄이고 Worker별 독립 입력과 출력을 만든다.
- Task, Thread와 Job에서 발생한 예외와 부분 결과를 수명 소유자가 반드시 관찰해야 한다.
- Cancellation은 협력적이므로 긴 작업 내부에서 적절한 주기로 확인해야 한다.
- Main Thread의 `.Result`, `.Wait()`, 긴 Lock과 즉시 `Complete()`는 Frame을 Block할 수 있다.
- Unity Object는 Worker에서 직접 접근하지 않고 Snapshot 계산 후 Main Thread에서 결과를 적용한다.
- 결과 적용 시 ID, Generation과 현재 상태를 확인해 오래된 결과를 거른다.
- Job의 NativeContainer 접근은 Safety Restriction 해제보다 올바른 Dependency와 소유권으로 해결한다.
- Worker 수와 병렬도를 늘리기 전에 Thread Pool, Job Worker와 Engine Thread의 CPU 경쟁을 확인한다.
- 순차 기준과 병렬 구현을 Target Device에서 정확성, 최악 Frame, 종료와 장시간 성능까지 비교해야 한다.
