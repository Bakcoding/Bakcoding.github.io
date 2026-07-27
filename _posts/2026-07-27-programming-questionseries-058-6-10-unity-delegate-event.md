---
title: "[궁금시리즈] 6-10. Unity에서 Delegate와 Event는 어떻게 사용할까?"
excerpt: "C#"
categories:
  - Programming
tags:
  - CSharp
permalink: /programming/6-10-unity-delegate-event/
toc: true
toc_sticky: true
date: 2026-07-27
last_modified_at: 2026-07-27
---

Unity 프로젝트를 보면 다음과 같은 코드를 자주 볼 수 있다.

```cs
button.onClick.AddListener(OnClick);
```

또는

```cs
public static Action OnGameStart;
```

또는

```cs
public event Action HealthChanged;
```

모두 이벤트처럼 사용되지만 사실은 서로 다른 기능이다.
 
이번 글에서는 Unity에서 가장 많이 사용하는

- Action
- event
- UnityEvent

의 차이와 언제 무엇을 사용하는 것이 좋은지 알아보자.

---

## Action

가장 단순한 방법이다.

```cs
public Action Jump;
```

호출은

```cs
Jump?.Invoke();
```

등록은

```cs
player.Jump += PlayJumpSound;
```

이다.
 
매우 간단하다.

---

## 그런데 Action은 위험하다

문제는 외부에서도

```cs
player.Jump?.Invoke();
```

가 가능하다는 것이다.
 
심지어

```
player.Jump = null;
```

도 가능하다.
 
즉, 외부 코드가
Delegate를 마음대로 변경할 수 있다.

---

## Event를 사용하는 이유

그래서 대부분의 경우 다음처럼 작성한다.

```cs
public event Action Jump;
```

이제 외부에서는

```cs
player.Jump += PlayJumpSound;
```

와

```cs
player.Jump -= PlayJumpSound;
```

만 가능하다.
 
호출은 Player 내부에서만 가능하다.

```cs
Jump?.Invoke();
```

이렇게 하면
객체의 책임이 명확해진다.

---

## UnityEvent는 무엇일까?

Unity에는 C# Event 외에도
UnityEvent가 존재한다.
 
예를 들어

```cs
Button.onClick
```

은 C# Event가 아니다.
UnityEvent이다.

---

## UnityEvent의 장점

가장 큰 장점은 Inspector에서 연결할 수 있다는 것이다.
 
예를 들어 Button을 선택하면

```
On Click ()

+

Drag & Drop

↓

메서드 선택
```

처럼
코드를 작성하지 않아도
메서드를 연결할 수 있다.
 
디자이너도
직접 이벤트를 연결할 수 있다.

---

## UnityEvent의 단점

편리하지만
단점도 있다.

- Reflection 사용
- Inspector 의존
- 런타임 오류 확인이 어려움
- 코드 추적이 어려움

또한 Action보다
약간의 오버헤드가 있다.
 
대부분의 게임에서는 큰 차이는 아니지만
매 프레임 호출되는 이벤트에는 적합하지 않다.

---

## 언제 Action을 사용할까?

간단한 콜백이라면 Action이 가장 좋다.
 
예를 들어

```cs
Task.Run(...)
```

처럼 
일회성 콜백
또는
클래스 내부에서만 사용하는 Delegate라면
Action으로 충분하다.

---

## 언제 Event를 사용할까?

다른 객체가 구독해야 하는 이벤트라면
Event가 좋다.
 
예를 들어

```
플레이어 사망

↓

UI

↓

사운드

↓

업적

↓

로그
```

이처럼 여러 객체가
반응해야 하는 상황이다.
 
실무에서는
게임 시스템 간의 통신은
대부분 Event를 사용한다.

---

## 언제 UnityEvent를 사용할까?

UI에서는 UnityEvent가 매우 편리하다.
 
예를 들어

```
Button

↓

OnClick

↓

Inspector 연결
```

처럼
프로그래머가 아닌
기획자나 디자이너도
이벤트를 연결할 수 있다.
반면
게임 로직까지
UnityEvent를 남용하는 것은
추천하지 않는다.

---

## 이벤트 해제를 잊지 말자

Unity에서
가장 많이 발생하는 버그 중 하나이다.

```cs
player.HealthChanged += UpdateUI;
```

등록만 하고
해제를 하지 않는다.
 
그러면
Destroy된 객체가
여전히 이벤트를 구독하고 있을 수 있다.
 
결국

```
MissingReferenceException
```

또는
예상보다 오래 객체가 살아남는 문제가 발생할 수 있다.

---

## OnEnable / OnDisable 패턴

Unity에서는
다음 패턴을 가장 많이 사용한다.

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

이렇게 하면 객체가 활성화될 때 등록하고
비활성화될 때 항상 해제한다.
 
가장 안전한 방법이다.

---

## static Event도 주의하자

다음처럼
전역 이벤트를 만드는 경우가 있다.

```cs
public static event Action GameStarted;
```

편리하지만
구독 해제를 하지 않으면
씬이 바뀌어도
참조가 계속 유지될 수 있다.
특히
Singleton과 함께 사용할 때
메모리 관리에 주의해야 한다.

---

## 실제 Unity에서는 어떻게 선택할까?

실무에서는
대략 다음 기준을 사용한다.

| 상황 | 추천 |
| ----- | ---- |
| 클래스 내부 콜백 | Action |
| 외부에 공개하는 이벤트 | event Action |
| Inspector 연결 | UnityEvent |
| UI Button | UnityEvent |
| 게임 시스템 이벤트 | event Action |
| 내부 알고리즘 콜백 | Action |

이 정도만 기억해도 대부분의 상황에서
올바른 선택을 할 수 있다.

---

## UnityEvent는 Event를 대체할까?

많은 초보 개발자가 UnityEvent만 있으면
C# Event가 필요 없다고 생각한다.
 
하지만 둘은 목적이 다르다.
UnityEvent는 Inspector와의 연동을 위해 만들어졌고,
C# Event는 코드에서 안전하게 이벤트를 공개하기 위한 기능이다.
 
게임 로직은 Event, 에디터 연결은 UnityEvent라는 기준이 가장 일반적이다.

---

## 실무에서 자주 하는 오해

가장 흔한 오해는

> Unity에서는 UnityEvent만 사용하면 된다.

라는 것이다.
 
UnityEvent는 UI나 Inspector 기반 작업에는 편리하지만,
게임 로직에서는 Event가 더 빠르고 타입 안전하며 코드 추적도 쉽다.
 
또 하나의 오해는

> 이벤트는 해제하지 않아도 된다.

라는 것이다.
 
Unity에서는 이벤트를 해제하지 않으면
예상하지 못한 호출이나 객체 참조 유지로 인해 버그가 발생할 수 있다.
 
특히 OnEnable()에서 등록했다면 OnDisable()에서 해제하는 습관을 들이는 것이 좋다.

---

## 마무리

Unity에서는 Action, Event, UnityEvent가 모두 사용되지만, 각각의 역할은 다르다.
Action은 간단한 콜백을 표현하기에 적합하고, Event는 다른 객체가 구독하는 게임 로직을 안전하게 공개하는 데 적합하다. UnityEvent는 Inspector에서 이벤트를 연결할 수 있다는 장점이 있어 UI와 에디터 기반 작업에서 특히 유용하다.
 
이들의 차이를 이해하고 상황에 맞게 선택하면 코드의 유지보수성과 안정성을 크게 높일 수 있다. 또한 이벤트를 등록했다면 적절한 시점에 반드시 해제하는 습관을 갖는 것이 중요하다.
 
다음 글에서는 **Delegate & Event에서 자주 하는 실수 총정리**를 통해 지금까지 배운 내용을 실무 관점에서 다시 정리해 보겠다.

---

## 핵심 정리

- Action은 간단한 콜백에 적합하다.
- 외부에 공개하는 이벤트는 event Action을 사용하는 것이 좋다.
- UnityEvent는 Inspector에서 연결할 수 있는 Unity 전용 이벤트 시스템이다.
- 게임 로직은 Event, UI 연결은 UnityEvent를 사용하는 것이 일반적이다.
- 이벤트를 등록했다면 반드시 적절한 시점에 해제해야 한다.
- Unity에서는 OnEnable() / OnDisable() 패턴으로 이벤트를 관리하는 것이 가장 많이 사용된다.
- static event는 편리하지만 생명 주기 관리에 주의해야 한다.
