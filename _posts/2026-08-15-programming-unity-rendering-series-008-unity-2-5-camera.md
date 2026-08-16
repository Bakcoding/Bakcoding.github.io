---
title: "[Unity 렌더링] 2-5. 카메라는 실제로 무엇을 하는가?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - Camera
  - Frustum
  - Projection
permalink: /programming/unity-2-5-camera/
toc: true
toc_sticky: true
date: 2026-08-15
last_modified_at: 2026-08-15
---

Unity Scene에 3D 오브젝트가 존재한다고 해서 자동으로 게임 화면이 만들어지는 것은 아니다.

어느 위치에서 어떤 방향으로 Scene을 바라볼지, 어느 범위까지 볼지, 어떤 방식으로 3D 공간을 2D 화면에 투영할지를 정해야 한다.

이 기준을 제공하는 것이 Camera다.

Camera를 현실의 카메라처럼 Scene을 촬영하는 오브젝트라고 생각할 수 있다.

하지만 렌더링 내부에서는 실제 사진을 찍는 장치라기보다 **World를 바라보는 기준과 투영 규칙, 렌더링 범위와 출력 대상을 제공하는 구성 요소**에 가깝다.

```text
Camera Transform
어디에서 어느 방향을 보는가?

Projection 설정
어떤 방식으로 화면에 투영하는가?

Frustum과 Culling 설정
어느 범위를 렌더링 후보로 볼 것인가?

Render Target 설정
결과를 어디에 기록할 것인가?
```

Camera의 역할을 이해하면 View Matrix, Projection Matrix, Frustum Culling, Depth, Render Texture가 하나의 흐름으로 연결된다.

---

## Camera는 Scene 안의 실제 물체일까?

Unity의 Camera는 GameObject에 붙는 Component다.

Camera GameObject에는 Transform이 있으므로 Position과 Rotation을 가진다.

```text
Camera GameObject
├─ Transform
│  ├─ Position
│  ├─ Rotation
│  └─ Scale
└─ Camera Component
   ├─ Projection
   ├─ Clipping Planes
   ├─ Culling Mask
   └─ Output
```

하지만 Camera 자체가 Scene 안에서 Mesh로 렌더링되는 물체는 아니다.

Editor의 Scene View에서 보이는 Camera Icon과 Frustum 선은 편집을 돕는 Gizmo다.

Game View에 Camera 모양이 그대로 나타나는 것은 아니다.

Camera Component는 해당 위치와 방향을 기준으로 렌더링 과정을 구성한다.

---

## Camera가 없으면 무엇이 달라질까?

Mesh는 Local Space의 Vertex와 Index를 가지고 있다.

Transform을 통해 World Position도 계산할 수 있다.

하지만 World Position만으로는 화면의 어디에 그릴지 결정할 수 없다.

```text
World Position
(10, 2, 5)

질문
어느 방향에서 바라보는가?
화면에 얼마나 크게 보이는가?
Camera 앞에 있는가 뒤에 있는가?
화면 범위 안에 있는가?
```

같은 World Position도 Camera의 위치와 회전에 따라 화면 중앙, 가장자리 또는 화면 밖에 나타날 수 있다.

Camera는 World의 절대 위치를 관찰자의 기준으로 바꾸고, 그 결과를 2D 화면에 투영할 규칙을 제공한다.

---

## Camera Transform은 관찰 기준을 만든다

Camera Transform의 Position은 관찰 위치를 나타낸다.

Rotation은 Camera가 바라보는 방향과 화면의 위쪽 방향을 결정한다.

```text
Position
어디에서 보는가?

Forward
어느 방향을 보는가?

Up
화면의 위쪽은 어느 방향인가?
```

Camera가 이동하면 World의 오브젝트 데이터가 실제로 반대 방향으로 이동하는 것은 아니다.

대신 같은 World Position을 새로운 Camera 기준으로 변환한 View Position이 달라진다.

```text
World Position은 그대로
↓
Camera Transform 변경
↓
View Matrix 변경
↓
화면 위치 변경
```

이 때문에 Camera 이동은 Scene 전체를 반대 방향으로 움직여 보는 것과 같은 결과를 만든다.

---

## View Matrix를 만든다

Camera의 첫 번째 핵심 역할은 World Space를 Camera 기준의 View Space로 변환할 기준을 제공하는 것이다.

이 변환에 사용하는 Matrix가 View Matrix다.

```text
View Position = View Matrix × World Position
```

Camera Transform은 Camera Local Space를 World Space로 배치한다.

View Matrix는 반대 방향으로 World Space를 Camera Space로 바꾼다.

따라서 개념적으로 Camera Transform의 역변환과 연결된다.

```text
Camera Transform
Camera Local → World

View Matrix
World → Camera View
```

Unity의 `Camera.worldToCameraMatrix`는 World Space에서 Camera Space로 변환하는 Matrix를 나타낸다.

```csharp
Matrix4x4 viewMatrix = camera.worldToCameraMatrix;
```

일반적인 Camera에서는 Transform을 바탕으로 Unity가 이 Matrix를 갱신한다.

직접 값을 설정할 수도 있지만, 그 경우 Camera 렌더링이 Transform을 자동으로 따르지 않으므로 특수한 렌더링 목적이 아니라면 주의가 필요하다.

---

## Unity Transform의 Forward와 Camera Space의 축

Unity GameObject의 `transform.forward`는 Local의 양의 Z 방향을 World 방향으로 변환한 값이다.

하지만 Shader와 Graphics API의 Camera Space Convention을 직접 다룰 때는 축 방향이 다르게 표현될 수 있다.

Unity 문서에서 `worldToCameraMatrix`의 Camera Space는 OpenGL 계열 Convention처럼 앞쪽이 음의 Z 방향인 형태로 설명된다.

```text
Unity Transform 관점
Forward = Local +Z

View Matrix 이후 Camera Space
Convention에 따라 앞쪽 깊이 부호가 다를 수 있음
```

따라서 Camera 앞에 있는지 확인하기 위해 View Space Z의 부호를 무조건 하나로 가정하는 코드는 Render Pipeline과 API의 Convention을 함께 확인해야 한다.

일반적인 Unity 기능에서는 제공되는 Camera와 Shader Helper API를 사용하는 것이 안전하다.

---

## Projection을 결정한다

View Space는 Camera를 기준으로 오브젝트 위치를 표현하지만 아직 최종 화면 위치는 아니다.

Camera는 3D 공간을 2D 화면으로 투영하는 규칙도 제공한다.

Unity Camera의 기본적인 Projection 방식은 두 가지다.

```text
Perspective Projection
원근감이 있음

Orthographic Projection
거리에 따른 크기 변화가 없음
```

Camera Component의 `orthographic` 값에 따라 두 방식을 선택할 수 있다.

```csharp
camera.orthographic = false; // Perspective
camera.orthographic = true;  // Orthographic
```

이 설정과 FOV, Aspect Ratio, Near, Far 등의 값을 바탕으로 Projection Matrix가 구성된다.

---

## Perspective Camera

Perspective Camera는 현실에서 보는 것과 비슷한 원근감을 만든다.

같은 크기의 오브젝트라도 Camera와 가까우면 크게 보이고 멀면 작게 보인다.

```text
가까운 Cube
화면에서 크게 보임

먼 Cube
화면에서 작게 보임
```

Perspective Projection에서는 Camera 위치에서 바깥으로 뻗어 나가는 시야 영역이 만들어진다.

Camera에서 멀어질수록 같은 화면 범위가 더 넓은 World 영역을 포함한다.

```text
       /──────── Far Plane
      /
Camera
      ＼
       ＼──────── Far Plane
```

실제로는 Camera 바로 앞이 Near Plane에서 잘리므로 완전한 Pyramid가 아니라 잘린 Pyramid 형태가 된다.

이 형태를 Perspective Frustum이라고 한다.

---

## Field of View란?

Field of View는 Camera가 얼마나 넓은 각도를 보는지를 의미한다.

보통 FOV라고 줄여 부른다.

Unity Camera의 `fieldOfView`는 일반적으로 수직 FOV를 Degree 단위로 나타낸다.

```csharp
camera.fieldOfView = 60f;
```

FOV가 작으면 좁은 범위를 확대해서 보는 느낌이 난다.

FOV가 크면 더 넓은 범위가 화면에 들어오지만 화면 가장자리의 원근 왜곡이 강해질 수 있다.

```text
작은 FOV
좁은 시야
오브젝트가 상대적으로 크게 보임

큰 FOV
넓은 시야
오브젝트가 상대적으로 작게 보임
```

FOV는 Camera가 볼 수 있는 거리 자체를 의미하지 않는다.

가시 거리의 앞뒤 범위는 Near와 Far Clip Plane이 결정한다.

---

## Aspect Ratio란?

Aspect Ratio는 화면 또는 Viewport의 가로 길이를 세로 길이로 나눈 비율이다.

```text
Aspect Ratio = Width / Height

1920 / 1080 ≈ 1.777
```

같은 수직 FOV라도 Aspect Ratio가 넓으면 수평으로 더 넓은 영역이 보일 수 있다.

Projection Matrix는 Aspect Ratio를 반영하여 화면이 가로나 세로로 찌그러지지 않도록 한다.

```csharp
float aspect = camera.aspect;
```

Game View 크기, Render Texture 크기, Camera의 Viewport 설정에 따라 실제 출력 비율이 달라질 수 있다.

해상도 변경을 직접 처리하는 Custom Projection에서는 현재 Render Target의 비율을 올바르게 반영해야 한다.

---

## Orthographic Camera

Orthographic Camera는 거리에 따른 크기 변화를 만들지 않는다.

같은 크기의 두 오브젝트는 Camera와의 거리가 달라도 화면에서 같은 크기로 투영된다.

```text
가까운 Cube  □
먼 Cube      □

투영 크기가 같음
```

Perspective Frustum이 잘린 Pyramid 형태라면 Orthographic Camera의 View Volume은 직육면체 형태다.

```text
Near Plane  ┌────────┐
            │        │
            │        │
Far Plane   └────────┘
```

Orthographic은 원근감이 필요하지 않은 2D 게임, 일부 전략 게임, 미니맵, 기술 도면과 같은 화면에 사용할 수 있다.

하지만 Orthographic이라고 해서 Depth가 사라지는 것은 아니다.

오브젝트는 여전히 Camera와의 깊이를 가지며 Near와 Far Plane, Depth Test, Sorting에 영향을 받을 수 있다.

---

## Orthographic Size

Orthographic Camera에서는 FOV 대신 `orthographicSize`가 화면에 보이는 범위를 결정한다.

Unity에서 Orthographic Size는 Camera View의 세로 크기 절반을 나타낸다.

```text
orthographicSize = 5

세로 View 크기
약 10 World Unit
```

수평 범위는 Orthographic Size와 Aspect Ratio를 함께 반영한다.

```text
세로 절반 = orthographicSize
가로 절반 = orthographicSize × aspect
```

```csharp
camera.orthographic = true;
camera.orthographicSize = 5f;
```

Camera를 앞뒤로 이동해도 오브젝트의 투영 크기는 달라지지 않지만, Near와 Far 범위를 벗어나거나 다른 Geometry와의 Depth 관계는 바뀔 수 있다.

---

## Projection Matrix를 만든다

Camera의 Projection 설정은 View Space Position을 Clip Space Position으로 변환하는 Projection Matrix에 반영된다.

```text
Clip Position
= Projection Matrix × View Position
```

Perspective Camera라면 FOV, Aspect Ratio, Near, Far가 Matrix 구성에 영향을 준다.

Orthographic Camera라면 Orthographic Size, Aspect Ratio, Near, Far가 투영 범위를 결정한다.

Unity에서는 다음 값으로 Projection Matrix를 확인할 수 있다.

```csharp
Matrix4x4 projection = camera.projectionMatrix;
```

이 Matrix를 직접 설정하면 Unity가 `fieldOfView`를 기준으로 자동 갱신하지 않는다.

Custom Projection이 정말 필요한 경우에만 Matrix Convention과 플랫폼 차이를 이해한 상태에서 사용하는 것이 좋다.

Shader에 사용할 GPU Projection Matrix는 플랫폼에 따라 조정될 수 있으므로 C#의 `projectionMatrix` 값을 무조건 그대로 Shader 규칙과 같다고 가정하면 안 된다.

---

## View-Projection Matrix

World Position을 Clip Position으로 변환하려면 View Matrix와 Projection Matrix를 연결한다.

```text
Clip Position
= Projection Matrix × View Matrix × World Position
```

두 Matrix를 결합한 것을 View-Projection Matrix라고 부른다.

오브젝트의 Model Matrix까지 포함하면 Local Vertex를 Clip Space로 보내는 MVP 변환이 된다.

```text
Local Position
↓ Model
World Position
↓ View
View Position
↓ Projection
Clip Position
```

Camera는 이 흐름에서 View와 Projection 기준을 제공한다.

---

## Frustum이란?

Frustum은 Camera가 볼 수 있는 공간의 형태를 나타낸다.

Perspective Camera에서는 Near Plane에서 잘린 Pyramid 형태다.

Orthographic Camera에서는 직육면체 형태다.

Perspective Frustum은 여섯 개의 Plane으로 경계를 만들 수 있다.

```text
Left Plane
Right Plane
Top Plane
Bottom Plane
Near Plane
Far Plane
```

이 경계 안에 있는 Geometry가 Camera 화면에 나타날 가능성이 있다.

Frustum은 실제로 렌더링된 이미지가 아니라 **Camera가 볼 수 있는 후보 영역을 정의하는 공간**이다.

---

## Near Clip Plane

Near Clip Plane은 Camera가 렌더링할 수 있는 가장 가까운 경계다.

Near보다 Camera에 가까운 Geometry는 정상적인 View Volume 밖에 있다.

```csharp
camera.nearClipPlane = 0.3f;
```

Near 값을 너무 크게 설정하면 Camera 가까이 있는 오브젝트가 잘려 보일 수 있다.

1인칭 게임에서 Camera가 벽이나 캐릭터 Mesh에 가까워질 때 표면 일부가 사라지는 현상과 연결될 수 있다.

반대로 Near 값을 필요 이상으로 매우 작게 설정하면 Perspective Depth Buffer의 정밀도 분배에 불리할 수 있다.

Depth 정밀도는 Near와 Far의 비율과 Projection 방식, Depth Buffer Format, Reversed-Z 사용 여부 등 여러 요소에 영향을 받는다.

따라서 Near는 무조건 작게 두기보다 게임에서 필요한 가장 가까운 렌더링 거리를 기준으로 설정하는 것이 좋다.

---

## Far Clip Plane

Far Clip Plane은 Camera가 렌더링할 수 있는 가장 먼 경계다.

```csharp
camera.farClipPlane = 1000f;
```

Far보다 멀리 있는 Geometry는 Camera의 일반적인 View Frustum 밖에 있다.

Far를 줄이면 Camera가 고려해야 하는 먼 영역을 제한할 수 있다.

하지만 Far 값 하나를 줄였다고 성능이 항상 크게 향상되는 것은 아니다.

```text
실제로 먼 거리에 Renderer가 존재하는가?
Frustum Culling으로 제거되는가?
LOD와 Shadow Distance는 어떻게 설정되어 있는가?
Occlusion Culling을 사용하는가?
```

같은 Scene 구조를 함께 봐야 한다.

Far와 Near의 범위는 Depth 정밀도에도 영향을 줄 수 있다.

---

## Camera는 보이는 오브젝트를 어떻게 고를까?

Camera가 Frustum 안의 모든 Pixel을 먼저 그려 본 뒤 화면 밖인지 확인하는 것은 비효율적이다.

Unity는 렌더링 전에 Renderer의 Bounds 등을 이용하여 Camera의 렌더링 후보를 줄일 수 있다.

대표적인 과정이 Frustum Culling이다.

```text
Scene Renderer 목록
↓ Layer와 활성 상태 확인
↓ Frustum과 Bounds 검사
↓ 렌더링 후보 구성
↓ Render Command 준비
```

Renderer가 Frustum 밖에 있다고 판단되면 해당 Camera를 위한 일반적인 Draw 후보에서 제외할 수 있다.

이렇게 하면 CPU의 렌더링 준비와 GPU가 처리할 Geometry를 줄일 수 있다.

정확한 Culling 과정과 단위는 Render Pipeline 및 Renderer 종류에 따라 달라질 수 있다.

---

## Frustum Culling과 Clipping은 다르다

Frustum Culling과 GPU의 Clipping은 모두 Camera 영역 밖의 Geometry와 관련되지만 같은 작업은 아니다.

Frustum Culling은 보통 Renderer의 Bounds 같은 비교적 큰 단위를 이용해 Draw 자체를 준비할지 판단한다.

Clipping은 Vertex Processing 이후 Clip Space에서 Primitive가 View Volume 경계와 교차하는지를 처리한다.

```text
Frustum Culling
Renderer 단위 후보 제거
주로 Draw 이전

Clipping
Primitive 경계 처리
Vertex Shader 이후
```

큰 오브젝트의 Bounds가 Frustum과 조금이라도 겹치면 Renderer 전체가 Culling을 통과할 수 있다.

그 안의 Triangle 일부가 화면 밖에 있다면 GPU의 Clipping과 Rasterization 단계에서 추가로 처리된다.

---

## Bounds가 중요한 이유

Unity Renderer는 공간에서 차지하는 범위를 Bounds로 나타낼 수 있다.

Frustum Culling은 모든 Triangle을 CPU에서 하나씩 검사하기보다 Bounds를 이용해 빠르게 후보를 판단할 수 있다.

```text
Renderer Bounds 전체가 Frustum 밖
→ Renderer 제거 가능

Bounds가 Frustum과 교차
→ 렌더링 후보 유지
```

Bounds가 실제 Mesh보다 지나치게 크면 화면에 보이지 않는 Renderer도 Culling을 통과할 가능성이 높아진다.

반대로 Bounds가 실제로 변형되는 Mesh보다 작으면 화면에 보여야 할 부분이 잘못 Culling될 수 있다.

Skinned Mesh, Particle, Procedural Geometry에서는 동적으로 변하는 Bounds가 특히 중요할 수 있다.

---

## Culling Mask

Camera는 `cullingMask`를 이용하여 어떤 Layer를 렌더링할지 선택할 수 있다.

```text
Camera Culling Mask
├─ Player Layer 포함
├─ Environment Layer 포함
└─ Debug Layer 제외
```

```csharp
camera.cullingMask = LayerMask.GetMask("Player", "Environment");
```

Culling Mask에서 제외된 Layer의 Renderer는 해당 Camera 화면에 그려지지 않는다.

미니맵 Camera에서 미니맵용 Layer만 표시하거나, 특정 Camera에서 UI 또는 효과용 오브젝트를 분리할 때 사용할 수 있다.

Culling Mask는 Physics Layer Collision 설정과 같은 기능이 아니다.

이름에 Culling이 들어가지만 Camera 렌더링 대상을 Layer 기준으로 선택하는 설정이다.

---

## Occlusion Culling과의 차이

Frustum 안에 있다고 해서 실제 화면에 보인다는 의미는 아니다.

벽 뒤에 가려진 오브젝트는 Frustum 안에 있어도 최종 Pixel에 나타나지 않을 수 있다.

```text
Camera
↓
Wall
↓
Enemy

Enemy는 Frustum 안
하지만 Wall에 가려짐
```

이런 가림 관계를 이용하여 보이지 않는 Renderer를 줄이는 방식이 Occlusion Culling이다.

```text
Frustum Culling
Camera 시야 영역 밖 제거

Occlusion Culling
다른 Geometry 뒤에 가려진 대상 제거
```

Occlusion Culling 자체에도 데이터 준비, 메모리와 Runtime 판단 비용이 있다.

모든 Scene에서 무조건 이득이라고 단정할 수 없으며 Scene 구조와 플랫폼을 기준으로 측정해야 한다.

---

## Camera는 Render Target을 정한다

Camera의 결과는 최종적으로 Color Buffer와 Depth Buffer 같은 Render Target에 기록된다.

일반적인 Game Camera는 화면으로 이어지는 Back Buffer 또는 Pipeline이 준비한 중간 Render Target에 렌더링한다.

Camera의 `targetTexture`를 설정하면 결과를 Render Texture에 출력할 수 있다.

```csharp
camera.targetTexture = renderTexture;
```

```text
Camera Rendering
↓
Render Texture
↓
Monitor UI, Portal, CCTV, Minimap 등에 사용
```

URP에서는 Render Scale, Intermediate Texture, Post Processing, Camera Stack 같은 설정에 따라 실제 중간 Render Target 흐름이 더 복잡할 수 있다.

Camera가 항상 디스플레이 Back Buffer에 직접 한 번만 그린다고 단순화하면 안 된다.

---

## Camera는 배경도 처리한다

새 Frame을 렌더링하기 전에 Camera가 사용할 Color와 Depth Target을 어떤 값으로 시작할지 정해야 한다.

Pipeline과 Camera 설정에 따라 배경 Color로 Clear하거나 Skybox를 그리거나 이전 결과를 활용할 수 있다.

```text
Render Target 준비
↓
Color / Depth Clear
↓
Skybox 또는 Background
↓
Opaque Geometry
↓
Transparent Geometry
↓
Post Processing
```

URP에서는 Camera Type과 Camera Stack, Render Type 등에 따라 Clear와 합성 방식이 달라질 수 있다.

배경이 보인다는 것은 단순히 아무것도 그리지 않은 상태가 아니라 Render Target을 초기화하거나 Skybox를 렌더링한 결과일 수 있다.

---

## Depth Buffer와 Camera

Camera의 Near와 Far, Projection Matrix는 Geometry의 깊이가 Depth Buffer 값으로 변환되는 방식과 연결된다.

Depth Buffer는 같은 화면 위치에 여러 Fragment가 있을 때 어느 표면이 앞에 있는지 판단하는 데 사용된다.

```text
Camera에 가까운 Fragment
Camera에서 먼 Fragment
↓ Depth Test
앞에 있는 결과 선택
```

Perspective Projection의 깊이는 World 거리와 단순한 선형 관계로 저장되지 않을 수 있다.

Depth 정밀도는 Near Plane 부근과 Far Plane 부근에 균일하게 배분되지 않으며, Reversed-Z 같은 기법과 Graphics API 규칙에 따라서도 달라진다.

Camera Clipping Plane 설정이 Z-Fighting과 Depth 정밀도에 영향을 줄 수 있는 이유다.

---

## Camera가 실제로 Draw Call을 실행할까?

Camera Component가 직접 GPU에게 모든 Draw Call을 한 줄씩 보내는 오브젝트라고 이해하는 것은 지나치게 단순하다.

Camera는 렌더링을 구성하는 기준과 설정을 제공한다.

Render Pipeline은 Camera를 기준으로 Culling을 수행하고 Renderer를 정렬하며 Pass와 Render Target을 구성한 뒤 Command를 기록하고 제출한다.

```text
Camera 설정
↓
Render Pipeline
↓ Culling
Renderer 후보
↓ Sorting / Pass 구성
Render Command
↓
GPU Rendering
```

Built-in Render Pipeline, URP, HDRP는 Camera를 처리하는 세부 구조가 다를 수 있다.

Scriptable Render Pipeline에서는 Camera별 렌더링 과정을 코드로 구성할 수 있다.

---

## Camera가 여러 개라면?

Scene에는 여러 Camera가 존재할 수 있다.

각 Camera는 서로 다른 Transform, Projection, Culling Mask, Viewport와 Render Target을 가질 수 있다.

```text
Main Camera
게임 화면 렌더링

Minimap Camera
위에서 본 Scene을 Render Texture로 렌더링

UI Camera
특정 UI Layer 렌더링

Portal Camera
다른 위치의 Scene을 Texture로 렌더링
```

Camera가 하나 늘어나면 단순히 최종 이미지만 하나 더 생기는 것이 아니다.

Camera마다 Culling, Command 준비, Geometry Rendering과 후처리 등이 반복될 수 있다.

```text
Camera A
Culling + Rendering

Camera B
Culling + Rendering
```

따라서 여러 Camera는 CPU와 GPU 비용을 모두 증가시킬 수 있다.

실제 비용은 각 Camera가 그리는 Layer, 해상도, Pass, Render Target과 Pipeline 설정에 따라 달라진다.

---

## URP Camera Stack

URP에서는 Base Camera와 Overlay Camera를 이용한 Camera Stack을 구성할 수 있다.

Base Camera가 기본 Scene을 렌더링하고 Overlay Camera 결과를 그 위에 합성하는 방식으로 사용할 수 있다.

```text
Base Camera
World 렌더링
↓
Overlay Camera
Weapon 또는 UI Layer 렌더링
↓
최종 출력
```

Camera Stack은 화면 구성을 분리하기 편리하지만 Camera별 렌더링 범위와 Clear, Post Processing, Depth 처리 비용을 확인해야 한다.

Pipeline 버전과 Renderer 설정에 따라 지원 범위와 동작이 달라질 수 있으므로 Unity 6 URP의 현재 문서를 기준으로 사용해야 한다.

---

## Physical Camera

Unity Camera는 FOV를 직접 설정하는 방식 외에도 현실의 Camera와 유사한 Physical Camera 속성을 사용할 수 있다.

```text
Focal Length
Sensor Size
Lens Shift
Gate Fit
```

Focal Length와 Sensor Size의 관계로 FOV를 계산할 수 있고 Lens Shift를 이용해 Frustum 중심을 이동할 수 있다.

Architectural Visualization, Cinematic Camera, 실제 촬영 Lens와의 Matching 같은 작업에 유용할 수 있다.

Physical Camera도 최종적으로는 View Matrix와 Projection Matrix를 구성하여 Vertex를 Clip Space로 변환한다는 점은 같다.

입력 방식이 현실 Camera의 Parameter에 가깝다는 차이가 있다.

---

## Custom Projection

`Camera.projectionMatrix`를 직접 설정하면 중심이 치우친 Projection이나 Oblique Projection 같은 특수한 Frustum을 만들 수 있다.

```csharp
camera.projectionMatrix = customProjection;
```

Portal, Mirror, Water Reflection, 비대칭 Display 같은 기능에서 Custom Projection이 필요할 수 있다.

하지만 직접 Matrix를 설정하면 Unity가 FOV 변경을 기준으로 Projection을 자동 갱신하지 않는다.

Near와 Far 설정도 Custom Matrix와 일관되게 관리해야 한다.

또한 Shader에 전달되는 GPU Projection Matrix는 플랫폼과 Render Target 상태에 따라 조정될 수 있다.

특수한 이유가 없다면 표준 Camera 설정과 Render Pipeline Helper를 사용하는 편이 안전하다.

---

## XR에서는 Camera가 어떻게 달라질까?

VR과 XR에서는 왼쪽 눈과 오른쪽 눈이 서로 다른 View Matrix를 가진다.

두 눈의 위치가 조금 다르기 때문에 같은 World Position도 각 눈에서 서로 다른 화면 위치로 투영된다.

```text
Left Eye
View Matrix L + Projection Matrix L

Right Eye
View Matrix R + Projection Matrix R
```

Headset의 Lens와 Display 구조에 맞춘 비대칭 Projection이 사용될 수도 있다.

따라서 Custom Shader에서 하나의 Camera Position이나 Projection만 있다고 가정하면 XR에서 잘못된 결과가 나타날 수 있다.

Unity의 XR 호환 Shader 함수와 Stereo Macro를 사용해야 하는 이유다.

두 눈을 렌더링해야 하므로 일반 화면보다 Geometry와 Pixel 처리량이 증가할 수 있으며 Single Pass 방식 등으로 중복 비용을 줄일 수 있다.

---

## Camera의 화면 좌표 변환 API

Unity Camera는 World, Viewport, Screen Space 사이를 변환하는 API를 제공한다.

```csharp
Vector3 screen = camera.WorldToScreenPoint(worldPosition);
Vector3 viewport = camera.WorldToViewportPoint(worldPosition);

Vector3 worldFromScreen = camera.ScreenToWorldPoint(screenPosition);
Vector3 worldFromViewport = camera.ViewportToWorldPoint(viewportPosition);
```

Screen Space는 Pixel 좌표를 사용하고 Viewport Space는 화면 범위를 0부터 1까지 정규화한다.

3D World로 되돌릴 때는 화면의 X와 Y만으로 깊이를 알 수 없으므로 Camera로부터의 Z 거리 정보가 필요하다.

마우스로 오브젝트를 선택할 때는 Screen Position에서 Ray를 만들고 Physics Raycast로 교차점을 찾는 방식이 일반적이다.

---

## Camera Frustum을 코드에서 확인하기

Unity의 `GeometryUtility.CalculateFrustumPlanes`를 사용하면 Camera Frustum을 구성하는 여섯 Plane을 얻을 수 있다.

```csharp
Plane[] planes = GeometryUtility.CalculateFrustumPlanes(camera);
```

Bounds가 이 Plane으로 구성된 영역과 겹치는지 검사할 수도 있다.

```csharp
bool visible = GeometryUtility.TestPlanesAABB(
    planes,
    renderer.bounds
);
```

이 결과는 Renderer가 최종 Pixel에 실제로 보인다는 보장은 아니다.

Frustum과 Bounds가 겹친다는 의미에 가깝고 다른 오브젝트에 가려질 수도 있다.

또한 직접 모든 Renderer를 매 Frame 검사하는 코드는 별도 CPU 비용을 만들 수 있으므로 필요한 시스템에서만 사용해야 한다.

---

## Camera와 렌더링 순서

Camera가 Renderer 후보를 얻은 뒤에도 어떤 순서로 그릴지 결정해야 한다.

Opaque Geometry는 Depth 효율과 State 변경을 고려한 순서로 정렬될 수 있다.

Transparent Geometry는 Blending 결과 때문에 일반적으로 Camera와의 거리 및 Render Queue를 고려한 순서가 중요하다.

```text
Camera
↓
Renderer Culling
↓
Render Queue 분류
↓
Opaque Sorting
↓
Transparent Sorting
```

따라서 Camera 위치가 달라지면 같은 Scene에서도 Transparent Sorting 순서가 달라질 수 있다.

Camera는 단순히 Projection만 제공하는 것이 아니라 Sorting의 관찰 기준에도 영향을 준다.

---

## Camera 설정과 성능

Camera 설정은 CPU와 GPU 작업량에 영향을 줄 수 있다.

```text
Far Clip Plane과 Frustum
렌더링 후보 범위에 영향

Culling Mask
Camera가 고려하는 Layer에 영향

Viewport와 Render Target 해상도
처리할 Pixel 수에 영향

HDR / MSAA / Post Processing
Render Target와 Shader 비용에 영향

Camera 수
Culling과 Rendering 반복 횟수에 영향
```

하지만 특정 Camera 설정 하나만 낮추면 항상 빨라진다고 단정할 수 없다.

예를 들어 GPU가 Fragment 처리에 병목이라면 Render Scale이나 후처리 설정의 영향이 클 수 있다.

CPU가 많은 Renderer와 Draw Command 준비에 병목이라면 Culling 범위와 Camera 수가 중요할 수 있다.

Profiler, Frame Debugger와 GPU Profiler를 이용하여 Camera별 Pass와 비용을 확인해야 한다.

---

## Camera가 Frame을 만드는 전체 흐름

Camera를 중심으로 하나의 렌더링 흐름을 단순화하면 다음과 같다.

```text
Camera Transform과 설정 확인
↓
View Matrix 구성
↓
Projection Matrix 구성
↓
Culling Parameter 준비
↓
Layer / Frustum / Occlusion Culling
↓
Renderer 분류와 Sorting
↓
Render Pass와 Command 구성
↓
Vertex를 Clip Space로 변환
↓
Rasterization과 Fragment 처리
↓
Color / Depth Render Target 기록
↓
Post Processing과 Camera 합성
↓
화면 또는 Render Texture 출력
```

실제 URP 내부에는 Shadow, Depth Prepass, Opaque Texture, Transparent, Post Processing 등 더 많은 단계가 들어갈 수 있다.

Camera는 이 전체 과정의 관찰 기준과 출력 설정을 제공한다.

---

## 정리

Unity Camera는 현실의 Camera처럼 Scene을 촬영하는 물체라기보다 렌더링의 관찰 기준과 투영 방식, 가시 범위와 출력 대상을 제공하는 Component다.

Camera Transform은 관찰 위치와 방향을 결정하고 World Position을 Camera 기준으로 변환하는 View Matrix와 연결된다.

Projection 설정은 View Position을 Clip Position으로 변환하는 Projection Matrix를 결정한다.

Perspective Camera는 거리에 따라 오브젝트 크기가 달라지는 원근감을 만들며 FOV, Aspect Ratio, Near, Far가 Frustum을 구성한다.

Orthographic Camera는 거리에 따른 투영 크기 변화를 만들지 않으며 Orthographic Size와 Aspect Ratio가 화면 범위를 결정한다.

Frustum은 Camera 화면에 나타날 가능성이 있는 공간의 경계다.

Frustum Culling은 Renderer Bounds 등을 이용해 Draw 후보를 줄이고, GPU Clipping은 Vertex 처리 이후 Primitive가 Clip Space 경계와 교차하는 부분을 처리한다.

Near와 Far Clip Plane은 Camera가 처리할 깊이 범위뿐 아니라 Projection과 Depth 정밀도에도 연결된다.

Culling Mask는 Camera가 렌더링할 Layer를 선택하며 Occlusion Culling은 Frustum 안에 있지만 다른 Geometry에 가려진 대상을 줄이는 별도의 과정이다.

Camera 결과는 화면뿐 아니라 Render Texture에 기록될 수 있고 여러 Camera나 URP Camera Stack을 사용하면 Culling과 Rendering 작업이 반복될 수 있다.

Camera는 직접 모든 Draw Call을 실행하는 단순한 오브젝트가 아니다.

Render Pipeline이 Camera의 설정을 기준으로 Culling, Sorting, Pass 구성과 Command 제출을 수행한다.

Camera의 역할을 이해하면 다음으로 Depth Buffer가 왜 필요하고, Camera에서 같은 화면 위치에 겹쳐 보이는 여러 표면 중 어떤 결과를 남기는지 연결할 수 있다.
