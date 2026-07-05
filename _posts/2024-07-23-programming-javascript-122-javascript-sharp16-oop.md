---
title: "JavaScript #16 객체지향 프로그래밍(OOP)"
excerpt: "JavaScript #16 객체지향 프로그래밍(OOP)"
categories:
  - Javascript
permalink: /programming/javascript/122-javascript-sharp16-oop/
tags:
  - "JavaScript"
  - "Web"
  - "CLASS"
  - "inherit"
  - "instance"
  - "객체지향"
  - "상속"
  - "인스턴스"
  - "자바스크립트"
  - "클래스"
toc: true
toc_sticky: true
date: 2024-07-23
last_modified_at: 2024-07-23
source_url: https://b-note.tistory.com/122
---

<h2>객체 지향 프로그래밍(OOP)</h2>
<p>객체 지향 프로그래밍 (Object Oriented Programming)은 객체를 중심으로 프로그램을 설계하고 구현하는 방법론이다. 자바스크립트에서 OOP는 클래스와 인스턴스, 생성자 함수, 상속 그리고 프로토타입 개념을 통해서 구현된다.</p>

<h2>클래스와 인스턴스</h2>
<p>클래스는 객체를 생성하기 위한 블루프린트 또는 템플릿이다. 클래스는 속성과 메서드를 정의하며, 인스턴스는 클래스를 기반으로 생성된 객체를 의미한다.</p>

<h3>클래스</h3>
<p>ES6 이전에는 자바스크립트에서 클래스를 정의하기 위해 생성자 함수와 프로토타입을 사용했다. 이후에는 'class' 키워드가 추가되어 키워드를 사용하여 클래스를 정의할 수 있게 되었다.</p>

<p><b>클래스 정의</b></p>
<pre class="javascript"><code>class Person {
    constructor(name, age) {
        this.name = name;
        this.age = age;
    }

    greet() {
        console.log(`Hello, my name is ${this.name} and I am ${this.age} years old.`);
    }
}

// 인스턴스 생성
const bak = new Person('Bak', 30);
bak.greet(); // "Hello, my name is Bak and I am 30 years old."</code></pre>

<p><b>생성자 함수</b></p>
<p>생성자 함수는 클래스를 정의하는 전통적인 방법으로 'new' 키워드를 사용하여 생성자 함수를 호출하면 새로운 인스턴스가 생성된다.</p>
<pre class="javascript"><code>function Person(name, age) {
    this.name = name;
    this.age = age;
}

Person.prototype.greet = function() {
    console.log(`Hello, my name is ${this.name} and I am ${this.age} years old.`);
};

// 인스턴스 생성
const bak = new Person('Bak', 25);
bak.greet(); // "Hello, my name is Bak and I am 25 years old."</code></pre>

<h2>상속과 프로토타입</h2>
<p>상속은 한 클래스가 다른 클래스의 속성과 메서드를 상속받아 사용하는 개념이다. 자바스크립트에서는 프로토타입 기반 상속을 사용한다. 자바스크립트의 모든 객체는 프로토타입 객체를 가지고 있으며, 다른 객체로부터 메서드와 속성을 상속받을 수 있다.</p>

<p><b>클래스 상속</b></p>
<p>ES6에서는 'extends' 키워드를 사용하여 상속을 구현할 수 있다.</p>
<pre class="javascript"><code>class Animal {
    constructor(name) {
        this.name = name;
    }

    speak() {
        console.log(`${this.name} makes a noise.`);
    }
}

class Dog extends Animal {
    constructor(name, breed) {
        super(name); // 부모 클래스의 생성자를 호출
        this.breed = breed;
    }

    speak() {
        console.log(`${this.name} barks.`);
    }
}

const rex = new Dog('Rex', 'Labrador');
rex.speak(); // "Rex barks."</code></pre>

<p><b>프로토타입 상속</b></p>
<p>ES6 이전에는 프로토타입을 사용하여 상속을 구현하였다.</p>
<pre class="javascript"><code>function Animal(name) {
    this.name = name;
}

Animal.prototype.speak = function() {
    console.log(`${this.name} makes a noise.`);
};

function Dog(name, breed) {
    Animal.call(this, name); // 부모 생성자 호출
    this.breed = breed;
}

Dog.prototype = Object.create(Animal.prototype);
Dog.prototype.constructor = Dog;

Dog.prototype.speak = function() {
    console.log(`${this.name} barks.`);
};

const rex = new Dog('Rex', 'Labrador');
rex.speak(); // "Rex barks."</code></pre>

<h2>상속의 이점</h2>
<p>상속의 특징을 제대로 이해하고 적절한 상황에 맞게 <span style="text-align: start">활용하는 것이</span> 중요하다.</p>

<h3>코드 재사용성</h3>
<p>상속을 통해 기존 클래스의 기능을 재사용할&nbsp; 수 있기 때문에 이를 통해 중복 코드를 줄이고 새로운 기능을 쉽게 추가할 수 있다.</p>
<pre class="javascript"><code>class Animal {
    constructor(name) {
        this.name = name;
    }

    speak() {
        console.log(`${this.name} makes a noise.`);
    }
}

class Dog extends Animal {
    speak() {
        console.log(`${this.name} barks.`);
    }
}

const dog = new Dog('Rex');
dog.speak(); // "Rex barks."</code></pre>

<p>'Dog' 클래스는 'Animal' 클래스의 'name' 속성과 'speak' 메서드를 재사용하여 기능을 확장한다.</p>

<h3>코드의 가독성과 유지보수성 향상</h3>
<p>상속으로 클래스 간의 관계를 명확히 하고, 코드를 더 구조적이고 일관성 있게 작성하여 코드의 가독성을 높이고 유지보수를 쉽게 할 수 있다.</p>
<pre class="javascript"><code>class Shape {
    constructor(color) {
        this.color = color;
    }

    draw() {
        console.log('Drawing a shape');
    }
}

class Circle extends Shape {
    constructor(color, radius) {
        super(color);
        this.radius = radius;
    }

    draw() {
        super.draw();
        console.log(`Drawing a circle with radius ${this.radius}`);
    }
}

const circle = new Circle('red', 5);
circle.draw();
// "Drawing a shape"
// "Drawing a circle with radius 5"</code></pre>

<p>'circle' 클래스는 'shape' 클래스를 상속받아 'color' 속성과 'draw' 메서드를 재사용하고 필요한 기능을 추가한다. 이를 통해서 코드가 더 구조적이고 명확해지도록 할 수 있다.</p>

<h3>다형성(Polymorphism)</h3>
<p>다형성은 같은 메서드가 다양한 클래스에서 다른 방식으로 동작하도록 하는 것으로 코드의 유연성을 높일 수 있다.</p>
<pre class="javascript"><code>class Animal {
    speak() {
        console.log('Animal makes a noise');
    }
}

class Dog extends Animal {
    speak() {
        console.log('Dog barks');
    }
}

class Cat extends Animal {
    speak() {
        console.log('Cat meows');
    }
}

function makeAnimalSpeak(animal) {
    animal.speak();
}

const dog = new Dog();
const cat = new Cat();

makeAnimalSpeak(dog); // "Dog barks"
makeAnimalSpeak(cat); // "Cat meows"</code></pre>

<p>'makeAnimalSpeak' 함수는 'Animal' 클래스를 상속받는 객체를 인수로 받아 다형성을 통해 다양한 동작을 수행할 수 있다.</p>

<h3>클래스 간의 계층 구조 정의</h3>
<p>상속 구조는 클래스 간의 계층 구조를 정의할 수 있어 복잡한 시스템을 더 쉽게 이해하고 관리할 수 있다.</p>
<pre class="javascript"><code>class Vehicle {
    constructor(brand) {
        this.brand = brand;
    }

    start() {
        console.log('Starting the vehicle');
    }
}

class Car extends Vehicle {
    constructor(brand, model) {
        super(brand);
        this.model = model;
    }

    start() {
        super.start();
        console.log(`Starting the car ${this.brand} ${this.model}`);
    }
}

const car = new Car('Toyota', 'Corolla');
car.start();
// "Starting the vehicle"
// "Starting the car Toyota Corolla"</code></pre>

<p>'vehicle' 클래스는 기본적인 차량의 속성과 메서드를 정의하고, 'Car' 클래스는 이를 상속받아 구체적인 차량 모델을 정의한다. 이는 클래스 간의 관계를 명확히 하고 계층 구조를 쉽게 이해할 수 있다.</p>

<h3>객체 간의 관계 모델링</h3>
<p>상속을 사용하면 객체 간의 관계를 모델링하여 복잡한 시스템을 설계하고 구현하는 데 유용하다.</p>
<pre class="javascript"><code>class Employee {
    constructor(name, position) {
        this.name = name;
        this.position = position;
    }

    work() {
        console.log(`${this.name} is working as a ${this.position}`);
    }
}

class Manager extends Employee {
    constructor(name, department) {
        super(name, 'Manager');
        this.department = department;
    }

    manage() {
        console.log(`${this.name} is managing the ${this.department} department`);
    }
}

const manager = new Manager('Bak', 'Sales');
manager.work(); // "Bak is working as a Manager"
manager.manage(); // "Bak is managing the Sales department"</code></pre>

<p>'manager' 클래스는 'Employee' 클래스를 상속받아 관리자의 속성과 메서드를 정의하여 객체 간의 관계를 명확히 모델링할 수 있다.</p>

<p>상속은 객체 지향 프로그래밍에서 매우 유용한 개념이지만 과도하게 또는 잘못된 방식으로 사용하게 되면 오히려 코드의 복잡성을 증가시켜 유지보수를 어렵게 만들 수 있다.</p>
