---
title: "[Unity 렌더링] 4-8. Shader Variant란 무엇일까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - ShaderVariant
  - ShaderKeyword
  - MultiCompile
permalink: /programming/unity-4-8-shader-variant/
toc: true
toc_sticky: true
date: 2026-08-15
last_modified_at: 2026-08-15
---

하나의 Shader가 모든 Material에서 완전히 같은 기능만 수행하는 경우는 드물다.

어떤 Material은 Normal Map을 사용하고 다른 Material은 사용하지 않을 수 있다.

Scene에 따라 Main Light Shadow, Additional Light, Fog 또는 GPU Instancing 지원 여부도 달라진다.

이 차이를 하나의 Shader Source에서 처리하기 위해 Unity는 여러 개의 Compile 결과를 만들 수 있다.

각 Compile 결과가 Shader Variant다.

```text
하나의 Shader Source
↓
Keyword 조합
├─ Normal Map Off + Shadow Off
├─ Normal Map On  + Shadow Off
├─ Normal Map Off + Shadow On
└─ Normal Map On  + Shadow On
↓
서로 다른 Shader Variant
```

Variant는 Material 기능을 유연하게 조합할 수 있게 하지만 조합을 관리하지 않으면 수가 매우 빠르게 증가한다.

---

## Shader Variant란?

Shader Variant는 같은 Shader Source를 서로 다른 Keyword 조건으로 Compile한 개별 GPU Program이다.

```hlsl
#if defined(_NORMAL_MAP)
    normalWS = SampleNormalMap(input.uv);
#else
    normalWS = input.normalWS;
#endif
```

`_NORMAL_MAP`이 꺼진 Variant에서는 Normal Map을 읽는 Code가 Compile 결과에 포함되지 않을 수 있다.

켜진 Variant에는 Texture Sampling과 Normal 변환 Code가 포함된다.

```text
Variant A
_NORMAL_MAP 미정의
→ Vertex Normal 사용

Variant B
_NORMAL_MAP 정의
→ Normal Map Sampling
```

Runtime에 매 Fragment가 항상 같은 `if`를 판단하는 구조와 다르다.

Variant 방식은 Keyword 상태에 맞는 별도의 Program을 미리 준비하고 그중 하나를 선택한다.

---

## Variant가 필요한 이유

Material마다 다른 기능을 하나의 거대한 Program에 모두 넣을 수는 있다.

```hlsl
if (_UseNormalMap > 0.5)
{
    normalWS = SampleNormalMap(input.uv);
}
```

하지만 이 조건을 GPU가 Runtime에 판단하면 Branch와 양쪽 경로의 Resource 구성에 영향을 받을 수 있다.

기능 차이가 크고 Material 단위로 고정된다면 Compile 단계에서 필요 없는 경로를 제거한 Variant가 효율적일 수 있다.

```text
Variant 방식
Compile할 때 기능 경로 선택
Runtime에 맞는 Program 선택

Dynamic Branch 방식
같은 Program 안에 여러 경로 유지
Runtime에 조건 판단
```

어느 방식이 항상 더 빠른 것은 아니다.

기능의 복잡도, 조건 변경 빈도, 같은 Wave 안에서의 분기 일관성, Variant 수와 대상 GPU를 함께 고려해야 한다.

---

## Variant가 만들어지는 흐름

Shader Source에 Keyword Set을 선언하면 Unity가 가능한 조합을 계산한다.

```text
Shader Source
↓
#pragma로 Keyword Set 선언
↓
Keyword 조합 생성
↓
Platform과 Graphics API별 Compile
↓
사용하지 않는 조합 Stripping
↓
Build에 Variant 포함
```

Runtime에는 Material과 Global Keyword 상태 등에 맞는 Variant가 선택된다.

```text
Material Keyword
+ Global Keyword
+ Render Pipeline 상태
↓
사용할 Variant 결정
↓
GPU Program과 Pipeline State 사용
```

Variant의 생성, Build 포함 여부와 Runtime 선택은 서로 다른 시점의 문제다.

---

## Shader Keyword란?

Shader Keyword는 Shader Code의 조건부 동작을 제어하는 이름이다.

```text
_NORMAL_MAP
_ALPHA_CLIP
_QUALITY_LOW
_QUALITY_HIGH
_MAIN_LIGHT_SHADOWS
```

HLSL에서는 Preprocessor 조건으로 사용할 수 있다.

```hlsl
#if defined(_ALPHA_CLIP)
    clip(alpha - _Cutoff);
#endif
```

Keyword를 Variant용으로 선언하면 Unity가 Keyword 상태별 Program을 Compile한다.

Keyword를 Dynamic Branch용으로 선언하면 추가 Variant 대신 Runtime 조건을 만드는 데 사용한다.

즉 Keyword라는 이름만 보고 반드시 Variant가 생긴다고 단정할 수는 없다.

---

## Keyword Set

하나의 `#pragma` 줄에 선언된 Keyword들은 하나의 Set이다.

```hlsl
#pragma shader_feature_local _QUALITY_LOW _QUALITY_MEDIUM _QUALITY_HIGH
```

이 Set은 Quality Mode 세 가지가 서로 배타적인 선택지라는 의미다.

```text
Quality Set
├─ _QUALITY_LOW
├─ _QUALITY_MEDIUM
└─ _QUALITY_HIGH
```

한 Set 안의 Keyword는 하나의 상태를 선택하도록 설계한다.

반면 서로 독립적인 기능은 별도 Set으로 선언할 수 있다.

```hlsl
#pragma shader_feature_local _ _NORMAL_MAP
#pragma shader_feature_local _ _EMISSION
```

```text
Normal Map
Off / On

Emission
Off / On
```

독립된 Set들은 서로 조합되므로 Variant 수가 곱해진다.

---

## 빈 상태를 나타내는 `_`

Keyword가 꺼진 상태도 Variant로 만들려면 `_`를 사용할 수 있다.

```hlsl
#pragma shader_feature_local _ _NORMAL_MAP
```

이 선언은 두 상태를 표현한다.

```text
상태 1
어떤 Keyword도 정의되지 않음

상태 2
_NORMAL_MAP 정의
```

Boolean 기능 하나를 켜고 끄는 데 적합하다.

`shader_feature`에 Keyword 하나만 작성하는 축약형도 꺼진 상태를 함께 만든다.

```hlsl
#pragma shader_feature_local _NORMAL_MAP
```

명시적인 `_`를 사용하면 Set에 Off 상태가 있다는 점을 Code에서 쉽게 읽을 수 있다.

---

## multi_compile

`multi_compile`은 선언한 Keyword Set의 가능한 상태를 모두 Compile 대상으로 만든다.

```hlsl
#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
```

개념적으로 두 Variant가 생성된다.

```text
Variant A
Main Light Shadow Off

Variant B
Main Light Shadow On
```

두 개의 독립된 Set을 선언하면 모든 조합이 대상이 된다.

```hlsl
#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
#pragma multi_compile _ _ADDITIONAL_LIGHTS
```

```text
Shadow Off + Additional Off
Shadow On  + Additional Off
Shadow Off + Additional On
Shadow On  + Additional On
```

Material 참조만으로 사용 여부를 판단하기 어려운 기능에 적합하다.

Render Pipeline이나 Runtime Code가 Keyword를 바꾸어 어떤 조합이든 요구할 수 있다면 필요한 Variant를 보존해야 하기 때문이다.

---

## shader_feature

`shader_feature`도 Keyword 상태별 Variant를 만든다.

```hlsl
#pragma shader_feature_local _ _NORMAL_MAP
```

`multi_compile`과 중요한 차이는 Build에 포함할 Variant를 판단하는 방식이다.

Unity는 Build에 포함된 Material에서 실제로 사용되는 `shader_feature` Keyword 조합을 기준으로 불필요한 Variant를 제외할 수 있다.

```text
Project의 Material
├─ Material A: Normal Map Off
└─ Material B: Normal Map On

Build
→ 두 상태 모두 필요
```

```text
Project의 Material
└─ Material A: Normal Map Off

Build
→ On Variant가 사용되지 않는다고 판단될 수 있음
```

Material Inspector에서 설정하고 Runtime에 임의 조합으로 변경하지 않는 기능에 주로 적합하다.

---

## multi_compile과 shader_feature 비교

| 항목 | `multi_compile` | `shader_feature` |
|---|---|---|
| Branch 방식 | Static Branch | Static Branch |
| Compile 대상 | 가능한 모든 Keyword 상태 | Keyword 상태별 Variant |
| Build 포함 | 일반적으로 모든 조합을 보존하는 쪽 | Material 사용 상태를 바탕으로 미사용 조합 제거 가능 |
| 대표 용도 | Pipeline·Global·Runtime 제어 기능 | Material별 선택 기능 |
| 주의점 | Variant 수가 쉽게 증가 | Runtime에만 켜는 조합이 Stripping될 수 있음 |

간단한 선택 기준은 다음과 같다.

```text
Material Asset이 기능 상태를 보유하고
Build 시 사용 조합을 알 수 있음
→ shader_feature 검토

Runtime이나 Render Pipeline이 상태를 바꾸고
Build 시 필요한 조합을 Material만으로 알기 어려움
→ multi_compile 검토
```

실제 Build Pipeline의 Stripping 설정과 Variant 보존 방식까지 함께 검증해야 한다.

---

## local Keyword

기본 Keyword 선언은 Global Keyword의 영향을 받을 수 있는 Scope를 가진다.

Directive에 `_local`을 붙이면 같은 이름의 Global Keyword가 해당 Shader의 Keyword 상태를 덮어쓰지 못하게 할 수 있다.

```hlsl
#pragma shader_feature_local _ _NORMAL_MAP
#pragma multi_compile_local _ _CUSTOM_FOG
```

```text
Local Scope
해당 Shader의 Keyword Space에 한정

Global Scope
같은 이름의 Global Keyword가 여러 Shader에 영향 가능
```

Material 내부 기능처럼 다른 Shader까지 일괄 제어할 이유가 없다면 Local Keyword가 의도하지 않은 이름 충돌을 줄이는 데 유리하다.

Keyword를 Local로 만든다고 Variant 조합 자체가 자동으로 줄어드는 것은 아니다.

Scope와 Variant 수는 구분해야 한다.

---

## Global Keyword

Global Keyword는 여러 Shader의 상태를 한 번에 제어할 수 있다.

```csharp
using UnityEngine;
using UnityEngine.Rendering;

public class GlobalWeatherKeyword : MonoBehaviour
{
    private GlobalKeyword rainKeyword;

    private void Awake()
    {
        rainKeyword = GlobalKeyword.Create("_GLOBAL_RAIN");
    }

    public void SetRain(bool enabled)
    {
        Shader.SetKeyword(rainKeyword, enabled);
    }
}
```

전역 날씨처럼 다수의 Shader가 같은 상태를 공유해야 한다면 편리하다.

하지만 흔한 이름을 Global Keyword로 사용하면 의도하지 않은 Shader까지 영향을 받을 수 있다.

새 Global Keyword를 생성할 때 Unity가 현재 Load된 Shader들의 Global·Local Keyword Mapping을 갱신할 수 있으므로 Loading 시점에 미리 만드는 방식을 검토할 수 있다.

---

## Material Keyword

Material별 기능은 해당 Material에 Keyword를 설정할 수 있다.

```csharp
using UnityEngine;
using UnityEngine.Rendering;

public class MaterialKeywordExample : MonoBehaviour
{
    [SerializeField] private Material targetMaterial;

    public void SetNormalMap(bool enabled)
    {
        LocalKeyword keyword = new LocalKeyword(
            targetMaterial.shader,
            "_NORMAL_MAP"
        );

        targetMaterial.SetKeyword(keyword, enabled);
    }
}
```

Keyword를 바꾸면 Unity는 현재 상태에 맞는 Variant를 선택한다.

Runtime에 Material Keyword를 변경할 계획이라면 해당 Variant가 Build에서 제거되지 않았는지 확인해야 한다.

공유 Material을 직접 수정하면 그 Material을 사용하는 모든 Renderer에 영향을 줄 수 있다는 점도 별도의 주의 사항이다.

---

## Keyword와 HLSL 조건문

Variant용 Keyword는 Compile 시 `#define`처럼 사용된다.

```hlsl
half3 GetSurfaceNormal(Varyings input)
{
    #if defined(_NORMAL_MAP)
        return SampleNormal(input.uv, input.tangentWS);
    #else
        return normalize(input.normalWS);
    #endif
}
```

Normal Map Off Variant를 Compile할 때 `_NORMAL_MAP` 경로는 제거될 수 있다.

```text
Source Code
두 경로 존재

Compiled Variant
선택된 경로 중심의 GPU Program
```

이 특성 때문에 큰 기능 Block을 Material 상태별로 분리할 수 있다.

하지만 작은 연산 하나를 제거하려고 Keyword를 계속 추가하면 Compile 조합 비용이 더 커질 수 있다.

---

## dynamic_branch

Unity 6에서는 `dynamic_branch` Directive로 추가 Variant 없이 Keyword 기반 Runtime Branch를 만들 수 있다.

```hlsl
#pragma dynamic_branch_local _USE_DETAIL

half3 color = baseColor;

if (_USE_DETAIL)
{
    color *= SampleDetail(input.uv);
}
```

Unity는 이 Keyword를 Uniform 값에 기반한 동적 분기로 표현한다.

```text
Static Variant
Program A 또는 Program B 선택

Dynamic Branch
Program 하나 안에서 경로 A 또는 B 실행
```

장단점은 서로 반대 방향에 가깝다.

| 방식 | 장점 | 비용 가능성 |
|---|---|---|
| Static Variant | 미사용 경로 제거와 최적화 가능 | Variant 조합 증가 |
| Dynamic Branch | Variant 수 증가 없음 | Runtime Branch와 Program 복잡도 |

Dynamic Branch가 효율적인지는 GPU, Branch의 일관성, 분기 내부 연산량과 실행 빈도에 따라 달라진다.

---

## Static Branch와 Dynamic Branch

두 방식의 실행 시점을 비교하면 차이가 분명해진다.

```text
Static Branch
Build 이전 Compile 단계에서 경로 분리
↓
Runtime에 Variant 선택

Dynamic Branch
Program은 한 종류
↓
Runtime GPU 실행 중 조건 평가
```

Material 하나의 상태가 오랫동안 고정되고 분기 양쪽이 매우 무겁다면 Variant가 유리할 수 있다.

기능 차이가 작고 조합 수가 지나치게 늘어난다면 Dynamic Branch가 전체 비용을 줄일 수 있다.

성능 판단은 Shader Instruction 수만이 아니라 Build, Loading과 Runtime을 함께 봐야 한다.

---

## Keyword Set의 Variant 수 계산

서로 독립된 Keyword Set은 가능한 상태 수가 곱해진다.

```hlsl
#pragma multi_compile _ _NORMAL_MAP
#pragma multi_compile _ _EMISSION
#pragma multi_compile _QUALITY_LOW _QUALITY_MEDIUM _QUALITY_HIGH
```

각 Set의 상태 수는 다음과 같다.

```text
Normal Map = 2
Emission   = 2
Quality    = 3
```

기본 조합 수는 다음과 같다.

```text
2 × 2 × 3 = 12
```

여기에 별도의 Fog, Shadow, Lightmap, Instancing과 Platform 조건이 결합되면 수가 더 증가할 수 있다.

각 Pass도 자체 Shader Program과 Keyword Directive를 가지므로 Pass별로 Variant가 Compile된다.

---

## Variant Explosion

독립적인 On·Off 기능이 `N`개라면 단순 조합 수는 `2^N`이다.

```text
기능 1개  → 2 Variants
기능 2개  → 4 Variants
기능 5개  → 32 Variants
기능 10개 → 1,024 Variants
기능 20개 → 1,048,576 Variants
```

모든 조합이 실제로 유효하지 않더라도 선언만으로 Compile 후보가 될 수 있다.

```text
Keyword Set A 상태 수
× Keyword Set B 상태 수
× Keyword Set C 상태 수
× Pass 수
× Platform 조건
× Graphics API 조건
```

이처럼 조합이 폭발적으로 늘어나는 현상을 Variant Explosion이라고 부른다.

---

## Variant Explosion이 만드는 문제

Variant가 많으면 Runtime Fragment 연산만 느려지는 것이 아니다.

주요 영향은 여러 단계에 나타난다.

```text
Editor
Shader Import와 Compile 대기 증가

Build
Compile 시간 증가

Build 결과
Shader Data와 파일 크기 증가 가능

Runtime Loading
Shader Data Load와 Memory 사용 증가 가능

첫 사용
GPU Program과 PSO 준비로 Hitch 가능
```

Stripping으로 최종 Build에서 제거되더라도 Compile 후보를 처리하는 과정에 시간이 들 수 있다.

어느 단계에 비용이 발생하는지 Profiler와 Build Log로 구분해야 한다.

---

## 모든 조합이 유효한 것은 아니다

다음과 같은 Feature 관계를 가정한다.

```text
_PARALLAX
Normal Map이 있을 때만 의미 있음

_CLEAR_COAT_NORMAL
Clear Coat가 켜졌을 때만 의미 있음
```

독립 Keyword로 모두 선언하면 의미 없는 조합도 생긴다.

```text
Normal Map Off + Parallax On
Clear Coat Off + Clear Coat Normal On
```

가능하다면 서로 배타적인 상태를 하나의 Set으로 합치거나 기능 구조를 다시 설계할 수 있다.

```hlsl
#pragma shader_feature_local _SURFACE_BASIC _SURFACE_NORMAL _SURFACE_PARALLAX
```

단, 하나의 Set으로 합치면 상태를 독립적으로 조절할 수 없으므로 실제 Material 요구사항과 맞아야 한다.

---

## Boolean Keyword를 무조건 나누지 않기

다음 선언은 두 기능이 독립적이라 4개 조합을 만든다.

```hlsl
#pragma shader_feature_local _ _QUALITY_MEDIUM
#pragma shader_feature_local _ _QUALITY_HIGH
```

하지만 Quality가 Low, Medium, High 중 하나라면 두 Boolean보다 하나의 Set이 자연스럽다.

```hlsl
#pragma shader_feature_local _QUALITY_LOW _QUALITY_MEDIUM _QUALITY_HIGH
```

```text
두 Boolean
Off/Off
On/Off
Off/On
On/On ← 의미가 모호할 수 있음

하나의 Enum Set
Low
Medium
High
```

Keyword 구조는 Material의 실제 상태 공간을 표현해야 한다.

---

## Stage 전용 Keyword

Keyword가 Fragment Shader에만 영향을 준다면 Stage Suffix로 범위를 나타낼 수 있다.

```hlsl
#pragma shader_feature_local_fragment _ _NORMAL_MAP
```

대표적인 Suffix는 다음과 같다.

```text
_vertex
_fragment
_hull
_domain
_geometry
_raytracing
```

Stage 제한은 불필요한 Variant 처리를 줄이는 데 도움을 줄 수 있다.

하지만 Graphics API에 따라 Stage Keyword 처리 방식과 효과가 다를 수 있으므로 대상 Platform에서 확인해야 한다.

`dynamic_branch`는 Variant를 만들지 않으므로 Stage Variant Suffix를 사용하는 대상이 아니다.

---

## Pass와 Variant의 관계

이전 글에서 Pass는 목적별 Program과 Render State의 묶음이라고 정리했다.

Variant는 각 Pass의 Program이 Keyword 조합에 따라 달라진 Compile 결과다.

```text
Shader
├─ Forward Pass
│  ├─ Normal Off / Shadow Off
│  ├─ Normal On  / Shadow Off
│  ├─ Normal Off / Shadow On
│  └─ Normal On  / Shadow On
│
└─ ShadowCaster Pass
   ├─ Alpha Clip Off
   └─ Alpha Clip On
```

Forward Pass에서만 필요한 Keyword를 ShadowCaster Pass까지 무조건 선언하면 불필요한 Variant가 생길 수 있다.

각 Pass가 실제로 사용하는 기능만 선언하는 것이 중요하다.

---

## URP와 Variant

URP는 다양한 Project 설정과 Rendering 기능을 지원하기 위해 Keyword를 사용한다.

대표적으로 다음과 같은 기능이 Variant에 영향을 줄 수 있다.

```text
Main Light Shadow
Additional Light와 Shadow
Soft Shadow
Lightmap
Fog
Reflection Probe
Decal
Rendering Layer
SSAO
GPU Instancing
```

Custom URP Shader가 URP Library의 Lighting 기능을 사용하면 관련 `multi_compile` Directive가 필요할 수 있다.

```hlsl
#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
#pragma multi_compile_fog
```

실제 Directive는 사용하는 URP Version과 기능의 공식 Shader 예제 및 Package Source를 기준으로 확인해야 한다.

필요하지 않은 기능까지 관습적으로 복사하면 Variant가 증가한다.

---

## URP Asset과 Stripping

URP Asset의 기능 설정은 어떤 Variant가 필요할지 판단하는 근거가 된다.

예를 들어 Project에서 Directional Light Shadow를 사용하지 않고 관련 기능을 모든 Build 대상 URP Asset에서 비활성화하면 URP가 해당 Variant를 제거할 수 있다.

```text
URP Asset Feature Off
↓
해당 Feature Variant가 불필요하다고 판단
↓
Build에서 Stripping 가능
```

Build에 포함되는 Quality Level마다 서로 다른 URP Asset을 사용한다면 그중 하나라도 기능을 요구하는지 확인해야 한다.

```text
Low Quality URP Asset
Shadow Off

High Quality URP Asset
Shadow On

Build
→ Shadow On Variant도 필요할 수 있음
```

현재 선택한 Editor Quality 설정 하나만 보고 Build 전체 Variant를 판단하면 안 된다.

---

## Shader Variant Stripping

Stripping은 Build에 필요하지 않은 Shader Variant를 제외하는 과정이다.

```text
Compile 후보 Variants
↓
Platform과 Project 설정 검사
↓
Material 사용 상태 검사
↓
Built-in / URP Stripping
↓
Custom Stripping
↓
Build 포함 Variants
```

Stripping은 Build 크기, Shader Loading과 Memory 사용을 줄일 수 있다.

반대로 필요한 Variant를 제거하면 Runtime에서 원하는 기능이 올바르게 표시되지 않을 수 있다.

공격적으로 제거하기 전에 실제 Runtime Keyword 조합을 수집하고 검증해야 한다.

---

## shader_feature와 Runtime 변경의 함정

Material Asset에는 Keyword가 꺼져 있지만 Runtime Code가 켜는 경우를 가정한다.

```text
Build 시점
모든 Material에서 _DISSOLVE Off

Runtime
Script가 _DISSOLVE On
```

`shader_feature`의 On Variant가 사용되지 않는다고 판단되어 Build에서 제거되면 Runtime에 필요한 정확한 Variant가 없을 수 있다.

대응 방법은 Project 구조에 따라 달라진다.

```text
필요한 상태를 가진 Material을 Build에 포함
Shader Variant Collection으로 Variant 보존
multi_compile 사용 검토
Custom Stripping Rule에 예외 추가
```

무조건 `multi_compile`로 바꾸면 안전할 수 있지만 모든 조합을 보존해 Variant 수가 크게 늘 수 있다.

필요한 Runtime 상태만 명시적으로 관리하는 편이 좋다.

---

## Custom Shader Stripping

Unity는 `IPreprocessShaders`를 통해 Build 전에 Graphics Shader Variant 목록을 검사하고 불필요한 항목을 제거할 수 있다.

```text
OnProcessShader
↓
Shader
Snippet Data
Compiler Data 목록
↓
Project 규칙으로 제외
```

Custom Stripper는 Project에서 절대 사용하지 않는 조합을 제거할 때 유용하다.

하지만 Keyword 이름만 보고 제거하면 다른 Pass, Quality Level이나 Platform에서 필요한 Variant까지 잃을 수 있다.

Shader, Pass Type, Platform, Graphics Tier와 Keyword 조합을 명확히 기록하고 자동 Test를 두는 편이 안전하다.

현재 글의 작업 조건상 저장소에는 Editor Script를 추가하지 않고 개념만 다룬다.

---

## Variant 수 확인하기

추측보다 Build Log를 확인해야 한다.

Unity 6의 Graphics Settings에서 Shader Stripping Logging을 활성화하면 Build 후 `Editor.log`의 `ShaderStrippingReport`로 Compile 및 Stripping 수를 확인할 수 있다.

```text
Graphics Settings
↓
Shader Stripping Logging 활성화
↓
Player Build
↓
Editor.log
↓
ShaderStrippingReport 검색
```

더 자세한 Variant Export 설정을 사용하면 Project의 `Temp` 아래 생성된 Stripping 관련 JSON에서 Shader별 정보를 확인할 수 있다.

이 파일들은 임시 Build 분석 자료이며 Blog 저장소에 추가할 대상은 아니다.

---

## Variant를 처음 사용할 때의 Hitch

Build에 Variant가 포함되어 있어도 Runtime에 처음 사용하는 순간 추가 준비가 필요할 수 있다.

```text
Variant Data Load
↓
Unity가 GPU용 Program 준비
↓
Graphics Driver Compile
↓
관련 Pipeline State Object 생성
↓
첫 Draw
```

이 작업이 Gameplay 도중 발생하면 짧은 멈춤처럼 보일 수 있다.

Variant 수를 줄이는 것은 Build만이 아니라 Runtime Loading과 첫 사용 문제에도 연결된다.

Unity Profiler에서 `Shader.CreateGPUProgram`, `CreateGraphicsGraphicsPipelineImpl` 같은 Marker를 확인하여 Shader 준비 시점을 조사할 수 있다.

---

## Shader Variant Collection

Shader Variant Collection은 필요한 Shader, Pass Type과 Keyword 조합의 목록이다.

```text
Shader Variant Collection
├─ Shader A / Forward / Keyword 조합 1
├─ Shader A / Shadow / Keyword 조합 2
└─ Shader B / Forward / Keyword 조합 3
```

대표적인 용도는 두 가지다.

```text
1. Runtime에 필요하지만 Scene 참조만으로 찾기 어려운 Variant 보존
2. 필요한 Variant를 실제 사용 전에 Warm-up
```

Collection에 넣었다고 모든 Graphics API와 모든 Pipeline State 준비가 자동으로 완벽해진다고 단정할 수는 없다.

사용할 Platform에서 실제 Gameplay 경로와 PSO 생성 상태를 측정해야 한다.

---

## Shader Warm-up

Warm-up은 필요한 Shader Variant와 관련 GPU 표현을 실제 사용 전에 준비하는 과정이다.

```text
Loading Screen
↓
필요 Variant Warm-up
↓
GPU Program / PSO 준비
↓
Gameplay 진입
```

Unity는 `ShaderVariantCollection.WarmUp`과 Preloaded Shaders 같은 방법을 제공한다.

Unity 6에는 Graphics State Collection을 이용한 추적 및 Warm-up 흐름도 있지만 일부 관련 API는 Experimental 상태일 수 있다.

모든 Shader의 모든 Variant를 한꺼번에 Warm-up하면 시작 시간과 Memory 부담이 커질 수 있다.

실제로 필요한 Variant를 Scene 또는 Gameplay 구간별로 준비하는 전략을 검토해야 한다.

---

## Variant 전환과 Runtime 성능

이미 준비된 Variant 사이를 전환하는 작업도 Render State와 Program 변경에 연결된다.

```text
Draw A
Variant: Normal Map Off
↓
Draw B
Variant: Normal Map On
↓
GPU Program 또는 PSO 상태 변경 가능
```

Render Pipeline은 유사한 State를 정렬하여 변경 비용을 줄이려 한다.

Material Keyword 조합이 지나치게 다양하면 같은 Shader를 사용해도 서로 다른 Variant로 나뉜다.

SRP Batcher는 호환되는 Material Draw의 CPU Data Binding 비용을 줄이는 데 도움을 주지만 Variant 종류 자체를 없애지는 않는다.

---

## GPU Instancing Keyword

Custom Shader에서 GPU Instancing Variant를 지원하려면 다음 Directive를 사용할 수 있다.

```hlsl
#pragma multi_compile_instancing
```

Instancing On과 Off 경로가 필요해 Variant가 추가될 수 있다.

```text
기존 Variant 수
× Instancing 상태
```

Instancing을 사용하지 않는 Shader에 Directive를 관습적으로 추가하면 불필요한 Compile 범위를 늘릴 수 있다.

반대로 Instancing이 필요한 Shader에서 Variant와 Instance Data Macro를 올바르게 구성하지 않으면 기대한 Batch가 만들어지지 않는다.

---

## Fog Keyword

Unity Shader 예제에서 다음 Directive를 볼 수 있다.

```hlsl
#pragma multi_compile_fog
```

Fog Mode에 필요한 Variant를 생성하는 Shortcut이다.

Fog를 사용하지 않는 Project라면 관련 Variant가 최종 Build에서 적절히 제거되는지 확인할 수 있다.

Custom Shader가 Fog를 계산하지 않는데 Directive만 복사되어 있다면 불필요한 조합이 될 수 있다.

Shader Template를 복사할 때 각 `#pragma`의 목적을 확인해야 하는 이유다.

---

## Keyword가 Property와 자동으로 연결되는가?

ShaderLab Property를 선언했다고 모든 Keyword가 자동으로 켜지는 것은 아니다.

```shaderlab
[Toggle(_NORMAL_MAP)] _UseNormalMap("Use Normal Map", Float) = 0
```

`Toggle` Attribute는 Material Inspector에서 Property와 Keyword 상태를 연결하는 데 사용할 수 있다.

Custom Shader GUI나 C# Code가 Texture 할당 여부에 따라 Keyword를 갱신할 수도 있다.

```text
Property Value
Material Inspector 또는 Shader GUI
↓
Material Keyword 갱신
↓
Variant 선택
```

Float 값과 Keyword 상태가 서로 어긋나면 Inspector에는 기능이 켜진 것처럼 보여도 다른 Variant가 선택될 수 있다.

---

## Keyword Set은 Runtime에 자동으로 배타적이지 않다

Shader Source에서 한 줄에 선언한 Keyword Set은 Compile 조합을 표현한다.

Runtime C# API가 그 Set의 배타성을 자동으로 관리해 주는 것은 아니다.

```hlsl
#pragma shader_feature_local _QUALITY_LOW _QUALITY_MEDIUM _QUALITY_HIGH
```

Code가 `_QUALITY_LOW`와 `_QUALITY_HIGH`를 동시에 켜는 잘못된 상태를 만들 수 있다.

```text
올바른 변경
기존 Quality Keyword 모두 Off
↓
선택한 Quality Keyword 하나 On
```

유효하지 않은 조합에서는 Unity가 정확히 의도한 Variant를 선택한다고 보장하기 어렵다.

Keyword 상태를 변경하는 함수를 한곳에 모으는 편이 안전하다.

---

## Variant와 Material 복제

Renderer마다 Keyword를 다르게 만들기 위해 `renderer.material`을 반복해서 접근하면 Material Instance가 생성될 수 있다.

```text
Shared Material
↓ renderer.material 접근
개별 Material Instance
↓
Material 수와 상태 조합 증가
```

Keyword는 Program 구조를 바꾸는 기능에 사용하고 단순 Color나 강도처럼 같은 Program에서 바꿀 수 있는 값은 Uniform Property로 유지하는 편이 일반적이다.

Renderer별 작은 Data 차이는 `MaterialPropertyBlock` 사용 가능성을 검토할 수 있다.

다만 어떤 방식이 Batching과 Rendering 결과에 미치는 영향은 사용하는 Unity Version과 Pipeline에서 측정해야 한다.

---

## Keyword가 필요한 기능과 Property로 충분한 값

다음 기준으로 구분할 수 있다.

```text
Keyword 후보
Texture Sampling 경로 전체 제거
큰 Lighting Model 변경
서로 다른 Resource 또는 Stage 사용
Compile 시 제거할 큰 기능 Block

Property 후보
Color
Roughness
Intensity
Scale
같은 연산 구조에서 바뀌는 수치
```

Property 하나가 달라질 때마다 Variant를 만들 필요는 없다.

연속적인 값은 Variant 상태로 표현하기에도 적합하지 않다.

```text
Roughness 0.0 ~ 1.0
→ Uniform Float

Normal Map Off / On
→ Keyword 후보
```

---

## Variant를 줄이는 설계 방법

Variant 최적화는 선언을 무작정 삭제하는 작업이 아니다.

다음 순서로 접근할 수 있다.

```text
1. 실제 Material과 Runtime 상태 수집
2. Shader·Pass별 Variant 수 확인
3. 사용하지 않는 URP 기능 비활성화
4. 독립 Keyword와 배타 Keyword 재구성
5. Material 기능은 shader_feature 검토
6. Shader 내부 기능은 local Scope 검토
7. 작은 기능은 Dynamic Branch 또는 Property 검토
8. 필요한 Runtime Variant 보존
9. Build와 실제 Device 검증
```

Variant 수 감소와 Runtime GPU 비용 사이에 Trade-off가 생길 수 있으므로 한쪽 수치만 최적화하지 않는다.

---

## Shader를 나누는 선택

하나의 Uber Shader에 모든 기능을 넣는 대신 용도가 크게 다른 Shader를 분리할 수 있다.

```text
하나의 Uber Shader
공통 관리가 쉬움
Keyword 조합이 많아질 수 있음

여러 전용 Shader
Variant 공간을 분리 가능
Shader Asset과 Code 중복이 늘 수 있음
```

예를 들어 Character Skin과 단순 Environment Unlit Effect가 거의 Code를 공유하지 않는다면 하나의 Shader Keyword 조합으로 억지로 묶을 이유가 적다.

반대로 공통 Lighting Code가 대부분이고 기능 차이가 작다면 분리로 유지 보수 비용만 늘 수 있다.

Shader Family의 책임과 실제 Variant Report를 기준으로 결정해야 한다.

---

## Build Target마다 Variant가 달라질 수 있다

Shader는 Graphics API와 Platform 조건에 따라 다른 Program으로 Compile된다.

```text
Windows
Direct3D

Android
Vulkan / OpenGL ES

iOS
Metal
```

같은 Keyword 조합이라도 Target API마다 Compile 결과와 지원 기능이 다를 수 있다.

Desktop Build의 Variant 수와 Warm-up 결과만 보고 Mobile Device의 동작을 판단하면 안 된다.

Build Target, Graphics API, Quality Level과 URP Asset 조합별로 확인해야 한다.

---

## Variant 문제를 진단하는 흐름

Material 기능이 Editor에서는 보이지만 Player Build에서 사라진 상황을 가정한다.

```text
1. Material Keyword 상태 확인
↓
2. Shader의 #pragma 선언 확인
↓
3. shader_feature인지 multi_compile인지 확인
↓
4. Build에 해당 Material과 Variant가 참조되는지 확인
↓
5. URP 및 Custom Stripping Log 확인
↓
6. Frame Debugger에서 선택 Pass와 Keyword 확인
↓
7. Target Device Capture로 Program 확인
```

Editor는 더 많은 Variant를 가지고 있을 수 있으므로 Editor에서 정상이라는 사실만으로 Player Build 포함 여부를 보장할 수 없다.

---

## 자주 혼동하는 내용

### Keyword 하나는 Variant 하나를 만든다?

정확하지 않다.

Keyword는 Set의 상태를 구성하고 여러 Set의 상태 수가 곱해져 Variant 조합이 만들어진다.

### shader_feature는 필요한 Variant를 항상 보존한다?

아니다.

Build 시 Material에서 사용되지 않은 상태는 제거될 수 있으므로 Runtime에만 활성화하는 조합을 별도로 관리해야 한다.

### multi_compile이면 Stripping되지 않는다?

모든 경우에 그렇다고 단정할 수 없다.

Render Pipeline과 Build 설정, Platform 및 Custom Preprocessor가 불필요한 Variant를 제거할 수 있다.

### Local Keyword는 Variant를 만들지 않는다?

아니다.

Local은 Scope에 관한 설정이다. `shader_feature_local`과 `multi_compile_local`도 Keyword 상태별 Variant를 만든다.

### Dynamic Branch는 항상 Variant보다 느리다?

아니다.

분기 비용은 GPU와 실행 패턴에 따라 달라지고 Variant 감소로 얻는 Build·Memory 이점도 있다.

### Variant가 많으면 한 Draw에서 전부 실행된다?

아니다.

현재 Keyword 상태에 맞는 Variant 하나가 선택되어 해당 Draw에 사용된다.

### Variant를 많이 만들면 Runtime Shader 연산이 자동으로 느려진다?

직접적인 의미로는 아니다.

선택된 Variant의 Program 복잡도가 Draw 비용을 결정한다. 많은 전체 Variant는 주로 Compile, Build 크기, Loading, Memory와 준비 비용에 영향을 준다.

---

## 확인해야 할 성능 지표

Variant 최적화 전후에 다음 항목을 분리해 측정한다.

```text
Editor Shader Import 시간
Player Build 시간
Compile 전 Variant 수
Stripping 후 Variant 수
Build 파일 크기
Shader Runtime Memory
Scene Loading 시간
첫 사용 Hitch
GPU Frame 시간
```

Variant 수를 줄였지만 Dynamic Branch로 바꾼 Shader의 GPU 시간이 늘 수 있다.

반대로 Variant가 조금 늘더라도 자주 실행되는 복잡한 분기를 제거해 GPU 시간이 줄 수 있다.

최종 기준은 Project의 Build Workflow와 목표 Device에서의 사용자 경험이다.

---

## 정리

Shader Variant는 하나의 Shader Source를 서로 다른 Keyword 조건으로 Compile한 개별 GPU Program이다.

```text
Shader Source
+ Keyword Set
↓
Keyword 조합
↓
Shader Variants
```

`multi_compile`은 가능한 Keyword 상태를 모두 Compile 대상으로 만들며 Pipeline이나 Runtime에서 요구할 수 있는 기능에 주로 사용한다.

`shader_feature`는 Build에 포함된 Material의 사용 상태를 바탕으로 미사용 Variant를 제거할 수 있어 Material별 기능에 적합하다.

`dynamic_branch`는 추가 Variant 대신 같은 Program 안의 Runtime Branch를 사용한다.

독립된 Keyword Set의 상태 수는 곱해지므로 작은 On·Off 기능도 쌓이면 Variant Explosion을 만든다.

많은 Variant는 Shader Import, Build 시간, 파일 크기, Loading Memory와 첫 사용 시 GPU Program 및 PSO 준비에 영향을 줄 수 있다.

URP Asset에서 사용하지 않는 기능을 비활성화하고, Local Scope, Keyword Set 구조, `shader_feature`, Dynamic Branch와 Stripping을 목적에 맞게 선택해야 한다.

필요한 Runtime Variant를 지나치게 제거하면 Player Build에서 Rendering 오류가 생길 수 있으므로 Variant Report, Frame Debugger, Profiler와 실제 Device를 이용해 검증해야 한다.
