---
title: "[궁금시리즈] 10-8. Unity Asset은 메모리를 얼마나 사용할까?"
excerpt: "C#"
categories:
  - CSharp
series: question-series
tags:
  - CSharp
permalink: /programming/10-8-unity-asset-memory/
toc: true
toc_sticky: true
date: 2026-08-16 12:00:28 +0900
last_modified_at: 2026-08-16 12:00:28 +0900
---

## 들어가며

Project 창에서 PNG 파일의 크기가 2MB라고 해서 게임에서도 Texture가 2MB만 사용하는 것은 아니다.

```text
Source PNG
2MB

Runtime Texture
해상도 × Pixel Format × Mipmap
```

PNG와 JPEG의 파일 크기는 디스크에 저장하기 위한 압축 결과다. GPU가 Rendering에 사용하는 Texture는 Build Target에 맞는 Runtime Format으로 변환된다.

Mesh와 Audio도 같은 원리가 적용된다.

```text
Asset 원본 파일 크기
Build에 포함되는 변환 결과 크기
Load 후 CPU Memory 크기
GPU 또는 Audio System Memory 크기
```

이 값들은 서로 같지 않다.

Unity Asset 메모리를 줄이려면 파일 탐색기의 크기보다 Runtime에서 어떤 데이터가 어디에 유지되는지 확인해야 한다.

---

## 개념 설명

### 디스크 크기와 Runtime Memory

Asset은 Import 과정에서 Build Target에 맞는 형식으로 변환된다.

```text
Source Asset
PNG / FBX / WAV
↓ Import
Unity의 Import 결과
↓ Build
플랫폼용 Texture / Mesh / Audio 데이터
↓ Load
CPU와 GPU 또는 Audio System Memory
```

Source 파일이 잘 압축되어 작아도 Runtime에서 압축을 풀거나 GPU Format으로 변환하면 더 큰 메모리를 사용할 수 있다.

### Texture Memory

압축하지 않은 Texture의 기본 크기는 대략 다음 값으로 계산할 수 있다.

```text
가로 × 세로 × Pixel당 Byte
```

4096 × 4096 RGBA32 Texture는 Pixel당 4Byte를 사용한다.

```text
4096 × 4096 × 4
= 67,108,864Byte
≈ 64MiB
```

여기에 Mipmap, CPU Read/Write 복사본과 Runtime의 추가 데이터가 붙을 수 있다.

Block Compression을 지원하는 Format을 사용하면 Pixel당 평균 비용을 크게 낮출 수 있다. 지원 Format과 품질은 플랫폼마다 다르다.

### Mipmap

Mipmap은 원본 Texture보다 작은 해상도의 단계를 함께 저장한다.

```text
1024 × 1024
512 × 512
256 × 256
128 × 128
...
1 × 1
```

멀리 있는 표면에 작은 Mip Level을 사용하면 Sampling 품질과 Cache 효율이 좋아진다. 대신 모든 Mip Level을 메모리에 올리면 원본 Level만 사용할 때보다 추가 공간이 필요하다.

Mipmap을 무조건 끄면 메모리 일부는 줄 수 있지만 3D Rendering에서 깜빡임과 Texture Cache 효율 저하가 생길 수 있다. UI처럼 화면 크기가 고정된 Texture와 원근으로 축소되는 3D Texture는 기준이 다르다.

### Mesh Memory

Mesh는 Vertex와 Index 데이터를 저장한다.

```text
Vertex Position
Normal
Tangent
UV
Color
Bone Weight
Index Buffer
Blend Shape
```

Vertex 수만 같아도 포함한 Attribute가 많을수록 한 Vertex의 크기가 커진다. SubMesh, Blend Shape와 Skinning 데이터도 추가 비용을 만든다.

### Audio Memory

AudioClip은 Load Type에 따라 메모리와 CPU 비용이 달라진다.

```text
Decompress On Load
└─ Load할 때 압축 해제, 메모리 사용 증가, 재생 CPU 부담 감소

Compressed In Memory
└─ 압축 상태로 보관, 재생 중 Decode 비용 발생

Streaming
└─ 디스크에서 일부씩 읽고 Buffer 유지, 메모리 감소, Streaming 비용 발생
```

짧고 자주 재생하는 Sound Effect와 긴 BGM에 같은 설정을 적용할 이유가 없다.

---

## 코드 예제

### Texture 크기 추정

단순한 Uncompressed Texture 크기를 계산한다.

```cs
public static long EstimateRgba32Bytes(
    int width,
    int height)
{
    const int bytesPerPixel = 4;
    return (long)width * height * bytesPerPixel;
}
```

```cs
long bytes = EstimateRgba32Bytes(4096, 4096);
float mebibytes = bytes / (1024f * 1024f);

Debug.Log(mebibytes); // 약 64MiB
```

이 계산은 특정 Format의 Level 0만 단순 추정한 값이다. 실제 Import Format, Mipmap과 CPU 복사본을 반영하려면 Profiler와 Inspector의 Runtime 정보를 확인해야 한다.

### 해상도 감소 효과

가로와 세로를 절반으로 줄이면 Pixel 수는 1/4이 된다.

```text
4096 × 4096
= 16,777,216 Pixel

2048 × 2048
= 4,194,304 Pixel
```

Texture 최적화에서 Max Size 조정의 효과가 큰 이유다. 화면에서 실제로 필요한 해상도보다 큰 Texture를 사용하고 있는지 먼저 확인한다.

### Runtime Texture의 CPU 복사본 제거

스크립트에서 만든 Texture는 Pixel 데이터를 GPU에 적용한 뒤 CPU 복사본이 더 이상 필요하지 않을 수 있다.

```cs
Texture2D texture = new(
    width,
    height,
    TextureFormat.RGBA32,
    mipChain: true);

texture.SetPixels(colors);
texture.Apply(
    updateMipmaps: true,
    makeNoLongerReadable: true);
```

`makeNoLongerReadable`을 `true`로 지정하면 Upload 후 CPU 측 Texture Data를 제거할 수 있다. 이후 `GetPixels()`나 `SetPixels()`처럼 CPU 접근이 필요한 작업은 사용할 수 없다.

Import Asset은 Texture Import Settings의 Read/Write 옵션으로 CPU 접근 필요 여부를 정한다.

### Texture를 참조하는 Material 복제

Renderer의 `material`에 접근하면 해당 Renderer 전용 Material Instance가 만들어질 수 있다.

```cs
Material runtimeMaterial = renderer.material;
runtimeMaterial.color = Color.red;
```

반복 호출이나 정리되지 않은 Material Instance는 Asset 자체와 별도의 Runtime 객체를 늘릴 수 있다.

공유 Material을 수정할 의도라면 `sharedMaterial`, Renderer별 값만 바꿀 목적이라면 `MaterialPropertyBlock` 같은 방식을 검토한다.

```cs
private readonly MaterialPropertyBlock block = new();

public void SetColor(Renderer target, Color color)
{
    target.GetPropertyBlock(block);
    block.SetColor(BaseColorId, color);
    target.SetPropertyBlock(block);
}
```

사용 중인 Render Pipeline과 Shader가 Property Block 변경에 적합한지도 확인해야 한다.

### Audio Data 수명 제어

Preload를 사용하지 않는 AudioClip은 필요한 시점에 Data를 Load할 수 있다.

```cs
public IEnumerator PrepareAudio(AudioClip clip)
{
    clip.LoadAudioData();

    while (clip.loadState == AudioDataLoadState.Loading)
    {
        yield return null;
    }

    if (clip.loadState != AudioDataLoadState.Loaded)
    {
        throw new InvalidOperationException(
            $"Audio load failed: {clip.name}");
    }
}
```

사용이 끝난 Clip의 Audio Data는 설정과 소유 관계에 따라 `UnloadAudioData()`를 검토할 수 있다.

```cs
clip.UnloadAudioData();
```

AudioClip Asset 자체의 참조와 내부 Audio Data Load 상태는 같은 개념이 아니다.

---

## 내부 동작

### Texture Format과 Block Compression

RGBA32는 Pixel마다 R, G, B, A 값을 직접 저장한다.

```text
R 1Byte
G 1Byte
B 1Byte
A 1Byte
= Pixel당 4Byte
```

GPU Texture Compression은 일정 크기의 Pixel Block을 압축된 단위로 저장한다. Runtime Memory는 Source PNG의 압축률이 아니라 선택된 GPU Format의 Block 크기와 해상도로 결정된다.

지원하지 않는 Format은 Runtime에 다른 Format으로 변환되는 Fallback이 생길 수 있다. 이 경우 예상보다 메모리가 커지고 Load CPU 비용도 추가될 수 있다.

### Mipmap의 추가 데이터

각 Mip Level은 가로와 세로가 절반이므로 Pixel 수는 이전 Level의 약 1/4이다.

```text
Level 0: 1
Level 1: 1/4
Level 2: 1/16
Level 3: 1/64
...
```

전체 합은 Level 0보다 약 1/3 큰 값에 가까워진다. 압축 형식의 Block 단위와 작은 Level 정렬 때문에 실제 수치는 달라질 수 있다.

### Read/Write 복사본

GPU에 올린 Texture를 Rendering에만 사용한다면 CPU가 전체 Pixel Data를 계속 보관할 필요가 없을 수 있다.

```text
Read/Write 비활성
GPU 사용 데이터 중심

Read/Write 활성
CPU가 접근할 수 있는 Texture Data 추가 유지
```

Unity 공식 문서는 Import Texture의 Read/Write를 활성화하면 Script 접근용 복사본 때문에 Texture에 필요한 메모리가 두 배가 될 수 있다고 설명한다.

Mesh도 Read/Write Enabled가 켜져 있으면 Runtime에 Vertex Data를 읽거나 수정할 수 있도록 CPU 측 접근 가능 데이터를 유지한다. Runtime Mesh 수정이나 일부 시스템에 필요하지 않다면 비활성화를 검토한다.

### Mesh Vertex Layout

Mesh의 Runtime 크기는 Triangle 수만으로 결정되지 않는다.

```text
Vertex Count
×
Position + Normal + Tangent + UV Channel + Color + Skinning
+
Index Buffer
+
Blend Shape
```

사용하지 않는 Vertex Color, 여분의 UV Channel과 Blend Shape가 Import되어 있는지 확인한다.

Index Format도 최대 Vertex 수와 저장 크기에 영향을 준다. 16-bit Index로 표현 가능한 Mesh와 32-bit Index가 필요한 Mesh의 비용이 다르다.

### Audio Decode 위치

Decompress On Load는 전체 Audio Sample을 재생 전에 메모리에 준비한다. 재생 중 Decode 비용은 줄지만 긴 Clip에서는 상주 메모리가 크게 늘 수 있다.

Compressed In Memory는 압축 데이터를 메모리에 유지하고 재생 중 Mixer Thread에서 Decode한다.

Streaming은 일부 Buffer만 유지하며 디스크에서 순차적으로 읽고 별도 Streaming Thread에서 Decode한다. 메모리 사용은 줄지만 Clip마다 Buffer와 Streaming Overhead가 있고 저장 장치 접근이 필요하다.

---

## 실제 Unity에서는?

### 플랫폼별 Texture Override를 설정한다

동일 Texture라도 PC, Android와 iOS가 지원하는 압축 Format이 다르다.

```text
Default 설정
↓
Android Override
Max Size / Format / Compression
↓
iOS Override
Max Size / Format / Compression
```

Editor에서 선택한 Platform과 실제 Target Device의 지원 Format을 기준으로 확인한다. 자동 설정만 사용한 채 모든 플랫폼에서 같은 메모리와 품질이 나온다고 가정하지 않는다.

### Alpha Channel 필요 여부를 확인한다

Alpha를 사용하지 않는 Texture에 Alpha Channel이 포함되면 더 비싼 Format이 선택되거나 불필요한 Channel Data가 유지될 수 있다.

Texture 목적별로 다음 항목을 확인한다.

```text
실제 Alpha 사용 여부
Normal Map Import Type
sRGB 또는 Linear Data
Max Size
Mipmap 필요 여부
Read/Write 필요 여부
```

### Mipmap Streaming을 사용한다

큰 3D World에서 모든 Texture의 최고 Mip Level을 동시에 Load할 필요는 없다.

Mipmap Streaming은 Camera와 Memory Budget을 기준으로 필요한 Mip Level을 Load한다.

```text
가까운 Texture
└─ 높은 해상도 Mip 요청

먼 Texture
└─ 낮은 해상도 Mip 사용

Memory Budget 초과
└─ Priority가 낮은 Texture의 해상도 조정
```

Streaming을 활성화해도 Texture별 Import 설정, Camera와 Quality Settings의 Budget 구성이 필요하다. UI, Sprite Atlas와 항상 최고 해상도가 필요한 Texture는 별도 기준을 적용한다.

### Mesh Read/Write를 목적에 맞게 사용한다

다음 기능은 CPU 측 Mesh Data가 필요할 수 있다.

```text
Runtime Vertex 수정
일부 Mesh 기반 Collision 생성
특정 Navigation 또는 Geometry 처리
CPU에서 Vertex 읽기
```

Import 후 Rendering에만 사용하는 정적 Mesh까지 모두 Read/Write를 켜 두면 불필요한 CPU 측 데이터가 유지될 수 있다.

### AudioClip을 길이와 재생 빈도로 분류한다

```text
짧고 자주 재생하는 효과음
└─ Decode CPU와 동시 재생 수를 고려

긴 BGM과 대사
└─ Compressed In Memory 또는 Streaming 검토

드물게 사용하는 Clip
└─ Preload와 Load In Background 검토
```

Audio 설정은 메모리만 줄이면 재생 중 CPU나 I/O Spike가 늘 수 있다. Audio Profiler의 Total Audio Memory, DSP CPU와 Streaming CPU를 함께 확인한다.

### Memory Profiler Snapshot으로 실제 크기를 본다

Asset Import 설정을 바꾼 뒤 예상 계산만 비교하지 않는다.

```text
동일 Scene과 Camera 위치
동일 Target Device
변경 전 Snapshot
↓
Import 설정 변경과 Build
↓
변경 후 Snapshot
```

Texture, Mesh와 AudioClip 수, Native Size, Graphics Memory와 전체 Peak를 확인한다.

---

## 실무에서 자주 하는 오해

### PNG 파일이 작으면 Texture Memory도 작다

PNG 크기는 Source의 디스크 압축 결과다. Runtime Memory는 Import된 Texture Format, 해상도, Mipmap과 CPU 복사본에 따라 결정된다.

### Texture 해상도를 절반으로 줄이면 메모리도 절반이다

가로와 세로를 각각 절반으로 줄이면 Pixel 수는 1/4이 된다. 동일 Format이라면 Level 0 메모리도 대략 1/4로 줄어든다.

### Mipmap은 메모리만 낭비한다

추가 메모리는 사용하지만 멀리 있는 Texture의 Sampling 품질과 Cache 효율을 높인다. Mipmap Streaming을 사용하면 필요한 Level 중심으로 메모리를 관리할 수 있다.

### Read/Write는 Inspector 옵션일 뿐 Runtime 비용이 없다

Texture와 Mesh를 Script에서 읽거나 수정할 수 있도록 CPU 측 데이터를 유지한다. 실제로 Runtime 접근이 필요한 Asset에만 사용해야 한다.

### Crunch Compression을 사용하면 GPU Memory도 같은 비율로 줄어든다

Crunch는 배포 데이터의 압축에 유리하지만 Runtime에서는 DXT나 ETC 같은 GPU Format으로 풀어 Upload할 수 있다. Build 크기와 GPU Runtime Memory를 구분해야 한다.

### Triangle 수만 줄이면 Mesh Memory가 해결된다

Vertex Attribute, Index Format, UV Channel, Skinning과 Blend Shape도 Mesh 크기에 영향을 준다. Triangle 수 하나만으로 판단할 수 없다.

### Streaming Audio는 메모리를 전혀 사용하지 않는다

디스크에서 일부씩 읽더라도 압축 데이터와 Decode Stream을 위한 Buffer가 필요하다. Clip 수와 재생 방식에 따른 고정 Overhead도 고려해야 한다.

### 모든 Audio를 압축하면 항상 최적이다

메모리는 줄 수 있지만 재생 중 Decode CPU가 증가한다. 짧은 효과음, 긴 BGM과 동시 재생이 많은 소리에 같은 Format과 Load Type을 적용하지 않는다.

---

## 마무리

Asset의 Source 파일 크기, Build 크기와 Runtime Memory는 서로 다른 값이다.

Texture는 해상도와 GPU Format, Mipmap, Read/Write에 영향을 받고 Mesh는 Vertex Layout과 CPU 접근 데이터, Audio는 Compression Format과 Load Type에 영향을 받는다.

```text
어떤 Asset 영역이 큰가?
↓
Runtime Format과 Load Type 확인
↓
실제 화면과 재생에 필요한 품질 결정
↓
플랫폼별 Import 설정 변경
↓
CPU / GPU / Audio 비용 함께 측정
↓
대상 기기에서 품질과 Memory 재검증
```

가장 큰 Asset부터 해상도, 불필요한 Channel과 Read/Write를 확인하면 작은 Script Allocation을 여러 곳 수정하는 것보다 큰 메모리를 줄일 수 있다.

다만 메모리를 줄인 결과 Decode CPU, I/O와 Rendering 품질이 악화될 수 있다. Asset 최적화는 파일을 작게 만드는 작업이 아니라 Target Device에서 품질과 Runtime 비용의 균형을 정하는 작업이다.

---

## 핵심 정리

- Asset의 Source 파일 크기, Build 크기와 Runtime Memory는 서로 같은 값이 아니다.
- Texture Memory는 주로 해상도, Runtime Format, Mipmap과 CPU Read/Write 복사본에 따라 달라진다.
- 가로와 세로를 절반으로 줄이면 동일 Format의 Pixel 수는 1/4이 된다.
- Mipmap은 추가 공간을 사용하지만 3D Rendering의 Sampling 품질과 Cache 효율에 필요할 수 있다.
- Mipmap Streaming은 Memory Budget에 맞춰 필요한 Mip Level 중심으로 Load한다.
- Texture와 Mesh의 Read/Write는 Runtime CPU 접근에 필요한 데이터를 유지하므로 필요한 Asset에만 사용한다.
- Mesh Memory에는 Vertex 수뿐 아니라 Attribute, Index, Skinning과 Blend Shape도 포함된다.
- Decompress On Load는 Audio Memory를 늘리고 재생 중 Decode 부담을 줄인다.
- Compressed In Memory와 Streaming은 메모리를 줄이는 대신 Decode CPU와 I/O 비용을 사용한다.
- Import 설정은 Target Platform별로 적용하고 실제 기기의 Profiler 결과와 품질을 함께 확인해야 한다.
