---
title: "[Unity 렌더링] 4-3. HLSL은 무엇일까?"
excerpt: "Unity Rendering"
categories:
  - Programming
tags:
  - Unity
  - Rendering
  - HLSL
  - ShaderLanguage
  - GPUProgramming
permalink: /programming/unity-4-3-hlsl/
toc: true
toc_sticky: true
date: 2026-08-15
last_modified_at: 2026-08-15
---

Shader는 GPU의 Programmable Stage에서 실행되는 Program이다.

이 Program의 계산을 사람이 작성할 수 있도록 사용하는 언어 중 하나가 **HLSL**이다.

HLSL은 **High Level Shading Language**의 줄임말로, Microsoft가 DirectX의 Programmable Graphics Pipeline을 위해 만든 C 계열 고수준 Shader Language다.

```text
HLSL Source Code
↓ Shader Compiler
Target Graphics API가 사용할 Shader 표현
↓ Driver와 Pipeline 준비
GPU에서 실행
```

Unity에서는 ShaderLab의 `HLSLPROGRAM` Block 안에 HLSL Code를 작성할 수 있다.

```shaderlab
HLSLPROGRAM
#pragma vertex vert
#pragma fragment frag

Varyings vert(Attributes input)
{
    // Vertex Shader Code
}

half4 frag(Varyings input) : SV_Target
{
    // Fragment Shader Code
}
ENDHLSL
```

문법은 C, C++와 C#에 익숙하면 비슷하게 보이지만 실행되는 Hardware, Invocation 수, Data 전달 방식과 허용되는 기능은 CPU Program과 다르다.

---

## HLSL이란?

HLSL은 Vertex, Fragment 또는 Pixel, Compute 같은 Shader Stage의 동작을 기술하는 고수준 언어다.

Assembly 명령을 직접 나열하는 대신 변수, 함수, 구조체, 연산자와 Control Flow를 사용해 GPU 계산을 표현한다.

```hlsl
float3 ApplyTint(float3 color, float3 tint)
{
    return color * tint;
}
```

```text
고수준 HLSL 표현
color * tint
↓ Compiler
Target Shader Instruction과 중간 표현
```

개발자가 GPU Instruction 배치와 Register 할당을 모두 직접 작성하지 않아도 Compiler가 Target에 맞는 Program으로 변환한다.

고수준이라는 말이 CPU용 일반 Application Language와 실행 모델까지 같다는 의미는 아니다.

---

## HLSL은 어디에서 실행될까?

HLSL Source 자체가 Text 상태로 GPU에서 한 줄씩 해석되는 것은 아니다.

Shader Compiler가 Source를 Compile하고 Graphics API와 Driver가 사용할 표현으로 준비한다.

```text
Unity Shader Asset
ShaderLab + HLSL
↓ Import와 Compile
Direct3D / Vulkan / Metal 등 Target용 Shader
↓
Graphics Pipeline에 Binding
↓ Draw 또는 Dispatch
GPU Shader Invocation
```

실제 Compile 경로와 Intermediate Representation은 Target Platform과 Unity 설정에 따라 달라질 수 있다.

Direct3D에서는 DXIL 또는 이전 Shader Model의 Bytecode가 사용될 수 있고 Vulkan에서는 SPIR-V가 사용된다.

Metal Target에서는 Unity의 Shader Toolchain이 Metal에서 사용할 형태로 변환할 수 있다.

HLSL을 작성했다고 실행 Graphics API가 반드시 Direct3D인 것은 아니다.

---

## 왜 고수준 Shader Language가 필요할까?

GPU Architecture와 Instruction Set은 Vendor와 세대마다 다르다.

개발자가 각 GPU의 Machine Code를 직접 작성하면 같은 Shader 효과를 Platform마다 다시 구현해야 한다.

```text
Shader 의도
Vertex 변환과 Lighting 계산
↓ HLSL로 기술
Compiler와 Driver
↓
각 Target GPU가 실행할 Code
```

HLSL은 개발자가 Rendering Algorithm과 Data Flow를 중심으로 작성할 수 있게 한다.

Compiler는 Type, Target Profile, Shader Model과 최적화 조건을 이용해 실행 Code를 생성한다.

같은 Source가 모든 Platform에서 완전히 같은 성능과 정밀도를 보장하는 것은 아니다.

지원 기능, Compiler Backend와 GPU Architecture의 차이를 확인해야 한다.

---

## ShaderLab과 HLSL은 다르다

Unity Shader File에는 ShaderLab 문법과 HLSL 문법이 함께 존재할 수 있다.

```shaderlab
Shader "Custom/Example"
{
    Properties
    {
        _BaseColor("Base Color", Color) = (1, 1, 1, 1)
    }

    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            Cull Back
            ZWrite On

            HLSLPROGRAM
            // 이 영역이 HLSL
            ENDHLSL
        }
    }
}
```

```text
ShaderLab
Shader Object 구조
Properties / SubShader / Pass / Tags / Render State

HLSL
Programmable Stage 계산
Type / Variable / Function / Texture Sampling
```

`Cull Back`과 `ZWrite On`은 HLSL Statement가 아니라 ShaderLab Render State Command다.

`float4`, `mul`, `return`은 HLSL 문법이다.

오류 위치를 읽을 때 어느 언어 영역인지 먼저 구분해야 한다.

---

## `HLSLPROGRAM` Block

Unity ShaderLab Pass 안에서 `HLSLPROGRAM`과 `ENDHLSL` 사이에 HLSL Shader Program을 작성할 수 있다.

```shaderlab
Pass
{
    HLSLPROGRAM

    #pragma vertex vert
    #pragma fragment frag

    ENDHLSL
}
```

`#pragma vertex vert`는 `vert` 함수를 Vertex Shader Entry Point로 지정한다.

`#pragma fragment frag`는 `frag` 함수를 Fragment Shader Entry Point로 지정한다.

```text
같은 HLSL Block
├─ vert 함수 → Vertex Stage
└─ frag 함수 → Fragment Stage
```

함수 이름 자체가 `vert` 또는 `frag`여야 하는 것은 아니다.

`#pragma`에서 지정한 Entry Point와 실제 함수가 일치해야 한다.

---

## 가장 단순한 HLSL 함수

두 Color를 곱하는 함수는 다음과 같이 작성할 수 있다.

```hlsl
half4 MultiplyColor(half4 a, half4 b)
{
    return a * b;
}
```

기본 구조는 일반적인 C 계열 함수와 비슷하다.

```text
반환 Type
half4

함수 이름
MultiplyColor

Parameter
half4 a, half4 b

함수 Body
return a * b
```

이 함수가 언제 몇 번 실행되는지는 어떤 Shader Entry Point에서 호출되는지에 따라 달라진다.

Fragment Shader에서 호출되면 많은 Fragment Invocation마다 실행될 수 있다.

---

## Scalar Type

HLSL은 여러 숫자 Type을 제공한다.

| Type | 의미 | 사용 예시 |
| --- | --- | --- |
| `bool` | 논리 값 | 조건 판단 |
| `int` | Signed Integer | Index와 정수 연산 |
| `uint` | Unsigned Integer | ID와 Bit 연산 |
| `float` | Floating-point | Position과 일반 실수 계산 |
| `half` | 낮은 정밀도 의도를 가진 실수 | Color와 일부 Mobile 연산 |

```hlsl
float depth = 0.5;
half intensity = 1.0h;
uint index = 3u;
bool enabled = true;
```

Type의 실제 Bit Width와 연산 Precision은 Shader Model, Unity의 Compile 설정과 Target Platform에 영향을 받을 수 있다.

이름만 보고 모든 GPU에서 정확히 같은 Register 크기와 속도를 보장한다고 단정하면 안 된다.

---

## Vector Type

Scalar Type 뒤에 Component 수를 붙여 Vector를 표현한다.

```hlsl
float2 uv;
float3 positionWS;
float4 positionCS;

half3 color;
half4 colorWithAlpha;
```

```text
float2 = (x, y)
float3 = (x, y, z)
float4 = (x, y, z, w)
```

Color는 `r`, `g`, `b`, `a` 이름으로도 Component에 접근할 수 있다.

```hlsl
float4 value = float4(0.2, 0.4, 0.6, 1.0);

float x = value.x;
float red = value.r;
```

Vector 연산은 Position, Normal, UV와 Color 같은 Graphics Data를 표현하기에 적합하다.

---

## Swizzle

HLSL은 Vector Component를 선택하고 재배열하는 Swizzle을 지원한다.

```hlsl
float4 color = float4(0.2, 0.4, 0.6, 1.0);

float3 rgb = color.rgb;
float2 rg = color.rg;
float3 bgr = color.bgr;
```

```text
color = (R, G, B, A)
color.bgr = (B, G, R)
```

필요한 Component만 읽거나 순서를 바꿀 때 짧게 표현할 수 있다.

왼쪽 값에 사용하는 Swizzle은 같은 Component를 중복해서 쓰는 형태처럼 모호한 대입이 허용되지 않을 수 있다.

---

## Matrix Type

HLSL은 Matrix Type을 제공한다.

```hlsl
float4x4 objectToWorld;
float3x3 tangentToWorld;
```

Matrix는 Coordinate 변환과 Basis 변환에 사용된다.

```hlsl
float4 positionWS = mul(objectToWorld, positionOS);
```

Matrix와 Vector의 곱 순서, Row-major와 Column-major Layout을 Source 문법만으로 임의 가정하면 안 된다.

Unity가 제공하는 Matrix와 Transform Helper를 사용하면 Platform별 Convention과 Pipeline 구조를 일관되게 처리하기 쉽다.

```hlsl
float4 positionCS = TransformObjectToHClip(positionOS.xyz);
```

---

## Struct

여러 값을 하나의 Interface로 묶을 때 `struct`를 사용한다.

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

`Attributes`는 Mesh에서 Vertex Shader로 들어오는 Data를 표현하고 `Varyings`는 Vertex Shader에서 Rasterizer를 거쳐 Fragment Shader로 전달할 Data를 표현할 수 있다.

일반 C# Struct처럼 Memory에 단순히 같은 방식으로 배치된다고 가정하기보다 Shader Stage Interface와 Semantic을 함께 확인해야 한다.

---

## Semantic

Semantic은 HLSL 변수와 Graphics Pipeline의 의미를 연결한다.

```hlsl
float4 positionOS : POSITION;
float3 normalOS   : NORMAL;
float2 uv         : TEXCOORD0;
float4 positionCS : SV_POSITION;
half4 color       : SV_Target;
```

```text
POSITION
Vertex Position Attribute

NORMAL
Vertex Normal Attribute

TEXCOORD0
일반적인 User Data Channel

SV_POSITION
Rasterizer가 사용할 Position

SV_Target
Color Render Target 출력
```

Semantic이 없거나 Stage Interface가 맞지 않으면 Compiler Error가 발생하거나 Data가 의도한 위치로 전달되지 않을 수 있다.

Semantic의 의미는 사용 Stage에 따라 달라질 수 있다.

---

## Vertex Shader Entry Point

기본적인 Vertex Shader는 Input Struct를 받고 Output Struct를 반환한다.

```hlsl
Varyings vert(Attributes input)
{
    Varyings output;

    output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
    output.normalWS = TransformObjectToWorldNormal(input.normalOS);
    output.uv = input.uv;

    return output;
}
```

```text
Attributes
Mesh Vertex Data
↓ vert
Varyings
Clip Position과 Fragment 전달 Data
```

이 함수는 Object마다 한 번 실행되는 것이 아니라 Vertex Shader Invocation마다 실행된다.

한 Draw에 수만 개 Vertex가 있다면 같은 Entry Point가 서로 다른 Input으로 여러 번 실행된다.

---

## Fragment Shader Entry Point

Fragment Shader는 Rasterizer가 보간한 Varying을 받고 Color를 출력할 수 있다.

```hlsl
half4 frag(Varyings input) : SV_Target
{
    half4 textureColor =
        SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv);

    return textureColor * _BaseColor;
}
```

```text
보간된 Varyings
↓ frag
Source Color
↓ Depth / Stencil / Blending
Render Target
```

Fragment Shader도 Object마다 한 번이 아니라 Rasterized Fragment에 대응하는 Invocation으로 실행된다.

Overdraw, MSAA, Helper Invocation과 Early-Z 때문에 실행 수가 화면 Pixel 수와 단순히 같지는 않다.

---

## HLSL의 함수는 CPU 함수처럼 호출될까?

Helper Function을 Entry Point 안에서 호출하는 문법은 일반 함수 호출과 비슷하다.

```hlsl
half3 ApplyLighting(half3 color, half NdotL)
{
    return color * NdotL;
}

half4 frag(Varyings input) : SV_Target
{
    half3 result = ApplyLighting(_BaseColor.rgb, 0.8h);
    return half4(result, 1.0h);
}
```

하지만 CPU가 `frag()`를 직접 한 번 호출하는 것은 아니다.

```text
CPU
Draw Command 제출
↓
GPU Pipeline
Fragment Invocation 생성
↓
각 Invocation이 frag Entry Point 실행
```

Compiler는 작은 Helper Function을 Inline하거나 전체 식을 최적화할 수 있다.

Source의 함수 호출 수와 실제 GPU Call Instruction 수가 같다고 가정하면 안 된다.

---

## Intrinsic Function

HLSL은 Vector와 Graphics 계산에 유용한 Intrinsic Function을 제공한다.

```hlsl
float value = saturate(inputValue);
float lengthValue = length(direction);
float3 unitDirection = normalize(direction);
float lightAmount = dot(normal, lightDirection);
float3 reflected = reflect(-lightDirection, normal);
float wave = sin(time);
```

| 함수 | 역할 |
| --- | --- |
| `saturate(x)` | 값을 0과 1 사이로 제한 |
| `dot(a, b)` | Vector 내적 |
| `cross(a, b)` | 3D Vector 외적 |
| `normalize(v)` | 단위 Vector 계산 |
| `lerp(a, b, t)` | 선형 보간 |
| `step(edge, x)` | 임계값 기반 0 또는 1 |
| `smoothstep(a, b, x)` | 부드러운 범위 전환 |
| `ddx`, `ddy` | Screen Space 미분 |

Intrinsic 하나가 모든 GPU에서 동일한 단일 Instruction으로 실행된다고 단정할 수 없다.

Compiler와 Hardware가 지원 방식에 맞춰 변환한다.

---

## `mul`과 Component-wise 곱

HLSL에서 `*`는 Vector끼리 사용할 때 Component별 곱으로 동작할 수 있다.

```hlsl
float3 a = float3(1, 2, 3);
float3 b = float3(4, 5, 6);
float3 c = a * b;

// c = (4, 10, 18)
```

내적은 `dot`을 사용한다.

```hlsl
float d = dot(a, b);
```

Matrix 곱에는 `mul`을 사용한다.

```hlsl
float4 positionWS = mul(matrix, positionOS);
```

C#의 Operator 의미를 그대로 대입하지 않고 HLSL Type과 Function 규칙을 확인해야 한다.

---

## 조건문

HLSL은 `if`, `else`를 사용할 수 있다.

```hlsl
if (input.uv.x < 0.5)
{
    color = _LeftColor;
}
else
{
    color = _RightColor;
}
```

GPU는 여러 Invocation을 실행 그룹으로 처리한다.

같은 그룹에서 Invocation마다 다른 Branch를 선택하면 경로를 나누어 실행해야 할 수 있다.

```text
Invocation
0 1 2 3

조건 결과
A A B B

경로 A 실행
0 1 활성 / 2 3 비활성

경로 B 실행
0 1 비활성 / 2 3 활성
```

이를 Branch Divergence라고 부를 수 있다.

모든 `if`가 느린 것은 아니며 Uniform 조건, Compiler 최적화와 Hardware Branch 처리 방식에 따라 비용이 달라진다.

---

## 반복문

HLSL은 `for`, `while` 같은 반복문을 사용할 수 있다.

```hlsl
half3 lighting = 0;

for (uint i = 0; i < lightCount; ++i)
{
    lighting += EvaluateLight(i, input);
}
```

Compiler가 반복 횟수를 알 수 있으면 Loop를 펼치는 Unroll을 적용할 수 있다.

반복 횟수가 Runtime Data에 따라 달라지면 실제 Branch와 Loop로 남을 수 있다.

```text
Loop 한 번의 비용
× Invocation 수
× 반복 횟수
= Frame 전체 비용
```

Fragment Shader의 Loop는 화면 Coverage와 Overdraw만큼 반복되므로 Light 수와 Sample 수를 함께 측정해야 한다.

---

## Preprocessor

HLSL Compile 전에는 Preprocessor Directive를 사용할 수 있다.

```hlsl
#define USE_CUSTOM_LIGHTING 1

#if defined(_NORMALMAP)
    // Normal Map Code
#endif
```

Unity의 `#pragma multi_compile`과 `#pragma shader_feature`는 Keyword 조합에 따른 Shader Variant를 구성할 수 있다.

```hlsl
#pragma shader_feature_local _NORMALMAP
```

```text
_NORMALMAP Off
→ Normal Map Code가 없는 Variant

_NORMALMAP On
→ Normal Map Code가 포함된 Variant
```

Preprocessor 분기는 Runtime `if`와 다르다.

Compile 시점에 Code 구성이 달라지므로 Variant 수와 Build Size에 영향을 줄 수 있다.

---

## `#include`

공통 HLSL Code를 여러 Shader에서 재사용하려면 Include File을 사용할 수 있다.

```hlsl
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
```

URP의 `Core.hlsl`은 Coordinate 변환과 공통 Shader 정의를 제공한다.

Project의 Custom Include도 만들 수 있다.

```hlsl
#include "Assets/Shaders/CommonLighting.hlsl"
```

```text
Shader A ─┐
Shader B ─┼→ CommonLighting.hlsl
Shader C ─┘
```

Include는 Source를 재사용하는 구조이며 독립된 Runtime Shader Stage가 아니다.

Include 순환, 중복 정의와 Pipeline별 Header 의존성을 관리해야 한다.

---

## Macro

Unity Render Pipeline Shader Library는 Platform 차이와 Resource 선언을 감싸는 Macro를 제공한다.

```hlsl
TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);

half4 color = SAMPLE_TEXTURE2D(
    _BaseMap,
    sampler_BaseMap,
    input.uv
);
```

Macro는 Target Graphics API에 맞는 HLSL 표현으로 확장될 수 있다.

직접 Platform별 문법을 반복하기보다 Render Pipeline이 제공하는 Macro를 사용하면 호환성을 유지하기 쉽다.

어떤 Macro가 실제로 무엇을 생성하는지는 Include File과 Compile 결과를 확인해야 한다.

---

## Texture와 Sampler Type

HLSL에서는 Texture Resource와 Sampler State를 구분한다.

```hlsl
Texture2D<float4> _BaseMap;
SamplerState sampler_BaseMap;
```

Unity URP Macro로는 다음처럼 선언할 수 있다.

```hlsl
TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);
```

Texture를 읽을 때 UV와 Sampler를 함께 사용한다.

```hlsl
half4 color = SAMPLE_TEXTURE2D(
    _BaseMap,
    sampler_BaseMap,
    input.uv
);
```

Texture는 Texel Data를 보관하고 Sampler는 Filtering과 Addressing 동작에 관여한다.

Texture Sampling의 세부 구조는 다음 `4-5` 문서에서 이어진다.

---

## Constant Buffer

Material Property와 Matrix 같은 값은 Constant Buffer를 통해 Shader에 전달될 수 있다.

URP Custom Shader에서 Per-Material 값을 다음처럼 묶을 수 있다.

```hlsl
CBUFFER_START(UnityPerMaterial)
    float4 _BaseColor;
    float4 _BaseMap_ST;
    float _Smoothness;
CBUFFER_END
```

```text
CPU / Unity
Material Property 준비
↓ Constant Buffer Binding
GPU Shader
같은 Draw의 Invocation이 값 읽음
```

Constant Buffer의 Alignment와 Packing은 C# Struct Layout과 단순히 같다고 가정하면 안 된다.

SRP Batcher 호환성을 위해 같은 Shader의 Per-Material Variable Layout을 일관되게 유지해야 한다.

---

## CPU의 C#과 HLSL 비교

| 구분 | C# Script | HLSL Shader |
| --- | --- | --- |
| 주 실행 장치 | CPU | GPU |
| 호출 시작 | Unity Event와 Method Call | Draw·Dispatch가 만든 Invocation |
| 주요 단위 | Object와 Component | Vertex, Fragment, Thread 등 |
| Memory | Managed Object와 일반 CPU Memory | Resource, Register, Buffer와 GPU Memory |
| 병렬성 | 명시적인 Job과 Thread 사용 가능 | 많은 Invocation 병렬 실행이 기본 |
| 결과 | Game State와 Command 갱신 | Vertex·Color·Buffer 등 GPU 출력 |
| Compile Target | .NET Runtime과 Platform Code | Shader Model, Graphics API, GPU Driver |

두 언어의 문법이 비슷해도 Program을 설계하는 기준은 다르다.

---

## C#은 GameObject를 처리한다

Unity C# Script는 Component Reference를 가져오고 Transform, Physics와 Gameplay State를 갱신할 수 있다.

```csharp
private void Update()
{
    transform.Rotate(0.0f, 30.0f * Time.deltaTime, 0.0f);
}
```

이 Code는 특정 GameObject의 `Transform` Component 상태를 변경한다.

HLSL Vertex Shader에는 `GameObject`, `Transform` Component와 C# Object Reference가 존재하지 않는다.

필요한 Matrix와 값이 Buffer 또는 Property로 전달되어야 한다.

```hlsl
output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
```

Shader는 Unity Object 의미보다 Binding된 숫자 Data를 처리한다.

---

## HLSL은 Invocation을 처리한다

한 Vertex Shader 함수가 작성되어 있어도 각 Vertex Invocation이 별도로 실행한다.

```text
Vertex Shader Program 한 개
↓
Invocation 0: Vertex 0
Invocation 1: Vertex 1
Invocation 2: Vertex 2
...
```

Fragment Shader도 Rasterization 결과에 따라 많은 Invocation이 실행된다.

```text
Fragment Shader Program 한 개
↓
Invocation 0: Fragment A
Invocation 1: Fragment B
Invocation 2: Fragment C
...
```

Source Code는 하나지만 실행 Context가 대량으로 복제된다.

Shader 비용은 함수 한 번이 아니라 Invocation 수까지 곱해서 판단해야 한다.

---

## 실행 순서를 가정하면 안 된다

일반적인 Vertex 또는 Fragment Shader Invocation의 상대적인 실행 순서는 정의되지 않을 수 있다.

```text
Source상의 Vertex Index
0, 1, 2, 3

실제 완료 순서
단순히 0 → 1 → 2 → 3이라고 보장되지 않음
```

각 Invocation이 독립적으로 계산할 수 있어야 GPU가 병렬 실행을 효율적으로 구성할 수 있다.

Fragment Shader가 Buffer에 Side Effect를 기록하는 경우에는 Data Race와 Synchronization 규칙을 별도로 고려해야 한다.

C#의 일반 Loop처럼 직전 Invocation이 변경한 일반 변수 값을 다음 Invocation이 자동으로 읽는 구조가 아니다.

---

## Local Variable은 Invocation마다 존재한다

Shader 함수 안의 Local Variable은 개념적으로 각 Invocation의 실행 상태다.

```hlsl
half4 frag(Varyings input) : SV_Target
{
    half brightness = input.uv.x;
    return half4(brightness, brightness, brightness, 1.0h);
}
```

한 Fragment의 `brightness`를 다른 Fragment가 일반 변수처럼 직접 읽지 않는다.

```text
Fragment A
brightness A

Fragment B
brightness B
```

GPU Compiler는 Local 값을 Register에 배치하거나 최적화하여 제거할 수 있다.

Local Variable 수가 많고 Lifetime이 길면 Register Pressure에 영향을 줄 수 있다.

---

## Memory Allocation 방식이 다르다

HLSL Shader에서는 C#의 `new GameObject()`나 Garbage-collected Object를 사용할 수 없다.

```text
C#
Managed Object 생성
Reference 보관
Garbage Collection 가능

HLSL
Compile 시 정해진 Type과 Resource Interface
Register / Constant Buffer / Texture / Structured Buffer 등 사용
```

GPU에서 Dynamic Memory와 Pointer를 지원하는 범위는 Shader Model과 기능에 따라 존재할 수 있지만 일반 Unity Graphics Shader는 C# Heap Programming과 전혀 다른 모델로 작성한다.

필요한 Memory Resource는 CPU 또는 Render Pipeline에서 생성하고 Shader에 Binding한다.

---

## 상태를 다음 Frame에 자동 보관하지 않는다

Vertex 또는 Fragment Shader의 Local Variable은 다음 Frame까지 유지되는 Object Field가 아니다.

```hlsl
float value = value + 1.0;
```

이런 식으로 이전 Frame의 Local 값을 자동으로 누적할 수 없다.

Frame 사이의 결과를 유지하려면 Texture나 Buffer 같은 Persistent Resource에 값을 저장하고 다음 Frame에 다시 읽는 구조가 필요하다.

```text
Frame N Shader
↓ RenderTexture에 결과 Write
Frame N+1 Shader
↓ 이전 RenderTexture Read
새 결과 Write
```

Feedback 효과에는 Double Buffering과 Resource Synchronization이 필요할 수 있다.

---

## Reference Type과 Pointer 감각이 다르다

C#에서는 Class Instance Reference를 함수에 전달할 수 있다.

```csharp
void ChangeTarget(Renderer target) { ... }
```

HLSL Entry Point는 Unity `Renderer` Reference를 받을 수 없다.

```text
HLSL Input
숫자 Vector
Vertex Attribute
Texture와 Buffer Resource
Built-in Semantic
```

Shader가 특정 GameObject를 찾아 이름으로 접근하는 기능도 없다.

CPU가 필요한 Data를 Material Property, Constant Buffer, Structured Buffer와 Texture로 변환해 전달해야 한다.

---

## Resource Binding

HLSL Source에 Texture 이름을 선언했다고 실제 Texture가 자동 생성되는 것은 아니다.

```hlsl
TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);
```

Unity와 Graphics API가 Draw 전에 실제 Resource를 해당 Binding에 연결한다.

```text
HLSL 선언
_BaseMap Resource Slot
↑
Material
Texture Asset 참조
↑
Unity Rendering Code
Draw에 Resource Binding
```

Shader의 선언은 사용할 Interface이며 Resource의 생성과 Lifetime은 Application과 Engine이 관리한다.

---

## Stage마다 사용할 수 있는 기능이 다르다

같은 HLSL 문법을 사용해도 Shader Stage에 따라 Input, Output과 사용할 수 있는 Intrinsic이 다르다.

```text
Vertex Shader
Vertex Attribute와 Vertex ID
Clip Position 출력

Fragment Shader
보간된 Input과 Screen Derivative
Color와 Depth 출력

Compute Shader
Thread와 Group ID
Buffer와 Texture 결과 Write
```

`ddx`, `ddy`처럼 인접 Fragment Invocation을 전제로 하는 Function은 일반 Vertex Shader에서 같은 의미로 사용할 수 없다.

Semantic과 Resource Access도 Target Profile이 지원해야 한다.

HLSL이라는 언어가 같다고 모든 함수가 모든 Stage에서 유효한 것은 아니다.

---

## Shader Model과 Target

Shader Model은 사용할 수 있는 HLSL 기능과 Shader Stage Capability의 범위를 나타낸다.

Unity Shader에서는 `#pragma target`으로 필요한 기능 수준을 지정할 수 있다.

```hlsl
#pragma target 4.5
```

높은 Target은 더 많은 기능을 사용할 수 있지만 낮은 사양 Device와 Graphics API 지원 범위를 줄일 수 있다.

```text
필요 기능 증가
→ 높은 Shader Target 필요 가능
→ 지원 Platform 범위 확인
```

필요 이상의 Target을 습관적으로 높이거나 Compile Error를 없애기 위해 무작정 변경하면 안 된다.

사용 기능과 Target Platform 요구사항을 기준으로 선택한다.

---

## HLSL과 GLSL

HLSL과 GLSL은 모두 고수준 Shader Language다.

```text
HLSL
DirectX에서 시작
Semantic과 HLSL Type, Intrinsic 사용

GLSL
OpenGL 계열에서 시작
Location, Built-in Variable과 GLSL 문법 사용
```

두 언어는 Vector, Matrix와 Shader Stage 같은 공통 개념을 표현하지만 문법과 Interface 방식이 완전히 일대일로 대응하지 않는다.

Vulkan은 Text HLSL이나 GLSL을 직접 실행하지 않고 SPIR-V Binary Module을 사용한다.

적절한 Compiler가 HLSL 또는 GLSL Source를 SPIR-V로 만들 수 있다.

---

## HLSL과 SPIR-V

Vulkan Target의 개념적인 Compile 흐름은 다음과 같다.

```text
HLSL Source
↓ HLSL Compiler의 SPIR-V Backend
SPIR-V Intermediate Representation
↓ Vulkan Shader Module과 Driver
GPU 실행 Code
```

SPIR-V는 사람이 주로 작성하는 고수준 Shader Language가 아니라 Graphics와 Compute Shader를 표현하는 Binary Intermediate Representation이다.

HLSL과 SPIR-V는 경쟁하는 동일 계층의 언어가 아니다.

```text
HLSL
개발자 Authoring Language

SPIR-V
Vulkan이 소비하는 Intermediate Representation
```

Unity 내부의 정확한 Compile Pipeline은 Unity Version, Compiler 선택과 Platform에 따라 달라질 수 있다.

---

## HLSL과 Metal

Apple Platform의 Graphics API는 Metal이며 Shader Language와 Binary 요구사항이 Direct3D와 다르다.

Unity는 HLSL 기반 Shader Source를 Platform Toolchain에 맞게 변환할 수 있다.

```text
Unity HLSL Source
↓ Cross-platform Shader Compilation
Metal Target용 Shader 표현
↓
Apple GPU
```

Cross-compilation이 모든 HLSL 기능을 모든 Platform에서 동일하게 지원한다는 의미는 아니다.

Platform Macro, Precision, Texture Coordinate Convention과 지원 Shader Feature를 확인해야 한다.

---

## Compile-time과 Runtime

Shader 작업에는 Compile 시점과 Runtime 시점의 구분이 중요하다.

```text
Compile-time
#include
#define
#if
#pragma와 Keyword Variant
Type 검사와 최적화

Runtime
Draw / Dispatch
Property와 Texture Binding
Shader Invocation
if와 Loop 실행
```

Preprocessor 조건으로 제거된 Code는 해당 Variant의 Runtime에 존재하지 않는다.

Runtime Branch는 Program에 남아 Invocation Data에 따라 선택될 수 있다.

Keyword를 늘리면 Runtime Branch를 줄일 수 있지만 Compile Variant 수가 증가할 수 있다.

---

## Shader Compile Error

HLSL Compile Error에는 파일, 줄 번호와 오류 내용이 포함될 수 있다.

```text
undeclared identifier
선언되지 않은 이름 사용

cannot convert
Type 변환 불일치

semantic is required
Stage Interface Semantic 문제

syntax error
괄호, 세미콜론 또는 문법 문제
```

Generated Variant와 Include File 때문에 Editor에 보이는 줄과 실제 Compile Unit의 관계가 복잡할 수 있다.

오류가 발생한 Graphics API, Pass, Keyword 조합과 Entry Point를 함께 확인한다.

한 Platform에서 Compile된다고 모든 Target에서 Compile되는 것은 아니다.

---

## Type 변환

HLSL은 일부 Type 사이의 변환을 허용하지만 Component 수와 Precision을 명시적으로 맞추는 편이 안전하다.

```hlsl
float3 rgb = float3(1.0, 0.5, 0.25);
float4 color = float4(rgb, 1.0);
```

Vector를 더 작은 Vector에 대입하면 Component가 잘리거나 Compiler Warning과 Error가 발생할 수 있다.

```hlsl
float4 value = float4(1, 2, 3, 4);
float3 xyz = value.xyz;
```

Color Alpha, Homogeneous Coordinate의 `w`와 Padding 값을 무심코 버리지 않도록 의도를 Code에 나타낸다.

---

## Precision

Unity HLSL에서는 `float`와 `half`를 목적에 맞게 선택할 수 있다.

```hlsl
float3 positionWS;
half3 normalWS;
half4 color;
```

World Position, 큰 UV 값과 민감한 Depth 계산에는 높은 Precision이 필요할 수 있다.

Color와 제한된 범위의 일부 계산은 `half`로 처리할 수 있다.

Mobile GPU에서는 Precision이 Register와 연산 비용에 영향을 줄 수 있지만 Desktop GPU에서는 `half`가 같은 Hardware Precision으로 처리될 수도 있다.

낮은 Precision은 Banding, Overflow, Flicker와 Normal 오차를 만들 수 있으므로 실제 Device에서 정확도와 성능을 함께 측정한다.

---

## Undefined 값과 초기화

Local Variable을 모든 Control Flow에서 대입하지 않으면 정의되지 않은 값을 사용할 수 있다.

```hlsl
half3 color;

if (condition)
{
    color = half3(1, 0, 0);
}

return half4(color, 1);
```

`condition`이 거짓일 때 `color`가 초기화되지 않는다.

```hlsl
half3 color = half3(0, 0, 0);

if (condition)
{
    color = half3(1, 0, 0);
}
```

CPU Debug Build에서 우연히 0처럼 보였던 감각을 GPU Shader에 적용하면 Platform마다 다른 Artifact가 생길 수 있다.

모든 경로에서 출력값을 명확히 초기화한다.

---

## Array와 Index

HLSL은 Array와 Buffer Indexing을 사용할 수 있다.

```hlsl
float weights[4];
float value = weights[index];
```

Index가 범위를 벗어났을 때 C#처럼 항상 관리되는 Exception이 발생한다고 기대하면 안 된다.

잘못된 Resource Index는 정의되지 않은 결과, Device Error 또는 Platform별 차이를 만들 수 있다.

```text
C# Array
Bounds Check와 Exception 가능

Shader Resource
Graphics API의 Robustness와 Compiler 규칙에 의존
```

Input Data와 Index 범위를 Application과 Shader 양쪽에서 검증한다.

---

## Debugging 방식

Shader에는 일반 C#처럼 모든 Invocation에서 `Debug.Log`를 호출하는 방식이 없다.

화면 Color나 Buffer에 중간값을 출력하여 확인할 수 있다.

```hlsl
return half4(input.normalWS * 0.5h + 0.5h, 1.0h);
```

```text
계산 중간값
↓ 0~1 Color로 변환
Render Target 출력
↓
화면에서 분포 확인
```

RenderDoc, PIX, Xcode GPU Frame Debugger 같은 도구의 Shader Debug 기능을 사용할 수도 있다.

최적화로 Local Variable이 제거되거나 Source와 Instruction 대응이 달라질 수 있으므로 Debug Build와 Capture 조건을 확인한다.

---

## 최소 URP HLSL 예제

Texture와 Color를 출력하는 기본 Shader는 다음 구조를 가질 수 있다.

```shaderlab
Shader "Custom/HLSLExample"
{
    Properties
    {
        _BaseMap("Base Map", 2D) = "white" {}
        _BaseColor("Base Color", Color) = (1, 1, 1, 1)
    }

    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

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
                float4 _BaseColor;
            CBUFFER_END

            Varyings vert(Attributes input)
            {
                Varyings output;
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                output.uv = input.uv * _BaseMap_ST.xy + _BaseMap_ST.zw;
                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                half4 textureColor = SAMPLE_TEXTURE2D(
                    _BaseMap,
                    sampler_BaseMap,
                    input.uv
                );

                return textureColor * _BaseColor;
            }
            ENDHLSL
        }
    }
}
```

이 Code에는 ShaderLab과 HLSL의 경계, Vertex와 Fragment Entry Point, Stage Interface, Texture Resource와 Material Constant가 모두 포함된다.

---

## 예제의 Data Flow

```text
Mesh
positionOS / uv
↓ Attributes
Vertex Shader
TransformObjectToHClip
UV Scale과 Offset
↓ Varyings
Rasterizer
UV Interpolation
↓
Fragment Shader
Texture Sampling
Base Color 곱
↓ SV_Target
Color Attachment
```

HLSL을 읽을 때 문법만 따라가기보다 Input이 어떤 Stage를 거쳐 어떤 Output으로 변환되는지 추적하는 편이 중요하다.

각 변수의 좌표 공간과 값 범위도 함께 표시하면 오류를 줄일 수 있다.

---

## HLSL 최적화는 Compiler와 함께 일어난다

작성한 Source Code가 그대로 한 줄씩 GPU Instruction이 되지는 않는다.

Compiler는 다음 최적화를 수행할 수 있다.

- 사용하지 않는 Code 제거
- Constant Folding
- Function Inlining
- Algebraic Simplification
- Loop Unroll 또는 유지
- Register Allocation
- Target Instruction 선택

```hlsl
float value = 2.0 * 3.0;
```

Compile 결과에서는 `6.0` Constant로 대체될 수 있다.

Source Line 수만으로 비용을 판단하지 않고 Compile된 Shader 통계와 GPU Profile을 확인한다.

---

## GPU 친화적인 HLSL

GPU 친화적인 Code는 단순히 짧은 Code를 뜻하지 않는다.

```text
Invocation이 충분히 독립적임
Memory Access가 예측 가능함
실행 그룹의 Branch가 비슷함
필요한 Precision을 사용함
Texture와 Buffer Access가 과도하지 않음
Register Pressure가 지나치지 않음
```

같은 Algorithm도 Data Layout, Branch Pattern과 Invocation 수에 따라 성능이 달라진다.

GPU Vendor마다 Wave 또는 SIMD Width, Cache와 Instruction 특성이 다르므로 일반 규칙은 출발점으로만 사용한다.

---

## HLSL Code 비용을 판단하는 질문

```text
어느 Stage에서 실행되는가?
→ Vertex / Fragment / Compute

몇 Invocation이 실행되는가?
→ Vertex 수 / Coverage / Thread 수

어떤 Resource를 읽고 쓰는가?
→ Texture / Buffer / Render Target

Branch와 Loop가 Data마다 갈리는가?
→ Divergence 가능성

어떤 Precision과 Type을 사용하는가?
→ 정확도와 Register

어떤 Variant와 Target으로 Compile되는가?
→ 실제 실행 Program 확인
```

한 번의 연산 비용보다 전체 Workload에서 몇 번 반복되고 어떤 Memory를 사용하는지가 더 중요할 수 있다.

---

## 자주 생기는 오해

### HLSL은 DirectX에서만 사용할 수 있다

HLSL은 DirectX에서 시작했지만 적절한 Compiler를 통해 Vulkan의 SPIR-V 같은 다른 Target에도 사용할 수 있다.

Unity도 HLSL 기반 Source를 여러 Graphics API용으로 처리한다.

### HLSL은 GPU용 C#이다

문법 일부가 비슷할 뿐 Managed Object, Garbage Collection, Component Reference와 실행 모델이 다르다.

### Shader 함수는 Object마다 한 번 실행된다

Vertex, Fragment 또는 Compute Invocation마다 실행된다.

한 Object에서도 수많은 Invocation이 발생할 수 있다.

### Source Code 순서대로 모든 Invocation이 실행된다

각 Invocation 내부의 Program 의미는 유지되지만 Invocation 사이의 상대 실행 순서를 일반 Loop처럼 가정할 수 없다.

### `half`는 항상 정확히 16bit이고 두 배 빠르다

실제 Precision과 성능은 Compiler, Shader Model과 GPU Hardware에 따라 달라진다.

### HLSL File을 GPU가 직접 읽는다

Source는 Compiler를 거쳐 Target API와 Driver가 사용할 Binary 또는 Intermediate Representation으로 변환된다.

### ShaderLab과 HLSL은 같은 언어다

ShaderLab은 Unity Shader Object의 구조와 Render State를 정의하고 HLSL은 Programmable Stage의 계산을 정의한다.

---

## HLSL을 읽는 순서

```text
1. #pragma에서 Entry Point 확인
↓
2. Attributes와 Vertex Input 확인
↓
3. Vertex Shader의 Coordinate 변환 확인
↓
4. Varyings와 Semantic 확인
↓
5. Texture, Buffer와 Constant 선언 확인
↓
6. Fragment Shader의 출력 확인
↓
7. Keyword와 Include에 따른 실제 Variant 확인
↓
8. ShaderLab의 Depth, Blend와 Pass State 연결
```

이 순서로 보면 개별 수식보다 Pipeline Data Flow를 먼저 파악할 수 있다.

---

## 정리

HLSL은 High Level Shading Language의 줄임말이며 GPU의 Programmable Shader Stage를 작성하는 C 계열 고수준 언어다.

Unity에서는 ShaderLab의 `HLSLPROGRAM` Block 안에 HLSL Code를 작성할 수 있다.

```text
ShaderLab
Shader, SubShader, Pass와 Render State 구조

HLSL
Vertex, Fragment와 Compute Stage의 계산
```

HLSL Source는 GPU가 Text로 직접 실행하지 않는다.

Unity의 Shader Toolchain과 Compiler가 Target Graphics API에 필요한 표현으로 변환하고 Driver가 GPU 실행을 준비한다.

Direct3D에서 시작한 언어지만 Unity는 여러 Graphics API를 Target으로 사용할 수 있으며 Vulkan에서는 HLSL을 SPIR-V로 Compile할 수 있다.

HLSL은 Scalar, Vector, Matrix, Struct, Function, 조건문과 반복문을 제공한다.

Semantic은 변수와 Vertex Attribute, Stage Interface, System Value와 Render Target Output의 의미를 연결한다.

Vertex Shader Entry Point는 Vertex Attribute를 처리하고 Clip Space Position과 Varying을 출력한다.

Fragment Shader Entry Point는 보간된 Varying, Texture와 Material 값을 처리하여 Color 같은 Fragment Output을 만든다.

```text
한 HLSL Program
↓
많은 Shader Invocation
↓
서로 다른 Vertex 또는 Fragment Data 병렬 처리
```

HLSL과 C#은 문법이 비슷해 보여도 실행 장치와 Program Model이 다르다.

C#은 CPU에서 GameObject와 Component 상태를 관리하고 HLSL은 GPU에서 Binding된 숫자 Data와 Resource를 Invocation 단위로 처리한다.

Shader에는 Managed Object, Garbage Collection과 일반적인 C# Reference가 없으며 Local Variable이 다음 Frame까지 자동으로 유지되지 않는다.

GPU는 많은 Invocation을 병렬 실행하므로 Invocation 사이의 실행 순서를 일반 CPU Loop처럼 가정하면 안 된다.

Branch, Loop, Texture Access와 Local Variable의 비용은 실행 그룹, Invocation 수, Register와 Memory 구조에 영향을 받는다.

HLSL Source의 길이가 곧 GPU 비용은 아니며 Compile된 Variant와 Target Device의 GPU Profile을 확인해야 한다.

HLSL을 이해하는 핵심은 C 계열 문법을 외우는 데 그치지 않고 Stage별 Input과 Output, Invocation 수, Resource Binding과 병렬 실행 모델을 함께 파악하는 것이다.
