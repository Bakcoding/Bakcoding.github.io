---
title: "[궁금시리즈] 11-4. lock과 동기화 도구는 언제 사용해야 할까?"
excerpt: "C#"
categories:
  - CSharp
series: question-series
tags:
  - CSharp
permalink: /programming/11-4-lock-synchronization-tools/
toc: true
toc_sticky: true
date: 2026-08-16 12:00:34 +0900
last_modified_at: 2026-08-16 12:00:34 +0900
---

## 들어가며

여러 Thread가 같은 상태를 수정하면 Race Condition을 막기 위한 동기화가 필요하다.

```cs
lock (gate)
{
    sharedValue++;
}
```

하지만 모든 공유 데이터에 `lock`을 붙이면 Thread Safety가 완성되는 것은 아니다.

```text
Counter 하나를 증가
└─ Interlocked가 더 단순할 수 있음

비동기 I/O의 동시 실행 수 제한
└─ SemaphoreSlim.WaitAsync가 적합할 수 있음

Process 사이에서 하나만 실행
└─ Mutex 같은 OS 동기화가 필요할 수 있음

읽기가 많고 쓰기가 드문 큰 상태
└─ ReaderWriterLockSlim 검토
```

잘못 선택한 동기화 도구는 Main Thread Block, Lock Contention, Deadlock과 복잡한 종료 문제를 만든다.

동기화의 목적은 모든 실행을 막는 것이 아니다. 어떤 상태의 어떤 불변 조건을 어느 범위에서 보호할지 정하고, 기다리는 동안 Thread를 Block해도 되는지 판단하는 것이다.

---

## 개념 설명

### Critical Section

동시에 한 실행 흐름만 들어가야 하는 코드 영역을 Critical Section이라고 한다.

```cs
if (balance >= amount)
{
    balance -= amount;
}
```

잔액 확인과 차감은 함께 보호되어야 한다.

```cs
lock (gate)
{
    if (balance >= amount)
    {
        balance -= amount;
    }
}
```

보호 대상은 코드 줄이 아니라 `balance`가 음수가 되지 않는다는 불변 조건이다.

### Mutual Exclusion

Mutual Exclusion은 한 시점에 하나의 실행 흐름만 보호 영역에 들어가도록 한다.

```text
Thread A: Lock 획득 → 실행
Thread B: Lock 대기
Thread C: Lock 대기
Thread A: Lock 해제
Thread B 또는 C: 실행 가능
```

실행 순서의 공정성이 항상 보장된다고 가정하지 않는다.

### Blocking과 Asynchronous Waiting

동기식 Lock을 기다리면 현재 Thread가 진행하지 못한다.

```cs
lock (gate)
{
    UpdateCache();
}
```

비동기 대기는 기다리는 동안 호출 Thread를 붙잡지 않고 나중에 재개할 수 있다.

```cs
await semaphore.WaitAsync(cancellationToken);
```

Main Thread에서 오래 기다릴 가능성이 있는 작업이라면 Blocking 여부가 Frame에 직접 영향을 준다.

### 동기화 범위

Lock 범위가 너무 좁으면 불변 조건 일부가 보호되지 않는다. 너무 넓으면 독립적인 작업까지 직렬화된다.

```text
공유 상태 읽기
조건 확인
상태 변경
```

이 세 단계가 하나의 규칙이라면 같은 동기화 경계 안에 있어야 한다.

### 동기화보다 소유권

하나의 Thread만 상태를 수정하고 다른 Thread는 Message로 요청하는 구조라면 Lock 수를 줄일 수 있다.

```text
Worker
Command Queue에 요청 추가
↓
Owner Thread
Queue를 읽어 상태 수정
```

모든 Thread가 모든 객체를 공유하는 구조보다 소유자를 정하는 구조가 단순하다.

---

## 코드 예제

### lock과 Monitor

```cs
private readonly object gate = new();
private readonly Dictionary<int, Player> players = new();

public bool TryAdd(Player player)
{
    lock (gate)
    {
        if (players.ContainsKey(player.Id))
        {
            return false;
        }

        players.Add(player.Id, player);
        return true;
    }
}
```

`lock`은 `Monitor.Enter()`와 `Monitor.Exit()`를 안전한 `try/finally` 형태로 사용하는 C# 문법이다.

개념적으로 다음과 비슷하다.

```cs
bool lockTaken = false;

try
{
    Monitor.Enter(gate, ref lockTaken);
    UpdateSharedState();
}
finally
{
    if (lockTaken)
    {
        Monitor.Exit(gate);
    }
}
```

일반적인 상호 배제에는 직접 `Monitor`를 쓰기보다 `lock`이 명확하다.

### Lock 밖에서 긴 계산 수행

```cs
lock (gate)
{
    Report report = BuildLargeReport(snapshot);
    reports.Add(report);
}
```

`BuildLargeReport()`가 공유 상태를 사용하지 않는다면 Lock 밖으로 옮긴다.

```cs
Report report = BuildLargeReport(snapshot);

lock (gate)
{
    reports.Add(report);
}
```

Lock 안에는 공유 Collection 변경만 남는다.

### Interlocked

단일 Counter와 상태 교환에는 `Interlocked`가 적합할 수 있다.

```cs
private int completedCount;

public void CompleteOne()
{
    Interlocked.Increment(ref completedCount);
}
```

한 번만 초기화해야 하는 참조를 원자적으로 교환할 수 있다.

```cs
private Cache? cache;

public Cache GetOrCreate()
{
    Cache? current = Volatile.Read(ref cache);

    if (current != null)
    {
        return current;
    }

    Cache created = BuildCache();
    Cache? existing = Interlocked.CompareExchange(
        ref cache,
        created,
        comparand: null);

    return existing ?? created;
}
```

경쟁 상황에서는 `BuildCache()`가 여러 번 호출될 수 있다. 생성에 외부 부작용이 있거나 비용이 매우 크다면 `Lazy<T>`나 Lock 기반 초기화를 검토한다.

### volatile과 Volatile

Worker에 정지 요청을 전달하는 단순 Flag에 사용할 수 있다.

```cs
private volatile bool stopRequested;

private void WorkerLoop()
{
    while (!stopRequested)
    {
        ProcessNext();
    }
}
```

하지만 `volatile`은 복합 연산을 Atomic하게 만들지 않는다.

```cs
private volatile int counter;

counter++; // 여전히 원자적 증가가 아님
```

실제 종료 흐름에는 `CancellationToken`이 조합과 전달 측면에서 더 적합한 경우가 많다.

### SemaphoreSlim

동시에 실행할 수 있는 작업 수를 제한한다.

```cs
private readonly SemaphoreSlim downloadSlots =
    new(initialCount: 3, maxCount: 3);

public async Task<byte[]> DownloadAsync(
    string url,
    CancellationToken cancellationToken)
{
    await downloadSlots.WaitAsync(cancellationToken);

    try
    {
        return await httpClient.GetByteArrayAsync(url);
    }
    finally
    {
        downloadSlots.Release();
    }
}
```

세 개 작업까지 동시에 진행하고 나머지는 비동기로 기다린다.

`WaitAsync()` 성공 후에는 예외나 취소가 발생해도 `finally`에서 반드시 Release한다. Wait가 성공하기 전에 Release하면 Count가 잘못 증가할 수 있으므로 `try/finally` 위치를 지킨다.

### Mutex

`Mutex`는 운영체제 수준의 동기화 객체로 Process 사이의 상호 배제에도 사용할 수 있다.

```cs
using Mutex mutex = new(
    initiallyOwned: false,
    name: "Global\\GamePatchWriter");

if (!mutex.WaitOne(millisecondsTimeout: 1000))
{
    throw new TimeoutException();
}

try
{
    WritePatchFiles();
}
finally
{
    mutex.ReleaseMutex();
}
```

Process 내부의 짧은 Critical Section에는 일반 `lock`보다 무겁다. Named Mutex 지원과 이름 규칙은 Target Platform을 확인해야 한다.

### ReaderWriterLockSlim

읽기는 동시에 허용하고 쓰기는 독점한다.

```cs
private readonly ReaderWriterLockSlim stateLock = new();
private readonly Dictionary<int, Item> items = new();

public bool TryGet(int id, out Item? item)
{
    stateLock.EnterReadLock();

    try
    {
        return items.TryGetValue(id, out item);
    }
    finally
    {
        stateLock.ExitReadLock();
    }
}
```

```cs
public void Set(Item item)
{
    stateLock.EnterWriteLock();

    try
    {
        items[item.Id] = item;
    }
    finally
    {
        stateLock.ExitWriteLock();
    }
}
```

읽기 구간이 충분히 길고 읽기 경쟁이 많으며 쓰기가 드물 때 이점이 있을 수 있다. 짧은 Dictionary 조회에는 관리 비용이 더 클 수 있으므로 측정해야 한다.

---

## 내부 동작

### Monitor의 재진입

같은 Thread는 자신이 획득한 Monitor에 다시 진입할 수 있다.

```cs
lock (gate)
{
    UpdateA();
}

private void UpdateA()
{
    lock (gate)
    {
        UpdateB();
    }
}
```

진입 횟수만큼 나와야 완전히 해제된다. 재진입 가능하다는 사실이 복잡한 중첩 Lock 설계를 권장한다는 뜻은 아니다.

### Monitor.Wait와 Pulse

`Monitor.Wait()`는 Lock을 잠시 놓고 조건 신호를 기다린다. `Pulse()`나 `PulseAll()`은 기다리는 Thread에 상태가 바뀌었음을 알린다.

조건은 `if`가 아니라 반복해서 확인해야 한다.

```cs
lock (gate)
{
    while (queue.Count == 0)
    {
        Monitor.Wait(gate);
    }

    WorkItem item = queue.Dequeue();
}
```

Signal은 상태 자체가 아니다. 깨어난 뒤 다른 Thread가 먼저 Queue를 비웠을 수 있으므로 조건을 다시 확인한다.

일반 Producer-Consumer 구조에는 `BlockingCollection<T>`나 Channel 같은 더 높은 수준의 도구가 단순할 수 있다.

### Interlocked의 Compare-and-swap

`CompareExchange`는 현재 값이 예상값과 같을 때만 새 값으로 교체한다.

```text
현재값 읽기
예상값과 비교
같으면 새 값 저장
이 과정을 원자적으로 수행
```

Lock-free Algorithm의 기반이 되지만 재시도 Loop, ABA 문제와 객체 수명까지 고려해야 한다. 단순히 Lock이 없다는 이유로 더 쉽거나 항상 빠른 것은 아니다.

### Semaphore Count

Semaphore는 소유 Thread를 추적하는 Lock과 다르게 허용 Slot 수를 관리한다.

```text
Count 3

작업 A Wait 성공 → Count 2
작업 B Wait 성공 → Count 1
작업 C Wait 성공 → Count 0
작업 D Wait 대기
작업 A Release → Count 1, D 진행
```

Release를 두 번 호출하면 실제 사용 가능한 Slot보다 Count가 커지거나 최대값에서 예외가 발생할 수 있다.

### Reader와 Writer 경쟁

Reader가 계속 들어오면 Writer가 오래 기다릴 수 있고, Writer 우선 정책은 새 Reader를 기다리게 할 수 있다.

실제 공정성과 Scheduling 특성을 코드가 임의로 가정하지 않는다. 읽기와 쓰기 비율, Critical Section 길이와 지연 분포를 측정한다.

### Deadlock 조건

여러 Lock의 획득 순서가 다르면 Deadlock이 생길 수 있다.

```cs
// Thread A
lock (playerGate)
{
    lock (inventoryGate)
    {
    }
}

// Thread B
lock (inventoryGate)
{
    lock (playerGate)
    {
    }
}
```

전체 코드에서 Lock 순서를 고정한다.

```text
항상 Player → Inventory 순서
```

가능하면 두 상태를 같은 Owner가 관리하거나 Message로 전달해 중첩 Lock 자체를 줄인다.

---

## 실제 Unity에서는?

### Main Thread에서 Lock 대기를 피한다

```cs
void Update()
{
    lock (resultGate)
    {
        ApplyAllResults();
    }
}
```

Worker가 같은 Lock 안에서 긴 작업을 수행하면 Main Thread Frame이 기다린다.

Worker는 완성된 결과를 `ConcurrentQueue<T>`에 넣고 Main Thread는 Lock 없이 꺼내는 구조를 사용할 수 있다.

```cs
private readonly ConcurrentQueue<Result> results = new();

private void Update()
{
    int count = 0;

    while (count < maxPerFrame &&
           results.TryDequeue(out Result result))
    {
        Apply(result);
        count++;
    }
}
```

### lock 안에서 Unity API를 호출하지 않는다

```cs
lock (gate)
{
    Instantiate(prefab);
}
```

Unity API가 Main Thread 전용이라는 규칙은 Lock으로 바뀌지 않는다. Worker가 Lock을 획득해 호출하면 안전하지 않고, Main Thread가 호출해도 Instantiate 시간 동안 다른 Thread를 오래 막는다.

공유 데이터만 보호하고 Unity Object 적용은 Lock 밖의 Main Thread 단계로 분리한다.

### async 메서드에서 lock을 유지하지 않는다

`lock` 영역 안에서는 `await`할 수 없다. 대기 중 Thread를 Block하지 않는 상호 배제가 필요하면 `SemaphoreSlim.WaitAsync()` 같은 구조를 사용한다.

```cs
await saveGate.WaitAsync(cancellationToken);

try
{
    await SaveAsync(cancellationToken);
}
finally
{
    saveGate.Release();
}
```

`SemaphoreSlim`은 재진입 Lock이 아니며 동일 호출 흐름이 다시 기다리면 스스로 막힐 수 있다.

### Lifecycle과 Dispose

`SemaphoreSlim`, `ReaderWriterLockSlim`, `Mutex` 같은 Disposable 동기화 객체는 더 이상 Wait하는 작업이 없을 때 정리한다.

```text
새 요청 중단
↓
Cancellation 전달
↓
진행 중 작업 완료 대기
↓
동기화 객체 Dispose
```

Wait 중인 Worker가 있는데 먼저 Dispose하면 종료 Race가 생길 수 있다.

### Job System의 안전성 규칙

Unity Job System은 Job Dependency와 Native Container의 Safety System으로 데이터 접근 충돌을 제한한다.

```text
Job A가 NativeArray 쓰기
↓ Dependency
Job B가 같은 NativeArray 읽기
```

일반 C# Lock을 Job 내부에서 사용하는 방식보다 읽기와 쓰기 Dependency를 명시하고 Job별 데이터 범위를 나누는 구조가 적합하다.

### Profiler에서 대기를 확인한다

동기화는 CPU 계산 Sample보다 Wait Sample로 성능을 소비할 수 있다.

```text
Main Thread의 Lock 대기
Worker의 Semaphore 대기
긴 Critical Section
Context Switch 증가
Job Dependency 대기
```

평균 Lock 횟수보다 가장 긴 Wait가 Frame Budget에 어떤 영향을 주는지 확인한다.

---

## 실무에서 자주 하는 오해

### lock을 붙이면 코드 전체가 Thread Safe해진다

같은 상태에 접근하는 모든 경로가 같은 규칙을 따라야 한다. 다른 메서드가 Lock 없이 읽거나 다른 Lock을 사용하면 보호되지 않는다.

### volatile은 가벼운 lock이다

Visibility와 Ordering에 일부 보장을 제공하지만 상호 배제나 복합 연산의 Atomicity를 제공하지 않는다.

### Interlocked는 lock보다 항상 빠르고 좋다

단일 값 연산에는 적합하지만 여러 상태의 불변 조건과 복잡한 전환에는 사용하기 어렵다. 재시도 경쟁이 심하면 비용도 커질 수 있다.

### SemaphoreSlim은 lock과 완전히 같다

여러 동시 진입을 허용할 수 있고 소유 Thread 개념이 다르다. Release 횟수를 직접 정확히 관리해야 한다.

### ReaderWriterLockSlim은 읽기가 있으면 항상 빠르다

Lock 관리 비용이 있으므로 Critical Section이 짧거나 경쟁이 적으면 일반 Lock보다 느릴 수 있다.

### Mutex는 더 강한 lock이므로 Process 내부에도 좋다

Process 간 동기화를 지원하는 대신 운영체제 수준 비용이 크다. Process 내부 상호 배제에는 더 가벼운 도구를 우선 검토한다.

### Lock 안에서 await하면 상태를 안전하게 유지할 수 있다

`lock` 안에서는 `await`할 수 없고, 비동기 대기 동안 상태를 독점하면 긴 지연과 Deadlock 위험이 생길 수 있다. 비동기 흐름에 맞는 설계가 필요하다.

### Timeout이 있으면 Deadlock이 해결된다

영원한 대기를 피할 수는 있지만 부분 변경, 재시도와 실패 처리 문제가 남는다. Lock 순서와 소유 구조를 고치는 것이 먼저다.

### ConcurrentQueue를 쓰면 Backpressure가 필요 없다

생산 속도가 소비 속도보다 빠르면 Queue와 메모리가 계속 증가한다. 최대 크기, 오래된 결과 폐기와 Frame당 소비 Budget이 필요하다.

---

## 마무리

동기화 도구는 보호할 상태와 기다림의 형태에 맞춰 선택한다.

```text
여러 Field의 짧은 불변 조건
└─ lock

단일 Counter와 원자적 교환
└─ Interlocked

간단한 상태 가시성
└─ volatile / Volatile

동시 실행 수 제한과 비동기 대기
└─ SemaphoreSlim

Process 간 상호 배제
└─ Mutex

읽기가 많고 긴 읽기 구간
└─ ReaderWriterLockSlim 검토
```

도구보다 먼저 공유 상태를 줄일 수 있는지 확인한다.

```text
상태 Owner 지정
↓
Immutable Snapshot 전달
↓
Worker별 독립 결과 생성
↓
Thread Safe Queue로 소유권 이전
```

Lock이 필요하다면 보호하는 불변 조건을 문서화하고, 획득 순서를 통일하며, Critical Section에서 I/O, Unity API와 외부 Callback을 제거한다.

Thread Safety와 성능은 별도 검증 대상이다. 정확한 Lock도 Main Thread를 오래 기다리게 하면 실시간 게임에는 적합하지 않을 수 있다.

---

## 핵심 정리

- 동기화는 코드 줄이 아니라 여러 상태가 함께 만족해야 하는 불변 조건을 보호한다.
- `lock`은 짧은 Critical Section의 상호 배제와 Memory Visibility 경계를 제공한다.
- Lock 대상은 외부에 노출되지 않는 전용 객체를 사용한다.
- `Interlocked`는 Counter와 Compare-and-swap 같은 단일 값 원자 연산에 적합하다.
- `volatile`은 복합 연산을 Atomic하게 만들거나 상호 배제를 제공하지 않는다.
- `SemaphoreSlim`은 동시 실행 수 제한과 `WaitAsync()` 기반 비동기 대기에 사용할 수 있다.
- `Mutex`는 Process 간 동기화가 필요할 때 검토하며 Process 내부에서는 상대적으로 무겁다.
- `ReaderWriterLockSlim`은 읽기 경쟁과 Critical Section이 충분할 때 측정 후 선택한다.
- Deadlock을 줄이려면 Lock 획득 순서를 통일하고 중첩 Lock과 외부 Callback을 피한다.
- Unity Main Thread에서는 Lock 대기를 최소화하고 Queue와 결과 Budget으로 Worker 결과를 적용한다.
