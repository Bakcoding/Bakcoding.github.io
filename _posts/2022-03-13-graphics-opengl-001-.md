---
title:  "OpenGL"
excerpt: "Graphics, OpenGL"

categories:
  - OpenGL
tags:
  - [Graphics, OpenGL]

toc: true
toc_sticky: true
 
date: 2022-03-13
last_modified_at: 2022-03-13
---  

***

<br>

### OpenGL

Open Graphics Library

컴퓨터 그래픽을 하드웨어 가속으로 처리(렌더링)함과 더불어 다양한 분야에서 사용될 수 있도록 Khronos Group에서 발표한 라이브러리이다. 

OpenGL 이전에도 솔루션이 존재했지만 여러 OS에서 사용할 수 있도록 범용성과 독립성이 고려되지 않았기 때문에 제약이 있었다.

<br>

Khronos Group은 대부분 그래픽 카드 제조업체로 구성되어있다. 

OpenGL은 해당 그래픽 카드를 제어하기 위한 구현에 대한 spcification이다.  

즉 추상화되어있는 OpenGL이 있고 그것을 구현하는것이 개발자의 몫이다. 

<br>

### API?

OpenGL을 찾아보면 API라는 말이 따라온다. 

그래픽 카드 개발자가 자신의 드라이버를 위한 API를 만들 수 있도록 정한 규격이 OpenGL인 셈이다.  

즉 OpneGL을 구현하면 그래픽 카드의 해당 드라이버에서 제공하는 API를 통해서 접근이 이루어지며 이 때 개발자가 그래픽 카드의 종류별로 코드를 작성할 필요없도록 공통된 인터페이스를 생성해 주기 때문에 OpenGL이 API인가에 대해서는 의견이 다른 글들을 찾아볼 수 있다. 

<br>

### 특징

* 범용성

* 효율성

* 독립성

* 완전성

* 상호작업성

OpenGL 자체는 C기반으로 제작되었지만 크로스 플랫폼을 지향하며 어떤 OS나 프로그래밍 언어에서 사용할 수 있다. 

라이브러리를 다운받고 IDE를 추가하여 include를 통해 사용할 수 있다.
