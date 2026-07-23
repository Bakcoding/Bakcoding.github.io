---
title: "[궁금시리즈] 1-5. string과 String은 무엇이 다를까?"
excerpt: "C#"
categories:
  - Programming
tags:
  - CSharp
permalink: /programming/1-5/
toc: true
toc_sticky: true
date: 2026-07-23
last_modified_at: 2026-07-23
---

C#을 공부하다 보면 다음 두 가지 코드를 모두 볼 수 있다.

```cs
string message = "Hello";
```

그리고

```cs
String message = "Hello";
```

처음 보면 누구나 이런 의문이 든다.

> "둘 중 하나는 잘못된 문법 아닌가?"
> "string이 최신 문법인가?"
> "성능 차이가 있는 걸까?"

결론부터 말하면

> string과 String은 완전히 같은 타입이다.

성능 차이도 없고, 내부적으로도 동일한 객체를 가리킨다.

그렇다면 왜 두 가지 표기법이 존재하는지 알아보자.
 
## string은 키워드이다
먼저 string은 C# 언어가 제공하는 예약어(keyword) 이다.

예를 들어

```cs
int
bool
float
double
string
char
```

모두 C# 키워드이다.

컴파일러는 이러한 키워드를 보면 내부적으로 .NET 타입으로 변환한다.

예를 들어

```cs
string name = "Tom";
```

컴파일러는 이를 다음과 같이 해석한다.

```cs
System.String name = "Tom";
```

즉, string은 System.String의 별칭(alias)이다.
 
## String은 클래스이다
반면

```cs
String
```

은 실제 .NET이 제공하는 클래스이다.

정확한 이름은

```cs
System.String
```

이다.

즉,

```cs
string
↓
System.String
↓
BCL(Base Class Library)에 정의된 클래스
```

라는 관계를 가진다.
 
정말 같은 타입일까?

다음 코드를 보자.

```cs
string text1 = "Hello";
String text2 = "World";
```

둘의 타입을 출력해 보면

```cs
Console.WriteLine(text1.GetType());
Console.WriteLine(text2.GetType());
```

결과는

```cs
System.String
System.String
```

이다.

즉, 두 변수 모두 같은 타입이다.
 
## IL 코드도 동일하다

다음 두 코드는

```cs
string message = "Hello";

String message = "Hello";
```

컴파일 이후 생성되는 IL도 동일하다.

즉, 컴파일러 입장에서는
두 코드의 차이가 전혀 없다.
 
## 다른 기본 타입도 모두 동일하다
문자열만 특별한 것이 아니다.
C#의 기본 타입은 모두 .NET 타입의 별칭이다.

| C# 키워드 | 실제 타입 |
| --------- | -------- |
| bool | System.Boolean |
| byte | System.Byte |
| char | System.Char |
| short | System.Int16 |
| int | System.Int32 |
| long | System.Int64 |
| float | System.Single |
| double | System.Double |
| decimal | System.Decimal |
| object | System.Object |
| string | System.String |

즉,

```cs
int
```

도 사실은

```cs
System.Int32
```

이다.
 
## 그럼 왜 둘 다 만들었을까?
이유는 크게 두 가지이다.

**1. 코드 작성이 편하다.**

매번

```cs
System.Int32
System.Boolean
System.String
```

을 작성하는 것은 불편하다.

그래서 C#은

```cs
int
bool
string
```

같은 짧은 키워드를 제공한다.
 
**2. C/C++ 개발자가 적응하기 쉽다.**

C#은 C 계열 언어의 문법을 많이 계승했다.

따라서

```cs
int
float
bool
```

같은 익숙한 키워드를 유지하는 것이 학습 비용을 줄여준다.
 
## 언제 string을 사용하는 것이 좋을까?

Microsoft의 공식 코딩 스타일에서도

> C# 키워드를 사용하는 것을 권장한다.

즉, 다음처럼 작성하는 것이 일반적이다.

```cs
string name = "Alice";
int age = 20;
bool isAdult = true;
```
 
## 그럼 String은 언제 사용할까?
실제로는 거의 사용하지 않는다.
다만, 정적 메서드를 사용할 때는 종종 볼 수 있다.

예를 들어

```cs
String.IsNullOrEmpty(text);
```

또는

```cs
String.Compare(a, b);
```

물론

```cs
System.String.IsNullOrEmpty(text);
```

도 같은 코드이다.

최근에는

```cs
string.IsNullOrEmpty(text);
```

처럼 사용하는 경우도 많다.

왜냐하면 string도 결국 System.String으로 해석되기 때문이다.
 
## string은 값 타입일까?

많은 초보 개발자가 헷갈리는 부분이다.

```cs
string
```

은 키워드이기 때문에
마치 기본 타입(Value Type)처럼 보인다.

하지만 그렇지 않다.

```cs
string
```

은 참조 타입(Reference Type) 이다.

즉,

```cs
string text = "Hello";
```

는 실제로 Heap에 생성된 System.String 객체를 참조한다.

이에 대해서는 다음 글에서 자세히 다룬다.
 
## string과 String 중 무엇을 사용할까?

대부분의 경우에는

```cs
string
```

을 사용하는 것이 좋다.

그 이유는

- Microsoft 공식 스타일 가이드
- Visual Studio 기본 설정
- 대부분의 오픈소스 프로젝트

모두 string을 기본으로 사용하기 때문이다.

즉, 일관성을 위해서라도 string을 사용하는 것이 좋다.
 
## 마무리
string과 String은 서로 다른 타입이 아니다.
string은 C# 언어가 제공하는 키워드이고, String은 실제 .NET에서 제공하는 System.String 클래스이다.

컴파일러는 string을 만나면 자동으로 System.String으로 변환하기 때문에 성능이나 실행 결과의 차이는 전혀 없다.

다음 글에서는 C# 문자열의 가장 중요한 특징 중 하나인 왜 String은 Immutable(불변 객체)로 설계되었는지 알아보겠다.
 
## 핵심 정리

- string은 C# 키워드이다.
- String은 System.String 클래스이다.
- string은 System.String의 별칭(alias)이다.
- 컴파일 후에는 두 코드가 완전히 동일하다.
- 성능 차이는 전혀 없다.
- 일반적으로는 string 사용을 권장한다.
- string은 기본 타입처럼 보이지만 실제로는 참조 타입이다.
