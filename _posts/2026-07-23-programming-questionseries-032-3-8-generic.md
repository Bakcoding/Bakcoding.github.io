---
title: "[궁금시리즈] 3-8. Generic을 사용하면 정말 성능이 좋아질까?"
excerpt: "C#"
categories:
  - Programming
tags:
  - CSharp
permalink: /programming/3-8-generic/
toc: true
toc_sticky: true
date: 2026-07-23
last_modified_at: 2026-07-23
---

Generic을 처음 배우면 다음과 같은 이야기를 자주 듣는다.

> "Generic은 성능이 좋다."

실제로 List<T>는 ArrayList보다 빠르고, Boxing도 발생하지 않는다.
그렇다면 Generic을 사용하면 항상 성능이 좋아지는 것일까?

결론부터 말하면 아니다.

Generic이 성능을 높이는 경우도 있지만, 목적 자체가 성능은 아니다.

이번 글에서는 Generic이 왜 성능 향상을 가져오는지, 그리고 언제 그렇지 않은지를 알아보자.

---

## Generic이 등장한 이유를 다시 생각해보자

가장 처음 Generic이 등장한 이유는 세 가지였다.

- 타입 안정성(Type Safety)
- 캐스팅 제거
- Boxing 제거

즉, 성능은 결과 중 하나일 뿐
**가장 큰 목적은 타입을 안전하게 다루기 위한 것이었다.**

---

## 왜 ArrayList는 느렸을까?

예를 들어

```
ArrayList list = new();

list.Add(10);
```

겉으로는 단순한 코드처럼 보인다.

하지만 내부에서는

```
int

↓

object

↓

Boxing
```

이 발생한다.

반대로 값을 꺼낼 때는

```cs
int value = (int)list[0];
```

```
object

↓

int

↓

Unboxing
```

이 발생한다.

즉, 객체 생성과 형 변환이 계속 일어난다.

---

## Generic은 무엇이 달라질까?

이번에는

```
List<int> list = new();

list.Add(10);
```

를 보자.

컴파일러는 이미

```
T == int
```

라는 사실을 알고 있다.

따라서

- Boxing이 발생하지 않는다.
- Unboxing도 발생하지 않는다.
- 캐스팅도 필요 없다.

이것이 Generic이 성능을 높이는 가장 큰 이유이다.

---

## JIT도 더 효율적인 코드를 만든다

앞에서 살펴봤듯이 Generic은 IL에도 그대로 남는다.

예를 들어

```
List<int>
```

를 처음 사용하는 순간 JIT는

```
List<int> 전용 Native Code
```

를 생성한다.

이 코드에서는 이미 자료형이 확정되어 있으므로
불필요한 형 변환을 고려할 필요가 없다.

즉, Generic 덕분에 JIT도 더 효율적인 코드를 생성할 수 있다.

---

## 그렇다면 항상 빨라질까?

많은 사람들이

```
Generic

↓

빠르다
```

라고 생각한다.

하지만 다음 코드를 보자.

```
List<Player> players = new();
```

여기서 Player는 참조 타입이다.

참조 타입에서는 원래 Boxing이 발생하지 않는다.

즉, Generic을 사용했다고 해서
갑자기 엄청난 성능 향상이 생기는 것은 아니다.

---

## 참조 타입은 코드를 공유한다

앞에서 Generic 내부 동작을 설명할 때 참조 타입은 대부분 
하나의 Native Code를 공유한다고 했다.

예를 들어

```
List<Player>

List<Monster>

List<Item>
```

은 대부분 같은 Native Code를 사용한다.

반면

```
List<int>

List<float>

List<double>
```

은 각각 전용 Native Code가 생성된다.

이 때문에 값 타입에서 Generic의 성능 이점이 더 크게 나타난다.

---

## Generic도 비용이 없는 것은 아니다

예를 들어

```
class Repository<T>
{
}
```

를 무분별하게 만들면 프로젝트에는

```
Repository<Player>

Repository<Item>

Repository<Monster>

Repository<Quest>

Repository<Weapon>
```

처럼 수많은 Generic 타입이 생긴다.

Generic은 코드의 재사용성을 높여 주지만,
불필요하게 Generic을 사용하면
코드가 복잡해질 수도 있다.

---

## Generic보다 중요한 것은 알고리즘이다

다음 두 코드를 비교해 보자.

```
List<int>
```

```
ArrayList
```

Generic이 더 빠르다.

하지만

```
O(n²)

↓

O(n log n)
```

으로 알고리즘을 개선하는 것이
훨씬 큰 성능 향상을 가져온다.

즉, Generic은 미세한 최적화보다 안전한 코드와 
재사용성을 제공하는 기능으로 이해하는 것이 좋다.

---

## 실무에서는 언제 성능 차이가 클까?

대표적인 경우는 값 타입을 많이 다룰 때이다.

예를 들어

```
List<Vector3>

List<int>

List<float>
```

처럼 수십만 개 이상의 데이터를 처리한다면
Boxing이 사라지는 효과는 매우 크다.

반대로

```
List<Player>
```

처럼 참조 타입만 다루는 경우에는
성능 차이보다 타입 안정성과 캐스팅 제거의 이점이 더 크다.

---

## 실무에서 자주 하는 오해

많은 개발자가

> "Generic은 빠르니까 모든 클래스를 Generic으로 만들어야겠다."

라고 생각한다.

하지만 Generic은 **필요할 때 사용하는 설계 도구**이다.

예를 들어

```cs
class Logger<T>
{
}
```

처럼 타입에 따라 동작이 달라지지 않는 클래스까지 Generic으로 만들면
오히려 API가 복잡해지고 유지보수성이 떨어질 수 있다.

Generic은 **여러 타입을 동일한 로직으로 처리해야 할 때** 사용하는 것이 적절하다.

---

## 지금까지의 내용을 연결해보자

이번 챕터에서 Generic에 대해 다음과 같은 내용을 살펴봤다.

1. Generic은 왜 등장했는가?
2. <T>는 컴파일러와 CLR이 어떻게 처리하는가?
3. where 제약 조건은 왜 필요한가?
4. Generic 클래스와 Generic 메서드는 언제 사용하는가?
5. Generic 인터페이스는 왜 중요한가?
6. default(T)는 왜 필요한가?
7. in과 out은 왜 존재하는가?

이 모든 기능은 하나의 목표를 위해 존재한다.

> 타입 안정성을 유지하면서 하나의 코드로 다양한 타입을 효율적으로 처리하는 것

성능 향상은 그 과정에서 얻는 중요한 장점 중 하나일 뿐이다.

---

## 마무리

Generic은 단순히 <T>를 사용하는 문법이 아니다.

컴파일러, CLR, JIT가 함께 동작하여 타입 안정성과 코드 재사용성을 제공하는 .NET의 핵심 기능이다.

특히 값 타입에서는 Boxing과 Unboxing을 제거하여 성능 향상을 가져오며, 참조 타입에서는 캐스팅 없는 안전한 코드를 작성할 수 있게 해준다.

중요한 것은 Generic의 목적을 **"성능 최적화"**가 아니라 **"타입을 안전하고 효율적으로 다루기 위한 설계 방식"**으로 이해하는 것이다.

이제 Generic의 핵심 개념을 모두 살펴보았으므로, 다음 챕터에서는 컬렉션(Collection) 으로 넘어가 List<T>, Dictionary<TKey, TValue>, HashSet<T> 등의 내부 구조와 동작 원리를 알아보겠다.

---

## 핵심 정리

- Generic의 가장 큰 목적은 타입 안정성과 코드 재사용성이다.
- 성능 향상은 Boxing 제거와 캐스팅 제거에서 비롯된다.
- 값 타입에서는 Generic의 성능 이점이 특히 크다.
- 참조 타입에서는 성능보다 타입 안정성의 이점이 더 크다.
- JIT는 값 타입 Generic에 대해 전용 Native Code를 생성한다.
- Generic을 무분별하게 사용하는 것보다 적절한 설계가 더 중요하다.
- 알고리즘 개선이 Generic 사용보다 더 큰 성능 향상을 가져오는 경우가 많다.
