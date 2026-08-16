---
title: "[Unity 렌더링] 11-1. 보이지 않는 오브젝트는 왜 그리지 않아야 할까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - Culling
  - Visibility
  - Optimization
permalink: /programming/unity-11-1-why-not-render-invisible-objects/
toc: true
toc_sticky: true
date: 2026-08-16
last_modified_at: 2026-08-16
---

Camera의 최종 화면에 기여하지 않는 Object를 Rendering하면 결과는 같지만 CPU와 GPU 작업은 남을 수 있다.

```text
Object 제출
→ Vertex 처리
→ Rasterization
→ Fragment 처리
→ 최종 화면에는 보이지 않음
```

보이지 않는다는 사실을 Pipeline의 앞 단계에서 판정할수록 Draw 준비, Vertex, Fragment와 Memory 작업을 더 많이 피할 수 있다.

Culling은 화면 결과에 기여할 가능성이 없는 Object를 Rendering 대상에서 제외해 제한된 Frame Budget을 실제로 보이는 장면에 사용하는 과정이다.

---

## 보이지 않는다는 말의 여러 의미

Object가 화면에 보이지 않는 원인은 하나가 아니다.

```text
보이지 않는 Object
├─ Camera Frustum 밖
├─ 다른 Object 뒤에 완전히 가려짐
├─ Camera Culling Mask에서 제외
├─ 너무 멀거나 너무 작음
├─ 반대 방향을 향하는 Triangle
├─ Alpha가 0
├─ Shader에서 clip
└─ 다른 Draw가 나중에 덮음
```

어떤 이유로 보이지 않는지에 따라 제거할 수 있는 Pipeline 단계와 비용이 다르다.

Alpha 0으로 출력하는 것과 Draw 자체를 제출하지 않는 것은 같은 최종 화면을 만들 수 있지만 성능상 같은 동작이 아니다.

---

## 최종 화면은 결과만 보여 준다

한 Object가 최종 화면에 없다고 GPU가 아무 일도 하지 않았다는 뜻은 아니다.

```text
Final Frame
└─ Wall만 보임

실제 Rendering 후보
├─ Wall
├─ Wall 뒤 Character
├─ Wall 뒤 Particle
└─ Wall 뒤 Props
```

Character와 Props가 Wall 뒤에 완전히 가려졌어도 CPU가 Renderer를 수집하고 Draw를 준비했을 수 있다.

Depth Test가 마지막에 Fragment를 제거하더라도 Vertex Shader와 Rasterization 일부 비용은 이미 발생한다.

---

## Rendering Pipeline에서 비용이 발생하는 위치

Object 하나를 그리기 위해 여러 단계가 연결된다.

```text
Scene Object
   │
   ▼
Transform·Animation Update
   │
   ▼
Bounds·Visibility Test
   │
   ▼
Render Queue·Sorting·Batching
   │
   ▼
Draw Submission
   │
   ▼
Vertex Shader
   │
   ▼
Rasterization
   │
   ▼
Fragment Shader·Blend
```

Culling이 적용되는 위치에 따라 아래 단계만 생략할 수 있다.

가능하면 Draw Submission보다 앞에서 불필요한 Renderer를 제거하는 편이 유리하다.

---

## CPU가 Renderer를 찾는 비용

Camera는 Rendering할 후보 Renderer를 수집하고 Visibility를 판정한다.

```text
Camera
→ Scene Renderer 후보 수집
→ Layer·Bounds 확인
→ Visible Set 생성
```

Object 수가 많으면 각 Renderer의 Transform, Bounds, Layer와 상태를 관리하는 CPU 비용이 누적된다.

실제로 보이는 Object가 100개여도 Scene에 관리할 Renderer가 100,000개라면 Visibility 단계 자체가 중요해질 수 있다.

Unity 내부의 공간 자료 구조와 Culling이 모든 Renderer를 단순 순회하는 것보다 효율적으로 후보를 줄일 수 있다.

---

## Sorting 비용

보이는 Renderer는 Render Queue, Material, Depth와 Sorting 기준에 따라 정렬될 수 있다.

```text
Visible Renderers
→ Opaque Sorting
→ Transparent Sorting
→ Draw Order 생성
```

화면에 기여하지 않을 Object가 Visible Set에 남으면 Sorting 대상도 증가한다.

특히 Transparent Object는 Camera 거리 기반 정렬이 필요할 수 있다.

Culling으로 후보 수를 줄이면 Draw뿐 아니라 정렬과 Batch 준비 비용도 줄어들 수 있다.

---

## Draw Call 준비와 제출

CPU는 Material, Shader Pass, Mesh와 Per-object Data를 준비해 GPU Command를 기록한다.

```text
Draw Command
├─ Pipeline State
├─ Material Data
├─ Mesh Buffer
├─ Object Matrix
└─ Rendering Layer Data
```

Object가 화면 밖인데 Draw가 제출되면 GPU가 나중에 Clip할 수 있어도 CPU Command 비용이 남는다.

작은 Draw Call 수천 개에서는 GPU Fragment보다 CPU Submission이 먼저 병목이 될 수 있다.

Renderer 단위 Culling은 GPU에 보내는 Command 수를 줄이는 출발점이다.

---

## Vertex Shader 비용

Draw가 제출되면 Mesh Vertex를 Clip Space로 변환한다.

```text
Object Space Position
→ World Space
→ View Space
→ Clip Space
```

Object가 최종적으로 화면 밖이거나 다른 Object 뒤에 있어도 Culling되지 않았다면 Vertex Shader가 실행될 수 있다.

Skinned Mesh, Morph Target, Wind Animation과 복잡한 Vertex Deformation은 Vertex당 비용을 높인다.

고밀도 Mesh가 보이지 않는 상태에서 계속 Draw되면 Fragment가 없어도 GPU Vertex 시간을 사용할 수 있다.

---

## Primitive Assembly와 Clipping

Vertex 처리 후 GPU는 Triangle을 구성하고 View Volume 경계와 교차하는 Primitive를 Clip한다.

```text
Triangle
├─ Frustum 안 → Rasterize
├─ 경계 교차 → Clip 후 Rasterize
└─ 완전히 밖 → 제거
```

GPU의 Clip 단계가 화면 밖 Triangle을 제거할 수 있지만 CPU Draw Submission과 Vertex Shader 작업은 이미 발생했을 수 있다.

Object Bounds 기반 Frustum Culling을 더 앞에서 수행하는 이유다.

---

## Rasterization 비용

화면 안 Triangle은 덮는 Pixel 위치에 Fragment 후보를 만든다.

```text
Triangle Screen Coverage
→ Fragment 후보 생성
→ Depth·Stencil·Shader 처리
```

다른 Object 뒤에 가려진 Triangle도 Rasterization과 Depth Test 대상이 될 수 있다.

Early-Z가 Fragment Shader를 막아도 Setup과 Depth 관련 작업이 모두 0이 되는 것은 아니다.

Occlusion Culling으로 가려진 Object Draw 자체를 제거하면 해당 Geometry 작업을 더 앞에서 피할 수 있다.

---

## Fragment Shader 비용

Depth와 Culling으로 제거되지 않은 Fragment는 Material Shader를 실행한다.

```text
Fragment Shader
├─ Texture Sample
├─ Normal Mapping
├─ Lighting
├─ Shadow Sample
├─ Reflection
└─ Fog
```

최종 화면에서 다른 Draw에 덮일 Fragment도 먼저 그려지면 이 계산이 발생할 수 있다.

Transparent Object는 ZWrite를 끄는 경우가 많아 Layer마다 Fragment와 Blend가 반복되기 쉽다.

보이지 않는 Layer를 Object 또는 Effect 단위로 제거하면 Overdraw와 Fill Rate 부담을 줄일 수 있다.

---

## Memory Bandwidth 비용

Rendering은 Vertex Buffer, Texture, Depth와 Color Target를 읽고 쓴다.

```text
Memory Traffic
├─ Vertex·Index Read
├─ Texture Read
├─ Depth Read·Write
├─ Color Read·Write
└─ Per-object Data Read
```

보이지 않는 Draw도 Shader와 Blend 단계까지 도달하면 Memory Bandwidth를 사용한다.

Mobile과 Integrated GPU처럼 Bandwidth와 전력 Budget이 제한된 환경에서는 불필요한 Rendering이 더 민감할 수 있다.

---

## Frame Budget 관점

목표 Frame Rate가 높을수록 한 Frame에 사용할 수 있는 시간이 짧다.

```text
30 FPS  → 약 33.3 ms
60 FPS  → 약 16.7 ms
120 FPS → 약 8.3 ms
```

보이지 않는 Object의 0.1ms가 작아 보여도 여러 System과 Camera에서 누적되면 Budget을 넘을 수 있다.

```text
불필요한 Rendering
├─ Main Camera 0.5 ms
├─ Shadow Camera 0.4 ms
├─ Reflection 0.3 ms
└─ UI Camera 0.2 ms
```

화면 결과에 기여하지 않는 작업을 줄이면 실제 품질에 사용할 여유가 생긴다.

---

## Frustum 밖 Object

Camera Frustum은 Camera가 화면에 투영할 수 있는 공간 범위다.

```text
          Far Plane
       ┌────────────┐
Camera ◀              │
       └────────────┘
          Near Plane
```

Frustum 밖의 Object는 현재 Camera 화면에 직접 보일 수 없다.

Unity는 Renderer Bounds와 Camera Frustum을 비교해 Draw 후보에서 제외할 수 있다.

다음 글에서 Frustum Plane과 Bounds Test의 동작을 더 구체적으로 다룬다.

---

## 다른 Object 뒤에 가려진 경우

Frustum 안에 있어도 큰 Wall이나 Terrain 뒤에 완전히 가려질 수 있다.

```text
Camera
  │
  ├─ Wall
  │    └─ House·Character·Props
  └─ 최종 화면에는 Wall만 보임
```

Frustum Culling만으로는 Wall 뒤 Object를 제거할 수 없다.

Occlusion Culling은 잠재적 Occluder와 Camera 위치를 이용해 가려진 Renderer를 Visible Set에서 제외한다.

Occlusion 계산 비용과 Data Memory가 있으므로 모든 Scene에서 자동으로 이득인 것은 아니다.

---

## Backface Culling

닫힌 Mesh의 Camera 반대쪽 Triangle은 일반적으로 보이지 않는다.

```text
Camera → [ Cube ]

앞 Face  → 보임
뒤 Face  → 보통 제거 가능
```

Backface Culling은 Triangle 방향을 기준으로 Rasterization 전에 뒷면을 제거한다.

Object 전체를 제외하는 Frustum·Occlusion Culling과 달리 Mesh 내부 Triangle 단위의 GPU 단계다.

Double-sided Material는 뒷면도 그리므로 Foliage, Cloth와 Hair에서 Fragment와 Overdraw가 늘 수 있다.

---

## Layer Culling

Camera의 Culling Mask는 어떤 Layer의 Object를 Rendering할지 결정한다.

```text
Main Camera
├─ Environment ✓
├─ Character   ✓
├─ UI          ✗
└─ Debug       ✗
```

Camera에 필요하지 않은 Layer를 제외하면 해당 Renderer가 그 Camera의 Draw 목록에 들어가지 않는다.

Mini Map, Reflection과 UI Camera가 모든 Layer를 불필요하게 그리지 않는지 확인한다.

Culling Mask는 GameObject의 Update나 Physics를 중단하는 기능은 아니다.

---

## Distance Culling

작은 Prop와 Particle는 일정 거리 이후 화면에서 의미가 거의 없을 수 있다.

```text
Near  → Full Detail
Mid   → Low LOD
Far   → Culled
```

Camera의 Layer Cull Distance나 Custom Distance Culling으로 특정 Layer를 거리 기준에서 제외할 수 있다.

Near·Far Clip Plane과 달리 Layer별 정책을 적용할 수 있다.

갑작스러운 Pop을 줄이려면 LOD, Fade와 Fog를 조합한다.

---

## 너무 작은 Object

Frustum 안에 있고 가려지지 않아도 화면에서 1 Pixel보다 작게 보이는 Object가 있다.

```text
World Object 1m
→ Camera에서 매우 멂
→ Screen에서 Subpixel 크기
```

Triangle Setup, Vertex와 Draw Submission 비용에 비해 시각적 기여가 작다.

LOD Group의 마지막 Level을 Cull로 설정하거나 Cluster·Impostor로 전환할 수 있다.

빛나는 작은 Object는 Pixel 크기가 작아도 중요할 수 있으므로 단순 거리보다 시각적 중요도를 고려한다.

---

## Near Plane 뒤와 Far Plane 밖

Camera의 Near·Far Clip Plane은 View Volume의 깊이 범위를 결정한다.

```text
Camera
│ Near │──────── Visible Range ────────│ Far │
```

Near보다 가까운 Geometry와 Far보다 먼 Geometry는 Clip된다.

Far Plane을 필요 이상으로 크게 두면 더 많은 먼 Object가 Frustum 후보에 들어오고 Depth Precision도 불리할 수 있다.

반대로 Far를 너무 줄이면 중요한 Object와 Shadow가 갑자기 사라질 수 있다.

---

## Alpha 0은 Culling이 아니다

Material Color나 CanvasGroup Alpha를 0으로 만드는 것은 Object를 투명하게 보이게 한다.

```text
Alpha = 0
→ 최종 Color 기여 없음
→ Draw가 자동으로 사라진다는 보장은 없음
```

Renderer, Particle와 UI Graphic이 제출되면 Vertex, Fragment Shader와 Blend가 실행될 수 있다.

완전히 숨긴 상태가 오래 유지된다면 Renderer나 GameObject, 독립 Canvas를 비활성화해 Rendering 자체를 중단할 수 있는지 검토한다.

재활성화 시 Animation, Layout과 Canvas Rebuild 비용도 함께 측정한다.

---

## Shader clip도 늦은 제거다

Fragment Shader의 `clip` 또는 `discard`는 조건에 맞는 Fragment의 Color Write를 막는다.

```hlsl
clip(alpha - cutoff);
```

하지만 Alpha 값을 얻기 위한 Texture Sample과 Fragment Shader 일부는 이미 실행된다.

Object 전체가 보이지 않는 상황을 Shader에서 Pixel마다 버리는 것은 CPU Draw와 Vertex 비용을 제거하지 못한다.

Object 수준 Visibility를 CPU 또는 GPU Culling 단계에서 먼저 판단하는 편이 더 많은 작업을 줄일 수 있다.

---

## Renderer.enabled

`Renderer.enabled = false`는 해당 Renderer의 화면 Rendering을 끈다.

```text
GameObject 활성
├─ Script Update 가능
├─ Physics 상태 유지 가능
└─ Renderer Draw 중단
```

Object Logic은 유지하면서 Visual만 숨길 때 유용하다.

하지만 Animator, Particle Simulation, Script와 Collider가 자동으로 중단되는 것은 아니다.

Rendering 비용과 전체 Object Update 비용을 구분한다.

---

## GameObject.SetActive

GameObject를 비활성화하면 하위 Component의 동작과 Rendering을 함께 중단한다.

```text
SetActive(false)
├─ Renderer 중단
├─ MonoBehaviour 비활성
├─ Animator 비활성 가능
├─ Collider 비활성
└─ Child Hierarchy 비활성
```

보이지 않을 때 Gameplay 동작도 필요 없다면 더 넓은 비용을 줄일 수 있다.

그러나 빈번한 활성·비활성은 Callback, Layout, Animation State와 Pool 관리 비용을 만들 수 있다.

가시성만을 이유로 모든 Object를 매 Frame SetActive로 토글하지 않는다.

---

## Renderer Culling과 Simulation Culling

Rendering에서 보이지 않는 것과 Simulation이 필요 없는 것은 다른 질문이다.

```text
Renderer Culled
→ 화면 Draw 제외

Simulation Culled
→ Animation·Particle·AI·Physics 갱신 제외 또는 단순화
```

Wall 뒤 Enemy는 보이지 않아도 공격 Logic과 Physics가 필요할 수 있다.

반대로 먼 Background NPC는 Animation Update Rate를 낮추거나 AI를 단순화할 수 있다.

Rendering Culling을 Gameplay 상태 변화로 연결할 때는 시각적 Visibility와 Game Logic 요구를 분리한다.

---

## Animator Culling Mode

Animator는 Renderer가 보이지 않을 때 Animation을 계속 계산할지 Culling Mode로 제어할 수 있다.

```text
Always Animate
→ 보이지 않아도 Animation 갱신

Cull Update Transforms
→ 보이지 않을 때 Transform 갱신 제한

Cull Completely
→ 더 넓은 Animation 계산 중단
```

Root Motion, IK, Gameplay Bone와 Script가 Animation 결과에 의존하면 무조건 Cull할 수 없다.

Renderer Visibility와 Animator 요구를 Character 종류별로 정한다.

---

## Skinned Mesh의 Update When Offscreen

Skinned Mesh Renderer는 화면 밖에서도 Skinning과 Bounds Update가 필요한 상황이 있다.

```text
Update When Offscreen On
→ 보이지 않아도 Skinning Update 가능
```

Ragdoll, Trail, Runtime Bone 수정이나 Camera로 다시 들어올 때 정확한 Bounds가 필요한 경우 사용할 수 있다.

하지만 많은 Character에 켜면 보이지 않는 Skinned Mesh의 CPU·GPU Animation 비용이 남는다.

Bounds가 올바른데도 습관적으로 활성화하지 않는다.

---

## Particle Culling Mode

Particle Renderer가 화면 밖이면 Draw는 제외될 수 있지만 Simulation은 설정에 따라 계속된다.

```text
Always Simulate
→ Offscreen에서도 계속 갱신

Pause
→ 보이지 않을 때 정지

Pause And Catch-up
→ 다시 보일 때 경과 시간 반영
```

Looping Environment Effect와 One-shot Explosion의 요구가 다르다.

Particle가 Gameplay Collision이나 Trigger에 영향을 주는지도 확인한다.

보이지 않는다고 Renderer, Simulation과 Child Effect가 모두 자동 중단된다고 가정하지 않는다.

---

## Audio와 Rendering Visibility

Object가 Camera에 보이지 않아도 Audio Source는 들릴 수 있다.

```text
Wall 뒤 Object
├─ Renderer: Culled 가능
└─ Audio: 계속 필요 가능
```

GameObject 전체를 비활성화하면 Audio도 중단될 수 있다.

Visual Component와 Gameplay·Audio Component를 분리하거나 Distance 기반 정책을 따로 적용한다.

Culling은 화면 기여 여부를 판단하는 Rendering 최적화이며 Object 존재 여부 전체를 결정하는 규칙은 아니다.

---

## Shadow는 Camera 화면 밖에서도 보일 수 있다

Object 자체가 Main Camera Frustum 밖이어도 그 Shadow가 화면 안 Surface에 떨어질 수 있다.

```text
Object        Camera Frustum
  █           ┌────────────┐
   ╲ Shadow → │ Ground     │
              └────────────┘
```

Main Camera에서 보이지 않는다고 Shadow Caster Pass에서도 항상 제거할 수 있는 것은 아니다.

Light의 Shadow Culling Volume과 Shadow Distance가 별도로 적용된다.

Renderer를 완전히 끄면 필요한 Shadow도 사라질 수 있으므로 시각 결과를 확인한다.

---

## Shadow Only Renderer

일부 Effect는 Object Mesh 자체는 보이지 않지만 Shadow만 보이게 설정할 수 있다.

```text
Camera Color Pass → Object 없음
Shadow Map Pass   → Object 있음
```

`Shadows Only` 같은 설정은 Main Color Rendering과 Shadow Rendering의 Visibility가 다름을 보여 준다.

Frame Debugger에서 Main Camera Draw가 없어도 Shadow Caster Draw가 남는지 확인한다.

Shadow가 작고 멀리 있어 구분되지 않으면 Shadow Casting을 거리별로 끄는 방법을 검토한다.

---

## Reflection Camera에서 보일 수 있다

Main Camera에 보이지 않는 Object가 Mirror나 Planar Reflection Camera에는 보일 수 있다.

```text
Main Camera
→ Object Culled

Reflection Camera
→ Object Visible
```

Renderer.enabled를 끄면 모든 Camera에서 사라지지만 Camera Culling Mask는 특정 Camera에서만 제외할 수 있다.

Main, Reflection, Mini Map와 Portal Camera별 Visibility 요구를 나눈다.

Camera 수가 늘면 Culling, Sorting과 Rendering도 Camera마다 반복될 수 있다.

---

## Reflection Probe Culling

Realtime Reflection Probe는 Cubemap의 여섯 Face에서 Scene을 Rendering할 수 있다.

```text
Cubemap
├─ +X
├─ -X
├─ +Y
├─ -Y
├─ +Z
└─ -Z
```

Main Camera에서 보이지 않는 Object도 Probe Culling Mask에 포함되면 Capture 대상이 된다.

Probe에 필요 없는 Layer를 제외하고 Refresh Mode와 Time Slicing을 조정한다.

보이지 않는 Object의 비용은 Main Camera 한 번으로 끝나지 않을 수 있다.

---

## Light Culling과 Object Culling

Object가 Camera에 보이면 영향을 주는 Light를 찾아 Lighting을 계산한다.

보이지 않는 Object를 Renderer Set에서 제외하면 해당 Object의 Lighting과 Shadow Receive 계산도 사라진다.

반면 Light 자체가 화면 밖이어도 Range가 Camera 안 Object에 닿으면 영향을 줄 수 있다.

```text
Light 위치가 화면 밖
→ Range가 Visible Object에 닿음
→ Lighting 기여 가능
```

Transform 위치만으로 Light와 Renderer의 Visibility를 같은 방식으로 판단하면 안 된다.

---

## Bounds가 Culling의 기준이다

Unity는 모든 Triangle을 CPU에서 검사하는 대신 Renderer Bounds를 이용해 Object의 공간 범위를 표현한다.

```text
Mesh Geometry
└─ Axis-aligned Bounds
   ├─ Center
   └─ Extents
```

Bounds가 Frustum과 겹치면 내부 Mesh가 실제로 보이지 않아도 잠재적으로 Visible로 처리될 수 있다.

Bounds가 지나치게 크면 Culling 효율이 떨어지고 너무 작으면 보이는 Geometry가 갑자기 사라진다.

---

## 큰 Bounds의 문제

넓은 Particle System, 결합 Mesh와 긴 Trail은 Bounds가 크게 잡힐 수 있다.

```text
Large Bounds
┌────────────────────────┐
│   실제 Geometry ●      │
└────────────────────────┘
```

Bounds 일부가 Frustum에 걸리면 실제 Geometry가 멀리 있어도 Renderer 전체가 Visible 후보가 된다.

큰 결합 Mesh 하나보다 공간적으로 나뉜 Renderer가 Culling에 유리할 수 있다.

하지만 너무 잘게 나누면 Renderer 수와 Draw Call이 증가한다.

---

## 작은 Bounds의 문제

Vertex Shader가 Geometry를 크게 움직이거나 Skinned Mesh Bone이 Import Bounds 밖으로 나가면 보이는 Vertex가 Bounds 밖에 있을 수 있다.

```text
Bounds 밖으로 변형된 Vertex
→ Bounds는 Frustum 밖 판정
→ 보이는 Mesh가 잘못 Culled
```

Wind, Displacement, Procedural Animation과 GPU Vertex Deformation은 CPU Bounds가 변형 결과를 모를 수 있다.

정확한 Bounds를 설정하되 필요 이상으로 크게 만들지 않는다.

---

## Mesh Combining의 Trade-off

여러 작은 Mesh를 하나로 합치면 Draw Call을 줄일 수 있다.

```text
Before
House A · House B · House C

After
Combined City Mesh
```

하지만 Combined Bounds 일부만 보이면 전체 Mesh가 Draw될 수 있다.

```text
Batch 감소
vs
Culling 단위 확대
```

공간적으로 가까우며 함께 보이는 Object끼리 결합해야 한다.

큰 World를 하나의 Mesh로 합치면 보이지 않는 Geometry까지 Vertex Processing할 수 있다.

---

## Static Batching과 Culling

Static Batching은 같은 Material의 Static Renderer를 효율적으로 그리도록 Geometry를 결합할 수 있다.

Unity의 구현은 원본 Renderer 단위의 Visibility를 고려할 수 있지만 Memory와 Batch 구조에 Trade-off가 있다.

```text
Static Batching
→ Draw Setup 감소 가능
→ Geometry Memory 증가 가능
→ Culling Granularity 확인 필요
```

Frame Debugger와 Rendering Profiler에서 실제 Batch와 Draw 범위를 확인한다.

---

## GPU Instancing과 Culling

같은 Mesh와 Material을 GPU Instancing으로 그리면 여러 Object를 한 Draw로 제출할 수 있다.

```text
Instance Group
├─ Tree 1
├─ Tree 2
├─ Tree 3
└─ Tree N
```

일부 API는 Group Bounds 단위로 Culling하고 Group이 보이면 내부 Instance를 함께 처리할 수 있다.

Indirect Drawing과 GPU-driven Rendering은 Instance별 GPU Culling을 구현할 수 있다.

Batch Size를 크게 만들수록 Submission은 줄지만 Culling Granularity가 거칠어질 수 있다.

---

## LOD와 Culling의 관계

LOD는 거리에 따라 Mesh와 Material 복잡도를 줄이고 마지막 단계에서 Renderer를 제거할 수 있다.

```text
LOD0 → High Detail
LOD1 → Medium Detail
LOD2 → Low Detail
Cull → Draw 없음
```

Frustum 안에 있어도 화면에서 너무 작은 Object를 그리지 않는 정책이다.

LOD Group의 Screen Relative Height, Fade와 마지막 Cull Threshold를 Project Camera에 맞춘다.

다음 Culling 글들과 LOD 주제에서 각 기법의 조건을 더 구체적으로 다룬다.

---

## HLOD와 Impostor

먼 거리의 Building이나 Forest를 개별 Renderer로 유지하는 대신 Cluster Mesh나 Impostor로 대체할 수 있다.

```text
Near
→ 개별 Building 100개

Far
→ Cluster Mesh 1개 또는 Impostor
```

완전히 제거하기 어려운 중요한 Silhouette를 낮은 비용으로 유지한다.

Draw Call과 Vertex는 줄지만 큰 Cluster Bounds와 Texture Memory가 증가할 수 있다.

Distance Culling과 함께 시각 중요도에 맞는 단계를 구성한다.

---

## Portal과 Room 기반 Visibility

실내 Scene은 Room과 Door·Portal 연결을 이용해 보일 수 있는 공간을 제한할 수 있다.

```text
Room A ─ Door ─ Room B ─ Door ─ Room C

Camera in A
→ 닫힌 Door 뒤 C 제외 가능
```

일반 Frustum과 Occlusion Data만으로 처리하기 어려운 구조를 Gameplay 공간 정보로 보완한다.

Door 상태가 Dynamic하게 바뀌면 Visibility Set도 갱신해야 한다.

잘못 제외하면 Object가 사라지는 오류가 발생하므로 보수적인 판정이 필요하다.

---

## Culling의 False Positive와 False Negative

Visibility 판정에는 두 종류의 오류를 생각할 수 있다.

```text
False Positive
→ 안 보이는데 Visible로 판단
→ 성능 손실, 화면은 정상

False Negative
→ 보이는데 Culled로 판단
→ 성능은 줄지만 화면 오류
```

Rendering Culling은 보이는 Object를 잘못 제거하지 않도록 보수적으로 설계하는 경우가 많다.

Bounds가 Frustum과 조금만 겹쳐도 전체 Renderer를 Draw하는 이유다.

최적화는 False Negative를 만들지 않는 범위에서 False Positive를 줄이는 과정이다.

---

## Culling 계산도 무료가 아니다

Object를 그리지 않기 위해 Bounds Test, Occlusion Query, Data Lookup과 Command Compaction을 수행한다.

```text
Culling Cost
vs
Saved Rendering Cost
```

Triangle 두 개짜리 작은 Object 몇 개를 복잡한 정밀 Occlusion Test로 제거하면 계산 비용이 더 클 수 있다.

Object 수, Mesh·Shader 비용, 가려지는 비율과 Camera Movement를 기준으로 손익을 판단한다.

---

## CPU Culling과 GPU Culling

CPU Culling은 Draw Command를 만들기 전에 Object를 제외할 수 있다.

```text
CPU Culling
→ Visible Objects만 Command 생성
```

GPU Culling은 Compute Shader나 GPU Visibility 결과로 Instance와 Indirect Draw를 압축할 수 있다.

```text
GPU Culling
→ 대규모 Instance 병렬 판정
→ Indirect Args 생성
```

GPU Culling은 CPU Readback 없이 Command를 유지해야 효율적이며 Buffer 관리와 Synchronization이 필요하다.

일반적인 Scene에서는 Unity의 기본 Camera Culling부터 올바르게 사용하는 것이 우선이다.

---

## Multi-camera에서 반복되는 Culling

Camera마다 Frustum, Culling Mask와 Position이 다르므로 Visibility 판정도 달라진다.

```text
Main Camera Visible Set
Reflection Camera Visible Set
Mini Map Camera Visible Set
Shadow Camera Visible Set
```

Camera 하나에서는 Culled인 Renderer가 다른 Camera에는 보일 수 있다.

불필요한 Camera는 Culling과 Rendering 전체를 추가하므로 Camera 수, Update Frequency와 Culling Mask를 확인한다.

작은 Mini Map이 Main Scene의 모든 Detail을 그리지 않도록 별도 Layer와 LOD를 사용할 수 있다.

---

## Camera Stack

URP Camera Stack의 Base와 Overlay Camera는 서로 다른 Layer를 그릴 수 있다.

```text
Base Camera
→ World Layer

Overlay Camera
→ Weapon·UI Layer
```

동일 Layer가 여러 Camera에 포함되면 Object가 반복 Rendering될 수 있다.

Overlay Camera의 Culling Mask와 Clear·Depth 요구를 확인한다.

Camera Stack은 Visibility 구성 도구이지 중복 Draw를 자동 제거하는 기능이 아니다.

---

## Occlusion과 Dynamic Object

Baked Occlusion Culling은 Static Occluder와 Occludee Data를 미리 계산한다.

Dynamic Object는 Baked Cell의 Visibility 결과를 이용해 가려질 수 있지만 Dynamic Occluder로서의 역할에는 제한이 있을 수 있다.

```text
Static Building
→ 안정적인 Occluder

움직이는 Truck
→ 항상 같은 Occluder라고 가정하기 어려움
```

문, Elevator와 Moving Wall이 많은 Scene에서는 Bake Data와 Runtime 상태의 차이를 확인한다.

---

## 작은 Occluder의 문제

얇은 Pole이나 작은 Box는 뒤 Object를 아주 잠깐 가린다.

이를 정밀한 Occluder로 포함하면 Occlusion Data와 계산이 늘어날 수 있다.

```text
좋은 Occluder 후보
├─ 큰 Wall
├─ Building
├─ Terrain
└─ 닫힌 Room

나쁜 후보 가능성
├─ 작은 Prop
├─ 얇은 Fence
└─ 움직이는 장식
```

큰 면적으로 안정적으로 가리는 Geometry를 우선한다.

---

## Culling과 Pop-in

거리나 Occlusion 판정이 너무 공격적이면 Object가 갑자기 나타나는 Pop-in이 생긴다.

```text
Frame N   → Object Culled
Frame N+1 → Object Visible
```

Camera 이동 속도, Bounds Margin과 Occlusion Cell 정밀도가 결과에 영향을 준다.

LOD Cross-fade, Dither와 Preload Margin으로 전환을 완화할 수 있지만 추가 Fragment 비용이 생길 수 있다.

성능과 시각 안정성 사이의 균형이 필요하다.

---

## Culling과 Object Streaming

Culling은 현재 Frame에서 그리지 않는 것이고 Streaming은 Asset와 Object Data를 Memory에 Load·Unload하는 것이다.

```text
Culling
→ Draw 제외
→ Memory에는 남을 수 있음

Streaming
→ Scene·Asset Data Load·Unload
→ Memory 사용 변화
```

멀리 있는 지역을 Culled해도 Mesh와 Texture Memory는 그대로일 수 있다.

Open World에서는 Distance Culling, LOD와 Scene·Asset Streaming을 함께 설계한다.

---

## `isVisible`을 Gameplay 판정으로 사용할 때

Renderer의 Visibility Callback이나 `isVisible`은 어떤 Camera에서 Renderer가 필요하다고 판단됐는지와 관련된다.

Scene View Camera, Shadow와 여러 Camera 때문에 Main Gameplay Camera에 보이는 것과 의미가 다를 수 있다.

```text
Renderer.isVisible = true
→ Main Camera에 보임일 수도 있음
→ Scene View Camera 때문일 수도 있음
→ 다른 Camera 때문일 수도 있음
```

Enemy AI와 Gameplay Logic을 단순히 Renderer Visibility에 연결하면 Editor와 Build에서 결과가 달라질 수 있다.

Gameplay Visibility는 명시적인 Camera, Distance와 Line-of-sight 규칙으로 분리하는 편이 안전하다.

---

## Culling 결과 확인

Scene View에서 Camera Frustum과 Renderer Bounds를 표시하면 기본 범위를 확인할 수 있다.

```text
확인 항목
├─ Camera Near·Far Plane
├─ Aspect Ratio
├─ Renderer Bounds
├─ LOD Threshold
├─ Occlusion Area
└─ Culling Mask
```

Occlusion Visualization을 이용하면 Camera Cell에서 어떤 Renderer가 보이는 것으로 판정되는지 확인할 수 있다.

최종 Player Frame은 Frame Debugger와 Profiler로 검증한다.

---

## Frame Debugger

Frame Debugger의 Draw Event 목록에서 보이지 않는다고 생각한 Renderer가 실제로 제출됐는지 확인한다.

```text
질문
├─ Main Camera Color Pass에 있는가?
├─ Shadow Caster Pass에만 있는가?
├─ Reflection Camera가 그리는가?
├─ Depth Prepass에 포함되는가?
└─ 다른 Material Pass가 남아 있는가?
```

Object 이름, Mesh, Material, Render Target와 Camera를 연결해 어느 Rendering 경로에서 비용이 남는지 찾는다.

---

## Rendering Profiler

Rendering Profiler Module에서 Batches, SetPass Calls, Triangle·Vertex와 Renderer 통계를 비교한다.

```text
Before Culling
Draws 1200
Triangles 4.0M

After Culling
Draws 700
Triangles 1.8M
```

Draw 감소가 CPU와 GPU ms 개선으로 이어졌는지는 CPU Timeline과 GPU Profiler에서 별도로 확인한다.

통계 수치만 줄고 Frame Time이 같다면 다른 병목이 제한하고 있을 수 있다.

---

## CPU Profiler

Culling, Sorting, Animation과 Render Submission 관련 Marker를 확인한다.

```text
CPU 후보
├─ Camera.Render
├─ Culling
├─ Render Loop
├─ Animation Update
├─ Particle Update
└─ Script Visibility Logic
```

Custom Culling Script가 모든 Object에 거리 계산을 매 Frame 수행하면 기본 Rendering 절감보다 CPU 비용이 더 커질 수 있다.

Update를 분산하고 Squared Distance, Spatial Partition과 CullingGroup API 같은 대안을 검토한다.

---

## GPU Profiler

Object를 제외하기 전후 Pass별 GPU 시간을 비교한다.

```text
Baseline
Opaque      5.0 ms
Shadow      2.0 ms
Transparent 3.0 ms

Culling 적용
Opaque      3.8 ms
Shadow      1.4 ms
Transparent 2.2 ms
```

숫자는 기록 형식의 예시다.

해당 Renderer가 어느 Pass에 참여했는지에 따라 개선 위치가 달라진다.

Target Device의 동일 Camera와 Frame에서 여러 번 측정한다.

---

## Culling A/B Test

문제 Object Group을 Rendering에서 한 번에 제외해 최대 절감 가능성을 확인한다.

```text
Test A: 전체 Scene
Test B: 가려진 District Renderer Off
Test C: Shadow만 Off
Test D: Reflection Camera에서만 제외
```

그룹 전체 제거로 GPU 시간이 거의 변하지 않으면 해당 Object Rendering은 주요 병목이 아닐 수 있다.

큰 차이가 있으면 Frustum, Occlusion, Distance 또는 LOD 중 올바른 자동화 방법을 선택한다.

---

## Culling 최적화 순서

가장 단순하고 안전한 범위부터 적용한다.

```text
1. Camera Culling Mask 정리
2. Renderer Bounds 오류 수정
3. Frustum Culling 결과 확인
4. LOD와 Distance Culling 구성
5. Shadow·Reflection별 Culling 분리
6. 큰 Static Occluder로 Occlusion Bake 검토
7. Multi-camera 중복 제거
8. Simulation Culling 별도 설계
9. 대규모 Instance는 GPU Culling 검토
10. Target Device에서 A/B Test
```

보이는 Object가 사라지지 않는지 Camera 이동, Animation과 모든 Quality Level에서 확인한다.

---

## 흔한 오해

### 화면에 안 보이면 Unity가 아무 작업도 하지 않는다

Visibility 종류와 Culling 단계에 따라 CPU, Vertex, Shadow와 Simulation 비용이 남을 수 있다.

### Depth Test가 가려진 Object를 완전히 무료로 만든다

Fragment를 제거할 수 있어도 Draw Submission, Vertex와 Rasterization 일부 비용은 이미 발생할 수 있다.

### Alpha 0은 Renderer를 끈 것과 같다

최종 Color만 투명하며 Draw와 Fragment Shader가 계속 실행될 수 있다.

### Renderer를 끄면 Object의 모든 비용이 사라진다

Script, Animation, Physics, Audio와 Particle Simulation은 별도로 남을 수 있다.

### GameObject를 끄는 것이 항상 최선이다

Gameplay Logic과 Audio도 중단되며 잦은 활성화에서 Callback과 Rebuild 비용이 생길 수 있다.

### Frustum Culling이면 Wall 뒤 Object도 제거된다

Frustum 안에 있는 가려진 Object는 Occlusion Culling이나 다른 Visibility 기법이 필요하다.

### Main Camera에 안 보이면 Shadow도 필요 없다

화면 밖 Object의 Shadow가 화면 안 Surface에 들어올 수 있다.

### Mesh를 크게 합치면 항상 빠르다

Draw Call은 줄지만 Bounds가 커져 보이지 않는 Geometry까지 함께 그릴 수 있다.

### Culling은 많을수록 좋다

Visibility Test와 Data 관리 비용이 있으며 작은 저비용 Object에서는 손해가 될 수 있다.

### `Renderer.isVisible`은 Main Camera에 보인다는 뜻이다

Scene View와 다른 Camera를 포함한 어떤 Camera의 Visibility 결과일 수 있다.

### Culling하면 Memory도 해제된다

Draw에서 제외될 뿐 Mesh, Texture와 Object Data는 Memory에 남을 수 있다.

---

## 최종 체크리스트

```text
□ 보이지 않는 원인을 Frustum·Occlusion·Layer·Distance로 구분했는가?
□ Alpha 0과 Draw 제외를 혼동하지 않았는가?
□ CPU Culling·Sorting·Submission 비용을 확인했는가?
□ 보이지 않는 고밀도 Mesh가 Vertex Shader를 실행하지 않는가?
□ Depth Test 이전에 제거할 수 있는 Object인가?
□ Transparent Layer가 가려진 상태로 남아 있지 않은가?
□ Camera Culling Mask가 필요한 Layer만 포함하는가?
□ Layer Cull Distance와 LOD Cull을 검토했는가?
□ Renderer Bounds가 너무 크거나 작지 않은가?
□ GPU Vertex Deformation이 Bounds를 벗어나지 않는가?
□ Mesh Combining이 Culling 단위를 과도하게 키우지 않았는가?
□ Animator와 Skinned Mesh의 Offscreen Update가 필요한가?
□ Particle Culling Mode가 Effect 목적에 맞는가?
□ Renderer를 꺼도 필요한 Audio·Gameplay가 유지되는가?
□ 화면 밖 Shadow Caster가 실제로 필요한가?
□ Reflection·Mini Map·Probe Camera의 Mask를 확인했는가?
□ Camera Stack이 같은 Layer를 중복 Rendering하지 않는가?
□ Occlusion Culling 비용보다 제거 이득이 큰가?
□ Culling과 Streaming을 구분했는가?
□ Frame Debugger에서 실제 Draw 제외를 확인했는가?
□ CPU·GPU Profiler로 전후 시간을 비교했는가?
□ 빠른 Camera와 Animation에서 Pop-in이 없는가?
□ Target Device의 Worst-case Scene에서 검증했는가?
```

---

## 정리

보이지 않는 Object도 Culling되지 않으면 CPU Visibility·Sorting·Draw Submission과 GPU Vertex·Rasterization·Fragment·Memory 작업을 만들 수 있다.

Frustum 밖, 다른 Object 뒤, Layer 제외, 먼 거리, Alpha 0과 Shader Clip은 최종 화면에서 보이지 않는 이유가 서로 다르며 제거되는 Pipeline 단계도 다르다.

Object Bounds 단계에서 Draw 자체를 제외하면 GPU Clip이나 Depth Test처럼 늦은 단계에서 버리는 것보다 더 많은 작업을 피할 수 있다.

Renderer Culling은 Rendering만 중단하며 Animation, Particle, Script, Physics와 Audio 같은 Simulation 비용은 별도 정책으로 관리해야 한다.

Main Camera에 보이지 않아도 Shadow, Reflection, Probe와 다른 Camera에 필요할 수 있으므로 Camera·Pass별 Visibility 요구를 구분한다.

Bounds 크기, Mesh Combining과 Instancing Group은 Draw Call 효율과 Culling Granularity 사이의 Trade-off를 만든다.

Frame Debugger로 실제 Draw와 Pass가 제외됐는지 확인하고 Rendering·CPU·GPU Profiler의 A/B Test를 통해 Target Device에서 절감 효과와 Pop-in을 함께 검증해야 한다.
