---
title: "[궁금시리즈] 6-6. 람다식(Lambda Expression)은 왜 등장했을까?"
excerpt: "[궁금시리즈] 6-6. 람다식(Lambda Expression)은 왜 등장했을까? 내용을 정리한다."
categories:
  - Programming
tags:
  - General
permalink: /programming/6-6-lambda-expression/
toc: true
toc_sticky: true
date: 2026-07-27
last_modified_at: 2026-07-27
---

현대 C#에서 가장 자주 볼 수 있는 문법 중 하나가 바로 람다식이다.
 
예를 들어

```cs
numbers.Where(x => x > 10);
```

또는

```cs
button.Click += () =>
{
    Console.WriteLine("Click");
};
```

이처럼 => 연산자는 거의 모든 C# 프로젝트에서 사용된다.
 
하지만 람다식은 새로운 실행 방식이 아니다.
람다는 **Delegate를 더 간결하고 읽기 쉽게 작성하기 위해 등장한 문법**이다.
 
이번 글에서는 람다가 왜 등장했으며 내부적으로 어떻게 동작하는지 알아보자.

---

## 익명 메서드의 한계

이전 글에서 익명 메서드를 살펴보았다.

```cs
Action<string> print =
    delegate (string message)
{
    Console.WriteLine(message);
};
```

메서드 이름은 없어졌지만
여전히 코드가 길다.
 
특히

```
Action<string>
```

에서 이미 매개변수가 string이라는 것을 알 수 있는데
 
다시

```
delegate (string message)
```

를 작성해야 한다.
 
즉,
컴파일러가 이미 알고 있는 정보를
개발자가 반복해서 적고 있었다.

---

## 더 짧게 표현할 수 없을까?

그래서 등장한 것이 람다식이다.
 
같은 코드를

```cs
Action<string> print =
    message =>
{
    Console.WriteLine(message);
};
```

처럼 작성할 수 있다.
 
컴파일러가 이미

```
Action<string>
```

을 보고 매개변수 타입을 알고 있기 때문에
타입을 생략할 수 있다.

---

## => 는 무엇을 의미할까?

람다 연산자인

```
=>
```

는
 
"입력을 받아"
↓
"이 동작을 수행한다."
라는 의미를 가진다.
 
예를 들어

```
x => Console.WriteLine(x);
```

는 개념적으로

```
x를 입력받아서

↓

Console.WriteLine(x)를 실행한다.
```

라는 의미이다.

---

## Expression Lambda

가장 많이 사용하는 형태이다.

```
x => x * x
```

한 줄짜리 식(Expression)을 작성한다.
 
컴파일러가 자동으로

```
return
```

을 추가한다.
 
즉,
다음과 같다.

```cs
(int x) =>
{
    return x * x;
}
```

---

## Statement Lambda

여러 줄의 코드가 필요하면
중괄호를 사용한다.

```cs
x =>
{
    Console.WriteLine(x);

    return x * x;
}
```

이 경우에는 직접

```
return
```

을 작성해야 한다.

---

## 타입 추론(Type Inference)

람다가 간결한 가장 큰 이유는
타입 추론이다.
 
예를 들어

```cs
Func<int, int> square =
    x => x * x;
```

에서

```
Func<int, int>
```

를 보고 컴파일러는

```
x는 int

↓

반환도 int
```

라는 것을 이미 알고 있다.
 
그래서

```
(int x)
```

를 작성하지 않아도 된다.
 
물론 명시적으로
작성하는 것도 가능하다.

```cs
Func<int, int> square =
    (int x) => x * x;
```

두 코드는 동일하게 동작한다.

---

## 람다는 Delegate일까?

많은 사람들이
람다가 새로운 객체라고 생각한다.
 
하지만
다음 코드를 보자.

```cs
Action action =
    () => Console.WriteLine("Hello");
```

결국 람다는
Action이라는 Delegate에 저장된다.
 
즉,
람다는 Delegate가 있어야 사용할 수 있다.
람다는 Delegate를 생성하기 위한 문법이다.

---

## 실제 컴파일 과정

예를 들어

```cs
Action action =
    () => Console.WriteLine("Hello");
```

를 작성하면 컴파일러는
개념적으로 다음과 비슷한 코드로 변환한다.

```cs
void AnonymousMethod()
{
    Console.WriteLine("Hello");
}

Action action = AnonymousMethod;
```

즉,
람다가 실행되는 것이 아니라 컴파일러가
메서드와 Delegate를 만들어 준다.

---

## 실제 .NET에서는 어떻게 사용할까?

람다는 .NET 라이브러리 전반에서 사용된다.
 
예를 들어

```cs
numbers.ForEach(x =>
{
    Console.WriteLine(x);
});
```

여기서 ForEach()는

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

역시 람다가 아니라 Action Delegate를 전달하는 것이다.

LINQ 역시

```cs
numbers.Where(x => x > 10);
```

처럼 람다를 사용하지만,
내부적으로는 Predicate 또는 Func Delegate가 전달된다.

즉,
람다는 Delegate를 생성하기 위한 편리한 문법이다.

---

## Expression Tree와는 다르다

여기서 하나 주의할 점이 있다.
람다는 항상 Delegate가 되는 것은 아니다.

예를 들어

```cs
Expression<Func<int, bool>>
```

처럼 사용하면
람다는 **코드가 아니라 코드의 구조(Expression Tree)** 로 변환된다.
 
이 기능은 LINQ to SQL이나 Entity Framework처럼
람다를 SQL로 변환해야 하는 기술에서 사용된다.
 
하지만 일반적인 람다는 대부분 Delegate로 컴파일된다고 이해하면 충분하다.
Expression Tree는 이후 Reflection 챕터에서 다시 자세히 살펴보겠다.

---

## 실무에서 자주 하는 오해

가장 흔한 오해는

> 람다는 Delegate와 다른 기능이다.

라는 것이다.
 
람다는 Delegate를 더 간결하게 생성하기 위한 문법이다.
Delegate가 없다면 일반적인 람다도 존재할 수 없다.
 
또 하나의 오해는

> 람다가 더 빠르다.

라는 것이다.
 
람다는 성능을 높이기 위해 만들어진 기능이 아니다.
컴파일 이후에는 대부분 Delegate로 변환되므로, 선택 기준은 **가독성과 생산성**이다.

---

## 마무리

람다식은 익명 메서드를 더욱 간결하게 표현하기 위해 등장한 문법이다.
=> 연산자를 사용하면 컴파일러가 타입을 추론하고, 필요한 메서드와 Delegate를 자동으로 생성해 주므로 코드를 훨씬 짧고 읽기 쉽게 작성할 수 있다.
 
하지만 람다식이 새로운 실행 방식을 제공하는 것은 아니다. 대부분의 람다는 결국 Delegate로 컴파일되며, 람다의 진정한 가치는 메서드를 더 자연스럽게 전달하고 조합할 수 있게 해 준다는 데 있다.
 
다음 글에서는 **람다가 지역 변수를 어떻게 기억하는지**, 즉 **Closure(클로저)** 의 동작 원리를 살펴보며 컴파일러가 숨겨서 생성하는 Display Class와 메모리 구조를 알아보겠다.

---

## 핵심 정리

- 람다식은 Delegate를 간결하게 생성하기 위한 문법이다.
- 익명 메서드의 장황한 문법을 개선하기 위해 등장했다.
- =>는 입력을 받아 특정 동작을 수행한다는 의미를 가진다.
- Expression Lambda는 식 하나로 구성되며 반환값을 자동으로 반환한다.
- Statement Lambda는 여러 줄의 코드를 작성할 수 있다.
- 컴파일러는 람다를 메서드와 Delegate로 변환한다.
- 일반적인 람다는 Delegate로 컴파일되며, Expression<Func<...>>에서는 Expression Tree로 변환된다.
