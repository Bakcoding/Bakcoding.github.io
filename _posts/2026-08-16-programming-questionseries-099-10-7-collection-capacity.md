---
title: "[궁금시리즈] 10-7. Collection의 Capacity는 메모리에 어떤 영향을 줄까?"
excerpt: "C#"
categories:
  - CSharp
series: question-series
tags:
  - CSharp
permalink: /programming/10-7-collection-capacity/
toc: true
toc_sticky: true
date: 2026-08-16 12:00:27 +0900
last_modified_at: 2026-08-16 12:00:27 +0900
---

## 들어가며

`List<T>`에 요소를 추가하면 필요한 만큼 메모리가 정확히 하나씩 늘어난다고 생각하기 쉽다.

```cs
List<Enemy> enemies = new();

enemies.Add(enemyA);
enemies.Add(enemyB);
```

실제로 List는 요소를 담는 내부 배열을 사용하고, 배열이 가득 차면 더 큰 배열을 확보한다.

```text
기존 배열 Capacity 부족
↓
더 큰 배열 생성
↓
기존 요소 복사
↓
새 배열로 교체
↓
기존 배열은 GC 대상
```

이 과정은 CPU 복사 비용과 Managed Allocation을 함께 만든다.

반대로 큰 Capacity를 미리 지정하면 확장은 줄지만 사용하지 않는 공간을 계속 보관한다.

Collection 최적화는 Capacity를 가장 크게 잡거나 매번 줄이는 작업이 아니다. 실제 요소 수의 변화와 Collection의 재사용 수명을 기준으로 확장 횟수와 상주 메모리 사이의 균형을 정하는 작업이다.

---

## 개념 설명

### Count와 Capacity

`List<T>`에는 서로 다른 두 크기가 있다.

```cs
List<int> values = new(capacity: 100);

values.Add(10);
values.Add(20);

Debug.Log(values.Count);    // 2
Debug.Log(values.Capacity); // 100
```

```text
Count
└─ 현재 저장된 요소 수

Capacity
└─ 내부 배열을 다시 할당하지 않고 저장할 수 있는 요소 수
```

Count가 2여도 100개를 담을 내부 공간은 이미 확보되어 있다.

### Capacity 확장

Count가 Capacity를 넘으려고 하면 List는 더 큰 내부 배열로 교체한다.

```cs
List<int> values = new(capacity: 4);

for (int i = 0; i < 5; i++)
{
    values.Add(i);
}
```

다섯 번째 요소를 추가할 공간이 없으므로 확장이 필요하다.

정확한 증가 규칙은 Runtime 구현에 따라 달라질 수 있으므로 Capacity가 항상 특정 배수로 늘어난다고 코드 계약처럼 사용하면 안 된다.

### Clear는 Capacity를 유지한다

```cs
values.Clear();
```

`Clear()`를 호출하면 Count는 0이 되지만 일반적으로 Capacity는 그대로 유지된다.

```text
Clear 전
Count 80 / Capacity 128

Clear 후
Count 0 / Capacity 128
```

다음 Frame에 다시 비슷한 수의 요소를 담는 Buffer라면 재할당을 피할 수 있다.

### Dictionary의 Capacity

`Dictionary<TKey, TValue>`도 Entry를 보관할 내부 저장 공간을 사용한다.

```cs
Dictionary<int, Enemy> enemyById = new(256);
```

요소가 늘어 공간이 부족하면 더 큰 저장 공간을 확보하고 기존 Entry를 새 구조에 배치한다. Hash Table의 Bucket 구성도 갱신되므로 단순 배열 복사보다 추가 작업이 필요할 수 있다.

이를 보통 Rehashing 과정으로 설명한다.

### Capacity는 실제 데이터가 아니다

참조 타입 List의 내부 배열은 객체 자체가 아니라 참조를 저장한다.

```cs
List<Enemy> enemies = new(1000);
```

Enemy 1000개가 만들어지는 것은 아니지만 참조 1000개를 담을 배열 공간은 확보된다.

Value Type Collection은 요소 값이 내부 저장 공간에 직접 들어가므로 구조체 크기가 Capacity 비용에 직접 영향을 준다.

---

## 코드 예제

### 예상 크기 없이 추가

```cs
public List<Enemy> BuildEnemyWave(int count)
{
    List<Enemy> result = new();

    for (int i = 0; i < count; i++)
    {
        result.Add(CreateEnemy(i));
    }

    return result;
}
```

최종 개수를 이미 알고 있는데 기본 Capacity에서 시작하면 생성 과정에서 내부 배열이 여러 번 확장될 수 있다.

### 초기 Capacity 지정

```cs
public List<Enemy> BuildEnemyWave(int count)
{
    List<Enemy> result = new(count);

    for (int i = 0; i < count; i++)
    {
        result.Add(CreateEnemy(i));
    }

    return result;
}
```

최종 Count가 정확히 `count`라면 중간 확장과 복사를 줄일 수 있다.

### 재사용 Buffer

```cs
private readonly List<Enemy> visibleEnemies = new(64);

public IReadOnlyList<Enemy> CollectVisibleEnemies()
{
    visibleEnemies.Clear();

    foreach (Enemy enemy in enemies)
    {
        if (enemy.IsVisible)
        {
            visibleEnemies.Add(enemy);
        }
    }

    return visibleEnemies;
}
```

반환한 List는 다음 호출에서 내용이 바뀐다. 호출자가 결과를 저장하거나 수정하면 안 된다는 수명 계약이 필요하다.

Callback 범위에서만 사용하게 만들면 소유권이 더 명확하다.

```cs
public void ForEachVisibleEnemy(Action<Enemy> action)
{
    foreach (Enemy enemy in enemies)
    {
        if (enemy.IsVisible)
        {
            action(enemy);
        }
    }
}
```

단, 반복 호출에서 캡처 Lambda를 전달하면 Closure 할당이 생길 수 있으므로 호출 방식도 측정해야 한다.

### 큰 Peak 이후 Capacity 처리

전투 중 한 번만 10,000개 요소를 담은 List가 이후에도 살아 있다고 가정한다.

```cs
temporaryResults.Clear();
```

Count는 0이지만 큰 내부 배열은 유지된다.

다시는 같은 크기를 사용하지 않는다는 사실이 분명하면 `TrimExcess()`를 검토할 수 있다.

```cs
temporaryResults.Clear();
temporaryResults.TrimExcess();
```

또는 Collection 자체를 버리고 필요할 때 적절한 크기로 다시 만들 수 있다.

```cs
temporaryResults = new List<Result>(normalCapacity);
```

두 방법 모두 새 저장 공간 할당이나 데이터 복사를 만들 수 있다. 매 Frame 사용하는 최적화가 아니라 수명 단계가 바뀌는 지점에서 선택한다.

### Capacity를 직접 줄일 때

```cs
if (results.Count == 0 &&
    results.Capacity > maxRetainedCapacity)
{
    results.Capacity = normalCapacity;
}
```

Capacity는 Count보다 작게 지정할 수 없다.

```cs
results.Capacity = results.Count - 1;
// ArgumentOutOfRangeException
```

현재 요소가 있다면 최소한 Count 이상을 유지해야 한다.

### Dictionary 초기 용량

등록할 요소 수를 알고 있다면 생성할 때 Capacity를 지정한다.

```cs
Dictionary<int, Skill> skillById =
    new(allSkills.Count);

foreach (Skill skill in allSkills)
{
    skillById.Add(skill.Id, skill);
}
```

동일한 Key를 다시 추가하면 Capacity와 무관하게 예외가 발생한다. 초기 용량은 중복 Key 정책을 대신하지 않는다.

---

## 내부 동작

### List의 내부 배열

List는 연속된 배열에 요소를 저장한다.

```text
List<int>

Count = 3
Capacity = 4

┌────┬────┬────┬────┐
│ 10 │ 20 │ 30 │ 빈칸 │
└────┴────┴────┴────┘
```

연속 저장은 Index 접근과 순회에 유리하다. 중간 삽입과 삭제에서는 뒤쪽 요소를 이동해야 할 수 있다.

Capacity 확장 시에는 더 큰 배열을 만들고 Count만큼 기존 요소를 복사한다.

```text
기존 Capacity 4
↓
새 Capacity 확보
↓
4개 요소 복사
↓
기존 배열 Garbage
```

### 참조 제거와 Clear

참조 타입 요소를 담은 List에서 `Clear()`는 내부 배열이 이전 객체를 계속 붙잡지 않도록 사용 중이던 영역의 참조를 정리한다.

```cs
List<Enemy> enemies = new();
enemies.Add(enemy);
enemies.Clear();
```

내부 배열 자체는 남아도 `enemy` 참조가 제거되므로 다른 참조가 없다면 Enemy Wrapper는 GC 대상이 될 수 있다.

Capacity 유지와 요소 참조 유지는 같은 개념이 아니다.

### Dictionary의 Bucket과 Entry

Dictionary는 Key의 Hash Code를 이용해 탐색 위치를 좁힌다.

```text
Key
↓ GetHashCode
Bucket 선택
↓
Entry에서 Key 비교
↓
Value 반환
```

요소가 늘어 저장 공간을 확장하면 Bucket과 Entry 구조를 다시 구성해야 한다. 큰 Dictionary를 한 번에 채울 때 적절한 초기 Capacity가 확장 횟수를 줄이는 이유다.

Hash Code가 자주 충돌하면 Capacity가 충분해도 탐색 비용이 늘 수 있다. 올바른 `Equals()`와 `GetHashCode()` 구현이 필요하다.

### Value Type 요소 크기

```cs
public struct Sample
{
    public Vector3 Position;
    public Quaternion Rotation;
    public Color Color;
}
```

```cs
List<Sample> samples = new(100_000);
```

큰 구조체는 내부 배열에 값이 직접 저장되어 Capacity와 복사 비용이 커진다. List 확장이나 값 반환 과정에서 큰 복사가 반복되는지도 확인해야 한다.

Class로 바꾸면 List에는 참조만 저장되지만 객체별 할당과 간접 접근이 생긴다. 단순히 요소가 크다는 이유만으로 선택하지 않는다.

### Reserved와 Used의 차이

Collection의 Capacity도 예약 공간과 실제 사용 공간의 차이를 만든다.

```text
Capacity 1024
Count 120

Used Element 120
Reserved Slot 904
```

여유 공간은 다음 추가 작업의 재할당을 줄이는 비용으로 유지된다.

---

## 실제 Unity에서는?

### Frame Buffer는 Capacity를 유지한다

Physics 결과, Visible 대상과 AI 후보처럼 매 Frame 비슷한 수를 담는 List는 `Clear()` 후 재사용하는 편이 일반적이다.

```cs
private readonly List<Collider> hits = new(32);

void Update()
{
    hits.Clear();
    CollectHits(hits);
    ProcessHits(hits);
}
```

매 Frame `TrimExcess()`를 호출하면 재사용할 배열을 줄였다가 다음 Frame에 다시 확장하는 반대 효과가 생길 수 있다.

### 일반 값과 Peak 값을 구분한다

개발 빌드에서 Count와 Capacity의 최대값을 기록할 수 있다.

```cs
peakCount = Mathf.Max(peakCount, targets.Count);
peakCapacity = Mathf.Max(peakCapacity, targets.Capacity);
```

다음 상황을 구분한다.

```text
Count가 Capacity 근처에서 반복
└─ 현재 Capacity 유지가 유리

일시적 Peak 이후 Count가 장기간 작음
└─ 단계 전환 시 축소 검토

매번 Capacity 확장
└─ 초기 Capacity 또는 수집 구조 검토
```

### Pool에 반환할 때 Collection을 정리한다

Pooled GameObject가 큰 List를 필드로 가지고 있다면 객체를 반환해도 List Capacity는 남는다.

```cs
public void OnRelease()
{
    targets.Clear();
}
```

재사용 주기가 짧다면 Capacity 유지가 적합하다. 한 번의 특수 상황으로 List가 지나치게 커졌다면 상한을 기준으로 축소할 수 있다.

```cs
public void OnRelease()
{
    targets.Clear();

    if (targets.Capacity > 1024)
    {
        targets.Capacity = 128;
    }
}
```

상한은 임의의 숫자가 아니라 실제 사용 분포와 대상 플랫폼의 메모리 제한으로 정한다.

### Serialized List의 크기

Inspector에서 설정한 List와 Runtime에 추가한 요소를 구분해야 한다. Prefab이나 Scene에 직렬화된 큰 List는 로드 데이터 크기와 객체 초기화에도 영향을 줄 수 있다.

Runtime Cache로만 사용할 List라면 직렬화 대상에서 제외하고 필요한 시점에 적절한 Capacity로 준비한다.

### Native Collection도 Capacity가 있다

`NativeList<T>` 같은 Native Collection도 Length와 Capacity를 구분한다.

```text
Managed List
└─ Managed 배열과 GC 수명

NativeList
└─ Native Allocator와 Dispose 수명
```

개념은 비슷해도 메모리 영역과 해제 책임이 다르다. Native Collection은 Allocator 수명에 맞춰 `Dispose()`해야 한다.

### Profiler로 확장 시점을 찾는다

Collection 확장은 지속적인 1B 단위 증가가 아니라 특정 Add 시점의 배열 할당과 복사로 나타난다.

Profiler에서 GC Alloc이 발생한 Frame의 호출 경로를 확인하고, 해당 Collection의 Count와 Capacity가 어떤 입력에서 증가했는지 기록한다.

---

## 실무에서 자주 하는 오해

### Count가 0이면 Collection이 메모리를 사용하지 않는다

`Clear()` 후에도 내부 Capacity는 남을 수 있다. Count는 논리적인 요소 수이고 Capacity는 확보한 저장 공간이다.

### Capacity는 크게 잡을수록 좋다

확장과 복사는 줄지만 사용하지 않는 공간이 상주한다. Collection 수가 많거나 요소 구조체가 크면 과도한 Capacity 비용도 커진다.

### Capacity는 항상 두 배로 증가한다

구현에 따라 증가 정책이 달라질 수 있다. 특정 배율을 Runtime 계약으로 가정하지 않고 필요한 최종 크기를 직접 지정한다.

### Clear를 호출하면 요소 객체도 파괴된다

List가 가진 참조를 제거할 뿐이다. 다른 참조가 남아 있으면 객체는 살아 있고 Unity Object의 Native 부분을 `Destroy()`하는 작업도 아니다.

### TrimExcess는 자주 호출할수록 메모리가 절약된다

축소 과정 자체가 복사와 할당을 만들 수 있고 다음 추가에서 다시 확장될 수 있다. 큰 Peak가 끝나고 장기간 작은 상태가 유지될 때 검토한다.

### 초기 Capacity는 정확히 맞춰야 한다

약간의 여유는 정상적인 성장에서 재할당을 줄인다. 지나치게 작은 값과 실제 최대값보다 훨씬 큰 값을 피하고 측정된 분포를 기준으로 정한다.

### Dictionary Capacity만 늘리면 조회가 항상 빨라진다

Key의 Hash 품질과 충돌, `Equals()` 비용도 조회 성능에 영향을 준다. Capacity는 올바른 Key 구현을 대신하지 않는다.

### 재사용 List를 반환하면 안전하다

호출자가 참조를 저장하면 다음 `Clear()`에서 내용이 바뀐다. 소유권, 유효 범위와 수정 가능 여부를 API 계약으로 정해야 한다.

---

## 마무리

Collection은 현재 요소만 담는 것이 아니라 다음 요소를 빠르게 추가하기 위한 여유 공간을 함께 관리한다.

Capacity는 확장 횟수와 복사 비용을 줄이지만 그만큼 메모리를 예약한다.

```text
최종 요소 수를 알고 있는가?
└─ 초기 Capacity 지정

비슷한 크기로 반복 사용하는가?
└─ Clear 후 Capacity 재사용

일시적 Peak 후 장기간 작아지는가?
└─ 단계 전환 시 축소 검토

크기가 계속 예측을 벗어나는가?
└─ 입력과 알고리즘부터 확인
```

`Clear()`와 `TrimExcess()`는 반대 목적을 가진다. `Clear()`는 저장 공간을 재사용하고, `TrimExcess()`는 앞으로 사용하지 않을 여유 공간을 줄인다.

어느 쪽이 적합한지는 Collection 하나의 현재 Count가 아니라 사용 주기, Peak 분포, 요소 크기와 전체 Collection 개수를 기준으로 판단해야 한다.

---

## 핵심 정리

- `Count`는 현재 요소 수이고 `Capacity`는 재할당 없이 담을 수 있는 저장 공간이다.
- Count가 Capacity를 넘으면 더 큰 내부 배열을 만들고 기존 요소를 복사할 수 있다.
- 최종 요소 수를 알고 있다면 초기 Capacity 지정으로 중간 확장을 줄일 수 있다.
- `Clear()`는 요소를 제거하지만 일반적으로 Capacity를 유지해 재사용에 유리하다.
- 참조 타입 List를 Clear하면 요소 참조는 제거되지만 요소 객체 자체를 직접 파괴하지는 않는다.
- `TrimExcess()`와 Capacity 축소는 매 Frame이 아니라 큰 Peak가 끝난 수명 경계에서 검토한다.
- Dictionary 확장에는 저장 공간 재구성과 Rehashing 작업이 포함될 수 있다.
- 큰 Value Type Collection은 Capacity와 확장 시 복사 비용이 커질 수 있다.
- 재사용 Collection을 외부에 반환할 때는 결과의 유효 범위와 소유권을 명확히 해야 한다.
- 실제 Count와 Capacity의 Peak 분포를 측정해 확장 비용과 상주 메모리 사이의 균형을 정해야 한다.
