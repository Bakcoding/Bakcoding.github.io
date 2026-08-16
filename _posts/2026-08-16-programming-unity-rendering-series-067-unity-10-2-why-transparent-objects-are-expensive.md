---
title: "[Unity 렌더링] 10-2. Transparent 오브젝트는 왜 비쌀까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - Transparency
  - Overdraw
  - Optimization
permalink: /programming/unity-10-2-why-transparent-objects-are-expensive/
toc: true
toc_sticky: true
date: 2026-08-16
last_modified_at: 2026-08-16
---

Transparent Object는 뒤에 있는 Color와 현재 Fragment의 Color를 섞어야 하므로 겹친 Layer를 각각 처리한다.

```text
Camera
  │
  ├─ Smoke A
  ├─ Glass B
  ├─ Smoke C
  └─ Opaque Background
```

최종 화면에는 하나의 Pixel Color만 보이지만 A, B, C와 Background의 Fragment Shader와 Blend가 모두 실행될 수 있다.

Depth Write를 끄는 경우가 많아 Transparent끼리 Early-Z로 제거하기 어렵고 Back-to-Front Sorting 비용과 순서 Artifact도 생긴다.

---

## Opaque와 Transparent의 근본적인 차이

Opaque Surface는 가장 가까운 Surface의 Color만 최종 화면에 필요하다.

```text
Camera
  │
  ├─ Near Opaque  ← 최종 Color
  ├─ Mid Opaque   ← 가려짐
  └─ Far Opaque   ← 가려짐
```

Transparent Surface는 뒤 Color도 최종 결과에 기여할 수 있다.

```text
Camera
  │
  ├─ Near Transparent 20%
  ├─ Mid Transparent 50%
  └─ Far Background 100%

→ 세 Layer의 Color를 조합
```

가려진 Surface를 단순히 버릴 수 없다는 점이 비용과 정렬 문제의 출발점이다.

---

## URP의 Rendering 순서

URP Lit Material의 `Surface Type`은 Opaque와 Transparent로 나뉜다.

```text
URP Rendering
1. Opaque Surface
2. Skybox와 중간 단계
3. Transparent Surface 별도 Pass
```

Unity 공식 URP Lit 문서는 Opaque를 먼저 Rendering하고 Transparent를 Background와 Blend하기 위한 별도 Pass에서 나중에 Rendering한다고 설명한다.

Opaque Depth Buffer가 먼저 완성되어 있으면 그 뒤의 Transparent Fragment는 Depth Test로 제거할 수 있다.

그러나 Opaque 앞에 겹친 Transparent Layer는 각각 처리해야 한다.

---

## Alpha Blending

일반적인 Alpha Blend는 Source Color와 이미 Render Target에 저장된 Destination Color를 섞는다.

```hlsl
finalColor =
    sourceColor * sourceAlpha
  + destinationColor * (1.0 - sourceAlpha);
```

ShaderLab State로는 다음과 같은 형태다.

```shaderlab
Blend SrcAlpha OneMinusSrcAlpha
```

```text
Source
└─ 현재 Transparent Fragment

Destination
└─ 이미 그려진 Background Color
```

Blend는 현재 Fragment 출력만 계산하는 것이 아니라 기존 Color를 읽고 조합해야 한다.

---

## Read-modify-write 비용

Blend가 활성화되면 Render Target의 기존 값을 읽고 새로운 값을 계산해 다시 쓴다.

```text
Transparent Fragment
├─ Texture Read
├─ Fragment Shader 계산
├─ Destination Color Read
├─ Blend Operation
└─ Final Color Write
```

이 과정은 Shader ALU뿐 아니라 Render Target Memory Bandwidth를 사용한다.

HDR Render Target은 Pixel당 Data가 크고 MSAA까지 사용하면 Color Sample과 Resolve 부담이 커질 수 있다.

Transparent Layer가 겹칠수록 Read-modify-write가 반복된다.

---

## Blend를 켜면 GPU 최적화가 제한된다

Unity 공식 ShaderLab 문서는 Blending 활성화가 주로 Hidden Surface Removal과 Early-Z 같은 GPU 최적화를 비활성화하거나 제한해 GPU Frame Time을 늘릴 수 있다고 설명한다.

```text
Opaque
가까운 Depth 기록
→ 뒤 Fragment를 빠르게 제거 가능

Transparent
뒤 Color가 Blend에 필요
→ Layer를 단순 제거하기 어려움
```

정확한 동작은 GPU Architecture, Shader와 Blend State에 따라 다르다.

중요한 것은 Transparent가 Opaque와 같은 Depth 최적화 이점을 기대하기 어렵다는 점이다.

---

## ZTest와 ZWrite는 다르다

`ZTest`는 현재 Fragment가 저장된 Depth와 비교할지 결정한다.

`ZWrite`는 통과한 Fragment의 Depth를 Buffer에 기록할지 결정한다.

```text
ZTest
→ 앞뒤 판정

ZWrite
→ 현재 Depth를 다음 Fragment를 위해 저장
```

Transparent Material도 일반적으로 Opaque Depth에 대해 `ZTest`를 수행한다.

하지만 반투명 Layer끼리 올바르게 Blend하기 위해 `ZWrite Off`를 사용하는 경우가 많다.

---

## ZWrite를 끄는 이유

가까운 Transparent Surface가 Depth를 기록하면 뒤 Transparent Surface가 제거될 수 있다.

```text
Near Glass
├─ ZWrite On → Depth 5 기록
└─ Alpha 0.2

Far Smoke
├─ Depth 10
└─ ZTest Fail → 그려지지 않음
```

Near Glass는 20%만 보이므로 뒤 Smoke도 보여야 한다.

Depth를 기록하면 올바른 Blend 결과를 잃는다.

따라서 일반적인 Semi-transparent Material은 `ZWrite Off`를 사용하고 CPU Sorting으로 순서를 맞춘다.

---

## ZWrite Off의 비용

앞 Transparent Layer가 Depth를 기록하지 않으면 뒤 Layer를 가리지 않는다.

```text
Transparent Layers
├─ Layer A: ZTest Pass, Shader, Blend
├─ Layer B: ZTest Pass, Shader, Blend
├─ Layer C: ZTest Pass, Shader, Blend
└─ Layer D: ZTest Pass, Shader, Blend
```

같은 Pixel에 네 Layer가 겹치면 네 번의 Fragment 계산과 Blend가 발생할 수 있다.

이것이 Transparent Overdraw가 Opaque Overdraw보다 쉽게 비싸지는 이유다.

---

## Back-to-Front Sorting

Alpha Blend는 일반적으로 Camera에서 먼 Object부터 그려야 한다.

```text
Camera
  │
  ├─ A Near
  ├─ B Mid
  └─ C Far

Draw Order
C → B → A
```

먼 Color를 먼저 저장하고 가까운 Transparent Color를 그 위에 Blend한다.

Unity는 Render Queue와 Camera 거리 기준으로 Transparent Renderer를 정렬한다.

CPU는 매 Frame Object 위치와 Camera에 따라 정렬 순서를 준비해야 한다.

---

## Sorting 자체의 CPU 비용

Visible Transparent Renderer가 많으면 Sorting 대상이 늘어난다.

```text
Transparent Rendering CPU
├─ Visibility 판정
├─ Distance Key 계산
├─ Render Queue와 Priority
├─ Back-to-Front Sorting
├─ Material State 고려
└─ Draw Command 생성
```

Opaque는 State와 Front-to-Back 최적화를 더 자유롭게 조합할 수 있다.

Transparent는 Blend 정확도를 위해 순서 제약이 커 Material 기준 Batch 기회도 제한될 수 있다.

---

## Object 단위 Sorting의 한계

일반적인 Transparent Sorting은 Renderer 또는 Bounds 중심의 거리로 순서를 정한다.

하나의 Mesh 안의 Triangle을 모두 Camera 거리 순으로 다시 정렬하지는 않는다.

```text
Transparent Mesh A와 B가 교차

A 앞부분 > B
B 앞부분 > A
```

Object 전체에 하나의 순서를 정할 수 없어 일부 Pixel의 Blend 순서가 틀릴 수 있다.

Intersecting Glass, Hair Card와 큰 Water Plane에서 Sorting Artifact가 보이는 이유다.

---

## 한 Mesh 내부의 Triangle 순서

```text
Transparent Sphere Mesh
├─ Back Face Triangle
└─ Front Face Triangle
```

Mesh Index 순서에 따라 Front Face가 먼저 그려지고 Back Face가 나중에 Blend되면 결과가 잘못될 수 있다.

Camera가 회전하면 올바른 Triangle 순서도 바뀐다.

```text
가능한 대응
├─ Back Face와 Front Face Pass 분리
├─ Mesh 분할
├─ Depth Prepass
├─ Weighted Blended OIT
└─ 표현 단순화
```

대응마다 Draw, Memory와 Shader 비용이 추가된다.

---

## Sorting Priority와 Render Queue

URP Lit Material은 `Sorting Priority`로 Transparent Material의 Rendering 순서를 조정할 수 있다.

Unity는 값이 낮은 Material을 먼저 Rendering한다.

```text
Sorting Priority -1 → 먼저
Sorting Priority  0
Sorting Priority +1 → 나중
```

Built-in Pipeline의 Render Queue Override와 비슷한 역할을 한다.

특정 Effect의 순서 문제를 해결할 수 있지만 모든 Camera 각도와 Mesh 교차 문제를 해결하지는 않는다.

Priority가 많아지면 State 정렬과 Batch도 더 나뉠 수 있다.

---

## Render Queue

Unity의 대표적인 Render Queue는 다음 순서다.

| Queue | 기본 Index | 용도 |
| --- | ---: | --- |
| Geometry | 2000 | Opaque Geometry |
| AlphaTest | 2450 | Alpha Clipping Geometry |
| Transparent | 3000 | Alpha Blended Surface |

Skybox는 일반적으로 Opaque 뒤, Transparent 앞에 그려진다.

Queue를 임의로 바꾸면 Depth, Sorting과 Pipeline Feature 동작이 달라질 수 있다.

단순히 `먼저 그리면 빠르다`는 이유로 Transparent를 Opaque Queue에 넣으면 Blend 결과가 깨질 수 있다.

---

## URP의 Blending Mode

URP Lit Transparent Material은 여러 Blend Mode를 제공한다.

```text
Alpha
├─ Alpha 값으로 Source와 Background 혼합
└─ 일반 반투명

Premultiply
├─ RGB를 Alpha와 미리 곱한 형태
└─ Edge Halo와 Lighting 표현에 유리할 수 있음

Additive
├─ Source Color를 Background에 더함
└─ Fire, Spark, Glow

Multiply
├─ Background Color와 곱함
└─ Darkening Effect
```

Mode마다 시각적 결과와 Blend Factor가 다르지만 모두 Fragment와 Render Target Blend 비용을 가진다.

---

## Alpha와 Premultiply

Straight Alpha는 Shader 출력 RGB와 Alpha를 Blend Factor에서 조합한다.

```text
Straight Alpha
Final = Src.rgb × Src.a + Dst.rgb × (1 - Src.a)
```

Premultiplied Alpha는 Texture 또는 Shader RGB가 이미 Alpha와 곱해진 형태를 사용한다.

```text
Premultiply
Final = Src.rgb + Dst.rgb × (1 - Src.a)
```

Premultiply는 Filtering Edge와 Specular 보존에 유리할 수 있지만 Texture 제작과 Shader 출력이 같은 Convention을 따라야 한다.

Overdraw Layer 수를 자동으로 줄이는 방식은 아니다.

---

## Additive Blend

```shaderlab
Blend One One
```

Additive는 Color를 더하므로 일부 상황에서 Layer 순서에 덜 민감하다.

```text
A + B + C
= C + B + A
```

그러나 Saturation, Tone Mapping, Alpha Channel과 다른 Blend State가 섞이면 결과가 단순하지 않을 수 있다.

모든 Layer의 Fragment Shader와 Blend는 여전히 실행된다.

Sorting 비용을 줄일 가능성과 Pixel Overdraw 비용을 구분한다.

---

## Multiply Blend

Multiply는 Background와 Source Color를 곱해 어둡게 만드는 데 사용한다.

```text
Final ≈ Source × Destination
```

Destination Color가 필요해 Read-modify-write가 발생한다.

Decal Shadow, UI Tint와 Stylized Effect에 사용할 수 있지만 Layer가 겹칠수록 Color가 빠르게 어두워지고 Overdraw도 누적된다.

실제 Lighting Shadow를 단순 Multiply Quad로 대체할 때 Screen Coverage를 확인한다.

---

## Preserve Specular Lighting

URP Lit의 Transparent Alpha·Additive Mode는 `Preserve Specular Lighting`을 사용할 수 있다.

Diffuse Transparency와 별개로 Specular Highlight를 유지해 Glass처럼 보이게 한다.

```text
Transparent Surface
├─ Diffuse / Base Color는 Alpha 영향
└─ Specular Highlight는 보존 가능
```

시각적 품질은 좋아지지만 Lighting 계산 자체가 줄어드는 기능은 아니다.

단순 Transparent Unlit보다 Lit Transparent가 비싼 이유 중 하나다.

---

## Transparent Lighting

Lit Transparent Fragment는 Blend 전에 Lighting을 계산한다.

```text
Transparent Fragment
├─ Base Map Sample
├─ Normal Map Sample
├─ Main Light
├─ Additional Lights
├─ Shadow Sample
├─ Reflection Probe
├─ Specular
└─ Blend
```

Layer가 다섯 번 겹치면 비싼 Lighting 계산도 다섯 Layer에서 반복될 수 있다.

Overdraw가 높은 Material일수록 Fragment Shader를 단순하게 유지해야 한다.

Glow Particle에 PBR Lit Shader가 꼭 필요한지 확인한다.

---

## Additional Light와 Transparent

Forward Rendering에서 Transparent Object는 Fragment마다 영향을 주는 Light를 평가할 수 있다.

```text
Pixel Cost
≈ Transparent Layer
× 영향 Light 수
× Light당 계산
```

Transparent Layer가 많은 Effect에 Additional Light가 여러 개 겹치면 비용이 곱해질 수 있다.

Per-vertex Lighting, Unlit Shader, Light Layer와 Light Range를 검토한다.

화면 품질과 Target Pipeline의 Lighting Path를 확인한다.

---

## Shadow를 받는 비용

URP Lit Transparent Material은 설정에 따라 Shadow를 받을 수 있다.

```text
Transparent Receiver
├─ Shadow Coordinate 계산
├─ Shadow Map Sample
├─ Soft Shadow PCF
└─ Lighting에 적용
```

Layer가 겹치면 Shadow Sample도 반복될 수 있다.

Smoke와 Glow처럼 Shadow가 시각적으로 중요하지 않은 Material은 `Receive Shadows`를 끄는 선택을 검토한다.

Material Keyword와 Batching 결과도 함께 확인한다.

---

## Shadow를 만드는 비용

Transparent Color 표현과 ShadowCaster Pass의 형태는 별도로 설계된다.

완전한 Semi-transparent Shadow를 Shadow Map Depth 하나로 표현하기 어렵기 때문에 Shader와 Pipeline은 Alpha Clip 또는 Opaque에 가까운 Shadow를 사용할 수 있다.

```text
Transparent Glass
├─ Color Pass: Alpha Blend
└─ Shadow Pass: Off 또는 별도 Approximation
```

Transparent Object가 Shadow를 만들 필요가 있는지 먼저 판단한다.

Foliage는 Alpha Clip Shadow가 필요할 수 있지만 Glass는 Baked·Cookie·단순 Shadow로 대체할 수 있다.

---

## Refraction과 Scene Color

Glass, Heat Haze와 Water는 뒤의 Scene Color를 Sample해 굴절을 표현할 수 있다.

```text
Opaque Scene Rendering
        │
        ▼ Copy / Opaque Texture
Transparent Shader
├─ Screen UV 계산
├─ Scene Color Sample
├─ Distortion Offset
└─ Blend
```

URP의 Opaque Texture를 만들기 위한 Copy Pass와 추가 Texture Memory가 필요할 수 있다.

여러 굴절 Layer가 서로를 올바르게 굴절하지 못하는 제한도 있다.

단순 Alpha Transparent보다 Texture Sample과 Bandwidth가 증가한다.

---

## Soft Particle

Soft Particle은 Particle Depth와 Opaque Scene Depth를 비교해 교차 경계를 Fade한다.

```text
Particle Fragment
├─ Particle Texture Sample
├─ Scene Depth Sample
├─ Depth Difference
├─ Fade 계산
└─ Blend
```

URP Asset에서 Depth Texture가 필요하며 Depth 생성 Pass나 Texture Memory 비용이 생길 수 있다.

교차 Artifact는 줄지만 모든 Particle Fragment에 추가 Sample과 계산이 들어간다.

Particle의 상세 최적화는 이후 글에서 다룬다.

---

## Distortion

Transparent Particle Distortion은 Background를 추가로 읽고 UV를 변형한다.

```text
Distortion Fragment
├─ Normal / Distortion Map
├─ Scene Color
├─ Scene Depth 가능성
├─ Offset 계산
└─ Blend
```

한 Effect가 Color Pass와 Distortion Pass를 따로 사용하면 Draw와 Pixel 작업이 반복될 수 있다.

화면 전체를 덮는 Heat Haze는 적은 Particle 수여도 비쌀 수 있다.

---

## Alpha가 0이면 무료일까?

Shader가 최종적으로 Alpha `0`을 출력하려면 그 값을 계산해야 한다.

```text
Invisible Transparent Fragment
├─ Vertex와 Rasterization
├─ Texture Sample
├─ Lighting
├─ Alpha 계산
└─ Blend 결과는 변화 없음
```

최종 Color가 바뀌지 않는다고 GPU 작업도 없는 것은 아니다.

완전히 Fade Out된 Renderer, Particle와 UI Element는 Rendering 자체를 중단할 수 있는지 확인한다.

---

## 큰 Quad의 투명한 여백

Texture Image는 작지만 Mesh Quad가 크면 Alpha 0 영역도 Rasterization된다.

```text
Quad Bounds
┌─────────────────────┐
│ Transparent Padding │
│       Smoke         │
│ Transparent Padding │
└─────────────────────┘
```

Texture Alpha를 읽은 뒤 0이라는 사실을 알게 되므로 Pixel 비용이 생긴다.

Particle Texture와 Sprite Mesh의 Padding을 줄이고 Tight Geometry를 검토한다.

Vertex 증가와 Fragment 감소의 균형을 측정한다.

---

## Double-sided Transparent

Glass와 Cloth에서 양면 Rendering을 사용하면 Front Face와 Back Face가 모두 Rasterization된다.

```text
Closed Transparent Mesh
├─ Front Face Layer
└─ Back Face Layer
```

같은 Object 하나만으로도 Screen Pixel당 두 Layer 이상의 Overdraw를 만들 수 있다.

Cull Off가 실제로 필요한지 확인한다.

한쪽 면만 보이는 Plane과 Effect는 Cull Back 또는 적절한 Cull Mode를 사용한다.

---

## 복잡한 Transparent Mesh

둥근 Glass Mesh와 Hair Card가 자체적으로 많은 Triangle Layer를 겹칠 수 있다.

```text
Hair
├─ Card A
├─ Card B
├─ Card C
└─ Card D
```

Card 수는 Silhouette 품질을 높이지만 내부 Layer의 Overdraw와 Sorting Artifact를 증가시킨다.

LOD에서 Card 수, Texture Resolution과 Shader 품질을 함께 낮춘다.

---

## Transparent가 Batching에 불리한 이유

Opaque는 같은 Material을 연속으로 그리도록 정렬하기 쉽다.

Transparent는 Camera 거리 순서를 우선해야 한다.

```text
원하는 Blend Order
Material A Far
Material B Mid
Material A Near

Draw Order
A → B → A
```

Material A를 한 번에 묶으면 Blend 순서가 달라진다.

따라서 SetPass와 Draw Call 최적화 기회가 줄 수 있다.

---

## Transparent가 Dynamic하게 바뀌는 경우

Camera와 Object가 움직이면 거리 순서가 Frame마다 변한다.

```text
Frame N
A → B → C

Frame N + 1
B → A → C
```

CPU Sorting과 Draw Command 순서도 갱신된다.

많은 작은 Transparent Renderer는 Fragment Overdraw뿐 아니라 CPU Sorting과 Draw Call 병목도 만들 수 있다.

가능하면 같은 Effect를 Particle System이나 적절한 Batch 구조로 관리한다.

---

## Opaque로 바꿀 수 있는가?

실제로 투명하지 않은 Material이 습관적으로 Transparent로 설정된 경우가 있다.

```text
잘못된 설정
Alpha = 1.0
Surface Type = Transparent

가능한 변경
Surface Type = Opaque
```

시각적으로 완전히 불투명하다면 Opaque Queue, ZWrite와 Early-Z 이점을 사용할 수 있다.

Alpha Channel을 Texture의 다른 Data로 사용한다는 이유만으로 Surface Type을 Transparent로 둘 필요는 없다.

---

## Alpha Clipping으로 바꿀 수 있는가?

Fence, Leaf와 Grass처럼 Pixel이 완전히 보이거나 완전히 사라지는 표현은 Alpha Clip이 적합할 수 있다.

```text
Alpha Blend
0.0 ~ 1.0 연속 투명도

Alpha Clip
alpha < threshold → discard
alpha ≥ threshold → Opaque Depth Write
```

통과 Pixel이 Depth를 기록해 뒤 Layer를 제거할 수 있다.

그러나 Alpha Texture Sample, `clip`, Jagged Edge와 Early-Z 제한이 생긴다.

부드러운 Smoke와 Glass는 동일한 표현으로 대체할 수 없다.

---

## Dithered Transparency

Dither Pattern으로 Pixel 일부를 버리고 시간·공간적으로 투명도를 근사할 수 있다.

```text
50% Dither
█ □ █ □
□ █ □ █
█ □ █ □
□ █ □ █
```

통과 Pixel을 Opaque처럼 Depth Write할 수 있어 Layer Overdraw를 줄일 가능성이 있다.

TAA가 Pattern을 시간적으로 섞어 부드럽게 보이게 할 수 있다.

Noise, Ghosting, TAA 의존성과 Screen-door Artifact를 고려한다.

---

## Transparent Depth Prepass

일부 Transparent Material은 먼저 Depth를 기록하고 Color Pass에서 Blend할 수 있다.

```text
Transparent Depth Prepass
└─ 가까운 Surface Depth 기록

Transparent Color Pass
└─ Depth와 일치하는 Surface Blend
```

Self-overdraw와 일부 Sorting 문제를 줄일 수 있다.

그러나 뒤 Transparent Layer가 보여야 하는 실제 반투명 표현을 잘못 제거할 수 있고 Pass·Vertex·Depth 비용이 추가된다.

Hair와 Glass의 요구사항에 맞게 제한적으로 사용한다.

---

## OIT

Order-independent Transparency는 단순 Back-to-Front Sorting 없이 여러 Transparent Layer를 조합하는 기법의 범주다.

```text
OIT 예시 방향
├─ Weighted Blended
├─ Per-pixel Linked List
├─ Depth Peeling
└─ Moment 기반 방식
```

Sorting Artifact를 줄일 수 있지만 추가 Render Target, Memory, Atomic Operation, Pass와 근사 오차가 생긴다.

Unity URP의 기본 Transparent Material을 켜는 것만으로 자동 적용되는 기능은 아니다.

필요한 품질과 Platform 지원을 기준으로 Custom Renderer Feature를 설계해야 한다.

---

## Screen Coverage를 줄인다

Transparent 비용은 Object 수보다 화면을 덮는 Pixel 수에 크게 영향을 받는다.

```text
작은 Spark 10,000개
vs
Fullscreen Fog Quad 5개
```

Fullscreen Fog는 적은 Draw와 Triangle이어도 수백만 Pixel을 반복 처리한다.

```text
최적화
├─ Quad 크기 축소
├─ Texture Padding 축소
├─ Camera 밖 Effect Culling
├─ Fade Out된 Renderer 비활성화
└─ Screen Edge 밖 Particle 제거
```

---

## Layer 수를 줄인다

```text
Before
Base Smoke + Detail Smoke + Light Smoke + Distortion

After
한 Shader 또는 적은 Layer로 표현 통합
```

Layer를 합치면 Draw와 Overdraw를 줄일 수 있지만 Shader가 복잡해질 수 있다.

Texture Sample과 Branch가 늘어 단일 Layer 비용이 커질 수 있으므로 GPU Time을 비교한다.

보이지 않는 유사 Layer를 먼저 제거한다.

---

## Shader를 단순하게 만든다

Overdraw가 높은 Transparent Shader는 Fragment당 비용이 여러 Layer에 곱해진다.

```text
High Overdraw Material
├─ Unlit 가능성
├─ Normal Map 필요성
├─ Additional Light 제한
├─ Shadow Receive Off 검토
├─ Reflection Sample 단순화
├─ Noise Sample 수 감소
└─ Low Quality Variant
```

가까운 Hero Glass와 먼 Background Glass에 같은 PBR 품질을 사용할 필요는 없다.

거리와 Platform별 Material Quality를 분리한다.

---

## Resolution을 낮춘 Buffer에서 처리한다

Fog, Distortion와 Blur처럼 Detail 요구가 낮은 Effect는 Half·Quarter Resolution Buffer에서 처리할 수 있다.

```text
Full Resolution
1920 × 1080 = 약 2.07M Pixel

Half Width / Height
960 × 540 = 약 0.52M Pixel
```

Pixel 수는 약 1/4로 줄지만 Downsample, Upsample와 Composite Pass가 추가된다.

Edge Artifact, Depth-aware Upsampling과 작은 Detail 손실을 확인한다.

---

## Sorting Priority를 최적화로만 쓰지 않는다

URP 문서는 Sorting Priority를 이용해 뒤 Material을 먼저 그리는 순서를 조절하고 불필요한 중복 Pixel Rendering을 피하는 용도를 언급한다.

그러나 일반 Alpha Blend에서는 뒤 Layer Color도 필요하므로 순서만 바꿔 Overdraw가 자동으로 사라지는 것은 아니다.

```text
Sorting Priority 주요 목적
├─ 의도한 Blend Order
├─ 특정 Effect의 앞뒤 관계
└─ Sorting Artifact 완화
```

성능 효과는 ZWrite, Blend Mode와 실제 Layer 관계를 GPU Capture로 확인한다.

---

## Mobile과 Tile-based GPU

Tile-based GPU는 Tile Memory에서 Blend를 처리해 외부 Memory Traffic을 줄일 수 있다.

하지만 다음 작업은 남는다.

```text
Transparent Layer
├─ Fragment Shader
├─ Texture Sample
├─ Depth Test
├─ Blend
└─ Tile Storage와 최종 Store
```

높은 Screen Resolution, MSAA와 여러 Transparent Layer는 Mobile의 Fill-rate와 Thermal Budget을 빠르게 소비할 수 있다.

Desktop GPU에서 허용되는 Effect가 Mobile에서 병목이 될 수 있다.

---

## XR에서 더 민감한 이유

XR은 높은 Refresh Rate와 두 Eye의 Rendering을 요구한다.

```text
Transparent Work
≈ Eye Resolution
× Eye 수
× Layer 수
× Fragment 비용
```

Single Pass Instanced Rendering은 CPU와 일부 GPU 작업을 효율화하지만 각 Eye의 Pixel Coverage가 사라지는 것은 아니다.

Headset Resolution과 Foveated Rendering 영역에서 Transparent Effect를 실제 Device로 측정한다.

---

## Overdraw View에서 확인한다

Unity Scene View의 Overdraw Draw Mode는 Transparent Layer가 겹치는 위치를 밝게 누적해 보여 준다.

```text
어두움 → 적은 Layer
밝음   → 많은 Layer
```

Glass, Smoke, UI와 Sprite가 겹치는 화면 중앙을 먼저 확인한다.

시각화 Shader는 실제 Material 복잡도를 동일하게 표시하지 않으므로 밝기와 GPU ms를 직접 대응시키지 않는다.

---

## Frame Debugger에서 확인한다

```text
Frame Events
├─ Opaque Pass
├─ Transparent Glass
├─ Transparent Smoke
├─ Distortion Pass
├─ Transparent Particle
└─ UI
```

Draw를 한 단계씩 진행하며 같은 Screen 영역에 Color가 몇 번 덧그려지는지 확인한다.

Material의 Blend, ZWrite, ZTest, Cull, Shader Pass와 Texture를 본다.

같은 Effect가 Depth, Distortion와 Color Pass로 여러 번 그려지는지도 확인한다.

---

## GPU Profiler에서 확인한다

```text
측정 항목
├─ Transparent Pass GPU Time
├─ Fragment Shader Invocation
├─ Early-Z Reject 가능성
├─ Texture Bandwidth
├─ Blend / Color Write
├─ Opaque Texture Copy
├─ Depth Texture Pass
└─ 전체 GPU Frame Time
```

Hardware Counter는 GPU Vendor와 Tool에 따라 다르다.

Transparent Renderer 수를 절반으로 줄이거나 Render Scale을 낮춘 A/B Test로 Fragment 민감도를 확인한다.

---

## 최적화 순서

```text
1. GPU Bound인지 확인
2. Overdraw View로 문제 영역 확인
3. Frame Debugger로 원인 Draw·Pass 확인
4. 잘못 설정된 Alpha 1 Transparent를 Opaque로 변경
5. Binary Cutout은 Alpha Clip 비교
6. 화면 Coverage와 Layer 수 축소
7. Lit·Shadow·Refraction Shader 단순화
8. Fade Out된 Renderer와 Particle 비활성화
9. Half-resolution Effect와 Dither 검토
10. Target Device에서 품질·GPU 시간 재측정
```

Sorting Priority와 ZWrite를 임의로 바꾸기 전에 시각적 정확성을 먼저 보존한다.

---

## A/B Test

```text
Test A
Transparent Lit + Shadow + Refraction

Test B
Transparent Unlit + No Shadow

Test C
Alpha Clip

Test D
Opaque / Dithered Fade
```

모든 방식이 완전히 같은 화면을 만들지는 않는다.

Art 요구사항을 만족하는 후보끼리 다음 값을 비교한다.

- Transparent Pass GPU Time
- Total GPU Frame Time
- Draw Calls와 SetPass
- Render Texture Memory
- Sorting Artifact
- Edge Quality와 Temporal Artifact

---

## 흔한 오해

### Transparent는 Alpha 계산 하나만 추가된다

Destination Color Read, Blend, Sorting과 반복 Fragment Layer가 함께 필요하다.

### Alpha가 1이면 Opaque와 비용이 같다

Surface Type이 Transparent이면 별도 Queue, Blend와 ZWrite 설정을 사용하므로 Alpha 값만 1이라고 Opaque 경로가 되지 않는다.

### Alpha가 0이면 Rendering 비용도 없다

Alpha를 계산하기 위한 Shader와 Texture Sample, Blend가 실행될 수 있다.

### Transparent는 Depth Test를 하지 않는다

일반적으로 Opaque Depth에 대한 ZTest는 수행할 수 있지만 Transparent끼리 Depth를 기록하지 않아 Overdraw가 누적된다.

### ZWrite를 켜면 모든 문제가 해결된다

뒤 Transparent Layer를 잘못 제거해 실제 반투명 결과가 깨질 수 있다.

### Sorting Priority를 조절하면 완벽하게 정렬된다

Object가 교차하거나 한 Mesh 내부 Triangle 순서가 필요한 문제는 해결하지 못할 수 있다.

### Additive는 순서가 덜 중요하므로 무료다

모든 Layer의 Fragment Shader와 Blend는 여전히 처리된다.

### Alpha Clip은 항상 Transparent보다 빠르다

Depth Write 이점은 있지만 Alpha Sample, Discard, Jagged Edge와 Shader 구조에 따라 비용이 달라진다.

### Draw Call을 줄이면 Transparent Overdraw도 줄어든다

한 Draw의 Particle와 Instance가 같은 Pixel에 많이 겹칠 수 있다.

### Desktop에서 빠르면 Mobile에서도 빠르다

Fill-rate, Bandwidth, Resolution과 Thermal Budget이 달라 Target Device 측정이 필요하다.

---

## 최종 체크리스트

```text
Material
□ 실제로 Semi-transparency가 필요한가?
□ Alpha 1인데 Transparent로 설정되지 않았는가?
□ Opaque·Alpha Clip·Dither로 대체 가능한가?
□ Lit, Shadow와 Refraction이 모두 필요한가?

Geometry
□ Quad의 투명 Padding이 큰가?
□ Double-sided Rendering이 필요한가?
□ Hair Card와 Glass Layer가 과도한가?
□ Mesh 내부 Sorting 문제가 있는가?

Rendering
□ ZTest와 ZWrite 설정이 의도와 맞는가?
□ Sorting Priority와 Queue가 과도하게 나뉘는가?
□ Distortion·Depth·Color Pass가 반복되는가?
□ Opaque Texture와 Depth Texture 비용을 확인했는가?

Performance
□ Screen Coverage와 Layer 수를 측정했는가?
□ Overdraw View와 Frame Debugger를 확인했는가?
□ Transparent Pass GPU 시간을 측정했는가?
□ Mobile·XR Target Device에서 검증했는가?
```

---

## 정리

Transparent Object는 현재 Fragment와 이미 그려진 Destination Color를 Blend하므로 겹친 Layer의 Fragment Shader와 Color Read·Write를 각각 처리한다.

Semi-transparent Layer의 뒤 Color도 보여야 해서 일반적으로 ZWrite를 끄며, 그 결과 Transparent끼리 Early-Z로 제거하기 어렵고 Overdraw가 누적된다.

올바른 Alpha Blend를 위해 Camera에서 먼 순서로 정렬해야 하므로 CPU Sorting 비용이 생기고 Material State 중심의 Batching 기회도 제한될 수 있다.

Object 단위 Sorting은 교차 Mesh와 한 Mesh 내부 Triangle의 완전한 순서를 해결하지 못해 Glass와 Hair에서 Artifact가 발생할 수 있다.

Lit Transparent, Shadow Receive, Refraction, Soft Particle와 Distortion은 Overdraw Layer마다 Lighting·Depth·Scene Color Sample을 추가한다.

비용은 Object 수보다 Resolution, Screen Coverage, Layer 수, Fragment Shader 복잡도, Blend와 Memory Bandwidth에 크게 좌우된다.

실제 반투명이 필요하지 않으면 Opaque, Binary Surface는 Alpha Clip, Fade는 Dither 방식과 비교하고 필요한 Transparent는 Layer·Coverage와 Shader를 최소화한다.

최종 판단은 Overdraw View로 위치를 찾고 Frame Debugger로 Blend·Depth·Pass를 확인한 뒤 Target Device의 Transparent GPU Time으로 내려야 한다.
