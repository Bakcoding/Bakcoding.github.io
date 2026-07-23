---
title: "[궁금시리즈] 4-4. HashSet<T>는 Dictionary와 무엇이 다를까?"
excerpt: "C#"
categories:
  - Programming
tags:
  - CSharp
permalink: /programming/4-4-hashset-t-dictionary/
toc: true
toc_sticky: true
date: 2026-07-23
last_modified_at: 2026-07-23
---

앞에서 Dictionary<TKey, TValue>는 Hash 함수를 이용하여 매우 빠른 검색을 제공한다고 설명했다.

그렇다면 다음과 같은 상황을 생각해 보자.

플레이어 이름을 저장하는데

```
Tom
Alice
Mike
```

처럼 **값만 저장하면 된다.**
Key도 필요 없고, 중복도 허용하면 안 된다.

이럴 때도 Dictionary를 사용해야 할까?

이 문제를 해결하기 위해 등장한 것이 **HashSet<T\>** 이다.

---

## HashSet은 무엇일까?

HashSet은

> 중복을 허용하지 않는 집합(Set)을 구현한 컬렉션이다.

예를 들어

```
HashSet<string> names = new();
```

여기에

```cs
names.Add("Tom");
names.Add("Alice");
names.Add("Mike");
```

를 추가하면

```
Tom
Alice
Mike
```

가 저장된다.

---

## 같은 데이터를 추가하면?

다음 코드를 보자.

```cs
names.Add("Tom");
names.Add("Tom");
names.Add("Tom");
```

결과는

```
Tom
```

하나만 저장된다.

중복 데이터는 자동으로 무시된다.

---

## List라면 어떻게 될까?

```
List<string> names = new();

names.Add("Tom");
names.Add("Tom");
names.Add("Tom");
```

결과는

```
Tom
Tom
Tom
```

이 된다.

List는 순서를 관리하는 컬렉션이지,
중복을 검사하는 컬렉션은 아니기 때문이다.

---

## HashSet은 어떻게 중복을 검사할까?

여기서 많은 사람들이 궁금해한다.

> "매번 처음부터 끝까지 비교하는 걸까?"

그렇지 않다.

HashSet도 Dictionary처럼
Hash 함수를 사용한다.

예를 들어

```
Tom

↓

HashCode

↓

Bucket 5
```

라는 결과가 나왔다고 하자.

같은 문자열

```
Tom
```

을 다시 추가하면
다시 같은 HashCode가 계산된다.

HashSet은 먼저 
같은 Bucket을 확인하고,
이미 같은 값이 존재하는지 검사한다.

존재한다면 새로운 데이터를 
저장하지 않는다.

---

## HashCode만 같으면 같은 객체일까?
아니다.

이 부분은 매우 중요하다.

예를 들어

```
A

↓

HashCode = 100
```

```
B

↓

HashCode = 100
```

이 될 수도 있다.

즉, HashCode는 같지만
실제 객체는 다를 수 있다.

이것을 **Hash Collision**
이라고 한다.

그래서 HashSet은
HashCode만 비교하지 않는다.

---

## Equals도 함께 사용한다

HashSet은 다음 순서로 비교한다.

```
HashCode 비교

↓

같다

↓

Equals 비교

↓

정말 같은 객체인지 확인
```

즉,HashCode는 검색 범위를 줄이기 위한 도구이고,
최종 판단은 Equals가 한다.

---

## 실제 .NET도 같은 방식이다

예를 들어

```
HashSet<Player>
```

가 있다고 하자.
플레이어를 추가하면 
내부에서는

```
GetHashCode()

↓

Bucket 선택

↓

Equals()

↓

중복 여부 확인
```

순서로 동작한다.
즉,
HashCode와 Equals는
항상 함께 동작한다.

---

## 그래서 GetHashCode를 같이 구현해야 한다

예를 들어

```
class Player
{
    public int Id;
}
```

두 객체를 Id만 같으면 같은 플레이어라고 
판단하고 싶다고 하자.

그러면

```cs
public override bool Equals(object obj)
{
    return obj is Player p && Id == p.Id;
}
```

만 구현해서는 안 된다.

반드시

```cs
public override int GetHashCode()
{
    return Id.GetHashCode();
}
```

도 함께 구현해야 한다.

그렇지 않으면 HashSet이나 Dictionary에서
올바르게 동작하지 않을 수 있다.

---

## 왜 둘 다 구현해야 할까?

다음 두 객체를 보자.

```cs
Player(Id = 1)

Player(Id = 1)
```

Equals는 `같다`

라고 판단한다.

그런데 GetHashCode가 다른 값을 반환하면
HashSet은 서로 다른 Bucket에 저장한다.

그러면 중복을 발견하지 못한다.

즉,
다음 규칙을 반드시 지켜야 한다.

> Equals가 true라면 GetHashCode도 반드시 같은 값을 반환해야 한다.

반대로 HashCode가 같다고 해서
Equals가 반드시 true일 필요는 없다.

Hash 충돌은 언제든 발생할 수 있기 때문이다.

---

## Dictionary도 똑같이 동작한다

많은 사람들이 HashSet만
HashCode를 사용하는 줄 안다.

하지만 Dictionary도 동일하다.

```
GetHashCode()

↓

Bucket 선택

↓

Equals()

↓

Key 비교
```

즉,
HashSet과 Dictionary의 
내부 원리는 거의 같다.
차이는 Dictionary는

```
Key

↓

Value
```

를 저장하고, HashSet은

```
Value 하나
```

만 저장한다는 것이다.

---

## 실무에서는 언제 사용할까?

대표적인 예는 중복 검사이다.

예를 들어

```
접속한 플레이어 이름

이미 처리한 이벤트 ID

방문한 노드
```

등 "이미 존재하는가?" 만 중요하다면
HashSet이 가장 적합하다.

---

## 실무에서 자주 하는 실수

많은 개발자가 중복 검사를 위해

```
List<string>.Contains()
```

를 사용한다.

```cs
if (!names.Contains(name))
{
    names.Add(name);
}
```

데이터가 적다면 괜찮다.

하지만 수십만 개의 데이터에서는
Contains()가 처음부터 끝까지 
탐색해야 하므로 비용이 커진다.

이런 경우에는

```
HashSet<string> names = new();
```

을 사용하는 것이 훨씬 효율적이다.

---

## HashSet과 Dictionary는 어떻게 선택할까?

다음 기준으로 생각하면 쉽다.

| 필요한 기능 | 적합한 컬렉션 |
| ---------- | ------------ |
| Key로 Value를 찾는다 | Dictionary<TKey, TValue> |
| 값의 중복 여부만 확인한다 | HashSet<T> |
| 순서가 중요하다 | List<T> |

즉, HashSet은 Dictionary에서
Value만 사용하는 특수한 형태가 아니라,
**중복 없는 집합(Set)**을 표현하기 위해 
만들어진 컬렉션이다.

---

## 마무리

HashSet<T>는 Hash 함수를 이용해 중복을 빠르게 검사하는 컬렉션이다.

내부적으로는 Dictionary<TKey, TValue>와 매우 비슷한 구조를 사용하지만, Key와 Value를 저장하는 대신 **값 자체를 하나의 집합(Set)**으로 관리한다.

또한 HashSet과 Dictionary 모두 GetHashCode()와 Equals()를 함께 사용하여 데이터를 올바르게 비교한다. 따라서 사용자 정의 클래스를 Key나 HashSet의 요소로 사용할 때는 두 메서드의 관계를 반드시 이해해야 한다.

다음 글에서는 **Queue<T>와 Stack<T>는 언제 사용해야 할까?**를 알아보며 FIFO와 LIFO 자료구조를 살펴보겠다.

---

## 핵심 정리

- HashSet<T>는 중복을 허용하지 않는 집합(Set) 컬렉션이다.
- HashSet<T>도 Hash 함수를 이용해 빠르게 검색한다.
- HashCode는 검색 위치를 찾기 위해 사용되고, Equals는 최종 비교를 위해 사용된다.
- Equals()를 재정의했다면 GetHashCode()도 함께 재정의해야 한다.
- Dictionary<TKey, TValue>와 HashSet<T>는 내부 원리가 매우 비슷하다.
- 중복 검사만 필요하다면 List<T>보다 HashSet<T>가 더 적합하다.
