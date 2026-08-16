---
title: "[궁금시리즈] 6-7. Closure(클로저)는 무엇일까?"
excerpt: "C#"
categories:
  - CSharp
series: question-series
tags:
  - CSharp
permalink: /programming/6-7-closure/
toc: true
toc_sticky: true
date: 2026-07-27 18:20:44 +0900
last_modified_at: 2026-07-27
---

## 들어가며

다음 코드를 보자.

```cs
Action action;

void CreateAction()
{
    int count = 0;

    action = () =>
    {
        count++;
        Console.WriteLine(count);
    };
}

CreateAction();

action();
action();
action();
```

실행 결과는

```
1
2
3
```

이다.
 
여기서 이상한 점이 있다.
count는

```
CreateAction()
```

메서드의 지역 변수이다.
 
메서드가 끝났다면
지역 변수도 사라져야 한다.
 
그런데
람다는 어떻게
count를 계속 사용할 수 있는 것일까?
 
바로 이것이 **Closure(클로저)**이다.

---

## 지역 변수의 수명

일반적인 지역 변수는 Stack에 생성된다.

```cs
void Test()
{
    int value = 10;
}
```

메모리는

```
Test() 시작

↓

Stack

value = 10

↓

Test() 종료

↓

Stack 제거
```

즉,
메서드가 끝나면
지역 변수도 함께 사라진다.

---

## 그런데 람다는 지역 변수를 사용한다

다음 코드를 다시 보자.

```cs
Action action;

void CreateAction()
{
    int count = 0;

    action = () =>
    {
        Console.WriteLine(count);
    };
}
```

람다는 count를 사용한다.
 
하지만 람다는 CreateAction이 끝난 뒤에도 실행될 수 있다.
 
그러면 사라진 Stack 변수를 어떻게 읽을 수 있을까?

---

## 컴파일러가 특별한 클래스를 만든다

정답은 컴파일러가 숨겨진 클래스를 하나 만드는 것이다.
 
이를 흔히 **Display Class**라고 부른다.
 
개념적으로는 다음과 비슷한 코드가 생성된다.

```cs
class DisplayClass
{
    public int count;
}
```

그리고
지역 변수는
이 객체의 필드가 된다.

실제로는 이렇게 바뀐다
컴파일러는 개념적으로
다음과 비슷하게 변환한다.

```cs
class DisplayClass
{
    public int count;

    public void Lambda()
    {
        count++;

        Console.WriteLine(count);
    }
}
```

그리고 원래 코드는

```cs
DisplayClass display = new();

display.count = 0;

action = display.Lambda;
```

처럼 변환된다.
 
즉,
람다는 지역 변수를 사용하는 것이 아니라
Display Class의 필드를 사용하는 것이다.

---

## Stack에서 Heap으로 이동한다

원래

```
count

↓

Stack
```

이었다.
 
하지만 람다가 사용하면

```
Display Class

↓

Heap

↓

count
```

가 된다.
 
즉, 지역 변수가 Heap으로 승격되는 것이다.
 
이를 Variable Capture
또는
Closure라고 부른다.

---

## 메모리 구조

원래라면

```
Stack

count = 0
```

만 존재한다.
 
하지만
Closure가 발생하면

```
Stack

↓

DisplayClass 참조

-----------------

Heap

DisplayClass

count = 0
```

가 된다.
 
람다는 DisplayClass의
count를 참조한다.
 
그래서 메서드가 끝난 뒤에도
값이 유지된다.

---

## 왜 값이 계속 증가할까?

다음 코드를 보자.

```cs
Action action;

void Create()
{
    int count = 0;

    action = () =>
    {
        count++;
        Console.WriteLine(count);
    };
}
```

많은 사람들이 매번 count가 
새로 생성된다고 생각한다.
 
하지만 람다는 동일한 
Display Class를 계속 참조한다.
 
즉,

```
count = 0

↓

1

↓

2

↓

3
```

이 되는 것이다.

---

## foreach에서 유명했던 문제

예전 C#에서는
다음 코드가 문제가 되었다.

```cs
List<Action> actions = new();

foreach (int number in numbers)
{
    actions.Add(() =>
    {
        Console.WriteLine(number);
    });
}
```

많은 사람들이

```
1

2

3
```

을 기대했다.
 
하지만 예전에는

```
3

3

3
```

처럼 출력되는 경우가 있었다.
 
모든 람다가 같은 변수를
캡처했기 때문이다.
 
현재 C#에서는 foreach의 동작이 개선되어
이 문제는 해결되었다.
 
하지만 for 문에서는
비슷한 실수를 여전히 할 수 있다.

---

## for 문에서는 지금도 주의해야 한다

다음 코드를 보자.

```cs
List<Action> actions = new();

for (int i = 0; i < 3; i++)
{
    actions.Add(() =>
    {
        Console.WriteLine(i);
    });
}

foreach (Action action in actions)
{
    action();
}
```

실행 결과는

```
3
3
3
```

이다.

람다가 i의 값을 복사한 것이 아니라, **같은 변수 i를 캡처**했기 때문이다.
원하는 결과를 얻으려면 반복마다 새로운 지역 변수를 만들어야 한다.

```cs
for (int i = 0; i < 3; i++)
{
    int current = i;

    actions.Add(() =>
    {
        Console.WriteLine(current);
    });
}
```

이제 결과는

```
0
1
2
```

가 된다.

---

## 성능에 영향이 있을까?

Closure가 발생하면 Display Class 객체가
Heap에 생성된다.
 
즉,
추가적인 메모리 할당이 발생한다.
또한
GC의 대상도 된다. 대부분의 경우에는
문제가 되지 않는다.
 
하지만 매 프레임 수천 개의 람다를 생성하는 게임이나
고성능 서버에서는 불필요한 Closure 생성을 줄이는 것이 좋다.
 
특히 Unity에서는 Update() 안에서 지역 변수를 캡처하는 람다를 반복 생성하면 GC Alloc의 원인이 될 수 있다.

---

## 실제 .NET에서는 어떻게 동작할까?

컴파일러는 람다가 지역 변수를 캡처하는 것을 발견하면
자동으로 Display Class를 생성한다.
 
람다는 그 Display Class의 인스턴스 메서드로 변환된다.
 
즉,
원래 코드

```cs
() =>
{
    Console.WriteLine(count);
}
```

는
 
개념적으로

```
display.Lambda();
```

를 호출하는 Delegate가 되는 것이다.
개발자는 Display Class를 직접 볼 수 없지만,
컴파일러가 자동으로 생성하여 Closure를 구현한다.

---

## 실무에서 자주 하는 오해

가장 흔한 오해는

> 람다가 지역 변수의 값을 복사한다.

라는 것이다.
 
실제로는 값을 복사하는 것이 아니라 **변수 자체를 캡처**한다.
그래서 캡처된 변수가 변경되면 람다에서도 변경된 값을 보게 된다.
 
또 하나의 오해는

> Closure는 람다만의 기능이다.

라는 것이다.
 
익명 메서드도 지역 변수를 캡처할 수 있으며, 이 경우에도 동일하게 Display Class가 생성된다.
즉, Closure는 람다의 기능이 아니라 **지역 변수를 캡처하는 메커니즘**이다.

---

## 마무리

Closure는 람다가 지역 변수를 사용할 수 있도록 컴파일러가 제공하는 기능이다.
컴파일러는 지역 변수를 그대로 유지하는 것이 아니라 Display Class라는 숨겨진 클래스를 생성하고, 지역 변수를 그 클래스의 필드로 옮긴다. 람다는 이 객체를 참조하기 때문에 메서드가 종료된 이후에도 동일한 변수를 계속 사용할 수 있다.
 
이러한 구조는 매우 편리하지만, 추가적인 Heap 할당과 변수 캡처로 인한 의도하지 않은 동작을 만들 수도 있다. 따라서 Closure의 동작 원리를 이해하는 것은 성능 최적화와 버그를 예방하는 데 매우 중요하다.
 
다음 글에서는 **Event는 Delegate와 무엇이 다를까?**를 살펴보며 Delegate 위에 Event가 왜 추가되었는지와 캡슐화 관점에서 Event가 필요한 이유를 알아보겠다.

---

## 핵심 정리

- Closure는 람다가 지역 변수를 계속 사용할 수 있게 하는 메커니즘이다.
- 컴파일러는 지역 변수를 캡처하면 Display Class를 자동으로 생성한다.
-캡처된 지역 변수는 Stack이 아니라 Heap의 Display Class 필드로 이동한다.
- 람다는 값이 아니라 **변수 자체를 캡처**한다.
- foreach의 캡처 문제는 최신 C#에서 해결되었지만, for 문에서는 여전히 주의해야 한다.
- Closure는 추가적인 Heap 할당과 GC의 원인이 될 수 있다.
- 익명 메서드도 동일한 방식으로 Closure를 사용한다.
