---
title: "[궁금시리즈] 2-2. 값 타입(Value Type)과 참조 타입(Reference Type)의 차이"
excerpt: "C#"
categories:
  - Programming
tags:
  - CSharp
permalink: /programming/2-2-value-type-reference-type/
toc: true
toc_sticky: true
date: 2026-07-23
last_modified_at: 2026-07-23
---

C#을 처음 배우면 가장 먼저 접하는 개념 중 하나가 **값 타입(Value Type)**과 **참조 타입(Reference Type)**이다.

많은 입문서에서는 다음처럼 설명한다.

> 값 타입은 Stack에 저장된다.
> 참조 타입은 Heap에 저장된다.

하지만 이전 글에서 살펴봤듯이 이 설명은 정확하지 않다.
값 타입과 참조 타입의 핵심 차이는 **저장 위치**가 아니라 **복사 방식과 메모리 관리 방식**에 있다.

이번 글에서는 두 타입의 진짜 차이를 알아보자.

---

## 값 타입(Value Type)이란?

값 타입은

> 데이터 자체를 변수에 저장하는 타입이다.

대표적인 값 타입은 다음과 같다.

- bool
- byte
- char
- int
- long
- float
- double
- decimal
- enum
- struct

예를 들어

```cs
int a = 10;
int b = a;
```

메모리는 다음과 같다.

```
a : 10

↓

복사

↓

b : 10
```

즉, b에는 a의 값이 그대로 복사된다.

---

## 값을 변경하면?

```cs
int a = 10;
int b = a;

b = 20;
```

결과는

```cs
a = 10

b = 20
```

이다.

왜냐하면 둘은 완전히 독립된 값을 가지고 있기 때문이다.

---

## 참조 타입(Reference Type)이란?

참조 타입은

> 객체 자체가 아니라 객체의 위치(참조)를 저장하는 타입이다.

대표적인 참조 타입은

- class
- string
- array
- delegate
- interface
- record(class)

등이 있다.

예를 들어

```cs
class Player
{
    public int Hp = 100;
}
```
```cs
Player p1 = new Player();
Player p2 = p1;
```

메모리는

```
Stack

p1 ───┐
       │
p2 ────┘

↓

Heap

Player

Hp = 100
```

이 된다.

객체는 하나뿐이다.

---

## 객체를 수정하면?

```cs
p2.Hp = 50;
```

결과는

```cs
p1.Hp == 50

p2.Hp == 50
```

이다.

왜냐하면 두 변수는 같은 객체를 참조하기 때문이다.
 
---

## 가장 큰 차이

값 타입

```
복사

↓

값 복사
```

참조 타입

```
복사

↓

주소 복사
```

즉, 복사의 대상이 다르다.
이것이 가장 중요한 차이이다.

---

## 메서드에 전달하면?

**값 타입**

```cs
void Increase(int value)
{
    value++;
}

int number = 10;

Increase(number);
```

결과

```cs
number = 10
```

왜냐하면

메서드에는 값이 복사되어 전달되기 때문이다.

---

**참조 타입**

```cs
void Damage(Player player)
{
    player.Hp -= 10;
}

Player player = new Player();

Damage(player);
```

결과

```cs
player.Hp = 90
```

참조가 복사되었지만 복사된 참조가 
같은 객체를 가리키므로 객체 내용이 변경된다.

---

## 그런데 참조 타입도 값처럼 복사된다?

여기서 헷갈리는 부분이 있다.
참조 타입도 사실은 **참조값(주소)**을 복사한다.

예를 들어

```cs
Player p1 = new Player();

Player p2 = p1;
```

실제로는

```
주소

0x100

↓

복사

↓

0x100
```

가 되는 것이다.

즉, 참조 타입도 복사가 일어나지만
복사되는 대상이 객체가 아니라 주소이다.

---

## String은 왜 특별할까?

String은 참조 타입이다.

하지만

```cs
string a = "Hello";

string b = a;

b += " World";
```

결과는

```cs
a = Hello

b = Hello World
```

이다.

마치 값 타입처럼 동작한다.
그 이유는 String이 Immutable 이기 때문이다.

새로운 문자열 객체가 생성되어
b만 새로운 객체를 참조하게 된다.

struct와 class의 차이
다음 두 타입을 비교해 보자.

```cs
struct Point
{
    public int X;
}
```

```cs
class Player
{
    public int Hp;
}
```

복사하면

```cs
Point p1 = new Point();

Point p2 = p1;
```
↓
독립적인 객체
 
반면

```cs
Player a = new Player();

Player b = a;
```
↓
같은 객체 공유
이 차이가 struct와 class를 구분하는 가장 큰 기준이다.

---

## 언제 값 타입을 사용할까?
다음 조건이라면
Value Type이 적합하다.

- 크기가 작다.
- 자주 생성된다.
- 독립적인 데이터이다.
- 불변 데이터이다.

예를 들어

- 좌표(Point)
- 색상(Color)
- 시간(TimeSpan)
- 숫자(Vector2Int)

등이 있다.

---

## 언제 참조 타입을 사용할까?
다음과 같은 경우이다.

- 데이터가 크다.
- 여러 곳에서 공유해야 한다.
- 수명이 길다.
- 객체 간 관계가 존재한다.

예를 들어

- Player
- Enemy
- Inventory
- Item
- Monster

등이다.

---

## 값 타입이 항상 빠를까?

꼭 그렇지는 않다.
값 타입은 복사 비용이 존재한다.

예를 들어

```cs
struct BigData
{
    public long A;
    public long B;
    public long C;
    public long D;
}
```

이러한 큰 구조체를 계속 복사하면
오히려 성능이 떨어질 수 있다.

그래서 구조체는 일반적으로 **작고 불변인 데이터**에 사용하는 것이 좋다.

---

## 마무리

값 타입과 참조 타입의 가장 큰 차이는 **데이터를 어떻게 복사하고 관리하는지**에 있다.
값 타입은 데이터를 직접 복사하기 때문에 서로 영향을 주지 않고, 참조 타입은 객체의 참조를 복사하기 때문에 여러 변수가 하나의 객체를 함께 사용할 수 있다.

또한 저장 위치(Stack/Heap)는 타입 자체가 아니라 **객체가 어디에 존재하는지에 따라 달라질 수 있다.** 이 개념을 이해하면 이후 구조체와 클래스의 차이, 메서드 호출 방식, 성능 최적화 등을 훨씬 쉽게 이해할 수 있다.

다음 글에서는 **메서드 호출 시 값 전달(Pass by Value)과 참조 전달(Pass by Reference)은 어떻게 다를까?**를 알아보겠다.

---

## 핵심 정리

- 값 타입은 데이터 자체를 저장한다.
- 참조 타입은 객체의 참조를 저장한다.
- 값 타입은 복사 시 값이 복사된다.
- 참조 타입은 복사 시 참조가 복사된다.
- 참조 타입 변수 여러 개가 하나의 객체를 공유할 수 있다.
- String은 참조 타입이지만 Immutable이라 값 타입처럼 보일 수 있다.
- 저장 위치(Stack/Heap)보다 복사 방식과 메모리 관리 방식이 더 중요한 차이이다.
