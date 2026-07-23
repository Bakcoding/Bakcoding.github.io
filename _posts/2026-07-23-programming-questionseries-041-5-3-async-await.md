---
title: "[궁금시리즈] 5-3. async와 await는 내부적으로 어떻게 동작할까?"
excerpt: "C#"
categories:
  - Programming
tags:
  - CSharp
permalink: /programming/5-3-async-await/
toc: true
toc_sticky: true
date: 2026-07-23
last_modified_at: 2026-07-23
---

C#에서 비동기 프로그래밍을 시작하면 가장 먼저 배우는 문법이 있다.
바로 async와 await이다.

```cs
public async Task DownloadAsync()
{
    await Task.Delay(1000);

    Console.WriteLine("완료");
}
```

코드를 보면 일반적인 순차 실행과 크게 다르지 않다.
 
하지만 실제로는 메서드가 중간에 멈췄다가, 나중에 다시 이어서 실행된다.
 
메서드는 어떻게 자신의 실행 위치를 기억할 수 있을까?
이번 글에서는 async와 await가 내부적으로 어떻게 동작하는지 살펴보자.

---

## await는 스레드를 멈추는 것일까?

가장 많이 하는 오해부터 살펴보자.
 
많은 사람들이

> await는 현재 스레드를 멈춘다.

라고 생각한다.
 
하지만 그렇지 않다.

예를 들어

```cs
await Task.Delay(3000);
```

이 코드는

```
현재 스레드

↓

3초 동안 정지
```

가 아니라

```
Task 시작

↓

현재 메서드 일시 중단

↓

스레드는 다른 작업 수행

↓

Task 완료

↓

메서드 이어서 실행
```

이라는 흐름으로 동작한다.
 
즉,
멈추는 것은 스레드가 아니라 메서드의 실행 흐름이다.

---

## await는 어떤 일을 할까?

다음 코드를 보자.

```cs
Console.WriteLine("A");

await Task.Delay(1000);

Console.WriteLine("B");
```

실행 순서는

```
A 출력

↓

Task.Delay 시작

↓

메서드 중단

↓

1초 후 Task 완료

↓

B 출력
```

이 된다.
 
중요한 점은 Task.Delay()가 끝날 때까지 메서드 전체가 실행되는 것이 아니라,
**현재 위치를 저장한 후 잠시 빠져나간다**는 것이다.

---

## 메서드는 어떻게 다시 시작될까?

많은 사람들이

```
메서드가 멈춘다.

↓

나중에 다시 실행된다.
```

정도로 이해한다.
 
하지만 실제로는
컴파일러가 코드를 다른 형태로 바꾼다.
 
예를 들어

```cs
await Task.Delay(1000);

Console.WriteLine("Hello");
```

는 개념적으로 다음과 비슷하게 변환된다.

```
Task.Delay 시작

↓

끝나면

↓

Console.WriteLine("Hello")
```
 
즉,
"나중에 실행할 코드"를 등록해 두는 것이다.

---

## async는 무엇을 하는 키워드일까?

많은 사람들이

```
async

↓

비동기로 실행한다.
```

라고 생각한다.
 
하지만 async는 비동기 작업을 실행하는 키워드가 아니다.
 
async는

> 메서드 안에서 await를 사용할 수 있도록 컴파일러에게 알려주는 키워드이다.

예를 들어

```cs
public async Task Foo()
{
    await Task.Delay(100);
}
```

여기서 실제 비동기 작업을 수행하는 것은

```cs
Task.Delay()
```

이다.
 
async는 그 메서드를 비동기 상태 머신으로 
변환하도록 지시할 뿐이다.

---

## 상태 머신(State Machine)이란?

await를 사용한 메서드는 컴파일 후
대략 이런 구조로 바뀐다.

```
상태 0

↓

Task 시작

↓

Task 미완료

↓

메서드 종료
```

Task가 끝나면

```
상태 1

↓

await 이후 코드 실행

↓

메서드 완료
```
 
즉,
메서드가 실행 위치를 상태(State)로 저장한다.
 
이 구조를 **상태 머신(State Machine)**이라고 한다.

---

## 왜 상태 머신이 필요할까?

다음 코드를 보자.

```cs
Console.WriteLine("1");

await Task.Delay(1000);

Console.WriteLine("2");

await Task.Delay(1000);

Console.WriteLine("3");
```

중간에 두 번 멈춘다.
 
컴파일러는

```
State 0

↓

1 출력

↓

await
```

```
State 1

↓

2 출력

↓

await
```

```
State 2

↓

3 출력

↓

종료
```

처럼 현재 어디까지 실행했는지를
상태 번호로 관리한다.
 
그래서 나중에 정확한 위치부터 다시 실행할 수 있다.

---

## 실제 컴파일 후에는 어떻게 될까?

실제 IL은 훨씬 복잡하지만,
컴파일러는 대략

```cs
struct DownloadAsyncStateMachine
{
    int _state;

    AsyncTaskMethodBuilder _builder;
}
```

와 비슷한 구조를 생성한다.
 
그리고 MoveNext()라는 메서드 안에서
현재 상태를 확인하며 다음 코드를 실행한다.
 
즉,
우리가 작성한

```
await
```

는 컴파일 후에는
상태 머신 코드로 바뀐다.

---

## await가 Task를 만나면 항상 중단될까?

아니다.
 
예를 들어

```cs
await Task.CompletedTask;
```

는 이미 완료된 Task이다.

이 경우에는 메서드를 중단하지 않고
바로 다음 코드를 실행한다.
 
즉,
await는 항상 중단하는 것이 아니라
**Task가 아직 완료되지 않았을 때만 메서드를 일시 중단한다.**

---

## 실제 .NET에서는 어떻게 이어서 실행될까?

await는 Task가 완료되면 이어서 실행할 코드를 등록한다.
개념적으로는 다음과 같은 흐름이다.

```
Task 시작

↓

Task 완료 시 실행할 작업 등록

↓

현재 메서드 반환

↓

Task 완료

↓

등록된 나머지 코드 실행
```

실제 구현에서는 TaskAwaiter와 상태 머신이 함께 동작하여 이 과정을 처리한다.

덕분에 개발자는 복잡한 콜백(Callback)을 직접 작성하지 않고도 순
차적인 코드 형태로 비동기 로직을 작성할 수 있다.

---

## 실무에서 자주 하는 오해

가장 흔한 오해는

```
await

↓

현재 스레드를 기다리게 한다.
```

라는 생각이다.
 
실제로는
**메서드만 잠시 중단**된다.
 
그래서 UI 프로그램에서도

```cs
await httpClient.GetAsync(url);
```

를 사용하면 네트워크 응답을 기다리는 동안에도
버튼 클릭이나 화면 그리기 같은 작업은 계속 수행할 수 있다.
 
이것이 await가 프로그램의 응답성을 높여 주는 이유이다.

---

## 마무리

async와 await는 비동기 작업을 실행하는 기능이 아니라, **비동기 코드를 순차 코드처럼 작성할 수 있도록 도와주는 언어 기능**이다.

컴파일러는 await가 포함된 메서드를 상태 머신으로 변환하고, 작업이 완료되면 중단된 위치부터 다시 실행하도록 코드를 생성한다.
 
이러한 구조 덕분에 개발자는 복잡한 콜백 체인을 직접 관리하지 않고도 읽기 쉽고 유지보수하기 쉬운 비동기 코드를 작성할 수 있다.
 
다음 글에서는 **await 이후에는 어떤 스레드에서 실행될까?**를 살펴보며 SynchronizationContext와 ConfigureAwait(false)의 필요성을 알아보겠다.

---

## 핵심 정리

- await는 스레드를 멈추는 것이 아니라 메서드의 실행을 일시 중단한다.
- async는 메서드를 비동기 상태 머신으로 변환하도록 컴파일러에 알려주는 키워드이다.
- 컴파일러는 await가 있는 메서드를 상태 머신(State Machine)으로 변환한다.
- 상태 머신은 실행 위치를 상태(State)로 관리한다.
- await는 Task가 완료되지 않았을 때만 메서드를 중단한다.
- 완료된 Task를 await하면 이어서 바로 실행된다.
- TaskAwaiter와 상태 머신이 함께 동작하여 비동기 흐름을 구현한다.
