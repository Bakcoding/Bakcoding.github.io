---
title: "[Unity 렌더링] 4-2. Shader와 Material은 무엇이 다를까?"
excerpt: "Unity Rendering"
categories:
  - Programming
tags:
  - Unity
  - Rendering
  - Shader
  - Material
  - ShaderProperty
permalink: /programming/unity-4-2-shader-material/
toc: true
toc_sticky: true
date: 2026-08-15
last_modified_at: 2026-08-15
---

Shader는 Vertex와 Fragment를 어떤 규칙으로 계산할지 정의하는 GPU Program이다.

하지만 같은 계산 규칙을 사용하는 모든 Object가 같은 Color와 Texture를 가져야 하는 것은 아니다.

```text
같은 Lit Shader
├─ 빨간 자동차 Material
├─ 파란 자동차 Material
├─ 거친 돌 Material
└─ 매끄러운 금속 Material
```

Shader가 **어떻게 계산할지** 정의한다면 Material은 어떤 Shader를 사용할지 선택하고 그 계산에 넣을 **구체적인 입력값**을 저장한다.

```text
Shader
계산 규칙과 사용할 Property 정의

Material
Shader 참조와 Property 값 저장
```

Unity Renderer는 Mesh와 Material을 연결하고 Material은 Shader와 Texture, Color, Float 같은 값을 연결한다.

```text
Renderer
├─ Mesh: 어떤 형태인가
└─ Material: 어떤 표면인가
   ├─ Shader: 어떻게 계산하는가
   └─ Property 값: 무엇을 입력하는가
```

---

## Shader란?

Unity의 Shader Asset은 GPU에서 실행할 Program과 Rendering에 필요한 구조를 정의한다.

ShaderLab으로 SubShader, Pass, Tag와 Render State를 구성하고 HLSL로 Programmable Stage의 계산을 작성할 수 있다.

```shaderlab
Shader "Custom/TintedTexture"
{
    Properties
    {
        _BaseMap("Base Map", 2D) = "white" {}
        _BaseColor("Base Color", Color) = (1, 1, 1, 1)
    }

    SubShader
    {
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // GPU Program
            ENDHLSL
        }
    }
}
```

이 Shader는 Base Texture와 Base Color를 입력받아 특정 방식으로 화면 결과를 계산할 수 있다는 규칙을 제공한다.

Shader Asset 자체가 빨간색 자동차나 회색 돌 하나를 의미하지는 않는다.

---

## Material이란?

Material은 Shader Object에 대한 참조와 Shader가 정의한 Material Property 값을 저장하는 Unity Asset 또는 Runtime Object다.

Project에 저장된 Material Asset은 일반적으로 `.mat` 확장자를 가진다.

```text
CarRed.mat
├─ Shader: Custom/CarPaint
├─ _BaseColor: Red
├─ _BaseMap: CarPaintTexture
├─ _Metallic: 0.8
└─ _Smoothness: 0.9
```

다른 Material은 같은 Shader를 참조하면서 값만 다르게 가질 수 있다.

```text
CarBlue.mat
├─ Shader: Custom/CarPaint
├─ _BaseColor: Blue
├─ _BaseMap: CarPaintTexture
├─ _Metallic: 0.8
└─ _Smoothness: 0.9
```

두 Material은 계산 Code를 복사해서 각각 보관하지 않는다.

같은 Shader 규칙에 서로 다른 입력값을 연결한다.

---

## 가장 단순한 관계

Shader에 다음 계산이 있다고 가정할 수 있다.

```hlsl
half4 surfaceColor = baseTexture * baseColor;
```

이 식은 모든 Material에서 같다.

Material마다 `baseTexture`와 `baseColor` 값이 달라진다.

```text
Material A
Brick Texture × Red Tint

Material B
Brick Texture × Blue Tint

Material C
Wood Texture × White Tint
```

```text
Shader = 함수
Material = 함수에 넣을 저장된 인자 묶음
```

함수와 인자라는 비유는 기본 관계를 이해하는 데 유용하지만 Material에는 Keyword, Render Queue와 Pass 제어 같은 추가 상태도 포함될 수 있다.

---

## Shader와 Material 비교

| 구분 | Shader | Material |
| --- | --- | --- |
| 핵심 역할 | Rendering 계산 규칙 정의 | Shader 선택과 입력값 저장 |
| 대표 Asset | `.shader`, Shader Graph Asset | `.mat` |
| 포함 내용 | Pass, HLSL Program, Property 선언 | Color, Float, Vector, Texture 참조 등 |
| GPU 관점 | 실행할 Program | Program에 Binding할 Resource와 값 |
| 재사용 | 여러 Material이 같은 Shader 사용 | 여러 Renderer가 같은 Material 사용 |
| 변경 영향 | 사용 중인 모든 Material의 계산 구조에 영향 가능 | 해당 Material을 공유하는 Renderer에 영향 |

Shader와 Material은 경쟁 관계가 아니라 서로 다른 책임을 가진 연결 구조다.

---

## Property란?

Property는 Shader가 외부에서 값을 받을 수 있도록 이름과 Type을 정의한 입력이다.

Unity ShaderLab의 `Properties` Block은 Material Asset에 저장하고 Inspector에서 편집할 수 있는 Property를 선언한다.

```shaderlab
Properties
{
    _BaseColor("Base Color", Color) = (1, 1, 1, 1)
    _Smoothness("Smoothness", Range(0, 1)) = 0.5
    _Offset("Offset", Vector) = (0, 0, 0, 0)
    _BaseMap("Base Map", 2D) = "white" {}
}
```

Property 선언에는 다음 정보가 들어간다.

```text
_BaseColor
Shader와 Script에서 사용하는 내부 이름

"Base Color"
Material Inspector에 표시할 이름

Color
Property Type

(1, 1, 1, 1)
기본값
```

Material은 이 정의에 맞는 실제 값을 저장한다.

---

## Property Type

ShaderLab `Properties` Block에는 여러 Type을 선언할 수 있다.

| Type | 저장하는 값 | Inspector 표현 예시 |
| --- | --- | --- |
| `Float` | 실수 하나 | 숫자 입력 |
| `Range` | 범위가 있는 실수 | Slider |
| `Integer` | 정수 | 정수 입력 |
| `Color` | RGBA 값 | Color Picker |
| `Vector` | 네 Component 값 | X, Y, Z, W 입력 |
| `2D` | Texture2D 참조 | Texture Slot |
| `3D` | Texture3D 참조 | Texture Slot |
| `Cube` | Cubemap 참조 | Cubemap Slot |
| `2DArray` | Texture2DArray 참조 | Texture Slot |

Inspector 표현은 편집 방법을 제공하며 HLSL 쪽 변수 선언과 Resource Type도 맞아야 한다.

```hlsl
float4 _BaseColor;
float _Smoothness;
TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);
```

Property 이름이 일치하지 않으면 Material에 저장된 값이 의도한 HLSL 변수로 연결되지 않는다.

---

## Shader가 Property의 종류를 정한다

Material Inspector에 표시되는 항목은 선택한 Shader가 정의한다.

```text
Unlit Shader 선택
├─ Base Map
└─ Base Color

Lit Shader 선택
├─ Base Map
├─ Base Color
├─ Metallic
├─ Smoothness
├─ Normal Map
└─ Emission
```

Material이 임의의 Property 구조를 만들고 Shader가 나중에 읽는 방식이 아니다.

Shader가 사용할 입력 Interface를 먼저 정의하고 Material이 그 Interface에 값을 저장한다.

Shader를 다른 것으로 변경하면 Inspector 항목과 사용되는 Property 집합도 달라질 수 있다.

---

## 기본값과 Material 값

Shader Property에는 기본값이 있다.

```shaderlab
_BaseColor("Base Color", Color) = (1, 1, 1, 1)
_Smoothness("Smoothness", Range(0, 1)) = 0.5
_BaseMap("Base Map", 2D) = "white" {}
```

새 Material이 이 Shader를 선택하면 기본값을 기준으로 Property가 구성된다.

Material에서 값을 변경하면 `.mat` Asset에 해당 값이 저장된다.

```text
Shader 기본값
_Smoothness = 0.5

Material A 저장값
_Smoothness = 0.2

Material B 저장값
_Smoothness = 0.9
```

Shader의 기본값을 나중에 바꿔도 이미 Override되어 저장된 Material 값이 자동으로 같은 값이 된다고 가정하면 안 된다.

Asset 상태와 Unity의 Serialization 결과를 확인해야 한다.

---

## Texture는 Shader일까 Material일까?

Texture는 Shader도 Material도 아닌 별도의 Resource Asset이다.

Material은 Texture Asset에 대한 참조를 Property 값으로 저장할 수 있다.

```text
Shader
_BaseMap이라는 Texture 입력을 정의

Material
_BaseMap에 Brick.png 참조를 저장

Texture
Brick.png의 Pixel Data와 Import 설정
```

Fragment Shader는 Material을 통해 Binding된 Texture를 Sampling한다.

```hlsl
half4 baseColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv);
```

같은 Texture를 여러 Material이 참조할 수 있고, 한 Material이 Base Map, Normal Map, Mask Map처럼 여러 Texture를 참조할 수도 있다.

---

## Texture와 Sampler

Texture는 Image Data를 보관하고 Sampler는 좌표 밖 처리와 Filtering 같은 Sampling State에 관련된다.

```text
Texture
Texel Data

UV
읽을 위치

Sampler
Filter와 Addressing 규칙

↓
Sampled Value
```

Unity Shader Property의 Texture Slot은 주로 Texture Asset 참조를 Material에 저장한다.

HLSL에서는 Texture Object와 Sampler State를 선언해 Sampling한다.

Texture Sampling의 세부 동작은 다음 `4-5` 문서에서 별도로 연결된다.

---

## 하나의 Shader와 여러 Material

Shader를 재사용하면 계산 Code를 하나의 Asset에서 관리하면서 다양한 표면을 만들 수 있다.

```text
Custom/LitSurface Shader
├─ Stone.mat
│  ├─ Gray Base Map
│  ├─ Metallic 0.0
│  └─ Smoothness 0.2
├─ Steel.mat
│  ├─ Steel Base Map
│  ├─ Metallic 1.0
│  └─ Smoothness 0.8
└─ Plastic.mat
   ├─ Red Base Color
   ├─ Metallic 0.0
   └─ Smoothness 0.6
```

새 Color가 필요할 때마다 Shader Code를 복사할 필요가 없다.

값의 차이는 Material로 분리하고 계산 방식의 차이는 Shader 또는 Shader Feature로 분리할 수 있다.

---

## 하나의 Material과 여러 Renderer

여러 Renderer가 같은 Material Asset을 참조할 수 있다.

```text
Rock.mat
↑       ↑       ↑
Rock A  Rock B  Rock C
Renderer Renderer Renderer
```

이 구조는 동일한 표면 설정을 여러 Object에서 재사용한다.

Material Asset의 값을 변경하면 이를 공유하는 Renderer의 화면도 함께 바뀐다.

```text
Rock.mat의 _BaseColor 변경
↓
Rock A, B, C 모두 변경
```

특정 Object 하나만 다른 값이 필요하다면 별도 Material을 만들거나 Per-Renderer Property 전달 방식을 검토해야 한다.

---

## Renderer의 Material Slot

Mesh Renderer와 Skinned Mesh Renderer는 하나 이상의 Material Slot을 가질 수 있다.

Mesh의 SubMesh와 Material Slot이 대응하여 서로 다른 Triangle Group에 다른 Material을 적용할 수 있다.

```text
Mesh
├─ SubMesh 0 → Material Slot 0 → Body.mat
├─ SubMesh 1 → Material Slot 1 → Glass.mat
└─ SubMesh 2 → Material Slot 2 → Tire.mat
```

일반적으로 SubMesh마다 별도의 Draw가 필요할 수 있다.

Material 수가 늘어나면 표현은 분리되지만 Draw Call과 State 변경 비용도 증가할 수 있다.

Material Slot을 나누기 전에 실제로 다른 Shader와 State가 필요한지 확인한다.

---

## Script에서 Material Property 변경

Unity C#에서는 `Material` API로 Property 값을 변경할 수 있다.

```csharp
using UnityEngine;

public class PulseColor : MonoBehaviour
{
    [SerializeField] private Material targetMaterial;

    private static readonly int BaseColorId =
        Shader.PropertyToID("_BaseColor");

    private void Update()
    {
        float value = Mathf.PingPong(Time.time, 1.0f);
        targetMaterial.SetColor(BaseColorId, new Color(value, 0.2f, 0.2f, 1.0f));
    }
}
```

`Shader.PropertyToID`로 Property 이름을 Integer ID로 바꾸어 반복적인 문자열 조회를 피할 수 있다.

```text
"_BaseColor"
↓ Shader.PropertyToID
Integer Property ID
↓
Material.SetColor
```

이 Code가 Project의 Material Asset을 직접 참조하면 그 Material을 공유하는 모든 Renderer에 값이 반영될 수 있다.

---

## `sharedMaterial`

`Renderer.sharedMaterial`은 Renderer가 참조하는 공유 Material을 반환한다.

```csharp
Renderer targetRenderer = GetComponent<Renderer>();
Material shared = targetRenderer.sharedMaterial;
```

공유 Material의 값을 변경하면 같은 Material을 사용하는 다른 Renderer에도 영향을 줄 수 있다.

```text
Renderer A ─┐
Renderer B ─┼→ SharedMaterial.mat
Renderer C ─┘

sharedMaterial 값 변경
→ A, B, C에 함께 영향
```

Editor에서 Material Asset 자체의 값을 변경할 수 있으므로 Runtime의 한 Object만 바꾸려는 의도라면 주의해야 한다.

공유가 목적일 때는 명확하고 불필요한 Material Instance를 만들지 않는다.

---

## `material`

`Renderer.material`에 접근하면 Renderer 전용으로 사용할 Material Instance가 생성될 수 있다.

```csharp
Renderer targetRenderer = GetComponent<Renderer>();
Material instance = targetRenderer.material;
instance.SetColor(BaseColorId, Color.red);
```

```text
접근 전
Renderer A ─┐
Renderer B ─┴→ SharedMaterial.mat

Renderer A.material 접근 후
Renderer A → Material Instance
Renderer B → SharedMaterial.mat
```

특정 Renderer만 값을 바꾸기에는 편리하지만 Object마다 Instance가 만들어지면 Material 수와 Memory 사용, Batching 조건에 영향을 줄 수 있다.

Runtime에 생성한 Material의 Lifetime 관리도 필요하다.

매 Frame `renderer.material`에 반복 접근하며 의도치 않은 Instance 생성 여부를 확인하지 않는 방식은 피하는 편이 안전하다.

---

## `sharedMaterial`과 `material` 비교

| API | 가리키는 대상 | 변경 영향 | 주의점 |
| --- | --- | --- | --- |
| `sharedMaterial` | 공유 Material 참조 | 공유하는 Renderer 전체에 영향 가능 | Asset 값을 의도치 않게 변경할 수 있음 |
| `material` | Renderer용 Instance | 주로 해당 Renderer에 적용 | Instance 생성과 Lifetime, Batching 비용 가능 |

둘 중 하나가 항상 올바른 것은 아니다.

공유된 표면을 함께 변경하려는지, 특정 Renderer만 변경하려는지와 Instance 비용을 기준으로 선택한다.

---

## MaterialPropertyBlock

같은 Material을 공유하면서 Renderer마다 일부 Property 값만 다르게 전달하려면 `MaterialPropertyBlock`을 사용할 수 있다.

```csharp
using UnityEngine;

public class PerRendererColor : MonoBehaviour
{
    private static readonly int BaseColorId =
        Shader.PropertyToID("_BaseColor");

    private Renderer targetRenderer;
    private MaterialPropertyBlock propertyBlock;

    private void Awake()
    {
        targetRenderer = GetComponent<Renderer>();
        propertyBlock = new MaterialPropertyBlock();
    }

    public void SetColor(Color color)
    {
        targetRenderer.GetPropertyBlock(propertyBlock);
        propertyBlock.SetColor(BaseColorId, color);
        targetRenderer.SetPropertyBlock(propertyBlock);
    }
}
```

```text
Shared Material
같은 Shader와 기본 Property
↑         ↑
Renderer A Renderer B
Red Override Blue Override
```

Material Asset을 복제하지 않고 Draw에 Per-Renderer 값을 Override할 수 있다.

하지만 SRP Batcher와 GPU Instancing의 적용 방식, Render Pipeline과 Unity Version에 따라 성능 영향이 달라질 수 있다.

Material Instance를 무조건 대체하는 만능 최적화로 가정하지 않고 Target Pipeline에서 측정한다.

---

## Property 우선순위

개념적으로 Property 값은 여러 위치에서 공급될 수 있다.

```text
Shader Property 기본값
↓
Material에 저장된 값
↓
MaterialPropertyBlock의 Per-Renderer Override
↓
Draw에 전달되는 실제 값
```

Global Shader Property나 Render Pipeline이 별도로 Binding하는 값도 존재할 수 있다.

같은 이름이 여러 범위에 존재할 때 어떤 값이 사용되는지는 Unity API와 Binding 구조를 확인해야 한다.

Material Inspector의 값만 보고 실제 Draw에서 전달된 값을 항상 확정할 수 없는 이유다.

---

## HLSL에서 Material Property 읽기

URP에서 Per-Material Scalar와 Vector를 SRP Batcher에 맞게 선언하려면 같은 `UnityPerMaterial` Constant Buffer에 배치한다.

```hlsl
CBUFFER_START(UnityPerMaterial)
    float4 _BaseColor;
    float _Smoothness;
CBUFFER_END
```

Texture와 Sampler는 별도로 선언한다.

```hlsl
TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);
```

Fragment Shader에서 값을 사용한다.

```hlsl
half4 textureColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv);
half4 color = textureColor * _BaseColor;
```

ShaderLab Property 선언, HLSL 변수 이름과 Script Property ID가 같은 이름으로 연결되어야 한다.

---

## SRP Batcher와 Material Property

SRP Batcher는 호환되는 Shader Variant의 Material Data를 효율적으로 Binding하여 CPU Rendering Cost를 줄이는 기능이다.

Custom URP Shader의 Per-Material Property는 하나의 `UnityPerMaterial` CBUFFER에 일관되게 선언해야 한다.

```text
Material A Data ─┐
Material B Data ─┼→ 같은 호환 Shader Variant 구조
Material C Data ─┘
```

SRP Batcher는 서로 다른 Material을 하나의 Draw Call로 자동 합친다는 의미가 아니다.

Shader Variant와 Buffer Layout의 호환성을 활용해 Material 변경에 따른 CPU 설정 비용을 줄이는 방향이다.

Frame Debugger와 Profiler의 SRP Batcher 정보를 통해 실제 호환 여부를 확인한다.

---

## GPU Instancing과 Material

GPU Instancing은 같은 Mesh와 Material을 사용하는 여러 Object를 Instance Data와 함께 효율적으로 그릴 수 있는 방식이다.

```text
같은 Mesh
같은 Material
여러 Transform과 Instance Property
↓
Instanced Draw
```

Object마다 별도 Material Instance를 만들면 동일 Material 조건을 깨뜨려 Instancing과 Batch 구성이 달라질 수 있다.

Per-Instance Property를 사용하려면 Shader의 Instancing 지원과 적절한 Data 선언이 필요하다.

SRP Batcher와 GPU Instancing은 목적과 적용 조건이 다르므로 Project의 Renderer 수, Material 수와 Draw 구조를 측정해 선택한다.

---

## Shader Keyword

Shader Keyword는 Compile된 Shader Variant 또는 기능 경로를 선택하는 데 사용할 수 있다.

```hlsl
#pragma shader_feature_local _NORMALMAP

#if defined(_NORMALMAP)
    // Normal Map 처리
#endif
```

Material은 Local Keyword의 활성 상태를 가질 수 있다.

```text
Material A
_NORMALMAP Off
→ Normal Map 없는 Variant

Material B
_NORMALMAP On
→ Normal Map Variant
```

Float Property 값을 `1`로 바꾸는 것과 Keyword를 활성화하는 것은 같은 동작이 아닐 수 있다.

Custom Inspector 또는 Script가 Property와 Keyword 상태를 함께 관리해야 하는 Shader도 있다.

---

## Property와 Keyword의 차이

| 구분 | Property | Keyword |
| --- | --- | --- |
| 역할 | Shader 계산에 사용할 Data 제공 | 기능 또는 Variant 선택 |
| 예시 | Color, Smoothness, Texture | `_NORMALMAP`, `_EMISSION` |
| 변경 결과 | 같은 Program에 다른 값 전달 가능 | 다른 Compile 경로 선택 가능 |
| 비용 관점 | Constant와 Resource Binding | Variant 수와 전환에 영향 |

`_UseEffect` Float 하나가 Inspector에 보여도 내부 Shader가 Dynamic Branch로 사용하는지 Keyword를 변경하는지는 구현에 따라 다르다.

Property 이름만 보고 Variant 구조를 판단하지 않는다.

---

## Render Queue

Shader의 SubShader `Queue` Tag는 기본 Rendering 순서를 나타낼 수 있다.

```shaderlab
Tags { "Queue" = "Geometry" }
```

투명 Shader는 다음과 같은 Queue를 사용할 수 있다.

```shaderlab
Tags { "Queue" = "Transparent" }
```

Material은 Shader가 제공한 기본 Queue를 사용하거나 Render Queue를 Override할 수 있다.

```csharp
targetMaterial.renderQueue = 3000;
```

```text
Shader Queue Tag
기본 Queue
↓
Material Render Queue Override
특정 Material의 Draw 순서 조절 가능
```

Render Queue를 바꾸면 Depth, Blending과 Sorting 결과가 달라질 수 있다.

단순히 앞이나 뒤에 보이게 만드는 값으로 사용하기보다 Render State와 Pipeline의 Queue 범위를 함께 확인한다.

---

## Render State는 어디에 있을까?

Cull, ZTest, ZWrite와 Blend 같은 Render State는 ShaderLab Pass에 고정해서 작성할 수 있다.

```shaderlab
Cull Back
ZWrite On
ZTest LEqual
Blend Off
```

Property를 State 명령에 연결하면 Material 값으로 State를 선택할 수도 있다.

```shaderlab
Properties
{
    [Enum(UnityEngine.Rendering.CullMode)]
    _Cull("Cull", Float) = 2
}

SubShader
{
    Cull [_Cull]
}
```

```text
Shader
어떤 State가 존재하고 어떻게 사용되는지 정의

Material
노출된 State Property의 구체적인 값 저장 가능
```

모든 Render State가 자동으로 Material Property인 것은 아니다.

Shader가 Property와 State를 연결했을 때 Material에서 변경할 수 있다.

---

## Shader를 변경하면 어떻게 될까?

Material Inspector에서 다른 Shader를 선택하면 Material이 참조하는 Shader Object가 바뀐다.

```text
Material
Shader A
_BaseColor / _BaseMap / _Smoothness

↓ Shader 변경

Material
Shader B
_Tint / _Texture / _Roughness
```

두 Shader가 서로 다른 Property 이름과 Type을 사용하면 기존 Material 값이 새 Shader 계산에 연결되지 않을 수 있다.

비슷한 의미라도 `_BaseMap`과 `_MainTex`처럼 이름이 다르면 자동으로 같은 입력이 되는 것은 아니다.

Render Pipeline을 변경할 때 Material Conversion이 필요한 이유 중 하나다.

---

## 사용하지 않는 저장값

Material은 이전 Shader에서 사용하던 Serialized Property 값을 내부에 남길 수 있다.

현재 Shader가 해당 이름을 선언하거나 사용하지 않으면 Rendering에는 반영되지 않는다.

```text
Material Serialized Data
_OldTexture 값 존재

현재 Shader
_OldTexture를 사용하지 않음

→ Draw 결과에는 연결되지 않음
```

Shader를 반복 변경한 Material에서 불필요한 Property Data가 남을 수 있다.

Asset Serialization을 직접 수정하기보다 Unity가 제공하는 Material 관리와 Upgrade 도구를 우선 사용한다.

---

## Material Variant

Unity의 Material Variant는 Base Material의 Property를 상속하고 필요한 값만 Override하는 계층을 구성할 수 있다.

```text
VehicleBase.mat
├─ Metallic 0.8
├─ Smoothness 0.9
└─ Base Texture
   ↓ 상속
VehicleRed.mat
└─ Base Color만 Red로 Override

VehicleBlue.mat
└─ Base Color만 Blue로 Override
```

공통 값을 Base Material에서 관리하고 변형 Material은 차이만 보관할 수 있다.

어떤 Property가 Override되었는지와 Parent 변경이 Child에 어떻게 전달되는지 Inspector에서 확인해야 한다.

Material Variant는 Shader Variant와 다른 개념이다.

```text
Material Variant
Material Asset Property 상속

Shader Variant
Keyword 조합으로 Compile된 Shader Program 변형
```

---

## Material 복제와 공유 선택

표면 값이 다르다는 이유로 항상 Material Asset을 새로 만들 필요는 없다.

```text
모든 Object가 같은 값
→ Shared Material

몇 개의 편집 가능한 표면 종류
→ 여러 Material Asset 또는 Material Variant

Runtime에 Renderer마다 작은 값 차이
→ MaterialPropertyBlock 또는 Instancing Property 검토

완전히 독립적인 Runtime State
→ Material Instance 검토
```

선택 기준은 Authoring 편의뿐 아니라 Material 수, Batch, Instance Lifetime과 값 변경 빈도다.

Project의 Render Pipeline과 Target Platform에서 검증한다.

---

## Material 수와 성능

Material이 많다고 GPU 연산이 반드시 복잡해지는 것은 아니다.

같은 Shader와 같은 Texture를 사용해도 Material이 분리되면 Rendering State와 Resource Binding 전환, Batching 구성에 영향을 줄 수 있다.

```text
같은 Material 공유
State 재사용과 Batch에 유리할 가능성

서로 다른 Material
Property 또는 Keyword 변경
State 전환과 Draw 분리 가능
```

반대로 서로 다른 표면을 하나의 Material과 복잡한 Per-Object Branch로 억지로 합치면 Shader 비용과 관리 복잡도가 증가할 수 있다.

Material 개수 하나만 목표로 삼지 않고 CPU Draw 제출, GPU Pass 시간, Variant와 Memory를 함께 측정한다.

---

## Texture를 공유해도 Material은 다를 수 있다

Material A와 B가 같은 Base Texture를 사용하면서 Tint 값만 다르게 가질 수 있다.

```text
SharedTexture.png
↑                 ↑
RedTint.mat       BlueTint.mat
_Color = Red      _Color = Blue
```

Texture Memory는 같은 Asset 참조를 공유할 수 있지만 Material Property 묶음은 별도로 존재한다.

Material이 다르다고 모든 Texture Data가 자동 복제되는 것은 아니다.

Runtime에 실제로 다른 Texture Instance를 생성하거나 RenderTexture를 할당한 경우에는 Resource가 분리될 수 있다.

---

## Material과 Mesh는 다르다

Mesh는 Geometry Data를 보관한다.

Material은 Surface Rendering 설정을 보관한다.

```text
Mesh
Position / Normal / Tangent / UV / Index

Material
Shader / Color / Texture / Float / Keyword
```

같은 Mesh에 여러 Material을 적용할 수 있고 같은 Material을 서로 다른 Mesh에 적용할 수도 있다.

```text
Cube Mesh + Brick Material
Sphere Mesh + Brick Material

Cube Mesh + Metal Material
```

형태와 표면을 분리했기 때문에 Asset을 조합하여 재사용할 수 있다.

---

## Material과 Texture Import 설정

Material이 Texture를 참조하더라도 Texture의 Format, Compression, Mipmap과 Color Space 설정은 Texture Importer에 존재한다.

```text
Material
어떤 Texture를 어느 Property에 사용할지

Texture Importer
Texture Data를 GPU용으로 어떻게 준비할지
```

Normal Map Property에 일반 Color Texture Import 설정을 사용하면 Sampling 결과가 의도와 다를 수 있다.

Material Inspector의 Texture Slot만 확인하지 않고 Texture Asset의 Import Type도 함께 확인한다.

---

## Material 값과 HLSL 변수의 연결

다음 네 위치의 이름이 연결된다.

```text
ShaderLab Property
_BaseColor
↓
Material Serialized Property
_BaseColor
↓
C# Property ID
Shader.PropertyToID("_BaseColor")
↓
HLSL Variable
float4 _BaseColor
```

Display Name인 `"Base Color"`는 Inspector에 보여 주는 Label이며 Script와 HLSL Binding에는 내부 이름 `_BaseColor`를 사용한다.

```shaderlab
_BaseColor("Base Color", Color) = (1, 1, 1, 1)
```

내부 이름과 표시 이름을 혼동하면 Script에서 Property를 찾지 못한다.

---

## Property 존재 여부 확인

Script에서 Custom Shader가 특정 Property를 제공하는지 확인할 수 있다.

```csharp
private static readonly int BaseColorId =
    Shader.PropertyToID("_BaseColor");

if (targetMaterial.HasProperty(BaseColorId))
{
    targetMaterial.SetColor(BaseColorId, Color.red);
}
```

여러 Shader를 사용할 수 있는 Renderer를 공통 Script로 처리할 때 존재하지 않는 Property 접근을 피할 수 있다.

Property가 존재해도 Type과 의미가 같다는 보장은 없으므로 Shader Contract를 함께 관리한다.

---

## Runtime Material 생성

Runtime에 기존 Material을 복제하여 독립 값을 만들 수 있다.

```csharp
private Material runtimeMaterial;

private void Awake()
{
    runtimeMaterial = new Material(sourceMaterial);
    GetComponent<Renderer>().sharedMaterial = runtimeMaterial;
}

private void OnDestroy()
{
    Destroy(runtimeMaterial);
}
```

Runtime Object는 Project의 `.mat` Asset과 다른 Memory 객체다.

Scene Loading, Pooling과 Domain Lifetime에 맞춰 생성과 제거를 관리해야 한다.

Object마다 무조건 복제하면 Material과 Memory가 불필요하게 늘어날 수 있다.

---

## 값 변경 빈도

Property가 얼마나 자주 바뀌는지도 전달 방법 선택에 영향을 준다.

```text
편집 시 고정 값
Material Asset

여러 Object가 함께 바뀌는 값
Shared Material 또는 Global Data 검토

Renderer마다 가끔 바뀌는 값
MaterialPropertyBlock 검토

대량 Instance마다 다른 값
GPU Instancing Data 검토
```

매 Frame 수천 개 Material Instance의 값을 변경하면 CPU Binding과 Batch 구성 비용이 커질 수 있다.

반대로 Update가 적은 소수 Object를 위해 복잡한 Instancing 구조를 도입할 필요는 없을 수 있다.

---

## Frame Debugger에서 확인하기

Unity Frame Debugger의 Draw Event에서 사용한 Shader, Pass와 Material 관련 State를 확인할 수 있다.

```text
Draw Event
├─ Shader와 Pass
├─ Shader Keywords
├─ Textures
├─ Constant 값
├─ Render Queue
└─ Cull / Depth / Blend State
```

같은 Shader를 사용하는 두 Material이 Keyword 때문에 다른 Variant를 선택하는지, Texture와 Property 값만 다른지 구분하는 데 도움이 된다.

Frame Debugger는 Material Asset 관계만 보는 도구가 아니라 실제 Draw에 Binding된 상태를 확인하는 도구다.

---

## Inspector에서 확인하기

Material Inspector에서 다음 관계를 확인할 수 있다.

- 현재 선택된 Shader
- Shader가 노출한 Property
- Texture Reference
- Keyword와 Surface Option
- Render Queue Override
- Material Variant의 Parent와 Override

Shader를 선택하여 Shader Asset으로 이동하면 Property 정의와 Pass 구조를 확인할 수 있다.

Material 값이 화면에 반영되지 않을 때는 Property 이름, Keyword, Pass 선택과 Render Pipeline 호환성을 순서대로 확인한다.

---

## 최적화할 때 확인할 항목

Material 관련 성능을 점검할 때 다음 질문을 사용할 수 있다.

```text
같은 표면이 불필요하게 여러 Material로 복제되었는가?
↓
Object마다 renderer.material 접근으로 Instance가 생겼는가?
↓
Keyword 조합이 불필요한 Shader Variant를 만들고 있는가?
↓
Material Property Layout이 SRP Batcher에 호환되는가?
↓
Per-Renderer 값은 어떤 방식으로 전달되는가?
↓
Material 변경이 실제 CPU/GPU 병목인가?
```

Material을 합치면 Draw와 State 전환이 줄 수 있지만 Texture Atlas, UV 변경과 Authoring 비용이 생길 수 있다.

Shader Keyword를 줄이면 Variant 수는 감소할 수 있지만 Runtime Branch가 늘 수 있다.

Profiler와 Frame Debugger로 현재 병목을 확인한 뒤 선택한다.

---

## 자주 생기는 오해

### Material 안에 Shader Code가 복사되어 있다

Material은 Shader 참조와 Property 값을 저장한다.

여러 Material이 같은 Shader Program을 사용할 수 있다.

### Shader와 Material은 같은 Asset의 다른 이름이다

Shader는 계산과 Pipeline 구조를 정의하고 Material은 그 Shader에 전달할 구체적인 값을 보관한다.

### Texture가 곧 Material이다

Texture는 Image Data Resource다.

Material은 Texture 참조를 포함할 수 있으며 Shader가 그 Texture를 어떻게 Sampling하고 해석할지 정한다.

### Material 값을 바꾸면 해당 GameObject만 바뀐다

공유 Material Asset을 변경하면 같은 Material을 참조하는 다른 Renderer도 바뀔 수 있다.

`sharedMaterial`, `material`과 `MaterialPropertyBlock`의 차이를 확인해야 한다.

### `renderer.material`은 공유 Material을 안전하게 반환한다

Renderer 전용 Material Instance를 생성할 수 있다.

특정 Object의 독립 값에는 편리하지만 Instance 수와 Lifetime을 관리해야 한다.

### MaterialPropertyBlock은 항상 가장 빠르다

Material 복제를 줄일 수 있지만 SRP Batcher와 Instancing, Render Pipeline에 따른 비용 구조가 다르다.

Target 환경에서 측정해야 한다.

### 같은 Shader를 사용하면 자동으로 한 Draw Call이 된다

Mesh, Material, Pass, Keyword, State, Instancing과 Render Pipeline 조건이 함께 맞아야 한다.

Shader 참조 하나만으로 Batch를 보장할 수 없다.

---

## 관계 정리

| 요소 | 보관하는 것 | 대표적인 변경 영향 |
| --- | --- | --- |
| Shader | GPU Program, Pass, Property 정의 | 사용하는 Material의 계산 구조 |
| Material | Shader 참조, Property 값, Keyword와 일부 Override | 공유하는 Renderer의 표면 설정 |
| Texture | Texel Data와 Import 결과 | 참조하는 Material의 Sampling 입력 |
| Renderer | Mesh와 Material Slot 연결 | Scene의 특정 Object Draw |
| MaterialPropertyBlock | Per-Renderer Property Override | 특정 Renderer의 Draw 값 |

```text
Shader
계산 규칙과 입력 형식
↑
Material
Shader 선택과 입력값
↑
Renderer
Mesh에 Material 적용
↑
GameObject
Scene의 Transform과 Component
```

---

## 정리

Shader는 Rendering Pipeline의 Programmable Stage에서 실행할 계산 규칙을 정의한다.

Material은 Shader Object에 대한 참조와 Shader가 정의한 Property의 구체적인 값을 저장한다.

```text
Shader
어떻게 계산하는가

Material
어떤 값으로 계산하는가
```

ShaderLab의 `Properties` Block은 Material이 저장하고 Inspector에서 편집할 수 있는 입력의 내부 이름, 표시 이름, Type과 기본값을 정의한다.

Material은 Color, Float, Vector와 Texture 참조를 Property 값으로 보관할 수 있다.

Texture는 Material 자체가 아니라 Shader가 Sampling할 별도의 Resource이며 Material은 Texture Asset의 참조를 저장한다.

같은 Shader를 여러 Material이 공유하여 계산 Code를 재사용하면서 서로 다른 표면 값을 만들 수 있다.

같은 Material도 여러 Renderer가 공유할 수 있으며 공유 Material의 값을 변경하면 모든 사용자에게 영향을 줄 수 있다.

`Renderer.sharedMaterial`은 공유 참조를 사용하고 `Renderer.material`은 Renderer용 Material Instance를 만들 수 있다.

특정 Renderer의 일부 값만 다르게 전달할 때는 `MaterialPropertyBlock`이나 Instancing Property를 검토할 수 있지만 Render Pipeline과 Batching 조건에서 성능을 측정해야 한다.

Shader Keyword는 Property 값과 달리 기능 또는 Compile Variant 선택에 사용될 수 있다.

Material은 Local Keyword 상태와 Render Queue Override 같은 Shader 사용 설정도 가질 수 있다.

```text
Mesh
Geometry Data
↓ Renderer가 연결
Material
Shader 참조 + Property 값
↓
Shader
GPU 계산 규칙
↓
Render Target
```

Shader와 Material을 분리하면 계산 방식은 하나의 Shader에서 관리하고 표면별 차이는 Material 값으로 재사용할 수 있다.

성능 최적화에서는 Material 개수만 줄이는 것이 아니라 Instance 생성, Keyword, SRP Batcher, GPU Instancing, Draw Call과 실제 Frame Time을 함께 확인해야 한다.
