---
title: "[Unity 렌더링] 9-9. MaterialPropertyBlock은 왜 사용할까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - MaterialPropertyBlock
  - Material
  - Optimization
permalink: /programming/unity-9-9-why-use-material-property-block/
toc: true
toc_sticky: true
date: 2026-08-16
last_modified_at: 2026-08-16
---

MaterialPropertyBlock은 Shared Material을 복제하지 않고 특정 Renderer의 Material Property 값만 덮어쓰는 Container다.

```text
Shared Material
├─ Renderer A: BaseColor Red
├─ Renderer B: BaseColor Blue
└─ Renderer C: BaseColor Green
```

색, Emission Strength와 Dissolve Amount처럼 Object마다 일부 값만 달라야 할 때 완전한 Material Instance를 하나씩 만드는 일을 피할 수 있다.

GPU Instancing의 Per-instance Data 전달에는 유용하지만 SRP Batcher와는 호환되지 않으므로 Rendering 경로에 따라 선택해야 한다.

---

## Material을 공유하는 이유

여러 Renderer가 같은 Material Asset을 사용하면 Shader, Texture와 Rendering State를 공유할 수 있다.

```text
M_Enemy Shared Material
├─ Enemy 0
├─ Enemy 1
├─ Enemy 2
└─ Enemy 3
```

Material 공유는 Asset과 Runtime Memory를 줄이고 Batching 조건을 유지하는 데 유리하다.

하지만 모든 Enemy가 같은 `_BaseColor`와 `_HitFlash` 값을 사용하게 된다.

Object 하나만 맞았을 때 반짝이게 만들려면 Renderer별 값이 필요하다.

---

## Shared Material을 직접 바꾸면 생기는 일

```csharp
Renderer targetRenderer = GetComponent<Renderer>();
targetRenderer.sharedMaterial.SetColor("_BaseColor", Color.red);
```

`sharedMaterial`은 여러 Renderer가 참조하는 Material이다.

값을 바꾸면 같은 Material을 사용하는 모든 Object의 화면이 함께 바뀔 수 있다.

```text
Enemy 0을 Red로 변경하려고 함
        │
        ▼
Shared Material 변경
        │
        ├─ Enemy 0 Red
        ├─ Enemy 1 Red
        └─ Enemy 2 Red
```

Project에 저장된 Material 설정에도 영향을 줄 수 있어 직접 수정은 주의해야 한다.

---

## renderer.material을 사용하면 생기는 일

```csharp
Renderer targetRenderer = GetComponent<Renderer>();
targetRenderer.material.SetColor("_BaseColor", Color.red);
```

`renderer.material`은 Shared Material이 다른 Renderer에서도 사용 중이면 해당 Renderer 전용 Material을 복제한다.

```text
Before
Enemy 0 ┐
Enemy 1 ├─ Shared Material
Enemy 2 ┘

After renderer.material 접근
Enemy 0 ─ Unique Material Instance
Enemy 1 ┐
Enemy 2 ┘ Shared Material
```

Object 하나만 바꿀 수 있지만 Runtime Material 수와 Memory가 늘고 Batch Group이 나뉠 수 있다.

---

## Material Instance의 Lifecycle

Unity 공식 API 문서에 따르면 `renderer.material`로 생성된 전용 Material은 사용자가 파괴할 책임이 있다.

```csharp
private Material runtimeMaterial;

private void Awake()
{
    runtimeMaterial = GetComponent<Renderer>().material;
}

private void OnDestroy()
{
    Destroy(runtimeMaterial);
}
```

많은 Object가 생성·삭제되며 Material Instance도 계속 만들어지면 Native Object와 Memory 관리 부담이 생긴다.

일부 Property만 다르게 주려는 목적이라면 MaterialPropertyBlock이 더 가벼운 선택일 수 있다.

---

## MaterialPropertyBlock의 역할

MaterialPropertyBlock은 Material의 기본값 위에 Renderer별 Override Layer를 올린다.

```text
Material Default
├─ _BaseColor = White
├─ _Metallic = 0
└─ _HitFlash = 0

Renderer A PropertyBlock
└─ _HitFlash = 1

최종 값
├─ _BaseColor = White
├─ _Metallic = 0
└─ _HitFlash = 1
```

Override하지 않은 Property는 Material의 값을 사용한다.

Material Asset과 Shader Variant를 새로 만들지 않고 몇 개의 값만 바꾼다.

---

## 기본 사용 흐름

```text
1. MaterialPropertyBlock 생성
2. Property 값 설정
3. Renderer.SetPropertyBlock 호출
4. Unity가 Rendering할 때 Override 적용
```

```csharp
using UnityEngine;

public class RendererTint : MonoBehaviour
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
        propertyBlock.SetColor(BaseColorId, color);
        targetRenderer.SetPropertyBlock(propertyBlock);
    }
}
```

Material Inspector의 실제 Property 이름을 사용해야 한다.

URP Lit의 Base Color는 일반적으로 `_BaseColor`지만 Custom Shader는 다른 이름을 사용할 수 있다.

---

## PropertyToID를 사용하는 이유

Shader Property를 문자열로 찾는 작업을 반복하지 않도록 Integer ID를 미리 만든다.

```csharp
private static readonly int HitFlashId =
    Shader.PropertyToID("_HitFlash");
```

```text
매 Update
SetFloat("_HitFlash", value)
        ↓
미리 계산된 ID 사용
SetFloat(HitFlashId, value)
```

특히 많은 Renderer의 값을 매 Frame 갱신할 때 불필요한 문자열 Lookup을 줄일 수 있다.

Property 이름 오타가 Compile Error로 잡히지는 않으므로 Shader와 ID 선언을 함께 관리한다.

---

## 지원하는 값의 종류

MaterialPropertyBlock은 다양한 Shader Property를 저장할 수 있다.

```text
Scalar
├─ Float
├─ Integer
└─ Color

Vector / Matrix
├─ Vector
├─ Matrix
├─ Vector Array
└─ Matrix Array

Resource
├─ Texture
├─ Buffer
└─ Constant Buffer
```

또한 Light Probe SH와 Shadowmask Occlusion Data를 복사하는 전용 API를 제공한다.

Property를 전달할 수 있다는 것과 해당 값이 같은 Batch에 적합하다는 것은 별개의 문제다.

---

## Render State는 바꿀 수 없다

Unity 공식 문서는 MaterialPropertyBlock이 Material Value Override용이며 Render State 변경은 지원하지 않는다고 설명한다.

```text
바꾸기 적합
├─ Color
├─ Float
├─ Vector
├─ Matrix
└─ Shader가 읽는 Buffer

바꾸기 부적합
├─ Blend Mode
├─ Depth Write
├─ Cull Mode
├─ Render Queue
└─ Shader Pass 구조
```

Opaque Object 하나를 PropertyBlock만으로 Transparent Material로 바꾸는 용도가 아니다.

Rendering State가 다르면 별도 Material과 Shader Variant가 필요하다.

---

## Shader Keyword도 다르게 보기 어렵다

MaterialPropertyBlock은 Shader Keyword를 Renderer별로 켜고 끄는 Container가 아니다.

```text
Keyword
_EMISSION On / Off
→ Shader Variant 선택

Property
_EmissionStrength = 0 / 1
→ 같은 Shader Program 안의 값
```

Feature의 코드와 Texture Sample을 완전히 제거해야 하면 Keyword와 Variant가 필요할 수 있다.

같은 Shader Variant를 유지하며 값만 달리하려면 Property와 Branch 구조를 사용할 수 있다.

GPU 계산 비용과 Batch 유지 사이의 Trade-off다.

---

## Block은 Renderer에 복사된다

`SetPropertyBlock`에 전달한 MaterialPropertyBlock Reference를 Renderer가 그대로 소유하는 방식이 아니다.

Unity는 Block 내용을 복사한다.

```text
Reusable Block
├─ Set Red
├─ Renderer A에 Copy
├─ Clear / Set Blue
└─ Renderer B에 Copy
```

따라서 하나의 Block Instance를 여러 Renderer 설정에 재사용할 수 있다.

Unity 공식 문서도 Block 하나를 생성해 여러 Draw Call에 재사용하는 것이 가장 효율적이라고 안내한다.

---

## 하나의 Block을 여러 Renderer에 재사용

```csharp
using UnityEngine;

public class RendererColorSetup : MonoBehaviour
{
    private static readonly int BaseColorId =
        Shader.PropertyToID("_BaseColor");

    [SerializeField] private Renderer[] renderers;
    [SerializeField] private Color[] colors;

    private readonly MaterialPropertyBlock block =
        new MaterialPropertyBlock();

    private void Start()
    {
        int count = Mathf.Min(renderers.Length, colors.Length);

        for (int i = 0; i < count; i++)
        {
            block.Clear();
            block.SetColor(BaseColorId, colors[i]);
            renderers[i].SetPropertyBlock(block);
        }
    }
}
```

각 `SetPropertyBlock`에서 값이 복사되므로 이후 `Clear`해도 이미 적용된 Renderer A의 값은 사라지지 않는다.

---

## 매 Frame new를 피한다

```csharp
private void Update()
{
    MaterialPropertyBlock block = new MaterialPropertyBlock();
    block.SetFloat(HitFlashId, value);
    targetRenderer.SetPropertyBlock(block);
}
```

이 Pattern은 Update마다 Managed Object를 생성한다.

```text
Renderer 수 × Frame 수
→ Allocation 누적
→ GC 가능
```

Block을 Field로 한 번 만들고 재사용한다.

값이 변하지 않으면 `SetPropertyBlock`도 매 Frame 다시 호출할 필요가 없다.

---

## SetPropertyBlock 자체도 공짜가 아니다

Unity가 Block 내용을 복사하고 Rendering Data에 반영해야 한다.

```text
SetPropertyBlock
├─ Property Data Copy
├─ Renderer Override 갱신
└─ GPU 제출을 위한 Data 준비
```

10,000 Renderer에 큰 Array와 Matrix를 매 Frame 설정하면 CPU Memory Copy와 Upload 비용이 커질 수 있다.

```text
Update Cost
= Renderer 수 × Property 크기 × 변경 빈도
```

Dirty Object만 갱신하고 Property 수를 최소화한다.

---

## 기존 Block 값을 보존해야 하는 경우

여러 System이 같은 Renderer의 PropertyBlock을 수정할 수 있다.

```text
Damage System → _HitFlash
Selection System → _OutlineColor
Weather System → _Wetness
```

새 Block에 `_HitFlash`만 넣어 설정하면 기존 Override가 교체될 수 있다.

기존 값을 가져와 수정한다.

```csharp
targetRenderer.GetPropertyBlock(propertyBlock);
propertyBlock.SetFloat(HitFlashId, hitFlash);
targetRenderer.SetPropertyBlock(propertyBlock);
```

여러 System의 실행 순서와 책임을 명확히 하지 않으면 서로 값을 덮어쓸 수 있다.

---

## GetPropertyBlock의 동작

`GetPropertyBlock`은 Renderer의 Override를 전달한 Block에 복사한다.

```csharp
targetRenderer.GetPropertyBlock(propertyBlock);
```

Unity 공식 문서 기준으로 전달한 Block의 기존 내용은 완전히 덮어써진다.

Renderer에 설정된 Property가 없으면 전달한 Block이 Clear된다.

```text
Before Get
Block: _TempValue = 10

Renderer에 Override 없음

After Get
Block: Empty
```

임시 값을 보존하는 함수가 아니라 Renderer 상태를 그대로 읽는 함수다.

---

## Clear와 Override 제거는 다르다

`block.Clear()`는 현재 MaterialPropertyBlock Container 안의 값을 비운다.

```csharp
propertyBlock.Clear();
```

이미 Renderer에 복사된 Override는 Block을 Clear하는 것만으로 제거되지 않는다.

Renderer의 Override를 제거하려면 `null`을 전달한다.

```csharp
targetRenderer.SetPropertyBlock(null);
```

```text
block.Clear()
→ 재사용 중인 Container 비움

renderer.SetPropertyBlock(null)
→ Renderer Override 비활성화
```

---

## 빈 Block을 적용하는 경우

```csharp
propertyBlock.Clear();
targetRenderer.SetPropertyBlock(propertyBlock);
```

빈 Block을 복사하는 것과 `null`로 Override 상태를 명시적으로 제거하는 동작을 같은 것으로 가정하지 않는다.

Override를 끄려는 목적이면 공식 API가 안내하는 `null`을 사용한다.

```csharp
private void OnDisable()
{
    targetRenderer.SetPropertyBlock(null);
}
```

Object Pool로 Renderer를 재사용할 때 이전 Object의 값이 남지 않도록 초기화한다.

---

## Renderer 전체 Override

다음 Overload는 Renderer의 모든 Material Slot에 대한 Per-renderer Block을 설정한다.

```csharp
targetRenderer.SetPropertyBlock(propertyBlock);
```

```text
Renderer
├─ Material Slot 0
├─ Material Slot 1
└─ Material Slot 2

Per-renderer Block
→ Renderer 전체에 적용되는 Override
```

Shader Property가 각 Material에 존재하고 사용되는지에 따라 화면 결과가 달라진다.

---

## Material Slot별 Override

특정 Material Index에만 Block을 설정할 수 있다.

```csharp
int materialIndex = 1;
targetRenderer.SetPropertyBlock(propertyBlock, materialIndex);
```

유효한 범위는 `0`부터 `Renderer.sharedMaterials.Length - 1`까지다.

```text
Character Renderer
├─ Slot 0: Body
├─ Slot 1: Hair ← Override
└─ Slot 2: Cloth
```

Hair Material의 Color만 바꾸고 Body와 Cloth는 유지할 수 있다.

---

## Per-material Block의 우선순위

Renderer 전체 Block과 특정 Material Slot Block이 동시에 있으면 Per-material Block이 우선한다.

```text
Per-renderer Block
_Color = Red

Slot 1 Per-material Block
_Color = Blue

Slot 1 최종 Override
→ Blue
```

Unity 공식 `SetPropertyBlock` 문서에 명시된 우선순위다.

Debug할 때 Renderer 전체 값만 확인하면 특정 Slot에서 다른 결과가 나오는 이유를 놓칠 수 있다.

---

## Slot별 GetPropertyBlock

특정 Material Index의 Override를 읽을 수도 있다.

```csharp
targetRenderer.GetPropertyBlock(propertyBlock, materialIndex);
```

해당 Slot의 Per-material Block만 가져온다.

Renderer 전체 Block과 합성된 최종 Material 값을 반환하는 함수라고 가정하지 않는다.

수정하려는 Override Level과 같은 Overload로 Get·Set을 맞춘다.

---

## 여러 Component가 수정하는 문제

```text
Component A Update
Get → Set _HitFlash → SetPropertyBlock

Component B LateUpdate
Get → Set _Wetness → SetPropertyBlock
```

같은 Frame에 순서가 바뀌거나 한 Component가 `Clear`하면 다른 값이 사라질 수 있다.

Renderer별 Property를 하나의 Coordinator가 관리하는 방식이 안전하다.

```text
RendererPropertyController
├─ Damage 값 수집
├─ Selection 값 수집
├─ Weather 값 수집
└─ 한 번의 SetPropertyBlock
```

호출 횟수와 Ownership 문제를 함께 줄일 수 있다.

---

## Hit Flash 예시

```csharp
using UnityEngine;

public class HitFlashRenderer : MonoBehaviour
{
    private static readonly int HitFlashId =
        Shader.PropertyToID("_HitFlash");

    [SerializeField] private Renderer targetRenderer;
    [SerializeField] private float recoverySpeed = 5f;

    private readonly MaterialPropertyBlock block =
        new MaterialPropertyBlock();

    private float hitFlash;

    public void Play()
    {
        hitFlash = 1f;
    }

    private void LateUpdate()
    {
        float next = Mathf.MoveTowards(
            hitFlash,
            0f,
            recoverySpeed * Time.deltaTime);

        if (Mathf.Approximately(next, hitFlash))
        {
            return;
        }

        hitFlash = next;

        targetRenderer.GetPropertyBlock(block);
        block.SetFloat(HitFlashId, hitFlash);
        targetRenderer.SetPropertyBlock(block);
    }

    private void OnDisable()
    {
        targetRenderer.SetPropertyBlock(null);
    }
}
```

다른 System의 Override를 보존하기 위해 Get한 뒤 값을 바꾼다.

Production에서는 Animation 종료 시 마지막 `0` 값이 한 번 적용되는지도 검증한다.

---

## 값이 변할 때만 적용한다

Property가 이전 Frame과 같다면 Copy와 Renderer Update를 반복할 필요가 없다.

```csharp
if (Mathf.Approximately(previousValue, nextValue))
{
    return;
}
```

Color와 Vector도 변경 여부를 추적할 수 있다.

```text
10,000 Renderers
├─ 실제 변경 100개
└─ 100개만 PropertyBlock Update
```

Dirty Flag와 Event 기반 갱신으로 CPU 비용을 줄인다.

---

## Object Pool 초기화

Pooled Object는 Destroy되지 않고 다른 용도로 다시 활성화된다.

```text
Enemy A
_HitFlash = 1
        │ Return Pool
        ▼
Enemy B로 재사용
이전 Override가 남을 수 있음
```

Pool 반환 또는 재대여 시 Block을 초기화한다.

```csharp
public void ResetRendererProperties()
{
    targetRenderer.SetPropertyBlock(null);
}
```

기본값을 새로 적용할 경우 Shader와 Material의 Default도 함께 확인한다.

---

## Texture Override

MaterialPropertyBlock은 Texture Property도 설정할 수 있다.

```csharp
block.SetTexture(BaseMapId, texture);
```

하지만 Instance마다 다른 Texture Resource를 사용하면 같은 Material State와 GPU Instancing Group을 유지하기 어려울 수 있다.

```text
Renderer A → Texture A
Renderer B → Texture B
Renderer C → Texture C
```

많은 Texture Variation은 Texture Atlas나 Texture2DArray와 Instance별 Index를 검토한다.

API가 허용하는 것과 성능상 적합한 것은 다르다.

---

## Buffer Override

Custom Shader가 Object별 Data Buffer를 읽는다면 PropertyBlock으로 `ComputeBuffer`나 `GraphicsBuffer`를 연결할 수 있다.

```csharp
block.SetBuffer(DataBufferId, graphicsBuffer);
```

Renderer마다 다른 Buffer를 Bind하면 Resource State 전환과 Batch 분리가 증가할 수 있다.

가능하면 큰 Shared Buffer를 사용하고 Renderer 또는 Instance별 Index만 전달한다.

Buffer Lifetime, Release와 GPU Synchronization을 직접 관리해야 한다.

---

## Light Probe Data

MaterialPropertyBlock은 Instanced Rendering에 Light Probe SH와 Probe Occlusion Data를 전달하는 API를 제공한다.

```text
CopySHCoefficientArraysFrom
├─ unity_SHAr
├─ unity_SHAg
├─ unity_SHAb
├─ unity_SHBr
├─ unity_SHBg
├─ unity_SHBb
└─ unity_SHC

CopyProbeOcclusionArrayFrom
└─ unity_ProbesOcclusion
```

`Graphics.RenderMeshInstanced`와 Custom Provided Probe Data를 구성할 때 사용할 수 있다.

SH Data Array는 크기가 크므로 Instance 수와 Upload 비용을 측정한다.

---

## Graphics.RenderMesh에서 사용

`Graphics.RenderMesh`는 GameObject 없이 Mesh를 현재 Frame의 Rendering Queue에 제출한다.

같은 Material로 여러 Mesh를 그리면서 값만 다르게 하려면 `RenderParams.matProps`에 Block을 사용할 수 있다.

```csharp
RenderParams renderParams = new RenderParams(material)
{
    matProps = propertyBlock
};

Graphics.RenderMesh(
    renderParams,
    mesh,
    0,
    objectToWorld);
```

함수는 즉시 GPU Rendering하는 것이 아니므로 호출 사이에 Material 자체의 값을 바꿔 Draw별 차이를 전달하는 방식은 적합하지 않다.

---

## GPU Instancing과 MaterialPropertyBlock

GPU Instancing Shader에 Instance별 Property를 선언하면 Unity가 여러 Renderer의 Block 값을 모아 하나의 Instanced Draw에 전달할 수 있다.

```text
Renderer A Block → Color Red
Renderer B Block → Color Blue
Renderer C Block → Color Green
        │
        ▼
Instance Property Array
        │
        ▼
Draw Mesh (Instanced)
```

Material을 복제하지 않고 Instance Variation을 표현하는 대표적인 사용 사례다.

---

## Instanced Property 선언

Built-in Pipeline의 개념적인 Shader 선언은 다음과 같다.

```hlsl
UNITY_INSTANCING_BUFFER_START(Props)
    UNITY_DEFINE_INSTANCED_PROP(float4, _InstanceColor)
UNITY_INSTANCING_BUFFER_END(Props)
```

```hlsl
float4 color =
    UNITY_ACCESS_INSTANCED_PROP(Props, _InstanceColor);
```

MaterialPropertyBlock에는 같은 이름의 값을 설정한다.

```csharp
block.SetColor(InstanceColorId, color);
```

Pipeline과 Shader Graph의 Instancing 지원 방식은 해당 Unity Version의 문서를 확인한다.

---

## Non-instanced Property를 넣으면 생기는 일

Unity 공식 GPU Instancing 문서는 MaterialPropertyBlock에 Non-instanced Property를 넣지 않도록 안내한다.

```text
Instanced Property
→ Instance Buffer에서 Object별 값 선택

Non-instanced Property Override
→ Draw 전체의 공통 State와 충돌
→ Instancing 비활성화 가능
```

Shader Property가 Instanced로 선언됐는지 이름만 보고 판단할 수 없다.

Frame Debugger에서 `Draw Mesh (Instanced)`가 유지되는지 확인한다.

---

## SRP Batcher와 호환되지 않는다

Unity 6 공식 문서는 MaterialPropertyBlock이 SRP Batcher와 호환되지 않는다고 명시한다.

```text
SRP Batcher
├─ Material Data를 GPU Memory에 Persistent하게 유지
└─ Renderer별 PropertyBlock이 해당 경로를 깨뜨림
```

URP, HDRP와 Custom SRP에서 Block을 사용하면 Standard SRP Code Path로 빠져 성능이 낮아질 수 있다.

Material Instance를 줄였다는 이유만으로 전체 CPU 성능이 좋아졌다고 단정하면 안 된다.

---

## URP에서 선택이 어려운 이유

```text
선택 A: MaterialPropertyBlock
├─ Renderer별 값 설정 편리
├─ Material 복제 방지
├─ GPU Instancing 후보
└─ SRP Batcher 비호환

선택 B: Material Variant / 별도 Material
├─ SRP Batcher 호환 가능
├─ 같은 Shader Variant 유지 가능
└─ Material Asset·Memory·관리 증가
```

같은 Mesh가 수천 개 반복되면 GPU Instancing + PropertyBlock이 유리할 수 있다.

서로 다른 Mesh가 많고 같은 Shader Variant를 공유하면 SRP Batcher + Material Variant가 유리할 수 있다.

---

## Global Property라는 대안

모든 Renderer가 같은 값을 사용한다면 Object별 Block이 필요 없다.

```csharp
Shader.SetGlobalFloat(GlobalWetnessId, wetness);
```

```text
Global Property 적합
├─ World 전체 Wetness
├─ 공통 Wind Time
├─ Global Snow Amount
└─ Environment Tint
```

Global 값은 해당 Property를 사용하는 모든 Shader에 영향을 줄 수 있다.

Object마다 달라야 하는 Hit Flash에는 적합하지 않다.

---

## Material Variant라는 대안

값 종류가 적고 Runtime에 자주 바뀌지 않는다면 Material Variant를 사용할 수 있다.

```text
M_Enemy_Base
├─ M_Enemy_Red
├─ M_Enemy_Blue
└─ M_Enemy_Green
```

같은 Shader Variant를 유지하면 SRP Batcher에서 효율적으로 처리할 수 있다.

색 조합이 수천 개이거나 매 Frame 값이 변하면 Material Asset을 늘리는 방식은 적합하지 않다.

---

## Instance Buffer라는 대안

대규모 GPU-driven Rendering에서는 Object별 Data를 Structured Buffer에 모을 수 있다.

```text
Instance Buffer
├─ Data 0: Transform, Color, State
├─ Data 1: Transform, Color, State
└─ Data N

Instance ID → Data Index
```

MaterialPropertyBlock을 Renderer마다 설정하는 CPU 호출을 줄일 수 있다.

Custom Shader, Buffer Update, Culling와 Lifecycle 구현 복잡도가 증가한다.

Renderer 수와 CPU 병목이 충분히 클 때 검토한다.

---

## PropertyBlock이 적합한 경우

```text
적합 후보
├─ Material의 일부 값만 Object별로 다름
├─ Runtime에 값이 바뀜
├─ Material 복제를 피해야 함
├─ 같은 Mesh의 GPU Instancing을 사용함
├─ Built-in Pipeline에서 Instance Variation 필요
└─ SRP Batcher보다 해당 기능 이득이 큼
```

Hit Flash, Selection Tint, Dissolve Amount, Wind Factor와 Object ID가 대표적이다.

Property 수와 Update 빈도가 작을수록 관리하기 쉽다.

---

## 적합하지 않을 수 있는 경우

```text
주의 대상
├─ URP·HDRP에서 SRP Batcher가 큰 이득을 제공함
├─ Object별로 Render State가 달라야 함
├─ 다른 Texture·Keyword가 필요함
├─ 큰 Array·Matrix를 매 Frame 설정함
├─ Renderer 수가 매우 많음
├─ 여러 System이 같은 Block을 덮어씀
└─ 값이 모든 Object에 공통임
```

공통 값은 Global Property, 고정된 소수 Variation은 Material Variant, 대규모 Data는 Instance Buffer를 비교한다.

---

## Frame Debugger에서 확인할 항목

```text
□ Renderer가 PropertyBlock을 사용하는가?
□ 어떤 Property가 Override됐는가?
□ GPU Instancing Group이 유지되는가?
□ Draw Mesh (Instanced)가 표시되는가?
□ SRP Batch에서 제외됐는가?
□ Material Slot별 Block이 우선하는가?
□ Shadow·Depth Pass에도 값이 영향을 주는가?
```

색이 다르게 보인다는 결과만 확인하지 말고 Rendering Path가 어떻게 바뀌었는지 본다.

Property가 해당 Pass에서 사용되지 않으면 Shadow와 Depth 결과에는 변화가 없을 수 있다.

---

## Profiler에서 확인할 항목

```text
CPU
├─ SetPropertyBlock 호출 시간
├─ Property Data Copy
├─ Main Thread Rendering
├─ Render Thread
└─ Instance Data Upload

Rendering
├─ Draw Calls
├─ Batches
├─ SetPass Calls
├─ SRP Batch 길이
└─ Instanced Draw 수

Memory
├─ Runtime Material 수
├─ Material Native Memory
└─ Property Buffer Data
```

Material Instance 방식, PropertyBlock 방식과 SRP Batcher 호환 Material Variant 방식을 같은 장면에서 비교한다.

---

## A/B Test 구성

```text
Test A
Renderer별 runtimeMaterial

Test B
Shared Material + MaterialPropertyBlock

Test C
Material Variant + SRP Batcher

Test D
GPU Instancing + Instanced Property
```

모든 방식이 같은 화면을 만들도록 Property와 Shader Variant를 맞춘다.

다음을 고정한다.

- Visible Renderer 수
- Mesh와 Material 기본값
- Property 변경 빈도
- Camera와 Culling
- Light와 Shadow
- Graphics API와 Build Type
- Render Scale과 Resolution

CPU·GPU 시간과 Material Memory를 함께 기록한다.

---

## 흔한 오해

### MaterialPropertyBlock은 Material 복사본이다

Material 전체를 복제하는 것이 아니라 특정 Renderer에 적용할 Property Override Container다.

### Block Object를 Renderer마다 만들어야 한다

`SetPropertyBlock`이 내용을 복사하므로 하나의 Block을 여러 Renderer에 재사용할 수 있다.

### block.Clear가 Renderer의 값을 지운다

재사용 Block만 비우며 Renderer Override 제거에는 `SetPropertyBlock(null)`을 사용한다.

### GetPropertyBlock은 기존 Block에 값을 추가한다

전달한 Block을 완전히 덮어쓰고 Renderer에 값이 없으면 Clear한다.

### Material의 모든 설정을 바꿀 수 있다

Shader Property 값은 Override할 수 있지만 Blend, Depth, Render Queue와 같은 Render State 변경은 지원하지 않는다.

### MaterialPropertyBlock은 항상 Batching에 좋다

GPU Instancing에는 활용할 수 있지만 SRP Batcher와 호환되지 않는다.

### PropertyBlock에 Texture를 넣어도 같은 Instance Group이다

서로 다른 Resource와 Non-instanced Property는 Instancing과 Batch를 나눌 수 있다.

### renderer.material보다 언제나 빠르다

SRP Batcher 손실, Property Copy와 Update 빈도에 따라 별도 Material이 더 빠를 수 있다.

### OnDisable에서 아무것도 하지 않아도 된다

Pooled Renderer를 재사용하면 이전 Override가 남을 수 있어 명시적인 초기화가 필요하다.

---

## 안전한 적용 순서

```text
1. Object별로 달라야 할 Property만 선정
2. Render State·Keyword 변경이 아닌지 확인
3. Shared Material 유지
4. Shader Property ID 캐시
5. Block을 한 번 생성해 재사용
6. 기존 Override 보존 필요 시 Get 후 수정
7. 값이 바뀔 때만 Set
8. Pool 반환 시 null로 초기화
9. Frame Debugger로 SRP·Instancing Path 확인
10. Target Device에서 대안과 A/B Test
```

여러 Component가 같은 Renderer를 수정한다면 하나의 Controller가 Block을 통합해 적용한다.

기능 구현 뒤 Material 수만 보지 말고 Rendering Path와 CPU ms를 확인한다.

---

## 최종 체크리스트

```text
Property
□ Shader에 실제 Property가 존재하는가?
□ PropertyToID를 캐시했는가?
□ Render State가 아니라 값 Override인가?
□ GPU Instancing에서는 Instanced Property인가?

Lifecycle
□ Block을 재사용하는가?
□ 값이 변경될 때만 Set하는가?
□ 다른 System의 값을 덮어쓰지 않는가?
□ Pool 반환 시 Override를 지우는가?

Material Slot
□ Renderer 전체와 Slot별 Block을 구분했는가?
□ Per-material Block 우선순위를 고려했는가?
□ Material Index 범위가 올바른가?

Performance
□ SRP Batcher 비호환을 고려했는가?
□ GPU Instancing이 유지되는가?
□ Runtime Material 방식과 비교했는가?
□ Target Device에서 CPU·GPU 시간을 측정했는가?
```

---

## 정리

MaterialPropertyBlock은 Shared Material을 복제하지 않고 특정 Renderer 또는 Material Slot의 Shader Property 값만 덮어쓰는 Container다.

Object별 Color, Hit Flash, Dissolve와 Wind처럼 일부 값만 다른 경우 Runtime Material Instance와 관련 Memory·Lifecycle 문제를 피할 수 있다.

Block은 `SetPropertyBlock` 호출 시 복사되므로 하나를 여러 Renderer에 재사용하고 Property ID를 캐시하며 값이 바뀔 때만 적용하는 것이 효율적이다.

`GetPropertyBlock`은 전달한 Block 전체를 덮어쓰고 Renderer에 값이 없으면 Clear하며 Override 제거에는 `SetPropertyBlock(null)`을 사용한다.

Renderer 전체 Block과 Material Slot별 Block이 동시에 있으면 Slot별 Block이 우선하므로 Get·Set Overload와 Material Index를 일치시켜야 한다.

MaterialPropertyBlock은 Shader Property 값을 바꾸지만 Blend, Depth, Render Queue와 Shader Keyword 같은 Render State를 변경하는 기능은 아니다.

GPU Instancing의 Instanced Property 전달에는 유용하지만 Unity 6의 SRP Batcher와는 호환되지 않아 URP·HDRP에서는 성능이 낮아질 수 있다.

최종 선택은 편의성이나 Material 수만 보지 않고 Runtime Material, Material Variant, Global Property와 Instance Buffer 대안을 동일 화면에서 CPU·GPU·Memory로 비교해 내려야 한다.
