---
title:  "부동소수점(Floating-Point)"
excerpt: "C, Float, Double, Datatype"

categories:
  - C
tags:
  - [C, Datatype, Float, Double]

toc: true
toc_sticky: true
 
date: 2021-06-26
last_modified_at: 2021-06-26
---  

**부동소수점**  
컴퓨터가 실수를 표현하는 방식이다.  
  
  <br/><br/>

### 1. 실수 표현 방식  
  * 컴퓨터는 숫자를 표현할 때 기본적으로 2진수를 사용한다.

 ![datatype size](/assets/images/20210626_Posting/3.png)  
 
 <br/>  
 따라서 컴퓨터에서 실수를 표현 함에 있어 정밀도에 문제가 생긴다. 여기서 생기는 오차를 부동소수점 오차라 한다.  

 <br/>예제)  
반복문을 사용해 실수를 합해본다.

 ``` c
#include <stdio.h>

int main()
{
  float sum = 0.0f;
  
  for (int i = 0; i < 1000; i++)
  {
    sum += 0.001f;
  }
  printf("sum : %f\n", sum);

  return 0;
}
```

<br/>
실행 결과  
  
 ![datatype size](/assets/images/20210626_Posting/4.PNG)  

 0.001을 1000번 더해주면 1이 나와야 하지만 오차가 발생한걸 확인할 수 있다.