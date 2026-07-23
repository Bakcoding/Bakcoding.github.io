---
title: "[궁금시리즈] 1-9. Boxing과 Unboxing은 왜 발생할까?"
excerpt: "C#"
categories:
  - Programming
tags:
  - CSharp
permalink: /programming/1-9-boxing-unboxing/
toc: true
toc_sticky: true
date: 2026-07-23
last_modified_at: 2026-07-23
---

C#을 공부하다 보면 다음과 같은 코드를 볼 수 있다.

```cs
int number = 10;

object obj = number;
```

겉으로 보기에는 단순히 int를 object 변수에 저장한 것처럼 보인다.
하지만 실제로는 단순한 대입이 아니다.
이 과정에서는 **Heap에 새로운 객체가 생성**된다.
이러한 과정을 **Boxing(Boxing)**이라고 한다.
반대로 다시 원래 타입으로 꺼내는 과정을 **Unboxing(Unboxing)**이라고 한다.
이번 글에서는 Boxing과 Unboxing이 왜 존재하며, 내부적으로 어떻게 동작하는지 알아보자.

---

## 먼저 Value Type과 Reference Type을 알아야 한다
Boxing을 이해하려면 먼저 값 타입(Value Type)과 참조 타입(Reference Type)의 차이를 알아야 한다.

예를 들어

```cs
int number = 10;
```

int는 **Value Type**이다.
값 자체를 변수 안에 저장한다.

반면

```cs
object obj = new object();
```

object는 **Reference Type**이다.
변수에는 객체의 주소(참조)가 저장된다.

즉,

| Value Type | Reference Type |
| ----------- | ------------- |
| 값 자체 저장 | 객체의 참조 저장 |
| 대부분 Stack에 저장 | 객체는 Heap에 생성 |
| 복사 시 값 복사 | 복사 시 참조 복사 |

이처럼 두 타입은 메모리 구조 자체가 다르다.

---

## Boxing이란?

Boxing은

> Value Type을 Reference Type으로 변환하는 과정이다.

예를 들어

```cs
int number = 10;

object obj = number;
```

겉보기에는 단순한 대입처럼 보이지만,
실제로는 다음과 같은 과정이 수행된다.

```
Stack

number
┌─────┐
│ 10  │
└─────┘
```
↓
Heap에 새로운 객체 생성

```
Stack                     Heap

number                    ┌──────────────┐
┌─────┐                   │ System.Int32 │
│ 10  │                   │      10      │
└─────┘                   └──────────────┘
                                ▲
                                │
                           obj ─┘
```

즉, Heap에 새로운 객체가 생성되고,
값이 복사된다.

이 과정이 바로 Boxing이다.

---

## 왜 Boxing이라는 이름일까?

Box(Box)는 상자를 의미한다.

Value Type인 10을 Reference Type 객체 안에 넣어
Heap으로 옮긴다고 생각하면 이해하기 쉽다.

즉,

```
10

↓

[ 10 ]

↓

Heap 객체
```

처럼 값을 객체(Box) 안에 담는 과정이다.

---

## Unboxing이란?

Unboxing은

> Boxing된 객체에서 다시 Value Type을 꺼내는 과정이다.

예를 들어

```cs
object obj = 10;

int number = (int)obj;
```

실제로는

```
Heap

┌──────────────┐
│ System.Int32 │
│      10      │
└──────────────┘
```

↓
값 복사
↓

```
Stack

number

10
```

이 된다.

즉, Heap 객체 안의 값을 다시 Value Type으로 복사하는 과정이다.

---

## Unboxing에는 형변환이 필요한 이유

다음 코드를 보자.

```cs
object obj = 10;
```

컴파일러는 obj가 실제 어떤 타입인지 모른다.

왜냐하면

```cs
object obj = 10;

obj = "Hello";

obj = DateTime.Now;
```

모두 가능하기 때문이다.

따라서

```cs
int number = obj;
```

는 컴파일 오류가 발생한다.

반드시

```cs
int number = (int)obj;
```

처럼 실제 타입을 명시해야 한다.

## 잘못된 Unboxing

다음 코드는 어떻게 될까?

```cs
object obj = 10;

long value = (long)obj;
```

컴파일은 된다.

하지만 실행하면

```
InvalidCastException
```

이 발생한다.

왜냐하면 Heap 안에는

```cs
System.Int32
```

가 들어있기 때문이다.

Unboxing은 **실제 저장된 타입과 정확히 일치해야 한다.**

즉,

```
Int32

↓

Int32

O
```

하지만

```
Int32

↓

Int64

X
```

이다.

---

## Boxing은 왜 느릴까?
Boxing이 발생하면
다음 작업이 수행된다.

1. Heap에 객체 생성
2. 값 복사
3. 객체 헤더 생성
4. GC 관리 대상 등록

즉,
단순한 대입보다 훨씬 많은 작업이 수행된다.
특히 반복문에서 발생하면 성능에 영향을 줄 수 있다.

예를 들어

```cs
for (int i = 0; i < 1000000; i++)
{
    object obj = i;
}
```

매 반복마다
새로운 객체가 생성된다.

결국 GC가 회수해야 하는 객체도 크게 증가한다.

---

## Boxing은 언제 발생할까?

대표적인 예시는 다음과 같다.

**object에 대입**

```cs
int value = 10;

object obj = value;
```

---

**인터페이스에 대입**

```
IComparable comparable = 10;
```

int는 IComparable을 구현하고 있지만
인터페이스는 참조 타입이므로 Boxing이 발생한다.

**ArrayList 사용**

```cs
ArrayList list = new ArrayList();

list.Add(10);
```

ArrayList는 object를 저장하기 때문에
Boxing이 발생한다.

이 때문에 Generic이 등장하게 된다.

---

## Generic은 왜 Boxing을 해결할까?

다음 코드를 보자.

```cs
List<int> list = new List<int>();

list.Add(10);
```

여기서는 Boxing이 발생하지 않는다.

왜냐하면 List<int>는
처음부터 int를 저장하도록 만들어졌기 때문이다.

즉, object로 변환할 필요가 없다.
이것이 Generic이 성능 향상에 큰 역할을 하는 이유 중 하나이다.

---

## Boxing을 피해야 할까?

무조건 피해야 하는 것은 아니다.

가끔 발생하는 Boxing은 큰 문제가 되지 않는다.

하지만 다음과 같은 상황에서는 주의해야 한다.

- 반복문 안에서 발생
- 게임 메인 루프(Update)
- 실시간 렌더링
- 서버 요청 처리
- 대량 데이터 처리

이러한 코드에서는 불필요한 Boxing이 
성능 저하와 GC 증가의 원인이 될 수 있다.

## 마무리
Boxing은 값 타입을 참조 타입으로 변환하기 위해 Heap에 새로운 객체를 생성하는 과정이다.
반대로 Unboxing은 Heap에 저장된 값을 다시 값 타입으로 꺼내오는 과정이다.

이 기능은 값 타입과 참조 타입을 함께 사용할 수 있도록 해주는 중요한 메커니즘이지만, 객체 생성과 GC 부담이 발생하기 때문에 성능이 중요한 코드에서는 주의해야 한다.

다음 대분류인 **메모리 관리**에서는 이러한 내용과 연결하여 **Stack과 Heap은 무엇이며 각각 어떤 역할을 하는지**부터 자세히 살펴보겠다.

---

## 핵심 정리

- Boxing은 Value Type을 Reference Type으로 변환하는 과정이다.
- Boxing 시 Heap에 새로운 객체가 생성된다.
- Unboxing은 Heap 객체에서 값을 다시 Value Type으로 꺼내오는 과정이다.
- Unboxing은 실제 저장된 타입과 정확히 일치해야 한다.
- Boxing은 객체 생성과 GC 부담을 증가시킨다.
- Generic(List<int> 등)은 Boxing을 방지할 수 있다.
- 성능이 중요한 코드에서는 불필요한 Boxing을 줄이는 것이 좋다.
