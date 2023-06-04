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
last_modified_at: 2023-06-04
---  

***

### C언어에서 입력과 출력  
c에서 입력과 출력은 scanf와 printf 함수를 사용한다.  
두 함수 모두 stdio.h 의 라이브러리에 포함되어있기 때문에 해당 라이브러리를 include를 해야 사용이 가능하다. 

<br/>

예) 입력한 숫자 호출하기

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

* 입력받을 자료형으로 변수를 선언한다.  
    ``` c
    int number = 0; 
    ``` 
     
* scanf 사용해서 값을 입력받는다.  
    ``` c  
    scanf_s("%d", &number);
    ```
    위에서 선언한 number 변수에 입력한 값을 저장하게 된다.  
    

* 입력한 숫자를 출력한다.  
    number에 저장된 입력 값 출력  
    ``` c  
    printf("입력한 숫자 : %d", number);
    ``` 

<br/>

결과  
![scanf_printf](/assets/images/posting/20210707/using_scanf.gif)  