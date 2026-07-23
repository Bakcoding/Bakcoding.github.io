---
title: "[궁금시리즈] 3-3. Generic 제약 조건(where)은 왜 필요할까?"
excerpt: "C#"
categories:
  - Programming
tags:
  - CSharp
permalink: /programming/3-3-generic-where/
toc: true
toc_sticky: true
date: 2026-07-23
last_modified_at: 2026-07-23
---

앞선 글에서 Generic은 타입을 나중에 결정하는 기능이라고 설명했다.
예를 들어

```
class Box<T>
{
    public T Value;
}
```

이 클래스는

```
Box<int>
Box<string>
Box<Player>
```

모든 타입을 사용할 수 있다.
하지만 여기서 문제가 생긴다.
예를 들어 T의 메서드를 호출하고 싶다면 어떻게 될까?

```cs
class Box<T>
{
    public void Print()
    {
        Value.ToString();
    }
}
```

ToString()은 호출할 수 있지만,

만약

```cs
Value.Attack();
```

처럼 특정 메서드를 호출하면 컴파일 오류가 발생한다.

컴파일러는

> T가 어떤 타입인지 모르기 때문이다.

이 문제를 해결하기 위해 등장한 것이 **Generic Constraint(제약 조건)**이다.

---

## 제약 조건이란?

제약 조건은

> Generic이 사용할 수 있는 타입을 제한하는 기능이다.

예를 들어

```cs
class Box<T>
    where T : Player
{
}
```

이제

```
Box<Player>
```

는 가능하지만

```
Box<int>
```

---

는 사용할 수 없다.

---

## 왜 필요한가?

예를 들어

```cs
class Player
{
    public void Attack()
    {
    }
}
```

다음 Generic 클래스를 보자.

```cs
class Battle<T>
    where T : Player
{
    public void Fight(T player)
    {
        player.Attack();
    }
}
```

이제 컴파일러는

```
T는 반드시 Player이다.
```

라는 사실을 알고 있다.

따라서

```
player.Attack();
```

를 안전하게 호출할 수 있다.

---

## where class

```cs
class Cache<T>
    where T : class
{
}
```

참조 타입만 허용한다.

가능

```
Cache<string>

Cache<Player>
```

불가능

```
Cache<int>
```

---

## where struct

반대로

```cs
class Buffer<T>
    where T : struct
{
}
```

값 타입만 허용한다.

가능

```
Buffer<int>

Buffer<float>
```
 
불가능

```
Buffer<string>
```

---

## 왜 class와 struct를 구분할까?

예를 들어

값 타입만 저장하는 버퍼를 만든다고 하자.

```
class Buffer<T>
    where T : struct
{
}
```

이 경우 컴파일러는

```
절대로 null이 들어오지 않는다.
```

라는 사실을 알게 된다.

반대로

```
where T : class
```

라면 null 여부를 고려한 코드를 작성할 수 있다.

즉, 제약 조건은 컴파일러에게 
더 많은 정보를 제공한다.

---

## where new()

가끔 Generic 안에서
객체를 생성하고 싶을 때가 있다.

```
new T();
```

하지만 컴파일러는

```
T에 기본 생성자가 있는지 모른다.
```

그래서 다음 코드는
컴파일되지 않는다.


```cs
class Factory<T>
{
    public T Create()
    {
        return new T();
    }
}
```

이때

```cs
class Factory<T>
    where T : new()
{
}
```

를 추가하면

```
new T();
```

를 사용할 수 있다.

---

## 여러 제약을 함께 사용할 수 있다

예를 들어

```cs
class Factory<T>
    where T : Player, new()
{
}
```

의 의미는

- Player를 상속해야 한다.
- 기본 생성자가 있어야 한다.

이다.

---

## 인터페이스도 가능하다

```cs
class SaveManager<T>
    where T : ISaveData
{
}
```

그러면

```cs
data.Save();
```

같은 코드를 안전하게 사용할 수 있다.

실무에서는 인터페이스 제약을 매우 자주 사용한다.

---

## where unmanaged

고성능 프로그래밍에서는

```
where T : unmanaged
```

도 자주 사용한다.

이 제약은 참조 타입을 포함하지 않는
순수한 값 타입만 허용한다.

예를 들어

가능

```cs
int

float

bool
```

불가능

```cs
string

Player
```

주로 
메모리 복사, Native 코드, Span<T>
등과 함께 사용된다.

---

## where notnull

```cs
where T : notnull
```

은 null이 될 수 없는 타입만 허용한다.

Dictionary의 Key처럼 null이면 안 되는 경우에 자주 사용된다.

---

## 제약 조건은 성능도 좋아질까?

많은 사람들이 

```
where를 사용하면 빨라진다.
```

라고 생각한다.

하지만 제약 조건의 주된 목적은
성능이 아니라 타입 안정성이다.

다만 컴파일러와 JIT가 타입 정보를 
더 많이 알게 되므로 일부 상황에서는
더 효율적인 코드를 생성할 수도 있다.

---

## 실무에서 가장 많이 사용하는 제약

가장 자주 사용하는 것은

```
where T : class

where T : new()

where T : IDisposable

where T : MonoBehaviour
```
이다.

특히 Unity에서는

```
where T : Component
```

도 자주 사용된다.

---

## 마무리

Generic 제약 조건은 사용할 수 있는 타입을 제한하는 기능이 아니다.
더 정확하게는 **컴파일러에게 타입에 대한 정보를 제공하는 기능**이다.

이 정보를 바탕으로 컴파일러는 잘못된 사용을 미리 막고, 개발자는 캐스팅 없이 안전한 코드를 작성할 수 있다.

실무에서는 class, struct, new(), 인터페이스 제약을 가장 많이 사용하며, 최근에는 unmanaged와 notnull도 고성능 라이브러리에서 자주 활용되고 있다.

다음 글에서는 **Generic 메서드는 언제 사용해야 할까?**를 알아보며 클래스 Generic과 메서드 Generic의 차이를 살펴보겠다.

---

## 핵심 정리

- where는 Generic에 사용할 수 있는 타입을 제한하는 기능이다.
- 제약 조건은 컴파일러에게 타입 정보를 제공한다.
- where class는 참조 타입만 허용한다.
- where struct는 값 타입만 허용한다.
- where new()는 기본 생성자가 있는 타입만 허용한다.
- 인터페이스와 부모 클래스도 제약 조건으로 사용할 수 있다.
- where unmanaged는 참조를 포함하지 않는 값 타입만 허용한다.
- 제약 조건의 가장 큰 목적은 성능보다 타입 안정성이다.
