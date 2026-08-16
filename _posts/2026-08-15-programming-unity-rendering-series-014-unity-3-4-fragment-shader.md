---
title: "[Unity 렌더링] 3-4. Fragment Shader는 무엇을 할까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - FragmentShader
  - TextureSampling
  - HLSL
permalink: /programming/unity-3-4-fragment-shader/
toc: true
toc_sticky: true
date: 2026-08-15
last_modified_at: 2026-08-15
---

Rasterizer는 화면에 투영된 Triangle이 덮는 Sample을 판정하고 Fragment를 만든다.

각 Fragment에는 Screen Position, Depth와 Vertex Shader에서 전달된 UV, Normal, Color 같은 보간 데이터가 연결된다.

이 데이터를 이용하여 화면에 기록할 Color와 Material 결과를 계산하는 Programmable Stage가 **Fragment Shader**다.

```text
Rasterization
↓
Fragment와 보간 데이터
↓
Fragment Shader
Texture Sampling, Lighting, Material 계산
↓
Source Color와 기타 출력
↓
Depth / Stencil / Blending
↓
Render Target
```

Fragment Shader를 Pixel의 색상을 정하는 Shader라고 표현할 수 있다.

하지만 Fragment와 Pixel은 같은 개념이 아니며 Shader 출력이 항상 최종 화면에 남는 것도 아니다.

하나의 Pixel 위치에 여러 Fragment가 생성될 수 있고, Fragment Shader 결과는 Depth Test에서 제거되거나 Blending으로 기존 Color와 결합될 수 있다.

---

## Fragment Shader란?

Fragment Shader는 Rasterization이 생성한 Fragment Invocation을 대상으로 실행되는 GPU Program이다.

```text
Fragment 0 → Fragment Shader
Fragment 1 → Fragment Shader
Fragment 2 → Fragment Shader
...
```

각 Invocation은 자신의 보간 Input과 Texture, Material, Camera와 Lighting Resource를 이용해 결과를 계산한다.

일반적인 Fragment Shader Invocation은 다른 Fragment의 Local 변수를 직접 읽지 않고 독립적으로 실행되는 것처럼 작성한다.

GPU는 많은 Fragment Invocation을 그룹으로 묶어 병렬로 처리한다.

이 데이터 병렬성이 실시간 화면의 수많은 Fragment를 처리할 수 있게 한다.

---

## Pixel Shader와 같은 것일까?

Direct3D와 HLSL 문맥에서는 Pixel Shader라는 이름을 자주 사용한다.

OpenGL, Vulkan과 Unity 문서에서는 Fragment Shader라는 표현도 많이 사용한다.

두 용어는 Graphics Pipeline의 같은 Programmable Stage를 가리키는 경우가 많다.

하지만 Fragment를 Pixel과 완전히 같은 데이터라고 이해하면 안 된다.

```text
Pixel
Render Target의 저장 위치

Fragment
Primitive가 해당 위치에 만든 렌더링 후보
```

여러 Fragment가 하나의 Pixel에 경쟁하거나 Blending될 수 있고 MSAA에서는 Sample Coverage도 존재한다.

그래서 이 글에서는 처리 대상을 강조하기 위해 Fragment Shader라고 부른다.

---

## Fragment Shader는 언제 실행될까?

Vertex Shader 이후 Primitive가 구성되고 Rasterization되어 Fragment가 생성된 뒤 Fragment Shader가 실행된다.

```text
Vertex Shader
↓
Primitive Assembly
↓
Clipping / Culling
↓
Rasterization
↓
Early Fragment Test 가능
↓
Fragment Shader
↓
Late Fragment Operations 가능
```

Depth Test가 가능한 경우 Shader보다 먼저 수행되어 가려진 Fragment Invocation을 줄일 수 있다.

반대로 Shader가 Depth를 직접 출력하거나 Fragment를 버리는 동작이 있으면 Test의 시점과 최적화 방식이 달라질 수 있다.

모든 Rasterized Fragment가 반드시 Fragment Shader를 실행하고 모든 실행 결과가 Color Buffer에 기록된다고 단정할 수 없다.

---

## Fragment Shader의 입력

Fragment Shader는 Vertex Shader가 출력한 Varying을 Rasterizer가 보간한 값으로 입력받는다.

```hlsl
struct Varyings
{
    float4 positionCS : SV_POSITION;
    float2 uv         : TEXCOORD0;
    float3 positionWS : TEXCOORD1;
    float3 normalWS   : TEXCOORD2;
    float4 color      : COLOR;
};
```

각 Vertex에만 있던 값이 Triangle 내부 위치에 맞게 보간된다.

```text
Vertex A UV
Vertex B UV
Vertex C UV
↓ Perspective Interpolation
현재 Fragment UV
```

Fragment Shader는 이 UV로 Texture를 Sampling하고 Normal과 World Position으로 Lighting을 계산할 수 있다.

---

## SV_POSITION 입력

Vertex Shader 출력의 `SV_POSITION`은 Rasterization 이후 Fragment Shader에서 현재 Fragment의 화면 위치와 관련된 값으로 전달된다.

```hlsl
float4 positionCS : SV_POSITION;
```

Fragment Stage에서 이 값의 의미는 Vertex Stage에서 출력한 Raw Clip Position과 완전히 같다고 단정하면 안 된다.

Rasterizer의 Perspective Divide와 Viewport Transform을 거친 Window 또는 Pixel 위치와 Depth에 대응한다.

Screen Space Pattern, Dithering과 Pixel 좌표 기반 효과에서 사용할 수 있다.

플랫폼별 좌표 방향과 Dynamic Resolution, XR Viewport를 고려하려면 Unity의 Screen Space Helper를 사용하는 편이 안전하다.

---

## VFACE와 앞뒷면

Fragment Shader는 현재 Fragment를 만든 Primitive가 Front Face인지 Back Face인지 나타내는 값을 받을 수 있다.

Unity HLSL에서는 `VFACE` Semantic을 사용할 수 있다.

```hlsl
half facing : VFACE;
```

양면 Material에서 앞면과 뒷면의 Normal 방향이나 Color를 다르게 처리할 수 있다.

```hlsl
float faceSign = facing > 0 ? 1.0 : -1.0;
normalWS *= faceSign;
```

정확한 값의 부호와 Type은 대상 Graphics API와 Unity Macro Convention을 확인해야 한다.

Cull Back이 활성화되어 뒷면 Primitive가 제거되면 Back Face Fragment 자체가 생성되지 않는다.

---

## 가장 단순한 Fragment Shader

모든 Fragment에 같은 빨간색을 출력하는 Shader는 다음처럼 작성할 수 있다.

```hlsl
half4 frag(Varyings input) : SV_Target
{
    return half4(1.0, 0.0, 0.0, 1.0);
}
```

`SV_Target`은 Fragment Shader 출력이 Color Render Target에 연결된다는 의미다.

```text
R = 1
G = 0
B = 0
A = 1
```

이 출력은 Source Color다.

Blend가 꺼져 있으면 기존 Destination Color를 대체할 수 있고 Blend가 켜져 있으면 Blend State에 따라 결합된다.

---

## Fragment Shader Entry Point

Unity Shader의 HLSL Program Block에서는 Fragment Shader Entry Point를 지정한다.

```hlsl
#pragma fragment frag
```

`frag` 함수의 이름 자체가 특별한 것이 아니라 `#pragma fragment`에서 어떤 함수를 지정했는지가 중요하다.

Vertex Shader의 출력 구조체와 Fragment Shader Input 구조체의 Semantic과 Type이 Pipeline Interface에서 맞아야 한다.

```hlsl
#pragma vertex vert
#pragma fragment frag
```

한 Shader Pass마다 서로 다른 Vertex와 Fragment Entry Point를 사용할 수 있다.

Shadow Pass와 Forward Pass가 다른 Fragment Shader를 사용하는 이유다.

---

## Texture Sampling

Fragment Shader의 대표적인 작업 중 하나는 Texture Sampling이다.

URP에서는 Texture와 Sampler를 선언하고 `SAMPLE_TEXTURE2D` Macro를 사용할 수 있다.

```hlsl
TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);

half4 baseColor = SAMPLE_TEXTURE2D(
    _BaseMap,
    sampler_BaseMap,
    input.uv
);
```

Texture Sampling은 UV가 가리키는 단일 Texel Byte를 그대로 읽는 것보다 복잡할 수 있다.

Filtering, Address Mode, Mipmap Level과 Texture Format이 결과에 영향을 준다.

---

## Texture와 Sampler

Texture는 Image Data를 저장하는 Resource다.

Sampler는 UV를 어떻게 해석하고 주변 Texel을 어떻게 Filter할지를 정의한다.

```text
Texture
Color 또는 다른 데이터

Sampler
Point / Bilinear / Trilinear
Repeat / Clamp
Anisotropic 설정
```

같은 Texture도 다른 Sampler State로 읽으면 가장자리와 축소 결과가 달라질 수 있다.

Unity의 Texture Import와 Render Pipeline Macro가 실제 Sampler 설정을 구성한다.

Texture와 Sampler를 하나의 개념으로만 보면 Filtering과 Resource Binding을 이해하기 어렵다.

---

## Point와 Bilinear Filtering

Point Filtering은 UV에 가장 가까운 Texel 하나를 선택한다.

```text
Point
선명한 Pixel 경계
Pixel Art에 적합할 수 있음
```

Bilinear Filtering은 같은 Mip Level의 주변 Texel을 보간한다.

```text
Bilinear
주변 2×2 Texel 관계를 이용한 보간
부드러운 확대 결과
```

Filtering은 Texture Sample Unit이 처리할 수 있지만 Sample 수와 Format, Cache Hit에 따라 비용이 달라진다.

부드러워 보인다는 이유로 모든 Texture에 같은 Filter가 적합한 것은 아니다.

Normal, Mask, Pixel Art와 Data Texture는 목적에 맞는 Import 설정이 필요하다.

---

## Mipmap Level은 어떻게 선택할까?

Fragment Shader의 Texture Sampling은 인접 Fragment 사이의 UV 변화량을 이용해 화면에서 Texture가 얼마나 축소되는지 추정할 수 있다.

```text
UV가 인접 Pixel에서 크게 변함
↓
Texture가 화면에서 많이 축소됨
↓
더 낮은 해상도의 Mip 선택
```

GPU는 UV Derivative를 이용해 적절한 LOD를 선택할 수 있다.

```hlsl
float2 dx = ddx(input.uv);
float2 dy = ddy(input.uv);
```

일반 `SAMPLE_TEXTURE2D`는 이러한 Implicit Derivative를 사용할 수 있다.

Mipmap은 축소 Texture의 Alias를 줄이고 Cache 효율을 높이는 데 도움이 된다.

---

## Derivative란?

Derivative는 화면 X와 Y 방향으로 값이 얼마나 변하는지를 나타낸다.

HLSL에서는 `ddx`, `ddy`, `fwidth`를 사용할 수 있다.

```hlsl
float changeX = ddx(value);
float changeY = ddy(value);
float width = fwidth(value);
```

GPU는 인접 Fragment Invocation 그룹의 값을 비교하여 Derivative를 계산한다.

Texture LOD 선택 외에도 Procedural Anti-Aliasing, Normal 재구성과 Screen Space Edge 계산에 사용할 수 있다.

조건 분기로 인접 Invocation이 서로 다른 코드를 실행하면 Derivative가 정의되지 않거나 불안정할 수 있다.

Derivative를 사용하는 Texture Sample을 불균일한 분기 안에 둘 때 주의해야 한다.

---

## Helper Invocation

Triangle Edge에서는 Derivative를 계산할 이웃 Fragment가 실제 Coverage 밖에 있을 수 있다.

GPU는 Derivative 그룹을 완성하기 위해 Helper Invocation을 실행할 수 있다.

```text
2×2 Invocation 예시

Covered  Covered
Covered  Helper
```

Helper Invocation은 같은 Fragment Shader 코드를 실행하여 Derivative 계산에 참여하지만 최종 Framebuffer 결과를 기록하지 않는다.

따라서 Covered Sample 수와 실제 Fragment Shader 연산 수가 정확히 같지 않을 수 있다.

작은 Triangle이 많으면 실행 그룹의 많은 Lane이 Helper 또는 비활성 상태가 되어 효율이 낮아질 수 있다.

---

## Material Property

Fragment Shader는 Material마다 설정한 Color, Float, Vector와 Texture를 읽을 수 있다.

URP의 SRP Batcher 호환 Custom Shader에서는 Material Property를 `UnityPerMaterial` Constant Buffer에 선언한다.

```hlsl
CBUFFER_START(UnityPerMaterial)
    half4 _BaseColor;
    float4 _BaseMap_ST;
    half _Smoothness;
CBUFFER_END
```

```hlsl
half4 color = baseMap * _BaseColor;
```

Constant Buffer 값은 많은 Fragment가 공유할 수 있다.

Material이 달라져 Property Layout과 값이 바뀌면 CPU와 GPU Binding 및 Batching에 영향을 줄 수 있다.

---

## Vertex Color와 Texture 결합

Particle과 Mesh Effect에서는 Vertex Color를 Texture와 곱하여 Fragment Color와 Alpha를 조절할 수 있다.

```hlsl
half4 color = SAMPLE_TEXTURE2D(
    _BaseMap,
    sampler_BaseMap,
    input.uv
);

color *= input.color;
```

Vertex Color는 Triangle 내부에서 보간된다.

Particle System은 Particle별 Color와 Lifetime Fade를 Vertex Attribute로 전달할 수 있다.

Texture Sample을 추가하지 않고 저주파 Color와 Mask 변화를 적용할 수 있지만 Vertex 밀도와 보간에 품질이 의존한다.

---

## Lighting 계산

Lit Material의 Fragment Shader는 표면 Normal, Light Direction, View Direction과 Material Property를 이용해 Lighting을 계산한다.

```text
Albedo
Normal
Light Direction
Light Color
View Direction
Metallic / Smoothness
Shadow
```

간단한 Diffuse Lighting은 Normal과 Light Direction의 Dot Product로 빛이 표면을 향하는 정도를 구할 수 있다.

```hlsl
half NdotL = saturate(dot(normalWS, lightDirectionWS));
half3 diffuse = albedo * lightColor * NdotL;
```

URP Lit Shader는 PBR BRDF, Main Light, Additional Light, Shadow, GI와 Reflection 등을 더 복잡하게 처리한다.

---

## Normal은 다시 Normalize해야 한다

Vertex Shader에서 단위 길이 Normal을 출력해도 Rasterizer의 선형 보간 결과는 길이가 1이 아닐 수 있다.

```text
Normal A 길이 1
Normal B 길이 1
↓ 보간
중간 Normal 길이 != 1 가능
```

Fragment Shader에서 Lighting 전에 Normalize해야 한다.

```hlsl
float3 normalWS = normalize(input.normalWS);
```

Normalize를 생략하면 Dot Product와 Lighting 강도가 왜곡될 수 있다.

Normal Map을 적용하는 경우 Tangent Space Normal을 Unpack하고 TBN Basis를 이용해 Lighting Space로 변환한다.

---

## Normal Map Sampling

Normal Map은 표면의 세밀한 방향 변화를 Texture에 저장한다.

```hlsl
half4 packedNormal = SAMPLE_TEXTURE2D(
    _BumpMap,
    sampler_BumpMap,
    input.uv
);
```

Sampling한 값을 올바른 Normal Format으로 Unpack하고 Tangent, Bitangent, Normal Basis로 변환한다.

```text
Normal Map Texel
↓ Unpack
Tangent Space Normal
↓ TBN Transform
World 또는 View Space Normal
```

Normal Map Texture는 일반 Color Texture와 다르므로 sRGB Color 변환과 Compression 설정도 목적에 맞아야 한다.

---

## View Direction

Specular와 Fresnel 같은 효과는 Camera를 향하는 View Direction이 필요하다.

World Position을 전달했다면 Camera World Position과의 차이로 구할 수 있다.

```hlsl
float3 viewDirWS = normalize(
    GetWorldSpaceViewDir(input.positionWS)
);
```

View Direction을 Vertex에서 계산해 보간할 수도 있지만 Normalize와 Perspective, 넓은 Triangle에서의 오차를 고려해야 한다.

Fragment마다 정확한 Direction이 필요한 효과는 World Position으로 재계산할 수 있다.

계산과 Varying 대역폭 사이의 Trade-off가 있다.

---

## Main Light와 Additional Light

URP Forward Rendering에서는 Fragment Shader가 Main Light와 현재 오브젝트에 영향을 주는 Additional Light를 반복하여 계산할 수 있다.

```text
Main Light 계산
+ Additional Light 0
+ Additional Light 1
+ Additional Light 2
...
```

화면을 덮는 Fragment 수와 Pixel별 Light 수가 많으면 Lighting 비용이 크게 증가할 수 있다.

Forward+는 화면 공간의 Light Culling을 이용해 Fragment가 고려할 Light 목록을 줄이는 구조와 연결된다.

Light 수만이 아니라 Shadow Sampling과 BRDF 복잡도도 함께 확인해야 한다.

---

## Shadow Sampling

실시간 Shadow를 적용하려면 Fragment의 World Position을 Light의 Shadow Space로 변환하고 Shadow Map Depth와 비교할 수 있다.

```text
Fragment World Position
↓ Light Shadow Coordinate
Shadow Map Sampling
↓ Depth 비교와 Filtering
Shadow Attenuation
```

PCF 같은 Filtering은 주변 Shadow Texel을 여러 번 Sampling할 수 있다.

Cascade Shadow를 사용하면 Camera Depth에 따라 Cascade를 선택해야 한다.

Shadow가 Fragment Shader에서 비싼 이유는 단순한 곱셈 하나가 아니라 Texture Sampling, 비교와 Filtering이 많은 Fragment에 반복되기 때문이다.

---

## Fragment Shader의 출력

가장 일반적인 출력은 Color Render Target에 기록할 `SV_Target`이다.

```hlsl
half4 frag(Varyings input) : SV_Target
{
    return color;
}
```

MRT를 사용하면 여러 Color Attachment에 서로 다른 값을 출력할 수 있다.

```hlsl
struct FragmentOutput
{
    half4 color0 : SV_Target0;
    half4 color1 : SV_Target1;
};
```

Deferred Rendering의 G-Buffer는 Albedo, Normal, Material Parameter를 여러 Render Target에 기록할 수 있다.

Render Target 수와 Format이 늘면 Memory Bandwidth 사용도 증가한다.

---

## Alpha 출력

Fragment Shader가 `half4` Color를 출력하면 네 번째 성분이 Alpha다.

```hlsl
return half4(rgb, alpha);
```

하지만 Alpha 값이 0.5라는 이유만으로 자동으로 반투명해지는 것은 아니다.

Blend State가 Alpha를 Source Factor로 사용해야 RGB가 Destination과 혼합된다.

```shaderlab
Blend SrcAlpha OneMinusSrcAlpha
```

Opaque Pass에서는 Alpha가 다른 Buffer 목적에 사용되거나 무시될 수 있다.

Shader Output과 Render State를 함께 이해해야 한다.

---

## Depth를 출력할 수 있을까?

Fragment Shader는 특수한 Semantic을 사용하여 Depth 값을 직접 출력할 수 있다.

```hlsl
struct FragmentOutput
{
    half4 color : SV_Target;
    float depth : SV_Depth;
};
```

Ray Marching Impostor와 특수 Geometry Effect에서 계산된 표면 깊이를 기록할 수 있다.

하지만 Shader가 Depth를 변경하면 GPU가 Fragment Shader 전에 최종 Depth Test를 확정하기 어려워 Early-Z 최적화가 제한될 수 있다.

Projection Convention과 Reversed-Z를 올바르게 처리하지 않으면 가시성 결과가 깨진다.

특수한 필요가 없다면 Rasterizer가 계산한 기본 Depth를 사용하는 편이 효율적이다.

---

## clip과 discard

Fragment Shader는 조건에 따라 현재 Fragment를 버릴 수 있다.

HLSL에서는 `clip`을 사용할 수 있다.

```hlsl
clip(alpha - _Cutoff);
```

값이 기준보다 작으면 Fragment가 Color와 Depth에 기여하지 않는다.

```text
Alpha >= Cutoff
Fragment 유지

Alpha < Cutoff
Fragment 제거
```

나뭇잎, 철망과 Hair Card 같은 Alpha Clipping Material에 사용할 수 있다.

---

## 버린 Fragment의 비용은 사라질까?

Fragment Shader 안에서 `clip`에 도달했다는 것은 그 이전 명령이 이미 실행되었을 수 있다는 의미다.

```hlsl
half4 color = ExpensiveTextureAndLighting();
clip(color.a - _Cutoff);
```

이 경우 Fragment를 버려도 비싼 연산 비용은 발생한다.

가능하다면 Alpha 판정에 필요한 최소 데이터만 먼저 읽고 일찍 `clip`한 뒤 나머지 Lighting을 계산하는 편이 유리할 수 있다.

하지만 `clip` 자체가 Early-Z와 실행 그룹 분기에 영향을 줄 수 있으므로 실제 GPU에서 측정해야 한다.

---

## Fragment Shader와 Early-Z

앞쪽 Opaque Geometry의 Depth가 이미 기록되어 있으면 뒤 Fragment는 Shader 실행 전에 제거될 수 있다.

```text
Rasterization
↓ Early Depth Test
가려진 Fragment 제거
↓
Fragment Shader
```

다음과 같은 동작은 Early Test의 적용 방식에 영향을 줄 수 있다.

```text
SV_Depth 출력
clip / discard
UAV와 Storage Buffer Side Effect
특정 Sample Mask 처리
```

현대 GPU는 Conservative Early Test와 Late Test를 조합할 수 있지만 모든 Shader에서 같은 방식으로 동작하지 않는다.

ZWrite와 Draw Order, Shader 동작을 함께 봐야 한다.

---

## Fragment Shader와 Blending

Fragment Shader가 출력한 Color는 Source Color다.

Render Target에 이미 있는 Color는 Destination이다.

```text
Fragment Shader Output
Source
↓
Blend Stage
Source와 Destination 결합
↓
Render Target
```

Blending은 일반적으로 Fragment Shader 코드 뒤의 Fixed-Function Stage에서 수행한다.

Transparent Shader가 Destination Color를 직접 Texture로 Sampling하지 않아도 Blend Unit이 현재 Render Target 값과 결합할 수 있다.

Blend Mode와 Render Target Format은 Shader Code 밖의 Pipeline State다.

---

## Screen Color를 읽는 효과

굴절과 Distortion처럼 뒤의 Scene Color를 Shader 안에서 변형하려면 현재 화면을 Sampling할 수 있는 Texture가 필요하다.

```text
Opaque Scene 렌더링
↓
Scene Color Texture 준비
↓
Transparent Fragment Shader에서 Sampling
↓
왜곡된 UV로 Color 출력
```

URP의 Opaque Texture나 Custom Render Pass가 이런 입력을 제공할 수 있다.

현재 쓰고 있는 Render Target을 같은 위치에서 일반 Texture처럼 바로 읽고 쓰는 것은 API와 하드웨어의 Read-Write Hazard 때문에 제한될 수 있다.

Copy 또는 별도 Attachment, Pipeline 지원 기능이 필요할 수 있다.

---

## Branch와 Divergence

Fragment Shader에도 조건문을 사용할 수 있다.

```hlsl
if (input.mask > 0.5)
{
    color = ExpensiveEffect();
}
```

같은 GPU 실행 그룹의 Fragment가 서로 다른 경로를 선택하면 Branch Divergence가 발생할 수 있다.

각 경로를 나누어 실행하는 동안 일부 Lane이 비활성화되어 실행 효율이 낮아질 수 있다.

하지만 모든 조건문이 항상 느린 것은 아니다.

조건이 Material 전체에서 같거나 Compiler가 Branch를 Flatten하고 한 경로가 매우 짧다면 영향이 작을 수 있다.

---

## Dynamic Branch와 Shader Variant

Material 기능을 선택하는 방법은 Runtime Branch만 있는 것이 아니다.

Shader Keyword로 서로 다른 Variant를 Compile할 수 있다.

```text
Dynamic Branch
하나의 Shader에서 Runtime 조건 선택

Shader Variant
기능 조합별 별도 Program
```

Variant는 실행 시 불필요한 Branch와 Code를 줄일 수 있지만 Build Size, Compile Time, Memory와 Pipeline State 수를 늘릴 수 있다.

Dynamic Branch는 Variant Explosion을 줄일 수 있지만 분기와 Register 사용 비용이 생길 수 있다.

기능의 변경 빈도와 대상 GPU를 기준으로 선택해야 한다.

---

## Fragment Shader의 Loop

여러 Light, Blur Tap 또는 Layer를 처리하기 위해 반복문을 사용할 수 있다.

```hlsl
for (int i = 0; i < lightCount; i++)
{
    lighting += EvaluateLight(i);
}
```

Loop 횟수가 Compile Time에 정해지면 Compiler가 Unroll할 수 있다.

Runtime Count에 따라 달라지면 Dynamic Loop가 될 수 있다.

Fragment 수백만 개에서 Loop가 반복되면 작은 반복 횟수 차이도 큰 전체 연산량이 된다.

Light Culling과 Blur Downsampling이 중요한 이유다.

---

## Texture Sampling 비용

Texture Sampling 비용은 단순히 Sample 명령 개수로만 결정되지 않는다.

```text
Texture Format과 크기
Cache Hit Rate
접근 패턴
Mipmap
Filtering
Anisotropic Level
Memory Bandwidth
Texture 압축
```

인접 Fragment가 가까운 UV를 Sampling하면 Texture Cache를 효율적으로 사용할 수 있다.

무작위 위치를 읽거나 큰 Texture를 여러 장 접근하면 Cache Miss와 Bandwidth가 증가할 수 있다.

ALU 연산보다 Texture Memory 대기가 병목인 Shader도 있다.

---

## ALU와 Bandwidth

Fragment Shader 비용은 계산 명령인 ALU와 Texture·Buffer·Render Target Memory 접근을 함께 봐야 한다.

```text
ALU Bound
복잡한 수학, Lighting, Loop

Texture Bound
많은 Sampling과 Cache Miss

Bandwidth Bound
큰 Render Target와 많은 Read / Write
```

Shader 코드가 길어도 Memory 대기 동안 ALU를 활용하여 전체 병목 변화가 작을 수 있다.

반대로 짧아 보이는 Shader도 큰 Texture 여러 장과 HDR MRT를 사용하면 대역폭 병목이 될 수 있다.

코드 줄 수만으로 Shader가 무겁다고 판단할 수 없다.

---

## Precision

HLSL의 `float`, `half`는 값의 정밀도와 Register 사용에 영향을 줄 수 있다.

모바일 GPU에서는 `half` 연산이 처리량과 전력에 유리할 수 있다.

```hlsl
half3 color;
half3 normal;
float3 positionWS;
```

Position, Depth와 넓은 HDR 범위처럼 높은 정밀도가 필요한 값에는 `float`가 필요할 수 있다.

Normal과 Color도 계산 범위와 누적 과정에 따라 `half` 오차가 보일 수 있다.

Desktop GPU에서는 두 Type의 실제 실행 성능 차이가 작거나 Compiler가 다르게 처리할 수 있다.

대상 플랫폼에서 품질과 성능을 확인해야 한다.

---

## Register Pressure

Fragment Shader의 Local 변수와 중간 계산이 많으면 Invocation마다 필요한 Register 수가 증가할 수 있다.

GPU의 Register 자원은 제한되어 있으므로 한 Invocation이 많이 사용하면 동시에 실행할 수 있는 Thread 수가 줄 수 있다.

```text
Register 사용 증가
↓
동시에 유지 가능한 실행 그룹 감소
↓
Memory Latency를 숨길 기회 감소 가능
```

이를 Occupancy와 연결해 볼 수 있다.

하지만 Register 수를 무조건 최소화하면 연산 재계산이나 Memory 접근이 늘 수 있다.

Compiler Output과 GPU 분석 도구를 기준으로 판단해야 한다.

---

## Fragment Shader Invocation 수

화면 해상도가 1920×1080이면 약 207만 Pixel이 있다.

하지만 Fragment Shader가 Frame당 정확히 207만 번 실행된다는 의미는 아니다.

```text
Overdraw
여러 Triangle이 같은 Pixel을 덮음

여러 Render Pass
Shadow, Depth, Opaque, Transparent, Post Process

MSAA / Sample Shading
Sample별 실행 가능

Helper Invocation
Derivative를 위한 추가 실행

Early-Z
일부 실행 제거 가능

VRS
여러 Pixel에 하나의 실행 가능
```

실제 Invocation 수는 Scene과 Pipeline에 따라 크게 달라진다.

---

## 해상도의 영향

Fragment Shader는 화면 Coverage와 연결되므로 Render Target 해상도가 높아지면 실행할 Fragment 수가 증가할 가능성이 높다.

```text
1920 × 1080
약 207만 Pixel

3840 × 2160
약 829만 Pixel
```

4K는 1080p보다 Pixel 수가 약 네 배다.

같은 Fullscreen Fragment Shader라면 연산과 Texture Sampling, Render Target Write가 크게 늘 수 있다.

Dynamic Resolution과 Render Scale이 GPU Fragment 병목을 줄이는 데 효과가 있을 수 있는 이유다.

---

## Overdraw의 영향

같은 화면 위치에 여러 Fragment가 겹치면 Fragment Shader가 반복 실행될 수 있다.

```text
Opaque Layer 3개
Depth로 일부 Early 제거 가능

Transparent Layer 10개
ZWrite Off로 모두 Blend될 수 있음
```

연기와 Particle이 화면 전체를 여러 번 덮으면 각 Layer의 Shader가 실행되고 Color Blending이 반복된다.

Fragment Shader가 간단해도 Overdraw가 매우 높으면 GPU Fill Rate와 Bandwidth 병목이 생길 수 있다.

Shader 복잡도와 화면 Coverage를 함께 확인해야 한다.

---

## Fullscreen Fragment Shader

Post Processing은 Fullscreen Triangle을 Rasterization하여 화면 전체에서 Fragment Shader를 실행할 수 있다.

```text
Scene Color Texture
↓
Fullscreen Fragment Shader
Tone Mapping / Bloom / Color Grading
↓
Output Render Target
```

Geometry는 Triangle 하나뿐이어도 Fragment는 화면 전체에 생성된다.

Blur가 여러 Texture Sample을 사용하고 여러 Pass로 반복되면 해상도와 Sample 수에 비례한 비용이 발생한다.

Post Processing에서는 Triangle 수보다 Fragment와 Bandwidth 비용이 중요하다.

---

## Deferred Rendering의 Fragment Shader

Deferred Rendering의 Geometry Pass는 최종 Lighting Color 대신 Material 정보를 G-Buffer에 기록한다.

```text
G-Buffer 0
Albedo / Occlusion

G-Buffer 1
Normal / Smoothness

G-Buffer 2
다른 Material 정보
```

이후 Lighting Pass가 Screen Space에서 G-Buffer와 Depth를 읽어 Lighting을 계산한다.

Fragment Shader의 역할이 항상 최종 Color 하나를 출력하는 것은 아니다.

Render Pass 목적에 따라 Shadow Depth, G-Buffer, Motion Vector, Object ID와 Post Process 결과를 출력할 수 있다.

---

## Shadow Caster Fragment Shader

Shadow Map Pass는 Light 관점의 Depth를 만드는 것이 목적이다.

Opaque Shadow Caster는 Color 출력이 필요하지 않을 수 있다.

Alpha Clipping Material은 Texture Alpha를 Sampling하여 Shadow를 만들 Fragment를 선택해야 한다.

```text
Leaf Texture Alpha
↓ clip
잎 모양의 Shadow Depth
```

같은 Material도 Forward Pass와 Shadow Caster Pass에서 서로 다른 Fragment Shader를 사용할 수 있다.

Shadow가 추가되면 화면에 한 번 보이는 Mesh의 Texture와 Alpha 계산이 Shadow Pass에서도 반복될 수 있다.

---

## Motion Vector Pass

Temporal AA와 Motion Blur에는 현재 Frame과 이전 Frame의 화면 위치 차이가 필요하다.

Motion Vector Pass는 Object와 Camera Movement를 계산하여 Velocity Buffer에 기록한다.

```text
Previous Clip Position
Current Clip Position
↓
Screen Motion Vector
```

Vertex Animation이 이전 Frame 위치를 올바르게 제공하지 않으면 Motion Vector가 잘못되어 TAA Ghosting과 Motion Blur Artifact가 생길 수 있다.

Fragment Shader와 Pass 출력은 Material의 최종 Color만을 위한 것이 아니다.

---

## Fragment Shader는 이웃 Pixel을 읽을 수 있을까?

일반 Fragment Shader Invocation은 이웃 Invocation의 Local 변수에 직접 접근하지 않는다.

Derivative는 이웃 값 차이를 얻는 제한된 기능이고 임의의 이웃 결과를 공유하는 일반 Memory가 아니다.

이미 완성된 Texture를 Sampling하면 주변 Texel을 읽을 수 있다.

```text
Blur
현재 UV 주변 Scene Color Texture Sampling
```

하지만 현재 Pass에서 동시에 쓰고 있는 Color를 아무 Synchronization 없이 이웃에서 읽으면 Read-Write Hazard가 생길 수 있다.

보통 별도 Render Target, Copy, Subpass Input 또는 지원되는 Tile 기능을 사용한다.

---

## Side Effect와 실행 순서

Fragment Shader는 지원되는 환경에서 Storage Buffer, UAV와 Atomic에 값을 쓸 수 있다.

하지만 Fragment Invocation의 실행 완료 순서는 Primitive 제출 순서와 같다고 보장되지 않을 수 있다.

```text
Primitive A Shader Store
Primitive B Shader Store

완료 순서는 병렬 실행에 따라 달라질 수 있음
```

Framebuffer Color와 Depth 결과는 Rasterization Order 규칙을 따르지만 일반 Storage Memory Side Effect는 별도 Synchronization과 Atomic이 필요하다.

Helper Invocation의 Side Effect도 일반 Invocation과 다르게 처리된다.

화면 순서를 이용한 임의 Buffer 알고리즘을 작성하면 Race Condition이 발생할 수 있다.

---

## Fragment Shader 문제를 확인하는 방법

Fragment 결과가 잘못 보이면 Input, Resource, Output과 Render State를 나누어 확인할 수 있다.

```text
UV 문제
Texture가 늘어나거나 뒤집힘

Normal 문제
Lighting 방향과 세기 오류

Color Space 문제
Texture와 Blend가 너무 밝거나 어두움

Depth / clip 문제
표면이 사라지거나 가림 오류

Blend 문제
투명 가장자리와 순서 오류

Variant 문제
특정 기능과 플랫폼에서만 결과가 다름
```

UV, Normal, World Position과 Mask를 Debug Color로 출력하면 중간 값을 시각화할 수 있다.

Frame Debugger와 RenderDoc에서는 Texture Binding, Sampler, Constant Buffer, Shader Resource와 Fragment Output을 확인할 수 있다.

---

## Fragment Shader 최적화 관점

Fragment Shader 비용은 다음 요소를 함께 봐야 한다.

```text
Fragment Invocation 수
화면 Coverage와 Overdraw
해상도와 MSAA
Texture Sampling 수와 Cache
Lighting과 Loop
Branch Divergence
Varying과 Register 사용
Render Target 수와 Format
Blending과 Bandwidth
```

코드 줄 수가 짧다고 가벼운 Shader라는 의미는 아니다.

큰 Texture를 여러 번 읽고 HDR MRT에 쓰는 짧은 Shader는 Bandwidth Bound가 될 수 있다.

긴 수학 Shader도 낮은 해상도와 적은 Coverage에서 실행되면 Frame 전체 영향이 작을 수 있다.

---

## 최적화는 어디서 시작할까?

먼저 GPU가 Fragment Bound인지 확인해야 한다.

해상도나 Render Scale을 낮췄을 때 GPU Frame Time이 크게 줄면 Fragment와 Bandwidth 병목일 가능성이 있다.

```text
Fragment 병목 확인
↓
Overdraw 확인
↓
비싼 Pass와 Shader 확인
↓
Texture / ALU / Bandwidth 분석
↓
수정 후 재측정
```

화면을 차지하는 면적과 실행 횟수를 줄이는 최적화가 Shader 명령 몇 개를 줄이는 것보다 효과적일 수 있다.

반대로 CPU Bound라면 Fragment Shader를 크게 단순화해도 Frame Time이 거의 변하지 않을 수 있다.

---

## 전체 흐름

Fragment Shader 전후의 과정을 정리하면 다음과 같다.

```text
Vertex Shader Varying
↓
Rasterization과 Perspective Interpolation
↓
Fragment Input
Screen Position, UV, Normal, Color, Depth
↓
Early Depth / Stencil 가능
↓
Fragment Shader
Texture Sampling
Material Property
Lighting / Shadow
Normal Mapping
Branch / Loop
↓
Color, Alpha, 선택적 Depth / MRT 출력
↓
Late Depth / Stencil / Coverage
↓
Blending
↓
Color / Depth Render Target
```

Fragment Shader는 Rasterization이 만든 Geometry Coverage와 Output Operations 사이에서 Material과 Lighting 결과를 계산한다.

---

## 정리

Fragment Shader는 Rasterization이 생성한 Fragment Invocation에서 보간 데이터와 Texture, Material, Lighting Resource를 읽어 Render Target에 사용할 값을 계산하는 GPU Program이다.

Pixel Shader라는 이름과 같은 Stage를 가리킬 수 있지만 Fragment는 최종 Pixel이 아니라 Primitive가 만든 렌더링 후보다.

여러 Fragment가 같은 Pixel 위치에 생성될 수 있고 일부는 Depth Test에서 제거되거나 Blending으로 결합된다.

Vertex Shader의 UV, Normal, World Position과 Color는 Rasterizer에서 Perspective 보간되어 Fragment Shader Input으로 전달된다.

Fragment Shader는 `SV_Target`을 통해 Source Color를 출력하며 MRT를 사용하면 여러 Color Attachment에 Material Data를 기록할 수 있다.

Alpha 출력은 Blend State와 함께 사용해야 실제 반투명 결과를 만들며 Shader가 출력한 Color가 곧바로 최종 화면 Color가 되는 것은 아니다.

Texture Sampling은 Texture와 Sampler, UV Derivative, Mipmap, Filtering과 Cache 및 Memory Bandwidth에 영향을 받는다.

Derivative를 계산하기 위해 Coverage 밖에서도 Helper Invocation이 실행될 수 있으므로 Covered Pixel 수와 Shader 연산 수가 항상 같지는 않다.

Lighting, Normal Mapping, Shadow와 Additional Light Loop는 많은 Fragment에 반복되므로 화면 Coverage와 해상도가 비용에 큰 영향을 준다.

`clip`은 Fragment를 버릴 수 있지만 이전에 실행한 Shader 연산 비용까지 되돌리지는 않으며 Early-Z와 Branch 효율에도 영향을 줄 수 있다.

Fragment Shader가 Depth를 직접 출력하거나 Storage Resource에 Side Effect를 만들면 일반적인 Early Test와 실행 순서 가정이 달라질 수 있다.

Fragment Shader 최적화에서는 코드 길이만 보지 않고 Invocation 수, Overdraw, Texture Cache, ALU, Register, Render Target Format과 Bandwidth를 함께 측정해야 한다.

Fragment Shader와 Pixel의 관계를 더 정확히 이해하려면 다음 글에서 하나의 Fragment가 최종 Pixel과 언제 같고 언제 다른지 별도로 구분할 필요가 있다.
