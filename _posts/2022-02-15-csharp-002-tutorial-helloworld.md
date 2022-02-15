---
title:  "Hello World"
excerpt: "csharp, ms, console"

categories:
  - CSharp
tags:
  - [csharp, console]

toc: true
toc_sticky: true
 
date: 2022-02-15 
last_modified_at: 2022-02-15
---  

### 출력

C#에서 메시지를 콘솔창에 출력시키는 방법이다. 

```cs
// 입력 받은 문자열을 출력한다. 
Console.WriteLine("Hello World!");

// 변수를 통해서 출력도 가능하다. 
string s = "Hello World!";
Console.WriteLine(s);

// 문자열 추가가 가능하다.
string h = "Hello ";
string w = "World!";
Console.WriteLine("Hello " + w);
Console.WriteLine(h + "World!");
Console.WriteLine(h + w);

// 문자열 보간
// $ 문자는 중괄호 안의 문자열을 상수로 찾는다. 
Console.WriteLine($"Hello {w}");
```

<br>

### 문자열 보간

\$ 문자를 사용해서 중괄호 안에서 정의된 문자를 문자열로 표현할 수 있다.

중괄호 안의 내용은 다음과 같은 서식을 가진다. 

```cs
{<interpolationExpression>[,<alignment>][:<formatString>]}
```

* {<보간 표현식(서식을 지정할 결과를 생성하는 식)>

*  [,<정렬(식 결과의 문자열 표현에 최소 문자 수를 정의하는 값을 갖는 상수 식이다. 양수이면 오른쪽 음수이면 왼쪽)>]

* [:<문자열 형식(식 결과의 형식을 기준으로 지원되는 서식 문자열이다.)>]
}

```cs
// 예
Console.WriteLine($"|{"Left",-7}|{"Right",7}|");
// 출력
|Left   |  Right|

// 예
const int FieldWidthRightAligned = 20;
Console.WriteLine($"{Math.PI,FieldWidthRightAligned}");
Console.WriteLine($"{Math.PI,FieldWidthRightAligned:F3}");
// 출력
    3.14159265358979
               3.142
```

중괄호 안에서 변수 뒤에 .을 붙여 해당 타입의 속성 및 메서드에 접근할 수 있다. 

```cs
string h = "Hello ";
string w = "World!";
// ToUpper 대문자로 출력한다.
Console.WriteLine(h.ToUpper());
// ToLower 소문자로 출력한다.
Console.WriteLine(w.ToLower());

// 결과
HELLO 
world!
```

<br>

### 검색 

문자열에서 찾으려는 문자열이 있는지 검색할 수 있다.  

```cs
string s = "Hello World!";
string h = "Hello";
// Contains 함수 (찾으려는 문자열)
Console.WriteLine(s.Contains("Hello"));
Console.WriteLine(s.Contains(h));

// 출력
// 찾는 문자열이 포함되어있다면 True, 없다면 False 를 반환한다.
True
True
```

Contains 메서드와 비슷한 기능을 가진 메서드

* StartsWith

  시작 부분을 검색한다.

* EndWith

  끝 부분을 검색한다.