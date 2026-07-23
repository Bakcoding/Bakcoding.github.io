---
title: "[궁금시리즈] 2-6. IDisposable과 using은 왜 필요할까?"
excerpt: "C#"
categories:
  - Programming
tags:
  - CSharp
permalink: /programming/2-6-idisposable-using/
toc: true
toc_sticky: true
date: 2026-07-23
last_modified_at: 2026-07-23
---

앞선 글에서 Garbage Collector(GC)는 더 이상 사용하지 않는 객체를 자동으로 회수한다고 설명했다.

그렇다면 다음 코드는 어떨까?

```cs
FileStream stream = new FileStream("data.txt", FileMode.Open);
```

메서드가 끝나면 GC가 알아서 파일도 닫아줄까?

많은 초보 개발자가

> "GC가 있으니까 그냥 두면 되지 않을까?"

라고 생각한다.

하지만 정답은 아니다.

GC는 **메모리만 관리**할 뿐,
파일, 네트워크, 데이터베이스 연결 같은 **운영체제 자원(Unmanaged Resource)**은 관리하지 않는다.

그래서 등장한 것이 **IDisposable**과 **using**이다.

---

## GC가 관리하는 것

GC는 Heap에 생성된 객체를 관리한다.

예를 들어

```cs
Player player = new Player();
```

객체가 더 이상 참조되지 않으면
GC가 자동으로 회수한다.

즉,

```
Player 객체

↓

GC 회수
```

---

## GC가 관리하지 않는 것

하지만 다음과 같은 자원은 다르다.

- 파일(File)
- 소켓(Socket)
- 데이터베이스 연결(DB Connection)
- 윈도우 핸들(Window Handle)
- 프린터
- 카메라
- GPU 리소스

이러한 자원은 운영체제(OS)가 관리한다.

예를 들어

```cs
FileStream stream = new FileStream(...);
```

Heap에는

```
FileStream 객체
```

가 있지만 운영체제에는

```
파일 핸들
```

이 생성된다.

GC는 이 핸들을 언제 닫아야 하는지 알지 못한다.

---

## 문제가 되는 상황

다음 코드를 보자.

```cs
void ReadFile()
{
    FileStream stream =
        new FileStream("data.txt", FileMode.Open);
}
```

메서드가 종료되었다.

하지만 GC는 언제 실행될지 모른다.

즉, 파일이

```
계속 열린 상태
```

일 수도 있다.

그동안 다른 프로그램은
파일을 사용할 수 없을 수도 있다.

--- 

## IDisposable이란?

IDisposable은

> 사용이 끝난 자원을 직접 정리하기 위한 인터페이스이다.

정의는 매우 단순하다.

```cs
public interface IDisposable
{
    void Dispose();
}
```

즉, Dispose() 안에는

```
파일 닫기

소켓 닫기

DB 연결 종료
```

등의 작업이 들어간다.

---

## Dispose() 호출

예를 들어

```cs
FileStream stream =
    new FileStream("data.txt", FileMode.Open);

stream.Dispose();
```

Dispose를 호출하면 파일 핸들이 즉시 반환된다.

GC를 기다릴 필요가 없다.

---

## 그런데 Dispose를 깜빡하면?

실무에서는

```cs
FileStream stream =
    new FileStream(...);
```

만 작성하고 Dispose를 잊어버리는 경우가 많다.

그러면

- 파일 잠김
- 소켓 고갈
- DB Connection 부족

같은 문제가 발생할 수 있다.
그래서 더 안전한 문법이 등장했다.

---

## using이란?

using은 Dispose를 자동으로 호출하는 문법이다.

예를 들어

```cs
using (FileStream stream =
       new FileStream("data.txt", FileMode.Open))
{
    // 파일 사용
}
```

블록을 벗어나는 순간 자동으로

```cs
stream.Dispose();
```

가 호출된다.

즉, 실제로는

```cs
FileStream stream =
    new FileStream(...);

try
{
}
finally
{
    if(stream != null)
        stream.Dispose();
}
```

와 거의 같은 코드로 컴파일된다.

---

## using 선언문(C# 8.0)

최근에는 더 간단한 문법도 
사용할 수 있다.

```cs
using FileStream stream =
    new FileStream("data.txt", FileMode.Open);

// 사용
```

현재 스코프가 끝나면 자동으로 Dispose가 호출된다.
가독성이 더 좋아져 최근 프로젝트에서는 이 문법도 많이 사용한다.

---

## Dispose와 Finalizer는 다르다

가끔 Dispose 대신 Finalizer를 사용하면 되는 것 아니냐는 질문이 있다.

예를 들어

```cs
~Player()
{
}
```

Finalizer는 GC가 호출한다.

즉, 언제 실행될지 알 수 없다.

반면 Dispose는 개발자가 원하는 시점에 즉시 실행된다.

| Dispose | Finalizer |
| ------- | --------- |
| 즉시 실행 | GC가 나중에 실행 |
| 직접 호출 | 자동 호출 |
| 자원 즉시 해제 | 실행 시점 예측 불가 |

그래서 운영체제 자원은
Dispose를 사용하는 것이 원칙이다.

---

## IDisposable을 구현하는 경우

직접 클래스를 만들 때도 운영체제 
자원을 관리한다면 IDisposable을 구현해야 한다.

예를 들어

```cs
class FileManager : IDisposable
{
    private FileStream _stream;

    public void Dispose()
    {
        _stream?.Dispose();
    }
}
```

그러면 사용하는 쪽에서는

```cs
using FileManager manager = new FileManager();
```

처럼 안전하게 사용할 수 있다.

---

## 언제 IDisposable을 구현할까?

다음과 같은 경우이다.

- FileStream
- StreamReader
- StreamWriter
- SqlConnection
- Socket
- HttpClient(상황에 따라)
- Graphics
- Bitmap

즉, 운영체제 자원을 직접 관리하는 클래스라면
대부분 IDisposable을 구현한다.

---

## GC와 Dispose의 관계

많은 사람들이 둘 중 하나만 필요하다고 생각한다.

하지만 둘은 역할이 다르다.

```
GC

↓

메모리 관리
```

```
Dispose

↓

운영체제 자원 해제
```

즉, 서로 경쟁하는 기능이 아니라
함께 사용하는 기능이다.

---

## 마무리
Garbage Collector는 메모리를 자동으로 관리하지만, 운영체제가 관리하는 파일, 소켓, 데이터베이스 연결 같은 자원은 직접 해제해야 한다.

이를 위해 .NET은 IDisposable 인터페이스와 using 문법을 제공한다.
특히 실무에서는 Dispose 호출을 잊는 것이 다양한 버그와 리소스 누수의 원인이 되므로, IDisposable을 구현한 객체는 가능한 한 using을 통해 사용하는 습관을 들이는 것이 좋다.

다음 글에서는 **얕은 복사(Shallow Copy)와 깊은 복사(Deep Copy)는 무엇이 다를까?**를 알아보며 객체 복사 방식과 메모리 공유에 대해 살펴보겠다.

---

핵심 정리

- GC는 메모리를 관리하지만 운영체제 자원은 관리하지 않는다.
- 파일, 소켓, DB 연결 등은 Dispose()로 직접 해제해야 한다.
- IDisposable은 자원 해제를 위한 인터페이스이다.
- using은 Dispose()를 자동으로 호출해 준다.
- using은 내부적으로 try-finally와 유사하게 동작한다.
- Finalizer는 실행 시점을 보장하지 못하므로 자원 해제 용도로 적합하지 않다.
- IDisposable 객체는 가능한 using으로 사용하는 것이 가장 안전하다.
