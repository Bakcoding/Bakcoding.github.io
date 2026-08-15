---
title: "[Unity 렌더링] 4-6. Normal은 왜 필요할까?"
excerpt: "Unity Rendering"
categories:
  - Programming
tags:
  - Unity
  - Rendering
  - Normal
  - NormalMap
  - TangentSpace
permalink: /programming/unity-4-6-normal/
toc: true
toc_sticky: true
date: 2026-08-15
last_modified_at: 2026-08-15
---

3D Mesh의 Triangle은 Position만으로도 화면에 Rasterization할 수 있다.

하지만 Surface가 어느 방향을 향하는지 알 수 없다면 Light가 정면에서 들어오는지 옆에서 스치는지 계산하기 어렵다.

```text
같은 Position의 Surface

Normal이 Light를 향함
→ 빛을 강하게 받음

Normal이 Light와 수직
→ 직접광이 약해짐

Normal이 Light 반대 방향
→ 앞면 Diffuse가 없음
```

Normal은 Surface에 수직인 방향 Vector다.

Lighting은 Normal과 Light Direction, View Direction의 관계를 사용하여 밝기와 반사 방향을 계산한다.

```text
Surface Position
↓
Normal N
Light Direction L
View Direction V
↓
Diffuse / Specular / Reflection / Fresnel
```

Normal이 있기 때문에 같은 Color를 가진 표면도 굴곡과 방향에 따라 다르게 보인다.

---

## Normal이란?

Normal은 특정 Surface 위치에서 표면에 수직인 방향을 나타내는 Vector다.

```text
        N
        ↑
        |
--------+-------- Surface
```

일반적으로 Lighting 계산에는 길이가 1인 Unit Vector를 사용한다.

```text
|N| = 1
```

Normal은 Position이 아니라 방향이다.

```text
Position
공간의 한 위치

Normal
Surface가 향하는 방향
```

같은 평면 위의 모든 위치는 같은 Face Normal을 가질 수 있지만 서로 다른 Position을 가진다.

---

## Normal은 왜 필요할까?

Light가 Surface에 닿는 각도를 계산하려면 Surface 방향이 필요하다.

가장 단순한 Diffuse Lighting은 Normal과 Light Direction의 내적을 사용할 수 있다.

```hlsl
half NdotL = saturate(dot(normalWS, lightDirectionWS));
half3 diffuse = baseColor * lightColor * NdotL;
```

두 Vector가 모두 Normalize되어 있다면 내적은 두 방향 사이 각도의 Cosine과 같다.

```text
dot(N, L) = cos(θ)
```

```text
θ = 0°
N과 L이 같은 방향
dot = 1

θ = 90°
서로 수직
dot = 0

θ = 180°
반대 방향
dot = -1
```

`saturate`를 적용하면 음수는 0으로 제한된다.

---

## Normal이 없으면 어떻게 보일까?

Normal을 사용하지 않는 Unlit Shader는 Surface 방향과 무관하게 같은 Texture Color를 출력할 수 있다.

```hlsl
return baseColor;
```

Sphere Mesh라도 모든 Fragment가 같은 Color라면 내부 굴곡을 Lighting으로 구분할 수 없다.

```text
Geometry Silhouette
Sphere처럼 보임

Surface 내부 Color
방향 변화가 반영되지 않음
```

Normal을 Lighting에 사용하면 Sphere 표면 방향이 연속적으로 변하면서 밝기와 Highlight가 만들어진다.

Normal은 Geometry 형태를 조명으로 드러내는 기준이다.

---

## Face Normal

Face Normal은 Triangle 평면에 수직인 방향이다.

Triangle Vertex를 `A`, `B`, `C`라고 하면 두 Edge Vector를 만들 수 있다.

```text
E1 = B - A
E2 = C - A
```

두 Edge의 외적으로 Triangle에 수직인 Vector를 계산한다.

```text
N = normalize(cross(E1, E2))
```

```text
        C
       / \
      / ↑ \
     /  N  \
    A-------B
```

외적의 순서를 바꾸면 방향이 반대가 된다.

```text
cross(E1, E2) = N
cross(E2, E1) = -N
```

Vertex Winding과 Front Face Convention이 Normal 방향과 연결되는 이유다.

---

## Face Normal과 Triangle 방향

Triangle의 세 Vertex가 나열된 순서는 앞면과 뒷면을 판정하는 기준이 된다.

```text
A → B → C
한쪽 방향의 Face

A → C → B
반대 방향의 Face
```

Face Normal이 바깥쪽을 향하도록 Mesh의 Winding과 Normal을 일관되게 구성해야 한다.

Normal이 뒤집히면 Light Direction과의 내적이 반대가 되어 표면이 어둡거나 안쪽에서 빛나는 것처럼 보일 수 있다.

Back Face Culling은 Triangle 방향을 기준으로 Primitive를 제거하고 Normal은 Lighting 방향을 계산한다.

두 기능은 관련되어 있지만 같은 Data를 반드시 직접 사용하는 하나의 단계는 아니다.

---

## Flat Shading

Triangle 전체에서 하나의 Face Normal을 사용하면 Flat Shading이 된다.

```text
Triangle A
모든 Fragment가 Normal A

Triangle B
모든 Fragment가 Normal B
```

인접 Triangle의 Normal이 경계에서 갑자기 바뀌므로 면이 뚜렷하게 보인다.

```text
      /\
 N1 /  \ N2
   /____\

경계에서 Normal 불연속
```

Low-poly Style, 각진 Metal과 Faceted Surface에 적합하다.

Geometry가 실제로 나뉜 면이라는 사실을 Lighting에서도 그대로 보여 준다.

---

## Vertex Normal

Vertex Normal은 Mesh Vertex Attribute로 저장된 Normal이다.

```hlsl
struct Attributes
{
    float4 positionOS : POSITION;
    float3 normalOS   : NORMAL;
};
```

하나의 Vertex가 여러 Triangle에 공유되면 주변 Face 방향을 바탕으로 부드러운 방향을 만들 수 있다.

```text
Face Normal N1 ─┐
Face Normal N2 ─┼→ Vertex Normal Nv
Face Normal N3 ─┘
```

단순 평균, Face Area Weight, Angle Weight 등 Normal 생성 방식에 따라 결과가 달라질 수 있다.

Vertex Normal이 항상 인접 Face Normal의 단순 산술 평균이라고 단정하면 안 된다.

DCC Tool과 Unity Mesh Import 설정이 어떤 방식으로 Normal을 계산하는지 확인해야 한다.

---

## Smooth Shading

Smooth Shading은 Vertex Normal을 Triangle 내부에서 보간하여 Fragment마다 다른 Normal을 사용한다.

```text
Vertex A Normal NA
Vertex B Normal NB
Vertex C Normal NC
↓ Rasterizer Interpolation
Fragment Normal Nf
↓ Normalize
Lighting
```

인접 Triangle이 경계 Vertex Normal을 공유하면 Lighting 방향이 연속적으로 이어진다.

적은 Triangle으로 구성된 Sphere도 표면이 부드럽게 보일 수 있다.

```text
Geometry
여러 평평한 Triangle

Lighting Normal
Triangle 경계를 넘어 부드럽게 변화
```

---

## Smooth Shading은 Geometry를 바꾸지 않는다

Vertex Normal을 부드럽게 보간해도 Triangle Position과 Silhouette은 그대로다.

```text
바뀌는 것
Lighting에 사용하는 방향

바뀌지 않는 것
Vertex Position
Triangle Coverage
Depth
Silhouette
```

낮은 Polygon Sphere는 내부 Lighting이 부드러워도 외곽선에서는 각진 Triangle 형태가 보인다.

실제 Silhouette을 부드럽게 만들려면 Geometry Vertex를 늘리거나 Tessellation, Displacement 같은 Position 변화가 필요하다.

---

## Hard Edge

인접 Face가 같은 위치의 Vertex를 사용하더라도 서로 다른 Normal을 가져야 하면 Vertex를 분리할 수 있다.

```text
같은 Position
├─ Vertex A1 Normal = Face 1 Normal
└─ Vertex A2 Normal = Face 2 Normal
```

이렇게 Normal이 불연속인 경계를 Hard Edge라고 할 수 있다.

Cube 모서리를 Smooth Normal로 공유하면 각 Face가 둥글게 이어진 것처럼 Lighting된다.

Cube Face마다 Vertex Normal을 분리하면 평평한 면과 날카로운 Edge가 유지된다.

```text
Smooth Edge
Vertex 공유 + Normal 연속

Hard Edge
Vertex 분리 + Normal 불연속
```

---

## Smoothing Angle

Mesh Importer는 Face 사이 각도를 기준으로 Normal을 부드럽게 연결하거나 분리할 수 있다.

```text
Face Angle < Threshold
→ Smooth하게 연결

Face Angle > Threshold
→ Hard Edge
```

단순 Angle 기준이 모든 Model에 적합한 것은 아니다.

원하는 Art 방향에 맞게 DCC Tool에서 Explicit Normal을 제작하거나 Unity Import 설정을 조절할 수 있다.

UV Seam과 Hard Edge는 Vertex 분리를 만들 수 있으므로 화면상 Point 수보다 실제 GPU Vertex 수가 많아질 수 있다.

---

## Normal Interpolation

Vertex Shader가 World Space Normal을 Varying으로 출력하면 Rasterizer가 보간한다.

```hlsl
struct Varyings
{
    float4 positionCS : SV_POSITION;
    half3 normalWS    : TEXCOORD0;
};
```

```hlsl
output.normalWS = TransformObjectToWorldNormal(input.normalOS);
```

Fragment Shader에서 보간된 값을 받는다.

```hlsl
half3 normalWS = normalize(input.normalWS);
```

보간은 Vector의 각 Component를 결합하지만 길이 1을 보장하지 않는다.

그래서 Lighting 전에 다시 Normalize하는 경우가 많다.

---

## 왜 다시 Normalize할까?

서로 다른 두 Unit Normal을 선형 보간할 수 있다.

```text
N1 = (1, 0, 0)
N2 = (0, 1, 0)

중간값
N = (0.5, 0.5, 0)
```

이 Vector의 길이는 1이 아니다.

```text
|N| = sqrt(0.5² + 0.5²)
    ≈ 0.707
```

Normalize하면 방향을 유지하면서 길이를 1로 맞춘다.

```text
normalize(N)
≈ (0.707, 0.707, 0)
```

길이가 다른 Normal을 내적에 사용하면 각도뿐 아니라 Vector 길이가 Lighting 밝기에 섞인다.

---

## Normal의 Coordinate Space

Normal도 Position과 마찬가지로 Coordinate Space를 가진다.

```text
Object Space Normal
Mesh Local Coordinate 기준

World Space Normal
Scene World Coordinate 기준

View Space Normal
Camera Coordinate 기준

Tangent Space Normal
Surface의 Local Basis 기준
```

Lighting 계산에 사용하는 Normal과 Light Direction은 같은 Space에 있어야 한다.

```text
normalWS · lightDirectionWS
→ 같은 World Space

normalOS · lightDirectionWS
→ 서로 다른 Space, 잘못된 계산
```

변수 이름에 `OS`, `WS`, `VS`, `TS`를 표시하면 오류를 줄일 수 있다.

---

## Position과 Normal Transform은 다르다

Position은 Translation의 영향을 받는다.

```text
Object가 오른쪽으로 이동
→ Position도 오른쪽으로 이동
```

Normal은 방향이므로 Translation의 영향을 받지 않는다.

```text
Object가 오른쪽으로 이동
→ Surface 방향은 그대로
```

그래서 Position처럼 Homogeneous `w = 1`로 전체 Matrix를 적용하면 안 된다.

Direction은 일반적으로 Translation을 제외한 Linear Transform을 고려한다.

하지만 Non-uniform Scale이 있으면 단순히 같은 3×3 Matrix를 곱하는 것만으로도 Normal이 Surface에 수직이라는 조건이 깨질 수 있다.

---

## Non-uniform Scale 문제

X, Y, Z Axis에 서로 다른 Scale을 적용하는 것을 Non-uniform Scale이라고 한다.

```text
Scale = (2, 1, 0.5)
```

Surface의 Tangent Direction과 Normal에 같은 Scale Matrix를 곱하면 두 Vector의 수직 관계가 유지되지 않을 수 있다.

```text
변환 전
dot(T, N) = 0

같은 Non-uniform Scale 적용 후
dot(T', N') ≠ 0 가능
```

Normal은 변환된 Surface에도 수직이어야 한다.

이를 보존하기 위해 Normal Matrix를 사용한다.

---

## Normal Matrix

일반적인 Linear Transform Matrix를 `M`이라고 하면 Normal은 `M`의 Inverse Transpose로 변환한다.

```text
Normal Matrix = transpose(inverse(M))
```

```hlsl
normalWS = mul(normalMatrix, normalOS);
```

Rotation과 Uniform Scale만 있는 일부 조건에서는 더 단순한 변환으로 같은 방향을 얻을 수 있다.

Non-uniform Scale과 Mirroring이 있으면 정확한 처리와 Handedness를 고려해야 한다.

Unity URP에서는 직접 Matrix를 구성하기보다 Helper를 사용할 수 있다.

```hlsl
half3 normalWS = TransformObjectToWorldNormal(input.normalOS);
```

Unity의 Transform 설정과 Shader Library Convention을 반영하므로 일반 Custom Shader에서 더 안전하다.

---

## `TransformObjectToWorldNormal`

URP의 Core Shader Library는 Object Space Normal을 World Space로 변환하는 Helper를 제공한다.

```hlsl
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

half3 normalWS = TransformObjectToWorldNormal(input.normalOS);
```

```text
Mesh normalOS
↓ TransformObjectToWorldNormal
normalWS
↓ Vertex Output과 Interpolation
Fragment normalWS
↓ normalize
Lighting
```

Position에는 `TransformObjectToWorld` 또는 `TransformObjectToHClip`, Direction에는 목적에 맞는 Direction Helper를 사용한다.

이름이 비슷해도 Position과 Normal Function을 바꿔 사용할 수 없다.

---

## Negative Scale과 Handedness

Object Transform에 음수 Scale이 포함되면 Coordinate System의 Handedness가 뒤집힐 수 있다.

```text
Scale X = -1
→ Mirror Transform
→ Tangent Basis 방향과 Face Orientation 변화 가능
```

Normal과 Tangent만 개별적으로 변환하면 Bitangent 방향이 뒤집혀 Normal Map의 Y 방향이 반대로 보일 수 있다.

Unity는 World Transform의 부호 정보를 제공하며 Tangent의 `w`와 함께 Bitangent Sign을 계산할 수 있다.

```hlsl
half tangentSign = input.tangentOS.w * GetOddNegativeScale();
```

실제 Helper 이름과 구현은 사용하는 URP Package Version의 Shader Library를 확인한다.

---

## Normal은 Lighting 어디에 사용될까?

### Diffuse

```hlsl
half NdotL = saturate(dot(N, L));
```

Light가 Surface 정면에 가까울수록 Direct Diffuse가 강해진다.

### Specular

Normal은 반사 Vector 또는 Half Vector와의 관계에 사용된다.

```hlsl
half3 H = normalize(L + V);
half NdotH = saturate(dot(N, H));
```

### Reflection

```hlsl
half3 R = reflect(-V, N);
```

Environment Map을 읽을 방향을 결정한다.

### Fresnel

```hlsl
half NdotV = saturate(dot(N, V));
```

표면을 비스듬히 볼수록 반사가 강해지는 효과의 기준이 된다.

Normal 오류는 여러 Lighting 항에 동시에 영향을 준다.

---

## Geometry Normal만으로 부족한 이유

고해상도 Surface의 작은 Scratch, Brick 틈과 Skin Wrinkle을 모두 실제 Triangle로 만들 수 있다.

하지만 Detail이 늘수록 Vertex와 Triangle, Skinning, Culling, Rasterization Data가 증가한다.

```text
실제 Geometry Detail
Position과 Silhouette까지 정확
Vertex / Triangle 비용 증가

Normal Map Detail
Lighting 방향만 변화
Geometry 비용은 크게 늘리지 않음
```

작은 표면 굴곡은 Normal Map으로 표현하고 Silhouette과 큰 형태는 Geometry로 만드는 방식이 일반적이다.

---

## Normal Map이란?

Normal Map은 Texture Texel에 Surface Normal 방향 정보를 저장한다.

```text
Normal Map Texture
각 Texel = 방향 Vector Encoding
↓ Fragment Shader Sampling
Fragment별 Surface Normal
↓ Lighting
작은 굴곡처럼 보이는 밝기 변화
```

Base Color Texture가 표면의 색을 바꾼다면 Normal Map은 Lighting에 사용할 방향을 바꾼다.

Normal Map을 화면 Color로 직접 출력하면 보통 파란색 계열로 보인다.

이는 Tangent Space의 기본 평면 Normal이 `(0, 0, 1)` 방향이고 이를 Texture의 양수 범위에 Encoding하기 때문이다.

---

## Normal Vector Encoding

Normal Component는 보통 `-1`부터 `1` 범위를 가진다.

일반적인 Color Texture Channel은 `0`부터 `1` 범위다.

개념적으로 다음과 같이 Encoding할 수 있다.

```text
encoded = normal × 0.5 + 0.5
```

Decode는 반대다.

```text
normal = encoded × 2 - 1
```

평평한 Tangent Space Normal은 다음과 같다.

```text
Normal = (0, 0, 1)
Encoded = (0.5, 0.5, 1.0)
```

그래서 일반적인 Tangent Space Normal Map이 보라색 또는 파란색 계열로 보인다.

---

## Unity에서는 직접 `* 2 - 1`만 하면 될까?

Unity는 Platform Texture Format과 Normal Map Compression에 따라 Component를 다른 Channel에 저장할 수 있다.

따라서 단순히 RGB를 `* 2 - 1`로 Decode하면 모든 Platform에서 올바르다고 보장할 수 없다.

Unity Shader Library의 Normal Unpack Helper를 사용한다.

```hlsl
half4 packedNormal = SAMPLE_TEXTURE2D(
    _NormalMap,
    sampler_NormalMap,
    input.uv
);

half3 normalTS = UnpackNormal(packedNormal);
```

Strength를 적용하는 Helper가 제공되는 경우 Render Pipeline Version에 맞게 사용할 수 있다.

```text
Texture Sample
↓ Unity Normal Decode
normalTS
```

---

## Normal Map Import 설정

Unity Texture Importer에서 Texture Type을 `Normal map`으로 설정한다.

```text
Texture Asset 선택
↓ Inspector
Texture Type = Normal map
↓ Apply
```

이 설정은 Unity가 Texture를 실시간 Normal Mapping에 적합한 방식으로 처리하도록 한다.

일반 Color Texture처럼 sRGB Color로 해석하면 Direction Data가 왜곡될 수 있다.

Platform별 Normal Compression과 Channel Layout도 Import Pipeline이 관리할 수 있다.

Shader에서 Unity의 Decode Helper를 사용하는 이유다.

---

## Object Space Normal Map

Normal Map은 Object Space 방향을 직접 저장할 수 있다.

```text
Object Space Normal Map
RGB 방향이 Mesh Object Axis 기준
```

각 Texel의 방향이 Object Coordinate에 고정되어 있어 Tangent Basis 변환이 단순할 수 있다.

하지만 Mesh가 변형되거나 Animation될 때 방향 Data를 함께 적절히 변환해야 하고 Texture 재사용성이 낮다.

같은 Tile Normal을 서로 다른 Surface 방향에 반복 적용하기도 어렵다.

일반적인 Realtime Asset에서는 Tangent Space Normal Map을 더 자주 사용한다.

---

## Tangent Space Normal Map

Tangent Space는 Surface의 각 위치에 붙은 Local Coordinate System이다.

세 Basis Vector로 구성된다.

```text
T = Tangent
Texture U 방향

B = Bitangent
Texture V 방향

N = Normal
Surface 바깥 방향
```

```text
        N
        ↑
        |
        +----→ T
       /
      B
```

Normal Map의 `(0, 0, 1)`은 World의 Z 방향이 아니라 현재 Surface의 Normal 방향을 뜻한다.

이 때문에 같은 Normal Map을 다양한 방향의 Triangle에 재사용할 수 있다.

---

## Tangent

Tangent는 Surface 위에서 UV의 U축이 증가하는 방향에 대응한다.

Mesh Vertex Attribute로 저장할 수 있다.

```hlsl
float4 tangentOS : TANGENT;
```

`xyz`는 Tangent 방향이고 `w`는 Bitangent 방향을 재구성하는 Handedness Sign에 사용된다.

```text
tangentOS.xyz
Tangent 방향

tangentOS.w
Tangent Basis의 방향 부호
```

Normal Mapping에 필요한 Tangent는 Mesh UV와 Normal을 기준으로 계산된다.

UV가 바뀌면 올바른 Tangent도 달라질 수 있다.

---

## Bitangent

Bitangent는 별도 Vertex Attribute로 저장하지 않고 Normal과 Tangent의 외적으로 재구성하는 경우가 많다.

```hlsl
half3 bitangentWS = cross(normalWS, tangentWS) * tangentSign;
```

```text
B = cross(N, T) × sign
```

Sign이 필요한 이유는 Mirrored UV와 Negative Scale처럼 Tangent Basis의 Handedness가 뒤집히는 경우가 있기 때문이다.

항상 `cross(N, T)`만 사용하면 Mirror된 UV Island에서 Normal Map의 방향이 반대로 보일 수 있다.

---

## TBN Matrix

Tangent, Bitangent와 Normal을 Basis로 묶은 Matrix를 TBN Matrix라고 부른다.

```text
TBN = [ T  B  N ]
```

Tangent Space Normal을 World Space로 변환할 수 있다.

HLSL Matrix Convention에 맞는 곱 순서를 사용해야 한다.

개념적으로는 다음과 같다.

```text
normalWS = T × normalTS.x
         + B × normalTS.y
         + N × normalTS.z
```

명시적으로 작성하면 Matrix Layout 혼동을 줄일 수 있다.

```hlsl
half3 normalWS = normalize(
    tangentWS * normalTS.x
  + bitangentWS * normalTS.y
  + vertexNormalWS * normalTS.z
);
```

---

## Normal Mapping 전체 흐름

```text
Mesh
NormalOS / TangentOS / UV
↓ Vertex Shader
NormalWS / TangentWS / Sign / UV
↓ Interpolation
Fragment Basis
↓ normalize와 Bitangent 구성
TBN

Normal Map
↓ Texture Sampling
Packed Normal
↓ UnpackNormal
NormalTS

TBN × NormalTS
↓
NormalWS
↓
Lighting
```

Normal Map Texture 하나만 Sample한다고 바로 World Space Lighting에 사용할 수 있는 것이 아니다.

Texture에 저장된 Space를 Lighting Space로 변환해야 한다.

---

## URP의 Vertex Input

Normal Mapping을 위한 Vertex Input Struct는 다음과 같이 구성할 수 있다.

```hlsl
struct Attributes
{
    float4 positionOS : POSITION;
    float3 normalOS   : NORMAL;
    float4 tangentOS  : TANGENT;
    float2 uv         : TEXCOORD0;
};
```

Vertex Shader Output에는 World Space Basis를 전달할 수 있다.

```hlsl
struct Varyings
{
    float4 positionCS : SV_POSITION;
    half3 normalWS    : TEXCOORD0;
    half4 tangentWS   : TEXCOORD1;
    float2 uv         : TEXCOORD2;
};
```

`tangentWS.w`에 Sign을 Packing하면 별도 Scalar Varying을 줄일 수 있다.

---

## URP의 Normal과 Tangent 변환

URP Shader Library는 Position과 Normal Input을 함께 제공하는 Helper Struct를 제공할 수 있다.

```hlsl
VertexNormalInputs normalInputs = GetVertexNormalInputs(
    input.normalOS,
    input.tangentOS
);
```

개념적으로 다음 값을 얻을 수 있다.

```text
normalInputs.normalWS
normalInputs.tangentWS
normalInputs.bitangentWS
```

직접 Basis를 구성할 수도 있지만 Render Pipeline Helper는 Negative Scale과 Convention을 일관되게 처리하는 데 유리하다.

사용하는 Unity와 URP Package Version의 Function Signature를 확인한다.

---

## Normal Map Sampling 예제

```hlsl
TEXTURE2D(_NormalMap);
SAMPLER(sampler_NormalMap);

half3 SampleNormalTS(float2 uv)
{
    half4 packedNormal = SAMPLE_TEXTURE2D(
        _NormalMap,
        sampler_NormalMap,
        uv
    );

    return UnpackNormal(packedNormal);
}
```

Fragment Shader에서 Tangent Space Normal을 World Space로 변환한다.

```hlsl
half3 normalTS = SampleNormalTS(input.uv);

half3 N = normalize(input.normalWS);
half3 T = normalize(input.tangentWS.xyz);
half3 B = normalize(cross(N, T)) * input.tangentWS.w;

half3 normalWS = normalize(
    T * normalTS.x
  + B * normalTS.y
  + N * normalTS.z
);
```

실제 URP Shader에서는 Library의 Normal Transform Helper를 사용할 수 있다.

---

## Basis를 다시 정규화해야 하는 이유

Normal과 Tangent는 Vertex에서 Fragment까지 보간되면서 길이와 수직 관계가 달라질 수 있다.

```text
Vertex의 Orthogonal TBN
↓ Component Interpolation
Fragment의 T, B, N
길이 1과 완전한 직교를 보장하지 않음
```

각 Vector를 Normalize하고 필요하다면 Tangent를 Normal에 대해 다시 Orthogonalize할 수 있다.

Gram-Schmidt 형태의 보정은 다음과 같이 표현할 수 있다.

```hlsl
T = normalize(T - N * dot(N, T));
B = cross(N, T) * sign;
```

정확도는 높아지지만 Fragment 연산이 추가된다.

사용 Shader Library가 이미 어떤 보정을 수행하는지 확인한 뒤 중복 계산을 피한다.

---

## Normal Map Strength

Normal Map의 효과 강도를 조절할 수 있다.

단순히 모든 Component에 같은 Scalar를 곱하면 Normalize 후 방향이 원래와 같아져 강도가 변하지 않는다.

```text
잘못된 방식
normalize(normalTS × strength)
→ 방향이 같음
```

일반적으로 Tangent Plane 방향인 X와 Y의 기울기를 조절하고 Z를 적절히 재구성하거나 Unity Helper를 사용한다.

```text
strength 증가
normalTS.xy 기울기 강조
→ 더 강한 굴곡 Lighting
```

Unity의 `UnpackNormalScale` 같은 Helper가 Target Platform과 Encoding을 처리할 수 있다.

---

## DirectX와 OpenGL Normal Map 방향

Normal Map 제작 Tool과 Convention에 따라 Green Channel의 방향이 다를 수 있다.

```text
한 Convention
Green = +Y

다른 Convention
Green = -Y
```

잘못된 Convention의 Normal Map을 사용하면 들어가야 할 홈이 튀어나오고 빛 방향이 반대로 보일 수 있다.

Unity Texture Import와 Asset Pipeline, DCC Export Preset이 같은 Convention을 사용하는지 확인한다.

문제가 있을 때 Green Channel을 무조건 뒤집기 전에 Toolchain 설정을 확인한다.

---

## Mirrored UV Seam

UV Island를 Mirror하면 Texture 공간의 Handedness가 뒤집힌다.

```text
UV Island A
U 방향 →

Mirrored Island B
U 방향 ←
```

Tangent `w` Sign과 Bitangent 재구성이 올바르지 않으면 Normal Map Lighting이 Seam에서 반전된다.

Mesh Tangent 생성 방식, Normal Map Baker와 Runtime Shader가 같은 Tangent Basis Convention을 사용해야 한다.

대표적으로 MikkTSpace 같은 공통 Basis를 사용하면 Baking과 Rendering 사이 차이를 줄일 수 있다.

Unity Version과 Model Import 설정에서 사용되는 Tangent 계산 방식을 확인한다.

---

## Normal Map은 Height를 저장할까?

Normal Map은 보통 Surface Height 자체가 아니라 방향을 저장한다.

```text
Height Map
각 Texel = 높이 Scalar

Normal Map
각 Texel = 방향 Vector
```

Height Map에서 주변 높이 차이를 계산하여 Normal Map을 만들 수 있지만 변환 후에는 절대 높이 정보가 직접 남지 않는다.

같은 Normal 방향 분포를 가진 서로 다른 높이 Scale이 존재할 수 있다.

Parallax Mapping은 Height Data를 사용해 UV를 이동시키며 Normal Mapping과 다른 효과다.

---

## Normal Map은 Geometry를 바꿀까?

일반 Normal Mapping은 Vertex Position을 변경하지 않는다.

```text
Normal Map이 바꾸는 것
Fragment Lighting 방향

바꾸지 않는 것
Triangle Position
Silhouette
Depth
Shadow Geometry
Collision
```

표면 내부의 작은 Scratch는 그럴듯하게 보이지만 Object 외곽선은 평평하게 남는다.

큰 돌출과 움푹 파임은 Geometry, Tessellation, Parallax 또는 Displacement를 검토해야 한다.

Normal Map에 과도하게 큰 형태를 담으면 Silhouette과 Shadow가 Lighting Detail과 일치하지 않아 부자연스러울 수 있다.

---

## Normal Map과 Shadow

일반 Shadow Map은 Light에서 본 Geometry Depth로 가림을 계산한다.

Normal Map은 Geometry Depth를 바꾸지 않으므로 작은 표면 굴곡이 실제 Shadow Silhouette을 만들지 않는다.

```text
Normal Map Scratch
Direct Lighting 반응 변화
하지만 Shadow Map Geometry는 평평함
```

Microfacet 기반 Material에서는 Normal이 반사와 Highlight에 영향을 주지만 큰 Self-shadowing까지 자동 생성하지 않는다.

Detail Scale에 맞는 표현 기법을 선택해야 한다.

---

## Normal Map Mipmap

Normal Map도 멀리서 Minification되므로 Mipmap이 필요할 수 있다.

하지만 여러 Unit Normal을 선형 평균하면 결과 Vector의 길이가 줄어든다.

```text
서로 다른 Normal 평균
→ 평균 Vector 길이 감소
→ 단순 Normalize 시 방향만 남음
```

작은 Normal 변화의 분산은 Surface Roughness와 Highlight에 영향을 줄 수 있다.

일반 Mip Generation이 먼 거리의 Specular Alias를 완전히 해결하지 못할 수 있다.

Normal Variance를 Roughness에 반영하는 Specular Anti-aliasing 기법이 사용되기도 한다.

Unity Pipeline과 Material이 제공하는 기능을 확인한다.

---

## Normal Map Compression

Normal은 Unit Vector이므로 X와 Y를 저장하면 Z를 재구성할 수 있다.

```text
x² + y² + z² = 1

z = sqrt(1 - x² - y²)
```

일부 Normal Map Compression은 두 Channel을 중심으로 저장하고 Shader에서 나머지 Component를 복원한다.

Unity의 `UnpackNormal` Helper는 Platform별 Encoding 차이를 처리한다.

직접 Channel을 고정 가정하면 Texture Compression 설정을 바꿀 때 Shader가 깨질 수 있다.

Compression은 Memory와 Bandwidth를 줄이지만 Block Artifact와 방향 정밀도에 영향을 준다.

---

## Vertex Normal과 Normal Map 결합

Normal Map은 Vertex Normal을 완전히 독립적으로 대체하는 것이 아니다.

Vertex Normal과 Tangent가 Surface의 Tangent Basis를 만들고 Normal Map 방향을 World Space로 옮긴다.

```text
Vertex Normal
큰 Surface 방향과 Smooth Shading
↓ TBN Basis
Normal Map
작은 Fragment Detail
↓
Final Fragment Normal
```

Vertex Normal이 잘못되어 있으면 Normal Map을 적용해도 전체 Lighting 방향과 Seam이 잘못될 수 있다.

Base Mesh Normal, Tangent, UV와 Normal Map Baking은 하나의 연결된 Data Pipeline이다.

---

## Skinned Mesh Normal

Skinned Mesh는 Bone Matrix로 Vertex Position을 변형한다.

Normal과 Tangent도 같은 Deformation을 따라 적절히 변환해야 한다.

```text
Bind Pose Position / Normal / Tangent
↓ Bone Weight와 Joint Transform
Animated Position / Normal / Tangent
↓
Rasterization과 Normal Mapping
```

Position만 Skinning하고 Normal을 원래 방향으로 두면 Character가 변형되어도 Lighting은 Bind Pose를 따르는 것처럼 보인다.

Joint에 Non-uniform Scale이 포함되면 Normal Matrix 처리가 더 복잡해질 수 있다.

Unity의 SkinnedMeshRenderer와 Shader Library가 제공하는 Skinning Path를 사용한다.

---

## Double-sided Surface

`Cull Off`인 Material은 Front Face와 Back Face Fragment를 모두 처리할 수 있다.

Back Face에서도 Front Face Normal을 그대로 사용하면 Lighting이 뒤집혀 보일 수 있다.

Fragment Face Semantic으로 방향을 조정할 수 있다.

```hlsl
half facing : VFACE;
half faceSign = facing > 0 ? 1.0h : -1.0h;
normalWS *= faceSign;
```

정확한 Semantic Type과 부호 Convention은 Target Graphics API와 Unity Macro를 확인해야 한다.

Thin Surface인지 실제 Volume의 내부인지에 따라 Back Face Normal 처리 의도가 다르다.

---

## Normal과 Two-sided Normal Map

양면 Leaf나 Cloth에 Tangent Space Normal Map을 적용하려면 Normal뿐 아니라 Tangent Basis 전체의 Orientation을 고려해야 한다.

```text
Back Face
N만 반전
→ TBN Handedness가 잘못될 수 있음

N, T, B 관계를 일관되게 조정
→ NormalTS 변환 유지
```

Render Pipeline의 Double-sided Normal Mode가 제공되면 Mirror, Flip, None 같은 정책을 선택할 수 있다.

단순히 `normalWS *= -1`만 적용한 결과가 모든 Normal Map에서 올바르다고 가정하면 안 된다.

---

## Decal과 Normal 결합

Decal Normal을 기존 Surface Normal과 결합할 때 두 Normal을 단순히 더하고 Normalize하는 방식은 Detail 방향을 정확히 보존하지 못할 수 있다.

```text
Base Normal
+ Detail Normal
↓ 단순 Normalize
근사 결과
```

Reoriented Normal Mapping 같은 결합 방법은 Base Surface 방향에 Detail Normal을 재배치한다.

여러 Normal Layer를 Blend하는 방법마다 평평한 Normal에 대한 Identity와 강한 기울기의 보존 정도가 다르다.

URP 또는 Shader Library가 제공하는 Normal Blend Function을 우선 검토한다.

---

## Normal을 Color로 시각화하기

Normal Component는 `-1~1` 범위이므로 화면 Color `0~1` 범위로 변환할 수 있다.

```hlsl
half3 normalWS = normalize(input.normalWS);
half3 debugColor = normalWS * 0.5h + 0.5h;
return half4(debugColor, 1.0h);
```

```text
-1 → 0
 0 → 0.5
 1 → 1
```

World Space Normal을 표시하면 같은 World Direction을 향하는 Surface가 비슷한 Color로 보인다.

Object가 회전할 때 Color도 World 방향에 맞춰 달라져야 한다.

---

## Face Normal Debug

Fragment Shader의 Screen Space Derivative로 World Position의 Face Normal을 근사할 수 있다.

```hlsl
float3 dpdx = ddx(input.positionWS);
float3 dpdy = ddy(input.positionWS);
float3 faceNormalWS = normalize(cross(dpdx, dpdy));
```

이 Normal은 보간된 Vertex Normal과 달리 현재 Triangle Surface 방향에 가깝다.

Derivative 방향과 Screen Coordinate Convention에 따라 부호가 반대가 될 수 있다.

Triangle Edge와 Helper Invocation, 작은 Primitive에서는 Derivative가 불안정할 수 있다.

Debug와 특정 효과에 사용할 때 Platform 결과를 확인한다.

---

## Normal 오류 증상

| 증상 | 확인할 항목 |
| --- | --- |
| 표면이 안쪽에서 빛남 | Normal 방향과 Winding |
| Scale 후 Lighting 왜곡 | Normal Matrix와 Non-uniform Scale |
| UV Seam에서 빛이 갈라짐 | Tangent Basis와 Mirrored UV Sign |
| 홈과 돌출이 반대로 보임 | Normal Map Green Channel Convention |
| Object 회전 시 빛이 이상함 | Normal과 Light Direction Space 불일치 |
| Normal Map이 거의 평평함 | Texture Import Type과 Strength |
| 반사가 흔들림 | 보간 후 Normalize, Tangent 정확도 |
| 외곽선이 평평함 | Normal Map의 Geometry 한계 |

문제가 Normal Texture 하나에 있다고 가정하지 않고 Mesh, Import, Transform, Shader Space와 Lighting을 순서대로 확인한다.

---

## Unity에서 확인하는 방법

### Model Importer

Model Asset의 Normal과 Tangent Import Mode, Smoothing 설정을 확인한다.

원본 DCC Normal을 Import할지 Unity가 계산할지에 따라 결과가 달라질 수 있다.

### Texture Importer

Normal Map Texture의 Texture Type이 `Normal map`인지, Platform Compression과 Flip Green Channel 관련 설정이 맞는지 확인한다.

### Scene View

Mesh Normal과 Tangent Visualization, Shaded Wireframe과 Material Preview로 Geometry와 Lighting 경계를 확인할 수 있다.

Unity Version과 Tool에 따라 표시 메뉴는 달라질 수 있다.

### Frame Debugger와 Graphics Debugger

사용된 Shader Variant, Normal Map Binding과 Pass를 확인하고 RenderDoc 같은 Tool로 Texture Channel과 Fragment Input을 조사할 수 있다.

---

## URP 기본 예제

Vertex Normal로 간단한 Diffuse를 계산하는 Shader는 다음과 같다.

```shaderlab
Shader "Custom/VertexNormalDiffuse"
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
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

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

            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
            CBUFFER_END

            Varyings vert(Attributes input)
            {
                Varyings output;
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                output.normalWS = TransformObjectToWorldNormal(input.normalOS);
                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                half3 N = normalize(input.normalWS);
                half3 L = normalize(half3(0.4h, 0.8h, 0.2h));
                half NdotL = saturate(dot(N, L));

                return half4(_BaseColor.rgb * NdotL, _BaseColor.a);
            }
            ENDHLSL
        }
    }
}
```

```text
Mesh normalOS
↓ Normal Transform
normalWS
↓ Interpolation
Fragment Normal
↓ Normalize
N dot L
↓
Diffuse Color
```

---

## Normal Map 포함 Data Flow 예제

Normal Map을 추가하려면 UV와 Tangent Basis가 필요하다.

```hlsl
struct Attributes
{
    float4 positionOS : POSITION;
    float3 normalOS   : NORMAL;
    float4 tangentOS  : TANGENT;
    float2 uv         : TEXCOORD0;
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    half3 normalWS    : TEXCOORD0;
    half4 tangentWS   : TEXCOORD1;
    float2 uv         : TEXCOORD2;
};
```

Vertex Shader에서 Basis를 준비한다.

```hlsl
VertexNormalInputs normalInputs = GetVertexNormalInputs(
    input.normalOS,
    input.tangentOS
);

output.normalWS = normalInputs.normalWS;
output.tangentWS = half4(
    normalInputs.tangentWS,
    input.tangentOS.w * GetOddNegativeScale()
);
```

Fragment Shader에서 Texture Normal을 World Space로 옮긴다.

```hlsl
half3 normalTS = UnpackNormal(
    SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, input.uv)
);

half3 N = normalize(input.normalWS);
half3 T = normalize(input.tangentWS.xyz);
half3 B = normalize(cross(N, T)) * input.tangentWS.w;

half3 normalWS = normalize(
    T * normalTS.x
  + B * normalTS.y
  + N * normalTS.z
);
```

Helper Signature는 설치된 URP Package Source를 기준으로 확인한다.

---

## Normal 관련 성능

Normal을 사용하는 비용은 하나의 Vector만 저장하는 문제로 끝나지 않는다.

```text
Vertex Normal
Attribute Bandwidth
Transform
Varying

Normal Map
Tangent Attribute
추가 Varying
Texture Sampling
Decode
TBN Transform
Normalize
```

Normal Mapping을 끄면 Texture Sample과 일부 연산, Tangent Data를 줄일 수 있다.

하지만 Material 품질이 크게 달라진다.

멀리 있는 LOD나 작은 Object에서 Normal Map Feature를 줄이는 방식은 화면 기여도와 Variant 비용을 함께 고려한다.

---

## Varying과 Basis 비용

World Space T, B, N 세 Vector를 모두 Vertex에서 전달하면 Interpolator 사용량이 증가한다.

```text
TangentWS  float3
BitangentWS float3
NormalWS   float3
```

Bitangent를 Fragment에서 `cross(N, T) × sign`으로 재구성하면 Varying을 줄이고 Fragment ALU가 증가한다.

```text
전달
Bandwidth와 Interpolator 증가

재구성
Fragment 연산 증가
```

Mobile과 Desktop GPU, Fragment Coverage와 Shader Complexity에 따라 Trade-off가 달라진다.

URP의 기존 Packing과 Helper를 참고하고 Profile 결과로 결정한다.

---

## Normal Map Feature Variant

Material에 Normal Map이 없는 경우 Sampling과 TBN 계산을 제거하기 위해 Shader Keyword를 사용할 수 있다.

```hlsl
#pragma shader_feature_local _NORMALMAP

#if defined(_NORMALMAP)
    // Normal Map Sampling과 TBN Transform
#else
    // Vertex Normal 사용
#endif
```

```text
Normal Map Off Variant
단순 Vertex Normal

Normal Map On Variant
Texture Sample + Tangent Basis
```

Runtime Branch 비용을 줄일 수 있지만 Keyword 조합과 Shader Variant 수가 증가한다.

Feature가 실제로 필요한 Material 수와 Build Variant를 함께 관리한다.

---

## Normal 계산 최적화

다음 항목을 측정할 수 있다.

- Normal Map Sample이 실제 화면 품질에 기여하는 거리
- Detail Normal과 Base Normal을 모두 Sampling할 필요가 있는지
- TBN Varying 수와 Fragment 재구성 비용
- `half` Precision으로 충분한지
- 불필요한 반복 Normalize가 있는지
- Normal Map Keyword Variant가 정리되어 있는지
- Compression Artifact와 Memory 절약의 균형
- Specular Alias가 Normal Detail 때문에 발생하는지

Normalize를 모두 제거하면 Direction 길이가 틀어질 수 있고 매 단계마다 중복 Normalize하면 연산이 늘어난다.

어느 Transform과 Interpolation 뒤에 Normalize가 필요한지 Data Flow를 기준으로 결정한다.

---

## 자주 생기는 오해

### Normal은 Vertex가 향하는 방향이다

Vertex는 Point이므로 자체 Surface 방향을 가지지 않는다.

Vertex Normal은 주변 Surface 방향을 표현하기 위해 Vertex Attribute에 저장한 Vector다.

### Normal은 Position에서 Object 중심을 빼면 된다

Sphere에는 근사가 가능하지만 일반 Mesh의 Surface Normal은 Geometry와 제작된 Shading Normal을 따라야 한다.

### Smooth Shading은 Triangle을 둥글게 만든다

Lighting Normal만 부드럽게 보간하며 Position, Depth와 Silhouette은 바꾸지 않는다.

### Normal은 Model Matrix로 Position처럼 변환한다

Translation은 제외해야 하고 Non-uniform Scale에서는 Inverse Transpose 기반 Normal Transform이 필요하다.

### 보간된 Vertex Normal은 자동으로 Unit Vector다

Component 보간 후 길이가 달라질 수 있으므로 Lighting 전에 Normalize하는 경우가 많다.

### Normal Map은 표면을 실제로 돌출시킨다

일반 Normal Mapping은 Fragment Lighting 방향만 바꾸며 Geometry, Collision, Depth와 Silhouette을 바꾸지 않는다.

### Normal Map RGB를 그대로 World Normal로 쓰면 된다

Texture Encoding을 Decode하고 Tangent Space라면 TBN으로 Lighting Space에 변환해야 한다.

### Normal Map은 일반 Color Texture로 Import해도 같다

Color Space와 Platform Compression 처리가 다르므로 Unity Texture Type을 `Normal map`으로 설정하고 Decode Helper를 사용해야 한다.

### Bitangent는 항상 `cross(N, T)`다

Mirrored UV와 Negative Scale의 Handedness Sign을 반영해야 한다.

---

## Normal 종류 정리

| 종류 | 의미 | 주 용도 |
| --- | --- | --- |
| Face Normal | Triangle 평면에 수직 | Flat Shading과 Geometry 방향 |
| Vertex Normal | Vertex에 저장된 Shading 방향 | Smooth Shading |
| Interpolated Normal | Triangle 내부에서 보간된 방향 | Fragment Lighting의 기본 Normal |
| Normal Map Normal | Texture에 Encoding된 Detail 방향 | 작은 표면 굴곡 |
| Object Space Normal | Mesh Local Axis 기준 | Object 단위 방향 처리 |
| World Space Normal | Scene World Axis 기준 | World Space Lighting |
| Tangent Space Normal | Surface TBN Basis 기준 | 재사용 가능한 Normal Mapping |

```text
Face Normal
실제 Triangle 방향

Vertex Normal
부드러운 Shading 근사

Normal Map
Fragment Detail 방향
```

---

## 정리

Normal은 Surface에 수직인 방향 Vector이며 Lighting이 표면 방향을 판단하는 기준이다.

Normal과 Light Direction의 내적은 Diffuse 밝기를 결정하는 기본 요소이고 View Direction과 함께 Specular, Reflection과 Fresnel 계산에도 사용된다.

```text
Normal N
Light Direction L
View Direction V
↓
Surface Lighting
```

Face Normal은 Triangle의 두 Edge를 외적하여 얻을 수 있으며 Triangle 전체에서 하나의 Normal을 사용하면 Flat Shading이 된다.

Vertex Normal은 Mesh Vertex Attribute에 저장된 Shading 방향이다.

인접 Vertex Normal을 Triangle 내부에서 보간하면 Smooth Shading을 만들 수 있지만 Geometry와 Silhouette은 바뀌지 않는다.

보간된 Normal은 길이 1을 보장하지 않으므로 Fragment Lighting 전에 Normalize하는 경우가 많다.

Normal과 Light Direction은 같은 Coordinate Space에서 계산해야 한다.

Position과 Normal의 Transform은 다르며 Non-uniform Scale에서 Surface의 수직 관계를 보존하려면 Inverse Transpose 기반 Normal Matrix가 필요하다.

Unity URP에서는 `TransformObjectToWorldNormal`과 `GetVertexNormalInputs` 같은 Shader Library Helper를 사용할 수 있다.

Normal Map은 Texture Texel에 Fragment별 Surface 방향을 Encoding하여 Geometry를 늘리지 않고 작은 굴곡의 Lighting을 표현한다.

```text
Normal Map Sample
↓ Unity Normal Decode
Tangent Space Normal
↓ TBN Transform
World Space Normal
↓
Lighting
```

Tangent Space는 Tangent, Bitangent와 Normal Basis로 구성된다.

Tangent는 Texture U 방향, Bitangent는 V 방향에 대응하고 Tangent의 `w`와 World Transform Sign은 Mirrored Basis의 Handedness를 처리하는 데 사용된다.

Normal Map은 Geometry Position, Depth, Collision, Shadow Silhouette을 바꾸지 않는다.

큰 형태와 외곽선은 Geometry로 만들고 작은 Surface Detail은 Normal Map으로 표현하는 방식이 적합하다.

Unity에서는 Normal Map Texture Type과 Platform Compression을 올바르게 설정하고 직접 RGB를 고정 방식으로 Decode하기보다 Render Pipeline의 `UnpackNormal` 계열 Helper를 사용한다.

Normal 관련 최적화는 Texture Sample, Tangent Attribute, Varying, TBN 연산과 Normalize 비용을 화면 품질 및 Target GPU Profile과 함께 판단해야 한다.
