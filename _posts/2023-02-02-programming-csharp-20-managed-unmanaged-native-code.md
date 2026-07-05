---
title: "Managed, Unmanaged, Native Code"
excerpt: "Managed, Unmanaged, Native Code"
categories:
  - CSharp
permalink: /programming/csharp/20-managed-unmanaged-native-code/
tags:
  - "CSharp"
  - "C#"
  - "Managed"
  - "native"
  - "unmanaged"
toc: true
toc_sticky: true
date: 2023-02-02
last_modified_at: 2023-02-02
source_url: https://b-note.tistory.com/20
---

<p><figure class="imageblock alignCenter" data-ke-mobileStyle="widthOrigin" data-filename="managed.png" data-origin-width="551" data-origin-height="225"><span><img src="/assets/images/posts/2023/02/02/20-1.png" loading="lazy" width="551" height="225" data-filename="managed.png" data-origin-width="551" data-origin-height="225"/></span></figure>
</p>
<h3>Managed code</h3>
<p>.Net Framwork에서 CLR(Common Language Runtime)의 제어하에서 실행되는 코드를 말한다.</p>
<p>이 코드는 Visual Basic.Net이나 C#과 같은 .Net Framework를 지원하는 언어의 컴파일러를 통해서 만들어지는 코드로&nbsp;컴파일러에 의해 IL(Intermediate Language)이라는 중간 언어로 생성된다. IL은 컴퓨터에서 바로 실행할 수 있는 기계 언어가 아니며 사용자가 생성한 코드의 클래스, 메서드, 속성 등을 나타내는 메타데이터와 함께 어셈블리라는 파일로 저장된다.</p>

<p>CLR은 이러한 어셈블리를 실행할 때 코드의 보안, 메모리 관리, 스레딩같은 관리를 담당하는 다양한 서비스를 제공하며 실행 시점에 필요한 코드는 JIT 컴파일로 컴퓨터의 환경에 맞는 기계어로 변환되어 실행된다. 이런 특징 때문에 CLR은 Managed Program이라고도 불리며 <span style="text-align: start"><span>&nbsp;</span>Managed Code</span>를 사용하기 때문에 이러한 동작이 가능하다.</p>

<h3>unmanaged code</h3>
<p>CLR 외부에서 실행되는 코드</p>
<p>unmanaged code는 Visaul Studio.Net 2002가 나오기 전에 만든 코드를 말한다. 즉 Visual Basic 6, Visual C++6 과 같은 컴파일러는 unmanaged code를 생성한다. 이 컴파일러들은 managed code처럼 IL 생성과정없이 컴파일이 수행되는 해당 컴퓨터에 적합한 기계 코드를 생성해 낸다. 이렇게 생성된 기계 언어는 동일한 구성의 다른 컴퓨터에서 실행될 수 있을지도 모르지만 다른 구성의 컴퓨터의 경우 실행이 불가능하다. 또한 이렇게 생성된 unmanaged code는 보안 및 메모리 관리 서비스를 실행시에 Runtime으로부터 받을 수가 없고 대신에 COM call의 서비스를 통해 받을 수 있다.</p>

<p>정리하자면 managed code의 경우 runtime이 알아서 메모리 관리를 해주는데 반해 unmanaged code의 경우, 사용자가 관리해야하지만 COM과 같은 라이브러리의 경우 스스로 능동적으로 메모리 관리할 수 있다.</p>

<h3>native code</h3>
<p>native code는 unmanaged code와 동일한 의미로 사용된다. 옛날 버전의 컴파일러로 컴파일 되었거나 선택적으로 해당 컴퓨터에 적합하게 생성된 기계 언어를 말하며 실행시 CLR에 의한 서비스를 받을 수 없는 것을 말한다. 이러한 native code는 하나의 완전한 프로그램이거나 COM 컴포넌트 또는 managed code에서 호출된 DLL일 수도 있다.&nbsp;</p>

<p>또 다른 의미로는 JIT 컴파일로부터 생성된 코드를 말한다. JIT은 managed code에만 사용되며 이는 managed code이지만 IL코드가 아니며 해당 컴퓨터에 적합한 기계언어이다. 따라서 native가 무조건 unmanaged는 아니다.</p>
