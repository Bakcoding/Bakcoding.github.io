---
title: "메모리"
excerpt: "메모리"
categories:
  - ComputerEngineering
permalink: /computer-science/engineering/25-post/
tags:
  - "Computer Engineering"
  - "Computer Science"
  - "Memory"
  - "기억장치"
  - "메모리"
toc: true
toc_sticky: true
date: 2023-03-17
last_modified_at: 2023-03-17
source_url: https://b-note.tistory.com/25
---

<h3>메모리</h3>
<p>컴퓨터 메모리는 시스템의 핵심 구성 요소 중 하나이다.</p>
<p>데이터와 명령어를 저장하고 CPU와 상호 작용하여 프로그램 실행을 가능하게 한다.</p>

<p>컴퓨터 메모리에는 다양한 종류가 있으며 각기 다른 용도와 특성을 가지고 있다.&nbsp;</p>
<p><figure class="imageblock alignCenter" data-ke-mobileStyle="widthOrigin" data-filename="496px-Memory_hierarchy.svg.png" data-origin-width="496" data-origin-height="390"><span data-alt="Memory Layount"><img src="/assets/images/posts/2023/03/17/25-1.png" loading="lazy" width="496" height="390" data-filename="496px-Memory_hierarchy.svg.png" data-origin-width="496" data-origin-height="390"/></span><figcaption>Memory Layount</figcaption>
</figure>
</p>
<h4>1. 주기억장치(Primary Memory)</h4>
<p>컴퓨터의 메인 메모리로 RAM과 ROM이 포함된다.</p>
<p>주기억장치는 CPU와 직접 통신하며 빠른 속드를 요구한다.&nbsp;</p>

<p>RAM</p>
<p>임시 데이터 저장소로, 읽기와 쓰기가 모두 가능한 메모리이다. 컴퓨터가 켜질 때마다 프로그램과 데이터가 RAM에 로드되며, 전원이 꺼지면 RAM의 데이터는 사라진다.</p>

<p>ROM</p>
<p>시스템의 기본 설정 및 부팅 과정에서 사용되는 정보를 저장하는 메모리이다. 일반적으로 읽기만 가능하며, 데이터는 전원이 꺼져도 유지된다.</p>

<h4>2. 보조기억장치(Secondary Memory)</h4>
<p>데이터를 영구적으로 저장하는 메모리로, 하드 드라이브, SSD, CD, DVD 등이&nbsp; 포함된다. 보조기억장치는 주기억장치보다 느리지만, 대용량의 데이터를 저장할 수 있다.</p>

<h3>계층 구조(Memory Hierachy)</h3>
<p>메모리 계층 구조는 컴퓨터 시스템에서 사용되는 다양한 메모리 기술을 속도, 용량, 비용, 접근 시간 등의 특성에 따라 계층적으로 구성한것이다.</p>
<p>계층 구조는 데이터를 처리하고 저장할 때 발생하는 효율성과 성능의 균형을 이루기 위해 만들어졌다.</p>

<p>1. 레지스터(Register)&nbsp;</p>
<p>CPU 내부에 위치한 가장 빠르고 작은 메모리</p>
<p>연산에 직접 사용되는 데이터와 주소를 저장한다.</p>

<p>2. 캐시 메모리(Cache Memory)</p>
<p>CPU에 가까운 고속의 작은 메모리</p>
<p>주기억장치에서 자주 사용되는 데이터와 명령어를 저장해, CPU의 성능 향상을 도모한다. 캐시 메모리는 종종 여러 레벨로 구성되기도 한다.</p>

<p>3. 주기억장치(Primary Memory)</p>
<p>RAM과 ROM으로 구성된 메모리로 CPU가 직접 접근할 수 있는 메모리이다.</p>
<p>RAM은 주로 프로그램 실행에 필요한 데이터와 명령어를 저장하고 ROM은 시스템 부팅과 관련된 정보를 저장한다.</p>

<p>4. 보조기억장치(Secondary Menory)</p>
<p>하드 드라이브, SSD, CD, DVD 등으로 구성된 대용량의 영구적인 저장장치이다. 주기억장치보다 느리지만 대영량 대이터를 저장할 수 있다.</p>

<p>5. 오프라인 저장 장치(Offline Storage)</p>
<p>테이프 드라이브, 광학 저장 매체 등을 포함하는 컴퓨터 시스템과 직접 연결되지 않은 저장 장치이다. 백업과 아카이빙에 주로 사용된다.</p>

<p>6.</p>
