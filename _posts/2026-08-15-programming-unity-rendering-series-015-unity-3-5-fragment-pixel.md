---
title: "[Unity 렌더링] 3-5. Fragment와 Pixel은 같은 것일까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - Fragment
  - Pixel
  - MSAA
permalink: /programming/unity-3-5-fragment-pixel/
toc: true
toc_sticky: true
date: 2026-08-15
last_modified_at: 2026-08-15
---

Fragment Shader는 흔히 Pixel의 색상을 계산하는 Shader라고 설명한다.

화면을 이해하는 첫 단계에서는 충분히 유용한 표현이지만 Fragment와 Pixel이 같은 대상을 뜻하는 것은 아니다.

```text
Pixel
Render Target을 이루는 격자의 한 위치

Fragment
Rasterization 과정에서 Primitive가 만든 렌더링 후보
```

하나의 Pixel 위치에 여러 Triangle이 겹치면 여러 Fragment가 만들어질 수 있다.

반대로 MSAA, Helper Invocation, Variable Rate Shading 같은 기능이 개입하면 Fragment, Sample, Fragment Shader Invocation의 수도 서로 달라질 수 있다.

최종 화면의 Pixel은 이 후보들이 Depth Test, Stencil Test, Blending과 Resolve를 거친 결과다.

```text
Primitive
↓ Rasterization
Fragment와 Coverage
↓ Fragment Shader와 Fragment Operations
Render Target의 Sample
↓ Resolve 또는 후처리
최종 Pixel
```

Fragment를 Pixel과 구분하면 Overdraw와 MSAA 비용을 더 정확히 해석할 수 있고, 화면 해상도만으로 Fragment Shader 부하를 판단하는 실수도 줄일 수 있다.

---

## Pixel이란?

Pixel은 **Picture Element**의 줄임말로, 2차원 Image를 구성하는 격자의 한 위치를 뜻한다.

GPU 렌더링에서는 주로 Color Render Target의 저장 위치를 가리킨다.

```text
Render Target

+---+---+---+---+
| P | P | P | P |
+---+---+---+---+
| P | P | P | P |
+---+---+---+---+
| P | P | P | P |
+---+---+---+---+
```

각 Pixel은 Format에 따라 Color 값을 저장한다.

예를 들어 `R8G8B8A8` Render Target이라면 Red, Green, Blue, Alpha Channel을 각각 8bit로 저장한다.

Pixel은 저장 위치에 관한 개념이다.

어떤 Triangle이 그 위치를 덮었는지, 몇 개의 Triangle이 경쟁했는지, 어떤 Fragment가 제거되었는지는 Pixel 자체만으로 설명하지 않는다.

---

## 화면 Pixel과 Render Target Pixel

Render Target의 Pixel이 항상 물리적인 Display Pixel과 일대일로 대응하는 것도 아니다.

Unity가 1920×1080 Render Target에 렌더링하고 같은 크기의 Display에 그대로 출력하면 두 격자가 거의 직접 대응하는 것처럼 보인다.

하지만 Dynamic Resolution이나 Upscaling을 사용하면 내부 Render Target과 최종 출력 해상도가 달라진다.

```text
낮은 해상도 Render Target
1280 × 720
↓ Upscale
Display 출력
1920 × 1080
```

이 경우 내부 렌더링 Pixel 하나가 최종 Display의 여러 Pixel에 영향을 줄 수 있다.

반대로 Supersampling에서는 더 높은 해상도로 렌더링한 여러 Pixel을 하나의 출력 Pixel로 축소한다.

따라서 Pixel이라는 말을 사용할 때도 Render Target Pixel인지 최종 Display Pixel인지 구분해야 한다.

---

## Fragment란?

Fragment는 Rasterizer가 Point, Line, Triangle 같은 Primitive를 화면의 Sample 위치와 비교하여 만든 **Framebuffer 갱신 후보**다.

Triangle이 특정 영역을 덮으면 Rasterizer는 Coverage를 계산하고, 그 위치에 대응하는 Fragment 데이터를 구성한다.

```text
Triangle
↓ Coverage 판정
Fragment
  - Screen Position
  - Depth
  - Coverage Mask
  - 보간된 UV
  - 보간된 Normal
  - 보간된 Color
```

Fragment는 아직 최종 Pixel이 아니다.

Fragment Shader가 Color를 계산한 뒤에도 Depth Test나 Stencil Test에서 제거될 수 있고, Blending을 통해 기존 Color와 합쳐질 수도 있다.

```text
Fragment 생성
↓
Fragment Shader
↓
Depth / Stencil Test
↓
Blending
↓
Render Target 기록
```

실제 Hardware와 Graphics API는 일부 Test를 Shader보다 먼저 실행할 수 있다.

중요한 점은 Fragment가 화면에 기록될 가능성을 가진 후보이며, 결과가 확정된 Pixel은 아니라는 것이다.

---

## 가장 단순한 경우

다음 조건에서는 Fragment와 Pixel의 관계가 단순해 보인다.

- Render Target이 Single Sample이다.
- Triangle이 서로 겹치지 않는다.
- Fragment가 Depth와 Stencil Test를 통과한다.
- Fragment Shader가 Fragment를 버리지 않는다.
- Blend가 꺼져 있다.
- 후처리와 해상도 변환이 없다.

```text
한 Pixel 위치
↓
한 Triangle이 덮음
↓
한 Fragment 생성
↓
한 Fragment Shader Invocation
↓
한 Pixel Color 기록
```

이 제한된 상황에서는 Fragment 하나가 Pixel 하나의 색상을 결정한다고 설명할 수 있다.

하지만 이것은 이해를 위한 단순화이며 항상 성립하는 항등관계는 아니다.

---

## 하나의 Pixel에 여러 Fragment가 생길 수 있다

카메라에서 같은 Pixel 위치를 향하는 방향에는 여러 Surface가 놓일 수 있다.

각 Surface의 Triangle은 서로 다른 Depth를 가진 Fragment를 만든다.

```text
Camera
  ↓
Triangle A  → Fragment A, Depth 0.2
  ↓
Triangle B  → Fragment B, Depth 0.6
  ↓
Pixel (x, y)
```

일반적인 Depth Test에서는 카메라에 가까운 Fragment A가 남고 Fragment B는 제거된다.

두 Fragment가 같은 Pixel 위치에 대응하더라도 최종 Pixel Color는 하나만 저장될 수 있다.

```text
Fragment A ─┐
            ├─ Depth Test → A만 기록
Fragment B ─┘
```

이처럼 같은 화면 위치에서 여러 Fragment가 경쟁하는 현상을 Overdraw와 연결해 해석할 수 있다.

---

## Overdraw

Overdraw는 같은 Pixel 또는 Sample 위치가 여러 번 Rasterization되고 Shading되거나 기록되는 현상이다.

화면 전체가 1920×1080이라고 해서 Fragment Shader가 약 207만 번만 실행된다고 단정할 수 없다.

겹치는 Object가 많다면 같은 위치에서 여러 Fragment 후보가 생성된다.

```text
화면 Pixel 수: 2,073,600

Layer 1: 배경
Layer 2: 지형
Layer 3: Character
Layer 4: Effect
Layer 5: UI

같은 Pixel 위치가 여러 Layer에서 반복 처리될 수 있음
```

불투명 Object는 적절한 Depth Test와 그리기 순서, GPU의 Early Depth 최적화로 가려진 Fragment의 Shader 실행을 줄일 수 있다.

그러나 Rasterization Cost와 Depth 처리까지 모두 사라진다는 의미는 아니다.

투명 Object는 뒤쪽 Color와 결합해야 하므로 겹친 Layer를 여러 번 Shading하고 Blending하는 경우가 많다.

---

## 투명 Fragment는 하나의 Pixel에 누적된다

Alpha Blending에서는 여러 Fragment 결과가 하나의 Destination Pixel에 순서대로 누적될 수 있다.

```text
Background Color
↓
Transparent Fragment A Blend
↓
Transparent Fragment B Blend
↓
최종 Pixel Color
```

일반적인 Alpha Blending은 다음과 같은 형태로 계산된다.

```text
Result = Source × SourceAlpha
       + Destination × (1 - SourceAlpha)
```

한 Pixel에 투명 Particle이 열 겹 겹쳤다면 하나의 Pixel을 만들기 위해 여러 Fragment Shader 실행과 Blend 연산이 발생할 수 있다.

화면에서 보이는 Pixel은 하나지만 그 Pixel을 만드는 과정은 하나가 아니다.

---

## Sample이란?

Sample은 Pixel 내부에서 Coverage, Depth, Stencil, Color를 평가하거나 저장하는 위치다.

Single Sample Render Target에서는 보통 Pixel마다 하나의 Sample이 있다.

```text
Single Sample Pixel

+---------+
|    ×    |  × = Sample
+---------+
```

이때 Pixel과 Sample의 수가 같아서 두 개념이 쉽게 섞인다.

Multisample Render Target에서는 Pixel 하나에 여러 Sample이 존재한다.

```text
4x MSAA Pixel

+---------+
| ×     × |
|         |
| ×     × |
+---------+
```

Rasterizer는 Triangle이 각 Sample을 덮는지 판정하고 Coverage Mask를 만든다.

```text
4개 Sample 중 2개를 덮음

Coverage Mask = 0011
```

Pixel은 격자의 위치이고 Sample은 그 Pixel 안에서 Coverage와 저장을 더 세밀하게 나타내는 단위다.

---

## MSAA에서 Fragment와 Pixel의 관계

MSAA는 Triangle Edge에서 Pixel 내부의 여러 Sample Coverage를 이용해 경계를 부드럽게 만든다.

Triangle 내부처럼 모든 Sample이 덮인 Pixel에서는 Coverage가 단순하다.

Edge Pixel에서는 일부 Sample만 Triangle 안에 들어간다.

```text
Triangle 내부 Pixel
Coverage: 1111

Triangle 경계 Pixel
Coverage: 0011

Triangle 외부 Pixel
Coverage: 0000
```

Fragment는 Coverage Mask를 통해 어떤 Sample에 영향을 줄 수 있는지 나타낸다.

4x MSAA라고 해서 Fragment Shader가 언제나 Pixel마다 네 번 실행되는 것은 아니다.

기본적인 Pixel Frequency Shading에서는 하나의 Fragment Shader 결과가 Fragment가 덮는 여러 Sample에 사용될 수 있다.

```text
한 Fragment
Coverage: 0011
↓ 한 번의 Shading이 가능
Color 결과 C
↓
덮인 Sample 0, 1에 C 적용
```

반면 Sample Shading이 활성화되어 Sample별 Input이나 결과가 필요하면 한 Fragment 영역에서도 여러 Fragment Shader Invocation이 실행될 수 있다.

```text
Fragment Coverage: 1111
↓ Sample Shading
Invocation 0 → Sample 0
Invocation 1 → Sample 1
Invocation 2 → Sample 2
Invocation 3 → Sample 3
```

정확한 Invocation 수는 Graphics API 설정, Shader가 사용하는 기능과 Hardware 구현에 영향을 받는다.

따라서 다음 식은 일반적으로 성립하지 않는다.

```text
4x MSAA = Fragment Shader가 항상 4배 실행
```

MSAA는 Sample Storage와 Depth, Stencil, Resolve 비용도 증가시키므로 Shader Invocation 수만으로 전체 비용을 설명할 수 없다.

---

## Resolve는 여러 Sample을 Pixel로 만든다

Multisample Color Target은 Pixel마다 여러 Sample Color를 보관할 수 있다.

최종적으로 Single Sample Image에 사용하려면 Resolve가 필요하다.

```text
Pixel의 Sample Color
C0, C1, C2, C3
↓ Resolve
한 Pixel Color
```

Triangle Edge에서는 일부 Sample에 Object Color가, 나머지 Sample에 Background Color가 남을 수 있다.

Resolve 결과는 이 Coverage 차이를 반영하여 부드러운 경계 Color가 된다.

최종 Pixel Color 하나만 보면 그 내부에서 여러 Sample이 처리되었다는 사실은 보이지 않는다.

---

## Fragment와 Fragment Shader Invocation

Fragment와 Fragment Shader Invocation도 완전히 같은 개념은 아니다.

Fragment는 Rasterization 결과로 만들어진 후보 데이터이고 Invocation은 Shader Program의 한 번의 실행을 뜻한다.

```text
Fragment
Rasterization과 Coverage의 결과

Fragment Shader Invocation
Fragment Shader Code의 실행 단위
```

단순한 Single Sample 상황에서는 한 Fragment에 한 Invocation이 대응하는 것처럼 보인다.

그러나 Sample Shading에서는 한 Fragment의 Sample을 나누어 여러 Invocation이 처리할 수 있다.

반대로 Coarse Fragment Shading에서는 하나의 Invocation이 더 넓은 영역의 결과를 공유할 수 있다.

최적화를 판단할 때 Fragment 수와 실제 Shader Invocation 수를 같은 값으로 가정하면 안 된다.

---

## Helper Invocation

GPU는 Fragment Shader를 작은 그룹으로 실행하여 인접 값의 차이를 계산한다.

Texture의 Mipmap Level을 선택하거나 `ddx`, `ddy` 같은 Screen Space Derivative를 계산하려면 주변 Invocation의 값이 필요하다.

Triangle 경계에서는 실행 그룹의 일부 위치가 Primitive Coverage 밖에 있을 수 있다.

```text
2 × 2 실행 그룹

+---+---+
| F | F |
+---+---+
| F | H |
+---+---+

F = 실제 Fragment를 처리하는 Invocation
H = Derivative 계산을 돕는 Helper Invocation
```

Helper Invocation은 이웃 Invocation의 Derivative 계산을 돕기 위해 Shader 명령을 실행할 수 있다.

하지만 Coverage된 Fragment처럼 Framebuffer에 Color, Depth와 Stencil 결과를 기록하지 않는다.

작고 가는 Triangle이 많으면 실제로 덮인 Sample에 비해 실행 그룹의 빈 영역이 늘어날 수 있다.

화면에 기록된 Pixel 수보다 Shader Core가 수행한 일이 많아질 수 있는 이유 중 하나다.

---

## Derivative와 작은 Triangle

Fragment Shader는 일반적으로 인접 Invocation을 묶어 처리한다.

큰 Triangle 내부에서는 실행 그룹 대부분이 유효한 Fragment를 담당할 가능성이 높다.

```text
큰 Triangle 내부

F F
F F
```

화면에서 매우 작은 Triangle은 그룹 일부만 덮을 수 있다.

```text
작은 Triangle 경계

F H
H H
```

Hardware와 실행 방식에 따라 세부 구조는 달라지지만 작은 Primitive가 Shader 실행 효율을 떨어뜨릴 수 있다는 방향은 같다.

Triangle 수만 줄이거나 Pixel 수만 줄이는 단일 지표보다 Primitive의 화면 크기와 Fragment Shader 비용을 함께 측정해야 한다.

---

## Early Depth Test와 Invocation 수

가려진 Fragment가 항상 Fragment Shader를 실행하는 것은 아니다.

GPU가 Fragment Shader보다 먼저 Depth Test를 수행할 수 있다면 뒤에 가려진 Fragment의 Invocation을 생략할 수 있다.

```text
Rasterized Fragment
↓ Early Depth Test 실패
Fragment Shader 실행 생략 가능
```

이 최적화는 Shader와 Pipeline State가 Early Test를 허용할 때 가능하다.

Fragment Shader가 Depth를 직접 변경하거나 `clip`, `discard`로 Coverage를 바꾸는 경우, Side Effect가 있는 경우에는 처리 순서와 최적화 가능성이 달라질 수 있다.

또한 Hardware가 실제로 어떤 방식으로 실행할지는 Graphics API의 보장과 GPU 구현에 따라 달라진다.

```text
Rasterization된 Fragment 수
≠ 반드시 실행된 Fragment Shader Invocation 수
≠ 반드시 기록된 Pixel 수
```

---

## Variable Rate Shading

Variable Rate Shading 또는 Fragment Shading Rate는 화면의 모든 위치를 같은 밀도로 Shading하지 않는 기능이다.

일반적인 1×1 Rate에서는 하나의 Shading 영역이 Pixel 하나에 대응한다.

2×2 같은 Coarse Rate에서는 하나의 Fragment Shader Invocation 결과를 여러 Pixel 영역에서 공유할 수 있다.

```text
1 × 1 Shading Rate

+---+---+
| A | B |
+---+---+
| C | D |
+---+---+

2 × 2 Shading Rate

+-------+
|   A   |
|       |
+-------+
```

두 경우 모두 Rasterization Coverage와 Depth, Stencil 처리는 별도로 고려해야 한다.

Coarse Shading은 화면의 Pixel 수가 그대로여도 Fragment Shader Invocation 수를 줄일 수 있다.

따라서 고정된 해상도에서도 Pixel 수와 Invocation 수가 일치하지 않을 수 있다.

Unity에서 이 기능을 사용할 수 있는 범위와 방식은 Render Pipeline, Graphics API, Platform과 GPU 지원에 따라 달라진다.

---

## Pixel과 Texel은 다르다

Pixel과 함께 자주 섞이는 용어가 Texel이다.

Texel은 Texture Element로, Texture를 구성하는 저장 단위다.

```text
Texel
Texture 안의 한 요소

Pixel
Render Target 또는 화면 Image 안의 한 요소
```

Fragment Shader가 한 Pixel 후보를 처리하면서 반드시 Texel 하나만 읽는 것도 아니다.

Bilinear Filtering은 주변 여러 Texel을 이용하며 Trilinear Filtering은 인접한 두 Mip Level의 Sample 결과를 결합한다.

```text
한 Fragment Shader Invocation
↓ Texture Sampling
여러 Texel이 Filtering에 참여 가능
↓
한 Sampled Color
```

Pixel 수, Fragment 수, Texture Sample 명령 수와 실제 Texel Fetch 수는 서로 다른 지표다.

---

## 여러 Render Pass에서 같은 위치가 반복 처리된다

한 Frame은 하나의 Color Render Target만 만드는 과정이 아니다.

Shadow Map, Depth Prepass, G-buffer, Opaque Color, Transparent, Post-processing과 UI Pass가 순서대로 실행될 수 있다.

```text
Shadow Pass
↓
Depth Prepass
↓
Opaque Pass
↓
Transparent Pass
↓
Post-processing
↓
UI
↓
최종 화면
```

각 Pass는 서로 다른 Render Target의 Pixel과 Fragment를 처리한다.

최종 화면의 Pixel 하나를 만들기까지 여러 Intermediate Texture의 같은 좌표가 반복해서 읽히고 쓰일 수 있다.

최종 해상도만으로 Frame 전체의 Fragment 처리량과 Bandwidth를 계산하기 어려운 이유다.

---

## Unity Shader에서 보이는 위치

Unity HLSL에서 Fragment Shader는 `SV_POSITION`을 통해 현재 Fragment의 화면 위치와 관련된 값을 받을 수 있다.

```hlsl
struct Varyings
{
    float4 positionCS : SV_POSITION;
    float2 uv         : TEXCOORD0;
};

half4 frag(Varyings input) : SV_Target
{
    float2 pixelPosition = input.positionCS.xy;
    return half4(frac(pixelPosition.x * 0.1), 0.0, 0.0, 1.0);
}
```

`input.positionCS.xy`는 Fragment Stage에서 Window 또는 Pixel 위치에 대응하는 값으로 사용된다.

하지만 이 값이 전달되었다고 해서 Invocation과 최종 Display Pixel이 항상 일대일이라는 의미는 아니다.

Dynamic Resolution, XR Viewport, Render Target Scale과 Graphics API별 좌표 Convention을 고려해야 한다.

Unity가 제공하는 Screen Space Helper와 Render Pipeline의 Shader Library를 사용하는 편이 플랫폼 차이를 줄이는 데 유리하다.

---

## `SV_SampleIndex`와 Sample Frequency

Multisample 환경에서는 Shader가 현재 처리하는 Sample Index를 입력받는 기능을 사용할 수 있다.

개념적으로 다음과 같은 형태다.

```hlsl
half4 frag(Varyings input, uint sampleIndex : SV_SampleIndex) : SV_Target
{
    return sampleIndex == 0
        ? half4(1.0, 0.0, 0.0, 1.0)
        : half4(0.0, 0.0, 1.0, 1.0);
}
```

Sample별 값을 요구하면 Pixel Frequency보다 더 많은 Invocation이 필요할 수 있다.

실제 지원 여부와 사용 방법은 Unity Version, Shader Target과 Graphics API를 확인해야 한다.

특별한 Sample 단위 효과가 필요하지 않다면 비용과 호환성을 측정한 뒤 도입하는 편이 안전하다.

---

## Fragment가 Pixel에 남지 않는 경우

Fragment가 생성되어도 다음 이유로 최종 Color에 남지 않을 수 있다.

| 원인 | 결과 |
| --- | --- |
| Depth Test 실패 | 더 가까운 Surface에 가려짐 |
| Stencil Test 실패 | Stencil 조건에 의해 기록되지 않음 |
| `clip` 또는 `discard` | Shader가 Fragment를 제거함 |
| Color Mask | 일부 또는 전체 Color Channel을 쓰지 않음 |
| Blend 결과 | 기존 Destination과 결합되어 독립 Color가 남지 않음 |
| 후속 Pass | Post-processing이나 UI가 결과를 다시 변경함 |
| Resolve / Upscale | 여러 Sample 또는 Pixel이 새 출력으로 재구성됨 |

최종 화면의 Color만으로 해당 위치에서 몇 개의 Fragment가 처리되었는지 알 수 없다.

---

## Pixel 수만으로 성능을 예측할 수 없는 이유

해상도는 Fragment 관련 비용을 추정하는 중요한 기준이다.

1920×1080에서 3840×2160으로 증가하면 Pixel 수는 네 배가 된다.

```text
1920 × 1080 = 2,073,600 Pixel
3840 × 2160 = 8,294,400 Pixel
```

하지만 실제 GPU Cost는 다음 요소의 영향을 함께 받는다.

- 화면을 덮는 Primitive의 Coverage
- Opaque와 Transparent Overdraw
- Early Depth Test의 효율
- MSAA Sample 수와 Sample Shading 여부
- Fragment Shader의 Texture Sampling과 연산량
- 작은 Triangle과 Helper Invocation
- Render Pass 수
- Render Target Format과 Memory Bandwidth
- Dynamic Resolution과 Upscaling
- Variable Rate Shading

같은 해상도에서도 단순한 Sky 화면과 여러 겹의 투명 Particle 화면은 Fragment 비용이 크게 다를 수 있다.

---

## Unity에서 확인하는 방법

Fragment와 Pixel의 관계는 하나의 숫자보다 여러 도구의 결과를 함께 보는 편이 정확하다.

### Frame Debugger

Unity Frame Debugger는 Draw Call이 어떤 순서로 Render Target을 바꾸는지 확인하는 데 유용하다.

같은 화면 위치가 Opaque, Transparent와 Post-processing Pass에서 반복해서 변경되는 흐름을 볼 수 있다.

Frame Debugger는 GPU의 정확한 Fragment Shader Invocation 수를 직접 보여 주는 도구는 아니다.

### Scene View Overdraw

Overdraw Visualization은 같은 위치에 Surface가 얼마나 겹치는지 파악하는 출발점이 된다.

특히 Particle, 투명 UI와 겹친 Quad가 많은 영역을 찾는 데 유용하다.

표시 방식이 실제 GPU Cost와 정확히 같은 것은 아니므로 Profiling 결과와 함께 해석해야 한다.

### GPU Profiler

Unity Profiler의 GPU Module이나 플랫폼 GPU Profiler로 Pass별 실행 시간을 측정할 수 있다.

해상도, MSAA, Particle 수와 Shader Variant를 바꿨을 때 GPU 시간이 어떻게 변하는지 비교하면 병목의 성격을 좁힐 수 있다.

### Graphics Debugger

RenderDoc, PIX, Xcode GPU Frame Debugger 같은 도구는 Draw Event, Attachment, Sample Count, Depth와 Blend State를 확인하는 데 도움이 된다.

지원되는 Hardware Counter가 있다면 Fragment Invocation, Early-Z Reject와 Overdraw에 가까운 지표를 추가로 확인할 수 있다.

Counter의 이름과 정의는 GPU Vendor마다 다르므로 수치의 의미를 먼저 확인해야 한다.

---

## 최적화할 때 구분해야 하는 질문

Fragment Cost를 줄이기 전에 어떤 수가 증가했는지 구분해야 한다.

```text
Render Target Pixel이 많은가?
→ Resolution과 Render Scale 확인

같은 위치에 Fragment가 많이 겹치는가?
→ Overdraw와 Draw Order 확인

Pixel마다 Sample이 많은가?
→ MSAA와 Sample Shading 확인

Invocation 하나가 비싼가?
→ Texture Sampling, Lighting, Branch 확인

Pass가 같은 화면을 여러 번 처리하는가?
→ Render Pipeline과 Post-processing 확인
```

해상도를 낮추면 Pixel 기반 부하는 줄지만 CPU Draw Call 병목이나 Vertex 병목은 크게 변하지 않을 수 있다.

Overdraw를 줄여도 매우 무거운 Fullscreen Post-processing이 주요 병목이라면 Frame Time 개선이 제한적일 수 있다.

MSAA를 끄면 Sample Storage와 Resolve 비용이 줄 수 있지만 Edge Quality와 다른 Anti-Aliasing 방식의 비용을 함께 비교해야 한다.

최적화는 Pixel, Fragment, Sample과 Invocation을 구분하고 실제 병목을 측정한 뒤 적용해야 한다.

---

## 자주 생기는 오해

### Fragment는 잘린 Pixel 조각이다

Fragment라는 이름 때문에 Pixel의 일부 조각으로 이해하기 쉽다.

Fragment는 Primitive가 Framebuffer에 기여하기 위해 만든 후보 데이터에 가깝다.

MSAA Coverage를 통해 Pixel 내부 일부 Sample만 덮을 수 있지만 단순히 Pixel을 기하학적으로 잘라 저장한 조각은 아니다.

### Fragment Shader는 Pixel마다 정확히 한 번 실행된다

Overdraw, Sample Shading, Helper Invocation과 Coarse Shading 때문에 일반적으로 성립하지 않는다.

### 4x MSAA는 Fragment Shader 비용을 무조건 네 배로 만든다

기본 MSAA는 여러 Sample의 Coverage와 Storage를 사용하면서 Shading 결과를 공유할 수 있다.

Sample Shading이나 Shader 특성, Bandwidth와 Resolve 비용에 따라 실제 변화가 달라진다.

### 보이지 않는 Fragment는 비용이 없다

Early Depth Test로 Shader 실행이 생략될 수 있지만 Rasterization과 Depth 처리 비용이 모두 0이라고 단정할 수 없다.

투명 Object나 Early Test를 제한하는 Shader에서는 가려진 영역도 Shading될 수 있다.

### 화면 Pixel 수가 곧 GPU 작업량이다

한 Frame의 Pass 수, Overdraw, MSAA, Shader 복잡도와 Memory Traffic을 포함하지 않은 값이다.

Pixel 수는 중요한 기준이지만 전체 작업량 그 자체는 아니다.

---

## 관계 정리

| 용어 | 의미 | 다른 수가 될 수 있는 이유 |
| --- | --- | --- |
| Display Pixel | 물리적 출력 화면의 한 위치 | Upscaling, Dynamic Resolution |
| Render Target Pixel | GPU Image의 한 격자 위치 | 여러 Pass와 서로 다른 해상도 |
| Sample | Pixel 내부의 Coverage·Depth·Color 평가 위치 | MSAA |
| Fragment | Primitive가 만든 Framebuffer 갱신 후보 | Overdraw, Coverage |
| Fragment Shader Invocation | Fragment Shader의 실행 단위 | Sample Shading, Helper, Shading Rate |
| Texel | Texture의 한 저장 요소 | Filtering과 Mipmapping |

가장 단순한 조건에서는 이 중 일부가 일대일로 대응하는 것처럼 보인다.

Graphics Pipeline은 품질과 성능을 조절하기 위해 이 관계를 분리해서 다룬다.

---

## 정리

Pixel은 Render Target 또는 화면 Image를 구성하는 격자의 한 위치다.

Fragment는 Rasterization 과정에서 Primitive가 만든 Framebuffer 갱신 후보이며 최종 Pixel이 아니다.

한 Pixel 위치에는 여러 Object와 투명 Layer가 만든 여러 Fragment가 존재할 수 있다.

Depth, Stencil, `clip`, Blending과 후속 Pass를 거치면서 일부 Fragment는 사라지고 일부 결과는 서로 결합된다.

Sample은 Pixel 내부에서 Coverage와 Depth, Color를 평가하는 위치다.

MSAA에서는 Pixel 하나에 여러 Sample이 있지만 Fragment Shader가 항상 Sample 수만큼 실행되는 것은 아니다.

Fragment Shader Invocation은 Shader의 실행 단위이며 Fragment, Sample과 Pixel 수에 항상 일대일로 대응하지 않는다.

Sample Shading은 한 Fragment에서 여러 Invocation을 만들 수 있고, Helper Invocation은 실제 Pixel 기록 없이 Shader 계산에 참여할 수 있다.

Variable Rate Shading은 하나의 Invocation 결과를 여러 Pixel 영역에서 공유할 수 있다.

화면 해상도는 Fragment 부하의 중요한 기준이지만 Overdraw, MSAA, 작은 Triangle, Pass 수, Shader 복잡도와 Bandwidth를 함께 측정해야 한다.

```text
Pixel = 저장 위치
Sample = Pixel 내부의 평가 위치
Fragment = Primitive가 만든 후보
Invocation = Shader의 실행
Texel = Texture의 저장 요소
```

이 구분이 Fragment Shader 비용과 Rasterization 결과를 정확히 해석하는 기준이 된다.
