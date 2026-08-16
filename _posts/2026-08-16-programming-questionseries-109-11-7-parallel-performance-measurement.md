---
title: "[궁금시리즈] 11-7. 병렬 처리 성능은 어떻게 측정해야 할까?"
excerpt: "C#"
categories:
  - CSharp
series: question-series
tags:
  - CSharp
permalink: /programming/11-7-parallel-performance-measurement/
toc: true
toc_sticky: true
date: 2026-08-16 12:00:37 +0900
last_modified_at: 2026-08-16 12:00:37 +0900
---

## 들어가며

순차 계산이 8ms이고 병렬 계산이 3ms라면 병렬 버전이 더 빠르다고 말할 수 있다.

하지만 어떤 3ms를 측정했는지 확인해야 한다.

```text
Job Schedule 호출 시간 0.1ms
Worker 실행 시간 2.5ms
Main Thread Complete 대기 1.0ms
결과 적용 1.5ms
입력 복사 0.8ms
```

`Schedule()` 호출만 측정하면 실제 계산과 대기 비용이 빠진다.

여러 Core가 동시에 일하면 작업 완료까지의 시간은 줄어도 모든 Core가 사용한 CPU 시간의 합계는 늘 수 있다.

```text
순차
1 Core × 8ms = 총 CPU 약 8ms

병렬
4 Core × 3ms = 총 CPU 최대 약 12ms
```

게임에서는 해당 계산만 빨라지는 것으로 끝나지 않는다. 병렬 작업이 Main Thread, Render Thread, Physics, Audio와 Unity Job Worker가 사용할 CPU를 빼앗으면 전체 Frame은 오히려 느려질 수 있다.

병렬 성능 측정은 작업 자체의 완료 시간, 전체 CPU 사용량과 최종 Frame 안정성을 함께 비교해야 한다.

---

## 개념 설명

### Wall-clock Time

작업을 시작한 시점부터 결과를 사용할 수 있는 시점까지 실제로 흐른 시간이다.

```text
시작 10.000초
완료 10.004초
Wall-clock 4ms
```

사용자가 기다리는 시간과 가장 가까운 지표다.

### CPU Time

모든 Thread가 작업에 사용한 CPU 시간을 합친 값이다.

```text
Worker A 3ms
Worker B 3ms
Worker C 2ms
Worker D 2ms

총 CPU Time 약 10ms
Wall-clock Time 약 3ms
```

병렬화는 총 계산량을 줄이지 않아도 여러 Core에 겹쳐 실행해 Wall-clock을 줄일 수 있다.

### Speedup

순차 실행 시간과 병렬 실행 시간의 비율이다.

```text
Speedup = 순차 시간 / 병렬 시간
```

순차 12ms, 병렬 4ms라면 Speedup은 3이다.

```text
12 / 4 = 3
```

### Parallel Efficiency

사용한 Worker 수에 비해 얼마나 효율적으로 Speedup을 얻었는지 나타낸다.

```text
Efficiency = Speedup / Worker 수
```

4개 Worker로 Speedup 3을 얻었다면 단순 효율은 0.75다.

```text
3 / 4 = 0.75
```

실제 Scheduler가 정확히 몇 Worker를 얼마 동안 사용했는지에 따라 해석이 달라지므로 개념적인 비교 지표로 사용한다.

### Latency와 Throughput

```text
Latency
└─ 요청 하나가 완료되는 시간

Throughput
└─ 일정 시간 동안 처리한 요청 수
```

Batch로 여러 요청을 처리하면 전체 Throughput은 높아져도 개별 요청이 Batch를 기다려 Latency가 늘 수 있다.

게임 시스템이 한 Frame 안의 결과를 원하는지, 초당 많은 작업 처리가 필요한지에 따라 목표가 다르다.

### Frame Time

실시간 게임에서는 평균 작업 시간보다 최악 Frame Time이 중요할 수 있다.

```text
평균 5ms
99% Frame 7ms
최악 Frame 42ms
```

병렬화 후 평균은 줄었지만 Lock이나 `Complete()` 대기로 간헐적인 42ms Frame이 생기면 사용자 경험은 나빠질 수 있다.

---

## 코드 예제

### Stopwatch로 순수 계산 측정

```cs
public static TimeSpan MeasureSequential(
    Input[] inputs,
    Result[] outputs)
{
    Stopwatch stopwatch = Stopwatch.StartNew();

    CalculateSequential(inputs, outputs);

    stopwatch.Stop();
    return stopwatch.Elapsed;
}
```

```cs
public static TimeSpan MeasureParallel(
    Input[] inputs,
    Result[] outputs)
{
    Stopwatch stopwatch = Stopwatch.StartNew();

    CalculateParallel(inputs, outputs);

    stopwatch.Stop();
    return stopwatch.Elapsed;
}
```

`Stopwatch`는 코드 구간의 Wall-clock 비교에 사용할 수 있지만 Rendering, 다른 Thread와 Frame 전체의 관계는 Unity Profiler로 확인해야 한다.

### 결과 검증

빠른 코드가 같은 결과를 만들지 않으면 비교할 수 없다.

```cs
for (int i = 0; i < sequential.Length; i++)
{
    float difference = math.abs(
        sequential[i] - parallel[i]);

    if (difference > tolerance)
    {
        throw new InvalidOperationException(
            $"Result mismatch at {i}: {difference}");
    }
}
```

Floating Point 계산 순서가 바뀌면 작은 차이가 생길 수 있으므로 시스템 요구에 맞는 Tolerance를 사용한다.

### 여러 번 반복하고 분포 기록

```cs
List<double> samples = new(iterationCount);

for (int i = 0; i < iterationCount; i++)
{
    Stopwatch stopwatch = Stopwatch.StartNew();

    CalculateParallel(inputs, outputs);

    stopwatch.Stop();
    samples.Add(stopwatch.Elapsed.TotalMilliseconds);
}
```

첫 결과 하나만 사용하지 않는다.

```text
최솟값
중앙값
평균
95 Percentile
99 Percentile
최댓값
```

Outlier를 무조건 버리지 않는다. 실제 Gameplay에서도 발생할 수 있는 Scheduling과 Thermal 변화인지 확인한다.

### Warm-up

```cs
for (int i = 0; i < warmupCount; i++)
{
    CalculateParallel(inputs, outputs);
}
```

첫 실행에는 다음 비용이 섞일 수 있다.

```text
JIT 또는 Burst Editor Compilation
Thread Pool Worker 준비
Cache 초기화
Native Container 최초 할당
Page Fault
```

첫 실행 Latency가 실제 요구사항이라면 별도 지표로 기록하고, 안정 상태 성능은 Warm-up 뒤에 측정한다.

### 입력 크기별 측정

```cs
int[] sizes =
{
    100,
    1_000,
    10_000,
    100_000
};
```

입력마다 순차와 병렬 시간을 비교한다.

```text
100개
순차 0.02ms / 병렬 0.20ms

1,000개
순차 0.20ms / 병렬 0.25ms

10,000개
순차 2.0ms / 병렬 0.9ms

100,000개
순차 20ms / 병렬 6ms
```

병렬화가 이득을 내기 시작하는 Break-even Point를 찾는다.

```cs
if (inputs.Length < parallelThreshold)
{
    CalculateSequential(inputs, outputs);
}
else
{
    CalculateParallel(inputs, outputs);
}
```

Threshold는 개발 PC의 숫자를 고정하지 않고 Target Device별 결과로 결정한다.

### ProfilerMarker

```cs
private static readonly ProfilerMarker PrepareMarker =
    new("Path.PrepareInputs");

private static readonly ProfilerMarker ScheduleMarker =
    new("Path.ScheduleJobs");

private static readonly ProfilerMarker CompleteMarker =
    new("Path.CompleteJobs");

private static readonly ProfilerMarker ApplyMarker =
    new("Path.ApplyResults");
```

입력 준비, Scheduling, 대기와 결과 적용을 별도 Marker로 나눈다.

```cs
using (PrepareMarker.Auto())
{
    CaptureInputs();
}

using (ScheduleMarker.Auto())
{
    handle = job.Schedule();
}
```

`Complete()` 시간이 짧아도 Worker가 이미 이전 Frame에서 오래 계산했을 수 있다. Worker Timeline과 함께 본다.

### Job 측정 범위

잘못된 측정은 Schedule 호출만 잰다.

```cs
stopwatch.Start();
JobHandle handle = job.Schedule();
stopwatch.Stop();
```

올바른 목적에 따라 범위를 나눈다.

```text
Schedule Overhead
Worker Execute Time
Complete Wait Time
입력 Native Data 준비
결과 Unity Object 적용
전체 Pipeline Latency
```

---

## 내부 동작

### Amdahl의 법칙

전체 작업 중 순차 구간이 남으면 Worker를 늘려도 Speedup에 한계가 있다.

```text
입력 준비 2ms
병렬 계산 8ms
결과 적용 2ms
```

병렬 계산을 이상적으로 4배 줄여도 전체는 6ms다.

```text
2 + 8 / 4 + 2 = 6ms
```

12ms에서 6ms이므로 전체 Speedup은 2다.

### Scheduling Overhead

병렬 작업에는 순차 구현에 없던 비용이 붙는다.

```text
작업 객체 또는 Job Data 준비
Queue 삽입
Partitioning
Worker 깨우기
Dependency 확인
결과 병합
동기화
```

계산량이 작으면 이 고정 비용이 전체를 지배한다.

### Load Imbalance

Worker별 작업 시간이 다르면 가장 늦은 Worker가 전체 완료 시간을 결정한다.

```text
Worker A 2ms
Worker B 2ms
Worker C 2ms
Worker D 9ms

전체 완료 약 9ms 이상
```

평균 Worker 시간보다 마지막 작업의 Long Tail을 확인한다.

### Contention

공유 Lock, Atomic Counter와 같은 Cache Line 쓰기가 병렬 효율을 낮춘다.

```text
계산은 병렬
↓
결과 추가에서 하나의 Lock 대기
↓
실제로는 병합 구간이 직렬 병목
```

Worker별 결과와 Partition 단위 병합으로 공유 쓰기 횟수를 줄인다.

### Memory Bandwidth

단순 배열 복사나 큰 데이터를 연속으로 읽는 작업은 CPU 계산보다 Memory Bandwidth가 먼저 한계에 도달할 수 있다.

```text
Worker 2개까지 성능 향상
Worker 4개부터 차이 작음
Worker 8개에서 오히려 악화
```

Core 사용률이 낮다는 이유만으로 Worker를 더 늘리지 않는다.

### Cache Locality

연속된 작은 Chunk를 처리하면 CPU Cache에 유리할 수 있다.

```text
Structure of Arrays
Position 배열
Velocity 배열
```

객체 그래프를 무작위로 따라가는 작업은 Cache Miss가 많아 Worker를 늘려도 효율이 낮을 수 있다.

### Oversubscription

Runtime Thread Pool, Unity Job Worker와 Engine Thread가 Logical Core보다 많은 CPU Bound 작업을 동시에 실행하면 서로 경쟁한다.

```text
Task Parallel Worker
+ Unity Job Worker
+ Physics
+ Rendering
+ Audio
> 사용 가능한 Core
```

개별 Benchmark에서는 빠르지만 실제 Frame에서는 느려지는 원인이 된다.

---

## 실제 Unity에서는?

### Timeline에서 겹침을 확인한다

병렬 처리의 목적은 Worker 사용 자체가 아니라 Main Thread와 독립 작업을 겹치는 것이다.

```text
좋은 Pipeline
Main Thread: 입력 준비 → 다른 작업 → Complete → 적용
Worker:            Job 실행 ───────┘

즉시 대기 Pipeline
Main Thread: Schedule → Complete 대기 → 적용
Worker:              Job 실행 ────┘
```

Profiler Timeline에서 Worker Sample이 Main Thread의 독립 작업과 겹치는지 확인한다.

### Wait Sample을 본다

다음 Sample이 길다면 병렬 작업을 시작한 사실보다 기다리는 이유가 중요하다.

```text
WaitForJobGroup
Task.Wait 또는 Result
Monitor Lock 대기
Semaphore 대기
Thread.Join
```

Main Thread가 어디서 결과를 너무 일찍 요구하는지 찾는다.

### Burst Compilation과 실행을 구분한다

Editor 첫 실행에서 Burst Compile 시간이 발생할 수 있다.

```text
Cold Run
Compile + 실행

Warm Run
이미 Compile된 Code 실행

Player Build
AOT Compile된 Code 실행
```

Editor의 Cold Run을 Gameplay의 매 Frame 비용으로 해석하지 않는다. 반대로 첫 사용 Spike가 Editor Tool이나 Workflow에 중요하면 별도로 개선한다.

### Development Build의 Profiler Overhead

Development Build, Deep Profile, Call Stack과 Safety Check는 실행 비용을 바꾼다.

```text
진단 Build
└─ 병목 위치와 실행 흐름 확인

최종 조건에 가까운 Build
└─ 실제 성능 수치 확인
```

같은 설정끼리 비교하고 최종 결론은 Release 조건에 가까운 Build에서도 확인한다.

### Device Thermal 상태

모바일은 병렬 작업으로 모든 Core를 오래 사용하면 온도와 전력 제한으로 Clock이 내려갈 수 있다.

```text
첫 30초: 4ms
5분 후: 7ms
10분 후: 10ms
```

짧은 Benchmark뿐 아니라 실제 플레이 시간 동안 반복 측정한다. Battery와 발열도 성능 목표에 포함될 수 있다.

### 입력과 Scene 상태를 고정한다

```text
같은 Enemy 수
같은 Pathfinding Map
같은 Camera와 Render 부하
같은 Background App 상태
같은 Target Frame Rate
같은 Worker 설정
```

입력 데이터가 다르면 Algorithm의 분기와 Cache 패턴도 달라져 비교가 흔들린다.

### ProfilerRecorder로 자동 수집한다

긴 Session에서 특정 Counter를 기록하려면 `ProfilerRecorder`를 사용할 수 있다.

```cs
ProfilerRecorder mainThreadTime =
    ProfilerRecorder.StartNew(
        ProfilerCategory.Internal,
        "Main Thread",
        capacity: 300);
```

Counter 이름과 사용 가능 여부는 Unity 버전과 플랫폼에 따라 확인한다. 자동 수집 값도 측정 환경과 Marker 정의를 함께 기록해야 의미가 있다.

---

## 실무에서 자주 하는 오해

### 평균 FPS가 오르면 병렬화가 성공했다

최악 Frame, 99 Percentile, 발열과 다른 시스템의 CPU 시간을 함께 봐야 한다. 평균은 간헐적인 긴 Wait를 숨길 수 있다.

### Schedule 시간이 짧으면 Job이 빠르다

Schedule은 Queue에 작업을 넣는 시간이다. Worker 실행, Complete 대기와 결과 적용은 별도다.

### CPU 사용률이 높을수록 최적화가 잘됐다

필요한 결과를 더 빨리 만들었다면 의미가 있지만 불필요한 Busy Work와 경쟁으로 사용률만 높을 수도 있다.

### Speedup이 4면 CPU도 4배 효율적이다

Wall-clock Speedup과 총 CPU 사용량은 다르다. 여러 Core가 사용한 시간의 합은 순차 버전보다 커질 수 있다.

### Worker 수는 많을수록 좋다

Scheduling, Context Switch, Cache와 Memory Bandwidth 경쟁이 증가한다. Unity의 다른 Thread가 사용할 Core도 필요하다.

### 한 번 가장 빠른 결과가 실제 성능이다

우연히 유리한 Scheduling 결과일 수 있다. 여러 Sample의 중앙값과 Tail을 함께 본다.

### Warm-up 결과만 보면 충분하다

안정 상태 성능에는 유용하지만 첫 실행 Latency가 사용자 경험에 포함되면 Cold Run도 별도로 측정해야 한다.

### Editor Profiler 수치가 Target Player 성능이다

Editor와 Profiling 도구의 Overhead, Burst JIT와 플랫폼 Core 구성이 다르다. 실제 기기 Player에서 비교해야 한다.

### 결과가 조금 다르면 병렬화는 실패다

Floating Point 결합 순서에 따른 작은 차이일 수 있다. 게임 로직에 필요한 결정성과 허용 오차를 먼저 정의한다.

### Microbenchmark가 빨라지면 전체 게임도 빨라진다

입력 복사, Scheduling, 결과 적용과 다른 Unity 시스템 경쟁을 포함한 Frame 전체에서 다시 확인해야 한다.

---

## 마무리

병렬 처리 성능은 하나의 실행 시간으로 설명할 수 없다.

```text
작업 완료까지 Wall-clock
모든 Worker의 총 CPU Time
Main Thread 대기 시간
전체 Frame Time
최악 Frame과 Percentile
처리량과 개별 Latency
전력과 Thermal 변화
```

공정한 비교는 순차 구현과 병렬 구현에 같은 입력, 결과 검증, Build, Device와 실행 조건을 적용하는 것에서 시작한다.

```text
정답이 같은지 확인
↓
Cold Run과 Warm Run 분리
↓
입력 크기별 여러 번 측정
↓
Break-even Point 확인
↓
Worker Timeline과 Wait 분석
↓
실제 Gameplay Frame에서 검증
↓
장시간 Thermal 테스트
```

병렬화의 목적은 모든 Core를 바쁘게 만드는 것이 아니다. 필요한 결과를 Frame Budget 안에 만들고 다른 Engine 작업의 진행을 방해하지 않는 것이다.

순차 코드가 더 빠른 입력 구간은 그대로 유지하고, 충분히 큰 독립 계산에서만 병렬 경로를 선택하는 방식이 실제 프로젝트에 적합할 수 있다.

---

## 핵심 정리

- Wall-clock은 결과를 기다린 실제 시간이고 CPU Time은 모든 Thread가 사용한 처리 시간의 합이다.
- Speedup은 순차 시간과 병렬 시간의 비율이며 Worker 수만큼 증가한다고 보장되지 않는다.
- 평균뿐 아니라 95·99 Percentile과 최악 Frame Time을 확인해야 간헐적인 대기를 찾을 수 있다.
- 순차와 병렬 구현은 같은 입력, 결과, Build와 Device 조건에서 비교한다.
- 첫 실행의 Compile과 초기화 비용은 Cold Run으로, 안정 상태 실행은 Warm Run으로 나눠 측정한다.
- 입력 크기별 측정으로 Scheduling 비용보다 계산 이익이 커지는 Break-even Point를 찾는다.
- Job의 Schedule 시간, Worker 실행, Complete 대기, 입력 준비와 결과 적용을 별도 구간으로 측정한다.
- Lock, Load Imbalance, Memory Bandwidth와 Oversubscription이 병렬 효율을 제한할 수 있다.
- Unity Profiler Timeline에서 Worker 실행과 Main Thread 작업이 실제로 겹치는지 확인한다.
- Target Device의 장시간 플레이에서 Frame 안정성, 발열과 다른 Unity 시스템의 CPU 영향까지 검증해야 한다.
