---
title:  "입력과 출력"
excerpt: "C, scanf, printf, input, output"

categories:
  - C
tags:
  - [C, scanf, printf, input, output]

toc: true
toc_sticky: true
 
date: 2021-07-07
last_modified_at: 2021-07-07
---  

**C언어에서 입력과 출력**  <br/>

C언어에서 입력을 할 때는 scanf 출력은 printf를 사용한다.  
두 기능을 사용하기 위해서는 stdio.h가 필요하다.  

<br/>
예) 입력한 숫자 호출하기
<br/><br/>

``` c
#include <stdio.h>

int main()
{
  int number = 0;
  scanf_s("%d", &number);
  printf("입력한 숫자 : %d", &number);

  return 0;
}
```
<br/>  

* 입력받을 자료형으로 변수를 선언한다.  
    ``` c
    int number = 0; 
    ``` 
     
* scnaf를 사용해서 값을 입력받는다.  
    ``` c  
    scanf_s("%d", &number);
    ```
    위에서 선언한 number 변수에 입력한 값을 저장하게 된다.  
    <br/>

* 입력한 숫자를 출력한다.  
    number에 저장된 입력 값 출력  
    ``` c  
    printf("입력한 숫자 : %d", number);
    ``` 
    <br/>

![scanf_printf](/assets/images/20210707_Posting/1.gif)  <br/>  