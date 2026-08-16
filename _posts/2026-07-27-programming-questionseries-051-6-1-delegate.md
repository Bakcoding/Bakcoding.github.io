---
title: "[궁금시리즈] 6-1. Delegate는 왜 등장했을까?"
excerpt: "C#"
categories:
  - CSharp
series: question-series
tags:
  - CSharp
permalink: /programming/6-1-delegate/
toc: true
toc_sticky: true
date: 2026-07-27 18:20:38 +0900
last_modified_at: 2026-07-27
---

## 들어가며

프로그래밍을 하다 보면 이런 상황을 자주 만난다.

예를 들어 게임에서 버튼을 눌렀을 때 실행되는 기능이 매번 다르다고 생각해 보자.

- 시작 버튼 → 게임 시작
- 종료 버튼 → 게임 종료
- 설정 버튼 → 설정 창 열기

버튼은 모두 동일하지만, 실행되는 동작은 서로 다르다.

그렇다면 버튼 클래스는 이 모든 기능을 직접 알고 있어야 할까?

아니면 실행할 동작만 외부에서 전달받으면 될까?

이러한 문제를 해결하기 위해 C#에는 **Delegate**라는 기능이 등장했다.

---

## Delegate가 없었다면?

다음과 같은 버튼 클래스가 있다고 가정해 보자.

```cs
public class Button
{
    public void Click()
    {
        // 게임 시작?
        // 게임 종료?
        // 설정 열기?
    }
}
```

버튼은 클릭되었다는 사실만 알고 있다.
 
하지만
어떤 기능을 실행해야 하는지는 알지 못한다.

그렇다면 가장 먼저 떠올릴 수 있는 방법은 조건문이다.

```cs
public class Button
{
    public int Type;

    public void Click()
    {
        if (Type == 0)
            StartGame();

        else if (Type == 1)
            ExitGame();

        else if (Type == 2)
            OpenSetting();
    }
}
```

처음에는 괜찮아 보인다.
 
하지만 기능이 계속 늘어난다면 어떨까?

```
게임 시작

게임 종료

설정

저장

불러오기

로그인

로그아웃

...
```

버튼 클래스는 계속 수정되어야 한다.

새로운 기능 하나가 추가될 때마다
버튼 코드도 수정해야 한다.
 
즉,
버튼과 실제 기능이
강하게 결합(Coupling)되어 버린다.

---

## 인터페이스를 사용할 수도 있다

객체지향에서는
보통 인터페이스를 사용한다.

```cs
public interface ICommand
{
    void Execute();
}
```

그리고

```cs
public class StartCommand : ICommand
{
    public void Execute()
    {
        Console.WriteLine("게임 시작");
    }
}
```

버튼은

```cs
public class Button
{
    private readonly ICommand _command;

    public Button(ICommand command)
    {
        _command = command;
    }

    public void Click()
    {
        _command.Execute();
    }
}
```

이제 버튼은 무슨 기능인지 모른다.
그저 Execute만 호출한다.
 
객체지향적으로는 매우 좋은 구조이다.

---

## 그런데 너무 무겁다

문제는 기능 하나마다
클래스를 만들어야 한다는 것이다.

예를 들어

```
게임 시작

↓

StartCommand
```
```
게임 종료

↓

ExitCommand
```
```
설정

↓

SettingCommand
```

기능이 많아질수록
Command 클래스도 계속 늘어난다.

단순히 메서드 하나 실행하려고
클래스를 하나씩 만드는 것은
다소 번거롭다.

---

## 함수 자체를 전달할 수는 없을까?

여기서 자연스럽게 떠오르는 생각이 있다.

> 메서드를 변수처럼 전달할 수 있으면 되지 않을까?
 
예를 들어

```
버튼

↓

게임 시작 메서드 전달
```

또는

```
버튼

↓

게임 종료 메서드 전달
```

처럼 실행할 메서드만 넘겨주면
버튼은 그 메서드를 호출하기만 하면 된다.
 
즉,
객체 전체가 아니라
**함수 자체를 전달하고 싶은 것**이다.

---

## C#은 함수도 하나의 값처럼 다룰 수 있다

바로 이것이
Delegate의 역할이다.
 
예를 들어

```
public delegate void ButtonAction();
```

라는 Delegate를 만들면
다음과 같이 메서드를 저장할 수 있다.

```
ButtonAction action = StartGame;
```

그리고
필요한 순간 호출한다.

```
action();
```

또는

```
action.Invoke();
```

라고 작성해도 된다.
 
중요한 점은
변수 안에 문자열이나 숫자가 들어간 것이 아니라
**실행할 메서드가 저장되어 있다는 것**이다.

---

## Delegate를 사용하면 무엇이 달라질까?

버튼은 더 이상 게임 시작도 모르고 게임 종료도 모른다.

```cs
public class Button
{
    private readonly ButtonAction _action;

    public Button(ButtonAction action)
    {
        _action = action;
    }

    public void Click()
    {
        _action();
    }
}
```

사용하는 쪽에서
원하는 메서드만 전달한다.

```cs
Button startButton = new Button(StartGame);

Button exitButton = new Button(ExitGame);
```

이제
Button 클래스는
새로운 기능이 생겨도
전혀 수정할 필요가 없다.

---

## 이것이 전략 패턴(Strategy Pattern)의 핵심이다

Delegate는 실제로
전략 패턴을 매우 쉽게 구현할 수 있게 해 준다.
 
예를 들어
정렬 기능이 있다고 하자.

오름차순

```
Ascending
```

내림차순

```
Descending
```

길이순

```
Length
```

등

정렬 방식만 바뀐다.
 
기존에는 전략마다 클래스를 만들었지만,
Delegate를 사용하면 정렬 기준이 되는 메서드만 전달하면 된다.
 
즉,
**동작(Behavior)을 객체처럼 전달**할 수 있게 된다.

---

## 왜 언어 차원에서 지원할까?

일부 언어에서는 함수를 전달하기 위해
복잡한 객체를 직접 만들어야 한다.
 
하지만 C#은
Delegate를 언어 기능으로 제공한다.
 
그 이유는 함수를 전달하는 작업이
생각보다 매우 자주 발생하기 때문이다.
 
실제로 앞으로 배울

```
Lambda

LINQ

Event

Task

Thread

Timer

Unity Button

UnityEvent
```

모두 Delegate를 기반으로 만들어져 있다.
 
즉,
Delegate는 C#의 수많은 기능을 연결하는
핵심 구성 요소이다.

---

## 실제 .NET에서는 어떻게 사용될까?

Delegate는 .NET 라이브러리 전반에서 매우 널리 사용된다.
 
예를 들어 List<T>의 Sort() 메서드는 정렬 기준을 Delegate로 전달받는다.

```cs
numbers.Sort((x, y) => x.CompareTo(y));
```

또한 Task.Run() 역시 실행할 작업을 Delegate로 전달받는다.

```cs
await Task.Run(() =>
{
    DoWork();
});
```

이처럼 .NET은 "무엇을 실행할지"를 메서드 형태로 전달받아 다양한 기능을 구현한다.

---

## 실무에서 자주 하는 오해

가장 흔한 오해는

> Delegate는 단순히 메서드를 호출하는 문법이다.

라는 것이다.
 
실제로 Delegate의 핵심은 **메서드를 저장하고 전달할 수 있다는 것**이다.
 
즉,

- 메서드를 변수에 저장하고,
- 다른 객체에 전달하고,
- 나중에 실행할 수 있다.

이러한 특성 덕분에 느슨한 결합(Loose Coupling)을 만들고, 재사용성과 확장성을 높일 수 있다.

---

## 마무리

Delegate는 메서드를 단순히 호출하기 위한 기능이 아니라, **메서드를 하나의 값처럼 저장하고 전달하기 위한 기능**이다.

이를 통해 객체는 어떤 기능이 실행되는지 알 필요 없이, 전달받은 동작만 실행하면 된다. 이러한 구조는 객체 간의 결합도를 낮추고, 새로운 기능이 추가되어도 기존 코드를 수정하지 않아도 되는 유연한 설계를 가능하게 한다.

앞으로 살펴볼 람다식, 이벤트, LINQ, 비동기 프로그래밍까지 모두 Delegate를 기반으로 동작한다. Delegate를 제대로 이해하면 C#의 여러 기능이 하나의 흐름으로 연결되어 보이기 시작한다.
 
다음 글에서는 **Delegate는 내부적으로 어떻게 동작할까?**를 살펴보며 Delegate 객체가 메서드와 인스턴스를 어떻게 저장하고 호출하는지 알아보겠다.

---

## 핵심 정리

- Delegate는 메서드를 저장하고 전달하기 위한 기능이다.
- Delegate가 등장하기 전에는 조건문이나 인터페이스를 사용하는 경우가 많았다.
- Delegate를 사용하면 실행할 동작을 외부에서 전달할 수 있다.
- 객체는 기능의 구현을 몰라도 전달받은 Delegate만 호출하면 된다.
- Delegate는 느슨한 결합과 전략 패턴 구현에 유용하다.
- 람다식, LINQ, Event, Task 등 C#의 많은 기능은 Delegate를 기반으로 동작한다.
