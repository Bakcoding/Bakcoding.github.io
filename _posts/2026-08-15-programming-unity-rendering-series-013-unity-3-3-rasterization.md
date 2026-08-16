---
title: "[Unity 렌더링] 3-3. Rasterization은 무엇을 할까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - Rasterization
  - Fragment
  - MSAA
permalink: /programming/unity-3-3-rasterization/
toc: true
toc_sticky: true
date: 2026-08-15
last_modified_at: 2026-08-15
---

Vertex Shader가 세 Vertex의 Clip Position을 출력하면 GPU는 이 Vertex를 Triangle로 구성한다.

하지만 Triangle은 아직 화면의 Pixel Color가 아니다.

화면에 투영된 Triangle이 Render Target의 어느 위치를 덮는지 판단하고, 해당 위치에서 Fragment Shader가 사용할 데이터를 만들어야 한다.

이 과정을 **Rasterization**이라고 한다.

```text
Clip Space Triangle
↓
Clipping과 Perspective Divide
↓
Screen Space Triangle
↓ Rasterization
Coverage와 Fragment 생성
↓
Fragment Shader
```

Rasterization을 Triangle을 Pixel로 바꾸는 과정이라고 간단히 표현할 수 있다.

하지만 더 정확하게는 **Primitive를 화면의 Sample 위치에 대응하는 Fragment와 Coverage 정보로 변환하는 과정**이다.

이 차이를 이해하면 Fragment와 Pixel, MSAA, Interpolation, Overdraw가 어떻게 연결되는지 파악하기 쉬워진다.

---

## Raster란?

Raster는 화면을 일정한 격자 형태의 위치로 표현하는 방식을 의미한다.

Render Target은 가로와 세로 해상도를 가진다.

```text
1920 × 1080

가로 1920 Pixel
세로 1080 Pixel
```

각 Pixel은 Color를 저장할 화면 위치에 대응한다.

3D Triangle은 연속적인 좌표를 가지지만 Render Target은 제한된 격자와 Sample 위치를 가진다.

Rasterization은 이 연속적인 Triangle이 이산적인 화면 격자의 어느 위치를 덮는지 판정한다.

```text
연속적인 Triangle 영역
↓
이산적인 Pixel / Sample 격자
```

---

## Rasterization의 입력

Rasterizer가 처리하는 입력은 Vertex Buffer의 원래 Local Position이 아니다.

Vertex Shader와 Primitive Processing을 거친 Point, Line, Triangle Primitive다.

```text
Vertex Shader 출력
Clip Position과 Varying
↓
Primitive Assembly
↓
Culling과 Clipping
↓
Perspective Divide
↓
Viewport Transform
↓
Rasterization 입력
```

Triangle Vertex는 화면 또는 Framebuffer 좌표에 대응할 수 있는 위치를 가지고 있다.

각 Vertex에는 UV, Normal, Color와 같은 Varying도 연결되어 있다.

Rasterizer는 Coverage뿐 아니라 Fragment 위치에 맞는 Varying을 준비해야 한다.

---

## Primitive란?

Primitive는 Rasterizer가 처리할 기본 기하 단위다.

대표적으로 Point, Line, Triangle이 있다.

```text
Point
한 Vertex를 기준으로 한 점

Line
두 Vertex를 연결한 선

Triangle
세 Vertex로 구성한 면
```

게임의 일반적인 3D Mesh는 Triangle을 주로 사용한다.

Triangle은 세 점으로 하나의 평면과 닫힌 영역을 안정적으로 결정하고 내부 Attribute를 보간하기 좋다.

이 글에서는 Triangle Rasterization을 중심으로 설명한다.

---

## Rasterization 전에 Clipping이 필요한 이유

Camera의 View Volume 밖에 있는 Triangle을 그대로 Rasterization하려고 하면 화면과 관계없는 매우 넓은 영역을 다루게 될 수 있다.

특히 Camera 뒤에 걸쳐 있는 Triangle은 Perspective Divide에서 비정상적으로 큰 Screen 좌표를 만들 수 있다.

```text
Triangle 일부가 Near Plane 뒤
↓
Clip Space 경계와 교차
↓
Clipping으로 보이는 영역만 유지
```

Clipping은 Primitive를 Clip Volume 경계에서 잘라 Rasterization할 수 있는 Geometry로 만든다.

Triangle 일부가 경계 밖이면 새로운 Vertex가 생성될 수 있고 Varying도 경계 위치에 맞게 계산된다.

Rasterizer는 이렇게 준비된 Primitive를 화면 격자에 대응시킨다.

---

## Perspective Divide

Vertex Shader가 출력한 Clip Position은 `(x, y, z, w)` 형태다.

Clipping 이후 `x`, `y`, `z`를 `w`로 나누면 NDC Position을 얻는다.

```text
NDC.x = Clip.x / Clip.w
NDC.y = Clip.y / Clip.w
NDC.z = Clip.z / Clip.w
```

Perspective Camera에서는 이 과정이 먼 Triangle을 화면에서 작게 보이도록 만든다.

`w`는 이후 Varying의 Perspective-Correct Interpolation에도 사용된다.

Rasterization은 단순히 최종 X와 Y만 받는 것이 아니라 Projection 과정과 연결된 깊이 및 보간 정보를 함께 이용한다.

---

## Viewport Transform

NDC는 해상도와 독립적인 정규화 좌표다.

Viewport Transform은 NDC를 현재 Viewport의 Framebuffer 좌표로 변환한다.

```text
NDC
↓
Viewport의 X, Y, Width, Height 적용
↓
Framebuffer Coordinate
```

Camera가 화면의 일부 영역에만 렌더링한다면 Viewport의 위치와 크기에 맞춰 Triangle이 배치된다.

같은 NDC Triangle도 1920×1080과 1280×720 Render Target에서 덮는 실제 Pixel 수가 달라질 수 있다.

해상도가 Fragment 작업량에 영향을 주는 이유다.

---

## Triangle Coverage

Rasterizer는 Triangle이 어떤 Sample 위치를 덮는지 판정한다.

이를 Coverage 판정이라고 한다.

```text
화면 격자

□ □ □ □ □
□ ■ ■ □ □
□ ■ ■ ■ □
□ □ ■ □ □
```

검은 위치가 Triangle의 Coverage를 가진 Sample이라고 생각할 수 있다.

Triangle의 Bounding Box 안에 있는 모든 위치가 반드시 내부인 것은 아니다.

각 Sample이 Triangle의 세 Edge 안쪽에 있는지를 판정하여 Coverage를 결정할 수 있다.

실제 규칙은 Graphics API가 정의하며 Edge 위의 Sample을 어느 Triangle에 포함할지도 일관되게 정해진다.

---

## Bounding Box를 먼저 사용할 수 있다

화면 전체의 모든 Sample을 Triangle과 비교하는 것은 비효율적이다.

Triangle의 최소와 최대 X, Y로 Screen Space Bounding Box를 구하면 검사할 후보 영역을 제한할 수 있다.

```text
Triangle
↓
Screen Bounding Box
↓
Box 내부 Sample만 Coverage 검사
```

하드웨어 Rasterizer의 실제 구현은 GPU Architecture에 따라 Tile, Edge Equation과 Hierarchy를 이용해 더 효율적으로 처리할 수 있다.

Bounding Box는 Rasterization의 기본적인 후보 범위를 이해하기 위한 개념이다.

---

## Edge Function

Triangle의 각 Edge를 기준으로 Sample이 안쪽에 있는지 판정할 수 있다.

```text
Edge AB 기준 안쪽?
Edge BC 기준 안쪽?
Edge CA 기준 안쪽?
```

세 조건을 모두 만족하면 Triangle 내부에 있다고 판단할 수 있다.

이런 판정은 Screen 좌표에서 Edge Equation 또는 2D Cross Product 형태로 표현할 수 있다.

```text
E(P) = Edge가 정의하는 식에 Sample P를 대입한 값
```

Triangle Winding에 따라 안쪽을 나타내는 부호가 달라진다.

GPU는 이러한 계산을 대량의 Primitive와 Sample에 효율적으로 수행하도록 Rasterization Hardware를 가진다.

---

## Edge 위의 Sample은 어느 Triangle에 속할까?

두 Triangle이 하나의 Edge를 공유할 때 Edge 위의 Sample을 둘 다 제외하면 틈이 생길 수 있다.

반대로 둘 다 포함하면 같은 위치를 두 번 처리할 수 있다.

```text
Triangle A │ Triangle B
           │
        공유 Edge
```

Graphics API는 공유 Edge의 Sample을 어느 Triangle에 포함할지 일관된 Rasterization 규칙을 정의한다.

흔히 Top-Left Rule과 같은 형태로 설명되지만 정확한 규칙과 좌표 방향은 API Convention을 따라야 한다.

같은 Vertex와 Edge를 공유하는 인접 Triangle이 균열 없이 표면을 채울 수 있도록 하는 것이 핵심이다.

---

## Fragment란?

Rasterization으로 Coverage가 생성된 화면 위치에는 Fragment가 만들어진다.

Fragment는 최종 Pixel이 아니라 최종 Render Target 값이 될 수 있는 후보 데이터다.

```text
Fragment
Screen Position
Depth
Coverage Mask
보간된 UV
보간된 Normal
보간된 Color
```

Fragment Shader는 이 데이터를 이용해 Source Color를 계산한다.

이후 Depth, Stencil, Blend를 거쳐 Render Target에 실제로 기록될지가 결정된다.

```text
Fragment 생성
↓
Fragment Shader
↓
Depth / Stencil
↓
Blending
↓
Pixel의 최종 Color에 기여
```

---

## Fragment와 Pixel은 왜 다를까?

한 Pixel 위치에 여러 Primitive가 겹치면 각각 Fragment를 만들 수 있다.

```text
Pixel (100, 100)

Wall Fragment
Enemy Fragment
Particle Fragment 1
Particle Fragment 2
```

Depth Test에서 뒤의 Fragment가 제거되거나 Transparent Blend로 여러 Fragment가 결합된다.

최종 Color Buffer에는 한 Pixel 값이 남더라도 그 값을 만들기 위해 여러 Fragment가 처리될 수 있다.

또한 MSAA에서는 한 Pixel 안에 여러 Sample Coverage와 Depth가 존재할 수 있다.

그래서 Fragment 수, Fragment Shader Invocation 수와 최종 Pixel 수는 항상 같지 않다.

---

## Sample이란?

Sample은 Rasterization Coverage와 Depth, Color를 평가하는 Framebuffer 내부의 위치다.

Single-Sample Rendering에서는 Pixel당 하나의 Sample 위치를 생각할 수 있다.

```text
Pixel
┌─────┐
│  ×  │
└─────┘

× = Sample 위치
```

Triangle이 Sample 위치를 포함하면 해당 Pixel에 Coverage가 있다고 판단할 수 있다.

Pixel 전체 면적의 10%만 Triangle이 덮더라도 하나의 Sample이 밖에 있으면 Single-Sample에서는 Coverage가 없을 수 있다.

이 이산적인 판정 때문에 Triangle Edge에서 계단 모양 Alias가 나타난다.

---

## MSAA

MSAA는 Multi-Sample Anti-Aliasing의 약자다.

Pixel 안에 여러 Coverage Sample을 두어 Triangle Edge를 더 세밀하게 판정한다.

```text
4x MSAA Pixel
┌─────┐
│ × × │
│ × × │
└─────┘
```

Triangle이 네 Sample 중 두 개를 덮으면 Coverage가 절반인 Edge 결과를 만들 수 있다.

```text
Coverage Mask
Sample 0 = Covered
Sample 1 = Covered
Sample 2 = Not Covered
Sample 3 = Not Covered
```

최종 Resolve에서 Sample 결과를 하나의 Pixel Color로 합치면 Edge가 부드럽게 보인다.

---

## MSAA는 Fragment Shader를 항상 Sample 수만큼 실행할까?

4x MSAA라고 Fragment Shader가 모든 Pixel에서 항상 네 번 실행된다고 단정할 수 없다.

일반적인 MSAA는 Coverage와 Depth를 여러 Sample에서 관리하면서 Fragment Shader 결과를 Pixel 또는 Covered Sample 그룹에 공유할 수 있다.

```text
Coverage / Depth
Sample 단위

Fragment Shading
설정과 Shader에 따라 Pixel당 한 번 또는 Sample별 실행 가능
```

Sample Shading을 사용하거나 Sample별 Input을 요구하면 Invocation 수가 늘 수 있다.

실제 실행은 Graphics API State, Shader와 GPU에 따라 달라진다.

MSAA Sample 수와 Fragment Shader 실행 수를 단순히 같은 값으로 보면 안 된다.

---

## MSAA가 해결하는 Alias

MSAA는 주로 Triangle Geometry Edge의 Coverage Alias를 줄인다.

다음 문제를 모두 해결하는 것은 아니다.

```text
Texture의 고주파 Alias
Specular Highlight 반짝임
Shader 내부의 날카로운 경계
Alpha Blended Texture Edge
Temporal Shimmering
```

Texture Alias에는 Mipmap과 Filtering이 필요하고 Shader Alias에는 Temporal AA, Supersampling, 분석적인 Filtering 등 다른 기법이 필요할 수 있다.

Alpha Clipping Edge에서는 Alpha-to-Coverage로 Alpha 값을 MSAA Coverage Mask에 대응시키는 방법을 사용할 수 있다.

---

## SSAA와의 차이

SSAA 또는 Supersampling은 더 높은 해상도나 더 많은 Shading Sample에서 전체 Shader 계산을 수행한 뒤 결과를 줄이는 방식으로 볼 수 있다.

```text
MSAA
Geometry Coverage 중심으로 Sample 증가

SSAA
Shading 자체를 더 많은 위치에서 수행
```

SSAA는 Geometry Edge뿐 아니라 Shader와 Texture Alias도 줄일 수 있지만 Fragment Shader 실행과 Render Target 비용이 크게 증가할 수 있다.

MSAA는 Coverage와 Shading을 분리하여 Geometry Edge 품질을 더 효율적으로 높이는 목적이 있다.

---

## Coverage Mask

Rasterizer는 Fragment가 Pixel 안의 어떤 Sample을 덮는지 Bit Mask로 나타낼 수 있다.

```text
4x MSAA Coverage

1111 = 모든 Sample Covered
1100 = 두 Sample Covered
0000 = Coverage 없음
```

Coverage Mask가 모두 0이면 이후 Fragment Operation을 진행할 필요가 없다.

Fragment Shader의 `clip`, Alpha-to-Coverage, Sample Mask State 같은 기능이 Coverage Mask를 변경할 수도 있다.

Color와 Depth가 어느 Sample에 기록될지는 이 Mask와 Fragment Test 결과에 영향을 받는다.

---

## Barycentric Coordinate

Triangle 내부 위치는 세 Vertex에 대한 가중치로 표현할 수 있다.

이 가중치를 Barycentric Coordinate라고 한다.

```text
P = a × A + b × B + c × C

a + b + c = 1
```

P가 Vertex A에 가까우면 `a`가 크고 B에 가까우면 `b`가 커진다.

Triangle Edge 위에서는 한 가중치가 0이 될 수 있다.

Rasterizer는 Fragment 위치의 가중치를 이용해 Vertex Attribute를 보간한다.

```text
UV(P)
= a × UV(A)
+ b × UV(B)
+ c × UV(C)
```

---

## Interpolation

Vertex Shader가 출력한 Varying은 Triangle의 세 Vertex에만 존재한다.

Rasterizer는 Fragment 위치에 맞는 값을 보간하여 Fragment Shader Input을 만든다.

```text
Vertex Shader Output
UV, Normal, Color, PositionWS
↓
Rasterization Interpolation
↓
Fragment Shader Input
```

Vertex A가 Red, B가 Green, C가 Blue를 출력하면 Triangle 내부에 Color Gradient가 만들어진다.

Fragment Shader가 단순히 입력 Color를 반환해도 Rasterizer가 이미 위치별 Color를 준비한다.

---

## 선형 보간만 사용하면 될까?

Screen Space에서 Vertex Attribute를 단순 선형 보간하면 Perspective Projection된 Texture가 올바르게 보이지 않을 수 있다.

멀리 있는 부분은 화면에서 압축되므로 원래 3D 표면의 관계를 고려해야 한다.

```text
화면상 중간 위치
≠ 항상 3D 표면상의 단순 중간
```

그래서 기본 Varying은 Clip Position의 `w`를 고려한 Perspective-Correct Interpolation을 사용한다.

개념적으로 Attribute를 `w`와 함께 보정한 뒤 화면에서 보간하고 다시 복원한다.

이를 통해 바닥처럼 깊이 방향으로 멀어지는 Triangle에서도 Texture가 자연스럽게 매핑된다.

---

## noperspective

특정 값은 Perspective 보정 없이 Screen Space에서 선형 보간하고 싶을 수 있다.

HLSL에서는 `noperspective` Modifier를 사용할 수 있다.

```hlsl
noperspective float2 value : TEXCOORD0;
```

Screen Space Line 거리나 일부 Wireframe Effect처럼 화면 기준 선형성이 필요한 경우에 사용할 수 있다.

하지만 World Surface의 일반 UV에 잘못 사용하면 Perspective가 있는 Texture가 왜곡될 수 있다.

지원 Shader Model과 플랫폼을 확인하고 목적에 맞게 사용해야 한다.

---

## nointerpolation

ID나 분류 값처럼 Triangle 내부에서 섞이면 안 되는 값에는 보간을 끌 수 있다.

```hlsl
nointerpolation uint materialId : TEXCOORD1;
```

이 값은 Primitive의 대표 Vertex인 Provoking Vertex에서 가져올 수 있다.

```text
보간 Color
Vertex 값이 부드럽게 섞임

Flat ID
Primitive 전체에서 하나의 값
```

정수형 Fragment Input은 일반적으로 Flat 방식이 필요하다.

Provoking Vertex 규칙은 Graphics API와 Pipeline State에 따라 달라질 수 있으므로 특정 Vertex 번호를 무조건 가정하면 안 된다.

---

## centroid와 sample Interpolation

MSAA Triangle Edge에서는 Pixel 중심이 Primitive 밖에 있지만 일부 Sample은 안에 있을 수 있다.

Pixel 중심에서 Varying을 평가하면 UV 같은 값이 Triangle 밖의 위치에서 Extrapolation될 수 있다.

`centroid`는 Covered 영역 안의 위치에서 보간값을 평가하도록 제한하는 데 사용할 수 있다.

```hlsl
centroid float2 uv : TEXCOORD0;
```

`sample` Modifier는 현재 Sample 위치에서 값을 평가하도록 요구할 수 있다.

```text
기본 Interpolation
Fragment의 구현 정의 위치

centroid
Covered 영역 안의 위치

sample
현재 Sample 위치
```

Sample Interpolation은 품질을 높일 수 있지만 Fragment Shader Invocation과 연산 비용이 증가할 수 있다.

---

## Normal 보간

Vertex Normal을 Triangle 내부에서 보간하면 평평한 Triangle Mesh도 부드러운 Lighting을 만들 수 있다.

```text
Vertex A Normal
Vertex B Normal
Vertex C Normal
↓
Fragment Normal 보간
```

하지만 단위 길이인 Normal 세 개를 선형 보간한 결과는 길이가 1이 아닐 수 있다.

Fragment Shader에서 다시 Normalize해야 올바른 Dot Product Lighting을 계산할 수 있다.

```hlsl
float3 normalWS = normalize(input.normalWS);
```

보간된 Normal이 부드럽다고 실제 Geometry 실루엣까지 부드러워지는 것은 아니다.

실루엣은 Rasterization되는 Triangle Edge로 결정된다.

---

## UV Derivative

Fragment Shader는 인접 Invocation의 값 차이를 이용해 Screen Space Derivative를 계산할 수 있다.

HLSL의 `ddx`, `ddy`, `fwidth`가 대표적이다.

```hlsl
float2 dx = ddx(input.uv);
float2 dy = ddy(input.uv);
```

Texture Sampling은 UV Derivative를 이용해 화면에서 Texture가 얼마나 축소되는지 판단하고 적절한 Mipmap Level을 선택할 수 있다.

```text
UV 변화가 큼
Texture가 화면에서 축소됨
↓
더 낮은 Mip 선택 가능
```

Derivative는 GPU가 Fragment Shader Invocation을 작은 그룹으로 실행하는 구조와 연결된다.

---

## Helper Invocation

Triangle Edge에서는 Derivative를 계산하기 위해 실제 Coverage가 없는 이웃 위치의 Shader 실행이 필요할 수 있다.

이런 실행을 Helper Invocation이라고 부를 수 있다.

```text
2×2 실행 그룹 예시

Covered   Covered
Covered   Outside but Helper
```

Helper Invocation은 Derivative 계산에는 참여하지만 Color와 Depth를 최종 Render Target에 기록하지 않는다.

따라서 화면에 Covered Fragment가 세 개라고 Shader 연산도 정확히 세 번만 발생한다고 단정할 수 없다.

작은 Triangle이 많을 때 실행 그룹의 많은 Lane이 Helper 또는 비활성 상태가 되어 효율이 낮아질 수 있다.

---

## 작은 Triangle이 비효율적일 수 있는 이유

Triangle이 화면에서 몇 Pixel보다 작아지면 적은 Coverage만 만들 수 있다.

```text
큰 Triangle
많은 인접 Fragment가 같은 Primitive를 처리

작은 Triangle
한두 Sample만 덮음
```

GPU는 Fragment를 일정한 Quad나 Wave 단위로 함께 실행할 수 있으므로 Triangle 밖의 Lane이 비활성화되거나 Helper로 사용될 수 있다.

Primitive Setup, Clipping과 Rasterization 비용도 Triangle마다 필요하다.

Triangle 수가 같더라도 화면에서 매우 작은 Triangle이 많은 Scene은 Geometry와 Fragment 처리 효율이 낮아질 수 있다.

LOD가 먼 오브젝트의 작은 Triangle을 줄이는 이유 중 하나다.

---

## Degenerate Triangle

세 Vertex가 한 직선 위에 있거나 같은 위치에 있어 면적이 0인 Triangle을 Degenerate Triangle이라고 한다.

```text
A ─ B ─ C

면적 = 0
```

면적이 없으므로 일반적인 Fill Rasterization에서는 Coverage를 만들지 않는다.

하지만 Vertex Processing과 Primitive Assembly 같은 앞 단계의 비용은 이미 발생할 수 있다.

Triangle Strip을 연결하거나 Geometry를 숨기는 용도로 Degenerate Triangle을 사용해 온 경우가 있지만 현대 Pipeline에서 실제 비용과 적합성을 확인해야 한다.

불필요한 Degenerate Geometry가 많으면 처리량을 낭비할 수 있다.

---

## Backface Culling과 Rasterization

Triangle의 Winding Order와 Cull State를 이용하면 Back Face를 Rasterization 전에 제거할 수 있다.

```shaderlab
Cull Back
```

닫힌 Mesh의 뒷면은 앞면에 가려지는 경우가 많으므로 Fragment를 만들 필요가 없다.

`Cull Off`를 사용하면 앞면과 뒷면 모두 Rasterization되어 얇은 천과 나뭇잎을 양면으로 표현할 수 있다.

하지만 화면 Coverage와 Overdraw가 늘 수 있다.

Backface Culling은 Rasterizer가 내부인지 판정하는 Coverage Test와는 별개의 Primitive 제거 단계지만 Rasterization 작업량에 직접 영향을 준다.

---

## Scissor Test

Scissor Rectangle은 Render Target의 특정 사각형 영역 밖 Fragment를 제외하는 기능이다.

```text
Viewport
전체 Camera 렌더 영역

Scissor
그 안에서 실제로 허용할 사각형 영역
```

UI Mask, Split Screen과 일부 Render Pass에서 작업 영역을 제한하는 데 사용할 수 있다.

Triangle이 Scissor 밖을 넓게 덮어도 해당 영역의 Fragment 처리를 줄일 수 있다.

Scissor는 임의 모양 Mask가 아니라 기본적으로 축에 정렬된 사각형 영역이다.

---

## Conservative Rasterization

일반 Rasterization은 정해진 Sample 위치가 Triangle 내부에 있는지를 기준으로 Coverage를 만든다.

Conservative Rasterization은 Primitive가 Pixel 영역에 조금이라도 겹치면 Coverage를 생성하는 Overestimate 방식 등을 사용할 수 있다.

```text
일반 Rasterization
Sample Point가 Primitive 안에 있어야 Covered

Conservative Rasterization
Primitive가 Pixel 영역과 겹치면 Covered 가능
```

Voxelization, Collision과 Visibility Buffer 같은 특수 알고리즘에서 Geometry가 지나가는 Pixel을 빠뜨리지 않는 데 유용할 수 있다.

일반 화면 렌더링에 켜면 Triangle이 실제보다 두껍게 보일 수 있다.

Unity ShaderLab의 `Conservative` 지원은 Graphics API와 GPU 기능에 따라 제한될 수 있다.

---

## Wireframe은 어떻게 그릴까?

Rasterization의 Polygon Mode를 Line으로 설정하면 Triangle Edge만 Rasterization하는 기능이 Graphics API에 존재할 수 있다.

하지만 Unity의 일반 Material과 모든 플랫폼에서 동일한 방식으로 사용할 수 있다고 가정하면 안 된다.

Wireframe Effect는 Barycentric Coordinate를 Vertex Attribute로 전달하고 Fragment Shader에서 Edge 거리를 계산하는 방식으로 만들 수도 있다.

```text
Triangle Vertex Barycentric
A = (1,0,0)
B = (0,1,0)
C = (0,0,1)
↓ 보간
가장 작은 성분으로 Edge 거리 판단
```

이 방식은 Fragment Shader와 Derivative 비용을 사용하고 Mesh Vertex 분리가 필요할 수 있다.

---

## Rasterization과 Depth

Rasterizer는 Fragment 위치의 Depth도 계산한다.

각 Vertex의 깊이를 Triangle 내부에서 보간하여 Sample별 Depth Test에 사용할 값을 만든다.

```text
Vertex Depth
↓ Interpolation
Fragment / Sample Depth
↓
Depth Buffer와 비교
```

Depth Test가 Early Stage에서 가능하면 앞 표면에 가려진 Fragment Shader 실행을 줄일 수 있다.

Rasterization이 Fragment를 만들었다고 모두 Fragment Shader와 Color Write까지 진행되는 것은 아니다.

---

## Rasterization과 Overdraw

여러 Triangle이 같은 화면 위치를 덮으면 각 Primitive가 Fragment를 생성할 수 있다.

```text
Wall
Enemy
Particle Layer 1
Particle Layer 2

같은 Pixel 영역에 여러 Fragment
```

불투명 Geometry는 Depth를 통해 뒤 Fragment를 조기에 제거할 수 있다.

Transparent는 일반적으로 ZWrite를 하지 않아 겹친 Layer가 계속 Fragment Shader와 Blending을 수행할 수 있다.

Rasterized Fragment 수가 최종 화면 Pixel 수보다 훨씬 많아지는 현상이 Overdraw다.

화면을 크게 덮는 Triangle과 많은 Layer가 Fragment Bound를 만들 수 있다.

---

## Fullscreen Triangle

Post Processing은 화면 전체를 덮는 Primitive를 Rasterization하여 Fragment Shader를 실행한다.

과거에는 두 Triangle로 이루어진 Quad를 사용할 수 있었지만 하나의 큰 Fullscreen Triangle을 사용하는 방식도 널리 쓰인다.

```text
Fullscreen Quad
Triangle 2개, 중앙 대각선 공유

Fullscreen Triangle
화면을 포함하는 Triangle 1개
```

Fullscreen Triangle은 공유 Edge에서 중복되는 Fragment Quad와 Interpolation 경계를 피하고 Vertex 수를 줄일 수 있다.

Triangle 일부가 Viewport 밖에 있어도 Clipping과 Rasterization이 화면 영역만 처리한다.

실제 Render Pipeline의 Fullscreen Pass Helper를 사용하는 것이 플랫폼별 좌표와 XR 처리를 맞추기 쉽다.

---

## Tile-Based GPU의 Rasterization

모바일 GPU에는 화면을 작은 Tile로 나누어 처리하는 Tile-Based Architecture가 많이 사용된다.

```text
화면
↓ 여러 Tile로 분할
Tile별 Geometry 분류
↓
빠른 On-Chip Memory에서 Rasterization과 Fragment 처리
```

Color와 Depth를 Tile Memory에 유지하면 외부 메모리 대역폭을 줄일 수 있다.

하지만 Render Target 전환, 불필요한 Store와 Load, 많은 Transparent Overdraw는 Tile GPU에서도 비용이 될 수 있다.

Rasterization의 논리적 결과는 같더라도 실제 처리 방식과 병목은 Immediate Mode GPU와 다를 수 있다.

---

## Variable Rate Shading

일부 현대 GPU는 화면 영역에 따라 Fragment Shading Rate를 조절할 수 있다.

여러 Pixel의 Coverage를 유지하면서 Fragment Shader 결과를 더 거친 단위로 공유하는 방식이 가능하다.

```text
중요한 중앙 영역
1×1 Shading

덜 중요한 주변 영역
2×2 또는 더 거친 Shading
```

VR의 Foveated Rendering과 성능 최적화에 활용할 수 있다.

Coverage, Depth와 Shading Invocation의 관계가 분리될 수 있으므로 Fragment 하나가 항상 Pixel 하나라고 보는 모델은 현대 Pipeline에서 더 부정확하다.

Unity와 XR 플랫폼의 VRS 지원 범위는 버전과 하드웨어를 확인해야 한다.

---

## Rasterization 비용은 무엇이 결정할까?

Rasterization 관련 비용에는 여러 요소가 영향을 준다.

```text
Triangle 수
Screen Space Triangle 크기
작은 Triangle 비율
Clipping되는 Primitive 수
Backface Culling 상태
Render Target 해상도
MSAA Sample 수
Overdraw
Scissor와 Viewport
```

Triangle이 많으면 Primitive Setup 비용이 증가할 수 있고 Triangle이 화면을 크게 덮으면 Fragment 수가 증가한다.

작은 Triangle이 많으면 Primitive와 Fragment 실행 효율이 낮아질 수 있다.

따라서 Polygon 수나 해상도 한 가지 지표만으로 Rasterization 병목을 판단할 수 없다.

---

## Triangle 수가 같아도 비용이 다른 이유

두 Scene의 Triangle 수가 같아도 화면 Coverage가 다르면 Fragment 작업량이 크게 달라진다.

```text
Scene A
Triangle 10,000개
화면의 작은 영역

Scene B
Triangle 10,000개
화면 전체를 여러 번 덮음
```

Scene B는 더 많은 Fragment와 Overdraw를 만들 수 있다.

반대로 Scene A의 Triangle이 모두 Sub-Pixel 크기라면 Primitive 처리 효율 문제가 생길 수 있다.

Geometry 병목과 Fragment 병목을 나누어 측정해야 한다.

---

## Rasterization을 직접 Shader로 작성할까?

일반적인 Graphics Pipeline에서 Triangle Coverage 계산은 Fixed-Function Rasterizer가 수행한다.

개발자는 Cull, Fill, Depth Bias, MSAA 같은 State를 설정할 수 있지만 기본 Triangle Rasterization Algorithm을 Vertex나 Fragment Shader로 교체하지 않는다.

Compute Shader로 Software Rasterizer를 구현할 수는 있지만 전용 Rasterization Hardware의 기능과 최적화를 직접 다시 만들어야 한다.

특수한 연구와 Rendering Technique가 아니라면 GPU의 Fixed-Function Rasterizer를 사용하는 것이 효율적이다.

---

## Rasterization 문제를 확인하는 방법

Triangle이 예상과 다르게 보이면 Pipeline의 앞뒤 단계를 함께 확인해야 한다.

```text
Vertex Position 오류
Triangle 위치와 형태가 잘못됨

Winding / Cull 오류
Triangle이 사라짐

Clipping 오류
Camera 경계에서 잘림

Interpolation 오류
Texture와 Normal이 왜곡됨

MSAA / Coverage 문제
Edge 품질이 달라짐

Depth 문제
Fragment는 생성되지만 Test에서 제거됨
```

Unity Frame Debugger는 Draw 순서와 Render State를 보여 주고 RenderDoc Mesh Viewer는 Vertex Shader 전후의 Geometry와 Pipeline State를 확인하는 데 유용하다.

Overdraw View는 화면에 Fragment가 반복 생성되는 영역을 찾는 데 도움을 준다.

---

## 전체 흐름

Rasterization 전후의 흐름을 정리하면 다음과 같다.

```text
Vertex Shader
Clip Position과 Varying 출력
↓
Primitive Assembly
Triangle 구성
↓
Backface Culling
↓
Clip Volume Clipping
↓
Perspective Divide
↓
Viewport Transform
↓
Triangle Setup
Edge와 Bounding 영역 준비
↓
Coverage Test
Pixel / Sample 포함 판정
↓
Barycentric / Perspective Interpolation
UV, Normal, Color, Depth 계산
↓
Fragment와 Coverage Mask
↓
Early Depth 가능
↓
Fragment Shader
```

Rasterization은 Geometry Processing과 Fragment Processing을 연결하는 단계다.

---

## 정리

Rasterization은 Point, Line, Triangle 같은 Primitive를 화면의 Sample 위치에 대응하는 Fragment와 Coverage 정보로 변환하는 과정이다.

Vertex Shader의 Clip Position은 Clipping, Perspective Divide와 Viewport Transform을 거쳐 Framebuffer 좌표에 대응된다.

Rasterizer는 Triangle의 Bounding 영역과 Edge를 기준으로 각 Sample이 Triangle 내부에 있는지 판정한다.

공유 Edge에서는 인접 Triangle 사이에 틈이나 불필요한 중복이 생기지 않도록 Graphics API가 일관된 Coverage 규칙을 정의한다.

Fragment는 최종 Pixel이 아니라 Screen Position, Depth, Coverage Mask와 보간 Attribute를 가진 렌더링 후보 데이터다.

한 Pixel 위치에는 여러 Primitive의 Fragment가 생성될 수 있고 일부는 Depth Test에서 제거되거나 Blending으로 결합된다.

Rasterizer는 Barycentric Coordinate와 Clip `w`를 이용한 Perspective-Correct Interpolation으로 UV, Normal과 Color를 Fragment Shader에 전달한다.

`noperspective`, `nointerpolation`, `centroid`, `sample` 같은 설정은 보간 위치와 방식을 바꿀 수 있다.

MSAA는 Pixel 내부의 여러 Sample에서 Geometry Coverage와 Depth를 평가하여 Triangle Edge Alias를 줄인다.

MSAA Sample 수와 Fragment Shader Invocation 수는 항상 같지 않으며 Sample Shading 설정에 따라 달라질 수 있다.

작은 Triangle은 적은 Sample만 덮으면서도 Primitive Setup과 Fragment 실행 그룹을 사용하므로 GPU 활용 효율이 낮아질 수 있다.

Rasterization 비용은 Triangle 수뿐 아니라 Screen Coverage, 작은 Triangle 비율, 해상도, MSAA, Culling과 Overdraw에 영향을 받는다.

Rasterization이 만든 Fragment와 보간 데이터가 다음 Programmable Stage로 전달되면 Fragment Shader가 Texture와 Lighting을 이용해 최종 Color 후보를 계산한다.
