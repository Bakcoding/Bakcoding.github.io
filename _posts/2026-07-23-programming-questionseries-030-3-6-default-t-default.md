---
title: "[궁금시리즈] 3-6. default(T)와 default는 무엇이 다를까?"
excerpt: "C#"
categories:
  - Programming
tags:
  - CSharp
permalink: /programming/3-6-default-t-default/
toc: true
toc_sticky: true
date: 2026-07-23
last_modified_at: 2026-07-23
---

Generic을 사용하다 보면 다음과 같은 코드를 자주 만나게 된다.

```
return default(T);
```

또는 최근 코드에서는

```
return default;
```

처럼 작성하기도 한다.

둘 다 기본값을 의미하는 것처럼 보이는데, 정확히 무엇이 다를까?
그리고 왜 Generic에서는 default(T)가 자주 등장하는 것일까?

이번 글에서는 default 키워드의 의미와 Generic에서 필요한 이유를 알아보자.

---

## 기본값(Default Value)이란?

모든 타입에는 기본값(Default Value)이 존재한다.

예를 들어

```cs
int number = default;
```

는

```cs
int number = 0;
```

과 같다.

반면

```cs
bool value = default;
```

는

```cs
bool value = false;
```

와 같다.

참조 타입이라면

```cs
string text = default;
```

는

```cs
string text = null;
```

과 동일하다.

즉, default는 타입에 맞는 **기본값을 반환하는 키워드**이다.

---

## 타입마다 기본값은 다르다

| 타입 | 기본값 |
| ---- | ----- |
| int | 0 |
| float | 0.0f |
| bool | false |
| char | '\0' |
| enum | 첫 번째 값(0) |
| struct | 모든 필드가 기본값으로 초기화된 상태 |
| class | null |

예를 들어

```cs
struct Player
{
    public int Hp;
    public int Mp;
}
```

```
Player player = default;
```

는 내부적으로

```
Hp = 0
Mp = 0
```

인 구조체가 생성된다.

---

## Generic에서는 왜 필요할까?

다음 메서드를 보자.

```
public T Create<T>()
{
}
```

여기서 값을 하나 반환해야 한다.

하지만 컴파일러는

```
T가 int인지

string인지

Player인지
```

전혀 알지 못한다.

그러므로

```
return 0;
```

도

```
return null;
```

도 사용할 수 없다.

둘 다 일부 타입에서만 올바른 값이기 때문이다.

---

이럴 때 사용하는 것이

```
return default(T);
```

이다.

컴파일러는 실제 자료형이 결정된 후
자동으로 적절한 기본값을 반환한다.

예를 들어

```
Create<int>()
```

이면

```
0
```

을 반환하고,

```cs
Create<string>()
```
 
이면

```cs
null
```

을 반환한다.

---

## default(T)의 동작

다음 코드를 보자.

```cs
public static T GetDefault<T>()
{
    return default(T);
}
```

호출 결과는 다음과 같다.

```cs
Console.WriteLine(GetDefault<int>());

// 출력
0
```

```
Console.WriteLine(GetDefault<bool>());

// 출력
False
```

```
Console.WriteLine(GetDefault<string>() == null);

// 출력
True
```

즉, 컴파일 시점에는 모르던 타입의 기본값을
런타임에 올바르게 선택해 준다.

---

## default(T)와 default의 차이

C# 7.1부터는 다음처럼 작성할 수 있다.

```cs
return default;
```

이전에는

```cs
return default(T);
```

만 사용할 수 있었다.

예를 들어

```cs
public T Create<T>()
{
    return default;
}
```

컴파일러는 반환형이

```
T
```

라는 사실을 이미 알고 있다.

따라서 자동으로

```
default(T)
```

로 해석한다.

즉,

```
default
```

와

```
default(T)
```

는
동일한 값을 의미한다.

차이는 **컴파일러가 타입을 추론할 수 있는가**이다.

---

## 언제 default(T)를 사용해야 할까?

타입을 추론할 수 없는 경우에는 반드시 타입을 명시해야 한다.

예를 들어

```cs
object value = default(int);
```

처럼 사용할 수 있다.

반면

```cs
object value = default;
```

는 컴파일러가 어떤 타입의 기본값인지 알 수 없기 때문에 사용할 수 없다.

즉,

- 타입을 알 수 있으면 default
- 타입을 알 수 없으면 default(T)

를 사용해야 한다.

---

## 실무에서는 어디에서 사용할까?

대표적인 예는 Dictionary 검색이다.

```cs
public T Find<T>()
{
    if (찾지 못했다)
        return default;

    ...
}
```

또는 
Generic Repository, Factory, Cache 등에서도
값이 없을 때 기본값을 반환하는 용도로 자주 사용된다.

---

## default가 항상 안전한 것은 아니다

많은 개발자가

```
return default;
```

를 "빈 값" 정도로 생각한다.

하지만 타입에 따라 의미는 크게 달라진다.

예를 들어

```
default(int)
```

는

```
0
```

이다.

하지만 0이 실제 데이터일 수도 있다.

마찬가지로

```
default(DateTime)
```

는

```
0001-01-01
```

이다.

이 값 역시 유효한 날짜로 사용할 수 있다.

즉, **default는 "데이터가 없다"는 의미를 표현하는 키워드**가 아니라 
"타입의 기본값"을 반환하는 키워드이다.

값의 존재 여부를 표현하려면

- TryGetValue()
- Nullable<T>
- Option 패턴(또는 Result 패턴)

등을 사용하는 것이 더 적절한 경우도 많다.

---

## 실제 .NET에서도 많이 사용된다

예를 들어 Dictionary<TKey, TValue>의 내부 구현이나 다양한 Generic 알고리즘에서는 default가 자주 사용된다.

```
TValue value = default;
```

처럼 초기값을 준비한 뒤, 
검색에 성공하면 실제 값을 대입하고, 실패하면 기본값을 유지하는 방식이다.
이처럼 default는 Generic 코드에서 **타입에 상관없이 초기값을 다룰 수 있게 해주는 핵심 기능**이다.

---

## 마무리
default(T)는 Generic 코드에서 타입에 맞는 기본값을 안전하게 얻기 위해 만들어진 기능이다.
C# 7.1부터는 타입을 추론할 수 있는 경우 default만으로도 같은 의미를 표현할 수 있게 되었지만, 타입을 추론할 수 없는 상황에서는 여전히 default(T)가 필요하다.

중요한 점은 default가 "값이 없다"는 의미가 아니라 **"해당 타입의 기본값"**을 의미한다는 것이다. 이 차이를 이해하면 Generic 메서드와 라이브러리 코드를 훨씬 자연스럽게 읽을 수 있다.

다음 글에서는 **공변성(Covariance)과 반공변성(Contravariance)은 무엇이며, out과 in 키워드는 왜 필요한가?**를 알아보며 Generic의 마지막 핵심 개념을 살펴보겠다.

---

## 핵심 정리

- default는 타입의 기본값을 반환하는 키워드이다.
- 값 타입과 참조 타입의 기본값은 서로 다르다.
- Generic에서는 타입을 모르기 때문에 default(T)가 자주 사용된다.
- C# 7.1부터는 타입을 추론할 수 있으면 default만 사용할 수 있다.
- default는 "값이 없음"이 아니라 "타입의 기본값"을 의미한다.
- Generic 라이브러리와 .NET BCL에서 매우 자주 사용되는 기능이다.
