---
title: "[Unity 렌더링] 1-2. 하나의 프레임은 어떻게 만들어질까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - VSync
  - DrawCall
permalink: /programming/unity-1-2/
toc: true
toc_sticky: true
date: 2026-08-02
last_modified_at: 2026-08-02
---

게임 화면은 정지된 한 장의 이미지가 아니라, 매우 짧은 시간 간격으로 계속 새롭게 만들어지는 이미지의 연속이다.

이때 한 번 만들어지는 화면을 **Frame**이라고 한다.

앞에서는 렌더링이 3D Scene의 데이터를 이용해 최종 2D 이미지를 만들어내는 과정이라고 정리했다.

그렇다면 실제로 하나의 Frame이 만들어질 때는 어떤 일이 일어날까.

단순하게 생각하면 다음과 같은 흐름으로 볼 수 있다.

```text
입력 처리
↓
게임 로직 처리
↓
물리 및 애니메이션 처리
↓
렌더링 준비
↓
GPU 렌더링
↓
화면 출력
```

하지만 실제로는 CPU와 GPU가 서로 다른 작업을 나누어 처리하며, 이 과정은 완전히 순차적으로만 실행되지 않는다.

하나의 Frame이 어떻게 만들어지는지 이해하면 이후에 등장하는 CPU Bound, GPU Bound, Draw Call, VSync, Profiler 같은 개념도 훨씬 자연스럽게 연결된다.

---

## Frame은 어디서 시작할까?

게임의 Frame은 보통 사용자의 입력이나 시간의 흐름에 따라 게임 상태를 갱신하는 과정에서 시작한다.

Unity에서는 대표적으로 `Update()`를 떠올릴 수 있다.

```csharp
private void Update()
{
    transform.position += Vector3.forward * speed * Time.deltaTime;
}
```

이 코드는 매 Frame마다 실행된다.

즉 현재 Frame에서 플레이어의 위치를 계산하고, 다음 Frame에서는 다시 변경된 상태를 기준으로 새로운 위치를 계산한다.

게임에서는 위치 이동뿐만 아니라 다음과 같은 작업들이 계속 이루어진다.

```text
사용자 입력 처리
캐릭터 이동
AI 처리
충돌 판정
애니메이션 계산
UI 갱신
게임 상태 변경
```

이렇게 CPU에서 게임의 현재 상태가 결정된 이후에야 화면에 무엇을 그려야 하는지도 결정할 수 있다.

---

## Game Logic

하나의 Frame에서 가장 먼저 생각할 수 있는 부분은 게임 로직이다.

게임 로직은 현재 게임 상태를 계산하는 작업이다.

예를 들어 플레이어가 이동 버튼을 눌렀다고 가정한다.

```text
키 입력
↓
플레이어 이동 계산
↓
Transform 변경
↓
Animation 상태 변경
```

이 과정에서 실제 화면에 Pixel을 그리는 작업은 아직 발생하지 않는다.

단지 현재 Frame에서 플레이어가 어디에 있어야 하는지, 어떤 애니메이션을 재생해야 하는지 같은 정보를 결정한다.

Unity에서는 이러한 작업이 주로 CPU에서 처리된다.

---

## Physics

게임에 물리 시스템이 사용된다면 물리 연산도 Frame 처리 과정의 일부가 된다.

Unity에서는 일반적인 게임 로직인 `Update()`와 별개로 물리 처리를 위한 `FixedUpdate()`가 존재한다.

```csharp
private void FixedUpdate()
{
    rigidbody.AddForce(Vector3.forward * force);
}
```

`FixedUpdate()`는 Frame Rate에 직접 종속되지 않고 고정된 시간 간격을 기준으로 실행된다.

따라서 하나의 화면 Frame 안에서 물리 연산이 여러 번 실행될 수도 있고, 반대로 어떤 Frame에서는 실행되지 않을 수도 있다.

예를 들어 게임이 순간적으로 느려졌다고 가정한다.

```text
Frame 처리 시간 증가
↓
Physics Step이 밀림
↓
한 Frame에서 여러 번 Physics 계산
```

이 경우 CPU의 작업량이 더욱 증가할 수 있다.

따라서 Frame Time과 Physics 처리 역시 서로 영향을 줄 수 있다.

---

## Animation

애니메이션도 화면을 그리기 전에 먼저 계산되어야 한다.

캐릭터가 현재 어느 포즈를 취하고 있는지 결정되지 않았다면 GPU는 캐릭터 Mesh를 올바른 위치에 그릴 수 없다.

예를 들어 Skinned Mesh를 사용하는 캐릭터라면 다음과 같은 정보가 계산된다.

```text
Animator 상태 계산
↓
Bone Transform 계산
↓
Skinned Mesh 변형
↓
렌더링 데이터 준비
```

캐릭터 수가 많거나 복잡한 Animator Controller를 사용하는 경우에는 이 과정 역시 CPU 비용에 영향을 줄 수 있다.

---

## 렌더링 준비

게임 로직, 물리, 애니메이션 등의 처리가 끝났다고 해서 바로 화면이 그려지는 것은 아니다.

Unity는 현재 Scene을 기준으로 **무엇을 그려야 하는지** 판단해야 한다.

대표적으로 다음과 같은 작업이 필요하다.

```text
Camera 확인
↓
렌더링 대상 확인
↓
Culling
↓
Material 확인
↓
Shader 확인
↓
렌더링 순서 결정
↓
GPU Command 생성
```

예를 들어 Scene에 오브젝트가 10,000개 있다고 하더라도 Camera에 보이지 않는 오브젝트까지 모두 그릴 필요는 없다.

Unity는 Camera의 시야 범위를 기준으로 렌더링할 오브젝트를 결정한다.

이 과정에서 사용되는 대표적인 기술이 **Frustum Culling**이다.

이후 실제로 그려야 하는 오브젝트들의 Mesh, Material, Shader 등의 정보를 기반으로 GPU에 전달할 렌더링 명령을 준비한다.

---

## Draw Call

CPU가 GPU에게 특정 오브젝트를 그리도록 요청하는 작업을 이해할 때 자주 등장하는 개념이 **Draw Call**이다.

개념적으로는 다음과 같이 볼 수 있다.

```text
CPU

Cube를 이 Mesh로 그린다.
이 Material을 사용한다.
이 Shader를 사용한다.

↓

GPU

해당 데이터를 이용해 렌더링
```

Scene에 여러 오브젝트가 존재하면 이러한 요청도 여러 번 발생할 수 있다.

```text
Draw Cube
Draw Character
Draw Tree
Draw Building
Draw Effect
...
```

Draw Call이 많아지면 GPU의 계산량뿐만 아니라 CPU가 렌더링 명령을 준비하고 전달하는 비용도 증가할 수 있다.

그래서 Unity에서는 이후에 살펴볼 여러 최적화 기법을 제공한다.

```text
Static Batching
Dynamic Batching
GPU Instancing
SRP Batcher
```

이 기능들은 방식은 서로 다르지만 CPU와 GPU 사이의 렌더링 처리 비용을 줄이는 것과 관련이 있다.

---

## GPU Rendering

CPU가 렌더링 명령을 준비하면 GPU는 해당 명령을 이용해 실제 화면의 그래픽을 계산한다.

GPU에서는 대략 다음과 같은 흐름이 진행된다.

```text
Vertex 처리
↓
Triangle 처리
↓
Rasterization
↓
Fragment 처리
↓
Depth Test
↓
Blending
↓
Render Target에 결과 저장
```

이 과정이 일반적으로 우리가 말하는 GPU 렌더링 파이프라인에 해당한다.

예를 들어 캐릭터 하나를 그린다고 하면 Mesh의 Vertex를 화면상의 위치로 변환하고, Triangle을 구성한 뒤, Triangle이 차지하는 영역을 Fragment로 변환한다.

그 다음 Shader를 이용하여 각 Fragment의 최종 색을 계산한다.

---

## Render Target

GPU가 계산한 결과는 바로 모니터에 하나씩 찍히는 방식으로 처리되지 않는다.

렌더링 결과는 일반적으로 **Render Target**이라는 메모리 영역에 저장된다.

대표적으로 화면에 표시할 색상 정보를 저장하는 버퍼를 생각할 수 있다.

```text
GPU Rendering
↓
Color Buffer
↓
완성된 Frame
```

여기에 Depth 정보가 필요하다면 별도의 Depth Buffer도 함께 사용된다.

```text
Color Buffer
Depth Buffer
Stencil Buffer
```

이러한 Buffer들이 하나의 Frame을 구성하는 데 사용된다.

Unity에서 `RenderTexture`를 사용하면 이러한 Render Target의 개념을 직접 활용할 수도 있다.

---

## Back Buffer와 Front Buffer

화면을 그리는 동안 완성되지 않은 이미지가 그대로 모니터에 표시되면 문제가 발생할 수 있다.

예를 들어 화면의 위쪽은 현재 Frame이고 아래쪽은 이전 Frame인 상태가 나타날 수 있다.

이를 방지하기 위해 일반적으로 렌더링 결과를 별도의 Buffer에 먼저 만든다.

개념적으로 다음과 같다.

```text
Front Buffer
현재 화면에 표시 중인 이미지

Back Buffer
GPU가 다음 Frame을 렌더링 중인 이미지
```

GPU가 Back Buffer에 새로운 Frame을 완성하면 화면에 표시할 Buffer를 교체한다.

```text
Back Buffer 렌더링 완료
↓
Buffer Swap
↓
새 Frame 표시
```

이 방식을 **Double Buffering**이라고 한다.

환경에 따라 세 개의 Buffer를 사용하는 Triple Buffering이 사용될 수도 있다.

---

## Present

GPU가 Frame을 모두 렌더링했다고 해서 Frame 처리가 완전히 끝난 것은 아니다.

완성된 이미지를 실제 디스플레이에 표시하는 과정이 필요하다.

이 과정을 흔히 **Present**라고 한다.

```text
게임 상태 계산
↓
Rendering
↓
Back Buffer 완성
↓
Present
↓
Display
```

Present 과정은 디스플레이의 Refresh Rate와도 관련이 있다.

예를 들어 60Hz 모니터라면 디스플레이는 1초에 약 60번 화면을 갱신한다.

```text
60Hz = 1초에 60번 화면 갱신
```

GPU가 아무리 빠르게 Frame을 만들어도 디스플레이가 실제로 화면을 갱신할 수 있는 속도에는 한계가 있다.

---

## Refresh Rate와 FPS는 다르다

FPS와 Refresh Rate는 비슷해 보이지만 서로 다른 개념이다.

FPS는 게임이나 GPU가 초당 몇 개의 Frame을 만들어냈는지를 의미한다.

Refresh Rate는 디스플레이가 초당 몇 번 화면을 갱신하는지를 의미한다.

예를 들어 다음과 같은 상황이 가능하다.

```text
게임 : 120 FPS
모니터 : 60Hz
```

게임은 초당 120개의 Frame을 만들 수 있지만 디스플레이는 초당 60번만 화면을 갱신할 수 있다.

반대로 다음과 같은 경우도 있다.

```text
게임 : 40 FPS
모니터 : 144Hz
```

디스플레이는 빠르게 화면을 갱신할 수 있지만 게임이 새로운 Frame을 충분히 만들어내지 못한다.

---

## Screen Tearing

GPU가 새로운 Frame을 만드는 속도와 모니터의 화면 갱신 시점이 맞지 않으면 **Screen Tearing** 현상이 발생할 수 있다.

예를 들어 모니터가 하나의 화면을 출력하는 도중 GPU가 새로운 Frame으로 Buffer를 교체했다고 가정한다.

```text
화면 위쪽 : 이전 Frame
화면 아래쪽 : 새로운 Frame
```

이 경우 화면이 수평 방향으로 찢어진 것처럼 보일 수 있다.

이 현상을 Screen Tearing이라고 한다.

---

## VSync

Screen Tearing을 방지하기 위해 사용되는 대표적인 방법이 **VSync(Vertical Synchronization)**다.

VSync는 GPU가 Frame을 표시하는 시점을 디스플레이의 Refresh 주기에 맞추는 방식이다.

```text
GPU Frame 완성
↓
Display Refresh 대기
↓
Present
```

예를 들어 60Hz 모니터에서 VSync가 적용되면 일반적으로 디스플레이 갱신 시점에 맞춰 Frame이 표시된다.

이렇게 하면 Screen Tearing을 줄일 수 있다.

하지만 GPU가 Frame을 빠르게 완성해도 다음 화면 갱신 시점까지 기다려야 하는 상황이 발생할 수 있다.

따라서 Profiler에서 Frame Time을 분석할 때는 VSync로 인한 대기 시간인지 실제 연산 때문에 느린 것인지 구분할 필요가 있다.

---

## CPU와 GPU는 순차적으로만 움직이지 않는다

하나의 Frame을 설명할 때 다음처럼 생각하기 쉽다.

```text
CPU Frame 1
↓
GPU Frame 1
↓
CPU Frame 2
↓
GPU Frame 2
```

실제로는 이런 방식으로만 움직이지 않는다.

CPU와 GPU는 가능한 범위에서 동시에 작업한다.

예를 들어 다음과 같은 형태가 될 수 있다.

```text
시간 →

CPU  | Frame 1 | Frame 2 | Frame 3 | Frame 4 |
GPU  |         | Frame 1 | Frame 2 | Frame 3 |
```

CPU가 Frame 2의 게임 로직과 렌더링 명령을 준비하는 동안 GPU는 Frame 1을 렌더링할 수 있다.

이렇게 CPU와 GPU가 각자의 작업을 병렬적으로 처리하면서 전체 성능을 높인다.

---

## CPU가 너무 느린 경우

CPU가 하나의 Frame을 준비하는 데 너무 많은 시간이 필요하면 GPU가 처리할 명령이 제때 전달되지 않는다.

```text
CPU

████████████████████
Frame 준비


GPU

    █████
    렌더링
```

GPU는 처리 능력이 남아 있지만 CPU가 새로운 작업을 전달하지 못하는 상황이 된다.

이런 상태를 **CPU Bound**라고 한다.

CPU Bound가 발생하는 원인은 다양하다.

```text
게임 로직
Physics
Animation
Draw Call
Culling
Script
GC
```

렌더링 최적화에서도 Draw Call이나 Culling 같은 CPU 비용이 중요한 이유다.

---

## GPU가 너무 느린 경우

반대로 CPU가 빠르게 명령을 준비했지만 GPU가 렌더링을 끝내지 못하는 경우도 있다.

```text
CPU

█████
Frame 준비


GPU

    ████████████████████
    렌더링
```

GPU가 이전 Frame을 처리하는 동안 CPU가 기다려야 할 수 있다.

이러한 상태를 **GPU Bound**라고 한다.

대표적인 원인은 다음과 같다.

```text
무거운 Shader
높은 해상도
Overdraw
Shadow
Post Processing
많은 Pixel 처리
많은 Light
```

따라서 FPS가 낮다는 사실만으로 어떤 최적화를 해야 하는지 결정할 수 없다.

---

## Frame Time을 나누어서 생각해야 한다

하나의 Frame을 단순히 하나의 작업으로 보는 것보다 여러 처리 영역으로 나누어 생각하는 것이 중요하다.

```text
Frame

├─ Game Logic
├─ Physics
├─ Animation
├─ Rendering Preparation
├─ GPU Rendering
└─ Present / Wait
```

예를 들어 Frame Time이 25ms라고 하더라도 원인은 완전히 다를 수 있다.

```text
Case 1

Game Logic        15ms
Rendering          5ms
기타               5ms
```

이 경우에는 CPU 게임 로직을 먼저 확인하는 편이 합리적이다.

반대로 다음과 같을 수도 있다.

```text
Case 2

Game Logic         3ms
Rendering          2ms
GPU                20ms
```

이 경우 CPU 코드를 최적화해도 성능 향상은 크지 않을 수 있다.

GPU 쪽 병목을 찾아야 한다.

---

## Unity Profiler와 Frame

Unity Profiler를 사용하면 하나의 Frame에서 어떤 작업이 시간을 사용했는지 확인할 수 있다.

대표적으로 다음과 같은 영역을 확인한다.

```text
CPU Usage
GPU Usage
Rendering
Memory
Physics
Animation
```

CPU Usage의 Timeline을 살펴보면 하나의 Frame 안에서 어떤 작업이 어느 시점에 실행되었는지 확인할 수 있다.

이때 중요한 것은 단순히 숫자를 보는 것이 아니다.

```text
왜 이 구간에서 시간이 증가했는가?
```

를 찾아내는 것이 핵심이다.

렌더링 최적화도 같은 방식으로 접근한다.

```text
FPS가 낮다
```

에서 끝나는 것이 아니라

```text
Frame Time이 길다
↓
CPU인가 GPU인가?
↓
어떤 작업이 오래 걸리는가?
↓
왜 오래 걸리는가?
↓
어떤 작업량을 줄일 수 있는가?
```

와 같이 원인을 좁혀간다.

---

## 하나의 Frame을 전체적으로 보면

지금까지의 과정을 하나로 정리하면 대략 다음과 같다.

```text
Input
↓
Game Logic
↓
Physics
↓
Animation
↓
Scene 상태 결정
↓
Culling
↓
Rendering Command 준비
↓
Draw Call
↓
GPU Rendering
↓
Render Target
↓
Present
↓
Display
```

여기서 CPU와 GPU가 완전히 직렬로 처리되는 것은 아니다.

여러 Frame에 걸쳐 서로 다른 작업을 동시에 진행하며 처리량을 높인다.

따라서 게임의 Frame 성능을 이해하려면 CPU와 GPU를 하나의 처리 장치로 생각하기보다 서로 연결된 두 개의 처리 장치로 이해하는 것이 좋다.

---

## 정리

하나의 Frame은 단순히 GPU가 화면을 한 번 그리는 것만을 의미하지 않는다.

사용자 입력을 처리하고 게임 로직을 계산하며, 물리와 애니메이션을 갱신한 뒤 현재 Scene 상태를 기준으로 렌더링할 데이터를 준비한다.

CPU는 렌더링에 필요한 명령을 구성해 GPU에 전달하고, GPU는 Vertex와 Fragment 등의 그래픽 연산을 수행하여 Render Target에 최종 이미지를 만든다.

완성된 이미지는 Present 과정을 거쳐 디스플레이에 표시된다.

CPU와 GPU는 가능한 범위에서 서로 동시에 동작하며, 어느 한쪽의 처리 시간이 길어지면 전체 Frame Time 역시 증가한다.

따라서 렌더링 최적화에서는 Frame을 하나의 결과로만 보는 것이 아니라

```text
CPU에서 무엇을 하고 있는가?

GPU에서 무엇을 하고 있는가?

둘 중 어디에서 기다림이 발생하고 있는가?
```

를 나누어서 확인하는 것이 중요하다.

이 구조를 이해하면 이후 Draw Call, GPU 렌더링 파이프라인, Batching, Overdraw 등의 개념이 Frame 안에서 각각 어느 위치에 해당하는지도 자연스럽게 연결할 수 있다.
