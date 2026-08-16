---
title: "[궁금시리즈] 7-5. Select와 SelectMany는 무엇이 다를까?"
excerpt: "C#"
categories:
  - CSharp
series: question-series
tags:
  - CSharp
permalink: /programming/7-5-select-selectmany/
toc: true
toc_sticky: true
date: 2026-07-27 20:34:02 +0900
last_modified_at: 2026-07-27
---

## 들어가며

LINQ에서 가장 많이 사용하는 메서드 중 하나가 `Select()`이다.

예를 들어 플레이어 객체에서 이름만 추출하고 싶다면 다음과 같이 작성한다.

```cs
List<Player> players =
[
    new Player("Alice", 10),
    new Player("Bob", 20)
];

IEnumerable<string> names =
    players.Select(player => player.Name);
```

결과는

```
Alice
Bob
```

가 된다.

그런데 컬렉션 안에 또 다른 컬렉션이 들어있는 경우에는 `Select()`만으로 원하는 결과를 얻기 어렵다.

이때 사용하는 것이 `SelectMany()`이다.

---

## Select는 무엇을 할까?

`Select()`는

> 하나의 데이터를 다른 형태로 변환하는 메서드이다.

예를 들어

```cs
List<Player> players =
[
    new Player("Alice", 10),
    new Player("Bob", 20)
];
```

가 있다면

```cs
IEnumerable<string> names =
    players.Select(player => player.Name);
```

결과는

```
Alice
Bob
```

이다.

Player를

String으로 변환한 것이다.

즉,

```
Player

↓

String
```

처럼

데이터를 다른 형태로 바꾸는 작업을

**Projection(투영)** 이라고 한다.

---

## 다양한 형태로 변환할 수 있다

반드시 기존 속성만 선택할 필요는 없다.

```cs
var result =
    players.Select(player =>
        $"{player.Name} ({player.Level})");
```

결과

```
Alice (10)

Bob (20)
```

새로운 객체를 만들어도 된다.

```cs
var result =
    players.Select(player =>
        new
        {
            player.Name,
            player.Level
        });
```

즉,

Select는

원하는 형태라면 무엇이든 반환할 수 있다.

---

## 그런데 컬렉션 안에 컬렉션이 있다면?

다음 구조를 보자.

```cs
public class Team
{
    public string Name { get; set; }

    public List<Player> Players { get; set; }
}
```

여러 팀이 있다.

```
Team A

↓

Player1

Player2

Player3

----------------

Team B

↓

Player4

Player5
```

이번에는

모든 Player를

하나의 목록으로 가져오고 싶다.

---

## Select를 사용하면 어떻게 될까?

```cs
var result =
    teams.Select(team => team.Players);
```

반환형은

```cs
IEnumerable<List<Player>>
```

이다.

즉,

```cs
List<Player>

List<Player>

List<Player>
```

가 만들어진다.

결과는

```
[Player1, Player2]

[Player3]

[Player4, Player5]
```

처럼

컬렉션의 컬렉션이다.

---

## 우리가 원하는 것은?

대부분 원하는 결과는

```
Player1

Player2

Player3

Player4

Player5
```

처럼

하나의 컬렉션이다.

---

## 그래서 SelectMany가 등장했다

```cs
var result =
    teams.SelectMany(team => team.Players);
```

결과는

```cs
IEnumerable<Player>
```

가 된다.

즉,

```
List<Player>

↓

Player

Player

Player
```

처럼

모든 컬렉션을 하나로 펼친다.

이를

**Flatten(평탄화)** 라고 한다.

---

## 내부적으로는 어떻게 동작할까?

개념적으로는

다음과 같은 반복문이다.

```cs
foreach (Team team in teams)
{
    foreach (Player player in team.Players)
    {
        yield return player;
    }
}
```

즉,

중첩된 컬렉션을

하나씩 꺼내

연속해서 반환하는 것이다.

---

## Select와 SelectMany 비교

예를 들어

```
반 A

학생1

학생2

----------------

반 B

학생3

학생4
```

이 있다.

Select는

```
반 A의 학생 목록

반 B의 학생 목록
```

을 반환한다.

즉,

```
List

↓

List

↓

List
```

이다.

반면

SelectMany는

```
학생1

학생2

학생3

학생4
```

를 반환한다.

즉,

```
List<List<T>>

↓

List<T>
```

가 된다.

---

## 실무에서는 언제 사용할까?

예를 들어

플레이어가 가진

모든 아이템을 가져오고 싶다면

```cs
var allItems =
    players.SelectMany(player => player.Items);
```

또는

모든 길드원의 이름을 가져온다면

```cs
var names =
    guilds.SelectMany(guild => guild.Members)
          .Select(member => member.Name);
```

처럼 사용할 수 있다.

---

## SelectMany 이후에도 LINQ를 계속 사용할 수 있다

`SelectMany()`의 결과도 `IEnumerable<T>`이다.

따라서

다른 LINQ 메서드를 자연스럽게 이어서 사용할 수 있다.

```cs
var names = teams
    .SelectMany(team => team.Players)
    .Where(player => player.Level >= 10)
    .Select(player => player.Name)
    .OrderBy(name => name);
```

이처럼 `SelectMany()`는 중첩된 컬렉션을 하나로 만든 뒤, 일반적인 LINQ 파이프라인을 계속 이어 갈 수 있다.

---

## 실제 .NET에서는 어떻게 사용할까?

`Select()`는 데이터 변환에 가장 많이 사용되는 LINQ 메서드 중 하나이다.

반면 `SelectMany()`는

- 부모-자식 관계
- 트리 구조
- 폴더와 파일
- 팀과 플레이어
- 주문과 주문 항목

처럼 하나의 객체가 여러 객체를 포함하는 구조를 처리할 때 자주 사용된다.

특히 Entity Framework나 XML 처리에서도 중첩된 데이터를 평탄화하는 용도로 많이 활용된다.

---

## 실무에서 자주 하는 오해

가장 흔한 오해는

> **SelectMany**는 여러 개를 선택하는 메서드이다.

라는 것이다.

`Many`는 "많이 선택한다"는 의미가 아니라,

여러 컬렉션을 하나의 컬렉션으로 펼친다는 의미이다.

또 하나의 오해는

> **Select**와 **SelectMany**는 서로 대체할 수 있다.

라는 것이다.

Select()는 데이터를 변환하는 것이 목적이고,

SelectMany()는 중첩된 컬렉션을 평탄화하는 것이 목적이다.

두 메서드는 역할이 다르므로 상황에 맞게 선택해야 한다.

---

## 마무리

`Select()`와 `SelectMany()`는 모두 데이터를 새로운 형태로 다루기 위한 LINQ 메서드이지만 목적은 다르다.

`Select()`는 하나의 데이터를 다른 형태로 변환하는 Projection을 수행하며, `SelectMany()`는 여러 컬렉션을 하나의 컬렉션으로 펼치는 Flatten 작업을 수행한다.

중첩된 컬렉션을 다루는 경우에는 `SelectMany()`를 사용하면 복잡한 중첩 반복문을 작성하지 않고도 원하는 결과를 간결하게 얻을 수 있다.

다음 글에서는 **`Where()`, `Any()`, `All()`, `Contains()`는 무엇이 다를까?**를 살펴보며 필터링과 존재 여부를 확인하는 LINQ 메서드들의 차이와 성능 특성을 알아보겠다.

## 핵심 정리

`Select()`는 데이터를 다른 형태로 변환하는 Projection 메서드이다.
`SelectMany()`는 중첩된 컬렉션을 하나의 컬렉션으로 펼치는 Flatten 메서드이다.
`Select()`의 결과는 컬렉션의 컬렉션이 될 수 있다.
`SelectMany()`는 `List<List<T>>`를 `List<T>`처럼 평탄화한다.
`SelectMany()`도 `IEnumerable<T>`를 반환하므로 다른 LINQ 메서드와 자연스럽게 연결할 수 있다.
부모-자식 구조나 중첩된 컬렉션을 처리할 때 `SelectMany()`가 유용하다.
