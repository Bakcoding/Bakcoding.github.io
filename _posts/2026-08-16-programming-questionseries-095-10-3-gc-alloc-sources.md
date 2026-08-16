---
title: "[궁금시리즈] 10-3. GC Alloc은 어디에서 발생할까?"
excerpt: "C#"
categories:
  - CSharp
series: question-series
tags:
  - CSharp
permalink: /programming/10-3-gc-alloc-sources/
toc: true
toc_sticky: true
date: 2026-08-16 12:00:23 +0900
last_modified_at: 2026-08-16 12:00:23 +0900
---

## 들어가며

다음 코드에서 Managed Allocation이 발생한다는 사실은 쉽게 알 수 있다.

```cs
EnemyData data = new EnemyData();
int[] damages = new int[10];
```

Class 인스턴스와 배열을 새로 만들기 때문이다.

하지만 코드에 `new`가 보이지 않아도 GC Alloc은 발생할 수 있다.

```cs
Debug.Log("HP: " + player.Hp);

IEnumerable<Enemy> alive =
    enemies.Where(enemy => enemy.IsAlive);

object value = damage;
```

문자열 연결, LINQ 실행 과정, Delegate와 Boxing처럼 Compiler와 Runtime이 내부 객체를 만드는 경우가 있다.

한 번의 작은 할당은 문제가 되지 않을 수 있다. 같은 코드가 `Update()`에서 매 Frame, 여러 객체에 걸쳐 반복되면 짧게 사용한 객체가 Managed Heap에 계속 쌓이고 GC 실행 주기를 앞당긴다.

```text
1회 64B 할당
× 60 Frame
× 100개 객체
= 초당 약 375KB 할당
```

GC Alloc을 줄이려면 문법 이름을 외우는 것보다 실제로 어떤 결과 객체와 임시 객체가 만들어지는지 확인해야 한다.

---

## 개념 설명

### GC Alloc이 의미하는 것

Unity Profiler의 `GC Alloc`은 해당 코드 경로에서 새로 확보한 Managed Memory를 의미한다.

```text
GC Alloc 발생
↓
Managed Heap에 객체 생성
↓
참조가 사라져 Garbage가 됨
↓
나중에 GC가 검사하고 회수
```

할당된 객체가 오래 살아 있으면 메모리 사용량이 늘고, 짧게 살아도 반복 할당이면 GC가 처리할 Garbage가 늘어난다.

### 명시적인 객체와 배열 생성

Class, 배열과 Collection 생성은 명확한 할당 지점이다.

```cs
PlayerData data = new();
Vector3[] points = new Vector3[128];
List<Enemy> targets = new();
Dictionary<int, Enemy> lookup = new();
```

Collection은 객체 자체뿐 아니라 내부 저장 공간을 별도로 확보하고, Capacity가 부족할 때 더 큰 배열로 교체할 수 있다.

### 문자열 생성

String은 Immutable이므로 내용이 바뀌면 새로운 문자열이 만들어진다.

```cs
string message = "Score: " + score;
string label = $"Wave {wave} / {maxWave}";
string upper = playerName.ToUpper();
```

문자열 보간과 변환 API는 결과 문자열을 만든다. 여러 번 이어 붙이면 중간 문자열도 생길 수 있다.

### Boxing

Value Type을 `object`나 Value Type이 구현한 Interface로 다루는 과정에서 Boxing이 발생할 수 있다.

```cs
int damage = 10;
object boxed = damage;
```

값을 담을 Managed 객체가 Heap에 만들어지고 값이 복사된다.

### Delegate와 Closure

Lambda가 바깥 지역 변수를 캡처하면 값을 보관할 Closure 객체가 필요할 수 있다.

```cs
int minLevel = 10;

Predicate<Player> predicate =
    player => player.Level >= minLevel;
```

Compiler는 `minLevel`을 보관할 숨겨진 객체와 해당 메서드를 가리키는 Delegate를 구성할 수 있다.

### LINQ와 Iterator

LINQ는 Query를 표현하는 객체, Iterator, Delegate와 결과 Collection을 만들 수 있다.

```cs
Enemy[] result = enemies
    .Where(enemy => enemy.IsAlive)
    .OrderBy(enemy => enemy.Distance)
    .ToArray();
```

간결하지만 매 Frame 호출되는 경로에서는 각 단계의 할당과 순회 비용을 측정해야 한다.

---

## 코드 예제

매 Frame 가장 가까운 Enemy를 찾고 UI에 표시하는 코드가 있다.

```cs
void Update()
{
    Enemy? target = enemies
        .Where(enemy => enemy.IsAlive)
        .OrderBy(enemy => enemy.Distance)
        .FirstOrDefault();

    targetText.text = $"Target: {target?.name}";
}
```

이 코드는 LINQ Query와 Delegate, 정렬 과정의 데이터, 결과 문자열을 만들 가능성이 있다. 가장 가까운 대상 하나를 찾기 위해 전체 정렬까지 수행한다.

### 반복문으로 한 번만 순회한다

```cs
private Enemy? FindClosestAliveEnemy()
{
    Enemy? closest = null;
    float closestDistance = float.MaxValue;

    foreach (Enemy enemy in enemies)
    {
        if (!enemy.IsAlive)
        {
            continue;
        }

        if (enemy.Distance >= closestDistance)
        {
            continue;
        }

        closest = enemy;
        closestDistance = enemy.Distance;
    }

    return closest;
}
```

한 번의 순회로 목적을 달성하며 결과 Collection이 필요하지 않다.

### UI는 값이 변할 때 갱신한다

```cs
private Enemy? currentTarget;

private void SetTarget(Enemy? target)
{
    if (currentTarget == target)
    {
        return;
    }

    currentTarget = target;
    targetText.text = target == null
        ? "Target: None"
        : $"Target: {target.name}";
}
```

문자열 생성을 더 빠르게 만드는 대신 같은 값을 매 Frame 다시 만들지 않는다.

### Closure를 만들지 않는 Callback

반복문 안에서 지역 변수를 캡처하는 Callback을 등록하면 각 항목마다 Closure가 생길 수 있다.

```cs
foreach (Item item in items)
{
    button.onClick.AddListener(() => Select(item));
}
```

UI를 구성할 때 한 번 발생하는 할당이라면 허용할 수 있다. 목록을 자주 재구성한다면 Component가 자신의 데이터를 보관하고 캡처 없는 메서드를 등록하는 구조를 사용할 수 있다.

```cs
public sealed class ItemButton : MonoBehaviour
{
    private Item? item;

    public void Initialize(Item value)
    {
        item = value;
        button.onClick.AddListener(OnClick);
    }

    private void OnClick()
    {
        if (item != null)
        {
            Select(item);
        }
    }
}
```

Listener를 반복 등록하지 않도록 해제 시점도 함께 관리해야 한다.

### params 배열

`params` 인수는 호출부에서 배열을 만들 수 있다.

```cs
public void LogValues(params object[] values)
{
}

LogValues(player.Hp, player.Mp);
```

호출 과정에서 `object[]`가 생성되고 `int` 값은 Boxing될 수 있다.

반복 경로라면 자주 사용하는 시그니처를 별도 Overload로 제공할 수 있다.

```cs
public void LogValues(int hp, int mp)
{
}
```

### 재사용 가능한 Buffer

Unity API 중 결과 배열을 반환하는 형태는 호출 때마다 배열을 만들 수 있다.

```cs
Collider[] hits = Physics.OverlapSphere(
    transform.position,
    radius);
```

반복 호출에는 NonAlloc 형태와 재사용 Buffer를 사용할 수 있다.

```cs
private readonly Collider[] hitBuffer = new Collider[64];

private int FindTargets()
{
    return Physics.OverlapSphereNonAlloc(
        transform.position,
        radius,
        hitBuffer,
        targetMask);
}
```

Buffer가 가득 찬 경우 결과가 잘릴 수 있으므로 최대 크기와 초과 처리 정책이 필요하다.

---

## 내부 동작

### Collection 확장

`List<T>`의 Count가 Capacity를 넘으면 더 큰 내부 배열을 확보하고 기존 요소를 복사한다.

```text
Capacity 4, Count 4
↓ Add
더 큰 배열 할당
↓
기존 4개 요소 복사
↓
이전 배열은 나중에 GC 대상
```

예상 크기를 알고 있다면 초기 Capacity를 지정해 중간 확장을 줄일 수 있다.

```cs
List<Enemy> enemies = new(expectedEnemyCount);
```

지나치게 큰 Capacity는 사용하지 않는 메모리를 오래 유지하므로 실제 최대 사용량을 기준으로 정한다.

### 문자열의 Immutable 특성

```cs
string path = "Assets";
path += "/Characters";
path += "/Player";
```

기존 문자열 자체를 늘리는 것이 아니라 연결 결과를 담는 새 문자열이 만들어진다. 여러 조각을 반복 조합한다면 `StringBuilder`를 재사용하거나 데이터가 변경될 때만 생성하는 방식이 적합할 수 있다.

짧은 문자열 연결을 한 번 수행하는 코드까지 무조건 `StringBuilder`로 바꾸면 객체와 복잡도만 추가될 수 있다.

### Boxing과 Unboxing

```cs
int value = 10;
object boxed = value;
int result = (int)boxed;
```

Boxing에서는 Heap 객체가 만들어지고 값이 복사된다. Unboxing은 저장된 타입을 확인한 뒤 값을 꺼낸다.

Non-Generic Collection, `object` 기반 API와 일부 형식화 호출에서 Value Type이 `object`로 전달되는지 확인해야 한다.

### Closure가 생성되는 이유

지역 변수는 원래 메서드가 끝나면 Stack Frame과 함께 수명을 다한다. Lambda가 메서드 밖에서도 해당 값을 사용해야 한다면 Compiler는 값을 별도 객체로 옮긴다.

```text
지역 변수 캡처
↓
Compiler Generated Closure 객체
↓
Delegate가 Closure 객체 참조
↓
Callback이 살아 있는 동안 값 유지
```

Closure는 할당뿐 아니라 의도보다 긴 객체 수명을 만들 수 있다.

### IEnumerable의 구현에 따른 차이

`foreach` 자체가 항상 할당을 만드는 것은 아니다.

```cs
foreach (Enemy enemy in enemyList)
{
}
```

`List<T>`의 Enumerator는 struct다. 구체적인 `List<T>`로 순회하는 경우와 `IEnumerable<T>` Interface를 통해 순회하는 경우는 Boxing과 호출 형태가 달라질 수 있다.

문법만 보고 판단하지 않고 사용하는 Collection 타입과 빌드 환경에서 Profiler로 확인해야 한다.

---

## 실제 Unity에서는?

### Profiler에서 GC Alloc 호출 위치를 찾는다

CPU Usage Module의 Hierarchy나 Timeline에서 `GC Alloc`이 발생한 Sample을 확인한다.

```text
GC Alloc이 증가한 Frame 선택
↓
관련 Script Sample 확장
↓
호출 경로와 반복 횟수 확인
↓
발생 코드를 좁힌 뒤 동일 조건 재측정
```

Deep Profile은 세부 호출을 찾는 데 도움이 되지만 실행 비용과 할당 패턴 자체를 크게 바꿀 수 있다. 항상 켜 두는 측정 결과로 사용하지 않는다.

### Call Stacks 기록은 필요한 구간에 사용한다

Allocation Call Stack 기록을 사용하면 할당 발생 위치를 추적할 수 있다. 기록 자체의 Overhead가 있으므로 재현 구간을 좁혀 사용하고 최종 성능은 일반 Profiling 조건에서 다시 확인한다.

### Unity API의 반환 타입을 확인한다

다음 형태는 결과 Collection이나 배열을 새로 반환할 수 있다.

```cs
GetComponents<T>()
FindObjectsByType<T>()
Physics.OverlapSphere()
```

호출 빈도가 낮은 초기화 코드라면 단순한 API가 적합할 수 있다. 매 Frame 실행해야 한다면 결과 캐시, Buffer를 받는 Overload 또는 NonAlloc API가 있는지 확인한다.

### 로그도 할당을 만든다

```cs
Debug.Log($"Position: {transform.position}");
```

조건부 로그라도 인수 문자열을 먼저 만들면 로그 함수가 내부에서 무시하더라도 할당은 이미 발생할 수 있다.

```cs
if (enableCombatLog)
{
    Debug.Log($"Position: {transform.position}");
}
```

반복 경로의 진단 로그는 개발 빌드 여부, 로그 Level과 생성 조건을 함께 관리한다.

### Editor와 Player를 구분한다

Editor는 Inspector, Console과 Editor 전용 코드가 추가로 동작한다. Editor에서 발견한 할당은 원인 분석의 단서로 사용하고 대상 플랫폼의 Development Player에서 같은 경로를 다시 확인한다.

Scripting Backend와 Unity 버전에 따라 Compiler와 Runtime 최적화 결과도 달라질 수 있으므로 오래된 고정 할당 목록만 믿지 않는다.

---

## 실무에서 자주 하는 오해

### new 키워드만 찾으면 모든 할당을 찾을 수 있다

문자열 연산, Boxing, Closure, LINQ, `params`와 배열을 반환하는 API에도 명시적인 `new` 없이 할당이 발생할 수 있다.

### struct를 사용하면 할당이 절대 없다

struct 값 자체는 상황에 따라 Stack이나 다른 객체 내부에 저장되지만 `object`나 Interface로 변환되면 Boxing될 수 있다. struct 배열과 Collection의 내부 저장 공간도 별도로 필요하다.

### foreach는 항상 GC Alloc을 만든다

Collection과 Enumerator 구현, 정적 타입에 따라 다르다. 구체적인 `List<T>`의 struct Enumerator 순회와 Interface를 통한 순회를 같은 결과로 단정할 수 없다.

### LINQ는 절대 사용하면 안 된다

Editor Tool, 초기화와 드물게 실행되는 코드에서는 가독성이 더 중요할 수 있다. 문제는 호출 빈도와 실제 측정 없이 Hot Path에서 반복 사용하는 경우다.

### 캐시하면 모든 문제가 해결된다

캐시는 반복 할당을 줄이지만 참조를 오래 유지해 상주 메모리를 늘릴 수 있다. 캐시 크기, 갱신과 해제 정책이 함께 필요하다.

### NonAlloc API는 Buffer 크기를 신경 쓰지 않아도 된다

결과가 Buffer보다 많으면 일부 항목을 받지 못할 수 있다. 고정 크기 Buffer를 사용할 때 초과를 감지하고 확장하거나 결과를 나눠 처리할 정책이 필요하다.

### GC Alloc 0B가 항상 최우선 목표다

플레이 중 반복되는 핵심 경로에서는 유용한 목표지만 Loading이나 드문 작업의 작은 할당까지 복잡하게 제거하면 유지보수 비용이 더 커질 수 있다.

---

## 마무리

GC Alloc은 객체를 명시적으로 생성하는 코드에서만 발생하지 않는다.

Compiler가 만드는 Closure, Runtime의 Boxing, LINQ Iterator, 문자열 결과와 API의 반환 배열처럼 소스 코드에 직접 드러나지 않는 객체도 Managed Heap을 사용한다.

```text
반복되는 코드인가?
↓
어떤 결과 객체가 만들어지는가?
↓
호출당 할당량과 호출 횟수는 얼마인가?
↓
재사용하거나 호출 자체를 줄일 수 있는가?
↓
변경 후 Player에서 다시 측정
```

모든 할당을 제거할 필요는 없다. 초기화에서 한 번 만드는 명확한 객체는 코드 구조를 단순하게 한다. 우선순위는 매 Frame 반복되고, 다수 객체에서 호출되며, 실제 GC Spike와 연결되는 할당이다.

코드를 짧게 만드는 표현과 Runtime에서 객체를 적게 만드는 표현은 같지 않을 수 있다. Profiler의 수치와 호출 경로를 기준으로 선택해야 한다.

---

## 핵심 정리

- `GC Alloc`은 Managed Heap에 새 객체나 저장 공간을 확보할 때 발생한다.
- Class와 배열뿐 아니라 Collection 확장, 문자열 연산, Boxing, Closure와 LINQ도 할당 원인이 될 수 있다.
- `params` 호출은 인수 배열을 만들고 Value Type 인수의 Boxing을 유발할 수 있다.
- `foreach`의 할당 여부는 Collection, Enumerator 구현과 정적 타입에 따라 달라진다.
- 반복 검색 결과는 Buffer를 재사용하거나 결과 Collection 없이 바로 처리할 수 있다.
- NonAlloc API는 Buffer가 가득 찼을 때의 초과 처리 정책이 필요하다.
- UI와 문자열은 매 Frame보다 값이 변경될 때 갱신하는 편이 효과적이다.
- Profiler의 Allocation Sample과 호출 Stack으로 실제 발생 위치와 반복 횟수를 확인해야 한다.
- Editor 측정 결과는 대상 플랫폼 Player에서 다시 검증해야 한다.
- 모든 할당보다 Hot Path에서 반복되어 GC Spike로 이어지는 할당을 먼저 줄여야 한다.
