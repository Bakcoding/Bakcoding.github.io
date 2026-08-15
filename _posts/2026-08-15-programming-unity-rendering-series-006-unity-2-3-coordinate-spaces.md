---
title: "[Unity 렌더링] 2-3. 좌표계는 왜 여러 개가 필요할까?"
excerpt: "Unity Rendering"
categories:
  - Programming
tags:
  - Unity
  - Rendering
  - CoordinateSpace
  - Matrix
  - Shader
permalink: /programming/unity-2-3-coordinate-spaces/
toc: true
toc_sticky: true
date: 2026-08-15
last_modified_at: 2026-08-15
---

3D 오브젝트를 화면에 그리려면 Mesh의 Vertex가 최종적으로 화면의 어느 위치에 나타날지 계산해야 한다.

하지만 Vertex 위치를 처음부터 화면 좌표로 저장하지는 않는다.

Mesh는 오브젝트 자신을 기준으로 한 좌표를 저장하고, GameObject는 Scene 안에서 자신의 위치와 회전을 가지며, Camera는 다시 자신을 기준으로 Scene을 바라본다.

GPU는 Camera에 보이는 영역을 계산한 뒤 그 결과를 화면의 Pixel 위치로 변환한다.

이 과정에서 하나의 Vertex는 여러 좌표 공간을 거친다.

```text
Local Space
↓
World Space
↓
View Space
↓
Clip Space
↓
NDC
↓
Screen Space
```

좌표계가 여러 개 존재하는 이유는 같은 위치를 쓸데없이 복잡하게 표현하기 위해서가 아니다.

오브젝트 배치, Camera 관찰, 원근 투영, 화면 출력처럼 서로 다른 문제를 각 단계에 알맞은 기준으로 계산하기 위해서다.

---

## 좌표와 좌표 공간은 무엇이 다를까?

좌표는 어떤 기준을 사용하여 위치를 숫자로 표현한 값이다.

```text
(1, 2, 3)
```

하지만 이 숫자만으로는 실제 위치를 알 수 없다.

어디를 원점으로 보는지, 각 축이 어느 방향을 가리키는지, 한 단위가 어떤 기준인지가 함께 필요하다.

이러한 기준을 제공하는 것이 좌표계 또는 좌표 공간이다.

예를 들어 `(1, 0, 0)`이라는 좌표는 다음처럼 서로 다른 위치를 의미할 수 있다.

```text
캐릭터 기준 (1, 0, 0)
→ 캐릭터의 오른쪽 1만큼 떨어진 위치

World 기준 (1, 0, 0)
→ Scene 원점에서 X축으로 1만큼 떨어진 위치

Camera 기준 (1, 0, 0)
→ Camera를 기준으로 옆에 있는 위치
```

숫자는 같지만 기준 공간이 다르기 때문에 같은 위치라고 볼 수 없다.

좌표를 사용할 때는 그 값이 어느 공간에 속하는지를 함께 알아야 한다.

---

## 하나의 좌표계만 사용하면 안 될까?

모든 Mesh의 Vertex를 처음부터 World Space에 저장한다고 가정할 수 있다.

Cube를 World 원점에 배치했다면 Cube의 모든 Vertex도 원점 주변의 World 좌표로 저장한다.

이 Cube를 다른 위치로 이동하려면 모든 Vertex 위치를 직접 변경해야 한다.

```text
Cube Vertex 24개
↓
모든 Position에 이동량 적용
```

같은 Cube를 100개 배치하면 각 Cube가 서로 다른 World 좌표를 가진 Vertex 복사본을 필요로 할 수 있다.

하지만 Mesh를 오브젝트 자신의 Local Space에 저장하면 하나의 Cube Mesh를 여러 GameObject가 공유할 수 있다.

```text
Cube Mesh 하나
Local Vertex 데이터
        ↓ 공유
Cube A Transform
Cube B Transform
Cube C Transform
```

각 GameObject의 Transform만 다르게 적용하면 같은 Mesh를 Scene의 여러 위치에 배치할 수 있다.

Camera도 마찬가지다.

Scene의 모든 오브젝트 위치를 Camera가 움직일 때마다 직접 다시 저장하는 대신, World 위치를 Camera 기준의 View Space로 변환하면 된다.

각 좌표 공간은 특정 단계의 기준을 분리하여 데이터 재사용과 계산을 쉽게 만든다.

---

## Local Space란?

Local Space는 오브젝트 자신의 원점과 축을 기준으로 하는 좌표 공간이다.

Object Space라고도 부른다.

Mesh의 Vertex Position은 일반적으로 Local Space에 저장된다.

```text
Cube의 Local Space

중심 = (0, 0, 0)
오른쪽 면 = Local X 방향
위쪽 면 = Local Y 방향
앞쪽 면 = Local Z 방향
```

GameObject를 Scene의 어느 위치로 이동해도 Mesh Asset의 Local Vertex 데이터 자체는 그대로일 수 있다.

```text
Mesh Vertex
(-0.5, -0.5, -0.5)

GameObject A 위치
(0, 0, 0)

GameObject B 위치
(10, 0, 5)
```

두 GameObject는 같은 Local Vertex를 사용하지만 서로 다른 Transform을 적용하므로 World에서는 다른 위치에 나타난다.

Local Space가 있기 때문에 Mesh는 특정 Scene 위치에 종속되지 않는다.

---

## Pivot은 Local Space의 기준점이다

Unity Editor에서 오브젝트를 선택하면 이동과 회전에 사용하는 Handle이 표시된다.

Mesh 또는 GameObject의 Local 원점은 오브젝트를 배치하고 회전시키는 기준이 된다.

이 기준점을 보통 Pivot이라고 부른다.

```text
문 중앙에 Pivot
→ 중앙을 기준으로 회전

문 경첩에 Pivot
→ 경첩을 기준으로 회전
```

두 문의 Mesh 형태가 같아도 Pivot 위치에 따라 같은 회전값의 결과가 달라진다.

```text
Local Vertex
↓
Local 원점을 기준으로 회전
↓
World 위치 결정
```

따라서 Local Space는 단순한 저장 형식이 아니라 오브젝트의 이동, 회전, 크기 변경이 적용되는 기준이다.

---

## 부모와 자식의 Local Space

Unity의 Transform은 계층 구조를 만들 수 있다.

자식 Transform의 `localPosition`, `localRotation`, `localScale`은 부모 Transform을 기준으로 표현된다.

```text
Character
└─ RightHand
   └─ Sword
```

Sword의 Local 위치는 World 원점이 아니라 RightHand를 기준으로 한다.

Character가 이동하면 RightHand가 함께 이동하고 Sword도 그 계층 변환을 따라간다.

```text
Sword Local Transform
↓
RightHand Transform
↓
Character Transform
↓
World Transform
```

이 구조 덕분에 Sword의 모든 Vertex를 직접 갱신하지 않고도 부모의 움직임을 자식에 전달할 수 있다.

Unity에서 `transform.localPosition`과 `transform.position`이 다른 값을 가질 수 있는 이유도 기준 공간이 다르기 때문이다.

```csharp
Vector3 local = transform.localPosition;
Vector3 world = transform.position;
```

`localPosition`은 부모 기준이고 `position`은 World 기준이다.

---

## World Space란?

World Space는 Scene 전체가 공유하는 기준 좌표 공간이다.

각 오브젝트는 Local Space가 서로 다르지만 World Space로 변환하면 같은 기준에서 위치 관계를 비교할 수 있다.

```text
Player World Position = (2, 0, 5)
Enemy World Position  = (8, 0, 5)

두 오브젝트 사이 거리
= 6
```

게임 로직에서는 서로 다른 오브젝트의 위치를 비교해야 하는 경우가 많다.

```text
플레이어와 적 사이의 거리
Light와 표면 사이의 방향
충돌체의 Scene 위치
Camera와 오브젝트의 거리
```

이런 계산은 두 값이 같은 좌표 공간에 있을 때 의미가 있다.

Player의 Local Position과 Enemy의 World Position을 그대로 빼면 서로 다른 기준을 섞은 잘못된 결과가 될 수 있다.

```text
올바른 계산
World Position - World Position

주의할 계산
Local Position - World Position
```

World Space는 Scene의 여러 오브젝트를 하나의 공통 기준으로 연결한다.

---

## Local Space에서 World Space로 변환

Local Position을 World Position으로 바꿀 때는 GameObject의 이동, 회전, 크기가 적용된다.

이 변환을 Model Transform이라고 볼 수 있다.

```text
Local Position
↓ Scale
크기 적용
↓ Rotation
방향 적용
↓ Translation
위치 적용
↓
World Position
```

수학적으로는 이러한 변환을 하나의 Model Matrix로 묶어 표현할 수 있다.

```text
World Position = Model Matrix × Local Position
```

Unity C#에서는 `Transform.TransformPoint`를 사용해 Local Space의 위치를 World Space로 변환할 수 있다.

```csharp
Vector3 localPoint = new Vector3(0f, 1f, 0f);
Vector3 worldPoint = transform.TransformPoint(localPoint);
```

반대로 `InverseTransformPoint`는 World Position을 해당 Transform의 Local Space로 변환한다.

```csharp
Vector3 localPoint = transform.InverseTransformPoint(worldPoint);
```

이동, 회전, 크기를 Matrix로 구성하는 자세한 과정은 다음 글에서 이어진다.

---

## Position과 Direction은 다르게 변환해야 한다

Position은 공간의 특정 지점을 나타낸다.

Direction은 방향과 크기를 나타내며 특정 위치를 의미하지 않는다.

```text
Position
플레이어가 어디에 있는가?

Direction
플레이어가 어느 방향을 바라보는가?
```

오브젝트가 World에서 `(10, 0, 0)`만큼 이동하면 Local 원점은 World의 `(10, 0, 0)`으로 이동한다.

하지만 오브젝트의 위쪽 방향에 이동값 `(10, 0, 0)`을 더해서는 안 된다.

방향을 변환할 때는 위치 이동인 Translation의 영향을 받지 않아야 한다.

Unity는 목적에 맞는 변환 함수를 제공한다.

```csharp
Vector3 worldPoint = transform.TransformPoint(localPoint);
Vector3 worldDirection = transform.TransformDirection(localDirection);
Vector3 worldVector = transform.TransformVector(localVector);
```

이 함수들은 Scale 적용 여부 등 의미가 서로 다르다.

좌표값이 `Vector3`라는 이유만으로 모두 같은 방식으로 변환하면 안 된다.

Shader에서도 Position, Direction, Normal은 목적에 맞는 변환을 사용해야 한다.

특히 비균일 Scale이 적용된 오브젝트의 Normal은 Position과 같은 Matrix로 단순 변환하면 표면에 수직인 성질이 깨질 수 있다.

---

## View Space란?

View Space는 Camera를 기준으로 Scene을 표현하는 좌표 공간이다.

Camera Space 또는 Eye Space라고도 부른다.

World Space에서는 Camera가 임의의 위치와 회전을 가진다.

View Space로 변환하면 Camera를 기준점에 둔 것처럼 모든 오브젝트의 위치를 다시 표현할 수 있다.

```text
World Space
Camera와 오브젝트가 각자의 위치를 가짐

View Space
Camera를 기준으로 오브젝트 위치를 표현
```

개념적으로 Camera를 움직이는 대신 World 전체에 Camera Transform의 역변환을 적용하는 것과 같다.

```text
View Position = View Matrix × World Position
```

예를 들어 Camera가 오른쪽으로 이동했을 때 화면에서는 오브젝트가 왼쪽으로 움직인 것처럼 보인다.

View Matrix는 Camera의 이동과 회전에 대한 반대 변환을 Scene에 적용하여 Camera 기준 좌표를 만든다.

---

## View Space가 필요한 이유

Projection은 Camera가 바라보는 기준에서 이루어진다.

오브젝트가 World의 어느 방향에 놓였는지보다 Camera 앞에서 얼마나 옆에 있고, 얼마나 위에 있으며, 얼마나 멀리 있는지가 중요하다.

```text
World Space 질문
오브젝트는 Scene의 어디에 있는가?

View Space 질문
오브젝트는 Camera를 기준으로 어디에 있는가?
```

Camera를 기준으로 좌표를 통일하면 Perspective와 Orthographic Projection을 일관된 방식으로 적용할 수 있다.

Lighting이나 후처리에서도 Camera 기준의 방향과 깊이가 필요할 때 View Space가 사용될 수 있다.

---

## Clip Space란?

View Space의 Position에 Projection Matrix를 적용하면 Clip Space Position을 얻는다.

```text
Clip Position = Projection Matrix × View Position
```

Local Space부터 한 번에 표현하면 다음과 같다.

```text
Clip Position
= Projection Matrix × View Matrix × Model Matrix × Local Position
```

Clip Space는 Camera의 시야 범위 안팎을 판정하고 Perspective Divide를 준비하기 위한 공간이다.

Clip Position은 일반적으로 `(x, y, z, w)`의 네 성분을 가진 동차 좌표로 표현된다.

```text
Clip Position = (x, y, z, w)
```

여기서 `w`는 원근 투영에서 중요한 역할을 한다.

아직 `w`로 나누기 전이므로 Clip Space를 NDC와 같은 공간으로 보면 안 된다.

---

## 왜 Clip이라는 이름을 사용할까?

Camera가 볼 수 있는 영역은 제한되어 있다.

Camera 뒤에 있거나 시야의 좌우와 위아래 범위를 벗어난 Geometry를 최종 화면에 그대로 그릴 필요는 없다.

Near Plane보다 가깝거나 Far Plane보다 먼 Geometry도 Camera 설정에 따라 보이는 범위 밖에 있다.

```text
Camera Frustum

Near Plane
↓
화면에 보일 수 있는 공간
↓
Far Plane
```

Clip Space에서는 Position의 각 성분과 `w`의 관계를 이용하여 시야 영역에 포함되는지 판정할 수 있다.

Triangle 전체가 영역 밖이면 제거할 수 있고, 일부만 걸쳐 있다면 경계에서 잘라 새로운 Geometry를 만들 수 있다.

이 과정을 Clipping이라고 한다.

```text
Triangle 전체가 내부
→ 유지

Triangle 전체가 외부
→ 제거

Triangle 일부가 경계와 교차
→ 경계에 맞게 자름
```

Graphics API에 따라 Clip Space의 깊이 범위와 방향에는 차이가 있을 수 있다.

Unity Shader에서는 플랫폼별 규칙을 직접 가정하기보다 Render Pipeline이 제공하는 Matrix와 변환 함수를 사용하는 것이 안전하다.

---

## NDC란?

NDC는 **Normalized Device Coordinates**의 약자다.

Clip Position의 `x`, `y`, `z`를 `w`로 나누는 Perspective Divide 이후의 좌표다.

```text
NDC.x = Clip.x / Clip.w
NDC.y = Clip.y / Clip.w
NDC.z = Clip.z / Clip.w
```

Perspective Projection에서는 Camera에서 멀어질수록 `w`와의 관계로 인해 화면에서 더 작게 보이는 결과가 만들어진다.

```text
가까운 오브젝트
→ 화면에서 크게 보임

먼 오브젝트
→ 화면에서 작게 보임
```

NDC는 화면 해상도와 직접적인 Pixel 좌표를 사용하지 않는 정규화된 공간이다.

따라서 1920×1080 화면과 2560×1440 화면에서도 같은 투영 결과를 각 Viewport 크기에 맞게 변환할 수 있다.

NDC의 정확한 축과 깊이 범위는 Graphics API 규칙을 고려해야 한다.

모든 플랫폼에서 깊이가 무조건 같은 범위라고 가정하면 Shader가 특정 API에서만 올바르게 동작할 수 있다.

---

## Screen Space란?

Screen Space는 최종 화면 또는 Render Target의 위치를 기준으로 하는 공간이다.

NDC 좌표는 Viewport Transform을 거쳐 화면 영역에 대응된다.

```text
NDC
↓ Viewport Transform
Screen Space
↓
Render Target의 위치
```

화면 해상도가 1920×1080이라면 Screen Position을 Pixel 단위에 가까운 좌표로 다룰 수 있다.

```text
화면 왼쪽 아래 부근
(0, 0)

화면 오른쪽 위 부근
(1920, 1080)
```

다만 C#의 Screen 좌표, Shader의 Render Target 좌표, Texture UV는 플랫폼과 API에 따라 Y축 방향 등의 차이를 고려해야 할 수 있다.

Unity가 제공하는 변환 함수와 매크로는 이런 차이를 처리하는 데 도움이 된다.

Screen Space는 다음과 같은 기능에서 자주 사용된다.

```text
UI 위치 계산
마우스 Picking
화면 기반 이펙트
Depth Texture Sampling
Post Processing
Screen Space Shadow와 Reflection
```

---

## Viewport Space와 Screen Space

Unity C# API에서는 Viewport Space도 자주 사용한다.

Viewport 좌표의 X와 Y는 일반적으로 Camera 화면 영역을 0부터 1까지 정규화하여 표현한다.

```text
왼쪽 아래 = (0, 0)
중앙      = (0.5, 0.5)
오른쪽 위 = (1, 1)
```

Screen Space는 해상도의 영향을 받지만 Viewport Space는 정규화된 값이므로 서로 다른 해상도에서도 화면의 상대적인 위치를 표현하기 쉽다.

```csharp
Vector3 viewportCenter = new Vector3(0.5f, 0.5f, distance);
Vector3 worldPoint = camera.ViewportToWorldPoint(viewportCenter);
```

`ViewportToWorldPoint`의 Z 값은 Camera로부터의 World 단위 거리로 사용된다.

2D 화면 위치 하나만으로는 3D World의 한 점을 유일하게 결정할 수 없기 때문에 깊이 또는 거리에 대한 정보가 함께 필요하다.

---

## 한 화면 좌표에 여러 World Position이 대응할 수 있다

Camera에서 화면의 한 Pixel을 향해 선을 뻗으면 그 선 위에는 여러 World Position이 존재할 수 있다.

```text
Camera
  ●
   ＼
    ● 가까운 위치
     ＼
      ● 먼 위치
       ＼
        화면의 같은 지점
```

이 위치들은 깊이는 다르지만 같은 화면 위치에 투영될 수 있다.

그래서 `ScreenToWorldPoint`를 사용할 때도 Camera로부터의 Z 거리를 지정해야 한다.

마우스로 3D 오브젝트를 선택할 때는 화면 좌표를 바로 하나의 World Position으로 바꾸기보다 Camera에서 Ray를 만들고 Scene과의 교차를 검사하는 방식이 자주 사용된다.

```text
Mouse Screen Position
↓
Camera Ray 생성
↓
Physics Raycast
↓
충돌한 World Position
```

Screen Space와 World Space 사이의 변환이 단순한 일대일 관계가 아니라는 점이 중요하다.

---

## Unity URP Shader에서 좌표 변환

Unity 6의 URP Shader에서는 `Core.hlsl`의 변환 함수를 사용할 수 있다.

```hlsl
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
```

Object Space의 Vertex Position을 Clip Space로 변환하는 기본 코드는 다음과 같다.

```hlsl
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

변수 이름의 접미사는 값이 속한 공간을 나타내는 용도로 자주 사용된다.

```text
OS = Object Space
WS = World Space
VS = View Space
CS = Clip Space
NDC = Normalized Device Coordinates
```

이름에 공간을 표시하면 서로 다른 좌표를 실수로 섞는 문제를 줄일 수 있다.

---

## 여러 공간의 Position이 필요할 때

URP의 `GetVertexPositionInputs`는 Object Space Position을 받아 여러 좌표 공간의 Position을 계산한 구조체를 반환한다.

```hlsl
VertexPositionInputs positionInputs =
    GetVertexPositionInputs(input.positionOS.xyz);

float3 positionWS = positionInputs.positionWS;
float3 positionVS = positionInputs.positionVS;
float4 positionCS = positionInputs.positionCS;
float4 positionNDC = positionInputs.positionNDC;
```

각 공간은 서로 다른 계산에 사용될 수 있다.

```text
positionWS
World의 Light나 Camera 위치와 비교

positionVS
Camera 기준 깊이와 방향 계산

positionCS
Rasterization을 위한 Vertex 출력

positionNDC
정규화된 화면 위치와 관련된 계산
```

필요한 모든 값을 항상 계산하는 것이 좋은 것은 아니다.

Shader Stage 사이로 전달하는 데이터와 연산도 비용이 될 수 있으므로 실제 효과에 필요한 공간만 사용하는 것이 좋다.

---

## 좌표 공간을 섞으면 어떤 문제가 생길까?

좌표 공간과 관련된 버그는 값의 자료형이 모두 `float3` 또는 `Vector3`이기 때문에 발견하기 어려울 수 있다.

다음 계산은 문법적으로는 가능하다.

```hlsl
float3 direction = lightPositionWS - positionOS.xyz;
```

하지만 `lightPositionWS`는 World Space이고 `positionOS`는 Object Space이므로 의미가 없는 계산이다.

두 값을 같은 공간으로 맞춰야 한다.

```hlsl
float3 positionWS = TransformObjectToWorld(positionOS.xyz);
float3 directionWS = lightPositionWS - positionWS;
```

좌표 공간을 잘못 섞으면 다음과 같은 문제가 나타날 수 있다.

```text
오브젝트가 이동하면 Lighting이 달라짐
Camera를 회전하면 효과 방향이 틀어짐
Scale에 따라 Normal이 비정상적으로 보임
화면 효과가 해상도나 플랫폼에 따라 뒤집힘
```

변수 이름에 공간을 명시하고 변환 경계를 분명히 하는 습관이 중요하다.

---

## 모든 계산을 World Space에서 하면 안 될까?

World Space는 여러 오브젝트를 같은 기준에서 비교하기 편하기 때문에 많은 게임 로직과 Lighting 계산에 사용된다.

하지만 모든 계산에 항상 가장 적합한 공간은 아니다.

```text
오브젝트 자체 형태와 변형
→ Local Space가 편리

오브젝트 사이의 위치 관계
→ World Space가 편리

Camera 기준 방향과 깊이
→ View Space가 편리

Camera 시야 판정과 투영
→ Clip Space가 필요

화면 기반 Texture와 후처리
→ Screen Space가 편리
```

좌표 공간을 선택하는 것은 계산하려는 문제의 기준을 선택하는 일이다.

필요할 때 적절한 공간으로 변환하면 계산식이 단순해지고 의미도 분명해진다.

---

## 렌더링 파이프라인에서 좌표 공간의 위치

Vertex 하나가 화면에 도달하는 흐름을 다시 정리하면 다음과 같다.

```text
Mesh Vertex
Local Position
↓ Model Matrix

World Position
Scene 공통 기준
↓ View Matrix

View Position
Camera 기준
↓ Projection Matrix

Clip Position
Clipping과 투영을 위한 동차 좌표
↓ Perspective Divide

NDC Position
정규화된 Device 좌표
↓ Viewport Transform

Screen Position
Render Target 위치
↓ Rasterization

Fragment
```

이 모든 공간이 Mesh에 별도로 저장되는 것은 아니다.

기본 Vertex Position을 Matrix와 변환 함수를 이용해 각 단계에 필요한 공간으로 바꾸는 것이다.

---

## 좌표 변환도 비용이 될까?

Vertex Shader는 렌더링되는 Vertex마다 좌표 변환을 수행한다.

```text
Vertex 수
×
Model / View / Projection 관련 연산
```

Skinned Mesh라면 Bone Matrix를 이용한 변형도 좌표 변환 전에 추가될 수 있다.

하지만 좌표계가 여러 개라는 이유로 모든 가능한 공간을 항상 계산하는 것은 아니다.

Render Pipeline과 Shader는 필요한 결과를 결합된 Matrix로 계산하거나, 실제 효과에 필요한 중간 공간만 구할 수 있다.

예를 들어 Object Space에서 Clip Space로 바로 변환하는 함수는 개념적으로 Model, View, Projection 변환을 연결한다.

```hlsl
output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
```

최적화 관점에서는 좌표 공간의 수 자체보다 다음을 확인하는 것이 중요하다.

```text
불필요한 공간 변환을 반복하는가?
Fragment마다 계산할 필요가 없는 값을 계산하는가?
Shader Stage 사이에 불필요한 데이터를 전달하는가?
정확도에 필요한 Precision을 사용하는가?
```

다만 기본 좌표 변환을 임의로 줄이는 것보다 먼저 GPU Profiler와 Shader 분석 도구로 병목을 확인해야 한다.

---

## 정리

좌표는 숫자만으로 의미가 정해지지 않으며 원점과 축을 포함한 좌표 공간이 함께 필요하다.

렌더링에서 좌표 공간을 여러 개 사용하는 이유는 오브젝트 배치, Scene의 공통 관계, Camera 관찰, 투영, 화면 출력을 서로 알맞은 기준으로 나누어 처리하기 위해서다.

Local Space는 오브젝트 자신의 원점과 축을 기준으로 하며 Mesh의 Vertex를 특정 Scene 위치와 분리해 재사용할 수 있게 한다.

World Space는 Scene의 모든 오브젝트가 공유하는 기준으로 서로 다른 오브젝트의 위치 관계를 계산하기 좋다.

View Space는 Camera를 기준으로 World를 다시 표현하여 Camera 관점의 방향과 깊이를 다룰 수 있게 한다.

Clip Space는 Projection이 적용된 동차 좌표 공간이며 Camera 시야 영역의 Clipping과 Perspective Divide에 사용된다.

NDC는 Clip Position을 `w`로 나눈 정규화된 좌표이고, Viewport Transform을 거쳐 Screen Space에 대응된다.

Graphics API에 따라 Clip Space의 깊이 범위와 화면 좌표 규칙에 차이가 있을 수 있으므로 Unity와 URP가 제공하는 Matrix, 함수, 매크로를 사용하는 것이 안전하다.

Position, Direction, Normal은 모두 벡터 형태로 표현될 수 있지만 변환의 의미가 다르다.

서로 다른 공간의 값을 그대로 계산하면 결과가 잘못되므로 변수 이름에 `OS`, `WS`, `VS`, `CS` 같은 접미사를 사용하여 공간을 명확히 구분하는 것이 좋다.

좌표 공간의 흐름을 이해하면 다음 단계인 Model, View, Projection Matrix가 각각 어떤 기준을 어떤 공간으로 바꾸는지 자연스럽게 연결할 수 있다.

