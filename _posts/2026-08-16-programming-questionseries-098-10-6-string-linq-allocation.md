---
title: "[궁금시리즈] 10-6. 문자열과 LINQ는 왜 메모리 할당을 만들까?"
excerpt: "C#"
categories:
  - CSharp
series: question-series
tags:
  - CSharp
permalink: /programming/10-6-string-linq-allocation/
toc: true
toc_sticky: true
date: 2026-08-16 12:00:26 +0900
last_modified_at: 2026-08-16 12:00:26 +0900
---

## 들어가며

문자열 보간과 LINQ는 복잡한 작업을 짧고 읽기 쉽게 표현한다.

```cs
statusText.text = $"HP: {player.Hp} / {player.MaxHp}";
```

```cs
Enemy? target = enemies
    .Where(enemy => enemy.IsAlive)
    .OrderBy(enemy => enemy.Distance)
    .FirstOrDefault();
```

두 코드 모두 의도가 분명하다. 문제는 같은 표현이 `Update()`에서 매 Frame, 여러 객체에 의해 호출될 때다.

String은 내용을 바꿀 수 없는 Immutable 객체이므로 결과가 달라질 때 새 문자열이 필요하다. LINQ는 Query 단계를 표현하는 Iterator와 Delegate를 구성하고, 일부 연산은 결과 Collection이나 정렬용 Buffer를 만든다.

```text
간결한 소스 코드
≠
한 번의 Runtime 작업
```

문자열과 LINQ를 없애는 것이 목표는 아니다. 데이터가 얼마나 자주 바뀌고, Query가 몇 번 실행되며, 결과를 어떤 형태로 소비하는지에 맞게 사용해야 한다.

---

## 개념 설명

### String은 Immutable이다

String 객체가 생성되면 내부 문자 내용은 바뀌지 않는다.

```cs
string path = "Assets";
path += "/Characters";
```

두 번째 줄은 기존 `"Assets"` 문자열의 뒤를 늘리는 작업이 아니다.

```text
기존 String: "Assets"
+
추가 String: "/Characters"
↓
새 String: "Assets/Characters"
```

변수 `path`가 새 문자열을 가리키도록 바뀐다.

### 문자열 보간도 결과 String을 만든다

```cs
string message = $"Score: {score}";
```

Compiler와 Runtime은 대상 Framework와 보간 형태에 맞는 방식으로 결과 문자열을 구성한다. 구현 최적화가 적용될 수 있어도 최종 String 객체가 필요하다는 사실은 같다.

값이 변하지 않아도 코드를 다시 실행하면 동일한 내용의 새 결과가 생성될 수 있다.

### LINQ는 Query를 구성한다

```cs
IEnumerable<Enemy> query = enemies
    .Where(enemy => enemy.IsAlive)
    .Select(enemy => enemy.Target);
```

`Where()`와 `Select()`는 보통 결과 전체를 즉시 배열로 만드는 대신 원본, 조건 Delegate와 다음 연산을 보관한 Query 객체를 반환한다.

```text
원본 enemies
↓ Where 조건
살아 있는 Enemy
↓ Select 변환
Target
```

실제 순회는 `foreach`, `First()`, `Count()`나 `ToList()`처럼 결과가 필요할 때 시작된다. 이를 Deferred Execution이라고 한다.

### 모든 LINQ 연산의 비용은 같지 않다

```text
Where / Select
└─ 요소를 하나씩 전달할 수 있음

First / Any
└─ 조건을 만족하면 일찍 종료 가능

ToList / ToArray
└─ 전체 결과를 새 Collection에 저장

OrderBy / GroupBy
└─ 정렬 또는 그룹 구성을 위해 데이터를 보관
```

LINQ라는 이름 하나로 비용을 단정하지 않고 사용하는 연산과 결과 소비 방식을 나눠 봐야 한다.

### Delegate와 Capture

```cs
float maxDistance = 10f;

IEnumerable<Enemy> nearby = enemies.Where(
    enemy => enemy.Distance <= maxDistance);
```

Lambda가 바깥의 `maxDistance`를 사용하면 값을 보관할 Closure 객체가 필요할 수 있다. Query를 얼마나 자주 새로 만드는지도 할당량에 영향을 준다.

---

## 코드 예제

### 반복 문자열 연결

```cs
string result = string.Empty;

foreach (Item item in items)
{
    result += item.Name + "\n";
}
```

반복할 때마다 이전 결과와 새 조각을 합친 String이 만들어진다.

```text
"Sword\n"
↓
"Sword\nPotion\n"
↓
"Sword\nPotion\nKey\n"
```

문자열이 길어질수록 앞에서 만든 내용도 새 결과로 다시 복사된다.

### StringBuilder 사용

```cs
private readonly StringBuilder builder = new(256);

public string BuildItemList(IReadOnlyList<Item> items)
{
    builder.Clear();

    foreach (Item item in items)
    {
        builder.AppendLine(item.Name);
    }

    return builder.ToString();
}
```

`StringBuilder`는 내부 Buffer에 내용을 쌓아 중간 String 생성을 줄인다. `ToString()`에서는 최종 String이 만들어진다.

공유 Builder를 재사용할 때는 동시에 두 작업이 사용하지 않는지 확인해야 한다. Thread나 재진입 가능성이 있다면 지역 Builder 또는 별도 Pool이 더 안전하다.

### UI 변경 감지

매 Frame Builder를 사용하는 것보다 갱신 자체를 줄이는 편이 효과가 크다.

```cs
private int displayedHp = -1;
private int displayedMaxHp = -1;

public void RefreshHp(int hp, int maxHp)
{
    if (displayedHp == hp &&
        displayedMaxHp == maxHp)
    {
        return;
    }

    displayedHp = hp;
    displayedMaxHp = maxHp;
    statusText.text = $"HP: {hp} / {maxHp}";
}
```

값이 바뀌는 Event에서만 호출하도록 만들면 비교 코드도 제거할 수 있다.

### 전체 정렬 없이 최솟값 찾기

```cs
Enemy? closest = enemies
    .Where(enemy => enemy.IsAlive)
    .OrderBy(enemy => enemy.Distance)
    .FirstOrDefault();
```

가장 가까운 대상 하나만 필요하다면 전체 순서를 만들 이유가 없다.

```cs
private static Enemy? FindClosest(
    IReadOnlyList<Enemy> enemies)
{
    Enemy? closest = null;
    float closestDistance = float.MaxValue;

    for (int i = 0; i < enemies.Count; i++)
    {
        Enemy enemy = enemies[i];

        if (!enemy.IsAlive ||
            enemy.Distance >= closestDistance)
        {
            continue;
        }

        closest = enemy;
        closestDistance = enemy.Distance;
    }

    return closest;
}
```

반복문 전환의 이점은 LINQ 문법을 제거한 것뿐 아니라 정렬 알고리즘 자체를 없앤 데 있다.

### ToList의 반복 호출

```cs
List<Enemy> aliveEnemies = enemies
    .Where(enemy => enemy.IsAlive)
    .ToList();
```

`ToList()`는 Query 결과를 담을 새 List와 내부 저장 공간을 만든다.

결과 Snapshot이 필요하다면 호출자가 가진 Buffer를 재사용할 수 있다.

```cs
private readonly List<Enemy> aliveEnemies = new(64);

private void CollectAliveEnemies()
{
    aliveEnemies.Clear();

    foreach (Enemy enemy in enemies)
    {
        if (enemy.IsAlive)
        {
            aliveEnemies.Add(enemy);
        }
    }
}
```

### Query를 여러 번 열거하지 않는다

```cs
IEnumerable<Enemy> query = enemies
    .Where(enemy => enemy.IsAlive);

int count = query.Count();
Enemy? first = query.FirstOrDefault();
```

Deferred Query는 `Count()`와 `FirstOrDefault()`에서 각각 실행될 수 있다. 조건 검사와 원본 순회가 반복된다.

한 번의 순회로 필요한 값을 함께 계산한다.

```cs
int count = 0;
Enemy? first = null;

foreach (Enemy enemy in enemies)
{
    if (!enemy.IsAlive)
    {
        continue;
    }

    count++;
    first ??= enemy;
}
```

결과를 여러 곳에서 반복 사용해야 하고 Snapshot 의미가 맞다면 한 번 `ToList()`로 Materialize하는 편이 오히려 명확할 수도 있다.

---

## 내부 동작

### 문자열 연결의 복사량

String은 기존 공간을 확장할 수 없으므로 결과 길이에 맞는 공간을 확보하고 문자를 복사한다.

```text
"A" + "B"
결과 길이 2의 String 생성
↓
"AB" + "C"
결과 길이 3의 String 생성
```

반복 횟수가 많을수록 이미 만든 앞부분을 여러 번 복사할 수 있다. `StringBuilder`는 Capacity가 허용하는 동안 같은 Buffer에 추가해 중간 복사를 줄인다.

Builder도 Capacity를 넘으면 더 큰 Buffer를 확보할 수 있다. 예상 길이를 안다면 적절한 초기 Capacity가 도움이 된다.

### 문자열 상수와 Runtime 문자열

소스 코드의 문자열 Literal은 Interning 대상이 될 수 있다.

```cs
string state = "Idle";
```

반면 Runtime 값으로 조합한 문자열이 내용만 같다고 해서 모두 같은 객체를 자동 공유한다고 기대하면 안 된다.

```cs
string state = prefix + index;
```

동적인 문자열을 강제로 Interning하면 Intern Pool에 오래 남아 메모리를 유지할 수 있으므로 반복 UI 문자열의 해결책으로 사용하지 않는다.

### LINQ Iterator Pipeline

```cs
IEnumerable<int> query = values
    .Where(value => value > 0)
    .Select(value => value * 2);
```

각 단계는 원본 Enumerator에서 값을 요청하고 조건이나 변환을 적용해 다음 단계로 전달한다.

```text
MoveNext 요청
↓
Select Iterator
↓
Where Iterator
↓
원본 Enumerator
↓
값이 위로 전달
```

전체 결과 배열 없이 하나씩 처리할 수 있지만 Iterator와 Delegate 호출 경계가 추가된다.

### Materialization

```cs
Enemy[] array = query.ToArray();
List<Enemy> list = query.ToList();
```

Materialization은 지연 Query를 즉시 실행해 결과를 저장한다.

장점은 이후 원본이 바뀌어도 Snapshot을 유지하고 같은 결과를 여러 번 순회할 수 있다는 점이다. 비용은 전체 순회와 결과 Collection 할당이다.

### Closure의 수명

```cs
int threshold = GetThreshold();
Func<Enemy, bool> filter =
    enemy => enemy.Level >= threshold;
```

`filter`가 오래 보관되면 캡처한 `threshold`를 가진 Closure도 함께 살아 있다. 참조 타입을 캡처하면 해당 객체의 수명까지 의도보다 길어질 수 있다.

```cs
Player player = currentPlayer;
button.onClick.AddListener(() => Select(player));
```

할당량뿐 아니라 Event 해제와 참조 수명도 확인해야 한다.

---

## 실제 Unity에서는?

### 매 Frame UI 문자열 생성을 피한다

Score, HP와 Timer를 표시하기 위해 모든 Text를 매 Frame 갱신하는 경우가 많다.

```cs
void Update()
{
    scoreText.text = $"Score: {score}";
}
```

Score가 바뀌는 시점에만 갱신하거나 일정한 표시 주기를 사용한다.

Timer처럼 계속 변하는 값도 화면에 필요한 정밀도를 기준으로 갱신 빈도를 줄일 수 있다.

```cs
private int previousSecond = -1;

void Update()
{
    int second = Mathf.CeilToInt(remainingTime);

    if (second == previousSecond)
    {
        return;
    }

    previousSecond = second;
    timerText.text = second.ToString();
}
```

### Update의 LINQ는 호출 수를 곱해 본다

한 객체에서 한 번 실행한 Query가 작아 보여도 같은 Component가 수백 개 존재할 수 있다.

```text
Query당 작은 할당
× Component 수
× 초당 Frame 수
```

Profiler에서 호출당 GC Alloc뿐 아니라 호출 횟수와 전체 합계를 확인한다.

### 초기화와 Editor Tool에서는 기준이 다르다

```cs
Dictionary<string, Skill> skills = allSkills
    .Where(skill => skill.IsEnabled)
    .ToDictionary(skill => skill.Id);
```

Scene Loading 중 한 번 실행되고 결과를 계속 사용하는 코드라면 LINQ의 가독성과 선언적 표현이 더 가치 있을 수 있다.

Editor Tool도 매 Frame Gameplay 경로와 같은 0B 기준을 적용할 필요는 없다. 다만 큰 Asset Database를 반복 Query한다면 Editor 반응성 문제는 별도로 측정한다.

### Profiler 결과는 Build에서 확인한다

LINQ와 문자열 구현은 Unity 버전, Scripting Backend와 API 형태에 따라 최적화 결과가 다를 수 있다.

```text
소스 코드 추정
↓
Profiler에서 GC Alloc 확인
↓
대상 플랫폼 Development Build 확인
↓
변경 전후 Frame 비교
```

특정 문법은 반드시 몇 Byte를 할당한다고 고정해서 외우지 않는다.

### Collection Pool을 검토한다

Unity는 임시 List와 Dictionary를 재사용할 수 있는 Pool API를 제공한다. 사용 범위를 명확히 제한할 수 있다면 임시 Collection 할당을 줄일 수 있다.

```cs
using (ListPool<Enemy>.Get(out List<Enemy> buffer))
{
    CollectAliveEnemies(buffer);
    Process(buffer);
}
```

Pool에 반환된 List 참조를 저장하거나 다른 시스템에 넘기면 이후 사용자가 같은 Collection을 재사용할 수 있다. `using` 범위 밖으로 참조를 내보내지 않는다.

---

## 실무에서 자주 하는 오해

### 문자열 보간은 항상 문자열 연결보다 느리다

Compiler와 Runtime이 보간을 처리하는 방식은 대상 환경과 인수에 따라 달라진다. 중요한 사실은 결과 문자열이 필요하고 호출 빈도에 따라 그 할당이 누적된다는 점이다.

### StringBuilder를 쓰면 문자열 할당이 0이 된다

중간 String 생성을 줄이지만 `ToString()`에서 최종 String이 만들어진다. Builder 자체와 내부 Buffer의 수명도 관리해야 한다.

### 짧은 문자열도 모두 StringBuilder로 바꿔야 한다

한 번 실행되는 간단한 연결에는 Builder 생성과 복잡도가 더 클 수 있다. 반복 횟수, 조각 수와 실제 할당을 기준으로 선택한다.

### LINQ는 호출 즉시 모든 결과를 만든다

많은 LINQ 연산은 Deferred Execution을 사용한다. `foreach`, `First()`나 `ToList()`처럼 결과를 소비할 때 Query가 실행된다.

### Deferred Execution이면 할당도 비용도 없다

결과 Collection을 즉시 만들지 않을 뿐 Iterator, Delegate와 반복 순회 비용은 존재할 수 있다. Query를 여러 번 열거하면 원본 작업도 반복된다.

### LINQ를 반복문으로 바꾸면 무조건 최적화된다

알고리즘과 호출 횟수가 같다면 개선이 작을 수 있다. `OrderBy().First()`를 단일 최솟값 검색으로 바꾸는 것처럼 불필요한 작업 자체를 제거해야 효과가 크다.

### ToList는 항상 나쁘다

할당은 발생하지만 Snapshot이 필요하거나 Query 결과를 여러 번 사용할 때 중복 실행을 막을 수 있다. 수명과 목적이 명확하면 올바른 선택이다.

### 문자열 Interning으로 반복 UI 할당을 해결할 수 있다

동적 문자열을 Intern Pool에 넣으면 오래 유지되는 문자열이 계속 늘 수 있다. 값이 변경될 때만 UI를 갱신하는 구조가 먼저다.

---

## 마무리

String은 Immutable이므로 내용이 달라질 때 새 결과 객체가 필요하다. LINQ는 Query Pipeline을 구성하고 결과가 필요할 때 원본을 순회한다.

두 기능 모두 잘못된 것이 아니라 실행 위치와 빈도가 문제를 만든다.

```text
얼마나 자주 실행되는가?
↓
결과 String이나 Collection이 꼭 필요한가?
↓
Query를 몇 번 열거하는가?
↓
정렬과 전체 저장이 필요한가?
↓
갱신 횟수나 알고리즘을 줄일 수 있는가?
↓
대상 플랫폼에서 다시 측정
```

UI 문자열은 Builder보다 갱신 시점을 먼저 줄이고, LINQ는 문법보다 Query가 수행하는 정렬과 Materialization을 먼저 확인한다.

Loading과 초기화 코드에서는 가독성 높은 LINQ가 적합할 수 있다. 반복되는 Gameplay Hot Path에서는 재사용 Buffer와 직접 순회가 더 예측 가능한 비용을 제공한다.

---

## 핵심 정리

- String은 Immutable이므로 연결과 보간 결과를 담을 새 문자열이 필요하다.
- `StringBuilder`는 중간 문자열을 줄이지만 `ToString()`의 최종 문자열까지 없애지는 않는다.
- 문자열 최적화에서는 조합 방식보다 불필요한 갱신 횟수를 먼저 줄인다.
- `Where()`와 `Select()` 같은 LINQ 연산은 주로 Deferred Execution으로 Query를 구성한다.
- `ToList()`와 `ToArray()`는 Query 전체를 실행하고 새 결과 Collection을 만든다.
- `OrderBy()`와 `GroupBy()`는 전체 데이터를 보관하고 처리해야 하므로 단순 필터보다 비용이 크다.
- Deferred Query를 여러 번 열거하면 원본 순회와 조건 평가도 반복될 수 있다.
- Lambda가 바깥 변수를 캡처하면 Closure 할당과 참조 수명 연장이 생길 수 있다.
- 반복문 전환보다 불필요한 정렬, Materialization과 호출 자체를 제거할 때 효과가 크다.
- Loading과 Hot Path에 같은 기준을 적용하지 않고 실제 Player의 호출 빈도와 할당량으로 판단한다.
