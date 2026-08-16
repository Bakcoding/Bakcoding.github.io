---
title: "[궁금시리즈] 7-7. OrderBy()는 내부적으로 어떻게 정렬할까?"
excerpt: "C#"
categories:
  - CSharp
series: question-series
tags:
  - CSharp
permalink: /programming/7-7-orderby/
toc: true
toc_sticky: true
date: 2026-07-27 20:34:04 +0900
last_modified_at: 2026-07-27
---

## 들어가며

LINQ에서 데이터를 정렬할 때 가장 많이 사용하는 메서드는 `OrderBy()`이다.

```cs
var result = players.OrderBy(player => player.Level);
```

보기에는 단순히 레벨 순으로 정렬하는 것처럼 보인다.

하지만 내부에서는 단순히 하나씩 비교하며 정렬하는 것이 아니라, 모든 데이터를 수집한 뒤 Comparer를 이용하여 정렬을 수행한다.

이번 글에서는 `OrderBy()`가 내부적으로 어떻게 동작하는지와 `ThenBy()`가 왜 가능한지 확인한다.

---

## OrderBy()는 무엇을 할까?

`OrderBy()`는 컬렉션을 특정 기준으로 정렬한다.

예를 들어

```cs
List<Player> players =
[
    new Player("Charlie", 30),
    new Player("Alice", 10),
    new Player("Bob", 20)
];
```

다음과 같이 작성하면

```cs
var result =
    players.OrderBy(player => player.Level);
```

결과는

```
Alice

Bob

Charlie
```

가 된다.

기준이 되는 값을 **Key**라고 부른다.

여기서는

```
player.Level
```

이 Key이다.

---

## OrderBy()는 언제 실행될까?

앞에서 살펴본 것처럼 `OrderBy()`도 LINQ 메서드이므로 지연 실행이다.

```cs
var result =
    players.OrderBy(player => player.Level);
```

여기까지는 아무 일도 일어나지 않는다.

실제 정렬은

```cs
foreach (var player in result)
{
    Console.WriteLine(player.Name);
}
```

처럼 데이터를 요청하는 순간 시작된다.

---

## 그런데 왜 끝까지 읽을까?

`Where()`는

조건을 만족하는 순간

하나씩 반환할 수 있었다.

하지만 정렬은 다르다.

예를 들어

```
5

1

3

2
```

가 있다면

첫 번째 값인

```
5
```

를 먼저 반환할 수 있을까?

불가능하다.

뒤에

```
1
```

이 있기 때문이다.

즉,

정렬을 수행하려면

모든 데이터를

먼저 읽어야 한다.

```
전체 수집

↓

정렬

↓

반환 시작
```

이 된다.

---

## 내부적으로는 어떤 과정이 일어날까?

개념적으로는 다음 순서이다.

```
컬렉션

↓

배열로 복사

↓

Key 생성

↓

Comparer로 정렬

↓

Enumerator 반환
```

즉,

OrderBy는

순회하면서 동시에 정렬하는 것이 아니다.

모든 데이터를 메모리에 보관한 뒤

정렬을 수행한다.

## Comparer는 무엇일까?

숫자는

어떤 값이 큰지

쉽게 비교할 수 있다.

하지만

Player 같은 객체는

무엇을 기준으로 비교해야 할까?

그래서

```cs
player => player.Level
```

이라는

Key Selector를 전달한다.

컴파일러는 이를

```cs
Func<Player, int>
```

로 변환한다.

이 Key를 이용해

Comparer가

정렬 순서를 결정한다.

---

## ThenBy()는 왜 가능할까?

다음 코드를 보자.

```cs
var result =
    players
        .OrderBy(player => player.Level)
        .ThenBy(player => player.Name);
```

많은 사람들이

```
첫 번째 정렬

↓

두 번째 정렬
```

이라고 생각한다.

하지만 실제로는

하나의 정렬 과정에서

비교 기준만 추가된다.

비교는

다음 순서로 진행된다.

```
Level 비교

↓

같다면

↓

Name 비교
```

즉,

이미 정렬된 결과를

다시 정렬하는 것이 아니다.

---

## Stable Sort란?

OrderBy는

안정 정렬(Stable Sort)을 사용한다.

안정 정렬이란

같은 Key를 가진 요소의

원래 순서를 유지하는 정렬이다.

예를 들어

```
Alice

Level = 10

---------------

Bob

Level = 10

---------------

Charlie

Level = 20
```

를

Level로 정렬하면

결과는

```
Alice

Bob

Charlie
```

이다.

Alice와 Bob의

순서는 그대로 유지된다.

이 특성 덕분에

`ThenBy()`가 자연스럽게 동작할 수 있다.

---

## OrderByDescending()

내림차순도

동일한 방식이다.

```cs
players.OrderByDescending(player => player.Level);
```

단지

Comparer의 비교 결과만

반대로 적용한다.

---

## 여러 번 OrderBy를 호출하면?

다음 코드를 보자.

```cs
players
    .OrderBy(player => player.Level)
    .OrderBy(player => player.Name);
```

많은 사람들이

Level과 Name으로

정렬될 것이라 생각한다.

하지만 그렇지 않다.

두 번째 `OrderBy()`는

첫 번째 정렬 결과를 무시하고

새로운 정렬 기준을 만든다.

즉,

최종 결과는

Name 기준 정렬이다.

여러 기준을 사용하려면

반드시

```cs
.OrderBy(...)
.ThenBy(...)
```

를 사용해야 한다.

---

## OrderBy는 메모리를 사용할까?

그렇다.

앞에서 살펴봤듯

정렬은

모든 데이터를

메모리에 보관해야 한다.

즉,

컬렉션이 매우 크다면

메모리 사용량도 증가한다.

반면

Where는

필요한 데이터만

하나씩 반환한다.

즉,

OrderBy는

LINQ 메서드 중에서도

메모리 사용량이 큰 편이다.

---

## 실제 .NET에서는 어떻게 구현될까?

실제 .NET의 `OrderBy()`는 단순히 요소를 비교하며 정렬하는 것이 아니라, 내부적으로 `EnumerableSorter`와 같은 전용 정렬 클래스를 사용한다.

정렬 기준(Key)은 한 번만 계산하여 저장한 뒤, 저장된 Key를 기준으로 비교를 수행한다. 만약 비교할 때마다 `player.Level`이나 복잡한 계산식을 다시 실행한다면 불필요한 비용이 발생하기 때문이다.

또한 `ThenBy()`를 사용하는 경우에는 여러 Key를 연결한 뒤 하나의 정렬 과정에서 비교를 수행하도록 최적화되어 있다.

---

**실무에서 자주 하는 오해**

가장 흔한 오해는

> **OrderBy()**도 **Where()**처럼 하나씩 처리한다.

라는 것이다.

정렬은 전체 데이터를 알아야 하므로 모든 요소를 먼저 수집한 뒤 수행된다.

또 하나의 오해는

> **OrderBy()**를 여러 번 호출하면 정렬 기준이 추가된다.

라는 것이다.

정렬 기준을 추가하려면 `ThenBy()`를 사용해야 하며, `OrderBy()`를 다시 호출하면 이전 정렬 기준은 새 기준으로 대체된다.

---

## 마무리

`OrderBy()`는 단순한 정렬 메서드가 아니라 Key Selector와 Comparer를 이용해 컬렉션 전체를 정렬하는 LINQ 메서드이다.

정렬을 위해서는 모든 데이터를 먼저 수집해야 하므로 `Where()`와 달리 부분적으로 처리할 수 없으며, 그만큼 메모리 사용량도 증가한다. 또한 안정 정렬을 사용하기 때문에 `ThenBy()`를 이용한 다중 기준 정렬도 자연스럽게 지원한다.

정렬은 LINQ에서 가장 비용이 큰 연산 중 하나이므로, 필요한 경우에만 사용하고 여러 기준을 사용할 때는 `OrderBy()`와 `ThenBy()`를 올바르게 구분하는 것이 중요하다.

다음 글에서는 **`GroupBy()`와 `ToLookup()`은 무엇이 다를까?**를 살펴보며 데이터를 그룹으로 묶는 LINQ의 동작 방식과 두 메서드의 차이를 알아보겠다.

---

## 핵심 정리

- `OrderBy()`는 지정한 Key를 기준으로 컬렉션을 정렬한다.
- `OrderBy()`도 지연 실행이지만, 실제 실행 시에는 모든 데이터를 먼저 수집한다.
- 정렬은 Key Selector와 Comparer를 사용하여 수행된다.
- `ThenBy()`는 새로운 정렬이 아니라 기존 정렬 기준에 비교 기준을 추가한다.
- `OrderBy()`는 안정 정렬을 사용하므로 동일한 Key의 상대적인 순서를 유지한다.
- `OrderBy()`를 여러 번 호출하면 이전 정렬 기준은 덮어쓰이며, 다중 기준 정렬에는 `ThenBy()`를 사용해야 한다.
- 정렬은 전체 데이터를 메모리에 보관해야 하므로 LINQ에서 비용이 큰 연산 중 하나이다.
