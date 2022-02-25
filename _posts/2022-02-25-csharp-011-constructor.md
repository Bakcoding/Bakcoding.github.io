---
title:  "생성자"
excerpt: "csharp, class, constructor"

categories:
  - CSharp
tags:
  - [csharp, class, constructor]

toc: true
toc_sticky: true
 
date: 2022-02-25 
last_modified_at: 2022-02-25
---

### 생성자

constructor

객체가 생성되는 시점에 자동으로 호출되는 함수이다. 

생성자의 이름은 클래스명과 동일하며 반환 타입을 명시하지 않는 특징이 있다.  

```cs
using System;

namespace Bakcoding
{
    class Person
    {
        string name;
        int age;

        public Person()
        {
            Console.WriteLine("Constructor Call");
        }
    }

    class Program
    {
        static void Main(string[] args)
        {

            Person person = new Person();
            
        }
    }
}

// 콘솔창을 켜놨다면
// Constructor Call 이 출력된다.
```

메인 함수에서 객체를 생성했기 때문에 생성자 안에서 출력한 문자가 콘솔창에 뜨는걸 확인할 수 있다. 

<br>

### 기본 생성자

생성자의 제한자를 private로 해본다. 그러면 메인 함수에서 객체를 만드는 부분이 에러가 나는것을 확인할 수 있다. 

생성자에 제한자를 둔거랑 객체를 만드는거랑 무슨상관인가 의문이든다. 하지만 잠시 코드를 바라보면 이유를 알 수 있다.  

```cs
Person person = new Person();
```

new 연산자 뒤에 오는 별 생각없이 썼던 Person()이 지금보니 생성자와 똑같이 생겼다. 여기서 이 메서드가 바로 생성자라는걸 알 수 있다. 에러가 난 이유도 private로 선언을 하고 외부에서 접근하였기 때문이라는게 이해가 간다.

하지만 곧바로 다른 의문이 생긴다. 그렇다면 생성자를 따로 선언하지 않았을 때는 어떻게 객체가 문제없이 만들어진건가

그 답은 기본 생성자에 있다. C# 컴파일러는 클래스가 생성자 없이 인스턴스화 될 때 자동으로 매개 변수가 없는 생성자를 제공하는데 이게 기본 생성자(defalut constructor)이다. 

<br>

### 초기화

생성자의 역할은 초기화에 있다. 기본적으로 외부에서 멤버변수에 대한 직접적인 접근은 코드의 안전성을 위해서 지향하는게 좋기 때문에 값을 초기화할 때 생성자를 사용하기도 한다.  

생성자는 오버로딩(overload)이 가능하기 때문에 같은 이름으로 매개변수만 달리해서 다양한 생성자를 만들 수 있다. 

따라서 이 생성자를 원하는 방식으로 만들고 외부에서 객체를 인스턴스화 할 때 인자값을 넣어 초기화한다. 

```cs
using System;

namespace CSharp_Project
{
    class Person
    {
        string name;
        int age;

        public Person(string _name, int _age)
        {
            name = _name;
            age = _age;
            Console.WriteLine($"name : {name}\nage : {age}");
        }
    }

    class Program
    {
        static void Main(string[] args)
        {

            Person person = new Person("bak", 50);
        }
    }
}

// 출력
// name : bak
// age : 50
```

생성자를 통해 멤버변수의 값을 초기화하고 출력하여 값의 확인까지 가능하다.