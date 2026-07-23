---
title: "[궁금시리즈] 2-5. 메모리 누수(Memory Leak)는 GC가 있는데도 왜 발생할까?"
excerpt: "C#"
categories:
  - Programming
tags:
  - CSharp
permalink: /programming/2-5-memory-leak-gc/
toc: true
toc_sticky: true
date: 2026-07-23
last_modified_at: 2026-07-23
---

C#은 Garbage Collector(GC)가 메모리를 자동으로 관리한다.
그래서 많은 사람들이

> "C#에서는 메모리 누수가 발생하지 않는다."

라고 생각한다.

하지만 실제로는 그렇지 않다.

오히려 게임이나 서버를 개발하다 보면
GC가 있는데도 메모리가 계속 증가하는 현상을 자주 만나게 된다.

그렇다면 GC는 왜 메모리를 회수하지 못하는 것일까?
이번 글에서는 C#에서 발생하는 메모리 누수의 원인과 해결 방법을 알아보자.

---

## 메모리 누수란?

메모리 누수(Memory Leak)란

> 더 이상 사용하지 않는 객체인데도 메모리에서 해제되지 않는 현상이다.

중요한 점은
객체가 실제로 사용되고 있는 것이 아니라,
**GC가 아직 사용 중이라고 판단하는 것**이다.

---

## GC는 참조가 남아 있으면 삭제하지 않는다

GC는 객체가 필요한지 필요하지 않은지를
개발자의 의도를 보고 판단하지 않는다.

오직

> 참조가 존재하는가?

만 판단한다.

예를 들어

```cs
Player player = new Player();
```

이 객체는

```
Root

↓

player

↓

Player
```

라는 참조가 있으므로
삭제되지 않는다.

---

## 참조 하나 때문에 살아남는다

다음 코드를 보자.

```cs
Player player = new Player();

Player cache = player;

player = null;
```

많은 사람들이

```
player = null

↓

삭제
```

라고 생각한다.
하지만 메모리는

```
cache

↓

Player
```

가 된다.

아직 참조가 하나 남아 있다.

GC는

> "아직 사용 중인 객체구나."

라고 판단한다.

즉, 삭제하지 않는다.

---

## 가장 흔한 원인 ① static 변수

다음 코드를 보자.

```cs
class Game
{
    public static Player CurrentPlayer;
}
```

```cs
Game.CurrentPlayer = new Player();
```

Static 변수는 프로그램이 종료될 때까지 살아있다.

따라서

```
Static

↓

Player
```

라는 참조가 유지된다.
객체는 GC 대상이 되지 않는다.

---

## 가장 흔한 원인 ② 이벤트(Event)

다음 코드를 보자.

```cs
publisher.OnDamage += player.HandleDamage;
```

이벤트는 Publisher가
Player를 참조하게 된다.

```
Publisher

↓

Delegate

↓

Player
```

Player를 더 이상 사용하지 않아도
이벤트가 연결되어 있으면
GC는 삭제하지 않는다.

따라서 사용이 끝났다면

```cs
publisher.OnDamage -= player.HandleDamage;
```

를 반드시 호출해야 한다.

---

## 가장 흔한 원인 ③ 컬렉션

예를 들어

```cs
List<Player> players = new();
```

```cs
players.Add(new Player());
```

사용이 끝났는데도

```
List

↓

Player
```

참조가 남아 있다.

GC는 삭제하지 않는다.

필요 없는 객체라면

```cs
players.Clear();
```

또는

```cs
players.Remove(player);
```

를 수행해야 한다.

---

## 가장 흔한 원인 ④ 캐시

예를 들어

```cs
Dictionary<int, Texture> cache;
```

캐시에 저장된 객체는 
삭제하지 않는 이상
계속 살아있다.

그래서 캐시에는 

- 최대 개수 제한 
- 만료 시간

등을 두는 것이 일반적이다.

---

## Unity에서 자주 발생하는 메모리 누수
게임 개발에서는
다음과 같은 경우가 많다.

```cs
Update()
{
    list.Add(new Enemy());
}
```

리스트를 비우지 않으면 Enemy는
계속 메모리에 남는다.

또는

```
DontDestroyOnLoad()
```

객체가 씬이 바뀌어도 계속 살아있을 수 있다.

Unity에서는 이벤트, 싱글톤, DontDestroyOnLoad
때문에 메모리 누수가 자주 발생한다.

---

## GC가 회수하지 않는 것이 버그일까?

아니다.

GC는 정상적으로 동작하고 있다.

예를 들어

```
Root

↓

Player
```

참조가 남아 있다.
GC는

> "사용 중인 객체"

라고 판단한다.

즉, 문제는 GC가 아니라
불필요한 참조를 남겨둔 코드이다.

---

## WeakReference란?

가끔 객체를 참조는 하고 싶지만
GC는 가능하게 하고 싶은 경우가 있다.

이럴 때 사용하는 것이

```
WeakReference<T>
```

이다.

```
WeakReference<Player> weak;
```

WeakReference는
GC가 객체를 회수하는 것을 막지 않는다.
주로 캐시 구현 등에 사용된다.

---

## IDisposable과는 무슨 관계일까?

다음 코드를 보자.

```cs
FileStream stream = new FileStream(...);
```

GC가 있다고 해서
파일이 자동으로 닫히는 것은 아니다.

파일, 네트워크, 데이터베이스, 윈도우 핸들
같은 운영체제 자원은 GC가 관리하는 대상이 아니다.

이러한 자원은

```
using
```

또는

```
Dispose()
```

를 통해 직접 해제해야 한다.
이 부분은 이후 IDisposable 글에서 자세히 다룬다.

---

## 메모리 누수를 줄이는 방법

다음 사항을 습관화하면 대부분의 메모리 누수를 예방할 수 있다.

- 사용이 끝난 이벤트는 반드시 해제한다.
- 사용하지 않는 컬렉션은 비운다.
- Static 변수 사용을 최소화한다.
- 캐시는 만료 정책을 만든다.
- IDisposable 객체는 반드시 Dispose한다.
- 객체 생명주기를 명확하게 관리한다.

---

## 마무리

C#의 GC는 사용하지 않는 객체를 자동으로 회수해 주지만, **참조가 남아 있는 객체는 절대 삭제하지 않는다.**

따라서 C#에서 발생하는 대부분의 메모리 누수는 GC의 문제가 아니라 **불필요한 참조를 오래 유지한 코드** 때문에 발생한다.

특히 이벤트, static 변수, 컬렉션, 캐시는 실무에서 가장 흔한 메모리 누수의 원인이므로 객체의 생명주기를 명확하게 관리하는 습관이 중요하다.

다음 글에서는 **IDisposable과 using은 왜 필요할까?**를 알아보며, GC가 관리하지 않는 자원을 어떻게 해제해야 하는지 살펴보겠다.

---

## 핵심 정리

- GC는 참조가 없는 객체만 회수한다.
- 참조가 하나라도 남아 있으면 객체는 삭제되지 않는다.
- static 변수는 프로그램 종료 전까지 객체를 유지할 수 있다.
- 이벤트를 해제하지 않으면 객체가 계속 참조될 수 있다.
- 컬렉션과 캐시도 메모리 누수의 주요 원인이다.
- WeakReference<T>는 GC를 방해하지 않는 참조를 제공한다.
- 파일, 소켓 등 운영체제 자원은 GC가 아닌 Dispose()로 해제해야 한다.
