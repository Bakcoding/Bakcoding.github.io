---
title: "[Unity 렌더링] 12-3. Triangle 수가 많으면 왜 느려질까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - Triangle
  - Geometry
  - Optimization
permalink: /programming/unity-12-3-why-many-triangles-can-be-slow/
toc: true
toc_sticky: true
date: 2026-08-16
last_modified_at: 2026-08-16
---

Triangle 수가 많으면 GPU가 읽고 변환할 Vertex·Index Data와 조립·Clipping·Rasterization할 Primitive가 증가한다.

```text
Mesh Data
→ Vertex·Index Fetch
→ Vertex Shader
→ Primitive Assembly
→ Culling·Clipping
→ Rasterization
→ Fragment Shader
```

하지만 Triangle가 두 배라고 Frame Time이 항상 두 배가 되는 것은 아니다.

Vertex 재사용, Triangle의 Screen Size, Backface·Frustum Culling, Shader 복잡도와 현재 CPU·GPU 병목이 실제 비용을 결정한다.

Triangle 최적화는 Geometry 처리 단계가 Frame을 제한한다는 측정 결과가 있을 때 가장 큰 효과를 낸다.

---

## Triangle은 GPU의 기본 Primitive다

GPU Rasterization Pipeline은 대부분 Surface를 Triangle 집합으로 처리한다.

```text
Cube
├─ Face 6개
└─ Face당 Triangle 2개
   → 총 12 Triangles
```

Quad와 Polygon도 최종 Rendering을 위해 Triangle로 분할된다.

Triangle는 항상 평면이고 세 Point로 정의되어 Projection과 보간을 일관되게 처리하기 쉽다.

Mesh가 복잡해질수록 GPU에 제출되는 Triangle 수가 증가한다.

---

## Triangle와 Vertex 수는 같지 않다

Triangle 하나는 Index 세 개를 사용하지만 이웃 Triangle와 Vertex를 공유할 수 있다.

```text
Quad

v0 ───── v1
│      ／ │
│    ／   │
│  ／     │
v2 ───── v3

2 Triangles
4 Shared Vertices
6 Indices
```

공유가 없다면 Triangle 두 개에 Vertex 여섯 개가 필요하지만 Index Buffer를 사용하면 네 Position을 재사용할 수 있다.

Triangle 수만으로 Vertex Shader 실행 수를 정확히 알 수 없는 이유다.

---

## Index Buffer

Index Buffer는 Triangle가 사용할 Vertex Buffer Entry를 지정한다.

```text
Vertices
[v0, v1, v2, v3]

Indices
[0, 1, 2, 2, 1, 3]
```

같은 Vertex를 여러 Triangle에서 재사용해 Memory와 Vertex Shader 실행을 줄일 수 있다.

Index가 16-bit인지 32-bit인지에 따라 한 Mesh에서 표현 가능한 Vertex 범위와 Index Memory가 달라진다.

Unity Mesh의 Index Format과 실제 Vertex 수를 함께 확인한다.

---

## Vertex Buffer 읽기

GPU는 Vertex Position뿐 아니라 Shader가 요구하는 Attribute를 읽는다.

```text
Vertex Data
├─ Position
├─ Normal
├─ Tangent
├─ UV0
├─ UV1
├─ Color
├─ Bone Weights
└─ Bone Indices
```

Vertex 수가 많고 Attribute가 넓으면 Memory Bandwidth 요구가 증가한다.

사용하지 않는 Tangent, UV Channel과 Color를 Import 단계에서 제거하면 Vertex당 Data 크기를 줄일 수 있다.

Triangle 수와 Vertex Layout을 함께 최적화해야 한다.

---

## Vertex Shader 실행

각 고유 Vertex는 Vertex Shader에서 Object·World·Clip Space로 변환된다.

```text
Vertex Shader
├─ Position Transform
├─ Normal·Tangent Transform
├─ Skinning
├─ Wind
├─ Vertex Animation
└─ Varying 계산
```

단순 Static Mesh와 네 개 Bone Weight를 가진 Skinned Mesh는 Vertex당 비용이 다르다.

```text
Geometry Cost
≈ Processed Vertex 수 × Vertex Shader 비용
```

Triangle 수가 같아도 Vertex Shader 복잡도에 따라 GPU 시간이 달라진다.

---

## Post-transform Vertex Cache

GPU는 최근 변환한 Vertex 결과를 Cache해 이웃 Triangle가 같은 Index를 사용할 때 재사용할 수 있다.

```text
Triangle A uses v0, v1, v2
Triangle B uses v2, v1, v3

v1·v2 결과 재사용 가능
```

Index 순서가 공간적으로 불규칙하면 Cache에서 Vertex가 밀려난 뒤 다시 계산할 수 있다.

Mesh Optimization은 Triangle 순서를 조정해 Vertex Cache Locality를 개선할 수 있다.

보이는 Shape와 Triangle 수가 같아도 Index Order에 따라 처리 효율이 달라질 수 있다.

---

## Vertex Sharing이 깨지는 이유

Position이 같은 지점도 Attribute가 다르면 별도 Vertex가 필요할 수 있다.

```text
Vertex Split 원인
├─ Hard Normal Edge
├─ UV Seam
├─ Material Boundary
├─ Different Vertex Color
├─ Lightmap UV Seam
└─ Tangent Discontinuity
```

Cube는 Corner Position가 8개지만 Face마다 다른 Normal과 UV가 필요하면 Rendering Vertex 수는 더 많아진다.

DCC Tool의 Point 수와 Unity Import 후 Vertex 수가 다른 이유다.

Triangle만 줄이고 UV Seam을 많이 만들면 Vertex 감소 효과가 제한될 수 있다.

---

## Hard Edge와 Normal Split

Smooth Surface는 이웃 Face의 Normal을 공유할 수 있다.

Hard Edge는 Face마다 다른 Normal이 필요해 Vertex가 분리된다.

```text
Smooth Edge
→ Shared Vertex Normal

Hard Edge
→ Vertex A Normal N1
→ Vertex B Normal N2
→ Position은 같아도 별도 Vertex
```

필요 없는 Hard Edge를 줄이면 Vertex Data와 Cache 효율이 좋아질 수 있다.

Silhouette와 의도한 Shading을 훼손하지 않는 범위에서 적용한다.

---

## UV Seam

Texture UV가 끊기는 경계에서는 같은 Position에 서로 다른 UV가 필요하다.

```text
Position P
├─ UV (0, 0)
└─ UV (1, 0)
```

GPU Vertex는 하나의 Attribute 조합만 저장하므로 두 Entry로 분리된다.

Lightmap UV도 추가 Seam을 만들 수 있다.

UV Island를 무조건 합치기보다 Texture 왜곡, Lightmap 품질과 Vertex 증가의 Trade-off를 본다.

---

## Primitive Assembly

Vertex Shader 결과와 Index를 이용해 Triangle Primitive를 구성한다.

```text
Indices 0, 1, 2
→ Triangle A

Indices 2, 1, 3
→ Triangle B
```

Triangle 수가 많으면 Primitive Assembly와 Setup 작업도 증가한다.

이 단계는 Fragment 수가 적어도 남는다.

멀리 있는 High-poly Mesh가 화면에서 작아져도 Triangle가 자동으로 합쳐지지 않는 이유다.

---

## Backface Culling

Camera 반대 방향을 향하는 Triangle은 Rasterization 전에 제거할 수 있다.

```text
Submitted Triangles
→ Face Orientation Test
→ Back Faces Culled
→ Front Faces Rasterized
```

Backface Culling은 Rasterization·Fragment를 줄이지만 Vertex Shader 이후에 수행될 수 있어 Vertex Processing 비용은 남는다.

닫힌 Mesh에서 Triangle 절반이 Back Face라고 GPU Geometry 비용도 정확히 절반이라는 뜻은 아니다.

---

## Frustum Culling

Renderer Bounds가 Camera Frustum 밖이면 Draw 전체를 제외한다.

```text
Bounds Outside
→ Draw Submission 없음
→ Mesh Vertex·Triangle 처리 없음
```

Object 단위 Frustum Culling은 Triangle 단위 Backface Culling보다 앞에서 더 많은 작업을 줄일 수 있다.

하지만 큰 Combined Mesh Bounds가 Frustum에 걸리면 내부의 Offscreen Triangle까지 Draw에 포함된다.

Geometry Chunk Size는 Draw Call와 Culling Granularity 사이의 Trade-off다.

---

## Clipping

Frustum 경계와 교차하는 Triangle는 Clip Plane에 맞게 잘린다.

```text
Original Triangle
→ Near Plane 교차
→ Polygon Clipping
→ 새로운 Triangle로 분할 가능
```

Camera Near Plane과 큰 Triangle가 자주 교차하면 Primitive 처리가 추가될 수 있다.

Renderer Bounds가 Frustum에 걸린다는 이유만으로 모든 Triangle가 그대로 Rasterize되는 것은 아니다.

Camera 내부에 큰 Mesh를 둘 때 Near Plane 교차를 확인한다.

---

## Rasterization

Rasterizer는 Triangle가 덮는 Screen Pixel 위치에 Fragment 후보를 만든다.

```text
Triangle Screen Area
→ Covered Samples
→ Fragment 후보
```

Triangle 수와 Fragment 수는 같은 지표가 아니다.

```text
Fullscreen Triangle 1개
→ 수백만 Fragments 가능

아주 작은 Triangle 100만 개
→ 각각 몇 Pixel 이하 가능
```

Geometry Bound와 Fill-rate Bound를 분리해야 한다.

---

## 큰 Triangle

Fullscreen Triangle 하나는 Primitive 비용은 작지만 화면 전체 Fragment Shader를 실행한다.

```text
Triangle Count: 1
Screen Coverage: 100%
```

복잡한 Post-processing Shader라면 Triangle 수가 거의 없어도 GPU가 느릴 수 있다.

이 경우 Mesh Triangle 최적화보다 Shader Sample, Resolution과 Pass 수를 줄이는 편이 효과적이다.

---

## 작은 Triangle

멀리 있는 고밀도 Mesh에서는 한 Triangle가 Pixel보다 작게 투영될 수 있다.

```text
Pixel Grid
┌────┬────┐
│△△△△│△△△△│
├────┼────┤
│△△△△│△△△△│
└────┴────┘
```

많은 Triangle를 조립·Cull·Setup하지만 각 Triangle의 Screen 기여는 매우 작다.

GPU가 효율적으로 처리할 수 있는 Primitive Rate와 Rasterizer Setup Rate가 병목이 될 수 있다.

LOD로 Subpixel Triangle를 줄이는 이유다.

---

## Quad 단위 Fragment 실행

GPU Fragment Shader는 보통 인접한 2 × 2 Pixel Quad 단위로 실행하는 구조를 사용한다.

```text
2 × 2 Quad
┌───┬───┐
│ P │ P │
├───┼───┤
│ P │ P │
└───┴───┘
```

Texture Gradient와 Derivative 계산에 이웃 Fragment가 필요하기 때문이다.

아주 작은 Triangle가 Quad의 한 Sample만 덮어도 나머지 Lane가 Helper Invocation으로 실행될 수 있다.

이를 Quad Under-utilization 또는 Shader Lane 낭비 관점으로 볼 수 있다.

---

## 작은 Triangle의 Shader 효율

큰 Triangle는 한 2 × 2 Quad의 네 Lane가 모두 유효 Pixel을 처리하기 쉽다.

```text
Large Triangle
████
████
→ 높은 Lane 활용
```

작고 가는 Triangle는 Quad 일부만 덮는다.

```text
Thin Triangle
█░
░░
→ 일부 Lane만 결과 기여
```

Fragment Shader 실행 단위에 비해 유효 Pixel가 적어 복잡한 Shader 비용이 낭비될 수 있다.

---

## Micro Triangle

Micro Triangle는 Screen에서 매우 작게 투영된 Triangle를 가리키는 일반적인 표현이다.

```text
Triangle Area < 1 Pixel 수준
```

GPU마다 정확한 성능 특성과 Threshold는 다르다.

문제는 다음 비용이 Pixel 기여보다 커지는 점이다.

```text
Vertex Fetch
Vertex Shader
Primitive Setup
Face Culling
Rasterization Rule
Helper Fragment
```

특정 고정 Pixel 크기를 보편 규칙으로 사용하지 않고 Target GPU Counter로 확인한다.

---

## Triangle가 너무 가늘 때

폭은 매우 좁고 길이는 긴 Triangle도 여러 2 × 2 Quad를 부분적으로 덮는다.

```text
──────────── Thin Triangle
```

실제 Coverage는 적지만 많은 Quad에서 Helper Lane가 생길 수 있다.

잘못된 Tessellation, 긴 Strip와 단순화 과정에서 이런 Geometry가 만들어질 수 있다.

Mesh Wireframe과 Triangle Aspect Ratio를 확인한다.

---

## Overdraw와 Triangle 수

Triangle가 서로 겹치면 같은 Pixel 위치에 여러 Fragment가 생성된다.

```text
Camera
  ├─ Triangle Layer A
  ├─ Triangle Layer B
  └─ Triangle Layer C
```

Opaque는 Depth와 Early-Z가 가려진 Fragment를 줄일 수 있다.

Transparent는 Layer마다 Blend해야 하므로 Triangle 증가가 Fragment Overdraw로 연결되기 쉽다.

Triangle 수와 Screen Coverage·Depth Order를 함께 본다.

---

## 내부 Face

닫힌 Mesh 내부에 절대 보이지 않는 Face가 남아 있을 수 있다.

```text
Building Mesh
├─ Exterior
└─ 막힌 내부 Wall Face
```

Backface Culling과 Depth가 일부 제거해도 Vertex·Primitive 처리 비용은 발생할 수 있다.

Object가 열리지 않고 내부 Camera가 없는 경우 내부 Geometry를 제거한다.

Destruction, Cutaway와 Shadow에서 필요하지 않은지 확인한다.

---

## 겹친 Surface

동일 위치에 중복 Face가 있으면 Z-fighting과 불필요한 Triangle·Fragment가 발생한다.

```text
Surface A
─────────
Surface B
─────────  거의 같은 Depth
```

DCC Duplicate, Boolean Operation와 Modular Kit 중첩에서 생길 수 있다.

Mesh Validation과 Frame Debugger로 중복 Draw를 확인한다.

Decal와 Layered Material처럼 의도한 중첩은 별도 Rendering 방식과 비교한다.

---

## Tessellation

Tessellation은 Patch를 GPU에서 더 많은 Triangle로 세분화한다.

```text
Base Triangle
→ Tessellator
→ Many Small Triangles
```

가까운 Surface Detail를 높일 수 있지만 Factor가 크면 Triangle 수가 폭발한다.

멀리서도 높은 Factor를 유지하면 Subpixel Triangle와 Vertex-like Domain Shader 작업이 증가한다.

Screen Space·Distance Adaptive Tessellation과 최대 Factor를 제한한다.

---

## Geometry Shader가 Primitive를 늘릴 때

Geometry Shader는 입력 Primitive에서 여러 Primitive를 출력할 수 있다.

```text
Input Point
→ Geometry Shader
→ Billboard Quad 2 Triangles
```

출력 Amplification이 크면 Primitive와 Rasterization 비용이 증가한다.

Geometry Shader Throughput는 Platform에 따라 낮을 수 있으며 Mobile 지원과 성능도 확인해야 한다.

Compute·Mesh Shader·Instanced Quad 같은 대안을 비교한다.

---

## Mesh Shader Pipeline

현대 GPU의 Mesh Shader는 Workgroup이 Meshlet 단위로 Vertex와 Primitive를 생성하고 Cull할 수 있다.

```text
Meshlets
→ Task·Mesh Workgroups
→ Primitive Output
```

Cluster Culling과 Vertex 재사용을 효율화할 가능성이 있지만 Primitive 수 자체가 무료가 되는 것은 아니다.

Unity Render Pipeline과 Target API의 지원 여부를 확인한다.

전통 Vertex Pipeline에서도 Meshlet 기반 GPU-driven Culling Data를 사용할 수 있다.

---

## Meshlet

Meshlet은 Mesh를 작은 Vertex·Triangle Cluster로 나눈 Data 구조다.

```text
Mesh
├─ Meshlet A
│  ├─ Local Vertices
│  └─ Triangles
├─ Meshlet B
└─ Meshlet C
```

Cluster Bounds와 Normal Cone으로 Frustum·Backface·Occlusion Culling을 먼저 수행할 수 있다.

보이지 않는 Meshlet의 Triangle를 GPU Pipeline에 제출하지 않아 대규모 Geometry에 유리하다.

Meshlet 생성 품질과 Cluster 크기는 Culling·Cache Trade-off를 만든다.

---

## Skinned Mesh

Skinned Mesh의 Vertex는 Bone Matrix를 혼합한다.

```text
Position Skinned
= Σ BoneMatrix[i] × Position × Weight[i]
```

Vertex 수가 많고 Bone Influence가 많을수록 Skinning 연산과 Bone Data Read가 증가한다.

Triangle를 줄이며 Vertex와 Bone Weight도 줄이는 Character LOD가 중요하다.

Mesh Triangle만 줄었지만 Seam 때문에 Vertex가 많이 남으면 Skinning 절감이 작을 수 있다.

---

## Blend Shape

Blend Shape는 여러 Shape Delta를 Vertex에 적용한다.

```text
Final Position
= Base
+ ShapeA Delta × WeightA
+ ShapeB Delta × WeightB
```

High-poly Face에 많은 활성 Blend Shape가 있으면 Vertex Data와 Deformation 비용이 커진다.

Far LOD에서 Facial Blend Shape를 제거하거나 Update를 줄인다.

Animation 품질과 Gameplay Lip Sync 요구를 구분한다.

---

## Cloth와 Vertex Deformation

Cloth Simulation 결과를 많은 Vertex에 적용하면 Simulation과 Vertex 처리 비용이 증가한다.

Far Character에서 Cape Mesh Triangle를 줄여도 Cloth Simulation Mesh가 High Detail로 남아 있을 수 있다.

```text
Render LOD
vs
Simulation LOD
```

Low-resolution Simulation Mesh와 Render Mesh Mapping을 사용하거나 먼 거리에서 Cloth를 단순 Animation으로 바꿀 수 있다.

---

## Terrain Triangle

Terrain은 넓은 Surface를 Grid Triangle로 표현한다.

```text
Near Patches → Dense Triangles
Far Patches  → Sparse Triangles
```

전체 Terrain를 최고 Detail로 그리면 먼 영역에 Subpixel Triangle가 대량으로 생긴다.

Patch별 LOD와 Heightmap Pixel Error로 Geometry Detail를 조절한다.

인접 LOD Edge의 Crack과 Skirt 비용을 함께 관리한다.

---

## Foliage Triangle

Vegetation은 Leaf Card 수가 많고 Alpha Clip·Double-sided Material를 사용한다.

```text
Foliage Cost
├─ 많은 Cards·Triangles
├─ Vertex Wind
├─ Cull Off
├─ Alpha Clip
└─ Overdraw
```

Triangle 수, Fragment Overdraw와 Shadow Caster가 동시에 병목이 될 수 있다.

Leaf Cluster LOD, Billboard, Shadow Distance와 Density를 함께 조정한다.

단순 Triangle 감소만으로 Alpha Coverage가 커지면 Overdraw가 오히려 증가할 수 있다.

---

## Hair Triangle

Hair Card와 Strand Geometry는 작은 Triangle, Alpha와 Layer가 많다.

```text
Hair
→ Geometry Front-end 부담
+ Fragment Overdraw
+ Complex Shading
```

LOD에서 Card·Strand 수를 줄이고 Far Material의 Anisotropic Lighting·Transparency를 단순화한다.

Silhouette와 Hair Volume을 유지하면서 내부 Layer부터 제거한다.

---

## Particle Mesh

Mesh Particle는 Particle마다 Mesh Geometry를 반복한다.

```text
Mesh 500 Triangles
× 1000 Particles
= 500,000 Triangle Instances
```

GPU Instancing으로 Draw Call를 줄여도 Vertex·Triangle 처리량은 남는다.

낮은 Detail Mesh, Billboard와 최대 Alive Count를 비교한다.

Camera에서 작게 보이는 Mesh Particle는 Geometry LOD가 특히 중요하다.

---

## Shadow Pass에서 Triangle가 반복된다

Shadow Casting Object는 Main Camera Color Pass 외에 Shadow Map에도 Geometry를 그린다.

```text
Main Camera
→ Mesh Triangles

Directional Cascade 0
→ Mesh Triangles

Cascade 1·2·3
→ 범위에 따라 반복
```

Additional Light Shadow와 Point Light Cube Face까지 있으면 Geometry가 여러 번 처리된다.

Triangle 최적화 효과는 Main View 통계보다 전체 Pass에서 더 클 수 있다.

---

## Depth Prepass에서 Triangle가 반복된다

Depth Prepass는 Opaque Geometry를 Depth-only Shader로 먼저 그린다.

```text
Depth Prepass
→ Geometry 1회

Color Pass
→ Geometry 다시 Draw
```

Fragment Color Overdraw를 줄이지만 Vertex·Primitive 작업은 반복될 수 있다.

High-poly Scene에서 Depth Prepass가 Vertex Bound를 악화할 가능성을 Profile한다.

---

## Deferred G-buffer

Deferred Geometry Pass는 Mesh를 한 번 Rasterize해 여러 G-buffer를 기록한다.

Triangle 수가 늘면 Vertex·Primitive와 Pixel Coverage가 증가한다.

Lighting은 Screen Space로 분리되므로 Light 수가 많아도 Geometry Vertex를 Light마다 반복하지 않는 장점이 있다.

하지만 Shadow Pass와 Depth Prepass 구조에 따라 Geometry는 추가 처리될 수 있다.

---

## Multi-pass Material

Material가 Outline, Fur Shell와 여러 Lighting Pass를 사용하면 같은 Mesh Triangle를 Pass마다 다시 그린다.

```text
Base Pass
+ Outline Pass
+ Fur Shell × N
+ Shadow Pass
```

Mesh Triangle 수가 100,000이고 Pass가 네 개면 Primitive Work가 개념적으로 여러 배 반복된다.

Renderer 통계의 Triangle 수가 Pass별 제출을 어떻게 집계하는지 확인한다.

---

## Draw Call와 Triangle 수

두 지표는 서로 다른 병목을 나타낸다.

```text
Case A
10,000 Draws × 2 Triangles
→ CPU Submission 병목 가능

Case B
10 Draws × 10M Triangles
→ GPU Geometry 병목 가능
```

Draw Call를 Batch로 줄여도 Case B의 Triangle 수는 그대로다.

Triangle를 줄여도 Case A의 Renderer·Draw 수가 그대로면 CPU 병목은 남는다.

---

## Static Batching과 Triangle

Static Batching은 같은 Material Geometry의 Draw 준비를 효율화할 수 있다.

```text
Before·After
→ Triangle 수는 대체로 동일
→ CPU State·Submission 구조 변화
```

큰 Combined Batch가 Frustum에 걸리면 Offscreen Geometry가 함께 처리될 가능성도 검토한다.

Batching과 Geometry LOD를 함께 적용해야 CPU와 GPU Geometry 비용을 모두 줄일 수 있다.

---

## GPU Instancing과 Triangle

GPU Instancing은 같은 Mesh를 여러 Transform으로 한 Draw에 제출한다.

```text
Mesh 1000 Triangles
× 1000 Instances
→ 1M Instance-Triangles 개념
```

Draw Call는 줄지만 Instance마다 Vertex Shader와 Primitive Processing가 필요하다.

Frustum·Occlusion·LOD로 Visible Instance와 Mesh Detail를 줄인다.

GPU Instancing을 사용하므로 Triangle 최적화가 필요 없다는 결론은 틀리다.

---

## SRP Batcher와 Triangle

SRP Batcher는 호환 Shader의 Material·Per-object Data 전환 비용을 줄인다.

Triangle, Vertex와 Fragment 수는 직접 줄이지 않는다.

```text
SRP Batcher
→ CPU Render State 비용 개선

LOD·Mesh Optimization
→ GPU Geometry 비용 개선
```

CPU 병목이 해결된 뒤 GPU Geometry가 새로운 병목으로 드러날 수 있다.

---

## Triangle가 많아도 빠른 경우

다음 조건에서는 높은 Triangle 수를 GPU가 충분히 처리할 수 있다.

```text
큰 Triangle 위주
높은 Vertex Reuse
단순 Vertex Shader
적은 Pass
좋은 Culling
충분한 GPU Geometry Throughput
Fragment·CPU가 더 큰 병목
```

Triangle 수가 높다는 이유만으로 시각 품질을 낮추지 않는다.

Target Frame Budget 안에 있고 다른 단계가 제한한다면 최적화 우선순위가 아니다.

---

## Triangle가 적어도 느린 경우

Fullscreen UI·Post-processing과 큰 Transparent Quad는 Triangle가 적지만 Pixel 비용이 크다.

```text
Triangle 2개
× 4K Pixels
× Complex Shader
× Multiple Layers
```

Fill Rate, Texture Sample와 Blend가 병목이면 Triangle를 더 줄일 수 없고 의미도 없다.

Resolution, Screen Coverage, Shader와 Overdraw를 최적화한다.

---

## GPU Geometry Bound

GPU Geometry Bound는 Vertex·Primitive 단계의 처리량이 전체 Rendering 시간을 제한하는 상태다.

```text
징후 후보
├─ Triangle·Vertex 감소 시 GPU ms 크게 감소
├─ Resolution 감소 효과 작음
├─ 단순 Fragment Shader로 바꿔도 변화 작음
├─ LOD 강제 시 큰 개선
└─ Vendor Counter에서 Geometry Unit Busy
```

한 징후만으로 확정하지 않고 여러 A/B Test를 조합한다.

---

## Resolution Test

Rendering Resolution을 절반으로 낮춘다.

```text
Pixel 수 약 1/4
Triangle·Vertex 수 동일
```

GPU 시간이 거의 변하지 않으면 Fragment보다 Vertex·Geometry 또는 Fixed Pass가 병목일 가능성이 있다.

GPU 시간이 크게 줄면 Pixel 비용 비중이 크므로 Triangle 감소만으로 효과가 제한될 수 있다.

---

## LOD Force Test

같은 Camera에서 모든 LOD Group를 LOD0와 Low LOD로 강제 비교한다.

```text
Force LOD0
→ High Triangles

Force LOD2
→ Low Triangles
```

Material, Screen Coverage와 Renderer 수가 최대한 같으면 Geometry 감소 효과를 분리하기 쉽다.

Low LOD가 Material와 Shadow까지 바꾸면 어떤 요소가 기여했는지 추가 Test한다.

---

## Vertex Shader Test

Geometry와 Triangle 수를 유지하고 Vertex Shader 기능을 단순화한다.

```text
Original
→ Skinning + Wind + Deformation

Diagnostic
→ Position Transform only
```

GPU 시간이 크게 줄면 Vertex당 연산 비용이 중요하다.

변화가 작고 LOD Mesh에서만 개선된다면 Primitive Count·Fetch가 더 큰 원인일 수 있다.

---

## Fragment Shader Test

원본 Mesh에 단순 Color Fragment Shader를 적용한다.

```text
Geometry 동일
Fragment Cost 감소
```

성능이 크게 개선되면 Fragment Bound 가능성이 높다.

변화가 작으면 Vertex·Primitive, Bandwidth 또는 CPU 병목을 의심한다.

Diagnostic Shader는 Depth, Cull와 Pass 수를 원본과 최대한 맞춘다.

---

## Pass 수 Test

Shadow, Depth Prepass, Outline과 Additional Pass를 하나씩 끈다.

```text
Baseline
→ Shadow Off
→ Depth Prepass Off
→ Outline Off
```

Mesh Triangle가 Pass마다 반복되는 비율을 확인할 수 있다.

Pass를 끄면 Pixel·Lighting도 바뀌므로 Frame Debugger로 실제 Draw 구조를 함께 본다.

---

## Unity Rendering Statistics

Game View Statistics와 Rendering Profiler에서 Triangle와 Vertex 통계를 확인할 수 있다.

```text
Stats
├─ Batches
├─ SetPass Calls
├─ Triangles
└─ Vertices
```

통계가 Scene의 고유 Mesh Triangle 합인지 Pass·Camera별 제출을 포함하는지는 도구와 Context에 따라 확인해야 한다.

숫자를 GPU가 실제 Rasterize한 Front Face 수와 동일하게 해석하지 않는다.

---

## Frame Debugger

Frame Debugger에서 Draw마다 Mesh, Submesh, Index Count와 Pass를 확인한다.

```text
질문
├─ 어떤 Mesh가 Triangle 대부분을 차지하는가?
├─ LOD가 실제 선택됐는가?
├─ Shadow에 LOD0가 남았는가?
├─ Depth Pass에서 반복되는가?
├─ Multi-pass Material인가?
└─ Reflection Camera가 다시 그리는가?
```

전체 Triangle 통계에서 실제 원인 Draw를 찾는 단계다.

---

## Mesh Inspector

Unity Mesh Asset Inspector에서 Vertex와 Triangle 수, Submesh, Index Format와 Read/Write 상태를 확인한다.

```text
Mesh Data
├─ Vertices
├─ Indices
├─ Submeshes
├─ Blend Shapes
├─ Skin Weights
└─ Bounds
```

DCC Polygon 수와 Import 후 Rendering Vertex 수가 Seam 때문에 달라지는지 비교한다.

LOD별 Mesh Data가 실제로 단계적으로 감소하는지 기록한다.

---

## Wireframe View

Scene View Wireframe으로 Triangle Density를 Screen Space에서 확인한다.

```text
Near Surface
→ Triangle Edge가 구분됨

Far Surface
→ Wire가 Pixel보다 촘촘함
```

Far Object에 Subpixel Triangle가 집중된 영역을 찾는다.

Wireframe Density가 높다고 바로 병목은 아니며 GPU Profile로 우선순위를 검증한다.

---

## RenderDoc Mesh Viewer

GPU Capture에서 Draw의 Input Vertex·Index와 Post-VS Position를 확인할 수 있다.

```text
Mesh Viewer
├─ Input Assembly
├─ Vertex Attributes
├─ Post-VS Output
└─ Triangle Projection
```

실제 Draw에 어떤 LOD Mesh가 들어갔는지와 Screen에서 Triangle가 얼마나 작게 투영되는지 분석할 수 있다.

Rasterizer Counter와 함께 보면 Submitted·Culled·Rasterized Primitive 차이를 이해하기 쉽다.

---

## Vendor GPU Counter

Platform Profiler는 다음과 같은 Counter를 제공할 수 있다.

```text
Counter 후보
├─ Vertex Shader Invocations
├─ Input Primitives
├─ Clipped Primitives
├─ Culled Primitives
├─ Rasterized Primitives
├─ Primitive Setup Busy
├─ Fragment Invocations
└─ Vertex Cache Hit Rate
```

이름과 정의는 GPU Architecture마다 다르다.

Triangle 통계보다 실제 Geometry Pipeline 병목을 직접 확인하는 데 유용하다.

---

## CPU 비용과 Triangle 수

일반적으로 CPU는 Mesh Triangle 하나씩 직접 처리하지 않고 Draw Command와 Buffer를 준비한다.

```text
CPU Cost
→ Renderer·Draw·State 중심

GPU Cost
→ Vertex·Primitive·Fragment 중심
```

Triangle 수가 크게 늘어도 Draw 수가 같으면 CPU Submission 변화가 작을 수 있다.

하지만 Runtime Mesh 생성, CPU Skinning, MeshCollider Cooking와 Readback에서는 CPU가 Vertex·Triangle Data를 직접 처리할 수 있다.

---

## Runtime Mesh 생성

매 Frame CPU에서 Mesh Vertex와 Triangle Array를 만들면 Geometry 수에 비례한 CPU와 Upload 비용이 발생한다.

```text
CPU Generate Vertices·Indices
→ Mesh API Upload
→ GPU Buffer Update
```

Terrain, Procedural Mesh와 Destruction에서 Allocation과 Bounds Recalculation까지 추가될 수 있다.

NativeArray·MeshData API, Buffer 재사용과 변경 범위를 최적화한다.

Static Mesh의 GPU Draw 비용과 다른 문제다.

---

## MeshCollider와 Rendering Triangle

MeshCollider는 Physics가 사용하는 Collision Mesh다.

Render Mesh를 그대로 Collider로 쓰면 고밀도 Triangle가 Physics Cooking과 Query 비용을 늘릴 수 있다.

```text
Render Mesh LOD
≠ Collision Mesh LOD
```

단순한 전용 Collision Mesh를 사용한다.

Rendering Triangle 최적화가 Collider에 자동 반영된다고 가정하지 않는다.

---

## Ray Tracing과 Triangle

Ray Tracing은 Triangle를 Acceleration Structure에 저장하고 Ray Intersection 후보로 검사한다.

```text
Mesh Triangles
→ BLAS Build
→ TLAS Instance
→ Ray Traversal
```

Triangle 수가 많으면 BLAS Memory, Build·Refit과 Intersection 비용이 증가할 수 있다.

Raster LOD와 Ray Tracing LOD 요구는 다를 수 있으며 Reflection Ray에서 Far Geometry Detail를 줄일 수 있다.

Unity Pipeline과 Hardware 지원을 기준으로 별도 Profile한다.

---

## Memory 비용

Geometry Memory는 Vertex Buffer와 Index Buffer 크기로 구성된다.

```text
Mesh Memory
≈ Vertex Count × Vertex Stride
+ Index Count × Index Size
+ Blend Shape·Skin Data
```

Triangle를 줄이면 Index와 종종 Vertex Data도 줄어든다.

하지만 여러 LOD Mesh를 동시에 Load하면 전체 Asset Memory는 증가할 수 있다.

Read/Write Enabled는 CPU-side Mesh Copy를 유지해 Memory를 추가로 사용할 수 있다.

---

## Bandwidth 비용

GPU는 Draw마다 필요한 Vertex·Index Data를 Memory에서 읽는다.

```text
Geometry Bandwidth
← Vertex Count
← Vertex Stride
← Index Size
← Cache Hit Rate
← Instance Count
```

High-poly Mesh를 여러 Instance와 Pass에서 반복하면 Cache를 넘어 Memory Traffic가 커질 수 있다.

Mesh Compression과 Quantization은 Bandwidth·Memory를 줄일 수 있지만 Decode와 품질 Trade-off가 있다.

---

## Mobile GPU

Mobile GPU는 Vertex Throughput, Bandwidth와 전력 Budget이 제한된다.

```text
Mobile Geometry 위험
├─ Subpixel Triangles
├─ Complex Skinning
├─ Many Shadow Passes
├─ Cull Off Foliage
└─ High Vertex Stride
```

Desktop에서 처리 가능한 Triangle가 Mobile에서 Thermal Throttling과 Frame Drop을 만들 수 있다.

LOD, Foliage Density와 Shadow Distance를 대표 저사양 Device에서 검증한다.

---

## XR

Stereo Rendering은 Object Geometry를 두 Eye View에 처리한다.

```text
Left Eye Vertex·Primitive
+ Right Eye Vertex·Primitive
```

Single Pass Instanced는 Draw Submission을 줄이고 Vertex Shader를 Eye Instance로 처리할 수 있지만 두 Projection의 Geometry 작업이 남는다.

높은 Refresh Rate는 Frame당 Geometry Budget을 줄인다.

Foveated Rendering은 Pixel Shader Rate를 낮춰도 Vertex·Triangle 수를 직접 줄이지 않을 수 있어 LOD가 중요하다.

---

## Triangle Budget

고정된 보편 Triangle Budget은 없다.

```text
Budget 변수
├─ Target GPU
├─ Target FPS
├─ Vertex Shader
├─ Pass 수
├─ Instance 수
├─ Screen Triangle Size
├─ Fragment 비용
└─ 다른 Frame Work
```

Platform별 Worst-case Camera에서 Frame Budget을 측정해 Project 기준을 만든다.

Asset당 숫자뿐 아니라 Scene 전체 Submitted Triangle와 Pass 반복을 관리한다.

---

## Asset Budget

Object 중요도와 사용 빈도로 Triangle Budget을 나눈다.

```text
Hero Character
→ 높은 LOD0 Budget

Enemy Crowd
→ 중간 Budget + 빠른 LOD

Background Prop
→ 낮은 Budget

Repeated Foliage
→ 매우 엄격한 Instance Budget
```

한 번만 등장하는 Hero와 수천 번 반복되는 Rock에 같은 Triangle Limit를 적용하지 않는다.

Maximum Simultaneous Count를 곱해 Scene 비용을 추정한다.

---

## Triangle 감소 우선순위

시각적 가치가 낮고 처리 비용이 높은 Geometry부터 줄인다.

```text
1. 중복·내부 Face
2. 화면에서 구분되지 않는 작은 Detail
3. Far LOD Subpixel Geometry
4. 반복 Asset 내부 Edge Loop
5. Tessellation Factor
6. Hair·Foliage 내부 Layer
7. Shadow 전용 Proxy
8. Multi-pass Shell 수
```

Silhouette, Animation Joint와 Gameplay Readability는 보존한다.

---

## 최적화 후 역효과

Triangle를 줄였지만 큰 Texture Alpha Quad로 대체하면 Fragment Overdraw가 증가할 수 있다.

```text
Before
Detailed Leaf Geometry

After
Large Alpha Card
→ Triangle 감소
→ Transparent·Alpha Clip Pixel 증가
```

Normal Map으로 Detail를 대체하면 Vertex는 줄지만 Texture Sample와 Fragment 비용이 늘 수 있다.

한 Pipeline 단계의 감소가 다른 단계의 증가를 만들 수 있다.

---

## Triangle 감소와 Silhouette

외곽 Edge를 줄이면 Mesh 형태가 눈에 띄게 변한다.

```text
High Detail Circle
○

Low Detail
⬡
```

Object가 작게 보일 때 차이가 사라지는 Threshold에서 LOD로 전환한다.

가까운 LOD0에서 무리하게 Triangle를 줄이기보다 Far LOD를 적극적으로 사용한다.

---

## Triangle 감소와 Shading

Vertex 수가 줄면 Normal 보간과 Specular Highlight 형태가 달라질 수 있다.

```text
Dense Sphere
→ Smooth Highlight

Sparse Sphere
→ Faceted Highlight
```

Normal Map과 Weighted Normal로 일부 차이를 보완할 수 있지만 Silhouette는 바꿀 수 없다.

Metallic·Glossy Material는 Geometry Facet 변화가 더 잘 보일 수 있다.

---

## Triangle 감소와 Animation

Character Joint 주변 Edge Loop를 과도하게 줄이면 Skinning Deformation이 무너진다.

```text
Elbow·Knee·Shoulder
→ Bend를 위한 Loop 필요
```

Far LOD에서 Detail를 줄이더라도 Extreme Pose의 Silhouette와 Volume을 유지한다.

Triangle 수보다 Bone Weight와 Topology 품질이 중요할 수 있다.

---

## 단계별 최적화 순서

```text
1. CPU Bound·GPU Bound 구분
2. Draw Call·Triangle·Pixel 지표 수집
3. Frame Debugger로 Geometry가 반복되는 Pass 확인
4. Wireframe으로 Subpixel·내부 Geometry 탐색
5. Force LOD A/B Test
6. Resolution·Shader A/B Test로 병목 분리
7. Triangle와 Vertex Layout 함께 최적화
8. Shadow·Depth·Reflection Pass 재확인
9. 시각 품질과 Memory 비교
10. Target Device에서 재측정
```

Triangle 수를 줄이는 작업은 Asset 제작 비용이 크므로 측정으로 우선순위를 정한다.

---

## 흔한 오해

### Triangle가 두 배면 GPU 시간이 두 배다

Vertex 재사용, Culling, Screen Size, Pass와 현재 병목에 따라 증가량이 다르다.

### Triangle 하나는 Vertex 세 개를 항상 새로 처리한다

Index Buffer와 Post-transform Cache로 이웃 Triangle가 Vertex 결과를 재사용할 수 있다.

### DCC Point 수와 Unity Vertex 수는 같다

Hard Edge, UV Seam, Material와 Lightmap 경계에서 Vertex가 분리될 수 있다.

### Backface Culling이 뒤 Triangle의 모든 비용을 제거한다

Rasterization 전에는 제거하지만 Vertex Shader 작업은 이미 발생할 수 있다.

### Triangle가 작으면 Fragment도 적어서 항상 싸다

Primitive Setup과 2 × 2 Quad Lane 활용이 나빠져 Subpixel Triangle가 비효율적일 수 있다.

### Triangle가 적으면 Rendering이 빠르다

Fullscreen Quad의 복잡한 Fragment Shader와 Overdraw는 Triangle 수가 적어도 비싸다.

### Draw Call를 줄이면 Triangle도 줄어든다

Batching과 Instancing은 제출을 묶지만 Geometry 처리량은 대부분 남는다.

### LOD로 Triangle를 줄이면 모든 GPU 병목이 해결된다

Fragment, Blend, Texture와 Bandwidth Bound에서는 효과가 작을 수 있다.

### Profiler Triangle 통계가 실제 Rasterized Front Face 수다

Submitted Pass·Draw 기준일 수 있으며 Culling과 Clipping 이후 수와 다를 수 있다.

### Polygon은 적을수록 무조건 좋다

품질과 제작 비용을 잃지 않고 현재 Geometry 병목을 해결할 만큼만 줄여야 한다.

### Desktop Triangle Budget을 Mobile·XR에 그대로 쓸 수 있다

GPU Architecture, Pass, Stereo와 목표 FPS가 달라 별도 Profile이 필요하다.

---

## 최종 체크리스트

```text
□ Triangle 수와 실제 Vertex 수를 함께 확인했는가?
□ Index Buffer와 Vertex Cache 재사용이 효율적인가?
□ Hard Edge·UV Seam으로 Vertex가 과도하게 분리되지 않았는가?
□ 사용하지 않는 Vertex Attribute를 제거했는가?
□ Vertex Shader의 Skinning·Wind·Deformation 비용을 확인했는가?
□ Far Mesh에 Subpixel Triangle가 과도하지 않은가?
□ 가늘고 긴 Triangle가 많은가?
□ 내부·중복·겹친 Face를 제거했는가?
□ Tessellation과 Geometry Amplification을 제한했는가?
□ Particle·Foliage·Hair의 반복 Triangle를 확인했는가?
□ Shadow·Depth·Reflection Pass에서 Geometry가 반복되는가?
□ Multi-pass Material의 총 Triangle 제출을 확인했는가?
□ Draw Call와 Triangle 병목을 구분했는가?
□ SRP Batcher·Instancing이 Geometry를 줄이지 않음을 고려했는가?
□ Resolution A/B Test로 Pixel 병목을 분리했는가?
□ ForceLOD Test에서 GPU ms가 의미 있게 줄었는가?
□ 단순 Vertex·Fragment Shader Test를 수행했는가?
□ Mesh Inspector와 Wireframe에서 원인 Asset을 찾았는가?
□ Rendering 통계를 Rasterized Triangle로 오해하지 않았는가?
□ GPU Counter에서 Primitive·Vertex 병목을 확인했는가?
□ Triangle 감소가 Overdraw·Texture 비용을 늘리지 않았는가?
□ Silhouette·Shading·Animation 품질을 보존했는가?
□ Scene 전체와 Pass별 Triangle Budget을 관리하는가?
□ Mobile·XR Target의 목표 FPS에서 검증했는가?
```

---

## 정리

Triangle 수가 많으면 Vertex·Index Buffer Read, Vertex Shader, Primitive Assembly, Face Culling, Clipping과 Rasterization Setup 작업이 증가한다.

Index Buffer와 Post-transform Cache가 Vertex를 재사용하므로 Triangle 수, 실제 Rendering Vertex 수와 Vertex Shader Invocation은 서로 같은 숫자가 아니다.

Hard Edge, UV·Lightmap Seam과 Material Boundary는 같은 Position를 여러 Vertex로 분리해 Geometry Memory와 Skinning 비용을 늘릴 수 있다.

멀리 있는 고밀도 Mesh의 Subpixel·Thin Triangle는 Primitive Setup에 비해 Pixel 기여가 작고 2 × 2 Fragment Quad의 Lane 활용도 낮출 수 있어 LOD가 중요하다.

Shadow, Depth Prepass, Reflection와 Multi-pass Material은 같은 Geometry를 여러 번 처리하며 Batching·Instancing·SRP Batcher는 Draw 비용을 줄여도 Triangle 처리량을 직접 제거하지 않는다.

Fullscreen Shader와 Transparent Overdraw는 Triangle가 적어도 Fragment Bound가 될 수 있으므로 Resolution·Vertex·Fragment·ForceLOD A/B Test로 병목을 먼저 구분해야 한다.

Mesh Inspector, Frame Debugger, Rendering Profiler와 GPU Counter를 연결해 원인 Draw와 Pipeline 단계를 찾고 Target Device에서 Triangle 감소가 실제 CPU·GPU Frame Time 개선으로 이어지는지 검증해야 한다.
