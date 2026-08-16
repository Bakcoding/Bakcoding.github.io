---
title: "[Unity 렌더링] 7-6. 실시간 Light는 왜 비쌀까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - Lighting
  - RealtimeLight
  - Optimization
permalink: /programming/unity-7-6-why-realtime-lights-are-expensive/
toc: true
toc_sticky: true
date: 2026-08-16
last_modified_at: 2026-08-16
---

실시간 Light는 매 Frame 현재 Transform, Camera, Object와 Shadow 상태를 반영해 Lighting을 다시 계산한다.

Light 하나를 Scene에 추가하는 비용은 단순히 밝기 값 하나를 더하는 데서 끝나지 않는다.

```text
Realtime Light
├─ CPU: Light Culling과 목록 구성
├─ GPU: 영향을 받는 Fragment의 BRDF 반복
├─ Shadow: Light 관점 Scene 재렌더링
├─ Memory: Light·Shadow Data 전송과 Sample
└─ Variant: Light와 Shadow 기능 조합
```

Light가 영향을 주는 화면 영역, Object 수, Pixel 수와 Shadow 설정에 따라 비용이 크게 달라진다.

---

## 실시간 Light란?

Realtime Light는 Frame마다 현재 Scene 상태를 사용해 Direct Lighting을 계산하는 Light다.

Object와 Light가 움직이면 바로 명암과 Highlight가 바뀐다.

```text
Frame N
Light Position + Object Position → Lighting N

Frame N+1
변경된 Position                 → Lighting N+1
```

Dynamic Character, 손전등, 움직이는 문과 시간에 따라 변하는 태양에 필요하다.

Baked Light는 미리 계산한 결과를 Lightmap이나 Probe Data로 저장하므로 Runtime에 같은 Direct Light 계산을 반복하지 않는다.

유연성은 Realtime Light가 높지만 반복 작업 비용도 크다.

---

## Light 하나의 비용은 고정되어 있을까?

같은 Point Light라도 다음 두 상황의 비용은 다르다.

```text
작은 Light
├─ 작은 Range
├─ 화면 일부만 차지
├─ Shadow 없음
└─ 영향 Object 적음

큰 Light
├─ 넓은 Range
├─ 화면 대부분 차지
├─ Soft Shadow 사용
└─ 영향 Object 많음
```

Light 수만 세는 것으로는 실제 비용을 알 수 없다.

대표적인 비용 관계는 다음과 같다.

```text
Lighting Cost
≈ 영향 Pixel 수
 × Pixel당 Light 수
 × Light당 Shader 비용
 + Shadow Rendering 비용
 + CPU Light 관리 비용
```

---

## CPU에서는 어떤 작업이 생길까?

CPU는 Camera와 Object에 어떤 Light가 영향을 주는지 판단하고 GPU가 사용할 Data와 Draw Command를 준비한다.

```text
Visible Light 수집
       │
       ▼
Light Culling / Sorting
       │
       ▼
Object 또는 Tile별 Light List
       │
       ▼
Constant / Buffer Data 준비
       │
       ▼
Render Command 제출
```

Rendering Path에 따라 목록 단위가 Object, Tile 또는 Cluster로 달라진다.

Light와 Renderer 수가 늘면 교차 관계를 판단하고 Data를 구성하는 CPU 작업도 증가한다.

Shadow를 사용하면 Shadow Caster를 별도로 Culling하고 Shadow Pass Command도 준비해야 한다.

---

## GPU에서는 어떤 작업이 생길까?

Lit Fragment는 한 Light마다 방향과 감쇠를 얻고 Diffuse·Specular BRDF를 계산한다.

```text
한 Fragment의 한 Light
├─ Light Direction
├─ Distance / Spot Attenuation
├─ N · L
├─ Diffuse BRDF
├─ Specular BRDF
├─ Shadow Sample
└─ Light Color 누적
```

개념적인 Loop는 다음과 같다.

```hlsl
half3 lighting = EvaluateMainLight(...);

uint lightCount = GetAdditionalLightsCount();

LIGHT_LOOP_BEGIN(lightCount)
    Light light = GetAdditionalLight(lightIndex, positionWS);
    lighting += EvaluatePBRLight(surface, inputData, light);
LIGHT_LOOP_END
```

화면을 크게 차지하는 Object라면 수백만 Fragment에서 이 Loop가 실행될 수 있다.

---

## Pixel Light란?

Pixel Light는 Fragment 또는 Pixel 수준에서 Lighting을 계산하는 Light다.

```text
Rasterized Fragment
       │
       ▼
Normal / Position / View
       │
       ▼
Light별 Diffuse + Specular
       │
       ▼
Pixel Color
```

Normal Map, 좁은 Specular와 작은 Point Light를 정확하게 표현할 수 있다.

대신 계산 횟수는 화면에 생성된 Fragment 수에 비례한다.

```text
1920 × 1080 ≈ 207만 Pixel

Full-screen Fragment에 Additional Light 4개
→ 최대 약 828만 회의 Light 평가 후보
```

Depth Test, Light Culling과 실제 Coverage 때문에 단순 곱과 정확히 같지는 않지만 비용이 빠르게 늘어나는 방향은 같다.

---

## Vertex Light와 무엇이 다를까?

Vertex Light는 Vertex에서 Additional Lighting을 계산하고 Triangle 내부로 보간한다.

```text
Vertex A Light ───── Vertex B Light
          \ 보간 /
           Vertex C Light
```

| 구분 | Vertex Light | Pixel Light |
| --- | --- | --- |
| 계산 기준 | Vertex | Fragment |
| 비용 | 대체로 낮음 | 화면 Coverage에 따라 높음 |
| 작은 Light | 놓칠 수 있음 | 정확함 |
| Specular | 부정확하거나 소실 | 정밀함 |
| Normal Map | 제한적 | 적합 |

Low-poly Mesh에서는 Light가 Vertex 사이에 있을 때 밝은 영역이 사라질 수 있다.

멀리 있는 Object와 단순한 Diffuse에는 Vertex Light가 충분할 수 있지만 가까운 Character에는 품질 차이가 크다.

---

## Fragment 수가 중요한 이유

Pixel Light 비용은 화면 해상도와 Object Coverage의 영향을 받는다.

```text
같은 Material과 Light 수

작은 Object  → 적은 Fragment → 낮은 비용
화면 전체    → 많은 Fragment → 높은 비용
```

Render Scale을 낮추면 Fragment 수가 줄어 Pixel Lighting 비용도 감소할 수 있다.

투명 Object가 겹치면 Depth로 일찍 제거되지 않고 같은 화면 Pixel에서 Lighting이 반복된다.

```text
Transparent Layer 3장
→ 같은 Pixel에서 Lit Fragment가 최대 3회 실행
```

Light 수와 Overdraw가 곱해지면 Transparent Particle과 유리 Material 비용이 커진다.

---

## Light 수는 왜 비용을 증가시킬까?

PBR Shader는 영향을 주는 Light마다 BRDF를 다시 평가한다.

```text
1 Light  → BRDF 1회
4 Lights → BRDF 4회
8 Lights → BRDF 8회
```

실제 증가는 완전히 선형이라고 단정할 수 없다.

GPU Cache, Wave 실행, Light Culling, Shadow와 Compiler 최적화가 함께 작용한다.

하지만 같은 Fragment에 영향을 주는 Pixel Light가 늘면 Light Loop 작업이 증가한다는 관계는 분명하다.

Scene 전체 Light 수보다 한 화면 영역에 겹치는 Light 수가 더 직접적인 지표다.

---

## Light Range가 중요한 이유

Point와 Spot Light의 Range가 커지면 더 많은 Object와 화면 영역에 영향을 준다.

```text
작은 Range                  큰 Range

   ( Light )          (       Light       )
영향 영역 작음          많은 Object와 Tile 포함
```

Range 밖에서는 Light 기여가 0이지만 목록에 포함되는 영역과 Light Volume이 커지면 처리 후보가 늘어난다.

밝기를 높이기 위해 Range를 무조건 늘리지 않고 실제 필요한 공간까지만 설정한다.

Spot Light는 Cone Angle이 넓을수록 영향 영역도 커질 수 있다.

---

## Directional Light는 왜 특별할까?

Directional Light는 위치와 Range 없이 Scene 전체에 같은 방향으로 영향을 준다.

```text
↘ ↘ ↘ ↘ ↘
Scene 전체에 평행한 Light Ray
```

거리 감쇠 계산은 단순하지만 화면의 거의 모든 Lit Fragment가 Main Directional Light를 평가한다.

Shadow를 사용하면 Camera Frustum의 넓은 영역을 Shadow Map에 담아야 하고 Cascade 수에 따라 Shadow Rendering이 반복된다.

작은 Point Light처럼 영향 Volume으로 쉽게 제한되지 않는 점이 중요하다.

---

## Forward Rendering에서 Light 비용

Forward Rendering은 Object의 Fragment Shader 안에서 Light를 적용해 최종 Color를 만든다.

```text
Object A → 영향 Light 목록 → Lit Shader
Object B → 영향 Light 목록 → Lit Shader
Object C → 영향 Light 목록 → Lit Shader
```

URP Forward는 Object마다 영향을 주는 Additional Light 수에 제한을 둘 수 있다.

제한을 낮추면 Shader Loop 비용을 제어할 수 있지만 제외된 Light 때문에 Object 경계에서 Lighting이 갑자기 바뀔 수 있다.

큰 Renderer 하나는 넓은 공간의 Light 후보와 교차할 수 있어 작은 Renderer 여러 개와 다른 결과를 만들 수 있다.

---

## Forward+는 Light를 어떻게 줄일까?

Forward+는 화면을 Tile로 나누고 각 Tile에 영향을 주는 Light를 식별한다.

```text
Screen
┌────┬────┬────┐
│ L1 │L1L2│ L2 │
├────┼────┼────┤
│    │ L3 │ L3 │
└────┴────┴────┘
```

Fragment는 Scene의 모든 Light가 아니라 자신이 속한 영역의 Light 목록을 사용한다.

많은 Local Light가 공간적으로 흩어진 Scene에서 불필요한 Light 평가를 줄인다.

하지만 공짜는 아니다.

```text
Forward+ 추가 비용
├─ Tile / Cluster 구성
├─ Light List Memory
├─ 화면 위치와 Depth 기반 목록 조회
└─ 한 Tile에 겹친 Light Loop
```

한 화면 Tile에 Light가 많이 겹치면 해당 Pixel은 여전히 많은 Light를 계산한다.

Forward+는 Light 수 제한을 없애 주는 기능이지 무제한 Light의 비용을 없애는 기능이 아니다.

---

## Deferred Rendering에서 Light 비용

Deferred는 Geometry Pass에서 Surface Data를 G-buffer에 기록한 뒤 Light Volume별 Lighting Pass를 실행한다.

```text
Geometry → G-buffer
               │
Light Volume 1 ├─ Lighting
Light Volume 2 ├─ Lighting
Light Volume 3 └─ Lighting
```

Object마다 같은 Light를 반복 처리하는 대신 화면에서 Light가 영향을 주는 Pixel에 적용하기 쉬워 많은 Light에 유리할 수 있다.

반면 G-buffer의 여러 Render Target을 읽고 쓰는 Memory Bandwidth, Light Volume Rendering과 호환성 제약이 있다.

화면 대부분을 덮는 Light가 많으면 Deferred에서도 많은 Pixel Lighting이 실행된다.

Rendering Path는 Target GPU, Material, Light 분포와 기능 요구를 Profile해 선택한다.

---

## Shadow를 켜면 왜 더 비쌀까?

Shadow는 두 종류의 큰 작업을 추가한다.

```text
1. Shadow Map 생성
   Light 관점에서 Shadow Caster를 다시 Rendering

2. Shadow 적용
   Lit Fragment에서 Shadow Map Sample과 비교
```

Light의 Color 계산만 늘어나는 것이 아니라 Scene Geometry가 Shadow Pass에서 다시 처리된다.

```text
Camera Color Pass
+ Main Light Shadow Pass
+ Additional Light Shadow Pass
```

Shadow Caster 수와 Triangle 수가 많으면 Vertex 및 Rasterization 비용이 증가한다.

Shadow를 받는 Pixel이 많으면 Shadow Texture Sample과 Filtering 비용이 증가한다.

---

## Point Light Shadow가 특히 비싼 이유

Point Light는 모든 방향으로 빛을 낸다.

주변 360°의 Depth를 저장하려면 Cubemap의 여섯 Face 방향에서 Scene을 Capture한다.

```text
Point Light Shadow
├─ +X
├─ -X
├─ +Y
├─ -Y
├─ +Z
└─ -Z
```

Unity 공식 문서는 Point Light Shadow 비용을 여섯 Spot Light Shadow를 Rendering하는 것과 비교한다.

작은 장식용 Point Light마다 Realtime Shadow를 켜면 Shadow Draw와 Atlas 사용량이 급격히 늘 수 있다.

필요하면 Shadow가 중요한 일부 Light만 Spot Light로 대체하거나 Shadow를 끈다.

---

## Spot Light Shadow는 어떻게 다를까?

Spot Light는 한 Cone 방향만 비추므로 일반적으로 하나의 Perspective Shadow Map 영역을 사용한다.

```text
Point Shadow → 6 Direction
Spot Shadow  → 1 Cone Direction
```

같은 시각적 목적을 Spot Light로 표현할 수 있다면 Point Light Shadow보다 비용을 줄일 가능성이 있다.

다만 Cone이 넓고 Resolution이 높거나 많은 Caster를 포함하면 Spot Shadow도 비싸다.

Light Type만으로 비용을 단정하지 않고 Shadow Coverage와 Resolution을 함께 본다.

---

## Soft Shadow는 무엇을 더할까?

Hard Shadow는 비교적 적은 Shadow Map Sample로 경계를 판단할 수 있다.

Soft Shadow는 주변 Texel을 여러 번 Sample하거나 더 복잡한 Filter를 사용해 경계를 부드럽게 만든다.

```text
Hard Shadow
└─ 적은 Sample

Soft Shadow
└─ 주변 여러 Sample + Filtering
```

Shadow를 받는 Pixel이 많을수록 추가 Sample 비용도 커진다.

URP Asset의 Soft Shadow 품질을 Target Hardware에 맞춰 설정한다.

---

## Shadow Resolution과 Atlas

Shadow Resolution이 높으면 세밀한 Shadow를 만들 수 있지만 더 많은 Memory와 Bandwidth를 사용한다.

Additional Light Shadow는 Atlas 공간을 나누어 사용할 수 있다.

```text
Shadow Atlas
┌────────┬────┐
│ Light A│ B  │
│        ├────┤
├────┬───┤ C  │
│ D  │ E │    │
└────┴───┴────┘
```

Shadow Light 수와 Resolution이 늘면 Atlas 공간 경쟁, 재배치와 품질 저하가 생길 수 있다.

Resolution 자체의 상세 영향은 Shadow 장에서 이어진다.

---

## Light Cookie도 비용이 있을까?

Cookie는 Light에 Pattern Texture를 적용한다.

```text
Light Color
    × Cookie Texture Sample
    × Attenuation
```

Light마다 Cookie Coordinate를 계산하고 Texture를 Sample해야 한다.

Window Pattern이나 Flashlight Shape처럼 시각적 가치가 분명할 때 유용하지만 모든 장식 Light에 무조건 사용할 필요는 없다.

Cookie Atlas와 Resolution도 Memory 사용에 영향을 준다.

---

## Light Layer와 Rendering Layer

Rendering Layer를 사용하면 특정 Light가 특정 Renderer에만 영향을 주도록 제한할 수 있다.

```text
Character Light → Character Layer만
Environment Light → Environment Layer만
```

불필요한 Lighting 관계를 줄이고 Art Control을 높일 수 있다.

하지만 Layer 판정 자체와 관련 Variant가 존재하며 모든 Rendering Path에서 비용 절감 방식이 같지는 않다.

시각적 그룹을 명확히 나누는 도구로 사용하고 실제 GPU 시간은 측정한다.

---

## Light가 Draw Call을 항상 늘릴까?

Modern URP Forward는 여러 Light를 한 Fragment Shader Light Loop에서 처리할 수 있으므로 Light 하나마다 Object를 반드시 다시 Draw하는 것은 아니다.

```text
하나의 Forward Draw
└─ Shader 내부에서 여러 Light Loop
```

그러나 Shadow를 만드는 Light는 ShadowCaster Pass를 추가하고 Deferred Light는 Light Volume Draw를 만들 수 있다.

Built-in Pipeline의 전통적인 Multipass Forward와 URP의 Single-pass Light Loop를 같은 방식으로 보면 안 된다.

Frame Debugger로 실제 Draw와 Pass가 어떻게 증가했는지 확인해야 한다.

---

## CPU Bound와 GPU Bound에서 증상이 다르다

CPU Bound Scene에서는 Light Culling, Shadow Caster 수집, Draw Command와 Render Thread 작업이 병목이 될 수 있다.

GPU Bound Scene에서는 Fragment BRDF, Shadow Sampling, Overdraw와 Shadow Map Rendering이 병목이 될 수 있다.

```text
CPU Bound
└─ Light 관리와 Draw 준비 감소가 중요

GPU Bound
└─ Pixel Light 수, Coverage, Shadow와 해상도 감소가 중요
```

Light를 줄였는데 Frame Time이 거의 바뀌지 않으면 현재 병목이 Lighting이 아니거나 다른 Processor에 있을 수 있다.

최적화 전후 CPU와 GPU 시간을 각각 비교한다.

---

## Light 비용을 확인하는 방법

### Rendering Debugger

Lighting Complexity 또는 관련 Debug View가 제공되면 화면 영역별 Light 중첩을 확인한다.

```text
낮은 값 → 적은 Light 영향
높은 값 → 많은 Light가 같은 영역에 겹침
```

### Frame Debugger

Shadow Pass, Light 관련 Draw와 사용된 Shader Pass를 확인한다.

### GPU Profiler

Opaque, Transparent, Shadow와 Deferred Lighting Pass의 GPU 시간을 비교한다.

### 실험적 Toggle

Light와 Shadow를 그룹별로 꺼서 Frame Time 변화를 측정한다.

```text
Baseline
→ Additional Shadow Off
→ Additional Light Off
→ Main Shadow Off
→ Render Scale Down
```

한 번에 하나의 변수를 바꾸면 비용 원인을 구분하기 쉽다.

---

## 최적화 우선순위

### 겹치는 Realtime Light 수를 줄인다

Scene 전체 개수보다 같은 Pixel에 영향을 주는 개수를 줄인다.

Range와 Spot Angle을 실제 시각 범위로 제한한다.

### Shadow Light를 선별한다

중요한 Main Light와 가까운 핵심 Light에 Shadow를 남긴다.

작은 장식 Light는 Shadow를 끄거나 Cookie와 Baked Detail로 대체할 수 있다.

### Point Shadow를 최소화한다

여섯 방향 Capture가 필요한 Point Light Shadow는 특히 신중하게 사용한다.

가능하면 제한된 방향의 Spot Light를 검토한다.

### Per Vertex와 Per Pixel을 구분한다

멀리 있는 배경과 단순한 Material은 Vertex Additional Light로 충분할 수 있다.

Normal Map과 선명한 Specular가 중요한 Object는 Pixel Light를 유지한다.

### Baked와 Mixed Lighting을 활용한다

움직이지 않는 Light와 Geometry는 Lightmap에 Bake해 Runtime Light Loop와 Shadow 부담을 줄일 수 있다.

Dynamic Object가 필요한 경우 Mixed Light와 Probe를 결합한다.

### Rendering Path를 비교한다

소수 Light와 다양한 Material에는 Forward가 단순할 수 있다.

많은 Local Light에는 Forward+ 또는 Deferred가 유리할 수 있지만 Target GPU에서 측정해야 한다.

---

## Distance 기반으로 Light를 제어하기

Camera에서 멀어진 작은 Light는 화면 기여가 줄어든다.

거리나 중요도에 따라 Shadow와 Light 자체를 단계적으로 줄일 수 있다.

```text
Near
└─ Light On + Shadow On

Middle
└─ Light On + Shadow Off

Far
└─ Light Off 또는 Baked 표현
```

갑자기 끄면 Popping이 보이므로 Intensity와 Shadow Strength를 일정 구간에서 Fade할 수 있다.

CPU에서 매 Frame 모든 Light의 거리를 무분별하게 검사하는 방식도 비용이 있으므로 Update 주기와 관리 구조를 설계한다.

---

## 품질 Tier별 설정

Target Hardware에 따라 URP Asset을 나누어 Light 품질을 조절할 수 있다.

| 항목 | 높은 품질 | 낮은 품질 |
| --- | --- | --- |
| Additional Light | Per Pixel | Per Vertex 또는 제한 |
| Per Object Limit | 높음 | 낮음 |
| Additional Shadow | 선택적 사용 | Off 또는 최소 |
| Shadow Resolution | 높음 | 낮음 |
| Soft Shadow | 높은 품질 | Hard 또는 Low |
| Shadow Distance | 김 | 짧음 |

Forward+와 Deferred에서는 일부 Forward 전용 Per Object 설정이 적용되지 않을 수 있다.

Quality Level이 실제로 어느 URP Asset과 Renderer를 사용하는지 확인한다.

---

## 자주 생기는 문제

### Light 수는 적은데 GPU가 느리다

Light가 Full-screen에 가깝게 영향을 주거나 Shadow와 Transparent Overdraw가 클 수 있다.

Light 개수 대신 Coverage와 Pass 시간을 확인한다.

### Forward+로 바꾸면 항상 빨라질 것이라 생각한다

Forward+는 많은 Local Light의 선별에 유리하지만 Tile List 구성과 조회 비용이 있다.

Light가 적거나 Target GPU 특성이 다르면 Forward가 더 빠를 수 있다.

### Shadow Resolution만 낮추면 Shadow 비용이 모두 해결된다

Caster Draw 수, Point Light의 여섯 Face, Cascade 수, Distance, Soft Shadow Sample과 Receiver Pixel도 비용 요인이다.

### Light Range 밖이면 비용이 완전히 없다

Culling으로 Pixel 계산은 줄어도 CPU가 Light를 관리하고 후보를 분류하는 작업은 남을 수 있다.

### Baked Light는 Runtime 비용이 전혀 없다

Realtime Light Loop는 줄지만 Lightmap Texture Memory와 Sample, Probe Data와 Baking 관리 비용은 존재한다.

### Light를 끄면 Visual만 달라진다

Light Keyword, Shadow Atlas와 Variant 선택이 달라질 수 있어 첫 Frame이나 Build 구성이 함께 변할 수 있다.

---

## 전체 비용 흐름

```text
Scene Realtime Lights
          │
          ▼
CPU Visible Light Culling
          │
          ├─ Object Light List: Forward
          ├─ Tile / Cluster List: Forward+
          └─ Light Volume 준비: Deferred
          │
          ▼
GPU Lighting
Fragment 수 × 영향 Light 수 × BRDF 비용
          │
          ├─ Distance / Spot Attenuation
          ├─ Diffuse / Specular
          ├─ Cookie
          └─ Shadow Sample
          │
          ▼
Shadow가 켜진 Light
          │
          ├─ Caster Culling
          ├─ ShadowCaster Draw
          ├─ Shadow Atlas Write
          └─ Soft Shadow Filtering
          │
          ▼
        Frame Time
```

실시간 Light 최적화는 Light Component 하나의 Option이 아니라 CPU 목록 구성, 화면 Coverage, Shader Loop와 Shadow Pass를 함께 줄이는 작업이다.

---

## 정리

실시간 Light는 매 Frame 현재 Scene 상태를 반영하기 위해 CPU의 Light 관리와 GPU의 Lighting 계산을 반복한다.

CPU는 Visible Light와 Shadow Caster를 Culling하고 Object, Tile 또는 Light Volume에 맞는 목록과 Render Command를 준비한다.

Pixel Light는 Fragment마다 Diffuse·Specular BRDF, 거리·각도 감쇠와 Shadow를 계산하므로 화면 Coverage에 따라 비용이 커진다.

같은 Pixel에 영향을 주는 Light 수가 늘면 Light Loop의 BRDF 계산도 반복된다.

Vertex Light는 계산 횟수를 줄일 수 있지만 작은 Local Light, Normal Map과 좁은 Specular 표현이 부정확하다.

Forward는 Object별 Additional Light를 처리하고 Forward+는 Tile별 Light List로 불필요한 Light 후보를 줄인다.

Deferred는 G-buffer 이후 Light Volume별로 Lighting하지만 Memory Bandwidth와 별도 Lighting Pass 비용이 있다.

Shadow Light는 Light 관점의 ShadowCaster Rendering과 화면 Fragment의 Shadow Map Sampling을 모두 추가한다.

Point Light Shadow는 여섯 방향을 Capture하므로 여섯 Spot Light Shadow에 해당하는 수준의 Rendering 작업이 필요할 수 있다.

Soft Shadow, 높은 Resolution, 긴 Shadow Distance, 많은 Cascade와 Shadow Caster는 비용을 더 높인다.

최적화에서는 Scene 전체 Light 개수보다 화면에서 겹치는 Pixel Light, Range, Shadow Light와 Transparent Overdraw를 우선 확인한다.

Baked·Mixed Lighting, Vertex Light, 제한된 Range, Distance 기반 Shadow 제어와 적절한 Rendering Path를 조합한다.

Frame Debugger, Rendering Debugger와 CPU·GPU Profiler로 병목을 측정한 뒤 Target Hardware별 URP Asset 설정을 결정해야 한다.
