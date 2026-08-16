---
title: "[궁금시리즈] 11-1. 병렬 프로그래밍은 왜 필요할까?"
excerpt: "C#"
categories:
  - CSharp
series: question-series
tags:
  - CSharp
permalink: /programming/11-1-why-parallel-programming/
toc: true
toc_sticky: true
date: 2026-08-16 12:00:31 +0900
last_modified_at: 2026-08-16 12:00:31 +0900
---

## 들어가며

게임의 Frame은 제한된 시간 안에 모든 작업을 끝내야 한다.

60FPS를 목표로 한다면 Frame 하나에 사용할 수 있는 시간은 약 16.67ms다.

```text
Input          0.5ms
Game Logic     5.0ms
Physics        4.0ms
Animation      3.0ms
Rendering 준비 6.0ms
-------------------
합계          18.5ms
```

Main Thread에서 작업을 순서대로 처리해 Budget을 넘으면 Frame Rate가 내려간다.

현대 CPU는 여러 Core를 가지고 있다. 서로 독립적인 계산을 여러 Thread나 Worker에서 동시에 실행할 수 있다면 Frame 시간을 줄일 가능성이 생긴다.

```text
한 Thread에서 순차 실행
A → B → C → D

여러 Core에서 병렬 실행
Core 1: A → B
Core 2: C → D
```

하지만 작업을 병렬로 옮긴다고 항상 빨라지는 것은 아니다. 작업 분할, Thread 전환, 동기화와 결과 합치기에도 비용이 든다.

병렬 프로그래밍은 코드를 여러 Thread에서 실행하는 기술이 아니라, 동시에 실행해도 안전한 작업을 찾고 분할 비용보다 큰 이익을 얻도록 설계하는 작업이다.

---

## 개념 설명

### 동시성과 병렬성

두 개념은 비슷하지만 같지 않다.

동시성은 여러 작업이 같은 시간 구간에 진행되는 구조다.

```text
한 Core

Task A 실행
→ Task B 실행
→ Task A 재개
→ Task B 재개
```

작업을 빠르게 번갈아 실행해 둘 다 진행될 수 있다.

병렬성은 여러 작업이 실제로 같은 순간에 실행되는 구조다.

```text
Core 1: Task A 실행
Core 2: Task B 실행
```

비동기 I/O는 대기 중 Thread를 점유하지 않는 동시성이 목적일 수 있고, 큰 수치 계산은 여러 Core가 동시에 계산하는 병렬성이 목적일 수 있다.

### CPU Bound와 I/O Bound

작업 특성에 따라 선택하는 도구가 달라진다.

```text
CPU Bound
Pathfinding, 대량 수치 계산, 데이터 변환
└─ 여러 Core의 계산 능력 활용 검토

I/O Bound
파일, Network, Asset 응답 대기
└─ Async로 대기 중 Thread 점유 방지
```

I/O 응답을 기다리는 코드를 새 Thread에 올린다고 디스크나 Network 자체가 빨라지지는 않는다.

### Thread

Thread는 CPU가 명령을 실행하는 흐름이다.

```cs
Thread worker = new(() =>
{
    CalculatePath();
});

worker.Start();
```

직접 Thread를 만들면 시작, 종료, 예외와 동기화 책임도 직접 관리해야 한다. 짧은 작업마다 Thread를 새로 만드는 것은 비용이 크다.

### Thread Pool과 Task

Thread Pool은 미리 관리되는 Worker Thread를 여러 작업이 공유한다.

```cs
Task<int> task = Task.Run(() =>
{
    return CalculateScore();
});
```

Task는 작업의 완료, 결과와 예외를 표현한다. Task 하나가 항상 새로운 Thread 하나를 의미하지는 않는다.

### Unity Main Thread

대부분의 UnityEngine Object API는 Main Thread에서 사용해야 한다.

```cs
Task.Run(() =>
{
    transform.position = Vector3.zero;
});
```

이런 코드는 안전하지 않다. `Transform`, `GameObject`, `Renderer` 같은 Engine Object를 Worker Thread에서 직접 수정하지 않는다.

```text
Worker Thread
순수 데이터 계산
↓
Main Thread
Unity Object에 결과 적용
```

병렬화할 계산 데이터와 Main Thread에서 적용할 Engine 상태를 분리해야 한다.

---

## 코드 예제

여러 Unit의 Threat Score를 계산한다고 가정한다.

```cs
public static float CalculateThreat(UnitData unit)
{
    return unit.Attack * 1.5f
        + unit.Defense * 0.8f
        + unit.DistanceWeight;
}
```

순차 실행은 한 Thread가 모든 요소를 처리한다.

```cs
public static void CalculateSequential(
    UnitData[] units,
    float[] results)
{
    for (int i = 0; i < units.Length; i++)
    {
        results[i] = CalculateThreat(units[i]);
    }
}
```

### Parallel.For 사용

각 요소 계산이 서로 독립적이라면 병렬 반복을 사용할 수 있다.

```cs
public static void CalculateParallel(
    UnitData[] units,
    float[] results)
{
    Parallel.For(
        0,
        units.Length,
        i =>
        {
            results[i] = CalculateThreat(units[i]);
        });
}
```

각 반복은 다른 Index의 결과만 쓴다.

```text
Worker 1: result[0..249]
Worker 2: result[250..499]
Worker 3: result[500..749]
Worker 4: result[750..999]
```

실제 분할 방식은 Runtime Scheduler가 결정할 수 있다.

### 공유 합계의 Race Condition

다음 코드는 여러 Worker가 같은 변수에 동시에 접근한다.

```cs
float total = 0f;

Parallel.ForEach(units, unit =>
{
    total += CalculateThreat(unit);
});
```

`+=`는 하나의 분리 불가능한 작업이라고 보장되지 않는다.

```text
total 읽기
↓
값 더하기
↓
total 쓰기
```

두 Thread의 갱신이 겹치면 한 결과가 사라질 수 있다.

각 Worker가 지역 합계를 계산하고 마지막에 합치는 Reduction 구조를 사용할 수 있다.

```cs
object gate = new();
double total = 0d;

Parallel.ForEach(
    units,
    () => 0d,
    (unit, state, localTotal) =>
        localTotal + CalculateThreat(unit),
    localTotal =>
    {
        lock (gate)
        {
            total += localTotal;
        }
    });
```

요소마다 Lock을 잡지 않고 Worker의 지역 결과를 마지막에 한 번 합친다.

### Unity 데이터 Snapshot

Worker에서 Transform에 접근하지 않고 Main Thread에서 필요한 값을 복사한다.

```cs
public readonly record struct UnitSnapshot(
    Vector3 Position,
    float Attack,
    float Defense);
```

```cs
private UnitSnapshot[] CaptureUnits()
{
    UnitSnapshot[] snapshots =
        new UnitSnapshot[units.Count];

    for (int i = 0; i < units.Count; i++)
    {
        Unit unit = units[i];

        snapshots[i] = new UnitSnapshot(
            unit.transform.position,
            unit.Attack,
            unit.Defense);
    }

    return snapshots;
}
```

```cs
public async Task<float[]> CalculateAsync()
{
    UnitSnapshot[] snapshots = CaptureUnits();

    float[] results = await Task.Run(() =>
    {
        float[] values = new float[snapshots.Length];

        Parallel.For(
            0,
            snapshots.Length,
            i => values[i] = Calculate(snapshots[i]));

        return values;
    });

    return results;
}
```

결과를 실제 Unity Object에 반영하는 코드는 Main Thread에서 실행되어야 한다. `await` 이후 실행 위치는 사용한 Async 환경과 Synchronization Context에 따라 달라질 수 있으므로 Main Thread 복귀를 명시적으로 보장하는 구조가 필요하다.

### 작은 작업은 순차 실행한다

```cs
public static int AddFourValues(int[] values)
{
    return values[0] + values[1]
        + values[2] + values[3];
}
```

이 정도 작업은 Worker에 전달하고 완료를 기다리는 비용이 계산보다 클 가능성이 높다.

---

## 내부 동작

### 작업 분할

병렬 실행에는 원래 계산 외의 단계가 추가된다.

```text
입력 준비
↓
작업을 Chunk로 분할
↓
Worker에 Scheduling
↓
여러 Core에서 실행
↓
결과 동기화
↓
결과 병합
```

계산량이 작으면 이 Overhead 때문에 순차 실행보다 느릴 수 있다.

### Context Switch

실행 가능한 Thread가 CPU의 Logical Core보다 많으면 운영체제는 Thread를 번갈아 실행한다.

```text
Thread A 상태 저장
↓
Thread B 상태 복원
↓
Thread B 실행
```

Context Switch에는 Scheduler 작업과 CPU Cache 영향이 따른다. Thread 수를 무작정 늘린다고 Core가 늘어나는 것은 아니다.

### Shared State와 Cache

여러 Core가 같은 메모리를 수정하면 동기화뿐 아니라 CPU Cache 일관성 비용이 생긴다.

```cs
sharedCounter++;
```

Lock으로 데이터 정확성을 보장해도 경쟁이 심하면 Worker가 대기해 병렬 이점이 사라질 수 있다.

```text
독립 입력
독립 출력
마지막에 결과 결합
```

공유 쓰기를 최소화하는 구조가 병렬화에 유리하다.

### Race Condition

실행 순서에 따라 결과가 달라지는 문제가 Race Condition이다.

```text
Thread A가 값 10 읽음
Thread B가 값 10 읽음
Thread A가 11 저장
Thread B가 11 저장

기대 결과 12
실제 결과 11
```

실행할 때마다 재현되지 않을 수 있어 일반 버그보다 찾기 어렵다.

### Memory Visibility

한 Thread가 값을 변경했다고 다른 Thread가 원하는 시점에 같은 값을 관찰한다고 단순히 가정할 수 없다.

Lock, `Interlocked`, `Volatile`과 Concurrent Collection 같은 동기화 수단은 Atomicity와 Memory Ordering을 제공하는 목적이 다르다.

특정 키워드 하나를 붙이는 것으로 모든 Thread Safety가 해결되지는 않는다.

### Amdahl의 법칙

전체 작업 중 병렬화할 수 없는 부분이 있으면 Core 수를 늘려도 속도 향상에 한계가 있다.

```text
전체 10ms

Main Thread 전용 4ms
병렬 가능 계산 6ms
```

병렬 가능 6ms가 이상적으로 4배 빨라져도 전체는 약 5.5ms다.

```text
4ms + 6ms / 4 = 5.5ms
```

실제로는 Scheduling과 동기화 비용도 포함된다.

---

## 실제 Unity에서는?

### Unity API와 순수 계산을 분리한다

다음 작업은 Worker로 옮기기 쉬운 편이다.

```text
대량 수치 계산
Grid Pathfinding
절차적 데이터 생성
압축과 변환
독립적인 AI 평가
```

다음 작업은 대부분 Main Thread 경계를 고려해야 한다.

```text
GameObject 생성과 파괴
Transform 변경
Component 접근
Scene과 대부분의 Asset API
Rendering 상태 변경
```

Engine API 호출과 계산을 한 메서드에 섞으면 병렬화하기 어렵다.

### Job System과 Burst

Unity는 일반 Task 외에도 Job System과 Burst Compiler를 제공한다.

```text
Task / Thread Pool
└─ 일반 C# 작업과 비동기 흐름

Job System
└─ Unity가 Worker Scheduling과 의존성 관리

Burst
└─ 지원되는 Job 코드를 최적화된 Native Code로 컴파일
```

대량의 동일 계산을 Data Oriented 구조로 처리한다면 Job System과 Burst가 더 적합할 수 있다.

### Frame을 기다리지 않게 한다

Worker 작업을 시작한 직후 Main Thread가 바로 기다리면 병렬 이점이 작아진다.

```cs
Task<float[]> task = CalculateAsync();
float[] result = task.Result;
```

`.Result`나 `.Wait()`는 Main Thread를 Block하고 상황에 따라 Deadlock 위험도 만든다.

```text
Frame N
입력 Snapshot → Worker 시작

Frame N 동안
Main Thread의 다른 작업 진행

Frame N 또는 N+1
완료 결과 적용
```

결과가 한 Frame 늦어도 되는 시스템인지 설계해야 한다.

### Worker 수를 직접 Core 수에 맞추지 않는다

Task Scheduler와 Unity Job System이 Worker를 관리한다. 자신의 시스템마다 Processor Count만큼 Thread를 만들면 Audio, Rendering, Job Worker와 운영체제 Thread가 모두 경쟁할 수 있다.

Target Device의 Core 구성과 다른 시스템의 부하를 포함해 Profiler로 확인한다.

### Development Build에서 Thread를 확인한다

Profiler Timeline에서 Main Thread와 Worker Thread의 실행 구간을 함께 본다.

```text
Worker가 실제로 동시에 실행되는가?
Main Thread가 완료를 기다리고 있는가?
Lock 대기가 긴가?
Scheduling 비용이 계산보다 큰가?
```

Editor에는 추가 Thread와 도구 비용이 있으므로 실제 Target Player에서 검증한다.

### 플랫폼 제약을 확인한다

지원하는 Thread 기능과 성능 특성은 Build Target에 따라 다를 수 있다. 모바일의 성능 Core와 효율 Core, Web 플랫폼, Console의 Job Worker 설정은 Desktop과 같은 결과를 보장하지 않는다.

병렬 코드가 동작한다는 사실과 해당 플랫폼에서 더 빠르다는 사실을 구분해야 한다.

---

## 실무에서 자주 하는 오해

### 비동기와 병렬은 같은 개념이다

Async는 대기 중 호출 흐름을 Block하지 않는 것이 목적일 수 있다. 여러 Core에서 동시에 계산한다는 뜻은 아니다.

### Task를 만들면 항상 새 Thread가 생긴다

Task는 작업의 완료와 결과를 표현한다. 실행 방법에 따라 Thread Pool을 사용하거나 현재 Context에서 진행될 수 있다.

### Core가 8개면 코드는 8배 빨라진다

병렬화할 수 없는 부분, Scheduling, 동기화, Memory Bandwidth와 Cache 비용 때문에 이상적인 배율이 나오지 않는다.

### Thread를 많이 만들수록 빠르다

Core보다 많은 CPU Bound Thread는 Context Switch와 Cache 경쟁을 늘릴 수 있다. Unity의 다른 Worker와도 CPU를 공유한다.

### Lock을 사용하면 Thread Safe하면서 빠르다

정확성은 보장할 수 있지만 경쟁이 심하면 Worker가 직렬로 대기한다. 공유 쓰기를 줄이는 데이터 구조가 먼저다.

### Worker Thread에서 Unity API도 호출할 수 있다

대부분의 UnityEngine Object API는 Main Thread 전용이다. Worker에서는 순수 데이터를 계산하고 결과 적용은 Main Thread에서 수행한다.

### 작은 작업도 모두 병렬화해야 한다

Scheduling과 결과 동기화 비용이 계산보다 크면 더 느려진다. 충분한 작업량과 독립성이 있는지 측정해야 한다.

### 병렬 실행 결과는 순차 실행과 항상 같다

공유 상태와 실행 순서에 의존하면 Race Condition이 발생한다. Floating Point 합계도 결합 순서가 달라져 작은 결과 차이가 생길 수 있다.

---

## 마무리

병렬 프로그래밍은 여러 Core에 코드를 나누어 전체 작업 시간을 줄일 가능성을 만든다.

하지만 모든 작업이 병렬화 가능한 것은 아니며 분할과 동기화도 새로운 비용이다.

```text
CPU Bound 작업인가?
↓
요소별 계산이 독립적인가?
↓
작업량이 Scheduling 비용보다 큰가?
↓
Unity Object 접근을 분리할 수 있는가?
↓
결과를 언제 Main Thread에 적용할 것인가?
↓
대상 플랫폼에서 실제 속도 비교
```

병렬화에 적합한 코드는 입력과 출력이 명확하고 공유 상태가 적다. Worker는 순수 데이터를 계산하고 Main Thread는 Unity Engine 상태를 적용하는 경계를 만들면 Thread Safety와 실행 흐름을 관리하기 쉽다.

병렬 API를 선택하기 전에 작업 구조를 바꾸는 것이 먼저다. 독립적인 데이터 단위로 나눌 수 없는 코드는 Worker 수를 늘려도 Lock 대기와 순서 문제만 커질 수 있다.

---

## 핵심 정리

- 동시성은 여러 작업이 같은 시간 구간에 진행되는 구조이고 병렬성은 여러 작업이 실제로 동시에 실행되는 구조다.
- CPU Bound 계산은 여러 Core 활용을 검토하고 I/O Bound 작업은 비동기 대기 구조를 우선 검토한다.
- Task는 작업의 완료와 결과를 표현하며 Task 하나가 항상 새 Thread 하나를 뜻하지는 않는다.
- 병렬 실행에는 작업 분할, Scheduling, 동기화와 결과 병합 비용이 추가된다.
- 여러 Worker가 같은 데이터를 수정하면 Race Condition과 Lock 경쟁이 생길 수 있다.
- 공유 쓰기보다 독립 입력과 독립 출력 후 결과를 합치는 구조가 병렬화에 유리하다.
- 대부분의 UnityEngine Object API는 Main Thread에서 사용하고 Worker에서는 순수 데이터를 계산한다.
- 작은 작업은 Scheduling 비용 때문에 순차 실행보다 느려질 수 있다.
- Core 수만큼 성능이 증가하지 않으며 병렬화할 수 없는 구간이 전체 속도 향상을 제한한다.
- 병렬화 전후를 실제 Target Player의 Main Thread와 Worker Timeline에서 비교해야 한다.
