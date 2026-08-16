---
title: "[궁금시리즈] 7-3. IEnumerable<T>와 IEnumerator<T>는 무엇이 다를까?"
excerpt: "C#"
categories:
  - CSharp
series: question-series
tags:
  - CSharp
permalink: /programming/7-3-ienumerable-t-ienumerator-t/
toc: true
toc_sticky: true
date: 2026-07-27 20:34:00 +0900
last_modified_at: 2026-07-27
---

## 들어가며

LINQ를 사용하다 보면 `IEnumerable<T>`라는 타입을 매우 자주 만나게 된다.

```cs
IEnumerable<int> numbers =
    Enumerable.Range(1, 5);
```

또는

```cs
var result = players.Where(player => player.Level >= 10);
```

`Where()`의 반환형 역시 `IEnumerable<T>`이다.

그런데 실제로 데이터를 하나씩 꺼내는 것은 `IEnumerable<T>`가 아니다.

그 역할을 하는 것은 `IEnumerator<T>`이다.

이번 글에서는 두 인터페이스의 역할과 `foreach`가 내부적으로 어떻게 동작하는지 살펴본다.

---

## IEnumerable<T>는 무엇일까?

`IEnumerable<T>`는

> "순회할 수 있는 컬렉션"

이라는 의미를 가진 인터페이스이다.

정의는 매우 단순하다.

```cs
public interface IEnumerable<out T>
{
    IEnumerator<T> GetEnumerator();
}
```

핵심은 단 하나의 메서드이다.

```cs
GetEnumerator()
```

즉,

`IEnumerable<T>`는

> "Enumerator를 만들어 줄 수 있다."

라는 기능만 제공한다.

---

## IEnumerator<T>는 무엇일까?

실제로 데이터를 하나씩 읽는 것은 Enumerator이다.

정의는 다음과 같다.

```cs
public interface IEnumerator<out T> : IDisposable
{
    T Current { get; }

    bool MoveNext();

    void Reset();
}
```

중요한 멤버는 세 가지이다.

- Current
- MoveNext()
- Dispose()

---

## MoveNext()

가장 중요한 메서드이다.

```cs
bool MoveNext();
```

현재 위치를

다음 요소로 이동한다.

다음 요소가 존재하면

```
true
```

를 반환하고

끝까지 도달하면

```
false
```

를 반환한다.

---

## Current

현재 위치한 데이터를 반환한다.

```cs
int value = enumerator.Current;
```

즉,

MoveNext()로 이동한 뒤

Current로 값을 읽는다.

---

## IEnumerable와 IEnumerator의 관계

두 인터페이스의 관계는 다음과 같다.

```
IEnumerable

↓

GetEnumerator()

↓

IEnumerator

↓

MoveNext()

↓

Current
```

즉,

컬렉션은 Enumerator를 만들고,

Enumerator가 실제 데이터를 순회한다.

---

## foreach는 내부에서 어떻게 동작할까?

다음 코드를 보자.

```cs
foreach (int number in numbers)
{
    Console.WriteLine(number);
}
```

컴파일러는

개념적으로 다음과 같은 코드로 변환한다.

```cs
using IEnumerator<int> enumerator =
    numbers.GetEnumerator();

while (enumerator.MoveNext())
{
    int number = enumerator.Current;

    Console.WriteLine(number);
}
```

즉,

`foreach`는 특별한 문법처럼 보이지만

실제로는 Enumerator를 사용하는 반복문이다.

---

## MoveNext()는 어떻게 동작할까?

예를 들어

```cs
List<int> numbers = [10, 20, 30];
```

을 순회하면

MoveNext()는 다음과 같이 동작한다.

```
처음

위치 = 시작 전

↓

MoveNext()

true

↓

Current = 10

↓

MoveNext()

true

↓

Current = 20

↓

MoveNext()

true

↓

Current = 30

↓

MoveNext()

false

↓

반복 종료
```

Enumerator는

현재 위치를 내부적으로 기억하고 있다.

---

## 왜 Enumerator를 따로 만들었을까?

컬렉션이 직접 순회하면 안 될까?

예를 들어

```
List

↓

MoveNext()

↓

Current
```

처럼 구현할 수도 있다.

하지만

이렇게 되면

동시에 두 번 순회할 수 없다.

예를 들어

```cs
foreach (var a in numbers)
{
    foreach (var b in numbers)
    {

    }
}
```

현재 위치가 하나뿐이라면

안쪽 반복문이 바깥 반복문의 위치를 덮어쓰게 된다.

그래서

매번 새로운 Enumerator를 만들어

독립적으로 순회하도록 설계한 것이다.

---

## LINQ는 왜 IEnumerable를 반환할까?

다음 코드를 보자.

```cs
var result =
    numbers.Where(number => number > 10);
```

`Where()`는

새로운 리스트를 만드는 것이 아니다.

단지

```
이 조건으로 순회하는 Enumerator
```

를 만들어 줄 수 있는

`IEnumerable<T>`를 반환한다.

실제 Enumerator는

```cs
foreach (var item in result)
```

를 시작하는 순간 생성된다.

---

## 직접 구현해 보기

간단한 컬렉션이라면 직접 `IEnumerable<T>`를 구현할 수도 있다.

```cs
public class NumberCollection : IEnumerable<int>
{
    private readonly int[] numbers = { 1, 2, 3 };

    public IEnumerator<int> GetEnumerator()
    {
        foreach (int number in numbers)
        {
            yield return number;
        }
    }

    IEnumerator IEnumerable.GetEnumerator()
    {
        return GetEnumerator();
    }
}
```

이제 다음과 같이 사용할 수 있다.

```cs
NumberCollection collection = new();

foreach (int number in collection)
{
    Console.WriteLine(number);
}
```

복잡한 Enumerator 클래스를 직접 작성하지 않아도 `yield return`을 사용하면 컴파일러가 필요한 Enumerator를 자동으로 생성해 준다.

---

## Dispose()는 언제 호출될까?

`IEnumerator<T>`는 `IDisposable`을 구현한다.

그 이유는

순회 중 사용하는 리소스를 정리하기 위해서이다.

예를 들어

- 파일 읽기
- 네트워크 스트림
- 데이터베이스 조회

처럼 외부 자원을 사용하는 Enumerator도 존재한다.

그래서 `foreach`는 반복이 끝나면 내부적으로 `Dispose()`도 호출한다.

---

## 실제 .NET에서는 어떻게 사용할까?

`List<T>`, 배열, `Dictionary<TKey, TValue>`, `HashSet<T>` 등 대부분의 컬렉션은 `IEnumerable<T>`를 구현한다.

덕분에 `foreach`와 LINQ는 컬렉션의 실제 구현을 몰라도 동일한 방식으로 데이터를 순회할 수 있다.

이러한 공통 인터페이스 덕분에 LINQ는 특정 컬렉션이 아니라 모든 순회 가능한 컬렉션에서 동작할 수 있다.

---

## 실무에서 자주 하는 오해

가장 흔한 오해는

> **IEnumerable<T\>가 데이터를 하나씩 읽는다.**

라는 것이다.

실제로 데이터를 읽는 것은 `IEnumerator<T>`이며,

`IEnumerable<T>`는 Enumerator를 생성하는 역할만 한다.

또 하나의 오해는

> **foreach는 특별한 반복문이다.**

라는 것이다.

`foreach`는 컴파일러가 `GetEnumerator()`, `MoveNext()`, `Current`, `Dispose()`를 호출하는 코드로 변환해 주는 문법 설탕(Syntactic Sugar)이다.

---

## 마무리

`IEnumerable<T>`와 `IEnumerator<T>`는 LINQ와 `foreach`의 핵심이 되는 인터페이스이다.

`IEnumerable<T>`는 순회 가능한 컬렉션을 나타내며, `IEnumerator<T>`는 실제 순회를 수행하는 객체이다. `foreach`는 내부적으로 Enumerator를 생성하고 `MoveNext()`와 `Current`를 반복 호출하여 데이터를 하나씩 가져온다.

이러한 구조 덕분에 C#은 컬렉션의 종류와 관계없이 동일한 방식으로 데이터를 순회할 수 있으며, LINQ 역시 이러한 기반 위에서 동작한다.

다음 글에서는 **지연 실행(Deferred Execution)**과 **즉시 실행(Immediate Execution)** 을 살펴보며, `Where()`는 왜 바로 실행되지 않는지와 `ToList()`, `Count()`, `First()`는 언제 실제 순회를 시작하는지 알아보겠다.

---

## 핵심 정리

- `IEnumerable<T>`는 순회 가능한 컬렉션을 나타내는 인터페이스이다.
- `IEnumerator<T>`는 실제 데이터를 하나씩 순회하는 객체이다.
- `IEnumerable<T>`는 `GetEnumerator()`를 통해 새로운 Enumerator를 생성한다.
- `IEnumerator<T>`는 `MoveNext()`, `Current`, `Dispose()`를 사용해 순회를 수행한다.
- `foreach`는 내부적으로 Enumerator를 사용하는 코드로 변환된다.
- LINQ는 `IEnumerable<T>`를 기반으로 모든 순회 가능한 컬렉션에서 동작한다.
- `yield return`을 사용하면 Enumerator 구현을 컴파일러가 자동으로 생성해 준다.
