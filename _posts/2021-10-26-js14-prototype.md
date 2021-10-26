---
title:  "프로토타입"
excerpt: "javascript, js, prototype"

categories:
  - Javascript
tags:
  - [javascript, js,  prototype]

toc: true
toc_sticky: true
 
date: 2021-10-26 
last_modified_at: 2021-10-26
---  

***

###  prototype  

자바스크립트가 다른 객체지향언어들과 큰 차이를 보이는 이유이다.  

```javascript
function Ultra() {}
Ultra.prototype.ultraProp = true;

function Super() {}
Super.prototype = new Ultra();

function Sub() {}
Sub.prototype = new Super();

var o = new Sub();
console.log(o.ultraProp);
// true
```
이 코드는 아래 구조의 상속 관계를 가지고 있다.  

&nbsp; Ultra  
&nbsp;&nbsp;&nbsp;&nbsp;  |  
&nbsp; Super  
&nbsp;&nbsp;&nbsp;&nbsp;  |  
&nbsp;&nbsp; Sub  

sub로부터 ultraProp에 대한 접근은 부모인 Super에서 찾게되고 Super도 가지고 있지 않기 때문에 그 부모인 Ultra에서 찾게 된다.  

o 변수안에는 생성자를 통해서 만든 객체가 저장되어있다. 생성자를 사용했기 때문에 객체의 프로퍼티까지 사용할 수 있게 되며 이 객체의 원형은 prototype이라는 프로퍼티에 저장되어있다.  

Sub.prototype에는 new Super가 저장되어있고 new를 사용한 생성자 호출은 이 new Super를 꺼내서 반환하게된다. 이 Super.prototype에는 new Ultra 객체가 저장되어 타고 올라가면 Ultra.prototype.ultraProp = true; 의 객체까지 같이 저장되기 때문에 o.ultraProp의 접근이 가능해진다.  

이렇게 객체끼리 연결이 된것을 prototype chain이라고 한다.  

이 연결 구조에서 prototype에 저장된 값은 가장 가까운 부모의 값을 찾아서 가져온다.  

```javascript
function Ultra() {}
Ultra.prototype.ultraProp = true;

function Super() {}
var t = new Ultra();
t.ultraProp = 3;
Super.prototype = t;

function Sub() {}
Sub.prototype = new Super();

var o = new Sub();
console.log(o.ultraProp);
// 3 출력
```

```javascript
function Ultra() {}
Ultra.prototype.ultraProp = true;

function Super() {}
var t = new Ultra();
t.ultraProp = 3;
Super.prototype = t;

function Sub() {}
var s = new Super();
s.ultraProp = 2;
Sub.prototype = s;

var o = new Sub();
console.log(o.ultraProp);
// 2 출력
```

<br/>

### 주의할점  

동작만 따지고 본다면 다음의 코드도 동일하게 프로퍼티를 사용할 수 있어 보인다.  

```javascript
//----------------------------
function Sub() {}
Sub.prototype = Super.prototype;
//----------------------------
```

이렇게 프로퍼티를 값으로 주게되면 동작이 잘되는것처럼 보이지만 prototype를 통해서 Super.prototype의 값에 영향을 줄 수 있으며 이는 하위 객체의 코드 수정이 상위 객체에 영향을 가져오는 큰 문제를 가지고 온다.  

따라서 상속할 때는 new 생성자를 통해서 prototype에 객체를 저장해주어야한다.  