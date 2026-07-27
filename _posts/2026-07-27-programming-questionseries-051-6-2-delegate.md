---
title: "[궁금시리즈] 6-2. Delegate는 내부적으로 어떻게 동작할까?"
excerpt: "C#"
categories:
  - Programming
tags:
  - CSharp
permalink: /programming/6-2-delegate/
toc: true
toc_sticky: true
date: 2026-07-27
last_modified_at: 2026-07-27
---

이전 글에서는 Delegate는

> 메서드를 저장하고 전달하는 기능

이라고 설명했다.

예를 들어

```cs
public delegate void MyDelegate();

MyDelegate del = Hello;

del();
```

이처럼 사용할 수 있다.
 
그런데 정말 메서드 자체가 변수 안에 저장되는 것일까?
 
사실 그렇지 않다

Delegate는 메서드를 직접 저장하는 것이 아니라,
**메서드를 호출하기 위한 정보를 담고 있는 객체**이다.
 
이번 글에서는 Delegate가 내부적으로 어떤 구조를 가지고 있는지 살펴보자.

---

## Delegate도 하나의 객체이다

많은 사람들이

```
MyDelegate del = Hello;
```

를 보면

```
del

↓

Hello 메서드
```

처럼 생각한다.
 
하지만 실제로는

```
del

↓

Delegate 객체

↓

Hello 메서드
```

이다.
 
즉,
Delegate는 메서드 자체가 아니라
메서드를 호출하기 위한 객체이다.

---

## Delegate는 무엇을 저장할까?

Delegate는 크게 두 가지 정보를 저장한다.

```
Target

+

Method
```

즉,

- 어떤 객체(Target)의
- 어떤 메서드(Method)를

호출해야 하는지를 기억한다.

---

## Static 메서드인 경우

다음 코드를 보자.

```cs
public static void Hello()
{
    Console.WriteLine("Hello");
}

MyDelegate del = Hello;
```

이 경우에는 호출 대상 객체가 없다.

따라서 Delegate 내부는

```
Target

↓

null

Method

↓

Hello()
```

가 된다.
 
즉,
메서드 정보만 저장하면 된다.

---

## 인스턴스 메서드인 경우

이번에는

```cs
public class Player
{
    public void Attack()
    {
    }
}
```

를 보자.

```cs
Player player = new();

MyDelegate del = player.Attack;
```

이번에는 누가 Attack을 실행해야 하는지가 중요하다.
 
Delegate는

```
Target

↓

player 객체

Method

↓

Attack()
```

를 저장한다.
 
그래서

```cs
del();
```

을 호출하면 실제로는

```cs
player.Attack();
```

이 실행된다.

---

## Invoke는 무엇일까?

Delegate를 실행할 때
 
보통

```
del();
```

처럼 사용한다.
 
하지만 사실은

```cs
del.Invoke();
```

를 호출하는 것과 같다.
 
즉,
컴파일러가

```
del();
```

를

```cs
del.Invoke();
```

로 바꾸어 준다.

---

## Invoke는 내부적으로 무엇을 할까?

Delegate 객체는 이미

```
Target

Method
```

를 알고 있다.
 
따라서 Invoke가 호출되면
개념적으로는

```
Target 확인

↓

Method 호출
```

을 수행한다.
 
예를 들어

```
Target

↓

player

Method

↓

Attack
```

이라면
 
결국

```cs
player.Attack();
```

을 실행하는 것이다.

---

## Delegate 객체는 언제 생성될까?

다음 코드를 보자.

```cs
MyDelegate del = Hello;
```

이 한 줄만 보면
단순한 대입처럼 보인다.
 
하지만 실제로는 Delegate 객체가 생성된다.
 
개념적으로는

```cs
MyDelegate del = new MyDelegate(Hello);
```

와 비슷하게 동작한다.
 
즉,
Delegate 역시 Heap에 생성되는 객체이다.

---

메모리 구조는 어떻게 될까?

예를 들어

```cs
Player player = new();

MyDelegate del = player.Attack;
```

라면
 
메모리는 개념적으로

```
Stack
-----------------------

player

↓

Player 객체

del

↓

Delegate 객체

-----------------------

Heap

Player 객체

Delegate 객체

Target → Player 객체

Method → Attack()
```

와 같은 구조가 된다.
 
Delegate는 Target과 Method를 함께 저장하여
나중에 정확한 메서드를 호출할 수 있다.

---

## Delegate는 함수 포인터와 무엇이 다를까?

C나 C++에서는
함수 포인터를 사용할 수 있다.
 
하지만 함수 포인터는

```
메서드 주소
```

만 저장한다.
 
반면 Delegate는

```
Target

+

Method

+

형식 안전성(Type Safety)
```

을 제공한다.
 
즉,
Delegate는 객체지향 언어에 맞게
안전하고 확장 가능한 구조로 설계되어 있다.

---

## 실제 .NET에서는 어떻게 구현될까?

Delegate는 내부적으로 System.Delegate를 기반으로 동작하며,
MulticastDelegate를 상속받는 형태로 생성된다.
 
컴파일러가

```cs
public delegate void MyDelegate();
```

를 만나면
 
개념적으로는 다음과 비슷한 클래스를 생성한다.

```cs
public sealed class MyDelegate : MulticastDelegate
{
    public void Invoke();
}
```

물론 실제 구현은 런타임이 담당하며 훨씬 복잡하지만,
개발자가 이해하기에는 **Delegate도 결국 특별한 클래스 하나가 생성되는 것**이라고 생각하면 된다.

---

## 왜 굳이 객체일까?

만약 Delegate가
단순히 메서드 주소만 저장했다면
인스턴스 메서드는 호출할 수 없다.
 
예를 들어

```
player1.Attack();
```

과

```
player2.Attack();
```

은 같은 Attack 메서드라도
대상 객체가 다르다.
 
그래서
Delegate는 메서드뿐 아니라
호출 대상(Target)도 함께 저장하도록 설계되었다.
 
이 구조 덕분에 객체지향 언어에서도
메서드를 자유롭게 전달할 수 있다.

---

## 실무에서 자주 하는 오해

가장 흔한 오해는

> Delegate는 함수 포인터이다.

라는 것이다.

Delegate는 함수 포인터보다 훨씬 많은 정보를 가진다.

- 호출 대상 객체(Target)
- 호출할 메서드(Method)
- 형식 안전성(Type Safety)

이 정보를 바탕으로 런타임이 안전하게 메서드를 호출한다.
또 하나의 오해는

> Delegate는 메서드 자체를 저장한다.

라는 것이다.
 
실제로는 메서드 자체가 아니라 **메서드를 호출하기 위한 정보**를 저장하는 객체이다.

---

## 마무리

Delegate는 단순히 메서드 주소를 저장하는 기능이 아니라, **호출 대상 객체와 메서드 정보를 함께 보관하는 객체**이다.
이러한 구조 덕분에 정적 메서드와 인스턴스 메서드를 동일한 방식으로 다룰 수 있으며, 메서드를 안전하게 전달하고 나중에 실행할 수 있다.
 
또한 Delegate가 객체라는 사실은 이후에 살펴볼 Multicast Delegate, 람다식, 이벤트의 동작 원리를 이해하는 중요한 기반이 된다.
 
다음 글에서는 **Delegate 하나에 여러 메서드를 등록할 수 있는 Multicast Delegate**를 살펴보며 +=와 -= 연산자가 내부적으로 어떻게 동작하는지 알아보겠다.

---

## 핵심 정리

Delegate는 메서드 자체가 아니라 메서드를 호출하기 위한 객체이다.
Delegate는 Target과 Method 정보를 함께 저장한다.
정적 메서드는 Target이 null이며 Method만 저장한다.
인스턴스 메서드는 Target 객체와 Method를 함께 저장한다.
del()은 내부적으로 del.Invoke()를 호출하는 것과 같다.
Delegate는 System.MulticastDelegate를 기반으로 하는 특별한 클래스이다.
Delegate는 함수 포인터보다 안전하고 객체지향적인 구조를 제공한다.
출처: https://b-note.tistory.com/254 [기록:티스토리]
