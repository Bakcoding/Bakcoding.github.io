---
title: "7-6. Where(), Any(), All(), Contains()"
excerpt: "C#"
categories:
  - Programming
tags:
  - CSharp
permalink: /programming/7-6-where-any-all-contains/
toc: true
toc_sticky: true
date: 2026-07-27
last_modified_at: 2026-07-27
---

LINQ에는 조건을 검사하는 메서드가 여러 개 있다.

예를 들어 다음과 같은 코드를 자주 볼 수 있다.

```cs
players.Where(player => player.Level >= 10);

players.Any(player => player.Level >= 10);

players.All(player => player.Level >= 10);

players.Contains(targetPlayer);
```

모두 조건을 사용하는 것처럼 보이지만 실제 역할은 전혀 다르다.

- **Where()** : 조건에 맞는 모든 데이터를 반환한다.
- **Any()** : 조건을 만족하는 데이터가 하나라도 있는지 확인한다.
- **All()** : 모든 데이터가 조건을 만족하는지 확인한다.
- **Contains()** : 특정 값이 존재하는지 확인한다.

이번 글에서는 각각 언제 사용하는 것이 적절한지와 내부적으로 어떻게 동작하는지 알아보자.

---

## Where()

가장 많이 사용하는 메서드이다.

```cs
var result =
    players.Where(player => player.Level >= 10);
```

결과는

```
Player

Player

Player
```

처럼

조건을 만족하는 모든 데이터를 반환한다.

반환형은

```
IEnumerable<Player>
```

이다.

즉,

Where는

> 필터링(Filter) 을 수행한다.

---

## Any()

이번에는

조건을 만족하는 데이터가 존재하는지만 알고 싶다.

```cs
bool exists =
    players.Any(player => player.Level >= 10);
```

결과는

```
true

또는

false
```

이다.

반환형은

```
bool
```

이다.

데이터를 반환하지 않는다.

---

## Any()는 끝까지 검사할까?

아니다.

```cs
players.Any(player => player.Level >= 10);
```

에서

첫 번째 조건을 만족하는 플레이어를 찾으면

즉시 종료한다.

예를 들어

```
Player1

↓

조건 만족

↓

종료
```

가 된다.

즉,

최악의 경우에는 전체를 검사하지만,

대부분의 경우

조기에 종료할 수 있다.

---

## All()

이번에는

모든 플레이어가

조건을 만족하는지 알고 싶다.

```cs
bool result =
    players.All(player => player.Level >= 10);
```

모든 플레이어가

레벨 10 이상이라면

```
true
```

하나라도 아니라면

```
false
```

가 된다.

---

## All()도 조기 종료한다

다음과 같은 경우

```
Player1

↓

조건 만족

↓

Player2

↓

조건 실패

↓

종료
```

즉,

실패하는 순간

더 이상 검사하지 않는다.

---

## Contains()

Contains는

조건을 검사하는 것이 아니다.

특정 값이 존재하는지를 검사한다.

```cs
bool exists =
    players.Contains(targetPlayer);
```

또는

```cs
bool exists =
    numbers.Contains(10);
```

처럼 사용한다.

---

## Contains는 어떻게 비교할까?

값 형식이라면

```cs
numbers.Contains(10);
```

은

값을 비교한다.

참조 형식은

기본적으로

`Equals()`를 사용한다.

즉,

직접 `Equals()`와 `GetHashCode()`를 구현하거나

`IEquatable<T>`를 구현하면

Contains의 동작도 달라질 수 있다.

---

## Where().Any()는 Any()와 같을까?

다음 코드를 보자.

```cs
players
    .Where(player => player.Level >= 10)
    .Any();
```

이 코드는 동작은 한다.

하지만

굳이 Where가 필요 없다.

다음처럼 작성하면 된다.

```cs
players.Any(player => player.Level >= 10);
```

이쪽이

더 간결하고

불필요한 Iterator도 만들지 않는다.

---

## Where().Count()는 어떨까?

다음 코드도 자주 볼 수 있다.

```cs
players
    .Where(player => player.Level >= 10)
    .Count() > 0;
```

이 역시

```cs
players.Any(player => player.Level >= 10);
```

으로 바꾸는 것이 좋다.

왜냐하면

Count는

조건을 만족하는 개수를 알아야 하므로

끝까지 순회한다.

반면

Any는

첫 번째 조건을 만족하는 순간

종료한다.

---

## All()과 !Any()의 관계

다음 두 코드를 보자.

```cs
players.All(player => player.Level >= 10);
```

그리고

```cs
!players.Any(player => player.Level < 10);
```

두 코드는

결과가 같다.

하지만

첫 번째가

의도를 훨씬 명확하게 표현한다.

즉,

All을 사용할 수 있는 상황이라면

굳이 Any를 뒤집지 않는 것이 좋다.

---

## Contains() 대신 Any()를 사용할 수도 있다

예를 들어

ID를 비교하고 싶다면

```cs
players.Any(player => player.Id == targetId);
```

처럼 사용할 수 있다.

반면

객체 자체가 존재하는지만 확인한다면

players.Contains(targetPlayer);

가 더 적절하다.

즉,

Contains는 동등성(Equality) 을 검사하고,

Any는 조건(Predicate) 을 검사한다.

---

## 실제 .NET에서는 어떻게 사용할까?

.NET 라이브러리에서는 목적에 맞는 메서드를 사용하는 것이 일반적이다.

예를 들어

```cs
if (orders.Any())
```

처럼 데이터가 존재하는지만 확인하고,

```cs
if (users.All(user => user.IsActive))
```

처럼 전체 조건을 검사하며,

```cs
var adults = people.Where(person => person.Age >= 20);
```

처럼 필터링이 필요할 때는 `Where()`를 사용한다.

즉, 반환값이 필요한 데이터인지, 단순한 참/거짓인지에 따라 메서드를 선택하는 것이 좋다.

---

## 실무에서 자주 하는 오해

가장 흔한 오해는

> **데이터가 있는지 확인할 때 Count()를 사용하는 것이다.**

예를 들어

```cs
if (players.Count() > 0)
```

처럼 작성하는 경우가 있다.

이 경우에는

```cs
if (players.Any())
```

가 더 적절하다.

`Any()`는 첫 번째 요소를 찾는 순간 종료할 수 있기 때문이다.

또 하나의 오해는

> **Contains()**와 **Any()**는 같은 기능이다.

라는 것이다.

`Contains()`는 특정 값이나 객체의 동등성을 검사하고,

`Any()`는 개발자가 지정한 조건을 검사한다.

목적이 다르므로 상황에 맞게 선택해야 한다.

---

## 마무리

`Where()`, `Any()`, `All()`, `Contains()`는 모두 데이터를 검사하는 LINQ 메서드이지만, 반환값과 목적은 서로 다르다.

`Where()`는 조건을 만족하는 데이터를 반환하고, `Any()`와 `All()`은 조건의 만족 여부를 `bool`로 반환한다. `Contains()`는 특정 값이나 객체가 컬렉션에 존재하는지를 확인하는 메서드이다.

필요한 결과가 컬렉션인지, 단순한 참/거짓인지에 따라 적절한 메서드를 선택하면 코드의 의도를 더욱 명확하게 표현할 수 있으며, 불필요한 순회를 줄여 성능도 개선할 수 있다.

다음 글에서는 **OrderBy()는 내부적으로 어떻게 정렬할까?**를 살펴보며 `OrderBy()`, `OrderByDescending()`, `ThenBy()`의 동작 방식과 안정 정렬(Stable Sort)에 대해 알아보겠다.

---

## 핵심 정리

- `Where()`는 조건을 만족하는 모든 데이터를 반환한다.
- `Any()`는 조건을 만족하는 데이터가 하나라도 있는지 확인한다.
- `All()`은 모든 데이터가 조건을 만족하는지 확인한다.
- `Contains()`는 특정 값이나 객체가 존재하는지 확인한다.
- `Any()`와 `All()`은 조건이 결정되는 순간 순회를 종료할 수 있다.
- 존재 여부만 확인할 때는 `Count() > 0`보다 `Any()`를 사용하는 것이 일반적으로 더 효율적이다.
- `Contains()`는 동등성을 검사하고, `Any()`는 조건을 검사한다.
