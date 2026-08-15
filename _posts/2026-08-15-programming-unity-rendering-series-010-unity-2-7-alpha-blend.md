---
title: "[Unity 렌더링] 2-7. Alpha와 Blend는 어떻게 동작할까?"
excerpt: "Unity Rendering"
categories:
  - Programming
tags:
  - Unity
  - Rendering
  - Alpha
  - Blending
  - Transparent
permalink: /programming/unity-2-7-alpha-blend/
toc: true
toc_sticky: true
date: 2026-08-15
last_modified_at: 2026-08-15
---

유리, 연기, 불꽃, 물, Particle 같은 표면은 뒤의 화면이 일부 보이도록 표현해야 한다.

불투명 오브젝트처럼 자신의 Color로 기존 화면을 완전히 덮어쓰면 이런 반투명 결과를 만들 수 없다.

```text
Opaque
새 Color가 기존 Color를 대체

Transparent
새 Color와 기존 Color를 결합
```

새 Fragment Shader가 계산한 Color와 Render Target에 이미 저장된 Color를 어떤 비율과 연산으로 합칠지 결정하는 과정이 **Blending**이다.

Alpha는 이때 혼합 비율이나 다른 효과를 제어하는 값으로 자주 사용된다.

하지만 Alpha 값이 있다는 사실만으로 자동으로 투명해지는 것은 아니다.

```text
Alpha 값
데이터

Blend State
Alpha를 포함한 값을 이용해 Color를 결합하는 규칙
```

Alpha와 Blend의 차이를 이해하면 Transparent가 Opaque와 다른 Render Queue, Sorting, ZWrite 설정을 요구하는 이유도 연결된다.

---

## Color의 Alpha란?

화면 Color는 보통 Red, Green, Blue 성분으로 표현한다.

Alpha를 포함하면 네 성분의 값이 된다.

```text
RGBA

R = Red
G = Green
B = Blue
A = Alpha
```

Shader에서는 다음처럼 `float4` 또는 `half4`로 Color를 표현할 수 있다.

```hlsl
half4 color = half4(1.0, 0.2, 0.1, 0.5);
```

일반적인 투명 표현에서는 Alpha 0을 완전 투명, Alpha 1을 완전 불투명으로 해석한다.

```text
Alpha = 0
Source가 보이지 않음

Alpha = 0.5
Source와 배경이 함께 보임

Alpha = 1
Source가 완전히 보임
```

하지만 이것은 특정 Blend 식에서의 해석이다.

Alpha는 단순한 숫자이므로 Shader와 Blend State가 다르면 Mask, Emission 강도, Smoothness 같은 다른 용도로 사용할 수도 있다.

---

## Texture의 Alpha Channel

Texture는 RGB 외에 Alpha Channel을 포함할 수 있다.

예를 들어 연기 Texture에서는 연기 중심의 Alpha는 높고 바깥쪽은 낮게 저장할 수 있다.

```text
Texture 중앙
Alpha가 높음

Texture 가장자리
Alpha가 낮음
```

Fragment Shader는 Texture를 Sampling하여 Alpha를 얻고 Material Color의 Alpha와 곱할 수 있다.

```hlsl
half4 textureColor = SAMPLE_TEXTURE2D(
    _BaseMap,
    sampler_BaseMap,
    input.uv
);

half4 finalColor = textureColor * _BaseColor;
return finalColor;
```

최종 Alpha는 Texture, Material Property, Vertex Color, Particle 수명 같은 여러 값의 조합으로 만들어질 수 있다.

```text
Texture Alpha
× Material Alpha
× Vertex Alpha
× Fade 값
= Final Alpha
```

이 Final Alpha를 Blend State가 어떻게 사용하는지가 실제 화면 결과를 결정한다.

---

## Alpha가 0.5면 자동으로 반투명할까?

Fragment Shader가 Alpha 0.5를 출력해도 Blending이 꺼져 있다면 일반적으로 Source Color가 Render Target을 덮어쓴다.

```text
Fragment Output
RGBA = (1, 0, 0, 0.5)

Blend Off
↓
RGB가 기존 Color를 대체
```

Alpha가 Color Buffer에 기록될 수는 있지만 RGB가 자동으로 절반만 보이는 것은 아니다.

반투명 결과를 만들려면 Blend State를 활성화하고 Source와 Destination을 결합할 규칙을 지정해야 한다.

Unity ShaderLab에서는 `Blend` Command를 사용한다.

```shaderlab
Blend SrcAlpha OneMinusSrcAlpha
```

Alpha는 데이터이고 Blending은 그 데이터를 사용할 수 있는 Render State다.

---

## Source와 Destination

Blending에서는 새로 그리려는 Fragment Color를 Source라고 부른다.

Render Target에 이미 저장된 Color를 Destination이라고 부른다.

```text
Source
현재 Fragment Shader 출력

Destination
현재 Render Target Color
```

예를 들어 불투명 배경 위에 반투명 유리를 그린다면 다음과 같다.

```text
Source = 유리 Shader Color
Destination = 뒤의 불투명 Scene Color
```

GPU의 Blend Stage는 두 Color에 Blend Factor를 곱하고 Blend Operation으로 결합한다.

```text
Output
= Source × Source Factor
   BlendOp
   Destination × Destination Factor
```

기본적인 Blend Operation은 두 결과를 더하는 `Add`다.

---

## 일반적인 Alpha Blending

Straight Alpha를 사용하는 일반적인 Alpha Blend는 다음처럼 설정할 수 있다.

```shaderlab
Blend SrcAlpha OneMinusSrcAlpha
```

이를 식으로 표현하면 다음과 같다.

```text
Output RGB
= Source RGB × Source Alpha
+ Destination RGB × (1 - Source Alpha)
```

Source Alpha가 0이면 Source의 기여는 사라지고 Destination이 그대로 남는다.

```text
Alpha = 0

Source × 0
+ Destination × 1
= Destination
```

Source Alpha가 1이면 Destination의 기여가 사라지고 Source가 남는다.

```text
Alpha = 1

Source × 1
+ Destination × 0
= Source
```

Alpha가 0.5라면 두 Color가 절반씩 기여한다.

---

## 숫자로 보는 Alpha Blend

배경이 파란색이고 그 위에 Alpha 0.25의 빨간색을 그린다고 가정할 수 있다.

```text
Source RGB = (1, 0, 0)
Source Alpha = 0.25

Destination RGB = (0, 0, 1)
```

일반 Alpha Blend 식을 적용한다.

```text
Output
= (1, 0, 0) × 0.25
+ (0, 0, 1) × 0.75

= (0.25, 0, 0.75)
```

결과는 빨간색이 조금 섞인 파란색이 된다.

Blend는 투명 오브젝트의 Color를 단순히 흐리게 만드는 것이 아니라 현재 Destination Color와 결합한다.

같은 Source라도 뒤에 어떤 Color가 있느냐에 따라 결과가 달라진다.

---

## Blend Factor

Unity ShaderLab의 `Blend` Command는 Source와 Destination에 적용할 Factor를 지정한다.

```shaderlab
Blend SourceFactor DestinationFactor
```

자주 사용하는 Factor에는 다음과 같은 값이 있다.

| Factor | 의미 |
|---|---|
| `One` | 1을 곱함 |
| `Zero` | 0을 곱함 |
| `SrcAlpha` | Source Alpha를 곱함 |
| `OneMinusSrcAlpha` | 1에서 Source Alpha를 뺀 값을 곱함 |
| `DstAlpha` | Destination Alpha를 곱함 |
| `OneMinusDstAlpha` | 1에서 Destination Alpha를 뺀 값을 곱함 |
| `SrcColor` | Source Color를 곱함 |
| `DstColor` | Destination Color를 곱함 |

어떤 Factor를 선택하느냐에 따라 Alpha Transparency, Additive Light, Multiply Darkening 같은 서로 다른 결과를 만들 수 있다.

---

## BlendOp

Blend Factor를 적용한 Source와 Destination을 어떤 연산으로 결합할지도 지정할 수 있다.

Unity ShaderLab에서는 `BlendOp`를 사용한다.

```shaderlab
BlendOp Add
```

대표적인 Operation은 다음과 같다.

```text
Add
Source와 Destination을 더함

Sub
Source에서 Destination을 뺌

RevSub
Destination에서 Source를 뺌

Min
더 작은 값을 선택

Max
더 큰 값을 선택
```

모든 Blend Operation이 모든 Graphics API와 하드웨어에서 동일하게 지원되는 것은 아니다.

일반적인 Alpha, Additive, Multiply Blend는 폭넓게 사용할 수 있지만 특수 Operation은 대상 플랫폼 지원을 확인해야 한다.

---

## Opaque는 Blending을 사용할까?

일반적인 Opaque Material은 Blending을 끄고 Fragment Shader의 Color로 Destination을 대체한다.

개념적으로 다음과 같다.

```shaderlab
Blend Off
```

또는 Blend 식으로 표현하면 Source만 남기는 형태다.

```shaderlab
Blend One Zero
```

```text
Output
= Source × 1
+ Destination × 0
= Source
```

Opaque는 보통 ZWrite On으로 Depth를 기록하고, Opaque Queue에서 Transparent보다 먼저 렌더링된다.

Blending이 필요 없으므로 GPU의 Hidden Surface 제거와 Render Target 처리에서 더 유리한 최적화를 사용할 가능성이 있다.

---

## Transparent Surface

URP Material에서 Surface Type을 Transparent로 설정하면 해당 Material은 배경과 결합되는 Transparent Rendering 경로를 사용한다.

```text
Surface Type = Opaque
완전히 불투명한 표면

Surface Type = Transparent
Blend Mode에 따라 배경과 결합
```

URP는 일반적으로 Opaque Material을 먼저 렌더링하고 Transparent Material을 별도의 단계에서 나중에 렌더링한다.

Transparent Surface에서는 Alpha, Premultiply, Additive, Multiply 같은 Blend Mode를 선택할 수 있다.

Material Inspector 설정은 Render Queue, Blend State와 Depth State를 일관된 조합으로 구성하는 데 도움을 준다.

Custom Shader에서는 이 상태를 직접 올바르게 설정해야 한다.

---

## Straight Alpha

일반적인 `Blend SrcAlpha OneMinusSrcAlpha`는 Source RGB가 Alpha와 아직 곱해지지 않은 Straight Alpha 데이터를 기대한다.

```text
Source RGB
원래 Color

Source Alpha
별도의 Coverage 또는 Transparency 값
```

Blend Stage가 Source RGB에 Source Alpha를 곱한다.

```text
Output
= SourceRGB × SourceAlpha
+ DestinationRGB × (1 - SourceAlpha)
```

Texture의 투명 영역에 RGB가 남아 있어도 Alpha가 0이라면 최종 기여는 0이 될 수 있다.

하지만 Texture Filtering, Mipmap과 압축 과정에서 투명 영역의 RGB가 가장자리 Artifact에 영향을 줄 수 있다.

---

## Premultiplied Alpha

Premultiplied Alpha는 Source RGB가 미리 Alpha와 곱해진 형태다.

```text
저장 또는 Shader 출력 RGB
= Original RGB × Alpha
```

이미 Alpha가 적용되었으므로 Blend Stage에서 Source에 다시 Alpha를 곱하지 않는다.

```shaderlab
Blend One OneMinusSrcAlpha
```

식은 다음과 같다.

```text
Output
= Premultiplied Source RGB
+ Destination RGB × (1 - Source Alpha)
```

Straight와 Premultiplied는 같은 투명도를 표현할 수 있지만 Source RGB의 전제가 다르다.

Premultiplied 데이터를 Straight Alpha Blend로 처리하면 Alpha가 두 번 곱해져 너무 어둡게 보일 수 있다.

반대로 Straight 데이터를 Premultiplied Blend로 처리하면 Source가 지나치게 밝게 기여할 수 있다.

---

## Premultiplied Alpha가 가장자리에 유리한 이유

투명 Texture의 가장자리에서는 Color와 Alpha가 Filtering된다.

Straight Alpha Texture의 완전 투명 Pixel에 검은 RGB가 저장되어 있다면 가장자리 Sampling에서 검은 Color가 섞인 뒤 Alpha가 적용되어 어두운 테두리가 생길 수 있다.

```text
불투명 빨강 Pixel
옆의 투명 검정 Pixel
↓ Bilinear Filtering
어두운 중간 RGB
```

Premultiplied Alpha는 투명도에 맞게 RGB 에너지를 미리 표현하므로 특정 Filtering과 합성 과정에서 가장자리 Artifact를 줄이는 데 유리할 수 있다.

하지만 올바른 결과를 위해 Texture 제작, Shader 출력과 Blend State가 모두 같은 Alpha Convention을 사용해야 한다.

Premultiply 설정만 켜면 모든 Halo 문제가 자동으로 해결되는 것은 아니다.

---

## Additive Blending

Additive Blend는 Source Color를 Destination에 더한다.

대표적인 설정은 다음과 같다.

```shaderlab
Blend One One
```

```text
Output
= Source + Destination
```

Alpha로 Source 강도를 조절하려면 다음과 같은 구성을 사용할 수도 있다.

```shaderlab
Blend SrcAlpha One
```

```text
Output
= Source × SourceAlpha
+ Destination
```

불꽃, 빛, Laser, Glow Particle처럼 화면을 밝게 더하는 효과에 적합하다.

검은색 Source는 더해도 Destination을 바꾸지 않고 밝은 Source는 화면을 밝게 만든다.

여러 Layer가 겹치면 Color가 빠르게 밝아져 HDR 범위로 올라가거나 Saturation될 수 있다.

---

## Additive는 순서와 무관할까?

단순한 덧셈은 교환 법칙이 성립하므로 Additive Particle끼리의 순서는 일반 Alpha Blend보다 결과에 덜 민감할 수 있다.

```text
A + B = B + A
```

하지만 Depth Test, Tone Mapping, Clamp, 다른 Blend Mode와의 혼합, Render Target Format 같은 요소가 함께 있으면 전체 Rendering Order가 완전히 무관하다고 단정할 수 없다.

Additive Material도 보통 Transparent Queue에서 렌더링되고 불투명 Geometry의 Depth에는 가려져야 한다.

시각적 요구와 Pipeline 구성을 기준으로 판단해야 한다.

---

## Multiply Blending

Multiply Blend는 Destination Color에 Source Color를 곱하여 화면을 어둡게 하거나 색을 입힐 수 있다.

대표적인 형태는 다음처럼 표현할 수 있다.

```shaderlab
Blend DstColor Zero
```

```text
Output
= Source × Destination
```

Source가 흰색이면 Destination이 유지된다.

```text
Destination × 1 = Destination
```

Source가 검은색이면 결과가 검게 된다.

```text
Destination × 0 = 0
```

그림자 형태의 Overlay나 색상 필터 같은 효과에 사용할 수 있다.

URP Material의 Multiply Mode가 사용하는 세부 상태와 Alpha 처리는 Shader에 따라 달라질 수 있으므로 Custom Blend 식과 완전히 같다고 무조건 가정하면 안 된다.

---

## Alpha Blending은 순서에 의존한다

일반 Alpha Blending은 Source와 Destination의 역할이 다르므로 그리는 순서를 바꾸면 결과가 달라진다.

```text
먼 파랑 먼저
가까운 빨강 나중

vs

가까운 빨강 먼저
먼 파랑 나중
```

각 단계에서 이전 결과가 Destination이 되기 때문에 최종 Color가 같지 않을 수 있다.

```text
Blend(A over B)
≠
Blend(B over A)
```

따라서 일반적인 Transparent Geometry는 Camera에서 먼 오브젝트부터 가까운 오브젝트 순서로 렌더링하는 Back-to-Front Sorting이 필요하다.

---

## Opaque와 Transparent의 렌더링 순서

일반적인 흐름은 Opaque를 먼저 그리고 Transparent를 나중에 그리는 것이다.

```text
Opaque Geometry
ZWrite On
Depth Buffer 구성
↓
Skybox 또는 Background
↓
Transparent Geometry
ZTest 사용, ZWrite Off가 일반적
Back-to-Front Sorting
```

Opaque가 먼저 Color와 Depth를 기록하면 벽 뒤에 있는 Transparent Fragment를 Depth Test로 제거할 수 있다.

Transparent는 이미 만들어진 Opaque Scene Color와 Blend한다.

이 순서를 반대로 하면 Opaque가 나중에 Transparent 결과를 완전히 덮어쓰거나, Transparent가 필요한 Destination Color를 얻지 못할 수 있다.

---

## Render Queue

Unity는 Material을 Render Queue로 분류하여 큰 렌더링 순서를 정할 수 있다.

대표적인 Queue는 다음과 같다.

| Queue | 기본 Index | 용도 |
|---|---:|---|
| Background | 1000 | 배경 요소 |
| Geometry | 2000 | 불투명 Geometry |
| AlphaTest | 2450 | Alpha Clipping Geometry |
| Transparent | 3000 | Alpha Blending Geometry |
| Overlay | 4000 | 위에 표시할 효과 |

이 값은 대표적인 Unity Queue 기준이며 Render Pipeline의 실제 Pass 구성과 Sorting 설정도 함께 확인해야 한다.

Shader에서는 Tag로 Queue를 지정할 수 있다.

```shaderlab
Tags { "Queue" = "Transparent" }
```

Material의 `renderQueue`로 값을 Override할 수도 있다.

```csharp
material.renderQueue = 3000;
```

Queue 숫자를 바꾸는 것은 단순한 투명도 설정이 아니라 다른 Renderer와의 실행 순서를 바꾸는 작업이다.

---

## Transparent는 왜 ZWrite Off일까?

반투명 표면이 Depth를 기록하면 뒤에 있는 다른 Transparent Fragment가 Depth Test에서 제거될 수 있다.

```text
앞 유리가 Depth 기록
↓
뒤 연기가 Z-Test 실패
↓
연기가 Blend되지 않음
```

그래서 일반적인 Transparent는 다음과 같은 상태를 사용한다.

```shaderlab
ZWrite Off
ZTest LEqual
Blend SrcAlpha OneMinusSrcAlpha
```

기존 Opaque Depth와는 비교하여 벽 뒤의 Transparent를 제거하지만 자신의 Depth는 남기지 않는다.

그 대신 Transparent끼리의 가시성은 Sorting 순서에 의존한다.

---

## Transparent Sorting의 한계

Unity가 Transparent Renderer를 Camera 거리 기준으로 정렬해도 완벽한 결과가 항상 나오지는 않는다.

Renderer 하나에는 여러 Triangle이 들어 있고 Sorting은 일반적으로 모든 Triangle을 전역 깊이순으로 나누어 처리하지 않는다.

```text
Mesh A 일부는 B보다 앞
Mesh A 일부는 B보다 뒤
```

두 투명 Mesh가 교차하면 오브젝트 단위로 어느 하나를 완전히 앞이나 뒤라고 정하기 어렵다.

하나의 긴 투명 Mesh도 Camera를 가로질러 깊이가 크게 달라질 수 있다.

이 경우 다음과 같은 방법을 상황에 따라 고려할 수 있다.

```text
Mesh 분리
Sorting Pivot 조정
Render Queue 또는 Priority 조정
Alpha Clipping 사용
Depth Prepass 활용
Order Independent Transparency 기법
```

각 방법에는 품질, 메모리, Draw Call과 Shader 비용의 Trade-off가 있다.

---

## Alpha Clipping

Alpha Clipping은 Alpha를 연속적으로 Blend하는 대신 Threshold를 기준으로 Fragment를 완전히 남기거나 제거한다.

```hlsl
clip(alpha - cutoff);
```

```text
Alpha >= Cutoff
완전히 보임

Alpha < Cutoff
완전히 제거
```

나뭇잎, 철망, 풀처럼 구멍은 필요하지만 중간 투명도가 필수적이지 않은 표면에 사용할 수 있다.

통과한 Fragment는 Opaque처럼 Depth를 기록할 수 있으므로 일반 Alpha Blend보다 Sorting 문제가 적다.

하지만 가장자리가 딱딱하거나 움직일 때 깜빡일 수 있고, `clip` 사용이 Early-Z 및 GPU 실행 효율에 영향을 줄 수 있다.

MSAA 환경에서는 Alpha-to-Coverage를 이용해 가장자리를 부드럽게 표현하는 방법도 있다.

---

## Alpha Clipping과 Blending의 차이

두 방식은 Alpha Channel을 사용할 수 있지만 결과와 Pipeline 동작이 다르다.

| 항목 | Alpha Clipping | Alpha Blending |
|---|---|---|
| 결과 | 보임 또는 제거 | 연속적인 반투명 |
| ZWrite | 사용할 수 있음 | 일반적으로 Off |
| Sorting | Opaque에 가까움 | 순서 의존성이 큼 |
| 가장자리 | Threshold에 따라 딱딱함 | 부드러운 투명도 가능 |
| Overdraw | Depth로 줄일 수 있음 | 겹친 Layer가 계속 처리될 수 있음 |

모든 투명 Material을 Alpha Blend로 만들 필요는 없다.

시각적으로 이진 Mask만 필요하면 Alpha Clipping이 더 적합할 수 있다.

반대로 유리와 연기처럼 뒤의 Color가 연속적으로 보여야 하면 Blending이 필요하다.

---

## Transparent Depth Prepass

일부 투명 오브젝트는 별도의 Pass에서 Depth를 먼저 기록하고 Color Pass에서 Blend하는 방식을 사용할 수 있다.

```text
Depth Pass
투명 Mesh의 Depth 기록
↓
Transparent Color Pass
Depth를 기준으로 Blend
```

자기 Mesh의 뒤쪽 면이나 다른 Geometry와의 일부 가림 문제를 줄일 수 있다.

하지만 뒤에서 보여야 할 Transparent Layer까지 제거할 수 있어 물리적으로 올바른 투명 결과와 다를 수 있다.

Pass가 추가되므로 Draw Call과 Vertex Processing도 늘어난다.

유리 Character, Hair, 특수 VFX처럼 원하는 시각 결과가 명확할 때 제한적으로 사용할 수 있는 방식이다.

---

## 양면 Transparent의 문제

유리 Sphere처럼 앞면과 뒷면이 모두 보이는 Transparent Mesh는 한 오브젝트 내부에서도 순서 문제가 발생한다.

일반 Mesh Triangle 순서로 그리면 앞면이 먼저 Blend되고 뒷면이 나중에 잘못 겹칠 수 있다.

```text
Camera
↓
Sphere 앞면
↓
Sphere 뒷면
```

일부 Shader는 Back Face를 먼저 렌더링하고 Front Face를 나중에 렌더링하는 두 Pass 방식을 사용한다.

```text
Pass 1: Back Face
Pass 2: Front Face
```

닫힌 단일 Mesh에서는 결과를 개선할 수 있지만 교차 Geometry와 여러 투명 오브젝트의 전체 Sorting 문제까지 해결하지는 못한다.

두 Pass로 인해 Rendering 비용도 증가한다.

---

## Alpha Channel도 Blend할 수 있다

Color RGB와 Output Alpha에 서로 다른 Blend Factor를 사용할 수 있다.

ShaderLab에서는 쉼표 뒤에 Alpha용 Factor를 별도로 지정할 수 있다.

```shaderlab
Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
```

앞의 두 Factor는 RGB에, 뒤의 두 Factor는 Alpha Channel에 적용된다.

Render Texture를 이후 합성에 사용한다면 Color뿐 아니라 결과 Alpha가 어떤 의미로 저장되는지도 중요하다.

최종 Display Back Buffer에서는 Alpha가 보이지 않더라도 중간 Render Target의 Alpha는 후속 Pass, UI 합성, Video 출력에서 사용될 수 있다.

---

## Color Space와 Blending

Color를 Blend하는 공간도 결과에 영향을 준다.

사람의 눈에 보이는 sRGB 값은 물리적인 빛의 세기와 선형 관계가 아니다.

일반적인 Linear Rendering Workflow에서는 Texture의 sRGB Color를 Linear 값으로 변환한 뒤 Lighting과 Blending을 수행하고, 최종 출력에서 다시 Display Color Space로 변환한다.

```text
sRGB Texture
↓ Linear 변환
Lighting / Blending
↓ Output 변환
Display
```

Gamma 값에서 단순히 Color를 평균하면 실제 빛의 혼합과 다른 어두운 결과가 나올 수 있다.

Render Target Format과 sRGB 설정, HDR 사용 여부에 따라 Pipeline이 처리하는 방식이 달라지므로 Custom Render Texture와 Blit에서는 Color Space를 확인해야 한다.

---

## Blending과 HDR

HDR Render Target은 1보다 큰 Color 값을 저장할 수 있다.

Additive Particle과 Emission을 여러 번 더하면 높은 밝기 값이 누적될 수 있다.

```text
Source 2.0
+ Destination 3.0
= 5.0
```

이 값은 Tone Mapping과 Bloom 같은 후처리를 거쳐 최종 Display 범위로 변환된다.

LDR Format에서는 표현 범위를 넘는 값이 Clamp되거나 Format에 맞게 제한될 수 있다.

같은 Additive Blend라도 Render Target Format과 Post Processing에 따라 시각 결과가 다를 수 있다.

---

## Blending은 어디에서 실행될까?

Fragment Shader는 Source Color를 계산한다.

그 후 GPU의 Output Merger 또는 Color Blend 단계가 Render Target의 Destination Color와 결합한다.

```text
Fragment Shader
Source RGBA 출력
↓
Depth / Stencil Test
↓
Blend State 적용
Source + Destination
↓
Color Buffer 기록
```

정확한 Early와 Late Test 순서는 Shader와 하드웨어에 따라 달라질 수 있다.

중요한 점은 Blend가 HLSL에서 Destination Color를 직접 읽어 수동 계산하는 것과 일반적으로 다르다는 것이다.

고정 기능 Blend Stage가 설정된 Factor와 Operation으로 결합한다.

---

## Blending과 성능

Blending을 활성화하면 Destination Color를 읽고 Source와 연산한 뒤 다시 기록해야 한다.

Render Target Read·Modify·Write와 관련된 대역폭과 Blend Unit 비용이 발생할 수 있다.

더 큰 문제는 일반적인 Transparent가 ZWrite를 하지 않아 같은 화면 위치의 많은 Layer가 Fragment Shader와 Blend를 반복할 수 있다는 점이다.

```text
연기 Particle 20장 겹침
↓
같은 Pixel에서 Fragment Shader와 Blend 반복
```

화면을 크게 덮는 Particle, UI, Fog Plane은 Overdraw와 Fill Rate 병목을 만들 수 있다.

모바일 GPU에서는 높은 해상도와 많은 Transparent Layer가 메모리 대역폭과 Tile 처리 비용에 큰 영향을 줄 수 있다.

---

## Transparent를 줄이면 항상 빨라질까?

Transparent Overdraw는 중요한 GPU 비용이지만 개수만 보고 판단할 수는 없다.

```text
작은 Particle 100개
화면의 적은 영역

큰 투명 Quad 5개
화면 전체를 반복해서 덮음
```

두 번째가 더 비쌀 수 있다.

확인해야 할 요소는 다음과 같다.

```text
화면에서 차지하는 면적
겹치는 Layer 수
Fragment Shader 복잡도
Texture Sampling 수
Render Target 해상도와 Format
Blend Mode
대상 GPU의 Fill Rate와 대역폭
```

Scene View의 Overdraw Mode, Unity Profiler, GPU Profiler와 Frame Debugger로 실제 Draw와 화면 Coverage를 확인해야 한다.

---

## 투명 효과 최적화 관점

Transparent 비용을 줄일 때는 시각 품질과 병목을 함께 고려한다.

```text
Particle 크기와 개수 조정
화면을 덮는 불필요한 투명 영역 축소
Texture Mesh 형태로 Empty Area 줄이기
가능하면 Alpha Clipping 사용
Shader와 Texture Sampling 단순화
낮은 해상도 Buffer에서 특정 효과 처리
겹치는 Layer와 수명 조정
```

하지만 Alpha Clipping으로 바꾸면 가장자리 품질과 Alias가 달라지고, Mesh를 세밀하게 만들면 Vertex 수가 늘 수 있다.

낮은 해상도 Buffer는 Upsampling Artifact를 만들 수 있다.

한 영역의 비용을 줄인 결과 다른 영역의 비용이나 품질 문제가 커질 수 있으므로 측정과 비교가 필요하다.

---

## Unity ShaderLab 예제

일반적인 Alpha Blend용 Render State를 단순화하면 다음과 같다.

```shaderlab
Shader "Example/AlphaBlend"
{
    Properties
    {
        _BaseMap("Base Map", 2D) = "white" {}
        _BaseColor("Base Color", Color) = (1, 1, 1, 1)
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "RenderPipeline" = "UniversalPipeline"
        }

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            ZTest LEqual

            HLSLPROGRAM
            // Vertex / Fragment Shader
            ENDHLSL
        }
    }
}
```

이 상태는 가장 기본적인 예시일 뿐이다.

실제 URP Shader에서는 Pipeline Tag, Pass Tag, SRP Batcher용 Material CBUFFER와 필요한 Include 및 Shader Entry가 올바르게 구성되어야 한다.

---

## Blend 문제를 확인하는 방법

투명 결과가 잘못 보이면 Alpha 값만 확인하지 말고 전체 Render State를 함께 확인해야 한다.

```text
Fragment Shader가 출력한 RGB와 Alpha
Straight 또는 Premultiplied Alpha 여부
Source / Destination Blend Factor
BlendOp
ZTest / ZWrite
Render Queue
Transparent Sorting
Texture Import의 Alpha와 Color
Color Space와 Render Target Format
```

Frame Debugger에서는 Transparent Draw의 실행 순서, Material, Shader Pass와 Render Target을 확인할 수 있다.

RenderDoc에서는 Draw 전후의 Color와 Blend State를 비교하여 Source가 Destination에 어떻게 합성되는지 분석할 수 있다.

검은 테두리가 보이면 Premultiply Convention과 Texture Edge RGB를 확인하고, 오브젝트가 갑자기 사라지면 ZWrite와 Sorting을 확인할 수 있다.

---

## 전체 흐름

Transparent Fragment가 화면에 기록되는 흐름을 단순화하면 다음과 같다.

```text
Opaque Geometry 렌더링
Color + Depth 기록
↓
Transparent Renderer Sorting
먼 것부터 가까운 순서
↓
Transparent Fragment Shader
Source RGBA 계산
↓
Z-Test
Opaque 뒤라면 제거 가능
↓
Blend Stage
Source와 Destination 결합
↓
Color Buffer 갱신
↓
일반적으로 ZWrite Off
```

여러 Transparent가 겹치면 앞 단계의 Output이 다음 Draw의 Destination이 된다.

그래서 Alpha Blending 결과는 렌더링 순서에 의존한다.

---

## 정리

Alpha는 RGBA Color의 네 번째 성분이며 그 자체가 자동으로 투명도를 적용하는 기능은 아니다.

Fragment Shader가 Alpha 값을 출력해도 Blending이 꺼져 있으면 RGB는 기존 Render Target Color를 그대로 덮을 수 있다.

Blending은 현재 Fragment Shader 출력인 Source와 Render Target에 저장된 Destination을 Blend Factor와 Blend Operation으로 결합하는 과정이다.

일반적인 Straight Alpha Blend는 `Source RGB × Source Alpha + Destination RGB × (1 - Source Alpha)` 식을 사용한다.

Premultiplied Alpha는 Source RGB에 Alpha가 미리 곱해져 있으므로 `Blend One OneMinusSrcAlpha`와 같은 상태를 사용한다.

Source 데이터와 Blend Convention이 일치하지 않으면 너무 어둡거나 밝은 결과와 가장자리 Artifact가 나타날 수 있다.

Additive Blend는 Source를 Destination에 더하여 불꽃과 빛 효과를 만들고 Multiply Blend는 Destination을 어둡게 하거나 색을 입힐 수 있다.

일반 Alpha Blending은 Source와 Destination의 순서를 바꾸면 결과가 달라지므로 Transparent Geometry는 보통 먼 곳부터 가까운 곳 순서로 렌더링한다.

Opaque는 먼저 Depth를 기록하고 Transparent는 그 Depth와 Z-Test하면서 자신의 Depth는 일반적으로 기록하지 않는다.

이 때문에 Transparent끼리의 가시성은 Sorting에 의존하고 교차 Mesh나 하나의 복잡한 Mesh에서는 완벽한 순서를 만들기 어렵다.

Alpha Clipping은 Threshold를 기준으로 Fragment를 완전히 남기거나 제거하므로 Depth를 기록할 수 있지만 연속적인 반투명 표현은 하지 못한다.

Transparent는 Destination Color Read·Modify·Write와 겹친 Layer의 Fragment Shader 실행 때문에 높은 Overdraw와 메모리 대역폭 비용을 만들 수 있다.

최적화에서는 Transparent 오브젝트 수만 세기보다 화면 Coverage, 겹침 수, Shader 비용, Render Target 해상도와 대상 GPU를 함께 측정해야 한다.

Alpha와 Blend의 흐름을 이해하면 다음 장에서 GPU Rendering Pipeline이 Vertex 입력부터 최종 Render Target 출력까지 이 상태들을 어느 단계에서 처리하는지 연결하기 쉬워진다.

