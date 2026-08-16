---
title: "[궁금시리즈] 5-11. 비동기 프로그래밍에서 자주 하는 실수 총정리"
excerpt: "C#"
categories:
  - CSharp
series: question-series
tags:
  - CSharp
permalink: /programming/5-11/
toc: true
toc_sticky: true
date: 2026-07-27
last_modified_at: 2026-07-27
---

## 들어가며

지금까지 비동기 프로그래밍에 대해 살펴보았다.

- Task는 무엇인가
- async와 await는 어떻게 동작하는가
- SynchronizationContext
- ConfigureAwait(false)
- Task.Run
- CPU Bound와 I/O Bound
- async void
- Task.WhenAll
- CancellationToken

개념 하나하나는 이해하기 어렵지 않다.
 
하지만 실제 프로젝트에서는 이러한 개념을 잘못 이해하여 성능 저하나 버그를 만드는 경우가 매우 많다.
이번 글에서는 실무에서 가장 자주 발생하는 비동기 프로그래밍 실수들을 정리해 보자.

---

## 1. Task를 Thread라고 생각하기

가장 흔한 오해이다.

많은 개발자가

```
Task = Thread
```

라고 생각한다.
 
하지만 Task는

> 작업(Task)을 표현하는 객체

이다.
 
실행은

- ThreadPool
- 운영체제 비동기 I/O
- 이미 완료된 Task

등 다양한 방식으로 이루어진다.
 
즉,
Task와 Thread는 전혀 다른 개념이다.

---

## 2. 모든 비동기 작업을 Task.Run으로 감싸기

다음 코드는 흔히 볼 수 있는 잘못된 예이다.

```cs
await Task.Run(() =>
{
    File.ReadAllText(path);
});
```

파일 읽기는 이미 비동기 API가 존재한다.

```cs
await File.ReadAllTextAsync(path);
```

를 사용하는 것이 올바르다.
 
Task.Run은 CPU 계산을 위한 도구이지
모든 비동기 작업을 위한 도구가 아니다.

---

## 3. async void를 일반 메서드에 사용하기

다음 코드는 좋지 않다.

```
public async void SaveAsync()
{
}
```

이렇게 작성하면

- await 불가능
- 예외 처리 어려움
- 테스트 어려움
- Task 조합 불가능

등의 문제가 발생한다.

일반적인 비동기 메서드는

```
public async Task SaveAsync()
{
}
```

를 사용하는 것이 좋다.

---

## 4. await를 사용하지 않기

다음 코드를 보자.

```
DownloadAsync();

Console.WriteLine("끝");
```

Task를 시작만 하고 기다리지 않는다.
 
그러면 작업이 끝나기 전에 메서드가 종료될 수도 있다.
 
의도적으로 백그라운드 실행(Fire-and-Forget)을 하는 경우가 아니라면,

비동기 메서드는 반드시 await 하는 것이 좋다.

---

## 5. .Result와 .Wait()를 남용하기

다음 코드도 자주 보인다.

```cs
string text = httpClient
    .GetStringAsync(url)
    .Result;
```

또는

```cs
task.Wait();
```

이 코드는 현재 Thread를 강제로 Block한다.

UI에서는 프로그램이 멈춘 것처럼 보일 수도 있다.
 
가능하면

```cs
await httpClient.GetStringAsync(url);
```

를 사용하는 것이 좋다.

> 참고
과거에는 .Result나 .Wait()가 SynchronizationContext와 결합되어 교착 상태(Deadlock)를 일으키는 경우가 많았다. 특히 WinForms, WPF, 기존 ASP.NET에서 자주 발생했다.
.NET Core와 ASP.NET Core에서는 이러한 문제가 크게 줄었지만, 스레드를 불필요하게 점유하고 응답성을 떨어뜨린다는 점은 여전히 동일하다.

---

## 6. CPU Bound와 I/O Bound를 구분하지 않기

**CPU 작업**

```
이미지 처리

암호화

압축

AI
```
↓
Task.Run 고려

---

**I/O 작업**

```
파일 읽기

DB

HTTP

Socket
```
↓
비동기 API 사용 

이 구분만 제대로 해도 성능이 크게 좋아진다.

---

## 7. CancellationToken을 무시하기

비동기 메서드를 만들면서

```cs
public async Task DownloadAsync()
{
}
```

처럼 취소 기능을 고려하지 않는 경우가 많다.
 
실무에서는

```cs
public async Task DownloadAsync(
    CancellationToken token)
{
}
```

처럼 취소를 지원하는 것이 일반적이다.
 
특히

- 서버 요청
- 다운로드
- 긴 계산

에서는 매우 중요하다.

---

## 8. 독립적인 작업을 순차적으로 실행하기

다음 코드를 보자.

```cs
await LoadProfileAsync();
await LoadInventoryAsync();
await LoadQuestAsync();
```

각 작업이 서로 독립적이라면
다음과 같이 작성하는 편이 효율적이다.

```cs
Task profile = LoadProfileAsync();
Task inventory = LoadInventoryAsync();
Task quest = LoadQuestAsync();

await Task.WhenAll(profile, inventory, quest);
```

전체 실행 시간을 크게 줄일 수 있다.
 
단, **작업 사이에 의존성이 없다면**이라는 전제가 필요하다.

예를 들어 B 작업이 A의 결과를 필요로 한다면 Task.WhenAll()을 사용할 수 없다.

---

## 9. 예외를 무시하기

다음 코드는 위험하다.

```
_ = DownloadAsync();
```

작업은 실행되지만 예외가 발생해도 아무도 처리하지 않을 수 있다.
 
Fire-and-Forget가 꼭 필요하다면 예외를 기록(Log)하거나 
내부에서 처리하도록 만드는 것이 좋다.

---

## 10. Unity API를 Task.Run 안에서 호출하기

Unity 개발자가 가장 많이 하는 실수이다.

```cs
await Task.Run(() =>
{
    transform.position = Vector3.zero;
});
```

Unity의 대부분의 API는
메인 스레드에서만 호출할 수 있다.
 
올바른 방법은

```cs
Vector3[] vertices = await Task.Run(() =>
{
    return GenerateVertices();
});

mesh.vertices = vertices;
```

처럼 계산만 Task.Run에서 수행하고
Unity API는 메인 스레드에서 호출하는 것이다.

---

## 실무에서 기억하면 좋은 기준

비동기 코드를 작성할 때 아래 질문을 순서대로 해 보면 대부분의 판단을 쉽게 내릴 수 있다.

1. **이 작업은 CPU 계산인가, I/O 대기인가?**
2. **이미 비동기 API가 제공되는가?**
3. **작업을 끝까지 기다려야 하는가?**
4. **취소가 필요한 작업인가?**
5. **여러 작업을 동시에 수행할 수 있는가?**
6. **현재 코드가 UI Context에 의존하는가?**

이 질문만으로도 대부분의 비동기 코드 설계 방향을 결정할 수 있다.

---

## 마무리
비동기 프로그래밍은 새로운 스레드를 만드는 기술이 아니라 **기다리는 시간을 효율적으로 활용하고 프로그램의 응답성을 높이기 위한 프로그래밍 방식**이다.
 
중요한 것은 문법을 외우는 것이 아니라 작업의 성격을 이해하는 것이다.

- CPU를 많이 사용하는 작업인지
- 외부 장치를 기다리는 작업인지
- 작업을 취소할 필요가 있는지
- 여러 작업을 동시에 수행할 수 있는지

이러한 관점으로 접근하면 언제 Task.Run()을 사용해야 하는지, 언제 Task.WhenAll()이 적절한지, 언제 CancellationToken을 전달해야 하는지도 자연스럽게 판단할 수 있다.
 
비동기 프로그래밍은 처음에는 복잡하게 느껴질 수 있지만, 기본 원리를 이해하면 코드의 성능과 유지보수성을 크게 향상시킬 수 있는 강력한 도구가 된다.

---

## 핵심 정리

- Task는 스레드가 아니라 작업을 표현하는 객체이다.
- CPU Bound와 I/O Bound를 구분하는 것이 가장 중요하다.
- 이미 비동기 API가 있다면 Task.Run()으로 감싸지 않는다.
- 일반적인 비동기 메서드는 Task 또는 Task<T>를 반환한다.
- .Result와 .Wait()보다는 await를 사용하는 것이 좋다.
- 독립적인 작업은 Task.WhenAll()로 함께 처리할 수 있다.
- CancellationToken을 지원하면 더 유연한 비동기 코드를 작성할 수 있다.
- Unity에서는 Task.Run() 안에서 Unity API를 호출하지 않는다.
