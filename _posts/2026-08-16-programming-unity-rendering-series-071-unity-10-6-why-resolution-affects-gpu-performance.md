---
title: "[Unity 렌더링] 10-6. 해상도가 GPU 성능에 영향을 주는 이유는 무엇일까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - Resolution
  - FillRate
  - Optimization
permalink: /programming/unity-10-6-why-resolution-affects-gpu-performance/
toc: true
toc_sticky: true
date: 2026-08-16
last_modified_at: 2026-08-16
---

화면 해상도가 높아지면 GPU가 한 Frame에 처리해야 하는 Pixel 수가 증가한다.

```text
1280 × 720
→   921,600 Pixels

1920 × 1080
→ 2,073,600 Pixels

3840 × 2160
→ 8,294,400 Pixels
```

Pixel마다 Fragment Shader, Texture Sample, Depth·Color 처리와 Post-processing이 실행될 수 있으므로 해상도는 GPU Frame Time에 직접 영향을 준다.

하지만 모든 Rendering 단계가 해상도에 같은 비율로 증가하는 것은 아니며 CPU나 Vertex 병목에서는 해상도를 낮춰도 성능 변화가 작을 수 있다.

---

## 해상도는 가로와 세로 Pixel 수다

`1920 × 1080`은 화면의 가로에 1920개, 세로에 1080개의 Pixel 위치가 있다는 뜻이다.

```text
Total Pixels
= Width × Height
```

```text
1920 × 1080
= 2,073,600 Pixels
```

해상도의 한 축만 비교하면 실제 Pixel 증가량을 잘못 판단하기 쉽다.

가로와 세로가 모두 증가하므로 전체 Pixel 수는 두 배가 아니라 면적 비율로 변한다.

---

## 1080p에서 4K는 네 배다

4K UHD의 각 축은 1080p의 두 배다.

```text
1920 × 1080
        ↓ 각 축 2배
3840 × 2160
```

전체 Pixel 수는 가로 배율과 세로 배율을 곱한다.

```text
2 × 2 = 4
```

| Resolution | Pixel 수 | 1080p 대비 |
|---|---:|---:|
| 1920 × 1080 | 2,073,600 | 1.00× |
| 2560 × 1440 | 3,686,400 | 1.78× |
| 3840 × 2160 | 8,294,400 | 4.00× |

같은 화면을 같은 Shader로 그려도 4K는 기본적으로 훨씬 많은 Fragment 후보와 Buffer Data를 처리한다.

---

## Resolution Scale의 제곱 관계

가로와 세로를 같은 비율로 조절하면 Pixel 수는 Scale의 제곱에 비례한다.

```text
Pixel Ratio
= Width Scale × Height Scale
```

| 각 축 Scale | Pixel 비율 | Pixel 감소량 |
|---:|---:|---:|
| 1.00 | 100% | 0% |
| 0.90 | 81% | 19% |
| 0.80 | 64% | 36% |
| 0.75 | 56.25% | 43.75% |
| 0.50 | 25% | 75% |

Render Scale을 `0.8`로 낮추면 각 축은 20%만 줄지만 Pixel 수는 36% 줄어든다.

해상도 조절이 Fragment 병목에 강한 효과를 낼 수 있는 이유다.

---

## GPU Rendering Pipeline에서 증가하는 작업

해상도는 주로 Rasterization 이후의 Screen Space 작업에 영향을 준다.

```text
Vertex Processing
  │  Object·Vertex 수 중심
  ▼
Rasterization
  │  Screen Coverage에 따라 Fragment 생성
  ▼
Fragment Shader
  │  Pixel 후보마다 계산
  ▼
Depth·Stencil·Blend
  │  Sample과 Pixel 처리
  ▼
Render Target Write
```

같은 Mesh를 같은 Camera로 그리면 Vertex 수는 해상도가 바뀌어도 대체로 같다.

반면 Triangle이 덮는 Pixel 수는 해상도에 따라 증가한다.

---

## Vertex Shader는 해상도에 직접 비례하지 않는다

Mesh의 Vertex 수가 100,000개라면 720p와 4K에서도 기본적으로 같은 Vertex를 변환한다.

```text
720p  → 100,000 Vertices
4K    → 100,000 Vertices
```

Camera Culling, LOD와 Tessellation 설정이 같다는 가정이다.

따라서 Vertex Processing이 병목인 Scene은 해상도를 낮춰도 GPU 시간이 크게 줄지 않을 수 있다.

다만 Screen Size 기반 LOD, Tessellation과 Particle Size 정책이 해상도에 따라 달라지면 간접적인 변화가 생길 수 있다.

---

## Rasterization은 Screen Coverage에 영향을 받는다

Rasterizer는 Triangle이 화면에서 덮는 Pixel 위치에 Fragment 후보를 만든다.

```text
같은 Triangle

낮은 해상도          높은 해상도
┌──────┐             ┌────────────┐
│  /   │             │      /     │
│ /    │             │    /       │
└──────┘             └────────────┘

덮는 Pixel 수 증가
```

화면의 절반을 덮는 Wall은 Resolution이 네 배가 되면 대략 네 배 많은 Pixel 위치를 덮는다.

Triangle 개수는 같아도 Fragment 수가 늘 수 있다.

---

## Fragment Shader가 반복된다

Fragment Shader는 Rasterization으로 생성된 Fragment에서 Material Color를 계산한다.

```text
Fragment Shader
├─ Base Map Sample
├─ Normal Map Sample
├─ Lighting
├─ Shadow Sample
├─ Fog
└─ Color Output
```

해상도가 높아져 Fragment 수가 증가하면 이 연산도 더 많은 위치에서 실행된다.

복잡한 Shader일수록 추가 Pixel 하나의 비용이 크다.

```text
GPU Pixel Cost
≈ Fragment 수 × Fragment당 Shader 비용
```

---

## Texture Sample도 증가한다

Fragment마다 Texture를 네 번 Sample하는 Shader가 있다고 가정한다.

```text
1080p Fullscreen
≈ 2.07M Fragments × 4 Samples
≈ 8.29M Samples

4K Fullscreen
≈ 8.29M Fragments × 4 Samples
≈ 33.18M Samples
```

Overdraw와 Multi-pass가 없다면 단순화한 계산이다.

실제 Scene에서는 Cache, Filtering, Mipmap, Branch와 Early-Z 때문에 결과가 달라진다.

해상도 증가가 Texture Unit과 Memory Bandwidth 부담까지 높인다는 관계가 중요하다.

---

## Mipmap과 해상도

Texture Mipmap은 화면에서 Texture가 작게 보일 때 낮은 해상도 Level을 Sample한다.

```text
Mip 0: 1024 × 1024
Mip 1:  512 × 512
Mip 2:  256 × 256
Mip 3:  128 × 128
```

Rendering Resolution이 높아지면 같은 Surface에 더 많은 Screen Pixel이 배정되고 더 높은 Detail Mip을 선택할 수 있다.

이로 인해 Fragment 수뿐 아니라 Texture Cache와 Memory Access Pattern도 바뀔 수 있다.

Mip Bias와 Texture Streaming 설정은 화질과 Memory Bandwidth에 함께 영향을 준다.

---

## Depth Buffer도 해상도를 가진다

Depth Buffer는 일반적으로 Render Target와 같은 또는 관련된 Resolution으로 각 Pixel의 깊이를 저장한다.

```text
Color Buffer
1920 × 1080

Depth Buffer
1920 × 1080
```

해상도가 높아지면 Depth Clear, Depth Test, Depth Write와 Memory 용량도 증가한다.

Depth Prepass를 사용하면 높은 해상도의 Depth Buffer를 먼저 채우고 Color Pass에서 다시 읽는다.

Early-Z로 비싼 Color Shader를 줄일 수 있지만 Depth 작업 자체는 Pixel 수에 영향을 받는다.

---

## Stencil Buffer

Stencil은 Mask, Portal, Deferred Lighting과 UI Clipping에 사용할 수 있다.

Depth와 결합된 Depth-Stencil Format을 쓰는 경우가 많다.

```text
Depth-Stencil Pixel
├─ Depth Value
└─ Stencil Bits
```

해상도가 높아지면 Stencil Clear, Test와 Write 대상도 늘어난다.

화면 전체 Stencil Mask를 여러 번 작성하는 Effect는 높은 Resolution에서 비용이 커질 수 있다.

---

## Color Buffer 크기

Render Target Memory는 Resolution과 Pixel Format에 영향을 받는다.

```text
Buffer Size
≈ Width × Height × Bytes per Pixel
```

RGBA8 Buffer 하나를 단순 계산한다.

```text
1920 × 1080 × 4 Bytes
≈ 8.29 MB

3840 × 2160 × 4 Bytes
≈ 33.18 MB
```

실제 Allocation은 Alignment, Tiling, Compression과 Platform 구현에 따라 달라질 수 있다.

HDR Format, Double Buffer와 여러 Intermediate Texture가 있으면 Memory 요구량이 더 커진다.

---

## HDR Render Target

HDR Rendering은 넓은 밝기 범위를 저장하기 위해 더 큰 Color Format을 사용할 수 있다.

```text
LDR 예시
RGBA8

HDR 예시
RGBA16F 또는 Pipeline별 HDR Format
```

Pixel당 Data가 커지면 높은 해상도에서 Render Target Memory와 Bandwidth 부담이 더 크게 증가한다.

HDR Color를 Copy하거나 여러 Post-processing Pass에서 읽고 쓰면 부담이 반복된다.

HDR 품질이 필요한 Camera와 Effect 범위를 구분해야 한다.

---

## Memory Bandwidth

GPU는 Fragment 처리 중 Texture, Depth와 Color Buffer를 읽고 쓴다.

```text
Per-pixel Traffic
├─ Texture Read
├─ Depth Read
├─ Depth Write
├─ Destination Color Read
└─ Result Color Write
```

Resolution이 높아지면 Pixel당 Data 이동이 같은 경우에도 전체 Traffic이 증가한다.

GPU 연산 Unit에 여유가 있어도 Memory Bandwidth가 한계에 도달하면 Frame Time이 늘어난다.

Mobile과 Integrated GPU에서는 CPU와 Memory 대역폭을 공유할 수 있어 더 민감할 수 있다.

---

## Overdraw가 해상도 증가를 증폭한다

화면 Pixel 수가 네 배이고 평균 Overdraw도 같다면 Fragment 후보 수도 대략 네 배가 된다.

```text
1080p, Average Overdraw 4×
≈ 2.07M × 4
≈ 8.29M Fragment Positions

4K, Average Overdraw 4×
≈ 8.29M × 4
≈ 33.18M Fragment Positions
```

Transparent Particle, UI와 Fog처럼 Early-Z로 제거하기 어려운 Layer에서는 증가가 실제 Shader와 Blend 작업으로 연결되기 쉽다.

고해상도 Target에서 Overdraw 최적화 중요도가 커지는 이유다.

---

## Transparent Blend

Transparent Fragment는 기존 Color와 자신의 Color를 혼합한다.

```text
Destination Color Read
+ Source Color
→ Blend
→ Result Write
```

해상도가 높아지면 넓은 Transparent Layer의 Read·Modify·Write 위치가 증가한다.

Fullscreen UI Panel, Smoke와 Screen Overlay가 여러 장 겹치면 Resolution과 Layer 수가 함께 비용을 키운다.

Alpha가 낮거나 0에 가까워도 Fragment가 제출되면 Pixel 처리 자체는 남을 수 있다.

---

## Opaque와 Early-Z

Opaque Surface는 Depth Write와 Early-Z를 이용해 가려진 Fragment Shader 실행을 줄일 수 있다.

```text
Near Surface Depth 기록
→ Far Surface Depth Test Fail
→ Far Fragment Shader 생략 가능
```

해상도가 높아지면 Depth Test 대상은 늘지만 비싼 Color Overdraw가 제거되면 증가 폭을 완화할 수 있다.

Front-to-Back Sorting, Occlusion과 Depth Prepass가 Resolution에 따른 Opaque Fragment 부담을 줄이는 데 기여할 수 있다.

모든 비용이 사라지는 것은 아니므로 실제 GPU Profile이 필요하다.

---

## Post-processing은 Screen Space 작업이다

많은 Post-processing Effect는 Camera Color 전체를 입력으로 사용한다.

```text
Camera Color
→ Bloom
→ Color Grading
→ Vignette
→ Anti-aliasing
→ Final Output
```

각 Pass는 Resolution에 비례하는 Texture Read와 Render Target Write를 만들 수 있다.

4K에서 Opaque Scene이 충분히 빠르더라도 여러 Fullscreen Pass가 병목이 될 수 있다.

Volume Component 수가 아니라 실제 Render Pass와 Buffer Resolution을 확인한다.

---

## Bloom과 Resolution Pyramid

Bloom은 화면을 Downsample해 여러 Resolution Level을 만들 수 있다.

```text
Full
→ 1/2 Width·Height
→ 1/4
→ 1/8
→ Blur
→ Upsample
→ Composite
```

낮은 Level을 사용하더라도 시작 Source와 Composite는 높은 Resolution에 영향을 받는다.

Output Resolution이 증가하면 Pyramid 각 Level의 Pixel 수도 함께 증가한다.

Bloom Quality와 Iteration을 Target Resolution에서 Profile해야 한다.

---

## Screen Space Reflection과 Ambient Occlusion

Screen Space Effect는 Depth, Normal과 Camera Color를 Screen Grid에서 Sample한다.

```text
SSAO
→ Depth·Normal 주변 Sample

SSR
→ Screen Space Ray Marching
→ 여러 Step Sample
```

Resolution이 높아지면 실행할 Fragment 수가 늘고, Pixel당 여러 Sample·Step도 반복된다.

Half-resolution이나 Checkerboard 방식은 비용을 줄이지만 Noise, Edge와 Temporal Artifact가 생길 수 있다.

Quality, Radius, Step와 Resolution Scale을 함께 조정한다.

---

## Motion Blur와 Depth of Field

Motion Blur는 Motion Vector와 Camera Color를 Sample하고 Depth of Field는 Depth에 따라 Blur를 계산한다.

```text
Motion Blur
├─ Motion Vector Read
├─ Neighbor Samples
└─ Color Write

Depth of Field
├─ Depth Read
├─ Circle of Confusion
├─ Blur Gather
└─ Composite
```

화면 전체에서 여러 Sample을 수행하므로 높은 Resolution의 영향을 크게 받을 수 있다.

낮은 Resolution Intermediate Buffer와 Sample 수 조절은 품질 대비 효과를 Profile해야 한다.

---

## Anti-aliasing과 해상도

Anti-aliasing 방식마다 Resolution과 결합되는 비용이 다르다.

| 방식 | 주요 비용 | Resolution 영향 |
|---|---|---|
| FXAA | Fullscreen Edge Filtering | Pixel 수에 따라 증가 |
| SMAA | Edge·Blend Weight·Resolve | 여러 Screen Space Pass 가능 |
| TAA | History·Motion·Resolve | Buffer Read·Write 증가 |
| MSAA | Multi-sample Color·Depth | Sample Storage·Resolve 증가 |

해상도가 높으면 Alias가 줄어 AA 품질 Level을 낮출 여지가 생길 수 있다.

반대로 고해상도와 높은 MSAA를 동시에 사용하면 Memory와 Sample 비용이 과도할 수 있다.

---

## MSAA Buffer

MSAA는 Pixel 안에 여러 Coverage Sample을 저장한다.

```text
4× MSAA Pixel
├─ Sample 0
├─ Sample 1
├─ Sample 2
└─ Sample 3
```

해상도가 증가하면 Pixel 수와 Multi-sample Storage가 함께 증가한다.

`4× MSAA`가 Shader 비용을 정확히 네 배로 만든다는 뜻은 아니지만 Color·Depth Memory와 Resolve 비용은 커질 수 있다.

Target GPU에서 Resolution과 MSAA Level을 교차 비교한다.

---

## Deferred G-buffer

Deferred Rendering은 Geometry Pass에서 여러 G-buffer에 Material Data를 기록한다.

```text
GBuffer 0: Base Color
GBuffer 1: Normal
GBuffer 2: Material Data
Depth Buffer
```

Resolution이 네 배가 되면 각 Buffer의 Pixel 수와 Memory 사용도 대략 네 배가 된다.

Lighting Pass에서도 G-buffer를 높은 Resolution로 읽는다.

Deferred는 Light가 많은 Scene에 유리할 수 있지만 고해상도에서 MRT Bandwidth와 Memory 부담을 함께 고려해야 한다.

---

## Shadow Resolution은 화면 해상도와 별개다

Shadow Map은 Light 기준의 별도 Resolution을 가진다.

```text
Display Resolution: 1920 × 1080
Shadow Atlas:       2048 × 2048
```

화면 해상도를 낮춰도 Shadow Atlas 크기가 그대로면 Shadow Caster Pass 비용은 크게 변하지 않을 수 있다.

```text
Render Scale 감소
→ Camera Color Pixel 감소
→ Shadow Map Pixel은 유지 가능
```

해상도를 낮췄는데 전체 GPU 시간이 기대만큼 줄지 않는 원인 중 하나다.

---

## Reflection Probe와 Render Texture

Reflection Probe, Planar Reflection, Portal과 Mini Map은 별도 Texture Resolution으로 Rendering한다.

```text
Main Camera: 2560 × 1440
Reflection:  1024 × 1024
Mini Map:     512 × 512
```

Main Camera Render Scale을 변경해도 별도 Render Texture가 고정 크기라면 해당 Pass 비용은 유지된다.

각 Camera와 Probe의 Resolution, Update Mode와 Update Frequency를 별도로 관리한다.

전체 Frame Pixel Budget에는 화면 밖 Buffer도 포함된다.

---

## 출력 해상도와 내부 렌더 해상도

Display에 출력하는 해상도와 3D Scene을 Rendering하는 내부 해상도는 다를 수 있다.

```text
Output Resolution
3840 × 2160

Internal Render Resolution
2560 × 1440

Upscale
→ 3840 × 2160 Output
```

내부 해상도를 낮추면 대부분의 3D Fragment와 Screen Space Effect 비용을 줄일 수 있다.

마지막 Upscale과 UI Composite는 출력 해상도에서 실행될 수 있다.

성능 분석에서는 어떤 Pass가 어느 Resolution에서 실행되는지 구분해야 한다.

---

## Native Resolution

Native Resolution은 Display Panel이 실제로 가진 Pixel Grid를 뜻한다.

내부 Rendering을 Native보다 낮게 하고 확대하면 GPU 비용을 줄이는 대신 Detail과 Edge 선명도가 감소할 수 있다.

```text
Native 4K Display
├─ Native Rendering: 높은 Pixel 비용, 높은 선명도
└─ 1440p + Upscale: 낮은 Pixel 비용, Reconstruction 필요
```

단순 Bilinear Upscale, Spatial Upscaler와 Temporal Upscaler는 품질과 비용이 다르다.

---

## URP Render Scale

URP Asset의 Render Scale은 Pipeline 내부 Rendering Resolution을 조절한다.

```text
Output: 1920 × 1080
Render Scale: 0.75

Internal
≈ 1440 × 810
```

Scale `0.75`의 Pixel 수는 Output의 약 `56.25%`다.

Camera Color, Depth와 일부 Screen Space Pass가 낮은 Resolution을 사용할 수 있다.

Overlay UI, 별도 Render Texture, Shadow Atlas와 Renderer Feature는 동일한 Scale을 따르지 않을 수 있으므로 Frame Debugger에서 확인한다.

---

## Dynamic Resolution

Dynamic Resolution은 GPU 부하에 따라 내부 Rendering Scale을 자동 또는 Script로 조절한다.

```text
GPU Frame Time 증가
→ Scale 낮춤
→ Pixel 수 감소

GPU 여유 증가
→ Scale 높임
→ 화질 회복
```

급격한 Scale 변화는 화면 선명도가 흔들리는 느낌을 줄 수 있다.

Minimum·Maximum Scale, 목표 Frame Time과 Scale 변경 속도를 조정한다.

CPU Bound 상태에서는 Scale을 낮춰도 Frame Rate가 오르지 않으므로 GPU Timing을 기준으로 동작해야 한다.

---

## Spatial Upscaling

Spatial Upscaler는 현재 Frame의 낮은 해상도 Image를 공간 정보로 확대한다.

```text
Low-resolution Current Frame
→ Edge-aware Spatial Reconstruction
→ High-resolution Output
```

History Buffer가 필요하지 않아 단순하고 안정적일 수 있지만 원본에 없는 Subpixel Detail 복원에는 한계가 있다.

낮은 Render Scale에서는 Shimmering, Thin Line 손실과 Blurring이 나타날 수 있다.

Upscaler 자체도 출력 해상도에서 Pixel 작업을 수행한다.

---

## Temporal Upscaling

Temporal Upscaler는 현재 Frame뿐 아니라 이전 Frame, Motion Vector와 Jitter 정보를 이용한다.

```text
Current Low-resolution Color
+ Previous History
+ Motion Vectors
+ Depth
→ Reconstructed Output
```

낮은 내부 Resolution에서도 Detail을 복원할 수 있지만 History 관리, Motion Vector와 Resolve 비용이 추가된다.

빠른 Particle, Transparent Surface, UI와 Disocclusion에서 Ghosting이나 Trail Artifact가 나타날 수 있다.

성능 이득은 줄어든 내부 Pixel 비용에서 Upscaler 비용을 뺀 결과로 판단한다.

---

## UI 해상도

Screen Space Overlay UI는 최종 출력 해상도에서 Rendering될 수 있다.

```text
3D Scene
→ 낮은 Internal Resolution
→ Upscale
→ Native-resolution UI
```

이 구조는 Text와 Icon을 선명하게 유지하지만 Fullscreen UI Panel의 Pixel 비용은 Render Scale로 줄지 않을 수 있다.

Canvas Scaler는 Layout 크기와 좌표를 조절하는 기능이며 GPU Render Target Pixel 수를 자동으로 줄이는 기능은 아니다.

UI Fill-rate 병목은 별도로 Profile해야 한다.

---

## Canvas Scaler와 Reference Resolution

Canvas Scaler의 Reference Resolution은 UI Layout이 다양한 화면 크기에 대응하는 기준이다.

```text
Reference Resolution
1920 × 1080

Actual Display
2560 × 1440
```

이는 UI Element의 상대적인 크기와 Scale을 계산하지만 실제 Display의 Pixel 수를 변경하지 않는다.

```text
Reference Resolution 변경
≠ GPU Rendering Resolution 변경
```

UI Graphic이 화면의 같은 비율을 덮으면 실제 해상도가 높을수록 더 많은 Fragment를 처리할 수 있다.

---

## Pixel Perfect

Pixel Perfect 설정은 UI와 2D Graphic을 Pixel Grid에 맞춰 선명하게 표시하는 데 사용한다.

이는 Pixel Rendering 수를 줄이는 최적화가 아니다.

Pixel Art Project에서는 낮은 내부 Reference Buffer를 Point Filtering으로 확대해 의도한 미학과 성능을 함께 얻을 수 있다.

하지만 일반 고해상도 UI에서 무조건 낮은 Buffer를 사용하면 Text와 Line이 흐려질 수 있다.

---

## 2D Pixel Art Rendering

Pixel Perfect Camera를 사용하는 2D Game은 낮은 Reference Resolution으로 Scene을 Rendering하고 정수 배율로 확대할 수 있다.

```text
Internal: 320 × 180
Scale 6×
Output: 1920 × 1080
```

Scene Pixel 작업은 크게 줄지만 Sprite Atlas, Transparent Overdraw와 UI 처리 구조는 별도로 남는다.

Camera Stack, Post-processing와 UI가 어느 Resolution에 속하는지 확인한다.

---

## Mobile의 Display Resolution

Mobile Device는 작은 화면에도 높은 Native Resolution을 가진 경우가 많다.

```text
작은 Physical Screen
≠ 적은 Pixel 수
```

GPU는 Physical Inch가 아니라 Render Target의 Pixel 수를 처리한다.

QHD·4K급 Panel을 항상 Native Resolution으로 Rendering하면 Mobile GPU의 Bandwidth와 전력 Budget을 크게 사용할 수 있다.

Device 등급에 따라 Render Scale과 Target FPS를 조정하고 실제 화면 크기에서 화질 차이를 비교한다.

---

## Thermal Throttling

해상도가 높으면 초당 Fragment, Texture와 Memory 작업이 늘어 전력 소비와 발열이 증가할 수 있다.

```text
높은 Resolution
→ 높은 GPU 사용률
→ 전력·온도 증가
→ Clock 제한 가능
→ 장시간 Frame Time 증가
```

짧은 30초 Profile에서는 빠르지만 10분 전투 후 성능이 낮아질 수 있다.

Mobile 성능 검증은 Cold 상태와 Sustained 상태를 함께 측정한다.

Dynamic Resolution과 FPS 제한은 지속 성능을 안정시키는 수단이 될 수 있다.

---

## XR Eye Texture Resolution

XR은 두 Eye를 위한 Render Target을 사용하며 Lens 왜곡 후 선명도를 확보하기 위해 Display Panel보다 큰 Eye Texture를 사용할 수 있다.

```text
Left Eye Texture
+ Right Eye Texture
→ Lens Distortion
→ Headset Display
```

Stereo Mode가 Draw Submission을 합쳐도 양쪽 Eye의 Pixel 처리량은 남는다.

Eye Texture Resolution Scale과 Refresh Rate가 GPU Budget에 큰 영향을 준다.

Foveated Rendering과 Dynamic Resolution을 Headset에서 직접 검증한다.

---

## Foveated Rendering

Foveated Rendering은 시선 중심 또는 화면 중심은 높은 Detail로, 주변부는 낮은 Rate로 Rendering한다.

```text
┌────────────────────┐
│ Low                │
│    Medium          │
│       High         │
│              Low   │
└────────────────────┘
```

모든 Pixel을 같은 품질로 처리하지 않아 XR의 Fragment 부담을 줄일 수 있다.

Fixed Foveated와 Eye-tracked Foveated 방식은 Hardware 지원, 품질과 구현이 다르다.

UI와 시선 이동에서 Peripheral Artifact가 눈에 띄지 않는지 확인한다.

---

## 여러 Camera와 해상도

Main Camera 외에 Mini Map, Weapon Camera와 Portal Camera가 있으면 각 Camera가 별도 Pixel을 처리한다.

```text
Frame Pixel Work
= Main Camera
+ Mini Map
+ Reflection
+ Portal
+ UI Camera
```

Main Output Resolution만 낮춰도 고정 크기의 Secondary Render Texture 비용은 그대로일 수 있다.

화면에서 작은 영역에 표시하는 Camera는 낮은 Texture Resolution과 낮은 Update Rate를 사용할 수 있는지 검토한다.

---

## Camera Viewport

Camera가 Render Target 전체가 아니라 작은 Viewport만 그리면 Rasterization과 Pixel 작업 범위를 줄일 수 있다.

```text
Full Render Target
┌────────────────────┐
│                    │
│   Camera Viewport  │
│   ┌──────────┐     │
│   └──────────┘     │
└────────────────────┘
```

하지만 Clear, Post-processing와 Intermediate Texture가 전체 Target에서 실행되는지 Pipeline 동작을 확인해야 한다.

Viewport Rect 크기만으로 모든 Pass 비용이 정확히 줄어든다고 단정할 수 없다.

---

## Editor Game View 해상도

Unity Editor의 Game View 크기와 Scale에 따라 Rendering Resolution이 달라질 수 있다.

작은 Game View에서 빠르다가 Standalone Fullscreen Build에서 느려지는 이유가 될 수 있다.

```text
Editor Game View: 1280 × 720
Player Build:     3840 × 2160
```

Editor 자체 Overhead도 있으므로 Game View 결과만으로 Target 성능을 결정하지 않는다.

Development Build에서 실제 Display Resolution과 Fullscreen Mode를 고정해 Profile한다.

---

## Window Mode와 Retina Display

High-DPI Display에서는 논리적 Window 크기와 실제 Backbuffer Pixel 크기가 다를 수 있다.

```text
Logical Size
1440 × 900 points

Physical Backbuffer
2880 × 1800 pixels 가능
```

Window가 작아 보이더라도 GPU는 더 높은 Pixel Resolution을 Rendering할 수 있다.

Profiler와 Frame Debugger에서 실제 Render Target Width·Height를 확인해야 한다.

---

## Aspect Ratio 변경

같은 세로 Resolution이라도 Aspect Ratio가 넓어지면 가로 Pixel 수와 화면에 보이는 Scene 범위가 증가할 수 있다.

```text
1920 × 1080
2560 × 1080
```

Pixel 수뿐 아니라 Camera Horizontal Field of View와 보이는 Object 수가 달라질 수 있다.

```text
더 넓은 화면
→ 더 많은 Pixel
+ 더 많은 Object·Particle가 Frustum에 포함 가능
```

해상도 Benchmark에서는 Aspect Ratio와 Camera Composition을 고정한다.

---

## 해상도와 LOD

LOD Group은 Object의 Screen 상대 높이를 기준으로 Level을 전환한다.

같은 Camera와 Object 배치에서 단순히 Pixel Resolution만 바꿔도 상대 Screen 비율은 같을 수 있다.

그러나 Dynamic Resolution, DPI와 Custom LOD 정책이 Pixel 단위 Size를 사용하면 선택 결과가 달라질 수 있다.

해상도 A/B Test에서 Triangle 수와 Draw Call이 같은지 함께 확인해야 순수 Fragment 효과를 비교할 수 있다.

---

## 해상도와 Culling

Frustum Culling은 Camera의 View Volume을 기준으로 하므로 같은 Aspect Ratio와 Camera 설정에서는 Resolution과 직접 관련이 작다.

Occlusion Culling도 World Visibility를 기준으로 한다.

```text
Resolution 감소
→ Object 수가 자동으로 감소하는 것은 아님
```

CPU Culling과 Draw Submission이 병목이면 Render Scale을 낮춰도 성능 변화가 작을 수 있다.

---

## CPU 성능은 왜 그대로일 수 있을까?

CPU는 주로 Script, Physics, Animation, Culling과 Draw Call 준비를 수행한다.

```text
CPU Work
├─ Gameplay
├─ Physics
├─ Animation
├─ Culling
├─ Batching
└─ Render Submission
```

해상도를 낮춰도 GameObject 수, Script와 Draw Call이 같으면 CPU Frame Time은 거의 변하지 않을 수 있다.

CPU Bound 상태에서는 GPU에 여유가 생겨도 전체 Frame Rate가 CPU 시간에 제한된다.

---

## GPU Bound와 CPU Bound

Frame Time은 CPU와 GPU 중 더 오래 걸리는 쪽에 제한될 수 있다.

```text
Case A
CPU 8 ms
GPU 18 ms
→ GPU Bound

Case B
CPU 20 ms
GPU 10 ms
→ CPU Bound
```

Case A에서 해상도를 낮춰 GPU가 12ms가 되면 Frame Time이 개선될 수 있다.

Case B에서 GPU를 6ms로 줄여도 CPU가 20ms라면 최종 Frame Rate 변화가 작다.

해상도 옵션 효과를 평가할 때 CPU·GPU Frame Time을 분리한다.

---

## VSync와 Frame Rate Cap

VSync나 Frame Rate 제한이 켜져 있으면 해상도를 낮춰 GPU가 빨라져도 표시 FPS는 그대로일 수 있다.

```text
GPU 12 ms → 8 ms
Frame Cap 60 FPS
→ 표시 FPS는 계속 60
```

성능 개선이 없는 것이 아니라 GPU Headroom, 전력과 온도가 개선됐을 수 있다.

Profiler의 GPU Time과 Utilization을 확인하고 Benchmark 조건에서는 Cap과 VSync 상태를 명시한다.

---

## 해상도를 낮춰도 빨라지지 않는 경우

다음 병목은 Resolution 변화에 민감하지 않을 수 있다.

```text
CPU Script·Physics 병목
Draw Call·State Change 병목
Vertex Shader·Tessellation 병목
Geometry 처리 병목
Shadow Map 고정 Resolution 병목
별도 Render Texture 병목
GPU Synchronization·Wait
Frame Rate Cap·VSync
```

Render Scale을 절반으로 낮췄는데 GPU 시간 변화가 작다면 Pixel Fill보다 다른 단계가 제한하고 있을 가능성이 높다.

해상도를 더 낮추는 대신 해당 Pipeline 단계의 Counter와 Pass 시간을 확인한다.

---

## 해상도를 낮추면 항상 정확히 비례할까?

Pixel 수를 절반으로 줄여도 GPU 시간이 정확히 절반이 되지는 않는다.

```text
GPU Frame Time
= Resolution-dependent Cost
+ Fixed Cost
+ Other Pipeline Cost
```

예를 들어 GPU 16ms 중 Pixel 작업이 8ms이고 나머지가 8ms라면 Pixel 비용을 절반으로 줄여도 전체는 약 12ms가 될 수 있다.

Cache, GPU Occupancy, Upscaler 비용과 Bottleneck 이동도 Scaling을 비선형으로 만든다.

---

## Bottleneck이 이동할 수 있다

처음에는 Fragment Shader가 병목이어도 Resolution을 낮추면 다른 단계가 가장 느려질 수 있다.

```text
Before
Fragment 12 ms
Vertex    4 ms
CPU       6 ms

After Resolution Down
Fragment 5 ms
Vertex   4 ms
CPU      6 ms

→ CPU가 새 제한 요소
```

해상도를 계속 낮춰도 어느 지점부터 Frame Rate 개선이 멈출 수 있다.

최적화 후에는 다시 Profile해 새로운 병목을 찾는다.

---

## 해상도 A/B Test

같은 Build와 Scene에서 내부 Rendering Scale만 바꾼다.

```text
Test A: 100% Scale
Test B: 75% Scale
Test C: 50% Scale
```

다음 조건을 고정한다.

```text
Camera Position
Visible Objects
Quality Level
Shadow Resolution
Post-processing
Target FPS
Effect Timing
```

CPU ms, GPU ms, Pass별 GPU Time과 실제 Render Target Size를 기록한다.

---

## 결과 해석 예

| Scale | Pixel 비율 | CPU ms | GPU ms |
|---:|---:|---:|---:|
| 1.00 | 100% | 7.9 | 18.0 |
| 0.75 | 56% | 7.8 | 12.5 |
| 0.50 | 25% | 7.8 | 9.2 |

GPU 시간은 줄지만 Pixel 비율만큼 정확히 줄지는 않는다.

Fixed-resolution Shadow와 CPU·Vertex·Pass Setup 비용이 남기 때문이다.

이 결과는 Fragment·Bandwidth 비용의 비중이 크지만 전체 GPU 비용은 아니라는 신호다.

실제 값은 Project와 Device마다 다르다.

---

## Frame Debugger로 Resolution 확인

Frame Debugger에서 Event마다 어떤 Render Target를 사용하는지 확인한다.

```text
확인 항목
├─ Camera Color Width·Height
├─ Depth Texture Width·Height
├─ Opaque Texture
├─ Shadow Atlas
├─ Post-process Intermediate
├─ UI Target
└─ Final Backbuffer
```

Render Scale을 낮췄는데 특정 Renderer Feature의 Texture가 여전히 Full Resolution일 수 있다.

Pass 이름만 보지 말고 실제 Resource 크기를 확인해야 한다.

---

## GPU Profiler로 Pass별 Scaling 확인

해상도를 바꾸며 Pass별 GPU 시간이 어떻게 변하는지 비교한다.

```text
Opaque       5.0 → 2.8 ms
Transparent  4.0 → 2.1 ms
PostProcess  3.0 → 1.8 ms
Shadow       2.0 → 1.9 ms
```

Shadow 시간이 거의 같은 것은 Shadow Atlas Resolution이 고정이기 때문일 수 있다.

Opaque와 Transparent가 크게 줄면 Camera Pixel 처리 비중이 높다는 뜻이다.

Editor가 아닌 Target Device의 GPU Marker를 기준으로 한다.

---

## RenderDoc에서 Resource 확인

GPU Capture에서 Render Target와 Texture Resource의 Width, Height, Format과 Sample Count를 확인한다.

```text
Resource
├─ 2560 × 1440
├─ RGBA16F
├─ MSAA 4×
└─ Render Target + Shader Resource
```

예상보다 큰 Intermediate Texture, 불필요한 HDR Format과 Full-resolution Blur Buffer를 찾을 수 있다.

Draw별 Viewport와 Scissor가 Resource 전체를 실제로 덮는지도 확인한다.

---

## 해상도 옵션 설계

사용자에게 Display Resolution과 Render Scale을 구분해 제공할 수 있다.

```text
Display Resolution
→ Window·Backbuffer 크기

Render Scale
→ 내부 3D Rendering 크기

Upscaling Quality
→ 확대 방식과 품질
```

Text와 UI 선명도를 유지하면서 3D GPU 비용을 줄이려면 Native Output에 낮은 Internal Resolution을 조합할 수 있다.

설정 이름과 실제 효과를 명확히 표시해야 사용자가 품질·성능 Trade-off를 이해할 수 있다.

---

## Device 등급별 기본값

GPU 성능과 Display Resolution을 함께 고려해 기본 Render Scale을 정한다.

```text
Low Tier
├─ 낮은 Render Scale
├─ 낮은 Shadow Resolution
└─ 단순 Post-processing

High Tier
├─ Native에 가까운 Scale
├─ 높은 Shadow Quality
└─ 고급 Upscaler
```

Screen DPI만으로 GPU 등급을 추정하면 안 된다.

같은 Resolution의 Device도 GPU Architecture, Bandwidth와 Thermal Budget이 다르다.

실제 Device Profile과 Runtime GPU Timing을 기준으로 조정한다.

---

## 해상도 최적화의 우선순위

해상도를 낮추기 전에 불필요한 Pixel 작업을 먼저 찾는다.

```text
1. 중복 Fullscreen Pass 제거
2. Transparent Overdraw 감소
3. 비싼 Fragment Shader 단순화
4. Intermediate Buffer Resolution 조정
5. MSAA·HDR·Format 검토
6. 내부 Render Scale 조정
7. 적절한 Upscaler 선택
8. Dynamic Resolution 범위 설정
```

불필요한 작업을 유지한 채 전체 Resolution만 낮추면 화질을 잃으면서 구조적 낭비는 남는다.

필요한 Effect까지 포함한 뒤 목표 Device에서 부족한 Budget을 Render Scale로 조절한다.

---

## 화질 평가

평균 Screenshot만으로 Upscaling 품질을 판단하면 Motion Artifact를 놓칠 수 있다.

```text
확인 장면
├─ Thin Geometry
├─ Foliage
├─ Specular Highlight
├─ Fast Camera Pan
├─ Transparent Particle
├─ Disocclusion
├─ Small Text
└─ High-contrast Edge
```

Temporal Upscaler는 정지 화면에서 선명해도 움직임에서 Ghosting이 생길 수 있다.

성능과 함께 실제 Gameplay Motion에서 평가한다.

---

## 흔한 오해

### 4K는 1080p의 두 배 Pixel이다

가로와 세로가 각각 두 배이므로 전체 Pixel 수는 네 배다.

### Render Scale 50%는 Pixel이 절반이다

각 축이 50%라면 전체 Pixel 수는 약 25%다.

### 해상도를 낮추면 모든 GPU 비용이 같은 비율로 줄어든다

Vertex, Draw Setup, Shadow Atlas와 고정 크기 Render Texture는 변화가 작을 수 있다.

### 해상도를 낮추면 CPU도 빨라진다

Script, Physics, Animation과 Draw Call 수가 같으면 CPU 시간은 대체로 유지될 수 있다.

### Display Resolution과 Render Scale은 같다

Output Backbuffer와 내부 3D Render Target를 서로 다른 크기로 사용할 수 있다.

### Canvas Reference Resolution이 GPU 해상도다

Reference Resolution은 UI Layout 기준이며 실제 Render Target Pixel 수를 직접 바꾸지 않는다.

### 높은 DPI 화면은 물리적으로 작으므로 가볍다

GPU는 화면의 물리 크기가 아니라 Rendering하는 Pixel 수를 처리한다.

### Upscaling은 비용이 없다

Upscaler 자체도 출력 Resolution에서 Sample, Reconstruction과 Color Write를 수행한다.

### Dynamic Resolution은 항상 Frame Rate를 높인다

Pixel 병목이 아닐 때는 화질만 낮아지고 Frame Time 변화가 작을 수 있다.

### 낮은 Resolution에서 빠르면 최적화가 끝났다

Target Native Resolution, Sustained Thermal 상태와 Worst-case Effect에서 다시 측정해야 한다.

### VSync 상태에서 FPS가 같으면 차이가 없다

표시 FPS는 같아도 GPU Time, 전력과 Thermal Headroom이 개선될 수 있다.

---

## 최종 체크리스트

```text
□ Target의 실제 Output Resolution을 확인했는가?
□ 내부 Render Resolution과 Output Resolution을 구분했는가?
□ Resolution Scale의 가로·세로 곱으로 Pixel 비율을 계산했는가?
□ 해상도별 Color·Depth Buffer 크기를 확인했는가?
□ HDR Format과 MSAA Sample 수를 확인했는가?
□ Transparent Overdraw가 Resolution 증가를 증폭하지 않는가?
□ Fullscreen Post-processing Pass 수를 확인했는가?
□ SSAO·SSR·Blur가 적절한 Resolution에서 실행되는가?
□ Deferred G-buffer의 Format과 개수를 확인했는가?
□ Shadow Atlas가 Camera Resolution과 별도임을 고려했는가?
□ Reflection·Portal·Mini Map Texture 크기를 확인했는가?
□ URP Render Scale을 따르지 않는 Pass가 있는가?
□ UI가 Native Output Resolution에서 별도 Rendering되는가?
□ Canvas Reference Resolution과 Render Resolution을 혼동하지 않았는가?
□ Mobile Native Resolution이 GPU 등급에 과도하지 않은가?
□ XR Eye Texture Resolution과 Refresh Rate를 확인했는가?
□ CPU Bound와 GPU Bound를 구분했는가?
□ VSync·Frame Cap 조건을 기록했는가?
□ 100%·75%·50% Resolution A/B Test를 수행했는가?
□ Pass별 GPU Time의 Scaling 차이를 확인했는가?
□ Frame Debugger에서 Resource 크기를 확인했는가?
□ Target Device에서 화질과 Sustained 성능을 함께 평가했는가?
```

---

## 정리

해상도는 가로와 세로 Pixel 수의 곱이며 각 축이 두 배가 되면 전체 Pixel 수는 네 배가 된다.

Pixel 수가 증가하면 Rasterization으로 생성되는 Fragment, Fragment Shader와 Texture Sample, Depth·Stencil, Blend와 Color Buffer Read·Write가 함께 증가할 수 있다.

Post-processing, Deferred G-buffer, MSAA와 HDR Intermediate Texture는 높은 Resolution에서 Memory 용량과 Bandwidth 부담을 더욱 키운다.

Vertex, Draw Call, CPU Simulation, 고정 Resolution Shadow Map과 별도 Render Texture는 Camera 해상도 변화에 직접 비례하지 않으므로 전체 GPU 시간이 Pixel 비율만큼 정확히 변하지는 않는다.

출력 해상도와 내부 렌더 해상도는 다를 수 있으며 URP Render Scale, Dynamic Resolution과 Upscaling을 이용해 UI 선명도를 유지하면서 3D Pixel 비용을 조절할 수 있다.

해상도를 낮춰도 성능이 변하지 않으면 CPU·Vertex·Shadow·Synchronization처럼 다른 병목을 확인해야 한다.

동일 장면의 Resolution A/B Test와 Pass별 GPU Profile, Frame Debugger의 실제 Render Target 크기를 이용해 Target Device에서 해상도 의존 비용을 검증해야 한다.
