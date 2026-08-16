---
title: "[Unity 렌더링] 7-1. 빛은 Shader에서 어떻게 계산될까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - Shader
  - Lighting
  - DiffuseSpecular
permalink: /programming/unity-7-1-shader-lighting-calculation/
toc: true
toc_sticky: true
date: 2026-08-16
last_modified_at: 2026-08-16
---

Shader가 Surface의 밝기와 Highlight를 계산하려면 Light와 Surface, Camera 사이의 방향을 알아야 한다.

Surface Normal과 Light Direction이 얼마나 같은 방향을 보는지 계산하면 Diffuse가 만들어진다.

Light가 반사되는 방향과 View Direction이 얼마나 가까운지 계산하면 Specular가 만들어진다.

```text
Light Direction
       │
       ▼
Surface Normal ── Diffuse
       │
       ├─ Reflection / Half Vector
       │
       ▼
View Direction ── Specular
```

여기에 Light Color, 거리 감쇠, Spot Angle, Shadow와 Material 값을 곱하면 한 Light의 최종 기여가 된다.

여러 Light가 있으면 각 기여를 반복해서 더한다.

---

## Lighting은 무엇을 계산하는가?

Lighting Shader는 한 Surface Point가 Camera에 어떤 Color로 보이는지 계산한다.

```text
Output Color
= Direct Diffuse
+ Direct Specular
+ Indirect Diffuse
+ Indirect Specular
+ Emission
```

Direct Lighting은 Light Source에서 Surface로 직접 도달한 빛이다.

Indirect Lighting은 다른 Surface와 Environment를 거쳐 들어온 빛이다.

이번 글은 Direct Light를 중심으로 Vector 관계를 연결하고 Indirect Light는 전체 결과 안에서 위치만 구분한다.

---

## Lighting 계산에 필요한 입력

한 Fragment의 Lighting에 필요한 대표 입력은 다음과 같다.

| 입력 | 의미 |
| --- | --- |
| `positionWS` | Lighting을 계산할 Surface의 World Position |
| `normalWS` | Surface가 향하는 World Space 방향 |
| `viewDirectionWS` | Surface에서 Camera로 향하는 방향 |
| `light.direction` | Surface에서 Light로 향하는 방향 |
| `light.color` | Light의 RGB Color와 Intensity 결과 |
| `distanceAttenuation` | 거리와 Spot Angle에 따른 Light 감소 |
| `shadowAttenuation` | Shadow에 따른 Light Visibility |
| Material Data | Base Color, Smoothness와 Specular 성질 |

모든 Vector는 같은 Coordinate Space에서 비교해야 한다.

---

## 한 Light의 기여

한 Light의 Direct Lighting을 개념적으로 다음처럼 표현할 수 있다.

```text
Direct Light Contribution
= (Diffuse + Specular)
× Light Color
× Distance Attenuation
× Shadow Attenuation
```

Spot Light라면 Angle Attenuation도 Distance Attenuation에 포함될 수 있다.

Rendering Layer가 맞지 않으면 해당 Light의 기여를 계산하지 않을 수 있다.

Material Workflow에 따라 Diffuse와 Specular가 Base Color를 나누어 사용하는 방식도 달라진다.

---

## Position이 필요한 이유

Directional Light는 모든 Surface에서 방향이 일정하다.

Point와 Spot Light는 Surface 위치에 따라 Light Direction과 Distance가 달라진다.

```text
Point Light Position P_L
Surface Position P_S

Light Vector = P_L - P_S
Distance = length(Light Vector)
Light Direction = normalize(Light Vector)
```

Surface의 World Position이 없으면 Local Light까지의 방향과 거리를 계산할 수 없다.

Forward+에서는 Position과 Screen UV가 어떤 Cluster의 Light를 읽을지 결정하는 데도 사용된다.

---

## Coordinate Space

3D Vector는 어느 Coordinate Space에 속하는지 반드시 구분해야 한다.

```text
Object Space
└─ Mesh Local Coordinate

World Space
└─ Scene 공통 Coordinate

View Space
└─ Camera 기준 Coordinate

Clip Space
└─ Projection 이후 Coordinate
```

World Normal과 Object Space Light Direction을 그대로 Dot Product하면 의미 없는 결과가 나온다.

Lighting Vector를 World Space로 통일하거나 모두 View Space로 변환한다.

URP는 주로 이름 끝의 `WS`, `VS`, `OS`, `CS`로 Space를 표시한다.

---

## Position을 World Space로 변환하기

Vertex Position은 Mesh Asset에서 Object Space로 들어온다.

```hlsl
float3 positionWS =
    TransformObjectToWorld(input.positionOS.xyz);

float4 positionCS =
    TransformWorldToHClip(positionWS);
```

```text
positionOS
   │ Object Transform
   ▼
positionWS
   │ View Projection
   ▼
positionCS
```

Rasterization에는 Clip Space Position이 필요하고 Lighting에는 World Position이 필요하다.

Vertex Shader에서 두 값을 준비해 Fragment로 전달할 수 있다.

---

## Normal이란?

Normal은 Surface가 어느 방향을 향하는지 나타내는 단위 Vector다.

```text
          N
          ↑
          │
──────────●────────── Surface
```

빛이 Surface 정면으로 들어오면 밝다.

빛이 Surface에 비스듬히 들어오면 같은 Energy가 더 넓은 면적에 퍼져 어두워진다.

빛이 Surface 뒤에서 오면 앞면 Direct Diffuse에 기여하지 않는다.

---

## Vertex Normal

Mesh의 각 Vertex는 Normal을 가질 수 있다.

```text
Vertex A Normal ↖
Vertex B Normal ↑
Vertex C Normal ↗
```

Rasterizer는 Triangle 내부 Fragment에서 Vertex Normal을 보간한다.

Smooth Shading은 Geometry Face가 적어도 보간된 Normal로 곡면처럼 보이게 만든다.

Hard Edge에서는 Vertex를 분리해 서로 다른 Normal을 사용한다.

Mesh Import의 Normal과 Smoothing 설정이 Lighting 결과에 직접 영향을 준다.

---

## Normal 변환

Normal은 Position과 같은 방식으로 Transform하면 Non-uniform Scale에서 틀어질 수 있다.

```text
Scale X = 2
Scale Y = 1
Scale Z = 0.5

Position Transform과 Normal Transform의 요구가 다름
```

URP Helper를 사용해 Object Normal을 World Normal로 변환한다.

```hlsl
float3 normalWS =
    TransformObjectToWorldNormal(input.normalOS);
```

최종 Dot Product 전에 Normalize한다.

---

## 보간 후 다시 Normalize하는 이유

단위 Vector 두 개를 선형 보간하면 중간 Vector의 길이가 1이 아닐 수 있다.

```text
normalize(N0) = length 1
normalize(N1) = length 1

lerp(N0, N1, 0.5)
→ length가 1이라는 보장 없음
```

Fragment Shader에서 다시 Normalize한다.

```hlsl
float3 N = normalize(input.normalWS);
```

Normalize를 빠뜨리면 Dot Product 크기와 Specular 모양이 왜곡된다.

---

## Normal Map

Normal Map은 Texture로 미세한 Surface 방향 변화를 표현한다.

```text
Mesh Normal
└─ 큰 형태

Normal Map
└─ 작은 홈과 요철 방향
```

일반적인 Normal Map은 Tangent Space Vector를 저장한다.

Shader는 Tangent, Bitangent와 Normal로 TBN Basis를 만들고 Tangent Space Normal을 World Space로 변환한다.

Geometry를 실제로 움직이지 않으므로 Silhouette는 바뀌지 않는다.

---

## TBN Basis

```text
T = Tangent
B = Bitangent
N = Normal

TBN Matrix
└─ Tangent Space Vector를 World Space로 변환
```

```hlsl
float3 normalTS =
    UnpackNormal(normalSample);

float3 normalWS = normalize(
    TransformTangentToWorld(
        normalTS,
        tangentToWorld
    )
);
```

정확한 URP Helper Signature는 사용하는 Package Version과 Shader Library를 따른다.

Tangent 방향이나 Normal Map Import Type이 틀리면 Light가 반대로 흐르는 것처럼 보일 수 있다.

---

## Light Direction

Lighting 수식에서는 일반적으로 Surface에서 Light로 향하는 단위 Vector `L`을 사용한다.

```text
Light ●
       ↖ L
         \
          ● Surface
```

어떤 Library는 Light에서 Surface로 향하는 방향을 제공할 수도 있다.

Vector 방향 Convention이 반대면 Dot Product Sign도 반대가 된다.

URP의 `Light.direction`이 어떤 Convention인지 공식 Helper와 Shader Source를 기준으로 사용한다.

---

## Directional Light

Directional Light는 매우 멀리 있는 Light를 모델링한다.

모든 Surface에서 Light Direction이 거의 같다.

```text
→ → → → Parallel Rays
→ → → →
→ → → →
```

Position과 Range에 따른 Distance Attenuation을 일반 Point Light처럼 계산하지 않는다.

Sun과 Moon 같은 광원에 적합하다.

Main Light로 선택되는 경우가 많다.

---

## Point Light

Point Light는 한 Position에서 모든 방향으로 빛을 낸다.

```text
        ↑
      ↖   ↗
    ←   ●   →
      ↙   ↘
        ↓
```

Surface마다 Light Direction이 다르다.

```hlsl
float3 toLight = lightPositionWS - positionWS;
float distanceToLight = length(toLight);
float3 L = toLight / distanceToLight;
```

거리가 멀어질수록 Intensity가 감소하고 Range 밖에서는 기여가 사라진다.

---

## Spot Light

Spot Light는 Position과 Direction, Inner·Outer Cone을 가진다.

```text
Light ●
       \  Inner Cone
        \
         \____ Outer Cone
```

Point Light의 Distance Attenuation에 Angle Attenuation이 더해진다.

```text
Spot Attenuation
= Distance Falloff
× Cone Angle Falloff
```

Cone 밖 Surface는 Light Range 안에 있어도 기여하지 않는다.

---

## Light Color

Light Color는 RGB Channel별 Energy 비율을 나타낸다.

```text
White Light  = (1, 1, 1)
Red Light    = (1, 0, 0)
Blue Light   = (0, 0, 1)
```

Unity Light의 Color와 Intensity가 Shader가 사용할 `light.color`에 반영된다.

Linear Lighting 계산에서는 Color를 Linear Space 값으로 다룬다.

Gamma Encoded Texture 값을 그대로 수학 연산하면 Energy 관계가 틀어질 수 있다.

---

## Dot Product

두 단위 Vector의 Dot Product는 사이 Angle의 Cosine이다.

```text
dot(A, B) = |A| |B| cos(theta)

단위 Vector라면
dot(A, B) = cos(theta)
```

| Angle | Dot Product |
| --- | --- |
| 0° | 1 |
| 60° | 0.5 |
| 90° | 0 |
| 180° | -1 |

Lighting에서는 Vector가 얼마나 같은 방향인지 빠르게 계산하는 핵심 연산이다.

---

## N dot L

Diffuse Lighting의 기본 입력은 Normal `N`과 Light Direction `L`의 Dot Product다.

```hlsl
float NdotL = dot(N, L);
```

```text
Light가 정면
N · L = 1

Light가 옆
N · L = 0

Light가 뒤
N · L < 0
```

앞면 Direct Light에서는 Negative 값을 0으로 제한한다.

```hlsl
float NdotL = saturate(dot(N, L));
```

---

## saturate

HLSL의 `saturate(x)`는 값을 0과 1 사이로 제한한다.

```text
saturate(-0.5) = 0
saturate(0.4)  = 0.4
saturate(1.5)  = 1
```

Diffuse에서 Surface 뒤쪽 Light가 Negative Color를 만들지 않도록 한다.

`max(0, dot(N, L))`과 같은 목적이다.

모든 Lighting 중간 값을 무조건 Saturate하면 HDR Energy와 Highlight가 잘릴 수 있으므로 필요한 항목에만 사용한다.

---

## Diffuse Lighting

Diffuse는 빛이 거친 Surface 내부에서 여러 방향으로 흩어져 나오는 성분을 모델링한다.

관찰 방향이 달라도 이상적인 Diffuse 밝기는 주로 `N · L`에 의해 결정된다.

```text
Diffuse
= Base Color
× Light Color
× saturate(N · L)
× Attenuation
```

```hlsl
half3 diffuse =
    baseColor
    * light.color
    * saturate(dot(N, L));
```

거리와 Shadow는 뒤에서 추가한다.

---

## Lambert Diffuse

가장 기본적인 Diffuse Model이 Lambert Lighting이다.

물리적인 Energy 정규화까지 포함하면 `1 / PI` Factor를 사용할 수 있다.

```text
Lambert BRDF = BaseColor / PI

Outgoing Diffuse
= Lambert BRDF
× Light Irradiance
× NdotL
```

Engine Helper가 이미 정규화와 Intensity Convention을 반영할 수 있으므로 Factor를 중복 적용하지 않는다.

Lambert의 의미와 수식은 다음 글에서 더 자세히 다룬다.

---

## URP LightingLambert

URP `Lighting.hlsl`은 단순 Lambert Helper를 제공한다.

```hlsl
half3 diffuse = LightingLambert(
    light.color,
    light.direction,
    normalWS
);
```

Function이 Light Color와 Direction, Surface Normal로 Diffuse Lighting을 반환한다.

Base Color를 언제 곱하는지는 사용하는 Helper의 반환 의미와 Shader 구조를 확인한다.

Custom Lighting에서는 직접 Dot Product를 작성하거나 URP Helper를 사용할 수 있다.

---

## View Direction

View Direction `V`는 Surface에서 Camera로 향하는 단위 Vector다.

```text
Camera ●
        ↖ V
          \
           ● Surface
```

Perspective Camera에서는 Surface Position마다 방향이 달라진다.

```hlsl
float3 V = normalize(
    cameraPositionWS - positionWS
);
```

URP Helper를 사용할 수 있다.

```hlsl
float3 V =
    GetWorldSpaceNormalizeViewDir(positionWS);
```

---

## Orthographic Camera의 View Direction

Orthographic Camera의 Ray는 서로 평행하다.

```text
Perspective
\  |  /
 \ | /
  Camera

Orthographic
↓  ↓  ↓
```

View Direction을 단순히 Camera Position에서 Surface로 계산하면 Orthographic Projection의 의도와 다를 수 있다.

URP Helper는 Camera Projection 조건을 고려하므로 직접 구현보다 안전하다.

---

## Specular Lighting

Specular는 매끄러운 Surface에서 특정 방향으로 집중되는 반사를 모델링한다.

Light가 반사되는 방향 근처에 Camera가 있을 때 밝은 Highlight가 보인다.

```text
      L       V
       \     /
        \ N /
─────────●──────── Surface
```

Specular에는 Light Direction, View Direction, Normal과 Surface Smoothness가 필요하다.

Diffuse와 달리 Camera가 움직이면 Highlight 위치와 크기가 변한다.

---

## Reflection Vector 방식

Phong 계열 Model은 Light Reflection Direction `R`과 View Direction `V`를 비교한다.

```text
R = reflect(-L, N)
```

```hlsl
float3 R = reflect(-L, N);
float RdotV = saturate(dot(R, V));

float specular = pow(RdotV, shininess);
```

`shininess`가 크면 Highlight가 작고 날카로워진다.

Reflection Vector Sign은 `L`의 방향 Convention에 따라 달라진다.

---

## Half Vector 방식

Blinn-Phong 계열 Model은 Light Direction과 View Direction의 중간 Vector `H`를 사용한다.

```text
H = normalize(L + V)
```

```hlsl
float3 H = normalize(L + V);
float NdotH = saturate(dot(N, H));

float specular = pow(NdotH, shininess);
```

Normal이 Half Vector와 가까우면 Surface가 Light를 Camera 방향으로 반사하는 상태다.

Phong과 Blinn-Phong의 Exponent는 같은 값에서 동일한 Highlight 폭을 만들지 않는다.

---

## Smoothness와 Highlight

매끄러운 Surface는 반사 방향이 집중된다.

거친 Surface는 여러 방향으로 퍼진다.

```text
Low Smoothness
└─ 넓고 약한 Highlight

High Smoothness
└─ 좁고 강한 Highlight
```

단순 Model에서는 Smoothness를 `pow()` Exponent로 변환한다.

PBR에서는 Microfacet Roughness Distribution과 Geometry, Fresnel Term을 함께 계산한다.

Specular의 세부 Model은 이어지는 글에서 분리한다.

---

## Specular Color

Specular Color는 Surface가 반사하는 Light의 Color 특성을 나타낸다.

```text
Non-metal
├─ Diffuse에 Base Color
└─ Specular는 낮은 Reflectance 중심

Metal
├─ Diffuse가 매우 작음
└─ Specular에 Base Color가 반영
```

단순 Shader에서는 독립적인 `specularColor`를 사용할 수 있다.

PBR Metallic Workflow에서는 Metallic과 Base Color로 Diffuse·Specular Energy를 나눈다.

---

## URP LightingSpecular

URP는 단순 Specular Helper를 제공한다.

```hlsl
half3 specular = LightingSpecular(
    light.color,
    light.direction,
    normalWS,
    viewDirectionWS,
    specularAmount,
    smoothnessAmount
);
```

Function Signature는 Light Color와 Direction, Surface Normal, View Direction, Specular Amount와 Smoothness를 받는다.

PBR Lit Shader 전체와 같은 BRDF라고 가정하면 안 된다.

학습용 또는 Simple Lighting에 적합한 Helper로 이해한다.

---

## Diffuse와 Specular를 더하기

```hlsl
half NdotL = saturate(dot(N, L));

half3 diffuse =
    baseColor * NdotL;

half3 H = normalize(L + V);
half NdotH = saturate(dot(N, H));

half specularTerm =
    pow(NdotH, shininess);

half3 specular =
    specularColor * specularTerm;

half3 directLighting =
    (diffuse + specular)
    * light.color;
```

여기에 Light Visibility와 Attenuation을 적용한다.

---

## Distance Attenuation

Point와 Spot Light의 밝기는 거리에 따라 감소한다.

물리적인 점광원 Energy는 거리 제곱에 반비례한다.

```text
Intensity ∝ 1 / distance²
```

Game Engine은 Range 경계에서 Light가 부드럽게 0이 되도록 Window Function을 결합할 수 있다.

URP가 계산한 결과는 `light.distanceAttenuation`으로 제공된다.

직접 다시 거리 감쇠를 곱하면 중복 감쇠가 될 수 있다.

---

## Angle Attenuation

Spot Light는 Surface가 Cone 안쪽에 있는지 계산한다.

```text
Inner Cone
└─ Attenuation 1에 가까움

Inner와 Outer 사이
└─ 1에서 0으로 부드럽게 감소

Outer Cone 밖
└─ 0
```

URP의 Light Data에서는 Distance와 Spot Angle 결과가 `distanceAttenuation`에 조합될 수 있다.

Custom Falloff를 만들 때 Realtime과 Baked Lighting의 모양이 일치하는지도 확인해야 한다.

---

## Shadow Attenuation

Shadow는 Light와 Surface 사이가 가려졌는지 나타낸다.

```text
Light Visibility
├─ 1: Light가 보임
├─ 0: 완전히 가려짐
└─ 0과 1 사이: Filtered Soft Shadow
```

URP의 `light.shadowAttenuation`을 Direct Light에 곱한다.

```hlsl
directLighting *=
    light.distanceAttenuation
    * light.shadowAttenuation;
```

Shadow가 Diffuse에만 적용되고 Specular에는 빠지는 실수를 주의한다.

---

## Shadow가 완전히 검지 않은 이유

Direct Light가 Shadow에 가려져도 Indirect Lighting과 Emission은 남을 수 있다.

```text
Shadowed Surface
├─ Direct Diffuse 감소
├─ Direct Specular 감소
├─ Baked / Probe Indirect 유지 가능
├─ Reflection 유지 가능
└─ Emission 유지
```

최종 Color 전체에 Shadow Attenuation을 곱하면 Ambient와 Emission까지 사라져 부자연스러울 수 있다.

Shadow는 해당 Light의 Direct Contribution에 적용한다.

---

## Main Light 가져오기

Custom URP Shader에서 Lighting Library를 Include한다.

```hlsl
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
```

Main Light Data를 얻는다.

```hlsl
Light mainLight = GetMainLight();
```

Shadow Coordinate를 받는 Overload를 사용하면 Main Light Shadow 정보도 가져올 수 있다.

```hlsl
float4 shadowCoord =
    TransformWorldToShadowCoord(positionWS);

Light mainLight =
    GetMainLight(shadowCoord);
```

---

## URP Light 구조체

```text
Light
├─ direction
├─ color
├─ distanceAttenuation
├─ shadowAttenuation
└─ layerMask
```

`direction`과 `color`만 사용하면 거리, Spot Cone과 Shadow가 빠진다.

`layerMask`는 Rendering Layer Matching에 사용한다.

Main과 Additional Light 모두 같은 개념의 구조체로 Lighting Function에 전달할 수 있다.

---

## 한 Light 계산 함수

```hlsl
half3 EvaluateDirectLight(
    half3 baseColor,
    half3 specularColor,
    half smoothness,
    float3 N,
    float3 V,
    Light light)
{
    float3 L = normalize(light.direction);

    half NdotL = saturate(dot(N, L));
    half3 diffuse = baseColor * NdotL;

    float3 H = normalize(L + V);
    half NdotH = saturate(dot(N, H));

    half shininess = exp2(
        1.0h + smoothness * 10.0h
    );

    half3 specular = specularColor
        * pow(NdotH, shininess)
        * NdotL;

    half attenuation =
        light.distanceAttenuation
        * light.shadowAttenuation;

    return (diffuse + specular)
        * light.color
        * attenuation;
}
```

Model을 이해하기 위한 단순 예제이며 URP Lit의 PBR BRDF를 재현한 Code는 아니다.

---

## Specular에 N dot L을 곱하는 이유

Surface 뒤쪽에서 오는 Light가 Specular Highlight를 만들지 않도록 제한해야 한다.

```text
N · L <= 0
→ 앞면에 Direct Light가 도달하지 않음
→ Diffuse와 Specular 모두 0
```

단순 `pow(NdotH, shininess)`만 사용하면 Light가 Surface 뒤에 있어도 Highlight가 생길 수 있다.

`NdotL` Gate 또는 명시적인 Branch를 적용한다.

PBR BRDF에서는 Geometry와 Visibility Term이 더 정교하게 처리한다.

---

## Additional Light 반복

Forward Path에서는 Additional Light 수를 얻어 반복할 수 있다.

```hlsl
uint lightCount = GetAdditionalLightsCount();

for (uint i = 0u; i < lightCount; ++i)
{
    Light light = GetAdditionalLight(
        i,
        positionWS
    );

    color += EvaluateDirectLight(
        baseColor,
        specularColor,
        smoothness,
        N,
        V,
        light
    );
}
```

Forward+까지 지원하려면 URP의 `LIGHT_LOOP_BEGIN` Macro와 `InputData` 구조를 사용해야 한다.

---

## 여러 Light는 더해진다

```text
Direct Lighting
= Light 0 Contribution
+ Light 1 Contribution
+ Light 2 Contribution
+ ...
```

HDR Buffer에서는 합이 1을 넘어갈 수 있다.

Final Tone Mapping 단계에서 Display 범위로 변환한다.

각 Light마다 Material Texture를 다시 Sampling할 필요가 없도록 Surface Data를 Loop 밖에서 준비한다.

---

## Rendering Layer

Light와 Renderer의 Rendering Layer Mask가 겹칠 때만 기여하도록 할 수 있다.

```text
Character Light Mask
AND Character Renderer Mask
→ Matching

Character Light Mask
AND Environment Renderer Mask
→ Not Matching
```

Custom Shader에서 `light.layerMask`를 무시하면 Pipeline의 Light Layer 설정과 다른 결과가 생긴다.

URP Lit Shader의 Matching Helper를 참고한다.

---

## Indirect Diffuse

직접 Light가 닿지 않아도 Environment에서 흩어진 빛이 Surface에 들어올 수 있다.

```text
Indirect Diffuse Source
├─ Lightmap
├─ Light Probe
├─ Adaptive Probe Volume
└─ Ambient Probe
```

Normal 방향에 따라 Environment의 Diffuse Irradiance를 Sampling한다.

Material Base Color와 Energy 관계를 반영해 최종 Direct Diffuse에 더한다.

---

## Indirect Specular

간접 Specular는 Reflection Probe와 Sky Environment를 Sampling한다.

```text
Reflection Vector R
        │
        ▼
Reflection Probe / Sky Cubemap
        │
        ├─ Roughness에 맞는 Mip
        └─ Occlusion
        │
        ▼
Indirect Specular
```

URP는 `GlossyEnvironmentReflection()` 같은 Helper를 제공한다.

Smoothness가 높으면 선명한 Mip, Roughness가 높으면 흐린 Mip을 사용한다.

---

## Emission

Emission은 외부 Light 없이 Material 자체에서 나오는 Color다.

```text
Final Color
= Lighting
+ Emission
```

Emission을 Direct Shadow Attenuation에 곱하지 않는다.

HDR Emission은 Bloom과 결합해 빛나는 Visual을 만들 수 있다.

Emission이 주변 Object를 실제로 밝히려면 Baked GI 또는 별도 Realtime Light가 필요할 수 있다.

---

## Ambient Occlusion

Ambient Occlusion은 좁은 틈과 접촉 영역에서 Indirect Light가 덜 들어오는 효과를 근사한다.

```text
Open Surface
→ AO ≈ 1

Deep Crease
→ AO < 1
```

Material AO와 SSAO를 조합할 수 있다.

AO를 Direct Light 전체에 강하게 곱하면 현실보다 접힌 곳이 지나치게 검어질 수 있다.

URP의 Lighting Model이 Direct와 Indirect AO를 어떻게 분리하는지 따른다.

---

## 최종 Lighting 구조

```text
Surface Data
├─ Base Color
├─ Normal
├─ Specular / Metallic
├─ Smoothness
├─ Occlusion
└─ Emission
        │
        ▼
Direct Lighting Loop
├─ N dot L Diffuse
├─ View 기반 Specular
├─ Light Color
├─ Distance / Angle Attenuation
└─ Shadow Attenuation
        │
        +
Indirect Lighting
├─ Probe / Lightmap Diffuse
└─ Reflection Specular
        │
        + Emission
        ▼
HDR Surface Color
        │
        ▼
Fog / Post-processing / Tone Mapping
```

각 항목의 적용 순서를 명확히 나누면 Lighting Bug를 찾기 쉽다.

---

## Vertex Lighting

Lighting을 Fragment가 아니라 Vertex에서 계산할 수도 있다.

```text
Vertex Shader
├─ Light Direction
├─ N dot L
└─ Light Color 계산
        │
        ▼
Rasterizer가 Lighting을 보간
        │
        ▼
Fragment Shader
```

Pixel 수가 Vertex 수보다 훨씬 많으면 연산을 줄일 수 있다.

작은 Point Light와 Specular Highlight는 Vertex 사이에서 손실될 수 있다.

URP 일반 Forward의 Additional Light를 Per Vertex로 설정할 수 있다.

---

## Fragment Lighting

Fragment Lighting은 Pixel 후보마다 Normal과 View Direction을 사용한다.

```text
장점
├─ Normal Map Detail
├─ 작은 Local Light
├─ 정확한 Specular
└─ Screen별 Surface 변화

비용
└─ Fragment 수 × Light 수 × BRDF
```

Forward+와 Deferred의 Realtime Light는 Per-pixel Lighting을 중심으로 처리한다.

화면 해상도와 Overdraw가 비용에 직접 영향을 준다.

---

## Gouraud와 Phong Shading의 구분

용어가 Lighting Model과 Interpolation 방식에 혼용될 수 있다.

```text
Gouraud Shading
Vertex에서 Lighting Color 계산
→ Color 보간

Phong Shading
Normal 보간
→ Fragment에서 Lighting 계산

Phong Reflection Model
Reflection Vector 기반 Specular 수식
```

Phong Shading과 Phong Specular Model은 관련 있지만 같은 개념은 아니다.

어느 값을 보간하고 어디서 Lighting하는지 구분한다.

---

## Two-sided Surface

Backface를 Rendering하는 Material은 Normal 방향을 어떻게 처리할지 정해야 한다.

```text
Front Face
→ Original Normal

Back Face
→ Normal Flip 여부 결정
```

Normal을 Flip하지 않으면 Backface가 뒤쪽 Light만 받을 수 있다.

Thin Fabric, Leaf와 Hair의 Lighting Model은 단순 Flip보다 복잡할 수 있다.

Cull Off만 설정한다고 Two-sided Lighting이 자동으로 자연스러워지는 것은 아니다.

---

## Color Space

Lighting의 덧셈과 곱셈은 Linear Space에서 수행해야 Energy 관계가 자연스럽다.

```text
sRGB Texture Sample
        │ Decode
        ▼
Linear Color
        │ Lighting
        ▼
Linear HDR Color
        │ Display Encode
        ▼
sRGB Output
```

Base Color Texture는 일반적으로 sRGB로 Import하고 Normal·Mask Data Texture는 sRGB를 끈다.

Data Texture를 Gamma Decode하면 Normal과 Metallic 값이 왜곡된다.

---

## HDR Lighting

Realtime Light와 Emission을 더하면 Color가 1보다 커질 수 있다.

```text
Light A = 2.0
Light B = 1.5
Emission = 3.0
→ HDR Value > 1
```

Shader 중간 결과를 조기에 Saturate하면 밝기 차이와 Bloom 정보가 사라진다.

최종 Tone Mapping 전까지 HDR 범위를 유지한다.

Half Precision의 최대 범위와 Overflow도 Target GPU에서 확인한다.

---

## Fog 적용

Surface Lighting 이후 Camera Distance에 따라 Fog Color를 Blend할 수 있다.

```text
Lit Surface Color
        │
        + Fog Factor
        + Fog Color
        │
        ▼
Fogged Color
```

Custom Shader에서 Fog Keyword와 Helper를 빠뜨리면 Standard URP Material과 깊이감이 달라진다.

Transparent에도 Fog가 일관되게 적용되어야 한다.

---

## 전체 Vertex·Fragment 예제 구조

```hlsl
struct Attributes
{
    float4 positionOS : POSITION;
    float3 normalOS : NORMAL;
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    float3 positionWS : TEXCOORD0;
    float3 normalWS : TEXCOORD1;
};

Varyings vert(Attributes input)
{
    Varyings output;

    output.positionWS =
        TransformObjectToWorld(
            input.positionOS.xyz
        );

    output.positionCS =
        TransformWorldToHClip(
            output.positionWS
        );

    output.normalWS =
        TransformObjectToWorldNormal(
            input.normalOS
        );

    return output;
}
```

Vertex Shader는 World Position과 Normal, Clip Position을 준비한다.

---

## Fragment 예제 구조

```hlsl
half4 frag(Varyings input) : SV_Target
{
    float3 N = normalize(input.normalWS);
    float3 V =
        GetWorldSpaceNormalizeViewDir(
            input.positionWS
        );

    Light mainLight = GetMainLight();

    half3 direct = EvaluateDirectLight(
        _BaseColor.rgb,
        _SpecularColor.rgb,
        _Smoothness,
        N,
        V,
        mainLight
    );

    half3 finalColor =
        direct + _EmissionColor.rgb;

    return half4(finalColor, 1.0h);
}
```

Shadow, Additional Light, GI와 Fog를 생략한 최소 흐름이다.

---

## Lighting 순서 Debug

화면이 이상할 때 전체 수식을 한 번에 고치지 않는다.

```text
1. Base Color만 출력
2. World Normal을 Color로 출력
3. N dot L만 Grayscale 출력
4. Light Color 곱하기
5. Distance Attenuation 추가
6. Shadow Attenuation 추가
7. Specular 추가
8. Indirect와 Emission 추가
9. Fog 추가
```

단계별 결과를 확인하면 어느 입력이 틀렸는지 찾기 쉽다.

---

## Normal Debug Color

Normal은 -1에서 1 범위이므로 화면 Color로 보려면 0에서 1로 Remap한다.

```hlsl
half3 normalColor =
    normalize(normalWS) * 0.5h + 0.5h;

return half4(normalColor, 1.0h);
```

```text
X Normal → Red 계열
Y Normal → Green 계열
Z Normal → Blue 계열
```

예상 방향과 Color가 다르면 Space 변환, Tangent와 Normal Map을 확인한다.

---

## N dot L Debug

```hlsl
half NdotL = saturate(
    dot(normalize(normalWS),
        normalize(light.direction))
);

return half4(NdotL.xxx, 1.0h);
```

Light를 향한 Surface는 흰색, 옆면과 뒷면은 검게 보인다.

Light를 움직였는데 Pattern이 반대로 움직이면 Direction Convention을 확인한다.

---

## View Direction Debug

```hlsl
float3 V =
    GetWorldSpaceNormalizeViewDir(positionWS);

half3 viewColor = V * 0.5h + 0.5h;
return half4(viewColor, 1.0h);
```

Camera를 움직일 때 값이 바뀌어야 한다.

Object Space Position으로 계산했다면 Object Transform에 따라 잘못된 Pattern이 나타날 수 있다.

---

## Specular만 출력하기

```hlsl
float3 H = normalize(L + V);
half NdotH = saturate(dot(N, H));

half specular =
    pow(NdotH, shininess)
    * step(0.0h, dot(N, L));

return half4(specular.xxx, 1.0h);
```

Camera와 Light를 움직이며 Highlight가 예상 반사 방향에 나타나는지 확인한다.

Highlight가 Surface 뒤에도 생기면 NdotL Gate를 점검한다.

---

## Lighting이 반대로 보일 때

다음 항목을 확인한다.

- `L`이 Surface에서 Light 방향인가?
- `reflect()`에 `-L`을 전달해야 하는가?
- Normal과 Light가 같은 Space인가?
- Mirrored Transform에서 Tangent Sign이 맞는가?
- Normal Map의 Green Channel Convention이 맞는가?
- Backface Normal을 Flip해야 하는가?

```text
수식이 맞아도 Vector Convention이 다르면 결과는 틀린다.
```

---

## Surface가 너무 어두울 때

- Light Color와 Intensity가 0이 아닌가?
- `N · L`이 Negative인가?
- Distance Attenuation이 Range 밖에서 0인가?
- Shadow Attenuation이 0인가?
- Light Culling Mask와 Rendering Layer가 맞는가?
- Additional Light Keyword가 포함되어 있는가?
- Indirect Lighting을 생략했는가?
- Linear·sRGB Import가 올바른가?

Diffuse, Attenuation과 Shadow를 각각 화면에 출력해 원인을 분리한다.

---

## Highlight가 따라오지 않을 때

Specular가 Camera를 따라 변하지 않으면 View Direction이 빠졌을 수 있다.

```text
Diffuse
→ Camera 이동에 큰 변화 없음

Specular
→ Camera 이동에 따라 위치 변화
```

`V`를 Vertex에서 계산해 보간하면 넓은 Triangle에서 정밀도 차이가 날 수 있다.

정확한 Highlight가 중요하면 Fragment에서 World Position으로 View Direction을 계산한다.

---

## Point Light가 평평해 보일 때

모든 Fragment에 같은 Light Direction을 사용하면 Point Light가 Directional Light처럼 보인다.

```text
잘못된 방식
L = Constant Direction

Point Light
L = normalize(lightPositionWS - positionWS)
```

URP `GetAdditionalLight()`는 Surface World Position을 받아 Position별 Direction과 Attenuation을 제공한다.

올바른 `positionWS`를 전달해야 한다.

---

## Shadow만 이상할 때

Diffuse와 Specular 방향이 맞는데 Shadow만 어긋나면 Shadow Coordinate를 점검한다.

- World Position에서 변환했는가?
- Main과 Additional Light용 API를 구분했는가?
- Shadow Keyword Variant가 있는가?
- Camera Shadow Distance 안인가?
- Bias와 Normal Bias가 적절한가?
- Alpha Clip ShadowCaster가 Color Pass와 같은가?

Lighting 수식과 Shadow Map 생성은 서로 다른 Pass에 걸친다.

---

## 성능 비용의 구조

Forward Fragment Lighting의 비용을 단순화하면 다음과 같다.

```text
Cost
≈ Visible Fragments
× Light Count
× BRDF Complexity
+ Texture Samples
+ Shadow Samples
+ Reflection Samples
```

Overdraw가 높으면 화면에 남지 않는 Fragment도 Lighting할 수 있다.

Forward+ Cluster는 Light Count 후보를 줄이지만 실제 겹치는 Light의 BRDF는 계산해야 한다.

Deferred는 Surface Data와 Lighting 반복 축을 분리한다.

---

## Normalize 비용

Normalize는 Vector Length와 Reciprocal Square Root를 사용한다.

```text
normalize(v) = v / sqrt(dot(v, v))
```

필요한 Vector는 Normalize해야 하지만 같은 값을 Loop 안에서 반복하지 않는다.

```hlsl
float3 N = normalize(normalWS);
float3 V = normalize(viewDirectionWS);

// Light Loop 밖에서 한 번 준비
```

Light Direction은 URP가 Normalize된 형태로 제공하는지 API Contract를 확인한다.

---

## pow 비용

단순 Specular의 `pow(x, exponent)`는 Mobile Shader에서 상대적으로 비쌀 수 있다.

```text
Light 8개
× Pixel 1,000,000개
× pow 1회
→ 많은 반복
```

Look-up, Approximation 또는 낮은 비용의 Stylized Specular를 사용할 수 있다.

품질과 Target GPU의 Compiler 결과를 확인한다.

PBR Library는 Platform별 최적화된 BRDF Function을 제공할 수 있다.

---

## half와 float

```text
float
└─ 높은 Precision과 Range

half
└─ 낮은 Precision, Mobile에서 성능·Register 이점 가능
```

World Position과 큰 거리 계산에는 `float`가 안전하다.

정규화된 Color, Normal과 일부 Material 값은 `half`를 사용할 수 있다.

Specular Exponent와 HDR Intensity에서 Precision Artifact나 Overflow를 Test한다.

Desktop GPU에서는 `half`가 항상 성능 차이를 만들지는 않는다.

---

## Branch와 Light Loop

Rendering Layer, Shadow와 Material Feature는 Light Loop 안에 Branch를 만들 수 있다.

```text
Light Loop
├─ Layer Match?
├─ Shadow Enabled?
├─ Cookie Enabled?
└─ Specular Enabled?
```

GPU Thread가 서로 다른 Branch를 선택하면 Execution Efficiency가 낮아질 수 있다.

Shader Variant로 분리할지 Runtime Branch를 사용할지는 Build Size와 Runtime Cost의 Trade-off다.

---

## Light 수 최적화

- Light Range를 실제 영향 범위로 제한한다.
- 중요하지 않은 Realtime Light를 Bake한다.
- VFX Light를 Emission과 Bloom으로 대체한다.
- Shadow를 만드는 Light 수를 줄인다.
- 일반 Forward에서는 Per Object Limit을 조정한다.
- Forward+에서는 Cluster Light Complexity를 확인한다.
- Deferred에서는 Screen Light Overlap을 확인한다.

Light 하나는 Diffuse만 추가하는 것이 아니라 Shadow, Cookie와 Specular 비용을 함께 추가할 수 있다.

---

## Shader 계산 최적화

```text
Loop 밖
├─ Surface Texture Sampling
├─ N Normalize
├─ V 계산
├─ Base BRDF Parameter
└─ Indirect Lighting

Light Loop 안
├─ L
├─ NdotL
├─ Attenuation
├─ Shadow
└─ Light별 BRDF
```

Light와 관계없는 계산을 반복하지 않는다.

Profiler와 Shader Compiler 결과로 실제 병목을 확인한다.

---

## 자주 혼동하는 내용

### Normal은 Surface Position인가?

아니다.

Normal은 Surface가 향하는 방향을 나타내는 Vector다.

### Light Direction과 Light Position은 같은가?

아니다.

Point Light는 Position에서 Surface Position을 빼 Direction을 만든다.

### Dot Product는 Angle을 Degree로 반환하는가?

아니다.

단위 Vector의 Dot Product는 Angle의 Cosine 값을 반환한다.

### N dot L이 Negative여도 Diffuse에 사용해야 하는가?

일반적인 앞면 Diffuse에서는 0으로 제한한다.

### Diffuse는 Camera 위치에 따라 달라지는가?

이상적인 Lambert Diffuse는 View Direction에 의존하지 않는다.

### Specular는 Light Direction만으로 계산하는가?

아니다.

Normal과 Light Direction뿐 아니라 View Direction과 Surface Roughness가 필요하다.

### Shadow가 있으면 최종 Color 전체를 0으로 만드는가?

아니다.

해당 Direct Light 기여를 줄이며 Indirect, Reflection과 Emission은 남을 수 있다.

### Attenuation은 Light Color에 이미 모두 포함되는가?

URP `Light` 구조에서는 Color와 Distance·Shadow Attenuation이 별도 Field다.

### Normal Map은 Geometry를 실제로 울퉁불퉁하게 만드는가?

아니다.

Lighting에 사용할 Normal을 바꾸며 기본적으로 Silhouette와 Vertex Position은 바꾸지 않는다.

### 모든 Vector를 Normalize하지 않아도 Dot Product가 Angle을 의미하는가?

아니다.

길이가 포함되므로 두 방향 Vector를 단위 길이로 만들어야 한다.

### Lighting 결과는 항상 0에서 1 사이인가?

아니다.

HDR Rendering에서는 1보다 큰 값이 정상이며 Tone Mapping에서 Display 범위로 변환한다.

---

## 전체 구조 다시 연결하기

```text
Vertex Shader
├─ positionOS → positionWS → positionCS
├─ normalOS → normalWS
└─ Tangent Data 준비
        │
        ▼
Fragment Shader
├─ positionWS
├─ Normal Map → N
├─ Camera Position → V
└─ URP Light Data
   ├─ L
   ├─ Color
   ├─ Distance Attenuation
   ├─ Shadow Attenuation
   └─ Layer Mask
        │
        ▼
한 Light의 Direct Lighting
├─ Diffuse = BaseColor × saturate(N · L)
└─ Specular = View와 Reflection / Half Vector 관계
        │
        × Light Color
        × Distance Attenuation
        × Shadow Attenuation
        │
        ▼
여러 Light 기여 누적
        │
        + Indirect Diffuse
        + Indirect Specular
        + Emission
        │
        ▼
HDR Surface Color
        │
        ▼
Fog와 Post-processing
```

Lighting은 복잡해 보여도 방향 Vector, Material과 Visibility를 단계별로 결합하는 구조다.

---

## 정리

Shader Lighting은 Surface Position, Normal, Light Direction과 View Direction의 Vector 관계로 Surface가 Camera에 보일 Color를 계산한다.

```text
N = Surface Normal
L = Surface에서 Light로 향하는 방향
V = Surface에서 Camera로 향하는 방향
```

Diffuse는 `saturate(dot(N, L))`로 Light가 Surface 정면에 얼마나 가깝게 들어오는지 계산하며 Base Color와 Light Color에 곱한다.

Specular는 Reflection Vector와 View Direction 또는 Normal과 Half Vector의 관계를 계산하며 Smoothness가 Highlight의 폭과 집중도를 결정한다.

Point와 Spot Light는 Surface World Position으로 Direction과 Distance를 구하고 거리 및 Cone Angle에 따른 `distanceAttenuation`을 적용한다.

Shadow는 `shadowAttenuation`으로 해당 Direct Light의 Diffuse와 Specular 기여를 줄이며 Indirect Lighting과 Emission까지 무조건 제거하지 않는다.

URP의 `Light` 구조체는 Direction, Color, Distance Attenuation, Shadow Attenuation과 Layer Mask를 제공하고 `GetMainLight()`와 `GetAdditionalLight()`로 Data를 얻을 수 있다.

여러 Light가 있으면 Surface Data, Normal과 View Direction을 먼저 준비한 뒤 각 Light의 Diffuse·Specular 기여를 Loop로 누적한다.

Normal, Light와 View Vector는 같은 Coordinate Space에서 Normalize해야 하며 Normal Map은 TBN Basis를 통해 Tangent Space에서 World Space로 변환한다.

최종 Surface Color에는 Direct Lighting뿐 아니라 Lightmap·Probe의 Indirect Diffuse, Reflection의 Indirect Specular와 Emission이 더해지고 Fog와 Tone Mapping을 거쳐 화면에 출력된다.
