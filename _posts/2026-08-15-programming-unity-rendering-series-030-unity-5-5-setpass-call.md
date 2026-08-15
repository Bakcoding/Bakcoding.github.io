---
title: "[Unity 렌더링] 5-5. SetPass Call은 무엇일까?"
excerpt: "Unity Rendering"
categories:
  - Programming
tags:
  - Unity
  - Rendering
  - SetPassCall
  - RenderState
  - SRPBatcher
permalink: /programming/unity-5-5-setpass-call/
toc: true
toc_sticky: true
date: 2026-08-15
last_modified_at: 2026-08-15
---

GPU에 Mesh를 그리라고 요청하려면 Geometry만 전달해서는 부족하다.

어떤 Shader Program을 실행하고, 어떤 Texture와 Buffer를 연결하며, Depth·Blend·Cull State를 어떻게 설정할지도 정해야 한다.

Unity가 새로운 Shader Pass를 Rendering에 사용하도록 설정하는 작업과 관련된 통계가 SetPass Call이다.

```text
Shader Pass 설정
↓
Material Resource 연결
↓
Render State 적용
↓
하나 이상의 Draw Call
```

Draw Call이 Geometry를 그리는 요청이라면 SetPass Call은 그 Draw를 어떤 방식으로 처리할지 GPU 상태를 준비하는 쪽에 가깝다.

두 Counter는 관련되어 있지만 같은 의미가 아니다.

---

## SetPass Call이란?

Unity Rendering Statistics의 SetPass는 한 Frame에서 Object Rendering에 사용할 Shader Pass를 전환한 횟수를 나타낸다.

```text
SetPass
새 Shader Pass와 관련 Rendering State를 사용하도록 설정

Draw
현재 설정으로 Geometry를 그리도록 요청
```

Unity 6 공식 Statistics 문서는 Shader가 여러 Pass를 포함할 수 있고 각 Pass가 Object를 다른 방식으로 그리며, 새로운 Pass Binding에는 CPU Overhead가 발생할 수 있다고 설명한다.

```text
Pass A 설정
→ Draw 1
→ Draw 2
→ Draw 3

Pass B 설정
→ Draw 4
```

위 흐름에서는 Draw가 네 번이지만 Pass 설정 전환은 더 적을 수 있다.

실제 Counter 집계는 Render Pipeline과 Platform 구현의 영향을 받는다.

---

## 왜 SetPass가 필요할까?

GPU는 다음 Draw가 이전 Draw와 같은 상태를 사용한다고 임의로 가정할 수 없다.

CPU와 Render Pipeline이 필요한 상태와 Resource를 명시해야 한다.

```text
Draw A
Shader = Lit
Blend = Off
Depth Write = On
Texture = Brick

Draw B
Shader = Unlit
Blend = Alpha
Depth Write = Off
Texture = Smoke
```

Draw A에서 Draw B로 이동할 때 Program, Blend, Depth와 Texture Binding 일부가 바뀐다.

이러한 변경을 준비하고 Graphics API Command로 기록하는 데 CPU 비용이 든다.

---

## Render State란?

Render State는 GPU가 Geometry와 Fragment를 처리하는 방식을 정하는 상태다.

대표적인 항목은 다음과 같다.

```text
Shader Program / Pipeline State Object
Vertex와 Index Buffer
Constant Buffer
Texture와 Sampler
Render Target
Viewport와 Scissor
Cull Mode
Depth Test와 Depth Write
Stencil Test
Blend State
```

모든 상태 변경이 Unity Stats의 SetPass 숫자와 정확히 1:1로 대응하는 것은 아니다.

SetPass는 Unity가 Shader Pass를 전환하는 큰 단위의 통계이며 Graphics API 내부에는 더 세분화된 Binding과 State Command가 존재한다.

---

## Shader Pass가 제공하는 상태

ShaderLab Pass는 GPU Program과 Render State를 묶는다.

```shaderlab
Pass
{
    Name "ForwardLit"

    Tags
    {
        "LightMode" = "UniversalForward"
    }

    Cull Back
    ZTest LEqual
    ZWrite On
    Blend Off

    HLSLPROGRAM
    #pragma vertex Vert
    #pragma fragment Frag
    ENDHLSL
}
```

이 Pass를 활성화하려면 Unity는 Compile된 Vertex·Fragment Program과 Cull, Depth, Blend State를 사용할 수 있게 준비한다.

Pass가 바뀌면 Program뿐 아니라 고정 기능 State도 달라질 수 있다.

---

## Material은 무엇을 더할까?

Material은 Shader와 Property 값을 가진다.

```text
Material
├─ Shader
├─ Keyword 상태
├─ Texture
├─ Color와 Float
├─ Render Queue
└─ Override State가 있는 경우 해당 설정
```

같은 Shader Pass를 사용하는 Material이라도 Base Texture와 Color가 다를 수 있다.

```text
Material A
Shader Variant X
Texture = Brick

Material B
Shader Variant X
Texture = Wood
```

Shader Variant는 같지만 Material Data Binding은 바뀐다.

일반적인 Rendering Path와 SRP Batcher 경로에서 이 Data를 준비하는 방식이 다를 수 있다.

---

## Draw Call과 SetPass Call 비교

| 항목 | Draw Call | SetPass Call |
|---|---|---|
| 핵심 역할 | Geometry Drawing 요청 | Shader Pass와 관련 State 설정 |
| 주요 입력 | Mesh, SubMesh, Index 범위, Instance | Shader Program, Material, Render State |
| 증가 원인 | Camera, Pass, SubMesh, Renderer | Shader Pass·Variant·State 전환 |
| 줄이는 방법 | Batching, Instancing, 불필요한 Draw 제거 | State별 정렬, Material·Variant 통일, SRP Batcher |
| Unity Stats | Batches와 관련 | SetPass Counter |

Draw Call을 줄이면 State 전환 기회도 줄어 SetPass가 감소할 수 있다.

하지만 Draw 수와 SetPass 수가 반드시 같은 비율로 움직이지는 않는다.

---

## 여러 Draw가 하나의 Pass 상태를 공유하는 경우

같은 Shader Pass와 호환되는 State를 사용하는 Renderer가 연속으로 정렬되었다고 가정한다.

```text
SetPass: Lit Variant A
├─ Draw Cube A
├─ Draw Cube B
├─ Draw Sphere C
└─ Draw Wall D
```

Geometry와 Transform이 달라 Draw는 나뉘어도 Shader Pass 전환을 반복할 필요는 줄어들 수 있다.

```text
Batches = 4
SetPass = 1에 가까운 구조 가능
```

실제 Material Resource Binding과 Counter는 Pipeline에 따라 다르므로 개념적 예로 이해한다.

---

## Draw마다 SetPass가 바뀌는 경우

각 Renderer가 서로 다른 Shader Variant나 Render State를 사용하면 다음과 같은 흐름이 될 수 있다.

```text
SetPass Lit Opaque
→ Draw Wall

SetPass Lit AlphaClip
→ Draw Leaves

SetPass Unlit Additive
→ Draw Effect

SetPass Transparent Alpha
→ Draw Glass
```

Draw 네 번과 함께 Pass 전환도 자주 발생한다.

CPU는 Program과 State 변경 Command를 반복해서 준비해야 한다.

Material과 Shader가 지나치게 다양하면 Batches뿐 아니라 SetPass 비용도 증가할 수 있다.

---

## Material이 다르면 항상 SetPass가 증가할까?

항상 그렇다고 단정할 수 없다.

두 Material이 같은 Shader Variant와 Pass State를 사용한다면 Pipeline이 Program State를 유지하고 Material Data만 바꾸는 최적화를 할 수 있다.

```text
Material A
Shader Variant = Lit_NormalOn
Base Color = Red

Material B
Shader Variant = Lit_NormalOn
Base Color = Blue
```

SRP Batcher는 이런 상황에서 서로 다른 Material의 Constant Data를 GPU Memory에 유지하고 Draw 준비 CPU 비용을 줄이는 데 유리하다.

Material Asset이 다르다는 사실만으로 SetPass 변화량을 계산할 수 없다.

---

## Shader가 다르면?

서로 다른 Shader는 일반적으로 다른 GPU Program과 Pipeline State를 요구한다.

```text
Shader A / Forward Pass
↓ Program A Bind
Draw

Shader B / Forward Pass
↓ Program B Bind
Draw
```

Shader 이름이 다르지만 Compile 결과가 우연히 비슷하더라도 Unity가 같은 Pass로 취급한다고 기대하면 안 된다.

기능이 거의 같은 Shader Asset이 과도하게 분리되어 있다면 공통 Shader와 Material Property 또는 Keyword 구조로 통합할 가능성을 검토할 수 있다.

Variant Explosion과 유지 보수 비용도 함께 고려한다.

---

## Shader Variant가 다르면?

같은 Shader와 Pass여도 Keyword 조합이 다르면 다른 Compile Program이 선택된다.

```text
Material A
_NORMAL_MAP Off
_ALPHA_CLIP Off

Material B
_NORMAL_MAP On
_ALPHA_CLIP Off

Material C
_NORMAL_MAP On
_ALPHA_CLIP On
```

각 조합은 다른 Shader Variant가 될 수 있다.

```text
Variant 변경
→ GPU Program 또는 Pipeline State 변경 가능
→ SRP Batch 분리
→ SetPass 전환 증가 가능
```

작은 기능 차이마다 Keyword를 추가하면 Build Variant뿐 아니라 Runtime State Group도 조각날 수 있다.

---

## Pass가 다르면?

같은 Shader의 서로 다른 Pass는 목적과 Program, State가 다르다.

```text
UniversalForward
Color와 Lighting

ShadowCaster
Light 관점 Depth

DepthOnly
Camera Depth
```

Camera Color Pass에서 ShadowCaster로 전환하거나 Depth Pass에서 Forward Pass로 전환할 때 새로운 Pass 설정이 필요하다.

Render Pipeline은 일반적으로 Pass별로 많은 Renderer를 모아 실행해 전환을 줄일 수 있다.

```text
모든 ShadowCaster Draw
↓
모든 DepthOnly Draw
↓
모든 Forward Draw
```

Renderer마다 Shadow→Depth→Color를 반복하는 방식보다 State Locality가 좋아질 수 있다.

---

## Render Target 변경

Shadow Map, Camera Depth와 Camera Color는 서로 다른 Render Target이다.

```text
Shadow Pass
Target = Shadow Map

Depth Pass
Target = Camera Depth

Forward Pass
Target = Camera Color + Depth
```

Render Target 변경은 GPU 작업 순서와 Memory Attachment 상태를 바꾼다.

모든 Render Target 전환이 SetPass Counter에 직접 같은 방식으로 집계되는 것은 아니지만 Render Pass 경계에서 발생하는 중요한 State 변경이다.

SetPass 숫자만 보고 전체 Render State 비용을 모두 설명할 수 없는 이유다.

---

## Texture Binding 변경

Material이 바뀌면 Texture Resource도 달라질 수 있다.

```text
Material Brick
_BaseMap = Brick Texture

Material Wood
_BaseMap = Wood Texture
```

Shader Program이 같아도 Draw 전에 올바른 Texture Descriptor 또는 Binding을 선택해야 한다.

Texture Atlas와 Texture Array는 여러 Surface Texture를 하나의 Resource 구조에서 선택하도록 만들어 Binding 변경을 줄이는 데 도움을 줄 수 있다.

대신 UV, Mipmap, Wrap Mode와 Memory 관리 제약이 생긴다.

---

## Constant Buffer 변경

Material의 Color, Roughness와 Texture Transform 같은 값은 Constant Buffer에 저장될 수 있다.

```hlsl
CBUFFER_START(UnityPerMaterial)
    float4 _BaseMap_ST;
    half4 _BaseColor;
    half _Metallic;
    half _Smoothness;
CBUFFER_END
```

Renderer가 다른 Material을 사용하면 해당 Material Constant Data가 필요하다.

전통적인 경로에서는 Material이 바뀔 때 Property를 수집하고 Buffer에 Upload·Bind하는 CPU 작업이 반복될 수 있다.

SRP Batcher는 Material Data를 GPU Memory에 지속적으로 유지해 이 비용을 줄인다.

---

## Per-object Data 변경

같은 Material을 공유해도 Renderer마다 Transform이 다르다.

```text
Object A
ObjectToWorld Matrix A

Object B
ObjectToWorld Matrix B
```

Lightmap Scale-Offset, Probe Data와 Object ID 같은 값도 Object별로 달라질 수 있다.

따라서 Pass 상태를 유지하더라도 Draw마다 Per-object Data는 갱신해야 한다.

```text
Same Pass
Same Material
↓
Per-object Buffer Offset 변경
↓
Draw
```

SetPass가 적다고 Draw 준비 작업이 전부 사라지는 것은 아니다.

---

## SetPass 비용은 왜 CPU에 나타날까?

GPU가 실행할 상태를 바꾸는 Command는 CPU와 Driver가 준비한다.

```text
Unity Render Loop
↓
Shader와 Material State 검사
↓
Graphics API Command 기록
↓
Driver 또는 Command Buffer
↓
GPU 실행
```

전환이 많으면 Main Thread 또는 Render Thread의 Rendering 시간이 늘 수 있다.

Modern Explicit API는 State를 Pipeline State Object로 미리 구성하지만 적절한 PSO 선택과 Descriptor Binding 작업은 여전히 필요하다.

Platform마다 비용이 다르므로 목표 Device에서 측정해야 한다.

---

## Pipeline State Object

Direct3D 12, Vulkan과 Metal 같은 Modern API는 여러 GPU State를 Pipeline State Object와 유사한 단위로 묶는다.

```text
PSO
├─ Shader Program
├─ Vertex Input Layout
├─ Raster State
├─ Depth / Stencil State
├─ Blend State
└─ Render Target Format 관계
```

Shader Variant나 Render State 조합이 달라지면 다른 PSO가 필요할 수 있다.

처음 사용하는 조합의 PSO 생성은 Runtime Hitch 원인이 될 수 있어 Shader Warm-up과 Graphics State 추적이 중요할 수 있다.

Unity Stats의 SetPass는 API별 PSO Bind 횟수 자체를 그대로 보여 주는 Low-level Counter는 아니다.

---

## Sorting이 SetPass를 줄이는 방법

Opaque Renderer는 Rendering 결과를 유지할 수 있는 범위에서 비슷한 State를 가진 Draw를 가깝게 정렬할 수 있다.

```text
정렬 전
Lit A
Unlit B
Lit C
Unlit D

정렬 후
Lit A
Lit C
Unlit B
Unlit D
```

정렬 후에는 Shader Pass 전환이 줄어들 수 있다.

```text
Lit SetPass 1회
→ Draw A, C

Unlit SetPass 1회
→ Draw B, D
```

Opaque에서 Front-to-back Depth 효율과 State 정렬 사이의 균형은 Pipeline의 Sorting Criteria가 결정한다.

---

## Transparent Sorting의 제약

일반 Alpha Blend는 먼 Object부터 가까운 Object 순서가 필요할 수 있다.

```text
Far Glass Material A
Near Smoke Material B
Very Near Glass Material A
```

Material A를 한 번에 모으면 Blend 순서가 깨질 수 있다.

```text
정확한 순서 우선
A → B → A
→ SetPass 전환 증가 가능
```

Transparent Rendering은 Opaque보다 State 정렬을 자유롭게 적용하기 어렵다.

Material 종류와 Layer 수를 줄이거나 다른 Transparency 기법을 검토할 수 있지만 시각적 정확성을 유지해야 한다.

---

## Render Queue와 SetPass

Render Queue는 Object의 큰 Rendering 순서를 구분한다.

```text
Geometry
↓
AlphaTest
↓
Transparent
↓
Overlay
```

Queue가 다르면 Render Pass와 Sorting Group이 나뉘어 같은 Shader를 사용해도 연속 Draw가 되지 않을 수 있다.

Material의 Queue Offset을 Object마다 지나치게 다르게 설정하면 State별 정렬 기회를 줄일 수 있다.

Render Queue의 자세한 규칙은 다음 글에서 다룬다.

---

## Multi Pass Shader와 SetPass

같은 Renderer를 여러 Shader Pass로 그리면 각 Pass의 Program과 State를 설정해야 한다.

```text
Outline Pass
Cull Front
Outline Program
↓
Main Pass
Cull Back
Lit Program
```

Renderer 하나에 Draw와 Pass 전환이 추가된다.

많은 Object가 같은 Multi Pass Effect를 사용할 때 Pipeline이 Pass별로 Object를 묶을 수 있는지, Shader가 Object마다 Pass를 연속 실행하는지에 따라 State 패턴이 달라질 수 있다.

Frame Debugger에서 실제 순서를 확인한다.

---

## Shadow Pass와 SetPass

Shadow Map은 Material의 `ShadowCaster` Pass를 사용한다.

```text
Opaque ShadowCaster Variant
→ 많은 Opaque Object Draw

Alpha Clip ShadowCaster Variant
→ 많은 Foliage Draw
```

Alpha Clip 여부, Cull Mode와 Vertex Animation Keyword가 다르면 ShadowCaster Variant와 State Group이 나뉠 수 있다.

Shadow Cascade마다 Geometry Draw가 반복되지만 같은 Pass State를 효율적으로 유지할 가능성도 있다.

Draw 증가와 SetPass 증가를 같은 배율로 계산하면 안 된다.

---

## Material 수와 SetPass

Material Asset 수가 많으면 State 변경 가능성이 커지지만 Asset 수와 SetPass가 반드시 1:1은 아니다.

```text
Material 100개
모두 같은 Shader Variant
SRP Batcher 호환
→ Draw는 많아도 State Setup 비용을 효율화 가능
```

```text
Material 10개
각각 다른 Shader와 Variant
Transparent 순서가 섞임
→ SetPass 전환이 자주 발생 가능
```

Material 수만 줄이기보다 Shader Variant와 Render State Group 수를 확인하는 편이 중요하다.

---

## SRP Batcher란?

SRP Batcher는 같은 Shader Variant를 사용하는 Material Draw의 준비와 Dispatch에 필요한 CPU 시간을 줄이는 Rendering 경로다.

```text
같은 Shader Variant
├─ Material A
├─ Material B
├─ Material C
└─ Material D
↓
하나의 긴 SRP Batch
```

각 Material의 Constant Buffer Data를 GPU Memory에 유지하고 Object별 Data를 전용 Buffer 경로로 갱신한다.

Material이 바뀔 때 모든 Property를 다시 수집하고 Upload하는 일을 줄일 수 있다.

---

## SRP Batch의 Bind와 Draw

SRP Batcher는 연속된 Bind와 Draw Command를 SRP Batch로 구성한다.

```text
Bind Shader Variant A
├─ Bind Material A Data → Draw A
├─ Bind Material B Data → Draw B
├─ Bind Material C Data → Draw C
└─ Bind Material D Data → Draw D
```

Draw 네 개가 하나로 합쳐지는 것은 아니다.

Shader Variant State를 유지하면서 Material Data Binding을 저비용으로 처리하는 것이 핵심이다.

```text
Draw Call 수
그대로일 수 있음

CPU 준비 비용
감소 가능
```

---

## SRP Batcher 호환 Shader

URP Custom Shader가 SRP Batcher와 호환되려면 Material Property를 하나의 `UnityPerMaterial` Constant Buffer에 선언해야 한다.

```hlsl
CBUFFER_START(UnityPerMaterial)
    float4 _BaseMap_ST;
    half4 _BaseColor;
    half _Metallic;
    half _Smoothness;
CBUFFER_END
```

Unity Engine의 Built-in Per-draw Property는 `UnityPerDraw` 구조와 호환되어야 한다.

URP ShaderLibrary Include가 일반적인 Engine Property 선언을 제공한다.

Material Property를 CBUFFER 밖에 흩어 놓으면 Inspector에 SRP Batcher 비호환으로 표시될 수 있다.

---

## 여러 Pass의 CBUFFER Layout

하나의 Shader가 여러 Pass를 가지면 Material CBUFFER Layout을 일관되게 유지해야 한다.

```text
Forward Pass
UnityPerMaterial Layout A

ShadowCaster Pass
UnityPerMaterial Layout A

DepthOnly Pass
UnityPerMaterial Layout A
```

공통 `HLSLINCLUDE` 또는 Include File에 CBUFFER를 선언하면 중복과 불일치를 줄일 수 있다.

Pass마다 같은 이름의 Property를 다른 Type과 순서로 선언하지 않도록 한다.

현재 저장소 작업 조건에서는 별도 `.hlsl` 파일을 추가하지 않고 개념만 설명한다.

---

## SRP Batch가 끊기는 이유

SRP Batcher는 같은 Shader Variant를 사용하는 연속 Draw를 효율적으로 처리한다.

다음 조건은 Batch를 끊을 수 있다.

```text
다른 Shader Variant
Shader Keyword 조합 변경
SRP Batcher 비호환 Shader
MaterialPropertyBlock 사용 경로
다른 Rendering State와 Pass
Pipeline이 다른 순서를 요구
```

Frame Debugger에서 SRP Batch와 Batch Break Reason을 확인할 수 있다.

가장 자주 발생하는 Variant 전환부터 정리하는 편이 효과적이다.

---

## MaterialPropertyBlock과 SRP Batcher

MaterialPropertyBlock은 Renderer별 Property Override에 유용하지만 일반적인 사용은 Renderer를 SRP Batcher 호환 경로에서 제외할 수 있다.

```text
SRP Batcher
Material Data를 지속적인 CBUFFER로 관리

MaterialPropertyBlock
Renderer별 Property Override
→ 별도 Data 경로 필요
```

같은 Mesh의 많은 Instance를 Renderer별로 바꾸려면 GPU Instancing Property가 더 적합할 수 있다.

SRP Batcher와 Instancing 중 어느 방식이 유리한지는 Object 반복성, Material 수와 Platform에서 측정한다.

---

## GPU Instancing과 SetPass

GPU Instancing은 같은 Mesh와 Material의 여러 Instance를 한 Draw로 처리한다.

```text
SetPass Tree Variant
↓
Draw Instanced
├─ Tree 1
├─ Tree 2
├─ Tree 3
└─ Tree 4
```

Draw 수와 Pass 설정 기회를 함께 줄일 수 있다.

하지만 Shadow, Depth와 Camera Color Pass마다 별도의 Instanced Draw가 필요할 수 있다.

다른 Shader Variant나 Material을 사용하는 Tree는 다른 Instanced Batch로 나뉜다.

---

## Static Batching과 SetPass

Static Batching은 Static Geometry를 결합 가능한 구조로 준비한다.

같은 Material과 State를 사용하는 Mesh의 Draw 준비 비용을 줄일 수 있지만 Unity의 구현과 Culling에 따라 개별 Draw가 남을 수 있다.

```text
Static Batch
같은 Vertex Buffer 범위에서 여러 Draw 가능
↓
Geometry Binding과 State Setup 효율화
```

Static Batching을 사용했다고 Stats의 Batches가 반드시 하나가 되는 것은 아니다.

SetPass와 Draw Counter를 Frame Debugger에서 각각 확인한다.

---

## Dynamic Batching과 SetPass

Dynamic Batching은 호환되는 작은 Mesh를 CPU에서 변환하고 한 Draw로 결합할 수 있다.

```text
같은 Material State
+ 작은 Mesh들
↓
CPU Vertex 결합
↓
SetPass 한 번
Draw 한 번 가능
```

Draw와 State Setup을 줄일 수 있지만 CPU Vertex 변환 비용이 추가된다.

Modern API와 복잡한 Vertex Layout에서는 이득이 작거나 오히려 느릴 수 있다.

Target Platform에서 활성화 전후를 비교한다.

---

## Render State 변경을 줄이는 Material 설계

Surface 기능이 비슷한 Object는 같은 Shader Family를 사용할 수 있다.

```text
Shader를 별도 Asset으로 분리
Lit_Red
Lit_Blue
Lit_Green

공통 Shader 사용
Lit + _BaseColor Property
```

Color 차이만으로 Shader를 나누지 않으면 같은 Variant State를 유지하기 쉽다.

반대로 Opaque와 Transparent처럼 Blend와 Depth State가 본질적으로 다른 Surface를 억지로 하나의 동일 State로 처리할 수는 없다.

실제 Pipeline State 차이와 유지 보수 범위를 기준으로 통합한다.

---

## Keyword를 줄이는 이유

Keyword는 Shader Variant를 만들며 Runtime State Group을 나눈다.

```text
Keyword 1: Normal Map
Keyword 2: Emission
Keyword 3: Detail
Keyword 4: Clear Coat
```

Material 조합이 다양하면 Renderer Sorting 중 Variant 전환이 많아질 수 있다.

작은 수치 차이는 Uniform Property로 유지하고 큰 Compile 경로 차이에 Keyword를 사용한다.

Dynamic Branch로 바꾸는 경우 Variant와 SetPass는 줄 수 있지만 GPU Branch 비용이 생길 수 있으므로 측정해야 한다.

---

## Render Queue Offset의 영향

Material마다 Queue Offset을 달리하면 같은 Shader Variant의 Renderer가 서로 멀리 떨어진 순서에 배치될 수 있다.

```text
Queue 2000: Lit A
Queue 2001: Unlit B
Queue 2002: Lit C
```

Lit A와 Lit C를 연속 처리할 수 없어 State 전환이 늘 가능성이 있다.

Queue Offset은 Z-fighting이나 특정 순서 문제를 임시로 해결하는 데 사용되기도 하지만 Material별 무분별한 값은 Sorting과 Batching을 복잡하게 만든다.

---

## Camera가 늘면 SetPass도 늘까?

Camera마다 Render Loop와 Pass가 반복될 수 있다.

```text
Camera A
Shadow / Opaque / Transparent State 흐름

Camera B
Opaque / Transparent State 흐름 반복
```

같은 Material State라도 Camera 사이에서 Render Target과 Per-camera Data가 바뀌고 Render Pass Queue가 다시 실행된다.

SetPass Counter와 Draw가 늘 가능성이 크지만 정확한 배율은 Camera 설정과 Pipeline 최적화에 따라 다르다.

사용하지 않는 Camera와 중복 Culling Mask를 먼저 확인한다.

---

## Renderer Feature의 영향

URP Renderer Feature가 Object를 다시 그리거나 Full-screen Pass를 추가하면 새로운 Shader Pass와 State가 필요하다.

```text
Opaque Pass
↓
Custom Mask Pass
↓
Full-screen Outline Pass
↓
Transparent Pass
```

Custom Pass가 기본 흐름 사이에 삽입되면 State Group이 끊기고 Render Target도 바뀔 수 있다.

필요한 효과라면 대상 Layer, Pass 수와 Render Target 해상도를 제한해 비용을 관리한다.

---

## CommandBuffer의 SetPass

`CommandBuffer.DrawMesh` 같은 Custom Draw도 Material과 Shader Pass를 지정한다.

```csharp
commandBuffer.DrawMesh(
    mesh,
    matrix,
    material,
    submeshIndex,
    shaderPassIndex
);
```

Custom Code가 Material을 번갈아 가며 Command를 기록하면 State 전환이 증가할 수 있다.

가능하다면 같은 Pass와 Material State를 사용하는 Command를 결과가 허용하는 범위에서 모은다.

Transparent Sorting과 Render Target Dependency를 깨지 않도록 한다.

---

## SetPass Counter가 낮으면 항상 빠를까?

아니다.

SetPass 한 번 뒤에 매우 많은 Draw와 복잡한 GPU 작업이 있을 수 있다.

```text
SetPass 1
Draw 10,000
각 Draw가 복잡한 Geometry
```

또는 한 번의 Full-screen Draw가 매우 비싼 Fragment Shader를 실행할 수 있다.

```text
SetPass 1
Draw 1
4K 화면 전체 × 복잡한 Ray Marching
```

SetPass는 CPU State Setup의 신호이며 GPU Frame 비용 전체를 나타내지 않는다.

---

## SetPass Counter가 높아도 병목이 아닐 수 있다

목표 Device의 CPU가 충분히 빠르고 전체 Frame Budget을 만족한다면 높은 Counter가 당장 문제는 아닐 수 있다.

```text
SetPass 증가
하지만 Main / Render Thread 시간 변화 작음
GPU도 목표 시간 만족
→ 우선순위 낮을 수 있음
```

반대로 Mobile과 낮은 수준 API 지원이 제한된 Platform에서는 같은 숫자의 비용이 더 클 수 있다.

고정된 권장 SetPass 수보다 Profiler의 CPU Rendering 시간을 기준으로 판단한다.

---

## Game View Stats로 확인하기

Game View 오른쪽 위의 Stats를 열면 Batches와 SetPass를 확인할 수 있다.

```text
Batches
Frame의 Draw Call Batch 수

SetPass
Shader Pass 전환 횟수
```

Scene에서 Material과 Shader를 변경한 전후를 빠르게 비교할 수 있다.

Editor Stats에는 Scene View와 Editor 작업 영향이 섞일 수 있고 표시 Counter는 Build Target에 따라 달라질 수 있다.

최종 판단은 Player Build와 Profiler에서 수행한다.

---

## Frame Debugger로 Pass 전환 확인하기

Frame Debugger는 Draw Event를 순서대로 보여 준다.

```text
Event 100: Shader A / Pass Forward
Event 101: Shader A / Pass Forward
Event 102: Shader A / Pass Forward
Event 103: Shader B / Pass Forward
```

각 Event에서 다음 정보를 비교한다.

```text
Shader
Pass Name와 Index
Keyword
Material
Render State
Render Target
Batching 상태
```

Pass나 Variant가 자주 번갈아 나타나는 구간을 찾으면 State 전환 원인을 조사할 수 있다.

---

## SRP Batcher Profiler

SRP Batcher를 사용하는 URP Frame은 Frame Debugger에서 SRP Batch와 Batch Break Reason을 확인할 수 있다.

```text
SRP Batch A
├─ Draw 1
├─ Draw 2
└─ Draw 3

Break
Reason: Different Shader Keywords

SRP Batch B
├─ Draw 4
└─ Draw 5
```

동일한 Material Asset만 찾기보다 같은 Shader Variant 흐름이 얼마나 길게 유지되는지 확인한다.

CPU Profiler에서 SRP Batcher 활성화 전후 Render Thread 시간을 비교한다.

---

## RenderDoc와 Platform Capture

Low-level Graphics Debugger는 실제 Pipeline, Descriptor, Texture와 Buffer Binding을 Draw별로 보여 줄 수 있다.

```text
Unity Frame Debugger
Engine 수준 Object와 Pass 관계

RenderDoc / Xcode GPU Capture / PIX 등
Graphics API와 GPU State 수준
```

Unity Stats의 SetPass가 예상과 다를 때 Low-level Capture로 실제 PSO와 Resource 변경을 조사할 수 있다.

Capture Tool은 Target Graphics API에 맞게 선택한다.

---

## SetPass 최적화 순서

SetPass가 CPU 병목과 관련 있다고 확인되면 다음 순서로 접근할 수 있다.

```text
1. Frame Debugger에서 Pass와 Variant 전환 구간 확인
2. 불필요한 Camera와 Render Pass 제거
3. 거의 같은 Shader Asset 통합 검토
4. Material Keyword 조합 정리
5. Opaque State Sorting을 방해하는 Queue Offset 확인
6. URP SRP Batcher 활성화와 Shader 호환성 확인
7. 반복 Mesh는 GPU Instancing 검토
8. 변경 전후 CPU Render Thread 측정
```

기능을 제거하거나 Shader를 통합할 때 Visual 결과와 Build Variant 비용도 함께 검증한다.

---

## 먼저 줄일 것은 불필요한 Pass

필요 없는 Draw와 Pass를 실행하지 않으면 SetPass와 GPU 작업을 함께 줄일 수 있다.

```text
사용하지 않는 DepthNormals Pass 요청
중복 Outline Renderer Feature
그림자가 필요 없는 작은 Prop의 ShadowCaster
중복 Camera가 같은 Layer Rendering
불필요한 Full-screen Blit
```

다만 Pipeline이 Depth Texture나 Motion Vector를 필요로 하는 이유를 확인하지 않고 Pass를 제거하면 Effect가 잘못될 수 있다.

Frame Debugger에서 Consumer를 추적한 뒤 결정한다.

---

## Material 공유의 범위

같은 Shader와 Property를 사용하는 Object는 Material Asset을 공유하는 것이 좋다.

```text
동일한 Red Material 100개 Asset
→ 중복 Resource와 관리 비용

Shared Red Material 하나
→ 동일 State 유지 가능성 증가
```

Object별 작은 값은 GPU Instancing Property나 상황에 맞는 Data 전달 방법을 검토한다.

MaterialPropertyBlock이 SRP Batcher를 끊을 수 있으므로 많은 Object에서는 두 경로를 비교한다.

---

## Shader 통합의 Trade-off

Shader를 통합하면 State Group을 줄일 수 있지만 Keyword와 Dynamic Branch가 증가할 수 있다.

```text
여러 전용 Shader
State 전환과 Asset 수 증가 가능
각 Program은 단순

하나의 Uber Shader
같은 Shader Variant 정렬 가능성
Keyword Explosion 또는 Branch 복잡도 가능
```

Shader 이름 수를 무조건 줄이는 것이 목표가 아니다.

실제로 함께 Rendering되는 Material이 같은 Variant를 공유할 수 있는 구조인지 판단한다.

---

## Opaque와 Transparent를 억지로 합치지 않기

Opaque와 Transparent는 핵심 Render State가 다르다.

```text
Opaque
Blend Off
ZWrite On

Transparent
Blend SrcAlpha OneMinusSrcAlpha
ZWrite Off가 일반적
```

하나의 Material State로 합치면 정확한 Rendering 순서와 Depth 동작이 깨질 수 있다.

본질적으로 다른 State 전환은 필요한 비용이다.

최적화는 불필요한 차이와 반복을 줄이는 작업이지 모든 State를 동일하게 만드는 작업이 아니다.

---

## SetPass Budget

모든 Platform에 적용되는 고정 SetPass 제한은 없다.

```text
Graphics API
Driver
CPU 성능
SRP Batcher 사용 여부
Shader Variant 수
State 변경 종류
목표 Frame Rate
```

같은 SetPass 수라도 Direct3D 11, Vulkan, Metal과 Console API에서 CPU 비용이 다를 수 있다.

대표 Scene의 Main·Render Thread 시간과 목표 Device Thermal 상태를 기준으로 Budget을 설정한다.

---

## Draw Call 최적화와 함께 보기

SetPass만 줄이고 Draw가 지나치게 많으면 CPU Command 비용이 남는다.

Draw만 줄이고 매 Draw마다 Shader Variant가 바뀌면 State Setup 비용이 남을 수 있다.

```text
Draw 수
Geometry 제출 횟수

SetPass 수
Shader Pass State 전환

둘 다 CPU Rendering 비용에 영향
```

SRP Batcher, GPU Instancing, Static Batching과 Material 정렬은 서로 다른 문제를 해결한다.

Profiler 결과에 맞는 방식을 선택한다.

---

## 예제: 같은 Material의 Cube 100개

같은 Mesh와 Material을 사용하는 Cube 100개를 가정한다.

```text
Batching 없음
SetPass Lit Variant A
→ Draw Cube 1
→ Draw Cube 2
→ ...
→ Draw Cube 100
```

Pass State를 유지하면 SetPass는 Draw보다 훨씬 적을 수 있다.

GPU Instancing이 성공하면 다음과 같이 바뀔 수 있다.

```text
SetPass Lit Instancing Variant
→ Draw Instanced 100 Cubes
```

Draw와 State Setup 기회가 모두 줄어들 수 있다.

---

## 예제: 서로 다른 Variant의 Cube 100개

Cube가 Keyword 조합 네 종류로 나뉜다고 가정한다.

```text
25: Normal Off / Emission Off
25: Normal On  / Emission Off
25: Normal Off / Emission On
25: Normal On  / Emission On
```

State별로 잘 정렬되면 네 개의 큰 Group으로 처리할 수 있다.

```text
Variant 1 SetPass → Draw Group
Variant 2 SetPass → Draw Group
Variant 3 SetPass → Draw Group
Variant 4 SetPass → Draw Group
```

Transparent Depth 순서 때문에 Variant가 교대로 나타나면 같은 네 종류라도 전환 횟수는 훨씬 늘 수 있다.

종류 수뿐 아니라 Draw 순서가 중요하다.

---

## 예제: Character Multi Pass

Character 하나가 세 Material Slot을 가지고 Shadow, Depth와 Forward Pass에 참여한다고 가정한다.

```text
ShadowCaster Pass
→ 3 SubMesh Draw

DepthOnly Pass
→ 3 SubMesh Draw

Forward Pass
→ 3 SubMesh Draw
```

Draw 후보는 아홉 개다.

Pass Group마다 Material의 Variant가 같다면 SetPass 전환은 Draw 수보다 적을 수 있다.

하지만 Hair만 Alpha Clip Variant를 사용하면 각 Group 내부 State가 다시 나뉜다.

---

## 자주 혼동하는 내용

### SetPass Call은 Draw Call이다?

아니다.

SetPass는 Shader Pass와 관련 State 설정이고 Draw Call은 Geometry Rendering 요청이다.

### Material 하나마다 SetPass 하나가 발생한다?

항상 그렇지 않다.

같은 Shader Variant를 사용하는 여러 Material은 SRP Batcher 경로에서 하나의 긴 State Group으로 처리될 수 있다.

### SetPass가 1이면 Draw도 1이다?

아니다.

같은 Pass State를 유지한 채 많은 Mesh를 각각 Draw할 수 있다.

### SRP Batcher는 여러 Draw를 한 Draw로 합친다?

아니다.

주로 같은 Shader Variant의 Draw 준비와 State·Material Binding CPU 비용을 줄인다.

### 같은 Shader면 같은 SetPass Group이다?

반드시 그렇지 않다.

Keyword Variant, Pass, Render State와 Sorting 순서가 다르면 Group이 끊길 수 있다.

### SetPass 수만 줄이면 Rendering이 최적화된다?

아니다.

Draw, Triangle, Pixel, Shader, Texture Bandwidth와 Render Target 비용도 함께 측정해야 한다.

### 모든 State 변경은 Stats의 SetPass에 하나씩 표시된다?

아니다.

SetPass는 Unity 수준의 Shader Pass 전환 Counter이며 Low-level Graphics API Binding 전체를 그대로 나열하는 값은 아니다.

---

## 전체 흐름 다시 연결하기

Renderer 하나가 Draw될 때의 상태 준비를 정리하면 다음과 같다.

```text
Visible Renderer
↓
SubMesh + Material
↓
Shader Pass 선택
↓
Keyword로 Variant 선택
↓
Render State와 Resource 확인
↓
이전 Draw State와 비교
├─ 호환됨 → State 유지와 Data 갱신
└─ 다름   → 새로운 Pass State 설정
↓
Per-object Data 연결
↓
Draw Call
```

Render Pipeline은 Sorting과 SRP Batcher를 이용해 호환되는 Draw가 길게 이어지도록 만들 수 있다.

---

## 정리

SetPass Call은 Unity가 Object Rendering에 사용할 새로운 Shader Pass와 관련 Render State를 설정한 횟수를 나타내는 Counter다.

```text
SetPass
Shader Program + Render State 준비
↓
Material과 Per-object Data 연결
↓
Draw Call
Geometry Rendering 요청
```

여러 Draw가 같은 Shader Variant와 Pass State를 공유하면 하나의 State Group 안에서 처리되어 Draw 수보다 SetPass 수가 적을 수 있다.

Shader, Pass, Keyword Variant, Blend·Depth State와 Sorting 순서가 달라지면 State Group이 끊기고 SetPass 전환이 증가할 수 있다.

SRP Batcher는 Material Constant Data를 GPU Memory에 유지하고 같은 Shader Variant를 사용하는 Draw의 준비와 Dispatch CPU 비용을 줄인다.

SRP Batcher가 Draw Call 자체를 반드시 합치는 것은 아니며 GPU Instancing과 Static·Dynamic Batching은 서로 다른 방식으로 Draw 수를 줄인다.

SetPass Counter는 CPU Render State Setup의 중요한 신호지만 Low-level API State 변경 전체나 GPU Workload를 단독으로 설명하지는 않는다.

Frame Debugger로 Shader Pass, Variant와 SRP Batch Break를 확인하고 CPU Profiler의 Main·Render Thread 및 목표 Platform Capture를 함께 측정해 실제 병목을 최적화해야 한다.
