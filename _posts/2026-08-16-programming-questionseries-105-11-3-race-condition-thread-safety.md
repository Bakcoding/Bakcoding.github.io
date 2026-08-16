---
title: "[궁금시리즈] 11-3. Race Condition과 Thread Safety는 무엇일까?"
excerpt: "C#"
categories:
  - CSharp
series: question-series
tags:
  - CSharp
permalink: /programming/11-3-race-condition-thread-safety/
toc: true
toc_sticky: true
date: 2026-08-16 12:00:33 +0900
last_modified_at: 2026-08-16 12:00:33 +0900
---

## 들어가며

여러 Thread가 같은 값을 1씩 증가시키면 최종 결과도 증가 횟수와 같아야 한다.

```cs
int counter = 0;

Parallel.For(0, 100_000, _ =>
{
    counter++;
});

Debug.Log(counter);
```

하지만 결과는 100,000보다 작을 수 있고 실행할 때마다 달라질 수 있다.

`counter++`가 하나의 명령처럼 보여도 내부적으로는 값을 읽고, 더하고, 다시 쓰는 여러 단계이기 때문이다.

```text
Thread A: counter 10 읽기
Thread B: counter 10 읽기
Thread A: 11 저장
Thread B: 11 저장

두 번 증가했지만 결과는 11
```

실행 순서에 따라 결과가 달라지는 문제를 Race Condition이라고 한다.

Race Condition은 값이 틀리는 경우에만 생기지 않는다. 중복 생성, Collection 손상, 이미 반환한 Pool 객체 재사용, 종료된 객체 접근처럼 상태 확인과 변경 사이에 다른 Thread가 끼어들 때 발생한다.

Thread Safety는 Lock을 붙이는 문법이 아니라 여러 Thread에서 실행되어도 상태의 불변 조건이 유지되도록 만드는 성질이다.

---

## 개념 설명

### Shared Mutable State

Race Condition에는 보통 여러 실행 흐름이 함께 읽고 수정하는 상태가 있다.

```text
Shared
└─ 여러 Thread가 접근

Mutable
└─ 실행 중 값이 변경됨
```

```cs
private readonly List<JobResult> results = new();
```

여러 Worker가 같은 List에 `Add()`하면 내부 Count와 배열 상태를 동시에 변경한다. `List<T>`는 이런 동시 쓰기를 보장하지 않는다.

### Atomicity

Atomic Operation은 다른 Thread가 중간 상태를 관찰할 수 없는 하나의 단위로 실행된다.

```cs
counter++;
```

소스 코드 한 줄이라고 Atomic한 것은 아니다.

```cs
Interlocked.Increment(ref counter);
```

`Interlocked`는 지원되는 단일 값 연산을 원자적으로 수행한다.

### Visibility

Thread A가 값을 썼다고 Thread B가 원하는 시점에 반드시 최신 값을 관찰한다고 단순히 가정할 수 없다.

```cs
bool isCompleted = false;
Result? result = null;
```

Worker가 `result`를 설정한 뒤 `isCompleted`를 바꿔도 적절한 동기화가 없다면 다른 Thread에서 관찰하는 순서를 안전한 통신 계약으로 사용할 수 없다.

Lock, Task 완료, Signal과 Concurrent Collection 같은 동기화 경계가 필요하다.

### Ordering

Compiler와 CPU는 단일 Thread 결과를 유지하는 범위에서 명령 실행을 최적화할 수 있다. 여러 Thread가 공유 상태로 통신한다면 쓰기와 읽기의 순서를 보장하는 규칙이 필요하다.

```text
Result 작성
↓
동기화된 완료 Signal
↓
다른 Thread가 완료 확인
↓
Result 읽기
```

### Check-then-act

상태를 확인한 뒤 행동하는 두 단계 사이에도 Race가 생긴다.

```cs
if (!players.ContainsKey(id))
{
    players.Add(id, player);
}
```

두 Thread가 동시에 `ContainsKey()`에서 false를 확인하면 둘 다 `Add()`를 시도할 수 있다.

```text
Thread A: Key 없음 확인
Thread B: Key 없음 확인
Thread A: Add
Thread B: Add → 예외
```

확인과 변경을 하나의 동기화 단위로 묶거나 해당 복합 연산을 제공하는 Concurrent API를 사용해야 한다.

### Thread Safety의 범위

Type이 Thread Safe하다는 말도 어떤 연산을 보장하는지 확인해야 한다.

단일 메서드 호출이 안전해도 여러 호출을 묶은 비즈니스 규칙까지 자동으로 Atomic해지는 것은 아니다.

---

## 코드 예제

### 잘못된 잔액 차감

```cs
public sealed class Wallet
{
    private int balance = 100;

    public bool TrySpend(int amount)
    {
        if (balance < amount)
        {
            return false;
        }

        balance -= amount;
        return true;
    }
}
```

두 Thread가 80을 동시에 사용하면 둘 다 잔액 100을 확인하고 성공할 수 있다.

### Lock으로 불변 조건 보호

```cs
public sealed class Wallet
{
    private readonly object gate = new();
    private int balance = 100;

    public bool TrySpend(int amount)
    {
        lock (gate)
        {
            if (balance < amount)
            {
                return false;
            }

            balance -= amount;
            return true;
        }
    }

    public int GetBalance()
    {
        lock (gate)
        {
            return balance;
        }
    }
}
```

잔액 확인과 차감을 같은 Critical Section에 넣는다. 쓰기만 잠그고 읽기는 잠그지 않으면 일관된 동기화 규칙이 되지 않는다.

### 잘못된 Lock 대상

```cs
lock (this)
{
    UpdateState();
}
```

외부 코드도 같은 객체에 Lock을 걸 수 있어 예상하지 못한 교착과 경쟁이 생길 수 있다.

```cs
private readonly object gate = new();
```

외부에 노출하지 않는 전용 객체를 Lock 대상으로 사용한다. 문자열 Literal이나 Type 객체처럼 다른 코드와 공유될 수 있는 대상도 피한다.

### Interlocked 사용

단순 Counter는 Lock 없이 원자적 연산을 사용할 수 있다.

```cs
private int completedCount;

public void MarkCompleted()
{
    Interlocked.Increment(ref completedCount);
}

public int GetCompletedCount()
{
    return Volatile.Read(ref completedCount);
}
```

하지만 여러 Field의 관계는 `Interlocked.Increment()` 하나로 보호되지 않는다.

```text
CurrentCount <= MaxCount
TotalDamage == 각 항목 Damage 합계
Key와 Value가 함께 변경됨
```

복합 불변 조건에는 더 큰 동기화 단위나 다른 데이터 구조가 필요하다.

### ConcurrentDictionary의 복합 연산

```cs
ConcurrentDictionary<int, Player> players = new();

bool added = players.TryAdd(id, player);
```

Key 확인과 추가를 별도 호출로 나누지 않고 `TryAdd()` 하나로 수행한다.

값을 생성할 때는 Factory가 한 번만 호출된다고 무조건 가정하지 않는다.

```cs
Player player = players.GetOrAdd(
    id,
    key => CreatePlayer(key));
```

경쟁 상황에서 Value Factory가 여러 번 실행될 수 있고 그중 하나의 결과만 저장될 수 있다. Factory에는 중복 실행되면 안 되는 외부 부작용을 넣지 않는다.

### Thread별 결과 후 병합

공유 List에 계속 Add하는 대신 Worker별 결과를 만든다.

```cs
Parallel.ForEach(
    partitions,
    partition =>
    {
        List<PathResult> localResults = new();

        foreach (PathRequest request in partition)
        {
            localResults.Add(Calculate(request));
        }

        completed.Enqueue(localResults);
    });
```

마지막에 한 Thread가 결과를 합친다.

```cs
while (completed.TryDequeue(
           out List<PathResult>? localResults))
{
    allResults.AddRange(localResults);
}
```

공유 쓰기 횟수를 결과 묶음 단위로 줄인다.

### Immutable Snapshot

```cs
public readonly record struct EnemySnapshot(
    int Id,
    Vector3 Position,
    float Health);
```

Main Thread가 Frame 시작에 Snapshot을 만들고 Worker는 읽기만 한다.

```text
Frame N의 Snapshot
↓
Worker들이 읽기 전용 계산
↓
결과 Queue
↓
Main Thread가 유효성 확인 후 적용
```

공유 상태를 수정하지 않으면 Lock이 필요한 지점도 줄어든다.

---

## 내부 동작

### Monitor와 Critical Section

C#의 `lock`은 한 시점에 하나의 Thread만 해당 영역에 진입하도록 한다.

```text
Thread A: Lock 획득 → Critical Section 실행
Thread B: Lock 대기
Thread A: Lock 해제
Thread B: Lock 획득
```

Lock 획득과 해제는 Memory Visibility를 위한 동기화 경계도 제공한다.

### Lock Contention

여러 Thread가 같은 Lock을 자주 요청하면 실제 실행이 직렬화된다.

```cs
Parallel.ForEach(items, item =>
{
    lock (gate)
    {
        results.Add(Process(item));
    }
});
```

`Process(item)`까지 Lock 안에 있어 계산 전체가 한 Thread씩 실행된다.

```cs
Parallel.ForEach(items, item =>
{
    Result result = Process(item);

    lock (gate)
    {
        results.Add(result);
    }
});
```

독립 계산은 Lock 밖에서 수행하고 공유 상태 변경만 최소 범위로 보호한다.

### False Sharing

서로 다른 변수라도 같은 CPU Cache Line에 있으면 여러 Core의 쓰기가 Cache 일관성 경쟁을 만들 수 있다.

```text
Cache Line
┌───────────────┐
│ WorkerA Count │
│ WorkerB Count │
└───────────────┘
```

논리적으로 공유하지 않는 값인데도 성능이 떨어질 수 있다. 정확성 문제는 아니지만 병렬 성능이 Memory Layout의 영향을 받는 사례다.

### Deadlock

두 Thread가 서로 가진 Lock을 기다리면 진행할 수 없다.

```text
Thread A: Lock X 보유 → Lock Y 대기
Thread B: Lock Y 보유 → Lock X 대기
```

여러 Lock이 필요하면 획득 순서를 전체 코드에서 일관되게 유지하고, Lock 안에서 외부 Callback이나 오래 걸리는 작업을 호출하지 않는다.

### Liveness 문제

Thread Safe는 데이터가 손상되지 않는 것만 의미하지 않는다.

```text
Deadlock
└─ 서로 기다려 영원히 진행하지 못함

Starvation
└─ 특정 작업이 실행 기회를 얻지 못함

Livelock
└─ 상태는 바뀌지만 서로 양보하며 완료하지 못함
```

정확성과 함께 시스템이 실제로 계속 진행되는지도 확인해야 한다.

### 비결정적 실행 순서

Thread Scheduling 순서는 실행할 때마다 달라질 수 있다.

```text
Run 1: A → B → C
Run 2: B → C → A
Run 3: C → A → B
```

특정 순서가 필요하면 우연한 Timing이 아니라 Queue, Signal, Dependency 같은 명시적인 규칙으로 표현해야 한다.

---

## 실제 Unity에서는?

### Unity Object를 공유 상태로 사용하지 않는다

```cs
Parallel.ForEach(enemies, enemy =>
{
    enemy.transform.position += Vector3.forward;
});
```

Transform 접근은 Main Thread 전용 규칙을 위반한다. Unity API에 Lock을 건다고 Worker 접근이 안전해지는 것은 아니다.

```text
Main Thread
Unity Object → 순수 데이터 Snapshot

Worker
Snapshot 계산 → 결과

Main Thread
결과 → Unity Object 적용
```

### 객체의 세대와 ID를 확인한다

Worker 계산 중 Enemy가 Despawn되고 같은 Pool Slot이 다른 Enemy에 재사용될 수 있다.

```cs
public readonly record struct EnemyHandle(
    int Id,
    int Generation);
```

결과 적용 시 ID뿐 아니라 Generation과 현재 생존 여부를 확인한다.

```cs
if (!registry.TryGet(
        result.Handle,
        out Enemy? enemy))
{
    return;
}

enemy.Apply(result);
```

Thread Safety가 보장되어도 오래된 결과를 새 객체에 적용하는 논리적 Race는 별도로 막아야 한다.

### Main Thread Queue의 Budget을 제한한다

```cs
private void Update()
{
    while (results.TryDequeue(out Result result))
    {
        Apply(result);
    }
}
```

Worker 결과가 한꺼번에 몰리면 Main Thread가 Queue를 모두 비우느라 Frame Budget을 넘을 수 있다.

```cs
private void Update()
{
    int processed = 0;

    while (processed < maxResultsPerFrame &&
           results.TryDequeue(out Result result))
    {
        Apply(result);
        processed++;
    }
}
```

Queue 최대 크기와 오래된 결과를 버릴 정책도 필요할 수 있다.

### Play Mode와 Static 상태

Domain Reload가 비활성화된 Editor 설정에서는 Static Queue와 취소 상태가 다음 Play Session에 남을 수 있다.

```cs
[RuntimeInitializeOnLoadMethod(
    RuntimeInitializeLoadType.SubsystemRegistration)]
private static void ResetState()
{
    while (results.TryDequeue(out _))
    {
    }
}
```

Worker 종료가 끝났는지 확인하지 않고 Queue만 비우면 이전 Worker가 다시 결과를 넣을 수 있다. 취소, 완료 대기, Queue 초기화 순서를 정한다.

### 로그가 Timing을 바꾼다

Race Condition을 찾기 위해 로그를 추가하면 Lock과 I/O 비용 때문에 Thread 실행 순서가 바뀌어 문제가 사라질 수 있다.

```text
로그 없음: Race 재현
로그 추가: 재현 안 됨
```

이를 Heisenbug라고 부르기도 한다. Stress 반복, Counter, Thread ID와 Timestamp를 가벼운 Buffer에 기록하고 종료 후 분석하는 방식을 사용할 수 있다.

### Development Build에서 반복한다

Race는 한 번 성공했다고 안전한 것이 아니다.

```text
작업 수 증가
Worker 수 변화
무작위 지연 삽입
취소와 종료 시점 반복
저성능 기기와 고성능 기기 비교
```

단, 테스트 반복으로 Race가 발견되지 않았다는 사실은 Thread Safety의 증명이 아니다. 공유 상태와 동기화 규칙을 코드 구조로 검토해야 한다.

---

## 실무에서 자주 하는 오해

### 소스 코드 한 줄은 Atomic하다

`counter++`, Collection 조회 후 추가와 여러 Field 변경은 한 줄이어도 여러 단계로 실행될 수 있다.

### 값 타입이면 Thread Safe하다

여러 Thread가 같은 변수 위치를 읽고 쓰면 Value Type도 Race가 발생한다. 큰 구조체의 읽기와 쓰기가 하나의 Atomic 연산이라고 보장할 수도 없다.

### volatile을 사용하면 Race Condition이 해결된다

Visibility와 Ordering에 일부 보장을 제공하지만 `counter++` 같은 복합 연산을 Atomic하게 만들지 않는다.

### Concurrent Collection이면 모든 코드가 안전하다

개별 연산은 안전해도 여러 호출을 묶은 조건은 Race가 생길 수 있다. `TryAdd`, `GetOrAdd`처럼 목적에 맞는 Atomic Operation을 사용한다.

### Lock 범위는 넓을수록 안전하다

정확성은 단순해질 수 있지만 병렬 실행이 직렬화되고 Deadlock 위험이 커진다. 보호해야 할 불변 조건을 기준으로 최소한의 범위를 정한다.

### 읽기만 하는 Thread는 Lock이 필요 없다

다른 Thread가 동시에 쓰고 있다면 일관되지 않은 상태나 오래된 값을 볼 수 있다. Immutable Snapshot처럼 읽는 동안 변경되지 않는다는 규칙이 필요하다.

### 테스트가 통과하면 Race가 없다

Scheduler Timing에 따라 드물게 발생할 수 있다. 반복 테스트는 발견 도구일 뿐 안전성은 공유 상태와 동기화 설계로 보장해야 한다.

### 결과가 맞으면 병렬 구현도 올바르다

현재 입력에서는 우연히 맞았을 수 있고 Lock 경쟁으로 순차 실행보다 느릴 수도 있다. 정확성과 성능을 각각 검증한다.

### Lock을 걸면 Unity API를 Worker에서 호출할 수 있다

Unity Main Thread 제약은 자신의 공유 데이터 Lock과 별개다. Engine API가 Main Thread 전용이면 Worker 접근을 피해야 한다.

---

## 마무리

Race Condition은 여러 실행 흐름이 공유 상태에 접근하고, 그 결과가 실행 순서에 따라 달라질 때 생긴다.

Thread Safety를 만들려면 세 가지를 구분해야 한다.

```text
Atomicity
복합 변경이 중간에 끼어들 수 없는가?

Visibility
다른 Thread가 최신 상태를 관찰하는가?

Ordering
결과 작성과 완료 신호의 순서가 보장되는가?
```

Lock과 Concurrent Collection은 필요한 도구지만 가장 단순한 해결은 공유되는 변경 가능 상태를 줄이는 것이다.

```text
Main Thread에서 Snapshot 생성
↓
Worker별 독립 계산
↓
Thread Safe Queue에 결과 전달
↓
Main Thread에서 결과 유효성 확인
↓
Unity Object에 적용
```

병렬 코드는 실행 순서를 예측하는 방식이 아니라 어떤 순서로 실행되어도 불변 조건이 유지되는 방식으로 설계해야 한다.

---

## 핵심 정리

- Race Condition은 공유 상태의 결과가 Thread 실행 순서에 따라 달라지는 문제다.
- Shared Mutable State가 많을수록 동기화해야 할 경계와 Race 가능성이 늘어난다.
- Atomicity, Visibility와 Ordering은 Thread Safety에서 서로 구분해 확인해야 한다.
- 상태 확인 후 변경하는 Check-then-act도 하나의 동기화 단위가 아니면 Race가 생긴다.
- `Interlocked`는 지원되는 단일 값 연산에 적합하지만 여러 Field의 불변 조건을 자동으로 보호하지 않는다.
- Concurrent Collection의 개별 메서드가 안전해도 여러 호출을 묶은 규칙은 별도 보호가 필요하다.
- Lock 안에는 공유 상태 변경만 두고 독립적인 긴 계산과 외부 Callback은 밖으로 분리한다.
- Immutable Snapshot과 Worker별 지역 결과는 공유 쓰기와 Lock 경쟁을 줄인다.
- Unity Object는 Lock으로 Worker 접근을 허용하지 않고 Main Thread에서 결과를 적용한다.
- 반복 테스트와 함께 공유 상태, 소유권과 동기화 규칙을 코드 구조로 검토해야 한다.
