---
title: "[궁금시리즈] 3-5. Generic 인터페이스는 왜 많이 사용할까?"
excerpt: "C#"
categories:
  - Programming
tags:
  - CSharp
permalink: /programming/3-5-generic/
toc: true
toc_sticky: true
date: 2026-07-23
last_modified_at: 2026-07-23
---

지금까지 Generic 클래스와 Generic 메서드를 살펴봤다.
그런데 .NET 라이브러리를 보면 Generic 클래스보다 더 자주 보이는 것이 있다.
바로 **Generic 인터페이스**이다.

예를 들어

```
IEnumerable<T>

ICollection<T>

IList<T>

IComparable<T>

IComparer<T>

IEquatable<T>
```

심지어 LINQ도

```
IEnumerable<T>
```

를 중심으로 만들어져 있다.

왜 .NET은 Generic 인터페이스를 이렇게 많이 사용하는 것일까?
이번 글에서는 Generic 인터페이스가 등장한 이유와 실무에서 어떻게 활용되는지 알아보자.

---

## 인터페이스부터 다시 생각해보자

인터페이스는

> 무엇을 할 수 있는지(기능)를 약속하는 계약(Contract) 이다.

예를 들어

```cs
interface IMovable
{
    void Move();
}
```

Player, Monster, NPC,
Move()를 구현할 수 있다.

즉, 인터페이스는
"어떤 타입인지"보다
"무엇을 할 수 있는지"에 관심이 있다.

---

## 그런데 자료형까지 다르면?

예를 들어

```cs
interface IRepository
{
    object Find(int id);
}
```

를 생각해 보자.

Player를 반환할 수도 있고
Monster를 반환할 수도 있다.

결국

```
object
```

를 사용해야 한다.

그러면

```
Player player = (Player)repo.Find(1);
```

처럼 매번 캐스팅해야 한다.

또한 값 타입이라면 Boxing도 발생한다.

이는 Generic이 등장하기 전 ArrayList와 같은 문제이다.

Generic 인터페이스의 등장 이 문제를 해결하기 위해
인터페이스에도 Generic을 적용할 수 있게 되었다.

```cs
interface IRepository<T>
{
    T Find(int id);
}
```

이제

```cs
class PlayerRepository : IRepository<Player>
{
    public Player Find(int id)
    {
        ...
    }
}
```

처럼 구현할 수 있다.

컴파일러는 처음부터 반환 타입이 
Player라는 사실을 알고 있으므로
캐스팅이 필요 없다.

## 가장 대표적인 Generic 인터페이스

### IEnumerable<T>

가장 많이 사용하는 Generic 인터페이스이다.

```cs
foreach(var item in collection)
{
}
```

가 가능한 이유도 대부분

```
IEnumerable<T>
```

를 구현하기 때문이다.

LINQ도

```
Where()

Select()

OrderBy()
```

모두 IEnumerable<T>를 기반으로 동작한다.

---

### IComparable<T>

객체끼리 비교하는 기준을 제공한다.

```cs
class Player : IComparable<Player>
{
    public int Level;

    public int CompareTo(Player other)
    {
        return Level.CompareTo(other.Level);
    }
}
```

그러면

```
players.Sort();
```

가 자동으로 동작한다.

---

### IComparer<T>

비교 기준을 외부에서 제공하고 싶을 때 사용한다.

예를 들어
레벨순, 이름순, 점수순
정렬을 각각 만들 수 있다.

```cs
class LevelComparer : IComparer<Player>
{
    public int Compare(Player x, Player y)
    {
        return x.Level.CompareTo(y.Level);
    }
}
```

---

### IEquatable<T>

객체의 동등성 비교를 제공한다.

```cs
class Player : IEquatable<Player>
{
    public bool Equals(Player other)
    {
        return Id == other.Id;
    }
}
```

Dictionary<TKey, TValue>나 HashSet<T>에서도
자주 사용된다.

---

## 왜 object를 사용하지 않았을까?

다음 두 코드를 비교해 보자.

```cs
interface IRepository
{
    object Find(int id);
}
```

```
interface IRepository<T>
{
    T Find(int id);
}
```

첫 번째는

- 캐스팅 필요
- 타입 안정성 부족
- Boxing 가능성

이 있다.

두 번째는

- 캐스팅 없음
- 컴파일 단계 검사
- Boxing 없음

즉,
Generic 인터페이스도
Generic 클래스와 같은 장점을 가진다.

실무에서는 어떻게 사용할까?

예를 들어 게임 서버를 만든다고 하자.

```cs
interface IRepository<T>
{
    T Find(int id);

    void Save(T data);

    void Delete(T data);
}
```

그러면

```
PlayerRepository

MonsterRepository

ItemRepository
```

모두 같은 인터페이스를 구현할 수 있다.

중복 코드가 줄고 타입 안정성도 확보된다.

---

## 실제 .NET 라이브러리에서도 같은 방식이다

앞에서 Generic 클래스와 Generic 메서드가 각각 다른 목적을 가진다고 설명했다.
Generic 인터페이스도 마찬가지이다.

예를 들어 List<T>는

```cs
public class List<T> :
    IList<T>,
    ICollection<T>,
    IEnumerable<T>
{
}
```

처럼 여러 Generic 인터페이스를 구현한다.

덕분에 List<T>는

- 컬렉션처럼 사용할 수도 있고
- foreach로 순회할 수도 있으며
- LINQ의 입력으로도 사용할 수 있다.

중요한 것은 LINQ가 List<T>만 처리하는 것이 아니라
**IEnumerable<T>를 구현한 모든 컬렉션을 처리한다**는 점이다.

예를 들어

```
List<Player>
Player[]
HashSet<Player>
Queue<Player>
```

모두

```cs
players.Where(x => x.Level >= 10);
```

와 같은 코드를 사용할 수 있다.
이처럼 .NET은 **구현 클래스보다 인터페이스를 중심으로 기능을 설계**한다.
이것이 Generic 인터페이스가 실무에서 매우 중요한 이유이다.

---

## 실무에서 자주 하는 실수

많은 초보 개발자는 메서드의 매개변수를 다음처럼 작성한다.

```cs
public void Print(List<Player> players)
{
}
```

이렇게 작성하면 List<Player>만 전달할 수 있다.

하지만 실제로 필요한 것은 순회할 수 있는 컬렉션일 뿐이라면

```cs
public void Print(IEnumerable<Player> players)
{
}
```

처럼 작성하는 것이 더 좋다.

이렇게 하면

- List<Player>
- Player[]
- HashSet<Player>
- Queue<Player>

등 IEnumerable<Player>를 구현한 모든 컬렉션을 받을 수 있다.
즉, **구현 클래스보다 인터페이스에 의존하는 것이 더 유연한 설계**이다.

---

## 마무리

Generic 인터페이스는 단순히 인터페이스에 <T>를 붙인 기능이 아니다.
타입 안정성을 유지하면서도 다양한 구현체를 하나의 방식으로 다룰 수 있도록 만든 .NET의 핵심 설계 요소이다.

특히 IEnumerable<T>를 중심으로 LINQ와 컬렉션 라이브러리가 구성되어 있기 때문에 Generic 인터페이스를 이해하면 .NET 라이브러리의 설계 철학도 함께 이해할 수 있다.

다음 글에서는 **default(T)와 default는 무엇이 다를까?**를 알아보며 Generic에서 타입의 기본값을 다루는 방법을 살펴보겠다.

---

## 핵심 정리

- Generic 인터페이스는 타입 안정성을 유지하면서 공통 기능을 정의한다.
- object 기반 인터페이스보다 캐스팅과 Boxing 문제를 해결할 수 있다.
- IEnumerable<T>는 LINQ와 foreach의 핵심 인터페이스이다.
- IComparable<T>, IComparer<T>, IEquatable<T>는 비교와 동등성 판단에 사용된다.
- 실무에서는 구현 클래스보다 Generic 인터페이스에 의존하는 것이 더 유연한 설계를 만든다.
- .NET BCL은 Generic 인터페이스를 중심으로 설계되어 있다.
