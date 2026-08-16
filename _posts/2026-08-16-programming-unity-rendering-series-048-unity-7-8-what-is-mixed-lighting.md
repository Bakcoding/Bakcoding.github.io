---
title: "[Unity 렌더링] 7-8. Mixed Lighting은 무엇일까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - Lighting
  - MixedLighting
  - Shadowmask
permalink: /programming/unity-7-8-what-is-mixed-lighting/
toc: true
toc_sticky: true
date: 2026-08-16
last_modified_at: 2026-08-16
---

Mixed Lighting은 하나의 Light가 Realtime Lighting과 Baked Lighting을 함께 사용하도록 만드는 방식이다.

변하지 않는 Indirect Light와 Static Shadow는 미리 Bake하고, 움직이는 Object에 필요한 Direct Light와 Shadow는 Runtime에 계산할 수 있다.

```text
Mixed Light
├─ 사전 계산: Indirect GI / Static Occlusion
└─ Runtime:   Direct Light / Dynamic Shadow
```

Realtime의 동적 반응과 Baked Lighting의 성능·간접광 품질 사이에서 역할을 나누는 것이 핵심이다.

---

## 왜 Realtime과 Baked 사이가 필요할까?

완전한 Realtime Lighting은 Light와 Object 변화에 바로 반응하지만 Light Loop와 Shadow Map 비용이 크다.

완전한 Baked Lighting은 Runtime 비용이 낮지만 움직이는 Character와 Light 변화를 제대로 반영하지 못한다.

| 방식 | Static 환경 | Dynamic Object | Runtime 비용 | 변화 대응 |
| --- | --- | --- | --- | --- |
| Realtime | 매 Frame 계산 | 직접광·Shadow 가능 | 높음 | 높음 |
| Baked | Lightmap 사용 | Probe 중심 | 낮음 | 낮음 |
| Mixed | Baked와 Realtime 분담 | 직접광·Shadow 가능 | 중간 | 중간 |

게임 Scene은 고정된 건물과 움직이는 Character가 함께 있는 경우가 많다.

```text
고정된 벽과 바닥
└─ Baked GI와 Static Shadow

움직이는 Character
└─ Realtime Direct Light와 Dynamic Shadow
```

Mixed Lighting은 이 두 요구를 하나의 Lighting 구성 안에서 결합한다.

---

## Mixed Light는 무엇을 의미할까?

Unity Light Component의 Mode를 Mixed로 설정하면 해당 Light가 Bake와 Runtime 양쪽에 참여할 수 있다.

```text
Light Mode
├─ Realtime
├─ Mixed
└─ Baked
```

Mixed라는 이름만으로 어떤 성분이 Bake되는지는 결정되지 않는다.

Scene의 Lighting Settings Asset에서 선택한 Mixed Lighting Mode가 Direct, Indirect와 Shadow의 분담을 결정한다.

대표 Mode는 다음과 같다.

- Baked Indirect
- Shadowmask
- Subtractive

Unity API의 `MixedLightingMode.IndirectOnly`는 Editor UI의 Baked Indirect에 대응하는 개념이다.

---

## Lighting을 성분별로 나누기

Mixed Mode를 이해하려면 최종 Lighting을 세 부분으로 분리해야 한다.

```text
Final Lighting
├─ Direct Lighting
├─ Indirect Lighting
└─ Visibility / Shadow
```

Direct Lighting은 Light에서 Surface로 직접 도달한 빛이다.

Indirect Lighting은 다른 Surface에서 반사된 뒤 도달한 빛이다.

Shadow는 Light와 Surface 사이가 Geometry에 의해 가려졌는지를 나타낸다.

각 Mode는 이 세 항 중 무엇을 Bake하고 무엇을 Realtime으로 남길지 선택한다.

---

## Static Object와 Dynamic Object

Static Object는 Bake 당시 위치가 고정되어 Lightmap에 Surface별 결과를 저장할 수 있다.

Dynamic Object는 움직이므로 특정 Lightmap Texel의 결과를 계속 사용할 수 없다.

```text
Static Object
└─ Lightmap Sample

Dynamic Object
├─ Light Probe로 Baked Indirect Sample
└─ Realtime Direct Light와 Shadow
```

Mixed Lighting은 Static Receiver와 Dynamic Receiver에 서로 다른 데이터 경로를 사용한다.

따라서 같은 Light 아래에서도 두 Object의 Lighting Source가 완전히 같지는 않을 수 있다.

---

## Baked Indirect Mode

Baked Indirect는 Mixed Light의 Indirect Lighting만 Bake한다.

Direct Lighting과 Shadow는 Realtime으로 처리한다.

```text
Baked Indirect
├─ Direct Light   → Realtime
├─ Indirect Light → Baked
└─ Shadow         → Realtime
```

Static Object는 Lightmap에서 Baked Indirect를 받고 Dynamic Object는 Light Probe에서 Baked Indirect를 받는다.

두 종류 모두 Mixed Light의 Direct Lighting을 Runtime에 계산한다.

```text
Static
= Realtime Direct + Lightmap Indirect + Realtime Shadow

Dynamic
= Realtime Direct + Probe Indirect + Realtime Shadow
```

Light Color와 Intensity를 Runtime에 어느 정도 바꿔도 Direct Lighting은 바로 반응한다.

하지만 Bake된 Indirect Color는 자동으로 같은 변화에 맞춰 다시 계산되지 않는다.

---

## Baked Indirect의 장점과 비용

직접광과 Shadow가 Realtime이므로 Dynamic Object와 움직임에 자연스럽게 반응한다.

간접광은 Lightmap과 Probe에 저장해 Realtime GI 계산을 피한다.

하지만 Shadow Distance 안의 Shadow는 여전히 Shadow Map으로 Rendering한다.

```text
절감
└─ Indirect GI의 Runtime 계산

남는 비용
├─ Pixel Light BRDF
├─ ShadowCaster Pass
└─ Shadow Map Sample
```

Realtime Shadow가 많은 Scene에서는 Baked Indirect로 바꿔도 Shadow 비용이 크게 남을 수 있다.

---

## Shadowmask Mode

Shadowmask는 Direct Lighting을 Realtime으로 유지하고 Indirect Lighting을 Bake한다.

여기에 Static Object가 만드는 Baked Shadow Occlusion을 별도의 Shadowmask Texture와 Light Probe Occlusion에 저장한다.

```text
Shadowmask
├─ Direct Light       → Realtime
├─ Indirect Light     → Baked
├─ Static Occlusion   → Shadowmask / Probe
└─ Dynamic Shadow     → Realtime Shadow Map
```

Baked Indirect와 가장 큰 차이는 Static Shadow 정보를 사전 계산해 보존한다는 점이다.

Shadow Distance 밖에서도 고정된 건물과 지형의 Shadow를 보여 줄 수 있다.

---

## Shadowmask Texture에는 무엇이 저장될까?

Shadowmask는 Lightmap과 같은 UV Layout을 사용하는 Texture이며 Static Surface에서 Mixed Light가 가려지는 정도를 저장한다.

```text
Shadowmask Texel
R → Mixed Light A Occlusion
G → Mixed Light B Occlusion
B → Mixed Light C Occlusion
A → Mixed Light D Occlusion
```

RGBA 네 Channel을 사용하므로 같은 공간에서 겹치는 Mixed Light Occlusion은 최대 네 개 Channel에 할당된다.

다섯 개 이상의 Shadowmask Light가 겹치면 추가 Light가 기대한 Mixed 동작을 유지하지 못하고 Bake 처리로 넘어갈 수 있다.

Scene View와 Rendering Debugger의 Lighting Complexity를 이용해 중첩 영역을 확인한다.

---

## Shadowmask는 Shadow Color를 저장할까?

Shadowmask는 최종 Color Texture가 아니라 Light별 Occlusion 비율을 저장한다.

```text
0 → Light가 가려짐
1 → Light가 보임
```

Runtime Shader는 Realtime Direct Light에 해당 Occlusion을 곱한다.

```text
Direct Light Contribution
× Baked Occlusion
= Static Shadow가 반영된 Direct Light
```

Light Color를 Runtime에 바꾸면 Direct Light Color는 바뀔 수 있지만 간접광은 Bake 당시 색을 유지한다.

Occlusion만 저장하므로 Static과 Dynamic Shadow를 조합하기 쉽다.

---

## Shadowmask Quality Mode

Lighting Settings에서 Shadowmask를 선택한 뒤 Quality Settings에서 Runtime 동작을 다시 선택할 수 있다.

```text
Shadowmask Mode
├─ Shadowmask
└─ Distance Shadowmask
```

두 설정은 Camera와 Shadow Distance를 기준으로 Realtime Shadow와 Baked Occlusion을 어떻게 사용할지 다르다.

---

## Shadowmask 방식

일반 Shadowmask 설정에서는 Static Object가 만드는 Shadow에 Baked Occlusion을 적극적으로 사용한다.

Dynamic Object의 Shadow는 Shadow Distance 안에서 Realtime Shadow Map으로 처리한다.

```text
Static Caster → Baked Shadowmask
Dynamic Caster → Realtime Shadow Map
```

Static Caster를 Shadow Map에 다시 Rendering하는 부담을 줄일 수 있어 중저사양 Platform에 유리할 수 있다.

하지만 가까운 거리의 Static Shadow도 Bake된 해상도와 위치를 사용하므로 Realtime Shadow보다 Detail과 변화 대응이 제한된다.

---

## Distance Shadowmask 방식

Distance Shadowmask는 Shadow Distance 안에서 Realtime Shadow를 사용하고 그 밖에서 Baked Shadow로 전환한다.

```text
Camera
  │
  ├─ Near, Shadow Distance 안
  │  └─ Realtime Shadow
  │
  └─ Far, Shadow Distance 밖
     └─ Baked Shadowmask
```

가까운 Dynamic·Static Shadow 품질을 높이고 먼 거리에도 Shadow를 유지할 수 있다.

대신 가까운 Static Caster까지 Shadow Map에 Rendering하므로 일반 Shadowmask보다 성능 비용이 높을 수 있다.

중상급 Hardware와 넓은 시야의 Scene에서 품질상 유리하다.

---

## Shadow Distance 경계

Realtime Shadow에서 Baked Shadow로 갑자기 바뀌면 경계가 보일 수 있다.

```text
Near Realtime ── Blend 영역 ── Far Baked
```

Bake 당시 Light와 Geometry 상태가 현재 Runtime과 같아야 두 Shadow가 자연스럽게 이어진다.

Light 방향을 크게 바꾸거나 Static Object를 이동하면 Realtime과 Baked Shadow 모양이 달라져 전환이 드러난다.

Mixed Light의 Runtime 변경 범위를 제한해야 하는 이유다.

---

## Dynamic Object의 Shadowmask Lighting

Dynamic Object는 Lightmap UV가 없으므로 Shadowmask Texture를 직접 사용하지 않는다.

Light Probe에 저장된 Occlusion 정보를 이용해 Static Geometry가 해당 Mixed Light를 가리는 정도를 얻을 수 있다.

```text
Dynamic Object
├─ Probe Indirect Lighting
├─ Probe Occlusion for Static Shadow
└─ Realtime Shadow for Dynamic Caster
```

Probe가 부족하거나 벽 양쪽의 값이 부정확하게 보간되면 Dynamic Object가 빛을 받지 말아야 할 곳에서 밝아질 수 있다.

Shadowmask 품질은 Light Probe 배치와도 연결된다.

---

## Subtractive Mode

Subtractive는 저사양 Hardware를 위한 단순한 Mixed Lighting Mode다.

Static Object의 Direct와 Indirect Lighting을 Lightmap에 Bake한다.

Dynamic Object는 Realtime Direct Light와 Light Probe Lighting을 받는다.

```text
Subtractive

Static
├─ Direct Light   → Baked
├─ Indirect Light → Baked
└─ Static Shadow  → Baked

Dynamic
├─ Direct Light   → Realtime
├─ Indirect Light → Probe
└─ Shadow         → 제한된 Realtime 처리
```

Scene의 Main Directional Light를 중심으로 Dynamic Object가 Static Surface에 만드는 Shadow를 단순하게 결합할 수 있다.

다른 Mode보다 비용은 낮지만 Light 수와 Shadow 표현에 제약이 크고 Static·Dynamic Object의 밝기 차이가 보이기 쉽다.

---

## 세 Mode 비교

| Mode | Static Direct | Indirect | Static Shadow | Dynamic Direct |
| --- | --- | --- | --- | --- |
| Baked Indirect | Realtime | Baked | Realtime | Realtime |
| Shadowmask | Realtime | Baked | Baked Occlusion 활용 | Realtime |
| Subtractive | Baked | Baked | Baked | Realtime 중심 |

```text
품질과 동적 반응
Baked Indirect / Distance Shadowmask 쪽이 높음

Runtime 비용 절감
Subtractive / Shadowmask 쪽이 유리할 수 있음
```

Scene, Platform과 Shadow 요구에 따라 결과가 달라지므로 이름만으로 선택하지 않는다.

---

## Light를 움직이면 어떻게 될까?

Mixed Light의 Realtime Direct 성분은 Transform, Color와 Intensity 변화에 반응할 수 있다.

하지만 Baked Indirect와 Static Occlusion은 Bake 당시 상태로 남는다.

```text
Light 이동
├─ Realtime Direct / Shadow → 새 위치 반영
└─ Baked GI / Shadowmask    → 이전 위치 유지
```

작은 Intensity 변화는 눈에 덜 띌 수 있지만 Light 방향과 위치를 크게 바꾸면 Direct와 Indirect가 모순된다.

완전히 움직이는 Light는 Realtime Mode가 더 적합하다.

Mixed는 `조금 바꿀 수 있는 Baked Light`가 아니라 어떤 성분을 고정할지 의도적으로 나누는 방식이다.

---

## Static Object를 움직이면 생기는 문제

Contribute GI로 Bake된 Object를 Runtime에 이동하면 Lightmap Shadow와 Shadowmask에는 이전 위치가 남는다.

```text
Bake: 문이 닫힘
Runtime: 문이 열림

결과: 닫힌 문의 Baked Shadow가 남을 수 있음
```

움직일 가능성이 있는 문, 엘리베이터와 파괴 Object는 Static Bake 대상에서 제외하거나 여러 상태를 별도로 설계한다.

Realtime Shadow만으로 해결해도 Baked Indirect에 남은 어두움이 사라지지는 않는다.

---

## Mixed Lighting의 Shader 결합

URP Lit Shader는 Realtime Light의 Shadow Attenuation과 Baked Shadow Mask를 결합해 Light Visibility를 계산한다.

개념적으로 다음과 같다.

```text
Light Attenuation
= Distance Attenuation
 × Realtime Shadow
 × 또는 Blend된 Baked Occlusion
```

`InputData`에는 Baked GI와 Shadow Mask Data가 전달될 수 있다.

```hlsl
half3 bakedGI;
half4 shadowMask;
```

실제 결합은 Mixed Mode, Shadow Distance, Light Channel과 Shader Keyword에 따라 달라진다.

Custom Lit Shader가 Shadow Mask와 Probe Occlusion 경로를 빠뜨리면 기본 URP Lit과 다른 결과가 나온다.

---

## 성능 비용

Mixed Lighting은 Realtime과 Baked 양쪽의 일부 비용을 가진다.

```text
Runtime Cost
├─ Realtime Direct Light BRDF
├─ 필요한 Realtime Shadow
├─ Lightmap / Probe Sample
├─ Shadowmask Texture Sample
└─ Shadow Blend Logic

Offline / Memory Cost
├─ Bake Time
├─ Lightmap
├─ Shadowmask Texture
└─ Probe Occlusion Data
```

Shadowmask가 Realtime Shadow Caster를 줄여도 추가 Texture Memory와 Sample이 필요하다.

Distance Shadowmask는 가까운 Shadow Map과 먼 Baked Shadow를 모두 관리한다.

---

## Shadowmask 중첩을 관리하는 방법

한 영역에 Shadow를 만드는 Mixed Light가 네 개 이상 겹치지 않도록 Range를 조절한다.

```text
나쁜 구성
작은 방 하나에 Shadow Mixed Light 7개 중첩

개선
├─ 핵심 Light만 Shadow
├─ 장식 Light는 No Shadows
├─ Range 축소
└─ 일부 Light는 완전 Baked
```

Light Explorer로 Mixed와 Shadow 설정을 한 번에 확인한다.

Scene View의 Shadowmask Mode와 Rendering Debugger의 Lighting Complexity로 Channel 사용과 Light 중첩을 검사한다.

---

## Mode 선택 기준

### Baked Indirect

Light 변화와 모든 Shadow의 Realtime 품질이 중요하고 Shadow 비용을 감당할 수 있는 경우에 적합하다.

### Distance Shadowmask

가까운 고품질 Realtime Shadow와 먼 거리 Static Shadow가 모두 필요한 넓은 Scene에 적합하다.

### Shadowmask

Static Caster의 Realtime Shadow 비용을 줄이면서 Dynamic Shadow를 유지하려는 중저사양 Target에 유리할 수 있다.

### Subtractive

Light와 Shadow 요구가 단순하고 매우 낮은 Runtime 비용이 중요한 환경에 적합하다.

```text
선택 질문
├─ Light가 움직이는가?
├─ Dynamic Object Shadow가 필요한가?
├─ 먼 거리 Shadow가 필요한가?
├─ Static Caster가 많은가?
├─ Lightmap Memory Budget은 충분한가?
└─ Target GPU의 Shadow Budget은 얼마인가?
```

---

## 디버깅 순서

```text
1. Light Mode가 Mixed인지 확인
2. Scene Lighting Settings의 Mixed Mode 확인
3. Quality Settings의 Shadowmask Mode 확인
4. Object의 Contribute GI 확인
5. Lightmap과 Shadowmask Bake 여부 확인
6. Light Probe와 Occlusion 배치 확인
7. Shadow Distance 확인
8. Realtime과 Baked Shadow를 분리해 확인
```

Editor Quality Level과 Build Platform이 서로 다른 Quality Setting을 사용할 수 있으므로 실제 실행 환경을 확인한다.

Frame Debugger에서 Shadow Pass와 Lightmap Variant를 보고 Scene View의 Baked GI Debug Mode에서 Shadowmask를 확인한다.

---

## 자주 생기는 문제

### 먼 거리에서 Shadow가 사라진다

Baked Indirect는 Shadow Distance 밖의 Shadow를 미리 저장하지 않는다.

Shadowmask Mode와 Bake Data를 검토한다.

### Shadowmask를 사용했는데 Light 하나가 다르게 보인다

같은 영역에 네 개를 넘는 Shadow Mixed Light가 겹쳐 Channel 할당 한계를 초과했을 수 있다.

### Character가 벽 뒤에서도 밝다

Light Probe가 벽 양쪽을 가로질러 부정확하게 보간되거나 Probe Occlusion Data가 부족할 수 있다.

### Light Color를 바꿨더니 간접광 색이 맞지 않는다

Realtime Direct는 변경됐지만 Baked Indirect는 이전 Bake Color를 유지한다.

다시 Bake하거나 완전 Realtime Light를 사용한다.

### 가까운 Shadow와 먼 Shadow 경계가 보인다

Bake 상태와 Runtime Light Transform이 다르거나 Resolution과 Bias 차이가 클 수 있다.

Shadow Distance와 전환 영역도 확인한다.

### Static Object가 움직인 자리에 Shadow가 남는다

Lightmap과 Shadowmask는 Bake 시점 Geometry를 저장하므로 움직일 Object를 Static Bake 대상에서 제외해야 한다.

---

## 최적화 관점

### Static Caster를 Baked Occlusion으로 전환한다

움직이지 않는 복잡한 환경 Geometry는 Shadowmask로 ShadowCaster Pass 반복을 줄일 수 있다.

### Shadow Distance를 제한한다

Distance Shadowmask와 Baked Indirect의 Realtime Shadow 범위를 시각적으로 필요한 거리까지만 둔다.

### Shadow Mixed Light 수를 줄인다

RGBA Channel 제한과 Realtime Shadow 비용을 고려해 중요한 Light만 Shadow를 사용한다.

### Light Probe를 함께 설계한다

Dynamic Object가 Baked Indirect와 Static Occlusion을 자연스럽게 받도록 공간 변화 지점에 Probe를 배치한다.

### Quality Tier를 분리한다

상위 Platform은 Distance Shadowmask, 하위 Platform은 Shadowmask 또는 단순한 Mode를 사용할 수 있다.

### 실제 Pass를 측정한다

Shadowmask Texture가 늘어난 Memory 비용과 줄어든 ShadowCaster GPU 시간을 함께 비교한다.

한쪽 지표만 보고 최적화 성공을 판단하지 않는다.

---

## 흔한 오해

### Mixed는 Realtime과 Baked 결과를 절반씩 섞는다

각 Mode가 Direct, Indirect와 Shadow의 역할을 명확히 나눈다.

단순한 50% Blend가 아니다.

### Shadowmask에는 최종 Shadow Color가 저장된다

Light별 Occlusion을 RGBA Channel에 저장하고 Runtime Direct Light에 적용한다.

### Mixed Light는 자유롭게 움직여도 된다

Baked GI와 Static Occlusion은 Bake 시점에 고정되므로 큰 변화는 불일치를 만든다.

### Shadowmask면 Realtime Shadow가 전혀 없다

Dynamic Object Shadow와 Distance Shadowmask의 가까운 Shadow는 Realtime Shadow Map을 사용할 수 있다.

### Mixed Lighting은 항상 Baked보다 빠르다

Realtime Direct, 일부 Shadow, Lightmap과 Shadowmask Sample이 함께 남는다.

완전 Baked보다 비싸지만 필요한 동적 반응을 얻는 절충안이다.

---

## 전체 처리 흐름

```text
Editor Bake
Mixed Light + Static Geometry
              │
              ├─ Indirect GI → Lightmap / Probe
              └─ Static Occlusion → Shadowmask / Probe
              │
──────────── Runtime ────────────
              │
Realtime Mixed Light
├─ Direction / Color / Intensity
├─ Direct Diffuse / Specular
└─ Dynamic Shadow Map
              │
              ├───────────────┐
              ▼               ▼
Static Object             Dynamic Object
Lightmap GI               Probe GI
Shadowmask                Probe Occlusion
              │               │
              └───────┬───────┘
                      ▼
Realtime Direct × Combined Shadow
        + Baked Indirect
                      │
                      ▼
                 Final Lighting
```

Mixed Lighting의 핵심은 어떤 값이 Bake Data에 고정되고 어떤 값이 Runtime에 갱신되는지 구분하는 것이다.

---

## 정리

Mixed Lighting은 Realtime Direct Lighting과 Baked GI·Shadow Data를 함께 사용해 동적 반응과 Runtime 성능을 절충한다.

Light Component를 Mixed로 설정한 뒤 Scene의 Lighting Settings에서 Baked Indirect, Shadowmask 또는 Subtractive Mode를 선택한다.

Baked Indirect는 Indirect Lighting만 Lightmap과 Probe에 Bake하고 Direct Light와 모든 Shadow를 Realtime으로 처리한다.

Shadowmask는 Realtime Direct와 Baked Indirect에 Static Occlusion을 저장한 Shadowmask Texture와 Probe Occlusion을 추가한다.

Shadowmask Texture는 RGBA Channel에 최대 네 개의 겹치는 Mixed Light Occlusion을 저장한다.

일반 Shadowmask는 Static Caster의 Baked Shadow를 적극적으로 사용해 비용을 줄이고 Dynamic Caster는 Realtime Shadow로 처리한다.

Distance Shadowmask는 Shadow Distance 안에서 Realtime Shadow, 밖에서 Baked Shadow를 사용해 가까운 품질과 먼 거리 Shadow를 함께 유지한다.

Subtractive는 Static Object의 Direct·Indirect Lighting을 Bake해 낮은 비용을 목표로 하지만 Dynamic Object와 Shadow 표현의 제약이 크다.

Dynamic Object는 Lightmap 대신 Light Probe의 Baked Indirect와 Occlusion을 사용하므로 Probe 배치가 Lighting 품질에 중요하다.

Mixed Light를 크게 움직이거나 색을 바꾸면 Realtime Direct와 Bake 당시 Indirect·Shadow가 서로 맞지 않을 수 있다.

Mode 선택은 Shadow 품질뿐 아니라 ShadowCaster GPU 비용, Lightmap·Shadowmask Memory, Light 중첩과 Target Hardware를 함께 고려해야 한다.
