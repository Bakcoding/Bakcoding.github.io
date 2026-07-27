---
title: "[궁금시리즈] 5-8. async void를 사용하면 안 되는 이유"
excerpt: "C#"
categories:
  - Programming
tags:
  - CSharp
permalink: /programming/5-8-async-void/
toc: true
toc_sticky: true
date: 2026-07-27
last_modified_at: 2026-07-27
---

다음 두 메서드를 보자.

```cs
public async Task SaveAsync()
{
    await Task.Delay(1000);
}
```

그리고

```cs
public async void SaveAsync()
{
    await Task.Delay(1000);
}
```

둘 다 컴파일된다.

둘 다 await도 사용할 수 있다.
 
그렇다면 둘은 무엇이 다를까?

많은 초보 개발자는

> 반환형만 다를 뿐 같은 기능이다.

라고 생각한다.

하지만 실제로는
**동작 방식이 완전히 다르다.**
 
이번 글에서는 왜 async void가 대부분의 상황에서 권장되지 않는지 알아보자.

---

## 먼저 Task를 떠올려 보자

앞에서 살펴본 것처럼

Task는 작업 하나를 나타내는 객체이다.

```cs
Task task = SaveAsync();
```

Task가 있으므로

```cs
await task;
```

도 할 수 있고

```cs
Task.WhenAll(...)
```

에도 사용할 수 있다.
 
또

```cs
try
{
    await SaveAsync();
}
catch (Exception ex)
{
}
```

처럼 

예외도 받을 수 있다.

---

## async void는 Task가 없다

이번에는

```cs
public async void SaveAsync()
{
    await Task.Delay(1000);
}
```

를 보자.
 
호출하면

```
SaveAsync();
```

뿐이다.
 
반환값이 없다.
 
즉,
작업을 나타내는 객체도 없다.

---

그래서
다음과 같은 코드는 불가능하다.

```
await SaveAsync();
```

컴파일 자체가 되지 않는다.

---

## 완료를 기다릴 수 없다

예를 들어

```cs
SaveAsync();

Console.WriteLine("끝");
```

를 실행하면

```
SaveAsync 시작

↓

Console.WriteLine 실행

↓

SaveAsync 완료
```

가 될 수도 있다.
 
즉,
호출한 쪽에서는 작업이 언제 끝났는지
알 방법이 없다.

---

## 예외 처리가 어렵다

다음 코드를 보자.

```cs
public async void SaveAsync()
{
    await Task.Delay(1000);

    throw new Exception();
}
```

호출하는 쪽에서

```cs
try
{
    SaveAsync();
}
catch
{
    Console.WriteLine("예외 처리");
}
```

를 작성해도 예외를 잡지 못한다.
 
왜일까?

호출하는 순간 메서드는 
이미 반환되었기 때문이다.
 
실제로 예외는 비동기 작업이 
이어서 실행되는 시점에 발생한다.
 
즉,
호출한 메서드의 try-catch 범위를 벗어나 버린다.

환경에 따라서는
애플리케이션이 종료될 수도 있다.

---

## async Task는 왜 괜찮을까?

```cs
public async Task SaveAsync()
{
    await Task.Delay(1000);

    throw new Exception();
}
```

이번에는

```cs
try
{
    await SaveAsync();
}
catch (Exception ex)
{
    Console.WriteLine(ex.Message);
}
```

가 정상적으로 동작한다.
 
Task가 예외 정보를
가지고 있기 때문이다.

Task는 완료뿐 아니라
실패 상태도 관리한다.

---

## Task 조합도 할 수 없다

앞에서

```cs
await Task.WhenAll(tasks);
```

을 사용할 수 있다고 했다.
 
하지만

```
async void
```

는 Task가 존재하지 않는다.
 
즉,

```
Task.WhenAll

Task.WhenAny

ContinueWith

await
```

모두 사용할 수 없다.

비동기 조합이
불가능하다.

---

## 테스트도 어렵다

예를 들어 단위 테스트에서

```cs
await service.SaveAsync();
```

는
 
작업이 끝날 때까지 기다릴 수 있다.
 
하지만

```
service.SaveAsync();
```

는
 
끝났는지 알 수 없다.

테스트가 중간에 끝날 수도 있다.
 
즉,
비동기 테스트도 거의 불가능해진다.

---

## 그럼 async void는 언제 사용할까?

사실 거의 유일한 예외가 있다.
바로 이벤트 핸들러이다.
 
예를 들어

**WinForms**

```cs
private async void button_Click(object sender, EventArgs e)
{
    await DownloadAsync();
}
```

**WPF**

```cs
private async void Window_Loaded(object sender, RoutedEventArgs e)
{
    await InitializeAsync();
}
```

이벤트의 시그니처는
프레임워크에서 이미

```
void
```

로 정해 두었다.
 
따라서 반환형을
Task로 바꿀 수 없다.
 
이 경우에는
async void를 사용하는 것이 맞다.

---

## Unity에서는?

Unity의 버튼 이벤트도 마찬가지이다.
 
예를 들어

```cs
public async void OnClick()
{
    await LoadDataAsync();
}
```

처럼 이벤트 진입점에서는 사용할 수 있다.
 
하지만
그 안에서 호출하는 메서드는

```cs
private async Task LoadDataAsync()
{
}
```

처럼 반드시 Task를 반환하는 것이 좋다.
 
즉, async void는
가장 바깥쪽 이벤트 메서드에서만 사용하고,
실제 작업을 수행하는 메서드는 Task를 반환하도록 작성하는 것이 권장된다.

---

## 실제 .NET에서는 어떻게 처리할까?

컴파일러는 async void와 async Task를 서로 다른 방식으로 처리한다.

- async Task는 AsyncTaskMethodBuilder를 사용하여 Task 객체를 생성하고, 완료 및 예외 정보를 그 안에 저장한다.
- async void는 AsyncVoidMethodBuilder를 사용하며, 호출자에게 전달할 Task가 존재하지 않는다.

이 때문에 async void에서는 호출자가 작업의 완료나 실패를 추적할 수 없다.

---

## 실무에서 자주 하는 오해

가장 흔한 오해는

> 반환값이 없으니까 async void를 사용하면 된다.

라는 것이다.
 
비동기 메서드에서 반환값이 없더라도

```cs
public async Task SaveAsync()
```

처럼 Task를 반환하는 것이 올바른 방법이다.

Task는 결과값을 전달하기 위한 용도가 아니라, **비동기 작업 자체를 표현하는 객체**이기 때문이다.

---

## 마무리

async void는 문법적으로는 가능하지만, 대부분의 상황에서는 사용하지 않는 것이 좋다.
Task가 없기 때문에 작업 완료를 기다릴 수 없고, 예외 처리도 어렵고, 다른 비동기 작업과 조합하거나 테스트하기도 힘들다.
 
예외적으로 이벤트 핸들러처럼 프레임워크가 void 반환형을 요구하는 경우에만 async void를 사용하고, 그 외의 비동기 메서드는 Task 또는 Task<T\>를 반환하는 습관을 갖는 것이 좋다.
 
다음 글에서는 **Task.WhenAll()과 Task.WhenAny()를 사용하여 여러 비동기 작업을 효율적으로 처리하는 방법**을 알아보겠다.

---

## 핵심 정리

- async void는 호출자에게 Task를 반환하지 않는다.
- async void는 작업 완료를 기다릴 수 없다.
- async void에서 발생한 예외는 호출자가 일반적인 try-catch로 처리하기 어렵다.
- Task.WhenAll(), Task.WhenAny(), await와 같은 비동기 조합에 사용할 수 없다.
- 일반적인 비동기 메서드는 Task 또는 Task<T>를 반환하는 것이 권장된다.
- async void는 이벤트 핸들러와 같이 void 시그니처가 강제되는 경우에만 사용하는 것이 좋다.
