---
title:  "C Hello World!"
excerpt: "C, printf, Hello, World"

categories:
  - C
tags:
  - [C, printf]

toc: true
toc_sticky: true
 
date: 2021-06-22
last_modified_at: 2021-06-22
---  

**Hello World!**   
printf를 사용하여 문자 출력하기  
<br/>
<br/>  
***

``` c
#include <stdio.h>

int main(void)
{
  printf("Hello World!\n");

  return 0;
}
```

### 1. #include `<stdio.h>`

printf(출력)을 사용하기 위해서 헤더 파일을 추가하는 명령어이다.

  * *\#: 전처리기(Pre-Processing), 프로그램이 실행될 때 컴파일 직전 실행되는 프로그램  
  * \#include: 컴파일 하기전에 다른 소스를 추가시키는 명령어  
  * `<stdio.h>`: 기본 입출력 헤더 파일(Standard Input Output Header) 
  
<br/><br/>

### 2. int main(void), return 0;
  
int: 반환형, 함수가 종료될 때 반환하는 데이터형(int = 정수형)  
main(void): 메인 함수, 프로그램이 시작될 때 가장 먼저 호출되는 함수(엔트리 포인트)  

return 0;: 0을 반환하고 함수를 종료한다.  
  
함수가 시작되면 프로그램이 코드를 읽기 시작하고 함수가 종료될 때 반환되는 값으로 운영체제는 프로그램이 정상 종료되었는지 판단한다.  
반환값이 0일 때 정상으로 판단하고 이외의 경우 비정상으로 판단한다.  
  


<br/><br/>

### 3. printf("Hello World!\n");  
  
printf: print formatted, 입력한 포맷으로 출력하는 함수  
("Hello World!\n"): 큰 따옴표 안에 출력할 문자를 입력한다.  
\n: 이스케이프 명령어, 줄 바꿈 문자

<br/><br/>
실행결과
 ![1](/assets/images/20210622_Posting/1.png)