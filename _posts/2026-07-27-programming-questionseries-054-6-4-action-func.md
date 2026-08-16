---
title: "[궁금시리즈] 6-4. Action과 Func는 왜 등장했을까?"
excerpt: "C#"
categories:
  - CSharp
series: question-series
tags:
  - CSharp
permalink: /programming/6-4-action-func/
toc: true
toc_sticky: true
date: 2026-07-27 18:20:41 +0900
last_modified_at: 2026-07-27
---

## 들어가며

이전 글에서는 Delegate가 메서드를 저장하고 전달하기 위한 기능이라는 것을 살펴보았다.

예를 들어 다음과 같이 Delegate를 직접 만들 수 있다.

```cs
public delegate void MyDelegate();

MyDelegate del = Hello;

del();
```

이 방식에는 문제가 하나 있다.
 
메서드의 형태가 달라질 때마다 새로운 Delegate를 만들어야 한다는 것이다.
이러한 불편함을 해결하기 위해 .NET은 **Action**과 **Func**를 제공한다.

---

## Delegate를 계속 만들어야 하는 문제

다음 메서드를 생각해 보자.

```
void Print()
{
}
```

이를 저장하려면

```cs
public delegate void PrintDelegate();
```

가 필요하다.
 
이번에는

```cs
void Print(string message)
{
}
```

라면

```cs
public delegate void PrintDelegate(string message);
```

를 또 만들어야 한다.
 
이번에는

```cs
int Add(int x, int y)
{
    return x + y;
}
```

라면

```cs
public delegate int AddDelegate(int x, int y);
```

가 필요하다.
 
메서드 하나마다
Delegate도 하나씩 만들어야 한다.

---

## 너무 비슷한 Delegate가 계속 생긴다

프로젝트가 커질수록

```
PrintDelegate

SaveDelegate

MoveDelegate

AttackDelegate

DownloadDelegate

...
```

처럼 기능은 다르지만 
시그니처는 같은 Delegate가 계속 생긴다.

예를 들어

```cs
public delegate void A();

public delegate void B();

public delegate void C();
```

이 세 Delegate는 이름만 다를 뿐
실제로는 모두 같은 형태이다.

---

## .NET이 공통 Delegate를 제공하자

그래서 .NET은 자주 사용하는 Delegate를
미리 만들어 두었다.
 
대표적인 것이

```
Action

Func

Predicate
```

이다.
 
즉, 매번 Delegate를 만들지 말고
필요한 형태를 가져다 쓰자는 것이다.

---

## Action

Action은 **반환값이 없는 Delegate**이다.
 
예를 들어

```cs
void Print()
{
}
```

라면
 
직접 Delegate를 만들 필요 없이

```cs
Action action = Print;

action();
```

라고 사용할 수 있다.

매개변수가 있어도 된다

```cs
void Print(string text)
{
    Console.WriteLine(text);
}
```

이라면

```cs
Action<string> action = Print;

action("Hello");
```

가 된다.
 
매개변수는 최대 16개까지 지원한다.
 
예를 들어

```cs
Action<int, string, bool>
```

도 가능하다.

---

## Func

Func는 **반환값이 있는 Delegate**이다.
 
예를 들어

```cs
int Add(int x, int y)
{
    return x + y;
}
```

는

Func<int, int, int> add = Add;

가 된다.
 
여기서

```
앞의 타입

↓

매개변수

마지막 타입

↓

반환값
```

이다.
 
즉,

```
Func<int, int, int>
```

는

```
(int, int)

↓

int 반환
```

이라는 의미이다.

## 왜 반환값은 마지막에 있을까?

많은 사람들이

```cs
Func<int, int, int>
```

를 처음 보면 어떤 것이 반환형인지 헷갈린다.
 
규칙은 하나이다.


> 마지막 Generic 타입이 반환형이다.

예를 들어

```
Func<string, bool>
```

는

```
string 입력

↓

bool 반환
```

이다.
 
또한

```
Func<int>
```

는

```
매개변수 없음

↓

int 반환
```

을 의미한다.

---

## Predicate는 무엇일까?

Predicate는 조건을 검사하는 Delegate이다.
 
항상

```
bool 반환
```

을 가진다.
 
예를 들어

```cs
bool IsAdult(int age)
{
    return age >= 20;
}
```

는

```cs
Predicate<int> predicate = IsAdult;
```

가 된다.
 
사실 Predicate는 다음과 거의 같다.

```
Func<int, bool>
```

하지만
조건 검사라는 의미를 명확하게 표현하기 위해
별도의 이름이 존재한다.

---

## 실제 .NET에서는 어떻게 사용할까?

대표적인 예가 List<T>.ForEach()이다.

```cs
numbers.ForEach(x =>
{
    Console.WriteLine(x);
});
```

ForEach()는 내부적으로

```
Action<T>
```

를 전달받는다.
 
또한

```cs
Task.Run(() =>
{
    DoWork();
});
```

역시 실행할 작업을 Action으로 전달받는다.
 
반환값이 있다면

```cs
Task.Run(() =>
{
    return 10;
});
```

처럼 Func<TResult>를 사용한다.
 
즉,
.NET 라이브러리 전반에서 Action과 Func는 매우 광범위하게 활용된다.

---

## 언제 직접 Delegate를 만들까?

실무에서는 대부분
Action과 Func를 사용한다.
 
하지만
다음과 같은 경우에는
직접 Delegate를 만드는 것이 좋다.

```cs
public delegate void HealthChangedHandler(
    int currentHealth,
    int maxHealth);
```

이처럼
이름 자체가 의미를 가지는 경우이다.
 
또는
공개 API에서
동작의 의도를 명확하게 표현하고 싶을 때도
사용자 정의 Delegate가 도움이 된다.

---

## Action과 Func를 무조건 쓰는 것이 좋을까?

실무에서는 대부분 Action과 Func만으로 충분하다.
 
하지만 **의미 있는 이름이 필요한 경우**에는 사용자 정의 Delegate가 더 읽기 좋은 코드를 만들 수 있다.
 
예를 들어

```cs
Action<int, int>
```

보다

```
HealthChangedHandler
```

가 무엇을 위한 Delegate인지 훨씬 명확하다.
 
즉,
재사용성이 중요하면 Action과 Func를,
도메인 의미가 중요하면 사용자 정의 Delegate를 선택하는 것이 좋다.

---

## 실무에서 자주 하는 오해

가장 흔한 오해는

> Action과 Func는 Delegate와 다른 기능이다.

라는 것이다.
 
Action과 Func도 결국 Delegate이다.
 
단지 .NET에서 자주 사용하는 형태를 미리 정의해 둔 Delegate일 뿐이다.
 
또 하나의 오해는

> Func가 더 성능이 좋다.

라는 것이다.
 
성능 차이는 거의 없다.
 
컴파일 이후에는 모두 Delegate 객체로 처리되며, 선택 기준은 **가독성과 의미 표현**이다.

---

## 마무리

Action과 Func는 Delegate를 대체하는 새로운 기능이 아니라,
**자주 사용하는 Delegate 형태를 미리 정의해 둔 제네릭 Delegate**이다.
 
덕분에 메서드마다 새로운 Delegate를 선언할 필요가 없어졌고, 코드는 훨씬 간결해졌다.
실무에서는 대부분 Action과 Func를 사용하지만, 의미를 명확하게 표현해야 하는 공개 API나 이벤트에서는 사용자 정의 Delegate가 더 적합한 경우도 있다.
 
다음 글에서는 **익명 메서드(Anonymous Method)**를 살펴보며 Delegate를 위해 클래스를 만들 필요도, 메서드 이름을 만들 필요도 없게 된 과정을 알아보겠다.

---

## 핵심 정리

- Action은 반환값이 없는 Delegate이다.
- Func는 반환값이 있는 Delegate이다.
- Func의 마지막 Generic 타입은 반환형이다.
- Predicate는 bool을 반환하는 조건 검사용 Delegate이다.
- Action과 Func는 .NET에서 미리 정의한 제네릭 Delegate이다.
- 대부분의 실무 코드에서는 Action과 Func를 사용한다.
- 의미를 명확하게 표현해야 하는 경우에는 사용자 정의 Delegate가 더 적합할 수 있다.
