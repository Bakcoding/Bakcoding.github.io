---
title: "[Unity 렌더링] 10-3. UI에서 Overdraw가 많이 발생하는 이유는 무엇일까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - UI
  - Overdraw
  - Optimization
permalink: /programming/unity-10-3-why-ui-causes-overdraw/
toc: true
toc_sticky: true
date: 2026-08-16
last_modified_at: 2026-08-16
---

Unity UI는 여러 개의 평평한 Graphic을 화면 위에 순서대로 겹쳐 그리는 구조다.

```text
Screen
  ├─ Background
  ├─ Dimmed Panel
  ├─ Window
  ├─ Image
  ├─ Text Shadow
  ├─ Text
  └─ Highlight
```

최종 화면에서 한 Pixel만 보이더라도 해당 위치를 덮는 UI Layer마다 Fragment가 생성되고 Blend가 실행될 수 있다.

UI는 Camera 가까이에 있다는 이유가 아니라 화면을 넓게 덮는 Transparent Quad가 많이 중첩되기 때문에 Overdraw에 취약하다.

---

## UI는 사각형을 그린다

UGUI의 `Image`, `RawImage`, `Text` 같은 Graphic은 일반적으로 Vertex로 구성된 평면 Mesh를 Canvas에 제출한다.

가장 단순한 Image는 사각형 두 Triangle이다.

```text
v0 ───────── v1
│          ／ │
│        ／   │
│      ／     │
│    ／       │
│  ／         │
v2 ───────── v3

Triangle 1 + Triangle 2
```

Triangle 수는 적지만 사각형이 차지하는 Screen Area가 크면 Rasterization되는 Fragment 수가 많아진다.

```text
UI Fragment Cost
≈ Screen Coverage
× 겹친 Layer 수
× Fragment당 Shader 비용
```

UI 성능을 Triangle 수만으로 판단하면 놓치기 쉬운 핵심이다.

---

## 화면 전체 Panel 한 장의 비용

1920 × 1080 화면을 완전히 덮는 반투명 Panel을 생각한다.

```text
Pixel 수
= 1920 × 1080
= 2,073,600
```

Panel이 단순한 Quad 한 장이어도 약 207만 Pixel 위치에 Fragment 후보를 만든다.

같은 크기의 Layer가 네 장 겹치면 개념적인 Coverage는 다음과 같이 증가한다.

```text
Background  1 Screen
Dim         1 Screen
Blur Tint   1 Screen
Popup Back  1 Screen
--------------------
합계        4 Screens
```

실제 처리량은 Clipping, Depth, Shader와 GPU 구조에 따라 달라지지만 Layer 수와 화면 면적의 곱이 중요하다는 관계는 같다.

---

## UI가 Transparent Queue를 사용하는 이유

일반적인 UI는 Texture의 Alpha와 Vertex Color의 Alpha를 이용해 배경과 섞는다.

```text
Result
= SourceColor × SourceAlpha
+ DestinationColor × (1 - SourceAlpha)
```

둥근 모서리, 글자 가장자리, Icon의 외곽과 Panel의 투명도를 표현하려면 Destination Color가 필요하다.

따라서 UI는 대체로 뒤에 그려진 Color를 읽고 현재 Color와 Blend하는 Transparent Rendering 경로를 사용한다.

```text
Scene Color
    │
    ▼
UI Background Blend
    │
    ▼
Panel Blend
    │
    ▼
Text Blend
    │
    ▼
Final Color
```

뒤 Layer가 최종적으로 가려지더라도 먼저 처리한 Pixel 비용을 되돌릴 수는 없다.

---

## UI는 Painter's Algorithm에 가깝다

Canvas의 Graphic은 Hierarchy와 Sorting 설정에 따라 정해진 순서로 그려진다.

```text
Hierarchy 위쪽
Background
Panel
Button
Text
Tooltip
Hierarchy 아래쪽

대체로 뒤에 제출된 UI가 앞 결과 위에 그려짐
```

이 방식은 겹침 결과를 예측하기 쉽지만 앞의 불투명 UI가 뒤 UI를 가린다는 사실을 이용해 모든 Pixel Shader 실행을 자동 제거해 주지는 않는다.

Opaque 3D Geometry의 Front-to-Back Sorting과 Depth Write에서 얻는 Early-Z 이점을 UI에서는 기대하기 어렵다.

---

## 투명도가 낮아도 비용은 작아지지 않는다

Alpha가 `1.0`인 Panel과 `0.05`인 Panel은 결과에 기여하는 Color의 양은 다르다.

그러나 둘 다 화면 전체를 Rasterize하고 Fragment Shader와 Blend를 수행할 수 있다.

```text
Alpha 1.00 → 눈에 크게 보임 → Pixel 처리
Alpha 0.05 → 거의 안 보임   → Pixel 처리
Alpha 0.00 → 안 보임        → 설정에 따라 Pixel 처리 가능
```

시각적으로 희미한 Graphic이 GPU에도 가벼울 것이라는 추론은 성립하지 않는다.

완전히 보이지 않는 UI는 단순히 Alpha만 0으로 두기보다 Rendering 제출 자체를 멈출 수 있는지 확인해야 한다.

---

## CanvasGroup Alpha 0의 함정

`CanvasGroup.alpha = 0`은 자식 UI의 최종 Alpha를 0으로 만든다.

하지만 Alpha 0이 곧 Canvas에서 Graphic이 제거된다는 의미는 아니다.

```text
CanvasGroup alpha = 0
        │
        ├─ Layout과 Hierarchy는 존재
        ├─ Graphic이 Batch에 남을 수 있음
        └─ 투명 Fragment가 처리될 수 있음
```

숨긴 화면을 계속 유지해야 한다면 다음 항목을 구분한다.

| 방법 | Rendering | Layout·Script 상태 | 주의점 |
|---|---|---|---|
| Alpha만 0 | 남을 수 있음 | 대부분 유지 | 보이지 않는 Overdraw 가능 |
| Graphic 비활성화 | 해당 Graphic 제외 | Object는 유지 | 다시 켤 때 Rebuild 가능 |
| GameObject 비활성화 | 하위 Rendering 제외 | 동작도 중단 | Enable 시 Layout·Canvas 갱신 가능 |
| Canvas 비활성화 | Canvas Rendering 중단 | 구성에 따라 다름 | 독립 Canvas일 때 관리하기 쉬움 |

정답은 화면 전환 빈도와 Rebuild 비용에 따라 달라진다.

GPU Overdraw를 줄이다가 매 Frame UI를 켜고 꺼 CPU Rebuild를 늘리지 않도록 함께 측정해야 한다.

---

## 투명 Texture의 빈 공간도 사각형 안에 있다

별 모양 Icon을 큰 투명 Texture에 배치했다고 가정한다.

```text
┌────────────────────┐
│                    │
│        ★           │
│                    │
└────────────────────┘

보이는 영역: ★
Mesh 영역: 전체 사각형
```

기본 Quad는 별 주변의 투명 Pixel까지 Rasterize한다.

Shader가 Alpha 0을 출력하더라도 Texture Sample과 Alpha 계산이 이미 실행된 뒤일 수 있다.

Sprite의 Mesh Type, Tight Mesh 사용 가능 여부, Atlas Padding과 Rect 크기를 점검하는 이유다.

단, Tight Mesh는 Vertex 수와 Batch 구성에 영향을 줄 수 있으므로 Screen Coverage 감소 효과와 함께 비교해야 한다.

---

## Image Type에 따라 Geometry가 달라진다

UGUI Image는 표시 방식에 따라 생성하는 Geometry와 Sampling 구조가 달라진다.

| Image Type | 일반적인 용도 | Overdraw 관점 |
|---|---|---|
| Simple | 단일 Image | Rect 전체 Coverage 확인 |
| Sliced | 9-Slice Panel | 투명 Center와 Border 중첩 여부 확인 |
| Tiled | 반복 Pattern | 생성 Geometry와 Sample 영역 확인 |
| Filled | Gauge·Cooldown | Fill Amount만큼 Geometry가 줄어드는지 확인 |

빈 공간이 많은 Source Image를 큰 Rect에 `Simple`로 그리면 보이는 모양보다 훨씬 넓은 영역을 처리할 수 있다.

반대로 세밀한 Geometry 최적화가 아주 작은 Icon 수천 개의 CPU·Vertex 비용을 늘릴 수도 있다.

최적화 기준은 Asset 모양이 아니라 Target Device의 GPU Time이다.

---

## Panel 중첩이 빠르게 누적된다

UI Prefab을 독립적으로 만들면 각 Prefab이 자신의 Background와 Dim Layer를 포함하기 쉽다.

```text
HUD Canvas
├─ Fullscreen Background
├─ Inventory
│  ├─ Dim
│  ├─ Window
│  └─ Item Grid
└─ Tooltip
   ├─ Background
   └─ Text
```

각 구성 요소만 보면 합리적이지만 동시에 활성화되면 같은 Pixel을 여러 번 덮는다.

```text
한 Pixel의 Layer
Scene
→ HUD Tint
→ Inventory Dim
→ Window
→ Item Slot
→ Selected Overlay
→ Tooltip Shadow
→ Tooltip Background
→ Text
```

Prefab 단위 검토만으로는 실제 Screen에서 형성되는 Layer Stack을 발견하기 어렵다.

최종 조합 상태를 Overdraw View로 확인해야 한다.

---

## 불투명하게 보이는 UI도 Blend될 수 있다

Alpha가 항상 1인 Background Image라도 UI 기본 Material과 Canvas 경로에서는 Transparent Blend State를 사용할 수 있다.

```text
시각적 상태: 완전 불투명
Rendering 상태: Transparent Blend
```

이 경우 Background가 앞 내용을 완전히 가리더라도 앞서 그린 Layer의 비용은 이미 발생했다.

불투명 UI를 별도 Material이나 구조로 바꾸는 최적화는 가능하지만 다음 요소를 함께 검토해야 한다.

```text
검토 항목
├─ Canvas Draw Order
├─ Depth Test·Write
├─ 다른 UI와의 Batching
├─ Mask·Clip 호환성
├─ Camera Stack
└─ Platform별 결과
```

Material만 Opaque로 바꾸면 UI 순서가 깨질 수 있으므로 측정 없이 일반 규칙으로 적용하면 안 된다.

---

## Text는 많은 작은 Quad로 구성된다

Text는 문자열 전체가 하나의 사각형인 것이 아니라 보통 Glyph별 Quad가 생성된다.

```text
"UNITY"

[U][N][I][T][Y]
 5 Glyph Quads
```

Glyph Texture Atlas에는 글자 모양 밖의 투명 영역이 존재한다.

Text가 여러 줄 겹치거나 큰 Font Size로 화면을 덮으면 Glyph Quad의 투명 부분도 Overdraw에 참여한다.

TextMeshPro의 SDF Shader는 단순 Texture 출력보다 Outline, Underlay, Glow 같은 효과를 추가할 수 있다.

```text
SDF Text Fragment
├─ Atlas Sample
├─ Distance 판정
├─ Face Color
├─ Outline
├─ Underlay
└─ Glow
```

활성화한 효과와 Shader Keyword가 많을수록 각 Glyph Fragment의 계산량이 증가할 수 있다.

---

## Shadow와 Outline은 Layer를 늘린다

UGUI의 Shadow는 원본 Graphic의 Vertex를 Offset 위치에 복제해 그림자처럼 그린다.

Outline은 여러 방향으로 Geometry를 복제한다.

```text
Original Text
   ├─ Left Copy
   ├─ Right Copy
   ├─ Up Copy
   ├─ Down Copy
   └─ Original
```

효과 하나가 단순히 Color 연산 한 번을 추가하는 것이 아니라 처리할 Geometry와 Fragment Coverage를 늘릴 수 있다.

큰 Text, 긴 문장, 넓은 Outline Offset에서는 겹친 Glyph 영역의 Overdraw가 빠르게 커진다.

SDF Shader 내부에서 처리하는 Outline과 Geometry 복제 방식은 비용 구조가 다르므로 같은 시각 결과로 A/B Test해야 한다.

---

## Drop Shadow를 여러 Graphic으로 만들 때

Button 그림자를 별도 Image로 만들면 구조가 명확하지만 Layer가 하나 추가된다.

```text
Button
├─ Shadow Image
├─ Background Image
├─ Icon
└─ Label
```

Button 100개가 동시에 표시되면 Shadow Image도 100개다.

각 Shadow가 넓고 흐릿한 Texture Padding을 가지면 실제 보이는 어두운 부분보다 훨씬 큰 사각형이 중첩될 수 있다.

Atlas에서 불필요한 투명 여백을 줄이고, 반복되는 효과를 꼭 필요한 상태에만 표시하는 편이 효과적일 수 있다.

---

## Scroll View는 Layer가 집중되는 구간이다

Scroll View에는 Viewport, Mask, Content, Item Background, Icon, Text와 선택 효과가 겹친다.

```text
Scroll View
├─ Viewport + Mask
├─ Content
│  ├─ Item 01
│  │  ├─ Background
│  │  ├─ Icon
│  │  ├─ Label
│  │  └─ Selection
│  ├─ Item 02
│  └─ ...
└─ Scrollbar
```

화면에 보이지 않는 Item까지 활성화되어 있으면 Canvas Geometry, Layout, Animation과 Rendering 후보가 함께 늘어난다.

Viewport 밖 Fragment는 Mask로 잘리더라도 Item을 생성하고 관리하는 CPU 비용이 사라지는 것은 아니다.

긴 목록은 Object Pooling과 Virtualization을 이용해 화면 주변 Item만 유지하는 방식을 검토한다.

---

## RectMask2D의 Clipping

`RectMask2D`는 사각형 영역 밖의 UI를 Clip하는 데 적합하다.

```text
┌──── Viewport ────┐
│ visible content │
└──────────────────┘
  clipped content
```

화면 밖 Fragment의 최종 출력을 막아 불필요한 Coverage를 줄이는 데 도움이 될 수 있다.

하지만 Mask가 있다고 해서 내부 Item 수, Layout 계산, Canvas Rebuild와 모든 Geometry 제출 비용이 자동으로 줄어드는 것은 아니다.

Clipping과 Item Virtualization은 서로 다른 문제를 해결한다.

---

## Mask와 Stencil Pass

일반 `Mask`는 Mask Graphic의 모양을 이용하기 위해 Stencil Buffer를 활용한다.

개념적인 흐름은 다음과 같다.

```text
Mask Shape Draw
→ Stencil 값 기록
→ Child UI Draw
→ Stencil Test로 영역 제한
→ Stencil 정리
```

Mask 계층이 중첩되면 Stencil State와 Material Variant가 늘고 추가 Draw가 발생할 수 있다.

Mask의 `Show Mask Graphic`을 끄더라도 Masking을 위한 처리가 모두 사라지는 것은 아니다.

단순 사각 Viewport라면 `RectMask2D`가 목적에 더 맞는지 비교하고, 복잡한 모양의 Mask는 필요한 범위에만 둔다.

---

## Mask는 Overdraw를 공짜로 제거하지 않는다

Mask 밖 Pixel이 잘리는 시점은 Shader와 Pipeline 구성에 영향을 받는다.

```text
Fragment 후보 생성
→ Clip·Stencil 판정
→ Color 출력 여부 결정
```

최종 Color가 기록되지 않았다고 해서 Rasterization과 앞 단계의 모든 비용이 0이라는 뜻은 아니다.

Mask를 최적화 기능으로만 생각하기보다 UI 표현을 위한 기능으로 보고 실제 GPU Capture에서 Pass와 Pixel 비용을 확인해야 한다.

---

## Nested Canvas는 Overdraw를 직접 해결하지 않는다

Canvas를 나누면 변경된 UI만 Rebuild하도록 CPU 비용을 격리할 수 있다.

```text
Root Canvas
├─ Static Canvas
├─ Dynamic HUD Canvas
└─ Popup Canvas
```

그러나 같은 화면 영역을 덮는 Graphic 수가 그대로라면 Pixel Overdraw도 그대로 남을 수 있다.

```text
Canvas 분할 전: Layer 6개
Canvas 분할 후: Layer 6개
Pixel Coverage: 동일할 수 있음
```

Canvas 분할은 주로 Canvas Rebuild, Batch와 Update 빈도 문제를 다루며 Overdraw 감소는 Graphic Coverage를 줄였을 때 발생한다.

---

## Canvas를 너무 많이 나눌 때

각 Canvas는 자체적인 Geometry와 Draw Order 경계를 만든다.

Material과 Texture가 같아도 Canvas 경계를 넘어 하나의 Batch로 합쳐지지 않을 수 있다.

```text
Canvas A: Image Material M
Canvas B: Image Material M

동일 Material이어도 별도 Canvas Batch 가능
```

Canvas를 분할해 CPU Rebuild는 줄였지만 Batch와 Draw Call이 증가할 수 있다.

또한 Override Sorting을 사용한 Nested Canvas는 Sorting Order 관리가 복잡해져 의도하지 않은 Layer 중첩을 만들 수 있다.

Canvas 분할은 정적·동적 갱신 빈도와 화면 전환 단위를 기준으로 결정한다.

---

## Canvas Render Mode의 차이

UGUI Canvas는 대표적으로 다음 Render Mode를 사용한다.

| Render Mode | 위치 | Overdraw 관점 |
|---|---|---|
| Screen Space - Overlay | Scene 이후 화면에 표시 | 화면 Coverage가 직접 비용으로 연결 |
| Screen Space - Camera | 지정 Camera를 통해 표시 | Camera·Plane Distance·Sorting 확인 |
| World Space | 3D 공간에 배치 | 거리와 투영 크기, 다른 Geometry와의 겹침 확인 |

Render Mode가 다르다고 UI의 투명 Fragment가 사라지는 것은 아니다.

World Space UI는 멀어지면 화면 Coverage가 작아질 수 있지만 여러 Billboard가 겹치면 Scene Transparency Overdraw와 같은 문제가 생긴다.

Screen Space UI는 Resolution이 높아질수록 Fullscreen Panel의 Pixel 수가 직접 증가한다.

---

## Camera Stack과 UI

URP Camera Stack에서 Base Camera와 Overlay Camera를 이용해 UI를 합성할 수 있다.

```text
Base Camera
→ World Rendering
→ Overlay Camera UI
→ Final Target
```

이 구조는 Layer 관리에 유용하지만 UI Pixel 비용을 자동으로 줄이지 않는다.

Camera별 Clear, Intermediate Texture, Post-processing, Render Scale과 Target 설정에 따라 추가 Fullscreen 작업이 생길 수 있다.

Frame Debugger에서 UI 이전과 이후에 어떤 Render Target과 Blit이 사용되는지 확인해야 한다.

---

## Fullscreen Dim Layer

Popup 뒤를 어둡게 만드는 Dim Image는 대표적인 Fullscreen Transparent Layer다.

```text
Scene
→ Fullscreen Dim 50%
→ Popup Window
```

Popup이 여러 개 열릴 때마다 각 Prefab의 Dim을 함께 활성화하면 동일한 화면 전체를 반복 Blend한다.

```text
Popup A Dim
Popup B Dim
Popup C Dim

시각적으로는 더 어두움
GPU에서는 Fullscreen Layer 3회
```

디자인 의도가 같다면 Popup Stack 전체가 공유하는 Dim Layer 하나로 합칠 수 있는지 검토한다.

Alpha Animation 중에는 Layer를 유지하되 전환이 끝난 숨김 상태에서는 Rendering을 중단하는 정책도 필요하다.

---

## Blur는 단순한 반투명 Panel이 아니다

UI Background Blur는 Scene Color를 Texture로 만들고 여러 Sample로 흐림을 계산한 뒤 UI와 합성할 수 있다.

```text
Scene Render
→ Scene Color Copy
→ Downsample
→ Horizontal Blur
→ Vertical Blur
→ UI Composite
```

겉보기에는 Panel 한 장이지만 내부적으로 Fullscreen 또는 넓은 영역의 Pass가 여러 번 실행될 수 있다.

Blur Radius, Sample 수, Render Texture Resolution과 Update 빈도가 비용을 결정한다.

정지된 Menu Background라면 매 Frame 다시 Blur해야 하는지, 낮은 Resolution이나 Capture 재사용이 가능한지 검토한다.

---

## UI Shader가 복잡하면 Layer당 비용이 커진다

Overdraw는 같은 Pixel을 몇 번 처리하는가의 문제이고 Shader 복잡도는 한 번 처리하는 비용이다.

```text
UI GPU Cost
≈ Overdraw Layer 수
× UI Shader Cost
× Pixel 수
```

다음 기능은 UI Fragment 비용을 높일 수 있다.

```text
Gradient
Rounded Corner SDF
Multiple Texture Sample
Noise·Dissolve
Color Space 변환
Procedural Mask
Blur
Glow
```

작은 Badge에 사용한 Shader가 Fullscreen Panel에도 공유되면 의도보다 넓은 영역에서 비싼 계산을 수행할 수 있다.

Shader Variant와 Material 용도를 화면 Coverage 기준으로 분리해 보는 편이 좋다.

---

## Mobile에서 UI Overdraw가 민감한 이유

Mobile GPU는 제한된 Memory Bandwidth와 전력 예산 안에서 높은 해상도의 화면을 처리한다.

Transparent UI Layer는 Color를 읽고 Blend한 뒤 다시 기록하므로 넓은 Coverage에서 Bandwidth 부담이 커질 수 있다.

```text
고해상도 Display
× Fullscreen UI Layer
× Blend Read·Write
× 높은 Frame Rate
= 큰 Pixel 처리량
```

Tile-based GPU도 불필요한 Fragment Shader와 Blend가 공짜인 것은 아니다.

발열과 전력 제한으로 시간이 지나며 Clock이 낮아지면 처음 실행한 짧은 Profile보다 UI 병목이 더 크게 나타날 수 있다.

---

## XR에서는 두 눈에 그릴 수 있다

XR UI는 Rendering 방식에 따라 왼쪽과 오른쪽 Eye View에 처리된다.

World Space UI가 각 Eye에서 큰 Screen Area를 덮으면 Fragment Coverage도 양쪽 View에 발생한다.

```text
Left Eye  UI Coverage
+ Right Eye UI Coverage
= Stereo Pixel Work
```

가까운 거리의 큰 Panel, 반투명 HUD와 다중 Layer는 일반 화면보다 민감할 수 있다.

XR Target Device의 실제 Render Scale과 Stereo Rendering Mode에서 측정해야 한다.

---

## Resolution이 UI 비용을 증폭한다

같은 정규화 크기의 UI는 해상도가 높을수록 더 많은 Pixel을 덮는다.

```text
1280 × 720  =   921,600 Pixels
1920 × 1080 = 2,073,600 Pixels
2560 × 1440 = 3,686,400 Pixels
3840 × 2160 = 8,294,400 Pixels
```

4K Fullscreen Layer 한 장은 1080p의 약 네 배 Pixel 위치를 처리한다.

CPU의 Canvas Rebuild 시간이 비슷해도 GPU UI 시간이 크게 달라질 수 있다.

Resolution 또는 Render Scale A/B Test에서 GPU 시간이 Pixel 수에 민감하게 변하면 Fill-rate와 Overdraw 가능성이 높다.

---

## UI Overdraw와 Batch는 다른 축이다

Batching은 CPU가 제출하는 Draw Call과 State 변경을 줄이는 문제다.

Overdraw는 GPU가 동일 Pixel 위치를 반복 처리하는 문제다.

```text
Batch 최적화
→ Draw Call 감소

Coverage 최적화
→ Fragment 처리 감소
```

여러 Panel이 하나의 Batch로 합쳐져도 겹친 Pixel은 각 Triangle에서 Rasterize될 수 있다.

반대로 Graphic 하나를 제거해 Overdraw는 줄었지만 Material이 나뉘어 Batch 수가 늘 수 있다.

두 지표를 동시에 확인해야 한다.

---

## Atlas는 Overdraw를 직접 줄이지 않는다

Sprite Atlas는 여러 Texture를 하나로 묶어 Texture State 변경과 Batch 분리를 줄이는 데 도움이 된다.

```text
Atlas 사용
→ Texture 전환 감소
→ Batch 개선 가능
```

하지만 같은 크기의 Quad와 같은 Layer 수를 그리면 Screen Coverage는 그대로다.

Atlas는 Draw Call 최적화이고 투명 Padding 제거와 Tight Geometry는 Coverage 최적화에 가깝다.

한 최적화를 다른 문제의 해결책으로 혼동하지 않아야 한다.

---

## Raycast Target은 Rendering 설정이 아니다

`Graphic.raycastTarget`은 UI Input Raycast 대상인지 결정한다.

이를 끄면 EventSystem의 Raycast 후보를 줄이는 데 도움이 될 수 있지만 Graphic Rendering 자체가 사라지는 것은 아니다.

```text
raycastTarget = false
→ Input Raycast 제외
→ Rendering은 계속 가능
```

Overdraw를 줄이려면 Graphic 비활성화, Geometry 제거 또는 Coverage 감소처럼 Rendering 경로에 영향을 주는 변경이 필요하다.

---

## Layout Component도 Overdraw를 직접 만들지는 않는다

`HorizontalLayoutGroup`, `VerticalLayoutGroup`, `ContentSizeFitter`는 RectTransform 배치를 계산한다.

Layout 계산은 주로 CPU 비용이고 Overdraw는 주로 Fragment 처리 비용이다.

```text
Layout Rebuild → CPU
Canvas Build   → CPU
UI Rasterize   → GPU
Blend          → GPU
```

다만 Layout 결과가 많은 Item을 화면에 겹치게 하거나 큰 Rect를 만들면 간접적으로 Overdraw를 늘릴 수 있다.

Profiler에서 CPU Canvas·Layout 병목과 GPU Fragment 병목을 분리해 판단한다.

---

## Animation이 숨은 Layer를 남길 수 있다

UI 전환 Animation은 Position, Scale과 Alpha를 변경한다.

이전 화면을 Fade Out하고 새 화면을 Fade In하면 전환 구간에는 두 화면이 동시에 존재한다.

```text
Old Screen Alpha 1.0 → 0.0
New Screen Alpha 0.0 → 1.0

전환 중: 두 Screen의 Graphic 처리
```

짧은 전환이라도 저사양 기기에서 가장 무거운 Frame이 될 수 있다.

Animation이 끝난 뒤 이전 Screen을 비활성화하는 Event가 누락되면 보이지 않는 Layer가 계속 남는다.

Runtime Hierarchy와 Frame Debugger로 실제 제출 여부를 확인한다.

---

## Screen 밖 UI도 확인해야 한다

RectTransform을 화면 밖으로 이동해 숨기는 구현은 Object를 비활성화하지 않는다.

완전히 Viewport 밖이면 Clipping과 Rasterization 결과가 줄 수 있지만 Canvas Build와 Batch에는 남을 수 있다.

일부만 화면에 걸쳐 있거나 큰 Rect가 회전되어 있으면 예상보다 넓은 Bounding Area가 처리될 수 있다.

```text
화면 밖 이동
≠ 모든 UI 비용 제거
```

숨김 방식은 Rendering, Layout, Input과 Animation 중 무엇을 유지해야 하는지에 맞춰 선택한다.

---

## Safe Area용 Background 중복

기기별 Safe Area를 대응하면서 Background를 Center, Top, Bottom으로 나누는 경우가 있다.

Rect가 겹치면 경계 구간이 중복 Rendering될 수 있다.

```text
Top Background
───────────────
    겹침 영역
───────────────
Main Background
```

한 장의 Stretch Image로 처리할 수 있는지, 분리해야 한다면 Rect 경계가 불필요하게 중첩되지 않는지 확인한다.

시각적으로 같은 Color라도 Graphic 수와 Coverage는 별개다.

---

## Overdraw View로 Layer 집중 영역 찾기

Unity Scene View의 Overdraw Draw Mode는 같은 위치에 겹쳐 그려지는 영역을 시각적으로 찾는 출발점이다.

```text
어두운 영역 → 적은 중첩 가능성
밝은 영역   → 많은 중첩 가능성
```

UI를 실제 Game 상태와 동일하게 열고 다음 영역을 확인한다.

```text
Fullscreen Panel
Popup Stack
Scroll View Item
Text·Outline
Mask 계층
HUD 고정 영역
```

Overdraw View의 밝기는 정확한 GPU Millisecond가 아니다.

Shader 복잡도, Blend State, Resolution과 Platform GPU 특성을 함께 반영하지 못할 수 있다.

---

## Frame Debugger로 실제 Draw 순서 확인

Frame Debugger는 Frame의 Draw Event를 순서대로 진행하며 Render Target 변화를 확인할 수 있다.

UI 분석에서는 다음 질문에 답한다.

```text
어떤 Canvas가 먼저 그려지는가?
Fullscreen Image가 몇 번 그려지는가?
Mask 때문에 추가 Event가 생겼는가?
Material 변경으로 Batch가 끊기는가?
숨긴 UI가 Draw 목록에 남아 있는가?
UI 전후에 Blit이 추가되는가?
```

Event를 한 단계씩 진행하면 최종 화면에서는 가려져 보이지 않는 Graphic도 찾을 수 있다.

Frame Debugger는 GPU 시간 측정기가 아니므로 원인 후보를 찾은 뒤 Profiler로 비용을 검증한다.

---

## Profiler에서 CPU와 GPU를 분리한다

UI 문제는 CPU Canvas Rebuild와 GPU Overdraw가 동시에 나타날 수 있다.

```text
CPU 확인
├─ Canvas.BuildBatch
├─ Layout Rebuild
├─ Graphic Rebuild
└─ Script·Animation

GPU 확인
├─ UI Pass 시간
├─ Transparent 시간
├─ Fragment 병목
└─ Render Target·Blit 시간
```

CPU Frame Time만 보고 Overdraw 개선 효과를 판정하거나, GPU Time만 보고 Canvas 분할 효과를 판정하면 결론이 어긋날 수 있다.

Target Device에서 CPU와 GPU Timeline을 각각 비교한다.

---

## RenderDoc에서 확인할 내용

GPU Capture가 필요하면 Draw별 Pipeline State와 Render Target을 확인한다.

```text
확인 항목
├─ UI Draw의 Scissor Rect
├─ Blend State
├─ Stencil State
├─ Texture와 Sampler
├─ Fragment Shader
├─ Render Target Resolution
└─ Draw별 Pixel History
```

특정 Pixel의 Pixel History를 보면 어떤 UI Draw가 같은 위치를 반복해서 덮었는지 추적할 수 있다.

지원 Platform과 Graphics API가 Capture 환경과 다르면 결과도 달라질 수 있으므로 최종 판단은 실제 Target에서 내린다.

---

## Resolution A/B Test

UI 상태와 Content를 고정하고 Resolution만 낮춰 본다.

```text
Test A: 2560 × 1440
Test B: 1280 × 720
```

GPU UI 시간이 크게 줄고 CPU Canvas 시간이 거의 유지된다면 Pixel 처리 병목 가능성이 높다.

다음에는 Fullscreen Dim, Shadow, Outline 또는 Blur를 하나씩 끄며 차이를 기록한다.

```text
Baseline
→ Dim Off
→ Text Effect Off
→ Blur Off
→ Hidden Screen Disabled
```

한 번에 하나의 변수만 바꿔야 어느 Layer가 실제 병목인지 알 수 있다.

---

## UI Overdraw를 줄이는 우선순위

효과가 큰 변경부터 다음 순서로 검토할 수 있다.

```text
1. 보이지 않는 Screen과 Graphic의 Rendering 중단
2. Fullscreen Transparent Layer 중복 제거
3. Popup·HUD의 Layer Stack 단순화
4. 큰 Texture의 투명 Padding 축소
5. Text Shadow·Outline·Glow 범위 축소
6. Scroll Item Virtualization
7. Mask 계층 단순화
8. 비싼 UI Shader와 Blur 최적화
9. 필요하면 Resolution·Render Scale 조정
```

작은 Icon의 Vertex 몇 개보다 화면 전체 Dim Layer 한 장을 제거하는 편이 더 큰 GPU 개선을 만들 수 있다.

항상 Screen Coverage가 큰 항목부터 측정한다.

---

## Layer를 합칠 때의 Trade-off

여러 정적 Image를 하나의 Bake된 Background로 합치면 Layer 수를 줄일 수 있다.

```text
Before
Background + Frame + Pattern + Decoration

After
Baked Background 1장
```

그러나 다음 비용이 생길 수 있다.

```text
큰 Texture Memory
해상도별 Asset 관리
Localization·Theme 유연성 감소
부분 변경 어려움
Download Size 증가
```

자주 바뀌지 않는 넓은 Layer에서만 이득과 유지 보수 비용을 비교한다.

---

## Graphic 제거와 Layout용 Object 분리

단순히 Layout Group의 배경 공간을 만들기 위해 투명 Image를 붙이는 경우가 있다.

```text
Layout Container
└─ Transparent Image
```

Rendering이 필요하지 않다면 `RectTransform`만 가진 GameObject로 구조를 만들 수 있는지 확인한다.

Input 수신을 위해 투명 Graphic을 쓰는 경우에도 Raycast 영역과 Rendering 요구를 분리할 대안을 검토한다.

불필요한 Graphic Component 하나가 작은 비용이어도 대규모 목록에서는 누적된다.

---

## Color만 필요한 Panel

단색 Panel에 큰 RGBA Texture를 사용하는 것보다 작은 White Texture와 Vertex Color로 표현할 수 있다.

이는 주로 Texture Memory와 Sampling Locality 관점의 개선이며 Quad Coverage 자체는 같을 수 있다.

```text
Texture 최적화 ≠ Coverage 제거
```

Panel이 완전히 가리는 영역 뒤의 UI를 함께 비활성화하거나 Layer를 합쳐야 Overdraw까지 줄어든다.

---

## 흔한 오해

### UI는 Triangle이 적으므로 가볍다

Quad 두 Triangle도 화면 전체를 덮으면 수백만 Fragment를 만든다.

UI에서는 Triangle 수보다 Screen Coverage와 Layer 수가 더 중요한 경우가 많다.

### Alpha를 0으로 만들면 그리지 않는다

Alpha 0은 최종 Color 기여가 없다는 뜻이며 Draw와 Fragment 실행이 자동으로 사라진다는 보장은 아니다.

### Canvas를 나누면 Overdraw가 줄어든다

Canvas 분할은 Rebuild 범위와 Batch를 바꾸지만 Graphic의 Pixel Coverage가 같으면 Overdraw도 유지될 수 있다.

### Sprite Atlas가 UI Overdraw를 해결한다

Atlas는 Texture State 변경과 Batch에 도움을 주지만 겹친 Quad의 Pixel 수를 직접 줄이지 않는다.

### Mask 밖은 잘리므로 비용이 전혀 없다

최종 Color Write가 차단되어도 Geometry, Rasterization, Mask Setup과 CPU 관리 비용이 남을 수 있다.

### Raycast Target을 끄면 Rendering도 꺼진다

Raycast Target은 Input 판정 설정이며 Graphic Rendering과 별개다.

### 불투명한 UI는 Opaque Object와 같다

눈으로 불투명하게 보여도 Material과 Render Queue가 Transparent Blend 경로일 수 있다.

### Draw Call이 적으면 Overdraw도 적다

한 Batch 안의 여러 Quad가 같은 Pixel을 반복해서 덮을 수 있다.

### UI 최적화는 Canvas 수를 줄이는 것이다

Canvas 수는 CPU Rebuild와 Batch 관점의 한 지표일 뿐이다.

GPU UI 비용은 Coverage, Layer, Shader, Blend와 Resolution을 함께 봐야 한다.

---

## 최종 체크리스트

```text
□ Alpha 0인 Screen이 Rendering에 남아 있지 않은가?
□ Fullscreen Dim과 Background가 중복되지 않는가?
□ Popup Stack이 각자 Dim Layer를 가지고 있지 않은가?
□ 투명 Padding이 큰 Sprite를 넓은 Quad로 그리고 있지 않은가?
□ Text Shadow·Outline·Glow가 필요한 범위에만 적용됐는가?
□ Scroll View가 화면 밖 Item까지 모두 유지하지 않는가?
□ 사각 Viewport에 불필요한 Stencil Mask를 쓰지 않는가?
□ Nested Mask와 Canvas가 과도하지 않은가?
□ Canvas 분할 목적이 Rebuild인지 Sorting인지 명확한가?
□ Blur와 Scene Color Copy가 매 Frame 필요한가?
□ Screen 밖 이동만으로 UI를 숨기고 있지 않은가?
□ Raycast 설정과 Rendering 설정을 혼동하지 않았는가?
□ Overdraw View에서 실제 조합 화면을 확인했는가?
□ Frame Debugger에서 숨은 UI Draw를 확인했는가?
□ CPU Canvas 비용과 GPU UI 비용을 분리했는가?
□ Resolution A/B Test를 수행했는가?
□ Target Device에서 GPU Time을 비교했는가?
```

---

## 정리

Unity UI는 Alpha Blend가 필요한 사각형 Graphic을 정해진 순서로 겹쳐 그리므로 같은 Screen Pixel을 여러 번 처리하기 쉽다.

Quad의 Triangle 수가 적어도 Fullscreen Panel, Dim, Background와 Popup이 중첩되면 Resolution과 Layer 수에 비례해 Fragment와 Blend 비용이 증가한다.

Alpha 0, 투명 Texture Padding과 화면 밖 이동은 Graphic의 Rendering 제출을 자동으로 제거하지 않으므로 보이지 않는 UI도 비용을 만들 수 있다.

Text의 Glyph Quad, Shadow·Outline, Scroll Item, Stencil Mask와 Blur는 Geometry, Layer, Pass 또는 Fragment Shader 비용을 추가한다.

Canvas 분할과 Sprite Atlas는 CPU Rebuild와 Batch 최적화에 유용하지만 Pixel Coverage가 그대로라면 Overdraw를 직접 줄이지 않는다.

Fullscreen Layer 중복 제거, 숨은 Screen 비활성화, Layer Stack 단순화와 긴 목록 Virtualization처럼 화면을 덮는 Fragment 자체를 줄이는 변경부터 검토한다.

Overdraw View로 집중 영역을 찾고 Frame Debugger로 실제 UI Draw 순서를 확인한 뒤 CPU와 GPU Profile을 분리해 Target Device에서 효과를 검증해야 한다.
