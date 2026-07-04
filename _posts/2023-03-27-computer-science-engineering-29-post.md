---
title: "아키텍처"
excerpt: "아키텍처"
categories:
  - ComputerEngineering
permalink: /computer-science/engineering/29-post/
tags:
  - "Computer Engineering"
  - "Computer Science"
  - "Architecture"
  - "아키텍처"
toc: true
toc_sticky: true
date: 2023-03-27
last_modified_at: 2023-03-27
source_url: https://b-note.tistory.com/29
---

<h2>Architecture</h2>
<p>하드웨어와 소프트웨어의 구성 요소, 기능, 상호작용 등을 설계하고 구성하는 방식이나 규칙으로 컴퓨터 시스템 전반에 대한 설계와 구조를 의미한다.</p>

<h3>Von Neumann Architecture</h3>
<p>폰 노이만 아키텍처</p>
<p>1940년대 말에 알렌 튜링과 존 폰 노이만 등이 제안한 아키텍처로 컴퓨터 시스템의 아키텍처 중 가장 널리 사용되는 구조 중 하나이다. 현대 컴퓨터 시스템의 대부분이 이 아키텍처를 기반으로 설계되었다.</p>
<p><figure class="imageblock alignCenter" data-ke-mobileStyle="widthOrigin" data-filename="von_neumann.png" data-origin-width="591" data-origin-height="234"><span><img src="/assets/images/posts/2023/03/27/29-1.png" loading="lazy" width="591" height="234" data-filename="von_neumann.png" data-origin-width="591" data-origin-height="234"/></span></figure>
</p>
<p>Von Neumann 아키텍처는 메모리, CPU, 입/출력 장치, 버스 등의 하드웨어 요소로 구성되며 이 중에서 CPU가 가장 핵심적인 구성 요소이다. CPU는 명령어를 순차적으로 처리하며, 프로그램의 명령어를 주기억장치에서 읽어와서 해석하고 실행한다. 따라서 명령어와 데이터를 모두 주기억장치에 저장하고 명령어와 데이터를 순차적으로 읽어오는 방식을 사용한다.&nbsp;이를 '프로그램과 데이터의 저장공간이 동일하다'라는 의미에서 '단일 저장 장치(Single Memory)'라고 한다.</p>

<p>명령어와 데이터를 같은 메모리 공간에 저장하기 때문에 명령어와 데이터의 접근 시간이 동일하다는 것으로 명령어와 데이터를 주기억장치에서 읽어오는 시간이 줄어들어 전체적인 성능을 향상시킬 수 있다. 또한 프로그램의 수정이나 변형이 용이하다는 장점을 가진다. 하지만 주기억장치와 CPU 사이의 데이터 전송이 병목현상을 유발할 수 있으며 이를 해결하기 위해 캐시 메모리 등의 보조 기억장치를 사용하는 등의 방법이 고안되었다.&nbsp;</p>

<h3>Havard Architecture</h3>
<p>하버드 대학에서 개발되었다는 것에서 이름이 유래되었다.</p>
<p>Von Neumann 아키텍처와 달리 프로그램과 데이터가 동일한 메모리 공간에 저장되지 않고 각각 다른 메모리 공간에 저장한다. 이러한 구조를 가지는 컴퓨터 시스템은 두 개의 메모리 버스를 사용한다. 하나는 프로그램을 저장하는 코드 메모리 버스이고, 다른 하나는 데이터를 저장하는 데이터 메모리 버스이다. 이 두 개의 버스는 병렬로 동작하여 CPU가 동시에 코드와 데</p>
<p><figure class="imageblock alignCenter" data-ke-mobileStyle="widthOrigin" data-filename="Harvard_Architecture.png" data-origin-width="653" data-origin-height="274"><span><img src="/assets/images/posts/2023/03/27/29-2.png" loading="lazy" width="653" height="274" data-filename="Harvard_Architecture.png" data-origin-width="653" data-origin-height="274"/></span></figure>
</p>
<p>이터를 읽을 수 있도록 한다.</p>

<p>이 아키텍처의 장점은 프로그램과 데이터가 각각 다른 메모리 공간에 저장되기 때문에 프로그램과 데이터를 동시에 읽을 수 있다. 따라서 프로그램 실행 시간이 더욱 빨라진다. 그리고 프로그램과 데이터를 분리하여 저장하기 때문에 데이터의 비인가된 접근을 막을 수 있어 보안성이 Von Neumann 아키텍처보다 높다. 하지만 각각 다른 메모리 공간에 저장되어 있기 때문에 프로그램 수정 시 코드 메모리와 데이터 메모리를 모두 수정해야하기 때문에 프로그램의 수정이나 변형이 불편하며 이러한 구조를 가지는 컴퓨터 시스템은 하드웨어 구조가 복잡하다.</p>

<p>Von Neumann 아키텍처와 Harvard 아키텍처 두 아키텍처의 차이는 명령어와 데이터를 메모리에서 어떻게 처리하느냐에 따라 달라지며, 이는 컴퓨터 아키텍처의 성능과 기능을 결정한다.&nbsp;</p>

<h3>Instruction Set Architecture(ISA)</h3>
<p>명령어 세트 아키텍처</p>
<p>컴퓨터에서 실행되는 명령어 집합과 해당 명령어의 동작을 정의하는 인터페이스 즉, 소프트웨어 개발자와 하드웨어 엔지니어 사이의 인터페이스 역할을 한다.</p>

<p>명령어 세트 아키텍처는 프로그래밍 언어와 컴퓨터 아키텍처 사이의 중개자 역할을 하며, 어떤 프로그래밍 언어를 사용하더라도 ISA에서 정의된 명령어 집합을 사용하여 작성된 프로그램은 모든 ISA 호환 컴퓨터에서 실행될 수 있다. 또한 ISA는 명령어의 크기, 명령어의 수행 방법, 레지스터의 개수와 종류, 주소 지정 방식 등과 같은 하드웨어 구성 요소를 규정하여, 하드웨어 제조업체들이 ISA를 준수하여 호환성을 보장할 수 있도록 한다.</p>
<h4>RISC</h4>
<p><b>Reduced instruction Set Computing&nbsp;</b></p>
<p>명령어의 수를 줄이고 명령어 실행 시간을 일정하게 유지하는 것에 초점을 두고 설계된 아키텍처이다.</p>
<h4>CISC</h4>
<p><b>Complex Instruction Set Computing</b></p>
<p><span><span>&nbsp;</span>복잡한 명령어 집합과 다양한 주소 지정 방식 등을 지원하여 프로그래머가 작성한 코드의 길이를 줄이고 복잡한 작업을 더 쉽게 처리할 수 있도록 설계되었다.</span></p>

<h3>Microarchitecture</h3>
<p>ISA에서 정의된 명령어 세트를 하드웨어로 구현하는 방법에 대한 아키텍처이다. 마이크로 아키텍처는 ISA와 하드웨어 구현 사이의 중간 계층으로 ISA에 정의된 명령어 세트를 하드웨어에서 처리하기 위한 방법과 기술적인 세부 사항을 다룬다.</p>

<p>마이크로 아키텍처는 CPU의 내부 동작 방식을 설명하며 ALU, 레지스터, 캐시 등과 같은 하드웨어 요소들이 어떻게 조합되어 명령어를 실행하는지를 나타낸다. 이는 프로세서의 처리 속도와 성능에 직접적인 영향을 미친다.</p>

<p>예를 들어 Intel의 x86 아키텍처는 하나의 ISA를 여러 가지 버전의 마이크로 아키텍처를 통해 구현하는 방법이 다르며 이러한 버전에는 Pentium, Core, Atom 등이 있다.</p>

<p>ISA와 달리 마이크로 아키텍처는 하드웨어에 종속적이며 같은 ISA를 가진 두 개의 CPU라 하더라도 각각의 마이크로 아키텍처에 따라서 성능과 기능이 달라진다. 이러한 이유로 마이크로 아키텍처는 하드웨어 설계자들이 CPU를 개발할 때 매우 중요한 역할을 한다.</p>
<h4>VLIW</h4>
<p>Very Long Instruction Word Architecture</p>
<p>하나의 명령어로 여러 개의 연산 명령어들을 패킹하여 동시에 처리하는 방식을 사용하는 마이크로 아키텍처이다.</p>
<p>각 연산 명령어의 종류와 크기는 사전에 고정되어 있어야 하며 이렇게 하나의 명령어에 여러 개의 연산 명령어를 패킹하면 하나의 명령어를 실행하는데 필요한 클럭 사이클 수를 줄 일 수 있어 실행 효율성이 높아진다.</p>

<p>하지만 이러한 패킹 작업이 복잡하고 명령어에 들어갈 연산 명령어의 종류와 크기를 고정해야 하기 때문에 하드웨어 구현이 복잡해지고 설계 및 프로그래밍이 어렵다.</p>

<p>EPIC</p>
<p>Explicitly Parallel Instruction Computing</p>
<p>인텔에서 개발한 아키텍처로 VLIW의 한 종류이다. 명령어와 함께 해당 명령어를 실행하기 위한 하드웨어 리소스를 명시적으로 지정하여 병렬 처리를 구현한다. 이를 위해 명령어를 여러 개 묶어 하나의 Attention Point로 지정하고 해당 포인트에서 동시에 실행 가능한 명령어를 실행하는 방식을 사용한다. 이를 통해 프로그램 내의 병렬 처리 가능한 부분을 미리 식별하여 처리할 수 있기 때문에 성능 향상을 기대할 수 있다.</p>

<p>대표적인 예시로 인텔의 Itanium 프로세서가 있다. 명령어 세트가 복잡하고 처리 방식이 복잡하기 때문에 초기에는 호환성 문제 등으로 실패했지만 대용량 데이터 처리 등에서 높은 성능을 발휘하였다. 그러나 x86 아키텍처에 비해 생태계가 덜 발달하고 소프트웨어 호환성 문제도 있어 현재는 사용되지 않고 있다.</p>


<h4>SIMD</h4>
<p>Single Instruction Multiple Data</p>
<p>여러 개의 데이터가 동시에 처리하기 때문에 대규모 데이터 병렬 처리에 유리하다.</p>
<p>벡터 프로세싱이라고도 불리며 벡터 레지스터라는 별도의 레지스터를 사용하여 데이터를 저장하고 벡터 명령어를 사용하여 데이터를 처리한다.&nbsp;</p>

<p>예를 들어 4개의 데이터를 더하는 연산을 할때 일반적으로 4번의 덧셈 연산을 수행해야 하지만 SIMD 아키텍처에서는 한 번의 명령어로 4개의 데이털르 한꺼번에 연산할 수 있다. 따라서 SIMD 아키텍처는 더 빠르고 효율적인 데이터 처리가 가능하기 때문에 그래픽 카드나 디지털 신호 처리 등의 분야에서 많이 사용된다.</p>

<p>Intel의 MMX, SSE, AVX, ARM의 NEON 등이 이 아키텍처를 기반으로 한다.</p>
