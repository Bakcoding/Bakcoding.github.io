---
title: "[Unity 렌더링] 5-4. Unity에서 Draw Call은 언제 발생할까?"
excerpt: "Unity Rendering"
categories:
  - Programming
tags:
  - Unity
  - Rendering
  - DrawCall
  - Batching
  - GPUInstancing
permalink: /programming/unity-5-4-draw-call/
toc: true
toc_sticky: true
date: 2026-08-15
last_modified_at: 2026-08-15
---

Scene에 Cube 하나를 배치하면 GPU는 Cube라는 GameObject를 직접 이해하지 않는다.

Unity는 Cube의 Mesh, SubMesh, Material, Transform과 Shader Pass를 확인하고 Graphics API가 처리할 수 있는 Drawing Command를 준비해야 한다.

이때 GPU에 Geometry Rendering을 요청하는 호출이 Draw Call이다.

```text
Renderer
+ Mesh와 SubMesh
+ Material
+ Shader Pass
+ Transform과 Resource
↓
Draw Command 준비
↓
Graphics API에 제출
↓
GPU가 Geometry 처리
```

Renderer 하나가 항상 Draw Call 하나를 만드는 것은 아니다.

한 Renderer가 여러 번 Draw될 수도 있고 여러 Renderer가 하나의 Draw로 묶일 수도 있다.

---

## Draw Call이란?

Draw Call은 CPU가 GPU에 특정 Geometry를 현재 Rendering State와 Resource로 그리도록 요청하는 작업이다.

Graphics API에 따라 실제 함수와 Command Buffer 구조는 다르지만 개념적으로 다음 Data가 필요하다.

```text
어떤 Vertex / Index Buffer를 사용할까?
어느 Index 범위를 그릴까?
어떤 Shader Program을 사용할까?
어떤 Texture와 Buffer를 연결할까?
어떤 Render State를 사용할까?
어느 Render Target에 기록할까?
몇 개의 Instance를 그릴까?
```

개념적인 Graphics API 호출은 다음과 같다.

```text
BindPipelineState(...)
BindVertexBuffer(...)
BindIndexBuffer(...)
BindResources(...)
DrawIndexed(indexCount, instanceCount, ...)
```

Unity의 `MeshRenderer`는 이 Command 자체가 아니라 Draw를 만들기 위한 Scene Data를 제공하는 Component다.

---

## Draw Call은 어디에서 발생할까?

Camera Culling을 통과한 Renderer가 현재 Render Pass의 조건과 맞을 때 Draw 후보가 된다.

```text
Camera Loop
↓
Culling
↓
Visible Renderer
↓
Render Pass Filtering
↓
SubMesh + Material 선택
↓
Shader Pass와 Variant 선택
↓
Batching 가능성 검사
↓
Draw Call 제출
```

즉 Scene에 Renderer가 존재하는 순간 바로 Draw Call이 발생하는 것은 아니다.

현재 Camera와 Render Pass에서 실제로 처리할 이유가 있어야 한다.

---

## Draw Call의 입력

Draw 하나를 구성하는 대표적인 입력을 정리하면 다음과 같다.

| 입력 | 역할 |
|---|---|
| Mesh Buffer | Vertex와 Index Data |
| SubMesh | 그릴 Index 범위와 Topology |
| Material | Shader, Property, Keyword와 Queue |
| Shader Pass | GPU Program과 Render State |
| Transform | Object를 World에 배치하는 Matrix |
| Per-camera Data | View·Projection과 Camera Parameter |
| Lighting Data | Light, Shadow와 Probe 정보 |
| Render Target | Color·Depth를 기록할 대상 |

이 중 일부가 달라지면 별도의 Draw 또는 State 설정이 필요할 수 있다.

Batching 방식은 서로 다른 Renderer의 일부 Data를 한 번에 전달할 수 있도록 재구성한다.

---

## Renderer 하나와 Draw Call 하나는 같은가?

같지 않다.

가장 단순한 조건에서는 비슷하게 보일 수 있다.

```text
Camera 1개
Render Pass 1개
Renderer 1개
SubMesh 1개
Material 1개
Batching 없음
↓
Draw 1개 가능
```

하지만 실제 Frame에는 Shadow, Depth, 여러 SubMesh와 Camera가 있을 수 있다.

```text
Renderer 1개
├─ ShadowCaster Draw
├─ DepthOnly Draw
├─ Forward Color Draw
└─ MotionVectors Draw
```

반대로 같은 Mesh와 Material을 사용하는 Renderer 여러 개가 GPU Instancing으로 한 Draw에 포함될 수도 있다.

---

## Draw 수를 늘리는 큰 축

단순화한 Draw 반복 요인은 다음과 같다.

```text
Camera
× Render Pass
× Visible Renderer
× SubMesh / Material Slot
× Shadow Light / Cascade
× 추가 효과 Pass
÷ Batching / Instancing 효과
```

이 식은 정확한 Counter 계산식이 아니라 어떤 요소가 Draw를 늘리고 줄이는지 이해하기 위한 모델이다.

Pipeline의 Culling, Pass 합성, Batching 제한과 Platform에 따라 실제 숫자는 달라진다.

---

## Camera가 늘면 Draw가 늘 수 있다

Camera마다 Culling과 Rendering Loop가 실행될 수 있다.

```text
Main Camera
→ Character Draw
→ Environment Draw

Minimap Camera
→ Character Draw
→ Environment Draw
```

같은 Renderer가 두 Camera의 Culling Mask와 Frustum에 모두 포함되면 각 Camera Target에 다시 그려질 수 있다.

```text
Renderer 하나
× Camera 두 개
→ Camera Color Draw 두 번 가능
```

Render Texture Camera, Reflection Camera, Scene View와 Preview Camera도 Rendering 작업을 만들 수 있다.

Editor의 Draw 수와 Player Build의 Draw 수가 다른 이유 중 하나다.

---

## Camera Stack과 Draw

URP의 Base Camera와 Overlay Camera가 같은 Renderer Layer를 포함하면 같은 Target에 Renderer를 반복 Drawing할 수 있다.

```text
Base Camera Culling Mask
World + Weapon

Overlay Camera Culling Mask
Weapon

Weapon Renderer
→ Base에서 한 번
→ Overlay에서 다시 한 번
```

의도한 Layer 분리가 아니라면 불필요한 Draw와 Overdraw가 생긴다.

Camera Stack의 Culling Mask를 확인하고 Frame Debugger에서 Camera별 Event를 비교해야 한다.

---

## SubMesh가 늘면 Draw가 늘 수 있다

Mesh의 각 SubMesh는 서로 다른 Index 범위와 Material을 사용할 수 있다.

```text
Character Mesh
├─ SubMesh 0 + Skin Material
├─ SubMesh 1 + Hair Material
├─ SubMesh 2 + Clothes Material
└─ SubMesh 3 + Eye Material
```

Renderer는 하나지만 Camera Color Pass에서 네 개의 Draw 후보가 생길 수 있다.

```text
Renderer Count = 1
Material Slot = 4
Color Draw ≈ 4 가능
```

각 SubMesh가 Shadow에도 참여하면 Shadow Pass에서도 반복될 수 있다.

Material Slot 수는 Renderer 수와 별개의 Draw 증가 요인이다.

---

## Material이 많으면 왜 나뉠까?

Material마다 Shader, Texture, Property, Keyword와 Render State가 다를 수 있다.

```text
Material A
Opaque Lit

Material B
Transparent Hair

Material C
Eye Clear Coat
```

GPU는 Draw마다 필요한 Pipeline State와 Resource를 알아야 한다.

서로 다른 Material의 Triangle을 아무 조건 없이 하나의 일반 Draw로 합칠 수 없는 이유다.

Texture Array, Atlas, Bindless Resource나 Material ID 기반 Shader 같은 설계로 차이를 Data화할 수 있지만 Shader 복잡도와 Platform 제약이 생긴다.

---

## Material Slot이 SubMesh보다 많을 때

MeshRenderer에 SubMesh 수보다 더 많은 Material을 할당하면 Unity가 마지막 SubMesh를 남은 Material로 반복 Rendering할 수 있다.

```text
SubMesh 0 → Material 0
SubMesh 1 → Material 1
SubMesh 1 → Material 2
SubMesh 1 → Material 3
```

Layered Effect를 의도했다면 유효하지만 실수로 남은 Opaque Slot은 같은 Geometry를 반복해서 덮어쓴다.

Frame Debugger에서 같은 Mesh와 SubMesh가 연속으로 다른 Material에 의해 Draw되는지 확인한다.

---

## Shader Pass가 늘면 Draw가 늘까?

Shader에 Pass가 여러 개 있다고 해서 모두 자동 실행되지는 않는다.

Render Pipeline이 현재 단계에서 해당 Pass를 선택할 때 Draw가 발생한다.

```text
Shader
├─ UniversalForward
├─ ShadowCaster
├─ DepthOnly
└─ MotionVectors

현재 Frame 요구
├─ Shadow On
├─ Depth Prepass On
└─ Motion Vector Off

실행 가능
├─ ShadowCaster
├─ DepthOnly
└─ UniversalForward
```

실제로 호출되는 Pass만 Draw 작업에 기여한다.

Multi Pass Effect가 같은 Geometry를 여러 번 그리도록 구성되었다면 Pass마다 추가 Draw가 생길 수 있다.

---

## Shadow가 Draw를 늘리는 이유

실시간 Shadow는 Light 관점에서 Shadow Caster Geometry를 Shadow Map에 그린다.

```text
Main Camera Color
→ Renderer Forward Draw

Directional Light Shadow
→ 같은 Renderer ShadowCaster Draw
```

Directional Light가 여러 Cascade를 사용하면 Renderer가 Cascade별 Shadow Map 영역에 반복 Drawing될 수 있다.

```text
Cascade 0
→ 가까운 Shadow Caster

Cascade 1
→ 중간 거리 Shadow Caster

Cascade 2
→ 먼 거리 Shadow Caster
```

추가 Light가 Shadow를 만들면 Light마다 별도 Shadow Rendering이 필요할 수 있다.

화면에 보이는 Object 수만으로 Shadow Draw 비용을 예측할 수 없는 이유다.

---

## Depth Prepass가 Draw를 늘리는 이유

URP 기능과 Rendering Path에 따라 Opaque Color 전에 Depth 또는 Depth-Normal을 먼저 그릴 수 있다.

```text
DepthOnly Pass
→ Geometry Draw, Depth 기록

Forward Pass
→ 같은 Geometry Draw, Color와 Lighting 기록
```

Prepass는 Draw와 Vertex 처리를 추가하지만 이후 Depth Test 효율을 높이거나 Depth Texture가 필요한 Effect를 지원한다.

Depth Prepass를 제거하면 Draw 수는 줄 수 있지만 Pipeline이 다른 방식으로 Depth Texture를 복사하거나 Feature가 동작하지 않을 수 있다.

전체 Frame 비용을 측정해야 한다.

---

## Deferred Rendering의 Draw

Deferred Rendering에서는 Opaque Geometry를 G-buffer에 기록한 뒤 Lighting Pass를 수행한다.

```text
Geometry Pass
Renderer → G-buffer
↓
Deferred Lighting Pass
G-buffer → Camera Color
```

Opaque Renderer마다 `UniversalGBuffer` Pass Draw가 필요할 수 있고 Lighting은 별도의 Screen 또는 Volume Draw·Dispatch로 처리될 수 있다.

Forward Only Material은 Deferred Renderer에서도 별도 Forward Pass에서 그려질 수 있다.

Rendering Path가 달라지면 같은 Scene의 Draw Event 구성도 달라진다.

---

## Transparent Draw

Transparent Object는 일반적으로 뒤의 Color와 Blend하므로 서로 다른 순서로 Drawing된다.

```text
먼 Transparent Renderer
↓
중간 Transparent Renderer
↓
가까운 Transparent Renderer
```

서로 다른 Depth에 있는 Transparent Object를 하나의 단순 Batch로 합치면 필요한 Sorting 순서를 유지하기 어려울 수 있다.

Transparent Material은 Opaque보다 Batching과 Sorting 제약이 커질 수 있다.

Draw 수뿐 아니라 여러 Layer가 Pixel을 반복 처리하는 Overdraw도 함께 증가한다.

---

## Full-screen Draw

모든 Draw Call이 MeshRenderer GameObject에서 만들어지는 것은 아니다.

Post-processing과 Blit는 화면을 덮는 Triangle 또는 Procedural Geometry를 Draw할 수 있다.

```text
Bloom Downsample
→ Full-screen Draw

Blur Horizontal
→ Full-screen Draw

Blur Vertical
→ Full-screen Draw

Color Grading
→ Full-screen Draw
```

Hierarchy에 대응하는 Renderer가 없어도 Render Pipeline과 Renderer Feature가 Draw Event를 만든다.

Stats의 Batches와 Scene Renderer 수가 일치하지 않는 또 다른 이유다.

---

## Draw Call의 CPU 비용

Draw를 제출하기 전에 CPU는 State와 Resource를 준비해야 한다.

```text
Renderer 정렬
↓
Shader Variant 확인
↓
Material Constant Data 준비
↓
Texture와 Buffer Binding
↓
Pipeline State 설정
↓
Draw Command 기록
```

Draw 하나의 비용은 Graphics API, Driver, State 차이와 Unity의 Rendering 경로에 따라 다르다.

Draw가 매우 많으면 Main Thread 또는 Render Thread가 GPU에 Command를 충분히 빠르게 공급하지 못하는 CPU 병목이 생길 수 있다.

---

## Draw Call의 GPU 비용

Draw가 제출되면 GPU는 Geometry와 Pixel을 처리한다.

```text
Vertex Shader
↓
Primitive Assembly
↓
Rasterization
↓
Fragment Shader
↓
Depth / Blend / Render Target
```

Draw Call 수가 같아도 GPU 비용은 크게 다를 수 있다.

```text
Draw A
Triangle 12개, 화면 10 Pixel

Draw B
Triangle 1,000,000개, 화면 전체, 복잡한 Shader
```

Draw 수는 CPU 제출 비용의 중요한 신호지만 GPU Workload 전체를 나타내는 단일 지표는 아니다.

---

## Batch란?

Unity Rendering Statistics의 Batch는 Unity가 한 Frame에서 처리한 Draw Call Batch를 나타낸다.

```text
Draw Candidates
↓
Batching 조건 검사
↓
하나 또는 여러 Candidate를 Batch로 제출
```

일반적인 개별 Draw도 하나의 Batch로 집계될 수 있고 Static, Dynamic 또는 Instanced Drawing도 Batch로 표시된다.

Unity Editor의 Stats Counter는 Build Target과 Rendering Path에 따라 표시 항목과 의미가 달라질 수 있다.

정확한 Event는 Frame Debugger에서 확인한다.

---

## Batching이 필요한 이유

여러 Object를 각각 제출하면 CPU가 Draw Command를 반복해서 준비한다.

```text
Object A → Draw 1
Object B → Draw 2
Object C → Draw 3
Object D → Draw 4
```

호환되는 Geometry와 State를 묶으면 제출 횟수를 줄일 수 있다.

```text
Object A + B + C + D
→ Batched Draw 1
```

하지만 묶는 과정 자체에 CPU, Memory 또는 Culling Granularity 비용이 생길 수 있다.

모든 Scene에서 모든 Batching 방식이 이득인 것은 아니다.

---

## Static Batching

Static Batching은 움직이지 않는 GameObject의 Mesh를 결합 가능한 형태로 준비해 더 적은 Draw로 Rendering한다.

```text
Static Renderer A
Static Renderer B
Static Renderer C
↓
Combined Geometry
↓
Draw 감소 가능
```

Object의 World Transform이 바뀌지 않는다는 가정이 필요하다.

개별 Renderer의 Culling 정보를 유지할 수 있는 구현이더라도 결합 Geometry와 Memory 비용이 증가할 수 있다.

같은 Material, Shader Variant, Lightmap과 Vertex Layout 등 호환 조건이 필요하다.

---

## Dynamic Batching

Dynamic Batching은 충분히 작은 Mesh의 Vertex를 CPU에서 World Space로 변환하고 호환되는 Object를 결합한다.

```text
Small Mesh A Vertex Transform
+ Small Mesh B Vertex Transform
+ Small Mesh C Vertex Transform
↓ CPU
Combined Vertex
↓
Draw 감소
```

CPU Vertex 변환 비용이 추가되므로 현대 Graphics API에서는 개별 Draw보다 더 비쌀 수 있다.

Mesh Vertex 수, Attribute Layout, Material과 Shader 조건에도 제한이 있다.

Project와 Platform에서 켠 상태와 끈 상태를 Profiler로 비교해야 한다.

---

## GPU Instancing

GPU Instancing은 같은 Mesh와 Material을 사용하는 여러 Object를 하나의 Instanced Draw로 Rendering한다.

```text
Tree Mesh + Tree Material
├─ Instance Transform 0
├─ Instance Transform 1
├─ Instance Transform 2
└─ Instance Transform 3
↓
DrawIndexedInstanced
```

각 Instance는 Transform 외에도 Instancing Buffer로 선언된 Color나 Scale 같은 값을 다르게 가질 수 있다.

Frame Debugger에서는 `Draw Mesh (instanced)` 형태의 Event로 확인할 수 있다.

Shader와 Material이 Instancing을 지원하고 Batch를 깨는 Property 차이가 없어야 한다.

---

## Instancing이 나뉘는 조건

다음 차이는 Instanced Batch를 분리할 수 있다.

```text
Mesh가 다름
Material이 다름
Shader Variant가 다름
Render Queue 또는 Pass가 다름
Lightmap과 Probe Data 조건이 호환되지 않음
지원하지 않는 Renderer Property 차이
Instance 수 제한
```

같은 Material 이름이라고 같은 Asset 참조라는 뜻은 아니다.

복제된 Material Asset이나 Runtime `renderer.material` Instance는 서로 다른 Batch가 될 수 있다.

Frame Debugger의 Batch Break 원인을 확인해야 한다.

---

## Manual Mesh Combining

여러 Mesh를 하나의 Mesh Asset 또는 Runtime Mesh로 직접 결합할 수 있다.

```text
Wall Segment A
Wall Segment B
Wall Segment C
↓
Combined Wall Mesh
↓
Renderer 1개
```

Draw와 Renderer 관리 비용을 줄일 수 있지만 결합 Bounds가 커진다.

Camera에 일부만 보여도 전체 Combined Mesh가 Draw될 수 있다.

각 부분을 독립적으로 움직이거나 LOD와 Occlusion Culling하기도 어려워질 수 있다.

Scene 공간 단위에 맞춰 결합 크기를 결정해야 한다.

---

## SRP Batcher

SRP Batcher는 이름에 Batcher가 있지만 여러 Mesh를 반드시 한 Draw Call로 합치는 기능은 아니다.

호환되는 Shader Variant를 사용하는 연속 Draw에서 Material Constant Buffer를 GPU Memory에 유지하고 State 설정 비용을 줄인다.

```text
Draw A: Material A, Same Shader Variant
↓ Material Data 전환 효율화
Draw B: Material B, Same Shader Variant
↓
Draw C: Material C, Same Shader Variant
```

Draw A, B, C는 여전히 별도 Draw일 수 있다.

핵심 목표는 CPU가 Draw 사이에 수행하는 Setup 비용을 줄이는 것이다.

---

## SRP Batcher와 GPU Instancing 비교

| 항목 | SRP Batcher | GPU Instancing |
|---|---|---|
| 주된 목표 | Draw 사이 CPU State·Material 설정 비용 감소 | 같은 Mesh의 여러 Instance를 한 Draw에 처리 |
| Mesh 조건 | 서로 달라도 호환 가능 | 같은 Mesh 필요 |
| Material | 다른 Material도 같은 Shader Variant면 이점 가능 | 일반적으로 같은 Material 필요 |
| Draw 수 | 반드시 줄지 않음 | 줄어들 수 있음 |
| Shader 요구 | SRP Batcher Constant Buffer 호환 | Instancing Variant와 Macro |

두 기능의 선택과 우선순위는 Render Pipeline 및 Shader 호환성에 따라 달라질 수 있다.

URP의 현재 Version에서 실제 Batch 경로를 Frame Debugger와 Profiler로 확인한다.

---

## SetPass Call이란?

SetPass Call은 Unity가 새로운 Shader Pass를 Rendering에 사용하기 위해 설정한 횟수와 관련된 Counter다.

```text
Material A / Shader Pass X
↓
Material B / 같은 호환 Pass State
↓
Draw는 여러 개여도 SetPass 변경은 적을 수 있음
```

반대로 Shader, Pass, Keyword Variant와 Render State가 자주 바뀌면 SetPass와 State 변경이 늘 수 있다.

```text
Draw Call
Geometry Drawing 요청

SetPass Call
Shader Pass와 관련 State를 새로 설정하는 작업
```

두 Counter는 같은 의미가 아니다.

SetPass Call의 구체적인 구조는 다음 글에서 다룬다.

---

## Saved by Batching

Game View Stats의 `Saved by batching`은 Batching을 통해 합쳐졌다고 계산된 Draw Call 수를 보여 준다.

```text
원래 개별 Draw 후보 100개
Batch 결과 10개
↓
일부 Draw 제출 절감
```

이 숫자가 높다고 Frame 성능이 반드시 좋다는 뜻은 아니다.

Batch로 합쳐진 Mesh가 화면 대부분을 덮거나 Fragment Shader가 복잡하면 GPU가 여전히 느릴 수 있다.

Batch 생성과 Culling 비용도 함께 봐야 한다.

---

## Triangle과 Vertex Counter

Stats의 Tris와 Verts는 Frame에서 처리하는 Geometry 규모를 파악하는 데 도움을 준다.

```text
Mesh Triangle 10,000
× Shadow Pass 4 Cascades
+ Camera Color Pass
→ 동일 Geometry가 여러 번 집계될 수 있음
```

Asset Inspector에 표시되는 원본 Mesh Triangle 수와 Frame Counter가 다른 이유다.

Batching은 Draw 수를 줄여도 GPU가 처리해야 하는 Vertex와 Triangle을 반드시 같은 비율로 줄이지 않는다.

---

## Draw Call이 적으면 항상 빠를까?

아니다.

극단적으로 모든 Scene Geometry를 하나의 Mesh와 Draw로 합쳐도 다음 문제가 생길 수 있다.

```text
큰 Bounds로 Culling 효율 저하
보이지 않는 Triangle까지 처리
거대한 Vertex / Index Buffer
Material 표현 유연성 감소
LOD와 Streaming 어려움
한 Draw의 GPU 작업 과다
```

Draw Call 최적화는 CPU 제출 비용과 GPU Visibility 비용 사이의 균형이다.

목표 Hardware가 CPU Bound인지 GPU Bound인지 먼저 확인해야 한다.

---

## 작은 Draw Call의 문제

Draw 하나가 처리하는 Geometry가 지나치게 작으면 GPU 작업보다 CPU 제출과 State 설정 비용의 비중이 커질 수 있다.

```text
Draw 1개당 Triangle 2개
× 10,000 Objects
↓
CPU Command Overhead 증가 가능
```

UI Element, 작은 Prop, Decal과 Particle을 개별 Renderer와 Material로 구성할 때 발생할 수 있다.

Atlas, Instancing, Batch Renderer 또는 적절한 Mesh 결합을 검토할 수 있다.

---

## 너무 큰 Draw Call의 문제

Draw가 너무 크면 Culling 단위가 거칠어진다.

```text
도시 전체 Combined Mesh
↓
Bounds 일부가 Camera Frustum과 교차
↓
도시 전체 Geometry Draw
```

Occlusion Culling과 LOD도 큰 단위로만 적용될 수 있다.

GPU가 보이지 않는 Triangle을 처리하고 Depth에서 제거하는 일이 늘 수 있다.

공간 Cell, Room, Chunk 또는 Streaming 단위에 맞는 크기로 나누는 방식을 검토한다.

---

## Material 공유가 중요한 이유

같은 시각적 설정을 가진 Object마다 별도 Material Asset을 만들면 Batching 기회를 잃을 수 있다.

```text
RedMaterial_A
RedMaterial_B
RedMaterial_C

값은 같지만 Asset 참조가 다름
→ Batch 분리 가능
```

같은 Material을 공유하고 Object별 Color 같은 작은 차이는 Instanced Property나 적절한 Data 전달 방식으로 표현할 수 있다.

하지만 서로 다른 Keyword, Texture와 Render State가 실제로 필요하다면 무리하게 공유하지 않는다.

---

## Texture Atlas

여러 Material이 Texture만 다르다면 Texture Atlas로 하나의 큰 Texture에 합칠 수 있다.

```text
Texture A ┐
Texture B ├─ Atlas Texture
Texture C ┘
↓
UV 영역으로 선택
↓
Shared Material
```

Material 변경을 줄이고 Mesh 결합과 Batching에 도움을 줄 수 있다.

단점도 있다.

```text
Atlas Padding 필요
Mip Bleeding 가능
Texture 해상도와 Memory 관리
Wrap Mode 제한
일부 Texture만 Load하기 어려움
```

Texture Array가 더 적합한 경우도 있으며 Platform 지원과 Shader 복잡도를 고려한다.

---

## MaterialPropertyBlock과 Draw

MaterialPropertyBlock은 Shared Material을 유지하면서 Renderer별 Property를 전달할 수 있다.

```text
Shared Material
├─ Renderer A: Color Red
├─ Renderer B: Color Blue
└─ Renderer C: Color Green
```

GPU Instancing용 Property로 올바르게 선언하면 Instance별 차이를 유지하며 한 Draw로 묶을 가능성이 있다.

그러나 일반 MaterialPropertyBlock 사용은 SRP Batcher 호환 경로에 영향을 줄 수 있다.

Shader와 Pipeline의 Batch 방식을 기준으로 선택한다.

---

## Shader Variant와 Draw 분리

같은 Shader Asset을 사용해도 Keyword 조합이 다르면 서로 다른 Variant가 선택된다.

```text
Material A
_NORMAL_MAP Off

Material B
_NORMAL_MAP On

같은 Shader
하지만 다른 Variant
```

Pipeline State가 달라져 같은 Batch로 묶이지 않을 수 있다.

Material Keyword 조합을 무분별하게 늘리면 Shader Compile 문제뿐 아니라 Runtime State 전환과 Batch 분리에도 영향을 준다.

---

## Negative Scale과 Batching

Transform에 음수 Scale을 사용하면 Triangle Winding과 Culling 방향에 영향을 줄 수 있다.

```text
Scale (1, 1, 1)
일반 Winding

Scale (-1, 1, 1)
Mirror Transform
Winding 반전 가능
```

Unity가 Front Face 처리 State를 다르게 설정해야 하면 Batch가 나뉠 수 있다.

Mirror Object를 Negative Scale로 대량 배치할 때 Frame Debugger의 Batch Break 이유를 확인한다.

---

## Lightmap과 Batching

Baked Renderer는 Lightmap Texture와 Scale-Offset Data를 가진다.

```text
Renderer A
Lightmap 0, Rect A

Renderer B
Lightmap 0, Rect B

Renderer C
Lightmap 1, Rect C
```

같은 Lightmap Atlas를 사용하는 Renderer는 Batching에 유리할 수 있다.

서로 다른 Lightmap Texture나 지원되지 않는 Property 차이는 Batch를 나눌 수 있다.

GPU Instancing은 같은 Lightmap Texture 안의 서로 다른 Atlas 영역을 지원할 수 있지만 사용하는 Pipeline과 Shader 조건을 확인해야 한다.

---

## Sorting과 Draw 순서

Renderer는 Render Queue와 Sorting 기준에 따라 순서가 정해진다.

```text
Opaque
State 변경과 Front-to-back 효율을 고려한 정렬

Transparent
Blend 결과를 위해 Back-to-front 중심 정렬
```

Batching을 위해 Material별로 묶고 싶어도 Transparent의 정확한 Depth 순서를 유지해야 하면 결합이 제한될 수 있다.

Draw Call 최적화는 Rendering 결과의 정확한 순서를 깨지 않아야 한다.

---

## Renderer Feature와 Draw Call

URP Renderer Feature는 추가 Render Pass를 삽입할 수 있다.

```text
Render Objects Feature
→ 특정 Layer Renderer 다시 Draw

Outline Feature
→ Mask Draw + Full-screen Draw

Decal Feature
→ Decal 관련 Pass
```

Feature 하나가 Hierarchy의 Renderer 수보다 많은 Event를 추가할 수 있다.

Inspector에서 Feature를 비활성화한 전후의 Frame Debugger와 GPU Profiler를 비교하면 비용을 확인할 수 있다.

기능이 필요하다면 단순 삭제보다 해상도, 대상 Layer와 Pass 수를 최적화한다.

---

## CommandBuffer.DrawMesh

Script나 Render Pipeline Code에서 Renderer Component 없이 Mesh Draw를 명시적으로 기록할 수 있다.

```csharp
commandBuffer.DrawMesh(
    mesh,
    matrix,
    material,
    submeshIndex,
    shaderPass
);
```

이 Command도 실행되면 Draw Call을 만든다.

Unity의 일반 Renderer Culling과 Sorting을 자동으로 동일하게 거치는지 가정하면 안 된다.

Custom Drawing Code가 Camera마다 몇 번 호출되고 어느 Pass에서 실행되는지 확인해야 한다.

---

## Graphics.DrawMesh 계열

Unity는 `Graphics.DrawMesh`, `Graphics.RenderMesh`, Indirect Drawing과 Instanced Drawing API를 제공한다.

```text
GameObject Renderer 경로
Scene Component를 통한 관리

Graphics API 경로
Script가 Drawing Parameter를 직접 제공
```

대량 Object를 Custom Data 구조로 관리하면 GameObject와 Renderer Overhead를 줄일 수 있다.

대신 Culling, LOD, Sorting, Motion Vector와 Shadow Pass 관리를 직접 책임지는 범위가 늘어난다.

사용 API와 Unity Version에 맞는 공식 문서를 확인한다.

---

## Indirect Draw

Indirect Drawing은 Draw Parameter를 GPU Buffer에서 읽도록 구성할 수 있다.

```text
Compute Shader Culling
↓
Visible Instance Count와 Argument Buffer
↓
Indirect Draw
```

CPU가 Instance마다 Draw를 제출하지 않고 대규모 Grass, Particle 또는 Crowd를 처리하는 데 활용할 수 있다.

Draw Call 수가 적어도 GPU Culling, Buffer 관리와 모든 Instance의 Vertex·Pixel 비용은 남는다.

복잡도가 높으므로 일반 Renderer와 GPU Instancing으로 목표를 달성할 수 있는지 먼저 평가한다.

---

## Frame Debugger로 Draw 확인하기

Unity Frame Debugger는 한 Frame의 Draw와 기타 Rendering Event를 순서대로 보여 준다.

```text
Window
↓
Analysis
↓
Frame Debugger
↓
Enable
```

Event를 선택하면 다음 정보를 확인할 수 있다.

```text
Camera와 Render Pass
Render Target
GameObject
Mesh와 SubMesh
Material
Shader Pass
Batching 방식
Keyword와 Render State
```

Hierarchy Object가 없는 Full-screen Draw와 Custom Pass도 Event 목록에서 찾을 수 있다.

---

## Frame Debugger의 Batch Break

연속 Object가 Batch되지 않을 때 Frame Debugger는 이유를 제공할 수 있다.

대표적인 후보는 다음과 같다.

```text
다른 Material
다른 Shader Variant
다른 Mesh
다른 Lightmap
다른 Shadow State
Negative Scale
Instancing Property 불일치
Batch 크기 제한
Renderer Sorting 순서
```

Batch Break 이유를 확인하지 않고 Material을 합치거나 Shader를 바꾸면 Rendering 결과만 복잡해질 수 있다.

가장 많이 반복되는 Break 원인부터 해결한다.

---

## Rendering Statistics

Game View의 Stats 창은 Frame의 Rendering 요약을 보여 준다.

| Counter | 의미 |
|---|---|
| Batches | Frame에서 처리한 Draw Call Batch 수 |
| Saved by batching | Batching으로 합쳐진 Draw Call 수 |
| Tris | 처리한 Triangle 수 |
| Verts | 처리한 Vertex 수 |
| SetPass | Shader Pass 전환과 관련된 횟수 |
| Shadow casters | Frame의 Shadow Casting Object 수 |

Counter는 빠른 비교에 유용하다.

Editor의 Scene View와 Preview 작업이 영향을 줄 수 있으므로 Player Build에서도 확인한다.

---

## Profiler에서 Draw 비용 확인하기

CPU Profiler의 Main Thread와 Render Thread에서 Rendering Command 준비 비용을 확인한다.

```text
Main Thread
Culling, Sorting, Render Loop 준비

Render Thread
Graphics API Command 제출과 Driver 작업
```

GPU Profiler와 Platform Capture에서는 각 Pass와 Draw의 GPU 실행 시간을 확인한다.

```text
Draw 수는 많지만 CPU·GPU 시간 여유
→ 우선순위가 낮을 수 있음

Draw 제출 때문에 Render Thread 병목
→ Batching과 State 최적화 후보
```

숫자 자체보다 Frame Budget을 제한하는지 판단한다.

---

## Draw Call 최적화 순서

다음 순서로 접근할 수 있다.

```text
1. 목표 Device에서 CPU / GPU 병목 확인
2. Frame Debugger로 Camera와 Pass별 Draw 분류
3. 불필요한 Camera와 Render Pass 확인
4. Material Slot과 중복 Material 확인
5. 같은 Mesh 반복은 GPU Instancing 검토
6. Static Geometry는 Static Batching 또는 공간 단위 결합 검토
7. Shader Variant와 State 차이 확인
8. 변경 후 Culling, Memory와 GPU 시간 재측정
```

Draw 수를 줄였는데 GPU 시간이 늘거나 Memory가 크게 증가하면 전체 최적화가 아닐 수 있다.

---

## 먼저 제거할 Draw

Batching보다 불필요한 Rendering 자체를 제거하는 편이 효과적일 수 있다.

```text
사용하지 않는 Camera
중복 Camera Layer
불필요한 Shadow Caster
과도한 Shadow Cascade
사용하지 않는 Renderer Feature
실수로 남은 Material Slot
보이지 않는 UI와 Particle Renderer
```

필요 없는 Draw를 하나의 Batch로 합치는 것보다 실행하지 않는 편이 CPU와 GPU 모두에 유리하다.

다만 Visual Feature 요구와 Gameplay Camera 의도를 확인한 뒤 제거한다.

---

## Draw를 합칠 때 확인할 것

Batching이나 Mesh 결합 전 다음 질문을 확인한다.

```text
같은 Material과 Shader Variant를 공유하는가?
Object가 함께 움직이는가?
같은 공간에서 함께 보이는가?
같은 LOD와 Shadow 설정을 사용하는가?
개별 Culling이 필요한가?
Texture Atlas Memory는 적절한가?
Target Platform에서 CPU가 실제 병목인가?
```

서로 멀리 떨어진 Object를 하나의 Mesh로 합치면 Frustum과 Occlusion Culling이 악화된다.

공간적으로 가까우며 함께 보이는 Object를 우선 후보로 삼는다.

---

## Draw Call Budget

모든 Project에 적용되는 고정 Draw Call 제한은 없다.

```text
영향 요소
CPU Architecture
Graphics API
Driver Overhead
Render Pipeline
Shader와 State 변경
Draw당 Geometry와 Pixel 수
목표 Frame Rate
```

고성능 Desktop과 저사양 Mobile의 허용 범위가 다르고 같은 숫자도 Graphics API에 따라 CPU 비용이 달라질 수 있다.

팀의 목표 Device와 대표 Scene에서 Frame Budget을 만들고 회귀 Test로 관리해야 한다.

---

## 자주 혼동하는 내용

### Renderer 하나는 Draw Call 하나다?

아니다.

SubMesh, Material, Shadow, Depth, Camera와 Pass에 따라 여러 Draw가 생길 수 있다.

### Draw Call 하나는 Object 하나만 그린다?

아니다.

Static Batching, Dynamic Batching과 GPU Instancing은 여러 Object의 Geometry 또는 Instance를 한 Draw로 처리할 수 있다.

### Shader에 Pass가 세 개면 항상 Draw가 세 번 발생한다?

아니다.

현재 Render Pipeline 단계가 실제로 선택하고 실행하는 Pass만 Draw를 만든다.

### SRP Batcher는 Draw Call을 하나로 합친다?

반드시 그렇지 않다.

주된 목적은 호환되는 Draw 사이의 CPU State와 Material Data 설정 비용을 줄이는 것이다.

### Draw Call을 줄이면 Triangle 수도 줄어든다?

반드시 그렇지 않다.

Batching은 같은 Geometry를 더 적은 호출로 제출할 뿐 GPU가 처리할 Triangle이 그대로일 수 있다.

### Batches와 SetPass는 같은 숫자다?

아니다.

Batches는 Draw Call Batch를, SetPass는 Shader Pass와 관련 State 설정 전환을 나타낸다.

### Draw Call이 적으면 GPU가 빠르다?

아니다.

Draw 하나가 화면 전체의 복잡한 Shader와 수많은 Triangle을 처리하면 GPU 비용은 클 수 있다.

---

## 한 Renderer의 Draw를 계산하는 예

다음 Character를 가정한다.

```text
Camera 1개
Directional Shadow Cascade 2개
Depth Prepass On
SubMesh 3개
Motion Vector On
```

모든 SubMesh가 모든 Pass에 참여한다고 단순 가정하면 다음 후보가 생길 수 있다.

```text
Shadow
3 SubMesh × 2 Cascades = 6

Depth
3 SubMesh × 1 = 3

Camera Color
3 SubMesh × 1 = 3

Motion Vector
3 SubMesh × 1 = 3

총 Draw 후보 = 15
```

실제 결과는 Culling, Pass 구현, Shadow 범위와 Batching에 따라 달라진다.

Renderer 하나가 Frame에서 한 번만 그려진다는 가정이 크게 어긋날 수 있다는 예다.

---

## 반복 Object의 Draw를 계산하는 예

같은 Tree Mesh와 Material을 사용하는 Tree 100개가 있다고 가정한다.

```text
Batching 없음
Camera Color Draw 최대 100개 후보

GPU Instancing 성공
여러 Tree를 Instanced Draw 하나 또는 소수로 처리 가능
```

하지만 Tree마다 다른 Material Instance를 만들면 다음과 같이 나뉠 수 있다.

```text
Tree 100개
각각 renderer.material 사용
↓
Material Instance 100개 가능
↓
Instancing Batch 분리 가능
```

Shared Material과 Instanced Property 구조가 중요하다.

---

## 전체 흐름 다시 연결하기

Draw Call이 발생하는 과정을 정리하면 다음과 같다.

```text
Camera
↓
Culling Result
↓
현재 Render Pass
↓
Visible Renderer Filtering
↓
SubMesh + Material
↓
Shader Pass + Variant
↓
Render State와 Resource
↓
Batching / Instancing
↓
Graphics Command
↓
GPU Draw
```

각 Camera, Shadow, Depth와 Effect Pass에서 이 흐름이 반복될 수 있다.

---

## 정리

Draw Call은 CPU가 GPU에 특정 Geometry를 현재 Shader, Resource와 Render State로 그리도록 제출하는 작업이다.

Camera Culling을 통과한 Renderer가 현재 Render Pass의 Filtering 조건에 맞고 SubMesh, Material, Shader Pass와 Variant가 결정되면 Draw 후보가 만들어진다.

```text
Camera × Pass × Renderer × SubMesh
× Shadow와 반복 Rendering
÷ Batching과 Instancing
→ 실제 Draw 규모
```

Renderer 하나도 여러 SubMesh, Shadow Cascade, Depth Prepass, Camera Color와 Motion Vector 단계에서 여러 번 Drawing될 수 있다.

반대로 Static·Dynamic Batching과 GPU Instancing은 호환되는 여러 Renderer를 더 적은 Draw로 처리할 수 있다.

SRP Batcher는 Draw 수를 반드시 줄이는 기능이 아니라 호환되는 Draw 사이의 CPU Shader·Material 설정 비용을 줄이는 구조다.

Draw Call 수는 CPU 제출 비용을 이해하는 중요한 지표지만 Triangle, Pixel Coverage, Shader 복잡도와 Memory Bandwidth를 포함한 GPU 비용 전체를 나타내지는 않는다.

Frame Debugger로 Camera와 Pass별 실제 Draw, Batch 방식과 Batch Break 원인을 확인하고 CPU·GPU Profiler로 목표 Device의 병목을 측정한 뒤 최적화해야 한다.
