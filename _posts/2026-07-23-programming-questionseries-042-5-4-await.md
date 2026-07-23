---
title: "[궁금시리즈] 5-4. await 이후에는 어떤 스레드에서 실행될까?"
excerpt: "C#"
categories:
  - Programming
tags:
  - CSharp
permalink: /programming/5-4-await/
toc: true
toc_sticky: true
date: 2026-07-23
last_modified_at: 2026-07-23
---

다음 코드를 보자.

```cs
private async Task DownloadAsync()
{
    Console.WriteLine($"Before : {Environment.CurrentManagedThreadId}");

    await Task.Delay(1000);

    Console.WriteLine($"After : {Environment.CurrentManagedThreadId}");
}
```

많은 개발자는 결과를 예상하기 어렵다.

- 같은 스레드일까?
- 다른 스레드일까?
- 새로운 스레드가 생성될까?
 
정답은

> 상황에 따라 다르다.

왜 이런 결과가 나오는지 이해하려면 **SynchronizationContext**라는 개념을 먼저 알아야 한다.

---

## await는 어디에서 다시 실행될까?

앞에서 await는

> 메서드를 잠시 중단했다가

Task가 완료되면
이어서 실행한다고 설명했다.
 
그렇다면
"어디에서"
이어서 실행될까?
 
예를 들어

```cs
await Task.Delay(1000);

UpdateUI();
```

를 생각해 보자.
 
만약 UpdateUI()가
다른 스레드에서 실행된다면 어떻게 될까?

---

## UI는 아무 스레드에서나 접근할 수 없다

Windows Forms나 WPF에서는
UI를 만든 스레드만
UI를 수정할 수 있다.
 
예를 들어

```cs
label.Text = "Complete";
```

는 UI 스레드가 아니라면
예외가 발생한다.

즉,
다음과 같은 상황은 문제가 된다.

```
UI Thread

↓

await

↓

다른 Thread

↓

label.Text 변경

❌ 예외
```

그래서 await는 원래 실행되던 
환경으로 돌아오려고 한다.

---

## SynchronizationContext란?

SynchronizationContext는

> "이 작업은 어디에서 이어서 실행해야 하는가?"를 관리하는 객체이다.

예를 들어

UI 프로그램에서는

```
UI Thread

↓

SynchronizationContext
```

가 존재한다.
 
await는 Task가 끝나면 이 Context에게 
"나머지 코드를 실행해 주세요." 라고 요청한다.
 
그러면 UI Thread에서
나머지 코드가 실행된다.

---

## 실제 흐름은 어떻게 될까?

다음 코드를 보자.

```cs
await Task.Delay(1000);

label.Text = "Complete";
```

실행 흐름은

```
UI Thread

↓

Task.Delay 시작

↓

메서드 중단

↓

Task 완료

↓

SynchronizationContext

↓

UI Thread

↓

label.Text 실행
```
 
즉,
원래 UI 스레드에서 실행을 이어간다.

---

## Console 프로그램에서는?

Console 프로그램에는 기본적으로
SynchronizationContext가 없다.
 
즉,

```
Console

↓

await

↓

Task 완료
```

후에 어느 ThreadPool 스레드에서
이어질지는 보장되지 않는다.
 
따라서

```
Environment.CurrentManagedThreadId
```

를 출력해 보면 스레드 번호가
달라질 수도 있다.

---

## ASP.NET Core에서는?

과거 ASP.NET에는
SynchronizationContext가 존재했다.
 
하지만 ASP.NET Core는 기본적으로
SynchronizationContext를 사용하지 않는다.
 
즉,

```
await

↓

원래 Thread

↓

복귀
```

를 보장하지 않는다.
 
이 덕분에 불필요한 Context 전환이 줄어들어
성능이 향상되었다.
 
이것이 ASP.NET Core가 기존 ASP.NET보다
비동기 성능이 좋은 이유 중 하나이다.

---

## 항상 같은 스레드로 돌아오는 것은 아니다

많은 사람들이

```
await

↓

원래 Thread로 복귀
```

라고 외운다.
 
하지만
정확한 표현은

> SynchronizationContext가 있다면 그 Context로 복귀하려고 한다.

이다.
 
즉,

| 환경 | await 이후 |
| ---- | --------- |
| WinForms | UI Thread |
| WPF | UI Thread |
| MAUI | UI Thread | 
| ASP.NET Core | 보장하지 않음 |
| Console | 보장하지 않음 |

이다.

---

## 왜 이렇게 설계했을까?

UI 프로그램에서는

```cs
button.Text = "...";
```

처럼 UI를 계속 수정해야 한다.
 
매번

```cs
Dispatcher.Invoke(...);

Control.Invoke(...);
```

를 호출해야 한다면
코드가 매우 복잡해진다.
 
그래서 await는 자동으로 원래 
UI Context로 복귀하도록 설계되었다.
 
덕분에 다음처럼
순차 코드만 작성하면 된다.

```cs
await DownloadAsync();

label.Text = "Complete";
```

## 실제 .NET에서는 어떻게 동작할까?

컴파일러가 생성한 상태 머신은 await를 만났을 때 
현재 실행 환경도 함께 저장한다.

개념적으로는 다음과 같은 순서이다.

```
현재 SynchronizationContext 저장

↓

Task 완료 대기

↓

Task 완료

↓

저장된 Context에 이어서 실행 요청
```

Context가 존재하지 않는 환경에서는 특정 스레드로 돌아갈 필요가 없으므로, 
이후 코드는 ThreadPool의 스레드에서 계속 실행될 수 있다.

---

## 실무에서 자주 하는 오해
가장 흔한 오해는

> await는 항상 원래 스레드로 돌아온다.

라는 것이다.
 
실제로는

> SynchronizationContext가 있는 환경에서만 원래 실행 환경으로 복귀하려고 한다.

Console 애플리케이션이나 ASP.NET Core에서는 이러한 Context가 없기 때문에, 
await 이후의 실행 스레드는 달라질 수 있다.

---

## 마무리

await는 단순히 작업이 끝날 때까지 기다리는 기능이 아니다.
현재 실행 환경에 SynchronizationContext가 존재한다면, 작업이 완료된 뒤 **원래 실행되던 Context에서 나머지 코드를 이어서 실행**하도록 도와준다.
 
이 덕분에 UI 프로그램에서는 별도의 스레드 전환 코드를 작성하지 않아도 안전하게 UI를 업데이트할 수 있다.

하지만 모든 환경이 SynchronizationContext를 사용하는 것은 아니다. Console 애플리케이션과 ASP.NET Core처럼 Context가 없는 환경에서는 await 이후의 실행 스레드가 달라질 수 있다는 점을 이해하는 것이 중요하다.
 
다음 글에서는 **ConfigureAwait(false)는 왜 사용할까?**를 살펴보며 Context 복귀를 생략하는 이유와 라이브러리 코드에서의 활용 방법을 알아보겠다.

## 핵심 정리

- await 이후의 실행 위치는 SynchronizationContext에 따라 결정된다.
- UI 프로그램에서는 await 이후에도 UI 스레드에서 이어서 실행된다.
- Console과 ASP.NET Core에는 기본적으로 SynchronizationContext가 없다.
- await가 항상 원래 스레드로 돌아오는 것은 아니다.
- SynchronizationContext는 "어디에서 이어서 실행할 것인가"를 관리하는 역할을 한다.
- Context 복귀 덕분에 UI 프로그램에서는 안전하게 UI를 업데이트할 수 있다.
