---
title:  "종료자"
excerpt: "csharp, class, destructor"

categories:
  - CSharp
tags:
  - [csharp, class, destructor]

toc: true
toc_sticky: true
 
date: 2022-02-25 
last_modified_at: 2023-06-05
---

### 종료자

객체가 선언될 때 호출된게 생성자라면 종료자는 객체가 제거될 때 호출되는거라고 짐작할 수 있다. 

종료자도 생성자와 마찬가지로 명시하지 않으면 기본적으로 제공하는 종료자가 존재하기 때문에 지금까지 작성없이도 문제가 없었다.

선언하는 방식은 생성자와 거의 똑같으며 어떠한 인자나 반환값도 갖지 않는다는 차이가 있다.  

```cs
using System;

namespace CSharp_Project
{
    class Person
    {
        string name;
        int age;

        public Person()
        {
            ~
        }

        ~Person() { 
            Console.WriteLine("Destructor Call");
        }
    }
}
```

<br>

### 호출시점

C++에서는 동적으로 할당된 메모리는 수동으로 delete 연산자를 통해 해제해주었다. 따라서 이 연산자가 호출되는 시점이 종료자가 호출되는 시점이라는걸 알 수 있지만 C#의 경우는 힙 메모리에 대한 직접적인 관리는 불가능하며 가비지 수집가라는 기능을 통해서 불규칙하게 메모리를 정리한다는걸 알고 있다.  

따라서 종료자가 호출되는 시점 또한 알 수 없게 되므로 종료자를 정의하는 것에 대해서는 신중함이 필요하다. 그 이유는 가비지 수집가 입장에서는 일반 참조 객체와 달리 종료자가 정의된 클래스 객체를 관리하려면 더 복잡한 과정을 거치기 때문에 성능면에서 더 부하를 줄 수 있게된다. 

![destructor](/assets/images/posting/20220225/destructor.png)
<br>

공식에서도 이 문제에 대해서 말해주고 있다. 하지만 정의할 수 있게 구현해 놓았다는것은 어떻게든 쓰는 구석이 있다는 것이지만 아직은 거기에 대해서 모르고 넘어가도 될거같다.

