---
title: "[Unity 렌더링] 6-8. Forward+는 왜 등장했을까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - URP
  - ForwardPlus
  - LightCulling
permalink: /programming/unity-6-8-why-forward-plus/
toc: true
toc_sticky: true
date: 2026-08-16
last_modified_at: 2026-08-16
---

일반 Forward Rendering은 Object를 그릴 때 해당 Object에 영향을 주는 Light 목록을 Shader에 전달한다.

이 구조는 Light가 적을 때 단순하고 효율적이지만 한 Object가 계산할 Realtime Light 수에 제한이 있다.

큰 Mesh나 Light가 밀집된 Scene에서는 필요한 Light가 목록에서 빠지거나 Light 기여가 갑자기 교체될 수 있다.

Forward+는 Forward Shading을 유지하면서 Light를 Object가 아니라 화면 영역을 기준으로 Culling해 이 문제를 해결한다.

```text
일반 Forward
Object → 제한된 Light List → Forward Shader

Forward+
Screen Tile / Depth 영역 → 관련 Light List
                         → Forward Shader
```

G-buffer를 만드는 Deferred와 달리 Material Lighting은 여전히 Geometry를 그리는 순간 계산한다.

`+`는 Forward에 화면 공간 Light Culling 단계를 더했다는 의미로 이해할 수 있다.

---

## Forward+란?

Forward+는 Forward Rendering과 Clustered Light Culling을 결합한 Rendering Path다.

```text
Forward Shading
+ Screen-space Light Culling
        │
        ▼
Forward+
```

먼저 Camera에 보이는 Light를 화면의 작은 영역별로 분류한다.

Object Fragment를 Lighting할 때 현재 Pixel이 속한 영역의 Light만 순회한다.

일반 Forward의 Object별 Light Limit를 사용하지 않으면서 모든 Light를 모든 Pixel에서 검사하는 낭비를 줄인다.

---

## URP의 세 가지 Rendering Path

Universal Renderer는 다음 Path를 제공한다.

```text
Universal Renderer
├─ Forward
│  └─ Object별 제한된 Light List
│
├─ Forward+
│  └─ Tile / Cluster별 Light List
│
└─ Deferred
   └─ G-buffer 이후 Screen-space Lighting
```

Forward+는 이름처럼 Forward 계열이다.

Deferred의 변형이 아니며 G-buffer가 핵심 요구 사항도 아니다.

---

## 일반 Forward의 Object별 Light List

일반 Forward에서 Unity는 Renderer 하나에 영향을 줄 Light를 선별한다.

```text
Large Floor Object
├─ Light A
├─ Light B
├─ Light C
├─ Light D
├─ Light E
├─ Light F
├─ Light G
├─ Light H
└─ Light I 이상
        │
        ▼
Per Object Limit 안의 Light만 Shader에 전달
```

Unity 6 URP의 일반 Forward는 Object당 Main Light 1개와 Additional Light 최대 8개를 사용할 수 있다.

실제 Additional Light 수는 URP Asset의 `Per Object Limit` 설정에 영향을 받는다.

---

## Object별 제한이 필요한 이유

모든 Object에 Camera의 모든 Light Data를 전달하면 CPU와 GPU 비용이 커진다.

```text
Camera Visible Lights: 100개

Object A 주변 실제 Light: 3개
Object B 주변 실제 Light: 5개
Object C 주변 실제 Light: 2개
```

Object별 목록은 관련 Light만 제공해 Shader Loop를 제한한다.

고정된 최대 수는 Buffer Layout과 Shader 실행 비용을 예측하기 쉽게 만든다.

하지만 Scene의 Light 밀도가 최대 수를 넘으면 Visual 제한이 된다.

---

## 큰 Mesh에서 생기는 문제

Object별 Light List는 Mesh의 각 Pixel이 아니라 Object Bounds를 기준으로 한다.

```text
하나의 큰 Floor Mesh
┌──────────────────────────────┐
│ L1  L2  L3  L4  L5  L6  L7 │
│ L8  L9  L10 L11 L12 L13 L14│
└──────────────────────────────┘
```

서로 멀리 떨어진 Light도 같은 Floor Object의 목록 후보가 된다.

Per Object Limit를 넘으면 Floor의 일부 영역에 필요한 Light가 빠질 수 있다.

Mesh를 나누면 개선되지만 Renderer와 Draw Call 수가 늘어나는 Trade-off가 있다.

---

## Light Pop 문제

Object 또는 Camera가 움직일 때 Light 우선순위가 바뀌면 제한된 목록의 구성도 바뀔 수 있다.

```text
Frame A
Object Lights = L1, L2, L3, L4

Frame B
Object Lights = L1, L2, L3, L5
                              ↑
                          L4와 교체
```

L4의 기여가 사라지고 L5가 나타나면서 Lighting이 Pop처럼 보일 수 있다.

Limit을 높여도 일반 Forward의 최대 범위 안에서만 해결된다.

Forward+는 Object별 고정 목록 자체를 제거한다.

---

## 모든 Light를 순회하는 단순 해결의 문제

Object Limit를 없애고 Camera의 모든 Light를 Fragment마다 순회할 수도 있다고 생각할 수 있다.

```text
1920 × 1080 Pixel
× Camera Light 100개
→ 매우 많은 Light Test와 BRDF 계산
```

대부분의 Point와 Spot Light는 화면의 일부 영역에만 영향을 준다.

화면 반대편 Light까지 모든 Pixel에서 검사하는 것은 낭비다.

Forward+는 먼저 Light 영향 영역을 분류해 Pixel Loop 후보를 줄인다.

---

## 화면을 Tile로 나눈다

Forward+는 Camera 화면을 작은 Tile로 나눈다.

```text
Screen
┌────┬────┬────┬────┐
│ T0 │ T1 │ T2 │ T3 │
├────┼────┼────┼────┤
│ T4 │ T5 │ T6 │ T7 │
├────┼────┼────┼────┤
│ T8 │ T9 │T10 │T11 │
└────┴────┴────┴────┘
```

각 Light의 Screen-space Bounds가 어떤 Tile과 겹치는지 계산한다.

Tile마다 영향을 줄 수 있는 Light Index 목록을 만든다.

---

## Tile별 Light List

```text
T0 → L0, L3
T1 → L0, L1, L3
T2 → L1
T3 → 없음

T4 → L0, L2
T5 → L0, L1, L2
T6 → L1, L4
T7 → L4
```

Fragment Shader는 자신의 Screen Position으로 Tile을 찾는다.

그 Tile의 List에 있는 Light만 Lighting한다.

```text
Fragment at T6
→ L1과 L4만 계산
→ 다른 Camera Light는 순회하지 않음
```

---

## Depth 구간이 필요한 이유

2D Tile만 사용하면 화면 위치는 같지만 Camera에서 아주 멀리 떨어진 Light도 같은 목록에 들어갈 수 있다.

```text
Camera Ray
├─ Near Light A
├─ Surface at Middle
└─ Far Light B

같은 Screen Tile에 투영될 수 있음
```

View Depth를 여러 구간으로 나누면 Near와 Far Light를 더 세밀하게 분류할 수 있다.

```text
Tile X
├─ Depth Bin 0 → L0, L1
├─ Depth Bin 1 → L2
└─ Depth Bin 2 → L3, L4
```

이처럼 화면 Tile과 Depth 구간을 결합한 공간을 Cluster로 이해할 수 있다.

---

## Clustered Light Culling

Cluster는 Camera Frustum을 작은 3D 영역으로 분할한 것이다.

```text
Camera Frustum
Near
┌──┬──┐
│  │  │
└──┴──┘
   ┌────┬────┐
   │    │    │
   └────┴────┘
Far
```

Perspective Camera에서는 먼 영역의 공간 범위가 커진다.

Depth Distribution을 균등 거리로만 나누지 않고 Projection 특성에 맞게 구성할 수 있다.

URP 내부 세부 크기와 Algorithm은 Version과 Platform에 따라 달라질 수 있다.

---

## Light Culling 단계

Forward+의 추가 단계는 다음처럼 볼 수 있다.

```text
Camera Visible Lights
        │
        ▼
Light의 View / Screen Bounds 계산
        │
        ▼
Tile과 Depth Range 교차 검사
        │
        ▼
Cluster별 Light Index List 생성
        │
        ▼
GPU Shader에서 List 조회
```

이 단계는 무료가 아니다.

Camera마다 Light Data를 분류하고 GPU가 읽을 Buffer를 준비해야 한다.

---

## Fragment Shader의 흐름

```text
Fragment
├─ positionCS
├─ positionWS
├─ normalWS
└─ viewDirectionWS
        │
        ▼
Screen UV와 Depth로 Cluster 찾기
        │
        ▼
Cluster Light List 순회
        │
        ▼
Material BRDF와 Light 누적
        │
        ▼
Camera Color
```

Material과 Light가 만나는 시점은 Forward와 같다.

Light 후보를 찾는 방식만 Object List에서 Cluster List로 바뀐다.

---

## Forward Shading을 유지한다

Forward+는 Geometry Pass에서 최종 Lighting Color를 계산한다.

```text
Geometry
+ Material Texture
+ Cluster Light List
+ Shadow
+ Reflection
        │
        ▼
UniversalForward Shader
        │
        ▼
Camera Color + Depth
```

Surface Data를 여러 G-buffer에 Encoding하지 않는다.

그래서 Forward의 정확한 Per-pixel Normal과 Material 유연성을 유지할 수 있다.

---

## Object별 Light 제한 제거

Forward+에서는 Object가 Light 목록을 하나만 공유하지 않는다.

같은 Mesh라도 Pixel 위치에 따라 다른 Cluster List를 읽는다.

```text
Large Floor Mesh
┌──────────┬──────────┬──────────┐
│ L1, L2   │ L3, L4   │ L5, L6   │
├──────────┼──────────┼──────────┤
│ L7       │ L8, L9   │ L10      │
└──────────┴──────────┴──────────┘
```

큰 Mesh를 Light Limit 때문에 인위적으로 나눌 필요가 줄어든다.

화면의 각 영역은 실제로 겹치는 Light를 계산한다.

---

## 무제한이라는 말의 의미

Unity 문서는 Forward+에 Object당 Realtime Light 제한이 없다고 설명한다.

이는 Camera와 Hardware 전체에서 Light가 무한하다는 뜻이 아니다.

```text
Object별 Limit
└─ 없음

Camera별 Visible Light Limit
└─ 존재

Cluster List Capacity
└─ Implementation과 Platform 제한 존재 가능

성능 Budget
└─ 항상 존재
```

Unity 6 공식 비교표는 Forward+의 Camera당 Realtime Light를 Platform에 따라 최대 256개로 제시한다.

---

## Platform별 Visible Light

Light Limit는 URP Version과 Platform에 따라 달라질 수 있다.

Unity 6 문서의 일반적인 범주는 다음과 같다.

```text
Desktop / Console
→ 높은 Camera Visible Light Limit

Mobile
→ 더 낮은 Camera Visible Light Limit

OpenGL ES 계열
→ 더 제한적인 범위 가능
```

숫자를 Shader Code에 직접 Hardcoding하지 않는다.

URP Macro와 Package Constant를 사용하고 사용 중인 Version 문서를 확인한다.

---

## Main Light 처리 차이

일반 Forward는 Main Light와 Additional Light를 구분한다.

Forward+에서는 Main과 Additional Light 설정의 일부를 다르게 해석한다.

```text
일반 Forward
├─ Main Light 설정
├─ Additional Lights 설정
└─ Per Object Limit

Forward+
├─ Light를 Per-pixel로 처리
├─ Main / Additional 설정 일부 무시
└─ Per Object Limit 무시
```

Renderer Path를 Forward+로 바꾼 뒤 URP Asset의 기존 Light Setting이 모두 같은 방식으로 적용된다고 가정하면 안 된다.

---

## Per Vertex Light를 사용하지 않는다

일반 Forward는 Additional Light를 Per Vertex로 계산할 수 있다.

Forward+는 Light를 Per Pixel로 처리한다.

```text
일반 Forward Per Vertex
Vertex에서 Light 계산
→ Fragment로 보간

Forward+
Fragment의 Cluster List로 Per-pixel Light 계산
```

낮은 Vertex Density에서 작은 Light가 사라지는 문제는 줄어든다.

대신 Fragment Light Loop 비용을 Vertex 단계로 옮기는 선택은 사용할 수 없다.

---

## Per Object Limit 설정을 무시한다

URP Asset의 다음 설정은 일반 Forward에서 중요한 Quality Control이다.

```text
Additional Lights
└─ Per Object Limit
```

Forward+에서는 Object별 목록을 사용하지 않으므로 이 값을 무시한다.

Limit 값을 2로 낮춰도 Forward+ Cluster에 Light가 2개만 들어가는 것이 아니다.

Forward+ 성능은 Light Range, Screen Overlap, Camera Visible Light와 Cluster 밀도로 조절해야 한다.

---

## Reflection Probe 처리

일반 Forward는 Object별 Reflection Probe Blending 수에 제한이 있다.

Forward+는 Clustered Data 구조를 활용해 더 많은 Probe를 처리할 수 있다.

```text
Cluster
├─ Local Lights
└─ Reflection Probes
```

Unity는 두 개를 넘는 Reflection Probe Blending이 필요할 때 Forward+를 선택 후보로 제시한다.

Probe 수가 늘면 Sampling과 Blending 비용도 증가한다.

Probe Resolution, Volume Overlap과 Priority를 함께 관리한다.

---

## Entities와 Procedural Draw

Object별 CPU Light List는 GameObject Renderer 중심 구조와 잘 맞는다.

많은 Entity와 Procedural Draw에서는 Screen Cluster 기반 Light 조회가 더 유연할 수 있다.

```text
GPU-driven / Procedural Geometry
        │
        ├─ Object별 CPU Light Index 전달 부담
        └─ Cluster Light Buffer를 Shader에서 조회
```

Unity는 Entities Package를 사용할 때 Forward+를 선택 기준으로 안내한다.

실제 지원 범위는 Entities Graphics와 URP Version을 함께 확인해야 한다.

---

## Forward+와 Deferred의 공통점

둘 다 많은 Light를 다루기 위해 화면 영역 기반 Light Culling을 활용할 수 있다.

```text
공통
├─ Camera Visible Light 분류
├─ Tile / Cluster 개념
├─ Object별 Light Limit 제거
└─ Screen 영역별 Light 비용
```

하지만 Surface Data와 Lighting 시점은 다르다.

```text
Forward+
Geometry Draw 안에서 Lighting

Deferred
G-buffer 이후 Lighting Pass
```

---

## Forward+와 Deferred의 차이

| 항목 | Forward+ | Deferred |
| --- | --- | --- |
| Surface Data | Shader에서 즉시 사용 | G-buffer에 저장 |
| Lighting | Geometry Fragment 안에서 계산 | 별도 Deferred Pass |
| G-buffer | 필수 아님 | 필수 |
| MSAA | 지원 | 지원하지 않음 |
| Normal | Encoding 없이 직접 사용 | Encoding·Decoding |
| Material | Forward Material 유연성 | G-buffer Layout 제약 |
| Transparent | 같은 Forward+ 구조 활용 가능 | Forward 단계에서 처리 |
| Memory | G-buffer보다 낮을 가능성 | MRT Bandwidth 큼 |

Forward+는 많은 Light와 Forward Material의 장점을 함께 얻으려는 선택지다.

---

## Forward+와 일반 Forward의 차이

| 항목 | Forward | Forward+ |
| --- | --- | --- |
| Light Culling | Object별 | Tile·Cluster별 |
| Object별 Realtime Light | 제한 있음 | 제한 없음 |
| Camera별 Light | Platform 제한 | Platform 제한 |
| Additional Light Mode | Per Vertex 또는 Per Pixel | Per Pixel |
| Per Object Limit | 사용 | 무시 |
| Reflection Probe | Object별 제한 | 더 많은 Blending 가능 |
| Culling 준비 비용 | 비교적 단순 | Cluster 구성 비용 추가 |
| 적합한 Scene | Light가 적음 | Light가 많고 지역적임 |

Light가 적으면 일반 Forward의 단순함이 더 효율적일 수 있다.

---

## MSAA를 지원한다

Forward+는 Forward Shading 계열이므로 URP에서 MSAA를 사용할 수 있다.

```text
Forward+
├─ Camera Color MSAA
├─ Camera Depth MSAA
└─ Final Resolve
```

많은 Light와 Hardware MSAA가 동시에 필요한 경우 Deferred보다 적합할 수 있다.

MSAA Sample 수가 늘면 Color·Depth Memory와 Resolve 비용이 증가한다.

Forward+ Light Loop와 MSAA의 조합을 실제 Target GPU에서 측정해야 한다.

---

## Transparent Lighting

Forward+는 Opaque와 Transparent 모두 Geometry Draw에서 Lighting할 수 있다.

```text
Opaque Forward+
→ Cluster Light List
→ Color + Depth

Transparent Forward+
→ Cluster Light List
→ Existing Color와 Blend
```

Deferred Renderer에서 Transparent가 일반 Forward Fallback으로 처리되는 것과 구분된다.

Transparent도 Object별 Light 제한 없이 많은 Light를 받을 수 있는 구조적 장점이 있다.

Blend와 Overdraw 비용은 그대로 존재한다.

---

## Transparent에서의 비용

Cluster List가 Light 후보를 줄여도 Transparent Fragment가 여러 번 겹치면 Lighting이 반복된다.

```text
Pixel
├─ Smoke Layer 1 × Light Loop
├─ Smoke Layer 2 × Light Loop
├─ Glass Layer × Light Loop
└─ Particle Layer × Light Loop
```

Light가 많은 VFX는 Forward+에서 매우 비쌀 수 있다.

Particle Shader 단순화, Light Range, Blend Area와 Soft Particle를 함께 최적화한다.

---

## Light Range가 중요한 이유

Light Range가 커지면 더 많은 Cluster와 겹친다.

```text
Small Point Light
→ 4개 Cluster

Large Point Light
→ 80개 Cluster
```

각 Cluster List가 길어지고 더 많은 Pixel이 Light를 계산한다.

Forward+가 많은 Light를 지원한다고 Range를 과도하게 늘리면 Culling 이점이 줄어든다.

보이는 영향 범위에 맞춰 최소 Range를 사용한다.

---

## Spot Angle과 방향

Spot Light의 Cone이 넓으면 많은 Screen Tile과 Depth 구간에 걸친다.

```text
Narrow Spot
└─ 작은 Cluster 집합

Wide Spot
└─ 큰 Cluster 집합
```

Spot Direction과 Camera 관계에 따라 Screen Projection 크기가 크게 변할 수 있다.

Camera 앞을 향한 Wide Spot은 화면 대부분에 영향을 줄 수 있다.

Lighting Complexity View로 실제 Overlap을 확인한다.

---

## Directional Light

Directional Light는 위치와 Range가 없으며 Scene 전체에 영향을 준다.

```text
Directional Light
→ 모든 Surface 후보
→ Local Cluster Culling으로 제거하기 어려움
```

Forward+ Custom Shader에서는 Main이 아닌 Directional Light를 별도 Loop로 처리할 수 있다.

Directional Light가 많으면 모든 Fragment에서 반복될 가능성이 크다.

일반적으로 주요 Directional Light 수를 작게 유지한다.

---

## Light Culling 비용

Forward+에는 일반 Forward보다 복잡한 사전 작업이 있다.

```text
CPU / GPU 준비 후보
├─ Visible Light 수집
├─ View Space Bounds
├─ Tile Range
├─ Depth Bin Range
├─ Index Buffer 구성
└─ Shader Constant 준비
```

Light가 한두 개뿐이면 이 Culling 비용이 절약하는 Fragment 작업보다 클 수 있다.

Forward+가 Light 수와 무관하게 항상 일반 Forward보다 빠르지 않은 이유다.

---

## Light List Memory

Cluster별 Light Index를 저장할 Buffer가 필요하다.

```text
Cluster Metadata
├─ List Start Offset
└─ Light Count

Light Index Buffer
├─ L0
├─ L3
├─ L7
└─ ...
```

많은 Light가 넓은 영역에 겹치면 Index Data가 증가할 수 있다.

G-buffer 여러 장보다 작을 가능성이 있지만 무료 Memory는 아니다.

GPU Capture와 Profiler로 Buffer 크기와 Lifetime을 확인한다.

---

## Cluster Light Loop 비용

Pixel이 속한 Cluster의 Light 수만큼 BRDF가 반복된다.

```text
Cluster A: Light 2개
→ Fragment당 2회

Cluster B: Light 20개
→ Fragment당 20회
```

Object별 Limit가 사라졌으므로 아주 많은 Light가 한 Cluster에 겹치면 Shader Loop가 길어진다.

Visual이 정확해지는 대신 실제 Lighting 연산을 지불한다.

Light Complexity를 성능 Budget으로 관리해야 한다.

---

## Worst Case

모든 Light가 화면 전체와 넓은 Depth Range를 덮는 조건은 Forward+에 불리하다.

```text
100 Large Lights
└─ 거의 모든 Cluster에 포함
        │
        ▼
거의 모든 Pixel에서 긴 Light Loop
```

Cluster Culling이 제거할 Light가 거의 없다.

Light 수 지원과 Light 수 성능을 같은 것으로 이해하면 안 된다.

무제한 Object Light는 품질 제약 제거이며 무제한 성능 보장이 아니다.

---

## Best Case

많은 Light가 있지만 각 Light의 Range가 작고 화면의 서로 다른 영역에 분산된 조건은 Forward+에 유리하다.

```text
100 Small Lights
├─ Cluster A에는 3개
├─ Cluster B에는 1개
├─ Cluster C에는 4개
└─ 대부분 Cluster에는 소수
```

Camera 전체 Light는 많아도 Pixel마다 계산하는 Light는 적다.

Object별 Limit 없이 지역 Lighting을 정확히 표현할 수 있다.

---

## Forward+ 선택 설정

Universal Renderer Data에서 Rendering Path를 선택한다.

```text
URP Asset
└─ Renderer List
   └─ Universal Renderer Data
      └─ Rendering Path: Forward+
```

Project에 Renderer Data가 여러 개면 현재 Camera가 해당 Renderer를 선택하는지 확인한다.

Quality Level마다 다른 URP Asset과 Renderer를 사용할 수 있으므로 Active 설정을 점검한다.

---

## Path 변경 후 확인할 설정

Forward+는 다음 일반 Forward Setting을 무시하거나 다르게 처리한다.

- Main Light Mode
- Additional Lights Mode
- Additional Lights의 Per Object Limit
- Reflection Probe Blending 설정 일부

```text
Forward Asset Setting
        │ Path 변경
        ▼
Forward+에서 동일 의미가 아닐 수 있음
```

Renderer Path를 바꾼 뒤 Lighting Quality와 Shader Variant를 다시 확인한다.

---

## Custom Shader Keyword

Custom URP Shader가 Forward+를 지원하려면 `_FORWARD_PLUS` Variant가 필요하다.

```hlsl
#pragma multi_compile _ _FORWARD_PLUS
```

일반 Forward Additional Light도 지원한다면 다음 Keyword를 함께 사용할 수 있다.

```hlsl
#pragma multi_compile _ _ADDITIONAL_LIGHTS
#pragma multi_compile _ _FORWARD_PLUS
```

Forward+에서는 `_ADDITIONAL_LIGHTS` 대신 `_FORWARD_PLUS` 경로가 사용된다.

Variant가 없으면 Lit Shader가 일부 Light를 처리하지 못할 수 있다.

---

## 필요한 Include

Unity 6 공식 Custom Shader 예제는 다음 Library를 사용한다.

```hlsl
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RealtimeLights.hlsl"
```

Package 내부 경로와 API는 URP Version에 따라 바뀔 수 있다.

설치된 Package의 공식 Shader Source와 Manual을 기준으로 작성한다.

---

## InputData가 필요한 이유

Forward+ Light Loop는 Fragment가 어느 Cluster에 속하는지 알아야 한다.

Screen Position과 World Position 같은 Data가 필요하다.

```hlsl
InputData inputData = (InputData)0;

inputData.positionWS = input.positionWS;
inputData.normalWS = input.normalWS;
inputData.viewDirectionWS =
    GetWorldSpaceNormalizeViewDir(input.positionWS);
inputData.normalizedScreenSpaceUV =
    GetNormalizedScreenSpaceUV(input.positionCS);
```

`LIGHT_LOOP_BEGIN` Macro가 찾는 Type과 Variable Name도 공식 Signature에 맞아야 한다.

---

## Screen UV의 역할

```text
positionCS
        │
        ▼
normalizedScreenSpaceUV
        │
        ▼
화면 Tile Index
        │ + Depth
        ▼
Cluster Light List
```

일반 Forward의 Object Light Index만 사용할 때는 Screen UV가 Light 선택의 핵심이 아니었다.

Forward+에서는 Pixel 위치로 Cluster를 찾기 때문에 올바른 Screen Coordinate가 필요하다.

XR, Dynamic Resolution과 Render Target Flip을 직접 계산하지 말고 URP Helper를 사용한다.

---

## LIGHT_LOOP_BEGIN

URP Macro를 사용하면 Forward와 Forward+에 맞는 Additional Light 반복을 구성할 수 있다.

```hlsl
uint pixelLightCount = GetAdditionalLightsCount();

LIGHT_LOOP_BEGIN(pixelLightCount)
    Light light = GetAdditionalLight(
        lightIndex,
        inputData.positionWS,
        half4(1, 1, 1, 1)
    );

    lighting += EvaluateLight(
        inputData.normalWS,
        light
    );
LIGHT_LOOP_END
```

Macro 내부가 Path에 맞는 Light Index를 제공한다.

---

## Non-main Directional Light Loop

Forward+에서는 Main이 아닌 Directional Light를 Clustered Local Light와 별도로 처리할 수 있다.

```hlsl
#if USE_FORWARD_PLUS
UNITY_LOOP for (
    uint lightIndex = 0u;
    lightIndex < min(
        URP_FP_DIRECTIONAL_LIGHTS_COUNT,
        MAX_VISIBLE_LIGHTS
    );
    ++lightIndex)
{
    Light light = GetAdditionalLight(
        lightIndex,
        inputData.positionWS,
        half4(1, 1, 1, 1)
    );

    lighting += EvaluateLight(
        inputData.normalWS,
        light
    );
}
#endif
```

Constant를 직접 숫자로 바꾸지 않고 URP가 제공하는 값을 사용한다.

---

## 두 Path를 지원하는 Shader 구조

```text
Custom UniversalForward Pass
├─ Main Light
├─ USE_FORWARD_PLUS일 때 Directional Loop
└─ LIGHT_LOOP_BEGIN
   ├─ Forward: Object Light List
   └─ Forward+: Cluster Light List
```

같은 Shader Pass가 일반 Forward와 Forward+에서 동작할 수 있다.

Keyword, `InputData`와 Macro Contract를 모두 지켜야 한다.

직접 `for` Loop로 Object Index만 순회하는 오래된 Shader는 Forward+에서 Light가 누락될 수 있다.

---

## Main Light까지 포함한 결과

```hlsl
half3 lighting = 0;

Light mainLight = GetMainLight();
lighting += EvaluateLight(
    inputData.normalWS,
    mainLight
);

// Forward+ Directional과 Cluster Additional Light Loop

return baseColor * lighting;
```

실제 Lit Shader는 Shadow, GI, Reflection, Cookie, Rendering Layer와 PBR BRDF를 더 처리한다.

예제의 목적은 Light List 접근 구조를 보여 주는 것이다.

---

## Rendering Layer 확인

Cluster List에 Light가 있다고 모든 Renderer가 그 Light를 받아야 하는 것은 아니다.

Rendering Layer Mask가 다르면 기여를 제외해야 한다.

```hlsl
if (IsMatchingLightLayer(
        light.layerMask,
        meshRenderingLayers))
{
    lighting += EvaluateLight(surface, light);
}
```

GameObject Layer, Camera Culling Mask와 Rendering Layer는 서로 다른 Filtering 목적을 가진다.

Custom Shader는 URP Lit Shader의 Layer 처리 방식을 참고한다.

---

## Shadow 비용

Forward+가 Light Culling을 개선해도 Shadow Map 생성 비용은 별도로 존재한다.

```text
Shadow Light
├─ Shadow Caster Culling
├─ Shadow Atlas Draw
├─ Point Light Face
└─ Fragment Shadow Sampling
```

많은 Light가 Shadow까지 Cast하면 Atlas와 Draw 비용이 빠르게 증가한다.

중요한 Light에만 Shadow를 사용하고 Range와 Resolution을 제한한다.

Cluster에서 Light를 제외할 수 있어도 Shadow Atlas가 이미 만들어졌다면 해당 준비 비용은 발생할 수 있다.

---

## Cookie 비용

Light Cookie는 Light Color에 Texture Pattern을 곱한다.

```text
Light
+ Cookie Texture Sample
        │
        ▼
Patterned Lighting
```

Forward+의 Light Loop에서 Cookie가 있는 Light마다 추가 Sampling이 발생할 수 있다.

Cookie Atlas Resolution, Format과 Cookie Light 수를 관리한다.

Light 수만 보고 Shader 비용을 추정하지 않는다.

---

## BRDF Complexity

Cluster에 Light가 10개면 Material BRDF도 Light마다 평가될 수 있다.

```text
Fragment Cost
≈ Material Setup
+ Cluster Lookup
+ Light Count × BRDF Cost
+ Shadow / Cookie Sampling
```

Clear Coat, Anisotropy 또는 Custom Stylized Function이 복잡하면 Light 수 증가의 기울기도 커진다.

Light와 무관한 계산은 Loop 밖으로 이동한다.

다음 장부터 Lighting 수식을 구성하는 요소를 더 자세히 다룬다.

---

## Shader Variant와 Build Time

Forward+는 `_FORWARD_PLUS`와 Light Limit 관련 Variant를 추가할 수 있다.

Camera Visible Light 최대값이 높으면 복잡한 Lighting Shader의 Compile Time에 영향을 줄 수 있다.

```text
Variant 증가 후보
├─ Forward / Forward+
├─ Shadow
├─ Cookie
├─ Reflection Probe
├─ Lightmap
└─ Material Feature
```

Unity 6 Known Issues는 일부 Forward+ 설정에서 Build Time이 길어질 수 있음을 안내한다.

사용하지 않는 Feature Strip과 Visible Light Configuration을 검토한다.

---

## Light 수가 적을 때

Scene에 Main Directional Light와 Point Light 두 개만 있다면 일반 Forward도 제한에 걸리지 않는다.

```text
일반 Forward
Object Light List 구성
→ 짧은 Loop

Forward+
Cluster Culling 구성
→ 짧은 Loop
```

Forward+의 추가 Culling 준비가 실질적인 이득을 만들지 못할 수 있다.

Light가 적은 Scene에서는 기본 Forward를 먼저 측정한다.

---

## Light가 많은 Indoor Scene

```text
Dungeon Corridor
├─ Torch 20개
├─ Magic Effect Light 10개
├─ Door Light 8개
└─ Character Light 4개
```

큰 Wall과 Floor에 많은 Light가 겹치지만 각 Light Range는 지역적일 수 있다.

Forward+는 Corridor 영역별 Cluster에 관련 Light만 넣는다.

일반 Forward의 Object Limit를 피하면서 G-buffer 없이 Lighting할 수 있다.

---

## Outdoor Scene

Sun Directional Light 하나와 드문 Local Light만 있는 넓은 야외 Scene에서는 Cluster Culling의 이점이 작을 수 있다.

```text
Outdoor
├─ Main Sun 1개
├─ Baked GI
└─ 일부 Local Light
```

일반 Forward의 단순한 Object List가 충분할 수 있다.

밤이 되어 수백 개 Street Light가 켜지는 Dynamic Scenario라면 Forward+의 가치가 달라진다.

평균뿐 아니라 최대 Light 상황을 Test한다.

---

## Particle과 VFX Scene

Magic Battle처럼 많은 Dynamic Light와 Transparent Particle이 동시에 나타날 수 있다.

```text
VFX
├─ Dynamic Point Lights
├─ Transparent Particles
├─ Distortion
└─ Bloom
```

Forward+는 Transparent도 많은 Light를 받을 수 있지만 Overdraw와 Light Loop가 곱해진다.

VFX Light의 Range와 Lifetime을 짧게 유지한다.

화면 기여가 작은 Light는 Shader Emission과 Bloom으로 대체할 수 있는지 검토한다.

---

## Light를 Emission으로 대체하기

작은 불꽃마다 Realtime Point Light를 만들 필요는 없다.

```text
Visual Glow
├─ Emissive Material
├─ Bloom
└─ Baked 또는 대표 Light 몇 개
```

Emission은 주변 Geometry를 실제로 밝히지 않는다.

중요한 Light만 Realtime으로 남기고 나머지는 Visual Effect로 표현하면 Cluster List와 Shadow 비용을 줄일 수 있다.

---

## Camera 수의 영향

Forward+ Light Culling Data는 Camera View에 따라 달라진다.

```text
Camera A
→ A의 Frustum과 Tile Light Lists

Camera B
→ B의 Frustum과 Tile Light Lists
```

Camera Stack, Reflection과 Render Texture Camera가 많으면 Culling 준비가 반복될 수 있다.

Light가 많은 Scene에서 Camera 수가 CPU와 GPU Cost를 증폭할 수 있다.

불필요한 Camera를 줄이고 Stack 중복을 확인한다.

---

## Resolution의 영향

Screen Tile 수는 Rendering Resolution과 연관된다.

```text
Resolution 증가
→ Tile 수 증가 가능
→ Fragment 수 증가
→ Light Loop 실행 Pixel 증가
```

Cluster Culling은 Pixel당 Light 후보를 줄이지만 Pixel 자체의 수를 줄이지 않는다.

4K에서 많은 Light와 복잡한 BRDF를 사용하면 Forward+도 매우 비쌀 수 있다.

Render Scale과 Dynamic Resolution을 함께 Test한다.

---

## MSAA와 Resolution

Forward+에서 4x MSAA를 사용하면 Edge Pixel에 여러 Sample이 존재한다.

```text
Forward+ GPU Cost 후보
├─ High Resolution
├─ Cluster Light Loop
├─ Transparent Overdraw
└─ MSAA Sample / Resolve
```

Forward+를 선택한 이유가 Deferred보다 낮은 Bandwidth와 MSAA라면 실제 Sample Count에서 측정한다.

Color·Depth Intermediate Texture와 Final Resolve도 Frame Debugger에서 확인한다.

---

## Light Culling이 CPU Bound일 때

많은 Camera와 Dynamic Light가 움직이면 매 Frame Light Bounds와 List를 갱신해야 한다.

```text
CPU 후보
├─ Visible Light 정리
├─ Light Constant 준비
├─ Cluster Range 계산
└─ Buffer Upload
```

GPU Fragment가 여유로워도 CPU 준비가 병목일 수 있다.

Main Thread와 Render Thread Marker를 확인한다.

Light를 Static으로 설정하는 것만으로 모든 Runtime Culling Cost가 사라진다고 가정하지 않는다.

---

## Light Loop가 GPU Bound일 때

```text
Cluster 평균 Light: 4개
→ 목표 Budget 안

Cluster 평균 Light: 24개
→ Fragment BRDF와 Shadow 반복 증가
```

Lighting Complexity View에서 Light 밀집 영역을 찾는다.

Light Range, Spot Angle, Shadow, Cookie와 Material Complexity를 줄인다.

GPU Capture로 Opaque와 Transparent Forward Pass의 Shader Duration을 확인한다.

---

## Forward+가 적합한 조건

- Scene에 Realtime Light가 많다.
- Light가 지역적으로 분산되어 있다.
- 큰 Mesh가 Object별 Limit에 걸린다.
- Light Pop을 제거해야 한다.
- Deferred의 G-buffer Bandwidth가 부담이다.
- MSAA가 필요하다.
- Transparent도 많은 Light를 받아야 한다.
- 두 개를 넘는 Reflection Probe Blending이 필요하다.
- Entities 또는 Procedural Draw를 활용한다.

```text
Many Local Lights
+ Forward Material
+ MSAA / Transparency
+ G-buffer 회피
        │
        ▼
Forward+ 후보
```

---

## 일반 Forward가 적합한 조건

- Main Light와 소수 Local Light만 사용한다.
- Object별 Limit가 Visual에 문제가 없다.
- 가장 단순한 Light 준비 비용이 중요하다.
- Per Vertex Additional Light를 활용한다.
- 매우 낮은 Hardware Tier를 우선한다.
- Shader와 Build Variant를 단순하게 유지한다.

Light 수가 적다면 Forward+의 Cluster 구성 비용을 추가할 이유가 작을 수 있다.

---

## Deferred가 적합한 조건

- Opaque Surface 비중이 매우 높다.
- 많은 Local Light를 화면 공간에서 처리한다.
- SSAO와 G-buffer Decal을 적극 활용한다.
- Material 대부분이 G-buffer에 호환된다.
- MRT와 Bandwidth가 충분하다.
- MSAA가 필요하지 않다.

Forward+와 Deferred는 모두 많은 Light 후보지만 Surface Data와 Memory 전략이 다르다.

동일 Scene에서 비교해야 한다.

---

## 세 Path 선택 표

| 질문 | Forward | Forward+ | Deferred |
| --- | --- | --- | --- |
| Light가 적은가? | 유리한 후보 | 추가 Culling 이점 작음 | G-buffer 고정 비용 |
| Object별 Light 제한 제거? | 불가 | 가능 | Opaque에서 가능 |
| G-buffer 회피? | 가능 | 가능 | 불가 |
| MSAA 필요? | 지원 | 지원 | 미지원 |
| 많은 Transparent Light? | 제한 있음 | 적합 후보 | Transparent는 Forward |
| Per Vertex Light? | 지원 | 미지원 | 미지원 |
| Material 유연성? | 높음 | 높음 | Layout 제약 |
| 많은 Opaque Light? | 제한·Loop 확인 | 적합 후보 | 적합 후보 |

표만으로 결론 내리지 않고 Target Device에서 측정한다.

---

## Lighting Complexity Debug

Rendering Debugger는 화면 Tile별 Light Complexity를 시각화할 수 있다.

```text
Tile 값 0
→ Local Light 없음

Tile 값 4
→ Light 4개 영향

Tile 값 20
→ 긴 Light Loop 후보
```

높은 값이 넓은 화면을 차지하면 Light Range와 배치를 수정한다.

Complexity 숫자는 Shadow, BRDF와 Transparent Overdraw의 차이까지 모두 나타내지는 않는다.

---

## Frame Debugger에서 확인할 항목

- Active Renderer가 Forward+인지
- Forward Opaque Pass
- Shader Keyword `_FORWARD_PLUS`
- Main과 Additional Shadow Pass
- Transparent Forward Pass
- MSAA Target과 Resolve
- Renderer Feature Pass
- Camera별 반복

```text
Draw 선택
→ Shader Keywords
→ Light Buffer
→ Pass Name
→ Render Target
```

G-buffer Pass가 핵심 Path로 나타나지 않는지 확인하면 Deferred와 구분할 수 있다.

---

## Rendering Debugger에서 확인할 항목

```text
Lighting Debug
├─ Light Complexity
├─ Light Layers
├─ Shadow Cascade
├─ Reflection Probe
└─ Material Validation
```

특정 Surface가 너무 많은 Light를 받는지 화면 공간으로 확인한다.

Light Pop이 사라졌지만 Complexity가 과도하게 높아졌다면 Quality와 Performance Trade-off를 다시 조정한다.

---

## Profiler에서 확인할 항목

```text
CPU
├─ Culling
├─ Light Data 준비
├─ Camera별 Cluster 준비
├─ Draw Scheduling
└─ Render Thread

GPU
├─ Shadow
├─ Opaque Forward+
├─ Transparent Forward+
├─ MSAA Resolve
└─ Post-processing
```

일반 Forward와 Forward+를 동일 Light 수에서 비교한다.

Light 수를 단계적으로 늘려 Cost Curve를 기록한다.

---

## Light 수 단계 Test

```text
Test 1: 1 Local Light
Test 2: 8 Local Lights
Test 3: 16 Local Lights
Test 4: 32 Local Lights
Test 5: 64 Local Lights
```

일반 Forward에서는 Object Limit와 Light Pop을 기록한다.

Forward+에서는 Cluster Culling CPU Time과 Opaque GPU Time을 기록한다.

Deferred에서는 G-buffer 고정 비용과 Light Pass 증가를 기록한다.

같은 Visual 결과를 만들 수 있는 범위에서 비교한다.

---

## Light Range 단계 Test

Light 수가 같아도 Range에 따라 Forward+ 성능이 크게 달라질 수 있다.

```text
64 Small Lights
→ Cluster 평균 3개

64 Large Lights
→ Cluster 평균 30개
```

Light Count만 Benchmark 표에 적으면 중요한 조건을 놓친다.

평균 Cluster Light 수와 Screen Coverage를 함께 기록한다.

---

## Custom Shader가 Light 하나만 보일 때

Forward+로 변경한 뒤 Main Light만 보인다면 다음 항목을 확인한다.

1. `_FORWARD_PLUS` Multi Compile이 있는가?
2. `RealtimeLights.hlsl`을 Include했는가?
3. `InputData inputData` 이름과 Type이 맞는가?
4. `normalizedScreenSpaceUV`를 채웠는가?
5. `LIGHT_LOOP_BEGIN`을 사용하는가?
6. Non-main Directional Loop가 필요한가?
7. Light의 Rendering Layer가 맞는가?

```text
Forward에서 동작
≠ Forward+에서 자동 동작
```

오래된 Object Light Index Loop를 URP Macro 구조로 Migration한다.

---

## GetAdditionalLightsCount가 0처럼 보일 때

Forward+에서는 `GetAdditionalLightsCount()`의 값만 일반 Forward 방식으로 해석하면 안 된다.

Cluster Light 반복은 `LIGHT_LOOP_BEGIN` Macro가 내부 Context를 사용한다.

```hlsl
uint pixelLightCount = GetAdditionalLightsCount();

LIGHT_LOOP_BEGIN(pixelLightCount)
    // Forward와 Forward+에 맞는 lightIndex
LIGHT_LOOP_END
```

직접 `for (i < pixelLightCount)`만 작성하면 Forward+의 Cluster Light를 올바르게 순회하지 못할 수 있다.

---

## Screen UV가 잘못되었을 때

Cluster 조회에 사용하는 Screen UV가 틀리면 다른 Tile의 Light를 읽거나 Light가 누락될 수 있다.

```text
잘못된 positionCS 정규화
→ Wrong Tile Index
→ Wrong Light List
→ 화면 영역별 Lighting 오류
```

`GetNormalizedScreenSpaceUV()` 같은 URP Helper를 사용한다.

Dynamic Resolution, XR, Render Texture와 Y Flip 조건에서 직접 계산을 피한다.

---

## Light가 너무 많이 계산될 때

Forward+에서 GPU Time이 높으면 다음을 확인한다.

- Light Range가 과도하게 큰가?
- Spot Angle이 너무 넓은가?
- Directional Light가 여러 개인가?
- Transparent Overdraw가 높은가?
- Shadow Light가 많은가?
- Cookie와 Complex BRDF가 반복되는가?
- Camera가 같은 Scene을 여러 번 그리는가?
- Render Scale과 MSAA가 높은가?

```text
Cluster Culling은 후보를 줄인다.
후보가 모두 실제로 넓게 겹치면 줄일 수 없다.
```

---

## Reflection Probe 결과가 달라질 때

Forward+는 Reflection Probe Blending 설정을 일반 Forward와 다르게 처리한다.

Probe가 많이 겹치는 영역에서 Visual이 달라질 수 있다.

```text
확인 목록
├─ Probe Volume
├─ Importance
├─ Box Projection
├─ Blending
├─ Sky Fallback
└─ Custom Shader Probe Loop
```

Path 전환 후 Metallic Surface와 Probe 경계를 다시 검수한다.

---

## Build Time이 길어질 때

Forward+의 최대 Visible Light와 여러 Feature 조합은 Shader Compile 범위를 키울 수 있다.

```text
Build Time 후보
├─ `_FORWARD_PLUS` Variant
├─ Shadow Variant
├─ Light Cookie
├─ Reflection Probe
├─ Material Feature
└─ Platform Variant
```

URP Config Package를 통한 Light Limit 조정은 Build와 Runtime 요구를 정확히 이해한 뒤 적용한다.

사용하지 않는 Feature의 Variant Stripping 설정을 확인한다.

---

## Forward+ 최적화 기준

```text
1. Camera Visible Light 수
2. Cluster 평균 Light 수
3. Light Screen Coverage
4. Shadow Light 수
5. Transparent Overdraw
6. Material BRDF Cost
7. Resolution과 MSAA
8. Camera 수
```

단순 Light Count보다 Light가 겹치는 공간 분포가 중요하다.

Lighting Complexity와 GPU Timing을 함께 기록한다.

---

## Light 배치 최적화

- 실제 영향 범위에 맞게 Range를 줄인다.
- Spot Angle을 필요한 크기로 제한한다.
- 같은 목적의 겹치는 Light를 합친다.
- Importance가 낮은 Light를 Bake 또는 Emission으로 대체한다.
- Camera 밖에서 불필요하게 활성인 Light를 관리한다.
- Shadow는 핵심 Light에만 사용한다.
- VFX Light Lifetime을 짧게 유지한다.

```text
작은 Light Volume
→ 적은 Cluster Overlap
→ 짧은 Pixel Light Loop
```

---

## Shader 최적화

- Light와 무관한 계산을 Loop 밖으로 이동한다.
- 불필요한 Texture Sampling을 줄인다.
- Shadow와 Cookie Branch를 필요한 Variant에서만 사용한다.
- Mobile에서 `half` Precision을 검증한다.
- Rendering Layer Filter를 올바르게 적용한다.
- URP Macro를 사용해 Path별 Indexing을 맡긴다.
- Main 외 Directional Loop 중복을 피한다.

```text
Loop Cost 절감
× Cluster Light 수
× Screen Pixel 수
→ 큰 GPU 차이 가능
```

---

## Camera 최적화

- 불필요한 Base와 Overlay Camera를 제거한다.
- Reflection Probe Realtime Update를 제한한다.
- Render Texture Camera Resolution을 낮춘다.
- Camera Stack 중복을 확인한다.
- Culling Mask로 필요 없는 Layer를 제외한다.
- Far Clip을 실제 Scene 범위에 맞춘다.

Forward+는 Camera별 Cluster를 구성하므로 Camera 수가 Light Culling 비용에 직접 영향을 줄 수 있다.

---

## 자주 혼동하는 내용

### Forward+는 Deferred Rendering인가?

아니다.

Light Culling은 화면 공간에서 수행하지만 Material Lighting은 Geometry의 Forward Shader에서 계산한다.

### Forward+는 G-buffer를 사용하는가?

핵심 Forward+ Lighting에 G-buffer가 필수는 아니다.

Depth, Normal과 Renderer Feature용 Texture는 조건에 따라 별도로 생길 수 있다.

### Forward+에서는 Light가 무한한가?

아니다.

Object별 제한은 없지만 Camera, Platform, Buffer와 성능 제한은 존재한다.

### Forward+는 일반 Forward보다 항상 빠른가?

아니다.

Light가 적으면 Cluster Culling의 추가 준비 비용이 이득보다 클 수 있다.

### Per Object Limit을 낮추면 Forward+가 빨라지는가?

아니다.

Forward+는 이 설정을 무시한다.

### Forward+는 Additional Light를 Per Vertex로 계산할 수 있는가?

아니다.

Forward+는 Light를 Per Pixel로 처리한다.

### Forward+는 Transparent에도 적용되는가?

그렇다.

Transparent도 Cluster Light List를 사용해 Forward Lighting할 수 있지만 Blend와 Overdraw 비용은 남는다.

### Forward Shader는 Forward+에서도 자동으로 동작하는가?

모든 Custom Shader가 자동으로 호환되는 것은 아니다.

`_FORWARD_PLUS`, `InputData`와 Light Loop Macro를 올바르게 구현해야 한다.

### Forward+를 사용하면 큰 Mesh를 항상 합치는 것이 좋은가?

아니다.

Light Limit 때문에 나눌 필요는 줄지만 Culling, LOD, Occlusion과 Draw Granularity는 여전히 고려해야 한다.

### Light Culling이 Shadow 비용도 제거하는가?

아니다.

Shadow Map 생성과 Atlas 비용은 별도이며 Fragment Shadow Sampling만 관련 Pixel에서 수행된다.

---

## 전체 구조 다시 연결하기

```text
일반 Forward의 문제
├─ Object별 Light List
├─ 최대 Additional Light 제한
├─ 큰 Mesh에서 Light 누락
└─ List 교체에 따른 Pop
        │
        ▼
모든 Camera Light를 순회하면 너무 비쌈
        │
        ▼
화면 공간 Light Culling 추가
        │
        ▼
Forward+
├─ Screen Tile 분할
├─ Depth Bin / Cluster 분할
├─ Light Bounds와 Cluster 교차
├─ Cluster별 Light Index List
└─ Fragment의 Cluster Light Loop
        │
        ▼
Forward Shading 유지
├─ 정확한 Per-pixel Normal
├─ G-buffer 필수 아님
├─ MSAA 지원
├─ Material 유연성
└─ Transparent Lighting
```

```text
Forward+의 새로운 비용
├─ Camera별 Cluster 구성
├─ Light Index Buffer
├─ Cluster Lookup
├─ 실제 겹치는 Light의 BRDF 반복
└─ Shader Variant와 Build 범위
```

---

## 정리

Forward+는 일반 Forward의 Object별 Light 제한을 제거하면서 Forward Material과 Lighting Workflow를 유지하기 위해 등장한 Rendering Path다.

```text
Forward
Object별 제한된 Light List

Forward+
Screen Tile + Depth Cluster별 Light List
```

Camera 화면을 Tile과 Depth 구간으로 나누고 Light Bounds가 겹치는 Cluster에 Light Index를 기록한다.

Fragment Shader는 Screen Position과 Depth로 현재 Cluster를 찾고 해당 List의 Light만 순회해 모든 Camera Light를 검사하는 낭비를 줄인다.

Object별 Realtime Light 제한은 없지만 Camera당 Visible Light, Platform, Buffer와 실제 Frame Time의 제한은 남는다.

Forward+는 G-buffer를 만드는 Deferred와 달리 Geometry Draw 안에서 Material BRDF와 Lighting을 계산하므로 정확한 Per-pixel Normal, MSAA, Flexible Material과 Transparent Lighting을 유지한다.

Main과 Additional Light는 Per Pixel로 처리되며 일반 Forward의 Additional Light Mode와 `Per Object Limit` 설정은 Forward+에서 무시된다.

Custom Shader는 `_FORWARD_PLUS` Variant, Screen UV를 포함한 `InputData`, Non-main Directional Loop와 `LIGHT_LOOP_BEGIN` Macro를 올바르게 사용해야 한다.

Light가 적으면 Cluster 구성 비용 때문에 일반 Forward가 더 단순할 수 있고 Light가 넓은 화면에 모두 겹치면 Forward+의 Culling 이점도 줄어든다.

많고 작은 Local Light, 큰 Mesh, MSAA, Transparent, Reflection Probe와 Forward Material 유연성이 함께 필요한 Scene에서 Forward+를 검토하고 Lighting Complexity, CPU·GPU Profiler와 Target Device Build로 측정해야 한다.
