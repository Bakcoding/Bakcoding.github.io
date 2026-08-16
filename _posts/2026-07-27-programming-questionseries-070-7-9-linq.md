---
title: "[궁금시리즈] 7-9. LINQ는 정말 느릴까? 성능과 사용 시 주의할 점"
excerpt: "C#"
categories:
  - CSharp
series: question-series
tags:
  - CSharp
permalink: /programming/7-9-linq/
toc: true
toc_sticky: true
date: 2026-07-27 20:34:06 +0900
last_modified_at: 2026-07-27
---

## 들어가며

다음 두 코드를 보자.

```cs
foreach (Player player in players)
{
    if (player.Level >= 10)
    {
        Console.WriteLine(player.Name);
    }
}
```

그리고

```cs
foreach (Player player in players.Where(player => player.Level >= 10))
{
    Console.WriteLine(player.Name);
}
```

둘 다 같은 결과를 출력한다.

그렇다면 성능도 같을까?

정답은 완전히 같지는 않다.

하지만 그 차이가 항상 문제가 되는 것은 아니다.

---

## LINQ가 비용이 발생하는 이유

LINQ는 편리한 만큼

추가 작업도 수행한다.

예를 들어

```cs
players.Where(player => player.Level >= 10);
```

에서는

다음 과정이 발생한다.

```
Where Iterator 생성

↓

Lambda Delegate 생성

↓

IEnumerable 반환

↓

Enumerator 생성

↓

MoveNext() 반복
```

반면

평범한 foreach는

```
Enumerator 생성

↓

MoveNext() 반복
```

정도로 끝난다.

즉,

LINQ는

중간 객체와 Delegate 호출이 추가된다.

---

## Delegate 호출 비용

다음 코드를 보자.

```cs
players.Where(player => player.Level >= 10);
```

실제로는

```cs
predicate(player);
```

가

매 요소마다 호출된다.

즉,

100만 개를 검사한다면

100만 번

Delegate 호출이 발생한다.

---

## Iterator 객체도 생성된다

다음 코드를 보면

```cs
var result =
    players.Where(player => player.Level >= 10);
```

Where는

새로운 Iterator 객체를 만든다.

그리고

```cs
result.Select(...)
```

를 연결하면

또 하나의 Iterator가 만들어진다.

즉,

```
Where Iterator

↓

Select Iterator

↓

Take Iterator
```

처럼

연결된 객체가 생성된다.

물론

실제 순회는

한 번만 이루어진다.

---

## Where 여러 개는 느릴까?

다음 코드를 보자.

```cs
var result = players
    .Where(player => player.Level >= 10)
    .Where(player => player.HP > 100)
    .Where(player => player.IsAlive);
```

많은 사람들이

컬렉션을

세 번 순회한다고 생각한다.

하지만

실제로는

한 번만 순회한다.

다만

각 요소마다

조건은

순서대로 검사한다.

```
Player

↓

조건1

↓

조건2

↓

조건3
```

즉,

순회 횟수는

한 번이다.

---

## Where와 ToList()

다음 코드를 보자.

```cs
players
    .Where(player => player.Level >= 10)
    .ToList();
```

ToList를 호출하면

새로운 List가 생성된다.

즉,

```
기존 List

↓

새 List 생성

↓

모든 요소 복사
```

가 발생한다.

메모리 사용량도 증가한다.

---

## OrderBy는 비용이 크다

앞에서도 살펴봤듯

```cs
players.OrderBy(player => player.Level);
```

는

전체 데이터를

모두 읽는다.

그리고

메모리에 저장한 뒤

정렬한다.

즉,

LINQ 중에서도

비용이 큰 연산이다.

---

## Count()를 여러 번 호출하면?

다음 코드를 보자.

```cs
query.Count();

query.Count();
```

`query`가 `IEnumerable<T>`라면

매번 처음부터

순회한다.

예를 들어

```cs
var query =
    players.Where(player => player.Level >= 10);
```

라면

```
첫 번째 Count

↓

전체 순회

↓

두 번째 Count

↓

다시 전체 순회
```

가 된다.

필요하다면

```cs
List<Player> list =
    query.ToList();
```

처럼

한 번 계산해 두는 것이 더 효율적일 수 있다.

---

## List<T>.Count와 Enumerable.Count()

예를 들어

```cs
list.Count
```

는 단순히 내부 필드 값을 읽기 때문에 O(1) 이다.

반면

```cs
query.Count()
```

는 IEnumerable<T>라면 전체를 순회할 수도 있어 O(n) 이 될 수 있다.

---

## Update()에서 LINQ를 사용할까?

Unity에서는 자주 나오는 질문이다.

```cs
void Update()
{
    var target =
        enemies
            .Where(enemy => enemy.IsAlive)
            .OrderBy(enemy => enemy.Distance)
            .FirstOrDefault();
}
```

매 프레임

LINQ가 실행된다.

60FPS라면

1초에

60번 실행된다.

컬렉션이 크다면

불필요한 메모리 할당과 CPU 사용량이 발생할 수 있다.

게임 루프처럼 매우 자주 호출되는 코드에서는 일반적인 반복문이 더 적합한 경우가 많다.

---

## 그럼 LINQ는 사용하면 안 될까?

그렇지 않다.

실제로 대부분의 비즈니스 로직에서는

LINQ의 성능보다

가독성 향상이 훨씬 큰 장점이 된다.

예를 들어

```cs
var names = players
    .Where(player => player.Level >= 10)
    .OrderBy(player => player.Name)
    .Select(player => player.Name);
```

는

중첩된 반복문보다

의도를 훨씬 쉽게 이해할 수 있다.

성능 차이가 미미한 곳이라면

LINQ를 사용하는 것이 유지보수에 도움이 된다.

---

## 언제 반복문을 사용하는 것이 좋을까?

다음과 같은 경우에는

반복문이 더 적합하다.

- Update(), FixedUpdate()처럼 매 프레임 실행되는 코드
- 수십만~수백만 개의 데이터를 반복 처리하는 경우
- 불필요한 메모리 할당을 줄여야 하는 경우
- 최대 성능이 필요한 핵심 알고리즘

이러한 상황에서는 LINQ보다 직접 반복문을 작성하는 것이 더 효율적일 수 있다.

---

## 실제 .NET에서는 어떻게 사용할까?

.NET 라이브러리와 ASP.NET 애플리케이션에서는 LINQ를 매우 적극적으로 사용한다.

데이터 조회, 컬렉션 변환, 그룹화, 정렬과 같은 일반적인 작업에서는 생산성과 가독성이 성능 차이보다 더 큰 이점을 제공하기 때문이다.

반면 게임 엔진이나 실시간 시스템처럼 짧은 시간 안에 동일한 작업을 매우 많이 반복하는 환경에서는 LINQ 사용을 신중하게 판단하는 경우가 많다.

특히 Unity에서는 `Update()`와 같이 프레임마다 호출되는 메서드에서 LINQ 사용을 지양하는 사례를 자주 볼 수 있다.

---

## 실무에서 자주 하는 오해

가장 흔한 오해는

> **LINQ는 무조건 느리다.**

라는 것이다.

LINQ는 반복문보다 약간의 오버헤드가 있지만, 대부분의 일반적인 애플리케이션에서는 그 차이가 문제가 되지 않는다.

또 하나의 오해는

> **성능 때문에 모든 LINQ를 반복문으로 바꿔야 한다.**

라는 것이다.

실제로는 병목 지점이 확인되기 전까지는 가독성이 높은 LINQ를 사용하는 것이 유지보수 측면에서 더 유리한 경우가 많다.

성능 최적화는 측정 결과를 바탕으로 필요한 부분에 적용하는 것이 바람직하다.

---

## 마무리

LINQ는 반복문보다 약간의 오버헤드가 있지만, 대부분의 일반적인 애플리케이션에서는 충분히 효율적인 성능을 제공한다.

다만 `OrderBy()`처럼 전체 데이터를 정렬해야 하는 연산이나 `ToList()`처럼 새로운 컬렉션을 생성하는 연산은 비용이 큰 편이며, `Update()`처럼 매우 자주 호출되는 코드에서는 LINQ 사용을 신중하게 판단해야 한다.

중요한 것은 **LINQ**를 무조건 피하는 것이 아니라, 비용이 발생하는 원리를 이해하고 적절한 상황에서 사용하는 것이다.

---

## 핵심 정리

- LINQ는 Delegate 호출과 Iterator 객체 생성 등의 오버헤드가 있다.
- `Where()`를 여러 번 연결해도 순회는 한 번만 수행된다.
- `ToList()`는 새로운 컬렉션을 생성하므로 메모리 할당이 발생한다.
- `OrderBy()`는 모든 데이터를 메모리에 수집한 뒤 정렬하므로 비용이 큰 연산이다.
- 동일한 `IEnumerable<T>`에 대해 `Count()` 등을 반복 호출하면 매번 다시 순회한다.
- Unity의 `Update()`처럼 자주 호출되는 코드에서는 LINQ 사용을 신중하게 판단하는 것이 좋다.
- 일반적인 애플리케이션에서는 LINQ의 가독성과 생산성이 작은 성능 오버헤드보다 더 큰 장점이 되는 경우가 많다.
