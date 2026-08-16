---
title: "[Unity 렌더링] 4-7. Shader의 Pass란 무엇일까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - ShaderPass
  - RenderState
  - MultiPass
permalink: /programming/unity-4-7-shader-pass/
toc: true
toc_sticky: true
date: 2026-08-15
last_modified_at: 2026-08-15
---

Shader는 GPU가 실행할 Program만 정의하지 않는다.

어떤 Render Pipeline 단계에서 그 Program을 사용하고, Triangle의 앞면을 제거할지, Depth를 기록할지, 기존 Color와 어떻게 섞을지도 함께 정해야 한다.

Unity의 ShaderLab에서 이 한 묶음을 `Pass`로 표현한다.

```text
Pass
├─ 목적과 선택 조건
├─ Render State
└─ GPU Program
```

하나의 Material이 화면의 Color를 그릴 때와 Shadow Map을 만들 때는 필요한 출력과 상태가 다르다.

그래서 하나의 Shader 안에도 역할이 다른 여러 Pass가 존재할 수 있다.

---

## Pass란?

ShaderLab의 Pass는 Object를 한 가지 목적과 설정으로 그리기 위한 렌더링 단위다.

가장 단순한 구조는 다음과 같다.

```shaderlab
Shader "Custom/SimplePass"
{
    SubShader
    {
        Pass
        {
            Name "ForwardLit"

            Tags
            {
                "LightMode" = "UniversalForward"
            }

            Cull Back
            ZWrite On
            ZTest LEqual

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            // HLSL Code
            ENDHLSL
        }
    }
}
```

이 Pass에는 다음 정보가 들어 있다.

| 구성 요소 | 역할 |
|---|---|
| `Name` | 다른 ShaderLab 명령에서 Pass를 식별하는 이름 |
| `Tags` | Render Pipeline이 Pass의 용도를 판단하는 Metadata |
| Render State | Cull, Depth, Blend, Stencil 같은 GPU 상태 |
| `HLSLPROGRAM` | Vertex·Fragment Shader 등 GPU가 실행할 Program |

Pass는 HLSL 함수 하나를 의미하지 않는다.

Shader Program과 그 Program을 실행할 때 필요한 상태 및 Pipeline상의 역할을 묶은 단위다.

---

## ShaderLab 구조에서 Pass의 위치

Unity Shader의 대표적인 계층은 다음과 같다.

```text
Shader
└─ SubShader
   ├─ Tags
   ├─ Pass A
   ├─ Pass B
   └─ Pass C
```

각 계층은 서로 다른 역할을 가진다.

```text
Shader
Property와 여러 SubShader를 포함하는 Asset

SubShader
특정 Render Pipeline과 Hardware 조건에 맞는 구현 묶음

Pass
특정 렌더링 목적에 사용할 Program과 State
```

URP용 SubShader는 일반적으로 다음 Tag를 가진다.

```shaderlab
SubShader
{
    Tags
    {
        "RenderPipeline" = "UniversalPipeline"
        "RenderType" = "Opaque"
        "Queue" = "Geometry"
    }

    Pass
    {
        // ...
    }
}
```

SubShader의 `Queue`는 Object가 어느 Render Queue에 속하는지 정한다.

Pass의 `LightMode`는 Pipeline이 어떤 렌더링 단계에서 그 Pass를 선택할지 나타낸다.

```text
Queue
Object 사이의 큰 렌더링 순서

LightMode
Object 내부의 어느 Pass가 현재 단계에 필요한지 구분
```

둘은 관련되어 있지만 같은 기능은 아니다.

---

## Pass는 Shader Stage가 아니다

Pass와 Vertex Shader, Fragment Shader를 혼동하기 쉽다.

```text
Pass
├─ Vertex Shader
├─ Fragment Shader
└─ Render State
```

Vertex Shader와 Fragment Shader는 Graphics Pipeline 안에서 실행되는 Stage다.

Pass는 어떤 Stage Program을 사용할지와 고정 기능 상태를 함께 정의한다.

```shaderlab
HLSLPROGRAM
#pragma vertex Vert
#pragma fragment Frag
ENDHLSL
```

위 코드는 `Vert`를 Vertex Entry Point로, `Frag`를 Fragment Entry Point로 지정한다.

이 두 함수가 Pass 전체와 같은 것은 아니다.

같은 HLSL 함수라도 서로 다른 Pass에서 다른 Blend나 Depth State와 함께 사용할 수 있다.

---

## Pass가 Draw와 연결되는 과정

Scene에 Renderer와 Material이 있다고 해서 Shader 파일의 모든 Pass가 무조건 위에서 아래로 한 번씩 실행되지는 않는다.

URP는 현재 렌더링 단계에 맞는 Pass를 찾는다.

```text
URP의 현재 단계
↓
Renderer의 Material 확인
↓
LightMode가 맞는 Pass 선택
↓
Pass의 Program과 Render State 적용
↓
Geometry 제출
↓
Draw 수행
```

예를 들어 Camera Color를 그리는 단계와 Shadow Map을 만드는 단계는 서로 다른 Pass를 선택할 수 있다.

```text
Main Camera Color
→ UniversalForward Pass

Light Shadow Map
→ ShadowCaster Pass

Camera Depth Texture
→ DepthOnly Pass
```

실제로 선택된 Pass는 Geometry 처리와 Rasterization을 위한 Draw 작업을 만든다.

다만 Pass 하나와 Profiler에 보이는 Draw Call 하나가 모든 상황에서 항상 정확히 1:1이라고 단정할 수는 없다.

SubMesh, Camera, Shadow Cascade, GPU Instancing, Batching, Render Pipeline 구현에 따라 제출되는 Draw 수가 달라질 수 있기 때문이다.

```text
Pass
렌더링 방법의 정의

Draw Call
특정 Geometry와 Resource를 사용해 그 방법을 실행하도록 제출한 작업
```

---

## Pass의 Name

`Name`은 Pass를 명시적으로 식별할 때 사용한다.

```shaderlab
Pass
{
    Name "ShadowCaster"
}
```

`Name` 자체가 URP에서 Pass의 실행 시점을 결정하지는 않는다.

그 역할은 주로 `LightMode` Tag가 담당한다.

```shaderlab
Pass
{
    Name "DepthOnly"

    Tags
    {
        "LightMode" = "DepthOnly"
    }
}
```

두 문자열을 같게 작성하는 경우가 많지만 용도가 다르다.

| 항목 | 용도 |
|---|---|
| `Name` | Pass 참조와 디버깅을 위한 이름 |
| `LightMode` | Render Pipeline이 Pass의 역할을 판별하는 Tag |

---

## LightMode가 필요한 이유

한 Shader에 여러 Pass가 있으면 Render Pipeline은 현재 단계에 맞는 Pass를 구분해야 한다.

`LightMode`는 이 Pass가 언제 사용될지를 나타내는 약속이다.

```shaderlab
Tags
{
    "LightMode" = "UniversalForward"
}
```

URP가 Forward Camera Color를 그릴 때 `UniversalForward` Pass를 찾을 수 있다.

Shadow Map 단계에서는 같은 Material의 `ShadowCaster` Pass를 찾는다.

```text
Material의 Shader
├─ UniversalForward
├─ ShadowCaster
├─ DepthOnly
└─ Meta

현재 Pipeline 단계가 무엇인가?
↓
해당 LightMode의 Pass 선택
```

Built-in Render Pipeline에서 사용하던 `ForwardAdd`, `PrepassBase` 같은 일부 Legacy LightMode는 URP에서 지원되지 않는다.

Custom Shader는 대상 Render Pipeline의 Pass 규칙에 맞춰 작성해야 한다.

---

## URP의 주요 Pass 역할

URP에서 자주 접하는 `LightMode`는 다음과 같다.

| LightMode | 대표적인 역할 |
|---|---|
| `UniversalForward` | Forward Rendering의 Camera Color와 Lighting |
| `UniversalGBuffer` | Deferred Rendering을 위한 G-buffer 기록 |
| `UniversalForwardOnly` | Forward·Deferred 모두에서 Forward 방식으로 처리 |
| `ShadowCaster` | Light 시점의 Shadow Map Depth 기록 |
| `DepthOnly` | Camera Depth Texture용 Depth 기록 |
| `DepthNormalsOnly` | Depth와 Normal을 함께 기록하는 Prepass |
| `MotionVectors` | Motion Vector 기록 |
| `Meta` | Lightmap Baking에 필요한 Material 정보 |
| `SRPDefaultUnlit` | 별도 LightMode가 없을 때의 기본값 또는 추가 Unlit Pass |
| `Universal2D` | URP 2D Renderer용 Pass |

하나의 Shader가 이 Pass를 전부 가져야 한다는 뜻은 아니다.

Material의 기능과 URP 설정에서 실제로 필요한 역할을 구현해야 한다.

---

## UniversalForward Pass

`UniversalForward`는 Forward Rendering Path에서 Object의 Color와 Lighting을 그리는 대표적인 Pass다.

```shaderlab
Pass
{
    Name "ForwardLit"

    Tags
    {
        "LightMode" = "UniversalForward"
    }

    HLSLPROGRAM
    #pragma vertex Vert
    #pragma fragment Frag
    ENDHLSL
}
```

개념적인 Data Flow는 다음과 같다.

```text
Mesh Attribute
↓
Vertex Shader
↓
Clip Space Position + Varying
↓
Rasterization
↓
Fragment Shader
↓
Lighting Color
↓
Camera Color Target
```

Forward Rendering에서는 Fragment가 처리될 때 필요한 Light 정보를 이용해 최종 Color를 계산한다.

---

## UniversalGBuffer와 UniversalForwardOnly

URP의 Deferred Rendering은 먼저 Surface 정보를 G-buffer에 기록하고 이후 Lighting을 계산한다.

```text
UniversalGBuffer Pass
↓
Albedo / Normal / Material Data 기록
↓
Deferred Lighting Pass
↓
Camera Color
```

Deferred와 호환되는 Lit Shader라면 `UniversalGBuffer` Pass를 구현할 수 있다.

반대로 G-buffer 방식으로 표현하기 어려운 Material은 `UniversalForwardOnly`를 사용할 수 있다.

```text
UniversalForward
Forward Rendering Path에서 Forward 처리

UniversalGBuffer
Deferred Rendering Path에서 G-buffer 기록

UniversalForwardOnly
Rendering Path가 Forward 또는 Deferred여도 Forward 처리
```

하나의 Pass에 `LightMode` 값을 여러 개 지정하는 방식이 아니다.

각 역할은 별도의 Pass로 구성한다.

---

## ShadowCaster Pass

Shadow를 만들려면 Light가 바라본 위치에서 Object의 Depth를 Shadow Map에 기록해야 한다.

```text
Light View
↓
ShadowCaster Pass
↓
Shadow Map Depth
↓
Camera Lighting에서 비교
↓
그림자 판정
```

ShadowCaster Pass는 일반적으로 최종 Surface Color를 계산할 필요가 없다.

핵심은 Light 기준의 Clip Space Position과 Depth다.

```shaderlab
Pass
{
    Name "ShadowCaster"

    Tags
    {
        "LightMode" = "ShadowCaster"
    }

    ZWrite On
    ZTest LEqual
    ColorMask 0

    HLSLPROGRAM
    #pragma vertex ShadowVert
    #pragma fragment ShadowFrag
    ENDHLSL
}
```

Custom Shader에 적절한 ShadowCaster 구현이 없으면 그 Material의 형태가 실시간 Shadow Map에 기대한 대로 기록되지 않을 수 있다.

Alpha Clip이나 Vertex Animation을 사용하는 Shader는 Forward Pass와 ShadowCaster Pass가 같은 실루엣을 만들어야 한다.

---

## DepthOnly Pass

URP는 Camera Depth Texture가 필요할 때 Depth만 기록하는 Pass를 사용할 수 있다.

```shaderlab
Pass
{
    Name "DepthOnly"

    Tags
    {
        "LightMode" = "DepthOnly"
    }

    ZWrite On
    ColorMask 0

    HLSLPROGRAM
    #pragma vertex DepthVert
    #pragma fragment DepthFrag
    ENDHLSL
}
```

`ColorMask 0`은 Color Channel에 값을 기록하지 않도록 한다.

```text
DepthOnly Pass
├─ Position 처리 필요
├─ Alpha Clip 판정이 필요할 수 있음
├─ Depth 기록
└─ Color 기록 없음
```

Depth Texture는 이후 여러 Screen Space Effect와 Depth 기반 판정에 사용될 수 있다.

Depth만 기록한다고 해서 비용이 0은 아니다.

Vertex 처리, Triangle Setup, Rasterization, Depth Test와 Depth Write가 여전히 필요하다.

하지만 복잡한 Lighting과 Color 출력을 생략할 수 있어 일반적인 Lit Color Pass보다 가벼울 수 있다.

---

## DepthNormalsOnly Pass

일부 Effect는 Depth뿐 아니라 Camera Space 또는 World Space Normal 정보도 필요하다.

URP의 `DepthNormalsOnly` Pass는 Depth-Normal Prepass에 사용된다.

```text
DepthNormalsOnly
↓
Depth + Normal Texture
↓
SSAO 같은 Screen Space Effect
```

Forward Only Material이 Deferred Renderer에서 사용되면서 SSAO에도 올바르게 참여해야 하는 경우 이 Pass가 중요할 수 있다.

DepthOnly와 이름이 비슷하지만 출력 목적이 다르다.

```text
DepthOnly
Depth 중심

DepthNormalsOnly
Depth와 Surface Normal
```

---

## Meta Pass

`Meta` Pass는 Player가 Camera 화면을 그리는 일반 Pass가 아니다.

Editor가 Lightmap Baking을 수행할 때 Material의 Albedo와 Emission 같은 정보를 얻는 데 사용한다.

```text
Material
↓
Meta Pass
↓
Lightmapper가 Surface 정보 수집
↓
Baked Lighting 계산
```

URP 문서 기준으로 Meta Pass는 Player Build에서 제거될 수 있다.

실시간 화면에서 보이지 않는 Pass라도 제작 Pipeline의 다른 단계에 필요할 수 있다는 예다.

---

## MotionVectors Pass

Temporal Effect는 현재 Frame과 이전 Frame 사이에서 Pixel이 얼마나 이동했는지 알아야 할 수 있다.

```text
Previous Position
+ Current Position
↓
MotionVectors Pass
↓
Screen Space Motion Vector
```

Camera Motion뿐 아니라 Skinned Animation이나 Vertex 변형을 정확히 표현하려면 이전 Frame의 Geometry 상태도 고려해야 한다.

Motion Vector 구현이 Main Pass의 변형과 다르면 Temporal Anti-Aliasing이나 Motion Blur 같은 기능에 Artifact가 나타날 수 있다.

---

## SRPDefaultUnlit Pass

Pass에 `LightMode`를 지정하지 않으면 URP에서는 `SRPDefaultUnlit`로 처리될 수 있다.

이 Tag는 Unlit Shader뿐 아니라 추가 Pass를 구분하는 데도 사용된다.

```shaderlab
Pass
{
    Name "Outline"

    Tags
    {
        "LightMode" = "SRPDefaultUnlit"
    }

    // Outline Program과 State
}
```

하지만 여러 Pass를 파일에 나열했다고 해서 원하는 시점에 전부 자동 실행된다고 생각하면 안 된다.

사용하는 Renderer와 URP의 Draw 단계가 어떤 ShaderTagId를 요청하는지 확인해야 한다.

Custom Renderer Feature가 특정 Tag를 대상으로 별도의 Draw를 수행하도록 구성할 수도 있다.

---

## Render State란?

Render State는 Shader Program 외부에서 Rasterization과 출력 동작을 제어하는 상태다.

Pass마다 대표적으로 다음 State를 설정할 수 있다.

| State | 질문 |
|---|---|
| `Cull` | 어느 방향의 Face를 제거할까? |
| `ZTest` | 기존 Depth와 어떤 조건으로 비교할까? |
| `ZWrite` | 새 Depth를 기록할까? |
| `Blend` | 기존 Color와 새 Color를 어떻게 섞을까? |
| `ColorMask` | 어떤 Color Channel에 기록할까? |
| `Stencil` | Stencil Buffer를 어떻게 검사하고 바꿀까? |

```shaderlab
Pass
{
    Cull Back
    ZTest LEqual
    ZWrite On
    Blend Off
    ColorMask RGBA
}
```

같은 Fragment Shader를 사용하더라도 State가 다르면 결과가 달라진다.

---

## Cull State

`Cull`은 Triangle의 앞면 또는 뒷면을 제거한다.

```shaderlab
Cull Back
```

대표적인 값은 다음과 같다.

```text
Cull Back
뒷면 제거

Cull Front
앞면 제거

Cull Off
양면 처리
```

일반적인 닫힌 Mesh는 `Cull Back`을 사용한다.

확장된 뒷면으로 Outline을 만드는 Pass는 `Cull Front`를 사용하기도 한다.

양면 Material에서 `Cull Off`를 사용하면 보이는 Triangle과 Fragment 처리량이 늘 수 있으므로 실제 Scene에서 확인해야 한다.

---

## ZTest와 ZWrite

`ZTest`는 새 Fragment의 Depth와 Depth Buffer의 값을 비교한다.

```shaderlab
ZTest LEqual
```

`LEqual`은 새 Depth가 기존 값보다 가깝거나 같을 때 통과한다.

`ZWrite`는 통과한 Fragment의 Depth를 기록할지 정한다.

```shaderlab
ZWrite On
```

```text
ZTest
보일 수 있는가?

ZWrite
뒤에 그릴 Object를 가릴 Depth를 남길 것인가?
```

Opaque Pass는 대개 Depth를 기록한다.

Transparent Pass는 흔히 `ZWrite Off`를 사용하지만 Material의 목적과 정렬 방식에 따라 달라질 수 있다.

---

## Blend State

Blend는 Fragment Shader가 출력한 Source Color와 Render Target의 Destination Color를 결합한다.

```shaderlab
Blend SrcAlpha OneMinusSrcAlpha
```

개념적으로 다음과 같다.

```text
Result = Source × SrcFactor
       + Destination × DstFactor
```

일반 Alpha Blending은 뒤의 Color를 읽고 섞기 때문에 Opaque처럼 단순히 덮어쓰는 것과 다르다.

```text
Opaque
Blend Off

일반적인 Alpha Blend
Blend SrcAlpha OneMinusSrcAlpha

Additive
Blend One One
```

Blend 식은 Pass에 속하므로 동일한 HLSL 출력도 Pass State에 따라 다른 화면 결과를 만든다.

---

## Stencil State

Stencil Buffer는 Pixel 단위의 작은 Integer 값을 저장하고 비교한다.

```shaderlab
Stencil
{
    Ref 1
    Comp Equal
    Pass Keep
}
```

Stencil을 이용하면 특정 영역을 표시한 뒤 다른 Pass가 그 영역만 통과하거나 제외하도록 만들 수 있다.

```text
Pass A
Mask 영역을 Stencil에 기록

Pass B
Stencil 조건을 검사해 선택적으로 렌더링
```

Portal, Mask, Outline, 제한된 후처리 영역 같은 효과에서 사용할 수 있다.

Stencil 값은 Render Pipeline의 다른 기능도 사용할 수 있으므로 사용 Bit와 실행 순서를 함께 확인해야 한다.

---

## 하나의 Pass로 그리는 URP Shader

다음은 한 개의 Forward Pass로 Texture를 출력하는 간단한 구조다.

```shaderlab
Shader "Custom/SinglePassTexture"
{
    Properties
    {
        _BaseMap("Base Map", 2D) = "white" {}
        _BaseColor("Base Color", Color) = (1, 1, 1, 1)
    }

    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
        }

        Pass
        {
            Name "ForwardUnlit"

            Tags
            {
                "LightMode" = "UniversalForward"
            }

            Cull Back
            ZTest LEqual
            ZWrite On

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
                half4 _BaseColor;
            CBUFFER_END

            Varyings Vert(Attributes input)
            {
                Varyings output;
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
                return output;
            }

            half4 Frag(Varyings input) : SV_Target
            {
                half4 baseMap = SAMPLE_TEXTURE2D(
                    _BaseMap,
                    sampler_BaseMap,
                    input.uv
                );

                return baseMap * _BaseColor;
            }
            ENDHLSL
        }
    }
}
```

이 Shader는 Camera Color용 Pass만 직접 정의한다.

Shadow, Depth, Meta 같은 역할까지 필요하다면 각 목적에 맞는 Pass를 추가하거나 검증된 구현을 재사용해야 한다.

---

## Multi Pass란?

한 Shader가 둘 이상의 Pass를 가지는 구성을 Multi Pass라고 부를 수 있다.

```text
Shader
└─ SubShader
   ├─ Pass: Forward Color
   ├─ Pass: Shadow Caster
   └─ Pass: Depth Only
```

여러 Pass가 필요한 이유는 목적에 따라 출력과 상태가 다르기 때문이다.

```text
Forward Color
Lighting을 계산하고 Color 기록

ShadowCaster
Light 기준 Depth 기록

DepthOnly
Camera 기준 Depth 기록
```

이 Pass들은 한 화면 위치에 같은 Color를 여러 번 덧그리는 것만 의미하지 않는다.

서로 다른 Render Target, Camera 또는 Pipeline 단계에서 선택될 수 있다.

---

## 효과를 위한 Multi Pass

같은 Camera 렌더링 안에서 Object를 여러 번 그려 효과를 만들 수도 있다.

대표적인 예가 Inverted Hull Outline이다.

```text
Outline Pass
Vertex를 Normal 방향으로 확장
앞면 제거
Outline Color 출력

Main Pass
원래 Geometry와 Surface Color 출력
```

개념적인 Outline Pass는 다음과 같다.

```shaderlab
Pass
{
    Name "Outline"

    Tags
    {
        "LightMode" = "SRPDefaultUnlit"
    }

    Cull Front
    ZWrite On

    HLSLPROGRAM
    #pragma vertex OutlineVert
    #pragma fragment OutlineFrag

    Varyings OutlineVert(Attributes input)
    {
        Varyings output;

        float3 expandedOS = input.positionOS.xyz
                          + input.normalOS * _OutlineWidth;

        output.positionCS = TransformObjectToHClip(expandedOS);
        return output;
    }

    half4 OutlineFrag(Varyings input) : SV_Target
    {
        return _OutlineColor;
    }
    ENDHLSL
}
```

실제 결과는 Pass가 호출되는 순서, Depth State, Renderer 설정, Camera Projection과 Mesh 형태의 영향을 받는다.

화면상 일정한 굵기가 필요하다면 Object Space의 단순 확장보다 Clip Space 또는 Screen Space 기준 보정이 필요할 수 있다.

---

## 여러 Pass에서 코드를 공유하는 방법

Forward, Shadow, Depth Pass는 공통으로 Position 변형이나 Alpha Clip 규칙을 사용할 수 있다.

같은 코드를 각 Pass에 복사하면 한쪽만 수정되는 문제가 생기기 쉽다.

ShaderLab의 `HLSLINCLUDE`를 사용하면 SubShader 안의 여러 Pass가 공통 HLSL 선언을 공유할 수 있다.

```shaderlab
SubShader
{
    HLSLINCLUDE
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

    float3 ApplyVertexAnimation(float3 positionOS)
    {
        // 공통 Vertex 변형
        return positionOS;
    }
    ENDHLSL

    Pass
    {
        HLSLPROGRAM
        #pragma vertex ForwardVert
        #pragma fragment ForwardFrag
        ENDHLSL
    }

    Pass
    {
        HLSLPROGRAM
        #pragma vertex ShadowVert
        #pragma fragment ShadowFrag
        ENDHLSL
    }
}
```

공통 `.hlsl` 파일로 분리하고 각 Pass에서 `#include`하는 방법도 있다.

현재 블로그 저장소에서는 새 글 이외의 파일을 추가하지 않는 조건이므로 예제에서는 개념만 표현한다.

---

## UsePass로 Pass 재사용하기

ShaderLab의 `UsePass`는 다른 Shader의 이름 있는 Pass를 포함할 수 있다.

```shaderlab
UsePass "SomeShader/SHADOWCASTER"
```

참조 경로의 Pass Name은 대문자로 작성한다.

재사용하면 검증된 ShadowCaster 같은 구현을 중복 작성하지 않을 수 있다.

하지만 재사용 대상의 Property, Keyword, Vertex Layout과 Alpha Clip 규칙이 현재 Shader와 호환되어야 한다.

```text
장점
중복 구현 감소
공통 수정 반영

주의점
참조 Shader와의 결합 증가
Property와 Keyword 의존성
Vertex 변형이나 Alpha Clip 불일치 가능성
```

이름만 같은 Pass라고 해서 현재 Material의 Surface 형태를 자동으로 동일하게 처리하는 것은 아니다.

---

## Pass 사이의 Geometry가 일치해야 한다

같은 Object를 나타내는 Pass들은 대체로 같은 위치와 실루엣을 만들어야 한다.

특히 다음 처리는 모든 관련 Pass에 일관되게 반영해야 한다.

```text
Vertex Animation
Skinning
Wind 변형
Tessellation 또는 위치 변형
Alpha Clip
Dither
LOD 전환
Double-sided 처리
```

예를 들어 잎사귀 Texture의 Alpha를 Forward Pass에서만 Clip한다고 가정한다.

```text
Forward Pass
잎 모양만 남음

ShadowCaster Pass
사각형 전체가 남음

결과
그림자가 사각형으로 나타남
```

DepthOnly Pass가 같은 Clip 규칙을 적용하지 않으면 Depth 기반 Effect에는 보이지 않는 사각형 영역까지 기록될 수 있다.

```hlsl
half alpha = SAMPLE_TEXTURE2D(
    _BaseMap,
    sampler_BaseMap,
    input.uv
).a;

clip(alpha - _Cutoff);
```

공통 함수를 사용하면 Pass 간 불일치를 줄일 수 있다.

---

## Render State도 Pass마다 일치 여부를 확인해야 한다

Program의 Position과 Alpha Clip만 같다고 끝나지 않는다.

Cull과 Depth State도 결과에 영향을 준다.

```text
Forward Pass
Cull Off

ShadowCaster Pass
Cull Back

가능한 결과
화면에서는 보이는 뒷면이 Shadow에는 빠짐
```

모든 Pass의 State가 반드시 완전히 같아야 한다는 뜻은 아니다.

Shadow Bias나 ColorMask처럼 목적상 달라야 하는 State도 있다.

중요한 것은 차이가 의도된 것인지 확인하는 것이다.

---

## 한 Object가 한 Frame에 여러 번 그려지는 이유

화면에 Object 하나가 보이더라도 GPU는 그 Object를 여러 번 처리할 수 있다.

```text
Directional Light Shadow Cascade 0
→ ShadowCaster

Directional Light Shadow Cascade 1
→ ShadowCaster

Camera Depth Prepass
→ DepthOnly 또는 DepthNormalsOnly

Camera Opaque Color
→ UniversalForward 또는 UniversalGBuffer

Motion Vector 단계
→ MotionVectors
```

Shadow Cascade가 여러 개라면 Light 기준의 서로 다른 영역에 같은 Geometry를 반복 제출할 수 있다.

추가 Camera나 Reflection용 Camera가 있으면 Camera별로 다시 렌더링될 수 있다.

따라서 Scene의 Renderer 수만 보고 전체 Draw 비용을 판단하기 어렵다.

---

## Multi Pass의 비용

실제로 실행되는 Pass가 늘면 일반적으로 다음 작업이 증가할 수 있다.

```text
CPU
Renderer 검색과 정렬
Draw 제출
State와 Resource 설정

GPU
Vertex Shader 실행
Primitive 처리
Rasterization
Depth·Stencil 처리
Fragment Shader 실행
Render Target Memory 접근
```

Pass마다 비용의 크기는 다르다.

```text
DepthOnly
Color와 복잡한 Lighting이 없어 비교적 단순할 수 있음

Forward Lit
Texture Sampling과 Light 계산이 많을 수 있음

Full-screen Blended Pass
화면 해상도와 Overdraw의 영향이 클 수 있음
```

Pass 수만 세어서 성능을 정확히 예측할 수는 없다.

Triangle 수, Pixel Coverage, Shader 복잡도, Render Target Format, Bandwidth와 대상 GPU를 함께 측정해야 한다.

---

## Render State 변경 비용

Pass가 달라지면 Program, Texture, Buffer, Blend, Depth와 Rasterizer State가 바뀔 수 있다.

```text
Draw A State
↓
State 변경
↓
Draw B State
```

Render Pipeline은 비슷한 Object를 정렬하고 Batching하여 제출 비용을 줄이려 한다.

그러나 Material과 Pass의 상태가 자주 달라지면 묶을 수 있는 범위가 줄어들 수 있다.

URP SRP Batcher는 호환되는 Shader의 CPU 설정 비용을 줄이는 데 도움을 주지만, 필요한 Pass의 Geometry 작업 자체를 없애는 기능은 아니다.

---

## Multi Pass와 Overdraw

같은 화면 영역에 여러 Color Pass를 그리면 Overdraw가 증가한다.

```text
Pixel 한 개
↓
Outline Fragment
↓
Main Surface Fragment
↓
Transparent Effect Fragment
```

Depth Test에서 일찍 제거되면 Fragment Shader 비용을 줄일 수 있지만 Vertex와 Primitive 처리까지 사라지는 것은 아니다.

Transparent Blend Pass는 뒤의 Color와 결합하기 위해 여러 Layer가 실제로 처리될 수 있다.

화면을 크게 덮는 Particle이나 Full-screen Multi Pass Effect는 Pixel 처리와 Bandwidth 병목을 만들 수 있다.

---

## Pass와 Shader Variant

각 Pass에는 Keyword와 Platform 조건에 따른 여러 Compile 결과가 생길 수 있다.

```text
Shader
├─ Pass A
│  ├─ Variant 1
│  └─ Variant 2
└─ Pass B
   ├─ Variant 1
   └─ Variant 2
```

따라서 Pass가 늘면 Compile 대상과 Build Data에도 영향을 줄 수 있다.

다만 실제 Variant 수는 선언된 Keyword, URP 설정, Stripping 규칙과 Platform에 따라 달라진다.

Shader Variant가 생성되고 선택되는 구체적인 구조는 다음 글에서 다룬다.

---

## Shader Pass와 Render Pass의 차이

Unity 문서와 Rendering Code에는 `Pass`라는 단어가 여러 의미로 등장한다.

```text
ShaderLab Pass
Material의 Shader Program과 Render State

URP Render Pass
어떤 Render Target에 어떤 Object나 Full-screen 작업을 실행할지 구성하는 Pipeline 작업

Render Graph Pass
Resource의 읽기·쓰기를 선언한 Scheduling 단위
```

ShaderLab Pass는 Shader Asset 안에 작성한다.

URP의 `ScriptableRenderPass`나 Render Graph Pass는 Render Pipeline 쪽에서 작업 순서와 Resource를 구성한다.

```text
URP Render Pass
특정 ShaderTagId를 가진 Object를 그리도록 요청
↓
Material에서 맞는 ShaderLab Pass 선택
↓
GPU Draw
```

서로 연결되지만 같은 계층의 개념은 아니다.

---

## Pass가 선택되지 않을 때

Shader 코드가 Compile되었더라도 현재 Pipeline 단계가 그 `LightMode`를 요청하지 않으면 Pass가 실행되지 않을 수 있다.

확인할 항목은 다음과 같다.

```text
SubShader의 RenderPipeline Tag가 URP와 맞는가?
현재 Renderer가 해당 LightMode를 지원하는가?
Pass의 LightMode 철자가 정확한가?
Render Queue와 Layer Mask에 포함되는가?
Renderer Feature가 필요한 Draw 단계를 추가했는가?
Material과 Shader Keyword 상태가 기대와 같은가?
```

Pass의 HLSL만 보고 문제를 찾기보다 Pipeline이 그 Pass를 호출했는지 먼저 확인하는 편이 효율적이다.

---

## Frame Debugger로 Pass 확인하기

Unity Frame Debugger는 Frame 안에서 발생한 Draw Event를 순서대로 확인할 수 있다.

```text
Frame Debugger
↓
Draw Event 선택
↓
Shader와 Pass 확인
↓
Render Target 확인
↓
Keyword와 State 확인
```

다음 질문에 답할 때 유용하다.

```text
Object가 Shadow Map에 몇 번 그려졌는가?
Depth Prepass가 실행되었는가?
Forward와 G-buffer 중 어느 Pass가 선택되었는가?
Outline Pass가 Main Pass보다 언제 실행되었는가?
예상하지 않은 추가 Draw가 있는가?
```

GPU Profiler와 Platform별 GPU Capture Tool을 함께 사용하면 각 Pass의 실제 시간과 병목을 더 정확히 확인할 수 있다.

---

## Pass를 설계할 때 확인할 기준

Pass를 추가하기 전에 먼저 역할을 명확히 정한다.

```text
1. 어떤 Pipeline 단계에 필요한가?
2. 어떤 Render Target에 기록하는가?
3. Position과 Alpha Clip 규칙은 무엇인가?
4. 필요한 Render State는 무엇인가?
5. 기존 Pass와 공유할 코드는 무엇인가?
6. 대상 Renderer에서 실제로 선택되는가?
7. 목표 Hardware에서 비용은 얼마인가?
```

필요 없는 Pass는 유지 비용과 Compile 범위를 늘릴 수 있다.

반대로 필요한 Depth, Shadow, Motion Vector Pass를 제거하면 Rendering Feature가 잘못 동작할 수 있다.

Pass 수를 무조건 최소화하는 것이 목표가 아니라 필요한 결과를 올바르게 만들면서 중복 작업을 줄이는 것이 목표다.

---

## 자주 혼동하는 내용

### Shader 파일의 Pass는 모두 순서대로 실행된다?

그렇지 않다.

Render Pipeline은 현재 단계가 요청하는 Tag와 조건에 맞는 Pass를 선택한다.

효과용 추가 Pass도 Renderer가 해당 Pass를 그리는 흐름이 있어야 실행된다.

### Pass 하나는 Draw Call 하나다?

Pass는 Draw 방법의 정의다.

실제 Draw 수는 Object, SubMesh, Camera, Shadow Cascade, Instancing과 Batching에 따라 달라질 수 있다.

### Pass Name과 LightMode는 같은가?

아니다.

`Name`은 참조 가능한 이름이고 `LightMode`는 Pipeline에서의 역할을 나타낸다.

### DepthOnly Pass는 무료인가?

아니다.

Color Lighting보다 단순할 수 있지만 Geometry 처리와 Depth 기록 비용이 있다.

### Main Pass만 올바르면 다른 Pass도 자동으로 같은 모양이 되는가?

아니다.

Vertex 변형, Alpha Clip과 Cull 규칙을 관련 Pass에 일관되게 구현해야 한다.

### SRP Batcher가 Multi Pass를 한 번의 Draw로 합치는가?

그렇지 않다.

SRP Batcher는 호환되는 Draw 사이의 CPU State 설정 비용을 줄이는 구조이며 서로 다른 목적의 Pass 작업 자체를 제거하지 않는다.

---

## 정리

Pass는 특정 렌더링 목적에 사용할 Shader Program, Render State와 Metadata를 묶은 ShaderLab 단위다.

```text
Pass
├─ Name
├─ LightMode
├─ Cull / Depth / Blend / Stencil
└─ Vertex / Fragment Program
```

URP는 `LightMode`를 이용해 Forward Color, G-buffer, Shadow, Depth, Depth-Normal, Motion Vector와 Baking 같은 단계에 맞는 Pass를 선택한다.

여러 Pass가 있다고 해서 모두 파일 순서대로 자동 실행되는 것은 아니다.

실제로 선택된 Pass는 목적에 맞는 Draw 작업을 만들며, 같은 Object도 Shadow Cascade, Depth Prepass, Camera Color와 Motion Vector 단계에서 여러 번 처리될 수 있다.

Multi Pass Shader에서는 Vertex 변형, Alpha Clip과 Surface 방향을 관련 Pass에 일관되게 적용해야 화면, 그림자와 Depth 기반 Effect의 형태가 일치한다.

Pass가 늘면 Geometry 처리, Draw 제출, State 변경과 Memory 접근이 증가할 수 있지만 Pass마다 비용은 다르다.

Frame Debugger와 대상 Platform의 GPU Profiler로 실제 실행 Pass와 병목을 확인한 뒤 필요한 기능을 유지하면서 중복 작업을 줄여야 한다.
