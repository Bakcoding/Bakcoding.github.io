---
title: "[궁금시리즈] 3-4. Generic 클래스와 Generic 메서드는 언제 사용해야 할까?"
excerpt: "C#"
categories:
  - Programming
tags:
  - CSharp
permalink: /programming/3-4-generic-generic/
toc: true
toc_sticky: true
date: 2026-07-23
last_modified_at: 2026-07-23
---

Generic을 배우다 보면 두 가지 형태를 만나게 된다.
첫 번째는 Generic 클래스이다.

```cs
class Box<T>
{
    public T Value;
}
```

두 번째는 Generic 메서드이다.

```cs
public T GetValue<T>(T value)
{
    return value;
}
```

둘 다 <T>를 사용하지만
언제 클래스를 Generic으로 만들고,
언제 메서드만 Generic으로 만들어야 하는지 헷갈리는 경우가 많다.
이번 글에서는 두 방식의 차이와 각각 언제 사용하는 것이 좋은지 알아보자.

---

## Generic 클래스

Generic 클래스는

> 클래스 전체가 하나의 타입을 계속 사용하는 경우에 사용한다.

예를 들어

```cs
class Box<T>
{
    public T Value;

    public void Set(T value)
    {
        Value = value;
    }

    public T Get()
    {
        return Value;
    }
}
```

여기서는 클래스 전체가

```cs
T
```

를 중심으로 동작한다.

---

사용은

```
Box<int> intBox = new();

Box<string> stringBox = new();
```

처럼 한다.

각 객체는 생성되는 순간
자료형이 결정된다.

---

## Generic 메서드

반면 메서드 하나만
자료형이 달라질 수도 있다.

예를 들어

```cs
public static void Print<T>(T value)
{
    Console.WriteLine(value);
}
```

사용은

```
Print(10);

Print("Hello");

Print(new Player());
```

모두 가능하다.

클래스 자체는 Generic일 필요가 없다.

---

## 가장 큰 차이

Generic 클래스는

```
객체가 생성될 때

↓

자료형 결정
```

된다.

반면 Generic 메서드는

```
메서드를 호출할 때

↓

자료형 결정
```

된다.

---

## Generic 클래스가 필요한 경우

예를 들어

```cs
class Repository<T>
{
}
```

한 Repository는 항상 하나의 자료형만 관리한다.

```
Repository<Player>

Repository<Item>

Repository<Monster>
```

Player Repository 안에 Item을 넣을 수는 없다.

이런 경우에는 클래스 Generic이 적합하다.

---

## Generic 메서드가 필요한 경우

예를 들어 Swap 함수를 만들어 보자.

```cs
public static void Swap<T>(ref T a, ref T b)
{
    T temp = a;
    a = b;
    b = temp;
}
```

사용은

```
Swap(ref x, ref y);

Swap(ref player1, ref player2);

Swap(ref text1, ref text2);
```

이다.

Swap 자체는 자료형을 기억할 필요가 없다.

호출할 때만 알면 된다.

---

## 타입 추론(Type Inference)

Generic 메서드의 큰 장점은
컴파일러가 자료형을 추론할 수 있다는 점이다.

예를 들어

```
Print<int>(10);
```

라고 작성하지 않아도

```
Print(10);
```

만으로도 컴파일러는

```
T == int
```

라는 것을 알아낸다.
이를 **타입 추론(Type Inference)**
이라고 한다.

---

## Generic 클래스도 타입 추론이 될까?

객체를 생성할 때는 다음처럼 작성한다.

```cs
Box<int> box = new();
```

왼쪽에서

```
Box<int>
```

를 이미 알고 있으므로

```
new();
```

만 작성해도 된다.

하지만

```
new Box<>();
```

처럼 자료형을 생략할 수는 없다.

클래스는 생성 시점에 자료형이 
반드시 결정되어야 하기 때문이다.

---

## Generic 클래스 안에 Generic 메서드도 가능하다

둘은 함께 사용할 수도 있다.

```cs
class Repository<T>
{
    public TResult Convert<TResult>()
    {
        ...
    }
}
```

여기서는 클래스는

```
T
```

를 사용하고 메서드는

```
TResult
```

를 별도로 사용한다.

실무에서도 자주 볼 수 있는 형태이다.

---

## LINQ도 Generic 메서드이다

예를 들어

```cs
numbers.Where(x => x > 10);
```

또는

```cs
numbers.Select(x => x.Name);
```

이들은 모두 Generic 메서드이다.

컴파일러가 자동으로

```
T
```

를 추론하기 때문에 우리는 <int>
같은 것을 거의 작성하지 않는다.

---

## 실제 .NET 라이브러리에서는 어떻게 사용할까?

지금까지는 직접 만든 예제로 Generic 클래스와 Generic 메서드를 살펴봤다.

실제로 .NET 라이브러리도 같은 원칙으로 설계되어 있다.

예를 들어 List<T>는 Generic 클래스이다.

```cs
public class List<T>
{
    // ...
}
```

List 객체는 생성되는 순간 자료형이 결정된다.

```cs
List<int> numbers = new();
List<string> names = new();
```

한 번 생성된 List는 같은 자료형만 저장할 수 있다.

반면 Where()는 Generic 메서드이다.

```cs
public static IEnumerable<TSource> Where<TSource>(
    this IEnumerable<TSource> source,
    Func<TSource, bool> predicate)
{
    // ...
}
```

여기서는 클래스가 아니라 메서드를 호출하는 순간 TSource가 결정된다.

예를 들어

```cs
numbers.Where(x => x > 10);
```

를 호출하면 컴파일러는 자동으로

```
TSource == int
```

라고 추론한다.

반대로

```cs
players.Where(x => x.Level > 10);
```

에서는

```cs
TSource == Player
```

가 된다.
 
즉, Where() 메서드는 하나만 존재하지만 호출하는 
컬렉션의 타입에 따라 다양한 자료형을 처리할 수 있다.

이처럼 .NET 라이브러리는 
**객체가 타입을 기억해야 하는 경우에는 Generic 클래스**, 
**메서드 하나만 다양한 타입을 처리하면 되는 경우에는 Generic 메서드**를 
사용하는 방식으로 설계되어 있다.

---

## 어떤 것을 선택해야 할까?
다음 기준으로 생각하면 된다.
 
**Generic 클래스**

- 객체 전체가 하나의 타입을 유지해야 하는 경우
- 타입을 상태(State)로 가지고 있는 경우

예)

- List<T>
- Queue<T>
- Stack<T>
- Repository<T>

---

## Generic 메서드

- 메서드 하나만 다양한 타입을 처리하면 되는 경우
- 객체가 타입을 기억할 필요가 없는 경우

예)

- Swap<T>()
- Max<T>()
- Print<T>()
- LINQ


## 마무리

Generic 클래스와 Generic 메서드는 모두 다양한 타입을 처리하기 위한 기능이지만, 타입이 필요한 범위가 다르다.

클래스 전체에서 같은 타입을 사용한다면 Generic 클래스를, 메서드 하나에서만 타입이 필요하다면 Generic 메서드를 사용하는 것이 적절하다.

이 차이를 이해하면 Generic을 더욱 자연스럽게 설계할 수 있으며, .NET 라이브러리가 왜 이런 구조를 사용하는지도 쉽게 이해할 수 있다.

다음 글에서는 **default(T)와 default는 무엇이 다를까?**를 알아보며 Generic에서 기본값을 다루는 방법을 살펴보겠다.

---

## 핵심 정리

- Generic 클래스는 클래스 전체가 하나의 타입을 사용한다.
- Generic 메서드는 메서드 호출 시 타입이 결정된다.
- Generic 메서드는 타입 추론을 지원한다.
- Generic 클래스와 Generic 메서드는 함께 사용할 수도 있다.
- List<T>는 Generic 클래스, Where<T>()는 Generic 메서드이다.
- 타입이 필요한 범위를 기준으로 적절한 방식을 선택하는 것이 중요하다.
