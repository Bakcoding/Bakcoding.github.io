---
title: "[Unity 렌더링] 9-3. Static Batching은 어떻게 동작할까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - StaticBatching
  - DrawCall
  - Optimization
permalink: /programming/unity-9-3-how-static-batching-works/
toc: true
toc_sticky: true
date: 2026-08-16
last_modified_at: 2026-08-16
---

Static Batching은 움직이지 않는 여러 Mesh의 Vertex와 Index를 공유 Buffer에 구성해 Render State 변경과 Draw 준비 비용을 줄이는 방식이다.

```text
Static Mesh A ┐
Static Mesh B ├─ World Space Combined Buffer
Static Mesh C ┘
```

Object는 Scene Hierarchy에서 각각 유지되지만 Rendering에 사용할 Geometry Data는 Batch 단위로 준비된다.

매 Frame Mesh를 결합하지 않아 CPU 비용을 절약할 수 있는 대신 추가 Memory와 개별 Transform 제한이 생긴다.

---

## Static의 의미

Static Batching에서 `Static`은 Object의 Position, Rotation과 Scale이 Runtime에 개별적으로 변하지 않는다는 의미다.

```text
Static Batching에 적합
├─ Building
├─ Wall
├─ Floor
├─ 고정된 Rock
└─ 움직이지 않는 Environment Prop

적합하지 않음
├─ Character
├─ Door
├─ Elevator
├─ Moving Platform
└─ 흔들리는 Object Transform
```

Mesh의 Vertex를 World Space 기준으로 미리 구성하므로 나중에 Object 하나만 움직이기 어렵다.

단순히 현재 정지해 있다는 의미가 아니라 게임 실행 중에도 Transform이 변하지 않아야 한다.

---

## 일반적인 Mesh Rendering

일반 Renderer는 Mesh Vertex를 Object의 Local Space에 저장한다.

```text
Local Vertex
    │ ObjectToWorld Matrix
    ▼
World Position
    │ ViewProjection Matrix
    ▼
Clip Position
```

같은 Cube Mesh를 여러 Object가 공유할 수 있다.

```text
Shared Cube Mesh
├─ Object A + Matrix A
├─ Object B + Matrix B
└─ Object C + Matrix C
```

Mesh Memory는 효율적으로 공유하지만 Object별 Matrix와 Draw 작업이 필요할 수 있다.

---

## Static Batching의 Vertex 처리

Static Batching은 각 Object의 Local Vertex에 Transform을 적용해 World Space 기준 Geometry로 구성한다.

```text
Object A
Local Vertex × Matrix A → World Vertex A

Object B
Local Vertex × Matrix B → World Vertex B

Object C
Local Vertex × Matrix C → World Vertex C
```

변환된 결과를 공유 Vertex Buffer와 Index Buffer에 배치한다.

```text
Combined Vertex Buffer
┌────────────┬────────────┬────────────┐
│ Mesh A     │ Mesh B     │ Mesh C     │
└────────────┴────────────┴────────────┘

Combined Index Buffer
┌────────────┬────────────┬────────────┐
│ Index A    │ Index B    │ Index C    │
└────────────┴────────────┴────────────┘
```

Unity 공식 문서는 Static Batching을 여러 Static Mesh를 World Space 좌표의 Vertex·Index Buffer로 결합하는 방식으로 설명한다.

---

## Build Time에 준비할 수 있는 이유

Object가 움직이지 않으므로 World Space Vertex 결과를 매 Frame 다시 계산할 필요가 없다.

```text
Build 또는 Load 단계
├─ 호환 Renderer 수집
├─ Vertex World Transform
├─ Combined Buffer 구성
└─ Renderer와 Buffer Range 연결

Runtime Frame
└─ 준비된 Buffer Range를 사용해 Rendering
```

Dynamic Batching처럼 매 Frame CPU가 작은 Mesh의 Vertex를 변환하고 합치는 비용이 없다.

정적인 Environment가 많은 Scene에서 유리한 이유다.

---

## GameObject가 하나로 합쳐지는 것은 아니다

Static Batching은 Scene Hierarchy의 GameObject를 삭제하거나 하나의 GameObject로 바꾸는 기능이 아니다.

```text
Hierarchy
├─ Wall_A
├─ Wall_B
└─ Wall_C

Rendering Buffer
└─ Wall_A + Wall_B + Wall_C Geometry
```

각 Renderer의 Bounds와 활성 상태 같은 정보는 남을 수 있다.

따라서 Editor에서 Object를 따로 선택할 수 있고 Unity는 개별 Renderer의 Visibility를 판정할 수 있다.

수동으로 Mesh를 완전히 합치는 방식과 중요한 차이다.

---

## 같은 Material이 필요한 이유

Geometry를 같은 Buffer에 넣는 것과 같은 Draw State로 그리는 것은 별개다.

```text
Mesh A → Material Stone
Mesh B → Material Stone
Mesh C → Material Wood
```

Stone과 Wood가 서로 다른 Texture와 Material State를 사용하면 같은 Draw로 처리하기 어렵다.

```text
Batch Group 1
└─ A + B: Stone Material

Batch Group 2
└─ C: Wood Material
```

Static Batching은 같은 Material을 사용하는 Mesh에서 State Update를 줄이는 방식이다.

Material과 Shader Variant가 다양하면 Static으로 표시해도 Batch 수가 충분히 줄지 않을 수 있다.

---

## Vertex Layout도 호환되어야 한다

같은 Vertex Buffer 구조로 묶으려면 Mesh가 사용하는 Vertex Attribute 구성이 호환되어야 한다.

```text
Mesh A
Position + Normal + UV0

Mesh B
Position + Normal + Tangent + UV0 + UV1
```

Attribute Layout이 다르면 Buffer 구성이나 Shader 입력 조건이 달라 별도 Batch가 필요할 수 있다.

다음 요소를 확인한다.

- Position
- Normal
- Tangent
- Vertex Color
- UV Channel
- Lightmap UV
- Skinning Data 유무

사용하지 않는 Vertex Attribute도 Import Data와 Memory에 영향을 줄 수 있다.

---

## SubMesh와 Material Slot

Mesh 하나가 여러 SubMesh를 가지면 Material별 Rendering 범위가 나뉜다.

```text
Building Mesh
├─ SubMesh 0: Wall Material
├─ SubMesh 1: Window Material
└─ SubMesh 2: Roof Material
```

Static Batching을 적용해도 서로 다른 Material Slot은 별도 Batch와 Draw를 만들 수 있다.

GameObject 수만 줄이거나 Static Flag만 켠다고 Material 경계가 사라지는 것은 아니다.

불필요하게 많은 SubMesh와 Material Slot이 없는지 확인한다.

---

## 개별 Culling은 어떻게 유지할까?

Unity는 Combined Buffer 안에서 각 Renderer가 차지하는 Index 범위를 추적할 수 있다.

```text
Combined Buffer
┌─────────┬─────────┬─────────┬─────────┐
│ A Range │ B Range │ C Range │ D Range │
└─────────┴─────────┴─────────┴─────────┘

Camera Visible
A: Yes
B: No
C: Yes
D: Yes
```

각 Object의 Bounds를 기준으로 Visibility를 판정해 보이는 범위만 Draw할 수 있다.

따라서 Static Batching은 수동으로 하나의 Mesh로 합쳐 Bounds도 하나가 되는 경우보다 Culling Granularity를 유지하기 쉽다.

그러나 Visibility 결과에 따라 하나의 Batch가 여러 Draw로 분리될 수 있다.

---

## Culling 때문에 Batch가 나뉘는 예

Combined Buffer에서 A, B, C, D가 순서대로 배치되어 있다고 가정한다.

```text
Buffer Range
[ A ][ B ][ C ][ D ]

Visibility
  O    X    O    O
```

B가 Camera Frustum 밖이면 A와 C·D 사이에 빈 구간이 생긴다.

```text
Draw 1 → A Range
Draw 2 → C + D Range
```

Unity 공식 문서는 Mesh가 Camera 밖이라 Culling되면 Combined Vertex Buffer의 간격을 피하기 위해 Batch를 둘로 나눌 수 있다고 설명한다.

Static Batching이 항상 Material당 정확히 한 Draw를 보장하지 않는 이유다.

---

## 수동 Mesh 결합과의 차이

```text
Static Batching
├─ GameObject와 Renderer 정보 유지
├─ 개별 Visibility 판정 가능
└─ Visibility에 따라 Draw Range 분할 가능

Manual CombineMeshes
├─ 실제 Mesh 하나로 결합 가능
├─ Bounds 하나로 Culling
└─ 일부만 보여도 전체 Mesh Rendering 가능
```

수동 결합은 Draw 수를 더 예측하기 쉬울 수 있지만 개별 Object Culling을 잃는다.

넓은 Scene 전체를 하나로 합치면 Camera에 작은 일부만 보여도 많은 Geometry가 처리될 수 있다.

Room, Chunk와 Spatial Cell 단위의 결합이 필요한 이유다.

---

## Static Batching의 CPU 이점

호환되는 Static Mesh는 공통 Buffer와 Render State를 사용해 Draw 준비를 줄일 수 있다.

```text
Before
Mesh A Buffer Bind → State → Draw
Mesh B Buffer Bind → State → Draw
Mesh C Buffer Bind → State → Draw

After
Combined Buffer Bind → 공통 State
└─ Visible Range를 효율적으로 Draw
```

다음 CPU 비용을 줄일 가능성이 있다.

- 반복 Vertex·Index Buffer Binding
- Material Render State 변경
- 개별 Draw Command 준비
- Graphics API Submission

효과는 Material 호환성과 실제 Visible Range에 따라 달라진다.

---

## GPU 이점과 한계

Static Batching의 주된 목적은 CPU Rendering Overhead를 낮추는 것이다.

Triangle 수와 Fragment Shader 계산이 자동으로 줄지는 않는다.

```text
Before: Triangle 100k
After : Triangle 100k
```

오히려 Batch와 Culling 구성에 따라 보이지 않는 Geometry가 더 포함되면 GPU 작업이 늘 수 있다.

Draw Call 감소만 보고 GPU Frame Time도 같은 비율로 줄 것이라 기대하면 안 된다.

---

## Memory가 증가하는 이유

여러 Object가 하나의 Mesh Asset을 공유해도 Static Batching은 각 Object의 World Space Vertex 결과를 Combined Buffer에 저장해야 한다.

```text
원본 Shared Mesh
└─ Tree Mesh 1개

Static Batch
├─ Tree 0의 World Vertex Copy
├─ Tree 1의 World Vertex Copy
├─ Tree 2의 World Vertex Copy
└─ ...
```

동일한 Tree를 숲에 수천 개 배치하면 Geometry가 반복 복사되어 Memory 사용량이 크게 늘 수 있다.

Unity 공식 문서도 밀집된 숲의 Tree를 Static으로 표시하면 Combined Mesh를 저장하는 CPU Memory에 큰 영향을 줄 수 있다고 경고한다.

반복 Mesh가 많다면 GPU Instancing이 더 적합할 수 있다.

---

## 간단한 Memory 예시

Tree Mesh의 Vertex Data가 200 KiB이고 1000개를 배치했다고 가정한다.

```text
Shared Mesh 방식
약 200 KiB + Object Data

World Space Vertex가 반복된 Combined Data의 단순 규모
200 KiB × 1000
≈ 195 MiB
```

실제 Unity Memory Layout, Index Buffer, 압축과 Batching 분할에 따라 값은 달라진다.

예시는 동일 Mesh 반복에서 Geometry Copy가 얼마나 커질 수 있는지 보여 주기 위한 계산이다.

Memory Profiler에서 실제 Native와 Mesh Memory를 확인해야 한다.

---

## GPU Instancing과 Memory 차이

```text
Static Batching
├─ Instance별 World Space Vertex Data 가능
└─ 서로 다른 Mesh도 Material 조건에 따라 결합 가능

GPU Instancing
├─ 동일 Mesh Geometry 1개 공유
└─ Instance별 Transform·Property만 전달
```

같은 Tree, Rock와 Prop가 반복된다면 Instancing은 Mesh Memory 공유 측면에서 유리하다.

서로 다른 형태의 고정된 Building Piece가 많다면 Static Batching이 적합할 수 있다.

두 방식은 `Static인가` 하나만으로 선택하지 않고 Mesh 반복성과 Memory를 함께 본다.

---

## 개별 Transform을 바꿀 수 없는 이유

Vertex가 이미 World Space 위치로 Combined Buffer에 기록되어 있다.

```text
Object B 이동 요청

기존 Buffer
[A World Vertex][B World Vertex][C World Vertex]
                  ↑ 이미 고정된 좌표
```

B만 움직이려면 해당 Vertex를 다시 변환하고 Buffer를 갱신해야 한다.

Static Batching은 이러한 Runtime 재구성을 전제로 하지 않는다.

Unity 공식 문서 기준으로 Runtime에는 Batch 전체의 Position, Rotation과 Scale은 바꿀 수 있지만 개별 Mesh의 Transform은 바꿀 수 없다.

---

## Batch Root를 움직이는 경우

Runtime API로 결합할 때 Root Transform 기준으로 Batch를 구성할 수 있다.

```text
Batch Root
├─ Static Child A
├─ Static Child B
└─ Static Child C
```

전체 Batch Root를 하나의 단위로 움직이는 것은 가능할 수 있다.

```text
가능
Batch Root 전체 이동

불가능한 전제
Child B만 독립 이동
```

움직이는 우주선 내부처럼 구조 전체는 함께 이동하지만 내부 부품은 고정된 경우 Runtime Batch Root 설계를 검토할 수 있다.

실제 Transform 요구사항과 API 동작을 Target Version에서 검증한다.

---

## Editor에서 Static Batching 설정

일반적인 설정 흐름은 다음과 같다.

```text
1. Project의 Static Batching 기능 활성화
2. 움직이지 않는 GameObject 선택
3. Static 또는 Batching Static Flag 설정
4. Build 또는 Play 과정에서 Batch 구성 확인
```

Render Pipeline과 Unity Version에 따라 설정 위치와 제공 옵션이 다를 수 있다.

GameObject를 Static으로 표시하면 Batching 외에도 Navigation, Occlusion과 GI 같은 다른 Static System에 영향을 줄 수 있다.

필요한 `Batching Static` 항목만 정확히 설정한다.

---

## Runtime Static Batching

Runtime에 생성된 고정 Object는 `StaticBatchingUtility.Combine`으로 준비할 수 있다.

```csharp
using UnityEngine;

public class RuntimeStaticBatchBuilder : MonoBehaviour
{
    [SerializeField] private GameObject batchRoot;

    private void Start()
    {
        StaticBatchingUtility.Combine(batchRoot);
    }
}
```

이 코드는 `batchRoot` 아래의 호환 가능한 GameObject를 Static Batching 대상으로 결합하는 기본 예시다.

매 Frame 호출하는 함수가 아니라 Object 배치가 완료된 뒤 한 번 구성하는 용도로 사용한다.

결합 후 Child를 개별적으로 움직이는 구조에는 적합하지 않다.

---

## Runtime 결합과 Read/Write

Runtime에 Mesh Vertex를 읽어 Combined Buffer를 만들려면 Mesh Data에 CPU 접근이 필요하다.

```text
Mesh Importer
└─ Read/Write Enabled
```

Unity 공식 문서는 Runtime Static Batching을 위해 대상 Mesh의 `Read/Write Enabled`를 켜도록 안내한다.

Read/Write가 켜지면 GPU용 Data 외에 CPU가 읽을 수 있는 Mesh Copy가 유지되어 Memory가 증가할 수 있다.

결합 후 CPU Copy가 필요 없다면 다음 API를 사용할 수 있다.

```csharp
mesh.UploadMeshData(true);
```

`markNoLongerReadable`이 `true`이면 CPU Copy를 제거할 수 있지만 이후 CPU에서 Mesh Data에 접근할 수 없다.

---

## UploadMeshData 사용 시 주의점

CPU Copy를 제거하면 Memory를 줄일 수 있지만 되돌리기 어려운 제약이 생긴다.

```text
UploadMeshData(true)
├─ CPU-side Mesh Data 제거 가능
├─ Runtime Memory 절감
└─ 이후 vertices, triangles 등 CPU 접근 불가
```

Runtime Mesh 수정, Collider 재생성, Procedural Deformation과 Debug Tool이 Mesh Data를 읽어야 한다면 사용할 수 없다.

정말 더 이상 CPU Read가 필요 없는 Mesh에만 적용한다.

---

## 64,000 Vertex Buffer 한도

Unity 6 공식 Batching 문서는 각 Static Batch Buffer가 최대 64,000 Vertex를 포함하며 필요하면 여러 Batch를 만든다고 설명한다.

```text
Static Mesh 전체 Vertex 150,000

Batch Buffer 0: 최대 64,000
Batch Buffer 1: 최대 64,000
Batch Buffer 2: 나머지
```

많은 Mesh를 Static으로 표시해도 무한히 하나의 Buffer와 Draw로 합쳐지는 것은 아니다.

Vertex 수, Material, Layout과 Platform 조건에 따라 여러 Batch로 분리된다.

이 한도는 문서의 현재 Unity 6 기준이며 Version별 구현을 확인해야 한다.

---

## Lightmap과 Static Batching

Baked Lighting을 사용하는 Renderer는 Lightmap Texture와 UV Scale·Offset을 가진다.

```text
Renderer A
├─ Lightmap Index 0
└─ ScaleOffset A

Renderer B
├─ Lightmap Index 0
└─ ScaleOffset B
```

같은 Lightmap Atlas를 사용하면 Batch에 유리할 수 있지만 Lightmap Index가 다르면 Texture Binding이 달라진다.

Static Batching은 World Vertex와 함께 Lightmap UV Data도 올바르게 유지해야 한다.

Lighting Bake 뒤에 Batch 수와 화면의 Lightmap 결과를 다시 확인한다.

---

## Reflection Probe와 Rendering Layer

Renderer별 Reflection Probe, Light Probe, Rendering Layer와 다른 Per-object Data가 Rendering 경로를 나눌 수 있다.

```text
같은 Material
├─ Renderer A: Probe 0
├─ Renderer B: Probe 1
└─ Renderer C: 다른 Rendering Layer
```

Material이 같다는 조건 하나만으로 항상 같은 Batch가 되는 것은 아니다.

Render Pipeline이 Draw마다 요구하는 Per-object Data와 Keyword가 호환되어야 한다.

Frame Debugger에서 실제 Batch Break 원인을 확인한다.

---

## Transparent Object의 제약

Transparent Object는 Blend 결과를 위해 Camera에서 먼 순서부터 그리는 것이 중요하다.

```text
Camera
  │
  ├─ Near Glass
  ├─ Mid Glass
  └─ Far Glass

일반적인 Draw Order: Far → Mid → Near
```

Material이 같아도 Sorting 순서와 Geometry가 Batch 구성과 충돌할 수 있다.

Unity 공식 문서도 Transparent GameObject는 Back-to-Front Sorting 때문에 Batching이 제한될 수 있다고 설명한다.

Static Batching만으로 Transparent Draw와 Overdraw 문제를 해결할 수 없다.

---

## Skinned Mesh Renderer를 지원하지 않는 이유

Skinned Mesh는 Bone Animation에 따라 Vertex Position이 매 Frame 변한다.

```text
Skinned Vertex
Local Position
× Bone Matrix
× Object Transform
→ 매 Frame World Position 변화
```

World Space Vertex를 고정해서 저장하는 Static Batching의 전제와 맞지 않는다.

Unity의 Mesh Batching은 Mesh Renderer를 대상으로 하고 Skinned Mesh Renderer는 지원하지 않는다.

Character와 Crowd에는 GPU Skinning, LOD와 Instancing 전용 방식을 검토한다.

---

## Shadow Pass에서도 효과가 있을까?

Static Renderer는 Camera Color Pass뿐 아니라 ShadowCaster Pass에도 참여한다.

```text
Static Building
├─ Main Color Pass
├─ Depth Pass
└─ ShadowCaster Pass × Cascade
```

Shadow Pass가 사용하는 Material Property가 같다면 Shadow Rendering에서도 Batching 기회가 생길 수 있다.

Color Texture가 달라도 Opaque ShadowCaster가 Depth만 기록하면 Shadow Pass의 상태가 호환될 수 있다.

Alpha Clipping은 Base Map Alpha와 Cutoff를 읽어야 하므로 Material 차이가 Batch를 나눌 수 있다.

---

## Multi-pass와 Renderer Feature

Static Batching은 Geometry를 효율적으로 준비하지만 Pass 수를 없애는 기능은 아니다.

```text
Static Batched Mesh
├─ Depth Prepass Batch
├─ Main Color Batch
├─ ShadowCaster Batch
└─ Custom Renderer Feature Pass
```

같은 Object가 필요한 Pass마다 다시 Rendering되는 구조는 남는다.

Frame Debugger에서 어느 Pass의 Draw가 줄었고 어떤 Pass는 여전히 반복되는지 확인한다.

---

## Static Batching과 SRP Batcher

두 기능은 CPU Rendering 비용을 줄이지만 접근 방식이 다르다.

```text
Static Batching
└─ 정적 Mesh를 World Space Combined Buffer에 구성

SRP Batcher
└─ 동일 Shader Variant Draw의 State와 Material Data 준비 효율화
```

Unity Version과 Render Pipeline은 두 방식의 우선순위와 함께 사용되는 방식을 내부적으로 결정할 수 있다.

Project에서 둘 다 켰다는 사실보다 Frame Debugger와 SRP Batcher Profiler의 실제 결과를 확인한다.

반복 Mesh는 GPU Instancing까지 포함해 비교해야 한다.

---

## Static Batching에 적합한 Scene

```text
적합 가능성이 높음
├─ 실내 Wall·Floor·Ceiling
├─ 고정된 Building Module
├─ 서로 다른 Mesh의 Environment Prop
├─ 동일 Material을 공유하는 Architecture
└─ Transform이 변하지 않는 Level Geometry
```

Object가 많고 CPU Draw 준비가 병목이며 Material 공유율이 높을수록 효과를 기대할 수 있다.

Spatial Cell별로 적절히 나누면 Culling과 Batching의 균형을 잡을 수 있다.

---

## 적합하지 않을 수 있는 Scene

```text
주의가 필요함
├─ 같은 Tree가 수천 개 반복되는 숲
├─ 대부분 Runtime에 움직이는 Object
├─ Material이 모두 다른 Prop
├─ Skinned Character Crowd
├─ Runtime Mesh 수정이 많은 Scene
└─ Memory가 매우 제한된 Platform
```

반복 Mesh는 Static Batching의 World Vertex Copy보다 GPU Instancing이 효율적일 수 있다.

Material이 지나치게 다양하면 Geometry를 같은 Buffer에 넣어도 State 변경과 Batch 분리가 남는다.

---

## Static Flag를 무조건 켜면 안 되는 이유

```text
모든 Environment를 Static
├─ Combined Mesh Memory 증가
├─ Batch Buffer 증가
├─ Load / Build Data 증가 가능
├─ Runtime 개별 이동 불가
└─ 다른 Static System에도 영향 가능
```

`움직이지 않는다`만으로 충분한 판단이 아니다.

Mesh 반복성, Material 호환성, Memory Budget, Visible Renderer 밀도와 CPU 병목을 확인한다.

Static Batching으로 얻는 CPU 시간보다 Memory 비용이 큰 Object는 제외한다.

---

## Spatial Group 단위로 나눈다

Level 전체를 하나의 Batch Root로 두기보다 Camera Visibility 구조에 맞춰 구역을 나눈다.

```text
Building
├─ Room A Batch
├─ Room B Batch
├─ Corridor Batch
└─ Exterior Batch
```

Open World는 Chunk나 Streaming Cell 단위로 구성할 수 있다.

```text
World Grid
┌────┬────┬────┐
│ C0 │ C1 │ C2 │
├────┼────┼────┤
│ C3 │ C4 │ C5 │
└────┴────┴────┘
```

이렇게 하면 Batch와 Scene Load·Unload, Culling 범위를 함께 관리하기 쉽다.

---

## LOD와의 관계

LOD Group은 Camera 거리에 따라 서로 다른 Renderer를 활성화한다.

```text
LOD 0: High Mesh
LOD 1: Medium Mesh
LOD 2: Low Mesh
```

각 LOD Renderer가 Static Batch에 포함될 수 있지만 한 시점에는 선택된 LOD만 보여야 한다.

Visibility 변화로 Combined Buffer Range 사이에 간격이 생겨 Batch가 여러 Draw로 나뉠 수 있다.

LOD가 많은 Outdoor Scene에서는 단순한 Static Object 수보다 실제 Batches와 Draw를 측정한다.

---

## Occlusion Culling과의 관계

개별 Renderer Bounds가 유지되면 Occlusion Culling 결과에 따라 일부 Range를 제외할 수 있다.

```text
Camera → Wall Occluder → Static Objects

Visible Range   : A
Occluded Ranges : B, C, D
```

GPU Geometry 작업은 줄지만 Visible Range가 불연속이면 Draw가 분할될 수 있다.

```text
Batching 목표: 적은 CPU Draw
Occlusion 목표: 보이지 않는 GPU 작업 제거
```

둘 사이의 균형은 Scene 구조와 Camera 경로에 따라 달라진다.

---

## Load Time과 Build Size

Combined Mesh Data를 준비하고 저장하는 방식은 Build Size와 Scene Load에 영향을 줄 수 있다.

```text
Static Batch Data
├─ Combined Vertex Buffer
├─ Combined Index Buffer
├─ Renderer Range 정보
└─ Material Group 정보
```

많은 Scene과 Variant를 포함하는 Project에서는 Runtime Frame Time뿐 아니라 Build 결과의 Data Size와 Load Peak Memory도 확인한다.

Addressables와 Additive Scene을 사용한다면 Scene 단위 Batch 구성과 Unload 후 Memory 반환도 Profile한다.

---

## Profiler에서 확인할 항목

```text
CPU
├─ Main Thread Rendering Time
├─ Render Thread Time
├─ Batching 관련 Marker
└─ Draw Call / SetPass 준비

Rendering Statistics
├─ Batches
├─ Saved by batching
├─ SetPass Calls
├─ Draw Calls
└─ Triangles / Vertices

Memory
├─ Mesh Memory
├─ Native Memory
├─ Read/Write Mesh Copy
└─ Scene Load Peak
```

Static Batching 전후 같은 Camera 경로와 Visible Object 조건을 사용한다.

Draw 수뿐 아니라 CPU ms, GPU ms와 Memory 증감량을 함께 기록한다.

---

## Frame Debugger에서 확인할 항목

```text
확인 질문
├─ 대상 Renderer가 Static Batch로 표시되는가?
├─ Material과 Shader Pass가 같은가?
├─ 어떤 Event에서 Batch가 나뉘는가?
├─ Culling된 Range 때문에 Draw가 분할됐는가?
├─ Shadow와 Depth Pass에서도 묶이는가?
└─ Lightmap·Probe·Keyword가 다른가?
```

Game View Stats의 `Saved by batching`만으로 Batch Break의 원인을 알 수 없다.

Frame Debugger에서 실제 Draw Event와 Material·Shader 상태를 연결해 확인한다.

---

## 비교 절차

```text
1. 대표 Static Object Group 선정
2. Batching 적용 전 CPU·GPU·Memory Capture
3. Material과 Vertex Layout 호환성 확인
4. Batching Static 적용
5. 동일 Camera 경로 재생
6. Batches·SetPass·CPU Time 비교
7. Mesh Memory와 Load Time 비교
8. Culling·LOD·Lighting 회귀 검사
```

전체 Scene에 한 번에 적용하면 어떤 Object Group이 이득과 Memory 증가를 만들었는지 구분하기 어렵다.

Building, Foliage와 Prop처럼 유형별로 나누어 적용한다.

---

## 간단한 판단 예시

### 서로 다른 Building Module 500개

```text
조건
├─ 움직이지 않음
├─ 공통 Material이 많음
├─ CPU Render Thread 병목
└─ Memory 여유 있음

→ Static Batching 검토 가치 높음
```

### 같은 Tree 5000개

```text
조건
├─ 같은 Mesh 반복
├─ Transform만 다름
├─ Memory 제한
└─ Shader가 Instancing 지원

→ GPU Instancing 우선 비교
```

### Runtime에 파괴되는 Wall

```text
조건
├─ 평소에는 정지
├─ 조각별 Destruction 필요
└─ Transform이 바뀜

→ 파괴 전·후 구조 분리 또는 다른 방식 검토
```

---

## 흔한 오해

### Static Batching은 GameObject를 하나로 합친다

Hierarchy의 GameObject는 유지되며 Rendering Geometry가 Combined Buffer에 구성된다.

### Static으로 표시하면 Material이 달라도 모두 한 Draw다

Material, Shader Variant, Vertex Layout과 Lighting 상태가 호환되어야 한다.

### Static Batch는 항상 Draw Call 하나다

Material과 Buffer 한도뿐 아니라 Culling된 Range 사이의 간격 때문에 여러 Draw로 나뉠 수 있다.

### 동일 Mesh를 반복할수록 Static Batching이 좋다

World Space Vertex Copy가 반복되어 Memory가 크게 늘 수 있으므로 GPU Instancing과 비교해야 한다.

### Static Batching은 Memory 비용이 없다

Combined Vertex·Index Buffer와 Runtime Read/Write Mesh Copy가 추가 Memory를 사용할 수 있다.

### Static Object는 절대로 움직일 수 없다

Batch 전체 Root Transform은 함께 바꿀 수 있는 구성이 있지만 개별 Mesh Transform 변경은 Static Batching 전제와 맞지 않는다.

### Static Batching은 GPU Triangle을 줄인다

기본 Triangle 수는 그대로이며 주로 CPU State Update와 Draw 준비를 줄인다.

### 수동 Mesh 결합과 완전히 같다

Static Batching은 개별 Renderer Culling을 유지할 수 있지만 수동 결합 Mesh는 일반적으로 하나의 Bounds로 Culling된다.

### 모든 Platform에서 같은 효과가 난다

CPU, Graphics API, Memory Budget과 Driver가 달라 Draw 절약과 Memory Trade-off도 달라진다.

---

## 정리

Static Batching은 움직이지 않는 여러 Mesh의 Vertex를 World Space로 변환해 공유 Vertex·Index Buffer에 구성하는 Draw Call 최적화 방식이다.

GameObject와 Renderer 정보는 유지할 수 있어 개별 Visibility를 판정하지만 Culling된 Buffer Range 때문에 Batch가 여러 Draw로 분리될 수 있다.

같은 Material, Shader Variant와 호환되는 Vertex·Lighting 상태를 가진 Mesh에서 Render State 변경과 CPU Draw 준비를 줄일 수 있다.

Vertex가 World Space에 고정되므로 Runtime에 개별 Object의 Position, Rotation과 Scale을 바꾸는 용도에는 적합하지 않다.

Combined Buffer는 동일 Mesh를 배치한 수만큼 World Vertex Data를 포함할 수 있어 숲처럼 반복 Mesh가 많은 Scene에서 Memory가 크게 증가할 수 있다.

Runtime 결합은 `StaticBatchingUtility.Combine`과 Read/Write 가능한 Mesh가 필요하며 결합 후 CPU Copy가 불필요하면 `UploadMeshData(true)`를 신중하게 검토한다.

Static Batching은 서로 다른 고정 Environment Mesh에 적합하고 동일 Mesh 반복은 GPU Instancing, 같은 Shader Variant의 다양한 Material은 SRP Batcher와 비교해야 한다.

최종 판단은 Batches 감소뿐 아니라 CPU Main·Render Thread 시간, GPU 작업, Mesh Memory, Culling과 Load Time을 Target Device에서 함께 측정해 내려야 한다.
