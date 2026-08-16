---
title: "[궁금시리즈] 11-6. Unity Job System과 Burst는 어떻게 병렬 처리할까?"
excerpt: "C#"
categories:
  - CSharp
series: question-series
tags:
  - CSharp
permalink: /programming/11-6-unity-job-system-burst/
toc: true
toc_sticky: true
date: 2026-08-16 12:00:36 +0900
last_modified_at: 2026-08-16 12:00:36 +0900
---

## 들어가며

일반 C#의 `Task.Run()`과 `Parallel.For()`로도 여러 Core에서 계산할 수 있다.

```cs
Parallel.For(0, inputs.Length, i =>
{
    outputs[i] = Calculate(inputs[i]);
});
```

Unity에는 게임의 대량 계산을 위한 별도의 Job System이 있다.

```cs
[BurstCompile]
public struct MoveJob : IJobParallelFor
{
    [ReadOnly]
    public NativeArray<float3> Velocities;

    public NativeArray<float3> Positions;

    public float DeltaTime;

    public void Execute(int index)
    {
        Positions[index] +=
            Velocities[index] * DeltaTime;
    }
}
```

Job System은 작업을 Unity의 Worker Thread에 Scheduling하고 `JobHandle`로 실행 순서와 데이터 의존성을 표현한다.

Burst Compiler는 지원되는 C# 코드를 Target CPU에 최적화된 Native Code로 컴파일한다.

```text
Job System
└─ 언제, 어떤 Worker에서, 어떤 순서로 실행할지 관리

Burst Compiler
└─ Job 내부 계산 코드를 어떻게 빠른 Native Code로 만들지 담당
```

Job을 만들었다고 자동으로 빨라지는 것도 아니고 `[BurstCompile]`을 붙였다고 모든 C# 코드가 Burst로 변환되는 것도 아니다.

데이터를 NativeContainer로 구성하고, 읽기와 쓰기 관계를 Dependency로 표현하며, Main Thread가 실제로 기다리지 않는 Pipeline을 만들어야 한다.

---

## 개념 설명

### Job

Unity에서 Job은 특정 작업을 수행하는 작은 단위다. 일반적으로 struct로 만들고 Job Interface를 구현한다.

```cs
public struct SumJob : IJob
{
    [ReadOnly]
    public NativeArray<float> Values;

    public NativeArray<float> Result;

    public void Execute()
    {
        float sum = 0f;

        for (int i = 0; i < Values.Length; i++)
        {
            sum += Values[i];
        }

        Result[0] = sum;
    }
}
```

`IJob.Execute()`는 한 번 실행된다. 다른 Job과 병렬로 실행될 수 있지만 Job 내부 반복 하나가 자동으로 여러 Worker에 나뉘는 것은 아니다.

### IJobParallelFor

동일한 계산을 여러 요소에 독립적으로 적용할 때 사용한다.

```cs
public struct SquareJob : IJobParallelFor
{
    [ReadOnly]
    public NativeArray<float> Inputs;

    [WriteOnly]
    public NativeArray<float> Outputs;

    public void Execute(int index)
    {
        float value = Inputs[index];
        Outputs[index] = value * value;
    }
}
```

각 Index의 `Execute()`는 여러 Batch로 나뉘어 Worker가 처리한다.

### NativeContainer

Burst는 일반 Managed Object를 지원하지 않는다. Job은 주로 Native Memory를 안전하게 다루는 NativeContainer를 사용한다.

```text
NativeArray<T>
NativeList<T>
NativeHashMap<TKey, TValue>
NativeQueue<T>
```

사용 가능한 Container는 Unity Collections Package 버전에 따라 달라진다.

NativeContainer는 GC가 자동 회수하는 일반 배열이 아니므로 Allocator 수명에 맞춰 `Dispose()`해야 한다.

### JobHandle

`Schedule()`은 Job 실행을 나타내는 `JobHandle`을 반환한다.

```cs
JobHandle handle = job.Schedule();
```

Handle은 다음 용도로 사용한다.

```text
Job 완료 확인
Main Thread에서 Complete
다음 Job의 Dependency로 전달
여러 Dependency 결합
```

### Burst Compiler

Burst는 High-Performance C#이라는 지원 가능한 C# 부분집합을 LLVM 기반으로 최적화된 Native Code로 변환한다.

```cs
[BurstCompile]
public struct CalculateJob : IJobParallelFor
{
}
```

Burst는 Job System을 대체하지 않고 Mono나 IL2CPP Scripting Backend를 완전히 대체하지도 않는다. Burst 호환 대상으로 표시된 코드만 추가로 컴파일한다.

---

## 코드 예제

여러 Unit의 위치를 계산하는 Job을 만든다.

```cs
using Unity.Burst;
using Unity.Collections;
using Unity.Jobs;
using Unity.Mathematics;

[BurstCompile]
public struct MoveUnitsJob : IJobParallelFor
{
    [ReadOnly]
    public NativeArray<float3> Velocities;

    public NativeArray<float3> Positions;

    public float DeltaTime;

    public void Execute(int index)
    {
        Positions[index] +=
            Velocities[index] * DeltaTime;
    }
}
```

### NativeArray 준비

```cs
private NativeArray<float3> positions;
private NativeArray<float3> velocities;

private void Awake()
{
    positions = new NativeArray<float3>(
        unitCount,
        Allocator.Persistent);

    velocities = new NativeArray<float3>(
        unitCount,
        Allocator.Persistent);
}
```

`Persistent`는 여러 Frame 동안 유지하는 데이터에 사용할 수 있지만 명시적으로 해제해야 한다.

```cs
private void OnDestroy()
{
    moveHandle.Complete();

    if (positions.IsCreated)
    {
        positions.Dispose();
    }

    if (velocities.IsCreated)
    {
        velocities.Dispose();
    }
}
```

Job이 NativeArray를 사용 중일 수 있으므로 Dispose 전에 관련 Handle을 완료한다.

### Schedule

```cs
MoveUnitsJob job = new()
{
    Positions = positions,
    Velocities = velocities,
    DeltaTime = Time.deltaTime
};

moveHandle = job.Schedule(
    positions.Length,
    innerloopBatchCount: 64);
```

첫 번째 인수는 실행할 Index 수이고 두 번째 인수는 Worker가 한 번에 가져갈 최소 작업 묶음과 관련된다.

Batch가 너무 작으면 Work Stealing과 Scheduling 비용이 커질 수 있다. 너무 크면 Worker 사이의 부하 균형이 나빠질 수 있다.

### Schedule 직후 Complete

```cs
moveHandle = job.Schedule(
    positions.Length,
    64);

moveHandle.Complete();

ApplyPositions();
```

정확하게 동작하지만 Main Thread가 즉시 완료를 기다린다.

```text
Schedule
↓
Main Thread가 Complete에서 대기
↓
Worker 계산
↓
Main Thread 재개
```

Worker가 실행하는 동안 Main Thread에서 수행할 다른 작업이 없다면 병렬 Pipeline의 이점을 충분히 사용하지 못한다.

### 한 Frame Pipeline

Frame N에서 Schedule하고 Frame N+1에서 결과를 사용할 수 있다.

```cs
private JobHandle moveHandle;
private bool hasScheduledJob;

private void Update()
{
    if (hasScheduledJob)
    {
        moveHandle.Complete();
        ApplyPositionsToTransforms();
    }

    CaptureCurrentInputs();
    ScheduleMoveJob();
    hasScheduledJob = true;
}
```

Job 계산과 다음 Frame 사이의 Main Thread 작업이 겹칠 여지가 생긴다. 결과가 한 Frame 늦어도 되는 시스템인지 먼저 결정해야 한다.

### Job Dependency

위치를 계산한 뒤 경계를 제한하는 Job이 이어진다고 가정한다.

```cs
[BurstCompile]
public struct ClampPositionsJob : IJobParallelFor
{
    public NativeArray<float3> Positions;
    public float3 Min;
    public float3 Max;

    public void Execute(int index)
    {
        Positions[index] = math.clamp(
            Positions[index],
            Min,
            Max);
    }
}
```

```cs
JobHandle moveHandle = moveJob.Schedule(
    positions.Length,
    64);

JobHandle clampHandle = clampJob.Schedule(
    positions.Length,
    64,
    moveHandle);
```

두 Job이 같은 `Positions`를 쓰므로 순서를 Dependency로 표현한다.

```text
Move Job 완료
↓
Clamp Job 시작
```

### 독립 Job 결합

서로 다른 데이터를 처리하는 Job은 독립적으로 Schedule하고 다음 Job 전에 Dependency를 결합할 수 있다.

```cs
JobHandle movementHandle = movementJob.Schedule();
JobHandle animationHandle = animationJob.Schedule();

JobHandle combined = JobHandle.CombineDependencies(
    movementHandle,
    animationHandle);

JobHandle finalHandle = finalJob.Schedule(combined);
```

필요 없는 Dependency까지 연결하면 병렬로 실행할 수 있는 Job을 직렬화한다.

### NativeArray 값을 수정하는 방식

NativeContainer가 `ref return`을 제공하지 않는 경우 구조체 요소의 Field만 직접 바꾸는 표현이 기대와 다르게 동작할 수 있다.

```cs
UnitState state = states[index];
state.Health -= damage;
states[index] = state;
```

값을 지역 변수로 복사하고 수정한 뒤 다시 저장한다.

---

## 내부 동작

### Job Data 복사

Job struct를 Schedule하면 Job System은 실행에 필요한 Job Data를 복사한다.

```text
Main Thread의 Job struct
↓ Schedule
Job Queue용 Data 복사
↓
Worker가 Execute
```

Job의 일반 Value Field를 Worker가 바꿔도 Main Thread의 원본 struct Field로 결과가 돌아오지 않는다. 결과는 같은 Native Memory를 가리키는 NativeContainer에 기록한다.

### Safety System

NativeContainer는 어떤 Job이 읽고 쓰는지 추적한다.

```text
Job A: NativeArray 쓰기
Job B: 같은 NativeArray 쓰기
Dependency 없음
└─ 안전하지 않은 Schedule로 판단
```

동일 데이터를 읽는 여러 Job은 함께 실행할 수 있지만 쓰기와 읽기 또는 두 쓰기가 겹치면 Dependency가 필요하다.

`[ReadOnly]`와 `[WriteOnly]` Attribute는 접근 의도를 Safety System과 Compiler에 전달한다.

### 소유권 반환

Job이 NativeContainer를 사용 중일 때 Main Thread는 안전하게 접근할 수 없다.

```text
Schedule 전
Main Thread가 Container 소유

Schedule 후
Job이 사용 중

Complete 후
Main Thread가 다시 안전하게 접근
```

`IsCompleted`가 true인지 확인한 것만으로 안전 상태 정리가 모두 끝나는 것은 아니다. 데이터를 읽기 전에 `Complete()`를 호출해야 한다.

### Work Stealing과 Batch

`IJobParallelFor`의 Index는 Batch로 나뉜다.

```text
Worker A: Batch 0
Worker B: Batch 1
Worker C: Batch 2
Worker D: Batch 3
```

먼저 끝난 Worker는 다른 Worker의 남은 Batch를 가져올 수 있다.

Batch Size는 Scheduling Overhead와 Load Balancing의 교환이다.

### Burst 최적화

Burst는 지원되는 IL을 Target CPU에 맞는 Native Code로 변환한다.

```text
C# Job
↓ IL
Burst Compiler
↓
Target CPU Native Code
```

Vectorization, Inlining과 불필요한 계산 제거 같은 최적화가 적용될 수 있다.

Burst가 SIMD 명령을 만들기 쉬운 형태는 연속 데이터에 같은 연산을 적용하는 구조다.

```text
Object마다 복잡한 Virtual 호출
보다
연속된 float 배열 순회
```

### Managed Object 제한

Burst Code에서는 일반 Class, String, Managed Array와 Managed Delegate를 사용할 수 없다.

```cs
public List<Enemy> Enemies; // Burst Job Data로 부적합
```

NativeContainer와 Blittable 또는 Unmanaged Data 중심으로 구조를 바꿔야 한다.

Static Mutable Data에 Job에서 접근하면 Safety System을 우회할 수 있어 Crash와 비결정적 결과를 만들 수 있다.

---

## 실제 Unity에서는?

### Job을 너무 작게 나누지 않는다

```cs
for (int i = 0; i < units.Length; i++)
{
    SingleUnitJob job = new()
    {
        Unit = units[i]
    };

    job.Schedule();
}
```

요소마다 Job을 Schedule하면 Scheduling 비용이 커진다. `IJobParallelFor` 하나에서 Index별로 처리하는 편이 적합할 수 있다.

### 긴 Job이 Worker를 독점하지 않게 한다

실행 시간이 매우 긴 `IJobParallelFor`가 많은 Worker를 점유하면 다른 Unity Job의 실행이 지연될 수 있다.

```text
자신의 긴 Parallel Job
↓
Animation / Physics / Engine Job 대기
↓
Main Thread가 중요 Job Complete에서 정지
```

작업을 Frame 단위로 나누거나 Batch Size와 Scheduling 구조를 조정한다. 자신의 Job 시간만 줄었다고 전체 Frame이 개선된 것은 아니다.

### Complete는 가능한 늦게 호출한다

```text
Update 초반 Schedule
↓
Main Thread의 독립 작업 수행
↓
결과가 필요한 직전 Complete
```

Schedule 직후 Complete보다 Main Thread와 Worker가 겹쳐 실행될 시간이 늘어난다.

Profiler의 `WaitForJobGroup` 같은 대기 Sample이 길다면 Main Thread가 Job을 너무 빨리 기다리는지 확인한다.

### Persistent NativeContainer를 재사용한다

매 Frame 같은 크기의 NativeArray를 생성하고 Dispose하면 Native Allocation 관리 비용이 반복된다.

```cs
private NativeArray<UnitInput> inputs;
private NativeArray<UnitResult> outputs;
```

최대 사용량과 수명을 알 수 있다면 Persistent Container를 재사용한다. 크기 변경, Scene 종료와 Domain Reload 시 Dispose 책임도 함께 가져야 한다.

### Allocator 수명을 지킨다

```text
Allocator.Temp
└─ 매우 짧은 수명

Allocator.TempJob
└─ 짧은 Job 수명

Allocator.Persistent
└─ 장기 유지, 명시적 Dispose
```

정확한 허용 기간과 검사 동작은 Unity 버전 및 Container에 따라 문서를 확인한다. 이름만 보고 수명을 임의로 늘리지 않는다.

### Burst Inspector로 확인한다

`[BurstCompile]`을 붙였다는 사실만으로 기대한 Vectorization이 적용됐다고 단정하지 않는다.

Burst Inspector와 Profiler로 다음 항목을 확인한다.

```text
실제로 Burst Compile되었는가?
Managed 호출 때문에 Compile이 제외되지 않았는가?
Vectorized Code가 생성되었는가?
Safety Check On / Off 차이는 무엇인가?
Player AOT Build에서도 같은가?
```

### Editor와 Player Compilation 차이

Burst는 Editor Play Mode에서 JIT 방식으로 Compile할 수 있고 Player Build에서는 AOT Compile한다.

Editor의 첫 실행에는 Burst Compilation 시간이 섞일 수 있다. Warm-up 이후 실행과 Target Player Profile을 구분한다.

### Job System을 모든 코드에 사용하지 않는다

Managed Object Graph, String 처리, Unity Object API와 복잡한 예외 흐름이 중심인 작업은 Job으로 옮기기 위해 드는 데이터 변환 비용이 더 클 수 있다.

Job System은 대량의 독립적인 수치 계산과 연속 데이터 처리에 특히 적합하다.

---

## 실무에서 자주 하는 오해

### IJob을 사용하면 Job 내부도 여러 Core에서 실행된다

`IJob.Execute()`는 한 번 실행된다. 여러 요소를 병렬 처리하려면 `IJobParallelFor` 같은 병렬 Job Type이나 여러 독립 Job을 사용한다.

### Schedule을 호출하면 즉시 Worker가 실행한다

Job Queue와 Dependency 상태에 따라 시작 시점이 결정된다. Main Thread에서 Schedule 호출이 끝났다는 사실은 Job 완료를 뜻하지 않는다.

### IsCompleted가 true면 NativeArray를 바로 읽어도 된다

Main Thread에서 데이터를 안전하게 다시 사용하고 Safety State를 정리하려면 `Complete()`를 호출해야 한다.

### Schedule 직후 Complete해도 완전한 비동기 처리다

Main Thread가 즉시 결과를 기다리므로 다른 작업과 겹쳐 실행할 기회가 줄어든다. 결과가 필요한 시점까지 Complete를 늦춘다.

### Job System과 Burst는 같은 기능이다

Job System은 Scheduling과 Dependency를 담당하고 Burst는 지원되는 계산 코드를 Native Code로 최적화한다. 각각 독립적으로 적용될 수 있다.

### BurstCompile을 붙이면 모든 C# 코드를 사용할 수 있다

Burst는 Managed Object를 지원하지 않는 HPC# 부분집합을 사용한다. String, 일반 Class와 Managed Collection 중심 코드는 그대로 Compile할 수 없다.

### NativeContainer는 이름 그대로 자동으로 Thread Safe하다

Safety System은 충돌을 감지하고 Dependency를 요구한다. 여러 Job이 같은 Index에 동시에 쓰는 알고리즘을 자동으로 올바르게 만들지는 않는다.

### Safety Attribute를 끄면 최적화가 된다

Restriction을 비활성화하면 개발자가 충돌 없는 접근을 직접 증명해야 한다. 잘못 사용하면 Race와 Memory Corruption을 만들 수 있다.

### Batch Size는 작을수록 Core를 잘 활용한다

Load Balancing은 좋아질 수 있지만 Scheduling과 Work Stealing 비용이 늘어난다. 요소 계산량과 Worker 경쟁을 기준으로 측정한다.

### Job 자체가 빠르면 게임도 빨라진다

데이터 복사, Schedule, Complete 대기, NativeContainer 관리와 결과 적용까지 포함한 전체 Frame을 비교해야 한다.

---

## 마무리

Unity Job System은 작업을 Worker Thread에 Scheduling하고 `JobHandle` Dependency로 실행 순서와 데이터 소유권을 관리한다.

Burst Compiler는 Job의 지원 가능한 C# 계산을 Target CPU에 최적화된 Native Code로 변환한다.

```text
Main Thread에서 입력 준비
↓
NativeContainer에 연속 데이터 저장
↓
Job Schedule과 Dependency 연결
↓
Main Thread의 독립 작업 진행
↓
결과가 필요한 직전에 Complete
↓
Main Thread에서 Unity Object에 적용
```

성능을 얻으려면 다음 조건이 필요하다.

```text
작업량이 Scheduling 비용보다 충분히 큰가?
요소별 읽기와 쓰기가 독립적인가?
Managed Object 없이 데이터화할 수 있는가?
Main Thread와 Worker 실행을 겹칠 수 있는가?
다른 Unity Job을 과도하게 방해하지 않는가?
```

Job과 Burst의 핵심은 Thread 문법이 아니라 데이터 구조다. 연속된 Native Data에 동일한 계산을 적용하고 의존성을 명시하면 Unity가 여러 Core와 CPU 최적화를 활용하기 쉬워진다.

---

## 핵심 정리

- `IJob`은 한 번 실행되는 작업 단위이고 `IJobParallelFor`는 Index별 작업을 여러 Worker에 나눌 수 있다.
- Job System은 Scheduling과 Dependency를 담당하고 Burst는 지원 코드를 Native Code로 최적화한다.
- Job은 Managed Object 대신 NativeContainer와 Unmanaged Data 중심으로 구성한다.
- `Schedule()`은 JobHandle을 반환하며 Job이 즉시 완료되었다는 뜻이 아니다.
- 실행 중인 Job이 사용하는 NativeContainer는 Main Thread에서 접근하지 않는다.
- 데이터를 읽거나 Dispose하기 전에 `Complete()`로 소유권과 Safety State를 정리해야 한다.
- 같은 데이터를 쓰는 Job은 `JobHandle` Dependency로 실행 순서를 표현한다.
- `Complete()`는 Schedule 직후가 아니라 결과가 필요한 시점까지 가능한 늦게 호출한다.
- Batch Size는 Scheduling Overhead와 Worker Load Balancing 사이의 교환이다.
- NativeContainer 준비, Job 실행, 대기와 결과 적용을 포함한 전체 Frame을 Target Player에서 측정해야 한다.
