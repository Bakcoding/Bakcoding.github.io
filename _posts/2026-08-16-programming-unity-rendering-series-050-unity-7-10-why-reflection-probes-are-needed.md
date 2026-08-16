---
title: "[Unity 렌더링] 7-10. Reflection Probe는 왜 필요할까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - Lighting
  - ReflectionProbe
  - Cubemap
permalink: /programming/unity-7-10-why-reflection-probes-are-needed/
toc: true
toc_sticky: true
date: 2026-08-16
last_modified_at: 2026-08-16
---

Reflection Probe는 Scene의 주변 환경을 Cubemap으로 Capture해 Material의 간접 Specular Reflection에 사용한다.

Skybox 하나만 사용하면 실내의 금속과 매끄러운 Surface에도 야외 하늘이 반사될 수 있다.

```text
Skybox Reflection
└─ Scene 전체의 기본 환경

Reflection Probe
└─ 특정 공간의 Local Environment
```

Probe를 방, 복도와 건물 내부에 배치하면 Object가 현재 위치와 가까운 환경을 반사하도록 만들 수 있다.

---

## Reflection Probe가 필요한 이유

Specular는 Light Source의 Highlight뿐 아니라 주변 환경 전체의 반사를 포함한다.

```text
Specular Lighting
├─ Direct Specular
│  └─ Directional / Point / Spot Light
└─ Indirect Specular
   └─ Skybox / Reflection Probe
```

금속은 Diffuse가 거의 없으므로 Environment Reflection이 재질의 형태와 색을 드러내는 데 특히 중요하다.

Reflection Probe가 없거나 환경이 검으면 Metallic Material도 검게 보일 수 있다.

Light를 더 밝히는 것만으로는 주변 공간의 반사 형태를 대신할 수 없다.

---

## Light Probe와 무엇이 다를까?

| 구분 | Light Probe | Reflection Probe |
| --- | --- | --- |
| 주요 역할 | Indirect Diffuse | Indirect Specular |
| 저장 데이터 | SH 계수 | Cubemap |
| 입력 방향 | Surface Normal | Reflection Vector |
| 표현 | 부드러운 간접광 | 환경의 선명하거나 흐린 반사 |

```text
Dynamic Lit Object
├─ Light Probe      → 어두운 면의 Baked Diffuse GI
└─ Reflection Probe → 금속과 광택의 Environment Reflection
```

두 Probe는 이름만 비슷할 뿐 서로 다른 Lighting Lobe를 담당한다.

---

## Cubemap이란?

Cubemap은 한 지점을 중심으로 여섯 방향의 이미지를 저장한 Texture다.

```text
Cubemap Faces
├─ +X
├─ -X
├─ +Y
├─ -Y
├─ +Z
└─ -Z
```

육면체를 펼치면 다음과 같은 구조로 볼 수 있다.

```text
        +Y
 -X  +Z  +X  -Z
        -Y
```

Shader는 2D UV가 아니라 3D Direction Vector로 Cubemap을 Sample한다.

```hlsl
half3 environment = SAMPLE_TEXTURECUBE(
    _EnvironmentCube,
    sampler_EnvironmentCube,
    reflectionDirection);
```

어느 방향을 바라보는 반사인지에 따라 Cubemap의 적절한 Face와 Texel이 선택된다.

---

## Reflection Vector는 어떻게 만들까?

Surface에서 Camera로 향하는 View Direction `V`와 World Normal `N`을 사용한다.

```hlsl
half3 R = reflect(-V, N);
```

```text
Camera
   ●
    ╲ V
     ╲
──────●────── Surface
      ↑╲
      N ╲ R
```

`-V`는 Camera에서 Surface로 들어오는 방향이고 `reflect`가 이를 Normal에 대해 반사한다.

결과 `R`은 Surface가 반사해 보여 줄 Environment 방향이다.

Normal Map이 바뀌면 Reflection Vector도 바뀌므로 작은 Scratch와 요철이 반사 모양에 나타난다.

---

## Roughness는 Cubemap Sample을 어떻게 바꿀까?

매끄러운 Surface는 좁은 방향의 Environment를 선명하게 반사한다.

거친 Surface는 주변 여러 방향의 빛을 넓게 섞어 반사한다.

```text
Smooth Surface → 선명한 Cubemap
Rough Surface  → 흐린 Cubemap
```

매 Fragment마다 주변 방향을 수백 번 Sample하는 것은 비싸다.

Unity는 Roughness 단계별로 미리 Filtering한 Cubemap Mip Level을 사용한다.

```text
Mip 0 → 선명한 Reflection
Mip 1 → 조금 흐림
Mip 2 → 더 흐림
...
```

Smoothness가 높으면 선명한 Mip, Roughness가 높으면 흐린 Mip을 선택한다.

이 과정을 Prefiltered Environment Map Sample로 볼 수 있다.

---

## Reflection Probe는 어떻게 Capture할까?

Probe Origin을 Camera 위치처럼 사용해 Scene을 여섯 방향으로 Rendering한다.

```text
Scene Geometry
      │
Probe Origin에서 6 Direction Rendering
      │
      ▼
HDR Cubemap
      │ Prefilter / Mip 생성
      ▼
Material에서 Sample
```

Culling Mask, Near·Far Clip, Shadow Distance와 HDR 설정이 Capture 결과에 영향을 준다.

Probe 자체가 화면에 보이는 구체를 만드는 것은 아니며 Cubemap Data를 제공하는 Component다.

---

## Probe Origin과 Influence Volume

Reflection Probe에는 Capture 중심인 Origin과 영향을 주는 Box Volume이 있다.

```text
Influence Volume
┌──────────────────┐
│       ● Origin   │
│                  │
└──────────────────┘
```

Origin은 Cubemap이 촬영된 관찰 지점이다.

Volume은 어떤 Scene Pixel이 이 Cubemap의 영향을 받을지 정한다.

방 안 Probe의 Volume이 벽 밖까지 나가면 야외 Object가 실내 Reflection을 받을 수 있다.

Volume을 실제 공간 경계에 맞추고 Origin은 방을 대표하는 위치에 둔다.

---

## URP는 Volume 영향도를 어떻게 계산할까?

URP는 Object 전체가 아니라 각 Pixel이 Probe Box 안 어디에 있는지에 따라 Probe 영향도를 계산한다.

Probe Volume 밖의 Pixel은 기본 Skybox Reflection을 사용한다.

```text
Probe Box 밖    → Probe Weight 0
Box 경계        → Probe Weight 0에 가까움
Box 내부 중심부 → Probe Weight 1 가능
```

큰 Object가 Volume 경계를 가로질러도 Pixel 위치에 따라 Reflection이 전환될 수 있다.

이는 Object 단위로 Probe를 선택하던 단순한 방식보다 공간 전환을 자연스럽게 만든다.

---

## Blend Distance

Blend Distance는 Probe Box 경계에서 내부로 들어오며 영향도가 증가하는 거리다.

```text
Box Face
│ Probe 0%
│╲
│ ╲ Blend Distance
│  ╲
│   Probe 100%
```

값이 너무 작으면 Volume 경계에서 Reflection이 갑자기 바뀐다.

값이 너무 크면 작은 Volume 안에서 Probe Weight가 100%에 도달하지 못할 수 있다.

공간 크기와 인접 Probe의 겹침을 고려해 설정한다.

---

## 여러 Probe가 겹치면 어떻게 될까?

URP에서 한 Object에 여러 Probe Volume이 겹치면 최대 두 Probe가 영향을 줄 수 있다.

선택 기준은 다음 순서로 볼 수 있다.

```text
1. Importance가 높은 Probe
2. Importance가 같으면 더 작은 Volume
3. 조건이 같으면 Object Surface를 더 많이 포함한 Volume
```

두 Probe가 선택되면 Pixel의 Box 경계 거리와 Blend Distance를 이용해 Weight를 계산한다.

두 Weight의 합이 1보다 작으면 남은 Weight는 Environment Cubemap, 일반적으로 Skybox Reflection에 배분된다.

```text
Final Reflection
= Probe A × weightA
 + Probe B × weightB
 + Skybox × remainingWeight
```

---

## Importance는 언제 사용할까?

Importance는 겹치는 Probe 중 어떤 공간의 Reflection을 우선할지 정한다.

```text
큰 야외 Probe Importance 0
작은 실내 Probe Importance 1

실내 겹침 영역 → 실내 Probe 우선
```

모든 Probe의 Importance를 무작정 높이면 상대적인 우선순위 의미가 사라진다.

작은 방, 특수 공간과 Hero Object 주변처럼 반드시 선택되어야 하는 Probe에 높은 값을 사용한다.

---

## Box Projection이 필요한 이유

Cubemap은 모든 반사광이 Probe Origin에서 무한히 먼 곳에 있다고 가정하기 쉽다.

Skybox에는 적합하지만 가까운 벽이 있는 실내에서는 반사 위치가 Object 이동에 맞지 않는다.

```text
Probe Origin ●
Object       ▲ 이동

단순 Cubemap → 같은 방향 Sample
벽 반사 위치가 고정되어 떠 보임
```

Box Projection은 Object Position과 Probe Box를 사용해 Reflection Ray가 Box 벽과 만나는 위치를 근사하고 Sample Direction을 보정한다.

직사각형 방과 복도에서 반사 Parallax를 개선한다.

---

## Box Projection의 한계

Box Projection은 Scene을 Box 형태로 근사한다.

원형 방, 복잡한 계단과 여러 깊이의 Geometry를 정확하게 재구성하지는 않는다.

```text
잘 맞는 공간
└─ 직사각형 방과 복도

오차가 큰 공간
└─ 복잡한 비정형 Geometry
```

Reflection Probe는 Screen Space Reflection이나 Ray Tracing처럼 실제 반사 Ray가 Scene Geometry에 닿는 지점을 추적하지 않는다.

Capture Origin과 실제 Surface 위치 차이에서 Parallax Error가 남는다.

---

## Baked Reflection Probe

Baked Probe는 Editor에서 Cubemap을 Capture하고 Asset으로 저장한다.

```text
Editor Bake → Static Cubemap → Runtime Sample
```

Runtime에 Scene을 여섯 방향으로 다시 Rendering하지 않아 비용이 낮다.

Reflection Probe Static으로 표시된 고정 Object가 Capture 대상이 된다.

움직이는 Object는 Cubemap 안에서 이동하지 않지만 정적인 환경 반사를 제공하는 용도로 충분한 경우가 많다.

대부분의 실내와 고정 Environment에서는 Baked Probe를 기본으로 사용할 수 있다.

---

## Custom Reflection Probe

Custom Probe는 직접 지정한 Cubemap 또는 Editor에서 준비한 고정 Capture를 사용한다.

```text
Custom HDRI / DCC Cubemap
          │
          ▼
Reflection Probe Cubemap
```

Scene에서 직접 Capture하기 어려운 Stylized Reflection과 일관된 Product Rendering에 유용하다.

Dynamic Objects 옵션을 통해 Bake 시점의 Dynamic Object를 포함할 수 있지만 결과는 여전히 고정된다.

Runtime 변화에 따라 자동 갱신되는 Probe는 아니다.

---

## Realtime Reflection Probe

Realtime Probe는 Runtime에 Cubemap을 다시 Rendering해 Scene 변화를 반영한다.

```text
Realtime Probe Update
├─ +X Render
├─ -X Render
├─ +Y Render
├─ -Y Render
├─ +Z Render
├─ -Z Render
└─ Cubemap Filtering / Mip
```

Scene을 여섯 방향으로 추가 Rendering하므로 매우 비쌀 수 있다.

Probe Resolution, Culling Mask, Shadow, 보이는 Object 수와 Update 주기가 비용에 영향을 준다.

Every Frame 갱신은 특별한 효과가 아니라면 피하고 On Awake 또는 Via Scripting으로 필요한 순간만 갱신한다.

---

## Time Slicing

Time Slicing은 Realtime Probe의 여섯 Face Capture와 후처리를 여러 Frame에 나누어 수행한다.

```text
Frame 1 → Face +X
Frame 2 → Face -X
...
Frame N → Filtering 완료
```

한 Frame의 큰 Spike를 줄이는 대신 Cubemap 전체가 갱신되기까지 시간이 걸린다.

빠르게 변하는 환경에서는 Face별 시간 차이로 Reflection이 일시적으로 불일치할 수 있다.

Gameplay 변화 속도와 Frame Budget을 기준으로 Update Mode를 선택한다.

---

## Resolution의 영향

Cubemap Resolution은 한 Face의 가로와 세로 크기다.

전체 Pixel 수는 여섯 Face와 Mip Chain을 포함한다.

```text
Base Cubemap Pixel
= Resolution × Resolution × 6
```

Resolution을 두 배로 높이면 Base Pixel 수는 네 배가 된다.

Capture Rendering, Filtering, Memory와 Sample Cache 비용이 함께 증가할 수 있다.

거친 Material만 있는 공간에서는 높은 Resolution의 Detail이 흐린 Mip에서 사라지므로 낭비가 될 수 있다.

---

## HDR이 필요한 이유

Reflection에는 태양, 조명과 밝은 창문처럼 1보다 큰 Light Energy가 포함될 수 있다.

LDR Cubemap에 Clamp하면 매우 밝은 Source와 주변 밝기의 차이를 잃는다.

```text
HDR Reflection
├─ 밝은 Light Energy 유지
├─ Roughness Filtering 품질
└─ Tone Mapping과 자연스럽게 결합
```

HDR Format은 더 많은 Memory를 사용할 수 있으므로 Platform 압축 지원과 품질을 확인한다.

---

## Culling Mask와 Shadow Distance

Realtime 또는 Baked Capture에 포함할 Layer를 Culling Mask로 제한할 수 있다.

```text
Capture 포함
├─ Environment
├─ 중요한 Prop
└─ Skybox

Capture 제외 가능
├─ UI
├─ 보이지 않는 Effect
└─ Reflection에 불필요한 Layer
```

Realtime Probe에서 불필요한 Object와 Shadow Distance를 줄이면 여섯 Face Rendering 비용을 낮출 수 있다.

Probe 자체, 반사 전용 Proxy Geometry와 특정 Effect가 재귀적으로 보이지 않도록 Layer 구성을 점검한다.

---

## Reflection Probe와 PBR

PBR Shader는 Reflection Vector, Roughness, Fresnel과 Material Specular Color를 결합한다.

```text
Environment Sample
× Fresnel
× Specular Color
× Visibility / Occlusion
= Indirect Specular
```

Metallic Workflow에서는 Base Color가 금속 Reflection을 Tint한다.

비금속도 Grazing Angle에서 Fresnel Reflection이 강해진다.

Probe Cubemap을 그대로 최종 Color로 출력하는 것이 아니라 BRDF에 맞춰 Filter와 Energy 보정을 거친다.

---

## URP Custom Shader에서 Sample하기

URP는 Global Illumination Shader Library에 Environment Reflection Helper를 제공한다.

```hlsl
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/GlobalIllumination.hlsl"
```

개념적인 흐름은 다음과 같다.

```hlsl
half3 R = reflect(-viewDirectionWS, normalWS);
half perceptualRoughness = 1.0h - smoothness;

half3 environment = GlossyEnvironmentReflection(
    R,
    positionWS,
    perceptualRoughness,
    occlusion,
    normalizedScreenSpaceUV);
```

정확한 Signature는 URP Package Version에 따라 달라질 수 있다.

Position과 Screen UV는 Probe Blending과 Pipeline 기능에 사용될 수 있다.

---

## Probe 배치 기준

```text
배치가 필요한 곳
├─ 실내와 실외 경계
├─ 서로 다른 방
├─ 긴 복도와 코너
├─ 밝은 창문 주변
├─ 금속 Object가 많은 공간
└─ 환경 색이 크게 달라지는 구역
```

큰 Scene 전체를 Probe 하나로 Capture하면 Local Environment와 Parallax가 맞지 않는다.

반대로 작은 Probe를 지나치게 많이 겹치면 선택과 Blending 비용, Cubemap Memory와 관리 복잡도가 증가한다.

공간 단위로 대표 환경을 정하고 Volume 경계를 실제 벽과 문에 맞춘다.

---

## 자주 생기는 문제

### 실내 금속에 하늘이 보인다

실내 Probe Volume이 해당 Pixel을 포함하지 않거나 Blend Weight가 부족할 수 있다.

Volume, Blend Distance와 Importance를 확인한다.

### Volume 경계에서 Reflection이 튄다

Probe Blending이 비활성화되었거나 Blend Distance가 너무 작을 수 있다.

인접 Probe의 Capture 밝기와 Exposure 차이도 줄인다.

### 반사 속 벽 위치가 밀린다

Capture Origin과 Object 위치의 Parallax Error다.

Box Projection을 활성화하고 Probe Origin과 Box Size를 방에 맞춘다.

### 움직인 Object가 Reflection에 남는다

Baked 또는 Custom Cubemap은 Bake 시점에 고정된다.

다시 Bake하거나 제한적으로 Realtime Probe를 사용한다.

### Reflection이 흐리다

Material Roughness, Cubemap Resolution, Compression과 Mip 상태를 확인한다.

### Realtime Probe를 켠 뒤 Frame이 느려졌다

여섯 Face Scene Rendering과 Filtering이 추가된다.

Update Mode, Time Slicing, Resolution, Culling Mask와 Shadow를 줄인다.

---

## 디버깅 순서

```text
1. Material의 Metallic / Smoothness 확인
2. Renderer의 Reflection Probe 사용 설정 확인
3. Pixel이 Probe Volume 안에 있는지 확인
4. Importance와 선택된 Probe 확인
5. Blend Distance 확인
6. Cubemap Preview 확인
7. Box Projection On/Off 비교
8. Skybox Weight와 Exposure 확인
9. Realtime Update Pass Profile
```

Chrome Sphere와 Rough Sphere를 같은 위치에 두면 Cubemap 방향, 선명도와 Roughness Mip을 비교하기 쉽다.

Frame Debugger와 GPU Capture로 실제 Environment Texture와 Mip Level, Shader Variant를 확인한다.

---

## 최적화 관점

### Baked Probe를 기본으로 사용한다

환경이 고정되어 있다면 Runtime Capture 없이 좋은 Reflection을 얻을 수 있다.

### Realtime Update를 Event 기반으로 제한한다

문이 열리거나 Lighting 상태가 바뀐 직후처럼 필요한 순간만 Script로 갱신한다.

### Resolution을 Material에 맞춘다

Rough Surface가 대부분이면 낮은 Resolution도 충분할 수 있다.

### Culling Mask를 줄인다

Reflection에 의미 없는 Layer와 복잡한 Effect를 Capture에서 제외한다.

### Probe Blending과 Box Projection을 Platform별로 조절한다

Unity 공식 성능 지침은 저사양 모바일에서 두 기능을 끄는 선택을 제시한다.

시각적 차이와 GPU 시간을 비교한다.

### Probe 중첩을 관리한다

최대 두 Probe 선택과 Skybox Weight를 고려해 Volume과 Importance를 단순하게 구성한다.

---

## 흔한 오해

### Reflection Probe는 거울을 만든다

Cubemap 기반 근사 Reflection을 제공하며 실제 반사 Ray가 Geometry를 추적하지 않는다.

평면 거울에는 Planar Reflection 같은 별도 기법이 더 적합하다.

### Probe가 Object를 실시간으로 비춘다

주 역할은 Environment Specular다.

Diffuse GI는 Light Probe, APV와 Lightmap이 담당한다.

### Realtime Probe는 Capture 한 번이면 저렴하다

한 번의 갱신도 Scene을 여섯 방향으로 Rendering하고 Cubemap을 Filtering해야 한다.

### Resolution만 높이면 Parallax가 해결된다

Parallax Error는 Capture 위치와 실제 Surface 위치 차이이므로 더 선명하게 잘못 보일 수 있다.

### Probe를 많이 겹치면 항상 자연스럽다

URP는 우선순위 규칙으로 최대 두 Probe를 선택하며 Memory와 Blending 비용도 증가한다.

---

## 전체 처리 흐름

```text
Probe Capture
Scene을 Origin에서 6 Direction Rendering
                  │
                  ▼
              HDR Cubemap
                  │ Roughness Prefilter
                  ▼
             Cubemap Mip Chain
                  │
────────────── Runtime ──────────────
                  │
Pixel Position → Probe Volume / Weight
                  │
Normal + View → Reflection Vector
Smoothness    → Roughness Mip
                  │
                  ▼
        Probe A / Probe B / Skybox Sample
                  │
          Weight로 Reflection Blend
                  │
       Fresnel / Specular Color / AO
                  │
                  ▼
            Indirect Specular
                  │
       Direct + Indirect Diffuse와 결합
                  │
                  ▼
             Final Lit Color
```

Reflection Probe는 한 지점에서 Capture한 환경을 주변 Volume의 Pixel에 재사용해 Ray Tracing 없이 Local Environment Reflection을 근사한다.

---

## 정리

Reflection Probe는 주변 Scene을 여섯 방향 Cubemap으로 Capture해 PBR Material의 Indirect Specular Reflection에 사용한다.

Light Probe는 SH 기반 Indirect Diffuse, Reflection Probe는 Cubemap 기반 Indirect Specular를 담당한다.

Shader는 View Direction을 Normal에 반사한 Vector로 Cubemap을 Sample하고 Roughness에 따라 미리 Filtering된 Mip Level을 선택한다.

Probe Origin은 Capture 위치이고 Box Volume은 Probe가 영향을 주는 공간을 정의한다.

URP는 Pixel과 Box 경계의 거리를 이용해 Probe Weight를 계산하고 겹치는 경우 최대 두 Probe를 Importance와 Volume 기준으로 선택한다.

선택된 Probe Weight의 합이 부족하면 남은 비율은 일반적으로 Skybox Environment Reflection에 배분된다.

Blend Distance는 Volume 경계의 Reflection 전환을 부드럽게 하고 Box Projection은 직사각형 실내의 Parallax Error를 줄인다.

Baked Probe는 Editor에서 고정 Cubemap을 만들어 Runtime 비용이 낮고 Custom Probe는 지정된 Cubemap을 사용한다.

Realtime Probe는 Scene 변화를 반영하지만 갱신할 때 여섯 Face Rendering과 Filtering이 필요하므로 Resolution과 Update 주기를 엄격히 관리해야 한다.

Probe는 실제 Geometry와 반사 Ray의 교차를 계산하지 않으므로 복잡한 공간, 가까운 벽과 평면 거울에서는 근사 오차가 남는다.

공간 경계에 맞는 Volume, 적절한 Importance와 최소한의 Probe 중첩을 사용하고 저사양 Platform에서는 Blending과 Box Projection 비용을 측정해야 한다.
