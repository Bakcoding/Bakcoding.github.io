---
title: "[Unity 렌더링] 7-7. Baked Lighting은 왜 사용할까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - Lighting
  - Lightmap
  - BakedGI
permalink: /programming/unity-7-7-why-use-baked-lighting/
toc: true
toc_sticky: true
date: 2026-08-16
last_modified_at: 2026-08-16
---

Baked Lighting은 Light와 정적인 Scene Geometry의 상호작용을 Runtime 전에 계산해 Texture와 Probe Data로 저장하는 방식이다.

매 Frame 수많은 Realtime Light와 Shadow를 다시 계산하는 대신 미리 만들어 둔 Lighting 결과를 Sample한다.

```text
Editor Bake
Light + Static Geometry
          │ 긴 계산
          ▼
Lightmap / Probe Data
          │ Runtime Sample
          ▼
      화면 Lighting
```

계산 시간을 Build 이전으로 옮겨 Runtime 성능을 확보하고, 여러 번 반사되는 Indirect Light까지 표현할 수 있다는 점이 핵심이다.

---

## Baked Lighting이 필요한 이유

Realtime Light는 영향을 받는 Fragment마다 Diffuse·Specular와 Shadow를 계산한다.

Light와 Shadow가 많으면 CPU의 Culling과 GPU의 Light Loop가 반복된다.

정적인 벽, 바닥과 천장의 Lighting은 매 Frame 결과가 바뀌지 않는다.

```text
고정된 Light + 고정된 Surface

Frame 1   같은 계산
Frame 2   같은 계산
Frame 3   같은 계산
...
```

이 결과를 한 번 계산해 저장하면 Runtime에서는 복잡한 Light Transport 대신 Texture를 읽을 수 있다.

```text
Realtime
매 Frame: BRDF × Light × Shadow

Baked
사전 계산: 복잡한 Light Transport
Runtime:   Lightmap Sample
```

---

## Bake란 무엇일까?

Bake는 Lightmapper가 Scene의 Light와 Geometry를 분석해 Surface마다 도달하는 빛을 계산하는 과정이다.

```text
Scene Input
├─ Baked / Mixed Light
├─ Static Mesh
├─ Material Albedo
├─ Emission
├─ Lightmap UV
└─ Lighting Settings
        │
        ▼
Progressive Lightmapper
        │
        ▼
Lighting Data Asset
├─ Lightmaps
├─ Light Probe Data
└─ 관련 Baked Data
```

직접광뿐 아니라 Surface에서 반사되어 다른 Surface에 도달하는 간접광도 계산할 수 있다.

Bake 결과는 Scene의 현재 배치와 Material에 의존한다.

Light, Static Object 또는 중요한 Material이 바뀌면 결과를 다시 Bake해야 한다.

---

## Global Illumination이란?

Global Illumination은 Light Source에서 직접 오는 빛뿐 아니라 Surface 사이에서 반사되는 빛까지 계산하는 개념이다.

```text
Light
  │
  ▼ Direct Light
흰 벽
  │ Bounce
  ▼ Indirect Light
바닥과 주변 Object
```

Direct Lighting만 사용하면 Light를 등진 영역이 지나치게 검게 보일 수 있다.

Baked GI는 여러 Bounce를 사전 계산해 Color Bleeding과 실내의 부드러운 밝기를 표현한다.

```text
빨간 벽에 닿은 흰빛
       │ 반사
       ▼
인접한 흰 바닥에 붉은 간접광
```

이 결과를 Runtime에 Realtime으로 추적하지 않고 Lightmap에 저장한다.

---

## Direct와 Indirect Baked Lighting

Bake Data에는 설정과 Light Mode에 따라 Direct와 Indirect 성분이 포함될 수 있다.

```text
Baked Direct
└─ Light에서 Surface로 직접 도달한 빛과 Shadow

Baked Indirect
└─ 다른 Surface에서 한 번 이상 반사된 빛
```

Baked Light Mode는 정적 Receiver에 대한 Direct와 Indirect Lighting을 모두 Bake할 수 있다.

Mixed Light는 일부 성분을 Baked Data에 저장하고 Dynamic Object와 Shadow를 위해 Realtime 성분을 남긴다.

구체적인 결합 방식은 다음 Mixed Lighting 글에서 이어진다.

---

## Lightmap이란?

Lightmap은 Scene Surface의 미리 계산된 Lighting을 저장하는 Texture다.

일반 Albedo Texture가 Material의 고유 색을 저장한다면 Lightmap은 Scene 배치에 따른 빛을 저장한다.

```text
Albedo Texture
└─ 나무, 돌, 페인트의 고유 색

Lightmap Texture
└─ 밝기, 간접광, Baked Shadow
```

Runtime Shader는 Mesh의 Lightmap UV를 이용해 해당 Surface의 Baked Lighting을 Sample한다.

```hlsl
float2 lightmapUV =
    input.lightmapUV * unity_LightmapST.xy +
    unity_LightmapST.zw;
```

실제 URP에서는 Shader Library Macro와 GI Helper를 사용해 Encoding과 Directional Mode를 처리한다.

---

## Lightmap UV는 왜 별도로 필요할까?

Base Texture UV는 반복되거나 여러 Face가 겹칠 수 있다.

Lightmap에는 Scene의 각 Surface 위치마다 서로 다른 Lighting을 저장해야 하므로 UV Island가 겹치면 안 된다.

```text
Base UV
├─ Tiling 가능
└─ Island Overlap 가능

Lightmap UV
├─ 보통 0~1 안에 배치
├─ Island 비중첩
└─ Filtering용 Padding 필요
```

Unity는 Import Setting에서 Generate Lightmap UVs를 통해 보조 UV를 생성할 수 있다.

복잡한 Asset은 DCC Tool에서 직접 UV2를 제작하는 편이 품질과 Packing을 더 세밀하게 제어할 수 있다.

---

## Texel이란?

Texel은 Texture를 구성하는 한 칸이다.

Lightmap에서는 한 Texel이 Scene Surface의 일정 면적에 대한 Lighting을 저장한다.

```text
Scene Surface
┌──┬──┬──┬──┐
│  │  │  │  │ ← 각 칸이 Lightmap Texel에 대응
├──┼──┼──┼──┤
│  │  │  │  │
└──┴──┴──┴──┘
```

Texel Density가 높으면 작은 Shadow와 Lighting Detail을 저장할 수 있지만 Lightmap 크기, Memory와 Bake Time이 증가한다.

Texel Density가 낮으면 Memory는 줄지만 Shadow 경계가 흐려지고 빛이 번질 수 있다.

---

## Lightmap Resolution과 Scale in Lightmap

Lighting Settings의 Resolution은 World Unit당 사용할 Lightmap Texel 밀도에 영향을 준다.

Renderer의 Scale in Lightmap은 Object별 상대적인 Lightmap 면적을 조절한다.

```text
최종 Lightmap 면적
≈ Object Surface Area
 × Global Resolution
 × Scale in Lightmap
```

화면에서 크고 Shadow Detail이 중요한 Object에는 더 많은 Texel을 배정할 수 있다.

천장 위, 보이지 않는 뒷면과 작은 장식에 같은 밀도를 주면 Atlas 공간을 낭비한다.

모든 Object의 Resolution을 올리기보다 중요도에 따라 분배한다.

---

## Lightmap Atlas

여러 Mesh의 Lightmap UV Island는 하나 이상의 Lightmap Texture에 Packing된다.

```text
Lightmap Atlas
┌──────────┬─────┐
│ Wall     │Prop │
│          ├─────┤
├────┬─────┤Floor│
│Door│Trim │     │
└────┴─────┴─────┘
```

각 Renderer는 자신이 사용할 Lightmap Index와 UV Scale·Offset을 가진다.

Atlas 수가 많아지면 Texture Memory, Loading과 Scene Data 크기가 증가한다.

Streaming Scene에서는 공간 단위로 Lightmap을 Load하고 Unload할 수 있도록 Scene과 Bake 구성을 설계해야 한다.

---

## Directional Lightmap

Non-Directional Lightmap은 주로 들어온 빛의 총량을 저장한다.

Directional Mode는 주요 Light Direction 정보를 추가로 저장해 Normal Map이 Baked Lighting에 반응하도록 만들 수 있다.

```text
Non-Directional
└─ Baked Irradiance 중심

Directional
├─ Baked Irradiance
└─ 주요 Direction Data
```

Directional Lightmap은 Normal Detail과 입체감을 개선하지만 추가 Texture Data와 Shader 계산이 필요하다.

저사양 Platform에서는 품질 차이와 Memory 비용을 비교한다.

---

## Baked Shadow는 왜 부드럽게 만들 수 있을까?

Realtime Shadow는 매 Frame 제한된 Shadow Map과 Sample Budget으로 계산한다.

Bake는 더 긴 시간 동안 여러 Sample을 누적해 Area Light와 부드러운 Penumbra를 근사할 수 있다.

```text
작은 Light Source → 비교적 날카로운 Shadow
큰 Light Source   → 넓고 부드러운 Shadow
```

Baked Directional Light의 Baked Shadow Angle과 Point·Spot Light의 Baked Shadow Radius로 Light Source 크기 효과를 조절할 수 있다.

Runtime Soft Shadow Filter 비용 없이 Lightmap에 부드러운 결과를 저장할 수 있다.

---

## Area Light가 Baked인 이유

Area Light는 면 전체에서 빛이 나오는 형태를 표현한다.

많은 Sample Direction과 Soft Shadow가 필요하므로 일반적인 URP Realtime Light처럼 직접 처리하기 어렵다.

Unity URP Light Component에서 Area Light는 Baked Mode로 사용된다.

```text
Window / Ceiling Panel
        │ 넓은 Light Source
        ▼
부드러운 Baked Lighting과 Shadow
```

실내 창문과 면 조명에서 Point Light 여러 개로 흉내 내는 것보다 자연스러운 Bake 결과를 만들 수 있다.

---

## Runtime에서는 무엇을 계산할까?

Baked Lighting이라고 해서 Shader가 아무 일도 하지 않는 것은 아니다.

```text
Runtime Baked Lighting
├─ Lightmap UV 보간
├─ Lightmap Texture Sample
├─ Encoding Decode
├─ Directional Data 결합
├─ Material Albedo 적용
└─ Realtime Specular / Reflection과 결합 가능
```

Realtime Light Loop와 Shadow Map 생성은 줄어들지만 Texture Sample과 Memory Bandwidth가 필요하다.

`무료 Lighting`이 아니라 비싼 동적 계산을 미리 계산된 Data 조회로 바꾸는 방식이다.

---

## Baked Lit Shader

URP의 Baked Lit Shader는 Realtime Lighting이 필요 없고 Lightmap과 Light Probe 기반 Lighting만 필요한 Material에 적합하다.

Realtime Light 관련 Shader Keyword와 Variant가 제거되어 Lit보다 단순하게 실행될 수 있다.

| Shader | Realtime Light | Baked GI | PBR |
| --- | --- | --- | --- |
| Lit | 사용 | 사용 | 사용 |
| Simple Lit | 사용 | 사용 | 비PBR 단순 Shading |
| Baked Lit | 사용하지 않음 | 사용 | 사용하지 않음 |
| Unlit | 사용하지 않음 | 사용하지 않음 | 사용하지 않음 |

Stylized 환경과 저사양 Target에서 Realtime Highlight가 필요 없는 Static Object에 유용하다.

Material의 시각 목표가 PBR Reflection을 요구하면 일반 Lit과 Bake Data를 함께 사용하는 선택도 가능하다.

---

## Dynamic Object는 Lightmap을 사용할 수 있을까?

Lightmap은 Bake 당시 고정된 Surface와 UV에 결과를 저장한다.

Object가 움직이면 Texture에 기록된 Shadow와 주변 Lighting 위치가 실제 Scene과 맞지 않는다.

```text
Bake 위치 A의 Lighting 저장
       │
Object가 위치 B로 이동
       │
       ▼
저장된 Lighting과 현재 공간 불일치
```

따라서 움직이는 Character와 Rigidbody는 일반적으로 Lightmap Receiver로 사용하지 않는다.

Dynamic Object는 Light Probe 또는 APV에서 공간의 Baked Indirect Lighting을 Sample할 수 있다.

실시간 Direct Light와 Shadow가 필요하면 Realtime 또는 Mixed Light를 결합한다.

---

## Dynamic Object가 Baked Shadow를 만들 수 있을까?

Baked Lightmap의 Shadow는 Bake 시점 Geometry를 기준으로 고정된다.

Bake 이후 움직인 Character의 Shadow는 Lightmap에 새로 기록되지 않는다.

```text
Static Wall → Baked Shadow 가능
Moving Character → Realtime Shadow 필요
```

완전히 Baked된 Light만 사용하면 Dynamic Object가 주변 Static Surface에 실시간 Shadow를 만들지 못할 수 있다.

Blob Shadow, Projector, Decal 또는 Mixed Lighting 같은 대안을 시각적 요구에 맞춰 선택한다.

---

## Light Probe와의 관계

Light Probe는 Scene의 지점마다 Baked Lighting 방향 정보를 저장한다.

Dynamic Object는 주변 Probe 값을 보간해 Indirect Diffuse를 얻는다.

```text
Probe A ●──────● Probe B
          ▲
      Dynamic Object
      주변 값을 보간
```

Lightmap은 Static Surface의 고해상도 결과를 저장하고 Light Probe는 움직이는 Object에 공간 Lighting을 전달한다.

Probe 배치와 보간의 상세 원리는 `7-9`에서 이어진다.

---

## Reflection Probe와의 관계

Lightmap은 주로 Diffuse Lighting을 저장한다.

매끄러운 Surface와 금속에 필요한 Environment Specular는 Reflection Probe와 Skybox가 담당한다.

```text
Baked Lighting 구성
├─ Lightmap / Light Probe → Indirect Diffuse
└─ Reflection Probe       → Indirect Specular
```

Baked GI를 사용한다고 Reflection이 자동으로 완성되는 것은 아니다.

PBR Lit Material은 Lightmap과 Reflection Probe를 함께 사용해야 재질이 자연스럽게 보일 수 있다.

---

## Baked Lighting의 장점

### Realtime Light Loop를 줄인다

정적인 Light의 Diffuse와 Shadow를 Lightmap으로 옮겨 Fragment당 반복되는 Light 계산을 줄인다.

### 고품질 Indirect Lighting을 표현한다

여러 Bounce와 Color Bleeding을 긴 Bake 시간 동안 계산할 수 있다.

### 부드러운 Shadow를 저장한다

Runtime Soft Shadow Sample 비용 없이 고정된 부드러운 Shadow를 표현한다.

### 저사양 Hardware에 유리하다

복잡한 Realtime BRDF와 Shadow 대신 Texture Sample 중심으로 Lighting을 구성할 수 있다.

### 결과가 안정적이다

동일한 Bake Data를 사용하므로 Frame마다 Sampling Noise가 변하지 않고 Lighting 품질을 예측하기 쉽다.

---

## Baked Lighting의 한계

### Scene 변화에 대응하지 못한다

Light와 Static Geometry가 움직이면 Bake 결과가 틀어진다.

문을 열거나 벽을 파괴하는 Scene에서는 Light Leak과 남아 있는 Shadow가 보일 수 있다.

### Bake 시간이 필요하다

Scene 규모, Texel 수, Sample과 Bounce 수가 증가하면 Bake 시간이 길어진다.

### Texture Memory를 사용한다

고해상도 Lightmap 여러 장은 Disk, RAM과 GPU Memory를 차지한다.

### UV와 Artifact 관리가 필요하다

Overlap, Padding 부족, 낮은 Texel Density와 Denoiser 결과 때문에 Seam과 Light Leak이 생길 수 있다.

### Dynamic Object 처리가 별도다

Light Probe, Mixed Light와 Realtime Shadow를 추가로 설계해야 한다.

---

## Bake Time은 어디서 증가할까?

```text
Bake Time 영향 요인
├─ Lightmap Texel 수
├─ Direct / Indirect Sample 수
├─ Bounce 수
├─ Static Geometry 복잡도
├─ Baked Light 수
├─ Denoising
└─ CPU / GPU Lightmapper 선택
```

Resolution을 두 배로 높이면 Texture의 가로와 세로가 모두 증가하므로 Texel 수는 훨씬 크게 늘 수 있다.

모든 품질 값을 동시에 높이기보다 Noise가 생기는 원인에 맞는 설정을 조정한다.

작업 중에는 낮은 품질로 빠르게 Preview하고 최종 Build 전에 높은 품질 Bake를 수행하는 Workflow가 유용하다.

---

## Memory 비용

Lightmap은 Scene에 포함되는 Texture Asset이다.

```text
Lightmap Memory
≈ Atlas Resolution²
 × Texture 수
 × Format / Mip 비용
```

Directional Mode는 Direction Data용 추가 Texture를 요구할 수 있다.

높은 해상도 Lightmap은 Runtime 연산을 줄이는 대신 Memory Bandwidth와 Loading 비용을 늘린다.

모바일에서는 GPU Memory와 App Size를 함께 확인하고 Texture Compression의 Banding과 Color 품질을 검사한다.

---

## 자주 생기는 Artifact

### UV Seam

UV Island 경계의 Texel과 Normal 차이 때문에 밝기 선이 보일 수 있다.

### Light Bleeding

얇은 벽, 낮은 Resolution 또는 Island Padding 부족으로 반대편 빛이 번질 수 있다.

### Blocky Shadow

Texel Density가 낮으면 Shadow 경계가 네모난 Texture 해상도로 드러난다.

### Splotch와 Noise

Indirect Sample이 부족하면 평평한 벽에 얼룩이 생길 수 있다.

### Dynamic Object 불일치

Probe가 부족하거나 Lightmap과 Probe Lighting이 다르면 Character가 배경에서 떠 보인다.

문제별로 UV, Resolution, Sample, Geometry 두께와 Probe 배치를 구분해 확인한다.

---

## Lightmap을 디버깅하는 방법

Unity Scene View의 Lighting 관련 Draw Mode와 Lightmap Preview를 사용해 다음 항목을 확인한다.

```text
검사 항목
├─ Baked Texel Density
├─ UV Overlap
├─ Lightmap Index와 Atlas Packing
├─ Direct / Indirect 결과
├─ Shadow Mask
├─ Light Probe 위치
└─ Baked Artifact
```

Renderer의 Lightmap Index와 Scale Offset도 Debugger 또는 Inspector에서 확인할 수 있다.

Runtime Frame Debugger에서는 Shader Variant가 Lightmap을 Sample하는지와 Realtime Light Pass가 남아 있는지 확인한다.

---

## 최적화 관점

### 중요한 Surface에 Texel을 집중한다

Camera에 가깝고 Shadow Detail이 중요한 벽과 바닥에 높은 밀도를 배정한다.

작거나 보이지 않는 Object의 Scale in Lightmap을 낮춘다.

### Lightmap 수를 관리한다

Atlas 크기와 Scene 분할을 조정해 불필요한 Texture 증가를 막는다.

Streaming 단위와 Lightmap Load 단위가 맞는지 확인한다.

### Baked Lit을 선택적으로 사용한다

Realtime Light와 PBR Reflection이 필요 없는 Material은 Baked Lit으로 Shader 계산과 Variant를 줄일 수 있다.

### Directional Mode를 목적에 맞게 선택한다

Normal Map Detail이 중요하지 않은 저사양 환경에서는 Non-Directional이 Memory에 유리할 수 있다.

### Realtime Shadow와 중복하지 않는다

이미 Baked된 정적 Shadow 위에 불필요한 Realtime Shadow를 다시 계산하지 않도록 Light Mode와 Mixed Mode를 설계한다.

### Bake 설정을 단계별로 높인다

Preview Bake에서 UV와 Leak을 먼저 해결한 뒤 Sample과 Resolution을 높인다.

잘못된 Geometry를 최고 품질로 반복 Bake하는 시간을 피할 수 있다.

---

## Baked Lighting이 적합한 경우

```text
적합
├─ 건물과 지형이 대부분 고정
├─ Light가 움직이지 않음
├─ 실내 간접광이 중요
├─ 저사양 GPU Target
└─ 긴 Bake 시간을 감수할 수 있음
```

건축 Visualization, 고정된 실내, 모바일 배경과 Stylized Stage에 효과적이다.

반대로 파괴 가능한 Environment, 시간대가 계속 변하는 Open World와 움직이는 Light가 핵심인 Scene은 완전한 Bake만으로 처리하기 어렵다.

Realtime, Baked와 Mixed를 Object와 Light 역할에 따라 나누는 편이 현실적이다.

---

## 흔한 오해

### Baked Lighting은 Runtime 비용이 0이다

Lightmap Sample, Decode, Texture Memory와 Bandwidth 비용이 남는다.

Realtime Light Loop와 Shadow Rendering을 줄이는 방식이다.

### Lightmap은 Albedo를 대신한다

Albedo는 Material의 고유 색이고 Lightmap은 Scene Lighting이다.

Shader가 둘을 결합해 최종 Diffuse를 만든다.

### Resolution이 높을수록 항상 좋은 결과다

UV, Geometry 두께, Padding과 Sample 문제가 있으면 Resolution만 높여도 Artifact가 남는다.

### 모든 Object를 Lightmap Static으로 만들면 좋다

움직일 Object는 Bake 결과와 맞지 않으며 불필요한 Surface는 Atlas를 낭비한다.

### Baked Light는 Dynamic Object도 자동으로 밝힌다

Dynamic Object에는 Light Probe나 APV가 필요하고 Realtime Direct Light는 Mixed 설정이 필요할 수 있다.

### Bake하면 Reflection도 모두 저장된다

Lightmap은 주로 Diffuse GI를 담당하며 매끄러운 반사는 Reflection Probe와 Skybox가 필요하다.

---

## 전체 처리 흐름

```text
Editor
Light + Static Mesh + Material
              │
              ▼
      Lightmapper Scene 분석
              │
      Direct / Indirect Sample
      Bounce / Shadow / Denoise
              │
              ▼
        Lighting Data 생성
        ├─ Lightmap Atlas
        ├─ Light Probe Data
        └─ Reflection Probe Data
              │
──────────── Runtime ────────────
              │
Static Renderer Lightmap UV
              │
              ▼
        Lightmap Sample
              │
              ├─ Albedo / Normal
              ├─ Realtime 또는 Mixed Light
              ├─ Reflection Probe
              └─ Emission
              │
              ▼
          Final Lit Color
```

Baked Lighting은 Lighting을 없애는 방식이 아니라 변화하지 않는 계산을 사전 Data로 변환해 Runtime의 반복을 줄이는 방식이다.

---

## 정리

Baked Lighting은 고정된 Light와 Static Geometry의 Lighting을 Runtime 전에 계산해 Lightmap과 Probe Data에 저장한다.

Lightmap은 Scene Surface의 Direct·Indirect Diffuse Lighting과 Baked Shadow를 Texture Texel에 기록한다.

Mesh는 겹치지 않고 Padding이 확보된 Lightmap UV를 통해 자신의 Baked Lighting을 Sample한다.

Baked GI는 Surface 사이의 여러 Bounce와 Color Bleeding을 긴 사전 계산으로 표현한다.

Runtime에서는 Realtime Light Loop와 Shadow Map 생성을 줄이는 대신 Lightmap Texture Sample, Decode와 Memory Bandwidth를 사용한다.

Texel Density와 Scale in Lightmap이 높을수록 Detail은 좋아지지만 Atlas 수, Memory와 Bake Time이 증가한다.

Directional Lightmap은 Light Direction Data를 추가해 Normal Map 반응을 개선하지만 Texture와 Shader 비용이 늘어난다.

Lightmap은 Bake 당시 고정된 Surface를 위한 Data이므로 움직이는 Object는 Light Probe나 APV로 Baked Indirect Light를 받아야 한다.

Dynamic Object의 Realtime Direct Light와 Shadow가 필요하면 Mixed Lighting을 결합한다.

금속과 매끄러운 Surface의 Indirect Specular는 Lightmap이 아니라 Reflection Probe와 Skybox가 담당한다.

URP Baked Lit은 Realtime Light Keyword와 Variant를 제거해 Baked GI 중심 Material을 더 단순하게 Rendering할 수 있다.

Baked Lighting은 Runtime 성능을 얻는 대신 Bake Time, Texture Memory, Static Scene 제약과 UV·Artifact 관리 비용을 지불한다.

품질과 성능은 모든 Lightmap Resolution을 높이는 방식보다 중요한 Surface의 Texel 배분, Atlas 수, Probe와 Realtime Light 조합으로 조절해야 한다.
