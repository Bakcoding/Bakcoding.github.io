---
title: "[궁금시리즈] 5-9. Task.WhenAll()과 Task.WhenAny()는 언제 사용할까?"
excerpt: "C#"
categories:
  - CSharp
series: question-series
tags:
  - CSharp
permalink: /programming/5-9-task-whenall-task-whenany/
toc: true
toc_sticky: true
date: 2026-07-27
last_modified_at: 2026-07-27
---

## 들어가며

다음 코드를 보자.

```cs
await DownloadFileAsync("A");
await DownloadFileAsync("B");
await DownloadFileAsync("C");
```

언뜻 보면 세 개의 다운로드가 동시에 진행될 것처럼 보인다.
 
하지만 실제 실행 순서는 다음과 같다.

```
A 다운로드

↓

완료

↓

B 다운로드

↓

완료

↓

C 다운로드
```

즉,
앞 작업이 끝나야 다음 작업이 시작된다.

만약 서로 독립적인 작업이라면
동시에 실행하는 것이 훨씬 효율적이다.

Task를 먼저 생성하면 어떻게 될까?

다음 코드를 보자.

```cs
Task taskA = DownloadFileAsync("A");
Task taskB = DownloadFileAsync("B");
Task taskC = DownloadFileAsync("C");

await taskA;
await taskB;
await taskC;
```

이번에는 Task를 먼저 생성했다.
 
실행 흐름은

```
A 시작

B 시작

C 시작

↓

각자 실행

↓

순서대로 await
```

즉,
Task는 생성되는 순간 이미 실행을 시작할 수 있다.

await가 실행을 시작하는 것이 아니라,
**완료를 기다리는 것**이다.

---

## Task.WhenAll이란?

여러 Task가 모두 끝날 때까지 기다리고 싶다면
Task.WhenAll()을 사용한다.

```cs
await Task.WhenAll(
    DownloadFileAsync("A"),
    DownloadFileAsync("B"),
    DownloadFileAsync("C"));
```

실행 흐름은

```
A 시작

B 시작

C 시작

↓

모두 실행

↓

모두 완료

↓

다음 코드 실행
```

즉,
모든 작업이 끝난 뒤
한 번만 이어서 실행된다.

---

## 결과도 받을 수 있다

Task<T>도 사용할 수 있다.

```cs
string[] results = await Task.WhenAll(
    DownloadTextAsync(url1),
    DownloadTextAsync(url2),
    DownloadTextAsync(url3));
```

results에는

```
results[0]

results[1]

results[2]
```

처럼 각 작업의 결과가 순서대로 저장된다.

중요한 점은 **완료 순서가 아니라 전달한 순서대로 결과가 반환된다.**
 
예를 들어

```
B 완료

↓

A 완료

↓

C 완료
```

가 되어도
 
결과는

```
A

B

C
```

순서로 들어간다.

---

## Task.WhenAny란?

이번에는 가장 먼저 끝나는 작업만 필요하다고 가정해 보자.
 
이때는 Task.WhenAny()를 사용한다.

```cs
Task first = await Task.WhenAny(
    DownloadFileAsync("A"),
    DownloadFileAsync("B"),
    DownloadFileAsync("C"));
```

실행 흐름은

```
A 시작

B 시작

C 시작

↓

B 완료

↓

WhenAny 완료
```

가 된다.
 
즉,
가장 먼저 끝난 Task 하나를 반환한다.

---

## WhenAny가 나머지 작업을 취소할까?

많은 사람들이

```
WhenAny

↓

가장 먼저 끝남

↓

나머지 종료
```

라고 생각한다.
 
하지만 그렇지 않다.

나머지 작업은 계속 실행된다.

```
A 시작

B 시작

C 시작

↓

B 완료

↓

WhenAny 반환

↓

A 계속 실행

↓

C 계속 실행
```

필요하다면
CancellationToken을 사용해
직접 취소해야 한다.

---

## 언제 사용할까?

**Task.WhenAll**

모든 작업이 반드시 필요할 때

```cs
var profileTask = GetProfileAsync();
var inventoryTask = GetInventoryAsync();
var questTask = GetQuestAsync();

await Task.WhenAll(profileTask, inventoryTask, questTask);
```

게임 로그인 시
프로필, 인벤토리, 퀘스트를
동시에 가져오는 경우가 대표적이다.

---

**Task.WhenAny**

가장 빠른 응답 하나만 필요할 때
 
예를 들어 여러 서버 중
먼저 응답한 서버를 사용할 수도 있다.

```cs
Task<HttpResponseMessage> response =
    await Task.WhenAny(
        server1.GetAsync(),
        server2.GetAsync());
```

---

## 병렬 실행과는 무엇이 다를까?

많은 사람들이

```
WhenAll

=

병렬 프로그래밍
```

라고 생각한다.
 
하지만 
정확히는 다르다.
 
WhenAll은 **여러 비동기 작업을 함께 기다리는 기능**이다.

각 작업이 반드시 여러 CPU에서 동시에 실행된다는 의미는 아니다.
 
예를 들어

```cs
await Task.WhenAll(
    File.ReadAllTextAsync(a),
    File.ReadAllTextAsync(b));
```

는
 
비동기 I/O 작업을 함께 기다리는 것이지,
CPU 병렬 계산과는 다른 개념이다.
 
실제로 CPU를 병렬로 사용하는 기술은
뒤에서 다룰 **병렬 프로그래밍(Parallel Programming)**에서 자세히 살펴본다.

---

## 실제 .NET에서는 어떻게 동작할까?

Task.WhenAll()은 전달된 Task들의 완료를 추적하는 새로운 Task를 생성한다.

```
Task A

Task B

Task C

↓

WhenAll Task

↓

모든 Task 완료

↓

Completed
```

반면 Task.WhenAny()는
가장 먼저 완료된 Task를 확인하는 순간
새로운 Task를 완료 상태로 만든다.

나머지 Task는 계속 실행된다.

---

## 실무에서 자주 하는 오해

가장 흔한 오해는

> Task.WhenAll()이 작업을 시작한다.

라는 것이다.
 
실제로는

```cs
Task task = DownloadAsync();
```

를 호출하는 순간 Task는 이미 실행을 시작할 수 있다.
 
Task.WhenAll()은 새로운 작업을 시작하는 기능이 아니라,
**이미 시작된 여러 Task가 모두 끝날 때까지 기다리는 기능**이다.
 
또 하나의 오해는

> Task.WhenAny()를 사용하면 나머지 작업이 자동으로 취소된다.
 
라는 것이다.

실제로는 그렇지 않으며,
필요하다면 CancellationToken을 이용해 직접 취소해야 한다.

---

## 마무리
Task.WhenAll()과 Task.WhenAny()는 여러 비동기 작업을 효율적으로 조합하기 위한 핵심 기능이다.
Task.WhenAll()은 모든 작업의 완료가 필요할 때 사용하며, Task.WhenAny()는 가장 먼저 완료되는 작업 하나만 필요할 때 사용한다.
 
중요한 점은 await가 작업을 시작하는 것이 아니라 **Task를 기다리는 역할**이라는 것이다.
여러 작업을 먼저 시작한 뒤 Task.WhenAll()이나 Task.WhenAny()를 사용하면 전체 실행 시간을 크게 줄일 수 있다.
 
다음 글에서는 **CancellationToken으로 비동기 작업을 안전하게 취소하는 방법**을 알아보겠다.

---

## 핵심 정리

- await를 연속해서 사용하면 작업은 순차적으로 실행된다.
- 여러 Task를 먼저 시작한 뒤 Task.WhenAll()을 사용하면 동시에 진행되는 작업을 함께 기다릴 수 있다.
- Task.WhenAll()은 모든 Task가 완료될 때까지 기다린다.
- Task.WhenAny()는 가장 먼저 완료된 Task 하나를 반환한다.
- Task.WhenAny()가 나머지 Task를 자동으로 취소하지는 않는다.
- Task.WhenAll()은 작업을 시작하는 기능이 아니라 이미 시작된 Task를 기다리는 기능이다.
