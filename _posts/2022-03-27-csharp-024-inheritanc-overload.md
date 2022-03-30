---
title:  "오버로드"
excerpt: "csharp, overload"

categories:
  - CSharp
tags:
  - [csharp,  overload]

toc: true
toc_sticky: true
 
date: 2022-03-27 
last_modified_at: 2022-03-27
---

***

<br>

### 메서드 시그니처

method signiture

어떤 메서드를 고유하게 규정할 수 있는 정보를 의미한다. 

메서드의 정의를 분리하면 이름, 반환 타입, 매개변수의 수, 개별 매개변수의 타입으로 나뉘는데 그것들이 바로 메서드의 시그니처가 된다. 즉 메서드가 같다는 것은 메서드 시그니처가 동일하다는 뜻이다.

<br>

### 메서드 오버로드

overload

오버라이드는 시그니처가 완전히 동일한 메서드를 재정의할 때 사용하는 것인 반면 오버로드는 시그니처 중에서 반환값은 무시하고 이름만 같은 메서드가 매개변수의 수, 개별 매개변수 타입만 다르게 재정의되는 경우를 말한다.

생성자를 선언할 때 동일한 이름으로 매개변수만 다르게 해서 다중으로 선언하는것이 가능했는데 이것또한 오버로드인것이다.

<br>

예)

절대값을 구하는 Math 클래스를 만들어볼 때 오버로드가 가능하지 않다면 이 기능을 구현하기 위해서 유사한 메서드를 여러 개 정의해야한다.

```cs
// 매개변수의 타입마다 메서드 작성
class Mathematics
{
  public int AbsInt(int value)
  {
    return (value >= 0) ? value : -value;
  }

  public double AbsDouble(double value)
  {
    return (value >= 0) ? value : -value;
  }

  public decimal AbsDecimal(decimal value)
  {
    return (value >= 0) ? value : -value;
  }
}
```

C#에서는 오버로드가 가능하기 때문에 동일한 이름의 메서드로 일관성 있게 클래스를 작성할 수 있다.

```cs
// 동일한 메서드 이름 사용
class Mathematics
{
  public int Abs(int value)
  {
    return (value >= 0) ? value : -value;
  }

  public double Abs(double value)
  {
    return (value >= 0) ? value : -value;
  }

  public decimal Abs(decimal value)
  {
    return (value >= 0) ? value : -value;
  }
}
```

Math 클래스를 사용하는 입장에서도 Abs라는 메서드 하나를 사용하여 모든 타입에 대응할 수 있는게 편하다.

위 결과를 Console.WriteLine을 사용하여 출력하면 각 타입마다 대응되는 값을 출력하게 되며 Console.WriteLine의 이러한 점도 오버로드의 한 예라고 볼 수 있다.

<br>

### 연산자 오버로드

연산자를 타입별로 재정의하여 사용할 수 있다.

```cs
int n1 = 5;
int n2 = 10;
int sum = n1 + n2;  // 15

string txt1 = "123";
string txt2 = "456";
Console.WriteLine(txt1 + txt2); // 123456
```

위 코드를 통해서 덧셈 연산자가 정수형 타입, 문자열 타입 각각의 다른 역할을 수행하는걸 확인할 수 있다. 정수형에서는 값을 합했다면 문자열에서는 두 문자열을 이어주는 역할을 한다.

string 타입이 덧셈 연산자를 재정의하여 사용하는 것처럼 사용자는 오버로드를 통해서 직접 연산자의 기능을 만들어 낼 수 있다.

예)

두 값을 합하고 원하는 형태로 반환하는 코드를 작성해본다.

```cs
public class Kilogram
{
  double mass;

  public Kilogram(double value)
  {
    this.mass = value;
  }

  public Kilogram Add(Kilogram target)
  {
    return new Kilogram(this.mass + target.mass);
  }

  public override string ToString()
  {
    return mass + "kg";
  }
}

Kilogram kg1 = new Kilogram(5);
Kilogram kg2 = new Kilogram(10);

Kilogram kg3 = kg1.Add(kg2);

Console.WriteLine(kg3); // 결과 15kg
```

이렇게 Add 메서드를 만들고 원하는 결과를 반환하도록 만드는것과 연산자를 오버로드하여 재정의하는 것에 방식에는 큰 차이가 없다.

<br>

**연산자 오버로드**

```cs
public class Kilogram
{
  public static Kilogram operator +(Kilogram op1, Kilogram op2)
  {
    return new Kilogram(op1.mass + op2.mass);
  }
}

Kilogram kg1 = new Kilogram(5);
Kilogram kg2 = new Kilogram(10);

Kilogram kg3 = kg1 + kg2;
```

<br>

Add 메서드와 연산자 오버로드로 새롭게 정의된 + 를 비교해보면 operator 예약어와 + 기호가 메서드의 이름으로 사용되었고 두 변수 kg1 + kg2 를 바로 + 연산하는 식의 직관적인 표현이 가능해졌다. 이 점이 연산자 오버로드의 최대 장점이다.

<br>

C#에는 연산자와 메서드 간의 구분이 없으며 원하는 연산자가 있다면 각 타입의 의미에 맞는 연산으로 새롭게 재정의하면 된다. 

주의할 점은 C#에서 제공되는 모든 연산자가 재정의 가능한것은 아니라는 것이다.

|연산자|오버로드 가능 여부|
|-----|-----------------|
|+, -, !, ~, ++, --, true, false|단항 연산자는 모두 오버로드 가능(+, -는 부호 연산자)|
|+, -, *, /, %, &, \|, ^, <<, >>|이항 연산자는 모두 오버로드 가능(+, -는 사칙 연산자)|
|==, !=, <, >, <=, >=|비교 연산자는 모두 오버로드할 수 있지만 반드시 쌍으로 재정의해야 한다. == 연산자를 오버로드했다면 != 연산자도 해야 한다.|
|&&, \|\||논리 연산자는 오버로드할 수 없다.|
|[ ]|배열 인덱스 연산자는 자체인 대괄호 오버로드는 할 수 없지만 대신 explicitm implicit를 이용한 대체 정의가 가능하다.|
|(Type)x|형변환 연산자 자체인 괄호는 오버로드할 수 없지만 대입이 아닌 +, -, *, / 등의 연산자를 오버로드하면 복합 대입 연산 구문이 지원된다.|
|기타 연산자|오버로드할 수 없다.|

<br>

연산자에서 단항이란 피연산자가 하나라는 의미이고, 이항이란 피연산자가 두 개라는 의미이다. 

```cs
a = -2; // 단항
b = 1 - 2;  // 이항
```

