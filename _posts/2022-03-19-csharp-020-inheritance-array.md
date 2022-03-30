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

***

<br>

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

위 멤버를 이용한 예제

```cs
using System;

namespace ConsoleApp1
{
  class Program
  {
    private static void OutputArrayInfo(Array arr)
    {
      Console.WriteLine("배열의 차원 수 : " + arr.Rank);  // Rank 프로퍼티
      Console.WriteLine("배열의 요소 수 : " + arr.Length);  // Length 프로퍼티
      Console.WriteLine();
    }

    private static void OutputArrayElements(string title, Array arr)
    {
      Console.WriteLine("{" +  title + "}");

      for (int i = 0; i < arr.Length; i++)
      {
        Console.Write(arr.GetValue(i) + ", ");  // GetValue 인스턴스 메서드
      }

      Console.WriteLine();
      Console.WirteLine();
    }
    static void Main(string[] args)
    {
      bool[,] boolArray = new bool[,] {\{true, false\}, \{false, false\}};
      OutputArrayInfo(intArray);

      int[] intArray = new int[] { 5, 4, 3, 2, 1, 0 };
      OutputArrayInfo(intArray);

      OutputArrayElements("원본 intArray", intArray);
      Array.Sort(intArray); // Sort 정적 메서드
      OutputArrayElements("Array.Sort 후 intArray", intArray);

      int[] copyArray = new int[intArray.Length];
      Array.Copy(intArray, copyArray, intArray.Length); // Copy 정적 메서드

      OutputArrayElements("intArray로부터 복사된 copyArray", copyArray);
    }
  }
}

// 출력 결과
// 배열의 차원 수 : 2
// 배열의 요소 수 : 4

// 배열의 차원 수 : 1
// 배열의 요소 수 : 6

// [원본 intArray]
// 5, 4, 3, 2, 1, 0

// [Array.Sort 후 intArray]
// 0, 1, 2, 3, 4, 5

// [intArray로부터 복사된 copyArray]
// 0, 1, 2, 3, 4, 5
```