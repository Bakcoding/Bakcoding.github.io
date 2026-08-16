---
title: "[Unity 렌더링] 8-4. Shadow Distance는 왜 중요할까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - Shadow
  - ShadowDistance
  - Optimization
permalink: /programming/unity-8-4-why-shadow-distance-matters/
toc: true
toc_sticky: true
date: 2026-08-16
last_modified_at: 2026-08-16
---

Shadow Distance는 Camera로부터 어느 거리까지 실시간 Shadow를 표시할지 결정한다.

```text
Camera
  │
  ├──────── Realtime Shadow 영역 ────────┤ Shadow Distance
  │
  └─────────────────────────────────────── 그보다 먼 영역
```

값을 크게 하면 멀리 있는 Object에도 Shadow가 보이지만 더 넓은 영역을 제한된 Shadow Map에 담아야 한다.

그 결과 Shadow Caster가 늘고 가까운 Shadow에 배정되는 Texel Density가 낮아질 수 있다.

Shadow Distance는 단순한 가시거리 설정이 아니라 성능과 Shadow 품질을 동시에 바꾸는 예산 설정이다.

---

## Shadow Distance가 제한하는 것

Camera의 Far Clip Plane은 Scene을 얼마나 멀리 Rendering할지 정한다.

Shadow Distance는 그중 실시간 Shadow가 필요한 범위를 별도로 제한한다.

```text
Camera
├─ 0 ~ Shadow Distance
│  └─ Realtime Shadow 표시
│
├─ Shadow Distance ~ Far Clip Plane
│  └─ 일반 Scene은 보이지만 Realtime Shadow는 제한
│
└─ Far Clip Plane 밖
   └─ Camera Rendering 대상 아님
```

예를 들어 Far Clip Plane이 1000 m라도 Shadow Distance를 80 m로 둘 수 있다.

멀리 있는 산과 건물은 화면에 보이되 작은 실시간 Shadow까지 계산하지 않는 구성이다.

---

## Camera 기준 거리인 이유

Directional Light는 태양처럼 Scene 전체를 비추지만 Player가 현재 보는 주변 영역의 Shadow가 우선된다.

```text
Directional Light
↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓

World 전체 ─────────────────────────────
                 Camera ●
                      ├──── Shadow Distance ────┤
```

World 전체를 하나의 Shadow Map에 담으면 제한된 Texel이 지나치게 넓게 퍼진다.

Camera 주변만 선택하면 현재 Frame에 가치가 높은 영역에 Shadow Map을 집중할 수 있다.

Camera가 이동하면 실시간 Shadow 영역도 함께 이동한다.

---

## 거리가 멀수록 Caster 후보가 늘어난다

실시간 Shadow를 만들려면 범위 안에서 Shadow에 영향을 주는 Renderer를 찾아 ShadowCaster Pass로 그려야 한다.

```text
Shadow Distance 증가
        │
        ▼
더 넓은 Shadow 영역
        │
        ▼
더 많은 Caster 후보
        │
        ▼
Culling / Draw / Vertex 처리 증가 가능
```

숲, 도시와 Open World처럼 공간에 Object가 계속 분포하는 Scene에서는 거리 증가가 많은 Renderer를 포함시킬 수 있다.

반대로 작은 실내처럼 기존 범위 안에 모든 Caster가 이미 포함되어 있다면 거리를 더 늘려도 Caster 수가 거의 변하지 않을 수 있다.

따라서 Shadow Distance와 비용이 항상 일정한 비율로 증가하는 것은 아니다.

---

## CPU 비용과의 관계

CPU는 Shadow를 만드는 View마다 Caster를 판정하고 Draw Command를 준비한다.

```text
Shadow Frustum 구성
        │
        ▼
Caster Culling
        │
        ▼
Sorting / Batching
        │
        ▼
Render Command 제출
```

Shadow Distance가 커져 Renderer가 더 많이 포함되면 Culling 결과와 Shadow Draw Call 후보가 증가할 수 있다.

특히 작은 Prop, Tree와 Grass Renderer가 넓은 지역에 흩어져 있으면 CPU의 Culling과 Render Thread 비용이 커질 수 있다.

Resolution을 낮추는 것만으로는 이러한 Renderer 수가 줄지 않는다.

CPU 병목에서는 Shadow Distance나 Caster 범위를 줄이는 조정이 Resolution 변경보다 효과적일 수 있다.

---

## GPU Geometry 비용과의 관계

범위에 새로 포함된 Caster는 Light 관점에서 다시 Rendering된다.

```text
추가된 Caster
├─ Vertex Buffer 읽기
├─ Transform과 Skinning
├─ Triangle Setup
├─ Rasterization
└─ Depth Write
```

먼 Object가 화면에서 작게 보여도 Shadow Map Projection에서는 ShadowCaster Pass에 참여할 수 있다.

LOD가 적용되면 먼 거리의 Geometry를 단순화할 수 있지만 Shadow를 만드는 Renderer 수와 Pass 자체가 사라지는 것은 아니다.

Alpha Clipping Foliage가 넓게 분포한 Scene은 거리 증가에 특히 민감할 수 있다.

---

## Receiver 범위도 함께 생각해야 한다

Caster는 Shadow를 만드는 Object이고 Receiver는 Shadow 결과를 적용받는 Surface다.

```text
Tree     → Caster
Ground   → Receiver
Character→ Caster + Receiver
```

Shadow Distance 밖의 Receiver에는 일반적으로 실시간 Main Light Shadow가 표시되지 않는다.

멀리 있는 Shadow가 실제 화면에서 몇 Pixel을 차지하는지 확인해야 한다.

작은 Detail을 위해 수백 m 범위의 Caster를 Rendering한다면 비용에 비해 시각적 이득이 낮을 수 있다.

---

## 같은 Resolution을 더 넓게 펼치면 품질이 낮아진다

Shadow Map Resolution이 고정되어 있다면 Shadow Distance가 커질수록 Texel을 더 넓은 World 영역에 나누어 써야 한다.

```text
2048 Texel을 20 m에 배분
→ 약 102.4 texel/m

2048 Texel을 80 m에 배분
→ 약 25.6 texel/m
```

이 계산은 Projection을 한 축으로 단순화한 예시지만 관계는 명확하다.

```text
Shadow Distance ↑
→ World Coverage ↑
→ 같은 Map의 Texel Density ↓
→ 가까운 경계의 계단과 흔들림 ↑ 가능
```

멀리까지 Shadow를 보이게 하려다 Player 발밑의 Shadow가 흐려질 수 있다.

---

## Resolution과 Distance는 서로 보완 관계다

품질이 부족할 때 Resolution만 높이는 방법과 Distance를 줄이는 방법이 있다.

| 조정 | 가까운 Shadow 품질 | Memory | 먼 Shadow |
| --- | --- | --- | --- |
| Resolution 증가 | 개선 가능 | 증가 | 유지 |
| Shadow Distance 감소 | 개선 가능 | 동일할 수 있음 | 더 일찍 사라짐 |
| 둘 다 조정 | 목표에 따라 균형 | 설정에 따라 변화 | 설정에 따라 변화 |

Unity 공식 문서의 예시처럼 `Max Distance 40 + Resolution 2048`보다 `Max Distance 10 + Resolution 1024`가 가까운 영역에서 더 높은 Texel Density를 제공할 수 있다.

```text
2048 / 40 = 51.2
1024 / 10 = 102.4
```

낮은 Resolution이더라도 필요한 범위에 집중하면 더 선명하고 더 저렴한 결과를 만들 수 있다.

---

## Shadow Distance를 무조건 줄일 수는 없다

거리를 지나치게 줄이면 Shadow가 Camera 앞에서 갑자기 사라지는 현상이 보인다.

```text
Camera 이동 →

Object A: Shadow 있음
Object B: 경계 근처에서 Fade
Object C: Shadow 없음
```

넓은 평야, 비행 Scene과 높은 시점의 Camera에서는 멀리 있는 큰 Shadow가 공간감과 방향을 전달한다.

멀티플레이 전술 게임처럼 높은 Camera에서 넓은 지역을 보는 경우 짧은 Distance는 화면 전체를 평평하게 만들 수 있다.

성능 숫자만이 아니라 Camera 구도와 Art Direction이 요구하는 최소 거리를 찾아야 한다.

---

## Shadow Fade가 필요한 이유

Shadow Distance 경계에서 판정을 즉시 끄면 선명한 선이 Camera와 함께 이동한다.

```text
즉시 전환

Shadow 100% ┃ Shadow 0%
            ↑ 눈에 띄는 경계
```

Fade는 일정 구간에서 실시간 Shadow의 영향도를 점차 줄인다.

```text
Shadow Strength
1.0 ───────────╲
                ╲
0.0 ─────────────╲────
                 Distance
```

Fade는 Shadow 생성 비용을 없애기 위한 기능이라기보다 시각적 전환을 감추는 기능이다.

실제로 어느 범위까지 Caster를 Rendering하는지는 Pipeline의 Culling과 설정을 Profile해서 확인해야 한다.

---

## Fog로 전환을 감출 수 있다

먼 거리의 Contrast가 Fog로 줄어드는 Scene에서는 Shadow Fade가 덜 눈에 띈다.

```text
Near
├─ 높은 Contrast
├─ Realtime Shadow
└─ Detail 중요

Far
├─ Fog로 Contrast 감소
├─ Shadow Fade
└─ Silhouette 중요
```

Shadow Distance와 Fog Distance를 비슷한 시각적 범위로 설계하면 먼 Shadow의 부재를 자연스럽게 숨길 수 있다.

단, Fog가 있다는 이유로 큰 건물이나 산의 중요한 그림자까지 제거하면 Lighting 방향성이 약해질 수 있다.

---

## Baked Shadow와 결합하는 방법

정적인 환경은 Baked Lighting이나 Shadowmask를 이용해 먼 영역의 Shadow 정보를 유지할 수 있다.

```text
Near
└─ Realtime Shadow
   ├─ Dynamic Character
   └─ 움직이는 Object

Far
└─ Baked Shadow / Shadowmask
   └─ Static Environment
```

이 방식은 멀리 있는 Static Shadow의 시각적 정보는 남기고 실시간 Shadow 범위를 줄이는 데 유리하다.

하지만 Dynamic Object의 Shadow는 Baked Texture에 미리 기록할 수 없다.

Lighting Mode, Shadowmask Distance와 Platform 지원에 따라 결합 방식이 달라지므로 실제 Project 설정을 확인해야 한다.

---

## Directional Light에서 영향이 큰 이유

Spot Light와 Point Light는 Range와 Frustum이 자체적인 공간 범위를 가진다.

Directional Light는 위치에 따른 Range가 없으므로 Camera 주변 Shadow 범위를 정하는 설정이 특히 중요하다.

```text
Directional Light
├─ Light 자체 Range 없음
├─ Camera Frustum 기준 Shadow 영역 구성
└─ Shadow Distance가 Coverage를 제한
```

Main Directional Light가 Scene의 대부분을 비추는 Outdoor 환경에서 Distance 변화는 Caster 수와 Texel 배분 양쪽에 큰 영향을 줄 수 있다.

---

## Additional Light와의 차이

Additional Spot·Point Light의 Shadow는 Light Range와 Camera Visibility, Shadow Atlas 설정의 영향을 함께 받는다.

```text
Additional Light Shadow 범위
≈ Camera에서 필요한 영역
∩ Light Range / Frustum
∩ Shadow 설정
```

Shadow Distance를 늘렸다고 Light Range 밖의 Object까지 해당 Light의 Shadow를 만드는 것은 아니다.

반대로 Range가 매우 큰 Additional Light가 많으면 넓은 영역의 Caster와 Atlas Tile 비용이 발생할 수 있다.

Main Light와 Additional Light의 Shadow Pass를 분리해 Profile해야 원인을 정확히 찾을 수 있다.

---

## Cascade가 필요한 배경

하나의 Shadow Map으로 Camera 근처부터 먼 거리까지 모두 덮으면 가까운 영역의 Texel Density가 부족해진다.

Cascade Shadow Map은 Camera Frustum을 거리 구간으로 나누어 이 문제를 완화한다.

```text
Camera
├─ Cascade 0: 가까운 작은 범위
├─ Cascade 1: 중간 범위
├─ Cascade 2: 먼 범위
└─ Cascade 3: Shadow Distance까지
```

가까운 Cascade는 좁은 World 범위에 Tile을 사용하므로 높은 Texel Density를 유지할 수 있다.

하지만 Shadow Distance를 크게 늘리면 마지막 Cascade가 매우 넓은 범위를 담당하거나 Cascade Split 전체를 다시 조정해야 한다.

Cascade의 구조와 Split 설정은 다음 글에서 구체적으로 다룬다.

---

## Cascade가 있어도 Distance가 중요한 이유

Cascade는 제한된 Shadow Map을 거리별로 재배분할 뿐 무한한 Detail을 만들지 않는다.

```text
고정된 Shadow Atlas 예산
        │
        ├─ Near Cascade Tile
        ├─ Mid Cascade Tile
        └─ Far Cascade Tile
```

Shadow Distance를 늘리면 먼 Cascade가 담당할 영역이 커지고 더 많은 Caster가 여러 Cascade에 포함될 가능성이 생긴다.

Cascade 경계를 걸치는 큰 Object는 둘 이상의 Cascade Shadow Pass에서 Rendering될 수도 있다.

Distance와 Cascade 수를 함께 높이면 품질은 유지될 수 있지만 Culling, Draw와 Atlas 비용이 증가한다.

---

## Camera 높이와 FOV가 체감 거리를 바꾼다

같은 Shadow Distance도 Camera 구성에 따라 화면에서 차지하는 범위가 다르다.

```text
낮은 3인칭 Camera
└─ 50 m가 화면 대부분을 덮을 수 있음

높은 전략 Camera
└─ 50 m 경계가 화면 중앙에 보일 수 있음
```

넓은 FOV나 높은 Camera에서는 가까운 거리 안에 더 넓은 지면이 보인다.

Camera가 절벽 위나 비행 상태로 이동한다면 평지에서 정한 값이 부족할 수 있다.

최악의 Camera 구도를 포함해 Distance를 검증해야 한다.

---

## World Scale도 기준이 된다

Unity Unit을 1 m로 사용하는 일반적인 Project와 축척이 다른 Project에서 같은 숫자는 같은 시각적 의미를 갖지 않는다.

```text
Character 높이 2 Unit인 Project
Shadow Distance 50 Unit
→ Character 높이의 25배

Character 높이 0.2 Unit인 Project
Shadow Distance 50 Unit
→ Character 높이의 250배
```

숫자를 복사하기보다 Character 크기, 이동 속도와 Camera가 보여 주는 Gameplay 공간을 기준으로 설정한다.

---

## 빠르게 이동하는 Camera

차량, 비행과 순간 이동에서는 Shadow 영역이 Frame마다 크게 바뀔 수 있다.

```text
Frame N Shadow 영역      [ A B C ]
Frame N+1 Shadow 영역          [ C D E ]
```

새로운 Caster가 대량으로 들어오면 Culling과 Shadow Rendering 부하가 순간적으로 변할 수 있다.

평균 Frame Time만 보면 이러한 Spike를 놓칠 수 있다.

고속 이동 경로를 재현하면서 CPU·GPU Frame Time의 상위 Percentile과 순간 최대값을 확인한다.

---

## Object별 Shadow 정책과 함께 사용한다

Shadow Distance는 전체 범위를 자르지만 그 안의 모든 Renderer가 같은 중요도를 갖지는 않는다.

```text
가까운 범위
├─ Character        : Cast Shadow 유지
├─ 큰 Architecture : Cast Shadow 유지
├─ 작은 Debris      : 거리별 Off 검토
├─ Grass Blade      : LOD별 Off 검토
└─ 실내 숨은 Mesh   : 불필요한 Cast Off
```

전체 Distance를 줄일 수 없는 Scene이라면 작은 Caster를 먼저 제외해 비용을 줄일 수 있다.

LOD Group의 먼 단계에 단순한 Shadow Geometry를 사용하거나 Cast Shadows를 끄는 정책도 가능하다.

다만 갑작스러운 Shadow Pop이 보이지 않도록 전환 거리를 Camera에서 검증해야 한다.

---

## Quality Level별 설정

Platform과 Quality Level마다 요구되는 거리와 성능 예산이 다르다.

| Quality | Shadow Distance 예시 방향 | 함께 조절할 항목 |
| --- | --- | --- |
| Low | 짧게 | Resolution, Additional Shadow, Soft Shadow |
| Medium | Gameplay 핵심 범위 | Cascade 수와 Atlas |
| High | 더 먼 주요 Shadow 유지 | Resolution과 Cascade 품질 |

표의 값은 고정된 권장 수치가 아니라 설정 방향이다.

Low Quality에서 Distance만 줄이고 Fade나 Fog를 그대로 두면 전환이 쉽게 드러날 수 있다.

Quality Preset 전체의 시각적 일관성을 확인한다.

---

## Dynamic Resolution과는 다른 설정이다

Render Scale이나 Dynamic Resolution은 Camera Color Buffer의 Pixel 수를 바꾼다.

Shadow Distance는 Shadow를 적용하는 World 범위를 바꾼다.

```text
Dynamic Resolution
└─ Screen Pixel 예산 조절

Shadow Resolution
└─ Shadow Texel 예산 조절

Shadow Distance
└─ Shadow World Coverage 조절
```

화면 해상도를 낮춰도 Shadow Caster 범위와 Shadow Map 생성 비용이 자동으로 같은 비율로 줄지는 않는다.

서로 다른 병목을 다루는 설정으로 구분해야 한다.

---

## 적절한 값을 찾는 순서

가장 먼 값을 먼저 고정하기보다 Gameplay에 필요한 최소 범위를 찾는다.

```text
1. 대표 Camera와 최악의 Camera 구도 선정
2. 중요한 Shadow 종류 구분
3. 낮은 Distance에서 시작
4. 경계가 보일 때까지 이동하며 확인
5. Fade와 Fog를 함께 조정
6. 필요한 최소 거리 확정
7. Resolution과 Cascade 재조정
8. Target Device에서 Profile
```

Character 발밑, 큰 건물, 움직이는 Enemy와 Gameplay 표식처럼 반드시 유지해야 하는 Shadow를 먼저 정의한다.

작은 원거리 Detail까지 보존하기 위해 전체 값을 크게 만드는 것은 피한다.

---

## 비교할 때 고정해야 하는 조건

Shadow Distance의 영향만 보려면 다른 설정을 고정한다.

- Shadow Resolution
- Cascade 수와 Split
- Light 방향
- Camera 경로와 FOV
- Caster의 LOD
- Soft Shadow 품질
- Render Scale
- Fog 설정

동일한 Camera Recording을 재생하고 Distance만 단계별로 바꾼다.

```text
Test A: 25 m
Test B: 50 m
Test C: 100 m
```

Screenshot으로 경계와 품질을 비교하고 Profiler로 CPU·GPU 시간을 기록한다.

---

## Profile에서 확인할 항목

```text
CPU
├─ Shadow Culling Time
├─ Render Thread Time
└─ Shadow Draw Call 수

GPU
├─ Main Light Shadow Pass
├─ Additional Shadow Pass
├─ Vertex / Fragment 부담
└─ 전체 GPU Frame Time

품질
├─ Shadow Fade 위치
├─ 가까운 Texel Density
├─ Cascade 경계
└─ 이동 중 Pop과 Shimmering
```

Frame Debugger로 Distance 변경 전후 ShadowCaster Pass의 Renderer 수와 Cascade별 Draw를 비교한다.

Unity Editor가 아니라 최종 Graphics API와 Target Device에서 측정한다.

---

## 흔한 오해

### Shadow Distance는 Shadow Map Resolution을 바꾼다

Distance는 World Coverage를 바꾸며 Texture의 설정 Resolution 자체를 바꾸는 값은 아니다.

다만 같은 Resolution이 더 넓은 범위에 분배되어 체감 품질이 달라진다.

### 거리를 절반으로 줄이면 성능이 정확히 2배 좋아진다

Object 분포, Cascade, Caster 수와 GPU 병목에 따라 변화 폭이 다르다.

빈 공간을 줄이면 차이가 작고 밀집된 숲을 제외하면 차이가 클 수 있다.

### Far Clip Plane과 같게 두는 것이 자연스럽다

먼 Object가 보인다고 그 거리의 작은 실시간 Shadow까지 모두 필요하다는 의미는 아니다.

### Cascade를 늘리면 Distance를 무한히 늘릴 수 있다

Cascade는 Texel 배분을 개선하지만 Shadow View, Culling, Draw와 Atlas 예산을 사용한다.

### Fade가 있으면 Shadow 비용도 서서히 줄어든다

Fade는 주로 시각적 영향도를 줄이는 전환이다. 실제 생성 비용이 같은 비율로 감소한다고 가정하지 말고 Profile해야 한다.

### 높은 Quality는 항상 가장 먼 Shadow가 필요하다

높은 품질은 중요한 Shadow를 안정적으로 보여 주는 것이다. 보이지 않는 원거리 Detail에 예산을 쓰는 것과 같지 않다.

---

## 정리

Shadow Distance는 Camera로부터 실시간 Shadow를 표시할 최대 World 범위를 정한다.

Far Clip Plane과 독립적으로 설정할 수 있어 먼 Scene은 보이면서 실시간 Shadow 계산 범위는 제한할 수 있다.

거리를 늘리면 더 많은 Caster가 Culling과 ShadowCaster Pass에 포함되어 CPU Draw 준비와 GPU Geometry 비용이 증가할 수 있다.

같은 Shadow Resolution을 넓은 범위에 펼치면 Texel Density가 낮아져 가까운 Shadow 품질도 떨어질 수 있다.

거리를 줄이면 성능과 근거리 품질을 함께 개선할 수 있지만 Shadow가 갑자기 사라지지 않도록 Fade, Fog와 Baked Shadow를 함께 설계해야 한다.

Cascade는 가까운 영역의 Texel Density를 보완하지만 추가 Shadow View와 Atlas 예산을 사용하므로 Distance를 대신하는 무제한 해결책은 아니다.

적절한 값은 고정된 권장 숫자가 아니라 Camera 구도, World Scale, Object 밀도와 Platform의 Frame Budget으로 결정한다.

대표 Camera 경로에서 Shadow Distance만 단계적으로 바꾸고 Caster 수, CPU·GPU Frame Time과 Shadow 경계를 함께 측정해야 한다.
