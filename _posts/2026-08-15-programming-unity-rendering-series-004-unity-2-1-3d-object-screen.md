---
title: "[Unity 렌더링] 2-1. 3D 오브젝트는 어떻게 화면에 그려질까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - Mesh
  - Vertex
  - Triangle
permalink: /programming/unity-2-1-3d-object-screen/
toc: true
toc_sticky: true
date: 2026-08-15
last_modified_at: 2026-08-15
---

Unity Scene에서 Cube를 만들면 화면에는 부피를 가진 상자가 나타난다.

하지만 GPU가 Cube라는 개념 자체를 이해하고 그리는 것은 아니다.

GPU가 처리하는 것은 공간의 위치와 여러 속성을 가진 Vertex, 그리고 이 Vertex를 어떤 순서로 연결할지 나타내는 Index 같은 데이터다.

이 데이터로 Triangle이 구성되고, Triangle이 화면의 Fragment로 변환된 뒤 최종 색상이 계산된다.

```text
3D Object
↓
Mesh 데이터
↓
Vertex 처리
↓
Triangle 구성
↓
Rasterization
↓
Fragment 처리
↓
화면의 Pixel
```

3D 오브젝트가 화면에 그려지는 과정을 이해하려면 먼저 Vertex, Edge, Triangle, Mesh가 무엇인지 구분해야 한다.

---

## Vertex란?

Vertex는 3D 공간에서 Mesh의 형태를 구성하는 기본 데이터 요소다.

한국어로는 보통 정점이라고 부른다.

Vertex를 단순히 공간의 점 하나라고 생각할 수 있지만, 렌더링에서 Vertex는 위치 외에도 여러 속성을 함께 가질 수 있다.

```text
Position
Normal
Tangent
Color
UV
Bone Weight
Bone Index
```

Position은 Vertex가 공간의 어디에 있는지를 나타낸다.

```text
Vertex A = (-1, 0, 0)
Vertex B = ( 1, 0, 0)
Vertex C = ( 0, 1, 0)
```

Normal은 표면이 향하는 방향을 나타내며 Lighting 계산에 사용된다.

UV는 Texture의 어느 위치를 이 Vertex에 대응시킬지 나타낸다.

Bone Weight와 Bone Index는 Skinned Mesh에서 뼈의 움직임이 Vertex에 얼마나 영향을 주는지를 표현한다.

따라서 Vertex는 단순히 점의 위치가 아니라 **Mesh의 한 지점에 필요한 여러 렌더링 속성을 묶은 데이터**로 이해하는 것이 정확하다.

---

## Vertex 속성은 서로 같은 개수를 가진다

Unity의 Mesh에서 사용하는 Vertex 속성은 각 Vertex에 대응한다.

위치가 4개인 Mesh가 Normal과 UV도 사용한다면 각 배열의 요소도 같은 Vertex 수에 맞아야 한다.

```text
Vertex 0
Position[0]
Normal[0]
UV[0]

Vertex 1
Position[1]
Normal[1]
UV[1]
```

이 대응 관계가 있기 때문에 Vertex Shader는 현재 Vertex의 Position, Normal, UV 등을 입력으로 받을 수 있다.

```hlsl
struct Attributes
{
    float4 positionOS : POSITION;
    float3 normalOS   : NORMAL;
    float2 uv         : TEXCOORD0;
};
```

여기서 `positionOS`의 `OS`는 Object Space를 의미한다.

Mesh의 Vertex 위치는 일반적으로 오브젝트 자신의 Local 좌표를 기준으로 저장된다.

Vertex Shader는 Transform과 Camera 정보를 이용하여 이 위치를 화면에 투영할 수 있는 좌표로 변환한다.

---

## Edge란?

Edge는 두 Vertex를 연결하는 선분이다.

```text
Vertex A ●────────● Vertex B
          Edge
```

3D 모델링 도구에서는 Vertex와 Edge를 선택하고 이동시키면서 Mesh의 형태를 편집한다.

하지만 일반적인 실시간 렌더링에서 채워진 표면을 그릴 때 GPU가 독립적인 Edge 목록을 반드시 필요로 하는 것은 아니다.

Triangle을 구성하는 Vertex Index를 통해 Triangle의 경계가 결정되기 때문이다.

```text
Triangle ABC

A ●
  |＼
  |  ＼
  |    ＼
B ●─────● C
```

AB, BC, CA는 Triangle의 Edge로 볼 수 있지만 Mesh 데이터에 별도 Edge 배열로 저장되지 않을 수 있다.

따라서 모델링 관점의 Edge와 GPU에 전달되는 렌더링 데이터 구조는 구분할 필요가 있다.

---

## Triangle이란?

Triangle은 세 Vertex로 구성되는 삼각형 Primitive다.

Primitive는 GPU가 기본 단위로 조립하고 Rasterization할 수 있는 기하 도형을 의미한다.

```text
Vertex 0
   ●
  / ＼
 /   ＼
●─────●
Vertex 1  Vertex 2
```

세 Vertex의 위치가 하나의 평면을 결정하고 그 내부가 표면이 된다.

여러 Triangle을 이어 붙이면 복잡한 3D 형태를 근사할 수 있다.

```text
한 개의 Triangle
↓
여러 Triangle으로 구성된 면
↓
닫힌 표면
↓
3D 형태
```

곡면처럼 보이는 Sphere도 실제 Mesh를 확대해서 보면 많은 Triangle으로 이루어져 있다.

Triangle이 충분히 작고 Vertex의 Normal이 부드럽게 보간되면 사람의 눈에는 연속적인 곡면처럼 보인다.

---

## Polygon은 무엇일까?

Polygon은 여러 선분으로 둘러싸인 다각형을 의미한다.

3D 모델링에서는 삼각형, 사각형, 그 이상의 다각형을 모두 Polygon이라고 부를 수 있다.

```text
Triangle = 3개의 꼭짓점
Quad     = 4개의 꼭짓점
N-gon    = 더 많은 꼭짓점
```

모델링 도구에서는 작업 편의를 위해 Quad나 N-gon을 사용할 수 있다.

하지만 GPU 렌더링 단계에서는 이런 면이 일반적으로 Triangle로 분할되어 처리된다.

사각형 하나는 대각선을 기준으로 두 개의 Triangle로 나눌 수 있다.

```text
A ●────● B       A ●────● B
  │    │           │  ／ │
  │    │     →     │／   │
D ●────● C       D ●────● C

Triangle ABD + Triangle BCD
```

따라서 Unity의 통계에서 말하는 Triangle 수와 모델링 도구에서 표시하는 Polygon 수는 항상 같은 의미가 아닐 수 있다.

---

## Mesh란?

Mesh는 3D 오브젝트의 기하 형태를 표현하는 데이터 집합이다.

단순히 Vertex 위치만 모아 놓은 것이 아니라 다음과 같은 데이터의 조합으로 이루어진다.

```text
Vertex Data
  Position
  Normal
  Tangent
  UV
  Color
  Skinning Data

Index Data
  어떤 Vertex를 연결해 Primitive를 만들지 지정

SubMesh Data
  Mesh를 여러 렌더링 구간으로 구분

Bounds
  공간에서 Mesh가 차지하는 범위
```

Unity에서는 `MeshFilter`가 사용할 Mesh를 보관하고, `MeshRenderer`가 Material과 함께 그 Mesh를 렌더링하는 일반적인 구조를 사용한다.

```text
GameObject
├─ Transform
├─ MeshFilter
│  └─ Mesh
└─ MeshRenderer
   └─ Material
```

Skinned Character는 보통 `SkinnedMeshRenderer`를 사용하여 Bone Transform에 따라 변형되는 Mesh를 처리한다.

Mesh는 형태를 제공하지만 표면의 최종 색상과 빛 반응까지 혼자 결정하지 않는다.

Material과 Shader가 Mesh 표면을 어떻게 계산할지 결정한다.

---

## Vertex와 Index는 왜 나누어 저장할까?

두 Triangle이 하나의 Edge를 공유하는 사각형을 생각할 수 있다.

Triangle마다 세 Vertex를 별도로 저장하면 여섯 개의 위치가 필요하다.

```text
Triangle 1 = A, B, C
Triangle 2 = A, C, D

총 참조 수 = 6
```

하지만 실제 고유한 위치는 A, B, C, D 네 개다.

Vertex 배열에 네 개의 데이터를 저장하고 Index로 조합을 나타내면 Vertex를 재사용할 수 있다.

```text
Vertices
0 = A
1 = B
2 = C
3 = D

Indices
0, 1, 2
0, 2, 3
```

Triangle 토폴로지에서는 Index 세 개가 하나의 Triangle을 구성한다.

```csharp
Mesh mesh = new Mesh();

mesh.vertices = new[]
{
    new Vector3(-1f, -1f, 0f),
    new Vector3( 1f, -1f, 0f),
    new Vector3( 1f,  1f, 0f),
    new Vector3(-1f,  1f, 0f)
};

mesh.triangles = new[]
{
    0, 2, 1,
    0, 3, 2
};
```

Index를 이용한 Vertex 재사용은 메모리 사용량과 Vertex 처리량을 줄이는 데 도움이 될 수 있다.

다만 위치가 같다고 해서 항상 하나의 Vertex로 공유할 수 있는 것은 아니다.

---

## 같은 위치에 Vertex가 여러 개 존재할 수 있다

화면에서 같은 점처럼 보이더라도 Normal이나 UV 같은 다른 속성이 다르면 렌더링 데이터에서는 별도의 Vertex가 필요할 수 있다.

Cube의 모서리가 대표적인 예다.

Cube의 기하학적 꼭짓점은 8개지만 각 면이 뚜렷한 방향의 Normal을 가져야 한다.

하나의 모서리 위치가 서로 다른 세 면에 포함된다면 면마다 다른 Normal이 필요하다.

```text
같은 Position
├─ 앞면 Normal
├─ 윗면 Normal
└─ 옆면 Normal
```

UV가 끊기는 Texture Seam에서도 같은 위치에 서로 다른 UV를 가진 Vertex가 필요하다.

따라서 모델링 도구가 보여 주는 위치 점의 수와 GPU가 처리하는 실제 Vertex 수가 다를 수 있다.

```text
Position은 같음
Normal 또는 UV는 다름
↓
별도의 Vertex 데이터
```

렌더링 최적화에서 Vertex 수를 볼 때 단순한 기하학적 꼭짓점 수만 확인하면 안 되는 이유다.

---

## Mesh는 어떻게 화면 좌표로 이동할까?

Mesh의 Position은 보통 Local Space에 저장된다.

하지만 화면에 그리려면 여러 좌표 변환을 거쳐야 한다.

```text
Local Space
↓ Model Transform
World Space
↓ View Transform
View Space
↓ Projection Transform
Clip Space
↓ Perspective Divide / Viewport
Screen Space
```

Vertex Shader가 각 Vertex의 위치를 변환한다.

Unity Shader에서는 다음과 같은 변환 함수를 사용할 수 있다.

```hlsl
float4 positionCS = TransformObjectToHClip(input.positionOS.xyz);
```

이 결과만으로 화면의 Pixel이 바로 채워지는 것은 아니다.

변환된 Vertex들이 Index에 따라 Triangle로 조립되고, Camera의 화면 영역에 맞게 Clipping된 뒤 Rasterization 단계로 전달된다.

좌표계와 Matrix 변환은 이후 글에서 각각 더 자세히 연결된다.

---

## Rasterization은 무엇을 만들까?

Rasterization은 화면에 투영된 Triangle이 어떤 Sample 또는 Fragment를 덮는지 결정하는 과정이다.

```text
화면에 투영된 Triangle
↓
Triangle이 덮는 위치 판정
↓
Fragment 생성
↓
Fragment Shader 실행
```

Fragment는 최종 Pixel과 완전히 같은 의미는 아니다.

여러 Triangle이 같은 Pixel 위치에 Fragment를 만들 수 있고, 일부 Fragment는 Depth Test에서 제거될 수 있다.

통과한 결과는 Blending 등의 과정을 거쳐 Render Target에 기록된다.

```text
Vertex Data
↓
Vertex Shader
↓
Primitive Assembly
↓
Rasterization
↓
Fragment Shader
↓
Depth / Stencil / Blending
↓
Render Target
```

결국 Mesh의 연속적인 3D 표면이 그대로 화면으로 이동하는 것이 아니다.

Vertex 데이터가 변환되고, Triangle 단위로 Rasterization되며, 생성된 Fragment의 색상을 계산한 결과가 화면을 구성한다.

---

## Triangle 수가 성능에 미치는 영향

Triangle이 많으면 일반적으로 더 많은 Vertex와 Primitive를 처리해야 할 가능성이 있다.

하지만 Triangle 수만으로 GPU 성능을 단정할 수는 없다.

```text
Vertex Shader 비용
화면에 보이는 Triangle 수
Triangle의 화면 크기
Fragment 수
Overdraw
Material과 Render Pass 수
GPU Architecture
```

같은 Triangle 수라도 화면을 작게 차지하고 간단한 Shader를 사용하는 Mesh와 화면 전체를 덮으며 복잡한 Fragment Shader를 사용하는 Mesh의 비용은 다르다.

반대로 Triangle이 매우 작아 화면의 적은 Sample만 덮는 경우에는 작은 Primitive 처리 효율이 문제가 될 수도 있다.

따라서 Mesh 최적화는 Polygon을 무조건 줄이는 작업이 아니다.

현재 Frame이 Vertex 처리, Primitive 처리, Fragment 처리 중 어디에서 제한되는지를 먼저 확인해야 한다.

---

## Unity에서 연결되는 컴포넌트

Unity가 일반적인 정적 Mesh를 그릴 때 필요한 관계를 단순화하면 다음과 같다.

```text
Transform
오브젝트의 위치, 회전, 크기

MeshFilter
Vertex와 Index가 들어 있는 Mesh 참조

MeshRenderer
Mesh를 어떤 Material로 렌더링할지 설정

Material
Shader와 Property 값

Shader
Vertex와 Fragment를 계산하는 GPU Program
```

어느 하나만으로 완성된 3D 오브젝트의 화면 결과가 만들어지는 것은 아니다.

Mesh는 기하 형태를 제공하고, Transform은 Scene 안의 위치를 결정하며, Material과 Shader는 표면이 어떻게 보일지를 결정한다.

Camera와 Light, Render Pipeline의 처리까지 연결되어 최종 이미지가 만들어진다.

---

## 정리

3D 오브젝트는 완성된 입체 이미지로 GPU에 전달되지 않는다.

Mesh에 저장된 Vertex 속성과 Index 같은 데이터로 전달된다.

Vertex는 Position뿐 아니라 Normal, Tangent, UV, Color, Skinning 정보 등을 가질 수 있다.

Edge는 두 Vertex 사이의 경계지만, 일반적인 Triangle Mesh의 렌더링 데이터에 별도 Edge 목록이 반드시 존재하는 것은 아니다.

세 Vertex 또는 세 Index가 Triangle Primitive를 구성하고, 여러 Triangle이 모여 복잡한 Mesh의 표면을 만든다.

Mesh의 Vertex는 Vertex Shader를 통해 화면에 투영할 수 있는 좌표로 변환된다.

변환된 Vertex는 Triangle로 조립되고 Rasterization을 거쳐 Fragment를 만든다.

Fragment Shader와 Depth, Blending 등의 처리가 끝난 결과가 Render Target에 기록된다.

같은 위치라도 Normal이나 UV가 다르면 별도의 Vertex가 필요할 수 있으므로 기하학적 꼭짓점 수와 실제 렌더링 Vertex 수는 다를 수 있다.

Triangle 수 역시 중요한 지표지만 그 수만으로 성능을 판단할 수는 없다.

다음으로는 복잡한 3D 표면을 표현할 때 왜 사각형이나 더 큰 Polygon이 아니라 Triangle이 GPU 렌더링의 기본 단위로 사용되는지 연결할 수 있다.
