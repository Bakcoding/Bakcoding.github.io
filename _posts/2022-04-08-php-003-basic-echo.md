---
title:  "PHP echo"
excerpt: "php, echo, print"

categories:
  - PHP
tags:
  - [php, echo, print]

toc: true
toc_sticky: true
 
date: 2022-04-08 
last_modified_at: 2022-04-08
---

***

<br>

### echo

php에서 출력하는 기능을 한다. 

```php
<?php 
  echo "Hello PHP!"; 
  echo 'Hello PHP!';  // Hello PHP!
?>
```

큰 따옴표, 작은 따옴표는 문자열은 동일하게 출력하게 출력하며 세미콜론은 php 문장의 끝을 나타낸다.

주의할 점은 문자열에 변수나 이스케이프 문자 등 처럼 문자열 자체만 포함되는 경우가 아닐 때는 큰 따옴표를 사용해주어야한다. 

```php
<?php 
  echo "Hello PHP!\n"; 
  echo 'Hello PHP!\n';  // \n문자 그대로 출력된다.
?>
```

<br>

#### 줄 바꿈 문자

일반적으로 사용되어지는 줄 바꿈 문자의 경우 PHP에서는 다르게 사용되어진다.

```php
<?php 
  echo "Hello <br> PHP!"; // <br> 사용
  echo nl2br("Hello \r\nPHP!");  // nl2br 함수 사용
?>
```

두 가지 모두 줄 바꿈의 기능을 한다. 

nl2br 함수의 경우 문자열 내부에 이스케이프 문자가 있는 지점에서 동작한다. 이 때 \n 을 사용해도 가능하다.

>\r = CR(캐리지 리턴) : MacOS에서 줄 바꾸기 문자로 사용  
>\n = LF(줄 바꿈) : Unix/ MacOS에서 줄 바꾸기 문자로 사용  
>\r\n = CR + LF : Windows에서 줄 바꾸기 문자로 사용  

<br>


### Print

echo 와 동일하게 출력하는 기능을 가지고 있지만 차이점이 있다.

* return   

  echo의 경우 void 를 반환하고 print는 int 값 1을 반환한다. 

* argument

  echo는 다수의 인자를 가질 수 있지만 print는 오직 하나의 인자만 가질 수 있다.

그리고 echo 가 print 보다 살짝 빠른 성능을 가지기도 한다.

공통점은 둘 다 함수가 아니며 사용할 때 괄호없이 인자를 가질 수 있다. 

<br>

```php
<?php
  print "Hello PHP!";
  printf("<br>This is printf function");
?>
```

뿐만 아니라 C에서 사용하는 printf 함수의 사용도 가능하다.