---
title: "[Unity 렌더링] 6-1. Built-in Render Pipeline은 무엇일까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - BuiltInRenderPipeline
  - RenderingPath
  - SurfaceShader
permalink: /programming/unity-6-1-built-in-render-pipeline/
toc: true
toc_sticky: true
date: 2026-08-16
last_modified_at: 2026-08-16
---

Unity가 Scene을 화면에 그리려면 Camera Culling, Shadow, Opaque, Transparent와 Post-processing 같은 작업의 순서를 누군가 정의해야 한다.

Unity의 초기부터 제공되던 기본 Rendering 구조가 Built-in Render Pipeline이다.

```text
Scene
↓
Camera
↓
Built-in Render Loop
├─ Culling
├─ Shadow
├─ Opaque
├─ Skybox
├─ Transparent
└─ Image Effect
↓
Screen
```

Built-in Render Pipeline은 Engine 내부에 미리 구현된 Rendering Loop를 사용한다.

사용자는 Camera와 Quality Setting, Shader Pass, Command Buffer 같은 확장 지점을 이용할 수 있지만 전체 Pipeline 구조를 C#으로 직접 구성하는 방식은 아니다.

---

## Built-in Render Pipeline이란?

Built-in Render Pipeline은 Unity Engine에 내장된 전통적인 Render Pipeline이다.

```text
Built-in
Unity Engine 내부의 미리 정의된 Rendering Loop

Render Pipeline
Scene Data를 Camera Image로 만드는 작업의 흐름
```

대표적인 특징은 다음과 같다.

```text
Render Pipeline Asset 없이 동작
Forward와 Deferred Rendering Path 지원
Surface Shader 지원
ShaderLab의 Legacy LightMode와 GrabPass 지원
Camera Event와 CommandBuffer를 통한 제한적 확장
오랜 기간 축적된 Asset과 Shader 호환성
```

URP와 HDRP도 Unity가 제공하는 Render Pipeline이지만 Scriptable Render Pipeline 기반이라는 점에서 구조가 다르다.

---

## Render Pipeline의 역할

Render Pipeline은 단순히 Shader 하나를 실행하는 기능이 아니다.

한 Frame에서 어떤 Camera를 처리하고, 어떤 Object를 고르며, 어떤 Render Target과 Pass를 어느 순서로 사용할지 관리한다.

```text
Camera 설정
↓
Visible Renderer와 Light 계산
↓
Rendering Path 결정
↓
Shadow Map 생성
↓
Opaque와 Transparent Drawing
↓
Lighting과 Post Effect
↓
Final Image
```

Shader는 각 Draw에서 Vertex와 Fragment를 처리하고 Render Pipeline은 그 Shader Pass를 언제 어떤 Object에 사용할지 결정한다.

---

## Built-in이 활성화되는 조건

Unity Project의 Graphics Settings와 Quality Settings에 Scriptable Render Pipeline Asset이 지정되지 않으면 Built-in Render Pipeline을 사용한다.

```text
Quality Settings
Render Pipeline Asset = None

Graphics Settings
Default Render Pipeline = None

↓
Built-in Render Pipeline 활성
```

URP Asset이나 HDRP Asset을 지정하면 해당 SRP가 활성 Pipeline이 된다.

Quality Level마다 Render Pipeline Asset Override를 가질 수 있으므로 현재 Editor Quality 하나만 확인하지 않는다.

```text
Low Quality
Pipeline Asset = None
→ Built-in

High Quality
Pipeline Asset = URP Asset
→ URP
```

이처럼 Quality별 Pipeline이 다르면 Material과 Shader 호환성을 모두 준비해야 하므로 일반적인 Project에서는 신중하게 구성한다.

---

## Built-in과 Render Pipeline Asset

Built-in은 별도의 Render Pipeline Asset으로 설정을 묶지 않는다.

```text
Built-in 설정 위치
├─ Graphics Settings
├─ Quality Settings
├─ Camera
├─ Lighting Settings
├─ Shader와 Material
└─ Project별 Component
```

URP는 URP Asset과 Renderer Asset에 Shadow, Light, Rendering Path와 Feature 설정을 보관한다.

```text
Built-in
Engine 기본 Loop + 여러 Project Setting

URP / HDRP
SRP Asset이 Pipeline과 품질 구성을 선택
```

설정 Data의 구조가 다르므로 Pipeline을 바꿀 때 단순히 Asset Reference 하나만 교체하면 끝나지 않는다.

---

## Built-in Rendering의 큰 흐름

Camera 하나의 Built-in Rendering을 단순화하면 다음과 같다.

```text
Camera 시작
↓
Frustum과 Occlusion Culling
↓
Visible Light와 Renderer 분류
↓
Camera Rendering Path 선택
↓
Shadow Map Drawing
↓
Opaque Queue Drawing
↓
Skybox
↓
Transparent Queue Drawing
↓
Image Effect
↓
Camera Target 출력
```

정확한 Pass와 Draw 순서는 Forward, Deferred, Camera 설정, Shader와 CommandBuffer Event에 따라 달라진다.

Built-in은 이 핵심 Loop를 Engine 내부에서 수행한다.

---

## Camera 중심 구조

Built-in Render Pipeline은 Camera마다 Scene을 Culling하고 Rendering한다.

```text
Camera A
├─ Culling
├─ Rendering Path
└─ Target A

Camera B
├─ Culling
├─ Rendering Path
└─ Target B
```

Camera의 다음 설정이 결과에 영향을 준다.

```text
Culling Mask
Clear Flags
Depth
Rendering Path
Target Texture
HDR
MSAA
Occlusion Culling
Command Buffer
```

Camera가 늘면 Culling과 Draw가 반복될 수 있다는 기본 비용 구조는 다른 Pipeline과 같다.

---

## Rendering Path란?

Render Pipeline과 Rendering Path는 같은 개념이 아니다.

```text
Render Pipeline
Frame Rendering 전체 구조
예: Built-in, URP, HDRP

Rendering Path
Lighting과 Geometry를 처리하는 세부 방식
예: Forward, Deferred
```

Built-in Render Pipeline 안에서 Camera는 Forward 또는 Deferred Rendering Path를 사용할 수 있다.

Legacy Vertex Lit Path도 존재하지만 현대적인 기능 지원이 제한적이다.

```text
Built-in Render Pipeline
├─ Forward Rendering Path
├─ Deferred Rendering Path
└─ Vertex Lit Rendering Path
```

---

## Camera의 Rendering Path 설정

Camera Inspector에서 Rendering Path를 지정할 수 있다.

```text
Use Graphics Settings
Project 기본 Rendering Path 사용

Forward
해당 Camera를 Forward로 Rendering

Deferred
해당 Camera를 Deferred로 Rendering

Vertex Lit
Legacy Vertex Lighting
```

Project Graphics Setting의 기본값을 사용하면서 특정 Camera만 다른 Path를 선택할 수 있다.

Platform이나 Camera Feature가 선택한 Path를 지원하지 않으면 Unity가 다른 Path로 대체할 수 있으므로 Frame Debugger에서 실제 결과를 확인한다.

---

## Built-in Forward Rendering

Built-in Forward Path는 Object를 그릴 때 Surface에 영향을 주는 Light를 계산한다.

```text
Renderer
↓
ForwardBase Pass
Main Light + Ambient + Lightmap 등
↓
ForwardAdd Pass
추가 Per-pixel Light
↓
Framebuffer
```

Object에 영향을 주는 Per-pixel Light가 많으면 추가 Light마다 Geometry를 다시 그리는 Multi Pass가 발생할 수 있다.

```text
Object 1개
Main Light 1개
Additional Pixel Light 3개
↓
Base Pass 1회
+ Add Pass 최대 3회 가능
```

Light 수와 Pixel Light 설정이 Draw와 Overdraw에 영향을 준다.

---

## ForwardBase Pass

Built-in Forward Shader는 `ForwardBase` LightMode Pass를 사용할 수 있다.

```shaderlab
Pass
{
    Tags
    {
        "LightMode" = "ForwardBase"
    }

    // Main Forward Lighting Program
}
```

이 Pass는 대표적으로 Main Directional Light, Ambient, Lightmap과 Vertex Light 관련 Data를 처리할 수 있다.

정확한 Keyword와 Lighting Data는 Shader 구현 및 Built-in Macro에 따라 달라진다.

URP의 `UniversalForward`와 이름 및 Include 구조가 다르다.

---

## ForwardAdd Pass

추가 Per-pixel Light는 `ForwardAdd` Pass로 누적할 수 있다.

```shaderlab
Pass
{
    Tags
    {
        "LightMode" = "ForwardAdd"
    }

    Blend One One

    // One Additional Light Program
}
```

Additive Blend로 추가 Light Contribution을 기존 Color에 더한다.

```text
Base Color
+ Light A
+ Light B
+ Light C
= Final Lighting
```

URP는 Built-in의 `ForwardAdd` LightMode를 지원하지 않는다.

Pipeline을 바꿀 때 Built-in Custom Shader를 그대로 사용할 수 없는 대표적인 이유다.

---

## Built-in Deferred Rendering

Deferred Path는 먼저 Opaque Surface Data를 G-buffer에 기록한 뒤 Screen Space에서 Light를 계산한다.

```text
Opaque Geometry
↓
G-buffer
├─ Albedo
├─ Normal
├─ Material Data
└─ Depth
↓
Light Volume / Full-screen Lighting
↓
Camera Color
```

많은 Light가 같은 Opaque Object에 영향을 줄 때 Geometry를 Light마다 반복 Drawing하지 않고 G-buffer를 이용할 수 있다.

대신 여러 Render Target의 Memory와 Bandwidth를 사용한다.

Transparent Object와 일부 Shader는 별도 Forward Path로 처리될 수 있다.

---

## Deferred의 제한

G-buffer에 저장할 수 있는 Material Data 형식이 정해져 있다.

```text
장점 가능성
많은 Real-time Light 처리
Lighting과 Geometry 분리

비용과 제한
G-buffer Memory Bandwidth
MSAA 제약
Transparent는 Forward 처리
Custom Lighting Model 표현 제한
낮은 사양 GPU 부담
```

Built-in Deferred가 항상 Forward보다 빠른 것은 아니다.

Light 수, 해상도, Overdraw, GPU Architecture와 Platform을 측정해야 한다.

---

## Vertex Lit Rendering Path

Vertex Lit은 Legacy Rendering Path다.

Lighting을 주로 Vertex 단위로 계산하고 Fragment로 보간한다.

```text
Vertex Lighting
↓
Triangle 내부 Interpolation
↓
Fragment Color
```

Per-pixel Lighting보다 연산을 줄일 수 있지만 큰 Triangle에서는 Light 변화가 거칠게 보일 수 있다.

Real-time Shadow 등 현대적인 Rendering Feature 지원도 제한적이다.

새로운 고품질 Project의 일반적인 선택으로 보기보다 Legacy Content 호환 관점에서 이해한다.

---

## Built-in Shader 종류

Built-in Render Pipeline은 전통적인 Standard, Unlit, Legacy와 Mobile 계열 Shader를 제공한다.

```text
Standard
Physically based Metallic Workflow

Standard Specular Setup
Specular Color Workflow

Unlit
Lighting 없이 Texture와 Color 중심

Legacy / Mobile
이전 기능과 저비용 표현
```

Shader가 Built-in Lighting, Shadow와 Fog Keyword를 지원하도록 작성되어 있다.

URP Lit Shader와 Property 이름이나 Lighting Model이 비슷해 보여도 내부 Pass는 다르다.

---

## Standard Shader

Standard Shader는 Built-in의 대표적인 Physically Based Shader다.

```text
Surface Input
├─ Albedo
├─ Metallic 또는 Specular
├─ Smoothness
├─ Normal Map
├─ Occlusion
└─ Emission
↓
Built-in Lighting
```

Material Keyword로 Normal Map, Emission과 Transparency Mode 등의 Variant를 선택한다.

기능이 많은 Uber Shader라서 Material 상태와 Build Variant를 관리해야 한다.

---

## Surface Shader란?

Surface Shader는 Built-in Render Pipeline 전용 Shader 작성 방식이다.

사용자가 Surface Property 계산을 작성하면 Unity가 Lighting과 Shadow를 처리할 여러 Pass의 Vertex·Fragment Code를 생성한다.

```text
Surface Function 작성
↓
Unity Shader Compiler
├─ ForwardBase Pass 생성
├─ ForwardAdd Pass 생성
├─ Deferred Pass 생성
├─ ShadowCaster Pass 생성
└─ Meta Pass 생성
```

복잡한 Built-in Lighting Boilerplate를 직접 작성하지 않고 Surface 표현에 집중할 수 있다.

URP와 HDRP는 Surface Shader를 지원하지 않는다.

---

## Surface Shader 예제

```shaderlab
Shader "Custom/BuiltInSurface"
{
    Properties
    {
        _MainTex("Albedo", 2D) = "white" {}
        _Color("Color", Color) = (1, 1, 1, 1)
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
        }

        CGPROGRAM
        #pragma surface Surf Standard fullforwardshadows

        sampler2D _MainTex;
        fixed4 _Color;

        struct Input
        {
            float2 uv_MainTex;
        };

        void Surf(Input input, inout SurfaceOutputStandard output)
        {
            fixed4 sampleColor = tex2D(_MainTex, input.uv_MainTex);
            output.Albedo = sampleColor.rgb * _Color.rgb;
            output.Alpha = sampleColor.a * _Color.a;
        }
        ENDCG
    }
}
```

`#pragma surface`가 Built-in Lighting에 필요한 Shader Pass를 생성한다.

같은 Code를 URP Shader에 복사해 사용할 수는 없다.

---

## Vertex·Fragment Shader 직접 작성

Built-in에서도 ShaderLab Pass 안에 Vertex와 Fragment Program을 직접 작성할 수 있다.

```shaderlab
Pass
{
    CGPROGRAM
    #pragma vertex Vert
    #pragma fragment Frag

    #include "UnityCG.cginc"

    // ...
    ENDCG
}
```

Built-in의 `UnityCG.cginc`, `Lighting.cginc`, `AutoLight.cginc` 같은 Include와 Macro를 사용할 수 있다.

URP의 `Core.hlsl`, `Lighting.hlsl`과 함수 이름 및 Data 구조가 다르다.

Custom Lighting과 Screen Effect를 세밀하게 제어할 수 있지만 Pass와 Keyword를 직접 관리해야 한다.

---

## CGPROGRAM과 HLSLPROGRAM

오래된 Built-in Shader 예제는 `CGPROGRAM`과 Cg 용어를 많이 사용한다.

Unity의 Shader Compiler는 실제 Platform Shader Code로 Cross Compile한다.

```text
Shader Source
↓
Unity Shader Compiler
↓
Direct3D / Metal / Vulkan / OpenGL용 Program
```

현대 Unity에서는 HLSL 문법과 `HLSLPROGRAM`도 사용할 수 있지만 Include와 Built-in Macro 호환을 확인해야 한다.

용어가 Cg라고 해서 GPU가 Cg Runtime을 직접 실행한다는 뜻은 아니다.

---

## Built-in LightMode

Built-in Shader Pass는 다음과 같은 `LightMode`를 사용할 수 있다.

```text
ForwardBase
Forward Main Lighting

ForwardAdd
Additional Pixel Light

Deferred
G-buffer 기록

ShadowCaster
Shadow Map Depth

Meta
Lightmap Baking

Always
특정 일반 Pass
```

URP의 `UniversalForward`, `UniversalGBuffer`, `DepthOnly`와 다른 Naming Convention이다.

Pipeline마다 Renderer가 요청하는 ShaderTag가 다르다.

---

## Built-in의 Shadow

Light가 Real-time Shadow를 만들면 Shadow Caster를 Light 관점에서 그린다.

```text
Light Culling
↓
Renderer의 ShadowCaster Pass
↓
Shadow Map
↓
Forward 또는 Deferred Lighting에서 Sample
```

Surface Shader는 ShadowCaster Pass를 생성할 수 있고 직접 작성한 Shader는 적절한 Pass나 Fallback이 필요하다.

Alpha Clip, Vertex Animation과 Double-sided Surface는 Camera Color와 Shadow Pass의 Geometry가 일치해야 한다.

---

## Built-in의 Light 선택

Built-in Forward는 Object에 영향을 주는 Light를 중요도와 Render Mode 등에 따라 Per-pixel, Per-vertex 또는 Spherical Harmonics 방식으로 분류할 수 있다.

```text
Important Light
Per-pixel 후보

Not Important Light
Per-vertex 또는 저비용 처리 후보
```

Quality Settings의 Pixel Light Count도 영향을 준다.

Object와 Light 수가 늘면 어떤 Light가 Pixel로 처리되는지 Frame마다 바뀌며 Popping이 보일 수 있다.

Light Render Mode와 범위를 의도적으로 설정한다.

---

## Pixel Light Count

Built-in Quality Settings의 Pixel Light Count는 Forward Rendering에서 동시에 Per-pixel로 처리할 Light 수에 영향을 준다.

```text
Pixel Light Count 증가
Lighting 품질 증가 가능
ForwardAdd Pass와 Draw 증가 가능

Pixel Light Count 감소
일부 Light가 Vertex 또는 SH 처리
품질 저하 가능
```

Deferred Path에서는 Light 처리 구조가 다르므로 같은 설정의 영향이 동일하지 않다.

Target Hardware와 Scene Light 밀도를 기준으로 정한다.

---

## Render Queue와 Sorting

Built-in은 Material의 Render Queue로 Object를 큰 Group에 나눈다.

```text
Background 1000
Geometry 2000
AlphaTest 2450
Transparent 3000
Overlay 4000
```

Queue 2500 이하의 Opaque 계열은 Front-to-back Sorting을, 2501 이상의 Transparent 계열은 Back-to-front 성격의 Sorting을 사용한다.

이전 글에서 다룬 Queue와 Sorting 개념의 전통적인 기준이 Built-in Render Pipeline 문서에 명시되어 있다.

---

## Camera Clear Flags

Built-in Camera는 Clear Flags로 Camera Target 시작 상태를 정한다.

```text
Skybox
Background를 Skybox로 채움

Solid Color
Color와 Depth를 지정 값으로 Clear

Depth Only
Color를 유지하고 Depth 중심 Clear

Don't Clear
이전 Buffer 내용 유지
```

여러 Camera를 Depth 순서로 겹쳐 그리는 전통적인 Camera Stacking 효과에 사용할 수 있다.

URP의 Base·Overlay Camera Stack과 설정 구조는 다르다.

---

## Camera Depth

Built-in Camera의 `Depth` 값은 여러 Camera의 Rendering 순서에 영향을 준다.

```text
Camera Depth -1
먼저 Rendering

Camera Depth 0
나중에 Rendering
```

앞 Camera의 Color를 유지하고 뒤 Camera가 Depth만 Clear하면 특정 Layer를 겹칠 수 있다.

Camera가 늘면 Culling, Draw와 Post Effect가 반복될 수 있으므로 단순 Layering을 위해 과도하게 사용하지 않는다.

---

## Command Buffer 확장

Built-in은 Camera와 Light의 특정 Event에 `CommandBuffer`를 삽입할 수 있다.

```text
CameraEvent.BeforeDepthTexture
CameraEvent.AfterDepthTexture
CameraEvent.BeforeForwardOpaque
CameraEvent.AfterForwardOpaque
CameraEvent.BeforeImageEffects
CameraEvent.AfterEverything
```

정확한 Event 목록은 Rendering Path에 따라 다를 수 있다.

CommandBuffer로 Custom Render Target, DrawMesh, Blit와 Global Texture 설정을 추가할 수 있다.

Pipeline 전체 순서를 새로 정의하는 것이 아니라 Engine이 제공한 Hook에 Command를 넣는 방식이다.

---

## Command Buffer 예제 구조

```csharp
using UnityEngine;
using UnityEngine.Rendering;

public class BuiltInCommandBufferExample : MonoBehaviour
{
    [SerializeField] private Camera targetCamera;

    private CommandBuffer commandBuffer;

    private void OnEnable()
    {
        commandBuffer = new CommandBuffer
        {
            name = "Custom Built-in Commands"
        };

        // Draw, Blit, SetGlobalTexture 등을 기록

        targetCamera.AddCommandBuffer(
            CameraEvent.AfterForwardOpaque,
            commandBuffer
        );
    }

    private void OnDisable()
    {
        if (commandBuffer == null)
        {
            return;
        }

        targetCamera.RemoveCommandBuffer(
            CameraEvent.AfterForwardOpaque,
            commandBuffer
        );

        commandBuffer.Release();
        commandBuffer = null;
    }
}
```

추가한 Buffer를 제거하고 Release하지 않으면 중복 실행과 Resource 문제가 생길 수 있다.

---

## Image Effect

Built-in에서는 Camera Component의 `OnRenderImage` Callback을 이용한 Image Effect가 널리 사용되었다.

```text
Camera Scene Color
↓
OnRenderImage(source, destination)
↓
Graphics.Blit + Effect Material
↓
Final Camera Target
```

```csharp
private void OnRenderImage(RenderTexture source, RenderTexture destination)
{
    Graphics.Blit(source, destination, effectMaterial);
}
```

Effect가 여러 개면 Component 순서와 Intermediate Render Texture가 늘 수 있다.

URP에서는 `OnRenderImage` 대신 Renderer Feature와 Scriptable Render Pass 계열 확장 방식을 사용한다.

---

## GrabPass

Built-in ShaderLab의 `GrabPass`는 현재 Framebuffer 내용을 Texture로 가져와 Shader에서 Sample할 수 있게 한다.

```text
Opaque Scene Color
↓
GrabPass
↓
Glass Shader가 Background Sample
↓
Refraction
```

Object마다 unnamed GrabPass를 실행하면 Screen Copy 비용이 반복될 수 있다.

이름 있는 Grab Texture 공유나 Camera CommandBuffer 방식으로 Copy 횟수를 줄일 수 있다.

URP는 GrabPass를 지원하지 않고 Camera Opaque Texture 또는 Renderer Feature를 사용한다.

---

## Built-in Post-processing

Built-in은 별도 Post-processing Package와 `OnRenderImage` Effect를 사용할 수 있다.

```text
Camera HDR Color
↓
Bloom
↓
Color Grading
↓
Tone Mapping
↓
Anti-aliasing
↓
Final Target
```

Camera마다 Post-process Layer와 Volume 관계를 설정하는 Workflow가 사용되었다.

URP와 HDRP는 Pipeline에 통합된 Volume 기반 Post-processing 구성을 가진다.

Package Version과 Unity Version 호환성을 확인해야 한다.

---

## Built-in의 Batching

Built-in은 Static Batching, Dynamic Batching과 GPU Instancing을 사용할 수 있다.

```text
Static Batching
움직이지 않는 Mesh 결합 경로

Dynamic Batching
작은 Mesh를 CPU에서 변환해 결합

GPU Instancing
같은 Mesh와 Material Instance를 한 Draw로 처리
```

SRP Batcher는 Scriptable Render Pipeline용이므로 Built-in에서 지원되지 않는다.

Built-in Shader 최적화에서는 Material 공유, Instancing과 Render State 변경 감소를 사용한다.

---

## Built-in의 SetPass 비용

Built-in Render Loop에서도 Material과 Shader Pass가 바뀌면 Program과 Render State를 설정해야 한다.

```text
Shader A ForwardBase
→ Draw Group A

Shader B ForwardBase
→ SetPass 변경
→ Draw Group B
```

ForwardAdd Pass, ShadowCaster와 Image Effect가 늘면 Draw와 SetPass가 함께 늘 수 있다.

Game View Stats와 Frame Debugger에서 Batches, Saved by Batching과 SetPass를 확인한다.

---

## Built-in Frame Debugger

Frame Debugger는 Built-in의 Pass 실행 순서를 확인하는 데 유용하다.

```text
Camera.Render
├─ Clear
├─ Shadow Map
├─ Draw Opaque
│  ├─ ForwardBase
│  └─ ForwardAdd
├─ Skybox
├─ Draw Transparent
└─ Image Effect
```

각 Event에서 Mesh, Material, Shader Pass, Light와 Render Target을 볼 수 있다.

ForwardAdd가 예상보다 많거나 GrabPass Copy가 반복되는 문제를 찾을 수 있다.

---

## Built-in Profiler

CPU Profiler의 Rendering Module과 Timeline으로 Camera Rendering, Culling, Batches와 Render Thread 시간을 확인한다.

GPU Profiler에서는 Shadow, Opaque, Transparent와 Image Effect 비용을 확인한다.

```text
CPU 병목 후보
많은 Draw와 SetPass
많은 Camera
Skinned Mesh
Dynamic Batching 변환

GPU 병목 후보
ForwardAdd Overdraw
많은 Shadow
Transparent
Image Effect
높은 해상도
```

Editor Overhead를 제외하기 위해 목표 Player Build에서도 측정한다.

---

## Built-in의 장점

기존 Project에서 Built-in을 유지할 이유가 있을 수 있다.

```text
오랜 기간 검증된 기존 Asset과 Custom Shader
Surface Shader Workflow
Built-in 전용 Asset Store Package
GrabPass와 OnRenderImage 의존 기능
Pipeline Migration 비용 회피
Legacy Platform과 Tool Chain 호환
```

이미 완성된 대규모 Project를 URP로 옮기면 Material, Shader, Lighting, Post Effect와 Custom Tool을 다시 검증해야 한다.

Migration 이점보다 위험이 크다면 Built-in 유지가 합리적일 수 있다.

---

## Built-in의 한계

Built-in은 Engine 내부 Loop를 사용하므로 Pipeline 전체를 Project 요구에 맞게 재구성하는 범위가 제한적이다.

```text
Pipeline Core Source를 직접 수정하기 어려움
CommandBuffer Hook 위치에 의존
현대 URP/HDRP 전용 Feature 사용 불가
SRP Batcher 사용 불가
Surface Shader와 Legacy Include에 대한 의존
Pipeline별 Shader 호환성 분리
```

Custom Deferred Layout, 새로운 Light Culling과 Render Graph 기반 Resource Scheduling 같은 큰 구조 변경에는 SRP 기반 Pipeline이 적합하다.

SRP가 등장한 배경은 다음 글에서 다룬다.

---

## Built-in과 URP Shader 호환성

Built-in Shader와 URP Shader는 ShaderLab 문법을 공유하지만 Pipeline Contract가 다르다.

```text
Built-in
ForwardBase / ForwardAdd / Deferred
UnityCG.cginc
Surface Shader

URP
UniversalForward / UniversalGBuffer
URP ShaderLibrary HLSL
SRP Batcher CBUFFER
```

Built-in Standard Material을 URP Project에 그대로 두면 Pink Error Material이 나타날 수 있다.

URP Upgrade Tool이나 대응 Shader로 Material을 변환하고 Custom Shader는 직접 Porting해야 한다.

---

## URP Shader를 Built-in에서 사용할 수 있을까?

URP Shader의 SubShader에는 다음 Tag가 있다.

```shaderlab
Tags
{
    "RenderPipeline" = "UniversalPipeline"
}
```

Built-in은 URP의 Renderer와 `UniversalForward` Pass를 실행하지 않는다.

URP Package Include와 Pipeline Global Data도 준비되지 않는다.

하나의 Shader Asset에 Built-in용 SubShader와 URP용 SubShader를 별도로 넣는 구조는 가능할 수 있지만 유지 보수와 Feature 동기화 비용이 크다.

일반적으로 Target Pipeline별 Shader를 명확히 관리한다.

---

## Pipeline 전환 비용

Project 중간에 Built-in에서 URP나 HDRP로 전환하면 다음 항목을 검토해야 한다.

```text
Material Shader 변환
Custom Shader Porting
Post-processing 교체
Camera Stack과 CommandBuffer 재구성
Lighting 결과 재검증
Shadow와 Color 차이
Particle와 VFX 호환
Third-party Asset 지원
Performance 재측정
```

Render Pipeline은 Project 초기에 선택하는 편이 좋다.

개발 후반의 전환은 단순한 Graphics Setting 변경이 아니라 Rendering System Migration에 가깝다.

---

## Built-in을 선택할 수 있는 경우

다음과 같은 Project는 Built-in 유지 또는 선택을 검토할 수 있다.

```text
Built-in 전용 Legacy Asset이 핵심
Surface Shader가 대량으로 존재
이미 안정화된 장기 운영 Project
특정 Built-in Image Effect와 Plugin 의존
Migration Budget이 부족
기존 Visual 결과 보존이 최우선
```

새 Project에서는 Unity Version의 공식 Pipeline Feature Comparison과 지원 방향, Target Platform 및 팀 경험을 확인한다.

단순히 익숙하다는 이유만으로 장기 유지 비용을 무시하지 않는다.

---

## Built-in이 가벼운 Pipeline인가?

Pipeline 이름만으로 성능을 단정할 수 없다.

```text
Built-in Forward
Light가 많으면 ForwardAdd Draw 증가

Built-in Deferred
G-buffer Bandwidth 증가

URP
설정에 따라 Feature와 Pass 수 변화
```

단순한 Built-in Unlit Project가 무거운 URP 설정보다 빠를 수 있고 잘 최적화된 URP가 복잡한 Built-in Project보다 빠를 수도 있다.

같은 Scene과 목표 Platform에서 품질을 맞춘 뒤 측정한다.

---

## Built-in이 오래되었으니 나쁜가?

오래된 구조라는 사실만으로 모든 Project에 나쁜 선택은 아니다.

안정적인 기존 Content와 Tool이 큰 가치를 가질 수 있다.

하지만 새 Graphics Feature와 Unity의 개발 투자는 SRP 기반 Pipeline을 중심으로 제공되는 경우가 많다.

```text
기존 Project
Migration Risk와 실제 이점 비교

새 Project
장기 지원, Feature와 팀 Workflow 비교
```

기술 선택은 현재 요구와 유지 기간을 기준으로 한다.

---

## Built-in 최적화 기준

Built-in Project에서는 Rendering Path와 Scene 특성부터 확인한다.

```text
Forward
Pixel Light Count와 ForwardAdd Pass

Deferred
G-buffer Bandwidth와 Light Volume

공통
Shadow Caster와 Cascade
Camera 수
Material와 SetPass
Transparent Overdraw
Image Effect Chain
```

Frame Debugger로 실제 Pass를 확인하고 CPU·GPU Profiler로 병목을 구분한다.

URP 최적화 지침을 Built-in에 그대로 적용하지 않고 지원되는 Batching과 Setting을 사용한다.

---

## Forward 최적화

Built-in Forward가 느리면 다음 항목을 확인한다.

```text
Object당 Pixel Light 수
ForwardAdd Draw 수
Light Range와 Culling Mask
Shadow Light 수
Opaque Front-to-back
Transparent Overdraw
Shader Variant와 SetPass
```

중요하지 않은 Light를 Per-vertex 처리하거나 Baked Lighting으로 전환할 수 있다.

Visual 요구를 만족하는 범위에서 Pixel Light Count와 Shadow를 조정한다.

---

## Deferred 최적화

Built-in Deferred가 느리면 다음 항목을 확인한다.

```text
Screen Resolution
G-buffer Format와 Bandwidth
MSAA 요구
화면을 덮는 Light Volume
Transparent Forward Pass
Post-processing
```

Light가 적은 Scene에서는 Deferred의 G-buffer 비용이 이점보다 클 수 있다.

많은 작은 Light가 있는 Scene에서는 ForwardAdd 반복보다 Deferred가 유리할 수 있다.

Target GPU Architecture에 따라 결과가 달라진다.

---

## CommandBuffer 최적화

Built-in 확장을 위해 추가한 CommandBuffer는 Frame마다 중복 등록되지 않는지 확인한다.

```text
OnEnable마다 Add
하지만 OnDisable에서 Remove하지 않음
↓
중복 CommandBuffer 가능
```

Temporary RenderTexture의 해상도와 Format, Release 시점을 관리한다.

같은 Screen Copy를 Object마다 반복하지 않고 Camera 단위로 한 번 생성해 공유할 가능성을 검토한다.

---

## Built-in 문제 진단 순서

Material이 Pink로 보이거나 Object가 Rendering되지 않으면 다음을 확인한다.

```text
1. 현재 Active Render Pipeline
↓
2. Shader가 Built-in용인지 확인
↓
3. SubShader와 Pass Compile Error
↓
4. Camera Rendering Path
↓
5. LightMode Pass
↓
6. Material Queue와 Render State
↓
7. Frame Debugger Event
↓
8. Platform Shader Compile Log
```

URP Asset이 Quality Setting 일부에 남아 있으면 Editor Quality 변경에 따라 Pipeline이 바뀔 수 있다.

Graphics와 모든 Quality Level을 확인한다.

---

## Active Pipeline 확인 예제

현재 SRP Asset이 설정되어 있는지 C#에서 확인할 수 있다.

```csharp
using UnityEngine;
using UnityEngine.Rendering;

public class ActivePipelineReport : MonoBehaviour
{
    private void Start()
    {
        RenderPipelineAsset currentAsset =
            GraphicsSettings.currentRenderPipeline;

        if (currentAsset == null)
        {
            Debug.Log("Built-in Render Pipeline");
        }
        else
        {
            Debug.Log($"SRP: {currentAsset.GetType().Name}");
        }
    }
}
```

`null`이면 Built-in이 활성인 것으로 판단할 수 있다.

Editor와 Runtime에서 Quality Level이 바뀔 가능성도 고려한다.

---

## Frame Debugger에서 확인할 항목

Built-in Frame을 열고 다음 질문에 답한다.

```text
Camera가 Forward인가 Deferred인가?
ForwardAdd Pass가 Object마다 몇 번 실행되는가?
Shadow Map Draw가 몇 개인가?
AlphaTest와 Transparent 순서는 올바른가?
GrabPass Copy가 반복되는가?
Image Effect Blit가 몇 단계인가?
SetPass가 자주 바뀌는가?
```

Stats 숫자만 보는 것보다 어떤 기능이 Event를 만들었는지 알 수 있다.

---

## 자주 혼동하는 내용

### Built-in은 Rendering Path 이름인가?

아니다.

Built-in은 Render Pipeline이고 그 안에서 Forward, Deferred 또는 Legacy Vertex Lit Path를 선택한다.

### Render Pipeline Asset을 만들면 Built-in을 설정할 수 있다?

Built-in은 별도의 Pipeline Asset을 사용하지 않는다.

Graphics와 Quality Setting에 SRP Asset이 없을 때 활성화된다.

### Built-in Shader는 URP에서 그대로 동작한다?

아니다.

LightMode, Include, Global Data와 Lighting Contract가 달라 Porting이 필요하다.

### Surface Shader는 모든 Pipeline에서 사용할 수 있다?

아니다.

Surface Shader는 Built-in Render Pipeline용 Workflow다.

### Built-in Forward는 Object를 항상 한 번만 그린다?

아니다.

추가 Per-pixel Light마다 ForwardAdd Pass가 실행될 수 있다.

### CommandBuffer로 Built-in 전체 Pipeline을 자유롭게 바꿀 수 있다?

아니다.

Engine이 제공하는 Camera와 Light Event Hook에 Command를 삽입하는 구조다.

### Built-in은 항상 URP보다 빠르다?

아니다.

Rendering Path, Light, Shadow, Shader, Platform과 Pipeline 설정에 따라 달라진다.

### Built-in은 기존 Project에서도 반드시 교체해야 한다?

아니다.

Migration 비용과 장기 지원, 필요한 Feature 및 실제 성능 이점을 비교해야 한다.

---

## 전체 구조 다시 연결하기

Built-in Render Pipeline의 큰 구조는 다음과 같다.

```text
Render Pipeline Asset 없음
↓
Built-in 활성
↓
Camera
├─ Culling
├─ Rendering Path 선택
│  ├─ Forward
│  │  ├─ ForwardBase
│  │  └─ ForwardAdd
│  ├─ Deferred
│  │  ├─ G-buffer
│  │  └─ Deferred Lighting
│  └─ Vertex Lit
├─ ShadowCaster
├─ Opaque / Transparent Queue
├─ CommandBuffer Event
└─ Image Effect
↓
Camera Target
```

Engine이 전체 Loop를 소유하고 Shader, Camera Setting과 제한된 Hook을 통해 동작을 구성한다.

---

## 정리

Built-in Render Pipeline은 Unity Engine에 내장된 전통적인 Rendering Pipeline이다.

Graphics와 Quality Settings에 Scriptable Render Pipeline Asset이 지정되지 않으면 Built-in이 활성화된다.

```text
Built-in Render Pipeline
├─ Forward Rendering Path
├─ Deferred Rendering Path
└─ Legacy Vertex Lit Path
```

Forward Path는 `ForwardBase`와 추가 Light용 `ForwardAdd` Pass로 Object를 여러 번 그릴 수 있고 Deferred Path는 Opaque Surface를 G-buffer에 기록한 뒤 Lighting을 계산한다.

Built-in은 Standard Shader와 Surface Shader, Legacy ShaderLab LightMode, GrabPass, Camera Event CommandBuffer와 `OnRenderImage` Workflow를 지원한다.

전체 Render Loop는 Engine 내부에 고정되어 있으며 사용자는 Camera 설정, Shader Pass와 제공된 Hook을 통해 확장한다.

URP와 HDRP는 SRP 기반으로 LightMode, Shader Include, Material, Post-processing과 Custom Rendering 구조가 달라 Built-in Asset을 그대로 호환하지 않을 수 있다.

기존 Project에서는 Asset과 Visual 안정성 및 Migration 비용을 고려하고 새 Project에서는 공식 Feature Comparison, 장기 지원 방향, Target Platform과 팀 Workflow를 기준으로 Pipeline을 선택해야 한다.

Frame Debugger로 ForwardAdd, Shadow, Queue와 Image Effect Pass를 확인하고 CPU·GPU Profiler로 목표 Device의 실제 병목을 측정해야 한다.
