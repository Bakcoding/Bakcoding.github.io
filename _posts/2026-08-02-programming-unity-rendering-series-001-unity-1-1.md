---
title: "[Unity 렌더링] 1-1. 렌더링이란 무엇일까?"
excerpt: "Unity Rendering"
categories:
  - Programming
tags:
  - Unity
  - Rendering
  - CPU
  - GPU
  - Frame
permalink: /programming/unity-1-1/
toc: true
toc_sticky: true
date: 2026-08-02
last_modified_at: 2026-08-02
---

게임 화면에 보이는 캐릭터, 배경, UI, 이펙트는 처음부터 하나의 완성된 이미지로 존재하는 것이 아니다.

Unity 안에는 Mesh, Material, Texture, Light, Camera와 같은 여러 데이터가 존재하고, 이 데이터들을 이용하여 최종적으로 모니터에 표시할 한 장의 이미지를 만들어낸다.

이렇게 **3D 공간에 존재하는 데이터를 2D 화면에 표시할 이미지로 변환하는 과정**을 렌더링(Rendering)이라고 한다.

단순하게 표현하면 다음과 같다.

```text
3D Scene
↓
Camera
↓
Rendering
↓
2D Image
↓
Display
```

게임은 이 과정을 한 번만 수행하지 않는다.

플레이어가 움직이고, 캐릭터가 애니메이션되고, 조명이 변하고, 파티클이 재생되는 것처럼 게임의 상태는 계속 변경된다.

따라서 현재 게임 상태를 기준으로 새로운 이미지를 계속 만들어 화면에 출력해야 한다.

이때 한 번 만들어지는 하나의 화면을 **Frame**이라고 한다.

---

## Frame이란?

Frame은 특정 시점의 게임 화면을 구성하는 하나의 이미지다.

예를 들어 게임이 60FPS로 동작한다면 1초 동안 약 60장의 이미지를 만들어 화면에 표시한다.

```text
Frame 1
Frame 2
Frame 3
...
Frame 60
```

이 이미지들이 빠르게 연속해서 표시되기 때문에 플레이어에게는 하나의 움직이는 화면처럼 보인다.

FPS는 **Frames Per Second**의 약자로, 1초 동안 몇 개의 Frame을 처리했는지를 의미한다.

```text
30 FPS = 1초에 30 Frame
60 FPS = 1초에 60 Frame
120 FPS = 1초에 120 Frame
```

FPS가 높을수록 일반적으로 화면의 움직임이 더 부드럽게 느껴진다.

하지만 렌더링 최적화를 다룰 때 FPS만 보는 것은 충분하지 않다.

중요한 값 중 하나가 **Frame Time**이다.

---

## Frame Time이란?

Frame Time은 하나의 Frame을 처리하는 데 걸린 시간을 의미한다.

예를 들어 60FPS를 유지하려면 1초에 60개의 Frame을 만들어야 한다.

```text
1000ms / 60 ≒ 16.67ms
```

즉 하나의 Frame을 약 16.67ms 이내에 처리해야 한다.

FPS에 따른 Frame Time은 대략 다음과 같다.

| FPS     | Frame Time |
| ------- | ---------: |
| 30 FPS  |    33.33ms |
| 60 FPS  |    16.67ms |
| 90 FPS  |    11.11ms |
| 120 FPS |     8.33ms |
| 144 FPS |     6.94ms |

게임이 60FPS를 목표로 하고 있는데 하나의 Frame을 처리하는 데 20ms가 필요하다면 60FPS를 안정적으로 유지할 수 없다.

이런 이유로 최적화를 분석할 때는 단순히 FPS가 낮다는 결과만 보는 것이 아니라,

```text
하나의 Frame에서 어디에 시간이 많이 사용되고 있는가?
```

를 확인해야 한다.

---

## 하나의 Frame에서는 렌더링만 수행할까?

하나의 Frame에서는 그래픽 처리만 수행되는 것이 아니다.

게임에서는 대략 다음과 같은 작업들이 함께 이루어진다.

```text
Input 처리
↓
Game Logic
↓
Physics
↓
Animation
↓
Rendering 준비
↓
GPU Rendering
↓
화면 출력
```

Unity를 기준으로 보면 `Update`, 물리 연산, 애니메이션 계산, 오브젝트 상태 변경 같은 작업도 계속 수행된다.

이후 현재 Scene의 상태를 기준으로 어떤 오브젝트를 그릴 것인지 판단하고 GPU에게 렌더링 명령을 전달한다.

따라서 게임 성능이 떨어진다고 해서 반드시 그래픽 자체가 원인인 것은 아니다.

예를 들어 다음과 같은 경우도 있다.

```text
CPU
게임 로직 계산이 너무 많음
↓
Frame 지연
```

반대로 게임 로직은 단순하지만 무거운 Shader나 높은 해상도 때문에 GPU가 늦게 처리할 수도 있다.

```text
GPU
Pixel 계산량이 너무 많음
↓
Frame 지연
```

이 때문에 렌더링 최적화를 시작할 때 가장 먼저 확인해야 하는 것 중 하나가 **CPU와 GPU 중 어디에서 병목이 발생하고 있는지**다.

---

## 렌더링에서 CPU와 GPU

렌더링이라고 하면 GPU가 모든 것을 처리한다고 생각하기 쉽지만 실제로는 CPU와 GPU가 역할을 나누어 작업한다.

CPU는 주로 게임의 상태를 관리하고 GPU에게 무엇을 그릴지 지시하는 역할을 한다.

예를 들어 다음과 같은 작업이 CPU에서 이루어진다.

```text
어떤 오브젝트가 존재하는가
어떤 오브젝트를 렌더링해야 하는가
어떤 Material을 사용하는가
어떤 Shader를 사용하는가
어떤 Mesh를 그릴 것인가
```

이러한 정보를 정리하여 GPU에게 렌더링 명령을 전달한다.

GPU는 전달받은 데이터를 이용하여 실제 화면에 표시될 결과를 계산한다.

```text
Vertex 위치 계산
Triangle 처리
Pixel 계산
Texture Sampling
Lighting 계산
Depth Test
Blending
```

즉 큰 흐름으로 보면 다음과 같이 이해할 수 있다.

```text
CPU

Scene 상태 계산
↓
렌더링할 오브젝트 결정
↓
GPU에게 Draw 명령 전달


GPU

Vertex 처리
↓
Triangle 처리
↓
Pixel 처리
↓
최종 이미지 생성
```

---

## CPU와 GPU는 동시에 일한다

CPU와 GPU는 일반적으로 모든 작업을 완전히 순차적으로 처리하는 구조가 아니다.

CPU가 GPU에게 렌더링 명령을 전달한 뒤 다음 작업을 준비하는 동안 GPU는 이전에 전달받은 명령을 처리할 수 있다.

개념적으로 보면 다음과 같다.

```text
CPU : Frame 1 준비 → Frame 2 준비 → Frame 3 준비
GPU :             Frame 1 렌더 → Frame 2 렌더 → Frame 3 렌더
```

이처럼 CPU와 GPU가 각자의 작업을 병렬적으로 수행하기 때문에 어느 한쪽이 지나치게 느리면 다른 한쪽이 기다리게 된다.

CPU 작업이 너무 오래 걸리는 경우를 흔히 **CPU Bound**라고 한다.

```text
CPU ████████████████████
GPU      ███████
```

GPU가 렌더링을 빠르게 처리할 수 있어도 CPU가 명령을 늦게 전달하므로 전체 Frame이 느려진다.

반대로 GPU 작업량이 지나치게 많은 경우는 **GPU Bound**라고 한다.

```text
CPU ███████
GPU      ████████████████████
```

CPU는 다음 작업을 준비했지만 GPU가 이전 Frame의 렌더링을 아직 끝내지 못한 상황이다.

렌더링 최적화의 방향은 이 두 상황에 따라 크게 달라진다.

---

## CPU Bound에서는 무엇이 문제가 될까?

CPU 쪽 렌더링 병목은 대표적으로 다음과 같은 상황에서 발생할 수 있다.

```text
Draw Call이 지나치게 많음
Render State 변경이 많음
오브젝트가 너무 많음
Culling 비용이 높음
Skinned Mesh 처리량이 많음
게임 로직 자체가 무거움
```

특히 Unity 최적화에서 자주 등장하는 `Draw Call`, `Batching`, `SRP Batcher`, `GPU Instancing` 같은 개념은 CPU가 GPU에게 렌더링 명령을 전달하는 비용과 밀접한 관계가 있다.

---

## GPU Bound에서는 무엇이 문제가 될까?

GPU 쪽 병목은 주로 실제 그래픽 계산량이 너무 많을 때 발생한다.

예를 들어 다음과 같은 경우가 있다.

```text
복잡한 Shader
높은 화면 해상도
많은 Transparent 오브젝트
Overdraw
실시간 Shadow
많은 Light
Post Processing
많은 Pixel 연산
```

같은 Scene이라도 화면 해상도를 낮췄을 때 FPS가 크게 상승한다면 GPU의 Pixel 처리 비용이 병목일 가능성을 생각해볼 수 있다.

반대로 해상도를 크게 낮춰도 성능 변화가 거의 없다면 CPU가 병목일 가능성도 있다.

물론 실제 원인을 판단할 때는 추측보다는 Unity Profiler 등의 분석 도구를 사용해야 한다.

---

## Rendering Pipeline

렌더링은 하나의 단일 작업으로 이루어지는 것이 아니다.

3D Mesh가 최종 화면의 Pixel이 되기까지 여러 단계를 거친다.

이를 **Rendering Pipeline**이라고 한다.

아주 단순하게 표현하면 다음과 같다.

```text
3D Object
↓
Vertex 처리
↓
Triangle 처리
↓
Rasterization
↓
Fragment 처리
↓
Depth / Blending
↓
Screen
```

예를 들어 하나의 캐릭터가 존재한다고 해서 GPU가 그 캐릭터를 곧바로 이미지로 변환하는 것은 아니다.

캐릭터의 Mesh를 구성하는 Vertex를 처리하고,

Vertex를 이용해 Triangle을 구성하고,

Triangle이 화면의 어느 Pixel 영역을 차지하는지 계산하고,

각 Pixel에 어떤 색을 출력할지 결정하는 여러 과정이 필요하다.

렌더링 파이프라인을 이해해야 Shader가 어디에서 실행되는지, Triangle 수가 왜 중요한지, Overdraw가 왜 발생하는지, Transparent가 왜 비싼지 같은 내용도 자연스럽게 연결된다.

---

## Unity의 Rendering Pipeline

Unity에서는 이러한 렌더링 과정을 개발자가 직접 처음부터 구현할 필요는 없다.

Unity가 Camera, Renderer, Material, Shader 등의 정보를 바탕으로 렌더링 과정을 구성해준다.

대표적인 Unity의 렌더링 파이프라인은 다음과 같다.

```text
Built-in Render Pipeline

URP
Universal Render Pipeline

HDRP
High Definition Render Pipeline
```

URP와 HDRP는 **SRP(Scriptable Render Pipeline)** 구조를 기반으로 만들어져 있다.

각 렌더링 파이프라인은 같은 Scene을 그리더라도 내부에서 Light, Shadow, Render Pass 등을 처리하는 방식이 다를 수 있다.

따라서 Unity에서 렌더링 최적화를 한다는 것은 단순히 GPU의 원리만 이해하는 것으로 끝나지 않는다.

```text
컴퓨터 그래픽스의 렌더링 원리

+

Unity의 렌더링 구조

+

사용 중인 Render Pipeline

+

Unity의 최적화 옵션
```

이 네 가지를 함께 이해해야 각각의 설정이 어떤 작업을 줄이고, 반대로 어떤 비용을 발생시키는지 판단할 수 있다.

---

## 렌더링 최적화에서 중요한 관점

최적화를 처음 접하면 다음과 같은 규칙을 외우기 쉽다.

```text
Draw Call을 줄인다.
Polygon을 줄인다.
Texture 크기를 줄인다.
Shadow를 끈다.
Light를 줄인다.
```

하지만 이런 방식에는 문제가 있다.

모든 게임에서 같은 요소가 병목이 되는 것은 아니기 때문이다.

예를 들어 GPU가 Pixel Shader 처리 때문에 병목이 발생하고 있는데 Triangle 수만 줄여도 큰 성능 개선이 없을 수 있다.

반대로 CPU에서 Draw Call 처리 비용이 병목인데 Texture 해상도만 줄이는 것 역시 기대한 만큼의 효과를 얻기 어렵다.

따라서 렌더링 최적화는 다음 흐름으로 접근하는 것이 중요하다.

```text
문제 발생
↓
Profiler로 측정
↓
CPU / GPU 병목 확인
↓
병목 원인 분석
↓
해당 부분 최적화
↓
다시 측정
```

즉 렌더링 최적화에서 가장 중요한 것은 모든 그래픽 품질을 낮추는 것이 아니라 **현재 Frame에서 가장 많은 시간을 사용하고 있는 작업을 찾아내는 것**이다.

---

## 정리

렌더링은 3D Scene의 데이터를 계산하여 최종적인 2D 이미지를 만들어내는 과정이다.

게임에서는 이 과정을 매 Frame 반복한다.

Frame 하나를 처리하는 시간은 제한되어 있으며, 60FPS를 목표로 한다면 약 16.67ms 안에 하나의 Frame이 처리되어야 한다.

하나의 Frame은 CPU와 GPU가 역할을 나누어 처리한다.

CPU는 게임 상태를 계산하고 렌더링 명령을 준비하며, GPU는 Vertex, Triangle, Pixel 등의 그래픽 연산을 수행한다.

어느 한쪽의 처리 시간이 길어지면 전체 Frame Time 역시 길어진다.

따라서 렌더링 최적화에서는 단순히 그래픽 설정을 낮추는 것이 아니라 먼저 CPU와 GPU 중 어디에서 병목이 발생하는지를 확인해야 한다.

그리고 GPU가 하나의 화면을 만들어내기까지 거치는 여러 처리 단계를 **렌더링 파이프라인**이라고 한다.

렌더링 파이프라인을 이해하면 이후 등장하는 Draw Call, Shader, Overdraw, Lighting, Shadow, Batching 등의 개념이 서로 어떤 관계를 가지고 있는지 이해하기 쉬워진다.
