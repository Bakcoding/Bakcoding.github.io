---
title: "[Unity 렌더링] 7-2. Lambert Lighting이란?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - Shader
  - Lighting
  - Lambert
permalink: /programming/unity-7-2-lambert-lighting/
toc: true
toc_sticky: true
date: 2026-08-16
last_modified_at: 2026-08-16
---

Lambert Lighting은 빛이 Surface에 들어오는 각도에 따라 Diffuse 밝기를 계산하는 가장 기본적인 Lighting Model이다.

Surface가 Light를 정면으로 바라보면 가장 밝고, Light가 옆으로 기울수록 어두워지며, Light가 Surface 뒤에 있으면 Direct Diffuse를 만들지 않는다.

이 관계는 Surface Normal과 Light Direction의 Dot Product 하나로 표현할 수 있다.

```text
Lambert Diffuse = max(0, N · L)
```

`N`은 Surface Normal, `L`은 Surface에서 Light로 향하는 단위 Vector다.

여기에 Surface의 Albedo와 Light Color, 거리 및 Shadow 감쇠를 곱하면 한 Light가 만드는 Lambert Diffuse가 된다.

---

## Diffuse Reflection이란?

Diffuse Reflection은 Surface에 들어온 빛이 여러 방향으로 넓게 흩어지는 반사다.

매우 거친 Surface를 미세하게 확대하면 표면 방향이 제각각이므로 들어온 빛도 다양한 방향으로 반사된다.

```text
                 ↖  ↑  ↗
Incoming Light ──▶ Surface ──▶ Scattered Light
                 ↙  ↓  ↘
```

이상적인 Diffuse Surface는 어느 방향에서 바라보더라도 비슷한 밝기로 보인다.

Camera 방향에 따라 Highlight 위치가 바뀌는 Specular Reflection과 다른 점이다.

| 반사 종류 | 주로 사용하는 방향 | 보이는 특징 |
| --- | --- | --- |
| Diffuse | Normal, Light Direction | 넓고 부드러운 명암 |
| Specular | Normal, Light Direction, View Direction | 시점에 따라 움직이는 Highlight |

Lambert Model은 이 Diffuse Reflection을 단순한 수식으로 근사한다.

---

## Lambert Lighting이 필요한 이유

Light Color와 Surface Color만 곱하면 Object 전체가 같은 밝기로 출력된다.

```hlsl
half3 color = albedo * lightColor;
```

Sphere에 이 계산만 적용하면 앞면의 모든 Fragment가 같은 색이 되어 평평한 원처럼 보인다.

3D 형태를 드러내려면 Surface가 Light를 향하는 정도에 따라 밝기가 달라져야 한다.

```text
Light → → →

       밝음
      ╭────╮
  중간│    │어두움
      ╰────╯
       뒷면
```

Lambert Lighting은 Geometry의 방향 정보를 명암으로 바꾸어 Object의 입체감을 만든다.

---

## Surface Normal과 Light Direction

Lambert 계산에는 두 단위 Vector가 필요하다.

```text
N = normalize(Surface Normal)
L = normalize(Surface에서 Light로 향하는 Vector)
```

Normal은 Surface가 바라보는 방향이다.

Light Direction은 해당 Surface Point에서 Light가 있는 방향이다.

```text
             Light
               ●
              ↗
             L
            /
───────────●─────────── Surface
           ↑
           N
```

두 Vector는 같은 Coordinate Space에 있어야 한다.

`normalWS`와 `light.direction`을 사용한다면 둘 다 World Space여야 한다.

Object Space Normal과 World Space Light Direction을 곱하면 각도를 비교하는 의미가 사라진다.

---

## Vector를 Normalize하는 이유

Dot Product는 두 Vector의 길이와 각도를 함께 반영한다.

```text
A · B = |A| |B| cosθ
```

두 Vector의 길이가 1이면 길이 항이 사라진다.

```text
|N| = 1
|L| = 1

N · L = cosθ
```

이때 결과는 두 방향 사이 각도의 Cosine 값이 된다.

| 각도 | `cosθ` | 의미 |
| ---: | ---: | --- |
| 0° | 1 | Light가 Surface 정면에 있음 |
| 30° | 약 0.866 | 대부분의 빛을 받음 |
| 60° | 0.5 | 절반 정도의 밝기 |
| 90° | 0 | Light가 Surface와 평행함 |
| 180° | -1 | Light가 Surface 뒤에 있음 |

Normal이나 Light Direction의 길이가 1이 아니면 결과가 각도가 아니라 Vector 길이에 따라서도 변한다.

```hlsl
half3 N = normalize(normalWS);
half3 L = normalize(lightDirectionWS);
half NdotL = dot(N, L);
```

URP가 제공하는 방향도 함수 계약을 확인해야 하며, 보간된 Normal은 Fragment에서 다시 Normalize하는 편이 안전하다.

---

## 왜 Cosine으로 밝기를 계산할까?

Light가 Surface에 수직으로 들어오면 빛의 Energy가 작은 면적에 집중된다.

Light가 비스듬히 들어오면 같은 Energy가 더 넓은 면적에 퍼진다.

```text
정면 입사                   비스듬한 입사

↓↓↓↓                       ↘ ↘ ↘ ↘
────                       ────────
짧은 투영 면적              넓은 투영 면적
```

Surface가 Light 방향에 수직인 평면으로 얼마나 투영되는지가 Cosine에 비례한다.

```text
받는 빛의 비율 ∝ cosθ
```

Lambert의 Cosine Law는 이 기하학적 관계를 Diffuse 밝기로 사용한다.

Light가 60° 기울면 `cos(60°) = 0.5`이므로 정면일 때의 절반만큼 기여한다.

---

## Dot Product가 각도를 밝기로 바꾸는 과정

Dot Product를 성분으로 계산하면 다음과 같다.

```text
N · L
= NxLx + NyLy + NzLz
```

예를 들어 위쪽을 향하는 Surface가 있다.

```text
N = (0, 1, 0)
L = (0, 1, 0)

N · L
= 0×0 + 1×1 + 0×0
= 1
```

Light가 오른쪽 위 45° 방향에 있다면 다음과 같다.

```text
N = (0, 1, 0)
L = (0.707, 0.707, 0)

N · L
= 0×0.707 + 1×0.707 + 0×0
= 0.707
```

Light가 아래쪽에 있다면 결과가 음수가 된다.

```text
N = (0, 1, 0)
L = (0, -1, 0)

N · L = -1
```

이 음수는 Surface의 앞면에 음수 Color를 더하라는 뜻이 아니다.

Light가 Surface 뒤에 있다는 방향 관계를 나타낸다.

---

## 음수 값을 제거하는 이유

일반적인 Opaque Surface의 앞면은 뒤쪽에서 오는 Direct Light를 받지 않는다.

따라서 `N · L`의 음수 영역을 0으로 제한한다.

```hlsl
half NdotL = max(0.0h, dot(N, L));
```

HLSL의 `saturate`를 사용하면 값을 0과 1 사이로 제한할 수 있다.

```hlsl
half NdotL = saturate(dot(N, L));
```

```text
Raw N · L       Lambert 결과

  1 ┐             1 ┐
    │╲               │╲
  0 ┼─╲──          0 ┼─╲────────
    │  ╲              │
 -1 ┘   ╲             ┘

음수 영역          0으로 Clamp
```

`max(0, N·L)`은 흔히 Clamped Cosine Term이라고 부른다.

Two-sided Material이나 얇은 천처럼 뒷면 Lighting이 필요한 경우에는 별도의 Normal 처리나 Transmission Model이 필요하다.

단순히 `abs(dot(N, L))`를 사용하면 양면이 동일하게 빛나지만 실제 얇은 물체의 빛 투과를 표현하는 것은 아니다.

---

## Lambert Diffuse의 기본 수식

가장 단순한 Shader 표현은 다음과 같다.

```hlsl
half3 LambertDiffuse(
    half3 albedo,
    half3 normalWS,
    half3 lightDirectionWS,
    half3 lightColor)
{
    half3 N = normalize(normalWS);
    half3 L = normalize(lightDirectionWS);
    half NdotL = saturate(dot(N, L));

    return albedo * lightColor * NdotL;
}
```

각 항의 역할은 분리되어 있다.

```text
Albedo
  × Light Color
  × Angular Term max(0, N · L)
  = Direct Diffuse
```

| 항 | 결정하는 것 |
| --- | --- |
| `albedo` | Surface가 반사하는 기본 색 |
| `lightColor` | Light의 색과 강도 |
| `NdotL` | Surface가 Light를 향하는 정도 |

Red Surface에 White Light가 정면으로 들어오면 Red Diffuse가 출력된다.

Red Surface에 Blue Light가 들어오면 RGB 곱셈 결과가 매우 어두울 수 있다.

Material과 Light가 공유하는 파장 성분만 반사되기 때문이다.

---

## 엄밀한 Lambert BRDF

물리 기반 표현에서는 Lambert Diffuse BRDF를 다음처럼 쓴다.

```text
f_d = Albedo / π
```

Rendering Equation에 넣으면 한 Directional Light의 반사 Radiance는 개념적으로 다음과 같다.

```text
L_o = (Albedo / π) × L_i × max(0, N · L)
```

`1/π`는 반구 전체로 퍼지는 Diffuse Energy를 정규화한다.

Albedo가 1인 Surface가 들어온 Energy보다 더 많은 Energy를 반사하지 않도록 만드는 항이다.

하지만 간단한 고전 Lambert Shader나 일부 Helper는 `N·L`과 Light Color만 계산하고, `Albedo/π` 또는 Pipeline의 에너지 보정은 다른 단계에서 처리할 수 있다.

```text
고전적인 교육용 표현
Diffuse = Albedo × LightColor × NdotL

BRDF 관점 표현
Diffuse = (Albedo / π) × IncidentLight × NdotL
```

코드의 함수 이름이 Lambert라고 해서 어느 단계까지 포함하는지 단정하면 안 된다.

함수가 Albedo를 받는지, Light Color만 받는지, `1/π`를 적용하는지 실제 구현과 호출부를 함께 확인해야 한다.

---

## Albedo는 단순한 최종 Color가 아니다

Albedo는 Surface가 Diffuse로 반사하는 비율과 색을 나타낸다.

Lighting 이전의 재질 정보이며 Light 계산 결과와 곱해진다.

```text
Texture Sample
      │
      ▼
Base Color / Albedo
      │
      × Lambert Light
      ▼
Direct Diffuse Color
```

Texture에 이미 강한 그림자와 Highlight가 그려져 있으면 Realtime Lighting과 중복될 수 있다.

Lighting용 Albedo Texture는 가능한 한 조명 결과를 제거한 고유한 Surface Color를 담는 편이 일관적이다.

Metallic Workflow에서는 Metal 성분이 커질수록 Diffuse에 쓰이는 Base Color Energy가 줄고 Specular 쪽으로 이동한다.

따라서 PBR Shader의 최종 Diffuse는 단순 Lambert 예제보다 더 많은 Material 처리를 거친다.

---

## Light Color와 Intensity

Lambert Term `N·L`은 방향에 따른 비율만 계산한다.

실제 밝기와 색은 Light Data에서 온다.

```hlsl
half3 radiance = light.color * NdotL;
half3 diffuse = albedo * radiance;
```

HDR Rendering에서는 `light.color`가 1보다 큰 값을 가질 수 있다.

`NdotL`을 0과 1 사이로 제한해도 최종 Color까지 반드시 1 이하인 것은 아니다.

```text
NdotL = 0.8
Light Intensity가 반영된 Color = (4, 3, 2)

Light Contribution = (3.2, 2.4, 1.6)
```

HDR 값은 이후 Tone Mapping을 거쳐 Display 범위로 변환된다.

Lighting 중간 결과를 무조건 `saturate`하면 밝은 Light의 Energy와 Bloom에 필요한 값을 잃는다.

---

## 거리 감쇠와 Shadow 감쇠

Lambert의 각도 항만으로는 Point Light나 Shadow를 완성할 수 없다.

한 Light의 Direct Diffuse는 다음과 같이 구성할 수 있다.

```text
Direct Diffuse
= Albedo
 × Light Color
 × max(0, N · L)
 × Distance Attenuation
 × Shadow Attenuation
```

Point Light와 Spot Light는 거리가 멀수록 약해진다.

Spot Light는 Cone 바깥으로 갈수록 Angle Attenuation도 적용된다.

Shadow Map 결과는 Light가 해당 Surface까지 보이는 정도를 나타낸다.

```hlsl
half attenuation =
    light.distanceAttenuation *
    light.shadowAttenuation;

half3 diffuse =
    albedo *
    light.color *
    NdotL *
    attenuation;
```

Shadow가 0이라고 해서 Albedo나 Indirect Lighting까지 0으로 만들어야 하는 것은 아니다.

Shadow Attenuation은 해당 Direct Light의 기여를 줄이는 값이다.

---

## Directional Light의 Lambert 계산

Directional Light는 Scene 전체에서 방향이 일정하고 거리에 따른 감쇠가 없다.

```text
Light Rays
↘ ↘ ↘ ↘ ↘

Surface A의 L = Surface B의 L
```

URP에서 Main Light를 얻은 뒤 방향과 색을 사용할 수 있다.

```hlsl
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

Light mainLight = GetMainLight();

half3 N = normalize(normalWS);
half3 L = normalize(mainLight.direction);
half NdotL = saturate(dot(N, L));

half3 diffuse =
    albedo *
    mainLight.color *
    NdotL;
```

Shadow를 포함하려면 Shadow Coordinate를 준비하고 그에 맞는 `GetMainLight` Overload를 사용해야 한다.

```hlsl
float4 shadowCoord = TransformWorldToShadowCoord(positionWS);
Light mainLight = GetMainLight(shadowCoord);

half attenuation =
    mainLight.distanceAttenuation *
    mainLight.shadowAttenuation;
```

필요한 Shader Keyword와 ShadowCaster Pass까지 갖춰야 실제 URP Shadow와 일치한다.

---

## Point Light의 Lambert 계산

Point Light는 Surface Position마다 Light Direction이 달라진다.

```text
              Point Light
                   ●
              ↙    ↓    ↘
            A      B      C

A, B, C의 Light Direction이 서로 다름
```

개념적으로 Light Position에서 Surface Position을 빼서 방향을 구한다.

```hlsl
float3 lightVector = lightPositionWS - positionWS;
float distanceToLight = length(lightVector);
half3 L = lightVector / distanceToLight;
```

그 뒤 같은 Lambert Term을 적용한다.

```hlsl
half NdotL = saturate(dot(normalize(normalWS), L));
```

URP의 `GetAdditionalLight`는 Surface의 World Position을 받아 해당 위치의 방향과 거리 감쇠가 반영된 Light Data를 돌려준다.

```hlsl
Light light = GetAdditionalLight(lightIndex, positionWS);
```

직접 거리 감쇠 공식을 중복 구현하기보다 Pipeline이 제공하는 `distanceAttenuation`을 사용하는 편이 URP 설정과 일치한다.

---

## URP의 LightingLambert 함수

Unity 6 URP의 Lighting Shader Library는 Lambert 계산용 Helper를 제공한다.

```hlsl
half3 LightingLambert(
    half3 lightColor,
    half3 lightDirection,
    half3 surfaceNormal);
```

사용할 때는 `Lighting.hlsl`을 Include한다.

```hlsl
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
```

Main Light의 기본 Lambert 결과는 다음처럼 얻을 수 있다.

```hlsl
Light mainLight = GetMainLight();

half3 lambertLight = LightingLambert(
    mainLight.color,
    mainLight.direction,
    normalize(normalWS));

half3 diffuse = albedo * lambertLight;
```

`LightingLambert`는 Light Color와 Direction, Surface Normal을 입력받는다.

Albedo를 입력받지 않으므로 Material Color는 호출부에서 곱한다.

Distance와 Shadow Attenuation도 호출 흐름에 맞춰 별도로 결합해야 한다.

```hlsl
half attenuation =
    mainLight.distanceAttenuation *
    mainLight.shadowAttenuation;

half3 diffuse =
    albedo *
    lambertLight *
    attenuation;
```

Package Version에 따라 내부 구현은 달라질 수 있으므로 프로젝트가 실제 사용하는 URP Package의 `ShaderLibrary/Lighting.hlsl`도 확인하는 편이 정확하다.

---

## Main Light 하나를 계산하는 함수

Lambert 계산을 Material과 Light Data까지 포함해 분리할 수 있다.

```hlsl
half3 EvaluateLambertLight(
    half3 albedo,
    half3 normalWS,
    Light light)
{
    half3 N = normalize(normalWS);

    half3 lambert = LightingLambert(
        light.color,
        light.direction,
        N);

    half attenuation =
        light.distanceAttenuation *
        light.shadowAttenuation;

    return albedo * lambert * attenuation;
}
```

Fragment Shader에서는 Light를 얻고 함수를 호출한다.

```hlsl
half4 frag(Varyings input) : SV_Target
{
    half3 albedo = SAMPLE_TEXTURE2D(
        _BaseMap,
        sampler_BaseMap,
        input.uv).rgb * _BaseColor.rgb;

    float4 shadowCoord =
        TransformWorldToShadowCoord(input.positionWS);

    Light mainLight = GetMainLight(shadowCoord);

    half3 diffuse = EvaluateLambertLight(
        albedo,
        input.normalWS,
        mainLight);

    return half4(diffuse, 1.0h);
}
```

이 결과에는 Main Light의 Direct Diffuse만 들어 있다.

Ambient, Light Probe, Lightmap, Additional Light와 Specular는 별도로 더해야 한다.

---

## 여러 Light의 Lambert 결과

여러 Light가 Surface에 영향을 주면 각 Light의 Diffuse 기여를 더한다.

```text
Total Direct Diffuse
= Main Light Lambert
 + Additional Light 0 Lambert
 + Additional Light 1 Lambert
 + ...
```

개념적인 Loop는 다음과 같다.

```hlsl
half3 totalDiffuse = 0.0h;

Light mainLight = GetMainLight(shadowCoord);
totalDiffuse += EvaluateLambertLight(
    albedo,
    normalWS,
    mainLight);

uint lightCount = GetAdditionalLightsCount();

for (uint i = 0u; i < lightCount; ++i)
{
    Light light = GetAdditionalLight(i, positionWS);

    totalDiffuse += EvaluateLambertLight(
        albedo,
        normalWS,
        light);
}
```

실제 URP에서는 Forward와 Forward+의 Additional Light 순회 방식이 다르다.

Forward+에서는 단순히 `GetAdditionalLightsCount()`만 사용하는 Loop로 모든 Light를 처리할 수 없으므로 URP의 공식 Light Loop Macro와 Keyword 구성을 따라야 한다.

Light 수가 늘면 Fragment마다 Lambert 계산과 Shadow Sampling이 반복된다.

Lambert 수식 자체는 가볍지만 Light Loop 전체 비용은 Light 수와 화면 Coverage에 비례한다.

---

## Vertex Lambert와 Fragment Lambert

Lambert Lighting은 Vertex Shader나 Fragment Shader에서 계산할 수 있다.

### Vertex Lighting

각 Vertex에서 밝기를 계산하고 Triangle 내부로 보간한다.

```text
Vertex A: 1.0 ───────── Vertex B: 0.4
             보간
                 ╲
                  Vertex C: 0.1
```

장점은 Fragment마다 Light 계산을 반복하지 않아 비용이 낮다는 점이다.

단점은 Vertex 사이의 Lighting 변화를 정확히 표현하지 못한다는 점이다.

작은 Point Light의 밝은 영역이 Vertex 사이에만 있으면 Highlight가 사라질 수 있다.

### Fragment Lighting

보간된 Normal과 Position을 사용해 Fragment마다 Lambert를 계산한다.

```text
Interpolated Normal / Position
            │
            ▼
     Fragment N · L
            │
            ▼
       Pixel Color
```

곡면과 Local Light의 변화가 더 부드럽지만 화면을 많이 차지하는 Object에서는 계산 횟수가 증가한다.

| 방식 | 계산 횟수 기준 | 품질 | 적합한 경우 |
| --- | --- | --- | --- |
| Vertex Lambert | Vertex 수 | 낮거나 중간 | 먼 Object, 단순한 Lighting |
| Fragment Lambert | Fragment 수 | 높음 | 가까운 Object, Normal Map, Local Light |

Normal Map은 Texture를 Fragment에서 Sample하고 Normal을 변경하므로 일반적으로 Fragment Lighting과 결합한다.

---

## 보간된 Normal을 다시 Normalize해야 하는 이유

Triangle의 각 Vertex Normal이 단위 Vector여도 선형 보간된 결과의 길이는 1이 아닐 수 있다.

```text
Vertex A Normal ↖       Vertex B Normal ↗
                ╲       ╱
                 Fragment Normal
```

방향이 다른 두 단위 Vector의 중간값은 보통 단위 길이보다 짧다.

```hlsl
half3 N = normalize(input.normalWS);
```

Normalize하지 않으면 `N·L`에 Normal 길이가 섞여 곡면 중앙이 필요 이상으로 어두워질 수 있다.

Vertex 단계에서만 Normalize했는지가 아니라 Lambert Dot Product 직전의 Vector 상태가 중요하다.

---

## Normal Map과 Lambert Lighting

Normal Map은 실제 Vertex를 움직이지 않고 Fragment의 Normal 방향을 바꾼다.

```text
평평한 Geometry Normal
↑ ↑ ↑ ↑ ↑

Normal Map 적용 후
↖ ↑ ↗ ↙ ↑
```

Lambert는 변경된 Normal로 `N·L`을 계산하므로 작은 요철처럼 명암이 생긴다.

```hlsl
half3 normalTS = UnpackNormal(
    SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, input.uv));

half3 normalWS = normalize(
    TransformTangentToWorld(normalTS, tangentToWorld));

half NdotL = saturate(
    dot(normalWS, light.direction));
```

Normal Map의 값은 보통 Tangent Space에 있으므로 Light Direction과 곧바로 Dot Product하면 안 된다.

TBN Basis를 사용해 Normal을 World Space로 옮기거나 Light Direction을 Tangent Space로 옮겨야 한다.

Normal Scale이 지나치게 크면 Lambert 명암이 급격하게 끊기고 Surface가 실제보다 거칠어 보일 수 있다.

---

## Lambert만 적용하면 Shadow 영역이 검게 보이는 이유

Lambert는 Direct Light의 Diffuse 항이다.

Surface가 Light 반대편을 향하면 `N·L`이 0이므로 결과도 0이다.

```text
Direct Lambert Only

Light-facing Side  → 밝음
Opposite Side      → 0
```

현실에서는 Sky와 주변 Surface에서 반사된 Indirect Light가 어두운 면에도 도달한다.

Unity에서는 Lightmap, Light Probe, Adaptive Probe Volume, Ambient Probe 등이 이 역할을 담당할 수 있다.

```text
Final Diffuse
= Direct Lambert
 + Baked / Probe Indirect Diffuse
```

단순히 어두운 면을 밝히려고 Lambert 결과에 임의의 상수를 더하면 방향성과 Scene Lighting이 맞지 않을 수 있다.

Stylized Rendering이 목적이라면 의도적인 Ambient Term으로 사용할 수 있지만 물리적인 Indirect Lighting과는 구분해야 한다.

---

## Half-Lambert란?

Half-Lambert는 `N·L` 범위를 이동하고 축소해 뒤쪽 Surface도 완전히 검게 되지 않도록 만든 비물리적 변형이다.

대표적인 형태는 다음과 같다.

```text
Half Lambert = N · L × 0.5 + 0.5
```

필요에 따라 제곱해 Contrast를 조절한다.

```hlsl
half halfLambert = dot(N, L) * 0.5h + 0.5h;
halfLambert *= halfLambert;
```

| `N·L` | Clamped Lambert | 기본 Half-Lambert |
| ---: | ---: | ---: |
| 1 | 1 | 1 |
| 0 | 0 | 0.5 |
| -1 | 0 | 0 |

Half-Lambert는 90°에서 이미 0.5의 값을 가지므로 Terminator가 부드럽고 Character의 어두운 면을 읽기 쉽다.

하지만 Light 뒤쪽에도 밝기가 생기므로 Energy Conservation을 만족하는 Lambert BRDF가 아니다.

```text
Lambert                 Half-Lambert

밝음 → 중간 → 0         밝음 → 중간 → 약한 밝기
         Terminator               부드러운 전환
```

현실적인 Lighting의 대체재라기보다 Stylized Shading을 위한 Remapping으로 보는 편이 정확하다.

---

## Toon Shading으로 확장하기

Lambert의 `N·L`은 0에서 1 사이의 연속적인 밝기 값이다.

이 값을 몇 단계로 양자화하면 Toon Shading의 기본 명암을 만들 수 있다.

```hlsl
half NdotL = saturate(dot(N, L));
half bands = 3.0h;
half toon = floor(NdotL * bands) / (bands - 1.0h);
```

또는 Ramp Texture를 Sample한다.

```hlsl
half NdotL = saturate(dot(N, L));
half3 ramp = SAMPLE_TEXTURE2D(
    _RampTex,
    sampler_RampTex,
    float2(NdotL, 0.5h)).rgb;
```

```text
N · L
  │
  ├─ 그대로 사용 ── Lambert
  ├─ 범위 이동 ──── Half-Lambert
  └─ 단계화 / Ramp ─ Toon Shading
```

입력은 같은 Normal과 Light Direction이지만 값을 어떻게 Mapping하는지에 따라 Visual Style이 달라진다.

---

## Gamma Space에서 계산하면 생기는 문제

Lighting은 빛의 Energy를 더하고 곱하는 계산이므로 Linear Space에서 수행해야 한다.

Gamma Encoding된 Color 값은 Display 저장을 위한 비선형 값이다.

Gamma 값에서 `Albedo × Light`를 계산하면 중간 밝기가 물리적인 Energy 관계와 달라진다.

```text
sRGB Texture
    │ Decode
    ▼
Linear Albedo
    │ × Linear Light
    ▼
Linear Lighting Result
    │ Tone Mapping / Encode
    ▼
Display
```

Unity의 Linear Color Space와 올바른 Texture Import 설정을 사용하면 Pipeline이 필요한 변환을 처리한다.

Normal Map과 Mask Texture는 Color Albedo와 데이터 의미가 다르므로 sRGB 설정도 구분해야 한다.

---

## Lambert 결과를 디버깅하는 방법

최종 Material을 한 번에 확인하면 어느 입력이 잘못되었는지 찾기 어렵다.

중간 값을 화면에 직접 출력하면 문제를 분리할 수 있다.

### World Normal 출력

Normal의 `-1~1` 범위를 `0~1`로 옮긴다.

```hlsl
half3 debugNormal = normalWS * 0.5h + 0.5h;
return half4(debugNormal, 1.0h);
```

### Raw Dot Product 출력

음수까지 보기 위해 범위를 Remap한다.

```hlsl
half rawNdotL = dot(normalize(normalWS), normalize(lightDirectionWS));
half debugDot = rawNdotL * 0.5h + 0.5h;
return half4(debugDot.xxx, 1.0h);
```

### Clamped Lambert 출력

```hlsl
half NdotL = saturate(dot(N, L));
return half4(NdotL.xxx, 1.0h);
```

### Attenuation 출력

```hlsl
half attenuation =
    light.distanceAttenuation *
    light.shadowAttenuation;

return half4(attenuation.xxx, 1.0h);
```

```text
Normal 확인
   ↓
Light Direction 확인
   ↓
N · L 확인
   ↓
Distance Attenuation 확인
   ↓
Shadow Attenuation 확인
   ↓
Albedo와 Light Color 결합
```

이 순서로 보면 좌표계 오류와 Shadow 설정 문제를 빠르게 구분할 수 있다.

---

## 자주 생기는 문제

### 밝은 면과 어두운 면이 반대로 나온다

Light Direction의 정의가 반대일 가능성이 크다.

어떤 함수는 Surface에서 Light로 향하는 방향을 주고, 어떤 데이터는 Light Ray가 진행하는 방향을 줄 수 있다.

```hlsl
dot(N, L)
dot(N, -L)
```

부호를 임의로 바꾸기 전에 API와 변수의 방향 정의를 확인해야 한다.

URP의 `Light.direction`은 URP Helper가 기대하는 방식으로 그대로 전달할 수 있다.

### Scale을 바꾸면 명암이 이상해진다

Non-uniform Scale에서 Normal을 Position처럼 변환했을 가능성이 있다.

URP의 Normal Transform Helper를 사용하고 변환 후 Normalize한다.

### Triangle 경계가 보인다

Mesh Normal이 Face마다 분리된 Flat Shading 상태이거나 Smoothing 설정이 의도와 다를 수 있다.

Normal Map의 압축 품질과 Tangent도 확인해야 한다.

### Object가 지나치게 검다

Direct Lambert만 출력하고 Indirect Diffuse를 더하지 않았을 수 있다.

Light Color, Exposure, Shadow Attenuation과 Albedo Color Space도 함께 확인한다.

### Point Light가 거리에 따라 줄지 않는다

Lambert Term만 적용하고 `distanceAttenuation`을 빠뜨렸을 수 있다.

`N·L`은 각도만 나타내며 거리 정보는 포함하지 않는다.

### Shadow 안에서도 밝다

`shadowAttenuation`을 곱하지 않았거나 Shadow Keyword와 Coordinate가 준비되지 않았을 수 있다.

Material의 Receive Shadows 설정과 Light의 Shadow 설정도 확인한다.

---

## Lambert Lighting의 비용

한 번의 기본 Lambert 계산은 가볍다.

```text
Normalize
Dot Product
Clamp
Color Multiply
```

실제 비용은 Lambert 수식보다 주변 조건에서 커지는 경우가 많다.

| 비용 요인 | 증가하는 작업 |
| --- | --- |
| Additional Light 증가 | Light Loop 반복 |
| Per-pixel Lighting | Fragment마다 계산 |
| Normal Map | Texture Sample과 TBN 변환 |
| Realtime Shadow | Shadow Map Sample과 비교 |
| 넓은 화면 Coverage | 실행되는 Fragment 증가 |
| Transparent Overdraw | 같은 Pixel의 반복 실행 |

`dot` 하나를 줄이는 Micro Optimization보다 불필요한 Light 수와 Shadow Light 수를 줄이는 것이 효과가 큰 경우가 많다.

---

## 최적화 관점

### Light 범위를 제한한다

Point와 Spot Light의 Range가 넓으면 더 많은 Object와 Screen Tile에 영향을 준다.

시각적으로 필요한 범위까지만 설정한다.

### 중요하지 않은 Light는 Shadow를 끈다

Lambert 계산은 저렴하지만 Realtime Shadow는 별도의 Shadow Map Rendering과 Sample을 요구한다.

모든 Light가 Shadow를 만들 필요는 없다.

### Vertex Lighting을 선택적으로 사용한다

멀리 있거나 작은 Object는 Vertex 단위 Additional Light로 충분할 수 있다.

가까운 곡면과 Normal Map Material은 Fragment Lighting을 유지한다.

### Baked Lighting과 Probe를 활용한다

움직이지 않는 Lighting을 Lightmap으로 Bake하면 Realtime Light Loop 비용을 줄일 수 있다.

Dynamic Object는 Light Probe나 APV로 간접광을 받을 수 있다.

### Shader Variant를 관리한다

Main Light Shadow, Additional Light, Soft Shadow와 Forward+ Keyword 조합은 Variant를 늘린다.

프로젝트에서 사용하지 않는 기능을 URP Asset과 Shader 설정에서 정리한다.

### 계산 정밀도를 구분한다

Color와 Normal의 일부 계산에는 `half`가 충분할 수 있다.

World Position이나 큰 좌표 범위처럼 오차에 민감한 값은 `float`가 안전하다.

정밀도 변경은 Target GPU에서 Artifact와 성능을 함께 측정해야 한다.

---

## Lambert Lighting의 한계

Lambert는 빠르고 이해하기 쉽지만 모든 Surface를 정확히 표현하지는 않는다.

### View Direction을 사용하지 않는다

Camera가 움직여도 같은 Surface Point의 Diffuse 밝기는 변하지 않는다.

이는 이상적인 Diffuse 가정에는 맞지만 Specular Highlight는 만들 수 없다.

### 모든 거친 Surface가 동일하지는 않다

실제 Surface는 Roughness, 미세 구조, Subsurface Scattering과 Retroreflection 같은 성질을 가진다.

Oren-Nayar 같은 Diffuse Model은 거친 Surface의 방향성을 더 자세히 다룬다.

### Energy 분배가 Material Workflow와 연결되지 않는다

단순 `Albedo × NdotL`은 Metallic과 Fresnel에 따른 Diffuse·Specular Energy 분배를 처리하지 않는다.

PBR에서는 Diffuse와 Specular를 독립적으로 무제한 더하지 않고 Material 특성에 따라 Energy를 나눈다.

### 간접광을 만들지 않는다

Lambert Term은 한 Light가 Surface에 직접 들어오는 각도를 계산할 뿐이다.

Bounce Light, Color Bleeding과 Environment Lighting은 GI 또는 Probe 계열 데이터가 필요하다.

---

## Lambert와 PBR의 관계

PBR이 Lambert를 완전히 버린 것은 아니다.

많은 PBR Model은 Diffuse Lobe의 기반으로 Lambert 또는 Lambert에 가까운 근사를 사용하고, 여기에 Microfacet Specular와 Energy Conservation을 결합한다.

```text
PBR Direct Lighting

Diffuse BRDF
  └─ Lambert 계열 또는 개선 Model

Specular BRDF
  └─ Distribution × Geometry × Fresnel
```

Lambert를 이해하면 PBR Shader에서도 `N·L`이 왜 반복해서 등장하는지 연결된다.

`N·L`은 Diffuse Color 자체만이 아니라 Light가 Surface에 들어오는 기하학적 가중치로 여러 BRDF 계산에 포함된다.

---

## 흔한 오해

### Lambert는 Light Color까지 포함한 하나의 고정 수식이다

Lambert의 핵심은 Cosine Law와 이상적인 Diffuse 가정이다.

Helper Function마다 Albedo, Light Color, `1/π`, Attenuation을 포함하는 범위는 다를 수 있다.

### `N·L`이 0.5면 각도가 45°다

`cos(60°) = 0.5`이므로 각도는 60°다.

Dot Product 결과는 각도에 선형으로 대응하지 않는다.

### Lambert가 어두우면 `N·L`에 상수를 더하면 된다

상수를 더하면 물리적인 Direct Diffuse가 아니라 Stylized Lighting이 된다.

Scene의 어두운 면을 자연스럽게 밝히려면 Indirect Lighting 상태를 먼저 확인한다.

### `saturate`는 최종 HDR Color에도 항상 필요하다

`saturate`는 Angular Term의 음수를 제거하는 데 유용하다.

최종 Lighting Color까지 제한하면 HDR Intensity와 후처리 정보가 사라진다.

### Lambert는 항상 성능 문제가 없다

수식 하나는 가볍지만 많은 Additional Light와 Shadow가 결합되면 Light Loop 비용이 커진다.

Model의 복잡도뿐 아니라 실행 횟수도 함께 봐야 한다.

---

## 전체 처리 흐름

Lambert Direct Diffuse가 만들어지는 흐름은 다음과 같다.

```text
Vertex Position / Normal
          │
          ▼
World Position / World Normal
          │
          ├──────────────┐
          │              │
          ▼              ▼
     Light Data       Albedo Sample
Direction / Color         │
Distance / Shadow         │
          │              │
          ▼              │
 normalize(N), normalize(L)
          │              │
          ▼              │
 saturate(dot(N, L))      │
          │              │
          └──────┬───────┘
                 ▼
 Albedo × Light Color × NdotL
 × Distance × Shadow Attenuation
                 │
                 ▼
        Direct Lambert Diffuse
                 │
                 ├─ Add Indirect Diffuse
                 ├─ Add Specular
                 └─ Add Emission
                 │
                 ▼
             Final Color
```

Lambert는 이 전체 흐름에서 Light Direction과 Surface Normal의 각도를 Direct Diffuse 가중치로 바꾸는 역할을 한다.

---

## 정리

Lambert Lighting은 Surface Normal과 Light Direction 사이의 Cosine을 사용해 Direct Diffuse 밝기를 계산하는 Lighting Model이다.

두 Vector를 같은 Coordinate Space에서 Normalize하면 `N·L`은 두 방향 사이 각도의 Cosine이 된다.

`max(0, N·L)` 또는 `saturate(N·L)`은 Surface 뒤에서 오는 Light의 음수 기여를 제거한다.

Light가 Surface 정면에 있을 때 값은 1이고, 60°에서는 0.5이며, 90° 이상에서는 Clamped Lambert 결과가 0이다.

최종 Direct Diffuse는 Albedo, Light Color, Lambert Term, Distance Attenuation과 Shadow Attenuation을 결합해 만든다.

물리 기반 Lambert BRDF는 Diffuse Energy를 반구에 정규화하기 위해 `Albedo/π`를 사용하지만 Helper마다 포함하는 계산 범위는 다르다.

Unity 6 URP는 `Lighting.hlsl`의 `LightingLambert`를 제공하며 Albedo와 감쇠는 호출 흐름에 맞게 별도로 결합한다.

여러 Light가 있으면 각 Lambert 기여를 누적하고, Forward와 Forward+에 맞는 Light Loop 구성을 사용해야 한다.

Vertex Lambert는 저렴하지만 Lighting 변화가 단순하고, Fragment Lambert는 Normal Map과 Local Light를 더 정확히 표현한다.

Half-Lambert와 Toon Ramp는 `N·L`을 다른 범위로 Mapping한 Stylized 기법이며 물리적인 Lambert와 구분해야 한다.

Lambert 수식 자체보다 Additional Light 수, Shadow, Normal Map, 화면 Coverage와 Overdraw가 실제 성능 비용을 크게 만들 수 있다.
