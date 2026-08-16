---
title: "[Unity 렌더링] 7-9. Light Probe는 왜 필요할까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - Lighting
  - LightProbe
  - BakedGI
permalink: /programming/unity-7-9-why-light-probes-are-needed/
toc: true
toc_sticky: true
date: 2026-08-16
last_modified_at: 2026-08-16
---

Light Probe는 Scene의 특정 공간 지점에 Baked Lighting을 저장해 움직이는 Object가 간접광을 받을 수 있도록 한다.

Static Object는 Surface마다 Lightmap을 사용하지만 Dynamic Object는 위치가 바뀌므로 고정된 Lightmap UV를 사용할 수 없다.

```text
Static Object  → Lightmap
Dynamic Object → Light Probe
```

Unity는 Dynamic Object 주변 Probe의 Lighting을 보간하고 Object의 Shader에 전달한다.

---

## Lightmap만으로 부족한 이유

Lightmap은 Bake 당시 고정된 Mesh Surface와 UV에 Lighting을 기록한다.

```text
Lightmap Texel
└─ 특정 Static Surface 위치의 Lighting
```

Character가 방 안을 이동하면 매 Frame 위치가 달라진다.

한 Lightmap Texel에 연결할 수 없고 Character 전용 Lightmap을 만들더라도 이동 후 Scene Lighting과 맞지 않는다.

```text
Bake 위치 A의 밝기
      │ Character 이동
      ▼
위치 B에서 그대로 사용 → 공간 Lighting 불일치
```

Light Probe는 Surface가 아니라 공간에 Lighting Sample Point를 둬 이 문제를 해결한다.

---

## Light Probe란?

Light Probe는 한 지점으로 들어오는 Baked Light의 방향과 색을 압축해 저장한 Sample이다.

```text
         위쪽 빛
            ↓
왼쪽 빛 →  ●  ← 오른쪽 빛
            ↑
         아래쪽 빛
```

단순한 RGB 한 값만 저장하면 모든 방향의 Surface가 같은 밝기를 받는다.

Probe는 방향 정보를 포함하므로 Object Normal에 따라 다른 간접광을 계산할 수 있다.

```text
위쪽 Normal   → 천장과 Sky 방향 Lighting
옆쪽 Normal   → 벽 방향 Lighting
아래쪽 Normal → 바닥 방향 Lighting
```

---

## 무엇을 저장할까?

일반적인 Light Probe는 저주파 간접광을 Spherical Harmonics 계수로 저장한다.

```text
Light Probe Data
├─ Baked Indirect Diffuse
├─ 방향별 저주파 Lighting
└─ Mixed Shadowmask용 Occlusion 가능
```

Light Probe는 선명한 Reflection Image나 고해상도 Shadow Texture를 저장하지 않는다.

| 데이터 | 담당 시스템 |
| --- | --- |
| Static Surface Diffuse GI | Lightmap |
| Dynamic Object Diffuse GI | Light Probe / APV |
| Environment Specular | Reflection Probe / Skybox |
| Realtime Direct Shadow | Shadow Map |

---

## Spherical Harmonics란?

Spherical Harmonics는 구면 방향의 부드러운 Lighting을 적은 계수로 근사하는 표현 방식이다.

```text
모든 방향의 복잡한 Light
          │ 저주파 근사
          ▼
   소수의 SH Coefficients
```

Diffuse Indirect Lighting은 방향 변화가 비교적 부드러워 저주파 표현에 적합하다.

Shader는 World Normal을 사용해 해당 방향의 Probe Lighting을 평가한다.

```hlsl
real3 bakedDiffuse = SampleSH(normalWS);
```

함수와 Data 전달 경로는 URP Version과 Probe System에 따라 달라질 수 있다.

SH는 작은 Light Source의 날카로운 Shadow와 Mirror Reflection을 정확하게 표현하는 방식은 아니다.

---

## Probe 하나만 사용하면 될까?

Scene Lighting은 위치마다 다르다.

창가, 방 중앙과 복도 안쪽은 서로 다른 간접광을 가진다.

```text
Window             Room Interior
밝고 푸른 빛       어둡고 따뜻한 빛
●───────────────●
```

Probe 하나만 사용하면 넓은 공간 전체가 같은 Lighting을 받는다.

여러 위치에 Probe를 배치하고 Object 위치에서 값을 보간해야 부드러운 공간 변화를 표현할 수 있다.

---

## Probe는 어떻게 보간될까?

Unity는 Light Probe 위치를 Delaunay Tetrahedralization으로 연결한다.

3D 공간을 네 개 Probe가 꼭짓점인 Tetrahedron으로 나눈다.

```text
          P1
          ●
         /|\
        / | \
      P2──┼──P3
        \ | /
         \|/
          ● P4
```

Dynamic Object가 들어 있는 Tetrahedron을 찾고 네 꼭짓점 Probe Data를 위치에 따라 보간한다.

```text
Interpolated Lighting
= P1 × w1
 + P2 × w2
 + P3 × w3
 + P4 × w4

w1 + w2 + w3 + w4 = 1
```

Object가 이동하면 보간 Weight가 바뀌어 Lighting도 부드럽게 변한다.

---

## Object의 어느 위치에서 Sample할까?

Renderer는 보통 Bounds와 Probe Anchor를 기준으로 Light Probe 위치를 결정한다.

```text
Large Character Bounds
┌──────────────┐
│      ●       │ ← Probe Anchor
└──────────────┘
```

Anchor가 바닥 아래나 벽 반대편에 있으면 Object 전체가 잘못된 공간 Lighting을 받을 수 있다.

Renderer의 Probe Anchor에 별도 Transform을 지정해 몸통 중심이나 실제 Lighting을 대표하는 위치로 옮길 수 있다.

큰 Renderer 하나가 여러 방을 가로지르면 Sample Point 하나만으로 전체 Surface를 표현하기 어렵다.

---

## Blend Probes와 Proxy Volume

일반적인 `Blend Probes`는 Object 기준으로 보간된 Probe Data 하나를 Renderer에 전달한다.

작은 Dynamic Object에는 충분하지만 큰 Object에서는 위와 아래, 좌우 Lighting 차이를 표현하지 못한다.

```text
큰 Object
┌─────────────────┐
│ 밝은 공간 │ 어두운 공간 │
└─────────────────┘

Probe Sample 하나 → 전체가 같은 간접광
```

Light Probe Proxy Volume은 Object 주변 Volume에 여러 Probe Sample을 배치해 Renderer 내부 위치별 Lighting을 근사한다.

품질은 좋아지지만 추가 Volume Data와 Shader Sample 비용이 발생한다.

---

## Light Probe Group

전통적인 Light Probe는 `Light Probe Group` Component를 사용해 수동으로 배치한다.

```text
Light Probe Group
├─ Local Probe Position 0
├─ Local Probe Position 1
├─ Local Probe Position 2
└─ ...
```

Group Transform은 Editor 배치와 Bake에 사용된다.

Runtime에 단순히 Transform을 옮기는 것만으로 내부 Probe Data와 Tetrahedron이 자동 갱신되는 것은 아니다.

Scene Loading과 Runtime 이동에서는 LightProbes API와 재사면체화가 필요할 수 있다.

---

## 어디에 Probe를 배치할까?

Object가 실제로 이동하는 공간에 Probe를 배치한다.

```text
권장 영역
├─ Character 이동 경로
├─ 방과 복도
├─ 문과 창문 주변
├─ 계단과 높이 변화
├─ 밝음과 어두움 경계
└─ 서로 다른 색의 간접광 경계
```

아무 Object도 접근하지 않는 천장 위와 벽 내부에 Probe를 촘촘히 둘 필요는 없다.

Probe 수보다 Lighting 변화에 맞는 위치가 중요하다.

---

## 밝기 경계에는 왜 더 필요할까?

Probe 보간은 두 지점 사이 값을 부드럽게 섞는다.

벽 양쪽에 Probe만 있고 벽 가까이에 중간 Sample이 없으면 빛이 벽을 통과한 것처럼 보간될 수 있다.

```text
밝은 방       벽       어두운 방
  ● ───────── │ ───────── ●
       보간이 벽을 가로지를 수 있음
```

문, 벽과 층처럼 Lighting이 불연속적으로 바뀌는 경계 양쪽에 Probe를 배치한다.

```text
밝은 방     벽      어두운 방
 ●  ●       │       ●  ●
경계 값을 각각 제어
```

Probe는 Geometry Occlusion을 Runtime에 새로 이해하지 않고 Bake된 Sample을 공간적으로 보간한다.

---

## 높이 방향 배치

바닥 높이에 한 층으로만 Probe를 두면 Character의 상체와 공중 Object를 대표하지 못한다.

```text
천장          ●

Character     ●

바닥          ●
```

점프, 계단, 비행 Object와 높은 Character가 있다면 실제 Bounds 높이를 포함하도록 여러 층을 둔다.

너무 규칙적인 Dense Grid보다 이동 공간과 Lighting 변화에 맞는 높이 배치가 효율적이다.

---

## Probe가 Geometry 안에 있으면 어떻게 될까?

Probe가 벽, 바닥 또는 Prop 내부에 있으면 거의 모든 방향이 막혀 지나치게 어두운 Data가 Bake될 수 있다.

그 값이 주변 Object에 보간되면 이유 없이 검게 보인다.

```text
Wall
████●████  ← Geometry 내부 Probe
```

Scene View에서 Probe 위치를 확대해 확인하고 Surface에서 적절히 떨어뜨린다.

얇은 벽과 겹친 Probe는 반대편 Light Leak 원인이 되기도 한다.

---

## Mixed Lighting과 Probe Occlusion

Shadowmask Mode에서는 Light Probe에 Static Object가 Mixed Light를 가리는 정보도 저장할 수 있다.

Dynamic Object는 이 Occlusion을 사용해 벽 뒤의 Mixed Light가 가려진 상태를 근사한다.

```text
Dynamic Object Lighting
├─ Probe Baked Indirect
├─ Probe Mixed Light Occlusion
└─ Realtime Direct / Dynamic Shadow
```

Probe가 벽 양쪽을 잘 구분하지 못하면 Character가 벽 뒤에서도 밝아질 수 있다.

Mixed Lighting에서 Probe 배치는 간접광뿐 아니라 Static Shadow 연결에도 중요하다.

---

## Realtime Light와 함께 사용할 수 있을까?

Light Probe는 주로 Baked Indirect Diffuse를 제공한다.

Realtime Light의 Direct Diffuse·Specular와 Shadow는 별도로 더할 수 있다.

```text
Dynamic Lit Object
= Probe Indirect Diffuse
 + Realtime Direct Diffuse
 + Realtime Direct Specular
 + Reflection Probe
 + Emission
```

Probe가 Realtime Light Loop를 완전히 대체하는 것은 아니다.

움직이는 손전등과 Character Shadow가 필요하면 Realtime 또는 Mixed Light가 남는다.

---

## Reflection Probe와 무엇이 다를까?

이름은 비슷하지만 저장하는 빛과 Sample 방식이 다르다.

| 구분 | Light Probe | Reflection Probe |
| --- | --- | --- |
| 주 역할 | Indirect Diffuse | Indirect Specular |
| 데이터 | SH 계수 | Cubemap |
| 주요 입력 | Surface Normal | Reflection Vector, Roughness |
| 대상 | Dynamic Object의 Baked GI | 매끄러운 표면과 금속 반사 |

Light Probe만 있으면 Character의 어두운 면은 자연스러워져도 Armor의 Environment Reflection은 부족할 수 있다.

두 Probe System은 서로 보완한다.

---

## Adaptive Probe Volume과 차이

Adaptive Probe Volume은 Scene Volume을 분석해 Probe를 더 자동화된 구조로 배치하고 Brick과 Cell 단위로 관리하는 방식이다.

```text
Light Probe Group
└─ 개발자가 Point를 수동 배치

APV
└─ Volume 안에 적응형 Probe 구조 생성
```

큰 Scene, Streaming과 Lighting Scenario에서는 APV가 관리에 유리할 수 있다.

전통적인 Light Probe Group은 단순한 Scene과 수동 제어에 여전히 이해하기 쉽다.

URP Asset과 Platform 지원, Memory와 Bake Workflow를 기준으로 선택한다.

---

## Additive Scene Loading

여러 Scene을 Additive로 Load하거나 Unload하면 전체 Probe 위치 집합이 달라진다.

Tetrahedron 연결을 다시 계산해야 새 Scene Probe와 기존 Probe 사이의 보간이 올바르게 동작한다.

```csharp
LightProbes.TetrahedralizeAsync();
```

재사면체화는 CPU 비용이 큰 작업일 수 있다.

여러 Scene을 연속으로 Load할 때마다 호출하기보다 필요한 Scene 변경이 끝난 뒤 한 번 수행하는 구조를 검토한다.

동기 호출은 Frame Hitch를 만들 수 있으므로 비동기 API와 Loading 구간을 활용한다.

---

## Runtime에 Probe를 이동할 때

Light Probe Group Transform을 움직이는 것만으로 Runtime Probe 위치가 갱신되지 않는다.

LightProbes API로 Position을 갱신하고 Tetrahedralize 또는 비동기 버전을 호출해야 한다.

```text
Probe Position 변경
        │
        ▼
전체 위치 Data Update
        │
        ▼
Tetrahedralize
        │
        ▼
새 보간 구조 사용
```

Probe Lighting 자체는 Bake된 Data이므로 Geometry와 Light가 바뀌었다면 위치만 이동해도 물리적으로 맞지 않을 수 있다.

---

## Light Probe의 한계

### 저주파 Lighting이다

작은 창살 Shadow와 날카로운 Light Pattern은 SH로 정확히 표현하기 어렵다.

### Object별 Sample이 제한될 수 있다

큰 Renderer는 공간 전체의 Lighting 변화를 하나의 Probe 값으로 표현하기 어렵다.

### Geometry 경계를 자동으로 차단하지 않는다

Tetrahedron이 벽을 가로지르면 밝은 값이 어두운 방으로 보간될 수 있다.

### Baked Data다

Light와 Scene이 크게 바뀌어도 Probe Data는 다시 Bake하기 전까지 갱신되지 않는다.

### 배치와 Memory 관리가 필요하다

Probe가 너무 적으면 품질이 낮고 너무 많으면 Bake Data, CPU 보간 구조와 관리 비용이 증가한다.

---

## 자주 생기는 문제

### Dynamic Object가 검게 보인다

Object 주변에 Probe가 없거나 Bounds가 Probe Hull 밖에 있을 수 있다.

Renderer의 Light Probe Usage와 Anchor도 확인한다.

### 문을 통과할 때 밝기가 이상하게 섞인다

문 양쪽의 Lighting 차이를 잡아 줄 Probe가 부족할 수 있다.

경계 양쪽에 Probe를 추가하고 Tetrahedron 연결을 확인한다.

### Object 전체가 한쪽 색으로 물든다

큰 Renderer가 Probe Sample 하나만 사용하고 있을 수 있다.

Mesh 분할, Anchor 조정 또는 Light Probe Proxy Volume을 검토한다.

### Probe를 추가했는데 변화가 없다

Lighting을 다시 Bake하지 않았거나 Runtime Tetrahedralization이 갱신되지 않았을 수 있다.

### Static Object는 자연스럽지만 Character만 떠 보인다

Lightmap과 Probe의 Sample 밀도와 위치가 다르거나 Reflection Probe가 부족할 수 있다.

같은 위치의 Static Reference와 Dynamic Object를 비교한다.

---

## 디버깅 순서

```text
1. Renderer의 Light Probe Usage 확인
2. Probe Anchor 위치 확인
3. Object가 Probe Hull 안에 있는지 확인
4. Probe가 Geometry 내부인지 확인
5. 밝기 경계 양쪽의 Probe 밀도 확인
6. Tetrahedron 연결 확인
7. Baked Data 재생성
8. Direct Light와 Reflection을 분리해 확인
```

Scene View에서 Probe를 선택하면 각 지점의 Baked Color와 연결 구조를 확인할 수 있다.

Lighting Debug View로 Lightmap과 Probe 결과를 비교하고 Material의 Metallic과 Reflection 영향을 잠시 제거하면 Diffuse GI 문제를 분리하기 쉽다.

---

## 최적화 관점

### 변화가 큰 곳에 집중한다

균일한 야외에 Dense Grid를 만들기보다 문, 창, 코너와 층 변화에 Probe를 집중한다.

### 이동 가능 영역만 채운다

Character와 Dynamic Prop이 도달하지 않는 공간의 Probe는 줄인다.

### 큰 Renderer를 점검한다

큰 Dynamic Mesh 하나가 넓은 Lighting 영역을 가로지르면 Proxy Volume 또는 Mesh 분할 비용을 비교한다.

### Additive Load 시 재사면체화를 관리한다

Scene마다 동기 호출해 Hitch를 만들지 않고 Loading 완료 후 비동기 갱신을 검토한다.

### APV와 비교한다

대규모 Scene에서 수동 Probe가 지나치게 많아지면 APV의 Cell Streaming과 자동 배치를 평가한다.

### Profile한다

Probe 수가 늘어도 GPU Lighting 비용보다 Bake Data Memory, CPU Tetrahedralization과 Loading 비용이 먼저 문제가 될 수 있다.

---

## 흔한 오해

### Light Probe는 작은 Light다

빛을 방출하는 Component가 아니라 특정 위치의 Baked Lighting을 기록하는 Sample Point다.

### Probe가 많을수록 항상 정확하다

Geometry 경계를 고려하지 않은 Dense Grid는 Light Leak을 해결하지 못하고 Data만 늘릴 수 있다.

### Light Probe가 Realtime Shadow를 만든다

Probe는 저주파 Baked Lighting과 일부 Mixed Occlusion을 제공한다.

움직이는 Object의 선명한 Shadow는 Shadow Map 같은 Realtime 방식이 필요하다.

### Light Probe와 Reflection Probe는 같다

Light Probe는 Diffuse GI, Reflection Probe는 Cubemap 기반 Specular Reflection을 담당한다.

### Group Transform을 움직이면 Runtime Probe도 바로 이동한다

Runtime Probe 위치와 Tetrahedralization은 별도 API로 갱신해야 한다.

---

## 전체 처리 흐름

```text
Editor
Baked / Mixed Light + Static Geometry
                    │
                    ▼
             Light Probe Bake
각 Probe Position의 방향별 Indirect Light
                    │
                    ▼
              SH Data 저장
                    │
             Tetrahedralization
                    │
────────────── Runtime ──────────────
                    │
Dynamic Renderer Position / Anchor
                    │
                    ▼
         포함된 Tetrahedron 검색
                    │
                    ▼
        네 Probe의 SH Data 보간
                    │
                    ▼
       Surface Normal로 GI 평가
                    │
                    ├─ Realtime Direct Light
                    ├─ Reflection Probe
                    └─ Emission
                    │
                    ▼
               Final Lit Color
```

Light Probe는 Static Surface에 저장된 고해상도 Lightmap을 Dynamic Object가 직접 사용할 수 없는 간격을 공간 Sample과 보간으로 연결한다.

---

## 정리

Light Probe는 Scene의 특정 공간 지점에 방향별 Baked Lighting을 저장해 Dynamic Object가 간접광을 받을 수 있도록 한다.

Static Object는 Lightmap UV로 Surface Lighting을 Sample하지만 움직이는 Object는 위치가 바뀌므로 Probe Data를 사용한다.

Probe Lighting은 Diffuse Indirect Light에 적합한 저주파 Spherical Harmonics 계수로 압축된다.

Unity는 Probe 위치를 Delaunay Tetrahedralization으로 연결하고 Object가 포함된 Tetrahedron의 네 Probe 값을 보간한다.

Renderer의 Bounds 또는 Probe Anchor가 Sample 위치를 결정하므로 Anchor가 잘못되면 Object 전체 Lighting도 틀어진다.

문, 창, 벽과 층처럼 밝기와 색이 급격히 변하는 경계 양쪽에 Probe를 배치해야 Light Leak을 줄일 수 있다.

큰 Dynamic Renderer는 Sample 하나로 공간 변화를 표현하기 어려우며 Light Probe Proxy Volume이나 Mesh 분할을 검토할 수 있다.

Shadowmask Mode에서는 Probe가 Baked Indirect뿐 아니라 Static Geometry의 Mixed Light Occlusion도 Dynamic Object에 전달할 수 있다.

Light Probe는 Indirect Diffuse를 담당하고 Reflection Probe는 Indirect Specular를 담당하므로 두 시스템은 서로 대체하지 않는다.

Additive Scene Load·Unload 또는 Runtime Probe 위치 변경 후에는 Tetrahedralization을 갱신해야 하며 이 작업은 CPU 비용이 클 수 있다.

Probe 수를 균일하게 늘리기보다 Dynamic Object의 이동 영역과 Lighting 변화가 큰 위치에 집중하고 Scene View에서 연결과 Bake 결과를 검증해야 한다.
