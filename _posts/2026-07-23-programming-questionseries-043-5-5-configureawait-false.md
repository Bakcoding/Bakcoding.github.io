---
title: "[궁금시리즈] 5-5. ConfigureAwait(false)는 왜 사용할까?"
excerpt: "C#"
categories:
  - Programming
tags:
  - CSharp
permalink: /programming/5-5-configureawait-false/
toc: true
toc_sticky: true
date: 2026-07-23
last_modified_at: 2026-07-23
---

비동기 코드를 보다 보면 다음과 같은 코드를 자주 만나게 된다.

```cs
await Task.Delay(1000).ConfigureAwait(false);
```

또는

```cs
await httpClient.GetAsync(url).ConfigureAwait(false);
```

처음 보면 많은 의문이 생긴다.

- 왜 ConfigureAwait(false)를 붙일까?
- 붙이면 무엇이 달라질까?
- 모든 await에 붙여야 할까?

이번 글에서는 ConfigureAwait(false)가 등장한 이유와 언제 사용하는 것이 적절한지 알아보자.

---

## 먼저 await를 다시 떠올려 보자

이전 글에서 await는 Task가 끝난 뒤 가능하면
**원래의 SynchronizationContext로 돌아간다.**
라고 설명했다.
 
예를 들어

```cs
await Task.Delay(1000);

label.Text = "Complete";
```

는

```
UI Thread

↓

Task.Delay

↓

Task 완료

↓

UI Thread 복귀

↓

label.Text 실행
```

이라는 흐름으로 동작한다.

---

## 그런데 항상 돌아올 필요가 있을까?

다음 코드를 보자.

```cs
string json = await httpClient.GetStringAsync(url);

return json.Length;
```

여기서는 UI를 수정하지도 않고,
버튼을 누르지도 않는다.

단순히 문자열 길이만 계산한다.
 
그렇다면 굳이

```
Task 완료

↓

UI Thread 복귀

↓

길이 계산
```

을 해야 할까?

사실 다른 Thread에서 그대로 
이어서 실행해도 아무 문제가 없다.

---

## ConfigureAwait(false)의 의미

바로 이런 경우를 위해 ConfigureAwait(false)가 존재한다.

```cs
await Task.Delay(1000).ConfigureAwait(false);
```

의 의미는

> Task가 완료되어도 원래 SynchronizationContext로 돌아오지 않아도 된다.

이다.
 
즉,

```
Task 완료

↓

아무 Thread에서 이어서 실행
```

해도 괜찮다고 알려주는 것이다.

---

## 실행 흐름 비교

**일반 await**

```
UI Thread

↓

Task 시작

↓

Task 완료

↓

UI Thread 복귀

↓

이후 코드 실행
```

---

**ConfigureAwait(false)**

```
UI Thread

↓

Task 시작

↓

Task 완료

↓

ThreadPool

↓

이후 코드 실행
```

Context 복귀 과정이 생략된다.

---

## 왜 성능이 좋아질까?

SynchronizationContext로 돌아가려면

```
현재 Context 저장

↓

Task 완료

↓

Context에 작업 등록

↓

다시 실행
```

과정이 필요하다.

ConfigureAwait(false)를 사용하면
이 과정이 필요 없다.

즉,
불필요한 Context 전환 비용을 줄일 수 있다.

다만 이 비용은 일반적으로 매우 작으며, **ConfigureAwait(false)의 주된 목적은 성능 향상보다 Context에 의존하지 않는 코드를 작성하는 것**이다.

---

## UI에서는 사용하면 안 되는 경우

다음 코드를 보자.

```cs
await DownloadAsync().ConfigureAwait(false);

label.Text = "Complete";
```

Task가 끝난 뒤
다른 Thread에서

```cs
label.Text
```

를 실행할 수도 있다.
 
WinForms나 WPF에서는 UI는 
UI Thread에서만 수정할 수 있으므로 예외가 발생한다.
 
즉,
UI를 계속 사용할 코드에서는
ConfigureAwait(false)를 사용하면 안 된다.

---

## 그렇다면 언제 사용할까?

대표적인 예는
라이브러리 코드이다.
 
예를 들어

```cs
public async Task<string> DownloadAsync(string url)
{
    return await httpClient
        .GetStringAsync(url)
        .ConfigureAwait(false);
}
```

이 메서드는
UI를 전혀 알지 못한다.
 
WinForms에서 사용할 수도 있고,
WPF에서 사용할 수도 있고,
ASP.NET Core에서 사용할 수도 있다.
 
즉,
특정 SynchronizationContext에
의존할 이유가 없다.
 
이런 경우에는
ConfigureAwait(false)를 사용하는 것이 적절하다.

---

## ASP.NET Core에서는?

현재 ASP.NET Core는 기본적으로 
SynchronizationContext를 사용하지 않는다.
 
즉,

```cs
await Task.Delay(1000);
```

와

```cs
await Task.Delay(1000).ConfigureAwait(false);
```

의 차이가 거의 없다.
 
그래서 ASP.NET Core에서는 예전만큼
ConfigureAwait(false)를 많이 사용할 필요는 없다.

---

## 실제 .NET 라이브러리는?

.NET BCL(Base Class Library)의 많은 내부 구현에서도

```
ConfigureAwait(false)
```

를 적극적으로 사용한다.
 
그 이유는 라이브러리 코드가 호출하는 프로그램이
WinForms인지 WPF인지 ASP.NET Core인지
알 수 없기 때문이다.
 
즉,
Context에 의존하지 않는 것이
더 안전하다.

---

## 실무에서는 어떻게 사용하는 것이 좋을까?

다음 기준으로 생각하면 쉽다.

| 상황 | 권장 여부 |
| --- | --------- |
| WinForms/WPF에서 UI를 계속 사용할 코드 | ❌ 사용하지 않음 |
| MAUI에서 UI를 계속 사용할 코드 | ❌ 사용하지 않음 |
| 라이브러리 코드 | ✅ 사용 권장 |
| ASP.NET Core 애플리케이션 | 대부분 필요 없음 |

이처럼 **프로젝트의 종류와 이후 코드가 UI Context를 필요로 하는지**에 따라 
판단해야 한다.

---

## 실무에서 자주 하는 오해

가장 흔한 오해는

> ConfigureAwait(false)를 붙이면 무조건 성능이 좋아진다.

라는 것이다.
 
실제로는 Context 전환 비용은 대부분의 
애플리케이션에서 매우 작은 부분이다.
 
무조건 모든 await에 붙이는 것보다
**현재 코드가 원래 Context로 돌아올 필요가 있는지**를 
먼저 판단하는 것이 중요하다.
 
또 하나의 오해는

> 모든 프로젝트에서 ConfigureAwait(false)를 사용해야 한다.

라는 것이다.
 
특히 UI 애플리케이션에서는
UI를 업데이트해야 하는 코드에서 사용하면
오히려 예외의 원인이 될 수 있다.

---

## 마무리

ConfigureAwait(false)는 성능을 높이기 위한 옵션이라기보다, 
**원래 SynchronizationContext로 복귀하지 않아도 된다는 것을 명시하는 기능**이다.

UI 프로그램에서는 대부분 원래 UI 스레드로 돌아와야 하므로 신중하게 사용해야 하지만, 특정 실행 환경에 의존하지 않는 라이브러리 코드에서는 불필요한 Context 복귀를 피하기 위해 자주 사용된다.
 
중요한 것은 "무조건 사용" 또는 "절대 사용하지 않음"이 아니라, **현재 코드가 SynchronizationContext를 필요로 하는지**를 기준으로 판단하는 것이다.
 
다음 글에서는 **Task.Run()은 언제 사용해야 할까?**를 살펴보며 CPU 작업과 I/O 작업에서의 올바른 사용법을 알아보겠다.

---

## 핵심 정리

- ConfigureAwait(false)는 원래 SynchronizationContext로 복귀하지 않아도 된다는 의미이다.
- UI를 계속 사용하는 코드에서는 일반적으로 사용하면 안 된다.
- 라이브러리 코드에서는 ConfigureAwait(false)를 사용하는 것이 일반적이다.
- ASP.NET Core에서는 기본적으로 SynchronizationContext가 없어 효과가 거의 없다.
- ConfigureAwait(false)의 목적은 Context 의존성을 줄이는 것이지, 단순히 성능을 높이는 것이 아니다.
- 항상 사용하는 것이 아니라 코드의 실행 환경에 따라 선택해야 한다.
