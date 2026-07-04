---
title: "OS"
excerpt: "OS"
categories:
  - ComputerEngineering
permalink: /computer-science/engineering/30-os/
tags:
  - "Computer Engineering"
  - "Computer Science"
  - "CPU"
  - "FCFS"
  - "Frament"
  - "Management"
  - "Memory"
  - "OS"
  - "priority"
  - "Round-Robin"
  - "Schedulling"
  - "SJF"
toc: true
toc_sticky: true
date: 2023-03-28
last_modified_at: 2023-03-28
source_url: https://b-note.tistory.com/30
---

<h3>Operating System</h3>
<p><b>운영체제</b></p>
<p>운영체제는 컴퓨터 시스템의 CPU, 메모리, 입출력 장치, 저장 장치 등의 자원을 효율적으로 관리하고 다른 소프트웨어나 사용자가 이용할 수 있도록 관리하는 인터페이스 역할을 하는 소프트웨어를 말한다.&nbsp;</p>

<h3>Resource Management</h3>
<p>자원관리, 운영체제는 컴퓨터의 자원을 효율적으로 관리하고 할당하는 역할을 한다.</p>
<p>대표적인 자원으로는 CPU, 메모리, 저장장치, 입출력 장치가 있다.</p>

<h3>CPU</h3>
<p>프로세스 스케줄링을 통해 CPU 자원을 할당하고 여러 프로세스 간의 경쟁 상황을 해결한다.</p>
<p>CPU를 효율적으로 사용하기 위해 실행 중인 여러 프로세스들 사이에서 CPU의 사용권을 어떻게 배분할지 결정하여 CPU의 사용률을 높이고 응답 시간을 최소화하며 프로세스의 우선순위를 지정하여 경쟁 상황 해결 및 효율적인 시스템 동작을 유지한다.</p>

<p>스케줄링 알고리즘에는 FCFS, SJF, Priority Scheduling, Round-Robin Scheduling 등이 있다.</p>

<h4>FCFS, First Come First Served</h4>
<p>프로세스 스케줄링의 가장 간단한 형태 중 하나이다.&nbsp;</p>
<p>준비 큐에 도착한 순서대로 프로세스를 처리하는 방식으로 매우 직관적이기 때문에 구현이 간단하지만 실행 시간이 긴 프로세스가 먼저 도착하면 그 이후에 도착한 짧은 실행 시간을 가진 프로세스들이 대기 시간이 길어지기 때문에 평균 대기 시간과 평균 반환 시간이 크게 증가할 수 있는 문제가 있다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-filename="fcfs.png" data-origin-width="486" data-origin-height="410"><span><img src="/assets/images/posts/2023/03/28/30-1.png" loading="lazy" width="407" height="410" data-filename="fcfs.png" data-origin-width="486" data-origin-height="410"/></span></figure>
</p>
<p><b>*</b> Average Waiting Time : 평균 대기 시간, 프로세스가 대기하는 시간의 평균값</p>
<p><b>*</b> Average Turnaround Time : 평균 반환 시간, 프로세스가 큐에서 대기하고 CPU를 사용하는 시간의 합의 평균값</p>
<p><b>*</b> 일반적으로 두 지표가 작을수록 좋은 스케줄링 알고리즘으로 판단한다.</p>

<p>먼저 도착한 프로세스가 먼저 실행되기 때문에 CPU를 먼저 사용하는 프로세스는 대기 시간이 짧고, 나중에 사용하는 프로세스는 대기 시간이 길어진다. 따라서 평균 대기 시간과 평균 반환 시간은 프로세스 도착 순서에 따라 크게 달라진다. 또한 FCFS는 선점형 스케줄링이 아니기 때문에 한 번 시작된 프로세스는 CPU를 반환하기 전까지 계속 실행된다. 따라서 이 알고리즘은 대화형 시스템과 같이 응답 시간이 중요한 시스템에서는 적합하지 않다.</p>

<h4>SJF, Shortest Job First</h4>
<p>다음에 실행할 프로세스를 선택할 때 CPU Burst Time이 가장 짧은 프로세스를 선택하는 알고리즘이다.</p>
<p>CPU 버스트 시간이 짧은 작업이 먼저 실행되면 해당 작업이 빠르게 완료되면 <span>자원을 빨리 반환할 수 있고 다른 작업도 빠르게 실행될 수 있기 때문에&nbsp;</span> 때문에 평균 대기 시간을 줄일 수 있다는 장점이 있다.</p>

<h4>Priority Scheduling</h4>
<p>FCFS와 SJF 알고리즘은 일괄적으로 대결에서 작업을 처리하기 때문에 일부 작업이 너무 오래 실행되거나 대기하는 경우 다른 작업들은 계속해서 대기열에 쌓이게 되는 문제가 있다. 이렇게 필요한 만큼의 CPU 자원을 할당받지 못하고 대기하게 되는 상태를 Starvation라고 한다.</p>

<p>이 문제는 대기 시간이 긴 프로세스에게 우선순위를 부여하여 대기 시간이 길어질수록 우선순위가 높아지게 하는 방법을 통해 해결할 수 있다. 그중 Aging 기법은 SJF 알고리즘에서 버스트 타임이 높은 작업을 우선순위로 두어 문제를 해결하는 기법이다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-filename="sjf.png" data-origin-width="622" data-origin-height="583"><span><img src="/assets/images/posts/2023/03/28/30-2.png" loading="lazy" width="454" height="426" data-filename="sjf.png" data-origin-width="622" data-origin-height="583"/></span></figure>
</p>

<p>우선순위 스케줄링은 자원이나 시간이 많이 필요한 작업을 우선 순위로 두고 먼저 처리시켜 다음 작업을 진행할 때 자원이나 시간이 부족하여 대기 상태에 빠지지 않도록 한다. 이때 동일한 우선순위의 경우 해당 알고리즘을 통해서 처리하여 기아 상황에서도 공정한 작업 스케줄링이 가능하게 한다.</p>

<h4>Round-Robin Scheduling</h4>
<p>CPU 스케줄링에서 가장 일반적으로 사용되는 알고리즘이다.&nbsp;</p>
<p>시분할 시스템에서 사용되며 각 프로세스가 동일한 시간 할당량(Quantum)을 갖는다는 특징이 있으며 할당된 시간 이내에 작업이 끝나지 않으면 다른 프로세스에게 CPU를 양보하고 대기열의 끝으로 이동하는 과정을 반복한다.</p>
<p><b>*</b> 시분할 시스템 : CPU 시간을 작은 단위로 분할하여 다수의 사용자가 동시에 컴퓨터를 사용할 수 있도록하는 기술이다.</p>

<p>주로 대화식 시스템에서 사용되는 것이 일반적이며 사용자가 프로세스를 시작하면 해당 프로세스는 대기열에 추가되는데 CPU는 대기열에서 가장 앞에 있는 프로세스에게 할당되고 일정한 시간 후에 다른 프로세스로 넘어가고 이 과정을 대기열이 비어 있을 때까지 반복한다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-filename="round_robin.png" data-origin-width="434" data-origin-height="348"><span><img src="/assets/images/posts/2023/03/28/30-3.png" loading="lazy" width="434" height="348" data-filename="round_robin.png" data-origin-width="434" data-origin-height="348"/></span></figure>
</p>
<p>FCFS와 마찬가지로 간단하며 쉽게 구현이 가능하지만 모든 프로세스에게 동일한 기회를 부여하기 때문에 더 공정한 스케줄링이 가능하다. 다만 할당된 시간이 작은 경우에는 자주 Context Switch이 발생하기 때문에 오버헤드 문제가 있을 수 있다. 또한 할당된 시간이 큰 경우에는 대기열에 있는 다른 프로세스들이 오랫동안 기다려야 하기 때문에 적절한 시간 할당량을 결정하는 것이 중요하다.</p>
<p>* Context Swtich : 문맥 교환, CPU가 현재 실행 중인 프로세스에서 다음으로 실행할 프로세스로 제어를 양도하는 과정</p>

<h3>Memory</h3>
<p>프로세스가 사용할 메모리 공간을 할당하고 메모리 공간을 관리한다.</p>
<p>운영체제에서 메모리 공간은 일반적으로 세 가지 방식으로 할당 및 관리된다.</p>

<h4>Single Fixed Partition Allocation</h4>
<p>단일 고정 분할 할당</p>
<p>메모리를 고정 크기의 분할로 나누고 각 분할을 프로세스에 할당한다.</p>
<p>분할 크기는 운영체제가 미리 정해놓은 것으로 프로세스의 크기가 이것보다 작아야한다.</p>
<p>단순한 방식이지만 메모리 이용률이 낮다는 단점이 있다.&nbsp;</p>
<p>Paing 기어</p>
<h4>Variable Partition Allocation</h4>
<p>가변 분할 할당</p>
<p>메모리를 동적으로 분할하며 프로세스에 할당하는 방식이다.</p>
<p>프로세스의 크기에 맞춰서 할당되기 때문에 메모리 이용률이 향상된다. 프로세스의 크기가 불규칙적이고 할당과 해제에 따른 Memory Fragment 문제가 발생할 수 있다.<b></b></p>

<p><b>Memory Fragment</b>&nbsp;</p>
<p>메모리 단편화</p>
<p>메모리에서 사용 가능한 공간이 작은 조각으로 나뉘어 큰 용량의 프로세스가 할당되지 못하고 남는 작은 조각들이 늘어나는 문제를 말한다. 메모리를 효율적으로 사용하지 못하게 만들어 시스템 성능을 저하시키게 된다.</p>
<p>메모리 단편화는 Internal Fragment와 External Fragment 두 종류가 있다.</p>
<p><figure class="imageblock alignCenter" data-ke-mobileStyle="widthOrigin" data-filename="fragment.png" data-origin-width="462" data-origin-height="289"><span><img src="/assets/images/posts/2023/03/28/30-4.png" loading="lazy" width="462" height="289" data-filename="fragment.png" data-origin-width="462" data-origin-height="289"/></span></figure>
</p>
<p><b>Internal Fragment</b></p>
<p>내부 단편화, 메모리 할당 시 요청한 프로세스크기보다 더 큰 메모리 공간을 할당하게 되어 할당된 메모리 공간 중 일부가 사용되지 않는 문제</p>
<p><b>External Fragment </b></p>
<p>외부 단편화, 메모리에서 사용 가능한 공간이 작은 조각으로 나뉘어 큰 용량의 프로세스가 할당되지 못하는 문제&nbsp;</p>

<p>이러한 메모리 단편화 문제를 해결하기 위해서 Paing과 Segmentation 기법이 사용된다.</p>
<p><b>Paging :&nbsp;</b>물리적인 메모리를 고정 크기의 블록으로 분할하여 가상 주소와 물리 주소를 매핑한다.&nbsp;</p>
<p><b>Segmentation :&nbsp;</b>프로그램을 논리적인 단위인 세그먼트로 분할하여 가상 주소와 물리 주소를 매핑한다. 페이징 보다 프로그램의 논리적 구조를 반영하기 쉽다.</p>

<h4>Virtual Memory</h4>
<p>가상 메모리</p>
<p>물리적인 메모리보다 큰 용량의 가상 메모리 공간을 프로세스에게 할당하여 사용하는 방식이다.</p>
<p>프로세스가 필요로 하는 부분만 메모리에 올려서 실행하고 나머지 부분은 디스크에 저장한다. 이 방식은 물리적인 메모리보다 큰 용량의 프로그램을 실행할 수 있게 되며 프로세스 간의 메모리 공유도 가능하다.</p>


<h3>Storage</h3>
<p>하드디스크 등의 저장장치를 관리하고 File System을 통해 파일을 관리한다.</p>
<p><b>* File System</b> : 운영체제에서 파일과 디렉터리를 저장하고 검색할 수 있는 구조</p>

<p>파일이나 디렉토리를 저장하기 위한 블록의 할당, 디스크 공간 관리, 파일 접근 권한 관리, 파일 백업 및 복구 등의 역할을 수행하는데 일반적으로 파일 시스템은 파일과 디렉토리를 계층 구조로 구성하며 각 파일과 디렉터리는 고유한 이름을 가지고 있다.&nbsp;</p>

<p>디렉터리와 파일을 구분하는 특별한 기능을 수행하기 위한 파일을 사용하기도 하는데 이 파일은 파일 시스템의 일부이지만 일반 파일과 다른 속성을 가지고 있다. 예를 들어 리눅스에는 /dev 디렉터리에 하드웨어와 상호 작용하기 위한 특별한 파일들이 존재하는데 이러한 파일들은 일반 파일과는 달리 디바이스 파일로서 하드웨어 디바이스에 대한 인터페이스 역할을 한다. Windows에는 레지스트리 파일이 이러한 파일로 분류되며 운영체제 설정 정보를 포함하고 운영체제 및 애플리케이션의 구성을 제어하는 데 사용된다.&nbsp;</p>


<h3>Input/Output</h3>
<p>키보드, 마우스, 모니터, 프린터 등의 입출력 장치의 관리, 디바이스 드라이버를 통해 입출력을 처리한다.</p>

<h4>Device Driver Management</h4>
<p>장치 드라이버 관리</p>
<p>각각의 입출력 장치에 대해 운영체제는 해당 장치와 상호작용할 수 있는 드라이버를 관리한다. 이 드라이버는 해당 장치와 통신할 수 있는 인터페이스를 제공하며 운영체제와 프로그램 간의 데이터 전송을 담당한다.</p>

<h4>I/O Request Management</h4>
<p>프로그램이 입출력을 요청하면 운영체제는 이를 관리하며 각각의 입출력 요청에 대해 우선순위를 결정하여 처리한다. 이를 위해서 운영체제는 입출력 요청 큐를 유지하고 요청에 따라 적절한 장치를 할당하여 요청을 처리한다.</p>

<h4>I/O Buffering</h4>
<p>입출력 장치의 속도는 프로그램의 실행 속도와 차이가 있기 때문에 입출력 요청에 대한 응답을 기다리는 동안에는 다른 작업을 수행할 수 있도록 버퍼링을 수행한다. 이를 위해 운영체제는 입출력 데이터를 임시로 저장할 수 있는 입출력 버퍼를 유지한다.</p>

<h4>Interrupt Process</h4>
<p>입출력 작업 중에는 다양한 상황에서 인터럽트가 발생할 수 있는데 이를 위해 운영체제는 인터럽트 처리 루틴을 유지하여 각각의 인터럽트에 대해 적절한 처리를 수행한다.</p>

<h4>I/O Protection</h4>
<p>&nbsp;입출력 장치를 공유하는 다양한 프로그램이 동시에 실행될 경우 장치 접근에 대한 충돌이 발생할 수 있는데 이를 방지하기 위해 운영체제는 입출력 보호 기능을 수행하여 각각의 프로그램이 입출력 장치를 안전하게 사용할 수 있도록 보장한다.</p>

<p>입출력 보호 기능은 장치에 대한 접근 권한을 제어하는 기능으로 보안과 안정성을 유지한다. 사용자 프로세스가 입출력 장치를 임의로 사용하지 못하도록 하고 운영체제가 입출력 장치에 대한 접근 권한을 부여하고 사용자 프로세스는 해당 권한을 가지지 못한 상태에서는 장치에 접근할 수 없도록 한다.</p>
