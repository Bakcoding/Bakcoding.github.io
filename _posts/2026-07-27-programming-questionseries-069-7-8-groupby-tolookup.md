---
title: "[궁금시리즈] 7-8. GroupBy()와 ToLookup()은 무엇이 다를까?"
excerpt: "C#"
categories:
  - CSharp
series: question-series
tags:
  - CSharp
permalink: /programming/7-8-groupby-tolookup/
toc: true
toc_sticky: true
date: 2026-07-27 20:34:05 +0900
last_modified_at: 2026-07-27
---

## 들어가며

학생을 반별로 묶거나, 주문을 고객별로 묶거나, 플레이어를 직업별로 분류하는 작업은 매우 자주 발생한다.

LINQ에서는 이러한 작업을 위해 `GroupBy()`와 `ToLookup()`을 제공한다.

예를 들어 다음과 같은 플레이어 목록이 있다고 가정하자.

```cs
List<Player> players =
[
    new("Alice", "Warrior"),
    new("Bob", "Mage"),
    new("Charlie", "Warrior"),
    new("David", "Archer")
];
```

직업별로 그룹을 만들고 싶다면 다음과 같이 작성할 수 있다.

```cs
var groups = players.GroupBy(player => player.Job);
```

또는

```cs
var lookup = players.ToLookup(player => player.Job);
```

두 코드 모두 비슷한 결과를 얻지만 내부 동작은 다르다.

---

## GroupBy()는 무엇일까?

`GroupBy()`는 지정한 Key를 기준으로 데이터를 그룹으로 묶는다.

```cs
var groups =
    players.GroupBy(player => player.Job);
```

결과의 타입은

```cs
IEnumerable<IGrouping<string, Player>>
```

이다.

조금 복잡해 보이지만,

각 그룹은

```
Key

+

해당 그룹에 속한 요소들
```

을 가지고 있는 객체라고 생각하면 된다.

---

## IGrouping은 무엇일까?

`GroupBy()`의 결과는 `IGrouping<TKey, TElement>`이다.

간단히 보면 다음과 같은 형태이다.

```cs
public interface IGrouping<out TKey, out TElement>
    : IEnumerable<TElement>
{
    TKey Key { get; }
}
```

즉,

하나의 그룹은

- 그룹의 Key
- 그룹에 속한 데이터들

을 함께 가지고 있다.

예를 들어

```
Key = Warrior

↓

Alice

Charlie
```

처럼 구성된다.

---

## GroupBy()를 순회해 보기

```cs
foreach (var group in groups)
{
    Console.WriteLine(group.Key);

    foreach (var player in group)
    {
        Console.WriteLine(player.Name);
    }
}
```

출력 결과

```
Warrior
Alice
Charlie

Mage
Bob

Archer
David
```

그룹 하나도 `IEnumerable<T>`이므로 다시 `foreach`로 순회할 수 있다.

---

## ToLookup()은 무엇일까?

이번에는

```cs
var lookup =
    players.ToLookup(player => player.Job);
```

를 보자.

반환형은

```cs
ILookup<string, Player>
```

이다.

Lookup 역시 그룹을 저장하지만

사용 방식이 조금 다르다.

---

## Lookup은 Dictionary처럼 사용할 수 있다

가장 큰 특징은

Key로 바로 접근할 수 있다는 점이다.

```cs
foreach (var player in lookup["Warrior"])
{
    Console.WriteLine(player.Name);
}
```

결과

```
Alice

Charlie
```

Dictionary처럼

```
Key

↓

그룹
```

으로 접근할 수 있다.

---

## 없는 Key를 조회하면?

Dictionary는

```cs
dictionary["Knight"];
```

를 호출하면

예외가 발생한다.

하지만

Lookup은 다르다.

```cs
foreach (var player in lookup["Knight"])
{

}
```

예외가 발생하지 않는다.

단순히

비어 있는 컬렉션을 반환한다.

이 점은 실무에서도 상당히 편리하다.

---

## GroupBy()와 ToLookup()의 가장 큰 차이

가장 중요한 차이는 실행 시점이다.

`GroupBy()`

```cs
var groups =
    players.GroupBy(player => player.Job);
```

는

지연 실행이다.

실제로 그룹을 만드는 작업은

순회를 시작하는 순간 수행된다.

반면

```cs
var lookup =
    players.ToLookup(player => player.Job);
```

는

즉시 실행이다.

호출하는 순간

전체 컬렉션을 순회하여

Lookup을 생성한다.

---

## 여러 번 사용할 때는?

다음 코드를 보자.

```cs
var groups =
    players.GroupBy(player => player.Job);

groups.Count();

groups.First();

groups.Last();
```

매번 순회가 발생할 수 있다.

반면

```cs
var lookup =
    players.ToLookup(player => player.Job);
```

는

한 번만 그룹을 만든 뒤

계속 재사용한다.

즉,

같은 그룹을 여러 번 조회한다면

Lookup이 더 효율적일 수 있다.

---

## 내부적으로는 어떻게 구현될까?

개념적으로 `GroupBy()`는 다음과 같은 과정을 수행한다.

```cs
전체 순회

↓

Key 계산

↓

같은 Key끼리 묶기

↓

IGrouping 생성
```

`ToLookup()`도 비슷하지만

최종 결과를

Lookup 구조에 저장한다.

```
Dictionary

↓

Key

↓

Group
```

와 매우 유사한 형태이다.

---

## 언제 GroupBy()를 사용할까?

결과를 한 번 순회하고 끝난다면

```cs
players
    .GroupBy(player => player.Job)
    .Select(group => new
    {
        Job = group.Key,
        Count = group.Count()
    });
```

처럼 `GroupBy()`가 자연스럽다.

---

## 언제 ToLookup()을 사용할까?

반대로

같은 그룹을 여러 번 조회한다면

```cs
var lookup =
    players.ToLookup(player => player.Job);

lookup["Mage"];

lookup["Warrior"];

lookup["Archer"];
```

처럼

Lookup이 훨씬 편리하다.

---

## 실제 .NET에서는 어떻게 사용할까?

`GroupBy()`는 데이터를 분석하거나 통계를 계산할 때 자주 사용된다.

예를 들어

- 부서별 직원 수
- 직업별 플레이어 수
- 월별 주문 수

처럼 그룹을 만든 뒤 한 번 순회하며 결과를 계산하는 경우에 적합하다.

반면 `ToLookup()`은 여러 번 조회해야 하는 상황에 적합하다.

예를 들어 게임에서 직업별 플레이어 목록을 자주 가져오거나, 카테고리별 아이템을 반복해서 조회하는 경우에는 `ILookup<TKey, TValue>`가 Dictionary처럼 빠르게 접근할 수 있어 유용하다.

---

## 실무에서 자주 하는 오해

가장 흔한 오해는

> **GroupBy()**와 **ToLookup()**은 완전히 같은 기능이다.

라는 것이다.

두 메서드는 모두 데이터를 그룹화하지만,

`GroupBy()`는 지연 실행이고,

`ToLookup()`은 즉시 실행이라는 중요한 차이가 있다.

또 하나의 오해는

> **Lookup**은 **Dictionary**와 같다.

라는 것이다.

Lookup은 Key 하나에 여러 값을 저장하는 구조이며, 존재하지 않는 Key를 조회해도 예외를 발생시키지 않고 빈 컬렉션을 반환한다는 점에서 Dictionary와 다르다.

---

## 마무리

`GroupBy()`와 `ToLookup()`은 모두 데이터를 Key 기준으로 그룹화하는 LINQ 메서드이지만 사용 목적은 다르다.

`GroupBy()`는 지연 실행을 기반으로 그룹을 생성하며, 분석이나 집계처럼 한 번 순회하는 작업에 적합하다. 반면 `ToLookup()`은 즉시 실행으로 모든 그룹을 미리 생성하며, 동일한 그룹을 여러 번 조회하는 상황에서 더 효율적이다.

두 메서드의 차이를 이해하면 데이터 처리 방식에 맞는 컬렉션을 선택할 수 있고, 불필요한 반복 작업도 줄일 수 있다.

다음 글에서는 **LINQ는 정말 느릴까?**를 주제로 LINQ의 성능 특성과 반복문과의 차이, 그리고 언제 LINQ를 사용하는 것이 적절한지 알아보겠다.

---

## 핵심 정리

- `GroupBy()`는 데이터를 Key 기준으로 그룹화하는 지연 실행 메서드이다.
- `ToLookup()`은 그룹을 즉시 생성하는 즉시 실행 메서드이다.
- `GroupBy()`의 결과는 `IEnumerable<IGrouping<TKey, TElement>>`이다.
- `IGrouping<TKey, TElement>`는 Key와 해당 그룹의 요소를 함께 가진다.
- `ILookup<TKey, TValue>`는 Key를 이용해 그룹에 직접 접근할 수 있다.
- `ILookup<TKey, TValue>`는 존재하지 않는 Key를 조회해도 예외 대신 빈 컬렉션을 반환한다.
- 그룹을 반복해서 조회해야 한다면 `ToLookup()`이 적합하고, 한 번 순회하며 처리한다면 `GroupBy()`가 적합하다.
