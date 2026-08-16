---
title: "[Unity 렌더링] 12-2. LOD Group은 어떻게 동작할까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - LOD
  - LODGroup
  - Optimization
permalink: /programming/unity-12-2-how-lod-group-works/
toc: true
toc_sticky: true
date: 2026-08-16
last_modified_at: 2026-08-16
---

Unity의 `LOD Group`은 Object가 Camera 화면에서 차지하는 상대 크기를 계산해 사용할 Renderer 집합을 선택한다.

```text
Screen Relative Height
      │
      ├─ 60% 이상 → LOD0
      ├─ 25% 이상 → LOD1
      ├─ 10% 이상 → LOD2
      └─ 10% 미만 → Culled
```

Camera와 가까울 때는 높은 Detail Mesh를 표시하고 작게 보일수록 단순한 Mesh로 전환한다.

LOD Group은 Mesh를 자동으로 단순화하는 Component가 아니라 미리 준비한 Renderer를 어떤 화면 크기에서 사용할지 결정하는 선택기다.

---

## LOD Group이 관리하는 것

하나의 LOD Group은 여러 LOD Level과 각 Level에 속한 Renderer 배열을 가진다.

```text
LOD Group
├─ LOD0
│  ├─ Body_High
│  └─ Hair_High
├─ LOD1
│  ├─ Body_Mid
│  └─ Hair_Mid
├─ LOD2
│  └─ Character_Low
└─ Culled
```

현재 Screen Relative Height가 어느 구간에 있는지 계산해 해당 Level의 Renderer를 Rendering 후보로 사용한다.

LOD Group에 속하지 않은 Renderer는 Level 전환과 관계없이 계속 활성 상태로 남을 수 있다.

---

## LOD Group이 하지 않는 것

LOD Group을 추가한다고 High-poly Mesh에서 Low-poly Mesh가 자동 생성되지는 않는다.

```text
LOD Group 역할
→ Renderer 선택

Mesh Simplification 역할
→ DCC Tool·Importer·별도 Tool
```

LOD0, LOD1과 LOD2 Mesh·Material은 Artist나 Asset Pipeline이 준비해야 한다.

자동 Simplification Tool을 사용해도 Silhouette, UV, Normal과 Animation 결과를 별도로 검수한다.

---

## Screen Relative Height

LOD 선택의 핵심 값은 Object가 화면 높이에서 차지하는 비율이다.

```text
Screen Relative Height
≈ Projected Object Height
  ─────────────────────
       Screen Height
```

Object가 화면 세로의 절반을 차지하면 약 `0.5`, 10%를 차지하면 약 `0.1`로 생각할 수 있다.

실제 Unity 계산에는 LOD Group의 Size, Reference Point, Transform Scale, Camera Projection과 Quality LOD Bias가 반영된다.

---

## 왜 절대 거리를 사용하지 않을까?

같은 거리에서도 Object World Size가 다르면 화면 크기가 다르다.

```text
20m 거리 Building
→ 화면의 80%

20m 거리 Pebble
→ 화면의 1%
```

Building은 높은 Detail가 필요하지만 Pebble은 낮은 LOD나 Cull이 가능하다.

Screen Relative Height를 사용하면 Object Size와 Camera Projection을 함께 반영할 수 있다.

---

## Perspective Camera에서의 계산 관계

Perspective Camera에서는 Object가 멀어질수록 투영 높이가 작아진다.

```text
Projected Height
∝ Object Size
  ───────────
    Distance
```

FOV가 좁으면 같은 Object가 화면에 크게 보이고 FOV가 넓으면 작게 보인다.

```text
Narrow FOV → LOD0를 더 오래 유지 가능
Wide FOV   → Low LOD로 일찍 전환 가능
```

LOD Group은 단순 World Distance보다 Camera Projection에 가까운 기준을 사용한다.

---

## Orthographic Camera에서의 계산 관계

Orthographic Camera에서는 같은 World Size의 Object가 거리에 따라 작아지지 않는다.

```text
Near □
Far  □
→ Projected Size 동일
```

Orthographic Size를 키워 Zoom Out하면 Object의 Screen Relative Height가 작아져 낮은 LOD로 전환할 수 있다.

```text
Orthographic Size 증가
→ World View 범위 증가
→ Object Screen 비율 감소
```

거리 대신 Camera Zoom이 LOD 선택에 큰 영향을 준다.

---

## LOD0 Threshold

LOD Bar의 첫 Threshold는 LOD0에서 LOD1로 넘어가는 Screen Relative Height를 나타낸다.

```text
1.0                 0.0
│──── LOD0 ────│──── LOD1 ────│──── LOD2 ────│ Cull
```

값이 큰 Threshold에 가까울수록 Object가 화면에서 조금만 작아져도 다음 LOD로 전환한다.

LOD0를 너무 오래 유지하면 Vertex·Shader 비용이 커지고 너무 빨리 바꾸면 가까운 거리에서 Detail 감소가 보인다.

---

## Threshold 순서

LOD Level은 높은 Screen Relative Height에서 낮은 값 순서로 배치한다.

```text
LOD0: 0.60
LOD1: 0.25
LOD2: 0.08
Cull: 0.02
```

이는 예시이며 Asset마다 적절한 값은 다르다.

큰 Building과 작은 Prop에 같은 Threshold를 복사해도 LOD Group Size가 다르면 실제 Distance는 달라진다.

Scene View Preview와 Target Camera에서 전환 위치를 확인한다.

---

## 마지막 Threshold와 Cull

가장 낮은 LOD 아래에는 Culled 구간이 있다.

```text
LOD2 Threshold 0.03

Relative Height >= 0.03
→ LOD2

Relative Height < 0.03
→ Culled
```

이 구간에서는 LOD Group에 등록된 Renderer가 Rendering되지 않는다.

Landmark와 Gameplay Object는 먼 거리에서도 필요할 수 있으므로 Cull Threshold를 무조건 높이지 않는다.

---

## LOD Group의 Size

LOD Group은 Object 크기를 나타내는 Size 값을 사용한다.

```text
LOD Group Bounds
├─ Local Reference Point
└─ Size
```

Size가 실제 Renderer 범위보다 크면 Object를 화면에서 크게 평가해 High LOD를 오래 유지할 수 있다.

Size가 너무 작으면 실제 Geometry가 크게 보이는데도 Low LOD로 일찍 전환할 수 있다.

Renderer 구성을 바꾼 뒤 Bounds를 다시 계산해야 하는 이유다.

---

## Local Reference Point

Local Reference Point는 LOD Group의 크기와 Camera Distance를 평가하는 중심 위치다.

```text
Object Root
└─ Local Reference Point ●
```

Pivot가 Geometry 중심에서 멀리 떨어져 있거나 여러 Renderer가 한쪽으로 치우치면 Reference Point를 조정해야 할 수 있다.

Camera가 Object 주변을 이동할 때 LOD 전환 거리가 비대칭으로 보이지 않는지 확인한다.

---

## Recalculate Bounds

Inspector의 Recalculate Bounds 기능은 등록된 Renderer를 기준으로 LOD Group의 Bounding Region을 다시 계산한다.

```text
LOD Renderer 추가·삭제
→ Recalculate Bounds
→ Local Reference Point·Size 갱신
```

Runtime API의 `RecalculateBounds()`도 Renderer Bounds에서 Group Bounds를 다시 계산한다.

매 Frame 호출할 기능이 아니라 LOD 구성이 바뀌었을 때 사용하는 비용 있는 작업으로 이해한다.

Skinned Animation와 GPU Deformation의 최대 범위까지 자동으로 완벽히 반영한다고 가정하지 않는다.

---

## Bounds가 어떤 Renderer를 기준으로 할까?

LOD Group은 Level에 등록된 Renderer의 Bounds를 이용해 Group Size를 구성할 수 있다.

LOD마다 Mesh 범위와 Pivot가 크게 다르면 전환 순간 Object 위치나 크기가 튀어 보인다.

```text
LOD0 Bounds
┌─────────────┐

LOD1 Bounds
   ┌───────┐
```

각 LOD Mesh의 World Scale, Pivot, Skeleton과 Silhouette 범위를 일치시킨다.

---

## Transform Scale의 영향

LOD Group Root의 Scale이 바뀌면 World Space Size도 달라진다.

```text
Root Scale 1
→ Size S

Root Scale 2
→ World Size 2S
```

큰 Instance는 같은 Distance에서 화면을 더 많이 차지하므로 High LOD를 더 오래 사용한다.

Non-uniform Scale과 Parent Scale이 Screen Size 계산과 Bounds에 어떤 결과를 만드는지 Scene에서 확인한다.

Scale이 극단적으로 다른 Prefab Instance에 동일 Threshold를 사용해도 화면 기준이므로 합리적인 전환을 기대할 수 있다.

---

## Renderer 배열

각 LOD Level은 하나 이상의 Renderer를 가진다.

```text
LOD0 Renderers
├─ Body High
├─ Hair High
├─ Equipment High
└─ Decal High

LOD1 Renderers
├─ Body Mid
└─ Equipment Mid
```

Far LOD에서 Hair와 Decal을 제거하거나 Body에 합쳐 Renderer 수를 줄일 수 있다.

Level 사이에 같은 Renderer가 실수로 중복 등록되지 않았는지 확인한다.

---

## Renderer가 Level에 등록되지 않은 경우

LOD Group Hierarchy 아래에 있어도 자동으로 모든 Renderer가 제어되는 것은 아니다.

```text
LOD Root
├─ LOD0 Mesh  → 등록됨
├─ LOD1 Mesh  → 등록됨
└─ Accessory   → 미등록
```

Accessory가 미등록 상태면 모든 거리에서 계속 Rendering될 수 있다.

항상 보여야 하는 Gameplay Indicator라면 의도적일 수 있지만 High-detail Accessory라면 설정 오류다.

Frame Debugger에서 거리별 Draw를 확인한다.

---

## 다른 LOD Group에 중복 등록

Renderer 하나를 여러 LOD Group이 제어하면 어떤 Group이 활성 상태를 결정하는지 복잡해진다.

```text
Parent LOD Group
└─ Renderer R

Child LOD Group
└─ Renderer R
```

Nested LOD Group과 HLOD 전환을 설계할 때 Renderer Ownership을 명확히 한다.

일반 Object는 하나의 LOD Group에만 등록하는 구조가 관리하기 쉽다.

---

## LOD Renderer의 활성 상태

LOD Group은 선택되지 않은 Renderer를 해당 Camera Rendering에서 제외하도록 관리한다.

이를 GameObject의 일반적인 `SetActive` 전환과 동일하게 보면 안 된다.

```text
LOD Selection
→ Rendering Renderer Set 변경

GameObject Lifecycle
→ Script·Physics·Audio 상태와 별개
```

낮은 LOD로 전환해도 High LOD GameObject의 Script와 Collider가 자동으로 중단된다고 가정하지 않는다.

---

## MeshRenderer LOD

Static Prop는 LOD Level마다 별도 MeshRenderer와 MeshFilter를 둘 수 있다.

```text
Rock_LOD0
├─ MeshFilter High
└─ MeshRenderer

Rock_LOD1
├─ MeshFilter Mid
└─ MeshRenderer
```

Material를 공유하면 Batching과 Instancing을 유지하기 쉽다.

Far LOD Material를 단순화하면 Draw State가 달라질 수 있으므로 CPU·GPU 손익을 비교한다.

---

## SkinnedMeshRenderer LOD

Character는 LOD마다 다른 Skinned Mesh를 같은 Skeleton에 연결할 수 있다.

```text
Skeleton
├─ Body_LOD0 SkinnedMeshRenderer
├─ Body_LOD1 SkinnedMeshRenderer
└─ Body_LOD2 SkinnedMeshRenderer
```

Bone Weight, Bind Pose와 Bounds가 일치해야 전환 시 Pose가 튀지 않는다.

낮은 LOD Mesh만 바꿔도 Animator Bone Update는 남을 수 있다.

Reduced Bone Skeleton과 Animation LOD는 별도 System이 필요할 수 있다.

---

## Renderer Material 수

LOD0가 Submesh 5개, LOD2가 Submesh 1개라면 Triangle뿐 아니라 Draw 수도 줄 수 있다.

```text
LOD0
5 Materials → 여러 Draw

LOD2
1 Baked Material → 한 Draw 가능
```

Far Texture Atlas와 Baked Material를 만들면 CPU Submission과 State Change를 줄일 수 있다.

추가 Texture Memory와 Asset 제작 비용을 고려한다.

---

## Fade Mode None

Fade를 사용하지 않으면 Threshold를 넘는 Frame에 Renderer Set가 즉시 바뀐다.

```text
Frame N   → LOD0
Frame N+1 → LOD1
```

추가 Transition Draw가 없어 비용은 가장 단순하다.

LOD Mesh 차이가 작고 전환이 충분히 멀리서 일어나면 Pop이 거의 보이지 않을 수 있다.

가능하면 Mesh 품질과 Threshold로 Pop을 줄이고 Fade가 꼭 필요한 Asset에만 추가한다.

---

## Fade Mode Cross Fade

Cross Fade는 전환 구간에서 이전과 다음 LOD를 점진적으로 교체한다.

```text
Transition Start
LOD0 100% · LOD1 0%

Middle
LOD0 Dither A · LOD1 Dither B

End
LOD0 0% · LOD1 100%
```

Opaque Mesh에서는 Alpha Blend보다 Dither Pattern과 LOD Fade 값으로 Pixel을 Clip할 수 있다.

전환 중 두 Renderer가 Draw되어 Geometry와 Fragment 비용이 증가할 수 있다.

---

## Fade Transition Width

Cross Fade Mode에서 각 LOD Level의 Transition 구간 폭을 지정할 수 있다.

```text
LOD1 Range
│────────────────────────│
              │── Fade ──│
```

폭이 넓으면 Pop은 부드러워질 수 있지만 이중 Draw 구간이 길어진다.

폭이 너무 좁으면 Dither가 잠깐 나타나고 Pop 완화 효과가 작다.

Object 이동 속도와 Camera 속도를 기준으로 시간상 몇 Frame 동안 Fade되는지 확인한다.

---

## Animate Cross-fading

Animate Cross-fading을 사용하면 LOD 전환을 일정 시간에 걸쳐 진행할 수 있다.

```text
Threshold 통과
→ Time-based Fade 시작
→ Cross-fade Animation
→ 다음 LOD 완료
```

사용하지 않으면 Screen Position과 Transition Width를 기준으로 Fade가 결정될 수 있다.

정확한 Inspector 동작과 전역 Duration Property는 Unity Version 문서를 기준으로 확인한다.

시간 기반 전환은 Camera가 멈춰도 완료되지만 빠른 Threshold 왕복에서 상태 관리가 필요하다.

---

## CrossFadeAnimationDuration

`LODGroup.crossFadeAnimationDuration`은 Animate Cross-fading의 전역 전환 시간을 제어한다.

```csharp
LODGroup.crossFadeAnimationDuration = 0.35f;
```

Static Property이므로 한 Group만이 아니라 관련 LOD Group 전체에 영향을 줄 수 있다.

전환 시간을 길게 하면 이중 Rendering이 오래 유지된다.

Gameplay Camera 속도와 Target Frame Budget을 기준으로 값을 정한다.

---

## SpeedTree Fade Mode

SpeedTree Mode는 Tree LOD 전환에 특화된 방식이다.

```text
High Tree Mesh
→ Simplified Tree
→ Billboard
```

Geometry Position을 Morph하거나 Tree Shader의 LOD Data를 이용해 형태 변화를 완화할 수 있다.

일반 Mesh가 같은 방식으로 자연스럽게 전환된다고 가정하지 않는다.

SpeedTree Asset·Shader와 Pipeline 호환성을 확인한다.

---

## unity_LODFade

Shader는 Unity가 제공하는 LOD Fade 값을 이용해 전환을 처리할 수 있다.

```hlsl
float fade = unity_LODFade.x;
```

정확한 Component와 범위는 Unity Shader Variables 문서를 기준으로 사용한다.

Dither Pattern과 Fade 값으로 일부 Fragment를 Clip해 두 LOD가 점진적으로 바뀌는 것처럼 만든다.

Custom Shader가 LOD Cross Fade Keyword와 값을 처리하지 않으면 Inspector에서 Fade를 켜도 원하는 결과가 나오지 않을 수 있다.

---

## LOD_FADE_CROSSFADE Keyword

Cross Fade를 지원하는 Shader Pass는 관련 Keyword와 Dither Logic을 포함해야 한다.

```text
Material·Shader
├─ LOD Fade Keyword
├─ Dither Function
└─ unity_LODFade Data
```

URP Shader Library와 Lit Shader가 제공하는 구현을 참고한다.

Forward Pass만 Fade되고 Depth·Shadow Pass가 즉시 전환되면 Silhouette와 Shadow Pop이 남을 수 있다.

---

## Dither Cross-fade와 TAA

Dither Pattern은 일부 Pixel을 Frame 또는 Screen Pattern에 따라 제거한다.

```text
LOD0 Pattern  █ ░ █ ░
LOD1 Pattern  ░ █ ░ █
```

TAA가 Dither를 시간적으로 누적해 더 부드러운 Fade처럼 보이게 할 수 있다.

반대로 Motion Vector와 History가 맞지 않으면 Ghosting과 Pattern Artifact가 생길 수 있다.

TAA On·Off와 Mobile AA 방식에서 전환 품질을 각각 확인한다.

---

## Shadow Cross-fade

LOD Mesh가 전환되면 Shadow Silhouette도 바뀐다.

```text
Color LOD0 → LOD1
Shadow LOD0 → LOD1
```

ShadowCaster Pass가 Dither Fade를 지원하지 않으면 Color는 부드럽지만 Shadow가 순간적으로 Pop할 수 있다.

Custom Shader의 Shadow Pass Keyword와 Alpha Clip 동작을 확인한다.

먼 거리에서는 Shadow 자체를 끄는 방식과 비교한다.

---

## LOD Bias

Quality Setting의 `LOD Bias`는 LOD Group이 평가하는 상대 크기에 배율로 영향을 준다.

```text
높은 LOD Bias
→ Object를 더 크게 평가
→ High Detail LOD를 더 오래 유지

낮은 LOD Bias
→ Low Detail LOD로 더 일찍 전환
```

Project의 모든 LOD Group에 넓게 영향을 줄 수 있으므로 Device Quality Level별로 조정한다.

개별 Asset의 잘못된 Threshold를 전역 Bias로 숨기지 않는다.

---

## Maximum LOD Level

Quality Setting의 Maximum LOD Level은 높은 Detail Level 일부를 전역적으로 제외할 수 있다.

```text
Maximum LOD Level 0
→ LOD0부터 허용

Maximum LOD Level 1
→ LOD0 Skip 가능
→ LOD1부터 사용
```

정확한 이름과 방향은 Unity Version의 Quality Settings를 확인한다.

저사양 Device에서 Memory와 Geometry를 줄일 수 있지만 가까운 Hero Asset 품질도 낮아질 수 있다.

---

## LOD Group의 Quality 설정 영향

같은 Prefab과 Camera Distance에서도 Quality Level이 다르면 선택 LOD가 달라질 수 있다.

```text
High Quality
LOD Bias 2.0
→ LOD0

Low Quality
LOD Bias 0.7
→ LOD1·2 가능
```

Editor의 현재 Quality Level과 Player Platform별 Default Quality를 확인한다.

개발 PC에서 보인 전환 거리와 Mobile Build가 다를 수 있다.

---

## Scene View LOD Preview

LOD Group을 선택하면 Inspector의 LOD Bar와 Scene View Preview를 이용해 Level을 확인할 수 있다.

```text
Camera 이동
→ Current LOD Highlight
→ Threshold Distance 확인
```

Scene View Camera FOV와 Game Camera FOV가 다르면 실제 Gameplay 전환 거리와 다를 수 있다.

Game Camera Preview와 Target Aspect Ratio에서 다시 확인한다.

---

## LOD Bar의 색

Inspector LOD Bar는 각 Level이 차지하는 Screen Relative Height 범위를 색 영역으로 표시한다.

```text
LOD0 | LOD1 | LOD2 | Culled
```

영역 경계를 Drag해 Threshold를 조절할 수 있다.

색 영역의 화면상 폭은 Relative Height Scale을 시각화한 것이며 World Distance를 직접 의미하지 않는다.

Object Size와 Camera Projection에 따라 실제 거리로 환산된 결과가 달라진다.

---

## Renderer 추가와 제거

LOD Level을 선택한 뒤 Renderer를 Drag하거나 Add·Remove하여 구성할 수 있다.

```text
LOD1
├─ Add Body_Mid Renderer
├─ Add Weapon_Mid Renderer
└─ Hair Renderer 제외
```

Renderer를 빼면 해당 Level에서만 보이지 않을 수 있다.

다른 Level이나 LOD Group 밖에서 계속 Rendering되지 않는지 Hierarchy와 Frame Debugger를 확인한다.

---

## LOD Level 추가와 삭제

LOD 단계가 너무 적으면 Level 사이 Geometry 차이가 커져 Pop이 보일 수 있다.

단계가 너무 많으면 Mesh·Material Memory, 전환 관리와 제작 비용이 증가한다.

```text
단계 수 결정
← Screen Size 변화
← Mesh Simplification 곡선
← Camera 이동 속도
← Asset 중요도
```

각 단계가 구분 가능한 성능 절감을 제공하는지 확인한다.

---

## SetLODs API

Runtime이나 Editor Tool에서 `SetLODs`로 LOD 배열을 지정할 수 있다.

```csharp
LOD[] levels =
{
    new LOD(0.6f, lod0Renderers),
    new LOD(0.25f, lod1Renderers),
    new LOD(0.08f, lod2Renderers)
};

lodGroup.SetLODs(levels);
lodGroup.RecalculateBounds();
```

Threshold는 높은 값부터 내림차순으로 구성하고 Renderer Array의 Null·중복을 검증한다.

Runtime에 자주 호출하기보다 Prefab 제작 Tool과 초기화 단계에 사용한다.

---

## GetLODs API

현재 LOD 구성을 읽어 검사하거나 수정할 수 있다.

```csharp
LOD[] levels = lodGroup.GetLODs();
```

반환 Array를 수정한 뒤 실제 Component에 반영하려면 `SetLODs`를 다시 호출해야 한다.

대량 Prefab 검사 Tool에서 다음 오류를 찾을 수 있다.

```text
Renderer 누락
Threshold 역순
Null Renderer
LOD0보다 무거운 LOD1
마지막 Cull 기준 누락
```

---

## ForceLOD API

`ForceLOD`는 자동 Screen Size 선택 대신 특정 Level을 강제로 사용할 수 있다.

```csharp
lodGroup.ForceLOD(1);
```

자동 선택으로 되돌리는 값은 Unity API 문서의 Convention을 확인한다.

다음 용도에 유용하다.

```text
LOD 품질 비교
Screenshot Capture
Performance A/B Test
Photo Mode
Debug Menu
```

Release Gameplay에서 Debug Force 상태가 남지 않도록 관리한다.

---

## ForceLOD의 Camera 영향

강제 LOD는 Camera Screen Size 선택을 무시하므로 가까이에서도 Low LOD, 멀리에서도 LOD0를 사용할 수 있다.

```text
Force LOD0
→ Camera 거리와 무관하게 High Detail
```

여러 Camera가 같은 LOD Group을 볼 때도 강제 상태가 적용될 수 있다.

Main Camera 진단을 위해 Force했는데 Reflection과 Shadow 비용까지 바뀔 수 있으므로 Frame 전체를 확인한다.

---

## Cross-fade API 구성

`fadeMode`, `animateCrossFading`과 각 `LOD.fadeTransitionWidth`를 조합한다.

```csharp
lodGroup.fadeMode = LODFadeMode.CrossFade;
lodGroup.animateCrossFading = false;

LOD[] levels = lodGroup.GetLODs();
levels[0].fadeTransitionWidth = 0.1f;
lodGroup.SetLODs(levels);
```

Unity Version에 맞는 Namespace와 Enum을 사용한다.

Custom Tool은 Fade Mode가 None인데 Width만 설정하는 무효 구성을 경고할 수 있다.

---

## 자동 LOD Prefab 검사

Editor Tool에서 Project의 LOD Group를 순회해 규칙을 검사할 수 있다.

```text
검사 규칙 예
├─ LOD0 Renderer 존재
├─ Threshold 내림차순
├─ Null Renderer 없음
├─ Level 간 중복 Renderer 없음
├─ Triangle 수 감소
├─ Material 수 증가하지 않음
├─ Bounds 유효
└─ 마지막 Cull Threshold 범위
```

모든 Asset에 동일 Triangle Ratio를 강제하지 않고 규칙 위반 후보를 Artist가 검토하도록 만든다.

---

## LOD Import Naming

DCC Asset에서 `_LOD0`, `_LOD1`, `_LOD2` 같은 Naming Convention을 사용하면 Importer가 LOD Group 구성을 인식할 수 있는 Workflow가 있다.

```text
Tree_LOD0
Tree_LOD1
Tree_LOD2
```

지원되는 Importer와 Naming 규칙은 Unity Version·Asset Format 문서를 확인한다.

자동 구성 후에도 Threshold, Material, Bounds와 Renderer 누락을 검수한다.

---

## Prefab Variant와 LOD

Prefab Variant에서 LOD Renderer를 교체하거나 Threshold를 Override하면 Base Prefab 변경과 충돌할 수 있다.

```text
Base Prefab
→ Common LOD Structure

Mobile Variant
→ Lower Mesh·Aggressive Threshold
```

Quality LOD Bias로 해결할 문제와 Asset 자체 Renderer를 바꿀 문제를 구분한다.

Override가 누락되어 일부 Variant에서 LOD0만 남지 않는지 자동 검사한다.

---

## MaterialPropertyBlock과 LOD

LOD Renderer마다 Color와 Gameplay State를 동일하게 전달해야 할 수 있다.

```text
LOD0 Color = Red
LOD1 Color = Default
→ 전환 시 Color Pop
```

MaterialPropertyBlock, Per-instance Data와 Material Variant를 모든 LOD Renderer에 일관되게 적용한다.

GPU Instancing과 SRP Batcher 호환성이 LOD Level별로 달라지지 않는지 확인한다.

---

## Lightmap과 LOD

Static LOD Mesh가 Lightmap에 참여할 때 LOD Level마다 UV와 Baked Lighting 처리 방식이 필요하다.

```text
LOD0 Lightmap Result
→ LOD1 Geometry·UV로 전환
```

LOD Renderer가 같은 Lightmap Data를 공유하거나 Scale Offset을 전달하는 방식은 Unity Lighting Workflow에 따라 다르다.

전환 시 Light Color, Shadow와 Light Probe 결과가 튀지 않는지 Baked Build에서 확인한다.

---

## Reflection Probe와 LOD

LOD마다 Renderer Bounds와 Material가 바뀌면 Reflection Probe 선택과 Blend 결과도 달라질 수 있다.

```text
LOD0 → Probe A
LOD1 → Probe A·B Blend
```

Anchor Override와 Probe Usage를 LOD Renderer에 동일하게 설정한다.

Specular Highlight가 전환 순간 튀면 Mesh Normal뿐 아니라 Probe·Material 설정을 확인한다.

---

## Motion Vector와 LOD 전환

LOD Mesh Topology가 달라지면 Vertex 간 대응이 없으므로 전환 Frame의 Motion Vector가 불연속적일 수 있다.

```text
LOD0 Vertex Set
≠ LOD1 Vertex Set
```

TAA와 Motion Blur에서 Ghosting이나 Edge가 튀는 현상이 생길 수 있다.

Cross-fade, Motion Vector Pass와 TAA Reset 정책을 실제 Camera Motion에서 검증한다.

---

## LOD와 GPU Instancing

같은 Prefab Instance라도 선택된 LOD가 다르면 Mesh가 달라 별도 Instancing Group이 된다.

```text
Trees LOD0 → Mesh A Instance Draw
Trees LOD1 → Mesh B Instance Draw
Trees LOD2 → Mesh C Instance Draw
```

각 거리 Band에 충분한 Instance가 있으면 여전히 효율적이다.

LOD마다 Material Instance가 생성되거나 Keyword가 달라져 Instancing이 깨지지 않도록 공유 Asset를 사용한다.

---

## LOD와 SRP Batcher

LOD마다 다른 Material를 사용해도 Shader가 SRP Batcher 호환이면 Material State 준비 비용을 줄일 수 있다.

```text
LOD Selection
→ Renderer·Mesh 변경

SRP Batcher
→ 호환 Shader Material Data 재사용
```

두 기능은 서로 다른 CPU 비용을 다룬다.

LOD Material의 Shader Variant와 Constant Buffer 선언이 동일한 호환 구조인지 확인한다.

---

## GPU Resident Drawer와 LOD

Unity 6 URP의 GPU Resident Drawer는 호환 Renderer를 GPU-driven Batch·Culling 경로에서 처리할 수 있다.

LOD Cross-fade와 LOD Group 호환 조건은 Unity Version의 공식 문서를 확인한다.

```text
GPU Resident Data
→ Visibility·LOD 선택
→ Indirect Draw 가능
```

기능 활성화 후 LOD Renderer가 실제 GPU-driven 경로에 포함되는지 Rendering Debug와 Profiler에서 확인한다.

---

## 여러 Camera와 LOD 선택

같은 Object가 Main Camera에는 크게, Reflection Camera에는 작게 보일 수 있다.

```text
Main Camera → LOD0
Reflection  → LOD2가 적합
```

Pipeline이 Camera별로 LOD를 평가할 수 있지만 Renderer State와 Cross-fade가 여러 Camera 사이에서 어떻게 공유되는지 검증해야 한다.

Mini Map는 별도 Layer와 Proxy Renderer를 사용하는 편이 단순할 수 있다.

---

## Scene View가 LOD에 미치는 영향

Scene View Camera도 Object를 Rendering하며 LOD Preview에 영향을 준다.

Game Camera에서 LOD2여도 Scene View에서 가까이 보면 LOD0가 보일 수 있다.

```text
Editor Scene View 결과
≠ Player Camera 결과
```

Profiler와 Visibility Callback을 분석할 때 Scene View Camera를 포함한 Editor Overhead를 고려한다.

최종 LOD 결과는 Player Build에서 확인한다.

---

## LOD Bias와 해상도

LOD Group은 화면 상대 비율을 사용하지만 같은 비율은 Resolution에 따라 실제 Pixel 수가 다르다.

```text
Relative Height 0.1

1080p → 108 Pixels
4K    → 216 Pixels
```

고해상도 Target에서는 Low LOD의 Geometry 부족이 더 잘 보일 수 있다.

LOD Bias, Threshold와 Upscaling Resolution을 Target별로 평가한다.

---

## Dynamic Resolution

내부 Render Scale이 낮아지면 실제 Pixel Detail는 줄지만 Screen Relative Height 계산 기준이 Output·Camera Pixel Size와 어떻게 연결되는지는 Pipeline을 확인해야 한다.

```text
Object Relative Size 동일
Internal Pixels 감소
→ Low LOD로 더 일찍 바꿀 여지
```

기본 LOD Group이 Dynamic Resolution 품질에 자동 적응한다고 가정하지 않는다.

고급 System은 GPU 부하와 Render Scale에 따라 LOD Bias를 동적으로 조정할 수 있지만 전환 Thrashing을 방지해야 한다.

---

## XR에서의 LOD Group

Left·Right Eye의 View Position이 달라 Object Screen Size도 조금 다를 수 있다.

```text
Left Eye  Relative Height A
Right Eye Relative Height B
```

Eye마다 다른 LOD Mesh를 보이면 Stereo 불일치가 생기므로 Conservative한 공통 Level을 선택할 수 있다.

Headset FOV, Eye Texture Resolution과 가까운 Hand·Weapon LOD를 실제 XR Device에서 확인한다.

Cross-fade Dither가 Stereo Eye에서 서로 다르게 보이지 않는지도 검증한다.

---

## Mobile에서의 LOD Group

Mobile Quality Level은 더 낮은 LOD Bias와 Maximum LOD Level을 사용할 수 있다.

```text
Mobile Low
→ LOD1부터 시작
→ 빠른 LOD2 전환
→ 이른 Cull
```

Physical Screen가 작아 Detail 차이가 덜 보일 수 있지만 Display Resolution은 높을 수 있다.

Vertex 절감, Shadow와 Thermal 개선을 장시간 Gameplay에서 측정한다.

LOD 판단 CPU 비용과 추가 Asset Memory도 포함한다.

---

## 전환 Pop 원인 찾기

LOD가 바뀔 때 눈에 띄는 변화의 원인을 분류한다.

```text
Shape Pop
→ Silhouette·Pivot·Scale

Lighting Pop
→ Normal·Tangent·Material·Probe

Texture Pop
→ UV·Mip·Baked Material

Shadow Pop
→ ShadowCaster Mesh·Pass

Animation Pop
→ Skin Weight·Bind Pose·Bone
```

Fade Width만 늘리기 전에 두 LOD Asset Data를 먼저 맞춘다.

---

## Threshold Thrashing

Camera가 Threshold 근처에서 흔들리면 Level이 반복 전환될 수 있다.

```text
0.251 → LOD0
0.249 → LOD1
0.252 → LOD0
```

Cross-fade가 반복 시작되어 두 Renderer가 오래 활성 상태로 남을 수 있다.

Threshold를 Gameplay Camera가 자주 머무는 거리에서 피하고 Camera Noise·Head Bob을 고려한다.

Custom LOD System에서는 Hysteresis를 추가할 수 있다.

---

## Frame Debugger로 확인한다

Camera를 Threshold 전후에 두고 Draw Event를 비교한다.

```text
Check
├─ 선택된 Mesh·Submesh
├─ Material·Shader Pass
├─ Draw Call 수
├─ ShadowCaster LOD
├─ Cross-fade 이중 Draw
└─ 미등록 Renderer 잔존
```

LOD0·LOD1 이름만 믿지 말고 실제 Mesh Vertex·Index와 Material를 확인한다.

Fade Keyword와 Dither Pass가 활성화됐는지도 본다.

---

## Rendering Profiler로 확인한다

`ForceLOD`를 이용해 같은 Camera에서 Level별 통계를 비교한다.

```text
Force LOD0
→ Batches·Triangles·Vertices

Force LOD1
→ 동일 항목 비교

Force LOD2
→ 동일 항목 비교
```

LOD2 Triangle은 줄었지만 Material 수가 늘어 Batches가 증가하는 역전이 없는지 확인한다.

Group 수가 많을 때 LOD Selection CPU 시간도 Profile한다.

---

## GPU Profiler로 확인한다

LOD Level별 Opaque, Depth, Shadow와 Transparent Pass 시간을 비교한다.

```text
LOD0
Opaque 1.0 ms
Shadow 0.6 ms

LOD2
Opaque 0.3 ms
Shadow 0.1 ms
```

숫자는 측정 형식의 예시다.

Mesh Triangle만 줄었는데 Fragment Coverage가 같으면 GPU Pixel 시간 차이가 작을 수 있다.

Far Material와 Shadow 단순화 효과를 분리한다.

---

## LOD Group A/B Test

동일 Scene에서 자동 선택, LOD0 강제와 Fade Off를 비교한다.

```text
Variant A
Automatic + Cross Fade

Variant B
Automatic + Fade None

Variant C
Force LOD0
```

다음 항목을 기록한다.

| Variant | Draws | Triangles | CPU ms | GPU ms | Pop |
|---|---:|---:|---:|---:|---|
| Auto Fade | 900 | 4M | 7.5 | 11.0 | 낮음 |
| Auto None | 820 | 3.5M | 7.2 | 10.4 | 중간 |
| LOD0 | 1200 | 12M | 8.6 | 16.0 | 없음 |

숫자는 예시이며 Target 결과로 Threshold와 Fade를 결정한다.

---

## 설정 순서

```text
1. LOD0·LOD1·LOD2 Mesh와 Material 준비
2. 공통 Root에 LOD Group 추가
3. Level별 Renderer 등록
4. Recalculate Bounds
5. Local Reference Point·Size 검증
6. Screen Relative Height Threshold 조정
7. 마지막 Cull 기준 설정
8. Fade Mode와 Width 선택
9. Quality LOD Bias별 Preview
10. Frame Debugger·Profiler 검증
```

Inspector 설정이 끝나도 실제 Camera Path와 Build에서 전환을 확인해야 한다.

---

## 최적화 순서

```text
1. Level별 Renderer 누락·중복 제거
2. Bounds와 Reference Point 수정
3. LOD Mesh Silhouette·Pivot 정렬
4. Threshold를 실제 Screen 차이에 맞춤
5. Far Level의 Material·Submesh 단순화
6. Shadow·Depth Pass LOD 확인
7. Cross-fade가 필요한 Asset만 선별
8. Quality별 LOD Bias·Maximum Level 조정
9. ForceLOD로 Level별 성능 측정
10. Target Camera에서 Pop·GPU ms 재검증
```

Threshold를 공격적으로 낮추는 것보다 LOD Asset 사이의 시각 차이를 먼저 줄이는 편이 품질 손실을 줄인다.

---

## 흔한 오해

### LOD Group이 Low-poly Mesh를 자동으로 만든다

Component는 준비된 Renderer Set를 선택하며 Mesh 단순화는 별도 제작 과정이다.

### LOD Group은 Camera Distance만 사용한다

Object Size와 Projection을 반영한 Screen Relative Height를 기준으로 선택한다.

### Hierarchy 아래 Renderer는 모두 자동으로 LOD 제어된다

각 Level Renderer 배열에 등록되지 않은 Renderer는 계속 Rendering될 수 있다.

### Recalculate Bounds를 매 Frame 호출해야 한다

LOD 구성이 바뀔 때 Group Bounds를 다시 계산하는 작업이며 일반적인 매 Frame Update 용도가 아니다.

### Cross Fade는 한 Mesh만 그리면서 부드럽게 바꾼다

전환 구간에서 두 LOD Renderer가 동시에 Draw될 수 있다.

### Fade Width가 클수록 무조건 좋다

Pop은 줄 수 있지만 이중 Draw 구간과 Fragment 비용이 길어진다.

### LOD Bias는 개별 Object 설정이다

Quality Setting으로 Project의 많은 LOD Group에 전역 영향을 줄 수 있다.

### ForceLOD는 선택한 Camera에만 적용된다

LOD Group 상태를 강제로 바꾸므로 다른 Camera와 Pass에도 영향을 줄 수 있다.

### LOD Mesh만 바꾸면 Character Animation도 가벼워진다

Animator, Skeleton과 Bone Update는 별도 최적화가 필요할 수 있다.

### LOD2는 항상 LOD1보다 빠르다

Material·Submesh와 Shader가 늘면 Draw·Fragment 비용이 오히려 커질 수 있다.

### Scene View Preview와 Player 결과는 항상 같다

Camera FOV, Quality LOD Bias, Resolution과 Platform 설정이 다를 수 있다.

---

## 최종 체크리스트

```text
□ LOD Group이 Renderer 선택기라는 점을 이해했는가?
□ LOD0·LOD1·LOD2 Mesh를 별도로 준비했는가?
□ Screen Relative Height Threshold가 내림차순인가?
□ World Distance가 아닌 화면 크기로 전환을 검증했는가?
□ Perspective·Orthographic Camera를 모두 고려했는가?
□ Local Reference Point가 Geometry 중심에 적절한가?
□ Group Size가 실제 Renderer 범위를 반영하는가?
□ Renderer 변경 후 Recalculate Bounds를 실행했는가?
□ Level별 Renderer 누락·중복·Null이 없는가?
□ Far LOD에서 Accessory·Decal을 제거했는가?
□ Skinned Mesh의 Skeleton·Bind Pose가 일치하는가?
□ Fade None과 Cross Fade 비용을 비교했는가?
□ Fade Transition Width가 과도하지 않은가?
□ Custom Shader가 LOD Cross Fade를 지원하는가?
□ Depth·Shadow·Motion Vector Pass도 Fade가 맞는가?
□ LOD Bias와 Maximum LOD Level을 Quality별 확인했는가?
□ ForceLOD Debug 상태가 Release에 남지 않는가?
□ LOD별 MaterialPropertyBlock 상태가 일치하는가?
□ Lightmap·Probe·Anchor 설정이 전환 시 튀지 않는가?
□ Instancing·SRP Batcher가 LOD별 유지되는가?
□ Threshold 근처에서 반복 전환하지 않는가?
□ Frame Debugger에서 실제 Mesh·Draw를 확인했는가?
□ ForceLOD별 Triangle·CPU·GPU ms를 측정했는가?
□ Mobile·XR Build에서 전환 품질을 확인했는가?
```

---

## 정리

Unity LOD Group은 Group Size와 Local Reference Point를 Camera에 투영한 Screen Relative Height를 Threshold와 비교해 Level별 Renderer Set를 선택한다.

LOD Group은 Low-poly Mesh를 생성하지 않으므로 각 단계의 Mesh·Material를 미리 준비하고 Renderer 배열에 정확히 등록해야 한다.

Screen Relative Height는 Object World Size, Distance, FOV와 Orthographic Size를 반영하며 Quality LOD Bias가 전역적인 전환 기준에 영향을 준다.

Recalculate Bounds는 Renderer 구성에서 Group Size와 Reference Point를 다시 계산하며 잘못된 Bounds는 너무 이른 전환이나 High LOD 유지의 원인이 된다.

None Mode는 Threshold에서 즉시 전환하고 Cross Fade는 Pop을 줄이는 대신 두 LOD의 Draw·Vertex·Fragment를 Transition 구간에 추가할 수 있다.

`SetLODs`, `GetLODs`, `ForceLOD`와 Fade API로 Tool·Debug를 자동화할 수 있지만 Runtime 반복 호출, 전역 Fade Duration과 다른 Camera 영향을 관리해야 한다.

Frame Debugger로 Level·Pass별 실제 Renderer를 확인하고 `ForceLOD` A/B Test의 Draw·Triangle·CPU·GPU 시간을 Target Camera에서 비교해 Threshold와 Fade를 결정해야 한다.
