---
title: "C# 비동기화 키워드 : async, await"
excerpt: "C# 비동기화 키워드 : async, await"
categories:
  - CSharp
permalink: /programming/csharp/16-csharp-async-await/
tags:
  - "CSharp"
  - "await"
  - "aync"
  - "C#"
  - "keyword"
  - "modifier"
toc: true
toc_sticky: true
date: 2023-01-31
last_modified_at: 2023-01-31
source_url: https://b-note.tistory.com/16
---

<h3>async</h3>
<p>메서드, 람다 표현식 또는 무명 메서드를 비동기로 특정할 수 있다.</p>
<p>메서드나 표현식에 async 제한자가 붙으면 비동기식 메서드라고 한다.</p>

<pre class="csharp"><code>public async Task&lt;T&gt; ExampleMethodAsync()
{
	string contents = await NetworkManager.GetData(url);
}</code></pre>

<p>async만 사용한다고 메서드가 비동기로 작동하는 것은 아니며 첫 번째 await 표현식을 만날 때까지 동기적으로 실행된다.&nbsp;</p>
<p>await의 동작이 완료될 때까지 메서드는 대기하게 되고 메서드 호출자는 다음 동작을 진행하게 된다.</p>

<p>async 키워드로 선언된 비동기 메서드가 await 표현식이나 구문이 포함되어있지 않으면 컴파일러는 경고를 띄우게 된다.</p>
<p>비동기 메서드의 반환형은 Task &lt;T&gt;, Task(void) 형태로 정의되고 return T와 같이 해당 타입만 반환한다.</p>
<p>컴파일러는 return T을 자동으로 Task &lt;T&gt;로 변환한다. 특히 async 메서드는 이벤트핸들러를 위해 void의 반환을 허용하고 있다.</p>

<p>awiat은 일반적으로 Task 또는 Task &lt;T&gt; 객체와 함께 사용되는데 Task 이외에 <b>awaitable</b> 클래스도 함께 사용할 수 있다.</p>
<p><b>* awaitable :&nbsp;</b>GetAwaiter() 메서드를 갖는 클래스</p>


<blockquote><a style="color: #6d67e4;" href="https://b-note.tistory.com/15" target="_blank" rel="noopener">About&nbsp;sync&nbsp;and&nbsp;async</a></blockquote>

<h4>Example</h4>
<pre class="csharp"><code>    class Program
    {
        public static void Main(string[] args)
        {
            TaskTest(10);
            Console.WriteLine("============Call Main============");

            Console.ReadLine();
        }
        private static async void TaskTest(int count)
        {
            Console.WriteLine("============Call Task1============");

            for (int i = 0; i &lt; count; i++)
            {
                var message = String.Format("Count {0}", i);
                Console.WriteLine(message);
                await Task.Delay(1000);
            }

            Console.WriteLine("============End Task1============");
        }
    }</code></pre>
<p>Main 함수가 실행되면서 TaskTest를 호출한다.</p>
<p>그리고 곧이어 비동기적으로 Main 함수의 다음 코드가 실행되면서 TaskTest의 다음 동작이 진행된다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-filename="blob" data-origin-width="445" data-origin-height="235"><span><img src="/assets/images/posts/2023/01/31/16-1.png" loading="lazy" width="377" height="199" data-filename="blob" data-origin-width="445" data-origin-height="235"/></span></figure>
</p>

<p>&nbsp;메인함수 또한 비동기로 정의하여 사용할 수 있다.</p>
<pre class="csharp"><code>    class Program
    {
        public static async Task Main(string[] args)
        {
            await TaskTest(10);
        }
        private static async Task TaskTest(int count)
        {
            Console.WriteLine("============Call Task1============");

            for (int i = 0; i &lt; count; i++)
            {
                var message = String.Format("Count {0}", i);
                Console.WriteLine(message);
                await Task.Delay(1000);
            }

            Console.WriteLine("============End Task1============");
        }
    }</code></pre>
<p>메인함수는 await 기준으로 비동기적으로 작업이 처리된다.</p>

<h3>요약</h3>
<p>async 메서드 내부에서 await을 만날게 되면 다음과 같은 경우의 수 가 있다.</p>
<p>1. awaitable이 예외를 발생시킨다면 await은 throw exception 한다.</p>
<p>2. awaitable이 이미 종료됐다면 메서드는 일반 메서드와 같이 동기적으로 실행된다.</p>
<p>3. awaitable이 종료된 상태가 아니라면 종료될 때 await 다음 코드가 실행되도록 대기 큐에 등록하고 async 메서드의 호출자에게 Task를 반환한다.</p>

<p><b>microsoft document 비동기 프로그래밍 예제</b></p>
<p><a href="https://learn.microsoft.com/ko-kr/dotnet/csharp/programming-guide/concepts/async/#final-version" target="_blank" rel="noopener">https://learn.microsoft.com/ko-kr/dotnet/csharp/programming-guide/concepts/async/#final-version</a></p>
<figure id="og_1675138977408" contenteditable="false" data-og-type="website" data-og-title="C#의 비동기 프로그래밍" data-og-description="async, await 및 Task를 사용하여 비동기 프로그래밍을 지원하는 C# 언어에 대해 간략히 설명합니다." data-og-host="learn.microsoft.com" data-og-source-url="https://learn.microsoft.com/ko-kr/dotnet/csharp/programming-guide/concepts/async/#final-version" data-og-url="https://learn.microsoft.com/ko-kr/dotnet/csharp/programming-guide/concepts/async/"><a href="https://learn.microsoft.com/ko-kr/dotnet/csharp/programming-guide/concepts/async/#final-version" target="_blank" rel="noopener" data-source-url="https://learn.microsoft.com/ko-kr/dotnet/csharp/programming-guide/concepts/async/#final-version">
<div class="og-image">&nbsp;</div>
<div class="og-text">
<p class="og-title">C#의 비동기 프로그래밍</p>
<p class="og-desc">async, await 및 Task를 사용하여 비동기 프로그래밍을 지원하는 C# 언어에 대해 간략히 설명합니다.</p>
<p class="og-host">learn.microsoft.com</p>
</div>
</a></figure>
