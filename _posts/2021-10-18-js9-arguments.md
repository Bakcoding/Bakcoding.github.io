---
title:  "arguments"
excerpt: "javascript, js, arguments"

categories:
  - Javascript
tags:
  - [javascript, js, arguments]

toc: true
toc_sticky: true
 
date: 2021-10-19 
last_modified_at: 2021-10-19
---  

***

### arguments
arguments는 자바스크립트에서 지정한 변수명이다. 함수안에서 그 함수의 정보 중 전달인자에 대한 정보를 담고있는 객체로 배열과 사용방법이 유사하다. 

```javascript
function sum() {
  var i, _sum = 0;
  // 전달인자 배열형태로 저장되며 접근방식도 유사하다.
  for (i = 0; i < arguments.length; i++) {
    document.write(i+' : '+arguments[i]+'<br />');
    _sum += arguments[i];
  }
  return _sum;
}
// 자바스크립트의 큰 특징 중 하나로 매개변수를 따로 지정하지 않아도 전달인자로 입력이 가능하다.  
document.wirte('result : ' + sum(1, 2, 3, 4));
```

sum 함수를 호출하면서 입력한 인자들이 arguments에 저장되고 함수내부에서 접근이 가능하다.  


<br/>

### 매개변수의 수
매개변수와 관련된 두가지 메서드가 있다.

```javascript
function zero(arg1) {
  console.log(
    'zero.length', zero.length,
    'arguments', arguments.length
  );
}
zero('val1', 'val2');
// zero.length 1 arguments 2 를 출력한다.
```

함수.length는 함수가 정의될 때 매개변수의 수를 반환하며 arguments.length는 함수가 호출 될 때 입력받는 전달인자의 수를 반환한다.  
