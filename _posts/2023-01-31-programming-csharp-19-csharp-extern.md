---
title: "C# 외부 코드 사용 키워드 : extern"
excerpt: "C# 외부 코드 사용 키워드 : extern"
categories:
  - CSharp
permalink: /programming/csharp/19-csharp-extern/
tags:
  - "CSharp"
  - "C#"
  - "extern"
  - "extern-alias"
  - "Interop"
  - "keyword"
toc: true
toc_sticky: true
date: 2023-01-31
last_modified_at: 2023-01-31
source_url: https://b-note.tistory.com/19
---

<h3>extern</h3>
<p>'외부의'라는 뜻을 가지는 External의 약자로 외부에 선언된 함수 또는 객체임을 명시하는 역할을 한다.</p>
<p>이때 외부란 C# 코드 이외의 언어로 작성된 코드를 뜻하며 DLL이나 C/C++ 등으로 작성된 함수를 말한다.</p>
<p>이런 외부에서 작성된 코드 즉, C# 및. Net 프레임 워크에서 사용되지 않는 코드 다시 말해서 CLR에서 관리되지 않는 코드를 unmanaged code라고 하는데 이러한 unmanaged code를 불러오기 위해서는 interop 기술이 필요하다.</p>

<blockquote><a href="https://b-note.tistory.com/21" target="_blank" rel="noopener">Interop 정리글</a></blockquote>

<p>간략하게 Interop은 다른 언어나 플랫폼에서 작성된 코드를 호출하거나 받는 기술로 COM, P/Invoke, C++/CLI 등이 대표적으로 있는데 extern 키워드는 이러한 함수나 객체가 외부의 것임을 나타내는 역할을 한다.</p>

<p>일반적으로 C#에서 많이 사용하는 P/Invoke 방식은 DllImport arttribute와 함께 사용한다.</p>
<p>이 경우 메서드는 반드시 static으로 선언되어야 한다.</p>
<pre class="csharp"><code>// Microsoft AVI File support library
[DllImport("avifil32.dll")] // Interop, P/Invoke
private static extern void AVIFileInit();</code></pre>

<h3>extern alias</h3>
<p>.Net 어셈블리에서 다른 버전의 동일한 어셈블리의 참조가 필요한 경우에 사용할 수 있다.</p>
<p>일반적으로 .Net 프로젝트에서 어셈블리의 참조는 using이나 Imports를 사용하여 참조하는데 만약 서로 다른 버전의 어셈블리를 참조하는 경우에는 컴파일러가 어떤 버전을 사용해야 하는지 구분이 필요하기 때문에 이런 경우 extern alias 키워드를 사용한다.</p>

<p>동일한 어셈블리를 버전별로 참조하기 위해서는 각각의 어셈블리를 특정시킬 수 있도록 만드는 작업이 필요하다.</p>
<p>특정시키는 방법으로는 각 어셈블리의 별칭을 지정하는 방법과 이름을 변경하는 방법이 있다.</p>

<h4>Alias</h4>
<p>어셈블리의 별칭을 지정하는 방법은 대표적으로 두 가지 방법이 있다.</p>

<p><b>1. Visual Studio&nbsp;</b></p>
<p>비주얼 스튜디오의 솔루션 탐색기에서 별칭을 수정할 수 있다.</p>
<p>Assembly &gt; 우클릭 속성 &gt; Aliases 수정</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="459" data-origin-height="218"><span><img src="/assets/images/posts/2023/01/31/19-1.png" loading="lazy" width="503" height="218" data-origin-width="459" data-origin-height="218"/></span></figure>
<figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="282" data-origin-height="121"><span><img src="/assets/images/posts/2023/01/31/19-2.png" loading="lazy" width="282" height="121" data-origin-width="282" data-origin-height="121"/></span></figure>
</p>
<p><b>2. 프롬프트 창</b></p>
<p>프롬프트에서 어셈블리에 별칭을 부여할 수 있다.</p>
<pre class="csharp"><code>/r:GridV1=grid.dll
/r:GridV2=grid20.dll</code></pre>

<p>각각의 어셈블리에 외부에서 사용할 별칭 GridV1과 GridV2가 지정된다.</p>

<p>이렇게 별칭을 지정해 주면 extern 키워드를 사용하여 별칭을 참조하면 동일한 어셈블리를 구분해서 참조가 가능해진다.</p>
<pre class="csharp"><code>extern alias GridV1;
extern alias GridV2;
// can using namespace
using Class1V1 = GridV1::Namespace.Class1;
using Class1V2 = GridV2::Namespace.Class1;</code></pre>

<h4>Name</h4>
<p>별칭을 지정하지 않고 이름을 변경하는 방법으로도 참조가 가능하다.</p>
<p>비주얼 스튜디오에서 별칭을 수정했던 설정창을 다시 켜보면 상단에 이름 속성을 확인할 수 있다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="527" data-origin-height="121"><span><img src="/assets/images/posts/2023/01/31/19-3.png" loading="lazy" width="527" height="121" data-origin-width="527" data-origin-height="121"/></span></figure>
</p>
<p>이름을 사용하기 위해서는 별칭이 지정되지 않아야 하므로 별칭을 지우고 이름을 수정한다.</p>

<p>그 후에 <span style="color: #333333; text-align: start;">C#에서 </span>Type.GetType 메서드를 사용하면 어셈블리에서 Type을 가져올 수 있는데 이때 어셈블리의 전체 이름을 사용하여 Type을 가져오면 해당 어셈블리를 특정해서 참조할 수 있게 된다.</p>
<pre class="csharp"><code>Type myType = Type.GetType("MyNamespace.MyType, MyAssembly");</code></pre>
