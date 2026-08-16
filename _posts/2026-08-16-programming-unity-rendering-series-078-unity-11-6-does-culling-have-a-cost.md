---
title: "[Unity 렌더링] 11-6. Culling 자체에도 비용이 있을까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - Culling
  - Profiling
  - Optimization
permalink: /programming/unity-11-6-does-culling-have-a-cost/
toc: true
toc_sticky: true
date: 2026-08-16
last_modified_at: 2026-08-16
---

Culling은 불필요한 Draw를 줄이지만 무엇이 보이는지 판정하는 작업 자체에도 CPU, GPU와 Memory 비용이 든다.

```text
Culling Cost
├─ Bounds 갱신
├─ 공간 구조 탐색
├─ Plane·Distance Test
├─ Occlusion Data 조회
├─ Visible List 생성
└─ Camera별 반복
```

최적화 효과는 Culling에 사용한 비용보다 제거한 Rendering 비용이 클 때 발생한다.

```text
Net Benefit
= Saved Rendering Cost
- Culling Cost
```

Object가 많고 가려지는 비율이 높을수록 이득이 커질 가능성이 있지만 작은 저비용 Object 몇 개를 복잡하게 판정하면 오히려 느려질 수 있다.

---

## Culling은 하나의 연산이 아니다

Camera가 Renderer를 제외하기까지 여러 종류의 작업이 연결된다.

```text
Scene State Update
       │
       ▼
Transform·Bounds 갱신
       │
       ▼
Spatial Structure Update·Query
       │
       ▼
Layer·Distance Filtering
       │
       ▼
Frustum Test
       │
       ▼
Occlusion Visibility
       │
       ▼
LOD Selection
       │
       ▼
Visible Renderer List
```

정확한 Unity 내부 흐름은 Version, Render Pipeline과 Renderer 종류에 따라 달라질 수 있다.

각 단계가 후보를 줄이지만 Data 갱신과 판정 시간을 사용한다.

---

## 가장 단순한 손익 관계

Object 하나에 Culling Test 비용 `C`가 들고 Draw했을 때 Rendering 비용 `R`이 든다고 단순화한다.

```text
Object가 Visible
→ Culling C + Rendering R

Object가 Culled
→ Culling C
```

Object가 Culled되면 `R`을 아끼지만 `C`는 계속 지불한다.

```text
절감 = R - Culling 추가 비용
```

`R`이 매우 작고 `C`가 복잡하면 Culling의 순이익이 작거나 음수가 될 수 있다.

---

## 많은 Object에서 누적된다

Object당 Test가 매우 짧아도 수십만 개에 반복하면 CPU 시간이 된다.

```text
10 ns × 100 Objects
→ 매우 작음

10 ns × 1,000,000 Objects
→ 약 10 ms 개념
```

숫자는 반복 비용 관계를 설명하기 위한 단순 예시다.

실제 Cost에는 Cache Miss, Branch, Job Scheduling과 공간 구조 탐색이 포함된다.

Object 수가 커질수록 Linear Scan을 피하고 Spatial Hierarchy로 후보를 먼저 줄이는 이유다.

---

## Bounds를 계산하고 유지하는 비용

Frustum과 Occlusion 판정에는 Renderer의 World Bounds가 필요하다.

```text
Local Bounds
+ Transform Matrix
→ World Bounds
```

Static Renderer는 Bounds 변화가 적지만 움직이는 Renderer는 Transform 변화에 따라 World Bounds를 갱신해야 한다.

```text
Moving Objects
├─ Transform 변경
├─ Bounds 갱신
└─ Spatial Structure 갱신 가능
```

Object가 보이지 않아도 움직이면 다음 Visibility Query를 위해 Bounds Data를 유지할 수 있다.

---

## AABB 갱신 비용

회전된 Local Bounds를 World AABB로 변환하려면 Center와 Extents를 새 Coordinate에 맞게 계산한다.

```text
Local Box
→ Scale·Rotation·Translation
→ World Axis-aligned Box
```

Rotation이 바뀌면 World AABB 크기도 달라질 수 있다.

Transform이 자주 바뀌는 Renderer 수가 많으면 Bounds 갱신과 공간 자료 구조 재삽입 비용이 누적될 수 있다.

Static으로 유지할 수 있는 Geometry를 매 Frame 움직이지 않는다.

---

## Skinned Mesh Bounds

Skinned Mesh는 Bone Animation으로 Vertex 범위가 변한다.

```text
Skeleton Pose
→ Skinned Vertex 범위
→ Renderer Bounds
```

정확한 Bounds를 매 Frame 모든 Vertex에서 계산하면 비싸므로 Precomputed Bounds와 Animation 범위를 이용할 수 있다.

`Update When Offscreen`을 사용하면 화면 밖에서도 Skinning과 Bounds 갱신이 계속될 수 있다.

잘못된 Bounds로 Pop을 막기 위해 무조건 크게 만들면 Culling 효율이 낮아진다.

정확성과 갱신 비용 사이의 Trade-off가 있다.

---

## Particle Bounds

Particle System Bounds는 살아 있는 Particle의 Position, Size와 이동 범위를 포함해야 한다.

```text
Emitter
├─ Velocity
├─ Lifetime
├─ Size
├─ Trail
└─ Simulation Space
```

매 Frame 정확한 Bounds를 추적하면 Simulation Data를 검사하는 비용이 들 수 있다.

고정 Bounds는 갱신 비용을 줄일 수 있지만 너무 크면 Effect가 화면 밖이어도 Renderer가 Visible 후보로 남는다.

Effect 특성과 Camera Path에 맞춰 Bounds 방식을 선택한다.

---

## 공간 자료 구조

모든 Renderer를 Camera와 하나씩 비교하는 대신 Object를 공간 계층으로 묶는다.

```text
World Root
├─ Node A Bounds
│  ├─ Renderer 1
│  └─ Renderer 2
├─ Node B Bounds
└─ Node C Bounds
```

Parent Node가 Frustum 밖이면 내부 Renderer를 개별 검사하지 않아도 된다.

```text
Parent Outside
→ Child 전체 Reject
```

Query는 빨라지지만 Object 이동 시 Tree를 갱신하고 Node Memory를 관리하는 비용이 생긴다.

---

## Static과 Dynamic 공간 구조

Static Object는 한 번 배치한 공간 구조를 오래 재사용할 수 있다.

```text
Static BVH·Tree
→ Build 비용은 초기·Bake 시점
→ Runtime Query 중심
```

Dynamic Object는 Cell이나 Tree Node 사이를 이동한다.

```text
Dynamic Structure
→ Remove old position
→ Insert new position
→ Bounds refit
```

수만 개 Object가 매 Frame 크게 이동하면 구조 유지 비용이 Culling Query보다 커질 수 있다.

Static Environment와 Dynamic Actor를 다른 구조로 관리하는 이유다.

---

## Frustum Plane Test 비용

Bounds 하나는 최대 여섯 Frustum Plane과 비교할 수 있다.

```text
Left
Right
Top
Bottom
Near
Far
```

한 Plane에서 Bounds가 완전히 Outside이면 나머지 Test를 생략할 수 있다.

```text
Early Reject
→ Outside Plane 발견
→ 즉시 Cull
```

Plane 순서와 Scene 분포에 따라 평균 Test 수가 달라질 수 있지만 일반 개발자가 Unity 내부 순서를 직접 조정하는 영역은 제한적이다.

---

## Bounds 크기가 Test 이득에 미치는 영향

Bounds가 지나치게 크면 Frustum과 자주 교차해 Culling Test를 통과한다.

```text
Culling 비용 지불
+ Draw 비용도 지불
```

False Positive가 많으면 판정 비용은 그대로인데 Rendering 절감이 줄어든다.

큰 Combined Mesh, Trail과 GPU Deformation Margin을 확인한다.

Bounds를 정확하게 만드는 것은 화면 오류뿐 아니라 Culling 손익에도 중요하다.

---

## Camera마다 반복되는 비용

각 Camera는 서로 다른 View Volume과 Culling Mask를 가진다.

```text
Main Camera Culling
+ Reflection Camera Culling
+ Mini Map Camera Culling
+ Portal Camera Culling
+ Scene View Camera Culling
```

Renderer 수가 같아도 Camera가 늘면 Visibility Query와 Visible List 생성이 반복될 수 있다.

Camera Stack도 Base·Overlay Camera별 Layer와 Rendering 요구를 확인해야 한다.

불필요한 Camera 하나를 제거하는 것이 개별 Bounds Test 최적화보다 큰 효과를 낼 수 있다.

---

## Reflection Probe의 반복

Realtime Reflection Probe는 Cubemap 여섯 Face를 Rendering할 수 있다.

```text
Cubemap Faces
├─ +X
├─ -X
├─ +Y
├─ -Y
├─ +Z
└─ -Z
```

각 Face는 다른 방향의 Frustum과 Visible Set를 요구한다.

Probe Update 한 번에 Culling과 Draw가 여러 번 발생할 수 있다.

Refresh Mode, Time Slicing, Culling Mask와 Update Frequency를 제한한다.

---

## Shadow Culling 비용

Shadow를 만드는 Light는 Light 기준의 Culling Volume에서 Shadow Caster를 찾는다.

```text
Main Camera Visibility
≠ Directional Shadow Visibility
≠ Point Light Cube Faces
```

Directional Cascade 수가 늘면 Cascade별 Caster 범위와 Draw 준비가 반복될 수 있다.

Point Light Shadow는 여섯 방향 Face를 사용할 수 있다.

Light와 Shadow 수가 많으면 Camera Object Culling 외의 Visibility 비용도 커진다.

---

## Layer Filtering 비용

Camera Culling Mask와 Rendering Layer는 Renderer 후보를 빠르게 제외하는 조건이다.

```text
Layer Mask Test
→ 불일치하면 Reject
```

Bit Mask 비교 자체는 저렴하지만 잘못 구성하면 다음 정밀 Test와 Draw 후보가 불필요하게 늘어난다.

Mini Map, Reflection과 Shadow Camera에 필요한 Layer만 포함하면 이후 Culling과 Rendering 작업을 함께 줄일 수 있다.

---

## Distance Culling 비용

Object Position이나 Bounds와 Camera Distance를 비교해 멀리 있는 Object를 제거할 수 있다.

```text
distanceSquared
= dot(delta, delta)
```

Square Root 없이 Squared Distance를 비교하면 단순 Custom Test 비용을 줄일 수 있다.

하지만 모든 MonoBehaviour의 `Update`에서 개별 거리 계산을 수행하면 Script Dispatch와 Cache 비효율이 커질 수 있다.

Camera Layer Cull Distance, LOD Group, CullingGroup과 공간 Chunk를 먼저 검토한다.

---

## CullingGroup의 관리 비용

`CullingGroup`은 많은 Bounding Sphere의 Visibility와 Distance Band를 중앙에서 관리한다.

```text
CullingGroup
├─ Bounding Sphere Array
├─ Target Camera
├─ Distance Reference Point
└─ State Changed Callback
```

Object마다 Update를 호출하는 것보다 효율적일 수 있지만 Sphere Array와 Index Mapping을 갱신해야 한다.

움직이는 Target가 많으면 Center 갱신과 Callback 처리 비용이 생긴다.

State 변화가 없는 Frame에도 불필요한 Gameplay 작업을 수행하지 않도록 Event 기반으로 사용한다.

---

## LOD 선택 비용

Visible Object는 Camera에서 보이는 상대 Screen Size나 Distance로 LOD Level을 선택한다.

```text
Bounds·Reference Point
→ Screen Relative Height
→ LOD0·LOD1·LOD2·Cull
```

LOD는 Rendering을 줄이지만 Level 판정과 Fade 상태 관리가 필요하다.

Cross-fade 구간에서는 두 LOD가 동시에 Draw되어 Culling 절감과 반대로 Geometry·Fragment가 일시적으로 증가할 수 있다.

---

## Sorting과 Visible List 생성

Culling 이후 남은 Renderer를 연속적인 Visible List에 기록하고 Sorting한다.

```text
Candidates
→ Visibility Flags
→ Compaction
→ Visible List
→ Opaque·Transparent Sort
```

Culling 결과가 Sparse하면 List Compaction과 Memory Write가 필요하다.

하지만 Visible 수가 크게 줄면 이후 Sorting, Batching과 Command 생성 비용을 절약한다.

Culling 단계만 떼어 보지 않고 후속 작업 절감까지 포함해 평가한다.

---

## Occlusion Culling Runtime 비용

Baked Occlusion Data를 사용해도 Runtime 비용은 0이 아니다.

```text
Runtime Occlusion
├─ Camera Cell 찾기
├─ PVS Data 조회
├─ Dynamic Bounds Visibility 판정
├─ Visible Bitset·List 처리
└─ Camera별 결과 생성
```

Occlusion Data가 크면 Cache Locality와 Memory Read 비용도 중요하다.

실내에서 Draw 수천 개를 줄이면 이득이 크지만 Open Field에서 거의 제거하지 못하면 손해가 될 수 있다.

---

## Occlusion Bake 비용

Bake는 Runtime Frame Time에는 직접 포함되지 않지만 개발 시간과 Build Workflow 비용이다.

```text
Bake Cost
├─ 계산 시간
├─ CI·Build 시간
├─ Data Storage
├─ Scene 변경 후 재Bake
└─ 결과 검증 시간
```

Smallest Occluder·Hole을 작게 설정하고 Area를 크게 만들면 Bake와 Data가 증가할 수 있다.

Runtime 0.1ms를 줄이기 위해 매 Level Build 시간을 크게 늘리는 것이 전체 Project에 유리한지도 판단한다.

---

## Occlusion Data Memory

View Cell과 Potentially Visible Set Data는 Runtime Memory를 사용한다.

```text
Occlusion Benefit
→ Draw·GPU 작업 감소

Occlusion Cost
→ CPU Query + Data Memory
```

Memory가 부족하면 Texture Streaming, Asset Load와 다른 System에 영향을 줄 수 있다.

Mobile과 여러 Additive Scene을 동시에 Load하는 경우 Data Size를 확인한다.

---

## Hardware Occlusion Query 비용

Runtime GPU Query는 Proxy Bounds를 Rasterize하고 통과한 Sample 수를 확인할 수 있다.

```text
Depth 준비
→ Bounds Query Draw
→ GPU 결과 생성
→ CPU 또는 GPU가 결과 사용
```

Query Object가 많으면 Proxy Draw와 Result Buffer 비용이 늘어난다.

CPU가 같은 Frame 결과를 기다리면 GPU Pipeline Stall이 발생할 수 있다.

이전 Frame 결과를 사용하면 Stall은 줄지만 빠른 Camera에서 Visibility가 한 Frame 늦을 수 있다.

---

## Hi-Z Culling 비용

GPU Hi-Z Occlusion은 Depth Pyramid를 생성하고 Object Bounds를 Screen Rect·Depth로 비교한다.

```text
Depth Buffer
→ Mip Pyramid 생성
→ Compute Culling
→ Visible List
```

비용은 다음처럼 나뉜다.

```text
Depth Pyramid Pass
Compute Dispatch
Bounds Buffer Read
Visible Flag Write
Compaction
Indirect Args 생성
```

대규모 Instance에서 Draw 절감이 크면 유리하지만 Object 수가 적으면 Fixed Dispatch 비용이 더 클 수 있다.

---

## GPU Frustum Culling 비용

Compute Shader에서 Instance Bounds와 여섯 Plane을 병렬로 비교할 수 있다.

```text
Instance Buffer
+ Frustum Planes
→ GPU Threads
→ Visible Instance Indices
```

Plane Test는 병렬화하기 좋지만 Visible List를 만들기 위한 Atomic Append, Prefix Sum 또는 Compaction이 필요하다.

GPU가 Culling을 수행해도 CPU가 결과를 Readback하면 Synchronization 비용이 생긴다.

Indirect Draw까지 GPU 안에서 이어야 CPU Stall을 피하기 쉽다.

---

## Dispatch 고정 비용

Compute Culling은 Object 수가 10개여도 Command Encoding, Resource Binding과 Dispatch가 필요하다.

```text
Small Workload
Dispatch Cost > Saved Draw 가능

Large Workload
Saved Draw >> Dispatch Cost 가능
```

작은 Renderer Group마다 Compute Dispatch를 따로 실행하지 않고 충분한 Batch로 묶는다.

Batch가 너무 크면 Culling Granularity와 Buffer Memory가 불리할 수 있다.

---

## Visible List Compaction

각 Instance의 Visibility Boolean만 계산해도 Draw하려면 Visible Instance를 연속 List로 모아야 한다.

```text
Flags
[1, 0, 1, 0, 0, 1]

Compacted Indices
[0, 2, 5]
```

Parallel Prefix Sum, Atomic Counter와 Append Buffer를 사용할 수 있다.

Visibility가 거의 100%라면 Compaction 비용을 내고도 제거되는 Instance가 적다.

Camera와 Scene별 Visibility Ratio를 측정해야 한다.

---

## Indirect Draw의 비용

GPU Culling 결과를 `DrawMeshInstancedIndirect`나 Render Pipeline의 Indirect 경로로 그릴 수 있다.

```text
Compute Culling
→ Indirect Argument Buffer
→ GPU Draw
```

CPU Draw Call 수를 줄일 수 있지만 Buffer Lifetime, Barrier와 Shader 호환성을 관리해야 한다.

Small Batch, 다양한 Material과 Lightmap Index는 Group을 분리해 Indirect Draw 수를 늘릴 수 있다.

---

## Batch 단위 Culling

Dynamic Batching, Static Batching과 GPU Instancing은 여러 Object를 Draw Group으로 묶는다.

```text
큰 Batch
→ Draw 적음
→ Bounds가 커질 수 있음

작은 Batch
→ Fine Culling
→ Draw·State 관리 증가
```

Batch Bounds 일부가 Frustum에 걸리면 그룹 전체를 처리하는 경로가 있을 수 있다.

Unity 기능별 실제 Culling Granularity를 Frame Debugger와 공식 문서에서 확인한다.

---

## GPU Instancing Group

같은 Mesh·Material의 Instance를 묶으면 Submission 비용을 줄인다.

```text
Trees 1000
→ Instance Group
```

API에 따라 Group Bounds로 한 번 Cull하고 내부 Instance를 모두 그릴 수 있다.

멀리 흩어진 Instance를 하나의 Group으로 묶으면 Bounds가 World 전체를 덮어 항상 Visible가 될 수 있다.

Spatial Cell별 Instance Group으로 나누면 Draw 수와 Culling 정밀도 사이를 조정할 수 있다.

---

## GPU Resident Drawer

Unity 6의 GPU Resident Drawer는 호환 Renderer Data를 GPU에 유지하고 GPU-driven 방식으로 Draw Submission 효율을 높일 수 있다.

```text
GPU-resident Renderer Data
→ Batch·Culling
→ Indirect Drawing
```

호환 조건, Render Pipeline, Renderer Type와 Material 설정에 따라 적용 범위가 달라진다.

기능을 켠다고 Culling이 무료가 되는 것은 아니며 GPU Memory, Compute와 Visible List 관리 비용을 사용한다.

Unity Version의 URP 설정과 Profiler 결과를 확인한다.

---

## BatchRendererGroup Culling Callback

`BatchRendererGroup`은 Custom Renderer Batch의 Culling Callback을 제공한다.

```text
OnPerformCulling
├─ Culling Context
├─ Plane Data
├─ Visibility 결과
└─ Draw Commands 생성
```

대규모 Custom Rendering을 제어할 수 있지만 Job Scheduling, Native Memory와 Draw Command Output을 직접 관리해야 한다.

모든 Frame과 Camera 호출에서 Allocation하거나 Main Thread에 의존하면 Culling 이점을 잃을 수 있다.

---

## Custom SRP의 Culling

Scriptable Render Pipeline은 Camera에서 `ScriptableCullingParameters`를 얻고 Context에 Culling을 요청할 수 있다.

```text
Camera
→ Culling Parameters
→ ScriptableRenderContext.Cull
→ CullingResults
→ DrawRenderers·RendererList
```

Culling 결과는 Visible Lights, Reflection Probes와 Renderer 정보를 포함할 수 있다.

Camera마다 Culling을 중복 호출하거나 필요 이상으로 큰 Shadow Distance를 사용하면 비용이 늘 수 있다.

---

## Light Culling 비용

Forward와 Forward+는 Renderer나 Screen Tile에 영향을 주는 Light를 선별한다.

```text
Visible Lights
→ Frustum·Range Culling
→ Tile·Cluster Light List
```

Light가 많으면 Light Bounds 판정과 List 생성 비용도 커진다.

Renderer Culling만 줄이고 수천 개 Light의 Cluster Culling을 놓치면 전체 Culling 시간이 높게 남을 수 있다.

Light Range와 활성 Light 수를 제한한다.

---

## Decal Culling 비용

Decal Projector도 Bounds와 Camera·Rendering Layer로 Visible 후보를 판정할 수 있다.

```text
Decal Bounds
→ Camera Frustum
→ Receiver Filtering
→ Draw·DBuffer
```

작은 Bullet Decal가 Runtime에 계속 누적되면 Culling 대상과 Data 관리 비용이 증가한다.

Lifetime과 Pool Budget으로 Scene에 남는 Decal 수를 제한한다.

---

## Particle Culling의 손익

Particle System 하나를 Bounds로 Cull하면 수천 Particle Draw를 한 번에 제거할 수 있다.

```text
System Bounds Outside
→ 큰 Rendering 절감
```

반대로 Bounds가 매우 크면 실제 Particle가 보이지 않아도 Test를 통과한다.

System을 공간적으로 너무 잘게 나누면 Component, Draw와 Simulation 관리 비용이 늘어난다.

Effect 범위와 동시 System 수를 기준으로 분할한다.

---

## 작은 Object Culling의 역효과

Triangle 두 개짜리 작은 Marker 100개를 정밀 Occlusion Query로 각각 검사한다고 가정한다.

```text
Saved Rendering
→ 매우 단순한 Quad 일부

Culling
→ Query 100개 + Result 관리
```

Depth Test와 Batch 한 번으로 그리는 편이 더 빠를 수 있다.

Object가 작고 Shader가 단순하며 Batch가 잘 되는 경우 Fine-grained Culling은 이득이 작다.

---

## 큰 Object Culling의 큰 이득

Wall 뒤 Skinned Character 100개와 High-poly Building가 있다고 가정한다.

```text
한 Occlusion Query·PVS Lookup
→ Draw 수백 개
→ Vertex 수백만 개
→ Shadow·Fragment 일부 절감 가능
```

판정 비용에 비해 Saved Rendering Cost가 크다.

Culling 우선순위는 Object 수뿐 아니라 Object당 Draw·Vertex·Shader 비용을 반영해야 한다.

---

## 가시 비율이 중요하다

같은 Object 수라도 Camera에 보이는 비율에 따라 손익이 달라진다.

```text
Scene A
100,000 Objects
Visible 5%
→ Culling 이득 큼 가능

Scene B
100,000 Objects
Visible 95%
→ Test 비용 대비 제거 적음
```

실내 Room과 거리 기반 Forest는 낮은 Visible Ratio를 만들 수 있다.

Top-down Map와 Open Field는 높은 Visible Ratio가 될 수 있다.

---

## Object당 Rendering 비용이 중요하다

같은 1,000 Renderer라도 비용은 다르다.

```text
Case A
1,000 Simple Quads

Case B
1,000 Skinned Lit Meshes
```

Case B는 Animation, Vertex, Material Pass와 Shadow 비용이 커 Culling 이득이 훨씬 클 수 있다.

Renderer Count만으로 Culling 가치와 Threshold를 정하지 않는다.

---

## Culling Granularity

Granularity는 한 번의 Visibility 판정으로 제거하는 공간·Object 단위다.

```text
Coarse
→ Building Block 단위

Fine
→ Window Prop 하나 단위
```

Coarse Culling은 Test 수가 적지만 False Positive가 많다.

Fine Culling은 정확하지만 Test, Renderer와 Draw Group 관리가 늘어난다.

Scene 구조에 맞는 중간 단위를 찾는 것이 핵심이다.

---

## Hierarchy Depth

BVH나 Octree가 너무 얕으면 Leaf에 Object가 많아 개별 Test가 늘어난다.

너무 깊으면 Node Traversal, Pointer·Index Read와 Memory가 증가한다.

```text
Shallow Tree
→ Coarse Nodes

Deep Tree
→ Many Nodes
```

Object Density, World Size와 Camera Frustum 형태에 맞춰 구조를 구성한다.

Unity 기본 구조는 Engine이 관리하지만 Custom GPU·World System에서는 직접 Profile해야 한다.

---

## Cache Locality

Culling은 Bounds와 Transform Data를 대량으로 순회한다.

```text
연속 Bounds Array
→ Cache-friendly 가능

분산된 GameObject Component
→ Pointer Chase·Cache Miss 가능
```

Data-oriented Layout과 Burst Job은 대규모 Custom Culling에서 CPU Throughput을 높일 수 있다.

Object별 Virtual Call과 Managed Allocation을 피하고 연속 Native Container를 재사용한다.

---

## Branch와 SIMD

Bounds마다 다른 Plane에서 Reject되면 Branch Pattern이 불규칙할 수 있다.

```text
Object A → Left Plane Reject
Object B → Top Plane Reject
Object C → All Pass
```

CPU SIMD나 GPU Wave에서 여러 Bounds를 병렬 처리할 때 Divergence와 Data Layout이 처리량에 영향을 줄 수 있다.

일반 Project에서는 복잡한 Micro-optimization 전에 Algorithm과 Candidate 수를 줄이는 편이 더 큰 효과를 낸다.

---

## Job Scheduling 비용

Unity Job System으로 Culling을 병렬화하면 Main Thread 시간을 줄일 수 있다.

```text
Schedule Jobs
→ Worker Culling
→ Dependency Complete
→ Visible List 사용
```

Object 수가 적으면 Job Scheduling과 Synchronization 비용이 실제 Plane Test보다 클 수 있다.

충분한 Batch Size를 사용하고 다른 Rendering Preparation Job과 의존성을 연결한다.

Profiler Timeline에서 Worker Utilization과 Wait를 확인한다.

---

## Allocation 비용

Custom Culling에서 매 Frame Plane Array, List와 Bounds Array를 새로 만들면 Garbage Collection과 Memory Allocation이 발생한다.

```csharp
// 매 Frame 새 List를 만드는 구조는 피한다.
var visible = new List<Renderer>();
```

Capacity를 미리 확보한 Container를 재사용하고 `GeometryUtility.CalculateFrustumPlanes`의 재사용 가능한 Overload를 검토한다.

GPU Buffer도 매 Frame 생성·해제하지 않고 Lifecycle을 관리한다.

---

## Transform 접근 비용

Custom Script가 수만 개 Object의 `transform.position`을 개별 Component 접근으로 읽으면 Culling Math보다 Data Access가 더 비쌀 수 있다.

```text
Cost
≈ Math
+ Component Lookup
+ Memory Access
+ Script Dispatch
```

Transform Data를 연속 Array나 Job-compatible 구조로 모으고 변경된 Object만 갱신하는 방법을 검토한다.

기본 Unity Culling 위에 동일한 Test를 중복 구현하지 않는다.

---

## 매 Frame Renderer.enabled 토글

Custom Culling 결과로 `Renderer.enabled`를 수천 개 매 Frame 켜고 끄면 Engine State 변경 비용이 발생할 수 있다.

```text
Visibility Test
→ Renderer.enabled 변경
→ Render Data 갱신 가능
```

다른 Camera와 Shadow에도 전역으로 영향을 준다.

Camera별 Culling API와 Rendering List를 사용하고 상태가 실제로 바뀔 때만 변경한다.

---

## GameObject.SetActive 토글

`SetActive`는 Renderer뿐 아니라 Script, Physics, Animation과 Child Hierarchy를 활성·비활성화한다.

```text
SetActive Toggle
├─ OnEnable·OnDisable
├─ Layout·Canvas Rebuild
├─ Physics 등록
└─ Animation State 영향
```

단순 Camera Frustum 경계를 넘을 때마다 GameObject를 토글하면 Culling보다 Lifecycle 비용이 커질 수 있다.

오래 보이지 않는 Chunk·Pooled Object에 낮은 빈도로 적용한다.

---

## Visibility Thrashing

Object Bounds가 Frustum이나 거리 Threshold 경계에 있으면 Visible 상태가 Frame마다 바뀔 수 있다.

```text
Frame N   Visible
Frame N+1 Culled
Frame N+2 Visible
```

Renderer State, LOD, Asset Load와 Animation을 반복 변경하면 Spike와 Pop이 생긴다.

Hysteresis, Margin과 최소 유지 시간을 사용해 경계 변화를 안정화할 수 있다.

Margin이 크면 더 많은 Object를 유지하는 Trade-off가 있다.

---

## Temporal Occlusion Delay

이전 Frame Depth로 GPU Occlusion을 판정하면 현재 Frame Camera 위치와 결과가 어긋날 수 있다.

```text
Frame N Depth
→ Frame N+1 Visibility
```

Camera가 빠르게 회전하면 새로 보이는 Object가 한 Frame 늦게 나타날 위험이 있다.

Camera Movement에 따라 Bounds를 확장하거나 Previously Visible Object를 보수적으로 유지한다.

정확성을 높이면 Culling 이득이 줄어드는 관계가 있다.

---

## Culling과 Sorting의 전체 손익

Culling에 1ms가 들었지만 Visible Renderer를 크게 줄여 Sorting과 Command Generation을 3ms 줄일 수 있다.

```text
Before
Culling 0.3 ms
Sorting·Commands 4.0 ms

After
Culling 1.0 ms
Sorting·Commands 1.0 ms

Net CPU Saving
= 2.3 ms
```

Culling Marker가 증가했다는 이유만으로 최적화가 실패했다고 결론 내리면 안 된다.

전체 Rendering Preparation과 GPU 시간을 본다.

---

## Culling과 GPU Bubble

GPU-driven Culling Compute Pass가 Graphics Draw와 잘 겹치지 않고 Barrier를 만들면 Pipeline이 기다릴 수 있다.

```text
Depth Pyramid
→ Barrier
→ Compute Culling
→ Barrier
→ Indirect Draw
```

Async Compute를 사용할 수 있어도 Resource Dependency와 Architecture에 따라 실제 Overlap이 다르다.

Dispatch 시간뿐 아니라 GPU Timeline의 Idle과 Barrier를 확인한다.

---

## Frame마다 Culling해야 할까?

Camera와 Object가 움직이면 Visibility가 바뀔 수 있어 일반 Camera Renderer Culling은 Frame마다 필요하다.

하지만 일부 Custom System은 갱신 빈도를 낮출 수 있다.

```text
Near Dynamic Objects
→ Every Frame

Far Static Chunks
→ Camera Cell 변경 시

Slow AI Interest
→ 여러 Frame 분산
```

업데이트 간격이 길면 빠른 Camera에서 Pop이 발생할 수 있다.

중요도와 이동 속도에 따라 Frequency를 나눈다.

---

## Amortization

Custom Distance와 Visibility Test를 여러 Frame에 분산할 수 있다.

```text
Frame 0 → Group A
Frame 1 → Group B
Frame 2 → Group C
Frame 3 → Group D
```

한 Frame Spike는 줄지만 Object가 최대 몇 Frame 늦게 갱신될 수 있다.

Camera 근처와 화면 경계 Object는 자주, 먼 Background는 낮은 빈도로 처리한다.

---

## Camera 이동 기반 갱신

Camera가 일정 거리·각도 이상 움직였을 때만 Custom Visibility를 다시 계산할 수 있다.

```text
if positionDelta > threshold
or rotationDelta > threshold
    update culling
```

정지 Camera에서는 CPU 비용을 줄일 수 있다.

Dynamic Object가 움직이면 Camera가 정지해도 Visibility가 달라질 수 있으므로 Static과 Dynamic Set를 분리한다.

---

## Culling이 필요 없는 작은 Set

항상 화면에 보이는 HUD Marker 20개나 작은 Room의 Prop 10개를 복잡한 공간 Tree에 넣을 필요는 없을 수 있다.

```text
Always Visible Set
→ Direct Draw·Batch
```

Test와 자료 구조 관리보다 단순 Rendering이 더 저렴할 수 있다.

Object 수 Threshold를 감각으로 정하지 않고 Target Device A/B Test로 결정한다.

---

## Culling이 중요한 대규모 Set

Forest의 Tree 100,000개와 Open World Prop 수백만 개는 모두 Draw할 수 없다.

```text
All Instances
→ Spatial Frustum
→ Distance·LOD
→ Hi-Z Occlusion
→ Visible Indirect Draw
```

Culling 자체에 몇 ms가 들어도 수백만 Vertex·Fragment와 CPU Draw를 줄이면 순이익이 크다.

대규모 Data에서는 Data-oriented·GPU-driven Pipeline을 검토한다.

---

## Break-even Point

Break-even Point는 Culling 추가 비용과 Saved Rendering Cost가 같아지는 지점이다.

```text
Culling Cost
= Culled Count × Average Saved Cost
```

실제 관계는 Batch, Cache와 Pipeline 병목 때문에 단순 선형이 아니다.

```text
Break-even 변수
├─ Object Count
├─ Visible Ratio
├─ Draw Cost
├─ Vertex Count
├─ Shader Cost
├─ Camera Count
└─ CPU·GPU Bottleneck
```

A/B Test로 Project별 Threshold를 찾는다.

---

## CPU Bound에서의 손익

CPU가 Draw Submission과 Sorting에 묶여 있다면 Renderer를 줄이는 Culling 이득이 크다.

```text
CPU Bound
→ Visible Draw 감소
→ Render Thread·Main Thread 개선 가능
```

GPU가 이미 Idle이라도 CPU Frame Rate가 개선될 수 있다.

반대로 Custom Culling을 Main Thread의 Managed Loop로 구현하면 CPU 병목을 더 악화할 수 있다.

Job·Burst와 Engine 기본 Culling 결과를 활용한다.

---

## GPU Bound에서의 손익

GPU가 Vertex, Fragment나 Bandwidth Bound라면 비싼 Hidden Draw 제거가 중요하다.

```text
Vertex Bound
→ High-poly Mesh Culling

Fragment Bound
→ Large Transparent·Overdraw Culling

Bandwidth Bound
→ Multi-pass·Blend Draw Culling
```

단순 CPU Culling 비용이 조금 늘어도 GPU가 크게 줄면 전체 Frame Time이 개선된다.

CPU와 GPU가 병렬로 실행되므로 더 느린 쪽의 Frame Time 변화를 본다.

---

## 병목이 아닌 작업을 줄일 때

GPU Fragment Bound인데 CPU Culling만 정교하게 만들고 실제 Fragment Coverage는 거의 줄지 않을 수 있다.

```text
Culling CPU +1 ms
GPU -0.1 ms
→ 전체 성능 악화 가능
```

반대로 CPU Draw Bound에서 Backface Culling만 켜면 Draw Call 수는 그대로라 CPU Frame이 변하지 않을 수 있다.

Culling 방식이 현재 병목 단계의 작업을 실제로 제거하는지 확인한다.

---

## Profiler에서 Culling 시간 확인

CPU Profiler Timeline에서 Camera Rendering, Culling, Batch·Render Loop와 Custom Job Marker를 확인한다.

```text
CPU Frame
├─ Camera Culling
├─ Shadow Culling
├─ Custom Culling Jobs
├─ Sorting
├─ Render Submission
└─ Wait For GPU
```

Marker 이름과 세분화는 Unity Version, Pipeline과 Platform에 따라 다르다.

Hierarchy View의 합계만 보지 말고 Main·Render·Worker Thread의 Timeline과 Dependency Wait를 본다.

---

## Rendering Profiler에서 제거량 확인

Culling 변경 전후 Batches, SetPass, Triangle·Vertex와 Visible Renderer 관련 통계를 비교한다.

```text
Before
Batches 2000
Triangles 8M

After
Batches 900
Triangles 3M
```

Culling CPU 시간이 0.5ms 늘었어도 Draw와 GPU가 크게 줄었다면 성공일 수 있다.

통계 감소만으로 Frame Time을 확정하지 않고 CPU·GPU ms와 연결한다.

---

## Frame Debugger에서 결과 확인

Frame Debugger는 실제로 어떤 Renderer Draw가 남았는지 보여 준다.

```text
질문
├─ 예상 Object가 제외됐는가?
├─ Shadow Pass에는 남았는가?
├─ 다른 Camera가 다시 그리는가?
├─ Batch가 과도하게 나뉘었는가?
└─ LOD Cross-fade가 이중 Draw되는가?
```

Custom Culling이 Main Color만 줄였지만 Depth·Shadow Pass를 그대로 남길 수 있다.

---

## GPU Profiler에서 절감 확인

Pass별 GPU 시간을 전후 비교한다.

```text
Before
Opaque 6.0 ms
Shadow 3.0 ms

After
Opaque 4.0 ms
Shadow 2.8 ms
```

Main Camera Culling이 Shadow Caster Set에는 영향을 적게 줬을 수 있다.

GPU-driven Culling에서는 Compute·Depth Pyramid Pass 시간이 새로 추가되므로 Saved Draw Time에서 빼야 한다.

---

## Vendor Counter

GPU Profiler는 Primitive, Vertex, Fragment와 Compute Workload Counter를 제공할 수 있다.

```text
확인 후보
├─ Compute Busy
├─ Vertex Invocations
├─ Primitives Culled
├─ Rasterized Primitives
├─ Fragment Invocations
├─ Memory Bandwidth
└─ GPU Idle·Barrier
```

Counter 이름과 정의는 Architecture마다 다르다.

Culling Dispatch가 GPU 시간을 어디서 사용하고 어떤 후속 작업을 줄였는지 연결한다.

---

## A/B Test 설계

동일 Camera와 Scene에서 Culling 방식만 바꾼다.

```text
Variant A
기본 Frustum

Variant B
Frustum + Occlusion

Variant C
GPU Frustum + Hi-Z
```

다음 조건을 고정한다.

```text
Resolution
Quality
Shadow
Object 배치
Camera Transform
Animation Frame
VSync·FPS Cap
```

CPU Culling, CPU Rendering, GPU Culling, GPU Draw와 Memory를 모두 기록한다.

---

## 측정 표

| Variant | Culling CPU | Render CPU | Culling GPU | Draw GPU | Memory |
|---|---:|---:|---:|---:|---:|
| Basic | 0.5 ms | 4.0 ms | 0 ms | 12.0 ms | 기준 |
| Occlusion | 1.1 ms | 2.0 ms | 0 ms | 7.0 ms | +18 MB |
| GPU Hi-Z | 0.4 ms | 1.2 ms | 0.8 ms | 5.5 ms | +32 MB |

숫자는 기록 양식의 예시다.

총 CPU·GPU Critical Path와 Target Frame Budget을 기준으로 선택한다.

---

## Camera Path 전체를 측정한다

한 위치에서만 Culling 이득을 측정하면 결과가 편향될 수 있다.

```text
Indoor Room
→ Visibility 10%

Doorway
→ Visibility 40%

Open Plaza
→ Visibility 90%
```

Occlusion은 Room에서 큰 이득이고 Plaza에서 손해일 수 있다.

Gameplay Camera Path의 Average, Worst-case와 Spike를 모두 측정한다.

Camera 상태별로 기능을 동적으로 바꾸는 비용도 고려한다.

---

## Warm-up과 Cache

첫 Frame에는 Spatial Data, Shader, Job과 Buffer가 Warm-up되며 Spike가 발생할 수 있다.

```text
First Frame
→ Allocation·Upload·Compilation 가능

Steady State
→ Reused Data
```

Culling Benchmark 전 충분히 Warm-up하고 첫 Frame과 지속 Frame을 따로 기록한다.

Scene Load 직후 Camera Teleport도 실제 Gameplay에 있다면 Spike Budget에 포함한다.

---

## Mobile에서의 손익

Mobile은 CPU 성능, Memory Bandwidth와 전력 Budget이 제한된다.

```text
Culling 이득
→ Draw·Vertex·Fragment·전력 감소

Culling 비용
→ CPU Query·Data Memory·Compute
```

Desktop에서 0.2ms인 Custom Culling이 Mobile CPU에서 더 크게 나타날 수 있다.

큰 Occlusion Data는 Cache와 Memory 압박을 만들 수 있다.

대표 저사양 Device에서 Sustained Thermal 상태까지 Profile한다.

---

## XR에서의 손익

XR은 Left·Right Eye와 높은 목표 FPS를 가진다.

```text
Saved Draw
→ 두 Eye Rendering 절감 가능

Culling
→ Stereo Frustum·Camera 처리 필요
```

두 Eye를 감싸는 Conservative Frustum은 Test 수를 줄이지만 한 Eye에만 불필요한 Object가 남을 수 있다.

Eye별 Culling은 정밀하지만 Query와 List 생성이 늘 수 있다.

Headset의 Stereo Mode와 GPU Timeline에서 손익을 측정한다.

---

## 최적화 순서

```text
1. 현재 CPU·GPU 병목 확인
2. Camera·Light·Probe 수 확인
3. Renderer Bounds와 Visible Ratio 측정
4. 기본 Frustum·Layer·LOD 활용
5. 큰 Hidden Draw 그룹부터 Occlusion 적용
6. Batch Size와 Culling Granularity 조정
7. Custom Update·Allocation·Toggle 제거
8. 대규모 Set에서만 GPU Culling 검토
9. Culling Cost와 Saved Cost를 함께 기록
10. Target Camera Path에서 재측정
```

정교한 Algorithm보다 불필요한 Camera와 과도하게 큰 Bounds를 먼저 수정하는 편이 효과적일 수 있다.

---

## 흔한 오해

### Culling은 보이지 않는 Object를 제거하므로 무료다

Bounds 갱신, 공간 Query, Visibility Test와 Visible List 생성 비용이 필요하다.

### 더 정밀하게 Culling할수록 항상 빠르다

Test·Data·Query가 늘고 제거되는 Rendering이 적으면 느려질 수 있다.

### Culling CPU 시간이 늘면 최적화에 실패했다

Sorting·Submission과 GPU Draw를 더 크게 줄였다면 전체 Frame은 개선될 수 있다.

### Object 수만 많으면 GPU Culling이 유리하다

Visible Ratio, Object당 비용, Batch와 Dispatch·Compaction 비용을 함께 봐야 한다.

### Bounds Test Math만 최적화하면 충분하다

Transform 접근, Cache, Allocation, Job Scheduling과 상태 변경이 더 큰 비용일 수 있다.

### 모든 Object에서 매 Frame 거리 Check를 해야 한다

Layer Distance, LOD, CullingGroup와 공간 구조로 중앙화하거나 갱신을 분산할 수 있다.

### Renderer.enabled 토글은 비용이 없다

Engine State 변경과 다른 Camera·Shadow 영향이 있으며 상태가 바뀔 때만 적용해야 한다.

### Occlusion Bake는 Offline이므로 Runtime 비용이 없다

Cell·PVS 조회와 Data Memory를 사용한다.

### GPU Culling은 CPU 비용을 완전히 없앤다

Buffer·Dispatch·Barrier·Indirect Draw 준비가 필요하며 CPU Readback은 Stall을 만들 수 있다.

### 작은 Object일수록 Culling해야 한다

저비용 Object는 Batch와 Depth Test로 그리는 편이 정밀 Query보다 빠를 수 있다.

### Culling은 Rendering만 보면 된다

Camera Path, Memory, Pop, Simulation과 개발 Bake Workflow까지 함께 평가해야 한다.

---

## 최종 체크리스트

```text
□ Culling Cost와 Saved Rendering Cost를 함께 측정했는가?
□ Object Count뿐 아니라 Visible Ratio를 확인했는가?
□ Renderer당 Draw·Vertex·Shader 비용을 고려했는가?
□ 움직이는 Renderer의 Bounds 갱신 비용을 확인했는가?
□ Skinned Mesh·Particle Offscreen Update가 필요한가?
□ Static·Dynamic 공간 구조를 구분했는가?
□ Bounds가 커서 Test 후에도 항상 Visible로 남지 않는가?
□ Main·Reflection·Mini Map Camera별 Culling을 확인했는가?
□ Shadow Cascade·Point Light Face의 반복을 확인했는가?
□ Layer Mask로 비싼 Test 전에 후보를 줄였는가?
□ Object별 Update 거리 Check를 중복 구현하지 않았는가?
□ CullingGroup Array와 Callback을 효율적으로 관리하는가?
□ LOD Cross-fade의 이중 Draw를 고려했는가?
□ Occlusion Runtime Query와 Data Memory를 포함했는가?
□ GPU Hi-Z의 Pyramid·Dispatch·Compaction 비용을 포함했는가?
□ GPU Result를 CPU Readback해 Stall을 만들지 않는가?
□ Instance Batch Bounds가 너무 넓지 않은가?
□ Custom Culling에서 매 Frame Allocation하지 않는가?
□ Renderer.enabled·SetActive를 매 Frame 토글하지 않는가?
□ Visibility 경계의 Thrashing을 완화했는가?
□ Job Scheduling 비용보다 Workload가 충분한가?
□ Frame Debugger에서 실제 Draw 감소를 확인했는가?
□ CPU·GPU Timeline에서 전체 순이익을 확인했는가?
□ Camera Path의 평균·Worst-case를 모두 측정했는가?
□ Mobile·XR Target에서 Memory와 Thermal까지 검증했는가?
```

---

## 정리

Culling은 불필요한 Rendering을 줄이지만 Bounds 갱신, 공간 구조 탐색, Visibility Test, List 생성과 Camera별 반복이라는 자체 비용을 가진다.

최적화 순이익은 제거한 CPU Submission·Vertex·Fragment·Bandwidth 비용에서 Culling CPU·GPU·Memory 비용을 뺀 값으로 판단해야 한다.

Object 수가 많고 Visible Ratio가 낮으며 Object당 Rendering 비용이 클수록 정밀한 Culling의 이득이 커질 가능성이 높다.

작고 단순하며 잘 Batch되는 Object가 대부분 보이는 Scene에서는 Fine-grained Occlusion Query와 GPU Dispatch가 오히려 더 비쌀 수 있다.

GPU Culling도 Bounds Buffer, Depth Pyramid, Compute Dispatch, Visible List Compaction, Barrier와 Indirect Draw 비용이 필요하며 CPU Readback은 Synchronization을 만들 수 있다.

Camera·Shadow·Reflection 수, Batch Granularity, Bounds 정확성, Allocation과 Visibility Thrashing이 Plane Test Math보다 큰 비용을 만들 수 있다.

Profiler와 Frame Debugger로 Culling 시간과 실제 Draw 절감을 함께 기록하고 Camera Path 전체의 CPU·GPU Critical Path를 Target Device에서 비교해야 한다.
