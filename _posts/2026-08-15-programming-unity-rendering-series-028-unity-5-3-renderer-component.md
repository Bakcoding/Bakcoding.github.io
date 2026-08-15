---
title: "[Unity 렌더링] 5-3. Renderer 컴포넌트는 어떤 역할을 할까?"
excerpt: "Unity Rendering"
categories:
  - Programming
tags:
  - Unity
  - Rendering
  - Renderer
  - MeshRenderer
  - SkinnedMeshRenderer
permalink: /programming/unity-5-3-renderer-component/
toc: true
toc_sticky: true
date: 2026-08-15
last_modified_at: 2026-08-15
---

Mesh Asset이 Project에 존재한다고 해서 화면에 자동으로 나타나지는 않는다.

Unity는 어떤 Geometry를 어떤 Material로, 어느 Transform 위치에서, 어떤 Lighting과 Shadow 설정으로 그릴지 연결해야 한다.

이 연결의 중심에 Renderer Component가 있다.

```text
Geometry
+ Material
+ Transform
+ Rendering 설정
↓
Renderer
↓
Camera Culling
↓
Render Pass와 Draw 후보
```

일반적인 정적 형태의 Mesh는 `MeshFilter`와 `MeshRenderer`가 함께 처리하고 Bone이나 Blend Shape로 변형되는 Mesh는 `SkinnedMeshRenderer`가 처리한다.

---

## Renderer란?

`Renderer`는 Unity가 Scene의 시각적 Object를 Rendering System에 등록하고 관리하는 기반 Component Type이다.

```text
Renderer
├─ MeshRenderer
├─ SkinnedMeshRenderer
├─ SpriteRenderer
├─ LineRenderer
├─ TrailRenderer
└─ ParticleSystemRenderer
```

각 Component가 만드는 Geometry의 방식은 다르지만 공통적으로 다음과 같은 정보를 제공한다.

```text
Render할 Material
World Bounds
Shadow Casting과 Receiving 설정
Light·Reflection Probe 설정
Rendering Layer Mask
활성 상태
Sorting 관련 정보
```

Camera와 Render Pipeline은 이 정보를 바탕으로 Renderer를 Culling하고 적절한 Pass에 배치한다.

---

## Renderer는 Mesh 자체가 아니다

Renderer와 Mesh를 같은 것으로 혼동하기 쉽다.

```text
Mesh
Vertex와 Index 등 Geometry Data

Material
Shader와 Property 값

Renderer
Geometry와 Material을 Scene Rendering에 연결하는 Component
```

같은 Mesh Asset을 여러 Renderer가 공유할 수 있다.

```text
Cube Mesh Asset
├─ Renderer A + Red Material
├─ Renderer B + Blue Material
└─ Renderer C + Glass Material
```

Geometry Data는 같아도 Transform과 Material이 달라 서로 다른 위치와 모습으로 그려진다.

---

## 일반 Mesh의 Component 구조

일반적인 3D Mesh GameObject에는 다음 Component가 있다.

```text
GameObject
├─ Transform
├─ MeshFilter
└─ MeshRenderer
```

각 Component의 역할은 분리되어 있다.

| Component | 역할 |
|---|---|
| `Transform` | Position, Rotation, Scale |
| `MeshFilter` | 사용할 Mesh 참조 |
| `MeshRenderer` | Mesh를 Material과 Rendering 설정으로 그리도록 연결 |

전체 흐름은 다음과 같다.

```text
MeshFilter.sharedMesh
↓
MeshRenderer가 Geometry로 사용
↓
Transform으로 World Space 배치
↓
Materials로 Surface 표현
↓
Render Pipeline에 제출
```

---

## MeshFilter의 역할

`MeshFilter`는 일반 MeshRenderer가 사용할 Mesh를 보관한다.

```csharp
using UnityEngine;

public class MeshFilterExample : MonoBehaviour
{
    [SerializeField] private Mesh sourceMesh;

    private void Awake()
    {
        MeshFilter meshFilter = GetComponent<MeshFilter>();
        meshFilter.sharedMesh = sourceMesh;
    }
}
```

Mesh에는 대표적으로 다음 Data가 있다.

```text
Position
Normal
Tangent
UV
Vertex Color
Index
SubMesh
Bounds
```

MeshFilter는 Surface를 어떻게 Shading할지는 정하지 않는다.

그 역할은 MeshRenderer가 참조하는 Material과 Shader가 담당한다.

---

## MeshRenderer의 역할

`MeshRenderer`는 같은 GameObject의 MeshFilter가 참조하는 Mesh를 그린다.

```text
MeshFilter
어떤 모양인가?

MeshRenderer
그 모양을 어떻게 Rendering System에 연결할까?
```

MeshRenderer는 다음 설정을 함께 관리한다.

```text
Materials
Cast Shadows
Receive Shadows
Light Probes
Reflection Probes
Lightmapping
Motion Vectors
Rendering Layer Mask
Bounds와 Sorting
```

MeshFilter만 있고 MeshRenderer가 없으면 Geometry Asset 참조는 존재하지만 일반적인 Camera Rendering에는 나타나지 않는다.

MeshRenderer만 있고 유효한 MeshFilter Mesh가 없다면 그릴 Geometry가 없다.

---

## MeshFilter에서 MeshRenderer까지

Cube 하나를 그리는 Data 관계를 단순화하면 다음과 같다.

```text
Cube GameObject
│
├─ Transform
│  Position = (0, 1, 0)
│
├─ MeshFilter
│  sharedMesh = CubeMesh
│
└─ MeshRenderer
   Materials[0] = RedMaterial
```

Render Pipeline이 이 Renderer를 선택하면 다음 정보가 Draw에 연결된다.

```text
CubeMesh Vertex / Index Buffer
+ Object Transform
+ RedMaterial Shader와 Property
+ MeshRenderer State
↓
Draw Command
```

Renderer가 GPU API Command 자체는 아니다.

Unity가 Draw Command를 만들기 위해 사용하는 Scene Component다.

---

## Material의 역할

Material은 사용할 Shader와 그 Shader Property 값을 보관한다.

```text
Material
├─ Shader
├─ Base Texture
├─ Base Color
├─ Metallic
├─ Smoothness
├─ Keyword 상태
└─ Render Queue 설정
```

Renderer는 Material Slot을 통해 Mesh의 각 부분에 Material을 연결한다.

```text
Renderer
├─ Material 0 → Body
├─ Material 1 → Glass
└─ Material 2 → Metal Trim
```

Shader가 GPU Program과 Pass를 정의하고 Material이 사용할 값과 Variant 상태를 정한다.

Renderer는 그 Material을 특정 Geometry와 Transform에 적용한다.

---

## Mesh의 SubMesh

하나의 Mesh는 여러 SubMesh로 나뉠 수 있다.

SubMesh는 같은 Vertex Buffer를 공유하면서 서로 다른 Index 범위를 사용하는 Geometry 부분이다.

```text
Mesh Vertex Buffer
공통 Vertex Data

SubMesh 0 Index List
Body Triangle

SubMesh 1 Index List
Glass Triangle

SubMesh 2 Index List
Metal Triangle
```

각 SubMesh는 Renderer의 Material Slot 하나와 대응한다.

```text
SubMesh 0 → Materials[0]
SubMesh 1 → Materials[1]
SubMesh 2 → Materials[2]
```

SubMesh마다 Material과 Shader State가 달라질 수 있으므로 일반적으로 별도의 Draw 작업이 필요하다.

---

## Material Slot과 Draw

Mesh가 세 개의 SubMesh를 가지고 각 Slot에 서로 다른 Material이 연결되었다고 가정한다.

```text
Renderer 하나
├─ SubMesh 0 + Material A
├─ SubMesh 1 + Material B
└─ SubMesh 2 + Material C
```

Renderer Component 수는 하나지만 Rendering 작업은 Material과 SubMesh별로 나뉠 수 있다.

```text
Draw Candidate 1
SubMesh 0 + Material A

Draw Candidate 2
SubMesh 1 + Material B

Draw Candidate 3
SubMesh 2 + Material C
```

따라서 Renderer 수와 Draw Call 수는 항상 같지 않다.

정확한 Draw 수는 Pass, Camera, Shadow, Batching과 Instancing까지 영향을 받는다.

---

## Material 수가 SubMesh보다 많을 때

Unity 6 Mesh Renderer 문서 기준으로 Material Slot이 SubMesh 수보다 많으면 남은 Material들이 마지막 SubMesh를 추가로 Rendering할 수 있다.

```text
SubMesh 수 = 2
Material 수 = 4

SubMesh 0 → Material 0
SubMesh 1 → Material 1
SubMesh 1 → Material 2 추가 Draw
SubMesh 1 → Material 3 추가 Draw
```

Transparent Layer를 겹치는 특수 효과에 사용할 수 있지만 의도하지 않은 추가 Slot은 불필요한 Draw를 만든다.

Opaque Material을 반복하면 앞의 결과를 덮어쓰면서 비용만 늘 수 있다.

Imported Model의 Material Slot 수와 실제 SubMesh 수를 확인해야 한다.

---

## Material 수가 SubMesh보다 적을 때

Material Slot이 필요한 SubMesh보다 적으면 모든 SubMesh가 의도한 Material로 Rendering되지 않을 수 있다.

```text
SubMesh 0: Body
SubMesh 1: Glass
SubMesh 2: Trim

Material Slot 0만 존재
→ 일부 SubMesh에 올바른 Material Mapping이 없음
```

Model Import 후 Material이 비어 있거나 Slot 순서가 바뀌면 표면 일부가 예상과 다르게 보일 수 있다.

Mesh의 `subMeshCount`와 Renderer의 `sharedMaterials.Length`를 함께 확인할 수 있다.

---

## SubMesh 수 확인하기

다음 Script로 Mesh와 Material Slot 관계를 확인할 수 있다.

```csharp
using UnityEngine;

public class RendererSlotReport : MonoBehaviour
{
    private void Start()
    {
        MeshFilter meshFilter = GetComponent<MeshFilter>();
        MeshRenderer meshRenderer = GetComponent<MeshRenderer>();

        if (meshFilter == null || meshRenderer == null)
        {
            return;
        }

        Mesh mesh = meshFilter.sharedMesh;

        Debug.Log($"SubMesh: {mesh.subMeshCount}");
        Debug.Log($"Material Slots: {meshRenderer.sharedMaterials.Length}");
    }
}
```

Slot 수가 많다고 항상 오류는 아니지만 추가 Layer Rendering이 의도된 것인지 확인해야 한다.

---

## sharedMaterial

`Renderer.sharedMaterial`은 Renderer가 공유하는 첫 번째 Material Asset을 참조한다.

```csharp
Renderer targetRenderer = GetComponent<Renderer>();
Material shared = targetRenderer.sharedMaterial;
```

여러 Renderer가 같은 Material을 사용할 수 있다.

```text
Shared Red Material
├─ Cube A Renderer
├─ Cube B Renderer
└─ Cube C Renderer
```

Shared Material의 Property를 변경하면 그 Asset을 사용하는 다른 Renderer의 모습도 바뀔 수 있고 Editor에서는 Project Asset 변경으로 이어질 수 있다.

Runtime에 개별 Object만 바꾸려는 목적이라면 주의해야 한다.

---

## sharedMaterials

여러 Material Slot은 `sharedMaterials` 배열로 접근할 수 있다.

```csharp
Renderer targetRenderer = GetComponent<Renderer>();
Material[] slots = targetRenderer.sharedMaterials;

slots[1] = replacementMaterial;
targetRenderer.sharedMaterials = slots;
```

Getter가 반환하는 배열은 Renderer 내부 배열 그 자체가 아니라 복사된 배열이므로 Element를 바꾼 뒤 다시 할당해야 한다.

```text
배열 가져오기
↓
복사본 Element 변경
↓
Renderer.sharedMaterials에 다시 할당
```

배열 안의 Material Asset 자체를 수정하면 그 Material을 공유하는 다른 Renderer에도 영향을 준다.

---

## material

`Renderer.material`은 Renderer 전용으로 수정할 Material Instance가 필요할 때 사용할 수 있다.

```csharp
Renderer targetRenderer = GetComponent<Renderer>();
targetRenderer.material.color = Color.red;
```

공유 Material이 사용 중이라면 Unity가 해당 Renderer용 Material Instance를 만들 수 있다.

```text
Shared Material
↓ renderer.material 접근
Instance Material 생성 가능
↓
해당 Renderer만 다른 값
```

편리하지만 많은 Renderer에서 반복 호출하면 Material Instance 수와 Memory, Batching 상태에 영향을 줄 수 있다.

Property 하나를 Object별로 바꾸기 위해 무조건 Material을 복제하는 방식은 피하는 편이 좋다.

---

## sharedMaterial과 material 비교

| API | 의미 | 주의점 |
|---|---|---|
| `sharedMaterial` | 공유 Material Asset 참조 | 값을 수정하면 공유 사용자에 영향 |
| `sharedMaterials` | 공유 Material Slot 배열 | 반환 배열 수정 후 다시 할당 필요 |
| `material` | 개별 Renderer용 Material 접근 | Instance 생성 가능 |
| `materials` | 개별 Material Slot 배열 접근 | 여러 Instance 생성 가능성 주의 |

단순히 읽기만 할 때도 어떤 Property가 Instance를 만들 수 있는지 인식해야 한다.

Material Instance가 필요한 경우 Lifetime과 정리 방식도 Project 구조에 맞게 관리한다.

---

## MaterialPropertyBlock

같은 Material과 Shader를 유지하면서 Renderer별 Property 값을 다르게 전달하려면 `MaterialPropertyBlock`을 사용할 수 있다.

```csharp
using UnityEngine;

public class PerRendererColor : MonoBehaviour
{
    private static readonly int BaseColorId =
        Shader.PropertyToID("_BaseColor");

    private Renderer targetRenderer;
    private MaterialPropertyBlock propertyBlock;

    private void Awake()
    {
        targetRenderer = GetComponent<Renderer>();
        propertyBlock = new MaterialPropertyBlock();
    }

    public void SetColor(Color color)
    {
        targetRenderer.GetPropertyBlock(propertyBlock);
        propertyBlock.SetColor(BaseColorId, color);
        targetRenderer.SetPropertyBlock(propertyBlock);
    }
}
```

```text
Shared Material 유지
+ Renderer별 Property Override
↓
개별 Color 또는 값
```

MaterialPropertyBlock이 모든 Batching 경로에서 항상 최선인 것은 아니다.

URP SRP Batcher와의 상호작용, GPU Instancing Property 선언과 대상 Platform 결과를 측정해야 한다.

---

## MaterialPropertyBlock은 Shader를 바꾸지 않는다

Property Block은 Material Property 값을 Override한다.

```text
바꾸기 적합한 값
Color
Float
Vector
Texture
Matrix

직접 바꾸지 않는 구조
Material Shader 자체
SubMesh 수
Shader Pass 구조
```

Keyword로 Compile 경로가 달라지는 기능은 단순 Float Override만으로 활성화되지 않을 수 있다.

Shader가 Uniform Branch로 Property를 읽도록 작성했는지 Keyword Variant를 요구하는지 구분해야 한다.

---

## Transform의 역할

MeshRenderer는 GameObject Transform을 이용해 Mesh를 World에 배치한다.

```text
Mesh Local Position
↓ Object-to-World Matrix
World Position
↓ View Matrix
View Position
↓ Projection Matrix
Clip Position
```

Renderer가 같은 Mesh와 Material을 공유해도 Transform이 다르면 서로 다른 위치에 나타난다.

```text
Renderer A
Transform A

Renderer B
Transform B
```

GPU Instancing은 같은 Mesh와 Material을 공유하는 여러 Instance의 Transform과 Instance Data를 묶어 처리하는 방식이다.

---

## Renderer Bounds

Renderer는 Camera Culling을 위한 World Bounds를 제공한다.

```text
Renderer.bounds
World Space Axis-Aligned Bounding Box
```

이전 글에서 다룬 Camera Frustum Culling은 이 Bounds가 View Frustum과 겹치는지 검사한다.

```text
Bounds 완전히 밖
→ Renderer Cull

Bounds 일부라도 교차
→ Draw Candidate 가능
```

MeshRenderer Bounds는 Mesh Geometry와 Transform을 바탕으로 계산된다.

Shader가 Vertex를 Bounds 밖으로 이동시키면 Bounds를 적절히 보정해야 할 수 있다.

---

## Cast Shadows

Renderer의 Cast Shadows 설정은 Shadow Map에 참여하는 방식에 영향을 준다.

대표적인 Mode는 다음과 같다.

```text
On
일반적으로 Shadow Casting

Off
Shadow Casting 제외

Two Sided
양면을 Shadow Caster로 처리

Shadows Only
Camera Color에서는 보이지 않고 Shadow만 생성
```

`Shadows Only`는 보이지 않는 대리 Geometry로 Shadow를 만들 때 사용할 수 있다.

하지만 Renderer와 Shader에 적절한 `ShadowCaster` Pass가 있어야 기대한 Shadow가 나온다.

---

## Receive Shadows

Receive Shadows는 다른 Object의 Shadow가 이 Renderer의 Surface Lighting에 반영되는지 제어한다.

```text
Cast Shadows
이 Renderer가 Shadow Map에 흔적을 남기는가?

Receive Shadows
이 Renderer가 Lighting에서 Shadow를 적용받는가?
```

둘은 독립적인 역할이다.

```text
Cast On + Receive Off
다른 곳에 그림자는 만들지만 자신은 그림자를 받지 않음

Cast Off + Receive On
자신은 그림자를 만들지 않지만 다른 그림자를 받을 수 있음
```

실제 지원 방식은 사용하는 URP Shader와 Material 설정에 따라 달라질 수 있다.

---

## Motion Vectors

Renderer의 Motion Vector 설정은 이전 Frame과 현재 Frame 사이의 움직임 정보를 기록하는 방식에 영향을 준다.

```text
Previous Transform 또는 Vertex Position
+ Current Transform 또는 Vertex Position
↓
Motion Vector
```

Motion Blur와 Temporal Anti-Aliasing 같은 Effect가 이 Data를 사용할 수 있다.

움직이지 않는 Renderer까지 불필요한 Motion Vector Pass에 포함되는지, Vertex Animation이 올바른 이전 위치를 제공하는지 확인해야 한다.

URP Version과 Renderer 설정에 따라 Mode와 지원 범위가 달라질 수 있다.

---

## Light Probe

Light Probe는 Baked Lighting 정보를 Scene의 여러 지점에 저장하고 Dynamic Renderer가 보간해 사용할 수 있게 한다.

```text
주변 Light Probes
↓
Renderer 위치에서 보간
↓
간접광 정보
↓
Material Lighting
```

Renderer의 Light Probe Usage 설정이 보간 방식을 결정한다.

큰 Renderer나 여러 Renderer가 이어진 Object에서는 Bounds Center 기반 Sample 위치 차이로 경계가 보일 수 있다.

Anchor Override나 Light Probe Proxy Volume을 Project 요구에 따라 검토할 수 있다.

---

## Reflection Probe

Reflection Probe는 주변 환경 Reflection 정보를 Cubemap 형태로 제공한다.

```text
Reflection Probe
↓
Renderer와 Probe 관계 계산
↓
Material이 Environment Reflection Sample
```

Renderer의 Reflection Probe Usage는 Probe 선택과 Blend 방식에 영향을 준다.

Shader가 Reflection Probe Data를 사용하지 않는 Unlit Shader라면 Renderer 설정만 켠다고 Reflection이 자동으로 나타나지는 않는다.

Renderer는 Data 연결을 제공하고 최종 계산은 Shader가 수행한다.

---

## Probe Anchor

Probe Sampling의 기준 위치는 기본적으로 Renderer Bounds와 관련된 위치를 사용할 수 있다.

Anchor Override에 별도 Transform을 지정하면 여러 Renderer가 같은 기준점에서 Probe를 Sample하도록 만들 수 있다.

```text
Character
├─ Body Renderer
├─ Clothes Renderer
└─ Equipment Renderer

같은 Anchor 사용
→ Probe Lighting 기준 통일
```

큰 Object 전체에 한 점의 Probe 결과를 적용하면 공간적 Lighting 변화가 충분히 표현되지 않을 수 있다.

Light Probe Proxy Volume 같은 대안을 상황에 맞게 사용한다.

---

## Lightmapping

Static MeshRenderer는 Baked Lightmap에 참여할 수 있다.

```text
Mesh UV
+ Renderer Lightmap 설정
+ Material Meta Pass
↓
Lightmap Bake
↓
Runtime Lightmap Sample
```

Renderer는 Lightmap Index와 Scale-Offset 같은 정보를 통해 자신의 Mesh가 Lightmap의 어느 영역을 사용할지 연결한다.

Material Shader에 적절한 Lightmap Keyword와 Sampling Code가 있어야 최종 Surface에 적용된다.

Renderer 설정과 Shader 기능은 서로 보완 관계다.

---

## Rendering Layer Mask

Renderer의 Rendering Layer Mask는 GameObject Layer와 별개의 Rendering 전용 Mask다.

```text
GameObject Layer
Camera Culling Mask와 Physics 등에 사용

Rendering Layer Mask
특정 Light, Decal 또는 Renderer Feature Filtering에 사용 가능
```

Renderer가 Camera에서 완전히 보이지 않는 문제는 우선 GameObject Layer와 Camera Culling Mask를 확인한다.

특정 Light만 적용되지 않는 문제는 Rendering Layer 관계를 확인할 수 있다.

사용하는 URP 기능이 어떤 Mask를 지원하는지 공식 문서와 Frame Debugger로 검증해야 한다.

---

## Renderer Priority와 Sorting

Renderer에는 특정 상황에서 Sorting에 영향을 주는 설정이 있을 수 있다.

Transparent Renderer는 Camera Distance와 Sorting Layer, Order 또는 Priority 등에 따라 순서가 달라질 수 있다.

```text
Renderer가 Culling 통과
↓
Render Queue 분류
↓
Sorting 기준 적용
↓
Draw 순서 결정
```

Renderer가 선택된다는 것과 언제 그려진다는 것은 다른 문제다.

Render Queue와 Sorting은 이후 글에서 더 구체적으로 다룬다.

---

## SkinnedMeshRenderer란?

`SkinnedMeshRenderer`는 Bone Skinning, Blend Shape 또는 Cloth처럼 변형되는 Mesh를 Rendering한다.

```text
GameObject
├─ Transform
└─ SkinnedMeshRenderer
   ├─ Shared Mesh
   ├─ Bones
   ├─ Root Bone
   ├─ Blend Shape Weights
   ├─ Materials
   └─ Bounds
```

일반적인 MeshRenderer와 달리 별도의 MeshFilter가 필요하지 않다.

SkinnedMeshRenderer 자체가 `sharedMesh` 참조를 가진다.

---

## Skinning이란?

Skinning은 Skeleton의 Bone Transform을 이용해 Mesh Vertex를 변형하는 과정이다.

```text
Vertex
├─ Bone Index 0 + Weight 0
├─ Bone Index 1 + Weight 1
├─ Bone Index 2 + Weight 2
└─ Bone Index 3 + Weight 3
↓
Bone Matrix 가중 결합
↓
Deformed Vertex
```

개념적인 Position 계산은 다음과 같다.

```text
P' = w0 × M0 × P
   + w1 × M1 × P
   + w2 × M2 × P
   + w3 × M3 × P
```

Bone Influence 수가 많으면 변형 품질이 좋아질 수 있지만 Vertex 처리와 Data 비용이 증가할 수 있다.

---

## Root Bone

Root Bone은 Skeleton Hierarchy의 기준 Transform을 지정한다.

```text
Character Root
└─ Hips
   ├─ Spine
   ├─ LeftLeg
   └─ RightLeg
```

SkinnedMeshRenderer Bounds는 Root Bone을 기준으로 이동한다.

Root Bone 참조가 잘못되면 Culling Bounds 위치와 Animation 결과에 문제가 생길 수 있다.

Imported Character Prefab의 Bone 구조를 임의로 바꿀 때 Renderer의 Bone Array와 Bind Pose 관계도 유지해야 한다.

---

## Blend Shape

Blend Shape는 Base Vertex와 Target Shape의 차이를 Weight로 적용해 Mesh를 변형한다.

```text
Base Face
+ Smile Delta × Weight
↓
Smiling Face
```

SkinnedMeshRenderer가 각 Blend Shape Weight를 보관한다.

```csharp
SkinnedMeshRenderer skinned = GetComponent<SkinnedMeshRenderer>();
skinned.SetBlendShapeWeight(0, 75f);
```

Facial Animation, Muscle Shape와 Corrective Shape 등에 사용할 수 있다.

Blend Shape도 Vertex Position을 바꾸므로 Bounds와 Vertex Processing 비용에 영향을 준다.

---

## Skinned Mesh Bounds

Skinned Mesh는 Animation에 따라 실제 Vertex 범위가 변한다.

Unity는 Import 시점에 Model과 포함된 Animation을 바탕으로 최대 Bounds를 계산해 Visibility 판정에 사용한다.

```text
Idle Pose
작은 Bounds

Arms Up Animation
더 높은 Bounds 필요

Attack Animation
더 넓은 Bounds 필요
```

Import 이후 추가된 Animation, Runtime Bone 변경, Ragdoll과 Vertex Shader 변형은 미리 계산된 Bounds 밖으로 나갈 수 있다.

이 경우 보이는 Character 일부 또는 전체가 Camera 각도에 따라 사라질 수 있다.

---

## Update When Offscreen

`Update When Offscreen`이 꺼져 있으면 어떤 활성 Camera에서도 보이지 않는 Skinned Mesh의 Skinning Update를 중단해 비용을 줄일 수 있다.

```text
Offscreen
+ Update When Offscreen Off
↓
Skinning Update 중지 가능
```

활성화하면 화면 밖에서도 매 Frame Bounds와 Skinning Update를 계속할 수 있다.

```text
장점
예측하기 어려운 Ragdoll이나 Runtime Bone 변형 대응

비용
보이지 않는 Character도 Update
```

가능하면 최대 변형을 포함하도록 Bounds를 정확히 수정하는 방식이 성능상 유리할 수 있다.

---

## Offscreen Animation과 Gameplay

SkinnedMeshRenderer의 화면 밖 Update 설정을 Animation System 전체의 Gameplay Update와 동일하게 보면 안 된다.

Animator의 Culling Mode, Root Motion, Script Bone 변경과 SkinnedMeshRenderer Update가 서로 영향을 줄 수 있다.

```text
화면 밖 Character
├─ Gameplay AI는 계속 실행
├─ Animator Pose Update는 설정에 따라 달라짐
└─ Skinning과 Bounds Update도 설정에 따라 달라짐
```

화면 밖에서 이동한 뒤 다시 나타날 때 Pose가 튀거나 Bounds가 틀리면 Animator와 Renderer 설정을 함께 확인해야 한다.

---

## MeshRenderer와 SkinnedMeshRenderer 비교

| 항목 | MeshRenderer | SkinnedMeshRenderer |
|---|---|---|
| Mesh 참조 | MeshFilter | Renderer의 `sharedMesh` |
| 대표 용도 | 일반적으로 형태가 고정된 Mesh | Bone·Blend Shape·Cloth 변형 Mesh |
| Vertex 변형 | Transform과 Shader 중심 | Skinning + Blend Shape + Shader |
| Bounds | Mesh와 Transform 기반 | Import Animation과 Runtime 변형 고려 |
| 추가 Data | MeshFilter 필요 | Bones, Bind Pose, Weights, Root Bone |
| 비용 | 상대적으로 단순 | Skinning과 Bounds Update 비용 추가 |

회전하는 기계 부품처럼 각 Part가 Rigid Transform으로만 움직인다면 여러 MeshRenderer Hierarchy로 표현할 수 있다.

팔꿈치처럼 하나의 Surface가 Joint에서 부드럽게 휘어야 한다면 SkinnedMeshRenderer가 적합하다.

---

## Renderer에서 Draw 후보가 만들어지는 과정

한 MeshRenderer가 화면에 그려지는 흐름을 연결하면 다음과 같다.

```text
GameObject Active
↓
Renderer Enabled
↓
Camera Culling Mask와 Bounds Test
↓
Visible Renderer 목록
↓
Render Queue와 Pass Filtering
↓
SubMesh와 Material Slot 분리
↓
Shader Pass와 Variant 선택
↓
Mesh / Transform / Material Data Binding
↓
Draw Command
```

Renderer는 이 전체 과정의 입력 Data를 묶는 Scene 측 단위다.

실제 Draw Call이 언제 발생하는지는 다음 글에서 더 자세히 다룬다.

---

## Renderer 하나가 여러 번 그려지는 경우

Renderer 하나도 Frame 안에서 여러 역할로 Drawing될 수 있다.

```text
Shadow Map
→ ShadowCaster Pass

Depth Prepass
→ DepthOnly Pass

Camera Color
→ UniversalForward 또는 UniversalGBuffer Pass

Motion Vector
→ MotionVectors Pass
```

SubMesh가 여러 개거나 Camera가 여러 개면 작업은 더 늘 수 있다.

```text
대략적인 반복 요인
Camera 수
× 필요한 Render Pass
× SubMesh / Material Slot
× Shadow Light와 Cascade
```

실제 Batching과 Culling 결과에 따라 Draw 수는 달라진다.

---

## Renderer.enabled를 자주 바꿀 때

`Renderer.enabled`로 Visibility를 직접 제어할 수 있다.

```csharp
targetRenderer.enabled = shouldRender;
```

간헐적으로 Object를 숨기는 용도에는 명확하다.

매 Frame 수많은 Renderer를 켜고 끄는 구조는 Culling과 Batch Data 갱신 비용을 만들 수 있으므로 Profiler로 확인해야 한다.

단순히 Camera 밖이라는 이유로 Script가 Renderer를 직접 끄는 것은 Unity의 Frustum Culling과 중복될 수 있다.

---

## Renderer 수와 성능

Renderer가 많으면 Culling과 관리 대상이 늘어난다.

```text
CPU
Bounds Update
Culling Test
Sorting
Draw 준비

GPU
실제로 제출된 SubMesh와 Pass 처리
```

작은 Object를 하나의 큰 MeshRenderer로 합치면 Renderer와 Draw 수를 줄일 수 있다.

하지만 큰 Bounds 때문에 일부만 보여도 전체 Geometry가 Culling을 통과할 수 있다.

Renderer를 합치는 크기는 CPU 관리 비용과 Culling Granularity 사이의 Trade-off다.

---

## Material Slot 수와 성능

하나의 Mesh에 Material Slot이 많으면 SubMesh별 Draw가 늘 수 있다.

```text
Character Renderer
├─ Skin Material
├─ Eye Material
├─ Hair Material
├─ Clothes Material
└─ Accessory Material
```

Texture Atlas와 공통 Shader로 Material을 합칠 가능성을 검토할 수 있다.

하지만 서로 다른 Surface Model, Transparency, Resolution과 Tiling 요구를 억지로 합치면 Memory와 Shader 복잡도가 늘 수 있다.

Material 수만 최소화하지 않고 실제 Draw, Texture Memory와 Visual 요구를 함께 측정한다.

---

## Shared Material과 Batching

여러 Renderer가 같은 Mesh와 Material을 공유하면 Batching 또는 GPU Instancing 후보가 되기 쉽다.

```text
Renderer A ┐
Renderer B ├─ Same Mesh + Same Material
Renderer C ┘
↓
Instancing 또는 Batch 가능성
```

각 Renderer에서 `material`을 접근해 Instance를 만들거나 Keyword와 Render State가 달라지면 Batch가 분리될 수 있다.

동일한 Material 참조만으로 항상 한 Draw가 되는 것은 아니다.

Transform, Lightmap, Shadow, Renderer Property와 Pipeline 조건도 영향을 준다.

---

## SRP Batcher와 Renderer

URP의 SRP Batcher는 호환되는 Shader가 Material Constant Buffer를 효율적으로 유지해 CPU의 Data Binding 비용을 줄이는 구조다.

```text
같은 호환 Shader Variant를 사용하는 Draw
↓
Material Data 설정 비용 감소 가능
```

Renderer 수나 Draw 자체를 무조건 하나로 합치는 기능은 아니다.

SubMesh와 Pass가 여러 개면 필요한 Draw는 남을 수 있다.

Frame Debugger의 SRP Batcher 사유와 CPU Profiler를 함께 확인해야 한다.

---

## Static Batching

움직이지 않는 MeshRenderer는 Static Batching 대상이 될 수 있다.

```text
여러 Static MeshRenderer
↓
Geometry를 Batch 가능한 구조로 준비
↓
Draw 제출 비용 감소 가능
```

Transform이 Runtime에 변하면 Static 가정과 맞지 않는다.

Geometry Memory 증가와 Culling 단위 변화도 고려해야 한다.

많은 Static Object가 있다는 이유만으로 모든 것을 하나의 큰 Batch로 만드는 것이 항상 최선은 아니다.

---

## GPU Instancing

같은 Mesh와 Material을 사용하는 반복 Renderer는 GPU Instancing으로 여러 Transform을 한 번의 Instanced Draw에 전달할 수 있다.

```text
Tree Renderer × 100
Same Mesh
Same Material
↓
Instance Transform Data
↓
Instanced Draw
```

Material에서 GPU Instancing을 지원하고 Shader에 필요한 Instance Macro와 Variant가 있어야 한다.

Renderer별 Data가 Instancing Buffer로 표현할 수 없는 방식으로 달라지면 Batch가 나뉠 수 있다.

실제 Batch 수는 Frame Debugger로 확인한다.

---

## Dynamic Batching

작은 Mesh를 CPU에서 결합해 Draw 수를 줄이는 Dynamic Batching 경로가 있을 수 있다.

하지만 Vertex Attribute 수, Transform, Material과 Render Pipeline 제약을 받는다.

현대 Platform에서는 CPU 변환 비용과 SRP Batcher 또는 GPU Instancing의 이점을 비교해야 한다.

Project 설정에서 기능을 켰다는 사실만으로 모든 MeshRenderer가 Batch되는 것은 아니다.

---

## Skinned Mesh 성능

SkinnedMeshRenderer는 일반 MeshRenderer 외에 Skinning 비용을 가진다.

```text
비용에 영향을 주는 요소
Vertex 수
Vertex당 Bone Influence 수
활성 Bone 수
Blend Shape 수와 활성 Weight
Renderer 수
Shadow Pass 수
Update When Offscreen
```

Character가 Camera 밖에서도 Update될 필요가 없다면 Offscreen Update를 끄는 기본 설정이 유리할 수 있다.

반대로 Ragdoll이나 Gameplay Bone을 계속 갱신해야 하면 시각적 정확성과 CPU·GPU 비용을 함께 측정한다.

---

## Renderer 문제 진단 순서

Mesh가 보이지 않을 때 다음 순서로 확인할 수 있다.

```text
1. GameObject activeInHierarchy
↓
2. Renderer.enabled
↓
3. MeshFilter.sharedMesh 또는 SkinnedMeshRenderer.sharedMesh
↓
4. Renderer Material Slot
↓
5. Camera Culling Mask와 Object Layer
↓
6. Renderer Bounds와 Frustum
↓
7. Render Queue와 Shader Pass
↓
8. Cull / Depth / Stencil / Alpha Clip
```

Skinned Mesh만 사라진다면 Bone, Root Bone, localBounds와 Update When Offscreen도 확인한다.

---

## Frame Debugger에서 Renderer 확인하기

Frame Debugger의 Draw Event에서 다음 관계를 확인할 수 있다.

```text
Camera
↓
Render Pass
↓
Renderer Object
↓
Mesh와 SubMesh
↓
Material
↓
Shader Pass와 Variant
```

같은 Renderer 이름이 Shadow, Depth와 Opaque Event에 반복되는지 확인할 수 있다.

예상보다 Draw가 많으면 Material Slot, 추가 Pass, Camera와 Shadow Cascade를 조사한다.

---

## 코드에서 Renderer를 Cache하기

매 Frame `GetComponent`를 반복하기보다 초기화 시 Renderer 참조를 Cache할 수 있다.

```csharp
using UnityEngine;

public class RendererVisibility : MonoBehaviour
{
    private Renderer targetRenderer;

    private void Awake()
    {
        targetRenderer = GetComponent<Renderer>();
    }

    public void SetVisible(bool visible)
    {
        targetRenderer.enabled = visible;
    }
}
```

하지만 Renderer 접근 비용보다 Rendering 자체가 병목인 경우가 많다.

Profiler에서 실제 Script 호출 빈도와 Rendering 비용을 확인한 뒤 최적화한다.

---

## 자주 혼동하는 내용

### MeshRenderer가 Mesh Data를 보관한다?

일반 Mesh의 실제 참조는 같은 GameObject의 MeshFilter가 보관한다.

MeshRenderer는 그 Mesh를 Material 및 Rendering 설정과 연결한다.

### Material Slot 하나는 Renderer 하나다?

아니다.

Renderer 하나가 여러 Material Slot과 SubMesh를 가질 수 있으며 각 조합이 별도 Draw 작업을 만들 수 있다.

### sharedMaterial을 바꾸면 해당 Object만 바뀐다?

공유 Material Asset의 Property를 수정하면 그 Material을 사용하는 다른 Renderer에도 영향을 줄 수 있다.

### renderer.material은 무료 복사본이다?

아니다.

개별 Material Instance가 생성되어 Memory와 Batching에 영향을 줄 수 있다.

### SkinnedMeshRenderer도 MeshFilter가 필요하다?

아니다.

SkinnedMeshRenderer가 자체 `sharedMesh`, Bone과 Blend Shape 정보를 가진다.

### Update When Offscreen을 켜면 Culling 비용이 사라진다?

아니다.

화면 밖에서도 Skinning과 Bounds Update를 계속할 수 있어 오히려 Update 비용이 증가할 수 있다.

### Renderer 하나는 Frame마다 한 번만 그려진다?

아니다.

SubMesh, Shadow, Depth, Camera Color, Motion Vector와 여러 Camera 때문에 반복될 수 있다.

---

## 전체 Data 관계

일반 Mesh Rendering의 관계를 다시 연결하면 다음과 같다.

```text
GameObject
├─ Transform
├─ MeshFilter
│  └─ Mesh
└─ MeshRenderer
   ├─ Materials
   │  └─ Shader + Properties
   ├─ Bounds
   ├─ Shadow 설정
   ├─ Probe 설정
   └─ Rendering Layer
       ↓
Camera Culling
↓
Render Pass Filtering
↓
SubMesh + Material
↓
Shader Pass + Variant
↓
Draw Command
```

변형 Mesh는 MeshFilter와 MeshRenderer 대신 SkinnedMeshRenderer가 Mesh, Bones, Blend Shape와 Rendering 설정을 함께 제공한다.

---

## 정리

Renderer Component는 Geometry, Material, Transform과 Rendering 설정을 Unity Render Pipeline에 연결하는 Scene 측 단위다.

일반 Mesh에서는 MeshFilter가 Mesh 참조를 제공하고 MeshRenderer가 그 Mesh를 Materials와 Shadow·Probe 설정으로 Rendering한다.

```text
MeshFilter.sharedMesh
+ MeshRenderer Materials
+ Transform
↓
Renderer Bounds와 설정
↓
Camera Culling
↓
Draw Candidate
```

Mesh의 각 SubMesh는 Renderer의 Material Slot과 대응하며 SubMesh와 Material 조합마다 별도 Draw 작업이 필요할 수 있다.

`sharedMaterial`은 여러 Renderer가 공유하는 Asset이며 `material` 접근은 개별 Instance를 만들 수 있어 Memory와 Batching에 영향을 준다.

Renderer별 작은 Property 차이는 MaterialPropertyBlock을 검토할 수 있지만 SRP Batcher 및 Instancing과의 실제 결과를 측정해야 한다.

SkinnedMeshRenderer는 MeshFilter 없이 Bone Skinning, Blend Shape와 Cloth로 변형되는 Mesh를 관리하며 Bounds와 Offscreen Update 비용을 추가로 고려해야 한다.

Renderer 하나도 Shadow, Depth, Camera Color, Motion Vector와 여러 Camera에서 반복 Rendering될 수 있으므로 Renderer 수만으로 Draw 수를 판단하지 않는다.

Frame Debugger와 Profiler에서 Renderer가 어떤 SubMesh, Material, Shader Pass로 몇 번 처리되는지 확인한 뒤 목표 Device의 병목에 맞게 최적화해야 한다.
