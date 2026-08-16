---
title: "[Unity 렌더링] 9-7. SRP Batcher와 GPU Instancing은 무엇이 다를까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - SRPBatcher
  - GPUInstancing
  - Optimization
permalink: /programming/unity-9-7-srp-batcher-vs-gpu-instancing/
toc: true
toc_sticky: true
date: 2026-08-16
last_modified_at: 2026-08-16
---

SRP Batcher와 GPU Instancing은 모두 CPU의 Draw Call 부담을 줄이지만 줄이는 방식이 다르다.

```text
SRP Batcher
└─ Draw Call은 유지할 수 있음
   └─ Draw 사이의 State·Material Data 준비 비용 감소

GPU Instancing
└─ 같은 Mesh·Material의 여러 Object
   └─ 하나의 Instanced Draw로 결합
```

SRP Batcher는 `Draw Call당 CPU 비용`을 줄이고 GPU Instancing은 `Draw Call 수`를 줄이는 데 초점이 있다.

Scene에 어떤 Mesh와 Material이 반복되는지에 따라 적합한 방식이 달라진다.

---

## 같은 문제에서 출발한다

CPU는 GPU가 Mesh를 그릴 수 있도록 State와 Data를 준비하고 Draw Command를 제출한다.

```text
CPU Rendering Cost
├─ Shader Variant 선택
├─ Material Property 준비
├─ Buffer와 Texture Bind
├─ Object Transform 전달
└─ Draw Command 제출
```

Object가 많으면 이 과정이 반복되어 Main Thread나 Render Thread가 병목이 될 수 있다.

두 기능은 반복 비용을 줄이지만 같은 Data 구조를 사용하지 않는다.

---

## 한 문장으로 구분하면

```text
SRP Batcher
= 다른 Mesh·Material이라도 같은 Shader Variant라면
  Draw 준비를 빠르게 처리

GPU Instancing
= 같은 Mesh·Material의 여러 복사본을
  하나의 Draw로 처리
```

이 기준만 기억해도 대부분의 선택 방향을 잡을 수 있다.

---

## SRP Batcher의 처리 단위

SRP Batcher는 같은 Shader Variant를 사용하는 Bind와 Draw Command의 연속 구간을 Batch로 구성한다.

```text
Shader Variant A
├─ Mesh House / Material Red   → Draw 1
├─ Mesh Rock / Material Gray   → Draw 2
├─ Mesh Tree / Material Green  → Draw 3
└─ Mesh Fence / Material Brown → Draw 4
```

Mesh와 Material 값이 서로 달라도 Variant가 같으면 같은 SRP Batch에 포함될 수 있다.

Draw는 네 번이지만 Material Data를 GPU Memory에 유지하고 State 전환을 줄여 CPU 준비를 빠르게 만든다.

---

## GPU Instancing의 처리 단위

GPU Instancing은 같은 Mesh와 Material을 반복해서 그리는 Instance Group을 만든다.

```text
Mesh Tree
Material Leaves
├─ Transform 0
├─ Transform 1
├─ Transform 2
└─ Transform 3

→ Instanced Draw 1회
```

다른 Rock Mesh나 다른 Material은 같은 기본 Instanced Draw에 들어갈 수 없다.

```text
Tree Group → Instanced Draw 1
Rock Group → Instanced Draw 2
```

---

## Draw Call 수의 차이

100개의 서로 다른 Mesh가 같은 Shader Variant를 사용한다고 가정한다.

```text
SRP Batcher
100 Mesh
→ Draw Call 약 100개 유지 가능
→ 하나 또는 소수의 긴 SRP Batch
```

같은 Tree Mesh가 100번 반복된다고 가정한다.

```text
GPU Instancing
Tree × 100
→ Instanced Draw 소수
```

SRP Batcher를 켰는데 Draw Call 숫자가 줄지 않는 것은 정상일 수 있다.

GPU Instancing의 직접적인 지표는 `Draw Mesh (Instanced)`와 Instance 수다.

---

## CPU에서 줄어드는 비용

| 비용 | SRP Batcher | GPU Instancing |
| --- | --- | --- |
| Shader Variant 전환 | 같은 Variant 구간에서 감소 | Group마다 공통 Variant |
| Material Data 준비 | Persistent Buffer로 감소 | Shared Material + Instance Data |
| Object별 Draw 제출 | 남을 수 있음 | 여러 Instance를 한 Draw로 감소 |
| Transform 전달 | Per-object Buffer | Instance Buffer 배열 |
| Property 수집 | Material Data 재사용 | Instance별 Property 수집·Upload |

두 방식 모두 CPU 작업을 완전히 없애지 않는다.

GPU Instancing은 Instance Data를 수집·결합·Upload해야 하고 SRP Batcher는 개별 Object Data와 Draw를 처리해야 한다.

---

## GPU에서 달라지는 것은 무엇일까?

두 방식 모두 실제 Geometry와 Pixel을 그리는 작업은 남는다.

```text
Tree Mesh 1000 Vertices
× 100 Instances
= 100,000 Vertex 처리
```

Instanced Draw 하나라도 GPU는 모든 Instance Vertex를 실행한다.

SRP Batcher도 Draw가 빨리 제출될 뿐 Triangle과 Fragment Shader가 줄지 않는다.

```text
Draw 최적화
≠ Geometry 자동 감소
≠ Overdraw 자동 감소
≠ Shader 계산 자동 감소
```

GPU Bound Scene에서는 두 기능의 FPS 효과가 작을 수 있다.

---

## Mesh 조건 비교

```text
SRP Batcher
├─ Mesh가 서로 달라도 가능
├─ Mesh Renderer 지원
└─ Skinned Mesh Renderer 지원

GPU Instancing
├─ 같은 Mesh와 SubMesh 필요
├─ Mesh Renderer 지원
└─ 일반 Skinned Mesh Renderer 미지원
```

서로 다른 Building, Prop와 Character가 많은 Scene은 SRP Batcher가 넓게 적용될 수 있다.

같은 Tree, Rock와 Grass가 반복되는 Scene은 GPU Instancing의 조건과 잘 맞는다.

---

## Material 조건 비교

```text
SRP Batcher
Material A, B, C가 달라도
같은 Shader Variant면 같은 SRP Batch 가능

GPU Instancing
같은 Mesh와 같은 Material을 공유해야
같은 Instanced Draw 가능
```

SRP Batcher는 Material Property 값이 달라도 Persistent Material Buffer를 전환해 연속 Draw할 수 있다.

GPU Instancing은 Instance별 차이를 Instanced Property로 설계해야 한다.

Texture와 Render State가 다르면 일반적으로 Instance Group이 나뉜다.

---

## Shader Variant 조건 비교

두 방식 모두 Shader Variant 호환성이 중요하다.

```text
Material A
_NORMALMAP
_MAIN_LIGHT_SHADOWS

Material B
_NORMALMAP
_MAIN_LIGHT_SHADOWS
_EMISSION
```

SRP Batcher에서는 다른 Variant가 SRP Batch를 끊는다.

GPU Instancing에서는 다른 Variant를 사용하는 Material이 별도 Instanced Draw Group이 된다.

불필요한 Keyword가 많으면 두 방식 모두 작은 Group과 잦은 State 전환을 만들 수 있다.

---

## Property를 다르게 주는 방법

### SRP Batcher

Material마다 값이 달라도 같은 Shader Variant를 유지할 수 있다.

```text
Material Red  → _BaseColor Red
Material Blue → _BaseColor Blue

같은 Variant
→ 같은 SRP Batch 가능
```

### GPU Instancing

하나의 Shared Material을 사용하면서 Instance별 값을 Buffer에서 선택한다.

```text
Shared Material
├─ Instance 0 Color Red
├─ Instance 1 Color Blue
└─ Instance 2 Color Green
```

Shader에 `_BaseColor`가 Instanced Property로 선언되어 있어야 한다.

---

## MaterialPropertyBlock이 갈림길이 된다

`MaterialPropertyBlock`은 Material을 복제하지 않고 Renderer별 Property를 Override한다.

```text
Shared Material
├─ Renderer A: PropertyBlock Red
├─ Renderer B: PropertyBlock Blue
└─ Renderer C: PropertyBlock Green
```

Unity 6 공식 문서 기준으로 MaterialPropertyBlock을 사용하는 GameObject는 SRP Batcher와 호환되지 않는다.

GPU Instancing에서는 Shader에 선언된 Instanced Property 값을 모으는 데 사용할 수 있다.

```text
MaterialPropertyBlock
├─ SRP Batcher: 비호환
└─ GPU Instancing: Instanced Property 전달 가능
```

Non-instanced Property를 Block에 넣으면 GPU Instancing도 비활성화될 수 있다.

---

## Renderer별 Color가 필요한 예

동일 Mesh인지에 따라 선택이 달라진다.

```text
같은 Cube Mesh 10,000개
각각 다른 Color
→ GPU Instancing + Instanced Color 후보

서로 다른 Prop Mesh 1000개
각각 다른 Color Material
같은 Shader Variant
→ SRP Batcher 후보
```

서로 다른 Mesh에 GPU Instancing을 강제로 적용하려면 Mesh를 통합하거나 더 복잡한 Procedural 구조가 필요하다.

SRP Batcher는 개별 Mesh를 유지한 채 적용할 수 있다.

---

## Geometry Memory 비교

두 방식 모두 Static Batching처럼 World Space Vertex를 Object마다 복제하지 않는다.

```text
SRP Batcher
├─ 각 Mesh Asset Buffer 유지
└─ Object별 Data Buffer

GPU Instancing
├─ 동일 Mesh Buffer 한 번 공유
└─ Instance별 Data Buffer
```

같은 Mesh 반복에서 GPU Instancing은 Mesh Data 공유가 명확하다.

SRP Batcher도 Geometry를 결합하지 않으므로 원본 Mesh Buffer를 사용하지만 반복 Object마다 Draw Command가 남는다.

---

## Culling 비교

GameObject Mesh Renderer 경로에서는 Unity가 Renderer별 Bounds를 Culling할 수 있다.

```text
SRP Batcher Renderer
├─ Object A Culling
├─ Object B Culling
└─ Object C Culling
```

자동 GPU Instancing도 Visible Renderer를 모아 Instance Group을 만들 수 있다.

그러나 `Graphics.RenderMeshInstanced` 같은 명시적 API는 Group Bounds를 기준으로 전체 Instance를 하나의 Entity처럼 Culling할 수 있다.

```text
Group Bounds Visible
→ Group 안의 Camera 밖 Instance도 Draw 가능
```

명시적 Instancing에서는 Spatial Chunk와 개별 Culling을 직접 설계해야 한다.

---

## GameObject와 Component 비용

SRP Batcher는 Scene의 Mesh Renderer와 Skinned Mesh Renderer를 그대로 사용한다.

자동 GPU Instancing도 Mesh Renderer를 사용할 수 있어 GameObject 관리 비용은 남는다.

```text
10,000 GameObjects
├─ Transform Update
├─ Renderer Culling
├─ Component 관리
└─ Scene Hierarchy 비용
```

`RenderMeshInstanced`나 `RenderMeshIndirect`로 전환하면 GameObject 없이 Instance Data를 직접 관리할 수 있다.

이는 Draw 최적화를 넘어 Data-oriented Rendering 구조를 만드는 변경이다.

---

## Skinned Mesh 차이

```text
SRP Batcher
└─ Skinned Mesh Renderer 지원
   └─ Material·Draw 준비 비용 최적화

일반 GPU Instancing
└─ Skinned Mesh Renderer 미지원
```

SRP Batcher가 Bone Matrix 계산과 Skinning Vertex 비용을 줄이는 것은 아니다.

Animated Crowd를 Instancing하려면 Animation Texture, GPU Skinning Buffer와 Custom Shader 같은 별도 구조가 필요하다.

Character가 많다고 일반 GPU Instancing Checkbox만 켜서는 해결되지 않는다.

---

## Particle 차이

Unity 공식 SRP Batcher 호환 조건에서 Particle은 제외된다.

Particle System은 자체 Batching과 GPU Instancing 경로를 사용할 수 있다.

```text
Particle Rendering
├─ Particle System Batching
├─ GPU Instancing 지원 Render Mode
├─ Runtime Vertex Stream
└─ Transparent Overdraw
```

Particle은 Draw Call보다 Fragment Overdraw가 병목인 경우도 많다.

SRP Batcher와 일반 Mesh Instancing 비교만으로 Particle 성능을 판단하지 않는다.

---

## Lightmap과 Light Probe

SRP Batcher는 Object별 Lightmap ScaleOffset과 Probe Data를 Per-object Buffer에서 처리할 수 있다.

GPU Instancing도 같은 Lightmap Texture를 사용하는 Static Object와 Light Probe Lighting을 지원한다.

```text
GPU Instancing Lighting 조건
├─ 같은 Lightmap Texture
├─ Instance별 Lightmap ScaleOffset
├─ Light Probe Data
└─ LPPV 지원 조건
```

Lightmap Texture가 다르면 Material·Resource State가 나뉘어 Instance Group도 분리될 수 있다.

Lighting Bake 전후 Frame Debugger 결과를 다시 확인한다.

---

## Shadow Pass

두 방식 모두 ShadowCaster Pass에서 적용될 수 있지만 Shadow Rendering 자체는 남는다.

```text
SRP Batcher Shadow
└─ Caster Draw 준비를 효율화

GPU Instancing Shadow
└─ 같은 Mesh Caster를 Instanced Draw로 결합
```

Cascade와 Shadow Light마다 Caster가 다시 Rendering될 수 있다.

```text
Tree Instances
├─ Cascade 0 Instanced Shadow Draw
├─ Cascade 1 Instanced Shadow Draw
└─ Cascade 2 Instanced Shadow Draw
```

Draw 최적화 후에도 Shadow Distance, Caster 수와 Vertex 처리량을 확인한다.

---

## SRP Batcher의 Shader 요구사항

Custom Shader는 Property를 정해진 Constant Buffer에 배치해야 한다.

```hlsl
CBUFFER_START(UnityPerMaterial)
    float4 _BaseColor;
    float _Metallic;
    float _Smoothness;
CBUFFER_END
```

```text
UnityPerDraw
└─ Engine Built-in Property

UnityPerMaterial
└─ Material Property
```

Inspector에서 Shader의 SRP Batcher Compatibility를 확인한다.

호환 Shader를 사용하는 동안 Draw마다 별도 Instance Macro가 필수인 것은 아니다.

---

## GPU Instancing의 Shader 요구사항

Shader는 Instance ID를 설정하고 Instance별 Property를 읽어야 한다.

```hlsl
UNITY_INSTANCING_BUFFER_START(Props)
    UNITY_DEFINE_INSTANCED_PROP(float4, _InstanceColor)
UNITY_INSTANCING_BUFFER_END(Props)
```

```hlsl
float4 color =
    UNITY_ACCESS_INSTANCED_PROP(Props, _InstanceColor);
```

Built-in Pipeline과 URP·HDRP의 Custom Shader 작성 방식은 다르다.

Shader Graph는 Pipeline의 Instancing·Indirect Rendering 지원 방식을 확인한다.

---

## 한 Shader가 두 방식에 모두 최적일까?

URP·HDRP에서는 Shader의 SRP Batcher 호환성과 자동 GPU Instancing 경로가 경쟁할 수 있다.

Unity 공식 문서는 Custom Shader GPU Instancing을 사용하려면 SRP Batcher를 끄거나 해당 Shader를 SRP Batcher 비호환으로 만들어야 할 수 있다고 설명한다.

```text
호환 Custom Shader
→ SRP Batcher 경로 우선 가능

SRP Batcher 비호환 + Instancing 지원
→ GPU Instancing 경로 가능
```

Project 전체 SRP Batcher를 끄기보다 Instancing이 꼭 필요한 Shader와 Renderer 집단을 구분하는 편이 안전하다.

---

## Unity 6 URP의 기본 권장 방향

Unity 6 공식 Draw Call 최적화 선택 문서는 URP에서 다음 방향을 제시한다.

```text
SRP Batcher
→ Enable

Material GPU Instancing Checkbox
→ 불필요한 Shader Variant를 피하기 위해 Disable 권장
```

이는 일반적인 Mesh Renderer와 Material Workflow의 기본 권장사항이다.

대규모 동일 Mesh를 `RenderMeshInstanced`, `RenderMeshIndirect`, GPU Resident Drawer나 BatchRendererGroup으로 처리하는 고급 경로까지 GPU Instancing 개념 전체를 쓰지 말라는 의미는 아니다.

---

## Built-in Pipeline에서는 선택이 다르다

SRP Batcher는 Built-in Render Pipeline에서 지원되지 않는다.

```text
Built-in Pipeline
├─ SRP Batcher 사용 불가
├─ GPU Instancing 후보
├─ Static Batching 후보
└─ Dynamic Batching 제한적 검토
```

같은 Mesh가 반복되는 Built-in Project에서는 GPU Instancing의 상대적 중요도가 높다.

Pipeline별 권장사항을 섞어 적용하지 않는다.

---

## GPU Resident Drawer와 BRG

Unity 6의 GPU-driven Rendering은 `BatchRendererGroup`과 GPU Resident Drawer 같은 구조를 사용할 수 있다.

```text
GPU-driven 방향
├─ GPU-friendly Instance Data
├─ BatchRendererGroup
├─ GPU Culling
├─ Indirect Draw
└─ 적은 GameObject 제출 비용
```

이 구조는 전통적인 Material Checkbox 기반 자동 Instancing보다 넓은 범위의 Rendering Data를 관리한다.

SRP Batcher와 연동되는 경로와 호환 조건은 URP 설정과 Unity Version에 따라 달라진다.

단순 비교 글에서는 `자동 GPU Instancing`과 `명시적 GPU-driven Rendering`을 구분하는 것이 중요하다.

---

## RenderMeshInstanced를 선택하는 경우

```text
적합 가능성
├─ 동일 Mesh·Material이 대량 반복
├─ GameObject Component 비용이 큼
├─ Instance Transform을 배열로 관리 가능
├─ Group Bounds와 Lighting을 직접 관리 가능
└─ 한 Frame마다 직접 제출 가능
```

SRP Batcher는 10,000개의 Renderer Draw 준비를 줄여도 Renderer Component와 Draw 자체가 남을 수 있다.

명시적 Instancing은 Draw와 GameObject 수를 더 크게 줄일 수 있지만 Culling, LOD, Motion Vector와 Lifecycle 구현 비용이 생긴다.

---

## RenderMeshIndirect를 선택하는 경우

Instance가 매우 많고 GPU에서 Visibility를 판정해야 한다면 Indirect Rendering을 검토한다.

```text
Compute Shader
├─ Frustum Culling
├─ Occlusion Culling
├─ LOD 분류
└─ Visible Instance Count 작성
        │
        ▼
Indirect Draw
```

CPU가 모든 Instance Transform을 읽어 Group을 구성하는 병목을 줄일 수 있다.

Compute Shader 지원, Buffer Synchronization과 Custom Shader 복잡도가 증가한다.

수천 Object가 아니라면 SRP Batcher와 자동 Renderer Workflow가 더 단순할 수 있다.

---

## 사례 1: 다양한 Building

```text
Scene
├─ 서로 다른 Mesh 500개
├─ 서로 다른 Material Color
├─ 모두 URP Lit Variant 동일
└─ Transform은 각각 다름
```

GPU Instancing은 Mesh가 다르므로 큰 Group을 만들기 어렵다.

SRP Batcher는 같은 Variant의 Draw를 긴 Batch로 처리할 수 있다.

```text
권장 출발점
SRP Batcher
```

움직이지 않는 Geometry라면 Static Batching과 Memory·Culling도 비교한다.

---

## 사례 2: 숲의 같은 Tree

```text
Scene
├─ Tree Mesh 3종
├─ Material 3종
├─ Instance 30,000개
└─ Transform과 Color만 다름
```

세 Mesh·Material Group으로 Instanced Draw를 구성하기 좋다.

```text
권장 검토
├─ GPU Instancing
├─ Spatial Chunk
├─ LOD별 Instance Group
└─ GPU Culling / Indirect
```

SRP Batcher만 사용하면 Tree Renderer별 Draw가 남을 수 있다.

---

## 사례 3: Character 100명

```text
Scene
├─ Skinned Mesh Renderer
├─ Character별 Pose
├─ Material은 유사
└─ Shader Variant 동일
```

일반 GPU Instancing은 Skinned Mesh Renderer를 자동으로 묶지 못한다.

SRP Batcher는 Draw State 준비를 줄일 수 있다.

```text
권장 출발점
SRP Batcher + LOD + Skinning Profile
```

더 큰 규모에는 Animation Texture와 GPU Skinning 전용 Crowd System을 검토한다.

---

## 사례 4: 색이 다른 Projectile

```text
Scene
├─ 같은 Sphere Mesh
├─ 같은 Material
├─ Projectile 5000개
├─ Color와 Transform만 다름
└─ 생성·삭제가 빈번함
```

Instanced Property로 Color를 전달하는 GPU Instancing에 적합하다.

GameObject와 MaterialPropertyBlock 5000개보다 Array·Buffer 기반 명시적 Instancing을 비교할 수 있다.

SRP Batcher 경로를 포기하는 대신 줄어드는 Draw와 Component 비용이 더 큰지 측정한다.

---

## 사례 5: Material이 많은 Prop

```text
Scene
├─ Mesh도 다름
├─ Texture와 Color도 다름
├─ Shader Variant는 같음
└─ MaterialPropertyBlock 없음
```

GPU Instancing Group은 거의 만들어지지 않는다.

SRP Batcher는 Material이 달라도 같은 Variant를 기준으로 CPU State 비용을 줄일 수 있다.

Texture Atlas나 Array로 Material 상태까지 줄일 수 있지만 Memory와 Authoring Trade-off가 있다.

---

## 선택 표

| 조건 | SRP Batcher | GPU Instancing |
| --- | --- | --- |
| Render Pipeline | URP·HDRP·Custom SRP | 모든 Pipeline, 제약 확인 |
| Mesh | 서로 달라도 가능 | 같은 Mesh·SubMesh |
| Material | 달라도 같은 Variant 가능 | 같은 Material 중심 |
| Draw Call 수 | 남을 수 있음 | Instance Group당 감소 |
| 주요 이점 | Draw당 CPU State 준비 감소 | Draw 제출 수 감소 |
| Per-object 변화 | Material 또는 Object Buffer | Instanced Property |
| MaterialPropertyBlock | 비호환 | Instanced Property에 활용 가능 |
| Skinned Mesh | 지원 | 일반 경로 미지원 |
| Particle | 미지원 | 별도 Particle 지원 경로 |
| Culling | Renderer별 Unity Culling | 자동 또는 Group·직접 Culling |
| 구현 복잡도 | 호환 Shader면 낮음 | 자동은 낮고 Indirect는 높음 |

표는 출발점이며 최종 선택은 실제 Profiler 결과로 결정한다.

---

## 우선 판단 질문

```text
1. URP·HDRP인가?
   ├─ 예 → SRP Batcher를 기본 기준으로 측정
   └─ 아니오 → GPU Instancing·Mesh Batching 검토

2. 같은 Mesh·Material이 많이 반복되는가?
   ├─ 예 → GPU Instancing A/B Test
   └─ 아니오 → SRP Batcher가 넓게 적용 가능

3. Skinned Mesh인가?
   ├─ 예 → SRP Batcher 또는 전용 Skinning 구조
   └─ 아니오 → 두 방식 후보

4. Renderer별 Property가 필요한가?
   ├─ Instanced Property 가능 → GPU Instancing 후보
   └─ Material Variant 유지 → SRP Batcher 후보
```

하나의 Project 안에서도 Object Group마다 답이 달라질 수 있다.

---

## 두 기능을 동시에 켜면 어떻게 될까?

Unity는 Renderer의 Static 여부, Shader와 Mesh 조건에 따라 사용할 최적화 경로를 선택한다.

```text
Scene
├─ Static Mesh → Static Batching 가능
├─ SRP 호환 Dynamic Mesh → SRP 경로
├─ Instancing 호환 Remaining Mesh → GPU Instancing 가능
└─ 나머지 → 일반 Draw 또는 다른 Batching
```

하나의 GameObject가 모든 최적화 방식을 동시에 적용받는 것은 아니다.

Unity Version, GPU Resident Drawer와 Pipeline 설정에 따라 우선순위가 달라질 수 있다.

Frame Debugger에서 실제 선택된 Path를 확인한다.

---

## Profiler에서 비교할 지표

```text
CPU
├─ Main Thread Rendering Time
├─ Render Thread Time
├─ Material / State Setup
├─ Instance Data 수집·Upload
└─ Draw Dispatch

Rendering Statistics
├─ Draw Calls
├─ Batches
├─ SetPass Calls
└─ Instance Count

GPU
├─ Vertex 처리량
├─ Fragment / Overdraw
├─ Shadow Pass
└─ 전체 GPU Frame Time
```

SRP Batcher의 성공은 Draw Call 감소보다 CPU Rendering ms 감소로 본다.

GPU Instancing의 성공은 Instanced Draw 수와 CPU 제출 감소가 Instance Data Upload 비용보다 큰지 확인한다.

---

## Frame Debugger에서 비교한다

### SRP Batcher

```text
RenderLoopNewBatcher.Draw
└─ SRP Batch
   ├─ Draw Call 수
   ├─ Shader Keyword
   └─ Batch Break Reason
```

### GPU Instancing

```text
Draw Mesh (Instanced)
├─ Mesh와 SubMesh
├─ Material
├─ Pass
└─ Instance 수
```

두 결과가 보이지 않으면 Shader 호환성, MaterialPropertyBlock, Instancing 설정과 Pipeline 우선순위를 확인한다.

---

## 공정한 A/B Test

세 가지 구성을 비교할 수 있다.

```text
Test A
SRP Batcher On
Material GPU Instancing Off

Test B
대상 Shader의 SRP Batcher 경로 제외
GPU Instancing On

Test C
명시적 RenderMeshInstanced 또는 Indirect
```

Project 전체 SRP Batcher를 끄면 다른 수많은 Renderer의 성능이 함께 변한다.

가능하면 비교 대상 Shader와 Object Group만 격리된 Test Scene에서 측정한다.

---

## 고정해야 할 조건

- 동일한 Camera 경로와 FOV
- 동일한 Visible Object 수
- 동일한 Mesh·Material·Keyword
- 동일한 LOD와 Culling 결과
- 동일한 Light와 Shadow
- 동일한 Graphics API와 Build Type
- 동일한 Render Scale과 Resolution
- 동일한 Property Update 빈도
- 동일한 VSync와 Frame Cap

```text
측정 예시

SRP Batcher
Draws 5000, CPU Render 6.0 ms, GPU 9.0 ms

GPU Instancing
Draws 50, CPU Render 4.5 ms, GPU 9.3 ms
```

Draw는 크게 줄어도 Bounds와 Culling 때문에 GPU가 늘 수 있으므로 CPU·GPU를 함께 기록한다.

---

## Property Update 빈도를 포함한다

정적인 Instance Data와 매 Frame 변하는 Instance Data는 비용이 다르다.

```text
Static Transform 10,000개
→ Buffer 재사용 가능성

Animated Transform 10,000개
→ Matrix 수집과 Upload 반복
```

SRP Batcher에서도 Material Property를 매 Frame 바꾸면 Persistent Buffer 갱신이 필요하다.

실제 Gameplay의 Update 빈도를 Test에 포함한다.

정지 Screenshot만으로 선택하면 Runtime Animation 비용을 놓칠 수 있다.

---

## Culling 품질을 포함한다

```text
SRP Renderer Path
→ 개별 Bounds Culling

큰 Instanced Group
→ Group Bounds Culling
→ 일부만 보여도 전체 Instance 제출 가능
```

Instancing Draw 수만 최소화하려고 World 전체를 하나의 Group으로 만들면 GPU Vertex와 Fragment가 늘 수 있다.

Spatial Chunk 크기를 바꾸며 CPU Draw 수와 GPU Visible Work의 균형을 찾는다.

---

## Platform별 결과가 다른 이유

```text
영향 요소
├─ CPU Draw Call 비용
├─ Graphics API
├─ Driver
├─ GPU Instance 처리
├─ Buffer Upload Bandwidth
├─ GPU Culling 지원
└─ 목표 FPS
```

Unity 공식 문서는 GPU Instancing의 Property 수집·Upload Overhead가 이점을 넘어설 수 있다고 설명한다.

SRP Batcher도 Shader가 최적화되지 않은 저성능 Device에서는 비활성화가 빠를 수 있다.

PC 결과를 Mobile과 Console에 그대로 적용하지 않는다.

---

## 유지보수 비용

```text
SRP Batcher
├─ URP Shader Convention 준수
├─ UnityPerMaterial Layout 유지
├─ Keyword 관리
└─ 일반 Renderer Workflow 유지

Explicit GPU Instancing
├─ Instance Array·Buffer 관리
├─ Culling과 LOD
├─ Lighting와 Shadow
├─ Motion Vector
├─ Lifecycle
└─ Custom Shader
```

성능 차이가 작다면 더 단순하고 검증된 경로가 장기적으로 유리할 수 있다.

Indirect Rendering의 구현·Debug 비용도 Project 예산에 포함한다.

---

## 흔한 오해

### 둘 다 Batcher이므로 같은 기능이다

SRP Batcher는 State 준비 비용을 줄이고 GPU Instancing은 같은 Mesh의 Draw 수를 줄인다.

### SRP Batcher가 켜지면 Draw Call이 줄어야 한다

Draw Call은 유지될 수 있으며 CPU Main·Render Thread 시간이 줄어드는 것이 핵심이다.

### GPU Instancing은 Material이 달라도 같은 Mesh면 된다

기본적으로 같은 Mesh와 Material·Shader Pass가 호환되어야 한다.

### 같은 Shader Asset이면 SRP Batch된다

Keyword가 다른 Shader Variant는 Batch를 끊을 수 있다.

### MaterialPropertyBlock은 두 방식 모두에 좋다

Instanced Property 전달에는 사용할 수 있지만 SRP Batcher와는 호환되지 않는다.

### GPU Instancing은 GPU Geometry 비용도 줄인다

Draw는 줄지만 모든 Instance의 Vertex와 Fragment는 처리해야 한다.

### SRP Batcher는 Skinned Mesh를 지원하지 않는다

Mesh 결합 방식이 아니므로 Skinned Mesh Renderer도 호환될 수 있다.

### URP에서는 GPU Instancing을 절대 쓰면 안 된다

일반 Material Checkbox는 비활성화가 권장되지만 대규모 동일 Mesh와 GPU-driven Rendering에는 명시적 Instancing 경로가 적합할 수 있다.

### 둘 다 켜면 모든 Object에 둘 다 적용된다

Unity는 Object의 Mesh, Shader와 Rendering 설정에 따라 일부 최적화 경로를 선택한다.

### Draw Call이 가장 적은 구성이 항상 빠르다

Instance Data Upload, Culling 손실과 GPU 작업이 늘 수 있어 전체 Frame Time으로 판단해야 한다.

---

## 최종 선택 절차

```text
1. CPU Draw 병목인지 확인
2. Object를 Mesh·Material 반복성으로 분류
3. URP·HDRP는 SRP Batcher를 Baseline으로 설정
4. Shader 호환성과 Batch Break를 정리
5. 동일 Mesh 대량 Group만 GPU Instancing 후보로 분리
6. Per-instance Data 크기와 Update 빈도 확인
7. Spatial Chunk와 Culling 방식 결정
8. SRP·Automatic Instancing·Explicit API 비교
9. CPU·GPU·Memory와 화면 결과 기록
10. Target Device별 최적 경로 선택
```

Project 전체에 하나의 답을 적용하기보다 Environment, Foliage, Character와 Effect Group별로 선택한다.

Unity Version과 Render Pipeline 기능이 바뀌면 같은 Scene을 다시 측정한다.

---

## 정리

SRP Batcher는 같은 Shader Variant를 사용하는 Draw의 Material Data를 GPU Memory에 유지하고 Bind·Draw State 준비를 효율화해 Draw Call당 CPU 비용을 줄인다.

GPU Instancing은 같은 Mesh와 Material의 여러 Object를 Instance Data 배열로 전달해 실제 Draw Call 수를 줄인다.

SRP Batcher는 서로 다른 Mesh와 Material에도 적용될 수 있고 Skinned Mesh를 지원하지만 Draw Call 자체는 남을 수 있다.

GPU Instancing은 동일 Mesh 반복에 강하지만 일반 Skinned Mesh를 지원하지 않고 Instance Property 수집·Upload와 Group Culling 비용이 생긴다.

MaterialPropertyBlock은 SRP Batcher 호환성을 깨뜨리지만 Shader에 선언된 Instanced Property를 GPU Instancing에 전달하는 데 사용할 수 있다.

Unity 6의 일반적인 URP Workflow에서는 SRP Batcher 활성화를 기본으로 권장하지만 대규모 동일 Mesh와 GPU-driven Rendering에는 명시적 Instancing API를 별도로 검토할 수 있다.

Frame Debugger에서 SRP Batch의 Draw·Break Reason과 `Draw Mesh (Instanced)`의 Instance 수를 확인하고 Profiler에서 CPU State 준비·Instance Upload·GPU 시간을 비교해야 한다.

최종 선택은 기능 이름이나 Draw Call 숫자가 아니라 Object의 Mesh 반복성, Shader Variant, Property Update, Culling과 Target Device의 전체 Frame Time으로 내려야 한다.
