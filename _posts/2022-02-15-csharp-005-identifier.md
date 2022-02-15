---
title:  "식별자"
excerpt: "csharp, identifier"

categories:
  - CSharp
tags:
  - [csharp, identifier]

toc: true
toc_sticky: true
 
date: 2022-02-15 
last_modified_at: 2022-02-15
---

### 식별자

식별자는 사용자가 임의로 선택해서 지을 수 있는 단어를 말한다. 

예를 들어

```cs
namespace bakcoding 
{
  class Program
  {
    private void Main()
    {
      string str = "Hello World";
    }
  }
}
```

위 작명한 것들이 식별자에 해당한다. 

#### 규칙

식별자로 사용할 수 있는 문자에는 제한사항이 있다.

* 시작 문자는 숫자로 할 수 없다.

  ```cs
  int 1n = 1; // 불가능
  int n1 = 1; // 가능
  ```

* 특수 문자 중에서 유일하게 _(underscore)만 시작 문자로 사용할 수 있다.

  ```cs
  int _num = 10;
  ```

* 한글 식별자도 가능은 하다. 하지만 코드는 영어로만 작성하는것이 좋다.

* 예약어를 사용할 수 없지만 사용해야 한다면 @ 문자를 접두사로 붙이면 식별자로 인식시킬 수 있다. 

  ```cs
  int @bool = 1;
  ```

* 이스케이프 시퀀스도 식별자로 사용할 수 있다.  

  ```cs
  int \u006= 11;
  ```