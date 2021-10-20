---
title:  "함수의 호출"
excerpt: "javascript, js, function, apply"

categories:
  - Javascript
tags:
  - [javascript, js,  function, apply]

toc: true
toc_sticky: true
 
date: 2021-10-20 
last_modified_at: 2021-10-20
---  

***

### 함수의 호출  

자바스크립트에서 함수는 일종의 객체이다.  
그렇기 때문에 속성도 가지고 있으며 그 속성의 값이 저장되어있다면 property, 함수의 형태라면 method를 가지게 된다. 

```java
// 함수 정의시 기본적으로 제공하는 method를 가지게 된다.  
function Func() {
  
}
```

객체이기 때문에 . 을 통해서 객체가 기본적으로 가지고 있는 method에도 접근할 수 있다.

<br/>

### apply

일반적인 함수의 호출은 다음과 같다.  

```java
function sum(arg1, arg2) {
  return arg1 + arg2;
}

sum(1, 2);
// 3의 결과가 나온다.  
```

apply를 사용해본다.   

```java
sum.apply
// function apply() { [native code]}
```
sum이라는 함수의 apply() 메서드의 내용이 나오는데 브라우저를 통해 코드를 실행하면 공개하지 않는 내장코드이기 때문에 native code가 뜬다.  

apply 함수에 인자를 넣어 호출해본다.  

```java
sum.apply(null, [1,2])
// 3
```

apply의 첫번째 인자로 null, 두번째 인자에 배열을 넣은 결과 두번째 인자인 배열의 1과 2를 인자로 하는 sum 함수의 결과가 반환된다.  

즉 sum(1, 2)와 똑같은 결과가 생기는데 우선 이 방법은 유의미한 apply의 사용이 아니다.  

<br/>

### apply 사용법

```java
o1 = {val1:1, val2:2, val3:3}
function sum() {
  var _sum = 0;
  for (name in this) {
    _sum += this[name];
  }
  return _sum;
}

alert(sum.apply(o1))
// 6
```

위 코드에서 함수의 출력결과는 배열의 값의 합으로 나온다.  

**원리**  

* this  
  함수가 호출될 때 결정된다.

sum.apply의 첫번째 인자로 o1을 넣었다. sum함수가 호출되고 함수의 this는 인자로 받은 o1으로 결정이되고 for in을 통해 o1의 모든 원소들의 합이 반환된다.  

즉 위실행은 다음 코드의 동작과 같다.  

```java
function sum() {
  var _sum = 0;
  for (name in this) {
    _sum += this[name];
  }
  return _sum;
}
// o1 객체에 sum 함수 추가
o1 = {val1:1, val2:2, val3:3, sum:sum}
// o1 객체의 sum 호출
alert(o1.sum());
/*
6function sum() {
  var _sum = 0;
  for (name in this) {
    _sum += this[name];
  }
  return _sum;
}
*/
```

이 코드를 실행시키면 sum 함수까지 for in으로 합해지기 때문에 함수의 내용까지 출력되므로 타입을 검사해 함수가 아닌것만 합하게 예외처리해준다.  

```java
function sum() {
  var _sum = 0;
  for (name in this) {  
    if (typeof this[name] !== 'function')
      _sum += this[name];
  }
  return _sum;
}
o1 = {val1:1, val2:2, val3:3, sum:sum}
alert(o1.sum());
// 6
```

즉 apply는 this가 함수가 호출될 때 결정되는 점을 이용해서 sum이 o1객체의 속성인것처럼 실행할 수 있게 된다. 
