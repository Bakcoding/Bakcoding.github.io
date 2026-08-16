---
title: "[궁금시리즈] 6-9. EventHandler 패턴은 왜 존재할까?"
excerpt: "C#"
categories:
  - CSharp
series: question-series
tags:
  - CSharp
permalink: /programming/6-9-eventhandler/
toc: true
toc_sticky: true
date: 2026-07-27 18:20:46 +0900
last_modified_at: 2026-07-27
---

## 들어가며

이전 글에서는 Event가 Delegate를 안전하게 사용할 수 있도록 만든 기능이라는 것을 살펴보았다.
Event를 선언하는 가장 쉬운 방법은 다음과 같다.

```cs
public event Action Click;
```

또는

```cs
public event Action<int> HealthChanged;
```

처럼 작성하는 것이다.
 
그런데 .NET 라이브러리를 살펴보면 대부분 다음과 같이 선언되어 있다.

```cs
public event EventHandler Click;
```

또는

```cs
public event EventHandler<HealthChangedEventArgs> HealthChanged;
```

왜 굳이 EventHandler라는 새로운 Delegate를 사용하는 것일까?

---

## Action만으로도 충분하지 않을까?

예를 들어 체력이 변경되는 이벤트라면
다음처럼 작성할 수 있다.

```cs
public event Action<int> HealthChanged;
```

호출도 간단하다.

```cs
HealthChanged?.Invoke(80);
```

구독하는 쪽도

```cs
player.HealthChanged += hp =>
{
    Console.WriteLine(hp);
};
```

처럼 사용할 수 있다.
 
겉으로 보기에는
전혀 문제가 없어 보인다.

---

## 그런데 누가 이벤트를 발생시켰을까?

다음 코드를 보자.

```cs
HealthChanged?.Invoke(80);
```

여기서 80은 전달된다.
 
하지만
이 이벤트를 발생시킨 객체가 누구인지 알 수 없다.
 
예를 들어

```
Player

Enemy

NPC
```

모두
HealthChanged 이벤트를 가진다면
이벤트를 받는 쪽에서는
누가 보낸 것인지 알기 어렵다.

---

## 그래서 sender가 존재한다

.NET 이벤트는
첫 번째 매개변수로
항상

```
sender
```

를 전달한다.

```cs
public event EventHandler HealthChanged;
```

호출은

```cs
HealthChanged?.Invoke(this, EventArgs.Empty);
```

가 된다.
 
여기서

```
this

↓

이벤트를 발생시킨 객체
```

이다.
 
즉,
구독자는
누가 이벤트를 발생시켰는지
항상 알 수 있다.

---

## EventArgs는 왜 필요할까?

이번에는
체력도 함께 전달하고 싶다.
 
Action이라면

```cs
public event Action<int> HealthChanged;
```

가 된다.
 
하지만 나중에

```
현재 체력

최대 체력

데미지

회복 여부
```

등을 추가하고 싶다면?
 
Action은
계속 수정해야 한다.

```
Action<int, int>

↓

Action<int, int, bool>

↓

Action<int, int, bool, DamageType>
```

매개변수가 계속 늘어난다.

---

## EventArgs 하나로 묶는다

그래서
정보를 하나의 객체로 만든다.

```cs
public class HealthChangedEventArgs : EventArgs
{
    public int CurrentHealth { get; }

    public int MaxHealth { get; }

    public HealthChangedEventArgs(
        int currentHealth,
        int maxHealth)
    {
        CurrentHealth = currentHealth;
        MaxHealth = maxHealth;
    }
}
```

이제 이벤트는

```cs
public event EventHandler<HealthChangedEventArgs>
    HealthChanged;
```

가 된다.
 
호출은

```cs
HealthChanged?.Invoke(
    this,
    new HealthChangedEventArgs(80, 100));
```

이다.

구독하는 쪽은 어떻게 될까?

```cs
player.HealthChanged += OnHealthChanged;

void OnHealthChanged(
    object? sender,
    HealthChangedEventArgs e)
{
    Console.WriteLine(e.CurrentHealth);

    Console.WriteLine(e.MaxHealth);
}
```

이제 필요한 정보가
모두 EventArgs 안에 있다.

---

## EventArgs를 사용하는 장점

매개변수가 계속 늘어나면 호출하는 곳과
구독하는 곳을 모두 수정해야 한다.
 
하지만 EventArgs를 사용하면
새로운 정보를 클래스 안에 추가하면 된다.
 
예를 들어

```cs
public bool IsCritical { get; }
```

를 추가해도
이벤트 시그니처는
바뀌지 않는다.
 
즉,
확장성이 좋아진다.

---

## EventHandler는 Delegate일 뿐이다

많은 사람들이
EventHandler를
특별한 기능으로 생각한다.
 
실제로는
Delegate이다.
 
개념적으로는

```cs
public delegate void EventHandler(
    object? sender,
    EventArgs e);
```

와 비슷하다.
 
Generic 버전도

```cs
public delegate void EventHandler<TEventArgs>(
    object? sender,
    TEventArgs e)
    where TEventArgs : EventArgs;
```

와 같은 형태이다.
 
즉,
EventHandler도
미리 만들어진 Delegate이다.

---

## 실제 .NET에서는 어떻게 사용할까?

.NET 라이브러리의 대부분 이벤트는
이 패턴을 따른다.
 
예를 들어

```
Button.Click

TextBox.TextChanged

FileSystemWatcher.Changed

Timer.Elapsed
```

등
 
수많은 이벤트가

```
sender

+

EventArgs
```

형태를 사용한다.
 
즉,
EventHandler는
.NET의 표준 이벤트 패턴(Standard Event Pattern)이다.

---

## 항상 EventHandler를 사용해야 할까?

반드시 그런 것은 아니다.
 
예를 들어
게임 내부에서만 사용하는 이벤트라면

```cs
public event Action<int> HealthChanged;
```

처럼
 
간단하게 작성하는 것이 더 읽기 쉬운 경우도 많다.
 
반면
라이브러리를 만들거나
다른 개발자가 사용할 API를 공개하는 경우에는
EventHandler<TEventArgs> 패턴을 사용하는 것이 일반적이다.
 
즉,

- 내부 구현 → Action도 충분
- 공개 API → EventHandler 권장

이라는 기준으로 생각하면 된다.

---

## 실무에서 자주 하는 오해

가장 흔한 오해는

> EventHandler가 Action보다 성능이 좋다.

라는 것이다.
 
둘 다 Delegate이므로
성능 차이는 거의 없다.
 
선택 기준은 성능이 아니라
**표준화와 확장성**이다.
 
또 하나의 오해는

## EventArgs는 반드시 상속해야 한다.

라는 것이다.
 
최근 .NET에서는 EventArgs를 상속하지 않는 경우도 있지만,
공개 라이브러리나 .NET 표준 패턴을 따를 때는 EventArgs를 상속하는 것이 일반적이다.

---

## 마무리

EventHandler는 새로운 이벤트 시스템이 아니라, **.NET에서 권장하는 표준 Delegate 형태**이다.
이벤트를 발생시킨 객체를 sender로 전달하고, 필요한 데이터를 EventArgs에 담아 전달함으로써 확장성과 재사용성을 높일 수 있다.
 
작은 프로젝트에서는 Action 기반 이벤트만으로도 충분하지만, 여러 개발자가 함께 사용하는 라이브러리나 프레임워크에서는 EventHandler<TEventArgs\> 패턴이 더 일관되고 유지보수하기 쉬운 구조를 제공한다.
 
다음 글에서는 **Unity에서 Delegate와 Event를 어떻게 활용하는가**를 살펴보며 Action, event, UnityEvent의 차이와 올바른 사용 방법을 알아보겠다.

---

## 핵심 정리

- EventHandler도 Delegate의 한 종류이다.
- 첫 번째 매개변수 sender는 이벤트를 발생시킨 객체이다.
- EventArgs는 이벤트 데이터를 하나의 객체로 전달하기 위한 클래스이다.
- EventArgs를 사용하면 이벤트 시그니처를 변경하지 않고도 정보를 확장할 수 있다.
- .NET 라이브러리 대부분은 EventHandler<TEventArgs> 패턴을 사용한다.
- 내부 코드에서는 Action도 충분하지만, 공개 API에서는 EventHandler가 권장된다.
