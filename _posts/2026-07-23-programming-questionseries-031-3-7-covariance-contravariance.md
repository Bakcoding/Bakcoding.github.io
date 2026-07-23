---
title: "[궁금시리즈] 3-7. 공변성(Covariance)과 반공변성(Contravariance)은 왜 필요할까?"
excerpt: "C#"
categories:
  - Programming
tags:
  - CSharp
permalink: /programming/3-7-covariance-contravariance/
toc: true
toc_sticky: true
date: 2026-07-23
last_modified_at: 2026-07-23
---

다음 코드를 보자.

```cs
class Animal
{
}

class Dog : Animal
{
}
```

Dog는 Animal을 상속하므로
다음 코드는 아무 문제없이 동작한다.

```cs
Animal animal = new Dog();
```

자식 객체를 부모 변수에 담는 것은 자연스럽다.
그런데 Generic에서는 조금 다른 결과가 나온다.

```
List<Dog> dogs = new();

List<Animal> animals = dogs;
```

컴파일 오류가 발생한다.

분명 Dog는 Animal인데 왜 List<Dog>는 List<Animal>이 될 수 없을까?

그리고 왜 IEnumerable<T>는 가능한 것일까?

이번 글에서는 Generic의 공변성과 반공변성이 등장한 이유를 알아보자.

---

## 왜 List는 변환되지 않을까?

직관적으로는

```
Dog → Animal

그러므로

List<Dog> → List<Animal>
```

도 가능할 것처럼 보인다.

하지만 허용된다면 다음 코드가 가능해진다.

```cs
List<Dog> dogs = new();

List<Animal> animals = dogs;

animals.Add(new Cat());
```

여기서

```
dogs
```

안에는 Dog만 들어 있어야 한다.
하지만 Cat이 들어가 버렸다.

이제

```cs
Dog dog = dogs[0];
```

를 수행하면 실제로는 Cat이 들어 있을 수도 있다.

즉, 타입 안정성이 완전히 깨진다.

그래서

```
List<Dog>

↓

List<Animal>
```

변환은 허용되지 않는다.

---

## 그런데 IEnumerable는 가능하다

다음 코드는 가능하다.

```
IEnumerable<Dog> dogs = new List<Dog>();

IEnumerable<Animal> animals = dogs;
```

왜일까?

그 이유는 IEnumerable<T>는
읽기만 가능하기 때문이다.

```
foreach (var animal in animals)
{
}
```

또는

```cs
animals.First();
```

처럼 꺼내기만 가능하다.

반대로

```
animals.Add(...)
```

는 존재하지 않는다.

즉, 잘못된 타입이 추가될 위험이 없다.

그래서 안전하게 변환을 허용한다.

이것을 **공변성(Covariance)**
이라고 한다.

---

## out 키워드

공변성은

```cs
interface IEnumerable<out T>
{
}
```

처럼 out 키워드로 표현한다.

여기서 out은

```
밖으로 나가는 타입
```

이라는 의미이다.

즉, 반환만 가능하다.

대표적인 예는

```
IEnumerable<T>

IEnumerator<T>

IReadOnlyList<T>

IReadOnlyCollection<T>
```

등이 있다.

---

## 반공변성은 무엇일까?

반대로
입력만 받는 경우도 있다.

예를 들어

```cs
interface IComparer<in T>
{
    int Compare(T x, T y);
}
```

여기서는 T를 반환하지 않는다.
오직 입력으로만 사용한다.

---

예를 들어 Animal을 비교할 수 있는 Comparer는
Dog도 비교할 수 있다.

```
Animal

↑

Dog
```

Dog도 Animal이므로 Animal을 처리할 수 있는 비교기는
Dog도 처리할 수 있다.

이것을 **반공변성(Contravariance)**
이라고 한다.

---

## in 키워드

```cs
interface IComparer<in T>
{
}
```

여기서 in 은

```
안으로 들어오는 타입
```

이라는 의미이다.

즉, 매개변수로만 사용할 수 있다.

대표적인 예는

```
IComparer<T>

IEqualityComparer<T>

Action<T>
```

이다.

---

## out과 in을 쉽게 기억하는 방법

다음처럼 생각하면 쉽다.
 
**out**

```
T를 밖으로 내보낸다.

↓

return

↓

읽기
```

---

**in**

```
T를 안으로 받는다.

↓

parameter

↓

쓰기(입력)
```

## 왜 둘 다 허용하면 안 될까?

예를 들어

```cs
interface IRepository<T>
{
    T Get();

    void Save(T value);
}
```

여기서는 T가 반환도 되고 입력도 된다.

이 경우에는

```
out

×

in
```

둘 다 사용할 수 없다.

왜냐하면 타입 안정성을 보장할 수 없기 때문이다.

---

## 실제 .NET에서는 어떻게 사용할까?

다음은 .NET 라이브러리의 실제 선언이다.

```
public interface IEnumerable<out T>
{
}
```

읽기 전용 컬렉션이다.

---

```
public interface IComparer<in T>
{
}
```

비교 대상만 입력받는다.

---

```
public delegate TResult Func<in T, out TResult>(
    T arg);
```

입력은

```
in
```

결과는

```
out
```

이다.

---

```
public delegate void Action<in T>(
    T arg);
```

반환값이 없으므로 입력만 존재한다.

---

이처럼 .NET BCL 전체가 공변성과 반공변성을 
적극적으로 활용하고 있다.

---

## 실무에서 자주 하는 오해

많은 개발자가

```
out

↓

매개변수 out
```
으로 생각한다.

하지만 Generic의 `out`은 메서드의

`out` 매개변수와는 전혀 다른 개념이다.

```cs
bool TryParse(string text, out int value)
```

에서의 `out`은 출력 매개변수이다.

반면

```
interface IEnumerable<out T>
```

의 `out`은 **공변성을 나타내는 키워드**이다.
키워드는 같지만 목적은 완전히 다르다.

왜 공변성과 반공변성이 중요할까?

이 기능이 없다면 다음과 같은 코드가 
모두 불가능해진다.

```cs
IEnumerable<Dog> dogs = new List<Dog>();

IEnumerable<Animal> animals = dogs;
```

또는

```
Action<Animal> action = PrintAnimal;

Action<Dog> dogAction = action;
```

즉, Generic을 훨씬 유연하게 사용할 수 있도록 만든 것이
공변성과 반공변성이다.

## 마무리
공변성과 반공변성은 Generic 타입 간의 변환을 안전하게 허용하기 위해 만들어진 기능이다.

읽기만 가능한 타입은 out을 사용하여 공변성을 지원하고, 입력만 받는 타입은 in을 사용하여 반공변성을 지원한다.

이러한 규칙 덕분에 .NET은 타입 안정성을 유지하면서도 IEnumerable<T>, Action<T>, Func<T>와 같은 핵심 라이브러리를 유연하게 설계할 수 있었다.

처음에는 다소 어렵게 느껴질 수 있지만, **"읽기만 하면 out, 입력만 받으면 in"**이라는 원칙만 기억해도 대부분의 상황을 이해할 수 있다.

이로써 Generic의 핵심 개념은 모두 살펴보았다. 다음 챕터에서는 **컬렉션(Collection)**으로 넘어가 List<T>, Dictionary<TKey, TValue>, HashSet<T> 등이 내부적으로 어떻게 동작하는지 알아보겠다.

---

## 핵심 정리

- List<Dog>는 List<Animal>로 변환할 수 없다.
- 그 이유는 타입 안정성이 깨질 수 있기 때문이다.
- IEnumerable<out T>는 읽기 전용이므로 공변성을 지원한다.
- IComparer<in T>는 입력만 받으므로 반공변성을 지원한다.
- Generic의 in, out은 메서드의 in, out 매개변수와 다른 개념이다.
- Func, Action, IEnumerable 등 .NET BCL은 공변성과 반공변성을 적극 활용한다.
