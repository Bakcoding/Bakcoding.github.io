---
title:  "델리게이트 #1"
excerpt: "csharp, delegate"

categories:
  - CSharp
tags:
  - [csharp, delegate]

toc: true
toc_sticky: true
 
date: 2022-04-05 
last_modified_at: 2022-04-05
---

***

<br>

### 델리게이트

타입에 값을 담듯이 메서드 자체를 값으로 갖는 타입이다.

```cs
public class Disk
{
  public int Clean(object arg)
  {
    Console.WriteLine("Execute");
    return 0;
  }
}

Disk disk = new Disk();

// 메서드를 인자로 갖는 타입의 인스턴스 생성
[타입] cleanFunc = new [타입](disk.Clean);  
```

이렇게 메서드를 가리킬 수 있는 타입을 C#에서 delegate 구문을 제공하며 델리게이트 타입을 만드는 방법은 일반적인 class 구문이 아닌 delegate 예약어로 표현한다.

```cs
[접근제한자] delegate [메서드의 반환 타입] (매개변수)
```

대상이 될 메서드의 반환 타입 및 매개변수 목록과 일치하는 델리게이트 타입을 정의한다. 

<br>

### 정의 방법

```cs
int Clean (object arg);
```

* 대상 메서드의 반환값과 인자를 분리하고 식별자만 바꾼다.

  ```cs
  // 관례적으로 델리게이트 타입의 이름은 끝에 Delegate 라는 접미사를 붙인다.
  int FuncDelegate(object arg);
  ```

  <br>

* 그 상태에서 delegate 예약어를 추가한다.

  ```cs
  delegate int FuncDelegate(object arg);
  ```

  <br>

이렇게 정의된 FuncDelegate 타입은 int 반환값과 object 인자를 하나 받는 메서드를 가리킬 수 있다. 

```cs
Disk disk = new Disk();
FuncDelegate cleanFunc = new FuncDelegate(disk.Clean);
```

<br>

일반 숫자형 타입처럼 대입할 수 있는 문법을 통해서 new를 사용하지 않고 더 쉽게 사용할 수 있다.

```cs
FuncDelegate cleanFunc = new FuncDelegate(disk.Clean);
FuncDelegate workFunc = disk.Clean();
```

이렇게 선언된 델리게이트는 변수에 저장된 메서드를 가리키고 그 메서드를 호출하는  역할을 한다. 

```cs
Disk disk = new Disk();

FuncDelegate cleanFunc = disk.Clean;

// Clean 메서드를 직접 호출
disk.Clean(null);
// 델리게이트 인스턴스를 통해 Clean 메서드를 호출
cleanFunc(null);
```


인스턴스가 메서드를 호출할 수 있다는 점을 제외하면 델리게이트는 완전한 타입에 속하므로 배열도 만들 수 있고 시그니처가 동일한 메서드라면 인스턴스/정적 유형에 상관없이 모두 가리킬 수 있다. 

<br>

### 사용예시

```cs
using System;

public class Mathematics
{
  delegate int CalcDelegate(int x, int y);

  static int Add(int x, int y) { return x + y; }
  static int Subtract(int x, int y) { return x - y; }
  static int Multiply(int x, int y) { return x * y; }
  static int Divide(int x, int y) { return x / y; }

  CalcDelegate[] methods;

  public Mathematics()
  {
    // static 메서드를 가리키는 델리게이트 배열 초기화
    methods = new CalcDelegate[] { 
      Mathematics.Add, 
      Mathematics.Subtract,
      Mathematics.Multiply,
      Mathematics.Divide
      };
  }

  // methods 배열에 담긴 델리게이트를 opCode 인자에 따라 호출
  public void Calculate(char opCode, int operand1, int operand2)
  {
    switch (opCode)
    {
      case '+':
        Console.WriteLine("+: " + methods[0](operand1, operand2));
        break;

      case '-':
        Console.WirteLine("-: " + methods[1](operand1, operand2));
        break;
      
      case '*':
        Console.WriteLine("*: " + methods[2](operand1, operand2));
        break;
      
      case '/':
        Console.WriteLine("/: " + methods[3](operand1, operand2));
        break;
    }
  }
}

namespace ConsoleApp1
{
  class Program
  {
    // 3개의 매개변수를 받고 void를 반환하는 델리게이트 정의
    // 매개변수의 타입이 중요할 뿐 매개변수의 이름은 임의로 정할 수 있다.
    delegate void WorkDelegate(char arg1, int arg2, int arg3);

    static void Main(string[] args)
    {
      Mathematics math = new Mathematics();
      WorkDelegate work = math.Calculate;

      work('+', 10, 5);
      work('-', 10, 5);
      work('*', 10, 5);
      work('/', 10, 5);
    }
  }
}

// 출력
// +: 15
// -: 5
// *: 50
// /: 2
```

델리게이트가 타입이라는 점으로 다음과 같은 중요한 특징을 가진다.

* 메서드의 반환값으로 델리게이트를 사용할 수 있다.

  메서드의 반환값으로 메서드를 사용할 수 있다.

* 메서드의 인자로 델리게이트를 전달할 수 있다. 

  메서드의 인자로 메서드를 전달할 수 있다.

* 클래스의 멤버로 델리게이트를 정의할 수 있다.

  클래스의 멤버로 메서드를 정의할 수 있다.
