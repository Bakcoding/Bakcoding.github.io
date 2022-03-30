---
title:  "다형성"
excerpt: "csharp, polymorphism, override"

categories:
  - CSharp
tags:
  - [csharp,  polymorphism, override]

toc: true
toc_sticky: true
 
date: 2022-03-27 
last_modified_at: 2022-03-27
---

***

<br>

### 다형성

객체지향의 4가지 특징은 일반적으로 추상화, 캡슐화, 상속, 다형성을 말한다.

그 중 다형성은 여러 가지 형태를 가지는 것을 뜻하며 메서드의 오버라이드와 관련이 있다.

<br>

### 메서드 오버라이드

method override

추상화된 클래스에서 공통적인 특징을 묶어서 메서드를 만들었다고 할 때 

```cs
// 추상화 클래스
public class Animal
{
  public void Move();
}

public class Human : Animal
{

}

public class Dog : Animal
{

}

public class Whale : Animal
{

}
```

동물에서 파생되는 인간, 개, 고래는 모두 움직인다는 공통적인 특징을 가지지만 그 움직임이는 방법이 각각 다르다는 문제가 있다. 

따라서 Move라는 특징을 공유하면서 각각의 자식들에서 행동 방식을 재정의할 필요가 있는데 이 때 사용하는것이 메서드 오버라이드 즉 메서드 재정의이다.

```cs
public class Human : Animal
{
  public void Move()
  {
    Console.WirteLine("Move Two Leg");
  }
  .
  .
  .
}
```

이 때 부모의 클래스에서 사용되는 메서드를 자식에서 동일한 이름으로 정의할 때 두 가지 선택방법이 있다.  

다형성 차원에서 메서드를 재정의해서 사용할것인지 아니면 순수하게 독립적인 하나의 메서드로 이름을 정의하고 싶은지이다.

<br>

#### virtual/override

부모 클래스에서 오버라이드 하고 싶은 메서드를 추상 메서드라는걸 명시하는 virtual 예약어를 붙여서 선언하고 자식에서는 재정의 한다는 override 예약어를 사용한다.

```cs
// 다형성
public class Animal
{
  virtual public void Move() {}
}

public class Human : Animal
{
  public override void Move()
  {
    ~
  }
}
```

<br>

#### new

자식 클래스에서 동일한 이름의 메서드를 선언할 때 앞에 new 예약어를 붙여 독립적인 메서드임을 명시한다.

```cs
// 독립적인 정의
public class Animal
{
  public void Move() {}
}

public class Human : Animal
{
  new public void Move() 
  {
    ~
  }
}
```

<br>

### base 오버라이드

자식 클래스에서 부모 클래스의 메서드에 추가하여 사용하고 싶은 경우도 있다.

만약 부모에서 정의된 내용을 그대로 자식에서 코드를 작성하여 사용한다면 중복된  코드를 사용하게 되는데 이 때 base 예약어를 사용하여 문제를 해결할 수 있다.  

```cs
public class Parent
{
  virtual public void Study() 
  {
    Console.WriteLine("Study C#");
  }
}

// 중복된 코드
public class Child : Parent
{
  override public void Study()
  {
    Console.WriteLine("Study C#");
    Console.WriteLine("Study Unity");
  }
}

// base 오버라이드
public class Child : Parent
{
  override public void Study()
  {
    base.Study();
    Console.WriteLine("Study Unity");
  }
}
```

중요한 점은 상황에 따라 부모 클래스의 원본 메서드 호출이 필요한지 여부가 달라 질 수 있는데 이 때 부모 클래스에서 원본 메서드에 대한 호출 여부를 결정할 수 없기 때문에 오버라이드시 상위 클래스의 도움말에 대한 확인과 기록이 필요하다.

<br>

### object 메서드 확장

object는 모든 클래스의 부모이다. 이 object 클래스에서 정의된 기본 메서드들은 오버라이드를 통해서 파생 클래스에서 각자 용도에 맞게 재정의되어 사용된다.

예)

좌표를 나타내는 클래스를 만들고 X, Y 좌표값을 출력하는 경우

```cs
public class Point
{
  int x, y;

  public Point(int x, int y)
  {
    this.x = x;
    this.y = y;
  }

  public override string ToString()
  {
    return "X : " + x + ", Y : " + y;
  }
}
```

이렇게 재정의하여 사용하게 되면 로그를 남기거나 통합 개발 환경에서 디버깅할 때 ToString에서 반환된 결과를 유용하게 사용할 수 있다.