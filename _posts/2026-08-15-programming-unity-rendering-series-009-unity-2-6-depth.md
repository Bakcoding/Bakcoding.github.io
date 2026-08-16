---
title: "[Unity 렌더링] 2-6. Depth는 왜 필요할까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - DepthBuffer
  - ZTest
  - ZFighting
permalink: /programming/unity-2-6-depth/
toc: true
toc_sticky: true
date: 2026-08-15
last_modified_at: 2026-08-15
---

3D Scene에는 여러 오브젝트가 서로 다른 거리에 배치된다.

Camera에서 보았을 때 두 오브젝트가 화면의 같은 위치에 겹치면 가까운 표면이 먼 표면을 가려야 한다.

```text
Camera
↓
가까운 Cube
↓
먼 Sphere
```

최종 화면에서는 Cube가 있는 부분에 Sphere가 보이지 않아야 한다.

하지만 GPU는 Triangle을 제출받은 순서만으로 어느 표면이 앞에 있는지 항상 알 수 없다.

먼 오브젝트가 나중에 그려졌다는 이유로 가까운 오브젝트 위를 덮어쓰면 3D 공간의 가림 관계가 깨진다.

이를 해결하기 위해 화면 위치마다 지금까지 기록된 표면의 깊이를 저장하고 새로운 Fragment의 깊이와 비교한다.

이때 사용하는 것이 **Depth Buffer**다.

```text
Color Buffer
화면에 보일 색상 저장

Depth Buffer
화면에 남아 있는 표면의 깊이 저장
```

Depth Buffer를 이용하면 불투명 Geometry는 제출 순서가 달라도 대부분 올바른 앞뒤 관계를 만들 수 있다.

---

## Depth란?

Depth는 Camera 관점에서 표면이 시야 방향의 어느 위치에 있는지를 나타내는 값이다.

단순히 오브젝트의 World Position Z와 같은 값은 아니다.

Camera가 이동하거나 회전하면 같은 World Position도 Camera 기준 깊이가 달라진다.

```text
World Space Z
Scene의 공통 축 기준

View Depth
Camera를 기준으로 한 깊이

Depth Buffer Value
Projection과 Viewport Depth 변환을 거쳐 저장되는 값
```

Depth Buffer에 저장되는 값은 Camera와 오브젝트 사이의 직선거리를 그대로 World Unit으로 기록한 값도 아니다.

Vertex의 Clip Space 깊이는 Perspective Divide와 Viewport Depth 변환을 거쳐 버퍼가 사용하는 범위에 대응된다.

Perspective Camera에서는 이 값이 일반적으로 World 거리와 선형 관계가 아니다.

---

## Depth Buffer란?

Depth Buffer는 Render Target의 각 화면 위치에 깊이 정보를 저장하는 Buffer다.

Z Buffer라고도 부른다.

```text
Color Buffer

Pixel (0,0) → Color
Pixel (1,0) → Color
Pixel (2,0) → Color
...

Depth Buffer

Pixel (0,0) → Depth
Pixel (1,0) → Depth
Pixel (2,0) → Depth
...
```

MSAA를 사용하면 Pixel 하나에 여러 Sample이 존재할 수 있고 Depth도 Sample 단위로 관리될 수 있다.

따라서 엄밀하게는 Pixel마다 하나라고만 단정하기보다 Render Target의 Sample 위치에 대응하는 깊이 데이터라고 보는 편이 정확하다.

Depth Buffer는 보통 Color Buffer와 같은 화면 크기에 대응하지만 Color 자체를 저장하지 않는다.

새로운 Fragment가 기존 표면보다 앞에 있는지를 검사하고, 통과한 경우 깊이를 갱신하는 데 사용된다.

---

## Depth Buffer가 없다면?

Depth Buffer를 사용하지 않으면 나중에 그린 결과가 앞의 Color를 덮는 순서에 의존하게 된다.

이를 Painter's Algorithm처럼 먼 표면부터 가까운 표면 순서로 정확히 정렬하여 해결할 수도 있다.

```text
먼 오브젝트 그리기
↓
중간 오브젝트 그리기
↓
가까운 오브젝트 그리기
```

하지만 Triangle이 서로 교차하거나 하나의 Mesh 안에서 깊이가 복잡하게 바뀌면 오브젝트 단위 정렬만으로 올바른 순서를 만들기 어렵다.

```text
Triangle A 일부는 B보다 앞
Triangle A 다른 일부는 B보다 뒤
```

모든 Triangle을 정확히 분할하고 정렬하는 것도 큰 CPU 비용과 복잡성을 만든다.

Depth Buffer는 Rasterization된 Fragment 수준에서 깊이를 비교하므로 복잡하게 겹치는 불투명 표면의 가시성을 처리하기 적합하다.

---

## 하나의 Fragment가 처리되는 흐름

Triangle이 Rasterization되면 화면의 Sample을 덮는 Fragment가 생성된다.

각 Fragment에는 보간된 깊이값이 있다.

단순화한 흐름은 다음과 같다.

```text
Triangle Rasterization
↓
Fragment 생성
↓
새 Fragment Depth 계산
↓
Depth Buffer의 기존 값과 비교
↓
Depth Test 통과?
├─ 아니오 → 결과 제거
└─ 예     → Color 처리 및 필요하면 Depth 갱신
```

실제 GPU에서는 Early Depth Test, Fragment Shader, Late Depth Test의 배치가 Shader 동작과 하드웨어에 따라 달라질 수 있다.

핵심은 새로운 Fragment의 깊이를 현재 Buffer 값과 비교하여 보이는 표면인지 판단한다는 점이다.

---

## Z-Test란?

Z-Test 또는 Depth Test는 새 Fragment의 깊이와 Depth Buffer에 저장된 값을 비교하는 과정이다.

```text
새 Fragment Depth
vs
현재 Depth Buffer Value
```

비교 조건을 만족하면 Fragment가 통과하고, 만족하지 못하면 가려진 것으로 판단할 수 있다.

Unity ShaderLab에서는 `ZTest`로 비교 조건을 지정한다.

```shaderlab
ZTest LEqual
```

`LEqual`은 개념적으로 새 Geometry가 기존 Geometry보다 앞에 있거나 같은 깊이에 있을 때 통과시키는 의미다.

Unity 문서에서 일반적인 기본값으로 설명되는 조건이다.

플랫폼이 Reversed-Z를 사용하는 경우 실제 하드웨어 Depth 값의 크고 작음과 비교 명령은 내부적으로 조정될 수 있다.

따라서 ShaderLab의 의미와 Raw Depth 숫자의 방향을 그대로 같은 것으로 생각하면 안 된다.

---

## ZTest 비교 조건

Unity ShaderLab은 여러 Depth Test 조건을 제공한다.

| 조건 | 의미 |
|---|---|
| `Never` | 어떤 깊이도 통과시키지 않음 |
| `Less` | 기존 깊이보다 앞에 있는 경우 통과 |
| `LEqual` | 앞에 있거나 같은 경우 통과 |
| `Equal` | 같은 깊이인 경우 통과 |
| `GEqual` | 뒤에 있거나 같은 경우 통과 |
| `Greater` | 기존 깊이보다 뒤에 있는 경우 통과 |
| `NotEqual` | 같은 깊이가 아닌 경우 통과 |
| `Always` | 깊이와 관계없이 통과 |

여기서 앞과 뒤의 의미는 Unity가 사용하는 Depth Convention에 맞춰 해석된다.

`Always`는 Depth Test를 사실상 무시하고 모든 Fragment를 통과시키는 특수 효과에 사용할 수 있다.

`Equal`은 이미 Depth가 기록된 표면 위치에 추가 Pass를 적용할 때 사용할 수 있다.

비교 조건을 바꾸면 정상적인 가림 관계도 달라지므로 시각 효과의 목적과 Render Pass 순서를 함께 고려해야 한다.

---

## Z-Write란?

Z-Write는 Depth Test를 통과한 Fragment의 깊이를 Depth Buffer에 기록할지를 결정한다.

Unity ShaderLab에서는 다음처럼 설정한다.

```shaderlab
ZWrite On
```

또는

```shaderlab
ZWrite Off
```

`ZTest`와 `ZWrite`는 서로 다른 기능이다.

```text
ZTest
기존 Depth와 비교할 것인가?

ZWrite
통과한 Depth를 Buffer에 기록할 것인가?
```

`ZWrite Off`라고 해서 Depth Test까지 자동으로 꺼지는 것은 아니다.

기존 Depth Buffer를 읽어 가려짐을 판단하면서 자신의 Depth는 기록하지 않을 수 있다.

---

## 불투명 오브젝트의 일반적인 Depth 상태

불투명 오브젝트는 보통 Depth Test와 Depth Write를 모두 사용한다.

```shaderlab
ZTest LEqual
ZWrite On
```

가까운 불투명 표면이 그려지면 해당 위치의 Color와 Depth가 기록된다.

이후 뒤쪽 표면의 Fragment는 Depth Test에서 실패할 수 있다.

```text
가까운 Wall 렌더링
Color 기록 + Depth 기록
↓
뒤의 Enemy 렌더링
같은 화면 위치에서 Depth Test 실패
```

이 구조 덕분에 뒤쪽 불투명 오브젝트가 나중에 제출되어도 앞의 표면을 잘못 덮지 않는다.

Opaque Sorting은 Depth Test의 효율을 높이기 위해 앞쪽 Geometry를 먼저 그리는 방향을 고려할 수 있다.

---

## 먼저 그린 오브젝트가 항상 보일까?

Depth Write가 활성화되어 있어도 먼저 그린 오브젝트가 무조건 최종 화면에 남는 것은 아니다.

먼 오브젝트가 먼저 그려졌다고 가정할 수 있다.

```text
1. 먼 Sphere
Color와 먼 Depth 기록

2. 가까운 Cube
Depth Test 통과
Color와 가까운 Depth로 덮어씀
```

가까운 Cube는 기존 Depth보다 앞에 있으므로 통과하여 Sphere 결과를 덮는다.

반대로 가까운 Cube가 먼저 그려지면 뒤의 Sphere는 Depth Test에서 실패한다.

두 순서 모두 최종 가시성은 같을 수 있지만 GPU가 수행한 Fragment Shader 작업량은 다를 수 있다.

---

## Early-Z란?

Depth Test는 Fragment Shader보다 먼저 수행될 수 있다.

이런 조기 Depth 판정을 일반적으로 Early-Z 또는 Early Depth Test라고 부른다.

```text
Fragment 생성
↓ Early Depth Test
가려진 Fragment 제거
↓
Fragment Shader 실행
```

뒤에 완전히 가려진 Fragment라면 Texture Sampling과 Lighting을 포함한 비싼 Fragment Shader를 실행하기 전에 제거할 수 있다.

```text
Wall 뒤의 복잡한 Material
↓
Early-Z에서 제거
↓
Fragment Shader 비용 절약 가능
```

Depth Buffer는 단순히 화면 결과를 올바르게 만드는 용도뿐 아니라 보이지 않는 Fragment 연산을 줄이는 최적화에도 연결된다.

---

## Early-Z가 항상 동작할까?

모든 Shader가 항상 Fragment Shader 전에 Depth Test를 끝낼 수 있는 것은 아니다.

Fragment Shader가 Depth 값을 직접 변경하거나 Fragment를 조건부로 버리는 동작을 사용하면 최종 깊이와 생존 여부를 Shader 실행 전에 확정하기 어려울 수 있다.

```text
Fragment Shader가 Depth 출력
Fragment Shader에서 discard / clip 사용
Alpha Test 성격의 처리
특정 UAV 또는 Side Effect 사용
```

GPU와 Graphics API는 Early Test를 보수적으로 수행하거나 Hierarchical Depth 같은 최적화를 사용할 수 있지만 실제 동작은 하드웨어와 Shader에 따라 달라진다.

`ZTest`가 켜져 있다는 사실만으로 모든 가려진 Fragment Shader 실행이 제거된다고 단정하면 안 된다.

GPU Profiler와 Frame Capture로 실제 비용을 확인해야 한다.

---

## Front-to-Back Rendering

불투명 오브젝트를 Camera 가까운 순서에서 먼 순서로 그리면 Depth Buffer가 앞쪽 표면으로 먼저 채워질 가능성이 높다.

```text
가까운 Geometry
↓
중간 Geometry
↓
먼 Geometry
```

뒤의 Fragment가 Early-Z에서 제거될 수 있으므로 Overdraw 비용을 줄이는 데 도움이 된다.

이를 Front-to-Back Rendering이라고 볼 수 있다.

하지만 모든 Opaque Draw를 거리순으로 완벽하게 정렬하면 CPU Sorting 비용이 늘고 Material과 Render State 변경이 많아질 수 있다.

```text
Front-to-Back 이점
Depth 제거 효율

Material 기준 Sorting 이점
State 변경 감소
```

Render Pipeline은 이 요소들을 함께 고려하여 Opaque Sorting을 구성할 수 있다.

하나의 기준만 무조건 최적이라고 볼 수 없다.

---

## Transparent는 왜 ZWrite Off를 사용할까?

반투명 표면은 뒤의 Color와 자신의 Color를 Blending해야 한다.

```text
최종 Color
= 앞의 Transparent Color
+ 뒤의 Background Color
```

Transparent가 자신의 Depth를 먼저 기록하면 뒤에 있는 다른 Transparent Fragment가 Depth Test에서 제거되어 Blending에 참여하지 못할 수 있다.

```text
앞 Transparent가 Depth 기록
↓
뒤 Transparent가 Depth Test 실패
↓
뒤 Color가 보이지 않음
```

그래서 일반적인 반투명 Shader는 Depth Test는 사용하되 Depth Write를 끄는 경우가 많다.

```shaderlab
ZTest LEqual
ZWrite Off
Blend SrcAlpha OneMinusSrcAlpha
```

이렇게 하면 앞의 불투명 Geometry에는 가려지면서 Transparent끼리는 Rendering Order에 따라 Blending할 수 있다.

---

## Transparent는 Depth Buffer만으로 해결되지 않는다

ZWrite를 끈 Transparent는 서로의 Depth를 Buffer에 남기지 않는다.

따라서 일반적인 Alpha Blending에서는 먼 Transparent부터 가까운 Transparent 순서로 그리는 Back-to-Front Sorting이 필요하다.

```text
먼 Transparent
↓
가까운 Transparent
↓
Blending
```

하지만 오브젝트 단위 Sorting은 서로 교차하는 Mesh나 하나의 Mesh 내부 Triangle 순서를 완벽하게 해결하지 못한다.

```text
Transparent A 일부가 B 앞
Transparent A 일부가 B 뒤
```

그래서 Transparent Rendering은 Opaque보다 복잡하며 Order Independent Transparency 같은 별도 기법이 연구되고 사용되기도 한다.

Depth Buffer가 있다고 모든 투명 가시성 문제가 자동으로 해결되는 것은 아니다.

---

## Alpha Clipping은 Transparent와 다르다

나뭇잎이나 철망처럼 Texture의 Alpha를 기준으로 Pixel을 완전히 남기거나 제거하는 방식은 Alpha Clipping을 사용할 수 있다.

```hlsl
clip(alpha - cutoff);
```

통과한 부분은 완전히 불투명하게 취급하여 Depth를 기록할 수 있다.

```text
Alpha가 Cutoff 이상
→ Color와 Depth 기록

Alpha가 Cutoff 미만
→ Fragment 제거
```

일반적인 반투명 Blending과 달리 연속적인 투명도를 표현하지 않지만 Depth Write와 Opaque에 가까운 가림 처리를 사용할 수 있다.

다만 `clip` 또는 `discard`가 Early-Z 최적화와 MSAA Edge에 영향을 줄 수 있으므로 실제 대상 GPU에서 측정해야 한다.

---

## Depth 값은 어떻게 만들어질까?

Vertex Shader는 각 Vertex의 Clip Position을 출력한다.

```text
Clip Position
(xClip, yClip, zClip, wClip)
```

Perspective Divide를 거치면 NDC 깊이를 얻을 수 있다.

```text
zNDC = zClip / wClip
```

Rasterizer는 Triangle 내부에서 깊이를 계산하고 Viewport의 Depth Range에 맞게 변환한다.

```text
Clip Space Depth
↓ Perspective Divide
NDC Depth
↓ Viewport Depth Transform
Depth Buffer Value
```

Graphics API와 Unity의 플랫폼 처리에 따라 NDC 깊이 범위와 방향이 다를 수 있다.

Shader에서 Raw Depth를 사용할 때는 Unity가 제공하는 매크로와 변환 함수를 이용해야 한다.

---

## Perspective Depth는 선형이 아니다

Perspective Projection에서는 Depth Buffer 값이 Camera로부터의 World 거리와 일정한 비율로 증가하지 않는다.

일반적으로 깊이 정밀도는 Camera 가까운 영역과 먼 영역에 균일하게 분배되지 않는다.

```text
Near 부근
Depth 값 변화가 상대적으로 큼

Far 부근
같은 World 거리 차이가 더 작은 Depth 차이로 표현될 수 있음
```

이 비선형 분포는 Perspective Projection과 `z / w` 변환에서 발생한다.

따라서 Depth Texture의 Raw 값을 그대로 World 거리라고 사용하면 잘못된 결과가 된다.

Fog, Soft Particle, Depth 기반 후처리에서는 Raw Depth를 Linear Eye Depth 또는 World Position으로 복원하는 과정이 필요하다.

---

## Depth Buffer의 정밀도

Depth Buffer는 무한히 정밀한 실수가 아니다.

사용하는 Format에 따라 표현할 수 있는 값의 수와 분포가 제한된다.

```text
16-bit Depth
메모리는 적지만 정밀도가 낮을 수 있음

24-bit Depth
널리 사용되는 Depth 정밀도 형태 중 하나

32-bit Float Depth
더 높은 정밀도와 다른 분포 특성
```

실제 플랫폼과 Render Pipeline이 선택하는 Depth Format은 지원 기능과 설정에 따라 달라질 수 있다.

두 표면의 변환된 깊이 차이가 Buffer가 구분할 수 있는 최소 차이보다 작으면 같은 값처럼 저장될 수 있다.

이 문제가 Z-Fighting으로 이어질 수 있다.

---

## Reversed-Z란?

전통적인 Depth Mapping에서는 Near를 작은 값, Far를 큰 값에 대응시키는 방식을 떠올릴 수 있다.

Reversed-Z는 반대로 Near를 큰 Depth 값, Far를 작은 값에 대응시킨다.

```text
일반적인 방향 예시
Near → 0
Far  → 1

Reversed-Z 예시
Near → 1
Far  → 0
```

Floating-Point Depth Buffer의 값 분포와 Perspective Depth 분포를 더 유리하게 결합하여 먼 거리의 정밀도를 개선할 수 있다.

Unity는 Direct3D 계열, Metal, Vulkan과 같은 여러 플랫폼에서 Reversed-Z를 사용할 수 있다.

Shader에서 Raw Depth가 가까울수록 항상 작다고 가정하면 플랫폼에 따라 반대 결과가 나올 수 있다.

Unity는 `UNITY_REVERSED_Z` 같은 매크로와 Depth 변환 Helper를 제공한다.

```hlsl
#if UNITY_REVERSED_Z
    // Reversed-Z 환경에 필요한 처리
#endif
```

일반적인 `ZTest LEqual` 같은 ShaderLab 의미는 Unity가 플랫폼에 맞게 처리하므로 Raw 하드웨어 비교 방향과 혼동하지 않는 것이 중요하다.

---

## Depth Buffer는 언제 초기화될까?

새 Camera Render를 시작할 때 Depth Buffer는 이전 Frame의 임의 값이 아니라 비교 기준이 되는 Clear Value로 초기화할 수 있다.

일반 Depth 방향과 Reversed-Z에서는 가장 먼 값을 나타내는 Clear Value가 다를 수 있다.

```text
Depth Clear
↓
아직 아무 Geometry도 기록되지 않은 상태
↓
첫 Geometry Depth Test
```

Camera Stack이나 여러 Render Pass에서는 기존 Depth를 유지하여 다음 Pass가 사용할 수도 있고, 새 Depth Target을 만들거나 Clear할 수도 있다.

Depth Clear 여부는 Pipeline과 Camera 합성 방식에 중요한 Render State다.

불필요한 Clear와 Depth Target 전환도 GPU 비용과 메모리 대역폭에 영향을 줄 수 있다.

---

## Depth Texture와 Depth Buffer는 같은 것일까?

Depth Buffer는 GPU의 Depth Test와 Depth Write에 사용하는 Attachment다.

Depth Texture는 Shader에서 Sampling할 수 있도록 노출된 깊이 데이터다.

두 용어가 같은 이미지 Resource를 가리키는 경우도 있지만 항상 완전히 같은 생성 과정이라고 단정할 수 없다.

```text
Depth Attachment
Depth Test에 사용

Camera Depth Texture
Shader Sampling에 사용
```

Render Pipeline은 Depth Attachment를 Texture로 사용할 수 있게 만들거나, 별도의 Depth Prepass 또는 Copy Depth Pass로 Camera Depth Texture를 생성할 수 있다.

플랫폼의 Depth Resource Sampling 지원과 MSAA, Render Pipeline 설정에 따라 방식이 달라질 수 있다.

Depth Texture가 필요하다는 것은 추가 Pass나 Copy, 메모리 사용을 만들 수 있다.

---

## Depth Texture는 어디에 사용할까?

화면의 깊이를 Shader에서 읽을 수 있으면 다양한 화면 효과를 만들 수 있다.

```text
Depth 기반 Fog
Soft Particle
Screen Space Ambient Occlusion
Depth of Field
Outline
World Position Reconstruction
Screen Space Effect
```

Soft Particle은 Particle 깊이와 Scene Depth를 비교하여 지면이나 벽과 만나는 경계를 부드럽게 만들 수 있다.

World Position Reconstruction은 Screen UV와 Depth를 이용해 해당 Pixel이 Scene의 어느 위치에서 왔는지 복원한다.

이런 효과에서는 Raw Depth의 비선형성과 Reversed-Z, 플랫폼별 NDC 범위를 올바르게 처리해야 한다.

---

## Depth Prepass란?

Depth Prepass는 주요 Color Pass 전에 Geometry의 Depth를 먼저 렌더링하는 Pass다.

```text
Depth Prepass
Depth만 기록
↓
Opaque Color Pass
기존 Depth를 이용해 가려진 Fragment 제거
```

복잡한 Fragment Shader와 많은 Overdraw가 있는 Scene에서는 Color Pass 전에 Depth를 확보하여 Early-Z 효율을 높일 수 있다.

또한 Camera Depth Texture가 필요할 때 깊이를 만드는 방법으로 사용될 수 있다.

하지만 Geometry를 한 번 더 렌더링해야 하므로 Vertex Processing과 Draw Call, Command 비용이 증가한다.

```text
이점
비싼 Fragment Overdraw 감소 가능

비용
Geometry Pass 추가
CPU Command와 Vertex 처리 증가
```

Depth Prepass가 이득인지는 Scene의 병목과 GPU Architecture, Render Pipeline의 Depth Copy 비용을 함께 측정해야 한다.

---

## Z-Fighting이란?

Z-Fighting은 서로 매우 가깝거나 같은 위치에 있는 두 표면의 Depth 순서가 안정적으로 구분되지 않아 화면에서 번갈아 나타나는 현상이다.

```text
Plane A Depth
≈
Plane B Depth
```

Camera나 오브젝트가 조금 움직일 때 두 표면의 일부 Pixel이 서로 다른 Depth 결과를 만들면서 얼룩이나 깜빡임처럼 보일 수 있다.

대표적인 상황은 같은 위치에 두 Plane을 겹쳐 둔 경우다.

```text
바닥 Mesh
위에 동일 위치의 Decal Plane
```

Depth Buffer의 제한된 정밀도로 두 값을 구분하기 어려우면 어느 표면이 통과할지 불안정해진다.

---

## Z-Fighting이 발생하는 이유

Z-Fighting에는 여러 요소가 영향을 준다.

```text
표면 사이 거리가 너무 가까움
Near와 Far 범위가 지나치게 큼
Near Plane이 필요 이상으로 작음
먼 거리의 Perspective Depth 정밀도 부족
낮은 정밀도의 Depth Format
거대한 World 좌표의 부동소수점 정밀도 문제
```

Perspective Camera에서는 Near Plane 설정이 Depth 정밀도 분포에 큰 영향을 줄 수 있다.

Near를 0에 매우 가깝게 두고 Far를 매우 멀게 두면 넓은 범위를 제한된 Depth 값으로 표현해야 한다.

Reversed-Z와 Floating-Point Depth는 정밀도를 개선할 수 있지만 완전히 같은 위치의 Coplanar Surface 문제를 없애지는 못한다.

---

## Z-Fighting은 어떻게 줄일까?

가장 명확한 방법은 두 표면을 실제로 분리하거나 중복 Geometry를 제거하는 것이다.

```text
중복 Face 제거
표면 사이에 충분한 거리 확보
Decal 전용 방식 사용
```

Camera 설정에서는 필요한 범위 안에서 Near Plane을 멀리 두고 Far Plane을 과도하게 늘리지 않는 것이 Depth 정밀도에 도움이 될 수 있다.

ShaderLab의 `Offset`을 이용하여 Depth Bias를 적용할 수도 있다.

```shaderlab
Offset Factor, Units
```

Depth Bias는 Decal이나 Coplanar Geometry를 의도적으로 앞 또는 뒤로 이동한 것처럼 Depth 비교에 영향을 준다.

하지만 값이 너무 크면 원하지 않는 Geometry보다 앞으로 튀어나오거나 Camera 각도에 따라 부자연스러운 결과가 생길 수 있다.

근본적으로 중복된 표면을 해결할 수 있다면 Geometry 구조를 먼저 수정하는 편이 좋다.

---

## Z-Fighting과 Shadow Acne은 같은 문제일까?

두 현상 모두 Depth 정밀도와 Bias에 연결되지만 사용하는 Depth Map과 목적이 다르다.

Z-Fighting은 주로 Camera Depth에서 거의 같은 두 표면의 가시성 경쟁으로 나타난다.

Shadow Acne은 Shadow Map에 기록된 깊이와 표면의 깊이를 비교할 때 자기 자신을 잘못 Shadow로 판단하는 현상이다.

```text
Z-Fighting
Camera 화면의 표면 간 Depth 경쟁

Shadow Acne
Light 기준 Shadow Depth 비교 문제
```

Shadow Bias는 Shadow Map 비교 문제를 줄이기 위한 설정이고 일반 Camera의 모든 Z-Fighting을 해결하는 값은 아니다.

---

## ZTest Always는 언제 사용할까?

`ZTest Always`는 기존 Depth와 관계없이 Fragment를 통과시킨다.

```shaderlab
ZTest Always
```

화면 전체를 덮는 Post Processing Pass, 항상 위에 보여야 하는 일부 Debug 효과처럼 Scene Geometry 가림이 필요하지 않은 경우에 사용할 수 있다.

하지만 World Geometry에 무분별하게 사용하면 벽 뒤의 오브젝트가 앞에 보이는 결과가 생긴다.

```text
벽 Depth 존재
↓
오브젝트 ZTest Always
↓
벽을 무시하고 Color 기록
```

Depth Test를 끄는 것은 최적화 설정이 아니라 시각적 규칙을 바꾸는 Render State다.

가려진 Fragment도 모두 Shader를 실행할 수 있어 성능이 오히려 나빠질 수 있다.

---

## ZWrite Off는 성능 최적화일까?

Depth Write를 끄면 Buffer 기록을 줄일 수 있지만 이것만으로 성능이 좋아진다고 단정할 수 없다.

자신의 Depth를 기록하지 않으면 뒤에 그려지는 Geometry를 Early-Z로 제거하는 데 기여하지 못한다.

```text
ZWrite On
뒤 Geometry 제거에 사용할 Depth 생성

ZWrite Off
뒤 Geometry가 현재 표면의 Depth를 알지 못함
```

Transparent Overdraw가 큰 이유 중 하나도 Depth Write를 일반적으로 사용할 수 없어 겹친 Fragment가 계속 Blending되는 데 있다.

Render State는 개별 읽기와 쓰기 비용뿐 아니라 이후 Draw의 제거 효율까지 함께 봐야 한다.

---

## Depth와 Render Queue

Unity는 보통 Opaque Geometry를 먼저 렌더링하고 Transparent Geometry를 나중에 렌더링한다.

```text
Opaque
ZWrite On
Depth Buffer 구성
↓
Transparent
ZTest 사용, ZWrite Off가 일반적
Opaque 뒤의 Fragment 제거
```

Opaque가 먼저 Depth를 채우면 뒤에 있는 Transparent Fragment는 Depth Test에서 제거될 수 있다.

Transparent끼리는 Depth를 기록하지 않으므로 Sorting과 Blending 순서가 중요하다.

Material의 Render Queue와 `ZTest`, `ZWrite`, `Blend` 상태는 서로 독립적인 설정이지만 올바른 결과를 위해 함께 구성해야 한다.

---

## Depth와 Overdraw

Overdraw는 같은 화면 위치에 여러 Fragment가 반복해서 처리되는 현상이다.

Depth Test가 뒤의 Fragment를 조기에 제거하면 실제 Fragment Shader Overdraw를 줄일 수 있다.

```text
불투명 표면 여러 개
앞 Depth가 먼저 기록
↓
뒤 Fragment Early-Z 제거 가능
```

하지만 Transparent는 일반적으로 ZWrite를 하지 않기 때문에 겹친 Layer가 모두 Fragment Shader와 Blending을 수행할 수 있다.

Particle, UI, 반투명 이펙트가 화면을 넓게 덮으면 GPU Fragment 비용이 커질 수 있다.

Depth Buffer가 존재한다는 사실만으로 Overdraw가 모두 사라지는 것은 아니다.

---

## Depth와 MSAA

MSAA에서는 하나의 Pixel 안에 여러 Coverage Sample이 존재할 수 있다.

Triangle Edge에서 일부 Sample만 Geometry에 포함될 수 있다.

```text
Pixel
├─ Sample 0: Triangle A
├─ Sample 1: Triangle A
├─ Sample 2: Background
└─ Sample 3: Background
```

각 Sample의 Coverage와 Depth를 구분하면 Triangle Edge를 더 부드럽게 표현할 수 있다.

하지만 Sample 수가 늘면 Depth와 Color 관련 메모리, 대역폭과 처리 비용이 증가할 수 있다.

Depth Texture를 Copy하거나 Sampling할 때 MSAA Depth를 어떻게 처리하는지도 Render Pipeline과 플랫폼에 따라 달라질 수 있다.

---

## Depth를 시각화할 때 주의할 점

Depth Texture의 값을 그대로 Grayscale Color로 출력하면 대부분 한쪽 색에 몰려 보일 수 있다.

Perspective Depth가 비선형이고 Reversed-Z가 적용될 수 있기 때문이다.

```hlsl
float rawDepth = SampleSceneDepth(uv);
```

Raw Depth를 용도에 맞게 Linearize한 뒤 표시해야 Camera로부터의 거리 변화를 이해하기 쉽다.

```text
Raw Depth
↓ Projection Parameter를 이용한 변환
Linear Eye Depth 또는 Linear01 Depth
↓
시각화
```

Unity URP의 Depth Sampling Helper와 `_ZBufferParams` 기반 함수를 사용하면 플랫폼 차이를 처리하는 데 도움이 된다.

---

## Depth 문제를 어떻게 확인할까?

Depth 관련 문제가 발생하면 다음 항목을 나누어 확인할 수 있다.

```text
Shader의 ZTest 조건
Shader의 ZWrite 상태
Render Queue와 Sorting
Camera Near / Far
Depth Buffer Format
Depth Texture 생성 방식
MSAA 사용 여부
Reversed-Z와 플랫폼 차이
겹친 Geometry 존재 여부
```

Unity Frame Debugger에서는 Draw 순서와 Render Target, Shader Pass를 확인할 수 있다.

RenderDoc 같은 GPU Frame Capture 도구에서는 Depth Attachment와 각 Draw 전후의 Depth 값을 자세히 볼 수 있다.

문제를 단순히 Sorting 오류라고 판단하기 전에 Depth Test와 Write 상태를 함께 확인하는 것이 중요하다.

---

## 최적화 관점의 Depth

Depth Buffer는 메모리와 대역폭을 사용하며 Depth Prepass는 추가 Geometry Rendering을 만들 수 있다.

반대로 Early-Z와 Hierarchical Depth를 이용하면 비싼 Fragment Shader 실행을 크게 줄일 수 있다.

```text
Depth의 비용
Buffer 메모리
Read / Write 대역폭
Clear
Depth Prepass 가능성

Depth의 이점
올바른 가시성
가려진 Fragment 제거
후처리용 공간 정보
```

Depth를 사용할지 말지를 하나의 비용으로만 판단할 수 없다.

불투명 3D Scene에서 Depth Buffer는 정확한 화면 결과와 GPU 최적화의 핵심 기반이다.

성능을 분석할 때는 Opaque Overdraw, Transparent Overdraw, Early-Z 효율, Depth Prepass 비용을 각각 확인해야 한다.

---

## 전체 흐름

Depth가 하나의 Frame에서 사용되는 흐름을 단순화하면 다음과 같다.

```text
Camera Projection
↓
Vertex Clip Position 생성
↓
Clipping과 Perspective Divide
↓
Triangle Rasterization
↓
Fragment Depth 생성
↓
Depth Buffer의 기존 값과 Z-Test
├─ 실패 → Fragment 제거
└─ 통과
   ↓
   Fragment Color 계산
   ↓
   Color Buffer 기록
   ↓
   ZWrite On이면 Depth Buffer 갱신
```

실제 GPU에서는 Early와 Late Test의 위치가 달라질 수 있고 Color, Depth Write 순서도 하드웨어 최적화로 병렬 처리될 수 있다.

개념적으로는 Depth 비교가 현재 화면 위치에 어느 표면이 남을지를 결정한다.

---

## 정리

Depth는 Camera 관점에서 표면의 앞뒤 관계를 나타내며 단순한 World Z나 Camera와의 직선거리를 그대로 의미하지 않는다.

Depth Buffer는 Render Target의 Sample 위치마다 현재 기록된 표면의 깊이를 저장한다.

새 Fragment의 깊이와 기존 값을 비교하는 과정이 Z-Test이고, 통과한 깊이를 Buffer에 기록할지를 결정하는 상태가 Z-Write다.

불투명 오브젝트는 일반적으로 Depth Test와 Depth Write를 사용하여 Draw 순서와 관계없이 올바른 가림 관계를 만든다.

Depth Test를 Fragment Shader보다 먼저 수행할 수 있으면 가려진 Fragment의 비싼 연산을 생략할 수 있으며 이를 Early-Z라고 부른다.

Early-Z의 실제 동작은 Shader가 Depth를 변경하거나 Fragment를 버리는지, GPU가 어떤 최적화를 사용하는지에 따라 달라질 수 있다.

반투명 오브젝트는 뒤의 Color와 Blending해야 하므로 보통 ZWrite를 끄고 Depth Test만 사용한다.

이 때문에 Transparent끼리는 Rendering Order가 중요하며 Depth Buffer만으로 모든 투명 정렬 문제를 해결할 수 없다.

Perspective Depth는 World 거리와 선형 관계가 아니며 Graphics API와 Reversed-Z 사용 여부에 따라 Raw Depth의 방향과 범위가 달라질 수 있다.

Depth Texture를 Sampling할 때는 Unity의 매크로와 Linearization Helper를 사용해야 한다.

서로 매우 가까운 표면의 깊이를 Buffer 정밀도로 구분하지 못하면 Z-Fighting이 발생할 수 있다.

중복 Geometry 제거, 표면 간격 확보, 적절한 Near·Far 설정과 필요한 경우 Depth Bias를 이용하여 현상을 줄일 수 있다.

Depth Buffer는 메모리와 대역폭을 사용하지만 올바른 가시성, Early-Z 최적화와 여러 Screen Space Effect를 가능하게 하는 핵심 렌더링 자원이다.

Depth를 이해하면 다음으로 Alpha와 Blend가 왜 불투명 표면과 다른 렌더링 순서와 Depth 상태를 요구하는지 연결할 수 있다.
