---
title: "[궁금시리즈] 2-7. 얕은 복사(Shallow Copy)와 깊은 복사(Deep Copy)는 무엇이 다를까?"
excerpt: "C#"
categories:
  - Programming
tags:
  - CSharp
permalink: /programming/2-7-shallow-copy-deep-copy/
toc: true
toc_sticky: true
date: 2026-07-23
last_modified_at: 2026-07-23
---

다음 코드를 보자.

```cs
Player player1 = new Player();

Player player2 = player1;
```

많은 초보 개발자는

> "player2가 player1을 복사했으니까 객체도 하나 더 생겼겠네."

라고 생각한다.

하지만 실제로는 그렇지 않다.
객체는 하나뿐이고, 두 변수는 같은 객체를 참조한다.

그렇다면 

**객체를 완전히 복사하려면 어떻게 해야 할까?** 이번 글에서는 
**얕은 복사(Shallow Copy)**와 **깊은 복사(Deep Copy)**의 차이를 알아보자.

---

## 먼저 복사란 무엇일까?

복사에는 두 가지 대상이 있다.

- 변수만 복사
- 객체까지 복사

이 차이가 얕은 복사와 깊은 복사를 만든다.

---

## 얕은 복사(Shallow Copy)

얕은 복사는

> 객체는 복사하지 않고 참조만 복사하는 방식이다.

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

객체는 하나뿐이다.

---

## 객체를 수정하면?

```cs
p2.Hp = 50;
```

결과

```cs
p1.Hp == 50

p2.Hp == 50
```

왜냐하면 둘은 같은 객체를 바라보고 있기 때문이다.

---

## MemberwiseClone()

C#에는

```
MemberwiseClone()
```

이라는 메서드가 있다.

예를 들어

```cs
class Player
{
    public int Hp;
}
```

```cs
Player copy = (Player)original.MemberwiseClone();
```

이 메서드는 새로운 객체를 만들지만
참조 타입 필드는 그대로 복사한다.

즉, 대표적인 얕은 복사이다.

---

## 참조 타입 필드가 있으면?

예를 들어

```cs
class Inventory
{
    public int Gold;
}
```

```
class Player
{
    public Inventory Inventory;
}
```

복사하면

```
Player A

↓

Inventory
```

↓

```
Player B

↓

Inventory
```

Player 객체는 두 개지만
Inventory는 하나이다.

---

## 그래서 문제가 발생한다

```cs
copy.Inventory.Gold = 500;
```

그러면

```
original.Inventory.Gold

↓

500
```

도 함께 변경된다. 

이것이 얕은 복사의 대표적인 문제이다.

---

## 깊은 복사(Deep Copy)

깊은 복사는

> 객체 내부에 포함된 참조 타입까지 모두 새로 복사하는 방식이다.

예를 들어

```
Player A

↓

Inventory A
```
↓
깊은 복사
↓
```
Player B

↓

Inventory B
```

모든 객체가 새로 생성된다.

---

## 직접 구현하기

예를 들어

```cs
class Inventory
{
    public int Gold;
}
```

```
class Player
{
    public Inventory Inventory;

    public Player DeepCopy()
    {
        return new Player
        {
            Inventory = new Inventory
            {
                Gold = Inventory.Gold
            }
        };
    }
}
```

이제

```cs
Player copy = original.DeepCopy();
```

를 수행하면 완전히 독립적인 객체가 된다.

---

## 얕은 복사와 깊은 복사 비교

| 항목 | 얕은 복사 | 깊은 복사 |
| ---- | -------- | -------- |
| 객체 생성 | O | O |
| 참조 타입 필드 | 공유 | 새 객체 생성 |
| 메모리 사용 | 적음 | 많음 |
| 복사 속도 | 빠름 | 느림 |
| 원본 영향 | 받을 수 있음 | 없음 |

---

## 언제 얕은 복사를 사용할까?

다음과 같은 경우이다.

- 객체를 공유해도 문제없는 경우
- 읽기 전용 객체
- Immutable 객체
- 성능이 중요한 경우

---

## 언제 깊은 복사를 사용할까?

다음과 같은 경우이다.

- 객체를 독립적으로 수정해야 하는 경우
- 저장(Save) 데이터
- Undo/Redo
- 복제(Clone) 기능
- 게임 오브젝트 복사

---

## Unity에서는?

Unity의

```
Instantiate()
```
는 새로운 GameObject를 생성한다.

즉, 깊은 복사에 가까운 개념이다.

반면

```
GameObject b = a;
```

는 단순히 같은 객체를 참조한다.
Unity 입문자가 가장 많이 실수하는 부분 중 하나이다.

---

## Clone()을 사용하면 깊은 복사일까?

많은 개발자가

```
Clone()

↓

깊은 복사
```

라고 생각한다.
하지만 **반드시 그렇지는 않다.**

.NET의 ICloneable 인터페이스는 Clone()이 
얕은 복사인지, 깊은 복사인지 명확하게 정의하지 않는다.

즉, 구현한 클래스마다 다를 수 있다.

그래서 실무에서는

```
DeepCopy()
```

처럼 의도를 명확하게 드러내는 
메서드명을 사용하는 경우도 많다.

---

## 마무리

얕은 복사는 객체의 참조를 공유하는 방식이며, 깊은 복사는 객체 내부까지 모두 새로 생성하는 방식이다.

어떤 방식을 선택할지는 성능보다 객체를 공유해야 하는지, 독립적으로 관리해야 하는지에 따라 결정된다.

특히 참조 타입 필드가 있는 객체를 복사할 때는 얕은 복사와 깊은 복사의 차이를 명확하게 이해해야 예기치 않은 버그를 예방할 수 있다.

다음 글에서는 **Stackalloc은 무엇이며 언제 사용해야 할까?**를 알아보며, Stack 메모리를 활용한 성능 최적화 기법을 살펴보겠다.

## 핵심 정리

- 얕은 복사는 참조를 공유한다.
- 깊은 복사는 내부 객체까지 모두 새로 생성한다.
- MemberwiseClone()은 대표적인 얕은 복사이다.
- 참조 타입 필드가 있으면 얕은 복사 시 객체를 함께 사용한다.
- 깊은 복사는 메모리를 더 사용하지만 서로 영향을 주지 않는다.
- ICloneable.Clone()은 깊은 복사를 보장하지 않는다.
- 객체 공유 여부에 따라 적절한 복사 방식을 선택해야 한다.
