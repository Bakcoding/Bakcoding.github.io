---
title: "[궁금시리즈] 4-3. Dictionary<TKey, TValue>는 왜 검색이 빠를까?"
excerpt: "C#"
categories:
  - Programming
tags:
  - CSharp
permalink: /programming/4-3-dictionary-tkey-tvalue/
toc: true
toc_sticky: true
date: 2026-07-23
last_modified_at: 2026-07-23
---

플레이어를 저장하는 프로그램을 만든다고 생각해 보자.


```
List<Player> players = new();
```

특정 ID를 가진 플레이어를 찾으려면 어떻게 해야 할까?

```cs
foreach (var player in players)
{
    if (player.Id == targetId)
    {
        return player;
    }
}
```

플레이어가 10명이라면 큰 문제가 없다.

하지만 10만 명이라면?

원하는 플레이어를 찾기 위해 처음부터 끝까지 검사해야 할 수도 있다.

이 문제를 해결하기 위해 등장한 것이 Dictionary이다.

---

## List는 왜 검색이 느릴까?

예를 들어

[Player1]
[Player2]
[Player3]
...
[Player100000]

여기서 ID가

`87543`인 플레이어를 찾는다고 생각해 보자.

List는

```
Player1 검사

↓

Player2 검사

↓

Player3 검사

↓

...
```

처럼 하나씩 비교해야 한다.
운이 나쁘면 마지막까지 가야 한다.

즉,
**순차 탐색(Linear Search)**이다.

---

## Dictionary는 무엇이 다를까?

Dictionary는 값을
**Key와 Value** 형태로 저장한다.

```cs
Dictionary<int, Player> players = new();
```

여기서

```
Key

↓

Player
```

가 연결된다.

예를 들어

```
1001 → Player

1002 → Player

1003 → Player
```

처럼 저장된다.

---

## 그럼 어떻게 바로 찾을까?

많은 사람들이

```
Dictionary는

Key를 기억한다.
```

라고 생각한다.

하지만 실제로는 **Hash 함수(Hash Function)**를 사용한다.

---

예를 들어

```
Key = 1001
```

을 넣으면 Hash 함수가

```
3
```

을 만든다.

```
Key = 2030
```

은

```
7
```

이 된다.

즉, 
Dictionary는 Key 자체를 찾는 것이 아니라
Hash 값을 이용해 저장 위치를 계산한다.

---

## Hash 함수는 우편함 번호를 만드는 것과 비슷하다

아파트 우편함을 생각해 보자.

편지를 받을 때마다 모든 우편함을 열어보지는 않는다.

대신

```
1203호

↓

1203번 우편함
```

으로 바로 간다.

Dictionary도 같다.

```
Key

↓

Hash

↓

저장 위치
```

를 계산하여 원하는 위치로 바로 이동한다.
그래서 대부분의 경우 처음부터 
끝까지 탐색할 필요가 없다.

---

## 내부 구조는 어떻게 생겼을까?

실제 구조는 훨씬 복잡하지만 단순화하면 다음과 같다.

```
Bucket

0

1

2

3

4

5

6

7
```

Hash 함수가

```
Key

↓

Bucket 번호
```

를 계산한다.

예를 들어

```
1001

↓

Bucket 3
```

이라면 바로
Bucket 3으로 이동한다.

---

## Hash 충돌(Collision)

그런데 다음과 같은 상황이 생길 수도 있다.

```
1001

↓

Bucket 3
```

```
2005

↓

Bucket 3
```

둘 다 같은 Bucket이 나왔다.
이것을 Hash Collision 이라고 한다.

---

## 충돌이 발생하면?

충돌이 생긴다고 해서
데이터가 사라지는 것은 아니다.

예를 들어

```
Bucket 3

↓

1001

↓

2005

↓

3008
```

처럼 같은 Bucket 안에
여러 데이터를 저장한다.

찾을 때는 Bucket만 확인하면 되므로
전체를 탐색하는 것보다 훨씬 빠르다.

실제 .NET은 이러한 충돌을 해결하기 위해 
**체이닝(Chaining)**방식과 엔트리 배열을 활용한다.

---

## 그래서 Dictionary는 항상 O(1)일까?

많은 책에서

```
Dictionary

↓

O(1)
```

이라고 설명한다.

엄밀하게 말하면 평균적으로 `O(1)` 이다.
충돌이 거의 없다면 바로 찾는다.

하지만 충돌이 계속 발생하면

```
Bucket

↓

1001

↓

2005

↓

3008

↓

...
```

처럼 같은 Bucket 안에서
비교가 많아질 수 있다.

극단적인 경우에는 `O(n)` 까지도 증가할 수 있다.

다만 .NET은 Hash 함수와 Bucket 관리 방식을 최적화하여 
이런 상황이 거의 발생하지 않도록 설계되어 있다.

---

## 실무에서는 언제 사용할까?

대표적인 예는 플레이어 관리이다.

```cs
Dictionary<int, Player> players;
```

접속한 플레이어를 ID로 찾는 경우

```
players[id]
```

한 번이면 된다.

또는

```
아이템 ID

↓

아이템 정보
```

```
NPC ID
↓
NPC 정보
```

처럼 고유한 식별자(Key) 가 있다면 
Dictionary가 가장 적합하다.

---

## 실무에서 자주 하는 실수

많은 초보 개발자는

```cs
if (players.ContainsKey(id))
{
    var player = players[id];
}
```

처럼 작성한다.

하지만 이렇게 하면 Dictionary를 두 번 검색하게 된다.

실무에서는

```cs
if (players.TryGetValue(id, out Player player))
{
}
```

를 더 많이 사용한다.

TryGetValue()는 검색을 한 번만 수행하고,
키가 없는 경우에도 예외를 발생시키지 않는다.

따라서 더 효율적이고 안전한 방법이다.

---

## 실제 .NET에서는 어떻게 구현되어 있을까?

실제 Dictionary<TKey, TValue>는 내부적으로

- Bucket 배열
- Entry 배열
- HashCode
- Next Index

등을 이용하여 데이터를 관리한다.

단순히

```
Key

↓

Value
```

를 저장하는 것이 아니라, HashCode를 계산하고,
Bucket을 찾고, 충돌이 발생하면 Entry를 따라가며 
원하는 값을 찾는다.

이 구조 덕분에 수십만 개 이상의 데이터에서도 
매우 빠른 검색 성능을 제공할 수 있다.

---

## 마무리

Dictionary<TKey, TValue\>는 데이터를 순서대로 저장하는 컬렉션이 아니라 **Key를 기반으로 빠르게 검색하기 위한 컬렉션**이다.

Hash 함수를 이용해 저장 위치를 계산하기 때문에 대부분의 경우 매우 빠른 검색이 가능하며, 플레이어 ID, 아이템 ID, 사용자 계정처럼 **고유한 키를 가진 데이터를 관리할 때 가장 강력한 성능**을 발휘한다.

다음 글에서는 **HashSet<T\>는 Dictionary와 무엇이 다를까?**를 알아보며 중복 제거와 집합(Set) 자료구조의 동작 원리를 살펴보겠다.

---

## 핵심 정리

- Dictionary<TKey, TValue>는 Key와 Value를 함께 저장하는 컬렉션이다.
- 검색 시 Hash 함수를 이용해 저장 위치를 계산한다.
- 평균적으로 매우 빠른 검색 성능(O(1))을 제공한다.
- Hash 충돌이 발생하면 같은 Bucket 안에서 데이터를 관리한다.
- 실제 .NET은 Bucket과 Entry 배열을 사용하여 충돌을 해결한다.
- 키 존재 여부를 확인할 때는 ContainsKey()보다 TryGetValue()를 사용하는 것이 더 효율적이다.
- 고유한 식별자를 가진 데이터를 관리할 때 Dictionary가 가장 적합하다.
