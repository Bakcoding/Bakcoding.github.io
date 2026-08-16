---
title: "[Unity 렌더링] 5-7. Sorting은 어떻게 이루어질까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - Sorting
  - OpaqueSorting
  - TransparentSorting
permalink: /programming/unity-5-7-sorting/
toc: true
toc_sticky: true
date: 2026-08-15
last_modified_at: 2026-08-15
---

Render Queue는 Renderer를 Opaque와 Transparent 같은 큰 순서 Group으로 나눈다.

하지만 같은 Geometry Queue에 Object가 수천 개 있거나 같은 Transparent Queue에 유리가 여러 장 있다면 Group 안의 순서도 정해야 한다.

```text
Render Queue로 큰 Group 분류
↓
각 Queue 내부 Renderer Sorting
↓
정렬된 순서로 Draw
```

Opaque는 가까운 Surface의 Depth를 먼저 기록해 뒤의 Fragment를 제거하고 State 변경도 줄이는 방향이 유리하다.

Transparent는 뒤 Color와 Blend해야 하므로 일반적으로 먼 Object부터 가까운 Object 순서가 필요하다.

Sorting은 Rendering 정확성과 CPU·GPU 효율 사이에서 Draw 순서를 만드는 과정이다.

---

## Sorting이란?

Sorting은 Camera Culling과 Render Queue Filtering을 통과한 Renderer의 Draw 순서를 결정하는 과정이다.

```text
Visible Renderer
↓
Render Queue Range Filter
↓
Sorting Key 계산
↓
Renderer 정렬
↓
Draw Command 기록
```

Sorting Key에는 Pipeline에 따라 다음 정보가 포함될 수 있다.

```text
Render Queue
Sorting Layer
Order in Layer
Camera Distance
Shader와 Material State
Renderer Priority
Canvas 또는 Sorting Group 관계
```

모든 Renderer Type과 Render Pipeline이 완전히 같은 우선순위를 사용하는 것은 아니다.

---

## 왜 하나의 Sorting 방식만 사용하지 않을까?

Opaque와 Transparent는 Color를 만드는 방식이 다르다.

```text
Opaque
가장 가까운 Surface가 Color를 결정
Depth Write 가능

Transparent
여러 Surface Color를 순서대로 Blend
Depth Write를 끄는 경우가 많음
```

Opaque는 정확한 Color 결과가 Draw 순서에 덜 민감하다.

Depth Buffer가 최종적으로 가장 가까운 Surface를 남기기 때문이다.

Transparent는 같은 Surface도 순서가 바뀌면 Blend 결과가 달라질 수 있다.

```text
Opaque Sorting 목표
성능 중심

Transparent Sorting 목표
Blend 정확성 중심
```

---

## Sorting이 적용되는 위치

한 Frame에서 Sorting은 Camera와 Render Pass마다 수행될 수 있다.

```text
Camera A
├─ Shadow Caster Sorting
├─ Opaque Sorting
└─ Transparent Sorting

Camera B
├─ Opaque Sorting
└─ Transparent Sorting
```

같은 Renderer라도 Camera Position이 다르면 Distance가 달라 정렬 순서도 달라질 수 있다.

Shadow Map은 Camera Color와 다른 Light 관점과 Sorting Criteria를 사용할 수 있다.

---

## Render Queue가 먼저다

Sorting은 일반적으로 Render Queue Group을 무시하고 모든 Object를 Distance 하나로만 섞지 않는다.

```text
Queue 2000 Opaque
↓
Queue 2450 AlphaTest
↓
Queue 3000 Transparent
```

Queue 2000의 먼 Opaque Object는 Queue 3000의 가까운 Transparent Object보다 먼저 그려진다.

```text
1차 기준
Render Queue

2차 기준
Queue 내부 Sorting
```

Material Queue Offset은 Sorting Key의 큰 앞부분을 바꾸므로 Distance보다 강한 순서 차이를 만들 수 있다.

---

## Opaque Sorting

Opaque Queue는 일반적으로 Front-to-back 방향과 Render State 효율을 함께 고려해 정렬한다.

```text
Camera
↓
Near Opaque
↓
Middle Opaque
↓
Far Opaque
```

가까운 Object가 먼저 Depth를 기록하면 뒤의 Fragment를 Early Depth Test에서 제거할 가능성이 커진다.

```text
Near Draw
Depth Buffer = Near Depth
↓
Far Draw
Depth Test 실패
↓
Far Fragment 작업 감소 가능
```

이를 Front-to-back Sorting이라고 한다.

---

## Front-to-back이 유리한 이유

화면 전체를 덮는 가까운 벽과 그 뒤의 복잡한 방을 가정한다.

```text
Camera → Wall → Furniture × 100
```

벽을 먼저 그리면 뒤 Furniture의 많은 Fragment가 Depth에서 제거될 수 있다.

```text
Wall 먼저
↓
Depth 채움
↓
Furniture Fragment Early Reject
```

반대로 Furniture를 모두 그린 뒤 벽을 그리면 최종 화면에는 벽만 보여도 뒤의 Fragment Shader가 이미 실행되었을 수 있다.

Opaque Sorting은 Overdraw를 줄여 GPU Fragment 비용을 낮추는 데 도움을 준다.

---

## Opaque Sorting과 State 변경

오직 Distance만 기준으로 정렬하면 Material과 Shader가 번갈아 나타날 수 있다.

```text
Near Lit A
Near Unlit B
Middle Lit C
Far Unlit D
```

이 순서는 Depth에는 유리하지만 Shader Pass State 전환이 많을 수 있다.

```text
Lit → Unlit → Lit → Unlit
```

Material과 Shader State를 기준으로 모으면 SetPass Call과 CPU Setup 비용을 줄일 수 있다.

```text
Lit A → Lit C → Unlit B → Unlit D
```

URP는 Opaque Sorting에서 Depth 효율과 State 변경 감소를 함께 고려할 수 있다.

---

## Opaque Sorting의 Trade-off

두 목표는 충돌할 수 있다.

```text
Front-to-back 우선
GPU Overdraw 감소 가능
State 변경 증가 가능

Material State 우선
CPU SetPass 감소 가능
GPU Overdraw 증가 가능
```

어느 쪽이 더 중요한지는 병목에 따라 달라진다.

```text
CPU Bound
State Sorting 이점이 클 수 있음

GPU Fragment Bound
Front-to-back 이점이 클 수 있음
```

Pipeline의 기본 Sorting을 임의로 바꾸기 전에 목표 Device에서 CPU와 GPU 시간을 측정한다.

---

## Opaque는 순서가 달라도 같은 결과인가?

일반적인 Opaque Surface가 같은 Depth Test와 Write를 사용하면 최종 Color는 가장 가까운 Surface가 남는다.

```text
Far 먼저 → Near 나중
최종 Near

Near 먼저 → Far Depth 실패
최종 Near
```

하지만 다음 경우에는 순서가 결과에 영향을 줄 수 있다.

```text
ZWrite Off
특수 Blend
Stencil Side Effect
동일하거나 매우 가까운 Depth
Shader의 Framebuffer Read
Order-dependent Custom Pass
```

Queue가 Opaque라고 모든 Shader가 순서 독립적이라고 가정하면 안 된다.

---

## AlphaTest Sorting

AlphaTest Queue는 Index 2450으로 Opaque 범위에 속한다.

Alpha Clip으로 일부 Pixel을 제거하지만 살아남은 Fragment는 Depth를 기록할 수 있다.

```text
Solid Opaque 먼저
↓
AlphaTest Foliage
↓
Transparent
```

AlphaTest Geometry를 일반 Solid Geometry 뒤에 그리면 이미 가려진 영역의 복잡한 Alpha Sampling과 Clip 작업을 줄일 가능성이 있다.

Queue 내부에서는 Opaque 계열 Sorting Criteria를 사용할 수 있다.

---

## Transparent Sorting

일반 Alpha Blend Transparent는 Back-to-front로 정렬한다.

```text
Camera
↓
Near Glass
↓
Middle Smoke
↓
Far Particle

Draw 순서
Far Particle
→ Middle Smoke
→ Near Glass
```

먼 Surface를 먼저 Background 위에 Blend하고 가까운 Surface를 마지막에 Blend해야 Layer 관계가 자연스럽다.

```text
Destination Color
↓ Far Blend
↓ Near Blend
Final Color
```

---

## Blend 순서가 결과를 바꾸는 이유

일반 Alpha Blend를 단순화하면 다음과 같다.

```text
Result = Source × Alpha
       + Destination × (1 - Alpha)
```

Red와 Blue Layer를 같은 Alpha로 Blend해도 순서가 다르면 Result가 달라진다.

```text
Background → Blue → Red
≠
Background → Red → Blue
```

Blend 연산은 일반적으로 교환 법칙이 성립하지 않는다.

그래서 Transparent는 Material State를 모으는 것보다 Depth 순서를 우선해야 할 수 있다.

---

## Transparent는 왜 Front-to-back을 사용하지 않을까?

가까운 Transparent를 먼저 그리고 ZWrite를 끄면 뒤의 Transparent도 그려지지만 Blend Layer 순서가 반대가 된다.

```text
Near Glass 먼저
↓
Far Smoke가 나중에 Near 위로 Blend
↓
Far Object가 앞에 있는 것처럼 보일 수 있음
```

ZWrite를 켜면 Near Glass 뒤의 Smoke가 Depth Test에서 사라져 반투명 Layer 자체가 누락될 수 있다.

일반 Alpha Blend에서는 Back-to-front가 가장 단순한 접근이다.

---

## Camera Distance는 어느 점을 기준으로 할까?

Renderer Sorting은 모든 Pixel의 실제 Depth를 비교하는 것이 아니라 Renderer를 대표하는 한 Distance 값을 사용한다.

```text
Renderer A Bounds / Sort Point
→ Camera Distance A

Renderer B Bounds / Sort Point
→ Camera Distance B
```

대표점은 Renderer Type과 Sorting 설정에 따라 Bounds Center, Transform Position 또는 Sprite Sort Point와 관련될 수 있다.

하나의 큰 Mesh가 Camera 앞뒤로 길게 늘어나 있어도 Distance 값은 하나다.

이 근사 때문에 Transparent Sorting Artifact가 생긴다.

---

## Renderer 단위 Sorting의 한계

두 개의 큰 Transparent Quad가 서로 교차한다고 가정한다.

```text
Quad A의 왼쪽은 앞
Quad B의 오른쪽은 앞
```

Object 전체에 대해 다음 중 하나만 선택할 수 있다.

```text
A 전체 먼저, B 전체 나중
또는
B 전체 먼저, A 전체 나중
```

화면 모든 위치에 맞는 하나의 Renderer 순서가 존재하지 않는다.

Renderer Distance Sorting만으로 교차 Transparency를 완벽히 해결할 수 없는 이유다.

---

## Mesh 내부 Triangle Sorting의 한계

하나의 Transparent Mesh 안에도 Triangle이 여러 개 있다.

```text
Transparent Sphere Mesh
앞면 Triangle
뒷면 Triangle
```

Renderer Sorting은 Mesh 사이의 Draw 순서를 정할 뿐 하나의 Index Buffer 내부 Triangle을 Camera마다 Back-to-front로 자동 재정렬하지 않는다.

Cull Off인 Glass Mesh에서는 앞면과 뒷면 순서가 잘못되어 Artifact가 보일 수 있다.

```text
대응 후보
Backface와 Frontface를 별도 Pass로 Drawing
Mesh 분리
Alpha Clip 또는 Dither
Depth Prepass
Order-independent Transparency
```

각 방법은 추가 Draw, Memory와 품질 Trade-off가 있다.

---

## Transparency Sort Mode

Unity Camera 또는 Project 설정은 Transparent Distance를 계산하는 Mode를 가질 수 있다.

대표적인 개념은 다음과 같다.

```text
Perspective
Camera Position에서 Renderer까지의 거리

Orthographic
Camera Forward 방향을 따른 거리

Custom Axis
지정한 World Axis를 따라 계산한 값
```

3D Perspective Game과 2D Side View, Isometric Game은 적절한 Distance Metric이 다르다.

URP 2D Renderer에서는 관련 설정 위치가 2D Renderer Asset에 있을 수 있다.

---

## Perspective Sort Mode

Perspective Camera에서는 Camera Position에서 Object의 대표점까지의 거리를 사용할 수 있다.

```text
Camera Position C
Renderer Position P

Distance ≈ |P - C|
```

Camera를 중심으로 한 구 형태의 Distance 관계가 된다.

화면 가장자리의 Object도 Camera Position과의 실제 공간 거리에 따라 정렬된다.

일반적인 3D Perspective Scene에 적합하다.

---

## Orthographic Sort Mode

Orthographic Camera는 거리에 따라 Object 크기가 작아지지 않는다.

Camera Forward 축을 따른 깊이가 Layer 관계에 더 적합할 수 있다.

```text
Camera Forward →

Object A Depth 2
Object B Depth 5
```

Camera Position까지의 Euclidean Distance를 쓰면 화면 좌우로 멀리 있는 Object가 깊이도 멀다고 잘못 해석될 수 있다.

Orthographic Mode는 View 방향의 Depth 관계를 중심으로 Sorting한다.

---

## Custom Axis Sort Mode

Custom Axis는 지정한 World 방향을 따라 Renderer의 순서를 계산한다.

```text
Custom Axis = (0, 1, 0)
→ World Y 위치 중심 Sorting
```

Top-down 또는 Isometric 2D Game에서 아래쪽에 있는 Character를 위쪽 Tile보다 앞에 보이게 만들 때 사용할 수 있다.

```text
Y가 높은 Object
화면상 뒤쪽

Y가 낮은 Object
화면상 앞쪽
```

Axis는 Project의 World 방향과 Art 규칙에 맞게 설정해야 한다.

---

## Custom Axis 예제

Project Settings 또는 Camera API를 통해 Transparency Sort Mode와 Axis를 지정할 수 있다.

```csharp
using UnityEngine;

public class TransparencySortSetup : MonoBehaviour
{
    [SerializeField] private Camera targetCamera;

    private void Awake()
    {
        targetCamera.transparencySortMode =
            TransparencySortMode.CustomAxis;

        targetCamera.transparencySortAxis =
            new Vector3(0f, 1f, 0f);
    }
}
```

이 설정은 Transparent Renderer의 Distance 비교 기준을 바꾼다.

Render Queue, Sorting Layer와 Order in Layer가 사라지는 것은 아니다.

---

## Sorting Layer란?

Sorting Layer는 주로 Sprite와 2D Renderer Group의 Drawing 우선순위를 명시적으로 나누는 Layer다.

```text
Sorting Layer
├─ Background
├─ Ground
├─ Character
├─ Effects
└─ UI World
```

Project Settings의 Sorting Layers 목록 순서가 상대적인 Rendering 순서를 나타낸다.

```text
낮은 Sorting Layer
먼저 Drawing

높은 Sorting Layer
나중에 Drawing
```

`Default` Sorting Layer는 항상 존재한다.

---

## Sorting Layer는 GameObject Layer와 다르다

두 Layer는 이름이 비슷하지만 목적이 다르다.

```text
GameObject Layer
Camera Culling Mask
Physics Collision
Raycast Filtering

Sorting Layer
Renderer의 Drawing 순서
```

GameObject Layer를 `Player`로 바꾼다고 Sprite가 배경 위에 자동으로 그려지지 않는다.

반대로 Sorting Layer를 바꿔도 Camera Culling Mask 포함 여부는 달라지지 않는다.

---

## Sorting Layer ID와 Value

Sorting Layer는 내부 ID와 실제 상대 순서를 나타내는 Value를 가진다.

```text
SortingLayer.id
고유 식별자

SortingLayer.value
상대적인 Sort Order 값
```

ID는 연속된 순서 숫자가 아니므로 ID 크기를 직접 비교해 Layer 순서를 판단하면 안 된다.

```csharp
int layerId = SortingLayer.NameToID("Character");
int layerValue = SortingLayer.GetLayerValueFromID(layerId);
```

실제 순서 비교에는 Layer Value를 사용한다.

---

## Order in Layer

같은 Sorting Layer 안에서는 `Order in Layer`로 세부 순서를 정할 수 있다.

```text
Sorting Layer = Character

Shadow Sprite       Order = 0
Body Sprite         Order = 10
Weapon Back Sprite  Order = 20
Weapon Front Sprite Order = 30
```

낮은 값이 먼저 Drawing되고 높은 값이 나중에 그려져 위에 나타날 수 있다.

```csharp
SpriteRenderer spriteRenderer = GetComponent<SpriteRenderer>();
spriteRenderer.sortingLayerName = "Character";
spriteRenderer.sortingOrder = 20;
```

Depth Test와 Material Shader 설정이 일반적인 Sprite 흐름과 다르면 결과도 달라질 수 있다.

---

## 2D Transparent Sorting 우선순위

Unity 6 2D Renderer 문서는 Transparent Queue의 2D Renderer가 대체로 다음 우선순위를 따른다고 설명한다.

```text
1. Sorting Layer와 Order in Layer
2. 지정된 Render Queue
3. Camera Distance
4. Sorting Group
5. Material / Shader
6. 내부 Tiebreaker
```

Project와 Renderer 설정에 따라 예외가 있을 수 있다.

순서가 반드시 중요하다면 내부 Tiebreaker에 의존하지 않고 명시적인 Sorting Layer와 Order를 부여한다.

---

## Sprite Sort Point

SpriteRenderer는 Distance Sorting에 사용할 Sort Point를 Center 또는 Pivot으로 선택할 수 있다.

```text
Center
Sprite Bounds Center 기준

Pivot
Sprite Editor의 Pivot 기준
```

Top-down Character는 발 위치를 Pivot으로 두면 바닥 Object와의 Y Sorting이 자연스러울 수 있다.

```text
큰 Character Sprite
Center 기준 → 몸 중앙으로 순서 계산
Foot Pivot 기준 → 바닥 접점으로 계산
```

Art Asset의 Pivot 규칙을 일관되게 유지해야 한다.

---

## Sorting Group

Sorting Group은 여러 Child Renderer를 하나의 Sorting 단위처럼 묶는다.

```text
Character Root + SortingGroup
├─ Body Sprite
├─ Hair Sprite
├─ Weapon Sprite
└─ Effect Sprite
```

그룹 내부 Renderer는 자신의 Sorting Layer와 Order를 기준으로 정렬된다.

다른 Character와 비교할 때는 전체 Group이 하나의 단위처럼 취급된다.

```text
Character A 내부 순서 유지
Character B 내부 순서 유지
↓
Group A와 Group B의 앞뒤 결정
```

---

## Sorting Group이 필요한 이유

두 Character가 각각 Body와 Weapon Sprite를 가진다고 가정한다.

Sorting Group이 없으면 모든 Sprite가 전역으로 섞여 정렬될 수 있다.

```text
Character A Body
Character B Body
Character A Weapon
Character B Weapon
```

두 Character가 겹칠 때 한 Character의 Body와 Weapon 사이에 다른 Character가 끼어 보일 수 있다.

Sorting Group은 Character 내부 Layer 관계를 유지하면서 Character 전체의 앞뒤를 정한다.

---

## Sorting Group 내부 Sorting

같은 Sorting Group의 Renderer는 Sorting Layer와 Order in Layer 등으로 내부 순서를 정한다.

그룹 내부 정렬에서는 각 Child Renderer의 Camera Distance를 독립적으로 비교하지 않고 Group Root의 Distance를 전체 Group에 사용할 수 있다.

```text
Group Root Distance
↓
다른 Group과 비교

Group 내부
Sorting Layer + Order 중심
```

이 구조 덕분에 Animation으로 Child Sprite가 움직여도 Character 내부 순서가 다른 Character와 섞이지 않는다.

---

## Nested Sorting Group

Sorting Group 안에 또 다른 Sorting Group을 둘 수 있다.

```text
Character Sorting Group
├─ Body
├─ Weapon Sorting Group
│  ├─ Weapon Back
│  └─ Weapon Front
└─ Effects
```

가장 안쪽 Group의 내부 순서를 먼저 계산한 뒤 Parent Group의 다른 Renderer와 비교한다.

`Sort At Root` 같은 설정은 Nested Group이 Parent를 무시하고 Root Level에서 정렬되도록 할 수 있다.

복잡한 Hierarchy에서는 Frame Debugger로 실제 순서를 확인한다.

---

## Particle Sorting

ParticleSystemRenderer도 Transparent Queue와 Sorting 설정의 영향을 받는다.

```text
Particle System끼리
Renderer Distance와 Sorting Fudge 등

Particle 내부
Particle Sort Mode
```

하나의 Particle System 안의 Particle을 Distance, Youngest, Oldest 등으로 정렬할 수 있는 설정이 있다.

Particle 수가 많으면 내부 Sorting CPU 또는 GPU 비용이 커질 수 있다.

Additive Particle처럼 순서 영향이 작은 경우 Sorting을 줄일 가능성을 검토한다.

Sorting Group 안의 Particle은 일부 독립 Sorting 보정 값이 무시될 수 있다.

---

## Canvas Sorting

Canvas는 Render Mode와 Override Sorting 설정에 따라 별도의 Sorting 구조를 가진다.

```text
Screen Space Overlay
화면 UI 출력 순서

Screen Space Camera
Camera와 Plane Distance, Sorting 관계

World Space
Scene Renderer처럼 공간에 배치
```

Canvas의 Sorting Layer와 Order는 다른 Canvas 및 Renderer와의 순서를 조정할 수 있다.

UI Graphic 내부 순서는 Hierarchy와 Canvas Batch 구성의 영향을 받는다.

일반 MeshRenderer Transparent Sorting과 완전히 같은 규칙으로 단순화하지 않는다.

---

## Sorting Criteria란?

Scriptable Render Pipeline은 `SortingSettings`와 `SortingCriteria`로 Renderer Sorting 방식을 지정할 수 있다.

```csharp
SortingSettings sortingSettings = new SortingSettings(camera)
{
    criteria = SortingCriteria.CommonOpaque
};
```

대표적인 조합은 다음과 같다.

```text
CommonOpaque
Opaque에 적합한 일반 Sorting Criteria 조합

CommonTransparent
Transparent에 적합한 일반 Sorting Criteria 조합
```

Custom Render Pass에서 `DrawRenderers`를 호출할 때 DrawingSettings에 Sorting 설정을 전달한다.

---

## SortingCriteria의 구성 요소

Sorting Criteria는 Flag 조합으로 여러 기준을 표현할 수 있다.

대표적인 개념은 다음과 같다.

```text
SortingLayer
RenderQueue
BackToFront
QuantizedFrontToBack
OptimizeStateChanges
CanvasOrder
RendererPriority
```

정확한 Flag 조합과 지원은 Unity Version의 API 문서를 확인해야 한다.

`CommonOpaque`와 `CommonTransparent`를 사용하면 Render Pipeline의 일반적인 의도에 맞는 조합을 사용할 수 있다.

Custom Criteria는 결과와 성능을 모두 검증해야 한다.

---

## CommonOpaque

`CommonOpaque`는 Opaque Renderer에 적합한 Queue, Front-to-back와 State 최적화 기준을 조합한다.

```text
Opaque Filtering
↓
Queue 기준
+ State 변경 최적화
+ Quantized Front-to-back
↓
Draw
```

`Quantized` Front-to-back은 Distance를 완전한 연속 정밀도로만 정렬하지 않고 구간화하여 State Sorting과 균형을 잡을 수 있다.

Pipeline 내부 구현에 따라 세부 결과가 달라질 수 있다.

---

## CommonTransparent

`CommonTransparent`는 Transparent Renderer에 필요한 Sorting Layer, Queue와 Back-to-front Distance 등을 조합한다.

```text
Transparent Filtering
↓
Sorting Layer
↓
Render Queue
↓
Back-to-front Distance
↓
State와 Tiebreaker
```

Blend 정확성을 위해 Distance 기준의 우선도가 높다.

그래도 같은 Distance 또는 명시적 Layer에서는 Material State 정렬이 일부 적용될 수 있다.

정확한 우선순위는 Renderer Type과 Pipeline 설정을 확인한다.

---

## Custom Render Pass의 Sorting

Custom SRP 또는 URP Renderer Feature에서 Object를 그릴 때 Opaque와 Transparent에 같은 Criteria를 사용하면 문제가 생길 수 있다.

```csharp
SortingCriteria criteria = isOpaque
    ? SortingCriteria.CommonOpaque
    : SortingCriteria.CommonTransparent;
```

Opaque Object를 Back-to-front로 그리면 Overdraw가 늘 수 있다.

Transparent Object를 Front-to-back로 그리면 Blend 결과가 잘못될 수 있다.

Filtering의 RenderQueueRange와 Sorting Criteria를 같은 Surface 목적에 맞춘다.

---

## Sorting과 Batching

Sorting은 같은 Material과 Shader State를 가까이 배치해 Batching과 SRP Batcher 효율을 높일 수 있다.

```text
정렬 전
Material A
Material B
Material A
Material B

정렬 후
Material A
Material A
Material B
Material B
```

Opaque에서는 이 최적화가 비교적 자유롭다.

Transparent에서는 Back-to-front 순서를 유지해야 하므로 Material을 모으기 어렵다.

Transparent Material 종류가 많으면 SetPass Call이 늘 수 있다.

---

## Sorting의 CPU 비용

Visible Renderer가 많으면 Sorting Key 생성과 정렬 자체에도 CPU 시간이 든다.

```text
Visible Renderer 수 N
↓
Key 계산
↓
Sort
↓
Draw Command 생성
```

일반 비교 Sort의 계산 복잡도를 단순하게 `N log N`으로 생각할 수 있지만 Unity 내부 알고리즘과 병렬화는 구현에 따라 다르다.

Culling으로 후보 수를 줄이고 Camera가 필요 없는 Layer를 제외하면 Sorting 대상도 줄어든다.

---

## Sorting과 GPU 비용

Sorting 자체는 CPU 작업이지만 Draw 순서가 GPU 효율을 바꾼다.

```text
Opaque Front-to-back
→ Early-Z 효율 증가 가능

State Sorting
→ Pipeline State 전환 감소

Transparent Back-to-front
→ 정확한 Blend
→ Overdraw는 유지될 수 있음
```

잘못된 Opaque 순서는 Fragment Overdraw를 늘리고 잘못된 Transparent 순서는 시각적 Artifact를 만든다.

CPU Sorting 시간을 줄이기 위해 순서를 제거하면 GPU와 결과에 더 큰 문제가 생길 수 있다.

---

## Renderer Priority

일부 Renderer와 Pipeline은 같은 Queue 안에서 Renderer Priority를 Sorting 기준으로 사용할 수 있다.

```text
Queue와 Distance가 비슷한 Renderer
↓
Priority 값으로 순서 조정
```

URP Material Inspector의 Priority나 Queue Offset과 이름이 비슷한 설정이 있을 수 있다.

어떤 단계의 Sort Key에 반영되는지 사용하는 Shader와 Renderer 문서를 확인한다.

명시적 Priority는 필요한 관계에만 사용한다.

---

## Sorting Fudge

Particle System에는 Camera Distance Sorting을 보정하는 `sortingFudge`가 있다.

```text
기본 Distance
+ Sorting Fudge
↓
다른 Transparent Renderer와 순서 조정
```

여러 Particle Effect의 앞뒤를 미세 조정할 수 있지만 Object가 Camera 주위를 이동하면 고정 보정이 모든 상황에 맞지 않을 수 있다.

Sorting Group 안에서는 Particle Sorting Fudge가 내부 정렬에 사용되지 않을 수 있다.

---

## 동일한 Sorting Key

두 Renderer의 Queue, Sorting Layer, Order, Distance와 Material 기준이 모두 같을 수 있다.

이 경우 Unity 내부 Tiebreaker가 순서를 결정할 수 있다.

```text
Renderer A Key = X
Renderer B Key = X
↓
내부 순서
```

이 내부 순서에 의존하면 Unity Version, Scene 변화 또는 Build Platform에서 결과가 달라질 수 있다.

순서가 시각적으로 중요하면 Order in Layer, Queue 또는 Geometry 구조로 명시적인 차이를 만든다.

---

## Z-fighting은 Sorting 문제인가?

같거나 매우 가까운 Depth의 Opaque Surface가 번갈아 보이는 현상은 주로 Depth Precision 문제다.

```text
Surface A Depth ≈ Surface B Depth
↓
Depth Buffer가 안정적으로 구분하지 못함
↓
Z-fighting
```

Draw 순서를 고정하면 일부 상황에서 한쪽이 남을 수 있지만 Camera와 Platform 전체에서 안정적인 해결은 아니다.

Geometry 간격, Near·Far Plane, Depth Bias와 Decal 방식을 검토한다.

Sorting과 Depth Precision을 구분해야 한다.

---

## Sorting으로 Transparency가 완벽해지지 않는 이유

정확한 Alpha Compositing에는 Pixel마다 모든 Transparent Fragment의 Depth 순서가 필요하다.

```text
Pixel A
Object 1 → Object 2

Pixel B
Object 2 → Object 1
```

Renderer 단위 Sorting은 Object 전체에 하나의 순서만 부여한다.

교차 Surface에서는 Pixel마다 필요한 순서가 달라 하나의 목록으로 표현할 수 없다.

이 한계를 해결하려면 Order-independent Transparency 같은 더 복잡한 Technique가 필요할 수 있다.

Memory, Multiple Pass와 Platform 비용을 고려한다.

---

## Depth Prepass를 이용한 Transparent

Transparent Geometry의 Depth를 먼저 기록하고 Color Pass에서 가까운 Surface만 Blend하는 방식을 사용할 수 있다.

```text
Transparent Depth Pass
가장 가까운 Surface Depth 기록
↓
Transparent Color Pass
Depth와 맞는 Surface Blend
```

Self-overlap Artifact를 줄일 수 있지만 뒤 Transparent Layer가 사라지고 추가 Draw가 생길 수 있다.

정확한 다층 Transparency 해결책은 아니다.

Glass, Hair와 Particle의 요구에 맞게 선택한다.

---

## Two-pass Transparent

닫힌 Transparent Mesh의 Back Face를 먼저, Front Face를 나중에 그릴 수 있다.

```text
Pass 1
Cull Front
Back Faces Draw

Pass 2
Cull Back
Front Faces Draw
```

단일 Mesh의 앞·뒤 순서를 개선할 수 있다.

하지만 다른 Transparent Object와의 교차, Mesh 내부 복잡한 Self-intersection은 남는다.

Draw Call과 SetPass 비용도 증가한다.

---

## Alpha Clip과 Dither로 Sorting 줄이기

부드러운 Transparency가 반드시 필요하지 않다면 Alpha Clip으로 Pixel을 완전히 유지하거나 제거할 수 있다.

```text
Alpha Blend
다층 Sorting과 Overdraw

Alpha Clip
Depth Write 가능
Opaque Sorting 활용
```

Dither Pattern과 Temporal Anti-Aliasing을 결합해 반투명처럼 보이게 만들 수도 있다.

Pattern Noise, Edge Flicker와 TAA 의존성이 생길 수 있다.

Foliage, Hair와 Fade Effect에서 목표 Platform 품질을 비교한다.

---

## Camera가 움직이면 Sorting이 바뀐다

Transparent Distance는 Camera 위치와 방향을 사용한다.

```text
Frame N
A가 B보다 멂
→ A 먼저

Frame N+1
Camera가 이동
B가 A보다 멂
→ B 먼저
```

두 Object의 Distance가 비슷하면 순서가 Frame마다 바뀌며 Popping처럼 보일 수 있다.

명확한 Layer 관계가 있다면 Sorting Layer, Order 또는 Mesh 구조로 안정적인 우선순위를 부여한다.

---

## Bounds가 Sorting에 미치는 영향

Renderer Distance가 Bounds Center와 관련되어 계산되면 Bounds가 비정상적으로 크거나 이동했을 때 순서도 예상과 달라질 수 있다.

```text
실제 Visible Geometry
Camera 가까이

Bounds Center
Camera에서 멀리
↓
Transparent 순서 오판 가능
```

Vertex Shader Animation으로 Geometry만 이동하고 CPU Bounds가 갱신되지 않으면 Culling뿐 아니라 Sorting 대표점도 어긋날 수 있다.

Renderer Bounds를 실제 최대 변형 범위에 맞춘다.

---

## Sorting Layer 남용

모든 Sprite마다 고유한 Sorting Layer를 만들 필요는 없다.

```text
Sorting Layer
큰 시각 Group

Order in Layer
Group 내부 세부 순서
```

Layer가 지나치게 많으면 Project 전체 순서 관계를 이해하기 어렵다.

Background, World, Character, Effect 같은 안정적인 Group에 Layer를 사용하고 Prefab 내부는 Order와 Sorting Group으로 관리할 수 있다.

---

## Order in Layer 남용

Object마다 임의로 1씩 증가하는 Order 값을 지정하면 새 Object를 사이에 넣기 어렵고 Prefab 간 충돌이 생긴다.

```text
Body = 1001
Hair = 1002
Weapon = 1003
Effect = 1004
```

의미 있는 간격과 규칙을 정의할 수 있다.

```text
Body Base = 0
Equipment Range = 100 ~ 199
Effect Range = 200 ~ 299
```

복잡한 Character는 Sorting Group으로 독립된 내부 공간을 만드는 편이 관리하기 쉽다.

---

## Sorting 최적화 순서

Sorting 관련 CPU 또는 GPU 문제가 확인되면 다음 순서로 접근할 수 있다.

```text
1. Camera별 Visible Renderer 수 확인
2. 불필요한 Layer와 Camera 제거
3. Opaque / Transparent Queue 분류 확인
4. Transparent로 만들 필요 없는 Surface 찾기
5. Opaque Overdraw와 State 변경 비교
6. Transparent Material과 Layer 수 감소 검토
7. Sorting Group과 Sort Point 규칙 정리
8. Frame Debugger와 목표 GPU Capture로 재측정
```

정렬 알고리즘을 바꾸기 전에 잘못된 Surface Type과 Queue 설정을 먼저 고친다.

---

## Opaque 최적화 확인

Opaque Scene에서 다음 항목을 비교한다.

```text
Early-Z와 Depth Prepass 사용 여부
Overdraw Heatmap
SetPass Call
SRP Batch 길이
Fragment GPU 시간
CPU Render Thread 시간
```

Material State를 더 잘 모았는데 Fragment 시간이 늘었다면 Front-to-back 효과가 줄었을 수 있다.

Front-to-back를 강화했는데 CPU 시간이 늘었다면 State 전환을 조사한다.

목표 Device의 병목에 맞는 균형을 찾는다.

---

## Transparent 최적화 확인

Transparent Scene에서는 다음 항목을 확인한다.

```text
겹치는 Layer 수
Screen Coverage
Material과 Shader 종류
Back-to-front 순서 정확성
Particle 내부 Sorting
Fragment GPU 시간
Blend Bandwidth
```

화면을 크게 덮는 Smoke와 Glass가 여러 장 겹치면 Renderer 수가 적어도 GPU 비용이 클 수 있다.

Sorting을 줄이기보다 Effect 크기, 수명, 해상도와 Shader 복잡도를 줄이는 것이 더 효과적일 수 있다.

---

## Frame Debugger로 Sorting 확인하기

Frame Debugger는 Draw Event를 실제 실행 순서대로 보여 준다.

```text
DrawOpaqueObjects
├─ Near Wall
├─ Building
└─ Terrain

DrawTransparentObjects
├─ Far Smoke
├─ Glass
└─ Near Particle
```

각 Event의 GameObject, Material, Queue, Shader Pass와 Render State를 비교한다.

예상과 다른 Object를 선택하고 Camera Distance, Bounds, Sorting Layer와 Order를 확인한다.

---

## Scene View로 Distance 확인하기

Transparent Object의 Bounds Center와 Sprite Pivot을 Gizmo로 표시하면 Sorting 대표점을 이해하기 쉽다.

```text
Camera
↓
Object Pivot / Bounds Center
↓
Distance 비교
```

Custom Axis를 사용한다면 Axis 방향과 Object Position Projection도 시각화할 수 있다.

Game Camera와 Scene View Camera는 위치가 다르므로 Game View 결과를 기준으로 진단한다.

---

## Profiler로 Sorting 비용 확인하기

CPU Profiler Timeline에서 Culling, Sorting과 Draw Command 준비 구간을 확인한다.

Renderer 수가 늘 때 Sorting 시간이 어떻게 변하는지 비교한다.

```text
Camera 한 개
Visible Renderer 1,000

Camera 두 개
각각 Visible Renderer 1,000
→ Camera별 Sorting 반복 가능
```

GPU Profiler에서는 Sorting 결과로 달라진 Opaque Overdraw와 Transparent Fragment 시간을 확인한다.

Editor Overhead를 제외하기 위해 Target Player에서도 측정한다.

---

## 자주 혼동하는 내용

### Render Queue가 같으면 순서가 정해지지 않는다?

Queue 내부에서 Distance, Sorting Layer, Material과 Pipeline Criteria로 다시 정렬된다.

### Opaque는 항상 정확한 Front-to-back 순서다?

아니다.

State 변경 감소와 Batching을 함께 고려하므로 완전한 Distance 순서가 아닐 수 있다.

### Transparent는 Triangle마다 정렬된다?

일반적인 Renderer Sorting은 Object 단위이며 Mesh 내부 Triangle을 Camera마다 자동 정렬하지 않는다.

### Sorting Layer는 Camera Culling Layer다?

아니다.

Sorting Layer는 Draw 순서이고 GameObject Layer는 Culling Mask와 Physics 등에 사용된다.

### Order in Layer 값이 크면 모든 Queue 위에 그려진다?

아니다.

Render Queue와 Render Pass Filter가 먼저 큰 범위를 나누며 Depth State도 결과에 영향을 준다.

### Sorting Group은 Child Renderer를 하나의 Draw로 합친다?

아니다.

Sorting 단위로 묶어 내부 순서를 유지하지만 Material과 Mesh Draw는 별도로 남을 수 있다.

### Back-to-front면 Transparency가 항상 정확하다?

아니다.

교차 Renderer와 Mesh 내부 Triangle은 하나의 Object 순서로 완벽히 해결할 수 없다.

### 정렬 순서를 바꾸면 Z-fighting이 해결된다?

안정적인 해결이 아니다.

Z-fighting은 주로 가까운 Depth 값과 Precision 문제이므로 Geometry와 Depth 설정을 확인해야 한다.

---

## 전체 흐름 다시 연결하기

Renderer Sorting 흐름은 다음과 같다.

```text
Camera Culling
↓
Visible Renderer
↓
Render Queue Range
├─ Opaque
│  ├─ Queue
│  ├─ State 변경 최적화
│  └─ Front-to-back Depth
│
└─ Transparent
   ├─ Sorting Layer / Order
   ├─ Queue
   ├─ Back-to-front Distance
   └─ Material / Tiebreaker
↓
정렬된 Draw Command
```

Renderer Type, Camera Sort Mode, Sorting Group과 Custom SRP Criteria에 따라 세부 Key가 달라질 수 있다.

---

## 정리

Sorting은 Camera Culling과 Render Queue Filtering을 통과한 Renderer의 Draw 순서를 결정하는 과정이다.

Opaque Renderer는 가까운 Surface의 Depth를 먼저 기록해 뒤 Fragment를 제거하는 Front-to-back 방향과 Shader·Material State 변경 감소를 함께 고려한다.

```text
Opaque Sorting
Depth 효율 + State 효율

Transparent Sorting
Blend 정확성을 위한 Back-to-front
```

Transparent는 Destination Color와 순서대로 Blend되므로 일반적으로 Camera에서 먼 Renderer부터 가까운 Renderer 순으로 그린다.

Renderer 단위 Distance는 Object를 대표하는 한 점을 사용하므로 교차 Mesh와 Mesh 내부 Triangle Transparency를 완벽히 해결하지 못한다.

Sorting Layer와 Order in Layer는 2D Renderer의 명시적인 순서를 만들고 Sorting Group은 여러 Child Sprite의 내부 순서를 유지하면서 Group 전체를 하나의 Sorting 단위처럼 처리한다.

Perspective, Orthographic과 Custom Axis Mode는 Camera Distance를 계산하는 방식을 바꾸며 Top-down 및 Isometric 2D Project에는 Custom Axis가 적합할 수 있다.

Sorting 결과는 Opaque Overdraw, Transparent 정확성, Batching과 SetPass Call에 영향을 주므로 Frame Debugger와 CPU·GPU Profiler에서 실제 순서와 목표 Device 비용을 함께 확인해야 한다.
