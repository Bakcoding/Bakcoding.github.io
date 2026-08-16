---
title: "[Unity 렌더링] 12-1. LOD는 왜 필요할까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - LOD
  - Optimization
  - LevelOfDetail
permalink: /programming/unity-12-1-why-lod-is-needed/
toc: true
toc_sticky: true
date: 2026-08-16
last_modified_at: 2026-08-16
---

LOD는 Object가 화면에서 차지하는 크기에 맞춰 Geometry와 Rendering 품질을 단계적으로 낮추는 기법이다.

```text
Camera
  │
  ├─ Near Object → LOD0 · High Detail
  ├─ Mid Object  → LOD1 · Medium Detail
  ├─ Far Object  → LOD2 · Low Detail
  └─ Very Far    → Cull 또는 Impostor
```

멀리 있는 Object는 화면에서 작은 Pixel 영역만 차지하므로 가까운 Object와 같은 Triangle, Shader와 Texture Detail을 사용해도 차이를 구분하기 어렵다.

LOD는 눈에 보이지 않는 Detail에 사용하는 CPU·GPU·Memory 비용을 줄이고 가까운 Object의 품질에 더 많은 Frame Budget을 배분한다.

---

## LOD의 의미

LOD는 `Level of Detail`의 약자다.

```text
LOD0
→ 가장 높은 Detail

LOD1
→ 중간 Detail

LOD2
→ 낮은 Detail

Cull
→ Rendering하지 않음
```

숫자가 작을수록 높은 Detail로 사용하는 Convention이 일반적이지만 Project Naming은 다를 수 있다.

LOD는 하나의 Mesh를 단순화하는 기능만을 뜻하지 않는다.

Object가 멀어질수록 Geometry, Material, Shadow, Animation과 Effect를 함께 단계화하는 품질 관리 전략이다.

---

## 왜 같은 Detail을 유지하면 낭비일까?

가까운 Tree는 잎과 Branch Silhouette를 구분할 수 있다.

멀리 있는 Tree는 화면에서 수십 Pixel 크기로 보인다.

```text
Near Tree
████████████████
→ Branch·Leaf Detail 구분 가능

Far Tree
██
→ 세부 Triangle 구분 어려움
```

Far Tree에 100,000 Triangle를 사용해도 최종 Pixel이 20 × 40이라면 대부분의 Geometry Detail은 같은 Pixel에 겹친다.

시각 결과에 거의 기여하지 않는 Vertex와 Triangle를 계속 처리하는 셈이다.

---

## World Distance보다 Screen Size가 중요하다

LOD를 단순히 Camera와 Object 사이의 거리만으로 이해하면 부족하다.

```text
Large Building at 500m
→ 화면에서 여전히 큼

Small Pebble at 20m
→ 화면에서 매우 작음
```

두 Object는 거리가 다르지만 실제 Detail 필요성은 Screen에 투영된 크기로 결정된다.

```text
Perceived Detail Need
≈ Projected Screen Size
```

Unity LOD Group이 Screen Relative Height를 사용하는 이유다.

---

## Perspective Projection과 크기

Perspective Camera에서 같은 크기의 Object는 멀어질수록 화면에 작게 투영된다.

```text
Projected Size
≈ Object World Size
  ─────────────────
       Distance
```

정확한 값에는 FOV, Aspect와 Projection Matrix가 영향을 준다.

```text
거리 2배
→ 화면 높이는 대략 1/2
→ 화면 면적은 대략 1/4 가능
```

멀리 갈수록 Detail 차이는 빠르게 작아지므로 낮은 LOD로 전환할 수 있다.

---

## Orthographic Camera에서는 다르다

Orthographic Projection은 거리에 따라 Object의 투영 크기가 변하지 않는다.

```text
Near Object □
Far Object  □
→ 같은 World Size면 같은 Screen Size
```

Camera와 멀어진다는 이유만으로 낮은 LOD를 선택하면 Detail가 눈에 보이는데 Mesh가 단순해질 수 있다.

Orthographic Camera에서는 Orthographic Size, Zoom Level, Object 크기와 Custom Distance 정책을 함께 고려한다.

Perspective 기반 Threshold를 그대로 적용하지 않는다.

---

## Pixel보다 작은 Triangle

멀리 있는 고밀도 Mesh에서는 여러 Triangle가 한 Pixel보다 작게 투영된다.

```text
Screen Pixel
┌────────┐
│△△△△△△│
│△△△△△△│
└────────┘
```

Triangle마다 Vertex Processing과 Primitive Setup이 필요하지만 최종 화면에서는 Detail를 분리해 표시할 Pixel이 없다.

작은 Triangle가 많으면 Rasterizer와 GPU Front-end 처리 효율도 낮아질 수 있다.

Geometry LOD는 Pixel 크기와 맞지 않는 Subpixel Triangle를 줄인다.

---

## Vertex Shader 비용

LOD0 Mesh가 많은 Vertex를 가지면 각 Vertex에서 Transform과 Material 관련 계산을 수행한다.

```text
Vertex Shader
├─ Object to World
├─ World to Clip
├─ Normal·Tangent 변환
├─ Skinning
├─ Wind Animation
└─ Vertex Displacement
```

Far Object의 Screen Coverage가 작아도 Vertex 수는 자동으로 줄지 않는다.

```text
LOD0 100,000 Vertices
→ Near에서도 100,000
→ Far에서도 Draw되면 100,000
```

LOD Mesh를 사용해야 Vertex 처리량을 직접 줄일 수 있다.

---

## Triangle Setup 비용

Vertex 이후 GPU는 Index를 읽고 Triangle를 구성해 Clipping과 Rasterization을 준비한다.

```text
Indices
→ Primitive Assembly
→ Face Culling
→ Clipping
→ Rasterization Setup
```

Backface와 Frustum 밖 Triangle가 나중에 제거되더라도 Draw된 Mesh의 Vertex·Primitive 작업 일부는 남는다.

LOD는 처음부터 제출하는 Geometry 수를 낮춰 Pipeline 앞쪽 작업을 줄인다.

---

## Fragment 비용도 달라질 수 있다

Geometry Triangle 수만 줄여도 Object가 덮는 Pixel 면적은 같을 수 있다.

```text
LOD0 Sphere → 화면 100 × 100 Pixels
LOD1 Sphere → 화면 100 × 100 Pixels
```

Silhouette가 비슷하면 Fragment 수는 크게 변하지 않을 수 있다.

따라서 Fragment Bound Scene에서는 Mesh LOD만으로 효과가 작을 수 있다.

Far LOD Material의 Texture Sample, Lighting, Transparency와 Shadow Feature도 함께 줄여야 한다.

---

## Geometry LOD

Geometry LOD는 Object 형태를 유지하면서 Vertex·Triangle를 줄인 Mesh로 교체한다.

```text
LOD0: 80,000 Triangles
LOD1: 20,000 Triangles
LOD2:  4,000 Triangles
LOD3:    500 Triangles
```

단순 비율보다 Silhouette, Animation Joint와 UV Seam을 보존하는 것이 중요하다.

Camera에서 보이는 크기에서 차이가 구분되지 않을 정도로 단계별 Mesh를 설계한다.

---

## Material LOD

멀리 있는 Object는 작은 Surface Detail과 복잡한 Lighting 차이가 잘 보이지 않는다.

```text
Near Material
├─ Base Map
├─ Normal Map
├─ Mask Map
├─ Detail Map
├─ Clear Coat
└─ Multiple Lights

Far Material
├─ Base Color
├─ Packed Mask
└─ Simple Lighting
```

낮은 LOD에서 Detail Normal, Parallax, Clear Coat, Refraction과 고품질 Noise를 제거할 수 있다.

Material가 달라지면 Batch와 Shader Variant가 늘 수 있으므로 Saved Fragment Cost와 State Change를 함께 측정한다.

---

## Shader LOD

Shader Level of Detail는 Hardware·Quality에 따라 SubShader나 Shader 기능을 선택하는 개념으로도 사용된다.

Object 거리 기반 LOD와 이름은 같지만 선택 기준이 다를 수 있다.

```text
Object LOD
→ Screen Size에 따라 Renderer 교체

Shader Quality LOD
→ Quality·Platform에 따라 Shader 복잡도 선택
```

Far Renderer에 별도 단순 Material를 배치하면 두 전략을 연결할 수 있다.

---

## Texture LOD와 Mipmap

Texture에도 거리에 따른 Detail Level인 Mipmap이 있다.

```text
Mip 0: 1024 × 1024
Mip 1:  512 × 512
Mip 2:  256 × 256
Mip 3:  128 × 128
```

Far Surface는 낮은 Mip을 Sample해 Texture Cache와 Alias 문제를 줄인다.

Mesh LOD와 Mipmap은 서로 다른 Data를 단계화한다.

```text
Mesh LOD
→ Geometry Detail

Mipmap
→ Texture Detail
```

둘을 함께 사용해야 Geometry와 Texture 모두 Screen Resolution에 맞출 수 있다.

---

## Shadow LOD

Far Object는 Main Camera에서 작게 보여도 Shadow Map에는 높은 Detail Mesh가 Rendering될 수 있다.

```text
Camera Color
→ LOD2

Shadow Caster
→ LOD0가 남으면 Geometry 절감 제한
```

Unity LOD Renderer가 Shadow Pass에도 선택되도록 구성하고 Shadow Casting Mode와 Distance를 확인한다.

낮은 LOD에서 Shadow를 끄거나 Simple Shadow Proxy를 사용할 수 있다.

Shadow Silhouette 변화가 눈에 띄지 않는 거리에서 단계화한다.

---

## Animation LOD

Far Character는 Bone 변형 Detail를 구분하기 어렵다.

```text
Near
├─ Full Skeleton
├─ IK
├─ Facial Animation
└─ Every-frame Update

Far
├─ Reduced Bones
├─ No Facial
├─ Lower Update Rate
└─ Impostor 가능
```

Mesh LOD만 줄이고 Animator와 Skinning을 그대로 유지하면 CPU Animation과 Bone Matrix 비용이 남는다.

Gameplay에 필요한 Root Motion과 Hit Detection은 Rendering Detail와 별도로 유지한다.

---

## Skinning LOD

Skinned Mesh Vertex는 여러 Bone Weight를 이용해 Position·Normal을 변환한다.

```text
Skinned Vertex Cost
≈ Vertex 수 × Bone Influence 수
```

Far LOD Mesh의 Vertex 수와 Bone Influence를 줄이면 GPU Skinning 또는 CPU Skinning 비용을 낮출 수 있다.

Bone를 제거하면 Weight 재매핑과 Animation Silhouette를 검증해야 한다.

LOD 전환에서 Pose가 튀지 않도록 Bind Pose와 Skeleton 구조를 맞춘다.

---

## Particle LOD

멀리 있는 Effect는 Particle 개수와 크기, Shader 기능을 낮출 수 있다.

```text
Near Explosion
├─ Smoke 100
├─ Sparks 300
├─ Distortion
└─ Light

Far Explosion
├─ Smoke 20
├─ Sparks 30
├─ No Distortion
└─ No Light
```

화면에서 작은 Effect에 Full-resolution Distortion과 Soft Particle를 유지할 필요가 없을 수 있다.

Gameplay 정보가 있는 Projectile와 장식 Particle를 구분한다.

---

## Light LOD

Far Object와 Effect에 붙은 Additional Light는 Screen 기여가 작아도 Light Culling과 Lighting List에 포함될 수 있다.

```text
Near Effect
→ Realtime Point Light

Far Effect
→ Emission Color만 사용
```

Light Range, Shadow, Cookie와 Update를 거리·Quality에 따라 줄인다.

실제 Light를 끄면 주변 Scene Lighting이 변할 수 있으므로 Material Emission 근사와 비교한다.

---

## Reflection LOD

Near Object는 Reflection Probe, Planar Reflection와 높은 품질 Specular가 중요할 수 있다.

Far Object는 단순 Cubemap과 낮은 Sample 수로 충분할 수 있다.

```text
Near Water
→ Planar Reflection

Far Water
→ Baked Cubemap·Simple Specular
```

Object LOD와 Renderer Feature를 연결하면 별도 Camera·Render Texture 비용도 줄일 수 있다.

Feature가 Object마다 개별로 끌 수 있는지 Pipeline 구조를 확인한다.

---

## Physics LOD와는 구분한다

Render Mesh가 단순해져도 Collider와 Rigidbody는 자동으로 바뀌지 않는다.

```text
Rendering LOD
→ GPU Geometry·Material

Physics LOD
→ Collider·Simulation Frequency
```

Far Object가 Gameplay Physics에 필요하지 않다면 Simple Collider, Sleeping과 Simulation Culling을 별도로 적용할 수 있다.

보이는 Detail와 충돌 정확도는 요구가 다르다.

---

## Audio LOD와는 구분한다

Object가 작게 보이거나 Cull되어도 Audio가 들릴 수 있다.

```text
Visual LOD3
→ Low Mesh

Audio
→ Distance Attenuation으로 유지
```

GameObject 전체를 비활성화해 Rendering LOD를 구현하면 Audio와 Gameplay도 중단될 수 있다.

Component별 Detail 정책을 분리한다.

---

## LOD0에 모든 품질을 집중한다

LOD Budget은 모든 단계에 같은 비율로 Triangle를 나누는 것이 아니다.

```text
LOD0
→ Hero Silhouette·Close-up 품질

LOD1
→ Mid-range 형태 유지

LOD2
→ Far Silhouette 중심

LOD3
→ Color·Shape 덩어리
```

Player가 가까이서 보는 시간과 Camera Cut을 고려해 LOD0 Detail를 배치한다.

절대 가까이 가지 않는 Background Object에 Hero Asset LOD0를 유지할 필요가 없다.

---

## Silhouette가 가장 중요하다

Far Object에서는 Surface의 작은 홈보다 외곽 형태 변화가 더 잘 보인다.

```text
보존 우선순위
1. Silhouette
2. 큰 Color Block
3. Major Normal 변화
4. 작은 Surface Detail
```

Mesh Simplification에서 외곽 Edge를 과도하게 줄이면 LOD 전환이 눈에 띈다.

내부 Edge Loop와 화면에서 구분되지 않는 Small Feature부터 제거한다.

---

## Normal Map으로 Geometry를 대체한다

작은 홈과 Bolt는 가까운 LOD에서 Geometry일 수 있지만 Far LOD에서는 Normal Map으로 근사할 수 있다.

```text
LOD0
→ 실제 Geometry Detail

LOD1·2
→ Baked Normal Detail
```

Vertex는 줄지만 Fragment Texture Sample이 남는다.

더 먼 LOD에서는 Normal Map 자체도 제거할 수 있다.

Vertex Bound와 Fragment Bound 중 현재 병목에 맞춰 단계화한다.

---

## Bake된 Far Material

복잡한 Material Layer와 Lighting Detail를 Far Texture에 Bake할 수 있다.

```text
Near
→ Multi-layer Material

Far
→ Baked Base Color·Normal·AO
```

Shader 연산과 Texture Sample를 줄일 수 있지만 Lighting 변화와 Weather·Damage 표현의 유연성이 감소한다.

Static Background Asset에 적합하며 Dynamic Hero Object에는 주의가 필요하다.

---

## Impostor

매우 먼 복잡한 Object를 여러 Angle에서 Capture한 Image나 간단한 Card로 대체할 수 있다.

```text
Tree Cluster Mesh
→ Far Distance
→ Impostor Quad
```

수많은 Triangle를 몇 개의 Quad로 줄일 수 있다.

Camera Angle, Parallax, Lighting과 Shadow 변화가 제한되고 Texture Memory가 필요하다.

`12-5`에서 Impostor와 Billboard를 별도로 다룬다.

---

## HLOD

Hierarchical LOD는 여러 Object를 먼 거리에서 하나의 Cluster로 합친다.

```text
Near
├─ Building A
├─ Building B
├─ Props
└─ Trees

Far
└─ District HLOD Mesh
```

Triangle뿐 아니라 Renderer와 Draw Call 수를 줄일 수 있다.

Cluster Bounds가 커져 Culling Granularity가 낮아지고 Bake된 Texture Memory와 Streaming 관리가 필요하다.

Open World에서 LOD와 Streaming을 연결하는 기법이다.

---

## 마지막 LOD의 Cull

Object가 화면에서 몇 Pixel 이하가 되면 낮은 Mesh조차 표시 가치가 없을 수 있다.

```text
LOD0 → LOD1 → LOD2 → Cull
```

Cull은 Draw, Vertex와 Fragment를 모두 제거할 수 있다.

작은 Prop, Grass와 Debris에 효과적이다.

Landmark, Enemy Silhouette와 Gameplay Indicator는 먼 거리에도 보여야 하므로 Object 종류별 Threshold를 사용한다.

---

## Distance Culling과 차이

Distance Culling은 Camera와 Object 거리만으로 제거할 수 있다.

LOD는 Screen Relative Size와 단계별 Renderer를 사용한다.

```text
Distance Culling
→ 100m 이후 제거

LOD
→ 화면 크기에 따라 Detail 전환
```

큰 Building와 작은 Pebble에 같은 Distance Threshold를 적용하면 품질·비용이 맞지 않는다.

Layer Cull Distance는 비슷한 크기와 역할의 Object Group에서 유용하다.

---

## Frustum Culling과 차이

Frustum Culling은 Camera Volume 밖 Object를 제거한다.

LOD는 Frustum 안에서 보이는 Object의 Detail를 줄인다.

```text
Frustum 밖
→ Draw 없음

Frustum 안 Near
→ LOD0

Frustum 안 Far
→ LOD2
```

Frustum Culling이 정상이어도 Camera 앞 먼 Object는 High Detail로 남을 수 있으므로 LOD가 필요하다.

---

## Occlusion Culling과 차이

Occlusion Culling은 다른 Geometry에 완전히 가려진 Object를 제거한다.

LOD는 가려지지 않고 실제로 보이지만 작게 보이는 Object를 단순화한다.

```text
Hidden Object
→ Occlusion Cull

Visible Far Object
→ Low LOD
```

두 기법은 서로 다른 Visible Set 문제를 해결한다.

---

## LOD 전환이 보이는 문제

LOD Mesh가 순간적으로 바뀌면 Shape, Shading와 Shadow가 튀는 Pop이 생길 수 있다.

```text
Frame N
LOD0

Frame N+1
LOD1
→ Silhouette Jump
```

Transition Distance를 화면에서 차이가 작아진 지점에 배치하고 LOD Mesh의 형태·Normal·Pivot을 일치시킨다.

Cross-fade와 Dither Fade로 전환을 완화할 수 있다.

---

## Cross-fade의 비용

Cross-fade는 전환 구간에서 이전과 다음 LOD를 동시에 Rendering할 수 있다.

```text
Transition
LOD0 Alpha·Dither 감소
+ LOD1 Alpha·Dither 증가
```

Object Pop은 줄지만 Draw, Vertex와 Fragment가 일시적으로 두 배 가까이 증가할 수 있다.

Dither Clip은 Fragment Shader와 Temporal AA에 영향을 줄 수 있다.

Fade 구간을 너무 길게 만들지 않고 전환 빈도와 Peak 비용을 측정한다.

---

## SpeedTree Fade와 특수 전환

Vegetation System은 Geometry 형태를 점진적으로 보간하거나 Billboard로 전환하는 전용 Fade를 사용할 수 있다.

```text
Tree Mesh
→ Simplified Mesh
→ Billboard
```

Branch와 Leaf가 수축·이동하는 Morph Artifact가 생길 수 있다.

Wind Animation, Shadow와 Billboard Orientation이 전환 구간에서 일치하는지 확인한다.

---

## LOD Hysteresis

Camera가 Threshold 근처에서 흔들리면 LOD가 Frame마다 바뀔 수 있다.

```text
Frame N   LOD0
Frame N+1 LOD1
Frame N+2 LOD0
```

이를 LOD Thrashing이라고 볼 수 있다.

Threshold 간격, Fade와 Hysteresis를 이용해 상태를 안정화할 수 있다.

Unity LOD Group이 제공하는 전환 방식과 Custom System의 정책을 구분한다.

---

## Camera FOV가 LOD에 미치는 영향

같은 Object와 거리에서도 FOV가 좁아지면 화면에 크게 보인다.

```text
Wide FOV
→ Object 작게 투영

Telephoto FOV
→ Object 크게 투영
```

Sniper Scope와 Zoom Camera에서 거리 기반 LOD만 사용하면 Low Mesh가 확대되어 보일 수 있다.

Screen Relative Size 기반 LOD는 Projection 변화를 반영할 수 있다.

---

## 해상도와 LOD

Screen Relative Height가 같은 경우 Output Resolution이 높아지면 Object를 구성하는 실제 Pixel 수가 늘어난다.

```text
Relative Height 10%

1080p → 약 108 Pixels 높이
2160p → 약 216 Pixels 높이
```

같은 LOD Threshold가 4K에서 Detail 부족을 더 드러낼 수 있다.

Unity의 LOD 기준과 Quality `lodBias`, Target Resolution을 함께 검토한다.

---

## LOD Bias

Quality Setting의 LOD Bias는 Object가 각 LOD로 전환되는 기준에 영향을 준다.

```text
높은 LOD Bias
→ High Detail를 더 오래 유지 가능

낮은 LOD Bias
→ Low Detail로 더 일찍 전환 가능
```

정확한 방향과 계산은 Unity Version의 Quality Setting 문서를 기준으로 확인한다.

Device Quality Level별로 Triangle·Shader Budget과 화질을 조절할 수 있다.

Bias를 극단적으로 바꾸면 모든 Asset의 전환 품질이 한꺼번에 달라진다.

---

## Maximum LOD Level

Quality Setting은 사용할 수 있는 최소 Detail Level 범위를 제한하는 Maximum LOD Level 계열 설정을 제공할 수 있다.

```text
Low Quality
→ LOD0 Skip
→ LOD1부터 사용 가능
```

저사양 Device에서 가까운 Object도 가장 무거운 Mesh를 사용하지 않도록 제한할 수 있다.

Hero Character와 Gameplay Object까지 일괄 저하될 수 있으므로 Asset별 중요도를 고려한다.

Unity Version과 Pipeline의 설정 이름을 확인한다.

---

## 여러 Camera의 LOD

Main Camera, Reflection, Mini Map와 Shadow Camera는 서로 다른 Projection과 Screen Size를 가진다.

```text
Main Camera
→ LOD0

Reflection Camera
→ LOD1 가능

Mini Map
→ LOD2·Proxy 가능
```

어떤 Camera가 LOD를 결정하고 Pass가 어떤 Renderer를 사용하는지는 Unity Rendering 경로에 따라 확인해야 한다.

Secondary Camera에서 Main Camera와 같은 High LOD를 무조건 Rendering하지 않도록 Culling Mask·Quality와 Renderer 정책을 검토한다.

---

## XR과 LOD

XR은 두 Eye의 Projection과 높은 Eye Texture Resolution을 사용한다.

한 Eye에서 LOD Threshold를 넘고 다른 Eye에서 넘지 않는 경계가 있을 수 있다.

```text
Left Eye Screen Size
Right Eye Screen Size
```

두 Eye가 서로 다른 Mesh를 보이면 Stereo 불일치가 생길 수 있어 Conservative한 공통 LOD를 사용할 수 있다.

Headset의 Render Scale, FOV와 가까운 Object 품질을 실제 장치에서 확인한다.

---

## Mobile과 LOD

Mobile GPU는 Vertex Throughput, Memory Bandwidth와 전력 Budget이 제한적이다.

```text
LOD 절감
├─ Vertices
├─ Triangles
├─ Texture Samples
├─ Shadows
└─ Thermal Load
```

고해상도 Mobile 화면에서는 Far Object의 실제 Pixel 수가 예상보다 많을 수 있다.

저사양 Device에서 LOD Bias를 낮추기 전에 Transition Pop과 Silhouette를 실제 Physical Screen에서 평가한다.

---

## Memory 비용

여러 LOD Mesh와 Material를 저장하면 Asset Memory와 Build Size가 증가한다.

```text
Base Asset
+ LOD1 Mesh
+ LOD2 Mesh
+ LOD3 Mesh
+ Impostor Texture
```

LOD Geometry가 원본의 50%·25%·10%라면 전체 Mesh Memory가 원본 하나보다 커진다.

사용하지 않는 LOD가 동시에 Memory에 Load되는지 Asset Bundle·Addressables 구조를 확인한다.

Streaming으로 필요한 단계만 Load할 수 있는지도 검토한다.

---

## CPU 비용

LOD Group은 Camera에 대한 Relative Size를 계산하고 활성 Renderer Set를 선택해야 한다.

```text
Camera
→ Bounds Screen Size
→ Threshold 비교
→ LOD 선택
```

LOD Group 수가 매우 많고 Camera가 여러 개면 판정 비용이 누적될 수 있다.

그러나 Draw와 Vertex를 크게 줄이면 순이익이 더 클 수 있다.

Culling 글과 마찬가지로 `LOD 판정 비용 < 절감한 Rendering 비용`인지 측정한다.

---

## Renderer와 Draw Call 변화

낮은 LOD가 Triangle만 줄이고 Renderer·Material 수를 그대로 유지하면 CPU Draw 절감은 작다.

```text
LOD0
├─ Body Renderer
├─ Accessories
├─ Decals
└─ Hair

LOD2
└─ Combined Renderer
```

Far LOD에서 Submesh와 Material를 합치면 Triangle뿐 아니라 Draw Call도 줄일 수 있다.

Texture Atlas와 Baked Material가 필요할 수 있으며 Memory·Batch Trade-off가 생긴다.

---

## LOD와 Batching

LOD마다 다른 Material와 Shader Keyword를 사용하면 Batch가 분리될 수 있다.

```text
Object A LOD1 Material M1
Object B LOD2 Material M2
→ 별도 Batch 가능
```

같은 Distance Band의 반복 Object는 LOD별 공유 Material와 Mesh를 사용해 GPU Instancing을 유지한다.

Transition Fade Keyword와 Per-object Fade Data가 Batching에 미치는 영향도 확인한다.

---

## LOD와 Culling Granularity

HLOD로 여러 Object를 합치면 Far Draw는 줄지만 Cluster Bounds가 커진다.

```text
Individual Objects
→ Fine Frustum·Occlusion Culling

HLOD Cluster
→ Coarse Bounds
```

Cluster 일부만 보일 때 전체 Far Mesh가 Rendering될 수 있다.

World Cell, Street Block와 Terrain Tile처럼 함께 보이는 공간 단위로 HLOD를 만든다.

---

## LOD 생성 방법

LOD Mesh는 DCC Tool, Mesh Simplification Tool 또는 Runtime·Build Pipeline에서 생성할 수 있다.

```text
Manual Authoring
→ 높은 품질 제어
→ 제작 시간 증가

Automatic Simplification
→ 대량 Asset 처리
→ Artifact 검수 필요
```

Hero Character는 Manual LOD, Background Prop는 자동 생성처럼 Asset 중요도별 Workflow를 나눌 수 있다.

자동 비율만 믿지 않고 실제 Camera Distance에서 검수한다.

---

## 자동 Simplification의 오류

Triangle 수를 목표 비율로 줄이는 Algorithm은 시각적 의미를 완전히 알지 못한다.

```text
주의 영역
├─ Silhouette
├─ UV Seam
├─ Hard Normal Edge
├─ Thin Part
├─ Animation Joint
├─ Material Boundary
└─ Vertex Color Data
```

얇은 Antenna와 Finger가 사라지거나 UV가 찌그러질 수 있다.

Screen Size별 Screenshot와 Animation Pose에서 검수한다.

---

## Triangle 감소율을 균등하게 하지 않는다

LOD0에서 LOD1로 50%, LOD1에서 LOD2로 다시 50%라는 고정 규칙이 모든 Asset에 맞는 것은 아니다.

```text
Mechanical Prop
→ Hard Silhouette 때문에 완만한 감소

Rock
→ 불규칙 형태라 큰 감소 가능

Character Face
→ Close-up Detail 유지
```

Object의 Screen Size와 시각 민감도에 따라 단계별 목표를 정한다.

실제 Vertex·Triangle와 GPU ms를 측정한다.

---

## LOD가 없는 Asset의 누적

Object 하나의 LOD0가 가볍더라도 Scene에 수천 개 반복되면 비용이 커진다.

```text
Tree LOD0 20,000 Triangles
× 5,000 Trees
= 100M Triangle 후보
```

Frustum과 Occlusion이 일부를 제거해도 Camera 앞의 Forest는 많은 Tree가 보인다.

낮은 Mesh, Impostor와 HLOD를 조합해야 대규모 Scene Budget을 유지할 수 있다.

---

## 가까운 Object도 LOD가 필요할 수 있다

Object가 매우 크면 일부만 Camera 가까이에 있고 나머지는 멀 수 있다.

하나의 거대한 Mesh LOD는 전체를 하나의 Detail 단계로 처리한다.

```text
Large Terrain·Building
→ Spatial Chunk 분할
→ Chunk별 LOD
```

Terrain, Road와 City Block은 공간 Patch별로 LOD를 선택해야 Detail와 Culling 정밀도를 유지할 수 있다.

경계 Crack과 Stitching 처리가 필요하다.

---

## Terrain LOD

Terrain은 Camera 주변 Patch를 높은 Tessellation으로, 먼 Patch를 낮은 Detail로 Rendering한다.

```text
Camera Near Patch  → Dense Grid
Far Patch          → Sparse Grid
```

Neighbor Patch의 LOD가 다르면 Edge Crack이 생길 수 있다.

Skirt, Edge Stitch와 제한된 LOD 차이로 경계를 연결한다.

Tree·Detail Distance와 Terrain Heightmap Pixel Error도 함께 조정한다.

---

## LOD와 Visual Priority

같은 Screen Size라도 Object 중요도가 다르다.

```text
Player Character
→ 높은 품질 유지

Background Crate
→ 빠른 LOD 전환

Enemy Silhouette
→ Gameplay Readability 유지
```

거리와 Screen Size만으로 자동 결정하지 않고 Gameplay Importance에 Weight를 줄 수 있다.

Target Lock, Cutscene와 Photo Mode에서는 일시적으로 LOD Quality를 높일 수 있다.

---

## LOD와 Art Direction

현실적인 Detail 감소보다 스타일의 형태를 유지하는 것이 중요할 수 있다.

```text
Stylized Asset
├─ 큰 Shape
├─ 과장된 Edge
├─ Flat Color Block
└─ 의도된 Facet
```

자동 Simplification이 의도한 Low-poly Facet와 Color Boundary를 무너뜨릴 수 있다.

Art Team과 전환 거리, Silhouette와 Material 단순화 규칙을 공유한다.

---

## LOD 전환 검증

Camera를 Threshold를 가로질러 천천히 이동한다.

```text
검사
├─ Silhouette Pop
├─ Pivot Shift
├─ Scale 변화
├─ Normal·Specular Pop
├─ UV·Color 변화
├─ Shadow Pop
├─ Animation Pose 변화
└─ Collision 불일치
```

정지 Screenshot뿐 아니라 빠른 이동, Zoom과 Camera Cut에서 확인한다.

다음 글에서 Unity LOD Group의 Threshold와 Fade 동작을 더 구체적으로 다룬다.

---

## Frame Debugger에서 확인한다

Frame Debugger에서 거리별로 어떤 Renderer와 Material가 Draw되는지 확인한다.

```text
Near Frame
→ LOD0 Mesh·Material

Mid Frame
→ LOD1 Mesh·Material

Far Frame
→ LOD2 또는 Draw 없음
```

Transition 구간에서 두 LOD가 동시에 Draw되는지, Shadow Pass가 다른 LOD를 사용하는지 확인한다.

LOD Renderer가 중복 등록되어 항상 여러 단계가 Draw되는 설정 오류도 찾는다.

---

## Rendering Profiler에서 확인한다

LOD Off와 On 상태의 Batches, Triangle·Vertex와 SetPass를 비교한다.

```text
LOD Off
Triangles 12M
Vertices   8M

LOD On
Triangles  4M
Vertices   3M
```

낮은 LOD Material가 Draw Call를 추가하면 Batches가 줄지 않을 수 있다.

Triangle 통계와 CPU·GPU Frame Time을 함께 본다.

---

## GPU Profiler에서 확인한다

Geometry LOD는 Vertex·Primitive Bound Pass에서 큰 효과를 낼 수 있다.

```text
GPU 비교
├─ Opaque Pass
├─ Shadow Pass
├─ Depth Prepass
└─ Transparent·Foliage Pass
```

Fragment Bound이면 Triangle 수가 크게 줄어도 GPU ms 변화가 작을 수 있다.

Far Material·Shadow·Overdraw까지 단순화한 Variant와 비교한다.

---

## LOD A/B Test

동일 Camera Frame에서 모든 Object를 LOD0로 강제한 결과와 자동 LOD를 비교한다.

```text
Test A
Force LOD0

Test B
Automatic LOD

Test C
More Aggressive Bias
```

CPU LOD 판정, Draw Call, Vertex·Triangle, GPU Pass ms, Memory와 품질을 기록한다.

Camera Path의 Near·Mid·Far 조합이 실제 Gameplay와 같아야 한다.

---

## 측정 표

| Variant | Batches | Triangles | CPU ms | GPU ms | 품질 |
|---|---:|---:|---:|---:|---|
| LOD0 고정 | 1400 | 14M | 9.0 | 18.0 | 최고 |
| 자동 LOD | 1100 | 5M | 7.8 | 12.0 | 허용 |
| 공격적 LOD | 900 | 2M | 7.0 | 10.0 | Pop 보임 |

숫자는 기록 양식의 예시다.

성능이 가장 높은 Variant가 아니라 품질 기준을 만족하면서 Frame Budget에 들어오는 Variant를 선택한다.

---

## LOD 최적화 순서

```text
1. Asset별 최대 Screen Size와 중요도 분류
2. LOD0의 불필요한 Geometry 제거
3. Silhouette 중심 LOD1·LOD2 제작
4. Far Material·Shadow·Effect 단순화
5. 가장 작은 Prop에 Cull 단계 추가
6. 반복 Asset의 Material·Instancing 유지
7. Transition Pop과 Cross-fade 비용 확인
8. LOD Bias를 Quality Level별 조정
9. Frame Debugger·Profiler로 전후 비교
10. Target Camera Path에서 품질·성능 검증
```

Triangle 비율만 채우지 않고 해당 LOD가 실제로 사용되는 Screen Size에서 결과를 판단한다.

---

## 흔한 오해

### LOD는 멀리 있는 Object를 숨기는 기능이다

완전 Cull도 가능하지만 주된 목적은 Screen Size에 맞는 Detail 단계로 Renderer를 교체하는 것이다.

### 거리가 같으면 같은 LOD를 사용해야 한다

Object World Size와 Camera Projection이 다르면 같은 거리에서도 Screen Size가 다르다.

### Triangle 수만 줄이면 LOD 최적화가 끝난다

Fragment Shader, Material 수, Shadow, Animation과 Effect 비용이 그대로 남을 수 있다.

### 낮은 LOD는 원본 Mesh를 일정 비율로 줄이면 된다

Silhouette, Thin Part, UV Seam과 Animation Joint를 Screen Size에 맞춰 보존해야 한다.

### LOD 전환은 멀리서 일어나므로 보이지 않는다

Threshold, FOV, Resolution과 Mesh 차이가 맞지 않으면 뚜렷한 Pop이 나타난다.

### Cross-fade는 비용이 없다

전환 구간에서 두 LOD를 동시에 Draw하고 Dither Fragment를 처리할 수 있다.

### LOD가 있으면 Culling은 필요 없다

Frustum·Occlusion은 보이지 않는 Object를 제거하고 LOD는 보이는 Object Detail를 줄인다.

### Mipmap이 Mesh LOD를 대체한다

Mipmap은 Texture Detail를 줄이며 Geometry Vertex·Triangle는 그대로다.

### LOD는 GPU만 최적화한다

Far LOD에서 Renderer·Material 수를 합치면 CPU Draw도 줄일 수 있고 Animation LOD는 CPU를 줄일 수 있다.

### LOD Mesh가 많을수록 항상 좋다

판정, Transition, Asset Memory와 제작 비용이 증가하므로 구분 가능한 단계만 만든다.

### 가장 낮은 LOD를 항상 Cull해야 한다

Landmark와 Gameplay Silhouette는 먼 거리에도 필요할 수 있다.

---

## 최종 체크리스트

```text
□ 거리보다 Projected Screen Size를 기준으로 생각했는가?
□ Perspective·Orthographic Camera 차이를 고려했는가?
□ Far Mesh에 Subpixel Triangle가 과도하지 않은가?
□ LOD별 Vertex·Triangle 수를 기록했는가?
□ Silhouette와 Thin Part를 우선 보존했는가?
□ Vertex Normal·UV·Material Boundary가 안정적인가?
□ Far Material의 Texture Sample·Lighting을 줄였는가?
□ Mipmap과 Mesh LOD를 함께 구성했는가?
□ Shadow Caster도 적절한 LOD를 사용하는가?
□ Far Character의 Bone·Animation Update를 줄일 수 있는가?
□ Particle·Light·Reflection Detail도 단계화했는가?
□ 작은 Prop에 마지막 Cull 단계가 필요한가?
□ Impostor·HLOD가 반복·Cluster Object에 적합한가?
□ LOD 전환에서 Silhouette·Normal·Shadow Pop이 없는가?
□ Cross-fade 구간의 이중 Draw 비용을 확인했는가?
□ FOV·Zoom·Resolution 변화에서 Threshold가 적절한가?
□ Quality LOD Bias가 Asset 전체에 과도하지 않은가?
□ 여러 LOD Asset의 Memory·Build Size를 확인했는가?
□ Far LOD에서 Renderer·Material 수를 합칠 수 있는가?
□ Instancing과 Batching이 LOD별로 유지되는가?
□ 자동 Simplification 결과를 Animation에서 검수했는가?
□ Frame Debugger에서 실제 LOD Renderer를 확인했는가?
□ Triangle 감소가 CPU·GPU ms 개선으로 이어졌는가?
□ Mobile·XR Target Camera에서 화질을 검증했는가?
```

---

## 정리

LOD는 Object가 화면에서 차지하는 크기에 맞춰 Geometry와 Rendering 품질을 단계적으로 낮춰 구분할 수 없는 Detail 비용을 줄이는 기법이다.

Perspective Camera에서는 거리가 멀어질수록 투영 면적이 작아지지만 Object World Size, FOV와 Orthographic Projection 때문에 거리보다 Screen Relative Size가 더 적절한 기준이다.

고밀도 Far Mesh는 Pixel보다 작은 Triangle를 만들고 Vertex Shader·Primitive Setup 비용을 유지하므로 단순 Mesh로 교체해야 Geometry 처리량을 직접 줄일 수 있다.

Mesh LOD만으로 Fragment 수가 크게 변하지 않을 수 있어 Far Material의 Texture Sample·Lighting, Shadow, Animation, Particle와 Light Detail도 함께 단계화해야 한다.

LOD 전환은 Silhouette·Normal·Shadow Pop을 만들 수 있고 Cross-fade는 전환 구간의 이중 Draw와 Fragment 비용을 추가한다.

LOD Mesh, Material와 Impostor는 Memory·Build Size를 늘리며 HLOD는 Draw를 줄이는 대신 Bounds와 Culling Granularity를 키우는 Trade-off가 있다.

Frame Debugger와 Rendering·GPU Profiler로 실제 Renderer, Triangle·Draw와 Pass 시간을 비교하고 Target Camera Path에서 품질 기준을 만족하는 LOD 단계와 Threshold를 결정해야 한다.
