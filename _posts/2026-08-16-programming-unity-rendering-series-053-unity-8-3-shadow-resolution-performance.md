---
title: "[Unity 렌더링] 8-3. Shadow Resolution은 성능에 어떤 영향을 줄까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - Shadow
  - ShadowResolution
  - Optimization
permalink: /programming/unity-8-3-shadow-resolution-performance/
toc: true
toc_sticky: true
date: 2026-08-16
last_modified_at: 2026-08-16
---

Shadow Resolution은 Light가 바라본 깊이를 얼마나 촘촘한 격자에 저장할지 결정한다.

```text
낮은 Resolution
├─ 적은 Shadow Texel
├─ 작은 Memory와 낮은 Rasterization 부담
└─ 계단과 흔들림이 잘 보임

높은 Resolution
├─ 많은 Shadow Texel
├─ 큰 Memory와 높은 Rasterization 부담
└─ 더 세밀한 경계를 표현할 수 있음
```

그러나 Resolution 숫자만 높인다고 항상 선명한 Shadow가 만들어지는 것은 아니다.

같은 Texture를 얼마나 넓은 World 영역에 펼치는지, Atlas에 몇 개의 Shadow를 넣는지, Camera에서 Shadow가 얼마나 크게 보이는지가 함께 품질과 비용을 결정한다.

---

## Shadow Resolution의 의미

`2048` Shadow Map은 가로와 세로에 각각 2048개의 Texel을 가진다.

```text
Shadow Resolution = 2048 × 2048
Shadow Texel 수   = 4,194,304
```

Shadow Map의 한 Texel에는 일반적으로 Light에서 가장 가까운 Surface의 Depth가 기록된다.

```text
Light가 보는 World 영역
        │ Projection
        ▼
┌─────────────────┐
│ Depth Texel Grid│
│ 2048 × 2048     │
└─────────────────┘
```

격자가 촘촘할수록 서로 가까운 두 위치를 다른 Depth Sample로 구분할 가능성이 커진다.

---

## 해상도를 2배로 올리면 Texel은 4배가 된다

Resolution은 한 변의 길이다.

| Resolution | 전체 Texel 수 | 1024 기준 |
| ---: | ---: | ---: |
| 512 × 512 | 262,144 | 0.25배 |
| 1024 × 1024 | 1,048,576 | 1배 |
| 2048 × 2048 | 4,194,304 | 4배 |
| 4096 × 4096 | 16,777,216 | 16배 |

```text
한 변 2배
→ 가로 Texel 2배
× 세로 Texel 2배
→ 전체 Texel 4배
```

따라서 `1024 → 2048`은 단순히 2배의 저장 공간을 요구하는 변경이 아니다.

Shadow Map 전체가 채워진다는 단순한 조건에서는 Depth Write 대상과 필요한 Memory가 최대 4배 규모로 증가한다.

---

## Screen Pixel과 Shadow Texel은 서로 다르다

Camera가 만드는 화면은 Screen Pixel로 구성되고 Shadow Map은 Shadow Texel로 구성된다.

```text
Camera Pixel ──World Position 변환──> Shadow Map UV
                                      │
                                      ▼
                                Shadow Texel Sample
```

여러 Screen Pixel이 같은 Shadow Texel을 읽으면 Shadow 경계가 블록처럼 보인다.

```text
화면의 Pixel
■■■■■■■■■■■■■■■■
        ↓
Shadow Texel
   A A A A B B B B
```

Camera가 Shadow에 가까이 다가가거나 Shadow를 확대해서 볼수록 하나의 Shadow Texel이 차지하는 Screen Pixel 수가 커진다.

이 때문에 같은 Shadow Resolution도 Camera 거리와 화면 구도에 따라 전혀 다르게 보인다.

---

## Texel Density가 실제 선명도를 결정한다

중요한 값은 Texture의 절대 크기만이 아니라 World 단위 면적에 배정된 Texel 수다.

```text
Texel Density ≈ Shadow Map 한 변의 Texel 수
                ───────────────────────────
                Light가 덮는 World 범위
```

예를 들어 단순하게 한 축만 비교하면 다음과 같다.

| Shadow Map | 덮는 범위 | 대략적인 밀도 |
| ---: | ---: | ---: |
| 1024 | 10 m | 102.4 texel/m |
| 2048 | 40 m | 51.2 texel/m |

2048 Map이 더 크지만 40 m를 덮으면 10 m를 덮는 1024 Map보다 가까운 영역의 밀도가 낮을 수 있다.

Unity 공식 문서도 Main Light의 `Max Distance`를 줄이면 더 낮은 Resolution으로 가까운 Shadow 품질을 높일 수 있다고 설명한다.

즉 다음 두 질문을 함께 해야 한다.

```text
Texture에 Texel이 몇 개인가?
            +
그 Texel을 어느 범위에 배분하는가?
```

---

## 낮은 Resolution에서 경계가 계단처럼 보이는 이유

Shadow 판정은 Receiver의 위치가 저장된 Depth보다 Light에서 먼지 비교해 얻는다.

```hlsl
float storedDepth  = SampleShadowMap(shadowUV);
float currentDepth = shadowCoord.z;
float shadow = currentDepth <= storedDepth ? 1.0 : 0.0;
```

실제 Pipeline은 Bias, Filtering과 Platform별 처리를 더하지만 핵심은 Depth 비교다.

한 Texel 안에서는 표현할 수 있는 경계 위치가 제한된다.

```text
실제 경계       ╱
낮은 해상도    ■■■
                 ■■■
                   ■■■
```

이를 Shadow Aliasing이라고 볼 수 있다.

Resolution을 높이면 계단 한 칸의 World 크기가 작아져 더 매끄러운 경계를 표현할 수 있다.

---

## Camera가 움직일 때 Shadow가 흔들리는 이유

낮은 Texel Density에서는 Camera나 Light가 조금 움직여도 Surface가 참조하는 Texel이 바뀔 수 있다.

```text
Frame N     : Receiver → Texel 42
Frame N + 1 : Receiver → Texel 43
```

경계가 Texel 단위로 이동하면서 반짝이거나 기어가는 것처럼 보이는 현상이 발생한다.

Resolution을 높이면 변화의 단위가 작아져 현상을 줄일 수 있다.

하지만 Projection 안정화, Cascade 전환, Bias와 Filtering도 관련되므로 Resolution만으로 모든 흔들림이 사라지는 것은 아니다.

---

## 높은 Resolution이 해결하지 못하는 문제

Resolution은 공간 표본의 밀도를 높이는 설정이다.

다음 문제에는 별도의 원인이 있다.

| 현상 | 주요 원인 | Resolution 증가 효과 |
| --- | --- | --- |
| 계단진 경계 | Texel 부족 | 직접적인 개선 가능 |
| Shadow Acne | Depth 정밀도와 Bias | 근본 해결 아님 |
| Peter Panning | 과도한 Bias | 근본 해결 아님 |
| Light Leak | Bias, 얇은 Geometry | 제한적 |
| 먼 거리의 낮은 품질 | 넓은 Coverage | Resolution과 거리 설정을 함께 조절 |
| Cascade 경계 변화 | Cascade 분배와 전환 | 근본 해결 아님 |

Acne가 보인다고 무조건 4096으로 올리거나 흐릿하다고 Bias를 크게 만드는 식의 조정은 원인과 해결책이 맞지 않을 수 있다.

---

## Memory 비용

Shadow Map은 GPU Texture Memory를 사용한다.

개념적인 계산은 다음과 같다.

```text
Memory ≈ Width × Height × Texel당 Byte
```

Texel당 4 Byte라고 단순 가정하면 다음과 같다.

| Resolution | 단순 계산 Memory |
| ---: | ---: |
| 1024 × 1024 | 약 4 MiB |
| 2048 × 2048 | 약 16 MiB |
| 4096 × 4096 | 약 64 MiB |

실제 사용량은 Depth Format, Platform, Texture 배열·Atlas 구성, Alignment와 내부 구현에 따라 달라진다.

이 표는 Profiler의 실제 수치를 대신하는 값이 아니라 한 변을 2배로 올릴 때 면적이 4배가 되는 관계를 보여 주는 계산이다.

---

## Shadow Map을 생성하는 GPU 비용

ShadowCaster Pass는 Light 관점에서 Geometry를 Rasterization하고 Depth를 기록한다.

```text
Caster Vertex 처리
        │
        ▼
Triangle Rasterization
        │
        ▼
Shadow Depth Test / Write
```

Resolution이 커지면 Triangle이 차지할 수 있는 Texel 수가 늘어난다.

큰 건물이나 지형처럼 Shadow Map을 넓게 덮는 Caster는 더 많은 Fragment 후보와 Depth Write를 만들 수 있다.

특히 Alpha Clipping을 사용하는 나뭇잎과 풀은 각 Texel에서 Alpha Texture를 읽고 `clip`을 수행하므로 높은 Resolution의 영향을 크게 받을 수 있다.

---

## Resolution을 4배로 올리면 Rendering 시간도 4배일까?

반드시 그렇지는 않다.

Shadow Pass 시간은 여러 비용의 합이다.

```text
Shadow Pass Time
├─ CPU Culling과 Draw 준비
├─ Vertex Processing
├─ Triangle Setup
├─ Fragment / Alpha Clipping
└─ Depth Bandwidth
```

Resolution은 Fragment와 Memory Traffic에 직접적인 영향을 주지만 Caster 수와 Vertex 수를 자동으로 4배 만들지는 않는다.

작은 Triangle이 많아 Vertex Bound인 Scene에서는 증가 폭이 작을 수 있다.

화면을 넓게 채우는 Foliage가 많아 Fill-rate와 Bandwidth Bound인 Scene에서는 증가 폭이 클 수 있다.

따라서 Texel 수 4배는 비용 증가 가능성을 설명하지만 GPU 시간 4배를 보장하는 공식은 아니다.

---

## Shadow를 읽는 비용에도 영향을 준다

Receiver Shader는 Shadow Map에서 Depth를 Sample한다.

Hard Shadow가 한 번 비교한다고 가정하면 Resolution을 높여도 명령의 Sample 횟수 자체는 그대로일 수 있다.

```text
1024 Map에서 1 Sample
2048 Map에서 1 Sample
→ Sample 명령 수는 동일할 수 있음
```

그러나 더 큰 Texture는 Cache Locality와 Memory Bandwidth에 불리할 수 있다.

Soft Shadow는 주변 Texel을 여러 번 읽으므로 Filtering 품질과 Kernel 크기의 영향도 함께 받는다.

```text
PCF 예시

□ □ □
□ ■ □  ← 중심 주변 Depth 비교
□ □ □
```

Shadow Sampling 비용은 Resolution 하나보다 Filter Sample 수, 화면의 Receiver Pixel 수와 Cache 동작까지 측정해야 정확하다.

---

## Resolution과 Soft Shadow의 관계

Soft Shadow는 주변 Texel의 비교 결과를 섞어 경계를 부드럽게 만든다.

```text
낮은 Resolution + Filtering
→ 계단을 감출 수 있음
→ 작은 Detail은 소실될 수 있음

높은 Resolution + Filtering
→ 세밀한 경계 위에서 부드러운 전환 가능
→ Memory와 생성 비용이 커질 수 있음
```

같은 Texel 반경의 Filter라도 World에서 차지하는 크기는 Texel Density에 따라 달라진다.

Resolution을 바꾸면 Shadow의 체감 Softness가 달라질 수 있으므로 선명도만 비교하지 말고 Filter 설정도 함께 확인한다.

모바일과 XR의 Tile-based GPU에서는 Soft Shadow Filtering 자체가 큰 비용이 될 수 있다.

---

## URP의 Main Light Shadow Resolution

URP Asset의 다음 위치에서 Main Light Shadow Map Resolution을 설정한다.

```text
URP Asset
└─ Lighting
   └─ Main Light
      └─ Shadow Resolution
```

Directional Main Light는 일반적으로 Camera 주변의 넓은 영역을 덮어야 한다.

같은 Resolution을 너무 먼 거리까지 펼치면 가까운 Character에게 배정되는 Texel Density도 낮아진다.

```text
고정된 Shadow Map
├─ 좁은 범위에 사용 → 높은 Texel Density
└─ 넓은 범위에 사용 → 낮은 Texel Density
```

Resolution을 올리기 전에 Shadow가 실제로 필요한 거리와 Cascade 배분이 적절한지 확인해야 한다.

Shadow Distance 자체의 동작과 조절 기준은 다음 글에서 구체적으로 다룬다.

---

## Cascade와 Resolution

Directional Light Cascade는 Camera Frustum을 여러 거리 구간으로 나눈다.

```text
Camera
├─ Cascade 0: Near
├─ Cascade 1
├─ Cascade 2
└─ Cascade 3: Far
```

각 Cascade는 담당 범위에 Shadow Texel을 배정해 가까운 영역의 밀도를 유지한다.

하지만 Cascade 수를 늘리면 Shadow View와 Caster Rendering 횟수가 증가하고 Atlas 공간도 분할해 사용해야 한다.

```text
Main Light Shadow Atlas 예시
┌────────┬────────┐
│  C0    │  C1    │
├────────┼────────┤
│  C2    │  C3    │
└────────┴────────┘
```

Atlas가 2048이고 네 Cascade가 2 × 2로 배치되는 구성이라면 각 Tile 한 변은 개념적으로 1024 규모가 된다.

실제 배치와 사용 방식은 Unity·URP Version과 설정에 따라 달라질 수 있지만 Cascade가 공짜로 Resolution을 만드는 것은 아니라는 점이 중요하다.

---

## Additional Light는 Shadow Atlas를 공유한다

URP의 Additional Light Shadow는 여러 Light가 하나의 Shadow Atlas 공간을 나누어 사용한다.

```text
Additional Shadow Atlas
┌────────┬────────┐
│Light A │Light B │
├────────┼────────┤
│Light C │Light D │
└────────┴────────┘
```

Unity 공식 문서의 예시처럼 1024 Atlas에는 512 × 512 Map 네 개 또는 256 × 256 Map 열여섯 개를 배치할 수 있다.

| Atlas | 개별 Map | 단순 수용량 |
| ---: | ---: | ---: |
| 1024 × 1024 | 512 × 512 | 4개 |
| 1024 × 1024 | 256 × 256 | 16개 |

Atlas Resolution은 전체 그릇의 크기이고 Additional Light의 Shadow Resolution은 각 Light에 원하는 Tile 크기다.

---

## Point Light 하나가 Atlas Tile 여섯 개를 사용한다

Spot Light는 한 방향의 Shadow Map이 필요하지만 Point Light는 모든 방향을 표현하기 위해 여섯 Face가 필요하다.

```text
Spot Light 1개  → Shadow Map 1개
Point Light 1개 → Shadow Map 6개
```

공식 문서의 예시에서 Shadow를 만드는 Spot Light 네 개와 Point Light 한 개는 총 열 개의 Shadow Map을 요구한다.

```text
Spot 4 × 1 Face  = 4
Point 1 × 6 Face = 6
전체             = 10 Maps
```

각 Map에 최소 256 Resolution을 배정하려면 512 Atlas로는 부족하고 1024 Atlas가 필요하다.

따라서 Additional Shadow의 비용은 Light 개수만 세기보다 필요한 Face 수와 Tile Resolution을 함께 계산해야 한다.

---

## Atlas가 부족하면 생기는 Trade-off

요청한 Shadow Tile을 Atlas에 모두 넣을 수 없다면 Pipeline은 제한된 공간에 맞게 Shadow Resolution을 낮춰야 할 수 있다.

```text
Atlas 공간 부족
├─ 더 큰 Atlas 필요
├─ 개별 Light Resolution 감소
├─ Shadow Light 수 감소
└─ Point를 Spot으로 변경
```

Atlas를 크게 만들면 품질을 유지할 수 있지만 Memory와 Depth Render 영역이 증가한다.

개별 Tile을 줄이면 Atlas는 절약하지만 해당 Light의 Shadow 경계가 거칠어진다.

모든 Additional Light에 같은 Resolution을 주기보다 화면 기여도에 따라 등급을 나누는 편이 효율적이다.

---

## Additional Light Shadow Resolution Tier

URP Asset은 Additional Light Shadow Resolution Tier를 Low, Medium, High로 나눌 수 있다.

```text
High
└─ 주 Character와 핵심 연출 Light

Medium
└─ 일반적인 Gameplay Light

Low
└─ 작거나 멀리 있는 보조 Light
```

Unity 문서에 따르면 Tier 값은 최소 128이며 지원되는 값에 맞게 다음 2의 거듭제곱으로 처리된다.

Scene의 모든 Light를 High로 지정하면 Tier를 둔 의미가 사라진다.

Light가 화면에서 만드는 Shadow의 크기와 중요도를 기준으로 예산을 배분한다.

---

## CPU와 GPU 중 어디에 더 직접적인 영향을 줄까?

Resolution 자체는 GPU의 Rasterization, Depth Memory와 Bandwidth에 더 직접적인 영향을 준다.

```text
Resolution 증가
├─ CPU Caster 수          : 대체로 직접 변화 없음
├─ CPU Draw Command 수    : 대체로 직접 변화 없음
├─ GPU Shadow Texel 처리  : 증가 가능
├─ GPU Memory             : 증가
└─ GPU Bandwidth / Cache  : 부담 증가 가능
```

CPU가 병목인 Scene에서 Resolution만 낮춰도 Frame Rate 변화가 작을 수 있다.

반대로 GPU Fill-rate나 Memory Bandwidth가 병목이면 Resolution 감소가 크게 작용할 수 있다.

어느 쪽인지 확인하지 않고 Quality만 낮추면 화면만 나빠지고 성능은 거의 그대로일 수 있다.

---

## Platform별로 같은 값이 적절하지 않은 이유

Desktop GPU, Mobile GPU와 XR 기기는 Memory 용량과 Bandwidth 구조가 다르다.

| 환경 | Resolution 판단에서 중요한 요소 |
| --- | --- |
| Desktop | 목표 GPU Frame Time, 고해상도 Display |
| Mobile | Memory Bandwidth, 발열, Tile-based GPU |
| XR | 두 Eye의 높은 Receiver Pixel 수, 안정적인 Frame Time |
| 저사양 | Atlas Memory와 Fill-rate 예산 |

4K Monitor에서 가까이 보는 Character Shadow와 작은 Mobile 화면의 Background Shadow에 같은 예산을 줄 필요는 없다.

URP Asset이나 Quality Level을 Platform별로 분리해 Shadow Resolution과 Distance를 다르게 구성한다.

---

## 품질을 조절하는 실전 순서

Resolution을 최고값부터 내리는 방식보다 필요한 품질을 기준으로 올리는 편이 원인을 파악하기 쉽다.

```text
1. Target Platform과 Frame Budget 결정
2. 실제 필요한 Shadow Distance 설정
3. Main Light Cascade 구성 확인
4. 낮은 Resolution에서 시작
5. 가까운 핵심 Shadow의 계단과 흔들림 확인
6. 필요한 단계까지만 Resolution 증가
7. Additional Light별 Tier 배정
8. 실제 Device에서 GPU 시간과 Memory 측정
```

한 번에 Resolution, Cascade, Distance와 Soft Shadow를 모두 바꾸면 어떤 설정이 품질과 성능을 바꿨는지 구분하기 어렵다.

한 변수씩 변경하고 같은 Camera 경로를 비교한다.

---

## Resolution을 올리기 전에 줄일 수 있는 범위

Shadow Detail이 부족할 때 항상 Texture부터 키울 필요는 없다.

```text
품질 부족
├─ 불필요하게 먼 Shadow Distance인가?
├─ Cascade Split이 핵심 구간에 맞는가?
├─ Additional Atlas가 Tile을 충분히 담는가?
├─ 중요하지 않은 Shadow Light가 공간을 차지하는가?
└─ Bias나 Filtering 문제를 Resolution 문제로 오해했는가?
```

필요 없는 먼 영역을 제외하면 같은 Resolution의 Texel을 가까운 곳에 더 집중할 수 있다.

작은 장식 Light의 Shadow를 끄면 핵심 Additional Light에 Atlas 공간을 남길 수 있다.

Point Light를 Spot Light로 바꿀 수 있다면 여섯 Face를 한 Face로 줄일 수 있다.

---

## Profile할 때 확인할 항목

Unity Profiler와 GPU Profiler에서 Resolution 변경 전후를 같은 조건으로 비교한다.

```text
측정 항목
├─ Main Light Shadow Pass GPU Time
├─ Additional Light Shadow Pass GPU Time
├─ Shadow 관련 Render Texture Memory
├─ ShadowCaster Draw Call
├─ 전체 GPU Frame Time
└─ 목표 Device의 발열과 지속 성능
```

Frame Debugger에서는 Main Light와 Additional Light의 ShadowCaster Pass가 몇 번 실행되는지 확인한다.

Rendering Debugger와 Game View에서는 실제 Shadow 경계, Cascade와 Atlas 관련 상태를 확인한다.

Editor 수치만으로 결론을 내리지 말고 최종 Graphics API와 Device에서 측정한다.

---

## 비교 장면을 만드는 방법

Shadow 품질은 Camera 위치에 크게 의존하므로 고정된 비교 장면이 필요하다.

```text
Test Scene
├─ 대각선 난간: 계단 현상 확인
├─ 얇은 기둥: Detail 보존 확인
├─ 움직이는 Character: 흔들림 확인
├─ Foliage: Alpha Clip 비용 확인
└─ 먼 건물: Distance와 Cascade 확인
```

다음 조건을 고정한다.

- Camera 위치와 FOV
- Light 방향과 움직임
- Shadow Distance와 Cascade
- Render Scale과 화면 해상도
- Soft Shadow 품질
- Caster와 Receiver 수

그 뒤 Shadow Resolution만 바꿔 Screenshot과 GPU Time을 함께 기록한다.

---

## 흔한 오해

### Resolution이 높으면 Shadow는 항상 정확하다

공간 표본은 촘촘해지지만 Bias, Projection, Cascade와 Filtering 문제는 남는다.

### 2048은 1024보다 비용이 2배다

한 변은 2배지만 Texel 수와 단순 Memory 규모는 4배다.

### Shadow Resolution은 GPU에만 영향을 준다

직접 영향은 GPU와 Memory 쪽이 크지만 전체 성능은 Caster Culling, Draw Call과 Sampling을 포함해 판단해야 한다.

### Atlas Resolution과 Light Resolution은 같은 값이다

Atlas는 여러 Shadow Map을 담는 전체 공간이고 Light Resolution은 그 안에 배정할 개별 Tile의 크기다.

### 모든 Light를 High Tier로 두면 가장 좋다

Atlas 공간은 한정되어 있으므로 중요도가 낮은 Light까지 크게 배정하면 Memory를 늘리거나 다른 Light의 품질을 낮출 수 있다.

---

## 정리

Shadow Resolution은 Light 관점의 Depth를 저장하는 Texel 격자의 크기다.

한 변을 2배로 올리면 전체 Texel 수와 단순 Memory 규모는 4배가 된다.

높은 Resolution은 Shadow 경계의 계단과 움직임에 따른 흔들림을 줄일 수 있지만 Bias, Light Leak와 Cascade 전환의 근본 해결책은 아니다.

실제 품질은 Resolution보다 World 범위당 Texel 수인 Texel Density로 판단해야 한다.

Main Light는 Shadow Distance와 Cascade가 Texel 배분을 바꾸고 Additional Light는 여러 Light와 Point Light의 여섯 Face가 Shadow Atlas를 공유한다.

Resolution은 GPU Rasterization, Depth Memory와 Bandwidth에 직접 영향을 주지만 GPU 시간이 정확히 Texel 수에 비례하지는 않는다.

가장 높은 값을 선택하는 대신 필요한 거리, Atlas 수용량과 Light 중요도를 먼저 정하고 실제 Target Device에서 품질과 GPU Frame Time을 함께 측정해야 한다.
