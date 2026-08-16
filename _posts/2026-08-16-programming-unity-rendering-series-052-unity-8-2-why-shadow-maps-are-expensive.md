---
title: "[Unity 렌더링] 8-2. Shadow Map은 왜 비쌀까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - Shadow
  - ShadowMap
  - Optimization
permalink: /programming/unity-8-2-why-shadow-maps-are-expensive/
toc: true
toc_sticky: true
date: 2026-08-16
last_modified_at: 2026-08-16
---

Shadow Map은 Light 관점에서 Scene Depth를 만들고 Camera Fragment에서 다시 Sample해야 하므로 생성과 적용 양쪽에서 비용이 발생한다.

```text
Shadow Cost
├─ CPU: Caster Culling과 Draw 준비
├─ GPU: Light 관점 Geometry 재렌더링
├─ GPU: Receiver의 Shadow Map Sample
├─ Memory: Shadow Atlas와 Bandwidth
└─ 반복: Light × Face × Cascade
```

Shadow Resolution만이 아니라 Shadow를 만드는 Light, Caster, Receiver와 Filter Sample 수가 전체 Frame 비용을 결정한다.

---

## Shadow Map은 한 번의 Texture Sample이 아니다

화면 Shader에서 Shadow Texture를 읽는 단계만 보면 비용이 작아 보일 수 있다.

하지만 그 Texture를 먼저 만들어야 한다.

```text
1. Shadow Map Generation
Light 관점에서 Scene Rendering

2. Shadow Evaluation
Camera 관점에서 Shadow Map Sampling
```

Light와 Caster가 움직이면 Shadow Map도 매 Frame 다시 생성해야 한다.

Static Shadow를 Bake하지 않는 한 이전 Frame 결과를 그대로 재사용하기 어렵다.

---

## CPU에서 발생하는 비용

CPU는 Shadow를 만드는 Light마다 Shadow Frustum을 준비하고 보이는 Caster를 찾는다.

```text
Shadow Light
    │
    ▼
Shadow Frustum / Face 구성
    │
    ▼
Caster Culling
    │
    ▼
Sorting / Draw Command
    │
    ▼
GPU 제출
```

Shadow Light와 Caster가 많으면 Culling과 Render Thread의 Command 준비가 증가한다.

Point Light의 여섯 Face와 Directional Cascade는 각각 별도 View처럼 Caster 집합을 평가할 수 있다.

Main Camera에서 보이지 않는 Object도 Light 관점에서 Shadow에 영향을 주면 Caster로 Rendering될 수 있다.

---

## GPU에서 Geometry를 다시 그리는 비용

Camera Color Pass에서 이미 그린 Mesh도 ShadowCaster Pass에서 다시 처리한다.

```text
Mesh
├─ Camera Depth / Color Pass
└─ ShadowCaster Pass × 필요한 Shadow View
```

Shadow Pass는 PBR Color 계산이 없어 Fragment Shader는 단순할 수 있다.

하지만 다음 작업은 남는다.

- Vertex Buffer 읽기
- Skinning과 Vertex Animation
- Object-to-Light Transform
- Triangle Setup과 Rasterization
- Alpha Clipping Texture Sample
- Depth Test와 Depth Write

많은 Triangle과 Skinned Mesh가 Shadow를 만들면 Vertex 비용이 커진다.

---

## Shadow Draw Call

ShadowCaster는 Material Color Pass와 별도 Pass이므로 Draw Command가 추가된다.

```text
100 Renderer
× Main Light Cascade 4개에 모두 포함
→ 최대 수백 개 Shadow Draw 후보
```

모든 Renderer가 모든 Cascade에 포함되는 것은 아니지만 반복 가능성을 보여 주는 관계다.

Batching과 Instancing이 적용될 수 있어도 Shadow View별 Visibility와 State에 따라 Draw 준비는 필요하다.

Frame Debugger에서 MainLightShadow와 AdditionalLightsShadowCaster Event를 분리해 확인한다.

---

## Caster 수가 중요한 이유

Shadow Distance 안의 모든 Object가 Shadow 품질에 같은 가치를 가지지는 않는다.

```text
중요한 Caster
├─ Character
├─ 큰 건물
└─ 가까운 Prop

낮은 가치의 Caster
├─ 화면에서 매우 작은 Detail
├─ 먼 Grass Blade
└─ Shadow가 보이지 않는 내부 Mesh
```

작은 Object 수천 개가 ShadowCaster Pass에 참여하면 Triangle 수보다 Draw와 Culling 비용이 먼저 커질 수 있다.

Renderer의 Cast Shadows를 필요에 따라 끄고 LOD별 Shadow 정책을 정한다.

---

## Alpha Clipping Caster가 더 비싼 이유

Opaque ShadowCaster는 Color Texture 없이 Depth만 기록할 수 있다.

Cutout Foliage는 Alpha를 알아야 Fragment를 버릴 수 있어 Texture Sample과 Fragment Shader가 필요하다.

```hlsl
half alpha = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv).a;
clip(alpha - _Cutoff);
```

잎의 대부분이 투명해도 Triangle Rasterization과 Alpha Test는 수행된다.

풀과 나무가 많은 Scene에서는 Shadow Pass의 Overdraw와 Texture Bandwidth가 커질 수 있다.

거리별로 단순 Shadow Proxy나 Shadow Casting Off를 검토한다.

---

## Skinned Mesh와 Vertex Animation

Character Shadow는 현재 Pose와 일치해야 한다.

ShadowCaster Pass에서도 Skinning된 Vertex Position이 필요하다.

```text
Animation Pose
├─ Camera Pass Skinning
└─ Shadow Pass Skinning × Shadow View
```

GPU Skinning Data를 재사용하는 방식과 Pipeline에 따라 세부 비용은 달라지지만 Shadow Pass의 Vertex 처리는 남는다.

Wind Shader와 Vertex Displacement도 Shadow Pass에서 반복해야 화면 Object와 Shadow 모양이 일치한다.

---

## Light Type별 반복 횟수

| Light Type | 일반적인 Shadow View |
| --- | ---: |
| Spot | 1 |
| Point | 6 |
| Directional | Cascade 수만큼 |

Spot Light는 하나의 Cone Projection을 사용한다.

Point Light는 모든 방향을 위해 Cubemap 여섯 Face를 Rendering한다.

Unity 공식 문서는 Point Light Shadow 비용을 여섯 Spot Light Shadow를 Rendering하는 것과 비교한다.

Directional Light는 Cascade 4개를 사용하면 서로 다른 거리 영역을 네 번 Rendering한다.

---

## Point Light Shadow가 특히 비싼 이유

```text
Point Light
       ●
   ↖ ↑ ↗
   ←   →
   ↙ ↓ ↘
```

각 방향의 Depth를 별도 Face에 저장한다.

```text
1 Point Shadow
= 6 Face Culling
 + 6 Face Draw
 + Atlas Tile 6개
```

작은 장식 Point Light 여러 개에 Shadow를 켜면 Caster Rendering과 Atlas 사용량이 동시에 증가한다.

방향을 제한할 수 있다면 Spot Light가 더 효율적일 수 있다.

---

## Cascade가 비용을 늘리는 이유

Directional Shadow Cascade는 Camera Frustum을 거리별로 나눈다.

```text
Camera
├─ Cascade 0: Near
├─ Cascade 1
├─ Cascade 2
└─ Cascade 3: Far
```

가까운 영역에 더 높은 Texel Density를 제공하지만 Cascade마다 Shadow View, Culling과 Rendering이 필요하다.

Cascade 경계 Blend가 있으면 Receiver Shader에서도 추가 비교가 생길 수 있다.

Cascade 수는 품질을 무료로 높이는 설정이 아니라 Shadow Pass 반복을 늘리는 설정이다.

---

## Resolution과 GPU 작업

Shadow Resolution이 커지면 Rasterization 대상 Texel 수와 Depth Texture 크기가 증가한다.

```text
1024² = 약 105만 Texel
2048² = 약 419만 Texel
4096² = 약 1,678만 Texel
```

가로 Resolution을 두 배로 높이면 면적은 네 배가 된다.

실제 작성 Texel 수는 Geometry Coverage에 따라 다르지만 Depth Buffer Memory와 최악의 Raster 범위는 크게 증가한다.

높은 Resolution은 Cache 효율과 Bandwidth에도 부담을 준다.

---

## Shadow Atlas

URP는 Main Directional Shadow와 Additional Light Shadow를 각각 Atlas에 Packing할 수 있다.

```text
Additional Shadow Atlas 1024²
┌──────┬──────┐
│512² A│512² B│
├──────┼──────┤
│512² C│512² D│
└──────┴──────┘
```

1024 Atlas에는 512 Tile 네 개 또는 256 Tile 열여섯 개를 담을 수 있다.

Spot Light 하나는 보통 Tile 하나를 사용하고 Point Light 하나는 Face 여섯 개가 필요하다.

```text
Spot 4개 + Point 1개
= 4 + 6
= Shadow Map Tile 10개
```

Atlas가 부족하면 요청 Resolution을 유지하지 못하고 낮은 Tile Resolution이 할당될 수 있다.

---

## Shadow Memory

Depth Texture Memory는 Resolution, Format, Atlas 수와 Buffering에 영향을 받는다.

```text
Shadow Memory
≈ Width × Height × BytesPerTexel
× Atlas Count
```

여기에 Temporary Render Target, Screen Space Shadow Texture와 Platform 내부 Alignment가 추가될 수 있다.

Point Light가 별도 Cubemap이 아니라 Atlas Tile을 사용해도 여섯 Face 면적은 필요하다.

Memory 사용은 GPU Capture와 Platform Profiler에서 확인한다.

---

## Shadow Map을 읽는 비용

Camera Color Pass의 Lit Fragment는 영향을 주는 Shadow Light마다 Shadow Map을 Sample한다.

```text
Receiver Cost
≈ Shadow를 받는 Fragment 수
 × Shadow Light 수
 × Filter Sample 수
```

화면 전체를 덮는 Main Directional Light Shadow는 대부분의 Lit Pixel에서 평가될 수 있다.

Additional Light Shadow가 여러 개 겹치면 Light Loop 안에서 각각 Shadow Sample이 추가된다.

Transparent Overdraw가 크면 같은 Screen Pixel에서 Shadow Sampling도 반복된다.

---

## Soft Shadow가 비싼 이유

Hard Shadow는 적은 수의 Depth Comparison으로 Visibility를 판단한다.

Soft Shadow는 주변 Texel을 여러 번 읽고 결과를 Filter한다.

```text
Hard
└─ Sample 1 또는 작은 Kernel

Soft
└─ Sample N + Weight / Average
```

Filter Sample 수가 4, 9, 16처럼 늘면 Receiver Fragment당 Texture 접근도 증가한다.

Tile-based Mobile GPU와 XR에서는 이 비용이 특히 클 수 있다고 Unity 공식 문서가 경고한다.

낮은 Resolution과 Soft Shadow의 조합이 Art Style에 더 적합할 수도 있지만 반드시 Target Device에서 측정한다.

---

## Receiver 수와 화면 Coverage

Shadow를 받는 Object 수보다 실제 Fragment Coverage가 중요할 때가 많다.

```text
작은 Receiver 100개
→ 화면 Coverage가 작으면 Sample 적음

Full-screen Terrain 1개
→ 거의 모든 Pixel에서 Shadow Sample
```

Receive Shadows를 끄면 해당 Material의 Shadow Evaluation 경로를 줄일 수 있다.

시각적으로 Shadow가 필요 없는 VFX, 작은 Background와 일부 Transparent Material에서 검토한다.

---

## Screen Space Shadow의 Trade-off

Screen Space Shadows는 Main Light Shadow를 화면 Texture에 한 번 계산하고 Opaque Pass가 이를 Sample하게 한다.

```text
Cascade Shadow Map + Camera Depth
              │
              ▼
Screen Space Shadow Texture
              │
              ▼
Opaque Material들이 공통 Sample
```

Forward에서 Material마다 Cascade를 선택하고 Sample하는 작업을 줄일 수 있다.

하지만 Camera Depth Prepass와 Screen Space Texture Memory가 추가된다.

Tile-based GPU에서는 Depth Prepass가 오히려 손해일 수 있으므로 Rendering Path와 Platform별 Profile이 필요하다.

---

## Shadow가 CPU Bound를 만들 때

다음 상황에서는 CPU Culling과 Draw 준비가 병목이 되기 쉽다.

- Shadow Caster Renderer가 매우 많음
- 작은 Mesh와 Material이 많아 Draw Call이 분산됨
- Shadow Light와 Face 수가 많음
- Cascade마다 많은 Object가 교차함
- 복잡한 Scriptable Render Feature가 Shadow Pass를 추가함

CPU Profiler와 Frame Debugger에서 Culling, Render Thread와 Shadow Draw 수를 확인한다.

Resolution을 낮춰도 CPU Draw 수는 그대로일 수 있다.

---

## Shadow가 GPU Bound를 만들 때

다음 상황에서는 GPU 시간이 크게 증가할 수 있다.

- 높은 Resolution Shadow Atlas
- 많은 Triangle과 Alpha-tested Foliage
- Point Light Shadow 여러 개
- Cascade 4개와 긴 Shadow Distance
- Full-screen Receiver와 높은 Soft Shadow Quality
- Transparent Lit Overdraw

GPU Profiler에서 ShadowCaster Pass와 Opaque·Transparent Receiver Pass를 따로 비교한다.

Shadow 생성과 Sample 중 어느 쪽이 병목인지 먼저 구분한다.

---

## Shadow Distance의 두 가지 효과

Shadow Distance를 줄이면 Directional Shadow가 다루는 공간이 작아진다.

```text
Distance 감소
├─ Caster 후보 감소
├─ Shadow Projection 범위 감소
├─ 같은 Resolution의 Texel Density 증가
└─ 먼 Receiver Shadow Sample 감소 가능
```

성능과 품질을 동시에 개선할 수 있는 경우가 많다.

먼 Shadow가 갑자기 사라지지 않도록 Fog, Fade와 Baked Shadowmask를 결합할 수 있다.

상세 설정은 뒤의 Shadow Distance 글에서 이어진다.

---

## Shadow Proxy

화면 Mesh와 동일한 복잡한 Geometry로 Shadow를 만들 필요가 없는 경우가 있다.

```text
High-poly Render Mesh
└─ Cast Shadows Off

Low-poly Proxy Mesh
└─ Shadows Only
```

Silhouette를 유지하는 단순 Mesh를 ShadowCaster로 사용하면 Vertex와 Triangle 비용을 줄일 수 있다.

Character Accessory와 작은 Surface Detail이 Shadow에 실제로 보이는지 기준으로 단순화한다.

---

## Baked와 Mixed Shadow

움직이지 않는 Light와 Geometry의 Shadow는 Lightmap 또는 Shadowmask에 저장할 수 있다.

```text
Realtime Shadow
└─ 매 Frame Caster Rendering + Sample

Baked Shadow
└─ Bake Time 계산 + Runtime Lightmap Sample
```

Shadowmask는 Static Caster Occlusion을 Bake하고 Dynamic Caster는 Realtime으로 남길 수 있다.

동적 반응이 필요한 범위만 Realtime Shadow로 유지하는 것이 효과적이다.

---

## 최적화 우선순위

```text
1. Shadow를 만드는 Light 수
2. Point Light Shadow 수
3. Shadow Distance와 Cascade 수
4. Caster Renderer와 Triangle 수
5. Additional Shadow Atlas와 Resolution
6. Soft Shadow Quality
7. Receiver Coverage와 Overdraw
```

모든 항목을 무조건 낮추기보다 Profiler에서 큰 Pass를 먼저 찾는다.

CPU Bound이면 Draw와 Caster를 줄이고 GPU Bound이면 Resolution, Face, Filter와 Coverage를 우선 조정한다.

---

## 측정 방법

### Frame Debugger

Main Light Shadow와 Additional Light Shadow Event, Draw 수와 Atlas Target을 확인한다.

### GPU Profiler

Shadow Map 생성 Pass와 Shadow를 Sample하는 Opaque·Transparent Pass 시간을 비교한다.

### Rendering Debugger

Cascade, Lighting Complexity와 Shadow 관련 Debug View를 사용한다.

### 단계별 Toggle

```text
Baseline
→ Additional Shadows Off
→ Main Shadow Off
→ Soft Shadows Off
→ Cascade 감소
→ Shadow Distance 감소
```

한 번에 하나씩 바꾸고 CPU·GPU Frame Time을 기록한다.

---

## 자주 생기는 판단 오류

### Shadow Resolution만 낮추면 충분하다

CPU Draw, Point Face 수와 Receiver Sample은 그대로 남을 수 있다.

### ShadowCaster Pass는 Depth뿐이라 무료다

Vertex Transform, Skinning, Alpha Test, Rasterization과 Draw Command가 필요하다.

### 화면 밖 Object는 Shadow 비용이 없다

Camera 밖에 있어도 Light 관점에서 보이고 화면 Receiver에 Shadow를 만들면 Caster가 될 수 있다.

### Forward+가 Shadow 비용도 모두 해결한다

Light List를 효율화하지만 Shadow Map 생성과 선택된 Shadow Light의 Sample은 여전히 필요하다.

### Baked Shadow는 완전히 무료다

Realtime Shadow Pass는 줄지만 Lightmap·Shadowmask Memory와 Sample 비용이 남는다.

---

## 전체 비용 흐름

```text
CPU
Shadow Light / Face / Cascade
          │
          ▼
Caster Culling + Draw Command
          │
          ▼
GPU Shadow Generation
Vertex / Skinning / Alpha Clip / Depth Write
          │
          ▼
Shadow Atlas Memory
          │
──────── Camera Rendering ────────
          │
Receiver Fragment
          │
Shadow Coordinate + Atlas Sample
          │
Soft Filter × Shadow Light
          │
          ▼
Shadow Attenuation
          │
          ▼
Direct Lighting Result
```

Shadow Map은 Texture 하나가 아니라 여러 Shadow View를 생성하고 저장하고 다시 읽는 전체 Pipeline이므로 비싸다.

---

## 정리

Shadow Map은 Light 관점 Depth 생성과 Camera Fragment의 Shadow Sampling이 모두 필요해 생산자와 소비자 양쪽 비용을 가진다.

CPU는 Shadow Light의 Face와 Cascade마다 Caster를 Culling하고 Shadow Draw Command를 준비한다.

GPU는 Camera Pass와 별도로 ShadowCaster의 Vertex, Skinning, Alpha Clip, Rasterization과 Depth Write를 반복한다.

Spot Light는 일반적으로 Shadow View 하나, Point Light는 여섯 Face, Directional Light는 Cascade 수만큼 Shadow View가 필요하다.

Resolution을 두 배로 높이면 Texture 면적은 네 배가 되어 Atlas Memory, Rasterization과 Bandwidth 부담이 크게 증가한다.

Additional Shadow Atlas는 Spot Light당 한 Tile, Point Light당 여섯 Tile이 필요하므로 Shadow Light 중첩에 따라 실제 Resolution이 낮아질 수 있다.

Receiver 비용은 Shadow를 받는 Fragment 수, 겹치는 Shadow Light 수와 Soft Filter Sample 수에 비례한다.

Alpha-tested Foliage와 Transparent Overdraw는 Shadow 생성과 Sampling 양쪽의 Fragment 비용을 키울 수 있다.

Shadow Distance와 Cascade 수를 줄이면 Caster 후보와 반복 Pass를 줄이고 같은 Resolution의 가까운 Shadow 품질도 높일 수 있다.

Static Caster는 Baked Lighting과 Shadowmask로 옮기고 복잡한 Mesh에는 Shadow Proxy를 사용해 Realtime Pass를 단순화할 수 있다.

최적화 전에는 Frame Debugger와 CPU·GPU Profiler로 Shadow 생성과 Receiver Sampling 중 실제 병목을 구분해야 한다.
