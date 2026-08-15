---
title: "[Unity 렌더링] 5-2. Camera는 무엇을 기준으로 오브젝트를 그릴까?"
excerpt: "Unity Rendering"
categories:
  - Programming
tags:
  - Unity
  - Rendering
  - Camera
  - FrustumCulling
  - CullingMask
permalink: /programming/unity-5-2-camera-culling/
toc: true
toc_sticky: true
date: 2026-08-15
last_modified_at: 2026-08-15
---

Scene에 GameObject가 존재한다고 해서 모든 Camera가 그 Object를 그리지는 않는다.

Camera는 Layer, Culling Mask, View Frustum과 Renderer의 Bounds 등을 이용해 현재 Camera의 Rendering 후보를 고른다.

```text
Scene의 Renderer
↓
활성 상태와 Layer 확인
↓
Camera Culling Mask 확인
↓
Frustum과 Renderer Bounds 검사
↓
Occlusion과 거리 조건 검사
↓
Visible Renderer 후보
```

이 과정을 통과한 Renderer도 Render Queue, Shader Pass와 GPU의 Depth Test에 따라 최종 화면에 Pixel을 남기지 못할 수 있다.

Camera Culling은 화면에 보일 가능성이 있는 Rendering 후보를 줄이는 단계다.

---

## Camera가 그린다는 의미

Camera가 Object를 그린다는 표현은 Camera Loop가 해당 Renderer를 Render Pass의 Draw 후보로 선택한다는 의미에 가깝다.

```text
GameObject
└─ Renderer
   ├─ Geometry
   ├─ Material
   └─ Bounds
```

Transform만 있는 빈 GameObject는 그 자체로 화면의 Triangle을 만들지 않는다.

MeshRenderer, SkinnedMeshRenderer, ParticleSystemRenderer 같은 Renderer Component가 Rendering할 Geometry와 Material을 제공한다.

```text
Camera
↓
Renderer를 수집하고 판정
↓
통과한 Renderer의 Mesh와 Material 사용
↓
Draw 준비
```

Renderer Component의 구체적인 역할은 다음 글에서 다룬다.

---

## Camera의 선택 조건

Camera가 Renderer를 후보로 선택할 때 관련되는 대표 조건은 다음과 같다.

| 조건 | 질문 |
|---|---|
| GameObject 상태 | Hierarchy에서 활성 상태인가? |
| Renderer 상태 | Renderer가 활성화되어 있는가? |
| Layer | Object가 어느 Layer에 속하는가? |
| Culling Mask | Camera가 그 Layer를 포함하는가? |
| Frustum | Renderer Bounds가 Camera가 보는 공간과 겹치는가? |
| Distance | Far Plane 또는 Layer별 거리 안에 있는가? |
| Occlusion | 다른 Object에 완전히 가려졌다고 판단되는가? |
| Render Pass | 현재 Pass의 Queue와 Filtering 조건에 맞는가? |

한 조건만 만족한다고 Draw가 보장되는 것이 아니다.

여러 Filter를 순서대로 통과해야 실제 Rendering 단계에 들어갈 수 있다.

---

## Layer란?

Layer는 GameObject를 분류하는 Integer 기반 Category다.

```text
Layer 0  : Default
Layer 5  : UI
Layer 6  : Player
Layer 7  : Enemy
Layer 8  : MinimapOnly
```

GameObject는 한 시점에 하나의 Layer에 속한다.

```csharp
gameObject.layer = LayerMask.NameToLayer("Player");
```

Layer는 Rendering에만 사용되는 정보가 아니다.

```text
Camera Culling Mask
Light Culling Mask 또는 Rendering Layer 관련 기능
Physics Layer Collision Matrix
Raycast Layer Mask
```

같은 Layer 이름을 사용해도 각 System이 그 Layer를 해석하는 목적은 다를 수 있다.

---

## Layer는 Tag와 다르다

Unity의 Tag도 GameObject를 분류하지만 Camera Culling Mask는 Tag를 직접 사용하지 않는다.

```text
Layer
Bit Mask 기반 System Filtering에 사용

Tag
Gameplay에서 Object 종류를 식별하는 문자열 Label
```

```csharp
if (other.CompareTag("Enemy"))
{
    // Gameplay Logic
}
```

Camera가 Enemy를 제외하려면 Enemy Tag가 아니라 적절한 Layer와 Culling Mask를 구성해야 한다.

---

## Culling Mask란?

Camera의 Culling Mask는 어떤 Layer의 GameObject를 Rendering 대상으로 포함할지 나타내는 Bit Mask다.

```text
Camera Culling Mask
├─ Default: On
├─ Player: On
├─ Enemy: On
└─ MinimapOnly: Off
```

Object Layer의 Bit가 Camera Mask에 포함되면 Layer 조건을 통과한다.

```text
(cameraMask & objectLayerBit) != 0
→ 포함

(cameraMask & objectLayerBit) == 0
→ 제외
```

Camera Inspector에서는 Layer 이름을 Checkbox로 표시하지만 내부적으로는 Bit 조합이다.

---

## Culling Mask의 Bit 구조

Layer 번호가 `n`이면 해당 Bit는 `1 << n`으로 만들 수 있다.

```csharp
int playerLayer = LayerMask.NameToLayer("Player");
int playerBit = 1 << playerLayer;
```

여러 Layer를 포함할 수 있다.

```csharp
int playerMask = LayerMask.GetMask("Player", "Enemy");
camera.cullingMask = playerMask;
```

특정 Layer만 기존 Mask에서 제거할 수도 있다.

```csharp
int uiBit = 1 << LayerMask.NameToLayer("UI");
camera.cullingMask &= ~uiBit;
```

Layer 이름을 찾지 못하면 `NameToLayer`가 유효한 Layer 번호를 반환하지 않으므로 Bit Shift 전에 값을 확인하는 편이 안전하다.

---

## Camera마다 Culling Mask가 다를 수 있다

같은 Scene을 여러 Camera가 서로 다르게 볼 수 있다.

```text
Main Camera
Default + Player + Enemy

Minimap Camera
Map + PlayerIcon + EnemyIcon

Weapon Camera
FirstPersonWeapon
```

Object 하나가 Main Camera에서는 제외되고 Minimap Camera에서는 포함될 수 있다.

```text
Object Layer = MinimapOnly

Main Camera Mask
MinimapOnly Off
→ 제외

Minimap Camera Mask
MinimapOnly On
→ 포함
```

Layer 분리는 Camera마다 다른 화면 구성을 만들기 쉽지만 Camera가 늘면 Camera Loop와 Rendering 비용도 늘 수 있다.

---

## Culling Mask는 Object를 비활성화하지 않는다

Camera의 Mask에서 Layer를 제외해도 GameObject가 Scene에서 사라지는 것은 아니다.

```text
Culling Mask에서 제외
├─ Script 실행 가능
├─ Physics 참여 가능
├─ Audio 동작 가능
├─ 다른 Camera에는 보일 수 있음
└─ 해당 Camera Rendering에서 제외
```

`SetActive(false)`와 목적이 다르다.

```text
SetActive(false)
GameObject Hierarchy의 활성 상태 변경

Culling Mask 제외
특정 Camera의 Rendering 선택만 변경
```

---

## View Frustum이란?

View Frustum은 Camera가 볼 수 있는 3D 공간이다.

Perspective Camera에서는 잘린 Pyramid 형태가 된다.

```text
                 Far Plane
            +----------------+
           /                  \
          /                    \
Camera → +------ Near Plane ----+
```

Frustum은 일반적으로 여섯 Plane으로 둘러싸인다.

```text
Left
Right
Top
Bottom
Near
Far
```

Renderer가 이 공간과 전혀 겹치지 않으면 Camera 화면에 나타날 수 없으므로 Draw 후보에서 제외할 수 있다.

---

## Perspective Camera의 Frustum

Perspective Camera는 멀어질수록 보이는 영역이 넓어진다.

```text
Top View

          / Far Width
         /------------
Camera  <
         \------------
          \ Far Width
```

Frustum 형태에 영향을 주는 대표 값은 다음과 같다.

```text
Camera Position / Rotation
Field of View
Aspect Ratio
Near Clip Plane
Far Clip Plane
Lens Shift와 Physical Camera 설정
```

Field of View가 커지면 한 화면에 더 넓은 방향이 포함된다.

하지만 보이는 Renderer와 Pixel 복잡도가 증가할 수 있다.

---

## Orthographic Camera의 Frustum

Orthographic Camera는 거리에 따라 Projection 크기가 작아지지 않는다.

Frustum은 직육면체 형태에 가깝다.

```text
Side View

Near Plane               Far Plane
+-------------------------------+
|                               |
|                               |
+-------------------------------+
```

Orthographic Size, Aspect Ratio, Near와 Far Plane이 보이는 공간을 결정한다.

2D Game, 전략 Camera와 일부 UI·Preview Camera에서 사용할 수 있다.

Orthographic이라고 Culling이 사라지는 것은 아니다.

해당 Frustum과 Renderer Bounds를 여전히 검사한다.

---

## Near Clip Plane

Near Clip Plane보다 Camera에 가까운 Geometry는 View Volume 밖에 놓인다.

```text
Camera
│ 제외 영역 │ Near Plane │ Rendering 영역
```

Near 값을 지나치게 크게 설정하면 Camera 가까이 있는 Object가 잘린다.

```text
Character Camera가 벽에 접근
↓
벽 일부가 Near Plane 앞쪽으로 이동
↓
화면에서 잘려 보임
```

Near 값을 너무 작게 설정하면 Perspective Depth Precision 분배가 불리해져 Z-fighting 문제가 커질 수 있다.

필요한 근거리 표현을 만족하는 범위에서 가능한 Near 값을 선택하고 실제 Platform에서 Depth 문제를 확인해야 한다.

---

## Far Clip Plane

Far Clip Plane은 Camera가 볼 수 있는 가장 먼 Frustum 경계를 만든다.

```text
Camera
↓
Near ~ Far 사이
Rendering 후보

Far보다 멀리
Frustum 밖
```

Far 값을 줄이면 먼 Renderer가 Culling되어 CPU와 GPU 작업을 줄일 가능성이 있다.

동시에 먼 배경이 갑자기 사라지지 않도록 Fog, LOD와 Scene Design을 함께 조정해야 한다.

Far 값을 줄이는 효과는 Scene의 Object 배치와 Bounds에 따라 달라진다.

---

## Frustum Culling

Frustum Culling은 Renderer의 Bounding Volume과 Frustum Plane을 비교한다.

```text
Renderer Bounds
├─ Frustum 완전히 밖
│  → Cull
├─ Frustum과 교차
│  → Candidate
└─ Frustum 안
   → Candidate
```

Unity는 일반적인 Rendering Culling에서 Mesh의 모든 Vertex를 Camera Plane과 하나씩 비교하지 않는다.

Renderer를 감싸는 단순한 Bounds를 사용해 빠르게 후보를 판단한다.

```text
정밀한 Triangle 검사
정확하지만 비쌈

Bounds 검사
보수적이지만 빠름
```

Bounds가 Frustum과 조금이라도 겹치면 실제 Triangle이 화면 밖이어도 Renderer가 후보로 남을 수 있다.

---

## Renderer Bounds

`Renderer.bounds`는 Renderer를 감싸는 World Space Axis-Aligned Bounding Box다.

```text
World Axis
     Y
     ↑
     │   +--------+
     │   |  Mesh  |
     │   +--------+
     └────────────→ X
```

Axis-Aligned이므로 Box의 면은 World Axis에 맞춰진다.

Object가 회전하면 Mesh를 완전히 감싸기 위해 Box가 커질 수 있다.

```text
회전 전 Bounds
+------+
| Mesh |
+------+

회전 후 AABB
+----------+
|  /Mesh/  |
+----------+
```

Bounds는 정밀한 형태가 아니라 빠른 공간 판정을 위한 보수적인 Volume이다.

---

## Mesh.bounds와 Renderer.bounds

두 Bounds는 Space가 다르다.

```text
Mesh.bounds
Mesh Local Space의 Bounds

Renderer.localBounds
Renderer Local Space의 Bounds

Renderer.bounds
World Space의 AABB
```

Camera Frustum과의 판정에서는 World Space 관계가 필요하다.

Renderer의 Transform과 Animation 결과를 고려한 World Bounds가 중요하다.

`Transform.position`은 Bounds Center와 같지 않을 수 있다.

Pivot이 Mesh 끝에 있거나 비대칭 Mesh라면 차이가 커진다.

---

## Bounds가 너무 작을 때

Shader가 Vertex를 원래 Mesh Bounds 밖으로 크게 이동시키는 경우가 있다.

```hlsl
positionOS.xyz += normalOS * _ExpandAmount;
```

CPU Culling System은 Shader 실행 후의 실제 Vertex 위치를 미리 알지 못할 수 있다.

```text
원래 Bounds
+----+

Shader 변형 후 Mesh
+----------+

Camera는 원래 Bounds로 판정
```

원래 Bounds가 Frustum 밖이라고 판단되면 GPU Draw가 제출되지 않아 확장된 Geometry가 화면 안에 있어도 사라질 수 있다.

Wind, Water Wave, Grass Animation, Inverted Hull Outline과 Procedural Vertex 변형에서 확인해야 한다.

---

## Bounds가 너무 클 때

Bounds를 무조건 크게 만드는 것도 해결책은 아니다.

```text
실제 Mesh는 Camera 밖
↓
큰 Bounds가 Frustum과 교차
↓
Culling 통과
↓
불필요한 Draw 후보
```

큰 Bounds는 Frustum Culling과 Occlusion Culling의 효율을 낮출 수 있다.

Shadow Caster 판정 범위에도 영향을 줄 가능성이 있다.

Vertex 변형의 최대 범위를 포함하면서도 불필요하게 크지 않은 Bounds가 적절하다.

---

## Bounds 확인하기

Gizmo를 이용해 World Bounds를 시각화할 수 있다.

```csharp
using UnityEngine;

[ExecuteAlways]
public class RendererBoundsGizmo : MonoBehaviour
{
    private void OnDrawGizmosSelected()
    {
        Renderer targetRenderer = GetComponent<Renderer>();

        if (targetRenderer == null)
        {
            return;
        }

        Bounds bounds = targetRenderer.bounds;

        Gizmos.matrix = Matrix4x4.identity;
        Gizmos.color = Color.cyan;
        Gizmos.DrawWireCube(bounds.center, bounds.size);
    }
}
```

Shader Animation의 최대 변형 시점에도 Box가 Geometry를 감싸는지 확인한다.

Skinned Mesh는 Bone Animation과 `localBounds` 설정도 함께 확인해야 한다.

---

## Frustum Plane과 Bounds 검사

Unity API를 이용해 Camera Frustum Plane과 Bounds의 교차 여부를 직접 검사할 수도 있다.

```csharp
using UnityEngine;

public class FrustumVisibilityCheck : MonoBehaviour
{
    [SerializeField] private Camera targetCamera;
    [SerializeField] private Renderer targetRenderer;

    private void Update()
    {
        Plane[] planes = GeometryUtility.CalculateFrustumPlanes(targetCamera);

        bool overlaps = GeometryUtility.TestPlanesAABB(
            planes,
            targetRenderer.bounds
        );

        Debug.Log(overlaps);
    }
}
```

이 결과는 Bounds와 Frustum이 겹치는지를 나타낸다.

최종 화면에서 실제로 보인다는 의미는 아니다.

다른 Object에 가려지거나 Shader가 Pixel을 제거할 수 있기 때문이다.

---

## Bounds 교차 판정의 보수성

다음 상황에서 Mesh Triangle은 Frustum 밖이지만 Bounds 모서리가 Frustum과 겹칠 수 있다.

```text
       Frustum
          /|
         / |
   +----+  |
   |Bounds\ |
   +------\|
```

이 경우 False Positive가 발생할 수 있다.

```text
False Positive
보이지 않는 Renderer가 후보로 남음

False Negative
보이는 Renderer가 잘못 제거됨
```

Rendering Culling은 보이는 Object를 놓치는 False Negative를 피하는 방향으로 보수적으로 설계하는 것이 일반적이다.

후보가 조금 더 남더라도 화면에 보여야 할 Geometry가 갑자기 사라지는 것보다 안전하기 때문이다.

---

## Occlusion Culling이 필요한 이유

Frustum Culling은 Camera 방향 밖의 Renderer를 제거하지만 앞의 벽에 가려진 Renderer는 알지 못한다.

```text
Camera → Wall → Hidden Object

Hidden Object는 Frustum 안
→ Frustum Culling 통과

하지만 Wall에 완전히 가려짐
→ 최종 화면에는 보이지 않음
```

Occlusion Culling은 다른 Object에 완전히 가려진 Renderer를 제외해 불필요한 Rendering을 줄인다.

```text
Frustum Culling
View Volume 밖 제거

Occlusion Culling
View Volume 안이지만 가려진 Object 제거
```

Camera에서 Occlusion Culling을 활성화하면 일반적으로 Frustum Culling과 함께 수행된다.

---

## Occluder와 Occludee

Occlusion Culling에서는 가리는 Object와 가려질 Object를 구분한다.

```text
Occluder
다른 Object를 가리는 Geometry
예: 벽, 바닥, 큰 건물

Occludee
가려졌을 때 Culling될 수 있는 Renderer
예: 방 안의 가구, 복도 뒤 Object
```

Unity의 Built-in Occlusion Culling Data에서는 움직이는 Dynamic Object가 가려질 수는 있지만 다른 Object를 가리는 Occluder 역할에는 제한이 있다.

Runtime에 전체 Scene Geometry가 생성되는 구조는 사전 Bake 방식과 맞지 않을 수 있다.

---

## Occlusion Culling의 Bake와 Runtime

Unity의 Built-in Occlusion Culling은 Editor에서 Visibility Data를 Bake한다.

```text
Editor
Scene을 Cell로 분할
↓
Cell 사이 Visibility 계산
↓
Occlusion Data 저장

Runtime
Camera 위치 확인
↓
Baked Data Query
↓
보일 수 있는 Renderer 선택
```

Runtime에는 Baked Data를 Memory에 Load하고 Camera마다 Query하는 CPU 비용이 있다.

Draw를 줄여 얻는 이득이 Query와 Memory 비용보다 커야 한다.

---

## Occlusion Culling에 적합한 Scene

Occlusion Culling은 공간이 큰 불투명 Geometry로 명확히 나뉘는 Scene에서 효과적일 수 있다.

```text
적합 가능성 높음
Room ─ Corridor ─ Room
Building Interior
도시의 큰 건물 사이

효과가 제한적일 수 있음
넓게 열린 평야
가리는 Geometry가 거의 없는 Scene
Runtime에 구조가 계속 변하는 Scene
```

작은 Object를 가리는 작은 Occluder가 매우 많으면 Data와 Query 비용이 증가할 수 있다.

Bake Parameter를 Scene Scale에 맞추고 Visualization으로 결과를 확인해야 한다.

---

## Layer Cull Distance

Camera는 Layer마다 별도의 Culling Distance를 설정할 수 있다.

```text
SmallProps Layer
50m 이후 Cull

Characters Layer
150m 이후 Cull

Terrain Layer
Far Clip까지 유지
```

작은 Detail Object는 먼 거리에서 화면 Pixel에 거의 기여하지 않으므로 Far Plane보다 먼저 제외할 수 있다.

```csharp
using UnityEngine;

public class LayerCullDistanceSetup : MonoBehaviour
{
    [SerializeField] private Camera targetCamera;

    private void Awake()
    {
        float[] distances = new float[32];
        int smallPropsLayer = LayerMask.NameToLayer("SmallProps");

        if (smallPropsLayer >= 0)
        {
            distances[smallPropsLayer] = 50f;
        }

        targetCamera.layerCullDistances = distances;
        targetCamera.layerCullSpherical = true;
    }
}
```

거리 전환이 눈에 띄지 않도록 Fog, LOD와 Fade를 함께 검토할 수 있다.

---

## Layer Cull Distance의 기준점

Layer Cull Distance는 Camera와 Object의 거리 판정 방식에 영향을 받는다.

`layerCullSpherical` 설정을 사용하면 Camera에서 구 형태의 거리를 기준으로 Layer Culling을 수행하도록 구성할 수 있다.

```text
Plane 기반 Distance
Camera View 방향과 Plane 관계

Spherical Distance
Camera Position에서 반경 관계
```

넓은 FOV의 가장자리에서 작은 Object가 언제 사라지는지 실제 Camera 움직임으로 확인해야 한다.

---

## LOD와 Camera

LOD Group은 Camera에 보이는 화면상의 크기와 설정을 바탕으로 서로 다른 Detail Mesh를 선택한다.

```text
Camera 가까움
LOD0 High Detail

중간 거리
LOD1 Medium Detail

먼 거리
LOD2 Low Detail

더 멂
Culled
```

LOD는 Camera마다 평가 결과가 달라질 수 있다.

Main Camera에서는 LOD0이지만 멀리 있는 Reflection Camera나 Minimap Camera에서는 다른 LOD가 선택될 수 있다.

LOD의 자세한 계산은 이후 Geometry 최적화 주제에서 다룬다.

---

## Renderer.enabled

Renderer Component의 `enabled`가 `false`이면 해당 Renderer는 일반 Rendering 대상이 아니다.

```csharp
Renderer targetRenderer = GetComponent<Renderer>();
targetRenderer.enabled = false;
```

GameObject와 다른 Component는 활성 상태로 유지할 수 있다.

```text
Renderer.enabled = false
├─ Script는 계속 실행 가능
├─ Collider는 계속 활성 가능
└─ 해당 Renderer Drawing은 비활성
```

특정 Camera만 제외하려면 Renderer를 끄는 것보다 Layer와 Culling Mask가 적합할 수 있다.

Renderer를 끄면 모든 Camera에서 보이지 않기 때문이다.

---

## GameObject 활성 상태

GameObject가 Hierarchy에서 비활성 상태라면 연결된 Renderer도 활성 Rendering 대상이 아니다.

```text
activeSelf
GameObject 자신에게 설정된 활성 상태

activeInHierarchy
Parent 상태까지 반영한 실제 Hierarchy 활성 상태
```

Parent가 비활성화되면 Child의 `activeSelf`가 `true`여도 `activeInHierarchy`는 `false`가 될 수 있다.

Camera Culling 문제를 조사할 때 Layer와 Bounds뿐 아니라 Hierarchy 활성 상태와 Renderer.enabled도 확인해야 한다.

---

## Renderer의 Material이 없거나 Shader가 맞지 않을 때

Renderer가 Culling을 통과해도 유효한 Rendering 설정이 필요하다.

```text
Culling 통과
↓
현재 Render Pass와 Queue 조건 확인
↓
Material의 Shader Pass 검색
↓
호환되는 Pass가 있어야 Draw 가능
```

URP에서 Shader의 `RenderPipeline` Tag가 맞지 않거나 현재 단계가 요구하는 `LightMode` Pass가 없으면 의도한 방식으로 그려지지 않을 수 있다.

이 문제는 Camera가 Object를 못 보는 것처럼 보이지만 실제 원인은 Shader 호환성일 수 있다.

---

## Render Queue Filtering

Camera Culling 결과는 이후 Render Pass에서 다시 Filter된다.

```text
Visible Renderer 목록
↓
Opaque Render Pass
Geometry Queue 범위 선택
↓
Transparent Render Pass
Transparent Queue 범위 선택
```

Renderer가 Camera에 보이더라도 Opaque Pass에서는 Transparent Material을 그리지 않는다.

대신 뒤의 Transparent Pass에서 선택될 수 있다.

Render Queue와 Sorting의 구체적인 규칙은 이후 글에서 다룬다.

---

## Rendering Layer Mask와의 차이

URP에는 GameObject Layer와 별도로 Rendering Layer Mask 개념도 있다.

```text
GameObject Layer + Camera Culling Mask
Camera가 Renderer 자체를 포함할지 결정

Rendering Layer Mask
Light, Decal 또는 특정 Renderer Feature와의 상호작용 Filter에 사용 가능
```

이름이 비슷해 Inspector에서 혼동하기 쉽다.

Camera Culling Mask에서 Object가 보이지 않는 문제를 Rendering Layer Mask만 바꿔 해결하려 하면 의도대로 동작하지 않을 수 있다.

사용하는 URP 기능이 어느 Mask를 읽는지 확인해야 한다.

---

## Camera Stacking과 Culling Mask

Base Camera와 Overlay Camera는 서로 다른 Culling Mask를 가질 수 있다.

```text
Base Camera
World Layer
↓
Overlay Camera
Weapon Layer
↓
하나의 Camera Stack 출력
```

Overlay Camera도 Projection, Clipping Plane, Culling Mask와 Occlusion Culling 같은 속성을 이용해 자신의 Rendering 대상을 고를 수 있다.

같은 Layer를 Base와 Overlay 모두 포함하면 같은 Renderer가 두 Camera에서 반복 Rendering될 수 있다.

Layer 구성을 의도적으로 분리하고 Frame Debugger로 Camera별 Draw를 확인해야 한다.

---

## Shadow에서는 선택 기준이 다를 수 있다

Camera Color에서 보이지 않는 Renderer가 Shadow에는 필요할 수 있다.

```text
Renderer
Camera Frustum 밖
↓
Camera Color Draw 제외

하지만
Light Shadow 영역 안
↓
ShadowCaster Draw 후보
```

Renderer의 `shadowCastingMode`, Light의 Shadow 설정, Shadow Distance와 Light 기준 Culling이 영향을 준다.

Camera Culling Mask에서 Layer를 제외했을 때 Shadow 처리까지 어떻게 달라지는지는 Pipeline과 Camera·Light 설정을 함께 확인해야 한다.

화면 Color Visibility와 Shadow Visibility를 동일한 판정으로 단순화하지 않는다.

---

## GPU Back-face Culling과의 차이

Camera의 Frustum Culling은 Renderer 단위로 수행된다.

Shader Pass의 `Cull Back`은 GPU Rasterization 단계에서 Triangle 방향을 기준으로 Primitive를 제거한다.

```text
Frustum Culling
Renderer Bounds 단위
Draw 제출 이전

Back-face Culling
Triangle 단위
Draw 제출 이후 GPU
```

Object가 Frustum 안에 있어 Draw가 제출되어도 Camera 반대 방향의 Triangle은 Back-face Culling으로 제거될 수 있다.

둘 다 Culling이라는 이름을 사용하지만 대상과 시점이 다르다.

---

## Depth Test와의 차이

벽 뒤의 Object가 Occlusion Culling되지 않아 Draw되더라도 GPU Depth Test에서 가려질 수 있다.

```text
Wall 먼저 Draw
↓
Depth Buffer 기록
↓
Hidden Object Draw
↓
Depth Test 실패
↓
Color 기록 제외
```

이 경우 최종 Pixel은 정확하지만 CPU Draw 제출과 Geometry 처리 일부가 이미 발생한다.

Occlusion Culling은 Draw 후보 자체를 제거할 수 있고 Depth Test는 제출된 Geometry의 Fragment Visibility를 판정한다.

---

## Camera.onPreCull은 무엇을 의미할까?

Built-in Camera Callback이나 관련 Event 이름에서 `PreCull`을 볼 수 있다.

이는 Camera가 Scene Culling을 수행하기 전 시점을 나타낸다.

SRP와 URP에서는 Rendering Callback과 Pipeline 실행 구조가 Built-in Render Pipeline과 다를 수 있으므로 Legacy Callback에 의존하기보다 현재 Pipeline이 제공하는 Event와 Renderer Feature 방식을 확인해야 한다.

Camera Transform이나 Projection을 Culling 이후에 바꾸면 Culling 결과와 실제 Rendering Matrix가 불일치할 수 있다.

변경 시점을 명확히 해야 한다.

---

## 사용자 정의 Frustum 판정의 활용

Gameplay System에서도 Frustum Plane 검사를 사용할 수 있다.

```text
Enemy UI Marker 표시 후보
Particle Update 거리 제한
LOD가 아닌 Custom Simulation 제어
Streaming 우선순위
```

하지만 Rendering Culling 결과를 추정한 Boolean 하나로 Gameplay 전체를 정지시키는 것은 주의해야 한다.

Object가 Main Camera 밖이어도 Shadow, Reflection, 다른 Camera나 Network Simulation에 필요할 수 있기 때문이다.

Rendering Visibility와 Gameplay Relevance는 다른 기준이다.

---

## Renderer.isVisible의 주의점

`Renderer.isVisible`은 Renderer가 어떤 Camera에서 보이는 것으로 판단되는지와 관련된 값이다.

Editor에서는 Scene View Camera도 Visibility에 영향을 줄 수 있다.

```text
Game Camera에는 안 보임
하지만 Scene View에는 보임
↓
Editor에서 isVisible이 true일 수 있음
```

특정 Game Camera에 대한 정확한 Frustum 판정이 필요하다면 해당 Camera의 Plane과 Bounds를 직접 검사하거나 Pipeline의 Culling 흐름에 맞는 방법을 사용한다.

`isVisible`을 Main Camera 전용 판정으로 단정하면 안 된다.

---

## Culling 결과가 Frame마다 바뀌는 이유

다음 Data가 움직이면 Visibility가 달라진다.

```text
Camera Transform
Camera FOV
Near / Far Plane
Object Transform
Renderer Bounds
Object Layer
Culling Mask
Occluder 관계
LOD 상태
```

Camera가 Frustum 경계를 빠르게 지날 때 Object가 후보에 들어오고 나가는 Frame이 반복될 수 있다.

Bounds와 LOD 전환 범위가 부정확하면 Popping이 눈에 띈다.

Temporal Effect가 있는 경우 이전 Frame Data와의 일관성도 필요할 수 있다.

---

## Culling 비용

Culling은 Draw를 줄이기 위한 작업이지만 CPU 시간이 필요하다.

```text
Renderer 수 증가
→ Bounds Update와 Frustum Test 후보 증가

Camera 수 증가
→ Camera별 Culling 반복

Occlusion Culling
→ Runtime Visibility Query와 Data Memory
```

작은 Mesh를 수천 개의 Renderer로 분리하면 정밀한 Culling은 가능하지만 Renderer 관리와 Draw 준비 비용이 증가할 수 있다.

큰 Mesh 하나로 합치면 Draw 수는 줄 수 있지만 일부만 보여도 전체 Bounds가 Culling을 통과할 수 있다.

Scene 분할 크기는 CPU Culling, Draw Call과 GPU Overdraw 사이의 Trade-off다.

---

## Static Batching과 Bounds

Static Batching은 여러 Static Renderer의 Geometry를 Batch 처리해 Draw 준비 비용을 줄이는 데 도움을 줄 수 있다.

그러나 Batching 방식에 따라 Culling Granularity와 Memory 사용을 함께 확인해야 한다.

```text
작은 Renderer 유지
세밀한 Culling 가능
Draw 후보 수 증가 가능

큰 단위 결합
Draw 수 감소 가능
보이지 않는 Geometry까지 처리 가능
```

Unity Version과 사용한 Batching 방식에 따라 내부 동작이 달라질 수 있으므로 Frame Debugger와 Profiler에서 실제 결과를 확인한다.

---

## Culling Mask 최적화

Camera가 절대 그리지 않을 Layer를 Mask에서 제외하면 해당 Camera의 후보 범위를 줄일 수 있다.

```text
Minimap Camera
Default 전체 포함
→ 불필요한 Environment Renderer 후보

필요 Layer만 포함
→ Map과 Icon 중심
```

하지만 Layer를 너무 많은 Rendering 목적에 재사용하면 설정이 복잡해진다.

Physics와 Raycast도 Layer를 사용하므로 Project 전체 Layer 설계를 함께 고려해야 한다.

Camera 한 대의 최적화를 위해 Gameplay Collision 구성이 깨지지 않도록 한다.

---

## Far Plane 최적화

Far Plane은 가능한 한 짧게 설정하면 된다는 절대 규칙은 없다.

```text
Far Plane 감소
장점 가능성
- 먼 Renderer 후보 감소
- Depth Precision 개선 가능

문제 가능성
- 먼 배경 Clipping
- Shadow와 Fog 연출 불일치
- 큰 Object의 Bounds가 갑자기 사라짐
```

Camera 목적에 맞게 설정한다.

Main Camera, Minimap Camera와 Reflection Camera는 필요한 거리 범위가 다를 수 있다.

---

## Occlusion Culling 최적화

Occlusion Culling을 켜는 것만으로 성능이 항상 좋아지지는 않는다.

확인할 항목은 다음과 같다.

```text
가려지는 Renderer가 충분히 많은가?
Occluder가 크고 안정적인가?
Scene이 Cell로 나누기 적합한가?
Baked Data Memory는 적절한가?
Runtime Query CPU 비용보다 Draw 감소가 큰가?
Dynamic Geometry 비중은 어떤가?
```

Indoor Scene처럼 방과 복도가 명확한 환경에서는 효과가 클 수 있다.

Open World의 탁 트인 평야에서는 이득이 제한적일 수 있다.

Occlusion Visualization과 목표 Device Profiler로 판단해야 한다.

---

## Object가 보이지 않을 때 확인 순서

Renderer가 Camera에 나타나지 않으면 다음 순서로 조사할 수 있다.

```text
1. GameObject activeInHierarchy
↓
2. Renderer.enabled
↓
3. Object Layer
↓
4. Camera Culling Mask
↓
5. Near / Far Clip Plane
↓
6. Frustum과 Renderer Bounds
↓
7. Occlusion Culling
↓
8. Render Queue와 Camera Renderer 설정
↓
9. Material과 URP Shader Pass
↓
10. Depth / Stencil / Alpha Clip
```

Frame Debugger에 Draw Event가 없다면 CPU·Pipeline 선택 단계부터 확인한다.

Draw Event는 있지만 Pixel이 없다면 GPU State, Shader와 Geometry를 조사한다.

---

## Frame Debugger로 Camera 결과 확인하기

Frame Debugger에서는 Camera와 Render Pass별로 어떤 Renderer가 Draw되었는지 확인할 수 있다.

```text
Camera Event 선택
↓
Opaque / Transparent Pass 확인
↓
Object Draw 검색
↓
Material과 Shader Pass 확인
```

Object가 목록에 없다면 Layer, Frustum, Bounds, Occlusion 또는 Pass Filtering 문제일 수 있다.

Object가 목록에 있지만 보이지 않는다면 Depth, Cull, Stencil, Blend, Alpha Clip과 Shader Output을 확인한다.

---

## Scene View로 Frustum 확인하기

Hierarchy에서 Camera를 선택하면 Scene View에서 Frustum Gizmo를 볼 수 있다.

```text
Camera 선택
↓
Frustum 경계 확인
↓
Object Bounds와 교차 여부 확인
↓
Near / Far와 FOV 조정
```

Occlusion Culling Window의 Visualization을 사용하면 Camera 위치에서 어떤 Renderer가 가려졌다고 판단되는지 확인할 수 있다.

Scene View Camera 자체의 Rendering과 Game Camera의 결과를 혼동하지 않도록 Game View도 함께 확인한다.

---

## 자주 혼동하는 내용

### Camera는 GameObject의 Transform 위치만 보고 Culling한다?

아니다.

Renderer를 감싸는 Bounds를 사용하므로 Pivot이 Frustum 밖이어도 Bounds가 겹치면 후보가 될 수 있다.

### Bounds 일부만 Frustum에 들어오면 Renderer가 제거된다?

일반적으로 그렇지 않다.

Bounds가 Frustum과 교차하면 보이는 Geometry를 놓치지 않도록 후보로 남는다.

### Culling Mask에서 제외하면 Object의 Script도 멈춘다?

아니다.

해당 Camera의 Rendering 대상에서 제외될 뿐 GameObject 전체가 비활성화되는 것은 아니다.

### Frustum 안이면 반드시 화면에 보인다?

아니다.

Occlusion, Render Queue, Shader Pass, GPU Depth와 Alpha 판정 때문에 Pixel을 남기지 않을 수 있다.

### Occlusion Culling은 Depth Test와 같다?

아니다.

Occlusion Culling은 Draw 후보를 CPU 쪽에서 제거할 수 있고 Depth Test는 제출된 Fragment를 GPU에서 판정한다.

### Bounds를 크게 만들면 Culling 문제가 모두 해결된다?

아니다.

보이는 Mesh가 잘리는 문제는 줄 수 있지만 불필요한 Draw와 Shadow 후보가 늘어 Culling 효율이 낮아질 수 있다.

### Main Camera에서 안 보이면 Renderer.isVisible은 항상 false다?

Editor Scene View나 다른 Camera에 보이면 true일 수 있으므로 특정 Camera 전용 판정으로 사용하기에는 주의가 필요하다.

---

## Camera 선택 흐름 다시 연결하기

Camera가 Renderer를 고르는 과정을 단순화하면 다음과 같다.

```text
Scene Renderer
│
├─ GameObject와 Renderer가 활성인가?
│
├─ Object Layer가 Culling Mask에 포함되는가?
│
├─ Bounds가 View Frustum과 겹치는가?
│
├─ Layer Distance와 LOD 조건을 통과하는가?
│
├─ Occlusion Culling에서 보일 가능성이 있는가?
│
└─ 현재 Render Pass의 Queue와 Filtering 조건에 맞는가?
   ↓
   Draw Candidate
   ↓
   GPU Pipeline
   ↓
   최종 Pixel 판정
```

Culling은 보이는 결과를 직접 완성하는 단계가 아니라 GPU에 보낼 후보를 줄이는 단계다.

---

## 정리

Camera는 Scene의 모든 GameObject를 무조건 그리지 않는다.

활성화된 Renderer 중 Object Layer가 Camera의 Culling Mask에 포함되고 Renderer Bounds가 View Frustum과 겹치는 대상을 먼저 후보로 고른다.

```text
Layer + Culling Mask
↓
View Frustum + Renderer Bounds
↓
Distance / LOD / Occlusion
↓
Render Pass Filtering
↓
Draw Candidate
```

View Frustum은 Camera의 Projection, FOV, Aspect Ratio와 Near·Far Clip Plane이 만드는 3D 공간이다.

Frustum Culling은 모든 Triangle 대신 World Space AABB인 `Renderer.bounds`를 사용해 빠르고 보수적으로 Renderer를 판정한다.

Bounds가 너무 작으면 Shader Vertex 변형으로 화면 안에 들어온 Geometry가 잘못 사라질 수 있고 너무 크면 보이지 않는 Renderer가 불필요하게 후보로 남는다.

Occlusion Culling은 Frustum 안에 있지만 다른 Geometry에 완전히 가려진 Renderer를 제거할 수 있으나 Baked Data Memory와 Runtime CPU Query 비용이 있다.

Camera Culling을 통과한 Renderer도 Shader Pass, Back-face Culling, Depth, Stencil과 Alpha Clip을 통과해야 최종 Pixel을 남긴다.

Object가 보이지 않거나 불필요한 Draw가 많다면 Culling Mask, Frustum, Bounds와 Occlusion 결과를 Frame Debugger 및 Scene Visualization으로 확인하고 목표 Device에서 측정해야 한다.
