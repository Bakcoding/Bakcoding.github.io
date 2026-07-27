---
title: "7-1. LINQ는 왜 등장했을까?"
excerpt: "C#"
categories:
  - Programming
tags:
  - CSharp
permalink: /programming/7-1-linq/
toc: true
toc_sticky: true
date: 2026-07-27
last_modified_at: 2026-07-27
---

프로그램을 개발하다 보면 컬렉션에서 원하는 데이터를 찾거나, 조건에 맞는 데이터만 추출하거나, 정렬하는 작업을 매우 자주 수행하게 된다.

예를 들어 플레이어 목록에서 레벨이 10 이상인 플레이어를 찾거나, 아이템 목록을 가격순으로 정렬하거나, 특정 조건을 만족하는 데이터의 개수를 구하는 작업은 거의 모든 프로젝트에서 반복적으로 등장한다.

오늘날에는 LINQ를 사용하면 이러한 작업을 간결하게 작성할 수 있다.

```cs
List<Player> highLevelPlayers = players
    .Where(player => player.Level >= 10)
    .OrderBy(player => player.Name)
    .ToList();
```

하지만 LINQ가 등장하기 전에는 이런 작업을 어떻게 처리했을까?

이번 글에서는 LINQ가 등장하게 된 배경과 해결하려 했던 문제를 알아본다.

---

## LINQ 이전에는 어떻게 데이터를 다뤘을까?

LINQ가 없던 시절에는 대부분 반복문을 직접 작성했다.

```cs
List<Player> result = new();

foreach (Player player in players)
{
    if (player.Level >= 10)
    {
        result.Add(player);
    }
}
```

코드 자체는 어렵지 않다.

하지만 프로젝트가 커질수록 같은 패턴이 계속 반복된다.

- 조건에 맞는 데이터 찾기
- 정렬하기
- 특정 데이터 선택하기
- 개수 구하기
- 그룹으로 묶기

이러한 코드가 프로젝트 곳곳에 흩어지게 된다.

---

## 반복되는 코드의 문제

예를 들어 이번에는 레벨뿐 아니라 직업까지 검사해야 한다.

```cs
List<Player> result = new();

foreach (Player player in players)
{
    if (player.Level >= 10 &&
        player.Job == Job.Warrior)
    {
        result.Add(player);
    }
}
```

다음에는 이름순으로 정렬해야 한다.

```cs
result.Sort((left, right) =>
    left.Name.CompareTo(right.Name));

그다음에는 상위 10명만 가져온다.

List<Player> top10 = new();

for (int i = 0; i < 10; i++)
{
    top10.Add(result[i]);
}
```

데이터를 처리하는 로직보다 반복문을 작성하는 코드가 더 많아지기 시작한다.

---

## SQL는 이미 해결하고 있었다

흥미로운 점은 데이터베이스에서는 이미 오래전부터 비슷한 문제를 해결하고 있었다.

예를 들어 SQL에서는 다음과 같이 작성한다.

```cs
SELECT *
FROM Player
WHERE Level >= 10
ORDER BY Name;
```

코드를 보면

- 무엇을 가져올지
- 어떤 조건인지
- 어떤 기준으로 정렬할지

가 매우 직관적으로 보인다.

반면 C#에서는 같은 작업을 수행하기 위해 반복문과 조건문을 직접 작성해야 했다.

.NET 개발팀은 이러한 데이터 처리 방식을 C#에서도 사용할 수 없을지 고민하게 되었다.

---

## 그래서 등장한 것이 LINQ이다

LINQ(Language Integrated Query)는 말 그대로 **언어(Language)**에 **통합된(Integrated)** **질의(Query)** 기능이다.

즉, SQL처럼 데이터를 조회하는 문법을 C# 안으로 가져온 것이다.

앞에서 작성했던 코드는 다음처럼 바뀐다.

```cs
List<Player> result = players
    .Where(player => player.Level >= 10)
    .OrderBy(player => player.Name)
    .ToList();
```

반복문이 사라졌다.

하지만 중요한 것은 반복문이 없어졌다는 것이 아니다.

반복문을 컴파일러와 라이브러리가 대신 작성해 주는 것이다.

---

## LINQ는 SQL가 아니다

LINQ를 처음 배우면 SQL와 비슷해 보인다.

하지만 둘은 완전히 다른 기술이다.

SQL는 데이터베이스를 조회하는 언어이다.

반면 LINQ는

- List<T>
- Array
- Dictionary
- XML
- Database
- 다양한 컬렉션

등 여러 데이터를 동일한 방식으로 다룰 수 있도록 만든 C# 기능이다.

즉,

SQL를 흉내 낸 것이 아니라

데이터를 조회하는 방식을 C# 언어 안으로 통합한 것이다.

---

## 왜 "Language Integrated"일까?

LINQ의 이름에는 중요한 의미가 담겨 있다.

이전에는 데이터를 조회하는 기능이 라이브러리 수준에 머물렀다.

하지만 LINQ는 언어 자체가 질의를 지원한다.

예를 들어

```cs
players.Where(player => player.Level >= 10)
```

에서 사용되는

- 람다식
- 제네릭
- Extension Method
- Delegate

모두 C# 언어 기능이다.

즉, LINQ는 하나의 기능이 아니라 여러 언어 기능이 결합되어 만들어진 결과물이다.

---

## LINQ는 어떻게 반복문 없이 동작할까?

많은 사람들이 LINQ에는 반복문이 없다고 생각한다.

하지만 실제로는 그렇지 않다.

```cs
players.Where(player => player.Level >= 10);
```

내부에서는 결국 모든 요소를 하나씩 확인한다.

```
즉,

컬렉션

↓

반복

↓

조건 검사

↓

결과 반환
```

이라는 과정은 그대로 존재한다.

단지 개발자가 직접 반복문을 작성하지 않을 뿐이다.

---

## LINQ는 데이터를 복사하는 것일까?

다음 코드를 보면

```cs
IEnumerable<Player> result =
    players.Where(player => player.Level >= 10);
```

새로운 컬렉션이 만들어졌다고 생각하기 쉽다.

하지만 대부분의 LINQ 메서드는 즉시 데이터를 복사하지 않는다.

실제로는

> "나중에 조건을 적용해서 데이터를 가져오는 방법"

만 만들어 둔다.

이러한 동작을 **지연 실행(Deferred Execution)** 이라고 한다.

이 개념은 다음 글에서 자세히 다룬다.

---

## 실제 .NET에서는 어떻게 사용할까?

LINQ는 .NET 라이브러리 전반에서 사용된다.

대표적인 예는 다음과 같다.

```cs
users.Where(user => user.IsActive);

orders.OrderBy(order => order.Date);

items.Select(item => item.Name);

numbers.Sum();

players.First();
```

게임 개발에서도 자주 사용된다.

```cs
Enemy target = enemies
    .Where(enemy => enemy.IsAlive)
    .OrderBy(enemy => enemy.Distance)
    .FirstOrDefault();
```

다만 Unity에서는 `Update()`처럼 매 프레임 실행되는 코드에서 LINQ를 남용하면 불필요한 메모리 할당과 성능 저하가 발생할 수 있다. 따라서 사용 위치를 고려하는 것이 중요하다.

---

## 실무에서 자주 하는 오해

가장 흔한 오해는

> LINQ는 반복문을 사용하지 않는다.

라는 것이다.

실제로는 내부에서 반복문을 수행한다.

다만 반복문을 직접 작성하지 않을 뿐이다.

또 하나의 오해는

> LINQ는 항상 느리다.

라는 것이다.

일반적인 비즈니스 로직에서는 LINQ의 성능 차이가 문제가 되는 경우는 드물다.

다만 게임의 메인 루프나 매우 큰 데이터를 반복 처리하는 코드에서는 추가적인 Delegate 호출이나 Enumerator 생성 비용이 영향을 줄 수 있다.

중요한 것은 **LINQ가 느린가가 아니라, 어디에서 사용하는가**이다.

---

## 마무리

LINQ는 반복문을 없애기 위해 등장한 기능이 아니라, 데이터를 다루는 코드를 더 읽기 쉽고 일관성 있게 작성하기 위해 등장한 기능이다.

SQL의 질의 방식을 C# 언어에 통합하여 다양한 데이터 소스를 동일한 방식으로 다룰 수 있도록 만들었으며, 내부적으로는 Delegate, 람다식, 제네릭, Extension Method 등 지금까지 살펴본 여러 C# 기능을 활용해 동작한다.

다음 글에서는 **LINQ는 내부적으로 어떻게 동작할까?**를 살펴보며 `Where()` 하나가 실제로 어떤 객체를 만들고, 왜 반복문 없이 동작하는 것처럼 보이는지, 그리고 `IEnumerable<T>`와 어떤 관계를 가지는지 알아보겠다.

---

## 핵심 정리

- LINQ는 데이터를 더 읽기 쉽고 일관성 있게 처리하기 위해 등장했다.
- LINQ 이전에는 반복문과 조건문을 직접 작성하는 경우가 많았다.
- LINQ는 SQL와 비슷한 형태를 제공하지만 SQL 자체는 아니다.
- LINQ는 람다식, Delegate, 제네릭, Extension Method 등 여러 C# 기능을 활용한다.
- LINQ도 내부적으로는 결국 컬렉션을 순회한다.
- 대부분의 LINQ 메서드는 즉시 실행되지 않고 지연 실행을 사용한다.
- Unity에서는 매 프레임 실행되는 코드에서 LINQ를 남용하지 않는 것이 좋다.
