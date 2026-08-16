---
title: "[Unity 렌더링] 11-2. Frustum Culling은 어떻게 동작할까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - Culling
  - Frustum
  - Bounds
permalink: /programming/unity-11-2-how-frustum-culling-works/
toc: true
toc_sticky: true
date: 2026-08-16
last_modified_at: 2026-08-16
---

Frustum Culling은 Camera가 볼 수 있는 공간 밖의 Renderer를 Draw 대상에서 제외하는 과정이다.

```text
                    Far Plane
               ┌────────────────┐
             ／                  ＼
Camera ● ───<      Visible Area    |
             ＼                  ／
               └────────────────┘
                   Near Plane
```

Unity는 일반적으로 Mesh의 모든 Triangle을 Camera와 비교하지 않고 Renderer Bounds가 View Frustum과 겹치는지 먼저 판정한다.

Bounds가 Frustum의 여섯 Plane 중 하나라도 완전히 바깥쪽에 있으면 해당 Renderer를 현재 Camera의 Rendering 후보에서 제외할 수 있다.

---

## Camera가 볼 수 있는 부피

3D Camera는 Position만으로 Visibility를 결정하지 않는다.

다음 설정이 Camera가 볼 수 있는 공간을 만든다.

```text
Camera Visibility Volume
├─ Position
├─ Rotation
├─ Projection Type
├─ Field of View 또는 Orthographic Size
├─ Aspect Ratio
├─ Near Clip Plane
└─ Far Clip Plane
```

이 공간 부피가 View Frustum이다.

Renderer가 Frustum 밖에 있으면 최종 화면의 Pixel로 투영될 수 없으므로 Draw할 필요가 없다.

---

## Perspective Frustum

Perspective Camera에서는 멀리 갈수록 보이는 범위가 넓어진다.

```text
Top View

                Far Width
          ┌──────────────────┐
         ／                    ＼
Camera ●                          |
         ＼                    ／
          └──────────────────┘
              Near Width
```

형태는 잘린 사각뿔인 Frustum에 가깝다.

가까운 Object는 크게, 먼 Object는 작게 보이는 Perspective Projection과 대응한다.

Vertical FOV, Aspect Ratio와 Near·Far Distance가 Frustum 모서리를 결정한다.

---

## Orthographic Frustum

Orthographic Camera에서는 거리에 따라 투영 크기가 변하지 않는다.

```text
Top View

Camera Direction →

┌────────────────────────────┐
│       Visible Volume       │
└────────────────────────────┘
 Near                      Far
```

Frustum은 사각기둥 형태에 가깝다.

Orthographic Size와 Aspect Ratio가 가로·세로 범위를 결정하고 Near·Far Plane이 깊이를 제한한다.

2D Game, Strategy Camera와 일부 UI·Mini Map Camera에서 자주 사용한다.

---

## Frustum의 여섯 Plane

Frustum은 여섯 개의 경계 Plane으로 표현할 수 있다.

```text
Frustum Planes
├─ Left
├─ Right
├─ Bottom
├─ Top
├─ Near
└─ Far
```

```text
Front View

       Top
   ┌──────────┐
Left          Right
   └──────────┘
      Bottom
```

각 Plane의 안쪽 Half-space가 모두 겹치는 영역이 Camera가 볼 수 있는 공간이다.

---

## Plane 표현

3D Plane은 Normal Vector와 Plane 위 Distance로 표현할 수 있다.

```text
Plane Equation
n · p + d = 0
```

`n`은 Plane Normal, `p`는 검사할 Position, `d`는 원점에서의 Offset에 해당한다.

Point를 Equation에 넣은 부호로 Plane의 어느 쪽에 있는지 판단할 수 있다.

```text
n · p + d > 0  → Normal 방향 쪽
n · p + d = 0  → Plane 위
n · p + d < 0  → 반대쪽
```

Unity의 Plane 방향과 API Convention을 기준으로 안쪽·바깥쪽을 해석해야 한다.

---

## Point와 Frustum 판정

Point 하나가 Frustum 안에 있으려면 여섯 Plane의 내부 조건을 모두 만족해야 한다.

```text
for each Frustum Plane
    Point가 바깥쪽인가?
        Yes → Frustum 밖

모든 Plane 통과
→ Frustum 안
```

한 Plane의 바깥에만 있어도 Frustum 전체 밖이다.

하지만 Renderer는 크기가 있으므로 Pivot Point 하나만 검사하면 정확하지 않다.

Pivot은 밖에 있어도 Mesh 일부가 화면 안에 들어올 수 있다.

---

## Pivot만 검사하면 생기는 문제

긴 Wall의 Pivot이 왼쪽 끝에 있다고 가정한다.

```text
Frustum
┌────────────────┐
│       Wall ───────────── Pivot ●
└────────────────┘
```

Pivot은 Frustum 밖이지만 Wall 일부는 화면 안에 보인다.

Pivot Position만 보고 Renderer를 제거하면 보이는 Geometry가 사라지는 False Negative가 생긴다.

따라서 Object의 공간 범위를 나타내는 Bounds를 검사한다.

---

## Renderer Bounds

`Renderer.bounds`는 Renderer Geometry를 World Space에서 감싸는 Axis-aligned Bounding Box다.

```text
        AABB
   ┌────────────┐
   │   Mesh     │
   │    /\      │
   │   /__\     │
   └────────────┘
```

일반적으로 다음 값으로 표현한다.

```text
Bounds
├─ center
├─ extents
├─ min
├─ max
└─ size
```

`extents`는 Size의 절반이며 Center에서 각 축 방향 끝까지의 거리다.

---

## AABB란 무엇인가?

AABB는 World Axis에 정렬된 Bounding Box다.

```text
Axis-aligned
X축과 평행한 Edge
Y축과 평행한 Edge
Z축과 평행한 Edge
```

Object가 회전해도 World Bounds Box는 World Axis에 맞춰 Mesh 전체를 감싼다.

```text
회전한 Mesh       World AABB
      ◇          ┌────────┐
                 │   ◇    │
                 └────────┘
```

Plane과 빠르게 교차 판정할 수 있지만 회전한 긴 Object에서는 빈 공간이 많이 포함될 수 있다.

---

## Plane과 AABB 판정

Frustum Plane 하나와 AABB를 비교할 때 Box가 Plane 바깥에 완전히 있는지 확인한다.

```text
Plane │
      │  Frustum Inside
      │     ┌─────┐
      │     │ AABB│
      │     └─────┘
```

Box에서 Plane Normal 방향으로 가장 멀리 있는 Support Point를 선택할 수 있다.

그 Point까지 바깥에 있다면 Box 전체가 해당 Plane 밖이다.

여섯 Plane 중 하나에서 완전히 Outside이면 Renderer를 Cull한다.

---

## Center와 Extents를 이용한 판정

AABB Center와 Extents를 이용하면 Plane에 대한 Projection Radius를 구할 수 있다.

```text
r
= |nx| × ex
+ |ny| × ey
+ |nz| × ez
```

`n`은 Plane Normal이고 `e`는 Bounds Extents다.

Center에서 Plane까지 Signed Distance를 `s`라고 하면 다음처럼 분류할 수 있다.

```text
s < -r
→ AABB 전체가 Plane 밖

s > r
→ AABB 전체가 Plane 안쪽

-r ≤ s ≤ r
→ Plane과 교차
```

정확한 부호는 Plane Normal Convention에 따라 달라질 수 있지만 중심 거리와 Box 반경을 비교한다는 원리는 같다.

---

## 세 가지 판정 결과

Bounds와 Frustum 관계는 세 상태로 생각할 수 있다.

```text
Outside
→ 완전히 Frustum 밖
→ Cull 가능

Intersecting
→ Frustum 경계와 교차
→ Draw 후보 유지

Inside
→ 완전히 Frustum 안
→ Draw 후보 유지
```

일반 Renderer Culling에서는 `Intersecting`과 `Inside`를 모두 Visible 후보로 처리한다.

경계에서 조금이라도 보일 가능성이 있으면 잘못 제거하지 않기 위한 보수적인 판정이다.

---

## Plane 하나만 Outside여도 충분하다

Frustum은 여섯 Half-space의 교집합이다.

```text
Inside Frustum
= Left 안
∩ Right 안
∩ Top 안
∩ Bottom 안
∩ Near 안
∩ Far 안
```

AABB가 Right Plane 바깥에 완전히 있다면 다른 다섯 Plane을 만족해도 화면에 들어올 수 없다.

```text
if Outside any plane
    Culled
else
    Potentially Visible
```

빠른 Reject가 가능하므로 Object가 많은 Scene에서 효율적이다.

---

## 완전히 안에 있는지까지 구분할 필요

단순 Visibility에서는 Outside인지 아닌지만 알면 된다.

```text
Outside → Cull
Not Outside → Keep
```

공간 계층 구조에서는 Parent Bounds가 완전히 Frustum 안이면 Child마다 Plane Test 일부를 생략하는 최적화를 적용할 수 있다.

```text
Parent Node fully inside
→ 모든 Child도 Frustum 안
→ Child Frustum Test 생략 가능
```

Unity 내부 구현 세부는 Version과 Rendering Architecture에 따라 달라질 수 있지만 Hierarchical Culling의 일반적인 아이디어다.

---

## View Matrix

View Matrix는 World Space를 Camera 기준 공간으로 변환한다.

```text
World Position
→ View Matrix
→ Camera Space Position
```

Camera Space에서 Camera는 원점에 있고 정해진 방향을 바라보는 형태로 생각할 수 있다.

Camera Transform이 움직이거나 회전하면 View Matrix가 바뀌고 Frustum의 World Space Plane도 갱신된다.

---

## Projection Matrix

Projection Matrix는 Camera Space Position을 Clip Space로 변환한다.

```text
Camera Space
→ Projection Matrix
→ Clip Space
```

Perspective와 Orthographic Camera는 서로 다른 Projection Matrix를 사용한다.

Field of View, Aspect Ratio, Near와 Far Plane 변경도 Projection Matrix에 반영된다.

```text
Clip Matrix
= Projection Matrix × View Matrix
```

Frustum Plane은 이 결합 Matrix에서 추출할 수 있다.

---

## Clip Space 판정

GPU는 Vertex를 Clip Space로 변환한 뒤 View Volume 밖 Primitive를 Clip할 수 있다.

API Convention에 따라 Clip 범위는 차이가 있지만 개념적으로 다음 조건을 사용한다.

```text
-w ≤ x ≤ w
-w ≤ y ≤ w
z 범위는 Graphics API Convention에 따름
```

GPU Clip은 Triangle 단위에서 정확하지만 Draw와 Vertex Shader 이후에 일어난다.

CPU의 Bounds Frustum Culling은 Draw 자체를 더 일찍 제외하기 위한 Coarse Test다.

---

## CPU Culling과 GPU Clipping

두 단계는 대체 관계가 아니라 서로 보완한다.

```text
CPU Bounds Frustum Culling
→ Object 전체가 밖이면 Draw 제외

GPU Primitive Clipping
→ Draw 안의 개별 Triangle이 경계와 교차할 때 처리
```

Bounds가 Frustum에 걸친 큰 Mesh는 Draw되지만 내부 Triangle 대부분이 화면 밖일 수 있다.

GPU가 최종 Clip을 처리하더라도 큰 Mesh의 Vertex 비용은 남는다.

---

## 왜 Mesh Triangle을 모두 검사하지 않을까?

Renderer마다 모든 Triangle을 CPU에서 Camera Plane과 비교하면 Culling 자체의 비용이 매우 커진다.

```text
100,000 Renderers
× Renderer당 10,000 Triangles
× 6 Planes
```

Bounds는 Mesh 전체를 감싸는 단순한 Box 하나로 빠르게 Reject할 수 있다.

```text
Coarse Bounds Test
→ 저렴하고 보수적
→ 일부 False Positive 허용
```

보이는 Geometry를 잘못 제거하지 않으면서 대부분의 명백한 Offscreen Object를 빠르게 제외한다.

---

## False Positive

Bounds는 Frustum과 겹치지만 실제 Mesh Geometry는 화면 밖일 수 있다.

```text
Frustum Edge
│
│ ┌──────────── Large Bounds ────────────┐
│ │                         Mesh ●       │
│ └──────────────────────────────────────┘
```

Frustum Culling은 Renderer를 Visible 후보로 유지하지만 실제 Triangle는 GPU에서 모두 Clip될 수 있다.

화면 오류는 없지만 불필요한 Draw와 Vertex 비용이 생긴다.

큰 Bounds, 긴 회전 Mesh와 결합 Mesh에서 발생하기 쉽다.

---

## False Negative를 피한다

Bounds가 실제 Geometry보다 작으면 보이는 Vertex가 Frustum 안에 있어도 Bounds 전체가 밖으로 판정될 수 있다.

```text
Frustum
│  Deformed Vertex ●
│
└────── Bounds 밖 판정
```

Object가 갑자기 사라지는 Culling Bug가 발생한다.

Unity는 기본적으로 보수적인 Bounds를 사용하지만 Custom Bounds와 GPU Vertex Deformation에서는 개발자가 정확한 범위를 제공해야 한다.

성능을 위해 Bounds를 무조건 작게 줄이면 안 된다.

---

## 회전과 World AABB

가늘고 긴 Object가 45도로 회전하면 World AABB의 빈 공간이 커진다.

```text
┌────────────────┐
│      /         │
│     / Mesh     │
│    /           │
└────────────────┘
```

Object Oriented Bounding Box보다 판정은 단순하지만 Tightness가 낮다.

회전하는 Blade, Door와 긴 Prop가 Frustum 경계에 있을 때 실제보다 오래 Visible로 남을 수 있다.

대부분의 일반 Renderer에서는 빠른 AABB Test의 이점이 더 크다.

---

## 큰 결합 Mesh

멀리 떨어진 Building을 하나의 Mesh로 합치면 Bounds가 도시 전체를 감싼다.

```text
Combined Bounds
┌─────────────────────────────┐
│ Building A        Building B│
│             Building C      │
└─────────────────────────────┘
```

Building A만 Frustum에 걸려도 B와 C Geometry까지 같은 Draw에 포함될 수 있다.

Draw Call은 줄지만 Frustum Culling Granularity가 거칠어진다.

공간적으로 함께 보이는 Cluster 단위로 결합해야 한다.

---

## Renderer를 너무 잘게 나눌 때

Mesh를 작은 Chunk로 나누면 Culling 정밀도는 높아진다.

```text
Large Mesh 1개
→ Draw 적음, Coarse Culling

Small Chunks 100개
→ Fine Culling, Renderer·Draw 관리 증가
```

Renderer 수, Bounds Test, Draw Call과 Transform 관리 비용이 늘 수 있다.

Camera에서 보이는 평균 Chunk 수와 가려지는 비율을 기준으로 적절한 공간 단위를 찾는다.

---

## Skinned Mesh Bounds

Skinned Mesh는 Bone Animation으로 Vertex가 매 Frame 움직인다.

```text
Import Pose Bounds
→ Runtime Animation
→ Arm·Weapon이 Bounds 밖으로 이동 가능
```

Bounds가 Animation 범위를 충분히 포함하지 않으면 Character 일부 또는 전체가 Camera 경계에서 사라질 수 있다.

`Update When Offscreen`은 Offscreen에서도 Skinning과 Bounds Update를 유지할 수 있지만 비용이 증가한다.

Animation Clip, Ragdoll과 Runtime Bone Modification을 포함해 Bounds를 검증한다.

---

## Particle System Bounds

Particle는 Velocity, Lifetime과 Size에 따라 넓게 이동한다.

```text
Emitter ●
  └────── Particle Travel Range ──────>
```

Renderer Bounds가 너무 작으면 살아 있는 Particle가 갑자기 사라진다.

Bounds가 너무 크면 Effect가 화면 밖이어도 System Renderer가 오래 Visible 후보로 남는다.

Particle System Renderer의 Bounds와 Culling Mode를 Effect의 실제 범위에 맞춘다.

---

## Trail과 Line Renderer Bounds

Trail Renderer와 Line Renderer는 여러 Point를 연결해 긴 Geometry를 만든다.

```text
Object ●────────────── Trail
```

현재 Object Transform이 Frustum 밖이어도 Trail 일부가 화면 안에 남아 있을 수 있다.

Pivot Distance만으로 Custom Culling하면 보이는 Trail을 잘못 제거할 수 있다.

Renderer Bounds 전체를 기준으로 판정하고 Trail Lifetime 동안 범위가 어떻게 변하는지 확인한다.

---

## GPU Vertex Deformation

Shader에서 Wind, Wave와 Displacement로 Vertex를 움직여도 CPU Bounds는 Shader 결과를 자동으로 알지 못할 수 있다.

```hlsl
positionWS.y += sin(time + positionWS.x) * amplitude;
```

Base Mesh Bounds가 Frustum 밖이지만 변형된 Vertex가 화면 안으로 들어오면 잘못 Culled될 수 있다.

Maximum Displacement를 포함하도록 Bounds를 확장한다.

너무 큰 Margin은 Culling 효율을 낮추므로 Shader Parameter의 실제 상한을 사용한다.

---

## Camera Aspect Ratio

Aspect Ratio는 Frustum의 가로 범위를 결정한다.

```text
Aspect
= Width / Height
```

같은 Vertical FOV에서도 Ultrawide 화면은 좌우 Frustum이 넓어진다.

```text
16:9  → Visible Width A
21:9  → Visible Width B > A
```

Game View Aspect와 실제 Device Aspect가 다르면 Scene View에서 예상한 Culling 경계와 달라질 수 있다.

---

## Field of View

Perspective Camera의 Vertical FOV가 커지면 더 넓은 공간이 Frustum에 들어온다.

```text
FOV 40° → 좁은 Frustum
FOV 90° → 넓은 Frustum
```

Visible Renderer 수와 Screen Coverage가 함께 달라질 수 있다.

Zoom Effect, Sprint FOV와 Cutscene Camera가 FOV를 변경하면 Culling 결과도 매 Frame 변한다.

성능 Benchmark에서는 FOV를 고정한다.

---

## Near Clip Plane

Near Plane은 Camera 앞에서 Rendering이 시작되는 거리다.

```text
Camera ● │ Near │ Visible Space
```

Near보다 Camera에 가까운 Geometry는 Clip된다.

Near를 너무 크게 두면 Weapon과 가까운 Object가 잘리고 너무 작게 두면 Depth Precision이 불리해질 수 있다.

Near Plane을 통과하는 큰 Bounds는 Renderer 전체를 Visible 후보로 유지할 수 있다.

---

## Far Clip Plane

Far Plane은 Camera가 Rendering하는 최대 깊이다.

```text
Camera ● ───────── Visible ───────── │ Far │ Culled
```

Far Distance를 줄이면 멀리 있는 Renderer를 Frustum 밖으로 제외할 수 있다.

하지만 Sky, Terrain, Shadow, Fog와 Gameplay Visibility가 영향을 받을 수 있다.

Layer Cull Distance와 LOD를 이용하면 Object 종류별로 더 세밀한 거리 정책을 적용할 수 있다.

---

## Orthographic Size

Orthographic Size는 Camera View의 세로 절반 크기를 나타낸다.

```text
Vertical View Size
≈ Orthographic Size × 2
```

Size가 커지면 더 넓은 World 영역이 Frustum 안에 들어오고 Visible Renderer 수가 증가한다.

Strategy Game에서 Zoom Out할 때 수많은 Unit과 Tile이 한 번에 Visible이 될 수 있다.

LOD, Chunk Culling과 Batch 전략을 Zoom Level별로 조정한다.

---

## Oblique Frustum

Portal, Water Reflection과 Custom Projection은 Near Plane을 기울인 Oblique Projection을 사용할 수 있다.

```text
일반 Near Plane  │
Oblique Plane    /
```

Frustum Plane이 일반 Camera 형태와 달라지므로 Position·FOV만으로 만든 Custom 판정이 실제 Projection과 어긋날 수 있다.

Camera의 현재 Culling Matrix와 Projection을 기준으로 Plane을 계산해야 한다.

---

## Jittered Projection

TAA는 Frame마다 Projection에 작은 Jitter를 적용할 수 있다.

```text
Frame N   Projection Offset A
Frame N+1 Projection Offset B
```

Culling Frustum을 너무 정확히 Jittered 경계에 맞추면 경계 Object가 Frame마다 나타났다 사라질 수 있다.

Pipeline은 안정적인 Non-jittered Culling Matrix나 Margin을 사용할 수 있다.

Custom Culling을 구현할 때 Rendering Projection과 Culling Projection의 차이를 확인한다.

---

## Camera Culling Mask가 먼저 후보를 줄인다

Camera Culling Mask에서 제외된 Layer는 Frustum 안에 있어도 해당 Camera가 그리지 않는다.

```text
Layer Test
→ 제외 Layer면 Reject
→ 포함 Layer면 Bounds Frustum Test
```

실제 내부 순서는 구현에 따라 다를 수 있지만 Layer Filtering과 Spatial Visibility는 서로 다른 조건이다.

Mini Map과 Reflection Camera에 불필요한 Layer를 넣지 않으면 Frustum Test와 Rendering 후보를 줄일 수 있다.

---

## Frustum Culling은 가림을 모른다

Renderer가 여섯 Plane 안에 있으면 앞에 Wall이 있어도 Frustum Test는 통과한다.

```text
Camera
  │
  ├─ Wall
  └─ Character  ← Frustum 안, 하지만 가려짐
```

Frustum Culling은 Camera 방향과 범위만 판단하고 Object 사이의 Occlusion 관계는 판단하지 않는다.

Wall 뒤 Object를 제거하려면 Occlusion Culling, Portal·Room Visibility 또는 GPU Depth 기반 Culling이 필요하다.

다음 글에서 Occlusion Culling을 다룬다.

---

## Frustum Culling은 Camera마다 수행된다

각 Camera는 Position, Projection과 Culling Mask가 다르다.

```text
Main Camera Frustum
Reflection Camera Frustum
Mini Map Orthographic Frustum
Shadow Camera Volume
```

Main Camera에서 Culled인 Renderer가 Reflection Camera에는 보일 수 있다.

Camera가 많으면 Visibility 판정과 Rendering 후보 생성도 반복된다.

필요 없는 Camera를 끄고 Camera별 Layer와 Far Distance를 제한한다.

---

## Shadow Culling Volume

Shadow Caster Visibility는 Main Camera Frustum과 Light의 Shadow Projection을 함께 고려한다.

Object 자체가 화면 밖이어도 Shadow가 화면 안에 들어올 수 있다.

```text
Caster 밖
   █
    ╲ Shadow
     ╲  Camera 안 Ground
```

Main Camera Frustum만 이용한 Custom Renderer Culling으로 Object를 완전히 끄면 필요한 Shadow도 사라질 수 있다.

Color Pass와 Shadow Pass의 Visibility 요구를 분리한다.

---

## Unity의 자동 Frustum Culling

일반적인 `MeshRenderer`, `SkinnedMeshRenderer`와 Particle Renderer는 Camera Rendering 과정에서 Bounds 기반 Culling을 적용받는다.

개발자가 모든 Renderer에 직접 Plane Test Script를 붙일 필요는 없다.

```text
Unity Camera Render
→ Layer Filtering
→ Culling
→ Visible Renderer Set
→ Sorting·Drawing
```

Custom Script는 기본 Culling을 대체하기보다 Gameplay Visibility, 대규모 Data 또는 특수 Rendering 요구가 있을 때 사용한다.

---

## GeometryUtility.CalculateFrustumPlanes

Unity는 Camera Frustum Plane을 계산하는 API를 제공한다.

```csharp
Plane[] planes = GeometryUtility.CalculateFrustumPlanes(camera);
```

반환된 여섯 Plane을 Bounds나 Custom Volume Test에 사용할 수 있다.

매 Frame 많은 Object에 호출할 때 Array Allocation과 반복 계산을 피하려면 재사용 가능한 Buffer를 지원하는 Overload와 구조를 확인한다.

Unity Version의 API Signature를 기준으로 구현한다.

---

## GeometryUtility.TestPlanesAABB

`TestPlanesAABB`는 Plane 배열과 AABB가 겹치는지 검사한다.

```csharp
bool visible = GeometryUtility.TestPlanesAABB(
    planes,
    renderer.bounds
);
```

반환값이 `false`면 Bounds가 Plane Set 밖에 있어 Frustum과 겹치지 않는 것으로 볼 수 있다.

`true`는 Bounds가 완전히 안에 있다는 뜻이 아니라 Frustum과 겹치거나 포함된다는 뜻이다.

```text
true
→ Inside 또는 Intersecting
```

---

## 간단한 진단 Component

특정 Camera 기준으로 Renderer Bounds가 Frustum과 겹치는지 표시할 수 있다.

```csharp
using UnityEngine;

public sealed class FrustumVisibilityProbe : MonoBehaviour
{
    [SerializeField] private Camera targetCamera;
    [SerializeField] private Renderer targetRenderer;

    private readonly Plane[] planes = new Plane[6];

    private void LateUpdate()
    {
        if (targetCamera == null || targetRenderer == null)
            return;

        GeometryUtility.CalculateFrustumPlanes(
            targetCamera,
            planes
        );

        bool intersects = GeometryUtility.TestPlanesAABB(
            planes,
            targetRenderer.bounds
        );

        Debug.Log($"Frustum intersects: {intersects}");
    }
}
```

매 Frame `Debug.Log`는 큰 CPU·Console 비용을 만들 수 있으므로 실제 진단에서는 상태가 바뀔 때만 기록하거나 Gizmo로 표시한다.

---

## 상태 변화만 기록하기

Visibility 상태가 바뀔 때만 Log를 남긴다.

```csharp
private bool? previous;

private void Report(bool current)
{
    if (previous.HasValue && previous.Value == current)
        return;

    previous = current;
    Debug.Log($"Frustum state changed: {current}");
}
```

이 방식은 Camera 경계에서 Object가 Flicker하는지 확인할 때 유용하다.

API Test 결과는 특정 Camera와 Bounds의 기하학적 교차이며 실제 Unity Renderer가 모든 Pass에서 Draw됐다는 의미는 아니다.

Layer, Occlusion, LOD와 Renderer 상태가 추가로 적용된다.

---

## Gizmo로 Bounds 그리기

Renderer Bounds를 Scene View에 그리면 Culling 오류를 빠르게 찾을 수 있다.

```csharp
private void OnDrawGizmosSelected()
{
    if (targetRenderer == null)
        return;

    Bounds bounds = targetRenderer.bounds;

    Gizmos.color = Color.yellow;
    Gizmos.DrawWireCube(bounds.center, bounds.size);
}
```

Animation, Particle와 GPU Deformation 중 Bounds가 실제 Geometry를 포함하는지 확인한다.

Gizmo는 Editor Rendering이며 Player 성능에는 포함되지 않도록 Debug Code를 관리한다.

---

## Camera.CalculateFrustumCorners

Perspective Camera의 특정 거리 Plane 모서리를 계산할 수 있다.

```csharp
Vector3[] corners = new Vector3[4];

camera.CalculateFrustumCorners(
    new Rect(0f, 0f, 1f, 1f),
    camera.farClipPlane,
    Camera.MonoOrStereoscopicEye.Mono,
    corners
);
```

반환된 Corner는 Camera 기준 공간이므로 World Space로 변환해 Line을 그릴 수 있다.

```csharp
Vector3 worldCorner = camera.transform.TransformPoint(corners[i]);
```

XR과 Off-axis Projection에서는 Eye와 Projection 조건을 명확히 선택한다.

---

## Custom Plane 추출 시 주의점

View Projection Matrix에서 직접 Frustum Plane을 추출할 수 있지만 다음 차이를 처리해야 한다.

```text
Graphics API Clip-space Convention
Reversed Z
Projection Matrix 보정
Oblique Projection
TAA Jitter
Stereo Eye Matrix
Camera Culling Matrix
```

일반적인 Unity Component에서는 검증된 `GeometryUtility`와 Camera API를 먼저 사용한다.

Custom SRP나 GPU Culling에서 직접 추출할 때 Unity가 GPU에 사용하는 Projection Matrix와 Culling Matrix를 구분한다.

---

## CullingGroup API

많은 Target의 Visibility와 Distance Band를 관리할 때 `CullingGroup` API를 사용할 수 있다.

```text
CullingGroup
├─ Target Camera
├─ Bounding Spheres
├─ Visibility Events
└─ Distance Bands
```

AABB 대신 Bounding Sphere 배열을 등록하고 Camera Visibility 변화 Callback을 받을 수 있다.

AI, Crowd, Effect와 LOD Logic을 모든 Object의 `Update`에서 직접 계산하는 비용을 줄이는 데 유용할 수 있다.

Renderer의 기본 Culling과 별개의 Gameplay·System 수준 도구로 이해한다.

---

## Bounding Sphere

Sphere는 Center와 Radius로 표현한다.

```text
Bounding Sphere
├─ center
└─ radius
```

회전에 영향을 받지 않고 Plane과의 Distance 비교가 단순하다.

```text
Center to Plane Distance < -Radius
→ Sphere 전체가 Plane 밖
```

긴 Object에서는 AABB보다 빈 공간이 많아 Coarse할 수 있지만 대규모 Object의 빠른 Visibility와 Distance 판정에 적합하다.

---

## Bounding Sphere 배열 관리

`CullingGroup`은 등록한 Sphere 배열의 Index로 Event를 전달한다.

```csharp
BoundingSphere[] spheres;

spheres[i] = new BoundingSphere(
    worldPosition,
    radius
);
```

Object 생성·삭제 시 Index와 Owner Mapping을 일관되게 관리해야 한다.

매 Frame 새 배열을 만들기보다 Capacity를 재사용하고 움직인 Sphere만 갱신한다.

Dispose 시점과 Camera 변경도 명확히 처리한다.

---

## Custom Distance Check와 Frustum Check

거리만으로 Visibility를 판단하면 Camera 뒤 Object도 같은 거리에서 활성 상태로 남는다.

```text
Distance Check
→ Camera 중심 Sphere

Frustum Check
→ Camera 방향·FOV·Clip 반영
```

반대로 Frustum 안의 매우 먼 작은 Object는 Visible 후보가 된다.

```text
Visibility Policy
= Layer
+ Distance Band
+ Frustum
+ Occlusion 또는 Gameplay Rule
```

각 조건이 무엇을 제거하는지 분리한다.

---

## Renderer.isVisible과 차이

`Renderer.isVisible`은 Renderer가 어떤 Camera에서 Visible로 간주되는지를 나타낼 수 있다.

```text
isVisible = true
→ Main Camera 때문일 수 있음
→ Scene View Camera 때문일 수 있음
→ Reflection Camera 때문일 수 있음
```

특정 Camera의 Frustum Test 결과가 필요하면 Camera와 Bounds를 명시적으로 검사한다.

`isVisible`은 Occlusion, Shadow와 Camera 종류를 포함한 Engine Visibility Context의 영향을 받을 수 있어 Gameplay Line-of-sight 판정과 같지 않다.

---

## Layer Cull Distance

Camera는 Layer별 Cull Distance를 설정할 수 있다.

```text
Small Props Layer → 50m
Character Layer   → 150m
Terrain Layer     → Far Plane
```

Frustum 안이지만 거리 기준을 넘은 Object를 제외한다.

`layerCullSpherical` 설정에 따라 Camera Plane Distance 또는 구형 Distance 기준을 사용할 수 있다.

거리 Culling은 Frustum Culling을 대체하지 않고 추가 조건으로 후보를 줄인다.

---

## LOD Group과 Frustum

LOD Group은 Camera에서 보이는 상대 Screen Size에 따라 Renderer Set을 선택한다.

```text
Frustum 밖
→ 모든 LOD Draw 제외

Frustum 안
→ Screen Size 계산
→ LOD0·LOD1·LOD2 또는 Cull 선택
```

마지막 LOD를 Cull로 구성하면 Far Plane 안에서도 시각적 기여가 작은 Object를 제거할 수 있다.

Frustum, Distance와 LOD는 서로 다른 단계에서 Visible Set을 좁힌다.

---

## Occlusion Culling과 순서

개념적인 Camera Visibility 흐름은 다음처럼 볼 수 있다.

```text
Renderer Candidates
→ Layer Filtering
→ Frustum Culling
→ Occlusion Visibility
→ LOD Selection
→ Sorting·Drawing
```

정확한 내부 순서는 Unity Version, Pipeline과 Renderer 종류에 따라 다를 수 있다.

Frustum 밖 Object를 먼저 제거하면 더 비싼 Occlusion 판정 후보를 줄일 수 있다.

Frustum 안에서 가려진 Object는 Occlusion 단계가 처리한다.

---

## Hierarchical Spatial Structure

대규모 Scene은 Object를 Tree나 Cell로 묶어 공간적으로 관리할 수 있다.

```text
World Root
├─ Cell A Bounds
│  ├─ Object 1
│  └─ Object 2
├─ Cell B Bounds
└─ Cell C Bounds
```

Cell Bounds 전체가 Frustum 밖이면 내부 Object를 개별 검사하지 않아도 된다.

```text
Parent Outside
→ 모든 Child Outside
```

Octree, BVH, Grid와 Scene Chunk는 이 원리를 다양한 구조로 구현한다.

---

## 대규모 World의 Chunk Culling

Terrain Tile, Building Block과 Vegetation Cell을 공간 Chunk로 나눈다.

```text
World Grid
┌───┬───┬───┐
│ A │ B │ C │
├───┼───┼───┤
│ D │ E │ F │
└───┴───┴───┘
```

Frustum과 겹치는 Chunk만 Renderer·Instance 후보로 만든다.

Chunk가 너무 크면 불필요한 Object가 함께 남고 너무 작으면 Bounds Test와 관리 비용이 증가한다.

Camera 높이, View Distance와 Object Density를 기준으로 Chunk Size를 Profile한다.

---

## GPU Frustum Culling

대량 Instance는 Compute Shader에서 Bounds와 Plane을 병렬로 검사할 수 있다.

```text
Instance Bounds Buffer
+ Frustum Planes
→ Compute Shader
→ Visible Instance List
→ Indirect Draw
```

CPU가 Instance별 Draw Command를 만들지 않고 GPU에서 Visible List를 압축한다.

Buffer Upload, Prefix Sum·Append, Synchronization과 Indirect Args 관리가 필요하다.

Object 수가 적으면 Dispatch와 Buffer 관리 비용이 이득보다 클 수 있다.

---

## GPU Culling의 Bounds

Instance마다 Sphere 또는 AABB Data를 GPU Buffer에 저장한다.

```hlsl
struct InstanceBounds
{
    float3 center;
    float radius;
};
```

각 Thread가 여섯 Plane을 검사해 Visible 여부를 결정할 수 있다.

```text
Outside any plane
→ Reject

Otherwise
→ Append visible index
```

GPU Vertex Animation이 Bounds를 변경하면 CPU와 GPU Data의 최대 범위를 일관되게 유지해야 한다.

---

## Stereo와 XR Frustum

XR은 Left Eye와 Right Eye에 서로 다른 View·Projection Matrix를 사용할 수 있다.

```text
Left Eye Frustum
Right Eye Frustum
```

한 Eye에는 보이고 다른 Eye에는 Frustum 밖인 Object가 있을 수 있다.

두 Eye의 합집합을 감싸는 Conservative Frustum으로 한 번 Cull하거나 Eye별로 판정하는 방식은 정밀도와 비용 Trade-off가 있다.

Custom Culling에서 Mono Camera Frustum만 사용하면 한쪽 Eye에 필요한 Object를 잘못 제거할 수 있다.

---

## Camera Stack

URP Base Camera와 Overlay Camera는 Projection과 Culling Mask를 공유하거나 다르게 구성할 수 있다.

```text
Base Camera
→ World Renderer Set

Overlay Camera
→ Weapon Renderer Set
```

각 Camera Rendering에서 필요한 Visibility가 다르므로 특정 Camera의 Frustum 결과로 Renderer.enabled를 전역 변경하면 다른 Camera에 영향을 준다.

Camera별 Filtering을 사용하고 Global Renderer State 변경은 신중하게 적용한다.

---

## Scene View Camera

Editor Scene View도 별도 Camera로 Scene을 Rendering한다.

Game Camera Frustum 밖 Object가 Scene View에는 보일 수 있다.

```text
Game Camera → Culled
Scene Camera → Visible
```

`OnBecameVisible`, `OnBecameInvisible`와 `Renderer.isVisible`을 Debug할 때 Scene View 때문에 상태가 달라질 수 있다.

Player Build와 Editor 결과를 구분한다.

---

## Frustum Gizmo 확인

Camera를 선택하면 Scene View에서 Frustum Wireframe을 볼 수 있다.

```text
확인 설정
├─ Projection
├─ FOV·Orthographic Size
├─ Near·Far
├─ Aspect
└─ Camera Transform
```

Renderer Bounds Gizmo와 함께 표시해 어느 Plane에서 교차하는지 확인한다.

Game View Aspect가 Free Aspect이면 실제 Target Aspect와 맞추고 테스트한다.

---

## Frame Debugger 확인

Frustum 밖이라고 예상한 Renderer가 Draw Event에 있는지 확인한다.

```text
확인 질문
├─ 어떤 Camera Event인가?
├─ Main Color Pass인가?
├─ Shadow Pass인가?
├─ Bounds가 실제로 Frustum과 겹치는가?
├─ 다른 Submesh가 Bounds를 키우는가?
└─ Reflection·Scene View Camera 때문인가?
```

Color Pass에서는 없지만 Shadow Map Pass에만 있는 경우 Main Camera Frustum Culling 오류가 아니다.

---

## Rendering Profiler 확인

Camera FOV, Far Plane 또는 Chunk Size를 바꾸기 전후 Renderer·Batch·Triangle 통계를 비교한다.

```text
Before
Visible Batches 1500
Triangles       5.0M

After
Visible Batches 900
Triangles       2.5M
```

통계 감소가 CPU Culling 비용 증가보다 큰지 CPU Profiler에서 확인한다.

GPU Vertex·Fragment 시간이 실제로 줄었는지도 Target Device에서 측정한다.

---

## 경계 이동 Test

Camera를 천천히 회전해 Object가 Frustum 경계를 통과하는 순간을 관찰한다.

```text
Outside
→ Bounds Intersecting
→ Visible
```

Mesh가 Bounds보다 먼저 사라지거나 늦게 나타나면 Bounds가 작을 가능성이 있다.

Bounds는 남아 있지만 실제 Geometry가 오래 화면 밖에 있으면 큰 Bounds나 Combined Mesh를 의심한다.

빠른 Camera 이동에서도 Pop-in이 없는지 확인한다.

---

## 성능 Test

Frustum에 보이는 Object 수가 크게 달라지는 두 Camera 방향을 비교한다.

```text
View A
→ Open Field, 2000 Renderers

View B
→ Sky, 50 Renderers
```

CPU Render Thread, Batches, Vertices와 GPU Pass 시간을 기록한다.

Frustum Culling이 정상이어도 Sky 방향에서 Simulation 비용은 그대로일 수 있다.

Rendering과 전체 GameObject Update를 분리한다.

---

## Frustum Culling 최적화 방향

기본 Culling이 정확하게 동작하도록 Data와 공간 단위를 조정한다.

```text
1. Renderer Bounds 정확성 확인
2. GPU Deformation 최대 범위 반영
3. 큰 Combined Mesh 공간 분할
4. 과도한 Renderer 분할 완화
5. Camera FOV·Far Plane 검토
6. Layer Culling Mask·Distance 구성
7. LOD 마지막 Cull 단계 설정
8. Multi-camera별 Visibility 분리
9. 대규모 Instance는 Spatial·GPU Culling 검토
10. Target Device에서 전후 측정
```

Bounds를 공격적으로 줄여 보이는 Geometry를 제거하는 것은 최적화가 아니라 Rendering 오류다.

---

## 흔한 오해

### Frustum Culling은 Object Position만 검사한다

Pivot만 검사하면 보이는 큰 Mesh를 잘못 제거하므로 Renderer Bounds와 Frustum의 교차를 판정한다.

### Bounds가 Frustum에 걸치면 Mesh 전체가 보인다

일부만 보이거나 실제 Geometry는 모두 밖일 수 있지만 보수적으로 Draw 후보를 유지한다.

### Frustum 안의 Object는 실제 화면에 보인다

다른 Object에 가려지거나 Alpha 0, LOD와 Layer 조건으로 보이지 않을 수 있다.

### Frustum Culling이 Occlusion도 처리한다

Camera Volume 안에서 Wall 뒤에 가려진 Object는 별도 Occlusion 판정이 필요하다.

### GPU가 Triangle을 Clip하므로 CPU Culling은 필요 없다

GPU Clip 전에 Draw Submission과 Vertex Shader 비용이 발생할 수 있다.

### Bounds를 작게 만들수록 성능이 좋다

실제 Geometry를 포함하지 못하면 Camera 경계에서 Mesh가 사라진다.

### Bounds를 크게 만들면 안전하므로 문제없다

화면 밖 Geometry가 Visible 후보로 남아 Draw와 Vertex 비용이 증가할 수 있다.

### Mesh를 합치면 Frustum Culling도 빨라진다

Bounds Test 수는 줄 수 있지만 큰 Bounds 때문에 보이지 않는 Geometry까지 함께 Draw될 수 있다.

### `TestPlanesAABB`가 true이면 완전히 화면 안이다

완전 포함뿐 아니라 Frustum과 교차하는 Bounds도 true를 반환할 수 있다.

### `Renderer.isVisible`은 특정 Game Camera의 Frustum 결과다

Scene View와 다른 Camera의 Visibility도 상태에 영향을 줄 수 있다.

### Far Plane을 줄이면 모든 먼 Object 비용이 사라진다

Shadow, Reflection, Simulation과 별도 Camera 비용은 남을 수 있다.

---

## 최종 체크리스트

```text
□ Perspective와 Orthographic Frustum 차이를 구분했는가?
□ Left·Right·Top·Bottom·Near·Far Plane을 확인했는가?
□ Camera FOV·Aspect·Clip Plane이 예상 값인가?
□ Pivot이 아니라 Renderer Bounds로 판단했는가?
□ AABB의 Center·Extents와 World Space 범위를 확인했는가?
□ Bounds가 한 Plane 밖에 완전히 있을 때만 Cull하는가?
□ Intersecting Bounds를 Visible 후보로 유지하는가?
□ 큰 회전 Object의 World AABB가 과도하지 않은가?
□ Combined Mesh Bounds가 Culling 단위를 너무 키우지 않았는가?
□ Renderer를 너무 잘게 나눠 CPU·Draw 비용을 늘리지 않았는가?
□ Skinned Mesh Animation이 Bounds를 벗어나지 않는가?
□ Particle·Trail의 실제 이동 범위를 포함하는가?
□ GPU Vertex Deformation 최대 변위를 Bounds에 반영했는가?
□ Oblique·Jittered·Stereo Projection을 고려했는가?
□ Camera Culling Mask와 Layer Distance를 함께 확인했는가?
□ Frustum과 Occlusion Culling을 혼동하지 않았는가?
□ GeometryUtility 호출에서 Allocation을 관리했는가?
□ Custom Culling이 다른 Camera와 Shadow를 제거하지 않는가?
□ Scene View가 Visibility Callback에 미치는 영향을 고려했는가?
□ Frame Debugger에서 실제 Camera·Pass를 확인했는가?
□ 경계 이동과 빠른 Camera에서 Pop-in을 검사했는가?
□ CPU·GPU Profiler로 Culling 전후를 비교했는가?
```

---

## 정리

Frustum Culling은 Camera Projection이 만드는 여섯 Plane과 Renderer Bounds의 공간 관계를 검사해 화면에 들어올 수 없는 Renderer를 Draw 후보에서 제외한다.

Perspective Frustum은 멀어질수록 넓어지는 잘린 사각뿔 형태이고 Orthographic Frustum은 일정한 크기의 사각기둥 형태다.

Unity는 모든 Triangle을 CPU에서 검사하지 않고 World Space AABB를 이용한 보수적인 Plane Test로 Object 전체를 빠르게 Reject한다.

Bounds가 Plane 하나의 바깥에 완전히 있으면 Cull할 수 있지만 Frustum과 조금이라도 교차하면 실제 Mesh가 보이지 않아도 Visible 후보로 유지한다.

큰 Bounds와 Combined Mesh는 False Positive를 늘리고 작은 Bounds는 보이는 Geometry가 사라지는 False Negative를 만들 수 있어 Animation, Particle와 GPU Deformation 범위를 정확히 포함해야 한다.

Frustum Culling은 Camera Volume만 판단하므로 Frustum 안에서 Wall 뒤에 가려진 Object는 Occlusion Culling이 별도로 필요하다.

Camera Gizmo, `GeometryUtility`, Frame Debugger와 CPU·GPU Profiler를 이용해 Camera별 Bounds 판정과 실제 Draw 제외 효과를 Target Device에서 검증해야 한다.
