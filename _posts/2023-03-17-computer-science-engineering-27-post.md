---
title: "데이터 경로와 제어 유닛"
excerpt: "데이터 경로와 제어 유닛"
categories:
  - ComputerEngineering
permalink: /computer-science/engineering/27-post/
tags:
  - "Computer Engineering"
  - "Computer Science"
  - "Control"
  - "data"
  - "path"
  - "Unit"
toc: true
toc_sticky: true
date: 2023-03-17
last_modified_at: 2023-03-17
source_url: https://b-note.tistory.com/27
---

<h3>데이터 경로(Data Path)</h3>
<p>데이터 경로는 프로세서 내에서 데이터가 이동하는 통로를 뜻한다.</p>
<p>프로세서 내에서 데이터가 이동하고 처리되는 구성 요소들과 이들 간의 연결을 말하며 데이터 경로는 컴퓨터가 명령어를 실행하는 과정에서 필요한 연산을 수행하고, 결과를 저장하는 데 사용된다. 레지스터, ALU, 다양한 버스 등으로 구성되어있으며 데이터 경로의 구성 요소와 연결 방식은 프로세서의 성능과 효율에 큰 영향을 미친다.</p>
<h4>1. 레지스터</h4>
<p>데이터 경로 내에서 데이터를 임시로 저장하는 작은 메모리이다.</p>
<p>레지스터는 데이터를 빠르게 처리할 수 있도록 돕고 ALU와 같은 다른 구성 요소들과 데이터를 교환한다.</p>

<h4>2. 산술 논리 연산 장치(ALU, Arithmetic Logic Unit)</h4>
<p>ALU는 데이터 경로에서 가장 중요한 연산을 수행하는 구성 요소이다. 산술 연산(덧셈, 뺄셈, 곱셈, 나눗셈 등) 및 논리 연산(AND, OR, NOT, XOR 등)을 처리한다.</p>

<h4>3. 버스(Bus)</h4>
<p>버스는 프로세서 내에서 레지스터, ALU, 메모리 등의 구성 요소들 간에 데이터를 전송하는 통로이다. 버스는 주로 데이터 버스, 주소 버스, 제어 버스로 구분된다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="512" data-origin-height="633"><span data-alt="Data Path"><img src="/assets/images/posts/2023/03/17/27-1.jpg" loading="lazy" width="512" height="633" data-origin-width="512" data-origin-height="633"/></span><figcaption>Data Path</figcaption>
</figure>
</p>
<h4>데이터 경로 동작</h4>
<p>1. 명령어 가져오기(Fetch)</p>
<p>&nbsp; &nbsp; 프로그램 카운터가 가리키는 메모리 위치에서 명령어를 가져온다.</p>

<p>2. 명령어 디코딩(Decode)</p>
<p>&nbsp; &nbsp; 제어 유닛이 가져온 명령어를 분석하여 해당 연산을 수행하는 데 필요한 제어 신호를 생성한다.</p>

<p>3. 피연산자 가져오기(Operand Fetch)</p>
<p>&nbsp; &nbsp; 디코딩된 명령어에 따라 필요한 피연산자를 레지스터 또는 메모리에서 가져온다.</p>

<p>4. 연산 수행(Execute)</p>
<p>&nbsp; &nbsp; ALU가 피연산자를 사용하여 명령어에서 지정한 연산을 수행한다.</p>

<p>5. 결과 저장(Store)</p>
<p>&nbsp; &nbsp; 연산 결과를 레지스터 또는 메모리에 저장한다.</p>

<p>데이터 경로의 구성과 동작 방식은 프로세서의 성능과 효율성에 결정적인 영향을 미치기 때문에 효율적인 데이터 경로 설계를 통해 프로세서의 처리 속도를 높이고 전력 소모를 줄일 수 있다.</p>
<p><i>#파이프라이닝 #슈퍼스칼라 #VLIW(Very Long Instruction Word)</i></p>

<h3>제어 유닛(Control Unit)</h3>
<p>CPU 내에 위치하며 명령어를 해석하고 필요한 연산을 수행하기 위해 필요한 제어 신호를 생성하는 역할을 한다.</p>
<p>명령어 실행 과정에서 데이터 경로의 구성 요소들을 제어함으로써 프로세서의 전체 동작을 조율한다.</p>
<p><span style="color: #333333; text-align: start;">동작은 데이터 경로와 비슷한 단계를 거친다.<span>&nbsp;</span></span></p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-filename="control_bus.png" data-origin-width="479" data-origin-height="343"><span><img src="/assets/images/posts/2023/03/17/27-2.png" loading="lazy" width="479" height="343" data-filename="control_bus.png" data-origin-width="479" data-origin-height="343"/></span></figure>
</p>
<p>1. 명령어 가져오기(Fetch)</p>

<p>2. 명령어 디코딩(Decode)</p>

<p>3. 제어 신호 생성(Control Signal Generation)</p>
<p>디코딩된 명령어를 기반으로 데이터 경로 내 구성 요소들을 제어하기 위한 신호를 생성한다. 이 신호들은 레지스터,&nbsp; &nbsp; ALU, 메모리 등과 같은 구성 요소들을 제어하여 명령어를 실행하는 데 필요한 동작을 수행하도록 한다.</p>

<p>제어 유닛은 명령어 집합 구조(ISA)를 기반으로 작동하며 ISA에 따라 다양한 연산들을 처리할 수 있다. 일반적으로 제어 유닛은 하드웨어 또는 마이크로프로그램 방식으로 구현된다.</p>

<p>하드웨어 제어 유닛</p>
<p>디코딩 논리 회로를 사용하여 명령어를 직접 해석하고 제어 신호를 생성하는 방식이다.&nbsp;</p>
<p>이 방식은 빠른 처리 속도를 가지지만 회로 복잡성이 높고 유연성이 떨어진다.</p>

<p>마이크로프로그램 제어 유닛</p>
<p>명령어를 해석하고 제어 신호를 생성하기 위해 내부적으로 사용하는 작은 프로그램인 마이크로코드를 실행하는 방식이다. 회로 설계가 단순하고 유연하지만 처리 속도가 하드웨어 제어 유닛에 비해 상대적으로 느리다.</p>
