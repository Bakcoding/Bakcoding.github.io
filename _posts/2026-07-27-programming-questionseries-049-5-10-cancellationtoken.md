---
title: "[궁금시리즈] 5-10. CancellationToken은 왜 필요할까"
excerpt: "C#"
categories:
  - CSharp
series: question-series
tags:
  - CSharp
permalink: /programming/5-10-cancellationtoken/
toc: true
toc_sticky: true
date: 2026-07-27
last_modified_at: 2026-07-27
---

## 들어가며

다음 코드를 보자.

```
await DownloadFileAsync();
```

다운로드가 시작되었다.

그런데 사용자가

"취소"

버튼을 눌렀다.
 
이때 우리는 자연스럽게

> 다운로드를 멈추면 되지 않을까?
 
라고 생각한다.
 
하지만 이미 시작된 비동기 작업은 외부에서 강제로 중단할 수 없다.
 
그래서 .NET에서는 **협력적 취소(Cooperative Cancellation)**라는 방식을 사용한다.

이번 글에서는 CancellationToken이 왜 필요한지와 올바른 사용 방법을 확인한다.

---

## 왜 Thread.Abort처럼 강제로 종료하지 않을까?

과거 .NET에는

```cs
thread.Abort();
```

처럼 스레드를 강제로 종료하는 기능이 있었다.

하지만 이는 매우 위험했다.
 
예를 들어

```
파일 저장 중

↓

강제 종료
```

가 발생하면 파일이 손상될 수도 있다.
 
또는

```
DB 저장 중

↓

강제 종료
```

가 발생하면 데이터의 일관성이 깨질 수도 있다.
 
그래서 현재는 강제 종료 방식이 아니라
**작업이 스스로 종료하도록 요청하는 방식**을 사용한다.

---

## CancellationToken이란?

CancellationToken은

> 작업을 취소해 달라는 요청을 전달하는 객체이다.
 
중요한 점은 토큰이 작업을 직접 멈추는 것이 아니라,
작업이 토큰을 확인하고 스스로 종료하는 것이다.

---

## CancellationTokenSource

취소 요청은

CancellationTokenSource가 만든다.

```cs
CancellationTokenSource cts = new();

CancellationToken token = cts.Token;
```

그리고
 
취소가 필요하면

```cs
cts.Cancel();
```

을 호출한다.
 
그러면

```
CancellationTokenSource

↓

Cancel()

↓

Token

↓

취소 요청 발생
```

이라는 흐름이 된다.

---

## 작업은 어떻게 취소될까?

다음 코드를 보자.

```cs
public async Task DownloadAsync(CancellationToken token)
{
    while (true)
    {
        token.ThrowIfCancellationRequested();

        await Task.Delay(100);
    }
}
```

중간중간

```cs
token.ThrowIfCancellationRequested();
```

를 호출한다.
 
사용자가

```cs
cts.Cancel();
```

을 호출하면 다음 검사 시점에서

```
OperationCanceledException
```

이 발생하면서 작업이 종료된다.

---

## IsCancellationRequested도 사용할 수 있다

예외 대신 직접 확인할 수도 있다.

```cs
while (!token.IsCancellationRequested)
{
    await Task.Delay(100);
}
```

이 방법도 가능하지만 실무에서는

```cs
token.ThrowIfCancellationRequested();
```

를 더 많이 사용한다.

취소가 발생했다는 사실을 호출자에게 명확하게 전달할 수 있기 때문이다.

---

## 취소는 예외일까?

다음 코드를 보자.

```cs
try
{
    await DownloadAsync(token);
}
catch (OperationCanceledException)
{
    Console.WriteLine("취소됨");
}
```

여기서 OperationCanceledException이 발생한다.

이름 때문에 실패처럼 보일 수 있다.
 
하지만 **취소는 실패가 아니다.**

취소는 사용자가 의도한 정상적인 종료이다.
 
그래서 일반적인 예외와는
다르게 처리하는 것이 좋다.

---

## Task의 상태는 어떻게 될까?

작업이 정상적으로 끝나면

```
RanToCompletion
```

상태가 된다.
 
예외가 발생하면

```
Faulted
```

가 된다.
 
취소되면

```
Canceled
```

상태가 된다.
 
즉,
취소는 실패(Faulted)가 아니라
별도의 상태를 가진다.

---

## 여러 작업을 함께 취소하기

같은 Token을 여러 작업에 전달할 수도 있다.

```cs
CancellationTokenSource cts = new();

Task a = DownloadAsync(cts.Token);
Task b = DownloadAsync(cts.Token);
Task c = DownloadAsync(cts.Token);

cts.Cancel();
```

그러면

```
Task A

↓

Task B

↓

Task C

↓

동시에 취소 요청
```

을 받는다.

---

## 게임 개발에서는?

게임에서는 취소 기능이 매우 자주 사용된다.
 
예를 들어
 
**로딩 화면**

```
맵 로딩

↓

사용자가 뒤로가기

↓

로딩 취소
```

---

**서버 요청**

```
검색 시작

↓

새 검색 입력

↓

이전 요청 취소
```

**리소스 다운로드**

```
패치 시작

↓

게임 종료

↓

다운로드 취소
```

이처럼 사용자의 행동에 따라
진행 중인 작업을 안전하게 종료하는 것이 중요하다.

---

## 실제 .NET에서는 어떻게 동작할까?

CancellationToken은 내부적으로 매우 가벼운 구조체(struct)이다.

작업은 토큰을 전달받아 필요한 시점마다

```
취소 요청 여부 확인

↓

취소되었는가?

↓

예

↓

OperationCanceledException 발생
```

이라는 흐름으로 동작한다.
 
즉,
.NET이 작업을 강제로 종료하는 것이 아니라,
**작업이 스스로 취소 요청에 협력(Cooperate)**하는 구조이다.

---

## 실무에서 자주 하는 오해

가장 흔한 오해는

> Cancel()을 호출하면 작업이 즉시 종료된다.

라는 것이다.

실제로는 취소 요청만 전달될 뿐이다.

작업이 토큰을 확인하지 않는다면
끝까지 계속 실행될 수도 있다.
 
또 하나의 오해는

> 취소는 실패이다.

라는 것이다.
 
Task는

- 성공(RanToCompletion)
- 실패(Faulted)
- 취소(Canceled)

를 서로 다른 상태로 관리한다.

취소는 사용자가 의도한 정상적인 종료로 취급된다.

---

## 마무리

CancellationToken은 실행 중인 작업을 강제로 중단하는 기능이 아니라, **작업이 안전하게 스스로 종료할 수 있도록 취소 요청을 전달하는 메커니즘**이다.
 
이러한 협력적 취소 방식은 파일 저장, 데이터베이스 작업, 네트워크 통신처럼 중간에 강제 종료하면 문제가 발생할 수 있는 작업을 안전하게 처리할 수 있게 해 준다.
 
실무에서는 비동기 작업을 작성할 때 CancellationToken을 함께 전달하는 것이 일반적인 패턴이며, 사용자의 취소 요청이나 화면 전환과 같은 상황에 유연하게 대응할 수 있다.
 
다음 글에서는 **비동기 프로그래밍에서 자주 하는 실수와 성능 문제**를 정리하며 지금까지 배운 내용을 실무 관점에서 다시 살펴보겠다.

---

## 핵심 정리

- CancellationToken은 작업을 강제로 종료하는 것이 아니라 취소 요청을 전달한다.
- 취소는 작업이 스스로 협력(Cooperate)하여 처리한다.
- CancellationTokenSource는 취소 요청을 생성하는 객체이다.
- ThrowIfCancellationRequested()는 취소 요청이 있으면 OperationCanceledException을 발생시킨다.
- Task의 상태는 성공(RanToCompletion), 실패(Faulted), 취소(Canceled)로 구분된다.
- 여러 작업에 같은 CancellationToken을 전달하여 동시에 취소 요청을 보낼 수 있다.
