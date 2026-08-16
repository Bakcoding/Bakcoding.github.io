---
title: "[Unity 렌더링] 10-7. Overdraw는 어떻게 확인할까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - Overdraw
  - FrameDebugger
  - Profiling
permalink: /programming/unity-10-7-how-to-check-overdraw/
toc: true
toc_sticky: true
date: 2026-08-16
last_modified_at: 2026-08-16
---

Overdraw는 최종 화면만 보고 정확히 판단하기 어렵다.

```text
Final Pixel
└─ 한 가지 Color만 보임

실제 처리
├─ Opaque Surface
├─ Decal
├─ Smoke A
├─ Smoke B
├─ UI Dim
└─ Final UI
```

Unity의 Overdraw View로 겹친 영역을 찾고 Frame Debugger로 어떤 Draw가 반복됐는지 확인한 뒤 GPU Profiler로 실제 시간을 측정해야 한다.

시각화, Draw 구조와 성능 수치를 순서대로 연결해야 밝게 보이는 영역과 진짜 병목을 구분할 수 있다.

---

## 확인 도구의 역할이 다르다

Overdraw 조사에는 여러 도구가 필요하다.

| 도구 | 답하는 질문 | 한계 |
|---|---|---|
| Scene View Overdraw | 어디가 많이 겹치는가? | 정확한 GPU 시간은 아님 |
| URP Rendering Debugger | 어떤 Rendering 상태인가? | Draw별 시간은 아님 |
| Frame Debugger | 무엇이 어떤 순서로 그려지는가? | 성능 측정기는 아님 |
| GPU Profiler | 어느 Pass가 몇 ms인가? | Pixel별 원인은 제한적 |
| RenderDoc | 특정 Draw·Pixel에서 무슨 일이 있었는가? | Capture 분석 비용이 큼 |
| Vendor Profiler | GPU Unit 중 무엇이 병목인가? | Platform별 사용법이 다름 |

한 도구만으로 Overdraw를 확정하려 하면 원인과 비용을 혼동하기 쉽다.

---

## 가장 먼저 재현 조건을 고정한다

Overdraw 비교 전에는 같은 Frame을 반복할 수 있어야 한다.

```text
고정 항목
├─ Camera Position·Rotation
├─ Screen Resolution
├─ Render Scale
├─ Quality Level
├─ Effect 재생 시점
├─ UI 상태
├─ Object 수
├─ Post-processing
└─ Target FPS·VSync
```

Particle와 Animation이 매번 다른 Frame에 있으면 Overdraw 분포와 GPU 시간이 달라진다.

재현 Scene이나 Debug Command를 만들어 동일한 Worst-case 상태에서 측정한다.

---

## 평균 장면보다 Worst-case를 찾는다

Overdraw는 특정 Gameplay 상태에서 순간적으로 급증할 수 있다.

```text
일반 이동
→ Smoke 1개

Boss Battle
→ Skill Effect 8개
→ Damage UI
→ Fullscreen Fog
→ Multiple Popup
```

평균적인 빈 Scene에서 정상이라고 실제 전투도 정상인 것은 아니다.

다음 상태를 별도로 Capture한다.

```text
일반 Frame
Peak Effect Frame
UI가 모두 열린 Frame
Camera가 Particle에 가까운 Frame
장시간 Gameplay 이후 Frame
```

---

## Scene View의 Draw Mode

Scene View 좌측 상단의 Shading Mode 메뉴에서 Rendering Debug용 Draw Mode를 선택할 수 있다.

```text
Scene View
└─ Shading Mode
   ├─ Shaded
   ├─ Wireframe
   ├─ Overdraw
   └─ Pipeline별 Debug View
```

Unity Version과 Render Pipeline에 따라 메뉴 이름과 제공 Mode가 다를 수 있다.

Overdraw Mode를 선택하면 같은 화면 위치에 여러 번 그려지는 Geometry를 누적 Color로 시각화한다.

---

## Overdraw View 읽기

일반적인 Overdraw 시각화는 Layer가 겹칠수록 밝아지는 형태다.

```text
낮은 중첩    높은 중첩
░  ▒  ▓  █  ███
```

밝은 영역은 많은 Draw 또는 Fragment 후보가 같은 위치를 덮고 있다는 신호다.

다음 패턴을 찾는다.

```text
Fullscreen 전체가 밝음
→ UI Panel·Post Effect 후보

연기 중심만 매우 밝음
→ Particle Layer 중첩 후보

나뭇잎 덩어리가 밝음
→ Alpha Clipped Card 후보

창문·유리만 밝음
→ Transparent Surface 후보
```

---

## 밝기와 Overdraw Ratio는 같지 않다

Overdraw View의 색을 `흰색 = 정확히 8×`처럼 해석하면 안 된다.

시각화 Shader, Pipeline과 Unity Version에 따라 누적 방식이 다를 수 있다.

```text
View Color
→ 상대적인 중첩 위치 파악

실제 GPU ms
→ Profiler로 측정
```

같은 밝기라도 Fragment Shader, Texture Sample, Blend와 Resolution이 다르면 GPU 비용이 다르다.

Overdraw View는 Heatmap이지 정밀 시간 측정기가 아니다.

---

## Scene View와 Game Camera가 같은가?

Scene View Camera와 실제 Game Camera는 Position, Projection과 Culling Mask가 다를 수 있다.

```text
Scene Camera
├─ 자유로운 위치
├─ Editor Gizmo
└─ 다른 Culling 설정 가능

Game Camera
├─ 실제 Gameplay 위치
├─ Camera Stack
└─ 실제 Post-processing·UI
```

Scene View를 Game Camera에 Align하거나 실제 Game View Debug 기능을 사용해 같은 구도를 맞춘다.

Scene View에서 문제없어도 Screen Space UI와 Camera Stack은 실제 Game Frame에서만 완전히 나타날 수 있다.

---

## Editor 전용 요소 제외

Gizmo, Selection Outline, Grid와 Icon은 Scene View에 추가 Rendering을 만들 수 있다.

```text
Editor Visualization
≠ Player Rendering
```

Gizmo 표시를 끄고 선택 상태를 해제한 뒤 비교한다.

Editor의 Overdraw View는 원인 후보를 찾는 용도이며 최종 수치는 Player Build에서 측정한다.

---

## Opaque Overdraw 확인

Opaque Object도 Camera 방향으로 겹치면 Overdraw 후보를 만든다.

```text
Camera
  ├─ Near Wall
  ├─ Middle Wall
  └─ Far Building
```

하지만 Depth Write와 Early-Z가 뒤 Fragment Shader를 제거할 수 있어 시각화된 Layer 수가 실제 Color Shader 실행 수와 같지 않을 수 있다.

Opaque 영역이 밝으면 다음을 추가로 확인한다.

```text
Front-to-Back Ordering
Depth Prepass
Early-Z 가능 여부
Occlusion Culling
Fragment Shader Cost
```

---

## Transparent Overdraw 확인

Transparent Object는 일반적으로 ZWrite를 끄고 Blend를 사용한다.

```text
Camera
  ├─ Glass
  ├─ Smoke
  ├─ Fog
  └─ Background
```

Layer마다 Color가 결과에 기여하므로 Opaque처럼 앞 Surface의 Depth로 뒤 Layer를 쉽게 제거할 수 없다.

Overdraw View에서 Transparent Effect가 밝다면 Screen Coverage, Layer 수, Alpha가 낮은 Lifetime Tail과 Shader 복잡도를 확인한다.

---

## Alpha 0 영역 확인

Texture가 투명해 보여도 Quad 전체가 Rasterize될 수 있다.

```text
┌────────────────────┐
│                    │
│      Smoke         │
│                    │
└────────────────────┘
```

보이는 Smoke보다 밝은 사각형 영역이 넓다면 Texture Padding이나 Particle Billboard Size가 원인일 수 있다.

Alpha 0은 시각 결과가 없다는 뜻이지 Fragment Shader와 Texture Sample이 없다는 보장은 아니다.

Wireframe View와 Overdraw View를 번갈아 보면 실제 Quad 범위를 파악하기 쉽다.

---

## Wireframe과 함께 본다

Wireframe은 Overdraw를 직접 측정하지 않지만 Geometry가 화면을 어떻게 덮는지 보여 준다.

```text
Overdraw View
→ 겹침이 많은 위치

Wireframe View
→ 그 위치를 덮는 Triangle 구조
```

큰 Transparent Quad, 겹친 Mesh Shell과 지나치게 세분된 Particle Trail을 구분할 수 있다.

Triangle이 많다고 Overdraw가 반드시 큰 것은 아니며 Screen Coverage와 Depth 순서를 함께 본다.

---

## UI Overdraw 확인

UI는 Background, Panel, Image, Text와 Effect가 Screen Space에 겹친다.

```text
UI Stack
├─ Background
├─ Dim
├─ Popup
├─ Item Grid
├─ Selection
├─ Text Shadow
└─ Text
```

실제 Popup 조합과 Scroll View가 활성화된 상태에서 Overdraw View를 확인한다.

Prefab 하나만 열어 보면 여러 Screen이 동시에 켜진 Runtime Layer를 놓칠 수 있다.

Fullscreen 영역이 일정하게 밝다면 Alpha 0 Screen, 중복 Dim과 Background를 의심한다.

---

## Particle Overdraw 확인

Particle Effect는 Lifetime에 따라 Overdraw Peak가 달라진다.

```text
Birth
→ 작은 Flash

Middle
→ 많은 Fire·Spark

End
→ 크고 옅은 Smoke
```

Effect 시작 Frame만 보지 말고 Peak Burst와 Smoke가 가장 크게 확산된 Frame을 확인한다.

Particle System을 Pause하고 Playback Time을 이동해 같은 시점을 비교하면 유용하다.

Scene 전체 Effect가 중첩되는 Worst-case도 별도로 측정한다.

---

## Foliage와 Alpha Clip

나뭇잎과 Grass는 Alpha Clipping을 사용하는 Quad Card를 많이 겹친다.

```text
Tree Crown
├─ Leaf Card A
├─ Leaf Card B
├─ Leaf Card C
└─ Leaf Card N
```

투명한 부분을 `clip`으로 버려도 Alpha Texture를 Sample하고 판정해야 한다.

Overdraw View가 Card 사각형 전체를 밝게 보일 수 있으며 실제 Shader 비용과 Early-Z는 Pipeline에 따라 다르다.

Card 수, Alpha Coverage, Double-sided Rendering과 Shadow Caster Pass를 함께 확인한다.

---

## Decal 확인

Decal은 기존 Surface 위에 Material 정보를 추가한다.

```text
Wall
→ Dirt Decal
→ Bullet Decal
→ Damage Decal
```

같은 위치에 오래 남은 Decal이 누적되면 Overdraw와 Draw 수가 함께 증가한다.

Screen Space, DBuffer와 Mesh Decal은 Pass 구조와 비용이 다르다.

Overdraw View에서 집중 영역을 찾은 뒤 Frame Debugger에서 Decal Pass와 Render Target를 확인한다.

---

## Fullscreen Pass는 별도로 확인한다

Overdraw View가 Scene Geometry 중심으로 동작하면 Post-processing의 모든 Fullscreen Pass를 그대로 보여 주지 못할 수 있다.

```text
Camera Color
→ Bloom
→ SSAO Composite
→ Color Grading
→ Anti-aliasing
→ Final Blit
```

최종 화면 전체를 반복 처리하는 Pass는 Frame Debugger와 GPU Profiler에서 확인한다.

Geometry Overdraw가 낮아도 Fullscreen Effect가 Fill-rate 병목을 만들 수 있다.

---

## URP Rendering Debugger 열기

URP Rendering Debugger는 Runtime과 Editor에서 Rendering 상태를 시각화하는 기능을 제공한다.

Unity Version에 따라 메뉴 위치와 단축키가 다를 수 있다.

```text
Rendering Debugger
├─ Material
├─ Lighting
├─ Rendering
├─ Volume
└─ Fullscreen Debug Modes
```

Material Validation, Lighting Complexity와 Rendering Feature 상태를 Overdraw 분석과 함께 볼 수 있다.

Player에서 지원되는 Debug UI를 이용하면 Game Camera 결과를 실제 Runtime 조건에 가깝게 확인할 수 있다.

---

## Rendering Debugger에서 고정할 설정

Debug View를 비교할 때 Camera와 Debug Option을 기록한다.

```text
Debug 기록
├─ Debug Mode 이름
├─ Camera 이름
├─ URP Renderer
├─ Quality Level
├─ Render Scale
├─ HDR·MSAA
└─ Renderer Feature 상태
```

다른 Quality Level의 URP Asset을 사용하면 Depth Prepass, Shadow와 Post-processing 구조가 달라질 수 있다.

Screenshot에 조건을 함께 남겨야 팀원이 같은 결과를 재현할 수 있다.

---

## Frame Debugger의 역할

Frame Debugger는 한 Frame의 Rendering Event를 제출 순서대로 보여 준다.

```text
Frame
├─ Shadow Map
├─ Depth Prepass
├─ Opaque
├─ Skybox
├─ Transparent
├─ Post-processing
├─ UI
└─ Final Blit
```

Slider를 이동하면 각 Event 이후 Render Target가 어떻게 변했는지 확인할 수 있다.

Overdraw 영역이 어떤 Draw에 의해 누적되는지 찾는 핵심 도구다.

---

## Frame Debugger 사용 전 준비

분석할 Frame에서 Game을 Pause한다.

```text
1. 문제 상태 재현
2. 원하는 Effect Frame에서 Pause
3. Frame Debugger Enable
4. Camera·Render Target 선택
5. Event를 단계별로 이동
```

계속 움직이는 Scene에서는 Frame Debugger를 켜는 순간 Particle와 Animation 상태가 달라질 수 있다.

재현 Script, Timeline Pause 또는 Particle Playback Control을 사용한다.

---

## Draw Event를 한 단계씩 진행한다

Event 목록을 처음부터 진행하며 문제 Pixel 영역을 관찰한다.

```text
Event 120: Opaque Wall
Event 121: Window Glass
Event 122: Smoke A
Event 123: Smoke B
Event 124: UI Dim
```

어느 Event에서 같은 영역에 Color가 추가되는지 기록한다.

최종 화면에서는 Smoke B에 가려진 Smoke A도 Event 122에서 이미 처리됐음을 확인할 수 있다.

---

## 선택한 Draw의 정보

Frame Debugger에서 Draw를 선택하면 Mesh, Material, Shader Pass와 상태를 확인할 수 있다.

```text
확인 항목
├─ GameObject·Renderer
├─ Mesh·Submesh
├─ Material
├─ Shader Pass
├─ Render Queue
├─ Blend State
├─ ZTest·ZWrite
├─ Keywords
└─ Render Target
```

Unity Version과 Pipeline에 따라 표시되는 항목은 다를 수 있다.

같은 Material로 생각했던 Object가 Keyword나 Instance 차이로 여러 Draw로 나뉘는지도 확인한다.

---

## Blend State 확인

Transparent Overdraw를 조사할 때 Source와 Destination Blend Factor를 확인한다.

```text
Alpha Blend 예
SrcAlpha, OneMinusSrcAlpha

Additive 예
SrcAlpha, One
```

Blend가 켜져 있으면 기존 Color와 결합하는 Pixel 작업이 발생한다.

시각적으로 불투명한 UI나 Particle도 Transparent Material과 Blend State를 사용할 수 있다.

Surface Type과 실제 Pipeline State가 같은지 확인한다.

---

## ZTest와 ZWrite 확인

Transparent Material는 보통 `ZTest`는 사용하고 `ZWrite`는 끈다.

```text
ZTest On
→ Opaque Depth 뒤 Fragment 제거 가능

ZWrite Off
→ Transparent끼리 Depth 가림 어려움
```

Frame Debugger에서 예상과 다른 ZWrite, Render Queue 또는 Depth Prepass가 있는지 확인한다.

ZWrite를 무조건 켜면 반투명 Sorting이 깨질 수 있으므로 진단 결과를 바로 설정 변경으로 연결하지 않는다.

---

## Render Queue와 Sorting 확인

Draw Event 순서를 보면 Opaque와 Transparent가 언제 그려지는지 알 수 있다.

```text
Opaque Queue
→ 대체로 Front-to-Back 이점

Transparent Queue
→ 대체로 Back-to-Front 정렬
```

Sorting Layer, Order, Priority와 Render Queue Override가 예상하지 않은 순서를 만들 수 있다.

앞에서 완전히 가려지는 Opaque가 늦게 그려지거나 큰 Transparent Layer가 불필요하게 여러 번 중첩되는지 확인한다.

---

## UI Draw Event 확인

UI는 Canvas와 Batch 단위로 Frame Debugger에 나타날 수 있다.

```text
Canvas A
├─ Background Batch
├─ Image Batch
└─ Text Batch

Canvas B
├─ Dim
└─ Popup
```

하나의 Batch에 여러 UI Quad가 포함되면 Event 하나만 보고 개별 Graphic을 찾기 어려울 수 있다.

Hierarchy에서 그룹을 임시 비활성화하는 A/B Test와 결합해 원인을 좁힌다.

Alpha 0 Screen이 Draw 목록에 남아 있는지도 확인한다.

---

## Mask와 Stencil Event

UI Mask와 Stencil을 사용하면 Mask 기록, Child Draw와 정리 Event가 추가될 수 있다.

```text
Mask Write
→ Child UI with Stencil Test
→ Mask Cleanup
```

Overdraw View에서는 단순 겹침처럼 보이지만 Frame Debugger에서는 추가 Pass 구조를 확인할 수 있다.

Nested Mask가 몇 Level인지, 사각 영역에 복잡한 Stencil Mask가 필요한지 검토한다.

---

## Particle System별 Draw 확인

Effect Prefab 하나가 여러 Child System과 Renderer를 포함할 수 있다.

```text
Explosion Prefab
├─ Flash Draw
├─ Fire Draw
├─ Smoke Draw
├─ Spark Draw
├─ Trail Draw
└─ Distortion Draw
```

Frame Debugger에서 Effect 한 번이 실제로 몇 Draw와 Pass를 만드는지 센다.

종료된 것으로 보이는 Looping Child System이나 Shadow Caster Pass가 남아 있지 않은지 확인한다.

---

## Render Target와 Viewport 확인

같은 Fullscreen Draw라도 Target Resolution에 따라 Pixel 수가 다르다.

```text
Camera Color: 2560 × 1440
Blur Buffer:  1280 × 720
Shadow Atlas: 2048 × 2048
```

Frame Debugger에서 현재 Event의 Render Target와 Viewport를 확인한다.

Render Scale을 낮췄는데 Custom Renderer Feature가 Full Resolution Texture를 사용하면 기대한 절감이 나타나지 않을 수 있다.

---

## Intermediate Texture와 Blit

Camera Color Copy, Opaque Texture, Post-processing과 Camera Stack은 Intermediate Texture를 사용할 수 있다.

```text
Camera Color A
→ Blit
→ Camera Color B
→ Effect
→ Final Blit
```

Geometry Overdraw가 아니어도 같은 Screen Pixel을 여러 Buffer에서 읽고 쓴다.

Frame Debugger의 Copy·Blit Event를 포함해 전체 Pixel 작업을 본다.

Overdraw 최적화 후에도 GPU 시간이 높다면 Fullscreen Transfer가 병목일 수 있다.

---

## Frame Debugger는 시간 측정기가 아니다

Event가 많다고 반드시 느린 것은 아니며 Event가 하나라고 Pixel 비용이 작은 것도 아니다.

```text
Draw A
→ 작은 Object 100 Triangles

Draw B
→ Fullscreen Complex Shader 1 Triangle
```

Draw B 하나가 더 비쌀 수 있다.

Frame Debugger는 원인 구조를 찾고 GPU Profiler는 실제 시간을 측정한다.

---

## GPU Profiler에서 확인할 것

GPU Usage Profiler Module은 Frame의 GPU Marker와 시간을 보여 준다.

```text
GPU Frame
├─ Shadows
├─ Depth Prepass
├─ Opaque
├─ Transparent
├─ Post-processing
└─ UI
```

Overdraw 후보가 속한 Pass의 GPU 시간을 확인한다.

Transparent Pass가 5ms라고 그 전체가 Overdraw 때문이라는 뜻은 아니며 Shader, Sorting 결과와 Bandwidth도 포함될 수 있다.

---

## CPU와 GPU 시간을 분리한다

Particle와 UI는 CPU 비용도 함께 만들 수 있다.

```text
CPU
├─ Particle Simulation
├─ UI Canvas Rebuild
├─ Culling
└─ Draw Submission

GPU
├─ Fragment Shader
├─ Texture Sample
├─ Blend
└─ Color Write
```

UI Layer를 제거해 GPU Overdraw는 줄었지만 Canvas Rebuild가 병목이면 표시 FPS 변화가 작을 수 있다.

CPU Timeline과 GPU Module을 함께 기록한다.

---

## Editor Profiling의 한계

Editor는 Inspector, Scene View, Gizmo와 Editor UI를 함께 실행한다.

```text
Editor Frame
= Game Work
+ Editor Overhead
```

GPU Marker 지원과 Timing 정확도도 Graphics API와 Platform에 따라 다를 수 있다.

원인 탐색은 Editor에서 빠르게 수행하고 최종 측정은 Development Build를 Target Device에서 실행한다.

Autoconnect Profiler의 통신 Overhead도 비교 조건에서 일정하게 유지한다.

---

## Resolution A/B Test

같은 Scene에서 Render Scale 또는 내부 Resolution을 낮춘다.

```text
Test A: 100% Pixels
Test B: 75% per Axis → 약 56% Pixels
Test C: 50% per Axis → 약 25% Pixels
```

Transparent·UI·Post-processing Pass 시간이 크게 줄면 Fragment와 Bandwidth 병목 가능성이 높다.

CPU, Shadow Map과 Fixed-resolution Buffer는 변화가 작을 수 있다.

Camera, Effect Frame과 Quality 설정을 고정한다.

---

## Layer A/B Test

Overdraw 후보를 그룹별로 하나씩 끈다.

```text
Baseline
→ Smoke Off
→ UI Dim Off
→ Decal Off
→ Text Effect Off
→ Background Blur Off
```

한 번에 여러 그룹을 끄면 어느 Layer가 기여했는지 구분하기 어렵다.

각 변경의 CPU ms, GPU ms, Pass ms와 Screenshot을 기록한다.

시각 품질 손실 대비 GPU 절감이 큰 항목부터 최적화한다.

---

## Shader A/B Test

Coverage와 Geometry를 그대로 두고 Material를 단순 Unlit Color Shader로 임시 교체한다.

```text
Original Shader
→ Texture + Lighting + Distortion

Diagnostic Shader
→ Solid Color
```

GPU 시간이 크게 줄면 Fragment Shader와 Texture Sample의 비중이 크다.

변화가 작으면 Blend, Bandwidth, Layer 수 또는 다른 Pass가 더 큰 원인일 수 있다.

진단 Material은 시각 결과가 아니라 병목 분리를 위한 도구다.

---

## Coverage A/B Test

Particle Size, UI Rect와 Decal 범위를 절반으로 줄인다.

```text
Particle Count 유지
Shader 유지
Size만 50%
```

Quad 폭과 높이가 각각 절반이면 면적은 약 1/4이 된다.

GPU 시간이 크게 반응하면 Screen Coverage가 주요 원인일 가능성이 높다.

Particle 수만 줄이는 Test와 비교하면 Count와 Size 중 어느 쪽이 더 중요한지 알 수 있다.

---

## Overdraw Ratio를 정량화하려면

일부 GPU Profiler와 Vendor Tool은 Samples per Pixel, Fragment Invocations, Early-Z Kill과 Overdraw 관련 Counter를 제공한다.

```text
개념적 Ratio
Processed Fragments
───────────────────
Output Pixels
```

Counter가 모든 Shader Stage와 Discard를 같은 방식으로 계산하는 것은 아니다.

MSAA, VRS와 Tile-based Rendering에서는 해석이 더 복잡해질 수 있다.

도구 문서의 Counter 정의를 확인하고 다른 GPU끼리 숫자를 직접 비교하지 않는다.

---

## RenderDoc Capture

RenderDoc은 한 Frame의 GPU Command와 Resource를 Capture한다.

```text
Capture
├─ Event Browser
├─ Pipeline State
├─ Texture Viewer
├─ Mesh Viewer
├─ Shader Resource
└─ Pixel History
```

Frame Debugger보다 낮은 수준에서 Draw와 Render Target 상태를 확인할 수 있다.

Unity Editor와 Standalone Player의 지원 Graphics API에서 Capture할 수 있으며 Platform에 따라 다른 Vendor Tool이 필요하다.

---

## Pixel History

Pixel History는 선택한 Pixel에 영향을 준 Event를 추적한다.

```text
Pixel (x, y)
├─ Clear
├─ Opaque Wall
├─ Decal
├─ Smoke A
├─ Smoke B
├─ Color Grading
└─ UI
```

각 Draw가 Depth·Stencil Test를 통과했는지, Color가 어떻게 바뀌었는지 확인할 수 있다.

화면 중앙의 밝은 Overdraw 영역과 정상 영역에서 각각 Pixel을 선택해 비교한다.

Fullscreen Post-processing도 History에 나타날 수 있으므로 Geometry Layer와 구분한다.

---

## Pipeline State 확인

RenderDoc의 Pipeline State에서 선택한 Draw의 상태를 확인한다.

```text
Input Assembly
Vertex Shader
Rasterizer
Depth·Stencil
Fragment Shader
Blend
Render Targets
```

예상과 다른 `ZWrite Off`, Double-sided Culling, Blend Factor와 여러 Color Attachment를 찾을 수 있다.

Shader Resource에서 Base Map, Depth Texture, Opaque Texture와 추가 Sample을 확인한다.

Overdraw 횟수와 한 Fragment의 비용을 연결하는 단계다.

---

## Texture Viewer

Render Target와 Texture를 Alpha Channel, Mip Level과 개별 Channel로 확인한다.

```text
RGBA View
Alpha-only View
Depth View
Stencil View
```

Particle Texture의 투명 Padding, Alpha 0 UI와 Mask 범위를 시각적으로 확인할 수 있다.

Intermediate Buffer가 예상보다 높은 Resolution이나 HDR Format인지도 Resource 정보에서 확인한다.

---

## Vendor GPU Profiler

GPU 제조사와 Platform은 Hardware Counter를 제공하는 전용 Profiler를 지원할 수 있다.

```text
Counter 후보
├─ Fragment Shader Busy
├─ Texture Unit Busy
├─ ALU Utilization
├─ Memory Bandwidth
├─ Early-Z Rejection
├─ Tile Load·Store
└─ Samples per Pixel
```

Overdraw가 많아도 Fragment Shader가 단순하면 다른 Unit이 병목일 수 있다.

Counter 이름과 계산 방식은 Architecture마다 다르므로 해당 Tool 문서를 기준으로 해석한다.

---

## Tile-based GPU 분석

Mobile Tile GPU는 Tile 내부 Memory에서 Color와 Depth를 처리해 외부 Bandwidth를 줄일 수 있다.

```text
Tile Rendering
→ On-chip Color·Depth
→ Tile 완료 시 Store
```

하지만 겹친 Fragment의 Shader와 Texture Sample은 여전히 실행될 수 있다.

Render Pass 분리, Intermediate Texture와 Store·Load가 Tile Memory 이점을 줄이는지도 확인한다.

Desktop Capture 결과를 Mobile GPU에 그대로 적용하지 않는다.

---

## XR Overdraw 확인

XR은 왼쪽과 오른쪽 Eye에서 Overdraw가 발생한다.

```text
Left Eye Layer Stack
+ Right Eye Layer Stack
```

Game View 한쪽 Eye만 보면 다른 Eye의 Coverage와 Stereo Artifact를 놓칠 수 있다.

XR Render Scale, Eye Texture Resolution과 Stereo Mode를 기록하고 Headset Target Profiler를 사용한다.

가까운 World Space UI와 Particle가 각 Eye에서 화면을 크게 덮는지 확인한다.

---

## Screenshot 비교만으로 부족한 이유

Before와 After의 최종 Screenshot이 같아도 내부 Draw 구조는 다를 수 있다.

```text
Before
Layer A + Layer B + Layer C

After
Baked Layer D

Final Image는 같음
GPU Work는 다름
```

반대로 Overdraw View가 어두워져도 Shader가 복잡해지면 GPU 시간은 늘 수 있다.

Screenshot, Frame Debugger Event와 GPU ms를 함께 저장한다.

---

## 측정 표 만들기

실험 결과를 표로 기록하면 감각적인 판단을 줄일 수 있다.

| Variant | Resolution | Draws | Transparent ms | GPU ms | 품질 |
|---|---:|---:|---:|---:|---|
| Baseline | 1920×1080 | 420 | 4.8 | 15.2 | 기준 |
| Smoke Off | 1920×1080 | 392 | 2.1 | 12.4 | 분위기 감소 |
| Smoke Size 60% | 1920×1080 | 420 | 3.0 | 13.3 | 허용 가능 |
| Scale 75% | 1440×810 | 420 | 2.7 | 11.9 | 약간 흐림 |

숫자는 기록 형식의 예시이며 실제 결과가 아니다.

같은 Capture 구간을 여러 번 측정해 평균과 Spike를 함께 본다.

---

## 조사 순서

Overdraw 문제를 다음 순서로 좁힐 수 있다.

```text
1. 문제 Frame 재현·고정
        │
        ▼
2. Overdraw View로 밝은 영역 확인
        │
        ▼
3. Wireframe으로 Coverage 구조 확인
        │
        ▼
4. Frame Debugger로 Draw 주체·순서 확인
        │
        ▼
5. GPU Profiler로 Pass 시간 측정
        │
        ▼
6. Resolution·Layer·Shader A/B Test
        │
        ▼
7. 필요하면 RenderDoc·Vendor Counter 분석
        │
        ▼
8. 수정 후 Target Device 재측정
```

이 순서는 시각적 후보를 실제 비용과 연결해 불필요한 최적화를 줄인다.

---

## UI 조사 예

Popup을 열 때 GPU 시간이 증가한다고 가정한다.

```text
1. Popup 상태에서 Overdraw View
→ 화면 전체가 밝아짐

2. Frame Debugger
→ Dim Image가 두 번 Draw
→ 이전 Screen Alpha 0 Draw 유지

3. A/B Test
→ 이전 Screen 비활성화: -1.1 ms
→ Dim 통합: -0.4 ms
```

Canvas 수만 줄이는 대신 실제 Fullscreen Graphic를 제거한다.

CPU Canvas Rebuild가 증가하지 않는지 함께 측정한다.

---

## Particle 조사 예

폭발 후반에 Frame Rate가 낮아진다고 가정한다.

```text
1. Effect Timeline Pause
→ 후반 Smoke가 가장 밝음

2. Wireframe
→ 큰 Billboard가 Screen 대부분을 덮음

3. Frame Debugger
→ Lit Smoke + Soft Particle

4. A/B Test
→ Max Size 70%: -0.8 ms
→ Unlit: -0.5 ms
→ Lifetime Tail 축소: -0.6 ms
```

Particle Count만 줄이지 않고 Coverage와 Shader를 분리해 품질 대비 효율이 큰 변경을 선택한다.

---

## Opaque Scene 조사 예

도시를 바라볼 때 Opaque 영역이 밝고 GPU 시간이 증가한다고 가정한다.

```text
1. Overdraw View
→ 건물 뒤쪽 Geometry 중첩

2. Frame Debugger
→ 먼 건물이 먼저 Color Draw
→ 가까운 건물이 나중에 덮음

3. 확인
→ Depth Prepass 없음
→ 복잡한 Lit Shader

4. Test
→ Front-to-Back·Depth 전략 비교
→ Occlusion Culling 비교
```

Depth Prepass는 Draw와 Vertex 비용을 추가하므로 GPU 전체 시간으로 손익을 판단한다.

---

## Post-processing 조사 예

Overdraw View는 어둡지만 GPU가 느릴 수 있다.

```text
Frame Debugger
├─ Bloom Pyramid 8 Events
├─ SSAO 3 Events
├─ Custom Blur 4 Events
└─ Final Blit 2 Events
```

이 경우 Geometry Overdraw보다 Fullscreen Pass와 Intermediate Buffer가 원인일 수 있다.

Resolution A/B Test와 Effect별 On·Off Test로 Pass 시간을 비교한다.

Overdraw라는 단어를 동일 Render Target의 Geometry 중첩에만 한정하지 말고 전체 Pixel 반복 작업도 함께 본다.

---

## 수정 후 다시 확인한다

Graphic나 Particle Layer를 제거했다고 예상한 만큼 GPU 시간이 줄었다고 가정하면 안 된다.

```text
수정
→ Frame Debugger Event 감소 확인
→ Overdraw View 변화 확인
→ GPU ms 비교
→ CPU ms 비교
→ 화질 비교
```

Batch가 깨지거나 다른 Shader Variant가 활성화되어 비용이 이동할 수 있다.

최적화 전후의 동일 Frame Capture를 보관하면 회귀를 찾기 쉽다.

---

## 자동화 가능한 항목

CI나 Performance Test에서 고정 Camera Frame을 Capture하고 GPU Timing을 기록할 수 있다.

```text
자동 측정 후보
├─ Resolution
├─ Draw Call
├─ Triangle·Vertex
├─ Render Texture 수
├─ CPU Frame Time
├─ GPU Frame Time
└─ 대표 Screenshot
```

Overdraw Heatmap의 Pixel 밝기를 단순 Threshold로 사용하는 자동화는 Pipeline 변경과 Debug Shader 차이에 취약할 수 있다.

정량 Counter를 지원하는 Platform에서는 정의와 허용 범위를 문서화한다.

---

## 흔한 오해

### Overdraw View가 밝으면 반드시 느리다

겹친 Layer의 후보를 보여 줄 뿐 Shader와 GPU Architecture에 따른 실제 ms는 Profiler로 측정해야 한다.

### Overdraw View가 어두우면 Pixel 병목이 없다

복잡한 Fullscreen Post-processing 한 Pass도 높은 Fragment 비용을 만들 수 있다.

### Frame Debugger Event 수가 곧 성능이다

작은 Draw 여러 개보다 복잡한 Fullscreen Draw 하나가 더 비쌀 수 있다.

### Scene View 결과가 Player와 같다

Camera, UI, Gizmo, Quality와 Render Pipeline 상태가 다를 수 있다.

### Alpha 0은 Overdraw View에 나타나지 않는다

투명 Color를 출력해도 Quad가 Draw되고 누적 시각화에 포함될 수 있다.

### Opaque Overdraw는 모두 Fragment Shader를 실행한다

Depth와 Early-Z가 가려진 Color Fragment를 제거할 수 있다.

### Resolution을 낮춰 빨라지면 Overdraw만 문제다

Post-processing, 일반 Fragment Shader와 Bandwidth도 Resolution에 반응한다.

### Draw Call을 줄이면 Overdraw도 줄어든다

하나의 Batch 안에서도 여러 Geometry가 같은 Pixel을 반복 처리한다.

### Editor Profiler 숫자가 최종 성능이다

Editor Overhead와 다른 GPU·Graphics API 때문에 Target Player 결과와 다를 수 있다.

### Pixel History가 곧 GPU 시간이다

Draw 순서와 Test 결과를 보여 주지만 각 Event의 실행 시간은 별도 측정해야 한다.

---

## 최종 체크리스트

```text
□ 동일한 문제 Frame을 반복 재현할 수 있는가?
□ Camera·Resolution·Quality·Effect 시점을 고정했는가?
□ 평균과 Worst-case Frame을 모두 확인했는가?
□ Scene View Camera를 Game Camera와 맞췄는가?
□ Gizmo와 Editor 전용 표시를 제외했는가?
□ Overdraw View의 밝기를 상대적 Heatmap으로 해석했는가?
□ Wireframe으로 실제 Quad와 Mesh 범위를 확인했는가?
□ Opaque와 Transparent Overdraw를 구분했는가?
□ UI의 Alpha 0 Screen과 중복 Panel을 확인했는가?
□ Particle의 Peak·Fade-out Frame을 확인했는가?
□ Fullscreen Post-processing은 별도로 확인했는가?
□ Frame Debugger에서 Draw를 한 단계씩 진행했는가?
□ Blend·ZTest·ZWrite·Render Queue를 확인했는가?
□ Mask·Trail·Shadow·Distortion 추가 Pass를 확인했는가?
□ Render Target Resolution과 Format을 확인했는가?
□ Copy·Blit과 Intermediate Texture를 포함했는가?
□ CPU와 GPU Frame Time을 분리했는가?
□ Resolution·Layer·Shader·Coverage A/B Test를 했는가?
□ 필요하면 Pixel History와 Hardware Counter를 확인했는가?
□ 수정 후 Event 수와 GPU ms를 다시 측정했는가?
□ Target Device의 실제 Graphics API에서 검증했는가?
```

---

## 정리

Overdraw는 최종 화면만으로 보이지 않으므로 시각화, Draw Event와 GPU 시간을 단계적으로 연결해 확인해야 한다.

Scene View Overdraw Mode는 같은 위치에 Geometry가 많이 겹치는 후보 영역을 빠르게 찾지만 밝기가 정확한 Overdraw Ratio나 GPU ms를 의미하지는 않는다.

Wireframe으로 큰 Quad와 Geometry 범위를 확인하고 Frame Debugger로 Material, Blend, Depth, Render Queue와 실제 Draw 순서를 추적한다.

Fullscreen Post-processing, Copy와 Intermediate Texture는 Geometry Overdraw View에 완전히 나타나지 않을 수 있으므로 전체 Frame Event를 함께 확인한다.

GPU Profiler에서 Pass별 시간을 측정하고 Resolution, Layer, Shader와 Coverage를 하나씩 바꾸는 A/B Test로 Fragment·Blend·Bandwidth 원인을 분리한다.

더 깊은 분석이 필요하면 RenderDoc Pixel History와 Pipeline State, Platform별 Hardware Counter를 이용해 같은 Pixel을 덮은 Draw와 GPU Unit 병목을 연결한다.

최적화 후에는 동일한 Worst-case Frame을 Target Device에서 다시 Capture해 Overdraw 구조, CPU·GPU 시간과 시각 품질을 함께 검증해야 한다.
