---
title: "[궁금시리즈] 5-7. CPU Bound와 I/O Bound는 무엇이 다를까?"
excerpt: "C#"
categories:
  - Programming
tags:
  - CSharp
permalink: /programming/5-7-cpu-bound-i-o-bound/
toc: true
toc_sticky: true
date: 2026-07-27
last_modified_at: 2026-07-27
---

비동기 프로그래밍을 공부하다 보면 자주 등장하는 용어가 있다.
바로 **CPU Bound**와 **I/O Bound**이다.
처음에는 단순히

- CPU 작업
- 입출력 작업

정도로 이해하기 쉽다.
 
하지만 실제로는 **어떤 작업인지에 따라 비동기 처리 방식이 완전히 달라진다.**

이번 글에서는 CPU Bound와 I/O Bound의 차이와 각각 어떤 방식으로 처리해야 하는지 알아보자.

---

## CPU Bound란?
CPU Bound는

> CPU가 계속 계산해야 하는 작업이다.

예를 들어

```cs
for (int i = 0; i < 5_000_000_000; i++)
{
    result += i;
}
```

CPU는

```
계산

↓

계산

↓

계산

↓

계산
```

처럼 쉬지 않고 연산을 수행한다.

즉, CPU 성능이
작업 속도를 결정한다.

**대표적인 CPU Bound 작업은**

- 이미지 처리
- 영상 인코딩
- 데이터 압축
- AI 계산
- 암호화
- 대량의 수학 연산
- 물리 계산

등이 있다.

---

## I/O Bound란?

반대로 I/O Bound는 CPU가 계산하는 시간이 아니라
**외부 장치를 기다리는 시간이 대부분인 작업**이다.
 
예를 들어

```cs
await File.ReadAllTextAsync(path);
```

CPU는 파일을 직접 읽지 않는다.

```
파일 읽기 요청

↓

디스크 동작

↓

기다림

↓

읽기 완료
```

처럼 대부분의 시간은
디스크를 기다린다.

**대표적인 I/O Bound 작업은**

- 파일 읽기
- 파일 저장
- 네트워크 요청
- HTTP 통신
- 데이터베이스 조회
- 소켓 통신

등이 있다.

---

## 둘의 가장 큰 차이

CPU Bound는

```
CPU가 바쁘다.
```

I/O Bound는

```
CPU는 놀고 있다.

↓

외부 장치를 기다린다.
```

라는 차이가 있다.

이 차이가 비동기 처리 방식을 결정한다.

---

## CPU Bound는 어떻게 처리할까?

CPU는 계산을 직접 해야 한다.
 
즉,
누군가는 반드시 계산을 수행해야 한다.
 
따라서

```cs
await Task.Run(() =>
{
    HeavyCalculation();
});
```

처럼 ThreadPool에서
계산하도록 하는 것이 일반적이다.

```
Main Thread

↓

Task.Run

↓

ThreadPool

↓

계산
```

---

## I/O Bound는 어떻게 처리할까?

I/O는 기다리는 시간이 대부분이다.
 
즉,
굳이 Thread 하나가
계속 대기할 필요가 없다.
 
예를 들어

```cs
await httpClient.GetAsync(url);
```

는

```
HTTP 요청

↓

운영체제가 처리

↓

Thread 반환

↓

응답 도착

↓

이어서 실행
```

이라는 흐름으로 동작한다.
 
CPU는 그동안 다른 작업을 수행할 수 있다.

---

## Task.Run을 사용하면 안 되는 이유

다음 코드를 보자.

```cs
await Task.Run(() =>
{
    File.ReadAllText(path);
});
```

겉으로 보면 비동기처럼 보인다.
 
하지만 실제로는

```
ThreadPool

↓

파일 읽기

↓

기다림

↓

기다림

↓

기다림
```

Thread 하나가 계속 놀고 있다.
 
반면

```cs
await File.ReadAllTextAsync(path);
```

는

```
파일 요청

↓

Thread 반환

↓

응답 도착

↓

Thread 확보

↓

이어서 실행
```

이 된다.
 
훨씬 효율적이다.

---

## 게임 개발에서는?

게임에서는 대부분
CPU Bound 작업이 많다.
 
예를 들어

- 길찾기(Path Finding)
- AI
- 물리 계산
- Procedural Generation

등은 CPU가 계속 계산해야 한다.
 
이런 작업은 Task.Run이 도움이 된다.
 
반대로

- 서버 통신
- 로그인
- 리소스 다운로드
- 패치

등은 I/O Bound이다.
 
이 경우에는 비동기 API를
그대로 사용하는 것이 좋다.

---

## 실제 .NET에서는 어떻게 처리할까?

.NET은 작업의 성격에 따라 서로 다른 방식을 사용한다.
 
**CPU Bound**

```cs
await Task.Run(() =>
{
    ProcessImage();
});
```

↓

```
ThreadPool

↓

CPU 계산

↓

Task 완료
```

---

**I/O Bound**

```cs
await File.ReadAllTextAsync(path);
```

↓

```
OS 비동기 I/O 요청

↓

Thread 반환

↓

완료 알림

↓

Task 완료
```

즉,
CPU 작업은 **스레드를 빌려 계산**하고,
I/O 작업은 **운영체제의 비동기 기능을 활용하여 기다림을 최소화**한다.

---

## 어떤 작업인지 어떻게 구분할까?

다음 질문을 해 보면 쉽게 판단할 수 있다.

> "이 작업은 CPU가 계속 계산하는가?"

 
그렇다면 CPU Bound이다.
 
반대로

> "대부분 기다리는 시간인가?"

 
그렇다면 I/O Bound이다.
 
예를 들어

| 작업 | 종류 |
| --- | ---- |
| 이미지 리사이즈 | CPU Bound |
| JSON 파싱 | CPU Bound |
| 암호화 | CPU Bound |
| 파일 읽기 | I/O Bound |
| HTTP 요청 | I/O Bound |
| DB 조회 | I/O Bound |

---

## 실무에서 자주 하는 오해

가장 흔한 오해는

> 비동기면 모두 Task.Run을 사용해야 한다.
 
라는 것이다.
 
하지만
비동기 API가 제공되는 I/O 작업은
이미 효율적으로 구현되어 있다.
 
오히려
Task.Run으로 감싸면
ThreadPool 스레드를 불필요하게 점유하게 된다.

반대로
CPU를 오래 사용하는 작업은 
비동기 API가 있더라도
결국 누군가는 계산해야 하므로 
Task.Run()과 같은 방법으로 계산을 다른 스레드에 맡기는 것이 적절하다.

---

## 마무리
CPU Bound와 I/O Bound의 가장 큰 차이는 **시간을 어디에서 소비하는가**이다.
CPU Bound는 CPU가 계속 계산을 수행하므로 다른 스레드에서 실행하여 응답성을 유지하는 것이 중요하다.
 
반면 I/O Bound는 외부 장치의 응답을 기다리는 시간이 대부분이므로, 운영체제의 비동기 I/O 기능을 활용하는 것이 가장 효율적이다.
 
이 두 가지를 구분할 수 있다면 언제 Task.Run()을 사용해야 하는지, 언제 비동기 API를 그대로 사용해야 하는지도 자연스럽게 판단할 수 있게 된다.
 
다음 글에서는 **async void를 사용하면 안 되는 이유**를 살펴보며 C# 비동기 프로그래밍에서 가장 위험한 실수 중 하나를 알아보겠다.

---

## 핵심 정리

- CPU Bound는 CPU가 계속 계산하는 작업이다.
- I/O Bound는 외부 장치의 응답을 기다리는 작업이다.
- CPU Bound는 Task.Run()을 통해 ThreadPool에서 실행하는 것이 일반적이다.
- I/O Bound는 ReadAllTextAsync(), GetAsync() 같은 비동기 API를 사용하는 것이 효율적이다.
- I/O 작업을 Task.Run()으로 감싸는 것은 일반적으로 권장되지 않는다.
- 작업의 성격을 구분하는 것이 올바른 비동기 프로그래밍의 핵심이다.
