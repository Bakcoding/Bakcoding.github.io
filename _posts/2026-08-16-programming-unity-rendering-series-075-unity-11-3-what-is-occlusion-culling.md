---
title: "[Unity 렌더링] 11-3. Occlusion Culling은 무엇일까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - Culling
  - OcclusionCulling
  - Optimization
permalink: /programming/unity-11-3-what-is-occlusion-culling/
toc: true
toc_sticky: true
date: 2026-08-16
last_modified_at: 2026-08-16
---

Occlusion Culling은 Camera Frustum 안에 있지만 다른 Object에 완전히 가려진 Renderer를 Draw 대상에서 제외하는 기법이다.

```text
Camera
  │
  ├─ Wall
  │    ├─ Character
  │    ├─ Props
  │    └─ Building
  │
  └─ 최종 화면에는 Wall만 보임
```

Frustum Culling은 Camera 범위 밖 Object를 제거하지만 Frustum 안의 가림 관계는 알지 못한다.

Occlusion Culling은 큰 Wall, Building과 Terrain 뒤에 숨은 Geometry를 추가로 제거해 CPU Draw Submission과 GPU Geometry·Pixel 작업을 줄인다.

---

## Occlusion이란 무엇인가?

Occlusion은 한 Surface가 다른 Surface를 시야에서 가리는 현상이다.

```text
Viewer → Occluder → Occluded Object
```

Camera와 Object 사이에 불투명한 Geometry가 있고 Object의 모든 투영 영역을 덮으면 해당 Object는 현재 화면에 기여하지 않는다.

```text
부분 가림
→ Object 일부가 보임
→ Draw 필요

완전 가림
→ Object가 전혀 보이지 않음
→ Draw 제외 가능
```

Occlusion Culling은 완전히 가려졌다고 안전하게 판단할 수 있을 때만 Renderer를 제거해야 한다.

---

## Frustum 안에서도 보이지 않을 수 있다

Camera Frustum은 화면에 투영될 수 있는 공간 범위다.

```text
Frustum
┌──────────────────────────┐
│ Wall   Hidden Objects    │
│  █       ●  ■  ▲         │
└──────────────────────────┘
```

Hidden Object의 Bounds는 여섯 Frustum Plane 안에 있으므로 Frustum Test를 통과한다.

Frustum Culling만 사용하면 Wall 뒤 Object도 Visible 후보로 남는다.

Depth Test가 마지막에 Pixel을 제거할 수 있지만 Draw Submission과 Vertex Shader 비용은 이미 발생할 수 있다.

---

## Depth Test와 차이

Depth Test는 GPU가 Fragment 단위에서 가까운 Surface와 먼 Surface를 비교한다.

```text
Wall Depth 기록
→ 뒤 Object Fragment Depth Test Fail
→ Color Write 제외
```

Early-Z가 작동하면 뒤 Object의 비싼 Fragment Shader를 줄일 수 있다.

하지만 뒤 Object Draw 자체가 제출되면 다음 비용은 남을 수 있다.

```text
CPU Draw 준비
Vertex Shader
Primitive Assembly
Rasterization 일부
Depth Test
```

Occlusion Culling은 Renderer를 Visible Set에서 제거해 이 작업을 더 앞에서 피하는 것이 목적이다.

---

## Occluder와 Occludee

Occlusion Culling에서는 Object 역할을 두 가지로 나눈다.

```text
Occluder
→ 다른 Object를 가릴 수 있는 Geometry

Occludee
→ 다른 Geometry 뒤에 가려져 Cull될 수 있는 Object
```

큰 불투명 Wall은 좋은 Occluder이자 다른 Building 뒤에서 Occludee가 될 수 있다.

한 Object가 두 역할을 동시에 가질 수도 있다.

역할을 잘못 설정하면 Bake Data가 불필요하게 커지거나 가려져야 할 Object가 계속 Rendering될 수 있다.

---

## 좋은 Occluder의 조건

좋은 Occluder는 넓은 Screen Area를 안정적으로 막는다.

```text
좋은 후보
├─ Building Wall
├─ 두꺼운 Floor·Ceiling
├─ Terrain
├─ 큰 Rock
└─ 닫힌 Room 구조
```

Camera 위치가 조금 변해도 뒤 공간을 계속 가릴 수 있는 Geometry가 효과적이다.

Occluder가 크고 단순할수록 많은 Renderer를 적은 Data로 제외할 가능성이 높다.

---

## 좋지 않은 Occluder 후보

작고 얇거나 구멍이 많은 Geometry는 안정적으로 뒤를 가리지 못한다.

```text
주의 후보
├─ 작은 Prop
├─ 얇은 Pole
├─ Fence
├─ 나뭇잎 Card
├─ 투명 Window
└─ 움직이는 Door
```

이들을 모두 Occluder로 사용하면 Bake 정밀도와 Data가 증가하지만 실제 Culling 이득은 작을 수 있다.

가림 면적과 Scene 구조를 기준으로 역할을 지정한다.

---

## Transparent Object는 Occluder가 되기 어렵다

유리나 반투명 Surface는 뒤 Object가 보여야 한다.

```text
Camera → Glass → Character

Character Color가 Glass를 통해 보임
```

Glass를 완전 불투명 Occluder처럼 처리하면 뒤 Character가 잘못 사라질 수 있다.

Alpha Clipped Fence도 구멍 사이로 뒤 Geometry가 보여 정확한 Occluder 표현이 어렵다.

시각적으로 실제 시야를 막는 Opaque Geometry를 중심으로 Occluder를 구성한다.

---

## Unity의 Baked Occlusion Culling

Unity의 기본 Occlusion Culling은 Static Scene Geometry를 분석해 Visibility Data를 미리 Bake한다.

```text
Editor Bake
├─ Scene 공간 분할
├─ Static Occluder 분석
├─ Cell별 Visible 가능 Object 계산
└─ Occlusion Data 저장

Runtime
├─ Camera가 속한 Cell 찾기
├─ Potentially Visible Set 조회
└─ Visible Renderer만 Draw 후보 유지
```

복잡한 가림 계산의 일부를 Build 전 처리해 Runtime 비용을 줄이는 구조다.

---

## 왜 미리 Bake할까?

Runtime마다 모든 Object 쌍의 가림 관계를 계산하면 비용이 매우 크다.

```text
Camera
× Occluders
× Occludees
× 매 Frame
```

Static Building과 Wall은 움직이지 않으므로 공간별 Visibility 관계를 미리 계산할 수 있다.

```text
Offline Cost 증가
→ Runtime Query 단순화
```

Bake Time과 Occlusion Data Memory를 사용해 Runtime Rendering 작업을 절약한다.

---

## Scene 공간을 Cell로 나눈다

Occlusion Bake는 Camera가 이동할 수 있는 공간을 작은 Cell로 나누어 Visibility를 계산한다.

```text
Top View

┌────┬────┬────┐
│ C1 │ C2 │ C3 │
├────┼────┼────┤
│ C4 │ C5 │ C6 │
└────┴────┴────┘
```

Camera가 Cell C4에 있을 때 C4에서 잠재적으로 보일 수 있는 Renderer Set를 조회한다.

Camera Position마다 처음부터 모든 Ray를 계산하는 대신 Precomputed Cell Data를 이용한다.

---

## View Cell

View Cell은 Camera가 위치할 수 있는 작은 공간 단위다.

```text
Cell
┌─────────┐
│ Camera  │
│   ●     │
└─────────┘
```

Cell 내부 어느 위치에서도 보일 수 있는 Object를 보수적으로 Visible 후보에 포함한다.

Cell이 크면 Data는 단순해질 수 있지만 서로 다른 시야 위치가 하나로 묶여 불필요한 Object가 Visible로 남을 수 있다.

Cell이 작으면 Visibility 정밀도는 올라가지만 Bake Time과 Data 크기가 증가할 수 있다.

---

## Potentially Visible Set

Cell마다 실제로 보이는 Object 하나만 저장하는 것이 아니라 보일 가능성이 있는 집합을 저장한다.

```text
PVS
= Potentially Visible Set
```

```text
Cell A PVS
├─ Wall 1
├─ Door 1
├─ Room B Props
└─ Corridor End
```

Cell 안의 Camera 위치와 방향 변화에서도 보이는 Object를 잘못 제거하지 않도록 보수적으로 구성한다.

PVS에 포함됐다고 현재 Camera에 실제로 보인다는 뜻은 아니며 Frustum과 다른 조건이 추가로 적용된다.

---

## Conservative Visibility

Occlusion Culling은 보이는 Object를 잘못 제거하는 것보다 가려진 Object를 조금 더 그리는 쪽을 선택한다.

```text
False Positive
→ 가려졌지만 Visible로 유지
→ 성능 손실, 화면은 정상

False Negative
→ 보이지만 Culled
→ Object Pop·Hole 발생
```

Bake Setting은 False Positive를 줄이되 False Negative가 생기지 않도록 조정한다.

작은 Door와 Window를 통해 보이는 Geometry를 너무 공격적으로 제거하면 화면 오류가 발생할 수 있다.

---

## Occlusion Area

Occlusion Area는 Camera가 이동하거나 Occlusion Data가 필요한 공간 범위를 지정한다.

```text
Scene
┌─────────────────────────┐
│   Occlusion Area        │
│   ┌─────────────────┐   │
│   │ Walkable Space  │   │
│   └─────────────────┘   │
└─────────────────────────┘
```

Camera가 절대 들어가지 않는 Wall 내부와 먼 빈 공간까지 정밀한 View Cell을 만들 필요가 없다.

실제 Camera Path, 높이와 이동 가능 영역을 감싸도록 설정한다.

---

## Occlusion Area 크기

Area가 너무 크면 불필요한 공간에 Cell과 Data가 생성될 수 있다.

```text
너무 큰 Area
→ Bake Time 증가 가능
→ Data Memory 증가 가능
→ 실제 사용하지 않는 Cell 포함
```

Area가 너무 작으면 Camera가 Data 범위를 벗어나 Occlusion Culling 효과를 얻지 못하거나 예상과 다른 결과가 생길 수 있다.

Player Camera뿐 아니라 Cutscene, Spectator와 Vehicle Camera의 이동 범위를 포함한다.

---

## Smallest Occluder

`Smallest Occluder`는 Occluder로 사용할 Geometry 크기의 기준을 조절한다.

```text
큰 값
→ 큰 Wall 중심
→ Bake 단순·Coarse 가능

작은 값
→ 작은 Geometry도 Occluder 후보
→ Bake 정밀·Data 증가 가능
```

Scene 단위와 실제 Object 크기에 맞지 않게 너무 작게 설정하면 작은 Prop까지 가림 계산에 참여한다.

가장 작은 의미 있는 Wall이나 Rock 크기를 기준으로 시작한다.

---

## Smallest Hole

`Smallest Hole`은 Occluder Geometry에서 시야가 통과할 수 있는 구멍 크기의 기준이다.

```text
Wall
┌───────────────┐
│   Window □    │
└───────────────┘
```

작은 Window, Door 틈과 Archway를 통해 뒤 Object가 보일 수 있다.

Hole 기준이 Scene 구조와 맞지 않으면 보이는 Object가 잘못 Culled되거나 너무 많은 Object가 Visible로 남을 수 있다.

Player Camera에서 실제로 의미 있는 Opening 크기를 기준으로 조정한다.

---

## Backface Threshold

Backface Threshold는 Occlusion Bake에서 Backface Sample 비율과 관련된 정밀도·Data 조정 항목이다.

복잡하거나 잘못된 Mesh Orientation이 있는 Scene에서는 결과에 영향을 줄 수 있다.

```text
Backface 비율
→ Cell이 Geometry 내부에 있는지 판단하는 데 활용 가능
```

기본값을 무조건 변경하기보다 Scene Geometry의 Normal, Closed Volume과 Bake Visualization을 확인한다.

Unity Version의 Occlusion Window 설명을 기준으로 값을 조정한다.

---

## Bake Setting의 Trade-off

정밀한 Setting이 항상 더 좋은 것은 아니다.

```text
정밀도 증가
├─ 가려진 Object를 더 잘 제거 가능
├─ Bake Time 증가 가능
├─ Occlusion Data 증가 가능
└─ 잘못 설정하면 Pop Risk 증가

정밀도 감소
├─ Bake·Data 부담 감소
└─ False Positive 증가 가능
```

최소 크기 값을 무작정 낮추지 않고 대표 Camera Path에서 결과와 Runtime ms를 비교한다.

---

## Static Occluder

Occlusion Bake에서 다른 Object를 가리는 Geometry는 위치와 형태가 안정적인 Static Object에 적합하다.

```text
Static Occluder 후보
├─ Building
├─ Wall
├─ Floor
├─ Terrain
└─ 큰 고정 Rock
```

Bake 후 움직이는 Object를 Occluder로 가정하면 Runtime Scene과 Precomputed Visibility가 달라질 수 있다.

Door, Elevator와 Vehicle처럼 움직이는 Geometry는 Static Occluder 역할을 신중하게 지정한다.

---

## Occludee Static

가려질 수 있는 Static Renderer는 Bake Data에서 Visibility 대상이 된다.

```text
Occludee
→ 다른 Geometry 뒤에서 Cull 가능한 Renderer
```

작은 Prop와 Room 안 장식은 좋은 Occludee 후보가 될 수 있다.

Occluder 역할이 필요하지 않은 Object까지 Occluder로 설정할 필요는 없다.

Static Flag와 Occlusion 설정은 Unity Version의 Inspector 구성을 기준으로 확인한다.

---

## Dynamic Object는 어떻게 처리될까?

움직이는 Character와 Prop는 Bake 시점 위치가 고정되지 않는다.

```text
Bake
Character at A

Runtime
Character moves A → B → C
```

Dynamic Renderer는 현재 Bounds가 어떤 View Cell의 Visibility Volume과 관계있는지 이용해 Static Occluder 뒤에서 Cull될 수 있다.

하지만 Dynamic Object 자체가 다른 Object를 가리는 Runtime Occluder 역할에는 기본 Baked Data의 한계가 있다.

정확한 지원 범위는 Unity Version과 Renderer 설정을 확인한다.

---

## Dynamic Occluder의 한계

큰 Truck가 Camera 앞을 막아도 Precomputed Bake는 Truck의 Runtime 위치를 알 수 없다.

```text
Camera → Moving Truck → Building
```

Truck가 Building을 완전히 가리더라도 Baked Occlusion Culling이 이를 새로운 Occluder로 활용하지 못할 수 있다.

Depth Test는 Building Fragment를 제거할 수 있지만 Building Draw와 Vertex 비용은 남는다.

GPU Hierarchical Z Culling이나 Custom Portal Logic 같은 Runtime 기법이 필요한 경우가 있다.

---

## Door가 열리고 닫히는 Scene

닫힌 Door는 Room 사이를 완전히 가리지만 열린 Door는 뒤 Room을 보여 준다.

```text
Door Closed
Room A │Door│ Room B
→ B Culled 가능

Door Open
Room A   Gap   Room B
→ B Visible 필요
```

Door를 Static Occluder로 Bake하면 열린 상태에서 Room B가 잘못 사라질 수 있다.

항상 열린 상태를 기준으로 보수적으로 Bake하거나 Portal·Room System으로 Door 상태를 Runtime에 반영한다.

---

## Camera가 Cell 밖에 있을 때

Camera가 Bake된 Occlusion 영역 밖으로 이동하면 해당 위치의 유효한 Precomputed Visibility를 사용할 수 없을 수 있다.

```text
Occlusion Area
┌──────────────┐
│ Camera Path  │
└──────────────┘ Camera ● Outside
```

Cutscene Camera, Fly Camera, Knockback와 Spectator Mode가 Area를 벗어나지 않는지 확인한다.

특수 Camera는 Occlusion Culling을 끄거나 별도 Area와 Scene 구성을 사용할 수 있다.

---

## Camera의 Use Occlusion Culling

Camera별로 Occlusion Culling 사용 여부를 제어할 수 있다.

```text
Main Camera
→ Occlusion Culling On

Mini Map Camera
→ Top-down View에서 이득이 작을 수 있음

Reflection Camera
→ 별도 검증 필요
```

Camera마다 Position, Projection과 Visible Layer가 다르므로 같은 Bake Data의 효율도 다르다.

Occlusion Query 비용보다 제거되는 Draw가 적은 Camera에서는 끄는 편이 나을 수 있다.

---

## Perspective와 Orthographic Camera

실내 Perspective Camera는 Wall과 Room이 많은 Geometry를 가리므로 Occlusion Culling 효과가 클 수 있다.

높은 위치의 Orthographic Strategy Camera는 Scene 전체를 내려다봐 가려지는 Object가 적을 수 있다.

```text
First-person Indoor
→ 많은 Wall Occlusion

Top-down Camera
→ 대부분 Object가 노출
```

Camera 유형별로 Culled Renderer 수와 Culling CPU 비용을 Profile한다.

---

## 실내 Scene에서 유리한 이유

Room과 Corridor는 큰 Wall로 시야가 명확히 분리된다.

```text
Room A ─ Corridor ─ Room B ─ Room C
```

Camera가 Room A에 있을 때 Wall 뒤 Room B·C의 Renderer를 대량으로 제외할 수 있다.

가려지는 비율이 높고 Occluder가 안정적이므로 Bake Data 대비 Rendering 절감이 크다.

Door와 Window Opening을 정확히 반영하는 것이 중요하다.

---

## 도시 Scene

큰 Building은 뒤의 Building, Vehicle와 Props를 가릴 수 있다.

```text
Street Camera
→ Front Building
→ Hidden City Blocks
```

Street Level Camera에서는 효과가 클 수 있지만 높은 Rooftop Camera에서는 대부분 Building이 보인다.

Camera 높이와 이동 경로에 따라 동일 Scene의 Occlusion 효율이 크게 달라진다.

Building Cluster와 Occlusion Area를 Gameplay View에 맞춘다.

---

## Open Field에서의 한계

넓은 평지에는 Object를 완전히 가리는 큰 Occluder가 적다.

```text
Camera ───────────────── Horizon
      Tree  Rock  House  Mountain
```

대부분의 Renderer가 PVS에 남으면 Occlusion Data Query 비용만 추가되고 Draw 절감은 작을 수 있다.

Open Field에서는 Frustum, Distance Culling, LOD, HLOD와 Terrain Occlusion이 더 중요할 수 있다.

Occlusion Culling을 사용한다는 사실보다 실제 가려지는 비율을 측정한다.

---

## 작은 Object가 많은 Scene

Occlusion Culling은 Wall 뒤 작은 Props 수백 개를 한꺼번에 제거할 때 효과가 좋을 수 있다.

```text
Hidden Room
├─ Chair × 20
├─ Table × 10
├─ Books × 200
└─ Decorations × 300
```

하지만 Props를 모두 Occluder로 설정할 필요는 없다.

큰 Wall은 Occluder, Props는 Occludee로 역할을 분리하면 Bake 복잡도를 줄일 수 있다.

---

## 매우 큰 Renderer

Renderer Bounds가 여러 Room과 Cell을 가로지르면 일부가 보이는 것만으로 전체 Renderer가 Visible로 남을 수 있다.

```text
Combined Bounds
┌───────────────────────────┐
│ Room A Mesh + Room B Mesh │
└───────────────────────────┘
```

Occlusion Culling Granularity는 Renderer 단위와 Bake Data 구조에 제한된다.

공간적으로 분리된 Room Geometry를 적절한 Chunk로 나눈다.

너무 잘게 나누면 Renderer와 Draw 관리 비용이 증가한다.

---

## Renderer Bounds의 영향

Occludee Bounds가 크면 작은 부분만 보일 가능성 때문에 전체 Object를 Visible로 유지할 수 있다.

```text
Large Bounds
→ 여러 Cell에서 Potentially Visible
```

Skinned Mesh, Particle, Trail과 Vertex Deformation의 Bounds가 과도하게 크지 않은지 확인한다.

Bounds를 줄여 실제 Geometry를 포함하지 못하면 잘못 Cull되는 Pop이 발생할 수 있다.

정확성과 Culling 효율의 균형이 필요하다.

---

## Mesh Combining과 Occlusion

작은 Renderer를 하나의 큰 Mesh로 결합하면 Draw Call은 줄지만 Occlusion Culling 단위가 커진다.

```text
Before
Room A Mesh
Room B Mesh

After
Combined Building Mesh
```

Room A 일부가 보이면 Room B Geometry까지 같은 Draw로 처리될 수 있다.

실내에서는 Room·Corridor처럼 Occlusion 경계에 맞춰 Mesh를 나누는 편이 효과적일 수 있다.

---

## Static Batching과 Occlusion

Static Batching은 Static Geometry의 Draw 효율을 높이지만 Occlusion Culling과 함께 사용될 때 실제 Renderer 단위와 Batch 구성을 확인해야 한다.

```text
Batching 목표
→ Draw Submission 감소

Occlusion 목표
→ Hidden Renderer 제거
```

두 최적화는 서로 다른 축이며 공간 분할이 너무 크거나 작으면 Trade-off가 생긴다.

Frame Debugger와 Rendering Profiler로 Culled Renderer와 Batch 수를 함께 비교한다.

---

## Occlusion Data Memory

Bake 결과는 Runtime에 사용할 Visibility Data로 저장된다.

```text
Data Size 영향
├─ Scene 공간 크기
├─ Cell 정밀도
├─ Renderer 수
├─ Occluder·Hole 설정
└─ Scene 복잡도
```

정밀한 Bake는 Runtime Draw를 더 줄일 수 있지만 Build Size와 Runtime Memory를 증가시킬 수 있다.

Occlusion Window의 Data Size와 Player Memory를 확인한다.

---

## Bake Time

큰 Scene과 작은 Bake Parameter는 계산 시간을 크게 늘릴 수 있다.

```text
Bake Workflow
→ Setting 변경
→ 긴 Bake
→ 결과 Visualization
→ Runtime Test
```

전체 World를 매번 Bake하기 전에 대표 Zone이나 작은 Test Scene에서 Parameter 방향을 찾는다.

Scene Geometry가 변경되면 기존 Data가 현재 구조와 일치하는지 다시 Bake해야 한다.

---

## Scene 변경과 재Bake

Wall, Door, Building과 Occlusion Static 상태가 바뀌면 Visibility 관계도 달라진다.

```text
Geometry 변경
→ 기존 Bake Data Stale 가능
→ Re-bake 필요
```

Prefab 위치 이동, Scene Merge와 Level Design 수정 후 Occlusion Data 갱신 절차를 Build Pipeline에 포함한다.

오래된 Data는 보이는 Object가 사라지거나 Culling 효과가 떨어지는 원인이 될 수 있다.

---

## Multi-scene과 Occlusion Data

Additive Scene Loading에서는 여러 Scene의 Geometry와 Occlusion Data 관계를 고려해야 한다.

```text
Persistent Scene
+ Level A
+ Level B
```

Scene을 함께 Bake해야 하는지, Runtime에 어느 Data가 활성화되는지는 Unity의 Multi-scene Occlusion Workflow를 따른다.

독립적으로 Bake한 인접 Scene 경계에서는 서로를 Occluder·Occludee로 인식하지 못할 수 있다.

Streaming 경계에서 Object Pop과 Visibility를 검증한다.

---

## Prefab과 Procedural Level

Runtime에 생성되는 Room, Building과 Dungeon은 Bake 시점에 위치가 정해져 있지 않을 수 있다.

```text
Bake Time
→ Layout 미정

Runtime
→ Procedural Layout 생성
```

기본 Precomputed Occlusion Data를 그대로 사용하기 어렵다.

Room·Portal Visibility, Runtime Hi-Z Occlusion, Distance·Frustum Culling과 Module별 Prebaked Data 같은 대안을 검토한다.

절차적 생성 구조에 맞는 Visibility System이 필요하다.

---

## Portal 기반 Visibility

Room과 Door 연결이 명확하면 Portal Graph로 보이는 Room을 결정할 수 있다.

```text
Room A ─ Portal ─ Room B ─ Portal ─ Room C
```

Camera가 Room A에 있고 Door가 닫혀 있으면 B·C를 제외한다.

Door가 열리면 Portal을 통해 Frustum을 재귀적으로 Clip해 다음 Room Visibility를 계산할 수 있다.

Dynamic Door 상태를 직접 반영할 수 있지만 Portal Authoring과 경계 오류 관리가 필요하다.

---

## Hardware Occlusion Query

GPU에 Bounding Box나 Proxy Geometry가 실제 Depth Buffer 뒤에 가려졌는지 Query할 수 있다.

```text
Depth Buffer 준비
→ Object Bounds Query
→ 통과 Sample 수 확인
→ 다음 Draw 여부 결정
```

결과를 CPU에서 기다리면 GPU Stall이 생길 수 있어 이전 Frame 결과를 사용하거나 비동기로 처리한다.

Camera가 빠르게 움직이면 이전 Visibility 결과로 Object가 늦게 나타날 수 있다.

Unity의 기본 Baked Occlusion Culling과 별개의 Runtime 기법이다.

---

## Hierarchical Z Buffer

Hi-Z는 Depth Buffer를 여러 해상도 Level로 축소해 넓은 영역의 가장 가까운 Depth를 빠르게 비교하는 구조다.

```text
Depth Full Resolution
→ 1/2
→ 1/4
→ 1/8
```

Object Bounds의 Screen Rect와 Depth를 적절한 Mip Level에서 비교해 가려짐을 판정할 수 있다.

GPU-driven Rendering과 대규모 Instance Culling에서 사용된다.

Depth Pyramid 생성, Temporal Delay와 Conservative Test 비용을 고려한다.

---

## CPU와 GPU Occlusion Culling

Baked PVS는 CPU가 Camera Cell의 Precomputed Data를 조회해 Draw 후보를 줄일 수 있다.

```text
CPU Baked Visibility
→ GPU에 보내기 전에 제외
```

GPU Hi-Z Culling은 GPU에서 대규모 Bounds를 검사해 Indirect Draw List를 만든다.

```text
GPU Runtime Visibility
→ Dynamic Occluder 반영 가능
→ GPU Buffer·Synchronization 필요
```

Scene의 Static 비율, Object 수와 Rendering Architecture에 따라 적합한 방식이 다르다.

---

## Temporal Coherence

Camera와 Object는 보통 Frame 사이에 조금씩 움직이므로 Visibility도 연속적이다.

```text
Frame N Visible
→ Frame N+1도 Visible일 가능성 높음
```

이전 Frame 결과를 재사용하면 Query와 Culling 비용을 줄일 수 있다.

하지만 빠른 Camera Teleport, Cut와 Door Open에서는 이전 Visibility가 틀릴 수 있다.

Conservative Expansion이나 Camera Movement 조건으로 Pop을 방지한다.

---

## Camera Teleport

Camera가 멀리 순간 이동하면 전혀 다른 Cell과 PVS를 사용한다.

```text
Frame N   Cell A
Frame N+1 Cell Z
```

Baked Occlusion Data는 새 Cell을 바로 조회할 수 있지만 Streaming Asset가 아직 준비되지 않았을 수 있다.

Runtime GPU Occlusion이 이전 Frame Depth를 사용한다면 Teleport Frame에 잘못된 결과가 생길 수 있다.

Camera Cut 시 History와 Visibility Cache Reset이 필요한지 확인한다.

---

## Occlusion Culling과 LOD

두 기법은 서로 다른 조건을 처리한다.

```text
Occlusion Culling
→ 다른 Geometry에 완전히 가려졌는가?

LOD
→ 보이지만 Screen에서 얼마나 작은가?
```

가려진 Object는 LOD Level과 관계없이 Draw하지 않을 수 있다.

보이는 먼 Object는 낮은 LOD나 Cull Level을 사용한다.

Frustum, Occlusion, Distance와 LOD를 조합해 Visible Set를 단계적으로 줄인다.

---

## Occlusion Culling과 Shadow

Main Camera에서 가려진 Object의 Shadow가 화면 안 Surface에 보일 수 있다.

```text
Camera Color
→ Object는 Wall 뒤

Directional Light
→ Object Shadow가 Ground에 투영 가능
```

Main Camera Occlusion 결과로 Renderer를 전역 비활성화하면 필요한 Shadow도 사라질 수 있다.

Unity Rendering Pipeline은 Camera Color Visibility와 Shadow Caster Visibility를 별도로 처리할 수 있다.

Custom Culling은 Pass별 요구를 구분해야 한다.

---

## Reflection과 다른 Camera

Main Camera에서 Wall 뒤에 가려진 Object가 Mirror Camera에는 보일 수 있다.

```text
Main Camera PVS
≠ Reflection Camera PVS
```

Occlusion Culling은 Camera Position과 Projection마다 결과가 달라진다.

Renderer.enabled를 Main Camera 결과로 끄면 다른 Camera에서도 사라진다.

Camera별 Culling Mask와 Pipeline Visibility를 사용한다.

---

## Occlusion Culling은 Simulation을 끄지 않는다

Renderer가 Occluded되어 Draw되지 않아도 Script, Physics, Animation과 Audio는 계속 실행될 수 있다.

```text
Occluded Renderer
→ Rendering 제외 가능

GameObject
→ Update·Physics·AI 유지 가능
```

Gameplay에 필요 없는 먼 NPC의 Simulation을 줄이려면 별도의 Distance·Interest Management가 필요하다.

Rendering Visibility를 그대로 Gameplay 활성 상태로 사용하면 Wall 뒤 Enemy AI가 멈추는 오류가 생길 수 있다.

---

## Animator와 Dynamic Occlusion

Character Renderer가 보이지 않을 때 Animator Culling Mode가 Animation Update를 줄일 수 있다.

하지만 Root Motion, IK와 Gameplay Bone이 필요하면 계속 갱신해야 한다.

```text
Renderer Occluded
≠ Animator가 자동으로 안전하게 정지 가능
```

Occlusion Visibility Callback과 Animator 정책을 연결할 때 여러 Camera, Shadow와 짧은 Visibility 변화에 의한 Thrashing을 고려한다.

---

## Occlusion Visualization

Unity Occlusion Culling Window의 Visualization Mode에서 Camera 위치에 따른 Cell과 Visible Object를 확인할 수 있다.

```text
Visualization
├─ View Cell
├─ Camera Volume
├─ Visible Renderer
├─ Culled Renderer
└─ Occlusion Data 범위
```

Unity Version에 따라 표시 Option과 색은 다를 수 있다.

Camera를 Gameplay Path로 이동하며 Wall 뒤 Room이 실제로 제외되는지 확인한다.

---

## Visualization에서 볼 질문

```text
□ Camera가 유효한 View Cell 안에 있는가?
□ 큰 Wall 뒤 Renderer가 Culled되는가?
□ Window를 통해 보이는 Renderer가 유지되는가?
□ Door가 열린 상태에서 잘못 사라지지 않는가?
□ Cell 경계에서 Object가 Flicker하지 않는가?
□ Dynamic Character가 Static Wall 뒤에서 제외되는가?
□ Camera 높이가 바뀌면 결과가 자연스러운가?
```

한 위치의 Screenshot보다 Camera를 천천히 이동하는 검사가 중요하다.

---

## Frame Debugger

Occluded Object가 Main Camera Draw Event에서 실제로 제외됐는지 확인한다.

```text
Frame Debugger 질문
├─ Opaque Pass에 Draw가 있는가?
├─ Depth Prepass에 남아 있는가?
├─ Shadow Pass에만 있는가?
├─ Reflection Camera가 그리는가?
└─ Scene View Camera 때문인가?
```

Occlusion Visualization에서 Culled로 보여도 다른 Camera와 Pass의 Draw는 남을 수 있다.

Frame Event와 Camera를 정확히 연결한다.

---

## Rendering Profiler

Occlusion Culling On·Off 상태에서 Batches, SetPass, Triangle와 Vertex를 비교한다.

```text
Occlusion Off
Batches   1800
Triangles 6.0M

Occlusion On
Batches    900
Triangles 2.5M
```

숫자는 기록 형식의 예시다.

Culling 통계 감소가 CPU와 GPU Frame Time 개선으로 이어지는지 별도로 측정한다.

---

## CPU Profiler

Occlusion Culling에는 Runtime Visibility Query와 Data Lookup 비용이 있다.

```text
CPU Trade-off
Occlusion Query Cost
vs
Saved Culling·Sorting·Submission Cost
```

가려지는 Object가 거의 없으면 Query 비용만 늘어날 수 있다.

Camera 수와 Scene Object 수가 많으면 Camera별 Culling 비용을 확인한다.

Occlusion On·Off의 Main Thread와 Render Thread 시간을 비교한다.

---

## GPU Profiler

가려진 Renderer가 제외되면 Opaque, Transparent와 일부 Vertex 비용이 줄 수 있다.

```text
Before
Opaque 6.0 ms

After
Opaque 4.2 ms
```

Depth Test와 Early-Z가 이미 Fragment를 잘 제거하던 Scene에서는 GPU Pixel 시간 감소가 작을 수 있다.

고밀도 Mesh와 많은 Draw가 Wall 뒤에 있을수록 CPU·Vertex 절감이 커질 수 있다.

Target Device에서 Pass별 GPU Time을 확인한다.

---

## Occlusion On·Off A/B Test

동일 Camera와 Frame에서 Camera의 Occlusion Culling을 On·Off로 비교한다.

```text
고정 조건
├─ Camera Transform
├─ Resolution
├─ Quality
├─ Object 상태
├─ Particle Time
└─ VSync·FPS Cap
```

다음 항목을 기록한다.

| 항목 | Off | On | 차이 |
|---|---:|---:|---:|
| Culling CPU ms | 0.4 | 0.8 | +0.4 |
| Draw Calls | 1600 | 700 | -900 |
| Triangles | 5.2M | 2.0M | -3.2M |
| GPU ms | 15.0 | 10.5 | -4.5 |

값은 측정 양식의 예시다.

---

## Camera Path Test

Occlusion 효과는 Camera 위치에 따라 달라진다.

```text
Test Points
├─ Room Center
├─ Door 앞
├─ Corridor
├─ Window 옆
├─ Rooftop
└─ Open Field
```

Room Center에서는 많은 Object가 Culled되고 Door 앞에서는 뒤 Room이 Visible로 전환될 수 있다.

평균, Minimum과 Maximum Visible Renderer 수를 Camera Path 전체에서 기록한다.

---

## 빠른 Camera Movement

Camera가 Cell 경계를 빠르게 통과할 때 Object가 늦게 나타나거나 Flicker하지 않는지 확인한다.

```text
Walk Speed
Sprint Speed
Vehicle Speed
Teleport
Cutscene Cut
```

Occlusion Area, Cell 정밀도와 Streaming 준비 상태가 함께 영향을 준다.

정지 Camera Screenshot만으로 Culling 안정성을 검증할 수 없다.

---

## Bake Parameter 조정 순서

대표 Scene Scale을 기준으로 단계적으로 조정한다.

```text
1. Camera 이동 영역에 Occlusion Area 배치
2. 큰 Static Geometry의 Occluder 역할 확인
3. 가려질 Renderer의 Occludee 역할 확인
4. 기본 Setting으로 Bake
5. Visualization과 Camera Path 검사
6. Smallest Occluder·Hole을 한 항목씩 조정
7. Data Size·Bake Time 기록
8. Runtime On·Off Profile
```

Setting을 여러 개 동시에 바꾸면 어떤 값이 결과를 바꿨는지 알기 어렵다.

---

## Occluder Proxy

시각 Mesh가 복잡하거나 구멍이 많으면 단순한 불투명 Proxy Geometry를 Occluder로 사용할 수 있다.

```text
Visual Building
→ Window·Detail가 많음

Occluder Proxy
→ 큰 Wall Volume 중심
```

Proxy가 실제 시야를 막는 범위보다 크면 보이는 Object를 잘못 제거할 수 있다.

Render되지 않는 Occlusion용 Geometry를 사용할 때 Camera Path와 Opening을 철저히 검증한다.

---

## Occlusion 최적화 우선순위

큰 가림 이득을 만드는 구조부터 정리한다.

```text
1. 실내 Room·큰 Wall을 Occluder로 구성
2. 작은 Prop는 Occludee 중심으로 설정
3. Camera가 이동하지 않는 공간 제외
4. Room 경계에 맞춰 큰 Combined Mesh 분할
5. Door·Window Opening 검증
6. Camera별 Use Occlusion Culling 비교
7. Bake Data Size와 Memory 확인
8. Multi-scene·Streaming 경계 검사
9. Dynamic Layout은 대체 Visibility 검토
10. Target Device On·Off Profile
```

Occlusion Culling을 켜는 것 자체가 목적이 아니라 제거 이득이 Query와 Data 비용보다 큰 상태를 만드는 것이 목적이다.

---

## 흔한 오해

### Frustum 안이면 모두 그려야 한다

Frustum 안에서도 Wall과 Building 뒤에 완전히 가려진 Renderer는 Occlusion Culling으로 제외할 수 있다.

### Depth Test가 있으므로 Occlusion Culling은 필요 없다

Depth는 Fragment를 제거하지만 Draw Submission과 Vertex 비용이 남을 수 있다.

### Occlusion Culling은 모든 Scene에서 빠르다

Open Field처럼 가려지는 Object가 적으면 Runtime Query와 Data 비용 대비 이득이 작을 수 있다.

### 작은 Object도 모두 Occluder로 설정해야 한다

작은 Prop는 안정적인 가림을 만들지 못하면서 Bake 복잡도만 늘릴 수 있다.

### Dynamic Object도 Static Wall처럼 다른 Object를 가린다

기본 Baked Data는 Runtime에 움직이는 Occluder 위치를 완전히 반영하기 어렵다.

### Occlusion Culling은 Animation과 AI도 멈춘다

Renderer Draw를 제외할 뿐 Simulation은 별도 설정이 필요하다.

### Camera 하나에서 Culled이면 모든 Camera에서 필요 없다

Reflection, Shadow, Mini Map과 다른 Camera에서는 보일 수 있다.

### Bake Setting을 가장 작게 하면 가장 좋다

Bake Time, Data Size와 Pop Risk가 증가할 수 있으며 Runtime ms 이득은 보장되지 않는다.

### Mesh를 크게 합치면 Occlusion Culling도 좋아진다

Bounds가 여러 Room을 걸치면 일부가 보일 때 전체 Mesh가 남을 수 있다.

### Occlusion Visualization에서 안 보이면 모든 Pass에서 제거됐다

Shadow와 다른 Camera Pass에는 Draw가 남을 수 있어 Frame Debugger 확인이 필요하다.

### Occlusion Culling은 Asset Streaming이다

Rendering 후보에서 제외할 뿐 Mesh와 Texture Memory를 자동으로 해제하지 않는다.

---

## 최종 체크리스트

```text
□ Frustum 안에서 실제로 완전히 가려진 Renderer가 많은가?
□ 큰 불투명 Wall·Building·Terrain을 Occluder로 사용했는가?
□ 작은 Prop와 투명 Geometry를 불필요한 Occluder로 넣지 않았는가?
□ 가려질 Static Renderer의 Occludee 설정을 확인했는가?
□ Camera 이동 영역을 Occlusion Area가 정확히 포함하는가?
□ 사용하지 않는 빈 공간에 Cell을 만들지 않았는가?
□ Smallest Occluder가 Scene Scale에 맞는가?
□ Smallest Hole이 Door·Window 크기를 반영하는가?
□ Backface Threshold 변경 이유가 명확한가?
□ Bake Time과 Occlusion Data Size를 기록했는가?
□ Door·Elevator 같은 Dynamic Occluder를 Static으로 가정하지 않았는가?
□ Dynamic Character가 Static Wall 뒤에서 자연스럽게 Culled되는가?
□ 큰 Combined Mesh가 Room 경계를 넘지 않는가?
□ Renderer Bounds가 과도하게 크거나 작지 않은가?
□ Multi-scene과 Streaming 경계에서 Data가 유효한가?
□ Procedural Level에 Baked 방식이 적합한가?
□ Main·Reflection·Mini Map Camera별 효율을 확인했는가?
□ Shadow Caster Visibility를 전역으로 제거하지 않았는가?
□ Occlusion이 Simulation Culling이 아님을 구분했는가?
□ Visualization에서 Camera Path 전체를 확인했는가?
□ Frame Debugger에서 실제 Draw 제외를 확인했는가?
□ Occlusion On·Off의 CPU·GPU ms를 비교했는가?
□ 빠른 Camera, Teleport와 Door 전환에서 Pop이 없는가?
□ Target Device의 Worst-case Scene에서 검증했는가?
```

---

## 정리

Occlusion Culling은 Camera Frustum 안에 있지만 Wall, Building과 Terrain 뒤에 완전히 가려진 Renderer를 Visible Set에서 제외하는 기법이다.

Depth Test보다 앞에서 Object Draw 자체를 제거할 수 있어 CPU Sorting·Submission과 GPU Vertex·Rasterization·Depth 작업까지 줄일 가능성이 있다.

Unity의 기본 방식은 Static Occluder와 Occludee를 분석해 Camera 공간을 Cell로 나누고 Cell별 Potentially Visible Set를 미리 Bake한다.

Smallest Occluder, Smallest Hole과 Occlusion Area의 정밀도를 높이면 가림 판정이 세밀해질 수 있지만 Bake Time, Data Memory와 Pop Risk가 증가한다.

큰 Static Wall은 좋은 Occluder이고 작은 Prop는 Occludee로 적합하며 Dynamic Door·Vehicle가 다른 Object를 가리는 관계는 Precomputed Data에 한계가 있다.

실내와 Street Level Scene은 많은 Renderer를 제거할 수 있지만 Open Field와 Top-down Camera에서는 Query 비용 대비 이득이 작을 수 있다.

Occlusion Visualization과 Frame Debugger로 실제 Draw 제외를 확인하고 Camera Path 전체의 On·Off CPU·GPU Profile을 통해 Target Device에서 손익을 검증해야 한다.
