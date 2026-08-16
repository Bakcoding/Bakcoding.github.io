---
title: "[Unity 렌더링] 6-7. Forward와 Deferred는 무엇이 다를까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - URP
  - ForwardRendering
  - DeferredRendering
permalink: /programming/unity-6-7-forward-vs-deferred/
toc: true
toc_sticky: true
date: 2026-08-16
last_modified_at: 2026-08-16
---

Forward와 Deferred는 같은 Scene을 다른 순서로 Lighting한다.

Forward는 Geometry를 그리는 순간 Material과 Light를 계산해 Camera Color에 기록한다.

Deferred는 Geometry의 Surface Data를 G-buffer에 저장하고 별도의 화면 공간 Pass에서 Lighting한다.

```text
Forward
Geometry + Material + Light
            │
            ▼
         Final Color

Deferred
Geometry + Material
            │
            ▼
         G-buffer
            │ + Light
            ▼
         Final Color
```

두 방식의 차이는 Light 처리뿐 아니라 Memory, Draw, Transparency, MSAA, Material과 Target Hardware에 영향을 준다.

어느 방식이 항상 빠르다고 결론 내릴 수 없는 이유다.

---

## 핵심 차이 한눈에 보기

| 항목 | Forward | Deferred |
| --- | --- | --- |
| Lighting 시점 | Geometry Draw와 동시에 계산 | G-buffer 생성 이후 계산 |
| Surface Data | Shader 내부에서 바로 사용 | 여러 G-buffer에 저장 후 복원 |
| Opaque Object별 Light | 제한 있음 | 제한 없음 |
| Additional Light 비용 | Fragment Light Loop | 화면의 Light 영향 영역 |
| 기본 Render Target | Color와 Depth 중심 | 여러 G-buffer와 Depth·Stencil |
| Memory Bandwidth | 비교적 낮을 가능성 | MRT Write와 Read 비용 큼 |
| Transparent | Forward | Forward |
| MSAA | 지원 | 지원하지 않음 |
| Normal | Encoding 없이 직접 사용 | G-buffer Encoding·Decoding |
| Material 유연성 | 비교적 높음 | G-buffer Layout 제약 |
| 적합한 조건 | 적은 Light, Mobile, MSAA | 많은 Opaque Local Light |

표는 출발점이며 실제 결과는 Scene과 Platform에 따라 달라진다.

---

## 같은 목표, 다른 작업 순서

두 Path 모두 최종적으로 Surface의 Lighting Color를 계산한다.

차이는 Surface Data와 Light가 만나는 시점이다.

```text
Forward Pixel
Material 읽기
→ Normal 계산
→ Main Light
→ Additional Light Loop
→ Reflection과 GI
→ Color 출력

Deferred Pixel
Geometry Pass에서 Material Data 저장
→ Lighting Pass에서 G-buffer 읽기
→ Position과 Normal 복원
→ 해당 Light 계산
→ Color에 누적
```

이 순서 차이가 각 방식의 장점과 비용을 만든다.

---

## Forward의 Lighting 구조

일반 Forward는 Object를 그릴 때 해당 Object의 Light 목록을 사용한다.

```text
Object A
├─ Main Light
├─ Additional Light 0
├─ Additional Light 1
└─ Additional Light 2
        │
        ▼
UniversalForward Pass
        │
        ▼
Camera Color
```

URP Asset의 `Per Object Limit`이 Object가 계산할 Additional Light 수를 제한한다.

Light 기여는 하나의 Geometry Pass 내부 Shader Loop에서 누적된다.

---

## Deferred의 Lighting 구조

Deferred는 Object를 그릴 때 Realtime Light 목록을 순회하지 않는다.

먼저 Opaque Surface를 G-buffer에 기록한다.

```text
All Opaque Geometry
        │
        ▼
G-buffer + Depth
        │
        ├─ Directional Light
        ├─ Point Light Volume
        └─ Spot Light Volume
        │
        ▼
Lighting Target
```

Light가 영향을 주는 화면 Pixel에서 G-buffer Surface를 읽고 BRDF를 계산한다.

Opaque Object별 Light 제한을 사용하지 않는다.

---

## 반복의 축이 다르다

Forward와 Deferred는 Lighting 반복 기준이 다르다.

```text
Forward
Object Fragment × Object에 선택된 Light

Deferred
Screen Pixel × 그 Pixel에 영향을 주는 Light
```

Forward는 Object Light List가 짧을 때 유리할 수 있다.

Deferred는 많은 Local Light가 여러 Opaque Object에 겹칠 때 같은 Surface Data를 재사용할 수 있다.

화면 전체에 영향을 주는 Light가 많으면 Deferred도 Pixel마다 Lighting을 반복한다.

---

## Light가 하나인 Scene

Main Directional Light 하나와 Baked GI만 있는 Scene을 생각할 수 있다.

```text
Forward
Geometry → Main Light → Color

Deferred
Geometry → 여러 G-buffer
→ G-buffer Read → Main Light → Color
```

이 조건에서는 Deferred의 MRT Write와 Lighting Pass 고정 비용을 회수하기 어려울 수 있다.

Forward의 직접적인 구조가 더 적합한 후보가 된다.

하지만 Material, Overdraw와 Target GPU가 결과를 바꿀 수 있으므로 측정이 필요하다.

---

## Local Light가 많은 Scene

Night City나 Indoor Dungeon처럼 Point와 Spot Light가 많이 겹치는 Scene을 생각할 수 있다.

```text
Opaque Wall Pixel
├─ Lamp A
├─ Lamp B
├─ Sign C
├─ Torch D
└─ Vehicle E
```

일반 Forward는 Object Light Limit 때문에 일부 Light를 제외할 수 있다.

Deferred는 해당 Pixel에 영향을 주는 Light를 화면 공간에서 누적할 수 있다.

Opaque Surface의 많은 Realtime Light가 중요한 경우 Deferred의 장점이 커진다.

---

## Object별 Light 제한 비교

Unity 6 공식 비교표는 일반 Forward의 Object당 Realtime Light를 Main Directional Light 1개와 설정에 따른 Additional Light 최대 8개로 설명한다.

Deferred의 Opaque Object에는 이 Per Object Limit가 없다.

```text
Forward Opaque Object
└─ Main 1 + Additional 최대 8

Deferred Opaque Object
└─ Object별 제한 없음
```

Camera당 Visible Light와 Platform별 Resource 제한은 두 Path 모두 존재한다.

Transparent는 Deferred Renderer에서도 Forward로 그리므로 일반 Forward의 제한을 받는다.

---

## Light Pop 가능성

일반 Forward에서는 제한된 Object Light List가 Camera나 Object 이동에 따라 바뀔 수 있다.

```text
Frame A
Object → L1, L2, L3, L4

Frame B
Object → L1, L2, L3, L5
                     ↑ 교체
```

Light 기여가 갑자기 바뀌어 Pop처럼 보일 수 있다.

Deferred Opaque는 Object별 목록 교체가 없지만 Light Culling 경계, Shadow와 Temporal Effect에서 다른 변화가 나타날 수 있다.

---

## 큰 Mesh의 차이

일반 Forward는 Object Bounds를 기준으로 Light 후보를 구성한다.

큰 Floor Mesh에 여러 지역 Light가 겹치면 같은 Object Limit를 공유한다.

```text
Forward Large Mesh
┌──────────────────────┐
│ L1  L2  L3  L4  L5 │
└──────────────────────┘
→ 제한된 Object List

Deferred
→ 각 Screen Pixel에 실제 영향 Light 계산
```

Forward에서는 Mesh를 나누면 지역 Light 선택이 개선될 수 있지만 Draw와 Renderer 수가 증가한다.

Deferred는 이 문제에서 더 자연스럽지만 G-buffer 비용을 지불한다.

---

## G-buffer 유무

Forward의 핵심 Color Pass는 Material과 Light를 계산해 Color와 Depth를 기록한다.

Deferred는 여러 G-buffer Target이 필수다.

```text
Forward 기본
├─ Camera Color
└─ Camera Depth

Deferred 기본 개념
├─ Albedo + Material Flags
├─ Specular / Metallic + Occlusion
├─ Normal + Smoothness
├─ Emission / GI / Lighting
└─ Depth + Stencil
```

Shadow, Post-processing과 Renderer Feature용 Texture는 두 Path 모두 추가될 수 있다.

---

## G-buffer가 제공하는 Data

Deferred Lighting은 Geometry를 다시 읽지 않고 G-buffer로 Surface를 복원한다.

- Albedo
- Material Flags
- Metallic 또는 Specular
- Occlusion
- World Normal
- Smoothness
- Emission과 Baked GI
- Depth와 Material Type

```text
Screen UV
+ G-buffer Channels
+ Depth
        │
        ▼
Lighting에 필요한 Surface 복원
```

저장 Channel이 제한되어 Custom Material Model에 제약이 생긴다.

---

## Forward의 Surface Data

Forward는 Shader가 필요한 Surface Data를 Local Variable로 계산해 바로 사용한다.

```text
Material Texture
        │
        ▼
SurfaceData
├─ Albedo
├─ Normal
├─ Metallic
├─ Smoothness
└─ Custom Parameter
        │
        ▼
Lighting 후 폐기
```

G-buffer Layout에 저장할 필요가 없어 특수 Material Model을 구성하기 쉽다.

대신 Light마다 BRDF를 같은 Fragment Shader에서 반복한다.

---

## Normal 품질 비교

Forward는 Fragment에서 계산한 Normal을 Lighting에 직접 사용한다.

Deferred는 Normal을 G-buffer에 Encoding하고 Lighting Pass에서 Decoding한다.

```text
Forward
Normal Map → normalWS → Lighting

Deferred
Normal Map → normalWS → Encode
→ G-buffer → Decode → Lighting
```

기본 Deferred Encoding은 Quantization Artifact를 만들 수 있다.

Accurate G-buffer Normals는 품질을 높이지만 Encode·Decode 비용과 일부 기능 제한이 있다.

---

## Material 유연성 비교

| 항목 | Forward | Deferred |
| --- | --- | --- |
| Custom BRDF | Shader 안에서 직접 구성하기 쉬움 | Deferred Lighting까지 확장 필요 가능 |
| 저장 Parameter | Local Data로 비교적 자유로움 | G-buffer Channel 제한 |
| 특수 Material | Forward Pass로 자연스럽게 처리 | Forward-only Fallback 가능 |
| Pipeline 통합 | `UniversalForward` | `UniversalGBuffer`와 Material Type |

Deferred Renderer에서도 `UniversalForwardOnly` Pass로 특수 Opaque Material을 그릴 수 있다.

Forward-only 비율이 높으면 Deferred 선택 이점이 줄어든다.

---

## Memory 사용 비교

Forward는 기본적으로 Color와 Depth 중심이다.

Deferred는 Full-resolution G-buffer 여러 장을 유지해야 한다.

```text
Render Target Memory
≈ Width × Height
× Bytes Per Pixel
× Target Count
```

1080p에서 32-bit Target 하나는 원시 Pixel Data 기준 약 8MB다.

Deferred는 여러 Target, Depth, Optional ShadowMask와 Rendering Layer Target이 추가될 수 있다.

고해상도와 작은 GPU Memory Budget에서 차이가 커진다.

---

## Bandwidth 비교

Forward Color Pass는 Material과 Lighting 결과를 Color에 쓴다.

Deferred는 Geometry Pass에서 여러 Target을 쓰고 Lighting Pass에서 다시 읽는다.

```text
Forward
Texture Read → Lighting → Color Write

Deferred
Texture Read → G-buffer MRT Write
→ G-buffer MRT Read → Lighting Write
```

Deferred는 Light가 많을 때 연산을 효율화할 수 있지만 Memory Traffic이 커질 수 있다.

GPU가 ALU Bound인지 Bandwidth Bound인지에 따라 결과가 다르다.

---

## Tile-based Mobile GPU

Mobile GPU는 On-chip Tile Memory를 활용한다.

Forward의 적은 Attachment는 Tile Memory에 맞추기 쉬울 수 있다.

```text
Forward Tile
├─ Color
└─ Depth

Deferred Tile
├─ GBuffer 0
├─ GBuffer 1
├─ GBuffer 2
├─ Lighting
└─ Depth
```

Deferred Attachment가 Tile Memory를 넘거나 외부 Memory Store·Load를 유발하면 비용이 커진다.

Native Render Pass가 이를 줄일 수 있지만 Device별 측정이 필요하다.

---

## Desktop GPU

Desktop과 Console GPU는 높은 Bandwidth와 많은 Compute Resource를 제공할 수 있다.

많은 Local Light와 복잡한 Opaque Scene에서는 Deferred 비용을 감당하면서 Light 장점을 얻을 수 있다.

```text
고성능 GPU + 많은 Opaque Light
→ Deferred 후보

고성능 GPU + 적은 Light + MSAA 요구
→ Forward도 유효한 후보
```

Hardware 등급만으로 Path를 확정하지 않는다.

Scene Content와 Visual Feature를 함께 본다.

---

## Draw Call 비교의 함정

두 Path의 Draw Call은 Light 수만으로 계산할 수 없다.

```text
Forward
├─ Shadow Caster Draw
├─ Opaque Forward Draw
├─ Depth Prepass 가능
└─ Transparent Draw

Deferred
├─ Shadow Caster Draw
├─ G-buffer Draw
├─ Deferred Light Draw
├─ Forward-only Opaque Draw
└─ Transparent Draw
```

Forward의 Additional Light가 늘어도 URP에서는 같은 Pass 안의 Loop로 처리되어 Geometry Draw가 늘지 않을 수 있다.

Deferred는 Light Volume Draw와 G-buffer Pass가 추가된다.

---

## Object당 Pass 1의 의미

Unity 공식 비교표는 Forward와 Deferred 모두 Object당 Rendering Pass를 1로 표시한다.

이는 주된 Geometry Lighting Path 비교다.

```text
Object의 전체 Frame Draw 후보
├─ ShadowCaster
├─ DepthOnly
├─ DepthNormals
├─ Forward 또는 G-buffer
└─ Editor / Selection Pass
```

Shadow와 Prepass까지 포함해 Object가 Frame에 한 번만 그려진다는 뜻은 아니다.

Frame Debugger에서 실제 Pass별 Draw를 확인해야 한다.

---

## Light 수와 Draw Call

일반 Forward에서 Additional Light 1개와 8개가 같은 Geometry Draw Call 수를 가질 수 있다.

하지만 Shader Loop 길이가 달라진다.

```text
Forward Draw 1회
├─ Light Loop 1회
└─ Light Loop 8회
→ Draw 수는 같아도 GPU Time 다름
```

Deferred에서는 Local Light마다 Light Volume 또는 Tile Lighting 작업이 증가할 수 있다.

Draw Call 하나만으로 Lighting 성능을 판단하면 안 된다.

---

## CPU 비용 비교

Forward는 Object별 Light List와 Shader Data를 준비한다.

Deferred는 G-buffer Renderer와 Light Culling·Volume Command를 준비한다.

```text
Forward CPU 후보
├─ Object Light 선별
├─ Renderer 정렬
└─ Draw 준비

Deferred CPU 후보
├─ Renderer 정렬
├─ Light Tile / Volume 준비
└─ 더 많은 Pass Scheduling
```

SRP Batcher는 두 Path의 호환 Geometry Draw CPU 비용을 줄일 수 있다.

GPU Bandwidth와 Fragment 비용은 SRP Batcher가 줄이지 않는다.

---

## GPU 비용 비교

```text
Forward GPU
├─ Material Texture Sampling
├─ Fragment당 Light Loop
├─ Shadow Sampling
├─ Overdraw
└─ MSAA 가능

Deferred GPU
├─ G-buffer MRT Write
├─ G-buffer Read와 Decode
├─ Light Volume / Tile Lighting
├─ Shadow Sampling
└─ Forward Fallback
```

Forward는 Light가 적을 때 Loop가 짧다.

Deferred는 Light가 많을 때 Surface Data를 재사용하지만 G-buffer 고정 비용이 있다.

---

## Opaque Overdraw

Forward Opaque Overdraw는 가려질 Fragment의 비싼 Lighting까지 실행할 수 있다.

Deferred Opaque Overdraw는 가려질 Fragment의 Material 계산과 여러 G-buffer Write를 실행할 수 있다.

```text
Forward 낭비 후보
└─ Material + Light Loop + Color Write

Deferred 낭비 후보
└─ Material + G-buffer MRT Write
```

Front-to-back Sorting과 Early-Z는 두 Path 모두 중요하다.

Depth Prepass는 Overdraw를 줄이지만 Geometry Pass를 추가한다.

---

## Depth Prepass Trade-off

```text
Without Prepass
Geometry 한 번
→ 가려진 Fragment Shader 실행 가능

With Prepass
Depth Geometry 추가
→ Color 또는 G-buffer Fragment 절약 가능
```

Forward의 Light Loop가 복잡하면 가려진 Fragment 절감 가치가 커질 수 있다.

Deferred의 MRT Write가 무거우면 Depth Priming이 도움을 줄 수 있다.

Vertex가 매우 많고 Overdraw가 낮으면 Prepass가 손해일 수 있다.

---

## Transparency 비교

Transparent는 두 Renderer Path 모두 Forward로 처리된다.

```text
Forward Renderer
Opaque Forward
→ Transparent Forward

Deferred Renderer
Opaque G-buffer
→ Deferred Lighting
→ Transparent Forward
```

Deferred를 선택해도 Transparent Material은 G-buffer Light 이점을 얻지 못한다.

Object별 Realtime Light 제한과 Back-to-front Sorting, Blend와 Overdraw 비용이 유지된다.

---

## Transparency 비율이 높은 Scene

Particle, Foliage Blend, Glass와 VFX가 화면 대부분을 차지하면 Deferred의 Opaque 장점 비중이 작아진다.

```text
Frame GPU Time
├─ Opaque 20%
└─ Transparent 80%

Deferred 최적화 대상
└─ 주로 Opaque 20%
```

Transparent는 Forward Shader를 실행하고 G-buffer 뒤의 Color에 Blend한다.

이런 Scene에서는 Path 전환보다 Transparent Overdraw와 Shader를 먼저 최적화해야 할 수 있다.

---

## Alpha Clip은 어디에 속할까?

Alpha Clip Material은 Pixel을 완전히 버리거나 유지하므로 Opaque Queue에서 처리할 수 있다.

```text
Alpha Clip Foliage
├─ Forward: Forward Opaque
└─ Deferred: G-buffer Opaque 가능

Alpha Blend Foliage
├─ Forward: Transparent Forward
└─ Deferred: Transparent Forward
```

Alpha Clip은 Deferred G-buffer 혜택을 받을 수 있지만 MRT Overdraw와 `clip()` 비용이 있다.

Material Queue와 ZWrite 설정을 명확히 구분한다.

---

## MSAA 비교

Forward는 Hardware MSAA를 지원한다.

URP Deferred는 MSAA를 지원하지 않는다.

```text
Forward
├─ 2x MSAA
├─ 4x MSAA
└─ 8x MSAA

Deferred
└─ Post-process AA 사용 검토
   ├─ FXAA
   ├─ SMAA
   └─ Temporal 계열 지원 범위
```

VR, Mobile과 Geometry Edge 품질에서 MSAA가 필수라면 Forward 선택에 큰 비중을 둔다.

MSAA도 Memory와 Resolve 비용이 있으므로 Sample Count를 측정한다.

---

## Anti-aliasing 품질 차이

MSAA는 Geometry Edge Coverage에 강하고 Texture 내부 Shimmering을 모두 해결하지는 않는다.

Post-process AA는 최종 Image를 분석해 Edge를 부드럽게 하지만 Detail이 흐려질 수 있다.

```text
MSAA
└─ Rasterization Sample 기반

FXAA / SMAA
└─ Final Image Edge 기반

Temporal AA
└─ 여러 Frame History 기반
```

Pipeline 선택 시 AA 이름보다 Project의 Motion, Camera, XR과 Art Style에서 결과를 비교한다.

---

## Reflection Probe 비교

일반 Forward는 Object별 Reflection Probe Blending 제한이 있다.

Deferred는 G-buffer Lighting 구조에서 Probe 처리 방식이 다르다.

```text
Forward
Object가 선택한 Probe 정보로 Material Lighting

Deferred
화면 Surface와 Probe 영향 영역을 조합
```

Probe가 많고 경계 Blend가 중요한 Scene에서는 Path별 지원 수와 Artifact를 확인한다.

Reflection Probe의 Realtime Update 비용은 어느 Path에서도 별도로 존재한다.

---

## Camera Stack 비교

Forward Base Camera와 Overlay Camera는 모두 Forward Path를 사용할 수 있다.

Deferred Base Camera의 Overlay Camera는 Forward로 Rendering된다.

```text
Forward Stack
Base Forward
→ Overlay Forward

Deferred Stack
Base Deferred
→ Overlay Forward
```

Overlay의 Light와 Material 동작이 Base Opaque와 다를 수 있다.

Stack이 많으면 Camera별 Culling과 Drawing이 반복되므로 Path보다 Camera 수가 더 큰 비용 원인일 수 있다.

---

## Shader Pass 비교

Forward Material은 `UniversalForward` 계열 Pass를 제공한다.

Deferred Material은 `UniversalGBuffer` Pass를 제공한다.

```shaderlab
// Forward
Tags { "LightMode" = "UniversalForward" }

// Deferred
Tags { "LightMode" = "UniversalGBuffer" }
```

Deferred에서 G-buffer로 표현하기 어려운 Material은 `UniversalForwardOnly`를 사용할 수 있다.

하나의 Shader가 여러 Path를 지원하려면 대응 Pass와 Keyword를 함께 관리해야 한다.

---

## Shader Variant 비교

Forward는 Main·Additional Light, Per Vertex·Per Pixel과 Shadow Keyword 조합을 가진다.

Deferred는 G-buffer Material Type, Deferred Lighting과 Forward-only Fallback Variant를 가진다.

```text
Variant 증가 요인
├─ Rendering Path
├─ Material Feature
├─ Shadow
├─ Lightmap
├─ Fog
├─ Decal
└─ Platform
```

두 Path를 모두 Build에 포함하면 Shader Variant와 Test 범위가 늘어날 수 있다.

사용하지 않는 Path와 Feature의 Strip 설정을 확인한다.

---

## Decal 비교

Forward에서 Decal은 Screen Space 또는 다른 Technique으로 Color와 Normal에 적용될 수 있다.

Deferred에서는 Lighting 전에 G-buffer Material Data를 수정하는 DBuffer 또는 관련 경로를 활용할 수 있다.

```text
Deferred Decal
G-buffer Material 수정
→ 이후 모든 Light에 반응
```

Decal Technique은 추가 Pass와 Texture를 만들 수 있다.

Accurate G-buffer Normals와 Screen Space Decal Normal Blending 제한도 확인한다.

---

## SSAO 비교

SSAO는 Depth와 Normal을 요구한다.

Deferred는 G-buffer에 Normal과 Depth가 이미 있다.

Forward는 Normal Texture를 위해 DepthNormals Prepass가 필요할 수 있다.

```text
Forward + SSAO
DepthNormals Prepass 가능
→ SSAO
→ Forward Opaque와 조합

Deferred + SSAO
G-buffer Normal / Depth
→ SSAO
→ Deferred Lighting
```

Deferred가 항상 SSAO에서 무료인 것은 아니지만 Input Data 재사용이 자연스럽다.

---

## Mixed Lighting 비교

Forward는 Per Vertex Light와 일부 Mixed Lighting Mode의 최적화 선택을 제공한다.

Deferred는 ShadowMask 또는 Subtractive 조건에서 G-buffer Target과 Flag가 추가될 수 있다.

```text
Deferred ShadowMask
기본 G-buffer
+ ShadowMask Attachment
```

Unity는 Subtractive와 Shadowmask Light가 Forward Path에 더 최적화된 조건이 있음을 안내한다.

Lightmap, Dynamic Object와 Shadow 요구를 함께 Test한다.

---

## Rendering Layers 비교

Forward는 Object와 Light의 Layer Mask를 Shader Data로 비교할 수 있다.

Deferred는 Pixel별 Rendering Layer를 Lighting 단계에서 알아야 하므로 별도 G-buffer Target이 필요할 수 있다.

```text
Forward
Object Data → Light Layer Matching

Deferred
Geometry Pass에서 Layer Mask 저장
→ Deferred Light Pass에서 Matching
```

Deferred에서 Rendering Layers를 켜면 Memory와 Bandwidth가 증가할 수 있다.

필요하지 않으면 비활성화한다.

---

## Resolution의 영향

Forward와 Deferred 모두 Pixel 수가 늘면 Fragment 비용이 증가한다.

Deferred는 여러 Full-resolution Buffer 때문에 Resolution에 더 민감할 수 있다.

```text
1920 × 1080 ≈ 2.07M Pixel
3840 × 2160 ≈ 8.29M Pixel

4K
→ G-buffer 각 Target도 약 4배 Pixel
```

Forward에서도 Light Loop, Transparent, MSAA와 Post-processing 비용이 약해지는 것은 아니다.

Render Scale과 Dynamic Resolution을 동일 조건에서 비교한다.

---

## Shadow 비용은 공통이다

두 Path 모두 Realtime Shadow Map을 먼저 만들어야 한다.

```text
Light View
→ Shadow Caster Draw
→ Shadow Atlas
→ Forward 또는 Deferred Lighting에서 Sampling
```

Deferred가 Camera Geometry Lighting을 분리해도 ShadowCaster Geometry Draw는 사라지지 않는다.

많은 Shadow Light가 병목이면 Path 전환보다 Shadow 수와 Resolution을 먼저 줄이는 것이 효과적일 수 있다.

---

## Post-processing 비용도 공통이다

Bloom, Depth of Field와 Color Grading은 Opaque Lighting 이후 Camera Color에 적용된다.

```text
Forward Lit Color ─┐
                   ├─ Post-processing → Final
Deferred Lit Color ┘
```

같은 해상도와 같은 Effect라면 Post-processing 비용은 Path 선택과 별도로 존재한다.

다만 Input Texture Format, MSAA Resolve와 Intermediate Target 경로가 차이를 만들 수 있다.

---

## Frame 전체에서 Path 비중 보기

Path를 바꿔도 Frame의 일부 비용만 변한다.

```text
Frame
├─ Gameplay CPU
├─ Animation
├─ Physics
├─ Culling
├─ Shadow
├─ Opaque Path       ← 주요 비교 대상
├─ Transparent       ← 둘 다 Forward
├─ Post-processing
└─ UI
```

Opaque Lighting이 Frame의 작은 비중이면 Path 전환 효과도 작을 수 있다.

Profiler Marker별 시간을 먼저 기록한다.

---

## Forward가 유리한 조건

- Realtime Light가 적다.
- Object당 겹치는 Light가 제한적이다.
- Mobile 또는 저사양 GPU가 중요하다.
- Memory Bandwidth Budget이 작다.
- Hardware MSAA가 필요하다.
- Transparent 비중이 높다.
- Custom Material Model이 많다.
- Per Vertex Additional Light를 활용할 수 있다.

```text
Few Lights
+ Tight Bandwidth
+ MSAA
+ Flexible Materials
        │
        ▼
Forward 후보
```

---

## Deferred가 유리한 조건

- Opaque Surface 비중이 높다.
- Point와 Spot Light가 많이 겹친다.
- Object별 Light Limit가 Visual을 제한한다.
- G-buffer 호환 Material이 대부분이다.
- SSAO와 Decal을 적극적으로 사용한다.
- Target GPU가 MRT와 Bandwidth를 충분히 제공한다.
- MSAA가 필수는 아니다.
- Forward-only Fallback 비율이 낮다.

```text
Many Opaque Local Lights
+ Capable GPU
+ G-buffer Compatible Materials
        │
        ▼
Deferred 후보
```

---

## Forward를 선택해도 되는 고사양 Project

Forward는 저사양 전용 Path가 아니다.

고사양 PC Project라도 다음 조건이면 적합할 수 있다.

- Light가 적고 Material Shader가 복잡하다.
- MSAA와 VR 품질이 중요하다.
- Transparent와 Hair가 많다.
- Custom BRDF가 G-buffer에 맞지 않는다.
- Memory보다 ALU 활용이 더 유리하다.

```text
Hardware 등급
≠ Rendering Path 자동 결정
```

Content 특성이 더 직접적인 기준이 된다.

---

## Deferred를 선택해도 되는 Mobile Project

공식 문서는 일반적으로 Mobile에서 Deferred의 G-buffer 추가 Pass가 더 큰 영향을 줄 수 있다고 안내한다.

그러나 특정 고성능 Mobile Device, Native Render Pass와 많은 Light 조건에서는 검토할 수 있다.

```text
필수 검증
├─ Target Device GPU
├─ Tile Memory
├─ Graphics API
├─ Native Render Pass
├─ Thermal Throttling
└─ Memory Bandwidth
```

Editor의 Desktop GPU 결과로 Mobile 결론을 내리면 안 된다.

---

## 선택을 위한 대표 Scene 만들기

실제 Production을 대표하는 Vertical Slice를 준비한다.

```text
Representative Scene
├─ 실제 Geometry 밀도
├─ 실제 Material 수
├─ 평균과 최대 Light 수
├─ 실제 Shadow 설정
├─ Transparent VFX
├─ Post-processing
└─ 목표 Resolution
```

빈 Scene이나 단순 Benchmark는 Production의 Material, Overdraw와 Light Overlap을 반영하지 못한다.

평균 Frame뿐 아니라 최악의 전투, 도시와 Effect 상황을 Test한다.

---

## 공정한 비교 설정

Path만 바꾸고 다른 Quality는 최대한 동일하게 유지한다.

- 같은 Camera와 Resolution
- 같은 Render Scale
- 같은 Light와 Shadow
- 같은 Material 품질
- 같은 Post-processing
- 같은 Graphics API
- 같은 Build Type
- 같은 Device 온도와 전력 상태

```text
Forward Test
        ↕ Path만 변경
Deferred Test
```

Deferred에서 MSAA가 불가능하므로 AA 품질 비교는 별도 Scenario로 기록한다.

---

## 측정할 숫자

| 영역 | 측정 항목 |
| --- | --- |
| CPU | Main Thread, Render Thread, Culling, Draw 준비 |
| GPU | Opaque, G-buffer, Deferred Light, Transparent, Shadow |
| Memory | Render Target Peak, G-buffer, Shadow Atlas, History |
| Draw | Opaque, Shadow, Light Volume, Forward-only, Transparent |
| 품질 | Light Pop, Normal Banding, AA, Material 호환성 |
| Build | Shader Variant, Build Size와 Warmup |

평균 FPS 하나만 기록하면 병목 이동을 놓친다.

CPU와 GPU Millisecond를 각각 기록한다.

---

## Frame Debugger 비교

Forward Frame은 다음 Event를 중심으로 본다.

```text
Depth Prepass (조건부)
→ Forward Opaque
→ Skybox
→ Transparent
```

Deferred Frame은 다음 Event를 중심으로 본다.

```text
Depth Prepass (조건부)
→ GBufferPass
→ Deferred Lights
→ Forward-only Opaque
→ Skybox
→ Transparent
```

각 단계의 Draw 수와 Render Target을 기록한다.

---

## Render Graph Viewer 비교

Render Graph Viewer에서 두 Path의 Pass와 Resource Graph를 Capture한다.

```text
Forward 확인
├─ Camera Color / Depth
├─ Optional Normal
├─ Optional Opaque Copy
└─ Pass Lifetime

Deferred 확인
├─ G-buffer Attachments
├─ Optional ShadowMask
├─ Optional Rendering Layers
├─ Deferred Light Input
└─ Native Render Pass Merge
```

사용하지 않는 Pass가 Culling되는지와 Texture Lifetime을 비교한다.

---

## GPU Capture 비교

GPU Capture는 실제 Graphics API 수준의 차이를 보여 준다.

- Render Target Format
- Load와 Store Action
- Tile Store·Load
- MRT Write
- Light Volume Draw
- Fragment Shader Duration
- Texture Bandwidth
- MSAA Resolve

```text
Unity Profiler
→ 병목 Pass 발견
→ GPU Capture
→ Attachment와 Shader 원인 분석
```

Path 이름보다 실제 Command와 Resource를 기준으로 판단한다.

---

## Light 수를 단계적으로 늘리는 Test

같은 Scene에서 Local Light를 단계적으로 늘린다.

```text
Test A: 1 Light
Test B: 4 Lights
Test C: 8 Lights
Test D: 16 Lights
Test E: 32 Lights
```

Forward에서는 Object Limit와 Opaque GPU Time 변화를 본다.

Deferred에서는 Light Volume·Tile Pass와 G-buffer 고정 비용을 본다.

두 그래프가 교차하는 지점이 해당 Hardware와 Scene의 중요한 선택 정보가 된다.

---

## Resolution을 단계적으로 늘리는 Test

```text
720p
→ 1080p
→ 1440p
→ 4K
```

Forward의 Fragment Light Loop와 Deferred의 G-buffer Bandwidth가 어떻게 증가하는지 기록한다.

Light가 적으면 Deferred가 Resolution 증가에 더 민감할 수 있다.

Forward도 MSAA Sample 수가 높으면 Color·Depth 비용이 크게 증가한다.

---

## Transparency 비율 Test

Opaque와 Transparent 비중을 바꿔 Path의 유효 범위를 확인한다.

```text
Scene A: Opaque 90% / Transparent 10%
Scene B: Opaque 50% / Transparent 50%
Scene C: Opaque 20% / Transparent 80%
```

Deferred의 변화는 주로 Opaque 구간에 나타난다.

Transparent 구간이 병목이면 두 Path의 전체 Frame 차이가 작아질 수 있다.

---

## Material 호환성 Test

모든 주요 Shader가 Deferred Pass를 제공하는지 확인한다.

```text
Material Inventory
├─ UniversalGBuffer 지원
├─ UniversalForwardOnly
├─ Transparent Forward
├─ Error / Unsupported
└─ Custom Renderer Feature 의존
```

Forward-only Opaque가 많으면 G-buffer 이후 추가 Forward Pass가 커진다.

Shader 변환 비용과 Visual Regression을 Pipeline 선택 비용에 포함한다.

---

## 병목이 CPU일 때

GPU Path를 바꿔도 Gameplay Main Thread가 병목이면 Frame Rate가 바뀌지 않을 수 있다.

```text
CPU Frame: 20ms
GPU Forward: 10ms
GPU Deferred: 12ms

둘 다 CPU Bound
→ 표시 Frame Time은 CPU가 제한
```

Render Thread가 병목이면 Pass와 Draw 차이가 영향을 줄 수 있다.

Main Thread, Render Thread와 GPU를 분리해 기록한다.

---

## 병목이 GPU ALU일 때

복잡한 Forward BRDF와 많은 Light Loop가 GPU Shader 연산을 제한할 수 있다.

Deferred는 Surface Data를 저장한 뒤 Light별 Shader를 실행해 반복 구조를 바꾼다.

```text
ALU Bound Forward
→ Light 수 감소
→ Shader 단순화
→ Deferred 비교
```

Deferred도 Light Overlap과 BRDF가 많으면 ALU Bound가 될 수 있다.

GPU Timing과 Shader Profiler를 확인한다.

---

## 병목이 Bandwidth일 때

Deferred G-buffer Write·Read가 Bandwidth를 포화시킬 수 있다.

Forward도 High Resolution, MSAA, Opaque Texture와 Full-screen Effect 때문에 Bandwidth Bound가 될 수 있다.

```text
Bandwidth 절감 후보
├─ Render Scale 감소
├─ HDR Format 조정
├─ 불필요한 Camera Texture 제거
├─ Deferred 추가 Attachment 제거
├─ MSAA Sample 감소
└─ Full-screen Pass 감소
```

Path 전환 전후의 Memory Traffic을 Platform Tool에서 비교한다.

---

## 병목이 Shadow일 때

```text
GPU Frame
├─ Shadow: 8ms
├─ Forward Opaque: 2ms
└─ Deferred Opaque: 2.5ms
```

Opaque Path 차이보다 Shadow가 훨씬 크다면 Path 선택은 핵심 해결책이 아니다.

Shadow Caster 수, Atlas, Cascade와 Light 수를 먼저 조정한다.

같은 Shadow 설정으로 Path를 비교해야 한다.

---

## 품질 기준도 함께 기록하기

성능만 빠르고 필요한 Visual을 만들지 못하면 적합한 Path가 아니다.

- Forward Light Pop
- Deferred Normal Banding
- MSAA Geometry Edge
- Post-process AA Blur
- Forward-only Material 차이
- Reflection Probe Blend
- Decal Normal
- Terrain Layer Blend

```text
선택 점수
= Performance
+ Visual Quality
+ Feature Compatibility
+ Production Cost
```

Millisecond와 Screenshot·Video를 함께 남긴다.

---

## 선택 Decision Tree

```text
MSAA가 필수인가?
├─ Yes → Forward 우선 검토
└─ No
    │
    ▼
Opaque에 많은 Local Light가 겹치는가?
├─ No → Forward 우선 검토
└─ Yes
    │
    ▼
Target GPU의 MRT·Bandwidth가 충분한가?
├─ No → Forward 또는 다른 대안 검토
└─ Yes
    │
    ▼
대부분 Material이 G-buffer에 호환되는가?
├─ No → Forward 우선 검토
└─ Yes → Deferred Prototype 측정
```

Decision Tree는 측정 후보를 좁히는 도구다.

최종 선택은 실제 Build 결과로 결정한다.

---

## Forward 선택 체크리스트

- Main과 Additional Light 수가 제한적인가?
- Per Object Limit가 Visual에 문제가 없는가?
- Mobile과 저사양 Device가 중요한가?
- MSAA가 필요한가?
- Transparent와 Custom Material 비중이 높은가?
- Memory Bandwidth가 제한적인가?
- Per Vertex Light를 활용할 수 있는가?
- Target Device에서 Opaque GPU Time이 Budget 안인가?

대부분 만족하면 일반 Forward가 단순하고 안정적인 선택일 수 있다.

---

## Deferred 선택 체크리스트

- Opaque Local Light가 많이 겹치는가?
- Object별 Light 제한을 제거해야 하는가?
- G-buffer Memory Budget이 충분한가?
- Target GPU가 MRT와 Deferred를 지원하는가?
- MSAA 없이 목표 AA 품질을 만들 수 있는가?
- Transparent 비중이 낮거나 비용을 감당할 수 있는가?
- Forward-only Material이 적은가?
- Accurate Normal과 Decal·Terrain 제한을 검증했는가?

대부분 만족한 뒤 Vertical Slice에서 이득을 확인한다.

---

## Path 전환 시 확인할 설정

Renderer Data의 Path만 바꾼 뒤 다음 항목을 다시 확인한다.

```text
전환 영향
├─ MSAA
├─ Depth / Normal Prepass
├─ SSAO Source
├─ Decal Technique
├─ Rendering Layers
├─ Accurate G-buffer Normals
├─ Camera Stack
├─ Custom Shader Pass
└─ Renderer Feature Injection Point
```

동일한 화면이 나온다고 가정하지 않는다.

Material, Light와 Post-processing의 Visual Regression Test를 수행한다.

---

## Forward+라는 세 번째 선택지

일반 Forward의 Object별 Light 제한이 문제지만 Deferred의 G-buffer 비용이 큰 경우가 있다.

```text
일반 Forward
Object별 제한된 Light List
        │ 문제
        ▼
많은 Light 필요
        │
        ├─ Deferred: G-buffer Lighting
        └─ Forward+: Tile 기반 Forward Lighting
```

Forward+는 Forward Material 구조를 유지하면서 Tile 기반 Light Culling으로 많은 Light를 처리한다.

구체적인 구조와 선택 기준은 다음 글에서 다룬다.

---

## 자주 혼동하는 내용

### Deferred는 Forward보다 항상 빠른가?

아니다.

Light 밀도, G-buffer Bandwidth, Resolution, Transparent와 Hardware에 따라 달라진다.

### Forward는 Light마다 Object를 다시 그리는가?

URP 일반 Forward는 선택된 Additional Light를 하나의 Geometry Pass 내부 Loop에서 계산한다.

### Deferred는 Draw Call이 항상 적은가?

아니다.

G-buffer, Light Volume, Forward-only, Shadow와 Prepass Draw를 모두 포함해야 한다.

### Deferred는 모든 Material을 처리하는가?

아니다.

G-buffer에 맞지 않는 Material은 Forward-only Pass에서 처리할 수 있다.

### Deferred를 선택하면 Transparent Light 제한도 사라지는가?

아니다.

Transparent는 Forward로 Rendering된다.

### Forward는 G-buffer가 없으므로 Texture를 사용하지 않는가?

아니다.

Depth, Opaque Texture, Normal, Shadow와 Post-processing Target이 추가될 수 있다.

### Deferred는 Normal이 항상 부정확한가?

기본 Encoding은 정밀도 손실이 있지만 Accurate G-buffer Normals Option으로 개선할 수 있다.

### Forward는 Mobile에서 무조건 빠른가?

아니다.

일반적인 권장 후보지만 Light, MSAA, Overdraw와 Device 특성을 측정해야 한다.

### Deferred에서는 Object가 한 번만 그려지는가?

아니다.

Shadow, Depth Prepass, G-buffer와 Forward-only Pass에서 여러 번 그려질 수 있다.

### Path만 바꾸면 공정한 비교가 끝나는가?

아니다.

MSAA, Normal 품질, Decal과 Feature 호환성까지 동일한 Visual 목표로 다시 조정해야 한다.

---

## 전체 구조 다시 연결하기

```text
Forward
Camera Culling
        │
        ▼
Object별 Light List
        │
        ▼
Geometry + Material + Light Loop
        │
        ▼
Camera Color + Depth
        │
        └─ Transparent Forward

Deferred
Camera Culling
        │
        ▼
Opaque Geometry + Material
        │
        ▼
G-buffer + DepthStencil
        │
        ▼
Screen Light Culling과 Deferred Lighting
        │
        ▼
Camera Color
        │
        ├─ Forward-only Opaque
        └─ Transparent Forward
```

```text
Forward의 주요 비용 축
├─ Object별 Light Loop
├─ Fragment Overdraw
└─ MSAA와 Material Complexity

Deferred의 주요 비용 축
├─ G-buffer Memory와 Bandwidth
├─ Screen Light Overlap
└─ Forward Fallback과 Resolution
```

---

## 정리

Forward는 Geometry를 그리는 시점에 Object별 Light 목록으로 Material Lighting을 계산해 Camera Color에 직접 기록한다.

Deferred는 Opaque Geometry의 Surface Data를 G-buffer에 기록한 뒤 화면 공간의 Light Pass에서 Lighting을 누적한다.

```text
Forward
Geometry × Object Lights → Color

Deferred
Geometry → G-buffer
G-buffer × Screen Lights → Color
```

일반 Forward는 Object당 Main Directional Light 1개와 설정에 따른 Additional Light 최대 8개의 제한이 있지만 Light가 적을 때 구조가 직접적이고 Per-vertex Light와 MSAA를 지원한다.

Deferred Opaque는 Object별 Realtime Light 제한이 없고 많은 Local Light에 유리할 수 있지만 여러 Full-resolution G-buffer의 Memory와 Write·Read Bandwidth를 요구하며 MSAA를 지원하지 않는다.

Forward는 Fragment에서 정확한 Normal을 직접 사용하고 Custom Material Model을 구성하기 쉽지만 Additional Light가 늘면 같은 Draw 안의 Light Loop 비용이 증가한다.

Deferred는 Surface Data를 Light가 재사용하지만 Normal Encoding 정밀도와 G-buffer Channel 제약이 있으며 호환되지 않는 Opaque Material은 Forward-only로 처리한다.

Transparent는 두 Path 모두 Forward로 Rendering되므로 Transparent 비율이 높으면 Deferred의 Opaque Light 장점이 전체 Frame에 미치는 영향이 줄어든다.

Draw Call 수만으로 비교하지 말고 Shadow, Prepass, G-buffer, Light Volume, Forward-only와 Transparent Pass를 모두 확인해야 한다.

Target Device에서 동일한 Resolution, Light, Shadow와 Visual 목표로 CPU·GPU Time, Render Target Memory, Bandwidth, Light Pop, Normal 품질과 AA를 측정한 뒤 선택해야 한다.
