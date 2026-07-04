---
title: "CPU"
excerpt: "CPU"
categories:
  - ComputerEngineering
permalink: /computer-science/engineering/24-cpu/
tags:
  - "Computer Engineering"
  - "Computer Science"
  - "Component"
  - "CPU"
  - "구성요소"
  - "레지스터"
  - "메모리"
  - "연산 유닛"
  - "제어 유닛"
toc: true
toc_sticky: true
date: 2023-03-17
last_modified_at: 2023-03-17
source_url: https://b-note.tistory.com/24
---

<h3>CPU</h3>
<p>컴퓨터 시스템을 구성하는 요소는 다양하며, 각각의 구성요소들이 상호 작용을 통해서 전체 시스템이 동작하게 된다.</p>
<p>그 중 중앙 처리 장치(CPU, Central Processing Unit)는 컴퓨터 시스템에서 가장 중요한 부품 중 하나이다.</p>

<h3>구성요소</h3>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-filename="CPU_Strut.png" data-origin-width="576" data-origin-height="317"><span><img src="/assets/images/posts/2023/03/17/24-1.png" loading="lazy" width="576" height="317" data-filename="CPU_Strut.png" data-origin-width="576" data-origin-height="317"/></span></figure>
</p>
<p>연산 유닛(Arithmetic Logic Unit, ALU)</p>
<p>산술 및 논리 연산을 수행한다. 덧셈, 뺄셈, 곱셈, 나눗셈 같은 산술 연산과 AND, OR, NOT, XOR과 같은 논리 연산을 처리한다.</p>

<p>제어 유닛(Control Unit, CU)</p>
<p>메모리에서 명령어를 가져와 해독하고 실행한다. 또한 다른 구성요소들을 제어하여 명령어 실행에 필요한 데이터를 제공하거나 결과를 저장한다.</p>

<p>레지스터(Register)</p>
<p>CPU 내부의 작은 기억장치이다. 매우 빠른 접근 속도를 가지고 연산에 필요한 데이터를 저장하거나 중간 결과를 저장하는데 사용된다. 종류는 크게 범용, 프로그램 카운터, 명령, 주소 레지스터 등이 있다.</p>

<p>캐시 메모리(Cache Memory)</p>
<p>캐시 메모리는 CPU와 주 기억장치 사이에 위치하며 자주 사용되는 데이터와 명령어를 빠르게 접근할 수 있도록 저장한다. 캐시 메모리는 CPU 성능을 향상시키는 데 중요한 역할을 한다.</p>

<h3>명령어 주기</h3>
<p>CPU는 명령어 주기를 통해 작동한다.</p>
<p>1. 인출(Fetch) : 메모리에서 명령어를 가져오는 단계</p>
<p>2. 해독(Decode) : 가져온 명령어를 해독하여 실행할 동작을 결정하는 단계</p>
<p>3. 실행(Execute) :&nbsp; 해독된 명령어를 실행하는 단계</p>
<p>4. 저장(Store) :&nbsp; 실행 결과를 레지스터나 메모리에 저장하는 단계</p>

<h3>성능</h3>
<p>CPU의 성능은 클럭 속도, 코어 수, 캐시 크기, 명령어 집합 구조(ISA) 등 다양한 요소에 의해 영향을 받는다. 클럭 속도는 CPU가 초당 처리할 수 있는 명령어의 수를 나타내며, 코어 수는 동시에 처리할 수 있는 명령어 스트림의 수를 의미한다. 캐시 크기는 CPU와 메모리 사이에 위치한 고속 메모리의 용량을 나타내며, 명령어 집합 구조는 CPU가 어떤 종류의 명령어를 처리할 수 있는지를 결정한다.</p>

<p>다중 코어 프로세서와 파이프라이닝, 병렬 처리 등의 기술을 통해 성능을 향상시킬 수 있으며 이러한 기술은 동시에 여러 작업을 처리하거나 여러 단계로 구성된 작업을 동시에 진행함으로써 전체 시스템의 처리 속도를 높일 수 있다.</p>
