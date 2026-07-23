---
title: "[궁금시리즈] 1-8. StringBuilder는 왜 등장했을까?"
excerpt: "C#"
categories:
  - Programming
tags:
  - CSharp
permalink: /programming/1-8/
toc: true
toc_sticky: true
date: 2026-07-23
last_modified_at: 2026-07-23
---

앞선 글에서 String은 **Immutable(불변 객체)**이기 때문에 문자열을 수정하는 것이 아니라 **새로운 문자열 객체를 생성한다**고 설명했다.

그렇다면 다음 코드는 어떻게 동작할까?

```cs
string text = "";

for (int i = 0; i < 10000; i++)
{
    text += i;
}
```

겉으로 보기에는 문자열 하나를 계속 이어 붙이는 것처럼 보인다.
하지만 실제로는 **10,000개의 새로운 문자열 객체**가 생성된다.
이처럼 문자열을 자주 수정하는 작업은 성능이 크게 떨어질 수 있다.
이 문제를 해결하기 위해 등장한 것이 바로 **StringBuilder**이다.

---

## String의 문제점

다음 코드를 보자.

```cs
string text = "Hello";

text += " ";
text += "World";
```

겉으로 보기에는 문자열 하나가 수정되는 것처럼 보인다.

하지만 실제로는

```
"Hello"

↓

"Hello "

↓

"Hello World"
```

처럼 새로운 문자열 객체가 계속 생성된다.

즉,

```
Heap

"Hello"

↓

"Hello "

↓

"Hello World"
```

기존 문자열은 버려지고,
새로운 문자열이 계속 생성된다.

이러한 객체들은 나중에 GC가 회수해야 한다.

---

## 문자열을 많이 붙이면 어떻게 될까?

다음 코드를 실행해 보자.

```cs
string result = "";

for (int i = 0; i < 5; i++)
{
    result += i;
}
```

실제 내부에서는

```
""

↓

"0"

↓

"01"

↓

"012"

↓

"0123"

↓

"01234"
```

라는 과정이 발생한다.

즉, 문자열 길이가 길어질수록
매번 기존 문자열 전체를 복사한 뒤
새로운 문자열을 생성한다.

---

## 왜 복사가 필요할까?

String은 Immutable이다.

즉,

```
기존 문자열 수정

❌ 불가능
```

따라서

```cs
text += "A";
```

는 실제로

```cs
text = text + "A";
```

와 동일하다.

그리고

```
기존 문자열 복사

+

새로운 문자열 생성
```

이라는 작업이 수행된다.

문자열이 길수록 복사 비용도 커진다.

---

## StringBuilder의 등장

StringBuilder는 이러한 문제를 해결하기 위해 만들어졌다.

핵심 아이디어는 매우 단순하다.

> 새로운 문자열을 계속 생성하지 말고, 기존 버퍼를 재사용하자.

즉, String처럼 객체를 계속 만드는 것이 아니라
내부 버퍼(Buffer)에 문자열을 추가한다.

---

## StringBuilder는 어떻게 동작할까?

다음 코드를 보자.

```cs
StringBuilder sb = new StringBuilder();

sb.Append("Hello");
sb.Append(" ");
sb.Append("World");
```

내부적으로는

```
Buffer

[ H e l l o _ _ _ _ ]
↓
Buffer

[ H e l l o ' ' _ _ ]
↓
Buffer

[ H e l l o ' ' W o r l d ]
```
처럼 하나의 버퍼를 계속 사용한다.

즉, 새로운 문자열 객체를 계속 생성하지 않는다.

---

## 마지막에만 String을 만든다

StringBuilder는 문자열을 계속 수정하다가 마지막에

```cs
string result = sb.ToString();
```

을 호출하면 비로소 하나의 String 객체를 생성한다.

즉,

```
Append()

↓

Append()

↓

Append()

↓

ToString()

↓

최종 문자열 생성
```

이라는 구조로 동작한다.

---

## Capacity란?

StringBuilder는 내부적으로
문자를 저장할 배열(Buffer)을 가지고 있다.

예를 들어

```cs
StringBuilder sb = new StringBuilder(16);
```

이라면 처음부터
16개의 문자를 저장할 공간을 확보한다.

```
Capacity = 16

[ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ ]
```

문자열을 추가해도 Capacity 안이라면
새로운 메모리를 할당하지 않는다.

---

## Capacity가 부족하면?

버퍼가 가득 차면
더 큰 버퍼를 만든다.

예를 들어

```
16

↓

32

↓

64

↓

128
```

처럼 더 큰 배열을 만들고
기존 내용을 복사한다.

즉, StringBuilder도
메모리 할당이 아예 없는 것은 아니다.

하지만 String처럼 문자열을 추가할 때마다
객체를 생성하는 것과는 비교할 수 없을 정도로 효율적이다.

---

## StringBuilder가 항상 빠를까?

그렇지는 않다.
다음 코드처럼

```cs
string text = "Hello";
```

또는

```cs
string fullName = first + last;
```

처럼 문자열을 한두 번 연결하는 정도라면
StringBuilder를 사용할 필요가 없다.

오히려

```cs
new StringBuilder()
```

를 만드는 비용이 더 클 수도 있다.

---

## 언제 사용하는 것이 좋을까?

다음과 같은 상황이라면 StringBuilder가 적합하다.

- 반복문 안에서 문자열 연결
- 로그 생성
- CSV 생성
- HTML 생성
- JSON 생성
- SQL 문자열 생성

예를 들어

```cs
StringBuilder sb = new StringBuilder();

foreach (var user in users)
{
    sb.AppendLine(user.Name);
}

string result = sb.ToString();
```

이처럼 반복적으로 문자열을 추가하는 작업에서는 StringBuilder가 훨씬 효율적이다.

---

## String과 StringBuilder 비교

| String | StringBuilder | 
| ------ | ------------- |
| Immutable | Mutable |
| 수정 시 새 객체 생성 | 기존 버퍼 재사용|
| 문자열 연결이 많으면 비효율적 | 반복적인 문자열 수정에 적합 |
| GC 부담 증가 | GC 부담 감소 |
| 읽기 전용 문자열에 적합 | 문자열 생성 과정에 적합 |

---

## StringBuilder도 Mutable일까?

그렇다. StringBuilder는

```cs
sb.Append("Hello");
sb.Append(" World");
```

처럼 기존 객체 내부를 직접 수정한다.

즉, String과 달리 **Mutable(가변 객체)**이다.
이것이 StringBuilder가 빠른 이유이다.

---

## 마무리
String은 Immutable이기 때문에 문자열을 수정할 때마다 새로운 객체를 생성한다.
이는 안전성과 메모리 공유 측면에서는 큰 장점이지만, 반복적인 문자열 연결에서는 성능 저하의 원인이 된다.

StringBuilder는 이러한 문제를 해결하기 위해 내부 버퍼를 재사용하는 방식으로 설계되었다.
따라서 문자열을 여러 번 이어 붙이거나 수정해야 하는 상황이라면 String보다 StringBuilder를 사용하는 것이 훨씬 효율적이다.

다음 글에서는 C#에서 자주 헷갈리는 개념 중 하나인 **Boxing과 Unboxing은 왜 발생할까?**를 알아보겠다.

---

## 핵심 정리

- String은 Immutable이므로 수정할 때마다 새로운 문자열 객체를 생성한다.
- 반복적인 문자열 연결은 많은 객체 생성과 GC 부담을 유발한다.
- StringBuilder는 내부 버퍼를 재사용하여 문자열을 관리한다.
- ToString()을 호출할 때 최종 String 객체가 생성된다.
- Capacity를 활용해 메모리 재할당 횟수를 줄일 수 있다.
- 문자열을 반복해서 생성하는 작업에서는 StringBuilder가 훨씬 효율적이다.
- 간단한 문자열 연결에는 StringBuilder보다 String이 더 적합한 경우도 있다.
