---
title: "[궁금시리즈] 6-3. Multicast Delegate란 무엇일까?"
excerpt: "C#"
categories:
  - Programming
tags:
  - CSharp
permalink: /programming/6-3-multicast-delegate/
toc: true
toc_sticky: true
date: 2026-07-27
last_modified_at: 2026-07-27
---

이전 글에서 Delegate는

> 메서드를 저장하고 전달하는 객체

라고 설명했다.

그런데 Delegate는 메서드를 하나만 저장할 수 있는 것이 아니다.

다음과 같이 여러 메서드를 등록할 수도 있다.

```cs
MyDelegate del = Hello;

del += World;
del += Bye;

del();
```

결과는

```
Hello
World
Bye
```

처럼 모든 메서드가 실행된다.
 
Delegate 하나가 어떻게 여러 메서드를 기억할 수 있는 것일까?

이번 글에서는 Multicast Delegate의 동작 원리를 살펴보자.

---

## Delegate 하나에 여러 메서드를 등록할 수 있다

다음 코드를 보자.

```cs
public delegate void MyDelegate();

void Hello()
{
    Console.WriteLine("Hello");
}

void World()
{
    Console.WriteLine("World");
}

MyDelegate del = Hello;

del += World;

del();
```

실행 결과는

```
Hello
World
```

이다.
 
처음 보는 사람이라면

> Delegate가 두 개가 된 건가?

라고 생각하기 쉽다.

하지만
Delegate는 여전히 하나이다.

---

## 왜 Multicast라고 부를까?

"Multi"
 
즉,
여러 개의 대상에게
호출(Call)을 전달한다는 의미이다.
 
개념적으로는

```
Delegate

↓

Hello()

↓

World()

↓

Bye()
```

처럼
하나의 Delegate가
여러 메서드를 순서대로 호출한다.

---

## 내부적으로는 Invocation List를 가진다

Delegate는 내부적으로
호출해야 할 메서드 목록을 관리한다.
 
이를 **Invocation List**
라고 부른다.

예를 들어

```
del += Hello;
del += World;
del += Bye;
```

라면
 
개념적으로는

```
Invocation List

1. Hello

2. World

3. Bye
```

를 저장하고 있다.
 
Invoke가 호출되면
이 목록을 앞에서부터 차례대로 실행한다.

---

## += 는 무엇을 하는 것일까?

많은 사람들이

```
del += Hello;
```

를 리스트에 추가하는 것으로 생각한다.

실제로는 조금 다르다.
 
Delegate는
**Immutable(불변 객체)**이다.
 
즉,
기존 Delegate를 수정하지 않는다.
 
대신 새로운 Delegate를 만들어 반환한다.
 
개념적으로는

```cs
del = Delegate.Combine(del, Hello);
```

와 비슷하게 동작한다.
 
즉,
새로운 Invocation List를 가진
Delegate 객체가 생성된다.

---

## -= 는 무엇을 할까?

삭제도
마찬가지이다.

```cs
del -= World;
```

는 개념적으로

```cs
del = Delegate.Remove(del, World);
```

와 비슷하게 동작한다.
 
즉,
기존 Delegate를 수정하지 않고
World가 제거된 새로운 Delegate를 만든다.

---

## 실행 순서는?

다음 코드를 보자.

```
del += A;
del += B;
del += C;
```

실행 결과는

```
A

B

C
```

이다.
 
항상
등록한 순서대로 실행된다.

---

## 반환값이 있다면?

이번에는

```cs
public delegate int Calc();
```

를 생각해 보자.

```
del += A;
del += B;
del += C;
```

모두 int를 반환한다.
 
그렇다면

```cs
int result = del();
```

의 결과는 무엇일까?
 
정답은
**마지막 메서드의 반환값**이다.
 
예를 들어

```
A()

↓

10

B()

↓

20

C()

↓

30
```

이라면

최종 결과는

```
30
```

이 된다.
 
그래서 반환값이 있는 Delegate를
Multicast로 사용하는 경우는
드물다.

---

## 중간에 예외가 발생하면?

다음 코드를 보자.

```cs
del += A;
del += B;
del += C;
```

그런데
B에서 예외가 발생했다.

```
A 실행

↓

B 실행

↓

Exception

↓

C 실행 안 됨
```

즉,
예외가 발생하면
이후 메서드는 실행되지 않는다.

---

## 실제 .NET에서는 어떻게 구현될까?

Delegate는 내부적으로 System.MulticastDelegate를 상속받는다.
 
이름 그대로 여러 메서드를 저장하는
기능을 기본적으로 제공한다.
 
컴파일러는

```
del += Hello;
```

를 만나면 내부적으로

```
Delegate.Combine(...)
```

을 호출하고,

```
del -= Hello;
```

를 만나면

```
Delegate.Remove(...)
```

을 호출한다.
 
이 과정을 통해 새로운 Delegate 객체가 생성되고, Invocation List가 갱신된다.

---

## Event가 Delegate를 사용하는 이유

다음과 같은 상황을 생각해 보자.

```
플레이어 사망

↓

UI

↓

사운드

↓

업적

↓

로그 저장
```

플레이어가 사망하면
여러 시스템이 동시에 반응해야 한다.
 
이때 Delegate 하나에
여러 메서드를 등록할 수 있기 때문에
Event 시스템을 매우 쉽게 구현할 수 있다.
 
실제로 C# Event는
Multicast Delegate를 기반으로 만들어져 있다.

---

## 실무에서 자주 하는 오해

가장 흔한 오해는

> +=가 기존 Delegate를 수정한다.

라는 것이다.

Delegate는 불변(Immutable) 객체이다.
+=와 -=는 기존 객체를 수정하는 것이 아니라 **새로운 Delegate 객체를 생성하여 참조를 바꾸는 것**이다.
 
또 하나의 오해는

> 반환값이 있는 Delegate도 여러 결과를 받을 수 있다.

라는 것이다.
 
Multicast Delegate는 모든 메서드를 실행하지만,
호출 결과는 마지막 메서드의 반환값만 돌려준다.
 
그래서 여러 메서드를 등록하는 Delegate는 일반적으로 void 반환형을 사용한다.

---

## 마무리

Multicast Delegate는 하나의 Delegate에 여러 메서드를 등록하여 순차적으로 실행할 수 있는 기능이다.
 
이 기능은 UI 이벤트, 게임 이벤트, 로그 기록, 알림 시스템처럼 하나의 동작에 여러 객체가 동시에 반응해야 하는 상황에서 매우 유용하다.
 
또한 +=와 -=는 기존 Delegate를 수정하는 것이 아니라 새로운 Delegate 객체를 생성하는 방식으로 동작하며, 이러한 불변 구조는 Delegate를 안전하게 사용할 수 있도록 해 준다.
 
다음 글에서는 **Action과 Func는 왜 등장했을까?**를 살펴보며 Delegate를 더욱 간결하게 사용할 수 있는 제네릭 Delegate를 알아보겠다.

---

## 핵심 정리

- Multicast Delegate는 하나의 Delegate에 여러 메서드를 등록할 수 있다.
- 내부적으로 호출 목록인 **Invocation List**를 관리한다.
- 등록된 메서드는 등록 순서대로 실행된다.
- +=와 -=는 Delegate.Combine()과 Delegate.Remove()를 사용하며 새로운 Delegate 객체를 생성한다.
- 반환값이 있는 Multicast Delegate는 마지막 메서드의 반환값만 반환한다.
- 중간에 예외가 발생하면 이후 메서드는 실행되지 않는다.
- C#의 Event는 Multicast Delegate를 기반으로 구현되어 있다.
