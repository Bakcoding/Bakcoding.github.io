---
title: "[Unity 렌더링] 6-3. URP와 HDRP는 무엇이 다를까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - URP
  - HDRP
  - RenderPipeline
permalink: /programming/unity-6-3-urp-vs-hdrp/
toc: true
toc_sticky: true
date: 2026-08-16
last_modified_at: 2026-08-16
---

Unity는 SRP 기반의 완성된 Render Pipeline으로 Universal Render Pipeline과 High Definition Render Pipeline을 제공한다.

두 Pipeline은 같은 SRP Core 위에서 동작하지만 목표가 다르다.

URP는 다양한 Platform에서 확장 가능한 Graphics를 구현하는 범용 Pipeline이다.

HDRP는 고성능 Hardware에서 높은 Fidelity를 구현하는 Pipeline이다.

```text
Scriptable Render Pipeline
├─ URP
│  └─ 넓은 Platform 범위와 확장 가능한 성능
│
└─ HDRP
   └─ 고성능 Hardware와 높은 Graphics Fidelity
```

어느 하나가 다른 하나의 상위 Version은 아니다.

Target Platform, 원하는 표현, 성능 Budget과 팀 Workflow에 맞춰 선택하는 서로 다른 제품이다.

---

## URP란?

URP는 `Universal Render Pipeline`의 약자다.

Unity가 제작한 Prebuilt Scriptable Render Pipeline이다.

Mobile부터 Desktop, Console, Web과 XR까지 폭넓은 Hardware를 대상으로 한다.

```text
URP의 방향
├─ 다양한 Platform
├─ 확장 가능한 Quality
├─ 비교적 단순한 Workflow
├─ 2D와 3D Rendering
└─ Custom Render Pass 확장
```

`Universal`은 모든 Device에서 같은 설정과 같은 성능을 보장한다는 뜻이 아니다.

하나의 Pipeline 안에서 Target Hardware에 맞춰 Feature와 Quality를 조절할 수 있다는 의미에 가깝다.

---

## HDRP란?

HDRP는 `High Definition Render Pipeline`의 약자다.

고성능 PC와 Console을 중심으로 높은 Graphics Fidelity를 목표로 하는 Prebuilt SRP다.

```text
HDRP의 방향
├─ Physically Based Lighting
├─ 고품질 Material
├─ 복잡한 Light와 Shadow
├─ Volumetric Effect
├─ 고급 Screen-space Effect
└─ 지원 Hardware의 Ray Tracing
```

HDRP는 모든 Unity Platform을 대상으로 하지 않는다.

높은 품질의 Rendering Technique을 안정적으로 구현할 수 있는 Graphics API와 Hardware Feature를 전제로 한다.

---

## 두 Pipeline의 공통점

URP와 HDRP는 모두 SRP 기반이다.

따라서 공통적인 큰 구조가 있다.

- Render Pipeline Asset으로 설정을 저장한다.
- C# Code가 Render Loop를 구성한다.
- SRP Core의 공통 기능을 사용한다.
- Shader Graph를 지원한다.
- Volume Framework로 환경과 Post-processing을 구성한다.
- SRP Batcher를 활용할 수 있다.
- Frame Debugger와 Rendering Debugger로 진단할 수 있다.

```text
URP / HDRP
    │
    ├─ RenderPipelineAsset
    ├─ RenderPipeline Instance
    ├─ ScriptableRenderContext
    ├─ SRP Core
    └─ Pipeline 전용 Shader Library
```

공통 Framework를 사용한다고 Shader, Material과 기능이 서로 호환되는 것은 아니다.

각 Pipeline이 구현한 Rendering Contract가 다르기 때문이다.

---

## 가장 큰 차이는 목표 Hardware다

URP는 저사양부터 고사양까지 넓은 범위를 목표로 한다.

HDRP는 Compute Shader와 현대적인 GPU 기능을 제공하는 고성능 Hardware를 중심으로 한다.

| 구분 | URP | HDRP |
| --- | --- | --- |
| 핵심 목표 | 넓은 Platform과 확장성 | 고성능 Hardware의 고품질 표현 |
| Mobile | 지원 | 지원하지 않음 |
| WebGL | 지원 | 지원하지 않음 |
| Nintendo Switch | 지원 | 지원하지 않음 |
| Mobile VR | 지원 | 지원하지 않음 |
| Desktop·Console | 지원 | 지원 |
| Hardware 요구 | 비교적 넓음 | 비교적 높음 |

지원 여부와 실제 성능은 구분해야 한다.

URP를 지원하는 Device라도 무거운 Feature를 많이 사용하면 목표 Frame Rate를 달성하지 못할 수 있다.

HDRP 지원 Platform이라도 모든 GPU가 동일한 Quality와 성능을 내는 것은 아니다.

---

## Platform 지원 비교

Unity 6 공식 기능 비교표의 큰 범주는 다음과 같다.

```text
URP
├─ Windows
├─ macOS
├─ Linux
├─ 주요 Console
├─ Nintendo Switch
├─ iOS / Android
├─ Desktop / Mobile VR
├─ HoloLens
└─ WebGL

HDRP
├─ Windows
├─ macOS
├─ Linux
├─ 주요 고성능 Console
└─ Desktop VR
```

정확한 지원 범위는 Unity Version, Graphics API와 Platform Package에 따라 달라질 수 있다.

Project를 시작할 때 사용하는 Unity Version의 공식 Requirements를 다시 확인해야 한다.

---

## URP가 Mobile에 적합한 이유

Mobile GPU는 Desktop GPU와 다른 제약을 가진다.

- 제한된 Memory Bandwidth
- 발열과 전력 Budget
- 다양한 GPU 성능 범위
- Tile-based GPU Architecture
- 높은 Screen Resolution

URP는 Feature와 Quality를 조절해 이 범위에 대응할 수 있다.

```text
Mobile용 URP 조정 예
├─ Render Scale 감소
├─ MSAA 단계 선택
├─ Additional Light 제한
├─ Shadow Distance 감소
├─ Cascade 수 감소
├─ Post-processing 최소화
└─ 불필요한 Texture 생성 방지
```

URP를 선택했다는 사실만으로 Mobile 최적화가 끝나지는 않는다.

Device Tier별 Asset과 실제 기기 Profiling이 필요하다.

---

## HDRP가 고성능 Hardware를 요구하는 이유

HDRP는 높은 품질을 위해 더 많은 Data와 Pass를 사용할 수 있다.

- 복잡한 Material Model
- 많은 Light를 처리하는 구조
- 고품질 Shadow
- Screen-space Reflection과 Global Illumination
- Volumetric Fog와 Cloud
- 고급 Sky와 Atmospheric Scattering
- Ray Tracing 또는 Path Tracing

```text
높은 Fidelity
    │
    ├─ 더 많은 Buffer
    ├─ 더 복잡한 Shader
    ├─ 더 많은 Sampling
    ├─ 높은 Memory 사용량
    └─ 높은 GPU 비용
```

모든 Feature를 항상 실행하는 것은 아니지만 사용할 수 있는 Quality 범위 자체가 높은 Hardware를 전제로 한다.

---

## Graphics Quality의 방향

URP도 PBR Material, Realtime Shadow, Reflection, Post-processing과 HDR Rendering을 지원한다.

Stylized Game뿐 아니라 사실적인 표현도 가능하다.

HDRP는 더 복잡한 물리 기반 표현과 고품질 Effect를 기본 설계에 깊게 통합한다.

| 표현 영역 | URP | HDRP |
| --- | --- | --- |
| PBR Lit Material | 지원 | 지원 |
| Shader Graph | 지원 | 지원 |
| Integrated Post-processing | 지원 | 지원 |
| Physical Sky | 기본 제공하지 않음 | 지원 |
| Volumetric Cloud | 기본 제공하지 않음 | 지원 |
| Local Volumetrics | 기본 제공하지 않음 | 지원 |
| 고급 Area Light | 제한적 | 폭넓게 지원 |
| Ray Tracing 계열 | 일반 목표가 아님 | 지원 Hardware에서 제공 |

그래픽 품질은 Pipeline 이름만으로 결정되지 않는다.

Art Direction, Asset 품질, Lighting, Shader와 Post-processing 설정이 최종 결과를 만든다.

---

## URP가 저품질이라는 오해

URP의 목표가 확장 가능한 성능이라고 해서 낮은 품질만 제공하는 것은 아니다.

URP에서도 다음 요소를 구성할 수 있다.

- Physically Based Lit Shader
- Reflection Probe
- Light Probe와 Lightmap
- Realtime Shadow와 Cascade
- Screen Space Ambient Occlusion
- Decal
- Depth of Field, Bloom과 Color Grading
- HDR Output이 지원되는 환경

```text
URP 결과 품질
= Asset 품질
+ Lighting 설계
+ Shader와 Material
+ Pipeline Asset 설정
+ Post-processing
+ Target 성능 Budget
```

HDRP 전용 고급 Feature가 필요하지 않다면 URP로도 충분히 높은 품질을 만들 수 있다.

---

## HDRP가 자동으로 사실적인 결과를 만드는가?

HDRP는 사실적인 표현에 필요한 많은 도구를 제공한다.

하지만 잘못된 Asset과 Lighting을 자동으로 수정하지 않는다.

```text
좋은 HDRP 결과
├─ 물리 단위에 맞는 Light
├─ 정확한 Material 값
├─ 올바른 Exposure
├─ 충분한 Texture와 Mesh 품질
├─ 적절한 Reflection
└─ 측정된 Performance Budget
```

Base Color, Metallic, Smoothness와 Normal이 잘못되면 복잡한 Pipeline도 올바른 Material을 만들 수 없다.

HDRP는 높은 품질의 가능성을 제공하며 결과를 보장하지 않는다.

---

## Lighting 구조의 차이

두 Pipeline은 Light를 처리하는 내부 전략과 지원 Feature가 다르다.

URP는 폭넓은 Hardware에서 사용할 수 있도록 확장 가능한 Light 처리 방식을 제공한다.

HDRP는 많은 Light와 복잡한 Light Type을 고성능 GPU에서 처리하는 구조를 제공한다.

```text
URP Lighting
├─ Main Light
├─ Additional Lights
├─ Forward 계열
└─ 조건에 따른 Deferred 계열

HDRP Lighting
├─ Tile / Cluster 기반 Light 분류
├─ 다양한 Light Shape
├─ 복잡한 Material Model
└─ 고급 Shadow와 Volumetric 통합
```

이 구분은 개념적 비교다.

정확한 Render Path와 Feature 지원은 사용 중인 Unity Version의 Pipeline 문서를 기준으로 확인해야 한다.

---

## Light 종류의 차이

기본 Directional, Point와 Spot Light는 두 Pipeline 모두 지원한다.

HDRP는 현실의 조명 형태를 표현하기 위한 Area Light Option이 더 다양하다.

| Light | URP | HDRP |
| --- | --- | --- |
| Directional | 지원 | 지원 |
| Point | 지원 | 지원 |
| Cone Spot | 지원 | 지원 |
| Rectangle Area | Baked 중심 | Realtime과 Baked |
| Tube Area | 기본 제공하지 않음 | Realtime 지원 |
| Box·Pyramid Spot Shape | 기본 제공하지 않음 | 지원 |

Area Light의 지원 방식은 Rendering Cost와 Shadow 지원 여부까지 함께 확인해야 한다.

Inspector에 Light Type이 보이는 것과 모든 Mode에서 같은 기능을 제공하는 것은 다르다.

---

## Material Model의 차이

URP의 대표적인 Material은 Lit, Simple Lit, Unlit이다.

성능과 표현 요구에 맞춰 Shader Complexity를 선택할 수 있다.

HDRP는 Lit 외에도 고품질 표현을 위한 더 복잡한 Material Option을 제공한다.

```text
URP Material 방향
├─ Lit
├─ Simple Lit
├─ Unlit
└─ Platform 범위와 비용 조절

HDRP Material 방향
├─ 고급 Lit
├─ Subsurface Scattering
├─ Coat와 Anisotropy
├─ Fabric과 Hair 계열
└─ 높은 Fidelity의 Surface 표현
```

복잡한 Material Model은 더 많은 Data와 Shader 연산을 요구할 수 있다.

필요하지 않은 Feature를 사용하는 것은 품질 이득 없이 비용만 늘릴 수 있다.

---

## Shader는 서로 호환되지 않는다

URP와 HDRP는 모두 SRP 기반이지만 Pipeline Contract가 다르다.

```text
URP Shader
├─ URP LightMode
├─ URP Shader Library
├─ URP Lighting Data
└─ URP Pass 구성

HDRP Shader
├─ HDRP LightMode
├─ HDRP Shader Library
├─ HDRP Lighting Data
└─ HDRP Pass 구성
```

URP용 Custom HLSL Shader를 HDRP에서 그대로 사용할 수 있다고 가정하면 안 된다.

Shader Graph도 Target Pipeline에 맞는 Target과 Sub Target을 사용한다.

Pipeline 전환 시 Material Converter가 처리하는 범위와 직접 변환할 Custom Shader를 구분해야 한다.

---

## 같은 Material도 다르게 보일 수 있다

Pipeline마다 Lighting Model, Reflection, Exposure와 Post-processing의 기본 동작이 다르다.

Texture와 숫자 값을 옮겨도 결과가 완전히 같지 않을 수 있다.

```text
같은 Base Color / Metallic / Smoothness
        │
        ├─ Light Unit 차이
        ├─ Reflection 차이
        ├─ Ambient Lighting 차이
        ├─ Exposure 차이
        └─ Tone Mapping 차이
        │
        ▼
서로 다른 최종 화면
```

Migration은 Compile Error를 없애는 작업에서 끝나지 않는다.

Lighting과 Visual을 다시 검수해야 한다.

---

## Render Path의 차이

URP와 HDRP는 Project 조건에 따라 여러 Rendering Path를 제공할 수 있다.

대표적으로 Forward와 Deferred 계열이 있지만 구현 세부 내용은 다르다.

| 항목 | URP | HDRP |
| --- | --- | --- |
| Forward 계열 | 폭넓은 Platform에 사용 | 고급 Lighting 구조와 결합 |
| Deferred 계열 | 지원 조건과 Feature 제한 확인 필요 | 주요 고품질 Workflow에 활용 |
| Light 처리 | Main·Additional Light 또는 Cluster 계열 | Tile·Cluster 기반 구조 중심 |
| 목표 | 확장성과 호환성 | 많은 Light와 복잡한 Material |

`Forward`라는 이름이 같다고 동일한 Buffer, Pass와 성능 특성을 가진 것은 아니다.

Pipeline별 공식 문서를 따로 확인해야 한다.

---

## 2D Rendering의 차이

URP는 2D Renderer를 제공한다.

Sprite Light, 2D Shadow와 Pixel Perfect Workflow를 Pipeline 안에서 구성할 수 있다.

```text
URP 2D
├─ 2D Renderer
├─ 2D Light
├─ 2D Shadow
├─ Sprite Lit Material
└─ Pixel Perfect Camera 연계
```

HDRP는 고성능 Hardware의 고품질 3D Rendering이 중심이다.

2D Game에 HDRP의 고급 3D Feature가 필요하지 않다면 일반적으로 URP의 2D Workflow가 더 자연스럽다.

2D라는 이유만으로 성능 측정을 생략할 수는 없다.

많은 Sprite, Transparency, Light와 Overdraw는 여전히 GPU 비용을 만든다.

---

## Sky와 Atmosphere의 차이

URP는 일반적인 Skybox Workflow를 지원한다.

HDRP는 Sky와 Atmosphere를 더 복잡한 환경 System으로 다룬다.

```text
URP
├─ Cubemap Skybox
├─ Panoramic Skybox
└─ Procedural Skybox 계열

HDRP
├─ HDRI Sky
├─ Gradient Sky
├─ Physical Sky
├─ Atmospheric Scattering
├─ Cloud Layer
└─ Volumetric Cloud
```

야외의 시간 변화, 대기 원근과 구름을 핵심 Visual로 사용하는 Project에서는 HDRP의 통합 기능이 유리할 수 있다.

단순한 배경 Skybox만 필요하다면 해당 기능의 비용과 제작 복잡도를 감수할 이유가 적다.

---

## Fog와 Volumetric의 차이

URP는 일반적인 Fog를 사용할 수 있다.

HDRP는 공간에 밀도를 가진 Fog와 Local Volume을 포함한 고급 Volumetric 기능을 제공한다.

```text
URP Fog
└─ Scene 전체의 일반 Fog 표현

HDRP Volumetric
├─ Volumetric Fog
├─ Local Volumetric Fog
├─ Light Scattering
└─ 3D Density Texture
```

Volumetric Effect는 깊이감과 Light Beam 표현에 효과적이지만 Sampling과 Memory 비용이 발생한다.

Resolution, Distance와 Quality를 목표 GPU에 맞춰 조정해야 한다.

---

## Ray Tracing의 차이

HDRP는 지원 Hardware와 Graphics API에서 Ray Tracing Feature를 제공한다.

Reflection, Shadow, Ambient Occlusion과 Global Illumination 같은 영역에 사용할 수 있다.

Path Tracing은 Offline에 가까운 고품질 Reference 또는 특정 Rendering 목적에 활용할 수 있다.

```text
HDRP Ray Tracing 사용 조건
├─ 지원 Platform
├─ 지원 Graphics API
├─ 지원 GPU
├─ 적절한 Driver
└─ 충분한 Frame Budget
```

URP의 핵심 목표는 폭넓은 Platform에서 확장 가능한 Rendering이다.

Ray Tracing이 Project의 필수 조건이면 Unity Version과 HDRP Requirements를 기준으로 Hardware 범위를 먼저 확정해야 한다.

---

## Post-processing 비교

두 Pipeline 모두 통합된 Post-processing과 Volume Workflow를 제공한다.

기본적인 Bloom, Color Adjustments, Depth of Field와 Tone Mapping을 구성할 수 있다.

HDRP는 고품질 Rendering Workflow에 맞는 더 다양한 Option을 제공하는 경우가 많다.

```text
Volume
├─ Global Volume
├─ Local Volume
├─ Profile
└─ Override
   ├─ Bloom
   ├─ Exposure
   ├─ Color Grading
   └─ Pipeline별 Effect
```

같은 이름의 Effect도 Option과 내부 Algorithm이 다를 수 있다.

Post-processing 비용은 Effect 수뿐 아니라 Resolution, Sample 수와 Temporal History 사용 여부에 따라 달라진다.

---

## Camera Workflow 비교

URP는 Base와 Overlay Camera를 조합하는 Camera Stack Workflow를 제공한다.

UI, Weapon Camera와 Layer별 Rendering을 구성할 때 사용할 수 있다.

HDRP의 Camera 구성은 고품질 Frame Settings와 Physical Camera Option을 중심으로 다르다.

```text
URP Camera
├─ Base Camera
├─ Overlay Camera
└─ Camera Stack

HDRP Camera
├─ Physical Camera
├─ Frame Settings
└─ 고급 Exposure와 Buffer 설정
```

Pipeline을 전환할 때 Camera Component의 기존 설정이 일대일로 대응한다고 가정하면 안 된다.

Camera Stack과 Custom Pass 사용 방식도 다시 설계해야 할 수 있다.

---

## Pipeline Asset의 차이

URP와 HDRP는 각자의 Render Pipeline Asset Type을 사용한다.

Asset에 노출되는 설정도 목표가 다르다.

```text
URP Asset 예
├─ Rendering Path
├─ Render Scale
├─ MSAA
├─ Main / Additional Light
├─ Shadow
└─ Renderer 목록

HDRP Asset 예
├─ 지원할 Rendering Feature
├─ Lighting과 Shadow Quality
├─ Decal과 Volumetric
├─ Post-processing
├─ Dynamic Resolution
└─ Ray Tracing 관련 지원
```

Quality Level마다 같은 Pipeline의 서로 다른 Asset을 지정할 수 있다.

URP Asset과 HDRP Asset을 단순한 Quality Preset처럼 Frame마다 교체하는 구조는 Material과 Shader 호환성 문제 때문에 일반적인 방식이 아니다.

---

## URP Renderer의 의미

URP Asset은 하나 이상의 Renderer Data를 참조할 수 있다.

Renderer는 Camera가 어떤 Rendering 구조를 사용할지 정의한다.

```text
URP Pipeline Asset
└─ Renderer List
   ├─ Universal Renderer
   ├─ 2D Renderer
   └─ Project용 Renderer 설정
```

Renderer Feature를 통해 정해진 지점에 Custom Render Pass를 추가할 수 있다.

이 구조의 Culling, Renderer와 Render Pass 흐름은 다음 글에서 자세히 연결한다.

여기서는 URP가 Pipeline Asset 안에서 Rendering 방식과 확장점을 구성한다는 점만 구분하면 된다.

---

## HDRP Frame Settings의 의미

HDRP는 많은 Feature를 Camera와 상황에 따라 제어해야 한다.

Frame Settings는 특정 Frame에서 사용할 Rendering Feature를 결정하는 계층이다.

```text
HDRP Default Settings
        │
        ▼
Camera / Reflection별 Override
        │
        ▼
해당 Frame의 Feature 결정
```

예를 들어 Camera가 Motion Vector, Post-processing, Volumetric 또는 특정 Pass를 사용할지 조정할 수 있다.

높은 Feature 수를 가진 만큼 설정 계층을 이해하지 못하면 불필요한 비용이나 예상과 다른 결과가 생길 수 있다.

---

## Custom Rendering 확장 방식

URP와 HDRP 모두 Custom Rendering 확장점을 제공하지만 API와 Workflow가 다르다.

```text
URP 확장
├─ ScriptableRendererFeature
├─ ScriptableRenderPass
└─ RenderPipelineManager Callback

HDRP 확장
├─ Custom Pass
├─ Custom Pass Volume
└─ RenderPipelineManager Callback
```

URP용 Renderer Feature Code를 HDRP Custom Pass로 그대로 옮길 수 없다.

Injection Point, 사용 가능한 Buffer와 Shader Include가 다르다.

Asset Store Package나 사내 Effect를 선택할 때 지원 Pipeline과 Version을 확인해야 한다.

---

## 성능 비교가 단순하지 않은 이유

URP와 HDRP의 성능은 Pipeline 이름 하나로 비교할 수 없다.

다음 조건이 Frame Time을 바꾼다.

- Target GPU와 Graphics API
- Output Resolution과 Render Scale
- Rendering Path
- Light와 Shadow 수
- Material과 Shader Complexity
- Transparency와 Overdraw
- Post-processing
- Volumetric와 Ray Tracing
- Dynamic Resolution과 Upscaler

```text
실제 Frame Cost
= Pipeline 기본 구조
+ 활성 Feature
+ Scene Content
+ Resolution
+ Hardware 특성
+ Driver와 Graphics API
```

같은 Scene도 설정에 따라 결과가 크게 달라진다.

---

## URP가 항상 HDRP보다 빠른가?

일반적으로 URP는 더 넓은 Hardware와 확장 가능한 비용을 목표로 한다.

그러나 URP Project가 항상 모든 HDRP Project보다 빠른 것은 아니다.

```text
무거운 URP Scene
├─ 높은 Render Scale
├─ 많은 Additional Light
├─ 큰 Shadow Distance
├─ 다수의 Full-screen Pass
└─ 많은 Transparency

절제된 HDRP Scene
├─ 제한된 Light
├─ 일부 Feature Off
├─ Dynamic Resolution
└─ 단순한 Content
```

실제 Hardware에서 측정하기 전에는 순서를 확정할 수 없다.

다만 Mobile과 Web처럼 HDRP가 지원하지 않는 Platform에서는 성능 비교 이전에 선택지가 URP로 제한된다.

---

## HDRP의 성능 비용이 커지는 지점

HDRP의 고급 Feature는 시각적 이점과 함께 비용을 가진다.

| Feature | 주요 비용 후보 |
| --- | --- |
| Volumetric Fog·Cloud | 3D 또는 저해상도 Buffer, Sampling, Temporal 처리 |
| Screen Space Reflection | Ray Marching, Color·Depth·Normal 접근 |
| Ray Tracing | Acceleration Structure, Ray Dispatch, Denoising |
| 고품질 Shadow | Atlas Memory, Caster Drawing, Filtering |
| 복잡한 Material | G-buffer·Shader 연산과 Variant |
| 높은 해상도 | Pixel 연산과 Bandwidth 증가 |

Feature를 켤 수 있다는 것과 제품에서 켜야 한다는 것은 다르다.

화면 기여도와 GPU 비용을 비교해 Quality Tier를 구성한다.

---

## URP의 성능 비용이 커지는 지점

URP에서도 잘못된 설정은 큰 비용을 만든다.

| Feature | 주요 비용 후보 |
| --- | --- |
| Additional Light | Light Loop와 Shadow Pass |
| Shadow | Caster Drawing, Atlas와 Filtering |
| Opaque·Depth Texture | 추가 Copy 또는 Prepass와 Memory |
| Renderer Feature | Full-screen Pass와 중간 Texture |
| High Render Scale | Pixel 수와 Bandwidth |
| MSAA | Color·Depth Sample Memory와 Resolve |
| Transparency | Overdraw와 Sorting |

URP Asset, Renderer와 Camera가 실제로 어떤 Texture와 Pass를 요구하는지 Frame Debugger로 확인해야 한다.

사용하지 않는 Renderer Feature를 등록한 채 유지하지 않는 것이 좋다.

---

## Resolution이 성능에 미치는 영향

화면 해상도가 커지면 Pixel 수가 증가한다.

```text
1920 × 1080 = 약 2.07M Pixel
2560 × 1440 = 약 3.69M Pixel
3840 × 2160 = 약 8.29M Pixel
```

4K는 1080p보다 약 네 배 많은 Pixel을 가진다.

Full-screen Effect와 G-buffer가 여러 개라면 Bandwidth와 Memory 차이는 더 커진다.

URP의 Render Scale이나 두 Pipeline의 Dynamic Resolution 지원을 활용할 수 있다.

비교 Test에서는 Output Resolution과 내부 Rendering Resolution을 동일하게 맞춰야 한다.

---

## Memory 사용 비교

HDRP는 고급 Feature를 위해 더 많은 중간 Buffer를 사용할 가능성이 높다.

URP도 Deferred, Camera Texture와 여러 Custom Pass를 사용하면 Memory 사용량이 커질 수 있다.

```text
Render Target Memory
= Width × Height
× Format Bytes
× Sample Count
× Buffer Count
```

Memory Peak에는 Shadow Atlas, History Buffer, Temporary Texture와 Compute Buffer도 포함된다.

평균 Memory만 보지 말고 Camera 전환과 Effect 활성화 시 Peak를 확인한다.

Mobile에서는 Bandwidth와 Tile Memory 동작까지 함께 고려한다.

---

## CPU 성능 비교

GPU Feature만 비교하면 Rendering 성능의 절반을 놓칠 수 있다.

CPU에서는 다음 작업이 비용을 만든다.

- Culling
- Renderer 정렬과 Batch 준비
- Light와 Shadow Data 구성
- Render Pass Scheduling
- Draw와 State Command 제출
- Shader Variant와 Resource 관리

```text
CPU Bound
├─ Main Thread
├─ Render Thread
└─ Job Worker

GPU Bound
├─ Vertex
├─ Fragment
├─ Compute
└─ Bandwidth
```

Pipeline을 비교할 때 CPU와 GPU Frame Time을 각각 기록해야 한다.

한 Pipeline이 CPU에서는 유리하고 GPU에서는 불리할 수도 있다.

---

## SRP Batcher는 둘 다 사용할 수 있다

SRP Batcher는 호환 Shader의 Material Data를 효율적으로 관리해 CPU Rendering 비용을 줄이는 기능이다.

URP와 HDRP 모두 이를 활용할 수 있다.

```text
SRP Batcher 효과 대상
└─ CPU의 Shader Binding과 Draw 준비 비용

자동으로 줄지 않는 것
├─ Polygon 수
├─ Pixel Overdraw
├─ Texture Bandwidth
└─ Shader 자체의 GPU 연산
```

SRP Batcher가 활성화되어도 GPU가 병목이면 Frame Rate 변화가 작을 수 있다.

Profiler와 Frame Debugger에서 실제 호환과 Batch 원인을 확인한다.

---

## Shader Variant 관리

두 Pipeline 모두 많은 Feature Keyword 조합을 가질 수 있다.

HDRP는 Feature 범위가 넓어 Variant와 Build Data 관리가 특히 중요할 수 있다.

URP도 Light, Shadow, Decal과 Renderer Feature 조합에 따라 Variant가 늘어난다.

```text
Variant 수 증가 요인
├─ Multi Compile Keyword
├─ Material Feature
├─ Lighting Option
├─ Shadow Option
├─ Rendering Path
└─ Platform
```

사용하지 않는 Feature를 Pipeline Settings에서 비활성화하면 Strip에 도움을 줄 수 있다.

Build Time, Build Size와 Runtime Warmup을 함께 확인해야 한다.

---

## Quality Level 설계

Pipeline 선택 이후에도 Hardware Tier별 설정이 필요하다.

```text
Low
├─ 낮은 Render Scale
├─ 짧은 Shadow Distance
├─ 적은 Light
└─ 단순 Post-processing

Medium
├─ 기본 Render Scale
├─ 중간 Shadow
└─ 주요 Effect

High
├─ 높은 Shadow Quality
├─ 추가 Effect
└─ 고품질 Sampling
```

같은 Pipeline의 여러 Render Pipeline Asset을 Quality Level별로 지정할 수 있다.

설정 전환 시 Runtime Memory Spike와 Shader Variant 준비도 Test한다.

---

## URP를 선택하기 좋은 Project

다음 조건에서는 URP가 자연스러운 출발점이 된다.

- iOS 또는 Android를 Target으로 한다.
- WebGL Build가 필요하다.
- Nintendo Switch를 지원해야 한다.
- Mobile XR 또는 폭넓은 XR Device가 필요하다.
- 2D Renderer와 2D Light를 사용한다.
- 하나의 Project로 다양한 Hardware Tier를 지원한다.
- 고급 HDRP 전용 Feature가 필수가 아니다.
- Custom Renderer Feature로 Effect를 확장하려 한다.

```text
넓은 Platform 범위
        +
조절 가능한 Graphics Cost
        +
일반적인 2D·3D Feature
        │
        ▼
URP 후보
```

---

## HDRP를 선택하기 좋은 Project

다음 조건에서는 HDRP의 장점이 커진다.

- Target이 고성능 PC 또는 Console로 명확하다.
- 사실적인 Lighting과 Material이 핵심이다.
- Physical Sky와 Volumetric Cloud가 필요하다.
- Local Volumetric Fog와 고급 Atmosphere가 중요하다.
- 복잡한 Area Light와 고품질 Shadow가 필요하다.
- 지원 Hardware에서 Ray Tracing을 활용한다.
- 높은 Fidelity를 위한 전담 Technical Art 역량이 있다.

```text
고성능 Target Hardware
        +
HDRP 전용 Feature 필요
        +
충분한 제작·최적화 역량
        │
        ▼
HDRP 후보
```

단순히 Screenshot이 좋아 보인다는 이유만으로 선택하면 Runtime Budget과 Content Workflow에서 문제가 생길 수 있다.

---

## URP를 선택하면 안 되는 경우가 있는가?

Project의 핵심 Visual이 HDRP 전용 Feature에 강하게 의존한다면 URP에서 같은 결과를 만들기 위해 많은 Custom 구현이 필요할 수 있다.

예를 들어 다음 요구를 생각할 수 있다.

- 복잡한 Physical Sky와 Atmosphere
- 고급 Volumetric Cloud
- 다수의 Realtime Area Light
- Pipeline에 통합된 Ray Tracing Effect
- 고급 Material Model

```text
URP Custom 구현 비용
>
HDRP Hardware 제약과 Runtime 비용
```

위 관계라면 HDRP가 더 적합할 수 있다.

기능 목록을 먼저 확정하고 구현 비용과 Target 범위를 비교해야 한다.

---

## HDRP를 선택하면 안 되는 경우가 있는가?

Target Platform이 HDRP 지원 범위 밖이면 사용할 수 없다.

지원 Platform이라도 낮은 사양의 GPU를 폭넓게 포함해야 하면 Quality 목표와 충돌할 수 있다.

```text
HDRP와 충돌하는 조건
├─ Mobile 필수
├─ WebGL 필수
├─ Switch 필수
├─ 매우 낮은 GPU Minimum Spec
├─ 작은 Memory Budget
└─ HDRP 전용 Feature가 필요하지 않음
```

고품질 Pipeline의 Feature를 대부분 끄고도 Hardware 요구와 제작 복잡도를 감수한다면 선택 이점이 줄어든다.

---

## 여러 Platform을 동시에 지원할 때

PC와 Mobile을 같은 Project에서 지원하려면 URP가 일반적으로 관리하기 쉽다.

하나의 Pipeline 안에서 Quality Asset과 Content 설정을 조절할 수 있기 때문이다.

```text
Shared URP Project
├─ Mobile Quality Asset
├─ Desktop Quality Asset
├─ Platform별 Shader Variant
└─ Platform별 Texture와 Mesh Import 설정
```

PC는 HDRP, Mobile은 URP로 한 Content를 자동 공유하는 방식은 단순하지 않다.

Material, Shader, Lighting, Camera와 Effect가 Pipeline별로 달라 별도 제작과 검증 비용이 커진다.

정말 필요한 경우 Pipeline별 Project 또는 명확한 Content Abstraction 전략이 필요하다.

---

## Pipeline 전환 비용

URP와 HDRP 사이의 전환은 Render Pipeline Asset 하나를 교체하는 작업이 아니다.

```text
전환 영향 범위
├─ Material과 Shader
├─ Lighting과 Light Unit
├─ Camera
├─ Post-processing Volume
├─ Custom Pass
├─ Reflection과 Sky
├─ Terrain과 VFX
└─ Performance Budget
```

Converter가 Standard Material의 일부를 바꿀 수 있어도 Custom Shader와 Project 전용 Rendering Code는 직접 Migration해야 할 수 있다.

Visual Regression Test와 Target Device Profiling을 다시 수행해야 한다.

---

## Asset Store Package를 확인하는 기준

Rendering 관련 Package는 Pipeline과 Version 의존성이 크다.

구매하거나 도입하기 전에 다음 항목을 확인한다.

- URP 또는 HDRP 중 어느 Pipeline을 지원하는가?
- 사용하는 Unity와 Pipeline Package Version을 지원하는가?
- Shader Graph인지 Custom HLSL인지?
- Renderer Feature 또는 Custom Pass가 포함되는가?
- Forward와 Deferred 모두 지원하는가?
- XR과 Camera Stack에서 동작하는가?
- Source Code와 Upgrade Guide가 제공되는가?

```text
"SRP 지원"
≠ URP와 HDRP 모두 지원
```

SRP 지원이라는 표현만으로 호환성을 판단하면 안 된다.

---

## 팀 역량과 Workflow 비교

HDRP는 다양한 고급 Feature와 물리 단위 기반 Workflow를 이해해야 장점을 충분히 사용할 수 있다.

URP도 Custom Shader와 Renderer Feature를 깊게 다루면 Rendering 지식이 필요하다.

| 팀 조건 | 고려 방향 |
| --- | --- |
| 소규모 팀, 넓은 Platform | URP가 관리하기 쉬운 경우가 많음 |
| 2D 중심 | URP 2D Renderer 검토 |
| 고품질 3D 전담 팀 | HDRP의 장점 활용 가능 |
| Rendering Programmer 없음 | Customization 범위를 보수적으로 설정 |
| 장기 Live Service | Upgrade와 Package 호환성 비용 포함 |

Pipeline의 Feature 수보다 팀이 안정적으로 제작하고 Debug할 수 있는 범위가 중요하다.

---

## Prototype으로 비교하는 방법

문서만 보고 결정하기 어려우면 작은 Vertical Slice를 두 Pipeline에서 검증할 수 있다.

```text
동일한 평가 조건
├─ 대표 Scene
├─ 대표 Character와 Material
├─ 대표 Light 수
├─ 목표 Resolution
├─ 핵심 Effect
└─ Target Hardware
```

기록할 항목은 다음과 같다.

- CPU와 GPU Frame Time
- Draw Call과 SetPass
- Render Target Memory
- Build Size와 Shader Variant
- Visual 목표 달성도
- Artist 작업 시간
- Custom Feature 구현 난이도

단순 Sample Scene보다 실제 Production Content에 가까운 Slice가 의미 있다.

---

## 공정한 성능 비교 조건

URP와 HDRP Benchmark에서는 화면 품질과 설정을 최대한 통제해야 한다.

```text
통제할 항목
├─ 동일 Resolution
├─ 동일 Frame Rate 제한
├─ 동일 Geometry
├─ 동일 Texture 해상도
├─ 유사한 Light와 Shadow 품질
├─ 유사한 Post-processing
└─ 동일 Hardware와 Graphics API
```

HDRP에서 Volumetric과 Ray Tracing을 켜고 URP에서는 끈 상태를 비교하면 Pipeline 기본 비용과 Feature 비용을 분리할 수 없다.

반대로 두 Pipeline을 가장 낮은 설정으로만 비교하면 HDRP를 선택하는 품질 이유가 사라진다.

동일 품질 비교와 각 Pipeline의 목표 품질 비교를 따로 수행하는 것이 좋다.

---

## Profiler에서 확인할 항목

Pipeline을 비교할 때 평균 FPS 하나만 기록하지 않는다.

- CPU Main Thread Time
- CPU Render Thread Time
- GPU Frame Time
- Shadow Pass 비용
- Opaque와 Transparent 비용
- Post-processing 비용
- Render Texture Allocation
- GC Allocation
- Memory Peak

```text
Frame Budget at 60 FPS
≈ 16.67ms

CPU와 GPU 중 더 오래 걸리는 쪽이
대체로 Frame 완료 시점을 제한한다.
```

Editor 결과는 Development Build와 다를 수 있다.

실제 Target Device의 Build에서 측정해야 한다.

---

## Frame Debugger에서 확인할 항목

Frame Debugger는 Pipeline이 실제로 수행한 Event와 Draw를 보여 준다.

```text
확인 목록
├─ Shadow Pass 수
├─ Depth / Normal Prepass
├─ Opaque와 Transparent
├─ G-buffer
├─ Copy Color / Depth
├─ Custom Pass
├─ Post-processing
└─ Final Blit
```

URP에서는 Camera Texture와 Renderer Feature 때문에 생긴 Pass를 확인한다.

HDRP에서는 활성화한 고급 Feature와 Debug 설정이 어떤 Pass를 추가했는지 확인한다.

예상하지 않은 Pass가 있다면 Camera, Pipeline Asset, Volume과 Custom Extension을 역으로 추적한다.

---

## Rendering Debugger 활용

Rendering Debugger는 Material, Lighting과 Rendering Feature를 시각적으로 진단하는 데 도움을 준다.

Pipeline마다 제공하는 Debug Mode의 범위는 다르다.

```text
Debug View 예
├─ Material Property
├─ Lighting Contribution
├─ Shadow
├─ Overdraw 계열 정보
├─ Mipmap
└─ Rendering Feature 상태
```

화면이 어둡거나 반사가 이상할 때 Post-processing부터 무작정 바꾸지 않는다.

Material, Light, Exposure와 Reflection을 Debug View로 분리해 확인한다.

---

## 선택 절차

Pipeline 선택을 다음 순서로 진행할 수 있다.

```text
1. 필수 Platform 확정
        │
        ▼
2. Minimum Hardware 확정
        │
        ▼
3. 필수 Graphics Feature 목록
        │
        ▼
4. 목표 Resolution과 Frame Rate
        │
        ▼
5. 팀의 Art·Rendering Workflow
        │
        ▼
6. Vertical Slice Profiling
        │
        ▼
7. Pipeline 결정
```

Mobile, WebGL 또는 Switch가 필수면 HDRP는 후보에서 제외된다.

HDRP 전용 Feature가 핵심이고 Target이 고성능 PC·Console이면 HDRP를 검토한다.

그 사이의 많은 Project에서는 URP가 범용적인 출발점이 된다.

---

## 선택 기준 표

| 질문 | URP 쪽 조건 | HDRP 쪽 조건 |
| --- | --- | --- |
| Target Platform | Mobile, Web, Switch 포함 | 고성능 PC·Console 중심 |
| Minimum GPU | 폭넓은 범위 | 현대적 고성능 GPU |
| Visual 목표 | Stylized부터 일반 PBR | 높은 Fidelity와 현실적 표현 |
| 2D 기능 | 2D Renderer 활용 | 핵심 목표가 아님 |
| Volumetric | 제한적 또는 Custom | 고급 기능 통합 |
| Ray Tracing | 핵심 목표가 아님 | 지원 Hardware에서 활용 |
| Custom 확장 | Renderer Feature·Pass | Custom Pass |
| 성능 전략 | Quality를 넓게 확장 | 높은 품질 Budget을 관리 |

표의 한 항목만으로 결정하지 않는다.

필수 조건과 비용을 함께 평가한다.

---

## 자주 혼동하는 내용

### HDRP는 URP의 상위 Version인가?

아니다.

목표 Platform과 Graphics Feature가 다른 별도의 Pipeline이다.

### URP는 Mobile 전용인가?

아니다.

Mobile뿐 아니라 Desktop, Console과 XR에서도 사용할 수 있다.

### HDRP는 PC에서만 동작하는가?

아니다.

지원 Console과 macOS·Linux 등 공식 지원 범위가 있지만 Mobile, WebGL과 Switch는 지원하지 않는다.

### URP는 사실적인 Graphics를 만들 수 없는가?

아니다.

PBR, Shadow, Reflection과 Post-processing을 사용해 사실적인 결과를 만들 수 있지만 HDRP 전용 고급 Feature와 범위가 다르다.

### HDRP를 사용하면 자동으로 화면이 좋아지는가?

아니다.

Asset, Material, Lighting, Exposure와 Post-processing을 올바르게 제작해야 한다.

### URP는 항상 HDRP보다 빠른가?

아니다.

일반적인 목표 비용은 다르지만 실제 성능은 Feature, Scene, Resolution과 Hardware를 측정해야 판단할 수 있다.

### URP Shader를 HDRP에서 사용할 수 있는가?

일반적으로 그대로 사용할 수 없다.

Pipeline별 Shader Contract와 Library가 다르다.

### 같은 Project에서 URP와 HDRP를 쉽게 전환할 수 있는가?

아니다.

Material, Shader, Lighting, Camera와 Custom Rendering Code의 Migration이 필요하다.

### SRP Batcher가 모든 GPU 비용을 줄이는가?

아니다.

주로 CPU의 Shader Binding과 Draw 준비 비용을 줄이며 Pixel, Overdraw와 Shader 연산 자체를 제거하지 않는다.

---

## 전체 구조 다시 연결하기

URP와 HDRP의 차이를 하나의 흐름으로 연결하면 다음과 같다.

```text
Scriptable Render Pipeline Framework
                │
        ┌───────┴────────┐
        │                │
        ▼                ▼
       URP              HDRP
        │                │
넓은 Platform       고성능 Platform
        │                │
확장 가능한 비용     높은 Fidelity
        │                │
2D·일반 3D         고급 Lighting·Material
        │                │
Mobile/Web/XR       Volumetric/Ray Tracing
        │                │
        └───────┬────────┘
                │
                ▼
공통 선택 기준
├─ 필수 Platform
├─ Minimum Hardware
├─ Graphics Feature
├─ Resolution과 Frame Rate
├─ Memory와 GPU Budget
├─ 팀 Workflow
└─ 실제 Device Profiling
```

두 Pipeline의 공통 기반보다 최종 구현의 목표와 Feature 차이가 Project 선택에 더 직접적인 영향을 준다.

---

## 정리

URP와 HDRP는 모두 Unity가 제공하는 SRP 기반의 Prebuilt Render Pipeline이다.

URP는 Mobile, WebGL, Switch, Desktop, Console과 XR을 포함한 폭넓은 Platform과 확장 가능한 성능을 목표로 한다.

HDRP는 고성능 PC와 Console급 Hardware에서 고품질 Lighting, Material, Volumetric와 지원 환경의 Ray Tracing을 구현하는 데 초점을 둔다.

```text
URP
└─ 넓은 Platform + 조절 가능한 Graphics Cost

HDRP
└─ 고성능 Hardware + 높은 Graphics Fidelity
```

URP가 저품질이고 HDRP가 무조건 상위라는 구분은 잘못된 접근이다.

URP도 높은 품질의 PBR Rendering을 구현할 수 있고 HDRP도 올바른 Asset과 Lighting 없이 자동으로 좋은 결과를 만들지 않는다.

두 Pipeline은 Shader Library, LightMode, Material, Camera와 Custom Pass Contract가 달라 서로의 Asset을 그대로 호환하지 않는다.

성능은 Pipeline 이름이 아니라 활성 Feature, Scene, Resolution, Graphics API와 Target Hardware의 조합으로 결정된다.

필수 Platform을 먼저 확정하고 필요한 Graphics Feature, Minimum Hardware, 목표 Frame Rate와 팀 Workflow를 기준으로 Vertical Slice를 측정한 뒤 Pipeline을 선택해야 한다.
