---
title: "[궁금시리즈] 3-2. Generic의 <T>는 컴파일러가 어떻게 처리할까?"
excerpt: "C#"
categories:
  - Programming
tags:
  - CSharp
permalink: /programming/3-2-generic-t/
toc: true
toc_sticky: true
date: 2026-07-23
last_modified_at: 2026-07-23
---

다음과 같은 Generic 클래스를 자주 보게 된다.

```cs
class Box<T>
{
    public T Value;
}
```

그리고 사용할 때는

```cs
Box<int> numberBox = new();
Box<string> textBox = new();
```

처럼 작성한다.
그렇다면 이런 의문이 생긴다.

- <T>는 컴파일할 때 int로 바뀌는 걸까?
- 아니면 실행 중(Runtime)에 바뀌는 걸까?
- Box<int>와 Box<string>는 같은 클래스일까?

이번 글에서는 Generic이 내부적으로 어떻게 동작하는지 알아보자.

---

## 컴파일러는 T를 그대로 둔다

많은 사람들이

> 컴파일하면 <T>가 int나 string으로 치환될 것이라고 생각한다.

하지만 C#은 그렇지 않다.

예를 들어

```cs
class Box<T>
{
    public T Value;
}
```

컴파일하면 바로 Native Code가 되는 것이 아니라
먼저 IL(Intermediate Language)로 변환된다.

IL에는

```cs
Box<T>
```

라는 Generic 정보가 그대로 남아 있다.

즉, 컴파일러가 <T>를 실제 타입으로 바꾸지 않는다.

---

## IL에도 Generic 정보가 존재한다

실행 흐름은 다음과 같다.

```
C# 코드

↓

컴파일

↓

IL(Generic 정보 유지)

↓

CLR

↓

JIT

↓

Native Code
```

즉, Generic은
CLR도 이해하는 기능이다.

---

## 실제 타입은 언제 결정될까?

```cs
Box<int> number = new();
```

이 코드가 처음 실행되면

CLR은

```cs
Box<int>
```

라는 타입이 필요하다는 것을 알게 된다.

그때 JIT 컴파일러가
Box<int>에 대한 Native Code를 생성한다.

다음에는

```cs
Box<string> text = new();
```

가 실행된다.

CLR은 이번에는

```cs
Box<string>
```

에 대한 코드를 준비한다.

즉, 실제 타입은
실행 시점(JIT 컴파일 시점) 에 결정된다.

---

## 그렇다면 Generic마다 코드를 새로 만들까?

여기서 중요한 차이가 있다.
 
**값 타입(Generic + Value Type)**

```
Box<int>

Box<float>

Box<double>
```

이들은 각각 별도의 Native Code가 생성된다.

왜냐하면 메모리 구조가 모두 다르기 때문이다.

```
Box<int>

↓

Native Code A
```

```
Box<float>

↓

Native Code B
```

---

## 참조 타입(Generic + Reference Type)

```
Box<string>

Box<Player>

Box<Monster>
```

이들은 대부분 **같은 Native Code를 공유한다.**

왜냐하면 참조 타입은 모두

```
객체 주소(Reference)
```

만 다루기 때문이다.

메모리 구조가 동일하다.

즉,

```
Box<string>

↓

공통 Native Code
```

```
Box<Player>

↓

공통 Native Code
```

---

## 왜 이렇게 설계했을까?

만약

```
Box<string>

Box<Player>

Box<Enemy>

Box<Item>
```

마다 모두 새로운 Native Code를 만든다면
메모리 사용량이 엄청나게 증가할 것이다.

반면 참조 타입은 내부 구조가 모두 동일하므로
하나의 코드를 공유할 수 있다.

성능과 메모리 사용량을 모두 고려한 설계이다.

---

## Generic과 Boxing

앞 글에서 Generic은 Boxing을 막아준다고 설명했다.

왜 가능할까?

예를 들어

```cs
List<int> numbers = new();
```

컴파일러는 처음부터

```
int
```

라는 사실을 알고 있다.

따라서

```
object

↓

int
```

변환이 필요 없다.
즉, Boxing이 발생하지 않는다.

---

## Generic은 Reflection으로도 확인할 수 있다

예를 들어

```
Console.WriteLine(typeof(Box<int>));
```

출력 결과는

```
Box`1[System.Int32]
```

이다.

Generic 타입도
하나의 독립적인 타입이라는 것을 알 수 있다.

---

## 열린 Generic(Open Generic)

다음과 같은 타입은

```
typeof(List<>)
```

아직 자료형이 결정되지 않았다.
이를 **Open Generic** 이라고 한다.

---

## 닫힌 Generic(Closed Generic)

반면

```
typeof(List<int>)
```

는 자료형이 결정되었다.

이를 **Closed Generic**이라고 한다.

실제로 객체를 생성할 수 있는 것은
Closed Generic이다.

---

## Generic은 런타임 기능이다

많은 사람들이 Generic을
컴파일러 기능이라고 생각한다.

하지만 정확히 말하면
Generic은

- 컴파일러
- CLR
- JIT

모두 함께 지원하는 기능이다.
즉, C# 문법만의 기능이 아니라 .NET 런타임 자체의 기능이다.

---

## 마무리 
Generic은 컴파일 시점에 단순히 타입을 치환하는 기능이 아니다.
컴파일러는 Generic 정보를 IL에 그대로 남기고, CLR과 JIT가 실행 시점에 실제 타입에 맞는 코드를 생성한다.

또한 값 타입과 참조 타입을 다르게 처리하여 성능과 메모리 사용량을 모두 최적화하고 있다.
이러한 구조 덕분에 Generic은 타입 안정성과 성능을 동시에 제공하는 .NET의 핵심 기능이 되었다.

다음 글에서는 **Generic 제약 조건(where)은 왜 필요할까?**를 알아보며 Generic이 타입을 어떻게 제한하는지 살펴보겠다.

---

## 핵심 정리

- Generic 정보는 컴파일 후 IL에도 그대로 유지된다.
- 실제 타입은 JIT 컴파일 시점에 결정된다.
- 값 타입 Generic은 타입별로 별도의 Native Code가 생성된다.
- 참조 타입 Generic은 대부분 Native Code를 공유한다.
- Generic은 Boxing을 제거하여 성능을 향상시킨다.
- List<>는 Open Generic, List<int>는 Closed Generic이다.
- Generic은 컴파일러뿐 아니라 CLR과 JIT가 함께 지원하는 런타임 기능이다.
