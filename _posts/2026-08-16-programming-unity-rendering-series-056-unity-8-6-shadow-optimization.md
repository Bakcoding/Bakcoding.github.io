---
title: "[Unity 렌더링] 8-6. Shadow 최적화는 어떻게 할까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - Shadow
  - Optimization
  - Profiling
permalink: /programming/unity-8-6-shadow-optimization/
toc: true
toc_sticky: true
date: 2026-08-16
last_modified_at: 2026-08-16
---

Shadow 최적화는 설정 하나를 무조건 낮추는 작업이 아니다.

```text
Shadow Cost
├─ CPU: Caster Culling과 Draw 준비
├─ GPU: ShadowCaster Geometry Rendering
├─ GPU: Receiver의 Shadow Sampling
├─ Memory: Main Shadow Map과 Additional Atlas
└─ 반복: Light × Face × Cascade
```

어디에서 시간이 걸리는지 확인한 뒤 가장 낮은 시각적 손실로 해당 비용을 줄여야 한다.

Distance, Resolution, Cascade, Light와 Cast Shadows는 서로 다른 비용을 조절한다.

---

## 먼저 목표를 정한다

최적화는 목표 Frame Time과 품질 기준이 있어야 끝낼 수 있다.

```text
60 FPS 목표 → Frame당 약 16.67 ms
30 FPS 목표 → Frame당 약 33.33 ms
90 FPS 목표 → Frame당 약 11.11 ms
```

이 전체 시간 안에서 Script, Physics, Animation과 Rendering이 예산을 나누어 쓴다.

Shadow Pass가 몇 ms까지 허용되는지는 Project와 Platform마다 다르다.

다음 조건을 먼저 기록한다.

- Target Platform과 Graphics API
- 목표 FPS와 CPU·GPU Frame Budget
- 대표 Camera와 최악의 Camera 구도
- 반드시 보여야 하는 Shadow
- 허용 가능한 Shadow Distance와 품질
- 평균 성능뿐 아니라 Frame Spike 기준

---

## Shadow 품질의 우선순위를 정한다

모든 Shadow가 같은 시각적 가치를 갖지는 않는다.

```text
높은 우선순위
├─ Player 발밑
├─ Gameplay에 영향을 주는 Enemy
├─ 큰 Architecture
└─ 주요 Directional Light

낮은 우선순위 후보
├─ 먼 Grass Blade
├─ 작은 Debris
├─ 장식용 Point Light
└─ 화면에 거의 보이지 않는 내부 Mesh
```

중요도 구분 없이 모든 Light와 Renderer에 최고 품질을 적용하면 예산을 낭비하기 쉽다.

먼저 무엇을 지킬지 정해야 무엇을 줄일지 판단할 수 있다.

---

## 측정하지 않고 설정부터 낮추면 안 되는 이유

Shadow Resolution은 GPU Fill-rate와 Memory에 영향을 주지만 CPU Draw 수를 직접 줄이지 않을 수 있다.

Cast Shadows를 끄면 Caster Draw는 줄지만 화면 전체의 Receiver Sampling 비용은 그대로일 수 있다.

```text
증상: Frame이 느림
├─ CPU 병목인가?
├─ GPU Shadow Generation 병목인가?
├─ GPU Shadow Sampling 병목인가?
└─ Memory Bandwidth 병목인가?
```

원인을 모르면 품질은 낮아지고 Frame Time은 거의 변하지 않는 조정을 할 수 있다.

최적화 전 기준 Capture를 남기고 한 번에 하나의 변수를 바꾼다.

---

## CPU 병목의 신호

CPU는 Shadow View마다 Caster를 찾고 Draw Command를 준비한다.

```text
CPU Shadow Work
├─ Light와 Cascade View 구성
├─ Caster Culling
├─ Sorting과 Batching
├─ Draw Command 생성
└─ GPU 제출
```

다음 조건에서 CPU 부담이 커지기 쉽다.

- Shadow를 만드는 Light가 많음
- 작은 Shadow Caster Renderer가 매우 많음
- Cascade Count가 높음
- Shadow Distance가 넓고 Object가 밀집됨
- Point Light Shadow가 많음
- 여러 Camera가 같은 Scene을 Rendering함

CPU 병목에서는 Caster와 Shadow View의 수를 줄이는 조정이 우선이다.

---

## GPU Shadow Generation 병목의 신호

ShadowCaster Pass는 Light 관점에서 Geometry를 다시 Rendering한다.

```text
Caster Vertex
    │
    ▼
Light Space Transform
    │
    ▼
Rasterization
    │
    ▼
Depth Test / Write
```

다음 조건에서 GPU 생성 비용이 커질 수 있다.

- Shadow Map과 Atlas Resolution이 높음
- Skinned Mesh와 Vertex Animation Caster가 많음
- Alpha Clipping Foliage가 넓게 분포함
- Point Light의 여섯 Face를 반복 Rendering함
- Caster가 여러 Cascade에 중복됨
- 큰 Triangle이 Shadow Tile을 넓게 덮음

GPU Capture에서 Main Light와 Additional Light Shadow Pass 시간을 분리해 확인한다.

---

## GPU Shadow Sampling 병목의 신호

Receiver Shader는 화면 Pixel마다 Shadow Map을 읽고 Depth를 비교한다.

```text
Receiver Pixel
├─ Shadow Coordinate 계산
├─ Cascade 선택
├─ Shadow Map Sample
├─ PCF Filtering
└─ Lighting에 Shadow 적용
```

높은 화면 해상도, 넓은 Receiver와 고품질 Soft Shadow는 Sampling 비용을 키울 수 있다.

Shadow를 만드는 Object 수를 줄였는데 Shadow Pass 생성 시간만 줄고 전체 GPU 시간이 여전히 높다면 Receiver 비용도 확인한다.

Soft Shadow를 끄거나 Quality를 낮춘 A/B Test가 원인 분리에 도움이 된다.

---

## Memory 병목의 신호

Main Light Shadow Map과 Additional Light Shadow Atlas는 GPU Memory를 사용한다.

```text
Memory ≈ Width × Height × Texel당 Byte
```

한 변의 Resolution을 2배로 올리면 Texel 수는 4배가 된다.

```text
1024 × 1024 → 약 1.0M Texel
2048 × 2048 → 약 4.2M Texel
4096 × 4096 → 약 16.8M Texel
```

실제 Memory는 Depth Format, Atlas Layout과 Platform 구현에 따라 달라진다.

모바일처럼 Memory Bandwidth가 제한된 환경에서는 큰 Atlas와 많은 Soft Shadow Sample이 함께 부담을 만들 수 있다.

---

## 1단계: Shadow Light 수를 줄인다

Shadow를 활성화한 Realtime Light마다 추가 Rendering이 필요하다.

```text
Realtime Light
├─ Lighting 계산
└─ Shadow Enabled
   ├─ Shadow Map 생성
   └─ Receiver Sample
```

Light가 실제로 밝기를 더하는 것과 실시간 Shadow가 반드시 필요한 것은 별개다.

장식용 Light는 Shadow를 끄고 핵심 Light만 Shadow를 유지한다.

```text
우선순위 예시
1. Main Directional Light
2. Player와 상호작용하는 Spot Light
3. 중요한 연출 Light
4. 장식 Point Light는 Shadow Off 검토
```

Light 수를 줄이는 조정은 CPU, GPU와 Atlas 사용량을 동시에 줄일 가능성이 크다.

---

## Point Light Shadow를 먼저 확인한다

Point Light는 모든 방향의 Shadow를 만들기 위해 여섯 Face를 Rendering한다.

```text
1 Spot Light Shadow  = 1 View
1 Point Light Shadow = 6 Views
```

Unity 공식 문서는 Point Light Shadow 하나의 비용을 Spot Light Shadow 여섯 개와 비교한다.

작은 전등 Point Light 여러 개에 Shadow를 켜면 Culling, Caster Draw와 Atlas Tile이 급격히 늘 수 있다.

다음을 검토한다.

- 방향을 제한할 수 있다면 Spot Light로 변경
- Static 환경이면 Baked Light 사용
- Light Cookie로 정적인 가림 패턴 표현
- Camera에서 먼 Point Light의 Shadow 비활성화
- Low Quality에서 Point Shadow 제거

모바일에서는 Shadow Point Light를 최소화하거나 사용하지 않는 선택도 중요하다.

---

## Light를 거리와 조건에 따라 끈다

Unity 공식 문서는 Camera 거리나 다른 조건에 따라 Shadow Light를 Script로 끄는 방법을 제시한다.

```csharp
using UnityEngine;

public class DistanceShadowLight : MonoBehaviour
{
    [SerializeField] private Light targetLight;
    [SerializeField] private Transform targetCamera;
    [SerializeField] private float activeDistance = 20f;

    private void LateUpdate()
    {
        float sqrDistance =
            (targetLight.transform.position - targetCamera.position).sqrMagnitude;

        targetLight.enabled = sqrDistance <= activeDistance * activeDistance;
    }
}
```

예시는 구조를 보여 주기 위한 단순 코드다.

매 Frame 많은 Light에서 개별 거리 계산을 하는 대신 중앙 Manager, Spatial Partition이나 Light Culling 체계를 사용할 수 있다.

갑작스러운 Pop을 피하려면 Light의 `intensity`를 먼저 Fade하고 비활성화한다.

---

## 2단계: Cast Shadows 대상 수를 줄인다

실시간 Shadow Caster 수는 Shadow Rendering 성능에 큰 영향을 준다.

```text
Mesh Renderer
└─ Lighting
   └─ Cast Shadows: Off
```

Shadow가 시각적으로 의미 없는 Renderer는 ShadowCaster Pass에서 제외한다.

| Object | 판단 기준 |
| --- | --- |
| Player | 대체로 유지 |
| 큰 건물 | Silhouette와 접지감 확인 후 유지 |
| 작은 Debris | 화면 기여도가 낮으면 Off |
| 실내 숨은 Mesh | 외부 Shadow 기여가 없으면 Off |
| 먼 Grass | LOD와 거리별 Off 검토 |
| 투명 장식 | 실제 Shadow 필요성 확인 |

Caster를 제거하면 해당 Mesh의 Culling, Draw, Vertex와 Depth 작업을 줄일 수 있다.

---

## Receive Shadows도 구분한다

Receiver 수와 화면 Coverage는 Shadow Sampling 비용에 영향을 준다.

```text
Caster Off
→ Shadow Map 생성 비용 감소

Receive Shadows Off
→ 해당 Material의 Shadow 적용 비용 감소 가능
```

Emission 중심 Material, 먼 Background와 Shadow가 거의 보이지 않는 Effect가 실시간 Shadow를 받을 필요가 있는지 확인한다.

다만 URP Shader와 Material 설정에 따라 Variant와 실제 실행 경로가 달라질 수 있으므로 GPU Capture로 확인한다.

Receive Shadows를 끄면 Lighting 일관성과 Object의 접지감이 깨질 수 있다.

---

## 작은 Caster가 많은 Scene

CPU 병목은 Triangle 수보다 Renderer 수에서 먼저 발생할 수 있다.

```text
큰 Mesh 1개, 100k Triangles
vs
작은 Mesh 10,000개, 각각 10 Triangles
```

두 경우 Triangle 총량이 같아도 10,000개 Renderer는 Culling과 Draw 준비 부담이 크다.

Grass, Debris와 작은 Prop는 다음 전략을 검토한다.

- GPU Instancing 또는 적절한 Batching
- Renderer 결합 시 Culling Granularity Trade-off 확인
- 먼 거리 Shadow Casting Off
- 단순 Shadow Proxy Mesh
- LOD별 Shadow 정책

결합을 지나치게 크게 하면 보이지 않는 영역까지 함께 Shadow Rendering될 수 있으므로 측정이 필요하다.

---

## Alpha Clipping Caster

Foliage ShadowCaster는 Alpha Texture를 읽고 Fragment를 버린다.

```hlsl
half alpha = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv).a;
clip(alpha - _Cutoff);
```

Opaque Depth Pass보다 Texture Sample과 Fragment 처리 부담이 커질 수 있다.

투명한 영역도 Triangle Rasterization을 거쳐 Alpha Test를 수행한다.

최적화 방법은 다음과 같다.

- Shadow용 단순 Silhouette Mesh 사용
- ShadowCaster Pass용 저비용 Alpha Texture 검토
- 먼 LOD에서 Alpha Detail 단순화
- 먼 Grass의 Cast Shadows 비활성화
- Shadow Distance를 실제 필요 범위로 제한

Color Pass와 Shadow 모양이 지나치게 달라지지 않는지 확인한다.

---

## Skinned Mesh와 Vertex Animation

Character Pose와 움직이는 Vertex가 Shadow에 반영되려면 ShadowCaster Pass에서도 변형된 Position이 필요하다.

```text
Animation / Vertex Deformation
├─ Camera Pass
└─ ShadowCaster Pass × View
```

여러 Cascade와 Shadow Light에 Character가 포함되면 Vertex 작업이 반복될 수 있다.

먼 Crowd의 Shadow는 다음 대안을 검토한다.

- 단순 LOD Skinned Mesh
- Blob Shadow나 Projector 방식
- 일부 Character만 Cast Shadows 유지
- 먼 거리에서 Baked 환경 Shadow와 조합

Gameplay 가독성과 Character 접지감을 기준으로 선택한다.

---

## 3단계: Shadow Distance를 줄인다

Shadow Distance를 줄이면 Camera 주변의 실시간 Shadow 영역이 작아진다.

```text
Distance 감소
├─ Caster 후보 감소 가능
├─ CPU Culling과 Draw 감소 가능
├─ GPU Geometry 작업 감소 가능
└─ 같은 Resolution의 Texel Density 증가 가능
```

Unity 공식 문서는 URP의 `Max Distance`를 낮추면 Shadow Pass에서 처리하는 Object가 줄어 CPU와 GPU 시간을 줄일 수 있다고 설명한다.

먼 Shadow가 화면에서 차지하는 Pixel과 Gameplay 중요도를 확인해 필요한 최소 거리를 찾는다.

---

## Distance 경계를 감춘다

Distance를 줄이면 Shadow가 Camera 앞에서 사라지는 전환이 보일 수 있다.

```text
Near Realtime Shadow
───────────────╲ Fade
                ╲──────── No Realtime Shadow
```

다음 요소를 함께 사용한다.

- Last Border 또는 Shadow Fade
- Fog로 먼 Contrast 감소
- Static 환경의 Baked Shadow
- Shadowmask Lighting Mode
- 큰 원거리 Shadow만 별도 유지

Fade는 전환을 감추는 기능이며 Caster 생성 비용이 같은 비율로 줄어든다고 가정해서는 안 된다.

---

## 4단계: Cascade Count를 줄인다

Cascade마다 별도의 Shadow View, Culling과 ShadowCaster Rendering이 필요하다.

```text
4 Cascades
├─ C0 Culling + Draw
├─ C1 Culling + Draw
├─ C2 Culling + Draw
└─ C3 Culling + Draw
```

URP 공식 성능 지침은 허용 가능한 가장 낮은 Cascade Count를 사용하도록 권장한다.

4개에서 2개로 줄이면 반복 View를 줄일 수 있지만 가까운 Shadow의 Perspective Aliasing이 커질 수 있다.

Cascade 수만 낮추기 전에 Shadow Distance와 Split을 함께 조절해 핵심 구간의 Texel Density를 유지한다.

---

## Cascade Split을 효율적으로 배치한다

Cascade 수가 같아도 Split에 따라 품질 분포가 달라진다.

```text
나쁜 예시 가능성
[────────────][────][────][────]
Near Cascade가 너무 넓음

조정 예시
[──][────][────────][────────────────]
Near 영역에 Detail 집중
```

Character, Enemy와 주요 Prop가 자주 위치하는 거리에 높은 Texel Density를 배정한다.

경계가 넓은 평면 중앙이나 Character가 자주 서는 위치를 지나지 않도록 Camera 경로에서 확인한다.

큰 Renderer가 여러 Cascade를 가로지르면 중복 Draw가 늘 수 있으므로 Frame Debugger에서 확인한다.

---

## 5단계: Main Shadow Resolution을 낮춘다

Resolution을 낮추면 Shadow Map Texel 수, Memory와 Rasterization 부담을 줄일 수 있다.

```text
4096 → 2048
한 변 1/2
전체 Texel 1/4
```

그러나 실제 GPU 시간은 Vertex, Culling과 Draw 비용도 포함하므로 정확히 1/4이 되지는 않는다.

Resolution을 낮춘 뒤 다음을 확인한다.

- Character 발밑의 계단
- 대각선 Edge의 Aliasing
- Camera 이동 중 Shimmering
- Cascade 경계의 품질 차이
- Bias와 Light Leak

필요한 Distance와 Cascade를 먼저 정한 뒤 가장 낮은 허용 Resolution을 찾는다.

---

## 6단계: Additional Shadow Atlas를 조절한다

Additional Spot·Point Light는 Shadow Atlas를 공유한다.

```text
Additional Shadow Atlas
┌────────┬────────┐
│Light A │Light B │
├────────┼────────┤
│Light C │Point 1 │
└────────┴────────┘
```

Atlas가 너무 크면 Memory와 Rendering 영역이 늘고 너무 작으면 개별 Light Tile의 Resolution이 낮아질 수 있다.

모든 Light를 High Tier로 지정하지 말고 화면 기여도에 따라 Low, Medium, High를 배정한다.

```text
High   : 핵심 Character와 연출 Light
Medium : 일반 Gameplay Light
Low    : 작거나 먼 보조 Light
Off    : Shadow가 필요 없는 장식 Light
```

Point Light는 여섯 Tile이 필요하므로 Atlas 수용량 계산에서 특히 주의한다.

---

## 7단계: Soft Shadows를 조절한다

Soft Shadow는 주변 Depth를 여러 번 Sample해 경계를 부드럽게 만든다.

```text
Hard Shadow
└─ 적은 Sample, 선명한 계단 가능

Soft Shadow
└─ 여러 PCF Sample, 부드러운 경계
```

URP는 Soft Shadow Quality에 따라 Filtering Sample 구조가 달라진다.

Unity 6 URP Asset 문서 기준으로 Low는 4 PCF Tap, Medium은 5 × 5 Tent Filter, High는 7 × 7 Tent Filter를 사용한다.

Tile-based Rendering을 사용하는 Mobile과 Untethered XR에서는 Soft Shadow가 큰 비용이 될 수 있다.

다음 순서로 비교한다.

```text
High → Medium → Low → Disabled
```

낮은 Resolution과 Soft Shadow 조합이 Art Style에 더 적합하고 저렴할 수도 있다.

---

## Hard Shadow가 항상 정답은 아니다

Soft Shadow를 끄면 Sample 비용은 줄지만 계단 현상을 숨기기 위해 Resolution을 크게 올리고 싶어질 수 있다.

```text
선택 A
높은 Resolution + Hard Shadow

선택 B
낮은 Resolution + Low Soft Shadow
```

어느 쪽이 빠른지는 Platform, Receiver Pixel 수와 Shadow Pass 병목에 따라 달라진다.

품질과 GPU Time을 같은 장면에서 직접 비교한다.

Art Direction이 부드러운 Shadow를 요구한다면 Filtering은 단순한 결함 보정이 아니라 의도된 표현이다.

---

## 8단계: Baked Lighting과 Shadowmask를 사용한다

움직이지 않는 Light와 Static Geometry의 Shadow는 Runtime마다 다시 만들 필요가 없다.

```text
Static Environment
└─ Baked Shadow / Lightmap

Dynamic Character
└─ Realtime Shadow
```

Shadowmask는 Baked Shadow와 Realtime Shadow를 결합해 실시간 범위를 줄이는 데 사용할 수 있다.

장점은 Static Shadow의 Runtime 생성 비용을 줄일 수 있다는 점이다.

대신 Bake 시간, Texture Memory, Lightmap 관리와 Dynamic Object의 Shadow 제한을 고려해야 한다.

Light Mode별 동작과 Platform 지원을 확인한 뒤 선택한다.

---

## Light Cookie를 대체 표현으로 사용한다

대부분 Static인 영역에서 Point·Spot Light의 고정된 가림 패턴은 Light Cookie로 표현할 수 있다.

```text
Realtime Shadow
→ 실제 Geometry에 반응
→ Caster Rendering 필요

Light Cookie
→ 미리 만든 Pattern 투영
→ 실제 동적 가림은 표현하지 못함
```

창문 틀, 나뭇잎 Pattern이나 장식 조명의 고정된 Shadow 표현에 적합할 수 있다.

Cookie Atlas와 Sampling 비용은 남으므로 공짜 기능은 아니다.

Dynamic Object가 Light를 가려야 하는 Gameplay 상황에는 실제 Shadow를 대체할 수 없다.

---

## Blob Shadow와 단순 대체물

작은 Character나 Mobile Crowd의 접지감만 필요하다면 정교한 Shadow Map이 과할 수 있다.

```text
대체 방식
├─ Blob Shadow Quad
├─ Decal / Projector
├─ Baked Contact Mark
└─ 단순 Shadow Proxy
```

Blob Shadow는 Light 방향과 복잡한 Geometry Silhouette를 정확히 표현하지 못한다.

그러나 Camera가 멀고 Object가 작다면 낮은 비용으로 위치와 높이를 전달할 수 있다.

실시간 Shadow와 대체 Shadow가 겹치지 않도록 거리별 전환을 설계한다.

---

## LOD와 Shadow 정책

Color Mesh의 LOD만 바꾸고 Shadow는 항상 같은 Detail로 만들 필요가 없다.

```text
LOD 0 Near
├─ Full Geometry
└─ Cast Shadows On

LOD 1 Mid
├─ Simplified Geometry
└─ Cast Shadows On

LOD 2 Far
├─ Very Low Geometry
└─ Cast Shadows Off 또는 Proxy
```

Shadow Silhouette에 영향을 거의 주지 않는 작은 Detail을 먼저 제거한다.

LOD Cross Fade가 Alpha Test를 사용하면 Shadow Pass에서도 추가 비용이 생길 수 있으므로 Mobile에서 Profile한다.

LOD와 Shadow 전환이 Camera에서 Pop으로 보이지 않는지 확인한다.

---

## Shadow 전용 Proxy Mesh

복잡한 Mesh 대신 단순한 Geometry로 Shadow를 만들 수 있다.

```text
Camera Color Pass
└─ 100k Triangle Character

ShadowCaster
└─ 5k Triangle Proxy
```

Hair, 작은 장식과 내부 Geometry를 제거하고 외곽 Silhouette만 유지한다.

Proxy가 Animation과 Transform을 정확히 따라야 하며 실제 Mesh와 Shadow가 분리되어 보이지 않아야 한다.

가까운 Hero Character보다 먼 NPC, 복잡한 Vehicle과 Architecture에 적용하기 쉽다.

---

## Camera가 여러 개인 경우

각 Camera는 Culling과 Rendering Resource를 요구한다.

```text
Main Camera
Mini-map Camera
Reflection Camera
UI World Camera
```

Camera별로 Shadow Map을 재사용하는지 다시 생성하는지는 Pipeline과 설정에 따라 달라질 수 있다.

Mini-map이나 보조 Camera에 동일한 Shadow 품질이 필요한지 확인한다.

Camera Stack, Render Type과 Renderer 구성을 Frame Debugger에서 확인해 Shadow Pass가 반복되는지 측정한다.

---

## Quality Level별 Shadow 예산

하나의 설정을 모든 Platform에 사용하지 않는다.

| 항목 | Low 방향 | Medium 방향 | High 방향 |
| --- | --- | --- | --- |
| Distance | 짧게 | 핵심 Gameplay 범위 | 주요 원거리까지 |
| Main Resolution | 낮게 | 중간 | 필요한 범위에서 높게 |
| Cascade | 최소 | 필요한 수 | 품질 기준 수 |
| Additional Shadow | 제한 | 중요 Light만 | 연출 Light 포함 |
| Soft Shadow | Off 또는 Low | Low·Medium | 품질 측정 후 Medium·High |
| Small Caster | 적극 제외 | 거리별 제외 | 중요한 Detail 유지 |

표는 고정 Preset이 아니라 방향을 설명한다.

Quality가 바뀔 때 Shadow가 갑자기 튀거나 Lighting 구성이 깨지지 않는지 확인한다.

---

## Scene 유형별 우선순위

### 실내

```text
우선 확인
├─ 작은 공간의 Additional Shadow Light 수
├─ Point Light를 Spot으로 변경 가능성
├─ Static Light Baking
└─ Room 단위 Light 활성화
```

Shadow Distance보다 Additional Light와 Occluded Room의 관리가 더 중요할 수 있다.

### 넓은 Outdoor

```text
우선 확인
├─ Shadow Distance
├─ Cascade Count와 Split
├─ Terrain / Foliage Caster
└─ Main Light Resolution
```

### Character 중심 Scene

```text
우선 확인
├─ Player 근거리 품질
├─ Skinned Mesh Caster 수
├─ Crowd의 LOD·Blob Shadow
└─ Contact 느낌을 유지할 최소 Distance
```

Scene 구조에 따라 가장 큰 비용 원인이 다르다.

---

## 최적화 적용 순서

큰 구조적 낭비부터 제거하고 미세 품질을 조절한다.

```text
1. Profiler로 CPU·GPU 병목 분류
2. 불필요한 Shadow Light 제거
3. Point Light Shadow와 여섯 Face 확인
4. 가치가 낮은 Caster·Receiver 제외
5. Shadow Distance를 필요한 범위로 축소
6. Cascade Count와 Split 조정
7. Main·Additional Resolution 조정
8. Soft Shadow Quality 조정
9. Baked·Shadowmask·Cookie·Proxy 검토
10. Target Device에서 재측정
```

이 순서는 일반적인 출발점이며 측정 결과에 따라 바뀔 수 있다.

예를 들어 Sampling 병목이 명확하면 Soft Shadow Quality를 먼저 낮추는 편이 효율적이다.

---

## 한 번에 하나씩 바꾼다

Distance, Resolution과 Cascade를 동시에 낮추면 성능은 좋아져도 무엇이 가장 효과적이었는지 알 수 없다.

```text
Baseline
└─ GPU 18.0 ms

Distance만 변경
└─ GPU 15.5 ms

Resolution만 변경
└─ GPU 14.8 ms

Cascade만 변경
└─ GPU 13.9 ms
```

각 변경마다 다음을 기록한다.

- CPU Main Thread와 Render Thread
- GPU Frame Time과 Shadow Pass
- Draw Call과 Caster 수
- Shadow Texture Memory
- Screenshot 또는 Video
- Artifact와 품질 손실

숫자와 화면을 함께 남겨야 되돌릴 기준이 생긴다.

---

## Frame Debugger에서 확인할 것

Frame Debugger는 ShadowCaster Pass가 어떤 순서와 Renderer로 실행되는지 보여 준다.

```text
Frame Events
├─ MainLightShadow
│  ├─ Cascade 0 Draws
│  ├─ Cascade 1 Draws
│  └─ ...
└─ AdditionalLightsShadowCaster
   ├─ Spot Light
   └─ Point Light Faces
```

다음을 확인한다.

- 예상하지 못한 Renderer가 Shadow를 만드는가?
- 같은 Mesh가 여러 Cascade에서 반복되는가?
- Shadow Point Light가 몇 Face를 Rendering하는가?
- Alpha Clipping Material이 대량 포함되는가?
- 보조 Camera에서 Shadow Pass가 반복되는가?

Frame Debugger는 개별 Event를 이해하는 도구이고 정확한 GPU 시간은 GPU Profiler로 확인한다.

---

## Unity Profiler와 GPU Profiler

Unity Profiler는 CPU·GPU Frame의 큰 흐름과 Rendering 통계를 확인하는 데 사용한다.

GPU Profiler, RenderDoc, Xcode GPU Tools와 Platform Vendor 도구는 Pass별 병목을 더 자세히 보여 줄 수 있다.

```text
Profiler 질문
├─ CPU가 GPU를 기다리는가?
├─ Render Thread가 병목인가?
├─ Main Shadow와 Additional Shadow 중 무엇이 큰가?
├─ Shadow Generation과 Receiver 중 무엇이 큰가?
└─ 변경 후 전체 Frame Time이 실제로 줄었는가?
```

Editor Overhead가 섞일 수 있으므로 Development Build와 Target Device에서 Profile한다.

---

## 최악의 장면을 측정한다

평균적인 빈 공간에서 통과한 설정이 전투와 숲에서도 유지된다는 보장은 없다.

```text
Worst Case
├─ Shadow Light가 가장 많은 전투
├─ Camera에 Caster가 가장 많이 보이는 위치
├─ Foliage가 밀집한 Outdoor
├─ Cascade 경계에 큰 Renderer가 몰린 구간
└─ 빠른 Camera 이동과 Light 활성화 순간
```

Average Frame Time뿐 아니라 Spike와 지속적인 발열 후 성능도 확인한다.

Mobile은 짧은 Test보다 Thermal Throttling이 발생하는 장시간 Test가 중요하다.

---

## 품질 회귀 체크리스트

성능이 좋아져도 다음 문제가 생기면 조정이 끝난 것이 아니다.

- Player Shadow가 발에서 분리됨
- Shadow Distance 경계가 Camera 앞에서 보임
- Cascade 전환선이 이동함
- 대각선 Edge가 심하게 계단짐
- Camera 이동 시 Shadow가 흔들림
- 얇은 Geometry에서 Light Leak 발생
- LOD 전환 시 Shadow가 Pop함
- Point Light를 Spot으로 바꾸며 Lighting 범위가 달라짐
- Baked와 Realtime Shadow가 이중으로 보임
- Quality Level 전환 시 Shadow가 갑자기 사라짐

고정 Screenshot, 이동 Video와 자동 Camera 경로를 함께 사용하면 회귀를 찾기 쉽다.

---

## 흔한 오해

### Resolution만 낮추면 Shadow 최적화가 끝난다

CPU Culling과 Draw가 병목이면 Resolution 감소 효과가 작을 수 있다.

Light, Face, Cascade와 Caster 수를 함께 확인해야 한다.

### Cast Shadows를 모두 끄면 가장 좋은 최적화다

Frame Time은 줄지만 접지감, 공간 인지와 Gameplay 정보가 사라질 수 있다.

중요도가 낮은 Caster부터 선별한다.

### Baked Shadow는 공짜다

Runtime Shadow Map 생성은 줄지만 Lightmap Texture Memory, Bandwidth와 Build Data 비용은 남는다.

### Soft Shadows는 항상 꺼야 한다

Platform에 따라 비쌀 수 있지만 낮은 Resolution과 조합해 더 적절한 품질·비용 균형을 만들 수도 있다.

### Point Light 하나는 Light 하나의 비용이다

Shadow는 여섯 방향 Capture가 필요하므로 Shadow View 관점에서는 Spot Light 여섯 개와 비교된다.

### Cascade를 줄이면 항상 빨라진다

반복 View는 줄지만 품질 보완을 위해 Resolution과 Distance를 올리면 전체 결과가 달라질 수 있다.

### Editor에서 빨라졌으면 최적화가 끝났다

Graphics API, Driver, Mobile GPU와 Thermal 상태가 다르므로 Target Device 측정이 필요하다.

### 평균 FPS만 보면 된다

Light 활성화, 빠른 Camera 이동과 밀집 전투에서 발생하는 Frame Spike도 사용자 경험을 해친다.

---

## 최종 점검표

```text
Light
□ Shadow Light가 모두 필요한가?
□ Point Shadow를 Spot·Baked·Cookie로 대체할 수 있는가?
□ 거리와 Room에 따라 Light를 끌 수 있는가?

Caster / Receiver
□ 작은 Caster를 제외했는가?
□ Foliage와 Skinned Mesh 비용을 확인했는가?
□ LOD와 Proxy를 사용할 수 있는가?
□ Shadow가 필요 없는 Receiver가 있는가?

Main Light
□ Distance가 필요한 최소 범위인가?
□ Cascade Count가 최소인가?
□ Split이 중요한 구간에 배치됐는가?
□ Resolution이 과도하지 않은가?

Additional Light
□ Atlas가 과도하게 크지 않은가?
□ Light별 Resolution Tier가 적절한가?
□ Point Light 여섯 Tile을 계산했는가?

Filtering
□ Soft Shadow Quality를 비교했는가?
□ Mobile·XR에서 실제 Sample 비용을 측정했는가?

검증
□ Frame Debugger로 반복 Draw를 확인했는가?
□ CPU와 GPU를 분리해 측정했는가?
□ Target Device의 최악 장면을 측정했는가?
□ 품질 회귀 Video를 확인했는가?
```

---

## 정리

Shadow 최적화는 CPU Culling과 Draw, GPU Shadow Map 생성과 Sampling, Texture Memory 중 실제 병목을 찾는 것에서 시작한다.

불필요한 Shadow Light를 제거하고 Point Light의 여섯 방향 비용을 먼저 확인하면 구조적인 낭비를 크게 줄일 수 있다.

시각적 가치가 낮은 Renderer의 Cast Shadows를 끄고 Foliage, Skinned Mesh와 작은 Caster에 거리·LOD 정책을 적용한다.

Shadow Distance는 Caster 범위와 Texel Density를, Cascade는 반복 View와 거리별 품질을, Resolution은 Texel·Memory 예산을 조절한다.

Additional Shadow Atlas는 Light별 Tier와 Point Light Tile 수를 기준으로 배분하고 Soft Shadow는 Platform별 Sampling 비용과 Art Style을 함께 비교한다.

Static 환경은 Baked Lighting과 Shadowmask, 고정된 가림 패턴은 Light Cookie, 작은 원거리 Object는 Blob Shadow와 Proxy Mesh로 대체할 수 있다.

한 번에 하나의 설정만 바꾸고 Frame Debugger, Unity Profiler와 GPU Profiler로 변경 전후를 기록해야 효과의 원인을 구분할 수 있다.

최종 판단은 Editor의 평균 FPS가 아니라 Target Device의 최악 장면에서 CPU·GPU Frame Time, Memory와 Shadow 품질을 함께 확인해 내려야 한다.
