---
title: "[Unity 렌더링] 11-4. Frustum Culling과 Occlusion Culling은 무엇이 다를까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - Culling
  - FrustumCulling
  - OcclusionCulling
permalink: /programming/unity-11-4-frustum-culling-vs-occlusion-culling/
toc: true
toc_sticky: true
date: 2026-08-16
last_modified_at: 2026-08-16
---

Frustum Culling은 Camera가 볼 수 있는 공간 밖의 Object를 제거하고 Occlusion Culling은 그 공간 안에서 다른 Geometry에 가려진 Object를 제거한다.

```text
Camera
  │
  ├─ Frustum 밖 Object
  │    └─ Frustum Culling
  │
  └─ Frustum 안
       ├─ Wall 앞 Object → Visible
       └─ Wall 뒤 Object → Occlusion Culling
```

두 기법은 같은 Object를 두고 경쟁하는 대안이 아니라 서로 다른 이유로 보이지 않는 Renderer를 단계적으로 줄이는 보완 관계다.

Frustum Culling은 Camera Projection과 Bounds만 필요하지만 Occlusion Culling은 Object 사이의 가림 관계와 추가 Visibility Data가 필요하다.

---

## 가장 짧은 차이

```text
Frustum Culling
→ Camera 범위 안에 있는가?

Occlusion Culling
→ Camera 범위 안에서 실제로 가려졌는가?
```

Frustum 밖 Object는 어떤 Wall이 없어도 화면에 나타날 수 없다.

Occluded Object는 Frustum 안에 있지만 Camera와 Object 사이의 Occluder 때문에 나타나지 않는다.

판정 질문이 다르므로 필요한 입력과 비용도 다르다.

---

## 핵심 비교표

| 항목 | Frustum Culling | Occlusion Culling |
|---|---|---|
| 제거 대상 | Camera View Volume 밖 | View Volume 안에서 완전히 가려진 Object |
| 주요 입력 | Camera Plane, Renderer Bounds | Camera Cell, Occluder, Occludee, Visibility Data |
| 대표 판정 | Plane 대 AABB | Precomputed PVS 또는 Runtime Depth Visibility |
| 사전 처리 | 일반적으로 별도 Bake 불필요 | Unity 기본 방식은 Bake 필요 |
| Dynamic Camera | 즉시 Matrix에 반영 | 현재 Cell·Camera 위치로 Data 조회 |
| Dynamic Occluder | 관계없음 | Baked 방식에서는 제한적 |
| Memory | 비교적 작음 | Occlusion Data Memory 필요 |
| 적용 범위 | 대부분의 Camera에 기본적 | 가림이 많은 Scene에서 선택적 |
| 대표 실패 | 큰 Bounds로 불필요 Draw | 잘못된 Bake로 Pop·낮은 제거율 |

표의 구분은 Unity의 일반적인 Bounds Frustum Culling과 Baked Occlusion Culling을 기준으로 한다.

---

## 같은 장면에서 비교한다

Camera 앞에 Wall이 있고 여러 Object가 배치된 장면을 가정한다.

```text
Top View

          Outside A
              ●

Camera ● ── Wall █ ── Hidden B ●
          Visible C ▲

              Outside D ■
```

Object A와 D는 Frustum 밖이다.

Object B는 Frustum 안이지만 Wall 뒤에 가려져 있다.

Object C는 Frustum 안이고 Wall 앞에 보인다.

---

## Frustum Culling 결과

Camera의 여섯 Frustum Plane과 각 Renderer Bounds를 비교한다.

```text
Object A → Frustum 밖 → Culled
Object B → Frustum 안 → Keep
Object C → Frustum 안 → Keep
Object D → Frustum 밖 → Culled
```

Frustum Culling은 Wall의 존재를 검사하지 않는다.

따라서 Object B가 완전히 가려져도 Camera Volume 안이라는 이유로 Visible 후보에 남는다.

---

## Occlusion Culling 결과

Frustum을 통과한 B와 C를 가림 관계로 추가 판정한다.

```text
Object B → Wall 뒤 완전 가림 → Culled
Object C → Camera에서 보임   → Keep
```

최종 Visible Set는 C만 남을 수 있다.

```text
Initial Objects: A B C D
Frustum Result:  B C
Occlusion Result:  C
```

두 단계를 연결하면 명백한 Offscreen Object와 Frustum 내부의 Hidden Object를 모두 줄일 수 있다.

---

## 판정 공간의 차이

Frustum Culling은 Camera Projection이 만드는 기하학적 Volume을 다룬다.

```text
Camera Parameters
├─ Position·Rotation
├─ FOV 또는 Orthographic Size
├─ Aspect
├─ Near
└─ Far
```

Occlusion Culling은 Camera와 Object 사이의 Scene Geometry 관계를 다룬다.

```text
Occlusion Inputs
├─ Camera Cell
├─ Static Wall·Building
├─ Opening·Hole
├─ Occludee Bounds
└─ Baked Visibility
```

Camera 설정만으로 가림을 알 수 없고 Geometry 위치만으로 Camera Volume 밖인지 알 수 없다.

---

## 필요한 데이터의 차이

Frustum Culling은 현재 Camera Matrix에서 여섯 Plane을 만들고 Renderer Bounds와 비교할 수 있다.

```text
View Projection Matrix
→ Frustum Planes
→ Bounds Test
```

Unity의 Baked Occlusion Culling은 Scene의 Static Geometry를 분석한 Data가 추가로 필요하다.

```text
Occluder·Occludee
→ Bake
→ View Cells
→ Potentially Visible Set
```

Level Geometry가 바뀌면 Occlusion Data는 다시 Bake해야 하지만 Frustum Plane은 Camera에서 매 Frame 계산할 수 있다.

---

## 사전 처리의 차이

Frustum Culling은 일반적인 Renderer Bounds가 정확하다면 별도 Authoring 작업이 적다.

```text
Renderer 존재
→ Bounds 생성
→ Camera가 자동 판정
```

Occlusion Culling은 다음 준비가 필요할 수 있다.

```text
Static Flag 설정
Occluder·Occludee 역할 설정
Occlusion Area 배치
Bake Parameter 지정
Data Bake
Visualization 검증
```

Occlusion은 더 많은 Object를 제거할 가능성이 있지만 Level 제작과 검증 Workflow도 추가한다.

---

## Runtime 비용의 차이

Frustum Plane과 단순 Bounds 교차는 비교적 저렴한 Coarse Test다.

```text
6 Planes × Bounds
→ Outside 여부
```

Occlusion Culling은 Camera Cell 조회, PVS 해석 또는 Runtime Depth Query 같은 추가 작업이 필요하다.

```text
Occlusion Cost
├─ Cell Lookup
├─ Visibility Data Access
├─ Dynamic Bounds Test
└─ Visible Set Filtering
```

가려지는 Object가 적으면 Occlusion 비용 대비 절감이 작을 수 있다.

---

## Memory 비용의 차이

Frustum Culling은 Camera Plane과 Renderer Bounds처럼 이미 Rendering에 필요한 Data를 주로 사용한다.

Occlusion Bake는 Cell과 Visibility 관계를 별도 Data로 저장한다.

```text
Occlusion Data Size
← Scene 크기
← Cell 정밀도
← Renderer 수
← Occluder·Hole Setting
```

정밀한 Bake는 더 많은 Hidden Object를 제거할 수 있지만 Build Size와 Runtime Memory를 늘릴 수 있다.

Frustum의 낮은 추가 Memory와 Occlusion의 더 높은 제거 잠재력을 비교한다.

---

## Frustum Culling이 항상 먼저인 이유

Frustum 밖 Object는 Occluder 관계를 계산하지 않아도 보이지 않는다는 사실이 확실하다.

```text
Renderer Candidates
→ Frustum Test
→ Frustum 안 후보만 Occlusion Test
```

명백한 Outside Object를 저렴한 Test로 먼저 제거하면 더 비싼 Occlusion 후보 수를 줄일 수 있다.

정확한 Unity 내부 순서는 Version과 Rendering Architecture에 따라 다를 수 있지만 저렴한 Broad Phase 뒤에 정밀한 Narrow Phase를 적용한다는 일반 원리는 같다.

---

## Broad Phase와 Narrow Phase

두 기법을 Collision Detection의 단계와 비슷하게 생각할 수 있다.

```text
Broad Phase
→ Frustum과 겹칠 가능성이 있는가?

Narrower Visibility Phase
→ 실제로 다른 Geometry 뒤에 가려졌는가?
```

Frustum Culling은 `Potentially Visible` 후보를 빠르게 만든다.

Occlusion Culling은 그 후보 중 Scene 가림 관계로 더 제거한다.

둘 다 최종 Pixel Visibility를 완벽하게 증명하는 것은 아니며 보수적인 False Positive를 허용할 수 있다.

---

## False Positive의 원인이 다르다

Frustum Culling의 False Positive는 Bounds가 Frustum과 겹치지만 실제 Mesh가 화면 밖인 경우다.

```text
Large Bounds intersects Frustum
Actual Mesh outside
→ Draw 후보 유지
```

Occlusion Culling의 False Positive는 Object가 실제로 가려졌지만 PVS나 Bake 정밀도 때문에 Visible로 남는 경우다.

```text
Hidden Object
PVS에 보수적으로 포함
→ Draw 후보 유지
```

둘 다 화면은 정상이고 최적화 기회만 놓친다.

---

## False Negative의 원인이 다르다

Frustum Culling에서는 Bounds가 실제 변형 Geometry를 포함하지 못할 때 보이는 Mesh가 사라질 수 있다.

```text
GPU Deformed Vertex inside
CPU Bounds outside
→ 잘못 Cull
```

Occlusion Culling에서는 잘못된 Occluder, Hole과 Stale Bake Data 때문에 Opening을 통해 보이는 Object가 사라질 수 있다.

```text
Open Door
Bake는 막힌 것으로 판단
→ 뒤 Room Pop
```

문제 원인이 다르므로 Debug 도구와 수정 방향도 다르다.

---

## Dynamic Object 처리

움직이는 Character도 Camera Frustum과 현재 Bounds를 비교할 수 있다.

```text
Character 이동
→ Bounds 이동
→ 다음 Camera Culling에서 새 Frustum 결과
```

Occlusion Bake는 움직이는 Character가 Static Wall 뒤에 가려지는 것은 처리할 수 있지만 Character가 다른 Object를 가리는 Dynamic Occluder 역할에는 제한이 있을 수 있다.

```text
Static Wall → Dynamic Character 가림 가능
Moving Truck → Building 가림은 Bake에 반영 어려움
```

---

## Camera 이동 처리

Frustum Culling은 Camera View·Projection Matrix가 바뀌면 Plane도 바로 바뀐다.

```text
Camera Rotate
→ Frustum Rotate
→ Bounds 결과 갱신
```

Occlusion Culling은 Camera가 이동한 View Cell과 해당 PVS를 조회한다.

```text
Camera Cell A → Cell B
→ Visibility Set 변경
```

Camera가 Bake Area 밖에 있거나 빠르게 Cell을 통과하면 Occlusion 효과와 안정성을 별도로 확인해야 한다.

---

## Geometry 변경 처리

Frustum Culling은 Renderer Bounds가 현재 Geometry 범위를 정확히 반영하면 Object 이동과 회전에 대응한다.

Occlusion Bake는 Static Wall의 위치가 바뀌면 Precomputed 관계가 현재 Scene과 달라질 수 있다.

```text
Wall Move
Frustum → Bounds만 갱신
Occlusion → Re-bake 필요 가능
```

절차적 Level과 Dynamic Building이 많은 Scene에서는 Baked Occlusion보다 Runtime Depth·Portal 방식이 더 적합할 수 있다.

---

## Frustum Culling에 유리한 장면

Frustum은 Camera 밖에 넓은 World가 존재하는 장면에서 효과적이다.

```text
Open World
├─ Camera 앞 Region
├─ Camera 뒤 Region
├─ 좌우 Region
└─ Far Plane 밖 Region
```

Open Field처럼 Occluder가 적어도 Camera 뒤와 View 밖 Object는 대량으로 제거할 수 있다.

대부분의 3D Camera에 기본적으로 필요한 Visibility 단계다.

---

## Occlusion Culling에 유리한 장면

큰 불투명 Geometry가 공간을 분리하는 장면에서 효과가 크다.

```text
Indoor
Room A │ Wall │ Room B │ Wall │ Room C

Street
Camera │ Building │ Hidden Blocks
```

Frustum 안에 Object가 많지만 Wall과 Building 뒤에서 실제로 보이지 않는 비율이 높다.

Hidden Renderer가 고밀도 Mesh거나 Draw Call이 많을수록 제거 이득이 커질 수 있다.

---

## Open Field 비교

넓은 평지에서 Camera가 수평을 바라본다.

```text
Frustum 밖
→ 많은 Object 제거 가능

Frustum 안
→ 대부분 직접 보임
→ Occlusion 제거 적음
```

이 장면에서는 Frustum Culling은 계속 유효하지만 Occlusion Culling은 Query와 Data 비용에 비해 이득이 작을 수 있다.

Distance Culling, LOD와 HLOD가 더 큰 효과를 만들 수 있다.

---

## 실내 비교

Camera가 작은 Room 안에 있다.

```text
Frustum 밖 Room
→ Frustum Culling

Frustum 방향의 Wall 뒤 Room
→ Occlusion Culling
```

Camera가 보는 방향만으로는 먼 Room이 Frustum 안에 들어올 수 있다.

Wall이 뒤 Room을 완전히 막으므로 Occlusion Culling이 많은 Renderer를 추가로 제거한다.

Door와 Window Opening의 Bake 정확도가 중요하다.

---

## Top-down Camera 비교

높은 위치에서 Scene 전체를 내려다보는 Camera를 가정한다.

```text
Orthographic Frustum
→ Map 밖 Object 제거

Map 안 Object
→ 위에서 대부분 보임
```

Frustum과 Layer Distance는 유효하지만 Building 뒤에 완전히 가려지는 Object가 적을 수 있다.

Occlusion Bake Data가 있어도 Culled 비율이 낮다면 Camera에서 사용하지 않는 편이 나을 수 있다.

---

## 도시 Street Camera 비교

Street Camera는 가까운 Building가 먼 Block을 가린다.

```text
Frustum
→ Camera 뒤·옆 Block 제거

Occlusion
→ 앞 Building 뒤 Block 제거
```

두 기법이 서로 다른 City 영역을 제거하므로 조합 효과가 크다.

Rooftop Camera로 올라가면 Occlusion은 줄고 Frustum 안 Visible Object가 늘 수 있다.

Camera 높이별 Profile이 필요하다.

---

## Bounds가 두 기법에 미치는 영향

Frustum은 Renderer Bounds를 직접 Plane과 비교한다.

Occlusion도 Occludee의 공간 범위를 이용해 보이는 가능성을 판정한다.

```text
큰 Bounds
├─ Frustum과 오래 교차
└─ 여러 Cell에서 Visible로 남을 가능성

작은 Bounds
└─ 실제 Geometry가 잘못 Culled될 위험
```

Bounds 정확성은 두 기법 모두의 기반이다.

---

## Mesh Combining Trade-off 비교

Mesh를 크게 합치면 Renderer 수와 Draw Call은 줄 수 있다.

```text
Combined Bounds가 Frustum에 걸림
→ 내부 Offscreen Geometry도 Draw

Combined Bounds 일부가 Opening에서 보임
→ Hidden Room Geometry도 Draw
```

큰 Combined Mesh는 Frustum과 Occlusion의 Culling Granularity를 동시에 낮출 수 있다.

Camera가 함께 보는 공간 Cluster나 Room 단위로 결합한다.

---

## LOD와 역할이 다르다

LOD는 보이는 Object의 Detail을 Screen Size에 따라 바꾼다.

```text
Frustum Culling
→ Camera Volume 밖 제거

Occlusion Culling
→ 가려진 Object 제거

LOD
→ 보이는 Object의 Detail 감소 또는 거리 Cull
```

세 기법을 순차적으로 조합할 수 있다.

어느 하나가 다른 둘을 대체하지 않는다.

---

## Layer Culling과 역할이 다르다

Camera Culling Mask는 Layer 정책으로 Renderer를 제외한다.

```text
UI Layer를 World Camera에서 제외
Debug Layer를 Player Camera에서 제외
```

Object가 Frustum 안인지 가려졌는지와 관계없이 Camera가 해당 Layer를 그리지 않는다.

Layer Filtering, Frustum, Occlusion과 LOD는 각기 다른 기준으로 Visible Set를 줄인다.

---

## Backface Culling과 역할이 다르다

Backface Culling은 Mesh Triangle의 앞뒤 방향을 기준으로 뒷면을 Rasterization에서 제거한다.

```text
Frustum·Occlusion
→ 주로 Renderer·Object 단위 Visibility

Backface
→ Triangle 방향 단위
```

Object가 Visible Set에 남아 Draw된 뒤에도 Camera 반대 방향 Triangle를 줄일 수 있다.

다음 글에서 Backface Culling을 별도로 다룬다.

---

## Depth Test와 역할이 다르다

Depth Test는 Rasterized Fragment의 깊이를 비교한다.

```text
Culling 단계
→ Draw 또는 Triangle를 줄임

Depth Test
→ Pixel 후보를 제거
```

Frustum과 Occlusion이 놓친 Hidden Geometry는 Depth Buffer가 최종 Color 오류를 막는다.

Depth Test는 정확한 Visibility를 제공하지만 늦은 단계이므로 CPU와 Vertex 비용은 줄이지 못할 수 있다.

---

## 적용 순서를 개념적으로 본다

```text
Scene Renderers
      │
      ▼
Layer Filtering
      │
      ▼
Frustum Culling
      │
      ▼
Occlusion Culling
      │
      ▼
LOD·Sorting·Batching
      │
      ▼
Draw Submission
      │
      ▼
Backface·Primitive Culling
      │
      ▼
Depth Test
```

실제 내부 순서는 Unity Version, Pipeline과 Renderer에 따라 달라질 수 있다.

핵심은 저렴하고 넓은 조건에서 후보를 줄인 뒤 더 세밀한 판정을 적용한다는 점이다.

---

## 어떤 기법을 켜야 할까?

Frustum Culling은 일반 Renderer의 기본 Camera Rendering에 항상 필요한 수준의 기능이다.

Occlusion Culling은 다음 질문으로 결정한다.

```text
Frustum 안에서 가려지는 Renderer가 많은가?
Static Occluder가 충분한가?
Camera가 제한된 공간을 이동하는가?
Bake Data Memory를 감당할 수 있는가?
Runtime Query보다 Draw 절감이 큰가?
```

질문 대부분이 `아니오`라면 Occlusion Bake보다 LOD·Distance·Chunk 최적화가 우선일 수 있다.

---

## 둘 중 하나만 선택하는 문제가 아니다

Occlusion Culling을 켰다고 Frustum Culling이 필요 없어지는 것은 아니다.

```text
잘못된 선택 사고
Frustum vs Occlusion

올바른 조합 사고
Frustum + 필요한 경우 Occlusion
```

Frustum은 Occlusion Query 대상까지 줄여 주며 Occlusion은 Frustum이 알 수 없는 가림을 처리한다.

두 기법의 비용과 제거율을 각각 측정한다.

---

## Frustum 문제를 Occlusion으로 해결하면 안 된다

큰 Bounds 때문에 화면 밖 Object가 Frustum과 계속 겹친다면 Bounds나 Mesh Chunk 문제다.

```text
문제
Large Bounds False Positive

해결 후보
Bounds 수정
Spatial Mesh Split
GPU Deformation Range 수정
```

Occlusion Bake를 더 정밀하게 만들어도 Camera View 밖 판정의 근본 원인은 해결되지 않는다.

먼저 어떤 Visibility 단계가 Object를 남겼는지 확인한다.

---

## Occlusion 문제를 Far Plane으로만 해결하면 안 된다

Wall 바로 뒤의 Hidden Room은 Camera와 가까워 Far Plane을 줄여도 남는다.

```text
Camera → Wall → Hidden Room 10m
```

Far Plane을 10m보다 작게 줄이면 Hidden Room뿐 아니라 앞쪽의 필요한 Object도 사라질 수 있다.

거리 문제가 아니라 가림 문제이므로 Occlusion 또는 Portal Visibility가 적합하다.

---

## Debug View의 차이

Frustum Culling은 Camera Gizmo와 Renderer Bounds로 확인한다.

```text
Frustum Debug
├─ Camera Plane
├─ Bounds
└─ GeometryUtility Test
```

Occlusion Culling은 Occlusion Visualization에서 View Cell과 Visible·Culled Renderer를 확인한다.

```text
Occlusion Debug
├─ Occlusion Area
├─ View Cell
├─ PVS
└─ Bake Data
```

둘 모두 최종 Draw는 Frame Debugger로 확인한다.

---

## Frame Debugger에서 구분하기

예상하지 못한 Renderer가 Draw 목록에 있을 때 다음 순서로 조사한다.

```text
1. Renderer Bounds가 Camera Frustum과 겹치는가?
   ├─ No  → Frustum·Camera·Pass 확인
   └─ Yes → 다음

2. 실제로 다른 Opaque Geometry에 완전히 가려졌는가?
   ├─ No  → Draw가 정상
   └─ Yes → Occlusion Data·Camera 설정 확인
```

Shadow와 Reflection Pass는 Main Camera의 Visibility 결과와 다를 수 있다.

Event의 Camera와 Render Target를 먼저 확인한다.

---

## Occlusion Visualization과 Frustum

Occlusion Visualization에서 Camera를 움직일 때 Frustum 밖 Object가 사라지고 Frustum 안의 PVS가 표시될 수 있다.

```text
표시되지 않음
→ Frustum 때문인지
→ Occlusion 때문인지
```

두 원인을 구분하려면 Camera Frustum Gizmo와 Occlusion On·Off를 비교한다.

Occlusion을 끈 상태에서도 사라지면 Frustum, Layer, LOD 또는 Renderer 상태가 원인일 수 있다.

---

## 단계별 A/B Test

동일 Frame에서 Visibility 단계를 분리한다.

```text
Test A
Occlusion Off
→ Frustum 결과만 중심으로 확인

Test B
Occlusion On
→ 추가 제거량 확인
```

Frustum Culling은 일반적으로 끄기보다 Camera 방향과 Bounds·Draw 통계를 이용해 효과를 간접 측정한다.

Occlusion On·Off의 차이가 추가 가림 이득이다.

---

## 측정 표

| 상태 | Visible Renderer | Batches | CPU Render ms | GPU ms |
|---|---:|---:|---:|---:|
| Camera 전체 후보 | 5000 | - | - | - |
| Frustum 적용 | 1800 | 1500 | 3.2 | 13.0 |
| Frustum + Occlusion | 700 | 620 | 2.4 | 9.0 |

숫자는 측정 양식의 예시다.

Occlusion으로 Renderer는 크게 줄었지만 Data Query 때문에 CPU Culling 시간이 일부 증가할 수 있다.

전체 CPU·GPU Frame Time과 Memory를 함께 판단한다.

---

## CPU 병목에서의 차이

많은 Renderer와 Draw Call가 병목이면 두 Culling 모두 CPU Submission을 줄일 수 있다.

```text
Frustum
→ Offscreen Draw Command 감소

Occlusion
→ Hidden Draw Command 추가 감소
```

Occlusion Query CPU 비용이 추가되므로 Saved Draw 수가 충분해야 한다.

Main Thread, Render Thread와 Culling Marker를 On·Off로 비교한다.

---

## GPU Vertex 병목에서의 차이

고밀도 Mesh가 Camera 밖이면 Frustum이 Draw 전체를 제거한다.

고밀도 Mesh가 Wall 뒤라면 Occlusion이 추가 제거할 수 있다.

```text
Saved Vertex Work
≈ Culled Mesh Vertex 수
```

Depth Test는 Pixel을 제거해도 Vertex Shader는 막지 못한다.

Frustum과 Occlusion의 GPU Vertex 절감은 Hidden Mesh 복잡도에 크게 영향을 받는다.

---

## GPU Fragment 병목에서의 차이

Opaque Hidden Object는 앞 Wall의 Depth와 Early-Z로 Fragment Shader가 이미 많이 제거될 수 있다.

이 경우 Occlusion Culling의 GPU Fragment 절감은 예상보다 작을 수 있다.

```text
Occlusion Off
→ Hidden Draw Vertex + Depth Test
→ Expensive Fragment는 Early-Z로 생략 가능
```

반면 Transparent Hidden Layer와 잘못된 Draw Order에서는 Pixel 비용이 더 남을 수 있다.

GPU Pass별 Counter와 시간을 확인한다.

---

## Mobile에서의 차이

Mobile Tile GPU에서도 Frustum 밖 Draw와 Wall 뒤 Geometry를 줄이면 CPU Submission, Vertex와 Tile 작업을 줄일 수 있다.

하지만 Occlusion Data Memory와 CPU Query 비용은 제한된 Resource를 사용한다.

```text
Mobile 평가
├─ Saved Batches
├─ Saved Vertices
├─ Occlusion CPU ms
├─ Data Memory
└─ Thermal 변화
```

Desktop에서 큰 이득이 난 Bake가 Mobile Camera와 Scene Density에서도 같은지 Target Device에서 확인한다.

---

## XR에서의 차이

각 Eye는 약간 다른 Frustum과 Occlusion 결과를 가질 수 있다.

```text
Left Eye Visible Set
Right Eye Visible Set
```

한 Eye에는 가려지고 다른 Eye에는 보이는 경계 Object가 있다.

Stereo Culling은 두 Eye를 감싸는 Conservative Volume을 사용할 수 있어 Mono Camera보다 더 많은 Renderer가 남을 수 있다.

Custom Visibility는 한쪽 Eye의 Object를 잘못 제거하지 않도록 Eye별 Projection을 고려한다.

---

## Multi-camera에서의 차이

Main, Reflection과 Mini Map Camera는 서로 다른 Frustum과 Occlusion 효율을 가진다.

```text
Main Camera
→ Indoor Wall Occlusion 높음

Mini Map
→ Top-down Occlusion 낮음

Reflection
→ 다른 방향의 Visible Set
```

Frustum은 각 Camera에 항상 필요하지만 Occlusion은 Camera별로 On·Off를 결정할 수 있다.

Main Camera 결과로 Renderer.enabled를 전역 변경하면 다른 Camera에서 필요한 Object까지 사라질 수 있다.

---

## Shadow Pass에서의 차이

Camera Color Frustum과 Light Shadow Culling Volume은 동일하지 않다.

```text
Main Camera 밖 Caster
→ Shadow가 화면 안에 들어올 수 있음
```

Unity Pipeline은 Shadow Caster Visibility를 별도로 계산한다.

Custom Frustum·Occlusion 결과로 Renderer를 완전히 비활성화하면 필요한 Shadow도 제거될 수 있다.

Frame Debugger에서 Main Color와 Shadow Pass를 구분한다.

---

## Procedural Scene에서의 선택

Frustum Culling은 Runtime 생성 Object도 Bounds가 있으면 적용할 수 있다.

```text
Procedural Object Spawn
→ Bounds 생성
→ Current Frustum Test
```

Baked Occlusion은 Bake 시점에 Layout을 알아야 하므로 완전한 Procedural Dungeon에는 바로 적용하기 어렵다.

```text
대안
├─ Room·Portal Graph
├─ Runtime Hi-Z
├─ GPU Occlusion Query
└─ Module별 Precomputed Visibility
```

---

## Streaming World에서의 선택

Frustum과 Distance를 이용해 현재 Camera 주변 Chunk를 Rendering 후보로 관리할 수 있다.

Occlusion Bake는 Additive Scene과 인접 Geometry의 Data 연결을 고려해야 한다.

```text
World Streaming
├─ Loaded Chunk
├─ Frustum Visible Chunk
├─ Occluded Renderer
└─ Unloaded Chunk
```

Culling은 Draw 제외이고 Streaming은 Memory Load·Unload라는 차이도 유지한다.

Occlusion Data 경계에서 Pop과 Memory를 검증한다.

---

## 선택 기준 Flow

```text
Renderer가 Camera Volume 밖인가?
├─ Yes → Frustum Culling
└─ No
    │
    ▼
큰 Static Geometry에 완전히 가려지는가?
├─ No → Visible 또는 LOD·Distance 검토
└─ Yes
    │
    ▼
가려지는 Renderer가 충분히 많고 비싼가?
├─ No → Depth·기본 Rendering으로 충분할 수 있음
└─ Yes
    │
    ▼
Bake·Data·Runtime Query 비용보다 절감이 큰가?
├─ Yes → Occlusion Culling 사용
└─ No  → 다른 Visibility 전략
```

기법 이름이 아니라 Scene 구조와 Profile 결과로 결정한다.

---

## 최적화 순서

```text
1. Renderer Bounds 오류 수정
2. Camera Culling Mask·Near·Far 확인
3. Frustum 결과와 Mesh Chunk 단위 검증
4. LOD·Distance Culling 구성
5. Frustum 안 Hidden Renderer 비율 측정
6. 큰 Static Occluder 선정
7. 기본 Occlusion Setting으로 Bake
8. Visualization과 Camera Path 검증
9. Occlusion On·Off CPU·GPU·Memory 비교
10. Camera별 사용 여부 결정
```

Frustum의 기본 문제를 해결한 뒤 Occlusion의 추가 가치를 측정한다.

---

## 흔한 오해

### Frustum Culling과 Occlusion Culling은 같은 기능이다

전자는 Camera Volume 밖을 제거하고 후자는 Volume 안에서 Geometry에 가려진 Object를 제거한다.

### 둘 중 더 좋은 하나를 선택해야 한다

Frustum을 기본 Broad Phase로 사용하고 필요한 Scene에서 Occlusion을 추가하는 보완 관계다.

### Occlusion Culling을 켜면 Frustum Culling이 필요 없다

Frustum 밖 Object를 먼저 제거해야 Occlusion 후보와 Draw를 효율적으로 줄일 수 있다.

### Frustum Culling도 Bake가 필요하다

일반적인 Frustum Plane과 현재 Bounds 판정에는 Precomputed Scene Visibility Bake가 필요하지 않다.

### Occlusion Culling은 Camera 밖 Object만 제거한다

Camera Frustum 안에서 다른 Geometry 뒤에 완전히 가려진 Object가 대상이다.

### Frustum 안이면 Renderer가 화면에 보인다

Wall 뒤, Alpha 0, LOD Cull과 다른 조건 때문에 보이지 않을 수 있다.

### Occlusion Bake를 정밀하게 하면 항상 빠르다

Data Memory와 Runtime Query 비용이 증가할 수 있어 제거되는 Draw와 비교해야 한다.

### Open World에는 Occlusion Culling이 항상 필수다

Open Field처럼 Occluder가 적으면 Frustum, Distance와 LOD가 더 효과적일 수 있다.

### Occlusion이 Depth Test를 완전히 대체한다

보수적 판정은 일부 Hidden Renderer를 남기며 Depth Buffer가 최종 Pixel Visibility를 계속 보장한다.

### 두 Culling은 Simulation도 멈춘다

Renderer Draw를 줄이는 기능이며 Script, Physics와 Animation은 별도 정책이 필요하다.

---

## 최종 체크리스트

```text
□ Camera Volume 밖과 Volume 안의 가림을 구분했는가?
□ Frustum은 Camera Plane·Bounds, Occlusion은 Scene 가림 관계임을 이해했는가?
□ Frustum 결과 뒤에 Occlusion이 추가 후보를 줄이는 구조인가?
□ Renderer Bounds가 두 기법에 정확한 범위를 제공하는가?
□ 큰 Combined Mesh가 Culling Granularity를 낮추지 않는가?
□ Dynamic Object와 Dynamic Occluder의 차이를 고려했는가?
□ Geometry 변경 시 Occlusion Re-bake가 필요한가?
□ Open Field·Indoor·Top-down Camera를 별도로 평가했는가?
□ Frustum False Positive와 Occlusion False Positive를 구분했는가?
□ Bounds Pop과 Bake Pop의 원인을 구분했는가?
□ Frustum 문제를 Occlusion Setting으로 우회하지 않았는가?
□ 가림 문제를 Far Plane만 줄여 해결하려 하지 않았는가?
□ Layer·LOD·Backface·Depth와 역할을 구분했는가?
□ Shadow와 Reflection Camera의 Visibility를 별도로 확인했는가?
□ Procedural Scene에 Baked Occlusion이 적합한가?
□ Frustum 안 Hidden Renderer 수를 측정했는가?
□ Occlusion Data Size와 Bake Time을 기록했는가?
□ Occlusion On·Off Draw·Triangle 차이를 확인했는가?
□ CPU Culling·Render Thread 시간을 비교했는가?
□ GPU Vertex·Opaque Pass 시간을 비교했는가?
□ Camera Path 전체에서 Object Pop이 없는가?
□ Target Device에서 Camera별 손익을 검증했는가?
```

---

## 정리

Frustum Culling은 Camera Projection이 만드는 View Volume 밖의 Renderer를 제거하고 Occlusion Culling은 그 Volume 안에서 다른 Geometry에 완전히 가려진 Renderer를 추가로 제거한다.

Frustum은 현재 Camera Plane과 Bounds만으로 빠르게 판정할 수 있지만 Unity의 기본 Occlusion은 Static Geometry, View Cell과 Potentially Visible Set를 위한 Bake Data가 필요하다.

Frustum은 대부분의 Camera에 필요한 저렴한 Broad Phase이고 Occlusion은 가려지는 Renderer가 많은 실내·도시 Scene에서 Query·Memory 비용보다 절감이 클 때 추가한다.

큰 Bounds와 Combined Mesh는 두 기법의 Culling 정밀도를 모두 낮출 수 있으며 작은 Bounds와 잘못된 Bake Setting은 서로 다른 Object Pop 문제를 만든다.

Open Field와 Top-down Camera에서는 Frustum·Distance·LOD의 효과가 크고 Occlusion은 작을 수 있지만 Room과 Street Camera에서는 두 기법의 조합이 많은 Draw를 줄일 수 있다.

Layer Culling, LOD, Backface Culling과 Depth Test는 판정 기준과 Pipeline 단계가 달라 두 기법을 대체하지 않는다.

Camera Gizmo·Bounds와 Occlusion Visualization로 각 단계의 후보를 확인하고 Frame Debugger와 On·Off CPU·GPU Profile로 Target Device에서 추가 Occlusion 이득을 검증해야 한다.
