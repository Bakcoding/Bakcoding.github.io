---
title: "[Unity 렌더링] 8-1. 그림자는 어떻게 만들어질까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - Shadow
  - ShadowMap
  - DepthTexture
permalink: /programming/unity-8-1-how-shadows-are-created/
toc: true
toc_sticky: true
date: 2026-08-16
last_modified_at: 2026-08-16
---

그림자는 Light에서 Surface까지 가는 경로가 다른 Geometry에 의해 막혔을 때 만들어진다.

Rasterization Pipeline은 Camera Pixel에서 Light까지 실제 Ray를 매번 추적하는 대신 Light가 볼 수 있는 가장 가까운 Depth를 Texture에 저장한다.

```text
Light 관점 Depth 생성
        │
        ▼
     Shadow Map
        │
Camera Fragment의 Light Depth와 비교
        │
        ▼
 Lit 또는 Shadow 판정
```

이 방식을 Shadow Mapping이라고 한다.

---

## 그림자는 무엇을 의미할까?

Surface Point `P`가 Light를 직접 볼 수 있으면 Direct Lighting을 받는다.

중간에 Occluder가 있으면 해당 Light의 Direct Contribution이 줄어든다.

```text
Light ─────────────▶ Surface A
      경로가 열림      Lit

Light ──▶ Occluder ── Surface B
          경로 차단     Shadow
```

Shadow는 Surface Color를 검게 칠하는 별도 Material이 아니다.

```text
Direct Light Contribution
× Shadow Attenuation
```

Shadow 안에서도 Lightmap, Light Probe, Environment Reflection과 Emission이 남을 수 있다.

---

## 왜 Light 관점에서 Scene을 그릴까?

Light에서 보이는 첫 번째 Surface는 Light Ray가 가장 먼저 만나는 Geometry다.

그 뒤에 있는 Surface는 같은 Light 방향에서 가려진다.

```text
Light Camera
     │
     ▼
Near Surface   → Depth 0.3 저장
Far Surface    → Depth 0.7, 앞 Surface에 가림
```

Light 관점의 가장 가까운 Depth를 알고 있으면 Camera에서 보이는 Point가 그보다 뒤에 있는지 비교할 수 있다.

이 가시성 정보를 2D Depth Texture로 저장한 것이 Shadow Map이다.

---

## Shadow Map이란?

Shadow Map은 Light 관점에서 Rendering한 Depth Texture다.

```text
Shadow Map Texel
└─ 해당 Light Ray에서 가장 가까운 Caster의 Depth
```

일반 Color Texture처럼 Albedo와 Lighting Color를 저장하지 않는다.

Depth 값은 Light의 Projection과 Near·Far Plane에 의해 정규화된 형태로 저장될 수 있다.

```text
Shadow Map
┌───────────────┐
│ 가까움: 작은 값 │
│ 멀어짐: 큰 값   │
└───────────────┘
```

정확한 Encoding과 비교 방향은 Graphics API와 Pipeline의 Reversed Z 사용 여부에 따라 달라질 수 있으므로 URP Helper를 사용하는 편이 안전하다.

---

## Shadow Caster와 Receiver

Shadow 생성에는 두 역할이 있다.

| 역할 | 의미 |
| --- | --- |
| Shadow Caster | Shadow Map에 Depth를 기록하는 Object |
| Shadow Receiver | Shadow Map을 Sample해 Direct Light를 줄이는 Surface |

하나의 Object가 두 역할을 모두 할 수 있다.

```text
Character
├─ 바닥에 Shadow를 Cast
└─ 자신의 몸에서 Self Shadow를 Receive
```

Renderer의 Cast Shadows와 Material 또는 Shader의 Receive Shadows 경로는 별도다.

Caster를 꺼도 Object 자체는 화면에 보일 수 있고 Receiver를 꺼도 다른 Surface에는 Shadow를 만들 수 있다.

---

## ShadowCaster Pass

URP Shader가 Realtime Shadow를 만들려면 `ShadowCaster` LightMode Pass가 필요하다.

```shaderlab
Pass
{
    Name "ShadowCaster"
    Tags { "LightMode" = "ShadowCaster" }

    ZWrite On
    ZTest LEqual
    ColorMask 0
}
```

Shadow Pass는 Color가 아니라 Depth가 목적이므로 Color Write를 끌 수 있다.

Vertex Shader는 Object Position을 Light Clip Space로 변환하고 Bias를 적용한다.

```text
positionOS
    │ Object to World
    ▼
positionWS
    │ Light View Projection
    ▼
positionLightCS
    │ Rasterization
    ▼
Shadow Depth
```

---

## Alpha Clipping Caster

나뭇잎과 철망 Mesh는 Triangle 전체가 아니라 Alpha Texture 일부만 보여야 한다.

ShadowCaster Pass도 같은 Alpha Clip을 수행하지 않으면 사각형 Polygon 전체가 Shadow를 만든다.

```hlsl
half alpha = SAMPLE_TEXTURE2D(
    _BaseMap,
    sampler_BaseMap,
    uv).a * _BaseColor.a;

clip(alpha - _Cutoff);
```

```text
Color Pass Shape = 잎 모양
Shadow Pass Shape = 잎 모양
```

Vertex Animation, Wind, Dither와 Deformation도 Color Pass와 ShadowCaster Pass에서 일치해야 Shadow가 Object와 분리되지 않는다.

---

## 1단계: Light Space Matrix 만들기

Camera가 World를 View·Projection Matrix로 Clip Space에 옮기듯 Light도 자신의 View와 Projection을 가진다.

```text
World Position
× Light View Matrix
× Light Projection Matrix
= Light Clip Position
```

Light Type에 따라 Projection이 다르다.

| Light | Shadow Projection |
| --- | --- |
| Directional | Orthographic 계열 |
| Spot | Perspective Cone |
| Point | 여섯 방향 Perspective |

Directional Light는 위치보다 방향이 중요하고 Camera 주변 Shadow 영역을 Orthographic Volume으로 나눈다.

Point Light는 모든 방향을 표현하기 위해 Cubemap 여섯 Face가 필요하다.

---

## 2단계: Light 관점 Depth 기록

Light Frustum 안의 Shadow Caster를 Culling하고 ShadowCaster Pass로 Rendering한다.

```text
Light Frustum
     │ Caster Culling
     ▼
Visible Shadow Casters
     │ Draw
     ▼
Depth Test + Depth Write
     │
     ▼
Shadow Map 완성
```

같은 Texel에 여러 Triangle이 들어오면 Depth Test를 통과한 가장 가까운 Surface Depth가 남는다.

Lighting BRDF와 Material Color는 일반적으로 이 단계에 필요하지 않다.

---

## 3단계: Camera Fragment를 Shadow Space로 변환

Camera Color Pass에서는 현재 Fragment의 World Position을 Light Shadow Space로 변환한다.

```hlsl
float4 shadowCoord =
    TransformWorldToShadowCoord(positionWS);
```

또는 Vertex Position Input에서 Shadow Coordinate를 만들 수 있다.

```hlsl
float4 shadowCoord = GetShadowCoord(vertexPositionInputs);
```

Perspective Divide와 Atlas 변환을 거치면 Shadow Map을 Sample할 UV와 비교 Depth를 얻는다.

```text
shadowCoord
├─ xy → Shadow Map UV
└─ z  → 현재 Fragment의 Light Depth
```

---

## 4단계: Depth 비교

Shadow Map에서 저장된 가장 가까운 Depth와 현재 Fragment Depth를 비교한다.

```text
storedDepth  = Shadow Map의 Caster Depth
currentDepth = Receiver의 Light Space Depth
```

```text
currentDepth ≤ storedDepth + bias
→ Light에서 보이는 첫 Surface
→ Lit

currentDepth > storedDepth + bias
→ 앞에 다른 Surface가 있음
→ Shadow
```

```hlsl
half shadow = currentDepth <= storedDepth + bias
    ? 1.0h
    : 0.0h;
```

실제 Hardware Comparison Sampler와 Reversed Z에서는 내부 비교식이 다를 수 있다.

개념은 Receiver가 Light에서 가장 가까운 Surface인지 판단하는 것이다.

---

## Shadow Attenuation

비교 결과는 보통 0과 1 사이의 Shadow Attenuation으로 Lighting에 전달된다.

```text
1 → Light가 완전히 보임
0 → 완전히 가려짐
중간 값 → Soft Shadow / Strength / Fade
```

```hlsl
Light mainLight = GetMainLight(shadowCoord);
half shadow = mainLight.shadowAttenuation;

half3 directLighting =
    (diffuse + specular) *
    mainLight.color *
    mainLight.distanceAttenuation *
    shadow;
```

Shadow는 해당 Direct Light의 기여에 적용한다.

Emission과 다른 Light Source까지 같은 값으로 제거하면 안 된다.

---

## URP Shadow Helper

Unity 6 URP Custom Shader에서는 `Lighting.hlsl`을 Include해 Shadow Helper를 사용할 수 있다.

```hlsl
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
```

Main Light Shadow Variant도 준비한다.

```hlsl
#pragma multi_compile _ \
    _MAIN_LIGHT_SHADOWS \
    _MAIN_LIGHT_SHADOWS_CASCADE \
    _MAIN_LIGHT_SHADOWS_SCREEN

#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
```

Main Light Shadow를 직접 얻을 수 있다.

```hlsl
half shadowAmount = MainLightRealtimeShadow(shadowCoord);
```

또는 Shadow가 포함된 Light Data를 얻는다.

```hlsl
Light mainLight = GetMainLight(shadowCoord);
```

---

## Shadow Map과 Camera Depth Texture의 차이

둘 다 Depth Texture지만 관점과 목적이 다르다.

| 구분 | Shadow Map | Camera Depth Texture |
| --- | --- | --- |
| 관점 | Light | Camera |
| 저장 값 | Light에서 가장 가까운 Depth | Camera에서 가장 가까운 Depth |
| 목적 | Light Visibility와 Shadow | Screen-space Effect와 Position 복원 |
| 좌표 | Shadow UV | Screen UV |

```text
Shadow Map
Light → Scene Depth

Camera Depth Texture
Camera → Scene Depth
```

Camera Depth Texture만으로 Light 뒤의 Occluder 관계를 모든 방향에서 알 수 없으므로 일반 Shadow Map을 대체하지 못한다.

---

## Camera Depth Texture는 어떻게 만들어질까?

URP Asset의 Depth Texture를 활성화하면 `_CameraDepthTexture`를 생성할 수 있다.

Pipeline과 Platform에 따라 Opaque Pass Depth를 Copy하거나 Depth Prepass로 다시 Rendering한다.

```text
방법 A
Opaque Depth Buffer → Copy Depth → Camera Depth Texture

방법 B
DepthOnly Pass → Camera Depth Texture
```

Custom Shader가 Depth Prepass에 참여하려면 `DepthOnly` Pass가 필요할 수 있다.

```shaderlab
Tags { "LightMode" = "DepthOnly" }
ZWrite On
ColorMask 0
```

Color, Depth, Shadow Pass의 Vertex Deformation과 Alpha Clip이 같아야 각 Texture의 형태가 일치한다.

---

## Screen Space Shadow Texture

URP의 Screen Space Shadows Renderer Feature는 Main Light Shadow 결과를 화면 공간 Texture에 먼저 계산할 수 있다.

```text
Shadow Map + Camera Depth
          │
          ▼
Screen Space Shadow Texture
          │
          ▼
Opaque Lighting Pass에서 Sample
```

Opaque Object는 여러 Cascade Shadow Map을 직접 읽는 대신 하나의 Screen Space Texture를 읽을 수 있다.

하지만 Camera Depth가 필요해 Depth Prepass가 추가될 수 있고 Screen Space Texture Memory도 사용한다.

Transparent Object는 일반 Shadow Map 경로를 사용할 수 있다.

---

## Hard Shadow

가장 단순한 Shadow는 Shadow Map Texel 하나를 비교한다.

```text
Shadow = Compare(sampleUV, receiverDepth)
```

결과가 0 또는 1에 가까워 경계가 단단하다.

실제 Area Light의 Penumbra를 표현하지 못하고 Shadow Map Resolution에 따른 계단이 보일 수 있다.

Point Sample 비용은 낮지만 Alias가 쉽게 드러난다.

---

## Soft Shadow

Soft Shadow는 주변 Shadow Map Texel을 여러 번 Sample해 비교 결과를 평균낸다.

```hlsl
shadow = (
    compare(uv + offset0) +
    compare(uv + offset1) +
    compare(uv + offset2) +
    compare(uv + offset3)
) * 0.25h;
```

```text
여러 0/1 Sample의 평균
→ 0~1 중간 값
→ 부드러운 Shadow 경계
```

Filter Kernel과 Sample 수가 커질수록 부드러워질 수 있지만 Texture Sample 비용도 증가한다.

URP의 Soft Shadows Quality는 Light 또는 Pipeline Setting에 따라 선택할 수 있다.

---

## Shadow Bias가 필요한 이유

Shadow Map은 유한한 Texel과 Depth Precision을 사용한다.

Caster 자신을 Receiver로 비교할 때 두 Depth가 반올림 오차로 어긋나 Surface가 자신을 가리는 것처럼 보일 수 있다.

```text
Self Shadow Error
→ 표면에 줄무늬와 점
→ Shadow Acne
```

Bias는 비교 Depth 또는 Caster Position을 조금 이동해 Self Shadow를 줄인다.

```text
Depth Bias  → Light Depth 방향 Offset
Normal Bias → Surface Normal 방향 Offset
```

Bias가 너무 크면 Shadow가 Object에서 떨어져 보이는 Peter Panning과 Light Leak이 생긴다.

---

## Directional Light Shadow

Directional Light는 Scene 전체에 평행한 Light Direction을 가진다.

무한한 Scene을 하나의 유한 Shadow Map에 담을 수 없으므로 Camera 주변의 Shadow Distance 영역을 사용한다.

```text
Camera Frustum 중 Shadow Distance 내부
          │
          ▼
Directional Shadow Projection
```

넓은 범위를 같은 Resolution에 담으면 가까운 Shadow Texel이 커져 품질이 낮아진다.

Cascade Shadow Map은 Camera 거리에 따라 영역을 나누어 가까운 곳에 더 많은 Texel Density를 배정한다.

상세 내용은 뒤의 Cascade 글에서 이어진다.

---

## Spot Light Shadow

Spot Light의 Cone을 Perspective Camera Frustum처럼 사용한다.

```text
Spot Light
    ╲   ╱
     ╲ ╱ Cone
      ▼
  2D Shadow Map
```

한 방향 Projection으로 Shadow Map을 만들 수 있다.

Outer Spot Angle이 지나치게 넓으면 같은 Resolution이 넓은 영역에 분산되어 Shadow 품질이 낮아진다.

---

## Point Light Shadow

Point Light는 모든 방향으로 빛을 내므로 하나의 2D Projection으로 전체를 담을 수 없다.

```text
Point Shadow Cubemap
├─ +X / -X
├─ +Y / -Y
└─ +Z / -Z
```

Scene을 여섯 방향으로 Rendering해야 하므로 ShadowCaster 비용이 크다.

한 Point Light Shadow가 여섯 Spot Light Shadow와 비슷한 수의 Face Render를 요구하는 이유다.

---

## Shadow Atlas

여러 Light와 Cascade의 Shadow Map을 큰 Atlas Texture에 Packing할 수 있다.

```text
Shadow Atlas
┌──────────┬─────┐
│Cascade 0 │Spot A│
├─────┬────┼─────┤
│C1   │C2  │Point│
└─────┴────┴─────┘
```

각 Shadow Coordinate에는 Atlas 안의 Scale과 Offset이 적용된다.

Light 수와 Resolution이 늘면 Atlas 공간이 부족해지고 Light별 실제 Tile Resolution이 낮아질 수 있다.

Atlas와 Resolution의 상세 비용은 다음 글에서 이어진다.

---

## 그림자가 보이지 않는 경우

Shadow 생성과 수신 경로를 순서대로 확인한다.

```text
1. Light Shadows가 Hard 또는 Soft인가?
2. URP Asset에서 Main / Additional Shadow가 켜졌는가?
3. Renderer Cast Shadows가 켜졌는가?
4. Shader에 ShadowCaster Pass가 있는가?
5. Receiver Shader에 Shadow Keyword와 Sample이 있는가?
6. Shadow Distance 안에 있는가?
7. Culling / Rendering Layer가 맞는가?
```

Alpha Clip Object는 ShadowCaster Pass에서 같은 Texture와 Cutoff를 사용하는지도 확인한다.

---

## Shadow Artifact

### Shadow Acne

Depth Precision과 Sampling 오차로 Surface가 자신을 가리는 것처럼 보인다.

### Peter Panning

Bias가 너무 커 Shadow가 Object 발에서 떨어진다.

### Aliasing

Shadow Map Texel이 화면 Pixel보다 커 계단과 흔들림이 보인다.

### Light Leak

얇은 Geometry와 큰 Bias 때문에 Light가 벽을 통과한 것처럼 보인다.

### Swimming

Camera 또는 Light 이동 시 Shadow Texel Grid가 움직여 경계가 흔들린다.

각 문제의 원인이 다르므로 Resolution만 무조건 높이지 않는다.

---

## Shadow를 디버깅하는 방법

### Shadow Map 확인

Frame Debugger에서 Main Light Shadow와 Additional Light Shadow Pass의 Render Target을 확인한다.

### Shadow Attenuation 출력

```hlsl
half shadow = MainLightRealtimeShadow(shadowCoord);
return half4(shadow.xxx, 1.0h);
```

### Shadow Coordinate 확인

UV와 Depth가 0~1 범위에 있는지 시각화한다.

### Caster와 Receiver 분리

Object의 Cast Shadows와 Receive Shadows를 하나씩 끄며 어느 단계가 문제인지 찾는다.

```text
Caster Pass
   ↓
Shadow Map
   ↓
Coordinate Transform
   ↓
Depth Compare
   ↓
Lighting Multiply
```

---

## 성능 관점

Shadow는 두 번 비용을 만든다.

```text
Shadow Generation Cost
├─ Caster Culling
├─ Vertex Transform
├─ Alpha Clip Sample
└─ Depth Rasterization

Shadow Sampling Cost
├─ Shadow Coordinate
├─ Texture Sample
├─ Depth Compare
└─ Soft Filter 반복
```

Shadow Light 수, Caster 수, Face·Cascade 수, Resolution, Receiver Pixel과 Soft Sample이 비용을 결정한다.

Shadow Map의 생성 비용과 화면 적용 비용을 별도로 Profile해야 한다.

---

## 최적화 관점

### Shadow Light를 제한한다

중요한 Light만 Shadow를 만들고 작은 장식 Light는 No Shadows를 사용한다.

### Shadow Distance를 줄인다

Camera에서 의미 있게 보이는 범위까지만 Directional Shadow를 Rendering한다.

### Caster를 줄인다

작고 멀거나 Shadow에 의미 없는 Renderer의 Cast Shadows를 끈다.

복잡한 Mesh는 단순한 Shadows Only Proxy를 사용할 수 있다.

### Point Shadow를 주의한다

여섯 Face Render가 필요한 Point Light 대신 가능한 경우 Spot Light를 검토한다.

### Soft Quality를 조절한다

Target Platform에서 필요한 Filter Sample 수준만 사용한다.

### Baked와 Mixed Shadow를 활용한다

고정된 Environment Shadow를 Lightmap과 Shadowmask로 옮겨 매 Frame ShadowCaster Rendering을 줄인다.

---

## 흔한 오해

### Shadow Map은 검은 그림자 이미지다

Light 관점에서 가장 가까운 Surface Depth를 저장하며 Shader가 Receiver Depth와 비교해 Visibility를 계산한다.

### Camera Depth Texture와 Shadow Map은 같다

저장 형식은 비슷할 수 있지만 Camera 관점과 Light 관점이라는 차이가 있고 목적도 다르다.

### Shadow 안의 Color는 항상 0이다

해당 Direct Light만 줄어들며 Indirect Light, 다른 Light와 Emission은 남을 수 있다.

### Bias를 높이면 Artifact가 모두 해결된다

Acne는 줄어도 Peter Panning과 Light Leak이 커진다.

### Soft Shadow는 Texture를 Blur한 결과일 뿐이다

일반적으로 여러 Depth Comparison Sample을 Filter해 중간 Visibility를 만들며 Sample 비용이 증가한다.

---

## 전체 처리 흐름

```text
Light
  │ View / Projection Matrix
  ▼
Shadow Caster Culling
  │
  ▼
ShadowCaster Pass
Light Clip Position + Bias
  │
  ▼
Depth Rasterization
  │
  ▼
Shadow Map / Atlas
  │
──────── Camera Color Pass ────────
  │
World Position
  │ World to Shadow Transform
  ▼
Shadow UV + Receiver Depth
  │
  ├─ Shadow Map Depth Sample
  └─ Depth Comparison / Filtering
  │
  ▼
Shadow Attenuation 0~1
  │
  ▼
Direct Diffuse + Specular에 적용
  │
  ├─ Indirect Lighting
  └─ Emission
  │
  ▼
Final Lit Color
```

Shadow Mapping은 Light가 본 가장 가까운 Depth와 Camera가 본 Surface의 Light Depth를 비교해 Light Visibility를 근사한다.

---

## 정리

그림자는 Light와 Surface 사이가 다른 Geometry에 의해 가려져 해당 Direct Light의 기여가 줄어들 때 만들어진다.

Shadow Mapping은 Light 관점에서 가장 가까운 Surface Depth를 Shadow Map에 저장한다.

ShadowCaster Pass는 Object Vertex를 Light Clip Space로 변환하고 Color 없이 Depth를 기록한다.

Camera Color Pass는 Fragment World Position을 Shadow Space로 변환해 Shadow UV와 Receiver Depth를 얻는다.

Receiver Depth가 Shadow Map에 저장된 Caster Depth보다 뒤에 있으면 가려진 것으로 판정한다.

비교 결과는 0~1의 Shadow Attenuation이 되어 해당 Light의 Direct Diffuse와 Specular에 적용된다.

Camera Depth Texture는 Camera 관점 Depth이며 Screen-space Effect에 사용되고 Shadow Map은 Light 관점 Depth이므로 서로 대체할 수 없다.

Hard Shadow는 적은 Depth Sample로 0 또는 1 Visibility를 만들고 Soft Shadow는 주변 Sample을 Filter해 부드러운 경계를 만든다.

Depth와 Texel Precision 때문에 Shadow Acne가 생기며 Depth·Normal Bias로 줄일 수 있지만 값이 크면 Peter Panning과 Light Leak이 발생한다.

Directional, Spot과 Point Light는 각각 Orthographic, Cone Perspective와 여섯 Face Projection 방식으로 Shadow Map을 생성한다.

Shadow 비용은 ShadowCaster Rendering과 Receiver의 Shadow Sampling 양쪽에서 발생하며 Light·Caster·Cascade·Face·Resolution과 Soft Filter 수에 따라 증가한다.
