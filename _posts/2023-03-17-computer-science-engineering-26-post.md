---
title: "명령 사이클과 명령어 집합 구조"
excerpt: "명령 사이클과 명령어 집합 구조"
categories:
  - ComputerEngineering
permalink: /computer-science/engineering/26-post/
tags:
  - "Computer Engineering"
  - "Computer Science"
  - "cycle"
  - "ISA"
toc: true
toc_sticky: true
date: 2023-03-17
last_modified_at: 2023-03-17
source_url: https://b-note.tistory.com/26
---

<h3>명령 사이클(Instruction Cycle)</h3>
<p>CPU가 명령어를 수행하는 과정을 의미한다. 일반적으로 명령 사이클은 여러 단계로 이루어져 있다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-filename="cpu_cycle.png" data-origin-width="431" data-origin-height="348"><span><img src="/assets/images/posts/2023/03/17/26-1.png" loading="lazy" width="431" height="348" data-filename="cpu_cycle.png" data-origin-width="431" data-origin-height="348"/></span></figure>
</p>
<h4>1. 인출(Fetch)</h4>
<p>메모리에서 프로그램 카운터에 저장된 주소의 명령어를 가져온다. 그 다음 프로그램 카운터를 다음 명령어의 주소로 업데이트한다.</p>

<h4>2. 디코딩(Decode)</h4>
<p>명령어를 분석하여 해당하는 작업을 파악하고 필요한 피연산자를 결정한다.</p>

<h4>3. 실행(Execute)</h4>
<p>분석된 명령어와 연관된 작업을 수행하고 결과를 생성한다.</p>

<h4>4. 저장(Store)</h4>
<p>연산 결과를 레지스터 또는 메모리에 저장한다.</p>

<p>CPU는 위 사이클을 프로그램이 실행되는 동안 반복하며 각 명령어가 수행되는 순서대로 진행한다.</p>

<h3>명령어 집합 구조(Instruction Set Architecture, ISA)</h3>
<p>컴퓨터의 하드웨어와 소프트웨어 사이의 인터페이스를 정의한다. ISA는 하드웨어가 지원하는 명령어들의 집합, 데이터 유형, 레지스터, 메모리 주소 지정 방식, 입출력 관리 등에 대한 규칙과 규격을 제공한다. ISA는 컴퓨터 아키텍처의 핵심 구성 요소로 컴파일러와 운영 체제가 하드웨어와 상호 작용하는 방식을 결정한다.&nbsp;컴퓨터는 다양한 아키텍처가 존재하며 각각의 아키텍처는 고유한 ISA를 가지고 있다.</p>

<p>ISA는 프로세서와 소프트웨어 간의 인터페이스 역할을 한다.<b></b></p>
<ul style="list-style-type: disc">
<li>명령어 집합 : 프로세서가 인식하고 수행할 수 있는 기본 명령어 집합</li>
<li>레지스터 파일 : 프로세서 내부에 있는 레지스터들의 집합</li>
<li>메모리 접근 방식 : 프로세서가 메모리에 접근하는 방법 정의</li>
<li>입출력 방식 : 프로세서와 외부 장치 간의 데이터 교환 방식을 정의</li>
<li>인터럽트 및 예외 처리 : 프로세서가 예외 상황이 발생했을 때 처리하는 방식 정의</li>
</ul>
