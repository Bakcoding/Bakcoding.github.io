---
title: "[궁금시리즈] 6-5. 익명 메서드(Anonymous Method)는 왜 등장했을까?"
excerpt: "C#"
categories:
  - CSharp
series: question-series
tags:
  - CSharp
permalink: /programming/6-5-anonymous-method/
toc: true
toc_sticky: true
date: 2026-07-27 18:20:42 +0900
last_modified_at: 2026-07-27
---

## 들어가며

지금은 Delegate를 사용할 때 대부분 람다식을 작성한다.

```cs
button.Click += () =>
{
    Console.WriteLine("Click");
};
```

너무나 익숙한 코드이다.
 
하지만 초기 C#에는 람다식이 존재하지 않았다.
 
당시에는 Delegate를 사용하려면 반드시 메서드를 하나 만들어야 했다.

```cs
button.Click += OnClick;

void OnClick()
{
    Console.WriteLine("Click");
}
```

단 한 번만 사용할 메서드인데도 이름을 만들고 따로 선언해야 했다.
 
이러한 불편함을 해결하기 위해 등장한 기능이 **익명 메서드(Anonymous Method)**이다.

---

## Delegate는 항상 메서드가 필요했다

앞에서 Delegate를 사용할 때는 항상 이런 형태였다.

```cs
public delegate void MyDelegate();

void Hello()
{
    Console.WriteLine("Hello");
}

MyDelegate del = Hello;
```

Delegate는 메서드를 저장하는 객체이므로
항상 메서드가 하나 존재해야 한다.
 
그런데 문제는 한 번만 사용할 메서드도
굳이 이름을 만들어야 한다는 점이었다.

---

## 한 번만 사용할 메서드인데?

예를 들어
버튼 클릭 이벤트를 등록한다고 해보자.

```cs
button.Click += SaveData;
```

그런데 SaveData는
오직 이 버튼 하나에서만 사용된다.
 
그럼에도 불구하고

```cs
void SaveData()
{
    Console.WriteLine("저장");
}
```

라는 메서드를 따로 만들어야 한다.
 
프로젝트가 커질수록

```
OnClick1

OnClick2

OnClick3

OnSave

OnLoad

OnExit
```

처럼 비슷한 메서드가 계속 늘어나게 된다.

---

## 이름 없는 메서드를 만들 수 없을까?

여기서 자연스럽게 떠오른 생각이 있다.

> 한 번만 사용할 메서드라면 이름이 필요 없지 않을까?

그래서 C# 2.0에서는 익명 메서드가 등장했다.

```cs
MyDelegate del = delegate ()
{
    Console.WriteLine("Hello");
};
```

메서드 이름이 없다.
 
그래도 Delegate에는 저장할 수 있다.
 
즉,
메서드를 위해
이름을 만들 필요가 없어졌다.

---

## 기존 방식과 비교해 보자

기존 방식

```cs
void Hello()
{
    Console.WriteLine("Hello");
}

MyDelegate del = Hello;
```

익명 메서드

```cs
MyDelegate del = delegate ()
{
    Console.WriteLine("Hello");
};
```

둘은 동일하게 동작한다.
차이점은 메서드 이름이 있는가 없는가뿐이다.

---

## 매개변수도 사용할 수 있다

Delegate에 매개변수가 있다면
익명 메서드도 그대로 사용할 수 있다.

```cs
Action<string> print = delegate (string message)
{
    Console.WriteLine(message);
};
```

호출하면

```cs
print("Hello");
```

가 실행된다.

---

## 반환값도 가능하다

Func 역시 사용할 수 있다.

```cs
Func<int, int, int> add =
    delegate (int x, int y)
{
    return x + y;
};
```

호출하면

```cs
Console.WriteLine(add(3, 5));
```

결과는

```
8
```

이다.

---

## 그런데 여전히 코드가 길다

익명 메서드는
메서드 이름을 없앴다.
 
하지만

```cs
delegate (int x, int y)
{
    return x + y;
}
```

는 여전히 길다.
 
특히
Action과 Func를 사용할 때는
같은 타입을 반복해서 적어야 한다.
 
예를 들어

```cs
Action<string> print =
    delegate (string message)
{
    Console.WriteLine(message);
};
```

여기서

```
string

↓

string
```

을 두 번 적는다.
 
컴파일러는 이미 Action<string>을 보고
매개변수가 string이라는 것을 알고 있다.
 
그런데도 개발자가 다시 작성해야 했다.

---

## 그래서 람다가 등장한다

이 불편함을 해결하기 위해
C# 3.0에서는 람다식(Lambda Expression)이 등장했다.
 
같은 코드를

```cs
Action<string> print =
    message =>
{
    Console.WriteLine(message);
};
```

처럼 작성할 수 있게 되었다.
 
코드는 훨씬 짧아졌고,
컴파일러가 타입도 추론한다.
 
즉,
익명 메서드를 더욱 간결하게 만든 문법이
바로 람다식이다.

---

## 실제 .NET에서는 어떻게 동작할까?

익명 메서드 역시 결국 Delegate 객체를 생성한다.
 
즉,

```cs
delegate ()
{
    Console.WriteLine("Hello");
}
```

도

```cs
void Hello()
{
    Console.WriteLine("Hello");
}
```

를 Delegate에 등록하는 것과 본질적으로 같다.
 
차이는 **컴파일러가 이름 없는 메서드를 생성하여 Delegate에 연결한다는 것**이다.
 
즉,
익명 메서드는 새로운 실행 방식이 아니라
Delegate를 더 편리하게 작성하기 위한 문법이다.

---

## 익명 메서드는 지금도 사용할까?

현재는 거의 대부분 람다식을 사용한다.
 
예를 들어

```cs
button.Click += delegate
{
    Console.WriteLine("Click");
};
```

보다

```cs
button.Click += () =>
{
    Console.WriteLine("Click");
};
```

가 더 짧고 읽기 쉽다.
그래서 현대 C# 코드에서는
익명 메서드를 직접 사용하는 경우는 매우 드물다.
 
다만
기존 프로젝트나 오래된 코드에서는
여전히 자주 볼 수 있다.

---

## 실무에서 자주 하는 오해

가장 흔한 오해는

> 익명 메서드와 람다는 서로 다른 기능이다.

라는 것이다.
 
실제로 둘은 모두 Delegate를 생성하기 위한 문법이다.
람다는 익명 메서드를 더 간결하게 표현할 수 있도록 발전한 형태라고 이해하면 된다.
 
또 하나의 오해는

> 익명 메서드는 더 이상 사용할 수 없는 문법이다.

라는 것이다.
 
현재도 정상적으로 사용할 수 있으며, 단지 람다식이 더 간결하기 때문에 대부분의 코드에서 람다를 사용할 뿐이다.

---

## 마무리
익명 메서드는 Delegate를 위해 매번 이름 있는 메서드를 만들어야 하는 불편함을 해결하기 위해 등장했다.
이를 통해 한 번만 사용할 동작을 코드가 필요한 위치에서 바로 작성할 수 있게 되었고, Delegate 사용이 훨씬 편리해졌다.
 
하지만 문법은 여전히 다소 장황했고, 이러한 한계를 개선하기 위해 람다식이 등장했다.
오늘날 대부분의 C# 코드는 람다식을 사용하지만, 그 기반에는 익명 메서드와 Delegate가 있다는 점을 이해하는 것이 중요하다.
 
다음 글에서는 **람다식(Lambda Expression)은 왜 등장했을까?**를 살펴보며, 람다가 단순한 축약 문법이 아니라 컴파일러와 Delegate가 함께 만들어 내는 기능이라는 점을 알아보겠다.

---

## 핵심 정리

- 초기 C#에서는 Delegate를 사용하려면 이름 있는 메서드가 필요했다.
- 익명 메서드는 이름 없는 메서드를 직접 작성할 수 있도록 도입되었다.
- 익명 메서드는 매개변수와 반환값을 모두 지원한다.
- 익명 메서드도 내부적으로는 Delegate 객체를 생성한다.
- 람다식은 익명 메서드를 더 간결하게 표현하기 위해 등장했다.
- 현대 C#에서는 대부분 람다식을 사용하지만, 익명 메서드는 여전히 사용할 수 있다.
