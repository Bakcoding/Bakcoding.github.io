---
title: "[Unity 렌더링] 2-2. 왜 대부분 Triangle을 사용할까?"
excerpt: "Unity Rendering"
categories:
  - Programming
tags:
  - Unity
  - Rendering
  - Triangle
  - Rasterization
  - Mesh
permalink: /programming/unity-2-2-triangle/
toc: true
toc_sticky: true
date: 2026-08-15
last_modified_at: 2026-08-15
---

3D 모델링 도구에서는 사각형으로 이루어진 Mesh를 자주 볼 수 있다.

사각형은 Edge Loop를 만들거나 형태를 수정하기 편하고, Subdivision을 적용할 때도 규칙적인 결과를 얻기 좋다.

하지만 이 Mesh를 GPU가 렌더링할 때는 대부분 Triangle 단위로 처리한다.

```text
모델링 단계
Quad와 N-gon 사용 가능

렌더링 단계
Triangle Primitive로 분할
```

Triangle이 사용되는 이유를 단순히 GPU가 Triangle만 이해하기 때문이라고 외우는 것은 충분하지 않다.

Triangle에는 평면을 안정적으로 결정하고, 내부를 일관되게 판정하며, Vertex 속성을 보간하기 좋은 수학적 성질이 있다.

이 성질이 GPU의 Rasterization 과정과 잘 맞는다.

---

## 세 점은 하나의 평면을 결정한다

서로 한 직선 위에 있지 않은 세 점은 하나의 평면을 결정한다.

```text
        A ●
         /＼
        /  ＼
       /    ＼
    B ●──────● C
```

A, B, C의 위치가 정해지면 세 점이 만드는 Triangle의 표면도 하나의 평면 위에 놓인다.

이 성질은 Triangle의 내부 위치와 방향을 안정적으로 계산하는 기반이 된다.

반면 네 점으로 만든 Quad는 네 Vertex가 항상 같은 평면 위에 있다는 보장이 없다.

```text
A ●────● B
  │    │
  │    │
D ●────● C

A, B, C, D 중 하나가 평면 밖으로 이동
↓
휘어진 Quad
```

이런 비평면 Quad의 내부를 하나의 평면처럼 처리하면 어느 방향으로 휘어졌는지 명확하지 않다.

하지만 Quad를 두 Triangle로 나누면 각 Triangle은 자신의 세 점으로 평면을 결정한다.

```text
A ●────● B       A ●────● B
  │    │           │  ／ │
  │    │     →     │／   │
D ●────● C       D ●────● C

Triangle ABD
Triangle BCD
```

따라서 복잡한 Polygon도 Triangle로 분할하면 각 Primitive의 표면을 명확하게 정의할 수 있다.

---

## 두 점과 한 점만으로는 채워진 면을 만들기 어렵다

한 개의 Vertex는 공간의 위치를 나타낸다.

두 Vertex를 연결하면 Line을 만들 수 있다.

```text
Point    ●

Line     ●────●
```

하지만 넓이를 가진 채워진 표면을 만들려면 최소 세 점이 필요하다.

Triangle은 면적을 가질 수 있는 가장 단순한 Polygon이다.

```text
세 점
↓
세 Edge
↓
닫힌 내부 영역
```

Vertex 수가 최소이기 때문에 Primitive를 구성하고 처리하는 규칙도 비교적 단순하다.

---

## Triangle 내부는 어떻게 판정할까?

Rasterization에서는 화면에 투영된 Triangle이 어떤 Sample 위치를 덮는지 판정해야 한다.

```text
화면 공간의 Triangle
↓
각 Sample이 내부에 있는지 판정
↓
덮인 위치에 Fragment 생성
```

Triangle은 세 Edge를 기준으로 내부와 외부를 일관되게 구분할 수 있다.

개념적으로 각 Edge의 같은 방향 안쪽에 Sample이 위치하는지 검사할 수 있다.

```text
        내부
      ● ● ●
    ● ● ● ● ●
  ───────────── Edge
        외부
```

실제 GPU의 Rasterizer 구현은 Architecture와 규칙에 따라 다르지만, Triangle의 단순하고 볼록한 형태는 이런 포함 판정에 적합하다.

오목한 Polygon은 내부 모양이 더 복잡하다.

```text
볼록 Polygon
어떤 두 내부 점을 이어도 선분이 내부에 있음

오목 Polygon
안쪽으로 들어간 부분이 있어 내부 판정이 복잡함
```

오목한 Polygon도 여러 Triangle로 분할하면 각 Triangle에 동일한 Rasterization 규칙을 적용할 수 있다.

GPU는 복잡한 Polygon마다 서로 다른 내부 판정 방법을 사용하는 대신 표준화된 Triangle Primitive를 대량으로 처리할 수 있다.

---

## Vertex 속성은 Triangle 내부에서 보간된다

Triangle의 세 Vertex는 Position 외에도 UV, Color, Normal 같은 속성을 가질 수 있다.

Rasterization으로 생성된 Fragment에는 Triangle 내부 위치에 맞는 속성값이 필요하다.

```text
Vertex A: UV (0, 1)
Vertex B: UV (0, 0)
Vertex C: UV (1, 0)

Triangle 내부 Fragment
→ 세 Vertex의 값을 기준으로 UV 계산
```

이 과정을 **Interpolation**, 즉 보간이라고 한다.

Triangle에서는 Barycentric Coordinate를 이용해 내부의 한 위치를 세 Vertex에 대한 가중치로 표현할 수 있다.

```text
P = wA × A + wB × B + wC × C

wA + wB + wC = 1
```

P가 A에 가까우면 A의 가중치가 커지고, B에 가까우면 B의 가중치가 커진다.

같은 가중치를 Vertex 속성에 적용하여 P 위치의 UV, Color, Normal 등을 계산할 수 있다.

```text
UV(P) = wA × UV(A) + wB × UV(B) + wC × UV(C)
```

Perspective Projection에서는 화면 공간에서 단순히 선형 보간하는 것만으로 Texture가 올바르게 보이지 않을 수 있다.

그래서 Rasterizer는 일반적으로 Perspective-Correct Interpolation을 사용하여 깊이에 따른 왜곡을 보정한다.

Triangle은 이렇게 내부 속성을 일관되게 보간하기 좋은 Primitive다.

---

## 모든 형태를 Triangle로 표현할 수 있다

Triangle을 충분히 조합하면 평면, Cube, Sphere, Character 같은 다양한 형태를 표현할 수 있다.

```text
Plane
2개 이상의 Triangle

Cube
각 면을 Triangle로 분할

Sphere
많은 작은 Triangle로 곡면 근사

Character
관절을 따라 변형되는 Triangle Mesh
```

곡면을 Triangle로 표현하면 실제로는 각 Triangle이 평평한 작은 면이다.

Triangle 수가 늘어날수록 실루엣을 더 세밀하게 근사할 수 있다.

또한 Vertex Normal을 보간하여 Triangle 경계의 Lighting 변화가 부드럽게 이어지도록 만들 수 있다.

```text
기하 형태
작은 평면 Triangle의 집합

Shading 결과
보간된 Normal로 부드럽게 표현 가능
```

부드러운 Shading이 실제 실루엣까지 둥글게 바꾸는 것은 아니다.

오브젝트의 외곽선은 여전히 Triangle의 기하 형태로 결정되므로 가까이에서 큰 Triangle을 보면 각진 실루엣이 드러날 수 있다.

---

## Quad는 어떤 대각선으로 나눌까?

Quad는 두 가지 방향으로 나눌 수 있다.

```text
분할 A          분할 B

A ●────● B     A ●────● B
  │  ／ │         ＼   │
  │／   │           ＼ │
D ●────● C     D ●────● C
```

네 Vertex가 완벽하게 같은 평면 위에 있다면 두 분할의 표면 모양은 같을 수 있다.

하지만 Quad가 휘어져 있다면 대각선 방향에 따라 두 Triangle의 평면과 최종 표면이 달라진다.

Lighting, Normal, UV 보간 결과도 차이가 생길 수 있다.

따라서 모델링 도구에서 보이는 Quad가 Runtime에 어떤 방향으로 Triangulation되는지 중요할 수 있다.

특히 변형되는 Character Mesh에서는 관절이 움직일 때 대각선 방향에 따라 표면이 접히는 모습이 달라질 수 있다.

필요한 결과가 명확하다면 Export 전에 Triangulation을 확정하여 DCC 도구와 Unity에서 동일한 분할을 사용하도록 관리할 수 있다.

---

## Vertex 순서는 왜 중요할까?

Triangle은 같은 세 Vertex를 사용하더라도 Index 순서에 따라 앞면 방향이 달라질 수 있다.

이를 **Winding Order**라고 한다.

```text
A → B → C

화면에서 시계 방향 또는 반시계 방향
```

Render Pipeline은 Winding Order를 기준으로 Triangle의 앞면과 뒷면을 구분할 수 있다.

Backface Culling이 활성화되어 있다면 뒷면으로 판단된 Triangle은 Rasterization 대상에서 제외된다.

```text
Camera를 향한 앞면
→ 렌더링

Camera 반대 방향의 뒷면
→ Culling 가능
```

절차적으로 Mesh를 생성했는데 아무것도 보이지 않거나 한쪽 방향에서만 보인다면 Triangle Index 순서가 반대인지 확인할 필요가 있다.

앞면을 결정하는 정확한 기준은 Graphics API와 Unity의 좌표 및 변환 처리 맥락을 함께 고려해야 하므로, 단순히 모든 환경에서 시계 방향이라고 일반화하면 안 된다.

중요한 점은 **일관된 Vertex 순서가 Triangle의 방향을 결정한다**는 것이다.

---

## Unity Mesh에서 Triangle은 어떻게 표현될까?

Unity의 `Mesh`는 Vertex 데이터와 Index 데이터를 분리하여 저장한다.

Triangle 목록에서는 연속된 Index 세 개가 한 Triangle을 나타낸다.

```csharp
Vector3[] vertices =
{
    new Vector3(-1f, -1f, 0f), // 0
    new Vector3( 1f, -1f, 0f), // 1
    new Vector3( 1f,  1f, 0f), // 2
    new Vector3(-1f,  1f, 0f)  // 3
};

int[] indices =
{
    0, 2, 1,
    0, 3, 2
};

Mesh mesh = new Mesh();
mesh.vertices = vertices;
mesh.triangles = indices;
mesh.RecalculateNormals();
mesh.RecalculateBounds();
```

첫 번째 세 Index는 첫 Triangle을 구성하고, 다음 세 Index는 두 번째 Triangle을 구성한다.

```text
0, 2, 1 → Triangle 0
0, 3, 2 → Triangle 1
```

두 Triangle이 Vertex 0과 2를 공유하므로 같은 Vertex 데이터를 재사용한다.

실제 프로젝트에서는 `Mesh.SetVertices`, `Mesh.SetIndices`, `Mesh.SetTriangles` 같은 API를 사용할 수도 있다.

Mesh가 여러 Material 영역으로 나뉜다면 여러 SubMesh가 각각 자신의 Index 범위를 가질 수 있다.

---

## Triangle은 항상 독립적으로 저장될까?

Graphics API에는 Triangle List 외에도 Triangle Strip 같은 토폴로지가 존재한다.

Triangle List는 Index 세 개씩 독립적인 Triangle을 구성한다.

```text
0, 1, 2
3, 4, 5
```

Triangle Strip은 앞선 Vertex를 재사용하면서 연속된 Triangle을 구성할 수 있다.

```text
Vertex 0, 1, 2 → 첫 Triangle
Vertex 1, 2, 3 → 다음 Triangle
```

다만 실제 Mesh 저장과 렌더링 방식은 엔진, Graphics API, Import 과정, 하드웨어 최적화에 따라 달라질 수 있다.

Unity 개발자가 일반적인 Mesh를 다룰 때는 Index로 구성된 Triangle 목록을 기본 모델로 이해하면 충분하다.

---

## Triangle이 많으면 무조건 느릴까?

Triangle은 GPU가 처리해야 하는 기하 Primitive이므로 수가 증가하면 관련 작업량이 늘어날 가능성이 있다.

하지만 Triangle 수 하나만으로 Frame 성능을 판단할 수는 없다.

```text
Scene A
Triangle이 많음
간단한 Vertex Shader
작은 화면 영역

Scene B
Triangle이 적음
화면 전체를 덮음
복잡한 Fragment Shader
많은 Overdraw
```

Scene B가 더 느릴 수도 있다.

Triangle이 화면에서 매우 작아지는 경우에도 별도의 비효율이 생길 수 있다.

작은 Triangle이 적은 Pixel만 덮더라도 Primitive 설정과 Rasterization 관련 작업은 필요하며, GPU가 Fragment를 일정한 묶음으로 처리하는 과정에서 활용도가 떨어질 수 있다.

반대로 Triangle을 지나치게 줄이면 실루엣과 애니메이션 품질이 크게 낮아질 수 있다.

따라서 최적화에서는 다음을 함께 확인해야 한다.

```text
Vertex와 Triangle 수
화면에서 Triangle이 차지하는 크기
Vertex Shader 비용
Fragment Shader 비용
Overdraw
Render Pass 수
대상 플랫폼의 GPU
```

LOD는 Camera에서 멀어진 오브젝트의 Triangle을 줄이는 대표적인 방법이다.

멀리 있는 오브젝트는 화면에서 차지하는 크기가 작기 때문에 기하 디테일을 줄여도 시각적 차이가 작을 수 있다.

하지만 LOD가 항상 이득인지는 전환 비용, 메모리, 대상 Scene의 병목을 함께 측정해야 한다.

---

## Triangle과 Rasterization의 연결

Triangle이 화면에 그려지는 전체 흐름을 정리하면 다음과 같다.

```text
Vertex Buffer / Index Buffer
↓
Vertex Shader
↓
Primitive Assembly
세 Vertex로 Triangle 구성
↓
Clipping
Camera 영역 밖의 부분 처리
↓
Perspective Divide와 Viewport 변환
↓
Rasterization
Triangle이 덮는 Fragment 생성
↓
Interpolation
UV, Normal, Color 등의 값 계산
↓
Fragment Shader
최종 색상 후보 계산
↓
Depth / Stencil / Blending
↓
Render Target
```

Triangle은 단지 모델링 단계의 면 모양이 아니다.

Vertex Shader의 결과와 Fragment Shader의 실행을 연결하는 GPU 렌더링 파이프라인의 핵심 Primitive다.

---

## 정리

Triangle은 넓이를 가진 가장 단순한 Polygon이다.

한 직선 위에 있지 않은 세 점은 하나의 평면을 결정하므로 Triangle의 표면은 명확하다.

네 개 이상의 Vertex로 만든 Polygon은 비평면이거나 오목할 수 있지만 Triangle로 분할하면 각 Primitive에 동일하고 안정적인 처리 규칙을 적용할 수 있다.

Triangle의 단순한 형태는 내부 Sample 판정과 Rasterization에 적합하다.

또한 Barycentric Coordinate를 이용하여 UV, Normal, Color 같은 Vertex 속성을 Triangle 내부에서 보간할 수 있다.

복잡한 3D 형태와 곡면도 많은 Triangle을 조합하여 근사할 수 있다.

Quad와 N-gon은 모델링 단계에서 유용하지만 렌더링을 위해 Triangle로 분할되며, 비평면 Quad는 대각선 방향에 따라 최종 형태와 보간 결과가 달라질 수 있다.

Triangle의 Vertex 순서는 앞면과 뒷면을 결정하는 데 사용되고 Backface Culling과 연결된다.

Unity의 Triangle Mesh에서는 일반적으로 연속된 Index 세 개가 하나의 Triangle을 구성한다.

Triangle 수가 많으면 기하 처리 비용이 증가할 수 있지만, 실제 성능은 Vertex Shader, 화면 크기, Fragment 수, Overdraw, Render Pass와 대상 GPU를 함께 측정해야 판단할 수 있다.

Triangle을 이해하면 이후 Rasterization, Vertex 속성 보간, Backface Culling, LOD와 Polygon 최적화가 각각 렌더링 파이프라인의 어느 부분과 연결되는지 파악하기 쉬워진다.

