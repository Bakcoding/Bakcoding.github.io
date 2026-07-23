---
title: "[궁금시리즈] 2-1. Stack과 Heap은 무엇일까?"
excerpt: "C#"
categories:
  - Programming
tags:
  - CSharp
permalink: /programming/2-1-stack-heap/
toc: true
toc_sticky: true
date: 2026-07-23
last_modified_at: 2026-07-23
---

C#을 공부하다 보면 가장 많이 듣는 말이 있다.

> "값 타입은 Stack에 저장되고 참조 타입은 Heap에 저장된다."

이 설명은 입문 단계에서는 이해하기 쉽지만, 실제로는 **정확하지 않은 표현**이다.

예를 들어

```cs
class Player
{
    public int Hp = 100;
}
```

여기서 Hp는 int이다.

int는 Value Type인데,
정말 Stack에 저장될까?

정답은 아니다.

Hp는 Heap에 생성된 Player 객체 내부에 저장된다.

즉, 

> 값 타입인지 참조 타입인지와 Stack/Heap에 저장되는 위치는 항상 같은 개념이 아니다.

이번 글에서는 Stack과 Heap이 무엇인지, 각각 어떤 역할을 하는지 알아보자.

---

## 메모리는 왜 나누어 사용할까?

프로그램은 실행되는 동안

- 지역 변수
- 객체
- 함수 호출 정보
- 배열
- 문자열

등 다양한 데이터를 저장해야 한다.

모든 데이터를 하나의 공간에서 관리하면
속도도 느려지고 관리도 어려워진다.

그래서 운영체제와 .NET은 메모리를 용도에 따라 크게 두 공간으로 나누어 사용한다.

- Stack
- Heap

---

## Stack이란?

Stack은

> 메서드 실행에 필요한 임시 데이터를 저장하는 메모리 영역이다.

대표적으로 저장되는 것은

- 지역 변수(Local Variable)
- 메서드 매개변수(Parameter)
- 반환 주소(Return Address)
- 메서드 호출 정보(Stack Frame)

이다.

예를 들어

```cs
void Print()
{
    int number = 10;
}
```

메서드가 실행되면

```
Stack

┌─────────────┐
│ number = 10 │
└─────────────┘
```

가 생성된다.

메서드가 종료되면

```
Stack

(비워짐)
```

즉, 자동으로 제거된다.

---

## Stack의 특징

Stack은 이름 그대로
**접시를 쌓는 구조(Stack, LIFO)**를 가진다.

```
Push

┌──────┐
│ C    │
├──────┤
│ B    │
├──────┤
│ A    │
└──────┘

↓

Pop

C

↓

B

↓

A
```

마지막에 들어온 것이 가장 먼저 나간다.

이를

> LIFO(Last In First Out)

이라고 한다.

---

## Heap이란?

Heap은

> 프로그램에서 생성되는 객체를 저장하는 메모리 영역이다.

예를 들어

```cs
Player player = new Player();
```

실제로는

```
Stack                Heap

player ─────────▶ Player 객체
```

가 된다.

Stack에는 객체 자체가 아니라
객체를 가리키는 참조만 저장된다.

실제 객체는 Heap에 생성된다.

---

## Heap의 특징

Heap은 Stack과 다르게 생성과 제거 시점이 일정하지 않다.

예를 들어

```cs
Player player = new Player();
```

객체를 생성해도 언제 삭제될지는 알 수 없다.
더 이상 참조하는 변수가 없어지면 
나중에

Garbage Collector(GC) 가 회수한다.

즉,

```
new

↓

Heap 생성

↓

사용

↓

참조 없음

↓

GC 회수
```

라는 흐름으로 동작한다.

---

## Stack과 Heap의 가장 큰 차이

| Stack | Heap |
| ----- | ---- |
| 메서드 실행 정보 저장 | 객체 저장 |
| 자동 생성/자동 제거 | GC가 관리 |
| 매우 빠름 | Stack보다 느림 |
| 크기가 상대적으로 작음 | 상대적으로 큼 |
| LIFO 구조 | 자유로운 메모리 관리 |

---

## Value Type은 항상 Stack에 있을까?

많은 사람들이 가장 많이 오해하는 부분이다.

다음 코드를 보자.

```cs
class Player
{
    public int Hp = 100;
}

Player player = new Player();
```

메모리는

```
Stack

player

↓

Heap

Player
┌───────────┐
│ Hp = 100  │
└───────────┘
```

가 된다.

즉, Hp는 Value Type이지만
Heap에 존재한다.

왜냐하면 Player 객체 자체가 Heap에 있기 때문이다.

Reference Type은 항상 Heap에 있을까?

이번에는 다음 코드를 보자.

```cs
Player player = null;
```

여기서

```
Stack

player = null
```

이다.

즉, 참조 변수는 Stack에 있다.

Heap에는 아무 객체도 생성되지 않았다.

따라서 

> Reference Type 변수는 Stack에 존재하고,
> 실제 객체는 Heap에 존재한다.

---

## 배열은 어디에 저장될까?

```cs
int[] numbers = new int[3];
```

메모리는 다음과 같다.

```
Stack

numbers

↓

Heap

┌──────────────┐
│ 0  │ 0  │  0 │
└──────────────┘
```

배열은 Value Type 배열이라도
항상 객체이다.

따라서 Heap에 생성된다.

---

## 구조체는 어떨까?

```cs
struct Point
{
    public int X;
    public int Y;
}
```

```cs
Point p = new Point();
```

지역 변수라면

```
Stack

Point
┌──────┐
│ X │ Y │
└──────┘
```

가 된다.

하지만

```cs
class Player
{
    public Point Position;
}
```

이라면

```
Heap

Player

┌──────────────┐
│ Position     │
│ X            │
│ Y            │
└──────────────┘
```

가 된다.

즉, 구조체 역시 어디에 포함되어 있는지에 따라 저장 위치가 달라진다.

---

## Stack이 빠른 이유

Stack은 메모리를 순서대로 쌓기만 하면 된다.

```
Push

↓

주소 증가
```

삭제도

```
Pop

↓

주소 감소
```

만 하면 끝난다.

반면 Heap은 
빈 공간을 찾고, 객체를 생성하고, GC가 관리해야 한다.

그래서 상대적으로 더 많은 작업이 필요하다.

## 마무리
Stack과 Heap은 데이터를 저장하는 두 가지 메모리 영역이지만, 역할이 완전히 다르다.
Stack은 메서드 실행에 필요한 임시 데이터를 빠르게 관리하고, Heap은 프로그램에서 생성되는 객체를 저장하며 GC가 수명을 관리한다.

특히 많이 알려진 **"값 타입은 Stack, 참조 타입은 Heap"**이라는 문장은 단순화된 설명일 뿐이다.
실제로는 **객체가 어디에 존재하는지에 따라 값 타입도 Heap에 저장될 수 있으며,** 참조 변수 자체는 Stack에 저장된다.

이 차이를 이해하면 이후 **GC, Boxing, 메모리 최적화** 같은 개념도 훨씬 쉽게 이해할 수 있다.

---

## 핵심 정리

- Stack은 메서드 실행에 필요한 데이터를 저장하는 메모리 영역이다.
- Heap은 객체를 저장하는 메모리 영역이다.
- Stack은 메서드 종료와 함께 자동으로 정리된다.
- Heap은 GC가 더 이상 참조되지 않는 객체를 회수한다.
- 참조 변수는 Stack에 저장되고 실제 객체는 Heap에 저장된다.
- 값 타입도 Heap 객체의 필드라면 Heap에 저장된다.
- "값 타입은 Stack, 참조 타입은 Heap"은 입문용 단순화 표현일 뿐 정확한 설명은 아니다.
