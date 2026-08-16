---
title: "[Unity 렌더링] 6-5. Forward Rendering은 무엇일까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - URP
  - ForwardRendering
  - Lighting
permalink: /programming/unity-6-5-forward-rendering/
toc: true
toc_sticky: true
date: 2026-08-16
last_modified_at: 2026-08-16
---

Forward Rendering은 Geometry를 그리는 시점에 Material과 Light 정보를 사용해 최종 Color를 계산하는 방식이다.

Object의 Vertex와 Fragment가 Shader를 통과할 때 Lighting이 함께 계산되고 Camera Color Target에 결과가 기록된다.

```text
Geometry
  │
  ├─ Material
  ├─ Main Light
  ├─ Additional Lights
  ├─ Shadow
  └─ Reflection
  │
  ▼
Forward Shader
  │
  ▼
Camera Color
```

URP의 일반 Forward Rendering Path는 각 GameObject에 영향을 주는 Light를 선별하고 Object당 하나의 Geometry Pass 안에서 Lighting을 누적한다.

구조가 비교적 직접적이며 Mobile과 Light가 많지 않은 Scene에 적합한 기본 Rendering Path다.

---

## Forward Rendering이란?

`Forward`는 Geometry가 Rasterization될 때 Surface의 Lighting 결과를 앞으로 전달해 최종 Color Target에 기록한다는 Rendering 구조를 가리킨다.

Fragment Shader가 실행되는 시점에는 다음 정보가 준비될 수 있다.

- Base Color와 Material Property
- World Position과 Normal
- View Direction
- Main Light
- Object에 영향을 주는 Additional Light
- Shadow Attenuation
- Indirect Lighting과 Reflection

```text
Fragment Input
├─ Position
├─ Normal
├─ UV
└─ View Direction
        │
        ▼
Material + Lighting 계산
        │
        ▼
Final Fragment Color
```

Surface 정보를 여러 G-buffer에 먼저 저장한 뒤 나중에 Lighting하는 구조와 다르다.

---

## URP에서 Forward의 위치

Universal Renderer는 여러 Rendering Path를 제공한다.

```text
Universal Renderer
├─ Forward
├─ Forward+
└─ Deferred
```

일반 Forward는 URP의 기본 Rendering Path다.

Unity 6에서 Renderer Data의 `Rendering Path`를 `Forward`로 선택해 사용할 수 있다.

Forward+도 Geometry Drawing 단계에서 Lighting을 계산하지만 Light Culling 방식이 다르다.

이번 글의 Forward는 Tile 기반 Light List를 사용하는 Forward+가 아니라 Object별 Light 제한을 사용하는 일반 Forward를 의미한다.

---

## Rendering Path 설정

Forward Path는 Universal Renderer Data에서 선택한다.

```text
URP Asset
└─ Renderer List
   └─ Universal Renderer Data
      └─ Rendering Path: Forward
```

Project에 Renderer Data가 여러 개면 현재 Camera가 어느 Renderer를 사용하는지 확인해야 한다.

한 Renderer의 설정을 바꿔도 다른 Renderer를 선택한 Camera에는 적용되지 않는다.

Platform이 선택한 Path를 지원하지 않으면 URP가 다른 경로로 Fallback할 수 있으므로 Build Target에서도 확인한다.

---

## Forward Frame의 큰 흐름

Camera 한 대의 일반적인 Forward 흐름을 단순화하면 다음과 같다.

```text
Camera Culling
      │
      ▼
Visible Light 수집
      │
      ▼
Main Light 결정
      │
      ▼
Object별 Additional Light 선별
      │
      ▼
Shadow Pass
      │
      ▼
Opaque Forward Draw
      │
      ▼
Skybox
      │
      ▼
Transparent Forward Draw
      │
      ▼
Post-processing
```

실제 Pass는 Depth Texture, Renderer Feature, Camera Stack과 Platform 설정에 따라 달라진다.

Forward는 이 전체 Camera Loop 중 Geometry의 Lighting을 처리하는 핵심 경로다.

---

## Object를 그릴 때 Lighting을 계산한다

Forward Shader는 Object의 Geometry가 그려질 때 Lighting을 계산한다.

```text
Object A Draw
└─ A에 영향을 주는 Light로 Lighting

Object B Draw
└─ B에 영향을 주는 Light로 Lighting

Object C Draw
└─ C에 영향을 주는 Light로 Lighting
```

모든 Object가 Camera의 모든 Light를 무조건 순회하지 않는다.

URP는 Culling 결과와 Light 영향 범위를 바탕으로 Object별 Light 목록을 구성한다.

일반 Forward에서는 Object에 전달할 Realtime Light 수에 제한을 둔다.

---

## Main Light

URP는 일반적으로 하나의 Light를 Main Light로 다룬다.

Scene의 가장 중요한 Directional Light가 Main Light가 되는 경우가 많다.

```text
Visible Lights
├─ Directional Light A → Main Light 후보
├─ Point Light B
├─ Spot Light C
└─ Point Light D
```

Main Light Data는 Additional Light와 별도 경로로 Shader에 전달된다.

Main Light는 Direction, Color, Distance Attenuation과 Shadow Attenuation 같은 값을 제공한다.

URP Asset에서 Main Light를 Per Pixel 또는 Disabled로 설정할 수 있는 조건도 있다.

---

## Additional Light

Main Light 이외의 Realtime Light는 Additional Light로 처리할 수 있다.

```text
Object
├─ Main Light
├─ Additional Light 0
├─ Additional Light 1
├─ Additional Light 2
└─ ... Per Object Limit까지
```

Point, Spot과 추가 Directional Light가 포함될 수 있다.

일반 Forward에서는 Object마다 영향을 줄 Additional Light를 선별해 제한된 목록을 전달한다.

Scene 전체 Visible Light 수와 한 Object가 실제로 계산하는 Light 수는 서로 다르다.

---

## Object별 Light 제한

URP Asset의 `Additional Lights > Per Object Limit`는 일반 Forward에서 Object 하나가 계산할 Additional Light 수를 제한한다.

```text
Camera에 보이는 Light: 40개
        │
        ▼
Object A 주변 후보: 12개
        │ Per Object Limit = 4
        ▼
Object A가 계산하는 Additional Light: 4개
```

Unity 6의 공식 비교표는 Main Light를 포함해 일반 Forward에서 Object당 최대 9개의 Realtime Light를 표시한다.

구체적인 제한은 URP Version과 Platform 설정을 기준으로 확인해야 한다.

Limit을 낮추면 Pixel 또는 Vertex Lighting 반복을 줄일 수 있지만 일부 Light 기여가 빠질 수 있다.

---

## Light 우선순위와 선별

여러 Light가 Object에 영향을 줄 때 URP는 제한 안에 넣을 Light를 선택해야 한다.

```text
Object Bounds와 겹치는 Light
├─ Light A: 강한 영향
├─ Light B: 가까움
├─ Light C: 넓은 Range
├─ Light D: 약한 영향
└─ Light E: 경계만 겹침
        │
        ▼
제한된 Object Light List
```

Light 선별 결과가 Camera나 Object 이동에 따라 바뀌면 특정 Light 기여가 갑자기 나타나거나 사라져 보일 수 있다.

큰 Mesh 하나에 많은 Light가 겹치는 Scene은 일반 Forward의 Object별 제한을 쉽게 드러낸다.

---

## 한 Pass에서 Light를 누적한다

URP의 일반 Forward는 Object당 하나의 Rendering Pass 안에서 선택된 Light의 기여를 반복해 더할 수 있다.

```text
Final Lighting
= Main Light Contribution
+ Additional Light 0 Contribution
+ Additional Light 1 Contribution
+ Additional Light 2 Contribution
+ Indirect Lighting
+ Emission
```

Built-in Forward의 `ForwardAdd`처럼 Additional Light마다 Geometry를 별도 Pass로 다시 그리는 구조와 구분해야 한다.

URP Forward의 Light Loop는 Shader 안에서 실행된다.

Light 수가 늘어도 Object Pass 수가 동일할 수 있지만 Fragment Shader의 반복 연산은 증가한다.

---

## Pass 수와 Shader 비용

Object당 Rendering Pass가 하나라는 말은 Lighting Cost가 고정이라는 뜻이 아니다.

```text
Object A: Additional Light 0개
Fragment당 Light 계산 1회 수준

Object B: Additional Light 4개
Fragment당 Main + Additional 반복
```

같은 Draw Call 수라도 Object B가 더 많은 GPU 연산을 수행할 수 있다.

Performance 분석에서 Draw Call과 Fragment Shader 비용을 함께 봐야 한다.

Forward의 Light 수 제한은 Shader Loop 비용을 예측 가능한 범위로 묶는 역할도 한다.

---

## Vertex Lighting과 Pixel Lighting

URP는 일반 Forward에서 Additional Light를 Per Vertex 또는 Per Pixel로 계산하도록 설정할 수 있다.

```text
Per Vertex
Vertex Shader에서 Light 계산
→ Vertex 값을 보간
→ Fragment에서 사용

Per Pixel
Fragment마다 Light 계산
→ 더 정확한 국소 Lighting
```

Per Vertex는 Fragment 수가 많은 Mesh에서 연산 비용을 줄일 수 있다.

하지만 Vertex 밀도가 낮으면 작은 Point Light나 Specular Highlight가 부정확해질 수 있다.

Per Pixel은 품질이 높지만 화면을 덮는 Pixel과 Light 수에 따라 비용이 증가한다.

---

## Vertex Density가 품질에 미치는 영향

Per Vertex Lighting 결과는 Vertex 사이에서 보간된다.

```text
낮은 Vertex Density
o----------------o
       Light
→ 중앙 Light 변화 표현이 부족할 수 있음

높은 Vertex Density
o---o---o---o---o
        Light
→ 변화 표현이 더 세밀함
```

작은 Point Light가 큰 Quad 중앙을 비추는데 Vertex가 모서리에만 있으면 Light가 거의 보이지 않을 수 있다.

Per Vertex를 사용할 때는 Mesh Tessellation과 Light Size를 함께 고려한다.

성능 절약을 위해 Polygon을 늘리면 Vertex 비용과 Memory가 증가하므로 Trade-off를 측정해야 한다.

---

## Opaque Forward Pass

Opaque Object는 일반적으로 `UniversalForward` 계열 Shader Pass로 그려진다.

```shaderlab
Pass
{
    Name "ForwardLit"

    Tags
    {
        "LightMode" = "UniversalForward"
    }

    HLSLPROGRAM
    // Forward Lighting Shader
    ENDHLSL
}
```

Renderer가 요청하는 `ShaderTagId`와 Pass의 `LightMode`가 일치해야 한다.

Built-in용 `ForwardBase` Pass만 가진 Shader는 URP Forward Contract를 충족하지 않는다.

---

## UniversalForwardOnly

URP에는 `UniversalForwardOnly` LightMode도 있다.

Forward 전용 Material Pass를 명시하거나 Deferred Renderer에서도 해당 Object를 Forward로 그려야 하는 경우 사용할 수 있다.

```text
UniversalForward
└─ URP Forward Lighting Pass

UniversalForwardOnly
└─ 선택한 Rendering Path에서 Forward로만 처리할 Pass
```

복잡한 Material Feature가 G-buffer에 맞지 않거나 Forward 전용 구현이 필요할 때 의미가 있다.

정확한 Pass 선택은 사용 중인 URP Shader와 Renderer Path를 Frame Debugger에서 확인한다.

---

## Forward Shader의 기본 입력

Lighting을 계산하려면 Object Space Data를 적절한 공간으로 변환해야 한다.

```text
Vertex Input
├─ positionOS
├─ normalOS
├─ tangentOS
└─ uv
        │
        ▼
Vertex Shader
├─ positionCS
├─ positionWS
├─ normalWS
└─ viewDirectionWS 계산
        │
        ▼
Fragment Shader
```

Position과 Normal의 Coordinate Space가 일치하지 않으면 Light Direction과 Dot Product 결과가 틀어진다.

URP Shader Library의 Transform Function을 사용하면 Platform별 Convention을 직접 처리하는 부담을 줄일 수 있다.

---

## URP Lighting Library

Custom URP Shader에서 Lighting Helper를 사용하려면 `Lighting.hlsl`을 포함할 수 있다.

```hlsl
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
```

대표적인 Function은 다음과 같다.

| Function | 역할 |
| --- | --- |
| `GetMainLight()` | Main Light Data 반환 |
| `GetAdditionalLightsCount()` | 현재 계산할 Additional Light 수 반환 |
| `GetAdditionalLight()` | 특정 Additional Light Data 반환 |
| `LightingLambert()` | 단순 Diffuse Lighting 계산 |
| `LightingSpecular()` | 단순 Specular Lighting 계산 |

Pipeline Version에 따라 Overload와 필요한 Parameter가 달라질 수 있으므로 설치된 Package의 Shader Library를 기준으로 작성한다.

---

## Light 구조체

URP Lighting Function은 Light 정보를 구조체로 제공한다.

```text
Light
├─ direction
├─ color
├─ distanceAttenuation
├─ shadowAttenuation
└─ layerMask
```

Lighting의 한 Light 기여를 단순화하면 다음처럼 볼 수 있다.

```text
Contribution
= BRDF(Material, Normal, View, Light Direction)
× Light Color
× Distance Attenuation
× Shadow Attenuation
```

Point와 Spot Light는 거리에 따른 감쇠가 중요하다.

Shadow가 없는 Pixel은 일반적으로 Shadow Attenuation이 Light를 줄이지 않는다.

---

## Main Light Diffuse 예제

다음은 개념을 보여 주는 단순한 Lambert 계산이다.

```hlsl
Light mainLight = GetMainLight();

half NdotL = saturate(
    dot(normalize(normalWS), mainLight.direction)
);

half3 diffuse =
    baseColor
    * mainLight.color
    * NdotL
    * mainLight.distanceAttenuation
    * mainLight.shadowAttenuation;
```

실제 URP Lit Shader는 PBR BRDF, GI, Reflection, Fog와 여러 Feature를 더 처리한다.

이 예제는 Forward Fragment에서 Material과 Light가 결합되는 위치를 보여 주기 위한 최소 구조다.

---

## Additional Light Loop

Additional Light의 기여는 Loop로 누적할 수 있다.

```hlsl
uint lightCount = GetAdditionalLightsCount();

for (uint lightIndex = 0u;
     lightIndex < lightCount;
     ++lightIndex)
{
    Light light = GetAdditionalLight(
        lightIndex,
        positionWS
    );

    half NdotL = saturate(
        dot(normalWS, light.direction)
    );

    color += baseColor
        * light.color
        * NdotL
        * light.distanceAttenuation
        * light.shadowAttenuation;
}
```

실제 Shader에서는 URP가 제공하는 Light Loop Macro와 Version별 API를 따라야 한다.

핵심은 하나의 Fragment 결과 안에 여러 Light 기여가 더해진다는 점이다.

---

## Shader Variant

Main Light, Additional Light와 Shadow Feature는 Shader Keyword와 Variant에 영향을 줄 수 있다.

```hlsl
#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
```

이 Keyword 목록은 개념적인 URP Forward 설정 예다.

설치된 URP Version의 공식 Shader를 기준으로 필요한 Variant를 구성해야 한다.

Variant가 없으면 해당 Feature가 활성화되어도 Shader가 올바른 경로를 실행하지 못할 수 있다.

사용하지 않는 Variant까지 과도하게 포함하면 Build Time과 Size가 증가한다.

---

## Main Light Shadow

Main Light가 Shadow를 Cast하면 Forward Color Pass 전에 Shadow Map이 준비된다.

```text
Main Light 관점
├─ Shadow Caster Culling
├─ Shadow Atlas에 Depth 기록
└─ Cascade별 영역 구성
        │
        ▼
Forward Fragment
└─ World Position으로 Shadow Sampling
```

Main Light Shadow의 비용은 Shadow Caster Drawing과 Fragment Sampling 양쪽에 존재한다.

Cascade 수, Shadow Distance, Atlas Resolution과 Filtering Quality가 영향을 준다.

---

## Shadow Coordinate

Fragment가 Shadow를 받으려면 World Position을 Shadow Map 좌표로 변환해야 한다.

```hlsl
float4 shadowCoord = TransformWorldToShadowCoord(positionWS);
Light mainLight = GetMainLight(shadowCoord);
```

`GetMainLight()`의 Overload는 Shadow Data를 포함한 Light 정보를 반환할 수 있다.

Vertex에서 Shadow Coordinate를 계산해 보간할지 Fragment에서 계산할지는 Keyword와 Shader 구현에 따라 달라질 수 있다.

Shadow Artifact가 있으면 Bias, Normal, Cascade와 Coordinate 계산을 함께 확인한다.

---

## Additional Light Shadow

Additional Point와 Spot Light도 설정과 Platform 지원 범위에서 Shadow를 가질 수 있다.

```text
Additional Light Shadow Atlas
├─ Spot Light A Shadow
├─ Point Light B Cube Face Shadows
└─ Spot Light C Shadow
        │
        ▼
Additional Light Loop에서 Sampling
```

Point Light Shadow는 여러 방향을 처리해야 하므로 비용이 클 수 있다.

Additional Light 수뿐 아니라 Shadow를 Cast하는 Light 수를 별도로 관리해야 한다.

Light가 화면에 작게 보이더라도 Shadow Atlas Rendering Cost는 존재할 수 있다.

---

## Direct Lighting과 Indirect Lighting

Forward Shader의 최종 결과는 Realtime Direct Light만으로 이루어지지 않는다.

```text
Final Surface Lighting
├─ Main Direct Light
├─ Additional Direct Lights
├─ Baked Lightmap
├─ Light Probe / APV
├─ Reflection Probe / Sky
├─ Ambient Occlusion
├─ Emission
└─ Fog
```

Indirect Diffuse는 Lightmap, Probe와 Environment에서 올 수 있다.

Specular Reflection은 Reflection Probe 또는 Sky Environment를 Sampling할 수 있다.

Forward는 이 정보를 Material Shader에서 결합해 최종 Color를 만든다.

---

## BRDF 계산

PBR Forward Shader는 Material Property와 Light 관계를 BRDF로 계산한다.

```text
Material
├─ Base Color
├─ Metallic
├─ Smoothness
├─ Normal
└─ Occlusion
        │
        + Light Direction / Color
        + View Direction
        │
        ▼
Diffuse + Specular Response
```

Light 수가 늘면 동일한 BRDF 평가가 Light마다 반복될 수 있다.

복잡한 Clear Coat나 Custom Lighting을 추가하면 Light Loop의 반복 비용도 커진다.

Shader Complexity와 Object Light 수를 함께 측정해야 한다.

---

## Normal의 정확도

Forward는 Fragment Shader가 사용하는 Normal을 직접 계산하거나 Normal Map에서 복원한다.

G-buffer에 Normal을 Encoding했다가 다시 Decoding하는 단계가 필수는 아니다.

```text
Vertex Normal / Normal Map
        │
        ▼
Tangent Space 변환
        │
        ▼
Fragment의 World Normal
        │
        ▼
Lighting 계산
```

Unity 공식 비교표는 Forward의 Per-pixel Normal이 Encoding 없이 정확하다는 특징을 제시한다.

Normal Map 품질, Tangent와 Mesh Import 설정은 여전히 최종 결과에 영향을 준다.

---

## Material 다양성

Forward는 Object를 그릴 때 Material Shader가 Lighting을 직접 계산하므로 Material Model을 유연하게 구성하기 쉽다.

```text
Object A
└─ Standard PBR Forward Shader

Object B
└─ Stylized Ramp Forward Shader

Object C
└─ Hair 전용 Forward Shader
```

모든 Material이 동일한 G-buffer Layout에 Surface Data를 맞출 필요가 없다.

대신 Material마다 다른 Shader와 Variant가 실행되면 State 변경과 Shader 관리 비용이 증가할 수 있다.

---

## MSAA와 Forward

URP Forward는 MSAA를 지원한다.

MSAA는 Triangle Edge의 Coverage를 여러 Sample로 평가해 Geometry Edge Aliasing을 줄인다.

```text
Pixel
├─ Sample 0: Triangle 안
├─ Sample 1: Triangle 안
├─ Sample 2: Triangle 밖
└─ Sample 3: Triangle 밖
        │
        ▼
Coverage를 반영한 Resolve
```

Forward에서는 Lighting Color Target을 Multi-sample로 처리할 수 있다.

MSAA는 Sample Count만큼 Color·Depth Memory와 일부 연산 비용을 늘릴 수 있다.

Shader 내부의 Texture Detail이나 Transparent Alias를 모두 해결하는 것은 아니다.

---

## Mobile에서 MSAA

Tile-based Mobile GPU에서는 MSAA가 다른 Anti-aliasing 방식보다 효율적인 경우가 있다.

하지만 Device와 Render Target 구성에 따라 비용이 달라진다.

```text
MSAA Cost 후보
├─ Multi-sample Color
├─ Multi-sample Depth
├─ Resolve
├─ Memory Bandwidth
└─ 중간 Texture 호환성
```

2x, 4x와 8x를 실제 Device에서 비교한다.

Render Scale, Post-processing과 Camera Texture가 MSAA 경로에 어떤 Copy를 추가하는지도 확인해야 한다.

---

## Transparent Rendering

Transparent Object도 일반적으로 Forward로 Lighting을 계산한다.

```text
Opaque Forward Draw
        │
        ▼
Skybox / Color Copy
        │
        ▼
Transparent Forward Draw
├─ Lighting
├─ Texture Sampling
└─ Blend
```

Transparent는 이미 그려진 Camera Color와 Blend해야 하므로 뒤에서 앞으로 정렬하는 것이 일반적이다.

여러 투명 Surface가 겹치면 Fragment Lighting과 Blend가 반복되어 Overdraw 비용이 커진다.

Forward는 Opaque와 Transparent 모두 같은 Material Lighting Model을 사용하기 자연스럽다.

---

## Transparent와 Depth

Transparent Material은 일반적으로 Depth Test를 하지만 Depth Write는 끈다.

```text
ZTest: 기존 Opaque Depth와 비교
ZWrite: Off
Blend: On
```

뒤의 Transparent Object가 계속 Rendering되어야 하기 때문이다.

하지만 Object 단위 Sorting만으로 교차하는 투명 Geometry의 정확한 순서를 해결할 수 없다.

Alpha Clipping으로 Opaque Queue에서 처리할 수 있는 Material인지 검토하면 Sorting과 Overdraw를 줄일 수 있다.

---

## Alpha Clipping

Cutout 형태의 잎, 철망과 Fence는 Alpha Blend 대신 Alpha Clipping을 사용할 수 있다.

```hlsl
clip(alpha - cutoff);
```

```text
Alpha Blend
└─ 반투명 Color를 기존 Color와 혼합

Alpha Clip
└─ Pixel을 완전히 유지하거나 버림
```

Alpha Clip Material은 Depth Write와 Opaque 계열 Sorting을 활용할 수 있다.

Fragment가 `clip`까지 실행된 뒤 버려지므로 아주 높은 Overdraw에서는 여전히 비용이 발생한다.

---

## Forward와 Depth Prepass

Forward라고 해서 Depth를 Color와 항상 한 번에만 그리는 것은 아니다.

Renderer Feature나 Depth Texture 요구에 따라 Depth Prepass가 추가될 수 있다.

```text
Depth Prepass
        │
        ▼
Forward Opaque Pass
├─ Depth Test
├─ Material
└─ Lighting
```

Depth Priming은 미리 작성한 Depth를 활용해 Opaque Fragment Overdraw를 줄일 수 있다.

Geometry를 추가로 그리는 비용과 절약되는 Fragment 비용을 Target GPU에서 비교해야 한다.

---

## Forward의 Render Target

일반 Forward Opaque Lighting은 주로 Camera Color와 Depth Target을 사용한다.

```text
Forward Opaque Pass
├─ Write: Camera Color
└─ Write/Test: Camera Depth
```

Surface Property를 여러 G-buffer Target에 동시에 저장하는 것이 핵심 요구가 아니다.

그래서 Multiple Render Target과 G-buffer Bandwidth가 부담인 Platform에서 유리할 수 있다.

다만 Opaque Texture, Depth Texture, Renderer Feature와 Post-processing이 별도 Intermediate Target을 추가할 수 있다.

Forward라는 이름만으로 Frame 전체 Texture 수가 적다고 단정하면 안 된다.

---

## Memory와 Bandwidth

Forward는 Lighting 결과를 Camera Color에 직접 기록하므로 Geometry Surface Data용 G-buffer가 필수는 아니다.

```text
기본 Forward Target
├─ Color
└─ Depth

조건부 Target
├─ Shadow Atlas
├─ Camera Opaque Texture
├─ Camera Depth Texture
├─ Normal Texture
└─ Post-process Intermediate
```

Forward의 Memory 장점은 추가 Feature가 적을 때 더 분명할 수 있다.

Full-screen Renderer Feature를 여러 개 추가하면 Texture Read·Write Bandwidth가 커진다.

---

## Tile-based GPU와 Forward

많은 Mobile GPU는 화면을 Tile로 나눠 On-chip Memory에서 Rasterization한다.

```text
Screen
├─ Tile 0
├─ Tile 1
├─ Tile 2
└─ Tile 3

각 Tile의 Color·Depth를 On-chip에서 처리
→ 필요할 때 External Memory에 저장
```

적은 Render Target과 단순한 Pass 구조는 Tile-based Architecture에 유리할 수 있다.

중간 Texture Copy와 Pass 전환이 Tile Store·Load를 유발하면 이점이 줄어들 수 있다.

Mobile에서 Forward가 자주 선택되는 이유를 GPU Architecture와 함께 이해해야 한다.

---

## Light 수가 적을 때의 장점

Scene의 한 Object에 영향을 주는 Light가 적으면 Forward Light Loop가 짧다.

```text
Outdoor Scene
├─ Main Directional Light 1개
├─ Baked Indirect
└─ 일부 지역 Additional Light
        │
        ▼
짧고 예측 가능한 Light Loop
```

Material Lighting 결과를 직접 계산하고 추가 G-buffer Lighting Pass가 필요하지 않다.

Unity는 Light가 많지 않거나 Mobile과 저사양 Platform인 경우 일반 Forward 사용을 안내한다.

---

## Light 수가 많을 때의 문제

많은 Light가 같은 Object에 겹치면 두 가지 문제가 생긴다.

```text
문제 1: Per Object Limit
일부 Light가 Object 목록에 들어오지 못함

문제 2: Shader Loop Cost
선택된 Light가 많을수록 Fragment 연산 증가
```

특히 화면을 크게 덮는 Object는 많은 Fragment에서 같은 Light Loop를 반복한다.

큰 Floor Mesh에 여러 Point Light가 겹치면 제한 전환과 비용이 눈에 띌 수 있다.

Light 수가 많은 Scene에서는 Mesh 분할, Baked Lighting 또는 다른 Light Culling 구조를 검토한다.

---

## 큰 Mesh와 Object Light List

일반 Forward Light List는 Object 단위로 구성된다.

큰 Mesh가 넓은 공간을 차지하면 서로 멀리 떨어진 Light가 같은 Object Bounds에 영향을 줄 수 있다.

```text
하나의 큰 Floor Mesh
┌─────────────────────────┐
│ L1   L2   L3   L4   L5 │
└─────────────────────────┘
→ 하나의 Object Light Limit 공유

여러 Floor Chunk
┌─────┬─────┬─────┬─────┐
│ L1  │ L2  │ L3  │ L4  │
└─────┴─────┴─────┴─────┘
→ Chunk별 Light List
```

Mesh를 적절히 나누면 지역별 Light 선택이 정확해질 수 있다.

너무 많이 나누면 Renderer와 Draw Call 수가 늘어난다.

---

## Mesh 분할의 Trade-off

Mesh 분할은 Light 제한만 보고 결정하면 안 된다.

| 작은 수의 큰 Mesh | 많은 수의 작은 Mesh |
| --- | --- |
| Draw와 Renderer 관리가 단순 | Culling Granularity가 좋아짐 |
| Object Light List가 넓은 영역 공유 | 지역 Light List가 정확해짐 |
| 보이지 않는 부분도 함께 Draw 가능 | Draw Call과 CPU Overhead 증가 가능 |
| Bounds가 큼 | Bounds가 작음 |

Scene Structure, Occlusion, Static Batching과 Light 배치를 함께 평가한다.

Frame Debugger와 Profiler로 변경 전후를 비교한다.

---

## Baked Lighting 활용

Realtime Light를 모두 Forward Light Loop에서 계산할 필요는 없다.

변하지 않는 Lighting은 Lightmap에 Bake할 수 있다.

```text
Static Environment
└─ Baked Lightmap

Dynamic Character
└─ Light Probe / Adaptive Probe Volume

핵심 Dynamic Light
└─ Realtime Main / Additional Light
```

Realtime Light와 Shadow 수를 줄이면 CPU Light 관리, Shadow Rendering과 Fragment Loop 비용을 낮출 수 있다.

Baked Lighting은 Texture Memory, Bake Time과 동적 변화 제한이라는 Trade-off를 가진다.

---

## Mixed Lighting

Mixed Light는 Baked와 Realtime 정보를 조합한다.

```text
Mixed Light
├─ Static Object: Baked Lighting 정보 활용
└─ Dynamic Object: Realtime Direct 영향 가능
```

Lighting Mode에 따라 Shadowmask, Subtractive와 Baked Indirect 동작이 달라진다.

Forward Path는 일부 Mixed Lighting Workflow와 잘 맞을 수 있다.

Scene의 Static·Dynamic 비율과 Target Platform에 맞는 Mode를 선택하고 실제 Shader Variant와 Texture 비용을 확인한다.

---

## Reflection Probe

Forward Lit Material은 Reflection Probe와 Sky Environment로 간접 Specular를 계산할 수 있다.

```text
Reflection Vector
        │
        ├─ Object 주변 Reflection Probe
        └─ Probe가 없으면 Sky Environment
        │
        ▼
Roughness에 맞는 Mip Sampling
```

일반 Forward에는 Object별 Reflection Probe Blending 수에도 구조적 제한이 있을 수 있다.

많은 Probe를 부드럽게 Blend해야 하는 Scene은 다른 Path의 선택 기준이 될 수 있다.

Probe Resolution과 Update Mode는 Memory와 Rendering Cost에 영향을 준다.

---

## Fog

Forward Fragment의 Lighting 결과에는 Fog가 적용될 수 있다.

```text
Surface Color
        │
        + Camera Distance
        + Fog Density / Color
        │
        ▼
Fogged Color
```

Fog Factor를 Vertex에서 계산해 보간하거나 Fragment에서 계산할 수 있다.

Transparent도 Fog가 일관되게 적용되어야 Scene Depth가 자연스럽다.

Custom Forward Shader에서 Fog Keyword와 URP Helper를 빠뜨리면 Built-in Material과 다른 결과가 날 수 있다.

---

## Light Layer와 Rendering Layer

Rendering Layer를 사용하면 특정 Light가 특정 Renderer에만 영향을 주도록 구성할 수 있다.

```text
Light A Layer Mask: Character
Light B Layer Mask: Environment

Character Renderer → Light A
Environment Renderer → Light B
```

GameObject Layer와 Rendering Layer는 목적이 다르다.

Camera Culling Mask는 GameObject Layer를 사용하고 Light 영향 Filtering은 Rendering Layer를 사용할 수 있다.

Custom Shader는 Light의 `layerMask`와 Mesh Rendering Layer를 올바르게 비교해야 한다.

---

## Forward Material의 Rendering Layer 확인

Additional Light Loop에서 모든 Light를 무조건 더하면 Rendering Layer 규칙을 무시할 수 있다.

개념적으로 다음 조건이 필요하다.

```hlsl
if (IsMatchingLightLayer(
        light.layerMask,
        meshRenderingLayers))
{
    color += EvaluateLight(light, surface);
}
```

정확한 Helper와 Data 접근 방식은 설치된 URP Package를 기준으로 확인한다.

Pipeline의 Lit Shader Source는 Custom Forward Shader 구현의 중요한 Reference다.

---

## Forward Material이 여러 Pass를 가질 수 있다

Object당 Forward Lighting Pass가 하나라는 말은 Shader 전체 Pass가 하나라는 뜻이 아니다.

```text
URP Lit Shader Pass 예
├─ ShadowCaster
├─ DepthOnly
├─ DepthNormals
├─ UniversalForward
├─ Meta
└─ SceneSelectionPass
```

Camera 설정에 따라 같은 Object가 Shadow, Depth와 Color Pass에서 여러 번 그려질 수 있다.

`Object당 Rendering Pass 1`이라는 공식 비교는 주요 Geometry Lighting 경로를 비교하는 맥락이다.

Frame 전체 Draw 횟수로 오해하면 안 된다.

---

## ShadowCaster Pass

Forward Color Pass와 ShadowCaster Pass는 목적이 다르다.

```text
ShadowCaster
├─ Light 관점 Position
├─ Alpha Clip
└─ Depth 출력

UniversalForward
├─ Camera 관점 Position
├─ Material
├─ Lighting
└─ Color 출력
```

Custom Shader에 ShadowCaster Pass가 없으면 Object가 Lighting은 받아도 다른 Surface에 Shadow를 만들지 못할 수 있다.

Alpha Clip Threshold도 Color와 Shadow Pass에서 일치해야 한다.

---

## DepthOnly Pass

Depth Prepass나 Camera Depth 생성에는 `DepthOnly` Pass가 사용될 수 있다.

```shaderlab
Pass
{
    Name "DepthOnly"
    Tags { "LightMode" = "DepthOnly" }

    ColorMask 0
    ZWrite On
}
```

ColorMask를 끄고 Depth만 기록하는 개념이다.

Alpha Clipping Material은 DepthOnly에서도 같은 Clip을 수행해야 한다.

그렇지 않으면 보이지 않는 영역이 Depth를 막아 Effect와 다른 Object가 잘못 가려질 수 있다.

---

## DepthNormals Pass

SSAO나 Screen-space Effect가 Normal을 요구하면 `DepthNormalsOnly` 계열 Pass가 필요할 수 있다.

```text
DepthNormals Pass
├─ Depth
└─ Encoded Normal
        │
        ▼
SSAO / Custom Edge Effect
```

Forward Color에서 이미 정확한 Normal을 사용하더라도 Screen-space Effect가 나중에 읽을 별도 Normal Texture가 필요할 수 있다.

이 Pass가 추가되면 Geometry Processing과 Texture Bandwidth가 증가한다.

---

## Meta Pass

Meta Pass는 Runtime Camera Forward Rendering용 Color Pass가 아니다.

Lightmapping 과정에서 Material의 Albedo와 Emission 정보를 추출하는 데 사용된다.

```text
Material
  │ Meta Pass
  ▼
Lightmapper가 사용할 Surface Data
```

Custom Lit Shader가 화면에서는 정상인데 Baked Lighting 결과가 이상하다면 Meta Pass 지원을 확인한다.

Rendering Pipeline은 Runtime Pass뿐 아니라 Bake와 Editor Workflow도 포함한다.

---

## Forward의 장점

### 단순하고 직접적인 Lighting 흐름

Material Shader가 Geometry Draw 시점에 Lighting과 최종 Color를 계산한다.

### 적은 Light에서 효율적

Object에 영향을 주는 Light가 적으면 Light Loop가 짧다.

### MSAA 지원

Geometry Edge 품질을 위한 Hardware MSAA를 사용할 수 있다.

### Transparent와 일관된 Material Lighting

Opaque와 Transparent 모두 Forward 방식으로 Material을 평가하기 자연스럽다.

### 다양한 Material Model

고정된 G-buffer Layout에 모든 Surface를 맞추지 않고 Custom Lighting을 구성할 수 있다.

### Mobile 친화적인 선택 가능성

G-buffer가 필수인 구조보다 Render Target과 Bandwidth 요구를 낮출 가능성이 있다.

---

## Forward의 한계

### Object별 Light 제한

한 Object에 많은 Light가 겹치면 일부 Light 기여가 제외될 수 있다.

### Light Loop 반복

많은 Pixel에서 여러 Light의 BRDF를 반복 계산한다.

### 큰 Mesh의 Light 선택 문제

넓은 Bounds가 많은 Light와 겹치면 제한이 쉽게 드러난다.

### Screen-space Lighting 재사용이 어려움

같은 Pixel의 Geometry Surface Data를 분리해 Light별로 처리하는 구조가 아니다.

### Material Variant 증가 가능성

Light, Shadow와 Material Feature 조합에 따라 Shader Variant가 늘 수 있다.

이 한계가 모든 Project에서 문제가 되는 것은 아니다.

Scene의 Light 밀도와 Hardware를 기준으로 판단한다.

---

## Forward가 적합한 Scene

다음 조건에서는 일반 Forward가 좋은 출발점이 된다.

- Scene의 Realtime Light가 많지 않다.
- 한 Object에 겹치는 Light 수가 제한적이다.
- Mobile 또는 저사양 Hardware가 중요하다.
- MSAA가 필요하다.
- Transparent Material 비중이 높다.
- Custom Material Lighting의 유연성이 중요하다.
- Baked Lighting을 적극적으로 사용한다.

```text
적은 Dynamic Light
+ 제한된 Per-object Light Overlap
+ Mobile / Low-end Target
+ MSAA 요구
        │
        ▼
일반 Forward 후보
```

---

## Forward가 불리할 수 있는 Scene

다음 조건에서는 일반 Forward의 Light 제한과 Shader Cost를 확인해야 한다.

- 좁은 공간에 많은 Point와 Spot Light가 겹친다.
- 큰 Mesh에 여러 Local Light가 영향을 준다.
- Object마다 많은 Realtime Light가 필요하다.
- Light 기여가 Limit 전환 때문에 Pop한다.
- 수십 개 Light를 Pixel 단위로 정확히 처리해야 한다.

```text
Dense Local Lights
        │
        ├─ Per Object Limit 문제
        └─ Fragment Light Loop 증가
```

Baked Lighting, Mesh 분할, Light Range 조정 또는 다른 Rendering Path를 비교할 수 있다.

---

## Draw Call을 해석하는 방법

Forward에서 Light를 추가했는데 Draw Call이 늘지 않을 수 있다.

Additional Light Loop가 같은 Pass 안에서 실행되기 때문이다.

```text
Light 1개
Draw Call: 1
Fragment Light 평가: 적음

Light 5개
Draw Call: 1일 수 있음
Fragment Light 평가: 많음
```

Draw Call이 같다는 이유로 성능이 같다고 판단하면 안 된다.

GPU Profiler와 Shader 분석 도구로 Fragment Cost를 확인한다.

Shadow를 켜면 별도 Shadow Caster Draw는 증가할 수 있다.

---

## Overdraw를 해석하는 방법

Forward Shader는 Pixel이 그려질 때 Lighting을 계산한다.

같은 Pixel이 여러 번 덮이면 이전 Lighting 계산이 최종 화면에서 사라질 수 있다.

```text
Near Opaque Fragment
        ↑ 최종 표시

Far Opaque Fragment
        ↑ 먼저 계산했지만 가려짐
```

Front-to-back Sorting과 Early Depth Test는 불필요한 Fragment 실행을 줄일 수 있다.

Transparent는 Blend 때문에 Overdraw를 피하기 더 어렵다.

큰 Full-screen Transparent Particle과 복잡한 Forward Shader 조합은 특히 비용이 크다.

---

## Early Depth Test

Depth Buffer에 더 가까운 Surface가 이미 기록되어 있으면 가려진 Fragment를 Shader 실행 전에 제거할 수 있다.

```text
Depth Test
├─ Fail → Fragment Shader 생략 가능
└─ Pass → Forward Lighting 실행
```

GPU와 Shader 조건에 따라 Early-Z 적용 범위가 달라진다.

Depth를 수정하거나 일부 Discard·UAV 동작을 사용하는 Shader는 최적화를 제한할 수 있다.

Opaque Sorting과 Depth Prepass의 효과를 실제 GPU Capture로 확인한다.

---

## Forward 최적화 기준

Forward를 최적화할 때 다음 순서로 비용을 나눠 본다.

```text
1. Camera와 Culling
2. Shadow Pass
3. Opaque Draw
4. Additional Light Loop
5. Transparent Overdraw
6. Post-processing
7. Copy와 Resolve
```

Light 수만 줄여도 Shadow와 Fragment 양쪽 비용이 줄 수 있다.

반대로 CPU Draw 제출이 병목이면 Material과 Batching을 먼저 봐야 한다.

병목 계층을 측정한 뒤 설정을 바꾼다.

---

## Additional Light 최적화

일반 Forward의 Additional Light 비용을 줄이는 방법은 다음과 같다.

- Per Object Limit을 필요한 최소값으로 낮춘다.
- Light Range를 실제 영향 범위에 맞춘다.
- 중요하지 않은 Light의 Shadow를 끈다.
- Static Lighting을 Bake한다.
- Per Vertex Lighting 품질을 Test한다.
- 큰 Mesh의 Bounds와 분할을 검토한다.
- 겹치는 Light 수를 Debug View로 확인한다.

```text
Light Range 감소
→ 겹치는 Object 감소
→ Object Light List 후보 감소
→ Fragment Light Loop 감소 가능
```

화면 결과를 보면서 Light Pop과 품질 저하를 함께 확인한다.

---

## Shadow 최적화

Shadow는 Forward Color Pass 외부와 내부에 비용을 만든다.

```text
외부 비용
└─ Shadow Map에 Caster Drawing

내부 비용
└─ Forward Fragment의 Shadow Sampling
```

다음 설정을 단계적으로 조정한다.

- Main Light Shadow Distance
- Cascade Count
- Shadow Atlas Resolution
- Additional Light Shadow Atlas
- Light별 Shadow Resolution Tier
- Soft Shadow Quality
- Shadow를 만드는 Light 수

Target Camera에서 보이지 않는 먼 Shadow까지 계산하지 않는다.

---

## Shader 최적화

Custom Forward Shader에서는 Light마다 반복되는 Code를 특히 주의한다.

```text
Loop 밖으로 이동 가능한 계산
├─ Material 공통 값
├─ 정규화된 View Direction 일부
└─ Light와 무관한 Texture Sample

Light마다 필요한 계산
├─ NdotL
├─ Half Vector
├─ Attenuation
└─ Light Color
```

Light와 무관한 값을 Loop 안에서 반복하지 않는다.

Precision을 `half`로 낮출 수 있는지 Mobile Target에서 검증한다.

Keyword 분기를 줄일 때 Variant 수와 Runtime Branch Cost의 Trade-off를 고려한다.

---

## Material과 Texture 최적화

Forward Fragment는 Material Texture를 Sampling하고 Light Loop를 실행한다.

```text
Fragment Cost
= Base Map Sample
+ Normal Map Sample
+ Mask Map Sample
+ Reflection Sample
+ Light Loop
+ Shadow Sample
```

화면을 작게 차지하는 Material에 고비용 Feature가 필요한지 검토한다.

Normal Map, Detail Map과 Clear Coat를 Quality Tier별로 조절할 수 있다.

Texture 압축과 Mipmap도 Bandwidth와 Cache 효율에 영향을 준다.

---

## Render Scale과 Forward Cost

Render Scale을 낮추면 Camera Color의 Pixel 수가 줄어든다.

```text
Render Scale 1.0
1920 × 1080 ≈ 2.07M Pixel

Render Scale 0.75
1440 × 810 ≈ 1.17M Pixel
```

Forward Fragment Lighting, Transparent와 Post-processing의 Pixel 비용을 줄일 수 있다.

Geometry Vertex, Culling과 Shadow Atlas 비용은 같은 비율로 줄지 않을 수 있다.

Upscaling Filter의 Quality와 UI Resolution을 함께 확인한다.

---

## Light Complexity Debug

Rendering Debugger의 Lighting Complexity 계열 View는 화면 영역에 영향을 주는 Light 수를 파악하는 데 도움을 준다.

```text
낮은 Light Overlap
→ 단순한 색

높은 Light Overlap
→ 복잡도가 높은 색
```

일반 Forward는 Object별 목록을 사용하므로 화면 Tile View만으로 최종 Object Limit 문제를 모두 설명하지 못할 수 있다.

Frame Debugger, Scene Light Gizmo와 Profiler 결과를 함께 본다.

---

## Frame Debugger에서 확인할 항목

Forward Rendering을 진단할 때 다음 Event를 확인한다.

- Main과 Additional Shadow Pass
- Depth 또는 DepthNormals Prepass
- `DrawOpaqueObjects`
- 사용된 Shader Pass와 `LightMode`
- Opaque Texture와 Depth Copy
- `DrawTransparentObjects`
- Renderer Feature Pass
- Post-processing과 Final Blit

```text
Draw 선택
→ Shader Properties
→ Keywords
→ Mesh
→ Pass Name
→ Render Target
```

Object가 어떤 Forward Pass와 Variant로 그려졌는지 확인한다.

---

## Profiler에서 확인할 항목

CPU와 GPU 비용을 분리한다.

```text
CPU 후보
├─ Culling
├─ Light List 구성
├─ Draw 준비
├─ SRP Batcher
└─ Render Thread

GPU 후보
├─ Shadow
├─ Vertex Shader
├─ Forward Fragment Light Loop
├─ Overdraw
├─ MSAA
└─ Post-processing
```

Light 수를 바꿨을 때 GPU Opaque Pass가 변하는지 확인한다.

Draw Call은 같지만 GPU Time만 증가한다면 Fragment Light Loop가 원인일 수 있다.

---

## Forward Shader가 검게 보일 때

Custom Shader의 Lighting 결과가 검다면 다음 순서로 확인한다.

1. SubShader에 `RenderPipeline = UniversalPipeline` Tag가 있는가?
2. Pass의 `LightMode`가 `UniversalForward` 계열인가?
3. URP Lighting Library를 올바르게 Include했는가?
4. Normal과 Light Direction이 같은 Coordinate Space인가?
5. Normal이 Normalize되어 있는가?
6. Main Light Keyword와 Shadow Variant가 존재하는가?
7. Base Color와 Texture가 Linear·sRGB 기준에 맞는가?
8. Camera가 올바른 Renderer를 사용하는가?

```text
Pass 선택 문제
≠ Lighting 수식 문제
```

Frame Debugger에서 Draw 자체가 있는지 먼저 확인한다.

---

## Additional Light가 보이지 않을 때

다음 설정을 확인한다.

- URP Asset의 Additional Lights가 Disabled인가?
- Per Vertex 또는 Per Pixel Mode가 무엇인가?
- Per Object Limit이 너무 낮은가?
- Light Range가 Object Bounds에 닿는가?
- Culling Mask와 Rendering Layer가 맞는가?
- Custom Shader에 Additional Light Variant가 있는가?
- `GetAdditionalLightsCount()` Loop를 구현했는가?
- 다른 Light가 제한된 목록을 차지하고 있는가?

```text
Scene에 Light 존재
→ Camera Visible
→ Object List에 선택
→ Shader Variant 지원
→ Light Loop 실행
```

각 단계를 분리해 확인한다.

---

## Light가 갑자기 바뀔 때

Object가 이동할 때 Light가 Pop하면 Per Object Limit 전환을 의심할 수 있다.

```text
Frame A Object Light List
L1, L2, L3, L4

Frame B Object Light List
L1, L2, L3, L5
             ↑ 교체
```

Light Range를 겹치지 않게 다듬거나 Limit을 늘리고 비용을 측정한다.

큰 Mesh를 합리적인 Chunk로 나누는 것도 방법이다.

Baked Lighting으로 중요도가 낮은 Realtime Light를 제거할 수 있다.

---

## Shadow가 없을 때

Object가 Light는 받지만 Shadow를 만들거나 받지 못하면 Pass와 설정을 나눠 확인한다.

```text
Shadow Cast
├─ Light Cast Shadows
├─ Renderer Cast Shadows
├─ ShadowCaster Pass
└─ Culling / Distance

Shadow Receive
├─ Material Receive Shadows
├─ Shadow Keyword
├─ Shadow Coordinate
└─ Sampling
```

Cast와 Receive는 서로 독립적인 문제다.

Shadow Atlas를 Frame Debugger에서 확인하면 Caster Rendering 여부를 알 수 있다.

---

## MSAA가 적용되지 않을 때

다음 조건을 확인한다.

- URP Asset의 MSAA Sample Count
- Camera의 Allow MSAA
- Target Platform 지원
- Renderer와 Rendering Path
- Intermediate Texture Format
- Dynamic Resolution과 Upscaler
- Post-processing Anti-aliasing 설정

```text
URP Asset 허용
AND Camera 허용
AND Render Target 지원
→ MSAA 경로 가능
```

Frame Debugger와 GPU Capture에서 Color·Depth Target의 Sample Count를 확인한다.

---

## 일반 Forward와 Built-in Forward의 차이

이름은 같지만 Light를 처리하는 구현이 다르다.

```text
Built-in Forward
├─ ForwardBase
└─ Additional Per-pixel Light마다 ForwardAdd 가능

URP Forward
└─ 하나의 Forward Pass 내부 Light Loop
```

Built-in Shader의 `ForwardBase`와 `ForwardAdd`를 URP에 그대로 옮길 수 없다.

URP의 LightMode, Shader Library와 Light Data Contract에 맞춰야 한다.

두 Pipeline의 Draw Call 특성을 같은 공식으로 계산하면 안 된다.

---

## 일반 Forward와 Forward+의 경계

두 방식 모두 Geometry를 그릴 때 Lighting을 계산한다.

차이는 Light를 선별해 Shader에 제공하는 방식에 있다.

```text
일반 Forward
└─ Object별 제한된 Light List

Forward+
└─ Screen Tile / Depth 구간 기반 Light Culling
```

일반 Forward의 Object별 Limit은 비용을 제한하지만 많은 Light가 겹치는 Scene에서 품질 제한이 된다.

Forward+가 이 문제를 어떻게 바꾸는지는 `6-8`에서 별도로 다룬다.

---

## 자주 혼동하는 내용

### Forward는 Object를 Light마다 다시 그리는가?

URP의 일반 Forward는 선택된 Light를 하나의 Geometry Pass 안의 Shader Loop에서 누적한다.

Built-in의 ForwardAdd 구조와 구분해야 한다.

### Forward는 Light 수와 관계없이 비용이 같은가?

아니다.

Draw Pass 수가 같아도 Additional Light Loop와 Shadow Sampling 비용이 증가할 수 있다.

### Per Object Limit은 Camera의 전체 Light 제한인가?

아니다.

Camera에 보이는 Light 중 Object 하나가 계산할 Additional Light 수를 제한한다.

### Per Vertex Lighting은 항상 품질 차이가 없는가?

아니다.

Vertex 밀도가 낮거나 작은 Local Light를 사용하면 보간 오차가 눈에 띌 수 있다.

### Forward는 Depth Prepass를 사용하지 않는가?

아니다.

Depth Texture, SSAO, Renderer Feature와 Renderer 설정에 따라 Depth 또는 DepthNormals Prepass가 추가될 수 있다.

### Forward에서는 Surface당 Shader Pass가 하나뿐인가?

아니다.

ShadowCaster, DepthOnly, DepthNormals, Meta와 Forward Color Pass를 가질 수 있다.

### Forward는 G-buffer를 만들지 않으므로 중간 Texture가 없는가?

아니다.

Camera Texture, Post-processing, Renderer Feature와 Render Scale 때문에 Intermediate Texture가 생길 수 있다.

### Forward는 Mobile에서 항상 가장 빠른가?

아니다.

일반적으로 적합한 후보지만 Scene, Light, Shader, MSAA와 Device GPU를 실제로 측정해야 한다.

### Forward는 Transparent에만 사용하는 방식인가?

아니다.

Opaque와 Transparent 모두 Forward Lighting으로 처리할 수 있다.

### Forward와 Forward+는 같은가?

아니다.

둘 다 Forward Shading 계열이지만 Light Culling과 Object별 Light 제한 방식이 다르다.

---

## 전체 구조 다시 연결하기

URP 일반 Forward의 흐름을 하나로 연결하면 다음과 같다.

```text
Camera Culling
        │
        ▼
Visible Lights
├─ Main Light
└─ Additional Lights
        │
        ▼
Object별 Light 선별
└─ Per Object Limit
        │
        ▼
Shadow Map 준비
        │
        ▼
UniversalForward Pass
├─ Material Data
├─ Main Light BRDF
├─ Additional Light Loop
├─ Shadow Attenuation
├─ Indirect Lighting
├─ Reflection
└─ Fog
        │
        ▼
Camera Color + Depth
        │
        ├─ Opaque
        ├─ Skybox
        └─ Transparent Forward
        │
        ▼
Post-processing과 Final Output
```

Forward의 핵심은 Object를 그리는 Shader 안에서 제한된 Light 목록의 기여를 최종 Color에 직접 누적한다는 점이다.

---

## 정리

Forward Rendering은 Geometry를 그리는 시점에 Material, Light, Shadow와 Reflection을 계산해 Camera Color에 최종 결과를 기록하는 방식이다.

URP의 일반 Forward는 Universal Renderer의 기본 Rendering Path이며 Light가 많지 않거나 Mobile과 저사양 Platform을 목표로 할 때 적합한 후보다.

```text
Object
+ Main Light
+ 제한된 Additional Lights
+ Shadow
+ Indirect Lighting
        │
        ▼
UniversalForward Shader Pass
        │
        ▼
Final Fragment Color
```

URP는 Main Light와 Object에 영향을 주는 Additional Light를 선별하고 `Per Object Limit` 안의 Light를 하나의 Forward Pass 내부 Shader Loop에서 누적한다.

Additional Light마다 Geometry를 다시 그리는 Built-in의 `ForwardAdd` 방식과 달리 URP Forward에서는 Draw Call이 그대로여도 Light Loop의 Fragment 비용이 증가할 수 있다.

Additional Light는 Per Vertex 또는 Per Pixel로 계산할 수 있으며 Per Vertex는 비용을 줄일 가능성이 있지만 낮은 Vertex Density와 작은 Local Light에서 품질 차이가 나타날 수 있다.

Forward는 정확한 Per-pixel Normal, MSAA, Transparent와 유연한 Material Model에 유리하며 Geometry Surface Data용 G-buffer가 필수는 아니다.

Object별 Light 제한, 큰 Mesh의 Light List와 많은 Light가 겹칠 때의 Fragment 반복은 일반 Forward의 주요 제약이다.

Per Object Limit, Light Range, Realtime Shadow, Baked Lighting, Mesh 분할과 Shader Complexity를 조절하고 Frame Debugger와 GPU Profiler로 실제 비용을 측정해야 한다.
