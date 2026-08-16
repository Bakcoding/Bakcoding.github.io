---
title: "[Unity 렌더링] 9-4. Dynamic Batching은 어떻게 동작할까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - DynamicBatching
  - DrawCall
  - Optimization
permalink: /programming/unity-9-4-how-dynamic-batching-works/
toc: true
toc_sticky: true
date: 2026-08-16
last_modified_at: 2026-08-16
---

Dynamic Batching은 움직이는 작은 Mesh의 Vertex를 CPU에서 World Space로 변환하고 호환되는 Geometry를 Runtime에 묶어 Draw Call을 줄이는 방식이다.

```text
Mesh A Local Vertex ┐
Mesh B Local Vertex ├─ CPU World Transform → Combined Buffer → Draw
Mesh C Local Vertex ┘
```

Object가 움직여도 사용할 수 있지만 매 Frame Vertex 변환과 Buffer 구성이 필요하다.

줄어든 Draw Call 비용보다 Batch를 만드는 CPU 비용이 더 클 수 있어 적용 전후를 반드시 측정해야 한다.

---

## Dynamic의 의미

Static Batching은 움직이지 않는 Mesh를 미리 World Space Buffer에 구성한다.

Dynamic Batching은 Transform이 바뀌는 Mesh를 현재 Frame의 상태로 변환해 묶는다.

```text
Static Batching
├─ Build·Load 시 Geometry 준비
├─ Runtime 개별 Transform 변경 불가
└─ 매 Frame Vertex 결합 불필요

Dynamic Batching
├─ Runtime에 Geometry 준비
├─ 움직이는 Object 지원 가능
└─ CPU Vertex 변환 비용 반복
```

`Dynamic`은 비용 없이 어떤 Object든 묶는다는 의미가 아니다.

변하는 Transform을 따라가기 위해 Batch Data도 계속 갱신해야 한다는 의미에 가깝다.

---

## 일반적인 Vertex 변환

보통 GPU의 Vertex Shader가 Local Position을 World Space와 Clip Space로 변환한다.

```hlsl
float3 positionWS = TransformObjectToWorld(positionOS);
float4 positionCS = TransformWorldToHClip(positionWS);
```

각 Object는 서로 다른 Object-to-World Matrix를 사용한다.

```text
Mesh A + Matrix A → Draw A
Mesh B + Matrix B → Draw B
Mesh C + Matrix C → Draw C
```

같은 Material이어도 Object Matrix가 다르므로 단순한 하나의 일반 Draw로 합치기 어렵다.

---

## CPU에서 World Space로 변환하는 이유

Dynamic Batching은 서로 다른 Object Transform을 Vertex Position에 미리 적용한다.

```text
Object A
Local Vertex × Matrix A = World Vertex A

Object B
Local Vertex × Matrix B = World Vertex B
```

이제 두 Mesh의 Vertex가 같은 World Space 좌표계를 사용한다.

```text
Combined Vertex Buffer
┌────────────────┬────────────────┐
│ World Vertex A │ World Vertex B │
└────────────────┴────────────────┘
```

하나의 공통 Transform 조건에서 Geometry를 연속으로 그릴 수 있다.

Draw Call은 줄지만 원래 GPU가 병렬로 수행하던 Vertex Transform 일부를 CPU가 담당한다.

---

## Frame마다 반복되는 흐름

움직이는 Object의 Transform은 다음 Frame에 달라질 수 있다.

```text
Frame N
├─ Matrix A(N)로 Vertex 변환
├─ Matrix B(N)로 Vertex 변환
├─ Batch Buffer 구성
└─ Draw

Frame N + 1
├─ Matrix A(N+1)로 다시 변환
├─ Matrix B(N+1)로 다시 변환
├─ Batch Buffer 다시 구성
└─ Draw
```

Static Batching과 달리 결과를 계속 재사용하기 어렵다.

Mesh가 작아야 CPU 변환 비용을 제한할 수 있는 이유다.

---

## 무엇을 절약하고 무엇을 지불할까?

```text
절약 가능
├─ Draw Call 수
├─ Render State Update
├─ Graphics API Submission
└─ 일부 Buffer Bind

추가 비용
├─ CPU Vertex Transform
├─ Vertex Attribute 복사
├─ Batch 호환성 판단
├─ Combined Buffer 구성
└─ Runtime Memory Traffic
```

최적화 효과는 두 비용의 차이다.

```text
이득 = 줄어든 Draw 제출 비용 - Dynamic Batch 준비 비용
```

결과가 음수라면 Batches는 줄어도 Frame Time은 늘어난다.

---

## 작은 Mesh만 가능한 이유

CPU가 많은 Vertex를 매 Frame 변환하면 비용이 빠르게 커진다.

```text
10 Mesh × 50 Vertex
→ 500 Vertex Transform

100 Mesh × 10,000 Vertex
→ 1,000,000 Vertex Transform
```

GPU는 대규모 Vertex 계산에 특화되어 있지만 CPU는 Game Logic, Physics와 Rendering Command 준비도 수행한다.

Dynamic Batching은 작은 Geometry에서 Draw Call 절약이 CPU Vertex 처리보다 클 때만 의미가 있다.

---

## Unity 6의 Vertex 제한

Unity 공식 문서 기준으로 Dynamic Batching 대상 Mesh는 다음 한도를 넘지 않아야 한다.

```text
최대 300 Vertices
또는
최대 900 Vertex Attributes
```

Vertex Attribute 수는 Mesh의 Vertex 수와 Vertex당 Data Channel 수의 영향을 받는다.

```text
총 Attribute 규모
≈ Vertex 수 × Vertex당 Attribute 구성
```

Position만 가진 Mesh와 Position, Normal, Tangent, 여러 UV를 가진 Mesh는 같은 Vertex 수라도 한도에 미치는 영향이 다르다.

---

## 900 Vertex Attribute의 의미

단순화한 예로 Vertex당 Position, Normal과 UV0 세 Attribute를 사용한다고 가정한다.

```text
300 Vertices × 3 Attributes
= 900 Vertex Attributes
```

Tangent와 UV1이 추가되면 Vertex당 Attribute가 늘어난다.

```text
Position + Normal + Tangent + UV0 + UV1
= Vertex당 더 많은 Attribute
→ Batch 가능한 Vertex 수 감소
```

정확한 내부 계산과 Attribute 단위는 Unity Version과 Mesh Layout에 따라 확인해야 한다.

공식 문서가 강조하는 핵심은 Attribute가 많을수록 더 적은 Mesh만 Dynamic Batch 조건을 만족한다는 점이다.

---

## Vertex Attribute가 늘어나는 경우

```text
일반적인 Vertex Data
├─ Position
├─ Normal
├─ Tangent
├─ Vertex Color
├─ UV0
├─ UV1 / Lightmap UV
├─ UV2 이상
└─ 기타 Stream
```

Normal Mapping을 위해 Tangent가 필요하고 Baked Lighting을 위해 Lightmap UV가 필요할 수 있다.

보이지 않는 Attribute를 무조건 삭제하는 것은 기능과 품질을 깨뜨릴 수 있다.

Mesh Import 설정과 Shader 입력을 확인해 실제로 사용하지 않는 Channel만 제거한다.

---

## Material과 Render State 조건

Dynamic Batch로 같은 Draw에 들어가려면 사용하는 Material과 Render State가 호환되어야 한다.

```text
Batch 후보
├─ 같은 Material
├─ 같은 Shader Pass
├─ 호환되는 Keyword
├─ 같은 Texture State
├─ 같은 Render Queue
└─ 호환되는 Vertex Layout
```

Object가 작다는 이유만으로 서로 다른 Material을 한 Draw로 합칠 수는 없다.

Material A에서 B로 바뀌면 Texture와 Shader Property를 다시 Bind해야 한다.

---

## 같은 Material Instance를 공유한다

Renderer마다 `renderer.material`에 접근하면 Material Instance가 복제될 수 있다.

```csharp
Renderer targetRenderer = GetComponent<Renderer>();
Material instance = targetRenderer.material;
```

각 Object에 별도 Material Instance가 생기면 Batching 호환성이 깨질 가능성이 있다.

공통 상태가 필요하면 `sharedMaterial`을 유지하고 Renderer별 값이 필요하다면 Batching 방식과 `MaterialPropertyBlock`의 영향을 확인한다.

Material 관리의 자세한 내용은 이후 글에서 다룬다.

---

## Positive Scale과 Negative Scale

Scale의 부호가 다르면 좌표계의 Handedness와 Triangle 방향이 바뀔 수 있다.

```text
Object A Scale = ( 1, 1, 1)
Object B Scale = (-1, 1, 1)
```

Negative Scale은 Mirror Transform을 만든다.

Normal, Tangent와 Face Winding 처리 조건이 Positive Scale Object와 달라질 수 있다.

Unity는 Negative Scale을 사용하는 GameObject와 Positive Scale GameObject를 같은 Dynamic Batch로 묶지 못한다.

Mirror가 필요하면 별도 Mesh를 만들거나 Batch 분리를 예상한다.

---

## Lightmap 조건

Baked Lighting을 사용하는 Object는 Lightmap Texture와 UV 정보를 참조한다.

```text
Renderer A
├─ Lightmap Texture 0
└─ UV ScaleOffset A

Renderer B
├─ Lightmap Texture 1
└─ UV ScaleOffset B
```

서로 다른 Lightmap Texture를 사용하면 동일한 Texture State로 한 Draw에 묶기 어렵다.

Unity 공식 문서는 Lightmap을 사용하는 GameObject가 같은 Lightmap Texture와 UV 조건을 가져야 Dynamic Batch될 수 있다고 설명한다.

Lighting Bake 전후에 Batch 수가 달라질 수 있으므로 Bake된 최종 Scene에서 확인한다.

---

## Multi-pass Shader의 제한

Shader가 여러 Pass를 사용하면 Object가 Pass마다 다시 Rendering될 수 있다.

```text
Multi-pass Shader
├─ Pass 0 → Dynamic Batching 가능 영역
├─ Pass 1 → 별도 Draw
└─ Pass 2 → 별도 Draw
```

Unity 공식 문서 기준으로 Dynamic Batching은 Multi-pass Shader의 첫 번째 Render Pass만 지원한다.

추가 Per-pixel Light를 위한 Pass와 다른 후속 Pass는 Batch되지 않을 수 있다.

첫 Pass의 Draw만 줄었다고 전체 Renderer의 Draw가 같은 비율로 줄지는 않는다.

---

## Shadow Pass에서의 Batching

Unity는 Shadow를 Rendering할 때 Shadow Pass가 사용하는 Material 값이 같으면 Mesh를 Batch할 수 있다.

```text
Color Pass
Crate A: Texture A
Crate B: Texture B
→ 다른 Material State

Opaque Shadow Pass
둘 다 Depth만 기록
→ 사용 Property가 같으면 Batch 가능성
```

Alpha Clipping Caster는 Base Map Alpha와 Cutoff를 읽어야 하므로 Texture와 Property 차이가 영향을 줄 수 있다.

Camera Color Pass와 ShadowCaster Pass의 Batching 결과를 따로 확인한다.

---

## Skinned Mesh Renderer가 대상이 아닌 이유

Dynamic Batching의 Mesh 결합 기능은 Mesh Renderer를 대상으로 하며 Skinned Mesh Renderer를 지원하지 않는다.

```text
Skinned Mesh
├─ Bone Matrix
├─ Vertex Weight
├─ Pose별 변형
└─ Object별 Animation 상태
```

각 Character가 다른 Pose를 사용하면 단순한 Object Transform보다 복잡한 Vertex 변형이 필요하다.

Crowd에는 GPU Skinning, Animation Instancing, LOD와 전용 Rendering 방식을 검토한다.

---

## HDRP에서 지원되지 않는다

Unity 6 공식 문서 기준으로 Dynamic Batching은 HDRP에서 지원되지 않는다.

```text
Built-in / URP
└─ 설정과 조건에 따라 사용 가능

HDRP
└─ Dynamic Batching 지원 안 함
```

Render Pipeline이 다르면 Shader, Pass와 Draw Call 최적화 전략도 달라진다.

HDRP Project에서는 SRP Batcher, GPU Instancing과 다른 GPU-driven 방식을 검토한다.

---

## Runtime 생성 Geometry의 별도 경로

Particle, Line과 Trail처럼 Runtime에 생성되는 Geometry도 Dynamic Batching이라는 이름 아래 처리될 수 있다.

```text
Runtime Geometry
├─ Particle System
├─ Line Renderer
└─ Trail Renderer
```

Unity는 이러한 Mesh를 하나의 Vertex Buffer로 Batch한 뒤 Mesh별 Draw를 제출하는 방식으로 처리할 수 있다.

일반 Mesh의 Local-to-World CPU 변환 경로와 세부 동작이 같다고 단정하면 안 된다.

Runtime 생성 Geometry는 Draw Call뿐 아니라 Vertex 생성, Upload, Transparent Sorting과 Overdraw 비용을 함께 가진다.

---

## Particle이 Batch되지 않는 흔한 이유

```text
Particle Batch Break
├─ 다른 Material
├─ 다른 Texture
├─ 다른 Render Mode
├─ 다른 Shader Keyword
├─ Sorting 조건
└─ Distortion 등 추가 Pass
```

Particle System 수가 많아도 같은 Material과 호환 State를 사용하면 묶일 가능성이 있다.

그러나 Batches가 줄어도 Screen을 덮는 투명 Particle의 Overdraw는 그대로일 수 있다.

Particle 최적화에서 Dynamic Batching 숫자만 보면 안 되는 이유다.

---

## 왜 과거에는 더 유리했을까?

과거 Graphics API와 Driver에서는 Draw Call마다 발생하는 CPU Overhead가 매우 컸다.

```text
과거 조건
Draw Call Cost 높음
CPU Vertex Transform Cost 상대적으로 낮음
→ 작은 Mesh를 CPU에서 합치는 이득 가능
```

작은 Mesh의 Vertex 몇백 개를 CPU에서 변환해 Draw 여러 개를 하나로 줄이는 선택이 효과적일 수 있었다.

Hardware와 API가 바뀌면서 이 비용 관계도 달라졌다.

---

## 현대 Graphics API에서 불리할 수 있는 이유

Metal, Vulkan과 Direct3D 12 같은 현대 API는 Command Submission Overhead를 줄이기 위해 설계되었다.

```text
현대 조건 가능성
Draw Call Cost 감소
Dynamic Batch CPU Transform Cost 유지
→ Batch 준비가 더 비쌀 수 있음
```

Unity 공식 문서는 대부분의 일반적인 용도에서 Dynamic Batching의 CPU Overhead가 Draw Call Overhead보다 클 수 있어 더 이상 권장하지 않는다고 경고한다.

기능 이름이 `Optimization` 범주에 있다고 항상 성능이 좋아지는 것은 아니다.

---

## Lower-end Device 권장의 의미

Unity 문서는 Dynamic Batching을 Lower-end Device의 제한적인 경우에 권장한다.

그러나 낮은 사양 Device라고 무조건 활성화해야 하는 것은 아니다.

```text
검토 조건
├─ 작은 Mesh가 많음
├─ 같은 Material 공유
├─ Draw Submission CPU 병목
├─ Dynamic Batch 준비 비용이 낮음
└─ 실제 Graphics API에서 측정상 이득
```

Device의 CPU가 느리면 Vertex Transform 비용도 더 크게 느껴질 수 있다.

권장 범주보다 실제 Profiler 결과가 우선한다.

---

## URP에서 활성화하는 위치

URP Asset 또는 Renderer 설정의 지원 여부와 Unity Version에 따라 Dynamic Batching 옵션을 설정한다.

일반적인 확인 흐름은 다음과 같다.

```text
Render Pipeline Asset
└─ Dynamic Batching 관련 설정

Camera Rendering
└─ 해당 Pipeline과 Shader가 지원하는지 확인
```

옵션이 켜져 있어도 모든 Renderer가 Dynamic Batch되는 것은 아니다.

Material, Vertex 한도, Lightmap, Pass와 Transform 조건을 모두 만족해야 한다.

---

## 코드에서 요청하는 경우

Scriptable Render Pipeline의 Drawing Setting에는 Dynamic Batching 사용 여부를 지정하는 Flag가 있다.

개념적인 구조는 다음과 같다.

```csharp
drawingSettings.enableDynamicBatching = true;
```

Custom SRP에서는 Pipeline이 이 Flag와 호환 Shader Pass를 사용해 Drawing해야 한다.

단순히 `true`로 설정한다고 Batch 준비 비용이 사라지거나 모든 Draw가 합쳐지지는 않는다.

Custom Pipeline의 Sorting, Filtering과 Per-object Data 설정도 결과에 영향을 준다.

---

## Shader에서 Batching을 끄는 경우

Dynamic Batching은 Vertex를 World Space로 변환하므로 Shader가 Object Space 정보를 특별한 방식으로 사용하면 결과가 달라질 수 있다.

Shader Import Setting이나 SubShader Tag로 Batching을 비활성화할 수 있다.

```shaderlab
SubShader
{
    Tags { "DisableBatching" = "True" }
}
```

Object Origin, Object Scale이나 Local Position을 이용한 Vertex Animation은 Batch된 World Space Data와 충돌할 수 있다.

Grass Wind와 Object별 흔들림처럼 Local Space가 중요한 Shader는 화면 결과를 반드시 확인한다.

---

## Preserve Object Position이 필요한 Shader

다음 Shader는 Object Space Data를 직접 사용하기 쉽다.

```text
Object Space 의존
├─ Object Origin 기반 Dissolve
├─ Local Height Gradient
├─ Local Position 기반 Wind
├─ Object Scale 기반 Effect
└─ Per-object Pivot Animation
```

Dynamic Batching으로 Vertex가 World Space에 결합되면 Object별 Local Origin을 그대로 가정할 수 없다.

별도 Property로 Origin을 전달하거나 해당 Shader의 Batching을 끈다.

성능보다 정확한 Visual 결과가 우선이다.

---

## Dynamic Batching과 GPU Instancing

```text
Dynamic Batching
├─ CPU가 Vertex를 World Space로 변환
├─ 서로 다른 작은 Mesh도 조건에 따라 결합 가능
└─ 매 Frame CPU 준비 비용

GPU Instancing
├─ 같은 Mesh Geometry 공유
├─ Instance별 Transform을 GPU에 전달
└─ GPU가 각 Instance Vertex 변환
```

같은 Mesh를 반복 배치한다면 GPU Instancing이 일반적으로 더 자연스러운 후보다.

서로 다른 매우 작은 Mesh가 같은 Material을 사용하고 Draw CPU 비용이 큰 경우에만 Dynamic Batching을 비교할 가치가 있다.

두 기능이 동시에 가능한 경우 Unity의 우선순위와 실제 Frame Debugger 결과를 확인한다.

---

## Dynamic Batching과 SRP Batcher

```text
Dynamic Batching
└─ Mesh Geometry를 CPU에서 결합해 Draw 수 감소

SRP Batcher
└─ 동일 Shader Variant Draw 사이의 State 준비 비용 감소
```

SRP Batcher는 Mesh Vertex를 CPU에서 World Space로 합치지 않는다.

Draw Call 수가 남아도 Material Data를 GPU Memory에 유지해 CPU 비용을 낮출 수 있다.

URP에서 SRP Batcher가 이미 효과적으로 작동한다면 Dynamic Batching의 추가 이득이 작거나 역효과일 수 있다.

---

## Dynamic Batching과 Static Batching

| 항목 | Static Batching | Dynamic Batching |
| --- | --- | --- |
| Object 이동 | 개별 이동 불가 | 이동 가능 |
| Vertex 변환 시점 | Build·Load | Runtime Frame |
| CPU 반복 비용 | 낮음 | Vertex 변환·결합 발생 |
| Memory | World Vertex Copy 증가 가능 | Runtime Buffer와 Upload |
| Mesh 크기 | 더 큰 Buffer 구성 가능 | 작은 Mesh 제한 |
| 주요 용도 | 고정 Environment | 제한적인 작은 Dynamic Mesh |

움직이지 않는 Object에 Dynamic Batching을 사용할 이유는 적다.

Static Batching의 Memory 비용이 너무 크거나 Object 구성상 Static 표시가 불가능할 때 다른 방식과 비교한다.

---

## Culling과의 관계

Dynamic Batching은 먼저 Visible Renderer를 판정한 뒤 호환 Geometry를 묶을 수 있다.

```text
Camera Culling
├─ Object A Visible
├─ Object B Culled
└─ Object C Visible

Dynamic Batch 후보
└─ A + C
```

Static Combined Mesh처럼 긴 수명의 World Buffer를 유지하는 대신 현재 Visible Set을 Runtime에 구성한다.

Camera가 빠르게 이동하면 Batch 구성 대상도 Frame마다 크게 바뀔 수 있다.

Culling 비용과 Batch 준비 비용을 함께 Profile한다.

---

## 많은 작은 Renderer의 Trade-off

```text
작은 Renderer 5000개
├─ 개별 Culling 비용
├─ Batch 호환성 검사
├─ CPU Vertex 변환
└─ 적은 Draw로 제출 가능
```

Dynamic Batching은 Draw 수만 줄일 뿐 Renderer Component 수와 Culling 후보 수를 없애지 않는다.

CPU 병목이 Renderer 수집과 Culling에 있다면 Draw 감소 효과가 제한적일 수 있다.

Spatial Partition, LOD, Occlusion과 Renderer 구조도 함께 확인한다.

---

## Batch가 깨지는 체크리스트

```text
□ Mesh가 300 Vertex 이하인가?
□ 전체 Vertex Attribute 한도 안인가?
□ Mesh Renderer인가?
□ 같은 Material과 Shader Pass인가?
□ Shader Variant가 호환되는가?
□ Positive·Negative Scale이 섞이지 않았는가?
□ 같은 Lightmap과 UV 조건인가?
□ 첫 번째 Render Pass인가?
□ Pipeline이 Dynamic Batching을 지원하는가?
□ Shader가 DisableBatching을 요청하지 않는가?
```

하나라도 맞지 않으면 별도 Batch 또는 Draw가 생성될 수 있다.

조건을 추측하지 말고 Frame Debugger에서 실제 Event를 확인한다.

---

## Profiler에서 확인할 것

```text
CPU
├─ Main Thread Rendering Time
├─ Render Thread Time
├─ Dynamic Batching 관련 Marker
├─ Vertex Transform / Buffer Upload
└─ Draw Submission

Rendering Statistics
├─ Batches
├─ Saved by batching
├─ SetPass Calls
├─ Draw Calls
└─ Vertices

GPU
├─ 전체 Frame Time
├─ Pass별 Draw
└─ Vertex / Fragment 병목
```

`Saved by batching` 숫자가 증가해도 CPU Frame Time이 늘었다면 성공한 최적화가 아니다.

Draw 절약량과 Batch 구성 CPU 시간을 함께 비교한다.

---

## Frame Debugger에서 확인할 것

```text
1. 대상 Renderer Draw Event 선택
2. Dynamic Batching 표시 확인
3. 앞뒤 Event의 Material과 Pass 비교
4. Batch Break 원인 확인
5. Shadow Pass 결과 별도 확인
6. Multi-pass의 추가 Draw 확인
```

같은 Material인데도 분리된다면 Vertex Attribute, Lightmap, Scale, Shader Keyword와 Pass를 확인한다.

Frame Debugger는 한 Frame의 구조를 보여 주지만 Batch를 만드는 CPU 시간은 Profiler에서 측정해야 한다.

---

## A/B Test 절차

```text
Test A: Dynamic Batching Off
├─ CPU Main / Render Thread
├─ Batches / SetPass
├─ GPU Time
└─ Visual 결과

Test B: Dynamic Batching On
├─ 동일 Camera 경로
├─ 동일 Object와 Animation
├─ 동일 Graphics API
└─ 동일 Quality 설정
```

다음 Scene을 각각 측정한다.

- 평균적인 Gameplay Scene
- 작은 Mesh가 가장 많이 보이는 Scene
- Camera가 빠르게 이동하는 Scene
- Shadow Light가 많은 Scene
- Target Device의 지속 부하 상태

한두 Frame보다 충분한 Sample의 Median과 상위 Percentile을 비교한다.

---

## 효과가 있을 수 있는 예

```text
조건
├─ 저사양 Device와 API에서 Draw Overhead가 큼
├─ 100 Vertex 이하의 다른 작은 Mesh가 많음
├─ 같은 Material 공유
├─ Vertex Attribute가 단순함
├─ CPU Draw Submission이 병목
└─ 측정상 Batch 준비보다 Draw 절약이 큼
```

예를 들어 단순한 2D World Geometry나 작은 Runtime Mesh가 많은 특수한 Scene에서 이득이 날 수 있다.

`가능성`일 뿐 실제 Device 측정 없이 결론을 내리지 않는다.

---

## 손해가 날 수 있는 예

```text
조건
├─ 현대 API에서 Draw Call 비용이 낮음
├─ Vertex Attribute가 많음
├─ Mesh가 제한에 가까움
├─ SRP Batcher가 이미 효율적으로 동작
├─ Material·Lightmap 차이로 Batch가 자주 끊김
└─ CPU가 Vertex 변환에 민감함
```

Batch되는 Object가 적으면 준비 작업만 늘고 Draw Call 절약은 작을 수 있다.

CPU Render Thread가 아니라 Script나 GPU가 병목인 Scene에서도 FPS 개선은 제한적이다.

---

## 흔한 오해

### Dynamic Batching은 GPU에서 Mesh를 합친다

일반 Mesh 경로에서는 CPU가 Vertex를 World Space로 변환하고 Geometry를 묶는다.

### 움직이는 Mesh라면 크기와 관계없이 Batch된다

Unity 6 기준 300 Vertex 또는 900 Vertex Attribute 한도와 여러 호환 조건이 있다.

### Batches가 줄면 반드시 빨라진다

CPU Vertex Transform과 Buffer 구성 비용이 줄어든 Draw Call 비용보다 클 수 있다.

### Lower-end Device에서는 항상 켜야 한다

느린 CPU에서는 Batch 준비도 비싸므로 Target Device와 Graphics API에서 비교해야 한다.

### 같은 Material이면 모두 Batch된다

Vertex Layout, Lightmap, Scale 부호, Shader Pass와 Pipeline 지원도 영향을 준다.

### 모든 Render Pass가 Batch된다

Multi-pass Shader에서는 첫 번째 Pass만 지원하며 추가 Pass는 별도 Draw가 될 수 있다.

### Skinned Mesh도 움직이므로 Dynamic Batch된다

일반 Mesh Batching은 Mesh Renderer를 대상으로 하며 Skinned Mesh Renderer를 지원하지 않는다.

### HDRP에서도 옵션만 켜면 된다

Unity 6 공식 문서 기준 HDRP는 Dynamic Batching을 지원하지 않는다.

### GPU Instancing과 같은 기능이다

Instancing은 같은 Mesh를 공유하고 Instance Data를 GPU에 전달하지만 Dynamic Batching은 CPU에서 Vertex를 변환해 결합한다.

---

## 적용 판단 순서

```text
1. CPU Draw Submission 병목인지 확인
2. 대상이 작은 Mesh Renderer인지 확인
3. Material·Vertex·Lightmap·Pass 조건 확인
4. 반복 Mesh면 GPU Instancing을 먼저 비교
5. 같은 Shader Variant면 SRP Batcher 상태 확인
6. Dynamic Batching Off 기준 Capture
7. On으로 바꾸고 같은 장면 재측정
8. CPU ms와 Draw 절약량 비교
9. Shadow·Local Space Shader 회귀 검사
10. Target Device별 설정 결정
```

Project 전체에 관성적으로 활성화하기보다 이득이 확인된 Platform과 Renderer 집단에서 사용한다.

Unity Version을 바꾼 뒤에도 내부 구현과 API 비용이 달라질 수 있으므로 다시 측정한다.

---

## 정리

Dynamic Batching은 움직이는 작은 Mesh의 Local Vertex를 CPU에서 World Space로 변환하고 호환 Geometry를 Runtime에 묶어 Draw Call을 줄이는 방식이다.

Draw와 Render State Update는 줄일 수 있지만 Vertex 변환, Attribute 복사, Combined Buffer 구성과 Upload라는 CPU 비용을 새로 만든다.

Unity 6 기준 대상 Mesh는 300 Vertex 또는 900 Vertex Attribute 한도를 넘지 않아야 하며 Attribute가 많을수록 Batch 가능한 Vertex 수가 줄어든다.

같은 Material·Shader Pass, 호환 Vertex Layout과 Lightmap 조건이 필요하고 Positive·Negative Scale은 함께 묶을 수 없다.

Multi-pass Shader의 첫 Pass만 지원하며 Skinned Mesh Renderer와 HDRP에는 적용되지 않는다.

현대 Graphics API에서는 Draw Call 비용보다 Dynamic Batch 준비 비용이 클 수 있어 Unity도 대부분의 일반적인 용도에서는 권장하지 않는다.

같은 Mesh 반복은 GPU Instancing, 같은 Shader Variant의 다양한 Material은 SRP Batcher, 움직이지 않는 Geometry는 Static Batching과 먼저 비교해야 한다.

최종 판단은 `Saved by batching` 숫자가 아니라 Target Device에서 Dynamic Batching On·Off의 CPU Main·Render Thread, GPU Frame Time과 화면 결과를 비교해 내려야 한다.
