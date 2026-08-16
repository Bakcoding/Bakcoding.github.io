---
title: "[Unity 렌더링] 9-2. Batching은 왜 필요할까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - Batching
  - DrawCall
  - Optimization
permalink: /programming/unity-9-2-why-batching-is-needed/
toc: true
toc_sticky: true
date: 2026-08-16
last_modified_at: 2026-08-16
---

Batching은 호환되는 여러 Rendering 작업을 묶어 CPU의 Render State 변경과 Draw Call 준비 비용을 줄이는 최적화 방식이다.

```text
Batching 없음
Object A → State 준비 → Draw
Object B → State 준비 → Draw
Object C → State 준비 → Draw

Batching 적용
공통 State 준비
└─ A + B + C를 묶거나 효율적으로 연속 처리
```

Object 수가 많아질수록 GPU가 Geometry를 처리하는 시간보다 CPU가 작은 Draw를 반복해서 준비하는 시간이 병목이 될 수 있다.

Batching은 이 반복을 줄이거나 Draw당 준비 비용을 낮추기 위해 필요하다.

---

## Draw Call에서 반복되는 작업

CPU는 Mesh를 그리기 전에 GPU가 사용할 상태와 Resource를 준비한다.

```text
Draw Call
├─ Shader Pass 선택
├─ Texture와 Sampler Bind
├─ Vertex / Index Buffer Bind
├─ Constant Buffer 설정
├─ Depth·Blend·Cull State 설정
└─ Draw Command 제출
```

Object마다 이 과정을 완전히 반복하면 CPU와 Graphics Driver 비용이 누적된다.

특히 작은 Mesh가 수천 개 존재하면 각 Draw의 GPU 작업은 작아도 CPU Command 제출량은 클 수 있다.

---

## Batching의 핵심 목적

Unity 공식 문서는 Batching을 같은 Material을 사용하는 Mesh를 결합해 Render State Update를 줄이는 Draw Call 최적화 방식으로 설명한다.

```text
호환되는 Renderer 수집
        │
        ▼
공통 Render State 확인
        │
        ▼
Mesh 또는 Command를 Batch로 구성
        │
        ▼
더 적은 State Update와 효율적인 Draw 제출
```

핵심은 GameObject 수 자체를 줄이는 것이 아니다.

논리적으로 독립된 Object를 유지하면서 Rendering 단계에서 공통 작업을 재사용하는 것이다.

---

## Batch는 무조건 Draw 하나를 의미하지 않는다

Batching이라는 용어는 여러 최적화 구조를 포함한다.

```text
Mesh Batching
└─ 여러 Mesh Data를 결합해 적은 Draw로 처리

GPU Instancing
└─ 같은 Mesh의 여러 Instance를 Instanced Draw로 처리

SRP Batcher
└─ 여러 Draw 사이의 Bind와 State Update 비용을 줄임
```

SRP Batcher는 Draw Call을 모두 하나로 합치는 방식이 아니다.

동일 Shader Variant를 사용하는 Draw 사이에서 Material Data와 Render State 준비를 효율화한다.

따라서 `Batching 활성화 = Draw Call 숫자가 반드시 크게 감소`라고 이해하면 안 된다.

---

## 반복되는 State를 재사용한다

같은 Material을 쓰는 Object를 연속으로 처리하면 Shader와 Texture를 계속 바꿀 필요가 없다.

```text
Material X
├─ Object A
├─ Object B
└─ Object C

Shader X / Texture X Bind
├─ Object A Data → Draw
├─ Object B Data → Draw
└─ Object C Data → Draw
```

여기서 Mesh까지 결합할 수 있다면 하나의 Draw로 줄일 수 있다.

Mesh를 결합하지 않더라도 SRP Batcher처럼 공통 State와 GPU Buffer를 효율적으로 재사용할 수 있다.

어떤 방식이 적합한지는 Object가 움직이는지, Mesh가 같은지와 Shader Data 구조에 따라 달라진다.

---

## 작은 Draw가 많은 경우

바닥 Tile 5000개가 각각 두 Triangle이라고 가정한다.

```text
Geometry
5000 × 2 Triangles = 10,000 Triangles

Draw
5000 Renderer → 최대 수천 Draw 후보
```

10,000 Triangle은 GPU에 매우 작을 수 있지만 수천 번의 Culling, State 확인과 Draw Command 준비는 CPU에 부담이 될 수 있다.

Batching이 효과적인 대표적인 상황이다.

```text
GPU Work는 작음
CPU Submission은 많음
→ CPU Rendering 병목 가능
```

---

## 큰 Draw 하나가 비싼 경우와는 다르다

Fullscreen Shader 하나는 Draw Call이 하나뿐이어도 수백만 Pixel에서 복잡한 계산을 할 수 있다.

```text
Draw Call 1
× 3840 × 2160 Pixel
× 복잡한 Fragment Shader
→ 높은 GPU 비용 가능
```

Batching은 Draw 제출 문제를 다루며 Fragment Shader, Overdraw와 Texture Bandwidth를 자동으로 줄이지 않는다.

CPU가 병목이 아닌 Scene에서는 Batching 후에도 전체 Frame Time 변화가 작을 수 있다.

---

## 무엇이 같은 상태여야 할까?

Batching 기법마다 조건은 다르지만 일반적으로 다음 요소의 호환성이 중요하다.

```text
Compatibility
├─ Material 또는 Shader Variant
├─ Shader Pass
├─ Texture와 Keyword
├─ Vertex Layout
├─ Lightmap과 Lighting Data
├─ Render Queue
├─ Shadow Pass에서 사용하는 Property
└─ Transform·Mesh의 처리 가능 방식
```

두 Object가 같은 색으로 보인다고 내부 Rendering 상태도 같다는 의미는 아니다.

서로 다른 Shader Keyword 하나가 다른 Variant를 선택해 Batch를 끊을 수 있다.

---

## Material이 중요한 이유

Material은 GPU Rendering 상태와 Shader Property의 묶음이다.

```text
Material A
├─ Shader: Lit
├─ BaseMap: Brick
├─ NormalMap: On
└─ Surface: Opaque

Material B
├─ Shader: Lit
├─ BaseMap: Metal
├─ NormalMap: Off
└─ Surface: Opaque
```

같은 Shader 이름을 사용해도 Texture와 Keyword가 다르면 같은 방식으로 묶이지 않을 수 있다.

Renderer마다 Material을 복제하면 동일한 Property를 가진 것처럼 보여도 공유 상태가 깨질 수 있다.

Material 다양성과 Batching의 자세한 관계는 이후 글에서 다룬다.

---

## Shader Variant가 Batch를 끊는 이유

Keyword 조합이 다르면 Compiler가 다른 Shader Variant를 선택할 수 있다.

```text
Variant A
_NORMALMAP
_MAIN_LIGHT_SHADOWS

Variant B
_NORMALMAP
_MAIN_LIGHT_SHADOWS
_EMISSION
```

GPU가 실행할 Program이나 Pipeline State가 달라지면 같은 Batch에서 연속 처리하기 어려워진다.

SRP Batcher도 같은 Shader가 아니라 같은 Shader Variant를 사용하는 연속 Draw에서 가장 효율적이다.

불필요한 Keyword와 Material Feature 다양성을 줄이는 것이 중요한 이유다.

---

## Texture Atlas가 도움을 주는 이유

Object마다 다른 Texture를 Bind하면 Material과 State가 나뉠 수 있다.

Texture Atlas는 여러 Image를 하나의 큰 Texture에 배치한다.

```text
Texture Atlas
┌────────┬────────┐
│ Brick  │ Metal  │
├────────┼────────┤
│ Wood   │ Stone  │
└────────┴────────┘
```

각 Mesh는 다른 UV 영역을 사용하지만 동일한 Atlas Texture와 Material을 공유할 수 있다.

```text
다른 Texture Bind 4개
        ↓
공유 Atlas Bind 1개
```

Atlas는 Padding, Mipmap Bleeding, 압축 Format과 최대 Texture 크기 같은 Trade-off가 있다.

---

## Object Transform이 서로 다른 문제

각 Object는 다른 Position, Rotation과 Scale을 가진다.

```text
Object A → Matrix A
Object B → Matrix B
Object C → Matrix C
```

Batching 방식은 이 차이를 서로 다른 방식으로 처리한다.

```text
Static Batching
└─ Vertex를 World Space 기준 Buffer에 구성

Dynamic Batching
└─ CPU가 Runtime에 Vertex를 World Space로 변환해 결합

GPU Instancing
└─ Instance별 Matrix를 GPU에 전달

SRP Batcher
└─ Object Data를 효율적인 GPU Buffer 경로로 갱신
```

이 차이 때문에 모든 Object에 하나의 Batching 방식이 적합하지 않다.

---

## Static Batching의 방향

움직이지 않는 Mesh Renderer는 사전에 Geometry Data를 결합하기 쉽다.

```text
Static Object A Mesh ┐
Static Object B Mesh ├─ Combined Vertex / Index Buffer
Static Object C Mesh ┘
```

Runtime에 매 Frame Vertex를 다시 결합하지 않고 공통 Material의 Mesh를 효율적으로 그릴 수 있다.

대신 World Space Vertex Data와 결합 Buffer 때문에 Memory 사용량이 증가할 수 있다.

Transform이 바뀌는 Object에는 적합하지 않다.

구체적인 동작과 제약은 다음 글에서 다룬다.

---

## Dynamic Batching의 방향

작은 움직이는 Mesh를 Runtime에 CPU가 변환해 하나의 Draw로 묶는 방식이다.

```text
Local Vertices
    │ CPU Transform
    ▼
World Space Vertices
    │ Combine
    ▼
Single Draw
```

Draw Call은 줄지만 CPU가 Vertex를 변환하고 결합하는 비용이 생긴다.

현대 Graphics API에서는 Draw Call 자체가 더 저렴해 Dynamic Batching 준비 비용이 오히려 클 수 있다.

Unity 6 공식 문서도 대부분의 용도에서 Dynamic Batching을 권장하지 않으며 낮은 사양 Device의 제한적인 경우를 제시한다.

---

## GPU Instancing의 방향

같은 Mesh와 Material을 여러 번 배치할 때 GPU Hardware의 Instance Drawing을 사용한다.

```text
Mesh: Tree
Material: Leaves

Instance Data
├─ Transform 0
├─ Transform 1
├─ Transform 2
└─ ...

→ Instanced Draw
```

CPU가 각 Mesh Geometry를 결합할 필요 없이 Instance별 Data를 전달한다.

같은 Tree, Rock, Prop와 Projectile처럼 반복 Mesh가 많은 Scene에 적합하다.

서로 다른 Mesh를 하나의 Instance Draw로 만드는 기능은 아니다.

---

## SRP Batcher의 방향

SRP Batcher는 URP와 HDRP 같은 Scriptable Render Pipeline에서 Draw 준비 비용을 줄인다.

```text
Traditional
Material 변경마다 Property 수집과 Buffer Bind 반복

SRP Batcher
Material Data를 GPU Memory에 유지
동일 Shader Variant의 Bind + Draw Command를 연속 처리
```

Draw Call 수가 그대로여도 CPU가 Material State를 설정하는 비용이 줄 수 있다.

Unity 공식 문서는 SRP Batcher를 전통적인 Draw 수 감소 대신 Draw 사이의 Render State 변경을 줄이는 방식으로 설명한다.

따라서 Profiler에서 Draw Call 수만 보고 효과가 없다고 판단하면 안 된다.

---

## 네 방식의 큰 차이

| 방식 | 주 대상 | 줄이는 핵심 비용 | 주요 Trade-off |
| --- | --- | --- | --- |
| Static Batching | 움직이지 않는 서로 다른 Mesh | Mesh Draw와 State Update | Memory, Static 조건 |
| Dynamic Batching | 작은 움직이는 Mesh | Draw 수 | CPU Vertex 결합 비용 |
| GPU Instancing | 같은 Mesh의 반복 | Instance Draw 수 | 호환 Material·Shader 조건 |
| SRP Batcher | 같은 Shader Variant의 Material | Draw당 State 설정 CPU 시간 | Shader 구조와 Variant 호환성 |

이 표는 선택 방향을 보여 주는 요약이다.

각 방식의 정확한 조건과 측정법은 이어지는 글에서 하나씩 다룬다.

---

## Batching이 깨지는 일반적인 이유

```text
Batch Break
├─ 다른 Material 또는 Shader Variant
├─ 다른 Render Queue나 Shader Pass
├─ 호환되지 않는 Vertex Attribute
├─ 서로 다른 Lightmap 조건
├─ Transparent Sorting 순서
├─ Negative Scale과 Transform 조건
├─ Skinned Mesh Renderer
└─ Batching 한도 초과
```

정확한 원인은 적용한 Batching 방식과 Unity Version에 따라 다르다.

`같은 Material인데 왜 묶이지 않는가`라는 질문에는 Renderer, Pass, Lightmap, Transform과 Shader Keyword를 모두 확인해야 한다.

---

## Transparent Object의 제약

Transparent Object는 Alpha Blend 결과를 위해 일반적으로 Camera에서 먼 순서부터 그린다.

```text
Camera
  │
  ├─ Transparent C: Far
  ├─ Transparent B
  └─ Transparent A: Near

Rendering Order: C → B → A
```

Material 기준으로 자유롭게 재정렬하면 Blend 결과가 달라질 수 있다.

따라서 Opaque보다 State 기반 Batching 기회가 제한될 수 있다.

Transparency Sorting, Overdraw와 Batching을 함께 고려해야 한다.

---

## Skinned Mesh의 제약

Unity의 일반 Mesh Batching은 Mesh Renderer를 대상으로 하며 Skinned Mesh Renderer를 지원하지 않는 경우가 있다.

```text
Skinned Mesh
├─ Bone Matrix
├─ Vertex Weight
├─ Pose별 Vertex Position
└─ Object별 Animation 상태
```

Character마다 Pose가 다르면 단순하게 Vertex Buffer를 합쳐 같은 방식으로 그리기 어렵다.

Crowd Rendering은 GPU Skinning, LOD, Animation Instancing이나 전용 System 같은 별도 접근이 필요할 수 있다.

---

## Lightmap이 Batch 조건에 영향을 주는 이유

Baked Lighting을 사용하는 Renderer는 Lightmap Texture와 Scale·Offset Data를 참조한다.

```text
Renderer A
├─ Lightmap 0
└─ UV ScaleOffset A

Renderer B
├─ Lightmap 1
└─ UV ScaleOffset B
```

서로 다른 Lightmap Texture를 Bind해야 하면 공통 상태로 묶기 어려울 수 있다.

같은 Lightmap Atlas를 쓰더라도 Renderer별 UV Scale·Offset을 처리할 수 있는 Batching 경로가 필요하다.

Lighting Bake 후 Batch 상태가 달라지는 이유 중 하나다.

---

## Shadow Pass의 Batching

Camera Color Pass에서 Material Texture가 다르더라도 ShadowCaster Pass가 사용하는 Property가 같으면 Shadow Draw는 묶일 수 있다.

```text
Color Pass
Crate A: Texture A
Crate B: Texture B
→ 서로 다른 State 가능

Shadow Pass
둘 다 Opaque Depth만 기록
→ 사용 Property가 같으면 Batch 가능성
```

반대로 Alpha Clipping Caster는 Base Map Alpha와 Cutoff가 필요해 Material 차이가 Shadow Batch에도 영향을 줄 수 있다.

Pass마다 Batching 조건이 같다고 가정하지 않는다.

Frame Debugger에서 Color와 Shadow Pass를 따로 확인한다.

---

## Batching과 Culling의 관계

Renderer를 크게 결합하면 Draw 수는 줄지만 개별 Culling이 어려워질 수 있다.

```text
분리된 100 Mesh
├─ Draw 많음
└─ Camera 밖 90개 Culling 가능

결합 Mesh 1개
├─ Draw 적음
└─ 일부만 보여도 전체 Geometry 처리 가능
```

CPU Draw 비용을 줄인 대신 GPU가 보이지 않는 Geometry를 더 처리할 수 있다.

Scene 전체를 하나로 합치는 것보다 Spatial Cell, Room이나 Chunk 단위로 묶는 편이 균형을 잡기 쉽다.

---

## Batching과 Occlusion Culling

큰 Combined Mesh의 Bounds가 넓으면 작은 일부만 보이거나 Occluder 뒤에서 튀어나와도 전체가 Visible로 판정될 수 있다.

```text
Large Bounds
┌────────────────────────────┐
│ Hidden Geometry      Visible│
└────────────────────────────┘
                         Camera
```

Draw Call은 줄지만 Occlusion Culling의 Granularity가 낮아진다.

실내 Room, Corridor와 Open World Chunk 크기를 정할 때 Batching과 Visibility를 함께 측정한다.

---

## Batching과 Memory

일부 Batching 방식은 성능을 위해 Memory를 더 사용한다.

```text
Static Batching 예시
Local Vertex Data
        +
World Space Combined Buffer
        =
추가 Memory 가능
```

GPU Instancing은 Mesh Data를 공유하지만 Instance Buffer가 필요하다.

Texture Atlas는 Bind 수를 줄이지만 큰 Texture와 Padding을 사용한다.

Batching을 CPU 최적화로만 보고 Memory 비용을 무시하면 저사양 Platform에서 문제가 될 수 있다.

---

## Batching과 업데이트 비용

움직이지 않는 Data는 미리 구성할 수 있지만 자주 변하는 Data는 다시 갱신해야 한다.

```text
Static Data
└─ Build Time 또는 Load Time에 Batch 가능

Dynamic Data
└─ Runtime Transform·Property Update 필요
```

매 Frame 큰 Mesh를 결합하거나 Material Property를 계속 바꾸면 Batching으로 절약한 Draw 비용보다 Data Update가 커질 수 있다.

`묶을 수 있는가`뿐 아니라 `묶음을 얼마나 자주 다시 만들어야 하는가`를 확인한다.

---

## MaterialPropertyBlock과 Batch

Renderer별로 Material을 복제하지 않고 Property를 다르게 주기 위해 `MaterialPropertyBlock`을 사용할 수 있다.

```text
Shared Material
├─ Renderer A: Color Red
├─ Renderer B: Color Blue
└─ Renderer C: Color Green
```

하지만 적용한 Rendering 경로와 Batching 방식에 따라 PropertyBlock이 Batch 호환성에 영향을 줄 수 있다.

예를 들어 SRP Batcher에서는 Renderer별 Property가 호환 경로를 깨뜨릴 수 있고 GPU Instancing에서는 Instanced Property로 설계할 수 있다.

구체적인 사용 기준은 이후 글에서 다룬다.

---

## Batch가 커질수록 항상 좋은 것은 아니다

```text
매우 큰 Batch
├─ State Update와 Draw 감소
├─ Culling Granularity 감소
├─ Memory 증가 가능
├─ Update 범위 증가 가능
└─ 일부만 보여도 많은 Geometry 처리 가능
```

작은 Batch는 Culling에 유리하지만 Draw가 많아진다.

```text
최적 Batch 크기
= CPU Submission 절약
  vs GPU 불필요 작업
  vs Memory와 Update 비용
```

이 균형은 Scene 밀도와 Camera 이동 방식에 따라 달라진다.

---

## CPU 병목에서 기대할 수 있는 효과

CPU가 Render State Update와 Draw Command 준비에 많은 시간을 쓴다면 Batching 효과가 크다.

```text
Before
Main / Render Thread: 10 ms
GPU: 6 ms

Batching으로 CPU Draw 준비 감소

After
Main / Render Thread: 6 ms
GPU: 6 ms
```

GPU가 이미 여유가 있다면 CPU 시간이 줄면서 Frame Rate가 개선될 수 있다.

특히 저성능 CPU, 높은 목표 FPS와 많은 작은 Renderer 조합에서 중요하다.

---

## GPU 병목에서는 결과가 다를 수 있다

```text
Before
CPU: 5 ms
GPU: 18 ms

Batching 후
CPU: 3 ms
GPU: 18 ms
```

CPU Headroom은 늘었지만 Frame Time은 GPU 18 ms에 의해 결정된다.

더 큰 Batch가 Culling을 악화시키면 GPU 시간은 오히려 늘 수도 있다.

이 경우 Shader, Overdraw, Resolution, Triangle과 Memory Bandwidth 최적화가 더 직접적이다.

---

## Batching 준비 비용도 측정한다

Batch를 만들고 유지하는 작업 자체가 공짜가 아니다.

```text
Batching Cost
├─ 호환성 검사
├─ Renderer 정렬
├─ Vertex 변환·결합 가능성
├─ Combined Buffer 생성
├─ Instance Data Upload
└─ Material·Object Buffer Update
```

Dynamic Batching은 작은 Mesh를 CPU에서 변환하는 비용이 Draw Call보다 클 수 있다.

Runtime에 자주 생성·삭제되는 Object는 Batch 재구성 비용을 확인해야 한다.

결과 Draw 수만 보지 말고 Batching 준비에 사용된 CPU Marker도 함께 본다.

---

## 적합한 방식을 고르는 질문

```text
Object가 움직이는가?
├─ 아니오 → Static Batching 후보
└─ 예
   ├─ 같은 Mesh를 반복하는가?
   │  ├─ 예 → GPU Instancing 후보
   │  └─ 아니오 → SRP Batcher 또는 제한적 Dynamic 검토
   └─ Skinned Mesh인가? → 별도 Crowd / Skinning 전략 검토
```

추가 질문은 다음과 같다.

- 같은 Material 또는 Shader Variant인가?
- Renderer별 Property가 필요한가?
- Object를 개별 Culling해야 하는가?
- Memory 증가를 허용할 수 있는가?
- Object가 Runtime에 자주 생성·변경되는가?
- Target Graphics API에서 Draw Call 비용이 큰가?

하나의 기능을 전체 Scene에 일괄 적용하기보다 Object 집단별로 선택한다.

---

## Unity Stats에서 확인할 수치

Game View의 Stats와 Rendering Profiler에서 다음 값을 본다.

```text
Rendering Statistics
├─ Batches
├─ Saved by batching
├─ SetPass Calls
├─ Draw Calls
├─ Triangles
└─ Vertices
```

`Saved by batching`이 높아도 Batch를 만들기 위한 CPU 비용과 GPU 작업량을 알 수는 없다.

`Batches`가 낮아졌어도 `SetPass Calls`가 많다면 Material과 Shader Pass 전환이 남아 있을 수 있다.

수치는 원인을 찾는 단서이며 최종 성능은 ms로 비교한다.

---

## Frame Debugger로 Batch Break를 찾는다

Frame Debugger는 Draw Event가 어떤 이유로 분리되었는지 추적하는 데 유용하다.

```text
Event 120: Material X / Shader Variant A
Event 121: Material X / Shader Variant B
           ↑ Keyword 차이로 분리 가능
Event 122: Material Y
```

다음을 확인한다.

- Material과 Shader Variant가 같은가?
- Pass와 Render Queue가 같은가?
- Lightmap Index가 다른가?
- Transparent Sorting이 필요한가?
- Renderer가 Static 조건을 만족하는가?
- Instancing Property가 올바르게 선언됐는가?
- Shadow Pass에서는 다른 결과가 나오는가?

Batch가 안 된다는 결과보다 그 이유를 찾아야 올바른 방식을 선택할 수 있다.

---

## SRP Batcher Profiler

URP에서는 SRP Batcher 호환 여부와 Batch가 끊기는 원인을 별도로 확인할 수 있다.

```text
SRP Batch Break 예시 원인
├─ 다른 Shader Variant
├─ 호환되지 않는 Constant Buffer 구조
├─ 다른 Pass
└─ Renderer별 Data 경로 변화
```

SRP Batcher가 활성화됐다는 Project 설정만으로 모든 Shader가 호환된다고 단정할 수 없다.

Custom Shader의 `UnityPerMaterial`, `UnityPerDraw` Constant Buffer 규칙과 Profiler 결과를 확인한다.

자세한 Shader 구조는 SRP Batcher 글에서 다룬다.

---

## 비교할 때 고정할 조건

Batching 전후에는 동일한 Rendering 조건을 유지한다.

- Camera 위치와 이동 경로
- Visible Renderer 수
- Shadow와 Light 설정
- Render Scale과 화면 해상도
- Material과 Shader Keyword
- Graphics API와 Build Type
- VSync와 Frame Cap
- LOD와 Occlusion Culling 상태

```text
Before
CPU Render Thread: 8.4 ms
Batches           : 2800
SetPass Calls     : 620
GPU               : 9.1 ms

After
CPU Render Thread: 5.7 ms
Batches           : 1300
SetPass Calls     : 210
GPU               : 9.0 ms
```

예시처럼 수치와 CPU·GPU 시간을 함께 기록한다.

---

## 품질과 기능 회귀

Batching 변경은 화면과 Object 동작에도 영향을 줄 수 있다.

```text
검증 항목
├─ Lightmap UV와 Baked Lighting
├─ Material Property 차이
├─ Animation과 Transform
├─ LOD 전환
├─ Shadow Casting
├─ Transparent Sorting
├─ Culling과 Bounds
└─ Runtime 생성·삭제
```

Mesh를 결합한 뒤 Object별 Color 변경이나 Destruction이 어려워질 수 있다.

Static으로 표시한 Object를 움직이면 기대한 결과와 성능이 깨질 수 있다.

최적화 후 기능 요구사항을 유지하는지도 반드시 확인한다.

---

## 흔한 오해

### Batching은 모든 Object를 한 Draw Call로 만든다

Material, Shader Pass, Mesh, Transform과 Lighting 조건이 호환되는 작업만 묶을 수 있다.

### Batch 수가 낮으면 항상 빠르다

큰 Batch의 Culling이 나빠지거나 GPU가 많은 Geometry와 Pixel을 처리하면 전체 Frame은 느릴 수 있다.

### 같은 Material이면 반드시 Batch된다

Shader Variant, Lightmap, Vertex Layout, Transform과 Batching 방식의 한도도 영향을 준다.

### SRP Batcher는 Draw Call을 줄이는 기능이다

주요 목적은 동일 Shader Variant를 사용하는 Draw 사이의 CPU Render State와 Material Data 준비 비용을 줄이는 것이다.

### Dynamic Batching은 항상 켜는 것이 좋다

Runtime CPU Vertex 변환 비용이 Draw Call 절약보다 클 수 있어 Unity 6에서는 대부분의 용도에 권장되지 않는다.

### Static Batching은 Memory를 사용하지 않는다

결합된 World Space Vertex·Index Buffer 때문에 추가 Memory가 필요할 수 있다.

### Mesh를 모두 합치면 최적이다

개별 Culling, LOD, Material 변경과 Runtime 상호작용이 제한되고 GPU의 불필요한 작업이 늘 수 있다.

### GPU Instancing은 서로 다른 Mesh도 묶는다

기본적으로 같은 Mesh와 Material을 반복해서 그리는 데 적합하다.

### Batching은 GPU 최적화 기능이다

주된 목표는 CPU의 State Update와 Draw 제출 부담을 줄이는 것이며 GPU 효과는 Culling과 Data 구조에 따라 달라진다.

---

## 적용 순서

```text
1. CPU Rendering 병목인지 확인
2. Frame Debugger로 Draw와 Batch Break 원인 확인
3. Material·Shader Variant 다양성 정리
4. Object 특성별 방식 선택
   ├─ Static Mesh
   ├─ 반복 Mesh
   ├─ 움직이는 작은 Mesh
   └─ 같은 Shader Variant의 다양한 Material
5. Culling·Memory·Update Trade-off 확인
6. Target Device에서 CPU·GPU 시간 재측정
7. 화면과 기능 회귀 검사
```

Batching 옵션을 먼저 켜고 효과를 기대하기보다 어떤 반복 작업을 줄일 것인지 정의한다.

Draw Call 수뿐 아니라 SetPass Calls, Render Thread Time과 GPU 작업량을 함께 비교한다.

---

## 정리

Batching은 호환되는 여러 Renderer의 Mesh나 Draw Command를 묶어 CPU의 Render State 변경과 Draw 제출 비용을 줄이는 최적화 방식이다.

작은 Mesh가 많아 GPU Geometry 비용은 낮지만 CPU Command 준비가 많은 Scene에서 특히 효과적이다.

같은 Material, Shader Variant, Pass, Texture와 Lighting Data 같은 Rendering 상태의 호환성이 Batch 형성에 중요하다.

Static Batching은 움직이지 않는 Mesh를 결합하고 Dynamic Batching은 작은 Mesh를 CPU에서 변환하며 GPU Instancing은 같은 Mesh의 Instance를 한 번에 그린다.

SRP Batcher는 Draw Call 자체를 모두 합치기보다 동일 Shader Variant 사이의 Bind와 Material Data 준비 비용을 낮춘다.

Batch를 크게 만들면 Draw는 줄지만 개별 Culling, LOD와 Runtime 변경이 어려워지고 Memory와 불필요한 GPU 작업이 증가할 수 있다.

Batching의 효과는 `Batches` 숫자만 아니라 `SetPass Calls`, CPU Main·Render Thread, GPU Frame Time과 Memory를 함께 측정해 판단해야 한다.

Object의 이동 여부, Mesh 반복성, Material 호환성과 Target Device 병목에 맞는 방식을 선택해야 한다.
