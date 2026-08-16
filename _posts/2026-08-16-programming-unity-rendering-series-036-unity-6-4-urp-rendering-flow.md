---
title: "[Unity 렌더링] 6-4. URP는 어떻게 렌더링할까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - URP
  - Culling
  - RenderPass
permalink: /programming/unity-6-4-urp-rendering-flow/
toc: true
toc_sticky: true
date: 2026-08-16
last_modified_at: 2026-08-16
---

Universal Render Pipeline은 Camera가 보는 Scene을 한 번의 명령으로 그리지 않는다.

Camera와 Pipeline 설정을 수집하고 보이지 않는 대상을 Culling한 뒤, 선택된 Renderer가 필요한 Render Pass를 구성한다.

각 Pass는 Shadow, Depth, Opaque, Skybox, Transparent와 Post-processing 같은 작업을 순서대로 처리한다.

```text
Camera
  │
  ▼
Culling
  │
  ▼
Rendering Data 준비
  │
  ▼
Renderer 선택과 Pass 구성
  │
  ▼
Draw와 Post-processing
  │
  ▼
Final Output
```

Unity 6의 URP는 이 과정을 Render Graph로 기록하고 실행할 수 있다.

전체 흐름을 이해하면 특정 Object가 보이지 않는 이유, 불필요한 Texture가 만들어지는 이유와 Custom Pass가 실행되는 위치를 추적할 수 있다.

---

## URP Rendering의 구성 요소

URP의 Frame Rendering에는 여러 Asset과 Runtime Data가 협력한다.

| 구성 요소 | 역할 |
| --- | --- |
| URP Asset | Lighting, Shadow, Texture와 Quality의 전역 설정 |
| Renderer Data | 사용할 Renderer와 Renderer Feature 설정 |
| Camera | View, Projection, Culling Mask와 Output 설정 |
| Renderer | Camera에 필요한 Render Pass 구성 |
| Render Pass | 특정 Rendering 작업 선언 |
| Render Graph | Pass와 Resource 의존성 기록 및 실행 최적화 |
| Shader | Draw Call 안에서 Vertex와 Fragment 계산 |

```text
URP Asset
└─ Renderer List
   ├─ Universal Renderer Data
   │  └─ Renderer Features
   └─ 2D Renderer Data

Camera
└─ 사용할 Renderer 선택
```

Pipeline Asset 하나만으로 모든 동작이 결정되는 것은 아니다.

Camera, Renderer Data, Volume, Material과 Platform 조건을 함께 봐야 한다.

---

## Frame과 Camera Loop

한 Frame에는 여러 Camera가 존재할 수 있다.

Game Camera뿐 아니라 Scene View, Preview, Reflection과 Render Texture Camera도 Rendering을 요청할 수 있다.

```text
Frame
├─ Camera A Loop
├─ Camera B Loop
├─ Scene View Camera Loop
└─ Preview Camera Loop
```

URP는 Camera마다 Culling하고 필요한 Pass를 구성한다.

Camera가 늘어나면 동일 Scene을 다시 Culling하고 다시 그릴 수 있다.

화면에 Camera 하나만 보인다고 Frame에 Camera Loop가 반드시 하나인 것은 아니다.

---

## URP Camera Loop의 큰 순서

공식 URP 구조를 단순화하면 Camera Loop는 다음 단계로 나뉜다.

```text
1. Culling Parameter 설정
          │
          ▼
2. Culling 실행
          │
          ▼
3. Rendering에 필요한 Data 준비
          │
          ▼
4. Renderer가 Pass 구성
          │
          ▼
5. Pass 실행
          │
          ▼
6. Camera 결과 출력
```

각 단계의 결과가 다음 단계의 입력이 된다.

Culling 결과가 없으면 Renderer는 어떤 Object와 Light가 보이는지 알 수 없다.

Renderer가 Pass를 구성하지 않으면 실제 Draw가 발생하지 않는다.

---

## Active URP Asset

URP Rendering이 시작되려면 Active Render Pipeline이 URP여야 한다.

Unity는 Quality Settings의 Override Asset을 먼저 확인하고, 없으면 Graphics Settings의 Default Asset을 사용한다.

```text
QualitySettings.renderPipeline
        │ null이면
        ▼
GraphicsSettings.defaultRenderPipeline
        │ null이면
        ▼
Built-in Render Pipeline
```

URP Package를 설치했더라도 Active Asset이 없으면 URP Render Loop를 사용하지 않는다.

문제를 진단할 때 Package 설치 여부보다 `GraphicsSettings.currentRenderPipeline`을 먼저 확인하는 이유다.

---

## URP Asset이 결정하는 것

URP Asset은 Rendering의 전역적인 Quality와 Feature 범위를 정의한다.

- Main Light와 Additional Light 설정
- Shadow 지원과 Shadow Distance
- Render Scale과 Upscaling Filter
- HDR과 MSAA
- Depth Texture와 Opaque Texture
- Post-processing LUT Size
- 사용할 Renderer Data 목록

```text
URP Asset
├─ Quality
├─ Lighting
├─ Shadows
├─ Post-processing
└─ Renderer List
```

설정에 따라 필요한 Pass와 Texture가 달라진다.

Depth Texture를 요구하면 Copy Depth 또는 Depth Prepass가 추가될 수 있다.

---

## Renderer Data와 Renderer

Renderer Data는 Project Asset이다.

Runtime에는 이 설정을 바탕으로 Renderer가 생성된다.

```text
UniversalRendererData.asset
├─ Rendering Path
├─ Depth Priming
├─ Intermediate Texture
├─ Native Render Pass
└─ Renderer Features
        │
        ▼
UniversalRenderer Instance
```

Asset은 설정을 저장한다.

Renderer Instance는 Camera별로 어떤 Pass가 필요한지 판단하고 Rendering을 구성한다.

두 대상을 같은 것으로 이해하면 설정 Data와 Runtime 동작을 구분하기 어렵다.

---

## Camera가 Renderer를 선택하는 방식

URP Asset은 여러 Renderer Data를 보관할 수 있다.

Camera는 목록 중 하나를 선택하거나 Default Renderer를 사용한다.

```text
URP Asset
├─ Renderer 0: Universal Renderer
├─ Renderer 1: 2D Renderer
└─ Renderer 2: 특수 Camera용 Renderer

Camera A → Renderer 0
Camera B → Renderer 2
```

같은 Scene에서도 Camera마다 다른 Renderer 설정을 사용할 수 있다.

특정 Camera에서만 Renderer Feature가 보이지 않는다면 Camera의 Renderer 선택을 확인해야 한다.

---

## Universal Renderer와 2D Renderer

URP에는 목적이 다른 Renderer가 있다.

```text
Universal Renderer
├─ 일반 3D Rendering
├─ Forward 계열 Path
├─ Deferred 계열 Path
└─ Renderer Feature 확장

2D Renderer
├─ Sprite Rendering
├─ 2D Light
├─ 2D Shadow
└─ 2D 전용 Pass
```

Renderer가 다르면 Frame을 구성하는 Pass도 달라진다.

이번 글은 일반적인 3D Universal Renderer 흐름을 중심으로 설명한다.

---

## Camera Data 준비

URP는 Camera Component만 읽지 않는다.

Camera 설정, Universal Additional Camera Data, URP Asset과 Platform 정보를 조합해 Camera Rendering에 필요한 Data를 만든다.

```text
Camera Component
+ Universal Additional Camera Data
+ URP Asset
+ Renderer Data
+ Platform Capability
+ XR 상태
          │
          ▼
Camera별 Rendering 설정
```

여기에는 HDR, Post-processing, Render Scale, Antialiasing, Camera Stack과 Output 정보가 포함될 수 있다.

동일한 Camera Component 값이라도 Quality Level과 Active URP Asset이 바뀌면 실제 Rendering이 달라질 수 있다.

---

## Culling Parameter 설정

Culling은 Camera에 보이지 않는 Object와 Light를 Rendering 후보에서 제외하는 과정이다.

먼저 Camera를 기준으로 Culling Parameter를 만든다.

```text
Culling Parameter
├─ Camera Frustum
├─ Culling Mask
├─ Layer Cull Distance
├─ Shadow Distance
├─ Occlusion Culling Option
└─ Stereo 관련 설정
```

URP는 Pipeline과 Renderer 요구에 맞춰 Parameter를 조정할 수 있다.

Shadow Distance는 Camera Far Clip보다 짧을 수 있다.

보이는 Object와 Shadow를 만드는 Object의 최대 범위가 항상 같을 필요는 없다.

---

## Frustum Culling

Camera의 View Frustum 밖에 있는 Object는 일반적으로 화면에 그릴 필요가 없다.

```text
          Far Plane
        /-----------\
       /   visible   \
Camera                 
       \              /
        \------------/
          Near Plane

Frustum 밖 Renderer → 제외 후보
```

Renderer의 Bounding Volume이 Frustum과 겹치는지 검사한다.

Mesh의 모든 Vertex를 하나씩 검사하는 방식이 아니다.

Bounding Box가 지나치게 크면 실제 Mesh가 보이지 않아도 Culling되지 않을 수 있다.

---

## Layer와 Culling Mask

Camera의 Culling Mask는 어떤 Layer를 Rendering할지 결정한다.

```text
Camera Culling Mask
├─ World: On
├─ Character: On
├─ UIWorld: On
└─ DebugOnly: Off
```

Object가 Frustum 안에 있어도 Layer가 Mask에서 제외되면 보이지 않는다.

Renderer Feature의 Filtering Layer와 Camera Culling Mask는 서로 다른 단계에서 함께 영향을 줄 수 있다.

특정 Object가 누락되면 GameObject Layer, Camera Mask와 Custom Pass Filter를 모두 확인해야 한다.

---

## Occlusion Culling

다른 Geometry에 완전히 가려진 Object도 Rendering 후보에서 제외할 수 있다.

```text
Camera → Wall → Hidden Object
                  │
                  └─ Occlusion 결과에 따라 제외
```

Frustum 안에 있다는 사실만으로 화면에 보이는 것은 아니다.

Occlusion Culling은 Scene Bake Data, Camera 설정과 Runtime 조건에 영향을 받는다.

작은 Object가 너무 많거나 Scene이 동적으로 크게 변하면 이득과 CPU 비용을 함께 측정해야 한다.

---

## CullingResults

Culling 결과는 이후 Rendering 단계의 핵심 입력이다.

```text
CullingResults
├─ Visible Renderer
├─ Visible Light
├─ Reflection Probe 관련 정보
└─ Shadow Caster 계산에 필요한 정보
```

Renderer는 이 결과를 바탕으로 Shadow, Opaque와 Transparent Draw 대상을 선별한다.

Culling된 Object는 뒤의 Pass가 다시 살려서 그리는 일반적인 후보가 아니다.

Custom Pass에서 특별한 대상을 그리고 싶다면 Camera Culling과 별도의 Drawing 방식이 필요한지 설계해야 한다.

---

## Culling은 Draw Call과 같지 않다

Culling은 보일 가능성이 있는 후보를 계산한다.

실제 GPU Drawing은 뒤의 Render Pass에서 일어난다.

```text
Scene Renderer 10,000개
        │ Culling
        ▼
Visible Renderer 1,000개
        │ Filtering / Sorting / Batching
        ▼
GPU Draw Command
```

Visible Renderer 수와 Draw Call 수는 같지 않다.

Batching, Instancing, Shader Pass와 Light 조건에 따라 Draw Command 수가 달라진다.

---

## Rendering Data 구성

Culling 이후 URP는 Camera를 Rendering하는 데 필요한 정보를 정리한다.

과거 URP 문서에서는 이를 `RenderingData` 중심으로 설명했다.

Unity 6의 Render Graph Workflow에서는 Frame Context 안의 여러 Data Container로 접근하는 구조도 사용한다.

```text
Frame Data
├─ UniversalCameraData
├─ UniversalRenderingData
├─ UniversalLightData
└─ UniversalResourceData
```

API의 구체적인 Type과 접근 방식은 Render Graph인지 Compatibility Mode인지에 따라 달라질 수 있다.

개념적으로는 Camera, Culling, Light, Resource와 Platform 정보를 Pass가 사용할 수 있게 정리하는 단계다.

---

## Renderer가 하는 일

Renderer는 Culling 결과를 직접 Pixel Color로 바꾸는 단일 Shader가 아니다.

Camera에 필요한 여러 Pass를 선택하고 순서에 배치하는 Orchestrator에 가깝다.

```text
Renderer
├─ Camera와 Pipeline 설정 확인
├─ 필요한 Resource 판단
├─ Built-in Pass 구성
├─ Renderer Feature Pass 추가
├─ Pass 순서 정리
└─ Pass 기록과 실행 요청
```

Rendering Path, Shadow, Camera Texture, Post-processing과 Custom Feature에 따라 Pass 목록이 바뀐다.

같은 Renderer라도 Camera마다 완전히 같은 Pass를 실행한다고 단정할 수 없다.

---

## Render Pass란?

Render Pass는 Frame 안의 특정 Rendering 작업 단위다.

```text
Render Pass 예
├─ Main Light Shadow
├─ Additional Light Shadow
├─ Depth Prepass
├─ Draw Opaque
├─ Draw Skybox
├─ Copy Color
├─ Draw Transparent
├─ Post-processing
└─ Final Blit
```

Pass는 Input Resource를 읽고 Output Resource를 쓸 수 있다.

Object를 그리는 Raster Pass일 수도 있고 Compute Shader를 실행하는 Compute Pass일 수도 있다.

단순한 이름보다 어떤 Resource를 읽고 쓰는지가 중요하다.

---

## ScriptableRenderPass

URP의 Custom Rendering 작업은 일반적으로 `ScriptableRenderPass`를 상속한 Class로 표현한다.

Unity 6 Render Graph 경로에서는 `RecordRenderGraph()`에서 Pass와 Resource 사용을 기록한다.

```csharp
using UnityEngine.Rendering;
using UnityEngine.Rendering.RenderGraphModule;
using UnityEngine.Rendering.Universal;

public sealed class ExamplePass : ScriptableRenderPass
{
    public override void RecordRenderGraph(
        RenderGraph renderGraph,
        ContextContainer frameData)
    {
        // Pass와 Resource 의존성을 Render Graph에 기록한다.
    }
}
```

Compatibility Mode에서는 `Execute()` 중심의 이전 API를 사용한다.

새 Graphics Feature는 Render Graph API로 작성하는 것이 Unity 6의 방향이다.

---

## Renderer Feature

`ScriptableRendererFeature`는 Custom Pass를 만들고 Renderer에 추가하는 설정과 수명 관리 계층이다.

```text
ScriptableRendererFeature
├─ Create()
│  └─ Custom Pass 생성
│
└─ AddRenderPasses()
   └─ 조건에 맞을 때 Pass Enqueue
```

```csharp
public override void AddRenderPasses(
    ScriptableRenderer renderer,
    ref RenderingData renderingData)
{
    renderer.EnqueuePass(examplePass);
}
```

이 Signature는 Renderer Feature의 Pass Enqueue 구조를 보여 준다.

실제 Resource 접근은 Unity Version과 Render Graph Workflow에 맞춰 구현해야 한다.

---

## RenderPassEvent

Custom Pass는 실행할 대략적인 위치를 `RenderPassEvent`로 지정할 수 있다.

```text
BeforeRendering
    │
BeforeRenderingShadows
    │
BeforeRenderingPrePasses
    │
BeforeRenderingOpaques
    │
AfterRenderingOpaques
    │
AfterRenderingSkybox
    │
BeforeRenderingTransparents
    │
AfterRenderingTransparents
    │
BeforeRenderingPostProcessing
    │
AfterRenderingPostProcessing
    │
AfterRendering
```

필요한 Input이 준비된 이후와 Output이 소비되기 이전을 선택해야 한다.

Event 이름만 보고 Color나 Depth Texture가 항상 존재한다고 가정하면 안 된다.

---

## Pass Queue와 실제 실행 순서

Renderer는 Built-in Pass와 Custom Pass를 모아 Event 순서에 맞게 구성한다.

```text
Built-in Shadow Pass
+ Custom Outline Pass
+ Built-in Opaque Pass
+ Custom Distortion Pass
+ Post-processing Pass
          │
          ▼
정렬된 Camera Pass 목록
```

같은 Event에 여러 Pass가 있으면 등록 순서와 Pipeline 구현이 영향을 줄 수 있다.

Custom Feature 사이에 암묵적인 순서 의존성을 만들면 유지보수가 어려워진다.

가능하면 Resource Input과 Output 관계를 명확히 선언해야 한다.

---

## Unity 6의 Render Graph

Render Graph는 Pass와 Resource 사용 관계를 선언하는 System이다.

```text
Pass A
└─ writes Texture X

Pass B
├─ reads Texture X
└─ writes Texture Y

Pass C
└─ reads Texture Y
```

Graph는 실행 전에 전체 의존성을 볼 수 있다.

사용되지 않는 결과를 만드는 Pass를 제거하고 Temporary Resource의 수명을 관리할 수 있다.

Hardware와 조건에 따라 Pass를 더 효율적으로 구성할 기반도 제공한다.

---

## Render Graph가 필요한 이유

전통적인 즉시식 Render Code는 각 Pass가 Resource를 직접 만들고 해제하기 쉽다.

전체 Frame 관점에서 Texture가 언제까지 필요한지 파악하기 어렵다.

```text
수동 Resource 관리
Pass A: Texture 생성
Pass B: Texture 사용
Pass C: 실제로는 불필요
Frame 끝: Texture 해제

Render Graph
Pass와 사용 관계를 먼저 선언
→ 실제 필요한 Pass와 수명 계산
```

Graph는 개발자가 올바른 Resource 의존성을 선언했을 때 효과적으로 동작한다.

외부 Side Effect를 숨기거나 Input 선언을 빠뜨리면 최적화와 결과가 예상과 달라질 수 있다.

---

## Render Graph Pass Culling

어떤 Pass의 Output이 이후에 사용되지 않고 외부 Side Effect도 없다면 Graph가 Pass를 제거할 수 있다.

```text
Pass A → Texture X → Pass B → Final Color

Pass C → Texture Z → 사용되지 않음
                      │
                      └─ Culling 후보
```

여기서 Pass Culling은 Camera의 Object Culling과 다른 개념이다.

```text
Camera Culling
└─ 보이지 않는 Renderer와 Light 제외

Render Graph Pass Culling
└─ 최종 결과에 기여하지 않는 Pass 제외
```

같은 단어가 서로 다른 계층에서 사용되므로 구분해야 한다.

---

## Resource Lifetime

Render Graph Texture는 필요한 구간만 살아 있도록 관리할 수 있다.

```text
Frame Timeline

Pass A   Pass B   Pass C   Pass D
  │        │        │        │
  └─ Texture X ─────┘
           └─ Texture Y ─────┘
```

수명이 겹치지 않는 Resource는 내부 Memory를 재사용할 가능성이 생긴다.

이는 Peak Memory와 Allocation 관리에 도움을 줄 수 있다.

개발자가 Texture Handle을 Frame 밖에 무조건 보관하면 Graph의 수명 규칙과 충돌할 수 있다.

---

## Compatibility Mode

Unity 6은 이전 URP Custom Pass를 위한 Compatibility Mode를 제공한다.

Project Settings에서 Render Graph를 비활성화하면 이전 방식의 `Execute()` API를 사용할 수 있다.

```text
Render Graph Mode
└─ RecordRenderGraph() 중심

Compatibility Mode
└─ Execute() 중심의 이전 API
```

Compatibility Mode는 기존 Project Migration을 돕는다.

Unity는 Render Graph를 사용하지 않는 경로를 더 이상 발전시키지 않는다고 안내한다.

새 Feature는 Render Graph 방식으로 설계하는 편이 장기적으로 적합하다.

---

## Shadow Pass

Shadow를 사용하는 Light가 있고 Pipeline 설정이 허용하면 Shadow Map을 만드는 Pass가 필요하다.

```text
Light View
  │
  ▼
Shadow Caster Culling
  │
  ▼
Shadow Atlas에 Depth Rendering
  │
  ▼
Opaque Lighting에서 Shadow Sampling
```

Main Light와 Additional Light Shadow는 서로 다른 Atlas와 Pass를 사용할 수 있다.

Shadow Pass에서는 Camera Color를 그리는 것이 아니라 Light 관점의 Depth를 기록한다.

Shadow Distance, Cascade, Atlas Resolution과 Caster 수가 비용을 결정한다.

---

## Depth Prepass

일부 조건에서는 Opaque Color보다 먼저 Scene Depth를 그린다.

```text
Depth Prepass
└─ Depth만 기록
      │
      ▼
Opaque Pass
└─ Color와 Lighting 기록
```

Depth Texture가 필요한 Effect, Rendering Path, Platform과 Renderer 설정에 따라 Prepass가 선택될 수 있다.

Depth Prepass는 Geometry를 한 번 더 처리하지만 Early Depth Test와 필요한 Depth Data를 제공한다.

항상 이득이거나 항상 손해라고 단정할 수 없다.

Frame Debugger에서 실제 생성 여부를 확인해야 한다.

---

## DepthNormals Prepass

일부 Effect는 Depth뿐 아니라 Normal Texture도 요구한다.

예를 들어 Screen Space Ambient Occlusion이나 Custom Edge Effect가 Normal을 사용할 수 있다.

```text
DepthNormals Pass
├─ Depth 기록
└─ View 또는 World Normal Encoding
        │
        ▼
SSAO / Outline / Custom Effect
```

Renderer Feature가 `ConfigureInput()` 또는 Render Graph Resource 접근으로 요구 사항을 선언하면 URP가 필요한 준비 Pass를 결정할 수 있다.

불필요한 Normal Input을 요청하면 추가 Pass와 Texture 비용이 생길 수 있다.

---

## Opaque Draw

Opaque Pass는 Culling 결과 중 불투명 Queue 범위의 Renderer를 그린다.

```text
CullingResults
  │
  ├─ Render Queue: Opaque
  ├─ Layer Mask
  ├─ Shader Pass Tag
  └─ Sorting: Opaque 기준
  │
  ▼
Opaque Renderer List
  │
  ▼
Draw
```

Pipeline은 Shader에서 URP가 이해하는 `LightMode` Pass를 찾는다.

대표적으로 Forward 계열과 Depth, Shadow Caster용 Pass가 서로 다른 역할을 가진다.

Material에 대응 Pass가 없으면 특정 단계에서 그려지지 않을 수 있다.

---

## RendererList

Unity 6 Render Graph에서는 조건에 맞는 Renderer 묶음을 `RendererList`로 표현해 Raster Pass에서 그릴 수 있다.

```text
RendererList Parameter
├─ CullingResults
├─ ShaderTagId
├─ Render Queue Range
├─ Sorting Criteria
├─ Layer Mask
└─ Render State
```

Render Graph Pass는 사용할 RendererList를 선언한다.

실행 함수에서 Context가 해당 List를 Drawing한다.

Object 하나마다 C#에서 직접 `DrawMesh`를 반복하는 것과 다른 구조다.

---

## Shader Pass 선택

URP Renderer는 ShaderLab의 `LightMode` Tag로 목적에 맞는 Pass를 선택한다.

```shaderlab
Pass
{
    Tags
    {
        "LightMode" = "UniversalForward"
    }

    HLSLPROGRAM
    // URP Forward용 Shader Program
    ENDHLSL
}
```

```text
Renderer의 ShaderTagId
          │
          ▼
Shader Pass의 LightMode
          │
          ▼
일치하는 Pass Draw
```

Built-in용 `ForwardBase` Pass만 가진 Shader가 URP에서 정상 Lighting되지 않는 이유 중 하나다.

---

## Draw Call 생성

RendererList가 GPU Command 하나와 항상 일대일 대응하는 것은 아니다.

Material, Shader Variant, Mesh, Pass와 Batching 조건에 따라 여러 Draw가 생성된다.

```text
Visible Opaque Renderer
        │
        ├─ Sorting
        ├─ SRP Batcher 호환성
        ├─ GPU Instancing
        ├─ Shader Variant
        └─ Render State
        │
        ▼
GPU Draw Command
```

Frame Debugger에서 각 Draw의 Shader, Pass, Mesh와 Batch 원인을 확인할 수 있다.

Scene Renderer 수만으로 실제 Render Thread 비용을 예측하면 안 된다.

---

## SRP Batcher

URP Shader가 SRP Batcher 규칙을 만족하면 Material Data Binding의 CPU 비용을 줄일 수 있다.

```text
같은 Shader Variant
├─ Material A Data
├─ Material B Data
└─ Material C Data
        │
        ▼
효율적인 Buffer Binding
```

SRP Batcher는 Object를 하나의 Draw Call로 자동 합치는 기능과 같지 않다.

GPU Pixel 연산, Overdraw와 Texture Sampling 비용도 줄이지 않는다.

CPU Rendering 병목을 진단한 뒤 효과를 측정해야 한다.

---

## Skybox Draw

일반적인 3D Camera에서는 Opaque 뒤에 Skybox를 그릴 수 있다.

```text
Opaque
  │
  ▼
Skybox
  │
  ▼
Transparent
```

Opaque가 이미 Depth를 기록한 Pixel에서는 Skybox가 가려진다.

Camera의 Background Type과 Clear 설정에 따라 Skybox 또는 Solid Color 동작이 달라진다.

Skybox Shader도 하나의 Rendering 작업이며 Reflection 환경과 화면 Background의 역할을 구분해야 한다.

---

## Opaque Texture Copy

URP의 Opaque Texture가 필요하면 Opaque Rendering 결과를 별도 Texture로 Copy하거나 Downsample할 수 있다.

```text
Opaque Color Target
        │ Copy / Downsample
        ▼
_CameraOpaqueTexture
        │
        ├─ Refraction
        ├─ Distortion
        └─ Custom Shader
```

Transparent Shader는 이 Texture를 읽어 뒤의 불투명 화면을 왜곡할 수 있다.

Copy는 Memory와 Bandwidth 비용을 만든다.

사용하지 않는다면 URP Asset과 Camera의 요구 설정을 끄는 것이 좋다.

---

## Depth Texture Copy

Depth Texture는 Prepass에서 직접 만들거나 적절한 시점에 Camera Depth를 Copy해 얻을 수 있다.

```text
방법 A
Depth Prepass → Camera Depth Texture

방법 B
Opaque Depth → Copy Depth → Camera Depth Texture
```

어떤 경로가 사용되는지는 Rendering Path, MSAA, Platform, Copy 가능 여부와 Custom Pass 요구에 따라 달라진다.

Depth Texture가 필요하다는 설정 하나만 보고 항상 Depth Prepass가 실행된다고 단정하면 안 된다.

Frame Debugger에서 실제 Pass를 확인한다.

---

## Transparent Draw

Transparent Object는 일반적으로 Opaque와 Skybox 뒤에 그린다.

```text
Transparent Filtering
├─ Render Queue: Transparent
├─ Camera Distance Sorting
├─ Layer Mask
└─ URP Shader Pass
```

Blend는 이미 Color Target에 있는 값과 현재 Fragment를 결합한다.

그래서 뒤에서 앞으로 정렬하는 것이 일반적이다.

서로 교차하는 투명 Mesh는 Object 단위 정렬만으로 완벽하게 해결되지 않을 수 있다.

Transparent는 Overdraw와 Shader 비용을 함께 관리해야 한다.

---

## Opaque와 Transparent의 차이

| 항목 | Opaque | Transparent |
| --- | --- | --- |
| Queue 범위 | 일반적으로 2500 이하 | 일반적으로 2501 이상 |
| Depth Write | 보통 사용 | 보통 사용하지 않음 |
| Sorting | State와 Front-to-back 중심 | Back-to-front 중심 |
| Blend | 보통 Off | 보통 On |
| 주요 문제 | State 변경과 Fragment 비용 | 정렬, Overdraw와 Blend 비용 |

URP는 각 범위를 별도 Pass로 그릴 수 있다.

Custom Shader의 Queue와 ZWrite를 잘못 설정하면 예상 순서와 Depth 결과가 달라진다.

---

## Post-processing 단계

Camera에서 Post-processing이 활성화되고 Volume Effect가 존재하면 화면 효과 Pass가 구성된다.

```text
Rendered Camera Color
        │
        ├─ Bloom
        ├─ Depth of Field
        ├─ Color Adjustments
        ├─ Tone Mapping
        ├─ Vignette
        └─ Film Grain
        │
        ▼
Post-processed Color
```

모든 Effect가 반드시 별도 Full-screen Pass 하나씩 되는 것은 아니다.

URP Version과 설정에 따라 일부 작업을 결합하거나 다른 Resource를 사용할 수 있다.

실제 Pass 수는 Frame Debugger와 Render Graph Viewer에서 확인한다.

---

## Volume Stack

URP는 Camera 위치와 Volume Layer Mask를 기준으로 Volume Profile을 Blend한다.

```text
Global Volume
        +
Local Volume A × Weight
        +
Local Volume B × Weight
        │
        ▼
Camera Volume Stack
```

Volume Stack은 현재 Camera에 적용할 Effect Parameter 결과다.

Volume Component가 존재해도 Override State가 꺼져 있으면 해당 값이 적용되지 않을 수 있다.

여러 Camera는 서로 다른 Volume Mask와 Trigger를 사용할 수 있다.

---

## Tone Mapping과 Final Color

HDR Rendering을 사용하면 Lighting과 Effect는 1보다 큰 Color 값을 가질 수 있다.

Tone Mapping은 넓은 밝기 범위를 Display 가능한 범위에 매핑한다.

```text
HDR Scene Color
        │
        ├─ Exposure
        ├─ Bloom
        ├─ Color Grading
        └─ Tone Mapping
        │
        ▼
Display용 Color
```

최종 Output이 SDR인지 HDR Display인지에 따라 처리 경로가 달라질 수 있다.

Color Space와 Output 설정도 최종 화면에 영향을 준다.

---

## Final Blit과 Output

Camera가 중간 Color Texture에 Rendering했다면 최종 Target으로 결과를 옮기는 단계가 필요할 수 있다.

```text
Intermediate Camera Color
        │
        ├─ Upscaling
        ├─ Final Post-processing
        ├─ Viewport 적용
        └─ Color Conversion
        │
        ▼
Backbuffer 또는 Render Texture
```

조건에 따라 중간 Texture 없이 Target에 직접 Rendering할 수도 있다.

Renderer Feature가 Camera Color를 요구하거나 Post-processing, Render Scale과 Camera Stack을 사용하면 Intermediate Texture가 필요해질 수 있다.

불필요한 Final Copy는 Bandwidth 비용이므로 실제 경로를 확인해야 한다.

---

## Camera Stack

Universal Renderer는 Base Camera와 Overlay Camera를 Stack으로 구성할 수 있다.

```text
Base Camera
├─ World Rendering
├─ Color와 Depth 생성
│
├─ Overlay Camera A
│  └─ Weapon
│
└─ Overlay Camera B
   └─ UI
        │
        ▼
Stack Final Output
```

각 Camera는 Culling과 Rendering Loop를 수행할 수 있다.

같은 Overlay Camera를 여러 Stack에 넣으면 작업이 반복될 수 있다.

Camera Stack은 편리하지만 Camera 수와 Overdraw 비용을 함께 봐야 한다.

---

## Base Camera와 Overlay Camera

Base Camera는 독립적인 Camera 결과를 시작한다.

Overlay Camera는 Base가 만든 Target 위에 추가로 그린다.

| 항목 | Base | Overlay |
| --- | --- | --- |
| 독립 Output 시작 | 가능 | Base Stack에 의존 |
| Background 처리 | Background Type 사용 | 제한된 Clear 동작 |
| Stack 소유 | Overlay 목록 보유 | Stack의 구성원 |
| 최종 Post-processing | Stack 설정에 영향 | Base와 조합 고려 |

Camera Stack에서 Depth Clear와 Post-processing 위치를 잘못 이해하면 Object가 사라지거나 Effect가 중복될 수 있다.

---

## 여러 Camera의 Rendering 순서

URP는 먼저 활성 Base Camera를 수집한다.

Render Texture에 그리는 Camera와 화면에 그리는 Camera를 구분하고 Priority에 따라 처리한다.

```text
Frame Camera 순서 개념
├─ Render Texture Base Cameras
│  └─ 각 Camera Stack
│
└─ Screen Base Cameras
   └─ 각 Camera Stack
```

Priority가 높은 Camera는 같은 그룹에서 나중에 Rendering된다.

Camera가 같은 Target의 같은 Pixel을 반복해서 덮으면 Overdraw와 전체 Camera Loop 비용이 증가한다.

---

## Forward와 Deferred가 흐름에 미치는 영향

Universal Renderer의 Rendering Path에 따라 Geometry와 Lighting Pass 구성이 달라진다.

```text
Forward 계열
Geometry Draw 안에서 Lighting 계산

Deferred 계열
Geometry Data를 G-buffer에 기록
→ Lighting Pass에서 계산
```

하지만 Culling, Renderer 선택, Pass 구성과 Final Output이라는 큰 Camera Loop는 공통적으로 이해할 수 있다.

Forward와 Deferred의 구체적인 Light 처리와 장단점은 이어지는 글에서 각각 분리한다.

---

## Renderer Feature가 추가하는 비용

Renderer Feature는 Pipeline에 새로운 Pass와 Resource 요구를 추가할 수 있다.

```text
Outline Feature
├─ DepthNormals Input 요청
├─ Mask Pass
├─ Full-screen Edge Pass
└─ Camera Color Write
```

Inspector에서 Component 하나를 추가한 것처럼 보여도 실제로는 Prepass, Texture와 Full-screen Draw가 늘 수 있다.

Feature가 비활성화된 Camera에서도 Pass를 Enqueue하는지 확인한다.

`AddRenderPasses()`의 조건과 Render Graph Viewer 결과를 함께 점검해야 한다.

---

## Custom Pass의 Input 선언

Custom Pass가 Color, Depth, Normal 또는 Motion Data를 읽는다면 이를 명확히 선언해야 한다.

```text
Custom Pass
├─ Read: Camera Depth
├─ Read: Camera Normal
└─ Write: Camera Color
```

URP는 요구 사항을 보고 필요한 Resource 준비 방식을 선택한다.

필요하지 않은 Input까지 요청하면 추가 Texture와 Pass가 생길 수 있다.

반대로 실제로 읽으면서 선언하지 않으면 Render Graph가 올바른 의존성을 알 수 없다.

---

## Pass 안에서 Submit을 호출하지 않는 이유

Custom SRP에서는 Pipeline 작성자가 `ScriptableRenderContext.Submit()`을 직접 호출했다.

URP의 Custom Pass는 URP가 소유한 전체 Render Loop 안에 들어간다.

```text
URP Pipeline
├─ Pass A
├─ Custom Pass
├─ Pass B
└─ Pipeline이 적절한 시점에 제출
```

Custom Pass가 임의로 Submit하면 Pipeline의 Command Scheduling을 깨뜨릴 수 있다.

Unity 문서는 URP가 제공한 Command Buffer에서 Custom Pass가 `Submit`을 호출하지 않도록 안내한다.

---

## Rendering 순서는 고정 목록이 아니다

URP Frame을 항상 동일한 Pass 목록으로 외우면 실제 Frame과 맞지 않을 수 있다.

```text
Pass를 바꾸는 조건
├─ Rendering Path
├─ Shadow 설정
├─ Depth / Opaque Texture
├─ MSAA
├─ Renderer Feature
├─ Post-processing
├─ Camera Stack
├─ XR
└─ Platform Capability
```

개념적 순서는 Debug의 출발점이다.

정확한 실행 목록은 해당 Camera의 Render Graph Viewer와 Frame Debugger에서 확인한다.

---

## 일반적인 Universal Renderer 흐름

조건에 따라 달라질 수 있는 점을 전제로 큰 순서를 연결하면 다음과 같다.

```text
Camera Setup
    │
    ▼
Culling
    │
    ▼
Shadow Passes
    │
    ▼
Depth / DepthNormals Prepass (필요 시)
    │
    ▼
Opaque Draw
    │
    ▼
Skybox
    │
    ├─ Opaque Color Copy (필요 시)
    ├─ Depth Copy (필요 시)
    ▼
Transparent Draw
    │
    ▼
Post-processing
    │
    ▼
Final Blit / Output
```

Custom Pass는 지정한 Injection Point와 Resource 의존성에 따라 이 사이에 배치된다.

---

## Frame Debugger로 흐름 확인하기

Frame Debugger는 실제 실행된 Rendering Event와 Draw Call을 순서대로 보여 준다.

확인할 항목은 다음과 같다.

- Camera와 Camera Stack 순서
- Shadow Map Pass
- Depth 또는 DepthNormals Prepass
- Opaque와 Transparent Draw
- Shader Pass와 LightMode
- Color·Depth Copy
- Renderer Feature Pass
- Post-processing과 Final Blit

```text
예상
Opaque → Skybox → Transparent → Post

실제
DepthNormals → Opaque → CopyColor
→ CustomPass → Transparent → Post → FinalBlit
```

예상과 실제의 차이가 추가 비용 또는 화면 문제의 원인이 될 수 있다.

---

## Render Graph Viewer

Unity 6의 Render Graph Viewer는 현재 Camera의 Graph를 분석하는 도구다.

```text
Viewer에서 확인할 내용
├─ Raster Pass
├─ Compute Pass
├─ Unsafe Pass
├─ Culled Pass
├─ Texture Input / Output
├─ Resource Lifetime
└─ Native Render Pass 정보
```

Pass를 선택하면 읽고 쓰는 Texture와 다른 Pass의 의존성을 확인할 수 있다.

Custom Pass가 제거되었다면 Output이 최종 결과에 연결되어 있는지 점검한다.

불필요하게 긴 Texture Lifetime도 찾을 수 있다.

---

## Profiler에서 확인할 흐름

Frame Debugger는 순서를 보여 주지만 모든 성능 비용을 정확히 나타내는 것은 아니다.

CPU와 GPU Profiler를 함께 사용한다.

```text
CPU
├─ Camera Setup
├─ Culling
├─ Renderer와 Pass 준비
├─ Draw Command 제출
└─ Render Thread

GPU
├─ Shadow
├─ Depth
├─ Opaque Lighting
├─ Transparent
├─ Post-processing
└─ Copy / Resolve
```

Target Device의 GPU Capture 도구로 Render Target, Bandwidth와 Shader 비용을 더 자세히 확인할 수 있다.

---

## Object가 보이지 않을 때

URP의 단계 순서에 맞춰 원인을 좁힐 수 있다.

```text
1. Camera Frustum 안인가?
2. Camera Culling Mask에 Layer가 포함되는가?
3. Occlusion Culling에 제외되지 않았는가?
4. Material Render Queue가 Pass 범위와 맞는가?
5. Shader에 URP용 LightMode Pass가 있는가?
6. Renderer Feature Filter가 제외하지 않는가?
7. Depth Test에 가려지지 않는가?
8. 최종 Camera Stack과 Output이 맞는가?
```

Pink Material이면 Shader 호환성과 Compile Error부터 확인한다.

Draw Event 자체가 없다면 Culling, Filtering과 Shader Pass 선택을 우선 확인한다.

---

## Depth Texture가 없을 때

Custom Effect에서 Depth가 비어 있다면 다음 항목을 확인한다.

- URP Asset 또는 Camera에서 Depth Texture를 허용했는가?
- Pass가 Depth Input을 선언했는가?
- Pass Event 시점에 Depth가 준비되었는가?
- 올바른 Frame Resource Handle을 읽는가?
- Camera Stack과 XR에서 같은 경로를 사용하는가?

```text
Depth 필요 선언
        │
        ▼
URP가 준비 방식 결정
├─ Depth Prepass
└─ Copy Depth
        │
        ▼
Custom Pass가 읽기
```

강제로 Texture를 Copy하기 전에 Pipeline이 제공하는 Camera Depth Resource를 올바르게 요청했는지 확인한다.

---

## Post-processing이 보이지 않을 때

다음 설정이 함께 맞아야 한다.

- Camera의 Post Processing 활성화
- Camera Volume Layer Mask
- 올바른 Volume Trigger
- Volume Profile의 Override
- Effect의 `active` 상태와 Parameter Override State
- Renderer와 Platform의 Feature 지원

```text
Volume 존재
≠ Camera에 Effect 적용
```

Local Volume이면 Camera 또는 Trigger 위치와 Blend Distance를 확인한다.

Scene View와 Game Camera의 Volume Mask가 다를 수도 있다.

---

## 불필요한 Copy Pass 찾기

Color와 Depth Copy는 Bandwidth를 사용한다.

다음 요구가 Copy를 만들 수 있다.

- Opaque Texture
- Depth Texture
- Post-processing
- Camera Stack
- Render Scale
- Renderer Feature의 Camera Color·Depth Input
- Intermediate Texture 설정

```text
Feature A가 Color 필요
        │
        ▼
Intermediate Color 생성
        │
        ▼
Final Blit 추가
```

Feature를 비활성화한 전후의 Frame Debugger와 Render Graph를 비교하면 원인을 찾기 쉽다.

---

## Camera 수 최적화

Camera마다 Culling과 Render Pass가 반복될 수 있다.

```text
Camera 1
├─ Cull
├─ Opaque
└─ Transparent

Camera 2
├─ Cull
├─ Opaque
└─ Transparent
```

Layer를 나눠 Camera를 추가하는 방식이 항상 가장 저렴하지는 않다.

Renderer Feature, Sorting Layer, Stencil 또는 Shader 방식으로 해결할 수 있는지 비교한다.

Camera Stack의 Overdraw와 Post-processing 중복도 확인한다.

---

## Culling 최적화

Culling 성능과 결과에는 Scene Structure가 영향을 준다.

- 합리적인 Renderer Bounds
- 적절한 Camera Far Clip
- 필요한 Layer만 포함한 Culling Mask
- 적절한 Shadow Distance
- Scene에 맞는 Occlusion Culling
- 불필요한 Camera 제거

```text
너무 큰 Bounds
→ Frustum에 계속 걸림
→ 실제로 안 보여도 Visible 후보 유지
```

CPU Culling 시간을 줄였더라도 GPU Draw가 병목이면 Frame Rate 변화가 작을 수 있다.

Profiler로 단계별 비용을 확인한다.

---

## Render Pass 최적화

Pass 하나는 단순한 함수 호출 이상의 비용을 만들 수 있다.

- Render Target Read·Write
- Texture Allocation
- Clear
- Renderer Draw
- Full-screen Fragment
- Compute Dispatch
- Resource Barrier와 State 변경

```text
Pass 제거 효과 후보
├─ Draw 감소
├─ Bandwidth 감소
├─ Temporary Memory 감소
└─ State 전환 감소
```

화면에 기여하지 않는 Custom Pass가 Render Graph에서 Culling 가능한 구조인지 확인한다.

모든 Pass에 `AllowPassCulling(false)`를 지정하면 최적화 기회를 잃을 수 있다.

---

## Texture Input 최소화

Custom Feature가 실제로 필요한 Input만 선언한다.

```text
Color만 필요한 Effect
Read: Camera Color

잘못된 과잉 요구
Read: Color + Depth + Normal + Motion
```

Depth, Normal과 Motion Input은 준비 Pass와 Texture를 추가할 수 있다.

Inspector Option을 끄는 것뿐 아니라 Code의 Input 선언도 확인해야 한다.

여러 Effect가 같은 Input을 공유할 때 Resource가 재사용되는지도 Graph에서 확인한다.

---

## Post-processing 최적화

Full-screen Effect 비용은 대체로 Pixel 수에 민감하다.

```text
Cost 후보
≈ Resolution
× Sample 수
× Pass 수
× Shader 복잡도
```

Mobile에서는 Bloom, Depth of Field와 고품질 Sampling을 실제 Device에서 측정한다.

Render Scale과 Downsampling은 비용을 줄일 수 있지만 화질 Trade-off가 있다.

Volume에 등록되어 있어도 실제로 비활성인 Effect가 Pass를 만드는지는 Frame Debugger로 확인한다.

---

## 자주 혼동하는 내용

### URP Asset이 직접 Scene을 그리는가?

아니다.

Asset은 설정과 Renderer 목록을 보관하고 Runtime Pipeline과 Renderer가 Rendering을 수행한다.

### Culling된 Renderer와 Draw Call 수는 같은가?

아니다.

Visible Renderer는 Drawing 후보이며 Pass, Material, Batching과 Instancing에 따라 Draw 수가 달라진다.

### Render Pass는 항상 Draw Call 하나인가?

아니다.

하나의 Pass가 많은 Renderer를 그리거나 Full-screen Draw, Compute 또는 Copy를 수행할 수 있다.

### Depth Texture를 켜면 항상 Depth Prepass가 실행되는가?

아니다.

조건에 따라 기존 Depth를 Copy할 수 있으며 Rendering Path와 Platform 설정에 따라 달라진다.

### Unity 6 URP의 Custom Pass는 모두 Execute에서 작성하는가?

아니다.

Render Graph 경로에서는 `RecordRenderGraph()`를 사용하고 `Execute()` 중심 방식은 Compatibility Mode에 해당한다.

### Render Graph가 Camera Culling을 대신하는가?

아니다.

Camera Culling은 보이지 않는 Scene 대상을 제외하고 Render Graph Pass Culling은 사용되지 않는 Pass를 제외한다.

### Custom Pass에서 Submit을 호출해야 하는가?

아니다.

URP가 전체 Render Loop의 제출을 관리하므로 Custom Pass가 임의로 호출하면 안 된다.

### Opaque 뒤에는 항상 Transparent가 바로 실행되는가?

아니다.

Skybox, Copy, Custom Pass와 다른 준비 작업이 사이에 들어갈 수 있다.

### Post-processing Effect 하나는 항상 Pass 하나인가?

아니다.

Effect와 URP Version에 따라 여러 Pass를 사용하거나 여러 작업이 결합될 수 있다.

### Frame Debugger의 Pass 목록은 모든 Camera에서 같은가?

아니다.

Camera, Renderer, Volume, Platform과 Feature 설정에 따라 달라진다.

---

## 전체 흐름 다시 연결하기

URP의 Camera Rendering을 하나의 구조로 연결하면 다음과 같다.

```text
Active URP Asset
        │
        ├─ Quality와 Feature 설정
        └─ Renderer Data 선택
        │
        ▼
Camera Data 준비
        │
        ▼
Culling Parameter 설정
        │
        ▼
Camera Culling
├─ Visible Renderer
├─ Visible Light
└─ Shadow 정보
        │
        ▼
Renderer가 Pass 구성
├─ Shadow
├─ Depth / Normal
├─ Opaque
├─ Skybox
├─ Copy
├─ Transparent
├─ Custom Pass
└─ Post-processing
        │
        ▼
Render Graph
├─ Resource 의존성
├─ Pass Culling
├─ Texture Lifetime
└─ 실행 Scheduling
        │
        ▼
Draw / Compute / Copy
        │
        ▼
Final Blit과 Camera Output
```

이 흐름은 모든 Camera에서 Pass가 완전히 같다는 뜻이 아니다.

실제 Pass 목록은 Camera와 Project 설정의 결과다.

---

## 정리

URP는 Camera별로 Culling Parameter를 설정하고 Culling을 수행한 뒤 Camera, Light, Platform과 Pipeline 설정을 Rendering Data로 정리한다.

선택된 Renderer는 이 Data를 바탕으로 Camera에 필요한 Render Pass를 구성한다.

```text
Camera
→ Culling
→ Rendering Data
→ Renderer
→ Render Pass
→ Draw
→ Post-processing
→ Final Output
```

Culling은 Frustum, Layer, Occlusion과 Shadow 조건으로 Visible Renderer와 Light 후보를 계산하며 실제 Draw는 뒤의 Pass에서 발생한다.

Renderer는 Shadow, Depth, Opaque, Skybox, Transparent, Post-processing과 Custom Pass의 순서를 조율한다.

Opaque와 Transparent Draw는 CullingResults, Render Queue, Sorting, Shader `LightMode`와 Layer 조건으로 대상을 선별한다.

Unity 6의 새 URP Project는 Render Graph가 기본 활성화되며 Pass가 Resource Input과 Output을 선언하면 사용되지 않는 Pass 제거와 Temporary Texture 수명 관리를 최적화할 수 있다.

Compatibility Mode는 이전 `Execute()` 기반 Custom Pass를 지원하지만 새 Feature는 `RecordRenderGraph()` 기반으로 작성하는 것이 권장된다.

URP의 실제 Pass 목록은 Rendering Path, Camera Texture, Shadow, MSAA, Renderer Feature, Post-processing, XR과 Platform 조건에 따라 달라진다.

Frame Debugger로 실제 Draw 순서를 확인하고 Render Graph Viewer로 Pass와 Texture 의존성을 분석하며 Profiler로 CPU·GPU 비용을 측정해야 한다.
