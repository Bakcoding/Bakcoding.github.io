---
title: "[Unity 렌더링] 10-1. Overdraw란 무엇일까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - Overdraw
  - FragmentShader
  - Optimization
permalink: /programming/unity-10-1-what-is-overdraw/
toc: true
toc_sticky: true
date: 2026-08-16
last_modified_at: 2026-08-16
---

Overdraw는 하나의 Screen Pixel 위치에 여러 Fragment가 겹쳐 반복해서 처리되는 현상이다.

```text
Camera Ray
    │
    ├─ Fragment A
    ├─ Fragment B
    ├─ Fragment C
    └─ 최종 Screen Pixel
```

최종 화면에는 한 Color만 보이더라도 그 앞뒤의 Fragment가 Shader, Texture Sample, Depth Test와 Blend를 수행했을 수 있다.

Overdraw가 많으면 GPU가 실제로 보이는 결과보다 훨씬 많은 Pixel 작업을 수행해 Fill-rate 병목이 발생할 수 있다.

---

## Pixel과 Fragment는 다르다

Pixel은 최종 Render Target의 위치이고 Fragment는 Rasterization으로 생성된 Pixel 후보 데이터다.

```text
Triangle Rasterization
        │
        ▼
Fragments 생성
        │
        ▼
Depth / Stencil / Fragment Shader / Blend
        │
        ▼
Render Target Pixel
```

여러 Triangle이 같은 Pixel 위치를 덮으면 여러 Fragment가 만들어질 수 있다.

```text
Screen Pixel (x, y)
├─ Fragment from Triangle A
├─ Fragment from Triangle B
└─ Fragment from Triangle C
```

Overdraw는 최종 Pixel 수보다 처리된 Fragment 후보가 많은 상태를 의미한다.

---

## 가장 단순한 Overdraw 예

화면 전체를 덮는 Quad 세 장이 겹쳐 있다고 가정한다.

```text
Camera
  │
  ├─ Quad A: Fullscreen
  ├─ Quad B: Fullscreen
  └─ Quad C: Fullscreen
```

1920 × 1080 화면은 약 207만 Pixel이다.

```text
한 Layer
1920 × 1080
= 2,073,600 Pixel 후보

세 Layer
≈ 6,220,800 Fragment 후보
```

실제 GPU 처리량은 Depth Test, Clipping, MSAA와 Shader 구조에 따라 달라진다.

이 계산은 화면 결과가 한 장이어도 여러 Layer가 Pixel 작업을 반복한다는 관계를 보여 준다.

---

## Overdraw Ratio

개념적으로 Overdraw 정도를 다음과 같이 생각할 수 있다.

```text
Overdraw Ratio
≈ 처리된 Fragment 수
  ─────────────────
  화면의 유효 Pixel 수
```

한 Pixel 위치에서 평균 한 번만 처리하면 약 `1×`, 평균 네 번 처리하면 약 `4×`로 볼 수 있다.

```text
1×: █
2×: ██
4×: ████
8×: ████████
```

하지만 모든 Fragment Shader 비용이 같지 않아 Overdraw Ratio만으로 GPU 시간을 계산할 수는 없다.

---

## 같은 Overdraw라도 비용이 다른 이유

```text
Layer A Shader
├─ Texture Sample 1회
└─ 단순 Color 출력

Layer B Shader
├─ Texture Sample 8회
├─ Normal Mapping
├─ Lighting Loop
└─ Noise 계산
```

둘 다 한 Layer의 Overdraw를 만들지만 B의 Fragment 비용이 훨씬 클 수 있다.

```text
Pixel Cost
≈ Fragment 수 × Fragment당 Shader 비용
```

Texture Cache, Branch, Blend, Render Target Format과 Memory Bandwidth도 결과에 영향을 준다.

Overdraw Visualization의 밝기만 보고 정확한 ms를 예측하면 안 되는 이유다.

---

## Opaque Object도 Overdraw를 만든다

Opaque Object가 서로 가려도 Camera 방향으로 Triangle이 겹친다.

```text
Camera
  │
  ├─ Wall A: Near
  ├─ Wall B: Mid
  └─ Building C: Far
```

Back-to-Front로 그리면 C, B, A의 Fragment가 모두 Color Shader를 실행한 뒤 가까운 A가 최종 결과를 덮을 수 있다.

그러나 Opaque Rendering은 Depth Buffer와 Early-Z를 이용해 불필요한 Fragment Shader 실행을 크게 줄일 수 있다.

---

## Depth Buffer의 역할

Depth Buffer는 각 Pixel에서 Camera에 가장 가까운 Depth를 저장한다.

```text
Depth Buffer Pixel
현재 저장 Depth = 5

새 Fragment Depth = 10
→ 더 멀리 있음
→ Depth Test Fail
```

Opaque Material은 일반적으로 Depth Write를 활성화한다.

가까운 Surface가 먼저 Depth를 기록하면 뒤의 Fragment를 버릴 수 있다.

```text
Near Opaque Draw
→ Depth 5 기록

Far Opaque Draw
→ Depth 10 Test Fail
→ Color Write 생략
```

---

## Early-Z

Early-Z는 Fragment Shader의 비싼 계산 전에 Depth Test를 수행해 가려진 Fragment를 제거하는 GPU 최적화다.

```text
Early-Z 가능
Fragment 생성
    │
    ▼
Depth Test
    ├─ Fail → Fragment Shader 실행 안 함
    └─ Pass → Fragment Shader 실행
```

가려진 Geometry의 Rasterization과 일부 Setup 비용은 남지만 Fragment Shader와 Texture Sample을 피할 수 있다.

Opaque Overdraw가 존재해도 실제 Shader Overdraw가 Transparent보다 덜 심할 수 있는 이유다.

---

## Early-Z가 항상 동작하는 것은 아니다

GPU와 Shader가 Depth 결과를 미리 확정할 수 있어야 한다.

다음 요소가 Early Depth Test를 제한하거나 동작 시점을 바꿀 수 있다.

```text
주의 요소
├─ Fragment Shader의 Depth 출력
├─ Alpha Clipping / discard
├─ 일부 UAV·Side Effect
├─ Blend와 Depth Write 설정
├─ Shader와 GPU Architecture
└─ Pipeline State
```

정확한 Early-Z 동작은 GPU Vendor, Graphics API와 Shader Compiler에 따라 달라진다.

Source Code만 보고 단정하지 말고 GPU Capture와 Hardware Counter로 확인한다.

---

## Front-to-Back Sorting

Opaque Object를 Camera에서 가까운 순서로 그리면 Depth Buffer를 빨리 채울 수 있다.

```text
Camera
  │
  ├─ A Near
  ├─ B Mid
  └─ C Far

Draw Order
A → B → C
```

A가 먼저 Depth를 기록하면 B와 C의 가려진 Fragment를 Early-Z로 제거할 가능성이 높다.

```text
Front-to-Back
→ 가려진 Fragment Shader 감소

State Sorting
→ Material·SetPass 변경 감소
```

두 정렬 목표가 항상 같은 순서를 만들지는 않는다.

CPU State 비용과 GPU Fragment 비용의 균형이 필요하다.

---

## Depth Prepass

Depth Prepass는 Color Shader 전에 Opaque Geometry의 Depth만 먼저 그린다.

```text
Depth Prepass
├─ Vertex Shader
├─ Rasterization
└─ Depth Write

Color Pass
├─ Depth Test
├─ 보이는 Fragment만 Shader 실행
└─ Color Write
```

복잡한 Fragment Shader가 많이 겹치는 Scene에서는 Color Overdraw를 줄일 수 있다.

하지만 모든 Geometry를 추가 Pass에서 다시 그리므로 Draw Call, Vertex 처리와 Depth Bandwidth가 증가한다.

---

## Depth Prepass의 Trade-off

| 비용 | Prepass 없음 | Prepass 있음 |
| --- | --- | --- |
| Opaque Draw | Color Pass | Depth + Color Pass |
| Vertex 처리 | 상대적으로 적음 | 반복 증가 |
| 비싼 Fragment Overdraw | 증가 가능 | 감소 가능 |
| Depth Bandwidth | 일반 | 추가 Write·Read |
| CPU Draw 준비 | 상대적으로 적음 | 증가 가능 |

Vertex Bound Scene에서는 손해가 날 수 있고 Fragment Bound Scene에서는 이득이 날 수 있다.

URP 기능이 Depth Texture를 요구해 이미 Prepass가 생기는지 Frame Debugger에서 확인한다.

---

## Transparent Object가 Overdraw에 취약한 이유

Transparent Blend는 뒤의 Color와 현재 Fragment Color를 섞는다.

```hlsl
finalColor =
    sourceColor * sourceAlpha
  + destinationColor * (1.0 - sourceAlpha);
```

뒤 Layer의 Color가 최종 결과에 필요하므로 단순히 가까운 Surface만 남길 수 없다.

```text
Camera
  │
  ├─ Smoke A
  ├─ Smoke B
  ├─ Glass C
  └─ Background

모든 Layer의 Color가 Blend에 기여 가능
```

겹친 Transparent Layer는 대부분 Fragment Shader와 Blend를 각각 수행한다.

---

## Transparent는 Depth Test를 사용하지 않을까?

Transparent Material도 일반적으로 Depth Test는 사용할 수 있다.

```text
Opaque Depth보다 뒤의 Transparent
→ Depth Test Fail 가능

서로 겹친 Transparent
→ Depth Write가 꺼져 있으면 각 Layer가 Pass 가능
```

문제는 투명 Surface끼리 올바르게 Blend하려고 Depth Write를 끄는 경우가 많다는 점이다.

앞 Transparent가 뒤 Transparent를 Depth로 제거하지 않으므로 Layer 수만큼 작업이 누적된다.

Transparent의 자세한 비용과 정렬 문제는 다음 글에서 다룬다.

---

## Alpha가 0이어도 비용이 생길 수 있다

Transparent Shader가 Alpha `0`을 출력해 눈에 보이지 않아도 Fragment Shader가 실행되고 Texture를 읽은 뒤 Blend될 수 있다.

```text
Fragment Shader
├─ Base Texture Sample
├─ Lighting 계산
├─ Alpha = 0 계산
└─ Blend
```

최종 Color 변화가 없다는 사실과 GPU 작업이 없다는 것은 다르다.

완전히 보이지 않는 Particle과 UI Element는 Renderer, Canvas Group 또는 Emission 단계에서 제외할 수 있는지 확인한다.

---

## Alpha Clipping은 Transparency와 다르다

Alpha Clipping은 Alpha가 Threshold보다 작으면 Fragment를 버리고 나머지는 Opaque처럼 처리한다.

```hlsl
half alpha = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv).a;
clip(alpha - _Cutoff);
```

통과한 Fragment는 Depth를 기록할 수 있어 뒤 Geometry를 가릴 수 있다.

그러나 버리기 위해 Alpha Texture Sample과 `clip`까지 Shader가 실행되어야 한다.

잎과 철망처럼 빈 영역이 많은 Quad가 겹치면 Alpha Clipping Overdraw도 비쌀 수 있다.

---

## Alpha Clipping과 Early-Z

Fragment가 살아남을지 Alpha Texture를 읽기 전에는 알 수 없다.

```text
Alpha Clip Fragment
├─ UV 계산
├─ Alpha Texture Sample
├─ Threshold 비교
└─ Discard 또는 Depth Write
```

GPU는 일부 Early Test를 수행할 수 있지만 Alpha 결과와 Depth Write의 정확성을 유지해야 한다.

일반 Opaque보다 Early-Z 효율이 낮아질 수 있다.

Foliage의 Quad 수, 빈 영역과 Layer 겹침을 줄이는 것이 중요하다.

---

## UI에서 Overdraw가 커지는 구조

UI는 Screen Space에 큰 Transparent Quad를 많이 겹칠 수 있다.

```text
Screen
├─ Background Panel
├─ Blur Overlay
├─ Window
├─ Image
├─ Text Shadow
├─ Text Outline
└─ Text Glyph
```

각 Layer가 같은 Pixel을 반복 처리한다.

Canvas 전체를 덮는 반투명 Image가 여러 개 쌓이면 Resolution에 비례해 비용이 증가한다.

UI Overdraw의 구체적인 원인과 Canvas 최적화는 `10-3`에서 다룬다.

---

## Particle에서 Overdraw가 커지는 구조

Particle은 Camera를 향한 Quad와 Transparent Texture를 많이 사용한다.

```text
Smoke Particle 1000개
├─ Quad 1000장
├─ 화면 중앙에 밀집
└─ Layer별 Soft Alpha Blend
```

Particle 하나의 Alpha가 낮아도 수십 Layer가 겹치면 같은 Pixel에서 Shader가 수십 번 실행될 수 있다.

큰 Smoke, Fire와 Fog Particle은 화면 Coverage가 넓어 Fill-rate를 빠르게 소비한다.

Particle 최적화는 `10-4`에서 구체적으로 다룬다.

---

## Sprite Overdraw

Sprite Texture의 실제 Image가 작아도 Mesh가 큰 사각형이면 투명한 여백까지 Rasterization된다.

```text
Sprite Quad
┌────────────────────┐
│ transparent        │
│      █ Image       │
│ transparent        │
└────────────────────┘
```

Tight Mesh를 사용하면 투명한 영역의 Fragment 후보를 줄일 수 있다.

```text
Full Rect Mesh
→ Vertex 적음, Transparent Pixel 많음

Tight Mesh
→ Vertex 증가, Transparent Pixel 감소
```

Vertex 비용과 Fill-rate 사이의 Trade-off다.

---

## Decal과 Overlay

Decal, Selection Highlight와 Screen Effect는 기존 Surface 위에 Color를 다시 그린다.

```text
Base Surface
├─ Decal 1
├─ Decal 2
├─ Damage Overlay
└─ Selection Outline
```

작은 영역이면 비용이 제한적이지만 큰 Projected Decal이 많이 겹치면 Fragment와 Blend 비용이 증가한다.

Decal Rendering Path에 따라 DBuffer, Screen Space Sample과 추가 Render Target 비용도 생길 수 있다.

---

## Fullscreen Pass도 Pixel을 반복 처리한다

Bloom, Color Grading와 Custom Post-process는 화면 전체 또는 일부를 다시 읽고 쓴다.

```text
Camera Color
├─ Bloom Prefilter
├─ Blur Passes
├─ Color Grading
├─ Vignette
└─ Final Blit
```

Geometry Layer가 겹치는 전통적인 Overdraw와 구조는 다르지만 같은 Screen Pixel을 여러 Pass에서 반복 처리한다는 점에서 Fill-rate와 Bandwidth를 소비한다.

Overdraw View만으로 Post-processing 비용을 모두 볼 수 없다.

GPU Profiler의 Pass별 시간을 확인한다.

---

## Resolution이 비용을 증폭한다

Fragment 작업은 Render Target Pixel 수에 영향을 받는다.

| Resolution | Pixel 수 | 1920×1080 기준 |
| --- | ---: | ---: |
| 1280 × 720 | 921,600 | 약 0.44배 |
| 1920 × 1080 | 2,073,600 | 1배 |
| 2560 × 1440 | 3,686,400 | 약 1.78배 |
| 3840 × 2160 | 8,294,400 | 4배 |

4K에서 Fullscreen Transparent Layer 5개는 단순 후보 기준으로 약 4,147만 Pixel 위치를 처리할 수 있다.

해상도가 높을수록 같은 Overdraw Layer가 더 큰 GPU 비용을 만든다.

---

## Render Scale과 Dynamic Resolution

URP Render Scale을 낮추거나 Dynamic Resolution을 사용하면 Camera Render Target의 Pixel 수를 줄일 수 있다.

```text
Render Scale 1.0
1920 × 1080

Render Scale 0.75
1440 × 810
≈ Pixel 수 56.25%
```

Fragment Bound Scene에서 Frame Time을 줄일 수 있다.

하지만 UI가 Native Resolution의 별도 Target에 Rendering되거나 일부 Pass가 다른 Resolution을 사용하면 모든 비용이 같은 비율로 줄지는 않는다.

이미지 선명도와 Upscaling 비용도 고려한다.

---

## MSAA와 Overdraw

MSAA는 Triangle Edge의 Coverage를 여러 Sample로 평가한다.

```text
1 Pixel
├─ Sample 0
├─ Sample 1
├─ Sample 2
└─ Sample 3
```

4× MSAA라고 모든 Fragment Shader가 항상 정확히 4배 실행되는 것은 아니지만 Coverage, Depth·Color Sample Storage와 Resolve 비용이 증가한다.

Overdraw가 많은 Edge와 Alpha-to-Coverage Scene에서는 Sample 비용을 함께 확인한다.

Tile-based Mobile GPU의 Memory와 Store·Resolve 비용도 측정한다.

---

## Fill Rate란 무엇일까?

Fill Rate는 GPU가 일정 시간 동안 Pixel 또는 Sample을 처리하고 Render Target에 기록할 수 있는 능력과 관련된다.

```text
필요 Pixel Work
≈ Resolution
× Overdraw Layer
× MSAA Sample 영향
× Pass 수
× Fragment Shader 비용
```

GPU가 Frame Budget 안에 이 작업을 끝내지 못하면 Fill-rate Bound 상태가 된다.

Unity 공식 성능 문서는 GPU가 Frame당 감당할 수 있는 것보다 더 많은 Pixel을 그리려 할 때 Fill-rate 제한이 발생한다고 설명한다.

---

## Fill Rate와 Memory Bandwidth

Fragment Rendering은 계산뿐 아니라 Texture와 Render Target Memory Traffic을 만든다.

```text
Fragment
├─ Texture Read
├─ Depth Read / Write
├─ Destination Color Read for Blend
├─ Color Write
└─ Additional Render Target Write
```

Transparent Blend는 기존 Destination Color가 필요해 Read-modify-write가 발생할 수 있다.

Deferred G-buffer처럼 여러 Render Target을 쓰면 한 Fragment의 출력 Bandwidth가 커진다.

Overdraw는 Shader ALU와 Memory Bandwidth 양쪽을 증폭할 수 있다.

---

## Tile-based GPU

많은 Mobile GPU는 화면을 작은 Tile로 나누어 On-chip Memory에서 Rendering한다.

```text
Screen
┌────┬────┬────┐
│Tile│Tile│Tile│
├────┼────┼────┤
│Tile│Tile│Tile│
└────┴────┴────┘
```

Tile Memory는 외부 Memory Traffic을 줄일 수 있지만 겹친 Fragment의 Shader 계산과 Blend 자체가 사라지는 것은 아니다.

많은 Transparent Layer, MSAA와 여러 Render Target은 Tile의 처리량과 Store 비용에 부담을 줄 수 있다.

Desktop 결과를 Mobile에 그대로 적용하지 않고 실제 Device에서 측정한다.

---

## Forward와 Deferred의 차이

Forward Rendering은 Visible Fragment에서 Lighting을 직접 계산한다.

```text
Forward Opaque Overdraw
→ 가려진 Fragment가 실행되면 Lighting도 반복 가능
```

Deferred는 G-buffer Pass에서 Material Data를 기록하고 Lighting을 나중에 계산한다.

```text
Deferred Geometry Overdraw
→ G-buffer Write 반복 가능
→ 여러 Render Target Bandwidth
```

Early-Z와 Depth Prepass, GPU Architecture에 따라 실제 비용은 달라진다.

Transparent는 Deferred에서도 일반적으로 별도 Forward 경로로 처리된다.

---

## Overdraw와 Triangle 수

Triangle 수가 적어도 큰 Quad가 화면을 덮으면 Fragment 비용이 클 수 있다.

```text
Fullscreen Quad
├─ Triangle 2개
└─ 4K Pixel 약 830만개 Coverage
```

반대로 Triangle이 많아도 화면에서 작거나 Depth로 빠르게 제거되면 Fragment 비용은 제한적일 수 있다.

```text
Triangle 수
→ Geometry 비용의 단서

Overdraw와 Coverage
→ Fragment 비용의 단서
```

둘을 별도로 Profile한다.

---

## 작은 Particle 수보다 크기가 중요할 수 있다

```text
Particle A
10,000개 × 2×2 Pixel
→ Coverage 약 40,000 Pixel 후보

Particle B
10개 × Fullscreen
→ Coverage 약 20,736,000 Pixel 후보 at 1080p
```

단순 계산에서는 Particle 수가 적은 B가 훨씬 큰 Pixel 작업을 만들 수 있다.

Renderer 수와 Triangle 수만 보고 Overdraw 비용을 판단하면 안 된다.

Screen Coverage와 Layer 겹침을 함께 본다.

---

## Overdraw가 잘 보이지 않는 이유

최종 화면은 마지막 Blend와 Depth 결과만 보여 준다.

```text
최종 Pixel
└─ 보이는 Color 하나

숨겨진 과정
├─ Fragment 1 실행
├─ Fragment 2 실행
├─ Fragment 3 실행
└─ Fragment 4 실행
```

화면이 단순해 보여도 투명한 Fullscreen Panel과 Particle가 겹쳐 있을 수 있다.

Visual Debug Mode와 GPU Capture가 필요한 이유다.

---

## Unity의 Overdraw Draw Mode

Unity Editor의 Scene View Draw Mode에서 Overdraw를 선택하면 겹쳐 그려지는 영역을 누적 Color로 시각화할 수 있다.

```text
낮은 Overdraw
→ 어두운 영역

높은 Overdraw
→ 밝게 누적된 영역
```

Unity 공식 성능 문서는 Overdraw Draw Mode로 겹친 UI, Particle와 Sprite 문제 영역을 찾도록 안내한다.

Scene View와 Game Camera의 Culling, Resolution과 Post-processing 조건이 다를 수 있으므로 실제 Game View 결과와 함께 본다.

---

## Overdraw View의 한계

대부분의 Overdraw 시각화는 원래 Material의 복잡한 Shader를 단순한 누적 Shader로 대체한다.

```text
실제 Scene
Layer A: 1 Texture Sample
Layer B: 12 Texture Samples + Lighting

Overdraw View
Layer A와 B를 비슷한 밝기로 표시 가능
```

밝은 영역은 Fragment Layer가 많은 위치를 알려 주지만 실제 GPU 비용의 정확한 열 지도는 아니다.

Fullscreen Post-process, Compute Shader와 일부 Custom Pass가 표시되지 않을 수도 있다.

---

## URP Rendering Debugger

URP Rendering Debugger는 Lighting, Rendering과 Material Property를 시각화해 Scene 구성 문제를 찾는 도구다.

```text
Window
└─ Analysis
   └─ Rendering Debugger
```

Editor Window, Game View Overlay, Play Mode 또는 지원되는 Build에서 사용할 수 있다.

Unity Version에 따라 제공되는 Fullscreen Debug Mode와 Overdraw 관련 시각화가 달라질 수 있다.

현재 URP Package의 Debugger Reference에서 지원 Mode를 확인한다.

---

## Frame Debugger

Frame Debugger는 같은 Pixel 위치의 Fragment 수를 직접 표시하는 도구는 아니지만 어떤 Draw가 화면을 덮는지 확인할 수 있다.

```text
Frame Events
├─ Opaque Draws
├─ Skybox
├─ Transparent Draw 0
├─ Transparent Draw 1
├─ Particle Draws
├─ Post-processing
└─ UI Draws
```

Event를 한 단계씩 진행하며 큰 Quad와 Fullscreen Pass가 Color를 반복해서 쓰는지 확인한다.

Overdraw View에서 밝은 영역을 만든 Renderer를 실제 Draw Event와 연결한다.

---

## GPU Profiler와 RenderDoc

정확한 병목은 Pass별 GPU 시간을 측정해야 한다.

```text
GPU Capture 질문
├─ Transparent Pass가 몇 ms인가?
├─ Fragment Shader Invocation이 많은가?
├─ Early-Z Reject 비율은 어떤가?
├─ Blend와 Color Write Bandwidth가 큰가?
├─ 어떤 Render Target이 Fullscreen Write되는가?
└─ Resolution을 낮추면 시간이 크게 줄어드는가?
```

Hardware Counter 이름과 제공 여부는 GPU Vendor와 Tool에 따라 다르다.

RenderDoc은 Draw별 Resource와 Pipeline State를 확인하는 데 유용하고 Vendor Profiler는 Fill-rate·Bandwidth Counter를 더 자세히 제공할 수 있다.

---

## Resolution A/B Test

Fill-rate 병목을 빠르게 추정하는 방법은 Render Resolution을 크게 낮춰 보는 것이다.

```text
Test A: Render Scale 1.0
GPU Frame = 18 ms

Test B: Render Scale 0.5
GPU Frame = 8 ms
```

Pixel 수를 줄였을 때 GPU 시간이 크게 감소하면 Fragment, Post-process와 Bandwidth 병목 가능성이 높다.

그러나 Resolution 변화가 LOD, Dynamic Resolution, UI와 다른 System에 영향을 줄 수 있으므로 확정 진단은 GPU Capture로 한다.

---

## Overdraw를 줄이는 기본 방향

```text
Geometry
├─ 가려진 Opaque를 Culling
├─ Front-to-Back 효율 개선
└─ 필요한 경우 Depth Prepass 비교

Transparency
├─ Screen Coverage 축소
├─ 겹친 Layer 감소
├─ 보이지 않는 Element 제거
└─ 가능한 경우 Opaque·Alpha Clip 전환

Shader
├─ Overdraw가 많은 Material 단순화
├─ Texture Sample 감소
└─ Low Quality Variant 제공

Resolution
├─ Render Scale 조정
└─ Dynamic Resolution 검토
```

한 방법이 다른 비용을 만들 수 있으므로 순서대로 측정한다.

---

## Opaque로 바꾸면 무조건 좋을까?

Transparent를 Opaque로 바꾸면 Depth Write와 Early-Z에 유리할 수 있다.

하지만 실제 반투명 표현이 필요하면 화면 결과가 달라진다.

Alpha Clipping은 Blend Overdraw를 줄일 수 있지만 Texture Sample과 Jagged Edge, MSAA·Alpha-to-Coverage 비용이 생긴다.

```text
Opaque
→ Depth 효율 좋음, 반투명 불가

Alpha Clip
→ Cutout 표현, Shader·Edge 비용

Transparent
→ 부드러운 Alpha, 높은 Overdraw 가능
```

Art 요구사항에 맞는 Surface Type을 선택한다.

---

## Overdraw 최적화 우선순위

```text
1. GPU Bound인지 확인
2. Resolution 감소 Test로 Fragment 민감도 확인
3. Overdraw View로 문제 영역 찾기
4. Frame Debugger로 원인 Draw 확인
5. Fullscreen Transparent·Particle·UI Layer부터 축소
6. 비싼 Fragment Shader와 Alpha Clip 확인
7. Opaque Sorting·Depth Prepass 비교
8. Render Scale·Quality Level 조정
9. Target Device GPU Capture
10. 화면 회귀 검사
```

작고 눈에 띄지 않는 영역보다 화면을 넓게 덮고 여러 Layer가 겹치는 영역부터 처리한다.

---

## 비교할 때 고정할 조건

- Camera 위치와 FOV
- 화면 Resolution과 Render Scale
- Particle Simulation Time
- UI 상태와 Animation
- Transparent Sorting
- Light와 Shadow
- Post-processing
- Graphics API
- MSAA와 HDR
- Target Device의 Thermal 상태

```text
Before
Transparent Pass: 6 ms
GPU Frame       : 20 ms

After
Transparent Pass: 3 ms
GPU Frame       : 17 ms
```

Overdraw Layer를 줄인 결과가 전체 Frame Time에 실제로 반영되는지 확인한다.

---

## 흔한 오해

### Overdraw는 Transparent Object에서만 생긴다

Opaque Geometry도 겹치지만 Depth Test와 Early-Z로 비싼 Fragment Shader 실행을 줄일 수 있다.

### 최종 Pixel이 한 번 보이면 Shader도 한 번 실행된다

뒤에서 덮이거나 Blend된 여러 Fragment가 이미 실행됐을 수 있다.

### Alpha가 0이면 비용도 0이다

Alpha를 계산하기 위한 Texture Sample과 Fragment Shader, Blend가 수행될 수 있다.

### Triangle이 적으면 Overdraw도 적다

Fullscreen Quad 두 Triangle만으로 수백만 Pixel을 덮을 수 있다.

### Overdraw View가 밝으면 정확히 그만큼 느리다

Layer 수를 시각화하지만 실제 Shader 복잡도, Early-Z, Bandwidth와 Post-process 비용은 다르게 나타날 수 있다.

### Depth Prepass는 항상 Overdraw를 해결한다

Color Fragment는 줄일 수 있지만 Draw Call, Vertex 처리와 Depth Bandwidth를 추가한다.

### Draw Call을 줄이면 Overdraw도 줄어든다

하나의 Batch나 Instanced Draw 안에서도 많은 Layer와 Pixel을 그릴 수 있다.

### Resolution을 낮추면 모든 Rendering 비용이 같은 비율로 줄어든다

CPU Draw, Vertex, Culling과 Native Resolution UI 같은 비용은 같은 비율로 줄지 않는다.

### Mobile Tile GPU는 Overdraw가 공짜다

On-chip Tile Memory가 외부 Bandwidth를 줄여도 Fragment Shader와 Blend 작업은 남는다.

---

## 최종 체크리스트

```text
화면
□ Fullscreen Transparent Layer가 겹치는가?
□ Alpha 0인 Object가 계속 Rendering되는가?
□ Sprite Texture의 투명 여백이 큰가?
□ Particle가 화면 중앙에 과도하게 밀집하는가?

Opaque
□ Front-to-Back와 Early-Z가 효과적인가?
□ 가려진 Geometry를 Culling할 수 있는가?
□ Depth Prepass의 이득이 추가 Draw보다 큰가?
□ Alpha Clip Foliage의 빈 영역이 큰가?

GPU
□ Resolution 감소 시 GPU 시간이 줄어드는가?
□ Transparent·UI·Particle Pass가 비싼가?
□ Fragment Shader와 Texture Sample이 복잡한가?
□ Blend와 Render Target Bandwidth가 큰가?

도구
□ Overdraw Draw Mode로 위치를 찾았는가?
□ Frame Debugger로 원인 Draw를 찾았는가?
□ GPU Profiler에서 Pass 시간을 측정했는가?
□ Target Device의 Hardware Counter를 확인했는가?
```

---

## 정리

Overdraw는 같은 Screen Pixel 위치에 여러 Fragment가 겹쳐 Shader, Depth, Blend와 Color Write가 반복되는 현상이다.

최종 화면에는 한 Color만 보여도 뒤에서 가려지거나 투명하게 Blend된 여러 Layer의 GPU 작업이 이미 수행됐을 수 있다.

Opaque Geometry는 Depth Buffer, Front-to-Back Sorting과 Early-Z로 가려진 Fragment Shader 실행을 줄일 수 있지만 조건에 따라 효과가 제한된다.

Transparent는 뒤 Color가 Blend에 필요하고 Depth Write를 끄는 경우가 많아 겹친 Layer마다 Fragment 작업이 누적되기 쉽다.

Overdraw 비용은 Resolution, Screen Coverage, Layer 수, MSAA, Fragment Shader 복잡도와 Memory Bandwidth가 함께 결정한다.

UI, Particle, Sprite, Decal과 Fullscreen Pass는 적은 Triangle으로도 넓은 Pixel 영역을 반복 처리해 Fill-rate 병목을 만들 수 있다.

Unity Overdraw Draw Mode는 문제 영역을 찾는 도구이며 실제 비용은 Frame Debugger의 Draw 구조와 GPU Profiler·Vendor Tool의 Pass 시간으로 확인해야 한다.

최적화는 화면을 넓게 덮는 겹친 Layer부터 줄이고 Depth, Shader와 Resolution 변경 전후를 Target Device에서 같은 조건으로 측정해 진행해야 한다.
