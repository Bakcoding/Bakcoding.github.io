---
title:  "클래스 확장"
excerpt: "csharp, class"

categories:
  - CSharp
tags:
  - [csharp, class]

toc: true
toc_sticky: true
 
date: 2022-04-04 
last_modified_at: 2022-04-04
---

***

<br>

### 중첩 클래스

nested class

클래스 내부에 또 다른 클래스를 정의하는 것을 말한다.

```cs
class OuterClass
{
  class NestedClass
  {

  }
}
```

객체의 생성과 메서드의 호출 방법도 보통의 클래스와 다르지 않다.

일반적인 클래스와 차이점은 자신이 소속되어 있는 클래스의 멤버에 자유롭게 접근이 가능하다는 점이다.

```cs
class OuterClass
{
  private int OuterMember;

  class NestedClass
  {
    public void DoSomething()
    {
      OuterClass outer = new OuterClass();
      outer.OuterMember = 10;
    }
  }
}
```

private 로 선언된 멤버라도 내부 클래스에서는 접근이 가능하다.

주로 클래스 내부에서 외부에 공개하고 싶지 않은 형식을 만들거나 현재 클래스의 일부분처럼 표현할 수 있는 클래스를 만들기위해서 사용한다.

<br>

### 추상 클래스

일반적으로 메서드 오버라이드에서 virtual 키워드를 사용하여 부모 클래스에서 메서드를 정의하고 자식 클래스에서는 override를 사용해 그 기능을 재정의한다.  

이렇게 정의된 클래스는 부모와 자식 모두 new를 통해서 인스턴스를 생성하는것이 가능하다. 

여기서 부모 클래스에서 인스턴스를 생성하지 못하게 하면서 자식들이 반드시 재정의하도록 강제하고 싶은 경우 필요한게 추상 클래스와 추상 메서드이다.

추상 메서드는 abstract 예약어로 선언되고 구현된 코드가 없는 메서드를 말하며 일반 클래스에 존재할 수 없고 반드시 추상 클래스 안에서만 선언이 가능하다.

따라서 추상 메서드는 무조건 자식에서 정의되어야하기 때문에 private 접근 제한자로 지정할 수 없다.

즉 추상 메서드(abstract method)는 코드가 구현되지 않는 가상 메서드(virtual method)라 볼 수 있다.

<br>

* 추상 클래스는 new를 사용해 인스턴스를 만들 수 없다.

* 추상 메서드를 가질 수 있으며 이는 자식에서 반드시 재정의하여 사용되어야한다.

<br>

예)

```cs
class Point
{
  int x, y;

  public Point(int x, int y)
  {
    this.x = x; this.y = y;
  }

  public override string ToString()
  {
    return "X : " + x + ", Y: " +y;
  }
}

abstract class DrawingObject
{
  public abstract void Draw();
  public void Move() 
  {
    Console.WriteLine("Move");
  }
}

class Line : DrawingObject
{
  Point pt1, pt2;
  public Line(Point pt1, Point pt2)
  {
    this.pt1 = pt1;
    this.pt2 = pt2;
  }

  public override void Draw()
  {
    Console.WriteLine("Line " 
    + pt1.ToString() 
    + " ~ " 
    + pt2.ToString());
  }
}

DrawingObject line = new Line(new Point(10, 10), new Point(20, 20));
line.Draw();
```

추상 클래스는 자식에서 재정의되지 않으면 컴파일 오류가 발생하기 때문에 재정의를 강제하고 싶을 때 유용하게 사용할 수 있다.

