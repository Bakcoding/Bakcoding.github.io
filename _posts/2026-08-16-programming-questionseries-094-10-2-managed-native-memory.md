---
title: "[궁금시리즈] 10-2. Managed Memory와 Native Memory는 무엇이 다를까?"
excerpt: "C#"
categories:
  - CSharp
series: question-series
tags:
  - CSharp
permalink: /programming/10-2-managed-native-memory/
toc: true
toc_sticky: true
date: 2026-08-16 12:00:22 +0900
last_modified_at: 2026-08-16 12:00:22 +0900
---

## 들어가며

C# 객체는 Garbage Collector가 관리한다고 알려져 있다.

```cs
PlayerData data = new PlayerData();
data = null;
```

참조가 사라진 `PlayerData`는 나중에 GC가 회수할 수 있다.

하지만 Unity의 Texture나 GameObject도 같은 방식으로만 관리된다고 생각하면 실제 메모리 변화를 설명하기 어렵다.

```cs
Texture2D texture = new Texture2D(4096, 4096);
texture = null;
```

변수에 `null`을 대입했다고 Texture의 모든 메모리가 즉시 반환되는 것은 아니다.

Unity 애플리케이션의 메모리는 크게 다음 영역을 함께 사용한다.

```text
Managed Memory
└─ C# 객체와 GC가 관리하는 Heap

Native Memory
└─ Unity Engine이 C++ 영역에서 관리하는 객체와 리소스

Graphics Memory
└─ GPU가 사용하는 Texture, Buffer 등의 데이터
```

메모리 문제를 해결하려면 어떤 영역에 데이터가 존재하고 누가 수명을 관리하는지 먼저 구분해야 한다.

---

## 개념 설명

### Managed Memory

Managed Memory는 .NET Runtime이 관리하는 메모리 영역이다.

```cs
public sealed class PlayerData
{
    public string Name = string.Empty;
    public int Level;
}

PlayerData player = new();
```

`PlayerData` 객체, 문자열과 배열 같은 참조 타입은 Managed Heap에 저장된다. 더 이상 Root에서 도달할 수 없으면 GC의 회수 대상이 된다.

```text
Root에서 참조 가능
└─ 살아 있는 Managed 객체

Root에서 참조 불가능
└─ 다음 GC에서 회수 가능한 객체
```

개발자가 특정 Managed 객체를 직접 해제할 수는 없다. 참조를 정리한 뒤 GC가 적절한 시점에 회수한다.

### Native Memory

Native Memory는 Unity Engine의 C++ 코드, 플랫폼 라이브러리와 Plugin 등이 사용하는 영역이다.

대표적으로 다음 데이터가 포함될 수 있다.

```text
GameObject와 Component의 Engine 객체
Texture와 Mesh 데이터
Audio Resource
Animation과 Physics 데이터
AssetBundle 내부 데이터
Native Collection
```

Native Resource는 Managed GC가 직접 회수하는 일반 C# 객체가 아니다. Unity의 객체 수명 API나 리소스 관리 규칙에 따라 해제해야 한다.

### Managed Wrapper

`UnityEngine.Object`를 상속한 객체는 C#에서 보이는 Managed Wrapper와 Engine 내부의 Native Object가 연결된 구조를 가진다.

```text
C# 변수
↓
Managed Wrapper
↓ Instance ID 또는 Native Pointer
Native Object
```

```cs
GameObject player = new GameObject("Player");
```

C# 변수 `player`가 참조하는 것은 Managed Wrapper다. 실제 Transform, Component 목록과 Engine 상태는 Native 영역과 함께 관리된다.

### Graphics Memory

Texture와 RenderTexture, Mesh의 Vertex Buffer처럼 GPU가 사용하는 데이터는 Graphics Memory에도 존재할 수 있다.

하나의 Texture Asset이 다음 여러 위치에 비용을 만들 수 있다.

```text
Managed Wrapper
Native Texture Object
CPU 측 Texture Data
GPU 측 Texture Data
```

Import 설정, Read/Write 옵션, 압축 형식과 플랫폼에 따라 실제 구성은 달라진다.

---

## 코드 예제

일반 C# 객체의 수명부터 확인한다.

```cs
public sealed class DamageBuffer
{
    public readonly int[] Values = new int[1024];
}
```

```cs
public void Calculate()
{
    DamageBuffer buffer = new();
    // 계산 수행
}
```

메서드가 끝나고 다른 참조가 없다면 `DamageBuffer`와 배열은 GC가 회수할 수 있다.

### Unity Object의 파괴

Unity Object는 `Destroy()`로 Native Object의 파괴를 요청한다.

```cs
GameObject enemy = new GameObject("Enemy");

Destroy(enemy);
```

`Destroy()`는 일반적으로 현재 Update Loop의 안전한 시점 이후에 실제 파괴를 처리한다. 호출 직후 C# 변수 자체가 사라지는 것도 아니다.

```cs
Destroy(enemy);

Debug.Log(enemy == null); // Unity의 특별한 null 비교
```

Unity는 파괴된 Native Object를 가리키는 Wrapper가 `null`처럼 동작하도록 `UnityEngine.Object`의 비교 연산을 별도로 처리한다.

```cs
object managedReference = enemy;

Debug.Log(enemy == null);
Debug.Log(managedReference == null);
```

정적 타입과 비교 방식에 따라 결과를 해석할 때 주의해야 한다. Native Object가 파괴되어도 Managed Wrapper는 C# 참조가 남아 있는 동안 GC 대상이 아니다.

### Component 제거

Component도 Unity Object이므로 `Destroy()`를 사용한다.

```cs
Collider collider = enemy.GetComponent<Collider>();
Destroy(collider);
```

일반 C# 객체처럼 `collider = null`만 지정하면 GameObject에 연결된 Native Component는 제거되지 않는다.

### Runtime Texture 해제

런타임에 직접 만든 Texture가 더 이상 필요하지 않다면 파괴한다.

```cs
private Texture2D? generatedTexture;

public void CreateTexture()
{
    generatedTexture = new Texture2D(1024, 1024);
}

public void ReleaseTexture()
{
    if (generatedTexture == null)
    {
        return;
    }

    Destroy(generatedTexture);
    generatedTexture = null;
}
```

`Destroy()`는 Native Resource의 수명을 끝내고, 필드의 `null` 대입은 Managed Wrapper를 붙잡은 참조를 제거한다. 두 작업의 대상이 다르다.

### Native Collection 해제

`NativeArray<T>`는 Native Memory를 직접 사용하는 구조다.

```cs
NativeArray<float> samples =
    new(1024, Allocator.Persistent);

try
{
    Process(samples);
}
finally
{
    if (samples.IsCreated)
    {
        samples.Dispose();
    }
}
```

`Allocator.Persistent`로 확보한 메모리는 GC를 기다리는 대상이 아니다. 소유자가 `Dispose()`를 호출해야 한다.

---

## 내부 동작

### GC가 확인하는 범위

GC는 Managed Heap의 객체 그래프를 기준으로 도달 가능한 객체를 찾는다.

```text
Static Field
Thread Stack
Local Variable
GC Handle
↓
Managed 객체 그래프 탐색
```

Native Resource의 실제 크기와 참조 관계 전체를 Managed GC가 대신 관리하지 않는다.

Managed Wrapper가 GC 대상이 되더라도 Native Resource가 어떤 규칙으로 반환되는지는 Unity Object의 종류와 소유 관계에 따라 다르다. 필요한 Unity Object를 명시적으로 파괴하거나 해당 로드 시스템의 Release API를 사용하는 이유다.

### Unity의 특별한 null

일반 C# 객체의 `null`은 참조가 없다는 뜻이다.

```cs
PlayerData? data = null;
```

Unity Object는 Managed Wrapper가 존재하더라도 연결된 Native Object가 파괴되었으면 `== null` 비교가 참이 될 수 있다.

```text
Managed Wrapper 존재
Native Object 파괴됨
UnityEngine.Object의 == 연산
결과: null처럼 판단
```

이 상태를 흔히 가짜 null 또는 Missing Reference 상태라고 부른다. 순수 C#의 Reference Null과 완전히 같은 상태는 아니다.

### Asset 참조와 수명

Scene의 Renderer가 Material을 참조하고 Material이 Texture를 참조하면 객체 그래프가 이어진다.

```text
Scene
↓
Renderer
↓
Material
↓
Texture
```

상위 참조가 남아 있거나 Static Cache가 Asset을 붙잡고 있다면 Scene 일부를 정리해도 관련 Asset이 계속 유지될 수 있다.

Addressables나 AssetBundle 같은 로드 시스템은 자체 Reference Count와 해제 규칙을 가질 수 있다. C# 변수 하나를 `null`로 만드는 것만으로 시스템이 가진 참조까지 사라지지는 않는다.

### CPU와 GPU 복사본

Texture Import 설정에서 Read/Write가 활성화되면 CPU가 읽을 수 있는 데이터 복사본이 추가로 필요할 수 있다.

```text
Read/Write 비활성화
주로 Runtime 사용에 필요한 데이터 유지

Read/Write 활성화
CPU 접근용 데이터가 추가로 유지될 수 있음
```

동일한 해상도의 Texture라도 압축 형식, Mipmap, Read/Write와 플랫폼 설정에 따라 메모리 비용이 달라진다.

---

## 실제 Unity에서는?

### Profiler의 영역을 나눠 본다

Unity Profiler의 Memory Module에서는 전체 수치 하나만 보지 않고 영역별 변화를 확인한다.

```text
Managed Heap이 계속 증가
└─ C# 참조, Collection, Event 구독과 Cache 확인

Texture Memory가 큼
└─ 해상도, 압축, Mipmap, Read/Write와 로드 수명 확인

Native Memory가 계속 증가
└─ Unity Object 생성과 파괴, Native Collection 확인
```

Profiler가 분류하지 못한 영역이나 플랫폼 자체 비용도 있을 수 있으므로 합계가 항상 단순히 일치한다고 가정하지 않는다.

### Memory Profiler Snapshot을 비교한다

메모리가 증가하는 상황 전후의 Snapshot을 비교하면 어떤 객체 수와 크기가 늘었는지 확인할 수 있다.

```text
기준 Scene 진입 후 Snapshot A
↓
문제가 생기는 행동 반복
↓
정리와 Scene 복귀
↓
Snapshot B
↓
객체 수와 Retained Reference 비교
```

한 번의 Snapshot에서 큰 객체를 찾는 것보다 같은 행동을 반복한 뒤 원래 상태로 돌아오지 않는 대상을 찾는 방식이 누수 진단에 유리하다.

### Instantiate와 Destroy를 함께 센다

GameObject를 반복 생성한 뒤 `Destroy()`하지 않으면 Native Object가 누적된다. 파괴했더라도 List, Event와 Static Field가 Component Wrapper를 계속 참조할 수 있다.

```cs
private readonly List<Enemy> enemies = new();

public void RemoveEnemy(Enemy enemy)
{
    enemies.Remove(enemy);
    Destroy(enemy.gameObject);
}
```

Native Object의 파괴와 Managed 참조 제거를 함께 확인해야 한다.

### 로드 API에 맞는 해제를 사용한다

직접 생성한 객체, Resources, AssetBundle과 Addressables는 획득 방식과 소유 규칙이 다르다.

```text
new Texture2D / Instantiate
└─ 생성한 쪽이 Destroy 책임 관리

Addressables Load
└─ Handle 또는 Instance에 맞는 Release 사용

NativeArray Persistent
└─ 소유자가 Dispose 호출
```

모든 것을 `Destroy()`나 `Resources.UnloadUnusedAssets()` 하나로 해결하려 하지 않고 획득 경로에 대응하는 해제 방식을 사용한다.

### Peak Memory를 확인한다

이전 Scene의 리소스를 유지한 채 다음 Scene을 로드하면 두 Scene의 Native Resource가 동시에 존재하는 구간이 생길 수 있다.

```text
이전 Scene 리소스
+ 다음 Scene 로드 데이터
+ 로드 중 임시 Buffer
= 전환 순간 Peak Memory
```

최종 상태의 메모리는 정상이어도 Peak에서 플랫폼 제한을 넘을 수 있다. Snapshot뿐 아니라 전환 과정의 Timeline도 확인해야 한다.

---

## 실무에서 자주 하는 오해

### C# 참조에 null을 넣으면 Unity Object도 해제된다

`null` 대입은 해당 Managed 참조를 제거한다. Unity의 Native Object를 파괴하거나 로드 시스템의 Reference Count를 내리는 작업과 같지 않다.

### Destroy를 호출하면 모든 메모리가 즉시 사라진다

`Destroy()`는 Unity Object의 파괴를 예약한다. 처리 시점, 남아 있는 Managed Wrapper와 공유 Asset 참조 때문에 메모리 수치가 즉시 모두 내려가지 않을 수 있다.

### GC.Collect를 호출하면 Native Memory도 정리된다

GC는 Managed 객체를 대상으로 한다. Native Collection의 `Dispose()`, Unity Object의 `Destroy()`와 Asset System의 Release를 대신하지 않는다.

### Unity Object가 null이면 C# 참조도 없다

파괴된 Native Object를 가리키는 Managed Wrapper가 남아 있어도 Unity의 비교 연산에서는 `null`처럼 보일 수 있다. 일반 C#의 Reference Null과 구분해야 한다.

### Texture 파일 크기가 Runtime Memory 크기다

디스크 압축 크기와 Runtime에서 사용하는 CPU 또는 GPU Memory는 다르다. 플랫폼 Texture Format, 해상도, Mipmap과 Read/Write 설정을 함께 봐야 한다.

### Scene을 바꾸면 이전 리소스가 모두 해제된다

DontDestroyOnLoad 객체, Static Field, Singleton, Event와 별도 로드 시스템의 참조가 남아 있으면 이전 리소스도 유지될 수 있다.

### NativeArray는 struct라서 Stack에만 존재한다

`NativeArray<T>` 값 자체는 struct지만 가리키는 데이터는 Allocator로 확보한 Native Memory에 존재한다. `Persistent`와 `TempJob` 등 수명 규칙에 맞게 해제해야 한다.

---

## 마무리

Unity의 메모리는 Managed Heap 하나로만 구성되지 않는다.

C# 객체는 GC가 관리하지만 Unity Object는 Managed Wrapper와 Native Object가 연결되어 있고, Texture나 Buffer는 Graphics Memory까지 사용할 수 있다.

```text
무엇이 증가했는가?
↓
Managed / Native / Graphics 영역 구분
↓
누가 생성했는가?
↓
누가 참조하고 있는가?
↓
어떤 API로 해제해야 하는가?
↓
해제 전후를 다시 측정
```

메모리 수명은 생성 API에서 시작된다. 직접 만든 Unity Object라면 `Destroy()`, Native Collection이라면 `Dispose()`, Addressables라면 대응하는 Release처럼 획득 방식과 해제 방식을 한 쌍으로 관리해야 한다.

GC가 모든 메모리를 자동으로 해결할 것이라는 전제를 버리면 Unity의 메모리 증가와 해제 지연을 더 정확히 추적할 수 있다.

---

## 핵심 정리

- Managed Memory는 .NET Runtime과 GC가 관리하는 C# 객체 영역이다.
- Native Memory는 Unity Engine, 플랫폼 코드와 Native Collection 등이 사용하는 영역이다.
- `UnityEngine.Object`는 Managed Wrapper와 Native Object가 연결된 구조를 가진다.
- Unity Object의 `null` 비교는 Native Object의 파괴 상태까지 반영하므로 일반 C# Null과 다를 수 있다.
- `Destroy()`는 Native Object의 파괴를 요청하고 `null` 대입은 Managed 참조 하나를 제거한다.
- `NativeArray<T>` 같은 Native Collection은 소유자가 수명 규칙에 맞춰 `Dispose()`해야 한다.
- Texture는 Managed, Native와 Graphics Memory에 걸쳐 비용을 만들 수 있다.
- Asset은 다른 객체나 로드 시스템의 참조가 남아 있으면 Scene 전환 후에도 유지될 수 있다.
- 획득한 API에 대응하는 `Destroy`, `Dispose` 또는 `Release`를 사용해야 한다.
- Memory Profiler에서는 영역별 수치와 전후 Snapshot을 함께 비교해야 한다.
