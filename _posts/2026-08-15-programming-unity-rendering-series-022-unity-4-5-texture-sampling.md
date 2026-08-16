---
title: "[Unity 렌더링] 4-5. Texture Sampling은 어떻게 동작할까?"
excerpt: "Unity Rendering"
categories:
  - Unity
series: unity-rendering
tags:
  - Unity
  - Rendering
  - TextureSampling
  - Sampler
  - Filtering
permalink: /programming/unity-4-5-texture-sampling/
toc: true
toc_sticky: true
date: 2026-08-15
last_modified_at: 2026-08-15
---

Texture는 Color, Normal, Mask와 다양한 표면 Data를 1D, 2D 또는 3D 격자에 저장하는 GPU Resource다.

Fragment Shader는 보간된 UV를 사용하여 Texture에서 값을 읽을 수 있다.

```hlsl
half4 color = SAMPLE_TEXTURE2D(
    _BaseMap,
    sampler_BaseMap,
    input.uv
);
```

이 한 줄에는 단순한 Array 접근보다 많은 과정이 포함된다.

```text
UV Coordinate
↓ Address Mode
Texture 내부 위치 결정
↓ Screen Space Derivative
Texture Footprint와 Mip Level 결정
↓ Filter Mode
주변 Texel 선택과 결합
↓ Format 변환
Sampled Value 반환
```

Texture Sampling은 Texture, Coordinate와 Sampler State를 이용하여 현재 Shader Invocation에 필요한 값을 만드는 과정이다.

---

## Texture란?

Texture는 규칙적인 격자에 값을 저장한 Image Resource다.

가장 익숙한 2D Texture는 Width와 Height를 가진다.

```text
4 × 4 Texture

+---+---+---+---+
| T | T | T | T |
+---+---+---+---+
| T | T | T | T |
+---+---+---+---+
| T | T | T | T |
+---+---+---+---+
| T | T | T | T |
+---+---+---+---+
```

각 칸은 **Texel**이다.

Texel은 Texture Element의 줄임말이며 Texture에 저장된 한 요소를 뜻한다.

Texture Format에 따라 Texel은 RGBA Color, 하나의 Depth, 여러 Material Channel 또는 압축된 Block Data의 일부를 나타낼 수 있다.

---

## Texture와 Pixel은 다르다

Pixel은 Render Target이나 최종 화면 Image의 한 위치를 가리키고 Texel은 Texture의 한 요소를 가리킨다.

```text
Texel
Texture Resource에 저장된 요소

Pixel
Render Target 또는 Display Image의 요소
```

한 Fragment Shader Invocation이 하나의 Pixel 후보를 처리하면서 여러 Texel을 Filtering에 사용할 수 있다.

반대로 낮은 해상도의 Texture Texel 하나가 화면의 여러 Pixel에 확대되어 보일 수도 있다.

```text
Texture Texel 수
≠ 화면 Pixel 수
≠ Fragment Shader Invocation 수
```

---

## UV란?

UV는 2D Texture에서 위치를 지정하는 Coordinate다.

일반적으로 정규화된 범위 `0`부터 `1`을 사용한다.

```text
V = 1
(0,1) ------------ (1,1)
  |                  |
  |     Texture      |
  |                  |
(0,0) ------------ (1,0)
V = 0       U →
```

`U`는 Texture의 가로축, `V`는 세로축에 대응한다.

3D World의 X, Y, Z와 구분하기 위해 U, V라는 이름을 사용한다.

UV의 세로 방향과 Texture Origin은 Graphics API와 Import 처리에 따라 차이가 있을 수 있으므로 Unity가 제공하는 Convention과 Helper를 사용한다.

---

## UV는 Texture 안에 저장될까?

UV는 일반적으로 Mesh의 Vertex Attribute로 저장된다.

```text
Mesh Vertex A
Position + UV (0, 0)

Mesh Vertex B
Position + UV (1, 0)

Mesh Vertex C
Position + UV (0, 1)
```

Vertex Shader가 UV를 Varying으로 출력하면 Rasterizer가 Triangle 내부에서 Perspective-correct Interpolation을 수행한다.

```text
Mesh UV
↓ Vertex Shader
Vertex별 UV Output
↓ Rasterizer Interpolation
Fragment UV
↓ Texture Sampling
Texture Value
```

Texture Asset이 Mesh 위의 어느 위치에 붙는지는 Mesh UV와 Shader 계산이 결정한다.

---

## Texture Coordinate는 Texel Index가 아니다

정규화 UV `(0.5, 0.5)`는 Texture 중앙 부근을 뜻한다.

Texture가 1024×1024든 256×256이든 같은 정규화 위치를 표현한다.

```text
UV (0.5, 0.5)

1024 × 1024 Texture
→ 중앙 부근

256 × 256 Texture
→ 중앙 부근
```

Texel Index는 정수 격자 위치다.

```text
UV Coordinate
Normalized Floating-point 위치

Texel Coordinate
Texture 격자의 위치
```

Sampling Operation은 Texture Size와 Coordinate를 사용해 어느 Texel과 주변 영역이 결과에 참여할지 결정한다.

---

## Texture Sampling에 필요한 세 요소

일반적인 Sample Operation에는 다음 요소가 필요하다.

```text
Texture
어떤 Texel Data를 읽는가

Coordinate
어느 위치를 읽는가

Sampler
범위 밖 좌표와 Filtering을 어떻게 처리하는가
```

HLSL에서는 Texture Object와 Sampler State를 구분할 수 있다.

```hlsl
TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);
```

Sampling할 때 세 요소를 연결한다.

```hlsl
half4 color = SAMPLE_TEXTURE2D(
    _BaseMap,
    sampler_BaseMap,
    input.uv
);
```

---

## Texture Object

Texture Object는 Image Resource에 접근하는 Shader Interface다.

```hlsl
Texture2D<float4> _BaseMap;
```

Unity URP Macro로는 다음처럼 선언할 수 있다.

```hlsl
TEXTURE2D(_BaseMap);
```

이 선언이 Texture Memory를 생성하는 것은 아니다.

Material이나 Render Pipeline이 실제 Texture Resource를 Draw에 Binding해야 한다.

```text
Material Property
_BaseMap = Brick Texture Asset
↓ Resource Binding
Shader Texture Object
_BaseMap
```

---

## Sampler란?

Sampler는 Texture를 읽는 규칙을 나타내는 State다.

대표적인 Sampler 설정은 다음과 같다.

- Minification Filter
- Magnification Filter
- Mipmap Filter
- Address 또는 Wrap Mode
- Anisotropic Filtering
- LOD Bias와 LOD 범위
- Depth Comparison 설정

```text
같은 Texture + 같은 UV

Point Sampler
→ 가장 가까운 Texel

Linear Sampler
→ 주변 Texel 결합

Repeat Address
→ 범위 밖 좌표 반복

Clamp Address
→ 가장자리 값 유지
```

Texture Data가 같아도 Sampler가 다르면 결과가 달라진다.

---

## Texture Import 설정과 Sampler

Unity Texture Importer의 Filter Mode, Wrap Mode와 Aniso Level은 Texture가 일반적인 Material Sampling에 사용될 때 Sampler State 구성에 영향을 준다.

```text
Texture Importer
├─ Wrap Mode
├─ Filter Mode
├─ Aniso Level
└─ Generate Mip Maps
```

Render Pipeline이나 Custom Shader는 별도의 Sampler State를 선언하여 다른 규칙을 사용할 수 있다.

Material의 Texture Slot만 보고 모든 Sampling State가 결정된다고 단정하면 안 된다.

실제 Shader의 Sampler 선언과 Platform의 Resource Binding을 함께 확인한다.

---

## Wrap Mode가 필요한 이유

UV가 항상 `0`부터 `1` 사이에 있는 것은 아니다.

Texture Tiling을 적용하면 UV가 범위를 벗어날 수 있다.

```hlsl
float2 tiledUV = input.uv * 4.0;
```

원래 UV가 `(0.75, 0.5)`라면 Tiling 후 `(3.0, 2.0)`이 된다.

Sampler의 Address Mode가 범위 밖 Coordinate를 Texture 내부 위치로 변환한다.

```text
UV 범위 밖
↓ Wrap Mode
읽을 Texture 위치 결정
```

---

## Repeat

Repeat는 Coordinate의 정수 부분을 반복 주기로 사용한다.

```text
U = 0.2 → 0.2
U = 1.2 → 0.2
U = 2.2 → 0.2
```

개념적으로 `frac`과 비슷한 반복을 만든다.

```text
... | 0~1 | 0~1 | 0~1 | ...
```

벽돌, 바닥과 반복 Pattern에 적합하다.

Texture Edge가 서로 이어지지 않으면 반복 경계에서 Seam이 보일 수 있다.

---

## Clamp

Clamp는 범위 밖 Coordinate를 가장자리로 제한한다.

```text
U < 0 → Edge 0
0 ≤ U ≤ 1 → 해당 위치
U > 1 → Edge 1
```

```text
Texture 범위
|----------|

왼쪽 밖 → 왼쪽 Edge Color
오른쪽 밖 → 오른쪽 Edge Color
```

UI Image, Render Texture와 반복되면 안 되는 Lookup Texture에 사용할 수 있다.

Linear Filtering은 Edge 주변 Texel을 참조하므로 Atlas에서는 Padding과 UV 경계 처리가 추가로 필요할 수 있다.

---

## Mirror와 Mirror Once

Mirror는 반복할 때 Texture 방향을 번갈아 뒤집는다.

```text
원본 | 반전 | 원본 | 반전
 →      ←      →      ←
```

Repeat 경계의 방향 변화가 자연스러운 Pattern에서 Seam을 완화할 수 있다.

Mirror Once는 한 번 반전한 뒤 바깥 영역을 Clamp하는 방식에 가깝지만 Graphics API와 Platform 지원 범위를 확인해야 한다.

Unity Texture Importer는 Axis별 Wrap Mode를 다르게 지정할 수도 있다.

```text
U Axis = Repeat
V Axis = Clamp
```

---

## Tiling과 Offset

Unity Texture Property에는 Tiling과 Offset 값이 연결될 수 있다.

```hlsl
CBUFFER_START(UnityPerMaterial)
    float4 _BaseMap_ST;
CBUFFER_END
```

`_BaseMap_ST`는 일반적으로 다음 Component를 사용한다.

```text
xy = Tiling
zw = Offset
```

UV Transform은 다음과 같다.

```hlsl
float2 transformedUV = input.uv * _BaseMap_ST.xy + _BaseMap_ST.zw;
```

URP Macro를 사용할 수 있다.

```hlsl
output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
```

Tiling으로 UV가 `0~1` 범위를 벗어나면 Wrap Mode가 결과를 결정한다.

---

## Point Filtering

Point 또는 Nearest Filtering은 Sampling 위치에 가장 가까운 Texel 하나를 선택한다.

```text
Sampling 위치 ×

+----+----+
| T0 | T1 |
+----×----+
| T2 | T3 |
+----+----+

가장 가까운 Texel 하나 반환
```

Texture를 확대하면 Texel 경계가 선명한 Block으로 보인다.

Pixel Art, Index Texture와 정확한 이산 값이 필요한 Data에 적합할 수 있다.

부드러운 Image에 사용하면 확대 시 계단 형태가 두드러진다.

---

## Bilinear Filtering

Bilinear Filtering은 한 Mip Level에서 Sampling 위치 주변의 2×2 Texel 값을 결합한다.

```text
T00 -------- T10
 |     ×      |
 |            |
T01 -------- T11

× = Sampling 위치
```

가로 방향으로 두 번 보간하고 그 결과를 세로 방향으로 보간하는 방식으로 이해할 수 있다.

```text
Top    = lerp(T00, T10, uFraction)
Bottom = lerp(T01, T11, uFraction)
Result = lerp(Top, Bottom, vFraction)
```

실제 Hardware는 같은 결과 규칙을 효율적인 Texture Unit에서 처리할 수 있다.

하나의 Sample Instruction이 Source상 한 줄이어도 여러 Texel이 Filtering에 참여한다.

---

## Point와 Bilinear 비교

| 구분 | Point | Bilinear |
| --- | --- | --- |
| 참여 Texel | 가장 가까운 하나 | 한 Level의 주변 2×2 |
| 확대 결과 | 선명한 Block | 부드러운 경계 |
| 적합한 Data | Pixel Art, 이산 값 | 일반 Color Texture |
| 주의점 | 계단과 깜빡임 | Atlas Edge Bleeding 가능 |

Normal이나 Mask Texture도 Linear Filter를 사용할 수 있지만 값의 의미에 따라 Filtering 결과가 적합한지 확인해야 한다.

ID처럼 이산적인 Integer 의미를 가진 Data는 값이 섞이면 잘못된 Category가 될 수 있다.

---

## Magnification과 Minification

Texture가 화면에 표시되는 크기에 따라 두 상황을 구분한다.

```text
Magnification
Texture Texel보다 화면 Pixel Coverage가 큼
→ Texture를 확대해서 봄

Minification
많은 Texture Texel이 작은 화면 영역에 들어감
→ Texture를 축소해서 봄
```

Magnification에서는 Point와 Linear Filter가 Texel 사이 값을 결정한다.

Minification에서는 한 Pixel이 넓은 Texture 영역을 대표해야 하므로 하나의 고해상도 Level만 읽으면 Alias가 생길 수 있다.

이 문제를 줄이기 위해 Mipmap을 사용한다.

---

## Minification Alias

멀리 있는 Checker Pattern을 고해상도 Texture에서 몇 Texel만 선택해 읽으면 Frame과 위치에 따라 흰색 또는 검은색이 불안정하게 선택될 수 있다.

```text
Texture의 많은 Checker Texel
↓ 화면 Pixel 하나로 축소
일부 Point Sample만 선택
↓
깜빡임, Moiré Pattern, Alias
```

이상적인 결과는 화면 Pixel이 덮는 Texture 영역의 평균에 가깝다.

매 Fragment마다 넓은 영역의 모든 원본 Texel을 읽는 것은 비싸다.

미리 축소한 Mipmap Level을 준비하여 비슷한 범위의 평균 Data를 효율적으로 Sampling한다.

---

## Mipmap이란?

Mipmap은 원본 Texture를 단계적으로 절반씩 축소한 Image Chain이다.

```text
Mip 0: 1024 × 1024
Mip 1:  512 ×  512
Mip 2:  256 ×  256
Mip 3:  128 ×  128
...
Mip 10:   1 ×    1
```

```text
+----------------+
|     Mip 0      |
|                |
+----------------+
+--------+
| Mip 1  |
+--------+
+----+
| M2 |
+----+
```

멀리 있는 Surface에는 더 작은 Mip Level을 사용하여 한 Sample이 대표해야 할 Texture 영역과 더 비슷한 크기의 Texel을 읽는다.

Alias를 줄이고 Texture Cache 효율을 높일 수 있다.

---

## Mipmap Memory

2D Texture의 모든 Mip Level을 저장하면 원본 Level만 저장하는 것보다 Memory가 증가한다.

각 축이 절반이면 Texel 수는 Level마다 약 1/4이 된다.

```text
전체 비율
1 + 1/4 + 1/16 + 1/64 + ...
≈ 4/3
```

완전한 Mip Chain은 압축과 Alignment를 제외한 단순 Texel 수 기준으로 원본보다 약 33% 많은 Memory를 사용할 수 있다.

대신 멀리 있는 Texture가 작은 Mip을 읽어 Cache와 Bandwidth에 유리할 수 있다.

UI처럼 화면에 1:1로 표시되고 축소되지 않는 Texture에는 Mipmap이 불필요할 수 있다.

---

## 어떤 Mip Level을 사용할까?

일반적인 Fragment Texture Sampling은 이웃 Fragment의 UV 변화량을 사용해 화면 Pixel이 Texture에서 차지하는 Footprint를 추정한다.

```hlsl
float2 uvDx = ddx(input.uv);
float2 uvDy = ddy(input.uv);
```

```text
현재 Fragment UV
이웃 Fragment UV
↓ 차이
Screen X, Y 방향 UV Derivative
↓ Texture Size 반영
Texture Footprint
↓
LOD와 Mip Level 선택
```

UV가 Fragment 사이에서 빠르게 변하면 한 Pixel이 넓은 Texture 영역을 덮으므로 더 작은 Mip Level이 필요하다.

UV 변화가 작으면 원본에 가까운 Mip Level을 사용할 수 있다.

---

## LOD

LOD는 Level of Detail의 줄임말이며 Texture Sampling에서는 Mip Chain에서 사용할 Level 위치를 나타낸다.

```text
LOD 0
Mip 0 원본 Level

LOD 1
Mip 1

LOD 2.5
Mip 2와 Mip 3 사이 위치
```

LOD는 반드시 정수일 필요가 없다.

Mipmap Filter가 Linear이면 인접한 두 Mip Level 결과를 Fraction으로 결합할 수 있다.

Sampler의 Min LOD, Max LOD와 LOD Bias가 최종 선택 범위를 조절할 수 있다.

---

## Bilinear와 Mipmap

Unity Texture Importer의 Bilinear Filter는 일반적으로 선택된 한 Mip Level 안에서 Linear Filtering을 수행한다.

```text
LOD 계산
↓ 가까운 Mip Level 하나 선택
선택된 Level의 2×2 Texel
↓ Bilinear
Sample Result
```

Mip Level 경계에서 LOD가 바뀌면 두 Level의 Detail 차이가 눈에 띄는 Band처럼 보일 수 있다.

이 전환을 부드럽게 만드는 방식이 Trilinear Filtering이다.

---

## Trilinear Filtering

Trilinear Filtering은 인접한 두 Mip Level에서 각각 Bilinear Sample을 계산하고 두 결과를 다시 선형 보간한다.

```text
Mip N
2×2 Texel Bilinear
↓ Result A

Mip N+1
2×2 Texel Bilinear
↓ Result B

LOD Fraction
↓ lerp(A, B, fraction)
Final Result
```

개념적으로 최대 여덟 Texel이 결과에 참여할 수 있다.

Mip Level 전환이 부드러워지지만 한 Level만 읽는 Bilinear보다 Texture Access와 Filtering 비용이 증가할 수 있다.

실제 비용은 Texture Unit, Cache와 Platform에 따라 측정해야 한다.

---

## Point, Bilinear, Trilinear 비교

| Filter Mode | Level 내부 Filter | Mip Level Filter | 특징 |
| --- | --- | --- | --- |
| Point | Nearest | 가까운 Level | 선명한 Texel, Alias 가능 |
| Bilinear | Linear 2×2 | 한 Level 선택 | Level 내부 부드러움 |
| Trilinear | Linear 2×2 | 두 Level Linear 결합 | Mip 전환 부드러움 |

Unity의 이름은 일반적인 동작을 나타내지만 Target Graphics API의 실제 Sampler State로 변환되는 세부사항을 확인해야 할 수 있다.

---

## 비스듬한 Surface의 문제

바닥이나 도로를 낮은 Camera Angle에서 보면 화면 Pixel의 Texture Footprint가 정사각형이 아니라 길게 늘어난 형태가 된다.

```text
정면 Surface
Texture Footprint ≈ 정사각형

비스듬한 Surface
Texture Footprint ≈ 길쭉한 타원
```

일반적인 Isotropic Mip 선택은 가장 큰 변화 방향을 기준으로 정사각형에 가까운 Footprint를 가정할 수 있다.

긴 축을 모두 포함하는 작은 Mip을 선택하면 짧은 축 방향의 Detail까지 지나치게 흐려진다.

```text
길쭉한 Footprint
↓ 큰 축 기준 Mip
필요 이상으로 흐린 결과
```

---

## Anisotropic Filtering

Anisotropic Filtering은 Texture Footprint의 방향별 크기 차이를 고려하여 비스듬한 Surface의 Detail을 더 잘 유지한다.

```text
Isotropic
하나의 정사각형에 가까운 Filter

Anisotropic
긴 방향을 따라 여러 Sample로 근사
```

Sampler의 Anisotropy Level이 높을수록 더 큰 방향 비율을 처리할 수 있지만 Sample과 Texture Access 비용이 증가할 수 있다.

```text
Aniso 1
Isotropic에 가까움

Aniso 2, 4, 8, 16
더 큰 비율의 비스듬한 Footprint 처리
```

정확한 Sampling 수와 Algorithm은 GPU 구현에 따라 달라질 수 있다.

Aniso Level이 곧 정확한 고정 Texel Fetch 수라고 해석하면 안 된다.

---

## Anisotropic Filtering이 유용한 경우

다음 Texture는 비스듬한 Surface에서 자주 보이므로 Anisotropic Filtering의 효과가 클 수 있다.

- Terrain
- Road
- Floor
- 긴 Wall
- Runway
- Camera 방향으로 멀리 뻗는 Surface

정면으로만 보이는 UI와 Sprite에서는 효과가 작을 수 있다.

모든 Texture의 Aniso Level을 최대값으로 설정하기보다 화면에서 실제로 비스듬하게 보이고 Detail이 필요한 Texture에 적용한다.

Target GPU의 Texture Bandwidth와 Frame Time을 측정한다.

---

## Implicit LOD Sampling

일반적인 `SAMPLE_TEXTURE2D`는 Fragment Shader에서 이웃 Invocation의 UV Derivative를 이용해 LOD를 암시적으로 선택한다.

```hlsl
half4 color = SAMPLE_TEXTURE2D(
    _BaseMap,
    sampler_BaseMap,
    input.uv
);
```

```text
Implicit LOD
Shader에 LOD 숫자를 직접 전달하지 않음
↓
GPU가 UV Derivative로 LOD 계산
```

Fragment Shader의 실행 그룹과 Control Flow가 Derivative 계산에 영향을 준다.

같은 실행 그룹에서 Texture나 Sampler 선택이 불균일하고 Target이 이를 지원하지 않으면 Implicit LOD가 정의되지 않을 수 있다.

---

## Explicit LOD Sampling

특정 Mip Level을 직접 지정할 수 있다.

Unity Macro 예시는 다음과 같다.

```hlsl
half4 color = SAMPLE_TEXTURE2D_LOD(
    _BaseMap,
    sampler_BaseMap,
    input.uv,
    lod
);
```

```text
LOD = 0
원본 Mip 요청

LOD = 3
Mip 3 요청
```

Vertex Shader처럼 Screen Space Fragment Derivative를 사용할 수 없는 Stage에서는 Explicit LOD가 필요할 수 있다.

LOD를 항상 `0`으로 고정하면 멀리 있는 Surface에서도 고해상도 Level을 읽어 Alias와 Cache 비용이 커질 수 있다.

특수한 효과와 Data Lookup 목적에 맞게 사용한다.

---

## Explicit Gradient Sampling

LOD 숫자 대신 UV의 X와 Y 방향 Gradient를 직접 제공할 수 있다.

HLSL 개념으로는 `SampleGrad` 계열을 사용할 수 있다.

```hlsl
float2 uvDx = ddx(input.uv);
float2 uvDy = ddy(input.uv);

half4 color = _BaseMap.SampleGrad(
    sampler_BaseMap,
    input.uv,
    uvDx,
    uvDy
);
```

UV를 복잡하게 왜곡하거나 Branch 밖에서 미리 계산한 Derivative를 유지해야 하는 경우 사용할 수 있다.

잘못된 Gradient는 지나치게 흐리거나 날카로운 Mip을 선택하여 화질과 성능 문제를 만든다.

---

## LOD Bias

LOD Bias는 계산된 LOD에 Offset을 더한다.

```text
기본 LOD = 3

Bias -1
→ LOD 2, 더 높은 Detail

Bias +1
→ LOD 4, 더 낮은 Detail
```

Negative Bias는 Texture를 더 선명하게 보이게 할 수 있지만 Alias와 Shimmering, Cache 비용을 증가시킬 수 있다.

Positive Bias는 더 흐린 Mip을 선택해 Detail과 비용을 줄일 수 있다.

Temporal Anti-aliasing이나 Upscaling과 함께 Sharpening 전략의 일부로 사용될 수 있지만 Project 전체 화질을 Target Device에서 검증해야 한다.

---

## Sample과 Load는 다르다

Texture Sampling은 Sampler State, Filtering과 LOD 선택을 사용한다.

Texture Load 또는 Fetch는 정수 Texel Coordinate와 명시적인 Mip을 사용하여 특정 Texel을 직접 읽는 방식이다.

```hlsl
float4 value = _DataTexture.Load(int3(texelXY, mipLevel));
```

```text
Sample
Normalized UV
Sampler 필요
Wrap / Filter / LOD 사용

Load
Integer Texel Coordinate
Sampler 없이 특정 Texel Fetch
Filtering 없음
```

화면 Color처럼 부드러운 Filtering이 필요한 Data에는 Sample이 적합하고 정확한 Texel Data가 필요한 Compute와 Lookup에는 Load가 적합할 수 있다.

---

## Texture Gather

Gather는 Sampling 위치 주변 Texel에서 같은 Component를 모아 Vector로 반환하는 Operation이다.

```text
주변 2×2 Texel
각 Texel의 Red Component
↓ Gather
(R00, R10, R01, R11)
```

Shadow Filter, Custom Bilinear와 Image Algorithm에 사용할 수 있다.

Gather는 네 Texel의 완성된 RGBA를 모두 반환하는 일반 Sample과 다르다.

Component 순서와 Coordinate Convention, 지원 Shader Target을 확인해야 한다.

---

## Depth Comparison Sampling

Shadow Map은 일반 Color Texture처럼 Depth를 읽어 Shader에서 한 번 비교할 수도 있지만 Comparison Sampler를 사용할 수 있다.

```text
Shadow Map Depth
Reference Depth
↓ Sampler Compare
Pass 또는 Fail 값
↓ Filtering
Shadow Visibility
```

Percentage-closer Filtering 지원 방식에서는 주변 Depth의 비교 결과가 Filtering에 참여할 수 있다.

일반 Linear Color Sampling과 Depth 값을 먼저 Linear로 섞은 뒤 한 번 비교하는 방식은 결과가 다르다.

Unity URP의 Shadow Sampling Helper를 사용하면 Platform별 Comparison Sampler 처리를 일관되게 연결할 수 있다.

---

## Color Space 변환

sRGB Texture는 저장된 값과 Shader에서 사용하는 Linear Color 값 사이의 변환이 필요할 수 있다.

Texture가 sRGB Format으로 Binding되면 Sampling 과정에서 RGB Channel을 Linear 값으로 Decode할 수 있다.

```text
sRGB Texture 저장값
↓ Hardware Sampling / Format 변환
Linear RGB Shader 값
```

Normal, Metallic, Roughness와 Mask 같은 Data Texture는 Color가 아니므로 일반적으로 sRGB 변환을 적용하지 않아야 한다.

```text
Color Texture
sRGB 설정 검토

Data Texture
Linear Data로 Import 검토
```

잘못된 sRGB 설정은 Sampling Code가 같아도 값의 분포를 바꾼다.

---

## Texture Format과 반환값

Texture Format은 Channel 수, Bit Depth, Signed 여부, Floating-point, Compression과 sRGB 여부를 결정한다.

```text
R8
Red 한 Channel

RGBA8
네 Channel의 8bit 값

RGBAHalf
Half Float 네 Channel

Compressed Format
Block 단위 압축 Data
```

Sampling 결과는 Shader가 선언한 Type과 Format Conversion 규칙에 따라 Vector 값으로 반환된다.

없는 Channel은 Format과 API의 Component 대체 규칙에 따라 기본값으로 채워질 수 있다.

Memory 크기뿐 아니라 Filtering 지원과 정밀도를 확인해야 한다.

---

## Compressed Texture Sampling

GPU Texture Compression은 여러 Texel을 Block으로 압축하여 저장한다.

```text
Compressed Block
여러 Texel의 근사 Data
↓ Texture Unit Decode
Sampled Value
```

Shader가 매번 전체 Image를 CPU 방식으로 압축 해제하는 것은 아니다.

GPU Texture Unit과 Cache가 지원 Format을 Sampling할 수 있다.

압축은 Memory와 Bandwidth를 줄일 수 있지만 Block Artifact, Channel 품질과 Platform 지원 차이가 있다.

Normal Map과 Mask에는 Color Texture와 다른 Compression Format이 적합할 수 있다.

---

## Texture Cache

Texture Sampling은 GPU Memory Access를 포함하므로 Cache Locality의 영향을 받는다.

인접 Fragment가 인접 UV를 Sampling하면 같은 Texture Block과 Mip Data를 재사용할 가능성이 높다.

```text
화면의 인접 Fragment
↓ 비슷한 UV
Texture의 인접 Texel
↓
Cache 재사용 가능
```

무작위 UV, 큰 Texture Array의 불규칙한 Layer 접근과 서로 다른 Texture 선택은 Cache 효율을 낮출 수 있다.

Source의 Sample Instruction 수가 같아도 Access Pattern에 따라 실제 Memory 비용이 달라질 수 있다.

---

## Dynamic Branch와 Sampling

Fragment마다 서로 다른 Branch에서 Texture를 Sampling하면 실행 그룹이 양쪽 경로를 처리할 수 있다.

```hlsl
if (input.mask > 0.5)
{
    color = SAMPLE_TEXTURE2D(_TextureA, sampler_TextureA, input.uv);
}
else
{
    color = SAMPLE_TEXTURE2D(_TextureB, sampler_TextureB, input.uv);
}
```

```text
Invocation Group
A A B B
↓
Texture A 경로와 Texture B 경로를 나누어 실행 가능
```

Compiler가 Branch를 어떻게 변환하는지, Texture 선택이 Uniform한지와 GPU Architecture에 따라 비용이 달라진다.

두 Texture를 항상 Sampling하고 `lerp`하는 방식도 Sample 수를 늘리므로 무조건 더 빠르지 않다.

---

## Derivative와 Control Flow

Implicit LOD는 이웃 Invocation의 UV Derivative에 의존한다.

Branch 안에서 일부 Invocation만 Sampling하거나 Texture와 Sampler가 실행 그룹 안에서 달라지면 Derivative와 LOD가 정의되지 않거나 품질이 불안정할 수 있다.

```text
2 × 2 Fragment Group
일부만 Sample 실행
↓
이웃 UV 차이를 일관되게 계산하기 어려움
```

필요하다면 Branch 전에 Gradient를 계산하고 `SampleGrad`로 전달하는 방식을 검토할 수 있다.

정확한 규칙은 Shader Model과 Target Graphics API를 확인해야 한다.

---

## Vertex Shader에서 Texture Sampling

Vertex Shader에서도 지원되는 Shader Target과 Texture Type에서 Sampling할 수 있다.

Screen Space Fragment Neighbor가 없으므로 일반적인 Implicit Derivative 기반 LOD 선택을 사용할 수 없다.

```hlsl
float height = SAMPLE_TEXTURE2D_LOD(
    _HeightMap,
    sampler_HeightMap,
    input.uv,
    0
).r;
```

Height Map으로 Vertex Position을 변형할 수 있다.

```text
Vertex UV
↓ Explicit LOD Sample
Height
↓ Position Offset
Displaced Vertex
```

Vertex 수만큼 Texture Access가 발생하고 Mesh Tessellation이 낮으면 변형 Detail도 제한된다.

---

## Fullscreen Shader의 Sampling

Post-processing은 Scene Color Texture를 Screen UV로 Sampling한다.

```hlsl
half4 color = SAMPLE_TEXTURE2D(
    _BlitTexture,
    sampler_LinearClamp,
    input.texcoord
);
```

```text
Scene Render Target
↓ Texture로 Binding
Fullscreen Triangle
↓ Fragment Shader Sampling
새 Render Target
```

Blur는 주변 UV를 여러 번 Sampling한다.

```hlsl
color += SAMPLE_TEXTURE2D(_Source, sampler_Source, uv + offsetX);
color += SAMPLE_TEXTURE2D(_Source, sampler_Source, uv - offsetX);
```

화면 전체에서 Sample 수가 반복되므로 Resolution과 Sample 횟수가 비용에 직접 영향을 줄 수 있다.

---

## Normal Map Sampling

Normal Map은 RGB를 그대로 최종 Color로 쓰지 않고 Surface 방향 Data로 Decode한다.

```text
Normal Map Texel
↓ Sample
Encoded Vector 값
↓ Unpack / Decode
Tangent Space Normal
```

Linear Filtering으로 주변 Encoded Normal이 결합되면 Decode 후 Vector 길이가 1이 아닐 수 있어 Normalize가 필요할 수 있다.

Texture Import Type과 Compression도 Normal Data에 맞아야 한다.

Tangent Space와 Normal Map 적용의 세부 흐름은 다음 `4-6` 문서에서 다룬다.

---

## Mask Texture Sampling

여러 Scalar Material 값을 한 Texture Channel에 Packing할 수 있다.

```text
R = Metallic
G = Occlusion
B = Detail Mask
A = Smoothness
```

```hlsl
half4 mask = SAMPLE_TEXTURE2D(_MaskMap, sampler_MaskMap, input.uv);

half metallic = mask.r;
half occlusion = mask.g;
half smoothness = mask.a;
```

한 Sample로 여러 값을 읽을 수 있어 Texture Access와 Memory Binding을 줄일 수 있다.

각 Channel이 같은 Resolution, UV, Filter, Mipmap과 Compression 요구를 가져야 한다.

서로 다른 성격의 Data를 억지로 묶으면 Mip Filter와 품질 제어가 어려워질 수 있다.

---

## Texture Atlas와 Filtering

Texture Atlas는 여러 Image를 하나의 큰 Texture 영역에 배치한다.

```text
+---------+---------+
| Image A | Image B |
+---------+---------+
| Image C | Image D |
+---------+---------+
```

UV는 각 Sub-image 영역으로 Scale과 Offset된다.

Linear Filtering과 Mipmap은 경계 밖 이웃 Texel을 읽을 수 있어 다른 Image Color가 섞이는 Bleeding이 생길 수 있다.

```text
Sub-image Edge
↓ Bilinear / Mipmap
옆 Image Texel 참여
↓
Color Bleeding
```

Padding, Edge Dilate, Mip-safe Layout와 적절한 Wrap Mode가 필요하다.

Atlas의 상세 목적과 Trade-off는 이후 Texture Atlas 문서에서 다룬다.

---

## Sprite와 Pixel Art

Pixel Art는 Texel 경계를 그대로 보여 주기 위해 Point Filter를 사용하는 경우가 많다.

```text
Point Filter
Texel Block 유지

Bilinear
이웃 Color가 섞여 흐려짐
```

하지만 Camera Scale과 Sprite Position이 Pixel Grid에 맞지 않으면 Point Filter만으로 흔들림과 불균일한 Pixel 크기가 해결되지 않는다.

Pixel Perfect Camera, Render Resolution, Sprite Pixels Per Unit과 Compression도 함께 확인한다.

---

## RenderTexture Sampling

RenderTexture는 GPU가 Render Target으로 쓴 Image를 이후 Pass에서 Texture로 Sampling할 수 있게 한다.

```text
Pass A
RenderTexture에 Color Write
↓ Resource Transition과 Pipeline 연결
Pass B
RenderTexture Sampling
```

Color, Depth, Normal과 Custom Buffer를 후속 Shader에서 읽을 수 있다.

같은 Resource를 동시에 읽고 쓰는 것은 Data Hazard를 만들 수 있으므로 Render Graph와 Graphics API의 Synchronization이 필요하다.

Unity Render Pipeline API가 관리하는 Temporary Texture와 Render Graph Resource Lifetime을 따른다.

---

## Texture Streaming

큰 Texture의 모든 고해상도 Mip을 항상 Memory에 유지하지 않고 Camera 거리와 사용 상황에 따라 필요한 Mip을 Load할 수 있다.

```text
멀리 있는 Object
작은 Mip 중심으로 Resident

가까이 이동
더 높은 Detail Mip Streaming
```

Sampler가 높은 Detail Level을 요청해도 해당 Mip이 아직 Resident하지 않으면 사용 가능한 Level 범위에서 결과가 제한될 수 있다.

Texture Streaming은 Sampling Algorithm과 별도로 Resource Residency와 Memory Budget을 관리한다.

세부 동작은 이후 Texture Streaming 문서에서 다룬다.

---

## Unity URP 예제

Base Texture를 Sampling하는 기본 Shader는 다음 구조를 가질 수 있다.

```shaderlab
Shader "Custom/TextureSampling"
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
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
        }

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv         : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv         : TEXCOORD0;
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
                half4 _BaseColor;
            CBUFFER_END

            Varyings vert(Attributes input)
            {
                Varyings output;
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                half4 sampledColor = SAMPLE_TEXTURE2D(
                    _BaseMap,
                    sampler_BaseMap,
                    input.uv
                );

                return sampledColor * _BaseColor;
            }
            ENDHLSL
        }
    }
}
```

---

## 예제의 Sampling Flow

```text
Mesh UV
↓ Vertex Shader
Tiling과 Offset 적용
↓ Rasterizer
Perspective-correct Fragment UV
↓ Fragment Shader
SAMPLE_TEXTURE2D
├─ Texture: _BaseMap
├─ Sampler: sampler_BaseMap
└─ Coordinate: input.uv
↓
Filtered Texture Color
↓ _BaseColor 곱
Source Color
```

Shader Code에는 주변 Texel과 Mip Level 선택이 직접 보이지 않지만 Sampler와 Texture Unit이 설정에 맞춰 처리한다.

---

## Custom Sampler State

URP HLSL에서 이름 규칙을 이용한 Inline Sampler State를 사용할 수 있는 범위가 있다.

개념적인 이름은 다음과 같다.

```hlsl
SamplerState sampler_PointClamp;
SamplerState sampler_LinearRepeat;
```

```text
PointClamp
Point Filter + Clamp Address

LinearRepeat
Linear Filter + Repeat Address
```

정확한 선언 규칙과 지원 Platform은 Unity Manual의 Sampler State 문서를 확인해야 한다.

Custom Sampler를 사용하면 Texture Importer 설정과 다른 Sampling 규칙을 적용할 수 있지만 Sampler 수 제한과 Platform 변환을 고려한다.

---

## Sampling 비용을 판단하는 항목

Texture Sample Instruction 수만으로 전체 비용을 확정할 수 없다.

```text
Sample 수
× Filter 종류
× Mip Level 수
× Anisotropy
× Fragment Invocation 수
× Cache Miss와 Memory Format
```

다음 요소가 영향을 준다.

- Texture Resolution과 Format
- Compression
- Mipmap 사용 여부
- Bilinear와 Trilinear
- Aniso Level
- UV Locality
- Texture Array Layer 접근
- Fragment Overdraw
- Render Resolution
- Branch Divergence
- Sample이 의존하는 결과의 Latency

같은 네 번의 Sampling도 Cache에 잘 맞는 작은 Texture와 불규칙하게 접근하는 큰 Texture의 비용이 다를 수 있다.

---

## Sample 수 줄이기

Texture Sampling이 실제 병목일 때 다음 방법을 검토할 수 있다.

- 여러 Scalar Map을 Channel Packing
- 반복해서 읽는 값을 한 번 Sampling하고 재사용
- 필요하지 않은 Feature와 Keyword 제거
- 낮은 Frequency Data를 Vertex 또는 낮은 Resolution Pass에서 계산
- Lookup Texture를 더 작은 Format과 Resolution으로 조정
- Blur를 Separable Filter로 분리
- Texture Cache에 유리한 Access Pattern 구성

Sample 수를 줄이는 대신 추가 ALU, Variant, Packing Artifact와 Authoring 복잡도가 생길 수 있다.

GPU Profiler와 Target Hardware Counter로 Texture Unit 또는 Bandwidth 병목인지 먼저 확인한다.

---

## Mipmap 설정 최적화

3D Surface에서 축소되는 Texture는 Mipmap이 품질과 성능에 도움이 되는 경우가 많다.

```text
Mipmaps On
추가 Memory
Alias 감소
멀리서 작은 Level Sampling

Mipmaps Off
Memory 감소
항상 Base Level 사용
Minification Alias와 Cache 비용 가능
```

UI, Lookup Table, Font Atlas와 특수 Data Texture는 Mipmap 요구가 다르다.

Alpha Cutout Texture는 Mip Downsampling으로 Coverage가 달라질 수 있으므로 Alpha Coverage 보존 기능을 검토할 수 있다.

Texture 용도별로 Import Preset을 구성하는 편이 일관적이다.

---

## Filter Mode 선택

```text
Pixel Art와 정확한 이산 값
→ Point 검토

일반 2D Color와 확대
→ Bilinear 검토

3D Surface의 Mip 전환
→ Trilinear 검토

비스듬한 바닥과 도로
→ Anisotropic Filtering 검토
```

Trilinear와 높은 Aniso를 모든 Texture에 적용하는 방식은 Memory Access 비용을 늘릴 수 있다.

Point를 모든 Texture에 적용하면 Alias와 Block Artifact가 생긴다.

표현 목적과 Camera 관계, Platform 성능을 기준으로 선택한다.

---

## Texture Debugging

### UV 표시

```hlsl
return half4(frac(input.uv), 0.0h, 1.0h);
```

UV Tiling과 방향을 Color Gradient로 확인할 수 있다.

### Mip Level 표시

Unity와 Platform Debug Tool의 Mipmap Visualization을 사용하면 화면에서 선택되는 Mip과 Streaming 상태를 확인할 수 있다.

### Sample 값 표시

```hlsl
half4 value = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv);
return value;
```

Material Tint와 Lighting을 제거하고 Texture Sample만 출력하면 Import, UV와 Sampling 문제를 분리하기 쉽다.

### Graphics Debugger

RenderDoc, PIX와 Xcode GPU Frame Debugger에서 Binding된 Texture, Mip Chain, Sampler State와 Pixel History를 확인할 수 있다.

---

## 자주 생기는 오해

### UV는 Pixel Coordinate다

일반 UV는 `0~1` 범위의 정규화 Texture Coordinate다.

Texture Size와 Sampling Operation이 Texel 위치로 변환한다.

### Sample 한 번은 Texel 하나를 읽는다

Point Filter는 하나에 가까운 Texel을 선택하지만 Bilinear, Trilinear와 Anisotropic Filtering은 여러 Texel과 Level을 사용할 수 있다.

### Bilinear는 네 Pixel을 섞는다

화면 Pixel이 아니라 Texture의 한 Mip Level에 있는 주변 네 Texel을 결합한다.

### Trilinear는 3D Texture만을 위한 Filter다

2D Texture의 두 Mip Level에서 Bilinear 결과를 계산하고 Level 사이를 선형 보간하는 이름이다.

### Mipmap은 Texture를 멀리서 흐리게 만드는 품질 저하 기능이다

Minification Footprint에 맞는 축소 Data를 사용하여 Alias를 줄이고 Cache 효율을 높이는 목적이 있다.

### Mipmap은 Memory를 줄인다

완전한 Chain은 원본 외의 Level을 추가하므로 Texture Memory가 증가한다.

Streaming은 필요한 Level만 Resident하게 하여 Runtime Memory를 별도로 관리할 수 있다.

### Aniso 16은 정확히 16 Texel만 읽는다

Anisotropy는 최대 방향 비율과 Filtering 품질을 제어하며 실제 Sample Algorithm과 수는 GPU 구현에 따라 달라질 수 있다.

### Texture가 같으면 Sample 결과도 같다

UV, Sampler, Mip, Format, sRGB 변환과 Shader Sampling Function이 다르면 결과가 달라진다.

### 모든 Texture는 sRGB여야 한다

Color Texture에는 sRGB Decode가 필요할 수 있지만 Normal, Mask와 다른 수치 Data는 Linear Import가 적합하다.

---

## Sampling 단계 정리

| 단계 | 입력 | 결정하는 것 |
| --- | --- | --- |
| Coordinate | UV 또는 명시 좌표 | Texture의 논리적 위치 |
| Addressing | Repeat, Clamp, Mirror | 범위 밖 Coordinate 처리 |
| Derivative | 이웃 Fragment UV 변화 | Texture Footprint |
| LOD | Footprint, Bias, 범위 | 사용할 Mip Level |
| Min/Mag Filter | Point 또는 Linear | Level 내부 Texel 결합 |
| Mipmap Filter | Nearest 또는 Linear | Mip Level 사이 결합 |
| Anisotropy | 방향별 Footprint 비율 | 비스듬한 Surface Filter |
| Format 처리 | Texture Format | Channel과 Color Space 변환 |
| Output | Filter된 값 | Shader 계산 Input |

```text
Texture + UV + Sampler
↓
Addressing
↓
LOD와 Mip 선택
↓
Texel Filtering
↓
Sampled Value
```

---

## 정리

Texture Sampling은 Texture Resource에서 UV 위치의 값을 읽고 Sampler State에 따라 주변 Texel을 Filter하여 Shader 값으로 반환하는 과정이다.

```text
Texture
Texel Data

UV
읽을 Coordinate

Sampler
Wrap, Filter, Mip와 Anisotropy 규칙

↓
Sampled Value
```

Texel은 Texture의 요소이며 Render Target의 Pixel과 구분해야 한다.

일반적인 UV는 Texture Resolution과 독립적인 정규화 Coordinate이고 Mesh의 Vertex Attribute에서 Fragment까지 Perspective-correct Interpolation될 수 있다.

Wrap Mode는 `0~1` 범위 밖의 UV를 처리한다.

Repeat는 Texture를 반복하고 Clamp는 Edge 값을 유지하며 Mirror는 반복 방향을 번갈아 뒤집는다.

Point Filtering은 가장 가까운 Texel을 선택하고 Bilinear Filtering은 한 Mip Level의 주변 2×2 Texel을 결합한다.

Mipmap은 원본 Texture를 단계적으로 축소한 Chain으로 Minification Alias를 줄이고 작은 화면 Footprint에 적합한 Data를 제공한다.

일반적인 Fragment Sampling은 이웃 Fragment의 UV Derivative로 Texture Footprint와 LOD를 계산한다.

Trilinear Filtering은 인접한 두 Mip Level에서 Bilinear 결과를 만든 뒤 Level 사이를 다시 보간한다.

Anisotropic Filtering은 비스듬한 Surface에서 길쭉한 Texture Footprint를 고려하여 Detail을 유지한다.

```text
Point
가장 가까운 Texel

Bilinear
한 Level의 2×2 Texel

Trilinear
두 Level의 Bilinear 결과

Anisotropic
방향성이 큰 Footprint를 여러 Sample로 근사
```

`SAMPLE_TEXTURE2D`는 Sampler, Filter와 Implicit LOD를 사용하는 Sampling이며 `Load`는 정수 Texel Coordinate에서 특정 값을 Filtering 없이 가져오는 Fetch다.

Color Texture와 Normal·Mask 같은 Data Texture는 sRGB 설정, Format, Compression과 Mipmap 요구가 다르다.

Sampling 비용은 Source의 명령 수뿐 아니라 Filter, Mip, Anisotropy, Cache Locality, Format, Fragment Invocation과 Overdraw에 영향을 받는다.

Texture 최적화는 Sample 수를 무조건 줄이거나 모든 Filter 품질을 낮추는 방식보다 실제 Texture Unit, Memory Bandwidth와 Fragment 병목을 측정한 뒤 적용해야 한다.
