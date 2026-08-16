---
title: "[Unity 렌더링] 11-5. Backface Culling은 무엇일까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - Culling
  - BackfaceCulling
  - ShaderLab
permalink: /programming/unity-11-5-what-is-backface-culling/
toc: true
toc_sticky: true
date: 2026-08-16
last_modified_at: 2026-08-16
---

Backface Culling은 Camera 반대 방향을 향하는 Triangle을 Rasterization 전에 제거하는 기법이다.

```text
Camera → [ Closed Mesh ]

앞쪽 Triangle  → 화면에 보임
뒤쪽 Triangle  → 앞면에 가려짐
```

닫힌 Opaque Mesh에서는 뒷면 Triangle이 최종 화면에 기여하지 않는 경우가 많다.

GPU가 이 Triangle을 Fragment로 만들기 전에 제외하면 Rasterization과 Fragment Shader 작업을 줄일 수 있다.

---

## Face는 Triangle의 방향을 가진다

Triangle은 세 Vertex의 Position뿐 아니라 Index가 나열된 순서를 가진다.

```text
Triangle A
v0 → v1 → v2

Triangle B
v0 → v2 → v1
```

같은 세 Position을 사용해도 순서를 반대로 연결하면 Triangle이 향하는 Front 방향도 반대로 해석된다.

이 순서를 Winding Order라고 한다.

Backface Culling은 Winding Order가 화면에서 Clockwise인지 Counter-clockwise인지 판정해 Front·Back Face를 구분한다.

---

## Winding Order

화면에 투영된 Triangle의 Vertex가 어떤 방향으로 이어지는지 본다.

```text
Counter-clockwise

        v1
       /  \
      /    \
    v0 ─── v2

v0 → v2 → v1 같은 순서는
Convention에 따라 반대 Face가 될 수 있음
```

어느 순서를 Front로 정의하는지는 Graphics API와 Engine의 Coordinate·Projection Convention에 따라 다를 수 있다.

Unity가 현재 Rendering Backend에 맞게 Front Face Convention을 처리하므로 ShaderLab의 `Cull Back` 의미를 기준으로 사용한다.

---

## Cross Product로 방향을 생각할 수 있다

World Space Triangle Edge 두 개의 Cross Product로 기하학적 Face Normal을 구할 수 있다.

```text
e1 = v1 - v0
e2 = v2 - v0

faceNormal = normalize(cross(e1, e2))
```

Vertex 순서를 바꾸면 Cross Product 방향도 반대로 바뀐다.

```text
cross(e1, e2) =  n
cross(e2, e1) = -n
```

이 관계가 Winding Order와 Face 방향의 기하학적 기반이다.

실제 GPU의 Front Face 판정은 Projection 이후 화면 공간 Orientation을 이용할 수 있다.

---

## Camera 방향과 Face 방향

개념적으로 Face Normal이 Camera 쪽을 향하면 Front Face, 반대쪽이면 Back Face로 볼 수 있다.

```text
Camera Direction
      ↓

Front Face Normal ↑
──────────────────

Back Face Normal  ↓
```

Dot Product로 방향 관계를 설명할 수 있다.

```text
dot(faceNormal, viewDirection)
```

부호로 Camera와 같은 쪽인지 반대쪽인지 구분할 수 있다.

하지만 GPU Rasterizer는 Vertex Normal Texture가 아니라 Triangle Winding을 기준으로 Face를 판정한다.

---

## Vertex Normal과 Face 방향은 다르다

Mesh Vertex에는 Lighting에 사용하는 Normal Attribute가 저장될 수 있다.

```text
Face Direction
→ Triangle Index 순서
→ Culling 판정

Vertex Normal
→ Lighting 방향
→ Smooth Shading
```

Vertex Normal을 뒤집어도 Triangle Index 순서가 같으면 Backface Culling 결과는 바뀌지 않는다.

반대로 Triangle Index를 뒤집어도 Vertex Normal Data는 자동으로 반전되지 않을 수 있다.

Geometry Face와 Lighting Normal을 별개로 수정해야 한다.

---

## 닫힌 Mesh에서 뒷면이 보이지 않는 이유

Cube나 Sphere처럼 닫힌 Opaque Mesh를 바깥에서 보면 Camera 반대편 Face는 앞 Face 뒤에 있다.

```text
Camera →  ┌───────┐
          │ Cube  │
          └───────┘

앞 Face가 Color·Depth 기록
뒤 Face는 최종 화면에 기여하지 않음
```

뒤 Triangle을 Rasterize해도 Depth Test로 제거될 가능성이 높다.

Backface Culling은 더 일찍 Primitive를 제거해 불필요한 Fragment 후보 생성을 피한다.

---

## Pipeline에서의 위치

개념적인 Rendering 흐름에서 Backface Culling은 Primitive Assembly 이후 Rasterization 전에 적용된다.

```text
Vertex Shader
   │
   ▼
Primitive Assembly
   │
   ▼
Face Orientation Test
   ├─ Culled → 종료
   └─ Kept
        │
        ▼
Rasterization
        │
        ▼
Fragment Shader
```

Triangle가 Cull되어도 그 Triangle Vertex를 처리하는 Vertex Shader 비용은 이미 발생할 수 있다.

Backface Culling은 Renderer Draw Submission과 Vertex Processing 전체를 제거하는 Object Culling은 아니다.

---

## Frustum Culling과 단위가 다르다

Frustum Culling은 Renderer Bounds와 Camera Volume을 비교한다.

```text
Frustum Culling
→ Renderer·Object 단위
→ Draw 전체 제외 가능
```

Backface Culling은 Draw 안의 각 Triangle 방향을 판정한다.

```text
Backface Culling
→ Primitive 단위
→ 같은 Mesh 안 일부 Triangle 제외
```

Object가 Frustum 안에 있어 Draw되더라도 Camera 반대쪽 Triangle은 Backface Culling으로 제거할 수 있다.

---

## Occlusion Culling과 단위가 다르다

Occlusion Culling은 다른 Geometry 뒤에 완전히 가려진 Renderer를 Visible Set에서 제외한다.

Backface Culling은 다른 Object가 없어도 Triangle 자체 방향만으로 제거한다.

```text
Occlusion
Camera → Wall → Hidden Object

Backface
Camera → Object의 반대 방향 Face
```

Occluder Data와 Bake가 없어도 Backface 판정은 Rasterizer State로 수행할 수 있다.

---

## Depth Test와 단위가 다르다

Depth Test는 Rasterization으로 만들어진 Fragment의 깊이를 비교한다.

```text
Backface Culling
→ Triangle를 Rasterization 전에 제거

Depth Test
→ Fragment를 Rasterization 후 제거
```

Backface Culling을 끄더라도 닫힌 Opaque Mesh의 뒷면은 앞면 Depth 때문에 최종 화면에 보이지 않을 수 있다.

그러나 뒷면 Rasterization과 Depth Test 작업은 추가된다.

---

## ShaderLab의 Cull Command

ShaderLab은 Rasterization 중 어느 Face를 제거할지 `Cull` Command로 지정한다.

```shaderlab
Cull Back
```

대표 Mode는 다음과 같다.

| Mode | 제거하는 Face | 일반적인 용도 |
|---|---|---|
| `Cull Back` | Back Face | 일반 Opaque Mesh |
| `Cull Front` | Front Face | 내부 Shell·특수 Pass |
| `Cull Off` | 제거하지 않음 | 양면 Plane·Foliage·Cloth |

명시하지 않았을 때의 기본 동작과 Shader Graph 설정은 Shader·Pipeline에 따라 Inspector에서 확인한다.

---

## Cull Back

`Cull Back`은 Camera에서 뒤를 향하는 Triangle을 제거한다.

```shaderlab
Pass
{
    Cull Back
}
```

닫힌 Mesh의 외부 Surface를 Rendering하는 가장 일반적인 설정이다.

```text
Outside Camera
→ 외부 Front Face 표시
→ 내부 Back Face 제거
```

Scene Object가 뒤집힌 Winding이나 Negative Scale을 사용하지 않는다는 전제가 필요하다.

---

## Cull Front

`Cull Front`는 Front Face를 제거하고 Back Face만 Rendering한다.

```shaderlab
Pass
{
    Cull Front
}
```

Object 내부 Shell, Outline 확장 Pass와 특수 Volume Effect에서 사용할 수 있다.

```text
Inflated Mesh Outline
→ Front Face 제거
→ 뒤집힌 외곽 Shell만 표시
```

일반 Material에 실수로 적용하면 Object 바깥 Surface가 사라지고 내부가 보이는 결과가 생긴다.

---

## Cull Off

`Cull Off`는 Front와 Back Face를 모두 Rasterize한다.

```shaderlab
Pass
{
    Cull Off
}
```

두께가 없는 Plane의 양쪽이 보여야 할 때 사용한다.

```text
Leaf Card
Cloth Plane
Paper
Hair Card
Grass Blade
```

하지만 같은 Mesh에서 Camera 반대쪽 Triangle까지 처리하므로 Overdraw와 Fragment 비용이 증가할 수 있다.

---

## Cull Off가 정확히 두 배 비용일까?

항상 정확히 두 배는 아니다.

```text
비용 변수
├─ Back Face Screen Coverage
├─ Depth Test
├─ Early-Z
├─ Mesh가 열린 형태인지
├─ Shader 복잡도
├─ Transparency
└─ Camera 위치
```

닫힌 Opaque Mesh에서 Back Face는 앞 Surface Depth에 제거될 수 있어 Fragment Shader 증가가 제한될 수 있다.

Transparent나 열린 Layer에서는 앞뒤 Face가 모두 Blend되어 Pixel 비용이 크게 늘 수 있다.

---

## Opaque Double-sided

닫힌 Opaque Mesh에서 `Cull Off`를 켜면 내부 Back Face도 Draw 후보가 된다.

```text
Camera Outside
→ Front Face Color·Depth
→ Back Face는 Depth Fail 가능
```

Front-to-Back 순서와 Early-Z가 잘 동작하면 Back Fragment Shader를 줄일 수 있다.

그래도 Primitive Rasterization, Depth Test와 Geometry 관련 비용이 추가될 수 있다.

Mesh 내부를 볼 일이 없다면 `Cull Back`이 더 적절하다.

---

## Transparent Double-sided

Transparent Material은 일반적으로 ZWrite를 끄고 Blend한다.

```text
Cull Off Transparent Shell
├─ Back Face Blend
└─ Front Face Blend
```

앞뒤 Face가 모두 같은 Pixel에 처리되어 Overdraw가 증가한다.

유리, Hair와 Smoke Mesh는 Triangle 정렬 문제까지 더해져 시각 Artifact가 생길 수 있다.

실제로 양면이 필요한 Surface만 Cull Off를 사용하고 내부 Face를 별도 Mesh로 설계할지 비교한다.

---

## Plane은 한쪽에서 사라진다

Plane은 두께가 없고 Triangle가 한 방향만 향한다.

```text
Front View  → Visible
Back View   → Culled
```

`Cull Back` 상태에서 Plane 뒤쪽이 사라지는 것은 Mesh 오류가 아니라 Face 방향 판정 결과다.

양쪽에서 보여야 한다면 다음 방법을 선택할 수 있다.

```text
Cull Off Material
또는
반대 방향 Triangle를 가진 실제 Back Surface 추가
또는
두께가 있는 Mesh 사용
```

---

## 실제 두께와 양면 Rendering

종이, 잎과 천에 실제 두께를 만들면 앞·뒤 Surface를 별도 Geometry로 표현할 수 있다.

```text
Thin Solid Mesh
├─ Front Surface
├─ Back Surface
└─ Edge Surface
```

각 면에 다른 Material, Normal과 UV를 줄 수 있지만 Vertex·Triangle 수가 증가한다.

Cull Off Plane은 Geometry가 적지만 양쪽 Lighting을 Shader에서 처리해야 한다.

Silhouette와 Edge가 중요한지에 따라 선택한다.

---

## Normal을 뒤집는 양면 Lighting

Back Face를 단순히 보이게만 하면 기존 Normal이 뒤쪽 Lighting에 맞지 않을 수 있다.

```text
Front Face Normal  ↑
Back View에서도   ↑ 유지
→ Light 반응이 뒤집혀 보일 수 있음
```

Back Face에서 Normal을 반전하는 방식이 필요할 수 있다.

```hlsl
normalWS *= isFrontFace ? 1.0 : -1.0;
```

실제 Shader Syntax와 Front Face Semantic은 Pipeline·Shader Model에 맞춰 사용한다.

Cull Off만 설정한다고 Two-sided Lighting이 자동으로 자연스러워지는 것은 아니다.

---

## Front Face Semantic

Fragment Shader는 현재 Fragment가 Front Face에서 왔는지 나타내는 Semantic을 받을 수 있다.

```hlsl
bool isFrontFace : SV_IsFrontFace;
```

Unity Shader Library Macro와 플랫폼 호환 Layer를 사용하는 경우 해당 Pipeline의 예제를 따른다.

```text
Front Face
→ Original Normal

Back Face
→ Flipped Normal 또는 별도 처리
```

Normal Map의 Tangent Space까지 함께 반전해야 하는지 Material 모델에 따라 검토한다.

---

## URP Lit의 Render Face

URP Lit Material Inspector의 Render Face 설정은 Front·Back·Both Face Rendering을 선택한다.

```text
Render Face
├─ Front
├─ Back
└─ Both
```

ShaderLab의 Cull Mode와 연결되는 Material Surface Option이다.

`Both`는 Foliage·Cloth처럼 양면이 필요한 Material에 사용하지만 Shadow, Depth와 다른 Pass도 같은 Face 정책인지 확인한다.

Unity Version과 Shader에 따라 표시되는 Option 이름이 다를 수 있다.

---

## Shader Graph의 Render Face

Shader Graph의 Graph Inspector 또는 Target Surface Option에서 Render Face를 지정할 수 있다.

```text
Shader Graph Target
└─ Render Face
   ├─ Front
   ├─ Back
   └─ Both
```

Graph가 생성하는 Forward, Depth, Shadow와 Meta Pass의 Culling 설정에 영향을 줄 수 있다.

Custom Function으로 Normal을 수정할 때 Generated Shader의 Face Semantic과 Pass별 동작을 확인한다.

---

## Normal Map과 Back Face

Tangent Space Normal Map은 Vertex Normal, Tangent와 Bitangent Basis로 World Normal을 구성한다.

```text
TBN
├─ Tangent
├─ Bitangent
└─ Normal
```

Back Face에서 Normal Vector 하나만 반전하면 Tangent Basis의 Handedness와 Normal Map 방향이 어긋날 수 있다.

Pipeline이 제공하는 Two-sided Normal Mode가 있다면 Flip, Mirror와 None 같은 정책을 Material 의도에 맞춰 선택한다.

---

## Double-sided GI

양면 Material가 Baked Lighting과 Global Illumination에 참여할 때 뒷면을 어떻게 취급할지도 중요하다.

```text
Realtime Raster Face
≠ Lightmap Bake Face 정책일 수 있음
```

Mesh Renderer나 Material의 Double-sided GI 설정은 Lightmapper가 Back Face를 고려하는 방식에 영향을 줄 수 있다.

Runtime `Cull Off`와 Lightmap Bake 결과가 자동으로 완전히 같다고 가정하지 않는다.

얇은 Wall과 Leaf의 Light Leak·Dark Backface를 Bake 결과에서 확인한다.

---

## Shadow Caster Pass의 Culling

Color Pass와 Shadow Caster Pass는 서로 다른 Cull 설정을 가질 수 있다.

```text
Forward Pass
→ Cull Back

Shadow Caster Pass
→ Cull Back 또는 별도 설정
```

얇은 Plane이 한쪽 Light 방향에서 Shadow를 만들지 못하거나 Bias 문제로 Face Culling을 조정할 수 있다.

Shadow Pass에서 `Cull Front`를 사용하면 Peter Panning과 Acne Trade-off가 달라질 수 있다.

Material의 Color 결과만 보고 Shadow Geometry를 판단하지 않는다.

---

## Depth Prepass의 Culling

Depth Prepass가 Color Pass와 다른 Face를 기록하면 Depth 불일치가 발생할 수 있다.

```text
Depth Pass: Cull Back
Color Pass: Cull Off
```

Back Face Color Fragment가 Depth Buffer와 예상하지 않은 관계를 만들 수 있다.

Custom Shader를 만들 때 Forward, DepthOnly, DepthNormals와 ShadowCaster Pass의 Cull Mode를 일관되게 설계한다.

필요한 차이가 있다면 이유와 시각 결과를 명확히 검증한다.

---

## Depth Normals Pass

SSAO와 Screen Space Effect는 Depth Normals Texture를 사용할 수 있다.

양면 Material의 Back Face가 Depth Normals Pass에서 제외되면 Color에는 보이지만 SSAO·Outline에는 빠질 수 있다.

```text
Color Buffer → Back Face 있음
Depth Normal → Back Face 없음
```

Generated Shader와 Renderer Feature가 어떤 Pass를 요구하는지 Frame Debugger에서 확인한다.

---

## Motion Vector Pass

TAA와 Motion Blur는 Motion Vector Pass를 사용할 수 있다.

양면 Cloth의 Back Face가 Color Pass에는 보이지만 Motion Vector에 기록되지 않으면 Temporal Artifact가 나타날 수 있다.

```text
Pass Consistency
├─ Forward
├─ Depth
├─ DepthNormals
├─ MotionVectors
└─ ShadowCaster
```

Cull Mode 변경은 모든 관련 Pass의 결과를 함께 확인해야 한다.

---

## Negative Scale

Transform Scale 한 축을 음수로 만들면 Object의 Handedness와 Triangle Winding이 반전될 수 있다.

```text
Scale (1, 1, 1)
→ Original Winding

Scale (-1, 1, 1)
→ Mirrored Geometry
→ Face 방향 반전 가능
```

거울 대칭을 만들기 위해 Negative Scale을 사용했더니 외부 Face가 Culled되는 문제가 생길 수 있다.

Unity가 Transform Determinant를 고려해 일부 Rendering State를 보정할 수 있지만 Batching, Custom Draw와 Shader 경로에서 결과를 검증해야 한다.

---

## Negative Determinant

Transform의 3×3 Linear 부분 Determinant 부호는 Coordinate System의 방향 반전을 나타낸다.

```text
det(M) > 0
→ Orientation 유지

det(M) < 0
→ Orientation 반전
```

Scale 축 중 홀수 개가 음수이면 Determinant가 음수가 될 수 있다.

Face Culling뿐 아니라 Normal·Tangent 변환과 Mesh Collider·Physics 결과도 확인한다.

가능하면 DCC Tool에서 Mirror를 적용하고 Transform Scale을 정규화한 Asset을 사용한다.

---

## 뒤집힌 Triangle Index

Procedural Mesh를 생성할 때 Triangle Index 순서를 잘못 지정하면 Mesh가 한쪽에서 사라진다.

```csharp
int[] triangles =
{
    0, 1, 2,
    0, 2, 3
};
```

순서를 반대로 바꾸면 Face 방향도 반전된다.

```csharp
int[] reversed =
{
    0, 2, 1,
    0, 3, 2
};
```

정확한 Front 방향은 Vertex Position과 Unity Mesh Convention을 Scene View에서 확인한다.

---

## RecalculateNormals는 Winding을 고치지 않는다

`Mesh.RecalculateNormals()`는 Triangle과 Vertex Data를 이용해 Lighting Normal을 다시 계산한다.

```text
RecalculateNormals
→ Normal Attribute 갱신
→ Triangle Index 순서 유지
```

뒤집힌 Winding 때문에 Face가 Culled되는 문제는 Triangle Index 순서를 수정해야 한다.

Normal만 뒤집으면 Lighting은 바뀌어도 Rasterizer의 Front·Back 판정은 그대로다.

---

## Import된 Mesh의 Face 문제

DCC Tool에서 Negative Scale, Mirror와 Normal 편집 상태가 Apply되지 않으면 Unity Import 후 Face 방향이 예상과 다를 수 있다.

```text
DCC 확인
├─ Face Orientation
├─ Applied Transform
├─ Normals
├─ Tangents
└─ Non-manifold Geometry
```

Material를 Cull Off로 바꿔 문제를 숨기기보다 Asset의 Winding과 Normal을 먼저 수정한다.

불필요한 양면 Rendering 비용도 방지할 수 있다.

---

## 비정상 Geometry

Zero-area Triangle, 겹친 Face와 Non-manifold Edge는 Face 판정과 Lighting Artifact를 만들 수 있다.

```text
Degenerate Triangle
v0, v1, v2가 같은 Line 위
→ Screen Area 0에 가까움
```

Rasterizer가 Degenerate Primitive를 제거할 수 있지만 Vertex와 Index Data는 남는다.

Mesh Validation과 DCC Cleanup으로 불필요한 Geometry를 제거한다.

---

## Camera가 Mesh 내부에 있을 때

닫힌 Room Mesh 내부에 Camera가 있지만 Face Normal이 바깥을 향하면 내부 Wall이 Back Face로 판정될 수 있다.

```text
Outside-facing Room Shell
┌────────────────┐
│ Camera ●       │
└────────────────┘

내부에서 Wall이 사라질 수 있음
```

Room 내부 Surface를 별도 Mesh로 만들거나 Winding을 안쪽으로 향하게 하고 필요하면 두께를 준다.

Cull Off는 빠른 해결처럼 보이지만 외부와 내부 Face를 모두 그린다.

---

## Skybox와 Inverted Sphere

Sphere 내부에서 Sky를 보여 주려면 Camera가 Sphere 안쪽 Back Face를 봐야 한다.

```text
Camera inside Sphere
→ Cull Front
→ 내부 Back Face 표시
```

일반 Sphere의 외부 Front Face를 제거하면 내부 Surface만 Rendering할 수 있다.

Unity Skybox는 전용 Pipeline과 Shader를 사용하지만 Inverted Sphere 기반 Dome Effect에서 같은 원리를 활용한다.

---

## Outline Shell

Inverted Hull Outline은 원본 Mesh를 Normal 방향으로 확장하고 Front Face를 Cull한다.

```text
Original Mesh
+ Expanded Backface Shell
→ 외곽 부분만 Outline처럼 보임
```

```shaderlab
Cull Front
```

Shell의 뒤쪽 Face만 남겨 원본 Object 외부로 튀어나온 영역을 표시한다.

Concave Mesh, Hard Edge와 Screen Thickness에서 Artifact가 생길 수 있다.

---

## Volume Rendering

Camera가 Volume 밖에 있을 때 Front Surface부터 Ray March를 시작하고 안에 있을 때 Back Surface가 필요할 수 있다.

```text
Volume Box
├─ Front Face Entry
└─ Back Face Exit
```

Pass마다 `Cull Back` 또는 `Cull Front`를 선택해 Entry·Exit Position을 Render Target에 기록할 수 있다.

Backface Culling은 단순 최적화뿐 아니라 Rendering Algorithm의 일부로 사용된다.

---

## Water와 얇은 Surface

Water Plane은 위에서만 보이는 Surface라면 Cull Back을 사용할 수 있다.

Camera가 물 아래로 이동해야 한다면 아래쪽 Face Rendering과 Normal·Refraction 처리가 필요하다.

```text
Above Water
→ Front Face

Underwater
→ Back Face 또는 별도 Underwater Pass
```

Cull Off 하나로 처리할지 위·아래 Material를 분리할지 Effect 품질과 비용을 비교한다.

---

## Foliage

Leaf와 Grass는 얇은 Card 양쪽에서 보여야 하는 경우가 많다.

```text
Leaf Card
→ Cull Off
→ Two-sided Normal 처리
→ Alpha Clip
```

Card가 대량으로 겹치면 Back Face Fragment와 Alpha Clip Overdraw가 증가한다.

Camera가 주로 한쪽에서 보는 Grass Blade는 Mesh 방향과 Curve를 조정해 Cull Back을 사용할 가능성도 검토한다.

LOD에서 먼 Foliage의 양면 정책을 단순화할 수 있다.

---

## Hair Card

Hair Card는 Camera 방향과 Animation에 따라 양쪽이 보일 수 있다.

```text
Hair Cost
├─ Cull Off
├─ Alpha Clip 또는 Transparent
├─ 많은 Layer
└─ Complex Lighting
```

양면 Rendering과 Overdraw가 결합해 Pixel 비용이 커진다.

Card 배치, Alpha Coverage와 LOD에서 Layer 수를 줄이는 편이 단순 Shader 최적화보다 효과적일 수 있다.

---

## Cloth

Flag와 Cape는 얇은 Mesh가 접히며 양쪽이 Camera에 보인다.

Culled Face가 Animation 중 바뀌므로 Cull Off가 필요할 수 있다.

```text
Cloth Front·Back
→ 다른 Color·Normal·Roughness 필요 가능
```

한 Shader에서 Front Face Semantic으로 양쪽 Material 특성을 다르게 처리하거나 실제 두께 Mesh를 사용할 수 있다.

Shadow와 Motion Vector Pass의 양면 결과도 확인한다.

---

## Sprite와 Billboard

Sprite Renderer와 Particle Billboard는 보통 Camera를 향하도록 Geometry가 생성된다.

```text
Billboard
→ Camera-facing
→ Cull Back으로 충분할 수 있음
```

World Space에서 자유롭게 회전하거나 Camera가 뒤로 이동할 수 있으면 Back Face가 노출될 수 있다.

Particle Renderer Alignment와 Material Cull Mode를 실제 Camera 경로에서 확인한다.

습관적으로 모든 Particle를 Cull Off로 만들지 않는다.

---

## Two-sided Shadow

얇은 Leaf가 Light 반대 방향을 향해도 Shadow를 만들어야 자연스러울 수 있다.

```text
Camera Face 설정
vs
Light Shadow Face 설정
```

Shadow Caster에서 양면 Geometry를 사용하면 Shadow Map Triangle Coverage가 증가한다.

Distance와 LOD별로 Foliage Shadow Casting을 제한하고 Contact Shadow나 Blob 방식과 비교한다.

---

## Backface Culling과 Overdraw

Cull Off 상태의 Back Face가 Front Face와 같은 Screen Pixel을 덮으면 Overdraw가 증가한다.

```text
Pixel
├─ Back Face Fragment
└─ Front Face Fragment
```

Opaque는 Depth가 일부 비용을 줄일 수 있지만 Transparent는 두 Layer가 모두 Blend될 수 있다.

Overdraw View에서 Double-sided Material 영역을 확인하고 Cull Mode On·Off GPU 시간을 비교한다.

---

## Backface Culling과 Vertex 비용

Backface Culling은 Vertex Shader 이후 Face Orientation을 판단하므로 Culled Triangle의 Vertex Shader 비용을 완전히 제거하지 않는다.

```text
Mesh Draw
→ 모든 필요한 Vertex 처리
→ Back Triangle Cull
```

Vertex Bound Mesh에서 Cull Back을 켜도 기대보다 GPU 시간이 적게 줄 수 있다.

Fragment Bound·Overdraw Scene에서는 Rasterization과 Pixel 절감 효과가 더 클 수 있다.

---

## Triangle 수 통계는 그대로일 수 있다

Profiler의 Triangle 통계가 Draw에 제출된 Primitive 수를 기준으로 하면 Backface Culling 후 실제 Rasterized Triangle 감소가 직접 나타나지 않을 수 있다.

```text
Submitted Triangles
≠ Rasterized Front Triangles
```

Frame Debugger Draw 정보만 보고 Backface 제거량을 계산하기 어렵다.

GPU Vendor Counter의 Culled Primitives, Rasterizer Input·Output과 Fragment Invocation을 확인할 수 있다.

---

## Mobile Tile GPU

Mobile에서도 Rasterization 전에 Back Face를 제거하면 Tile의 Fragment·Depth·Blend 작업을 줄일 수 있다.

Foliage와 Particle의 Cull Off가 넓은 Screen Coverage를 만들면 Memory와 전력 Budget에 민감하다.

```text
Mobile Test
├─ Cull Back
├─ Cull Off
├─ Overdraw
├─ GPU ms
└─ Visual Difference
```

Desktop에서 차이가 작아도 Mobile Target에서는 의미 있는 차이가 날 수 있다.

---

## XR

Left Eye와 Right Eye는 서로 다른 View Position을 가진다.

한 Eye에서 경계에 있는 Triangle가 다른 Eye에서는 Orientation과 Coverage가 조금 다를 수 있다.

Rasterizer는 Eye별 Projection 결과에 맞게 Face를 판정한다.

Custom Stereo Geometry, Negative Scale과 Single Pass Instanced Shader에서 Front Face Semantic이 올바르게 전달되는지 확인한다.

양면 Foliage와 Transparent Layer는 두 Eye에서 Pixel 비용이 반복된다.

---

## Scene View에서 Face 확인

Mesh가 특정 방향에서 사라지면 다음을 확인한다.

```text
1. Material Render Face
2. Transform Negative Scale
3. Mesh Triangle Winding
4. Vertex Normal 방향
5. Camera가 Mesh 내부인지
6. Pass별 Cull Mode
```

Scene View를 Mesh 앞뒤로 이동하고 Wireframe·Shaded Mode를 비교한다.

Normal Visualization과 DCC Face Orientation Display도 함께 사용한다.

---

## Frame Debugger

Frame Debugger에서 선택한 Draw의 Material, Shader Pass와 Cull State를 확인한다.

```text
확인 Pass
├─ ForwardLit
├─ DepthOnly
├─ DepthNormals
├─ ShadowCaster
└─ MotionVectors
```

Color Pass는 Both Face인데 Shadow Pass는 Back Face만 사용하는 등 Pass별 차이를 찾는다.

Draw가 존재해도 특정 Triangle가 Rasterizer에서 Culled됐는지는 Event 목록만으로 모두 보이지 않을 수 있다.

---

## RenderDoc

GPU Capture의 Rasterizer State에서 Cull Mode와 Front Face Convention을 확인할 수 있다.

```text
Rasterizer State
├─ Cull Mode
├─ Front Counter Clockwise
├─ Fill Mode
├─ Depth Clip
└─ Scissor
```

Mesh Viewer에서 Post-VS Geometry와 Triangle Orientation을 확인한다.

Pixel History는 Front·Back Face가 실제 Pixel에 기여했는지 분석하는 데 도움을 준다.

---

## A/B Test

동일 Material에서 Cull Back과 Cull Off Variant를 비교한다.

```text
Test A
Cull Back

Test B
Cull Off
```

다음 조건을 고정한다.

```text
Camera
Resolution
Object 수
Material Feature
Lighting
Shadow
Animation Frame
```

GPU Pass 시간, Fragment Invocation과 시각 차이를 기록한다.

Cull Off가 실제로 필요한 Camera Angle도 함께 Capture한다.

---

## Material 분리 전략

같은 Shader를 사용하는 모든 Object가 양면일 필요는 없다.

```text
Material A
→ Cull Back
→ Trunk·Rock·Closed Mesh

Material B
→ Cull Off
→ Leaf·Cloth·Hair
```

Material가 나뉘면 Batch와 State Change가 증가할 수 있지만 불필요한 양면 Fragment를 줄인다.

Screen Coverage, Object 수와 Batching 손익을 함께 측정한다.

---

## 최적화 순서

```text
1. 뒤집힌 Winding·Negative Scale 오류 수정
2. 닫힌 Mesh는 Cull Back 유지
3. 실제 양면이 필요한 Asset만 분류
4. Plane에 두께 Mesh가 필요한지 비교
5. Two-sided Normal·Tangent 처리 확인
6. Forward·Depth·Shadow Pass Cull 일관성 확인
7. Transparent 양면 Layer 최소화
8. Foliage·Hair LOD에서 Card 수 축소
9. Cull Back·Off A/B GPU Profile
10. Target Device와 모든 Camera Angle 검증
```

Object가 사라지는 Import 오류를 Cull Off로 가리는 습관을 피한다.

---

## 흔한 오해

### Backface Culling은 Object 뒤에 있는 다른 Object를 제거한다

다른 Object의 가림이 아니라 각 Triangle가 Camera 반대 방향을 향하는지 판정한다.

### Vertex Normal이 뒤를 향하면 Culled된다

Rasterizer Face 판정은 일반적으로 Triangle Winding을 사용하며 Lighting Normal과 별개다.

### Normal을 뒤집으면 Winding도 바뀐다

Normal Attribute만 바뀌고 Triangle Index 순서는 그대로다.

### Cull Off는 단순히 양쪽을 보이게 할 뿐 비용 차이가 없다

Back Face Rasterization, Fragment, Depth와 Blend 작업이 추가될 수 있다.

### Cull Off는 항상 정확히 두 배 느리다

Screen Coverage, Depth, Transparency와 Shader에 따라 증가량이 달라진다.

### 닫힌 Opaque Mesh에서 Backface Culling이 모든 Back Vertex를 제거한다

Face 판정은 Vertex Shader 이후일 수 있어 Vertex Processing은 남는다.

### RecalculateNormals가 뒤집힌 Face를 고친다

Winding 문제는 Triangle Index 순서를 수정해야 한다.

### Cull Off를 켜면 Back Face 조명도 자동으로 맞다

Normal과 Tangent Basis를 Two-sided Lighting에 맞게 처리해야 할 수 있다.

### Color Pass가 양면이면 Shadow도 자동으로 양면이다

Shader Pass마다 Cull State가 다를 수 있다.

### Negative Scale은 위치만 Mirror한다

Transform Handedness와 Winding, Normal 방향에 영향을 줄 수 있다.

### Backface Culling은 Frustum·Occlusion Culling을 대체한다

Triangle 방향만 제거하며 Offscreen·Occluded Renderer Draw는 별도 기법이 처리한다.

---

## 최종 체크리스트

```text
□ Triangle Winding과 Vertex Normal을 구분했는가?
□ Procedural Mesh의 Index 순서가 일관적인가?
□ Cull Back·Front·Off의 제거 대상을 확인했는가?
□ 닫힌 Opaque Mesh에 Cull Off를 사용하지 않는가?
□ Plane이 실제로 양쪽에서 보여야 하는가?
□ Cull Off의 Back Face Overdraw를 측정했는가?
□ Transparent Shell의 앞뒤 Blend를 확인했는가?
□ Back Face Normal을 Lighting에 맞게 반전했는가?
□ Normal Map Tangent Basis도 올바른가?
□ URP Lit·Shader Graph Render Face 설정을 확인했는가?
□ Double-sided GI와 Runtime Cull 설정을 구분했는가?
□ Forward·Depth·DepthNormals Pass의 Cull Mode가 맞는가?
□ Shadow Caster가 필요한 Face를 Rendering하는가?
□ Motion Vector Pass에 양면 Geometry가 필요한가?
□ Transform에 Negative Scale이 있는가?
□ DCC Tool에서 Mirror와 Transform을 Apply했는가?
□ RecalculateNormals로 Winding 문제를 숨기지 않았는가?
□ Camera가 Mesh 내부에 들어가는 상황이 있는가?
□ Foliage·Hair·Cloth의 LOD에서 양면 비용을 줄였는가?
□ Frame Debugger에서 Pass별 Rasterizer State를 확인했는가?
□ Cull Back·Off A/B Test의 GPU ms를 비교했는가?
□ Mobile·XR Target에서 Screen Coverage를 검증했는가?
```

---

## 정리

Backface Culling은 Camera 반대 방향을 향하는 Triangle을 Winding Order로 판정해 Rasterization 전에 제거하는 Primitive 단위 기법이다.

Triangle Index 순서가 Face 방향을 결정하며 Vertex Normal은 Lighting에 사용하는 별도 Data이므로 Normal만 뒤집어도 Culling 결과는 바뀌지 않는다.

`Cull Back`은 일반적인 닫힌 Mesh의 뒷면을 제거하고 `Cull Front`는 내부 Shell과 특수 Pass에 사용하며 `Cull Off`는 앞뒤 Face를 모두 Rendering한다.

양면 Rendering은 Foliage, Hair, Cloth와 얇은 Plane에 필요할 수 있지만 Back Face Fragment, Depth와 Transparent Blend Overdraw를 추가한다.

Cull Off에서 자연스러운 조명을 얻으려면 Front Face Semantic을 이용해 Normal·Tangent Basis를 처리하고 Forward, Depth, Shadow와 Motion Vector Pass의 Face 설정을 맞춰야 한다.

Negative Scale, 뒤집힌 Procedural Index와 잘못 Import된 Mesh는 외부 Surface가 사라지는 원인이므로 Cull Off로 숨기지 말고 Winding과 Transform을 수정한다.

Scene View와 Frame Debugger·RenderDoc으로 Face와 Pass State를 확인하고 Cull Back·Off A/B Test를 통해 Target Device에서 실제 Rasterization·Fragment 절감 효과를 검증해야 한다.
