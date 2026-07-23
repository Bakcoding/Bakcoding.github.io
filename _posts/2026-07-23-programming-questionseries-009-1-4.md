---
title: "[궁금시리즈] 1-4. var는 동적 타입일까?"
excerpt: "C#"
categories:
  - Programming
tags:
  - CSharp
permalink: /programming/1-4/
toc: true
toc_sticky: true
date: 2026-07-23
last_modified_at: 2026-07-23
---

C#을 배우다 보면 다음과 같은 코드를 자주 보게 된다.

```cs
var number = 10;
```

이를 처음 본 사람들은 흔히 이렇게 생각한다.

> "var는 타입을 안 적었으니까 동적 타입 아닌가?"

실제로 다른 언어(JavaScript, Python 등)에서 경험이 있는 개발자라면 더욱 그렇게 느끼기 쉽다.

하지만 결론부터 말하면,

> var는 동적 타입이 아니다.

var는 컴파일러가 타입을 대신 써주는 문법(Syntax Sugar) 일 뿐이며, C#은 여전히 정적 타이핑 언어이다.

이번 글에서는 var가 실제로 어떻게 동작하는지 알아보자.
 
## var는 타입이 아니다
먼저 가장 중요한 사실부터 알아보자.

많은 사람들이

```cs
var number = 10;
```

을 보고

> var라는 새로운 타입이 존재한다고 생각한다.

하지만 그렇지 않다.

컴파일러는 위 코드를 보면 내부적으로

```cs
int number = 10;
```

으로 해석한다.

즉, var는 타입이 아니라

> 컴파일러에게 타입을 추론해 달라고 요청하는 키워드

이다.
 
## 컴파일러는 어떻게 타입을 알까?
컴파일러는 오른쪽 값을 보고 타입을 추론한다.

예를 들어

```cs
var number = 10;
↓
int number = 10;
```
```cs
var message = "Hello";
↓
string message = "Hello";
```
```cs
var list = new List<string>();
↓
List<string> list = new List<string>();
```

즉, 오른쪽 표현식을 분석하여
컴파일 시점에 타입을 결정한다.
 
## 컴파일이 끝나면 var는 사라진다
이 부분이 가장 중요하다.

컴파일이 끝난 후에는
IL 코드 안에 var라는 개념은 존재하지 않는다.

예를 들어

```cs
var age = 20;
```

컴파일 이후에는

```cs
int age = 20;
```

와 동일한 IL이 생성된다.

즉, 런타임에서는

```
var
```

라는 정보 자체가 존재하지 않는다.
 
## var인데 다른 타입을 넣을 수 있을까?
동적 타입이라면
다음 코드가 가능해야 한다.

```js
let value = 10;
value = "Hello";
```

하지만 C#에서는

```cs
var value = 10;

value = "Hello";
```

컴파일 오류가 발생한다.

```
Cannot implicitly convert type 'string' to 'int'
```

왜냐하면 
첫 번째 줄에서 이미

```cs
int value
```

로 결정되었기 때문이다.

즉, var 역시 타입이 고정된다.
 
## var는 언제 사용할 수 있을까?
컴파일러가 타입을 추론할 수 있어야 한다.

따라서 다음 코드는 가능하다.

```cs
var number = 100;

var text = "Hello";

var person = new Person();
```

반면

```
var value;
```

은 사용할 수 없다.

왜냐하면
오른쪽 값이 없으므로 타입을 추론할 수 없기 때문이다.

또한

```
var value = null;
```

도 사용할 수 없다.

null만으로는 어떤 타입인지 알 수 없기 때문이다.
 
## var를 사용하면 성능이 달라질까?
결론부터 말하면

> 전혀 달라지지 않는다.

예를 들어

```cs
int number = 10;
```

과

```cs
var number = 10;
```

은 컴파일 이후 완전히 동일한 코드가 된다.

즉, 
- 메모리 사용량
- 실행 속도
- JIT 최적화

모두 동일하다.
성능 차이는 0이다.
 
## 그럼 왜 var를 사용할까?
타입 이름이 너무 길어질 수 있기 때문이다.

예를 들어

```cs
Dictionary<string, List<Person>> dictionary =
    new Dictionary<string, List<Person>>();
```

가독성이 좋지 않다.

var를 사용하면

```
var dictionary = new Dictionary<string, List<Person>>();
```

처럼 훨씬 읽기 쉬워진다.

또한 LINQ에서는 거의 필수적으로 사용된다.

```cs
var result = people
    .Where(p => p.Age >= 20)
    .Select(p => p.Name);
```

실제 타입은

```cs
IEnumerable<string>
```

이지만,
굳이 길게 작성할 필요가 없다.
 
## 그렇다고 항상 var를 사용하는 것이 좋을까?
그렇지는 않다.
가독성이 더 중요하다.

예를 들어

```cs
var age = 20;
```

는 괜찮다.

누가 봐도 int라는 것을 알 수 있다.

하지만

```cs
var result = GetData();
```

는 GetData()가 무엇을 반환하는지 알 수 없다.

이런 경우에는

```cs
Customer customer = GetCustomer();
```

처럼 타입을 명시하는 편이 더 읽기 쉽다.

즉, 타입이 명확하면 var를 사용하고, 

> 명확하지 않으면 타입을 직접 작성하는 것이 좋다.

## var와 dynamic는 완전히 다르다

많은 사람들이 가장 헷갈리는 부분이다.

```cs
var value = 10;
```

는 컴파일 시

```cs
int
```

로 결정된다.

반면

```cs
dynamic value = 10;
```

는 타입 검사가 런타임으로 미뤄진다.

즉,

```cs
dynamic value = 10;

value = "Hello";
value = true;
value = new Person();
```

모두 가능하다.
dynamic는 정말 동적 타입처럼 동작한다.
반면 var는 절대 그렇지 않다.
 
## var와 dynamic 비교

| var | dynamic |
| --- | ------- |
| 컴파일 시 타입 결정 | 런타임에 타입 결정 |
| 정적 타이핑 | 동적 타이핑 |
| IntelliSense 지원 | 제한적 |
| 컴파일 오류 발생 | 런타임 오류 가능 |
| 성능 저하 없음 | 런타임 바인딩 비용 발생 |
 
## 마무리
var는 새로운 타입이 아니다.
단지 컴파일러가 오른쪽 값을 보고 타입을 대신 작성해 주는 문법일 뿐이다.
따라서 var를 사용한다고 해서 C#이 동적 타이핑 언어가 되는 것은 아니다.

오히려 var는 정적 타이핑의 장점을 그대로 유지하면서 코드의 가독성을 높여주는 기능이라고 이해하는 것이 맞다.

다음 글에서는 C#에서 자주 볼 수 있는 **string과 String은 무엇이 다른지** 알아보겠다.
 
## 핵심 정리

- var는 타입이 아니라 타입 추론 키워드이다.
- 컴파일러가 오른쪽 값을 보고 타입을 결정한다.
- 컴파일이 끝나면 var는 실제 타입으로 대체된다.
- var를 사용해도 성능 차이는 전혀 없다.
- 타입이 명확한 경우에는 var를 사용하는 것이 가독성에 도움이 된다.
- dynamic는 런타임 타입을 사용하는 것으로 var와 완전히 다른 개념이다.
