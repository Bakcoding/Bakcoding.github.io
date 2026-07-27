---
title: "[궁금시리즈] 5-6. Task.Run()은 언제 사용해야 할까?"
excerpt: "C#"
categories:
  - Programming
tags:
  - CSharp
permalink: /programming/5-6-task-run/
toc: true
toc_sticky: true
date: 2026-07-27
last_modified_at: 2026-07-27
---

비동기 코드를 작성하다 보면 다음과 같은 코드를 자주 보게 된다.

```cs
await Task.Run(() =>
{
    DoWork();
});
```

많은 개발자는

> "비동기 작업은 모두 Task.Run으로 실행해야 한다."

라고 생각한다.
 
하지만 실제로는 그렇지 않다.

Task.Run()은 모든 비동기 작업을 위한 도구가 아니라 CPU를 많이 사용하는 작업(CPU Bound) 을 다른 스레드에서 실행하기 위한 도구이다.
 
이번 글에서는 Task.Run()이 왜 존재하는지, 그리고 언제 사용해야 하는지 알아보자.

---

## 먼저 Task.Run은 무엇일까?

다음 코드를 보자.

```cs
await Task.Run(() =>
{
    HeavyCalculation();
});
```

Task.Run()은 전달된 작업을 **ThreadPool의 스레드에서 실행하도록 예약**한다.
 
즉,

```
Main Thread

↓

Task.Run

↓

ThreadPool Thread

↓

HeavyCalculation()
```

이라는 흐름으로 동작한다.
여기서 중요한 점은

> Task.Run은 새로운 Thread를 만드는 것이 아니라 ThreadPool을 사용한다.

는 것이다.

---

## 왜 다른 스레드에서 실행할까?

예를 들어

다음과 같은 계산이 있다고 하자.

```cs
for (int i = 0; i < 5_000_000_000; i++)
{
    // 복잡한 계산
}
```

이 작업은 CPU가 계속 계산해야 한다.
 
만약 UI Thread에서 실행하면

```
계산 시작

↓

UI 멈춤

↓

계산 완료

↓

UI 다시 동작
```

하게 된다.
 
이런 경우에는

```cs
await Task.Run(() =>
{
    HeavyCalculation();
});
```

을 사용하면 계산은 ThreadPool에서 수행되고
UI는 계속 반응할 수 있다.

---

## 그런데 파일 읽기도 Task.Run을 사용할까?

다음 코드를 보자.

```cs
await Task.Run(() =>
{
    File.ReadAllText(path);
});
```

많은 초보 개발자가 이렇게 작성한다.

하지만 좋은 방법이 아니다.

왜일까?

파일 읽기는
CPU가 계산하는 작업이 아니라
디스크를 기다리는 작업이다.
 
즉,

```
파일 읽기 요청

↓

디스크가 읽는 동안 대기
```

하는 시간이 대부분이다.
 
그런데 Task.Run으로 감싸면

```
ThreadPool Thread

↓

아무것도 못 하고 대기
```

하게 된다.
 
즉,
스레드 하나를
불필요하게 점유한다.

---

## 올바른 방법은?

파일은 비동기 API를 사용하면 된다.

```cs
await File.ReadAllTextAsync(path);
```

그러면

```
파일 읽기 요청

↓

운영체제가 처리

↓

현재 Thread는 다른 작업 수행

↓

완료 후 이어서 실행
```

이 된다.
 
즉,
ThreadPool 스레드를 점유하지 않는다.

---

## HTTP 요청도 마찬가지이다

다음 코드도 자주 보인다.

```
await Task.Run(() =>
{
    httpClient.GetStringAsync(url).Result;
});
```

이 역시 좋지 않다.
 
이미

```
await httpClient.GetStringAsync(url);
```

가 비동기 API이다.

굳이 Task.Run으로
한 번 더 감쌀 이유가 없다.

---

## 언제 Task.Run을 사용해야 할까?

대표적인 예는

**이미지 처리**

```cs
await Task.Run(() =>
{
    ResizeImage();
});
```

---

**압축**

```cs
await Task.Run(() =>
{
    CompressFile();
});
```

---

**대량 계산**

```cs
await Task.Run(() =>
{
    CalculatePhysics();
});
```

**AI 계산**

```cs
await Task.Run(() =>
{
    RunNeuralNetwork();
});
```


이처럼

CPU가 계속 계산해야 하는 작업이라면
Task.Run이 적합하다.

---

## 게임 개발에서는?

게임에서도 메인 스레드는

```
입력

↓

물리

↓

렌더링
```

을 계속 수행해야 한다.
 
만약

맵 생성

```
100만 개 타일 생성
```

같은 작업을 메인 스레드에서 
수행하면 프레임이 끊긴다.
 
이럴 때는

```cs
await Task.Run(() =>
{
    GenerateMap();
});
```

처럼 별도의 ThreadPool 스레드에서 계산하도록 할 수 있다.
 
단,
Unity에서는 대부분의 엔진 API가 메인 스레드에서만 호출 가능하므로, Task.Run() 안에서는 **순수 계산만 수행**해야 한다.

예를 들어 다음과 같은 코드는 문제가 된다.

```cs
await Task.Run(() =>
{
    GameObject.Find("Player");   // ❌
    transform.position = Vector3.zero; // ❌
});
```
 
반면,

```cs
var vertices = await Task.Run(() =>
{
    return GenerateTerrainVertices();
});

// 메인 스레드
mesh.vertices = vertices;
```

처럼 계산과 Unity API 호출을 분리하는 것이 올바른 방법이다.

---

## 실제 .NET에서는 어떻게 동작할까?

Task.Run()은 내부적으로 작업을 **ThreadPool**에 등록한다.

개념적으로는 다음과 같은 흐름이다.

```
Task.Run()

↓

ThreadPool 작업 등록

↓

사용 가능한 ThreadPool 스레드 선택

↓

작업 실행

↓

Task 완료
```

ThreadPool은 작업이 끝난 스레드를 재사용하므로, 매번 새로운 스레드를 생성하는 것보다 훨씬 효율적이다.

---

## 실무에서 자주 하는 오해

가장 흔한 오해는

> 비동기 메서드는 모두 Task.Run으로 감싸야 한다.

라는 것이다.
 
예를 들어

```cs
await Task.Run(() => File.ReadAllText(path));
```

보다는

```cs
await File.ReadAllTextAsync(path);
```

가 더 적절하다.
 
이미 비동기 API가 제공되는 작업을 Task.Run()으로 감싸면 스레드만 불필요하게 점유하게 된다.
즉,

- **CPU 계산 → Task.Run 고려**
- **파일, 네트워크, DB → 비동기 API 사용**

이라는 기준을 기억하면 된다.

---

## 마무리

Task.Run()은 비동기 작업을 만드는 도구가 아니라, **CPU를 많이 사용하는 작업을 ThreadPool에서 실행하기 위한 도구**이다.

이미 비동기 API가 제공되는 파일 입출력이나 네트워크 통신에서는 Task.Run()을 사용할 필요가 없으며, 오히려 불필요하게 스레드를 점유하여 효율을 떨어뜨릴 수 있다.
 
반대로 이미지 처리, 압축, 복잡한 계산처럼 CPU를 오래 사용하는 작업에서는 Task.Run()을 통해 UI나 메인 스레드의 응답성을 유지할 수 있다.
 
다음 글에서는 **CPU Bound와 I/O Bound는 무엇이 다를까?**를 살펴보며 지금까지 다룬 비동기와 Task.Run()의 개념을 하나로 연결해 보겠다.

---

## 핵심 정리

- Task.Run()은 작업을 ThreadPool에서 실행하도록 예약한다.
- Task.Run()은 새로운 스레드를 만드는 것이 아니라 ThreadPool을 사용한다.
- CPU를 많이 사용하는 작업에는 Task.Run()이 적합하다.
- 파일 입출력, 네트워크 통신, 데이터베이스 조회는 비동기 API를 사용하는 것이 더 효율적이다.
- 이미 비동기 API가 있는 작업을 Task.Run()으로 감싸는 것은 일반적으로 권장되지 않는다.
- Unity에서는 Task.Run() 안에서 Unity API를 호출하면 안 되며, 순수 계산만 수행해야 한다.
