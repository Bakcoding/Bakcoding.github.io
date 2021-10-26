---
title:  "상속"
excerpt: "javascript, js, opp, inheritance"

categories:
  - Javascript
tags:
  - [javascript, js,  opp, inheritance]

toc: true
toc_sticky: true
 
date: 2021-10-25 
last_modified_at: 2021-10-25
---  

***

###  상속(inheritance)
객체는 연관된 로직들로 이루어진 작은 프로그램이라고 할 수 있다. 상속은 객체의 로직을 그대로 물려 받아 또 다른 객체를 만들 수 있는 기능을 의미한다.  

상속받은 객체는 기존의 로직을 수정하고 변경해서 파생된 새로운 객체로 만들 수 있다.  

```javascript
function Person(name) {
  this.name = name;
  this.introduce = function() {
    return 'My name is '+this.name;
  }
}

var p1 = new Person('bak');
document.write(p1.introduce() + "<br />");
// My name is bak
```

위 코드를 상속하기 위해서는 수정이 필요하다.  


```javascript
function Person(name) {
  this.name = name;
}
// Person 함수에 프로퍼티를 추가하는 방법
Person.prototype.name=null;
Person.prototype.introduce = function() {
  return 'My name is '+this.name;
}

var p1 = new Person('bak');
document.write(p1.introduce()+"<br />");
```

함수 안에서 프로퍼티를 정의했던 방식을 외부에서 할당하는 방식으로 바꾸었다. 동작은 처음의 코드와 동일한 결과를 출력한다.  

이 수정한 코드를 이용해서 상속을 사용해본다. 

```javascript
function Person(name) {
  this.name = name;
}
Person.prototype.name=null;
Person.prototype.introduce = function() {
  return 'My name is '+this.name;
}

// 새로운 생성자
function Programmer(name) {
  this.name = name;
}
Programmer.prototype = new Person();
// 객체를 만들고 인자 넣어준다.
var p1 = new Programmer('bak');
// 메서드 호출
document.write(p1.introduce()+"<br />");
```
Programmer 객체에는 introduce 메서드가 없는데도 정상적으로 결과를 출력한다. 이는 new Person을 통해서 Person을 상속하여 Programmer 객체를 생성하였기 때문에 상속되어서 메서드를 그대로 사용할 수 있게된다.

<br/>

### 상속활용

상속 받은 객체의 프로퍼티를 수정하여 사용한다.  

Person에는 없지만 Programmer는 가지는 기능을 추가한다.
```javascript
function Person(name) {
  this.name = name;
}
Person.prototype.name=null;
Person.prototype.introduce = function() {
  return 'My name is '+this.name;
}

function Programmer(name) {
  this.name = name;
}
Programmer.prototype = new Person();
// Programmer만의 기능 추가
Programmer.prototype.coding = function() {
  return "hello world";
}
var p1 = new Programmer('bak');
document.write(p1.introduce()+"<br />");
document.write(p1.coding()+"<br />");
```

공통적인 기능과 개별적인 기능을 가지는 다수의 객체를 만들 때 상속은 아주 중요한 기능이다.  

