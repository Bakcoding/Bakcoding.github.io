---
title: "[궁금시리즈] 10-9. Unity Profiler와 Memory Profiler로 메모리를 어떻게 분석할까?"
excerpt: "C#"
categories:
  - CSharp
series: question-series
tags:
  - CSharp
permalink: /programming/10-9-unity-memory-profiler/
toc: true
toc_sticky: true
date: 2026-08-16 12:00:29 +0900
last_modified_at: 2026-08-16 12:00:29 +0900
---

## 들어가며

메모리 사용량이 2GB라는 사실만으로는 무엇을 수정해야 할지 알 수 없다.

```text
Managed Heap이 큰가?
Texture가 큰가?
Native Object가 누적되는가?
Graphics Driver 영역이 큰가?
사용 중인 메모리인가?
Allocator가 예약한 여유 공간인가?
```

Unity에는 메모리를 확인하는 도구가 여러 개 있다.

```text
CPU Usage Module
└─ 어느 Frame의 어떤 호출에서 GC Alloc이 발생했는지 확인

Memory Module
└─ 시간에 따른 메모리 영역과 객체 수 변화 확인

Memory Profiler Package
└─ 특정 시점의 객체, 크기와 참조 관계 분석
```

각 도구가 답하는 질문이 다르다.

메모리 분석은 가장 큰 숫자를 보고 코드를 추측하는 작업이 아니다. 같은 행동을 재현하고, 증가한 영역을 찾고, 전후 Snapshot에서 남은 객체와 참조 경로를 확인하는 과정이다.

---

## 개념 설명

### CPU Usage Module

CPU Usage Module의 Hierarchy View에는 선택한 Frame과 Thread의 `GC.Alloc` 열이 있다.

```text
PlayerLoop
└─ Update.ScriptRunBehaviourUpdate
   └─ EnemyScanner.Update
      └─ GC.Alloc 4.2KB
```

Managed Allocation이 발생한 호출 경로와 반복 횟수를 찾는 데 사용한다.

Timeline에서는 `GC.Alloc` Sample과 Garbage Collection으로 Main Thread가 중단된 구간을 시간 흐름으로 확인할 수 있다.

### Memory Module

Memory Module은 Frame마다 주요 메모리 지표의 변화를 보여 준다.

```text
Total Used Memory
Texture Memory
Mesh Memory
Material Count
Object Count
GC Used Memory
GC Allocated In Frame
```

특정 Scene 진입 후 Texture Memory가 증가했는지, 전투를 반복할 때 Object Count가 계속 늘어나는지처럼 추세를 확인하는 데 적합하다.

### Used와 Reserved

Unity의 여러 Allocator는 운영체제에 매번 메모리를 요청하지 않도록 여유 공간을 예약한다.

```text
Used
└─ 현재 실제 데이터에 사용 중인 공간

Reserved
└─ Allocator가 확보해 둔 전체 공간
```

객체를 해제해 Used가 줄어도 Reserved가 즉시 같은 크기로 내려가지 않을 수 있다. Reserved 증가만 보고 객체 누수라고 단정하면 안 된다.

### Memory Profiler Package

Memory Profiler Package는 특정 시점의 Player Memory를 Snapshot으로 저장하고 자세히 분석한다.

```text
Memory Usage Overview
Unity Objects
All Of Memory
Memory Map
Object Details와 References
```

Package 버전에 따라 View 이름과 제공 정보는 달라질 수 있지만 핵심은 특정 시점에 어떤 객체가 존재하고 어떤 참조 때문에 유지되는지를 찾는 것이다.

### Snapshot

Snapshot은 촬영 순간의 메모리 상태다.

```text
Snapshot A
기준 상태

Snapshot B
문제 행동 이후 상태
```

두 상태를 같은 조건에서 비교하면 단순히 큰 객체가 아니라 행동 뒤에 새로 남은 객체를 찾을 수 있다.

---

## 코드 예제

Enemy를 Spawn하고 제거하는 기능에서 메모리가 계속 증가한다고 가정한다.

```cs
public sealed class EnemyRegistry : MonoBehaviour
{
    private readonly List<Enemy> enemies = new();

    public Enemy Spawn(Enemy prefab)
    {
        Enemy enemy = Instantiate(prefab);
        enemies.Add(enemy);
        return enemy;
    }

    public void Despawn(Enemy enemy)
    {
        Destroy(enemy.gameObject);
    }
}
```

GameObject는 파괴하지만 List에서 참조를 제거하지 않는다.

### 재현 시나리오를 만든다

```text
1. Test Scene 진입
2. 초기 Loading 완료까지 대기
3. Enemy 100개 Spawn
4. Enemy 100개 Despawn
5. 원래 화면으로 복귀
6. 같은 행동을 3회 반복
```

무작위 Gameplay 전체를 기록하는 것보다 동일한 입력으로 반복할 수 있는 짧은 시나리오가 비교에 유리하다.

### Marker를 추가한다

Profiler에서 자신의 시스템 경계를 쉽게 찾도록 Marker를 사용할 수 있다.

```cs
using Unity.Profiling;

public sealed class EnemyRegistry : MonoBehaviour
{
    private static readonly ProfilerMarker SpawnMarker =
        new("EnemyRegistry.Spawn");

    public Enemy Spawn(Enemy prefab)
    {
        using (SpawnMarker.Auto())
        {
            Enemy enemy = Instantiate(prefab);
            enemies.Add(enemy);
            return enemy;
        }
    }
}
```

Marker 이름은 기능 경계를 표현하고 매 호출마다 동적 문자열을 만들지 않는다.

### CPU Usage에서 반복 할당 찾기

```text
Window
↓
Analysis
↓
Profiler
↓
CPU Usage / Hierarchy
↓
GC.Alloc 열 정렬
```

GC.Alloc이 큰 한 번의 호출과 작은 할당이 수천 번 호출된 경우를 모두 확인한다.

Call Stacks 기록을 활성화하면 `GC.Alloc` Sample이 어떤 호출 경로에서 발생했는지 찾을 수 있다. Deep Profile보다 실행 패턴에 주는 영향이 작을 수 있지만 기록 자체에도 Overhead가 있으므로 필요한 구간에 사용한다.

### Snapshot A 촬영

초기 Loading과 일회성 초기화가 끝난 안정된 상태에서 기준 Snapshot을 촬영한다.

```text
Scene 진입 직후 X
Shader Compile과 Asset Load 진행 중 X

Loading 완료
Object Count 안정화
동일 Camera 위치
Snapshot A 촬영
```

### Snapshot B 촬영

문제 행동을 반복한 뒤 원래 상태로 돌아와 Snapshot B를 촬영한다.

```text
Snapshot A
↓
Spawn / Despawn 3회
↓
Coroutine과 Destroy 처리 대기
↓
원래 상태 복귀
↓
Snapshot B
```

`Destroy()`와 비동기 Release가 처리될 시간을 주지 않고 촬영하면 정상적으로 정리될 임시 객체까지 누수처럼 보일 수 있다.

### 증가한 객체를 좁힌다

```text
Snapshot Compare
↓
Unity Objects 수와 크기 증가 확인
↓
Enemy 또는 관련 Component 필터
↓
Object Details
↓
References / Referenced By 확인
```

Enemy Wrapper를 붙잡는 `EnemyRegistry.enemies` List를 발견했다면 Despawn에서 참조도 제거한다.

```cs
public void Despawn(Enemy enemy)
{
    if (!enemies.Remove(enemy))
    {
        Debug.LogWarning(
            $"Enemy is not registered: {enemy.name}");
    }

    Destroy(enemy.gameObject);
}
```

수정 후 같은 Build와 시나리오로 다시 Snapshot을 비교한다.

---

## 내부 동작

### Snapshot이 Capture하는 상태

Snapshot은 특정 순간의 Managed Object, Native Object와 Unity가 추적하는 메모리 정보를 수집한다.

```text
Managed Heap
Native Allocation
UnityEngine.Object
Type과 Field 정보
Object 간 Reference
Memory Region
```

플랫폼과 Capture 옵션에 따라 수집 가능한 영역과 정확도가 달라질 수 있다. 운영체제가 보고하는 전체 Process Memory와 Snapshot의 추적 합계가 항상 완전히 같지는 않다.

### Self Size와 Retained 영향

객체 자체가 차지하는 크기와 그 객체의 참조가 유지시키는 전체 메모리는 다르다.

```text
CacheManager 자체
└─ 작은 객체

CacheManager가 참조하는 Dictionary
└─ Texture 수백 개
```

Manager의 자체 크기만 보면 작지만 해당 참조를 제거했을 때 함께 해제될 수 있는 객체 그래프는 클 수 있다.

Memory Profiler의 View와 Package 버전에 따라 이 관계를 표시하는 용어와 계산 방식은 다를 수 있다. 단일 Size 열만 보지 않고 Reference Chain과 소유 구조를 함께 확인한다.

### Managed Reference Chain

GC는 Root에서 도달 가능한 객체를 회수하지 않는다.

```text
Static GameManager
↓
EventBus
↓
Delegate
↓
Scene Controller
↓
Texture Reference
```

가장 아래 Texture만 보면 왜 Scene 전환 뒤에도 남아 있는지 알기 어렵다. Root 방향의 Reference를 따라가면 Static Event 구독이 실제 원인임을 찾을 수 있다.

### Native와 Managed 연결

`UnityEngine.Object`에는 Managed Wrapper와 Native Object가 연결되어 있다.

```text
Managed Enemy Component
↕
Native Component
↓
GameObject와 Transform
```

Native Object가 파괴되어도 Managed Wrapper를 참조하는 List나 Delegate가 남아 있을 수 있다. 반대로 Asset System의 Native Reference 때문에 Managed Field 하나를 비워도 Resource가 즉시 해제되지 않을 수 있다.

### Snapshot 자체의 영향

Snapshot Capture에는 시간과 추가 메모리가 필요하다. 모바일 기기에서는 Capture 중 앱이 멈추거나 메모리 제한에 가까워질 수 있다.

문제 상태에 도달하기 전에 Snapshot 저장 공간과 연결 상태를 준비하고, Capture로 인해 발생한 일시적 Peak를 원래 문제와 구분한다.

### GC Alloc 합계와 Heap 증가량

Frame별 `GC.Alloc` 합계를 더한 값은 Managed Heap의 최종 증가량과 같지 않다.

```text
Frame마다 Allocation
↓
일부 객체는 계속 살아 있음
일부 객체는 GC가 회수함
Heap의 빈 공간은 재사용됨
Heap Reserved는 유지될 수 있음
```

GC.Alloc은 발생량이고 GC Used Memory는 특정 시점의 사용 상태다.

---

## 실제 Unity에서는?

### Editor 대신 Target Player에 연결한다

Editor에는 Inspector, Scene View, Console, Asset Database와 Profiler 자체 객체가 포함된다.

```text
Development Build 생성
Autoconnect Profiler 또는 Attach to Player
Target Device에서 시나리오 실행
Player의 Memory Data Capture
```

Editor 측 결과는 재현 경로를 찾는 데 사용할 수 있지만 최종 Memory Budget은 실제 기기의 Player로 판단한다.

### 같은 조건의 Snapshot만 비교한다

다음 조건을 맞춘다.

```text
같은 Build
같은 Device
같은 Scene
같은 Camera 위치
같은 Asset Load 상태
같은 기능 반복 횟수
```

Snapshot A는 Main Menu이고 B는 전투 Scene이라면 차이의 대부분은 정상 Asset Load일 수 있다.

### Warm-up을 구분한다

첫 실행에는 Shader, Font Glyph, Pool, Generic Code와 Cache 초기화가 추가될 수 있다.

```text
첫 실행 증가
두 번째 실행 유지
세 번째 실행 유지
└─ 의도된 Cache 가능성

반복할 때마다 같은 양 증가
└─ 누수 또는 미해제 가능성
```

한 번 증가한 뒤 안정화되는 메모리와 반복마다 계속 증가하는 메모리를 구분한다.

### 큰 범주에서 작은 객체로 내려간다

```text
System Memory 증가 확인
↓
Managed / Native / Graphics / Audio 구분
↓
Type 또는 Asset별 크기와 개수 정렬
↓
전후 증가 대상 필터
↓
Reference Chain 확인
↓
소유자와 Release 경로 수정
```

처음부터 작은 Managed Object 하나의 Reference를 추적하면 전체 문제와 관계없는 대상에 시간을 쓸 수 있다.

### Untracked Memory를 인식한다

Unity가 추적하지 못하거나 완전히 분류하지 못하는 메모리도 있다.

```text
Native Plugin
일부 Graphics Driver Allocation
Executable Code와 DLL
Mono 또는 IL2CPP Metadata
플랫폼 Runtime
```

Unity의 추적 합계와 운영체제의 Process Memory 차이가 크다면 Platform 도구와 Native Plugin 측정이 필요할 수 있다.

### Snapshot 파일을 관리한다

Snapshot은 크기가 크고 Build와 Device 정보에 의존한다. 비교 목적과 재현 조건을 이름이나 설명에 남긴다.

```text
Android_Battle_Before_20260816.snap
Android_Battle_After3Cycles_20260816.snap
```

서로 다른 Package 버전이나 Project 상태에서 촬영한 Snapshot 비교는 해석에 주의한다.

---

## 실무에서 자주 하는 오해

### 가장 큰 객체가 메모리 누수의 원인이다

큰 Texture 하나가 의도적으로 Loading된 상태일 수 있다. 중요한 것은 기준 상태와 비교해 불필요하게 새로 남았는지, 누가 참조하는지다.

### Reserved Memory가 줄지 않으면 누수다

Allocator가 이후 요청에 재사용하려고 공간을 유지할 수 있다. Used Memory, 객체 수와 반복 패턴을 함께 봐야 한다.

### GC Alloc 합계가 Managed Heap 증가량이다

할당된 객체 일부는 회수되고 빈 Heap 공간은 재사용된다. Frame Allocation과 현재 Heap 사용량은 서로 다른 지표다.

### Snapshot 한 장이면 누수를 찾을 수 있다

큰 객체는 찾을 수 있지만 정상 상태와 문제 상태의 차이를 구분하기 어렵다. 같은 조건의 전후 Snapshot과 반복 시나리오가 필요하다.

### Snapshot B가 크면 모두 비정상이다

비동기 Load, `Destroy()`와 Release가 아직 끝나지 않았을 수 있다. 시스템이 안정화될 시간을 준 뒤 동일한 수명 단계에서 비교해야 한다.

### Editor에서 측정하면 Player도 같다

Editor 전용 객체와 도구 비용이 섞이고 Runtime과 API 할당 동작도 다를 수 있다. 대상 플랫폼 Development Player에서 확인해야 한다.

### Deep Profile을 항상 켜야 정확하다

Deep Profile 자체가 실행 시간과 할당 패턴을 바꿀 수 있다. 기본 Profiling과 Allocation Call Stack으로 범위를 좁히고 필요한 경우에만 사용한다.

### Reference가 하나 보이면 그것만 지우면 된다

여러 Root와 로드 시스템이 같은 Asset을 참조할 수 있다. 전체 Reference Chain과 소유권을 확인한 뒤 올바른 Release 경로를 수정해야 한다.

---

## 마무리

Unity 메모리 분석은 세 가지 질문으로 나눌 수 있다.

```text
언제 증가했는가?
└─ Profiler Timeline과 Memory Module

어디서 할당했는가?
└─ CPU Usage의 GC.Alloc과 Call Stack

무엇이 남았고 누가 붙잡는가?
└─ Memory Profiler Snapshot과 Reference
```

도구를 열기 전에 재현 시나리오와 기준 상태를 먼저 정해야 한다. 조건이 다른 Snapshot의 숫자 차이는 원인을 설명하지 못한다.

```text
재현 가능한 행동 정의
↓
큰 메모리 영역 확인
↓
동일 조건 Snapshot A / B 촬영
↓
증가한 Type과 Asset 필터
↓
Root 방향 Reference 추적
↓
소유권과 Release 수정
↓
같은 Build에서 재검증
```

메모리 최적화의 결과는 Snapshot 숫자가 작아진 것으로 끝나지 않는다. Target Device의 Peak Memory 제한을 만족하고, Release 시점이 예측 가능하며, Frame Time에 새로운 Spike를 만들지 않는지도 함께 확인해야 한다.

---

## 핵심 정리

- CPU Usage Module의 `GC.Alloc`은 선택한 Frame과 Thread에서 Managed Allocation이 발생한 호출을 찾는 데 사용한다.
- Memory Module은 메모리 영역, 객체 수와 Frame별 변화 추세를 확인하는 도구다.
- Used Memory는 현재 사용 중인 공간이고 Reserved Memory는 Allocator가 확보한 전체 공간이다.
- Unity 6에서는 내장 Memory Module의 Detailed View보다 Memory Profiler Package 사용이 권장된다.
- Snapshot은 특정 시점의 객체와 메모리 상태이므로 동일 조건의 전후 Snapshot을 비교해야 한다.
- 객체 자체 크기뿐 아니라 해당 객체가 참조해 유지시키는 객체 그래프도 확인해야 한다.
- Reference Chain을 Root 방향으로 추적하면 Static Field, Event, Cache와 로드 시스템의 실제 소유자를 찾을 수 있다.
- `GC.Alloc` 합계와 최종 Managed Heap 증가량은 객체 회수와 공간 재사용 때문에 같지 않다.
- Editor 전용 메모리를 피하려면 대상 플랫폼 Development Player에 연결해 측정한다.
- 수정 후에는 같은 Build, Device와 재현 시나리오로 Memory와 Frame Time을 다시 검증해야 한다.
