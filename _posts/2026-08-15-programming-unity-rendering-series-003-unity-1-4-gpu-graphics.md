---
title: "[Unity 렌더링] 1-4. GPU는 왜 그래픽 처리에 유리할까?"
excerpt: "Unity Rendering"
categories:
  - Programming
tags:
  - Unity
  - Rendering
  - GPU
  - SIMD
  - SIMT
permalink: /programming/unity-1-4-gpu-graphics/
toc: true
toc_sticky: true
date: 2026-08-15
last_modified_at: 2026-08-15
---

게임의 한 Frame을 만들 때 GPU는 수많은 Vertex의 위치를 변환하고, Triangle을 화면의 Fragment로 바꾸며, 각 Fragment의 색상을 계산한다.

이런 작업을 CPU에서도 계산할 수는 있다.

그런데 실시간 렌더링에서는 대부분의 그래픽 연산을 GPU가 담당한다.

이를 단순히 GPU의 Core 수가 많기 때문이라고만 이해하면 CPU와 GPU의 차이를 정확히 설명하기 어렵다.

CPU와 GPU는 애초에 서로 다른 종류의 작업을 효율적으로 처리하도록 설계되었다.

```text
CPU
복잡한 작업을 빠르게 처리
낮은 지연 시간에 초점

GPU
비슷한 작업을 대량으로 처리
높은 처리량에 초점
```

렌더링에는 같은 Shader 연산을 많은 Vertex와 Fragment에 반복하는 과정이 많다.

이 특성이 GPU의 병렬 처리 구조와 잘 맞는다.

---

## CPU와 GPU는 설계 목적이 다르다

CPU는 운영체제, 게임 로직, AI, Physics, 입력 처리처럼 종류가 다양한 작업을 수행한다.

이러한 작업에는 다음과 같은 특징이 있다.

```text
서로 다른 명령이 자주 등장한다.
조건에 따라 실행 경로가 달라진다.
앞선 계산 결과를 기다려야 하는 경우가 많다.
예측하기 어려운 메모리 위치에 접근한다.
```

예를 들어 적 AI는 플레이어를 발견했는지, 체력이 얼마나 남았는지, 이동할 수 있는 길이 있는지에 따라 서로 다른 행동을 선택한다.

```csharp
if (canSeePlayer)
{
    Chase();
}
else if (health < retreatHealth)
{
    Retreat();
}
else
{
    Patrol();
}
```

CPU는 이런 복잡한 제어 흐름을 빠르게 처리하는 데 유리하다.

반면 GPU는 화면 전체의 Vertex와 Fragment처럼 많은 데이터에 비슷한 계산을 적용하는 작업에 초점을 둔다.

```text
Vertex 0 → 위치 변환
Vertex 1 → 위치 변환
Vertex 2 → 위치 변환
...

Fragment 0 → 색상 계산
Fragment 1 → 색상 계산
Fragment 2 → 색상 계산
...
```

각 데이터의 입력값은 달라도 실행하는 계산 과정은 비슷하다.

GPU는 이런 데이터 병렬성이 큰 작업에서 높은 처리량을 낼 수 있도록 구성된다.

---

## Latency와 Throughput

CPU와 GPU의 차이를 이해할 때 **Latency**와 **Throughput**을 구분하는 것이 중요하다.

Latency는 하나의 작업을 시작해서 결과를 얻기까지 걸리는 시간이다.

Throughput은 일정 시간 동안 처리할 수 있는 전체 작업량이다.

```text
Latency
작업 하나가 얼마나 빨리 끝나는가?

Throughput
같은 시간에 작업을 얼마나 많이 끝내는가?
```

CPU는 하나의 실행 흐름을 빠르게 진행하고 복잡한 상황에 대응하기 위해 큰 Cache, 분기 예측, 명령어 실행 최적화와 같은 기능에 많은 자원을 사용한다.

이는 개별 작업의 Latency를 줄이는 데 유리하다.

GPU는 더 많은 연산을 동시에 진행하고, 어떤 작업이 메모리를 기다리는 동안 다른 작업을 실행하는 방식으로 전체 Throughput을 높이는 데 초점을 둔다.

예를 들어 한 Fragment가 Texture 데이터를 기다리고 있다면 GPU의 실행 자원을 그대로 멈춰 두는 대신 준비된 다른 Fragment 그룹을 처리할 수 있다.

```text
Fragment 그룹 A → Texture 대기
                    ↓
Fragment 그룹 B → 연산 실행
Fragment 그룹 C → 실행 준비
```

개별 Fragment 하나의 결과가 즉시 나오는 것보다 Frame 전체에 필요한 수많은 Fragment를 제한된 시간 안에 처리하는 것이 중요하기 때문이다.

60FPS를 목표로 한다면 게임의 모든 작업이 약 16.67ms의 Frame 예산 안에서 이어져야 한다.

GPU에는 한 Pixel만 특별히 빨리 계산하는 것보다 화면 전체의 계산을 높은 처리량으로 완료하는 능력이 더 중요하다.

---

## CPU Core와 GPU 연산 유닛은 같은 개념이 아니다

CPU와 GPU의 사양을 비교할 때 Core 수만 비교하는 경우가 있다.

하지만 CPU Core와 GPU에서 Core라고 부르는 연산 유닛은 구조와 역할이 같지 않다.

CPU는 일반적으로 비교적 적은 수의 강력하고 독립적인 Core를 가진다.

각 Core는 복잡한 명령 흐름을 처리하고, 큰 Cache와 정교한 제어 장치를 이용해 하나의 Thread를 빠르게 진행할 수 있다.

GPU는 다수의 산술 연산 유닛을 여러 실행 그룹으로 구성하여 많은 Thread의 비슷한 명령을 함께 처리한다.

제조사와 GPU Architecture에 따라 실행 단위의 명칭과 구조도 다르다.

따라서 다음과 같은 비교는 정확하지 않다.

```text
CPU Core 8개
GPU Core 2,000개
→ GPU가 모든 작업에서 250배 빠르다
```

GPU의 많은 연산 유닛은 독립적인 CPU Core 수천 개를 그대로 모아 놓은 것이 아니다.

많은 데이터에 같은 종류의 연산을 실행할 때 함께 높은 처리량을 내도록 구성된 자원에 가깝다.

---

## 병렬 처리란?

병렬 처리는 여러 계산을 같은 시간 구간에 함께 진행하는 방식이다.

예를 들어 Vertex Shader가 다음과 같이 각 Vertex의 위치를 변환한다고 가정할 수 있다.

```hlsl
output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
```

Mesh에 Vertex가 10만 개 있다면 같은 Shader가 서로 다른 입력을 대상으로 반복 실행된다.

```text
Shader(Vertex 0)
Shader(Vertex 1)
Shader(Vertex 2)
...
Shader(Vertex 99,999)
```

Vertex 하나의 결과가 다음 Vertex의 결과에 의존하지 않는다면 여러 Vertex를 동시에 처리할 수 있다.

Fragment 처리도 비슷하다.

각 Fragment는 자신의 UV로 Texture를 Sampling하고, Normal과 Light 정보를 이용하여 색상을 계산한다.

```hlsl
float4 albedo = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv);
return albedo * lighting;
```

입력값은 서로 다르지만 동일하거나 유사한 명령을 매우 많은 Fragment에 적용한다.

이처럼 같은 계산을 서로 독립적인 데이터에 적용할 수 있는 성질을 **데이터 병렬성**이라고 한다.

렌더링은 데이터 병렬성이 매우 큰 작업이다.

---

## SIMD란?

SIMD는 **Single Instruction, Multiple Data**의 약자다.

하나의 명령으로 여러 데이터 요소를 함께 처리하는 방식을 의미한다.

네 개의 위치 값에 같은 값을 더하는 상황을 단순화하면 다음과 같다.

```text
일반적인 순차 처리

x0 + 1
x1 + 1
x2 + 1
x3 + 1
```

SIMD 방식에서는 하나의 벡터 명령이 여러 데이터 요소를 대상으로 동작할 수 있다.

```text
[x0, x1, x2, x3] + [1, 1, 1, 1]
```

CPU에도 SIMD 명령어가 존재한다.

따라서 SIMD 자체가 GPU만의 기능은 아니다.

중요한 차이는 GPU가 이런 형태의 병렬 연산을 훨씬 많은 실행 작업에 걸쳐 활용하도록 설계되었다는 점이다.

---

## SIMT란?

GPU 실행 모델을 설명할 때 **SIMT**라는 용어도 자주 등장한다.

SIMT는 **Single Instruction, Multiple Threads**의 약자다.

개발자는 각각의 Thread가 자신의 데이터를 처리하는 것처럼 Shader를 작성하지만, GPU는 여러 Thread를 하나의 실행 그룹으로 묶어 같은 명령을 함께 실행할 수 있다.

```text
Thread 0 → Fragment 0 처리
Thread 1 → Fragment 1 처리
Thread 2 → Fragment 2 처리
Thread 3 → Fragment 3 처리

실제 실행
여러 Thread가 같은 Shader 명령을 함께 진행
```

SIMD는 명령이 여러 데이터 요소를 직접 다루는 관점이고, SIMT는 여러 Thread가 각자의 상태와 데이터를 가진 채 실행되는 프로그래밍 관점이다.

실제 GPU의 세부 실행 단위와 묶음 크기, 스케줄링 방식은 제조사와 Architecture에 따라 달라진다.

NVIDIA에서는 이런 실행 그룹을 Warp라고 부르지만 모든 GPU를 Warp라는 용어만으로 설명하면 안 된다.

Unity Shader를 이해할 때는 다음 정도의 일반적인 모델이 적절하다.

```text
Shader 코드는 Thread별로 실행되는 것처럼 작성한다.
↓
GPU는 여러 Thread를 그룹으로 묶는다.
↓
그룹은 가능한 한 같은 명령을 함께 실행한다.
```

---

## Branch Divergence란?

Shader 안에도 `if` 문을 사용할 수 있다.

```hlsl
if (input.brightness > 0.5)
{
    color *= 2.0;
}
else
{
    color *= 0.5;
}
```

같은 실행 그룹에 포함된 모든 Thread가 같은 경로를 선택한다면 그룹이 함께 해당 명령을 처리할 수 있다.

하지만 일부 Thread는 `if` 경로를 선택하고 다른 Thread는 `else` 경로를 선택할 수 있다.

이를 **Branch Divergence**, 즉 분기 발산이라고 한다.

```text
Thread 0 → if
Thread 1 → if
Thread 2 → else
Thread 3 → else
```

실행 그룹이 서로 다른 경로를 동시에 완전히 독립적으로 처리할 수 없다면 각 경로를 나누어 실행하고, 해당 경로에 참여하지 않는 Thread는 일시적으로 비활성화될 수 있다.

```text
if 경로 실행   → Thread 0, 1 활성
else 경로 실행 → Thread 2, 3 활성
```

이 경우 병렬 실행 자원의 활용도가 낮아질 수 있다.

그렇다고 Shader의 모든 조건문이 항상 큰 성능 문제를 만든다는 의미는 아니다.

분기 비용은 다음 요소에 따라 달라진다.

```text
같은 실행 그룹의 Thread가 서로 다른 경로를 선택하는가?
각 경로의 계산량은 얼마나 큰가?
Compiler가 분기를 다른 연산으로 바꾸는가?
대상 GPU Architecture는 어떻게 실행하는가?
```

짧은 분기는 Compiler가 두 결과를 계산한 뒤 조건에 따라 선택하는 형태로 바꿀 수도 있다.

반대로 긴 반복문이나 비싼 Texture Sampling이 포함된 경로가 Fragment마다 불규칙하게 갈린다면 비용이 커질 수 있다.

따라서 `if` 문의 개수만 보고 Shader 성능을 판단하면 안 된다.

실제 대상 기기에서 GPU Profiler와 Frame Capture 도구를 이용해 확인해야 한다.

---

## GPU가 그래픽 처리에 잘 맞는 이유

게임 렌더링에서는 하나의 Frame마다 많은 독립적인 데이터가 발생한다.

```text
많은 Vertex
↓
위치 변환과 속성 계산

많은 Triangle
↓
Clipping과 Rasterization

많은 Fragment
↓
Texture Sampling과 Lighting
```

1920×1080 해상도에는 약 207만 개의 Pixel이 있다.

실제로 처리하는 Fragment 수는 Overdraw, MSAA, 여러 Render Pass와 후처리 때문에 Pixel 수보다 많아질 수 있다.

이 방대한 데이터를 순서대로 하나씩 처리하면 실시간 Frame 예산을 맞추기 어렵다.

GPU는 다음 특성을 이용해 전체 처리량을 높인다.

```text
많은 연산 유닛
대규모 Thread 실행
비슷한 명령의 그룹 실행
작업 전환을 통한 대기 시간 숨기기
그래픽 파이프라인 전용 기능
```

Vertex와 Fragment에 같은 Shader를 반복 실행하는 렌더링 구조는 GPU가 잘 처리할 수 있는 형태다.

---

## GPU가 모든 연산에서 CPU보다 빠른 것은 아니다

GPU의 병렬 처리 능력은 작업을 충분히 많이 나눌 수 있을 때 효과가 크다.

작업량이 매우 작거나 앞선 결과에 계속 의존한다면 GPU의 많은 실행 자원을 활용하기 어렵다.

복잡한 분기와 순차적인 상태 변경이 많은 작업도 GPU에 잘 맞지 않을 수 있다.

또한 CPU의 데이터를 GPU로 전달하고 명령을 제출하며 결과를 동기화하는 과정에도 비용이 든다.

```text
CPU 데이터 준비
↓
GPU로 데이터 전달
↓
GPU 작업 실행
↓
필요한 경우 결과 동기화
```

계산 자체는 짧은데 전송과 동기화 비용이 더 크다면 GPU를 사용하는 이점이 없다.

그래서 게임에서는 CPU와 GPU가 각자 잘하는 작업을 나누어 처리한다.

CPU는 게임의 상태와 복잡한 제어 흐름을 처리하고, GPU는 준비된 대량의 그래픽 데이터를 높은 Throughput으로 처리한다.

---

## Unity Shader와 GPU의 연결

Unity에서 Shader를 작성할 때 Vertex Shader 코드는 Mesh의 많은 Vertex에 실행된다.

Fragment Shader 코드는 Rasterization으로 생성된 많은 Fragment에 실행된다.

```text
Mesh Vertex 데이터
↓
Vertex Shader를 병렬 실행
↓
Triangle 구성
↓
Rasterization
↓
Fragment Shader를 병렬 실행
↓
Render Target
```

Shader 코드 한 줄은 한 번만 실행되는 것이 아니다.

해당 Draw에서 처리되는 Vertex 또는 Fragment 수만큼 매우 많이 실행될 수 있다.

따라서 작은 연산 하나도 수백만 Fragment에 반복되면 큰 GPU 비용이 될 수 있다.

반대로 코드가 길어 보여도 실행되는 데이터가 적거나 병목이 다른 곳에 있다면 Frame 성능에 미치는 영향은 작을 수 있다.

Shader 최적화 역시 코드 길이만 줄이는 작업이 아니다.

```text
Vertex 수
Fragment 수
Overdraw
Texture Sampling
메모리 대역폭
분기 발산
대상 GPU
```

를 함께 확인해야 한다.

---

## 정리

CPU와 GPU는 어느 한쪽이 항상 더 빠른 관계가 아니라 서로 다른 작업을 목표로 설계된 처리 장치다.

CPU는 복잡한 제어 흐름과 낮은 Latency가 중요한 범용 작업에 강하다.

GPU는 많은 데이터에 동일하거나 유사한 계산을 적용하여 높은 Throughput을 얻는 작업에 강하다.

GPU의 많은 연산 유닛은 CPU Core와 같은 의미가 아니며, 단순한 Core 수 비교로 성능 차이를 판단할 수 없다.

SIMD는 하나의 명령으로 여러 데이터를 처리하는 방식이고, SIMT는 여러 Thread가 각자의 데이터를 처리하는 형태로 코드를 작성하면서 GPU가 Thread 그룹을 함께 실행하는 모델이다.

같은 실행 그룹의 Thread가 서로 다른 조건 경로를 선택하면 Branch Divergence가 발생하여 실행 자원의 효율이 낮아질 수 있다.

그러나 조건문이 있다는 사실만으로 성능 문제를 단정할 수는 없다.

렌더링은 많은 Vertex와 Fragment에 비슷한 Shader 연산을 반복한다.

이러한 데이터 병렬성이 GPU의 처리량 중심 구조와 잘 맞기 때문에 GPU가 실시간 그래픽 처리에 사용된다.

이제 GPU가 처리할 입력인 Vertex, Edge, Triangle, Mesh가 각각 무엇인지 연결하면 3D 오브젝트가 화면에 그려지는 출발점을 이해할 수 있다.

