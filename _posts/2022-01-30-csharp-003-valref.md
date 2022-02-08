---
title:  "값타입과 참조타입"
excerpt: "csharp, val, ref"

categories:
  - CSharp
tags:
  - [csharp, val, ref]

toc: true
toc_sticky: true
 
date: 2022-01-30 
last_modified_at: 2022-01-30
---


### 값, 참조 타입

C#에는 크게 값 타입(Value type)과 참조 타입(Reference type)이 있다. 

<br>

#### 값 타입(Value type) 

스택에 할당되며 변수가 값 자체를 직접 가지고 있다.  

정수, 문자, 실수 등의 내장 타입과 열거형, 구조체 등 크기가 작고 길이가 고정적인 값들을 저장한다.  

변수를 선언하는 즉시 메모리가 할당되므로 별도의 초기화 없이 값을 저장하고 대입할 수 있다.

<br>

기본적으로 제공되는 내장 자료형은 대부분 값 타입이다. 

**Built-in datatype**  

|자료형|형식|범위|크기|
|------|----|----|----|
|sbyte|System.SByte|-128 ~ 127|부호 있는 8bit 정수|
|byte|System.Byte|0 ~ 255|부호 없는 8bit 정수|
|short|System.Int16|-32,768 ~ 32,767|부호 있는 16bit 정수|
|ushort|System.UInt16|0 ~ 65,535|부호 없는 16bit 정수|
|int|System.Int32|-2,147,483,648 ~ 2,147,483,647|부호 있는 32bit 정수|
|uint|System.UInt32|0 ~ 4,294,967,295|부호 없는 32bit 정수|
|long|System.Int64|-9,223,372,036,854,775,808 ~ 9,223,372,036,854,775,808|부호 있는 64bit 정수|
|ulong|System.UInt64|0 ~ 18,446,744,073,709,551,615|부호 없는 64bit 정수|
|float|System.Single|±1.5e-45 ~ ±3.4e38|4 byte|
|double|System.Double|±5.0e-324 ~ ±1.7e308|8 byte|
|decimal|System.Decimal|±1.0 × 10<sup>−28</sup>  ±7.9 × 10<sup>28</sup>|16 byte|
|char|System.Char|U+0000 ~ U+ffff|유니코드 16bit 문자|
|string|System.String||유니코드 문자열|
|bool|System.Boolean||4byte|

<br>

**User defined datatype** 

* Struct(구조체)

* Enumeration(열거형)

#### 참조 타입(Reference type)

값 자체를 가지는 것이 아닌 값이 저장된 위치만 가진다.  

선언 후 곧바로 사용할 수 없으며 힙에 메모리를 할당하는 초기화 과정이 필요하다.  

변수의 실제 값은 할당된 힙에 저장되고 이 메모리는 가비지 컬렉터에 의해 자동으로 관리된다.  

문자열, 클래스, 배열 등 용량이 크고 가변적인 타입들이 참조형이된다.  

<br>

**built-in datatype**

* object

* string

* delegate

* dynamic

주의할점은 string 이 참조형이란 점이다. 

string은 수정 불가능한 타입으로 주어진 string 값을 변경을 시도하면 새로운 문자열을 할당하고 그 메모리 주소를 넘겨받는 방식으로 되어있기 때문에 하나의 string 객체로 많은 문자열을 수정하는 작업을 한다면 오버헤드가 걸리게 된다.  

따라서 대안으로 stringBuiler 클래스를 사용하기도 한다.

<br>

**User defined datatype**  

* class

* interface

* record