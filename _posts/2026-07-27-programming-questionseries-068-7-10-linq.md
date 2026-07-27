---
title: "7-10. LINQ를 사용할 때 자주 하는 실수 총정리"
excerpt: "C#"
categories:
  - Programming
tags:
  - CSharp
permalink: /programming/7-10-linq/
toc: true
toc_sticky: true
date: 2026-07-27
last_modified_at: 2026-07-27
---

LINQ는 C#에서 가장 생산성이 높은 기능 중 하나이다.

하지만 편리한 만큼 내부 동작을 이해하지 못하면 예상하지 못한 성능 문제나 버그가 발생하기 쉽다.

이번 글에서는 실무에서 자주 볼 수 있는 LINQ 사용 실수와 그 이유를 함께 정리해 보자.

---

## 1. Count() 대신 Any()를 사용해야 하는 상황

다음 코드를 보자.

```cs
if (players.Count() > 0)
{

}
```

데이터가 존재하는지만 확인하려는 코드이다.

이 경우에는

```cs
if (players.Any())
{

}
```

가 더 적절하다.

`Count()`는 요소의 개수를 알아야 하므로 전체를 순회할 수 있지만,

`Any()`는 첫 번째 요소를 발견하는 순간 바로 종료한다.

> 단, `List<T>`나 배열처럼 `Count` 속성을 가진 컬렉션에서는 `list.Count`가 O(1) 이므로 문제가 되지 않는다.

예를 들어

```cs
if (list.Count > 0)
```

는 매우 빠르다.

반면

```cs
if (query.Count() > 0)
```

에서 `query`가 `IEnumerable<T>`라면 전체 순회가 발생할 수 있다.

---

## 2. Where().Any()를 사용하는 경우

다음 코드도 자주 볼 수 있다.

```cs
players
    .Where(player => player.Level >= 10)
    .Any();
```

동작에는 문제가 없다.

하지만

```cs
players.Any(player => player.Level >= 10);
```

가 더 간결하다.

불필요한 `Where` Iterator도 생성하지 않는다.

---

## 3. Where().Count() > 0

다음 코드도 흔하다.

```cs
players
    .Where(player => player.Level >= 10)
    .Count() > 0;
```

이 역시

```cs
players.Any(player => player.Level >= 10);
```

로 작성하는 것이 좋다.

`Count()`는 끝까지 검사하지만,

`Any()`는 첫 번째 조건을 만족하면 종료한다.

---

## 4. 지연 실행을 잊는 경우

다음 코드를 보자.

```cs
var query =
    players.Where(player => player.Level >= 10);

players.Add(new Player("Alice", 20));

foreach (var player in query)
{
    Console.WriteLine(player.Name);
}
```

많은 사람들이

"Alice가 출력되지 않을 것이다."

라고 생각한다.

하지만 실제로는 출력된다.

`Where()`는 지연 실행이므로

순회하는 시점의 컬렉션을 읽기 때문이다.

현재 상태를 유지하고 싶다면

```cs
var list =
    players
        .Where(player => player.Level >= 10)
        .ToList();
```

처럼 즉시 실행해야 한다.

---

## 5. IEnumerable를 여러 번 순회하는 경우

다음 코드를 보자.

```cs
var query =
    players.Where(player => player.Level >= 10);

Console.WriteLine(query.Count());

Console.WriteLine(query.Last());
```

많은 사람들이

한 번만 계산될 것이라 생각한다.

하지만

실제로는

```
Count()

↓

전체 순회

↓

Last()

↓

다시 전체 순회
```

가 된다.

여러 번 사용할 예정이라면

```cs
var list =
    query.ToList();
```

로 한 번 계산하는 것이 좋다.

---

## 6. OrderBy()가 부분적으로 실행된다고 생각하는 경우

다음 코드를 보자.

```cs
players.OrderBy(player => player.Level);
```

`Where()`처럼 하나씩 처리될 것이라고 생각하기 쉽다.

하지만

정렬은

모든 데이터를

먼저 읽어야 한다.

즉,

```
전체 수집

↓

정렬

↓

반환
```

이 수행된다.

정렬은 LINQ에서 가장 비용이 큰 연산 중 하나이다.

---

## 7. Update()에서 LINQ를 사용하는 경우

Unity에서는

다음 코드를 자주 볼 수 있다.

```cs
void Update()
{
    var target = enemies
        .Where(enemy => enemy.IsAlive)
        .OrderBy(enemy => enemy.Distance)
        .FirstOrDefault();
}
```

매 프레임

Iterator 생성,

Delegate 호출,

정렬이 반복된다.

소규모 프로젝트에서는 문제가 없을 수도 있지만,

대량의 객체를 처리하는 경우에는 성능에 영향을 줄 수 있다.

게임 루프에서는 일반적인 반복문이 더 적합한 경우가 많다.

---

## 8. OrderBy()를 여러 번 호출하는 경우

다음 코드를 보자.

```cs
players
    .OrderBy(player => player.Level)
    .OrderBy(player => player.Name);
```

많은 사람들이

Level,

그 다음 Name으로

정렬된다고 생각한다.

하지만

두 번째 `OrderBy()`가

첫 번째 정렬 기준을 덮어쓴다.

올바른 코드는

```cs
players
    .OrderBy(player => player.Level)
    .ThenBy(player => player.Name);
```

이다.

---

## 9. Select()와 SelectMany()를 혼동하는 경우

다음 코드를 보자.

```cs
teams.Select(team => team.Players);
```

반환형은

```
IEnumerable<List<Player>>
```

이다.

많은 사람들이

```
Player

Player

Player
```

가 나올 것이라 생각한다.

모든 플레이어를 하나의 컬렉션으로 가져오려면

```cs
teams.SelectMany(team => team.Players);
```

를 사용해야 한다.

---

## 10. ToList()를 습관처럼 사용하는 경우

다음 코드를 보자.

```cs
players
    .Where(player => player.Level >= 10)
    .ToList();
```

필요하지 않은데도

항상 `ToList()`를 붙이는 경우가 있다.

`ToList()`는

- 전체 순회
- 새로운 List 생성
- 메모리 할당

이 발생한다.

결과를 한 번만 사용할 예정이라면

굳이 `ToList()`를 사용할 필요가 없다.

---

## 11. LINQ가 항상 느리다고 생각하는 경우

가장 흔한 오해이다.

일반적인 업무 프로그램에서는

LINQ의 성능 차이보다

가독성이 훨씬 큰 장점이 된다.

반대로

다음과 같은 환경에서는

신중하게 사용하는 것이 좋다.

- 게임 루프
- 실시간 물리 계산
- 대용량 데이터 처리
- 매우 빈번한 반복 작업

성능 최적화는 측정 결과를 바탕으로 필요한 부분에만 적용하는 것이 바람직하다.

---

## 실제 .NET에서는 어떻게 사용할까?

.NET 라이브러리와 ASP.NET, Entity Framework 등에서는 LINQ를 매우 적극적으로 활용한다.

반면 성능이 매우 중요한 코드에서는 반복문이나 특화된 자료구조를 선택하는 경우도 있다.

중요한 것은 **LINQ**를 피하는 것이 아니라, 내부 동작을 이해한 뒤 상황에 맞게 사용하는 것이다.

---

## 마무리

LINQ는 C#에서 가장 강력한 기능 중 하나이며, 적절하게 사용하면 코드의 가독성과 유지보수성을 크게 향상시킨다.

하지만 지연 실행, 즉시 실행, Enumerator, 메모리 할당, 정렬 비용과 같은 내부 동작을 이해하지 못하면 예상하지 못한 성능 문제나 버그를 만들 수 있다.

결국 좋은 LINQ 코드는 메서드를 많이 사용하는 코드가 아니라, **각 메서드가 언제 실행되고 어떤 비용이 발생하는지 이해하고 사용하는 코드**이다.

---

## 핵심 정리

- 데이터 존재 여부는 `Count()`보다 `Any()`가 적합한 경우가 많다.
- `Where().Any()`보다 `Any(predicate)`가 더 간결하다.
- `Where().Count() > 0` 대신 `Any()`를 사용할 수 있다.
- `IEnumerable<T>`는 지연 실행되므로 순회 시점의 데이터를 사용한다.
- 같은 `IEnumerable<T>`를 여러 번 순회하면 매번 다시 실행된다.
- `OrderBy()`는 전체 데이터를 메모리에 수집한 뒤 정렬한다.
- 여러 기준으로 정렬할 때는 `ThenBy()`를 사용한다.
- `SelectMany()`는 중첩된 컬렉션을 하나로 펼치는 메서드이다.
- 불필요한 `ToList()`는 메모리 할당을 증가시킨다.
- LINQ는 무조건 느린 것이 아니라, 사용 환경에 따라 적절하게 선택하는 것이 중요하다.
