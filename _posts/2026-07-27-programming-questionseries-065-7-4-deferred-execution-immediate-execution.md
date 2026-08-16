---
title: "[궁금시리즈] 7-4. 지연 실행(Deferred Execution)과 즉시 실행(Immediate Execution)"
excerpt: "C#"
categories:
  - CSharp
series: question-series
tags:
  - CSharp
permalink: /programming/7-4-deferred-execution-immediate-execution/
toc: true
toc_sticky: true
date: 2026-07-27 20:34:01 +0900
last_modified_at: 2026-07-27
---

## 들어가며

다음 코드를 보자.

```cs
List<int> numbers = [1, 2, 3, 4, 5];

IEnumerable<int> result =
    numbers.Where(number => number % 2 == 0);
```

많은 사람들이 `Where()`를 호출하는 순간 이미 필터링이 끝났다고 생각한다.

하지만 실제로는 아무 일도 일어나지 않는다.

LINQ의 대부분의 메서드는 호출 즉시 데이터를 처리하지 않고, 필요한 순간까지 실행을 미루는 방식으로 동작한다.

이를 **지연 실행(Deferred Execution)** 이라고 한다.

반대로 결과를 즉시 계산하는 방식을 **즉시 실행(Immediate Execution)** 이라고 한다.

이번 글에서는 두 방식의 차이와 각각 언제 사용되는지 확인한다.

---

## 지연 실행이란?

지연 실행은 말 그대로 실행을 나중으로 미루는 것이다.

다음 코드를 보자.

```cs
List<int> numbers = [1, 2, 3, 4, 5];

IEnumerable<int> result =
    numbers.Where(number => number % 2 == 0);
```

여기까지 실행해도

```
1 검사

2 검사

3 검사

...
```

같은 작업은 아직 수행되지 않는다.

`Where()`는 단지

> "짝수만 반환하는 방법"

을 만들어 둘 뿐이다.

---

## 언제 실행될까?

실제 실행은 데이터를 요청하는 순간 이루어진다.

```cs
foreach (int number in result)
{
    Console.WriteLine(number);
}
```

이때 비로소

```
1 검사

↓

2 출력

↓

3 검사

↓

4 출력

↓

5 검사
```

가 수행된다.

---

## 왜 이렇게 만들었을까?

가장 큰 이유는 불필요한 작업을 줄이기 위해서이다.

예를 들어

```cs
numbers
    .Where(number => number > 10)
    .First();
```

를 보자.

조건을 만족하는 첫 번째 값만 필요하다.

지연 실행이라면

```
11 발견

↓

즉시 종료
```

가 가능하다.

모든 데이터를 끝까지 검사할 필요가 없다.

---

## 즉시 실행이란?

반면

다음 코드는 다르다.

```cs
List<int> list =
    numbers.Where(number => number % 2 == 0)
           .ToList();
```

`ToList()`를 호출하는 순간

LINQ는

모든 데이터를 순회하여

새로운 List를 만든다.

즉,

```
Where

↓

전체 순회

↓

새 List 생성
```

이 수행된다.

---

## 대표적인 지연 실행 메서드

다음 메서드들은 대부분 지연 실행이다.

```
Where()

Select()

Skip()

Take()

Distinct()

Concat()
```

이들은

결과를 바로 만들지 않는다.

단지

다음 Enumerator를

연결할 뿐이다.

---

## 대표적인 즉시 실행 메서드

다음 메서드들은

호출하는 순간 실행된다.

```
ToList()

ToArray()

ToDictionary()

Count()

Sum()

Average()

Max()

Min()
```

결과를 계산해야 하므로

즉시 순회가 시작된다.

---

## First()는 어느 쪽일까?

`First()`도 즉시 실행이다.

하지만

모든 데이터를 읽지는 않는다.

```cs
numbers.First(number => number > 10);
```

는

첫 번째 조건을 만족하는 순간

즉시 종료된다.

즉,

```
1

↓

2

↓

...

↓

11

↓

종료
```

이다.

전체를 순회하지 않는다.

---

## Count()도 즉시 실행이다

```cs
int count =
    numbers.Where(number => number > 10)
           .Count();
```

여기서는

조건을 만족하는 개수를 알아야 한다.

따라서

모든 데이터를

끝까지 검사해야 한다.

---

## ToList() 이후에는 어떻게 될까?

다음 코드를 보자.

```cs
List<int> list =
    numbers.Where(number => number % 2 == 0)
           .ToList();
```

이후

```cs
numbers.Add(6);
```

을 실행해도

```cs
foreach (int number in list)
{
    Console.WriteLine(number);
}
```

결과에는

6이 포함되지 않는다.

이미 새로운 List가 만들어졌기 때문이다.

---

## 지연 실행은 원본 데이터를 다시 읽는다

이번에는

```cs
IEnumerable<int> result =
    numbers.Where(number => number % 2 == 0);

numbers.Add(6);

foreach (int number in result)
{
    Console.WriteLine(number);
}
```

를 보자.

이번에는

```
2

4

6
```

이 출력된다.

지연 실행은

컬렉션을 미리 복사하지 않는다.

순회하는 순간

현재 컬렉션을 읽는다.

---

## 여러 번 순회하면 어떻게 될까?

다음 코드를 보자.

```cs
IEnumerable<int> result =
    numbers.Where(number => number % 2 == 0);

foreach (int number in result)
{
    Console.WriteLine(number);
}

foreach (int number in result)
{
    Console.WriteLine(number);
}
```

많은 사람들이

첫 번째 결과를 재사용한다고 생각한다.

하지만 실제로는

두 번째 `foreach`에서도

다시 처음부터 순회한다.

즉,

```
첫 번째 순회

↓

전체 검사

↓

두 번째 순회

↓

다시 전체 검사
```

가 된다.

---

## 언제 ToList()를 사용하는 것이 좋을까?

다음과 같이 결과를 여러 번 사용할 예정이라면

```cs
var query =
    players.Where(player => player.Level >= 10);

query.Count();

query.Last();

query.ToArray();
```

매번 순회가 발생할 수 있다.

이런 경우에는

```cs
List<Player> list =
    players.Where(player => player.Level >= 10)
           .ToList();
```

로 한 번만 계산해 두는 것이 더 효율적일 수 있다.

다만 무조건 `ToList()`를 사용하는 것도 좋은 습관은 아니다.

결과를 한 번만 사용할 예정이라면 지연 실행이 더 효율적인 경우도 많다.

---

## 실제 .NET에서는 어떻게 사용할까?

LINQ는 지연 실행을 기본으로 설계되어 있다.

덕분에 여러 LINQ 메서드를 연결해도 실제 순회는 한 번만 수행되는 경우가 많다.

예를 들어

```cs
var result = numbers
    .Where(number => number > 10)
    .Select(number => number * 2)
    .Take(5);
```

이 코드는 `Where()`, `Select()`, `Take()`가 각각 컬렉션을 복사하는 것이 아니라 하나의 파이프라인처럼 연결된다.

데이터를 요청하는 순간 각 단계가 순차적으로 처리되며, 필요한 개수만큼만 순회가 이루어진다.

---

## 실무에서 자주 하는 오해

가장 흔한 오해는

> **Where()**를 호출하면 바로 필터링이 끝난다.

라는 것이다.

`Where()`는 조건만 저장하며 실제 필터링은 순회가 시작될 때 수행된다.

또 하나의 오해는

> **ToList()**는 성능이 더 좋다.

라는 것이다.

ToList()는 컬렉션을 새로 생성하고 모든 요소를 복사한다.

결과를 여러 번 사용할 때는 유리할 수 있지만, 한 번만 사용할 데이터라면 오히려 불필요한 메모리 할당이 발생할 수 있다.

---

## 마무리

LINQ는 기본적으로 지연 실행을 사용한다.

`Where()`, `Select()`와 같은 메서드는 즉시 데이터를 처리하지 않고, 데이터를 어떻게 조회할지에 대한 정보만 저장한다. 실제 순회는 `foreach`, `ToList()`, `Count()`, `First()`처럼 결과를 요구하는 시점에 이루어진다.

이러한 구조는 불필요한 연산을 줄이고 여러 연산을 하나의 순회로 연결할 수 있다는 장점이 있다. 반면 동일한 `IEnumerable<T>`를 여러 번 순회하면 매번 다시 실행된다는 점도 반드시 기억해야 한다.

다음 글에서는 **Select와 SelectMany는 무엇이 다를까?**를 살펴보며 Projection과 Flattening의 개념, 그리고 왜 `SelectMany()`가 필요한지 알아보겠다.

---

## 핵심 정리

- 지연 실행은 실제 데이터 처리를 필요한 시점까지 미루는 방식이다.
- `Where()`, `Select()`, `Skip()`, `Take()` 등은 대표적인 지연 실행 메서드이다.
- `ToList()`, `ToArray()`, `Count()`, `Sum()` 등은 즉시 실행 메서드이다.
- `First()`는 즉시 실행이지만 조건을 만족하는 순간 순회를 종료한다.
- 지연 실행은 컬렉션을 미리 복사하지 않고 순회 시점의 데이터를 사용한다.
- 동일한 `IEnumerable<T>`를 여러 번 순회하면 매번 다시 실행된다.
- `ToList()`는 여러 번 사용할 결과를 캐싱할 때 유용하지만, 불필요하게 사용하면 메모리 할당이 증가할 수 있다.
