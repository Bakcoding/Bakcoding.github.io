---
title: "[궁금시리즈] 3-1. Generic은 왜 등장했을까?"
excerpt: "C#"
categories:
  - Programming
tags:
  - CSharp
permalink: /programming/3-1-generic/
toc: true
toc_sticky: true
date: 2026-07-23
last_modified_at: 2026-07-23
---

C#을 배우다 보면 가장 자주 만나는 문법 중 하나가 Generic이다.
예를 들어

```cs
List<int> numbers = new List<int>();

Dictionary<string, Player> players = new();
```

또는

```cs
public T GetValue<T>()
{
    ...
}
```

처럼 <T>를 사용하는 코드를 자주 보게 된다.
많은 개발자는

> "Generic은 여러 자료형을 사용할 수 있게 해주는 문법이다."

정도로만 알고 넘어간다.

물론 맞는 설명이다.

하지만 이것만으로는
*왜 Generic이 만들어졌는지*를 이해하기 어렵다.

Generic은 단순히 편리한 문법이 아니라
**타입 안정성과 성능 문제를 동시에 해결하기 위해 등장한 기능**이다.
이번 글에서는 Generic이 왜 필요했는지부터 알아보자.

---

## Generic이 없던 시절
.NET 1.0에는 Generic이 없었다.
당시에는 다양한 자료형을 저장하기 위해
object를 사용했다.

예를 들어

```cs
ArrayList list = new ArrayList();

list.Add(10);
list.Add("Hello");
list.Add(new Player());
```

모든 자료형을 저장할 수 있었다.
겉보기에는 매우 편리해 보인다.

---

## 문제점 1. 타입 안정성

예를 들어

```cs
ArrayList list = new ArrayList();

list.Add(10);
list.Add("Hello");
```

이후

```cs
int value = (int)list[1];
```

를 실행하면 런타임에서

```
InvalidCastException
```

이 발생한다.

컴파일러는 ArrayList 안에 
어떤 타입이 들어있는지 알 수 없기 때문이다.

즉, 오류를 컴파일 시점이 아닌
런타임에서 발견하게 된다.

---

## 문제점 2. Boxing

더 큰 문제는 값 타입이다.

```cs
ArrayList list = new ArrayList();

list.Add(10);
```

여기서

```
int

↓

object
```

로 저장된다.

즉, Boxing이 발생한다.

값 타입이 Heap에 복사되고
새로운 객체가 생성된다.

반대로 꺼낼 때는

```cs
int value = (int)list[0];
```

처럼 Unboxing이 발생한다.

앞에서 살펴본 것처럼 Boxing과 Unboxing은
불필요한 Heap 할당과 성능 저하를 일으킨다.

---

## 그래서 Generic이 등장했다

Generic은

> 자료형을 나중에 결정하도록 만드는 기능이다.

예를 들어

```cs
List<int> numbers = new();
```

컴파일러는 처음부터

```cs
List<int>
```

라는 것을 알고 있다.

즉, 잘못된 자료형은
컴파일 단계에서 막을 수 있다.

---

## 타입 안정성

다음 코드를 보자.

```cs
List<int> numbers = new();

numbers.Add(10);
numbers.Add(20);
```

여기에

```cs
numbers.Add("Hello");
```

를 작성하면
컴파일 자체가 되지 않는다.

즉, 잘못된 자료형을
실행하기도 전에 발견할 수 있다.

---

## Boxing이 사라진다

```cs
List<int> numbers = new();

numbers.Add(10);
```

여기서는 값 타입을
object로 변환하지 않는다.

즉, 

```
Boxing 없음
```

Heap 할당도 발생하지 않는다.

이것이 Generic이 성능 면에서도 중요한 이유이다.

---

## Generic은 하나의 코드로 여러 타입을 만든다

예를 들어

```cs
class Box<T>
{
    public T Value;
}
```

사용은

```cs
Box<int> numberBox = new();
Box<string> textBox = new();
Box<Player> playerBox = new();
```

클래스는 하나지만
타입은 각각 다르다.

---

## 컴파일러는 어떻게 처리할까?

컴파일러는

```cs
Box<int>
```

와

```cs
Box<string>
```

를 서로 다른 타입으로 인식한다.

그래서

```cs
Box<int>
```

에는 string 을 넣을 수 없다.

---

## Generic은 형변환이 필요 없다

예전 방식

```cs
object obj = 10;

int value = (int)obj;
```

Generic

```cs
List<int> numbers = new();

int value = numbers[0];
```

캐스팅이 없다.

즉, 코드도 더 안전하고
더 간결해진다.

---

## Generic이 사용되는 곳

실제로 .NET에서는 거의 모든 
핵심 라이브러리가 Generic을 사용한다.

예를 들어

- List<T>
- Dictionary<TKey, TValue>
- Queue<T>
- Stack<T>
- HashSet<T>
- Task<T>
- Nullable<T>
- IComparable<T>

등이 있다.

즉, Generic은 C#의 핵심 기능이라고 할 수 있다.

---

## Generic은 단순한 편의 기능이 아니다

많은 사람들이

> "중복 코드를 줄이기 위해 만들었다."

라고 생각한다.

물론 그것도 맞다.

하지만 더 중요한 목적은

- 타입 안정성
- Boxing 제거
- 캐스팅 제거
- 성능 향상

이다.

즉, Generic은
**안전성과 성능을 모두 얻기 위해 설계된 기능**이다.

---

## 마무리
Generic은 다양한 타입을 하나의 코드로 처리하기 위한 기능이지만, 그 진짜 목적은 **타입 안정성과 성능 향상**에 있다.

Generic이 등장하면서 object 기반 컬렉션의 단점을 해결했고, 컴파일 시점의 타입 검사와 Boxing 제거를 통해 더욱 안전하고 효율적인 코드를 작성할 수 있게 되었다.

다음 글에서는 **<T>는 컴파일러가 어떻게 처리할까?**를 알아보며 Generic의 내부 동작과 런타임 구현 방식을 살펴보겠다.

---

## 핵심 정리

- Generic은 자료형을 나중에 결정하는 기능이다.
- Generic 이전에는 object 기반 컬렉션을 많이 사용했다.
- object는 타입 안정성과 Boxing 문제를 가지고 있었다.
- Generic은 컴파일 시점에 타입을 검사한다.
- Generic은 불필요한 캐스팅과 Boxing을 제거한다.
- List<T>, Dictionary<TKey, TValue> 등 .NET의 핵심 라이브러리는 대부분 Generic 기반이다.
- Generic은 편의 기능이 아니라 성능과 안정성을 위한 기능이다.
