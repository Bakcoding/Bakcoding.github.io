---
title: "[Unity 렌더링] 5-6. Render Queue는 왜 필요할까?"
excerpt: "Unity Rendering"
categories:
  - Programming
tags:
  - Unity
  - Rendering
  - RenderQueue
  - Transparency
  - ShaderLab
permalink: /programming/unity-5-6-render-queue/
toc: true
toc_sticky: true
date: 2026-08-15
last_modified_at: 2026-08-15
---

여러 Object가 같은 화면 Pixel에 겹치면 어떤 Object를 먼저 그리는지가 결과와 성능에 영향을 준다.

불투명한 벽은 먼저 Depth를 기록해 뒤의 Object를 가릴 수 있지만, Alpha Blend를 사용하는 유리는 뒤에 그려진 Color를 읽은 뒤 자신의 Color와 섞어야 한다.

```text
Opaque Geometry
먼저 Depth와 Color 기록
↓
Transparent Geometry
기존 Color와 Blend
↓
Overlay Effect
마지막에 출력
```

Unity는 서로 다른 Rendering 성격을 큰 순서 Group으로 나누기 위해 Render Queue를 사용한다.

Render Queue는 Object가 언제 그려질지를 정하는 첫 번째 분류 기준이다.

---

## Render Queue란?

Render Queue는 Renderer의 Material을 Rendering 순서 Group에 배치하는 Integer 값이다.

```text
낮은 Queue Index
먼저 Rendering

높은 Queue Index
나중에 Rendering
```

Unity는 대표적인 Queue에 이름과 기준 Index를 제공한다.

| Queue | 기준 Index | 대표 용도 |
|---|---:|---|
| `Background` | 1000 | 배경 Object |
| `Geometry` | 2000 | 일반 Opaque Geometry |
| `AlphaTest` | 2450 | Alpha Clip Geometry |
| `Transparent` | 3000 | Alpha Blend Transparency |
| `Overlay` | 4000 | 마지막에 그릴 Overlay Effect |

Queue는 개별 Object의 정확한 최종 순서를 모두 결정하지 않는다.

같은 Queue 안에서는 별도의 Sorting 기준이 적용된다.

---

## Render Queue가 필요한 이유

모든 Renderer를 무작위 순서로 그리면 다음 문제가 생길 수 있다.

```text
Transparent를 먼저 Drawing
↓
뒤의 Opaque가 Transparent 결과를 덮어씀
↓
의도한 Blend 결과 손실
```

또는 멀리 있는 Opaque Object를 먼저 그린 뒤 가까운 Object가 계속 덮어쓰면 불필요한 Fragment 처리가 증가할 수 있다.

```text
Render Queue
Surface 종류별 큰 순서 보장
↓
Queue 내부 Sorting
정확성 또는 효율에 맞는 세부 순서
```

Queue는 Rendering 결과와 최적화에 필요한 순서를 동시에 구성한다.

---

## Queue와 Sorting의 차이

Render Queue는 큰 Group을 정하고 Sorting은 그 Group 안의 Renderer 순서를 정한다.

```text
전체 Renderer
↓ Render Queue
Geometry Group
AlphaTest Group
Transparent Group
↓ Sorting
각 Group 안에서 Distance와 State 기준 정렬
```

예를 들어 두 Transparent Object가 모두 Queue 3000이라면 Queue만으로 어느 Object가 먼저인지 알 수 없다.

Camera Distance와 Transparency Sorting 설정 등이 추가로 사용된다.

Sorting의 자세한 규칙은 다음 글에서 다룬다.

---

## Queue는 Shader에 선언할 수 있다

ShaderLab에서는 SubShader의 `Queue` Tag로 기본 Render Queue를 지정한다.

```shaderlab
Shader "Custom/OpaqueExample"
{
    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "Queue" = "Geometry"
            "RenderType" = "Opaque"
        }

        Pass
        {
            // ...
        }
    }
}
```

`Queue` Tag는 개별 Pass가 아니라 SubShader Tag다.

```text
SubShader Tags
Queue, RenderType, RenderPipeline

Pass Tags
LightMode 등
```

위치를 잘못 작성하면 Unity가 의도한 Queue Metadata로 사용하지 못할 수 있다.

---

## Queue와 RenderType은 다르다

두 Tag는 함께 작성되는 경우가 많지만 역할이 다르다.

```shaderlab
Tags
{
    "Queue" = "Transparent"
    "RenderType" = "Transparent"
}
```

```text
Queue
Rendering 순서 Group과 Index

RenderType
Shader를 Opaque, Transparent 등 Category로 식별하는 Metadata
```

`RenderType`을 Transparent로 작성했다고 Queue가 자동으로 모든 경우에 올바르게 바뀐다고 가정하면 안 된다.

Custom Shader에서는 필요한 Tag와 Blend·Depth State를 명시적으로 일치시킨다.

---

## Background Queue

`Background`는 다른 일반 Geometry보다 먼저 그릴 배경 Object에 사용한다.

```shaderlab
Tags
{
    "Queue" = "Background"
}
```

기준 Index는 1000이다.

```text
Background 1000
↓
Geometry 2000
↓
Transparent 3000
```

배경용 Quad, 특수 배경 Effect 등에 사용할 수 있다.

Skybox는 Render Pipeline이 별도 시점에 처리할 수 있으므로 단순히 Background Queue Object와 완전히 같은 흐름이라고 보지 않는다.

---

## Geometry Queue

`Geometry`는 대부분의 Opaque Object에 사용하는 기본 Queue다.

```shaderlab
Tags
{
    "Queue" = "Geometry"
    "RenderType" = "Opaque"
}
```

기준 Index는 2000이다.

Opaque Pass는 일반적으로 다음 State를 사용한다.

```shaderlab
Blend Off
ZWrite On
ZTest LEqual
```

앞의 Object가 Depth를 기록하면 뒤의 Fragment를 Early Depth Test로 제거할 가능성이 생긴다.

그래서 Opaque Queue에서는 정확한 Blend 순서보다 Depth 효율과 State 변경 감소를 고려해 Sorting할 수 있다.

---

## Opaque가 먼저 그려지는 이유

Opaque Object는 뒤의 Color가 필요하지 않다.

가장 가까운 Surface Color가 최종 결과를 덮어쓴다.

```text
Near Opaque
Depth = 2

Far Opaque
Depth = 10
```

Near Opaque를 먼저 그리면 Depth Buffer에 2가 기록된다.

Far Opaque는 Depth Test에서 실패하여 복잡한 Fragment Shader 실행이나 Color Write를 줄일 수 있다.

```text
Front-to-back 가능성
→ Early-Z 효율 증가 가능
```

Opaque Queue가 Transparent보다 먼저 실행되는 것은 뒤의 Blend 대상 Color와 Depth를 준비하는 역할도 한다.

---

## AlphaTest Queue

`AlphaTest`는 Alpha Clip을 사용하는 Geometry에 주로 사용한다.

기준 Index는 2450이다.

```shaderlab
Tags
{
    "Queue" = "AlphaTest"
    "RenderType" = "TransparentCutout"
}

ZWrite On
Blend Off
```

Fragment Shader는 Alpha가 Cutoff보다 작으면 Pixel을 버린다.

```hlsl
half alpha = SAMPLE_TEXTURE2D(
    _BaseMap,
    sampler_BaseMap,
    input.uv
).a;

clip(alpha - _Cutoff);
```

살아남은 Fragment는 일반적인 Opaque처럼 Depth를 기록할 수 있다.

---

## AlphaTest가 Geometry와 분리되는 이유

Alpha Clip Shader는 Texture Sampling과 `clip` 판정 때문에 완전한 Opaque Surface보다 Fragment 처리와 Early Depth 최적화 조건이 복잡할 수 있다.

```text
Solid Opaque 먼저 Drawing
↓
Depth Buffer 채움
↓
AlphaTest Geometry Drawing
↓
가려진 AlphaTest Fragment 작업 감소 가능
```

그래서 AlphaTest Queue는 Geometry 뒤, Transparent 앞에 위치한다.

Alpha Clip Object도 Depth를 기록하므로 일반 Alpha Blend와는 구분된다.

```text
Alpha Clip
Pixel을 완전히 남기거나 제거

Alpha Blend
뒤 Color와 부분적으로 혼합
```

---

## Transparent Queue

`Transparent`는 Alpha Blend를 사용하는 Surface에 주로 사용한다.

기준 Index는 3000이다.

```shaderlab
Tags
{
    "Queue" = "Transparent"
    "RenderType" = "Transparent"
}

Blend SrcAlpha OneMinusSrcAlpha
ZWrite Off
```

Transparent Fragment는 이미 Render Target에 있는 Destination Color와 섞인다.

```text
Result = Source × Source Alpha
       + Destination × (1 - Source Alpha)
```

Destination에 어떤 Object가 먼저 그려졌는지가 결과에 영향을 준다.

---

## Transparent가 나중에 그려지는 이유

유리 뒤에 Opaque 벽이 있다고 가정한다.

```text
Camera → Glass → Wall
```

올바른 순서는 일반적으로 다음과 같다.

```text
1. Wall Color와 Depth 기록
2. Glass Color를 Wall Color와 Blend
```

유리를 먼저 그린 뒤 벽을 Opaque로 그리면 벽이 유리 결과를 덮어쓸 수 있다.

```text
Opaque Queue 완료
↓
Transparent Queue 실행
```

이 큰 순서를 Render Queue가 보장한다.

---

## Transparent가 먼 곳부터 그려지는 이유

두 Transparent Surface가 겹치면 Blend 순서가 결과에 영향을 준다.

```text
Camera → Near Glass A → Far Smoke B → Background
```

일반적인 Back-to-front 순서는 다음과 같다.

```text
Background
↓
Far Smoke B Blend
↓
Near Glass A Blend
```

반대로 그리면 Near Color가 Far Layer에 의해 잘못 섞일 수 있다.

Transparent Queue 안에서는 일반적으로 Camera에서 먼 Renderer부터 가까운 Renderer 순으로 Sorting한다.

이 규칙도 교차하는 Mesh와 하나의 Mesh 내부 Triangle 순서를 완벽히 해결하지는 못한다.

---

## Transparent와 ZWrite Off

일반적인 Transparent Material은 `ZWrite Off`를 사용한다.

첫 Transparent Layer가 Depth를 기록하면 뒤의 Transparent Layer가 완전히 제거되어 Blend되지 않을 수 있기 때문이다.

```text
Near Glass가 Depth Write
↓
Far Smoke Depth Test 실패
↓
Smoke가 Glass 뒤에 보이지 않음
```

ZWrite를 끄면 여러 Layer가 그려질 수 있지만 Overdraw가 증가한다.

```text
Transparent Accuracy
↔ Overdraw와 Sorting 비용
```

특수한 Transparent Depth Prepass나 ZWrite On 기법은 장단점과 Artifact를 따로 검증해야 한다.

---

## Overlay Queue

`Overlay`는 일반 Scene Geometry보다 마지막에 그릴 Effect에 사용한다.

기준 Index는 4000이다.

```shaderlab
Tags
{
    "Queue" = "Overlay"
}
```

Lens Flare와 화면 위 강조 Effect 같은 용도를 생각할 수 있다.

Overlay Queue라고 Depth Test가 자동으로 꺼지는 것은 아니다.

```text
Queue
언제 Draw할까?

ZTest / ZWrite
Depth와 어떻게 상호작용할까?
```

항상 위에 보여야 한다면 Pass의 Depth State도 목적에 맞게 설정해야 한다.

---

## Queue 이름과 Integer

Queue 이름은 내부 Integer 기준값에 대응한다.

```text
Background  = 1000
Geometry    = 2000
AlphaTest   = 2450
Transparent = 3000
Overlay     = 4000
```

중간 Integer도 사용할 수 있다.

```shaderlab
Tags
{
    "Queue" = "Geometry+10"
}
```

이 Queue Index는 2010이 된다.

```text
Geometry 2000
↓
Custom 2010
↓
AlphaTest 2450
```

---

## Queue Offset

기준 Queue에 Offset을 더하거나 뺄 수 있다.

```shaderlab
"Queue" = "Transparent-100"
```

```text
Transparent 3000
- 100
= 2900
```

일반 Transparent보다 먼저 그려야 하는 물이나 특수 Surface에 사용할 수 있다.

Offset은 작은 순서 조정 도구다.

문제를 해결하기 위해 Material마다 임의의 Offset을 계속 추가하면 Queue 구조가 복잡해지고 State Sorting 기회가 줄 수 있다.

---

## Opaque와 Transparent 경계

일반적인 Unity Queue 분류에서 Index 2500 이하와 2501 이상은 Sorting 성격이 달라지는 경계로 사용된다.

```text
Queue ≤ 2500
Opaque 범위

Queue ≥ 2501
Transparent 범위
```

Opaque Range는 Front-to-back과 State 최적화를 고려할 수 있고 Transparent Range는 Distance 기반 Transparency Sorting을 사용한다.

Alpha Blend Material을 2500 이하로 옮기면 기대한 Back-to-front Sorting을 받지 못할 수 있다.

Queue 값만 앞당겨 Draw 순서를 고치는 방식이 새로운 Blend Artifact를 만들 수 있다.

---

## Skybox는 특수한 경우

Skybox는 단순한 일반 Renderer Queue Object와 다른 Pipeline 단계로 처리될 수 있다.

전통적인 순서 설명에서는 Opaque Geometry 뒤와 Transparent Geometry 앞에 그려진다.

```text
Opaque Geometry
↓
Skybox
↓
Transparent Geometry
```

Opaque가 이미 채운 Pixel을 Depth Test로 피하고 빈 배경을 채울 수 있다.

URP의 실제 Camera Background와 Skybox Pass 순서는 Frame Debugger에서 확인한다.

Skybox Material의 Queue 값만으로 전체 실행 시점을 판단하지 않는다.

---

## Material이 Queue를 Override할 수 있다

Shader의 Queue Tag는 기본값을 제공하고 Material은 `renderQueue`를 Override할 수 있다.

```csharp
using UnityEngine;

public class MaterialQueueExample : MonoBehaviour
{
    [SerializeField] private Material targetMaterial;

    private void Start()
    {
        targetMaterial.renderQueue = 3010;
    }
}
```

Shader 기본 Queue로 돌아가려면 `-1`을 사용할 수 있다.

```csharp
targetMaterial.renderQueue = -1;
```

Shared Material의 Queue를 바꾸면 그 Material을 사용하는 모든 Renderer의 순서에 영향을 줄 수 있다.

---

## Material Inspector의 Render Queue

Material Inspector의 Advanced Options 등에서 Render Queue를 지정할 수 있다.

```text
From Shader
Shader의 Queue Tag 사용

Custom
Material별 Integer Override
```

URP Lit·Unlit Material의 Surface Type을 Opaque에서 Transparent로 바꾸면 Shader GUI가 Blend, Depth, Keyword와 Queue를 함께 갱신할 수 있다.

Inspector의 Queue 숫자만 바꾸는 것과 Surface Type 전체를 바꾸는 것은 다르다.

Custom Shader GUI가 State 동기화를 담당하는지도 확인해야 한다.

---

## Queue만 바꾸면 Transparent가 되는가?

아니다.

Opaque Shader의 Queue를 3000으로 옮겨도 Blend가 자동으로 활성화되지는 않는다.

```text
Queue = Transparent
Blend Off
ZWrite On
→ 나중에 그리는 Opaque처럼 동작 가능
```

반대로 Alpha Blend State를 켜고 Queue를 Geometry에 두면 Opaque Sorting Group에서 Blend Object가 처리될 수 있다.

Transparent Surface에는 다음 설정이 함께 일치해야 한다.

```text
Queue
RenderType
Blend State
ZWrite
Shader Keyword
Pipeline Pass
```

---

## Alpha 값만 낮추면 Transparent가 되는가?

Material Color의 Alpha를 0.5로 설정해도 Shader의 Blend State가 Off이면 기존 Color를 덮어쓸 수 있다.

```text
Fragment Output Alpha = 0.5
Blend Off
→ RGB는 그대로 덮어쓸 수 있음
```

Alpha Channel 값과 Alpha Blending은 별개의 조건이다.

```text
Alpha 값
Shader가 출력하는 Data

Blend State
그 Data로 Source와 Destination을 결합하는 규칙
```

Queue까지 Transparent 범위에 맞춰야 일반적인 순서가 적용된다.

---

## Alpha Clip과 Alpha Blend 비교

| 항목 | Alpha Clip | Alpha Blend |
|---|---|---|
| 대표 Queue | AlphaTest 2450 | Transparent 3000 |
| Pixel 결과 | 완전히 유지 또는 제거 | Destination과 부분 혼합 |
| Blend | 보통 Off | 보통 On |
| ZWrite | 보통 On | 보통 Off |
| Sorting | Opaque 계열 | Back-to-front 계열 |
| 대표 용도 | 잎, 철망, Cutout | 유리, 연기, Particle |

잎사귀처럼 중간 투명도가 필요 없는 Surface는 Alpha Clip이 Depth와 Sorting에 유리할 수 있다.

부드러운 반투명이 필요하면 Alpha Blend가 필요하지만 Overdraw와 Sorting Artifact를 고려해야 한다.

---

## URP의 Opaque와 Transparent Pass

URP는 Renderer의 Queue Range를 이용해 Opaque와 Transparent Object를 서로 다른 Render Pass에서 그린다.

```text
DrawOpaqueObjects
Opaque Render Queue Range
↓
Skybox 등 중간 단계
↓
DrawTransparentObjects
Transparent Render Queue Range
```

Material Queue를 Opaque에서 Transparent Range로 옮기면 어느 Pass가 Renderer를 선택하는지도 바뀔 수 있다.

단순 순서뿐 아니라 Depth Texture 생성 시점, Opaque Texture Capture와 Renderer Feature Filtering에도 영향을 줄 수 있다.

---

## Camera Opaque Texture와 Queue

URP가 Camera Opaque Texture를 만들면 Opaque Rendering 결과를 복사한 Texture를 Transparent Shader에서 Sample할 수 있다.

```text
Opaque Objects 완료
↓
Camera Opaque Texture Copy
↓
Transparent Object가 Sample
```

굴절 유리나 물이 이 Texture를 사용할 수 있다.

Object를 Transparent보다 앞의 Queue로 이동하면 Opaque Texture가 Capture되는 시점과 Sample 결과가 달라질 수 있다.

Custom Queue 조정은 Pipeline의 중간 Texture 생성 시점까지 확인해야 한다.

---

## Depth Texture와 Queue

Depth Texture가 어떤 Object를 포함하는지는 Depth Prepass, Copy Depth 시점과 Material의 Depth Pass 지원에 따라 달라진다.

일반 Transparent는 ZWrite를 끄고 Opaque Depth 이후에 그려져 Camera Depth Texture에 포함되지 않을 수 있다.

```text
Opaque Depth
→ Camera Depth Texture

Transparent ZWrite Off
→ Depth에 흔적 없음
```

Transparent Object가 Depth 기반 Fog, Intersection 또는 SSAO에 참여해야 한다면 별도 Depth Pass나 Renderer Feature를 검토할 수 있다.

Queue 숫자만 바꾸는 것으로 모든 Depth 문제를 해결할 수 없다.

---

## Render Objects Renderer Feature

URP의 Render Objects Renderer Feature는 특정 Layer, Queue와 시점의 Object를 별도로 그릴 수 있다.

```text
Feature Filter
├─ Layer Mask
├─ Render Queue Type
├─ Shader Pass
└─ Render Pass Event
```

기본 `DrawOpaqueObjects` 또는 `DrawTransparentObjects` 외의 시점에 Object를 다시 Rendering할 수 있다.

Material Queue가 Feature의 Filter Range 밖이면 대상 Layer가 맞아도 Draw되지 않을 수 있다.

Custom Effect를 진단할 때 Layer와 Queue를 함께 확인한다.

---

## Queue와 LightMode

Queue와 `LightMode`는 서로 다른 Filter다.

```text
Queue
어느 큰 순서 Group에서 Renderer를 처리할까?

LightMode
그 단계에서 Material의 어느 Shader Pass를 사용할까?
```

```text
Transparent Queue Renderer
↓
URP Transparent Render Pass가 선택
↓
UniversalForward Shader Pass 검색
```

Queue가 맞아도 해당 `LightMode` Pass가 없으면 원하는 Draw가 실행되지 않을 수 있다.

반대로 Pass가 있어도 Queue Range Filter 밖이면 현재 Render Pass에서 제외될 수 있다.

---

## Queue와 Camera Culling은 다르다

Camera Culling은 Renderer가 Camera에 보일 후보인지 결정한다.

Render Queue는 Culling을 통과한 Renderer를 어느 순서 Group에서 그릴지 결정한다.

```text
Camera Frustum / Culling Mask
↓
Visible Renderer
↓
Render Queue Filtering
↓
Sorting
↓
Draw
```

Queue를 바꿔도 Camera Frustum 밖의 Object가 보이게 되지는 않는다.

Culling Mask에서 제외된 Layer를 Overlay Queue로 바꿔도 해당 Camera는 그리지 않는다.

---

## Queue와 UI Canvas

Screen Space Overlay Canvas의 UI Rendering은 일반 MeshRenderer의 Overlay Queue와 다른 System 흐름을 사용할 수 있다.

```text
Shader Queue = Overlay
일반 Renderer의 Queue Metadata

Screen Space Overlay Canvas
Canvas System의 화면 출력 순서
```

UI가 항상 마지막에 보인다는 사실만으로 두 구조를 같은 것으로 보면 안 된다.

Screen Space Camera와 World Space Canvas는 Camera, Sorting Layer와 Material Queue의 영향을 다른 방식으로 받을 수 있다.

Canvas Render Mode와 Sorting 설정을 함께 확인한다.

---

## Queue와 Sorting Layer

SpriteRenderer와 Renderer는 Sorting Layer와 Order in Layer를 사용할 수 있다.

```text
Render Queue
Material 기반 큰 순서 Group

Sorting Layer / Order
특정 Renderer 종류와 Sorting 기준에 추가 영향
```

어느 값이 우선하는지는 Render Pipeline의 Sorting Criteria와 Renderer Type에 따라 달라질 수 있다.

Queue만 바꿔 Sprite 순서 문제를 해결하거나 Sorting Layer만 바꿔 Opaque·Transparent Pass 경계를 넘길 수 있다고 가정하지 않는다.

---

## Queue Offset으로 Z-fighting을 해결할 수 있을까?

두 Coplanar Surface의 Queue를 다르게 하면 Draw 순서는 정할 수 있다.

하지만 둘 다 Depth를 같은 값으로 기록하거나 Test하면 Z-fighting이 완전히 해결되지 않을 수 있다.

```text
Queue A 먼저
Queue B 나중
하지만 Depth가 거의 같음
→ ZTest와 Precision 문제 유지 가능
```

Geometry를 실제로 분리하거나 ShaderLab `Offset`, Decal 기법과 Depth State를 목적에 맞게 검토해야 한다.

Queue는 Depth 값을 변경하지 않는다.

---

## Queue Offset 남용의 문제

Material마다 다음과 같은 값이 쌓일 수 있다.

```text
Glass A = 3000
Glass B = 3001
Smoke = 3002
Effect = 3003
Special Glass = 3010
```

처음에는 순서 문제가 해결된 것처럼 보여도 Camera가 반대편으로 이동하거나 Object가 교차하면 고정 Queue 순서가 실제 Depth 관계와 맞지 않을 수 있다.

또한 같은 Shader와 State를 사용하는 Renderer를 연속으로 정렬할 기회가 줄어 SetPass 전환이 증가할 수 있다.

Queue Offset은 전역적으로 고정해야 하는 Layer 관계에 제한적으로 사용한다.

---

## Transparent Sorting Artifact

Renderer 단위 Back-to-front Sorting은 Mesh 내부 Triangle을 개별적으로 완벽히 정렬하지 않는다.

```text
하나의 Transparent Mesh
Triangle A와 B가 교차
↓
Renderer Distance는 하나
↓
Triangle 순서가 View에 따라 잘못될 수 있음
```

두 Transparent Mesh가 서로 관통해도 Camera Distance 기준이 모든 Pixel에 맞지 않을 수 있다.

```text
가능한 대응
Mesh 분리
Geometry 순서 재구성
Alpha Clip 또는 Dither
Depth Prepass
Order-independent Transparency 계열 기법
```

각 방법은 Visual과 성능 Trade-off가 있다.

---

## Premultiplied Alpha와 Queue

Premultiplied Alpha는 RGB에 Alpha가 미리 곱해진 표현과 대응하는 Blend State를 사용한다.

```shaderlab
Blend One OneMinusSrcAlpha
```

일반 Alpha Blend와 Edge 품질 및 Additive 성격의 표현이 달라질 수 있다.

하지만 여전히 Destination Color와 순서에 의존하므로 일반적으로 Transparent Queue와 Sorting 문제가 남는다.

Blend 식이 달라진다고 Queue가 자동으로 변경되지는 않는다.

---

## Additive Material과 Queue

Additive Blend는 Color를 더한다.

```shaderlab
Blend One One
```

```text
Result = Source + Destination
```

수학적으로 일반 Alpha Blend보다 순서 영향이 적은 경우가 있지만 Depth Test, Clamp, Tone Mapping과 다른 Blend Object 관계는 여전히 고려해야 한다.

Particle와 Glow Effect는 Transparent Queue를 사용하는 경우가 많다.

Additive라는 이유만으로 Overlay Queue에 둘 필요는 없다.

---

## Queue와 Shadow

Shadow Map Render Pass는 Camera Color Queue 순서를 그대로 재현하지 않는다.

Shadow Caster를 별도로 Culling하고 `ShadowCaster` Pass를 사용한다.

```text
Camera Color
Render Queue에 따라 Opaque / Transparent 처리

Shadow Map
Shadow Casting 설정과 ShadowCaster Pass로 처리
```

일반 Transparent Material은 Shadow를 만들지 않거나 Alpha Clip 형태의 Shadow를 사용할 수 있다.

Queue를 바꾼다고 ShadowCaster Pass가 자동으로 생기지는 않는다.

---

## Queue와 Batching

서로 다른 Queue의 Renderer는 큰 Render Pass Group이 다르므로 같은 Batch로 묶이기 어렵다.

```text
Material A Queue 2000
Material B Queue 2001

같은 Shader Variant여도
Sorting Group 분리 가능
```

Queue Offset이 많으면 State별 정렬을 방해해 SRP Batch가 짧아질 수 있다.

반대로 정확한 순서를 위해 Queue를 나누는 것이 필요할 수도 있다.

Batch 수보다 Rendering 정확성이 우선이며 불필요한 차이만 제거한다.

---

## Queue와 SetPass Call

Queue는 Draw 순서를 바꾸므로 Shader Pass State 전환 패턴에도 영향을 준다.

```text
Queue 정리 전
Lit → Unlit → Lit → Unlit

State별로 정렬 가능하면
Lit → Lit → Unlit → Unlit
```

Transparent는 Distance 순서가 우선되어 Material State가 자주 바뀔 수 있다.

Queue Offset을 사용해 같은 Material을 무조건 모으면 Blend 결과가 틀릴 수 있다.

SetPass 최적화와 Transparency 정확성 사이에서 실제 요구를 판단한다.

---

## Queue와 성능

Render Queue 자체의 Integer 비교가 큰 비용인 것은 아니다.

Queue 선택이 만드는 Rendering 방식이 비용에 영향을 준다.

```text
Opaque Queue
Depth Write와 Early-Z 활용 가능

Transparent Queue
Back-to-front Sorting
ZWrite Off
Overdraw 증가 가능

Overlay Queue
이미 채워진 화면 위에 추가 Drawing
```

Opaque로 표현할 수 있는 Surface를 불필요하게 Transparent로 만들면 Sorting, Overdraw와 Batching 비용이 증가할 수 있다.

---

## Transparent Overdraw

Transparent는 Depth를 쓰지 않는 경우가 많아 겹치는 모든 Layer의 Fragment가 처리될 수 있다.

```text
Pixel 하나
├─ Smoke Layer 1
├─ Smoke Layer 2
├─ Glass Layer
├─ Particle Layer 1
└─ Particle Layer 2
```

각 Layer가 Texture Sampling과 Blend를 수행하면 GPU Fragment와 Memory Bandwidth 비용이 커진다.

```text
최적화 후보
Particle 크기와 수 감소
불필요하게 겹치는 Layer 제거
낮은 해상도 Buffer
Alpha Clip 또는 Dither 검토
Shader 단순화
```

목표 GPU에서 Overdraw View와 Profiler로 측정한다.

---

## Queue를 선택하는 기준

Surface의 시각적 요구와 Depth 동작을 먼저 정한다.

```text
완전히 불투명
→ Geometry

구멍은 있지만 남은 부분은 불투명
→ AlphaTest

뒤 Color가 비쳐야 함
→ Transparent

Scene보다 앞에 그릴 특수 Effect
→ Overlay 검토

항상 먼 배경
→ Background 검토
```

Queue를 선택한 뒤 Blend, ZWrite, RenderType과 URP Surface 설정이 일치하는지 확인한다.

---

## Custom Queue를 선택하는 기준

기본 Queue 사이에 고정된 Layer 관계가 필요할 때 Offset을 사용할 수 있다.

```text
Opaque World
↓
Water Surface
↓
일반 Transparent Particle
```

하지만 Camera Distance에 따라 순서가 바뀌어야 하는 Object 관계를 고정 Queue로 해결하지 않는다.

```text
고정 Layer 관계
Queue Offset 후보

공간적 앞뒤 관계
Sorting과 Depth 문제로 해결
```

Custom Renderer Feature나 별도 Render Target이 더 명확한 해결책일 수도 있다.

---

## Queue 문제 진단 순서

Object가 잘못된 순서로 보이면 다음 항목을 확인한다.

```text
1. Material Surface Type
↓
2. Shader Queue Tag
↓
3. Material.renderQueue Override
↓
4. Blend State
↓
5. ZWrite와 ZTest
↓
6. RenderType Tag
↓
7. URP Opaque / Transparent Pass 선택
↓
8. Queue 내부 Sorting
↓
9. Mesh 내부 Triangle과 Bounds
```

Queue 값만 계속 변경하기 전에 Blend와 Depth 문제인지 구분한다.

---

## Frame Debugger로 Queue 확인하기

Frame Debugger에서는 Opaque와 Transparent Event Group의 순서를 확인할 수 있다.

```text
DrawOpaqueObjects
├─ Queue 2000 Renderer
└─ Queue 2450 Renderer

DrawTransparentObjects
├─ Queue 3000 Renderer
└─ Queue 3010 Renderer
```

각 Draw Event에서 Material, Shader Pass, Blend, ZWrite와 Render Target을 비교한다.

Object가 예상 Group에 없다면 Material Queue Override와 Renderer Feature의 Range Filter를 확인한다.

---

## 코드에서 Queue 확인하기

Shader의 기본 Queue와 Material Override 결과를 확인할 수 있다.

```csharp
using UnityEngine;

public class RenderQueueReport : MonoBehaviour
{
    [SerializeField] private Renderer targetRenderer;

    private void Start()
    {
        Material material = targetRenderer.sharedMaterial;

        Debug.Log($"Shader Queue: {material.shader.renderQueue}");
        Debug.Log($"Material Queue: {material.renderQueue}");
    }
}
```

두 값이 다르면 Material이 Shader 기본 Queue를 Override하고 있을 수 있다.

Shared Material을 직접 변경하지 않고 진단용으로 읽는다.

---

## Custom Shader 예제: Opaque

```shaderlab
Shader "Custom/QueueOpaque"
{
    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "Queue" = "Geometry"
            "RenderType" = "Opaque"
        }

        Pass
        {
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            Blend Off
            ZWrite On
            ZTest LEqual

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag
            ENDHLSL
        }
    }
}
```

Queue, RenderType, Blend와 Depth State가 Opaque 목적에 맞게 구성되어 있다.

---

## Custom Shader 예제: Alpha Clip

```shaderlab
Shader "Custom/QueueAlphaClip"
{
    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "Queue" = "AlphaTest"
            "RenderType" = "TransparentCutout"
        }

        Pass
        {
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            Blend Off
            ZWrite On

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag
            #pragma shader_feature_local _ _ALPHA_CLIP
            ENDHLSL
        }
    }
}
```

Fragment Shader의 `clip` Code와 ShadowCaster·DepthOnly Pass에도 같은 Cutoff가 적용되어야 한다.

---

## Custom Shader 예제: Transparent

```shaderlab
Shader "Custom/QueueTransparent"
{
    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "Queue" = "Transparent"
            "RenderType" = "Transparent"
        }

        Pass
        {
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            ZTest LEqual

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag
            ENDHLSL
        }
    }
}
```

이 구조는 일반적인 Alpha Blend 기준이며 모든 Transparent Effect에 동일한 설정이 최선이라는 뜻은 아니다.

---

## 자주 혼동하는 내용

### Queue Index가 높으면 항상 화면 위에 보인다?

아니다.

나중에 Draw되더라도 ZTest에서 실패하거나 Alpha가 0이면 보이지 않을 수 있다.

### Queue를 Transparent로 바꾸면 자동으로 투명해진다?

아니다.

Blend State, Output Alpha와 ZWrite 등도 함께 설정해야 한다.

### Alpha가 0.5면 Transparent Queue가 자동 선택된다?

아니다.

Color Alpha 값은 Queue Metadata를 자동으로 변경하지 않는다.

### Alpha Clip은 Transparent Queue를 사용해야 한다?

일반적으로 AlphaTest Queue와 Depth Write를 사용해 Opaque 계열로 처리할 수 있다.

### Queue가 같으면 Draw 순서도 항상 같다?

아니다.

Queue 내부에서는 Distance, State, Sorting Layer와 Pipeline Criteria에 따라 다시 정렬된다.

### Overlay Queue면 Depth를 무시한다?

아니다.

Queue는 순서를 정하고 Depth 동작은 ZTest와 ZWrite가 정한다.

### Queue Offset으로 모든 Transparency 문제를 해결할 수 있다?

아니다.

교차 Geometry, Mesh 내부 Triangle과 View-dependent Depth 관계는 고정 Queue 순서로 해결되지 않을 수 있다.

---

## 전체 흐름 다시 연결하기

Render Queue가 사용되는 과정을 정리하면 다음과 같다.

```text
Camera Culling Result
↓
Renderer의 Material 확인
↓
Shader Queue Tag
+ Material Queue Override
↓
Queue Index 결정
↓
Opaque / Transparent Range Filtering
↓
Queue 내부 Sorting
↓
Shader Pass와 Variant 선택
↓
Draw
```

Queue는 Camera가 Object를 볼 수 있는지보다 뒤에서, 정확한 Draw 순서보다 앞에서 작동하는 큰 분류 기준이다.

---

## 정리

Render Queue는 Renderer의 Material을 Rendering 순서 Group에 배치하는 Integer 값이다.

```text
Background  1000
Geometry    2000
AlphaTest   2450
Transparent 3000
Overlay     4000
```

Opaque Geometry는 먼저 Color와 Depth를 기록해 뒤의 Fragment를 제거할 수 있고 Transparent Geometry는 완성된 Opaque Color 위에 Blend하기 위해 나중에 그려진다.

AlphaTest는 Pixel을 완전히 유지하거나 제거하면서 Depth를 기록할 수 있어 일반 Opaque 뒤와 Transparent 앞에 배치된다.

Shader의 SubShader `Queue` Tag가 기본값을 제공하며 Material의 `renderQueue`가 이를 Override할 수 있다.

Queue만 변경해도 Blend, ZWrite, RenderType과 Shader Keyword가 자동으로 Surface 목적에 맞춰지는 것은 아니다.

URP는 Queue Range로 Opaque와 Transparent Renderer를 서로 다른 Render Pass에서 Filter하고 각 Queue 안에서는 별도의 Sorting Criteria를 적용한다.

Queue Offset은 고정된 Layer 관계에 제한적으로 사용하고 Transparency 교차, Depth와 Z-fighting 문제를 임의의 숫자 증가로 해결하지 않는다.

Frame Debugger에서 Object가 어느 Opaque·Transparent Event에 포함되는지와 Material Queue, Blend, Depth State를 함께 확인한 뒤 목표 Device에서 Overdraw와 State 변경 비용을 측정해야 한다.
