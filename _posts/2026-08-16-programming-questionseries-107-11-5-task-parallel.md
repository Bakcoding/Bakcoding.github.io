---
title: "[궁금시리즈] 11-5. Task와 Parallel은 어떻게 CPU 작업을 나눌까?"
excerpt: "C#"
categories:
  - CSharp
series: question-series
tags:
  - CSharp
permalink: /programming/11-5-task-parallel/
toc: true
toc_sticky: true
date: 2026-08-16 12:00:35 +0900
last_modified_at: 2026-08-16 12:00:35 +0900
---

## 들어가며

CPU 계산을 Main Thread 밖으로 옮길 때 `Task.Run()`을 자주 사용한다.

```cs
float[] result = await Task.Run(() =>
{
    return CalculateAll(inputs);
});
```

배열의 각 요소를 여러 Worker가 나누어 계산할 때는 `Parallel.For()`를 사용할 수 있다.

```cs
Parallel.For(0, inputs.Length, i =>
{
    results[i] = Calculate(inputs[i]);
});
```

두 API 모두 Thread Pool을 활용할 수 있지만 목적은 다르다.

```text
Task.Run
└─ 하나의 CPU 작업을 호출 Thread 밖에서 실행하고 완료를 표현

Parallel.For
└─ 하나의 반복 작업을 여러 Partition으로 나누어 병렬 실행
```

`Task.Run()` 하나로 감쌌다고 내부 계산이 자동으로 여러 Core에 나뉘는 것은 아니다. `Parallel.For()`를 사용했다고 모든 반복이 동시에 시작되는 것도 아니다.

작업량, 독립성, 분할 크기, Worker 수와 결과를 기다리는 위치에 따라 순차 실행보다 느려질 수도 있다.

---

## 개념 설명

### Task는 작업의 상태를 표현한다

Task는 다음 정보를 담는다.

```text
아직 시작하지 않음
실행 중
성공 완료
취소됨
실패함
결과 값
예외
```

```cs
Task<int> scoreTask = Task.Run(CalculateScore);
int score = await scoreTask;
```

Task 자체가 Thread는 아니다. 작업이 어디서 실행되는지는 생성 방식과 Scheduler, 현재 Context에 따라 달라진다.

### Task.Run

`Task.Run()`은 CPU 작업을 기본 Task Scheduler에 Queue하고 보통 Thread Pool Worker에서 실행한다.

```cs
Task<Path> pathTask = Task.Run(() =>
{
    return FindPath(map, start, end);
});
```

호출자는 Task를 `await`해 Main Thread를 Block하지 않고 완료를 기다릴 수 있다.

### Parallel.For

`Parallel.For()`는 반복 범위를 여러 작업으로 나누고 여러 Worker가 처리하도록 한다.

```cs
Parallel.For(
    fromInclusive: 0,
    toExclusive: count,
    body: i => Process(i));
```

호출 자체는 동기식이다. 모든 반복이 끝날 때까지 `Parallel.For()`를 호출한 Thread는 메서드에서 빠져나오지 않는다.

```text
Main Thread에서 Parallel.For 직접 호출
↓
Main Thread도 병렬 작업에 참여하거나 완료를 기다림
↓
전체 작업이 끝날 때까지 다음 Frame으로 진행하지 못함
```

병렬 계산이 빨라져도 Frame을 여러 Frame에 걸쳐 비동기로 넘긴다는 뜻은 아니다.

### Partitioning

반복 하나마다 Task를 만드는 대신 여러 요소를 Chunk로 묶어 Worker가 처리한다.

```text
입력 0..999

Partition A: 0..249
Partition B: 250..499
Partition C: 500..749
Partition D: 750..999
```

실제 분할은 고정 범위가 아닐 수 있다. Scheduler는 부하 균형을 위해 작업을 동적으로 나눌 수 있다.

### Degree of Parallelism

동시에 사용할 병렬 작업의 상한을 설정할 수 있다.

```cs
ParallelOptions options = new()
{
    MaxDegreeOfParallelism = 4
};
```

상한을 4로 지정했다고 항상 4개 Core가 100% 사용되는 것은 아니다. Scheduler, 입력 크기와 시스템 부하에 따라 실제 실행은 달라진다.

### PLINQ

PLINQ는 LINQ Query를 병렬 실행할 수 있게 한다.

```cs
Result[] results = inputs
    .AsParallel()
    .Select(Calculate)
    .ToArray();
```

간결하지만 Partitioning, 결과 병합, 순서 유지와 Materialization 비용이 추가된다. Hot Path에서는 실제 데이터 크기로 비교해야 한다.

---

## 코드 예제

### 순차 처리 기준 만들기

```cs
public static void CalculateSequential(
    Input[] inputs,
    Result[] results)
{
    for (int i = 0; i < inputs.Length; i++)
    {
        results[i] = Calculate(inputs[i]);
    }
}
```

병렬 버전을 만들기 전에 비교할 순차 구현을 유지한다.

### Parallel.For

```cs
public static void CalculateParallel(
    Input[] inputs,
    Result[] results,
    CancellationToken cancellationToken)
{
    ParallelOptions options = new()
    {
        CancellationToken = cancellationToken,
        MaxDegreeOfParallelism =
            Math.Max(1, Environment.ProcessorCount - 1)
    };

    Parallel.For(
        0,
        inputs.Length,
        options,
        i =>
        {
            results[i] = Calculate(inputs[i]);
        });
}
```

Main Thread와 Unity의 다른 Worker가 사용할 CPU를 남긴다는 의도로 상한을 설정했지만 모든 플랫폼에 적합한 공식은 아니다. 실제 Target Device에서 조정한다.

각 반복은 다른 Index에만 결과를 쓴다. `results` 배열 크기와 입력 수가 일치한다는 사전 조건도 확인해야 한다.

### Task.Run과 Parallel.For 조합

Main Thread를 Block하지 않도록 전체 병렬 계산을 Task로 실행할 수 있다.

```cs
public static Task<Result[]> CalculateAsync(
    Input[] inputs,
    CancellationToken cancellationToken)
{
    return Task.Run(() =>
    {
        Result[] results = new Result[inputs.Length];

        CalculateParallel(
            inputs,
            results,
            cancellationToken);

        return results;
    }, cancellationToken);
}
```

```cs
Result[] results = await CalculateAsync(
    inputSnapshot,
    destroyCancellationToken);
```

바깥 `Task.Run()`은 호출 흐름을 Thread Pool로 옮기고, 안쪽 `Parallel.For()`는 반복 계산을 여러 Worker에 분산한다.

이 구조가 항상 최적은 아니다. 같은 Thread Pool을 사용하는 작업이 중첩되고 Worker 경쟁이 늘 수 있으므로 단일 순차 Task와 병렬 Task를 실제로 비교한다.

### 작업량이 고르지 않은 경우

```cs
Parallel.ForEach(requests, request =>
{
    results[request.Id] = Calculate(request);
});
```

일부 Request는 0.1ms이고 일부는 20ms라면 고정 Chunk가 불균형할 수 있다.

```text
Worker A: 가벼운 작업만 처리 후 대기
Worker B: 무거운 작업 계속 처리
```

동적 Partitioning과 Work Stealing이 부하를 나눌 수 있지만 작업 크기 분포 자체를 측정해야 한다.

무거운 요청을 더 작은 독립 단위로 나눌 수 있는지도 확인한다.

### Thread Local 결과

공유 합계에 요소마다 Lock을 걸지 않는다.

```cs
double total = 0d;
object gate = new();

Parallel.For<double>(
    0,
    inputs.Length,
    () => 0d,
    (i, state, localTotal) =>
        localTotal + CalculateValue(inputs[i]),
    localTotal =>
    {
        lock (gate)
        {
            total += localTotal;
        }
    });
```

Worker별 지역 합계를 계산하고 Partition이 끝날 때만 공유 합계에 반영한다.

Floating Point 덧셈 순서가 순차 버전과 달라질 수 있어 마지막 Bit까지 동일하지 않을 수 있다.

### Cancellation

```cs
ParallelOptions options = new()
{
    CancellationToken = cancellationToken
};

try
{
    Parallel.ForEach(
        inputs,
        options,
        input => Process(input, cancellationToken));
}
catch (OperationCanceledException)
    when (cancellationToken.IsCancellationRequested)
{
    // 요청된 취소
}
```

Cancellation은 이미 시작한 모든 작업을 즉시 강제 종료하지 않는다. 반복 본문도 긴 계산 구간에서 Token을 확인해야 응답성이 높아진다.

### 예외 처리

여러 반복에서 예외가 발생하면 병렬 실행의 예외가 집계될 수 있다.

```cs
try
{
    Parallel.ForEach(inputs, Process);
}
catch (AggregateException exception)
{
    foreach (Exception inner in exception.Flatten().InnerExceptions)
    {
        LogWorkerFailure(inner);
    }
}
```

일부 결과가 이미 작성된 뒤 실패할 수 있다. 실패 시 배열 전체를 버릴지, 성공 결과만 사용할지 Transaction 경계를 정한다.

### PLINQ와 순서

```cs
Result[] results = inputs
    .AsParallel()
    .Select(Calculate)
    .ToArray();
```

결과 순서가 입력과 같아야 한다면 순서 보존을 명시할 수 있다.

```cs
Result[] results = inputs
    .AsParallel()
    .AsOrdered()
    .Select(Calculate)
    .ToArray();
```

순서 유지에는 결과를 다시 배열하는 비용이 추가될 수 있다. 순서가 정말 필요한지 확인한다.

---

## 내부 동작

### Task Scheduler

기본 Task Scheduler는 보통 Thread Pool 위에서 Task를 실행한다.

```text
Task 생성
↓
Scheduler Queue
↓
Thread Pool Worker가 Task 획득
↓
Delegate 실행
↓
Task 완료 상태와 결과 저장
↓
Continuation 실행 가능
```

Task가 Queue된 순서와 시작·완료 순서가 같다고 보장하지 않는다.

### Work Stealing

Worker별 Queue가 있을 때 한 Worker가 자신의 작업을 끝내면 다른 Worker의 남은 작업을 가져올 수 있다.

```text
Worker A Queue: 비어 있음
Worker B Queue: 작업 B1, B2, B3

Worker A가 B 작업 일부를 가져와 실행
```

작업량이 고르지 않을 때 Core 유휴 시간을 줄이는 데 도움이 된다.

### Granularity

작업 단위의 크기를 Granularity라고 한다.

```text
너무 작음
└─ Queue, Delegate와 Scheduling 비용이 계산보다 큼

너무 큼
└─ Worker 사이 부하 불균형

적절한 Chunk
└─ Scheduling 횟수와 부하 균형 절충
```

입력 요소 수만으로 판단하지 않고 요소 하나의 계산량도 함께 본다.

### Nested Parallelism

```cs
Parallel.ForEach(groups, group =>
{
    Parallel.ForEach(group.Items, Process);
});
```

중첩 병렬 반복은 더 많은 Core를 만드는 것이 아니다. 같은 Thread Pool에서 Scheduling과 경쟁을 늘릴 수 있다.

바깥 Group 또는 전체 Item 중 한 단계에서만 병렬화하는 편이 단순할 수 있다.

### Blocking과 Pool Starvation

병렬 본문에서 동기 I/O나 다른 Task 완료를 Block하면 Worker가 계산하지 않고 기다린다.

```cs
Parallel.ForEach(urls, url =>
{
    string data = httpClient.GetStringAsync(url).Result;
    Process(data);
});
```

I/O 동시성은 비동기 API와 별도 제한으로 설계한다. `Parallel.ForEach`는 CPU Bound 반복에 더 적합하다.

### Continuation Context

`await` 이후 코드가 어느 Thread에서 실행되는지는 Synchronization Context와 Awaitable 종류에 영향을 받는다.

```cs
Result[] results = await CalculateAsync(inputs, token);
ApplyToUnityObjects(results);
```

Unity 환경에서 Main Thread Context를 캡처한 호출이라면 복귀할 수 있지만 모든 Library 코드와 호출 위치에서 이를 가정하지 않는다.

계산 계층은 Unity API를 호출하지 않고, Unity 계층이 명시적으로 Main Thread에서 결과를 적용하도록 경계를 둔다.

---

## 실제 Unity에서는?

### Snapshot은 Main Thread에서 만든다

```cs
EnemyInput[] inputs = new EnemyInput[enemies.Count];

for (int i = 0; i < enemies.Count; i++)
{
    Enemy enemy = enemies[i];

    inputs[i] = new EnemyInput(
        enemy.Id,
        enemy.transform.position,
        enemy.Health);
}
```

Worker는 Transform이나 Component가 아닌 `EnemyInput`만 읽는다.

### 결과 적용 전에 유효성을 확인한다

계산하는 동안 Enemy가 Despawn될 수 있다.

```cs
foreach (EnemyResult result in results)
{
    if (!registry.TryGet(result.Handle, out Enemy? enemy))
    {
        continue;
    }

    enemy.Apply(result);
}
```

Thread Safe한 계산 결과라도 시간상 오래된 결과일 수 있다. ID, Generation과 Frame 번호 같은 논리적 유효성도 확인한다.

### 한 Frame 늦는 Pipeline

Main Thread에서 결과를 즉시 기다리지 않는다.

```text
Frame N
입력 Snapshot과 Worker 시작

Frame N+1
완료 확인

Frame N+1 또는 이후
결과 적용
```

AI 평가나 경로 요청이 한 Frame 이상 늦어도 되는지 시스템 요구사항을 정한다.

### Task.Result를 호출하지 않는다

```cs
Task<Result[]> task = CalculateAsync(inputs, token);
Result[] results = task.Result;
```

Main Thread가 완료를 Block해 Frame이 멈춘다. Context 의존적인 Continuation과 서로 기다리면 Deadlock 위험도 있다.

```cs
Result[] results = await CalculateAsync(inputs, token);
```

또는 완료된 Task만 Polling해 Frame 사이에 결과를 적용한다.

### Unity Job System과 비교한다

`Task`와 `Parallel`은 일반 Managed C# 작업에 편리하다. 대량의 동일 계산을 Unity Native Container로 처리한다면 Job System과 Burst가 더 적합할 수 있다.

```text
Task / Parallel
일반 C# 객체와 Library 활용
Thread Pool Scheduling
GC와 Managed Delegate 고려

Job System / Burst
Native Container와 Job Dependency
Data Oriented 작업
Burst 최적화 가능
```

Task 내부에서 다시 Job을 Scheduling하고 즉시 `Complete()`로 기다리는 식의 중첩은 흐름을 복잡하게 만들 수 있다.

### 다른 Unity Worker와 CPU를 공유한다

Rendering, Physics, Audio, Job System과 Runtime Thread Pool이 같은 CPU Core를 사용한다.

```text
ProcessorCount = 8
Task Worker 8개 사용
≠
게임이 자유롭게 쓸 Core 8개
```

`MaxDegreeOfParallelism`을 높여 계산 자체는 빨라져도 Main Thread와 Render Thread가 느려져 전체 Frame은 악화될 수 있다.

### Profiler Marker를 넣는다

```cs
private static readonly ProfilerMarker CalculateMarker =
    new("Threat.CalculateParallel");
```

Worker 실행 시간, Main Thread Wait, Scheduling Overhead와 결과 적용 시간을 각각 표시한다.

```text
순차 총 시간
병렬 총 CPU 시간
Wall-clock 완료 시간
Main Thread Block 시간
최악 Frame Time
```

병렬 버전의 총 CPU 사용량이 늘어도 Wall-clock 시간이 줄 수 있다. 목표 지표를 구분한다.

---

## 실무에서 자주 하는 오해

### Task.Run을 사용하면 내부 코드가 여러 Core에서 실행된다

하나의 Delegate는 기본적으로 한 Worker에서 실행된다. 내부 작업을 여러 Core로 나누려면 독립 작업이나 병렬 반복 구조가 필요하다.

### Parallel.For는 비동기 API다

호출한 Thread는 반복이 끝날 때까지 반환되지 않는다. Main Thread에서 직접 호출하면 해당 Frame을 Block할 수 있다.

### ProcessorCount만큼 병렬도를 설정하면 항상 최적이다

Unity의 다른 시스템, 효율 Core, Thermal 상태와 Memory Bandwidth도 CPU를 공유한다. Target Device에서 측정해야 한다.

### 반복 횟수가 많으면 병렬화가 항상 빠르다

요소당 계산이 매우 작으면 Partitioning과 Delegate 호출 비용이 더 클 수 있다. 입력 수와 요소당 작업량을 함께 본다.

### PLINQ는 LINQ보다 항상 빠르다

Partitioning과 결과 병합 비용이 추가되며 작은 입력에서는 더 느릴 수 있다. 순서 유지와 Materialization도 비용을 만든다.

### CancellationToken은 작업을 즉시 종료한다

협력적 취소다. 이미 실행 중인 긴 계산이 Token을 확인하거나 취소 가능한 API를 호출해야 빠르게 멈춘다.

### 하나의 반복이 실패하면 아무 결과도 변경되지 않는다

다른 반복이 이미 결과를 작성했을 수 있다. 실패 시 부분 결과를 버릴지 사용할지 정책이 필요하다.

### Task 안에서 Parallel을 쓰면 두 배로 병렬화된다

같은 Thread Pool을 중첩해서 사용해 Scheduling과 경쟁만 늘 수 있다. 하나의 분할 계층을 선택하고 비교한다.

### await 뒤에는 항상 Unity Main Thread다

호출 Context와 Awaitable에 따라 달라질 수 있다. Library 계산 코드는 Unity API와 분리하고 결과 적용 위치를 명확하게 보장한다.

### 병렬 버전의 CPU 합계가 크면 실패다

여러 Core가 동시에 일하면 총 CPU 시간은 늘어도 완료까지의 Wall-clock 시간이 줄 수 있다. Frame 안정성과 다른 시스템 영향까지 함께 평가한다.

---

## 마무리

`Task.Run()`은 하나의 CPU 작업을 Thread Pool에 Scheduling하고 완료와 결과를 표현한다. `Parallel.For()`는 반복 범위를 Partition으로 나누어 여러 Worker가 처리하게 한다.

```text
하나의 계산을 Main Thread 밖으로 이동
└─ Task.Run 검토

대량의 독립 반복 계산
└─ Parallel.For / ForEach 검토

선언적인 데이터 병렬 Query
└─ PLINQ 검토

Unity Data Oriented 대량 계산
└─ Job System과 Burst 검토
```

병렬화 전에는 다음 조건을 확인한다.

```text
입력과 출력이 독립적인가?
요소당 계산량이 충분한가?
공유 Lock이 병목이 되지 않는가?
Main Thread가 결과를 기다리지 않는가?
다른 Unity Worker의 CPU를 빼앗지 않는가?
```

순차 버전을 기준으로 유지하고 실제 Target Device에서 입력 크기별 경계점을 측정해야 한다.

병렬 API를 사용하는 것보다 작업을 적절한 크기로 나누고 공유 상태 없이 결과를 합치는 구조가 성능과 정확성을 결정한다.

---

## 핵심 정리

- Task는 작업의 완료, 결과, 취소와 예외를 표현하며 Thread 자체가 아니다.
- `Task.Run()`은 보통 하나의 CPU 작업을 Thread Pool Worker에서 실행한다.
- `Parallel.For()`는 반복을 Partition으로 나누지만 호출 자체는 동기식이다.
- 작업 단위가 너무 작으면 Scheduling 비용이 계산 이익보다 커질 수 있다.
- `MaxDegreeOfParallelism`은 상한이며 실제 Core 사용량이나 최적 성능을 보장하지 않는다.
- 공유 결과는 요소마다 Lock을 잡기보다 Worker별 지역 결과 후 병합하는 구조가 유리하다.
- 병렬 작업의 취소는 협력적이며 긴 작업 내부에서도 Token을 확인해야 한다.
- 여러 반복이 실패하면 예외와 부분 결과 처리 정책이 필요하다.
- Unity Worker에서는 Snapshot을 계산하고 Unity Object 적용은 Main Thread에서 수행한다.
- 순차 버전과 병렬 버전을 Target Device에서 Wall-clock, 총 CPU와 최악 Frame Time으로 비교해야 한다.
