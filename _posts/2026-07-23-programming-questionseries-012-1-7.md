---
title: "[궁금시리즈] 1-7. String Pool은 무엇일까?"
excerpt: "C#"
categories:
  - Programming
tags:
  - CSharp
permalink: /programming/1-7/
toc: true
toc_sticky: true
date: 2026-07-23
last_modified_at: 2026-07-23
---

다음 코드를 보자.

```cs
string a = "Hello";
string b = "Hello";
```

많은 사람들이 이 코드를 보면

> "Hello" 문자열 객체가 두 개 생성되겠구나.

라고 생각한다.

하지만 실제로는 그렇지 않다.
C#은 동일한 문자열을 발견하면 **하나의 객체만 생성하여 여러 변수가 함께 사용**한다.
이를 **String Pool**이라고 한다.

String Pool은 단순한 메모리 절약 기술이 아니라, String이 **Immutable(불변 객체)** 이기 때문에 가능한 최적화이다.

이번 글에서는 String Pool이 어떻게 동작하는지 알아보자.
 
## String Pool이란?

String Pool은

> 동일한 문자열 리터럴을 하나만 생성하여 여러 곳에서 공유하는 메모리 최적화 기법이다.

예를 들어

```cs
string a = "Hello";
string b = "Hello";
```

실제 메모리는 다음과 같이 구성된다.

```
Stack                     Heap (String Pool)

a ───────┐
          ▼
       "Hello"
          ▲
b ────────┘
```

즉, 문자열 객체는 하나만 존재하고
a와 b가 함께 참조한다.
 
## 왜 이렇게 해도 안전할까?

이전 글에서 String은 Immutable이라고 설명했다.

즉,

```cs
string text = "Hello";
```

라는 문자열은 절대로 변경되지 않는다.

그렇기 때문에 여러 변수가 
같은 문자열을 공유 해도 아무런 문제가 발생하지 않는다.

만약 String이 수정 가능했다면

```cs
a[0] = 'X';
```

처럼 수정했을 때

```
a

↓

Xello

↓

b도 함께 변경
```

되는 심각한 문제가 발생했을 것이다.

하지만 String은 Immutable이므로
이런 일이 절대 발생하지 않는다.

즉,

> String Pool은 Immutable이라는 특징 위에서 동작하는 최적화이다.

## 같은 문자열은 항상 같은 객체일까?

다음 코드를 보자.

```cs
string a = "Hello";
string b = "Hello";
```

참조를 비교하면

```cs
Console.WriteLine(object.ReferenceEquals(a, b));
```

결과는

```
True
```
이다.

두 변수는 같은 문자열 객체를 참조하고 있기 때문이다.
 
## new를 사용하면 어떻게 될까?

이번에는 다음 코드를 보자.

```cs
string a = "Hello";
string b = new string("Hello".ToCharArray());
```

메모리는 다음과 같이 구성된다.

```
Heap

"Hello" (Pool)
      ▲
      │
      a


"Hello" (새 객체)
      ▲
      │
      b
```

이번에는

```cs
Console.WriteLine(object.ReferenceEquals(a, b));
```

결과가

```
False
```

가 된다.

왜냐하면 new는 항상 새로운 객체를 생성하기 때문이다.
 
## 그런데 값은 같은데?

참조는 다르지만
다음 비교는 어떨까?

```cs
Console.WriteLine(a == b);
```

결과는

```
True
```

이다.

왜냐하면 String은 == 연산자를 재정의하여
**참조가 아니라 문자열의 내용(Value)**을 비교하기 때문이다.

즉,

| 비교 방식 | 결과 |
| -------- | ---- |
| a == b   | 문자열 내용 비교 |
| ReferenceEquals(a, b) | 같은 객체인지 비교 |

이 차이를 이해하는 것이 중요하다.
 
## String Pool에는 언제 등록될까?

String Pool에는
**문자열 리터럴(String Literal)**이 등록된다.

예를 들어

```cs
string a = "Hello";
string b = "Hello";
```

은 String Pool을 사용한다.

하지만

```cs
string text = Console.ReadLine();
```

처럼 실행 중(Runtime)에 생성된 문자열은
자동으로 Pool에 등록되지 않는다.

즉, Pool은

> 컴파일 시점에 알 수 있는 문자열 리터럴을 대상으로 동작한다.

## Intern()이란?
실행 중 생성한 문자열도
String Pool에 등록할 수 있다.
바로

```cs
string.Intern()
```

메서드를 사용하면 된다.

예를 들어

```cs
string text = new string("Hello".ToCharArray());

text = string.Intern(text);
```

그러면
기존 문자열 대신
String Pool 안의 "Hello" 객체를 참조하게 된다.

다만 일반적인 개발에서는 직접 사용할 일이 거의 없다.

런타임이 대부분의 문자열 리터럴을 자동으로 관리해 주기 때문이다.
 
## String Pool의 장점

**1. 메모리 절약**
같은 문자열을 하나만 생성한다.

예를 들어

```
"Player"
```

라는 문자열이 프로그램에서 1,000번 등장해도
객체는 하나만 생성된다.
 
**2. GC 부담 감소**
같은 문자열 객체를 계속 생성하지 않으므로
Heap에 생성되는 객체 수가 줄어든다.

즉, Garbage Collector가 처리해야 하는 객체도 감소한다.
 
**3. 참조 공유**
같은 문자열을 여러 곳에서 안전하게 공유할 수 있다.
Immutable이기 때문에 가능한 최적화이다.
 
## String Pool에도 단점이 있을까?
String Pool에 등록된 문자열은
프로그램이 실행되는 동안 계속 유지될 수 있다.

따라서 매우 많은 문자열을 무분별하게 Intern()하면
오히려 메모리를 오래 점유하게 된다.

그래서 Intern()은 특별한 상황이 아니라면 직접 사용할 필요가 없다.
 
## String Pool과 Immutable의 관계

지금까지 내용을 정리하면

```
String이 Immutable

↓

객체를 안전하게 공유 가능

↓

String Pool 사용 가능

↓

메모리 절약

↓

GC 부담 감소
```

즉, String Pool은 Immutable이 있기 때문에 존재할 수 있는 최적화이다.
 
## 마무리
String Pool은 동일한 문자열을 하나만 생성하여 여러 변수가 함께 사용하는 메모리 최적화 기법이다. 이 최적화가 가능한 이유는 String이 Immutable이기 때문이다.

덕분에 메모리 사용량을 줄이고 GC의 부담도 감소시킬 수 있다.
하지만 문자열을 반복해서 이어 붙이는 작업에서는 새로운 문자열 객체가 계속 생성되므로 String Pool만으로는 해결되지 않는다.

다음 글에서는 이러한 문제를 해결하기 위해 등장한 **StringBuilder는 왜 필요할까?**를 알아보겠다.
 
## 핵심 정리

- String Pool은 동일한 문자열 리터럴을 하나만 생성하여 공유하는 기능이다.
- String이 Immutable이기 때문에 객체를 안전하게 공유할 수 있다.
- 같은 문자열 리터럴은 동일한 객체를 참조한다.
- new string()은 항상 새로운 객체를 생성한다.
- ==는 문자열 내용을 비교하고, ReferenceEquals()는 객체 참조를 비교한다.
- string.Intern()으로 런타임 문자열을 Pool에 등록할 수 있지만 일반적으로 사용할 일은 거의 없다.
- String Pool은 메모리 절약과 GC 부담 감소에 도움이 된다.
