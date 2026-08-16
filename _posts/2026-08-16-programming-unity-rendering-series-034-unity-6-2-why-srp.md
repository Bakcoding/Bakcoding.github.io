---
title: "[Unity 렌더링] 6-2. SRP는 왜 등장했을까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - ScriptableRenderPipeline
  - RenderPipeline
  - ScriptableRenderContext
permalink: /programming/unity-6-2-why-srp/
toc: true
toc_sticky: true
date: 2026-08-16
last_modified_at: 2026-08-16
---

Unity의 Built-in Render Pipeline은 Engine 내부에 정의된 Render Loop를 사용한다.

개발자는 Camera, Rendering Path, Shader Pass와 CommandBuffer 같은 기능으로 결과를 조정할 수 있지만 전체 흐름 자체를 Project 목적에 맞게 다시 설계하기는 어렵다.

모바일 Game과 고사양 Console Game은 필요한 Lighting, Shadow, Post-processing과 Memory Budget이 전혀 다르다.

하나의 고정된 Pipeline이 모든 Project에 최적일 수 없는 이유다.

이 문제를 해결하기 위해 등장한 기반 구조가 Scriptable Render Pipeline이다.

```text
Built-in Render Pipeline
└─ Engine이 전체 Render Loop를 소유

Scriptable Render Pipeline
└─ Project가 C# 코드로 Render Loop를 구성
```

SRP는 Unity의 저수준 Rendering 기능을 버리는 체계가 아니다.

Unity가 제공하는 Culling, Drawing, Shadow와 Graphics API 추상화를 사용하면서 어떤 작업을 어떤 순서로 실행할지 C#에서 결정하는 체계다.

이번 글에서는 SRP가 필요해진 이유와 Rendering 과정을 제어한다는 말의 실제 의미를 연결한다.

---

## SRP란?

SRP는 `Scriptable Render Pipeline`의 약자다.

Unity Manual은 SRP를 C# Script로 Rendering Command를 예약하고 구성할 수 있는 얇은 API Layer로 설명한다.

```text
Project C# Rendering Code
            │
            ▼
Scriptable Render Pipeline API
            │
            ▼
Unity Low-level Graphics Architecture
            │
            ▼
Direct3D / Vulkan / Metal / OpenGL
            │
            ▼
GPU
```

개발자가 Platform별 Graphics API를 직접 호출하는 것은 아니다.

SRP Code는 Unity가 제공하는 Rendering API를 사용한다.

Unity는 그 Command를 현재 Platform의 Graphics API에 맞게 전달한다.

따라서 SRP의 핵심은 다음 두 요소의 결합이다.

| 요소 | 역할 |
| --- | --- |
| Unity Engine | Culling, Graphics API 추상화와 저수준 Rendering 기능 제공 |
| Project의 Pipeline Code | Pass 구성, Drawing 순서와 Feature 선택 |

SRP는 Rendering 전체를 처음부터 GPU Driver 수준으로 구현하는 기능이 아니다.

Engine과 Project 사이에서 Render Loop의 정책을 Project가 작성할 수 있게 만든 구조다.

---

## Scriptable이라는 말의 의미

`Scriptable`은 Shader를 C#으로 작성한다는 뜻이 아니다.

Shader는 여전히 HLSL Code를 통해 GPU에서 실행된다.

C#은 어떤 Camera를 처리하고 어떤 Object를 그리며 어느 Shader Pass를 사용할지 구성한다.

```text
C# Pipeline Code
├─ Camera 순서 결정
├─ Culling 요청
├─ Render Target 설정
├─ Renderer 선별
├─ Shader Pass 선택
├─ Shadow Drawing 요청
├─ Post-processing 배치
└─ Command 제출

HLSL Shader Code
├─ Vertex 변환
├─ Surface Data 계산
├─ Lighting 계산
└─ Pixel Color 출력
```

두 Code는 역할이 다르다.

C# Pipeline은 작업의 순서와 대상을 정의한다.

Shader는 선택된 Draw Call 안에서 Vertex와 Fragment를 계산한다.

이 구분을 이해해야 SRP를 Shader 제작 기능으로 오해하지 않는다.

---

## Built-in에서 제어할 수 있었던 것

Built-in Render Pipeline도 전혀 확장할 수 없는 구조는 아니다.

개발자는 다음 요소를 조정할 수 있다.

- Camera의 Forward 또는 Deferred Rendering Path
- ShaderLab의 Queue와 LightMode Tag
- Surface Shader와 Vertex·Fragment Shader
- Camera와 Light Event에 연결한 CommandBuffer
- `OnRenderImage` 기반 Image Effect
- Culling Mask, Clear Flags와 Camera Depth

```text
Built-in의 확장

고정된 Engine Render Loop
├─ 정해진 설정 변경
├─ 정해진 Shader Pass 제공
└─ 정해진 Event에 Command 삽입
```

이 방식은 공통적인 Rendering Workflow를 빠르게 구현하기에 편리하다.

하지만 Project가 원하는 구조가 Engine의 전제와 달라질수록 우회와 추가 비용이 생긴다.

---

## Built-in에서 제어하기 어려웠던 것

Built-in의 전체 Pass 순서와 내부 Lighting Loop는 Engine이 소유한다.

사용자는 Hook을 통해 작업을 추가할 수 있지만 Loop 전체를 교체하지는 못한다.

예를 들어 다음과 같은 요구를 생각할 수 있다.

- 특정 Platform에서 사용하지 않는 Pass를 Pipeline 단계부터 제거한다.
- Camera Stack을 Project 전용 규칙으로 처리한다.
- Shadow Atlas 배치와 갱신 정책을 직접 결정한다.
- 불투명 Object를 그리기 전에 전용 Depth Pass를 수행한다.
- 특정 Shader Tag를 가진 Renderer만 별도 Buffer에 그린다.
- Lighting Data를 Project 전용 Buffer Layout으로 구성한다.
- 여러 Render Target의 수명과 해상도를 직접 관리한다.

Built-in에서는 일부 결과를 비슷하게 만들 수 있어도 전체 구조를 명시적으로 소유하기 어렵다.

```text
원하는 흐름
A → C → 전용 Pass → B → D

Built-in의 흐름
A → B → C → D
        ↑
        정해진 Hook에만 작업 삽입
```

Pipeline이 제공하는 순서와 Project가 원하는 순서가 다르면 불필요한 Copy, 중복 Rendering 또는 복잡한 우회가 발생할 수 있다.

---

## 하나의 Pipeline으로 모든 Platform을 처리하는 문제

Rendering Feature의 비용은 Target Hardware에 따라 크게 다르다.

Mobile GPU는 Memory Bandwidth와 발열에 민감하다.

Desktop과 Console GPU는 더 복잡한 Lighting과 Compute 작업을 감당할 수 있다.

XR은 한 Frame에 두 Eye를 처리하는 방식과 매우 높은 Frame Rate가 중요하다.

```text
Mobile
├─ 작은 Memory Budget
├─ 낮은 Bandwidth
└─ 단순한 Lighting 선호

High-end PC / Console
├─ 복잡한 Lighting
├─ 고품질 Shadow
└─ 많은 Screen-space Effect

XR
├─ Stereo Rendering
├─ 낮은 Latency
└─ 높은 Frame Rate
```

고정된 Pipeline이 모든 기능을 포함하면 저사양 Platform에는 불필요한 비용이 생긴다.

반대로 공통 분모에만 맞추면 고사양 Platform의 표현력을 충분히 사용하기 어렵다.

SRP는 목적별 Pipeline을 구성할 수 있게 하여 이 충돌을 줄인다.

---

## Rendering 기술의 빠른 변화

현대 Rendering은 다양한 Technique을 빠르게 도입한다.

Lighting, Shadow, Temporal 처리, Upscaling과 GPU-driven Rendering은 서로 다른 Pass와 Resource 구조를 요구한다.

Engine 내부의 고정 Pipeline만 수정할 수 있다면 새로운 기술을 적용할 때 Engine Update를 기다려야 한다.

```text
고정 Pipeline
Project 요구 → Engine 기능 추가 대기 → Engine Version 반영

Scriptable Pipeline
Project 요구 → Pipeline Code 변경 → Project에서 검증
```

SRP는 Rendering 연구와 Product 요구 사이의 거리를 줄인다.

모든 Project가 Custom SRP를 직접 만들어야 한다는 뜻은 아니다.

핵심은 Unity와 Pipeline Package가 Engine 전체 Release와 더 느슨하게 발전할 수 있는 기반을 제공한다는 점이다.

---

## SRP가 해결하려는 핵심 문제

SRP가 해결하려는 문제는 단순히 Built-in을 더 빠르게 만드는 것이 아니다.

핵심은 Rendering 정책의 소유권이다.

```text
Built-in
Engine이 정책과 실행 기반을 함께 소유

SRP
Project 또는 Pipeline Package가 정책을 소유
Unity Engine이 실행 기반을 제공
```

정책에는 다음 항목이 포함된다.

- 어떤 Camera를 어떤 순서로 처리할지
- 어떤 Object를 Culling할지
- 어떤 Shader Pass를 선택할지
- Opaque와 Transparent를 어떤 기준으로 정렬할지
- Shadow를 언제 어떤 Target에 그릴지
- 중간 Texture를 언제 만들고 해제할지
- Lighting과 Post-processing을 어떤 순서로 배치할지
- 최종 결과를 언제 제출할지

SRP는 이 결정을 C# Code 영역으로 옮긴다.

---

## SRP의 주요 구성 요소

Custom SRP의 가장 기본적인 구성은 다음과 같다.

```text
RenderPipelineAsset
        │ CreatePipeline()
        ▼
RenderPipeline Instance
        │ Render(context, cameras)
        ▼
ScriptableRenderContext
        │
        ├─ Cull
        ├─ DrawRenderers
        ├─ DrawSkybox
        ├─ DrawShadows
        ├─ ExecuteCommandBuffer
        └─ Submit
```

각 구성 요소의 책임을 분리하면 SRP의 동작을 이해하기 쉽다.

| 구성 요소 | 책임 |
| --- | --- |
| `RenderPipelineAsset` | Pipeline 설정을 Asset으로 저장하고 Instance 생성 |
| `RenderPipeline` | 실제 Frame Rendering 흐름 정의 |
| `ScriptableRenderContext` | C#과 Unity 저수준 Graphics Code 연결 |
| `CommandBuffer` | Clear, Blit, Draw와 상태 변경 Command 기록 |
| `CullingResults` | Camera 기준으로 보이는 Renderer와 Light 정보 보관 |

---

## RenderPipelineAsset의 역할

`RenderPipelineAsset`은 `ScriptableObject`를 상속하는 Project Asset이다.

Pipeline 설정값을 저장하고 실제 `RenderPipeline` Instance를 생성한다.

```text
Project Asset
MyRenderPipelineAsset.asset
├─ Shadow Distance
├─ Shadow Resolution
├─ HDR 허용 여부
├─ Batching 설정
└─ Pipeline Instance 생성 규칙
```

같은 Pipeline Code를 사용하더라도 여러 Asset에 서로 다른 설정을 저장할 수 있다.

예를 들어 Quality Level마다 다른 Asset을 지정할 수 있다.

```text
Low Quality Asset
├─ 작은 Shadow Distance
└─ 낮은 Shadow Resolution

High Quality Asset
├─ 큰 Shadow Distance
└─ 높은 Shadow Resolution
```

Asset은 설정 Data다.

Frame마다 Rendering을 수행하는 주체는 Asset이 생성한 Pipeline Instance다.

---

## RenderPipelineAsset 최소 예제

Custom Pipeline Asset은 `CreatePipeline()`을 Override한다.

```csharp
using UnityEngine;
using UnityEngine.Rendering;

[CreateAssetMenu(
    menuName = "Rendering/Example Render Pipeline Asset"
)]
public sealed class ExampleRenderPipelineAsset
    : RenderPipelineAsset
{
    [SerializeField]
    private Color clearColor = Color.black;

    protected override RenderPipeline CreatePipeline()
    {
        return new ExampleRenderPipeline(clearColor);
    }
}
```

이 Code가 하는 일은 단순하다.

1. Inspector에 저장할 `clearColor`를 정의한다.
2. Asset 생성 Menu를 제공한다.
3. `ExampleRenderPipeline` Instance를 생성한다.

이 Asset을 Graphics Settings 또는 Quality Settings에 지정하면 해당 SRP가 Active Pipeline이 된다.

Asset이 지정되지 않은 Quality에서는 Built-in Render Pipeline이 사용된다.

---

## RenderPipeline Instance의 역할

`RenderPipeline`을 상속한 Class는 실제 Rendering Algorithm을 가진다.

Unity는 Active Pipeline이 사용하는 Instance의 `Render()`를 자동으로 호출한다.

```csharp
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public sealed class ExampleRenderPipeline : RenderPipeline
{
    private readonly Color clearColor;

    public ExampleRenderPipeline(Color clearColor)
    {
        this.clearColor = clearColor;
    }

    protected override void Render(
        ScriptableRenderContext context,
        List<Camera> cameras)
    {
        foreach (Camera camera in cameras)
        {
            RenderCamera(context, camera);
        }
    }

    private void RenderCamera(
        ScriptableRenderContext context,
        Camera camera)
    {
        // Camera별 Rendering 과정을 구성한다.
    }
}
```

`Render()`는 SRP의 진입점이다.

Camera 반복 순서와 Camera별 처리 내용도 Pipeline Code가 결정한다.

---

## List Camera Overload를 사용하는 이유

Unity 6 API에는 `List<Camera>`를 받는 `Render()`가 제공된다.

과거 호환성을 위한 `Camera[]` Signature도 존재할 수 있다.

Array Version은 크기 변경 과정에서 Heap Allocation을 만들 수 있으므로 Unity 문서는 `List<Camera>` Version 사용을 안내한다.

```csharp
protected override void Render(
    ScriptableRenderContext context,
    List<Camera> cameras)
{
    // 권장되는 진입점
}
```

Render Loop는 매 Frame 호출되는 Hot Path다.

작은 Allocation도 Frame마다 반복되면 Garbage Collection Spike의 원인이 될 수 있다.

API Signature 선택도 Rendering 성능과 연결된다.

---

## ScriptableRenderContext란?

`ScriptableRenderContext`는 C# Pipeline Code와 Unity의 저수준 Graphics Code 사이의 Interface다.

Pipeline은 Context를 통해 Culling과 Drawing을 요청하고 Command를 실행한다.

```text
RenderPipeline.Render()
        │
        ▼
ScriptableRenderContext
├─ Camera Culling
├─ Renderer Drawing
├─ Shadow Drawing
├─ Skybox Drawing
├─ CommandBuffer 실행
└─ GPU 제출
```

Context는 즉시 모든 GPU 작업을 끝내는 객체로 이해하면 안 된다.

Rendering Command를 구성하고 Unity의 내부 Rendering 시스템에 전달하는 통로다.

마지막에는 `Submit()`을 호출해 예약된 작업을 제출한다.

---

## CommandBuffer와 Context의 차이

`CommandBuffer`와 `ScriptableRenderContext`는 함께 사용하지만 역할이 다르다.

```text
CommandBuffer
├─ Render Target 설정
├─ Clear
├─ Global Shader Property 설정
├─ Blit
└─ Compute Dispatch

ScriptableRenderContext
├─ CommandBuffer 실행 요청
├─ Culling
├─ Renderer 목록 Drawing
├─ Skybox Drawing
├─ Shadow Drawing
└─ Submit
```

`CommandBuffer`는 일련의 Graphics Command를 기록한다.

Context의 `ExecuteCommandBuffer()`가 기록된 Command를 실행 Queue에 넣는다.

Renderer Collection을 Filtering하고 Drawing하는 작업은 보통 Context API를 사용한다.

두 기능을 섞어 전체 Frame을 구성한다.

---

## 최소 SRP가 화면을 지우는 과정

Object를 그리지 않고 화면만 특정 색으로 지우는 Pipeline도 유효한 최소 예제가 된다.

```csharp
private void RenderCamera(
    ScriptableRenderContext context,
    Camera camera)
{
    var cmd = new CommandBuffer
    {
        name = "Clear Camera Target"
    };

    cmd.ClearRenderTarget(
        clearDepth: true,
        clearColor: true,
        backgroundColor: clearColor
    );

    context.ExecuteCommandBuffer(cmd);
    cmd.Release();

    context.Submit();
}
```

흐름은 다음과 같다.

```text
CommandBuffer 생성
        │
        ▼
Clear Command 기록
        │
        ▼
Context에 실행 요청
        │
        ▼
CommandBuffer Release
        │
        ▼
Context.Submit()
```

이 예제는 SRP의 핵심 구조를 보여 주지만 Scene Object는 아직 그리지 않는다.

Renderer를 그리려면 Camera 설정, Culling과 Drawing 설정이 추가로 필요하다.

---

## Camera Properties 설정

Camera마다 View Matrix, Projection Matrix와 여러 Shader Variable이 달라진다.

`SetupCameraProperties()`는 현재 Camera에 맞는 Built-in Camera Property를 설정한다.

```csharp
context.SetupCameraProperties(camera);
```

일반적인 Camera Rendering 흐름에서 Culling 이후, Drawing 전에 호출한다.

```text
Camera 선택
    │
    ├─ Culling
    │
    ├─ SetupCameraProperties
    │
    ├─ Clear
    │
    ├─ Draw Visible Geometry
    │
    └─ Submit
```

Camera Data를 설정하지 않으면 Shader가 기대하는 Matrix와 Camera 관련 값이 올바르게 준비되지 않을 수 있다.

SRP가 자유롭다는 것은 필요한 준비 작업까지 Pipeline 작성자가 책임진다는 뜻이다.

---

## Culling을 직접 요청하는 흐름

GPU에 모든 Renderer를 보내기 전에 Camera에 보일 가능성이 있는 대상을 선별해야 한다.

Camera는 Culling 설정을 만들 수 있다.

Context는 그 설정으로 Culling을 수행한다.

```csharp
if (!camera.TryGetCullingParameters(
        out ScriptableCullingParameters cullingParameters))
{
    return;
}

CullingResults cullingResults =
    context.Cull(ref cullingParameters);
```

결과에는 Camera 기준으로 보이는 Renderer와 Light에 관한 정보가 포함된다.

```text
Camera
  │ TryGetCullingParameters
  ▼
ScriptableCullingParameters
  │ context.Cull
  ▼
CullingResults
├─ Visible Renderers
├─ Visible Lights
└─ Shadow 관련 정보
```

SRP 작성자는 Culling 결과를 직접 계산하는 것이 아니라 Unity에 Culling을 요청한다.

필요한 Parameter와 결과 사용 정책을 제어한다.

---

## Culling Parameter로 제어할 수 있는 것

`ScriptableCullingParameters`는 Pipeline의 Culling 정책을 조정하는 출발점이다.

예를 들어 Shadow Distance를 Camera Far Clip보다 작게 제한할 수 있다.

```csharp
cullingParameters.shadowDistance = Mathf.Min(
    maxShadowDistance,
    camera.farClipPlane
);
```

Camera가 매우 멀리까지 보더라도 Shadow까지 같은 거리로 계산할 필요는 없다.

```text
Camera Far Clip
0 ───────────────────────────── 1000m

Shadow Distance
0 ───────── 100m
```

보이는 Geometry 범위와 Shadow를 계산할 범위를 분리하면 비용을 줄일 수 있다.

이처럼 Pipeline은 Project의 Quality 정책을 Culling 단계에 반영할 수 있다.

---

## Renderer를 그리기 위한 두 가지 설정

Visible Renderer를 그릴 때는 주로 `DrawingSettings`와 `FilteringSettings`를 사용한다.

```text
DrawingSettings
├─ 사용할 ShaderTagId
├─ SortingSettings
├─ Per-object Data
└─ Batching 관련 설정

FilteringSettings
├─ Render Queue Range
├─ Layer Mask
└─ Rendering Layer Mask
```

`DrawingSettings`는 어떻게 그릴지를 정의한다.

`FilteringSettings`는 어떤 Renderer를 그릴지를 정의한다.

둘을 `CullingResults`와 함께 Context에 전달하면 조건에 맞는 Visible Renderer가 그려진다.

---

## ShaderTagId로 Pass 선택하기

SRP는 Shader의 모든 Pass를 무조건 실행하지 않는다.

Pipeline이 요청하는 `ShaderTagId`와 ShaderLab Pass의 `LightMode` Tag를 연결한다.

```csharp
private static readonly ShaderTagId UnlitShaderTagId =
    new ShaderTagId("SRPDefaultUnlit");
```

Shader 쪽에서는 다음처럼 대응할 수 있다.

```shaderlab
Pass
{
    Tags
    {
        "LightMode" = "SRPDefaultUnlit"
    }

    HLSLPROGRAM
    // Vertex / Fragment Program
    ENDHLSL
}
```

```text
Pipeline 요청
ShaderTagId("SRPDefaultUnlit")
              │
              ▼
Shader Pass
LightMode = "SRPDefaultUnlit"
```

이 이름이 맞지 않으면 Pipeline이 해당 Pass를 선택하지 못해 Object가 그려지지 않을 수 있다.

SRP마다 Shader 호환성이 달라지는 중요한 이유다.

---

## Opaque Drawing 설정

Opaque Object는 일반적으로 Front-to-back 정렬을 활용해 Overdraw를 줄인다.

Camera 기준 Sorting 설정과 Opaque Queue 범위를 구성할 수 있다.

```csharp
var sortingSettings = new SortingSettings(camera)
{
    criteria = SortingCriteria.CommonOpaque
};

var drawingSettings = new DrawingSettings(
    UnlitShaderTagId,
    sortingSettings
);

var filteringSettings = new FilteringSettings(
    RenderQueueRange.opaque
);

context.DrawRenderers(
    cullingResults,
    ref drawingSettings,
    ref filteringSettings
);
```

Pipeline 작성자가 Opaque 범위와 정렬 기준을 명시한다.

Built-in 내부에 감춰져 있던 정책이 Code로 드러난다.

---

## Transparent Drawing 설정

Transparent Object는 Blend 결과 때문에 일반적으로 Back-to-front 정렬이 필요하다.

```csharp
sortingSettings.criteria = SortingCriteria.CommonTransparent;
drawingSettings.sortingSettings = sortingSettings;
filteringSettings.renderQueueRange = RenderQueueRange.transparent;

context.DrawRenderers(
    cullingResults,
    ref drawingSettings,
    ref filteringSettings
);
```

```text
Opaque
├─ Queue: opaque
└─ Sorting: CommonOpaque

Transparent
├─ Queue: transparent
└─ Sorting: CommonTransparent
```

두 그룹을 한 번에 그리지 않고 서로 다른 정책으로 Drawing한다.

이 분리 사이에 Skybox나 Custom Pass를 배치할 수도 있다.

---

## Skybox의 위치도 Pipeline이 정한다

Skybox는 Context의 `DrawSkybox()`를 통해 요청할 수 있다.

```csharp
context.DrawSkybox(camera);
```

일반적인 순서는 다음과 같다.

```text
Clear
  │
  ▼
Opaque Geometry
  │
  ▼
Skybox
  │
  ▼
Transparent Geometry
```

Skybox를 Opaque 뒤에 그리면 Opaque가 차지하지 않은 Pixel에만 Background가 보인다.

Custom Pipeline은 다른 목적에 따라 순서를 다르게 구성할 수 있다.

중요한 점은 이 순서가 C# Code에 명시된다는 것이다.

---

## 하나의 Camera를 그리는 최소 흐름

앞의 요소를 연결하면 단순한 Camera Rendering 흐름을 만들 수 있다.

```csharp
private void RenderCamera(
    ScriptableRenderContext context,
    Camera camera)
{
    if (!camera.TryGetCullingParameters(
            out ScriptableCullingParameters parameters))
    {
        return;
    }

    CullingResults cullingResults = context.Cull(ref parameters);

    context.SetupCameraProperties(camera);

    var cmd = new CommandBuffer
    {
        name = camera.name
    };

    cmd.ClearRenderTarget(true, true, clearColor);
    context.ExecuteCommandBuffer(cmd);
    cmd.Clear();

    DrawVisibleGeometry(context, camera, cullingResults);

    context.Submit();
    cmd.Release();
}
```

세부 Error 처리와 Editor 지원을 생략한 학습용 구조다.

실제 Production Pipeline에는 Shadow, Lighting, Unsupported Shader 처리, Gizmo와 Resource 관리 등이 더 필요하다.

---

## 전체 Frame 흐름을 Code로 읽을 수 있다

Custom SRP의 장점 중 하나는 Rendering 순서가 Code Structure로 드러난다는 점이다.

```csharp
private void RenderCamera(
    ScriptableRenderContext context,
    Camera camera)
{
    Cull(context, camera);
    SetupCamera(context, camera);

    DrawShadows(context);
    DrawDepthPrepass(context, camera);
    DrawOpaque(context, camera);
    DrawSkybox(context, camera);
    DrawTransparent(context, camera);
    DrawPostProcessing(context, camera);

    context.Submit();
}
```

이 Code만으로도 큰 순서를 확인할 수 있다.

```text
Cull
 → Camera Setup
 → Shadow
 → Depth Prepass
 → Opaque
 → Skybox
 → Transparent
 → Post-processing
 → Submit
```

실제 Pipeline은 더 복잡하지만 Render Loop가 Data와 Code로 표현된다는 원리는 같다.

---

## 렌더링 과정 제어의 실제 범위

SRP에서 제어한다는 말은 다음 영역을 포함한다.

| 영역 | 제어 예시 |
| --- | --- |
| Camera | 처리 순서, Target, Clear와 Stack 정책 |
| Culling | Shadow Distance, Layer와 Culling Option |
| Drawing | Queue, Sorting, Shader Pass와 Per-object Data |
| Lighting | Visible Light 처리, Buffer 구성과 Light Loop |
| Shadow | Caster 선택, Atlas, Cascade와 Update 정책 |
| Resource | Color·Depth Texture의 Format, Size와 수명 |
| Pass | Depth, Opaque, Transparent와 Effect 순서 |
| Submission | Command 실행과 Submit 시점 |

자유도가 높아진 만큼 모든 항목을 반드시 직접 구현해야 하는 것은 아니다.

Unity가 제공하는 API와 SRP Core의 공통 기능을 활용할 수 있다.

다만 최종 정책과 조합은 Pipeline 구현에 속한다.

---

## SRP Core의 역할

SRP Core Package는 SRP 제작과 Customization에 필요한 공통 Code를 제공한다.

Unity 6 Manual은 다음과 같은 요소를 포함한다고 설명한다.

- Platform별 Graphics API를 다루기 위한 Boilerplate
- 공통 Rendering Operation Utility
- Shader Library
- Pipeline 제작에 재사용할 기반 기능

```text
Custom Pipeline / Prebuilt Pipeline
            │
            ▼
SRP Core
├─ 공통 Utility
├─ Shader Library
└─ Platform 추상화 지원
            │
            ▼
Unity Engine
```

SRP Core는 완성된 Render Pipeline 자체와 같지 않다.

Pipeline 구현에 필요한 공통 기반 Package다.

---

## SRP와 완성된 Pipeline의 차이

SRP는 Framework다.

완성된 Render Pipeline은 그 Framework를 사용해 구체적인 Rendering 정책을 구현한 결과다.

```text
SRP Framework
├─ RenderPipelineAsset
├─ RenderPipeline
├─ ScriptableRenderContext
└─ Rendering API
       │
       ├─ 완성된 범용 Pipeline A
       ├─ 완성된 고품질 Pipeline B
       └─ Project 전용 Custom Pipeline
```

따라서 “SRP를 사용한다”는 말만으로 정확한 Lighting Feature나 성능을 알 수 없다.

어떤 SRP 구현과 어떤 설정을 사용하는지 확인해야 한다.

SRP라는 공통 기반이 모든 구현의 결과를 같게 만들지는 않는다.

---

## SRP는 Rendering Path가 아니다

Rendering Path와 Render Pipeline은 계층이 다르다.

```text
Render Pipeline
└─ 전체 Rendering 구조
   ├─ Camera 처리
   ├─ Shadow
   ├─ Lighting
   ├─ Drawing
   └─ Post-processing

Rendering Path
└─ Lighting과 Geometry를 처리하는 특정 경로
```

Built-in 안에는 Forward, Deferred와 Legacy Vertex Lit Path가 있다.

SRP 구현도 자신의 구조 안에 Forward나 Deferred 계열의 경로를 제공할 수 있다.

SRP 자체를 Forward 또는 Deferred와 같은 Rendering Path로 분류하면 안 된다.

---

## SRP는 하나의 Shader가 아니다

SRP와 Shader는 서로 협력하지만 같은 대상이 아니다.

```text
SRP
└─ 어떤 Shader Pass를 언제 실행할지 결정

Shader
└─ 선택된 Pass에서 GPU 계산 수행
```

Pipeline이 특정 `LightMode` Tag를 요청하면 대응하는 Shader Pass가 필요하다.

Pipeline이 Lighting Data를 특정 Buffer Layout으로 전달하면 Shader도 그 Layout을 읽어야 한다.

그래서 Pipeline이 달라질 때 Shader가 그대로 호환되지 않을 수 있다.

호환성은 파일 확장자가 `.shader`인지 여부가 아니라 Pipeline과 Shader 사이의 Contract에 달려 있다.

---

## Pipeline과 Shader의 Contract

Pipeline과 Shader는 여러 규칙을 공유한다.

- Shader Pass의 `LightMode` 이름
- Camera와 Object Matrix의 이름과 Layout
- Light Data를 담는 Constant Buffer
- Shadow Texture와 Sampling 규칙
- Keyword와 Variant 구성
- Depth와 Normal Encoding
- Render Target Format과 채널 의미

```text
Pipeline
├─ _CameraColorTexture 생성
├─ Light Buffer 설정
└─ "ExampleForward" Pass 요청
            │ Contract
            ▼
Shader
├─ _CameraColorTexture 읽기
├─ 같은 Light Buffer Layout 사용
└─ LightMode="ExampleForward" 제공
```

Contract가 맞지 않으면 Compile이 성공해도 정상적인 결과가 나오지 않을 수 있다.

SRP 전환에 Material과 Shader Migration이 필요한 이유다.

---

## RenderPipelineManager Callback

SRP에는 Rendering 시점에 Code를 연결할 수 있는 Callback이 있다.

Unity 6에서는 Context와 Camera 단위 Event를 사용할 수 있다.

- `beginContextRendering`
- `endContextRendering`
- `beginCameraRendering`
- `endCameraRendering`

```text
beginContextRendering
  │
  ├─ beginCameraRendering(Camera A)
  │    └─ Camera A Rendering
  │   endCameraRendering(Camera A)
  │
  ├─ beginCameraRendering(Camera B)
  │    └─ Camera B Rendering
  │   endCameraRendering(Camera B)
  │
endContextRendering
```

완성된 Pipeline이 Event를 호출하면 외부 System이 정해진 시점에 동작을 연결할 수 있다.

Custom SRP 작성자는 적절한 위치에서 대응 Event를 호출할 책임이 있다.

---

## Camera Callback 예제

다음은 Camera Rendering 시작 시점을 구독하는 구조다.

```csharp
using UnityEngine;
using UnityEngine.Rendering;

public sealed class CameraRenderObserver : MonoBehaviour
{
    private void OnEnable()
    {
        RenderPipelineManager.beginCameraRendering +=
            OnBeginCameraRendering;
    }

    private void OnDisable()
    {
        RenderPipelineManager.beginCameraRendering -=
            OnBeginCameraRendering;
    }

    private void OnBeginCameraRendering(
        ScriptableRenderContext context,
        Camera camera)
    {
        Debug.Log($"Begin rendering: {camera.name}");
    }
}
```

구독과 해제를 쌍으로 관리해야 한다.

이 Callback은 Built-in 전용 Camera Callback과 같은 것으로 가정하면 안 된다.

SRP Render Loop에서 제공되는 시점을 기준으로 동작한다.

---

## Custom SRP가 Callback을 호출하는 이유

Custom Pipeline 내부에서 다음과 같은 구조를 구성할 수 있다.

```csharp
protected override void Render(
    ScriptableRenderContext context,
    List<Camera> cameras)
{
    BeginContextRendering(context, cameras);

    foreach (Camera camera in cameras)
    {
        BeginCameraRendering(context, camera);
        RenderCamera(context, camera);
        EndCameraRendering(context, camera);
    }

    EndContextRendering(context, cameras);
}
```

Pipeline이 Callback을 호출하지 않으면 이를 기다리는 외부 Code가 실행되지 않는다.

SRP의 자유도는 Ecosystem과의 연결 지점도 구현 책임에 포함시킨다.

완성도 높은 Pipeline은 단순히 화면만 그리는 것 이상을 처리해야 한다.

---

## Rendering 제어가 성능으로 이어지는 방식

SRP는 필요 없는 작업을 Pipeline 수준에서 제거할 수 있다.

예를 들어 단순한 Stylized Mobile Game에 고급 Feature가 필요하지 않을 수 있다.

```text
Project에 필요한 Pass
├─ Main Shadow
├─ Opaque
├─ Skybox
├─ Transparent
└─ Tone Mapping

제외 가능한 Pass
├─ Motion Vector
├─ 다중 G-buffer
├─ 고급 Screen-space Effect
└─ 사용하지 않는 Auxiliary Buffer
```

Pass를 실행하지 않으면 관련 Draw Call, Texture Write와 Bandwidth를 줄일 가능성이 생긴다.

하지만 Custom Code라는 이유만으로 자동으로 빠르지는 않다.

잘못 구성하면 중복 Pass, 과도한 Texture와 잦은 State 변경으로 Built-in보다 느려질 수 있다.

---

## 명시적인 Feature 선택

SRP는 Rendering Feature를 Project의 조건에 맞춰 구성할 수 있다.

```csharp
if (settings.enableDepthPrepass)
{
    DrawDepthPrepass(context, camera);
}

DrawOpaque(context, camera);

if (settings.enablePostProcessing)
{
    DrawPostProcessing(context, camera);
}
```

기능의 On·Off가 Code와 Asset 설정으로 드러난다.

Platform별 Pipeline Asset에 서로 다른 설정을 저장할 수도 있다.

```text
Mobile Asset
├─ Depth Prepass: Off
├─ Shadow Cascades: 1
└─ Post-processing: Basic

Desktop Asset
├─ Depth Prepass: On
├─ Shadow Cascades: 4
└─ Post-processing: High
```

단, Asset 교체가 Shader와 Pipeline 구조 자체의 무조건적인 호환을 보장하지는 않는다.

같은 Pipeline 구현이 해석할 수 있는 설정이어야 한다.

---

## Resource 수명 제어

현대 Rendering은 많은 중간 Texture를 사용한다.

- Camera Color
- Depth
- Normal
- Motion Vector
- Shadow Atlas
- Post-processing Intermediate

```text
Pass A ── writes ──> Texture X
Pass B ── reads  ──> Texture X
Pass C 이후 Texture X 불필요
```

Pipeline이 Resource의 생성, 사용과 해제 시점을 알면 Memory를 더 효율적으로 관리할 수 있다.

반대로 수명을 과도하게 길게 유지하면 Peak Memory가 증가한다.

SRP의 제어권은 Render Target Format, Resolution과 Lifetime을 성능 정책으로 다룰 수 있게 한다.

실제 구현에서는 현재 Pipeline이 제공하는 Resource 관리 체계를 따라야 한다.

---

## Draw Call만 줄이면 되는 것은 아니다

Rendering 최적화는 Draw Call 하나의 숫자로 끝나지 않는다.

SRP 설계 시 다음 비용을 함께 봐야 한다.

- CPU Culling과 Renderer 준비 비용
- SetPass와 Pipeline State 변경
- GPU Vertex와 Fragment 연산
- Overdraw
- Render Target Read·Write Bandwidth
- Texture Memory와 Temporary Resource Peak
- Shadow와 Post-processing Pass 수
- Synchronization과 Submit 지점

```text
Frame Time
├─ CPU Render Thread
├─ GPU Geometry
├─ GPU Pixel
├─ Bandwidth
└─ Synchronization
```

Pass를 합치면 Bandwidth가 줄 수 있지만 Shader가 복잡해질 수 있다.

Pass를 분리하면 구조는 명확해져도 Texture 접근과 전환 비용이 늘 수 있다.

SRP는 선택권을 주며 정답까지 자동으로 결정하지 않는다.

---

## SRP의 장점

SRP의 대표적인 장점은 다음과 같다.

### Project 목적에 맞는 구조

필요한 Feature와 Target Hardware에 맞춰 Rendering 흐름을 구성할 수 있다.

### 명시적인 Render Loop

Pass 순서와 조건이 C# Code에 표현되어 동작을 추적하기 쉽다.

### 불필요한 작업 제거 가능성

사용하지 않는 Pass와 Resource를 Pipeline 설계에서 제외할 수 있다.

### Rendering 기술 확장

Project 전용 Buffer, Pass와 Lighting Workflow를 구현할 수 있다.

### Package 단위 발전

Pipeline과 공통 Rendering Code가 Engine 전체와 구분된 Package 형태로 발전할 수 있다.

이 장점은 Pipeline을 올바르게 설계하고 유지할 역량이 있을 때 실현된다.

---

## SRP의 비용

제어권에는 책임과 유지보수 비용이 따른다.

### 구현 범위 증가

Shadow, Lighting, Camera, Editor View와 Debug 기능까지 고려해야 한다.

### Shader Contract 관리

Pipeline의 Data Layout과 Shader Pass가 함께 변경되어야 한다.

### Platform 검증

Graphics API와 Hardware별 결과 및 성능을 확인해야 한다.

### Tooling 지원

Frame Debugger Marker, Gizmo, Scene View와 Preview가 올바르게 동작해야 한다.

### Upgrade 비용

Unity Version과 SRP Core API 변경에 맞춰 Custom Code를 유지해야 한다.

```text
높은 제어권
    │
    ├─ 높은 최적화 가능성
    ├─ 독자적인 표현 가능성
    └─ 높은 구현·검증·유지보수 책임
```

Custom SRP는 간단한 Script 하나를 추가하는 수준의 결정이 아니다.

---

## 왜 모든 팀이 Custom SRP를 만들지 않는가?

범용 Game에 필요한 Rendering Feature는 매우 많다.

- Directional, Point와 Spot Light
- Realtime·Baked Lighting
- 여러 Shadow Type과 Cascade
- Reflection Probe와 Light Probe
- Particle, Terrain과 Decal
- Post-processing
- Camera Stack과 XR
- Platform별 최적화
- Editor Preview와 Debug View

이 기능을 처음부터 구현하고 지속적으로 검증하는 비용은 크다.

```text
Custom SRP 선택
├─ 필요한 Feature가 매우 독특함
├─ 전담 Rendering 역량이 있음
├─ 장기간 유지보수 가능
└─ 범용 Pipeline보다 얻는 이점이 명확함
```

대부분의 팀은 검증된 SRP 구현을 사용하고 제공되는 확장 지점 안에서 Custom Pass를 추가하는 편이 현실적이다.

SRP Framework의 존재와 Custom SRP 직접 제작의 필요성은 별개의 문제다.

---

## Built-in Hook과 SRP 제어의 차이

Built-in의 CommandBuffer도 Rendering Command를 삽입할 수 있다.

하지만 정해진 Event에 연결한다는 전제가 있다.

```text
Built-in CommandBuffer
Engine Loop
├─ Event A
│   └─ Custom Command 삽입
├─ Engine Pass B
└─ Event C

Custom SRP
Project Loop
├─ Custom Pass A
├─ 조건에 따라 Pass B 생략
├─ Custom Pass C
└─ 직접 Submit
```

Built-in Hook은 Engine Loop를 확장한다.

SRP는 Render Loop의 구성을 Pipeline Code가 담당한다.

둘 다 `CommandBuffer`를 사용할 수 있지만 제어 계층이 다르다.

---

## 제어할 수 있다는 말의 한계

SRP가 Unity Engine과 GPU의 모든 동작을 무제한으로 바꿀 수 있다는 뜻은 아니다.

다음과 같은 경계가 있다.

- Unity가 공개한 Rendering API 범위
- Target Graphics API와 Hardware의 지원 기능
- Platform별 제한
- Unity의 Object, Camera와 Culling System 구조
- Shader Model과 GPU Resource 제한

```text
Project C# Code의 자유
        │
        ▼
Unity SRP API가 허용하는 범위
        │
        ▼
Graphics API와 Hardware Capability
```

SRP는 Engine Source 전체를 자유롭게 수정하는 기능과 같지 않다.

Unity가 제공하는 추상화 안에서 높은 수준의 Rendering 제어권을 제공한다.

---

## Pipeline 설정과 Active Pipeline

SRP 기반 Pipeline을 활성화하려면 Render Pipeline Asset을 Project Settings에 지정한다.

```text
QualitySettings.renderPipeline
        │ 값이 있으면 우선
        ▼
GraphicsSettings.defaultRenderPipeline
        │ 값이 있으면 사용
        ▼
둘 다 없으면 Built-in
```

Quality Setting의 Override가 있으면 해당 Asset이 우선한다.

Override가 없으면 Graphics Setting의 Default Asset을 사용한다.

어느 쪽에도 Asset이 지정되지 않으면 Built-in Render Pipeline이 활성화된다.

SRP Package를 설치한 것만으로 Active Pipeline이 자동 변경되는 것은 아니다.

---

## Active Pipeline을 확인하는 방법

현재 Pipeline Asset은 C#에서 확인할 수 있다.

```csharp
using UnityEngine;
using UnityEngine.Rendering;

public static class ActivePipelineLogger
{
    [RuntimeInitializeOnLoadMethod]
    private static void Log()
    {
        RenderPipelineAsset qualityAsset =
            QualitySettings.renderPipeline;

        RenderPipelineAsset defaultAsset =
            GraphicsSettings.defaultRenderPipeline;

        RenderPipelineAsset activeAsset =
            qualityAsset != null
                ? qualityAsset
                : defaultAsset;

        Debug.Log(
            activeAsset == null
                ? "Built-in Render Pipeline"
                : $"SRP: {activeAsset.GetType().Name}"
        );
    }
}
```

문제 진단 시 Package 설치 여부가 아니라 실제 Active Asset을 확인해야 한다.

Quality Level을 변경했을 때 다른 Asset이 Override되는지도 함께 확인한다.

---

## SRP 전환 시 화면이 분홍색이 되는 이유

분홍색 Material은 Shader가 지원되지 않거나 정상적으로 사용할 수 없다는 신호다.

Pipeline을 바꾸면 다음 Contract가 달라질 수 있다.

- 요청하는 `LightMode` Tag
- Lighting Include와 Function
- Shader Keyword
- Light와 Shadow Data Layout
- 지원하는 Surface Shader Workflow

```text
기존 Shader
Built-in Contract에 맞음
        │ Pipeline 변경
        ▼
새 SRP가 요구하는 Pass를 찾지 못함
        │
        ▼
Unsupported / Pink Material
```

Pipeline Asset만 교체한다고 Shader가 자동으로 같은 결과를 내는 것은 아니다.

Material Converter가 지원하는 범위와 Custom Shader의 수동 Migration 범위를 구분해야 한다.

---

## Surface Shader와 SRP

Built-in의 Surface Shader Compiler는 Built-in Lighting Workflow에 맞는 Pass를 생성한다.

Custom SRP의 임의 Lighting Contract에 맞는 Pass를 자동 생성하지 않는다.

```text
Built-in Surface Shader
Surface Function
  │
  └─ Built-in Forward / Deferred / Shadow Pass 생성

Custom SRP
Pipeline 전용 LightMode와 Data Contract 필요
```

따라서 Built-in Surface Shader를 SRP에 그대로 옮길 수 있다고 가정하면 안 된다.

SRP가 사용하는 Shader Library, Shader Graph Target 또는 직접 작성한 HLSL 구조에 맞춰야 한다.

이 차이는 SRP가 C#만 바꾸는 기능이 아니라 Pipeline과 Shader의 협력 구조라는 점을 보여 준다.

---

## Custom SRP 학습에서 흔한 첫 화면 문제

최소 Pipeline Code를 작성했는데 아무것도 보이지 않을 수 있다.

확인할 항목은 다음과 같다.

1. Pipeline Asset이 실제 Graphics 또는 Quality Settings에 지정되었는가?
2. `Render()`가 호출되는가?
3. Camera Culling이 성공했는가?
4. `SetupCameraProperties()`를 호출했는가?
5. Clear와 Drawing Command를 Context에 전달했는가?
6. Shader의 `LightMode`가 요청한 `ShaderTagId`와 일치하는가?
7. Filtering의 Render Queue 범위가 Material Queue와 맞는가?
8. 마지막에 `context.Submit()`을 호출했는가?

```text
Asset
 → Render Entry
 → Culling
 → Camera Setup
 → Pass Match
 → Filtering
 → Drawing
 → Submit
```

위 순서대로 확인하면 문제 지점을 좁히기 쉽다.

---

## Submit을 빠뜨리면 생기는 문제

Context에 Command를 예약하고 Drawing을 요청해도 최종 제출이 필요하다.

```csharp
context.ExecuteCommandBuffer(cmd);
context.DrawRenderers(
    cullingResults,
    ref drawingSettings,
    ref filteringSettings
);

context.Submit();
```

`Submit()`은 지금까지 예약한 Rendering 작업을 Unity의 저수준 Graphics 계층에 제출한다.

```text
C#에서 Command 구성
        │
        ▼
Context에 작업 예약
        │
        ▼
Submit
        │
        ▼
Unity Graphics Layer → GPU
```

호출 위치와 빈도는 Pipeline 구조와 성능에 영향을 준다.

학습용 Pipeline에서는 Camera 끝에 호출하는 구조가 이해하기 쉽다.

---

## CommandBuffer 재사용

매 Camera와 Pass마다 `new CommandBuffer()`를 반복하면 관리와 Allocation 측면에서 불리할 수 있다.

Pipeline Instance가 Buffer를 보관하고 재사용하는 구조를 만들 수 있다.

```csharp
private readonly CommandBuffer commandBuffer =
    new CommandBuffer
    {
        name = "Example Render Pipeline"
    };

private void ExecuteBuffer(ScriptableRenderContext context)
{
    context.ExecuteCommandBuffer(commandBuffer);
    commandBuffer.Clear();
}

protected override void Dispose(bool disposing)
{
    commandBuffer.Release();
    base.Dispose(disposing);
}
```

```text
Command 기록
 → Context 실행 요청
 → Clear
 → 다음 Pass에서 재사용
 → Pipeline Dispose 시 Release
```

Resource의 소유자와 해제 시점을 명확하게 정의해야 한다.

---

## Profiling Marker의 중요성

Custom SRP는 Pass 이름과 Profiling Scope를 직접 제공해야 문제를 찾기 쉽다.

```csharp
private static readonly ProfilingSampler CameraSampler =
    new ProfilingSampler("Render Camera");

private void RenderCamera(
    ScriptableRenderContext context,
    Camera camera)
{
    using (new ProfilingScope(commandBuffer, CameraSampler))
    {
        // Camera Rendering Command 기록
    }

    ExecuteBuffer(context);
}
```

Profiler와 Frame Debugger에 의미 있는 이름이 보이면 Pass의 비용과 순서를 추적하기 쉽다.

```text
불명확한 Marker
Unnamed Pass / Draw / Draw / Draw

명확한 Marker
Main Shadow / Depth Prepass / Opaque / Transparent / Tone Mapping
```

Tooling은 Pipeline 구현 이후에 덧붙이는 장식이 아니라 유지보수 가능한 Render Loop의 일부다.

---

## Frame Debugger에서 확인할 내용

SRP의 Render Loop가 의도대로 동작하는지 Frame Debugger로 확인할 수 있다.

- Camera별 Event 순서
- Clear 시점과 Clear 대상
- Render Target 전환
- Opaque와 Transparent Drawing 순서
- 선택된 Shader Pass
- Shadow와 Custom Pass 위치
- 불필요한 중복 Drawing

```text
예상
Clear → Opaque → Skybox → Transparent

실제 Frame Debugger
Clear → Opaque → Opaque 중복 → Skybox → Transparent
                 ↑
                 문제 후보
```

Code만 읽어서는 Material Queue, Camera 중복 또는 조건 분기 결과를 모두 알기 어렵다.

실제 Frame을 펼쳐 Pipeline의 의도와 실행 결과를 비교해야 한다.

---

## CPU와 GPU Profiler를 함께 보는 이유

SRP Code는 CPU에서 Command를 구성하고 GPU가 실제 Rendering 작업을 수행한다.

한쪽만 측정하면 병목을 잘못 판단할 수 있다.

```text
CPU 병목 후보
├─ Culling
├─ Renderer 정렬
├─ 많은 Draw 제출
└─ Allocation과 GC

GPU 병목 후보
├─ Shadow Fill
├─ Fragment Shader
├─ Overdraw
├─ Bandwidth
└─ Post-processing
```

Pass를 줄였는데 Frame이 빨라지지 않는다면 해당 Pass가 병목이 아니었을 수 있다.

Target Device에서 CPU와 GPU Frame Time을 각각 확인해야 한다.

SRP의 높은 제어권은 측정 기반 의사결정을 더 중요하게 만든다.

---

## Custom SRP 설계 순서

처음부터 모든 Feature를 구현하면 문제 원인을 분리하기 어렵다.

다음처럼 작은 단계로 확장하는 편이 안전하다.

```text
1. Pipeline Asset과 Clear
            │
            ▼
2. Camera Setup과 Culling
            │
            ▼
3. Unlit Opaque
            │
            ▼
4. Skybox와 Transparent
            │
            ▼
5. Lighting
            │
            ▼
6. Shadow
            │
            ▼
7. Post-processing와 고급 Feature
```

각 단계에서 Frame Debugger와 Profiler 결과를 남긴다.

Feature가 추가될 때 Pipeline과 Shader Contract도 함께 Test한다.

---

## Project 전용 Pipeline이 적합한 경우

Custom SRP의 가치가 큰 경우는 Rendering 요구가 명확하고 범위가 제한될 때다.

- 독특한 Stylized Lighting만 사용하는 Project
- 고정된 Camera와 제한된 Material Set을 가진 Game
- 특정 Hardware 하나에 강하게 최적화하는 Application
- 연구 목적의 새로운 Rendering Technique
- 범용 Pipeline 확장 지점으로 구현하기 어려운 Render Loop

```text
적합성 판단
Project 전용 이점
      >
구현 + 검증 + Upgrade + Tooling 비용
```

단순히 Rendering Code를 직접 소유하고 싶다는 이유만으로는 장기 비용을 정당화하기 어렵다.

필요한 Feature 목록과 유지보수 기간을 먼저 계산해야 한다.

---

## 기존 Pipeline 확장이 적합한 경우

완성된 SRP 구현이 제공하는 Feature가 대부분 필요하고 일부 Effect만 추가한다면 전체 Pipeline을 만들 필요가 없다.

```text
요구 사항
├─ 일반적인 Lighting과 Shadow 필요
├─ 다양한 Platform 지원 필요
├─ Tooling과 Upgrade 지원 중요
└─ Custom Pass 몇 개만 필요
        │
        ▼
기존 SRP 구현 + 공식 확장 지점
```

검증된 Camera, Lighting, Shadow와 Platform Code를 재사용할 수 있다.

Custom Feature는 Pipeline이 공개한 Injection Point와 API 범위에서 구현한다.

Framework가 Scriptable하다는 사실이 항상 전체 Framework를 다시 작성하라는 의미는 아니다.

---

## SRP 도입이 팀 Workflow에 미치는 영향

SRP에서는 Rendering Programmer와 Technical Artist 사이의 Contract가 더 중요해진다.

```text
Rendering Programmer
├─ Pass와 Buffer 설계
├─ Shader Data Contract
└─ Platform 최적화

Technical Artist
├─ Material Workflow
├─ Shader Graph와 Keyword 관리
└─ Visual 검증

Content Artist
├─ Asset 제작 규칙
├─ Texture Budget
└─ Material 사용 기준
```

Pipeline 변경은 Code에만 영향을 주지 않는다.

Material, Shader, Lighting Setup, Post-processing과 Asset 제작 규칙이 함께 달라질 수 있다.

Pipeline 선택과 Migration을 Project 초기에 결정해야 하는 이유다.

---

## SRP가 자동으로 해결하지 않는 것

SRP를 사용한다고 다음 문제가 자동으로 해결되지는 않는다.

- 낮은 Frame Rate
- 과도한 Overdraw
- 너무 많은 Shader Variant
- 잘못된 Texture Format
- 비효율적인 Material 구성
- 과도한 Realtime Light와 Shadow
- Platform별 Memory 문제

```text
SRP
└─ 문제를 해결할 수 있는 제어 수단 제공

좋은 성능
└─ 올바른 설계 + 측정 + Content Budget + 검증 필요
```

Pipeline이 제공하는 Feature를 모두 켜면 오히려 비용이 커질 수 있다.

SRP는 최적화의 도구이지 최적화 결과 그 자체가 아니다.

---

## SRP가 자동으로 화질을 높이지 않는 이유

화질은 Lighting Model, Shadow, Sampling, Material, Post-processing과 Content Quality의 결과다.

SRP Framework는 어떤 Quality Algorithm을 구현할지 결정하지 않는다.

```text
SRP Framework
        │
        ├─ 단순한 Unlit Pipeline 구현 가능
        ├─ Mobile용 경량 Pipeline 구현 가능
        └─ 고품질 Rendering Pipeline 구현 가능
```

같은 SRP 기반이라도 결과와 요구 Hardware는 크게 다를 수 있다.

따라서 “SRP가 Built-in보다 화질이 좋다”는 문장은 구현과 설정을 생략한 표현이다.

구체적인 Pipeline Feature를 비교해야 한다.

---

## 자주 혼동하는 내용

### SRP는 C#으로 Shader를 작성하는 기능인가?

아니다.

C#은 Render Loop와 Command를 구성하고 Shader는 HLSL로 GPU 계산을 수행한다.

### SRP는 하나의 완성된 Render Pipeline인가?

아니다.

SRP는 Render Pipeline을 구현하기 위한 Framework이며 여러 구현이 존재할 수 있다.

### SRP는 Forward Rendering Path의 다른 이름인가?

아니다.

SRP 구현 내부에서 Forward 또는 Deferred 계열의 경로를 구성할 수 있다.

### SRP를 설치하면 자동으로 활성화되는가?

아니다.

Graphics 또는 Quality Settings에 Render Pipeline Asset을 지정해야 한다.

### ScriptableRenderContext가 Graphics API를 직접 노출하는가?

아니다.

Unity의 저수준 Graphics Architecture에 Rendering Command를 전달하는 추상화된 Interface다.

### SRP를 사용하면 항상 Built-in보다 빠른가?

아니다.

실제 성능은 Pipeline 구현, Feature, Content와 Target Hardware에 따라 달라진다.

### Custom SRP는 Render 함수 하나만 작성하면 완성되는가?

아니다.

Production 환경에서는 Lighting, Shadow, Resource, Camera, Editor, Debug와 Platform 지원이 필요하다.

### Built-in의 CommandBuffer와 SRP는 같은 제어권을 제공하는가?

아니다.

Built-in CommandBuffer는 정해진 Engine Event에 Command를 삽입하고 SRP는 Pipeline Code가 전체 Render Loop 정책을 구성한다.

---

## 전체 구조 다시 연결하기

SRP가 등장한 이유를 한 흐름으로 연결하면 다음과 같다.

```text
Built-in의 고정된 전체 Render Loop
                │
                ├─ Platform별 요구 차이 증가
                ├─ 새로운 Rendering 기술 증가
                ├─ 불필요한 Pass 제거 요구
                └─ Project 전용 순서와 Data 요구
                │
                ▼
Rendering 정책을 C# Code로 이동
                │
                ▼
Scriptable Render Pipeline
├─ RenderPipelineAsset이 설정 저장
├─ RenderPipeline.Render가 진입점
├─ ScriptableRenderContext가 Engine과 연결
├─ CommandBuffer가 Graphics Command 기록
├─ CullingResults로 Visible Data 사용
└─ DrawingSettings와 FilteringSettings로 대상 제어
                │
                ▼
Project 목적에 맞는 Render Loop 구성
                │
                ├─ 필요 Feature 선택
                ├─ Pass와 Resource 순서 제어
                ├─ Shader Contract 정의
                └─ Target Hardware 최적화
```

이 구조의 핵심은 Engine 기능을 버리는 것이 아니다.

Unity의 Rendering 기반을 사용하면서 Pipeline 정책을 Project와 Package가 소유하게 만드는 것이다.

---

## 정리

SRP는 C# Script로 Rendering Command를 예약하고 구성하는 Scriptable Render Pipeline Framework다.

Built-in Render Pipeline은 Engine이 전체 Render Loop를 소유하고 정해진 설정과 Hook을 제공한다.

SRP는 `RenderPipeline.Render()`를 진입점으로 Camera, Culling, Drawing, Shadow, Resource와 Pass 순서를 Pipeline Code에서 구성한다.

```text
RenderPipelineAsset
        │
        ▼
RenderPipeline.Render()
        │
        ▼
ScriptableRenderContext
        │
        ├─ Cull
        ├─ DrawRenderers
        ├─ ExecuteCommandBuffer
        └─ Submit
```

`RenderPipelineAsset`은 설정과 Pipeline Instance 생성 책임을 가지며 `RenderPipeline` Instance는 실제 Frame Rendering을 수행한다.

`ScriptableRenderContext`는 C# Pipeline Code와 Unity의 저수준 Graphics Code를 연결하고 `CommandBuffer`는 Clear, Render Target과 Graphics Command를 기록한다.

SRP의 Scriptable은 Shader를 C#으로 작성한다는 뜻이 아니라 어떤 Shader Pass와 Renderer를 어떤 순서로 처리할지 C#에서 제어한다는 뜻이다.

SRP는 Project별 최적화와 새로운 Rendering 구조를 가능하게 하지만 구현, Shader Contract, Tooling, Platform 검증과 Upgrade 책임을 함께 가져온다.

SRP 자체가 성능이나 화질을 보장하지 않으며 실제 결과는 그 Framework 위에 어떤 Pipeline을 어떻게 구현하고 설정했는지에 따라 달라진다.
