---
title: "[Unity 렌더링] 3-6. GPU는 어떤 순서로 픽셀을 결정할까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - Culling
  - DepthTest
  - Blending
permalink: /programming/unity-3-6-pixel-decision-order/
toc: true
toc_sticky: true
date: 2026-08-15
last_modified_at: 2026-08-15
---

하나의 Triangle이 화면에 제출되었다고 해서 그 Color가 곧바로 Render Target에 기록되지는 않는다.

GPU는 Triangle의 방향과 화면 영역을 확인하고, Rasterization으로 Fragment를 만든 뒤, 여러 Test와 Fragment Shader, Blending을 거쳐 기록할 값을 결정한다.

```text
Triangle
↓ Culling
Rasterization
↓ Coverage를 가진 Fragment
Depth / Stencil Test
↓
Fragment Shader
↓
Depth / Stencil Test
↓
Blending
↓
Render Target
```

위 흐름에 Depth와 Stencil이 두 번 표시된 이유는 실제 Pipeline에서 Test가 항상 Fragment Shader의 한쪽에만 고정되지 않기 때문이다.

GPU는 결과가 바뀌지 않는 범위에서 Test를 먼저 수행하여 불필요한 Fragment Shader 실행을 줄이거나, Shader 결과가 필요한 경우 나중에 Test할 수 있다.

따라서 Pixel을 결정하는 순서는 다음 두 관점으로 나누어 이해해야 한다.

```text
논리적 순서
어떤 조건과 연산이 최종 결과를 결정하는가

실제 실행 순서
GPU가 같은 결과를 더 효율적으로 만들기 위해 언제 수행하는가
```

---

## Pixel을 결정한다는 의미

Pixel을 결정한다는 말은 화면 위치마다 하나의 Fragment를 고르는 단순한 과정만을 뜻하지 않는다.

Render Target의 각 Sample에는 기존 Color, Depth와 Stencil 값이 저장되어 있을 수 있다.

새로운 Fragment가 도착하면 GPU는 이 값과 Pipeline State를 사용하여 다음 항목을 결정한다.

- Fragment가 처리 대상인지
- Fragment Shader를 실행할 필요가 있는지
- Color, Depth와 Stencil을 기록할지
- 기존 Color를 교체할지 결합할지
- 어떤 Channel을 실제로 갱신할지

```text
새 Fragment
  Source Depth
  Source Color 후보
  Coverage

기존 Render Target
  Destination Depth
  Destination Stencil
  Destination Color

Pipeline State
  Cull / ZTest / ZWrite / Stencil / Blend / ColorMask
```

최종 Pixel은 새 Fragment만의 결과가 아니라 기존 Buffer 값과 Render State가 함께 만든 결과다.

---

## 전체 흐름

일반적인 Triangle의 처리 흐름을 결과 중심으로 정리하면 다음과 같다.

```text
1. Vertex 처리와 Primitive 구성
2. Clipping
3. Face Culling
4. Rasterization과 Coverage 판정
5. Fragment 및 보간값 생성
6. Depth / Stencil Test
7. Fragment Shader 실행
8. Depth / Stencil Test와 값 갱신
9. Blending 또는 Logic Operation
10. Color Mask 적용과 Render Target 기록
```

이 목록은 개념을 설명하기 위한 논리적 흐름이다.

Graphics API와 GPU Architecture는 일부 단계를 합치거나 병렬로 수행할 수 있으며 Depth와 Stencil Test는 Fragment Shader 전후에 배치될 수 있다.

중요한 것은 각 단계가 무엇을 제거하고 무엇을 기록하는지다.

---

## 1. Draw Call과 Render State

GPU가 Pixel을 처리하기 전에 CPU는 Draw Call과 함께 사용할 Mesh, Material, Shader와 Render State를 지정한다.

Unity ShaderLab의 Pass에는 다음과 같은 State가 포함될 수 있다.

```shaderlab
Pass
{
    Cull Back
    ZTest LEqual
    ZWrite On
    Blend Off
    ColorMask RGBA

    Stencil
    {
        Ref 1
        Comp Always
        Pass Replace
    }
}
```

Shader Program이 Source Color를 계산한다면 Render State는 그 결과를 언제, 어떤 조건으로 Buffer에 반영할지 결정한다.

같은 Fragment Shader라도 `ZTest`, `ZWrite`, `Stencil`과 `Blend` 설정이 다르면 최종 화면은 달라진다.

```text
Shader Code
무슨 값을 계산하는가

Render State
계산한 값을 어떤 조건으로 기록하는가
```

---

## 2. Vertex 처리와 Primitive 구성

Vertex Shader는 Object의 Vertex Position을 Clip Space로 변환하고 Rasterizer에 전달할 값을 출력한다.

```text
Vertex Buffer
↓ Vertex Shader
Clip Space Vertex
↓ Primitive Assembly
Triangle
```

Index Buffer를 사용하는 경우 GPU는 Index를 따라 Vertex를 조합하여 Triangle을 구성한다.

이 시점에는 아직 화면 Pixel이나 Fragment가 만들어지지 않았다.

GPU가 처리하는 대상은 Position과 Attribute를 가진 Vertex 및 그 Vertex로 구성된 Primitive다.

---

## 3. Clipping

Triangle이 Camera의 View Volume을 완전히 벗어나면 화면에 기여할 수 없다.

GPU는 Clip Volume과 Primitive의 관계를 확인한다.

```text
View Volume 내부
→ 유지

View Volume 외부
→ 제거

경계와 교차
→ 잘라서 새로운 Primitive 구성
```

Clipping은 화면에 보이지 않는 영역이 Rasterization으로 넘어가는 것을 막는다.

Unity에서 CPU가 수행하는 Frustum Culling과 GPU Pipeline의 Clip 단계는 구분해야 한다.

CPU Culling은 Renderer 단위로 Draw Call 제출 자체를 줄일 수 있고, GPU Clipping은 제출된 Primitive가 Clip Volume을 벗어난 부분을 처리한다.

---

## 4. Face Culling

Face Culling은 Triangle이 Front Face인지 Back Face인지 판정하여 특정 방향의 Primitive를 제거한다.

닫힌 Mesh의 뒷면은 일반적으로 앞면에 가려지므로 기본적인 Material은 Back Face를 제거하는 경우가 많다.

```text
Triangle 방향 판정
↓
Front Face → 유지
Back Face  → Cull Back이면 제거
```

Unity ShaderLab에서는 `Cull` 명령으로 설정한다.

```shaderlab
Cull Back
Cull Front
Cull Off
```

| 설정 | 의미 |
| --- | --- |
| `Cull Back` | Back Face를 제거함 |
| `Cull Front` | Front Face를 제거함 |
| `Cull Off` | 양쪽 Face를 모두 Rasterization함 |

Culling에서 제거된 Triangle은 Rasterization되지 않으므로 Fragment도 만들지 않는다.

```text
Culled Triangle
→ Coverage 판정 없음
→ Fragment 없음
→ Fragment Shader 실행 없음
```

양면 Material에 `Cull Off`를 사용하면 필요한 화면을 만들 수 있지만 뒷면까지 Fragment를 생성할 가능성이 있으므로 실제 Coverage와 GPU 시간을 측정해야 한다.

---

## CPU Culling과 GPU Face Culling

Unity에서는 여러 Culling이 서로 다른 단계에서 일어난다.

```text
CPU
Frustum Culling / Occlusion Culling
↓ 통과한 Renderer의 Draw Call 제출
GPU
Primitive Clipping / Face Culling
↓
Rasterization
```

CPU Frustum Culling에서 Renderer가 제거되면 해당 Renderer의 Draw Call과 Vertex 처리 비용을 줄일 수 있다.

GPU Face Culling은 이미 제출되고 Vertex 처리된 Triangle의 방향을 기준으로 Rasterization을 막는다.

둘 다 보이지 않는 Geometry를 줄이지만 적용 단위와 절약하는 비용이 다르다.

---

## 5. Rasterization과 Coverage

Culling을 통과한 Primitive는 Rasterization으로 이동한다.

Rasterizer는 화면의 어떤 Sample을 Triangle이 덮는지 판정하고 Coverage Mask를 만든다.

```text
Projected Triangle
↓
Sample 위치와 교차 판정
↓
Coverage Mask
↓
Fragment
```

Fragment에는 보통 다음과 같은 정보가 연결된다.

- Screen Position
- Rasterizer가 계산한 Depth
- Sample Coverage
- 보간된 UV
- 보간된 Normal
- 보간된 Vertex Color

Rasterization은 Color를 확정하는 단계가 아니다.

어떤 Primitive가 어떤 Sample에 기여할 가능성이 있는지 후보를 만드는 단계다.

---

## 6. Scissor와 Sample Mask

Rasterization 이후의 Fragment Operations에는 화면 영역과 Sample을 추가로 제한하는 Test가 존재한다.

Scissor Test는 지정된 직사각형 밖의 Fragment를 제거한다.

```text
Viewport
+-------------------+
|   Scissor Rect    |
|   +-----------+   |
|   | 처리 영역 |   |
|   +-----------+   |
+-------------------+
```

MSAA를 사용하면 Sample Mask가 Pixel 내부의 어떤 Sample이 활성화되는지 제한할 수 있다.

이 단계에서 Coverage Mask의 모든 Bit가 제거되면 더 이상의 Fragment Operation과 Color 기록이 필요하지 않다.

Unity의 일반적인 Material 작성에서 직접 조절하는 빈도는 낮지만 GPU가 Pixel을 결정하는 과정은 Color와 Depth만으로 구성되지 않는다.

---

## 7. Stencil Test

Stencil Buffer는 각 Pixel 또는 Sample 위치에 작은 Integer 값을 저장한다.

Stencil Test는 저장된 Stencil 값과 Reference 값을 비교하여 Fragment를 통과시키거나 제거한다.

```text
Stencil Buffer 값 = 1
Reference 값      = 1
Compare           = Equal

1 == 1 → 통과
```

Unity ShaderLab에서는 다음처럼 설정할 수 있다.

```shaderlab
Stencil
{
    Ref 1
    Comp Equal
    Pass Keep
    Fail Keep
    ZFail Keep
}
```

Stencil Test는 Portal, Mask, Outline, Mirror와 제한된 화면 영역의 렌더링에 사용할 수 있다.

Stencil은 단순히 통과 여부만 결정하지 않는다.

Test 결과에 따라 Stencil 값을 유지하거나 교체하고 증가·감소시킬 수도 있다.

| 상황 | Stencil Operation |
| --- | --- |
| Stencil Test 실패 | `Fail` |
| Stencil 통과 후 Depth 실패 | `ZFail` |
| Stencil과 Depth 모두 통과 | `Pass` |

그래서 Stencil 값의 최종 결과는 Stencil Compare와 Depth Test 결과에 함께 영향을 받는다.

---

## 8. Depth Test

Depth Test는 새 Fragment의 Depth와 Depth Buffer에 저장된 값을 비교한다.

```text
Incoming Depth = 0.3
Stored Depth   = 0.7
ZTest LEqual

0.3 <= 0.7 → 통과
```

일반적인 Depth Convention에서는 Camera에 가까운 값이 Test를 통과하지만 Reversed-Z를 사용하는 환경에서는 값의 방향과 Compare Function이 달라질 수 있다.

Unity Shader에서는 `ZTest`로 비교 조건을 설정한다.

```shaderlab
ZTest LEqual
```

| 설정 | 통과 조건 |
| --- | --- |
| `Less` | Incoming 값이 Stored 값보다 작음 |
| `LEqual` | Incoming 값이 Stored 값보다 작거나 같음 |
| `Equal` | 두 값이 같음 |
| `Greater` | Incoming 값이 Stored 값보다 큼 |
| `GEqual` | Incoming 값이 Stored 값보다 크거나 같음 |
| `Always` | 항상 통과함 |
| `Never` | 항상 실패함 |

Depth Test의 의미는 현재 Projection과 Depth Convention, Clear 값에 맞춰 해석해야 한다.

`LEqual`이라는 이름만 보고 모든 Platform에서 작은 수가 반드시 Camera에 더 가깝다고 가정하면 안 된다.

---

## ZTest와 ZWrite는 다르다

`ZTest`는 기존 Depth와 비교할지를 결정하고 `ZWrite`는 통과한 Fragment의 Depth를 Buffer에 기록할지를 결정한다.

```shaderlab
ZTest LEqual
ZWrite On
```

```text
ZTest
이 Fragment가 현재 Depth 조건을 통과하는가?

ZWrite
통과한 Fragment의 Depth로 Buffer를 갱신하는가?
```

불투명 Object는 보통 Depth Test와 Depth Write를 모두 사용한다.

앞쪽 Surface가 Depth를 기록하면 나중에 처리되는 뒤쪽 Surface를 가릴 수 있다.

일반적인 투명 Object는 뒤의 Color와 결합해야 하고 정렬 문제가 있으므로 `ZWrite Off`를 사용하는 경우가 많다.

```shaderlab
ZTest LEqual
ZWrite Off
Blend SrcAlpha OneMinusSrcAlpha
```

투명 Material의 정확한 State는 사용하는 Render Pipeline과 표현하려는 효과에 따라 달라질 수 있다.

---

## Depth Test를 통과한 Fragment

두 Triangle이 같은 Pixel을 덮는 상황을 가정할 수 있다.

```text
Depth Buffer Clear = Far

Triangle A
Depth 0.6 → 통과 → Depth 0.6 기록

Triangle B
Depth 0.2 → 통과 → Depth 0.2 기록
```

반대 순서로 그려도 두 Triangle이 올바르게 Depth를 기록하고 같은 Compare 규칙을 사용한다면 가까운 Surface가 최종적으로 남는다.

```text
Triangle B
Depth 0.2 → 통과 → Depth 0.2 기록

Triangle A
Depth 0.6 → 실패 → Color 기록 안 함
```

최종 Color가 같더라도 두 번째 순서는 뒤쪽 Fragment를 일찍 제거할 가능성이 있어 Fragment Shader 실행 비용이 달라질 수 있다.

정확한 차이는 GPU와 Shader State를 Profiling해야 한다.

---

## 9. Fragment Shader

Fragment Shader는 Rasterization이 만든 보간값과 Texture, Material, Light Data를 이용하여 Source Color와 필요한 출력을 계산한다.

```hlsl
half4 frag(Varyings input) : SV_Target
{
    half4 albedo = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv);
    return albedo * _BaseColor;
}
```

```text
보간된 UV
Texture Sampling
Material Color
Lighting
↓
Source Color
```

Fragment Shader가 반환한 Color는 최종 Pixel Color가 아니다.

이 값은 Color Attachment로 들어가는 Source이며 이후 Coverage, Depth, Stencil, Blending과 Color Mask의 영향을 받는다.

Shader가 여러 Render Target에 출력하거나 Depth를 직접 출력하는 경우에는 Color와 Depth 결정 과정이 더 복잡해질 수 있다.

---

## Fragment Shader가 Fragment를 제거하는 경우

Alpha Cutout Material은 Texture의 Alpha 값에 따라 Fragment를 제거할 수 있다.

```hlsl
half4 color = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv);
clip(color.a - _Cutoff);
return color;
```

```text
Alpha >= Cutoff → 유지
Alpha <  Cutoff → 제거
```

`clip` 또는 `discard`는 Rasterization 이후에 Texture 값을 확인하여 Coverage를 변경한다.

Fragment가 제거되면 해당 Sample의 Color와 일반적인 Depth 기록이 이루어지지 않는다.

Shader 실행 전에는 Alpha Texture 결과를 알 수 없으므로 Depth Test를 언제 안전하게 확정할 수 있는지에도 영향을 줄 수 있다.

---

## Fragment Shader가 Depth를 출력하는 경우

일반적인 Fragment는 Rasterizer가 보간한 Depth를 사용한다.

특수한 Shader는 `SV_Depth`를 통해 Depth를 직접 출력할 수 있다.

```hlsl
struct FragmentOutput
{
    half4 color : SV_Target;
    float depth : SV_Depth;
};
```

Shader가 Depth 값을 바꾸면 최종 Depth Test에는 새 값이 필요하다.

따라서 Rasterizer가 계산한 Depth만으로 Shader 실행 전에 결과를 확정할 수 없는 상황이 생긴다.

필요한 시각 효과가 아니라면 직접 Depth 출력은 Early Test 가능성과 성능에 미치는 영향을 측정해야 한다.

---

## Depth와 Stencil Test는 언제 실행될까?

개념적으로는 Fragment Shader가 Color와 Depth 후보를 계산하고 Fragment Operations가 기록 여부를 결정한다고 설명할 수 있다.

하지만 일반적인 Shader는 Rasterizer Depth를 그대로 사용하므로 GPU가 Depth와 Stencil Test를 먼저 수행할 수 있다.

```text
Early Test가 가능한 경우

Fragment
↓ Depth / Stencil Test
실패 → Fragment Shader 생략 가능
통과 → Fragment Shader
```

Shader가 Depth를 바꾸거나 Fragment를 제거하고 Storage에 Side Effect를 기록하면 처리 조건이 달라질 수 있다.

```text
Late Test가 필요한 경우

Fragment
↓ Fragment Shader
새 Depth 또는 Coverage
↓ Depth / Stencil Test
기록 여부 결정
```

일부 Architecture와 Extension은 보수적인 Early Test와 정확한 Late Test를 함께 사용할 수도 있다.

Graphics Pipeline을 이해할 때는 Early와 Late라는 논리적 위치를 사용하되 Hardware가 명령을 직렬로 하나씩 실행한다고 해석하면 안 된다.

GPU는 많은 Fragment를 병렬로 처리하고 결과의 규칙을 지키는 범위에서 내부 실행을 최적화한다.

---

## 10. Depth와 Stencil 값 갱신

Fragment가 필요한 Test를 통과하면 Pipeline State에 따라 Depth와 Stencil Buffer를 갱신한다.

```text
Stencil Test 통과
Depth Test 통과
↓
Stencil Pass Operation
ZWrite On이면 Depth 기록
```

Color를 쓰지 않는 Pass도 Depth나 Stencil만 기록할 수 있다.

```shaderlab
ColorMask 0
ZWrite On
```

이런 Depth-only Pass는 이후 Color Pass에서 가려진 Fragment를 빠르게 제거할 수 있는 Depth 정보를 준비한다.

반대로 Shadow Volume이나 Mask Pass는 Stencil 값만 갱신할 수 있다.

Pixel 결정 과정에는 눈에 보이는 Color 외에도 다음 Draw가 사용할 보조 Buffer를 만드는 과정이 포함된다.

---

## 11. Blending

Fragment가 Color Attachment에 기록될 조건을 통과하면 Fragment Shader가 만든 Source Color와 Render Target에 있던 Destination Color를 결합할 수 있다.

```text
Source
현재 Fragment Shader 출력

Destination
Render Target에 저장된 기존 Color

↓ Blend State

Result
새 Render Target Color
```

일반적인 Alpha Blending은 다음과 같은 형태다.

```text
Result.rgb = Source.rgb × Source.a
           + Destination.rgb × (1 - Source.a)
```

Unity ShaderLab에서는 다음처럼 설정한다.

```shaderlab
Blend SrcAlpha OneMinusSrcAlpha
```

Blend가 꺼져 있으면 Source Color가 Destination Color를 교체하는 Copy 동작처럼 처리된다.

```shaderlab
Blend Off
```

```text
Blend Off
Result = Source
```

Blending은 Fragment마다 한 번이라는 표현보다 Fragment가 덮는 Color Sample마다 적용된다고 이해하는 편이 정확하다.

MSAA에서는 Fragment의 Coverage Mask에 포함된 각 Sample의 Destination Color와 결합된다.

---

## 불투명 Object의 결정 흐름

일반적인 불투명 Material은 다음과 같은 State를 사용한다.

```shaderlab
Cull Back
ZTest LEqual
ZWrite On
Blend Off
```

```text
Back Face Culling
↓
Rasterization
↓
Depth Test
↓ 통과
Fragment Shader
↓
Depth 기록
Color 교체
```

가까운 Surface가 Depth Buffer를 갱신하고 뒤쪽 Surface는 Depth Test에서 제거된다.

불투명 Object는 Color를 누적할 필요가 없으므로 일반적으로 Blend를 사용하지 않는다.

---

## 투명 Object의 결정 흐름

일반적인 Alpha Blend Material은 다음과 같은 State를 사용할 수 있다.

```shaderlab
Cull Back
ZTest LEqual
ZWrite Off
Blend SrcAlpha OneMinusSrcAlpha
```

```text
Rasterization
↓
Depth Test
↓ 통과
Fragment Shader
↓
기존 Color와 Blending
↓
결합된 Color 기록
```

Depth Test는 이미 존재하는 불투명 Surface 뒤의 투명 Fragment를 제거할 수 있다.

하지만 `ZWrite Off`이면 투명 Object끼리 Depth를 기록하여 서로 가리는 방식으로 순서를 해결하지 않는다.

Alpha Blending은 일반적으로 순서에 따라 결과가 달라지므로 Unity는 Transparent Queue의 Object를 Camera 거리 기준으로 정렬하려고 한다.

Renderer 단위 정렬과 Triangle 단위 정렬은 다르기 때문에 교차하는 투명 Mesh에서는 한계가 생길 수 있다.

---

## Alpha Cutout의 결정 흐름

Alpha Cutout은 반투명 Color를 누적하기보다 Fragment를 유지하거나 완전히 제거한다.

```shaderlab
Cull Back
ZTest LEqual
ZWrite On
Blend Off
```

```hlsl
half alpha = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv).a;
clip(alpha - _Cutoff);
```

```text
Rasterization
↓
Fragment Shader에서 Alpha 확인
↓
clip으로 Coverage 결정
↓
Depth와 Color 기록
```

나뭇잎이나 철망처럼 구멍이 있는 표면을 표현할 수 있으며 유지된 Fragment는 불투명 Surface처럼 Depth를 기록할 수 있다.

Fragment Shader에서 Texture를 읽어야 구멍을 알 수 있으므로 완전히 불투명한 Shader와 Early Depth 동작이 같다고 단정할 수 없다.

---

## Stencil Mask의 결정 흐름

두 Pass로 특정 영역에만 Color를 그리는 상황을 가정할 수 있다.

첫 번째 Pass는 Mask Geometry가 덮는 위치에 Stencil 값 `1`을 기록한다.

```shaderlab
Stencil
{
    Ref 1
    Comp Always
    Pass Replace
}
ColorMask 0
```

두 번째 Pass는 Stencil 값이 `1`인 위치에서만 Color를 그린다.

```shaderlab
Stencil
{
    Ref 1
    Comp Equal
    Pass Keep
}
```

```text
Mask Pass
Stencil = 1 기록
↓
Color Pass
Stencil == 1인 Fragment만 통과
↓
제한된 영역의 Pixel 갱신
```

Stencil Buffer는 기하학적 Mask 결과를 다음 Draw Call의 Pixel 결정 조건으로 전달한다.

---

## 12. Color Mask와 Render Target 기록

Blending 결과가 계산되어도 `ColorMask`에 따라 일부 Channel만 기록할 수 있다.

```shaderlab
ColorMask RGB
```

이 설정은 Red, Green, Blue를 기록하고 Alpha Channel은 유지한다.

```text
기존 Destination = (0.2, 0.3, 0.4, 0.5)
새 Result         = (1.0, 0.0, 0.0, 1.0)
ColorMask RGB

최종 저장         = (1.0, 0.0, 0.0, 0.5)
```

`ColorMask 0`은 Color Channel을 기록하지 않는다.

Depth Prepass와 Stencil Mask처럼 Color가 필요 없는 Pass에 사용할 수 있다.

최종적으로 허용된 Channel만 Color Attachment의 Sample에 기록된다.

---

## 최종 Pixel은 한 Draw Call에서 완성되지 않을 수 있다

한 Frame은 여러 Draw Call과 Render Pass가 같은 Render Target을 차례로 갱신하는 과정이다.

```text
Clear Color
↓ Sky
Opaque Geometry
↓ Transparent Geometry
Post-processing
↓ UI
최종 화면
```

각 Draw Call은 자신에게 설정된 Culling, Depth, Stencil, Fragment Shader와 Blend State를 사용한다.

한 Draw Call이 기록한 Destination Color는 다음 Draw Call의 Blending 입력이 될 수 있다.

Deferred Rendering에서는 Geometry Pass가 G-buffer를 만들고 Lighting Pass가 이 Buffer를 읽어 최종 Color를 계산한다.

최종 Display Pixel을 결정하는 과정은 전체 Frame Graph와 Pass 순서까지 포함한다.

---

## Draw Order가 중요한 경우

Depth Write가 활성화된 불투명 Object는 Draw Order가 달라도 Depth Test를 통해 가까운 Surface가 남을 수 있다.

하지만 실행 비용은 달라질 수 있다.

가까운 불투명 Object가 먼저 Depth를 기록하면 뒤쪽 Fragment의 Shading을 생략할 가능성이 커진다.

Blending은 Destination Color를 읽으므로 Draw Order가 최종 결과 자체를 바꾼다.

```text
A Blend 후 B Blend
≠
B Blend 후 A Blend
```

Stencil Operation도 이전 Draw가 기록한 Stencil 값을 다음 Draw가 읽기 때문에 Pass 순서가 중요하다.

```text
Depth
불투명 결과의 가시성 결정

Blend
투명 결과와 누적 순서 결정

Stencil
Pass 사이의 영역 Mask 결정
```

---

## 논리적 순서와 Hardware 실행 순서

Graphics API 명세는 결과를 설명할 수 있는 논리적 Pipeline 순서를 정의한다.

하지만 이 순서가 GPU 내부에서 각 Fragment마다 하나씩 직렬 실행된다는 뜻은 아니다.

```text
설명을 위한 순서
Culling → Rasterization → Test → Shading → Blend → Write

Hardware
여러 Primitive와 Fragment를 병렬 처리
일부 Test를 앞당김
일부 작업을 묶음
결과에 필요한 순서와 가시성은 보장
```

Fragment Shader Invocation 자체의 실행 완료 순서는 일반적으로 단순한 Draw 제출 순서로 가정할 수 없다.

Framebuffer의 같은 Sample에 대한 Fragment Operation과 Blend, Color Write는 Graphics API가 정의한 Rasterization Order 규칙을 따른다.

Shader가 임의의 Buffer나 Texture에 수행하는 Side Effect는 별도의 Synchronization과 Ordering 규칙을 확인해야 한다.

---

## Unity에서 순서를 확인하는 방법

### Frame Debugger

Unity Frame Debugger는 Draw Call과 Pass가 어떤 순서로 Render Target을 갱신하는지 확인하는 데 적합하다.

Event를 한 단계씩 이동하면 다음 항목을 확인할 수 있다.

- 어떤 Renderer와 Pass가 실행되었는지
- Render Queue와 Draw 순서
- 사용한 Render Target
- Depth, Stencil, Blend와 Cull State
- Draw 전후의 Color 변화

Frame Debugger는 논리적 Draw Event를 보여 주며 GPU 내부의 실제 Early Test Scheduling을 직접 보여 주지는 않는다.

### RenderDoc과 Platform Debugger

RenderDoc, PIX, Xcode GPU Frame Debugger 같은 도구에서는 Draw Call의 Pipeline State와 Attachment를 더 자세히 확인할 수 있다.

특정 Pixel의 History 기능이 지원되면 어떤 Draw가 그 위치를 갱신했고 Depth나 Stencil Test에서 실패했는지 추적할 수 있다.

도구와 Graphics API에 따라 지원 범위는 다르다.

### GPU Profiler

순서가 올바르다고 해서 효율적인 것은 아니다.

GPU Profiler와 Hardware Counter를 사용하여 Early Depth Reject, Fragment Invocation, Color Write와 Blend 관련 비용을 측정할 수 있다.

Counter의 이름과 의미는 GPU Vendor마다 다르므로 동일한 수치로 직접 비교하기보다 해당 도구의 정의를 확인해야 한다.

---

## 최적화와 처리 순서

Pixel 결정 과정에서 비용을 줄이는 방법은 제거 시점과 관련된다.

```text
일찍 제거
Culling에서 Triangle 제거
→ Rasterization과 Fragment 비용 감소

Depth에서 제거
가려진 Fragment 제거
→ Fragment Shader 비용 감소 가능

늦게 제거
Fragment Shader의 clip
→ Shader 앞부분의 계산은 이미 수행됨
```

다음 항목을 측정할 수 있다.

- Back Face가 필요하지 않은 Mesh에서 Culling이 꺼져 있는지
- 불투명 Object의 Overdraw가 큰지
- Alpha Cutout이 넓은 Quad 대부분을 제거하는지
- 투명 Particle이 같은 Pixel에 많이 겹치는지
- 불필요한 Pass가 Depth와 Color를 반복해서 기록하는지
- Blend가 필요하지 않은 Material에 활성화되어 있는지
- Depth Prepass가 비용보다 더 많은 Shading을 절약하는지

Depth Prepass는 Fragment Shader 부하를 줄일 수 있지만 Geometry 처리와 Depth Write Pass를 추가한다.

Tile-based GPU와 Immediate-mode GPU, Scene 구조와 Shader 복잡도에 따라 결과가 다르므로 항상 이득이라고 단정할 수 없다.

---

## 상태별 처리 결과

| 상태 | Fragment에 미치는 영향 | 주로 결정하는 값 |
| --- | --- | --- |
| Culling | Primitive 전체를 Rasterization 전에 제거 | Face 방향 |
| Scissor | 지정된 화면 영역 밖 Coverage 제거 | Screen Position |
| Stencil Test | Mask 조건으로 Sample 제거 | Stencil과 Reference |
| Depth Test | 가려진 Sample 제거 | Incoming과 Stored Depth |
| Fragment Shader | Source Color와 Material 결과 계산 | 보간값, Texture, Light |
| `clip` / `discard` | Shader 안에서 Fragment Coverage 제거 | Shader 조건 |
| ZWrite | 통과한 Depth를 Buffer에 기록 | Depth State |
| Stencil Operation | Test 결과에 따라 Stencil 갱신 | Fail, ZFail, Pass |
| Blending | Source와 Destination Color 결합 | Blend Factor와 Operation |
| ColorMask | 기록할 Color Channel 제한 | Channel Mask |

각 단계는 독립된 기능처럼 보이지만 앞 단계의 결과가 다음 단계의 입력을 결정한다.

---

## 자주 생기는 오해

### Fragment Shader가 최종 Pixel Color를 반환한다

Fragment Shader는 Source Color를 출력한다.

Depth와 Stencil Test에서 제거되거나 Blending과 Color Mask를 거쳐 다른 값으로 기록될 수 있다.

### Depth Test는 항상 Fragment Shader 뒤에서 실행된다

논리적으로 Shader가 만든 Depth와 Coverage가 필요한 경우 Late Test가 필요할 수 있다.

일반적인 Shader에서는 GPU가 Test를 먼저 수행하여 Shading을 생략할 수 있다.

### Culling은 보이지 않는 Object를 모두 제거한다

Face Culling은 Triangle 방향을 기준으로 Front 또는 Back Face를 제거한다.

다른 Object 뒤에 가려졌는지는 Depth Test나 Occlusion Culling이 처리하는 별도의 문제다.

### ZWrite Off이면 Depth Test도 꺼진다

Depth 기록과 Depth 비교는 별개의 State다.

투명 Material은 `ZWrite Off`이면서 `ZTest LEqual`을 사용하여 불투명 Surface 뒤의 Fragment를 제거할 수 있다.

### Blend를 켜면 투명 정렬 문제가 해결된다

일반적인 Alpha Blending은 순서에 의존한다.

올바른 Draw Order와 표현 방식이 함께 필요하다.

### GPU는 그림의 Pixel을 왼쪽 위부터 순서대로 만든다

GPU는 많은 Primitive와 Fragment를 병렬로 처리한다.

Pipeline의 순서는 결과와 의존성을 설명하는 규칙이지 화면 격자를 직렬로 순회한다는 의미가 아니다.

---

## 가장 단순한 판단 흐름

Single Sample 불투명 Fragment 하나의 결과를 단순화하면 다음과 같다.

```text
Triangle이 Cull되었는가?
├─ Yes → Fragment 없음
└─ No
   ↓
Pixel Sample을 덮는가?
├─ No → Fragment 없음
└─ Yes
   ↓
Stencil 조건을 통과하는가?
├─ No → Color 기록 없음
└─ Yes
   ↓
Depth 조건을 통과하는가?
├─ No → Color 기록 없음
└─ Yes
   ↓
Fragment Shader가 유지하는가?
├─ No → Color 기록 없음
└─ Yes
   ↓
Source Color 계산
   ↓
Blend State 적용
   ↓
ColorMask가 허용한 Channel 기록
```

실제 GPU는 같은 결과를 유지할 수 있다면 Depth와 Stencil Test를 Fragment Shader보다 먼저 또는 나중에 수행할 수 있다.

MSAA에서는 이 판단이 Coverage된 Sample 단위로 확장된다.

---

## 정리

GPU가 Pixel을 결정하는 과정은 Triangle의 Color를 그대로 복사하는 단일 연산이 아니다.

Draw Call과 함께 지정된 Shader와 Render State가 전체 판단 기준을 구성한다.

Clipping은 View Volume 밖의 Primitive를 제거하고 Face Culling은 방향이 맞지 않는 Triangle을 Rasterization 전에 제거한다.

Rasterizer는 남은 Primitive가 덮는 Sample을 판정하여 Coverage와 Fragment를 만든다.

Stencil Test는 저장된 Mask 값과 Reference를 비교하고 Depth Test는 새 Depth와 기존 Depth를 비교한다.

Fragment Shader는 Texture, Material과 Lighting을 이용해 Source Color를 계산하지만 그 출력이 곧 최종 Pixel은 아니다.

통과한 Fragment는 State에 따라 Depth와 Stencil을 갱신하고, Blending을 사용하면 Source Color와 기존 Destination Color를 결합한다.

Color Mask가 허용한 Channel이 최종적으로 Render Target에 기록된다.

```text
Primitive 제거
Culling
↓
후보 생성
Rasterization
↓
기록 조건 판단
Depth / Stencil
↓
값 계산
Fragment Shader
↓
기존 값과 결합
Blending
↓
Buffer 갱신
Color / Depth / Stencil Write
```

Depth와 Stencil Test는 항상 Fragment Shader의 한쪽에서만 실행되는 것이 아니다.

GPU는 Shader가 Depth와 Coverage를 변경하는지, Side Effect가 있는지와 Pipeline State를 고려하여 Early 또는 Late Fragment Test를 사용할 수 있다.

Graphics Pipeline의 순서는 결과를 설명하는 논리적 흐름이며 GPU가 Pixel을 하나씩 직렬로 처리한다는 의미가 아니다.

Pixel 처리 비용을 줄이려면 Culling, Overdraw, Depth Reject, Fragment Shader, Blending과 Pass 수 중 실제 병목이 어디에 있는지 측정해야 한다.
