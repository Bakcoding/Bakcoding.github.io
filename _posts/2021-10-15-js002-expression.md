---
title:  "표현식"
excerpt: "javascript, js, expression"

categories:
  - Javascript
tags:
  - [javascript, js, expression]

toc: true
toc_sticky: true
 
date: 2021-10-15 
last_modified_at: 2021-10-15
---  

***

### 표현식(expression)
표현식이란 값을 반환하는 식 또는 코드를 말한다. 
즉 인터프리터가 값으로 평가하는 자바스크립트의 구문들을 말한다.

<br/>

* 기본 표현식  
  가장 간단한 형태로 다른 표현식을 포함하지 않는 독립적인 표현식이다.  

  상수, 리터럴 값, 특정 키워드들, 변수 참조 등

  ```javascript
  1
  // 1
  1+1
  // 2
  null
  // null
  true
  // true
  "Hello"
  //"Hello"
  "Hello" + " JavaScript"
  //"Hello JavaScript"
  ```

* 객체나 배열의 초기화 표현식  
  새로 생성된 객체나 배열을 값으로 하는 표현식이다. 
  ```javascript
  let arr = [1, 2, 3];
  arr;
  // (3) [1, 2, 3]
  ```

* 프로퍼티 접근 표현식
  프로퍼티에 접근하기 위해 .이나 []를 사용하는 표현식을 말한다.  

  ```javascript
  document.wirte(arr);
  ```

* 호출 표현식  
  모든 호출 표현식은 한 쌍의 괄호와 괄호 앞에 오는 표현식으로 이루어진다. 

  값을 반환하기 위해 return 문을 사용하면 그 값이 결국 호출 표현식의 값이 된다.  
  ```javascript
  var foo = function() { return 5; }
  ```

* 객체 생성 표현식  
  객체를 생성하고 생성자 함수를 호출해 객체에 속한 프로퍼티를 초기화하는 표현식을 말한다.  

  ```javascript
  var obj = new Object();
  obj.name = 'bak';
  obj['age'] = 13;
  ```

* 산술 표현식  
  수로 변환 불가능한 피연산자는 NaN 값으로 변환되며 피연산자중 하나라도 NaN 일 경우에는 연산 결과도 NaN이다.  

  ```javascript
  1 + 2
  // 3                   
  "1" + "2"
  // "12"         
  "1" + 2  
  // "12"                           
  true + true
  // 2          
  2 + null   
  // 2, null이 0으로 된다.            
  
  2 + undefined
  2 + NaN
  // 둘 다 NaN 나옴   
  ```

* 관계형 표현식  
  == : 동치  
  === : 일치, 동치보다 엄격하다.

  ```javascript
  true == 1;
  // ture
  // 두 피연산자를 비교하기전 true를 1로 변환함

  true === 1;
  // false
  // 두 피연산자의 타입에서 부터 걸러진다.  
  ```

  <, > : 비교 연산자, 오직 숫자와 문자열만 비교할 수 있기 때문에 해당하지 않는 피연산자는 먼저 변환된다.

  ```javascript
  1 < 2;
  // true, 숫자비교

  "1" < "2"
  // true, 문자열이 숫자로 변환되어 비교

  1 < "2"
  // true, 문자열이 숫자로 변환

  "1" < 2
  // false, 
  ```  

  in 연산자  
  좌변에는 문자열로 변활 될 수 잇는 문자열을 받고 우변에는 객체나 배열을 받는다.  

  ```javascript
  // 객체 정의
  const obj = {
    x: 1,
    y: 2,
    z: 3,
  }

  "x" in obj
  // true, 객체 obj에 프로퍼티 x 존재

  "i" in obj
  // false, 객체 obj에 프로퍼티 i 존재하지 않음

  0 in arr
  // true, 숫자는 배열의 index를 말한다. 배열에 0번째 원소 존재 해당 원소값 1

  3 in arr
  // false, 3번째 원소 없음
  ```

  instanceof 연산자  
  좌변의 객체를 우변의 객체 클래스의 이름을 받는다.  

  ```javascript
  // 생성자 Data(), 새로운 객체 생성
  var d = new Data();

  d instanceof Data;
  // true, d는 Data()로 생성되었음

  d instanceof Object;
  // true, 모든 객체는 Object의 인스턴스

  d instanceof Number;
  // false, d는 Number의 객체가 아님

  var a = [1, 2, 3];
  a instanceof Array;
  // true, a는 배열
  a instanceof Object;
  // true, 모든 배열은 객체
  a instanceof RegExp;
  // false, 배열은 정규 표현식이 아님
  ```
* 논리 연산자  
  OR(||)
  일반적으로 여러 값 중에서 최초로 true로 평가되는 값을 선택하는 경우에 사용된다.  

  ```javascript
  // max_width가 정의되어 있지 않으면 
  // preferences.max_width 객체에 속한 값을 찾는다. 정의되지 않았다면
  // 마지막 상수를 사용한다.  
  var max = max_width || preferences.max_width || 500;
  ```
  NOT(!)  
  단항 연산자이며 단일 피연산자 앞에 놓인다. 이 연산자의 목적은 피연산자의 값을 반대로 바꾸는 것이다.  

  ```javascript
  var x = true;
  !x;
  // false;
  ``` 

  

* 기타 연산자들  
  typeof 연산자  
  
  ```javascript
  var x = new Object;
  typeof x;
  // "object"

  var y = new Function;
  typeof y;
  // "function"
  ```

  delete 연산자  
  
  ```javascript
  var x = [1, 2, 3];
  delete x[0];
  // true
  x
  // (3) [empty, 2, 3]
  delete x[1]
  delete x[1]

  x.length
  // 3, 길이는 유지된다.

  var y = {
    a: 1,
    b: 2
  }

  delete y.a;
  y
  // {b: 2}
  ```