---
title: "[궁금시리즈] 6-11. Delegate & Event에서 자주 하는 실수 총정리"
excerpt: "C#"
categories:
  - Programming
tags:
  - CSharp
permalink: /programming/6-11-delegate-event/
toc: true
toc_sticky: true
date: 2026-07-27
last_modified_at: 2026-07-27
---

Delegate와 Event는 C#에서 매우 강력한 기능이다.
메서드를 값처럼 전달하고, 객체 간의 결합도를 낮추며, 이벤트 기반 구조를 쉽게 만들 수 있다.
 
하지만 편리한 만큼 잘못 사용하면 디버깅이 어려워지고, 메모리 문제나 예기치 않은 동작을 만들기도 한다.
이번 글에서는 실무에서 가장 자주 발생하는 Delegate와 Event 관련 실수를 살펴보고, 올바른 사용 방법을 정리해 보자.

---

## 1. Event 대신 Delegate를 공개하기

다음과 같은 코드를 종종 볼 수 있다.

```cs
public Action HealthChanged;
```

겉보기에는 문제가 없어 보인다.
 
하지만 외부에서

```cs
player.HealthChanged?.Invoke();
```

또는

```cs
player.HealthChanged = null;
```

처럼 호출하거나 덮어쓸 수 있다.
 
이벤트를 발생시키는 권한은 객체 내부에 있어야 한다.
 
따라서 외부에 공개하는 이벤트라면

```cs
public event Action HealthChanged;
```

를 사용하는 것이 좋다.

---

## 2. 이벤트를 해제하지 않기

가장 흔한 실수이다.

```cs
player.HealthChanged += UpdateUI;
```

등록만 하고

```cs
player.HealthChanged -= UpdateUI;
```

를 호출하지 않는 경우가 많다.
 
이벤트를 발행하는 객체가 구독자를 계속 참조하므로
객체가 예상보다 오래 살아 있을 수 있다.
 
Unity에서는

```cs
private void OnEnable()
{
    player.HealthChanged += UpdateUI;
}

private void OnDisable()
{
    player.HealthChanged -= UpdateUI;
}
```

패턴을 사용하는 것이 일반적이다.

---

## 3. 람다를 등록하고 해제하지 못하는 경우

다음 코드는 문제가 있다.

```cs
player.HealthChanged += () =>
{
    Console.WriteLine("Changed");
};
```

나중에

```cs
player.HealthChanged -= () =>
{
    Console.WriteLine("Changed");
};
```

를 작성해도 해제되지 않는다.
 
두 람다는 모양은 같지만
서로 다른 Delegate 객체이기 때문이다.
 
해제가 필요하다면 메서드를 사용하거나
Delegate를 변수에 저장해야 한다.

```cs
Action handler = () => Console.WriteLine("Changed");

player.HealthChanged += handler;
player.HealthChanged -= handler;
```

---

## 4. Closure를 모르고 사용하는 경우
다음 코드를 보자.

```cs
List<Action> actions = new();

for (int i = 0; i < 3; i++)
{
    actions.Add(() => Console.WriteLine(i));
}
```

많은 사람이

```
0
1
2
```

를 기대한다.
 
하지만 실제 결과는

```
3
3
3
```

이다.
 
람다가 값이 아니라
변수 자체를 캡처했기 때문이다.
반복마다 새로운 변수를 만들어야 한다.

```cs
for (int i = 0; i < 3; i++)
{
    int current = i;

    actions.Add(() => Console.WriteLine(current));
}
```

---

## 5. 이벤트 안에서 예외를 처리하지 않는 경우

Multicast Delegate는
등록된 메서드를 순서대로 호출한다.

```
HealthChanged += SaveLog;
HealthChanged += UpdateUI;
HealthChanged += PlaySound;
```

그런데
첫 번째 메서드에서 예외가 발생하면
이후 메서드는 실행되지 않는다.
 
필요하다면 호출하는 쪽에서 예외 처리를 고려해야 한다.

```cs
foreach (Action handler in HealthChanged.GetInvocationList())
{
    try
    {
        handler();
    }
    catch (Exception ex)
    {
        Console.WriteLine(ex.Message);
    }
}
```

단, 이렇게 개별 호출하는 방식은 일반적인 패턴은 아니며, 모든 구독자를 반드시 실행해야 하는 경우에만 고려하면 된다.

---

## 6. Delegate를 Thread-Safe하게 호출하지 않는 경우

다음 코드가 있다고 하자.

```cs
HealthChanged?.Invoke();
```

대부분의 경우에는 충분하다.

하지만 여러 스레드에서 이벤트를 등록하거나 해제하는 환경에서는
null 검사 이후 다른 스레드가 구독을 해제할 수도 있다.
 
이를 방지하려면 Delegate를 지역 변수에 
복사한 뒤 호출하는 패턴이 사용되기도 한다.

```
Action? handler = HealthChanged;

handler?.Invoke();
```

최근 C#에서는 ?.Invoke()가 대부분의 상황에서 안전하게 동작하므로 일반적인 애플리케이션에서는 크게 걱정하지 않아도 된다. 

다만 멀티스레드 환경에서는 이러한 패턴이 사용되는 이유를 이해해 두면 도움이 된다.

---

## 7. 이벤트를 남용하기

이벤트는 매우 편리하다.

하지만 모든 객체가 모든 이벤트를 구독하기 시작하면
프로그램의 흐름을 추적하기 어려워진다.
 
예를 들어

```
Player

↓

Event

↓

UI

↓

Sound

↓

Achievement

↓

Analytics

↓

Quest

↓

Tutorial
```

이처럼
수많은 객체가 연결되면
누가 무엇을 호출하는지 파악하기 어렵다.
 
이벤트는
**정말 느슨한 결합이 필요한 경우**에 사용하는 것이 좋다.

---

## 8. UnityEvent를 게임 로직에 남용하기

UnityEvent는
Inspector 연결에는 매우 편리하다.
 
하지만
게임 로직까지 모두 UnityEvent로 구성하면

- 코드 추적이 어렵고
- 리팩터링 지원이 약하며
- 컴파일 타임 검사가 줄어든다.

게임 로직은 event Action UI 연결은 UnityEvent
를 사용하는 것이 일반적인 방식이다.

---

## Delegate와 Event 사용 기준

실무에서는 다음 기준으로 선택하면 대부분의 상황에 적합하다.

| 상황 | 추천 |
| ---- | ---- |
| 메서드를 전달하는 콜백 | Action / Func |
| 클래스 내부에서만 사용하는 Delegate | Action |
| 외부에 공개하는 이벤트 | event Action |
| 공개 라이브러리 API | EventHandler<TEventArgs> |
| Inspector 연결 | UnityEvent |
| UI Button 이벤트 | UnityEvent |

---

## 실무에서 기억해야 할 원칙

Delegate와 Event는 기능 자체보다 **언제 사용하는가**가 더 중요하다.
다음 세 가지 원칙만 기억해도 대부분의 실수를 피할 수 있다.

- 외부에 공개하는 이벤트는 event를 사용한다.
- 이벤트를 등록했다면 반드시 적절한 시점에 해제한다.
- 람다가 지역 변수를 캡처한다는 사실을 항상 염두에 둔다.

---

## 마무리

Delegate와 Event는 C#의 이벤트 기반 프로그래밍을 가능하게 하는 핵심 기능이다.
Delegate는 메서드를 값처럼 전달하는 방법을 제공하고, Event는 이를 안전하게 외부에 공개하기 위한 캡슐화를 제공한다. 여기에 람다식과 클로저를 이해하면 현대 C#의 대부분의 이벤트 코드를 자연스럽게 읽고 작성할 수 있다.
 
이번 챕터에서 배운 내용을 바탕으로 Action, Func, Event, EventHandler, UnityEvent를 상황에 맞게 선택한다면 더욱 유지보수하기 쉽고 안정적인 코드를 작성할 수 있을 것이다.
 
다음 챕터에서는 **LINQ**를 살펴보며, 컬렉션 데이터를 SQL처럼 간결하게 다루는 방법과 내부 동작 원리를 알아보겠다.

---

## 핵심 정리

- 외부에 공개하는 Delegate는 event로 감싸는 것이 좋다.
- 이벤트를 등록했다면 반드시 적절한 시점에 해제한다.
- 람다는 값을 복사하는 것이 아니라 변수를 캡처한다.
- 람다를 직접 등록하면 같은 코드로도 해제할 수 없다.
- Multicast Delegate는 하나의 예외로 이후 호출이 중단될 수 있다.
- 이벤트는 필요한 곳에만 사용하고 남용하지 않는다.
- 게임 로직은 event, Inspector 연결은 UnityEvent를 사용하는 것이 일반적이다.
