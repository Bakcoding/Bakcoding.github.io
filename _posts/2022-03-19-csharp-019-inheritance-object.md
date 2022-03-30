---
title:  "Oject"
excerpt: "csharp,  Oject"

categories:
  - CSharp
tags:
  - [csharp,  Oject]

toc: true
toc_sticky: true
 
date: 2022-03-19 
last_modified_at: 2022-03-19
---

***

<br>

### Oject

System.Object 는 모든 타입의 조상이다.

클래스를 정의할 때 따로 부모에 대한 명시가 없다면 C# 컴파일러는 Object 타입에서 상속받는다고 가정 후 자동으로 코드를 생성한다.

```cs
public class Parent {

}

// 컴파일시

public class Parent : Object {

}
```

결국 사용자가 부모 클래스를 만들어도 그 부모 역시 따로 상속을 명시하지 않았다면 Object를 상속 받기 때문에 Object가 모든 클래스의 부모가 된다.

```cs
Parent parent1 = new Parent();
Object object = parent;
Parent parent2 = object as Parent;
```

<br>

### Value, Reference

Object는 그 자체가 참조형(class) 임에도 값 형식의 부모이기도 하다.

참조 타입과 값 타입의 처리방식에는 차이가 있는데 .Net 프레임워크에서는 모든 값 형식을 System.ValueType을 상속받게 하는데 이 역시 Object를 상속 받는다.

즉 값 형식은 System.ValueType으로 상속받은 모든 타입을 의미하고 참조 형식은 Object로부터 상속받은 타입 중 System.ValueType 하위 타입을 제외한 모든 타입을 의미한다.

![object](/assets/images/20220319_Posting/object.png)

<br>

이렇게만 보면 object는 특별해 보이지만 단순한 하나의 클래스일 뿐이다.

```cs
public class Objcet
{
  public virtual bool Equals(object obj);
  public virtual int GetHashCode();
  public Type GetType();
  public virtual string ToString();
}
```

즉 C#에서 정의된 예약어로 실체는 System namespace에 정의된 Object 클래스로 존재한다.

<br>

Object 클래스의 메서드를 살펴본다.

#### ToString

인스턴스가 속한 클래스의 전체 이름을 반환한다. 

```cs
using System;

namespace ConsoleApp
{
  class Program
  {
    static void Main(string[] args)
    {
      Program program = new Program();
      Console.WriteLine(program.ToString());
    }
  }
}
// 결과
// ConsoleApp.Program
```

그러나 이 메서드는 상속받은 자식 클래스에서 오버라이드가 가능하기 때문에 클래스마다 다른 반환 결과를 낸다.

C#에서 제공되는 기본 타입들은 모두 오버라이드를 통해서 클래스 전체 이름이 아닌 타입이 담고 있는 값을 반환 하도록 재정의 되어있다.

```cs
int n = 10;
n.ToString();
// 결과
// 10 -> 문자열이다. 
```

<br>

#### GetType

클래스 또한 속성으로 클래스의 이름을 담고 있으며 필드, 메서드, 프로퍼티와 같은 멤버를 담고 있는 또 다른 타입으로 볼 수 있다.

C#에서는 개발자가 class로 타입을 정의하면 내부적으로 해당 class 타입의 정보를 가지고 있는 System.Type의 인스턴스를 보유하게되고 그 인스턴스를 가져올 수 있는 방법으로 GetType 메서드를 통해 제공된다.

```cs
Parent parent = new Parent();
Type type = parent.GetType();

Console.WriteLine(type.FullName); // Parent
Console.WriteLine(type.IsClass);  // True
Console.WriteLine(type.IsArray);  // False
```

ToString이 값을 문자열로 반환한다면 GetType을 통해서 전체 이름을 반환하는 방법이 있다.

```cs
int n = 10;
Type intType = n.GetType();
Console.WriteLine(intType.FullName);  // System.Int32 
```

<br>

**typeof**

GetType이 클래스의 인스턴스로부터 Type을 구하는 반면 typeof를 사용하면 클래스에서 곧바로 Type을 구할 수 있다.

```cs
Type type = typeof(double);
Console.WriteLine(type.FullName); // System.Double
Console.WriteLine(typeof(System.Int16).FullName); // System.Int16
```

<br>

#### Equals

Equals 메서드는 값을 비교한 결과를 bool로 반환한다.

```cs
int n = 5;
Console.WriteLine(n.Equals(5)); // True
```

이 메서드는 값 타입과 참조 타입에서 차이가 있다.

비교 대상이 값 형식일 때는 인스턴스가 소유하고 있는 값을 대상으로 비교한다.

참조 형식에 대해서는 할당된 메모리 위치를 가리키는 식별자의 값이 같은지 비교한다.


**Value**

```cs
int n1 = 5;
int n2 = 5;
Console.WriteLine(n1.Equals(n2)); // True

n2 = 6;
Console.WriteLine(n1.Equals(n2)); // False
```

값 형식의 Equals는 값 자체를 비교하기 때문에 값이 변경되고 나서는 False를 반환한다.

<br>

**Reference**

```cs
class Person
{
  int age
  public Person(int _age)
  {
    age = _age;
  }
}

Person person1 = new Person(19);
Person person2 = new Person(19);
person1.Equals(person2);  // false
```

동일한 값을 소유하고 있지만 false를 반환하는 이유는 참조 형식의 비교는 힙에 할당한 데이터 주소를 가리키고 있는 스택 변수의 값을 비교하기 때문이다.

따라서 참조 형식에 대한 Equals 메서드는 하위 클래스에서 재정의하여 사용한다.

대표적으로 string을 보면

```cs
string txt1 = new string(new char[]{'H', 'E', 'L', 'L', 'O'});
string txt2 = new string(new char[]{'H', 'E', 'L', 'L', 'O'});

txt1.Equals(txt2);

// true
```

string이 참조형식이지만 동일한 값을 가지고 있기 때문에 true를 반환하게 된다.

<br>

#### GetHashCode

(Hash Code는 고유한 값이다.)

특정 인스턴스를 고유하게 식별할 수 있는 4바이트 int 값을 반환하는 메서드이다.

중요한 점은 Equals 메서드와 연계되는 특성이 있다.

* Equals 반환값이 True인 객체는 서로 같다. 따라서 객체들을 식별하는 고유값 또한 같아야한다.

따라서 보통 Equals를 재정의하면 GetHashCode 또한 재정의한다.

```cs
// Value
int n1 = 10;
int n2 = 10;
// 출력 결과 동일
Console.WriteLine(n1.GetHashCode()); 
Console.WriteLine(n2.GetHashCode());

// Reference
Person person1 = new Person(19);
Person person2 = new Person(19);
// 출력 결과 다름
Console.WriteLine(person1.GetHashCode());
Console.WriteLine(person2.GetHashCode());
```

반환값이 -2,147,483,648 ~ 2,147,483,647 즉 int 의 범위와 동일하기 때문에 GetHashCode와 값 자체를 1 : 1 매핑할 수 있으며 실제로 .Net은 int에 대한 GetHashCode를 재정의해 그 값을 그대로 반환한다.

객체의 대표값이 2<sup>32</sup>를 넘으면 안된다는 제한 때문에 long 같은 경우 범위가 2<sup>64</sup> 라서 어떤 경우에는 값이 다른데 동일한 해시코드가 반환될 수 있다.

이렇게 발생하는 문제를 해시충돌(Hash Collision)이라고 한다.

따라서 이런 경우 Equals를 호출해서 객체가 동일한지 판단한다.