---
title: "[Unity 렌더링] 10-4. Particle은 왜 GPU 부하를 높일까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - ParticleSystem
  - Overdraw
  - Optimization
permalink: /programming/unity-10-4-why-particles-increase-gpu-load/
toc: true
toc_sticky: true
date: 2026-08-16
last_modified_at: 2026-08-16
---

Particle Effect는 작은 Image 여러 장으로 불꽃, 연기, 마법과 폭발을 표현한다.

```text
Explosion
├─ Flash
├─ Fire
├─ Smoke
├─ Spark
├─ Debris
├─ Distortion
└─ Light
```

각 요소는 단순한 Quad처럼 보여도 수십에서 수천 개가 움직이고 서로 겹치며 같은 Screen Pixel을 반복 처리한다.

Particle GPU 부하는 개수뿐 아니라 화면 점유율, Layer 중첩, Shader 복잡도, Blend, Sorting과 Rendering 방식이 함께 결정한다.

---

## Particle System의 한 Frame

Particle System은 생성부터 화면 출력까지 여러 단계를 거친다.

```text
Emission
   │
   ▼
Simulation
Position · Velocity · Lifetime · Color · Size
   │
   ▼
Geometry 생성
Billboard · Mesh · Trail
   │
   ▼
Culling · Sorting · Batching
   │
   ▼
Vertex Shader
   │
   ▼
Rasterization
   │
   ▼
Fragment Shader · Blend
```

GPU 부하라는 표현은 주로 아래 Rendering 단계를 가리키지만 Simulation과 Sorting이 CPU에서 실행되면 CPU Frame Time도 함께 증가한다.

병목 지점을 구분하지 않고 Particle 수만 줄이면 효과가 작거나 다른 문제가 남을 수 있다.

---

## Particle 한 개는 보통 Billboard Quad다

일반적인 Particle은 Camera를 향하는 Billboard 사각형으로 그려진다.

```text
v0 ───────── v1
│          ／ │
│   Smoke    │
│      ／     │
v2 ───────── v3

2 Triangles
```

Particle 한 개의 Triangle 수는 적다.

하지만 GPU Fragment 비용은 Triangle 개수보다 Quad가 화면에서 차지하는 면적에 크게 좌우된다.

```text
작은 Quad 100개
vs
Fullscreen에 가까운 Quad 10개
```

후자가 더 적은 Particle로도 훨씬 많은 Fragment를 만들 수 있다.

---

## Particle 비용을 보는 기본 식

개념적으로 Particle Pixel 비용을 다음처럼 정리할 수 있다.

```text
Particle GPU Pixel Cost
≈ 보이는 Particle 수
× Particle당 Screen Coverage
× 평균 Overlap
× Fragment Shader 비용
× Eye·Camera 수
```

여기에 Vertex 처리, Sorting, Draw Call, Texture Bandwidth와 Render Target 비용이 더해진다.

어떤 항이 병목인지에 따라 최적화 방법도 달라진다.

```text
Coverage 병목 → 크기·거리·Layer 조정
Shader 병목   → Sample·Lighting·Distortion 단순화
Draw 병목     → Material·System·Batch 검토
Simulation 병목 → Emission·Module·Update 빈도 검토
```

---

## Overdraw가 가장 큰 원인인 경우

연기 Particle은 가장자리가 부드러운 반투명 Texture를 사용하고 여러 장이 겹친다.

```text
Camera
  │
  ├─ Smoke A
  ├─ Smoke B
  ├─ Smoke C
  ├─ Smoke D
  └─ Background
```

한 Pixel 위치에 네 장의 Smoke가 겹치면 네 Fragment가 Shader와 Blend를 수행할 수 있다.

Particle이 퍼지면서 각 Quad의 크기가 커지면 개수가 줄어도 Screen Coverage가 증가한다.

```text
초기: Particle 40개 × 작은 면적
후기: Particle 20개 × 매우 큰 면적
```

Effect 후반의 옅은 Smoke가 시각적으로는 약하지만 GPU에서는 더 비쌀 수 있다.

---

## 투명 Texture의 여백

불꽃 모양이 Texture 중앙에 작게 있고 주변이 투명하다고 가정한다.

```text
┌────────────────────┐
│                    │
│       Flame        │
│                    │
└────────────────────┘

보이는 영역 < Billboard Quad 영역
```

GPU는 기본적으로 Quad의 두 Triangle을 Rasterize하므로 투명 여백도 Fragment 후보가 된다.

Alpha가 0인 Pixel도 Texture Sample과 Alpha 계산 이후에 투명하다는 사실을 알 수 있다.

Particle Texture를 제작할 때 불필요한 Padding을 줄이고 모양이 Atlas Cell을 효율적으로 사용하도록 배치해야 한다.

---

## Alpha Blend의 Read·Modify·Write

일반 Alpha Particle은 기존 Render Target Color와 자신의 Color를 혼합한다.

```text
Result
= SourceColor × SourceAlpha
+ DestinationColor × (1 - SourceAlpha)
```

각 Fragment는 개념적으로 다음 과정을 거친다.

```text
Destination Color 읽기
→ Particle Fragment 계산
→ Blend Equation
→ Result Color 쓰기
```

Particle가 같은 Pixel을 여러 번 덮으면 이 과정도 Layer마다 반복된다.

고해상도 화면, HDR Render Target과 높은 Frame Rate에서는 Memory Bandwidth 부담이 커질 수 있다.

---

## Additive Particle도 무료가 아니다

불꽃과 Spark는 Additive Blend를 자주 사용한다.

```text
Result = Source + Destination
```

순서에 덜 민감하고 밝은 결과를 만들기 쉽지만 Fragment Shader, Texture Sample과 Color Blend는 여전히 실행된다.

```text
Additive
≠ Overdraw 제거
≠ Fragment 비용 제거
```

많이 겹친 Additive Particle는 화면이 하얗게 Saturation된 뒤에도 계속 Pixel 작업을 추가할 수 있다.

보이는 밝기가 더 이상 의미 있게 변하지 않는 Layer는 시각 품질보다 비용만 늘릴 수 있다.

---

## Alpha가 낮아져도 비용은 유지될 수 있다

Lifetime 후반에 Alpha를 천천히 0으로 Fade하는 Particle가 많다.

```text
Lifetime
0%      50%      100%
│────────│────────│
Alpha 1.0 → 0.3 → 0.0
```

Alpha가 `0.02`여도 Particle가 살아 있고 Renderer에 제출되면 Quad Coverage는 남는다.

거의 보이지 않는 긴 Tail 구간이 Effect 전체 GPU 비용의 큰 부분을 차지할 수 있다.

Color over Lifetime Curve와 Lifetime을 함께 조정해 시각적으로 의미 없는 구간을 줄인다.

---

## ZWrite Off와 Early-Z 제한

반투명 Particle는 뒤 Scene Color가 보여야 하므로 일반적으로 Depth를 기록하지 않는다.

```text
ZTest  On
ZWrite Off
Blend  On
```

Opaque Geometry 뒤의 Particle는 Depth Test로 제거할 수 있지만 Particle끼리는 앞 Particle가 뒤 Particle를 Depth로 가리지 않는다.

```text
Opaque Wall Depth 기록
→ Wall 뒤 Particle 제거 가능

Smoke A Depth 미기록
→ Smoke B를 Depth로 제거하지 못함
```

투명 Layer가 중첩될수록 Opaque처럼 Early-Z로 Fragment Shader 실행을 줄이기 어렵다.

---

## Sorting 비용

Alpha Blend 결과를 자연스럽게 만들기 위해 Particle를 Camera에서 먼 순서로 정렬할 수 있다.

```text
Far Particle
→ Middle Particle
→ Near Particle
```

Particle 수가 많으면 매 Frame Camera 기준 거리와 순서를 계산해야 한다.

이 비용은 CPU 또는 구현에 따른 Sorting 단계에 나타날 수 있다.

Particle System Renderer의 Sort Mode를 선택할 때 다음 차이를 고려한다.

| Sort Mode | 용도 | 비용·한계 |
|---|---|---|
| None | 순서 영향이 작은 효과 | 가장 단순하지만 Alpha Artifact 가능 |
| By Distance | Camera 거리 기준 | Camera 이동과 Particle 수에 따라 정렬 |
| Oldest in Front | 생성 순서 표현 | 거리 교차를 해결하지 못함 |
| Youngest in Front | 새 Particle 우선 | 효과 의도에 맞을 때 사용 |

Additive처럼 순서 의존성이 낮은 효과에서 불필요한 Distance Sorting을 끌 수 있는지 확인한다.

---

## Particle System 간 Sorting

한 System 내부 Particle 정렬과 여러 Renderer 사이 정렬은 별개의 문제다.

```text
Smoke System A
Spark System B
Distortion System C
```

Sorting Layer, Order in Layer, Render Queue와 Sorting Fudge 설정이 System 사이 순서를 결정한다.

강제로 순서를 조정하면 Artifact를 줄일 수 있지만 Overdraw 자체가 사라지는 것은 아니다.

잘못된 순서를 보정하기 위해 Effect Layer를 계속 추가하면 비용과 유지 보수 난도가 함께 증가한다.

---

## Max Particles는 예약 상한이지 목표가 아니다

Main Module의 `Max Particles`는 동시에 살아 있을 수 있는 Particle 상한을 제한한다.

```text
Emission Rate × Lifetime
≈ 동시에 살아 있는 Particle 수
```

예를 들어 초당 100개를 방출하고 Lifetime이 5초면 안정 상태에서 약 500개가 살아 있을 수 있다.

```text
100 particles/s × 5 s
= 약 500 particles
```

Max Particles를 1000으로 설정했다고 항상 1000개를 그리는 것은 아니다.

실제 Alive Particle 수, Emission Burst와 Lifetime의 조합을 Profile해야 한다.

---

## Emission Rate와 Burst

지속 방출은 Frame마다 Particle를 누적하고 Burst는 짧은 순간에 많은 Particle를 생성한다.

```text
Continuous
10, 10, 10, 10, 10 ...

Burst
0, 0, 300, 0, 0 ...
```

평균 Particle 수가 같아도 Burst Frame에는 생성, Initialization, Geometry Update와 Overdraw가 동시에 증가할 수 있다.

여러 Effect가 같은 Event에서 Burst하면 순간 GPU Spike가 발생한다.

평균 Frame Time뿐 아니라 폭발이 겹치는 Worst-case Frame을 측정해야 한다.

---

## Lifetime은 동시 개수를 결정한다

Emission을 그대로 두고 Lifetime을 두 배로 늘리면 동시에 살아 있는 Particle 수도 대체로 증가한다.

```text
Alive Count
≈ Emission Rate × Average Lifetime
```

시각적으로 거의 사라진 Particle를 오래 유지하면 Simulation과 Rendering 대상이 계속 남는다.

Lifetime 마지막 구간이 실제로 Effect의 형태에 기여하는지 확인한다.

Size와 Alpha Curve만 줄이는 것보다 Lifetime 자체를 줄이는 편이 비용을 더 확실히 제거할 수 있다.

---

## Size over Lifetime과 Screen Coverage

Smoke는 시간이 지날수록 크기가 커지는 Curve를 자주 사용한다.

```text
Birth      Middle       End
  ·          ○          ◯◯
```

Quad의 폭과 높이가 각각 두 배가 되면 면적은 약 네 배가 된다.

```text
Area = Width × Height

2W × 2H = 4WH
```

Particle 수를 20% 줄이는 것보다 최대 Size를 절반으로 줄이는 편이 Fragment Coverage에 더 큰 영향을 줄 수 있다.

Camera와 가까운 Effect에서는 World Size가 Screen을 얼마나 덮는지 반드시 확인한다.

---

## Camera에 가까울수록 비싸질 수 있다

같은 World Space Size의 Particle도 Camera 가까이 오면 화면에서 크게 보인다.

```text
Far Smoke  → 작은 Screen Area
Near Smoke → 큰 Screen Area
```

1인칭 Weapon Effect, Camera Collision Dust와 Screen 앞 Fog는 Fullscreen에 가까운 Quad를 만들 수 있다.

Near Plane을 교차하는 큰 Billboard는 일부만 보이는 상황에서도 넓은 Triangle Coverage를 만들 수 있다.

거리별 Size, Emission, Material Quality와 Effect 교체 정책이 필요하다.

---

## Mesh Particle

Renderer Mode를 Mesh로 설정하면 각 Particle가 지정 Mesh를 그린다.

```text
Billboard Particle
→ 2 Triangles 중심

Mesh Particle
→ Mesh의 Vertex·Triangle 수 × Particle 수
```

파편과 돌 조각에는 Mesh Particle가 적합하지만 복잡한 Mesh를 수백 개 사용하면 Vertex Processing과 Rasterization 비용이 커진다.

Mesh의 보이지 않는 내부 Face, 높은 Subdivision과 여러 Submesh를 제거한다.

Mesh Particle가 불투명하다면 적절한 Opaque Material과 Depth Write로 Overdraw를 줄일 가능성도 있다.

---

## Billboard Alignment의 비용과 결과

Particle System Renderer는 View, Facing, World, Local 같은 정렬 방식을 제공한다.

Billboard 방향을 계산하는 Vertex 단계의 비용보다 결과 Quad가 Screen에서 어떻게 겹치는지가 더 큰 문제가 될 수 있다.

```text
View-facing Smoke
→ Camera에 정면
→ 최대 면적에 가까운 Coverage
```

특정 축으로 고정할 수 있는 Ground Dust나 Slash Effect는 Stretched Billboard, Mesh 또는 다른 Alignment가 시각적 품질과 Coverage에 더 적합할 수 있다.

---

## Stretched Billboard

Stretched Billboard는 Velocity 방향으로 Particle를 늘여 Rain, Spark와 Speed Line을 표현한다.

```text
Normal Billboard: □
Stretched:        ─────────
```

길이가 커지면 한 Particle가 덮는 Screen Area도 증가한다.

Motion을 강조하려고 Length Scale을 과도하게 키우면 Particle 수가 적어도 넓은 Overdraw를 만든다.

Velocity Scale, Length Scale과 Camera Speed Scale을 실제 Camera Movement에서 확인한다.

---

## Trail Module

Trail은 Particle 이동 경로를 Ribbon Geometry로 만든다.

```text
Particle ●──────────── Trail
```

Trail이 길고 Corner·Texture Mode가 세밀하면 Vertex와 Triangle 수가 증가한다.

여러 Trail이 투명하게 겹치면 Ribbon 전체에서 Overdraw가 발생한다.

```text
Trail Cost
≈ Trail을 가진 Particle 수
× Trail 길이·Segment 수
× Screen Coverage
```

Minimum Vertex Distance, Lifetime, Width와 Ratio를 조정해 화면에서 구분되지 않는 Segment를 줄인다.

---

## Texture Sheet Animation

Flipbook Animation은 한 Atlas 안의 Frame을 시간에 따라 바꾼다.

```text
Frame 0 → Frame 1 → Frame 2 → Frame 3
```

단순 Frame 선택은 표현 효율이 좋지만 Frame Blending을 켜면 두 Frame을 Sample하고 보간할 수 있다.

```text
Frame Blending
Sample Current Frame
+ Sample Next Frame
→ Interpolate
```

Texture Sample과 Shader 연산이 늘어나며 Overdraw Layer마다 반복된다.

빠르게 움직이거나 작은 Particle에서 Frame Blending 품질 차이가 실제로 보이는지 비교한다.

---

## Lit Particle

Unlit Particle는 주로 Texture와 Color를 출력하지만 Lit Particle는 Lighting 계산을 추가한다.

```text
Lit Particle Fragment
├─ Base Map
├─ Normal Map
├─ Lighting
├─ Additional Lights
├─ Shadow Receive
├─ Specular
└─ Blend
```

Smoke Layer가 여섯 장 겹치면 Lighting 계산도 같은 Pixel 위치에서 여러 번 실행될 수 있다.

모든 Effect가 Scene Light에 반응해야 하는지, Vertex Lighting이나 단순 Unlit 근사가 가능한지 검토한다.

---

## Additional Light

Forward Rendering에서 Particle가 여러 Additional Light의 영향을 받으면 Fragment당 Light 계산이 증가할 수 있다.

```text
Particle Fragment Cost
≈ Base Shader
+ Light 1
+ Light 2
+ Light 3
```

폭발 Effect가 Point Light를 만들고 그 Light가 Effect 자신의 Lit Smoke와 주변 Particle까지 비추면 비용이 겹친다.

Light Culling Mask, Rendering Layer, Range와 Lifetime을 필요한 범위로 제한한다.

시각 효과용 Light를 실제 Light 대신 Emissive Color나 Shader Parameter로 근사할 수 있는지도 비교한다.

---

## Shadow Casting과 Receiving

Particle Shadow Casting은 Shadow Map Pass에 Particle Geometry를 추가한다.

```text
Light View
→ Particle Shadow Caster Draw
→ Shadow Map Write

Camera View
→ Particle Color Draw
```

Main Camera에는 작게 보이는 Particle가 Directional Light Shadow Map에서는 넓은 영역을 차지할 수 있다.

반투명 Smoke Shadow가 꼭 필요한지, Blob Shadow나 Decal로 대체 가능한지 검토한다.

Receive Shadows도 Lit Fragment마다 Shadow Texture Sample과 비교를 추가할 수 있다.

---

## Soft Particle

Soft Particle는 Scene Geometry와 교차하는 딱딱한 경계를 줄이기 위해 Depth Texture를 Sample한다.

```text
Particle Depth
vs
Scene Depth Texture
→ 교차 거리 계산
→ Alpha Fade
```

시각 품질은 좋아지지만 각 Fragment에 Depth Sample과 Fade 계산이 추가된다.

Pipeline에서 Depth Texture가 다른 이유로 필요하지 않았다면 이를 생성하는 비용도 함께 고려해야 한다.

작고 빠른 Spark까지 Soft Particle가 필요한지 Material 용도별로 나눈다.

---

## Camera Fading

Near·Far Camera Fading은 Camera 거리나 Depth에 따라 Particle Alpha를 조정한다.

Camera와 교차하는 Artifact를 줄이는 데 유용하지만 Fade가 긴 구간에서 거의 보이지 않는 Particle를 계속 그릴 수 있다.

```text
Near Fade Range가 너무 큼
→ 낮은 Alpha의 큰 Particle가 Screen 근처에 오래 존재
```

Fade Distance와 Lifetime을 함께 조정해 보이지 않는 Rendering 구간을 줄인다.

---

## Distortion

Heat Haze와 Shockwave는 Scene Color를 Sample해 UV를 왜곡한다.

```text
Scene Color Copy
→ Distortion Texture Sample
→ Offset 계산
→ Scene Color Sample
→ Composite
```

단순 Additive Particle보다 Texture Sample과 Render Target 의존성이 커진다.

여러 Distortion Particle가 겹치면 넓은 Screen 영역에서 Scene Color를 반복 Sample한다.

Distortion Buffer를 별도 저해상도로 처리하거나 Effect 개수, 크기와 Update 빈도를 줄이는 방식을 비교한다.

---

## Collision Module

Collision은 Particle와 Plane 또는 World Geometry의 충돌을 계산한다.

이는 주로 Simulation 비용이지만 충돌 Event와 Bounce로 Particle Lifetime이 늘면 Rendering 비용에도 영향을 준다.

```text
Collision
├─ Collision Query
├─ Response 계산
├─ Event Callback
└─ 살아 있는 시간 증가 가능
```

Collision Quality, Voxel Size, Collides With Layer와 Max Collision Shapes를 Effect 요구 수준에 맞춘다.

눈에 보이지 않는 먼 Particle까지 정밀 Collision을 수행하지 않도록 거리와 Quality를 조정한다.

---

## Trigger Module

Trigger Module은 Particle가 Collider Volume에 들어오거나 나가는 상태를 판정한다.

많은 Particle와 Collider 조합에서는 CPU Simulation과 Callback 데이터 처리 비용이 커질 수 있다.

GPU Overdraw와 직접 같은 비용은 아니지만 전체 Frame Budget을 공유한다.

Particle Effect의 시각 목적만으로 Trigger를 사용하는지, 단순 Lifetime·Position Curve로 대체할 수 있는지 확인한다.

---

## Noise Module

Noise는 Particle 경로를 자연스럽게 흔든다.

```text
Base Velocity
+ Noise Sample
→ Curved Motion
```

Quality, Frequency, Octave와 Separate Axes 설정에 따라 Simulation 연산이 증가할 수 있다.

모든 작은 Spark에 높은 품질 Noise를 적용하면 화면에서 구분하기 어려운 변화에 CPU 또는 GPU Simulation Budget을 사용하게 된다.

큰 대표 Particle에만 복잡한 Motion을 주고 나머지는 단순 Curve로 근사할 수 있다.

---

## Sub Emitter

Sub Emitter는 Birth, Collision 또는 Death Event에서 다른 Particle System을 방출한다.

```text
Parent Particle Death
→ Smoke Sub Emitter
→ Spark Sub Emitter
→ Debris Sub Emitter
```

하나의 Particle가 여러 자식 Particle를 만들면 Effect 수가 기하급수적으로 늘 수 있다.

Parent의 Max Particles만 확인하면 실제 전체 Particle 수를 놓친다.

Effect Prefab의 모든 Child System과 Sub Emitter가 동시에 만드는 Alive Count를 합산해야 한다.

---

## Lights Module

Particle Lights Module은 일부 Particle에 실제 Light를 연결한다.

```text
Particle 수 500
Light Ratio 0.1
→ 최대 약 50 Light 후보
```

Light 수가 늘면 Light Culling, Shadow와 영향을 받는 Renderer의 Lighting 비용이 증가한다.

Ratio, Maximum Lights, Range Multiplier와 Intensity를 제한한다.

짧은 Flash를 Material Emission으로 표현할 수 있다면 실제 Light와 품질 차이를 비교한다.

---

## Custom Vertex Streams

Particle Shader가 필요한 데이터를 Renderer의 Custom Vertex Streams로 전달할 수 있다.

```text
Position
Color
UV
Custom1
Custom2
Velocity
Age
```

사용하지 않는 Stream이 많으면 Particle Vertex당 전송 데이터와 Memory Bandwidth가 늘어난다.

반대로 Shader가 필요한 값을 전달하지 않으면 잘못된 결과나 추가 계산이 생길 수 있다.

Material Shader가 실제로 읽는 Attribute만 남기고 변경 후 Batching과 결과를 검증한다.

---

## Material 수와 Draw Call

Particle System마다 서로 다른 Material Instance를 사용하면 Batch가 분리될 수 있다.

```text
Smoke Material A
Smoke Material B
Smoke Material C
→ 별도 Draw 가능
```

Texture, Shader Keyword, Blend Mode, Render Queue와 Property 차이가 State 변경을 만든다.

같은 시각 기능은 Atlas와 공유 Material로 묶을 수 있는지 검토한다.

하지만 Draw Call을 합쳐도 겹친 Fragment 수는 그대로일 수 있으므로 Overdraw와 Submission 비용을 따로 측정한다.

---

## Particle System 수

Particle 1000개를 한 System에서 그리는 경우와 Particle 10개인 System 100개는 비용 구조가 다르다.

```text
System A: 1000 Particles, 1 Material

Systems B: 10 Particles × 100 Systems
```

System 수가 많으면 Component Update, Bounds, Culling, Renderer 제출과 Draw Call 관리 비용이 증가할 수 있다.

반대로 성격이 다른 Effect를 무리하게 하나로 합치면 Culling Bounds가 커지고 항상 함께 활성화되는 문제가 생긴다.

Material, Lifetime, 공간적 범위와 활성화 단위가 같은 System끼리만 통합 가능성을 검토한다.

---

## Bounds와 Culling

Renderer Bounds가 Camera Frustum 밖에 있으면 Particle System Rendering을 Culling할 수 있다.

```text
Camera Frustum
┌──────────────┐
│ Effect A     │
└──────────────┘   Effect B → Culled
```

Velocity와 Lifetime이 큰 Particle 때문에 Bounds가 지나치게 넓으면 실제 Particle가 보이지 않아도 System이 Culling되지 않을 수 있다.

반대로 Bounds를 너무 작게 고정하면 보이는 Particle가 갑자기 사라진다.

Renderer Bounds를 Scene View에서 확인하고 Effect의 실제 이동 범위에 맞춘다.

---

## Culling Mode와 Simulation

Particle System의 Culling Mode는 화면 밖일 때 Simulation을 어떻게 처리할지 결정한다.

```text
Always Simulate
→ 보이지 않아도 계속 갱신

Pause
→ 보이지 않을 때 정지

Pause And Catch-up
→ 다시 보일 때 경과 시간 반영
```

화면 밖 Effect를 정지하면 CPU Simulation을 줄일 수 있지만 다시 보일 때 상태가 달라질 수 있다.

Looping Effect, One-shot Effect와 Gameplay에 영향을 주는 Particle인지에 따라 적절한 Mode가 다르다.

GPU Rendering Overdraw 최적화와 Offscreen Simulation 최적화를 구분한다.

---

## GPU Instancing

지원되는 Particle Renderer와 Shader 구성에서는 Mesh Particle에 GPU Instancing을 사용할 수 있다.

```text
여러 Mesh Particle
→ Instance Data 묶음
→ Draw Submission 감소 가능
```

이는 동일 Mesh와 Material의 반복 Draw를 줄이는 데 도움이 되지만 Mesh의 Triangle과 Fragment 자체를 제거하지 않는다.

GPU Instancing 활성화 여부, Shader 호환성과 실제 Draw Call 변화를 Frame Debugger에서 확인한다.

---

## Prewarm의 의미

Looping Particle System의 Prewarm은 시작 순간 이미 한 Cycle이 진행된 것처럼 Particle를 채운다.

빈 상태에서 서서히 차오르는 현상을 피하지만 시작 Frame 주변에 많은 Particle가 즉시 존재할 수 있다.

```text
Without Prewarm: 0 → 20 → 40 → 60
With Prewarm:   100 from start
```

Prewarm 자체의 Initialization 비용과 첫 표시 순간의 Rendering 부하를 확인한다.

화면 밖에서 미리 재생하는 방식도 Simulation과 Memory를 사용하므로 무조건 무료는 아니다.

---

## Object Pooling

Particle Effect Prefab을 반복 Instantiate·Destroy하면 CPU Allocation과 Lifecycle 비용이 발생한다.

Object Pooling은 Effect Object를 재사용해 이 비용과 Garbage Collection Spike를 줄이는 데 도움이 된다.

```text
Pool
→ Get Effect
→ Play
→ Stop
→ Return
```

하지만 Pooling은 Particle의 GPU Fragment 수를 줄이지 않는다.

비활성 Pool이 너무 크면 Memory를 차지하고 재사용 시 Module 상태가 남을 수 있으므로 Clear와 Stop Behavior를 명확히 관리한다.

---

## LOD와 Quality Level

Particle는 거리와 품질 설정에 따라 단계적으로 단순화할 수 있다.

```text
Near
├─ Lit Smoke
├─ Distortion
├─ Trails
└─ Dense Sparks

Far
├─ Unlit Smoke
├─ No Distortion
├─ No Trails
└─ Low Emission
```

멀리 있는 Particle는 화면에서 작아 Detail 차이가 잘 보이지 않는다.

Emission, Max Particles, Texture Sheet FPS, Shader, Shadow와 Light Module을 Quality Level별로 조정한다.

Effect 전체를 갑자기 끄기보다 시각적 중요도가 낮은 Module부터 줄이면 변화가 자연스럽다.

---

## Particle Budget

개별 Effect가 아니라 Scene 전체 동시 Effect 수를 기준으로 Budget을 세운다.

```text
Worst-case Battle
├─ Player Skill × 2
├─ Enemy Skill × 10
├─ Hit Effect × 20
├─ Environment Dust
└─ UI Particle
```

각 Prefab이 단독으로 0.2ms여도 20개가 겹치면 Frame Budget을 넘을 수 있다.

다음 항목을 Effect별로 기록할 수 있다.

| 항목 | 예시 Budget |
|---|---:|
| Peak Alive Particles | 500 |
| 최대 Screen Coverage | 25% |
| Transparent Layers | 4 |
| Material·Pass 수 | 3 |
| Light·Distortion | 각 1 이하 |
| Target GPU Time | 0.4ms |

숫자는 Project와 Device에 맞춰 Profile 결과로 정한다.

---

## UI Particle

Canvas 위 Particle Effect는 UI Background, Panel, Text와 추가로 겹친다.

```text
UI Background
→ Panel
→ Particle
→ Icon
→ Text
```

Screen Space에서 크기가 유지되면 해상도가 높을수록 Particle Coverage가 증가한다.

UI Mask와 Sorting을 맞추기 위해 별도 Camera, Render Texture 또는 Custom Shader를 사용하면 추가 Pass와 Composite 비용이 생길 수 있다.

장식용 Particle가 Interaction에 실제로 기여하는지, 개수와 Update Rate를 줄일 수 있는지 검토한다.

---

## Mobile GPU에서의 Particle

Mobile은 높은 Display Resolution에 비해 Memory Bandwidth와 전력 Budget이 제한적이다.

```text
Large Transparent Quad
× Many Layers
× Blend Read·Write
× 60/120 Hz
```

짧은 Profile에서는 목표 Frame을 만족해도 지속 Effect가 발열을 만들고 Clock이 낮아지면 Frame Time이 증가할 수 있다.

Desktop GPU에서 Particle 수만 맞춘 결과를 Mobile로 그대로 옮기지 않는다.

대표 저사양 Target Device에서 긴 전투와 Worst-case Effect 중첩을 측정한다.

---

## XR에서의 Particle

XR은 Particle를 두 Eye View에 Rendering할 수 있다.

```text
Left Eye Coverage
+ Right Eye Coverage
= Stereo Fragment Work
```

Camera 가까운 Smoke와 Muzzle Flash는 두 화면에서 큰 면적을 덮으며 Depth와 Stereo Projection에 따른 Artifact도 만들 수 있다.

Single Pass Instanced가 CPU·Vertex Submission을 줄여도 각 Eye의 Pixel Coverage가 사라지는 것은 아니다.

XR Render Scale, Foveated Rendering과 Particle Quality Level을 실제 Headset에서 검증한다.

---

## VFX Graph와 Particle System

VFX Graph는 많은 Particle Simulation을 GPU에서 처리하는 데 유리할 수 있다.

```text
CPU Particle System
→ CPU Simulation 중심

VFX Graph
→ GPU Simulation·Rendering 중심
```

수십만 Particle의 Position Update를 GPU로 옮겨 CPU 병목을 줄일 수 있지만 Fragment Overdraw가 자동으로 줄어드는 것은 아니다.

오히려 더 많은 Particle를 쉽게 생성해 Pixel 병목이 커질 수 있다.

```text
Simulation이 빨라짐
≠ Rendering이 무료
```

Alive Count, Bounds, Output Quad Size와 Shader 비용을 동일하게 Profile한다.

---

## Particle 수를 줄여도 느린 경우

Particle 수를 절반으로 줄였는데 GPU 시간이 거의 변하지 않을 수 있다.

가능한 원인은 다음과 같다.

```text
남은 Particle가 여전히 Fullscreen을 덮음
Distortion Fullscreen Pass가 고정 비용
복잡한 Lit Shader가 병목
다른 Transparent Effect가 더 큰 비중
CPU 또는 Draw Call이 병목이 아님
```

Count 변경만으로 결론을 내리지 말고 Size, Shader와 Resolution을 각각 A/B Test한다.

---

## Overdraw View

Scene View의 Overdraw Draw Mode에서 Effect를 단독 재생하면 Layer가 집중되는 위치를 찾기 쉽다.

```text
확인 상태
├─ Effect 시작 Frame
├─ Peak Burst Frame
├─ Smoke 확산 Frame
└─ Fade-out Frame
```

한 시점만 보면 Peak를 놓칠 수 있으므로 Timeline을 Scrub하거나 반복 Capture한다.

밝은 영역은 중첩 후보를 보여 주지만 Shader Sample 수와 정확한 GPU 시간까지 나타내지는 않는다.

---

## Frame Debugger

Frame Debugger에서 Particle Draw Event를 순서대로 확인한다.

```text
확인 항목
├─ System별 Draw 수
├─ Material과 Shader Pass
├─ Blend Mode
├─ ZWrite·ZTest
├─ Render Queue
├─ Soft Particle·Distortion Pass
├─ Shadow Caster Pass
└─ Render Target Copy·Blit
```

하나의 Effect Prefab이 Color, Distortion, Trail과 Shadow로 몇 번 제출되는지 확인할 수 있다.

숨겨진 Child System이나 종료되지 않은 Looping System도 Draw 목록에서 찾는다.

---

## CPU와 GPU Profiler

Particle 병목을 다음처럼 분리한다.

```text
CPU
├─ Simulation
├─ Emission
├─ Collision·Trigger
├─ Sorting
├─ Bounds·Culling
└─ Draw Submission

GPU
├─ Vertex Processing
├─ Rasterization
├─ Fragment Shader
├─ Texture Sample
├─ Blend·Bandwidth
└─ Shadow·Distortion Pass
```

CPU Main Thread가 병목이면 Fragment Shader를 단순화해도 Frame Rate가 바로 오르지 않을 수 있다.

GPU Fill-rate가 병목이면 Object Pooling만 적용해도 Pixel 비용은 그대로다.

Profiler Timeline과 GPU Module을 함께 확인한다.

---

## RenderDoc과 Pixel History

GPU Capture에서 특정 Pixel의 History를 보면 어떤 Particle Draw가 반복해서 Color를 썼는지 추적할 수 있다.

```text
Pixel (x, y)
├─ Smoke Draw 1
├─ Smoke Draw 2
├─ Fire Draw
├─ Spark Draw
└─ Distortion Composite
```

Draw별 Texture, Blend State, Depth State, Shader Resource와 Render Target Resolution도 확인한다.

Editor Capture와 Target Device의 Graphics API가 다르면 비용 특성도 다를 수 있다.

Capture는 원인 구조를 확인하는 도구이고 최종 성능 수치는 Target GPU Profile로 결정한다.

---

## Particle 최적화 A/B Test

Effect와 Camera를 고정하고 변수를 하나씩 바꾼다.

```text
Baseline
→ Emission 50%
→ Max Size 50%
→ Lifetime 50%
→ Unlit Shader
→ Soft Particle Off
→ Distortion Off
→ Trails Off
→ Resolution 50%
```

결과를 다음처럼 기록한다.

| 변경 | CPU ms | GPU ms | 품질 영향 |
|---|---:|---:|---|
| Baseline | 1.2 | 3.8 | 기준 |
| Size 50% | 1.1 | 2.2 | 연기 범위 감소 |
| Emission 50% | 0.8 | 2.7 | 밀도 감소 |
| Unlit | 1.2 | 2.5 | 조명 반응 감소 |

예시는 측정 방식이며 실제 숫자는 Project와 Device마다 다르다.

GPU 시간이 Resolution과 Size에 크게 반응하면 Fragment·Fill-rate 병목 가능성이 높다.

---

## 최적화 우선순위

화면에 미치는 영향이 큰 항목부터 검토한다.

```text
1. 보이지 않는 Looping System과 Child Effect 중단
2. 큰 Particle의 최대 Size와 Camera 근접 Coverage 축소
3. Lifetime 후반의 낮은 Alpha 구간 제거
4. Emission·Burst와 동시 Effect 수 제한
5. 투명 Texture Padding과 Layer 중첩 축소
6. Lit·Soft Particle·Distortion·Shadow 단순화
7. Trail·Collision·Noise·Light Module 조정
8. Material 공유와 불필요한 Sorting 제거
9. Distance·Quality LOD 적용
10. Target Device에서 Worst-case 재측정
```

Particle Count를 일괄 감소시키기보다 시각적으로 가장 덜 중요한 Layer부터 제거한다.

Main Flash와 Silhouette는 유지하고 긴 Smoke Tail과 미세 Spark를 줄이는 방식이 품질 대비 효율적일 수 있다.

---

## 흔한 오해

### Particle 수가 적으면 항상 가볍다

Particle 열 개도 Camera 가까이에서 화면 전체를 덮으면 수천 개의 작은 Particle보다 비쌀 수 있다.

### Quad는 Triangle 두 개뿐이므로 가볍다

Fragment 수는 Triangle 개수보다 Screen Coverage와 중첩에 크게 영향을 받는다.

### Alpha가 거의 0이면 비용도 거의 0이다

보이는 기여가 작아도 Fragment Shader와 Blend가 실행될 수 있다.

### Additive는 Sorting이 단순하므로 무료다

순서 의존성이 낮을 뿐 Texture Sample, Fragment와 Blend 비용은 남는다.

### Particle를 Pooling하면 GPU도 빨라진다

Pooling은 Instantiate·Destroy와 Allocation 비용을 줄이지만 화면의 Fragment 수를 직접 줄이지 않는다.

### VFX Graph로 바꾸면 모든 Particle가 빨라진다

GPU Simulation은 CPU 병목을 줄일 수 있지만 Overdraw와 Shader 비용은 별도로 남는다.

### Soft Particle는 Alpha만 부드럽게 바꾼다

Scene Depth Texture Sample과 Fade 계산이 필요하며 Depth Texture 생성 비용도 관련될 수 있다.

### Sorting을 끄면 시각 결과는 항상 같다

Additive는 차이가 작을 수 있지만 일반 Alpha Blend에서는 순서 Artifact가 나타날 수 있다.

### Draw Call을 합치면 Overdraw도 줄어든다

같은 Batch 안에서도 겹친 Quad는 각 Fragment를 처리한다.

### Max Particles가 실제 Particle 수다

Max Particles는 상한이고 실제 Alive Count는 Emission과 Lifetime에 따라 결정된다.

### Offscreen Particle는 비용이 전혀 없다

Rendering은 Culling되어도 Culling Mode에 따라 Simulation이 계속될 수 있다.

---

## 최종 체크리스트

```text
□ Peak Alive Particle 수를 확인했는가?
□ Emission Rate × Lifetime으로 동시 개수를 추정했는가?
□ Camera 근처에서 최대 Screen Coverage를 확인했는가?
□ Size over Lifetime의 최대 면적이 과도하지 않은가?
□ Alpha가 거의 0인 Tail 구간이 길지 않은가?
□ Texture Atlas Cell에 투명 Padding이 크지 않은가?
□ Additive Particle에 불필요한 Sorting을 사용하지 않는가?
□ Lit·Normal·Additional Light가 꼭 필요한가?
□ Soft Particle와 Camera Fading이 필요한 Material에만 켜졌는가?
□ Distortion이 넓은 화면을 반복 Sample하지 않는가?
□ Shadow Casting과 Receiving이 필요한가?
□ Trail Lifetime과 Segment가 과도하지 않은가?
□ Collision·Trigger·Noise Quality가 목적에 맞는가?
□ Sub Emitter를 포함한 전체 Child System 수를 확인했는가?
□ Particle Light Ratio와 Maximum Lights를 제한했는가?
□ 사용하지 않는 Custom Vertex Stream을 제거했는가?
□ Material Instance와 Particle System 수가 과도하지 않은가?
□ Renderer Bounds와 Culling Mode가 적절한가?
□ 거리·Quality별 Effect LOD가 있는가?
□ Worst-case 동시 Effect 상태를 Profile했는가?
□ CPU Simulation과 GPU Fragment 병목을 분리했는가?
□ Resolution·Size·Shader A/B Test를 수행했는가?
□ Target Device에서 지속 발열 상태까지 확인했는가?
```

---

## 정리

Particle는 적은 Triangle의 Billboard를 사용하더라도 많은 Quad가 넓은 화면 영역에서 겹치며 Fragment Shader와 Blend를 반복하므로 GPU 부하가 커진다.

실제 비용은 Particle 수만이 아니라 Screen Coverage, Overlap, Shader 복잡도, Blend, Camera·Eye 수의 곱으로 판단해야 한다.

Emission과 Lifetime은 Alive Count를 결정하고 Size over Lifetime과 Camera 거리는 Particle 한 개가 만드는 Pixel 수를 결정한다.

Lit Shader, Additional Light, Shadow, Soft Particle, Distortion, Texture Sheet Frame Blending과 Trail은 Layer마다 연산·Sample·Pass 또는 Geometry 비용을 추가한다.

Collision, Trigger, Noise, Sub Emitter, Sorting과 여러 System은 CPU Simulation과 제출 비용도 높일 수 있어 GPU Overdraw와 별도로 측정해야 한다.

큰 Quad, 낮은 Alpha의 긴 Tail, 투명 Padding과 Fullscreen에 가까운 Effect부터 줄이고 거리·Quality별 LOD로 동시 Effect Budget을 관리한다.

Overdraw View와 Frame Debugger로 Layer·Pass 구조를 확인하고 CPU·GPU Profiler와 Resolution·Size A/B Test를 이용해 Target Device에서 병목을 검증해야 한다.
