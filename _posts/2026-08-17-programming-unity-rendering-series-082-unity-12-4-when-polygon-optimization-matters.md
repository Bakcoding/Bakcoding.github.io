---
title: "[Unity 렌더링] 12-4. 언제 Polygon 최적화가 중요할까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - Polygon
  - Geometry
  - Optimization
permalink: /programming/unity-12-4-when-polygon-optimization-matters/
toc: true
toc_sticky: true
date: 2026-08-17
last_modified_at: 2026-08-17
---

Polygon 최적화는 GPU Geometry 처리나 Geometry Memory가 실제 병목이고, 줄인 Detail가 화면에서 구분되지 않을 때 중요하다.

```text
Polygon 수가 많다
        │
        ▼
바로 줄인다? ── No
        │
        ▼
Geometry가 병목인가?
        │
        ▼
품질 손실보다 절감 효과가 큰가?
```

Triangle 수가 높은 Asset를 발견했다는 사실만으로 최적화 우선순위가 정해지지는 않는다.

Camera에서 보이는 횟수, Vertex Shader, Pass 수, Screen Triangle 크기와 Target GPU를 함께 측정해야 한다.

---

## Polygon 최적화의 목표

목표는 가능한 한 Polygon를 적게 만드는 것이 아니다.

```text
잘못된 목표
→ 최소 Triangle 수

올바른 목표
→ 품질 기준을 만족하는 최소 필요 Geometry
```

Silhouette, Animation Deformation과 Gameplay Readability에 필요한 Polygon는 유지한다.

화면 결과에 기여하지 않으면서 Vertex·Primitive·Memory 비용만 만드는 Geometry를 줄인다.

---

## 먼저 병목을 확인한다

Polygon 감소가 효과적인 상황은 GPU의 Geometry 관련 단계가 Frame을 제한할 때다.

```text
GPU Geometry Work
├─ Vertex·Index Fetch
├─ Vertex Shader
├─ Skinning·Deformation
├─ Primitive Assembly
├─ Clipping
└─ Rasterizer Setup
```

CPU Script, Draw Call, Fragment Shader, Overdraw와 Bandwidth가 병목이면 Polygon 감소 효과가 작을 수 있다.

현재 가장 느린 단계가 무엇인지 Profile한 뒤 작업을 시작한다.

---

## Geometry Bound의 증거

다음 결과가 함께 나타나면 Geometry 병목 가능성이 높다.

```text
Low LOD 강제 시 GPU ms 크게 감소
Resolution 감소 효과는 작음
단순 Fragment Shader로 바꿔도 변화가 작음
Vertex Shader 단순화 시 개선
Shadow·Depth Pass 제거 시 개선
GPU Counter에서 Vertex·Primitive Unit 사용률 높음
```

징후 하나만으로 확정하지 않는다.

Triangle, Vertex, Pass와 GPU Timeline을 여러 A/B Test로 연결한다.

---

## Resolution Test가 알려 주는 것

내부 Render Resolution을 각 축 절반으로 낮추면 Pixel 수는 약 1/4이 된다.

```text
Resolution 100%
→ Pixel Work 기준

Resolution 50% per Axis
→ 약 25% Pixels
→ Geometry 수는 대부분 동일
```

GPU 시간이 크게 줄면 Fragment·Fill-rate 비중이 높다.

GPU 시간이 거의 유지되면서 LOD를 낮출 때 줄면 Geometry 최적화 우선순위가 높다.

---

## Force LOD Test

Unity LOD Group의 `ForceLOD`로 동일 Camera에서 Geometry Detail만 바꾼다.

```text
Test A
Force LOD0

Test B
Force LOD2
```

Material, Shader와 Screen Coverage가 같을수록 Geometry 감소 효과를 분리하기 쉽다.

LOD2가 Material, Shadow와 Renderer 수도 바꾸면 다음 Test에서 요소를 하나씩 고정한다.

Triangle 감소량과 GPU ms 변화의 관계를 기록한다.

---

## Vertex Shader Test

Mesh를 그대로 두고 Vertex Shader 기능을 줄인다.

```text
Original
├─ Skinning
├─ Wind
├─ Displacement
└─ Complex Varying

Diagnostic
└─ Position Transform
```

성능이 크게 개선되면 Vertex당 연산과 Vertex 수가 중요하다.

이 경우 Polygon·Vertex 감소와 Vertex Shader 단순화를 함께 검토한다.

---

## Fragment Shader Test

같은 Mesh를 단순 Fragment Shader로 Rendering한다.

```text
Geometry 동일
Pixel Shader만 단순화
```

GPU 시간이 크게 줄면 Polygon보다 Fragment·Texture·Lighting 최적화가 먼저일 수 있다.

변화가 작고 Low LOD에서만 빨라지면 Geometry 단계 비중이 높다.

Diagnostic Shader의 Pass·Cull·Depth State를 원본과 최대한 맞춘다.

---

## Polygon 수보다 Vertex 수가 중요할 때

GPU Vertex Shader는 실제 Rendering Vertex를 처리한다.

Hard Edge, UV Seam와 Material Boundary는 같은 Position를 여러 Vertex로 분리한다.

```text
DCC Points: 20,000
Unity Vertices: 45,000 가능
```

Triangle를 줄였어도 Seam가 많아 Vertex가 거의 줄지 않으면 Skinning·Vertex Shader 절감이 제한될 수 있다.

Polygon, Vertex와 Vertex Attribute Stride를 함께 확인한다.

---

## Screen Triangle 크기가 중요하다

같은 Triangle 수라도 화면에 투영되는 크기가 다르다.

```text
Near Mesh
→ Triangle당 여러 Pixels

Far Mesh
→ Pixel보다 작은 Triangle 다수
```

Subpixel Triangle는 Pixel 기여보다 Vertex·Primitive Setup 비용이 커지기 쉽다.

Wireframe이 Pixel Grid보다 촘촘해지는 거리에서 LOD 전환을 검토한다.

Far Object의 Polygon 최적화가 가까운 Hero Mesh보다 높은 우선순위일 수 있다.

---

## 반복 횟수가 중요하다

Asset 하나의 Triangle 수가 작아도 Scene에 수천 번 배치되면 비용이 커진다.

```text
Rock 2,000 Triangles
× 10,000 Instances
= 20M Instance-Triangles
```

GPU Instancing은 Draw Call를 줄이지만 Instance별 Vertex·Primitive 처리는 남는다.

반복 Asset의 LOD, Distance Cull과 Low-poly Mesh는 작은 수정으로 Scene 전체 Geometry를 크게 줄일 수 있다.

---

## Pass 수가 중요하다

Triangle는 Main Color Pass에서 한 번만 처리되는 것이 아닐 수 있다.

```text
Main Color
+ Depth Prepass
+ Shadow Cascade
+ Reflection Camera
+ Outline Pass
```

Mesh 100,000 Triangle가 네 Pass에서 Draw되면 Geometry Work가 여러 번 반복된다.

Polygon 최적화 가치는 Asset Triangle 수에 실제 Pass·Camera 반복 횟수를 곱해 판단한다.

---

## Shadow가 무거운 Scene

Directional Shadow Cascade와 Additional Light Shadow는 Caster Geometry를 Light 관점에서 다시 Rendering한다.

```text
Character LOD0
→ Main Camera
→ Cascade 0
→ Cascade 1
→ Point Light Shadow Faces 가능
```

Main Camera에서 작은 Object가 Shadow Map에서 많은 Triangle를 제출할 수 있다.

낮은 LOD Shadow Caster, Shadow Proxy, Shadow Distance와 Casting Off를 비교한다.

---

## Depth Prepass가 있는 Scene

Depth Prepass는 Opaque Mesh를 Depth-only로 먼저 그린다.

```text
Depth Pass
→ Geometry 1회

Color Pass
→ Geometry 다시 처리
```

비싼 Fragment Overdraw를 줄일 수 있지만 Vertex·Primitive 비용이 반복된다.

Vertex Bound Scene에서는 Polygon 감소 효과가 Depth와 Color Pass 모두에 나타날 수 있다.

Depth Prepass를 끄는 Test는 Fragment 비용 변화도 동반하므로 결과를 분리해 해석한다.

---

## Reflection Camera가 있는 Scene

Planar Reflection, Mirror와 Portal은 Scene Geometry를 별도 Camera에서 다시 그린다.

```text
Main Camera Triangles
+ Reflection Camera Triangles
+ Portal Camera Triangles
```

Reflection Texture가 작아 Pixel 비용은 낮아도 Vertex·Triangle 수가 그대로면 Geometry 부담이 남는다.

Secondary Camera에 낮은 LOD Bias, Layer Mask와 Shadow Off를 적용할 수 있는지 검토한다.

---

## Multi-pass Material

Outline, Fur Shell와 특수 Effect는 같은 Mesh를 여러 번 Draw한다.

```text
Base Pass
+ Outline Pass
+ Fur Shell × 8
```

High-poly Mesh에 Multi-pass를 적용하면 Triangle Processing가 곱으로 증가한다.

Polygon 감소, Pass 통합, Screen Space Effect와 Far LOD Effect 제거 중 어느 변경이 품질 대비 효율적인지 비교한다.

---

## Skinned Character

Character Mesh는 Skinning과 Blend Shape 때문에 Vertex당 비용이 높다.

```text
Skinned Cost
≈ Vertex 수
× Bone Influence
× Active Deformation
```

Crowd에 High-poly Character가 반복되면 Polygon 최적화 우선순위가 높다.

Character LOD에서 Vertex·Triangle, Bone Weight, Blend Shape와 Material 수를 함께 줄인다.

Hero Character는 Close-up 품질을 보존하고 NPC Crowd를 먼저 최적화할 수 있다.

---

## Blend Shape가 많은 Character

Facial Mesh는 높은 Vertex Density와 여러 Blend Shape Delta를 가진다.

```text
LOD0 Face
→ Wrinkle·Lip Detail

LOD2 Face
→ Simple Shape
→ Blend Shape 감소
```

Far Character에서 얼굴 Detail를 구분하기 어렵다면 Mesh와 활성 Shape 수를 줄인다.

LOD Mesh Memory에 Blend Shape Data가 중복 저장되는지도 확인한다.

---

## Foliage

Tree와 Grass는 많은 Leaf Card, Wind Vertex Shader, Alpha Clip와 Double-sided Rendering을 결합한다.

```text
Foliage 병목
├─ Triangle·Vertex
├─ Wind Deformation
├─ Alpha Clip
├─ Overdraw
└─ Shadow
```

Geometry와 Fragment가 동시에 병목일 수 있다.

Card 수를 줄이면서 한 Card의 투명 면적을 크게 만들면 Overdraw가 증가할 수 있다.

Triangle와 Alpha Coverage의 균형을 A/B Test한다.

---

## Hair

Hair Card와 Strand는 작은 Triangle, 많은 Layer와 복잡한 Anisotropic Shader를 사용한다.

```text
Hair LOD
├─ 내부 Card 제거
├─ Strand Cluster 단순화
├─ Material 단순화
└─ Far에서는 Cap·Impostor
```

Silhouette를 만드는 외부 Card는 유지하고 안쪽에서 겹치는 Layer부터 줄인다.

Geometry 감소와 Transparent Overdraw 감소가 동시에 발생할 수 있어 효과가 크다.

---

## Terrain

넓은 Terrain를 최고 Detail Grid로 그리면 먼 Patch에 Subpixel Triangle가 대량으로 생긴다.

```text
Near Patch → Dense Geometry
Far Patch  → Sparse Geometry
```

Terrain LOD, Heightmap Pixel Error와 Patch Size를 조정한다.

전체 Terrain Mesh를 수작업으로 단순화하기보다 Camera 거리 기반 Adaptive Detail가 적합하다.

LOD 경계 Crack와 Vegetation Density도 함께 확인한다.

---

## Mesh Particle

Mesh Particle는 Alive Particle마다 Geometry를 반복한다.

```text
300 Triangle Mesh
× 5,000 Particles
= 1.5M Triangle Instances
```

화면에서 작게 보이는 Debris에 복잡한 Mesh를 사용할 필요가 없을 수 있다.

Low-poly Mesh, Billboard와 Particle Count 감소를 비교한다.

Mesh Particle가 Shadow를 만들면 Shadow Geometry도 반복된다.

---

## Destruction Debris

파괴 Object는 짧은 순간 수백 개 조각을 생성한다.

```text
Original Building
→ Debris Mesh × 500
```

각 조각이 작은데도 원본 Detail를 유지하면 Vertex·Draw와 Physics Collider 비용이 급증한다.

Debris 전용 단순 Mesh, 짧은 Lifetime, Distance Cull와 Mesh Particle Instancing을 사용한다.

Render Polygon와 Collision Polygon를 별도로 단순화한다.

---

## Mobile에서 중요해지는 조건

Mobile GPU는 Vertex Throughput, Bandwidth와 전력 Budget이 제한적이다.

```text
Mobile Geometry 위험
├─ 많은 Skinned Vertices
├─ Small Triangles
├─ 여러 Shadow Pass
├─ High Vertex Stride
└─ Sustained Thermal Load
```

Desktop에서 차이가 작아도 저사양 Mobile에서 Geometry Bound가 될 수 있다.

대표 Device의 장시간 Gameplay에서 LOD·Triangle A/B Test를 수행한다.

---

## XR에서 중요해지는 조건

XR은 두 Eye의 View에서 Geometry를 처리하고 높은 목표 FPS를 요구한다.

```text
90 FPS → 약 11.1 ms
120 FPS → 약 8.3 ms
```

Single Pass가 CPU Draw를 줄여도 Eye별 Vertex·Primitive 작업은 남을 수 있다.

Foveated Rendering은 Fragment Rate를 낮추지만 Polygon 수를 직접 줄이지 않는 경우가 있다.

LOD와 Polygon 최적화가 XR에서 상대적으로 중요해질 수 있다.

---

## Ray Tracing에서 중요해지는 조건

Ray Tracing은 Triangle를 Acceleration Structure에 저장한다.

```text
Geometry
→ BLAS Build·Refit
→ Memory
→ Ray Intersection
```

Dynamic High-poly Mesh가 많으면 BLAS Update와 Memory 비용이 커진다.

Raster Camera에 필요한 LOD와 Ray Tracing용 Geometry LOD가 다를 수 있다.

Reflection·Shadow Ray에서 Far Detail를 줄일 수 있는지 Pipeline 기능을 확인한다.

---

## Runtime Mesh 생성

CPU가 Procedural Mesh를 매 Frame 생성하면 Polygon 수가 CPU 작업과 Upload에 직접 영향을 준다.

```text
Generate Vertices·Indices
→ Recalculate Bounds·Normals
→ Upload Mesh Data
```

Water, Voxel, Terrain와 Destruction에서 GPU Draw 이전에 CPU 병목이 생길 수 있다.

변경된 Chunk만 갱신하고 Buffer를 재사용하며 Job·MeshData API를 검토한다.

---

## Voxel Mesh

Voxel World의 각 Block Face를 모두 생성하면 내부에 보이지 않는 Face가 대량으로 생긴다.

```text
Naive Voxel
→ Block당 최대 12 Triangles

Surface Extraction
→ 외부 Face만 생성

Greedy Meshing
→ 인접 Face 병합
```

Polygon 최적화가 GPU뿐 아니라 Chunk 생성, Upload와 Collider 비용을 크게 줄일 수 있다.

Dynamic Edit 비용과 Mesh Rebuild 범위를 함께 측정한다.

---

## CAD·Photogrammetry Asset

CAD와 Scan Asset는 Rendering에 필요하지 않은 작은 부품과 매우 높은 Triangle Density를 가질 수 있다.

```text
원본 Data
├─ Bolt Thread
├─ 내부 기계 부품
├─ 미세 Surface Noise
└─ 중복 Shell
```

Game Camera에서 구분되지 않는 Detail를 Normal·Texture로 Bake하고 내부 Geometry를 제거한다.

자동 Decimation만으로 Hard Surface Edge와 UV가 무너지지 않는지 검수한다.

---

## Architecture Asset

건물 Asset는 Camera가 들어갈 수 있는 내부와 외부 요구가 다르다.

```text
Exterior-only Building
→ 내부 Face 제거 가능

Enterable Building
→ Room별 Geometry·LOD 필요
```

전체 Building를 하나의 High-poly Mesh로 두면 Frustum·Occlusion Culling 단위도 커진다.

Room, Floor와 Street Block 단위로 분할하고 Far HLOD를 만든다.

---

## Hero Asset는 언제 줄일까?

Hero Character와 Main Weapon는 화면을 크게 차지하며 Silhouette·Specular Detail가 잘 보인다.

```text
Hero LOD0
→ Polygon 가치 높음
```

Geometry Bound 증거가 없다면 품질을 희생하며 LOD0를 공격적으로 줄이지 않는다.

중복 Face, 보이지 않는 내부 Geometry와 불필요한 Vertex Attribute처럼 품질에 영향 없는 부분부터 정리한다.

Far LOD는 별도로 적극 최적화한다.

---

## Background Asset는 언제 줄일까?

Camera가 가까이 가지 않는 Background Asset는 LOD0 자체가 과도할 수 있다.

```text
Maximum Screen Size가 5%
→ Close-up Detail 사용되지 않음
```

Asset Import 시 Maximum Usage Distance를 정의하고 그 Screen Size에서 필요한 Polygon만 유지한다.

원본 High Mesh는 Source Asset로 보관하고 Runtime Build에는 필요한 LOD만 포함할 수 있다.

---

## 반복 Asset가 가장 높은 우선순위일 수 있다

작은 개선도 배치 수만큼 곱해진다.

```text
Tree LOD1
10,000 → 7,000 Triangles
절감 3,000

× Visible Trees 2,000
→ 6M Triangle 절감 가능
```

Hero Mesh에서 같은 3,000 Triangle를 줄이는 것보다 Scene 효과가 훨씬 크다.

Asset당 수보다 Maximum Visible Instance 수를 우선한다.

---

## Polygon 감소 우선순위 식

개념적인 우선순위를 다음처럼 생각할 수 있다.

```text
Priority
≈ Saved Vertices·Triangles per Instance
× Maximum Visible Instances
× Pass Repetitions
× Vertex Shader Cost
× Geometry Bottleneck Weight
```

정확한 수식이 아니라 영향을 주는 변수를 빠뜨리지 않기 위한 모델이다.

화질 영향과 제작 시간을 분모에 두면 실무 우선순위를 정하기 쉽다.

---

## 줄이기 좋은 Polygon

```text
우선 후보
├─ 완전히 중복된 Face
├─ 절대 보이지 않는 내부 Face
├─ 평면의 불필요한 Edge Loop
├─ Far Distance의 작은 Bevel
├─ Texture로 대체 가능한 Surface Detail
├─ 반복 Foliage 내부 Card
├─ 과도한 Tessellation
└─ 사용하지 않는 LOD0 Detail
```

품질 변화가 없거나 Screen에서 구분되지 않는 부분이다.

Wireframe, Overdraw와 Camera Path를 함께 확인한다.

---

## 유지해야 할 Polygon

```text
보존 후보
├─ Silhouette Edge
├─ Animation Joint Loop
├─ Hard Surface Major Edge
├─ Shadow Silhouette
├─ Gameplay Readability Feature
├─ Destruction·Cut Surface
└─ 가까운 Camera의 Specular Shape
```

단순 Triangle Ratio 목표 때문에 이 Geometry를 제거하면 품질 손실이 크다.

Normal Map은 Surface Shading을 근사할 수 있지만 Silhouette와 Deformation Volume을 대체하지 못한다.

---

## 평면의 불필요한 분할

변형되지 않는 완전한 평면에 많은 Edge가 있어도 화면 결과가 같을 수 있다.

```text
Before
┌─┬─┬─┬─┐
├─┼─┼─┼─┤
└─┴─┴─┴─┘

After
┌───────┐
└───────┘
```

Lightmap UV, Vertex Color, Tessellation와 Deformation에 Edge가 필요한지 먼저 확인한다.

단순화 후 Normal·Tangent와 Baking 결과를 재검증한다.

---

## Bevel의 가치

Hard Surface Bevel은 Edge에서 Highlight를 만들어 형태를 자연스럽게 보이게 한다.

```text
Sharp Edge
→ Highlight 거의 없음

Beveled Edge
→ Specular Highlight
```

가까운 LOD에서는 가치가 높지만 Far LOD에서는 몇 Pixel 이하라 구분되지 않을 수 있다.

LOD0 Bevel은 유지하고 LOD1·2에서 Segment를 줄이거나 Normal Map으로 Bake한다.

---

## Cylinder Segment

Cylinder와 Cable의 Segment 수는 Silhouette를 결정한다.

```text
Near Cylinder
→ 24·32 Segments

Far Cylinder
→ 8·12 Segments
```

Object가 화면에서 작아질수록 Segment 차이가 구분되지 않는다.

단면 Segment를 줄이면 길이 방향 Vertex·Triangle도 함께 줄어 효과가 크다.

Specular가 강한 Material에서는 Facet가 더 잘 보일 수 있다.

---

## Normal Map으로 대체할 Detail

Bolt, Groove와 Surface Noise는 Normal Map으로 Bake할 수 있다.

```text
High Mesh
→ Normal Bake
→ Low Mesh + Normal Map
```

Geometry·Vertex는 줄지만 Fragment Texture Sample와 Tangent Data가 필요하다.

Fragment Bound Asset에서는 Normal Map 대체가 반드시 빠르지 않을 수 있다.

Silhouette를 바꾸지 않는 Detail에 적용한다.

---

## Alpha Card로 대체할 때

복잡한 잎 Geometry를 큰 Alpha Card로 바꾸면 Triangle는 줄지만 투명 Pixel가 늘 수 있다.

```text
Geometry Leaves
→ High Triangles, Tight Coverage

Alpha Card
→ Low Triangles, Large Transparent Area
```

Mobile Fill-rate와 Shadow Alpha Clip 비용이 증가할 수 있다.

Triangle와 Overdraw A/B Test를 같은 Camera에서 수행한다.

---

## Mesh Combining과 Polygon

여러 Mesh를 합쳐도 Polygon 수는 대체로 그대로다.

```text
Before
10 Meshes × 1,000 Triangles

After
1 Mesh × 10,000 Triangles
```

Draw Call는 줄 수 있지만 Bounds가 커져 Offscreen·Occluded Polygon까지 함께 처리될 수 있다.

Polygon 최적화와 Batching 최적화를 구분하고 공간적으로 함께 보이는 Object만 결합한다.

---

## Decimation의 비용

자동 Decimation은 Edge Collapse 등으로 Triangle를 줄인다.

```text
오류 후보
├─ Silhouette 손실
├─ UV 왜곡
├─ Normal 변화
├─ Thin Part 제거
├─ Material Boundary 손상
└─ Skin Weight 붕괴
```

Target Ratio만 지정하지 말고 Screen Error, Border·Seam 보존과 Bone Weight 정책을 설정한다.

모든 Animation Pose와 Shadow에서 검수한다.

---

## Vertex Cache를 고려한 최적화

Triangle 수가 같아도 Index 순서가 Vertex Cache 재사용에 영향을 준다.

```text
좋은 순서
→ 인접 Triangle가 최근 Vertex 공유

나쁜 순서
→ 멀리 떨어진 Vertex를 반복 변환
```

Mesh Import Optimization이 Vertex·Index 순서를 재배치할 수 있다.

Runtime Mesh가 특정 Index Order에 의존하지 않는지 확인하고 Target GPU에서 효과를 측정한다.

---

## Vertex Attribute 최적화

Polygon를 줄이기 어려워도 Vertex당 Data를 줄일 수 있다.

```text
제거 후보
├─ 사용하지 않는 Tangent
├─ 빈 UV Channel
├─ 사용하지 않는 Vertex Color
├─ 불필요한 Bone Influence
└─ 과도한 Precision
```

Vertex Buffer Memory와 Fetch Bandwidth가 감소한다.

Shader Variant가 해당 Attribute를 실제로 요구하지 않는지 확인한다.

---

## Read/Write Enabled

Mesh Read/Write가 켜져 있으면 CPU가 접근할 수 있는 Mesh Data Copy를 Memory에 유지할 수 있다.

```text
GPU Mesh Data
+ CPU-readable Copy
```

Runtime 변형·읽기가 필요 없는 Static Mesh는 비활성화를 검토한다.

이는 Polygon 처리 속도보다 Memory 최적화에 가깝다.

MeshCollider, Runtime Combine와 Script Access 요구를 확인한다.

---

## Mesh Compression

Mesh Compression은 Vertex Data Precision과 저장 크기를 줄일 수 있다.

```text
장점
→ Build·Memory 감소 가능

주의
→ Position·Normal·UV 정밀도 손실
```

Polygon 수는 그대로지만 Geometry Bandwidth와 Memory에 영향을 줄 수 있다.

큰 World Position, Thin Mesh와 Lightmap UV에서 Artifact를 확인한다.

---

## LOD가 가장 안전한 최적화인 경우

LOD0 품질을 유지하고 화면에서 Detail가 구분되지 않는 거리에서 Low Mesh로 바꾸면 가까운 품질 손실이 없다.

```text
Near
→ Original High Mesh

Far
→ Optimized Low Mesh
```

Hero Asset를 직접 저해상도로 만드는 것보다 LOD 단계에서 Polygon를 줄이는 편이 품질과 성능을 모두 만족하기 쉽다.

Cross-fade 비용과 LOD Asset Memory는 별도로 관리한다.

---

## HLOD가 중요한 경우

먼 거리의 City와 Forest는 개별 Object LOD만으로 Draw 수가 많이 남을 수 있다.

```text
Far District
├─ Building LOD2 × 100
└─ Draws 다수

HLOD
└─ District Proxy 1개
```

HLOD는 Polygon, Renderer와 Material 수를 함께 줄일 수 있다.

Cluster Bounds, Streaming와 Baked Texture Memory가 증가하는 Trade-off가 있다.

---

## Polygon 최적화가 중요하지 않은 경우

다음 조건에서는 우선순위가 낮을 수 있다.

```text
CPU Script Bound
Draw Call Bound인데 Mesh 수는 적음
4K Fragment Shader Bound
Transparent Overdraw Bound
Texture Bandwidth Bound
Triangle가 이미 충분히 큼
GPU Geometry Unit 여유
Frame Budget를 만족
```

이 경우 Polygon를 줄여도 GPU ms가 거의 변하지 않고 품질과 제작 시간만 잃을 수 있다.

현재 병목을 직접 줄이는 작업을 먼저 한다.

---

## CPU Draw Call Bound

작은 Mesh 수천 개가 각각 Draw되면 Triangle 수보다 Renderer와 State Submission이 문제일 수 있다.

```text
10,000 Draws
× Draw당 2 Triangles
```

Triangle를 2개에서 1개로 줄일 수 없으며 효과도 작다.

Batching, Instancing, Material 공유와 Renderer 통합을 검토한다.

통합으로 Culling Granularity가 떨어지지 않는지 함께 본다.

---

## Fragment Bound

Fullscreen Post-processing와 큰 Transparent Quad는 Triangle가 거의 없어도 비싸다.

```text
2 Triangles
× 4K
× 10 Texture Samples
× 5 Layers
```

Polygon 최적화가 아니라 Resolution, Shader, Layer와 Blend를 줄여야 한다.

Low-poly Mesh로 바꿨는데 Screen Coverage가 같다면 Fragment 시간도 거의 유지될 수 있다.

---

## Memory Bound지만 Geometry가 원인이 아닌 경우

Texture와 Render Target가 Memory Bandwidth 대부분을 사용하면 Mesh Polygon 감소 효과가 작을 수 있다.

```text
Bandwidth
├─ 4K HDR Color
├─ G-buffer
├─ Texture Samples
└─ Post-processing
```

Geometry Buffer 비중과 Texture·Color Traffic를 GPU Counter로 구분한다.

Mesh Memory가 크다는 사실과 Frame Bandwidth 병목을 같은 문제로 보지 않는다.

---

## 품질 손실 비용

Polygon 감소는 성능 외 비용을 만든다.

```text
Trade-off
├─ Silhouette 변화
├─ Specular Faceting
├─ Animation Collapse
├─ Shadow Pop
├─ LOD Memory
├─ 제작·검수 시간
└─ Asset Pipeline 복잡도
```

0.1ms를 줄이기 위해 Hero Asset 품질과 제작 일정을 크게 잃는 선택이 타당한지 평가한다.

반복 Background Asset의 자동 LOD처럼 효율이 높은 작업부터 진행한다.

---

## 제작 시간 대비 효과

Asset별 Manual Retopology는 높은 품질을 제공하지만 시간이 많이 든다.

```text
Manual
→ Hero·Deforming Asset

Automatic
→ Static Background Prop

Procedural HLOD
→ Large World Cluster
```

Profiling에서 상위 Geometry Cost를 만드는 Asset에 Artist 시간을 집중한다.

사용 빈도가 낮은 Asset 전체를 일괄 Retopology하지 않는다.

---

## Platform별 전략

```text
PC High-end
→ 높은 Geometry Budget, 품질 우선 가능

Mobile
→ Vertex·Bandwidth·Thermal 제한

XR
→ Stereo·높은 FPS, LOD 중요

Console
→ 고정 Hardware에 맞춘 Budget
```

하나의 Mesh LOD Set를 공유하더라도 Quality LOD Bias와 Maximum Level를 Platform별로 조정한다.

Target별 Camera, Resolution와 Pass 구성이 달라 별도 Profile한다.

---

## Polygon Budget는 결과로 정한다

보편적인 `Character는 몇 Polygon` 규칙은 정확하지 않다.

```text
Budget 변수
├─ Maximum Visible Count
├─ Vertex Shader Cost
├─ Shadow Pass Count
├─ Target FPS
├─ GPU Architecture
├─ Screen Size
└─ 전체 Scene Budget
```

Target Device에서 Worst-case Scene이 Frame Budget를 만족하도록 Asset Category별 Budget를 역산한다.

Triangle뿐 아니라 Vertex, Material, Bone와 Texture Budget를 함께 문서화한다.

---

## Asset Audit 표

| Asset | LOD0 Tri | Visible Max | Pass 반복 | GPU 영향 | 우선순위 |
|---|---:|---:|---:|---|---|
| Hero | 120K | 1 | 3 | 중간 | 품질 우선 |
| Enemy | 60K | 30 | 3 | 높음 | 높음 |
| Tree | 15K | 2000 | 2 | 매우 높음 | 매우 높음 |
| Rock | 4K | 500 | 1 | 낮음 | 중간 |

숫자는 분류 형식의 예시다.

실제 Frame Capture에서 Visible Count와 Pass를 채워 우선순위를 정한다.

---

## Frame Debugger로 원인 Asset 찾기

Draw Event에서 Mesh, Submesh와 Pass를 확인한다.

```text
확인 질문
├─ High-poly Mesh가 어떤 Camera에 Draw되는가?
├─ Low LOD가 실제 선택됐는가?
├─ Shadow Pass에 LOD0가 남았는가?
├─ Depth·Outline에서 반복되는가?
├─ Reflection Camera가 다시 그리는가?
└─ Submesh Material가 Draw를 늘리는가?
```

Scene 전체 Triangle 숫자에서 실제 최적화할 Asset를 찾는 단계다.

---

## Rendering Profiler로 우선순위 확인

Batches, Triangle와 Vertex 통계를 Camera 상태별로 기록한다.

```text
View A: Crowd
View B: Forest
View C: Indoor
```

Object Category를 끄거나 LOD를 강제하며 통계와 CPU·GPU ms 변화를 비교한다.

Triangle 수는 크게 줄었지만 GPU 시간이 같다면 Geometry가 병목이 아니다.

---

## GPU Counter로 확정한다

Vendor Profiler에서 Geometry 관련 Counter를 확인한다.

```text
후보
├─ Vertex Shader Busy
├─ Vertex Invocations
├─ Primitive Setup Busy
├─ Input·Rasterized Primitives
├─ Small Triangle Efficiency
├─ Vertex Cache Hit Rate
└─ Geometry Bandwidth
```

Counter 이름과 의미는 GPU마다 다르다.

Fragment, Texture와 Memory Unit 상태도 함께 비교해 진짜 제한 요소를 찾는다.

---

## 최적화 전후 표

| Variant | Triangles | Vertices | Draws | GPU Geometry | GPU Frame |
|---|---:|---:|---:|---:|---:|
| Baseline | 14M | 9M | 1200 | 6.0 ms | 18.0 ms |
| Low LOD | 5M | 3M | 1100 | 2.5 ms | 13.8 ms |
| Low Poly + Shadow Proxy | 4M | 2.5M | 950 | 1.8 ms | 12.4 ms |

숫자는 측정 양식의 예시다.

품질 Screenshot와 Memory 변화도 같은 표에 기록한다.

---

## 단계별 의사결정

```text
1. Target Device Frame Capture
        │
        ▼
2. CPU·GPU Bound 구분
        │
        ▼
3. Resolution·Shader·LOD A/B Test
        │
        ▼
4. Geometry Bound 증거가 있는가?
   ├─ No  → 다른 병목 최적화
   └─ Yes
        │
        ▼
5. 반복 수·Pass·Vertex Cost로 Asset 순위 결정
        │
        ▼
6. 품질 영향 없는 Geometry부터 제거
        │
        ▼
7. LOD·Proxy·HLOD 적용
        │
        ▼
8. 동일 Capture 재측정
```

작업량이 큰 Retopology 전에 진단 단계에서 기대 절감량을 확인한다.

---

## 흔한 오해

### Polygon가 많으면 무조건 가장 먼저 줄여야 한다

현재 병목이 Fragment, Draw Call나 Script라면 성능 효과가 작을 수 있다.

### Triangle 수가 높은 Asset부터 줄이면 된다

Maximum Visible Instance, Pass 반복과 Vertex Shader Cost를 곱한 Scene 기여도가 더 중요하다.

### Hero Character가 가장 복잡하므로 우선순위가 높다

한 개만 보이는 Hero보다 수천 개 반복되는 Tree의 작은 개선이 더 클 수 있다.

### Polygon 최적화는 Triangle만 줄이는 작업이다

Vertex Seam, Attribute, Material, Shadow, LOD와 Culling도 Geometry 비용에 영향을 준다.

### Low-poly Mesh는 항상 원본보다 빠르다

Material·Submesh가 늘거나 Alpha Card Overdraw가 커지면 다른 병목이 증가할 수 있다.

### Normal Map 대체는 항상 최적화다

Vertex는 줄지만 Texture Sample와 Tangent Data가 추가되어 Fragment Bound에서는 손해일 수 있다.

### Mesh Combining은 Polygon 최적화다

Triangle는 유지되며 Draw는 줄지만 Culling Granularity가 낮아질 수 있다.

### 한 Platform의 Polygon Budget을 모두 사용할 수 있다

Mobile·XR·PC는 GPU, Pass와 목표 FPS가 달라 별도 Budget가 필요하다.

### 자동 Decimation 비율만 맞추면 끝난다

Silhouette, UV, Animation, Shadow와 실제 전환 거리의 검수가 필요하다.

### Triangle 통계가 줄면 성공이다

CPU·GPU Frame Time과 품질 기준이 실제로 개선돼야 한다.

### Polygon는 적을수록 좋은 Asset다

필요한 형태를 가장 효율적으로 표현하는 Geometry가 좋은 Asset다.

---

## 최종 체크리스트

```text
□ Target Device에서 CPU·GPU 병목을 구분했는가?
□ Resolution 감소보다 LOD 감소에 GPU가 더 반응하는가?
□ Vertex·Fragment Shader A/B Test를 수행했는가?
□ Triangle와 실제 Rendering Vertex 수를 함께 확인했는가?
□ Far Mesh의 Subpixel Triangle를 Wireframe으로 확인했는가?
□ Maximum Visible Instance 수를 기록했는가?
□ Main·Depth·Shadow·Reflection Pass 반복을 계산했는가?
□ Vertex Shader의 Skinning·Wind·Deformation 비용을 포함했는가?
□ 반복 Foliage·Crowd·Particle를 우선 검토했는가?
□ Hero와 Background Asset 중요도를 구분했는가?
□ 중복·내부 Face와 평면 Edge부터 제거했는가?
□ Silhouette·Joint·Gameplay Feature를 보존했는가?
□ Bevel·Cylinder Segment를 LOD별로 줄였는가?
□ Normal Map 대체의 Fragment 비용을 측정했는가?
□ Alpha Card가 Overdraw를 늘리지 않는가?
□ Mesh Combining과 Polygon 감소를 구분했는가?
□ Decimation 후 UV·Normal·Skin Weight를 검수했는가?
□ 사용하지 않는 Vertex Attribute를 제거했는가?
□ Read/Write·Mesh Compression의 Memory 효과를 구분했는가?
□ LOD·Shadow Proxy·HLOD를 비교했는가?
□ Polygon Budget를 Platform·FPS별로 정했는가?
□ Frame Debugger에서 원인 Mesh·Pass를 찾았는가?
□ GPU Geometry Counter로 병목을 검증했는가?
□ 최적화 전후 CPU·GPU ms와 품질을 다시 측정했는가?
```

---

## 정리

Polygon 최적화는 Triangle 수가 높다는 이유가 아니라 Vertex·Primitive 처리나 Geometry Memory가 Target Device의 실제 병목일 때 중요하다.

Resolution, 단순 Fragment Shader와 ForceLOD A/B Test를 조합하면 Pixel 병목과 Geometry 병목을 구분할 수 있다.

최적화 우선순위는 Asset의 Triangle 수보다 실제 Vertex 수, Maximum Visible Instance, Pass 반복, Vertex Shader 비용과 Screen Triangle 크기로 결정한다.

Crowd, Foliage, Terrain, Mesh Particle, Skinned Character와 Shadow·Reflection에 반복되는 Mesh는 작은 Polygon 감소도 Scene 전체에서 크게 누적된다.

중복·내부 Face와 구분되지 않는 Far Detail부터 줄이고 Silhouette, Animation Joint, Shadow 형태와 Gameplay Readability에 필요한 Geometry는 보존해야 한다.

Normal Map과 Alpha Card 대체는 Vertex를 줄이는 대신 Fragment Sample와 Overdraw를 늘릴 수 있고 Mesh Combining은 Draw를 줄이는 대신 Culling Granularity를 낮출 수 있다.

Frame Debugger, Rendering Profiler와 GPU Counter로 원인 Asset·Pass를 찾고 최적화 전후 CPU·GPU Frame Time, Memory와 시각 품질을 Target Camera에서 재측정해야 한다.
