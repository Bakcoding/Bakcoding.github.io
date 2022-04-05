---
title:  "델리게이트 #3"
excerpt: "csharp, delegate, call-back"

categories:
  - CSharp
tags:
  - [csharp, delegate, call-back]

toc: true
toc_sticky: true
 
date: 2022-04-05 
last_modified_at: 2022-04-05
---

***

<br>

### 콜백 메서드

메서드를 사용하는 전형적인 패턴 중 하나이다. 콜백 메서드를 이해하기 위해서는 호출자(caller)와 피호출자(callee) 관계를 알아야한다.

사용자가 만든 Source 타입에서 Target 타입 내에 정의된 메서드를 호출할 때 Source가 호출자가 되고, 피호출자는 Target이 된다.

즉 콜백이란 역으로 피호출자의 메서드를 호출하는 것을 의미하고 호출자 측의 메서드를 콜백 메서드라고 한다.


```cs
class Target
{
  public void Do(Source obj)
  {
    Console.WriteLine(obj.GetResult());
  }
}

class Source
{
  public int GetResult()
  {
    return 10;
  }

  public void Test()
  {
    Target target = new Target();
    target.Do(this);
  }
}
```

여기서 target.Do 에서 호출이 Source 타입 호출자이고 Target 타입이 피호출자가 된다. 하지만 피호출자가 정의한 Do 메서드 내부에서 다시 호출자의 타입에 정의된 메서드를 호출하고 있다. 이 Do 메서드 내부에서 obj.GetResult 호출을 콜백이라 하고 Source 타입의 GetResult 멤버가 콜백 메서드가 된다. 

<br>

### 델리게이트 콜백

콜백은 메서드를 호출하는 것이기 때문에 실제로 필요한 것은 타입이 아니라 하나의 메서드이다. 따라서 이 타입 자체를 전달해서 실수를 유발할 여지를 남기기보다 메서드에 대한 델리게이트만 전달해서 이 문제를 해결할 수 있다.

```cs
// int를 반환하고 매개변수가 없는 델리게이트 타입을 정의
delegate int GetResultDelegate();

class Target
{
  public void Do(GetResultDelegate getResult)
  {
    // 콜백 메서드 호출
    Console.WriteLine(getResult());
  }
}

class Source
{
  // 콜백 용도로 전달될 메서드
  public int GetResult()
  {
    return 10;
  }

  public void Test()
  {
    Target target = new Target();
    target.Do(new GetResultDelegate(this.GetResult));
  }
}
```

>피호출자가 호출하게 될 메서드가 꼭 호출자 내부에 정의된 메서드로 한정되지 않고 다른 타입에 정의된 메서드를 피호출자에 전달해서 호출되는 식의 역 호출도 보통 콜백이라 한다.

위 콜백 패턴에서 Target 타입의 Do 메서드를 호출하면서 콜백 메서드를 전달하고 이로 인해 Do 메서드는 내부의 동작에 콜백 메서드를 반영하게 된다. 이것은 이미 정의되어 있는 메서드 내의 특정 코드 영역을 콜백 메서드에 정의된 코드로 치환하는 것과 같은 역할을 한다.

<br>

**코드 치환 예시**

```cs
using System;

namespace ConsoleApp1
{
  // 배열을 정렬할 수 있는 기능을 가진 타입 정의
  class SortObject
  {
    int [] numbers;

    // 배열을 생성자의 인자로 받아서 보관
    public SortObject(int[] numbers)
    {
      this.numbers = numbers;
    }

    // numbers 배열의 요소를 크기순으로 정렬
    public void Sort()
    {
      int temp;

      for (int i = 0; i < numbers.Length; i++)
      {
        int lowPos = i;

        for (int j = i + 1; j < numbers.Length; j++)
        {
          if (numbers[j] < numbers[lowPos])
          {
            lowPos = j;
          }
        }

        temp = numbers[lowPos];
        numbers[lowPos] = numbers[i];
        numbers[i] = temp;
      }
    }

    // numbers 요소를 화면에 출력
    public void Display()
    {
      for (int i = 0; i < numbers.Length; i++)
      {
        Console.WriteLine(numbers[i] + ", ");
      }
    }

    class Program
    {
      static void Main(string[] args)
      {
        intp[] intArray = new int[] { 5, 2, 3, 1, 0, 4 };

        SortObject so = new SortObject(intArray);
        so.Sort();
        so.Display();
      }
    }
  }
}

// 출력
// 0, 1, 2, 3, 4, 5
```

SortObject 클래스는 Sort 단 하나의 메서드를 제공해서 int 형 배열을 크기순으로 정렬한다. 여기서 배열을 내림차순으로 정렬하고 싶다면 for 문 내의 비교 연산자 하나만 수정하면 된다.

```cs
public void Sort()
{
  // '<' 연산자를 '>'로 변경
  if (numbers[j] > numbers[lowPos])
  {
    lowPos = j;
  }
}
```

오름차순과 내림차순을 SortObject에서 함께 구현해야 한다면 각각을 구현하는 두 개의 Sort 메서드를 만들 필요 없이 bool 매개변수를 추가해 선택하게 만든다.

```cs
public void Sort(bool ascending)
{
  // 오름차순
  if (ascending == true)
  {
    if (numbers[j] < numbers[lowPos])
    {
      lowPos = j;
    }
  }
  // 내림차순
  else 
  {
    if (numbers[j] > numbers[lowPos])
    {
      lowPos = j;
    }
  }
}
```

여기서 외부에서 비교하는 코드를 선택할 수 있도록 델리게이트로 만든다.

```cs
public delegate bool CompareDelegate(int arg1, int arg2);

public void Sort(CompareDelegate compareMethod)
{
  if (compareMethod(numbers[j], numbers[lowPos])
  {
    lowPos = j;
  }
}
```

이 코드를 정리하면 다음과 같다.

```cs
static void Main(string[] args)
{
  int[] intArray = new int[] { 5, 2, 3, 1, 0, 4 };

  SortObject so = new SortObject(intArray);
  // 오름차순 정렬을 할 수 있는 메서드 전달
  so.Sort(AscendingCompare);
  so.Display();

  Console.WriteLine();

  // 내림차순 정렬을 할 수 있는 메서드 전달
  so.Sort(DescendingCompare);
  so.Display();
}

public static bool AscendingCompare(int arg1, int arg2)
{
  return (arg1 < arg2);
}

public static bool DescendingCompare(int arg1, int arg2)
{
  return (arg1 > arg2);
}

// 출력
// 0, 1, 2, 3, 4, 5
// 5, 4, 3, 2, 1, 0
```