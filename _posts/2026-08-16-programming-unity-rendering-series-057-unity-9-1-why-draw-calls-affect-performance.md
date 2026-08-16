---
title: "[Unity 렌더링] 9-1. Draw Call은 왜 성능에 영향을 줄까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - DrawCall
  - RenderState
  - Optimization
permalink: /programming/unity-9-1-why-draw-calls-affect-performance/
toc: true
toc_sticky: true
date: 2026-08-16
last_modified_at: 2026-08-16
---

Draw Call은 CPU가 GPU에 어떤 Geometry를 어떤 상태로 그릴지 명령하는 작업이다.

```text
CPU
├─ Render State 준비
├─ Shader·Texture·Buffer 연결
└─ Draw Command 제출
        │
        ▼
GPU
└─ Vertex·Rasterization·Fragment 처리
```

Object 하나의 Draw Call은 작아 보일 수 있지만 수천 번 반복되면 CPU의 준비와 제출 비용이 누적된다.

Draw Call 최적화는 Triangle을 그리는 GPU 계산만의 문제가 아니라 CPU와 Graphics API가 GPU 작업을 구성하는 비용을 줄이는 작업이다.

---

## CPU와 GPU는 역할이 다르다

CPU는 Scene, Component와 Rendering 상태를 관리하고 GPU는 대량의 Vertex와 Pixel 계산을 병렬로 수행한다.

```text
CPU 역할
├─ Camera Culling
├─ Renderer 정렬
├─ Shader Pass 선택
├─ Resource Binding
└─ GPU Command 생성

GPU 역할
├─ Vertex Shader
├─ Rasterization
├─ Fragment Shader
├─ Depth / Blend
└─ Render Target Write
```

GPU는 Scene의 GameObject 구조를 스스로 해석하지 않는다.

CPU가 Graphics API 명령으로 필요한 상태와 작업 범위를 전달해야 한다.

Draw Call은 이 두 Processor 사이의 작업 단위 중 하나다.

---

## Draw Call에 들어가는 정보

단순하게는 다음 정보가 GPU Command에 필요하다.

```text
Draw
├─ 어떤 Vertex / Index Buffer인가?
├─ 어느 Index 범위를 그리는가?
├─ 어떤 Shader Pass인가?
├─ 어떤 Texture와 Sampler를 사용하는가?
├─ 어떤 Constant Buffer인가?
├─ 어떤 Render Target인가?
├─ Depth Test는 무엇인가?
├─ Blend Mode는 무엇인가?
└─ 몇 개의 Instance를 그리는가?
```

Graphics API와 Render Pipeline에 따라 실제 Command와 Binding 구조는 다르다.

중요한 점은 `Mesh를 그려라`라는 한 문장보다 많은 상태가 함께 준비된다는 것이다.

---

## Unity가 Mesh 하나를 그리는 기본 흐름

Unity 공식 문서는 기본적으로 각 Mesh에 자체 Draw Call이 필요하다고 설명한다.

```text
Renderer 수집
    │
    ▼
Visibility 판정
    │
    ▼
Render Queue와 State 기준 정렬
    │
    ▼
Render State Update
    │
    ▼
Draw Call Submit
```

같은 Cube Prefab을 100개 배치해도 아무 최적화가 없다면 CPU는 각 Renderer를 별도 작업으로 준비할 수 있다.

```text
Cube 0 → Draw
Cube 1 → Draw
Cube 2 → Draw
...
Cube 99 → Draw
```

이 반복 비용이 Draw Call 최적화의 출발점이다.

---

## Render State란 무엇일까?

Render State는 GPU가 다음 Draw를 처리하는 방법을 결정하는 상태의 집합이다.

```text
Render State
├─ Shader Program / Pass
├─ Material Parameter
├─ Texture와 Sampler
├─ Vertex Layout
├─ Depth Test / Depth Write
├─ Blend Mode
├─ Cull Mode
├─ Render Target
└─ Keyword와 Pipeline State
```

Opaque Lit Material과 Transparent Particle Material은 Shader, Blend와 Depth 상태가 다르다.

GPU가 다음 Draw를 올바르게 처리하려면 CPU가 필요한 상태를 바꾸고 Resource를 Bind해야 한다.

---

## State 변경이 비싼 이유

Unity 공식 문서는 Draw Call 과정 중 Render State를 갱신하는 단계를 가장 CPU 집약적인 부분으로 설명한다.

```text
Material A Draw
├─ Shader A Bind
├─ Texture A Bind
└─ Draw

Material B Draw
├─ Shader B Bind
├─ Texture B Bind
├─ Blend State 변경
└─ Draw
```

State가 바뀌면 Driver와 Graphics API는 다음 작업을 수행할 수 있다.

- Pipeline State 확인과 전환
- Shader와 Resource Binding
- Constant Buffer 갱신
- Command Validation
- Dependency와 Barrier 처리
- Driver 내부 Command 구성

세부 비용은 Graphics API, Driver와 Platform에 따라 달라진다.

Draw Call 수뿐 아니라 얼마나 자주 비싼 State를 바꾸는지도 중요하다.

---

## 같은 Material을 연속으로 그리는 경우

같은 Render State를 사용하는 Object가 연속되면 일부 상태를 재사용할 수 있다.

```text
Object A: Material X
Object B: Material X
Object C: Material X

Shader X / Texture X Bind
├─ Draw A
├─ Object Data 변경 → Draw B
└─ Object Data 변경 → Draw C
```

Draw Call은 세 번일 수 있지만 Shader와 Texture를 매번 완전히 다시 바꾸지 않아도 된다.

반대로 Material이 계속 교차하면 상태 전환이 늘어난다.

```text
A → B → A → B → A → B
```

Unity가 Render Queue와 State를 기준으로 정렬하는 이유 중 하나다.

---

## Object마다 다른 Transform도 Data다

같은 Mesh와 Material을 사용해도 Object Position, Rotation과 Scale은 다르다.

```text
Cube A
ObjectToWorld = Matrix A

Cube B
ObjectToWorld = Matrix B
```

각 Draw 전에 Object별 Matrix와 Lighting 관련 Data를 GPU에 전달하거나 참조 위치를 바꿔야 한다.

```text
Bind Shared Mesh / Material
Update Object Data A → Draw
Update Object Data B → Draw
Update Object Data C → Draw
```

같은 Material이라는 조건만으로 여러 Object가 자동으로 하나의 Draw가 되는 것은 아니다.

---

## SubMesh와 Material

하나의 Mesh도 여러 SubMesh와 Material Slot을 가지면 여러 Draw Call이 필요할 수 있다.

```text
Character Mesh
├─ SubMesh 0: Body Material  → Draw 1
├─ SubMesh 1: Hair Material  → Draw 2
├─ SubMesh 2: Eye Material   → Draw 3
└─ SubMesh 3: Cloth Material → Draw 4
```

GameObject 수가 하나라고 Draw Call도 하나라고 단정할 수 없다.

Material Slot 수, Shader Pass와 현재 Rendering 경로까지 봐야 한다.

사용하지 않는 Material Slot이나 불필요하게 분리된 SubMesh가 없는지 확인한다.

---

## Shader Pass가 Draw를 반복한다

Shader는 목적에 따라 여러 Pass를 가질 수 있다.

```text
Mesh
├─ DepthOnly Pass
├─ ShadowCaster Pass
├─ ForwardLit Pass
├─ DepthNormals Pass
└─ Meta Pass
```

모든 Pass가 매 Frame 실행되는 것은 아니지만 Pipeline 설정에 따라 같은 Renderer가 여러 Rendering Pass에서 다시 그려질 수 있다.

```text
Camera Depth Prepass → Draw
Main Color Pass      → Draw
ShadowCaster Pass    → Draw
```

화면에 Object가 한 번 보인다고 GPU Command도 한 번만 생기는 것은 아니다.

---

## Light와 Shadow도 Draw Call을 늘린다

Shadow Map은 Light 관점에서 Caster를 다시 Rendering한다.

```text
Mesh A
├─ Camera Color Draw
├─ Main Light Cascade 0 Shadow Draw
├─ Main Light Cascade 1 Shadow Draw
└─ Additional Spot Shadow Draw
```

Point Light Shadow는 여섯 Face가 필요하고 Directional Cascade는 거리 구간마다 Shadow View를 가진다.

Scene View의 `Batches`가 예상보다 큰 경우 Camera Color Pass뿐 아니라 Shadow, Depth와 Renderer Feature Pass를 함께 확인해야 한다.

---

## Draw Call과 Triangle은 다른 비용이다

Draw Call은 CPU가 GPU 작업을 제출하는 단위이고 Triangle은 GPU가 처리할 Geometry 양과 관련된다.

```text
Case A
Draw Call 1개
Triangle 1,000,000개
→ GPU Geometry 병목 가능

Case B
Draw Call 10,000개
각 Triangle 2개
→ CPU 제출 병목 가능
```

Draw Call을 줄여도 한 Draw가 지나치게 많은 Triangle과 Pixel을 처리하면 GPU 병목은 남는다.

Triangle을 줄여도 Renderer가 수천 개로 분리되어 있으면 CPU 병목은 남을 수 있다.

서로 다른 축의 비용으로 측정해야 한다.

---

## Draw Call과 Pixel 비용도 다르다

한 번의 Fullscreen Draw는 Draw Call 수는 하나지만 수백만 Pixel에서 비싼 Shader를 실행할 수 있다.

```text
3840 × 2160
≈ 8.3 Million Pixels
```

반대로 화면에 작은 Icon 100개는 Pixel 수는 작아도 여러 Material과 Draw를 만들 수 있다.

```text
낮은 Draw Call ≠ 항상 빠른 GPU
높은 Draw Call ≠ 항상 느린 GPU
```

Draw Call 수는 CPU 제출 비용을 이해하는 중요한 지표지만 전체 Rendering 비용을 대표하는 단일 점수는 아니다.

---

## Command Buffer의 관점

현대 Graphics API에서는 CPU가 GPU가 실행할 Command를 Buffer에 기록한다.

```text
CPU Timeline
┌────────────────────────────────────┐
│ Set Pipeline │ Bind │ Draw │ Draw │
└────────────────────────────────────┘
                  │ Submit
                  ▼
GPU Queue
┌────────────────────────────────────┐
│ Execute Commands                   │
└────────────────────────────────────┘
```

CPU는 GPU가 실행할 일을 미리 준비할 수 있고 GPU는 이전 Command를 처리할 수 있다.

하지만 CPU가 Command를 충분히 빠르게 생성하지 못하면 GPU Queue가 비게 된다.

이를 CPU가 GPU에 일을 공급하지 못하는 상태로 볼 수 있다.

---

## CPU가 병목일 때의 Frame 흐름

```text
CPU: [Culling][State][Draw][State][Draw][Draw][State]────
GPU:          [Work][Work]   [Idle]     [Work]      [Idle]
```

Draw Command 준비가 느리면 GPU가 처리 능력을 남긴 채 기다릴 수 있다.

화면 해상도나 Shader 품질을 낮춰도 Frame Rate가 거의 오르지 않을 수 있다.

이 경우 Renderer 수, State 변경과 Draw 제출 비용을 줄이는 방향이 필요하다.

---

## GPU가 병목일 때의 Frame 흐름

```text
CPU: [Commands]──[Wait / Next Frame Prep]
GPU:       [Vertex][Raster][Fragment][Post Process]──────
```

CPU가 Command를 빨리 준비해도 GPU 계산이 오래 걸리면 Draw Call 감소 효과가 제한적일 수 있다.

다음 원인이 있을 수 있다.

- 높은 해상도와 Overdraw
- 비싼 Fragment Shader
- 많은 Triangle
- 높은 Shadow Resolution
- Post-processing
- Memory Bandwidth

Draw Call 최적화와 GPU Shader 최적화를 구분해야 한다.

---

## Main Thread와 Render Thread

Unity의 Rendering 작업은 Main Thread와 Render Thread에 나뉠 수 있다.

```text
Main Thread
├─ Scene Update
├─ Culling 요청과 Renderer Data 준비
└─ Rendering 시스템 작업

Render Thread
├─ Graphics API Command 구성
├─ State와 Resource 처리
└─ GPU 제출
```

Graphics Jobs와 Platform에 따라 세부 Thread 구조는 달라질 수 있다.

Draw Call이 많으면 Main Thread만이 아니라 Render Thread 시간이 커질 수 있다.

Profiler에서 `PlayerLoop` 하나만 보지 말고 Rendering 관련 Thread와 GPU Wait Marker를 함께 확인한다.

---

## Graphics API와 Driver 비용

같은 Draw Call 수도 Platform과 Graphics API에 따라 CPU 비용이 다를 수 있다.

```text
Legacy API
└─ Driver가 많은 Validation과 State 관리 수행 가능

Modern Explicit API
└─ Application과 Engine이 더 명시적으로 Command 구성
```

Direct3D, Vulkan, Metal과 Console API는 Command Submission Model이 다르다.

Driver, Hardware와 Unity Version도 결과에 영향을 준다.

다른 Project에서 얻은 `Draw Call 몇 개까지 안전하다`는 숫자를 그대로 적용할 수 없는 이유다.

---

## Draw Call 한계에 고정 숫자가 없는 이유

허용 가능한 Draw Call 수는 다음 조건에 따라 달라진다.

| 조건 | 영향 |
| --- | --- |
| CPU 성능 | Command 준비와 제출 속도 |
| Graphics API | Driver와 Validation 비용 |
| Render State 변화 | Draw당 준비 비용 |
| Shader Pass | Renderer 반복 횟수 |
| Shadow와 Camera | 추가 View와 Pass |
| Batching 방식 | State와 Mesh Data 처리 구조 |
| 목표 FPS | 허용 Frame Time |

Mobile CPU와 Desktop CPU가 같은 수를 처리하는 시간은 다르다.

30 FPS Project와 120 FPS Project도 같은 기준을 사용할 수 없다.

목표 Device에서 Frame Time으로 판단해야 한다.

---

## Draw Call, Batch, SetPass Call

Unity Rendering 통계에는 비슷해 보이는 여러 값이 있다.

| 지표 | 의미 |
| --- | --- |
| Draw Calls | Frame에 Unity가 발행한 전체 Draw Call |
| Batches | Unity가 처리한 Rendering Batch 수 |
| SetPass Calls | 다른 Shader Pass로 전환한 횟수 |

Unity 공식 Profiler 문서에서 `SetPass Calls`는 Unity가 GameObject를 그릴 Shader Pass를 전환한 횟수로 설명된다.

`Draw Calls`, `Batches`와 `SetPass Calls`는 서로 같은 숫자일 필요가 없다.

---

## SetPass Call이 중요한 이유

Shader Pass 전환은 Pipeline State 변경과 관련된 무거운 작업이 될 수 있다.

```text
Pass A
├─ Draw Object 1
├─ Draw Object 2
└─ Draw Object 3

SetPass → Pass B
├─ Draw Object 4
└─ Draw Object 5
```

위 예시는 Draw가 다섯 번이지만 Pass 전환은 더 적을 수 있다.

같은 Pass의 Draw를 연속 배치하면 비싼 State 변경을 줄일 수 있다.

따라서 Draw Call 숫자만 보고 SetPass Call과 Material·Shader 다양성을 무시하면 병목을 잘못 해석할 수 있다.

---

## Batch는 무엇을 의미할까?

Batch는 Unity가 같은 Rendering 상태나 최적화 조건을 기준으로 묶어 처리하는 단위다.

```text
여러 Renderer
        │
        ▼
Compatibility 판단
        │
        ▼
Batch 또는 효율적인 연속 Draw
```

Batching 방식에 따라 여러 Mesh를 합치거나 Instance를 한 번에 그리거나 State Update를 줄일 수 있다.

모든 Batching 기법이 정확히 같은 방식으로 Draw Call을 줄이는 것은 아니다.

Batching이 필요한 이유와 큰 분류는 다음 글에서 이어서 다룬다.

---

## SRP Batcher 수치를 오해하면 안 된다

SRP Batcher의 핵심 목표는 호환되는 Shader Variant 사이에서 CPU의 Render State와 Material Data 준비 비용을 줄이는 것이다.

```text
SRP Batcher
├─ 동일 Shader Variant의 연속 처리 효율화
├─ Material Data를 GPU Buffer에 유지
└─ Draw Call 자체가 남을 수 있음
```

Draw Call 수가 크게 줄지 않아도 CPU Rendering 시간이 개선될 수 있다.

즉 `Draw Call 수 감소`와 `Draw Call당 CPU 비용 감소`는 다른 최적화다.

SRP Batcher의 구체적인 구조는 이후 글에서 별도로 다룬다.

---

## GPU Instancing도 구분해야 한다

GPU Instancing은 같은 Mesh와 Material의 여러 Instance를 하나의 Instanced Draw로 처리할 수 있다.

```text
Draw Mesh
├─ Instance 0 Transform
├─ Instance 1 Transform
├─ Instance 2 Transform
└─ ...
```

이는 동일한 Geometry를 반복 배치하는 Scene에서 효과적이다.

반면 서로 다른 Mesh, Shader와 Render State를 무조건 하나로 묶지는 못한다.

조건과 Data 전달 방식은 GPU Instancing 글에서 구체적으로 다룬다.

---

## Material이 많으면 Draw가 나뉘는 이유

Material은 Shader뿐 아니라 Texture, Parameter와 Keyword 조합을 가진다.

```text
Material A
├─ Shader Lit
├─ BaseMap Brick
└─ Keyword NormalMap On

Material B
├─ Shader Lit
├─ BaseMap Metal
└─ Keyword NormalMap Off
```

Shader 이름이 같아도 Material Resource와 Variant가 다르면 상태와 Data를 바꿔야 한다.

Material Instance를 Renderer마다 복제하면 동일하게 보이는 Object도 별도 상태로 취급될 수 있다.

Material 수와 Draw Call의 자세한 관계는 이후 글에서 별도로 다룬다.

---

## Sorting의 Trade-off

Opaque Object는 Front-to-Back과 State 유사성을 고려해 정렬할 수 있다.

```text
State 기준 정렬
→ SetPass 감소 가능

Front-to-Back 정렬
→ Early-Z로 Fragment 작업 감소 가능
```

두 목표가 항상 같은 순서를 만들지는 않는다.

Transparent Object는 Blend 결과 때문에 일반적으로 Back-to-Front 순서가 중요해 자유로운 State 정렬이 어렵다.

Draw Call 최적화는 CPU State 비용과 GPU Overdraw 사이의 균형도 고려해야 한다.

---

## UI에서 Draw Call이 늘어나는 예

UI Element가 많아도 같은 Atlas와 Material을 사용하면 묶일 가능성이 있다.

하지만 중간에 다른 Material, Mask와 Texture가 들어가면 Batch가 끊길 수 있다.

```text
Image Atlas A
Text Material B
Image Atlas A

→ A / B / A로 Batch 분리 가능
```

Canvas 갱신 비용, Geometry Rebuild와 Overdraw는 Draw Call과 별도의 UI 비용이다.

UI의 Batches가 낮다고 전체 UI가 반드시 저렴한 것은 아니다.

---

## Particle에서 Draw Call이 늘어나는 예

하나의 Particle System은 많은 Particle을 하나의 Mesh Stream으로 그릴 수 있다.

하지만 Material, Texture, Render Mode와 Sorting 조건이 다른 Particle System은 별도 Draw가 필요하다.

```text
Fire Material    → Draw
Smoke Material   → Draw
Spark Material   → Draw
Distortion Pass  → Additional Draw
```

Particle은 Draw Call뿐 아니라 Transparent Overdraw와 Fill-rate가 더 큰 병목일 수 있다.

수치 하나로 원인을 단정하지 않는다.

---

## Terrain과 많은 Prop

Terrain Detail, Tree와 작은 Prop가 Renderer 단위로 분리되면 CPU Culling과 Draw 준비가 커질 수 있다.

```text
Outdoor Scene
├─ Terrain Patches
├─ Trees
├─ Grass
├─ Rocks
├─ Buildings
└─ Shadow Pass 반복
```

LOD, GPU Instancing, 적절한 Mesh 결합과 Culling Cell을 함께 고려한다.

모든 Mesh를 하나로 합치면 Draw는 줄지만 Camera 밖 Object까지 함께 그려 Culling 효율이 낮아질 수 있다.

Draw 감소와 불필요한 GPU 작업 증가 사이의 Trade-off가 있다.

---

## Mesh를 크게 합치면 항상 좋을까?

```text
작은 Mesh 100개
├─ Draw 많음
└─ 개별 Culling 가능

큰 Mesh 1개
├─ Draw 적음
└─ 일부만 보여도 전체 Geometry Rendering 가능
```

Mesh 결합은 CPU 제출 비용을 줄일 수 있지만 다음 비용을 만들 수 있다.

- Culling Granularity 저하
- 큰 Combined Buffer Memory
- Object별 LOD와 Animation 제한
- Lightmap과 Material 조건
- 일부만 바뀌어도 전체 Data 관리 부담

Scene의 공간 구조에 맞는 크기로 묶어야 한다.

---

## Draw Call을 줄여도 성능이 그대로인 경우

다음 상황에서는 수치 감소가 Frame Time 개선으로 이어지지 않을 수 있다.

```text
GPU Fragment Bound
→ Draw 감소 후에도 Pixel Shader 시간이 지배

Memory Bandwidth Bound
→ Texture와 Render Target Traffic이 지배

Physics / Script CPU Bound
→ Rendering Thread가 병목 아님

VSync / Frame Cap
→ 여유 성능이 FPS에 표시되지 않음
```

Draw Call이 2000에서 1000으로 줄었다는 사실보다 CPU·GPU Frame Time이 몇 ms 변했는지가 중요하다.

---

## Draw Call이 늘어도 더 빨라질 수 있는 경우

최적화 과정에서 Draw Call 수가 조금 늘어도 전체 Frame이 빨라질 수 있다.

예를 들어 큰 Mesh를 작은 Cell로 나누면 개별 Culling이 가능해진다.

```text
Before
Draw 1개, Triangle 2M 항상 Rendering

After
Draw 20개, 보이는 Cell Triangle 200k만 Rendering
```

CPU Draw 비용은 늘지만 GPU Geometry와 Pixel 비용이 크게 줄 수 있다.

또한 Depth Prepass는 Draw를 추가하지만 복잡한 Opaque Scene의 Overdraw를 줄일 수 있다.

전체 Pipeline 비용을 기준으로 판단해야 한다.

---

## Unity Profiler에서 확인할 값

Rendering Profiler Module은 Frame의 Rendering 통계를 제공한다.

```text
확인 항목
├─ Batches Count
├─ SetPass Calls Count
├─ Draw Calls
├─ Triangles
├─ Vertices
└─ CPU Rendering Marker
```

Unity 공식 문서에 따르면 Draw Calls에는 Batched되지 않은 Draw와 Static·Dynamic Batched Draw가 포함된다.

Batches와 SetPass Calls는 서로 다른 작업을 나타내므로 함께 비교한다.

Profiler Marker 이름과 Thread 구조는 Unity Version과 Platform에 따라 달라질 수 있다.

---

## Stats 창의 한계

Game View의 Stats는 빠르게 상태를 확인하는 데 유용하다.

```text
Game View Stats
├─ Batches
├─ Saved by batching
├─ Tris / Verts
└─ SetPass Calls
```

하지만 수치만으로 어느 Renderer와 Pass가 원인인지 알기 어렵다.

Editor Rendering과 Scene View가 영향을 줄 수 있으며 Target Device의 CPU 시간도 보여 주지 못한다.

Stats는 경향 확인에 사용하고 Profiler와 Frame Debugger로 원인을 추적한다.

---

## Frame Debugger에서 확인할 것

Frame Debugger는 한 Frame의 Rendering Event를 순서대로 보여 준다.

```text
Frame Events
├─ Shadow Pass
├─ Depth Prepass
├─ Opaque Draws
├─ Skybox
├─ Transparent Draws
├─ Post-processing
└─ UI
```

개별 Event에서 다음을 확인한다.

- 어떤 Mesh와 Material이 Draw를 만들었는가?
- 왜 앞 Draw와 Batch되지 않았는가?
- Shader Pass와 Keyword가 달라졌는가?
- Shadow와 Depth Pass에서 반복되는가?
- Renderer Feature가 추가 Pass를 만들었는가?

Draw Call 숫자를 실제 원인 Object와 연결하는 데 유용하다.

---

## SRP Batcher Profiler와 GPU Capture

URP에서는 SRP Batcher가 호환 Draw의 CPU State 설정을 줄이는 데 도움을 줄 수 있다.

SRP Batcher 관련 도구로 Batch가 끊기는 Shader Variant와 상태 변경 원인을 확인할 수 있다.

RenderDoc, Xcode GPU Tools와 Vendor Profiler는 실제 GPU Command와 Pass 시간을 더 자세히 보여 준다.

```text
Unity Profiler
→ CPU·GPU Frame 흐름

Frame Debugger
→ Unity Rendering Event와 Material

GPU Capture
→ 실제 GPU Pass, State, Resource와 Timing
```

목적에 따라 도구를 나누어 사용한다.

---

## 정확한 비교 방법

Draw Call 최적화 전후에는 같은 조건을 유지한다.

- 동일한 Camera 위치와 이동 경로
- 동일한 Resolution과 Quality Level
- 동일한 Light와 Shadow 설정
- 동일한 Object 수와 Animation 상태
- 동일한 Graphics API
- Development Build의 동일한 Profiler 옵션
- VSync와 Frame Cap 조건 통일

```text
Baseline
CPU Render Thread: 8.0 ms
GPU Frame         : 10.0 ms
Batches           : 3000
SetPass Calls     : 800

After
CPU Render Thread: 5.2 ms
GPU Frame         : 9.8 ms
Batches           : 1500
SetPass Calls     : 250
```

예시처럼 수치 변화와 실제 ms를 함께 기록한다.

---

## 최적화 우선순위

```text
1. CPU·GPU 병목 판별
2. Frame Debugger로 반복 Pass와 Draw 원인 확인
3. 불필요한 Camera·Shadow·Renderer Pass 제거
4. Material·Shader State 전환 확인
5. 적합한 Batching 또는 Instancing 선택
6. Culling과 Mesh 결합 Trade-off 검증
7. Target Device에서 재측정
```

단순히 가장 큰 Mesh부터 합치기보다 어떤 Render State와 Pass가 Draw를 나누는지 먼저 확인한다.

Batching 기법은 Object가 움직이는지, Mesh가 같은지, Material이 호환되는지에 따라 선택이 달라진다.

---

## 흔한 오해

### GameObject 하나는 Draw Call 하나다

SubMesh, Material, Shader Pass, Shadow와 Depth Pass에 따라 여러 Draw가 발생할 수 있다.

### Draw Call은 GPU만의 비용이다

핵심 부담 중 하나는 CPU가 Render State를 준비하고 Graphics API Command를 제출하는 비용이다.

### Draw Call 수가 절반이면 Rendering 시간도 절반이다

State 변화, Triangle, Pixel, Shader와 현재 병목에 따라 Frame Time 변화는 다르다.

### SetPass Calls와 Draw Calls는 같은 값이다

SetPass는 Shader Pass 전환 횟수이고 Draw Calls는 발행한 Drawing Command의 총수다.

### 같은 Material이면 자동으로 한 Draw다

Object별 Transform과 Mesh가 다르며 Batching·Instancing 조건을 만족해야 한 Draw로 결합될 수 있다.

### SRP Batcher는 모든 Draw를 하나로 합친다

SRP Batcher는 주로 호환되는 Draw 사이의 CPU State와 Data 설정 비용을 줄이며 Draw Call 자체는 남을 수 있다.

### Mesh를 전부 합치면 가장 빠르다

Culling Granularity와 LOD가 나빠져 GPU가 불필요한 Geometry와 Pixel을 처리할 수 있다.

### Batches가 낮으면 Rendering은 최적화됐다

한 Batch 안에서도 많은 Triangle, Overdraw와 비싼 Shader가 GPU 병목을 만들 수 있다.

### PC에서 괜찮으면 Mobile도 괜찮다

CPU, Driver, Graphics API와 목표 FPS가 다르므로 허용 가능한 수치도 달라진다.

---

## 정리

Draw Call은 CPU가 GPU에 어떤 Geometry를 어떤 Render State로 그릴지 제출하는 작업이다.

CPU는 Shader, Texture, Buffer, Depth와 Blend 상태를 준비하고 Graphics API Command를 구성하며 이 과정이 Draw마다 누적된다.

State 변경은 특히 CPU 집약적일 수 있어 Draw Call 수뿐 아니라 Shader Pass와 Material 전환 순서도 중요하다.

GameObject 하나도 SubMesh, Material, Depth, Shadow와 여러 Shader Pass 때문에 여러 번 Drawing될 수 있다.

Draw Call은 Triangle과 Pixel 비용과 다른 축이며 낮은 Draw Call 수가 항상 낮은 GPU Frame Time을 의미하지 않는다.

Unity의 `Draw Calls`, `Batches`, `SetPass Calls`는 서로 다른 지표이므로 Rendering Profiler와 Frame Debugger에서 함께 확인해야 한다.

CPU Rendering 병목일 때 Draw와 State 준비를 줄이는 효과가 크고 GPU Fragment나 Geometry가 병목이면 다른 최적화가 먼저 필요할 수 있다.

최종 기준은 고정된 Draw Call 개수가 아니라 Target Device에서 측정한 Main·Render Thread와 GPU Frame Time이다.
