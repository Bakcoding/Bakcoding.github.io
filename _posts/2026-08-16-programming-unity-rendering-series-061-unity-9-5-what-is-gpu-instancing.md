---
title: "[Unity 렌더링] 9-5. GPU Instancing은 무엇일까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - GPUInstancing
  - DrawCall
  - Optimization
permalink: /programming/unity-9-5-what-is-gpu-instancing/
toc: true
toc_sticky: true
date: 2026-08-16
last_modified_at: 2026-08-16
---

GPU Instancing은 같은 Mesh와 Material을 사용하는 여러 Object를 하나의 Instanced Draw Call로 Rendering하는 방식이다.

```text
일반 Draw
Tree 0 → Draw
Tree 1 → Draw
Tree 2 → Draw

GPU Instancing
Tree Mesh + Material
└─ Instance 0, 1, 2 → Instanced Draw
```

Mesh Geometry는 한 번 Bind하고 Position, Rotation, Scale과 Color 같은 Instance별 Data만 배열 형태로 전달한다.

같은 Object가 반복되는 숲, Rock, Grass와 Projectile에서 CPU Draw 제출 비용을 줄일 수 있다.

---

## Instance란 무엇일까?

같은 원본 Mesh를 서로 다른 Transform과 Property로 그린 각각의 복사본을 Instance라고 한다.

```text
Shared Mesh: Tree
Shared Material: Leaves

Instances
├─ Tree 0: Position A, Scale 1.0, Color Green
├─ Tree 1: Position B, Scale 0.8, Color Yellow
└─ Tree 2: Position C, Scale 1.2, Color Green
```

Unity 공식 문서는 GPU Instancing을 같은 Mesh와 Material을 사용하는 여러 GameObject를 하나의 Draw Call로 Rendering하는 GPU 기능으로 설명한다.

각 Instance는 Geometry를 공유하지만 일부 Property는 다르게 가질 수 있다.

---

## 일반 Rendering과의 차이

Instancing이 없으면 Object마다 Transform Data를 설정하고 Draw를 제출할 수 있다.

```text
Bind Tree Mesh
Bind Leaves Material
Set Matrix 0
Draw Tree 0

Set Matrix 1
Draw Tree 1

Set Matrix 2
Draw Tree 2
```

Instancing에서는 Matrix 배열과 Instance 수를 한 번에 전달한다.

```text
Bind Tree Mesh
Bind Leaves Material
Upload Instance Data [0...N]
DrawInstanced N
```

CPU의 Draw Call과 반복 State 설정은 줄고 GPU가 한 Draw 안에서 여러 Instance를 처리한다.

---

## Geometry를 공유한다

Static Batching은 Object별 World Space Vertex가 Combined Buffer에 복사될 수 있다.

GPU Instancing은 같은 Mesh Buffer 하나를 재사용한다.

```text
Static Batching의 동일 Mesh 반복
├─ Tree 0 World Vertices
├─ Tree 1 World Vertices
└─ Tree 2 World Vertices

GPU Instancing
├─ Tree Vertices 1개
└─ Transform 0, 1, 2
```

동일 Mesh가 많이 반복될수록 Geometry Memory 공유 이점이 커진다.

서로 다른 Mesh를 하나의 기본 Instanced Draw로 묶는 기능은 아니다.

---

## GPU는 Instance를 어떻게 구분할까?

Instanced Draw에는 `Instance ID`가 제공된다.

```text
Instance ID 0 → Matrix[0], Color[0]
Instance ID 1 → Matrix[1], Color[1]
Instance ID 2 → Matrix[2], Color[2]
```

Vertex Shader는 현재 Instance ID를 이용해 해당 Object의 Transform과 Property를 읽는다.

개념적인 HLSL 구조는 다음과 같다.

```hlsl
uint id = input.instanceID;
float4x4 objectToWorld = instanceMatrices[id];
float4 positionWS = mul(objectToWorld, input.positionOS);
```

Unity Shader에서는 Pipeline과 Shader 방식에 맞는 Instancing Macro 또는 Shader Graph 기능을 사용한다.

---

## Transform은 Per-instance Data다

같은 Mesh를 다른 위치에 그리려면 Instance별 Object-to-World Matrix가 필요하다.

```text
Instance Buffer
┌─────────────┬─────────────┬─────────────┐
│ Matrix 0    │ Matrix 1    │ Matrix 2    │
└─────────────┴─────────────┴─────────────┘
```

GPU는 같은 Vertex를 각 Matrix로 변환한다.

```text
Tree Vertex × Matrix 0 → Tree 0 World Position
Tree Vertex × Matrix 1 → Tree 1 World Position
Tree Vertex × Matrix 2 → Tree 2 World Position
```

Dynamic Batching처럼 CPU가 모든 Vertex를 World Space로 변환해 복사하지 않는다.

---

## 다른 Color도 사용할 수 있다

Instance마다 Color, Emission과 Wind Strength 같은 값을 다르게 줄 수 있다.

```text
Shared Material
├─ Instance 0: Color Green
├─ Instance 1: Color Yellow
├─ Instance 2: Color Brown
└─ Instance 3: Color Green
```

Shader가 해당 Property를 Instanced Property로 선언해야 한다.

Material 자체를 복제하는 대신 Instance Buffer에서 값을 선택한다.

이렇게 하면 시각적 다양성을 유지하면서 같은 Instanced Draw에 포함될 수 있다.

---

## 모든 Property가 달라도 되는 것은 아니다

Instance별로 바꿀 값과 모든 Instance가 공유할 값을 구분한다.

```text
Shared Material State
├─ Shader Variant
├─ Base Texture
├─ Blend Mode
├─ Render Queue
└─ Pass

Per-instance Data
├─ Transform
├─ Color
├─ Wind Factor
└─ Custom Float / Vector
```

Texture와 Shader Keyword를 Instance마다 자유롭게 바꾸면 같은 Render State가 아니게 된다.

Texture 다양성이 필요하면 Texture Atlas, Texture Array 또는 Index 기반 Sample 구조를 검토한다.

---

## 같은 Material이 필요한 이유

Instanced Draw 안에서는 하나의 Material과 Shader Pass가 Binding된다.

```text
Instanced Draw
├─ Mesh: Rock
├─ Material: RockMaterial
└─ Instance Data: 100개
```

RockMaterial과 SnowRockMaterial이 서로 다른 Shader Variant나 Texture State를 사용하면 별도 Draw가 필요할 수 있다.

```text
Rock Material Group → Instanced Draw 1
Snow Material Group → Instanced Draw 2
```

Material Instance를 Object마다 복제하면 같은 Mesh라도 Batch가 나뉠 수 있다.

---

## SubMesh는 별도 Draw다

하나의 Mesh가 여러 SubMesh와 Material Slot을 가지면 SubMesh마다 Draw가 필요하다.

```text
Tree Mesh
├─ SubMesh 0: Trunk Material
└─ SubMesh 1: Leaves Material
```

Tree 100개를 Instancing해도 개념적으로 다음과 같이 나뉜다.

```text
Trunk SubMesh × 100 Instances → Instanced Draw
Leaves SubMesh × 100 Instances → Instanced Draw
```

Instancing은 Instance 수를 묶지만 Material과 SubMesh 경계를 없애지 않는다.

---

## 자동 GPU Instancing

Unity의 호환 Material과 Mesh Renderer를 사용하면 Scene의 GameObject를 자동으로 Instancing할 수 있다.

```text
조건
├─ 동일 Mesh
├─ 동일 Material
├─ Instancing 지원 Shader
├─ Material의 GPU Instancing 활성화
└─ 호환되는 Rendering 상태
```

Prebuilt Material에서는 Inspector의 다음 옵션을 사용한다.

```text
Material Inspector
└─ Advanced Options
   └─ Enable GPU Instancing
```

옵션이 보이지 않으면 해당 Prebuilt Shader가 GPU Instancing을 지원하지 않는 것이다.

---

## Frame Debugger에서 확인한다

GPU Instancing이 실제 적용되면 Frame Debugger에서 다음과 같은 Event를 확인할 수 있다.

```text
Draw Mesh (Instanced)
```

Event를 선택해 Mesh, Material, Pass와 Instance 수를 확인한다.

```text
확인 질문
├─ 예상한 Renderer가 같은 Draw에 들어갔는가?
├─ Material Instance가 분리되지 않았는가?
├─ Shader Variant가 같은가?
├─ Shadow Pass도 Instanced되는가?
└─ 몇 개의 Instance Group으로 나뉘었는가?
```

`Enable GPU Instancing`을 체크했다는 사실만으로 적용됐다고 단정하지 않는다.

---

## MaterialPropertyBlock으로 값을 다르게 준다

Material을 복제하지 않고 Renderer마다 Property를 설정하려면 `MaterialPropertyBlock`을 사용할 수 있다.

```csharp
using UnityEngine;

public class InstanceColor : MonoBehaviour
{
    private static readonly int BaseColorId =
        Shader.PropertyToID("_BaseColor");

    [SerializeField] private Color color = Color.white;

    private Renderer targetRenderer;
    private MaterialPropertyBlock propertyBlock;

    private void Awake()
    {
        targetRenderer = GetComponent<Renderer>();
        propertyBlock = new MaterialPropertyBlock();
    }

    private void OnEnable()
    {
        targetRenderer.GetPropertyBlock(propertyBlock);
        propertyBlock.SetColor(BaseColorId, color);
        targetRenderer.SetPropertyBlock(propertyBlock);
    }
}
```

Shader의 `_BaseColor`가 Instanced Property로 선언되어 있어야 같은 Instanced Draw에 값을 모을 수 있다.

MaterialPropertyBlock에 Non-instanced Property를 넣으면 Instancing이 비활성화될 수 있다.

---

## PropertyBlock을 재사용한다

Unity는 `SetPropertyBlock`에 전달한 내용을 내부적으로 복사한다.

매번 새 Object를 만들 필요가 없다.

```csharp
private readonly MaterialPropertyBlock block =
    new MaterialPropertyBlock();
```

```text
나쁜 Runtime Pattern
매 Frame × Renderer 수만큼 new MaterialPropertyBlock
→ Managed Allocation과 GC 가능

재사용 Pattern
Block 생성 후 값 갱신·재사용
```

값이 변하지 않는다면 매 Frame 다시 설정하지 않는다.

Property Update CPU 비용도 Instancing 이득에 포함해 측정한다.

---

## Built-in Pipeline Shader Macro

Built-in Render Pipeline의 Custom Vertex·Fragment Shader에서는 Instance ID를 전달하고 설정하는 Macro가 필요하다.

```hlsl
struct Attributes
{
    float4 positionOS : POSITION;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

Varyings vert(Attributes input)
{
    UNITY_SETUP_INSTANCE_ID(input);

    Varyings output;
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    output.positionCS = UnityObjectToClipPos(input.positionOS);
    return output;
}
```

Pipeline과 Unity Version에 맞는 Include와 Macro를 사용해야 한다.

예시는 Instance ID가 Vertex Stage에 설정되는 구조를 보여 준다.

---

## Instanced Property 선언

Built-in Pipeline의 개념적인 선언은 다음과 같다.

```hlsl
UNITY_INSTANCING_BUFFER_START(Props)
    UNITY_DEFINE_INSTANCED_PROP(float4, _InstanceColor)
UNITY_INSTANCING_BUFFER_END(Props)
```

Shader에서 현재 Instance의 값을 읽는다.

```hlsl
float4 color = UNITY_ACCESS_INSTANCED_PROP(Props, _InstanceColor);
```

Custom Shader가 Instanced Property를 사용하지 않아도 Transform Matrix를 올바르게 선택하려면 Instance ID 설정이 필요하다.

URP·HDRP Custom Shader와 Shader Graph는 Pipeline별 지원 방식과 SRP Batcher 호환성을 확인해야 한다.

---

## URP와 SRP Batcher

URP에서는 SRP Batcher가 기본적인 Draw CPU 비용을 줄이는 권장 경로다.

```text
SRP Batcher
└─ 동일 Shader Variant의 Draw 준비 비용 감소

GPU Instancing
└─ 동일 Mesh·Material의 여러 Instance를 한 Draw로 감소
```

Unity 공식 문서 기준으로 URP·HDRP Custom Shader의 GPU Instancing은 SRP Batcher를 비활성화하거나 해당 Shader를 SRP Batcher 비호환으로 만들어야 동작할 수 있다.

Prebuilt Material 문서도 URP·HDRP에서는 기본적으로 SRP Batcher 사용을 권장한다.

둘 중 하나를 이름만 보고 고르지 말고 실제 Object 분포와 CPU 시간을 비교한다.

---

## 왜 두 기능이 경쟁할 수 있을까?

Unity는 Renderer를 어떤 최적화 경로로 제출할지 선택해야 한다.

```text
Renderer Group
├─ SRP Batcher 호환 경로
│  └─ Draw는 남지만 State Setup 효율화
└─ GPU Instancing 경로
   └─ 같은 Mesh Instance를 Draw 하나로 결합
```

같은 Shader Variant를 쓰는 서로 다른 Mesh가 많으면 SRP Batcher가 유리할 수 있다.

같은 Mesh와 Material이 수천 번 반복되면 Instancing의 Draw 감소가 유리할 수 있다.

구체적인 비교 기준은 `SRP Batcher와 GPU Instancing은 무엇이 다를까?` 글에서 다룬다.

---

## 자동 Instancing의 CPU 비용

GPU Instancing도 공짜가 아니다.

Unity는 각 Draw를 위해 Instance Property를 여러 Memory 위치에서 수집하고 결합해 GPU에 Upload해야 한다.

```text
CPU
├─ 호환 Renderer 수집
├─ Instance Transform 수집
├─ PropertyBlock 값 수집
├─ Instance Buffer 구성
└─ GPU Upload와 Draw 제출
```

Instance 수가 매우 적거나 Property가 많으면 이 준비 비용이 줄어든 Draw Call 비용보다 클 수 있다.

Unity 공식 문서도 Platform과 GPU에 따라 Instancing Overhead가 이점을 넘어설 수 있다고 설명한다.

---

## Instance 수가 적을 때

같은 Mesh가 두 개뿐이라면 다음 두 방법의 차이가 작을 수 있다.

```text
일반 Draw 2회
vs
Instance Data 수집 + Instanced Draw 1회
```

Draw Call 하나를 절약하지만 Instance Buffer 구성과 Upload가 필요하다.

명확한 최소 개수는 Platform, API, Property 크기와 Shader에 따라 달라진다.

Object Group별 Instance 수 분포를 확인하고 작은 Group이 지나치게 많지 않은지 본다.

---

## Instance Data가 많을 때

Instance마다 Matrix 외에 많은 Property를 전달하면 Buffer가 커진다.

```text
Per-instance Data
├─ ObjectToWorld Matrix
├─ WorldToObject Matrix
├─ Previous Matrix
├─ Color
├─ Wind
├─ LOD Fade
└─ Custom Vectors
```

```text
Upload Size
= Instance Count × Instance당 Data 크기
```

Draw 수는 줄지만 CPU 수집, Memory Copy와 GPU Bandwidth가 증가한다.

정말 Instance마다 달라야 하는 값만 Instanced Property로 선언한다.

---

## RenderMeshInstanced

GameObject와 Mesh Renderer 없이 Script에서 같은 Mesh를 여러 번 Rendering하려면 `Graphics.RenderMeshInstanced`를 사용할 수 있다.

```csharp
using UnityEngine;

public class InstancedGrid : MonoBehaviour
{
    [SerializeField] private Mesh mesh;
    [SerializeField] private Material material;

    private readonly Matrix4x4[] matrices = new Matrix4x4[100];

    private void Start()
    {
        for (int i = 0; i < matrices.Length; i++)
        {
            Vector3 position = new Vector3(i % 10, 0f, i / 10);
            matrices[i] = Matrix4x4.TRS(
                position,
                Quaternion.identity,
                Vector3.one);
        }
    }

    private void Update()
    {
        RenderParams renderParams = new RenderParams(material);
        Graphics.RenderMeshInstanced(
            renderParams,
            mesh,
            0,
            matrices);
    }
}
```

Material의 Instancing이 활성화되고 Platform과 Shader가 지원해야 한다.

---

## API를 매 Frame 호출하는 이유

`RenderMeshInstanced`는 현재 Frame에 Mesh를 Rendering하는 함수다.

```text
Frame N     → API Call → Render
Frame N + 1 → API Call → Render
```

GameObject를 Scene에 영구 등록하는 함수가 아니다.

보여야 하는 Frame마다 호출하고 Instance Data, Bounds와 Lighting 정보를 관리해야 한다.

배열을 매 Frame 새로 생성하면 GC와 CPU 비용이 생기므로 Buffer와 Data Container를 재사용한다.

---

## 한 번에 Rendering할 수 있는 Instance 한도

Unity 6 `RenderMeshInstanced` API 문서 기준으로 한 번에 최대 1023 Instance를 Rendering할 수 있다.

하지만 실제 최대값은 Instance당 Data 크기에 따라 더 작아진다.

```text
기본 Data
ObjectToWorld + WorldToObject Matrix
→ 최대 511 Instance가 될 수 있음
```

Shader에 다음 옵션을 사용해 Uniform Scale을 가정하면 World-to-Object Matrix를 제거할 수 있다.

```hlsl
#pragma instancing_options assumeuniformscaling
```

Non-uniform Scale과 Normal Transform 정확성을 확인한 뒤 사용한다.

---

## 많은 Instance는 Chunk로 나눈다

Tree 10,000개를 한 번에 처리할 수 없다면 여러 Group으로 나눈다.

```text
10,000 Trees
├─ Chunk 0: Instance 0~511
├─ Chunk 1: Instance 512~1023
├─ Chunk 2: ...
└─ Chunk N
```

API의 최대 Instance 수만을 기준으로 자르기보다 Spatial Cell을 고려한다.

```text
World
┌────┬────┬────┐
│ C0 │ C1 │ C2 │
├────┼────┼────┤
│ C3 │ C4 │ C5 │
└────┴────┴────┘
```

Camera에 보이는 Chunk만 제출하면 Culling과 Draw 수의 균형을 잡을 수 있다.

---

## Group Bounds와 Culling

`RenderMeshInstanced`는 모든 Instance를 포함하는 Bounds를 계산하거나 `RenderParams.worldBounds`로 Override할 수 있다.

Unity는 이 Bounds를 기준으로 Instance Group 전체를 하나의 Entity처럼 Culling과 Sorting한다.

```text
Group Bounds
┌──────────────────────────────┐
│ Instance A                  B │
│              C               │
└──────────────────────────────┘
```

Bounds 일부만 Camera에 보여도 Group 전체 Instance가 Draw에 포함될 수 있다.

너무 넓은 Group은 보이지 않는 Instance까지 GPU가 처리하게 만든다.

---

## 개별 Instance Culling은 자동이 아닐 수 있다

명시적 `RenderMeshInstanced` Group은 전달된 전체 Instance를 Group Bounds 기준으로 처리한다.

```text
Group Bounds Visible
├─ Instance A: Camera 안
├─ Instance B: Camera 밖
└─ Instance C: Camera 밖

→ Group Draw에 A, B, C가 함께 포함될 수 있음
```

GameObject Renderer의 자동 Instancing과 명시적 API의 Culling 경로를 동일하게 가정하지 않는다.

대규모 Instance에는 CPU Culling, Spatial Chunk 또는 GPU Culling을 별도로 설계한다.

---

## RenderMeshIndirect

`Graphics.RenderMeshIndirect`는 Instance 수와 Drawing Argument를 `GraphicsBuffer`에서 읽는다.

```text
CPU 또는 Compute Shader
        │
        ▼
Indirect Argument Buffer
├─ Index Count
├─ Instance Count
├─ Start Index
└─ Base Vertex
        │
        ▼
RenderMeshIndirect
```

GPU Compute Shader가 Visible Instance를 판정하고 Instance Count를 기록하는 GPU-driven 구조를 만들 수 있다.

CPU가 모든 Instance를 읽어 Draw Count를 결정하지 않아도 된다.

Compute Shader를 지원하는 Platform과 Custom Shader가 필요해 복잡도가 높다.

---

## RenderMeshPrimitives

`Graphics.RenderMeshPrimitives`는 Instance Count를 함수 인자로 전달해 Custom Shader로 같은 Mesh를 여러 번 그린다.

```csharp
Graphics.RenderMeshPrimitives(
    ref renderParams,
    mesh,
    submeshIndex,
    instanceCount);
```

Shader의 `SV_InstanceID`로 각 Instance를 구분하고 Buffer에서 Transform과 Custom Data를 읽는 구조를 만들 수 있다.

GameObject Renderer가 필요 없는 Procedural Rendering에 적합하다.

어떤 API든 Bounds, Lighting, Shadow, Motion Vector와 Lifecycle을 직접 관리해야 할 수 있다.

---

## 자동 Renderer와 명시적 API

| 방식 | 장점 | 관리해야 할 것 |
| --- | --- | --- |
| Mesh Renderer 자동 Instancing | Unity Culling·Lighting·Component Workflow | 많은 GameObject와 Renderer CPU 비용 |
| RenderMeshInstanced | GameObject 없이 Instance Batch 직접 제출 | 배열, Bounds, Frame 호출, Lighting |
| RenderMeshIndirect | GPU-driven Culling과 Draw Count 가능 | Compute, Buffer, Custom Shader, 동기화 |
| RenderMeshPrimitives | Instance ID 기반 Procedural Rendering | Transform·Property Buffer와 Shader |

작은 Scene에서 복잡한 Indirect Pipeline을 만드는 것은 유지보수 비용이 더 클 수 있다.

Object 수와 실제 병목에 맞는 단계부터 선택한다.

---

## Light Probe와 Instancing

Dynamic GameObject Instance는 Light Probe Lighting을 사용할 수 있다.

```text
Instance Position
    │
    ▼
Light Probe 보간
    │
    ▼
Instance별 SH Lighting Data
```

`RenderMeshInstanced`에서는 `RenderParams.lightProbeUsage`를 `BlendProbes`로 설정해 Instance별 Probe Data를 준비할 수 있다.

직접 계산한 Data는 `CustomProvided`와 MaterialPropertyBlock을 사용할 수 있다.

Probe 보간과 SH Data Upload도 CPU·Memory 비용을 가지므로 Instance 수가 많을 때 Profile한다.

---

## Lightmap과 Instancing

Static GameObject도 같은 Lightmap Texture에 Bake되는 조건에서 Instancing과 함께 사용할 수 있다.

```text
Static Instances
├─ Contribute GI
├─ 같은 Lightmap Texture
└─ Instance별 Lightmap ScaleOffset
```

서로 다른 Lightmap Texture는 Texture Binding을 바꾸므로 Instanced Draw를 나눌 수 있다.

Lighting Bake 전후 Frame Debugger에서 실제 결과를 확인한다.

동일 Mesh를 반복해도 Lightmap Packing이 Group을 여러 개로 나눌 수 있다.

---

## Light Probe Proxy Volume

GPU Instancing은 Light Probe Proxy Volume을 사용할 수 있다.

모든 Instance가 포함되는 전체 공간에 대해 LPPV를 Bake해야 한다.

```text
LPPV Bounds
┌────────────────────────┐
│ Instance 0  1  2  ... │
└────────────────────────┘
```

Volume이 지나치게 크면 Lighting Data의 공간 해상도와 Memory가 문제가 될 수 있다.

Project의 Render Pipeline 지원과 Probe Data 전달 방식을 확인한다.

---

## Shadow Pass와 Instancing

같은 Mesh와 ShadowCaster Material State를 사용하는 Instance는 Shadow Pass에서도 Instancing될 수 있다.

```text
Main Color Pass
└─ Tree × 500 Instanced Draw

ShadowCaster Pass
├─ Cascade 0: Tree × Visible Instances
├─ Cascade 1: Tree × Visible Instances
└─ ...
```

Cascade와 Shadow Light마다 Instance Group이 다시 Drawing되는 구조는 남는다.

Instancing은 Draw Call을 줄이지만 전체 Vertex 처리 횟수를 자동으로 줄이지 않는다.

먼 Tree의 Cast Shadows와 Shadow Distance도 함께 조절한다.

---

## Vertex 비용은 그대로일 수 있다

Tree 1000개를 Instancing해도 GPU는 1000개 Tree의 Vertex를 변환해야 한다.

```text
Mesh Vertex 1000개
× Instance 1000개
= 최대 1,000,000 Vertex 처리
```

Draw Call은 하나 또는 소수로 줄지만 Geometry 작업량은 Instance 수에 비례한다.

LOD, Frustum Culling과 Occlusion Culling이 여전히 필요하다.

Draw Call 감소를 Polygon 감소와 혼동하면 안 된다.

---

## Fragment와 Overdraw도 그대로일 수 있다

Grass와 Leaves는 Instancing으로 CPU Draw 비용을 줄여도 Transparent 또는 Alpha Clipping Pixel 비용이 남는다.

```text
GPU Instancing
→ Draw Submission 감소

Foliage Overdraw
→ Fragment Shader와 Alpha Test 반복
```

GPU가 Fill-rate Bound라면 Instancing 후 Batches는 줄어도 GPU Frame Time 변화가 작을 수 있다.

Foliage LOD, Coverage, Alpha Texture와 Shader 비용을 별도로 최적화한다.

---

## LOD와 Instancing

LOD가 다르면 Mesh가 다르므로 한 Instanced Draw에 들어갈 수 없다.

```text
Tree LOD 0 Mesh → Instance Group 0
Tree LOD 1 Mesh → Instance Group 1
Tree LOD 2 Mesh → Instance Group 2
```

Camera 거리별로 Instance를 각 LOD Group에 분류한다.

LOD Cross Fade가 필요하면 Instance별 Fade Property와 Shader 지원이 필요할 수 있다.

Group 분류 CPU 비용과 LOD별 Draw 수를 함께 측정한다.

---

## Motion Vector

움직이는 Instance가 Temporal AA나 Motion Blur에 올바른 Motion Vector를 제공하려면 이전 Frame Transform이 필요하다.

```text
Current ObjectToWorld
        +
Previous ObjectToWorld
        │
        ▼
Motion Vector 계산
```

`RenderMeshInstanced`의 Custom Instance Data는 `prevObjectToWorld` Member를 제공할 수 있다.

Instance를 추가·삭제하거나 배열 순서를 바꿀 때 이전 Transform과 현재 Instance의 대응을 유지해야 한다.

잘못된 Data는 Ghosting과 Motion Blur Artifact를 만들 수 있다.

---

## Rendering Layer Mask

Instance별로 다른 Rendering Layer Mask가 필요할 수 있다.

```text
Instance Data
├─ objectToWorld
├─ prevObjectToWorld
└─ renderingLayerMask
```

Unity 6 `RenderMeshInstanced` Custom Data 구조는 정해진 이름과 Type의 `renderingLayerMask`를 선택적으로 사용할 수 있다.

그 외 임의 Member는 이 API의 자동 Rendering Data로 사용되지 않을 수 있다.

Custom Shader Buffer가 필요하면 별도의 전달 경로를 설계한다.

---

## Platform 지원

GPU Instancing을 사용하기 전에 Platform 지원을 확인한다.

```csharp
if (!SystemInfo.supportsInstancing)
{
    Debug.LogWarning("GPU Instancing is not supported.");
}
```

지원하지 않는 Platform, Instancing이 비활성화된 Material 또는 호환되지 않는 Shader에서 명시적 API는 실패할 수 있다.

Build Target의 Graphics API와 Shader Variant Stripping도 확인한다.

Editor에서 동작한다는 사실만으로 모든 Device 지원을 보장할 수 없다.

---

## Shader Variant Stripping

Build 과정에서 사용하지 않는다고 판단된 Instancing Variant가 제거되면 Runtime에 필요한 Shader Variant가 없을 수 있다.

```text
Build
├─ Instancing Variant 사용 분석
├─ 불필요 Variant Strip
└─ Player에 필요한 Variant 포함
```

Runtime에만 생성되는 Material과 Shader Keyword 조합은 Build 분석에서 놓칠 수 있다.

Graphics Settings와 Shader Variant Collection, Build Log를 확인한다.

Variant를 무조건 모두 유지하면 Build Size와 Load Memory가 증가하므로 필요한 조합을 명확히 관리한다.

---

## CPU 병목에서 기대할 수 있는 효과

```text
Before
Tree Draw 2000회
CPU Render Thread 9 ms
GPU 7 ms

After Instancing
Tree Instanced Draw 소수
CPU Render Thread 5 ms
GPU 7 ms
```

CPU가 State 설정과 Draw 제출에 묶여 있다면 Frame Time을 줄일 수 있다.

Renderer Component와 Culling 비용은 자동 Instancing 후에도 남을 수 있다.

대규모 Object에서는 명시적 API와 GPU-driven Culling까지 비교할 수 있다.

---

## GPU 병목에서의 결과

```text
Before
CPU 6 ms
GPU 20 ms

After Instancing
CPU 4 ms
GPU 20 ms
```

Vertex 수, Fragment 수와 Shader 계산은 그대로라면 전체 Frame Time은 GPU에 의해 결정된다.

Instance Group이 너무 커 Culling이 나빠지면 GPU 시간이 늘 수 있다.

Instancing은 만능 GPU 최적화가 아니라 주로 Draw Call 최적화다.

---

## Instance Group을 구성하는 기준

```text
Group Key
├─ Mesh
├─ SubMesh Index
├─ Material
├─ Shader Pass / Variant
├─ Lightmap·Probe 조건
├─ Shadow 설정
└─ Spatial Chunk
```

같은 Key를 가진 Instance를 모으고 Bounds가 지나치게 커지지 않도록 공간별로 나눈다.

Group이 너무 작으면 Instancing 준비 비용 대비 Draw 절약이 작다.

Group이 너무 크면 Culling과 LOD가 나빠진다.

---

## Object 생성·삭제가 많은 경우

Projectile과 Effect처럼 Instance가 자주 추가·삭제되면 배열 관리 비용이 생긴다.

```text
매 Frame
├─ Instance 등록
├─ 삭제된 Slot 회수
├─ Visible List 구성
├─ Matrix / Property 갱신
└─ GPU Upload
```

매번 List를 새로 만들고 복사하면 GC와 CPU Spike가 발생할 수 있다.

Object Pool, Persistent NativeArray, Free List와 Dirty Range Update를 검토한다.

복잡한 Data Structure가 실제 Draw Call 절약보다 비싸지 않은지 Profile한다.

---

## Static Object에도 사용할 수 있다

GPU Instancing은 움직이는 Object 전용 기능이 아니다.

같은 Mesh가 반복되는 Static Forest와 Architecture에서도 사용할 수 있다.

```text
Static Tree 10,000개
├─ Static Batching: World Vertex Copy 증가 가능
└─ GPU Instancing: Mesh 공유 + Matrix Data
```

Static 여부보다 Mesh가 같은지와 Material 호환성이 더 중요한 판단 기준이다.

Baked Lightmap과 Occlusion Culling 조건까지 비교한다.

---

## 적합한 사례

```text
GPU Instancing 후보
├─ 같은 Tree와 Bush
├─ 같은 Rock와 Debris
├─ 반복 Building Module
├─ Grass와 Ground Detail
├─ Projectile와 Bullet
├─ Crowd의 단순 Non-skinned 표현
└─ 동일 Mesh Particle
```

Instance 수가 많고 Mesh·Material 공유율이 높으며 CPU Draw Submission이 병목일수록 효과적이다.

Instance별 차이가 Transform과 소수 Property로 표현될수록 Batch를 유지하기 쉽다.

---

## 적합하지 않을 수 있는 사례

```text
주의 대상
├─ Mesh가 대부분 서로 다름
├─ Material과 Texture가 모두 다름
├─ Instance Group마다 1~2개뿐임
├─ Skinned Mesh Renderer
├─ Instance별 Shader Keyword가 다름
├─ GPU Fragment Bound Scene
└─ 개별 정밀 Culling이 중요한 넓은 Group
```

서로 다른 Mesh가 많고 같은 Shader Variant를 공유한다면 SRP Batcher가 더 적합할 수 있다.

Skinned Crowd에는 별도의 Animation Instancing 또는 GPU Skinning System이 필요하다.

---

## Skinned Mesh Renderer의 제한

Unity의 일반 GPU Instancing 대상에는 Mesh Renderer가 포함되지만 Skinned Mesh Renderer는 지원되지 않는다.

```text
Skinned Instance 추가 Data
├─ Bone Matrix Array
├─ Animation State
├─ Blend Shape
└─ Pose별 Bounds
```

Character마다 다른 Pose를 처리하려면 Mesh Transform 하나보다 훨씬 많은 Data가 필요하다.

일반 `Enable GPU Instancing` 체크만으로 Animated Character Crowd가 Instancing되지는 않는다.

---

## A/B Test 절차

```text
Test A
GPU Instancing Off
├─ Batches
├─ SetPass Calls
├─ CPU Main / Render Thread
├─ GPU Frame
└─ Memory / Upload

Test B
GPU Instancing On
└─ 동일한 조건 측정
```

다음을 고정한다.

- Camera 위치와 이동 경로
- Visible Instance 수
- LOD와 Culling
- Shadow와 Light 설정
- Material과 Shader Keyword
- Graphics API와 Build Type
- 화면 Resolution과 VSync

평균 Instance 수와 최악의 Instance 수 장면을 모두 측정한다.

---

## Profiler에서 확인할 항목

```text
CPU
├─ Renderer Culling
├─ Instance Data 수집
├─ Buffer Upload
├─ Render Thread
└─ Draw Submission

Rendering Statistics
├─ Batches
├─ SetPass Calls
├─ Draw Calls
└─ Instanced Draw Event

GPU
├─ Vertex 처리량
├─ Fragment / Overdraw
├─ Shadow Pass
└─ 전체 GPU Frame Time
```

CPU 시간이 줄지 않았다면 Instance Group이 너무 작거나 Property 수집 비용이 클 수 있다.

GPU 시간이 늘었다면 Bounds와 Culling, LOD와 불필요한 Instance를 확인한다.

---

## 흔한 오해

### GPU Instancing은 Mesh를 복사한다

같은 Mesh Buffer를 공유하고 Instance별 Transform과 Property를 전달한다.

### Mesh가 달라도 Material이 같으면 Instancing된다

기본 Instanced Draw는 같은 Mesh와 SubMesh를 반복해서 그리는 방식이다.

### Instance마다 어떤 값이든 다르게 줄 수 있다

Shader에 Instanced Property로 설계된 Data만 같은 Draw 안에서 다르게 사용할 수 있다.

### Draw Call 하나면 GPU 비용도 하나다

GPU는 모든 Instance의 Vertex와 Fragment를 처리하므로 Geometry·Pixel 비용은 Instance 수에 따라 증가한다.

### Enable GPU Instancing만 체크하면 반드시 적용된다

Mesh, Material, Shader, Pass, Pipeline과 Lighting 조건이 호환되어야 하며 Frame Debugger로 확인해야 한다.

### Instance 수가 많을수록 무조건 좋다

Property 수집·Upload와 Group Bounds로 인한 Culling 손실이 커질 수 있다.

### MaterialPropertyBlock은 항상 성능을 높인다

Non-instanced Property는 Instancing을 끌 수 있고 URP에서 SRP Batcher 호환성을 깨뜨릴 수 있다.

### URP에서는 GPU Instancing이 항상 SRP Batcher보다 빠르다

같은 Mesh 반복성과 Shader Variant 분포에 따라 다르며 두 경로를 실제 CPU 시간으로 비교해야 한다.

### GPU Instancing은 Skinned Character에도 자동 적용된다

일반 Skinned Mesh Renderer는 지원되지 않아 별도 Animation Rendering 구조가 필요하다.

### 한 Group에 모든 Instance를 넣는 것이 가장 좋다

Bounds가 커져 개별 Culling과 LOD가 나빠질 수 있으므로 공간 Chunk가 필요하다.

---

## 적용 판단 순서

```text
1. 같은 Mesh·Material 반복 수 확인
2. CPU Draw Submission 병목 확인
3. Shader와 Material의 Instancing 지원 확인
4. Frame Debugger에서 현재 Batch 구조 확인
5. Instance별로 필요한 Property 최소화
6. 자동 Renderer Instancing부터 비교
7. 필요하면 RenderMeshInstanced로 Component 비용 축소
8. 대규모 Group은 Spatial Chunk와 Culling 설계
9. GPU-driven 필요 시 RenderMeshIndirect 검토
10. Target Device에서 SRP Batcher와 A/B Test
```

가장 복잡한 Indirect Rendering부터 만들 필요는 없다.

자동 Instancing으로 목표를 달성할 수 있다면 유지보수와 Lighting Integration 측면에서 더 단순하다.

---

## 정리

GPU Instancing은 같은 Mesh와 Material을 사용하는 여러 Object를 하나의 Instanced Draw로 Rendering하는 Draw Call 최적화 방식이다.

Mesh Geometry는 공유하고 Instance ID로 Transform, Color와 같은 Per-instance Data를 선택해 서로 다른 위치와 표현을 만든다.

같은 Tree, Rock와 Prop가 많이 반복되는 Scene에서 CPU의 Render State 설정과 Draw 제출 비용을 줄이고 Static Batching보다 Geometry Memory를 절약할 수 있다.

Material, Shader Variant, SubMesh와 Pass가 호환되어야 하며 Instance별 차이는 Shader에 Instanced Property로 선언된 Data로 전달해야 한다.

`RenderMeshInstanced`는 GameObject 없이 Instance를 제출할 수 있지만 Instance Data 크기에 따른 개수 한도, Group Bounds, Lighting과 Frame별 호출을 직접 관리해야 한다.

Instancing은 Draw Call을 줄일 뿐 모든 Instance의 Vertex, Fragment와 Shadow Rendering을 제거하지 않으며 큰 Group은 Culling 효율을 낮출 수 있다.

URP에서는 SRP Batcher와 GPU Instancing이 서로 다른 방식으로 CPU 비용을 줄이므로 같은 Mesh 반복성과 Shader Variant 분포를 기준으로 비교해야 한다.

최종 판단은 Frame Debugger의 `Draw Mesh (Instanced)`, CPU Instance Data 수집·Upload, Render Thread와 GPU Frame Time을 Target Device에서 함께 측정해 내려야 한다.
