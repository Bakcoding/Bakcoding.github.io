---
title: "Main method"
excerpt: "Main method"
categories:
  - CSharp
permalink: /programming/csharp/11-main-method/
tags:
  - "CSharp"
  - "async"
  - "await"
  - "C#"
  - "dotnet"
  - "main method"
  - "string[args]"
toc: true
toc_sticky: true
date: 2023-01-19
last_modified_at: 2023-01-19
source_url: https://b-note.tistory.com/11
---

<h2>메인 함수</h2>
<p>C#의 메인함수는 프로그램의 시작점이다.&nbsp;</p>
<p>프로그램이 실행될 때 가장 먼저 실행되는 함수로 몇가지 조건을 가진다.</p>
<p>- 클래스 또는 구조체 내부에 선언한다.</p>
<p>- 메인함수는 반드시 static으로 선언되어야하며 클래스 또는 구조체가 static일 필요는 없다.</p>
<p>- 접근제한자는 public일 필요는 없다.</p>
<p>- 반환형은 void, int, Task, Task&lt;int&gt; 형을 가질 수 있다. (Task, Task&lt;int&gt; 의 경우 async 한정자 필요)</p>
<p>- 매개변수는 string[]을 가질 수 있다. 이 매개변수에는 명령어 인자가 포함된다.</p>

<h2>선언</h2>
<pre class="csharp"><code>public static void Main() {}
public static int Main() {}
public static void Main(string[] args) {}
public static int Main(string[] args) {}
public static async Task Main() {}
public static async Task&lt;int&gt; Main() {}
public static async Task Main(string[] args) {}
public static async Task&lt;int&gt; Main(string[] args) {}
//( public 접근 제한자는 일반적으로 사용되는 것이며 필요조건은 아니다.)</code></pre>
<h2>반환형<b></b></h2>
<p>메인 함수는 한정자나 매개변수의 상태에 따라 반환형을 선택할 수 있다.</p>
<pre class="csharp"><code>//매개변수, await을 모두 사용하지 않음
static int Main()
static void Main()

//매개변수, awiat 모두 사용
static async Task&lt;int&gt; Main(string[] args)
static void Main(string[] args)

//매개변수를 사용하고 await만 사용하지 않음
static int Main(string[] args)
static aync Task Main()

//매개변수를 사용하지않고 await만 사용
static async Task&lt;int&gt; Main()
static async Task Main(string[] args)</code></pre>

<p>메인 함수의 반환값을 통해 프로그램 실행 결과를 확인할 수 있다.</p>
<p>윈도우에서 프로그램이 실행되면 메인 함수에서 반환되는 모든 값이 환경 변수에 저장된다.</p>
<p>저장된 환경 변수는 배치 파일의 ERRORLEVEL 또는 PowerShell의 $LastExitCode를 사용하여 검색할 수 있다.</p>

<p><b>테스트</b></p>
<p>int 값 반환 확인</p>
<p>실행하면 0을 반환하도록 메인 함수를 만든다.</p>
<pre class="csharp"><code>class MainReturnValTest
{
    static int Main()
    {
        //...
        return 0;
    }
}</code></pre>
<p>해당 스크립트가 위치한 폴더에서 PowerShell을 열어 스크립트를 실행시킨다.</p>
<pre class="shell"><code>dotnet run
if ($LastExitCode -eq 0) {
	Write-Host "Execution succeeded"
} else
{
	Write-Host "Execution Failed"
}
Write-Host "Return value = " $LastExitCode</code></pre>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="587" data-origin-height="193"><span><img src="/assets/images/posts/2023/01/19/11-1.png" loading="lazy" width="587" height="193" data-origin-width="587" data-origin-height="193"/></span></figure>
</p>
<p><b>비동기 메인 함수</b></p>
<p>메인 함수를 비동기로 선언하면 컴파일러는 항상 올바른 코드를 실행하는 이점이 있다.</p>
<p>프로그램의 진입점에서 Task 또는 Task&lt;int&gt;를 반환할때 컴파일러는 프로그램 코드에 선언된 진입점 메서드를 호출하는 새로운 진입점을 생성한다.<b></b></p>

<p>진입점의 이름을 $GeneratedMain이라고 할때 컴파일러는 이 진입점에 대해 다음과 같은 코드를 생성한다.</p>

<pre class="csharp"><code>// 결과적으로 동일한 코드를 생성
static Task Main()
static void $GeneratedMain() =&gt; Main().GetAwaiter().GetResult();

static Task Main(string[])
private static void $GeneratedMain(string[] args) =&gt; Main(args).GetAwaiter().GetResult();

static Task&lt;int&gt; Main()
private static int $GeneratedMain()

static Task&lt;int&gt; Main(string[])
private static int $GeneratedMain(string[] args) =&gt; Main(args).GetAwaiter().GetResult();</code></pre>

<p><b>테스트</b></p>
<p>async 반환값 확인</p>
<p>비동기 함수 호출을 하기 위해서 상용구 코드를 사용하거나 직접 await을 반환하는 메인함수를 만든다.</p>
<pre class="csharp"><code>// boilerplate code
public static void Main()
{
	AsyncConsoleWork().GetAwaiter().GetResult();
}

// or
static async Task&lt;int&gt; Main(string[] args)
{
	return await AsncConsoleWork();
}

// async function return 0
private static async Task&lt;int&gt; AsyncConsoleWork()
{
	return 0;
}</code></pre>

<p>코드를 작성한 다음 동일하게 명령어를 입력해보면 결과를 확인할 수 있는데 이번에는 await으로 인한 동작이 추가된걸 확인할 수 있다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="613" data-origin-height="268"><span><img src="/assets/images/posts/2023/01/19/11-2.png" loading="lazy" width="613" height="268" data-origin-width="613" data-origin-height="268"/></span></figure>
</p>

<h2>명령문 인자</h2>
<p>다음 방법들로 함수를 정의해서 메인 함수에 인자를 전달할 수 있다.</p>
<table style="border-collapse: collapse; width: 100%; height: 208px;" border="1">
<tbody>
<tr style="height: 17px;">
<td style="width: 412.5px; height: 17px;"><b>Main method code</b></td>
<td style="width: 412.5px; height: 17px;"><b>Main signature</b></td>
</tr>
<tr style="height: 17px;">
<td style="width: 412.5px; height: 17px;">No return value, no use of await</td>
<td style="width: 412.5px; height: 17px;">static void Main(string[] args)</td>
</tr>
<tr style="height: 17px;">
<td style="width: 412.5px; height: 17px;">Return value, no use of await</td>
<td style="width: 412.5px; height: 17px;">static int Main(string[] args)</td>
</tr>
<tr style="height: 17px;">
<td style="width: 412.5px; height: 17px;">No return value, uses await</td>
<td style="width: 412.5px; height: 17px;">static async Task Main(string[] args)</td>
</tr>
<tr style="height: 20px;">
<td style="width: 412.5px; height: 20px;">Return value, uses await</td>
<td style="width: 412.5px; height: 20px;">static async Task&lt;int&gt; Main(string[] args)</td>
</tr>
</tbody>
</table>
<p>인자를 사용하지 않는 경우 더 간단하게 함수를 선언할 수 있다.</p>
<table style="border-collapse: collapse; width: 100%;" border="1">
<tbody>
<tr>
<td style="width: 50%;"><b>Main method code</b></td>
<td style="width: 50%;"><b>Main signature</b></td>
</tr>
<tr>
<td style="width: 50%;">No return value, no use of await</td>
<td style="width: 50%;">static void Main()</td>
</tr>
<tr>
<td style="width: 50%;">Return value, no use of await</td>
<td style="width: 50%;">static int Main()</td>
</tr>
<tr>
<td style="width: 50%;">No return value, uses await</td>
<td style="width: 50%;">static async Task Main()</td>
</tr>
<tr>
<td style="width: 50%;">Return value, uses await</td>
<td style="width: 50%;">static async TaskMint&gt; Main()</td>
</tr>
<tr>
<td style="width: 50%;">&nbsp;</td>
<td style="width: 50%;">&nbsp;</td>
</tr>
</tbody>
</table>
<p>또한 Environment.CommandLine 이나 Environment.GetCommandLineArgs를 통해서 콘솔이나 WinForms 응용 프로그램에서 어느 시점에나 인자에 접근할 수 있다. 명령문 인자를 사용할 수 있도록 하기 위해서는 수동으로 메인 함수를 수정해야한다.&nbsp;</p>

<p><span style="background-color: #f6e199;">💡 메인 함수의 매개변수는 명령문 인자로 문자열 배열이다. 보통은 인자의 존재를 확인할때 문자열 속성인 Lenght 사용한다.</span></p>
<p><span style="background-color: #f6e199;">이때 문자열 배열은 null이 올 수 없기 때문에 null 검사하지 않고 Length로만 판단해도 안전하다.</span></p>

<p>문자열 인자는 Convert 클래스나 Parse 함수를 사용해서 숫자 형식으로 변환할 수 있다.</p>

<pre class="csharp"><code>long num = Int64.Parse(args[0]);
long num = long.Parse(args[0]);
long num = Convert.ToInt64(s);</code></pre>

<p><b>문자열을 정수로 변환하여 사용하는 예제</b></p>
<p>인자가 없는 경우 응용 프로그램은 프로그램의 올바른 사용법을 설명하는 메시지를 출력한다.</p>

<pre class="csharp"><code>// ---How to using numeric argument---
// Factorial : 정수로 변환된 인자를 팩토리얼 계산후 반환
public class Functions
{
    public static long Factorial(int n)
    {
        if ((n &lt; 0) || (n &gt; 20))
        {
            return -1;
        }

        long tempResult = 1;
        for (int i = 1; i &lt;= n; i++)
        {
            tempResult *= i;
        }
        return tempResult;
    }
}

class Program
{
    static int Main(string[] args)
    {
        if (args.Length == 0)
        {
            Console.WriteLine("Please enter a numeric argument.");
            Console.WriteLine("Usage: Factorial &lt;num&gt;");
            return 1;

        }

        int num;
        bool test = int.TryParse(args[0], out num);
        if (!test)
        {
            Console.WriteLine("Please enter a numeric argument.");
            Console.WriteLine("Usage: Factorial &lt;num&gt;");
            return 1;
        }

        long result = Functions.Factorial(num);

        if (result == -1)
        {
            Console.WriteLine("Input must be &gt;= 0 and &lt;= 20.");
        }
        else
        {
            Console.WriteLine($"The Factorial of {num} is {result}.");
        }

        return 0;
    }
}</code></pre>
<p>예제를 테스트 하기위해서 Developer Command Prompt를 사용한다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="331" data-origin-height="56"><span><img src="/assets/images/posts/2023/01/19/11-3.png" loading="lazy" width="331" height="56" data-origin-width="331" data-origin-height="56"/></span></figure>
</p>
<p>시작 메뉴에서 커맨드 창을 실행시킨다.</p>
<p>(프롬프트창은 굳이 위 프로그램을 사용하지 않아도 된다.)</p>

<p><span style="background-color: #f6e199;">💡Command&nbsp; 명령어 : 경로 이동 cd &lt;path&gt;, </span><span style="background-color: #f6e199;">드라이브 변경하는방법 C:\&gt;E:</span></p>

<p>스크립트 파일이 위치한 경로로 이동한 후 다음 명령어를 실행한다,</p>
<pre class="shell"><code>dotnet build</code></pre>
<p>만약 응용 프로그램이 컴파일 오류가 없다면 해당 스크립트파일의 빌드 파일이 실행된다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="763" data-origin-height="178"><span><img src="/assets/images/posts/2023/01/19/11-4.png" loading="lazy" width="763" height="178" data-origin-width="763" data-origin-height="178"/></span></figure>
</p>
<p>팩토리얼 함수가 잘 동작하는지 확인하기 위해서 인자를 전달해본다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="475" data-origin-height="48"><span><img src="/assets/images/posts/2023/01/19/11-5.png" loading="lazy" width="475" height="48" data-origin-width="475" data-origin-height="48"/></span></figure>
</p>
<p>3의 인자를 전달했을때 3!의 계산 결과인 6이 잘 출력되는걸 확인할 수 있다.</p>
