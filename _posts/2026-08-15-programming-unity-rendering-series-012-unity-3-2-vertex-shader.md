---
title: "[Unity 렌더링] 3-2. Vertex Shader는 무엇을 할까?"
excerpt: "Unity Rendering"
categories:
  - Programming
tags:
  - Unity
  - Rendering
  - VertexShader
  - HLSL
  - URP
permalink: /programming/unity-3-2-vertex-shader/
toc: true
toc_sticky: true
date: 2026-08-15
last_modified_at: 2026-08-15
---

GPU Graphics Pipeline에서 Mesh 데이터가 입력되면 가장 먼저 거치는 Programmable Stage 중 하나가 Vertex Shader다.

Vertex Shader는 Mesh의 각 Vertex Attribute를 입력받아 위치를 변환하고 이후 Pipeline에 필요한 데이터를 출력한다.

```text
Mesh Vertex
Position, Normal, Tangent, UV, Color
↓
Vertex Shader
↓
Clip Position과 Varying
↓
Primitive Assembly와 Rasterization
```

가장 중요한 출력은 Clip Space Position이다.

GPU는 이 Position을 이용해 Vertex를 Triangle로 구성하고 Clipping, Perspective Divide와 Rasterization을 진행한다.

하지만 Vertex Shader의 역할이 Position 변환 하나로 끝나는 것은 아니다.

Normal을 World Space로 바꾸거나 UV를 변환하고, Wind나 Wave처럼 Mesh 형태를 움직이며, Fragment Shader에 전달할 값을 준비할 수도 있다.

---

## Vertex Shader란?

Vertex Shader는 Vertex 단위로 실행되는 GPU Program이다.

Draw Command가 지정한 Vertex 또는 Index 흐름을 기준으로 Vertex Shader Invocation이 생성된다.

```text
Vertex Input 0 → Vertex Shader
Vertex Input 1 → Vertex Shader
Vertex Input 2 → Vertex Shader
...
```

각 Invocation은 하나의 Vertex와 관련된 Attribute를 입력받고 자신의 출력값을 만든다.

일반적인 Vertex Shader는 다른 Vertex의 값을 직접 읽어 Triangle 전체 형태를 판단하지 않는다.

여러 Vertex를 하나의 Primitive로 조립하는 작업은 Vertex Shader 이후 단계에서 이루어진다.

---

## Vertex Shader는 무엇을 입력받을까?

Mesh의 Vertex Buffer에는 여러 Vertex Attribute가 저장될 수 있다.

```text
Position
Normal
Tangent
UV0 ~ UV7
Color
Bone Weight
Bone Index
```

Shader는 실제로 필요한 Attribute를 Input 구조체에 선언한다.

```hlsl
struct Attributes
{
    float4 positionOS : POSITION;
    float3 normalOS   : NORMAL;
    float4 tangentOS  : TANGENT;
    float2 uv         : TEXCOORD0;
    float4 color      : COLOR;
};
```

변수 이름은 개발자가 정할 수 있지만 뒤의 `POSITION`, `NORMAL`, `TEXCOORD0` 같은 Semantic은 데이터의 의미와 연결에 사용된다.

---

## Semantic이란?

HLSL Semantic은 Shader 변수의 역할과 Pipeline Interface를 나타낸다.

```text
POSITION
Vertex Position

NORMAL
Vertex Normal

TANGENT
Vertex Tangent

TEXCOORD0
첫 번째 Texture Coordinate 또는 일반 보간 데이터

COLOR
Vertex Color
```

GPU와 Graphics API는 변수 이름 `positionOS` 자체를 보고 Position이라고 판단하지 않는다.

Semantic과 Vertex Layout을 통해 Buffer 데이터가 Shader Input에 연결된다.

```hlsl
float4 myValue : POSITION;
```

변수 이름이 `myValue`여도 `POSITION` Semantic이므로 Vertex Position 입력에 연결될 수 있다.

읽기 쉬운 Shader를 위해서는 이름에도 데이터와 좌표 공간을 명확히 표시하는 편이 좋다.

---

## OS, WS, VS, CS 접미사

Unity URP Shader에서는 변수 이름 뒤에 좌표 공간을 나타내는 접미사를 자주 사용한다.

```text
OS = Object Space
WS = World Space
VS = View Space
CS 또는 HCS = Clip Space / Homogeneous Clip Space
```

```hlsl
float4 positionOS : POSITION;
float3 normalWS   : TEXCOORD1;
float4 positionCS : SV_POSITION;
```

이 접미사는 HLSL Compiler가 강제하는 Type System이 아니다.

개발자가 서로 다른 공간의 값을 실수로 계산하지 않도록 돕는 Naming Convention이다.

```text
lightPositionWS - positionOS
→ 서로 다른 공간이라 잘못된 계산

lightPositionWS - positionWS
→ 같은 World Space
```

---

## 가장 중요한 입력인 Position

Mesh의 Position은 일반적으로 Object Space에 저장된다.

```hlsl
float4 positionOS : POSITION;
```

이 값은 Mesh Asset 자체의 형태를 나타내며 GameObject의 World Position이 아직 적용되지 않은 상태다.

Vertex Shader는 Model, View, Projection 변환을 적용하여 Clip Position을 만든다.

```text
Object Position
↓ Model
World Position
↓ View
View Position
↓ Projection
Clip Position
```

Unity URP에서는 이 전체 흐름을 Helper 함수로 처리할 수 있다.

```hlsl
output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
```

---

## SV_POSITION 출력

Vertex Shader의 Position 출력에는 `SV_POSITION` Semantic을 사용한다.

```hlsl
struct Varyings
{
    float4 positionCS : SV_POSITION;
};
```

Vertex Shader가 반환하는 Clip Position은 이후 Graphics Pipeline이 Primitive 위치를 처리하는 데 필요한 System Value다.

```text
SV_POSITION
↓
Primitive Assembly
↓
Clipping
↓
Perspective Divide
↓
Rasterization
```

일반적인 Rasterization Draw에서 유효한 Position을 출력하지 않으면 Triangle을 화면의 어디에 만들지 결정할 수 없다.

Vertex Shader가 Pixel 단위의 최종 Screen Position을 직접 출력하는 것이 아니라 `w`를 포함한 Homogeneous Clip Position을 출력한다는 점이 중요하다.

---

## 가장 단순한 URP Vertex Shader

Unity 6 URP에서 Position만 변환하는 기본 구조는 다음과 같다.

```hlsl
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
```

ShaderLab의 Program Block에서는 어떤 함수를 Vertex Shader Entry Point로 사용할지도 지정해야 한다.

```hlsl
#pragma vertex vert
```

`vert`라는 이름 자체가 특별한 것은 아니고 `#pragma vertex`에서 지정한 함수가 Entry Point가 된다.

---

## Attributes와 Varyings

Unity URP 예제에서는 Vertex Shader Input 구조체를 `Attributes`, 출력 구조체를 `Varyings`라고 부르는 경우가 많다.

```text
Attributes
Mesh Vertex Buffer에서 오는 입력

Varyings
Vertex Shader에서 다음 Stage로 전달하는 출력
```

```hlsl
Varyings vert(Attributes input)
{
    Varyings output;
    // 입력을 처리하여 출력 구성
    return output;
}
```

이 이름은 읽기 쉬운 Convention이며 HLSL이 반드시 이 이름만 요구하는 것은 아니다.

Built-in Render Pipeline의 오래된 Shader 예제에서는 `appdata`, `v2f` 같은 이름도 볼 수 있다.

URP Custom Shader에서는 현재 SRP Shader Library와 Convention을 따르는 편이 구조를 이해하기 쉽다.

---

## UV를 전달한다

Fragment Shader에서 Texture를 Sampling하려면 UV가 필요하다.

Vertex Shader는 Mesh의 UV를 입력받아 출력 구조체에 기록한다.

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
```

Vertex UV는 Triangle의 세 꼭짓점에만 존재한다.

Rasterizer가 Triangle 내부의 Fragment마다 UV를 보간하여 Fragment Shader에 전달한다.

---

## Texture Tiling과 Offset

Unity Texture Property에는 Tiling과 Offset 값이 연결될 수 있다.

URP Shader에서는 `_BaseMap_ST`와 `TRANSFORM_TEX`를 사용하여 UV를 변환할 수 있다.

```hlsl
CBUFFER_START(UnityPerMaterial)
    float4 _BaseMap_ST;
CBUFFER_END

output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
```

개념적인 계산은 다음과 같다.

```text
Transformed UV
= Original UV × Tiling + Offset
```

이 계산을 Vertex Shader에서 수행하면 보간된 UV를 Fragment Shader가 사용할 수 있다.

단순한 선형 UV 변환은 Vertex에서 계산해도 Triangle 내부 보간과 잘 맞는다.

---

## Normal을 변환한다

Mesh의 Normal도 일반적으로 Object Space에 저장된다.

Lighting을 World Space에서 계산하려면 Normal을 같은 공간으로 변환해야 한다.

```hlsl
float3 normalWS = TransformObjectToWorldNormal(input.normalOS);
```

```text
NormalOS
↓ Normal 변환
NormalWS
↓ Rasterizer 보간
Fragment NormalWS
```

Normal은 Position과 달리 Translation의 영향을 받지 않아야 한다.

비균일 Scale에서는 표면에 수직인 성질을 유지하기 위한 올바른 Normal Matrix 처리가 필요하다.

Position과 동일한 Object-to-World 곱을 임의로 사용하는 대신 Unity의 Normal 변환 Helper를 사용하는 것이 안전하다.

---

## Tangent와 Bitangent

Normal Map을 사용하려면 Texture에 저장된 Tangent Space Normal을 World Space 같은 Lighting 공간으로 바꿔야 한다.

이를 위해 Vertex의 Normal과 Tangent를 사용할 수 있다.

```hlsl
float3 normalOS  : NORMAL;
float4 tangentOS : TANGENT;
```

Tangent의 `xyz`는 방향이고 `w`는 Bitangent 방향을 재구성하는 Sign에 사용될 수 있다.

```text
Normal
표면 바깥 방향

Tangent
UV의 한 축 방향

Bitangent
Normal과 Tangent로 구성하는 다른 축
```

URP의 `GetVertexNormalInputs`는 World Space의 Normal, Tangent, Bitangent를 준비하는 데 사용할 수 있다.

```hlsl
VertexNormalInputs normalInputs =
    GetVertexNormalInputs(input.normalOS, input.tangentOS);
```

---

## Varying은 어떻게 Fragment에 도착할까?

Vertex Shader 출력 중 Position을 제외한 값은 Rasterizer가 Triangle 내부에서 보간하여 Fragment Shader Input으로 전달할 수 있다.

```text
Vertex A Color = Red
Vertex B Color = Green
Vertex C Color = Blue
↓
Triangle 내부 Fragment
보간된 Color
```

`TEXCOORD` Semantic은 UV 전용 이름처럼 보이지만 일반적인 보간 데이터를 전달하는 Slot으로도 사용한다.

```hlsl
float3 positionWS : TEXCOORD1;
float3 normalWS   : TEXCOORD2;
float4 color      : COLOR;
```

Vertex Shader와 Fragment Shader의 Interface Type과 Semantic이 맞아야 올바른 데이터가 전달된다.

---

## 보간하지 않아야 하는 값

모든 값이 Triangle 내부에서 부드럽게 보간되어야 하는 것은 아니다.

Instance ID, Material 분류 값처럼 Primitive 전체에서 일정해야 하는 값이 있을 수 있다.

HLSL은 `nointerpolation` 같은 Modifier를 제공할 수 있다.

```hlsl
nointerpolation uint materialId : TEXCOORD3;
```

지원되는 Type과 Semantic, 대상 Shader Model을 확인해야 한다.

Flat Shading이나 특수 ID Buffer처럼 보간을 원하지 않는 데이터에서 사용할 수 있다.

---

## Vertex Color

Mesh는 Vertex마다 Color를 가질 수 있다.

```hlsl
float4 color : COLOR;
```

Vertex Shader가 이 값을 출력하면 Triangle 내부에서 보간된 Color를 Fragment Shader가 사용할 수 있다.

```text
Vertex Color 활용
Mesh Painting
Terrain Blend Weight
Particle Color
AO 또는 Mask
효과 강도
```

Texture를 추가로 Sampling하지 않고 저주파 Mask를 전달할 수 있다는 장점이 있다.

하지만 Vertex 밀도가 낮으면 세밀한 경계를 표현하기 어렵고 Mesh 데이터 크기도 증가한다.

---

## Vertex Position을 움직일 수 있다

Vertex Shader는 Clip 변환 전에 Object 또는 World Position을 변경할 수 있다.

```hlsl
float3 positionOS = input.positionOS.xyz;
positionOS.y += sin(positionOS.x + _Time.y) * _Amplitude;

output.positionCS = TransformObjectToHClip(positionOS);
```

이런 방식으로 Wave, Wind, Flag, Grass 흔들림을 만들 수 있다.

```text
원본 Mesh Position
↓ Vertex Animation
변형된 Position
↓ MVP Transform
Clip Position
```

CPU에서 Mesh Vertex Buffer를 매 Frame 수정하지 않고 GPU에서 Draw 시점에 변형할 수 있다.

---

## Vertex Animation의 한계

Vertex Shader는 기존 Vertex를 움직일 수 있지만 일반적인 Vertex Shader Stage에서 새로운 Vertex를 임의로 추가하지는 않는다.

```text
가능
기존 Vertex Position 변경

불가능
Vertex Shader 하나가 Triangle을 무제한 생성
```

Mesh가 거칠면 Wave를 적용해도 Vertex 사이의 실루엣이 각져 보일 수 있다.

```text
Vertex가 적은 Plane
큰 면 단위로 변형

Vertex가 많은 Plane
더 부드러운 Wave
```

세밀한 Vertex Animation에는 충분한 Geometry가 필요하지만 Vertex 수가 늘면 처리 비용과 Mesh Memory도 증가한다.

---

## Position만 움직이면 충분할까?

Vertex Position을 변형했는데 Normal은 원래 값을 그대로 사용하면 Lighting이 변형된 표면 방향과 맞지 않을 수 있다.

```text
Position은 Wave 형태
Normal은 평평한 Plane 방향
↓
Lighting 불일치
```

변형 방식에 따라 Normal과 Tangent도 새 표면에 맞게 계산하거나 근사해야 한다.

간단한 Grass 흔들림처럼 회전에 가까운 변형은 Direction도 같은 방식으로 회전할 수 있다.

복잡한 Procedural Surface는 주변 위치의 기울기나 수학적 미분으로 Normal을 구할 수 있다.

Position 변형과 Shading Basis를 함께 관리해야 자연스러운 Lighting을 얻을 수 있다.

---

## Skinning

Skinned Mesh의 Vertex는 Bone Matrix와 Bone Weight를 이용해 변형된다.

```text
Vertex
Bone 0 Weight 0.7
Bone 1 Weight 0.3
↓
두 Bone Transform의 영향 결합
↓
Skinned Position
```

개념적으로 각 Bone이 변환한 Position을 Weight로 합산한다.

```text
Skinned Position
= Bone0 Position × Weight0
+ Bone1 Position × Weight1
...
```

Normal과 Tangent도 Bone 변환에 맞게 처리해야 한다.

Unity와 플랫폼 설정에 따라 Skinning이 Vertex Shader, Compute Shader 또는 다른 GPU·CPU 경로에서 처리될 수 있으므로 모든 경우가 같은 구현이라고 단정하면 안 된다.

---

## Morph Target과 Blend Shape

Blend Shape는 기본 Vertex와 Target Shape의 Position, Normal, Tangent 차이를 Weight에 따라 적용한다.

```text
Base Position
+ Delta Position × Weight
= Morphed Position
```

얼굴 표정과 입 모양 같은 변형에 사용할 수 있다.

여러 Blend Shape와 Skinning을 함께 사용하면 Vertex당 읽을 데이터와 연산량이 늘어난다.

실제 Unity의 처리 경로는 Renderer 설정과 플랫폼에 따라 달라질 수 있지만 최종적으로 변형된 Vertex가 Rasterization Pipeline에 전달되어야 한다.

---

## Vertex Lighting

Lighting을 반드시 Fragment Shader에서만 계산해야 하는 것은 아니다.

Vertex Shader에서 Light와 Normal의 관계를 계산하고 결과를 Fragment Shader로 보간할 수 있다.

```text
Vertex마다 Lighting 계산
↓
Triangle 내부에서 보간
↓
Fragment Color
```

Fragment 수보다 Vertex 수가 훨씬 적다면 연산량을 줄일 수 있다.

하지만 작은 Highlight나 빠르게 변하는 Lighting을 Vertex 사이 보간만으로 표현하면 품질이 낮아질 수 있다.

```text
Per-Vertex Lighting
저렴할 수 있지만 Geometry 밀도에 품질 의존

Per-Fragment Lighting
세밀하지만 Fragment 수만큼 연산 가능
```

어느 Stage에서 계산할지는 품질과 병목을 기준으로 결정해야 한다.

---

## 계산을 Vertex Shader로 옮기면 항상 빠를까?

Fragment Shader에서 반복되는 값을 Vertex에서 계산하여 보간하면 연산 횟수를 줄일 수 있다.

하지만 모든 계산을 옮길 수 있는 것은 아니다.

```text
Vertex에서 적합할 수 있는 계산
선형적으로 보간해도 되는 값
낮은 빈도의 변화

Fragment에서 필요한 계산
Texture Sample 결과
세밀한 Normal Map
Pixel별 View와 Light 관계
비선형 결과의 정확한 계산
```

Vertex 출력 Varying이 많아지면 Rasterizer와 Shader Stage 사이의 보간 데이터, Register와 대역폭 사용도 늘 수 있다.

Vertex 수가 매우 많은 Scene에서는 Vertex Shader 자체가 병목일 수 있다.

단순히 Fragment 연산을 Vertex로 옮기는 것보다 시각 결과와 GPU Profile을 확인해야 한다.

---

## Vertex Shader와 Index Buffer

Index Buffer를 사용하면 여러 Triangle이 같은 Vertex를 참조할 수 있다.

```text
Triangle 0 = 0, 1, 2
Triangle 1 = 0, 2, 3
```

GPU의 Post-Transform Vertex Cache가 Vertex 0과 2의 처리 결과를 재사용하면 Vertex Shader를 다시 실행하지 않을 수 있다.

따라서 Index 참조 수가 6이라고 Vertex Shader가 반드시 6회 실행된다고 단정할 수 없다.

```text
Index 참조 수
≠ 항상 Vertex Shader Invocation 수
```

Cache 효율은 Index 순서, Draw 경계와 GPU Architecture에 영향을 받는다.

반대로 UV Seam이나 Hard Normal Edge에서는 같은 Position이 별도의 Vertex Attribute 조합으로 분리되어 실제 Vertex 수가 늘 수 있다.

---

## 하나의 Vertex는 Frame에 한 번만 처리될까?

같은 Mesh도 여러 Render Pass에서 반복해서 그려질 수 있다.

```text
Shadow Pass
Depth Prepass
Opaque Color Pass
Motion Vector Pass
Reflection Camera
```

각 Draw에서 해당 Pass의 Vertex Shader가 실행될 수 있다.

화면에 Mesh가 한 번 보인다고 Vertex가 Frame당 한 번만 처리되는 것은 아니다.

```text
실제 Vertex Processing
= Mesh Vertex
× Pass 수
× Camera 수
× Instance와 Draw 구성
```

Shader와 Pipeline 최적화에서는 최종 화면의 Geometry 수뿐 아니라 몇 개의 Pass가 같은 Geometry를 처리하는지 확인해야 한다.

---

## GPU Instancing

GPU Instancing은 같은 Mesh를 여러 Transform으로 그릴 때 Instance별 데이터를 이용한다.

```text
같은 Local Vertex
↓ Instance 0 Model Matrix
World Position 0

같은 Local Vertex
↓ Instance 1 Model Matrix
World Position 1
```

Vertex Shader는 현재 Instance ID를 기준으로 올바른 Object-to-World Transform과 Property를 선택해야 한다.

Unity Shader Macro가 Instance ID를 설정하고 전달하는 데 사용될 수 있다.

같은 Mesh 데이터를 공유하더라도 Instance마다 Vertex Shader Invocation은 필요하다.

Instancing의 주된 이점은 CPU Draw Command와 State 준비를 줄이는 것이며 GPU Vertex 연산 자체가 사라지는 것은 아니다.

---

## SV_VertexID

HLSL의 `SV_VertexID`를 사용하면 현재 Vertex의 ID를 Shader에서 받을 수 있다.

```hlsl
uint vertexID : SV_VertexID;
```

Vertex Buffer 없이 ID를 이용해 Fullscreen Triangle Position을 생성하거나 Procedural Geometry의 Buffer Index를 계산하는 데 사용할 수 있다.

```text
Vertex ID 0, 1, 2
↓
Shader에서 세 Clip Position 생성
↓
Fullscreen Triangle
```

지원 Shader Stage와 API, Unity의 Draw 방식에 맞게 사용해야 한다.

일반 Mesh Rendering에서는 Vertex Attribute 입력을 사용하는 기본 구조를 먼저 이해하는 것이 좋다.

---

## Vertex Shader는 Texture를 읽을 수 있을까?

현대 Shader Model에서는 Vertex Shader도 Texture와 Buffer를 읽을 수 있다.

Height Map을 Sampling하여 Terrain Vertex를 움직이는 Vertex Displacement를 만들 수 있다.

```hlsl
float height = SAMPLE_TEXTURE2D_LOD(
    _HeightMap,
    sampler_HeightMap,
    input.uv,
    0
).r;

positionOS.y += height * _HeightScale;
```

Vertex Stage에서는 화면상의 UV 변화율을 이용한 자동 Mipmap Level 계산이 Fragment Stage와 같지 않으므로 명시적인 LOD Sampling이 필요할 수 있다.

Texture Read는 Memory Latency와 대역폭 비용을 만들며 많은 Vertex에 실행되면 비싼 연산이 될 수 있다.

---

## Precision 선택

Vertex Position 변환에는 넓은 좌표 범위와 정확도가 필요하므로 일반적으로 `float` Precision을 사용한다.

```hlsl
float4 positionOS;
float4 positionCS;
```

Color와 일부 Normal·Lighting 데이터에는 대상 플랫폼에 따라 `half`가 적합할 수 있다.

하지만 모바일과 데스크톱에서 `half`의 실제 Precision과 성능 특성이 다를 수 있다.

```text
Position과 Matrix
정밀도 오류가 화면 흔들림과 변형으로 보일 수 있음

Color와 보조 값
허용 범위에서 낮은 Precision 고려 가능
```

무조건 모든 값을 `half`로 낮추거나 모든 값을 `float`로 유지하기보다 값의 범위와 대상 GPU를 기준으로 결정해야 한다.

---

## Varying이 많으면 어떤 비용이 생길까?

Vertex Shader Output은 Rasterizer가 Primitive별로 보관하고 Fragment 위치에서 보간해야 한다.

```text
PositionWS
NormalWS
TangentWS
UV0
UV1
Color
Fog Factor
Shadow Coordinate
```

출력이 많아지면 Vertex-to-Fragment Interface의 Register와 보간 자원, 대역폭 사용이 증가할 수 있다.

플랫폼의 Interpolator 제한을 넘으면 Shader Compile이 실패하거나 다른 Packing이 필요할 수 있다.

같은 값을 여러 형태로 전달하기보다 Fragment에서 재구성하는 비용과 Varying으로 전달하는 비용을 비교해야 한다.

---

## Vertex Shader의 분기

Vertex Shader에도 조건문을 사용할 수 있다.

```hlsl
if (_WindEnabled > 0)
{
    positionOS += windOffset;
}
```

Material 전체에서 동일한 조건이라면 같은 Draw의 Vertex가 같은 경로를 선택할 가능성이 높다.

Vertex마다 다른 Weight나 ID로 경로가 갈리면 실행 그룹 내 Branch Divergence가 발생할 수 있다.

Compiler가 분기를 평탄화하거나 Shader Variant로 기능을 분리할 수도 있다.

조건문 개수만 보고 비용을 판단하지 말고 실제 Compile 결과와 GPU Profile을 확인해야 한다.

---

## Vertex Shader와 Bounds

GPU Vertex Shader에서 Position을 크게 움직여도 CPU Culling에 사용하는 Renderer Bounds가 자동으로 정확히 확장된다고 가정하면 안 된다.

```text
CPU Culling
원래 Bounds 사용
↓
Renderer가 Frustum 밖으로 판단
↓
Draw가 제출되지 않음
↓
Vertex Shader 변형도 실행되지 않음
```

Wind, Wave, Procedural Displacement가 원래 Mesh Bounds를 벗어난다면 충분한 Bounds를 설정해야 한다.

Bounds가 너무 작으면 화면 가장자리에서 Mesh가 갑자기 사라질 수 있다.

반대로 지나치게 크면 보이지 않는 Renderer가 Culling되지 않아 성능에 영향을 줄 수 있다.

---

## Vertex Shader 문제를 확인하는 방법

Vertex Shader 결과가 잘못되면 Triangle이 사라지거나 폭발하듯 늘어나고 Lighting과 Texture가 틀어질 수 있다.

```text
Position 변환 문제
잘못된 위치, Clipping, 뒤집힘

Normal 변환 문제
Lighting 방향 오류

UV 전달 문제
Texture 왜곡

Semantic 문제
입력과 출력 데이터 불일치

Bounds 문제
Camera 가장자리에서 사라짐
```

World Position, Normal과 UV를 Color로 시각화하면 각 값의 흐름을 확인할 수 있다.

Frame Debugger와 RenderDoc에서는 Draw의 Vertex Buffer Layout, Shader, Pipeline Input과 Mesh Viewer를 확인할 수 있다.

---

## Vertex Shader 최적화 관점

Vertex Shader 비용은 다음 요소에 영향을 받는다.

```text
실제 Vertex Shader Invocation 수
Vertex Attribute 대역폭
Matrix와 Skinning 연산
Texture / Buffer Read
Varying 출력량
Render Pass와 Camera 수
Branch와 Vertex 변형
```

Triangle 수만 줄이는 것과 Vertex Shader 비용을 줄이는 것은 완전히 같은 작업이 아니다.

UV Seam과 Hard Edge로 인해 Vertex가 분리될 수 있고 Index Cache 효율도 영향을 준다.

GPU가 Fragment Bound인 Scene에서는 Vertex Shader를 줄여도 Frame Time 변화가 작을 수 있다.

Profiler와 GPU Capture를 이용해 Vertex 또는 Geometry Stage가 병목인지 먼저 확인해야 한다.

---

## 전체 흐름

일반적인 URP Vertex Shader의 데이터 흐름을 정리하면 다음과 같다.

```text
Mesh Vertex Buffer
PositionOS, NormalOS, TangentOS, UV, Color
↓
Vertex Shader Input Attributes
↓
필요한 Vertex Animation / Skinning
↓
PositionOS → PositionCS
NormalOS → NormalWS
UV Tiling / Offset
↓
Vertex Shader Output Varyings
PositionCS, NormalWS, UV, Color
↓
Primitive Assembly
↓
Clipping과 Rasterization
↓
Varying Interpolation
↓
Fragment Shader Input
```

Vertex Shader는 최종 Pixel Color를 직접 만드는 Stage가 아니다.

Geometry의 위치를 준비하고 이후 Fragment Processing에 필요한 데이터를 연결하는 Stage다.

---

## 정리

Vertex Shader는 Draw에서 처리되는 Vertex Attribute를 입력받아 Clip Position과 다음 Pipeline Stage에 전달할 Varying을 출력하는 GPU Program이다.

Mesh의 Position, Normal, Tangent, UV, Color는 HLSL Semantic과 Vertex Layout을 통해 `Attributes` 구조체에 연결된다.

Vertex Shader의 가장 중요한 출력은 `SV_POSITION` Semantic을 가진 Homogeneous Clip Position이다.

Unity 6 URP에서는 `TransformObjectToHClip`을 사용하여 Object Space Position을 Clip Space로 변환할 수 있다.

UV, World Position, Normal과 Color 같은 출력은 Rasterizer가 Triangle 내부에서 보간하여 Fragment Shader에 전달한다.

Normal과 Tangent는 Position과 변환 방식이 다르며 비균일 Scale과 Tangent Space를 고려하는 Unity Helper 함수를 사용하는 것이 안전하다.

Vertex Shader는 Wind, Wave, Skinning과 Morph 같은 Vertex Animation을 수행할 수 있지만 일반적으로 기존 Vertex를 움직일 뿐 새로운 Vertex를 추가하지 않는다.

Position을 변형하면 Lighting에 사용되는 Normal과 CPU Culling에 사용되는 Bounds도 함께 고려해야 한다.

같은 Vertex는 Index Cache를 통해 재사용될 수 있으므로 Index 참조 수와 Vertex Shader Invocation 수가 항상 같지는 않다.

반대로 같은 Mesh가 Shadow, Depth, Color와 여러 Camera Pass에서 반복 렌더링되면 Vertex Shader도 여러 번 실행될 수 있다.

GPU Instancing은 CPU Draw 비용을 줄일 수 있지만 각 Instance의 Vertex 변환 자체를 없애는 기능은 아니다.

Vertex Shader 최적화에서는 Mesh에 표시된 Triangle 수만 보지 않고 Vertex Attribute 대역폭, Cache, Shader 연산, Varying 수와 Pass 반복을 함께 확인해야 한다.

Vertex Shader가 만든 Clip Position과 Varying이 다음 단계로 전달되면 Triangle이 화면의 Fragment로 바뀌는 Rasterization 과정이 시작된다.

