---
title: "[Unity 렌더링] 4-1. Shader는 왜 필요할까?"
excerpt: "Unity Rendering"
categories:
  - Programming
tags:
  - Unity
  - Rendering
  - Shader
  - VertexShader
  - FragmentShader
permalink: /programming/unity-4-1-why-shader/
toc: true
toc_sticky: true
date: 2026-08-15
last_modified_at: 2026-08-15
---

Mesh에는 Vertex Position, Normal, UV와 Triangle을 구성하는 Index가 저장된다.

Texture에는 색상이나 표면 정보를 나타내는 데이터가 저장된다.

하지만 이 데이터만으로 GPU는 Vertex를 화면의 어디에 배치할지, Texture를 어떻게 읽을지, Light를 어떤 방식으로 반영할지 결정할 수 없다.

```text
Mesh
Position / Normal / UV / Index

Texture
Color / Normal / Mask Data

Light와 Camera
Direction / Color / View

↓ 어떤 규칙으로 계산할까?

Shader
```

Shader는 Rendering Pipeline의 Programmable Stage에서 실행되는 GPU Program이다.

Vertex Shader는 Geometry의 Position과 다음 Stage에 전달할 데이터를 계산하고, Fragment Shader는 Rasterization된 Fragment의 Material과 Lighting 결과를 계산한다.

```text
Mesh Data
↓
Vertex Shader
Position 변환과 Vertex Data 계산
↓
Rasterization
↓
Fragment Shader
Texture, Material, Lighting 계산
↓
Color와 기타 출력
```

Shader가 있기 때문에 같은 Mesh와 Texture를 사용해도 불투명 표면, 물, 홀로그램, Toon Shading, Dissolve와 Post-processing처럼 서로 다른 화면 표현을 만들 수 있다.

---

## Shader란?

Shader는 GPU의 특정 Pipeline Stage에서 많은 데이터 항목을 병렬로 처리하도록 작성한 Program이다.

Graphics Pipeline에는 여러 Programmable Stage가 존재할 수 있다.

- Vertex Shader
- Tessellation Control Shader
- Tessellation Evaluation Shader
- Geometry Shader
- Fragment Shader
- Task Shader와 Mesh Shader

Compute Shader도 GPU Program이지만 Graphics Pipeline의 Vertex와 Fragment 흐름과는 별도의 Compute Pipeline에서 실행된다.

Unity의 기본적인 Custom Graphics Shader를 이해할 때는 Vertex Shader와 Fragment Shader가 중심이 된다.

```text
Vertex Shader
Vertex마다 실행되는 Programmable Stage

Fragment Shader
Rasterization이 만든 Fragment를 처리하는 Programmable Stage
```

Shader라는 이름이 한 종류의 효과만 뜻하는 것은 아니다.

어떤 Stage에서 어떤 Input을 받고 어떤 Output을 만들도록 작성되었는지가 Shader의 역할을 결정한다.

---

## 왜 GPU Program이 필요할까?

3D Object를 화면에 그리는 모든 규칙이 하나로 고정되어 있다면 모든 표면은 같은 방식으로 변환되고 같은 방식으로 색칠된다.

실제 Scene에는 서로 다른 표현이 필요하다.

```text
돌
거칠고 빛이 넓게 퍼지는 표면

금속
주변 환경을 강하게 반사하는 표면

유리
뒤의 Color와 결합되는 투명 표면

물
시간에 따라 변형되고 굴절되는 표면

UI
Lighting보다 Image Color가 중요한 표면
```

GPU는 Object가 돌인지 물인지 스스로 알지 못한다.

Mesh, Texture, Light와 숫자 Data를 어떤 식으로 결합할지 Shader가 계산 규칙을 제공해야 한다.

```text
입력 Data + Shader의 계산 규칙 = Rendering 출력
```

---

## 고정 기능만으로 부족한 이유

초기의 Graphics Pipeline은 Transform, Lighting와 Texture 결합 방식을 제한된 State와 고정된 기능으로 선택하는 구조가 중심이었다.

```text
Fixed Function
미리 준비된 연산 선택
Parameter 조절
```

정해진 표현에는 편리하지만 새로운 Lighting Model이나 Surface Effect를 만들려면 한계가 생긴다.

Programmable Shader는 Pipeline 전체를 없애는 것이 아니라 일부 계산 Stage를 Program으로 정의할 수 있게 한다.

```text
Fixed Function Stage
Vertex Fetch, Primitive Assembly, Rasterization,
Depth / Stencil, Blending

Programmable Stage
Vertex Shader, Fragment Shader 등
```

Rasterizer가 Triangle Coverage를 판정하는 기본 역할은 유지하면서 Vertex Position과 Fragment 출력의 계산 방식을 Shader로 바꿀 수 있다.

---

## Shader가 모든 것을 하는 것은 아니다

Graphics Pipeline에는 Shader Code가 직접 대체하지 않는 Fixed-function Stage도 존재한다.

```text
Vertex Input
↓
Vertex Shader           Programmable
↓
Primitive Assembly      Fixed Function
↓
Clipping / Culling      Fixed Function + State
↓
Rasterization           Fixed Function
↓
Fragment Shader         Programmable
↓
Depth / Stencil / Blend Fixed Function + State
↓
Render Target
```

Shader는 Rasterizer처럼 Triangle이 Pixel을 덮는 기본 규칙을 일반적인 Vertex·Fragment Shader에서 직접 구현하지 않는다.

Depth Test와 Blending도 보통 ShaderLab Render State로 설정하고 GPU의 전용 Stage가 처리한다.

Shader Code와 Render State가 함께 하나의 Pipeline 동작을 구성한다.

---

## Shader가 정의하는 질문

기본적인 Graphics Shader는 다음 질문에 답한다.

```text
Vertex Shader
이 Vertex는 화면의 어디에 놓일까?
어떤 데이터를 Rasterizer에 전달할까?

Fragment Shader
이 Fragment의 표면 결과는 무엇일까?
어떤 Color나 Material Data를 출력할까?
```

Render State는 다른 질문을 담당한다.

```text
Cull
어느 방향의 Triangle을 제거할까?

ZTest / ZWrite
어떤 Depth가 통과하고 기록될까?

Blend
새 Color와 기존 Color를 어떻게 결합할까?
```

화면 결과를 이해하려면 Shader Program만이 아니라 State도 함께 확인해야 한다.

---

## Vertex Shader가 필요한 이유

Mesh의 Position은 일반적으로 Object Space에 저장된다.

GPU가 Rasterization하려면 이 Position을 Clip Space까지 변환해야 한다.

```text
Object Space Position
↓ Object to World
World Space
↓ World to View
View Space
↓ Projection
Clip Space
```

가장 기본적인 Vertex Shader는 이 변환 결과를 출력한다.

```hlsl
Varyings vert(Attributes input)
{
    Varyings output;
    output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
    return output;
}
```

`SV_POSITION`으로 전달되는 Clip Space Position이 없으면 Rasterizer는 Triangle을 화면에 배치할 기준을 얻을 수 없다.

Vertex Shader의 가장 기본적인 책임은 Vertex Position을 Graphics Pipeline이 요구하는 위치로 변환하는 것이다.

---

## Vertex Position을 바꿀 수 있다

Vertex Shader는 단순한 Matrix 변환 외에 Position 자체를 변형할 수 있다.

```hlsl
float3 positionOS = input.positionOS.xyz;
positionOS.y += sin(positionOS.x * _Frequency + _Time.y) * _Amplitude;
output.positionCS = TransformObjectToHClip(positionOS);
```

```text
원래 Plane Vertex
↓ 시간과 위치 기반 Offset
물결 모양 Vertex
↓ Transform
화면 Position
```

같은 Mesh라도 Vertex Shader 계산에 따라 흔들리는 풀, 파도, 깃발, 팽창과 왜곡을 표현할 수 있다.

CPU에서 매 Frame 모든 Vertex를 수정하여 GPU로 다시 전송하지 않고 GPU에서 병렬 계산할 수 있다는 장점이 있다.

다만 Vertex Shader가 실제 Mesh의 Topology를 자동으로 세분화하는 것은 아니다.

Vertex가 충분하지 않은 Plane은 복잡한 곡선으로 변형할 수 없다.

---

## Vertex마다 실행된다

Vertex Shader는 Draw에 포함된 Vertex Invocation을 대상으로 실행된다.

```text
Vertex 0 → Vertex Shader
Vertex 1 → Vertex Shader
Vertex 2 → Vertex Shader
...
```

각 Invocation은 자신의 Position, Normal, UV, Color 같은 Attribute를 읽는다.

GPU는 많은 Invocation을 병렬로 처리할 수 있다.

일반적인 Vertex Shader는 임의의 다른 Vertex 결과를 직접 참조하여 전체 Mesh 형태를 분석하는 방식으로 작성하지 않는다.

Mesh 전체 정보가 필요한 변형은 미리 Data를 준비하거나 다른 Algorithm과 Pipeline Stage를 사용해야 할 수 있다.

---

## 다음 Stage에 데이터를 전달한다

Vertex Shader는 Position뿐 아니라 Fragment Shader가 사용할 데이터를 출력한다.

```hlsl
struct Attributes
{
    float4 positionOS : POSITION;
    float3 normalOS   : NORMAL;
    float2 uv         : TEXCOORD0;
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    float3 normalWS   : TEXCOORD0;
    float2 uv         : TEXCOORD1;
};
```

```text
Mesh Attribute
Position / Normal / UV
↓ Vertex Shader
Varying
Clip Position / World Normal / UV
↓ Rasterization과 Interpolation
Fragment Shader Input
```

Triangle 내부에는 Vertex가 없지만 Rasterizer가 세 Vertex의 출력값을 보간하여 Fragment마다 연속적인 UV와 Normal을 만든다.

이 Interface 덕분에 Vertex 단위 Data가 Fragment 단위 계산에 연결된다.

---

## Fragment Shader가 필요한 이유

Rasterizer는 Triangle이 어떤 Sample을 덮는지와 Vertex 출력값의 보간 결과를 만든다.

하지만 Surface가 어떤 Color를 가져야 하는지는 Rasterizer가 결정하지 않는다.

Fragment Shader는 보간된 Data와 Texture, Material Property, Light 정보를 사용하여 출력값을 계산한다.

```hlsl
half4 frag(Varyings input) : SV_Target
{
    half4 baseColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv);
    return baseColor * _BaseColor;
}
```

```text
보간 UV
↓ Texture Sampling
Texture Color
↓ Material Color와 결합
Source Color
```

Fragment Shader 출력은 Depth, Stencil과 Blending을 거치기 전의 Source Color다.

최종 Pixel은 Fixed-function Fragment Operations와 이후 Pass의 영향을 더 받을 수 있다.

---

## Texture를 표면에 연결한다

Texture는 2D Data 배열일 뿐이며 Mesh의 어느 위치에서 어떤 Texel을 읽을지는 자동으로 정해지지 않는다.

Mesh의 UV와 Sampling 규칙이 필요하다.

```text
Mesh UV
(0, 0) ~ (1, 1)
↓
Texture 좌표
↓ Sampler와 Filtering
Sampled Color
```

Fragment Shader는 보간된 UV를 이용해 Texture를 Sampling한다.

```hlsl
half4 color = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv);
```

UV를 시간에 따라 이동하면 흐르는 표면을 만들 수 있고, 좌표를 왜곡하면 열기나 물결 같은 효과를 만들 수 있다.

Shader가 Texture Data를 어떤 의미로 읽느냐에 따라 같은 Texture도 Color, Normal, Roughness 또는 Mask로 사용할 수 있다.

---

## Lighting 규칙을 정의한다

Light가 존재한다고 해서 Surface의 밝기가 하나의 방식으로 자동 결정되는 것은 아니다.

Fragment Shader 또는 Render Pipeline의 Lighting Code는 다음 Data를 조합한다.

```text
Surface Normal
Light Direction
View Direction
Light Color
Surface Property
Shadow
Environment
↓
Lighting Result
```

가장 단순한 Diffuse 항은 Normal과 Light Direction의 내적으로 표현할 수 있다.

```hlsl
half NdotL = saturate(dot(normalWS, lightDirectionWS));
half3 diffuse = baseColor.rgb * lightColor * NdotL;
```

```text
빛을 정면으로 향한 Normal
N · L이 큼 → 밝음

빛과 수직인 Normal
N · L이 작음 → 어두움
```

실제 URP Lighting은 Main Light, Additional Light, Shadow, GI와 BRDF를 포함하는 더 복잡한 구조를 사용할 수 있다.

Shader를 통해 Realistic Lighting뿐 아니라 단계적인 Toon Shadow나 Lighting을 무시하는 Unlit 표현도 만들 수 있다.

---

## 같은 Mesh가 다르게 보이는 이유

Sphere Mesh 하나에 서로 다른 Shader 계산을 적용할 수 있다.

```text
같은 Sphere Mesh
├─ Unlit Shader      → 일정한 Texture Color
├─ Lit Shader        → Light와 Shadow 반영
├─ Toon Shader       → 단계적인 밝기
├─ Hologram Shader   → Scan Line과 투명 Blend
└─ Dissolve Shader   → Noise 기준 Fragment 제거
```

Mesh는 Geometry Data를 제공하고 Shader는 이 Data가 화면으로 변환되는 규칙을 제공한다.

Texture도 Shader가 어떤 Channel을 어떤 계산에 사용하는지에 따라 의미가 달라진다.

Asset만으로 화면 결과가 확정되지 않는 이유다.

---

## Unlit Shader

Unlit Shader는 일반적으로 Scene Light에 의한 표면 Lighting을 계산하지 않는다.

```hlsl
half4 frag(Varyings input) : SV_Target
{
    return SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv) * _BaseColor;
}
```

```text
Texture Color
× Base Color
↓
Fragment Color
```

Light Direction과 Shadow를 읽지 않으므로 구조가 단순하다.

UI, Debug Visualization, Stylized Effect와 Lighting이 필요 없는 Object에 사용할 수 있다.

Unlit이라는 이름이 Depth Test, Fog, Blending과 후처리를 모두 무시한다는 의미는 아니다.

Pass State와 Render Pipeline 기능은 별도로 적용될 수 있다.

---

## Lit Shader

Lit Shader는 Surface와 Light의 관계를 계산한다.

```text
Base Color
Normal
Metallic
Smoothness
View Direction
Light와 Shadow
Environment
↓ BRDF와 Lighting
Final Surface Color
```

URP Lit Shader는 물리 기반 Rendering에 필요한 Material Property와 Lighting 기능을 제공한다.

Custom Lit Shader를 작성할 때는 Render Pipeline의 Light Data, Shadow Coordinate, BRDF와 Additional Light Loop를 올바르게 연결해야 한다.

Unlit보다 계산이 많다고 항상 느린 것은 아니며 실제 Shader Variant, Light 수, Texture 수와 Target GPU를 확인해야 한다.

---

## Stylized Shader

Shader는 현실적인 조명만 계산하기 위해 존재하지 않는다.

Diffuse 밝기를 몇 단계로 나누면 Toon Shading을 만들 수 있다.

```hlsl
half NdotL = saturate(dot(normalWS, lightDirectionWS));
half toon = step(0.5, NdotL);
half3 color = baseColor.rgb * lerp(_ShadowColor.rgb, _LightColor.rgb, toon);
```

```text
연속적인 밝기
0.0 ───────── 1.0

단계적인 밝기
Shadow | Light
       0.5
```

같은 Geometry와 Light를 사용해도 Shader의 수학적 규칙을 바꾸면 미술 방향에 맞는 화면을 만들 수 있다.

---

## 시간에 따라 변하는 Shader

Shader는 Frame마다 갱신되는 Time 값을 이용할 수 있다.

```hlsl
float wave = sin(input.positionOS.x * _Frequency + _Time.y * _Speed);
```

시간을 Vertex Position, UV 또는 Color 계산에 사용하면 Animation Data 없이도 반복 효과를 만들 수 있다.

```text
Time
├─ Vertex Offset → 흔들림과 파도
├─ UV Offset     → 흐르는 Texture
├─ Color 변화    → 점멸과 Pulse
└─ Threshold     → Dissolve 진행
```

모든 Animation을 Shader로 옮기는 것이 효율적인 것은 아니다.

Collision, Gameplay와 정확히 일치해야 하는 Geometry는 CPU 또는 Physics Data와의 동기화가 필요할 수 있다.

---

## 화면 공간 효과

Shader는 Object 표면뿐 아니라 이미 렌더링된 화면 Image를 처리할 수 있다.

```text
Scene Color Texture
↓ Fullscreen Shader
Color Correction / Blur / Bloom / Distortion
↓
새 Render Target
```

Fullscreen Fragment Shader는 Screen UV로 Color와 Depth Texture를 Sampling하여 Post-processing 결과를 만든다.

이때 Geometry의 Material 표현보다 Render Target의 Pixel Data를 변환하는 Program으로 사용된다.

Shader는 3D Mesh의 표면 색칠만을 의미하지 않는다.

---

## GPU에서 실행되는 이유

화면에는 수많은 Vertex와 Fragment가 존재한다.

각 항목에 비슷한 계산을 반복 적용하는 작업은 Data Parallel 구조에 적합하다.

```text
Vertex 0 ─┐
Vertex 1 ─┼→ 같은 Vertex Shader Program
Vertex 2 ─┘  서로 다른 Input Data

Fragment 0 ─┐
Fragment 1 ─┼→ 같은 Fragment Shader Program
Fragment 2 ─┘  서로 다른 보간값과 좌표
```

GPU는 많은 Shader Invocation을 그룹으로 묶어 병렬 실행한다.

CPU가 Pixel마다 함수를 호출하여 Color를 계산하고 결과를 하나씩 전송하는 방식보다 대량의 Graphics Data를 처리하기에 적합하다.

GPU가 모든 종류의 Program에서 CPU보다 빠르다는 의미는 아니다.

독립적인 대량 연산, Memory Access Pattern과 병렬 실행에 맞는 Shader Workload에서 강점을 가진다.

---

## Shader Invocation

Shader Source Code에 함수가 하나 있어도 GPU에서는 많은 Invocation이 실행된다.

```hlsl
Varyings vert(Attributes input) { ... }
half4 frag(Varyings input) : SV_Target { ... }
```

```text
한 Draw Call
↓
여러 Vertex Shader Invocation
↓
여러 Fragment Shader Invocation
```

각 Invocation은 같은 Program과 Resource를 사용하면서 서로 다른 Input을 처리한다.

Vertex 수, 화면 Coverage, Overdraw와 MSAA가 Invocation 수에 영향을 준다.

Shader Code 한 줄의 비용도 실행 횟수가 많으면 Frame 전체에서 큰 비용이 될 수 있다.

---

## Shader는 CPU Code와 어떻게 다를까?

Unity의 C# Script는 주로 CPU에서 Game Logic, Object 상태와 Rendering 명령 준비를 담당한다.

Shader는 GPU에서 Vertex와 Fragment Data를 병렬 처리한다.

```text
C# / CPU
Transform과 Game State 갱신
Renderer와 Material 설정
Draw Command 준비
↓
Shader / GPU
Vertex 변환
Rasterization 이후 표면 계산
Render Target 출력
```

CPU Code가 Shader 함수를 일반 함수처럼 직접 호출하는 것은 아니다.

CPU는 Shader와 Resource를 Pipeline에 Binding하고 Draw Command를 제출한다.

GPU는 해당 Command가 실행될 때 Stage별 Shader Invocation을 만든다.

HLSL과 CPU Language의 구체적인 차이는 이후 HLSL 문서에서 더 세분화된다.

---

## Unity에서 Shader가 사용되는 구조

Unity의 Custom Shader Asset은 ShaderLab 구조 안에 SubShader와 Pass를 정의하고 Pass 안에 HLSL Program을 포함할 수 있다.

```shaderlab
Shader "Custom/SimpleUnlit"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // HLSL Code

            ENDHLSL
        }
    }
}
```

```text
ShaderLab
SubShader 선택과 Pass, Render State 정의

HLSL
Programmable Stage에서 실행할 GPU Program 정의
```

`#pragma vertex vert`는 `vert` 함수를 Vertex Shader Entry Point로 지정한다.

`#pragma fragment frag`는 `frag` 함수를 Fragment Shader Entry Point로 지정한다.

---

## 최소한의 URP Shader 흐름

Unity 6 URP에서 단순한 Unlit Pass의 핵심 구조는 다음과 같다.

```shaderlab
Shader "Custom/BasicUnlit"
{
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
        }

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
            };

            Varyings vert(Attributes input)
            {
                Varyings output;
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                return half4(0.2, 0.7, 1.0, 1.0);
            }
            ENDHLSL
        }
    }
}
```

Vertex Shader는 Object Space Position을 Clip Space로 변환한다.

Fragment Shader는 고정된 Cyan 계열 Color를 출력한다.

```text
Mesh Position
↓ vert
Clip Position
↓ Rasterization
Fragment
↓ frag
Color
```

이 짧은 Program도 Geometry의 위치 규칙과 표면의 출력 규칙을 모두 포함한다.

---

## ShaderLab과 Shader Program

Unity에서 Shader라는 말은 여러 층을 함께 가리킬 수 있다.

```text
Shader Asset
├─ ShaderLab 구조
│  ├─ Properties
│  ├─ SubShader
│  ├─ Pass
│  ├─ Tags
│  └─ Render State
└─ HLSL Shader Program
   ├─ Vertex Entry Point
   └─ Fragment Entry Point
```

ShaderLab은 Unity가 적절한 SubShader와 Pass를 선택하고 Render State를 구성할 수 있게 한다.

HLSL Program은 GPU Programmable Stage에서 실제 Data를 계산한다.

둘을 구분하면 Compile Error가 HLSL 문법에서 발생했는지 ShaderLab 구조에서 발생했는지 파악하기 쉽다.

---

## Compile 과정

개발자가 작성한 HLSL Source가 GPU에서 Text 상태로 직접 해석되는 것은 아니다.

Unity의 Build와 Shader Import 과정은 Target Graphics API와 Platform에 맞는 Shader Program을 준비한다.

```text
ShaderLab + HLSL Source
↓ Unity Shader Import / Compile
Platform과 Graphics API용 Program
↓ Driver와 Pipeline 준비
GPU 실행 Code
```

Direct3D, Vulkan, Metal 등 Target마다 Shader Binary와 Interface 요구사항이 다르다.

Unity는 공통 HLSL 작성 흐름과 Cross-compilation을 제공하지만 모든 Platform이 동일한 기능, Precision과 성능 특성을 가진다는 의미는 아니다.

Platform별 Shader Compile 결과와 지원 Shader Model을 확인해야 할 수 있다.

---

## Shader Variant

Lighting, Shadow, Fog, Instancing과 Material Feature 조합은 서로 다른 Compile 조건을 만들 수 있다.

```hlsl
#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
#pragma shader_feature_local _NORMALMAP
```

```text
Base Variant
Shadow Variant
Normal Map Variant
Shadow + Normal Map Variant
...
```

실행 중 Branch 하나로 모든 기능을 처리하지 않고 필요한 조합을 미리 Compile하여 최적화할 수 있다.

반면 Keyword가 많으면 Variant 수, Build Size와 Compile 시간이 증가할 수 있다.

Shader가 필요한 표현을 유연하게 제공하는 만큼 어떤 기능 조합을 만들지 관리해야 한다.

Variant의 구체적인 구조와 최적화는 별도의 주제로 다뤄질 수 있다.

---

## Shader와 Resource

Shader Program은 계산 규칙이며 실제 Mesh와 Texture Data는 Resource로 전달된다.

```text
Shader Program
같은 계산 규칙

Resource
Mesh Buffer
Texture
Constant Buffer
Sampler

State
Cull / Depth / Blend
```

같은 Shader를 사용하면서 Color와 Texture 같은 입력값을 바꾸면 여러 Object를 다르게 표시할 수 있다.

이 입력값을 Unity에서 관리하는 대표적인 단위가 Material이다.

Shader와 Material의 구체적인 차이는 다음 문서에서 분리한다.

---

## Shader의 입력

Shader가 사용할 수 있는 입력은 Stage에 따라 다르다.

| 입력 | 예시 | 주 사용처 |
| --- | --- | --- |
| Vertex Attribute | Position, Normal, UV, Color | Vertex Shader |
| Uniform Data | Matrix, Time, Material Property | 여러 Stage |
| Texture | Base Map, Normal Map, Depth | 주로 Fragment Shader |
| Sampler | Filter와 Addressing State | Texture Sampling |
| Built-in Value | Vertex ID, Position, Face | Stage별 특수 입력 |
| 이전 Stage Output | Varying과 보간값 | 다음 Graphics Stage |

Stage가 지원하지 않는 Data를 임의로 읽을 수는 없다.

Resource Binding, Semantic과 Pipeline Interface가 일치해야 한다.

---

## Shader의 출력

Vertex Shader와 Fragment Shader는 서로 다른 목적의 출력을 만든다.

```text
Vertex Shader Output
Clip Position
Fragment Shader로 전달할 Varying

Fragment Shader Output
Color Attachment 값
선택적인 Depth와 기타 Render Target 값
```

Fragment Shader가 Color를 반환하더라도 Depth Test와 Blend State가 최종 기록을 결정한다.

Vertex Shader가 Position을 반환하더라도 Clipping과 Culling에서 Primitive가 제거될 수 있다.

Shader Output은 Pipeline 다음 단계의 Input이지 항상 최종 Frame 결과는 아니다.

---

## 여러 Pass가 필요한 이유

한 Object가 Frame에서 한 번만 그려지는 것은 아니다.

Render Pipeline은 목적에 따라 서로 다른 Pass와 Shader Program을 사용할 수 있다.

```text
DepthOnly Pass
Depth 기록

ShadowCaster Pass
Light 기준 Shadow Map 기록

ForwardLit Pass
Camera 기준 Color와 Lighting 기록

Meta Pass
Lightmap Baking용 Surface Data 제공
```

각 Pass는 같은 Mesh를 사용해도 다른 Vertex와 Fragment Entry Point, Render State와 Output을 가질 수 있다.

Shader Asset이 단순히 Object Color 공식 하나만 저장하는 파일이 아닌 이유다.

---

## Shader가 표현과 성능을 함께 결정한다

Shader는 시각 결과를 만드는 동시에 GPU 작업량을 결정한다.

```text
표현
Texture 수
Lighting Model
Reflection
Transparency
Vertex Animation

비용
Shader Invocation 수
연산량
Texture Sampling
Register 사용량
Memory Bandwidth
Overdraw와 Pass 수
```

복잡한 수식 하나보다 화면 전체에서 실행되는 단순한 Shader가 더 큰 비용을 만들 수도 있다.

Vertex Shader는 Vertex 수에, Fragment Shader는 화면 Coverage와 Overdraw에 더 직접적으로 영향을 받는다.

성능은 Source Code 길이만으로 판단하지 않고 Target GPU에서 Pass 시간과 Hardware Counter를 측정해야 한다.

---

## Vertex Shader 최적화 관점

Vertex Shader 비용은 다음 요소에 영향을 받을 수 있다.

- 처리되는 Vertex와 Instance 수
- Skinning과 Vertex Animation 연산
- Matrix와 Coordinate 변환 수
- Vertex Texture Fetch
- 출력하는 Varying의 수와 Precision
- Tessellation 또는 추가 Geometry 처리

동일한 Vertex가 Index Buffer와 Vertex Cache를 통해 효율적으로 재사용될 수 있지만 정확한 동작은 GPU와 Mesh 구조에 따라 다르다.

단순히 Polygon 수만 확인하지 않고 실제 Vertex 수, Draw 수와 Vertex Stage 시간을 함께 본다.

---

## Fragment Shader 최적화 관점

Fragment Shader 비용은 다음 요소에 영향을 받을 수 있다.

- Render Resolution
- Triangle의 화면 Coverage
- Opaque와 Transparent Overdraw
- Texture Sampling 수와 Filter
- Lighting과 Shadow 연산
- Branch와 Loop
- MSAA와 Sample Shading
- Render Target 수와 Format

Early-Z는 가려진 불투명 Fragment의 Invocation을 줄일 수 있지만 투명 Layer와 Fullscreen Pass 비용은 그대로 남을 수 있다.

Fragment Shader 한 번의 비용과 실제 실행 횟수를 함께 측정해야 한다.

---

## Precision 선택

Unity HLSL에서는 `float`, `half` 같은 Type을 사용한다.

```hlsl
float3 positionWS;
half3 normalWS;
half4 color;
```

Position과 큰 범위의 계산에는 충분한 Precision이 필요하고 Color나 일부 Normal 계산은 낮은 Precision으로 처리할 수 있다.

Mobile GPU에서는 낮은 Precision이 성능과 Register 사용량에 도움이 될 수 있지만 Desktop GPU에서는 차이가 작을 수도 있다.

Precision을 낮추면 Banding, Overflow, Normal 불안정과 좌표 오차가 생길 수 있다.

정확도 요구와 Target Hardware를 확인한 뒤 적용해야 한다.

---

## Branch와 병렬 실행

Shader에서도 조건문을 사용할 수 있다.

```hlsl
if (input.uv.x > 0.5)
{
    color = _RightColor;
}
else
{
    color = _LeftColor;
}
```

GPU는 여러 Invocation을 그룹으로 실행한다.

같은 그룹의 Invocation이 서로 다른 Branch를 선택하면 양쪽 경로를 나누어 처리해야 할 수 있다.

```text
Invocation Group
A A B B

Branch A 실행 시 B 비활성
Branch B 실행 시 A 비활성
```

모든 조건문이 느리다는 의미는 아니다.

Compiler가 연산으로 바꾸거나 그룹 전체가 같은 Branch를 선택하면 비용 구조가 다르다.

Shader 최적화는 규칙 하나로 결정하지 않고 Compile 결과와 GPU 측정으로 판단한다.

---

## Shader를 사용하지 않는 Rendering이 가능할까?

현대적인 Programmable Graphics Pipeline에서 일반적인 Mesh를 화면에 그리려면 최소한 Position을 출력하는 Programmable Stage가 필요하다.

Depth-only Rendering처럼 Color Fragment Shader가 생략될 수 있는 Pipeline 구성도 있다.

```text
Depth-only Pass
Vertex Shader로 Position 출력
Fragment Color 출력 없음
Depth Buffer만 갱신 가능
```

하지만 Programmable Pipeline 전체에서 Shader라는 개념이 사라지는 것은 아니다.

어떤 Stage가 필수인지와 생략 가능한지는 Graphics API, Pipeline 구성과 Rendering 목적에 따라 달라진다.

---

## Shader Graph도 Shader일까?

Unity Shader Graph는 Node를 연결하여 Shader 동작을 구성하는 Authoring Tool이다.

```text
Shader Graph Node
↓ Graph 변환과 Code 생성
Shader Program
↓ Compile
GPU 실행
```

개발자가 HLSL Entry Point 전체를 직접 작성하지 않아도 최종적으로 GPU에서 실행할 Shader Program이 생성된다.

Shader Graph와 Hand-written HLSL은 Authoring 방식이 다르지만 Vertex와 Fragment Stage, Resource, Variant와 GPU 비용이라는 기본 원리는 공유한다.

Node 수만으로 성능을 판단하기보다 생성된 Code와 실제 GPU 실행 결과를 확인해야 한다.

---

## Shader 오류가 화면에 미치는 영향

Shader Compile에 실패하거나 현재 Platform에서 지원되지 않으면 의도한 Pass를 사용할 수 없다.

Unity는 오류를 Console에 표시하고 Error Shader나 대체 결과를 보여 줄 수 있다.

다음 항목을 구분하여 확인할 수 있다.

- ShaderLab 문법 오류
- HLSL Compile 오류
- Entry Point 누락
- Semantic과 Type 불일치
- Include File 또는 Function 누락
- Target Platform 기능 미지원
- Render Pipeline Tag 불일치

화면이 분홍색으로 표시되는 현상은 Texture가 없다는 뜻으로만 해석하지 않고 Shader 지원과 Compile 상태부터 확인한다.

---

## Unity에서 Shader를 확인하는 방법

### Inspector

Shader Asset과 이를 사용하는 Material의 Property, Keyword와 Render Queue를 확인할 수 있다.

Material에 표시되는 값은 Shader가 노출한 입력과 연결된다.

### Frame Debugger

Draw Event가 어떤 Shader Pass를 사용했고 Cull, Depth와 Blend State가 어떻게 설정되었는지 확인할 수 있다.

같은 Object가 Shadow, Depth와 Color Pass에서 여러 번 그려지는 흐름도 볼 수 있다.

### Shader Compile 정보

Unity Editor의 Shader 관련 Inspector와 Compile 결과를 통해 Keyword, Variant와 Platform별 Program을 확인할 수 있다.

Unity Version과 Render Pipeline Package에 따라 메뉴와 표시 범위는 달라질 수 있다.

### GPU Profiler와 Graphics Debugger

GPU Profiler에서 Pass 시간을 비교하고 RenderDoc, PIX, Xcode GPU Frame Debugger 같은 도구로 실제 Pipeline과 Resource Binding을 조사할 수 있다.

Shader Source만 보고 추정한 비용과 실제 병목이 일치하는지 검증한다.

---

## Shader를 작성할 때 확인할 질문

```text
어떤 Stage의 Program인가?
→ Vertex / Fragment / Compute 등

입력은 무엇인가?
→ Attribute / Varying / Texture / Buffer / Uniform

출력은 무엇인가?
→ Position / Color / Depth / Buffer

몇 번 실행되는가?
→ Vertex 수 / Fragment Coverage / Dispatch 크기

어떤 Fixed-function State와 연결되는가?
→ Cull / Depth / Stencil / Blend

어느 Render Pipeline과 Pass에서 사용되는가?
→ URP / HDRP / Custom SRP와 Pass Tag
```

이 질문을 기준으로 Shader Code를 읽으면 함수 하나의 수식보다 Pipeline 안의 역할을 먼저 파악할 수 있다.

---

## 자주 생기는 오해

### Shader는 Texture에 효과를 입히는 Filter다

Texture를 처리하는 것은 Shader의 역할 중 하나다.

Vertex Position 변환, Lighting, Depth 출력, 여러 Render Target 생성과 Compute 작업도 Shader가 담당할 수 있다.

### Shader가 최종 Pixel을 직접 기록한다

Fragment Shader는 Color와 기타 출력 후보를 만든다.

Depth, Stencil, Blending과 Color Mask 같은 Fragment Operations가 실제 Attachment 기록을 결정한다.

### Shader는 Object마다 하나씩 실행된다

한 Draw Call에서 Vertex와 Fragment마다 많은 Invocation이 실행된다.

Object 수만으로 Shader 실행량을 계산할 수 없다.

### Shader가 복잡하면 Source Code가 길다

짧은 함수도 비싼 Texture Sampling, Loop 또는 많은 Variant를 포함할 수 있다.

반대로 긴 Code의 일부는 Compile 과정에서 제거될 수 있다.

### Shader Graph는 HLSL과 전혀 다른 방식으로 GPU에서 실행된다

Authoring Interface는 다르지만 Graph도 최종적으로 GPU가 실행할 Shader Program으로 변환된다.

### GPU는 Shader가 표현하려는 Material 의미를 이해한다

GPU는 숫자와 명령을 처리한다.

돌, 금속, 물이라는 의미는 Data와 Shader 계산 규칙을 설계한 개발자가 부여한다.

---

## Shader가 필요한 흐름

```text
Asset에는 Data가 있음
Mesh / Texture / Light / Camera
↓
화면 결과를 만들 계산 규칙이 필요함
↓
Shader가 Programmable Stage의 규칙을 정의함
↓
Vertex Shader
Geometry Position과 전달 Data 계산
↓
Rasterization
Fragment 후보와 보간값 생성
↓
Fragment Shader
Surface와 Lighting 출력 계산
↓
Fixed-function Fragment Operations
Depth / Stencil / Blend
↓
Render Target
```

Shader는 Asset Data와 Graphics Pipeline 사이를 연결하는 실행 규칙이다.

---

## 정리

Shader는 GPU의 Programmable Stage에서 실행되는 Program이다.

Mesh, Texture, Camera와 Light는 Rendering에 필요한 Data를 제공하지만 이 Data를 화면 결과로 바꾸는 계산 규칙까지 스스로 결정하지 않는다.

Shader는 Vertex를 어디에 배치하고 Fragment에서 어떤 표면 결과를 출력할지 정의한다.

```text
Data
Mesh / Texture / Light
↓
Shader
GPU에서 실행할 계산 규칙
↓
Rendering Result
```

Vertex Shader는 Vertex Attribute를 읽고 Rasterizer에 필요한 Clip Space Position과 Varying을 출력한다.

Position에 Offset을 적용하면 같은 Mesh를 파도, 깃발과 흔들리는 식생처럼 변형할 수 있다.

Fragment Shader는 보간된 UV와 Normal, Texture, Material Property와 Light Data를 이용하여 Source Color와 필요한 Attachment 값을 계산한다.

Shader Output은 Pipeline 다음 단계의 Input이며 Depth, Stencil과 Blending을 거쳐야 실제 Render Target 결과가 된다.

Graphics Pipeline의 모든 단계가 Shader인 것은 아니다.

Primitive Assembly, Rasterization, Depth·Stencil과 Blending은 일반적으로 Fixed-function Stage와 Render State가 담당한다.

```text
Programmable
Vertex Shader / Fragment Shader

Fixed Function
Rasterization / Depth / Stencil / Blend
```

Unity의 Shader Asset은 ShaderLab으로 SubShader, Pass와 Render State를 구성하고 HLSL Block으로 GPU Program을 정의할 수 있다.

Shader Graph도 최종적으로 GPU에서 실행할 Shader Program을 생성하는 Authoring 방식이다.

같은 Shader Code는 Vertex 또는 Fragment마다 여러 번 병렬 실행되므로 비용은 Code 길이뿐 아니라 Invocation 수, Texture Sampling, Overdraw와 Pass 수로 판단해야 한다.

Shader는 현실적인 표면만 만드는 기능이 아니라 Stylized Rendering, Vertex Animation, 화면 공간 효과와 다양한 GPU 계산을 가능하게 한다.

Shader가 필요한 이유는 고정된 화면 표현을 선택하는 데 그치지 않고 Project가 요구하는 Rendering 규칙을 GPU Program으로 정의하기 위해서다.
