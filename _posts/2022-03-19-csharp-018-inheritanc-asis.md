---
title:  "as / is"
excerpt: "csharp,  as, is"

categories:
  - CSharp
tags:
  - [csharp,  as, is]

toc: true
toc_sticky: true
 
date: 2022-03-19 
last_modified_at: 2022-03-19
---

***

<br>

### as

클래스를 캐스팅 연산자를 통해 형변환을 하면 오류가 발생한다. 이 문제를 해결하기 위해 as 연산자가 추가되었다.

```cs
Parent parent = new Parent();
Child child = parent as Child;
```

as는 형변환이 가능하면 지정된 타입의 인스턴스 값을 반환하고 불가능하면 null을 반환한다.

다만 as 연산자는 참조형 변수에만 적용이 가능하며 참조형 타입으로의 체크만 가능하다. 따라서 다음과 같은 경우 오류가 발생한다.

```cs
int n = 10;
if ((n as string) != null)  // 컴파일 오류 발생
{
  ~
}
```

<br>

### is

as가 형변환 결과값을 반환한다면 is 형변환 가능성 여부를 결과값(bool)로 반환한다.

즉 as 와 is 의 사용 기준이 명확하다.

* as : 형변환된 인스턴스가 필요할 때

* is : 인스턴스는 필요없고 가능성 여부만 필요할 때

그리고 as와 달리 is는 값 형식에도 사용이 가능하다. 다만 int 타입의 string으로 변환 같은 경우 is로 확인할 때는 오류는 아니지만 경고는 발생한다.

위 코드는 is를 사용하는게 적절한 경우이다.

```cs
if (n is string) {  ~ }
```

