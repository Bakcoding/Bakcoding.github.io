---
title:  "상속"
excerpt: "csharp,  inheritance"

categories:
  - CSharp
tags:
  - [csharp, inheritance]

toc: true
toc_sticky: true
 
date: 2022-03-19 
last_modified_at: 2023-06-05
---

***

<br>

### 상속

inheritance

상속은 공통되는 특성을 가지는 class를 하나 만들고 확장해서 사용하는것이라 볼 수 있다.

```cs
using System;

public class Person {
  public int age;
  public float height;
  public float weight;

  public void Eat(){}
  public void Sleep(){}
  public void Die(){}
}

public class Bak : Person {
  private void Study(){}
}

class Program
{
    static void Main(string[] args)
    {
      Bak bak = new Bak();
      bak.age = 15;
      Console.WriteLine($"Age : {bak.age}");
    }
}
```

C#에서는 부모를 여러개 가질 수 없는 단일 상속(Single Inheritance)만 허용하고 있다.

이렇게 상속으로 연결된 관계에서 상위 클래스를 부모, base, super 등 하위 클래스를 자식, derived, sub 으로 부른다.

Bak 클래스안에는 아무것도 작성되지 않았지만 Person을 상속했기 때문에 Person이 가지는 특성을 그대로 사용할 수 있을 뿐만 아니라 자식에서만 필요한 것을 추가로 작성해서 사용할 수 있다.

중요한 점은 상속을 통해서 만들어진 자식 클래스라도 부모에서 private로 선언되었다면 접근할 수 없다. 여기서 자식은 사용하면서 다른 외부 클래스에서 사용을 막고 싶을 때 사용하는 접근 제한자가 protected이다.

그리고 아예 상속 자체가 안되도록 클래스를 만들고 싶을 때는 sealed 예약어를 사용해서 클래스를 선언하면 된다.

<br>

### 형변환

casting

형변환에 대해서 설명하기전에 우선 자료형의 관계를 살펴본다.  

**자료형의 관계**

![casting](/assets/images/posting/20220319/casting.png)

<br>

int, short는 정수 안에 포함되며 그 안에서 short는 int안에 포함된다. 이 분류에서 상대적으로 포괄적인 것을 일반화 타입 세부적인 것을 특수화 타입이라고 한다.

따라서 정수와 int는 일반화-특수화, int와 short 일반화-특수화라고 할 수 있다.

<br>

형변환은 크게 두가지로 나뉜다.

* 암시적 형변환 

  특수화 타입 변수 -> 일반화 타입 변수 값 대입될 때

  ```cs
  short a = 10;
  int b = a;  // 암시적 변환
  ```

* 명시적 형변환

  일반화 타입 변수 -> 특수화 타입 변수 값 대입될 때 

  ```cs
  int c = 10;
  short d = (short) c;  // 명시적 변환
  ```

  여기서 (short)를 캐스팅 연산자라고 한다.

<br>



이 규칙은 class로 정의된 부모-자식 클래스 관계에서도 동일하게 적용된다.

### 클래스 형변환

클래스에서 형변환을 적용해보면 부모 클래스가 일반화 타입, 자식 클래스가 특수화 타입이라 볼 수 있다.


```cs
// 암시적
Child child = new Child();
Parent parent = child;

// 명시적
Parent parent = new Parent();
Child child = (Child) parent;
```

여기서 명시적 형변환의 경우 컴파일 단계에서는 문제가 없지만 프로그램을 실행시키면 에러가 발생한다.

그 이유는 자식 클래스에서 추가로 작성된 것은 부모 클래스에서는 정의되지 않았기 때문에 당연하게도 문제가 발생하게 된다.  

그럼에도 컴파일 단계에서 오류를 잡지 않는 이유는 의도적으로 활용하기도 하기 때문이다.

```cs
Child ch1 = new Child();
Parent p = ch1  // 부모 타입으로 암시적 형변환
Child ch2 = (Child) ch1;  // 다시 본래 타입으로 명시적 형변환
```

위 코드는 방식을 보여주는 예이다.

예)

```cs
public class Parent
{
  public Method(Parent p) {}
}

class Child : Parent
{
}

class Program
{
    static void Main(string[] args)
    {
      Child ch1 = new Child();
      Child ch2 = new Child();
      CHild ch3 = new Child();
      
      Parent parent = new Parent();
      parent.Method(ch1);
      parent.Method(ch2);
      parent.Method(ch3);
    }
}
```

매개변수가 Parent인 Parent 클래스의 Method 메서드는 Parent를 상속받은 Child의 인스턴스를 인자로 호출이 가능하다.

<br>

예)

```cs
Parent[] parentArr = new Parent[] {new Child1(), new Child2(), new Child3()};

Parent parent = new Parent();
foreach (Parent p in parentArr)
{
  parent.Method(p);
}
```

Parent를 상속받은 Child1, Child2, Child3은 Parent 배열의 요소로 할당될 수 있다.