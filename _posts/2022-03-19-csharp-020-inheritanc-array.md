---
title:  "Array"
excerpt: "csharp,  Array"

categories:
  - CSharp
tags:
  - [csharp,  Array]

toc: true
toc_sticky: true
 
date: 2022-03-19 
last_modified_at: 2022-03-19
---

### Array

System.Array

모든 배열의 조상이다.

Object가 모든 타입의 조상인 것처럼 소스코드에 정의되는 배열은 모두 Array 타입을 조상으로 둔다. 

```cs
int[] intArray = new int[] { 0, 1, 2, 3, 4, 5 };
```

C# 컴파일러는 자동적으로 int\[\] 타입을 Array 타입으로부터 상속받는 것으로 처리한다. 따라서 배열 인스턴스는 Array 타입이 가지는 모든 특징을 제공한다.

|멤버|타입|설명|
|----|----|----|
|Rank|인스턴스 프로퍼티|배열 인스턴스의 차원(dimension) 수를 반환|
|Length|인스턴스 프로퍼티|배열 인스턴스의 요소(element) 수를 반환|
|Sort|정적 메서드|배열 요소를 값의 순서대로 정렬|
|GetValue|인스턴스 메서드|지정된 인덱스의 배열 요소 값을 반환|
|Copy|정적 메서드|배열의 내용을 다른 배열에 복사|

<br>


