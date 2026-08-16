---
title: "[Unity 렌더링] 6-6. Deferred Rendering은 무엇일까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - URP
  - DeferredRendering
  - GBuffer
permalink: /programming/unity-6-6-deferred-rendering/
toc: true
toc_sticky: true
date: 2026-08-16
last_modified_at: 2026-08-16
---

Deferred Rendering은 Geometry의 Material 정보를 먼저 여러 Render Target에 기록하고 Lighting 계산을 뒤로 미루는 방식이다.

첫 단계에서는 화면에 보이는 Opaque Surface의 Albedo, Normal, Smoothness와 같은 Data를 G-buffer에 저장한다.

두 번째 단계에서는 G-buffer와 Depth를 읽어 화면 공간에서 Light의 기여를 계산한다.

```text
Geometry Pass
Geometry + Material
        │
        ▼
G-buffer + Depth
        │
        ▼
Deferred Lighting Pass
        │
        ▼
Lit Camera Color
```

`Deferred`는 Lighting을 하지 않는다는 뜻이 아니다.

Geometry를 그리는 시점이 아니라 Surface Data를 저장한 뒤 Lighting을 계산한다는 뜻이다.

---

## Deferred Rendering이란?

Forward Rendering은 Object를 그릴 때 Material과 Light를 함께 계산한다.

Deferred Rendering은 Geometry 처리와 Lighting 처리를 분리한다.

```text
Forward
Geometry → Material + Lighting → Color

Deferred
Geometry → Material Data → G-buffer
                              │
Light ────────────────────────┘
                              ▼
                           Lighting
                              │
                              ▼
                            Color
```

Geometry Pass는 해당 Pixel의 Surface가 무엇인지 기록한다.

Lighting Pass는 그 Surface에 어떤 Light가 영향을 주는지 계산한다.

---

## 왜 Lighting을 뒤로 미룰까?

Scene에 많은 Local Light가 있으면 같은 Geometry의 Lighting을 여러 번 계산할 수 있다.

Deferred는 화면에 최종적으로 보이는 Surface Data를 먼저 확정한다.

그 뒤 Light가 영향을 주는 화면 영역에만 Lighting을 적용할 수 있다.

```text
Camera에 보이는 최종 Pixel
        │
        ▼
Surface Data 한 세트
        │
        ├─ Light A 영향
        ├─ Light B 영향
        └─ Light C 영향
        │
        ▼
Lighting 누적
```

Object별 Realtime Light 제한을 피하면서 많은 Light를 다루기 좋은 구조다.

대신 G-buffer를 만들고 읽는 Memory와 Bandwidth 비용이 생긴다.

---

## URP에서 Deferred 선택하기

URP의 Universal Renderer Data에서 Rendering Path를 `Deferred`로 설정할 수 있다.

```text
URP Asset
└─ Renderer List
   └─ Universal Renderer Data
      └─ Rendering Path: Deferred
```

Camera가 다른 Renderer Data를 선택하고 있다면 변경한 설정이 적용되지 않는다.

Target GPU가 Deferred Path의 요구 사항을 지원하지 않으면 URP가 다른 Path로 Fallback할 수 있다.

Editor뿐 아니라 실제 Build Target에서 Active Renderer와 Pass를 확인해야 한다.

---

## Deferred Frame의 큰 흐름

URP Deferred의 대표적인 Camera 흐름을 단순화하면 다음과 같다.

```text
Camera Culling
      │
      ▼
Shadow Passes
      │
      ▼
Depth / DepthNormals Prepass (필요 시)
      │
      ▼
G-buffer Pass
      │
      ├─ Albedo
      ├─ Specular / Metallic
      ├─ Normal
      ├─ Smoothness
      ├─ Occlusion
      ├─ Emission / GI
      └─ Depth / Stencil
      │
      ▼
Deferred Lighting Pass
      │
      ▼
Forward-only Opaque
      │
      ▼
Skybox와 Transparent Forward
      │
      ▼
Post-processing
```

Renderer Feature, SSAO와 Camera Texture 설정에 따라 Pass는 달라질 수 있다.

---

## Geometry Pass

Geometry Pass는 Opaque Object를 Camera 관점에서 Rasterization한다.

하지만 최종 Direct Lighting Color를 바로 계산하지 않는다.

```text
Opaque Mesh
+ Material Property
+ Texture
        │
        ▼
UniversalGBuffer Shader Pass
        │
        ▼
여러 G-buffer Render Target
```

각 Fragment는 Surface를 나중에 Lighting할 수 있도록 필요한 Data를 Encoding한다.

가장 가까운 Surface의 Data만 Depth Test를 통과해 해당 Pixel에 남는다.

---

## G-buffer란?

G-buffer는 `Geometry Buffer`를 뜻한다.

하나의 Texture가 아니라 여러 Render Target의 묶음이다.

```text
Screen Pixel (x, y)
├─ GBuffer 0: Albedo + Material Flags
├─ GBuffer 1: Specular / Metallic + Occlusion
├─ GBuffer 2: Normal + Smoothness
├─ GBuffer 3: Emission + GI + Lighting Result
└─ DepthStencil: Depth + Material Type
```

실제 Format과 추가 Target은 Platform과 설정에 따라 달라진다.

Lighting Pass는 같은 Screen UV에서 이 Data를 읽어 Surface를 복원한다.

---

## Multiple Render Targets

Geometry Pass는 한 Fragment Shader 실행에서 여러 Render Target에 값을 기록한다.

이 기능을 MRT라고 한다.

```hlsl
struct GBufferOutput
{
    half4 gbuffer0 : SV_Target0;
    half4 gbuffer1 : SV_Target1;
    half4 gbuffer2 : SV_Target2;
    half4 lighting : SV_Target3;
};
```

개념적으로 하나의 Opaque Draw가 Surface Data를 여러 Texture에 동시에 쓴다.

Target GPU가 필요한 MRT 수와 Format을 지원해야 한다.

여러 Target Write는 Memory Bandwidth와 Tile Memory 사용량을 증가시킬 수 있다.

---

## Albedo와 Material Flags

URP G-buffer는 Surface Base Color와 Material 동작 Flag를 저장한다.

```text
GBuffer Albedo Target
├─ RGB: Albedo
└─ A: Material Flags
```

Material Flag에는 다음과 같은 상태가 Bit로 들어갈 수 있다.

- Receive Shadows Off
- Specular Highlights Off
- Subtractive Mixed Lighting
- Specular Setup Workflow

Lighting Pass는 Flag를 읽어 Pixel의 Lighting 분기를 결정한다.

Boolean Option을 별도 Texture로 만들지 않고 제한된 Bit에 Packing한다.

---

## Specular와 Metallic

Material Workflow에 따라 G-buffer의 Specular 영역 의미가 달라질 수 있다.

```text
Simple Lit
└─ RGB Specular Color

Lit Metallic Workflow
└─ Reflectivity / Metallic 관련 값

Lit Specular Workflow
└─ RGB Specular Color
```

Lighting Pass는 Material Type과 Flag를 보고 저장된 값을 해석한다.

같은 Channel이 모든 Material에서 항상 같은 의미라고 가정하면 안 된다.

Custom G-buffer Shader는 URP의 Encoding Contract를 정확히 따라야 한다.

---

## Occlusion

Occlusion 값은 간접광과 Reflection을 줄이는 데 사용할 수 있다.

```text
Final Occlusion
= Baked Material Occlusion
× Screen Space Ambient Occlusion
```

URP는 Baked Occlusion과 SSAO를 조합해 간접광의 가려짐을 계산할 수 있다.

Occlusion을 Direct Light Shadow와 같은 것으로 이해하면 안 된다.

직접광 Shadow는 Shadow Map과 Light Visibility를 통해 별도로 계산된다.

---

## Normal

Deferred Lighting은 Geometry Pass 이후에도 Surface 방향을 알아야 한다.

그래서 World Space Normal을 G-buffer에 Encoding한다.

```text
normalOS
   │ Transform
   ▼
normalWS
   │ Encode
   ▼
G-buffer Normal
   │ Decode
   ▼
Deferred Lighting BRDF
```

Normal의 Encoding Precision은 Smooth Surface의 Highlight와 Reflection 품질에 영향을 준다.

Forward처럼 Shader 내부의 원래 Normal을 바로 사용하는 것과 달리 저장과 복원 단계가 있다.

---

## 기본 Normal Encoding

Unity 6 URP의 기본 Deferred Normal은 RGB Channel에 x, y, z를 각각 8-bit로 Encoding한다.

```text
Normal XYZ
├─ X → 8 bit
├─ Y → 8 bit
└─ Z → 8 bit
```

양자화로 정밀도가 손실될 수 있다.

매끄러운 Surface나 강한 Specular Highlight에서 Banding이 보일 수 있다.

기본 방식은 Encoding과 Decoding 비용을 낮추고 Mobile GPU 성능에 유리할 수 있다.

---

## Accurate G-buffer Normals

Universal Renderer Data에서 `Accurate G-buffer normals`를 활성화할 수 있다.

이 Option은 Octahedral Encoding을 사용해 Normal Precision을 높인다.

```text
Default
├─ RGB 8-bit XYZ Encoding
├─ 낮은 연산 비용
└─ Quantization Artifact 가능

Accurate
├─ Octahedral Encoding
├─ 높은 정밀도
└─ Encode / Decode GPU 비용 증가
```

품질 개선이 모든 Scene에서 눈에 띄는 것은 아니다.

Smooth Metallic Surface와 Close-up Camera에서 차이를 확인하고 비용을 측정한다.

---

## Accurate Normal의 제한

Accurate G-buffer Normals는 일부 Feature와 조합에 제한이 있다.

Unity 6 문서는 다음 항목을 안내한다.

- Screen Space Decal Technique의 Normal Blending
- 네 개를 넘는 Terrain Layer의 Normal Blending

```text
정밀도 향상
        │
        ├─ Encoding 비용
        └─ 일부 Blend 기능 제한
```

Option을 활성화하기 전에 Decal과 Terrain 사용 조건을 확인해야 한다.

---

## Smoothness

Smoothness는 Reflection Lobe의 폭과 Highlight 모양에 영향을 준다.

```text
Low Smoothness
└─ 넓고 흐린 Reflection

High Smoothness
└─ 좁고 선명한 Reflection
```

Deferred Lighting Pass는 G-buffer에서 Smoothness를 읽어 BRDF를 평가한다.

Material Texture의 Channel과 G-buffer Channel은 단계가 다르다.

Geometry Pass가 Material 값을 Decode하고 URP Layout에 다시 Packing한다.

---

## Emission과 Global Illumination

G-buffer의 Lighting Target에는 Emission과 Baked GI가 기록될 수 있다.

Deferred Light Pass는 Realtime Direct Light를 이 Target에 누적한다.

```text
Geometry Pass
Emission + Baked GI
        │
        ▼
Lighting Target
        │
        + Realtime Deferred Lights
        ▼
Lit Opaque Color
```

해당 Render Target Format은 HDR 설정과 Platform Capability에 따라 달라질 수 있다.

Emission이 매우 밝으면 Tone Mapping 전 HDR 범위에 값이 존재한다.

---

## Depth Buffer

Depth는 Camera에서 가장 가까운 Surface까지의 깊이를 저장한다.

Deferred Lighting은 Screen UV와 Depth로 Pixel의 Position을 복원할 수 있다.

```text
Screen UV
+ Device Depth
+ Inverse View Projection
        │
        ▼
World Position 복원
```

G-buffer에 World Position을 별도 RGB Texture로 저장하지 않아도 된다.

Depth Precision, Reversed-Z와 Projection Convention은 URP Helper를 통해 처리해야 한다.

Custom Deferred Effect에서 Depth를 직접 해석할 때 Platform 차이를 주의한다.

---

## Stencil Buffer

URP Deferred는 DepthStencil의 일부 Bit로 Material Type을 구분할 수 있다.

```text
Stencil
├─ Lit Material
├─ Simple Lit Material
├─ Forward-only 구분
└─ Pipeline 내부 상태
```

Deferred Light Pass는 Stencil Test를 사용해 해당 Material Model에 맞는 Lighting Shader를 실행할 수 있다.

Custom Renderer Feature가 Stencil Bit를 무심코 덮으면 Pipeline 내부 분류와 충돌할 수 있다.

사용 가능한 Stencil 범위와 URP 예약 Bit를 Version 문서에서 확인해야 한다.

---

## ShadowMask Target

Mixed Lighting Mode가 Shadowmask 또는 Subtractive 조건이면 G-buffer에 ShadowMask Target이 추가될 수 있다.

```text
기본 G-buffer
+ ShadowMask Render Target
        │
        ▼
Mixed Light의 Baked Visibility 사용
```

Render Target 하나가 늘면 Pixel당 Write와 Memory 사용량이 증가한다.

Lighting Mode를 선택할 때 Visual뿐 아니라 G-buffer Layout 변화도 확인해야 한다.

Frame Debugger와 GPU Capture로 실제 MRT 수를 확인한다.

---

## Rendering Layer Mask Target

Deferred에서 Rendering Layer를 사용하면 추가 Render Target이 필요할 수 있다.

```text
G-buffer
+ Rendering Layer Mask Texture
        │
        ▼
Light와 Pixel의 Layer Matching
```

Unity의 성능 문서는 Deferred에서 Rendering Layers를 사용하지 않는다면 비활성화해 추가 Target을 피하도록 안내한다.

Light Layer 기능이 꼭 필요한 Scene인지 판단하고 Memory와 Bandwidth를 측정한다.

Native Render Pass 사용 여부에 따라 Layout 세부 동작이 달라질 수 있다.

---

## Depth as Color Target

일부 Graphics API와 Native Render Pass 조건에서는 Depth를 Color Target에도 기록할 수 있다.

```text
DepthStencil
        +
Depth as Color
        │
        ▼
같은 Native Render Pass 안에서 Depth 접근 지원
```

Vulkan과 Metal의 Render Pass 제약을 효율적으로 처리하기 위한 Platform별 선택이다.

Deferred의 G-buffer Texture 수를 문서의 고정 숫자로만 외우면 실제 Capture와 다를 수 있는 이유다.

Active Feature와 Graphics API를 기준으로 확인해야 한다.

---

## G-buffer Pass Shader

URP Deferred에 호환되는 Shader는 `UniversalGBuffer` LightMode Pass를 제공한다.

```shaderlab
Pass
{
    Name "GBuffer"

    Tags
    {
        "LightMode" = "UniversalGBuffer"
    }

    HLSLPROGRAM
    // Material Data를 URP G-buffer Layout으로 Encoding
    ENDHLSL
}
```

이 Pass는 최종 Lighting Color가 아니라 Surface Data를 출력한다.

Custom Shader가 `UniversalForward`만 제공하면 Deferred G-buffer Pass에서 그려지지 않을 수 있다.

---

## UniversalMaterialType

G-buffer Pass는 `UniversalMaterialType` Tag로 Lighting Model을 구분할 수 있다.

```shaderlab
Tags
{
    "LightMode" = "UniversalGBuffer"
    "UniversalMaterialType" = "Lit"
}
```

대표적인 Type은 `Lit`과 `SimpleLit`이다.

URP는 Material Type 정보를 Stencil에 기록하고 대응하는 Deferred Lighting을 적용할 수 있다.

Custom Type을 임의로 추가한다고 Pipeline이 새로운 Deferred BRDF를 자동으로 이해하지 않는다.

---

## Deferred Lighting Pass

G-buffer가 준비되면 URP는 Light를 화면 공간에서 처리한다.

```text
Deferred Light
├─ Light Position / Direction
├─ Light Color / Range
├─ Shadow
└─ Cookie
        │
        + G-buffer Surface Data
        + Depth에서 복원한 Position
        │
        ▼
BRDF Lighting Contribution
        │
        ▼
Lighting Target에 누적
```

Light가 영향을 주는 Pixel에만 Shader를 실행하도록 Light Volume과 Tile 정보를 활용할 수 있다.

---

## Directional Light 처리

Directional Light는 Camera 화면 전체에 영향을 줄 가능성이 높다.

```text
Directional Light
└─ Full-screen Lighting 평가
   ├─ G-buffer 읽기
   ├─ Shadow Sampling
   └─ BRDF 계산
```

Surface가 없는 Background Pixel은 Depth와 Stencil을 사용해 제외할 수 있다.

Directional Light 수가 늘면 Full-screen Lighting 비용도 늘 수 있다.

Sun 역할의 주요 Directional Light 수를 제한하는 것이 일반적이다.

---

## Point Light Volume

Point Light는 Sphere 형태의 영향 Volume을 가진다.

```text
       Point Light Range
          _______
       .-'       '-.
      /   Light     \
     |    Volume     |
      \             /
       '-._______.-'
```

Sphere가 화면에 투영된 영역에서만 Deferred Lighting Shader를 실행할 수 있다.

Light가 작고 화면의 일부만 차지하면 Full-screen 계산을 피할 수 있다.

Camera가 Light Volume 안에 있는지 여부에 따라 Cull Mode와 Depth Test가 달라질 수 있다.

---

## Spot Light Volume

Spot Light는 Cone 또는 Pyramid 계열의 영향 Volume으로 표현할 수 있다.

```text
Light
  \
   \
    \________ Cone Volume
```

Volume 밖의 Pixel에는 Light를 계산할 필요가 없다.

Screen에 투영된 Volume이 커질수록 처리할 Fragment 수가 증가한다.

Light Range와 Spot Angle을 Visual에 필요한 최소 범위로 유지하면 Shadow와 Deferred Lighting 비용을 줄일 수 있다.

---

## Tile 기반 Light Culling

URP Deferred는 Screen을 Tile로 나누고 Light가 영향을 주는 Tile을 분류하는 단계를 사용할 수 있다.

```text
Screen Tiles
┌───┬───┬───┬───┐
│ 0 │L1 │L1 │ 0 │
├───┼───┼───┼───┤
│L2 │L1 │L1 │ 0 │
├───┼───┼───┼───┤
│L2 │L2 │ 0 │ 0 │
└───┴───┴───┴───┘
```

각 Tile에서 관련 Light만 처리하면 모든 Light를 모든 Pixel에 적용하지 않아도 된다.

Tile List 생성의 CPU 또는 GPU 비용과 Light 밀도에 따른 Shader 비용이 존재한다.

---

## Stencil Deferred

일부 Light와 Material은 Stencil을 이용해 Light Volume Rendering과 Material Model을 제한한다.

```text
Light Volume Rasterization
        │
        ├─ Depth Test
        ├─ Stencil Test
        └─ Material Type에 맞는 Lighting
        │
        ▼
해당 Pixel에 Light 누적
```

Tile과 Stencil 방식은 서로 배타적인 단일 개념으로만 보면 안 된다.

URP Version과 Light Type에 따라 Deferred Lighting 내부에서 여러 전략을 조합할 수 있다.

---

## Object별 Light 제한이 없는 이유

Deferred Opaque Lighting은 Object를 그릴 때 Light 목록을 고정하지 않는다.

G-buffer가 이미 화면 Surface를 저장했고 Light가 화면 영역에 기여를 누적한다.

```text
Object별 Light List
        ✕

Screen Pixel
├─ Light A 영향
├─ Light B 영향
├─ Light C 영향
└─ Light D 영향
```

그래서 Opaque Object에 영향을 주는 Realtime Light 수를 일반 Forward의 Per Object Limit로 제한하지 않는다.

Camera당 Visible Light와 Hardware Resource 제한은 여전히 존재한다.

---

## 많은 Light가 항상 무료인 것은 아니다

Object별 Limit이 없다는 말은 Light Cost가 없다는 뜻이 아니다.

```text
Light 한 개의 비용
├─ Light Culling
├─ Light Volume / Tile 처리
├─ G-buffer Sampling
├─ BRDF 계산
├─ Shadow Sampling
└─ Lighting Target Blend
```

Screen에서 큰 영역을 차지하는 Light가 많으면 같은 Pixel의 Lighting이 반복된다.

Point Light Range가 지나치게 크면 Deferred의 국소 영역 이점이 줄어든다.

Light Complexity Debug View와 GPU Profiler로 실제 Overlap을 확인해야 한다.

---

## Shadow 처리

Deferred라도 Shadow Map은 Lighting Pass 전에 별도로 Rendering한다.

```text
Shadow Caster Pass
        │
        ▼
Shadow Atlas
        │
        + Deferred Light
        + Reconstructed Position
        │
        ▼
Shadow Attenuation
```

Shadow Cast 비용은 Geometry를 Light 관점에서 다시 그리는 비용이다.

Deferred가 Geometry Camera Pass를 한 번 수행한다고 Shadow Caster Draw가 사라지는 것은 아니다.

Point Light Shadow는 여러 Face 때문에 특히 비쌀 수 있다.

---

## SSAO의 위치

Screen Space Ambient Occlusion은 G-buffer의 Normal과 Depth를 활용하기 좋다.

```text
G-buffer + Depth
        │
        ▼
SSAO Pass
        │
        ▼
Ambient Occlusion Texture
        │
        ▼
Deferred Lighting에서 적용
```

URP 설정에 따라 SSAO를 G-buffer 이후, Deferred Lighting 전에 계산할 수 있다.

Sample 수, Radius, Normal Source와 Downsampling이 품질과 성능에 영향을 준다.

---

## Decal과 G-buffer

Deferred Decal은 Lighting 전에 G-buffer의 Surface Property를 수정할 수 있다.

```text
Base G-buffer
        │
        + Decal Albedo
        + Decal Normal
        + Decal MAOS
        │
        ▼
Modified G-buffer
        │
        ▼
Deferred Lighting
```

Decal이 Lighting 결과가 아니라 Material Data에 섞이므로 여러 Light 아래에서도 자연스럽게 반응한다.

Decal Technique과 Accurate Normal Option의 호환 제한을 확인해야 한다.

---

## Forward-only Opaque Material

모든 Material Model을 제한된 G-buffer Layout으로 표현할 수 있는 것은 아니다.

그런 Material은 Deferred Renderer 안에서도 Forward Pass로 그릴 수 있다.

```text
G-buffer 호환 Opaque
└─ UniversalGBuffer Pass

Forward-only Opaque
└─ UniversalForwardOnly Pass
```

Forward-only Object는 Deferred Light Pass 이후 별도 Opaque Forward 단계에서 처리될 수 있다.

Scene이 Deferred라고 해서 모든 Opaque Pixel이 반드시 G-buffer를 거치는 것은 아니다.

---

## UniversalForwardOnly Pass

Forward-only Shader는 `UniversalForwardOnly` LightMode를 사용할 수 있다.

```shaderlab
Pass
{
    Tags
    {
        "LightMode" = "UniversalForwardOnly"
    }

    HLSLPROGRAM
    // Forward Lighting
    ENDHLSL
}
```

Deferred Renderer는 이 Pass를 G-buffer Lighting과 구분해 Forward로 실행한다.

Complex Lit과 일부 Custom Material이 Forward-only 경로를 사용할 수 있다.

DepthNormalsOnly Pass도 함께 제공해야 Prepass와 SSAO에 필요한 Normal을 만들 수 있다.

---

## Shader가 Deferred에 호환되지 않을 때

Custom Shader가 `UniversalGBuffer`도 `UniversalForwardOnly`도 올바르게 제공하지 않으면 예상대로 그려지지 않을 수 있다.

```text
Deferred Compatibility 확인
├─ UniversalPipeline Tag
├─ UniversalGBuffer Pass
├─ UniversalMaterialType
├─ G-buffer Encoding
├─ DepthNormalsOnly
└─ 또는 UniversalForwardOnly
```

Frame Debugger에서 Object가 GBufferPass에 있는지 Forward-only 단계에 있는지 확인한다.

Pink Material이면 Compile Error와 Pipeline Tag부터 확인한다.

---

## Transparent는 Forward로 그린다

일반적인 G-buffer는 가장 가까운 Opaque Surface 한 세트를 저장한다.

여러 Layer가 겹치는 Transparent Surface Data를 모두 저장하기 어렵다.

```text
Opaque Deferred
Geometry → G-buffer → Deferred Lighting

Transparent Forward
Geometry + Lighting → Blend into Camera Color
```

URP Deferred Path에서도 Transparent Object는 뒤의 Forward 단계에서 Rendering된다.

따라서 Transparent에는 Object별 Realtime Light 제한과 Forward Shader 특성이 적용될 수 있다.

---

## Transparent를 Deferred로 처리하기 어려운 이유

한 Pixel에 유리, 연기와 물이 겹칠 수 있다.

```text
Camera
  │
  ├─ Glass Layer A
  ├─ Smoke Layer B
  ├─ Water Layer C
  └─ Opaque Wall
```

일반 G-buffer는 Pixel당 한 Surface Data만 저장한다.

모든 Transparent Layer를 저장하려면 별도의 복잡한 Data Structure와 많은 Memory가 필요하다.

그래서 Opaque는 Deferred, Transparent는 Forward인 Hybrid 구조가 일반적이다.

---

## Skybox의 위치

Skybox는 G-buffer에 일반 Opaque Material Data를 쓰는 대상이 아니다.

Deferred Opaque Lighting 이후 Background 영역에 그려질 수 있다.

```text
G-buffer Opaque
        │
        ▼
Deferred Lighting
        │
        ▼
Forward-only Opaque
        │
        ▼
Skybox
        │
        ▼
Transparent
```

정확한 순서는 Renderer Feature와 URP Version의 Frame Debugger에서 확인한다.

Depth가 없는 Background Pixel에 Skybox가 표시된다.

---

## MSAA 제한

URP 공식 Rendering Path 비교에서 Deferred는 MSAA를 지원하지 않는다.

Deferred는 여러 G-buffer Target과 Lighting Pass 사이에서 Pixel Data를 공유한다.

```text
4x MSAA G-buffer 가정
├─ Albedo × 4 Samples
├─ Normal × 4 Samples
├─ Material × 4 Samples
├─ Lighting × 4 Samples
└─ Sample별 Lighting / Resolve 문제
```

Memory와 Lighting 처리 복잡도가 크게 증가한다.

Deferred에서는 FXAA, SMAA 또는 Temporal 계열의 Post-process Anti-aliasing을 검토한다.

---

## Camera Stack과 Deferred

URP Camera Stack은 Deferred Renderer에서도 사용할 수 있지만 Base와 Overlay의 Path 동작을 구분해야 한다.

Unity 6 공식 비교는 Deferred Base Camera의 Overlay Camera가 Forward Path를 사용한다고 안내한다.

```text
Base Camera
└─ Deferred Opaque + Lighting
        │
        ▼
Overlay Camera
└─ Forward Rendering
```

Overlay Camera의 Material과 Light 제한은 Base Deferred 결과와 다를 수 있다.

Stack의 Post-processing, Clear와 Depth 동작을 실제 Frame에서 확인한다.

---

## Terrain 제한

Deferred G-buffer의 Material Encoding은 Terrain Layer Blending과 상호작용한다.

Accurate G-buffer Normals를 사용할 때 네 개를 넘는 Terrain Layer의 Normal Blending에 제한이 있다.

```text
Terrain Layer 1 Normal
+ Layer 2 Normal
+ Layer 3 Normal
+ Layer 4 Normal
+ Layer 5 Normal
        │
        ▼
Octahedral Encoded Normal Blend 제한
```

Terrain이 핵심인 Project에서는 Layer 수, Accurate Normal과 Visual 결과를 Prototype에서 검증한다.

---

## Baked와 Mixed Lighting

Deferred Geometry Pass는 Baked GI와 Material 정보를 G-buffer에 저장할 수 있다.

Mixed Lighting Mode에 따라 ShadowMask Target과 Material Flag가 추가된다.

```text
Baked GI
        │
        + Realtime Deferred Light
        + ShadowMask Visibility
        │
        ▼
Final Opaque Lighting
```

Unity 문서는 일부 Mixed Lighting Mode가 Forward Path에 더 최적화되어 있을 수 있다고 안내한다.

사용할 Lighting Mode와 Deferred 조합을 Target Platform에서 측정해야 한다.

---

## G-buffer Memory 계산

Render Target Memory는 Resolution, Format과 Target 수에 비례한다.

```text
Memory
≈ Width
× Height
× Bytes Per Pixel
× Render Target Count
```

1920×1080에서 32-bit Target 하나는 약 8MB의 원시 Pixel Data를 가진다.

Target 네 개와 Depth가 있으면 이보다 훨씬 커진다.

실제 Allocation에는 Alignment, Tile, MSAA 여부와 Driver 관리 비용이 추가될 수 있다.

---

## Resolution과 Bandwidth

Deferred Geometry Pass는 Screen Pixel마다 여러 Target에 Data를 쓴다.

Lighting Pass는 그 Target을 다시 읽는다.

```text
Geometry Pass
└─ G-buffer Write Bandwidth

Lighting Pass
└─ G-buffer Read + Lighting Write Bandwidth
```

Resolution이 두 배가 되면 Pixel 수는 가로와 세로 비율에 따라 네 배가 될 수 있다.

4K에서 G-buffer Bandwidth는 1080p보다 훨씬 큰 부담이 된다.

Dynamic Resolution과 Upscaling을 품질 Budget에 포함한다.

---

## Tile-based Mobile GPU

Tile-based GPU는 작은 On-chip Tile Memory에서 Rendering할 때 효율적이다.

G-buffer Target이 많아 Tile Memory에 맞지 않거나 Render Pass 사이에 외부 Memory로 Store·Load하면 비용이 커질 수 있다.

```text
Tile Memory
├─ GBuffer 0
├─ GBuffer 1
├─ GBuffer 2
├─ Lighting
└─ Depth
        │ 용량 초과 / Pass 분리
        ▼
External Memory Store·Load
```

Native Render Pass와 Input Attachment를 지원하는 Graphics API는 일부 Traffic을 줄일 수 있다.

그래도 Mobile에서 Deferred의 실제 이점은 Device별로 측정해야 한다.

---

## Native Render Pass

Vulkan, Metal과 DirectX 12 같은 API에서 Native Render Pass를 활용하면 Tile 내부 Data 접근을 최적화할 수 있다.

```text
G-buffer Subpass
        │ On-chip Attachment
        ▼
Deferred Lighting Subpass
        │
        ▼
최종 Store
```

URP는 지원 조건에서 Render Texture를 Memory로 복사하는 빈도를 줄일 수 있다.

Renderer Feature가 Native Pass Merge를 방해하거나 외부 Texture 접근을 요구하면 이점이 줄어들 수 있다.

Render Graph Viewer의 Native Render Pass 정보를 확인한다.

---

## 많은 Opaque Light에서의 장점

Deferred는 많은 Local Light가 Opaque Surface에 겹치는 Scene에 적합할 수 있다.

```text
Night City
├─ Street Light
├─ Shop Light
├─ Vehicle Light
├─ Sign Light
└─ Interior Light
        │
        ▼
Screen 영역별 Deferred Lighting
```

Object당 Light 제한 없이 보이는 Pixel에 Light를 누적할 수 있다.

Material Geometry를 Light마다 다시 그리지 않는다.

Light가 작고 영향 영역이 제한적일수록 Light Volume Culling 이점을 얻기 쉽다.

---

## Light가 적을 때의 비용

Scene에 Directional Light 하나만 있어도 Deferred는 G-buffer를 생성하고 읽어야 한다.

```text
Light 1개
├─ G-buffer 여러 Target Write
├─ Depth / Stencil
└─ Full-screen Deferred Lighting
```

Light 수가 적으면 복잡한 G-buffer 구조의 고정 비용을 회수하기 어려울 수 있다.

단순한 Mobile Scene이나 Baked Lighting 중심 Project에서는 다른 Path가 유리할 가능성이 있다.

다음 글에서 동일 조건의 비교 기준을 별도로 연결한다.

---

## Material Shader 비용의 이동

Deferred가 Shader 연산을 없애는 것은 아니다.

Geometry Pass에서 Material Texture와 Surface Data를 계산한다.

Lighting Pass에서 BRDF와 Light를 계산한다.

```text
Geometry Shader Cost
├─ Texture Sampling
├─ Normal Mapping
├─ Alpha Clip
└─ G-buffer Encoding

Lighting Shader Cost
├─ G-buffer Decoding
├─ Position 복원
├─ BRDF
├─ Shadow
└─ Light Accumulation
```

작업의 시점과 반복 축을 분리한 것이다.

---

## Overdraw와 Deferred

Opaque Geometry Overdraw는 G-buffer Write를 반복할 수 있다.

뒤에 가려질 Surface도 Depth Test 전에 Fragment가 실행되면 여러 Target에 값을 쓸 수 있다.

```text
Far Surface
└─ G-buffer Write

Near Surface
└─ 같은 Pixel G-buffer 덮어쓰기
```

Front-to-back Sorting, Early-Z와 Depth Prepass가 Overdraw를 줄이는 데 도움을 줄 수 있다.

Depth Prepass는 Geometry를 추가로 처리하므로 Fragment 절감과 Trade-off를 측정한다.

---

## Alpha Clipping

Alpha Clip Material은 G-buffer Pass에서 `clip()`을 수행할 수 있다.

```text
Texture Alpha < Cutoff
→ Fragment 폐기

Texture Alpha ≥ Cutoff
→ G-buffer + Depth 기록
```

잎과 철망 같은 Cutout은 Opaque Deferred에 포함될 수 있다.

ShadowCaster와 DepthOnly Pass에서도 같은 Cutoff를 사용해야 Shadow와 Depth Silhouette가 일치한다.

높은 Alpha Clip Overdraw는 여러 Texture Write 이전의 Fragment 연산 비용을 만든다.

---

## Deferred Material의 유연성 제한

G-buffer Layout에는 저장할 Channel 수가 제한되어 있다.

```text
Material Feature 추가 요구
├─ Custom Anisotropy
├─ Subsurface Parameter
├─ Multi-layer Coat
└─ 특수 Lighting Model
        │
        ▼
기존 G-buffer에 Packing 가능한가?
```

새 Material Model을 추가하려면 Channel Packing, Material Type 분류와 Deferred Light Shader까지 수정해야 할 수 있다.

단일 Custom Shader만 바꾸는 것보다 Pipeline 전체 Contract의 영향이 크다.

이 경우 Forward-only Pass가 더 현실적일 수 있다.

---

## Custom G-buffer Shader의 책임

Custom Shader가 `UniversalGBuffer` Pass를 제공하면 URP가 기대하는 Layout에 정확히 Encoding해야 한다.

- Albedo Color Space
- Material Flag Bit
- Metallic 또는 Specular Workflow
- Occlusion
- World Normal Encoding
- Smoothness
- Emission과 GI
- Material Type Stencil

```text
잘못된 Normal Encoding
→ Light 방향과 Reflection이 왜곡

잘못된 Material Flag
→ Shadow 또는 Specular 동작 오류
```

URP Package의 `UnityGBuffer.hlsl` Utility와 Lit Shader Source를 참고하는 것이 안전하다.

---

## Renderer Feature와 G-buffer

Custom Renderer Feature는 Deferred의 Pass 순서와 Resource를 이해해야 한다.

```text
Before GBuffer
└─ 아직 Surface Data 없음

After GBuffer
└─ G-buffer 존재, Direct Lighting 전일 수 있음

After Deferred Lights
└─ Opaque Lighting 결과 존재
```

Effect가 Material Data를 수정할지 Lit Color를 수정할지에 따라 Injection Point가 달라진다.

Camera Color만 기대하는 Forward용 Feature를 Deferred에 넣으면 시점이 맞지 않을 수 있다.

---

## Render Graph에서 G-buffer

Unity 6 URP Render Graph는 G-buffer Texture와 Pass 의존성을 기록한다.

```text
GBufferPass
├─ Write GBuffer0
├─ Write GBuffer1
├─ Write GBuffer2
├─ Write Lighting
└─ Write Depth
        │
        ▼
DeferredLightingPass
├─ Read G-buffers
├─ Read Depth
└─ Write Lighting
```

Renderer Feature가 G-buffer Resource를 읽으려면 올바른 Frame Data Handle과 시점을 사용해야 한다.

Pass Input을 선언하면 Graph가 Lifetime과 의존성을 계산할 수 있다.

---

## G-buffer를 Frame 밖에 보관하면 안 되는 이유

Render Graph Texture Handle은 해당 Frame Graph의 Resource를 가리킨다.

```text
Frame N G-buffer Handle
└─ Frame N Pass 사이에서 유효

Frame N+1
└─ 새로운 Resource와 Lifetime
```

Handle이나 Temporary Texture를 다음 Frame까지 임의로 보관하면 Resource Lifetime 규칙과 충돌할 수 있다.

History가 필요하면 Pipeline이 제공하는 Persistent Resource 방식으로 별도 관리한다.

---

## Deferred의 장점

### Opaque Object의 많은 Realtime Light

Object별 Light 제한 없이 화면 Pixel에 Light를 누적할 수 있다.

### Geometry와 Lighting 분리

Material Surface Data를 한 번 기록하고 여러 Light가 재사용한다.

### Screen-space Effect와 Data 공유

Depth와 Normal이 준비되어 SSAO와 Decal 같은 Effect에 활용하기 좋다.

### Light 영향 영역 최적화

Tile과 Light Volume으로 관련 Pixel만 Lighting할 수 있다.

### Light 수와 Geometry Pass 분리

Local Light가 늘어도 G-buffer Geometry Pass 수가 Light마다 증가하지 않는다.

---

## Deferred의 한계

### G-buffer Memory

여러 Full-resolution Render Target이 필요하다.

### Memory Bandwidth

Geometry Pass에서 여러 Target을 쓰고 Lighting Pass에서 다시 읽는다.

### MSAA 미지원

URP Deferred Path는 Hardware MSAA를 지원하지 않는다.

### Transparent의 Forward 처리

Transparent에는 Deferred의 Object Light 장점이 그대로 적용되지 않는다.

### Material Model 제한

G-buffer Layout으로 표현하기 어려운 Material은 Forward-only가 필요하다.

### Normal Encoding

저장과 복원 과정에서 Precision Artifact가 생길 수 있다.

### 저사양·Mobile 비용

MRT와 Bandwidth 부담이 큰 Device에서는 불리할 수 있다.

---

## Deferred가 적합한 Scene

다음 조건에서는 Deferred를 검토할 수 있다.

- Opaque Surface 비중이 높다.
- 좁은 공간에 많은 Point와 Spot Light가 겹친다.
- Object별 Realtime Light 제한을 피해야 한다.
- SSAO와 Decal을 적극적으로 사용한다.
- Target GPU의 MRT와 Bandwidth가 충분하다.
- Hardware MSAA가 필수는 아니다.
- Material 대부분이 URP G-buffer Layout과 호환된다.

```text
Many Local Lights
+ Mostly Opaque
+ Capable GPU
+ G-buffer Compatible Materials
        │
        ▼
Deferred 후보
```

---

## Deferred가 불리할 수 있는 Scene

다음 조건에서는 G-buffer 고정 비용과 Fallback을 주의한다.

- Realtime Light가 매우 적다.
- Transparent Object가 화면 대부분을 차지한다.
- Mobile과 낮은 Memory Bandwidth가 핵심이다.
- MSAA가 반드시 필요하다.
- Forward-only Custom Material이 많다.
- 고해상도 Output에서 Memory Budget이 작다.
- Camera가 많아 G-buffer 작업이 반복된다.

```text
Mostly Transparent
+ Few Lights
+ Tight Bandwidth
        │
        ▼
Deferred 이점 감소 가능
```

---

## G-buffer 최적화

사용하지 않는 추가 Target을 제거하는 것이 중요하다.

- Rendering Layers가 필요 없으면 끈다.
- Mixed Lighting Mode에 따른 ShadowMask 필요성을 확인한다.
- Accurate G-buffer Normals는 품질이 필요할 때만 사용한다.
- HDR Format과 Preserve Framebuffer Alpha 요구를 검토한다.
- Native Render Pass를 지원하는 API에서 활성화 여부를 확인한다.
- 불필요한 Renderer Feature의 G-buffer Input을 제거한다.

```text
Target 하나 감소
→ Geometry Write 감소
→ Lighting Read 감소 가능
→ Memory Peak 감소
```

실제 Layout은 GPU Capture로 검증한다.

---

## Light 최적화

Deferred에서 Object Limit이 없어도 Light를 무제한으로 늘리지 않는다.

- Point와 Spot Light Range를 줄인다.
- 화면 기여가 작은 Light를 Bake한다.
- Shadow가 필요 없는 Light는 Shadow를 끈다.
- Light Cookie Resolution을 관리한다.
- 겹치는 Full-screen Directional Light를 제한한다.
- Light Culling과 Lighting Complexity를 확인한다.

```text
작은 Local Light
→ 작은 Screen Volume
→ 적은 Lighting Pixel

큰 Local Light
→ 화면 대부분 처리
→ 높은 Pixel Cost
```

---

## Shadow 최적화

Deferred Light가 많을 때 Shadow까지 모두 켜면 비용이 빠르게 증가한다.

```text
Shadow Cost
├─ Light별 Shadow Caster Drawing
├─ Atlas Memory
├─ Point Light Face 수
├─ Filtering Sample
└─ Deferred Lighting Shadow Sampling
```

중요한 Light에만 Realtime Shadow를 사용한다.

Shadow Distance, Cascade, Atlas Resolution과 Soft Shadow Quality를 Target Hardware에 맞춘다.

Static Environment에는 Baked Shadow와 Shadowmask를 비교한다.

---

## Resolution 최적화

G-buffer는 대부분 Camera Rendering Resolution을 따른다.

```text
Render Scale 1.0
→ 100% Pixel의 모든 G-buffer 처리

Render Scale 0.75
→ 약 56.25% Pixel
```

Render Scale 또는 Dynamic Resolution은 G-buffer Write, Lighting Read와 Post-processing 비용을 함께 줄일 수 있다.

Upscaling Quality와 Thin Geometry, Text 가독성을 확인해야 한다.

Shadow Atlas처럼 Screen Resolution과 독립적인 비용은 같은 비율로 줄지 않는다.

---

## Depth Prepass 최적화

Deferred는 이미 G-buffer Pass에서 Depth를 쓰지만 일부 Material과 Feature 때문에 Prepass가 필요할 수 있다.

```text
Depth Prepass 필요 후보
├─ Forward-only Opaque Normal
├─ SSAO Input
├─ Depth Priming
├─ Renderer Feature
└─ Platform 조건
```

Prepass가 모든 Opaque를 다시 그리는지 일부 Forward-only Object만 그리는지 확인한다.

복잡한 Alpha Clip Geometry에서는 Depth Prepass도 비쌀 수 있다.

---

## Frame Debugger에서 확인할 항목

URP Deferred Frame을 펼쳐 다음 순서를 확인한다.

- Shadow Pass
- Depth 또는 DepthNormals Prepass
- GBufferPass
- G-buffer Depth Copy
- SSAO
- Deferred Light Pass
- Forward-only Opaque
- Skybox
- Transparent Forward
- Post-processing

```text
Object 선택
├─ UniversalGBuffer인가?
├─ UniversalForwardOnly인가?
├─ 어떤 MRT에 쓰는가?
└─ Material Type Stencil은 무엇인가?
```

---

## Render Graph Viewer에서 확인할 항목

Render Graph Viewer는 Pass와 G-buffer Texture 의존성을 보여 준다.

```text
확인 목록
├─ G-buffer Target 수
├─ 각 Target Format
├─ Producer와 Consumer Pass
├─ Texture Lifetime
├─ Culled Pass
├─ Native Render Pass Merge
└─ Unsafe Pass
```

Custom Feature 때문에 G-buffer가 Frame 후반까지 살아 있는지 확인한다.

긴 Lifetime은 Resource Alias와 Peak Memory 최적화를 제한할 수 있다.

---

## GPU Capture에서 확인할 항목

RenderDoc, Xcode GPU Frame Debugger와 Platform Tool로 실제 Attachment와 Bandwidth 후보를 확인할 수 있다.

- MRT Format과 Resolution
- Load·Store Action
- Render Pass와 Subpass
- G-buffer Sample 수
- Light Volume Draw
- Texture Read 횟수
- Shader Duration
- Tile Store와 External Memory Traffic

```text
Unity 설정
        │
        ▼
Render Graph
        │
        ▼
Graphics API Command
        │
        ▼
GPU Capture
```

최종 Hardware 명령을 봐야 Platform별 비용을 정확히 판단할 수 있다.

---

## Profiler에서 확인할 항목

CPU와 GPU 병목을 나눈다.

```text
CPU
├─ Culling
├─ Light Data와 Tile List 준비
├─ RendererList 구성
└─ Draw Command 제출

GPU
├─ G-buffer Geometry
├─ G-buffer Bandwidth
├─ Deferred Lights
├─ Shadow
├─ Forward-only Opaque
├─ Transparent
└─ Post-processing
```

Light 수를 늘릴 때 Geometry Pass와 Deferred Light Pass 중 어느 쪽이 증가하는지 기록한다.

---

## G-buffer가 보이지 않을 때

Deferred를 설정했는데 Frame Debugger에 GBufferPass가 없다면 다음 항목을 확인한다.

1. Camera가 Deferred로 설정한 Renderer Data를 사용하는가?
2. Active URP Asset이 올바른가?
3. Target GPU가 Deferred를 지원하는가?
4. Scene Camera가 다른 Renderer를 선택하지 않았는가?
5. Frame Debugger에서 올바른 Camera와 Frame을 보고 있는가?
6. Renderer가 2D Renderer가 아닌가?

```text
Renderer Data 설정
≠ 모든 Camera에 자동 적용
```

Active Camera의 Renderer Index를 먼저 확인한다.

---

## Object가 Forward로 그려질 때

Deferred Scene의 일부 Opaque Object가 Forward 단계에 있다면 Shader Pass를 확인한다.

```text
UniversalGBuffer 있음
→ G-buffer 후보

UniversalForwardOnly 있음
→ Forward-only 처리

둘 다 부적절
→ 누락 또는 Error 가능
```

Material Feature가 G-buffer Layout으로 표현할 수 없는지 확인한다.

Forward-only가 의도된 동작일 수도 있으므로 무조건 Error로 판단하지 않는다.

---

## Lighting이 이상할 때

G-buffer Channel을 Debug View와 GPU Capture로 분리한다.

```text
검사 순서
├─ Albedo
├─ Metallic / Specular
├─ Occlusion
├─ Normal
├─ Smoothness
├─ Emission / GI
├─ Depth
└─ Stencil Material Type
```

Normal이 틀리면 Light와 Reflection 방향이 모두 이상해질 수 있다.

Material Flag가 틀리면 Shadow와 Specular가 선택적으로 사라질 수 있다.

Lighting Pass보다 Geometry Encoding 문제인지 먼저 구분한다.

---

## Normal Banding이 보일 때

Smooth Surface의 Highlight가 계단처럼 보이면 G-buffer Normal Quantization을 확인한다.

```text
확인 순서
1. Mesh Normal과 Tangent
2. Normal Map Import
3. G-buffer Normal Debug
4. Accurate G-buffer Normals Test
5. Decal·Terrain 제한 확인
6. GPU 비용 비교
```

Accurate Option을 켜기 전에 Source Normal 자체가 올바른지 확인한다.

Encoding 정밀도를 높여도 잘못된 Mesh Normal은 고쳐지지 않는다.

---

## Memory가 급증할 때

Deferred 전환 후 Memory가 증가하면 실제 Render Target 목록을 확인한다.

```text
증가 후보
├─ 기본 G-buffer MRT
├─ ShadowMask
├─ Rendering Layer Mask
├─ Depth as Color
├─ SSAO
├─ Camera Opaque Texture
├─ Renderer Feature Texture
└─ Post-processing History
```

Camera가 여러 개면 Camera별 Resource가 겹치는 시점도 확인한다.

Average보다 Peak Allocation이 Device Memory Limit을 넘는지 보는 것이 중요하다.

---

## Deferred와 Draw Call

Deferred가 Draw Call을 자동으로 줄이는 것은 아니다.

```text
G-buffer Draw
├─ Material과 Mesh별 Draw
├─ ShadowCaster Draw
├─ Depth Prepass Draw 가능
└─ Forward-only Draw 가능

Deferred Light
├─ Directional Full-screen Draw
└─ Local Light Volume Draw
```

Object Light 수가 늘어도 Geometry를 다시 그리지 않는 장점은 있다.

하지만 Light Volume과 Shadow Draw가 추가되므로 전체 Draw Call은 Scene에 따라 달라진다.

---

## Deferred와 SRP Batcher

G-buffer Geometry Pass의 호환 Shader는 SRP Batcher를 활용할 수 있다.

```text
SRP Batcher
└─ Material Data Binding CPU 비용 최적화

줄이지 않는 비용
├─ G-buffer Pixel Write
├─ Deferred Light Shader
├─ Memory Bandwidth
└─ Shadow Sampling
```

CPU Render Thread가 병목인지 GPU Bandwidth가 병목인지 구분한다.

SRP Batcher Compatible 표시만으로 Deferred 성능을 판단하면 안 된다.

---

## 자주 혼동하는 내용

### Deferred는 Lighting을 나중 Frame에 계산하는가?

아니다.

같은 Frame 안에서 Geometry Pass 뒤의 Lighting Pass로 미룬다는 뜻이다.

### G-buffer는 Texture 하나인가?

아니다.

Albedo, Material, Normal, Lighting과 Depth·Stencil 등을 담는 여러 Render Target의 묶음이다.

### Deferred는 Object마다 Light 수 제한이 있는가?

Opaque Deferred Surface는 일반 Forward의 Per Object Limit를 사용하지 않지만 Camera와 Platform의 Visible Light 제한은 존재한다.

### Deferred에서는 모든 Object가 G-buffer에 들어가는가?

아니다.

Forward-only Opaque, Transparent와 일부 특수 Material은 Forward 단계에서 그릴 수 있다.

### Deferred는 Transparent도 화면 공간에서 Lighting하는가?

일반적으로 아니다.

Transparent는 여러 Layer를 한 G-buffer Pixel에 저장하기 어려워 Forward로 처리한다.

### Deferred는 MSAA를 지원하는가?

URP Deferred Rendering Path는 MSAA를 지원하지 않는다.

### Deferred를 사용하면 Light가 무료인가?

아니다.

Light Culling, G-buffer Sampling, BRDF, Shadow와 Lighting Target Write 비용이 발생한다.

### Accurate G-buffer Normals는 항상 켜야 하는가?

아니다.

정밀도는 높지만 GPU 연산과 일부 Decal·Terrain 호환 제한이 있으므로 필요한 Scene에서 측정한다.

### Deferred는 항상 Forward보다 빠른가?

아니다.

Light 밀도, Resolution, G-buffer Bandwidth, Transparent와 Hardware에 따라 달라진다.

### Deferred는 Draw Call을 항상 줄이는가?

아니다.

Geometry, Shadow, Prepass, Forward-only와 Light Volume Draw를 모두 확인해야 한다.

---

## 전체 구조 다시 연결하기

URP Deferred Rendering의 흐름을 하나로 연결하면 다음과 같다.

```text
Camera Culling
        │
        ▼
Shadow Maps
        │
        ▼
GBufferPass
├─ Albedo + Material Flags
├─ Specular / Metallic + Occlusion
├─ World Normal + Smoothness
├─ Emission / GI / Lighting
├─ Optional ShadowMask
├─ Optional Rendering Layers
└─ Depth + Stencil
        │
        ▼
Deferred Lighting
├─ Depth에서 Position 복원
├─ G-buffer Surface Decode
├─ Tile / Light Volume Culling
├─ BRDF
├─ Shadow
└─ Light Contribution 누적
        │
        ▼
Lit Opaque Camera Color
        │
        ├─ Forward-only Opaque
        ├─ Skybox
        └─ Transparent Forward
        │
        ▼
Post-processing과 Final Output
```

Deferred의 핵심은 화면에 보이는 Opaque Surface Data를 먼저 저장하고 여러 Light가 그 Data를 재사용한다는 점이다.

---

## 정리

Deferred Rendering은 Opaque Geometry의 Surface Data를 G-buffer에 기록한 뒤 별도의 Lighting Pass에서 Light를 계산하는 방식이다.

```text
Geometry + Material
        │
        ▼
G-buffer + Depth
        │
        ▼
Deferred Lighting
        │
        ▼
Lit Camera Color
```

URP G-buffer는 Albedo, Material Flag, Specular 또는 Metallic, Occlusion, World Normal, Smoothness, Emission·GI와 Depth·Stencil 정보를 저장한다.

Deferred Light Pass는 Depth에서 Position을 복원하고 G-buffer의 Surface를 Decode한 뒤 Tile과 Light Volume으로 영향 Pixel을 제한해 BRDF, Shadow와 Light 기여를 누적한다.

Opaque Surface는 일반 Forward의 Per Object Light Limit 없이 많은 Realtime Light를 받을 수 있지만 Camera당 Visible Light와 Hardware 제한은 남는다.

Transparent와 G-buffer로 표현하기 어려운 Material은 `UniversalForwardOnly` 같은 Forward Pass에서 별도로 Rendering된다.

URP Deferred는 MSAA를 지원하지 않으며 여러 Full-resolution G-buffer의 Write·Read 때문에 Memory와 Bandwidth 비용이 크다.

Accurate G-buffer Normals는 Normal Precision을 높이지만 Encoding·Decoding 비용과 Decal·Terrain의 일부 제한을 동반한다.

Rendering Layers, ShadowMask와 Platform별 Depth Target은 G-buffer Attachment를 늘릴 수 있으므로 실제 Layout을 Frame Debugger, Render Graph Viewer와 GPU Capture로 확인해야 한다.

Deferred의 효과는 Opaque 비율, Local Light 밀도, Resolution, Transparent, Material 호환성과 Target GPU의 MRT·Bandwidth 특성을 함께 측정해 판단해야 한다.
