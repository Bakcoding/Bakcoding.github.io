---
title: "[궁금시리즈] 7-2. LINQ는 내부적으로 어떻게 동작할까?"
excerpt: "C#"
categories:
  - CSharp
series: question-series
tags:
  - CSharp
permalink: /programming/7-2-linq/
toc: true
toc_sticky: true
date: 2026-07-27 20:33:59 +0900
last_modified_at: 2026-07-27
---

## 들어가며

LINQ를 사용하다 보면 다음과 같은 코드를 자주 작성하게 된다.

```cs
List<int> numbers = [1, 2, 3, 4, 5];

IEnumerable<int> result =
    numbers.Where(number => number % 2 == 0);
```

보기에는 단순히 `Where()`를 호출한 것처럼 보인다.

하지만 실제로는 이 한 줄 안에서 여러 C# 기능이 함께 동작한다.

- Extension Method
- Lambda Expression
- Delegate
- IEnumerable<T>
- Iterator
- yield return

LINQ는 새로운 문법이 아니라, 기존 C# 기능들을 조합하여 만든 라이브러리이다.

이번 글에서는 `Where()` 하나가 내부적으로 어떻게 동작하는지 살펴본다.

---

## Where()는 메서드일 뿐이다

많은 사람들이

```cs
numbers.Where(...)
```

를 특별한 문법처럼 생각한다.

하지만 `Where()`는 단순한 메서드이다.

실제로 정의는 다음과 비슷하다.

```cs
public static IEnumerable<TSource> Where<TSource>(
    this IEnumerable<TSource> source,
    Func<TSource, bool> predicate)
```

여기서 중요한 것은 두 가지이다.

첫 번째 매개변수 앞에 붙은

```cs
this
```

는 Extension Method를 의미한다.

즉,

```cs
numbers.Where(...)
```

는 실제로는

```cs
Enumerable.Where(numbers, ...)
```

를 호출하는 것과 같다.

---

## 람다는 Func로 변환된다

다음 코드를 보자.

```cs
numbers.Where(number => number % 2 == 0);
```

람다는 그대로 실행되는 것이 아니다.

컴파일러는

```cs
number => number % 2 == 0
```

를

```cs
Func<int, bool>
```

Delegate로 변환한다.

즉,

실제로는

```cs
Func<int, bool> predicate =
    number => number % 2 == 0;

Enumerable.Where(numbers, predicate);
```

와 비슷한 형태가 된다.

---

## IEnumerable<T>를 반환하는 이유

`Where()`는

```cs
List<T>
```

를 반환하지 않는다.

반환형은

```cs
IEnumerable<T>
```

이다.

왜 그럴까?

그 이유는 아직 데이터를 검사하지 않았기 때문이다.

`Where()`는

> "이 조건으로 데이터를 가져오겠다."

라는 방법만 만들어 놓는다.

즉,

결과가 아니라

조회 방법을 반환한다.

---

## 실제 반복은 언제 일어날까?

다음 코드를 보자.

```cs
IEnumerable<int> result =
    numbers.Where(number => number % 2 == 0);
```

여기까지는 아무 일도 일어나지 않는다.

반복이 시작되는 순간은

```cs
foreach (int number in result)
{
    Console.WriteLine(number);
}
```

이다.

이때 비로소

```
1 검사

↓

2 검사

↓

3 검사

↓

4 검사

↓

...
```

가 수행된다.

이를 **지연 실행(Deferred Execution)** 이라고 한다.

---

## Where()는 내부에서 어떻게 구현될까?

실제 .NET 구현은 훨씬 복잡하지만,

개념적으로는 다음과 비슷하다.

```cs
public static IEnumerable<int> Where(
    IEnumerable<int> source,
    Func<int, bool> predicate)
{
    foreach (int item in source)
    {
        if (predicate(item))
        {
            yield return item;
        }
    }
}
```

놀랍게도

LINQ도 결국

평범한 반복문이다.

---

## yield return이 중요한 이유

여기서 핵심은

```cs
yield return
```

이다.

```cs
foreach (int item in source)
{
    if (predicate(item))
    {
        yield return item;
    }
}
```

이 코드는

모든 결과를 한 번에 만들지 않는다.

필요한 순간마다 하나씩 반환한다.

예를 들어

```cs
result.First();
```

만 호출한다면

첫 번째 조건을 만족하는 요소를 찾는 순간

순회가 종료된다.

즉,

불필요한 작업을 하지 않는다.

---

## Where().Select().OrderBy()는 어떻게 이어질까?

다음 코드를 보자.

```cs
var result = players
    .Where(player => player.Level >= 10)
    .Select(player => player.Name)
    .OrderBy(name => name);
```

많은 사람들이

```
Where 완료

↓

Select 완료

↓

OrderBy 완료
```

순서로 실행된다고 생각한다.

실제로는 그렇지 않다.

각 메서드는

새로운 IEnumerable을 만들어 연결만 한다.

```
players

↓

Where Iterator

↓

Select Iterator

↓

OrderBy Iterator
```

실제 순회는

마지막에 데이터를 요청하는 순간 시작된다.

---

## foreach는 무엇을 호출할까?

다음 코드

```cs
foreach (int number in result)
{
    Console.WriteLine(number);
}
```

는

컴파일러가

대략 다음처럼 바꾼다.

```cs
using IEnumerator<int> enumerator =
    result.GetEnumerator();

while (enumerator.MoveNext())
{
    int number = enumerator.Current;

    Console.WriteLine(number);
}
```

즉,

LINQ는

결국 Enumerator를 통해

데이터를 하나씩 꺼낸다.

---

## LINQ는 새로운 컬렉션을 만드는 것이 아니다

다음 코드를 보자.

```cs
IEnumerable<int> result =
    numbers.Where(number => number > 3);
```

많은 사람들이

새로운 리스트가 만들어졌다고 생각한다.

하지만

실제로는

```
numbers

+

조건
```

만 저장되어 있다.

진짜 리스트를 만들려면

```cs
List<int> list =
    result.ToList();
```

처럼

즉시 실행 메서드를 호출해야 한다.

---

## 실제 .NET에서는 어떻게 최적화될까?

.NET의 LINQ 구현은 생각보다 훨씬 많은 최적화를 포함하고 있다.

예를 들어 `Where()`를 여러 번 연결하면 단순히 중첩 반복문을 만드는 것이 아니라, 가능한 경우 조건을 하나로 결합하여 불필요한 객체 생성을 줄인다.

또한 배열과 `List<T>`처럼 자주 사용하는 컬렉션은 전용 Iterator를 사용하여 일반적인 `IEnumerable<T>`보다 더 효율적으로 순회한다.

즉, 우리가 사용하는 `Where()` 하나도 내부에서는 다양한 최적화가 적용된다.

---

## 실무에서 자주 하는 오해

가장 흔한 오해는

> **LINQ**는 반복문을 사용하지 않는다.

라는 것이다.

실제로는 모든 LINQ는 결국 컬렉션을 순회한다.

또 하나의 오해는

> **Where()**를 호출하면 바로 필터링이 수행된다.

라는 것이다.

`Where()`는 조건만 저장해 두며, 실제 필터링은 데이터를 열거하는 순간 수행된다.

---

## 마무리

LINQ는 새로운 실행 방식이 아니라, Extension Method, Delegate, Lambda, `IEnumerable<T>`, `yield return`과 같은 C# 기능을 조합하여 만든 라이브러리이다.

`Where()`는 단순히 조건을 저장하는 Iterator를 만들고, 실제 데이터 처리는 `foreach`나 `ToList()`, `First()`처럼 결과를 요구하는 시점에 수행된다. 이러한 구조 덕분에 LINQ는 필요한 만큼만 데이터를 처리하는 지연 실행을 지원할 수 있다.

다음 글에서는 **IEnumerable<T\>와 IEnumerator<T\>는 무엇이 다를까?**를 살펴보며 `foreach`가 내부적으로 어떻게 동작하는지와 `MoveNext()`, `Current`, `Dispose()`의 역할을 알아보겠다.

---

## 핵심 정리

- `Where()`는 특별한 문법이 아니라 Extension Method이다.
- 람다는 `Func<T, bool>` Delegate로 변환된다.
- `Where()`는 `IEnumerable<T>`를 반환하며, 결과가 아닌 조회 방법을 나타낸다.
- 대부분의 LINQ는 `yield return`을 사용한 Iterator 기반으로 구현된다.
- 실제 순회는 `foreach`나 `ToList()`처럼 결과를 요구하는 시점에 수행된다.
- `foreach`는 내부적으로 `IEnumerator<T>`를 사용해 데이터를 순회한다.
- .NET은 배열과 `List<T>` 등에 대해 전용 Iterator를 사용하는 등 다양한 최적화를 적용한다.
