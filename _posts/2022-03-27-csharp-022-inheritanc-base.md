---
title:  "base"
excerpt: "csharp, base"

categories:
  - CSharp
tags:
  - [csharp,  base]

toc: true
toc_sticky: true
 
date: 2022-03-27 
last_modified_at: 2022-03-27
---

***

<br>

### base

base 예약어는 부모 클래스를 명시하는데 사용되며 생략시 부모 클래스의 멤버를 사용시 base 키워드가 생략된것이나 다름없다.

```cs
public class Parent
{
  public void ParentDo(){}
}

public class Child : Parent
{
  public void ChildDo()
  {
    base.ParentDo();
  }
}
```


base 예약어는 this와 마찬가지로 명시하고 안하고는 선택의 문제이며 생성자에서 사용되는 패턴도 this와 유사하다.

다음과 같이 반드시 1개의 매개변수를 생성자에게 받게 되어있는 클래스로부터 상복을 받는 자식 클래스를 정의할 때 

```cs
class Bak
{
  string language;
  public Study(string language)
  {
    this.language = language;
  }
}

class CBak : Bak
{
  public CBak()
  {
    // 에러 발생
  }
}
```

상속 받은 자식에서 매개변수를 선언하지 않으면 컴파일시 오류가 발생한다. 그 이유는 자식 클래스의 생성은 곧 부모 클래스의 생성자를 호출한다는 의미이며 자식 클래스가 생성되는 시점에 부모 클래스의 생성자를 호출해야 하는데 이 때 부모에서 제공되는 생성자에는 매개변수가 존재하기 때문이다.

따라서 컴파일러 입장에서는 매개변수에 대한 정부를 알 수 없고 부모 클래스의 생성자가 여러 개 있는 상황이라면 어떤 생성자를 자동으로 호출해야 할지도 불분명하다. 

이런 경우에 base 예약어를 사용해서 어떤 생성자를 어떤 값으로 호출해야할지 명시하여 문제를 해결할 수 있다.

```cs
class Bak
{
  ~
}

class CBak : Bak
{
  public CBak() : base(0)
  {
  }
  // or

  public CBak(string language) : base(language)
  {

  }
}
```