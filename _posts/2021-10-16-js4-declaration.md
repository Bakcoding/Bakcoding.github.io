---
title:  "선언문"
excerpt: "javascript, js, declaration"

categories:
  - Javascript
tags:
  - [javascript, js, declaration]

toc: true
toc_sticky: true
 
date: 2021-10-16 
last_modified_at: 2021-10-16
---  

***

### 선언문
변수의 선언도 하나의 표현식에 해당된다. 변수를 선언하면서 초기화까지 한다면 하나 이상의 표현식으로된 문장이며 함수의 선언도 마찬가지로 그 정의까지 묶어서 문장이 된다.  

**var**  
하나 또는 그 이상의 변수를 선언한다. 변수에 초기 값을 지정하지 않으면 변수의 초기 값은 undefined이며 함수 안에서 선언된 변수는 해당 스크립트나 함수 전체에 걸쳐 유효하다.  

**function**  
함수 선언문은 자바스크립트 가장 위에서 선언되거나 함수내에 중첩될 수도 있다. 하지만 함수가 다른 함수 속에 중첩될 때는 중첩된 함수 내에서 최상위 단계에 위치해야 한다.  

함수 선언문은 함수 정의 표현식과는 다르다. 둘 다 새 함수 객체를 만들지만 함수 선언문은 함수 이름을 변수로 선언한 후 이 변수에 함수 객체를 할당한다는 차이가 있다.  

```javascript
//함수 선언문  
function FuncName() {
  ~
}

//함수 표현식
var FuncName2 = function () {
  ~
}
```
함수 선언문으로 정의된 함수는 스크립트나 함수 유효범위 최상단에 위치하게 되어 함수 선언에 앞서 함수의 호출이 가능하게 된다. 이렇게 최상단으로 끌어올려지는걸 호이스팅이라고 하며 var의 선언도 마찬가지로 적용된다. 하지만 var로 선언하여 정의된 함수는 변수의 선언만 적용되기 때문에 에러가 발생한다.  


```javascript
//작성된 코드
Func1();
Func2();

function Func1() {
  console.log("func1 call");
}

var Func2 = function () {
  console.log("func2 call");
}

//-----------------------------------//

//실제 실행기의 인식
//호이스팅으로 최상단에 위치함
function Func1() {
  console.log("func1 call");
}
// var는 변수 선언만 호이스팅
var Func2;

Func1();
// 함수로 호출시 현재 변수 취급이기 때문에 is not a function 에러 발생
Func2();

// 여기에서 함수로 정의됨
var Func2 = function () {
  console.log("func2 call");
}
```

위 코드의 결과는 Func1의 경우 정상적으로 동작하지만 Func2의 경우 함수가 아닌 변수로 인식되어 선언부만 호이스팅으로 상단에 위치하게 되어 에러가 발생하게 된다.  