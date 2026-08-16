---
title: "[Unity 렌더링] 8-5. Cascade Shadow Map은 무엇일까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - Shadow
  - CascadeShadowMap
  - CSM
permalink: /programming/unity-8-5-cascade-shadow-maps/
toc: true
toc_sticky: true
date: 2026-08-16
last_modified_at: 2026-08-16
---

Cascade Shadow Map은 Camera Frustum을 거리에 따라 여러 구간으로 나누고 각 구간에 별도의 Directional Light Shadow Map을 사용하는 방식이다.

```text
Camera
├─ Cascade 0: 가까운 좁은 영역
├─ Cascade 1: 중간 영역
├─ Cascade 2: 먼 영역
└─ Cascade 3: Shadow Distance 끝까지
```

같은 Resolution의 Shadow Map 하나를 전체 거리에 펼치면 Camera 근처의 Shadow가 쉽게 픽셀처럼 깨진다.

Cascade는 가까운 영역을 별도로 확대해 제한된 Shadow Texel을 더 촘촘하게 배정한다.

---

## 하나의 Shadow Map에서 생기는 문제

Directional Light는 태양처럼 평행한 방향으로 넓은 Scene을 비춘다.

Shadow Distance 안의 Camera Frustum 전체를 하나의 Shadow Map에 담는다고 가정한다.

```text
Camera Frustum
       /---------------------- Far
      /                     /
     /                    /
    /___________________/
   Near

전체 범위 → Shadow Map 1장
```

Camera에 가까운 영역은 Frustum의 작은 일부지만 화면에서는 매우 크게 보인다.

먼 영역까지 담기 위해 Shadow Map Projection을 넓히면 가까운 Surface에 배정되는 Texel이 부족해진다.

---

## Perspective Aliasing

Perspective Camera에서 가까운 Object는 많은 Screen Pixel을 차지하고 먼 Object는 적은 Pixel을 차지한다.

```text
같은 크기의 바닥 Tile

Near : ■■■■■■■■■■■■  많은 Screen Pixel
Far  : ■■            적은 Screen Pixel
```

반면 하나의 Directional Shadow Map은 넓은 World 범위에 Texel을 비교적 일정하게 배분한다.

가까운 영역에서는 하나의 Shadow Texel을 여러 Screen Pixel이 확대해서 읽게 된다.

```text
1 Shadow Texel
      │
      ▼
Near Screen Pixel 여러 개
■■■■■■■■
```

Shadow 경계가 계단처럼 보이고 Camera 이동 시 흔들리는 현상이 발생한다.

Unity 공식 문서는 이를 Directional Light의 실시간 Shadow에서 발생하는 `Perspective Aliasing` 문제로 설명한다.

---

## Cascade가 문제를 나누는 방식

Camera Frustum을 가까운 구간과 먼 구간으로 나눈다.

```text
1 Cascade
[────────────────────────────────]

4 Cascades
[────][──────][────────][──────────────]
  C0     C1       C2           C3
```

각 구간에 맞는 Light View와 Projection을 만들어 Shadow Depth를 Rendering한다.

```text
Camera Frustum Split
        │
        ├─ C0 → Light Projection 0 → Shadow Tile 0
        ├─ C1 → Light Projection 1 → Shadow Tile 1
        ├─ C2 → Light Projection 2 → Shadow Tile 2
        └─ C3 → Light Projection 3 → Shadow Tile 3
```

Receiver는 자신의 Camera 거리와 위치에 맞는 Cascade Shadow Map을 Sample한다.

---

## 가까운 Cascade가 더 선명한 이유

각 Cascade Tile의 Resolution이 같다고 단순 가정한다.

```text
Cascade 0
1024 Texel을 10 m 범위에 사용
→ 약 102.4 texel/m

Cascade 3
1024 Texel을 80 m 범위에 사용
→ 약 12.8 texel/m
```

가까운 Cascade는 좁은 World 영역을 담당하므로 Texel Density가 높다.

먼 Shadow는 Screen에서 작게 보이기 때문에 낮은 World Texel Density도 상대적으로 덜 눈에 띈다.

```text
Near
├─ Screen에서 크게 보임
└─ 높은 Shadow Detail 필요

Far
├─ Screen에서 작게 보임
└─ 낮은 Shadow Detail도 허용 가능
```

이것이 같은 전체 Resolution 예산을 거리 중요도에 맞게 재배분하는 핵심이다.

---

## Resolution을 올리는 것과 무엇이 다를까?

Shadow Map Resolution을 올리면 모든 영역의 Texel 수가 증가한다.

Cascade는 Camera 근처에 별도의 Projection을 배정해 분포를 바꾼다.

| 방식 | 핵심 변화 | 장점 | 비용 |
| --- | --- | --- | --- |
| Resolution 증가 | Map 한 변의 Texel 증가 | 전체 Detail 개선 가능 | Memory와 Rasterization 증가 |
| Cascade 증가 | Frustum을 여러 Projection으로 분할 | 근거리 Detail 집중 | Shadow View와 Draw 반복 증가 |
| Shadow Distance 감소 | World Coverage 축소 | 밀도와 성능 개선 가능 | 먼 Shadow 소실 |

Unity 공식 문서는 Shadow Resolution이 같은 상태에서도 Cascade 수에 따라 가까운 Shadow 품질이 달라질 수 있음을 보여 준다.

Cascade는 더 큰 Texture를 만드는 대신 Texture를 어디에 집중할지 바꾸는 방법이다.

---

## Directional Light에만 사용하는 이유

Perspective Aliasing은 Directional Light가 Camera 주변의 넓은 범위를 하나의 평행 Projection으로 덮을 때 크게 나타난다.

```text
Directional Light
↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
Camera Frustum 전체에 평행한 빛
```

Spot Light는 Light 자체의 Perspective Frustum이 있고 Point Light는 여섯 방향의 범위를 가진다.

Unity의 Shadow Cascade 설정은 Main Directional Light에 적용된다.

Additional Spot·Point Light Shadow를 여러 Cascade로 나누는 설정이 아니다.

---

## Cascade Count

URP Asset에서 Main Light의 Cascade Count를 설정한다.

```text
URP Asset
└─ Lighting
   └─ Main Light
      └─ Cascade Count
```

Cascade Count는 Camera Frustum을 몇 개의 Shadow 거리 구간으로 나눌지 정한다.

```text
1 Cascade : 분할 없음
2 Cascades: Near / Far
3 Cascades: Near / Mid / Far
4 Cascades: Near / Mid 1 / Mid 2 / Far
```

수가 많을수록 거리별 Projection을 세밀하게 맞출 수 있지만 비용도 증가한다.

가장 많은 수가 항상 가장 효율적인 선택은 아니다.

---

## Cascade Split

Split은 한 Cascade가 끝나고 다음 Cascade가 시작되는 위치를 정한다.

```text
0% Camera
│
├──── Split 1
│     Cascade 0
├────────── Split 2
│           Cascade 1
├──────────────── Split 3
│                 Cascade 2
└──────────────────────── 100% Shadow Distance
                          Cascade 3 끝
```

URP Asset의 `Split 1`, `Split 2`, `Split 3`은 Cascade 수에 따라 표시된다.

각 값은 전체 Shadow Distance 안에서 Cascade 경계를 어디에 둘지 결정한다.

---

## 균등 Split이 항상 적합하지 않은 이유

Shadow Distance가 100 m이고 네 Cascade를 25 m씩 균등하게 나눈다고 가정한다.

```text
0 ── 25 ── 50 ── 75 ── 100 m
```

첫 Cascade가 25 m를 담당하면 Character 발밑과 가까운 Prop에 충분한 Texel Density를 주지 못할 수 있다.

Perspective Camera는 가까운 영역의 Detail을 더 크게 보여 주므로 가까운 Split을 더 좁게 배치하는 경우가 많다.

```text
0 ─ 8 ─── 22 ─────── 50 ───────── 100 m
```

이 값은 예시이며 모든 Project에 적용되는 권장값이 아니다.

Camera 높이, FOV, World Scale과 중요한 Shadow의 위치를 기준으로 정해야 한다.

---

## Split을 너무 가깝게 모으면 생기는 문제

Near Cascade만 지나치게 좁게 만들면 Camera 바로 앞은 선명하지만 중간 거리의 품질이 급격히 떨어진다.

```text
Near     Mid                         Far
[고밀도][낮은 밀도──────────────────────]
```

Player가 자주 보는 Enemy나 건물이 두 번째 Cascade에 있는데 그 구간이 너무 넓으면 Shadow가 흐려질 수 있다.

한 지점의 Screenshot만 보고 조절하지 말고 Camera 이동 경로 전체에서 확인한다.

---

## Cascade 선택은 어떻게 이루어질까?

Receiver의 World Position 또는 Camera-relative Position이 어느 Cascade 영역에 속하는지 판정한다.

개념적인 흐름은 다음과 같다.

```text
Screen Pixel
    │
    ▼
World Position 복원 또는 전달
    │
    ▼
Cascade 0~N 범위 판정
    │
    ▼
해당 Light Matrix로 Shadow Coordinate 변환
    │
    ▼
해당 Shadow Tile Sample
```

실제 URP Shader 구현은 Keyword, Platform과 Rendering Path에 따라 달라질 수 있다.

핵심은 Receiver가 모든 Cascade를 무조건 완전히 Sample하는 것이 아니라 자신의 위치에 맞는 Cascade를 선택한다는 점이다.

---

## Cascade Atlas

여러 Cascade의 Depth는 Shadow Atlas의 Tile에 배치될 수 있다.

```text
4 Cascade Atlas 예시
┌────────────┬────────────┐
│ Cascade 0  │ Cascade 1  │
├────────────┼────────────┤
│ Cascade 2  │ Cascade 3  │
└────────────┴────────────┘
```

Atlas Resolution이 2048이고 네 Tile을 2 × 2로 나누는 단순한 구성이면 각 Tile 한 변은 1024 규모다.

```text
2048 Atlas
└─ 2 × 2 배치
   └─ Tile당 1024 × 1024
```

실제 Layout과 내부 Padding은 URP Version과 구현에 따라 달라질 수 있다.

Cascade 수를 늘린다고 각 Cascade에 전체 Atlas Resolution이 그대로 주어지는 것은 아니다.

---

## Cascade마다 Shadow Map을 다시 만든다

각 Cascade는 Light 관점의 별도 Shadow View다.

```text
Cascade 0
├─ Caster Culling
└─ ShadowCaster Rendering

Cascade 1
├─ Caster Culling
└─ ShadowCaster Rendering

Cascade 2 ...
```

같은 Renderer가 여러 Cascade에 걸치면 둘 이상의 Shadow Pass에서 그려질 수 있다.

큰 Terrain, 높은 Building과 긴 Wall은 Cascade 경계를 가로지르기 쉽다.

Cascade Count 증가는 단순한 Sample 설정 변경이 아니라 Shadow Map 생성 작업을 반복하는 변경이다.

---

## CPU 비용

CPU는 Cascade마다 Shadow 영역을 구성하고 Caster를 판정한다.

```text
Cascade Count 증가
├─ Shadow Culling View 증가
├─ Caster 목록 준비 증가
├─ Draw Command 후보 증가
└─ Render Thread 작업 증가 가능
```

모든 Caster가 모든 Cascade에 포함되는 것은 아니다.

하지만 Caster가 많고 경계를 걸치는 Renderer가 많으면 Culling과 Draw 준비 비용이 증가한다.

CPU 병목 Project에서는 Resolution을 바꾸는 것보다 Cascade Count 변화가 더 크게 나타날 수 있다.

---

## GPU Geometry 비용

GPU는 Cascade별 ShadowCaster Pass에서 Vertex를 처리하고 Depth를 기록한다.

```text
Mesh
├─ Cascade 0 ShadowCaster
├─ Cascade 1 ShadowCaster
└─ Camera Color Pass
```

Skinned Mesh, Vertex Animation과 Alpha Clipping Caster도 포함된 Cascade마다 관련 작업을 반복할 수 있다.

Cascade를 2개에서 4개로 바꿨다고 전체 GPU 시간이 정확히 2배가 되는 것은 아니다.

각 Cascade의 Caster 수, Tile 면적, Geometry와 GPU 병목에 따라 증가 폭이 달라진다.

---

## Shadow Sampling 비용

Receiver Shader는 어느 Cascade를 사용할지 판정하고 해당 Tile의 Depth를 Sample한다.

```text
Receiver Cost
├─ Cascade Index 판정
├─ Shadow Coordinate 계산
├─ Atlas UV 변환
└─ Depth Filtering
```

Hard Shadow라면 기본 Sample 수가 크게 변하지 않을 수 있지만 Cascade 선택과 경계 처리 비용이 추가된다.

Cascade 경계에서 두 결과를 Blend하는 방식은 둘 이상의 Cascade를 Sample할 수 있어 비용이 늘어난다.

Soft Shadow의 PCF Sample 수가 많다면 경계 Blend와 함께 Receiver 비용이 더 커질 수 있다.

---

## Cascade 경계가 보이는 이유

인접한 Cascade는 서로 다른 Projection과 Texel Density를 사용한다.

```text
Cascade 0 Texel: 촘촘함
■■■■■■■■■■■■■■■■

Cascade 1 Texel: 성김
■■  ■■  ■■  ■■
```

Receiver가 경계를 넘는 순간 Sample Grid, Bias와 Filtering 결과가 바뀔 수 있다.

```text
Camera 이동
Cascade 0 결과 ┃ Cascade 1 결과
               ↑ 전환선
```

Shadow의 선명도나 위치가 갑자기 변하면 Camera와 함께 움직이는 띠처럼 보인다.

이를 Cascade Transition 또는 Cascade 경계 Artifact로 볼 수 있다.

---

## Cascade Border와 Blend

경계 Artifact를 줄이기 위해 인접 Cascade 결과를 일정 구간에서 섞을 수 있다.

```text
Cascade 0 ────────────────┐
                          ╲ Blend
                           ╲
Cascade 1                  └────────────
```

Blend 영역에서는 현재 Cascade와 다음 Cascade를 함께 Sample할 수 있다.

```text
shadow = lerp(shadowCascade0, shadowCascade1, blendFactor);
```

이는 개념 코드이며 실제 URP 함수와 구현을 그대로 나타낸 것은 아니다.

Border를 넓히면 전환은 부드러워질 수 있지만 중복 Sampling 영역과 낮은 품질 Cascade의 영향이 커질 수 있다.

---

## Last Border

URP Asset의 `Last Border`는 Shadow Distance 끝에서 Shadow를 Fade Out하는 영역의 크기를 정한다.

Unity 공식 문서에 따르면 Fade는 다음 위치에서 시작한다.

```text
Fade 시작 = Max Distance - Last Border
Fade 종료 = Max Distance
```

```text
Shadow Strength
1.0 ─────────────────╲
                      ╲
0.0 ───────────────────╲──
       Max Distance - Border  Max Distance
```

마지막 Cascade 끝에서 Shadow가 갑자기 사라지는 현상을 완화한다.

Cascade 사이의 Split Blend와 전체 Shadow 끝의 Last Border는 목적을 구분해서 설정해야 한다.

---

## Bias가 Cascade마다 다르게 보일 수 있다

Depth Bias와 Normal Bias는 Shadow Acne을 줄이기 위해 Caster와 Receiver 비교 위치를 조정한다.

Cascade마다 World 단위 Texel 크기가 다르기 때문에 같은 Bias 설정도 화면에서 다르게 느껴질 수 있다.

```text
Near Cascade
└─ 작은 World Texel

Far Cascade
└─ 큰 World Texel
```

Far Cascade에서 Shadow가 Object에서 더 떨어져 보이거나 얇은 Geometry의 Light Leak이 커질 수 있다.

Resolution이나 Cascade를 바꾼 뒤에는 경계 품질만 아니라 Acne, Peter Panning과 Light Leak도 다시 확인한다.

---

## Stable Shadow와 Shimmering

Camera가 움직이면 각 Cascade를 감싸는 Light Projection도 이동한다.

Projection이 연속적으로 움직이면 World Position이 매 Frame 다른 Texel에 정렬되어 Shadow가 흔들릴 수 있다.

```text
Frame N     World Edge → Texel 120
Frame N + 1 World Edge → Texel 121
```

Pipeline은 Projection을 Shadow Texel 단위에 맞추는 안정화 기법을 사용할 수 있다.

하지만 Cascade Split, Light 회전과 Camera 이동에 따라 Shimmering이 완전히 사라지지 않을 수 있다.

정지 Screenshot뿐 아니라 실제 Camera 이동 중에 품질을 평가해야 한다.

---

## Camera FOV와 높이

같은 Shadow Distance와 Split도 Camera FOV와 높이에 따라 화면상 위치가 달라진다.

```text
낮은 3인칭 Camera
└─ Near Cascade가 Character 주변을 충분히 덮음

높은 전략 Camera
└─ Near Cascade 경계가 화면 중앙에 보일 수 있음
```

Zoom 기능으로 FOV가 크게 변하면 Cascade가 담당하는 Screen 영역도 달라진다.

대표 FOV 하나에서만 Split을 맞추면 Zoom In·Out 시 전환선이 눈에 띌 수 있다.

Camera의 모든 Gameplay Mode에서 확인해야 한다.

---

## Shadow Distance와 함께 조절한다

Cascade는 Shadow Distance 내부를 나눈다.

```text
Shadow Distance 50 m
└─ 4 Cascades가 0~50 m 분할

Shadow Distance 200 m
└─ 같은 4 Cascades가 0~200 m 분할
```

Distance를 크게 늘리면 각 Cascade가 더 넓은 범위를 맡게 되어 Texel Density가 낮아질 수 있다.

이를 보완하려고 Cascade Count와 Resolution을 모두 올리면 Culling, Rendering과 Memory 비용이 함께 커진다.

먼 Shadow가 실제로 필요한지 먼저 정하고 그 범위 안에서 Split을 배분한다.

---

## Caster LOD와 함께 사용한다

먼 Cascade는 낮은 Detail의 Geometry로도 충분할 수 있다.

```text
Cascade 0
└─ Character와 Prop의 세밀한 Silhouette

Cascade 3
└─ 큰 형태 중심의 단순 Shadow
```

LOD Group으로 먼 Caster의 Triangle을 줄이거나 먼 LOD에서 작은 Detail의 Cast Shadows를 끌 수 있다.

단, Camera LOD 기준과 Light Shadow Projection의 관계 때문에 전환 시 Shadow 모양이 갑자기 바뀔 수 있다.

LOD 전환과 Cascade 전환이 같은 화면 구간에서 겹치지 않는지도 확인한다.

---

## Terrain과 Foliage

Terrain과 숲은 넓은 World 범위에 Caster가 계속 분포한다.

Cascade 수가 늘면 넓은 Terrain Chunk와 Tree가 여러 Shadow View에서 처리될 수 있다.

```text
Outdoor Shadow Cost
├─ Cascade Count
├─ Shadow Distance
├─ Terrain Patch 수
├─ Tree / Grass Caster 수
└─ Alpha Clipping
```

가까운 Foliage Shadow는 품질 기여도가 높지만 먼 Grass Blade의 Shadow는 Screen에서 거의 보이지 않을 수 있다.

거리별 Cast Shadow 정책과 Cascade 설정을 함께 설계한다.

---

## Platform별 선택

Cascade가 제공하는 품질과 비용의 균형은 Platform마다 다르다.

| 환경 | 주요 고려 사항 |
| --- | --- |
| Desktop | 높은 Display 해상도, GPU·CPU Frame Budget |
| Mobile | Culling·Draw 비용, Tile-based GPU, Memory Bandwidth |
| XR | 높은 Frame Rate, 두 Eye의 안정적인 품질 |
| 전략 Camera | 넓은 가시 범위와 경계 위치 |
| 실내 | 짧은 Distance로 적은 Cascade 가능성 |

모바일에서 무조건 Cascade를 끄거나 Desktop에서 무조건 4개를 쓰는 고정 규칙은 없다.

Scene 밀도와 병목을 Target Device에서 측정해 결정한다.

---

## 적절한 Cascade 수를 찾는 순서

```text
1. 필요한 Shadow Distance 확정
2. Main Light Shadow Resolution 설정
3. 1 Cascade에서 근거리 Artifact 확인
4. 필요하면 2 Cascades로 증가
5. Split을 중요한 거리 구간에 배치
6. 부족한 경우에만 3~4 Cascades 검토
7. 경계와 Last Border 조정
8. CPU·GPU 비용 측정
```

Cascade 수를 먼저 최대값으로 두면 각 단계가 실제로 필요한지 판단하기 어렵다.

가장 적은 수로 목표 품질을 만족시키는 구성을 찾는다.

---

## Split을 조절하는 실전 기준

대표 장면에서 다음 지점을 표시한다.

```text
0 m      : Camera
2 m      : Player 발밑 Shadow
10 m     : 근접 Enemy
30 m     : 주요 Building
80 m     : Background
100 m    : Shadow Distance
```

높은 품질이 필요한 대상이 어떤 Cascade에 들어가는지 확인한다.

경계가 Character가 자주 서는 거리나 넓은 평면 중앙을 지나면 변화가 잘 보인다.

복잡한 Geometry, Fog가 시작되는 지점이나 Contrast가 낮은 영역에 경계를 배치하면 전환을 감추기 쉬울 수 있다.

---

## 비교 장면

Cascade 품질은 고정 Screenshot과 움직임 테스트를 모두 사용한다.

```text
Test Object
├─ 대각선 난간: Aliasing 확인
├─ 긴 Wall: Cascade 경계 확인
├─ 얇은 기둥: Detail과 Bias 확인
├─ Character: 이동 Shadow 안정성
├─ Foliage: 생성 비용 확인
└─ 넓은 Ground: 전환선 확인
```

Camera 경로, FOV, Light 방향과 Shadow Distance를 고정한 뒤 Cascade Count와 Split만 바꾼다.

동일한 Frame에서 Game View와 GPU Capture를 비교한다.

---

## Profile에서 확인할 항목

```text
CPU
├─ Cascade별 Culling Time
├─ Shadow Draw Call
└─ Render Thread Time

GPU
├─ Main Light ShadowCaster Pass
├─ Cascade별 Geometry 처리
├─ Shadow Atlas Depth Write
└─ Receiver Shadow Sample

품질
├─ 근거리 계단 현상
├─ 이동 중 Shimmering
├─ Split 경계 변화
└─ Last Border Fade
```

Frame Debugger에서 Cascade별 ShadowCaster Event와 반복되는 Renderer를 확인한다.

Profiler의 평균값만 아니라 Camera 이동 중 Spike도 기록한다.

Editor가 아닌 Target Graphics API와 Device에서 최종 판단한다.

---

## 흔한 오해

### Cascade는 Shadow Resolution을 높이는 기능이다

전체 Texture의 설정 Resolution을 자동으로 높이는 기능이 아니다.

Frustum을 나누어 각 거리 구간에 Shadow Texel을 더 효율적으로 배분한다.

### Cascade 수가 많을수록 항상 선명하다

Atlas가 더 많은 Tile로 나뉘고 각 Cascade Rendering이 반복된다.

Split이 잘못 배치되면 필요한 구간의 품질이 오히려 부족할 수 있다.

### Cascade는 모든 Light에 적용된다

Unity의 Shadow Cascade는 Directional Light, URP에서는 Main Light에 적용되는 설정이다.

### Receiver는 매 Pixel에서 모든 Cascade를 Sample한다

일반 영역에서는 위치에 맞는 Cascade를 선택한다. 경계 Blend에서는 인접 Cascade Sample이 추가될 수 있다.

### 경계가 보이면 Resolution만 올리면 된다

Split 위치, Border, Bias, Filtering과 Projection 안정성도 원인이 될 수 있다.

### 4 Cascades는 1 Cascade보다 정확히 4배 비싸다

Caster 분포, 중복 Renderer, Tile 크기와 CPU·GPU 병목에 따라 증가 폭이 달라진다.

### Cascade가 있으면 Shadow Distance를 크게 해도 된다

Cascade는 제한된 예산을 재배분한다. Distance가 커지면 Caster 범위와 각 구간의 World Coverage도 증가한다.

---

## 정리

Cascade Shadow Map은 Camera Frustum을 거리별로 나누고 각 구간에 별도의 Directional Light Shadow Projection을 사용하는 방식이다.

Perspective Camera의 가까운 영역에서 하나의 Shadow Texel이 여러 Screen Pixel로 확대되는 Perspective Aliasing을 줄인다.

가까운 Cascade는 좁은 World 범위에 Texel을 집중하고 먼 Cascade는 넓은 범위를 담당해 제한된 Resolution을 화면 중요도에 맞게 배분한다.

Cascade Count는 구간 수를, Split은 각 구간의 경계를, Last Border는 Shadow Distance 끝의 Fade 영역을 결정한다.

Cascade를 늘리면 근거리 품질을 개선할 수 있지만 Cascade별 Culling, ShadowCaster Rendering과 Atlas Tile이 필요해 CPU·GPU 비용이 증가한다.

인접 Cascade는 Texel Density와 Projection이 달라 경계 Artifact가 발생할 수 있으며 Split, Blend, Bias와 Camera 이동을 함께 검증해야 한다.

적절한 구성은 필요한 Shadow Distance를 먼저 정한 뒤 가장 적은 Cascade 수에서 시작해 중요한 Gameplay 거리 중심으로 Split을 배치하는 것이다.

Target Device에서 Cascade별 Draw, Main Light Shadow Pass 시간, 경계와 Shimmering을 함께 측정해야 한다.
