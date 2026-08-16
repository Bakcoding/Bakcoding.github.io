---
title: "[Unity 렌더링] 2-4. Vertex는 어떻게 화면 좌표로 변환될까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - Vertex
  - Matrix
  - MVP
permalink: /programming/unity-2-4-vertex-screen-coordinate/
toc: true
toc_sticky: true
date: 2026-08-15
last_modified_at: 2026-08-15
---

Mesh의 Vertex Position은 일반적으로 오브젝트 자신의 Local Space에 저장된다.

하지만 GPU가 Triangle을 화면에 그리려면 각 Vertex가 Camera 화면의 어느 위치에 나타날지 알아야 한다.

Local Position은 곧바로 Screen Position이 되지 않는다.

오브젝트의 Transform, Camera의 위치와 방향, Perspective 또는 Orthographic 설정, 화면의 Viewport를 차례로 반영해야 한다.

```text
Local Position
↓ Model Matrix
World Position
↓ View Matrix
View Position
↓ Projection Matrix
Clip Position
↓ Perspective Divide
NDC Position
↓ Viewport Transform
Screen Position
```

이 과정의 중심에는 Matrix가 있다.

Model, View, Projection Matrix가 각각 어떤 변환을 담당하는지 이해하면 Vertex Shader가 출력하는 Clip Position이 어떻게 실제 화면으로 이어지는지 알 수 있다.

---

## Matrix는 왜 사용할까?

3D 오브젝트를 배치하려면 Vertex에 이동, 회전, 크기 변환을 적용해야 한다.

```text
Scale
오브젝트 크기 변경

Rotation
오브젝트 방향 변경

Translation
오브젝트 위치 변경
```

이 변환을 매번 서로 다른 계산식으로 처리할 수도 있다.

하지만 Matrix를 사용하면 여러 변환을 일정한 형식으로 표현하고 하나의 변환으로 결합할 수 있다.

```text
Scale Matrix
Rotation Matrix
Translation Matrix
↓ 결합
Model Matrix
```

결합된 Matrix를 각 Vertex에 적용하면 같은 오브젝트에 속한 많은 Vertex를 일관된 방식으로 변환할 수 있다.

```text
Vertex 0 × Model Matrix
Vertex 1 × Model Matrix
Vertex 2 × Model Matrix
...
```

GPU는 많은 Vertex에 같은 종류의 행렬 연산을 반복하는 작업을 병렬로 처리하기에 적합하다.

---

## 4×4 Matrix를 사용하는 이유

3D Position은 보통 `(x, y, z)`의 세 값으로 생각한다.

그런데 그래픽스 변환에서는 네 번째 성분 `w`를 더한 `(x, y, z, w)` 형태를 자주 사용한다.

```text
3D Position
(x, y, z)

Homogeneous Position
(x, y, z, w)
```

이런 표현을 동차 좌표라고 한다.

동차 좌표를 사용하면 3D의 이동까지 4×4 Matrix 곱셈으로 함께 표현할 수 있다.

개념적인 Translation Matrix는 다음과 같은 형태다.

```text
| 1  0  0  Tx |
| 0  1  0  Ty |
| 0  0  1  Tz |
| 0  0  0   1 |
```

Position `(x, y, z, 1)`에 이 Matrix를 적용하면 이동량이 더해진다.

```text
(x, y, z, 1)
↓ Translation
(x + Tx, y + Ty, z + Tz, 1)
```

회전과 크기뿐 아니라 이동도 같은 Matrix 형식으로 결합할 수 있기 때문에 그래픽스에서는 4×4 Matrix가 널리 사용된다.

---

## Position의 w는 왜 1일까?

공간의 한 지점을 나타내는 Position은 일반적으로 `w = 1`로 표현한다.

```text
Position
(x, y, z, 1)
```

이 값에 Translation Matrix를 적용하면 이동 성분의 영향을 받는다.

반면 Direction은 특정 위치가 아니라 방향을 의미하므로 일반적으로 `w = 0`으로 표현할 수 있다.

```text
Direction
(x, y, z, 0)
```

Translation Matrix를 적용해도 이동 성분에 `w = 0`이 곱해지므로 방향에는 위치 이동이 더해지지 않는다.

```text
Position w = 1
→ Translation 적용

Direction w = 0
→ Translation 무시
```

Position과 Direction이 모두 `float3`처럼 보이더라도 변환 방식이 달라야 하는 이유다.

다만 Projection 이후의 Clip Position에서 `w`는 단순히 Position과 Direction을 구분하는 값에 머물지 않는다.

원근 투영과 Perspective Divide를 만드는 중요한 값으로 사용된다.

---

## 변환 순서는 왜 중요할까?

Matrix 변환은 순서를 바꾸어도 같은 결과가 나오는 일반적인 곱셈이 아니다.

오브젝트를 회전한 뒤 이동하는 것과 이동한 뒤 World 원점을 기준으로 회전하는 것은 결과가 다르다.

```text
경우 A
Local에서 회전
↓
World 위치로 이동

경우 B
World 위치로 이동
↓
World 원점을 기준으로 회전
```

첫 번째는 오브젝트가 자신의 자리에서 방향을 바꾼 뒤 배치되는 결과가 될 수 있다.

두 번째는 이미 이동한 오브젝트가 World 원점 주변을 도는 결과가 될 수 있다.

따라서 Matrix를 결합하는 순서는 실제로 적용하려는 변환 순서를 반영해야 한다.

행 벡터와 열 벡터 중 어느 표기 관례를 사용하는지에 따라 수식에 보이는 곱셈 순서는 달라질 수 있다.

이 글에서는 Vertex를 열 벡터처럼 두는 다음 개념 표기를 사용한다.

```text
World Position = Model Matrix × Local Position
```

중요한 것은 문자로 보이는 좌우 순서를 외우는 것이 아니라 각 Matrix가 어느 공간을 다음 공간으로 바꾸는지 이해하는 것이다.

---

## Model Matrix란?

Model Matrix는 Object 또는 Local Space Position을 World Space Position으로 변환한다.

Unity GameObject의 Position, Rotation, Scale이 Model Matrix 구성에 반영된다.

```text
Local Position
↓ Scale
↓ Rotation
↓ Translation
World Position
```

같은 Cube Mesh를 두 GameObject가 공유한다고 가정할 수 있다.

```text
Cube Mesh Local Vertex
(0.5, 0.5, 0.5)
```

GameObject A와 B는 서로 다른 Model Matrix를 가진다.

```text
GameObject A
Position = (0, 0, 0)
Scale = (1, 1, 1)

GameObject B
Position = (10, 0, 5)
Scale = (2, 2, 2)
```

같은 Local Vertex에 서로 다른 Model Matrix를 적용하면 World Position이 달라진다.

```text
Model Matrix A × Local Vertex
→ A의 World Position

Model Matrix B × Local Vertex
→ B의 World Position
```

Mesh Asset을 복제하지 않고도 동일한 기하 데이터를 여러 위치와 크기로 배치할 수 있다.

---

## Unity의 Object To World 변환

Unity Shader에서는 Render Pipeline이 제공하는 변환 함수를 사용하는 것이 일반적이다.

URP의 `Core.hlsl`을 포함하면 Object Space Position을 World Space로 변환할 수 있다.

```hlsl
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

float3 positionWS = TransformObjectToWorld(positionOS.xyz);
```

이때 `positionOS`는 Mesh에 저장된 Object Space Position이고 `positionWS`는 현재 오브젝트의 Transform이 적용된 World Space Position이다.

```text
positionOS
↓ TransformObjectToWorld
positionWS
```

내부 Matrix와 저장 방식에 직접 의존하는 것보다 Pipeline의 Helper 함수를 사용하면 플랫폼과 렌더링 구조의 차이를 처리하기 쉽다.

---

## 부모 Transform도 Model 변환에 포함된다

GameObject가 Transform 계층 안에 있다면 최종 World 변환에는 부모의 Transform도 영향을 준다.

```text
Character
└─ Hand
   └─ Sword
```

Sword Mesh의 Vertex는 Sword Local Space에서 시작한다.

최종 World Position에는 Sword, Hand, Character의 계층 변환이 연결된다.

```text
Sword Local Vertex
↓ Sword Local Transform
Hand Space
↓ Hand Transform
Character Space
↓ Character Transform
World Space
```

Unity는 계층의 최종 결과를 World 변환으로 구성하여 렌더링에 사용할 수 있게 한다.

자식 Mesh의 Vertex Shader가 부모 계층을 하나씩 직접 순회하는 방식으로 이해할 필요는 없다.

렌더링 시점에는 해당 Renderer에 필요한 최종 Object-to-World 변환이 준비된다.

---

## View Matrix란?

View Matrix는 World Space Position을 Camera 기준의 View Space Position으로 변환한다.

```text
View Position = View Matrix × World Position
```

World Space에서는 Camera도 Position과 Rotation을 가진 하나의 오브젝트다.

하지만 화면 투영을 계산할 때는 Camera가 기준점에 있다고 보는 편이 편리하다.

View Matrix는 개념적으로 Camera Transform의 역변환을 World 전체에 적용한다.

```text
Camera가 오른쪽으로 3 이동
↓ View Matrix
World가 Camera 기준으로 왼쪽 3 이동한 것처럼 표현
```

Camera가 회전하면 World의 오브젝트도 반대 방향으로 회전한 Camera 기준 좌표로 바뀐다.

이 결과를 이용하면 모든 Vertex를 같은 Camera 기준에서 Projection할 수 있다.

---

## Camera Transform과 View Matrix는 같은 Matrix일까?

Camera Transform은 Camera의 Local Space를 World Space로 변환하는 정보를 나타낸다.

View Matrix는 반대로 World Space를 Camera의 View Space로 변환해야 한다.

따라서 개념적으로 서로 역변환 관계에 있다.

```text
Camera Transform
Camera Local → World

View Matrix
World → Camera View
```

Camera가 World의 `(0, 0, 10)`에 있다고 해서 모든 Vertex에 `(0, 0, 10)`을 더하는 것이 아니다.

Camera를 원점으로 옮긴 것처럼 World Position에 반대 변환을 적용한다.

이 구분을 알면 Camera가 움직일 때 Scene의 모든 오브젝트가 반대 방향으로 움직여 보이는 이유를 이해할 수 있다.

---

## Model과 View를 결합할 수 있다

Local Position을 View Space까지 변환하려면 Model Matrix와 View Matrix를 차례로 적용한다.

```text
View Position
= View Matrix × Model Matrix × Local Position
```

Model과 View를 결합한 Matrix를 Model-View Matrix라고 부를 수 있다.

```text
Model-View Matrix
= View Matrix × Model Matrix
```

그러면 각 Vertex에 두 Matrix를 별도로 적용하는 대신 결합된 Matrix를 사용할 수 있다.

```text
View Position
= Model-View Matrix × Local Position
```

Matrix를 미리 결합하면 Vertex마다 반복하는 연산을 줄일 수 있다.

실제 Render Pipeline이 Matrix를 언제, 어떤 형태로 결합하는지는 Pipeline과 플랫폼 구현에 따라 달라질 수 있다.

---

## Projection Matrix란?

Projection Matrix는 View Space Position을 Clip Space Position으로 변환한다.

```text
Clip Position = Projection Matrix × View Position
```

Camera가 Perspective인지 Orthographic인지에 따라 Projection Matrix의 성질이 달라진다.

Perspective Projection은 멀리 있는 물체가 작게 보이도록 만든다.

Orthographic Projection은 거리에 따른 크기 변화를 만들지 않는다.

```text
Perspective
가까운 물체 → 크게
먼 물체     → 작게

Orthographic
가까운 물체와 먼 물체의 투영 크기가 같음
```

Projection Matrix는 단순히 Z축을 제거하여 3D를 2D로 만드는 Matrix가 아니다.

Camera의 시야 범위를 Clip Space에 대응시키고, Clipping과 Perspective Divide에 필요한 정보를 만든다.

---

## Perspective Projection에 필요한 값

Perspective Camera의 Projection Matrix에는 보통 다음 설정이 영향을 준다.

```text
Field of View
Camera가 보는 각도

Aspect Ratio
Viewport의 가로와 세로 비율

Near Clip Plane
가까운 Clipping 경계

Far Clip Plane
먼 Clipping 경계
```

Field of View가 커지면 더 넓은 영역이 화면에 들어오고 오브젝트는 상대적으로 작게 보일 수 있다.

Aspect Ratio를 반영하지 않으면 화면이 가로나 세로로 늘어나 보일 수 있다.

Near와 Far Plane은 Camera가 처리하는 깊이 범위를 정의하고 Depth 정밀도와도 관련된다.

이 값들을 기준으로 View Frustum이 Clip Space의 표준화된 영역에 대응되도록 Projection Matrix가 구성된다.

---

## Perspective는 어떻게 먼 물체를 작게 만들까?

Perspective Projection의 핵심은 깊이와 관련된 값으로 X와 Y를 나누는 과정이다.

View Space에서 비슷한 X 위치를 가진 두 Vertex가 서로 다른 깊이에 있다고 가정할 수 있다.

```text
가까운 Vertex
X = 1, Depth = 2

먼 Vertex
X = 1, Depth = 10
```

깊이와 관련된 값으로 나누면 먼 Vertex의 화면상 X 크기가 더 작아진다.

```text
가까운 값
1 / 2 = 0.5

먼 값
1 / 10 = 0.1
```

실제 Projection Matrix와 좌표 부호는 Graphics API와 Convention에 따라 더 복잡하지만 원근감의 기본 원리는 이와 연결된다.

GPU에서는 Projection Matrix가 Clip Position의 `w`를 만들고, 이후 Perspective Divide에서 `x`, `y`, `z`를 `w`로 나눈다.

---

## Clip Position의 w

Vertex Shader가 출력해야 하는 위치는 일반적으로 Clip Space의 `float4` 값이다.

```hlsl
float4 positionCS : SV_POSITION;
```

Perspective Projection이 적용되면 Clip Position의 `w`에는 View 깊이와 관련된 정보가 들어간다.

```text
Clip Position
(xClip, yClip, zClip, wClip)
```

Vertex Shader가 끝난 뒤 GPU의 고정 기능 단계는 이 값을 이용해 Clipping과 Perspective Divide를 진행한다.

```text
NDC.x = xClip / wClip
NDC.y = yClip / wClip
NDC.z = zClip / wClip
```

따라서 Vertex Shader에서 Clip Position의 `w`를 임의로 잃어버리거나 항상 1로 고정하면 정상적인 원근 결과와 깊이 처리가 깨질 수 있다.

---

## Orthographic Projection에서는 무엇이 다를까?

Orthographic Projection은 거리에 따라 화면상의 X와 Y 크기를 줄이지 않는다.

평행한 선은 Projection 이후에도 평행하게 유지되고, 같은 크기의 물체는 Camera와의 거리가 달라도 같은 크기로 보인다.

```text
Perspective Frustum
멀어질수록 시야 영역이 넓어짐

Orthographic Volume
깊이에 따라 시야 폭이 변하지 않음
```

Orthographic Projection도 View Space를 Clip Space로 변환하고 Near와 Far 범위를 처리하기 위해 Projection Matrix를 사용한다.

다만 Perspective Projection처럼 깊이에 따른 크기 축소를 만드는 형태가 아니다.

2D 게임, 전략 게임의 특정 Camera, UI 또는 기술적인 시각화에서 Orthographic Camera를 사용할 수 있다.

---

## MVP Matrix란?

Local Position에서 Clip Position까지의 변환을 하나로 연결하면 다음과 같다.

```text
Clip Position
= Projection Matrix
× View Matrix
× Model Matrix
× Local Position
```

Model, View, Projection의 앞 글자를 따서 MVP 변환이라고 부른다.

```text
M = Model
V = View
P = Projection
```

세 Matrix를 결합한 MVP Matrix를 사용하면 Vertex Shader에서 한 번의 Matrix-Vector 곱 형태로 Clip Position을 계산할 수 있다.

```text
MVP Matrix = Projection × View × Model

Clip Position = MVP Matrix × Local Position
```

수학 표기와 Shader 언어의 `mul` 인자 순서는 사용하는 행렬 Convention에 따라 달라질 수 있다.

Unity에서는 Render Pipeline의 변환 함수를 사용하여 내부 Convention에 맞게 처리하는 편이 안전하다.

---

## Unity URP에서 Object Position을 Clip Position으로 변환

Unity 6 URP Shader에서는 `TransformObjectToHClip`을 사용할 수 있다.

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

    output.positionCS =
        TransformObjectToHClip(input.positionOS.xyz);

    return output;
}
```

`positionOS`는 Object Space Position이고 `positionCS`는 Clip Space Position이다.

`HClip`의 H는 Homogeneous Clip Space를 나타낸다.

이 함수는 개념적으로 Object-to-World와 View-Projection 변환을 연결하여 Rasterizer가 요구하는 Clip Position을 만든다.

---

## GetVertexPositionInputs

Shader에서 World, View, Clip Position이 모두 필요할 때는 `GetVertexPositionInputs`를 사용할 수 있다.

```hlsl
VertexPositionInputs positions =
    GetVertexPositionInputs(input.positionOS.xyz);

float3 positionWS = positions.positionWS;
float3 positionVS = positions.positionVS;
float4 positionCS = positions.positionCS;
float4 positionNDC = positions.positionNDC;
```

예를 들어 Clip Position은 Vertex Shader 출력에 사용하고, World Position은 Lighting이나 Camera 방향 계산에 사용할 수 있다.

```text
positionWS
World Space 연산

positionVS
Camera 기준 연산

positionCS
Rasterization 위치 출력

positionNDC
화면 위치 관련 연산
```

필요하지 않은 공간까지 항상 계산해야 한다는 의미는 아니다.

Shader가 실제로 사용하는 값에 맞는 Helper 함수와 데이터만 선택하는 것이 좋다.

---

## Vertex Shader가 Screen Position을 직접 출력할까?

Vertex Shader의 위치 출력은 일반적으로 최종 Pixel 단위의 Screen Position이 아니라 Clip Position이다.

```text
Vertex Shader
Clip Position 출력
↓
GPU 고정 기능 단계
Clipping
Perspective Divide
Viewport Transform
↓
화면 위치
```

이 구분이 중요한 이유는 Triangle의 Clipping과 Perspective-Correct Interpolation이 `w`를 포함한 Clip 좌표를 필요로 하기 때문이다.

Vertex Shader에서 해상도에 맞춘 2D Pixel 좌표를 바로 만들면 Graphics Pipeline이 기대하는 일반적인 Clip Space 처리와 맞지 않는다.

Render Pipeline은 Clip Position을 받은 뒤 현재 Viewport와 Graphics API 규칙에 맞는 화면 좌표를 만든다.

---

## Clipping은 Perspective Divide 전에 일어난다

Clip Space의 이름처럼 이 단계에서는 Camera의 View Volume 밖에 있는 Primitive를 판정한다.

```text
Vertex Shader 출력
↓
Clip Space에서 Primitive 검사
↓
완전히 밖이면 제거
경계와 교차하면 잘라냄
↓
Perspective Divide
```

Perspective Divide 전에 Clipping하는 것은 Camera 뒤쪽이나 Near Plane을 가로지르는 Primitive를 안정적으로 처리하는 데 중요하다.

Triangle의 일부가 View Volume 안에 있으면 경계와 만나는 지점에 새로운 Vertex가 만들어질 수 있다.

새 Vertex의 Position뿐 아니라 UV, Normal, Color 같은 속성도 경계 위치에 맞게 계산되어야 한다.

---

## Perspective Divide

Clipping 이후 Clip Position을 `w`로 나누면 NDC Position을 얻는다.

```text
(xClip, yClip, zClip, wClip)
↓
(xClip / wClip,
 yClip / wClip,
 zClip / wClip)
↓
NDC
```

Perspective Divide는 Perspective Projection에서 멀리 있는 Vertex를 화면 중심 쪽으로 더 가깝게 모은다.

같은 World 크기의 오브젝트가 Camera에서 멀어질수록 NDC에서 차지하는 범위가 작아진다.

```text
가까운 Triangle
NDC에서 넓은 범위

먼 Triangle
NDC에서 좁은 범위
```

Orthographic Projection에서는 깊이에 따른 X와 Y 축소가 발생하지 않도록 Clip Position이 구성된다.

---

## NDC에서 Screen Space로

NDC는 화면 해상도와 독립적인 정규화 좌표다.

Viewport Transform은 NDC를 현재 Viewport의 위치와 크기에 대응시킨다.

개념적으로 X축을 다음처럼 변환할 수 있다.

```text
NDC X 범위
-1 ~ 1

정규화
0 ~ 1

Viewport Width 적용
0 ~ Width
```

단순화한 식은 다음과 같다.

```text
normalizedX = NDC.x × 0.5 + 0.5

screenX = viewportX
        + normalizedX × viewportWidth
```

Y축과 Depth도 Viewport와 Graphics API 규칙에 맞게 변환된다.

Unity가 Direct3D, Metal, Vulkan, OpenGL 계열 API를 지원하므로 Shader에서 모든 플랫폼의 Y 방향과 깊이 범위를 하나의 고정된 규칙으로 가정하면 안 된다.

---

## 화면 해상도가 바뀌면 Vertex 변환도 달라질까?

NDC까지의 좌표는 직접적인 Pixel 해상도와 분리되어 있다.

같은 NDC 위치는 Viewport Transform을 통해 현재 해상도에 맞는 Screen Position으로 변환된다.

```text
NDC 중앙
(0, 0)

1920×1080 Viewport
→ 화면 중앙 부근 (960, 540)

2560×1440 Viewport
→ 화면 중앙 부근 (1280, 720)
```

하지만 해상도의 Aspect Ratio가 바뀌면 Camera Projection Matrix도 영향을 받을 수 있다.

Aspect Ratio를 Projection에 반영해야 오브젝트가 가로 또는 세로로 찌그러지지 않는다.

즉 해상도는 Viewport Transform뿐 아니라 Camera가 구성하는 Projection에도 연결될 수 있다.

---

## Vertex 사이의 위치는 어떻게 채워질까?

Vertex Shader는 Mesh의 각 Vertex 위치를 변환한다.

하지만 Triangle 내부의 모든 Pixel 위치마다 새로운 Mesh Vertex를 실행하는 것은 아니다.

세 Vertex가 Clip Space를 거쳐 화면에 투영되면 Rasterizer가 Triangle이 덮는 Fragment를 결정한다.

```text
Vertex A ─┐
Vertex B ─┼→ Triangle → Rasterization → Fragment
Vertex C ─┘
```

UV, Color, Normal 같은 Vertex Shader 출력은 Triangle 내부에서 보간된다.

Perspective Projection에서는 단순한 화면상 선형 보간만 사용하면 Texture가 왜곡될 수 있다.

GPU는 Clip Position의 `w`를 고려한 Perspective-Correct Interpolation을 사용하여 속성을 계산할 수 있다.

따라서 `w`는 Vertex 위치뿐 아니라 Triangle 내부 속성이 올바르게 이어지는 데도 중요하다.

---

## Normal도 MVP Matrix로 변환하면 될까?

Normal은 Position이 아니라 표면에 수직인 Direction이다.

따라서 Translation의 영향을 받으면 안 되고, Projection Matrix로 화면에 투영할 대상도 아니다.

```text
Position
Model → View → Projection

Normal
Lighting 계산에 필요한 공간까지만 변환
```

특히 오브젝트에 비균일 Scale이 적용되면 Normal에 Model Matrix를 그대로 적용했을 때 표면과 수직인 성질이 깨질 수 있다.

이 경우 역전치 Matrix와 관련된 올바른 Normal 변환이 필요하다.

Unity URP에서는 `TransformObjectToWorldNormal` 같은 Helper 함수를 사용할 수 있다.

```hlsl
float3 normalWS = TransformObjectToWorldNormal(normalOS);
```

Vertex Position과 Normal의 자료형이 비슷하다는 이유로 같은 변환을 적용하면 안 된다.

---

## CPU와 GPU 중 누가 Matrix를 만들까?

개념적으로 CPU 측 Render Pipeline은 Camera와 Renderer 상태를 기준으로 필요한 Matrix 데이터를 준비한다.

GPU의 Vertex Shader는 전달받은 Matrix 또는 변환 데이터를 이용하여 많은 Vertex를 처리한다.

```text
CPU
Transform과 Camera 상태 확인
Matrix 및 렌더링 데이터 준비
Command 제출
↓
GPU
각 Vertex에 변환 적용
Clip Position 출력
```

같은 Renderer의 Vertex는 공통된 Object-to-World 변환을 사용할 수 있다.

Camera가 같다면 View와 Projection 관련 데이터도 여러 Draw에서 공유될 수 있다.

Unity의 실제 데이터 전달과 Batching 방식은 Render Pipeline, SRP Batcher, GPU Instancing 등에 따라 달라질 수 있다.

---

## GPU Instancing에서는 무엇이 달라질까?

같은 Mesh를 여러 Transform으로 그리는 GPU Instancing에서는 각 Instance가 서로 다른 Model 변환을 가져야 한다.

```text
같은 Mesh
같은 Material

Instance 0 → Model Matrix 0
Instance 1 → Model Matrix 1
Instance 2 → Model Matrix 2
```

Vertex Shader는 현재 Instance에 해당하는 Object-to-World 변환을 이용하여 같은 Local Vertex를 서로 다른 World Position으로 바꾼다.

View와 Projection은 같은 Camera를 기준으로 공유될 수 있지만 Model 변환은 Instance마다 다르다.

이 구조는 Local Space Mesh 데이터와 Transform을 분리했기 때문에 가능하다.

---

## Skinned Mesh의 Vertex는 어디서 시작할까?

Skinned Mesh는 Model Matrix를 적용하기 전에 Bone 변환을 이용해 Vertex 형태를 변경한다.

각 Vertex의 Bone Weight와 Bone Index를 이용하여 여러 Bone Matrix의 영향을 결합한다.

```text
Mesh Local Vertex
↓ Skinning
변형된 Local Vertex
↓ Model Matrix
World Position
↓ View / Projection
Clip Position
```

Character가 팔을 움직이면 Vertex의 Local 형태가 Bone에 따라 변한 뒤 Character의 World Transform이 적용된다.

Skinned Mesh도 최종적으로는 View와 Projection을 거쳐 Clip Position을 출력해야 한다는 점은 같다.

---

## Matrix를 직접 곱할 때 주의할 점

Shader 코드에서 Matrix를 직접 다룰 수 있지만 다음 요소를 함께 고려해야 한다.

```text
행 벡터와 열 벡터 Convention
Matrix 곱셈 순서
Matrix 저장 Layout
Graphics API의 Clip Space 규칙
Render Texture Y 방향
Stereo Rendering
Camera-relative Rendering
```

겉으로 같은 4×4 값처럼 보여도 Convention을 잘못 적용하면 오브젝트가 뒤집히거나 엉뚱한 위치에 나타날 수 있다.

Unity와 URP가 제공하는 Helper 함수는 현재 Pipeline의 변환 규칙을 따르므로 일반적인 Shader에서는 이를 우선 사용하는 편이 안전하다.

특수한 렌더링 효과를 위해 Matrix를 직접 구성한다면 대상 플랫폼과 XR 환경까지 실제 결과를 확인해야 한다.

---

## 변환 과정에서 발생할 수 있는 문제

Vertex 변환이 잘못되면 다음과 같은 결과가 나타날 수 있다.

```text
Model Matrix 문제
오브젝트 위치, 회전, 크기가 잘못됨

View Matrix 문제
Camera 이동과 Scene 움직임이 맞지 않음

Projection Matrix 문제
원근감, Aspect Ratio, 깊이 범위가 잘못됨

Perspective Divide 문제
깊이에 따른 크기와 위치가 비정상적임

Viewport 문제
화면 위치가 뒤집히거나 영역이 어긋남
```

디버깅할 때는 Local에서 Screen까지 한 번에 확인하기보다 각 단계의 값을 나누어 검사하는 것이 좋다.

Shader에서 World Position이나 View Position을 Color로 시각화하거나 Frame Debugger와 GPU Frame Capture 도구를 이용할 수 있다.

---

## Vertex 변환 비용은 어떻게 볼까?

Model, View, Projection 변환은 렌더링되는 Vertex마다 실행되는 기본 작업이다.

```text
Vertex 수
×
Vertex Shader의 변환과 추가 연산
```

Mesh의 Vertex가 많거나 같은 Mesh를 여러 Pass에서 반복 렌더링하면 전체 Vertex Shader 실행 수도 늘어날 수 있다.

Shadow Pass, Depth Prepass, 여러 Camera는 같은 Geometry를 추가로 처리할 수 있다.

하지만 Matrix 곱셈이 존재한다는 이유만으로 성능 문제라고 판단하면 안 된다.

```text
실제 Vertex 수
Vertex Shader 복잡도
Render Pass 수
GPU의 Vertex 처리 능력
Fragment 처리와의 상대적인 비용
```

을 함께 측정해야 한다.

많은 게임에서는 Fragment Shader, Overdraw, Texture Sampling, Lighting 등이 더 큰 병목일 수 있다.

반대로 매우 많은 Vertex와 복잡한 Skinning을 처리하거나 작은 Triangle이 많은 Scene에서는 Vertex와 Geometry 관련 비용이 중요할 수 있다.

---

## 전체 흐름

Vertex 하나가 화면 위치로 이어지는 과정을 정리하면 다음과 같다.

```text
1. Mesh에서 Local Position 읽기

2. 필요한 경우 Skinning 또는 Vertex 변형

3. Model Matrix 적용
   Local → World

4. View Matrix 적용
   World → View

5. Projection Matrix 적용
   View → Clip

6. Vertex Shader가 Clip Position 출력

7. Clip Space에서 Primitive Clipping

8. Perspective Divide
   Clip → NDC

9. Viewport Transform
   NDC → Screen

10. Triangle Rasterization
    Fragment 생성
```

Vertex Shader가 모든 단계를 직접 실행하는 것은 아니다.

일반적으로 Vertex Shader는 Clip Position까지 출력하고, Clipping, Perspective Divide, Viewport Transform, Rasterization은 이후 Graphics Pipeline 단계에서 처리된다.

---

## 정리

Mesh의 Vertex Position은 일반적으로 Local Space에 저장되며 화면에 그리기 위해 여러 변환을 거친다.

Matrix를 사용하면 Scale, Rotation, Translation과 같은 변환을 일정한 형식으로 표현하고 결합할 수 있다.

3D 그래픽스에서 4×4 Matrix와 동차 좌표를 사용하면 Translation까지 Matrix 곱셈에 포함할 수 있다.

Position은 일반적으로 `w = 1`, Direction은 `w = 0`으로 표현하여 Translation의 영향을 구분할 수 있다.

Model Matrix는 Local Position을 World Position으로 변환하며 GameObject의 위치, 회전, 크기와 부모 계층의 최종 변환을 반영한다.

View Matrix는 World Position을 Camera 기준의 View Position으로 변환하고, 개념적으로 Camera Transform의 역변환 역할을 한다.

Projection Matrix는 View Position을 Clip Position으로 바꾸며 Perspective 또는 Orthographic Camera의 투영 방식과 Near, Far, Field of View, Aspect Ratio를 반영한다.

Model, View, Projection을 연결한 변환을 MVP라고 부른다.

Unity 6 URP에서는 `TransformObjectToHClip`을 이용하여 Object Space Position을 Clip Space로 변환할 수 있다.

Vertex Shader는 일반적으로 최종 Pixel 좌표가 아니라 `w`를 포함한 Clip Position을 출력한다.

GPU는 이후 Clipping을 수행하고, Clip Position을 `w`로 나누는 Perspective Divide를 통해 NDC를 만든다.

NDC는 Viewport Transform을 거쳐 실제 Render Target의 Screen Position에 대응된다.

Normal은 Position과 의미가 다르므로 MVP Matrix로 변환하지 않으며, 비균일 Scale까지 고려하는 전용 Normal 변환을 사용해야 한다.

Vertex가 화면에 도달하는 변환 흐름을 이해하면 Camera의 View Matrix와 Perspective·Orthographic Projection이 각각 화면 결과를 어떻게 바꾸는지 더 구체적으로 연결할 수 있다.
