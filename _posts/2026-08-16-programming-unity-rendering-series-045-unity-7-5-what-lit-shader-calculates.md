---
title: "[Unity 렌더링] 7-5. Unity의 Lit Shader는 무엇을 계산할까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - Shader
  - Lighting
  - URPLit
permalink: /programming/unity-7-5-what-lit-shader-calculates/
toc: true
toc_sticky: true
date: 2026-08-16
last_modified_at: 2026-08-16
---

Unity URP의 Lit Shader는 Material Texture를 화면에 단순히 출력하는 Shader가 아니다.

Base Color, Metallic, Smoothness와 Normal 같은 Surface 정보를 읽고 현재 Camera, Light, Shadow와 Environment 정보를 결합해 최종 Pixel Color를 계산한다.

```text
Material Properties
        │
        ▼
   SurfaceData
        │
        ├──── Geometry / Camera ──── InputData
        │
        ▼
 Physically Based Lighting
        │
        ├─ Direct Light
        ├─ Indirect Light
        ├─ Reflection
        ├─ AO
        └─ Emission
        │
        ▼
     Final Color
```

Lit Shader의 핵심은 Material이 가진 성질과 Fragment가 Scene 안에서 놓인 상황을 분리한 뒤 PBR Lighting 단계에서 합치는 것이다.

---

## Lit Shader란?

Lit은 Light에 반응하는 Material을 위한 URP의 기본 PBR Shader다.

```text
Universal Render Pipeline/Lit
```

같은 Mesh와 Texture라도 Light Direction, Camera Position, Shadow와 Reflection Environment에 따라 결과가 달라진다.

```text
Unlit
Texture Color ──────────────▶ Output

Lit
Texture + Normal + Material
       + Light + View + GI ─▶ Output
```

URP의 Lit은 Physically Based Shading을 사용하며 Simple Lit은 더 단순한 Lighting Model을 사용한다.

Lit은 현실적인 Material과 Environment Reflection이 중요할 때 적합하고 Simple Lit은 단순한 재질과 낮은 성능 예산에 유리할 수 있다.

---

## Lit Shader는 하나의 계산만 하는가?

Lit이라는 하나의 Shader Asset 안에는 목적이 다른 여러 Pass가 포함될 수 있다.

```text
Lit Shader
├─ ForwardLit / UniversalForward
├─ GBuffer / UniversalGBuffer
├─ ShadowCaster
├─ DepthOnly
├─ DepthNormals
├─ Meta
└─ MotionVectors 등
```

Pipeline 설정과 Material Option, Unity와 URP Package Version에 따라 실제 Pass 구성은 달라질 수 있다.

| Pass | 주요 역할 |
| --- | --- |
| Forward Lit | Surface와 Light를 결합해 Color 출력 |
| GBuffer | Deferred Lighting에 필요한 Material Data 기록 |
| ShadowCaster | Light 관점 Depth를 Shadow Map에 기록 |
| DepthOnly | Camera Depth Texture 또는 Prepass용 Depth 기록 |
| DepthNormals | Depth와 Normal Data 기록 |
| Meta | Lightmap Baking에 필요한 Albedo와 Emission 제공 |
| Motion Vectors | 이전 Frame과 현재 Frame의 화면 이동 기록 |

Lit Material이 화면에 한 번 보인다고 GPU에서 항상 한 Pass만 실행되는 것은 아니다.

Camera와 Renderer Feature가 요구하는 Texture에 따라 Depth, Shadow와 Motion Vector Pass가 추가될 수 있다.

---

## Rendering Path에 따라 무엇이 달라질까?

Lit Material은 URP Renderer의 Rendering Path에 따라 Lighting 계산 위치가 달라진다.

### Forward

각 Object의 Lit Fragment Shader에서 영향을 주는 Light를 순회하고 최종 Color를 직접 계산한다.

```text
Surface Data + Light Loop
          │
          ▼
      Final Color
```

### Forward+

화면과 Depth 영역에 맞게 Light를 분류하고 Fragment에서 해당 영역의 Light를 읽는다.

Material의 PBR 계산은 여전히 Lit Fragment 흐름에서 실행된다.

### Deferred

먼저 Surface Material Data를 G-buffer에 기록한 뒤 별도의 Lighting Pass에서 Light를 적용한다.

```text
Geometry Pass           Lighting Pass
Surface Data ─▶ G-buffer ─▶ Light ─▶ Color
```

따라서 `Lit Shader가 최종 Color를 계산한다`는 설명은 Forward Pass를 기준으로 가장 직접적이다.

Deferred에서는 Lit의 Geometry Pass와 Pipeline의 Deferred Lighting을 함께 봐야 한다.

---

## 전체 Forward Lit 처리 흐름

Forward Lit Pass를 크게 나누면 다음과 같다.

```text
Mesh Vertex
   │
   ▼
Vertex Shader
├─ Clip Position
├─ World Position
├─ World Normal / Tangent
├─ UV
├─ Fog / Vertex Light
└─ Lightmap UV 또는 SH Data
   │
   ▼
Rasterization / Interpolation
   │
   ▼
Fragment Shader
├─ Texture Sample
├─ SurfaceData 구성
├─ InputData 구성
├─ BRDFData 초기화
├─ Main Light
├─ Additional Lights
├─ GI / Reflection / AO
├─ Emission
└─ Fog / Alpha 처리
   │
   ▼
Render Target Color
```

각 단계가 Material 정보와 Scene 정보를 조금씩 준비한다.

---

## Vertex Shader는 무엇을 준비할까?

Mesh의 Position, Normal, Tangent와 UV는 Object Space Data로 들어온다.

```hlsl
struct Attributes
{
    float4 positionOS : POSITION;
    half3 normalOS    : NORMAL;
    half4 tangentOS   : TANGENT;
    float2 texcoord   : TEXCOORD0;
    float2 lightmapUV : TEXCOORD1;
};
```

Vertex Shader는 Rendering과 Lighting에 필요한 Coordinate Space로 변환한다.

```hlsl
VertexPositionInputs positionInputs =
    GetVertexPositionInputs(input.positionOS.xyz);

VertexNormalInputs normalInputs =
    GetVertexNormalInputs(input.normalOS, input.tangentOS);
```

개념적인 출력은 다음과 같다.

```hlsl
output.positionCS = positionInputs.positionCS;
output.positionWS = positionInputs.positionWS;
output.normalWS   = normalInputs.normalWS;
output.tangentWS  = half4(normalInputs.tangentWS, tangentSign);
output.uv         = TRANSFORM_TEX(input.texcoord, _BaseMap);
```

Clip Space Position은 Rasterization에 필요하고 World Position과 World Normal은 Lighting에 필요하다.

---

## 왜 모든 계산을 Vertex에서 끝내지 않을까?

Base Map과 Normal Map은 보통 Fragment마다 Sample한다.

Point Light Direction과 View Direction도 Surface Position에 따라 달라진다.

```text
Vertex A ───────── Vertex B
        Fragment마다
       UV / Position / Normal이 다름
```

Vertex에서만 Lighting을 계산하면 좁은 Specular, 작은 Point Light와 Normal Map Detail이 Vertex 사이에서 사라질 수 있다.

Lit은 품질이 필요한 핵심 PBR Lighting을 Fragment 기준으로 처리하고 일부 Vertex Light나 Fog Data는 설정에 따라 Vertex에서 준비할 수 있다.

---

## Interpolator는 비용이 없는가?

Vertex와 Fragment 사이에는 Varying 또는 Interpolator를 통해 Data를 전달한다.

```text
Vertex Output
├─ positionWS
├─ normalWS
├─ tangentWS
├─ uv
├─ lightmapUV / vertexSH
├─ shadowCoord
└─ fogFactor 등
```

많은 기능을 활성화하면 필요한 Interpolator와 Keyword가 늘어난다.

모바일 GPU와 낮은 Shader Model에서는 Interpolator 수가 제약이 될 수 있다.

URP Shader Library는 일부 값을 묶거나 Fragment에서 재구성해 Variant별 요구량을 관리한다.

---

## SurfaceData란?

`SurfaceData`는 Material과 Texture에서 읽은 Surface 자체의 성질을 담는 구조다.

URP Version에 따라 세부 필드는 바뀔 수 있지만 대표 개념은 다음과 같다.

```hlsl
struct SurfaceData
{
    half3 albedo;
    half3 specular;
    half  metallic;
    half  smoothness;
    half3 normalTS;
    half3 emission;
    half  occlusion;
    half  alpha;
    half  clearCoatMask;
    half  clearCoatSmoothness;
};
```

```text
SurfaceData
└─ 이 Fragment의 Material은 어떤 성질인가?
```

World Position, Camera Direction과 Shadow는 Surface 자체의 Texture Property가 아니므로 이 구조의 역할과 구분된다.

---

## SurfaceData는 어떻게 채워질까?

Lit Fragment Shader는 Material Property와 Texture를 Sample해 Surface Data를 만든다.

### Base Color와 Alpha

```hlsl
half4 baseSample = SAMPLE_TEXTURE2D(
    _BaseMap,
    sampler_BaseMap,
    uv);

surfaceData.albedo = baseSample.rgb * _BaseColor.rgb;
surfaceData.alpha  = baseSample.a * _BaseColor.a;
```

### Metallic 또는 Specular

Workflow에 따라 같은 BRDF 입력을 다른 방식으로 제공한다.

```text
Metallic Workflow
├─ Albedo
├─ Metallic
└─ Smoothness

Specular Workflow
├─ Albedo
├─ Specular Color
└─ Smoothness
```

### Normal

```hlsl
surfaceData.normalTS = SampleNormal(
    uv,
    TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap),
    _BumpScale);
```

### Occlusion과 Emission

```hlsl
surfaceData.occlusion = SampleOcclusion(uv);
surfaceData.emission  = SampleEmission(uv, _EmissionColor.rgb);
```

함수명과 인자는 Package Version에 따라 달라질 수 있지만 Texture에서 Surface Attribute를 만드는 목적은 같다.

---

## Alpha Clipping은 언제 처리될까?

Alpha Clipping이 활성화되면 Fragment Alpha가 Threshold보다 낮을 때 Fragment를 버린다.

```hlsl
clip(surfaceData.alpha - _Cutoff);
```

```text
Alpha ≥ Cutoff → Fragment 유지
Alpha < Cutoff → Fragment 폐기
```

풀잎과 철망처럼 경계가 명확한 Cutout Material에 사용한다.

Forward Color Pass뿐 아니라 ShadowCaster와 Depth Pass에서도 같은 Alpha 기준을 사용해야 화면 형태, Shadow와 Depth가 일치한다.

Texture Sample과 `clip`이 여러 Pass에서 반복될 수 있다.

---

## InputData란?

`InputData`는 Fragment가 Scene 안에서 놓인 상황과 Lighting에 필요한 Geometry Data를 담는다.

대표적인 개념은 다음과 같다.

```hlsl
struct InputData
{
    float3 positionWS;
    half3  normalWS;
    half3  viewDirectionWS;
    float4 shadowCoord;
    half   fogCoord;
    half3  vertexLighting;
    half3  bakedGI;
    float2 normalizedScreenSpaceUV;
    half4  shadowMask;
};
```

```text
InputData
└─ 이 Fragment는 Scene에서 어디에 있고 어떤 빛을 받는가?
```

`SurfaceData`와 비교하면 역할이 명확하다.

| 구조 | 질문 | 대표 Data |
| --- | --- | --- |
| `SurfaceData` | 무엇으로 만들어진 Surface인가? | Albedo, Metallic, Smoothness, NormalTS |
| `InputData` | Scene에서 어디에 놓였는가? | PositionWS, NormalWS, View Direction, GI |

---

## World Normal은 어떻게 완성될까?

Normal Map을 사용하지 않으면 보간된 Geometry Normal을 Normalize한다.

Normal Map을 사용하면 Tangent Space Normal을 TBN Basis로 World Space에 옮긴다.

```text
normalTS
   │ Tangent / Bitangent / Normal Basis
   ▼
normalWS
   │ Normalize
   ▼
Lighting Normal
```

```hlsl
half3 bitangentWS =
    input.tangentWS.w * cross(input.normalWS, input.tangentWS.xyz);

half3x3 tangentToWorld = half3x3(
    input.tangentWS.xyz,
    bitangentWS,
    input.normalWS);

inputData.normalWS = normalize(
    TransformTangentToWorld(surfaceData.normalTS, tangentToWorld));
```

이 Normal은 Direct Diffuse, Direct Specular, GI와 Reflection Direction에 모두 사용된다.

---

## View Direction은 어떻게 준비할까?

World Position과 Camera 정보를 이용해 Surface에서 Camera로 향하는 방향을 구한다.

```hlsl
inputData.viewDirectionWS =
    GetWorldSpaceNormalizeViewDir(inputData.positionWS);
```

View Direction은 Fresnel, Specular BRDF와 Environment Reflection에 필요하다.

```text
View Direction
├─ N · V
├─ Half Vector
├─ Fresnel
└─ Reflection Vector
```

URP Helper를 사용하면 Perspective와 Orthographic Projection의 차이를 Pipeline 방식에 맞게 처리할 수 있다.

---

## Shadow Coordinate는 무엇을 위한 값일까?

Main Light Shadow를 Sample하려면 Fragment의 위치를 Light Shadow Space로 연결하는 Coordinate가 필요하다.

```hlsl
inputData.shadowCoord =
    TransformWorldToShadowCoord(inputData.positionWS);
```

Main Light를 얻을 때 Shadow Attenuation이 함께 계산될 수 있다.

```text
World Position
      │
      ▼
Shadow Coordinate
      │ Shadow Map Sample
      ▼
Shadow Attenuation 0~1
```

Receive Shadows가 꺼져 있거나 Shadow Keyword가 없는 Variant에서는 이 경로가 생략되거나 다른 값으로 처리될 수 있다.

---

## Baked GI는 어디에서 올까?

Static Lightmap을 사용하는 Object는 Lightmap UV로 Baked Lighting을 Sample한다.

Lightmap이 없는 Dynamic Object는 Light Probe, SH 또는 APV 계열 Data를 사용할 수 있다.

```text
Baked GI Source
├─ Lightmap
├─ Light Probe / SH
└─ Adaptive Probe Volume
        │
        ▼
   inputData.bakedGI
```

Baked GI는 Surface의 어두운 면을 단순 상수로 밝히는 값이 아니라 Scene에서 Bake 또는 Probe로 얻은 Indirect Diffuse Lighting이다.

Mixed Lighting에서는 Shadow Mask와 함께 Realtime Light와 Baked Data의 중복을 조정할 수 있다.

세부 방식은 뒤의 Baked Lighting, Mixed Lighting과 Light Probe 글에서 이어진다.

---

## BRDFData는 무엇일까?

`SurfaceData`는 Artist가 다루는 Material Parameter에 가깝다.

Lighting 함수는 이를 계산에 편한 BRDF Data로 변환한다.

```text
SurfaceData
├─ Albedo
├─ Metallic / Specular
└─ Smoothness
       │ InitializeBRDFData 계열 처리
       ▼
BRDFData
├─ Diffuse Color
├─ Specular F0
├─ Roughness
├─ Perceptual Roughness
└─ Normalization 관련 값
```

Metallic Workflow에서는 Metallic에 따라 Albedo Energy를 Diffuse와 Specular로 나눈다.

```text
Metallic = 0
├─ Albedo → Diffuse
└─ 비금속 기본 Specular

Metallic = 1
├─ Diffuse → 거의 0
└─ Albedo → Specular Color
```

Smoothness는 BRDF 내부에서 Roughness 계열 값으로 변환된다.

단순히 `1 - smoothness`만 저장하는 것으로 끝나지 않고 Distribution 계산에 맞는 형태가 추가로 준비될 수 있다.

---

## Main Light는 무엇을 계산할까?

Main Light는 일반적으로 가장 중요한 Directional Light다.

URP의 Light Data에는 대표적으로 다음 값이 들어 있다.

```hlsl
struct Light
{
    half3 direction;
    half3 color;
    float distanceAttenuation;
    half shadowAttenuation;
    uint layerMask;
};
```

한 Light의 PBR 기여는 개념적으로 다음과 같다.

```text
Light Contribution
= BRDF(N, L, V, Material)
 × Light Color
 × NdotL
 × Distance Attenuation
 × Shadow Attenuation
```

Main Directional Light는 방향이 Scene 전체에서 같지만 Cascade Shadow와 Shadow Mask 결과는 Fragment 위치에 따라 달라질 수 있다.

---

## Direct Diffuse는 무엇을 계산할까?

Direct Diffuse는 Light가 Surface에 들어와 내부 산란 후 넓게 나오는 성분을 근사한다.

핵심 방향 항은 Lambert에서 다룬 `N·L`이다.

```text
NdotL = max(0, dot(N, L))
```

PBR에서는 Metallic과 Fresnel에 따라 Diffuse에 사용할 Energy가 줄어든다.

```text
Direct Diffuse
= Diffuse BRDF
 × Light Radiance
 × NdotL
 × Attenuation
```

Metallic이 1에 가까운 Surface는 일반적인 Diffuse 기여가 거의 없다.

---

## Direct Specular는 무엇을 계산할까?

URP Lit의 PBR Specular는 단순 Blinn-Phong Power만 사용하는 방식이 아니다.

Microfacet BRDF를 이용해 미세 표면의 반사 분포를 근사한다.

```text
Specular BRDF
├─ Distribution: GGX 계열
├─ Fresnel
└─ Geometry / Visibility
```

```text
Direct Specular
= Specular BRDF
 × Light Radiance
 × NdotL
 × Attenuation
```

Smoothness는 Highlight의 폭을 바꾸고 Metallic 또는 Specular Color는 정면 반사율과 색에 영향을 준다.

View Direction이 필요하므로 Camera가 움직이면 Highlight 위치가 달라진다.

---

## Additional Light는 어떻게 더할까?

Main Light 외의 Point, Spot과 추가 Directional Light가 Surface에 영향을 줄 수 있다.

```text
Total Direct Lighting
= Main Light PBR
 + Additional Light 0 PBR
 + Additional Light 1 PBR
 + ...
```

각 Light마다 Direction, Color, Distance Attenuation, Spot Attenuation과 Shadow를 평가하고 BRDF를 반복한다.

Forward와 Forward+는 Light List를 만드는 방식과 Loop 구조가 다르다.

Lit Shader는 Pipeline이 제공한 Keyword와 Loop를 통해 현재 Fragment에 영향을 주는 Light를 처리한다.

Light 수가 증가하면 Fragment당 Direct Lighting 비용이 증가하는 이유다.

상세한 비용 구조는 다음 실시간 Light 글에서 분리한다.

---

## Vertex Lighting은 어디에 더해질까?

URP Asset에서 Additional Light를 Per Vertex 방식으로 설정하면 일부 Light 기여를 Vertex에서 계산하고 Fragment로 보간할 수 있다.

```text
Vertex Additional Lighting
          │ 보간
          ▼
inputData.vertexLighting
          │
          ▼
Final Diffuse에 결합
```

Fragment Light Loop보다 저렴할 수 있지만 작은 Point Light와 곡면의 변화가 부정확해질 수 있다.

좁은 PBR Specular는 Vertex 보간으로 쉽게 사라지므로 품질 차이가 크다.

---

## Global Illumination은 무엇을 더할까?

Lit Shader의 GI 단계는 Baked GI와 Environment Reflection을 Material BRDF에 맞게 결합한다.

```text
Global Illumination
├─ Indirect Diffuse
│  └─ Lightmap / Probe / APV
└─ Indirect Specular
   └─ Reflection Probe / Skybox
```

Indirect Diffuse는 Diffuse Color와 Normal, Occlusion의 영향을 받는다.

Indirect Specular는 Reflection Vector와 Perceptual Roughness를 이용해 Environment Map을 Sample한다.

```hlsl
half3 reflectVector = reflect(
    -inputData.viewDirectionWS,
    inputData.normalWS);
```

Smooth Surface는 선명한 Mip, Rough Surface는 흐린 Mip을 사용한다.

---

## Reflection Probe는 왜 Lit에 중요할까?

금속은 Diffuse가 거의 없으므로 Environment Reflection이 재질 색과 형태를 드러내는 데 중요하다.

```text
Metal Surface
├─ Direct Specular Highlight
└─ Reflection Probe / Sky Reflection
```

Reflection Probe가 없거나 Environment가 어두우면 Metallic Material이 검게 보일 수 있다.

Lit은 Probe Blending, Box Projection과 Pipeline 설정에 따라 적절한 Reflection Source를 선택할 수 있다.

Probe의 캡처와 갱신 비용은 별도이며 Reflection Probe 글에서 구체적으로 다룬다.

---

## Ambient Occlusion은 어디에 적용될까?

Surface Occlusion Map은 틈과 접촉 영역에 Indirect Light가 덜 도달하는 현상을 근사한다.

Screen Space Ambient Occlusion이 활성화되면 화면 공간 AO도 Direct와 Indirect Factor로 제공될 수 있다.

```text
Material AO
       ×
Screen Space AO
       │
       ▼
Indirect Diffuse / Specular 감소
필요한 경우 Direct Lighting에도 영향
```

정확한 결합 방식은 URP Version과 Renderer Feature 설정에 따라 달라진다.

AO를 Albedo에 강하게 그려 넣으면 Pipeline AO와 중복되어 지나치게 검어질 수 있다.

---

## Emission은 언제 더해질까?

Emission은 외부 Light의 반사가 아니라 Material이 스스로 내는 Color다.

```text
Lighting Result
      +
Emission
      │
      ▼
Final Surface Color
```

Emission은 Shadow 안에서도 보일 수 있고 HDR 값이면 Bloom에 기여할 수 있다.

하지만 Lit Material의 Emission이 밝다고 해서 자동으로 주변 Object를 Realtime으로 밝히는 것은 아니다.

Baked GI 참여 또는 별도 Light가 필요할 수 있다.

---

## Fog는 어디에서 적용될까?

Lighting과 Emission이 결합된 뒤 Camera까지의 거리와 Fog 설정에 따라 Fog Color가 섞인다.

```hlsl
color.rgb = MixFog(color.rgb, inputData.fogCoord);
```

```text
Lit HDR Color
      │ Fog Factor
      ▼
Fog와 혼합된 Color
      │
      ▼
Render Target
```

함수와 적용 위치는 URP Version 및 Pass에 따라 달라질 수 있다.

Fog를 Lighting 전에 Material Albedo에 곱하는 방식과는 결과가 다르다.

---

## Opaque Lit의 최종 Alpha

Opaque Material은 최종적으로 불투명한 Surface로 Render Target에 기록된다.

Base Texture의 Alpha는 Alpha Clipping, Smoothness Source 또는 다른 Material 기능에 사용될 수 있지만 일반적인 Opaque Blending 투명도로 동작하지 않는다.

```text
Opaque
├─ Depth Write 일반적으로 사용
├─ Background와 Alpha Blend하지 않음
└─ Alpha Clip은 선택 가능
```

Opaque와 Transparent는 단순 Alpha 값 차이가 아니라 Render Queue, Depth Write와 Blending 상태가 다르다.

---

## Transparent Lit는 무엇이 다를까?

Transparent Lit도 Surface와 PBR Lighting을 계산하지만 Opaque 이후 별도 Queue에서 Background와 Blend한다.

```text
Lit Surface Color + Alpha
          │ Blending Mode
          ▼
Background Color와 결합
```

Alpha, Premultiply, Additive와 Multiply Mode에 따라 결합식이 달라진다.

Transparent는 보통 Depth Write를 하지 않아 Sorting 문제와 Overdraw가 생기기 쉽다.

Preserve Specular Lighting 옵션은 Alpha가 낮아져도 반사 Highlight를 보존하는 데 사용될 수 있다.

유리처럼 Base 투과와 Surface Reflection이 다른 Material에서 중요하다.

---

## Material Option은 계산을 어떻게 바꿀까?

Lit Inspector의 Option은 단순 UI가 아니라 Render State, Keyword와 Shader Variant를 선택한다.

| 옵션 | 바뀌는 처리 |
| --- | --- |
| Workflow Mode | Metallic 또는 Specular 입력 경로 |
| Surface Type | Opaque/Transparent Queue와 Blending |
| Blending Mode | Framebuffer 결합식 |
| Render Face | Culling State |
| Alpha Clipping | Fragment `clip`과 관련 Pass |
| Receive Shadows | Shadow 수신 경로 |
| Specular Highlights | Direct Specular 계산 |
| Environment Reflections | Indirect Specular Sample |
| GPU Instancing | Instance Data와 Batch 가능성 |

Material Toggle이 많을수록 프로젝트 전체 Shader Variant 수도 늘 수 있다.

사용하지 않는 조합을 관리하는 것이 Build Size와 Shader Warmup에 중요하다.

---

## Specular Highlights를 끄면 무엇이 사라질까?

Specular Highlights Option을 끄면 Directional, Point와 Spot Light가 만드는 Direct Specular Highlight를 생략할 수 있다.

```text
Direct Light
├─ Diffuse 유지
└─ Specular Highlight 제거
```

Matte한 Material이나 저사양 Target에서 비용을 줄이는 선택이 될 수 있다.

Environment Reflections Option은 Reflection Probe와 Skybox 기반 Indirect Specular 경로에 관련된다.

두 Option은 Direct Specular와 Indirect Specular가 서로 다른 계산이라는 점을 보여 준다.

---

## Receive Shadows를 끄면 ShadowCaster도 사라질까?

Receive Shadows는 다른 Object나 자신이 만든 Shadow를 해당 Material의 Lighting에 적용할지 결정한다.

Shadow를 Cast하는지와는 별도 개념이다.

```text
Cast Shadows
└─ 이 Object가 Shadow Map에 기록되는가?

Receive Shadows
└─ 이 Object의 Lighting이 Shadow Map을 Sample하는가?
```

Renderer의 Cast Shadows 설정과 Material의 Receive Shadows를 구분해야 한다.

Receive Shadows를 끄면 화면 Color Pass의 Shadow Sampling과 Variant가 단순해질 수 있지만 ShadowCaster Pass가 자동으로 없어지는 것은 아니다.

---

## Deferred에서는 SurfaceData가 어떻게 쓰일까?

Deferred Geometry Pass는 최종 Light Color 대신 Material과 Geometry 정보를 여러 G-buffer Render Target에 Encode한다.

```text
SurfaceData + Input Geometry
            │
            ▼
G-buffer
├─ Albedo / Material Flags
├─ Specular / Metallic 정보
├─ Normal
└─ Emission / Occlusion 관련 Data
            │
            ▼
Deferred Lighting Pass
```

정확한 Channel Layout은 URP Version과 Rendering Path에 따라 달라질 수 있다.

모든 Lit 기능이 Deferred G-buffer에 동일하게 저장될 수 있는 것은 아니며 일부 Material은 Forward-only Pass로 처리될 수 있다.

---

## ShadowCaster Pass는 Lit Color를 계산할까?

ShadowCaster Pass의 목적은 Light 관점에서 Object의 Depth를 기록하는 것이다.

PBR Diffuse와 Specular Color를 계산할 필요가 없다.

```text
Vertex Transform to Light Clip Space
             │
       Alpha Clip 필요 시 Sample
             │
             ▼
        Shadow Depth 기록
```

Normal Bias를 위한 Normal 정보와 Alpha Clipping Texture는 사용할 수 있다.

Main Color Pass보다 단순하지만 Shadow를 만드는 Light마다 Scene Geometry가 다시 Render될 수 있다.

---

## DepthOnly와 DepthNormals Pass

DepthOnly Pass는 Camera 관점 Depth를 기록한다.

DepthNormals Pass는 Depth와 Normal 정보를 함께 제공한다.

```text
Depth Texture 사용 기능
├─ Soft Particle
├─ Depth 기반 Fog
├─ 일부 Post Processing
└─ Renderer Feature

Depth Normal 사용 기능
├─ SSAO
├─ Edge Detection
└─ Custom Screen-space Effect
```

이 Pass들은 Lit의 최종 PBR Color를 만들지는 않지만 Lit Object가 후속 화면 효과에 올바르게 참여하도록 한다.

---

## Meta Pass는 왜 필요할까?

Meta Pass는 Lightmap Baking 과정에서 Surface의 Albedo와 Emission을 Lightmapper에 전달한다.

```text
Material Base Color / Emission
             │ Meta Pass
             ▼
        Lightmap Baking
```

현재 Camera의 View Direction과 Realtime Specular Highlight를 그대로 Bake하는 Pass가 아니다.

Surface의 광학적 입력을 제공해 간접광과 Emission 기여를 계산하도록 돕는다.

Custom Lit Shader에서 Meta Pass가 빠지면 Baked GI 결과가 기본 Lit과 다를 수 있다.

---

## Lit Shader의 개념적 Fragment Code

실제 URP Source는 Keyword와 Platform 최적화 때문에 더 복잡하지만 흐름을 단순화하면 다음과 같다.

```hlsl
half4 LitFragment(Varyings input) : SV_Target
{
    SurfaceData surfaceData;
    InitializeSurfaceData(input.uv, surfaceData);

    InputData inputData;
    InitializeInputData(input, surfaceData.normalTS, inputData);

    half4 color = UniversalFragmentPBR(
        inputData,
        surfaceData);

    color.rgb = MixFog(color.rgb, inputData.fogCoord);
    color.a = OutputAlpha(color.a);

    return color;
}
```

함수 이름과 Signature는 URP Package Version에 따라 달라질 수 있다.

중요한 관계는 다음 세 단계다.

```text
Material Texture → SurfaceData
Geometry / Scene → InputData
두 Data          → PBR Lighting Result
```

---

## PBR Lighting 함수 내부의 개념적 흐름

```hlsl
half3 lighting = 0.0h;

BRDFData brdfData = InitializeBRDF(surfaceData);

lighting += EvaluateGlobalIllumination(
    brdfData,
    inputData,
    surfaceData.occlusion);

Light mainLight = GetMainLight(inputData.shadowCoord);
lighting += EvaluateDirectPBR(
    brdfData,
    mainLight,
    inputData.normalWS,
    inputData.viewDirectionWS);

for (각 Additional Light)
{
    lighting += EvaluateDirectPBR(...);
}

lighting += inputData.vertexLighting * brdfData.diffuse;
lighting += surfaceData.emission;
```

이 코드는 이해를 위한 의사 코드이며 실제 URP 구현을 그대로 복사한 것이 아니다.

실제 Source는 Rendering Layer, Light Cookie, Shadow Mask, SSAO, Debug Display와 Clear Coat 같은 기능을 조건부로 처리한다.

---

## Shader Keyword와 Variant

Lit은 하나의 고정된 GPU Program이 아니라 기능 조합에 맞춰 Compile된 여러 Variant 중 하나를 사용한다.

```text
Variant 조건 예시
├─ Main Light Shadows
├─ Shadow Cascades
├─ Additional Lights Vertex / Pixel
├─ Additional Light Shadows
├─ Lightmap
├─ Shadow Mask
├─ Normal Map
├─ Alpha Test
├─ SSAO
├─ Reflection Probe Blending
└─ Forward+
```

Runtime에서 현재 Scene과 Material Keyword에 맞는 Variant가 선택된다.

Variant가 많아지면 Build Size, Compile Time와 첫 사용 시 Shader 준비 비용이 커질 수 있다.

모든 Material이 모든 기능을 실제 실행하는 것은 아니며 Preprocessor로 제외된 경로는 GPU Program에 들어가지 않을 수 있다.

---

## SRP Batcher와 Material Data

Lit Material Property는 Unity Per Material Constant Buffer와 Texture Binding으로 GPU에 전달된다.

SRP Batcher는 호환되는 Shader가 같은 구조의 Constant Buffer를 사용하도록 하여 Draw 준비 비용을 줄이는 데 도움을 준다.

```text
CPU
├─ Object Transform Data
├─ Material Constant Data
└─ Draw Command
        │
        ▼
GPU Lit Shader
```

SRP Batcher는 Fragment PBR 계산 자체를 제거하는 기능이 아니다.

CPU의 Render State와 Constant Buffer 준비 비용을 줄이는 방향이며 GPU의 Texture Sample과 Light Loop는 여전히 실행된다.

---

## Lit Shader를 디버깅하는 순서

최종 결과가 이상하면 Data 준비와 Lighting 결합을 단계별로 분리한다.

```text
1. Base Color / Alpha
2. Metallic 또는 Specular
3. Smoothness
4. Tangent Space Normal
5. World Space Normal
6. Baked GI
7. Main Light Diffuse
8. Main Light Specular
9. Additional Lights
10. Environment Reflection
11. AO
12. Emission과 Fog
```

Material Inspector Toggle과 URP Asset 설정도 함께 확인한다.

Frame Debugger로 실행된 Pass, Light와 Render Target을 보고 RenderDoc 같은 GPU Capture로 Texture, Buffer와 Shader Variant를 확인할 수 있다.

---

## 자주 생기는 문제

### Lit Material이 검게 보인다

Base Color만 문제가 아닐 수 있다.

Main Light, Baked GI, Reflection Probe, Metallic 값, Exposure와 Normal 방향을 분리해 확인한다.

금속은 Environment Reflection이 없으면 특히 검게 보인다.

### Normal Map을 넣으면 Light가 반대로 움직인다

Texture Type, Y 방향, Tangent와 TBN 변환이 잘못됐을 수 있다.

Unity가 기대하는 Normal Map Import 설정을 사용한다.

### Shadow가 화면 형태와 맞지 않는다

Color Pass와 ShadowCaster Pass의 Alpha Clipping Keyword, Texture와 Cutoff가 일치하는지 확인한다.

Renderer의 Cast Shadows와 Material의 Receive Shadows도 구분한다.

### Smoothness가 적용되지 않는다

Smoothness Source가 Metallic Alpha인지 Albedo Alpha인지 확인한다.

Texture Alpha Channel, Import Compression과 Material Slider가 Sample 값에 곱해지는지도 확인한다.

### Transparent Material의 Highlight가 사라진다

Blending Mode와 Preserve Specular Lighting 설정을 확인한다.

Base Alpha와 Specular Reflection을 같은 방식으로 줄이면 유리 같은 재질이 부자연스러울 수 있다.

### Scene View와 Game View가 다르다

Camera Renderer, Post Processing, HDR, Exposure, Scene Lighting Toggle과 Quality Level의 URP Asset이 다를 수 있다.

Material만 비교하기 전에 Rendering Context를 맞춘다.

---

## Lit Shader의 성능 비용

Lit의 비용은 Shader 이름 하나가 아니라 활성화된 기능과 Pass 전체에서 발생한다.

```text
CPU Cost
├─ Renderer Culling
├─ Draw / State 준비
├─ Light List 준비
└─ Variant / Resource Binding

GPU Cost
├─ Vertex Transform
├─ Texture Sample
├─ Normal Mapping
├─ PBR BRDF × Light 수
├─ Shadow Sample
├─ GI / Reflection Sample
├─ Overdraw
└─ 추가 Depth / Shadow Pass
```

같은 Lit Shader라도 Opaque 단색 Material과 Transparent Normal-mapped Material의 비용은 크게 다르다.

Material Inspector에서 보이는 기능과 실제 Frame에서 실행되는 Pass를 함께 봐야 한다.

---

## 최적화 관점

### 필요 없는 Material 기능을 끈다

Normal Map, Specular Highlights, Environment Reflections와 Alpha Clipping이 필요하지 않으면 비활성화를 검토한다.

시각적 차이와 실제 GPU 시간을 함께 측정한다.

### Opaque를 우선한다

투명도가 필요 없는 Object는 Opaque로 유지하면 Depth Write와 Early Depth Test를 활용하기 쉽고 Overdraw를 줄일 수 있다.

Cutout이 적합한 풀잎을 부드러운 Transparent로 만드는 선택은 비용과 Sorting 문제를 늘릴 수 있다.

### Light와 Shadow 수를 관리한다

Lit의 Direct BRDF는 영향을 주는 Pixel Light마다 반복된다.

Light Range, Rendering Layer와 Shadow 사용을 필요한 영역으로 제한한다.

### 적절한 Shader를 선택한다

현실적인 PBR이 필요하지 않은 작은 배경 Object는 Simple Lit, Baked Lit 또는 Unlit으로 대체할 수 있다.

Shader를 바꾸면 Specular와 Environment 표현이 달라지므로 Art 목표를 기준으로 선택한다.

### Texture Sample을 관리한다

Detail Map, Normal Map, Emission과 Mask가 늘면 Bandwidth와 Sample 수가 증가한다.

Scalar Map의 Channel Packing과 적절한 Resolution을 사용한다.

### Variant를 정리한다

프로젝트에서 사용하지 않는 URP Feature와 Shader Keyword 조합을 줄인다.

Variant Stripping 결과와 Runtime Shader Warmup 문제를 함께 확인한다.

### Pass 수를 확인한다

Main Color Pass만 Profile하지 말고 ShadowCaster, DepthNormals, Motion Vector와 Renderer Feature Pass를 Frame Debugger에서 확인한다.

Lit Material이 많아질수록 보조 Pass의 Geometry 비용도 커질 수 있다.

---

## 흔한 오해

### Lit은 Texture에 Light Color를 한 번 곱한다

Lit은 Surface Data와 Scene Data를 준비하고 Direct·Indirect Diffuse, Specular, AO, Emission과 Fog를 결합한다.

### Material Inspector의 값이 곧 최종 Pixel 값이다

Metallic과 Smoothness는 BRDF 내부 Data로 변환되고 Light, View와 Environment에 따라 결과가 달라진다.

### Receive Shadows를 끄면 Object가 Shadow를 만들지 않는다

Shadow 수신과 투영은 별도 설정과 Pass다.

### Forward와 Deferred의 Lit은 완전히 같은 GPU 흐름이다

Forward는 Material Pass에서 Light를 결합하고 Deferred는 G-buffer 기록 후 Lighting Pass에서 계산한다.

최종 목표는 유사해도 Pass와 Memory 흐름이 다르다.

### SRP Batcher가 Lit의 PBR 연산을 줄인다

SRP Batcher는 주로 CPU의 Draw 준비와 Material Data Binding을 효율화한다.

Fragment의 BRDF와 Texture Sample은 별도로 실행된다.

### Lit 하나만 사용하면 Material 비용도 모두 같다

Keyword, Texture, Surface Type, Light 수, Shadow와 화면 Coverage에 따라 같은 Lit 안에서도 실제 Variant와 비용이 달라진다.

---

## 전체 계산 흐름

URP Forward Lit의 개념적인 전체 흐름은 다음과 같다.

```text
Mesh Attributes
Position / Normal / Tangent / UV
              │
              ▼
         Vertex Shader
World Position / Normal / Tangent
Clip Position / UV / GI Coordinate
              │
              ▼
   Rasterization / Interpolation
              │
              ▼
        Fragment Shader
              │
      ┌───────┴────────┐
      ▼                ▼
Material Texture    Scene / Geometry
Base / Mask /       PositionWS
Normal / Emission   NormalWS / View
      │                │
      ▼                ▼
 SurfaceData        InputData
      │                │
      └───────┬────────┘
              ▼
          BRDFData
Diffuse / Specular / Roughness
              │
      ┌───────┼───────────────┐
      ▼       ▼               ▼
 Main Light  Additional     Global
 Direct PBR  Light Loop     Illumination
      │       │          GI / Reflection
      └───────┴───────────────┘
              │
              ▼
     AO / Vertex Light 결합
              │
              ▼
          + Emission
              │
              ▼
          Fog / Alpha
              │
              ▼
        Render Target Color
```

Lit Shader를 이해하는 핵심은 `Texture를 읽는 단계`, `Fragment의 Scene 정보를 만드는 단계`, `Lighting을 합치는 단계`와 `보조 Pass`를 분리해서 보는 것이다.

---

## 정리

Unity URP의 Lit Shader는 Material의 Surface Property와 Scene의 Light·Camera·GI 정보를 결합해 PBR Color를 계산한다.

Lit Shader에는 Forward 또는 G-buffer Color 처리뿐 아니라 ShadowCaster, DepthOnly, DepthNormals, Meta와 Motion Vector 같은 여러 목적의 Pass가 포함될 수 있다.

Vertex Shader는 Clip Position, World Position, Normal, Tangent, UV와 GI Coordinate를 준비하고 Rasterizer가 이를 Fragment로 보간한다.

`SurfaceData`는 Albedo, Metallic, Specular, Smoothness, NormalTS, Occlusion, Emission과 Alpha처럼 Material 자체의 성질을 담는다.

`InputData`는 World Position과 Normal, View Direction, Shadow Coordinate, Baked GI와 Screen UV처럼 Fragment의 Scene 상황을 담는다.

Surface Data는 BRDF 계산에 필요한 Diffuse Color, Specular F0와 Roughness 계열 값으로 변환된다.

Main Light와 Additional Light마다 PBR Diffuse·Specular를 계산하고 Distance 및 Shadow Attenuation을 적용한다.

Lightmap·Probe 기반 Indirect Diffuse와 Reflection Probe·Skybox 기반 Indirect Specular가 Global Illumination 단계에서 결합된다.

Ambient Occlusion과 Vertex Lighting을 반영한 뒤 Emission을 더하고 Fog와 Alpha 처리를 거쳐 Render Target Color가 만들어진다.

Forward는 Lit Fragment에서 Light를 직접 순회하고 Deferred는 먼저 G-buffer를 기록한 뒤 별도 Lighting Pass에서 Light를 적용한다.

Material의 Surface Type, Workflow, Alpha Clipping, Receive Shadows와 Specular·Reflection Option은 Render State와 Shader Variant를 바꾼다.

Lit의 비용은 PBR 수식뿐 아니라 Texture Sample, Light 수, Shadow, Reflection, Overdraw와 Shadow·Depth 같은 추가 Pass에서 발생한다.

실제 함수명과 구조체 필드는 URP Package Version에 따라 바뀔 수 있으므로 Custom Shader를 작성할 때는 프로젝트에 설치된 Package Source를 기준으로 확인해야 한다.
