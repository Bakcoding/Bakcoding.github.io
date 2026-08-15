---
title: "[Unity 렌더링] 5-1. Unity는 한 프레임을 어떻게 렌더링할까?"
excerpt: "Unity Rendering"
categories:
  - Programming
tags:
  - Unity
  - Rendering
  - GameLoop
  - Culling
  - Present
permalink: /programming/unity-5-1-frame-rendering/
toc: true
toc_sticky: true
date: 2026-08-15
last_modified_at: 2026-08-15
---

Game 화면의 한 Frame은 Camera가 Scene을 사진처럼 한 번 찍은 결과만은 아니다.

Unity는 Input과 Script를 갱신하고, Physics와 Animation 결과를 반영한 뒤, Camera마다 보일 수 있는 Object를 고르고, 여러 Render Pass를 실행해 Image를 만든다.

완성된 Image는 Display가 사용할 수 있도록 제출된다.

```text
Frame 시작
↓
Game State 갱신
↓
Camera와 Renderer 수집
↓
Culling
↓
Render Pass 구성과 실행
↓
GPU Rendering
↓
Present
↓
다음 Frame
```

CPU가 다음 Frame을 준비하는 동안 GPU가 이전 Frame의 Command를 실행할 수 있으므로 이 흐름이 항상 한 줄로만 순차 실행되는 것도 아니다.

한 Frame의 전체 구조를 이해하면 CPU 병목, GPU 병목, Draw Call 증가와 Present 대기를 서로 구분할 수 있다.

---

## Frame이란?

Frame은 Display에 보여 줄 한 장의 Image를 만드는 시간 단위다.

60 FPS를 목표로 한다면 Frame 하나에 사용할 수 있는 평균 시간은 약 16.67ms다.

```text
1초 / 60 Frames
= 0.01667초
= 약 16.67ms
```

대표적인 Frame Budget은 다음과 같다.

| 목표 Frame Rate | Frame Budget |
|---:|---:|
| 30 FPS | 약 33.33ms |
| 60 FPS | 약 16.67ms |
| 90 FPS | 약 11.11ms |
| 120 FPS | 약 8.33ms |

이 시간 안에는 Rendering만 들어가는 것이 아니다.

```text
Input
Script
Physics
Animation
Audio
Rendering 준비
GPU Rendering
Synchronization과 대기
```

목표 Frame Rate는 가장 오래 걸리는 주요 작업과 CPU·GPU의 겹침, VSync 및 Platform Scheduling의 영향을 받는다.

---

## Unity의 Player Loop

Unity Application은 Player Loop라는 반복 구조로 실행된다.

```text
while (Application 실행 중)
{
    Input과 System 갱신
    Fixed Update 작업
    Game Logic 갱신
    Animation 갱신
    Late Update 작업
    Rendering 준비와 제출
    Frame 완료
}
```

실제 Player Loop는 위 의사 코드보다 훨씬 많은 System과 Subsystem으로 구성된다.

Unity는 정해진 기본 순서에 따라 Physics, Script Event, Animation, Rendering과 Frame 완료 작업을 호출한다.

```text
Player Loop 한 번
≈ Application의 한 Frame 진행
```

단, Fixed Physics Update는 Render Frame마다 정확히 한 번 실행된다고 보장되지 않는다.

누적 시간에 따라 한 Frame 안에서 여러 번 실행되거나 실행되지 않을 수도 있다.

---

## Game Loop와 Render Loop

Game Loop는 Application 전체 상태를 갱신하는 큰 반복 구조다.

Render Loop는 그 상태를 Image로 만드는 Rendering 작업의 흐름이다.

```text
Game Loop
├─ Input
├─ Gameplay Script
├─ Physics
├─ Animation
└─ Render Loop
   ├─ Camera 처리
   ├─ Culling
   ├─ Render Pass
   └─ Present 준비
```

Render Loop는 Game Loop와 분리된 독립 Application이 아니다.

현재 Game State의 Transform, Camera, Light, Renderer와 Material 정보를 읽어 GPU 작업으로 변환하는 부분이다.

---

## Frame 초반의 Game State 갱신

Rendering 전에 Scene 상태가 결정되어야 한다.

```text
Input
↓
Character 이동
↓
Physics 결과
↓
Animation Pose
↓
Camera 추적
↓
최종 Transform
```

대표적으로 `Update`에서는 일반 Gameplay Logic을, `LateUpdate`에서는 Character 이동이 끝난 뒤 Camera를 따라가게 만드는 Logic을 작성할 수 있다.

```csharp
using UnityEngine;

public class FollowCamera : MonoBehaviour
{
    [SerializeField] private Transform target;
    [SerializeField] private Vector3 offset;

    private void LateUpdate()
    {
        transform.position = target.position + offset;
    }
}
```

Camera의 최종 Transform이 늦게 결정되면 Culling과 View Matrix도 그 결과를 기준으로 계산되어야 한다.

Rendering 결과는 해당 Frame에서 확정된 Scene 상태의 Snapshot에 가깝다.

---

## Transform과 Animation 결과

Renderer가 그릴 Vertex Position은 GameObject Transform과 Animation의 영향을 받는다.

```text
Static Mesh
Mesh Vertex
+ Transform
↓
World Position
```

```text
Skinned Mesh
Mesh Vertex
+ Bone Pose
+ Skinning Weight
+ Transform
↓
변형된 World Position
```

CPU 또는 GPU Skinning 방식에 따라 실제 변형 작업 위치는 달라질 수 있다.

하지만 Render Loop가 사용할 Transform, Bone과 Parameter Data가 현재 Frame 상태에 맞게 준비되어야 한다는 점은 같다.

---

## Camera가 렌더링의 기준을 만든다

Unity의 Scene 전체를 한 번에 그대로 GPU에 보내는 것이 아니다.

Camera는 다음 정보를 이용해 어떤 Image를 만들지 정의한다.

```text
Position과 Rotation
Projection
Viewport
Culling Mask
Near / Far Clip Plane
Render Target
Renderer 설정
Post-processing 설정
```

한 Scene에 Camera가 여러 개라면 Camera마다 Culling과 Rendering Loop가 실행될 수 있다.

Game Camera 외에도 다음 Camera 성격의 작업이 존재할 수 있다.

```text
Scene View Camera
Reflection Probe
Preview Camera
Base Camera
Overlay Camera
Render Texture Camera
```

따라서 Game View에 Camera 하나만 보인다고 해서 Frame 안의 Camera Rendering이 항상 한 번뿐이라고 단정할 수 없다.

---

## URP의 Camera Loop

Unity 6 URP의 Universal Renderer는 Camera마다 다음과 같은 큰 흐름을 수행한다.

```text
1. Culling Parameter 설정
2. Culling 수행
3. Rendering Data 구성
4. Renderer 설정
5. Render Pass 실행
6. Camera Image 출력
```

조금 더 자세히 표현하면 다음과 같다.

```text
Camera
↓
Culling Parameter
↓
Visible Renderer / Light / Shadow Caster 계산
↓
URP Asset + Camera + Platform 설정 결합
↓
필요한 Render Pass Queue 구성
↓
각 Render Pass 실행
↓
Framebuffer 또는 Render Texture
```

Rendering Path가 Forward, Forward+ 또는 Deferred인지, Depth Texture와 Opaque Texture가 필요한지에 따라 실제 Pass 구성이 달라진다.

---

## Culling Parameter 설정

Culling을 수행하기 전에 Camera와 Pipeline 설정을 기준으로 조건을 만든다.

```text
Camera Frustum
Layer와 Culling Mask
Occlusion Culling 사용 여부
Shadow Distance
Per-layer Culling Distance
LOD Parameter
```

이 조건은 어떤 Renderer, Light와 Shadow Caster가 이후 Rendering 후보가 될지 결정한다.

Camera가 무엇을 기준으로 Object를 고르는지는 다음 글에서 더 구체적으로 다룬다.

---

## Culling이란?

Culling은 최종 Image에 기여하지 않을 가능성이 높은 Object나 Primitive를 Rendering 대상에서 제외하는 과정이다.

```text
Scene의 모든 Renderer
↓
Culling
↓
현재 Camera에서 필요한 Renderer
```

대표적인 Culling은 다음과 같다.

| 종류 | 제거 기준 |
|---|---|
| Layer Culling | Camera의 Culling Mask에 포함되지 않음 |
| Frustum Culling | Camera가 보는 공간 밖에 있음 |
| Occlusion Culling | 다른 Geometry에 가려질 것으로 판단됨 |
| Distance Culling | 설정된 거리보다 멀리 있음 |
| LOD Culling | LOD Group의 마지막 단계에서 제외됨 |

Culling을 통과했다는 사실이 화면 Pixel을 반드시 만든다는 뜻은 아니다.

GPU의 Back-face Culling, Depth Test, Alpha Clip과 Scissor Test 등에서 추가로 제거될 수 있다.

---

## CPU Culling과 GPU의 Pixel 판정

Unity의 Object 단위 Culling과 Graphics Pipeline의 Primitive·Fragment 판정은 계층이 다르다.

```text
CPU / Render Pipeline Culling
Renderer 단위 후보 제거
↓
Draw 제출
↓
GPU Back-face Culling
Triangle 방향으로 제거
↓
Rasterization
↓
GPU Depth / Stencil / Alpha 판정
Fragment 단위 제거
```

Frustum 밖의 Renderer를 CPU에서 제거하면 해당 Renderer의 Draw 자체를 피할 수 있다.

Depth Test에서 가려진 Pixel을 제거하면 Draw는 제출되었지만 일부 Fragment 실행과 Color 기록을 줄일 수 있다.

두 최적화의 비용과 효과를 같은 것으로 보면 안 된다.

---

## Culling Result

Culling 결과에는 Camera에 보일 수 있는 Renderer만 있는 것이 아니다.

URP는 Camera Loop에서 다음과 같은 Data를 구성할 수 있다.

```text
Visible Renderers
Visible Lights
Shadow Casters
Reflection Probe 관련 정보
LOD 선택 결과
```

Camera에 직접 보이지 않는 Object도 Light의 Shadow Map에는 필요할 수 있다.

```text
Camera 밖의 Object
↓
Camera Color에는 보이지 않음

하지만
↓
Light Shadow 영역 안에 있고
화면 안 Object에 그림자를 만듦
↓
ShadowCaster로 필요할 수 있음
```

Camera Visibility와 Shadow Caster Visibility를 구분해야 하는 이유다.

---

## Rendering Data 구성

Culling이 끝나면 URP는 Culling 결과와 Project 설정을 결합하여 현재 Camera에 필요한 Rendering 정보를 만든다.

```text
Culling Result
+ URP Asset
+ Camera 설정
+ Quality Level
+ Platform Capability
↓
Rendering Data
```

이 Data를 바탕으로 다음과 같은 결정을 내릴 수 있다.

```text
어떤 Light를 사용할까?
Shadow를 그려야 하는가?
Depth Prepass가 필요한가?
Opaque Texture가 필요한가?
어떤 Post-processing을 실행할까?
어떤 Render Target이 필요한가?
```

모든 Camera가 동일한 Render Pass 목록을 실행하는 것은 아니다.

---

## Renderer 설정과 Render Pass Queue

URP Renderer는 현재 Rendering Data에 따라 실행할 Render Pass를 구성한다.

```text
필요한 기능 분석
↓
Render Pass 생성 또는 준비
↓
실행 Event에 따라 Queue 구성
↓
순서대로 실행
```

Forward Rendering의 개념적인 Pass 순서는 다음과 같이 표현할 수 있다.

```text
Shadow Map
↓
Depth 또는 Depth-Normal Prepass가 필요한 경우 실행
↓
Opaque Objects
↓
Skybox
↓
Transparent Objects
↓
Post-processing
↓
Final Blit / Resolve
```

정확한 구성과 순서는 URP Version, Renderer, Camera 설정과 Renderer Feature에 따라 달라질 수 있다.

---

## Render Pass와 Shader Pass

이름은 비슷하지만 두 계층을 구분해야 한다.

```text
URP Render Pass
Pipeline이 수행할 Rendering 작업

ShaderLab Pass
Material을 특정 목적으로 그릴 Program과 Render State
```

예를 들어 URP의 Opaque Render Pass가 Object를 그리도록 요청하면 Material에서 알맞은 `LightMode`의 ShaderLab Pass가 선택된다.

```text
URP Opaque Render Pass
↓
Visible Opaque Renderer 순회
↓
Material 확인
↓
UniversalForward Shader Pass 선택
↓
Draw Command
```

Shadow Render Pass에서는 같은 Material의 `ShadowCaster` Pass를 선택할 수 있다.

---

## Shadow Rendering

실시간 Shadow가 필요하면 Camera Color보다 먼저 Shadow Map을 만들 수 있다.

```text
Light 기준 Culling
↓
Shadow Caster 수집
↓
ShadowCaster Pass 선택
↓
Light View에서 Depth 기록
↓
Shadow Map
```

이후 Camera Color Pass의 Lighting이 Shadow Map을 Sample한다.

```text
Camera Fragment의 World Position
↓
Light Space로 변환
↓
Shadow Map Depth와 비교
↓
빛을 받는지 판정
```

Directional Light의 Cascade나 여러 Shadow Light가 있으면 Shadow Rendering 작업이 반복될 수 있다.

---

## Depth Prepass

현재 Camera 설정과 기능에 따라 Opaque Color 전에 Depth를 먼저 기록할 수 있다.

```text
Visible Opaque Objects
↓
DepthOnly Pass
↓
Camera Depth
↓
후속 Rendering과 Effect에서 사용
```

Depth-Normal 정보가 필요하면 `DepthNormalsOnly` Pass가 사용될 수 있다.

Depth Priming, SSAO, Rendering Path와 Platform 조건에 따라 실제 방식은 달라진다.

Prepass는 추가 Draw를 만들지만 이후 Overdraw 감소나 필요한 Texture 생성에 도움을 줄 수 있다.

항상 이득 또는 손해라고 단정하지 않고 대상 GPU에서 측정해야 한다.

---

## Opaque Rendering

Opaque Object는 일반적으로 불투명한 Surface를 Camera Color와 Depth에 기록한다.

```text
Visible Opaque Renderer
↓
Render Queue와 Sorting 조건
↓
Shader Pass와 Variant 선택
↓
Mesh + Material Data Binding
↓
Draw 제출
↓
Color / Depth 기록
```

Opaque는 Depth Test와 Depth Write를 이용해 가까운 Surface가 먼 Surface를 가리도록 처리한다.

앞쪽 Object를 먼저 그리면 뒤쪽 Fragment를 Early Depth Test로 제거할 가능성이 커질 수 있다.

실제 Sorting 기준은 Pipeline과 Camera 설정의 영향을 받으며 별도 글에서 다룬다.

---

## Skybox Rendering

Skybox는 Camera 배경을 채운다.

```text
Opaque Geometry가 기록한 Depth
↓
남아 있는 배경 영역
↓
Skybox Color
```

URP Camera의 Background Type과 Renderer 설정에 따라 Solid Color나 Skybox 등으로 배경을 구성한다.

Skybox가 정확히 어느 시점에 그려지는지는 Pipeline 구현에 따르지만 일반적인 Camera Image 흐름에서는 Opaque와 Transparent 사이에 배치될 수 있다.

---

## Transparent Rendering

Transparent Object는 뒤에 이미 그려진 Color와 섞어야 하는 경우가 많다.

```text
Opaque Color
↓
먼 Transparent
↓
가까운 Transparent
↓
최종 혼합 Color
```

일반 Alpha Blending에서는 순서가 결과에 영향을 준다.

```text
A 위에 B를 Blend
≠
B 위에 A를 Blend
```

그래서 Opaque와 Transparent는 서로 다른 Queue와 Sorting 전략을 사용한다.

Transparent는 흔히 Depth Write를 끄므로 겹친 Layer의 Fragment가 많이 실행되어 Overdraw가 증가할 수 있다.

---

## Post-processing

Scene Geometry Rendering이 끝난 뒤 Camera Color에 Screen Space Effect를 적용할 수 있다.

```text
Scene Color
↓
Bloom
↓
Color Grading
↓
Tone Mapping
↓
Anti-Aliasing
↓
Final Color
```

실제 순서와 중간 Render Target 구성은 URP 설정과 Effect에 따라 달라진다.

Post-processing은 화면 전체 또는 넓은 영역을 처리하므로 해상도와 Render Target Memory Bandwidth의 영향을 크게 받을 수 있다.

Effect 하나가 반드시 Draw Call 하나라는 뜻도 아니다.

여러 단계와 임시 Texture를 요구할 수 있다.

---

## Final Blit과 Resolve

Camera가 중간 Color Texture에 그렸다면 최종 Target으로 복사하거나 변환해야 할 수 있다.

```text
Camera Intermediate Color
↓
Post-processing 결과
↓
MSAA Resolve / Upscaling / Format 변환
↓
Backbuffer 또는 Target Texture
```

URP는 조건이 맞으면 중간 Texture를 생략하거나 Render Pass를 합쳐 불필요한 Memory 이동을 줄일 수 있다.

반대로 Camera Opaque Texture, Post-processing, HDR, Dynamic Resolution이나 Renderer Feature 때문에 Intermediate Target이 필요할 수 있다.

---

## Render Texture로 출력하는 Camera

모든 Camera가 Display Backbuffer로 직접 출력하는 것은 아니다.

```text
Camera
↓
Render Texture
↓
Monitor Material에서 Sample
↓
Main Camera
↓
Screen
```

감시 Camera, Mirror, Portal, Minimap 같은 효과가 이 구조를 사용할 수 있다.

URP에서는 Render Texture로 출력하는 Camera의 결과가 화면 Camera에서 필요하므로 해당 Camera Loop가 먼저 실행될 수 있다.

Camera가 늘면 Culling, Render Pass와 Draw 작업도 늘 수 있다.

---

## Camera Stacking

URP의 Universal Renderer는 Base Camera 위에 Overlay Camera 출력을 결합할 수 있다.

```text
Base Camera
World Rendering
↓
Overlay Camera A
Weapon 또는 Cockpit
↓
Overlay Camera B
추가 Layer
↓
Camera Stack 결과
```

Camera마다 Culling Mask와 Rendering 설정을 다르게 구성할 수 있다.

그러나 같은 화면 Pixel을 Camera별로 다시 그리면 Overdraw와 Camera Loop 비용이 증가한다.

Camera Stack은 원하는 Layering을 쉽게 만들지만 비용이 무료는 아니다.

---

## CPU는 Draw Command를 준비한다

Renderer가 보인다고 GPU가 Unity Component를 직접 읽는 것은 아니다.

CPU 쪽 Rendering System이 GPU가 이해할 Command와 Resource 상태를 준비한다.

```text
Renderer Component
+ Mesh
+ Material
+ Transform
+ Light Data
↓
Rendering System
↓
Buffer와 Texture Binding
Shader Variant 선택
Render State 설정
Draw Command
```

Draw Command에는 사용할 Geometry, Program, Resource와 그리는 범위 등이 연결된다.

이 준비 비용 때문에 매우 많은 Renderer와 State 변경은 CPU 병목을 만들 수 있다.

---

## Main Thread와 Render Thread

Platform과 Graphics API에 따라 Unity는 Rendering Command 준비를 Main Thread와 Render Thread에 나누어 처리할 수 있다.

```text
Main Thread
Game Logic
Culling과 Rendering 준비
Render Command 생성 요청
↓
Render Thread
Graphics API Command로 변환
Driver에 제출
↓
GPU
Command 실행
```

Unity Job System과 Render Pipeline 내부의 병렬 작업도 일부 준비에 사용될 수 있다.

Profiler에서는 Main Thread 시간만 보지 말고 Render Thread, Worker Thread와 GPU Timeline을 함께 확인해야 한다.

---

## CPU와 GPU는 겹쳐서 일할 수 있다

CPU가 Frame N+1을 준비하는 동안 GPU가 Frame N을 그릴 수 있다.

```text
시간 →

CPU  [Frame N 준비][Frame N+1 준비][Frame N+2 준비]
GPU          [Frame N 실행][Frame N+1 실행]
Display              [Frame N 표시]
```

이 Pipeline 구조는 Hardware를 쉬지 않게 만들지만 Input부터 화면 표시까지의 Latency를 늘릴 수 있다.

CPU가 GPU보다 너무 빨리 Command를 만들면 Queue가 길어질 수 있고, Engine이나 Driver가 CPU를 대기시킬 수 있다.

GPU가 빠르고 CPU 준비가 늦다면 GPU가 새 작업을 기다릴 수 있다.

---

## GPU Rendering

GPU는 제출된 Command를 바탕으로 Graphics Pipeline을 실행한다.

```text
Vertex Data
↓
Vertex Shader
↓
Primitive Assembly
↓
Clipping
↓
Rasterization
↓
Fragment Shader
↓
Depth / Stencil / Blend
↓
Render Target
```

한 Frame 안에는 Shadow Map, Depth Texture, Camera Color와 Post-processing을 위한 여러 Pipeline 실행이 포함될 수 있다.

CPU가 Draw를 제출했다는 시점과 GPU가 실제로 그 Draw를 끝낸 시점은 같지 않을 수 있다.

---

## Render Target

Render Target은 Rendering 결과를 기록하는 Texture 또는 Buffer다.

```text
Shadow Pass
→ Shadow Map

Depth Pass
→ Camera Depth Texture

Opaque / Transparent
→ Camera Color

Post-processing
→ Intermediate Color

Final Output
→ Backbuffer
```

Pass가 바뀔 때 Render Target도 바뀔 수 있다.

Texture를 읽고 쓰는 순서와 Lifetime을 관리하는 것이 Render Pipeline의 중요한 역할이다.

Unity 6 URP는 Render Graph 경로에서 Pass가 사용하는 Resource를 선언하여 Lifetime과 동기화를 관리할 수 있다.

---

## Command 제출과 GPU 완료는 다르다

CPU가 Graphics API에 Command를 제출했다고 Image가 즉시 완성되는 것은 아니다.

```text
CPU Submit
↓
Driver / Command Queue
↓
GPU Execute
↓
Render Target 완료
```

Profiler Marker의 CPU Rendering 시간과 GPU Rendering 시간은 다른 Timeline을 나타낸다.

CPU Marker가 짧아도 GPU가 복잡한 Shader와 많은 Pixel을 오래 처리할 수 있다.

반대로 GPU가 여유 있어도 CPU의 Culling, Sorting과 Draw 제출이 오래 걸릴 수 있다.

---

## Present란?

Present는 Rendering이 끝난 Image를 Display System이 표시할 수 있도록 넘기는 단계다.

```text
Backbuffer에 Image 완성
↓
Present 요청
↓
Display System의 Swap / Composition
↓
Monitor Scanout
```

Double Buffering을 단순화하면 Front Buffer와 Backbuffer를 번갈아 사용할 수 있다.

```text
Frame N
Front Buffer → Display
Backbuffer   → GPU Rendering

Present 이후
새로 완성된 Buffer를 표시 대상으로 전환
```

현대 OS의 Window Compositor와 Graphics API에서는 실제 동작이 더 복잡할 수 있지만 핵심은 완성된 Frame을 표시 단계로 전달하는 것이다.

---

## VSync

VSync는 Frame 표시를 Display Refresh와 동기화하여 화면 일부가 서로 다른 Frame으로 섞여 보이는 Tearing을 줄인다.

```text
Display Refresh
|----16.67ms----|----16.67ms----|

Present
Refresh 시점에 맞춰 표시
```

GPU와 CPU가 일찍 끝나도 다음 표시 시점이나 목표 Frame Rate를 기다릴 수 있다.

Profiler에서 Present 관련 Wait가 보인다고 항상 Rendering이 느리다는 뜻은 아니다.

```text
Present Wait가 큼
가능성 A: VSync 대기
가능성 B: Target FPS 제한
가능성 C: GPU 또는 Queue 동기화 대기
```

Platform과 Graphics API별 Marker 의미를 함께 확인해야 한다.

---

## Present가 Frame의 끝인가?

CPU 관점에서는 Present 호출과 Frame 완료 처리가 Loop의 끝부분에 위치할 수 있다.

하지만 GPU와 Display 관점의 완료 시점은 서로 다르다.

```text
CPU
Present 호출 완료

GPU
해당 Frame Command를 아직 실행 중일 수 있음

Display
완성된 Image를 다음 Refresh에 Scanout
```

따라서 다음 문장은 모두 서로 다른 의미다.

```text
CPU가 Frame Logic을 끝냈다
GPU가 Frame Rendering을 끝냈다
Display가 Frame을 보여 주었다
```

Frame Timing을 분석할 때 어느 완료 시점을 말하는지 구분해야 한다.

---

## CPU Bound Frame

CPU 작업이 Frame Rate를 제한하는 경우다.

```text
CPU  [======================]
GPU       [==========]

CPU가 다음 작업을 늦게 제출
→ GPU가 기다릴 수 있음
```

대표적인 원인은 다음과 같다.

```text
많은 Script Update
Physics Simulation
Animation 처리
많은 Renderer Culling
많은 Draw Call 제출
빈번한 State 변경
Garbage Collection
```

Main Thread와 Render Thread 중 어느 쪽이 긴지도 구분해야 한다.

Draw Call이 많다는 사실만으로 반드시 Main Thread 병목이라고 단정할 수는 없다.

---

## GPU Bound Frame

GPU 작업이 Frame Rate를 제한하는 경우다.

```text
CPU  [==========]
GPU       [======================]

다음 Frame Resource 사용 전 동기화
→ CPU가 GPU를 기다릴 수 있음
```

대표적인 원인은 다음과 같다.

```text
높은 해상도
복잡한 Fragment Shader
많은 Transparent Overdraw
많은 Shadow Map과 높은 Shadow Resolution
비싼 Post-processing
높은 MSAA Sample 수
과도한 Geometry
Memory Bandwidth 병목
```

해상도를 낮췄을 때 GPU 시간이 크게 줄어든다면 Pixel 처리나 Bandwidth 병목 가능성을 조사할 수 있다.

---

## Present Limited Frame

CPU와 GPU가 Frame Budget보다 빠르게 끝났지만 VSync나 Frame Rate 제한 때문에 기다리는 경우가 있다.

```text
CPU Work  [====]
GPU Work      [=====]
Wait                [=========]
Next Refresh                      |
```

이 상태는 반드시 성능 문제가 있다는 뜻은 아니다.

목표 Frame Rate를 안정적으로 만족해 남은 시간 동안 대기하는 정상적인 결과일 수 있다.

Unity의 Frame Timing 정보는 Main Thread Work, Render Thread Work, GPU Frame Time과 Present Wait를 구분하는 데 도움을 준다.

---

## 한 Frame이 16.67ms를 넘으면

60Hz VSync 환경에서 Frame이 표시 시점을 놓치면 다음 Refresh까지 기다릴 수 있다.

단순한 Double Buffering 환경을 가정하면 Frame Rate가 큰 단계로 떨어지는 것처럼 보일 수 있다.

```text
16.67ms 안에 완료
→ 다음 Refresh에 표시 가능

조금 늦게 완료
→ 다음 Refresh를 놓침
→ 추가 대기 가능
```

Triple Buffering, Variable Refresh Rate, Mobile Frame Pacing과 OS Compositor에 따라 실제 표시 방식은 달라진다.

평균 Frame Time뿐 아니라 Spike와 Frame Pacing을 함께 확인해야 한다.

---

## 여러 Camera가 있는 Frame

Camera가 두 개면 단순히 화면이 두 장 생기는 것만이 아니다.

```text
Camera A
├─ Culling
├─ Shadow와 Render Pass 구성
└─ Rendering

Camera B
├─ Culling
├─ Render Pass 구성
└─ Rendering
```

Shadow Data나 일부 Resource를 재사용할 가능성은 Pipeline 구현에 따라 다르지만 Camera별 작업이 추가되는 것은 고려해야 한다.

특히 Camera가 같은 Scene 영역을 같은 Target에 반복해서 그리면 Overdraw와 CPU 제출 비용이 늘 수 있다.

Frame Debugger에서 Camera별 Event 범위를 확인할 수 있다.

---

## Renderer Feature가 Frame에 추가하는 작업

URP Renderer Feature는 기본 Renderer에 Custom Render Pass를 추가할 수 있다.

```text
기본 URP Pass Queue
+ Custom Renderer Feature
↓
추가 Object Draw
또는 Full-screen Effect
또는 Custom Texture 생성
```

Feature 하나가 추가되면 필요한 Render Target, Culling 결과 사용, Draw와 Blit가 늘 수 있다.

Inspector에서 Feature가 켜져 있다는 사실만 보지 말고 실제 Frame Debugger Event와 GPU 비용을 확인해야 한다.

---

## Scene View와 Editor의 Frame

Unity Editor에서는 Game View 외에도 Scene View, Inspector Preview와 Editor UI가 Rendering될 수 있다.

```text
Editor Frame
├─ Game Camera
├─ Scene View Camera
├─ Asset Preview
└─ Editor UI
```

Editor Profiler 결과는 Player Build와 다를 수 있다.

Editor Overhead와 추가 Camera가 포함되기 때문이다.

최종 성능 판단은 Development Build와 목표 Device의 Profiler Data를 함께 사용해야 한다.

---

## Frame Debugger로 흐름 확인하기

Frame Debugger는 한 Frame의 Rendering Event를 순서대로 멈춰 확인할 수 있다.

```text
Frame 시작
↓
Shadow Map Event
↓
Depth Event
↓
Opaque Draw
↓
Skybox
↓
Transparent Draw
↓
Post-processing
↓
Final Output
```

각 Event에서 다음 정보를 확인할 수 있다.

```text
Render Target
Drawn Object
Mesh
Material
Shader Pass
Shader Keyword
Render State
```

Frame Debugger는 실행 순서와 상태를 이해하는 데 유용하지만 각 Event의 정확한 GPU 시간은 GPU Profiler나 Platform Capture Tool로 측정해야 한다.

---

## Unity Profiler에서 볼 영역

CPU Profiler Timeline에서는 Player Loop 안의 작업과 Thread 관계를 볼 수 있다.

```text
Main Thread
PlayerLoop
├─ Script Update
├─ Physics
├─ Animation
└─ Rendering 준비

Render Thread
Graphics API 제출

Worker Threads
Culling과 Job 작업 일부
```

GPU Profiler에서는 Shadow, Opaque, Transparent, Post-processing 등 GPU Event의 시간을 확인할 수 있다.

Frame Timing Manager는 CPU Frame, Main Thread, Render Thread, Present Wait와 GPU Frame Time을 큰 범위로 비교하는 데 사용할 수 있다.

---

## Stats 창만으로 충분하지 않은 이유

Game View Stats는 Batches, SetPass Call과 Triangle 같은 요약 값을 보여 준다.

하지만 숫자 하나만으로 병목을 확정할 수 없다.

```text
같은 Batches 수
Scene A: 작은 Object, 단순 Shader
Scene B: 화면 전체 Object, 복잡한 Shader

GPU 비용은 다를 수 있음
```

```text
같은 Triangle 수
Scene A: 한 번만 렌더링
Scene B: Shadow와 여러 Camera에서 반복 렌더링

전체 작업은 다를 수 있음
```

요약 Counter는 문제 후보를 찾는 출발점으로 사용하고 Timeline과 Capture로 원인을 확인해야 한다.

---

## 한 Frame을 추적하는 예

다음 Scene을 가정한다.

```text
Main Camera 1개
Directional Light 1개
Opaque Character 1개
Transparent Particle 1개
Bloom On
```

개념적인 Frame은 다음과 같이 진행될 수 있다.

```text
1. Input 처리
2. Character Script Update
3. Physics와 Animation 갱신
4. Camera LateUpdate
5. Camera Culling
6. Visible Character와 Particle 수집
7. Shadow Caster 수집
8. Shadow Map Render Pass
9. Character ShadowCaster Pass Draw
10. Opaque Render Pass
11. Character Forward Pass Draw
12. Transparent Render Pass
13. Particle Draw
14. Bloom 처리
15. Final Color를 Backbuffer로 출력
16. Present
```

Character 하나도 Shadow와 Camera Color에서 두 번 이상 처리될 수 있다.

Bloom은 화면에 보이는 별도 GameObject가 없어도 추가 GPU Pass를 만든다.

---

## Frame마다 반드시 같은 작업을 하는가?

Scene과 Rendering 상태가 변하면 Frame의 작업도 달라진다.

```text
Camera가 이동
→ Visible Renderer와 LOD 변화

Light Shadow 활성화
→ Shadow Pass 추가

Particle 증가
→ Transparent Draw와 Overdraw 증가

Post Effect Volume 진입
→ Effect Pass 변경

새 Shader Variant 첫 사용
→ Program 준비 Hitch 가능
```

평균적인 빈 Scene만 측정하면 실제 Gameplay의 Worst Case를 놓칠 수 있다.

전투, 빠른 Camera 이동, 많은 Effect와 Scene Streaming 시점을 따로 측정해야 한다.

---

## 한 Frame의 최적화 순서

전체 Frame이 느릴 때 가장 먼저 CPU와 GPU 중 어느 쪽이 Frame Rate를 제한하는지 구분한다.

```text
Frame Time 문제
↓
CPU / GPU / Present Limited 구분
↓
긴 Thread 또는 GPU Pass 식별
↓
해당 단계의 원인 조사
↓
한 가지 변경
↓
동일 조건에서 재측정
```

CPU Bound라면 Script, Physics, Animation, Culling, Batch와 Draw 제출을 조사한다.

GPU Bound라면 Shadow, Geometry, Pixel Coverage, Shader, Transparency, Post-processing와 Bandwidth를 조사한다.

Present Limited라면 목표 Frame Rate를 이미 만족하는 정상 대기인지 먼저 확인한다.

---

## Culling 최적화의 기준

Culling은 보이지 않는 Draw를 줄이지만 자체 계산 비용도 가진다.

```text
너무 넓은 Bounds
→ 실제로 안 보여도 Culling 통과 가능

너무 많은 작은 Renderer
→ Culling 대상 수 증가

Occlusion Culling
→ 가려진 Object 제거 가능
→ Data와 Runtime Test 비용 존재
```

Static한 실내 Scene과 넓게 열린 야외 Scene은 적합한 Culling 전략이 다를 수 있다.

Camera별 Layer와 Distance를 정확히 설정하고 실제 Rendered Object 수와 CPU Culling 시간을 함께 확인한다.

---

## Rendering 최적화의 기준

Rendering 단계에서는 작업을 줄이는 위치가 병목에 맞아야 한다.

```text
CPU Draw 제출 병목
→ Batching, Instancing, Renderer 수와 State 변경 조사

Vertex 병목
→ Geometry, Skinning, Shadow와 반복 Pass 조사

Fragment 병목
→ 해상도, Overdraw, Shader와 Post Effect 조사

Bandwidth 병목
→ Render Target 수, Format, Resolve와 Blit 조사
```

Draw Call을 줄였지만 더 복잡한 Shader와 큰 Buffer를 사용해 GPU 비용이 늘 수도 있다.

하나의 Counter를 목표로 삼기보다 Frame Time을 줄이는 변경인지 확인해야 한다.

---

## Present 최적화의 기준

Present 대기는 원인에 따라 대응이 다르다.

```text
VSync 대기
목표 Refresh에 맞춘 정상 대기일 수 있음

GPU 완료 대기
앞선 GPU 작업을 줄여야 할 수 있음

Frame Queue와 Latency
Platform별 Frame Pacing 설정 확인
```

VSync를 끄고 숫자가 줄었다는 사실만으로 Production 설정이 더 좋아졌다고 결론 내리면 안 된다.

Tearing, Power 사용, 발열, Input Latency와 Frame Pacing을 함께 고려해야 한다.

---

## 자주 혼동하는 내용

### Update가 끝나면 해당 Frame이 화면에 즉시 보인다?

아니다.

이후 Rendering 준비, GPU 실행, Present와 Display Scanout이 남아 있다.

### Culling을 통과한 Object는 모든 Pixel이 그려진다?

아니다.

GPU에서 Back-face Culling, Depth, Stencil과 Alpha Clip 등으로 Primitive와 Fragment가 추가 제거될 수 있다.

### CPU Rendering과 GPU Rendering은 같은 시간 구간이다?

아니다.

CPU는 Command를 준비하고 GPU는 Queue에 제출된 작업을 실행하며 서로 다른 Frame 작업이 겹칠 수 있다.

### Present Wait가 길면 GPU가 느리다?

항상 그렇지 않다.

VSync나 목표 Frame Rate를 만족해 기다리는 정상적인 상태일 수도 있다.

### Camera 하나는 Draw 한 번을 만든다?

아니다.

한 Camera 안에서도 Shadow, Depth, Opaque, Transparent와 Post-processing을 위한 많은 Draw와 Pass가 실행된다.

### Frame Debugger Event 수가 곧 GPU 시간인가?

아니다.

Event의 종류, Pixel Coverage, Shader와 Memory 접근에 따라 각 비용이 다르다.

---

## 전체 흐름 다시 연결하기

Unity 한 Frame의 핵심 흐름은 다음과 같다.

```text
Player Loop 시작
│
├─ Input / Script / Physics / Animation
│  └─ 현재 Scene State 결정
│
├─ Camera Loop
│  ├─ Culling Parameter
│  ├─ Culling
│  ├─ Rendering Data
│  ├─ Render Pass Queue
│  └─ Render Pass 실행
│     ├─ Shadow
│     ├─ Depth
│     ├─ Opaque
│     ├─ Skybox
│     ├─ Transparent
│     └─ Post-processing
│
├─ Graphics Command 제출
│
├─ GPU Pipeline 실행
│  └─ Render Target 완성
│
└─ Present
   └─ Display에 Frame 전달
```

여러 Camera가 있으면 Camera Loop가 반복되고 CPU와 GPU는 가능한 범위에서 서로 다른 Frame의 작업을 겹쳐 수행한다.

---

## 정리

Unity Application은 Player Loop를 반복하며 Input, Script, Physics와 Animation으로 현재 Frame의 Scene 상태를 갱신한다.

Rendering 단계에서는 Camera마다 Culling Parameter를 만들고 Visible Renderer, Light와 Shadow Caster를 계산한다.

URP는 Culling 결과에 URP Asset, Camera, Quality와 Platform 설정을 결합해 Rendering Data를 구성하고 필요한 Render Pass를 Queue에 배치한다.

```text
Game State
↓
Culling
↓
Rendering Data
↓
Render Pass
↓
Draw Command
↓
GPU
↓
Present
```

GPU는 Shadow, Depth, Opaque, Transparent와 Post-processing Command를 실행해 최종 Render Target을 만든다.

Present는 완성된 Image를 Display System에 전달하며 VSync와 목표 Frame Rate 때문에 CPU가 대기할 수도 있다.

CPU의 Frame 준비, GPU의 Rendering 완료와 Display의 화면 표시는 서로 다른 시점이며 여러 Frame의 작업이 겹칠 수 있다.

한 Frame의 병목을 찾을 때는 CPU, GPU와 Present Limited 상태를 먼저 구분하고 Frame Debugger, CPU·GPU Profiler와 목표 Device의 Frame Timing을 함께 확인해야 한다.
