---
title:  "네임스페이스"
excerpt: "csharp, namespace"

categories:
  - CSharp
tags:
  - [csharp, namespace]

toc: true
toc_sticky: true
 
date: 2022-03-02 
last_modified_at: 2022-03-02
---

### 네임스페이스

namespace

이름이 중복되어 정의되는 것을 구분하기 위해서 만들어졌다. 일반적으로는 수 많은 클래스를 분류하는 방법으로 사용된다. 

다른 사람들이 만든 클래스를 이것저것 사용하다보면 클래스, 변수, 메서드 등 이름이 중복되어 사용되는 경우가 생기는데  

컴파일러는 이런 상황에서 적절한 의미를 선택해서 해석할 수 없기 때문에 이름 충돌(naming conflict) 오류가 발생한다.

<br>

네임스페이스는 이런 문제를 해결하기 위해 개발자가 문맥에 해당하는 정보를 컴파일러에게 주는 역할을 한다. 

```cs
namespace Bakcoding
{
  class Study{}
}

namespace Blog
{
  class Study{}
}
```

네임스페이스로 구분된 블록 내에서는 동일한 이름 공간이 적용되며 네임스페이스 외부에서 사용하는 경우 네임스페이스도 명시하여야한다.

```cs
static void Main(string[] args)
{
  Bakcoding.Study study = new Bakcoding.Study();
}
```

### using

하지만 이렇게 매번 네임스페이스까지 작성하는것은 번거럽기 때문에 using 이라는 예약어를 통해서 생략이 가능하다. 

```cs
using Bakcoding;

static void Main(string[] args)
{
  Study study = new Study();
}
```

<br>

이걸 통해서 지금까지 c# 코드를 작성할 때 기본적으로 작성했던 using System의 의미를 알 수 있다. 

System이라는 네임스페이스를 사용한다고 명시함으로 생략하여 여러 메서드를 사용할 수 있었다. 

```cs
//using System

namespace Bakcoding
{
  class Program
  {
    static void Main(string[] args)
    {
      System.Console.WriteLine("Hello World");
    }
  }
}
```