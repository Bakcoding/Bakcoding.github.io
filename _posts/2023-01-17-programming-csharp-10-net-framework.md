---
title: ".Net Framework"
excerpt: ".Net Framework"
categories:
  - CSharp
permalink: /programming/csharp/10-net-framework/
tags:
  - "CSharp"
  - ".net framework"
  - "CLR"
  - "gc"
  - "Il"
  - "JIT"
toc: true
toc_sticky: true
date: 2023-01-17
last_modified_at: 2023-01-17
source_url: https://b-note.tistory.com/10
---

<h3>.Net Framework</h3>
<p>응용 프로그램을 구축하고 실행하기 위해 Microsoft에서 개발한 소프트웨어 개발 프레임워크 및 런타임 환경이다.</p>
<p>일반적인 C, C++ 같은 네이티브 언어로 만들어진 프로그램들이 운영체제에서 곧바로 실행되는 것과는 다르게 .Net 프레임워크를 기반으로 만들어진 응용 프로그램은 반드시 프레임워크가 설치된 환경이 요구된다.</p>

<p><figure class="imageblock alignCenter" data-ke-mobileStyle="widthOrigin" data-filename="dotnet.png" data-origin-width="801" data-origin-height="658"><span><img src="/assets/images/posts/2023/01/17/10-1.png" loading="lazy" width="655" height="538" data-filename="dotnet.png" data-origin-width="801" data-origin-height="658"/></span></figure>
</p>
<p>.Net 프레임워크에서 사용되는 프로그래밍 언어는 대표적으로 C#과 Visual Basic이 있다.</p>
<p>해당 환경에서 개발된 프로그램은 컴파일 시 소스 코드를 IL(Intermediate Language)이라는 중간 언어로 바뀌는데 이때 IL코드는 메서드, 속성 및 기타 세부 정보를 포함한 메타 데이터와 함께 어셈블리라는 파일로 패키징 되어 저장된다. 어셈블리는 CLR에서 관리되며 런타임 실행 중에 JIT에 의해서 기계 언어로 변환된다. 이 기계언어 또한 지속해서 CLR에 의해서 유지 및 관리된다.&nbsp;</p>

<p>이렇게 중간언어로 변경되는 과정이 있기 때문에 빌드환경과 실행환경이 다르더라도 실행환경에 맞춰서 런타임에서 기계언어를 맞춰서 만들어 내게 된다. <span style="text-align: start">일반적인 네이티브 언어는 이러한 과정이 없기 때문에 환경이 바뀌면 문제가 생기는 경우가 발생하기도 한다.</span><span style="text-align: start"></span></p>

<h3 style="text-align: start">IL</h3>
<p>Intermediate Language</p>
<p style="text-align: start">중간언어, 인간이 읽을 수 있는 소스코드가 컴파일러를 통해 해석될 때 완전한 네이티브 코드가 아닌<span>&nbsp;</span><span>컴파일러나 소프트웨어 도구에 의해 추가 처리 또는 최적화될 수 있는 일련의 명령으로 변환되는데 이때 생성되는 파일에는 중간 언어라고 하는 명령어가 포함된다.</span></p>
<p style="text-align: start">&nbsp;</p>
<p style="text-align: start"><span>중간 언어는 쓰기 및 실행 사이의 가교 역할을 하는 언어로 컴파일러가 정밀한 최적화를 하도록 만들어 프로그램이 더 효율적으로 실행되도록 만들기도 하고 호환성이 없는 시스템 간에 이식 가능한 출력 파일을 생성하기 위해 사용되기도 한다.</span></p>
<p style="text-align: start">언어의 실제 구문은 기계 코드 또는 인간이 읽을 수 없는 다른 유형의 바이트 코드와 유사하거나 또는 기존의 크로스 플랫폼 컴퓨터 프로그래밍 언어일 수도 있다.</p>
<p>.Net 프레임워크 환경은 다음과 같은 과정으로 작업이 진행된다.</p>
<p style="text-align: start"><span style="text-align: start">.Net&nbsp;</span>호환 언어 &gt; IL 코드 &gt; CLR 실행 &gt; CPU 기계어</p>
<p style="text-align: start">IL 코드의 특이한 점은 ILASM.EXE라는 컴파일러를 가지고 있고 그 자체로 프로그래밍 언어의 문법을 가진다는 점이다.</p>
<p style="text-align: start">&nbsp;</p>
<h3><span style="text-align: start">CLR</span></h3>
<p>Common Language Runtime&nbsp;</p>
<p>.Net 프로그램 실행을 위한 런타임 환경을 제공한다. CLR은 구성요소들을 통해서 다양한 서비스를 제공하여 런타임에 프로그램의 전체 작업을 관리한다.&nbsp;</p>

<h4>JIT Compiler</h4>
<p><b>Just In Time</b></p>
<p>중간 언어인 IL 코드를 하드웨어에서 실행할 수 있는 기계어로 변환한다.&nbsp;</p>
<p>.Net 프로그램의 모든 어셈블리 및 코드를 기계어로 컴파일하지 않고 프로그램이 실행되는 런타임 동안 즉석에서 코드를 컴파일하여 필요한 코드만 컴파일한다. 실제로 실행에 필요한 코드를 컴파일할 수 있는 마지막 순간까지 기다리기 때문에 적시 컴파일 Junt In Time Compile이라고 한다. 이러한 작동 방식으로 다음과 같은 특징을 가진다.</p>

<h4>메모리 사용량 감소</h4>
<p>실제로 필요한 코드만 컴파일하기 때문에 사용되지 않는 코드는 컴파일되지 않으므로 메모리에 저장할 필요가 없어 프로그램에서 메모리 사용량을 절약할 수 있다.</p>

<h4>향상된 성능</h4>
<p>코드를 즉석에서 컴파일함으로 기본 하드웨어 및 시스템 구성에 대한 정보를 활용할 수 있기 때문에 최대 성능 및 효율성을 위해 코드를 최적화할 수 있다.</p>

<h4>유연성</h4>
<p>필요에 따라 코드를 컴파일할 수 있기 때문에 프로그램의 실행 흐름 또는 데이터 입력의&nbsp; 변경 사항에 적응할 수 있으므로 프로그램이 사용자 또는 시스템 입력에 더 유연하게 응답할 수 있다.</p>

<h4>GC</h4>
<p>Garbage Collection</p>
<p>더 이상 사용되지 않는 메모리를 식별하고 할당 해제하여 .Net 프로그램에서 사용하는 메모리를 자동으로 관리하는 프로세스이다.</p>

<p>Net 프로그램에서 개체는 프로그램 실행 중에 동적으로 생성되는데 이러한 개체를 저장하는 데 사용되는 메모리는 필요에 따라 할당 및 해제되어야 한다. GC는 프로그램에서 더 이상 참조하지 않는 개체를 식별하기 위해 메모리를 주기적으로 스캔하는 방식으로 작동한다. 그런 다음 해당되는 개체는 할당 해제되며 해당 메모리는 시스템에서 회수된다.</p>

<p>GC는 자동으로 사용되지 않는 메모리를 할당 해제하기 때문에 프로그램이 충돌하거나 예측할 수 없는 동작을 유발할 수 있는 메모리 누수를 방지하는데 도움이 된다. 또한 사용 가능한 메모리를 최적화하고 수동 메모리 관리의 오버헤드를 줄이면서 프로그램의 성능을 향상할 수 있으며 자동화된 프로세스를 통해 프로그래밍을 단순화할 수 있다.</p>

<p>하지만 GC는 사용되지 않는 개체를 식별하기 위해 주기적으로 메모리를 스캔하는 과정이 성능 오버헤드를 유발하기도 하며 메모리가 수거되는 동안 프로그램의 실행이 일시적으로 중지되거나 중단되는 등의 프로그램 응답성에 영향을 미칠 수 있다.</p>

<h3>Exception Handling</h3>
<p>프로그램 실행 중에 발생하는 오류 및 예외를 처리하기 위한<span>&nbsp;</span>메커니즘을<span>&nbsp;</span>제공하여 .Net<span>&nbsp;</span>프로그램이 오류를 복구하고 계속 실행할 수 있도록 한다. 이 메커니즘은 개발자가 프로그램이 다양한 유형의 예외에 응답하는 방법을 지정할 수 있는 try/catch/finally 블록의 사용을 기반으로 한다.&nbsp;</p>

<p>예외가 발생하면 CLR은 우선 예외 유형과 일치하는 catch 블록을 찾는다.</p>
<p>일치하는 catch 블록이 발견되면 해당 블록의 코드가 실행되어 프로그램이 적절한 방식으로 예외를 처리할 수 있다. 일반적으로 이 블록에서는 오류 메시지 로그나 대화 상자 표시 등을 처리한다.</p>

<p>일치하는 블록이 없으면 호출 스택에서 다음 상위 수준 catch 블록으로 예외가 전달되는데 어떤 수준에서도 블록이 발견되지 않으면 프로그램이 종료되고 오류 메시지가 표시된다.</p>

<p>예외를 효과적으로 처리할 수 있도록 제공되는 기능으로 Custom exception types, Exception filters, Stack traces 등이 있다.</p>

<h3>Security Serviece</h3>
<p>프로그램이 안전하게 실행되고 버퍼 오버플로 또는 인젝션 어택과 같은 공격에 취약하지 않도록 도움이 되는 다양한 보안 서비스를 제공한다.</p>

<h4>CAS(Code Access Security)</h4>
<p>코드 액세스 보안은 리소스 또는 중요한 데이터에 대한 무단 액세스를 방지하는 메커니즘으로 개발자가 다양한 코드 모듈이나 구성 요소에 대한 권한을 지정할 수 있으며 필요한 권한이 부여된 코드만 보호 중인 리소스에 액세스 할 수 있다.</p>

<h4>Verification</h4>
<p>CLR에는 프로그램 코드가 실행되기 전에 무결성과 안전성을 확인하는 확인 프로세스가 포함되어 있다. 확인 프로세스는 코드가 형식이 안전하고 버퍼 오버플로 또는 인젝션 어택과 같은 보안 취약성이 포함되어 있지 않은지 확인한다.</p>

<h4>Sandboxing</h4>
<p>프로그램을 서로 간에 그리고 기본 시스템으로부터 격리할 수 있는 샌드박싱 메커니즘을 제공한다. 샌드박싱은 프로그램에서 사용할 수 있는 권한과 리소스를 제한하고 악의적인 프로그램이 중요한 시스템 리소스나 데이터에 액세스 하지 못하도록 방지한다.</p>

<h4>Secure execution</h4>
<p>악성 코드가 시스템에서 실행되는 것을 방지하여 안전한 실행환경을 제공하여 프로그램이 안전하고 신뢰할 수 있는 환경에서만 실행되도록 악성 코드나 승인되지 않은 코드를 포함하지 않도록 한다.</p>

<h4>Encryption</h4>
<p>CLR은 중요한 데이터를 보호하고 무단 액세스를 방지할 수 있도록 데이터 암호화 및 암호 해복에 대한 지원을 한다. 이 암호화 메커니즘을 사용하면 디스크에 저장되거나 네트워크를 통해 전송되는 데이터를 보호할 수 있다.</p>

<h3>Thread Management</h3>
<p>개발자가 단일 프로그램 내에서 여러 스레드를 만들고 제어할 수 있도록 한다.</p>

<h4>Thread Pool</h4>
<p>개발자가 각 작업에 대해 새로운 스레드를 만드는 대신 여러 작업에 스레드를 재사용할 수 있도록 스레드 풀 메커니즘을 제공한다. 스레드 풀은 성능을 향상시키고 스레드 생성 및 소멸시 발생하는 오버헤드를 줄일 수 있다.</p>

<h4>Thread Synchronization</h4>
<p>여러 스레드가 공유 리소스나 데이터에 액세스할 때 발생할 수 있는 경합 상태 및 기타 동기화 문제를 방지하도록 다양한 동기화 메커니즘이 제공되는데 이 메커니즘에는 locks, mutexes, semaphores, synchronization primitives 가 있다.</p>

<h4>Thread Prioritization</h4>
<p>스레드의 우선 순위를 지정할 수 있어 중요한 작업이 먼저 실행되도록 할 수 있다. 우선 순위는 실행 예약 순서를 결정하는데 이것은 성능을 최적화하거나 중요한 작업이 먼저 실행되도록 하는 데 유용하다.</p>

<h4>Thread Interruption</h4>
<p>현재 실행 중인 스레드를 중단할 수 있는데 오래 실행되거나 응답하지 않는 스레드를 중지시킬 수 있다.</p>

<h4>Thread Local Storage</h4>
<p>여러 스레드 간에 공유되지 않고 특정 스레드에 로컬 데이터를 저장한다. 스레드 로컬 저장소는 성능을 최적화하거나 동기화 오버헤드를 줄일 수 있다.</p>

<h3>Type System</h3>
<p><span style="text-align: start">.Net&nbsp;</span>&nbsp;호환 언어는 지켜야 할 타입의 표준 규격을 정의한 <b>CTS</b>를 만족한다면 누구나 새로운 언어를 만들어 <span style="text-align: start">.Net&nbsp;</span>프레임워크 상에서 실행할 수 있다. CTS의 모든 규격을 구현할 필요는 없으며 사용할 <b>언어 사양</b>에 맞게 구현하는 것도 가능하다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-filename="cls.png" data-origin-width="389" data-origin-height="227"><span><img src="/assets/images/posts/2023/01/17/10-2.png" loading="lazy" width="389" height="227" data-filename="cls.png" data-origin-width="389" data-origin-height="227"/></span></figure>
</p>
<h4>CTS</h4>
<p>Common Type System</p>
<p>공통 유형 시스템은 데이터 유형을 정의하고 사용하기 위한 표준이다.</p>
<p>데이터 유형은 언어 간 통합을 용이하게 하기 위해 런타임에 의해 사용되고 관리된다.</p>

<h4>공용 언어 사양</h4>
<p>CTS 이외에도 한 가지 지켜할 사항인 CLS가 있다.</p>
<p>직접 <span style="text-align: start">.Net&nbsp;</span> 호환 언어를 만든다면 CTS는 전체를 구현할 필요가 없더라도 CLS만큼은 완벽하게 구현할 필요가 있는데 .Net 호환 언어끼리는 서로 사용할 수 있고 상속도 받을 수 있기 때문에 항상 외부에서 사용할 기능에 대한 호환성 문제를 염두하고 CLS를 준수해야 한다. 모든 <span style="text-align: start">.Net&nbsp;</span> 호환 언어는 CLS에 정의한 사양만큼 구현하도록 하며 서로 간에 호출해야 하는 경우에는 그 기능에 한해서 만족시킬 수 있어야 한다.</p>

<h4>CLS</h4>
<p>Common Language Specification</p>
<p>완전한 상호운용성을 만들기 위한 언어의 공통점이다.</p>
<p>CTS의 서브셋으로 CLS의 규칙이 더 엄격하지 않은 이상 CTS 내의 모든 규칙이 CLS에 동일하게 적용될 수 있다.</p>
