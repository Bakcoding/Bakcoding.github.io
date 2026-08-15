---
title: "[Unity 렌더링] 4-4. Vertex Shader와 Fragment Shader는 어떻게 데이터를 주고받을까?"
excerpt: "Unity Rendering"
categories:
  - Programming
tags:
  - Unity
  - Rendering
  - VertexShader
  - FragmentShader
  - Interpolation
permalink: /programming/unity-4-4-vertex-fragment-data/
toc: true
toc_sticky: true
date: 2026-08-15
last_modified_at: 2026-08-15
---

Vertex Shader는 Mesh의 Vertex마다 실행되고 Fragment Shader는 Rasterization이 만든 Fragment를 처리한다.

두 Stage의 실행 대상 수는 서로 다르다.

Triangle에는 세 Vertex만 있어도 화면에서 넓은 영역을 차지하면 수많은 Fragment가 만들어진다.

```text
Triangle Vertex
A, B, C
↓ Vertex Shader 3회에 대응
Vertex Output A, B, C
↓ Rasterization
Triangle 내부의 많은 Fragment
↓ Fragment Shader
```

Fragment Shader가 Texture를 읽으려면 각 Fragment 위치의 UV가 필요하고 Lighting을 계산하려면 Normal이나 World Position이 필요할 수 있다.

하지만 Mesh에는 Triangle 내부 모든 Fragment의 값이 저장되어 있지 않다.

Vertex Shader가 Vertex별 값을 출력하면 Rasterizer가 Triangle 내부 위치에 맞게 **Interpolation**하고 Fragment Shader Input으로 전달한다.

```text
Mesh Attribute
↓
Vertex Shader Input
↓ Vertex Shader
Varying Output
↓ Rasterizer가 Interpolation
Fragment Shader Input
```

---

## 전체 Data Flow

Vertex Shader와 Fragment Shader 사이의 흐름은 세 단계로 나눌 수 있다.

```text
1. Attributes
Mesh Vertex Buffer에서 Vertex Shader로 들어오는 값

2. Varyings
Vertex Shader가 다음 Stage에 출력하는 Vertex별 값

3. Interpolation
Rasterizer가 Primitive 내부 Fragment 위치에 맞게 Varying을 계산
```

Unity URP의 기본적인 Struct 이름은 다음과 같이 작성할 수 있다.

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

`Attributes`와 `Varyings`는 HLSL Keyword가 아니라 개발자가 정한 Struct 이름이다.

Unity URP 문서와 Shader Code에서 역할을 명확하게 나타내기 위해 관례적으로 사용하는 이름이다.

---

## Attribute란?

Attribute는 Mesh의 각 Vertex에 저장된 입력 Data다.

```text
Vertex 0
Position / Normal / Tangent / UV / Color

Vertex 1
Position / Normal / Tangent / UV / Color

Vertex 2
Position / Normal / Tangent / UV / Color
```

Vertex Buffer에는 Attribute가 특정 Layout과 Format으로 배치된다.

Draw Call에서 Vertex Input State와 Shader Interface가 이 Data를 Vertex Shader Input에 연결한다.

```text
Mesh Vertex Buffer
↓ Vertex Fetch
Attribute Semantic과 Format
↓
Vertex Shader Input Struct
```

Attribute는 Object 전체에 하나만 존재하는 Material Property와 다르다.

Material Color가 Draw에 공통으로 전달될 수 있다면 Vertex Color는 Vertex마다 다른 값을 가질 수 있다.

---

## 대표적인 Vertex Attribute

| Attribute | Semantic | 일반적인 의미 |
| --- | --- | --- |
| Position | `POSITION` | Object Space Vertex 위치 |
| Normal | `NORMAL` | Vertex의 표면 방향 |
| Tangent | `TANGENT` | Tangent Space Basis 구성 정보 |
| UV | `TEXCOORD0` 등 | Texture Coordinate 또는 임의 Data |
| Vertex Color | `COLOR` | Vertex별 Color 또는 Mask |
| Blend Weight | `BLENDWEIGHT` | Skinning Bone Weight |
| Blend Index | `BLENDINDICES` | Skinning Bone Index |

Semantic은 Data의 의미와 Pipeline Interface를 연결한다.

```hlsl
float4 positionOS : POSITION;
float3 normalOS   : NORMAL;
float4 tangentOS  : TANGENT;
float2 uv         : TEXCOORD0;
float4 color      : COLOR;
```

변수 이름은 자유롭게 정할 수 있지만 Semantic은 어떤 Vertex Attribute Channel을 받을지 결정한다.

```hlsl
float4 anyName : POSITION;
```

`anyName`이어도 `POSITION` Semantic 때문에 Position Attribute에 연결된다.

---

## Mesh에 없는 Attribute

Shader가 `NORMAL`을 요청해도 Mesh에 Normal Data가 없으면 의도한 Lighting 결과를 만들 수 없다.

```text
Shader Input
NORMAL 요청

Mesh
Normal Channel 없음

→ 유효한 Normal을 기대할 수 없음
```

Unity Importer가 Normal을 계산하도록 설정할 수 있지만 모든 Mesh와 Runtime 생성 Mesh가 자동으로 같은 Data를 가진다고 가정하면 안 된다.

UV, Tangent와 Vertex Color도 사용 전에 Mesh Channel과 Import 설정을 확인해야 한다.

필요하지 않은 Attribute를 Shader Input에서 선언한다고 항상 큰 비용이 발생하는 것은 아니지만 실제 사용 Data와 Interface를 단순하게 유지하는 편이 오류를 줄인다.

---

## Vertex Shader Input

Vertex Shader Entry Point는 `Attributes` Struct를 Input으로 받을 수 있다.

```hlsl
Varyings vert(Attributes input)
{
    Varyings output;
    // input.positionOS
    // input.normalOS
    // input.uv
    return output;
}
```

각 Invocation에는 자신이 처리하는 Vertex의 Attribute가 들어온다.

```text
Invocation 0
Vertex 0 Attributes

Invocation 1
Vertex 1 Attributes

Invocation 2
Vertex 2 Attributes
```

Vertex Shader가 Mesh 전체 Array를 Input으로 받는 구조가 아니다.

일반적인 Invocation은 한 Vertex의 Data를 처리한다.

---

## Vertex Shader Output

Vertex Shader는 Rasterizer가 Primitive를 만들 수 있도록 Clip Space Position을 출력해야 한다.

```hlsl
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
```

`SV_POSITION`은 Rasterizer가 Vertex 위치를 처리하기 위한 System-value Semantic이다.

```text
Object Space Position
↓ TransformObjectToHClip
Clip Space Position
↓ SV_POSITION
Clipping / Perspective Divide / Rasterization
```

Position 이외의 Output은 Fragment Shader에 전달할 Varying으로 사용할 수 있다.

---

## Varying이란?

Varying은 Vertex Processing Stage의 출력에서 Fragment Shader Input으로 이어지는 사용자 정의 Data를 가리킨다.

Vertex마다 값이 다를 수 있고 Triangle 내부에서 그 값이 보간되기 때문에 Varying이라는 이름을 사용한다.

```text
Vertex A UV = (0, 0)
Vertex B UV = (1, 0)
Vertex C UV = (0, 1)

↓ Rasterization

Triangle 내부 Fragment마다 서로 다른 UV
```

Unity URP Code에서는 Vertex Shader Output Struct 자체를 `Varyings`라고 이름 붙이는 경우가 많다.

```hlsl
struct Varyings
{
    float4 positionCS : SV_POSITION;
    float2 uv         : TEXCOORD0;
};
```

`TEXCOORD0`이라는 이름이 Texture UV만 전달할 수 있다는 의미는 아니다.

일반적인 User-defined Stage Data Channel로 World Position, Normal, Fog Factor와 다른 값을 전달할 수 있다.

---

## Vertex Shader가 Fragment Shader를 직접 호출할까?

Vertex Shader 안에서 Fragment Shader 함수를 직접 호출하여 값을 넘기는 구조가 아니다.

```text
잘못된 이해
Vertex Shader → Fragment Shader 함수 호출

실제 흐름
Vertex Shader Output
↓ Primitive 구성
Rasterizer가 Fragment 생성과 보간
↓
Fragment Shader Invocation
```

Vertex Shader Invocation은 Vertex 수를 기준으로 실행되고 Fragment Shader Invocation은 Rasterization 결과를 기준으로 실행된다.

두 Stage 사이에서 Rasterizer가 Data의 개수와 위치를 확장한다.

---

## UV 전달

Mesh의 UV를 Fragment Shader까지 전달하는 가장 단순한 흐름은 다음과 같다.

```hlsl
struct Attributes
{
    float4 positionOS : POSITION;
    float2 uv         : TEXCOORD0;
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    float2 uv         : TEXCOORD0;
};

Varyings vert(Attributes input)
{
    Varyings output;
    output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
    output.uv = input.uv;
    return output;
}

half4 frag(Varyings input) : SV_Target
{
    return SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv);
}
```

```text
Mesh UV
↓ Attributes.uv
Vertex Shader
↓ Varyings.uv
Rasterizer Interpolation
↓ Fragment input.uv
Texture Sampling
```

Texture Sampling의 Sampler와 Filtering 세부 동작은 다음 문서에서 다룬다.

---

## UV Transform은 어디에서 할까?

Material의 Tiling과 Offset을 Vertex Shader에서 적용할 수 있다.

```hlsl
output.uv = input.uv * _BaseMap_ST.xy + _BaseMap_ST.zw;
```

Unity Macro를 사용하면 다음과 같이 작성할 수 있다.

```hlsl
output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
```

```text
Mesh UV
↓ Tiling
Scale
↓ Offset
Transformed UV
↓ Interpolation
Fragment UV
```

선형적인 UV Transform은 Vertex에서 계산하고 보간해도 Fragment마다 같은 식을 반복하는 것보다 연산을 줄일 수 있다.

반면 Fragment 위치마다 달라지는 비선형 왜곡은 Vertex 계산 결과를 단순 보간하는 것과 Fragment에서 직접 계산하는 결과가 다를 수 있다.

---

## Vertex Color 전달

Vertex Color를 Varying으로 전달할 수 있다.

```hlsl
struct Attributes
{
    float4 positionOS : POSITION;
    half4 color       : COLOR;
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    half4 color       : COLOR;
};
```

Vertex Shader에서 복사한다.

```hlsl
output.color = input.color;
```

Fragment Shader에서 사용한다.

```hlsl
return input.color;
```

세 Vertex의 Color가 다르면 Triangle 내부에서 Gradient가 만들어진다.

```text
Vertex A = Red
Vertex B = Green
Vertex C = Blue
↓ Interpolation
Triangle 내부의 연속적인 Color
```

---

## World Position 전달

Fragment Lighting과 Fog, World Space Pattern을 계산하려면 Fragment 위치의 World Position이 필요할 수 있다.

```hlsl
struct Varyings
{
    float4 positionCS : SV_POSITION;
    float3 positionWS : TEXCOORD0;
};

Varyings vert(Attributes input)
{
    Varyings output;
    output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
    output.positionWS = TransformObjectToWorld(input.positionOS.xyz);
    return output;
}
```

Fragment Shader에는 Triangle 내부 위치의 보간된 World Position이 들어온다.

```hlsl
float distanceToPoint = distance(input.positionWS, _EffectCenterWS.xyz);
```

평면 Triangle 위의 Position은 Barycentric Weight로 보간할 수 있다.

Skinned, Displaced 또는 Tessellated Geometry에서는 최종 Vertex Position 변형을 적용한 뒤 같은 Coordinate Space의 값을 출력해야 화면 Geometry와 계산 위치가 일치한다.

---

## Normal 전달

Object Space Normal을 World Space로 변환하여 전달할 수 있다.

```hlsl
struct Attributes
{
    float4 positionOS : POSITION;
    float3 normalOS   : NORMAL;
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    half3 normalWS    : TEXCOORD0;
};

Varyings vert(Attributes input)
{
    Varyings output;
    output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
    output.normalWS = TransformObjectToWorldNormal(input.normalOS);
    return output;
}
```

Normal도 Triangle 내부에서 보간된다.

보간된 Normal의 길이는 1이 아닐 수 있으므로 Fragment Shader에서 다시 Normalize하는 경우가 많다.

```hlsl
half3 normalWS = normalize(input.normalWS);
```

```text
Vertex Normal
↓ Interpolation
길이가 달라질 수 있는 Fragment Normal
↓ normalize
Lighting에 사용할 Unit Normal
```

Normal Map과 Tangent Space의 상세 구조는 `4-6` 문서에서 다룬다.

---

## 왜 Interpolation이 필요할까?

Mesh에는 Vertex 위치에만 UV, Normal과 Color가 저장된다.

Fragment Shader는 Triangle 내부의 수많은 위치에서 실행된다.

```text
저장된 Data
Vertex A, B, C의 값 3개

필요한 Data
Triangle 내부 Fragment 각각의 값
```

모든 예상 Pixel 위치의 값을 Mesh에 저장하는 것은 Camera, 해상도와 Projection이 바뀔 때 사용할 수 없다.

Rasterizer는 현재 화면에서 생성된 Fragment 위치를 기준으로 Vertex Output을 보간한다.

이 방식으로 적은 Vertex Data에서 연속적인 표면 값을 만든다.

---

## Barycentric Coordinate

Triangle 내부의 위치는 세 Vertex에 대한 Weight로 표현할 수 있다.

```text
Weight A = a
Weight B = b
Weight C = c

a + b + c = 1
```

Triangle Vertex의 값이 `fA`, `fB`, `fC`라면 단순한 선형 보간은 다음과 같다.

```text
f = a × fA + b × fB + c × fC
```

Vertex A에 가까우면 `a`가 크고 Vertex B에 가까우면 `b`가 커진다.

```text
Vertex A 위치
a = 1, b = 0, c = 0
→ f = fA

Triangle 중심에 가까운 위치
a ≈ b ≈ c ≈ 1/3
→ 세 값이 비슷하게 섞임
```

이 Weight를 Barycentric Coordinate라고 한다.

---

## 선형 Interpolation 예제

세 Vertex의 Scalar 값이 다음과 같다고 가정할 수 있다.

```text
fA = 0
fB = 1
fC = 0.5

a = 0.2
b = 0.5
c = 0.3
```

단순 선형 보간은 다음과 같다.

```text
f = 0.2 × 0
  + 0.5 × 1
  + 0.3 × 0.5

f = 0.65
```

Color, UV와 World Position의 각 Component에도 같은 Weight 구조를 적용할 수 있다.

하지만 Perspective Projection이 적용된 화면에서 UV 같은 값을 단순 Screen Space Weight로만 보간하면 왜곡이 생긴다.

---

## Perspective 때문에 생기는 문제

원근 투영에서는 Camera에 가까운 부분과 먼 부분의 화면 크기가 다르게 축소된다.

```text
World Space의 같은 길이

Camera 가까이
화면에서 크게 보임

Camera 멀리
화면에서 작게 보임
```

Triangle Vertex를 Screen Space로 Projection한 뒤 UV를 화면상 거리만으로 선형 보간하면 3D Surface 위의 일정한 Texture 간격이 유지되지 않는다.

```text
단순 Screen Space Linear UV
→ 멀어지는 Surface에서 Texture가 휘거나 미끄러지는 왜곡
```

그래서 기본 Varying은 Clip Space의 `w`를 고려하는 Perspective-correct Interpolation을 사용한다.

---

## Perspective-correct Interpolation

Perspective-correct Interpolation은 각 Vertex 값과 Clip `w`를 함께 고려한다.

개념적인 형태는 다음과 같다.

```text
f = (a × fA / wA + b × fB / wB + c × fC / wC)
    ------------------------------------------------
    (a / wA + b / wB + c / wC)
```

`a`, `b`, `c`는 화면 위치의 Barycentric Weight이고 `wA`, `wB`, `wC`는 각 Vertex의 Clip `w`다.

```text
Vertex별 값
↓ 1 / clip.w를 고려
Screen Space에서 보간
↓ 보정
Perspective에 맞는 Fragment 값
```

개발자가 일반 UV Varying마다 이 식을 직접 작성할 필요는 없다.

Graphics Pipeline이 기본 Interpolation 규칙으로 처리한다.

---

## 단순 선형과 Perspective-correct 비교

| 구분 | Screen Space Linear | Perspective-correct |
| --- | --- | --- |
| Clip `w` 고려 | 하지 않음 | 고려함 |
| 화면상 변화 | 화면 거리에 선형 | 3D Perspective에 맞게 보정 |
| 일반 UV | 왜곡 가능 | 기본적으로 적합 |
| HLSL Modifier | `noperspective` | 기본값 |

화면 공간에서 정말 선형이어야 하는 값에는 `noperspective`가 필요할 수 있다.

일반적인 Mesh UV와 World Space Data는 기본 Perspective-correct Interpolation을 사용하는 경우가 많다.

---

## HLSL의 기본 Interpolation

별도의 Modifier가 없는 Floating-point Varying은 기본적으로 Perspective-correct 방식으로 보간된다.

```hlsl
struct Varyings
{
    float4 positionCS : SV_POSITION;
    float2 uv         : TEXCOORD0;
    half3 normalWS    : TEXCOORD1;
};
```

`uv`와 `normalWS`는 Fragment 위치에 맞게 보간된다.

Position의 `SV_POSITION`은 일반 User Varying과 다른 System-value 역할을 가지며 Rasterization 후 Fragment Stage에서 Window Position에 대응하는 값으로 제공된다.

---

## `nointerpolation`

Primitive 전체에서 같은 값을 사용하고 싶다면 HLSL의 `nointerpolation` Modifier를 사용할 수 있다.

```hlsl
struct Varyings
{
    float4 positionCS : SV_POSITION;
    nointerpolation uint materialId : TEXCOORD0;
};
```

```text
Vertex별 Material ID
↓ 보간하지 않음
Provoking Vertex의 값
↓
Primitive의 모든 Fragment에서 동일한 값
```

Integer와 Integer Vector Fragment Input은 일반적인 수치 보간이 적합하지 않으므로 Flat 또는 `nointerpolation` 형태가 필요하다.

어느 Vertex의 값이 선택되는지는 Graphics API의 Provoking Vertex 규칙에 연결된다.

세 Vertex에 서로 다른 ID를 넣고 임의의 하나를 기대하는 방식보다 Primitive 전체에서 같은 값을 출력하도록 Data를 구성하는 편이 명확하다.

---

## `noperspective`

`noperspective`는 Clip `w` 보정 없이 Screen Space에서 선형 Interpolation을 사용한다.

```hlsl
struct Varyings
{
    float4 positionCS : SV_POSITION;
    noperspective float2 screenValue : TEXCOORD0;
};
```

화면 공간 거리, Line Width와 Screen-space Pattern처럼 Perspective와 무관하게 화면상 선형 변화가 필요한 Data에 사용할 수 있다.

```text
기본 Interpolation
3D Perspective를 고려

noperspective
Screen Space Barycentric Weight로 선형 보간
```

일반 UV에 무심코 적용하면 원근이 있는 Surface에서 Texture 왜곡이 생길 수 있다.

---

## `centroid`

MSAA Edge Pixel에서는 Pixel 중심이 Primitive 밖에 있지만 일부 Sample만 Primitive 안에 있을 수 있다.

```text
Pixel
+---------+
| ×     × |
|   C     |
| ×     × |
+---------+

C = Pixel 중심
× = MSAA Sample
```

`centroid`는 Primitive가 덮는 영역 안의 위치에서 값을 평가하도록 제한한다.

```hlsl
centroid float2 uv : TEXCOORD0;
```

Triangle Edge에서 Pixel 중심 기준 UV가 Primitive 밖으로 외삽되어 Texture Atlas 경계를 읽는 문제를 줄이는 데 도움이 될 수 있다.

정확한 평가 위치는 Implementation이 선택할 수 있으며 Covered Sample 중 하나와 반드시 같은 위치라고 단정할 수 없다.

Centroid 위치가 이웃 Fragment마다 달라지면 Derivative가 일반 Interpolation보다 불안정할 수 있으므로 필요한 Input에만 사용한다.

---

## `sample`

`sample` Modifier는 현재 Shading Sample의 위치에서 Varying을 평가하도록 요청한다.

```hlsl
sample float2 uv : TEXCOORD0;
```

MSAA에서 Sample별로 더 정확한 Attribute 값을 얻을 수 있다.

```text
Pixel 안의 Sample 0
→ Sample 0 위치의 UV

Pixel 안의 Sample 1
→ Sample 1 위치의 UV
```

Sample Frequency Shading과 연결되어 Fragment Shader Invocation과 연산량이 증가할 수 있다.

필요한 Edge 품질과 비용, Shader Target 및 Platform 지원을 확인한 뒤 사용한다.

---

## Modifier 비교

| Modifier | 보간 방식 | 대표 목적 |
| --- | --- | --- |
| 기본 | Perspective-correct | UV, World Position, Normal 등 |
| `nointerpolation` | 보간하지 않음 | Integer ID, Primitive별 값 |
| `noperspective` | Screen Space Linear | 화면 공간 거리와 Pattern |
| `centroid` | Covered 영역 안에서 평가 | MSAA Edge의 외삽 완화 |
| `sample` | 개별 Sample 위치에서 평가 | Sample별 정확한 값 |

Modifier 문법과 지원 범위는 Target Shader Model, Graphics API와 Unity Compiler Backend에 따라 확인해야 한다.

---

## Interpolation은 Vertex Shader에서 실행될까?

Vertex Shader가 Triangle 내부의 값을 직접 계산하는 것은 아니다.

```text
Vertex Shader
세 Vertex의 Output 계산

Rasterizer
Fragment 위치와 Weight 계산
Varying Interpolation

Fragment Shader
보간된 Input 사용
```

Interpolation은 Vertex Shader와 Fragment Shader 사이의 Rasterization 과정에 포함된 Fixed-function 역할이다.

Fragment Shader는 일반적으로 이미 보간된 값을 Input으로 받는다.

---

## Stage Interface가 맞아야 한다

Vertex Shader Output과 Fragment Shader Input은 Semantic과 Type이 연결되어야 한다.

```hlsl
struct VertexOutput
{
    float4 positionCS : SV_POSITION;
    float2 uv         : TEXCOORD0;
};

struct FragmentInput
{
    float4 positionCS : SV_POSITION;
    float2 uv         : TEXCOORD0;
};
```

다음처럼 같은 `TEXCOORD0`에 서로 다른 Type을 사용하면 Interface가 일치하지 않는다.

```hlsl
// Vertex Output
float2 uv : TEXCOORD0;

// Fragment Input
float3 normalWS : TEXCOORD0;
```

Compiler 또는 Link 단계에서 오류가 발생하거나 지원되지 않는 Interface가 될 수 있다.

변수 이름보다 Semantic, Component 수, Type과 Interpolation Qualifier를 확인한다.

---

## 같은 Struct를 사용하는 이유

Unity Shader 예제에서는 Vertex Shader 반환 Type과 Fragment Shader Parameter Type에 같은 `Varyings` Struct를 사용한다.

```hlsl
Varyings vert(Attributes input)
{
    Varyings output;
    // ...
    return output;
}

half4 frag(Varyings input) : SV_Target
{
    // ...
}
```

이 방식은 두 Stage의 Interface를 한 곳에서 정의하여 Type과 Semantic 불일치를 줄인다.

실제 Graphics Pipeline에서는 Vertex별 `Varyings` Object 하나가 그대로 Fragment 함수에 전달되는 것이 아니다.

Rasterizer가 세 Vertex Output을 이용해 Fragment마다 새로운 보간값을 만든다.

---

## 사용하지 않는 Varying

Vertex Shader가 값을 출력해도 Fragment Shader가 사용하지 않으면 Compiler가 Interface와 계산을 최적화할 수 있다.

```hlsl
output.extraValue = expensiveCalculation;
```

Fragment Shader와 이후 Stage에서 `extraValue`를 전혀 사용하지 않는다면 Dead Code로 제거될 가능성이 있다.

하지만 Variant, Debug Mode와 다른 Entry Point에서 사용될 수 있으므로 Source만 보고 실제 제거를 확정하지 않는다.

Compile된 Shader와 Generated Code를 확인한다.

---

## Interpolator 자원

Varying은 무제한으로 전달할 수 없다.

GPU와 Shader Target은 Stage 사이 Interface Component와 Interpolator 수에 제한을 가진다.

```text
많은 Varying
World Position
Normal
Tangent
Bitangent
여러 UV
Vertex Color
Fog
Shadow Coordinate
Custom Data
```

필요 이상의 값을 모두 전달하면 Interface Bandwidth와 Register 사용량이 증가하고 낮은 Shader Target에서 Limit을 초과할 수 있다.

Fragment Shader에서 재구성하는 비용과 Varying으로 전달하는 비용을 비교해야 한다.

---

## Component Packing

여러 작은 값을 같은 `TEXCOORD` Vector Component에 묶을 수 있다.

```hlsl
struct Varyings
{
    float4 positionCS : SV_POSITION;
    float4 packedData : TEXCOORD0;
};

// packedData.xy = uv
// packedData.z  = fogFactor
// packedData.w  = customMask
```

```text
TEXCOORD0.xy → UV
TEXCOORD0.z  → Fog
TEXCOORD0.w  → Mask
```

Packing은 Interpolator Slot 사용을 줄이는 데 도움이 될 수 있다.

반대로 의미가 불명확해지고 Precision 요구가 다른 값을 억지로 묶으면 유지보수와 정확도 문제가 생길 수 있다.

Compiler와 Target의 실제 Packing 규칙도 확인해야 한다.

---

## Precision 선택

Varying Type의 Precision도 고려할 수 있다.

```hlsl
float3 positionWS : TEXCOORD0;
half3 normalWS    : TEXCOORD1;
half4 color       : COLOR;
```

World Position처럼 범위가 크고 정확도가 필요한 값은 `float`가 필요할 수 있다.

제한된 범위의 Color와 일부 Normal은 `half`를 사용할 수 있다.

```text
Precision을 너무 낮춤
→ Banding, 흔들림, Lighting Artifact

필요 이상 높은 Precision
→ 일부 Mobile GPU에서 Register와 Bandwidth 증가 가능
```

실제 Interpolator Precision과 성능 차이는 Platform과 Compiler에 따라 달라진다.

화질과 GPU 시간을 Target Device에서 확인한다.

---

## Coordinate Space를 함께 표시해야 한다

같은 `float3`라도 Coordinate Space가 다르면 계산할 수 없다.

```hlsl
float3 positionOS;
float3 positionWS;
float3 normalWS;
float3 viewDirectionWS;
```

변수 이름에 `OS`, `WS`, `VS`, `CS`를 붙이면 Data Flow에서 Space를 구분하기 쉽다.

```text
positionOS
↓ TransformObjectToWorld
positionWS
↓ TransformWorldToHClip
positionCS
```

Vertex Shader에서 World Space Normal을 출력했다면 Fragment Shader의 Light Direction도 World Space로 맞춰야 한다.

Interpolation이 Coordinate Space 불일치를 자동으로 해결하지 않는다.

---

## Full URP 예제

Vertex Attribute를 전달하고 Fragment Shader에서 간단한 Lighting을 계산하는 Shader는 다음 구조를 가질 수 있다.

```shaderlab
Shader "Custom/InterpolatedData"
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
                float3 normalOS   : NORMAL;
                float2 uv         : TEXCOORD0;
                half4 color      : COLOR;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
                half3 normalWS    : TEXCOORD1;
                float2 uv         : TEXCOORD2;
                half4 color       : COLOR;
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
                half4 _BaseColor;
            CBUFFER_END

            Varyings vert(Attributes input)
            {
                Varyings output;

                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                output.positionWS = TransformObjectToWorld(input.positionOS.xyz);
                output.normalWS = TransformObjectToWorldNormal(input.normalOS);
                output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
                output.color = input.color;

                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                half3 normalWS = normalize(input.normalWS);
                half3 lightDirectionWS = normalize(half3(0.4, 0.8, 0.2));
                half NdotL = saturate(dot(normalWS, lightDirectionWS));

                half4 textureColor = SAMPLE_TEXTURE2D(
                    _BaseMap,
                    sampler_BaseMap,
                    input.uv
                );

                half3 color = textureColor.rgb
                    * _BaseColor.rgb
                    * input.color.rgb
                    * NdotL;

                return half4(color, textureColor.a * _BaseColor.a);
            }
            ENDHLSL
        }
    }
}
```

---

## 예제의 Data Flow

```text
Mesh Vertex
positionOS / normalOS / uv / color
↓
Vertex Shader
positionCS / positionWS / normalWS / transformed UV / color
↓
Primitive Assembly
Triangle의 세 Vertex Output
↓
Rasterization
Fragment Coverage와 Perspective-correct Interpolation
↓
Fragment Shader
보간된 positionWS / normalWS / uv / color
↓
Texture와 간단한 Lighting
↓
Source Color
```

Fragment Shader에 들어오는 `input`은 한 Vertex의 원본 `Varyings`가 아니다.

현재 Fragment를 만든 Primitive의 Vertex Output을 보간한 결과다.

---

## Vertex에서 계산할지 Fragment에서 계산할지

같은 값을 Vertex Shader에서 계산해 보간할 수도 있고 Fragment Shader에서 직접 계산할 수도 있다.

```text
Vertex에서 계산
실행 횟수 적음
↓ 보간
근사된 Fragment 값

Fragment에서 계산
실행 횟수 많음
Fragment마다 직접 계산
```

Vertex Lighting은 Vertex에서 밝기를 계산하고 Fragment까지 보간한다.

Geometry가 성기면 Highlight나 작은 Light 변화가 Vertex 사이에서 손실될 수 있다.

Per-fragment Lighting은 보간된 Normal과 Position으로 Fragment마다 계산하여 더 세밀하지만 연산 횟수가 증가한다.

화질과 Vertex Density, Fragment Coverage, Shader Cost를 기준으로 선택한다.

---

## 비선형 연산과 보간 순서

일반적으로 비선형 연산은 Vertex에서 계산한 결과를 보간하는 것과 보간한 Input으로 Fragment에서 계산하는 결과가 다르다.

```text
방법 A
각 Vertex에서 normalize
↓
Normalized Vector를 보간

방법 B
Vector를 보간
↓
Fragment에서 normalize
```

보간은 선형 결합이므로 Unit Vector를 보간하면 길이가 1이 아닐 수 있다.

Lighting Normal은 Fragment에서 다시 Normalize하는 이유가 여기에 있다.

```text
normalize(lerp(A, B, t))
≠
lerp(normalize(A), normalize(B), t)
```

연산을 Vertex Stage로 옮길 때 단순한 성능 이동뿐 아니라 수학적 결과 변화도 확인해야 한다.

---

## 값의 범위를 넘는 외삽

일반 Interpolation 위치가 Primitive Coverage 내부로 제한되지 않는 경우 Triangle Edge에서 평가값이 Vertex 범위를 조금 벗어날 수 있다.

특히 MSAA에서 Pixel 중심은 Primitive 밖에 있고 일부 Sample만 안에 있을 수 있다.

```text
UV Atlas Edge
Primitive 밖으로 외삽된 UV
↓
이웃 Tile Texture를 읽을 가능성
```

Texture Padding, Clamp, Centroid Interpolation과 Sample 위치 평가가 해결 방향이 될 수 있다.

Centroid 하나만으로 모든 Atlas Bleeding이 해결되는 것은 아니며 Mipmap과 Filtering Padding도 함께 고려해야 한다.

---

## Derivative와 Interpolation

Fragment Shader의 `ddx`, `ddy`는 이웃 Invocation 사이에서 보간된 값의 차이를 계산하는 데 사용할 수 있다.

```hlsl
float2 uvDx = ddx(input.uv);
float2 uvDy = ddy(input.uv);
```

Texture Sampling은 UV Derivative를 이용해 Mipmap Level을 선택할 수 있다.

```text
Vertex UV
↓ Perspective-correct Interpolation
Fragment UV
↓ 이웃 Fragment와 차이
UV Derivative
↓
Texture LOD 선택
```

`centroid`처럼 이웃 Fragment에서 평가 위치가 달라질 수 있는 Modifier는 Derivative의 일관성에 영향을 줄 수 있다.

Interpolation 방식은 단순히 전달값만 아니라 이후 Texture Sampling에도 연결된다.

---

## MSAA에서의 Interpolation

MSAA에서는 Pixel 안에 여러 Sample 위치가 존재한다.

기본 Fragment Input은 Implementation이 허용하는 위치에서 한 번 평가되어 Covered Sample에 공유될 수 있다.

```text
Pixel Frequency
한 Interpolated Input
↓
여러 Covered Sample에 사용 가능
```

`sample` Modifier를 사용하면 Sample 위치별 값을 요구할 수 있다.

```text
Sample Frequency
Sample 0 위치 Input
Sample 1 위치 Input
...
```

정확도는 높아질 수 있지만 Invocation과 계산 비용이 증가할 수 있다.

MSAA Sample 수와 Fragment Shader 실행 수가 항상 일대일이라는 의미는 아니며 실제 Sample Shading 조건을 함께 확인한다.

---

## Primitive별 Data

모든 Data가 Vertex 사이에서 부드럽게 변해야 하는 것은 아니다.

Material ID, Face ID와 Primitive Category처럼 Triangle 전체에서 하나의 값을 사용해야 하는 Data가 있다.

```hlsl
nointerpolation uint primitiveCategory : TEXCOORD3;
```

Flat Data는 Provoking Vertex의 값을 사용하므로 Primitive의 모든 Vertex에 같은 값을 준비하거나 별도 Primitive Input 기능을 사용하는 편이 안전하다.

Integer를 Floating-point로 바꾸어 일반 보간한 뒤 반올림하는 방식은 Triangle 내부에서 잘못된 ID를 만들 수 있다.

---

## `SV_VertexID`와 생성 Data

Vertex Shader Input이 항상 Vertex Buffer Attribute만으로 구성되는 것은 아니다.

System-value Semantic을 통해 Vertex ID를 받을 수 있다.

```hlsl
struct Attributes
{
    uint vertexID : SV_VertexID;
};
```

Fullscreen Triangle처럼 Vertex Buffer 없이 ID를 이용해 Position과 UV를 생성할 수 있다.

```text
SV_VertexID 0, 1, 2
↓ Vertex Shader
Clip Position과 UV 생성
↓
Fullscreen Triangle
```

이 경우 생성한 UV도 Varying으로 출력되어 Fragment Stage에서 보간된다.

Platform과 Graphics API에서 System-value Semantic의 지원 조건을 확인해야 한다.

---

## Instancing Data와 Varying

GPU Instancing에서는 `SV_InstanceID` 또는 Unity Instancing Macro를 통해 Instance별 Data를 Vertex Shader에 전달할 수 있다.

Instance별 Color를 Fragment Shader에서 사용하려면 Varying으로 넘길 수 있다.

```text
Instance ID
↓ Vertex Shader에서 Instance Color 조회
Vertex별 동일 Color 출력
↓ Interpolation
Fragment Shader Input
```

Primitive 전체에서 같은 Color라도 Floating-point Varying이면 보간되며 세 Vertex 값이 같으므로 결과도 같다.

MaterialPropertyBlock, SRP Batcher와 GPU Instancing의 구체적인 호환성은 사용하는 Render Pipeline과 Shader 구성에서 확인한다.

---

## Debugging 방법

Varying이 올바르게 전달되는지 Fragment Color로 출력할 수 있다.

### UV 확인

```hlsl
return half4(input.uv, 0.0h, 1.0h);
```

### Normal 확인

```hlsl
half3 normalWS = normalize(input.normalWS);
return half4(normalWS * 0.5h + 0.5h, 1.0h);
```

### Vertex Color 확인

```hlsl
return input.color;
```

```text
의심되는 Varying
↓ 0~1 Color로 변환
Render Target 출력
↓
화면에서 연속성, 방향과 범위 확인
```

Coordinate Space Vector는 음수 Component가 있을 수 있으므로 `* 0.5 + 0.5`로 표시 범위에 옮긴다.

---

## Frame Debugger와 Graphics Debugger

Unity Frame Debugger는 어떤 Shader Pass와 Variant가 Draw에 사용되는지 확인하는 데 도움이 된다.

Stage Interface의 실제 값을 Pixel별로 모두 보여 주는 도구는 아니다.

RenderDoc, PIX와 Xcode GPU Frame Debugger 같은 Tool에서는 Vertex Input, Post-Vertex Shader Data와 Fragment Debug 기능을 제공할 수 있다.

```text
Vertex Input 확인
→ Mesh Attribute가 올바른가

Post-VS 확인
→ positionCS와 Varying Output이 올바른가

Pixel Debug 확인
→ 보간된 Fragment Input이 올바른가
```

Tool과 Graphics API에 따라 지원 범위와 값 표현이 다르다.

---

## 최적화할 때 확인할 항목

Stage 사이 Data 전달 비용을 줄이기 전에 실제 병목을 확인한다.

```text
Varying Limit에 가까운가?
→ Interface Component와 Compile Error 확인

Fragment Shader가 비싼가?
→ 선형 계산 일부를 Vertex로 옮길 수 있는지 확인

화질이 깨지는가?
→ Vertex Density와 비선형 연산 순서 확인

Precision이 과도한가?
→ Target GPU에서 half 정확도와 성능 비교

같은 값을 중복 전달하는가?
→ 재구성 비용과 Varying 비용 비교
```

World Position을 전달하지 않고 Depth와 Screen Coordinate로 재구성할 수 있지만 Matrix 연산과 Depth Texture Access가 추가될 수 있다.

Tangent와 Bitangent를 모두 전달하지 않고 일부 Basis를 재구성할 수 있지만 정확도와 연산량이 달라진다.

Varying을 줄이는 것 자체보다 Frame Time과 Register, Bandwidth 병목을 기준으로 선택한다.

---

## 자주 생기는 오해

### Vertex Shader가 Fragment Shader를 직접 호출한다

두 Stage 사이에는 Primitive Assembly와 Rasterization이 있다.

Vertex Output이 보간되어 Fragment Shader Input이 된다.

### Vertex 하나가 Fragment 하나와 대응한다

Triangle의 세 Vertex에서 화면 Coverage에 따라 많은 Fragment가 생성될 수 있다.

실행 단위와 수가 서로 다르다.

### `TEXCOORD0`에는 UV만 넣을 수 있다

User-defined Stage Data Channel로 World Position, Normal, Fog와 Custom 값을 전달할 수 있다.

### Varying은 단순한 평균이다

Triangle 위치에 따른 Barycentric Weight를 사용하며 기본 Floating-point Input은 Clip `w`를 고려한 Perspective-correct Interpolation을 사용한다.

### Normal은 보간 후에도 항상 Unit Vector다

Vector의 선형 결합은 길이 1을 보장하지 않는다.

Lighting에 사용하기 전에 Fragment에서 Normalize하는 경우가 많다.

### Integer ID도 UV처럼 보간할 수 있다

Integer Fragment Input은 Flat 또는 `nointerpolation` 방식이 필요하다.

### Varying을 많이 추가해도 비용이 없다

Stage Interface Limit, Interpolator, Register와 Bandwidth에 영향을 줄 수 있다.

### Vertex에서 계산하면 결과가 같고 항상 빠르다

실행 횟수는 줄 수 있지만 비선형 계산의 보간 결과와 Fragment별 직접 계산 결과는 다를 수 있다.

---

## Data 전달 흐름 정리

| 단계 | Data | 처리 |
| --- | --- | --- |
| Mesh | Position, Normal, UV, Color | Vertex별 Attribute 저장 |
| Vertex Fetch | Vertex Buffer와 Layout | Attribute를 Shader Input에 연결 |
| Vertex Shader | `Attributes` | Position 변환과 Varying 계산 |
| Stage Output | `Varyings` | Primitive Vertex별 값 출력 |
| Rasterizer | 세 Vertex Output | Coverage와 Interpolation 계산 |
| Fragment Shader | 보간된 `Varyings` | Texture와 Lighting 계산 |
| Fragment Output | Color, Depth 등 | Fragment Operations로 전달 |

```text
저장된 Vertex Data
Attributes
↓
계산된 Vertex Data
Varyings
↓
Fragment 위치의 Data
Interpolated Fragment Input
```

---

## 정리

Vertex Shader와 Fragment Shader는 함수를 직접 호출하여 Data를 주고받지 않는다.

Vertex Shader가 Vertex별 Output을 만들고 Rasterizer가 Primitive 내부 Fragment 위치에 맞게 그 값을 보간하여 Fragment Shader Input을 생성한다.

```text
Mesh Vertex Buffer
↓ Attribute와 Semantic
Vertex Shader Input
↓
Vertex Shader Output
Varyings
↓ Rasterizer Interpolation
Fragment Shader Input
```

Attribute는 Mesh의 각 Vertex에 저장된 Position, Normal, Tangent, UV와 Color 같은 Data다.

HLSL Semantic은 Vertex Buffer Data와 Shader Input, Stage Output과 Fragment Input의 의미를 연결한다.

Vertex Shader는 Rasterizer가 사용할 Clip Space Position을 `SV_POSITION`으로 출력해야 한다.

Fragment Shader에 필요한 UV, Normal, World Position과 Color는 `TEXCOORD` 또는 `COLOR` 같은 Channel을 가진 Varying으로 출력할 수 있다.

Rasterizer는 Barycentric Coordinate를 사용하여 Triangle 내부의 값을 계산한다.

일반적인 Floating-point Varying은 Clip `w`를 고려한 Perspective-correct Interpolation을 사용하므로 원근이 있는 Surface에서도 UV가 올바르게 변화한다.

```text
기본
Perspective-correct Interpolation

nointerpolation
Primitive 전체에서 Flat Value

noperspective
Screen Space Linear Interpolation

centroid
Covered 영역 안의 위치에서 평가

sample
개별 Sample 위치에서 평가
```

Integer ID처럼 보간할 수 없는 값은 `nointerpolation`을 사용해야 한다.

Normal은 Vertex 사이에서 보간된 뒤 길이가 달라질 수 있으므로 Fragment Lighting 전에 다시 Normalize하는 경우가 많다.

Vertex와 Fragment Stage Interface의 Semantic, Type과 Component 수가 일치해야 한다.

Varying은 무제한 Resource가 아니며 수와 Precision이 Interpolator, Register, Bandwidth와 Shader Target Limit에 영향을 줄 수 있다.

계산을 Vertex Stage로 옮기면 실행 횟수를 줄일 수 있지만 비선형 연산의 결과와 화면 품질이 달라질 수 있다.

Attributes, Varyings와 Interpolation을 이해하면 Mesh에 Vertex 단위로 저장된 적은 Data가 어떻게 Fragment 단위의 연속적인 표면 정보로 확장되는지 추적할 수 있다.
