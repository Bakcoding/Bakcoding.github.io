---
title: "[궁금시리즈] 2-3. 값 전달(Pass by Value)과 참조 전달(Pass by Reference)은 무엇이 다를까?"
excerpt: "C#"
categories:
  - Programming
tags:
  - CSharp
permalink: /programming/2-3-pass-by-value-pass-by-reference/
toc: true
toc_sticky: true
date: 2026-07-23
last_modified_at: 2026-07-23
---

C#을 공부하다 보면 다음과 같은 말을 자주 듣는다.

> "값 타입은 값으로 전달되고, 참조 타입은 참조로 전달된다."

이 말은 절반만 맞는 설명이다.
많은 개발자가 여기서

> "class는 메서드에 전달하면 원본이 넘어간다."

라고 오해한다.

하지만 실제 C#은 **기본적으로 모든 매개변수를 값으로 전달(Pass by Value)**한다.

그렇다면 왜 참조 타입은 원본이 변경되는 것처럼 보일까?
이번 글에서는 C#의 매개변수 전달 방식과 ref, out, in 키워드의 역할까지 함께 알아보자.

---

## 먼저 결론부터

C#에서

> 기본 매개변수 전달 방식은 모두 Pass by Value이다.

즉, 다음 두 코드 모두

```cs
void Method(int value)
```

```cs
void Method(Player player)
```

기본적으로는 **Pass by Value**이다.

다만 복사되는 대상이 다를 뿐이다.

---

## 값 타입 

전달 다음 코드를 보자.

```cs
void Increase(int number)
{
    number++;
}

int value = 10;

Increase(value);

Console.WriteLine(value);
```

결과

```
10
```

왜 그럴까?

메모리는

```
호출 전

value

10
```
↓
메서드 호출

```
Increase()

number

10
```

↓
number++

```
number

11
```

↓
메서드 종료

```
value

10
```

메서드 안에서 수정한 것은
복사본이었다.

---

## 참조 타입 전달

이번에는

```cs
class Player
{
    public int Hp = 100;
}
```

```cs
void Damage(Player player)
{
    player.Hp -= 20;
}
```

```cs
Player p = new Player();

Damage(p);
```

결과

```cs
Hp = 80
```

이번에는 원본이 변경되었다.

왜일까?

---

## 실제로 복사되는 것은 참조값이다

메모리를 보면

```
Stack

p

↓

0x100
```

메서드 호출 시

```
player

↓

0x100
```

이 복사된다.

즉, 복사된 것은 객체가 아니라
참조(주소)이다.

```
p

0x100

↓

복사

↓

player

0x100
```

둘 다 같은 객체를 바라본다.

그래서

```cs
player.Hp = 50;
```

하면 원본 객체가 변경된다.

---

## 그렇다면 객체를 새로 만들면?

이번 코드를 보자.

```cs
void Reset(Player player)
{
    player = new Player();
}
```

```cs
Player p = new Player();

Reset(p);
```

결과는

```
원본 그대로
```

이다.

왜냐하면 메서드 안에서 변경한 것은
복사된 참조이다.

메모리는

```
호출 전

p

↓

Player A
```

↓
복사

```
player

↓

Player A
```

↓
새 객체 생성

```
player

↓

Player B
```

하지만

```
p

↓

Player A
```

는 그대로이다.

즉, 참조 자체를 바꾸는 것은
원본에 영향을 주지 않는다.

---

## Pass by Reference란?

그렇다면 원본 변수 자체를 변경하려면 
어떻게 해야 할까?

바로

```
ref
```

를 사용한다.

예를 들어

```cs
void Reset(ref Player player)
{
    player = new Player();
}
```

호출

```
Reset(ref p);
```

이번에는 메서드 안에서

```cs
player = new Player();
```

를 수행하면 원본 변수도 변경된다.

---

## ref는 무엇이 다를까?

**기본 전달**

```
복사

p

↓

0x100

↓

player

0x100
```

---

**ref 전달**

```
player

↓

p 자체를 참조
```

즉, 복사본이 아니라
원본 변수 자체를 다룬다.

---

## out 키워드

out도 Pass by Reference이다.

하지만 반드시 메서드 안에서 
값을 대입해야 한다.

예를 들어

```cs
void GetValue(out int value)
{
    value = 100;
}
```

사용

```cs
int number;

GetValue(out number);
```

결과

```
100
```

---

## ref와 out 차이

| ref | out |
| --- | --- |
| 전달 전에 초기화 필요 | 초기화 불필요 |
| 읽기 가능 | 읽기 전 반드시 대입 |
| 입력 + 출력 | 출력 전용 |

## in 키워드

C# 7.2부터는

```
in
```

도 등장했다.

```cs
void Print(in BigStruct data)
{
}
```

이는

> 복사는 하지 않고 읽기만 하겠다.

라는 의미이다.

큰 구조체를 전달할 때
불필요한 복사를 줄일 수 있다.

---

## 언제 ref를 사용할까?

대표적인 예

- 큰 구조체 전달
- Swap 구현
- 성능 최적화
- 여러 값을 수정해야 하는 경우

하지만 일반적인 코드에서는
과도한 ref 사용은 오히려 가독성을 떨어뜨릴 수 있다.

---

## 자주 하는 오해

다음 문장은 틀렸다.

> class는 참조로 전달된다.

정확한 표현은

> class의 참조값이 값으로 전달된다.

즉,

```
객체

X

참조값

O
```

가 복사되는 것이다.

이 차이를 이해하면 C#의 매개변수 전달 방식을 
거의 완벽하게 이해한 것이다.

---

## 마무리
C#은 기본적으로 모든 매개변수를 **Pass by Value**방식으로 전달한다.
값 타입은 값이 복사되고, 참조 타입은 참조값이 복사된다. 그래서 참조 타입은 메서드 안에서 객체의 내용을 변경하면 원본에도 영향이 있지만, 참조 자체를 다른 객체로 바꾸는 것은 원본 변수에 영향을 주지 않는다.

원본 변수 자체를 변경해야 하는 경우에는 ref, out, in 키워드를 사용하며, 각각 목적과 제약이 다르다.

이 개념은 이후 구조체 설계와 성능 최적화, 메서드 설계에서도 매우 중요한 기반이 된다.
다음 글에서는 **GC(Garbage Collector)는 어떻게 메모리를 관리할까?**를 알아보겠다.

---

## 핵심 정리

- C#의 기본 매개변수 전달 방식은 모두 Pass by Value이다.
- 값 타입은 값이 복사된다.
- 참조 타입은 객체가 아니라 참조값(주소)이 복사된다.
 참조 타입의 객체를 수정하면 원본에도 영향을 준다.
- 참조를 다른 객체로 변경해도 원본 변수는 변경되지 않는다.
- ref, out, in은 Pass by Reference 방식이다.
- ref는 원본 변수 자체를 수정할 수 있다.
- out은 출력 전용이며 반드시 값을 대입해야 한다.
- in은 읽기 전용 참조 전달로 큰 구조체 전달 시 복사를 줄일 수 있다.
