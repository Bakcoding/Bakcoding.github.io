---
title: "[궁금시리즈] 2-10. stackalloc과 Span<T>는 왜 등장했을까?"
excerpt: "C#"
categories:
  - Programming
tags:
  - CSharp
permalink: /programming/2-10-stackalloc-span-t/
toc: true
toc_sticky: true
date: 2026-07-23
last_modified_at: 2026-07-23
---

앞선 글에서 Heap에 객체를 많이 생성하면 GC가 자주 발생하고, 이를 줄이기 위해 Object Pool을 사용할 수 있다고 설명했다.

그렇다면 이런 생각이 들 수 있다.

> "애초에 Heap에 할당하지 않으면 더 좋은 것 아닐까?"

실제로 .NET은 이런 상황을 위해 Stack 메모리를 적극적으로 활용할 수 있는 기능을 제공한다.
바로 stackalloc과 Span<T>이다.

이번 글에서는 이 두 기능이 왜 등장했으며, 어떤 상황에서 사용해야 하는지 알아보자.

---

## 왜 새로운 기능이 필요했을까?

예를 들어

```cs
byte[] buffer = new byte[1024];
```

이 코드는 배열을 생성한다.
배열은 **참조 타입**이므로
Heap에 생성된다.

```
Stack

buffer

↓

Heap

byte[1024]
```

메서드가 자주 호출되면

```
Heap 할당

↓

GC

↓

Heap 할당

↓

GC
```

가 반복된다.

---

## 작은 배열도 Heap에 생성된다

다음 코드도 마찬가지이다.

```cs
char[] chars = new char[32];
```

32개의 문자만 저장하는 작은 
배열이지만 Heap에 생성된다.

이런 작은 배열이 수천 번, 수만 번 생성되면
GC 부담이 커질 수 있다.

---

## stackalloc이란?

stackalloc은

> 배열을 Heap이 아닌 Stack에 생성하는 기능이다.

예를 들어

```cs
Span<int> numbers = stackalloc int[10];
```

메모리는

```
Stack

numbers

↓

int[10]
```

이 된다.

Heap을 사용하지 않는다.

---

## Stack을 사용하는 이유

Stack은 메서드가 종료되면
자동으로 제거된다.

```
메서드 종료

↓

Stack Frame 제거

↓

메모리 반환
```

GC가 개입하지 않는다.
즉, 아주 짧게 사용하는 메모리라면
Heap보다 효율적일 수 있다.

## 그렇다면 배열 대신 stackalloc만 쓰면 될까?

아니다. 

Stack 메모리는 크기가 제한되어 있다.

예를 들어

```cs
Span<int> numbers = stackalloc int[100000];
```

처럼 너무 큰 메모리를 Stack에 생성하면
Stack Overflow가 발생할 수 있다.

따라서

stackalloc은 작은 크기의 임시 버퍼를 만들 때 사용하는 것이 일반적이다.

---

## 그런데 stackalloc은 왜 불편했을까?

초기의 C#에서는

```cs
int* numbers = stackalloc int[10];
```

처럼 포인터를 사용해야 했다.

즉, 

```
unsafe 코드 
```

가 필요했다.

안전성이 떨어졌기 때문에
사용이 쉽지 않았다.

---

## Span<T>의 등장

이를 해결하기 위해 Span<T>가 등장했다.

Span<T>는

> 메모리의 연속된 영역을 안전하게 다루기 위한 타입이다.

중요한 점은 Heap과 Stack을
모두 참조할 수 있다는 것이다.

---

**Heap도 가능하다**

```cs
int[] numbers = { 1, 2, 3 };

Span<int> span = numbers;
```

---

**Stack도 가능하다**

```cs
Span<int> span = stackalloc int[10];
```
 
같은 코드로 Stack 메모리도
안전하게 사용할 수 있다.

---

**Span은 복사가 아니다**

예를 들어

```cs
int[] numbers = {1,2,3};

Span<int> span = numbers;
```

메모리는

```
Span

↓

int[]
```

이다.

새로운 배열을 만드는 것이 아니라
기존 메모리를 바라본다.

---

## Slice도 복사하지 않는다

```cs
Span<int> part = span.Slice(2, 5);
```

많은 사람들이 새 배열이 생성된다고 생각한다.

하지만 그렇지 않다.

```
원본 배열

↓

Slice

↓

같은 메모리
```

범위만 바뀐다.
복사가 발생하지 않는다.

---

## ReadOnlySpan<T>

읽기만 가능하도록 만들 수도 있다.

```cs
ReadOnlySpan<char> text = "Hello";
```

수정은 불가능하다.
읽기 전용 데이터를 처리할 때 자주 사용된다.

---

## 왜 성능이 좋을까?

**기존 방식**

```
string.Substring()
```
↓
새 문자열 생성
↓
Heap 할당
↓
GC

---

**Span**

```cs
text.AsSpan().Slice(...)
```
↓
복사 없음
↓
Heap 할당 없음
↓
GC 없음

즉, 메모리 복사를 줄일 수 있다.

---

**Span의 제약**

Span은 매우 빠르지만
제약도 있다.

예를 들어
다음 코드는 불가능하다.

```cs
class Player
{
    Span<int> data;
}
```

왜냐하면 Span은 Stack 기반 타입(ref struct)이기 때문이다.

또한

- Boxing 불가
- async 메서드에서 장기간 보관 불가
- 람다에서 캡처 불가

등의 제약이 있다.

이는 Span이 Stack 기반의 안전성을 유지하기 위한 설계이다.

---

## 언제 사용할까?

다음과 같은 경우에 적합하다.

- 문자열 파싱
- JSON 처리
- 네트워크 패킷 분석
- 파일 읽기
- 바이너리 데이터 처리
- 게임 서버
- 고성능 라이브러리

일반적인 업무 프로그램에서는
사용 빈도가 높지 않을 수도 있다.

---

## 마무리
stackalloc과 Span<T>는 Heap 할당을 줄이고 불필요한 메모리 복사를 방지하기 위해 등장한 기능이다.

특히 고성능이 요구되는 라이브러리나 게임 서버에서는 매우 강력한 도구이지만, 일반적인 애플리케이션에서는 코드 복잡도가 증가할 수 있으므로 필요한 곳에만 사용하는 것이 좋다.

메모리 최적화는 **무조건 최신 기능을 사용하는 것**이 아니라, **실제 병목이 발생하는 지점을 측정하고 적절한 기술을 적용하는 것**이 핵심이다.

이로써 **메모리 관리** 챕터를 마무리하고, 다음 장인 **Generic**으로 넘어가겠다.

---

## 핵심 정리

- 배열은 기본적으로 Heap에 생성된다.
- stackalloc은 Stack에 메모리를 할당한다.
- Stack 메모리는 GC 대상이 아니다.
- Span<T>는 Heap과 Stack 메모리를 모두 안전하게 다룰 수 있다.
- Slice()는 데이터를 복사하지 않고 같은 메모리를 참조한다.
- ReadOnlySpan<T>는 읽기 전용 메모리를 표현한다.
- Span<T>는 ref struct이므로 일반 구조체보다 제약이 많다.
- stackalloc과 Span<T>는 성능이 중요한 코드에서 사용하는 것이 적합하다.
