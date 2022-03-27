---
title:  "this"
excerpt: "csharp, this"

categories:
  - CSharp
tags:
  - [csharp, this]

toc: true
toc_sticky: true
 
date: 2022-03-24 
last_modified_at: 2022-03-24
---

***

<br>

### this

객체는 외부에서 자신을 식별할 수 있는 변수를 갖는다.

```cs
Bak bak = new Bak(1234);
```
<br>

변수 bak은 마침표 . 를 사용해 객체의 멤버를 호출할 수 있다.

이 때 클래스 내부의 코드에서 객체가 자신을 가리키기 위해서 사용하는 것이 this 예약어이다.

```cs
class Bak
{
  string _name;
  public string Name;
  {
    get { return this._name; }
  }

  public Bak(string name)
  {
    this._name = name;
  }

  public string GetName()
  {
    return this.Name;
  }

  public void PrintName()
  {
    Console.WriteLine("Name : " + this.GetName());
  }
}
```

이전까지는 this를 생략해서 예시 코드를 작성했다.

위의 경우처럼 코드를 길게 만드는 this 표현을 굳이 사용하는 이유는 없다.

이것은 개발자의 취향 문제로 어떤 개발자는 메서드 내에서 멤버 변수에 접근할 때 그것이 멤버 변수임을 명확히 인식할 수 있게 this를 사용하기도 한다.

하지만 취향 문제가 아닌 꼭 필요해서 사용하는 경우도 있다.

메서드의 매개변수와 클래스에 정의된 필드의 이름이 같을 경우 this를 명시함으로써 멤버 변수를 사용할 수 있다.

```cs
class Bak
{
  string name;
  
  public Bak(string name)
  {
    // this를 생략하면 메서드의 매개변수인 name 변수가 사용된다.
    this.name = name;
  }
}
```

<br>

### 생성자

this 예약어를 사용해 생성자 내에서 다른 생성자를 호출하게 만들 수 있다.

```cs
class Bak
{
  string name;
  int age;
  string job;

  public Bak(string name) : this(name, 0)
  {

  }

  public Bak(string name, int age) : this(name, age, string.Empty)
  {

  }

  // 초기화 코드를 하나의 생성자에서 처리
  public Bak(string name, int age, string job)
  {
    this.name = name;
    this.age = age;
    this.job = job;
  }

  public Bak() : this(string.Empty, 0, string.Empty)
  {

  }
}
```

위 코드에서는 this를 사용해 또 다른 생성자를 호출하는 구문을 사용함으로 초기화 관련 코드를 하나의 메서드 내에서 처리하게 한다.

<br>

### 인스턴스

this 예약어는 new로 할당된 객체를 가리키는 내부 식별자이므로 인스턴스 멤버에서는 사용이 가능하지만 클래스 수준에서 정의되는 정적 멤버는 this를 사용할 수 없다.

```cs
class Bak
{
  // 인스턴스 필드
  string title;
  // 정적 필드
  static int count;
  
  public Bak(string title)
  {
    // 인스턴스 필드 식별
    this.title = title;
    // 인스턴스 메서드 식별
    this.Study();
    // 정적 메서드 사용
    Play();

    // 인스턴스 메서드
    void Study()
    {
      // 인스턴스 멤버 사용
      Console.WriteLine(this.title);
      // 정적 멤버 사용
      Console.WriteLine(count);
    }

    // 정적 메서드
    static void Play()
    {
      // 정적 필드 사용
      count++;
      // this.title = "~";  this가 없으므로 인스턴스 멤버 사용 불가
    }
  }
}
```

따라서 클래스에 정의되는 메서드를 인스턴스로 할 것이냐 정적으로 할 것이냐에 대한 기준에 this를 사용해야하는지 여부가 추가된다.

인스턴스 메서드의 실제 구현되는 방식은 다음과 같다.

```cs
// 코드
Bak bak = new Bak("");
bak.Study();

// 빌드시
Bak bak = new Bak("");
bak.Study(bak);

class Bak
{
  string title;
  ~
  public void Study(Bak this)
  {
    ~
  }
}
```

메서드에 해당 객체를 가리키는 인스턴스 변수를 인자로 넘기면서 동시에 인스턴스 메서드도 변환해서 컴파일 된다.

즉 인스턴스 메서드는 인자를 무조건 1개 이상 더 받게 돼 있으므로 내부에서 인스턴스 멤버에 접근할 일이 없다면 정적 메서드로 명시하는 것이 큰 차이는 아니지만 성능상 유리할 수 있다.
