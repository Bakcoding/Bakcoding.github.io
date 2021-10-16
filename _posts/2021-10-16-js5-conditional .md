---
title:  "선언문"
excerpt: "javascript, js, conditional"

categories:
  - Javascript
tags:
  - [javascript, js, conditional]

toc: true
toc_sticky: true
 
date: 2021-10-16 
last_modified_at: 2021-10-16
---  

***

### 조건문  
표현식이 참일 때 실행되고 거짓일 때 실행되지 않는 문장이다.  

### if

```javascript
if (표현식){
  // ~ 실행내용 ~
}
```

표현식으로 실행여부가 결정되며 다양한 방식이 가능해 원하는 상황에만 동작하는 기능을 만들 수 있게 한다.  

* 참으로 판단하는 경우
  ```javascript
  if (true)
  if (1)
  if (-1)
  if ('not blank')
  if ({})
  if ([])
  ```
* 거짓으로 판단하는 경우

  ```javascript
  if (false)
  if (0)
  if ('')
  if (null)
  if (undefined)
  if (NaN)
  ```

산술의 결과, 값의 비교, 일치 여부 등과 같이 참과 거짓으로 나타낼 수 있다면 모두 조건으로 사용이 가능하다.  

```javascript
if ( n + 1 === 0)
if ( n > 0)
```


**else if**  
if 이후 조건이 추가적으로 필요할 때 사용한다.  

```javascript
if (n % 3 === 0)
{
    console.log('n은 3의 배수입니다.');
}
else if (n % 5 === 0)
{
    console.log('n은 5의 배수입니다.');
}
```

**else**  
조건 이외의 결과를 일괄적으로 처리할 때 사용하며 if나 else의 마지막에 쓴다.  

```javascript
if (n % 3 === 0)
{
    console.log('n은 3의 배수입니다.');
}
else if (n % 5 === 0)
{
    console.log('n은 5의 배수입니다.');
}
else
{
    console.log('n은 3의 배수도 아니고, 5의 배수도 아닙니다.');
}
```

**논리 연산자**  
논리 연산자를 사용해서 조건을 여러개를 걸거나 간단하게 표현할 수 있다.   

* AND(&&) 연산자  

  세 조건이 모두 참일 때 만 실행한다. 앞의 조건을 순서대로 확인하기 때문에 앞에서 하나라도 거짓인 경우 즉시 다음 작업으로 넘어간다.  

  ```javascript
  if (true && true && true)
  ```

* OR(||) 연산자

  세 조건 중 하나라도 참이면 실행한다. 앞에서부터 조건이 참이면 즉시 실행되며 거짓인 경우 다음 조건으로 넘어가 판단한다.  

  ```javascript
  if (false || false || false)
  ```

* NOT(!) 연산자  

  ```javascript
  // 참이 아닐 때 실행, 즉 거짓이면 실행된다.  
  if (!true)
  // 거짓이 아닐 때 실행, 즉 참이면 실행된다.  
  if (!false)
  ```

<br/>

### switch

케이스를 나누어서 조건에 맞는 문장을 실행한다.  

```javascript
var n = 2;

switch (n)
{
  case 2:
    ~
  case 5: 
    ~
}
```
위 코드를 실행하면 조건에 해당하는 case 2가 실행된다. 하지만 switch의 특징은 참인 case가 나오면 그 뒤의 모든 case도 실행을 하는것이다. 따라서 해당하는 경우만 출력하고 싶다면 break를 사용한다.  

```javascript
var n = 2;

switch (n)
{
  case 2:
    ~
    break;
  case 5: 
    ~
    break;
}
```

해당하는 case 실행후 break로 해당 코드 탈출한다.  

조건에 맞는게 없어도 기본값을 출력하는 방법이 있다.  

```javascript
var n = 2;

switch (n)
{
  case 2:
    ~
    break;
  case 5: 
    ~
    break;
  default:
    ~
}
```
해당하는 조건을 못 찾으면 default를 실행시킨다. 