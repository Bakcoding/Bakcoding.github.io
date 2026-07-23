---
title: "[궁금시리즈] 5-2. Task는 무엇이며 왜 등장했을까?"
excerpt: "C#"
categories:
  - Programming
tags:
  - CSharp
permalink: /programming/5-2-task/
toc: true
toc_sticky: true
date: 2026-07-23
last_modified_at: 2026-07-23
---

비동기 프로그래밍을 공부하다 보면 가장 먼저 만나게 되는 타입이 있다.
바로 Task이다.

```cs
Task task = DoWorkAsync();
```

또는

```cs
Task<int> task = CalculateAsync();
```

거의 모든 비동기 메서드가 Task를 반환한다.

그렇다면 Task는 무엇일까?

많은 사람들이

> "Task는 새로운 스레드이다."

라고 생각하지만,
실제로는 전혀 다른 개념이다.

---

## Task가 등장하기 전에는?

초기의 .NET에서는 비동기 작업을 수행하기 위해 직접 Thread를 생성하는 경우가 많았다.

```cs
Thread thread = new Thread(DoWork);

thread.Start();
```

또는

```cs
ThreadPool.QueueUserWorkItem(...);
```

처럼 작성했다.
 
이 방식도 동작은 하지만 여러 문제가 있었다.

- 작업 완료 여부를 직접 관리해야 한다.
- 예외 처리가 어렵다.
- 여러 작업을 함께 관리하기 어렵다.
- 작업을 이어서 실행하는 코드가 복잡하다.

 
즉,
**스레드는 작업을 실행하는 도구일 뿐, 작업 자체를 표현하지는 못했다.**

---

## Task는 작업(Task)을 표현하는 객체이다

Task는 이름 그대로

> 앞으로 완료될 작업 하나를 나타내는 객체이다.

 
예를 들어

```
Task download = DownloadFileAsync();
```

이 코드에서 download는 파일 자체도 아니고, 스레드도 아니다. 

"다운로드 작업"을 나타내는 객체이다.

예를 들어 택배를 생각해 보자.

```
택배 주문

↓

배송 중

↓

배송 완료
```

주문 번호 하나로 현재 상태를 확인할 수 있다.
 
Task도 비슷하다.

```
작업 시작

↓

실행 중

↓

완료
```

Task는 현재 작업의 상태를 관리한다.

---

## Task는 어떤 정보를 가지고 있을까?

Task는 내부적으로 다음과 같은 상태를 관리한다.

```
생성됨

↓

실행 중

↓

완료
```

또는

```
실패

취소
```

가 될 수도 있다.
즉, 
Task는 작업이

- 시작되었는지
- 끝났는지
- 실패했는지
- 취소되었는지

등의 정보를 모두 가지고 있다.

---

## Task<T>는 무엇일까?

다음 코드를 보자.

```cs
Task<int> task = GetNumberAsync();
```

이번에는 작업이 끝난 후
결과도 필요하다.
 
예를 들어

```
파일 다운로드

↓

파일 내용 반환
```

또는

```
DB 조회

↓

Player 객체 반환
```

처럼 작업의 결과가 존재한다.
 
이때 사용하는 것이
Task<T>이다.
 
즉,

- Task → 결과가 없는 작업
- Task<T> → 결과가 있는 작업

이다.

---

## Task는 언제 끝날까?
예를 들어

```cs
Task task = DownloadAsync();
```

를 호출했다고 해서
바로 완료되는 것은 아니다.
 
작업은

```
Running...
```

상태일 수도 있다.
 
완료되면

```
Completed
```

상태가 된다.
 
즉,
Task 객체는 작업 자체가 아니라
**작업의 진행 상태를 추적하는 객체**라고 이해하면 된다.

---

## Task는 Thread일까?

가장 많이 하는 오해이다.
 
다음 코드를 보자.

```cs
await File.ReadAllTextAsync(path);
```

여기서 Task가 만들어졌다고 해서
새로운 Thread가 생성되는 것은 아니다.

작업의 종류에 따라

- 운영체제의 비동기 I/O를 사용할 수도 있고
- ThreadPool에서 실행할 수도 있고
- 이미 실행 중인 작업을 그대로 나타낼 수도 있다.

즉,
Task는

"어디에서 실행되는가"

보다

"작업이 존재한다"

를 표현하는 객체이다.

---

## Task.Run은 무엇일까?

여기서 혼동이 많이 발생한다.

```cs
Task.Run(() =>
{
    DoWork();
});
```

이 코드는 실제로 ThreadPool을 
이용하여 작업을 실행한다.
 
하지만

```cs
await File.ReadAllTextAsync(path);
```

는 ThreadPool을 사용하지 않을 수도 있다.
 
즉,
**Task를 사용한다고 항상 새로운 스레드가 생성되는 것은 아니다.**
Task.Run()은 Task를 만드는 여러 방법 중 하나일 뿐이다.

---

## 실제 .NET에서는 어떻게 사용될까?

비동기 메서드는 대부분 Task 또는 Task<T>를 반환한다.
 
예를 들어

```cs
Task Delay(int milliseconds);

Task<string> ReadAllTextAsync(string path);

Task<HttpResponseMessage> GetAsync(string url);
```

이처럼 .NET 라이브러리의 비동기 API는 작업을 Task로 표현한다.
 
덕분에 호출하는 쪽에서는 작업의 완료를 기다리거나, 여러 작업을 함께 관리하거나, 
예외를 처리하는 등의 작업을 일관된 방식으로 수행할 수 있다.

---

## 실무에서 자주 하는 오해

많은 개발자가

```
Task

=

Thread
```

라고 생각한다.
 
하지만 정확한 관계는

```
Task

↓

작업(Task)

↓

실행 방식은 다양함
```

이다.
 
실제로 하나의 Thread가 
여러 Task를 순차적으로 실행할 수도 있고,
 
하나의 Task가 ThreadPool에서 실행될 수도 있으며,
I/O 작업처럼 별도의 Thread 없이 완료되는 Task도 존재한다.
 
따라서 Task와 Thread를 같은 개념으로 이해하면 
이후 async/await의 동작 원리를 이해하기 어려워진다.

---

## 마무리
Task는 스레드가 아니라 **비동기 작업을 표현하는 객체**이다.
작업의 시작, 진행, 완료, 실패, 취소 등의 상태를 관리하며, 실행 방식은 작업의 종류에 따라 달라질 수 있다.
 
이러한 추상화 덕분에 개발자는 스레드를 직접 관리하지 않고도 여러 작업을 조합하고, 완료를 기다리고, 예외를 처리하는 코드를 일관된 방식으로 작성할 수 있다.
 
다음 글에서는 **async와 await는 내부적으로 어떻게 동작할까?**를 살펴보며 C# 컴파일러가 비동기 코드를 어떻게 변환하는지 알아보겠다.

---

## 핵심 정리

- Task는 스레드가 아니라 작업(Task)을 표현하는 객체이다.
- Task는 작업의 상태(실행 중, 완료, 실패, 취소)를 관리한다.
- Task<T>는 작업의 결과까지 함께 표현한다.
- Task를 사용한다고 반드시 새로운 스레드가 생성되는 것은 아니다.
- Task.Run()은 ThreadPool에서 작업을 실행하는 방법 중 하나이다.
- 대부분의 .NET 비동기 API는 Task 또는 Task<T>를 반환한다.
