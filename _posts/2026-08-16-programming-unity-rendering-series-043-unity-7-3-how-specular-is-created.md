---
title: "[Unity 렌더링] 7-3. Specular는 어떻게 만들어질까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - Shader
  - Lighting
  - Specular
permalink: /programming/unity-7-3-how-specular-is-created/
toc: true
toc_sticky: true
date: 2026-08-16
last_modified_at: 2026-08-16
---

Specular는 Surface에서 특정 방향으로 집중되어 반사된 빛이 Camera에 들어올 때 보이는 밝은 반사 영역이다.

Diffuse는 주로 Normal과 Light Direction의 관계로 결정되지만 Specular는 View Direction까지 필요하다.

```text
Diffuse  = Normal + Light Direction
Specular = Normal + Light Direction + View Direction
```

Camera나 Light가 움직이면 이 세 방향의 관계가 바뀌므로 Highlight도 Surface 위를 이동한다.

고전적인 Shader에서는 Reflection Vector 또는 Half Vector를 만들고 View Direction과 얼마나 가까운지 계산해 Specular를 근사한다.

---

## Specular Reflection이란?

Specular Reflection은 들어온 빛이 특정 방향을 중심으로 반사되는 현상이다.

완벽하게 매끄러운 Mirror Surface에서는 입사각과 반사각이 같다.

```text
             N
             ↑
 Incoming  ↘ │ ↗  Reflected
       Light │
─────────────●───────────── Surface
             │

       입사각 = 반사각
```

실제 Surface는 미세한 요철을 가지므로 반사광이 하나의 방향에만 모이지 않고 주변으로 퍼진다.

```text
Smooth Surface            Rough Surface

      ↗                         ↑ ↗ →
──────●──────             ──────●──────
좁고 선명한 반사           넓고 흐린 반사
```

이 퍼짐의 정도가 Highlight의 크기와 선명도를 만든다.

---

## Diffuse와 무엇이 다를까?

이상적인 Lambert Diffuse는 빛을 반구 방향으로 균일하게 흩어 보낸다.

따라서 Surface와 Light 관계가 같다면 Camera 위치가 바뀌어도 Diffuse 밝기는 같다.

Specular는 반사 방향 가까이에 Camera가 있을 때 강해진다.

| 구분 | Diffuse | Specular |
| --- | --- | --- |
| 반사 형태 | 넓게 분산 | 특정 방향에 집중 |
| 주요 Vector | `N`, `L` | `N`, `L`, `V` |
| Camera 이동 영향 | 이상적인 Lambert에서는 없음 | Highlight 위치와 밝기가 변함 |
| Material 정보 | Albedo | Specular Color, Smoothness/Roughness |
| 보이는 특징 | Object의 기본 명암 | 광택과 재질 단서 |

같은 색과 Geometry를 가진 Object도 Specular의 폭과 강도가 다르면 플라스틱, 고무, 금속처럼 서로 다른 재질로 인식된다.

---

## 계산에 필요한 Vector

한 Surface Point에서 다음 Vector를 준비한다.

```text
N = Surface Normal
L = Surface에서 Light로 향하는 방향
V = Surface에서 Camera로 향하는 방향
```

```text
              Light
                ●
               ↗ L
              /
─────────────●──────────── Surface
             ↑╲
             N ╲ V
                ↘ Camera
```

세 Vector는 같은 Coordinate Space에서 비교하고 단위 길이로 Normalize해야 한다.

```hlsl
half3 N = normalize(normalWS);
half3 L = normalize(lightDirectionWS);
half3 V = normalize(viewDirectionWS);
```

World Space Normal과 View Space Light Direction을 Dot Product하면 기하학적 의미가 없다.

---

## View Direction은 어떻게 만들까?

Perspective Camera에서는 Surface Position에서 Camera Position을 빼서 View Direction을 만든다.

```hlsl
float3 viewDirectionWS = normalize(
    cameraPositionWS - positionWS);
```

URP Helper를 사용할 수도 있다.

```hlsl
half3 V = GetWorldSpaceNormalizeViewDir(positionWS);
```

```text
Camera Position - Surface Position
                 │
                 ▼
           View Vector
                 │ Normalize
                 ▼
          View Direction V
```

Perspective Camera에서는 Fragment마다 Camera까지의 방향이 다르다.

Orthographic Camera에서는 투영 Ray가 평행하므로 Pipeline Helper를 사용하는 편이 Projection 차이를 안전하게 처리한다.

---

## Light Direction의 부호

Specular 계산에서는 Light Direction의 정의가 특히 중요하다.

`L`을 Surface에서 Light로 향하는 방향으로 정의하면 실제 입사 Ray의 진행 방향은 `-L`이다.

```text
L  : Surface → Light
-L : Light → Surface
```

HLSL `reflect(I, N)`은 Surface로 들어오는 Incident Vector `I`를 받는다.

따라서 `L`이 Surface에서 Light로 향한다면 다음처럼 사용한다.

```hlsl
half3 R = reflect(-L, N);
```

`reflect(L, N)`을 사용하면 반사 방향이 반대로 나와 Highlight가 잘못된 위치에 생길 수 있다.

---

## Reflection Vector는 어떻게 만들어질까?

Incident Vector `I`를 Normal `N`에 대해 반사한 Vector는 다음 수식으로 구할 수 있다.

```text
R = I - 2(N · I)N
```

`I = -L`을 대입하면 다음 관계가 된다.

```text
R = reflect(-L, N)
```

```text
                 N
                 ↑
   I = -L      ↘ │ ↗ R
                 │
─────────────────●─────────────────
```

Reflection Vector가 View Direction과 같으면 반사광이 Camera를 정확히 향한다.

```hlsl
half3 R = reflect(-L, N);
half RdotV = saturate(dot(R, V));
```

| `R·V` | 의미 |
| ---: | --- |
| 1 | Camera가 완전한 반사 방향에 있음 |
| 0에 가까움 | Camera가 반사 방향에서 크게 벗어남 |
| 음수 | 반사 방향의 반대쪽에 있음 |

`R·V`만 사용하면 Highlight가 너무 넓으므로 거듭제곱으로 모양을 조절한다.

---

## Phong Specular Model

Phong Specular는 Reflection Vector와 View Direction의 Dot Product를 사용한다.

```text
Phong Specular
= pow(max(0, R · V), Shininess)
```

HLSL로 표현하면 다음과 같다.

```hlsl
half PhongSpecular(
    half3 normalWS,
    half3 lightDirectionWS,
    half3 viewDirectionWS,
    half shininess)
{
    half3 N = normalize(normalWS);
    half3 L = normalize(lightDirectionWS);
    half3 V = normalize(viewDirectionWS);

    half3 R = reflect(-L, N);
    half RdotV = saturate(dot(R, V));

    return pow(RdotV, shininess);
}
```

이 함수는 Specular의 모양만 계산한다.

최종 결과에는 Light Color, Specular Color와 감쇠를 곱한다.

---

## 거듭제곱이 Highlight 폭을 바꾸는 이유

0과 1 사이의 값을 1보다 큰 지수로 거듭제곱하면 1에 가까운 값만 남는다.

| 입력 | `pow(x, 2)` | `pow(x, 8)` | `pow(x, 32)` |
| ---: | ---: | ---: | ---: |
| 1.0 | 1.0 | 1.0 | 1.0 |
| 0.9 | 0.81 | 약 0.43 | 약 0.034 |
| 0.7 | 0.49 | 약 0.058 | 거의 0 |
| 0.5 | 0.25 | 약 0.004 | 거의 0 |

지수가 낮으면 반사 방향에서 멀리 떨어진 Fragment도 밝게 남는다.

지수가 높으면 `R·V`가 1에 매우 가까운 좁은 영역만 밝다.

```text
낮은 Shininess             높은 Shininess

      ╭────╮                    ╭╮
──────╯    ╰──────        ──────╯╰──────
넓고 부드러운 Highlight    좁고 날카로운 Highlight
```

고전적인 Shader에서 Shininess 또는 Specular Power는 Surface의 광택을 조절하는 값이다.

---

## Half Vector란?

Half Vector는 Light Direction과 View Direction의 정확한 중간 방향이다.

```text
H = normalize(L + V)
```

```text
           L
          ↗
         / H
        ↗
       ●────────→ V
```

Surface Normal이 Half Vector와 같다면 Light가 반사되는 방향과 Camera 방향이 일치한다.

```text
N = H
→ 입사각과 관찰각이 Normal을 기준으로 대칭
→ 강한 Specular
```

Half Vector를 사용하면 Reflection Vector를 직접 만들지 않고 `N·H`로 Highlight를 계산할 수 있다.

---

## Blinn-Phong Specular Model

Blinn-Phong은 Normal과 Half Vector의 Dot Product를 거듭제곱한다.

```text
Blinn-Phong Specular
= pow(max(0, N · H), Shininess)
```

```hlsl
half BlinnPhongSpecular(
    half3 normalWS,
    half3 lightDirectionWS,
    half3 viewDirectionWS,
    half shininess)
{
    half3 N = normalize(normalWS);
    half3 L = normalize(lightDirectionWS);
    half3 V = normalize(viewDirectionWS);
    half3 H = normalize(L + V);

    half NdotH = saturate(dot(N, H));

    return pow(NdotH, shininess);
}
```

Phong과 Blinn-Phong의 지수는 같은 값을 넣어도 Highlight 폭이 같지 않다.

두 Model의 Dot Product가 측정하는 각도가 다르므로 Visual을 유지하려면 지수를 다시 조정해야 한다.

| Model | 비교하는 Vector | 핵심 항 |
| --- | --- | --- |
| Phong | Reflection과 View | `pow(R·V, p)` |
| Blinn-Phong | Normal과 Half | `pow(N·H, p)` |

Blinn-Phong은 고전적인 Realtime Lighting에서 널리 사용되었고 Half Vector 개념은 PBR Microfacet Model에도 이어진다.

---

## Light가 Surface 뒤에 있을 때

Specular 항만 계산하면 Light가 Surface 뒤에 있어도 일부 방향에서 값이 생길 수 있다.

Opaque Surface의 앞면 Direct Lighting에서는 `N·L`이 양수인지 확인해야 한다.

```hlsl
half NdotL = saturate(dot(N, L));
half NdotH = saturate(dot(N, H));

half specular = pow(NdotH, shininess) * NdotL;
```

또는 조건으로 차단할 수 있다.

```hlsl
half specular = 0.0h;

if (dot(N, L) > 0.0h)
{
    specular = pow(saturate(dot(N, H)), shininess);
}
```

GPU에서는 명시적 Branch보다 수학적 Mask가 더 단순할 수 있지만 Target GPU와 Compiler 결과를 확인해야 한다.

Two-sided Lighting과 Transmission은 별도의 Material Model이 필요하다.

---

## Specular Color와 Intensity

각도 항은 Highlight 모양만 만든다.

Specular Color는 반사광의 색과 세기를 조절한다.

```hlsl
half3 specular =
    specularColor *
    lightColor *
    specularTerm;
```

비금속 Surface의 Specular는 보통 Light Color를 반영하고 Surface의 Base Color와 다른 성질을 가진다.

금속은 Diffuse보다 색이 있는 Specular Reflection이 중심이 된다.

이 에너지 분배와 Fresnel은 다음 PBR 글에서 구체적으로 연결한다.

고전적인 Custom Shader에서 Specular Color를 임의로 높게 설정하고 Diffuse도 그대로 더하면 들어온 빛보다 많은 Energy를 반사할 수 있다.

```text
Naive Result
= Full Diffuse + Full Specular

PBR 관점
= Material에 따라 Diffuse와 Specular Energy를 분배
```

---

## Smoothness와 Roughness

Smoothness는 Surface가 얼마나 매끄러운지를 나타낸다.

Roughness는 Surface가 얼마나 거친지를 나타내며 개념적으로 반대 성질이다.

```text
Roughness ≈ 1 - Smoothness
```

| Surface | Smoothness | Highlight |
| --- | ---: | --- |
| 거친 고무 | 낮음 | 넓고 흐림 |
| 플라스틱 | 중간 | 중간 크기 |
| 유리처럼 매끄러운 표면 | 높음 | 작고 선명함 |

고전적인 Blinn-Phong에서는 Smoothness를 Specular Power로 변환해 사용한다.

```hlsl
half shininess = exp2(
    minSmoothnessPower +
    smoothness * powerRange);
```

정확한 Mapping은 Shader마다 다르다.

Smoothness 값을 그대로 `pow`의 지수로 사용하면 `0~1` 범위라 Highlight가 지나치게 넓어질 수 있다.

Unity의 Lit Shader는 단순 지수 하나가 아니라 PBR BRDF의 Roughness 관련 항으로 변환하므로 Custom Blinn-Phong과 동일한 모양을 기대하면 안 된다.

---

## Highlight 크기와 밝기는 같은 값이 아니다

고전적인 Model에서는 지수를 높이면 Highlight가 좁아지면서 주변 값이 급격히 감소한다.

이때 Peak 값만 유지하면 전체 반사 Energy도 달라질 수 있다.

```text
Width   ← Roughness / Power
Color   ← Specular Color
Energy  ← Model의 정규화 방식
```

물리 기반 BRDF는 Roughness가 바뀌어도 Energy 관계를 더 일관되게 유지하도록 Distribution을 정규화한다.

단순 Phong·Blinn-Phong은 이해와 Stylized Lighting에는 유용하지만 물리적으로 정확한 Material 표현에는 한계가 있다.

---

## Light 감쇠와 Shadow

한 Light의 Direct Specular도 거리와 Shadow의 영향을 받는다.

```text
Direct Specular
= Specular Angular Term
 × Specular Color
 × Light Color
 × Distance Attenuation
 × Shadow Attenuation
```

```hlsl
half attenuation =
    light.distanceAttenuation *
    light.shadowAttenuation;

half3 directSpecular =
    specularColor *
    light.color *
    specularTerm *
    attenuation;
```

Shadow 안에서 해당 Direct Light가 보이지 않으면 그 Light의 Specular Highlight도 줄어야 한다.

Reflection Probe와 Skybox에서 오는 Indirect Specular는 Direct Light의 Shadow Attenuation으로 함께 제거하지 않는다.

---

## Direct Specular와 Indirect Specular

Specular는 광원 종류에 따라 구분할 수 있다.

```text
Direct Specular
└─ Directional / Point / Spot Light의 Highlight

Indirect Specular
└─ Skybox / Reflection Probe / Environment Reflection
```

Direct Specular는 Light Direction을 알고 분석적인 Highlight를 계산한다.

Indirect Specular는 Reflection Vector로 Environment Map을 Sample한다.

```hlsl
half3 reflectionVector = reflect(-V, N);
```

Roughness가 높으면 Environment Map의 흐린 Mip Level을 사용하고, 낮으면 선명한 Mip Level을 사용한다.

URP는 Custom Shader에서 `GlossyEnvironmentReflection` 같은 Helper로 Reflection Probe와 Skybox를 Sample할 수 있다.

한쪽만 구현하면 직접광 Highlight는 보이지만 주변 환경 반사가 없거나 그 반대가 될 수 있다.

---

## Normal Map이 Specular에 미치는 영향

Specular는 Normal 변화에 매우 민감하다.

Normal Map이 미세한 방향 변화를 만들면 Reflection 또는 Half Vector 관계도 크게 달라진다.

```text
Geometry Normal       Normal Map 적용

↑ ↑ ↑ ↑ ↑            ↖ ↑ ↗ ↘ ↑
하나의 Highlight      잘게 흔들리는 Highlight
```

```hlsl
half3 normalTS = UnpackNormal(
    SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, uv));

half3 N = normalize(
    TransformTangentToWorld(normalTS, tangentToWorld));
```

Tangent Space Normal을 World Space Light 및 View Direction과 바로 계산하면 Highlight가 Object 회전에 맞지 않게 움직인다.

Normal Map 압축, Tangent, UV Seam과 Normal Scale 문제도 Specular에서 Diffuse보다 눈에 잘 띈다.

---

## Vertex Specular와 Fragment Specular

Vertex에서 Specular를 계산하면 Vertex 사이 값이 보간된다.

좁은 Highlight가 Vertex 사이에 있으면 어느 Vertex에서도 높은 값이 계산되지 않아 완전히 사라질 수 있다.

```text
실제 Highlight 위치: Triangle 중앙

Vertex A = 0       Vertex B = 0
          \   ★   /
           \     /
            Vertex C = 0

보간 결과도 0 → Highlight 소실
```

Fragment Specular는 보간된 Position과 Normal로 Pixel마다 방향을 다시 계산한다.

| 방식 | 장점 | 단점 |
| --- | --- | --- |
| Vertex Specular | 계산 횟수가 적음 | 작은 Highlight가 사라지고 형태가 부정확함 |
| Fragment Specular | 부드럽고 정확함 | 화면 Fragment 수만큼 반복됨 |

높은 Smoothness의 좁은 Highlight와 Normal Map은 Fragment 계산이 특히 중요하다.

---

## URP의 LightingSpecular 함수

Unity 6 URP의 `Lighting.hlsl`은 단순 Specular Lighting Helper를 제공한다.

```hlsl
half3 LightingSpecular(
    half3 lightColor,
    half3 lightDirection,
    half3 surfaceNormal,
    half3 viewDirection,
    half4 specularAmount,
    half smoothnessAmount);
```

```hlsl
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
```

Main Light와 결합한 기본 형태는 다음과 같다.

```hlsl
Light mainLight = GetMainLight(shadowCoord);

half3 N = normalize(input.normalWS);
half3 V = GetWorldSpaceNormalizeViewDir(input.positionWS);

half3 specular = LightingSpecular(
    mainLight.color,
    mainLight.direction,
    N,
    V,
    _SpecularColor,
    _Smoothness);

specular *=
    mainLight.distanceAttenuation *
    mainLight.shadowAttenuation;
```

`specularAmount`는 `half4`, `smoothnessAmount`는 `half` 입력이다.

이 Helper는 Simple Lighting용 Specular 계산이며 URP Lit의 전체 PBR BRDF와 같은 함수라고 보면 안 된다.

프로젝트가 사용하는 URP Package Version의 실제 `Lighting.hlsl` 구현과 호출부도 함께 확인해야 한다.

---

## Lambert와 Specular를 결합하기

한 Light의 단순한 Direct Lighting을 두 항으로 나눌 수 있다.

```text
Direct Lighting = Diffuse + Specular
```

```hlsl
half3 EvaluateSimpleLight(
    half3 albedo,
    half3 normalWS,
    half3 viewDirectionWS,
    half4 specularColor,
    half smoothness,
    Light light)
{
    half3 N = normalize(normalWS);
    half3 V = normalize(viewDirectionWS);

    half3 diffuse = LightingLambert(
        light.color,
        light.direction,
        N) * albedo;

    half3 specular = LightingSpecular(
        light.color,
        light.direction,
        N,
        V,
        specularColor,
        smoothness);

    half attenuation =
        light.distanceAttenuation *
        light.shadowAttenuation;

    return (diffuse + specular) * attenuation;
}
```

여러 Light가 있으면 각 Light에 대해 Diffuse와 Specular를 계산해 누적한다.

```hlsl
half3 directLighting = 0.0h;

directLighting += EvaluateSimpleLight(
    albedo, N, V, specularColor, smoothness, mainLight);

// Additional Light Loop에서도 같은 방식으로 누적
```

Forward와 Forward+의 Additional Light Loop는 Pipeline에 맞는 Keyword와 Macro를 사용해야 한다.

---

## URP Lit와 Simple Lit의 차이

URP의 Simple Lit은 비교적 단순한 Lighting Model로 성능과 Stylized Material에 적합하다.

Lit은 Metallic 또는 Specular Workflow와 물리 기반 BRDF를 사용한다.

| Shader | Specular 접근 | 적합한 경우 |
| --- | --- | --- |
| Simple Lit | 단순화된 Specular | 저사양, 단순한 재질, Stylized 표현 |
| Lit | PBR Specular | 현실적인 재질과 Environment Reflection |

Lit의 Smoothness는 Highlight 분포와 Environment Reflection의 흐림 정도에 함께 영향을 준다.

Simple Lit 또는 직접 만든 Blinn-Phong의 Smoothness Mapping과 Lit의 결과가 정확히 같지는 않다.

Shader를 바꿀 때 숫자만 그대로 옮기지 말고 Scene Light와 Reflection 환경에서 재질을 다시 확인해야 한다.

---

## Transparent Surface의 Specular

일반적인 Alpha Blending에서 최종 Lighting 전체에 Alpha를 곱하면 Surface가 투명해질수록 Specular도 사라진다.

유리처럼 투명한 재질은 Base Color가 약해도 반사광은 선명하게 남을 수 있다.

```text
Base Transmission / Alpha
        와
Specular Reflection
        은 서로 다른 광학 성질
```

URP Lit의 Transparent 설정에는 Blending Mode에 따라 Specular Lighting을 보존하는 옵션이 제공될 수 있다.

Custom Transparent Shader에서는 Premultiplied Alpha와 Specular 결합 방식을 의도적으로 설계해야 한다.

잘못 결합하면 Highlight 주변에 검은 테두리가 생기거나 Specular가 Alpha와 함께 지나치게 약해질 수 있다.

---

## Specular Aliasing

매우 높은 Smoothness와 강한 Normal Map은 Pixel보다 작은 좁은 Highlight를 만든다.

Camera나 Object가 조금 움직일 때 Sample에 걸렸다 사라지며 반짝이는 Noise가 생길 수 있다.

```text
Frame 1  ·  ★  ·  ·
Frame 2  ·  ·  ★  ·
Frame 3  ·  ★  ·  ·
```

이를 Specular Aliasing 또는 Shimmering으로 볼 수 있다.

대응 방법은 다음과 같다.

- 지나치게 높은 Smoothness를 피한다.
- Normal Map의 고주파 Detail과 강도를 조절한다.
- 거리에 맞는 Mip Map과 Texture Filtering을 사용한다.
- Pipeline이 제공하는 Specular Anti-aliasing 기능을 검토한다.
- Temporal Anti-aliasing을 사용할 때 Motion Vector와 전체 품질을 함께 확인한다.

단순히 MSAA를 높여도 Shader 내부의 고주파 Specular가 모두 해결되는 것은 아니다.

---

## Specular를 디버깅하는 순서

최종 Color 대신 각 입력을 분리해 출력한다.

### View Direction

```hlsl
return half4(V * 0.5h + 0.5h, 1.0h);
```

### Reflection Vector

```hlsl
half3 R = reflect(-L, N);
return half4(R * 0.5h + 0.5h, 1.0h);
```

### Half Vector

```hlsl
half3 H = normalize(L + V);
return half4(H * 0.5h + 0.5h, 1.0h);
```

### Dot Product

```hlsl
half NdotH = saturate(dot(N, H));
return half4(NdotH.xxx, 1.0h);
```

### Power 적용 결과

```hlsl
half specularTerm = pow(NdotH, shininess);
return half4(specularTerm.xxx, 1.0h);
```

```text
Normal 확인
   ↓
Light Direction 부호 확인
   ↓
View Direction 확인
   ↓
R·V 또는 N·H 확인
   ↓
Smoothness / Power 확인
   ↓
Light Color와 감쇠 확인
```

Highlight가 반대로 움직이면 Light 또는 View Direction의 부호와 Coordinate Space를 먼저 확인한다.

---

## 자주 생기는 문제

### Camera가 움직여도 Highlight가 움직이지 않는다

View Direction을 상수로 사용했거나 Vertex에서 잘못 계산했을 수 있다.

Perspective Camera에서는 Surface Position마다 View Direction이 달라야 한다.

### Highlight가 Light 반대편에 생긴다

`reflect(L, N)`처럼 Incident Vector 부호가 뒤집혔을 가능성이 있다.

`L`의 정의를 확인하고 Surface에서 Light로 향한다면 `reflect(-L, N)`을 사용한다.

### Object 회전 시 Highlight가 이상하다

Normal, Light와 View Direction의 Coordinate Space가 다를 수 있다.

Normal Map을 사용한다면 TBN 변환과 Tangent의 `w` 부호도 확인한다.

### Smoothness를 높여도 Highlight가 선명해지지 않는다

Smoothness를 Specular Power로 변환하지 않고 `0~1` 값을 지수에 그대로 넣었을 수 있다.

Texture의 Smoothness Channel과 Import 설정도 확인한다.

### Shadow 안에서도 Highlight가 남는다

Direct Specular에 `shadowAttenuation`을 곱하지 않았을 수 있다.

남아 있는 것이 Reflection Probe 기반 Indirect Specular인지도 구분해야 한다.

### Highlight가 삼각형처럼 보인다

Vertex Specular를 사용하거나 Mesh Normal과 Tangent가 거칠 수 있다.

Fragment Lighting과 Mesh Smoothing 상태를 비교한다.

---

## 성능 비용은 어디서 생길까?

고전적인 Specular는 Lambert보다 계산 항이 많다.

```text
Lambert
└─ N · L

Specular
├─ View Direction
├─ Reflection 또는 Half Vector
├─ 추가 Dot Product
└─ Power Function
```

하지만 실제 Frame 비용은 수식 하나보다 실행 횟수와 주변 기능에 더 크게 좌우될 수 있다.

| 비용 요인 | 영향 |
| --- | --- |
| Additional Light 수 | Light마다 Specular 반복 |
| Per-fragment 계산 | 화면 Coverage만큼 반복 |
| Normal Map | Texture Sample과 TBN 변환 |
| Realtime Shadow | Light별 Shadow Sample |
| Reflection Probe | Indirect Specular Texture Sample |
| Transparent Overdraw | 같은 Pixel에서 반복 실행 |

Smoothness 값이 높다고 항상 명령 수가 늘어나는 것은 아니지만 좁은 Highlight의 Aliasing을 줄이기 위한 품질 비용이 생길 수 있다.

---

## 최적화 관점

### 필요 없는 Specular를 끈다

완전히 Matte한 Stylized Material은 Specular 계산과 관련 Variant가 필요하지 않을 수 있다.

URP Asset과 Material 설정에서 사용하지 않는 기능을 정리한다.

### Light 수를 관리한다

Specular는 영향을 주는 Realtime Light마다 반복된다.

작은 Point Light의 Range와 불필요한 Additional Light를 줄이는 것이 Micro Optimization보다 효과적일 수 있다.

### 중요한 Object에 Fragment Specular를 사용한다

멀고 작은 Object에는 Vertex Lighting이나 단순 Shader를 사용할 수 있다.

가까운 Character, 자동차, 매끄러운 Prop에는 Fragment Specular가 시각적으로 중요하다.

### Normal Map 품질을 거리별로 조절한다

먼 거리에서 고주파 Normal Detail은 눈에 잘 보이지 않으면서 Specular Shimmering을 만들 수 있다.

Mip Map, LOD Material과 Normal Strength를 함께 설계한다.

### Reflection Probe 수와 Blending을 확인한다

Indirect Specular 품질을 높이기 위한 Probe Blending과 Box Projection도 Sample 비용을 늘릴 수 있다.

Frame Debugger와 GPU Profiler로 실제 Pass와 Shader Variant를 확인한다.

### PBR과 Simple Lighting을 목적에 맞게 선택한다

현실적인 Material이 필요하지 않은 저사양 Object에 전체 Lit BRDF를 항상 사용할 필요는 없다.

반대로 중요한 Material을 단순 Blinn-Phong으로 바꾸면 성능은 줄어도 재질 일관성과 Lighting 품질을 잃을 수 있다.

---

## 흔한 오해

### Specular는 흰색 점을 더하는 효과다

Specular는 Light, Surface Normal, View Direction과 Material 반사 성질의 결과다.

고정된 Texture Highlight와 달리 Camera와 Light에 따라 움직인다.

### Smoothness는 Specular 밝기다

Smoothness는 주로 Highlight의 분포와 선명도에 영향을 준다.

Specular Color 또는 Reflectance는 반사 강도와 색을 담당하며 PBR에서는 두 값이 함께 BRDF를 결정한다.

### Phong과 Blinn-Phong에 같은 Power를 쓰면 같다

두 Model이 비교하는 각도가 다르므로 같은 지수에서도 Highlight 폭이 다르다.

### Reflection Vector는 Light Direction을 그대로 반사하면 된다

HLSL `reflect`는 들어오는 Incident Vector를 요구한다.

Surface에서 Light로 향하는 `L`을 사용한다면 `-L`을 전달한다.

### Direct Specular와 Reflection Probe는 같은 계산이다

Direct Specular는 분석적인 Light Direction으로 계산하고 Indirect Specular는 Environment Map을 Sample한다.

최종 Material에서는 함께 보일 수 있지만 데이터와 감쇠 방식이 다르다.

---

## 전체 처리 흐름

한 Light의 Specular가 만들어지는 흐름은 다음과 같다.

```text
Surface Position ──────── Camera Position
       │                         │
       └──────────┬──────────────┘
                  ▼
          View Direction V

Surface Normal N ───────── Light Direction L
       │                         │
       └──────────┬──────────────┘
                  ▼
       Reflection Vector R
             또는
          Half Vector H
                  │
                  ▼
       saturate(R · V)
             또는
       saturate(N · H)
                  │
                  ▼
     Smoothness / Power로 분포 조절
                  │
                  ▼
 Specular Color × Light Color
 × Distance × Shadow Attenuation
                  │
                  ▼
         Direct Specular
                  │
                  ├─ Direct Diffuse
                  ├─ Indirect Diffuse
                  ├─ Indirect Specular
                  └─ Emission
                  │
                  ▼
              Final Color
```

Specular의 핵심은 Light가 반사될 방향과 Camera가 Surface를 바라보는 방향이 얼마나 일치하는지를 밝기로 바꾸는 것이다.

---

## 정리

Specular는 Surface에서 특정 방향으로 집중된 반사광이 Camera에 들어올 때 보이는 Highlight다.

Diffuse와 달리 Surface Normal `N`, Light Direction `L`뿐 아니라 View Direction `V`가 필요하다.

Phong Model은 `reflect(-L, N)`으로 Reflection Vector `R`을 만들고 `pow(max(0, R·V), power)`로 Highlight를 계산한다.

Blinn-Phong은 `normalize(L+V)`로 Half Vector `H`를 만들고 `pow(max(0, N·H), power)`를 사용한다.

Power가 높을수록 1에 가까운 값만 남아 Highlight가 좁고 선명해진다.

Smoothness가 높은 Surface는 작고 날카로운 Highlight를 만들고 Roughness가 높은 Surface는 넓고 흐린 반사를 만든다.

최종 Direct Specular에는 Specular Color, Light Color, Distance Attenuation과 Shadow Attenuation이 결합된다.

Direct Specular와 Reflection Probe·Skybox 기반 Indirect Specular는 서로 다른 Light Source를 표현하므로 구분해서 처리한다.

Unity 6 URP는 `Lighting.hlsl`에 단순 Lighting용 `LightingSpecular`를 제공하지만 URP Lit의 전체 PBR BRDF와 동일하지는 않다.

Normal Map은 Fragment Normal을 바꾸므로 Specular 모양에 큰 영향을 주며 Coordinate Space와 TBN 변환이 정확해야 한다.

높은 Smoothness와 고주파 Normal은 Specular Aliasing을 만들 수 있으므로 Mip Map, Normal 강도와 거리별 품질을 함께 조절한다.

실제 비용은 Specular 수식 하나보다 Additional Light 수, Fragment Coverage, Shadow, Normal Map과 Environment Reflection의 반복 횟수에서 커질 수 있다.
