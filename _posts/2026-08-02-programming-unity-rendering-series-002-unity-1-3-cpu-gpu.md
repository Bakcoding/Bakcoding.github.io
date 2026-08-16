---
title: "[Unity 렌더링] 1-3. CPU와 GPU는 렌더링에서 어떤 일을 할까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - SetPassCall
  - RenderState
permalink: /programming/unity-1-3-cpu-gpu/
toc: true
toc_sticky: true
date: 2026-08-02
last_modified_at: 2026-08-02
---

게임의 렌더링 과정은 GPU만으로 이루어지지 않는다.

화면에 하나의 오브젝트를 그리기 위해서도 CPU와 GPU가 서로 역할을 나누어 작업한다.

CPU는 게임의 현재 상태를 계산하고, 어떤 오브젝트를 어떤 방식으로 그릴지 결정한다.

GPU는 CPU가 전달한 명령과 데이터를 이용해 실제 화면에 표시될 이미지를 계산한다.

단순하게 표현하면 다음과 같다.

```text
CPU
무엇을 그릴지 결정

↓

GPU
어떻게 그릴지 계산
```

이 구분을 이해하면 Draw Call, Batching, Shader, Overdraw 같은 개념이 CPU와 GPU 중 어느 쪽의 비용과 관련되는지도 구분하기 쉬워진다.

---

## CPU는 게임의 상태를 계산한다

CPU는 게임 전체의 흐름을 제어하는 역할을 한다.

Unity에서는 `Update()`, `FixedUpdate()`, AI, Physics, Animation, 게임 규칙 등의 대부분이 CPU에서 처리된다.

예를 들어 플레이어가 이동하는 경우 다음과 같은 계산이 발생한다.

```csharp
private void Update()
{
    Vector3 direction = new Vector3(
        Input.GetAxisRaw("Horizontal"),
        0f,
        Input.GetAxisRaw("Vertical")
    );

    transform.position += direction * speed * Time.deltaTime;
}
```

이 코드에서 CPU는 입력을 확인하고, 이동 방향을 계산하고, Transform의 위치를 변경한다.

이 시점에서 GPU가 캐릭터를 화면에 그리는 것은 아니다.

먼저 CPU가 현재 Frame의 게임 상태를 결정한다.

```text
Input
↓
Game Logic
↓
Transform 변경
↓
현재 Scene 상태 결정
```

이후 렌더링 단계에서 변경된 Scene 상태를 기준으로 GPU가 새로운 화면을 만든다.

---

## CPU는 무엇을 그릴지도 결정한다

Scene 안에 존재하는 모든 오브젝트가 항상 GPU로 전달되는 것은 아니다.

CPU는 Camera와 Scene의 상태를 기준으로 현재 Frame에서 어떤 Renderer가 렌더링 대상인지 판단한다.

예를 들어 다음과 같은 정보가 사용될 수 있다.

```text
Camera
Renderer
Layer
Material
Mesh
Render Queue
Culling 결과
```

Camera의 시야 밖에 있는 오브젝트라면 굳이 GPU에게 그리도록 명령할 필요가 없다.

이처럼 렌더링할 대상을 줄이는 과정 중 하나가 Culling이다.

단순하게 보면 다음 흐름이다.

```text
Scene Object
↓
Camera에 보이는가?
↓
렌더링 대상 결정
↓
GPU 명령 준비
```

따라서 렌더링 성능 문제라고 하더라도 CPU 쪽에서 발생하는 비용이 존재한다.

---

## CPU는 GPU에 명령을 전달한다

CPU와 GPU는 서로 다른 프로세서다.

CPU가 Scene을 계산했다고 해서 GPU가 자동으로 어떤 오브젝트를 그려야 하는지 알 수 있는 것은 아니다.

CPU가 GPU에게 렌더링 명령을 전달해야 한다.

개념적으로는 다음과 같은 요청을 한다고 생각할 수 있다.

```text
이 Mesh를 사용한다.

이 Material을 사용한다.

이 Shader를 사용한다.

이 Transform으로 그린다.

이 Render State를 적용한다.

그린다.
```

이런 GPU 작업 명령은 그래픽 API를 통해 전달된다.

플랫폼에 따라 대표적으로 다음과 같은 그래픽 API가 사용된다.

```text
Direct3D
Vulkan
Metal
OpenGL
```

Unity 개발자가 이러한 API를 직접 호출하지 않더라도 Unity 내부에서는 현재 플랫폼에 맞는 그래픽 API를 이용해 GPU와 통신한다.

---

## Draw Call이란?

CPU가 GPU에게 실제 렌더링을 요청하는 과정에서 자주 등장하는 개념이 **Draw Call**이다.

Draw Call은 간단히 말하면 GPU에게 특정 그래픽 데이터를 그리도록 요청하는 호출이다.

예를 들어 Scene에 서로 다른 오브젝트가 세 개 존재한다고 생각할 수 있다.

```text
Cube
Sphere
Character
```

각 오브젝트를 개별적으로 렌더링해야 한다면 개념적으로는 다음과 같은 요청이 발생할 수 있다.

```text
Draw Cube
Draw Sphere
Draw Character
```

Draw Call은 GPU에서 Vertex를 계산하는 작업 자체와는 조금 다른 문제다.

Draw Call을 준비하고 GPU에게 명령을 전달하는 과정에는 CPU 비용이 들어간다.

따라서 Draw Call이 지나치게 많아지면 GPU가 충분히 빠르더라도 CPU가 렌더링 명령을 준비하는 데 많은 시간을 사용할 수 있다.

---

## Draw Call이 많으면 무조건 느릴까?

Draw Call은 중요한 성능 지표지만 개수만 보고 성능을 판단할 수는 없다.

예를 들어 다음 두 Scene이 있다고 가정한다.

```text
Scene A

Draw Call 300
매우 단순한 Shader
```

```text
Scene B

Draw Call 100
매우 복잡한 Shader
대량의 Pixel 연산
```

Draw Call만 보면 Scene B가 더 좋아 보인다.

하지만 GPU가 복잡한 Shader 처리 때문에 병목이라면 실제로는 Scene B가 더 느릴 수도 있다.

즉 Draw Call은 주로 CPU와 렌더링 명령 제출 비용과 관계된 요소이고, 전체 성능은 GPU의 작업량까지 함께 확인해야 한다.

---

## Render State란?

GPU가 오브젝트를 그릴 때는 Mesh와 Shader만 필요한 것이 아니다.

어떤 방식으로 렌더링할지에 대한 여러 상태 정보도 필요하다.

대표적으로 다음과 같은 상태가 있다.

```text
Depth Test
Depth Write
Culling
Blending
Shader
Texture
Render Target
```

이러한 값들을 묶어서 **Render State**라고 볼 수 있다.

예를 들어 불투명한 오브젝트를 그리다가 반투명 오브젝트를 렌더링해야 한다면 Blend 설정이 변경될 수 있다.

```text
Opaque

Blend Off
Depth Write On

↓

Transparent

Blend On
Depth Write Off
```

GPU가 작업하는 도중 Render State가 자주 바뀌면 CPU와 GPU 사이에서 추가적인 상태 변경 비용이 발생할 수 있다.

그래서 Unity에서는 가능한 경우 비슷한 Material이나 Shader를 사용하는 오브젝트를 묶어서 처리하려고 한다.

---

## SetPass Call

Unity의 렌더링 통계에서 Draw Call과 함께 자주 볼 수 있는 값 중 하나가 **SetPass Call**이다.

SetPass Call은 새로운 Shader Pass와 Render State를 설정하는 작업과 관련이 있다.

단순화하면 다음과 같이 볼 수 있다.

```text
Material A 설정
↓
Shader Pass 설정
↓
Draw
Draw
Draw

↓

Material B 설정
↓
Shader Pass 변경
↓
Draw
```

동일한 렌더링 상태를 유지하면서 여러 오브젝트를 그릴 수 있다면 상태 변경 횟수를 줄일 수 있다.

반대로 Material과 Shader 상태가 계속 달라진다면 GPU에 새로운 상태를 설정하는 작업이 자주 발생한다.

따라서 렌더링 최적화에서는 Draw Call의 수뿐만 아니라 Material과 Shader 구성 역시 중요하다.

---

## GPU는 무엇을 할까?

CPU가 렌더링 명령을 전달하면 실제 그래픽 계산은 GPU가 담당한다.

GPU는 크게 다음과 같은 작업을 처리한다.

```text
Vertex 처리
↓
Primitive 처리
↓
Rasterization
↓
Fragment 처리
↓
Depth / Stencil Test
↓
Blending
↓
Render Target 기록
```

CPU가

```text
이 Mesh를 이 위치에 그려라.
```

라고 요청했다면 GPU는 Mesh의 Vertex부터 실제 화면의 Pixel 결과까지 계산한다.

---

## Vertex 처리

Mesh는 여러 개의 Vertex로 구성된다.

예를 들어 간단한 Triangle이라면 세 개의 Vertex가 존재한다.

```text
       Vertex
         ●
        / \
       /   \
      /     \
     ●-------●
 Vertex   Vertex
```

GPU는 Vertex Shader를 이용해 각 Vertex를 처리한다.

가장 중요한 작업 중 하나는 3D 공간에 존재하는 Vertex를 최종 화면에 사용할 좌표로 변환하는 것이다.

```text
Local Space
↓
World Space
↓
View Space
↓
Clip Space
```

이 좌표 변환 과정은 이후 별도로 다루게 된다.

---

## Rasterization

Vertex 처리가 끝나면 Triangle이 화면의 어느 영역을 차지하는지 판단해야 한다.

이 과정을 Rasterization이라고 한다.

예를 들어 화면에 다음과 같은 Triangle이 있다고 생각할 수 있다.

```text
      /\
     /  \
    /    \
   /______\
```

실제 디스플레이는 연속적인 면이 아니라 Pixel의 집합으로 이루어져 있다.

따라서 GPU는 Triangle이 어떤 Pixel 영역을 차지하는지 판단해야 한다.

개념적으로는 다음과 같다.

```text
Triangle
↓
Rasterization
↓
Fragment 생성
```

이때 생성되는 Fragment를 대상으로 이후의 색상 계산이 진행된다.

---

## Fragment 처리

Fragment Shader는 각 Fragment가 어떤 색을 가져야 하는지를 계산한다.

여기에서는 다양한 연산이 발생할 수 있다.

```text
Texture Sampling
Lighting
Normal Map
Shadow
Color
Reflection
Emission
```

Shader가 복잡해질수록 Fragment 하나를 계산하는 비용도 증가할 수 있다.

더 중요한 것은 화면 해상도가 높아질수록 처리해야 하는 Fragment의 수 역시 크게 증가할 수 있다는 점이다.

예를 들어 Full HD 해상도는 다음과 같다.

```text
1920 × 1080

약 207만 Pixel
```

4K 해상도는 다음과 같다.

```text
3840 × 2160

약 829만 Pixel
```

단순 Pixel 수만 비교해도 약 4배 차이가 발생한다.

따라서 Fragment Shader가 무거운 게임에서는 해상도가 GPU 성능에 큰 영향을 줄 수 있다.

---

## GPU는 왜 그래픽 연산에 적합할까?

CPU와 GPU는 구조적인 목적이 다르다.

CPU는 다양한 종류의 작업을 빠르게 처리하는 데 적합하다.

예를 들어 다음과 같은 작업이다.

```text
게임 로직
조건문
AI
운영체제 처리
메모리 관리
복잡한 제어 흐름
```

반면 그래픽 작업에는 비슷한 계산을 대량의 데이터에 반복하는 경우가 많다.

예를 들어 Vertex가 100,000개 존재한다고 하면 각 Vertex에 비슷한 좌표 변환 연산을 수행해야 한다.

```text
Vertex 1 → 좌표 변환
Vertex 2 → 좌표 변환
Vertex 3 → 좌표 변환
...
Vertex 100000 → 좌표 변환
```

Pixel 처리도 마찬가지다.

```text
Pixel 1 → Shader 계산
Pixel 2 → Shader 계산
Pixel 3 → Shader 계산
...
```

GPU는 이러한 대량 병렬 연산을 처리하기 위한 구조를 가지고 있다.

---

## CPU는 적은 수의 강력한 Core를 가진다

CPU는 일반적으로 비교적 적은 수의 강력한 Core를 가진다.

각 Core는 복잡한 명령 흐름과 다양한 작업을 빠르게 처리하도록 설계되어 있다.

개념적으로 보면 다음과 같다.

```text
CPU

[강한 Core]
[강한 Core]
[강한 Core]
[강한 Core]
```

게임의 AI, 물리, Script와 같이 서로 다른 형태의 복잡한 연산을 처리하는 데 유리하다.

---

## GPU는 많은 연산 유닛을 가진다

GPU는 동일하거나 비슷한 작업을 대량으로 동시에 처리하는 데 초점을 맞춘 구조다.

개념적으로는 다음과 같이 볼 수 있다.

```text
GPU

[Core][Core][Core][Core][Core][Core]
[Core][Core][Core][Core][Core][Core]
[Core][Core][Core][Core][Core][Core]
[Core][Core][Core][Core][Core][Core]
...
```

실제 GPU 구조는 이보다 훨씬 복잡하지만 중요한 점은 대량의 데이터에 동일한 종류의 연산을 병렬적으로 수행하는 데 적합하다는 것이다.

이 특징은 렌더링 작업과 매우 잘 맞는다.

---

## CPU가 Pixel을 직접 그리면 안 될까?

CPU에서도 당연히 이미지 계산을 할 수 있다.

하지만 수백만 개의 Pixel에 동일한 Shader 계산을 반복해야 한다면 GPU의 병렬 처리 구조가 훨씬 효율적이다.

예를 들어 1920×1080 화면에는 약 207만 개의 Pixel이 존재한다.

각 Pixel마다 조명, Texture, 색상 등을 계산한다고 가정하면 한 Frame에서도 엄청난 양의 반복 연산이 필요하다.

그리고 60FPS라면 이 작업을 초당 60번 반복해야 한다.

```text
약 207만 Pixel
×
60 Frame

≈ 초당 1억 2천만 Pixel
```

여기에 Overdraw, Shadow, Post Processing까지 추가되면 실제 연산량은 더욱 증가한다.

GPU가 게임 그래픽 처리에 사용되는 이유가 여기에 있다.

---

## CPU Bound

게임 성능이 CPU의 처리 속도에 의해 제한되는 상황을 **CPU Bound**라고 한다.

렌더링과 관련해서는 대표적으로 다음과 같은 원인이 있을 수 있다.

```text
과도한 Draw Call
많은 Renderer
Culling 비용
복잡한 Animation
Skinned Mesh 처리
게임 Script
Physics
GC
```

예를 들어 GPU는 하나의 Frame을 6ms 만에 처리할 수 있지만 CPU가 Frame 준비에 20ms를 사용한다면 전체 게임은 CPU의 속도에 제한된다.

```text
CPU : 20ms
GPU : 6ms
```

이 경우 GPU Shader를 조금 최적화해도 전체 FPS에는 거의 영향이 없을 수 있다.

---

## GPU Bound

반대로 GPU의 처리 속도가 전체 Frame을 제한하는 상황을 **GPU Bound**라고 한다.

대표적인 원인은 다음과 같다.

```text
복잡한 Shader
높은 해상도
Overdraw
많은 Transparent
Shadow
Post Processing
많은 Light
높은 MSAA
```

예를 들어 CPU가 하나의 Frame을 5ms 만에 준비하지만 GPU 렌더링에 22ms가 걸린다고 가정한다.

```text
CPU : 5ms
GPU : 22ms
```

이 경우 Script 최적화를 진행해도 GPU 작업이 그대로라면 전체 성능은 크게 개선되지 않는다.

---

## CPU와 GPU의 역할을 구분하는 것이 중요한 이유

최적화에서는 문제가 발생한 위치와 다른 부분을 수정하면 기대한 성능 향상을 얻기 어렵다.

예를 들어 CPU Bound 상황에서 다음 작업을 한다고 가정한다.

```text
Texture 해상도 감소
Shader 단순화
Post Processing 품질 감소
```

GPU의 작업량은 감소하지만 CPU가 여전히 병목이라면 FPS는 크게 변하지 않을 수 있다.

반대로 GPU Bound 상황에서 Draw Call만 줄이는 것도 마찬가지다.

```text
CPU 작업량 감소

하지만

GPU Shader 비용 그대로
```

결국 병목은 그대로 남는다.

그래서 최적화는 먼저 측정부터 시작해야 한다.

```text
성능 문제 발생
↓
CPU / GPU Frame Time 확인
↓
어느 쪽이 느린지 확인
↓
구체적인 원인 분석
↓
해당 부분 최적화
```

---

## Unity에서 CPU와 GPU 비용을 확인하기

Unity에서는 Profiler를 통해 CPU와 GPU의 Frame 처리 시간을 분석할 수 있다.

대표적으로 다음 영역을 확인한다.

```text
CPU Usage
GPU Usage
Rendering
```

또한 Frame Debugger를 이용하면 현재 Frame에서 어떤 순서로 렌더링 명령이 수행되고 있는지도 확인할 수 있다.

```text
Render Pass
Draw
Material
Shader
Render Target
```

따라서 렌더링 최적화는 단순히 설정을 낮추는 작업이 아니라 CPU와 GPU의 역할을 구분하고 어느 단계에서 시간이 소모되는지를 찾아가는 과정이라고 볼 수 있다.

---

## CPU와 GPU의 관계를 단순하게 정리하면

전체적인 흐름을 단순화하면 다음과 같다.

```text
CPU

게임 상태 계산
↓
렌더링 대상 결정
↓
Render State 준비
↓
Draw Command 생성

         ↓

GPU

Vertex 처리
↓
Rasterization
↓
Fragment 처리
↓
Depth / Blending
↓
최종 이미지 생성
```

CPU가 GPU에게 작업을 공급하는 구조라고 생각할 수도 있다.

CPU가 명령을 충분히 빠르게 만들지 못하면 GPU가 기다린다.

반대로 GPU가 명령을 처리하지 못하면 CPU가 GPU의 작업 완료를 기다리게 된다.

결국 하나의 Frame 성능은 CPU와 GPU가 얼마나 효율적으로 작업을 이어가느냐에 영향을 받는다.

---

## 정리

게임의 렌더링은 CPU와 GPU가 역할을 나누어 처리한다.

CPU는 게임의 현재 상태를 계산하고, Camera에 어떤 오브젝트가 보여야 하는지 판단하며, Mesh와 Material, Shader 등의 정보를 이용해 GPU에게 렌더링 명령을 전달한다.

이 과정에서 Draw Call과 Render State 변경 같은 CPU 비용이 발생할 수 있다.

GPU는 전달받은 명령을 기준으로 Vertex를 처리하고, Triangle을 Rasterization하며, Fragment Shader를 실행해 최종 Pixel의 색상을 계산한다.

GPU는 동일하거나 비슷한 계산을 대량의 데이터에 병렬적으로 처리하는 데 특화되어 있기 때문에 Vertex와 Pixel을 대량으로 계산해야 하는 그래픽 작업에 적합하다.

CPU의 작업 시간이 전체 Frame을 제한하면 CPU Bound, GPU의 작업 시간이 전체 Frame을 제한하면 GPU Bound 상태가 된다.

따라서 렌더링 최적화에서 중요한 것은 단순히 Draw Call이나 Polygon 수를 줄이는 것이 아니라

```text
현재 병목이 CPU에 있는가?

GPU에 있는가?
```

를 먼저 확인하는 것이다.

이 구분을 기준으로 이후에 등장하는 Draw Call, Batching, Shader, Overdraw 등의 최적화 방법을 서로 다른 관점에서 이해할 수 있다.
