---
title: "[Unity 렌더링] 7-4. PBR은 무엇일까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - Shader
  - Lighting
  - PBR
permalink: /programming/unity-7-4-what-is-pbr/
toc: true
toc_sticky: true
date: 2026-08-16
last_modified_at: 2026-08-16
---

PBR은 Physically Based Rendering의 약자로, 현실의 빛과 재질이 상호작용하는 원리를 일관된 규칙으로 근사하는 Rendering 방식이다.

재질마다 임의의 Highlight 색과 밝기를 맞추는 대신 Albedo, Metallic, Smoothness, Normal 같은 물리적 의미의 입력을 사용한다.

```text
Material Data
├─ Albedo
├─ Metallic
├─ Smoothness / Roughness
└─ Normal
        │
        ▼
물리 기반 BRDF + Light + Environment
        │
        ▼
       화면 Color
```

같은 Material이 낮, 밤, 실내와 실외처럼 서로 다른 Lighting 환경에서도 재질의 성질을 비교적 일관되게 유지하는 것이 핵심이다.

---

## PBR이 등장한 이유

고전적인 Lighting에서도 Lambert Diffuse와 Phong 또는 Blinn-Phong Specular를 더해 입체감과 광택을 만들 수 있다.

하지만 각 값을 독립적으로 조절하면 현실에서 불가능한 재질도 쉽게 만들어진다.

```text
Diffuse = 매우 밝음
Specular = 매우 밝음
Reflection = 매우 밝음

→ 들어온 빛보다 더 많은 빛을 반사
```

Scene마다 Material 값을 다시 조절해야 하는 문제도 생긴다.

어두운 조명에 맞춘 Texture와 Highlight가 밝은 야외에서는 과장되고, 야외에 맞춘 Material이 실내에서는 재질감을 잃을 수 있다.

PBR은 다음 목표를 가진다.

- Material Parameter에 명확한 의미를 부여한다.
- 반사되는 빛의 Energy가 들어온 빛을 넘지 않도록 제한한다.
- 미세한 Surface 구조에 따른 반사 분포를 모델링한다.
- Direct Light와 Environment Light에서 같은 Material 성질을 유지한다.
- Artist가 Lighting 결과가 아니라 Surface 자체의 정보를 제작하게 한다.

PBR은 현실을 완전히 Simulation하는 것이 아니라 Realtime Rendering에 적합한 물리 원칙과 근사를 사용하는 방식이다.

---

## Physically Based는 완전히 물리적으로 정확하다는 뜻일까?

게임의 PBR Shader는 빛의 모든 파장, Surface 내부 산란과 분자 구조를 그대로 계산하지 않는다.

실시간 Frame Budget 안에서 중요한 현상을 단순화한다.

```text
현실의 복잡한 광학 현상
        │ 근사
        ▼
BRDF + Texture + Probe + Light
        │ 실시간 계산
        ▼
시각적으로 그럴듯하고 일관된 결과
```

Pipeline마다 사용하는 Diffuse Model, Specular Distribution, Roughness Mapping과 Energy 보정이 다를 수 있다.

따라서 PBR은 하나의 고정 Shader 이름보다 물리적 제약과 Material Workflow를 따르는 Rendering 접근법에 가깝다.

---

## 빛이 Surface에 도달하면 어떻게 될까?

빛이 Surface에 도달하면 일부는 표면에서 반사되고 일부는 내부로 들어간다.

```text
Incoming Light
      ↓
──────●────── Surface
     ↗ ↘
표면 반사  내부로 굴절
Specular   Absorption / Scattering
              │
              └─ 다시 나오는 빛 → Diffuse
```

표면에서 바로 반사되는 빛이 Specular Reflection이다.

비금속 내부로 들어간 빛은 흡수되거나 산란한 뒤 다른 방향으로 나오며 Diffuse Color를 만든다.

금속에서는 들어간 빛이 대부분 흡수되므로 일반적인 Diffuse가 거의 없고 색이 있는 Specular Reflection이 재질의 색을 만든다.

이 차이가 Metallic Workflow의 기반이다.

---

## BRDF란?

BRDF는 Bidirectional Reflectance Distribution Function의 약자다.

특정 방향에서 들어온 빛이 Surface에서 특정 관찰 방향으로 얼마나 반사되는지를 나타내는 함수다.

```text
BRDF 입력
├─ Light Direction L
├─ View Direction V
├─ Surface Normal N
└─ Material Properties

BRDF 출력
└─ 해당 View Direction으로 반사되는 비율
```

PBR의 Direct Lighting을 단순화하면 다음처럼 볼 수 있다.

```text
Direct Lighting
= Incident Light
 × BRDF(N, L, V, Material)
 × max(0, N · L)
```

BRDF는 보통 Diffuse Lobe와 Specular Lobe로 나뉜다.

```text
BRDF = Diffuse BRDF + Specular BRDF
```

URP의 물리 기반 Shading은 Specular Highlight 형태를 위해 GGX 계열 함수를 사용한다.

---

## 에너지 보존

Energy Conservation은 Emission이 없는 Surface가 들어온 빛보다 더 많은 빛을 반사하지 않아야 한다는 원칙이다.

```text
Reflected Energy ≤ Incoming Energy
```

빛의 일부가 Specular로 반사되면 내부로 들어가 Diffuse가 될 수 있는 양은 줄어든다.

```text
Incoming Energy = 1.0

Specular Reflection = 0.2
Diffuse에 사용 가능한 최대 Energy ≈ 0.8
```

고전적인 방식처럼 Full Diffuse와 Full Specular를 독립적으로 더하면 이 관계를 깨뜨릴 수 있다.

PBR Shader는 Material의 반사 성질에 따라 Diffuse와 Specular의 비율을 나눈다.

```text
Specular 증가
     ↓
Diffuse에 남는 Energy 감소
```

Metallic이 1에 가까워질수록 Diffuse는 줄고 Base Color가 Specular 색에 사용된다.

---

## 미세 표면 이론

눈에 매끄러워 보이는 Surface도 아주 작게 확대하면 서로 다른 방향을 향하는 미세 면으로 이루어져 있다고 근사할 수 있다.

```text
Smooth Microsurface         Rough Microsurface

──────────────              /\/\_/\/\
Normal이 비슷함             Normal 분포가 넓음
```

각 미세 면은 Mirror처럼 빛을 반사한다고 가정한다.

Half Vector를 향하는 미세 면이 얼마나 많이 존재하는지가 Camera 방향으로 오는 Specular의 양에 영향을 준다.

```text
H = normalize(L + V)

Microfacet Normal이 H에 가까움
→ Light가 View 방향으로 반사됨
```

Smooth Surface는 미세 Normal이 한 방향에 집중되어 좁고 강한 Highlight를 만든다.

Rough Surface는 미세 Normal이 넓게 분포해 Highlight가 퍼진다.

---

## Microfacet Specular BRDF

대표적인 Microfacet Specular BRDF는 다음 형태를 가진다.

```text
Specular BRDF = (D × F × G) / (4 × N·L × N·V)
```

| 항 | 의미 |
| --- | --- |
| `D` | Half Vector 방향의 미세 면이 얼마나 분포하는가 |
| `F` | 각도에 따라 반사 비율이 어떻게 변하는가 |
| `G` | 미세 면끼리 빛과 시야를 얼마나 가리는가 |
| 분모 | 기하학적 정규화 |

`D`는 Normal Distribution Function이며 URP PBR에서는 GGX 계열 분포가 사용된다.

`F`는 Fresnel Term이다.

`G`는 Geometry 또는 Visibility Term으로 Masking과 Shadowing을 근사한다.

이 수식의 세부 구현은 Pipeline과 최적화 근사에 따라 달라질 수 있다.

PBR Material을 사용하기 위해 모든 내부 수식을 암기할 필요는 없지만 Smoothness와 Metallic이 어느 항을 바꾸는지 이해하면 결과를 예측하기 쉽다.

---

## Fresnel Effect

Fresnel Effect는 Surface를 비스듬히 볼수록 반사 비율이 강해지는 현상이다.

```text
정면 시점                 비스듬한 시점

Camera ↓                 Camera →
─────── Surface          ─────── Surface
반사 약함                 가장자리 반사 강함
```

비금속도 정면에서 일정한 Specular Reflection을 가지며 Grazing Angle에서는 반사가 강해진다.

PBR에서는 흔히 정면 반사율을 `F0`로 표현한다.

```text
F = F0 + (1 - F0)(1 - V·H)^5
```

이는 널리 쓰이는 Schlick Fresnel 근사의 형태다.

Metallic Workflow에서는 비금속의 F0를 Pipeline이 적절한 기본값으로 처리하고, 금속의 F0 Color는 Base Color에서 얻는 방식으로 구성할 수 있다.

Fresnel 때문에 Matte한 비금속도 가장자리에서 Reflection이 완전히 사라지지 않는다.

---

## Albedo란?

Albedo는 Surface가 반사하는 기본 색 정보를 나타낸다.

Unity Material에서는 Base Map과 Base Color를 결합해 Base Color Data를 만든다.

```hlsl
half4 baseSample = SAMPLE_TEXTURE2D(
    _BaseMap,
    sampler_BaseMap,
    uv);

half3 baseColor = baseSample.rgb * _BaseColor.rgb;
```

Albedo Texture에는 원칙적으로 Scene Lighting 결과가 들어가지 않아야 한다.

```text
Albedo에 포함하면 안 되는 정보
├─ Directional Light의 Highlight
├─ 고정된 Cast Shadow
├─ 특정 Environment Reflection
└─ 임의로 그린 강한 Ambient Occlusion
```

Lighting이 Texture에 이미 Bake되어 있으면 Realtime Light와 다시 곱해져 그림자와 Highlight가 중복된다.

### 비금속의 Albedo

비금속에서는 Base Color가 주로 Diffuse Color를 나타낸다.

플라스틱, 나무, 돌과 피부가 대표적이다.

### 금속의 Albedo

금속에서는 일반적인 Diffuse가 거의 없고 Base Color가 Specular Reflection의 색에 사용된다.

```text
Metallic = 0
Base Color → Diffuse 중심

Metallic = 1
Base Color → Specular 중심
Diffuse → 거의 0
```

같은 Base Map이라도 Metallic 값에 따라 Lighting에서 쓰이는 위치가 달라진다.

---

## Albedo Texture의 Color Space

Albedo는 사람이 보는 색 데이터이므로 보통 sRGB Texture로 Import한다.

GPU는 Lighting 계산 전에 sRGB 값을 Linear 값으로 Decode한다.

```text
sRGB Albedo Texture
        │ Decode
        ▼
Linear Base Color
        │ PBR Lighting
        ▼
Linear HDR Result
        │ Tone Mapping / Encoding
        ▼
Display
```

Gamma Encoding 상태에서 Energy 연산을 하면 중간 밝기가 올바르지 않다.

Metallic, Roughness, Smoothness, Occlusion처럼 숫자를 저장한 Mask Texture는 일반 Color와 다르므로 보통 sRGB를 끈 Linear Data로 Import한다.

---

## Metallic이란?

Metallic은 Surface가 금속처럼 동작하는 정도를 나타내는 값이다.

```text
Metallic = 0 → Dielectric, 비금속
Metallic = 1 → Metal, 금속
```

| Metallic | Diffuse | Specular Color |
| ---: | --- | --- |
| 0 | Base Color 중심 | 비금속 기본 반사율 |
| 1 | 거의 없음 | Base Color로 Tint |

현실의 순수한 Material은 대체로 금속 또는 비금속 중 하나다.

따라서 Metallic Map은 많은 영역에서 0 또는 1에 가깝게 제작한다.

중간 값이 유효한 경우도 있다.

- 금속 위에 먼지나 녹이 덮인 경계
- Texture Filtering으로 생기는 경계 Pixel
- 서로 다른 Material이 한 Texel에 섞인 경우
- 의도적인 Stylized Material

녹, 페인트와 먼지는 금속 표면 위에 있어도 그 층 자체는 비금속이므로 Metallic을 낮춰야 한다.

---

## Metallic은 반사의 양만 조절하는 값이 아니다

Metallic을 단순 Reflection Strength Slider로 생각하면 Material이 잘못 만들어진다.

Metallic은 Diffuse와 Specular가 Base Color를 사용하는 방식을 바꾼다.

```text
Metallic 증가
├─ Diffuse Energy 감소
├─ Specular F0 증가 및 Base Color Tint
└─ Environment Reflection이 재질 색을 형성
```

금속이 어둡게 보일 때 Metallic을 낮추는 것이 항상 해답은 아니다.

Reflection Probe, Skybox와 Lighting Environment가 부족하면 금속이 반사할 대상이 없어 검게 보일 수 있다.

금속 Material을 평가할 때는 Direct Light뿐 아니라 Environment Reflection도 함께 준비해야 한다.

---

## Metallic Workflow와 Specular Workflow

PBR Material은 같은 물리 모델을 서로 다른 입력 방식으로 제어할 수 있다.

### Metallic Workflow

Base Color, Metallic과 Smoothness를 사용한다.

```text
Base Color + Metallic
        │
        ├─ Diffuse Color 결정
        └─ Specular F0 Color 결정
```

입력이 단순하고 금속과 비금속을 구분해 제작하기 쉽다.

### Specular Workflow

Diffuse Color와 Specular Color를 직접 제공한다.

```text
Diffuse Color ── Diffuse Lobe
Specular Color ─ Specular F0
```

정면 반사 색을 세밀하게 제어할 수 있지만 물리적으로 불가능한 값도 입력하기 쉽다.

| 구분 | Metallic Workflow | Specular Workflow |
| --- | --- | --- |
| 핵심 입력 | Base Color, Metallic | Diffuse Color, Specular Color |
| 장점 | 단순하고 일관된 제작 | 반사 색 직접 제어 |
| 주의점 | 혼합 영역 해석 | Energy를 깨는 값 입력 가능 |

URP Lit은 Material의 Workflow Mode에서 두 방식을 선택할 수 있다.

한 프로젝트에서는 Asset 제작 규칙을 통일하는 편이 Material 일관성과 Channel Packing 관리에 유리하다.

---

## Smoothness란?

Smoothness는 미세 표면이 얼마나 매끄러운지를 나타낸다.

```text
Smoothness = 0 → 거친 미세 표면
Smoothness = 1 → 매끄러운 미세 표면
```

Smoothness는 주로 Specular Highlight와 Environment Reflection의 분포를 바꾼다.

| Smoothness | Direct Highlight | Environment Reflection |
| ---: | --- | --- |
| 낮음 | 넓고 흐림 | 흐린 Mip Sample |
| 높음 | 좁고 선명함 | 선명한 Reflection |

Smoothness를 Specular 밝기와 같은 값으로 보면 안 된다.

거친 Surface도 넓은 범위로 Specular Energy를 반사하지만 Peak가 낮아 덜 선명하게 보인다.

매끄러운 Surface는 Energy가 좁은 방향으로 집중되어 밝고 날카로운 Highlight를 만든다.

---

## Roughness란?

Roughness는 미세 표면의 거칠기를 나타내며 Smoothness와 반대 방향의 입력이다.

Asset Workflow에서 흔히 다음처럼 변환한다.

```text
Roughness = 1 - Smoothness
Smoothness = 1 - Roughness
```

```hlsl
half smoothness = 1.0h - roughness;
```

하지만 Shader 내부에서는 Perceptual Roughness, Linear Roughness와 Roughness Squared처럼 여러 형태로 다시 변환할 수 있다.

```text
Artist Roughness
      │ Mapping
      ▼
Perceptual Roughness
      │ 제곱 등 변환
      ▼
BRDF 내부 Roughness
```

다른 DCC Tool과 Unity 사이에서 Texture를 옮길 때 Channel 반전 여부와 값의 정의를 확인해야 한다.

Roughness Map을 Unity Smoothness Slot에 그대로 넣으면 거친 부분이 매끄럽고 매끄러운 부분이 거칠게 보인다.

---

## Smoothness Texture는 어디에 저장될까?

Smoothness는 Scalar 값이므로 Texture Channel 하나만 필요하다.

URP Lit Material에서는 설정에 따라 Metallic Map의 Alpha 또는 Albedo Alpha를 Source로 사용할 수 있다.

```text
Metallic Map
├─ R: Metallic
└─ A: Smoothness
```

Channel Packing은 Texture Sample 수와 Memory를 줄일 수 있다.

하지만 각 Channel의 해상도 요구, 압축 Artifact와 sRGB 설정을 함께 고려해야 한다.

Color Texture의 Alpha에 Smoothness를 넣으면 RGB는 sRGB Decode가 필요하지만 Alpha Data의 처리와 Export Pipeline을 정확히 맞춰야 한다.

플랫폼 Texture Compression이 Smoothness에 Banding과 Block Artifact를 만드는지도 실제 Material에서 확인한다.

---

## Normal은 PBR에서 무엇을 할까?

Normal은 Surface가 어느 방향을 향하는지 나타낸다.

PBR의 거의 모든 방향 계산에 사용된다.

```text
Normal N
├─ N · L → Light가 들어오는 양
├─ N · V → Camera와 Surface 각도
├─ N · H → Microfacet Specular 분포
└─ Reflection Vector → Environment Sample 방향
```

Mesh Normal만 사용하면 Polygon보다 작은 Detail은 Lighting에 반영되지 않는다.

Normal Map은 Geometry를 추가하지 않고 Fragment마다 Normal을 바꾼다.

```text
Geometry Surface: 평평함
Normal Map:       ↖ ↑ ↗ ↘ ↑
Lighting Result:  미세한 홈과 돌출처럼 보임
```

Normal Map은 실제 Silhouette, Collision과 Shadow Geometry를 바꾸지 않는다.

비스듬한 시점에서는 평평한 윤곽이 드러날 수 있다.

---

## Tangent Space Normal Map

일반적인 Normal Map은 Tangent Space 방향을 RGB에 Encode한다.

```text
Encoded RGB 0~1
      │ Decode
      ▼
Normal XYZ -1~1
      │ TBN Transform
      ▼
World Space Normal
```

```hlsl
half3 normalTS = UnpackNormal(
    SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, uv));

half3 normalWS = normalize(
    TransformTangentToWorld(normalTS, tangentToWorld));
```

Unity는 Y+ 방식의 Normal Map을 사용하므로 다른 Tool의 Y 방향 규칙과 다르면 Green Channel을 뒤집어야 할 수 있다.

Normal Texture는 색으로 표시할 이미지가 아니라 Vector Data이므로 Texture Type을 Normal Map으로 지정한다.

잘못된 Import 설정은 Lighting 방향, 압축과 Mip 처리에 문제를 만든다.

---

## PBR Surface Data의 관계

각 입력은 독립적인 장식 값이 아니라 BRDF의 서로 다른 부분을 결정한다.

```text
Albedo / Base Color
├─ 비금속 Diffuse Color
└─ 금속 Specular Color

Metallic
├─ 금속과 비금속 구분
└─ Diffuse·Specular Energy 분배

Smoothness / Roughness
├─ Microfacet Normal 분포
└─ Direct·Indirect Specular의 선명도

Normal
├─ 입사각과 관찰각
└─ Highlight·Reflection 방향
```

한 값의 오류가 다른 Lighting 항에도 연쇄적으로 영향을 준다.

예를 들어 Normal이 틀리면 Diffuse, Direct Specular와 Reflection Probe 방향이 모두 틀어진다.

---

## Direct Lighting에서의 PBR

한 Light의 Direct PBR은 개념적으로 다음 흐름을 가진다.

```text
Light Data + Surface Data + View Direction
                    │
                    ▼
       Diffuse BRDF + Specular BRDF
                    │
                    ▼
        × NdotL × Light Radiance
                    │
                    ▼
      × Distance / Shadow Attenuation
                    │
                    ▼
             Direct Lighting
```

여러 Realtime Light가 있으면 각 Light의 방향과 감쇠를 사용해 결과를 누적한다.

PBR BRDF는 Lambert와 단순 Blinn-Phong보다 계산량이 많고 Light마다 반복된다.

---

## Indirect Lighting에서의 PBR

PBR Material이 자연스럽게 보이려면 Direct Light뿐 아니라 Environment Lighting이 중요하다.

```text
Indirect Diffuse
├─ Lightmap
├─ Light Probe / APV
└─ Ambient Probe

Indirect Specular
├─ Reflection Probe
└─ Skybox
```

Roughness가 높은 Surface는 흐린 Environment Reflection을 사용하고 Smooth Surface는 선명한 Reflection을 사용한다.

Metal은 Diffuse가 거의 없으므로 Reflection Environment가 없으면 검게 보이기 쉽다.

Material Preview에서 좋아 보이던 금속이 Scene에서 검다면 Albedo보다 Lighting과 Reflection Probe 상태를 먼저 확인할 필요가 있다.

---

## Image Based Lighting

Image Based Lighting은 HDR Environment Texture를 Light Source로 사용한다.

모든 방향의 환경광을 실시간으로 그대로 적분하는 것은 비싸므로 미리 Filtering한 Texture와 근사를 사용한다.

```text
HDR Environment
├─ Diffuse용 저주파 Irradiance
└─ Roughness별 Specular Prefilter Mip
```

Fragment에서는 Normal 또는 Reflection Vector와 Roughness를 이용해 적절한 방향과 Mip을 Sample한다.

```hlsl
half3 R = reflect(-V, N);
```

Smoothness가 높으면 낮은 Blur의 Mip, Roughness가 높으면 더 흐린 Mip을 선택한다.

이 방식이 PBR Material을 Scene 주변 환경과 자연스럽게 연결한다.

---

## Ambient Occlusion과 PBR

Ambient Occlusion은 틈과 접촉 영역에 Environment Light가 덜 도달하는 현상을 근사한다.

```text
열린 Surface → AO 1 → Indirect Light 유지
깊은 틈      → AO 0에 가까움 → Indirect Light 감소
```

AO를 모든 Direct Light에 무조건 곱하면 Light가 틈을 직접 비추는 상황까지 부자연스럽게 어두워질 수 있다.

Pipeline의 AO가 Direct와 Indirect에 어떻게 적용되는지 확인해야 한다.

Albedo Texture에 AO를 강하게 Bake하면 Lighting과 분리해 제어하기 어렵고 그림자가 중복될 수 있다.

AO는 목차의 다섯 핵심 입력 밖에 있지만 PBR Material 제작에서 자주 함께 Packing되는 Data다.

---

## Emission은 에너지 보존의 예외일까?

Emission은 Surface가 외부 Light를 반사하는 것이 아니라 스스로 빛을 내는 항이다.

```text
Final Surface
= Reflected Direct Light
 + Reflected Indirect Light
 + Emission
```

Energy Conservation의 반사 제한을 넘어 밝은 값을 가질 수 있다.

HDR Emission은 Bloom을 만들 수 있지만 Material이 Scene을 실제로 밝히려면 Baked GI, Realtime GI 지원 또는 별도 Light가 필요할 수 있다.

화면에서 밝게 보이는 것과 주변에 Light Energy를 전달하는 것은 같은 기능이 아니다.

---

## Unity URP의 PBR Shader

Unity 6 URP는 여러 Shading Model을 제공한다.

| Shader 계열 | Shading 방식 | 특징 |
| --- | --- | --- |
| Lit | Physically Based Shading | 현실적인 Material과 Reflection |
| Simple Lit | Simple Shading | 단순한 Specular와 낮은 비용 |
| Baked Lit | Baked Lighting 중심 | Realtime Light 계산 제한 |
| Unlit | Lighting 없음 | 입력 Color를 직접 표현 |

URP Lit과 Particles Lit은 물리 기반 Shading을 사용한다.

Lit Material에서는 Metallic 또는 Specular Workflow, Smoothness와 Normal Map을 설정할 수 있다.

Shader Graph의 Lit Target도 Base Color, Metallic 또는 Specular Color, Smoothness와 Normal 입력을 제공한다.

구체적인 URP Lit의 SurfaceData, InputData와 Fragment Lighting 흐름은 다음 글에서 이어진다.

---

## Material 제작 예시

### 거친 나무

```text
Albedo     = 나뭇결 고유 색
Metallic   = 0
Smoothness = 낮음
Normal     = 나뭇결의 미세 요철
```

넓고 약한 Specular와 뚜렷한 Diffuse가 나타난다.

### 깨끗한 플라스틱

```text
Albedo     = 플라스틱 색
Metallic   = 0
Smoothness = 중간 또는 높음
Normal     = 제조 표면에 따라 약하게
```

Diffuse Color 위에 색이 거의 없는 선명한 Specular가 보인다.

### 도색된 금속

페인트 층은 비금속이고 벗겨진 부분만 금속이다.

```text
Paint Area
├─ Metallic = 0
└─ Base Color = Paint Color

Exposed Metal
├─ Metallic = 1
└─ Base Color = Metal Reflection Color
```

Scratch Mask를 이용해 두 영역을 구분할 수 있다.

### 녹슨 금속

순수 금속 영역은 Metallic 1에 가깝지만 녹은 비금속 산화물이다.

```text
Metal = Metallic 1
Rust  = Metallic 0
```

모든 영역을 중간 Metallic으로 칠하는 것보다 Material 종류를 구분하는 편이 자연스럽다.

---

## Texture 제작과 검증

PBR Texture는 중립적인 Lighting 환경에서 검증하는 편이 좋다.

```text
검증 환경
├─ 중립적인 HDR Sky
├─ 밝기 기준이 명확한 Main Light
├─ Reflection Probe
├─ 여러 Exposure 조건
└─ Smooth와 Rough Reference Object
```

한 Environment에서만 맞추면 Texture 오류를 Lighting으로 가릴 수 있다.

밝은 야외, 어두운 실내와 색이 있는 Light에서도 Material 정체성이 유지되는지 확인한다.

Albedo Histogram, Metallic의 0/1 구분, Smoothness Channel과 Normal 방향을 각각 Debug View로 확인하면 원인을 분리하기 쉽다.

---

## 자주 생기는 문제

### 금속이 검게 보인다

금속은 Diffuse보다 Environment Reflection에 의존한다.

Skybox, Reflection Probe, Probe Blend와 Exposure를 확인한다.

### 거친 부분이 반짝이고 매끄러운 부분이 흐리다

Roughness Map을 Smoothness로 반전하지 않았을 가능성이 있다.

Texture Channel과 Shader 입력 정의를 확인한다.

### Object 회전 시 Lighting이 틀어진다

Normal Map의 Tangent Space 변환, Green Channel 방향 또는 Texture Type이 잘못됐을 수 있다.

### 재질이 조명마다 다른 색으로 무너진다

Albedo에 기존 Lighting과 Reflection이 그려져 있거나 값의 범위가 과도할 수 있다.

Linear Color Space와 Texture sRGB 설정도 확인한다.

### 페인트가 금속처럼 보인다

금속 Object 위의 페인트라는 이유로 Paint 영역까지 Metallic 1로 설정했을 수 있다.

표면에서 실제로 Light와 접촉하는 최상단 Material의 성질을 기록해야 한다.

### Normal Detail은 보이지만 Silhouette가 평평하다

Normal Map은 Lighting Normal만 바꾸며 실제 Geometry를 변경하지 않는다.

큰 형태는 Mesh, Displacement 또는 Parallax 계열 기법이 필요하다.

---

## PBR Material 디버깅 순서

최종 Lighting을 한 번에 보지 않고 입력을 분리한다.

```text
1. Base Color만 출력
2. Metallic을 Grayscale로 출력
3. Smoothness 또는 Roughness 출력
4. World Normal을 0~1로 Remap해 출력
5. Direct Diffuse만 출력
6. Direct Specular만 출력
7. Indirect Diffuse만 출력
8. Environment Reflection만 출력
9. 최종 결과 결합
```

예를 들어 금속이 검을 때 Direct Diffuse를 높이는 대신 Environment Reflection 단계가 0인지 먼저 확인할 수 있다.

Frame Debugger는 어떤 Pass와 Light가 적용되었는지 확인하고 GPU Capture는 실제 Texture와 Shader 입력을 검사하는 데 유용하다.

---

## PBR의 성능 비용

PBR은 단순 Lambert나 Blinn-Phong보다 복잡한 BRDF를 사용한다.

```text
PBR Fragment Cost
├─ Material Texture Sample
├─ Normal Transform
├─ Diffuse BRDF
├─ GGX Specular BRDF
├─ Light Loop
├─ Shadow Sample
├─ GI / Probe Sample
└─ Reflection Probe Sample
```

Material 입력이 많으면 Texture Sample과 Memory Bandwidth도 늘어난다.

여러 Realtime Light가 있으면 Direct BRDF가 Light마다 반복된다.

Smoothness와 Metallic 자체는 단순 값이지만 이 값이 활성화하는 Reflection, Specular와 Shader Variant 구성이 전체 비용에 영향을 준다.

---

## 최적화 관점

### 필요한 Shading Model을 선택한다

현실적인 Material과 Reflection이 중요하지 않은 Object에는 Simple Lit, Baked Lit 또는 Unlit이 더 적합할 수 있다.

중요한 Character와 가까운 Prop에는 Lit을 유지한다.

### Texture Channel을 Packing한다

Metallic, Smoothness와 Occlusion 같은 Scalar Data를 Channel에 Packing하면 Sample 수를 줄일 수 있다.

압축 품질과 각 Channel의 해상도 요구를 확인해야 한다.

### 불필요한 기능을 비활성화한다

Normal Map, Detail Map, Clear Coat와 Environment Reflection이 필요하지 않은 Material에서는 관련 기능과 Variant를 줄일 수 있다.

### Realtime Light와 Shadow를 관리한다

PBR BRDF는 영향을 주는 Light마다 반복된다.

Light Range, Culling Mask, Rendering Layer와 Shadow 사용을 제한한다.

### Probe 배치를 최적화한다

Reflection Probe를 무조건 많이 두기보다 공간별로 필요한 Resolution, Blending과 Update Mode를 정한다.

Realtime Probe 갱신은 Scene을 Cubemap의 여러 방향으로 다시 Rendering할 수 있어 비싸다.

### Texture 해상도를 용도에 맞춘다

모든 PBR Map이 같은 해상도를 필요로 하지는 않는다.

화면 크기와 Detail 빈도에 맞춰 Albedo, Normal과 Mask Map의 해상도를 결정한다.

### 측정으로 선택한다

Shader의 수식 복잡도뿐 아니라 Texture Bandwidth, Overdraw, Light 수와 Shadow Pass를 GPU Profiler와 Frame Debugger로 확인한다.

---

## 흔한 오해

### PBR을 사용하면 자동으로 사실적으로 보인다

PBR은 일관된 규칙을 제공하지만 Texture 값, Lighting, Reflection Probe, Exposure와 Tone Mapping이 잘못되면 결과도 잘못된다.

### Metallic은 광택 값이다

Metallic은 금속과 비금속의 반사 구조를 선택한다.

Highlight의 흐림과 선명함은 Smoothness 또는 Roughness가 담당한다.

### Smoothness가 0이면 Specular가 없다

거친 Surface도 Specular Energy를 넓게 분산한다.

Peak가 낮고 흐려서 눈에 덜 띌 뿐 완전히 사라지는 것과는 다르다.

### Normal Map은 Surface를 실제로 울퉁불퉁하게 만든다

Normal Map은 Lighting 계산에 사용하는 방향만 바꾸며 Geometry와 Silhouette는 그대로다.

### Albedo는 사진을 그대로 넣으면 된다

사진에는 촬영 환경의 Shadow, Highlight와 White Balance가 포함될 수 있다.

Surface 고유 색으로 정리하고 물리적으로 타당한 범위를 유지해야 한다.

### PBR은 특정 Render Pipeline 전용이다

PBR은 Rendering 접근법이며 Built-in, URP, HDRP와 Custom Pipeline에서 각기 다른 구현으로 사용할 수 있다.

---

## 전체 처리 흐름

PBR Material이 화면 Color로 변환되는 흐름은 다음과 같다.

```text
Texture / Material Properties
├─ Albedo / Base Color
├─ Metallic 또는 Specular Color
├─ Smoothness / Roughness
├─ Normal
├─ Occlusion
└─ Emission
              │
              ▼
      Surface Data 구성
              │
              ├──────── View Direction
              ├──────── Direct Light Data
              └──────── GI / Environment Data
              │
              ▼
   Diffuse BRDF + Specular BRDF
   Energy Conservation + Fresnel
              │
              ├─ Direct Diffuse
              ├─ Direct Specular
              ├─ Indirect Diffuse
              └─ Indirect Specular
              │
              ▼
        Emission과 결합
              │
              ▼
       Linear HDR Color
              │
       Fog / Post Processing
              │
              ▼
          Display Color
```

PBR의 핵심은 각각의 Texture가 최종 밝기를 직접 그리는 것이 아니라 Surface의 물리적 성질을 기록하고, Shader가 현재 Lighting 환경에서 결과를 계산하게 만드는 것이다.

---

## 정리

PBR은 빛과 Surface의 상호작용을 물리 원칙에 따라 근사해 서로 다른 Lighting 환경에서도 Material을 일관되게 표현하는 Rendering 방식이다.

BRDF는 Light Direction에서 들어온 빛이 View Direction으로 얼마나 반사되는지를 Material과 Surface 방향을 이용해 계산한다.

에너지 보존은 Emission이 없는 Surface의 반사 Energy가 들어온 Energy를 넘지 않도록 Diffuse와 Specular를 분배한다.

Microfacet Model은 Surface를 작은 Mirror 면의 분포로 보고 Roughness에 따른 Specular Highlight의 모양을 계산한다.

URP의 Physically Based Shading은 GGX 계열 함수를 사용해 Specular 분포를 근사한다.

Albedo는 Surface의 기본 색이며 비금속에서는 Diffuse, 금속에서는 주로 Specular Color에 사용된다.

Metallic은 금속과 비금속의 반사 구조를 구분하며 단순한 Reflection Strength 값이 아니다.

Smoothness가 높으면 좁고 선명한 반사, Roughness가 높으면 넓고 흐린 반사가 만들어진다.

Normal은 Diffuse 입사각, Microfacet Specular와 Environment Reflection 방향에 모두 영향을 준다.

Metallic Workflow는 Base Color와 Metallic으로 Diffuse·Specular를 나누고 Specular Workflow는 Specular Color를 직접 제공한다.

Direct PBR Lighting만으로는 금속과 매끄러운 Surface를 충분히 표현하기 어려우며 Lightmap, Probe, Skybox와 Reflection Probe 기반 Indirect Lighting이 중요하다.

Unity 6 URP에서는 Lit 계열 Shader가 PBR을 사용하며 Simple Lit, Baked Lit과 Unlit은 품질 목표와 성능 예산에 따라 선택한다.

PBR의 실제 비용은 BRDF 연산뿐 아니라 Material Texture Sample, Realtime Light Loop, Shadow와 Environment Reflection에서 발생한다.
