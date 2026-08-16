---
title: "[Unity 렌더링] 12-5. Impostor와 Billboard는 무엇일까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - LOD
  - Impostor
  - Billboard
permalink: /programming/unity-12-5-what-are-impostors-and-billboards/
toc: true
toc_sticky: true
date: 2026-08-17
last_modified_at: 2026-08-17
---

Billboard는 Camera를 향하도록 회전하는 평면이고 Impostor는 복잡한 3D Object의 외형을 미리 캡처한 Image로 대신 그리는 원거리 LOD 기법이다.

```text
Near
High-poly Tree Mesh
        │
        ▼
Mid
Low-poly Tree Mesh
        │
        ▼
Far
Tree Impostor Quad
```

수만 개 Triangle와 여러 Material를 몇 개 Triangle와 Texture Sample로 바꿔 Geometry·Draw 비용을 크게 줄일 수 있다.

대신 Camera 각도 변화, Parallax, Lighting, Shadow와 Texture Memory에 한계가 생긴다.

---

## Billboard의 기본 형태

가장 단순한 Billboard는 두 Triangle로 만든 Quad다.

```text
v0 ───────── v1
│          ／ │
│        ／   │
│      ／     │
v2 ───────── v3
```

Quad에 Tree, Smoke, Icon와 먼 Building Image를 표시한다.

Camera가 이동해도 정면을 보이도록 Object Transform이나 Vertex Position을 회전한다.

```text
Billboard Forward
≈ Camera 방향의 반대
```

---

## 왜 Camera를 향하게 할까?

고정된 Plane은 Camera가 옆으로 이동하면 얇은 Edge만 보인다.

```text
Front View  → ▉
Side View   → │
```

Billboard를 Camera 방향으로 회전하면 항상 넓은 Image Area가 보인다.

```text
Camera A → [Quad]

Camera B
   ↓
 [Quad가 회전]
```

얇은 Geometry로 Volume가 있는 Object처럼 보이게 만드는 핵심이다.

---

## Impostor의 의미

Impostor는 실제 복잡한 Geometry 대신 그 Object처럼 보이도록 만든 대체 표현이다.

```text
Original Object
├─ 100,000 Triangles
├─ 5 Materials
└─ Complex Shader

Impostor
├─ 2~몇 개 Triangles
├─ Captured Textures
└─ Impostor Shader
```

Billboard가 대체 Geometry의 방향 방식이라면 Impostor는 캡처된 외형과 Rendering 기법 전체를 뜻한다.

Impostor는 Billboard를 사용하지만 모든 Billboard가 복잡한 Object의 Impostor인 것은 아니다.

---

## Billboard와 Impostor의 차이

| 항목 | Billboard | Impostor |
|---|---|---|
| 핵심 | Camera-facing Plane | 복잡한 Object의 시각적 대체 표현 |
| Data | 단일 Sprite도 가능 | 여러 방향 Color·Normal·Depth Capture 가능 |
| 용도 | Particle, Icon, Grass, Label | Tree, Rock, Building, Crowd, HLOD |
| Geometry | 주로 Quad | Quad, Cross Plane, Proxy Mesh |
| 목표 | Plane를 항상 읽기 쉽게 표시 | 원본 Geometry 비용을 낮은 Image 비용으로 대체 |

둘은 자주 결합되므로 용어가 같은 의미처럼 사용되기도 한다.

구현을 설명할 때 Orientation 방식과 Capture Data를 구분한다.

---

## Screen-aligned Billboard

Screen-aligned Billboard는 Camera View Plane과 평행하게 배치한다.

```text
Billboard Right = Camera Right
Billboard Up    = Camera Up
```

Object 중심에서 Camera 방향을 바라보기보다 화면 축과 완전히 정렬한다.

UI Marker, Lens Flare와 Screen Space에 가까운 Effect에 적합하다.

Camera Roll에도 Billboard가 함께 회전할 수 있다.

---

## View-facing Billboard

View-facing Billboard는 각 Object에서 Camera Position을 향한다.

```text
look = normalize(cameraPosition - objectPosition)
```

Camera와 Object 위치에 따라 Billboard 방향이 조금씩 달라진다.

넓은 World에서 여러 Tree가 하나의 View Plane에 평행한 것보다 각각 Camera를 향하는 결과가 자연스러울 수 있다.

Up Vector 선택이 불안정하면 Camera가 바로 위에 있을 때 회전이 뒤집힐 수 있다.

---

## Spherical Billboard

Spherical Billboard는 Horizontal과 Vertical 방향 모두 Camera를 향하도록 자유롭게 회전한다.

```text
Yaw   → Camera 방향
Pitch → Camera 방향
```

Space Particle, Glow와 자유로운 Camera에서 유용하다.

Tree처럼 항상 수직이어야 하는 Object는 Camera 높이에 따라 기울어져 뿌리가 Ground에서 떨어지는 것처럼 보일 수 있다.

---

## Cylindrical Billboard

Cylindrical 또는 Axial Billboard는 World Up Axis를 유지하고 수평 방향만 Camera를 향한다.

```text
Up = World Up
Yaw만 회전
```

```text
Camera가 위로 이동해도
Tree Trunk는 수직 유지
```

Tree, Character와 Vertical Sign에 적합하다.

Camera가 Object 바로 위를 보면 평면 형태가 드러나는 한계가 있다.

---

## Billboard Basis 계산

Object Center에서 Camera로 향하는 Vector를 구한다.

```text
view = normalize(cameraPosition - center)
```

World Up을 고정한 Cylindrical 방식은 수직 성분을 제거한다.

```text
forward = normalize(float3(view.x, 0, view.z))
right   = normalize(cross(up, forward))
```

Quad Vertex는 Center에 Right·Up Offset을 더해 World Position을 만든다.

```text
positionWS
= center
+ right × corner.x × width
+ up    × corner.y × height
```

---

## CPU Rotation 방식

Transform Script에서 Billboard Object를 매 Frame Camera 방향으로 회전할 수 있다.

```csharp
transform.forward =
    transform.position - camera.transform.position;
```

정확한 방향 부호와 Up Axis는 Mesh의 Local Orientation에 맞춰야 한다.

Object 수가 적으면 간단하지만 Billboard 수만 개의 Transform를 매 Frame 수정하면 Main Thread와 Transform Hierarchy 비용이 커질 수 있다.

여러 Camera에서 한 Transform가 동시에 서로 다른 방향을 볼 수 없다는 한계도 있다.

---

## GPU Vertex 방식

Quad Transform는 유지하고 Vertex Shader에서 Camera Right·Up Vector로 Position을 구성할 수 있다.

```text
Instance Center·Size
+ Camera Basis
→ Billboard Vertex Position
```

CPU Transform 회전을 피하고 많은 Billboard를 Instancing하기 쉽다.

Camera별 Draw에서 올바른 Camera Matrix를 사용하므로 Reflection와 XR에도 대응할 수 있다.

Bounds는 CPU가 Shader 회전 결과를 모르므로 모든 Orientation을 포함하도록 설정해야 한다.

---

## Pivot

Billboard Pivot는 Quad가 Object Center에서 어느 위치를 기준으로 회전하는지 결정한다.

```text
Center Pivot
→ Quad 중앙 회전

Bottom Pivot
→ Tree·Character의 발이 Ground에 고정
```

Tree Impostor는 Trunk Base를 Pivot로 사용해야 Camera 회전에서 지면 위를 미끄러지는 느낌이 줄어든다.

Capture Object의 Pivot와 Billboard Mesh Pivot를 일치시킨다.

---

## Bounds

Billboard는 Camera에 따라 회전하므로 World AABB가 바뀔 수 있다.

```text
Front Orientation Bounds
≠ Side Orientation Bounds
```

Vertex Shader에서만 회전하면 CPU Renderer Bounds는 자동으로 모든 방향을 알지 못할 수 있다.

Quad의 대각선과 Height를 포함하는 Conservative Bounds를 설정한다.

Bounds가 작으면 화면에 보이는 Billboard가 잘못 Culled되고 너무 크면 Frustum·Occlusion 효율이 낮아진다.

---

## 단일 View Impostor

한 방향에서만 Object를 Capture한 가장 단순한 방식이다.

```text
Front Capture
→ One Texture
→ Camera-facing Quad
```

먼 Tree와 Mountain처럼 방향 변화가 눈에 잘 띄지 않는 Object에 적합하다.

Camera가 옆이나 위로 이동하면 모든 방향에서 같은 Front Image가 보여 회전하는 Card처럼 느껴질 수 있다.

Texture Memory와 Shader 비용은 가장 낮다.

---

## 여러 방향 Impostor

Object를 둘러싼 여러 각도에서 Image를 Capture한다.

```text
Top View Capture

       0°
 315°      45°
270° Object 90°
 225°     135°
      180°
```

Runtime Camera 방향과 가장 가까운 Frame을 선택한다.

방향 변화가 원본 형태에 더 가깝지만 Capture Frame 수에 비례해 Texture Memory와 Bake 시간이 늘어난다.

---

## View 선택

Object Local Space에서 Camera 방향을 구하고 Azimuth Angle을 계산한다.

```text
localViewDirection
→ atan2(x, z)
→ 0°~360°
→ Frame Index
```

8방향 Capture라면 각 Frame가 45도 구간을 담당할 수 있다.

```text
frame = round(angle / 45°) mod 8
```

Frame가 순간적으로 바뀌면 외형이 튀는 View Pop이 발생한다.

---

## View Frame Blending

인접한 두 Capture를 방향 비율로 Blend한다.

```text
Camera Angle 30°

Frame 0° × 0.33
+ Frame 45° × 0.67
```

View Pop은 줄지만 Texture Sample가 두 배 이상 필요할 수 있고 서로 다른 Silhouette가 겹쳐 Ghosting처럼 보일 수 있다.

Alpha, Depth와 Normal도 일관되게 Blend해야 한다.

먼 거리에서 실제 차이가 보이는지 A/B Test한다.

---

## Elevation Capture

수평 방향뿐 아니라 위아래 Elevation에서도 Frame를 Capture할 수 있다.

```text
Azimuth × Elevation Grid
```

비행 Camera, Strategy View와 Mountain에서 위쪽 형태를 표현할 수 있다.

```text
8 Azimuth × 4 Elevation
= 32 Frames
```

Capture 수와 Texture Memory가 빠르게 증가한다.

Camera 이동 범위를 제한할 수 있다면 필요한 Elevation만 저장한다.

---

## Spherical View Sampling

Latitude·Longitude Grid는 Pole 근처에 Sample가 몰리고 방향 간 면적이 균일하지 않다.

```text
Longitude Lines
→ Pole에서 수렴
```

Octahedral Mapping은 Sphere Direction을 2D 정사각형에 비교적 균일하게 매핑할 수 있다.

```text
3D View Direction
→ Octahedral Encode
→ 2D Atlas Coordinate
```

여러 방향 Impostor의 Frame 선택과 Blend를 효율적으로 구성하는 데 사용된다.

---

## Octahedral Impostor

Octahedral Impostor는 Object 주변 방향을 Octahedral Mapping으로 Capture·배치한다.

```text
Sphere Views
→ Octahedron
→ Unfold to 2D Grid
```

Camera Direction에 가까운 Sample 여러 개를 찾아 Blend할 수 있다.

Top·Bottom View를 포함하는 Full Sphere Object에 적합하다.

Shader Math, Multiple Samples와 Atlas Memory가 단일 Billboard보다 크다.

---

## Hemispherical Impostor

Ground 위 Tree와 Rock는 아래쪽에서 볼 일이 없으므로 Upper Hemisphere만 Capture할 수 있다.

```text
Camera 가능한 영역
→ Ground 위 Half Sphere
```

같은 Frame 수로 필요한 방향의 Angular Resolution을 높이거나 Texture Memory를 줄일 수 있다.

Camera가 지하나 Object 아래로 이동할 수 있는 Game에는 적합하지 않다.

Gameplay Camera Constraint를 Bake 가정과 일치시킨다.

---

## Capture Texture 종류

Impostor는 Color 하나만 저장할 수도 있고 Material Data를 여러 Texture에 저장할 수도 있다.

```text
Capture Data
├─ Base Color + Alpha
├─ Normal
├─ Depth
├─ Roughness·Metallic
├─ Emission
├─ Ambient Occlusion
└─ Shadow·Lighting Bake
```

Data가 많을수록 Dynamic Lighting에 대응할 수 있지만 Texture Memory, Sample와 Shader 비용이 증가한다.

Far Distance에서 필요한 Material 반응만 저장한다.

---

## Baked Lighting Impostor

최종 Lighting Color를 Texture에 Bake하면 Runtime Shader가 단순하다.

```text
Captured Final Color
→ Unlit Impostor
```

시간대, Light Direction와 Weather가 바뀌면 원본 3D Object와 Lighting가 어긋난다.

Static Background, 먼 City와 고정 Sky Lighting에 적합하다.

Dynamic Day·Night Cycle에서는 여러 Lighting Set나 Relightable Impostor를 검토한다.

---

## Relightable Impostor

Base Color, Normal와 Material Parameter를 저장해 Runtime Light를 계산한다.

```text
Sample Base Color
Sample Normal
Sample Material Data
→ Runtime Lighting
```

Scene Light 변화에 반응하지만 여러 Texture Sample와 Fragment Lighting 비용이 필요하다.

Geometry는 크게 줄어도 Fragment 비용은 단순 Billboard보다 높다.

Far Object의 Pixel Coverage와 Light 수에 맞춰 Shader를 제한한다.

---

## Normal Capture

Normal Texture는 원본 Surface 방향을 Impostor Pixel에 저장한다.

```text
Normal Encode
World Space 또는 Object Space
→ Texture
```

Billboard가 Camera를 따라 회전하므로 Captured Normal를 올바른 Space로 복원해야 한다.

View Frame Blend 시 Normal를 단순 Linear Blend한 뒤 Normalize한다.

Compression과 낮은 Resolution은 Specular가 흔들리는 Artifact를 만들 수 있다.

---

## Depth Impostor

Color뿐 아니라 Camera 기준 Depth를 저장하면 Flat Quad 안에서 Surface Position를 근사할 수 있다.

```text
Impostor UV
→ Depth Sample
→ Ray 방향 Position 복원
```

Lighting, Fog와 다른 Geometry의 Depth Test에 더 자연스럽게 참여할 수 있다.

단순 Alpha Billboard보다 Texture Sample와 Reconstruction 연산이 추가된다.

Depth Discontinuity와 View Blend에서 Layer가 찢어지는 Artifact를 처리해야 한다.

---

## Parallax Correction

Camera가 옆으로 이동하면 Flat Image 내부 Feature가 모두 같은 Depth에 있는 것처럼 움직인다.

```text
실제 Tree
Front Branch와 Back Branch
→ 서로 다른 Parallax

Flat Billboard
→ 같은 Plane Motion
```

Depth를 이용해 UV나 Ray Intersection를 보정하면 내부 Parallax를 일부 복원할 수 있다.

효과는 좋아지지만 Iteration, Texture Sample와 Edge Hole 문제가 생긴다.

---

## Layered Impostor

Object를 여러 Depth Layer로 분리해 Front·Middle·Back Plane를 사용한다.

```text
Camera
→ Front Layer
→ Middle Layer
→ Back Layer
```

단일 Quad보다 Parallax와 Volume가 좋아진다.

Triangle·Draw·Overdraw와 Texture Memory가 증가해 원본 Low-poly Mesh보다 이득이 줄 수 있다.

Layer 수와 Target Distance를 제한한다.

---

## Cross Billboard

두 개 이상의 Plane를 서로 교차시킨다.

```text
Top View

   \ /
    X
   / \
```

Camera 방향 회전 없이도 여러 Angle에서 Volume처럼 보인다.

Grass, Shrub와 먼 Tree에 사용한다.

Plane가 겹쳐 Alpha Overdraw가 증가하고 Top View에서 별 모양이 드러날 수 있다.

---

## Camera-facing Quad와 Cross Plane 비교

| 항목 | Camera-facing Quad | Cross Plane |
|---|---|---|
| Geometry | 2 Triangles 중심 | 4개 이상 Triangle |
| Rotation | Camera별 필요 | 고정 가능 |
| Side View | 항상 넓게 보임 | 여러 Plane 중 일부 보임 |
| Overdraw | 한 Layer 중심 | Plane 중첩 가능 |
| 여러 Camera | Vertex 방식이면 대응 | 자연스럽게 대응 가능 |

Object 수, Camera 수와 View Angle로 선택한다.

---

## Mesh Impostor

완전한 Quad 대신 단순한 Proxy Mesh에 Captured Texture를 투영할 수 있다.

```text
Original Tree 100K Triangles
→ Proxy Hull 20 Triangles
```

Silhouette와 큰 Depth 변화를 유지하면서 Geometry를 크게 줄인다.

Camera-facing 회전이 덜 필요하고 Shadow도 단순 Quad보다 자연스러울 수 있다.

Proxy Mesh 제작, UV와 Capture Projection이 추가로 필요하다.

---

## BillboardRenderer

Unity의 `BillboardRenderer`는 `BillboardAsset` Data를 이용해 Billboard를 Rendering한다.

```text
BillboardAsset
├─ Width·Height
├─ Bottom
├─ Vertices
├─ Indices
└─ Image UV Data
```

Tree와 Custom Billboard Asset를 표현하는 데 사용할 수 있다.

일반 MeshRenderer Quad와 Material를 직접 사용하는 방식과 Authoring·Batching 차이를 비교한다.

Unity Version과 Render Pipeline의 지원 범위를 확인한다.

---

## BillboardAsset

BillboardAsset은 Billboard Geometry와 여러 Image TexCoord Data를 저장한다.

```text
Runtime View Direction
→ Billboard Image TexCoord 선택
→ Camera-facing Geometry Draw
```

Material와 Texture Atlas를 연결하고 Bottom·Size로 Ground Alignment를 조정할 수 있다.

Asset를 Script로 생성할 때 Vertex·Index·Image TexCoord 배열을 올바르게 설정해야 한다.

---

## SpeedTree Billboard

SpeedTree는 Tree LOD의 마지막 단계에서 Billboard 표현을 사용할 수 있다.

```text
LOD0 Tree Mesh
→ LOD1 Simplified Tree
→ LOD2 Billboard
```

LOD Group의 SpeedTree Fade Mode와 Tree Shader Data를 이용해 Mesh에서 Billboard 전환을 완화할 수 있다.

Wind, Color Variation, Shadow와 Billboard Lighting가 Mesh 단계와 일치하는지 확인한다.

URP SpeedTree Shader Version에 맞는 Importer와 Material를 사용한다.

---

## LOD Group에 Impostor 연결

Impostor Renderer를 가장 낮은 LOD Level에 등록한다.

```text
LOD Group
├─ LOD0: High Mesh Renderers
├─ LOD1: Low Mesh Renderers
├─ LOD2: Impostor Renderer
└─ Cull
```

Threshold는 Mesh와 Impostor 차이가 구분되지 않는 Screen Size에서 설정한다.

Cross-fade를 사용하면 두 Renderer가 Transition 구간에 동시에 Draw될 수 있다.

원본 Mesh와 Impostor의 Pivot, Bounds와 Color를 일치시킨다.

---

## Mesh에서 Impostor로 전환할 때

전환 Pop의 원인을 분류한다.

```text
Shape Pop
→ Capture Silhouette·Pivot 차이

Color Pop
→ Lighting·Exposure·Color Space 차이

Scale Pop
→ Bounds·Capture Framing 차이

Shadow Pop
→ Shadow Caster 형태 차이

Motion Pop
→ Wind·Animation 차이
```

Fade Width를 늘리기 전에 Source Data와 Capture 조건을 먼저 맞춘다.

---

## Capture Framing

모든 방향 Frame에서 Object가 Texture Rect 안에 들어오도록 Orthographic Capture 범위를 설정한다.

```text
Capture Bounds
→ Object 최대 Extents 포함
→ 일정한 Scale·Center 유지
```

Frame마다 Crop 크기가 다르면 Runtime Blend에서 Object 크기가 흔들린다.

Pivot와 Ground Height를 공통 기준에 고정한다.

Texture Padding은 Mipmap Bleeding 방지를 위해 필요하지만 Quad의 투명 Coverage를 늘릴 수 있다.

---

## Capture Projection

Orthographic Capture는 Perspective Distortion가 없어 먼 거리에서 안정적이다.

```text
Orthographic Capture
→ 방향별 일정 Scale
```

Perspective Capture는 가까운 View와 비슷할 수 있지만 Frame별 Camera Distance와 FOV를 정확히 유지해야 한다.

원거리 Impostor는 Orthographic Capture가 일반적으로 관리하기 쉽다.

큰 Building와 내부 Parallax에는 Depth 방식이 필요할 수 있다.

---

## Atlas Packing

여러 방향 Frame를 하나의 Texture Atlas에 배치한다.

```text
┌────┬────┬────┬────┐
│ 0° │45° │90° │135°│
├────┼────┼────┼────┤
│180°│225°│270°│315°│
└────┴────┴────┴────┘
```

한 Texture로 Frame를 선택해 Material State와 Batching을 유지할 수 있다.

Cell Padding, Mipmap와 Texture Compression Block 경계를 고려한다.

Frame 수가 늘면 각 Cell Resolution 또는 전체 Atlas Memory가 커진다.

---

## Atlas Bleeding

Mipmap과 Bilinear Filtering는 Cell 경계 밖 Texel을 Sample할 수 있다.

```text
Cell A Edge
→ Filter Footprint
→ Cell B Color 혼입
```

Frame 사이에 충분한 Padding을 두고 Border Texel를 확장한다.

UV를 Cell 내부로 Clamp하거나 Mip-safe Atlas Layout을 사용한다.

Far Distance에서 낮은 Mip을 사용할수록 Bleeding이 잘 나타날 수 있다.

---

## Alpha Padding

Object Silhouette 밖은 Alpha 0이지만 RGB Color가 검은색이면 Filtering에서 Dark Halo가 생길 수 있다.

```text
Opaque Edge Color
→ Transparent Pixel RGB로 확장
→ Alpha만 0
```

Color Dilate를 이용해 투명 영역의 RGB를 가장 가까운 Surface Color로 채운다.

Premultiplied Alpha 여부와 Blend Mode를 Bake·Runtime Shader에서 일치시킨다.

---

## Alpha Clip과 Blend

Tree Impostor는 Silhouette를 위해 Alpha Clip 또는 Alpha Blend를 사용한다.

```text
Alpha Clip
→ 명확한 Edge
→ Alias 가능
→ Blend Layer 감소 가능

Alpha Blend
→ 부드러운 Edge
→ Sorting·Overdraw·ZWrite 문제
```

Alpha-to-Coverage와 MSAA를 이용할 수 있지만 Platform과 Pipeline 지원을 확인한다.

먼 Tree 수천 개에서는 작은 Blend 비용도 넓게 누적된다.

---

## Impostor Overdraw

원본 Mesh보다 Triangle는 줄지만 Quad의 투명 영역이 큰 경우 Fragment 수가 증가할 수 있다.

```text
Original Tight Geometry
→ 많은 Triangles
→ 낮은 Empty Coverage

Impostor Quad
→ 2 Triangles
→ 넓은 Alpha 0 영역
```

Geometry Bound Scene에서는 이득이 크지만 Fill-rate Bound Mobile에서는 손해가 날 수 있다.

Tight Polygon Billboard, Alpha Clip와 Texture Crop을 비교한다.

---

## Tight Billboard Mesh

직사각형 Quad 대신 Impostor Silhouette에 가까운 몇 개 Polygon로 Plane를 구성한다.

```text
Rectangle
┌──────────┐
│   Tree   │
└──────────┘

Tight Hull
  /────\
 / Tree \
/_______\
```

Triangle는 조금 늘지만 투명 Fragment Coverage를 줄인다.

Screen 크기, Vertex 비용과 Overdraw 중 어떤 병목이 큰지 Target에서 측정한다.

---

## Sorting

Alpha Blend Impostor는 Transparent Queue에서 Camera 거리 순으로 정렬될 수 있다.

```text
Far Tree Impostor
→ Near Tree Impostor
```

Billboard Bounds Center와 실제 Volume Center가 다르면 Sorting 순서가 어색할 수 있다.

Tree Cluster가 서로 교차하면 Object 단위 Sorting으로 모든 Pixel 순서를 해결할 수 없다.

가능하면 Alpha Clip·Opaque Depth Write 경로를 검토한다.

---

## Depth Write

Alpha Clip Impostor는 통과한 Pixel에 Depth를 기록해 뒤 Impostor Overdraw를 줄일 수 있다.

```text
Alpha Clip Pass
ZWrite On
→ Visible Leaf Pixel Depth 기록
```

하지만 Cutoff Edge가 Alias되고 Captured Surface 전체가 한 Plane Depth에 놓인다.

Depth Impostor는 Pixel별 Depth를 출력해 Volume를 더 정확히 표현할 수 있지만 Early-Z와 Shader 비용에 영향을 줄 수 있다.

---

## Shadow Casting

Quad Impostor가 Shadow Map에 그대로 들어가면 Camera와 Light 방향이 달라 문제가 생긴다.

```text
Camera-facing Quad
≠ Light-facing Geometry
```

가능한 전략은 다음과 같다.

```text
Far Shadow 끄기
Simple Shadow Proxy Mesh
Light-facing Shadow Billboard
Captured Shadow Texture
Original Low LOD Shadow Caster 유지
```

Shadow Pass 비용과 Silhouette Pop을 비교한다.

---

## Receive Shadow

Unlit Baked Impostor는 Scene Realtime Shadow를 자연스럽게 받기 어렵다.

Relightable Impostor는 Normal·Depth를 이용해 Shadow Map을 Sample할 수 있다.

```text
Impostor Pixel Position 복원
→ Shadow Coordinate
→ Shadow Sample
```

Flat Plane Position만 사용하면 Tree 전체가 같은 Depth Plane에 있는 것처럼 Shadow가 붙을 수 있다.

Far Distance에서 허용 가능한 품질인지 확인한다.

---

## Fog

Distance Fog는 Billboard Center나 Pixel Depth로 계산한다.

```text
Center Depth Fog
→ 단순

Per-pixel Depth Fog
→ Volume에 더 정확
```

Far Impostor는 Fog에 많이 섞이므로 일부 Artifact를 숨길 수 있다.

Capture Texture에 Fog를 Bake하면 Runtime Fog와 이중 적용될 수 있으므로 Capture는 보통 Fog 없는 상태로 만든다.

---

## Wind Animation

Tree Mesh는 Branch와 Leaf가 Vertex Wind로 움직인다.

Static Impostor Texture로 전환하면 움직임이 갑자기 멈춘다.

```text
Mesh LOD
→ Branch Wind

Impostor
→ Static Card
```

UV Distortion, Vertex Sway와 여러 Animation Frame로 Far Wind를 근사할 수 있다.

Mesh·Impostor 전환 구간의 Phase와 Amplitude를 맞춘다.

---

## Animated Impostor

Character와 Effect는 Animation Frame와 View Direction 두 축을 Capture할 수 있다.

```text
Data Count
= View Frames
× Animation Frames
```

8방향 × 16 Animation Frame이면 128 Image가 필요하다.

Texture Array, Atlas, Compression와 Frame Interpolation을 사용하지만 Memory가 빠르게 증가한다.

Crowd 수가 많고 Animation 종류가 제한될 때 유리하다.

---

## Crowd Impostor

먼 Crowd의 Skinned Mesh와 Animation을 Sprite Animation으로 대체할 수 있다.

```text
Near Crowd
→ Skinned LOD

Far Crowd
→ Animated Impostor
```

Skinning·Bone·Triangle 비용을 크게 줄이고 Instancing하기 쉽다.

View·Animation Atlas Memory, Lighting와 Character Customization 제한이 생긴다.

Team Color와 Equipment 변화는 Mask·Layer Texture로 처리할 수 있다.

---

## Building Impostor

먼 Building Cluster를 Impostor로 바꾸면 Geometry와 Draw 수를 크게 줄일 수 있다.

```text
District HLOD
→ Captured Color·Normal·Depth
→ Proxy Plane·Box
```

Camera 이동에 따른 Parallax가 Tree보다 눈에 띄므로 Depth Impostor나 Proxy Mesh가 필요할 수 있다.

Window Emission, Day·Night와 Weather 변화도 Capture Data에 반영해야 한다.

---

## Cloud Impostor

Volume Cloud와 Smoke Simulation 결과를 여러 방향 Slice나 Impostor로 Capture할 수 있다.

```text
Volumetric Data
→ Baked View Textures
→ Billboard Layers
```

Ray March Step를 줄이지만 View Dependence와 Lighting 변화 표현이 제한된다.

여러 Transparent Layer의 Overdraw와 Sorting 비용을 확인한다.

---

## Icon Billboard

World Space Health Bar와 Quest Marker는 Camera-facing Billboard지만 3D Object Impostor는 아니다.

```text
World Position
→ Screen-readable Quad
```

항상 같은 Pixel Size를 유지하면 멀리서도 화면을 크게 차지할 수 있다.

Distance Scale, Occlusion와 Maximum Visible Count를 제한한다.

UI Canvas 방식과 GPU Instanced Billboard를 비교한다.

---

## Billboard와 GPU Instancing

모든 Billboard가 같은 Quad Mesh와 Material를 사용하면 Center, Size와 Frame Index만 Instance Data로 전달할 수 있다.

```text
Shared Quad
+ Instance Center
+ Size
+ Atlas Frame
→ Instanced Draw
```

CPU Transform Update와 Draw Call를 줄인다.

MaterialPropertyBlock의 Non-instanced Property나 서로 다른 Texture가 Instancing을 깨지 않는지 확인한다.

---

## SRP Batcher와 Billboard

서로 다른 Material를 쓰는 Billboard도 Shader가 SRP Batcher 호환이면 Material State 처리 비용을 줄일 수 있다.

Instancing은 같은 Mesh·Material의 여러 Instance를 한 Draw에 묶고 SRP Batcher는 호환 Draw 사이 Shader Constant 관리 비용을 줄인다.

```text
Geometry 감소
→ Billboard

Draw 감소
→ GPU Instancing

State 비용 감소
→ SRP Batcher
```

세 최적화의 역할을 구분한다.

---

## Texture Array

여러 Object 종류와 View Frame를 Texture Array Layer에 저장할 수 있다.

```text
Texture2DArray
├─ Tree A Views
├─ Tree B Views
└─ Rock Views
```

동일 Dimension·Format·Mip Count가 필요하지만 Material를 공유하고 Instance Layer Index로 선택하기 쉽다.

Array 전체 Memory와 Streaming Granularity가 커질 수 있다.

Atlas Bleeding은 줄지만 Layer 수 제한과 Platform 지원을 확인한다.

---

## Mipmap

Impostor Texture는 Far Distance에서 작게 보이므로 Mipmap이 중요하다.

```text
High Mip
→ Near Impostor Detail

Low Mip
→ Far Stable Sampling
```

Mipmap이 없으면 Shimmering와 Cache Miss가 증가할 수 있다.

Alpha Clip Texture는 Mip이 내려가며 Alpha Coverage가 달라져 Tree가 얇아지거나 사라질 수 있다.

Preserve Coverage와 Cutoff를 검토한다.

---

## Texture Compression

다방향 Color·Normal·Depth Atlas는 Memory가 크므로 Platform Compression이 필요하다.

```text
Color·Alpha
→ BC·ASTC·ETC 계열

Normal
→ Normal 적합 Format

Depth
→ Precision 요구 확인
```

Block Compression는 얇은 Branch와 Alpha Edge에 Artifact를 만들 수 있다.

Capture Resolution, Frame 수와 Compression Block Size를 Target Physical Screen에서 비교한다.

---

## Texture Memory 계산

8방향 RGBA8 Frame가 각각 512 × 512이고 Compression이 없다고 단순 계산한다.

```text
512 × 512 × 4 Bytes
≈ 1 MB per Frame

× 8 Views
≈ 8 MB

+ Mipmaps
≈ 약 10.7 MB 개념
```

Normal·Depth를 추가하면 더 커진다.

실제 Memory는 Format, Compression, Mip와 Platform Alignment에 따라 달라진다.

Geometry Memory를 줄인 대신 Texture Memory를 과도하게 늘리지 않는다.

---

## Capture Resolution

Impostor가 전환되는 최대 Screen Pixel 크기보다 훨씬 큰 Texture는 Memory를 낭비한다.

```text
Transition에서 Impostor 최대 128 Pixels
→ 2048 Texture Detail 대부분 사용되지 않음
```

View Angle Blend, Anisotropic Sampling와 Upscaling을 고려해 여유를 두되 실제 Maximum Screen Size를 기준으로 Resolution을 정한다.

고해상도 4K·XR Target는 같은 Relative Size에서 더 많은 Pixel이 필요할 수 있다.

---

## Capture Bake 비용

Object마다 여러 방향, Material Buffer와 Lighting Variant를 Render Texture에 Bake해야 한다.

```text
Bake Time
≈ Asset 수
× View 수
× Texture Channels
× Resolution
```

Source Mesh·Material가 바뀌면 Impostor를 다시 Bake해야 한다.

자동 Build Pipeline에서 Cache와 변경 감지를 사용한다.

Runtime 성능 이득과 Asset 제작·CI 시간을 함께 고려한다.

---

## Source와 Impostor 동기화

원본 Tree Material Color를 수정했지만 Impostor Atlas를 다시 만들지 않으면 LOD 전환에서 색이 바뀐다.

```text
Source Version
≠ Bake Version
→ Stale Impostor
```

Source Asset GUID·Hash와 Bake Setting를 Impostor Metadata에 저장한다.

Stale Bake를 자동으로 검출하고 Release Build 전에 재생성한다.

---

## Dynamic Material 변경

Snow, Wetness, Damage와 Team Color가 Runtime에 바뀌면 Baked Final Color Impostor는 반영하지 못한다.

```text
대안
├─ Mask Channel 저장
├─ Runtime Tint
├─ Multiple Texture Set
├─ Relightable Material Data
└─ Impostor 사용 거리 제한
```

모든 동적 기능을 Impostor Shader에 넣으면 Far Shader가 다시 복잡해진다.

눈에 보이는 핵심 변화만 유지한다.

---

## Camera Roll

Screen-aligned Billboard는 Camera Roll에 따라 함께 회전한다.

Tree는 World Up을 유지해야 하므로 Cylindrical 방식이 더 적합하다.

```text
UI Marker
→ Screen-aligned

Tree
→ World-up constrained
```

VR Head Tilt와 Aircraft Camera에서 Billboard Orientation을 실제 Camera Motion으로 검증한다.

---

## Camera가 위에서 볼 때

Cylindrical Billboard는 Camera가 Object 위로 이동해도 Vertical Plane에 남는다.

```text
Top-down Camera
↓
Vertical Billboard → 얇은 Line에 가까움
```

Strategy Game와 Flight Camera에서는 Elevation Capture, Spherical Billboard, Cross Plane 또는 Proxy Mesh가 필요하다.

Gameplay Camera 높이가 제한돼 있다면 불필요한 View Frame를 저장하지 않는다.

---

## Camera가 가까워질 때

Impostor Quad에 가까워지면 Flat Shape, 낮은 Texture Resolution와 Parallax 부족이 드러난다.

```text
Far → Impostor 허용
Near → 원본 Mesh 필요
```

LOD Transition를 Artifact가 보이기 전 Screen Size에 둔다.

Camera Teleport, Scope Zoom와 Photo Mode가 Impostor를 강제로 확대하지 않는지 확인한다.

---

## 여러 Camera

CPU Transform로 하나의 Billboard를 Main Camera 방향으로 돌리면 Reflection Camera에는 잘못된 방향이 보일 수 있다.

```text
Main Camera Facing ✓
Reflection Camera Facing ✗
```

Camera별 Vertex Shader Basis를 사용하거나 Camera마다 별도 Draw Data를 만든다.

Mini Map와 Shadow Camera는 Impostor 대신 Proxy Renderer를 사용할 수 있다.

---

## XR Stereo

Left Eye와 Right Eye는 Position가 다르다.

```text
Left Eye View Direction
≠ Right Eye View Direction
```

각 Eye에 완전히 정면인 Billboard를 별도로 계산하면 Stereo Image가 약간 다르게 회전할 수 있다.

두 Eye 중간 Center Eye 방향을 사용하거나 Eye별 Basis를 사용하는 방식은 Stereo 안정성과 Flatness Trade-off가 있다.

가까운 Billboard는 두 Eye에서 Card 형태가 더 잘 드러나므로 충분히 먼 LOD에서 사용한다.

---

## Mobile에서의 손익

Mobile은 Geometry Throughput를 줄이는 Impostor의 이득이 크지만 Fill-rate와 Texture Bandwidth가 제한된다.

```text
Saved
→ Vertices·Triangles·Draws

Added
→ Alpha Coverage·Texture Samples·Memory
```

Tree Geometry를 Quad로 바꿨는데 Transparent Padding과 Layer Overdraw가 커지면 GPU 시간이 늘 수 있다.

Overdraw View, LOD Force와 Resolution Test를 Target Device에서 수행한다.

---

## XR에서의 손익

XR은 두 Eye Geometry 처리와 높은 목표 FPS 때문에 Impostor 이득이 클 수 있다.

반면 높은 Eye Texture Resolution과 Stereo Parallax 때문에 Flat Card Artifact도 잘 보일 수 있다.

```text
XR 검증
├─ Eye별 Orientation
├─ Stereo Depth
├─ Foveated Rendering
├─ Alpha Overdraw
└─ 90·120 FPS Budget
```

Desktop Mono View만으로 품질을 결정하지 않는다.

---

## Impostor가 적합한 Object

```text
적합 후보
├─ 먼 Tree·Forest
├─ Rock
├─ Building·City HLOD
├─ Mountain
├─ 먼 Crowd
├─ Static Background Prop
└─ 제한된 Camera의 Volume Effect
```

멀리서 Silhouette와 큰 Color 형태가 중요하고 내부 Parallax가 작게 보이는 Object다.

반복 수가 많을수록 Bake·Memory 비용을 여러 Instance가 공유해 효율이 높다.

---

## Impostor가 부적합한 Object

```text
주의 대상
├─ 가까이 접근 가능한 Object
├─ 큰 Parallax가 있는 Architecture
├─ Camera가 내부로 들어가는 Object
├─ 형태가 크게 변하는 Character
├─ Runtime Destruction
├─ 강한 Dynamic Lighting
└─ 투명 Layer가 많은 Object
```

View Frame와 Shader를 늘려 모든 문제를 해결하려 하면 Low-poly Mesh보다 비싸질 수 있다.

Impostor를 사용할 거리와 Camera 범위를 제한한다.

---

## Low-poly Mesh와 비교

| 항목 | Low-poly Mesh | Impostor |
|---|---|---|
| Geometry | 수백~수천 Triangle | 수 개 Triangle |
| Parallax | 실제 Geometry | 제한적·Depth 근사 |
| Lighting | 자연스러움 | Capture Data에 의존 |
| Shadow | 실제 Proxy Shape | 별도 처리 필요 |
| Texture Memory | 기존 Material | View Atlas 추가 |
| Overdraw | Shape에 따라 Tight | Quad Padding 가능 |
| Animation | Skeleton·Vertex | Frame Atlas 필요 |

Far Distance에서 Low Mesh도 충분히 빠르고 품질이 좋다면 Impostor가 필요하지 않을 수 있다.

---

## HLOD와 비교

HLOD는 여러 Object를 하나의 Low-poly Cluster Mesh나 Impostor로 합치는 상위 개념이다.

```text
Individual LOD
→ Tree 하나의 Detail 단계

HLOD
→ Forest Cell 전체의 Proxy
```

HLOD Impostor는 Triangle와 Draw Call를 함께 크게 줄인다.

Cluster Bounds가 커져 Culling Granularity가 낮아지고 Texture Atlas가 커질 수 있다.

World Streaming Cell과 함께 설계한다.

---

## Frame Debugger로 확인한다

LOD Transition 전후 실제 Draw를 확인한다.

```text
Near
→ Original Mesh Draws

Far
→ Impostor Draw

Transition
→ Mesh + Impostor 동시 Draw 가능
```

Material, Blend, ZWrite, Cull, Texture와 Shadow Pass를 확인한다.

Impostor로 바뀌었는데 원본 Child Renderer 일부가 등록 누락으로 남아 있지 않은지 확인한다.

---

## Overdraw View로 확인한다

Impostor Forest가 화면에서 넓은 Alpha Quad를 얼마나 겹치는지 확인한다.

```text
밝은 Tree Crown 영역
→ Billboard Layer 중첩
→ Transparent Padding 후보
```

원본 Mesh와 Impostor Variant를 같은 Camera에서 비교한다.

Triangle 통계가 줄어도 Overdraw가 크게 늘면 Mobile GPU 성능이 악화될 수 있다.

---

## Rendering Profiler로 확인한다

```text
비교 지표
├─ Batches
├─ SetPass
├─ Triangles
├─ Vertices
├─ Used Textures
└─ Render Texture
```

Impostor Instancing으로 Draw가 줄었는지, Texture Atlas 증가가 Memory에 어떤 영향을 주는지 확인한다.

통계 감소를 CPU·GPU ms와 연결한다.

---

## GPU Profiler로 확인한다

원본 Low Mesh와 Impostor의 Pass 시간을 비교한다.

```text
Original
Vertex  · Shadow · Opaque

Impostor
Vertex 감소
Fragment·Alpha Clip·Blend 증가 가능
```

Resolution을 낮췄을 때 Impostor만 크게 빨라지면 Fill-rate 비중이 높다.

Shadow Off·Alpha Clip·Texture Sample를 하나씩 바꿔 병목을 분리한다.

---

## A/B Test

같은 Camera와 Object 수에서 LOD를 강제한다.

```text
Variant A
Low-poly Mesh

Variant B
Single Billboard

Variant C
Multi-view Impostor

Variant D
Depth Impostor
```

| Variant | Draws | Triangles | Texture MB | GPU ms | 품질 |
|---|---:|---:|---:|---:|---|
| Low Mesh | 500 | 4M | 40 | 8.0 | 높음 |
| Billboard | 20 | 20K | 20 | 4.0 | 낮음 |
| Multi-view | 20 | 20K | 80 | 5.0 | 중간 |

숫자는 측정 형식의 예시다.

---

## 최적화 순서

```text
1. Impostor가 필요한 최대·최소 Screen Size 정의
2. Camera Azimuth·Elevation 범위 확인
3. 단일 Billboard와 Low Mesh 먼저 비교
4. 필요한 경우 Multi-view Frame 추가
5. Dynamic Lighting 필요 시 Normal·Material Capture
6. Parallax가 보이면 Depth·Proxy Mesh 검토
7. Atlas Resolution·Compression·Mip 조정
8. Alpha Padding·Overdraw 축소
9. LOD Fade·Shadow·Wind 일치
10. Target Device CPU·GPU·Memory 재측정
```

가장 복잡한 Impostor부터 만들지 않고 품질 기준을 만족하는 가장 단순한 표현을 선택한다.

---

## 흔한 오해

### Billboard와 Impostor는 완전히 같은 뜻이다

Billboard는 Camera-facing Geometry 방식이고 Impostor는 원본 Object의 시각적 대체 표현 전체를 뜻한다.

### Impostor는 Triangle가 적으므로 항상 빠르다

큰 Alpha Quad, Texture Sample, Blend와 Overdraw가 Geometry 절감보다 비쌀 수 있다.

### Camera를 향하면 모든 각도에서 원본처럼 보인다

단일 Image는 측면·상단 형태와 Parallax를 표현하지 못한다.

### View Frame를 많이 만들수록 무조건 좋다

Texture Memory, Bake Time와 Sample·Blend 비용이 증가한다.

### Impostor는 Dynamic Lighting을 사용할 수 없다

Normal·Material Data를 저장해 Relighting할 수 있지만 Shader와 Texture 비용이 추가된다.

### Depth Texture를 추가하면 실제 Geometry와 같다

Parallax를 개선할 뿐 Disocclusion, 복잡한 Layer와 Silhouette 한계가 남는다.

### Cross-fade는 전환 비용이 없다

Mesh와 Impostor를 동시에 Draw하는 구간이 생길 수 있다.

### Shadow는 Billboard가 자동으로 자연스럽게 만든다

Camera-facing Plane와 Light 방향이 달라 별도 Shadow Proxy나 정책이 필요하다.

### Texture Resolution은 높을수록 좋다

전환 시 최대 Screen Pixel보다 과도하면 Memory와 Bandwidth를 낭비한다.

### CPU에서 Billboard를 회전하면 모든 Camera에 맞는다

하나의 Transform는 Main·Reflection·Stereo Camera의 서로 다른 방향을 동시에 만족하지 못한다.

### Impostor가 있으면 LOD Mesh는 필요 없다

가까운 거리의 Parallax·Lighting 품질을 위해 Mesh 단계가 필요하며 Impostor는 Far LOD에 적합하다.

---

## 최종 체크리스트

```text
□ Billboard Orientation이 Screen·Spherical·Cylindrical 중 적절한가?
□ Tree·Character Pivot가 Ground에 고정되는가?
□ Vertex Shader Billboard Bounds가 모든 방향을 포함하는가?
□ 단일 View로 Camera 각도 범위를 만족하는가?
□ 필요한 Azimuth·Elevation Frame만 Capture했는가?
□ View 전환 Pop과 Frame Blend 비용을 비교했는가?
□ Octahedral·Hemispherical Sampling이 필요한가?
□ Baked Color와 Relightable Data 중 목적에 맞는가?
□ Normal Space와 View Blend가 올바른가?
□ Depth·Parallax 비용이 품질 이득보다 작은가?
□ Capture Pivot·Scale·Projection가 Frame마다 일치하는가?
□ Atlas Padding·Mip Bleeding을 방지했는가?
□ Transparent RGB Dilate와 Blend Mode가 맞는가?
□ Alpha Clip·Blend·Depth Write를 비교했는가?
□ Tight Billboard Mesh로 Empty Coverage를 줄였는가?
□ Shadow Proxy와 Receive Shadow 정책이 있는가?
□ Mesh·Impostor Wind와 Color가 전환에서 일치하는가?
□ LOD Group Renderer 등록과 Fade가 올바른가?
□ GPU Instancing·SRP Batcher를 유지하는가?
□ Texture Array·Atlas Memory를 계산했는가?
□ Capture Resolution이 최대 Screen Pixel에 맞는가?
□ Multi-camera·XR Eye에서 방향이 올바른가?
□ Overdraw View와 Frame Debugger로 실제 Draw를 확인했는가?
□ Low Mesh 대비 CPU·GPU·Memory를 Target에서 측정했는가?
```

---

## 정리

Billboard는 Camera를 향하도록 회전하는 평면이고 Impostor는 복잡한 3D Object의 외형을 Capture Texture와 간단한 Proxy Geometry로 대체하는 Far LOD 기법이다.

Screen·Spherical Billboard는 Camera Pitch까지 따르며 Tree처럼 수직을 유지해야 하는 Object는 World Up을 고정한 Cylindrical 방식이 적합하다.

단일 View는 가장 저렴하지만 각도 한계가 있고 Multi-view·Octahedral Impostor는 방향 품질을 높이는 대신 Atlas Memory와 Texture Sample·Blend 비용을 늘린다.

Normal·Material Data는 Dynamic Relighting을 가능하게 하고 Depth는 Parallax와 Pixel Position를 개선하지만 Shader 연산, Disocclusion와 View Blend 문제가 추가된다.

Impostor는 Geometry·Draw를 크게 줄이는 대신 Alpha Padding·Overdraw, Texture Memory, Flat Shadow, Wind·Lighting 불일치와 LOD Pop을 만들 수 있다.

LOD Group의 마지막 Mesh 단계 뒤에 Impostor를 배치하고 Capture Pivot·Scale·Color, Cross-fade와 Shadow를 원본 Renderer에 맞춰야 한다.

Frame Debugger와 Overdraw View, Rendering·GPU Profiler를 이용해 Low-poly Mesh, 단일 Billboard와 Multi-view Impostor의 CPU·GPU·Memory·품질을 Target Camera에서 비교해야 한다.
