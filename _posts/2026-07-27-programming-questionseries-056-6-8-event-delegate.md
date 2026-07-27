---
title: "[궁금시리즈] 6-8. Event는 Delegate와 무엇이 다를까?"
excerpt: "C#"
categories:
  - Programming
tags:
  - CSharp
permalink: /programming/6-8-event-delegate/
toc: true
toc_sticky: true
date: 2026-07-27
last_modified_at: 2026-07-27
---

C#에서는 이벤트를 선언할 때 다음과 같이 작성한다.

```cs
public event Action Click;
```

처음 보면

> Delegate 앞에 event만 붙은 것 아닌가?

라고 생각하기 쉽다.
 
실제로 Event는 Delegate를 기반으로 만들어졌다.
 
하지만 Delegate와 Event는 역할이 다르다.
Delegate는 메서드를 저장하고 호출하기 위한 기능이고,
Event는 **외부에서 Delegate를 안전하게 사용할 수 있도록 제한하는 기능**이다.
 
이번 글에서는 Event가 왜 등장했는지 살펴보자.

---

## Delegate만으로도 이벤트를 만들 수 있다

다음과 같이 Delegate를 공개했다고 가정해 보자.

```cs
public class Button
{
    public Action Click;

    public void OnClick()
    {
        Click?.Invoke();
    }
}
```

사용자는

```cs
button.Click += OpenMenu;
```

처럼 등록할 수 있다.
 
겉보기에는 이벤트처럼 동작한다.
그런데 문제가 하나 있다.

---

## 외부에서 마음대로 호출할 수 있다

Delegate는 메서드를 호출하는 기능이다.
 
따라서 외부에서도

```cs
button.Click?.Invoke();
```

를 실행할 수 있다.
 
즉,
버튼을 누르지도 않았는데
클릭 이벤트가 발생한다.

---

## Delegate 자체를 바꿔버릴 수도 있다

더 큰 문제는 다음 코드도 가능하다는 것이다.

```cs
button.Click = null;
```

등록된 모든 메서드가
한 번에 사라진다.
 
심지어

```cs
button.Click = ExitGame;
```

처럼 기존 등록을 모두 덮어쓸 수도 있다.
 
즉,
외부 코드가
이벤트를 완전히 망가뜨릴 수 있다.

---

## 이벤트는 누가 발생시켜야 할까?

버튼 클릭 이벤트는 누가 발생시켜야 할까?
 
당연히 버튼 자신이다.
 
사용자는

> "버튼이 클릭되었을 때"

실행할 메서드만 등록하면 된다.
 
이벤트를 발생시키는 것은
Button 클래스의 책임이다.

---

## 그래서 Event가 등장했다

Event를 사용하면 다음처럼 작성한다.

```cs
public class Button
{
    public event Action Click;

    public void OnClick()
    {
        Click?.Invoke();
    }
}
```

이제 외부에서는

```cs
button.Click += OpenMenu;
```

등록할 수 있고

```cs
button.Click -= OpenMenu;
```

해제할 수도 있다.
 
하지만
다음은 불가능하다.

```cs
button.Click?.Invoke();
```

컴파일 오류가 발생한다.
 
또한

```cs
button.Click = null;
```

역시
컴파일 오류가 발생한다.

---

## Event는 무엇을 제한할까?

Event는 외부에서
다음 두 가지만 허용한다.

```
+=

-=
```

즉,
등록과 해제만 가능하다.
 
반면
다음은 모두 금지된다.

```
Invoke()

=

null 대입

Delegate 교체
```

이렇게 함으로써
이벤트를 발생시키는 권한을
클래스 내부만 가지게 된다.

---

## 캡슐화를 위한 기능

객체지향의 핵심 중 하나는
캡슐화이다.
 
Button은 버튼 상태를 관리한다.
Click 이벤트 역시 Button이 관리해야 한다.
 
외부에서는
"이 이벤트가 발생하면
이 메서드를 실행해 주세요."
만 말할 수 있어야 한다.
 
실제로 이벤트를 발생시키는 것은
Button만 할 수 있어야 한다.

---

## Event는 Delegate를 감싼 문법이다

많은 사람들이
Event를 새로운 기능이라고 생각한다.
 
실제로는 Delegate를
캡슐화한 문법이다.
 
개념적으로는

```
Delegate

↓

접근 제한

↓

Event
```

라고 생각하면 된다.
 
즉,
Event는
Delegate를
안전하게 사용하기 위한 기능이다.

---

## 실제 .NET에서는 어떻게 사용할까?

.NET에서는 대부분의 이벤트가
다음처럼 선언된다.

```cs
public event EventHandler Click;
```

또는

```cs
public event EventHandler<ButtonEventArgs> Click;
```

예를 들어
WinForms의 버튼, WPF의 버튼, 파일 시스템 감시, 타이머 등
거의 모든 이벤트는 event 키워드를 사용한다.
 
즉,
.NET 라이브러리에서도
Delegate를 직접 공개하는 경우보다
Event를 사용하는 경우가 훨씬 많다.

---

## Unity에서는?

Unity의

```cs
Button.onClick
```

은 C# Event가 아니다.
 
Unity에서 제공하는
**UnityEvent**이다.
 
사용 방법은 비슷하지만
내부 구현은 다르다.
 
따라서
일반 C# Event와
UnityEvent는
구분해서 이해하는 것이 좋다.
 
이에 대해서는
Unity 편에서
다시 자세히 다룬다.

---

## Event에도 한계는 있다

Event는 외부에서 Invoke()를 막아 주지만,
이벤트에 등록된 메서드가 언제 해제되는지는 관리하지 않는다.
 
예를 들어 객체가 사라졌는데도 이벤트를 해제하지 않으면,
이벤트를 발행하는 객체가 구독자를 계속 참조하게 되어
예상보다 오래 메모리에 남을 수 있다.
 
즉, Event는 캡슐화를 제공하지만 **구독 해제(-=)**는 여전히 개발자의 책임이다.
이 부분은 다음 글과 Unity 편에서 자세히 살펴본다.

---

## 실무에서 자주 하는 오해

가장 흔한 오해는

> Event는 Delegate와 완전히 다른 기능이다.

라는 것이다.
 
Event는 Delegate 위에 캡슐화를 추가한 언어 기능이다.
내부적으로는 Delegate를 사용한다.
 
또 하나의 오해는

> Event를 사용하면 메모리 누수가 발생하지 않는다.

라는 것이다.
 
Event는 호출 권한만 제한할 뿐,
구독한 객체의 생명 주기를 관리하지는 않는다.
 
이벤트를 구독했다면 적절한 시점에 반드시 해제해야 한다.

---

## 마무리

Delegate는 메서드를 저장하고 호출하기 위한 기능이고,
Event는 그 Delegate를 외부에서 안전하게 사용할 수 있도록 제한하는 기능이다.
 
Event를 사용하면 외부에서는 이벤트를 구독하거나 해제할 수만 있고,
실제 이벤트를 발생시키는 권한은 해당 객체만 가진다.
 
이러한 구조는 객체의 책임을 명확하게 하고, 외부 코드가 내부 동작을 임의로 변경하는 것을 방지한다.
 
따라서 이벤트를 외부에 공개해야 하는 경우라면 Delegate보다 Event를 사용하는 것이 일반적인 설계 방식이다.
다음 글에서는 **.NET이 권장하는 EventHandler 패턴**을 살펴보며 EventHandler, EventArgs가 왜 존재하는지와 사용자 정의 이벤트를 작성하는 방법을 알아보겠다.

---

## 핵심 정리

- Event는 Delegate를 기반으로 만들어진 기능이다.
- Delegate는 외부에서 Invoke()와 =가 가능하지만, Event는 +=와 -=만 허용한다.
- Event는 이벤트 발생 권한을 클래스 내부로 제한하여 캡슐화를 제공한다.
- 대부분의 .NET 라이브러리는 Delegate 대신 Event를 사용해 이벤트를 공개한다.
- Unity의 Button.onClick은 C# Event가 아니라 UnityEvent이다.
- Event를 사용하더라도 구독 해제는 개발자가 직접 관리해야 한다.
