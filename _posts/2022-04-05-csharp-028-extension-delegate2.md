---
title:  "델리게이트 #2"
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

### 델리게이트의 실체

delegate 예약어가 메서드를 가리킬 수 있는 내부 닷넷 타입에 대한 간편 표기법이라는 점으로 타입과 같이 사용할 수 있다.

그 내부 타입의 이름은 MulticastDelegate 이다.

>System.MulticastDelegate 타입은 System.Delegate 타입을 상속받고 그것은 다시 System.Object를 상속받는다.

따라서 delegate 예약어 없이 정의를 한다면 다음과 같이 작성해야한다.

```cs
class WorkDelegate : System.MulticastDelegate
{
  public WorkDelegate(object obj, IntPtr method);
  public virtual void Invoke(char arg1, int arg2, int arg3);
}
```

하지만 MulticastDelegate 를 직접 상속하는 것은 불가능하기 때문에 실제로 컴파일은 되지 않는다.

또한 인스턴스 생성 및 호출까지도 C# 컴파일러의 개입이 없다면 다음과 같이 작성해야한다.

```cs
Mathematics math = new Mathematics();
WorkDelegate func = new WorkDelegate(math, math.Calculate);
func.Invoke('+', 10, 5);
```

즉 delegate 예약어가 있기 때문에 MulticastDelegate 타입의 존재를 모른 채 메서드를 가리키는 타입을 더 쉽게 사용할 수 있다.

<br>

### 델리게이트 응용

여러 개의 메서드를 한번에 가리키는 것도 가능하며 한 번의 함수 호출로 모두 호출하는것도 가능하다.

```cs
using System;
namespace ConsoleApp1
{
  class Program
  {
    delegate void CalcDelegate(int x, int y);

    static void Add(int x, int y) { Console.WrtieLine(x + y); }
    static void Subtract(int x, int y) { Console.WriteLine(x - y); }
    static void Multiply(int x, int y) { Console.WriteLine(x * y); }
    static void Divide(int x, int y) { Console.WriteLine(x / y); }

    static void Main(string[] args)
    {
      CalcDelegate calc = Add;
      calc += Subtract;
      calc += Multiply;
      calc += Divide;

      calc(10, 5);
    }
  }
}

// 출력
// 15
// 5
// 50
// 2
```

델리게이트는 += 연산자를 사용해서 인스턴스에 추가할 수 있다.

이 코드는 컴파일러가 자동으로 다음과 같이 바꾸어준다.

```cs
CalcDelegate calc = new CalcDelegate(Add);
CalcDelegate subtract = new CalcDelegate(Subtract);
CalcDelegate multiplyCalc = new CalcDelegate(Multiply);
CalcDelegate divideCalc = new CalcDelegate(Divide);

calc = CalcDelegate.Combine(calc, subtractCalc) as CalcDelegate;
calc = CalcDelegate.Combine(calc, multiplayCalc) as CalcDelegate;
calc = CalcDelegate.Combine(calc, divideCalc) as CalcDelegate;
```

+= 를 통해서 추가가 가능하며 -= 를 사용해서 제거 또한 가능하다.

```cs
static void Main(string[] args)
{
  CalcDelegate calc = Add;
  calc += Subtract;
  calc += Multiply;
  calc += Divide;

  // Add, Subtract, Multiply, Divide 메서드 모두 호출
  calc(10, 5);

  // 목록에서 Multiply 메서드를 제거
  calc -= Multiply;

  // Add, Subtract, Divide 메서드만 호출
  calc(10, 5);
}
```

<br>