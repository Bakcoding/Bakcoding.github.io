---
title:  "정적멤버"
excerpt: "csharp, class, static"

categories:
  - CSharp
tags:
  - [csharp, class, static]

toc: true
toc_sticky: true
 
date: 2022-02-25 
last_modified_at: 2022-02-25
---

### 정적멤버

개별 인스턴스 수준이 아닌 인스턴스 타입 전체에 걸쳐 전역적으로 적용되는 필드, 메서드, 생성자를 말한다.  

예약어 static을 사용하며 new로 할당된 인스턴스와 상관없이 존재한다.  

<br>

### 싱글턴

정적 필드를 사용하는 전형적인 패턴 가운데 대표적으로 한 가지인 패턴이다.  

싱글턴 패턴은 특정 클래스의 인스턴스를 의도적으로 한 개만 만들고 싶을 때 사용한다.  

외부에서 인스턴스를 만들지 못하도록 생성자를 private로 명시하고 클래스 내부에서 인스턴스를 미리 생성해 두는 방식이다.  


```cs
using System;

namespace Bakcoding
{
    class Singleton
    {
        static public Singleton Onlyone = new Singleton("Only One");
        string name;

        private Singleton(string _name)
        {
            name = _name;
        }

        public void PrintName()
        {
            Console.WriteLine(name);
        }
    }
}
```

이렇게 정의해 두면 외부에서는 new 연산자를 사용해서 객체를 만들 수 없지만 이미 내부에서 정적 필드로 인스턴스를 생성했기 때문에 Singleton.Onlyone과 같은 방법으로 해당 객체를 사용할 수 있게된다. 

싱글턴 패턴은 일반적으로 단일 시스템 자원을 책임지는 타입이 필요할 때 사용된다.

<br>

### 정적 메서드

일반 메서드에 static 예약어를 붙여서 정의한다.  

정적 메서드의 특징은 메서드 내부에서 인스턴스 멤버에 접근할 수 없다는 점이다.  

이때까지 문자나 값을 출력할 때 사용해왔던 함수를 생각해본다.  

```cs
Console.WriteLine();
```

이제는 이 함수가 Console 클래스의 정적 메서드 WriteLine()에 인자를 전달해 사용했다는걸 알 수 있다.  


<br>

### 정적 생성자

기본 생성자에 static 예약어를 붙인 경우이다.

클래스에 단 하나만 존재할 수 있고 주로 정적 멤버를 초기화하는 기능을 하기 때문에 형식 이니셜라이저(type initializer)라고도 한다. 

정적 생성자는 매개변수를 포함할 수 없고 단 한개만 정의할 수 있을 뿐만 아니라 정적 생성자의 실행이 실패하게 되면 해당 클래스 자체를 사용할 수 없으며 오류의 원인을 찾는 것 또한 쉽지않기 때문에 사용시 오류에 더욱 유의해야한다. 

```cs
using System;

namespace Bakcoding
{
    class Singleton
    {
        static public Singleton Onlyone;

        static Singleton()
        {
            Onlyone = new Singleton("Only One");
        }
    }
}
```

만약 정적 필드에 초기화 코드도 포함되어 있고 동시에 정적 생성자도 정의했다면 C# 컴파일러는 사용자가 정의한 정적 생성자의 코드와 초기화 코드를 자동으로 병합해서 정의한다.  

정적 맴버를 처음 호출할 경우나 인스턴스 생성자를 통해 객체를 만들어지는 시점이 되면 그 어떤 코드보다도 우선적으로 실행된다. 

```cs
using System;

namespace CSharp_Project
{ 
    class Person
    {
        public string name;
        public Person(string _name)
        {
            name = _name;
            Console.WriteLine("Constructor Call");
        }
        static Person()
        {
            Console.WriteLine("static Constructor Call");
        }
    }

    class Program
    {
        static void Main(string [] args)
        {
            Person person1 = new Person("");
            Console.WriteLine("\n");
            Person person2 = new Person("");
        }
    }
}

// 출력
//static Constructor Call
//Constructor Call
//
//Constructor Call
```