---
title:  "메인함수"
excerpt: "csharp, main"

categories:
  - CSharp
tags:
  - [csharp, main]

toc: true
toc_sticky: true
 
date: 2022-02-26 
last_modified_at: 2022-02-26
---

### 메인함수

C++의 main() 함수처럼 프로그램이 실행될 때 가장 먼지 코드를 읽기 시작하는 시작점으로 프로그램을 실행하기 위해서 작성을 해주어야한다. 

<br>

#### 특징

* class 안에 속해야한다. 

* 반드시 정적 메서드여야 한다.  

* 반환값은 void 또는 int만 허용된다.  

* 매개변수는 없거나 string 배열만 허용된다.

리턴값과 인수는 4가지를 사용할 수 있다. 

```cs
public static void Main();
public static int Main();
public static void Main(string[] args);
public static int Main(string[] args);
```

Main 함수가 클래스에 소속되는 멤버이기 때문에 여러 개의 클래스에서 각각의 Main을 가지는 것이 가능하지만 프로그램이 실행될 때 진입점은 유일해야 하므로 컴파일 전에 어떤것이 유효한지를 알려줄 필요가 있다.

<br>

#### 형태

```cs
using System;

class Program
{
    static void Main(string[] args)
    {
        Console.WriteLine("Main Function");
    }
}
```