---
title: "[Unity 렌더링] 9-6. SRP Batcher는 무엇일까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - SRPBatcher
  - DrawCall
  - URP
permalink: /programming/unity-9-6-what-is-srp-batcher/
toc: true
toc_sticky: true
date: 2026-08-16
last_modified_at: 2026-08-16
---

SRP Batcher는 같은 Shader Variant를 사용하는 Draw Call 사이에서 CPU의 Render State와 Material Data 준비 비용을 줄이는 SRP 전용 Rendering 경로다.

```text
일반적인 오해
여러 Mesh → Draw Call 하나

SRP Batcher의 핵심
Bind + Draw + Bind + Draw Command를 효율적으로 연속 처리
```

Draw Call 수를 반드시 줄이지는 않는다.

Material Property를 GPU Memory에 유지하고 Object별 Data를 큰 Buffer에서 빠르게 갱신해 각 Draw를 준비하는 CPU 시간을 줄인다.

---

## SRP는 무엇을 의미할까?

SRP는 Scriptable Render Pipeline의 약자다.

```text
Scriptable Render Pipeline
├─ URP
├─ HDRP
└─ Custom SRP
```

SRP Batcher는 SRP의 Low-level Render Loop에서 동작한다.

```text
지원
├─ Universal Render Pipeline
├─ High Definition Render Pipeline
└─ 호환되게 구현된 Custom SRP

미지원
└─ Built-in Render Pipeline
```

Built-in Pipeline의 일반 Batching 기능과 이름은 비슷하지만 다른 구조다.

---

## Draw Call에서 CPU가 준비하는 것

CPU는 GPU가 Mesh를 그리기 전에 필요한 Data와 State를 연결한다.

```text
Draw 준비
├─ Shader Variant 선택
├─ Material Property 수집
├─ Constant Buffer 갱신
├─ Object Matrix 갱신
├─ Texture·Buffer Bind
└─ Draw Command 제출
```

Material이 바뀔 때마다 Property를 수집하고 GPU Buffer에 Bind하는 작업이 반복될 수 있다.

Object와 Material이 많은 Scene에서는 GPU가 빠르게 그려도 CPU의 준비 시간이 병목이 될 수 있다.

---

## 전통적인 Draw Call 감소와의 차이

Static Batching과 GPU Instancing은 여러 Object를 더 적은 Draw로 그리는 데 초점을 둔다.

```text
Static Batching
Mesh A + B + C → 결합 Geometry Draw

GPU Instancing
같은 Mesh × N → Instanced Draw
```

SRP Batcher는 Draw Call을 남겨 둔 채 Draw 사이의 State 준비를 줄인다.

```text
Object A → Draw A
Object B → Draw B
Object C → Draw C

Draw는 3개일 수 있음
State·Material Data Setup 경로는 효율화
```

따라서 Draw Call 숫자만 보면 효과를 놓칠 수 있다.

---

## SRP Batch란 무엇일까?

SRP Batcher는 호환되는 `Bind`와 `Draw` GPU Command의 연속 구간을 SRP Batch로 구성한다.

```text
SRP Batch
├─ Bind Object Data A → Draw A
├─ Bind Object Data B → Draw B
├─ Bind Object Data C → Draw C
└─ Bind Object Data D → Draw D
```

같은 Shader Variant를 유지하는 동안 비싼 Pipeline State 전환을 최소화한다.

다른 Shader Variant가 필요하면 현재 Batch가 끝나고 새로운 Batch가 시작될 수 있다.

```text
Variant X: Draw A, B, C
        │ Batch Break
Variant Y: Draw D, E
```

---

## Shader Variant가 핵심인 이유

Shader Variant는 Keyword 조합에 따라 Compile된 Shader Program이다.

```text
Variant A
_NORMALMAP
_MAIN_LIGHT_SHADOWS

Variant B
_NORMALMAP
_MAIN_LIGHT_SHADOWS
_EMISSION
```

Material A와 B가 같은 Shader Asset을 사용해도 Keyword가 다르면 다른 Variant일 수 있다.

GPU Pipeline Program이 바뀌면 Render State를 계속 재사용하기 어렵다.

SRP Batch를 길게 유지하려면 Shader Asset 개수보다 실제 Variant 다양성을 줄여야 한다.

---

## Material이 달라도 Batch될 수 있다

전통적인 Mesh Batching은 같은 Material 조건이 중요하다.

SRP Batcher는 같은 Shader Variant를 사용한다면 서로 다른 Material도 효율적인 연속 Draw에 포함할 수 있다.

```text
Material Red
├─ Shader Variant Lit_A
└─ BaseColor Red

Material Blue
├─ Shader Variant Lit_A
└─ BaseColor Blue

→ 같은 SRP Batch에 포함 가능
```

Material Property 값이 다른 것은 허용된다.

각 Material의 Data가 GPU Memory에 지속적으로 존재하므로 Draw마다 전체 Property를 다시 Upload할 필요를 줄일 수 있다.

---

## Material Data를 GPU Memory에 유지한다

일반 경로에서는 Material이 바뀔 때 CPU가 Property를 수집하고 Constant Buffer를 갱신할 수 있다.

```text
Traditional
Material A 발견
→ Property 수집
→ Constant Buffer Upload / Bind
→ Draw

Material B 발견
→ Property 수집
→ Constant Buffer Upload / Bind
→ Draw
```

SRP Batcher는 Material Data를 Persistent Constant Buffer에 유지한다.

```text
GPU Memory
├─ Material A Buffer
├─ Material B Buffer
└─ Material C Buffer
```

Material 내용이 바뀌지 않으면 매 Frame 같은 Data를 다시 구성하는 작업을 줄일 수 있다.

---

## Per-material과 Per-object Data를 분리한다

Rendering Data는 변화 주기가 다르다.

```text
Per-material Data
├─ Base Color
├─ Smoothness
├─ Metallic
├─ Texture Transform
└─ Material Parameter

Per-object Data
├─ ObjectToWorld Matrix
├─ WorldToObject Matrix
├─ Light Probe Data
├─ Lightmap ScaleOffset
└─ Rendering Layer
```

Material Data는 자주 바뀌지 않으므로 GPU Memory에 유지한다.

Object Data는 Draw마다 달라질 수 있어 큰 Per-object GPU Buffer의 필요한 영역을 갱신한다.

---

## 큰 Per-object Buffer

Unity 공식 문서는 SRP Batcher가 모든 Object Property를 위한 큰 GPU Constant Buffer를 전용 경로로 관리한다고 설명한다.

```text
Per-object Large Buffer
┌────────────┬────────────┬────────────┐
│ Object A   │ Object B   │ Object C   │
└────────────┴────────────┴────────────┘

Draw A → A Offset
Draw B → B Offset
Draw C → C Offset
```

Draw마다 여러 개의 작은 Buffer를 새로 만들고 Binding하기보다 이미 준비된 큰 Buffer의 위치를 사용한다.

CPU의 Data 관리와 Bind 비용을 줄일 수 있다.

---

## CPU에서 줄어드는 비용

```text
SRP Batcher 효과
├─ Material Property 재수집 감소
├─ Material Constant Buffer Upload 감소
├─ Shader Variant 사이 State 전환 감소
├─ Bind Command 구성 효율화
└─ Draw Dispatch CPU Time 감소
```

GPU의 Triangle과 Fragment 계산을 직접 줄이는 기능은 아니다.

CPU Main Thread나 Render Thread가 Draw 준비에 묶여 있을 때 효과가 크다.

---

## GPU 작업량은 어떻게 될까?

Draw Call 수, Triangle 수와 Pixel 수가 그대로라면 GPU Geometry·Fragment 작업도 대부분 남는다.

```text
Before
100 Draws, 1M Triangles

After SRP Batcher
100 Draws, 1M Triangles
```

GPU Setup 명령의 효율은 개선될 수 있지만 비싼 Shader와 Overdraw를 없애지는 않는다.

GPU Bound Scene에서 SRP Batcher를 켜도 전체 Frame Time 변화가 작을 수 있다.

---

## 호환되는 GameObject

Unity 6 공식 문서 기준으로 SRP Batcher 호환 GameObject는 다음 조건을 만족해야 한다.

```text
Renderer Type
├─ Mesh 또는 Skinned Mesh 포함
└─ Particle은 제외

Material Data
└─ MaterialPropertyBlock을 사용하지 않음

Shader
└─ SRP Batcher 호환 Shader
```

호환 Object는 SRP Batcher Code Path를 사용하고 비호환 Object는 Standard SRP Code Path를 사용한다.

Scene 전체가 한꺼번에 호환 또는 비호환으로 결정되는 것은 아니다.

---

## Skinned Mesh를 지원한다

Static·Dynamic Mesh Batching과 달리 SRP Batcher는 Geometry를 하나로 결합하지 않는다.

```text
Skinned Mesh Renderer
├─ Draw Call 유지
├─ Skinning 작업 유지
└─ Material·State 준비 경로 효율화 가능
```

따라서 Skinned Mesh Renderer도 호환 Shader와 Data 조건을 만족하면 SRP Batcher를 사용할 수 있다.

Character의 Bone 계산과 Vertex Skinning 비용을 줄이는 기능은 아니다.

---

## Particle이 제외되는 이유

Particle Renderer는 Runtime Geometry Stream, Sorting과 Per-particle Data를 사용한다.

```text
Particle Rendering
├─ Dynamic Vertex Stream
├─ Particle별 Property
├─ Transparent Sorting
└─ Runtime Buffer Update
```

Unity 공식 호환 조건에서 Particle GameObject는 SRP Batcher 대상이 아니다.

Particle에는 Particle System의 자체 Batching, Material 공유, GPU Instancing과 Overdraw 최적화를 별도로 검토한다.

---

## MaterialPropertyBlock이 호환성을 깨는 이유

MaterialPropertyBlock은 Shared Material을 복제하지 않고 Renderer별 Property를 Override한다.

```text
Shared Material
├─ Renderer A: Color Red
├─ Renderer B: Color Blue
└─ Renderer C: Color Green
```

SRP Batcher는 Material Data를 Persistent Buffer에 유지하는 구조다.

Renderer마다 별도의 Property Override가 들어오면 고정된 Material Buffer 경로를 그대로 사용하기 어렵다.

Unity 6 공식 문서는 MaterialPropertyBlock을 사용하는 GameObject를 SRP Batcher 비호환으로 분류한다.

---

## PropertyBlock을 무조건 제거해야 할까?

Renderer별 값이 꼭 필요하다면 기능 요구사항을 먼저 유지해야 한다.

```text
선택 A
MaterialPropertyBlock 유지
→ SRP Batcher 비호환
→ GPU Instancing 후보 검토

선택 B
별도 Material 생성
→ 같은 Shader Variant면 SRP Batch 가능
→ Material 수와 Memory 증가

선택 C
Global·Buffer 기반 Data 구조
→ Custom Shader와 관리 복잡도 증가
```

어느 방식이 빠른지는 Object 수와 Property 변경 빈도에 따라 다르다.

MaterialPropertyBlock의 구체적인 선택 기준은 이후 글에서 다룬다.

---

## Custom Shader의 Constant Buffer 규칙

SRP Batcher와 호환되려면 Custom Shader가 Property를 정해진 Constant Buffer에 배치해야 한다.

```text
UnityPerDraw
└─ Unity Engine Built-in Property
   ├─ unity_ObjectToWorld
   ├─ unity_WorldToObject
   └─ unity_SHAr 등

UnityPerMaterial
└─ Material Property
   ├─ _BaseColor
   ├─ _Metallic
   └─ _Smoothness 등
```

모든 Built-in Engine Property는 하나의 `UnityPerDraw` Buffer에 있어야 한다.

모든 Material Property는 하나의 `UnityPerMaterial` Buffer에 있어야 한다.

---

## UnityPerMaterial 선언

URP Custom Shader의 Material Property는 다음과 같이 하나의 Buffer에 모은다.

```hlsl
CBUFFER_START(UnityPerMaterial)
    float4 _BaseColor;
    float4 _BaseMap_ST;
    float _Metallic;
    float _Smoothness;
CBUFFER_END
```

Material Property를 Buffer 밖이나 여러 Constant Buffer에 나누면 SRP Batcher 호환성이 깨질 수 있다.

Texture와 Sampler Declaration은 일반적인 Scalar·Vector Material Constant와 배치 방식이 다르다.

URP Shader Library의 선언 방식과 현재 Version의 예제를 기준으로 작성한다.

---

## UnityPerDraw 선언

`unity_ObjectToWorld`, Light Probe SH와 Lightmap Data 같은 Engine Property는 Unity와 URP Include가 제공하는 경우가 많다.

```text
Custom Shader
├─ Core.hlsl 등 Pipeline Include
│  └─ UnityPerDraw Engine Data 선언
└─ 직접 선언한 UnityPerMaterial
```

Built-in Property를 Custom Buffer에 임의로 다시 선언하면 Layout과 호환성이 깨질 수 있다.

URP 공식 Shader Include와 Naming Convention을 사용하고 Inspector의 호환성 결과를 확인한다.

---

## Buffer Layout이 중요한 이유

GPU Constant Buffer는 변수의 순서, Type과 Alignment에 따라 Memory Layout이 정해진다.

```text
UnityPerMaterial Layout
Offset 0  : float4 _BaseColor
Offset 16 : float4 _BaseMap_ST
Offset 32 : float  _Metallic
Offset 36 : float  _Smoothness
```

Shader Pass마다 같은 Material Property를 다른 순서나 Type으로 선언하면 동일 Material Buffer를 안정적으로 재사용하기 어렵다.

모든 Pass가 동일한 `UnityPerMaterial` Layout을 공유하도록 공통 Include에 정의하는 것이 안전하다.

---

## 여러 Pass에서 같은 선언을 사용한다

Lit, ShadowCaster와 DepthOnly Pass가 같은 Material Property를 사용할 수 있다.

```text
Shader
├─ ForwardLit Pass
├─ ShadowCaster Pass
└─ DepthOnly Pass
```

Pass마다 `UnityPerMaterial`을 서로 다르게 정의하면 호환성과 값 일관성 문제가 생길 수 있다.

```hlsl
// CommonInput.hlsl
CBUFFER_START(UnityPerMaterial)
    float4 _BaseColor;
    float4 _BaseMap_ST;
    float _Cutoff;
CBUFFER_END
```

각 Pass에서 같은 Common Include를 사용한다.

---

## Shader Inspector에서 호환성을 확인한다

Unity는 Shader Inspector에 SRP Batcher 호환 상태를 표시한다.

```text
Shader Asset 선택
└─ Inspector
   └─ SRP Batcher Compatibility
```

비호환이라면 Constant Buffer 이름과 Property 선언 위치를 먼저 확인한다.

Material 화면이 아니라 Shader Asset의 Inspector에서 Custom Shader 자체의 호환성을 확인해야 한다.

호환 Shader라도 GameObject가 MaterialPropertyBlock을 사용하면 해당 Renderer는 비호환 경로로 갈 수 있다.

---

## URP Built-in Lit·Unlit Shader

Unity 공식 문서 기준으로 URP와 HDRP의 Lit·Unlit Shader는 Particle Version을 제외하고 SRP Batcher 호환 조건을 만족한다.

```text
일반 URP Lit / Unlit
└─ SRP Batcher 호환

Particle Shader Version
└─ 일반 호환 대상 제외
```

Prebuilt Shader를 사용하는 Project는 기능을 활성화하고 실제 Batch가 길게 유지되는지 확인하면 된다.

Custom Shader는 Constant Buffer 규칙을 직접 지켜야 한다.

---

## URP에서 활성화하는 방법

```text
Project Window
└─ URP Asset 선택
   └─ Inspector
      └─ Rendering
         └─ SRP Batcher: Enabled
```

옵션이 보이지 않으면 URP Asset의 Advanced Property 표시를 활성화한다.

URP Version과 Asset Inspector Layout에 따라 위치가 달라질 수 있다.

SRP Batcher는 URP에서 기본적으로 권장되는 경로지만 활성화 여부를 Project Asset마다 확인한다.

---

## 코드에서 설정하는 방법

Custom SRP 또는 Runtime 설정에서는 Pipeline Asset의 관련 Property를 사용할 수 있다.

URP의 Version별 API가 달라질 수 있으므로 Inspector 설정을 기본으로 사용하고 Runtime 변경이 필요한 경우 해당 Version의 API를 확인한다.

```text
주의
Project에 URP Asset이 여러 개라면
Quality Level마다 다른 Asset이 활성화될 수 있음
```

Editor에서 선택한 Asset이 실제 Build와 Quality Level에서 사용되는지 확인한다.

---

## Batch가 길수록 좋은 이유

하나의 SRP Batch 안에 많은 Bind와 Draw Command가 들어가면 Shader Variant 전환이 적다.

```text
좋은 연속 구간
Variant A
├─ Draw 1
├─ Draw 2
├─ Draw 3
├─ Draw 4
└─ Draw 5
```

작은 Batch가 계속 반복되면 State 전환 비용이 다시 누적된다.

```text
Variant A → 2 Draw
Variant B → 1 Draw
Variant A → 2 Draw
Variant C → 1 Draw
```

Renderer Sorting과 Shader Variant 다양성이 Batch 길이에 영향을 준다.

---

## Material 수보다 Variant 수가 중요할 수 있다

```text
Case A
Material 100개
Shader Variant 1개
→ 긴 SRP Batch 가능

Case B
Material 10개
Shader Variant 10개
→ 잦은 Batch Break 가능
```

SRP Batcher에서는 다른 Material Property 값 자체보다 Keyword로 인한 Variant 전환이 더 중요할 수 있다.

많은 Material을 하나로 합치는 것보다 불필요한 Feature Keyword를 정리하는 편이 효과적일 수 있다.

Material 수의 다른 비용은 이후 글에서 별도로 다룬다.

---

## Keyword를 최소화한다

Shader Feature를 Keyword로 켜고 끄면 Variant가 만들어질 수 있다.

```text
Features
├─ Normal Map On / Off
├─ Emission On / Off
├─ Alpha Clip On / Off
└─ Detail Map On / Off

조합 수 증가
→ Variant 수 증가
→ SRP Batch Break 가능성 증가
```

모든 Feature를 하나의 거대한 Shader에 넣는 것도 Compile Time과 Variant Explosion을 만들 수 있다.

자주 함께 사용되는 기능과 Rendering State가 크게 다른 기능을 기준으로 Shader 구조를 설계한다.

---

## Render Queue와 Pass

Opaque와 Transparent는 Sorting과 Render State가 다르다.

```text
Opaque Pass
├─ Variant A Draws
└─ Variant B Draws

Transparent Pass
├─ Sorting Order 우선
└─ Variant 전환 가능
```

서로 다른 Shader Pass는 같은 Variant 연속 구간으로 처리할 수 없다.

DepthOnly, ShadowCaster와 ForwardLit는 목적이 다른 Pass이므로 각각의 Rendering 구간에서 Batch를 형성한다.

SRP Batcher가 Pass 수 자체를 줄이는 기능은 아니다.

---

## Shadow Pass에서도 동작한다

ShadowCaster Pass가 SRP Batcher 호환 Shader Layout을 사용하면 Caster Draw 준비 비용도 줄일 수 있다.

```text
Main Color
└─ ForwardLit SRP Batches

Shadow Map
├─ Cascade 0 ShadowCaster SRP Batches
├─ Cascade 1 ShadowCaster SRP Batches
└─ Additional Light Shadow Batches
```

Cascade와 Light마다 Geometry를 다시 그리는 작업은 남는다.

SRP Batcher는 각 Shadow Draw의 CPU 준비를 효율화할 뿐 Shadow View와 GPU Vertex 비용을 없애지 않는다.

---

## GPU Instancing과의 관계

GPU Instancing은 같은 Mesh와 Material의 여러 Instance를 하나의 Draw로 묶는다.

SRP Batcher는 같은 Shader Variant를 사용하는 서로 다른 Mesh와 Material의 Draw 준비를 줄일 수 있다.

```text
같은 Tree Mesh 5000개
→ GPU Instancing 후보

서로 다른 Building Mesh와 Material 500개
같은 Lit Variant 사용
→ SRP Batcher 후보
```

URP Custom Shader에서는 SRP Batcher 호환 경로가 GPU Instancing보다 우선될 수 있다.

두 방식의 상세 비교는 다음 글에서 다룬다.

---

## Static Batching과의 관계

```text
Static Batching
├─ 움직이지 않는 Mesh Geometry 결합
├─ Draw 수 감소 가능
└─ Combined Mesh Memory 증가

SRP Batcher
├─ Geometry를 결합하지 않음
├─ 개별 Culling·Transform 유지
└─ Draw당 State 준비 비용 감소
```

Static Batching으로 Draw 수를 줄이는 이점과 SRP Batcher의 Material State 효율은 대상에 따라 다르다.

동일 Mesh 반복, Memory Budget과 Culling Granularity까지 포함해 선택한다.

---

## Dynamic Batching과의 관계

Dynamic Batching은 CPU가 작은 Mesh Vertex를 World Space로 변환해 Runtime에 결합한다.

```text
Dynamic Batching Cost
└─ CPU Vertex Transform + Buffer 구성

SRP Batcher Cost
└─ 개별 Draw는 유지, 효율적인 Buffer·State 경로
```

현대 Graphics API에서는 Dynamic Batch 준비 비용보다 SRP Batcher가 더 효율적일 수 있다.

URP Project에서 Dynamic Batching을 관성적으로 활성화하기 전에 SRP Batcher On 상태와 비교한다.

---

## Renderer별 Property가 필요한 경우

Object마다 Color를 다르게 하고 싶다고 가정한다.

```text
방법 1
MaterialPropertyBlock
→ Material 복제 없음
→ SRP Batcher 비호환

방법 2
Material 100개
→ 같은 Shader Variant면 SRP Batch 가능
→ Material Memory와 관리 증가

방법 3
GPU Instancing Property
→ 같은 Mesh 반복에 적합
→ Instancing Shader 필요
```

어느 방식도 모든 상황에서 우월하지 않다.

Object 수, Mesh 반복성, 변경 빈도와 Memory를 측정해 선택한다.

---

## Material을 매 Frame 바꾸면 어떻게 될까?

SRP Batcher의 Material Data는 바뀌지 않을 때 GPU Memory에 유지되어 이점을 얻는다.

```text
Stable Material
→ Persistent Buffer 재사용

Material Property 매 Frame 변경
→ Buffer Data 갱신 필요
```

수천 Material의 Property를 매 Frame 수정하면 Upload와 관리 비용이 증가한다.

변하지 않는 값은 초기화할 때만 설정하고 Animation이 필요한 값은 Global Data, Texture, Buffer 또는 Instancing Property 구조를 검토한다.

---

## Texture 변경은 어떻게 볼까?

Texture는 Material Property이면서 GPU Resource Binding 대상이다.

같은 Shader Variant라도 서로 다른 Material Texture를 사용할 수 있다.

```text
Material A: Texture Brick
Material B: Texture Wood
```

SRP Batcher는 Shader Variant 전환을 줄이지만 Texture Resource Binding이 완전히 사라지는 것은 아니다.

Texture Atlas와 Array는 Resource Bind를 줄일 수 있지만 UV, Mipmap, Memory와 Shader 복잡도 Trade-off가 있다.

---

## CPU 병목에서 효과가 큰 경우

```text
Scene 조건
├─ 서로 다른 Mesh와 Material이 많음
├─ 같은 Shader Variant 공유율이 높음
├─ MaterialPropertyBlock 사용이 적음
├─ Main·Render Thread Draw 준비가 병목
└─ GPU는 여유가 있음
```

예를 들어 URP Lit Shader를 공유하는 다양한 Environment Prop가 많은 Scene에 적합할 수 있다.

Draw Call 수가 그대로여도 `RenderLoop.Draw` 계열 CPU 시간이 줄어들 수 있다.

---

## 효과가 작을 수 있는 경우

```text
효과 제한 가능
├─ Draw Call 자체가 적음
├─ Shader Variant가 계속 바뀜
├─ MaterialPropertyBlock 사용이 많음
├─ Particle Renderer가 대부분임
├─ Material Property를 매 Frame 변경함
├─ GPU Fragment·Geometry Bound
└─ Script·Physics CPU Bound
```

SRP Batcher를 켰다는 사실보다 실제로 호환 Draw가 긴 Batch를 형성하는지 확인한다.

Unity 공식 문서는 Asset과 Shader가 최적화되지 않은 Low-performance Device에서는 비활성화가 더 빠를 수도 있다고 안내한다.

---

## Frame Debugger에서 확인하는 방법

Unity 6 공식 절차는 Frame Debugger에서 SRP Batch를 직접 선택하는 것이다.

```text
Window
└─ Analysis
   └─ Frame Debugger
      └─ Render Camera
         └─ Render Opaques
            └─ RenderLoopNewBatcher.Draw
               └─ SRP Batch
```

각 SRP Batch는 다음 정보를 보여 준다.

- Batch 안의 Draw Call 수
- Shader에 연결된 Keyword
- 이전 Draw와 Batch되지 않은 이유
- 사용 Shader와 Rendering State

Batch 수치뿐 아니라 Break Reason을 확인한다.

---

## Batch Break Reason

Frame Debugger는 새 SRP Batch가 시작된 이유를 보여 준다.

```text
예시
Nodes have different shaders
```

이는 이전 Batch와 다른 Shader를 사용해 새로운 Batch가 만들어졌다는 뜻이다.

다른 원인으로 Shader Variant, Pass와 Rendering State 차이가 있을 수 있다.

작은 SRP Batch가 많이 반복되면 Project가 Shader Variant를 과도하게 사용하는지 확인한다.

---

## 좋은 Frame Debugger 결과

```text
SRP Batch A
├─ Draw Calls: 120
└─ Variant: Lit / Normal / Shadow

SRP Batch B
├─ Draw Calls: 80
└─ Variant: Lit / No Normal / Shadow
```

적은 Batch 안에 많은 Draw가 들어가면 State 전환이 적다.

반대로 다음 구조는 비효율적일 수 있다.

```text
SRP Batch A: 2 Draws
SRP Batch B: 1 Draw
SRP Batch C: 3 Draws
SRP Batch D: 1 Draw
```

각 Break의 Keyword와 Shader 차이를 확인한다.

---

## Unity Profiler에서 확인한다

```text
측정 항목
├─ Main Thread Rendering Time
├─ Render Thread Time
├─ RenderLoop 관련 Marker
├─ Batches와 SetPass Calls
├─ Draw Calls
└─ GPU Frame Time
```

SRP Batcher On·Off에서 Draw Call 수가 같아도 CPU Marker 시간이 달라질 수 있다.

```text
Off
Draw Calls 2000, CPU Render 9 ms

On
Draw Calls 2000, CPU Render 5 ms
```

예시처럼 Draw 수보다 CPU ms를 기준으로 효과를 판단한다.

---

## A/B Test 방법

```text
Test A: SRP Batcher Off
Test B: SRP Batcher On
```

다음 조건을 고정한다.

- Camera 위치와 경로
- Visible Renderer와 LOD
- Material과 Keyword
- Light와 Shadow
- Render Scale과 Resolution
- Graphics API
- Build Type과 Quality Level
- Material Property Update 상태

On 상태에서 Batch Break까지 분석하고 Off와 CPU·GPU 시간을 비교한다.

---

## Shader 수정 전후 검사

Custom Shader를 SRP Batcher 호환으로 바꿀 때 화면 결과도 함께 확인한다.

```text
검사 항목
├─ Material Property 값
├─ 모든 Pass의 Buffer Layout
├─ GPU Instancing 동작 변화
├─ MaterialPropertyBlock 동작
├─ Light Probe와 Lightmap
├─ ShadowCaster Pass
└─ Platform별 Shader Compile
```

Constant Buffer 이동 과정에서 Property Type이나 Name이 달라지면 기존 Material 값이 깨질 수 있다.

Build에 포함되는 Shader Variant와 Platform Compiler Error도 확인한다.

---

## Custom Shader 호환 예시

다음은 Material Constant Buffer 배치를 보여 주는 단순 URP 구조다.

```shaderlab
Shader "Custom/SRPBatcherExample"
{
    Properties
    {
        _BaseColor("Base Color", Color) = (1, 1, 1, 1)
    }

    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Opaque"
        }

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseColor;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
            };

            Varyings vert(Attributes input)
            {
                Varyings output;
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                return _BaseColor;
            }
            ENDHLSL
        }
    }
}
```

실제 Production Shader에는 Shadow, Lighting, Fog와 필요한 Pass가 추가된다.

각 Pass가 동일 Material Buffer Layout을 공유하도록 구성한다.

---

## 흔한 비호환 선언

```hlsl
// Material Property가 CBUFFER 밖에 있음
float4 _BaseColor;
float _Smoothness;
```

또는 Material Property를 서로 다른 Buffer에 나누는 경우다.

```hlsl
CBUFFER_START(MyColorBuffer)
    float4 _BaseColor;
CBUFFER_END

CBUFFER_START(MySurfaceBuffer)
    float _Smoothness;
CBUFFER_END
```

SRP Batcher를 위해 하나의 `UnityPerMaterial` Buffer로 모은다.

```hlsl
CBUFFER_START(UnityPerMaterial)
    float4 _BaseColor;
    float _Smoothness;
CBUFFER_END
```

---

## Material 수를 줄여야 할까?

SRP Batcher에서는 같은 Shader Variant를 쓰는 서로 다른 Material이 같은 Batch에 들어갈 수 있다.

따라서 CPU State 비용만을 위해 모든 Material을 하나로 합칠 필요는 줄어든다.

그러나 Material 수는 다음 비용을 가진다.

```text
많은 Material
├─ Asset과 Memory
├─ Texture Binding
├─ Keyword Variant
├─ 관리 복잡도
└─ Property Update
```

SRP Batch 호환성만으로 Material 수 전체가 공짜가 되는 것은 아니다.

---

## Sorting과 SRP Batch

Unity는 Opaque Object를 Rendering 효율과 Depth를 고려해 정렬한다.

```text
State Sorting
→ 같은 Variant 연속
→ SRP Batch 길이 증가

Front-to-Back
→ Early-Z 효율 증가
→ Fragment Overdraw 감소
```

두 목표가 항상 같은 순서를 만들지는 않는다.

Transparent는 Blend 순서가 중요해 Variant별로 자유롭게 묶기 어렵다.

CPU State 절약과 GPU Overdraw의 전체 Frame Time으로 판단한다.

---

## Camera와 Pass가 많을 때

Camera와 Rendering Pass가 추가되면 같은 Renderer도 다시 처리될 수 있다.

```text
Main Camera
├─ Depth Pass
├─ Opaque Pass
└─ Transparent Pass

Mini-map Camera
└─ 별도 Rendering
```

SRP Batcher는 반복되는 Draw의 CPU 준비를 줄일 수 있지만 Pass와 Camera 자체를 제거하지 않는다.

불필요한 Camera, Renderer Feature와 Shadow Pass는 별도로 줄여야 한다.

---

## Platform별 차이

CPU와 Graphics API에 따라 Draw State 변경 비용이 다르다.

```text
영향 요소
├─ CPU 성능
├─ Graphics API
├─ Driver
├─ GPU Buffer Update 비용
├─ Shader Variant 분포
└─ 목표 FPS
```

Desktop에서 작은 차이가 Mobile의 높은 목표 Frame Time에서는 크게 나타날 수 있다.

반대로 Asset과 Shader가 비호환 상태라면 Low-end Device에서 관리 비용이 이점을 넘을 수 있다.

각 Target Device에서 On·Off를 측정한다.

---

## 적합한 사례

```text
SRP Batcher 후보
├─ URP·HDRP Project
├─ Mesh와 Skinned Mesh가 많음
├─ 서로 다른 Mesh·Material이 많음
├─ 같은 Shader Variant 공유율이 높음
├─ MaterialPropertyBlock 사용이 적음
└─ CPU Draw 준비가 병목
```

Architecture, Character와 Prop가 모두 같은 Lit Variant를 공유하는 Scene에서 긴 SRP Batch를 만들 수 있다.

Material 값이 달라도 같은 Variant라면 효율적인 경로를 사용할 수 있다.

---

## 적합하지 않을 수 있는 사례

```text
효과가 작거나 비호환
├─ Built-in Render Pipeline
├─ Particle 중심 Scene
├─ MaterialPropertyBlock 사용 Renderer가 많음
├─ Shader Variant가 지나치게 많음
├─ Draw Call이 이미 적음
├─ GPU Fragment Bound
└─ Material Property를 계속 수정함
```

같은 Mesh·Material이 대량 반복되면 GPU Instancing이 더 큰 Draw 감소를 제공할 수 있다.

단순히 SRP Batcher를 끄거나 켜지 말고 Object 집단별 Rendering 경로를 확인한다.

---

## 흔한 오해

### SRP Batcher는 Draw Call을 하나로 합친다

개별 Draw Call은 남을 수 있으며 Bind·Draw Command 연속 처리와 State 준비 비용을 줄인다.

### 같은 Material만 Batch된다

Material 값이 달라도 같은 Shader Variant를 사용하고 호환 조건을 만족하면 같은 SRP Batch에 들어갈 수 있다.

### Shader 이름이 같으면 같은 Variant다

Keyword 조합이 다르면 다른 Compiled Variant가 되어 Batch를 끊을 수 있다.

### MaterialPropertyBlock은 Material을 복제하지 않아 항상 빠르다

SRP Batcher와 호환되지 않아 많은 Renderer에서 오히려 CPU 성능을 낮출 수 있다.

### SRP Batcher는 GPU Triangle을 줄인다

Geometry, Fragment와 Pass 수는 그대로이며 주로 CPU Draw 준비를 최적화한다.

### Skinned Mesh는 사용할 수 없다

Geometry 결합 방식이 아니므로 호환 Shader를 사용하는 Skinned Mesh Renderer도 지원한다.

### Particle도 URP Shader를 쓰면 Batch된다

Unity 6 공식 GameObject 호환 조건에서 Particle은 제외된다.

### 기능을 켜면 모든 Shader가 자동 호환된다

Custom Shader는 `UnityPerDraw`와 `UnityPerMaterial` Constant Buffer 규칙을 지켜야 한다.

### Material이 많아도 모든 비용이 사라진다

Material Buffer, Texture Bind, Memory와 Property Update 비용은 남는다.

### 모든 Platform에서 항상 빠르다

Shader와 Asset이 최적화되지 않은 Low-performance Device에서는 비활성화가 더 빠를 수도 있어 측정이 필요하다.

---

## 적용 순서

```text
1. 실제 사용 중인 URP Asset 확인
2. SRP Batcher 활성화 상태 확인
3. Custom Shader Inspector 호환성 확인
4. UnityPerMaterial·UnityPerDraw Layout 수정
5. MaterialPropertyBlock 사용 Renderer 조사
6. Frame Debugger에서 SRP Batch와 Break Reason 확인
7. 작은 Batch를 만드는 Keyword·Variant 정리
8. On·Off CPU Main·Render Thread 비교
9. GPU Instancing 대상은 별도로 분류
10. Target Device와 Quality Level별 검증
```

Draw Call 숫자보다 하나의 Batch에 포함된 Draw 수와 CPU Rendering ms를 본다.

Shader 수정 후 모든 Pass의 Material 값, Lighting와 Shadow 결과도 회귀 검사한다.

---

## 정리

SRP Batcher는 URP·HDRP와 Custom SRP에서 같은 Shader Variant를 사용하는 Draw 사이의 Render State와 Material Data 준비 비용을 줄이는 Low-level Render Loop다.

Draw Call 자체를 반드시 줄이지 않고 호환되는 Bind·Draw Command를 긴 SRP Batch로 연속 처리해 CPU Dispatch 시간을 낮춘다.

Material Property는 Persistent Constant Buffer로 GPU Memory에 유지하고 Object별 Engine Property는 큰 Per-object Buffer에서 효율적으로 갱신한다.

Custom Shader는 Engine Property를 하나의 `UnityPerDraw`, Material Property를 하나의 `UnityPerMaterial` Constant Buffer에 선언해야 한다.

Mesh와 Skinned Mesh Renderer는 지원하지만 Particle과 MaterialPropertyBlock을 사용하는 Renderer는 SRP Batcher 호환 경로를 사용할 수 없다.

Material 값이 달라도 같은 Shader Variant를 사용하면 같은 Batch에 들어갈 수 있지만 Keyword와 Pass가 달라지면 Batch가 끊길 수 있다.

Frame Debugger에서 SRP Batch의 Draw 수, Keyword와 Batch Break Reason을 확인하고 Profiler에서 On·Off의 Main·Render Thread 시간을 비교해야 한다.

같은 Mesh가 대량 반복되는 대상은 GPU Instancing과 비교하고 최종 선택은 Target Device의 CPU·GPU Frame Time으로 내려야 한다.
