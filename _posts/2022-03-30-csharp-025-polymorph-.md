---
title:  "클래스 형변환"
excerpt: "csharp, polymorphism, class"

categories:
  - CSharp
tags:
  - [csharp,  polymorphism, class]

toc: true
toc_sticky: true
 
date: 2022-03-30 
last_modified_at: 2022-03-30
---

***

<br>

### 클래스 간의 형변환

사용자 지정 타입은 빈번하게 사용되는 단위가 필요할 때 유용하다. 

예를 들어 금전의 단위를 생각했을 때 국가마다 원, 달러, 엔 등을 단순히 하나로 지정하게 되면 오류가 발생할 여지가 있다.

```cs
decimal won = 10000;
decimal dollar = won * 1200;
decimal yen = won * 13;

yen = dollar;  // 실수로 작성해버린 코드지만 오류가 없기 때문에 문제를 찾기 힘들게 된다.
```

이처럼 버그를 쉽게 유발할 수 있는 상황을 두고 'Code smells'라는 표현을 쓴다 

위 코드를 각 타입을 정의해서 사용하면

```cs
public class Curreny
{
  decimal money;
  public decimal money { get { return money; } }

  public Currency(decimal money)
  {
    this.money = money;
  }
}

public class Won : Currency
{
  public Won(decimal money) : base(money) { }

  public override string ToString()
  {
    return Money + "Won";
  }
}

public class Dollar : Currency
{
  public Dollar(decimal money) : base(money) { }

  public override string ToString()
  {
    return Money + "Dollar";
  }
}

.
.
.
Won won = new Won(1000);
Dollar dollar = new Dollar(1);
.
.
.
won = dollar; // 타입이 다르기 때문에 컴파일 시 에러를 감지한다.
```

이렇게 타입으로 지정해두면 실수로 작성하게 되는 오류가 없는 코드들의 발생을 방지할 수 있다.

여기서 만약 통화 사이에 형변환이 필요한 상황이 생긴다면 대체 구문인 explicit, implicit 메서드를 정의하는 것으로 해결이 가능하다.  

```cs
public class Yen : Currency
{
  .
  .
  .
  static public implicit operator Won(Yen yen)
  {
    return new Won(yen.Money * 13m);  // 1 per 13
  }
}
```

이처럼 implicit operator를 오버로드하여 암시적 형변환을 할 수 있으며 또한 명시적으로 캐스팅 연사자를 쓰는 것도 허용된다. 하지만 개발자가 의도한 형변환만 가능하도록 제한하고 싶다면 impicit 대신 explicit 연산자를 사용하면 된다.

```cs
public class Dollar : Currency
{
  static public explicit operator Won(Dollar dollar)
  {
    return new Won(dollar.Money * 1000m);
  }
}

Dollar dollar = new Dollar(1);
Won won1 = dollar;  // 암시적 형변환 불가능
Won won2 = (Won)dollar; // 명시적 형변환 가능

Console.WriteLine(won2);
```

<br>

이렇게 expllicit 으로 구현한 타입은 반드시 형변환 연산자를 사용해야만 Won 타입으로 변경할 수 있다. 