---
title: "[Unity 렌더링] 3-7. Early-Z는 무엇일까?"
excerpt: "Unity Rendering"
categories:
  - Programming
tags:
  - Unity
  - Rendering
  - EarlyZ
  - DepthTest
  - Overdraw
permalink: /programming/unity-3-7-early-z/
toc: true
toc_sticky: true
date: 2026-08-15
last_modified_at: 2026-08-15
---

여러 Object가 같은 화면 위치에 겹치면 Rasterizer는 각 Surface에 대응하는 Fragment를 만든다.

가까운 Surface에 완전히 가려진 Fragment는 최종 Color에 기여하지 않는다.

```text
Camera
↓
가까운 Triangle A
↓
먼 Triangle B
↓
같은 Pixel 위치
```

먼 Triangle B의 Fragment Shader가 복잡한 Lighting과 여러 Texture Sampling을 모두 수행한 뒤 Depth Test에서 제거된다면 계산 결과가 사용되지 않는다.

Early-Z는 이런 Fragment의 Depth 또는 Stencil Test를 Fragment Shader보다 먼저 수행하여 불필요한 Shader 실행을 줄일 수 있는 GPU 최적화다.

```text
Late Depth Test
Fragment Shader 실행
↓
Depth Test 실패
↓
결과 폐기

Early Depth Test
Depth Test 실패
↓
Fragment Shader 실행 생략 가능
```

Early-Z는 화면의 결과를 바꾸는 새로운 렌더링 기능이 아니다.

같은 Depth Test 결과를 더 이른 시점에 판단하여 GPU 작업량을 줄이는 실행 최적화다.

---

## Z는 무엇을 뜻할까?

Early-Z의 `Z`는 화면의 Depth를 나타내는 관습적인 이름이다.

3D 좌표에서 Camera 방향과 관련된 축을 Z로 표현하고 Depth Buffer를 Z-buffer라고 부르면서 사용된 용어다.

```text
Early-Z
= Early Depth Test
= Fragment Shader 전에 수행하는 Depth 관련 판정
```

실제 Depth Buffer에 저장되는 값은 단순한 World Space Z가 아니다.

Projection과 Viewport 변환을 거친 Depth 값이며 Platform과 Render Pipeline에 따라 Reversed-Z를 사용할 수도 있다.

Early-Z의 핵심은 작은 값과 큰 값 중 어느 쪽이 가까운지가 아니라 현재 `ZTest` 조건을 Shader 실행 전에 안전하게 판단할 수 있는지다.

---

## 일반적인 Fragment 처리

Fragment가 Color Buffer에 기록되는 흐름을 단순화하면 다음과 같다.

```text
Rasterization
↓
Fragment 생성
↓
Fragment Shader
↓
Depth / Stencil Test
↓
Blending
↓
Color, Depth, Stencil 기록
```

이 순서에서는 모든 Rasterized Fragment가 Fragment Shader를 실행한 뒤 Depth Test 결과를 확인하는 것처럼 보인다.

하지만 Fragment Shader가 Rasterizer의 Depth를 바꾸지 않고 외부 Memory에 Side Effect를 만들지 않는다면 가려진 Fragment를 먼저 제거해도 최종 결과가 같다.

GPU는 이 조건을 이용하여 Test를 앞당길 수 있다.

---

## Early-Z의 처리 흐름

Early-Z가 적용될 수 있는 흐름은 다음과 같다.

```text
Rasterization
↓
Fragment의 Rasterized Depth
↓
Early Depth / Stencil Test
├─ 실패 → Fragment Shader 생략 가능
└─ 통과 → Fragment Shader 실행
           ↓
           Color와 필요한 값 기록
```

Depth Test에서 실패한 Fragment는 화면에 Color를 기록할 수 없다.

Shader의 다른 관찰 가능한 결과도 없다면 Shader를 실행하지 않아도 Frame 결과가 달라지지 않는다.

이때 절약되는 비용은 Fragment Shader가 수행했을 연산이다.

- Texture Sampling
- Normal Map 처리
- Lighting 계산
- Branch와 Material 연산
- Color 출력 계산

Rasterization과 Depth 비교까지 사라지는 것은 아니다.

Early-Z는 Fragment를 만들기 전의 Culling이 아니라 만들어진 Fragment를 Shading 전에 거르는 최적화다.

---

## Early-Z와 Early Fragment Tests

Early-Z라는 이름은 주로 Depth Test를 강조한다.

Graphics API에서는 Fragment Shader 전에 수행하는 Depth와 Stencil Test를 함께 Early Fragment Tests로 구분하기도 한다.

```text
Early Fragment Tests
├─ Depth Test
└─ Stencil Test
```

Stencil Test만으로 Fragment가 제거되어도 Shader 실행을 줄일 수 있다.

따라서 실제 Pipeline 분석에서는 Early Depth뿐 아니라 Early Stencil과 Coverage 관련 Operation을 함께 확인해야 한다.

---

## Early-Z가 결과를 바꾸면 안 되는 이유

다음과 같은 단순한 Fragment Shader를 가정할 수 있다.

```hlsl
half4 frag(Varyings input) : SV_Target
{
    return SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv);
}
```

Shader는 Color만 반환하고 Depth는 Rasterizer가 만든 값을 그대로 사용한다.

Depth Test에서 실패하면 이 Color는 어느 경우에도 Render Target에 기록되지 않는다.

```text
Shader 후 Test
Texture Sampling → Color 계산 → Depth 실패 → 폐기

Test 후 Shader
Depth 실패 → Shader 생략

최종 Color는 같음
```

이처럼 관찰 가능한 결과가 같을 때 GPU는 Test를 앞당길 수 있다.

Shader가 Depth나 Coverage를 바꾸거나 Color 이외의 Memory에 값을 기록하면 같은 변환이 항상 안전하지 않다.

---

## Overdraw와 Early-Z

Overdraw는 같은 Pixel 또는 Sample 위치가 여러 Surface에 의해 반복해서 처리되는 현상이다.

불투명 Object가 세 겹 겹친 상황을 가정할 수 있다.

```text
Pixel (x, y)

Surface A: 가까움
Surface B: 중간
Surface C: 멂
```

가까운 Surface A의 Depth가 먼저 기록되어 있다면 B와 C는 Early Depth Test에서 실패할 수 있다.

```text
A → Depth 통과 → Shader 실행 → Depth 기록
B → Early Depth 실패 → Shader 생략 가능
C → Early Depth 실패 → Shader 생략 가능
```

화면 결과에는 A만 보이지만 Early-Z가 없으면 B와 C의 Fragment Shader도 실행된 뒤 제거될 수 있다.

Fragment Shader가 비쌀수록 가려진 Invocation을 줄이는 효과가 커질 가능성이 있다.

---

## Front-to-Back 순서

불투명 Geometry를 Camera에 가까운 순서부터 그리면 Depth Buffer가 가까운 값으로 먼저 채워질 수 있다.

```text
Front-to-Back

가까운 Surface
↓ Depth 기록
중간 Surface
↓ Early Depth 실패 가능
먼 Surface
↓ Early Depth 실패 가능
```

반대로 먼 Surface부터 그리면 각 Surface가 이전 Depth보다 가까워 계속 통과할 수 있다.

```text
Back-to-Front

먼 Surface    → 통과, Shader 실행
중간 Surface  → 통과, Shader 실행
가까운 Surface → 통과, Shader 실행
```

두 순서 모두 일반적인 불투명 Depth Test에서는 최종 화면이 같을 수 있다.

하지만 실행한 Fragment Shader Invocation 수는 달라질 수 있다.

Unity의 불투명 Render Queue는 Early-Z에 유리한 순서를 고려할 수 있지만 CPU 정렬 비용, Material State 변경과 GPU Architecture까지 함께 고려한다.

무조건 완벽한 Object 단위 Front-to-Back 정렬이 가장 빠르다고 단정할 수 없다.

---

## Object 정렬의 한계

Renderer를 Camera 거리순으로 정렬해도 Triangle 단위의 완벽한 Front-to-Back 순서가 되는 것은 아니다.

```text
Renderer A의 Bounds Center는 가까움
하지만 일부 Triangle은 Renderer B 뒤에 있음
```

큰 Mesh가 서로 교차하거나 Camera가 Mesh 안에 있으면 Object 중심 기반 정렬만으로 이상적인 Depth 순서를 만들 수 없다.

또한 하나의 Draw Call 내부 Triangle 순서는 Mesh Index Buffer에 의해 정해진다.

Early-Z 효율은 Render Queue 정렬뿐 아니라 Scene 구조, Mesh 배치와 Camera 위치에 영향을 받는다.

---

## Hierarchical Z

GPU는 Sample마다 Depth를 하나씩 비교하는 것 외에 여러 Pixel 영역의 Depth를 계층적으로 요약할 수 있다.

이 구조는 일반적으로 Hierarchical Z, Hi-Z 또는 Hierarchical Depth라고 부른다.

```text
Depth Buffer
개별 Sample Depth
↓ 영역별 요약
작은 Tile Depth
↓ 더 큰 영역별 요약
상위 Hierarchy
```

새 Triangle 또는 Fragment Block이 이미 기록된 Geometry 뒤에 완전히 가려졌다고 판단할 수 있으면 더 큰 단위로 작업을 제거할 가능성이 생긴다.

```text
Tile 전체가 가까운 Depth로 가려짐
↓
Tile 안의 여러 Fragment를 묶어서 Reject 가능
```

Hi-Z의 정확한 구성, Tile 크기와 판정 방식은 GPU Vendor와 Architecture의 구현 세부사항이다.

Unity Shader에서 직접 동일한 구조를 제어하는 기능으로 이해하면 안 된다.

Early-Z는 Fragment Shader 전의 Depth Test라는 논리적 개념이고 Hi-Z는 이 판정을 넓은 영역에서 효율적으로 수행하는 Hardware 최적화에 가깝다.

---

## ZWrite가 필요한 이유

뒤쪽 Fragment를 Early-Z로 제거하려면 비교할 Depth 정보가 먼저 존재해야 한다.

```shaderlab
ZTest LEqual
ZWrite On
```

불투명 Surface가 Depth를 기록하면 이후 Draw의 Fragment가 이 값과 비교된다.

`ZWrite Off`이면 현재 Surface는 Depth Test를 통과하더라도 다음 Surface를 가릴 Depth를 남기지 않는다.

```text
ZWrite On
현재 Surface가 다음 Draw의 Occluder가 될 수 있음

ZWrite Off
현재 Surface Color는 보이지만 Depth Occluder가 되지 않음
```

그렇다고 `ZWrite Off`가 Early-Z를 항상 완전히 끈다는 의미는 아니다.

이미 Depth Buffer에 기록된 불투명 Surface와 비교하여 현재 Fragment를 Early Reject할 가능성은 남아 있다.

현재 Draw가 이후 Draw를 가리는 Depth를 추가하지 않을 뿐이다.

---

## 투명 Object와 Early-Z

일반적인 Alpha Blend Material은 다음과 같은 State를 사용한다.

```shaderlab
ZTest LEqual
ZWrite Off
Blend SrcAlpha OneMinusSrcAlpha
```

Depth Buffer의 불투명 Surface 뒤에 있는 투명 Fragment는 Depth Test에서 제거될 수 있다.

```text
Opaque Depth가 이미 기록됨
↓
그 뒤의 Transparent Fragment
↓ Early Depth 실패 가능
Shader 실행 생략 가능
```

하지만 여러 투명 Surface는 보통 서로의 Depth를 기록하지 않는다.

따라서 Particle이 같은 Pixel에 여러 겹 겹치면 각 Layer가 Fragment Shader와 Blending을 수행할 수 있다.

```text
투명 Layer A
투명 Layer B
투명 Layer C
↓
세 Layer 모두 Shading과 Blend 가능
```

Early-Z는 불투명 Depth 뒤의 투명 Fragment를 줄일 수 있지만 투명 Overdraw 전체를 해결하지는 않는다.

---

## `clip`과 `discard`

Alpha Cutout Shader는 Texture Alpha를 읽은 뒤 Fragment를 제거한다.

```hlsl
half alpha = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv).a;
clip(alpha - _Cutoff);
```

Rasterizer Depth만 보면 Fragment가 Depth Test를 통과하더라도 Shader가 `clip`으로 제거할 수 있다.

GPU가 Depth를 너무 일찍 기록한 뒤 Shader에서 Fragment를 제거하면 구멍 위치에도 Depth가 남아 잘못된 결과를 만든다.

```text
잘못된 가정
Early Depth Write
↓
Shader에서 clip
↓
Color는 없지만 Depth가 남음
```

그래서 Early Test와 Early Depth Write는 같은 개념이 아니며 `discard`가 있는 Shader에서는 구현과 State에 따라 최적화 방식이 제한되거나 Early Test와 Late Update가 분리될 수 있다.

`clip`을 사용하면 모든 Early Depth 비교가 반드시 사라진다고 단정하는 것도 정확하지 않다.

GPU는 결과를 보존할 수 있는 범위에서 보수적인 Early Reject를 수행할 수 있지만 실제 동작과 효과는 Platform에서 측정해야 한다.

---

## Alpha Cutout의 비용

나뭇잎 Texture를 큰 Quad에 배치하면 Quad 영역 대부분이 투명하여 `clip`으로 제거될 수 있다.

```text
Quad Coverage: 넓음
실제 잎 영역: 좁음
투명 영역: Fragment Shader에서 제거
```

투명 영역도 Rasterization되고 Alpha Texture를 Sampling해야 제거 여부를 알 수 있다.

Geometry를 실제 모양에 더 가깝게 만들면 빈 영역의 Fragment를 줄일 수 있지만 Vertex와 Triangle 수가 증가한다.

```text
단순 Quad
Vertex 적음 / 빈 Fragment 많음

윤곽에 맞춘 Mesh
Vertex 많음 / 빈 Fragment 적음
```

어느 쪽이 빠른지는 화면 크기, Overdraw, Shader Cost와 Target GPU에 따라 달라진다.

---

## Fragment Shader가 Depth를 쓰는 경우

일반적인 Fragment는 Rasterizer가 계산한 Depth를 사용한다.

Shader가 `SV_Depth`를 출력하면 최종 Depth 값은 Shader를 실행해야 알 수 있다.

```hlsl
struct FragmentOutput
{
    half4 color : SV_Target;
    float depth : SV_Depth;
};
```

```text
Rasterized Depth
↓ Fragment Shader
새 Depth 출력
↓
Depth Test
```

새 Depth가 기존 값보다 앞쪽으로도 뒤쪽으로도 자유롭게 이동할 수 있다면 Rasterized Depth만으로 최종 Test를 미리 확정하기 어렵다.

Graphics API의 Conservative Depth 기능처럼 Shader가 Depth를 특정 방향으로만 변경한다고 선언하여 일부 최적화를 허용하는 방법도 있다.

Unity와 Target Graphics API에서 실제로 사용할 수 있는 기능과 생성된 Shader Code를 확인해야 한다.

---

## Side Effect가 있는 Fragment Shader

Fragment Shader는 Color 출력 외에도 Storage Buffer, RWTexture와 Atomic Counter에 값을 기록할 수 있다.

```hlsl
RWStructuredBuffer<uint> Counter;

half4 frag(Varyings input) : SV_Target
{
    InterlockedAdd(Counter[0], 1);
    return half4(1.0, 1.0, 1.0, 1.0);
}
```

Depth Test에 실패한 Fragment의 Shader 실행을 생략하면 Counter 결과가 달라진다.

```text
Shader를 먼저 실행
Counter 증가 → Depth 실패

Early Test로 Shader 생략
Counter 증가 없음
```

어느 결과가 API에서 요구되는지에 따라 Early Test의 사용 가능 범위가 달라진다.

Storage Write와 Atomic 같은 Side Effect는 Early-Z 최적화와 실행 순서에 영향을 줄 수 있으므로 단순한 Color Shader와 같은 방식으로 가정하면 안 된다.

---

## UAV와 화면 결과 외의 관찰 가능성

Color Buffer에 아무것도 남지 않더라도 Shader가 다른 Resource를 변경했다면 실행 여부를 관찰할 수 있다.

```text
Color Attachment
Depth 실패로 기록 안 됨

Storage Buffer
Shader가 값을 기록할 수 있음
```

GPU는 최종 Color만 같은지 확인하는 것이 아니라 Graphics API가 보장하는 모든 Side Effect와 Ordering을 지켜야 한다.

Debug Counter, Per-Pixel Linked List, Custom Visibility Buffer 같은 기법에서 Fragment Shader Side Effect를 사용한다면 Early와 Late Test의 정확한 규칙이 중요하다.

---

## Depth Test가 꺼진 경우

```shaderlab
ZTest Always
ZWrite Off
```

`ZTest Always`는 Fragment가 Depth 비교 때문에 제거되지 않는다는 의미다.

Fullscreen Post-processing처럼 모든 Pixel을 처리해야 하는 Pass에서는 Early-Z로 가려진 Fragment Shader를 줄일 대상이 없다.

```text
Fullscreen Triangle
↓ ZTest Always
모든 Coverage Fragment 통과
↓
Fragment Shader 실행
```

이 Pass의 비용은 Render Target 해상도, Shader 연산, Texture Sampling과 Bandwidth에 더 직접적으로 영향을 받는다.

Early-Z 최적화는 Depth에 의해 가려지는 Fragment가 있을 때 의미가 있다.

---

## ZTest와 Compare Function

Early-Z는 특정 Compare Function에만 붙은 이름이 아니다.

`Less`, `LEqual`, `Greater`, `GEqual` 등 현재 Pipeline의 Depth 조건을 Shader 전에 평가할 수 있을 때 적용될 수 있다.

```text
Incoming Depth
Stored Depth
Compare Function
↓
Pass 또는 Fail
```

Unity가 Reversed-Z를 사용하는 Platform에서는 가까운 Surface가 더 큰 Depth 값으로 표현될 수 있다.

최적화를 위해 Compare Function을 임의로 바꾸는 것이 아니라 Render Pipeline이 사용하는 Depth Convention과 의도한 가시성 규칙에 맞게 설정해야 한다.

---

## Depth Prepass

Depth Prepass는 Color를 계산하기 전에 Scene의 Depth를 별도 Pass로 먼저 기록한다.

```text
Depth Prepass
간단한 Shader로 Depth만 기록
↓
Color Pass
완성된 Depth Buffer로 Early Test
↓
보이는 Fragment 중심으로 무거운 Shading
```

Unity ShaderLab 개념으로는 다음과 같은 Depth-only State를 사용할 수 있다.

```shaderlab
ZWrite On
ColorMask 0
```

Color Pass에서는 이미 기록된 Depth와 비교한다.

```shaderlab
ZTest Equal
ZWrite Off
```

실제 URP Pass와 Shader State는 Render Pipeline 설정, Renderer Feature와 Material에 따라 달라진다.

Depth Prepass의 핵심은 무거운 Color Shading 전에 가까운 Depth를 준비하는 것이다.

---

## Depth Prepass는 항상 빠를까?

Depth Prepass는 Scene Geometry를 한 번 더 그린다.

```text
추가 비용
Vertex 처리
Primitive 처리
Rasterization
Depth Read / Write
Draw Call과 State 전환

절약 가능 비용
가려진 Fragment의 무거운 Color Shading
```

Fragment Shader가 무겁고 Overdraw가 큰 Scene에서는 이득이 될 수 있다.

반대로 Geometry가 많고 Fragment Shader가 단순하거나 이미 Draw Order와 Hardware Depth Culling이 효율적이면 추가 Pass 비용이 더 클 수 있다.

Tile-based GPU에서는 Depth와 Color Attachment 처리 방식이 다르므로 Desktop GPU의 결과를 그대로 적용하면 안 된다.

Depth Texture, SSAO, Decal과 다른 Feature 때문에 이미 Depth Prepass가 필요한 경우에는 비용 구조가 다시 달라진다.

---

## Depth Priming

일부 Render Pipeline은 이미 생성한 Depth 정보를 이후 Opaque Pass의 Depth Test에 재사용하는 방식을 사용한다.

Unity URP에서는 Version과 Renderer 설정에 따라 Depth Priming 관련 동작을 사용할 수 있다.

개념적 흐름은 다음과 같다.

```text
Depth 정보 선행 생성
↓
Opaque Color Pass에서 재사용
↓
중복 Fragment Shading 감소 가능
```

Depth Priming의 활성 조건과 자동 선택 기준은 Unity Version, Rendering Path와 Platform에 따라 바뀔 수 있다.

Profiler에서 Depth Prepass가 추가되었다는 사실만 보고 문제로 판단하거나, 반대로 이름만 보고 성능 향상을 가정하면 안 된다.

---

## Deferred Rendering과 Early-Z

Deferred Rendering의 Geometry Pass는 화면에 보이는 Surface의 Material 정보를 G-buffer에 기록한다.

가려진 Surface가 G-buffer Fragment Shader를 실행하면 여러 Render Target Write와 Texture Sampling 비용이 발생할 수 있다.

```text
Early Depth 실패
↓
G-buffer Shader 생략 가능
↓
여러 Attachment Write 감소 가능
```

하지만 Deferred Pipeline은 Depth Prepass 사용 여부, G-buffer Layout과 Tile Architecture에 따라 동작이 달라진다.

Early-Z가 중요하다는 방향은 같아도 Forward와 Deferred의 실제 병목은 동일하지 않다.

---

## MSAA와 Early-Z

MSAA에서는 Pixel 하나에 여러 Sample이 존재하고 Fragment는 Coverage Mask를 가진다.

Depth와 Stencil Test도 Coverage된 Sample을 기준으로 처리된다.

```text
4x MSAA Fragment
Coverage = 1111

Sample 0 → Depth 통과
Sample 1 → Depth 실패
Sample 2 → Depth 실패
Sample 3 → Depth 통과
```

일부 Sample만 통과하면 Fragment Shader Invocation과 결과 적용 방식은 Sample Shading 설정과 Hardware에 영향을 받는다.

Coverage가 모두 제거되면 Shader 실행을 생략할 수 있는 가능성이 가장 분명하다.

Single Sample에서 측정한 Early-Z 효과가 MSAA 환경에서 같은 비율로 나타난다고 단정할 수 없다.

---

## Helper Invocation은 남을 수 있다

Early Depth Test에서 실제 Fragment가 제거되더라도 주변 Fragment의 Derivative 계산을 돕기 위해 Helper Invocation이 필요할 수 있다.

```text
2 × 2 Derivative Group

F F
F H

F = 유효 Fragment Invocation
H = Helper Invocation
```

Texture LOD 선택에 사용하는 Derivative는 인접 Invocation의 값 차이를 필요로 한다.

그래서 Early-Z로 Color와 Depth Side Effect가 없는 Fragment를 제거해도 Shader 실행량이 기록된 Pixel 수와 정확히 일치한다고 보장할 수 없다.

작은 Triangle과 경계가 많은 Scene에서는 Helper Invocation의 비중도 함께 고려해야 한다.

---

## Early-Z와 Occlusion Culling은 다르다

두 기능 모두 가려진 대상을 줄이지만 적용 위치가 다르다.

```text
Occlusion Culling
Renderer 또는 Object 제출을 줄임
→ Draw Call, Vertex, Rasterization 비용도 줄일 수 있음

Early-Z
Rasterization된 Fragment를 Shader 전에 제거
→ 주로 Fragment Shader 비용을 줄임
```

Unity Occlusion Culling이 Object를 제거하지 못했더라도 GPU Early-Z가 가려진 Fragment Shading을 줄일 수 있다.

반대로 Early-Z가 잘 작동하더라도 가려진 Mesh의 Vertex 처리와 Rasterization 관련 작업은 이미 발생할 수 있다.

서로 대체하는 기능이 아니라 다른 단계의 최적화다.

---

## Early-Z와 Culling은 다르다

Back Face Culling은 Primitive 방향만으로 Triangle 전체를 Rasterization 전에 제거한다.

```text
Back Face Culling
Triangle 제거
↓
Fragment 자체가 생성되지 않음
```

Early-Z는 Rasterization으로 생성된 Fragment의 Depth를 기존 Buffer와 비교한다.

```text
Early-Z
Fragment 생성
↓
Depth 실패
↓
Fragment Shader 생략 가능
```

가능하다면 더 앞 단계에서 작업을 제거하는 편이 더 많은 비용을 줄일 수 있지만 각 단계는 서로 다른 정보를 사용한다.

---

## Unity에서 확인할 수 있는 것

### Frame Debugger

Frame Debugger로 Opaque Draw 순서, Depth Prepass, Depth-only Pass와 Material State를 확인할 수 있다.

다음 항목이 Early-Z 조건을 이해하는 데 도움이 된다.

- `ZTest`와 `ZWrite`
- Render Queue
- Alpha Clip 사용 여부
- Depth Prepass 존재 여부
- Draw Call 전후 Depth와 Color 변화

Frame Debugger는 GPU 내부에서 몇 개의 Fragment가 Early Reject되었는지 직접 측정하는 도구는 아니다.

### Unity GPU Profiler

GPU Module에서 Pass별 시간을 비교할 수 있다.

Camera와 Object 배치를 바꾸거나 Opaque 정렬, Depth Prepass와 Shader 복잡도를 변경한 뒤 GPU 시간이 어떻게 달라지는지 확인한다.

CPU 시간이 아니라 GPU Pass 시간이 변했는지 구분해야 한다.

### Platform GPU Profiler

RenderDoc, PIX, NVIDIA Nsight Graphics, AMD Radeon GPU Profiler, Xcode GPU Tools와 Android GPU 도구는 Platform에 따라 Depth 관련 Counter를 제공할 수 있다.

예를 들어 다음 의미에 가까운 지표를 찾을 수 있다.

- Early Depth Rejected Samples
- Late Depth Rejected Samples
- Fragment Shader Invocations
- Overdraw
- Depth Compression 또는 Hi-Z 효율

Counter 이름과 계산 기준은 Vendor마다 다르므로 문서를 확인하고 같은 Capture 안에서 비교해야 한다.

---

## Early-Z 효과를 실험하는 방법

같은 화면 결과를 유지하는 두 배치를 비교할 수 있다.

```text
Case A
가까운 불투명 Quad를 먼저 그림
그 뒤에 무거운 Shader의 Object를 배치

Case B
무거운 Shader의 Object를 먼저 그림
가까운 불투명 Quad를 나중에 그림
```

Case A에서 뒤쪽 Object의 Fragment Shader Invocation과 GPU 시간이 줄어든다면 Early Depth Reject의 효과를 관찰할 수 있다.

실험에서는 다음 조건을 고정해야 한다.

- 같은 Resolution과 MSAA
- 같은 Camera와 Geometry
- 같은 Shader Variant
- 같은 Lighting과 Texture
- 같은 Render Target Format
- 충분한 Frame Sample

GPU Clock, Thermal 상태와 다른 Pass의 변동도 결과에 영향을 줄 수 있다.

---

## 최적화 순서

Early-Z 관련 병목이 의심될 때 다음 흐름으로 확인할 수 있다.

```text
1. GPU가 병목인지 확인
↓
2. Fragment 또는 Bandwidth 병목인지 확인
↓
3. Overdraw가 큰 위치 확인
↓
4. ZTest, ZWrite, Blend, Alpha Clip 확인
↓
5. Draw Order와 Depth Prepass 비교
↓
6. Target GPU에서 다시 측정
```

단순히 모든 Material의 `ZWrite`를 켜거나 Depth Prepass를 강제로 추가하는 방식은 시각 결과와 비용을 바꿀 수 있다.

투명 Object에 Depth Write를 켜면 뒤의 투명 Layer가 잘못 가려질 수 있다.

Alpha Cutout을 없애면 Early-Z 조건은 단순해질 수 있지만 표현 자체가 달라진다.

올바른 화면을 유지한 상태에서 병목에 맞는 변경을 적용해야 한다.

---

## Early-Z에 유리할 수 있는 조건

일반적으로 다음 조건은 Early Depth 최적화가 적용되기 쉬운 방향이다.

- Depth Test가 활성화되어 있음
- 앞쪽 불투명 Surface의 Depth가 먼저 준비되어 있음
- Fragment Shader가 Depth를 직접 출력하지 않음
- Shader가 `clip` 또는 `discard`로 Coverage를 바꾸지 않음
- Storage Buffer나 UAV에 관찰 가능한 Side Effect를 만들지 않음
- 가려진 Fragment가 충분히 많음

이 목록은 모든 GPU에서 Early-Z 실행을 보장하는 Unity 규칙이 아니다.

Graphics API의 요구사항과 Driver, GPU Architecture가 최종 실행 방식을 결정한다.

---

## Early-Z를 제한할 수 있는 조건

다음 기능은 Early와 Late Test의 관계를 복잡하게 만들 수 있다.

| 조건 | 이유 |
| --- | --- |
| `SV_Depth` 출력 | 최종 Depth를 Shader 실행 후 알 수 있음 |
| `clip` / `discard` | Shader가 최종 Coverage를 변경함 |
| UAV 또는 Storage Write | Shader 실행 여부가 외부 Resource 결과를 바꿈 |
| Atomic Operation | Invocation 수와 순서가 관찰 가능한 값에 영향 |
| Stencil Reference 출력 | Shader가 Test 기준을 변경할 수 있음 |
| Fragment Interlock | 같은 Pixel·Sample의 실행 순서 제약이 생김 |
| 일부 Sample Mask 조작 | Shader가 Sample Coverage를 바꿈 |

기능 하나가 존재하면 모든 Early Reject가 반드시 꺼진다고 일반화하면 안 된다.

API의 Execution Mode, Conservative 조건과 Hardware 구현에 따라 일부 Early Test와 Late Test를 함께 사용할 수 있다.

---

## Early Test와 Early Write는 다르다

Depth를 Shader 전에 비교하는 것과 Depth Buffer를 Shader 전에 갱신하는 것은 다른 문제다.

```text
Early Test
Rasterized Depth로 통과 여부를 먼저 판단

Early Write
통과한 Depth를 Shader 완료 전에 Buffer에 반영
```

Shader가 `discard`할 수 있다면 Test는 먼저 수행할 수 있어도 Depth Write는 Shader 결과를 기다려야 할 수 있다.

```text
Early Test 통과
↓
Fragment Shader
↓ discard 여부 확정
↓
Depth Write
```

Early-Z라는 하나의 이름 아래 Depth Compare, Depth Update, Hierarchical Reject가 모두 같은 시점에 일어난다고 가정하면 안 된다.

---

## Early-Z가 절약하지 못하는 비용

Early-Z가 Fragment Shader Invocation을 줄여도 이전 단계의 모든 비용이 사라지지는 않는다.

```text
CPU Draw Call
Vertex Fetch
Vertex Shader
Primitive Assembly
Clipping / Culling
Rasterization
Depth Test
↓
여기까지 일부 비용은 이미 발생
↓
Fragment Shader 생략 가능
```

Vertex 병목 Scene에서는 Early-Z Reject가 늘어도 Frame Time 변화가 작을 수 있다.

Memory Bandwidth가 Depth Read와 Write에 묶여 있거나 투명 Blend가 주요 병목인 경우에도 기대한 개선이 나오지 않을 수 있다.

Early-Z는 전체 GPU Pipeline 중 Fragment Shading 이전의 한 최적화다.

---

## 자주 생기는 오해

### Early-Z는 항상 켜져 있다

GPU가 가능한 경우 자동으로 활용할 수 있지만 Shader 기능, Render State와 API 규칙에 따라 적용 범위가 달라진다.

Unity의 단일 On/Off 옵션으로 모든 Material의 Early-Z를 보장하는 기능으로 이해하면 안 된다.

### Depth Test를 사용하면 Fragment Shader가 항상 생략된다

Depth Test에 실패하고 Early Test가 가능한 Fragment만 생략될 수 있다.

통과한 Fragment는 Shader를 실행해야 하며 Helper Invocation이 남을 수도 있다.

### `discard`가 있으면 Early-Z는 무조건 완전히 꺼진다

Coverage와 Depth Write의 확정 시점이 복잡해지고 최적화가 제한될 수 있다.

일부 GPU는 안전한 범위의 Early Reject와 Late Update를 수행할 수 있으므로 실제 Target에서 측정해야 한다.

### Front-to-Back 정렬은 항상 가장 빠르다

Fragment Overdraw에는 유리할 수 있지만 CPU 정렬, Material 전환, Batching과 Tile Architecture의 비용이 함께 변한다.

### Depth Prepass는 Early-Z를 사용하므로 항상 빠르다

Color Shading을 줄이는 대신 Geometry와 Depth Pass를 추가한다.

절약한 Fragment 비용이 추가 비용보다 큰 Scene에서 효과가 있다.

### Early-Z는 가려진 Object의 비용을 모두 제거한다

주로 Fragment Shader 실행을 줄이며 Draw Call, Vertex 처리와 Rasterization 비용은 이미 발생할 수 있다.

---

## Early-Z 판단 흐름

개념적인 판단 과정을 단순화하면 다음과 같다.

```text
Fragment가 Depth Test를 사용하는가?
├─ No → Depth 기반 Early Reject 없음
└─ Yes
   ↓
기존 Depth로 실패를 판단할 수 있는가?
├─ No → Shader 실행 필요
└─ Yes
   ↓
Shader 실행을 생략해도 관찰 가능한 결과가 같은가?
├─ No → Late Test 또는 제한된 최적화
└─ Yes
   ↓
Early Depth Reject 가능
   ↓
Fragment Shader Invocation 생략 가능
```

실제 GPU 판단은 이보다 복잡하며 Application이 위 흐름을 직접 실행하는 것도 아니다.

이 구조는 어떤 Shader 기능이 Early-Z와 충돌할 수 있는지 이해하는 기준이다.

---

## 정리

Early-Z는 Fragment Shader보다 먼저 Depth 또는 Stencil Test를 수행하여 가려진 Fragment의 Shader 실행을 줄이는 GPU 최적화다.

최종 화면에 기여하지 않는 Fragment가 Texture Sampling과 Lighting을 수행한 뒤 폐기되는 낭비를 줄일 수 있다.

```text
Early-Z 없음
Fragment Shader → Depth 실패 → 결과 폐기

Early-Z 가능
Depth 실패 → Fragment Shader 생략 가능
```

Early-Z는 Rasterization 이전에 Object나 Triangle을 제거하는 Culling과 다르다.

Fragment는 이미 생성되고 Depth 비교도 수행되므로 Vertex 처리와 Rasterization 비용까지 모두 제거하지는 않는다.

가까운 불투명 Surface의 Depth가 먼저 기록되면 뒤쪽 Fragment가 Early Reject될 가능성이 커진다.

Front-to-Back Draw Order와 Depth Prepass는 이 Depth 정보를 일찍 준비하는 방법이지만 정렬 및 추가 Pass 비용을 함께 측정해야 한다.

`SV_Depth`, `clip`, `discard`, Sample Mask 변경, Storage Write와 Atomic Side Effect는 Early와 Late Test의 관계를 복잡하게 만든다.

이 기능들이 존재한다고 모든 GPU에서 Early-Z가 완전히 사라진다고 단정할 수는 없으며 API와 Hardware가 허용하는 범위에서 보수적인 Test가 가능할 수 있다.

Depth Test와 Depth Write도 구분해야 한다.

Shader 전에 비교할 수 있더라도 Shader가 Fragment를 제거한다면 Depth 갱신은 나중에 확정될 수 있다.

MSAA, Helper Invocation과 Hierarchical Z 때문에 기록된 Pixel 수와 실제 Shader 실행 수가 단순히 일치하지 않을 수 있다.

Unity에서는 Frame Debugger로 Draw Order와 Render State를 확인하고 GPU Profiler 및 Platform Counter로 Fragment Invocation과 Early Depth Reject 변화를 측정해야 한다.

Early-Z의 효과는 Overdraw, Fragment Shader 비용, Scene Geometry, Render Pipeline과 Target GPU에 따라 달라진다.

```text
Early-Z 최적화의 핵심

가려진 Fragment를 찾음
↓
결과가 바뀌지 않는지 확인 가능한 조건
↓
Fragment Shader 실행을 생략
↓
실제 GPU 시간으로 효과 검증
```
