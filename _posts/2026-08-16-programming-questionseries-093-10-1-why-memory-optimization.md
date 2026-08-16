---
title: "[궁금시리즈] 10-1. 메모리 최적화는 왜 필요할까?"
excerpt: "C#"
categories:
  - CSharp
series: question-series
tags:
  - CSharp
permalink: /programming/10-1-why-memory-optimization/
toc: true
toc_sticky: true
date: 2026-08-16 12:00:21 +0900
last_modified_at: 2026-08-16 12:00:21 +0900
---

## 들어가며

게임이 사용하는 메모리가 많다고 해서 항상 느린 것은 아니다.

반대로 메모리 사용량이 제한 안에 있어도 플레이 중 계속 객체를 생성하면 GC가 실행되는 순간 Frame이 끊길 수 있다.

```cs
void Update()
{
    string text = "HP: " + player.Hp;
    hpText.text = text;
}
```

화면에 문자열 하나를 표시하는 코드는 작아 보이지만 매 Frame 새로운 문자열을 만들 수 있다.

메모리 최적화에는 서로 다른 목표가 섞여 있다.

```text
전체 메모리 사용량 줄이기
실행 중 할당 횟수 줄이기
GC가 끊는 시간 줄이기
필요한 데이터를 제때 해제하기
```

무조건 할당을 없애거나 가장 작은 자료형을 선택하는 것이 목적은 아니다. 프로젝트가 실제로 가진 메모리 문제를 측정하고, 사용자 경험에 영향을 주는 지점을 줄이는 것이 목적이다.

---

## 개념 설명

### 메모리 사용량과 할당은 다르다

메모리 사용량은 특정 시점에 프로그램이 차지하고 있는 공간을 의미한다.

```text
Texture 500MB
Audio Clip 200MB
Managed Object 100MB
기타 Native Memory 300MB
```

메모리 할당은 새로운 데이터가 사용할 공간을 확보하는 동작이다.

```cs
Enemy enemy = new Enemy();
int[] damages = new int[100];
string message = $"Damage: {damage}";
```

1GB를 사용하더라도 시작할 때 한 번 확보한 뒤 안정적으로 유지할 수 있다. 반대로 전체 사용량은 작아도 매 Frame 짧게 살 객체를 많이 만들면 GC 작업이 반복될 수 있다.

### Managed Memory와 Native Memory

C# 객체는 주로 Managed Heap에서 관리된다.

```cs
PlayerData data = new PlayerData();
List<int> scores = new();
```

Unity의 Texture, Mesh와 AudioClip 같은 객체는 Managed Wrapper와 Engine의 Native Resource가 함께 존재할 수 있다.

```text
C#의 Texture2D 참조
↓
Managed Wrapper
↓
Unity Native Resource와 Graphics Memory
```

C# 참조 하나의 크기만 보고 실제 리소스 비용을 판단할 수 없는 이유다.

### GC Alloc과 GC Spike

Unity Profiler의 `GC Alloc`은 해당 Frame에서 발생한 Managed Allocation을 찾는 단서다.

할당된 객체가 더 이상 사용되지 않으면 GC가 나중에 회수한다.

```text
Frame마다 임시 객체 생성
↓
Managed Heap 사용량 증가
↓
GC 실행 조건 도달
↓
참조 추적과 메모리 회수
↓
Frame Time 증가 가능
```

한 번의 작은 할당보다 반복 주기와 누적량이 중요하다.

### 메모리 누수와 과도한 할당

두 문제는 증상이 비슷해 보여도 원인이 다르다.

```text
메모리 누수
더 이상 필요하지 않은 데이터를 계속 참조함

과도한 할당
짧게 사용할 데이터를 너무 자주 새로 만듦
```

누수는 시간이 지나도 기준 메모리가 내려오지 않는다. 과도한 할당은 객체가 회수되더라도 GC 빈도와 실행 비용을 높인다.

---

## 코드 예제

Enemy를 찾기 위해 매 Frame 새 List를 만드는 코드가 있다.

```cs
public List<Enemy> FindAliveEnemies()
{
    List<Enemy> result = new();

    foreach (Enemy enemy in enemies)
    {
        if (enemy.IsAlive)
        {
            result.Add(enemy);
        }
    }

    return result;
}
```

```cs
void Update()
{
    List<Enemy> targets = FindAliveEnemies();
    Attack(targets);
}
```

호출할 때마다 `List<Enemy>`와 내부 배열이 생성되거나 확장될 수 있다.

### 재사용할 Buffer 전달

호출자가 가진 List를 비우고 다시 사용할 수 있다.

```cs
public void FindAliveEnemies(List<Enemy> result)
{
    result.Clear();

    foreach (Enemy enemy in enemies)
    {
        if (enemy.IsAlive)
        {
            result.Add(enemy);
        }
    }
}
```

```cs
private readonly List<Enemy> targets = new(64);

void Update()
{
    FindAliveEnemies(targets);
    Attack(targets);
}
```

`Clear()`는 요소를 제거하지만 보통 List의 Capacity를 유지한다. 다음 Frame에 같은 내부 배열을 다시 사용할 수 있다.

### 결과 Collection 자체를 만들지 않는다

모든 대상을 저장할 필요가 없다면 순회 중 바로 처리할 수 있다.

```cs
public void AttackAliveEnemies()
{
    foreach (Enemy enemy in enemies)
    {
        if (!enemy.IsAlive)
        {
            continue;
        }

        Attack(enemy);
    }
}
```

하지만 이 방식이 항상 더 좋은 것은 아니다. 검색 결과를 여러 시스템에서 공유하거나 한 Frame 동안 동일한 Snapshot이 필요하다면 Buffer가 의도를 더 잘 표현한다.

### 변화가 있을 때만 갱신한다

UI 문자열을 매 Frame 만들 필요가 없다면 값이 바뀔 때만 갱신한다.

```cs
public void SetHp(int hp)
{
    if (currentHp == hp)
    {
        return;
    }

    currentHp = hp;
    hpText.text = $"HP: {currentHp}";
}
```

가장 효과적인 최적화는 같은 작업을 더 빠르게 반복하는 것이 아니라 필요하지 않은 반복을 제거하는 경우가 많다.

### 먼저 측정한다

다음과 같은 순서로 접근한다.

```text
Profiler로 느린 Frame 확인
↓
GC Alloc과 Memory 변화 확인
↓
호출 Stack에서 발생 위치 확인
↓
코드 또는 리소스 수명 변경
↓
동일 조건에서 다시 측정
```

코드만 보고 예상한 병목과 실제 Player에서 비용이 큰 지점은 다를 수 있다.

---

## 내부 동작

### 객체를 만들면 공간만 확보하는 것이 아니다

Managed 객체 생성에는 Heap에서 공간을 확보하고 객체의 타입 정보와 필드를 초기화하는 과정이 포함된다.

```cs
ProjectileData data = new ProjectileData();
```

생성 비용이 작더라도 수천 번 반복되면 할당량이 누적된다. 객체가 수명을 다한 뒤에는 GC가 참조 가능 여부를 확인해야 한다.

### 참조가 남으면 회수되지 않는다

```cs
private readonly List<Enemy> enemies = new();

public void Despawn(Enemy enemy)
{
    enemy.gameObject.SetActive(false);
}
```

GameObject를 비활성화해도 List가 Enemy를 계속 참조한다. 이것이 Pool의 의도라면 정상이고, 완전히 제거하려는 의도라면 참조를 정리해야 한다.

```cs
public void Remove(Enemy enemy)
{
    enemies.Remove(enemy);
    Destroy(enemy.gameObject);
}
```

`Destroy()` 호출과 C# 참조 해제, Native Resource의 실제 해제 시점은 모두 같지 않을 수 있다.

### Collection의 Capacity는 즉시 줄지 않는다

```cs
List<int> values = new(10_000);
values.Clear();
```

`Count`는 0이 되지만 확보한 내부 배열의 Capacity는 유지된다. 반복 사용에는 장점이지만 다시 사용하지 않는 큰 Buffer라면 메모리를 오래 잡는 원인이 될 수 있다.

```text
Count
현재 저장된 요소 수

Capacity
다시 할당하지 않고 담을 수 있는 공간
```

Capacity를 줄이는 작업도 새 배열과 복사를 유발할 수 있으므로 매번 수행할 작업은 아니다.

### 메모리는 하나의 Heap만으로 구성되지 않는다

Unity Player의 메모리는 Managed Heap뿐 아니라 Engine의 Native Memory, Graphics Driver, Executable Code와 플랫폼 영역을 포함한다.

Managed GC만 줄였는데 전체 메모리가 내려가지 않는다면 Texture, Mesh, Audio, AssetBundle과 RenderTexture 같은 Native Resource도 확인해야 한다.

---

## 실제 Unity에서는?

### Frame Time과 함께 본다

메모리 수치가 크다는 이유만으로 최적화 대상을 결정하지 않는다.

Profiler에서 다음 관계를 함께 확인한다.

```text
특정 Frame의 GC Alloc
GC.Collect 또는 GarbageCollector 관련 Spike
스크립트 호출 시간
전체 Frame Time
```

GC Alloc이 있어도 빈도와 양이 작아 사용자 경험에 영향이 없다면 우선순위가 낮을 수 있다.

### Editor 수치를 그대로 사용하지 않는다

Editor에는 Inspector, Console, Editor Tool과 Profiler 자체의 비용이 포함된다. 최종 플랫폼의 Development Build와 연결해 측정하면 게임 코드의 경향을 더 정확히 확인할 수 있다.

```text
재현 가능한 플레이 구간 준비
↓
대상 기기에서 여러 번 측정
↓
첫 실행과 안정화 이후 구간 구분
↓
변경 전후 같은 조건 비교
```

### 리소스 수명을 설계한다

Scene을 변경했다고 모든 Asset이 즉시 해제되는 것은 아니다. Static Field, Singleton, DontDestroyOnLoad 객체와 Asset 참조가 남아 있으면 관련 리소스도 유지될 수 있다.

Addressables를 사용한다면 Load 횟수와 Release 책임을 한 쌍으로 관리해야 한다.

```cs
AsyncOperationHandle<GameObject> handle =
    Addressables.LoadAssetAsync<GameObject>(key);

// 사용 종료 시
Addressables.Release(handle);
```

로드 방식에 따라 반환된 Handle과 Instance의 해제 API가 다를 수 있으므로 획득한 쪽이 해제 규칙도 함께 가져야 한다.

### Pool은 메모리를 없애지 않는다

Object Pool은 생성과 파괴를 반복하지 않고 객체를 재사용한다.

```text
Instantiate / Destroy 반복 감소
GC Alloc과 Native 생성 비용 감소
대신 Pool이 객체를 계속 보관
```

최대 동시 사용량보다 지나치게 큰 Pool은 유휴 메모리를 늘린다. Pool 크기와 축소 정책도 사용량을 측정해 정해야 한다.

### Low Memory 상황을 고려한다

모바일 플랫폼에서는 다른 앱과 운영체제 상태에 따라 사용할 수 있는 메모리가 달라진다. 평균 사용량뿐 아니라 Scene 전환, 대형 리소스 로드와 캐시가 겹치는 Peak Memory가 중요하다.

로드 전에 이전 리소스를 해제할지, 동시에 유지해야 하는지, 실패했을 때 품질을 낮출 수 있는지를 설계 단계에서 정한다.

---

## 실무에서 자주 하는 오해

### 메모리를 많이 사용하면 CPU도 항상 느리다

메모리 사용량과 CPU 실행 시간은 관련될 수 있지만 같은 지표는 아니다. 미리 계산한 데이터를 메모리에 캐시해 CPU 작업을 줄이는 구조도 있다.

### new는 모두 제거해야 한다

초기화나 Loading 구간의 필요한 객체 생성까지 없앨 이유는 없다. 반복되는 Hot Path에서 수명이 짧은 할당이 문제인지 먼저 확인해야 한다.

### GC Alloc이 0이 아니면 실패한 최적화다

0B는 유용한 목표가 될 수 있지만 모든 시스템의 절대 규칙은 아니다. 할당량, 빈도, 대상 플랫폼의 Frame Budget과 실제 GC 영향을 함께 판단한다.

### Clear를 호출하면 List 메모리도 해제된다

`Clear()`는 요소를 제거하지만 내부 Capacity는 보통 유지한다. 재사용에는 유리하고 장기간 사용하지 않는 큰 List에는 불리할 수 있다.

### Destroy를 호출하면 메모리가 즉시 줄어든다

Unity Object의 파괴 요청, Managed Wrapper의 참조 해제와 Native Resource 반환은 서로 다른 수명 주기를 가질 수 있다. 다른 객체가 Asset을 참조하고 있는지도 확인해야 한다.

### Object Pool은 항상 메모리를 줄인다

Pool은 반복 할당과 생성 비용을 줄이지만 객체를 보관하는 공간이 필요하다. 과도한 사전 생성은 시작 시간과 상주 메모리를 늘린다.

### 코드를 짧게 만들면 메모리도 줄어든다

LINQ나 보간 문자열처럼 짧은 표현이 내부적으로 Iterator, Delegate, Collection 또는 문자열을 만들 수 있다. 코드 줄 수와 Runtime Allocation은 직접적인 관계가 없다.

---

## 마무리

메모리 최적화는 사용량을 가장 작은 숫자로 만드는 작업이 아니다.

게임이 허용된 메모리 범위 안에서 안정적으로 실행되고, 플레이 중 할당과 GC로 Frame이 끊기지 않으며, 리소스 수명이 예측 가능하도록 만드는 작업이다.

```text
문제 재현
↓
전체 사용량과 Frame 할당 구분
↓
Managed와 Native 영역 구분
↓
할당 위치와 참조 수명 확인
↓
가장 영향이 큰 지점 수정
↓
동일한 조건에서 재측정
```

최적화 과정에서는 CPU 시간, 메모리 사용량과 코드 복잡도 사이의 교환도 생긴다. 모든 값을 캐시하면 계산은 줄지만 메모리는 늘고, 모든 객체를 즉시 버리면 상주 메모리는 줄어도 재생성 비용이 늘 수 있다.

측정 결과와 프로젝트의 목표 플랫폼을 기준으로 적절한 균형을 정해야 한다.

---

## 핵심 정리

- 메모리 사용량과 실행 중 메모리 할당은 서로 다른 지표다.
- 짧게 사는 Managed 객체를 반복 생성하면 GC 빈도와 Frame Spike가 증가할 수 있다.
- 메모리 누수는 불필요한 참조가 남는 문제이고, 과도한 할당은 임시 객체를 자주 만드는 문제다.
- Unity의 전체 메모리에는 Managed Heap뿐 아니라 Native Resource와 Graphics Memory도 포함된다.
- Collection의 `Clear()`는 요소를 제거하지만 Capacity를 보통 유지한다.
- Object Pool은 반복 생성 비용을 줄이지만 보관하는 객체만큼 상주 메모리를 사용한다.
- Editor가 아닌 대상 플랫폼 Player에서 Frame Time과 메모리를 함께 측정해야 한다.
- 평균 사용량뿐 아니라 Scene 전환과 리소스 로드가 겹치는 Peak Memory도 확인해야 한다.
- 최적화 전후를 같은 조건으로 측정해 실제 개선 여부를 검증해야 한다.
- 메모리, CPU 시간과 코드 복잡도의 균형을 프로젝트 조건에 맞게 결정해야 한다.
