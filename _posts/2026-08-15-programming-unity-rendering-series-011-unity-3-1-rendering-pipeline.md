---
title: "[Unity 렌더링] 3-1. 렌더링 파이프라인이란 무엇일까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - RenderingPipeline
  - Rasterization
  - Shader
permalink: /programming/unity-3-1-rendering-pipeline/
toc: true
toc_sticky: true
date: 2026-08-15
last_modified_at: 2026-08-15
---

3D 오브젝트를 화면에 그리려면 Mesh의 Vertex와 Index를 읽고, Vertex 위치를 변환하고, Triangle을 구성하고, 화면을 덮는 Fragment를 만든 뒤 최종 Color를 계산해야 한다.

Depth Test와 Blending을 거쳐 살아남은 결과는 Render Target에 기록된다.

```text
Mesh Data
↓
Vertex 처리
↓
Triangle 구성
↓
Rasterization
↓
Fragment 처리
↓
Depth / Blending
↓
Render Target
```

이처럼 그래픽 데이터를 여러 단계에 걸쳐 처리하여 최종 이미지를 만드는 구조를 **Rendering Pipeline**이라고 한다.

Pipeline이라는 이름은 데이터가 한 처리 단계의 결과에서 다음 단계의 입력으로 이어지기 때문에 사용한다.

각 단계는 서로 다른 역할을 맡고, 일부 단계는 Shader 코드로 제어하며 다른 일부는 GPU에 정해진 기능으로 구성된다.

렌더링 파이프라인을 이해하면 Vertex Shader, Rasterization, Fragment Shader, Depth, Blend가 서로 독립적인 용어가 아니라 하나의 데이터 흐름 안에서 연결된다는 점을 알 수 있다.

---

## Pipeline이란?

Pipeline은 하나의 큰 작업을 여러 처리 단계로 나누고 각 단계의 결과를 다음 단계로 전달하는 구조다.

공장에서 제품이 여러 공정을 거쳐 완성되는 흐름에 비유할 수 있다.

```text
원재료
↓ 가공
중간 부품
↓ 조립
제품
↓ 검사
완성품
```

Graphics Pipeline에서도 입력 데이터가 단계마다 다른 형태로 바뀐다.

```text
Vertex Data
↓
변환된 Vertex
↓
Primitive
↓
Fragment
↓
Color / Depth 결과
```

한 단계가 모든 렌더링 기능을 처리하는 대신 각 단계가 맡은 문제를 분리한다.

이 구조 덕분에 GPU는 많은 Vertex와 Fragment를 병렬로 처리하고 서로 다른 단계의 작업을 겹쳐 진행할 수 있다.

---

## 모든 데이터가 한 개씩 순서대로 지나갈까?

Pipeline 그림은 보통 위에서 아래로 이어진 화살표로 표현한다.

하지만 Vertex 하나가 모든 단계를 끝낼 때까지 다른 Vertex가 기다린다는 의미는 아니다.

```text
단순한 이해용 그림

Vertex 0 → 모든 단계 완료
Vertex 1 → 모든 단계 완료
Vertex 2 → 모든 단계 완료
```

실제 GPU는 많은 작업을 병렬로 실행하고, 서로 다른 Pipeline Stage와 Render Pass의 작업을 하드웨어가 가능한 범위에서 겹칠 수 있다.

```text
Vertex 그룹 A 처리
Fragment 그룹 B 처리
Texture 요청 C 대기
다른 실행 그룹 D 처리
```

Pipeline 순서는 각 연산의 논리적인 의존 관계를 설명한다.

실제 하드웨어 내부의 실행 순서, Cache, Tile 처리와 병렬성은 GPU Architecture에 따라 달라질 수 있다.

---

## 렌더링 파이프라인이라는 말의 범위

렌더링 파이프라인이라는 말은 문맥에 따라 범위가 다르다.

CPU에서 Scene을 준비하는 과정까지 포함한 전체 Rendering 흐름을 의미할 수 있고, GPU 안의 Graphics Pipeline만 의미할 수도 있다.

```text
넓은 의미의 Rendering Pipeline

Game Logic
Culling
Sorting
Render Pass 구성
Draw Command
GPU Graphics Pipeline
Present
```

```text
GPU Graphics Pipeline

Vertex Input
Vertex Processing
Primitive Assembly
Rasterization
Fragment Processing
Output Operations
```

이 글에서는 CPU의 Application Stage부터 GPU의 Output까지 전체 흐름을 먼저 정리하고, GPU Graphics Pipeline의 각 단계를 중심으로 연결한다.

---

## Unity의 Render Pipeline과 GPU Pipeline

Unity에서 Built-in Render Pipeline, URP, HDRP라는 이름을 사용한다.

이 Render Pipeline들은 Camera를 어떤 순서로 처리하고 어떤 Render Pass를 구성하며 어떤 Shader와 Render Target을 사용할지를 결정하는 Engine 수준의 구조다.

```text
Unity Render Pipeline
Camera Culling
Shadow Pass
Opaque Pass
Skybox
Transparent Pass
Post Processing
```

각 Pass 안에서 실제 Mesh를 Draw하면 GPU Graphics Pipeline이 동작한다.

```text
Opaque Draw Call 하나
↓
Vertex Shader
Rasterization
Fragment Shader
Depth / Blend
```

따라서 URP 자체와 Vertex-to-Fragment Graphics Pipeline은 같은 개념이 아니다.

URP는 여러 GPU Pipeline 실행과 Render Pass를 어떤 방식으로 구성할지 결정하는 상위 렌더링 구조라고 볼 수 있다.

---

## 전체 단계

전통적인 Rasterization 기반 Rendering Pipeline을 크게 나누면 다음과 같다.

```text
1. Application Stage
CPU에서 Scene과 Rendering Command 준비

2. Geometry Processing
Vertex와 Primitive 처리

3. Rasterization
Primitive를 Fragment로 변환

4. Fragment Processing
각 Fragment의 Color와 값을 계산

5. Output Operations
Depth, Stencil, Blending 후 Render Target 기록
```

각 범위 안에는 더 세부적인 단계가 있다.

Graphics API와 GPU가 지원하는 기능에 따라 Tessellation, Geometry Shader, Mesh Shader 같은 선택 단계가 포함될 수도 있다.

모든 Unity Shader가 모든 단계를 직접 작성하는 것은 아니다.

일반적인 URP Shader에서는 Vertex Shader와 Fragment Shader를 주로 작성하고 나머지는 Render State와 Pipeline 설정으로 제어한다.

---

## Application Stage

Application Stage는 CPU에서 현재 Frame의 Scene 상태와 Rendering 작업을 준비하는 범위다.

```text
Game Logic
Physics
Animation
Transform 갱신
Camera 설정
```

렌더링 시점에는 Camera를 기준으로 어떤 Renderer를 고려할지 판단하고, Mesh와 Material, Shader Pass, Render State를 이용해 GPU Command를 준비한다.

```text
Camera
↓
Culling
↓
Renderer 후보
↓
Sorting
↓
Material / Shader Pass 선택
↓
Draw Command 생성
```

GPU가 알아서 Unity Scene의 GameObject 목록을 읽고 무엇을 그릴지 결정하는 것은 아니다.

CPU와 Render Pipeline이 GPU가 처리할 Buffer, Texture, Shader, Render State와 Draw 범위를 준비한다.

---

## Culling

Application Stage에서는 먼저 그릴 필요가 없는 Renderer를 후보에서 제외할 수 있다.

```text
비활성 Renderer
Camera Culling Mask에서 제외된 Layer
Frustum 밖의 Renderer
Occlusion Culling으로 가려진 Renderer
```

Renderer 단위의 Culling을 통해 Draw Call 자체를 만들지 않으면 CPU의 Command 준비와 GPU의 Geometry 처리를 줄일 수 있다.

GPU Pipeline 내부의 Backface Culling이나 Clip Space Clipping과는 처리 단위와 위치가 다르다.

```text
CPU / Pipeline Culling
Renderer 후보 제거

GPU Backface Culling
뒷면 Primitive 제거

GPU Clipping
View Volume 경계와 교차하는 Primitive 처리
```

---

## Sorting과 Batching 준비

Culling을 통과한 Renderer는 Render Queue와 Material, Camera 거리 등을 기준으로 정렬될 수 있다.

```text
Opaque
State 변경과 Front-to-Back 효율 고려

Transparent
Blending을 위해 Back-to-Front 순서 고려
```

같은 Mesh나 Material 상태를 공유하는 Draw를 묶거나 GPU Instancing, SRP Batcher 같은 경로를 사용할 수 있는지도 준비한다.

이 과정은 GPU가 Vertex를 처리하기 전에 CPU와 Render Pipeline이 Draw Command를 효율적으로 구성하는 단계다.

Sorting과 Batching 자체에도 CPU 비용이 있으므로 Draw Call을 줄이는 이점과 준비 비용을 함께 봐야 한다.

---

## Render State 준비

GPU가 Geometry를 어떻게 처리할지 결정하려면 Shader 코드 외에도 여러 State가 필요하다.

```text
Primitive Topology
Cull Mode
Depth Test
Depth Write
Stencil
Blend Mode
Color Mask
Viewport
Scissor
Render Target Format
```

Vulkan, Direct3D 12 같은 현대 Graphics API에서는 많은 State와 Shader 조합을 Pipeline State Object 형태로 미리 구성할 수 있다.

Unity Material과 Shader Pass가 달라지면 필요한 GPU Pipeline State도 달라질 수 있다.

State 변경과 Pipeline 생성이 Runtime Hitch 또는 CPU 비용에 영향을 줄 수 있는 이유다.

---

## Draw Call에서 GPU Pipeline이 시작된다

CPU가 Draw Command를 제출하면 GPU는 지정된 Vertex와 Index 범위, Shader와 Render State를 이용해 Graphics Pipeline 작업을 수행한다.

개념적인 Draw Command에는 다음 정보가 연결된다.

```text
어떤 Vertex Buffer인가?
어떤 Index Buffer인가?
어떤 Primitive Topology인가?
어떤 Shader인가?
어떤 Material Property인가?
어떤 Render Target인가?
몇 개의 Vertex 또는 Index를 처리할 것인가?
```

Draw Call 하나가 화면 하나를 완성하는 것은 아니다.

Scene의 여러 Renderer와 Shadow, Depth, Opaque, Transparent Pass를 위해 많은 Draw가 실행되고 결과가 Render Target에 누적된다.

---

## Vertex Input

GPU Graphics Pipeline의 입력에는 Mesh의 Vertex Buffer와 Index Buffer가 있다.

Vertex Buffer에는 Position, Normal, Tangent, UV, Color와 같은 Vertex Attribute가 저장될 수 있다.

```text
Vertex 0
Position, Normal, UV

Vertex 1
Position, Normal, UV
```

Pipeline은 Vertex Layout을 기준으로 Buffer의 Byte를 Shader Input에 연결한다.

```hlsl
struct Attributes
{
    float4 positionOS : POSITION;
    float3 normalOS   : NORMAL;
    float2 uv         : TEXCOORD0;
};
```

Mesh 데이터에 Normal이 없는데 Shader가 올바른 Normal을 기대하거나, Layout과 Format이 맞지 않으면 정상적인 결과를 얻을 수 없다.

---

## Input Assembly

Input Assembly는 Vertex와 Index를 읽어 Pipeline이 처리할 Vertex 흐름과 Primitive 구성을 준비한다.

Triangle List라면 Index 세 개가 하나의 Triangle을 지정한다.

```text
Indices
0, 1, 2
0, 2, 3

Triangle 0 = Vertex 0, 1, 2
Triangle 1 = Vertex 0, 2, 3
```

Index를 사용하면 여러 Triangle이 같은 Vertex를 재사용할 수 있다.

GPU의 Vertex Cache가 변환된 Vertex 결과를 재사용할 수 있으면 Vertex Shader 실행을 줄이는 데 도움이 될 수 있다.

실제 Cache 동작과 효율은 Index 순서와 GPU Architecture에 따라 달라진다.

---

## Vertex Shader

Vertex Shader는 입력 Vertex마다 실행되는 Programmable Stage다.

가장 기본적인 역할은 Object Space Position을 Clip Space Position으로 변환하는 것이다.

```hlsl
output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
```

UV, Normal, Color처럼 Fragment Shader에 필요한 값도 출력할 수 있다.

```hlsl
output.uv = input.uv;
output.normalWS = TransformObjectToWorldNormal(input.normalOS);
```

```text
Vertex Shader Input
PositionOS, NormalOS, UV
↓
Vertex Shader Output
PositionCS, NormalWS, UV
```

Vertex Shader는 일반적으로 한 Vertex의 데이터만 처리하며 Triangle 내부의 Pixel을 직접 만들지 않는다.

---

## Vertex Shader에서 할 수 있는 일

좌표 변환 외에도 Vertex Animation과 변형을 적용할 수 있다.

```text
Wind Animation
Wave
Procedural Offset
Skinning
Morph Target
```

Vertex Shader에서 Position을 바꾸면 이후 Triangle 형태와 Rasterization 결과가 달라진다.

하지만 Mesh의 Vertex 밀도가 낮으면 Vertex 사이의 곡면을 세밀하게 변형할 수 없다.

Vertex Shader 비용은 실행되는 Vertex 수와 각 Vertex의 연산량, Render Pass 반복 횟수에 영향을 받는다.

---

## 선택적인 Geometry Stage

전통적인 Graphics Pipeline에는 Vertex Shader 이후 Tessellation과 Geometry Shader 같은 선택 단계가 있을 수 있다.

```text
Vertex Shader
↓
Tessellation Control
↓
Tessellation Evaluation
↓
Geometry Shader
↓
Rasterization
```

Tessellation은 Patch를 더 많은 Primitive로 세분화할 수 있다.

Geometry Shader는 Primitive를 입력받아 제거하거나 새로운 Primitive를 출력할 수 있다.

하지만 모든 플랫폼에서 같은 지원과 성능을 제공하지 않으며 모바일과 URP 환경에서는 제약을 확인해야 한다.

일반적인 Shader에는 이 단계가 없고 Vertex Shader 결과가 Primitive Processing으로 이어진다.

---

## Mesh Shader Pipeline

현대 GPU와 Graphics API에는 기존 Vertex Input과 Geometry Processing 구조를 대체하거나 확장하는 Mesh Shader Pipeline이 존재할 수 있다.

Meshlet 같은 작은 Geometry 묶음을 Shader에서 처리하고 Culling과 Primitive 생성을 더 유연하게 수행할 수 있다.

```text
전통적 Pipeline
Vertex Input → Vertex Shader → Primitive

Mesh Shader Pipeline
Task / Mesh Shader → Primitive 생성
```

이 기능은 하드웨어, Graphics API와 Unity Render Pipeline 지원에 따라 사용할 수 있는 범위가 달라진다.

기본 렌더링 구조를 이해할 때는 먼저 전통적인 Vertex-to-Rasterization 흐름을 기준으로 보는 것이 좋다.

---

## Primitive Assembly

Vertex Processing 결과는 Primitive Topology에 따라 Point, Line, Triangle로 조립된다.

게임의 3D Mesh는 대부분 Triangle Primitive를 사용한다.

```text
Vertex A PositionCS
Vertex B PositionCS
Vertex C PositionCS
↓
Triangle ABC
```

이 시점부터 개별 Vertex뿐 아니라 여러 Vertex가 구성하는 Primitive의 방향과 영역을 판단할 수 있다.

Triangle의 Winding Order는 Front Face와 Back Face를 구분하는 데 사용된다.

---

## Backface Culling

닫힌 Mesh에서는 Camera 반대 방향을 향한 Triangle이 앞쪽 표면에 가려지는 경우가 많다.

Backface Culling은 Winding과 Pipeline의 Cull State를 기준으로 이런 Triangle을 Rasterization 대상에서 제외할 수 있다.

```shaderlab
Cull Back
```

```text
Front Face
Rasterization

Back Face
Culling
```

양면으로 보여야 하는 나뭇잎이나 얇은 천에서는 `Cull Off`를 사용할 수 있지만 처리하는 Triangle과 Fragment가 늘 수 있다.

Culling은 Shader 코드 길이를 줄이는 기능이 아니라 Primitive 자체를 이후 단계에서 제외하는 Render State다.

---

## Clipping

Vertex Shader가 출력한 Triangle은 Camera의 Clip Volume과 비교된다.

```text
완전히 Clip Volume 밖
→ Primitive 제거

완전히 안
→ 유지

경계와 교차
→ 경계에 맞게 자름
```

Triangle을 자르면 경계 위치에 새로운 Vertex가 생성될 수 있고 UV, Normal, Color 같은 Attribute도 해당 위치에 맞게 계산된다.

Clipping은 CPU의 Renderer Frustum Culling과 다르다.

Renderer Bounds가 Frustum과 겹쳐 Draw가 제출된 뒤에도 개별 Primitive 일부는 GPU Clip Stage에서 처리될 수 있다.

---

## Perspective Divide와 Viewport Transform

Clipping 이후 Clip Position의 `x`, `y`, `z`를 `w`로 나누어 NDC를 만든다.

```text
NDC = Clip.xyz / Clip.w
```

Perspective Camera에서는 이 과정이 멀리 있는 Geometry를 화면에서 작게 만드는 원근감과 연결된다.

NDC는 Viewport Transform을 거쳐 현재 Render Target의 화면 좌표와 Depth 범위에 대응된다.

```text
Clip Space
↓ Perspective Divide
NDC
↓ Viewport Transform
Screen / Framebuffer Coordinates
```

Graphics API별 축과 Depth Convention 차이는 Unity와 Render Pipeline이 제공하는 Matrix와 Helper를 통해 처리하는 것이 안전하다.

---

## Rasterization

Rasterization은 화면에 투영된 Primitive를 Fragment 후보로 변환하는 단계다.

Triangle이 화면의 어느 Sample 위치를 덮는지 판정한다.

```text
Screen Space Triangle
↓
Coverage 계산
↓
Fragment 생성
```

Rasterization은 3D Triangle을 완성된 Pixel Color로 바로 바꾸는 단계가 아니다.

Triangle이 덮는 위치와 그 위치에 전달할 보간 데이터를 만든다.

최종 Color는 이후 Fragment Shader와 Output Operations를 거쳐 결정된다.

---

## Fragment와 Pixel

Fragment는 Pixel과 같은 의미가 아니다.

여러 Triangle이 같은 Pixel 위치에 각각 Fragment를 만들 수 있다.

MSAA에서는 Pixel 안의 여러 Sample Coverage도 고려한다.

```text
Pixel 하나
├─ Triangle A Fragment
├─ Triangle B Fragment
└─ Particle Fragment 여러 개
```

Depth Test에서 제거되거나 Blending으로 합쳐지는 Fragment가 있으므로 모든 Fragment가 최종 Pixel로 남는 것은 아니다.

Fragment는 최종 Render Target 값을 만들기 위한 후보 데이터에 가깝다.

---

## Interpolation

Vertex Shader가 출력한 UV, Normal, Color는 Triangle의 세 Vertex에만 존재한다.

Rasterizer는 Fragment가 Triangle 내부의 어느 위치에 있는지를 기준으로 이 값을 보간한다.

```text
Vertex A UV = (0, 1)
Vertex B UV = (0, 0)
Vertex C UV = (1, 0)
↓
Fragment별 UV 보간
```

Perspective Projection에서는 Clip `w`를 고려한 Perspective-Correct Interpolation이 사용될 수 있다.

이 과정을 통해 Fragment Shader는 현재 위치에 맞는 UV와 Normal을 입력받는다.

---

## Fragment Shader

Fragment Shader는 Rasterization으로 생성된 Fragment를 대상으로 실행되는 Programmable Stage다.

Pixel Shader라고도 부르지만 Fragment와 Pixel의 차이를 고려하면 Fragment Shader라는 이름이 처리 대상을 더 잘 나타낸다.

```hlsl
half4 frag(Varyings input) : SV_Target
{
    half4 albedo = SAMPLE_TEXTURE2D(
        _BaseMap,
        sampler_BaseMap,
        input.uv
    );

    return albedo;
}
```

Fragment Shader는 Texture Sampling, Lighting, Normal Mapping, Fog와 Material 효과를 계산하여 Color를 출력할 수 있다.

MRT를 사용하면 여러 Render Target에 서로 다른 값을 출력할 수도 있다.

---

## Fragment Shader의 입력

Fragment Shader는 Vertex Shader 출력이 Rasterizer에서 보간된 값을 입력받는다.

```text
Vertex Shader Output
UV, NormalWS, Color, Position
↓ Rasterization / Interpolation
Fragment Shader Input
현재 Fragment 위치의 UV, NormalWS, Color
```

Texture, Constant Buffer, Camera Depth Texture 같은 Resource도 읽을 수 있다.

```text
Interpolated Data
Material Property
Texture
Lighting Data
Camera Data
```

어떤 데이터를 Shader Stage 사이에 전달하고 어떤 Texture를 Sampling하는지가 GPU 연산량과 대역폭에 영향을 준다.

---

## Fragment를 버릴 수도 있다

Fragment Shader는 Alpha Clipping과 같은 조건으로 Fragment를 버릴 수 있다.

```hlsl
clip(alpha - cutoff);
```

나뭇잎 Texture의 투명 영역처럼 Color와 Depth를 기록하지 않아야 하는 부분에 사용할 수 있다.

하지만 `clip`이나 `discard`는 실행 그룹의 분기와 Early-Z 최적화에 영향을 줄 수 있다.

Fragment를 최종적으로 버리더라도 그 지점까지 수행한 Shader 연산 비용이 이미 발생했을 수 있다.

---

## Early Fragment Operations

Depth와 Stencil Test 일부는 Fragment Shader보다 먼저 수행될 수 있다.

앞의 불투명 표면에 완전히 가려진 Fragment를 Shader 실행 전에 제거하면 비싼 Texture Sampling과 Lighting 비용을 줄일 수 있다.

```text
Rasterization
↓ Early Depth / Stencil
가려진 Fragment 제거
↓
Fragment Shader
```

Fragment Shader가 Depth를 변경하거나 Fragment 생존 여부를 바꾸는 동작을 사용하면 Test를 완전히 앞에서 처리하기 어려울 수 있다.

실제 Early-Z와 Hierarchical Depth 동작은 GPU와 Shader에 따라 달라진다.

---

## Late Fragment Operations

Fragment Shader 실행 이후 Depth, Stencil과 Sample 관련 Test가 수행되거나 최종 확정될 수도 있다.

```text
Fragment Shader
↓
Depth Test
Stencil Test
Sample Mask
↓
통과한 결과만 Output 단계로
```

Depth Test에 실패한 Fragment는 Color Buffer에 기록되지 않는다.

Shader가 실행된 뒤 실패하면 화면 결과에는 남지 않아도 GPU 연산 비용은 발생한다.

이 때문에 Opaque의 Front-to-Back Rendering과 Early-Z 효율이 Fragment 병목에 중요할 수 있다.

---

## Stencil Test

Stencil Buffer는 화면 위치마다 작은 정수 값을 저장하고 조건에 따라 Fragment를 통과시키거나 값을 갱신할 수 있다.

```text
Depth
앞뒤 관계

Stencil
사용자가 정의한 영역 Mask와 상태
```

Portal, Outline, Mirror, UI Mask와 특정 Lighting 영역에 사용할 수 있다.

Stencil Test도 Output Operations의 가시성 판정에 참여한다.

Depth와 Stencil이 하나의 Depth-Stencil Attachment Format으로 함께 저장되는 경우도 있다.

---

## Color Blending

Depth와 Stencil을 통과한 Source Color는 Render Target의 Destination Color와 Blend될 수 있다.

```text
Source
현재 Fragment Shader 출력

Destination
Render Target의 기존 Color

Output
Blend State에 따른 결합 결과
```

Opaque는 일반적으로 Source로 Destination을 대체한다.

Transparent는 Alpha, Additive, Premultiplied 같은 Blend Mode로 기존 Scene Color와 결합한다.

Blending은 Fragment Shader 내부가 아니라 GPU의 고정 기능 Output Stage에서 처리하는 것이 일반적이다.

---

## Render Target 기록

최종적으로 살아남은 결과는 Color, Depth, Stencil Attachment에 기록된다.

```text
Color Attachment
최종 또는 중간 Color

Depth Attachment
가시성 판정용 깊이

Stencil Attachment
영역 Mask와 상태
```

하나의 Pass가 반드시 디스플레이에 보일 최종 Color를 만드는 것은 아니다.

Shadow Pass는 Light 기준 Depth를 만들고, G-Buffer Pass는 Material 속성을 여러 Target에 기록하며, Post Processing Pass는 중간 Texture를 읽어 다른 Target에 결과를 쓸 수 있다.

---

## 하나의 Frame에는 Pipeline이 몇 번 실행될까?

Scene을 한 번 그린다고 Graphics Pipeline이 한 번만 실행되는 것은 아니다.

```text
Shadow Map Pass
여러 Light와 Cascade

Depth Prepass
Camera Depth

Opaque Pass
Scene Color

Transparent Pass
Blending

Post Processing
Full Screen Draw
```

각 Pass 안에서 여러 Draw Call이 발생하며 Draw마다 Graphics Pipeline의 관련 단계가 동작한다.

같은 Mesh가 Main Camera, Shadow, Depth와 Reflection Camera에서 반복 처리될 수 있다.

화면에 보이는 Triangle 수만으로 전체 GPU 작업량을 판단할 수 없는 이유다.

---

## Programmable Stage와 Fixed-Function Stage

Graphics Pipeline에는 개발자가 Shader 코드로 작성하는 Programmable Stage와 동작 형태가 GPU에 정해진 Fixed-Function Stage가 함께 있다.

```text
Programmable
Vertex Shader
Fragment Shader
선택적인 Tessellation / Geometry / Mesh Shader

Fixed-Function 중심
Input Assembly
Clipping
Rasterization
Depth / Stencil Test
Blending
```

Fixed-Function이라고 설정할 수 없다는 의미는 아니다.

Cull Mode, Depth Compare, Blend Factor처럼 State를 지정할 수 있지만 Rasterization Algorithm 자체를 일반 Shader 코드처럼 교체하지는 않는다.

전용 하드웨어는 정해진 작업을 효율적으로 처리할 수 있다.

---

## Shader와 Pipeline State

Shader 코드만 같다고 모든 Draw가 같은 Pipeline State를 사용하는 것은 아니다.

```text
같은 Shader Program

Cull Back / Cull Off
ZWrite On / Off
Blend Off / Alpha
다른 Render Target Format
다른 MSAA Sample Count
```

이 State 조합은 별도의 GPU Pipeline 구성이 필요할 수 있다.

Material과 Shader Variant가 많으면 Pipeline State 전환, Compile과 Cache 관리가 복잡해질 수 있다.

Unity에서 SetPass Call과 Shader Variant, Material 구성이 성능과 Loading Hitch에 연결되는 이유다.

---

## Rasterization Pipeline과 Compute Shader

Compute Shader는 GPU에서 대량 병렬 계산을 수행하지만 전통적인 Graphics Pipeline의 Vertex-to-Rasterization 흐름에 속하지 않는다.

```text
Graphics Pipeline
Draw Command
Primitive → Fragment → Render Target

Compute Pipeline
Dispatch Command
Thread Group → Buffer / Texture Read Write
```

Compute Shader는 Culling, Particle Simulation, Image Effect, Lighting과 Data Processing에 사용할 수 있다.

Compute 결과를 이후 Graphics Pipeline의 Vertex Buffer, Indirect Argument 또는 Texture로 사용할 수 있다.

두 Pipeline은 Resource와 Synchronization을 통해 연결될 수 있다.

---

## Rasterization과 Ray Tracing

이 글의 Rendering Pipeline은 Triangle을 화면에 투영하고 Rasterization하는 구조를 기준으로 한다.

Ray Tracing Pipeline은 Camera Ray와 Scene Geometry의 교차를 추적하여 Visibility와 Lighting을 계산하는 다른 실행 구조를 사용한다.

```text
Rasterization
Triangle을 화면으로 투영

Ray Tracing
Ray를 Scene으로 추적
```

현대 Rendering은 Rasterization과 Ray Tracing, Compute를 함께 사용할 수 있다.

Unity의 일반적인 실시간 화면은 여전히 Rasterization Pipeline을 중심으로 구성하고 일부 Reflection, Shadow, GI에 Ray Tracing을 결합할 수 있다.

---

## Pipeline의 병목

Frame 성능은 Pipeline의 어느 단계에서 처리량이 제한되는지에 따라 달라진다.

```text
Application / CPU Bound
많은 Renderer, Draw Call, State 변경

Vertex Bound
많은 Vertex, 복잡한 Skinning과 Vertex Shader

Primitive / Raster Bound
매우 많은 작은 Triangle

Fragment Bound
높은 해상도, Overdraw, 복잡한 Fragment Shader

Bandwidth Bound
많은 Texture와 Render Target Read / Write
```

Triangle 수만 줄이거나 Shader 코드 줄 수만 줄인다고 모든 병목이 해결되지는 않는다.

현재 가장 오래 걸리는 Stage와 Resource 병목을 측정해야 한다.

---

## Pipeline Stage는 완전히 독립적일까?

한 단계의 설정은 뒤 단계의 작업량에 영향을 준다.

```text
Culling 개선
→ Vertex와 Fragment 작업 감소

Vertex가 Triangle을 크게 확장
→ Rasterization과 Fragment 증가

Front-to-Back Ordering
→ Early-Z 효율 증가 가능

ZWrite Off Transparent
→ 뒤 Fragment 제거 감소

낮은 해상도 Render Target
→ Fragment와 대역폭 감소
```

최적화는 개별 Stage만 보는 것이 아니라 앞 단계의 결정이 뒤 단계에 어떤 데이터를 보내는지 확인하는 과정이다.

---

## Unity에서 Pipeline을 어떻게 확인할까?

Unity Profiler의 CPU Usage와 Rendering 영역에서는 Culling, Render Thread, Draw Call 준비와 관련된 시간을 확인할 수 있다.

GPU Usage Profiler는 플랫폼 지원 범위 안에서 Render Pass와 GPU 작업 시간을 보여 준다.

Frame Debugger는 한 Frame의 Draw와 Blit, Render Target 변경 순서를 단계별로 확인하는 데 유용하다.

```text
Frame Debugger
어떤 Draw가 어떤 순서로 실행되는가?

GPU Profiler
어느 Pass가 오래 걸리는가?

RenderDoc
Pipeline State, Buffer, Texture, Attachment는 무엇인가?
```

개념적인 Pipeline을 실제 Frame의 Command와 연결하면 병목 원인을 더 구체적으로 찾을 수 있다.

---

## 전체 흐름

Unity에서 하나의 Mesh가 Render Target에 기록되는 흐름을 단순화하면 다음과 같다.

```text
CPU / Application

Camera와 Scene 상태
↓
Culling
↓
Sorting / Batching
↓
Shader Pass와 Render State 선택
↓
Draw Command

GPU / Graphics Pipeline

Vertex / Index Input
↓
Vertex Shader
↓
Primitive Assembly
↓
Backface Culling / Clipping
↓
Perspective Divide / Viewport
↓
Rasterization
↓
Interpolation
↓
Early Depth / Stencil 가능
↓
Fragment Shader
↓
Depth / Stencil / Sample Operations
↓
Blending
↓
Color / Depth Render Target
```

Render Pipeline은 이 흐름을 여러 Draw와 Pass에 걸쳐 반복하고 중간 Render Target을 연결하여 하나의 Frame을 만든다.

---

## 정리

Rendering Pipeline은 Mesh와 Texture 같은 그래픽 입력을 여러 처리 단계에 통과시켜 최종 Render Target의 이미지로 만드는 구조다.

Pipeline 그림은 논리적인 데이터 의존 관계를 나타내며 실제 GPU가 모든 작업을 한 개씩 완전히 직렬로 처리한다는 의미는 아니다.

넓은 의미의 Rendering Pipeline은 CPU의 Culling, Sorting, Command 준비부터 GPU Rendering과 Present까지 포함할 수 있다.

GPU Graphics Pipeline은 Vertex Input, Geometry Processing, Rasterization, Fragment Processing과 Output Operations로 구성된다.

Unity의 URP, HDRP와 Built-in Render Pipeline은 여러 Camera와 Render Pass, GPU Pipeline 실행을 어떻게 구성할지 결정하는 상위 Engine 구조다.

Application Stage에서는 Camera를 기준으로 Renderer를 Culling하고 정렬하며 Mesh, Material, Shader Pass와 Render State를 이용해 Draw Command를 준비한다.

Vertex Shader는 Vertex Position을 Clip Space로 변환하고 Fragment Shader에 전달할 속성을 출력한다.

Primitive Assembly는 Vertex를 Triangle로 구성하며 Backface Culling과 Clipping을 거쳐 Rasterization으로 전달한다.

Rasterization은 Triangle이 덮는 Sample을 판정하고 Vertex Attribute를 보간하여 Fragment를 만든다.

Fragment Shader는 Texture Sampling과 Lighting으로 Source Color를 계산한다.

Depth, Stencil과 Blending 같은 Output Operations는 Fragment가 Render Target에 기록될지와 기존 Color에 어떻게 결합될지를 결정한다.

하나의 Frame에는 Shadow, Depth, Opaque, Transparent와 Post Processing 등 여러 Pass와 많은 Draw가 포함되므로 같은 Geometry가 Pipeline을 여러 번 지날 수 있다.

최적화에서는 Draw Call, Vertex, Triangle, Fragment, Texture와 Render Target 대역폭 중 실제로 어느 단계가 처리량을 제한하는지 측정해야 한다.

전체 Pipeline의 위치를 잡으면 다음 글에서 Vertex Shader가 입력 Vertex를 어떤 방식으로 변환하고 다음 Stage에 어떤 데이터를 전달하는지 더 구체적으로 연결할 수 있다.
