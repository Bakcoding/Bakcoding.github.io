---
title: "Interoperability"
excerpt: "Interoperability"
categories:
  - CSharp
permalink: /programming/csharp/21-interoperability/
tags:
  - "CSharp"
  - "C#"
  - "C++/CLI"
  - "COM"
  - "Interop"
  - "P/Invoke"
  - "SWIG"
toc: true
toc_sticky: true
date: 2023-02-02
last_modified_at: 2023-02-02
source_url: https://b-note.tistory.com/21
---

<h3>Interoperability(Interop)</h3>
<p>상호운용성</p>
<p>unmanaged code에 대한 기존 투자를 보존하고 활용할 수 있게 한다.</p>
<p>즉 CLR을 사용하지 않는 어셈블리를 CLR에서 사용할 수 있게 만드는 것이다.</p>
<p>interop은 managed와 unmanaged를 오고가는 메모리 비용과 코드 작성 비용 때문에 최소화하는게 좋다.</p>

<h4>COM Interop</h4>
<p>Component Object Model(COM) 을 사용하면 개체의 기능을 다른 컴포넌트와 윈도우 플랫폼의 호스트 프로그램에 사용할 수 있다. 사용자가 기존 코드 베이스와 상호 운용할 수 있도록 .Net 프레임워크에서 COM라이브러리를 통해 interop을 지원한다.</p>

<h4>Platform Invoke(P/Invoke)</h4>
<p>P/Invoke는 사용자의 managed code에서 unmanaged 라이브러리의 구조, 콜백 그리고 기능에 접근할 수 있도록 한다. 대부분 P/Invoke API는 <code>System</code> 과 <code>System.Runtime.InteropServices</code> 두 개의 네임스페이스를 포함한다.</p>
<p>이 두개의 네임스페이스를 사용하면 네이티브 컴포넌트를 사용할 수 있는 도구가 제공된다.</p>
<pre class="csharp"><code>using System;
using System.Runtime.InteropServices;

public class Program
{
	// Import dll (containing the funtion)
    [DllImport("user32.dll", CharSet = CharSet.Unicode, SetLastError = true)
    // Define
    private static extern int MessageBox(IntPtr hWnd, string IpText, string IpCaption, uint uType);
    
    public static void Main(string[] args)
    {
    	// Invoke the function as a regular managed method
        MessageBox(IntPtr.Zero, "Command-line message box", "Attention!", 0);
    }
}</code></pre>
<ol style="list-style-type: decimal">
<li>Attribute
<ul style="list-style-type: disc">
<li><span>[DllImport] attribute은 런타임에 unmanaged DLL을 로드할것을 알린다.</span></li>
<li>"user32.dll"&nbsp;문자열은&nbsp;사용할&nbsp;기능이&nbsp;포함된&nbsp;DLL을&nbsp;대상으로&nbsp;한다.</li>
<li>CharSet&nbsp;=&nbsp;CharSet.Unicode&nbsp;문자열을&nbsp;Mashalling하는데&nbsp;사용할&nbsp;문자&nbsp;집합을&nbsp;지정한다.</li>
<li>SetLastError&nbsp;=&nbsp;true&nbsp;런타임에서&nbsp;오류가&nbsp;발생했을때&nbsp;사용자가&nbsp;Mashal.GetLastWin32Error()를&nbsp;통해서&nbsp;에러코드를&nbsp;감지할&nbsp;수&nbsp;있게한다.</li>
</ul>
</li>
<li>Declare
<ul style="list-style-type: disc">
<li>메서드 선언시 메서드명은 사용할 unmanaged code와 동일한 이름으로 작성한다.</li>
<li>이때 extern 키워드를 통해서 해당 메서드가 외부의 메서드임을 런타임에 알린다.</li>
<li>런타임은 외부 메서드라는것을 알게되면 해당 managed 메서드를 호출할 때 attribute의 설정을 통해 특정된 DLL을 찾아서 실행시킨다.</li>
</ul>
</li>
<li>Main method
<ul style="list-style-type: disc">
<li>managed code 즉 현재 작업중인 코드에서 extern으로 선언한 메서드를 호출하여 외부 메서드를 사용한다.&nbsp;</li>
</ul>
</li>
</ol>

<h4>Managed C++(C++/CLI)</h4>
<p>Managed Extensions for C++ 또는 Managed C++은 문법적 그리고 구문적 확장, 키워드와 속성을 포함하고 C++의 구문 및 언어를 가져오는 .Net Framework의 C++ 언어 확장 집합이다. 이 확장자는 managed code상에서 C++ 코드가 CLR의 대상이 될 수 있도록 그리고 지속적으로 native code와 상호 운용될 수 있게하려고 <span>마이크로소프트에서<span>&nbsp;</span></span>만들었다.</p>

<p>2004년 Managed C++은 구문을 명확하고 단순화하고 managed generics을 포함하도록 기능을 크게 개선시켰다. 이렇게 새로운 확장자는 C++/CLI로 지정되었고 Visual Studio 2005 이후에 포함되면서 Managed C++을 대체하였다.</p>

<h4>SWIG</h4>
<p>Simplefied Wrapper and Interface Generator</p>
<p>C 또는 C++로 작성된 컴퓨터 프로그램이나 라이브러리 다른 프로그래밍 언어에서 사용할 수 있도록 연결하는데 사용하는 오픈소스 도구이다.&nbsp;</p>
<p>주목적은 네이티브 함수의 호출, 복잡한 자료형을 함수에 전달, 메모리 부적절하게 해제하지 못하게 방지, 언어 간에 오브젝트 클래스를 상속할 수 있게 하는것이다.</p>
