---
title:  "캡슐화"
excerpt: "csharp, encapsulation"

categories:
  - CSharp
tags:
  - [csharp, encapsulation]

toc: true
toc_sticky: true
 
date: 2022-03-02 
last_modified_at: 2022-03-02
---

### 캡슐화

encapsulation

프로그래밍을 할 때 관련성 있는 데이터와 그 데이터를 다루는 메서드를 객체 안에 구현하는 것이 기본적이다.  

더 나아가서는 외부에서 알필요가 없는 내부 멤버들은 숨겨놓고 사용하기도한다.  

이렇게 연관된 데이터를 묶고 외부에 필요한 정보만 접근 가능하게 만드는 것을 캡슐화라고 한다.

<br>

객체가 없던 시절에는 데이터와 코드가 한 곳에 묶일 구실점이 없었기 때문에 그나마 파일을 구분해서 코드를 작성할 수 있었다.  

하지만 외부에서 접근을 제한할 수 있는 방법은 없었는데 이 문제는 객체지향 프로그래밍에서 클래스를 통해 캡슐화가 가능해지면서 해결되었다. 

<br>

#### 접근 제한자

access modifier

|예약어|설명|
|-----|----|
|private|내부에서만 접근을 허용한다.|
|protected|내부에서의 접근과 함께 파생 클래스에서만 접근을 허용한다.|
|public|내부 및 파생 클래스 뿐만 아니라 외부에서의 접근도 허용한다.|
|internal|동일한 어셈블리 내에서는 public에 준한 접근을 허용한다. 다른 어셈블리에서는 접근 할 수 없다.|
|internal protected|동일 어셈블리 내에서 정의된 클래스 또는 다른 어셈블리라면 파생 클래스인 경우에 한하여 접근할 수 있다.|

접근 제한자의 기능이 외부에서 클래스를 사용할 때 접근을 허용하고 싶은 것들만 지정할 수 있게 만드는 역할을 한다. 

<br>

#### 정보 은닉

information hiding

캡슐화에는 접근 제한자와 함께 반드시 나오는것이 정보 은닉이다. 

클래스 입장에서 정보라고 불리는 것은 멤버 변수를 말하는데 외부에서 이 멤버 변수를 직접 접근할 수 없게 만드는 것이 바로 정보 은닉에 해당한다.

일반적으로 캡슐화를 잘 했다면 정보 은닉도 함께 지켜지는 것이 보통이지만 정보 은닉을 잘했다고 캡슐화가 잘된것은 아니다. 

즉 온갖 기능을 넣은 클래스에서도 멤버 변수를 외부에 노출시키지 않는다면 정보 은닉은 성립한다는 것이다.

그렇다면 멤버 변수의 경우 숨기고 싶지만 외부에서 값에 접근할 필요가 있을 때가 문제가 된다.

그 문제를 해결하는 방법이 get, set 이다.

<br>


#### get, set

필드의 값을 읽을 때 get, 쓰는 것을 set이라고 사용하는것이 관례적이다. 그리고 멤버 변수에 대해 get/set 기능을 하는 메서드를 접근자 메서드(getter), 설정자 메서드(setter)라고 한다.  

```cs
class Study
{
  int time = 3;
  // getter
  public int GetTime()
  {
    return time;
  }
  // setter
  public void SetTime(int _time)
  {
    time = _time;
  }
}
```

멤버 변수를 public으로 사용하지 않고 getter, setter를 사용하는 이유는 유지보수에 있다. public으로 설정된 time 멤버 변수를 여기저기서 값을 바꿔가면서 쓰다가 에러가 발생하는 경우가 생겼다면 time 변수를 사용하는 코드를 모조리 찾아봐야 하지만 설정자 메서드를 사용한다면 그 메서드 안에서 진단용 코드를 작성해 문제를 쉽게 발견할 수 있다.

```cs
class Study
{
  int time = 3;
  // getter
  public int GetTime()
  {
    return time;
  }
  // setter
  public void SetTime(int _time)
  {
    if (_time <= 0 || _time >= 6)
    {
      Console.WriteLine("Error!!");
    }
    time = _time;
  }
}
```

<br>

접근자/설정자 메서드를 통해 필드 접근을 제한하는 것은 바람직하지만 호출을 위한 메서드 정의를 매번 코드로 작성하기는 번거롭다.

이런 단점을 보완하기 위한 기능이 프로퍼티이다.

<br>

#### 프로퍼티

property

속성으로 번역되지만 객체지향에서 말하는 속성(attribute)는 '필드'에 해당하고 C#에서 속성은(property) '접근자/설정자 메서드에 대한 편리한 구문'에 해당한다.

보통 public으로 두기 때문에 공용 속성이라고 구분해서 부르기도 한다.

```cs
class Study
{
  int time = 3;

  public int Time
  {
    get { return time; }
    set { time = value; }
  }
}
```

public으로 Time을 만들고 get을 정의해 time을 읽고 set을 통해 쓴다. 그런데 set에서 value가 어디서 나오게 됐는지 의문이 생긴다.  

설정자 메서드는 사용자가 전달하는 값을 매개변수명을 통해서 구분할 수 있지만 프로퍼티 정의에서는 매개변수가 없기 때문에 프로퍼티에 대입되는 값을 가리킬 수 있는 예약어 value가 만들어졌다. 

value는 set 블록 내에서만 사용할 수 있는 예약어이다.

또한 get/set 에도 접근 제한자를 지정할 수 있어 set을 없애지 않고 private로 설정하여 사용할 수 있다.

프로퍼티는 메서드의 특수한 변형에 불과하며 컴파일러가 빌드하는 시점에서는 자동으로 메서드를 getter, setter로 분리해서 컴파일하게된다.