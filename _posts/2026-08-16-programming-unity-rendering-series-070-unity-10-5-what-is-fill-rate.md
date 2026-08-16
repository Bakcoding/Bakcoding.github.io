---
title: "[Unity 렌더링] 10-5. Fill Rate란 무엇일까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - FillRate
  - FragmentShader
  - Optimization
permalink: /programming/unity-10-5-what-is-fill-rate/
toc: true
toc_sticky: true
date: 2026-08-16
last_modified_at: 2026-08-16
---

Fill Rate는 GPU가 일정 시간 동안 Render Target의 Pixel을 처리하고 기록할 수 있는 능력을 뜻한다.

```text
Geometry
  │
  ▼
Rasterization
  │
  ▼
Fragment Shader
  │
  ▼
Blend · Color Write
  │
  ▼
Render Target Pixel
```

화면에 그릴 Pixel 작업이 GPU의 처리 능력을 넘으면 GPU Frame Time이 증가하고 Frame Rate가 낮아질 수 있다.

Fill Rate는 단순히 화면 해상도만의 문제가 아니라 Overdraw, Shader 복잡도, Texture Sample, Blend와 Render Target 수가 함께 만드는 Pixel 처리량의 문제다.

---

## Fill의 의미

Rasterization은 Triangle이 덮는 Screen 위치에 Fragment 후보를 만든다.

Fragment Shader와 후속 단계는 이 후보를 계산해 Render Target의 Pixel을 채운다.

```text
Triangle
  └─ Screen Area를 덮음
       └─ Fragment 후보 생성
            └─ Pixel Color 기록
```

여기서 `Fill`은 최종 화면의 빈칸을 한 번 채운다는 의미로만 해석하면 안 된다.

같은 Pixel 위치를 여러 Draw가 반복해서 덮으면 각각 별도의 Fill 작업이 발생할 수 있다.

---

## 이론적 Pixel Fill Rate

GPU 사양의 Pixel Fill Rate는 흔히 다음과 같은 형태로 표현된다.

```text
Theoretical Pixel Fill Rate
≈ Raster Operations Per Clock
× GPU Clock
```

단위는 대개 초당 수십억 Pixel을 뜻하는 `GPixel/s`다.

예를 들어 이론상 초당 32 GPixel을 기록할 수 있는 GPU가 있다고 가정한다.

```text
32 GPixel/s
= 32,000,000,000 Pixels/s
```

이 수치는 특정 조건의 최대 처리량에 가까우며 실제 Game에서 항상 달성되는 성능은 아니다.

Shader, Texture, Blend, Cache, Bandwidth, Thermal Throttling과 다른 Pipeline 단계가 먼저 병목이 될 수 있다.

---

## Frame당 Pixel Budget

목표 Frame Rate를 알면 초당 Fill Rate를 Frame당 개념적 Budget으로 나눌 수 있다.

```text
Frame당 Pixel 처리 Budget
≈ 초당 유효 Pixel 처리량
  ─────────────────────
       Target FPS
```

유효 처리량이 12 GPixel/s이고 목표가 60 FPS라면 다음처럼 생각할 수 있다.

```text
12,000,000,000 / 60
= 200,000,000 Pixel Operations per Frame
```

하지만 Fragment마다 비용이 같지 않으므로 이를 정확한 허용 Pixel 수로 사용하면 안 된다.

Effect와 Resolution 변경이 처리량에 어떤 방향으로 영향을 주는지 이해하기 위한 모델이다.

---

## 화면 Pixel 수와 Fill Rate

일반적인 해상도의 Pixel 수는 다음과 같다.

| Resolution | 화면 Pixel 수 |
|---|---:|
| 1280 × 720 | 921,600 |
| 1920 × 1080 | 2,073,600 |
| 2560 × 1440 | 3,686,400 |
| 3840 × 2160 | 8,294,400 |

화면을 정확히 한 번만 단순하게 채운다면 1080p에서 약 207만 Pixel 작업으로 생각할 수 있다.

실제 Frame은 Opaque, Transparent, Shadow, Post-processing과 UI가 여러 차례 같은 위치를 처리한다.

```text
Depth Prepass
→ Opaque Color
→ Transparent
→ Post-processing
→ UI
→ Final Blit
```

따라서 Backbuffer Pixel 수보다 실제 Fragment와 Render Target Write 수가 훨씬 많을 수 있다.

---

## Overdraw와 Fill Rate

Overdraw는 같은 Pixel 위치에 여러 Fragment가 겹쳐 반복 처리되는 현상이다.

```text
Screen Pixel (x, y)
├─ Background Fragment
├─ Smoke Fragment A
├─ Smoke Fragment B
├─ UI Dim Fragment
└─ Popup Fragment
```

평균 Overdraw가 `4×`라고 단순화하면 화면 Pixel 수의 약 네 배에 해당하는 Fragment 후보가 처리될 수 있다.

```text
Pixel Work
≈ Resolution Pixels × Average Overdraw
```

1080p에서 평균 `4×`라면 개념적으로 약 829만 Fragment 위치다.

Shader 비용과 Depth 제거 여부가 다르므로 Overdraw Ratio만으로 실제 GPU 시간을 계산할 수는 없다.

---

## Fill Rate와 Fragment Shader

Fill Rate 병목은 Color를 쓰는 하드웨어의 최대량만을 의미하지 않는다.

현업에서는 넓은 Pixel 영역을 처리하는 Fragment 단계가 전체 GPU 성능을 제한하는 상황을 Fill-rate Bound라고 부르는 경우가 많다.

```text
Fragment Cost
├─ Arithmetic
├─ Texture Sample
├─ Branch
├─ Lighting
├─ Depth·Stencil
├─ Blend
└─ Render Target Write
```

Fragment Shader가 복잡하면 초당 처리할 수 있는 유효 Fragment 수가 줄어든다.

같은 GPU도 단색 Shader와 여러 Texture를 Sample하는 Lit Shader의 실효 Fill Rate가 다르다.

---

## 단순 Shader와 복잡한 Shader

두 Fullscreen Shader를 비교한다.

```text
Shader A
return fixedColor;

Shader B
Sample Base Map
Sample Normal Map
Sample Mask Map
Calculate Lights
Sample Shadow
Calculate Fog
Apply Color Grading
```

두 Shader 모두 같은 수의 Pixel을 덮지만 B는 Fragment당 더 많은 연산과 Memory Access를 요구한다.

```text
Total Pixel Cost
≈ Covered Fragments × Cost per Fragment
```

Fill Rate를 Pixel 수 하나로만 설명할 수 없는 이유다.

---

## Pixel Fill Rate와 Texel Fill Rate

GPU 사양에는 Pixel Fill Rate와 Texel Fill Rate가 구분되어 표시될 수 있다.

```text
Pixel Fill Rate
→ Render Target Pixel 출력 능력과 관련

Texel Fill Rate
→ Texture Unit의 Texture Sample 처리 능력과 관련
```

Texel은 Texture의 한 Sample 위치를 의미한다.

Fragment 하나가 Texture를 한 번만 Sample할 수도 있고 여러 번 Sample할 수도 있다.

```text
Fragment A: 1 Texture Sample
Fragment B: 8 Texture Samples
```

Texture Sample이 많은 Shader는 Pixel 출력보다 Texture Fetch 처리량이나 Memory Bandwidth가 먼저 병목이 될 수 있다.

---

## Texture Sample 수

PBR Material은 Base Map, Normal Map, Mask Map과 Emission Map을 사용할 수 있다.

```text
Lit Fragment
├─ Base Map Sample
├─ Normal Map Sample
├─ Metallic·AO Sample
├─ Emission Sample
├─ Shadow Sample
└─ Reflection Sample
```

Transparent Layer가 세 장 겹치면 이 Sample들도 Layer마다 반복될 수 있다.

Texture를 Atlas나 Channel Packing으로 합치면 Sample과 State 변경을 줄일 가능성이 있지만 압축 Format, 해상도와 Cache 효율을 함께 고려해야 한다.

사용하지 않는 Feature가 Shader Variant에서 실제로 제거되는지도 확인한다.

---

## Texture Cache

가까운 Fragment가 비슷한 Texture 위치를 읽으면 GPU Cache가 데이터를 재사용할 수 있다.

```text
Coherent Access
UV 0.50 → 0.51 → 0.52
→ Cache 재사용 가능

Random Access
UV 0.10 → 0.87 → 0.32
→ Cache Miss 증가 가능
```

같은 Texture Sample 수라도 UV Access Pattern과 Texture 크기에 따라 비용이 달라진다.

Noise 기반 Distortion, 불규칙한 Lookup과 큰 Texture는 Cache 효율을 낮출 수 있다.

이론적 Texel Fill Rate가 실제 Shader 성능을 그대로 보장하지 않는 이유다.

---

## Memory Bandwidth

Memory Bandwidth는 GPU가 일정 시간 동안 Memory와 주고받을 수 있는 Data 양이다.

```text
Bandwidth Pressure
├─ Texture Read
├─ Depth Read·Write
├─ Color Read·Write
├─ Multiple Render Targets
├─ Blend Destination Read
└─ Intermediate Texture Copy
```

Fill-rate Bound처럼 보이는 Frame이 실제로는 Memory Bandwidth에 제한될 수 있다.

고해상도 Render Target, HDR Format과 Overdraw가 결합하면 Pixel당 Data 이동량이 증가한다.

---

## Render Target Format

Pixel 하나가 사용하는 Byte 수는 Render Target Format에 따라 달라진다.

```text
예시 개념
RGBA8   → 4 Bytes per Pixel
RGBA16F → 8 Bytes per Pixel
RGBA32F → 16 Bytes per Pixel
```

실제 저장과 압축 방식은 GPU와 Platform에 따라 달라질 수 있다.

같은 해상도와 같은 Pixel 수라도 더 큰 Format은 Color Buffer Read·Write와 Memory 용량을 늘릴 수 있다.

HDR가 필요한 Pass와 LDR로 충분한 Pass를 구분하고 URP Asset의 HDR 설정이 Target 품질에 필요한지 확인한다.

---

## Blend와 Fill Rate

Opaque Fragment는 기존 Color를 완전히 대체할 수 있다.

Transparent Fragment는 Destination Color와 혼합해야 한다.

```text
Opaque
Source → Color Write

Transparent
Destination Read
+ Source
→ Blend
→ Color Write
```

Blend는 Color Buffer Read·Modify·Write와 순서 의존성을 추가한다.

Fullscreen UI, Smoke, Fog와 Decal이 중첩되면 Blend와 Bandwidth가 Fill Rate를 제한할 수 있다.

Additive Blend도 Equation이 단순할 뿐 Destination과의 결합 및 Color Write가 사라지는 것은 아니다.

---

## Depth Buffer가 Fill을 줄이는 방법

Opaque Object는 일반적으로 Depth를 기록한다.

가까운 Surface가 먼저 그려지면 뒤 Fragment를 Fragment Shader 전에 제거할 수 있다.

```text
Near Opaque
→ Depth 5 기록

Far Opaque
→ Depth 10
→ Early-Z Fail
→ Fragment Shader 생략 가능
```

Front-to-Back Sorting과 Early-Z는 최종 Color에 기여하지 않는 Fragment의 비싼 Pixel Shader 실행을 줄인다.

Rasterization과 Depth Test 비용이 모두 사라지는 것은 아니지만 Opaque Fill 부담을 크게 낮출 수 있다.

---

## Early-Z가 제한되는 경우

GPU가 Fragment Shader 실행 전에 Depth 결과를 확정하기 어려운 Shader가 있다.

```text
주의 요소
├─ Fragment에서 Depth 수정
├─ discard·clip
├─ Alpha Test
├─ 일부 UAV·Side Effect
└─ Pipeline·Hardware별 제약
```

Alpha Clipping은 투명 영역을 Color Write하지 않지만 Texture Alpha를 알아야 버릴 수 있어 Fragment Shader 일부가 실행된다.

Depth Prepass가 있어도 Shader와 GPU 구현에 따라 기대한 Early-Z 이득이 달라질 수 있다.

Frame Capture와 실제 GPU Time으로 확인해야 한다.

---

## Depth Prepass의 비용

Depth Prepass는 Geometry를 먼저 그려 Depth Buffer를 채운다.

```text
Depth Prepass
→ Depth만 기록

Color Pass
→ 이미 채운 Depth로 가려진 Fragment 제거
```

복잡한 Scene에서 비싼 Color Shader Overdraw를 줄일 수 있다.

하지만 Geometry를 한 번 더 제출하고 Rasterize하며 Depth Buffer를 읽고 쓴다.

```text
이득
→ Color Fragment 감소

비용
→ Draw·Vertex·Depth 작업 증가
```

Vertex Bound Scene이나 Overdraw가 낮은 Scene에서는 손해가 될 수 있다.

---

## Multiple Render Targets

Deferred Rendering의 G-buffer Pass는 한 Fragment에서 여러 Render Target에 값을 기록한다.

```text
Fragment
├─ GBuffer 0: Base Color
├─ GBuffer 1: Normal
├─ GBuffer 2: Material Data
└─ Depth
```

화면 Pixel 한 개를 처리해도 여러 Buffer Write가 발생한다.

따라서 단순히 Backbuffer Pixel 수만으로 Fill 비용을 추정할 수 없다.

G-buffer Format, Render Target 수와 Bandwidth는 Deferred의 Pixel 비용에 중요한 요소다.

---

## Forward와 Deferred

Forward Rendering은 Object의 Color Pass에서 Lighting을 계산한다.

```text
Forward Fragment
→ Material + Light 계산
→ Color Target Write
```

Deferred Rendering은 먼저 G-buffer를 채우고 Lighting Pass에서 Screen Space Lighting을 계산한다.

```text
Geometry Pass
→ Multiple G-buffer Writes

Lighting Pass
→ G-buffer Reads
→ Lighting Color Write
```

Forward는 Overdraw된 Opaque Fragment마다 Lighting을 반복할 수 있고 Deferred는 넓은 G-buffer Bandwidth를 사용한다.

Scene의 Light 수, Material, MSAA, Transparency와 GPU 특성에 따라 어느 쪽이 Fill Rate에 유리한지 달라진다.

---

## Fullscreen Pass

Post-processing은 화면 전체 또는 대부분을 덮는 Triangle·Quad로 실행된다.

```text
Camera Color
→ Bloom
→ Tone Mapping
→ Color Grading
→ Vignette
→ Anti-aliasing
→ Final Output
```

각 Pass가 1080p 전체를 처리하면 Pass 하나마다 약 207만 Pixel 위치를 읽고 쓸 수 있다.

Effect를 Volume 하나에 묶어 설정해도 내부 구현이 반드시 한 Pass라는 뜻은 아니다.

Frame Debugger와 GPU Profiler로 실제 Render Pass와 Intermediate Texture를 확인한다.

---

## Bloom의 Pixel 처리

Bloom은 밝은 영역 추출, Downsample, Blur와 Upsample을 여러 Level에서 수행할 수 있다.

```text
Full Resolution Source
→ Half Resolution
→ Quarter Resolution
→ Eighth Resolution
→ Blur
→ Upsample
→ Composite
```

낮은 Resolution을 이용해 비용을 줄이지만 여러 Level의 Texture Read·Write가 발생한다.

Bloom Quality, Iteration과 Scatter는 단순한 On·Off보다 실제 Pass 구조로 판단해야 한다.

다른 Fullscreen Effect와 합성 가능한지 Pipeline 구현도 확인한다.

---

## Blur와 Sample 수

Blur Kernel이 넓으면 Fragment 하나가 주변 Texel을 여러 번 읽는다.

```text
3 × 3 Kernel
→ 최대 9 Samples 개념

Separable Blur
→ Horizontal Samples
→ Vertical Samples
```

Separable Blur는 2D Kernel을 두 Pass로 나눠 Sample 수를 줄일 수 있지만 Intermediate Texture Write가 추가된다.

Resolution을 절반으로 낮추면 각 축의 Pixel 수가 절반이 되어 전체 Pixel 수는 약 1/4이 된다.

UI Background Blur와 Depth of Field가 저해상도 Buffer를 사용하는 이유다.

---

## MSAA와 Fill Rate

MSAA는 Triangle 경계의 여러 Coverage Sample을 저장해 Anti-aliasing한다.

```text
1 Pixel
├─ Sample 0
├─ Sample 1
├─ Sample 2
└─ Sample 3
```

`4× MSAA`가 모든 Fragment Shader 비용을 정확히 네 배로 만든다는 뜻은 아니다.

Shader 실행 빈도, Coverage, Depth·Color Storage와 Resolve 방식은 GPU와 설정에 따라 다르다.

하지만 Multi-sample Buffer는 Memory와 Bandwidth를 늘리고 Edge가 많은 Scene에서 Sample 처리를 추가할 수 있다.

Fill-rate가 의심되면 MSAA Off·2×·4×를 같은 장면에서 비교한다.

---

## Dynamic Resolution

Dynamic Resolution은 GPU 부하에 따라 Rendering Resolution을 조정한다.

```text
GPU 부하 증가
→ Render Scale 감소
→ Pixel 수 감소
→ GPU Pixel 시간 완화
```

Scale을 각 축에서 `0.8`로 낮추면 Pixel 수는 대략 `0.8 × 0.8 = 0.64`가 된다.

```text
80% Width × 80% Height
= 64% Pixels
```

Fragment·Bandwidth Bound 상황에서는 효과가 크지만 CPU, Vertex, Draw Call이나 Simulation 병목에는 영향이 작다.

Upscaling 품질과 UI Resolution 정책도 함께 확인해야 한다.

---

## URP Render Scale

URP Asset의 Render Scale은 Camera Rendering에 사용하는 내부 Resolution을 조절한다.

```text
Display: 1920 × 1080
Render Scale: 0.75

Internal Rendering
≈ 1440 × 810
```

내부 3D Rendering Pixel은 줄지만 Screen Space Overlay UI나 일부 별도 Render Target은 다른 Resolution을 사용할 수 있다.

Render Scale 변경으로 어떤 Pass가 실제로 줄었는지 Frame Debugger에서 Render Target 크기를 확인한다.

다음 글에서 Resolution과 GPU 성능 관계를 별도로 더 깊게 다룬다.

---

## Shadow Map Fill

Shadow Caster는 Light 관점의 Shadow Map에 Depth를 기록한다.

```text
Main Camera Color Pass
+ Directional Shadow Cascades
+ Additional Light Shadow Maps
```

화면에 보이는 Pixel 수와 별개로 Shadow Atlas의 Pixel을 채운다.

Shadow Resolution, Cascade 수, Shadow를 만드는 Object와 Additional Light 수가 Depth Fill 작업을 늘린다.

Shadow Pass는 단순 Depth Shader일 수 있지만 Alpha Clipped Foliage는 Texture Alpha Sample과 Clip을 수행할 수 있다.

---

## Reflection과 별도 Camera

Planar Reflection, Portal, Security Camera와 Mirror는 Scene을 별도 Render Texture에 다시 그릴 수 있다.

```text
Main Camera Render
+ Reflection Camera Render
+ Portal Camera Render
```

Display Resolution이 하나여도 실제로 채우는 Render Target가 여러 개다.

각 Camera의 Resolution, Culling Mask, Post-processing, Shadow와 Update Rate를 제한한다.

작게 보이는 Reflection Surface에 Full Resolution Buffer를 사용하지 않는지 확인한다.

---

## Camera Stack

URP Camera Stack은 Base Camera 결과 위에 Overlay Camera를 합성한다.

```text
Base Camera
→ Overlay Camera A
→ Overlay Camera B
→ Final Target
```

Camera를 나눈다고 동일 Pixel의 이전 작업이 사라지는 것은 아니다.

Clear와 Intermediate Texture, Post-processing 설정에 따라 Pixel 처리와 Blit이 추가될 수 있다.

Layer 구조가 필요해 Camera를 사용하더라도 각 Camera가 화면의 어느 비율을 다시 그리는지 측정한다.

---

## UI와 Fill Rate

UI는 Screen Space의 넓은 Transparent Quad를 여러 Layer로 겹치기 쉽다.

```text
Background
→ Fullscreen Dim
→ Window
→ Image
→ Text Shadow
→ Text
```

Triangle 수가 적어도 높은 Resolution에서 Alpha Blend를 반복하므로 Fill-rate Bound가 될 수 있다.

Alpha 0 Graphic, 투명 Padding과 중복 Panel을 제거하고 실제 조합 상태의 Overdraw를 확인한다.

Canvas Rebuild CPU 비용과 UI Fragment GPU 비용은 별도로 측정한다.

---

## Particle와 Fill Rate

Particle는 큰 Billboard와 부드러운 Alpha Texture가 겹친다.

```text
Particle Fill Cost
≈ Alive Count
× Screen Size
× Overlap
× Shader Cost
```

Particle 개수가 적어도 Camera 가까운 Smoke가 Fullscreen을 덮으면 Fill 부담이 클 수 있다.

Emission보다 Maximum Size와 낮은 Alpha의 긴 Lifetime Tail을 줄였을 때 GPU 시간이 더 크게 감소할 수 있다.

---

## Decal과 Overlay

Screen Space Decal, Selection Highlight와 Damage Overlay는 기존 Scene 위에 Pixel 작업을 추가한다.

```text
Opaque Scene
→ Decal
→ Highlight
→ Damage Overlay
```

작은 Object를 강조하기 위해 Fullscreen Shader를 실행하면 실제 효과 영역보다 넓은 Pixel을 처리할 수 있다.

Object Space Mesh, Scissor, Stencil 또는 낮은 Resolution Buffer로 작업 범위를 제한할 수 있는지 검토한다.

---

## Tile-based GPU

Mobile에서 흔한 Tile-based GPU는 화면을 작은 Tile로 나눠 On-chip Memory에서 Rendering을 처리한다.

```text
Screen
├─ Tile 0
├─ Tile 1
├─ Tile 2
└─ Tile N
```

일부 Color·Depth 작업의 외부 Memory Traffic을 줄일 수 있지만 Fragment Shader, Texture Sample과 Blend가 무료가 되는 것은 아니다.

Render Pass 사이에 Buffer를 Store하고 다시 Load하거나 불필요한 Intermediate Texture를 사용하면 Tile 이점을 잃을 수 있다.

Platform GPU의 Tile Memory와 Render Pass 구성에 따라 같은 Effect 비용이 달라질 수 있다.

---

## Immediate-mode GPU

Desktop에서 흔한 Immediate-mode Rendering 구조는 Triangle 작업을 순서대로 처리하며 큰 Cache와 Memory Bandwidth를 활용한다.

높은 이론적 Fill Rate가 있어도 4K Resolution, 복잡한 Shader, Ray Tracing과 Post-processing이 결합하면 Pixel 병목이 발생할 수 있다.

```text
강한 Desktop GPU
≠ Fill Rate 무제한
```

Desktop 결과만으로 Mobile과 Console 성능을 추정하지 않는다.

각 Architecture와 Graphics API의 Counter를 지원 도구로 확인한다.

---

## XR의 Fill Rate

XR은 왼쪽과 오른쪽 Eye View를 Rendering한다.

```text
Left Eye Pixels
+ Right Eye Pixels
= Stereo Pixel Work
```

Single Pass Instanced는 CPU Submission과 일부 Vertex 작업을 효율화할 수 있지만 두 Eye의 Pixel Coverage 자체가 없어지지는 않는다.

높은 Headset Resolution과 Refresh Rate는 초당 필요한 Pixel 처리량을 크게 높인다.

Foveated Rendering, Eye Texture Resolution과 Dynamic Resolution은 XR Fill Rate 관리에 중요하다.

---

## Frame Rate와 초당 Fill 요구량

같은 Frame을 30 FPS와 120 FPS로 Rendering하면 초당 Pixel 작업 요구량이 네 배 차이 날 수 있다.

```text
Frame당 20M Pixel Operations

30 FPS  → 600M Operations/s
60 FPS  → 1.2B Operations/s
120 FPS → 2.4B Operations/s
```

목표 Frame Rate가 높을수록 한 Frame에 허용되는 GPU 시간도 짧다.

```text
30 FPS  → 약 33.3 ms
60 FPS  → 약 16.7 ms
120 FPS → 약 8.3 ms
```

Fill Rate Budget은 Resolution과 Effect뿐 아니라 목표 Refresh Rate를 기준으로 정해야 한다.

---

## 이론적 사양만 비교하면 안 되는 이유

GPU 제조사의 Fill Rate 수치는 Architecture와 측정 조건이 다를 수 있다.

```text
실제 성능 변수
├─ Clock 유지 여부
├─ Thermal·Power Limit
├─ Shader Compiler
├─ Texture Cache
├─ Memory Bandwidth
├─ Blend·Format
├─ Driver
└─ 다른 Pipeline 병목
```

이론적 GPixel/s가 두 배인 GPU가 특정 Unity Scene에서 정확히 두 배 빠르다는 보장은 없다.

사양은 대략적인 상한 비교에 사용하고 최종 결정은 동일 Build와 동일 Scene의 GPU Frame Time으로 내린다.

---

## Fill-rate Bound의 증상

다음 현상은 Pixel 처리 병목의 후보가 될 수 있다.

```text
Resolution을 낮추면 GPU 시간이 크게 감소
Fullscreen Effect를 끄면 즉시 개선
Transparent Layer가 겹치는 화면에서만 느림
Camera가 Smoke에 가까워질수록 느림
간단한 Unlit Shader로 바꾸면 개선
MSAA·HDR를 낮추면 개선
```

이 중 하나만으로 Fill-rate Bound라고 확정할 수는 없다.

여러 A/B Test와 GPU Counter에서 Fragment, Texture, Bandwidth 사용률을 함께 확인한다.

---

## Resolution A/B Test

Scene, Camera와 Gameplay 상태를 고정하고 내부 Rendering Resolution만 변경한다.

```text
Test A: Render Scale 1.0
Test B: Render Scale 0.75
Test C: Render Scale 0.5
```

각 축을 절반으로 줄이면 Pixel 수는 약 1/4이 된다.

GPU 시간이 큰 폭으로 감소하면 Fragment, Post-processing 또는 Bandwidth 병목 가능성이 높다.

변화가 작으면 CPU, Vertex, Geometry, Simulation이나 Fixed-cost Pass를 의심한다.

UI가 별도 Resolution으로 Rendering되면 Test에서 제외될 수 있으므로 Render Target 크기를 확인한다.

---

## Shader Complexity A/B Test

비싼 Material을 단순 Unlit Shader로 임시 교체한다.

```text
Baseline Lit Shader
vs
Solid Color Unlit Shader
```

Geometry와 Coverage를 그대로 유지한 채 GPU 시간이 크게 줄면 Fragment Shader 연산이나 Texture Sample이 주요 원인일 수 있다.

결과가 거의 같으면 Blend, Bandwidth, Fixed Pass나 다른 Effect 비중이 더 클 수 있다.

최종 Asset을 변경하기 전 진단용 Material로 원인만 분리한다.

---

## Overdraw A/B Test

Transparent Particle, UI와 Decal Layer를 그룹별로 끈다.

```text
Baseline
→ Particle Off
→ UI Overlay Off
→ Decal Off
→ Fullscreen Fog Off
```

하나씩 끌 때 GPU 시간이 얼마나 변하는지 기록한다.

Layer를 모두 동시에 끄면 어느 그룹이 병목인지 구분하기 어렵다.

Overdraw View에서 밝은 영역을 찾고 실제 GPU Time 변화로 우선순위를 결정한다.

---

## Bandwidth A/B Test

가능한 범위에서 HDR, MSAA, Render Target Format과 Intermediate Texture 설정을 비교한다.

```text
HDR On / Off
MSAA 4× / Off
Opaque Texture On / Off
Post-processing On / Off
```

Visual Quality와 Pipeline 기능이 바뀌므로 최종 설정을 바로 결정하는 Test가 아니라 병목 원인을 분리하는 Test다.

Format이나 MSAA 변경에 GPU 시간이 크게 반응하면 Color·Depth Storage와 Bandwidth가 중요할 수 있다.

---

## Frame Debugger

Frame Debugger는 Frame이 Render Target을 몇 번 채우는지 확인하는 데 유용하다.

```text
확인 항목
├─ Depth Prepass
├─ Opaque Pass
├─ Transparent Pass
├─ Shadow Map Pass
├─ Copy Color·Depth
├─ Post-processing Pass
├─ UI Pass
└─ Final Blit
```

각 Event의 Render Target 크기, Shader Pass와 Blend State를 확인한다.

Frame Debugger는 GPU 처리량을 직접 측정하지 않으므로 구조를 이해한 뒤 Profiler로 시간을 비교한다.

---

## Rendering Debugger

URP Rendering Debugger는 Material, Lighting, Rendering Feature와 Overdraw 관련 상태를 시각적으로 분석하는 데 도움을 준다.

Fullscreen Debug Mode와 Wireframe·Overdraw 계열 View를 이용해 넓은 Coverage와 중첩 영역을 찾는다.

```text
시각화
→ 병목 후보 위치 발견
→ Frame Debugger로 Pass 확인
→ GPU Profiler로 시간 검증
```

Debug View의 색이나 밝기를 정확한 ms로 해석하지 않는다.

---

## GPU Profiler

GPU Usage Profiler Module에서 Pass별 GPU 시간을 확인한다.

```text
GPU Frame
├─ Shadows       1.2 ms
├─ Opaque        3.0 ms
├─ Transparent   4.5 ms
├─ PostProcess   2.8 ms
└─ UI            1.0 ms
```

Resolution을 바꾸며 어떤 Pass 시간이 비례해서 변하는지 비교한다.

Profiler Marker와 GPU Timing 지원 범위는 Graphics API와 Platform에 따라 다를 수 있다.

Editor Overhead를 줄이기 위해 Development Build와 Target Device에서 측정한다.

---

## GPU Hardware Counter

Platform Profiler와 GPU Vendor Tool은 Fragment Activity, Texture Unit, Bandwidth, Tile와 Cache Counter를 제공할 수 있다.

```text
Counter 후보
├─ Fragment Shader Busy
├─ Texture Unit Busy
├─ Color Write Throughput
├─ Memory Bandwidth
├─ Early-Z Kill Rate
└─ Overdraw·Samples per Pixel
```

Counter 이름과 의미는 GPU마다 다르다.

한 Counter의 비율만 보지 말고 Pipeline의 다른 Unit이 Idle인지, Resolution 변경에 어떻게 반응하는지 함께 본다.

---

## RenderDoc

RenderDoc Capture에서 Draw별 Render Target, Pipeline State, Texture와 Shader를 확인한다.

Pixel History는 선택한 Pixel에 어떤 Draw가 Color·Depth를 기록했는지 보여 줄 수 있다.

```text
Pixel History
├─ Opaque Surface
├─ Decal
├─ Smoke A
├─ Smoke B
├─ Color Grading
└─ UI
```

같은 위치의 반복 작업을 찾고 각 Draw의 Blend와 Shader Resource를 연결한다.

지원하지 않는 Target Platform에서는 Vendor Capture Tool을 사용한다.

---

## Fill Rate를 줄이는 기본 방향

Pixel 작업의 네 가지 축을 줄인다.

```text
1. Pixel 수
   └─ Resolution · Render Scale

2. 반복 횟수
   └─ Overdraw · Pass · Camera

3. Fragment당 비용
   └─ Shader · Texture Sample · Lighting

4. Pixel당 Data 이동
   └─ Format · Blend · MRT · MSAA
```

어느 축이 병목인지 먼저 진단해야 품질 손실이 적은 변경을 선택할 수 있다.

---

## Screen Coverage 줄이기

Particle, Decal과 UI의 Mesh가 실제 보이는 영역보다 큰지 확인한다.

```text
Large Transparent Quad
→ Texture 중앙에 작은 Effect

Tight Coverage
→ 필요한 영역만 Rasterize
```

Texture의 투명 Padding, Particle Maximum Size와 Fullscreen Panel 중복을 줄인다.

화면 면적이 큰 요소부터 변경해야 Fragment 감소 효과가 크다.

---

## Pass 수 줄이기

같은 화면을 반복 처리하는 Feature를 확인한다.

```text
중복 후보
├─ 여러 Fullscreen Blit
├─ Camera Stack
├─ Depth·Color Copy
├─ Blur Iteration
├─ Shadow Cascade
└─ Multi-pass Material
```

Renderer Feature를 하나씩 비활성화해 GPU 시간과 시각 결과를 비교한다.

Pass를 합치는 최적화는 Render Graph, Load·Store와 Shader Variant에 영향을 줄 수 있어 Pipeline 수준의 검증이 필요하다.

---

## Shader 단순화

화면을 넓게 덮는 Material부터 Texture Sample과 Feature를 줄인다.

```text
검토 항목
├─ 사용하지 않는 Normal Map
├─ Additional Light
├─ Shadow Receive
├─ High-quality Noise
├─ Multi-sample Blur
├─ Complex Branch
└─ 불필요한 Precision
```

작은 Object의 복잡한 Shader보다 Fullscreen Effect의 Sample 하나를 줄이는 편이 전체 Fragment 작업에 더 큰 영향을 줄 수 있다.

Mobile에서는 적절한 Numeric Precision도 성능과 품질에 영향을 줄 수 있다.

---

## 낮은 Resolution Buffer

Blur, Fog, Distortion과 일부 Lighting Effect는 낮은 Resolution Render Target에서 처리할 수 있다.

```text
Full Resolution
1920 × 1080 = 2,073,600 Pixels

Half Resolution per Axis
960 × 540 = 518,400 Pixels
```

Pixel 수는 약 1/4이지만 Downsample, Upsample과 Composite Pass가 추가된다.

Edge 품질, Temporal Stability와 작은 Detail 손실을 Target Device에서 비교한다.

---

## 최적화의 Trade-off

Fill Rate를 낮추는 변경은 다른 비용을 늘릴 수 있다.

| 변경 | 기대 효과 | 가능한 비용 |
|---|---|---|
| Tight Mesh | 투명 Coverage 감소 | Vertex 수 증가 |
| Depth Prepass | Color Overdraw 감소 | Draw·Vertex·Depth 증가 |
| Half-resolution Effect | Pixel 수 감소 | Upsample·Artifact |
| Alpha Clip | Blend 감소 가능 | Alias·discard 비용 |
| Pass 통합 | Intermediate Write 감소 | Shader 복잡도 증가 |
| Render Scale 감소 | 전체 Pixel 감소 | 화질 저하·Upscaling |

GPU Architecture와 Scene에 따라 손익분기점이 다르므로 일반 규칙으로 단정하지 않는다.

---

## 흔한 오해

### Fill Rate는 해상도와 같다

해상도는 기본 Pixel 수이고 Fill Rate 요구량은 Overdraw, Shader, Pass와 Buffer Format까지 포함한다.

### 화면 Pixel은 Frame마다 한 번만 그린다

Opaque, Transparent, Post-processing과 UI가 같은 위치를 여러 Render Target에서 반복 처리할 수 있다.

### 제조사 GPixel/s가 실제 Game 성능이다

이론적 최대 출력량이며 Shader, Texture, Bandwidth와 Clock 조건에 따라 실효 성능은 달라진다.

### Triangle이 적으면 Fill Rate도 낮다

Fullscreen Triangle 하나도 화면 전체 Fragment를 만들 수 있다.

### Draw Call을 줄이면 Fill Rate도 줄어든다

하나의 Draw 안에서도 많은 Triangle과 Layer가 같은 Pixel을 반복 처리할 수 있다.

### Overdraw가 같으면 GPU 시간도 같다

Fragment Shader와 Blend, Texture Sample이 다르면 Layer당 비용이 다르다.

### Alpha 0은 Pixel 작업이 없다

Alpha를 계산하기 위해 Fragment Shader와 Texture Sample이 이미 실행될 수 있다.

### Dynamic Resolution은 모든 병목을 해결한다

Pixel·Bandwidth 병목에는 효과적이지만 CPU, Draw Call, Vertex와 Simulation 병목에는 영향이 작다.

### Depth Prepass는 항상 Fill Rate를 개선한다

Color Overdraw를 줄이는 대신 Geometry와 Depth Pass 비용을 추가한다.

### Tile-based GPU에서는 Overdraw가 무료다

On-chip Tile Memory가 외부 Traffic을 줄여도 Fragment Shader와 Texture·Blend 작업은 남는다.

### Post-processing 하나는 Pass 하나다

Effect 내부에서 Downsample, Blur, Upsample과 Composite Pass가 여러 번 실행될 수 있다.

---

## 최종 체크리스트

```text
□ Target Resolution과 목표 FPS를 기준으로 측정했는가?
□ Backbuffer 외 Intermediate Render Target를 확인했는가?
□ 평균·Peak Overdraw 영역을 확인했는가?
□ 화면을 넓게 덮는 Shader의 Sample 수를 확인했는가?
□ Transparent Blend Layer가 과도하지 않은가?
□ HDR Render Target가 필요한 Pass에만 사용되는가?
□ MSAA Level별 GPU 시간을 비교했는가?
□ Depth Prepass의 Color 절감과 Geometry 비용을 비교했는가?
□ Deferred MRT의 Buffer Format과 Bandwidth를 확인했는가?
□ Fullscreen Post-processing Pass 수를 확인했는가?
□ Blur·Bloom을 낮은 Resolution에서 처리할 수 있는가?
□ Shadow Atlas와 Cascade Fill 비용을 확인했는가?
□ Reflection·Portal Camera Resolution이 과도하지 않은가?
□ Camera Stack의 추가 Clear·Blit을 확인했는가?
□ UI와 Particle의 Fullscreen Coverage를 확인했는가?
□ Resolution A/B Test에서 GPU 시간 변화를 기록했는가?
□ 단순 Shader A/B Test를 수행했는가?
□ Overdraw Layer를 하나씩 끄며 비교했는가?
□ HDR·MSAA·Format의 Bandwidth 영향을 비교했는가?
□ Frame Debugger에서 모든 Render Pass를 확인했는가?
□ GPU Profiler와 Hardware Counter로 병목을 검증했는가?
□ Editor가 아닌 Target Device에서 측정했는가?
```

---

## 정리

Fill Rate는 GPU가 일정 시간 동안 Fragment를 처리하고 Render Target Pixel을 채울 수 있는 능력이며 화면 해상도 이상의 개념이다.

실제 Pixel 작업량은 Resolution에 Overdraw와 Pass 수가 곱해지고, 각 Fragment의 Shader·Texture Sample·Blend 비용과 Render Target Data 크기가 더해져 결정된다.

이론적 Pixel Fill Rate와 Texel Fill Rate는 GPU의 최대 처리량을 비교하는 지표지만 Cache, Memory Bandwidth, Clock과 Pipeline 병목 때문에 실제 Game 성능을 그대로 나타내지 않는다.

Depth와 Early-Z는 Opaque Color Overdraw를 줄일 수 있지만 Transparent, UI와 Particle는 Layer마다 Fragment와 Blend를 반복하기 쉽다.

Post-processing, MRT, Shadow Map, Reflection Camera와 Camera Stack은 Backbuffer 밖의 Render Target에도 Pixel Fill 작업을 추가한다.

Resolution, Shader Complexity, Overdraw와 Buffer 설정을 하나씩 바꾸는 A/B Test로 Fragment 연산, Texture, Blend와 Bandwidth 병목을 분리해야 한다.

Frame Debugger로 Pass와 Render Target 구조를 확인하고 GPU Profiler·Hardware Counter를 이용해 Target Device에서 실제 Fill-rate Bound 여부를 검증해야 한다.
