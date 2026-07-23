---
title: "[궁금시리즈] 1-6. String은 왜 Immutable일까?"
excerpt: "C#"
categories:
  - Programming
tags:
  - CSharp
permalink: /programming/1-6/
toc: true
toc_sticky: true
date: 2026-07-23
last_modified_at: 2026-07-23
---

C#에서 문자열(String)은 가장 많이 사용하는 타입 중 하나이다.
하지만 String에는 다른 클래스와 다른 매우 중요한 특징이 있다.
바로 **Immutable(불변 객체)** 이라는 점이다.
많은 개발자가 다음과 같은 코드를 보고

```cs
string text = "Hello";

text += " World";
```

문자열이 수정되었다고 생각한다.

하지만 실제로는 그렇지 않다.

> String은 한 번 생성되면 내부 데이터를 절대로 변경하지 않는다.

그렇다면 왜 이렇게 설계했을까?

이번 글에서는 String이 Immutable인 이유와 그 장점에 대해 알아보자.
 
## Immutable이란?
Immutable(불변 객체)이란

> 객체가 생성된 이후에는 내부 상태를 변경할 수 없는 객체를 의미한다.

예를 들어

```cs
string text = "Hello";
```

여기서 생성된 "Hello" 문자열은 이후 절대 수정되지 않는다.
만약 다른 문자열이 필요하다면
기존 문자열을 수정하는 것이 아니라
**새로운 문자열 객체를 생성한다.**
 
## 문자열이 수정되는 것처럼 보이는 이유

다음 코드를 보자.

```cs
string text = "Hello";

text += " World";
```

겉으로 보기에는

```
Hello
↓

Hello World
```

처럼 기존 문자열이 수정된 것처럼 보인다.

하지만 실제 내부에서는 다음과 같은 일이 발생한다.

```
Heap

"Hello"

↓

새로운 문자열 생성

"Hello World"

↓

text가 새로운 문자열을 참조
```

즉, 기존 "Hello"는 그대로 남아 있고,
새로운 "Hello World" 객체가 생성된다.
 
## 실제 메모리 흐름

다음 코드를 실행해 보자.

```cs
string text = "Hello";

string copy = text;

text += " World";
```

메모리에서는 다음과 같이 동작한다.

**1단계**

```
text ───┐
         ▼
      "Hello"
         ▲
copy ────┘
```

두 변수 모두 같은 문자열을 참조한다.
 
**2단계**

```cs
text += " World";
```

실제로는

```cs
text = text + " World";
```

와 동일하다.

새로운 문자열이 생성된다.

```
copy ───────▶ "Hello"

text ───────▶ "Hello World"
```

즉, copy는 여전히 "Hello"를 참조한다.

기존 문자열은 전혀 수정되지 않았다.
 
## 왜 이렇게 설계했을까?

String을 Immutable로 만든 이유는 여러 가지가 있다.
 
**1. 안전하게 공유할 수 있다.**
같은 문자열을 여러 변수가 참조해도 문제가 발생하지 않는다.

```cs
string a = "Hello";
string b = a;
```

만약 String이 변경 가능했다면

```cs
a[0] = 'X';
```

처럼 수정했을 때

```
b

↓

"Xello"
```

까지 함께 변경된다.

이는 매우 위험한 동작이다.
Immutable이라면 절대 이런 일이 발생하지 않는다.
 
**2. String Pool을 사용할 수 있다.**
다음 코드를 보자.

```cs
string a = "Hello";
string b = "Hello";
```

Immutable이기 때문에 두 변수는
같은 문자열 객체를 함께 사용할 수 있다.

```
a ───┐
      ▼
   "Hello"
      ▲
b ────┘
```

이러한 최적화를 String Pool이라고 한다.

다음 글에서 자세히 알아본다.
 
**3. 멀티스레드 환경에서 안전하다.**
여러 스레드가 같은 문자열을 동시에 사용하더라도
누군가 문자열을 변경할 수 없다.

즉, 동기화(lock) 없이도 안전하게 공유할 수 있다.
Immutable 객체가 멀티스레드 환경에서 자주 사용되는 이유이기도 하다.
 
**4. Hash 값을 캐싱할 수 있다.**
Dictionary는 문자열의 HashCode를 자주 사용한다.
만약 문자열이 변경 가능하다면
HashCode도 계속 변경되어야 한다.

하지만 Immutable이므로
한 번 계산한 HashCode를 재사용할 수 있다.

덕분에 Dictionary 성능도 향상된다.
 
## Immutable의 단점
물론 단점도 존재한다.
문자열을 수정할 때마다
새로운 객체가 생성된다.

예를 들어

```cs
string text = "";

for (int i = 0; i < 10000; i++)
{
    text += i;
}
```

매 반복마다

```
새 문자열 생성

↓

기존 문자열 버림

↓

새 문자열 생성

↓

기존 문자열 버림
```

이라는 작업이 반복된다.

즉, 엄청난 양의 객체가 생성된다.
이러한 객체들은 결국 GC의 대상이 된다.

그래서 문자열을 자주 수정하는 경우에는 성능이 크게 떨어질 수 있다.
 
## 그래서 StringBuilder가 등장했다

문자열을 계속 수정해야 하는 상황에서는
Immutable은 오히려 단점이 된다.
이를 해결하기 위해 등장한 것이
**StringBuilder**이다.
StringBuilder는
기존 버퍼를 재사용하면서 문자열을 수정하기 때문에
새로운 문자열 객체를 계속 생성하지 않는다.
이에 대해서는 이후 별도의 글에서 자세히 알아본다.
 
## String은 정말 절대 변경되지 않을까?
그렇다.

```cs
string text = "Hello";
```

라는 문자열 객체는 프로그램이 끝날 때까지
혹은 GC가 회수할 때까지 내부 데이터가 절대 변경되지 않는다.

새로운 문자열이 필요하면 항상 새로운 객체가 생성된다.
이것이 Immutable의 핵심이다.
 
## 마무리
String이 Immutable인 이유는 단순히 "수정을 막기 위해서"가 아니다.
객체를 안전하게 공유하고, String Pool을 사용할 수 있으며, 멀티스레드 환경에서도 안정적으로 동작하고, HashCode를 효율적으로 관리하기 위해 선택된 설계이다.

물론 문자열을 자주 수정하는 상황에서는 새로운 객체가 계속 생성되는 단점도 있다.

이러한 단점을 해결하기 위해 다음 글에서 살펴볼 **String Pool**과 **StringBuilder** 같은 최적화 기법이 함께 등장하게 되었다.
 
## 핵심 정리

- String은 Immutable(불변 객체)이다.
- 문자열을 수정하는 것이 아니라 새로운 문자열 객체를 생성한다.
- 여러 변수가 하나의 문자열을 안전하게 공유할 수 있다.
- Immutable 덕분에 String Pool이 가능하다.
- HashCode를 캐싱할 수 있어 Dictionary 등의 성능 향상에 도움이 된다.
- 문자열을 반복해서 수정하면 많은 객체가 생성되어 성능이 저하될 수 있다.
- 문자열을 자주 변경하는 경우에는 StringBuilder를 사용하는 것이 좋다.
