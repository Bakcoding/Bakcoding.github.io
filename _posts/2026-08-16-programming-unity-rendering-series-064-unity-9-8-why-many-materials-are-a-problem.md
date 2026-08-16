---
title: "[Unity 렌더링] 9-8. Material이 많으면 왜 문제가 될까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - Material
  - DrawCall
  - Optimization
permalink: /programming/unity-9-8-why-many-materials-are-a-problem/
toc: true
toc_sticky: true
date: 2026-08-16
last_modified_at: 2026-08-16
---

Material은 Shader와 Texture, Color, Keyword와 Surface State를 묶어 Object의 표면을 정의한다.

```text
Material
├─ Shader와 Variant
├─ Texture Reference
├─ Color·Float·Vector
├─ Keyword
├─ Blend·Depth·Cull 설정
└─ Render Queue
```

Material이 많으면 CPU가 Rendering State를 더 자주 바꾸고 Draw Batch가 잘게 나뉠 수 있다.

고유 Texture와 Shader Variant까지 함께 늘면 GPU Memory, Build Size, Load Time과 Shader Compilation 비용도 커질 수 있다.

그러나 Material Asset 개수 자체보다 현재 Frame에 실제로 사용되는 서로 다른 Rendering State가 중요하다.

---

## Material은 Shader가 아니다

Shader는 GPU가 실행할 Program을 정의하고 Material은 그 Shader에 전달할 값과 상태를 저장한다.

```text
Shader: URP Lit
├─ Material Brick
│  ├─ BaseMap: Brick.png
│  └─ Smoothness: 0.2
├─ Material Metal
│  ├─ BaseMap: Metal.png
│  └─ Metallic: 1.0
└─ Material Wood
   ├─ BaseMap: Wood.png
   └─ Smoothness: 0.4
```

세 Material은 같은 Shader를 사용하지만 Property와 Texture가 다르다.

같은 Shader Asset을 사용한다고 같은 Material이나 같은 Render State라는 의미는 아니다.

---

## Material Asset 수와 Runtime 비용은 다르다

Project에 Material Asset이 10,000개 있어도 현재 Scene과 Build에서 사용하지 않으면 한 Frame의 Draw Call을 직접 늘리지 않는다.

```text
Project Material Asset 10,000개
└─ 현재 Camera에서 Visible Material 20개
   └─ Frame Rendering은 주로 20개 상태의 영향
```

반대로 Project Asset은 100개뿐이어도 Visible Renderer가 Material을 계속 교차 사용하면 State 전환이 많아질 수 있다.

```text
Frame Order
A → B → C → A → D → B → C
```

다음 값을 구분한다.

- Project 전체 Material Asset 수
- Build에 포함된 Material 수
- Load된 Material Instance 수
- 현재 Camera에서 Visible한 Material 수
- Frame에서 실제 발생한 Shader Pass와 State 전환 수

---

## Material마다 State가 달라질 수 있다

GPU는 다음 Draw를 처리하기 전에 Material이 요구하는 Resource와 Pipeline State를 사용해야 한다.

```text
Material A
├─ Shader Variant A
├─ Texture Brick
├─ Opaque
└─ Depth Write On

Material B
├─ Shader Variant B
├─ Texture Glass
├─ Transparent
└─ Blend SrcAlpha OneMinusSrcAlpha
```

A에서 B로 바뀌면 Shader, Texture, Blend와 Depth State를 전환해야 한다.

이 과정은 CPU의 Command 준비와 GPU Pipeline Setup 비용을 만든다.

---

## SetPass Call과의 관계

Unity Profiler의 `SetPass Calls`는 Unity가 GameObject를 그릴 Shader Pass를 전환한 횟수다.

```text
Pass X
├─ Draw Object 0
├─ Draw Object 1
└─ Draw Object 2

SetPass → Pass Y
├─ Draw Object 3
└─ Draw Object 4
```

Material이 서로 다른 Shader Pass와 Variant를 요구하면 SetPass가 늘 수 있다.

SetPass 전환은 Draw Command 자체보다 무거운 CPU State 변경이 될 수 있다.

Material 수를 볼 때 Draw Calls, Batches와 SetPass Calls를 함께 보는 이유다.

---

## 같은 Material을 공유하면 유리한 이유

여러 Renderer가 하나의 Material Asset을 참조하면 Shader, Texture와 Property State를 공유한다.

```text
Shared Brick Material
├─ Wall A
├─ Wall B
├─ Wall C
└─ Wall D
```

Unity는 같은 State를 사용하는 Draw를 연속 처리하거나 Static Batching과 GPU Instancing 조건을 만들기 쉽다.

```text
Bind Brick Material
├─ Draw Wall A
├─ Draw Wall B
├─ Draw Wall C
└─ Draw Wall D
```

Unity 공식 Draw Call 최적화 문서도 가능한 한 여러 GameObject에서 같은 Material을 사용하도록 권장한다.

---

## 값이 같은 별도 Material은 공유 Material이 아니다

다음 두 Material이 Inspector에서 완전히 같은 값처럼 보여도 서로 다른 Asset일 수 있다.

```text
Brick_A.mat
├─ BaseMap Brick.png
└─ Color White

Brick_B.mat
├─ BaseMap Brick.png
└─ Color White
```

Rendering Pipeline과 Batching 방식에 따라 같은 State로 연속 처리될 수는 있지만 자동으로 같은 Material Instance가 되는 것은 아니다.

GPU Instancing처럼 같은 Material 참조가 필요한 방식에서는 별도 Group으로 나뉠 수 있다.

중복 Material Asset을 정리하면 Authoring과 Runtime 상태를 예측하기 쉬워진다.

---

## Material 하나가 Draw 하나라는 의미는 아니다

같은 Material을 사용해도 Mesh와 Transform이 다르면 여러 Draw Call이 남을 수 있다.

```text
Material X
├─ Mesh A → Draw
├─ Mesh B → Draw
└─ Mesh C → Draw
```

SRP Batcher는 이 Draw 사이의 State 준비를 줄이고 GPU Instancing은 같은 Mesh까지 반복될 때 Draw 수를 줄일 수 있다.

Material 공유는 Batching의 중요한 조건이지 Draw 하나를 보장하는 조건은 아니다.

---

## 한 Mesh의 Material Slot

Mesh Renderer에 여러 Material Slot이 있으면 SubMesh마다 별도 Draw가 필요하다.

```text
Character Mesh
├─ SubMesh 0: Skin Material  → Draw 1
├─ SubMesh 1: Hair Material  → Draw 2
├─ SubMesh 2: Eye Material   → Draw 3
└─ SubMesh 3: Cloth Material → Draw 4
```

GameObject가 하나여도 Material Slot이 네 개면 Color Pass에서 최소 여러 Draw가 발생할 수 있다.

Depth와 Shadow Pass까지 포함되면 같은 SubMesh가 다시 그려질 수 있다.

불필요한 Slot과 실제 Triangle이 없는 Material Assignment를 확인한다.

---

## Material Slot이 Geometry를 반복할 수 있다

Mesh의 SubMesh 수보다 Renderer에 더 많은 Material을 지정하면 Unity가 Geometry를 추가 Pass처럼 다시 그리는 구성이 생길 수 있다.

```text
Mesh SubMesh 1개
Material Slot 여러 개
→ 같은 Geometry에 Material을 겹쳐 Rendering할 가능성
```

Outline이나 Layered Effect를 의도한 경우가 아니라면 불필요한 Draw와 Overdraw가 된다.

Frame Debugger에서 같은 Mesh가 연속해서 여러 번 Drawing되는지 확인한다.

---

## Shader Keyword가 Variant를 만든다

Material Feature를 켜고 끌 때 Shader Keyword가 바뀔 수 있다.

```text
Material A
_NORMALMAP
_MAIN_LIGHT_SHADOWS

Material B
_NORMALMAP
_EMISSION
_MAIN_LIGHT_SHADOWS
```

두 Material은 같은 Shader Asset을 사용하지만 다른 Compiled Shader Variant를 선택한다.

SRP Batcher에서는 Variant 전환이 SRP Batch를 끊을 수 있다.

GPU Instancing에서도 다른 Variant와 Material은 별도 Instance Group이 된다.

---

## Variant 조합은 빠르게 증가한다

On·Off Feature가 여러 개 있으면 가능한 조합 수가 곱해진다.

```text
Feature 2개 → 2²  = 4 Variants
Feature 5개 → 2⁵  = 32 Variants
Feature 10개 → 2¹⁰ = 1024 Variants
```

실제 Keyword Set은 단순한 Boolean만이 아니며 Unity는 필요 없는 Variant를 Strip할 수 있다.

그러나 Material이 다양한 Keyword 조합을 실제로 참조하면 더 많은 Variant가 Build에 포함될 수 있다.

---

## Shader Variant가 만드는 비용

Unity 공식 문서는 많은 Shader Variant의 단점을 다음과 같이 설명한다.

```text
많은 Shader Variants
├─ Shader Build Time 증가
├─ Build File Size 증가
├─ Runtime Shader Memory 증가
├─ Shader Loading Time 증가
├─ Prewarm 복잡도 증가
└─ Shader Compilation Stutter 가능
```

Material 수가 많다는 문제는 Material Object Memory뿐 아니라 각 Material이 어떤 Keyword 조합을 요구하는지까지 포함한다.

같은 Variant를 사용하는 Material 100개와 서로 다른 Variant를 사용하는 Material 100개는 비용 구조가 다르다.

---

## Variant는 왜 존재할까?

Variant는 Runtime Dynamic Branch 대신 특정 Feature 조합에 특화된 Shader Program을 제공한다.

```text
Variant A
Normal Mapping 코드 포함

Variant B
Normal Mapping 코드 제거
```

필요 없는 계산을 Compile 단계에서 제거해 GPU 실행을 효율화할 수 있다.

따라서 모든 Variant를 하나로 합치는 것이 항상 GPU에 유리한 것은 아니다.

Build·Memory·CPU State와 GPU Branch 비용 사이의 Trade-off를 결정해야 한다.

---

## Texture가 다르면 Resource Bind가 달라진다

같은 Shader Variant를 사용해도 Base Map이 다르면 다음 Draw 전에 다른 Texture를 Bind해야 한다.

```text
Material Brick → Texture Brick
Material Wood  → Texture Wood
Material Metal → Texture Metal
```

SRP Batcher는 Material Data 준비를 줄일 수 있지만 Texture Resource 변경을 완전히 없애는 기능은 아니다.

Material을 State 기준으로 정렬하면 같은 Texture를 사용하는 Draw를 연속 처리할 기회가 생긴다.

Transparent Sorting과 Depth 효율 때문에 자유로운 재정렬이 어려울 수도 있다.

---

## Texture Memory와 Material Memory를 구분한다

Material 여러 개가 같은 Texture Asset을 참조한다고 Texture Pixel Data가 Material마다 복제되는 것은 아니다.

```text
Shared Texture Brick.png
├─ Material Brick_Dry
├─ Material Brick_Wet
└─ Material Brick_Dark

→ Texture Asset Data는 공유 가능
```

각 Material의 Property와 Object Memory는 존재하지만 큰 Texture Data는 공통 Reference를 사용할 수 있다.

반대로 Material마다 고유한 4K Texture를 사용하면 Texture Memory가 크게 증가한다.

```text
100 Materials
× Unique 4K Textures
→ Texture Memory와 Streaming 부담 증가
```

---

## Texture Set은 여러 장일 수 있다

PBR Material 하나는 여러 Texture를 참조할 수 있다.

```text
PBR Material
├─ Base Map
├─ Normal Map
├─ Mask Map
├─ Emission Map
├─ Detail Map
└─ Height Map
```

Material 100개가 각각 고유한 Texture Set을 사용하면 실제 Texture Asset은 수백 장이 될 수 있다.

GPU Memory뿐 아니라 Disk Build Size, AssetBundle Load, Texture Streaming과 Upload 비용이 증가한다.

Material Asset 수보다 `Used Textures`와 실제 Texture Memory를 함께 확인한다.

---

## Texture Atlas

여러 작은 Texture를 하나의 Atlas에 배치하면 Material을 공유하기 쉬워진다.

```text
Texture Atlas
┌────────┬────────┐
│ Brick  │ Wood   │
├────────┼────────┤
│ Metal  │ Stone  │
└────────┴────────┘
```

Mesh마다 다른 UV 영역을 사용하지만 같은 Texture와 Material State를 유지할 수 있다.

```text
Before
4 Textures + 4 Materials

After
1 Atlas + 1 Shared Material
```

Batching과 Resource Bind에 유리할 수 있다.

---

## Atlas의 Trade-off

```text
Texture Atlas 비용
├─ UV 재배치
├─ Mipmap Bleeding Padding
├─ 서로 다른 Resolution 통합
├─ Wrap Mode 제한
├─ 압축 Format 통일
├─ Atlas 일부만 필요해도 전체 Load
└─ 큰 Texture Streaming Granularity
```

모든 Texture를 하나의 거대한 Atlas로 합치면 Memory Residency와 Streaming이 나빠질 수 있다.

같이 보이고 같이 Load되는 Object Group 단위로 Atlas를 구성한다.

---

## Texture Array

Texture Array는 같은 크기와 Format의 Texture Layer를 하나의 Resource로 묶는다.

```text
Texture2DArray
├─ Layer 0: Brick
├─ Layer 1: Wood
├─ Layer 2: Metal
└─ Layer 3: Stone
```

Shader는 Material이나 Instance별 Layer Index로 Texture를 선택한다.

UV를 Atlas 영역으로 다시 배치하지 않아도 되고 Mipmap Bleeding을 피하기 쉽다.

모든 Layer의 Resolution과 Format 조건, Shader 수정과 Platform 지원을 고려한다.

---

## Render Queue가 다르면 묶기 어렵다

Opaque, Alpha Clipping과 Transparent Material은 Rendering 순서와 State가 다르다.

```text
Opaque
├─ Depth Write On
└─ Front-to-Back 가능

Transparent
├─ Blend On
├─ Depth Write Off인 경우 많음
└─ Back-to-Front Sorting
```

같은 Shader를 사용해도 Surface Type과 Render Queue가 다르면 같은 Batch에서 처리할 수 없다.

Material 수를 줄이기 위해 서로 다른 Surface Type을 억지로 하나로 통합하면 GPU Branch와 Sorting 문제가 생긴다.

---

## Shader Pass 수가 다르면 비용이 달라진다

Material이 선택한 Shader는 여러 Pass를 가질 수 있다.

```text
URP Material Pass 후보
├─ ForwardLit
├─ ShadowCaster
├─ DepthOnly
├─ DepthNormals
└─ Meta
```

모든 Pass가 매 Frame 실행되는 것은 아니지만 Pipeline 기능에 따라 같은 Renderer가 여러 번 그려진다.

Material 하나의 추가 Feature가 DepthNormals나 Transparent Depth Pass를 활성화하면 Draw가 늘 수 있다.

Material Asset 개수보다 어떤 Pass가 실행되는지 Frame Debugger에서 확인한다.

---

## Material Property의 Memory

각 Material은 Shader Reference와 Serialized Property 값을 저장한다.

```text
Material Data
├─ Float·Vector·Color
├─ Texture Reference
├─ Keyword State
├─ Render Queue Override
├─ Pass Enable State
└─ GPU Constant Buffer Data
```

Material 하나의 Data는 대형 Texture보다 작을 수 있지만 수만 개가 Load되면 Managed·Native·GPU-side 관리 비용이 누적될 수 있다.

SRP Batcher는 Material별 Persistent Constant Buffer를 GPU Memory에 유지한다.

Material 수가 많아도 공짜가 되는 것은 아니다.

---

## SRP Batcher에서는 무엇이 달라질까?

SRP Batcher는 같은 Shader Variant를 사용하는 서로 다른 Material의 Draw를 긴 Batch로 처리할 수 있다.

```text
Material A: Red
Material B: Blue
Material C: Green

같은 Shader Variant
→ 같은 SRP Batch 가능
```

Material 값이 다르다는 이유만으로 무조건 SetPass가 발생하는 것은 아니다.

그러나 Material Buffer, Texture Binding, Asset Memory와 Variant 전환은 남는다.

`SRP Batcher가 있으니 Material 수는 상관없다`는 결론은 지나치다.

---

## GPU Instancing에서는 무엇이 달라질까?

GPU Instancing은 같은 Mesh와 Material을 공유하는 Instance Group에 적합하다.

```text
같은 Mesh + Material A → Instance Group A
같은 Mesh + Material B → Instance Group B
같은 Mesh + Material C → Instance Group C
```

색만 다른 Material 100개를 만들면 동일 Mesh도 100개 Instance Group으로 나뉠 수 있다.

색을 Instanced Property로 바꾸면 Shared Material 하나로 Group을 유지할 수 있다.

Texture와 Keyword처럼 Non-instanced State가 다르면 별도 Group이 필요하다.

---

## Material Variant는 무엇을 해결할까?

Material Variant는 Parent Material의 Property를 상속하고 필요한 값만 Override하는 계층 구조다.

```text
Parent: M_Wood_Base
├─ Child: M_Wood_Oak
├─ Child: M_Wood_Dark
└─ Child: M_Wood_Wet
```

Parent의 공통 Property를 바꾸면 Override하지 않은 Child에 변경이 전파된다.

Unity 공식 문서는 수백 Material을 복제하는 것보다 Material Variant가 관리하기 쉽다고 설명한다.

주요 목적은 대량 Material의 Authoring과 유지보수다.

---

## Material Variant가 Runtime Material을 하나로 만들까?

Material Variant Child는 Parent와 다른 Property를 가진 독립적인 Rendering 상태로 사용할 수 있다.

```text
Parent와 Child
├─ Authoring에서는 상속 관계
└─ Runtime에서는 필요한 Property State 존재
```

Material Variant를 사용했다고 모든 Child가 하나의 GPU Material Binding이나 Draw로 자동 합쳐지는 것은 아니다.

같은 Shader Variant를 유지하면 SRP Batcher에 유리할 수 있지만 Texture와 Keyword Override에 따라 State는 달라진다.

관리 편의와 Runtime Batching 효과를 구분해야 한다.

---

## Parent와 Override 설계

```text
Parent에서 고정할 것
├─ Shader
├─ Surface Type
├─ 공통 Keyword
├─ 공통 Texture Set
└─ 공통 Render State

Child에서 Override할 후보
├─ Color
├─ Smoothness
├─ Emission Strength
└─ 제한적인 Texture
```

Child마다 Keyword를 자유롭게 바꾸면 Variant와 Batch가 많이 나뉠 수 있다.

Parent 계층은 Art 규칙과 Rendering State 규칙을 함께 표현하도록 설계한다.

---

## Material을 Script에서 가져올 때

Renderer의 `material` Property는 해당 Renderer만을 위한 Material Instance를 만들 수 있다.

```csharp
Renderer targetRenderer = GetComponent<Renderer>();
Material runtimeMaterial = targetRenderer.material;
runtimeMaterial.color = Color.red;
```

원래 Shared Material을 직접 바꾸지 않고 Object 하나만 수정할 수 있다.

하지만 Renderer 수만큼 Instance가 생성되면 Material Memory와 Batching Group이 늘 수 있다.

단순히 값을 읽기 위해 `material`에 접근하는 Pattern도 의도하지 않은 Instance를 만들 수 있어 주의한다.

---

## sharedMaterial의 의미

`sharedMaterial`은 Renderer가 공유하는 Material Reference를 반환한다.

```csharp
Renderer targetRenderer = GetComponent<Renderer>();
Material shared = targetRenderer.sharedMaterial;
```

Runtime Instance를 만들지 않고 참조를 확인할 수 있다.

그러나 Shared Material의 Property를 수정하면 같은 Asset을 사용하는 모든 Renderer의 화면이 함께 바뀐다.

Editor에서 Asset 자체를 변경할 위험도 있으므로 읽기와 할당 용도로 신중하게 사용한다.

---

## Runtime Material Instance 누적

```text
1000 Renderers
각각 renderer.material 접근
→ 최대 수많은 Runtime Material Instance 가능
```

Scene 전환과 Object 파괴 시 생성한 Material의 Lifecycle을 관리하지 않으면 Native Object가 남을 수 있다.

```text
문제
├─ Material Memory 증가
├─ Shared State 깨짐
├─ GPU Instancing Group 분리
├─ Batch 수 증가 가능
└─ Cleanup 복잡도
```

Renderer별 변화가 꼭 필요한지 먼저 판단한다.

---

## MaterialPropertyBlock이라는 대안

Renderer별 Color나 Float만 다르게 주려면 Material을 복제하지 않고 `MaterialPropertyBlock`을 사용할 수 있다.

```text
Shared Material
├─ Renderer A: PropertyBlock Red
├─ Renderer B: PropertyBlock Blue
└─ Renderer C: PropertyBlock Green
```

GPU Instancing의 Instanced Property 전달에는 유용할 수 있다.

하지만 Unity 6 기준 URP·HDRP에서는 SRP Batcher와 호환되지 않아 성능이 낮아질 수 있다.

구체적인 사용 기준은 다음 글에서 다룬다.

---

## Global Shader Property

모든 Material이 같은 값을 사용한다면 Material마다 값을 갱신할 필요가 없다.

```csharp
Shader.SetGlobalFloat("_GlobalWetness", wetness);
```

```text
Global Property 후보
├─ World 전체 Wetness
├─ 공통 Snow Amount
├─ Global Wind Time
└─ Environment Tint
```

Global Property는 해당 이름을 사용하는 모든 Shader에 영향을 줄 수 있다.

Camera별·Object별 값에는 적합하지 않으며 Global State 의존성이 Debug를 어렵게 만들 수 있다.

---

## Constant Buffer와 Structured Buffer

대량 Object별 Data는 Material Instance 대신 Buffer에 모아 Index로 접근할 수 있다.

```text
Object Data Buffer
├─ Data 0: Color, Wind, State
├─ Data 1: Color, Wind, State
└─ Data N

Renderer / Instance ID → Buffer Index
```

GPU Instancing과 GPU-driven Rendering에 적합하다.

Custom Shader, Buffer Lifecycle, Platform 지원과 Synchronization 복잡도가 증가한다.

Material 수가 실제 병목으로 확인된 대규모 System에서 검토한다.

---

## Material 정렬

Opaque Renderer는 같은 Material과 Shader State를 연속 처리하도록 정렬할 수 있다.

```text
정렬 전
A → B → A → C → B → A

State 정렬 후
A → A → A → B → B → C
```

SetPass와 Resource Binding을 줄일 수 있다.

Front-to-Back 정렬은 Early-Z와 Overdraw에 유리하므로 Material 정렬과 목표가 충돌할 수 있다.

Transparent는 Back-to-Front 순서가 중요해 Material 기준 재정렬이 제한된다.

---

## UI Material

UI는 같은 Texture Atlas와 Material을 사용하는 Element를 Batch할 수 있다.

```text
Image Material A
Text Material B
Image Material A

→ A / B / A Batch로 분리 가능
```

Mask, Stencil, Custom Effect와 Font Material이 Batch를 끊을 수 있다.

UI Material 수를 줄여도 Canvas Rebuild와 Transparent Overdraw 비용은 별도로 남는다.

UI Profiler와 Frame Debugger에서 원인을 구분한다.

---

## Particle Material

Particle System마다 다른 Material과 Shader Pass를 사용하면 별도 Draw가 생긴다.

```text
Fire Material
Smoke Material
Spark Material
Distortion Material
```

같은 Atlas와 Shader를 공유하고 Instance별 UV·Color를 사용하면 Material Group을 줄일 수 있다.

하지만 Particle의 주요 GPU 병목이 Transparent Overdraw라면 Material 수 감소만으로 Frame Time이 크게 변하지 않을 수 있다.

---

## Decal과 Layered Material

표면 종류를 줄이기 위해 모든 Detail을 Base Material에 넣으면 Shader가 복잡해질 수 있다.

반대로 Decal과 Layered Material을 지나치게 사용하면 추가 Pass, Draw와 Texture Sample이 늘어난다.

```text
선택 A
많은 고유 Material·Texture

선택 B
공통 Base Material + Decal

선택 C
Atlas·Mask 기반 Layer
```

Memory, Draw Call, Overdraw와 Shader 비용을 함께 비교한다.

Material 개수 하나만 최소화하는 목표는 적절하지 않다.

---

## Addressables와 Material 중복

AssetBundle이나 Addressables Group이 나뉘면 같은 Material과 Texture가 여러 Bundle에 중복 포함될 수 있다.

```text
Bundle A → Material X → Texture T
Bundle B → Material X Copy → Texture T Copy 가능성
```

의존성 구성과 Asset Address가 잘못되면 Disk Size, Download와 Runtime Memory가 늘 수 있다.

Build Layout Report로 Material·Texture Dependency와 중복을 확인한다.

Scene의 Draw Call 문제와 Asset Packaging 중복 문제를 구분한다.

---

## Load와 Shader Warmup

Material이 참조하는 Shader Variant가 많으면 Scene Load와 첫 Rendering 시점에 Shader 준비가 필요하다.

```text
Scene Load
├─ Material Asset Load
├─ Texture Load / Streaming
├─ Shader Variant Load
├─ GPU Resource 생성
└─ 첫 사용 Pipeline 준비
```

필요한 Variant가 Prewarm되지 않았으면 Gameplay 중 Compilation Stutter가 나타날 수 있다.

모든 Variant를 무조건 Prewarm하면 시작 시간과 Memory가 늘어난다.

실제 사용 Material과 Variant를 기준으로 관리한다.

---

## 많은 Material이 문제가 아닐 수 있는 경우

```text
조건
├─ 대부분 현재 Scene에 Load되지 않음
├─ Visible Material 수가 적음
├─ 같은 Shader Variant를 사용함
├─ SRP Batcher가 긴 Batch를 유지함
├─ Texture Asset을 공유함
├─ Property가 자주 변하지 않음
└─ CPU·Memory Budget에 여유가 있음
```

이 경우 Project Asset 수가 많아도 Runtime Frame 비용은 허용 가능할 수 있다.

최적화를 위해 Art Workflow를 과도하게 제한하기 전에 실제 병목을 측정한다.

---

## 문제가 되기 쉬운 경우

```text
조건
├─ Visible Renderer마다 Material이 다름
├─ Keyword 조합이 모두 다름
├─ 고유 4K Texture Set을 사용함
├─ Material Slot이 많음
├─ Runtime Material Instance가 계속 생성됨
├─ Material Property를 매 Frame 갱신함
├─ SetPass Calls가 높음
└─ Shader Compilation Stutter가 발생함
```

한 가지 숫자보다 상태 전환, Variant, Texture Memory와 Lifecycle을 함께 해결해야 한다.

---

## Material 정리 순서

```text
1. 현재 Frame의 SetPass·Draw·Batch 확인
2. Frame Debugger로 Material 전환 원인 확인
3. 중복 Material Asset과 Runtime Instance 조사
4. Shader Variant·Keyword 조합 조사
5. 고유 Texture와 Memory 확인
6. 불필요한 Material Slot 제거
7. Shared Material·Variant·Atlas 후보 분류
8. Property 변경 방식 선택
9. Build·Load·Frame 성능 재측정
10. 화면과 Authoring Workflow 회귀 확인
```

Material 이름을 정리하는 것과 Runtime 성능을 개선하는 작업을 구분한다.

---

## Frame Debugger에서 확인할 항목

```text
Draw Event
├─ Material
├─ Shader와 Pass
├─ Shader Keyword
├─ Texture Binding
├─ Render Queue
├─ Batch Break Reason
└─ 같은 Mesh의 반복 Draw
```

Material이 바뀔 때 실제로 SetPass가 발생하는지, SRP Batch가 끊기는지 확인한다.

같은 Material인데도 Draw가 나뉘면 Mesh, Lightmap, Culling, Sorting과 Pass 조건을 본다.

---

## Profiler에서 확인할 항목

```text
Rendering
├─ SetPass Calls Count
├─ Draw Calls Count
├─ Batches Count
├─ Used Textures와 Memory
├─ Used Buffers와 Memory
└─ Main·Render Thread Time

Memory
├─ Material Object
├─ Texture Memory
├─ Shader Memory
└─ Native Object 수
```

Shader Build Log와 Variant Report로 Compile된 Variant 수를 확인한다.

Memory Profiler에서 동일 이름의 Runtime Material Instance와 중복 Texture를 찾는다.

---

## A/B Test

```text
Before
Material 500개
SetPass 400
Draw 2000
CPU Render 8 ms
Texture Memory 1.5 GiB

After
Shared Material·Atlas·Variant 정리
SetPass 150
Draw 1600
CPU Render 5 ms
Texture Memory 900 MiB
```

예시는 기록 형식을 보여 주는 값이며 고정된 개선 비율이 아니다.

같은 Camera, Visible Object, Resolution, Light와 Graphics API에서 비교한다.

Material 통합으로 Shader Branch나 Atlas Memory가 늘지 않았는지도 확인한다.

---

## 흔한 오해

### Material Asset이 많으면 Draw Call도 같은 수만큼 생긴다

현재 Frame에 Visible하고 실제 사용되는 Renderer·SubMesh·Pass와 Batching 조건이 Draw를 결정한다.

### 같은 Shader면 같은 Material이다

Texture, Property, Keyword와 Render State가 다른 별도 Material일 수 있다.

### Material을 하나로 만들면 항상 빠르다

큰 Atlas, Shader Branch, Texture Array와 Culling·Authoring 복잡도가 증가할 수 있다.

### 같은 Texture를 쓰는 Material은 Texture Memory를 복제한다

같은 Texture Asset Reference는 Pixel Data를 공유할 수 있다. 고유 Texture가 늘어날 때 큰 Memory 비용이 생긴다.

### SRP Batcher가 있으면 Material 수는 무관하다

같은 Variant의 State 준비는 줄지만 Material Buffer, Texture Bind, Memory와 Property Update는 남는다.

### Material Variant는 Runtime Material을 하나로 합친다

주요 목적은 Parent·Child 상속으로 Material Authoring을 관리하는 것이며 Child의 Runtime 상태 차이는 남을 수 있다.

### renderer.material은 단순한 참조 Getter다

Renderer 전용 Material Instance를 만들 수 있어 의도하지 않은 Material 증가와 Batch 분리를 유발할 수 있다.

### MaterialPropertyBlock은 언제나 최적이다

GPU Instancing에는 유용할 수 있지만 URP·HDRP의 SRP Batcher와 호환되지 않는다.

### SetPass Calls만 낮으면 끝난다

Texture Memory, Shader Variant, GPU Overdraw와 Fragment 비용이 병목일 수 있다.

---

## 최종 체크리스트

```text
Asset
□ 중복 Material이 있는가?
□ Material Variant로 Authoring을 정리할 수 있는가?
□ Runtime Material Instance가 누적되는가?

Rendering State
□ Visible Material과 SetPass가 많은가?
□ Shader Variant와 Keyword가 과도한가?
□ Material Slot과 Pass가 필요한가?
□ 같은 State의 Draw가 연속되는가?

Texture
□ 고유 Texture Set이 너무 많은가?
□ Atlas나 Array가 적합한가?
□ Streaming Granularity가 적절한가?

Batching
□ Shared Material을 사용할 수 있는가?
□ SRP Batch가 Variant 때문에 끊기는가?
□ GPU Instancing Group이 Material 때문에 나뉘는가?

검증
□ CPU Main·Render Thread를 측정했는가?
□ Texture·Shader·Material Memory를 측정했는가?
□ Build Size와 Load Stutter를 확인했는가?
□ Target Device에서 화면 회귀를 확인했는가?
```

---

## 정리

Material은 Shader와 Variant, Texture, Property와 Render State를 묶으며 서로 다른 Material이 많으면 State 변경과 Batch 분리가 증가할 수 있다.

문제의 핵심은 Project의 Material Asset 개수 자체가 아니라 현재 Frame의 Visible Material, Shader Pass·Variant, Texture Binding과 Runtime Instance 수다.

여러 Material이 같은 Texture를 참조하면 Texture Pixel Data는 공유할 수 있지만 고유 Texture Set이 늘면 GPU Memory, Streaming과 Load 비용이 크게 증가한다.

Material Keyword 조합은 Shader Variant를 늘려 SRP Batch를 끊고 Build Time, File Size, Shader Memory와 Compilation Stutter를 키울 수 있다.

같은 Material 공유는 Batching에 유리하고 Atlas와 Texture Array는 Resource Binding을 줄일 수 있지만 Memory, UV와 Shader 복잡도 Trade-off가 있다.

Material Variant는 Parent·Child 상속으로 수백 Material의 Authoring을 관리하지만 Runtime Material 상태와 Draw를 자동으로 하나로 합치는 기능은 아니다.

`renderer.material`의 무분별한 사용은 Runtime Material Instance를 늘릴 수 있으며 `sharedMaterial`, MaterialPropertyBlock과 Instance Buffer를 목적에 맞게 선택해야 한다.

최종 판단은 Material 수 하나가 아니라 SetPass·Draw·SRP Batch Break, Texture·Shader Memory, CPU Rendering 시간과 Target Device의 전체 Frame Time을 함께 측정해 내려야 한다.
