---
title: "[궁금시리즈] 11-2. Thread와 Thread Pool은 어떻게 동작할까?"
excerpt: "C#"
categories:
  - CSharp
series: question-series
tags:
  - CSharp
permalink: /programming/11-2-thread-thread-pool/
toc: true
toc_sticky: true
date: 2026-08-16 12:00:32 +0900
last_modified_at: 2026-08-16 12:00:32 +0900
---

## 들어가며

오래 걸리는 계산을 Main Thread에서 실행하면 해당 작업이 끝날 때까지 Frame이 멈춘다.

```cs
void Start()
{
    byte[] data = CompressLargeData();
    Save(data);
}
```

별도 Thread에서 실행하면 Main Thread는 다음 Frame을 계속 처리할 수 있다.

```cs
Thread worker = new(() =>
{
    byte[] data = CompressLargeData();
    Save(data);
});

worker.Start();
```

하지만 Thread는 단순한 함수 호출이 아니다.

```text
자신의 실행 Stack
운영체제 Scheduling 대상
시작과 종료 수명
예외 처리
취소와 완료 통지
공유 데이터 동기화
```

짧은 작업마다 Thread를 직접 만들면 실제 계산보다 생성과 Scheduling 비용이 커질 수 있다.

Thread Pool은 Worker Thread를 미리 관리하고 여러 작업이 재사용하도록 만든다. 직접 Thread를 소유해야 하는 경우와 Thread Pool에 짧은 작업을 맡기는 경우를 구분해야 한다.

---

## 개념 설명

### Process와 Thread

Process는 실행 중인 프로그램의 자원 경계다. 하나의 Process 안에는 여러 Thread가 존재할 수 있다.

```text
Unity Player Process
├─ Main Thread
├─ Render 관련 Thread
├─ Audio Thread
├─ Job Worker
└─ Runtime Thread Pool Worker
```

같은 Process의 Thread는 Heap과 여러 자원을 공유하지만 각자 실행 흐름과 Stack을 가진다.

### Thread Stack

각 Thread에는 메서드 호출, 지역 변수와 실행 위치를 추적하는 Stack이 있다.

```text
Main Thread Stack
PlayerLoop
└─ Update
   └─ MovePlayer

Worker Thread Stack
WorkerLoop
└─ Compress
   └─ EncodeBlock
```

Thread를 많이 만들면 실행하지 않고 대기하는 Thread도 Stack과 운영체제 자원을 사용한다.

### Thread 상태

Thread의 실행 흐름은 개념적으로 다음 상태를 오간다.

```text
생성됨
↓ Start
실행 가능
↓ Scheduler 선택
실행 중
↓ Sleep / Wait / Lock
대기
↓ 조건 충족
실행 가능
↓ 작업 종료
종료됨
```

`Start()`를 호출한 Thread는 다시 시작할 수 없다. 반복 작업이 필요하다면 Thread 내부에 Loop를 두거나 Thread Pool 작업으로 나눈다.

### Foreground와 Background Thread

Foreground Thread가 실행 중이면 일반적으로 Process는 해당 Thread가 끝날 때까지 종료를 기다린다.

Background Thread는 모든 Foreground Thread가 끝나면 작업 중이어도 Process 종료와 함께 중단될 수 있다.

```cs
Thread worker = new(WorkerLoop)
{
    IsBackground = true
};
```

Background라는 이름이 CPU 우선순위가 낮다는 뜻은 아니다. Process 종료를 유지하는지에 관한 구분이다.

### Thread Pool

Thread Pool은 Runtime이 Worker Thread 집합과 작업 Queue를 관리하는 구조다.

```text
작업 A ┐
작업 B ├─ Work Queue
작업 C ┘
       ↓
재사용되는 Worker Thread
```

작업이 끝나도 Worker를 바로 없애지 않고 다음 작업에 재사용할 수 있어 반복 생성 비용을 줄인다.

### Task와 Thread Pool

```cs
Task<int> task = Task.Run(() =>
{
    return CalculateScore();
});
```

`Task.Run()`은 보통 Thread Pool에 작업을 Scheduling한다. Task는 완료, 결과, 취소와 예외를 나타내며 Thread 자체를 직접 소유하는 API가 아니다.

---

## 코드 예제

### 직접 Thread 생성

```cs
public sealed class MapGenerator
{
    private Thread? worker;
    private Exception? workerException;
    private MapData? result;
    private volatile bool isCompleted;

    public void Start(MapInput input)
    {
        if (worker != null)
        {
            throw new InvalidOperationException(
                "Worker already started.");
        }

        worker = new Thread(() => Run(input))
        {
            IsBackground = true,
            Name = "Map Generator"
        };

        worker.Start();
    }
}
```

Worker 내부의 예외를 기록한다.

```cs
private void Run(MapInput input)
{
    try
    {
        result = Generate(input);
    }
    catch (Exception exception)
    {
        workerException = exception;
    }
    finally
    {
        isCompleted = true;
    }
}
```

Main Thread에서 완료를 확인하고 결과를 적용한다.

```cs
public bool TryGetResult(out MapData? map)
{
    map = null;

    if (!isCompleted)
    {
        return false;
    }

    if (workerException != null)
    {
        throw new InvalidOperationException(
            "Map generation failed.",
            workerException);
    }

    map = result;
    return true;
}
```

이 예제는 직접 Thread 수명에 필요한 책임을 보여 주기 위한 단순 구조다. 여러 필드의 공개 순서와 재사용까지 엄격히 보장하려면 Lock, 완료 Signal, Task 또는 다른 동기화 구조가 필요하다.

`volatile` 하나가 모든 공유 데이터의 Thread Safety를 자동으로 보장하지는 않는다.

### 취소 가능한 Worker Loop

Thread를 강제로 중단하는 대신 협력적 취소를 사용한다.

```cs
public sealed class FileWorker : IDisposable
{
    private readonly CancellationTokenSource cancellation = new();
    private readonly BlockingCollection<FileJob> jobs = new();
    private readonly Thread worker;

    public FileWorker()
    {
        worker = new Thread(WorkerLoop)
        {
            IsBackground = true,
            Name = "File Worker"
        };

        worker.Start();
    }
}
```

```cs
private void WorkerLoop()
{
    try
    {
        foreach (FileJob job in jobs.GetConsumingEnumerable(
                     cancellation.Token))
        {
            Process(job, cancellation.Token);
        }
    }
    catch (OperationCanceledException)
    {
        // 정상적인 종료 경로
    }
}
```

```cs
public void Enqueue(FileJob job)
{
    if (jobs.IsAddingCompleted)
    {
        throw new InvalidOperationException(
            "Worker is shutting down.");
    }

    jobs.Add(job);
}
```

종료할 때 새 작업을 막고, 취소를 전달한 뒤 Thread가 끝날 시간을 준다.

```cs
public void Dispose()
{
    jobs.CompleteAdding();
    cancellation.Cancel();

    if (!worker.Join(millisecondsTimeout: 1000))
    {
        Debug.LogWarning("File worker did not stop in time.");
    }

    jobs.Dispose();
    cancellation.Dispose();
}
```

`Join()`은 호출한 Thread를 기다리게 한다. Main Thread에서 긴 Timeout으로 기다리면 종료 Frame이 멈출 수 있으므로 Worker 작업이 Cancellation을 자주 확인하도록 설계한다.

### Thread Pool Queue

결과가 필요 없는 짧은 작업은 Thread Pool에 Queue할 수 있다.

```cs
ThreadPool.QueueUserWorkItem(
    static state =>
    {
        LogBatch batch = (LogBatch)state!;
        batch.WriteToDisk();
    },
    logBatch);
```

하지만 완료, 결과와 예외를 직접 관리해야 하므로 일반 애플리케이션 코드에서는 Task가 더 편리하다.

```cs
Task writeTask = Task.Run(() =>
{
    logBatch.WriteToDisk();
});
```

### 예외 관찰

```cs
try
{
    await Task.Run(() => Process(data));
}
catch (Exception exception)
{
    Debug.LogException(exception);
}
```

Task 내부의 예외는 Task에 저장되고 `await`할 때 다시 전달된다. Fire-and-forget으로 버리면 실패를 관찰하지 못할 수 있다.

### Thread Pool을 Block하지 않는다

```cs
Task.Run(() =>
{
    networkEvent.WaitOne();
});
```

오래 대기하는 작업이 Thread Pool Worker를 점유한다. 같은 작업이 많아지면 새 작업이 Worker를 받지 못하고 지연될 수 있다.

비동기 I/O API가 있다면 Thread를 Block하는 대기보다 `await` 기반 API를 우선 검토한다.

---

## 내부 동작

### Thread 생성 비용

새 Thread를 만들 때 Runtime과 운영체제는 실행 Stack과 Thread 상태를 준비하고 Scheduler에 등록한다.

```text
Thread 객체 생성
↓
Native Thread 생성
↓
Stack과 상태 준비
↓
Scheduler 등록
↓
실행 시작
```

작업이 0.1ms인데 Thread 준비와 전환에 비슷하거나 더 큰 비용이 든다면 병렬화 이점이 없다.

### Scheduler와 Time Slice

실행 가능한 Thread가 Logical Core보다 많으면 운영체제 Scheduler가 실행 시간을 나눈다.

```text
Core 1
Thread A → Thread B → Thread C

Core 2
Thread D → Thread E
```

Thread가 바뀔 때 Register와 실행 상태를 저장하고 복원한다. Working Set이 바뀌면서 CPU Cache 효율도 낮아질 수 있다.

### Thread Pool Worker 재사용

Thread Pool은 Queue에 들어온 작업을 기존 Worker가 가져가 실행하도록 관리한다.

```text
Worker 1: 작업 A 완료 → 작업 D 실행
Worker 2: 작업 B 완료 → 작업 E 실행
Worker 3: 작업 C 실행 중
```

부하와 Block 상태에 따라 Runtime이 Worker 수를 조절할 수 있다. 개발자가 작업 하나당 Thread 수를 직접 맞추지 않아도 된다.

### Thread Pool Starvation

Worker가 모두 긴 Blocking 작업을 수행하면 Queue의 짧은 작업도 시작하지 못할 수 있다.

```text
Worker 1: Wait
Worker 2: Wait
Worker 3: Wait
Worker 4: Wait

Queue: 짧은 작업 A, B, C
```

Runtime이 Worker를 추가할 수 있어도 즉시 원하는 수만큼 늘어난다고 기대하면 안 된다. CPU Bound 작업, Blocking I/O와 오래 유지되는 전용 Loop를 같은 방식으로 Queue하지 않는다.

### Thread Local State

Thread는 자신의 Stack을 가지지만 Heap 객체는 다른 Thread와 공유할 수 있다.

```cs
List<int> values = new();

Thread a = new(() => values.Add(1));
Thread b = new(() => values.Add(2));
```

List는 Thread Safe하지 않다. 각 Thread Stack이 분리되어 있다는 사실이 공유 Heap 객체의 안전성을 보장하지 않는다.

Thread Pool 작업은 실행할 때마다 같은 Worker Thread에서 실행된다고 보장되지 않는다. Thread Local 값과 특정 Thread Affinity에 의존하는 코드는 별도 설계가 필요하다.

### Memory Visibility와 완료 신호

Worker가 결과를 쓴 뒤 Main Thread에 완료를 알릴 때는 결과 쓰기와 완료 관찰의 순서가 보장되어야 한다.

Task, Lock, `ManualResetEventSlim`, Channel과 Concurrent Collection 같은 동기화 도구는 이 경계를 제공한다.

```text
Worker가 Result 작성
↓
동기화된 완료 Signal
↓
Main Thread가 완료 확인
↓
Result 읽기
```

일반 Boolean Field 하나만 반복해서 확인하는 구조는 Compiler와 CPU의 Memory Ordering까지 고려하지 못할 수 있다.

---

## 실제 Unity에서는?

### Main Thread에서 Unity Object를 준비한다

Worker가 Unity Component를 직접 읽지 않도록 필요한 값을 Snapshot으로 만든다.

```cs
EnemyInput[] inputs = new EnemyInput[enemies.Count];

for (int i = 0; i < enemies.Count; i++)
{
    Enemy enemy = enemies[i];

    inputs[i] = new EnemyInput(
        enemy.transform.position,
        enemy.Health);
}
```

Worker에서는 `EnemyInput` 같은 순수 데이터만 처리하고 결과는 Main Thread Queue로 전달한다.

### 결과 Queue

```cs
private readonly ConcurrentQueue<Action> mainThreadActions = new();

public void Post(Action action)
{
    mainThreadActions.Enqueue(action);
}

private void Update()
{
    while (mainThreadActions.TryDequeue(out Action? action))
    {
        action.Invoke();
    }
}
```

Worker에서 Queue에 넣는 Action이 Unity Object를 캡처하면 적용 전 객체가 파괴될 수 있다. Main Thread에서 유효성을 다시 확인하고 Frame당 처리 Budget도 제한해야 한다.

Queue에 작업이 몰리면 한 Frame에 모두 처리해 새로운 Spike를 만들 수 있다.

### Play Mode 종료 처리

MonoBehaviour가 파괴되어도 직접 만든 Thread가 자동으로 협력적 종료를 수행하지는 않는다.

```cs
private FileWorker? worker;

private void OnEnable()
{
    worker = new FileWorker();
}

private void OnDisable()
{
    worker?.Dispose();
    worker = null;
}
```

Editor의 Enter Play Mode 설정과 Domain Reload 여부에 따라 Static 상태 수명도 달라질 수 있다. Play 시작과 종료에 Worker, CancellationTokenSource와 Queue를 명시적으로 초기화한다.

### Application 종료

모바일 Suspend나 Process 강제 종료에서는 긴 정리 작업이 끝날 시간을 보장받지 못할 수 있다.

중요 데이터는 종료 Event 한 번에 모두 저장하기보다 Gameplay 중 안전한 Checkpoint에서 저장한다. Background Thread이므로 종료까지 계속 실행될 것이라고 기대하지 않는다.

### 전용 Thread가 적합한 경우

다음 조건에서는 전용 Thread를 검토할 수 있다.

```text
작업 Loop가 애플리케이션 수명 동안 유지됨
특정 Blocking API를 계속 감시함
Thread Affinity가 필요함
Thread Pool을 오래 점유하면 안 됨
우선순위와 수명을 직접 관리해야 함
```

일반적인 짧은 계산은 Task, 대량 Unity 계산은 Job System이 더 적합할 수 있다.

### Profiler에서 Worker를 확인한다

Thread 이름을 지정하면 Timeline에서 작업을 찾기 쉽다.

```cs
worker.Name = "Map Generator";
```

다음 항목을 확인한다.

```text
Main Thread가 Join이나 Wait로 Block되는가?
Worker가 실제로 계산하는 시간은 얼마인가?
Worker 수가 Core보다 과도한가?
Lock 대기가 긴가?
작업 Queue가 밀리는가?
```

---

## 실무에서 자주 하는 오해

### Thread를 만들면 새로운 CPU Core를 얻는다

Thread는 Scheduler가 Core에 배치하는 실행 흐름이다. Core 수보다 Thread가 많으면 시간을 나눠 사용하며 Context Switch가 증가할 수 있다.

### Background Thread는 낮은 우선순위로 실행된다

Background 여부는 Process 종료를 유지하는지에 관한 설정이다. Thread Priority와 같은 개념이 아니다.

### Background Thread는 Unity 종료 시 안전하게 정리된다

Process 종료와 함께 작업 중에 중단될 수 있다. 중요한 저장이나 Resource 정리를 완료한다고 보장할 수 없다.

### Thread Pool은 Thread 수가 고정되어 있다

Runtime은 부하와 Worker 상태에 따라 수를 조절할 수 있다. 특정 작업이 항상 같은 Thread에서 실행되는 것도 아니다.

### Thread Pool에는 오래 걸리는 작업을 얼마든지 넣어도 된다

오래 Block되는 작업이 Worker를 점유하면 다른 작업이 지연되는 Starvation이 생길 수 있다.

### volatile을 붙이면 객체가 Thread Safe해진다

특정 Field의 읽기와 쓰기 순서에 일부 보장을 제공할 뿐 여러 단계 연산이나 List 같은 객체의 복합 상태를 보호하지 않는다.

### IsBackground만 true면 종료 코드는 필요 없다

Process 종료를 막지 않을 뿐 Cancellation, Queue 종료, Resource 해제와 완료 대기 책임은 남아 있다.

### Worker에서 발생한 예외는 Main Thread가 자동으로 받는다

직접 만든 Thread의 예외는 호출자 Stack으로 돌아오지 않는다. Worker 경계에서 기록하고 완료 결과로 전달해야 한다. Task 예외도 `await`하거나 명시적으로 관찰해야 한다.

### Join으로 기다리면 가장 안전하다

완료 순서는 보장할 수 있지만 Main Thread에서 긴 Join을 호출하면 게임이 멈춘다. 취소 응답성을 높이고 기다리는 구간과 Timeout을 제한해야 한다.

---

## 마무리

Thread는 독립적인 실행 Stack과 운영체제 Scheduling 상태를 가진 실행 흐름이다.

직접 만든 Thread는 수명과 종료를 세밀하게 관리할 수 있지만 생성, 취소, 예외와 완료 동기화 책임도 모두 개발자에게 있다.

Thread Pool은 Worker를 재사용해 짧은 작업을 효율적으로 처리하지만 긴 Blocking 작업으로 Worker를 점유하면 Queue 전체가 지연될 수 있다.

```text
짧은 독립 작업
└─ Task와 Thread Pool 검토

오래 유지되는 Blocking Loop
└─ 전용 Thread 검토

대량의 Unity 수치 계산
└─ Job System과 Burst 검토

I/O 대기
└─ 비동기 I/O API 우선 검토
```

Unity에서는 Worker가 순수 데이터를 처리하고 Main Thread가 Engine Object에 결과를 적용하도록 경계를 나눈다.

어떤 방식을 사용해도 시작 코드와 함께 종료 코드, Cancellation, 예외 전달과 결과 소유권을 설계해야 한다.

---

## 핵심 정리

- Process 안의 Thread는 Heap 자원을 공유하지만 각자의 실행 흐름과 Stack을 가진다.
- Thread 생성에는 Native Thread, Stack과 Scheduler 상태를 준비하는 비용이 든다.
- Foreground와 Background 구분은 Process 종료 유지 여부이며 실행 우선순위가 아니다.
- Thread Pool은 Worker Thread를 재사용해 짧은 작업의 반복 생성 비용을 줄인다.
- `Task.Run()`은 보통 Thread Pool에 작업을 Scheduling하며 Task가 Thread 자체를 의미하지는 않는다.
- 오래 Block되는 Thread Pool 작업이 많으면 다른 작업이 지연되는 Starvation이 생길 수 있다.
- 직접 만든 Thread에는 협력적 취소, 예외 전달, 완료 신호와 종료 대기가 필요하다.
- `volatile` 하나로 여러 공유 데이터와 복합 연산의 Thread Safety를 보장할 수 없다.
- Unity Worker에서는 순수 데이터를 처리하고 Unity Object 결과 적용은 Main Thread에서 수행한다.
- Editor와 Application 종료 시 Worker, Queue와 Cancellation Resource를 명시적으로 정리해야 한다.
