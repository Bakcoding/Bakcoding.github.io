---
title: "[궁금시리즈] 10-4. Unity의 GC와 Incremental GC는 어떻게 동작할까?"
excerpt: "C#"
categories:
  - CSharp
series: question-series
tags:
  - CSharp
permalink: /programming/10-4-unity-incremental-gc/
toc: true
toc_sticky: true
date: 2026-08-16 12:00:24 +0900
last_modified_at: 2026-08-16 12:00:24 +0900
---

## 들어가며

게임이 정상적으로 실행되다가 일정한 간격으로 Frame이 크게 느려지는 경우가 있다.

```text
16ms
17ms
16ms
84ms  ← GC Spike
16ms
```

짧게 사용한 Managed 객체가 누적되고 Garbage Collector가 한꺼번에 작업하면 이런 Spike가 생길 수 있다.

Unity의 Incremental GC는 전체 작업을 여러 Frame에 나누어 한 번의 긴 중단을 줄인다.

```text
일반 GC
한 Frame에서 긴 Collection

Incremental GC
여러 Frame에서 짧은 Collection Slice
```

Incremental GC를 활성화했다고 할당 비용이나 GC의 전체 작업량이 사라지는 것은 아니다. 작업이 언제, 얼마씩 실행되는지가 달라진다.

GC Spike를 줄이려면 Collector 설정만 바꾸는 것이 아니라 Frame마다 만드는 Garbage의 양, 살아 있는 객체의 수와 참조 변경 패턴을 함께 확인해야 한다.

---

## 개념 설명

### Unity의 Garbage Collector

Unity는 Managed Heap에서 더 이상 참조되지 않는 객체를 회수하기 위해 Boehm-Demers-Weiser Garbage Collector를 사용한다.

```cs
public void CreateMessage()
{
    string message = $"Wave: {currentWave}";
    Debug.Log(message);
}
```

메서드가 끝난 뒤 `message`를 참조하는 곳이 없다면 문자열은 Garbage가 된다. 메모리는 즉시 반환되지 않고 GC가 실행될 때 회수할 수 있다.

### Mark와 Sweep

GC는 Root에서 접근할 수 있는 객체를 추적한다.

```text
Root
├─ Static Field
├─ Thread Stack
├─ Local Variable
└─ GC Handle
```

Root에서 도달할 수 있는 객체를 살아 있다고 표시하는 과정이 Mark다.

```text
Root → Player → Inventory → Item
```

어떤 Root에서도 도달할 수 없는 객체의 공간을 회수하는 과정이 Sweep이다.

```text
Root    X    Temporary List
              ↓
           회수 대상
```

Unity의 GC는 Non-Compacting 방식이므로 살아 있는 객체를 한쪽으로 다시 배치해 빈 공간을 모두 합치는 작업은 수행하지 않는다.

### Stop-the-world Collection

Incremental Mode가 꺼져 있으면 GC가 Collection을 수행하는 동안 Main Thread의 프로그램 실행을 멈춘다.

```text
게임 코드 실행
↓
Main Thread 정지
↓
Managed Heap 검사와 회수
↓
게임 코드 재개
```

Heap과 살아 있는 객체 그래프가 크면 중단 시간이 길어질 수 있다. Profiler의 Frame Time에서 급격한 Spike로 나타난다.

### Incremental GC

Incremental GC는 Mark 작업을 여러 Frame의 작은 Slice로 나눈다.

```text
Frame 1: 게임 코드 + GC Slice
Frame 2: 게임 코드 + GC Slice
Frame 3: 게임 코드 + GC Slice
Frame 4: Collection 완료
```

전체 GC 작업이 반드시 줄어드는 것은 아니지만 긴 중단을 여러 번의 짧은 중단으로 분산해 Frame 안정성을 높일 수 있다.

Unity에서는 Incremental GC가 기본 동작이며 Player Settings의 `Use Incremental GC`로 설정할 수 있다. 일부 플랫폼은 지원 조건이 다를 수 있으므로 대상 플랫폼 문서를 함께 확인해야 한다.

---

## 코드 예제

매 Frame 임시 객체를 만드는 Spawner가 있다.

```cs
void Update()
{
    List<Enemy> visibleEnemies = new();

    foreach (Enemy enemy in enemies)
    {
        if (enemy.IsVisible)
        {
            visibleEnemies.Add(enemy);
        }
    }

    UpdateTargets(visibleEnemies);
}
```

Incremental GC를 활성화해도 `List<Enemy>`와 내부 배열의 반복 할당은 그대로 발생한다.

### Buffer를 재사용한다

```cs
private readonly List<Enemy> visibleEnemies = new(64);

void Update()
{
    visibleEnemies.Clear();

    foreach (Enemy enemy in enemies)
    {
        if (enemy.IsVisible)
        {
            visibleEnemies.Add(enemy);
        }
    }

    UpdateTargets(visibleEnemies);
}
```

GC 모드에 기대기 전에 반복되는 Garbage 자체를 줄인다.

### GC.Collect 직접 호출

다음 코드는 매 Frame 전체 Collection을 요청한다.

```cs
void Update()
{
    GC.Collect();
}
```

Garbage가 적더라도 Heap 검사와 Main Thread 중단을 반복하므로 일반적인 해결 방법이 아니다.

명확한 비대화 구간이 끝났고 다음 구간의 Spike를 피해야 하는 특수한 흐름에서는 Loading Screen 같은 안전한 시점에 검토할 수 있다.

```cs
public IEnumerator LoadBattle()
{
    yield return LoadBattleAssets();

    ReleaseLoadingData();

    GC.Collect();

    yield return null;
    StartBattle();
}
```

직접 호출이 실제로 전체 플레이 품질을 개선하는지는 대상 기기에서 전후를 측정해야 한다.

### Incremental Collection 수동 실행

GC를 Manual Mode로 운용하는 특수한 구조에서는 Unity API로 Incremental 작업 시간을 제공할 수 있다.

```cs
using UnityEngine.Scripting;

public sealed class ManualGcController : MonoBehaviour
{
    private void OnEnable()
    {
        GarbageCollector.GCMode =
            GarbageCollector.Mode.Manual;
    }

    private void LateUpdate()
    {
        const ulong nanoseconds = 1_000_000;
        GarbageCollector.CollectIncremental(nanoseconds);
    }

    private void OnDisable()
    {
        GarbageCollector.GCMode =
            GarbageCollector.Mode.Enabled;
    }
}
```

Manual Mode는 자동 Collection을 끄고 개발자가 책임지는 방식이다. 예제의 고정 시간 Budget이 모든 기기와 Frame에 적합한 것은 아니다.

일반 프로젝트에서는 기본 Incremental GC와 할당 감소부터 적용하고, 수동 제어는 메모리 증가량과 여유 Frame 시간을 계산할 수 있을 때만 사용한다.

### GC 비활성화

```cs
GarbageCollector.GCMode =
    GarbageCollector.Mode.Disabled;
```

Disabled Mode에서는 자동 GC가 실행되지 않고 `GC.Collect()`도 Collection을 시작하지 않는다. Garbage는 계속 쌓일 수 있으므로 장시간 켜 두면 Managed Heap이 계속 확장되어 메모리 부족으로 이어질 수 있다.

---

## 내부 동작

### Incremental Marking

Mark 단계가 여러 Slice로 나뉘는 동안 게임 코드는 계속 객체의 참조를 바꾼다.

```cs
player.Target = newTarget;
inventory.CurrentItem = nextItem;
```

GC가 이전 Slice에서 검사한 객체의 참조가 바뀌면 새 참조 관계를 놓치지 않아야 한다.

### Write Barrier

Incremental GC는 Managed Reference가 변경될 때 Write Barrier라는 추가 코드를 사용해 변경 사실을 기록한다.

```text
객체 참조 변경
↓
Write Barrier가 GC에 알림
↓
필요한 객체를 다시 검사 대상으로 표시
```

정확한 Marking을 유지하는 대신 Reference를 변경할 때 일부 Overhead가 추가된다.

### 참조 변경이 너무 많은 경우

Slice 사이에 객체 그래프가 계속 크게 바뀌면 GC가 이미 확인한 객체를 다시 검사해야 한다.

```text
Mark Slice 수행
↓
대량의 Reference 변경
↓
재검사 작업 증가
↓
Incremental Mark 완료 지연
```

변경량이 너무 많아 Incremental 작업이 끝나지 못하면 Full Non-Incremental Collection으로 전환될 수 있다. Incremental GC가 모든 Spike를 보장해서 없애지는 않는 이유다.

### Heap 크기와 Live Object

GC 비용은 이번 Frame에 생성된 Garbage만으로 결정되지 않는다. 살아 있는 Managed 객체가 많으면 Mark 단계에서 따라가야 할 참조 그래프도 커질 수 있다.

```text
짧게 사는 Garbage
└─ Sweep 대상과 실행 주기에 영향

오래 사는 객체와 참조
└─ Mark해야 할 Live Set 크기에 영향
```

불필요한 Cache와 Event 구독을 정리하는 작업은 메모리 사용량뿐 아니라 GC가 검사할 Live Set을 줄이는 데도 관련된다.

### Non-Compacting의 영향

객체가 회수된 자리는 빈 공간으로 남고 이후 할당에 재사용될 수 있다. 살아 있는 객체를 이동해 연속 공간으로 합치지 않으므로 Heap이 조각날 수 있다.

Managed Heap이 한 번 커진 뒤 OS에 즉시 같은 크기로 반환되지 않을 수도 있다. GC가 실행된 뒤 Profiler의 Reserved Memory가 기대만큼 내려가지 않는다고 해서 모두 누수인 것은 아니다.

---

## 실제 Unity에서는?

### Player Settings 확인

설정 위치는 다음과 같다.

```text
Edit
↓
Project Settings
↓
Player
↓
Other Settings / Configuration
↓
Use Incremental GC
```

대부분의 프로젝트에는 기본으로 활성화된 Incremental GC가 유리하지만 Project의 Reference 변경 패턴과 대상 플랫폼에서 측정해 결정한다.

### Profiler에서 Collection과 할당을 함께 본다

GC Sample 하나만 보지 않고 앞선 Frame의 할당 흐름까지 확인한다.

```text
GC Alloc / Frame
Managed Heap 사용량 변화
GC Collection Sample 시간
Main Thread Frame Time
Collection 발생 주기
```

Spike가 발생한 순간만 수정하면 원인을 놓칠 수 있다. Garbage는 이전 여러 Frame에서 누적되었을 수 있다.

### Incremental Slice가 보이는 방식

Incremental Mode에서는 GC 작업이 여러 Frame의 Sample로 나뉘어 나타날 수 있다.

```text
긴 Spike 1회 감소
대신 작은 GC 작업 여러 Frame 발생
```

평균 Frame Time뿐 아니라 최악 Frame Time과 Frame Time 분포를 비교해야 체감 개선 여부를 판단할 수 있다.

### Frame 여유 시간 활용

VSync나 목표 Frame Rate로 Frame 끝에 여유 시간이 생기면 Unity는 그 시간을 Incremental GC 작업에 활용할 수 있다.

```text
Frame Budget 16.67ms
게임 작업 11ms
남은 여유 시간 일부
└─ Incremental GC Slice 수행 가능
```

게임 작업 자체가 Budget을 계속 넘는 상황이라면 GC Slice를 분산할 여유도 부족하다. 먼저 CPU 병목과 반복 할당을 줄여야 한다.

### 실제 Player에서 비교한다

Editor에는 Editor 전용 객체와 참조가 추가되어 Managed Heap과 Collection 패턴이 Player와 다를 수 있다.

```text
Incremental On 빌드
Incremental Off 빌드
동일 기기
동일 플레이 구간
동일 Profiler 조건
```

평균 FPS 하나가 아니라 GC 시간, 최대 Frame Time, 할당량과 메모리 Peak를 함께 비교한다.

### 플랫폼 제한을 확인한다

Incremental GC 지원 여부와 세부 동작은 플랫폼 및 Unity 버전에 따라 다를 수 있다. 예를 들어 Unity 6 공식 문서에서는 Web 플랫폼이 Incremental GC를 지원하지 않는다고 안내한다.

프로젝트 설정에 항목이 보인다는 사실만으로 모든 Build Target에 동일하게 적용된다고 가정하지 않는다.

---

## 실무에서 자주 하는 오해

### Incremental GC는 GC를 더 빠르게 만든다

주된 목적은 전체 작업을 줄이는 것이 아니라 여러 Frame으로 나누는 것이다. 총 CPU 비용이 줄지 않거나 Write Barrier 비용이 추가될 수 있다.

### Incremental GC를 켜면 GC Spike가 절대 생기지 않는다

Reference 변경이 너무 많거나 작업을 분산할 시간이 부족하면 Incremental Mark가 지연되고 Full Collection으로 전환될 수 있다.

### GC.Collect를 자주 호출하면 메모리가 깨끗해진다

전체 Blocking Collection을 반복 요청하면 Main Thread 중단을 직접 만들 수 있다. Garbage 생성 원인과 Live Reference를 해결하지도 않는다.

### GC를 끄면 성능이 항상 좋아진다

Collection Spike는 막을 수 있지만 Garbage를 회수하지 않아 Managed Heap이 계속 커질 수 있다. 할당량과 구간 수명을 완전히 통제할 수 있는 특수한 경우에만 고려한다.

### Garbage가 적으면 GC 비용도 항상 작다

GC는 살아 있는 객체 그래프도 Mark해야 한다. 오래 유지되는 객체와 참조가 많으면 이번 Collection에서 회수할 Garbage가 적어도 검사 비용이 생긴다.

### Collection 후 Reserved Memory가 줄지 않으면 누수다

GC가 객체를 회수해 Heap 내부의 사용 가능한 공간을 늘려도 Runtime이 예약한 메모리를 OS에 즉시 모두 반환하지 않을 수 있다. Used와 Reserved를 구분해야 한다.

### Editor의 GC 결과가 Player와 같다

Editor 자체 객체와 도구가 추가로 동작하고 대상 플랫폼의 Runtime 조건도 다르다. 최종 판단은 Player Profiling 결과로 해야 한다.

---

## 마무리

Unity의 GC는 Root에서 도달 가능한 Managed 객체를 표시하고 더 이상 참조되지 않는 객체의 공간을 회수한다.

일반 Collection은 이 작업 동안 Main Thread를 길게 멈출 수 있고, Incremental GC는 Mark 작업을 여러 Frame의 작은 Slice로 분산한다.

```text
GC Spike 발견
↓
이전 Frame의 GC Alloc 확인
↓
Live Managed Object와 참조 확인
↓
반복 할당과 불필요한 참조 감소
↓
Incremental On / Off 비교
↓
실제 플랫폼에서 최악 Frame Time 재측정
```

Incremental GC는 유용한 Frame 안정화 수단이지만 할당을 없애는 기능은 아니다. Write Barrier와 Reference 재검사라는 비용도 가진다.

가장 먼저 할 일은 플레이 중 발생하는 Garbage를 줄이고 객체 수명을 명확하게 만드는 것이다. 그다음 프로젝트의 Frame Budget과 플랫폼에 맞게 Incremental Mode를 측정해 선택해야 한다.

---

## 핵심 정리

- Unity의 GC는 Managed Heap에서 Root로부터 도달할 수 없는 객체의 공간을 회수한다.
- Mark는 살아 있는 객체를 추적하고 Sweep은 사용하지 않는 공간을 회수한다.
- Incremental GC가 꺼진 Collection은 Main Thread를 멈추고 Heap을 처리해 긴 Spike를 만들 수 있다.
- Incremental GC는 Mark 작업을 여러 Frame에 나누어 한 번의 긴 중단을 줄인다.
- Incremental Mode는 GC의 전체 작업을 없애거나 반드시 더 빠르게 만들지는 않는다.
- Write Barrier는 Reference 변경을 GC에 알리며 Managed 코드에 일부 비용을 추가한다.
- Reference 변경이 지나치게 많으면 Incremental 작업이 지연되어 Full Collection으로 전환될 수 있다.
- `GC.Collect()`는 Full Blocking Collection이므로 반복 호출하는 일반적인 해결책이 아니다.
- GC를 비활성화하면 Garbage가 회수되지 않아 Managed Heap이 계속 증가할 수 있다.
- Editor가 아닌 실제 플랫폼에서 할당량, GC 시간과 최악 Frame Time을 함께 측정해야 한다.
