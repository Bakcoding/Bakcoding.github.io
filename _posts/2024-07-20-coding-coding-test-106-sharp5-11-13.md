---
title: "백준 코딩테스트 #5. 입출력과 사칙연산 (11 ~ 13)"
excerpt: "백준 코딩테스트 #5. 입출력과 사칙연산 (11 ~ 13)"
categories:
  - CodingTest
permalink: /coding/coding-test/106-sharp5-11-13/
tags:
  - "Coding Test"
  - "Baekjoon"
  - "C#"
  - "c++"
  - "Python"
  - "백준"
  - "코딩테스트"
toc: true
toc_sticky: true
date: 2024-07-20
last_modified_at: 2024-07-20
source_url: https://b-note.tistory.com/106
---

<h2>11번 "꼬마 정민"</h2>
<p><b>문제</b></p>
<p>꼬마&nbsp;정민이는&nbsp;이제&nbsp;A&nbsp;+&nbsp;B&nbsp;정도는&nbsp;쉽게&nbsp;계산할&nbsp;수&nbsp;있다.&nbsp;이제&nbsp;A&nbsp;+&nbsp;B&nbsp;+&nbsp;C를&nbsp;계산할&nbsp;차례이다!</p>

<p><b>입력</b></p>
<p>첫 번째 줄에 A, B, C (1 &le; A, B, C &le; 10^12)이 공백을 사이에 두고 주어진다.</p>

<p><b>출력</b></p>
<p>A+B+C의&nbsp;값을&nbsp;출력한다.</p>

<h2>C++</h2>
<pre class="cpp"><code>#include &lt;iostream&gt;
using namespace std;
int main(){
    long long a,b,c;
    cin &gt;&gt; a;
    cin &gt;&gt; b;
    cin &gt;&gt; c;
    cout &lt;&lt; a+b+c;
    return 0;
}</code></pre>

<p>int 타입은 최대 - 2^31 ~ <span><span>2^31&minus;1까지의 정수를 저장할 수 있는데 입력받을 수 있는 수의 범위는 10^12이므로 이를 저장할 수 있는 long long 타입을 사용한다. (long long은 -2^63 ~ 2^63 &minus;1까지)</span></span></p>

<h2><span><span>C#</span></span></h2>
<pre class="csharp"><code>using System;
class Program{
    static void Main(string[] args){
        string str = Console.ReadLine();
        string[] arr = str.Split(" ");
        long a = long.Parse(arr[0]);
        long b = long.Parse(arr[1]);
        long c = long.Parse(arr[2]);
        Console.WriteLine(a+b+c);
    }
}</code></pre>

<p>C#의 int 범위는 - 2^31&nbsp; ~ 2^31-1, <span style="letter-spacing: 0px;">long 범위는 -2^31 ~ 2^31-1이다</span></p>

<h2><span style="letter-spacing: 0px;">Python</span></h2>
<pre class="python"><code>str = input()
arr = str.split(' ')
a = int(arr[0])
b = int(arr[1])
c = int(arr[2])
print(a+b+c)</code></pre>

<p>파이썬의 경우 int는 임의 정밀도로 정해진 범위가 없고 사용할 수 있는 만큼 값을 가질 수 있다.</p>

<h2>12번 "고양이"</h2>
<p>\,&nbsp;'&nbsp;등의&nbsp;문자에&nbsp;주의하며&nbsp;고양이를&nbsp;출력하는&nbsp;문제</p>

<p><b>문제</b></p>
<p>아래&nbsp;예제와&nbsp;같이&nbsp;고양이를&nbsp;출력하시오.<b></b></p>

<p><b>입력</b></p>
<p>없음.</p>

<p><b>출력<br /></b>고양이를&nbsp;출력한다.<b><br /></b></p>
<pre class="csharp"><code>\    /\
 )  ( ')
(  /  )
 \(__)|</code></pre>

<p>예제의 고양이와 동일하게 출력을 하면 되는 문제이다.</p>

<h2>C++</h2>
<pre class="cpp"><code>#include &lt;iostream&gt;
using namespace std;
int main(){
    cout &lt;&lt; "\\    /\\" &lt;&lt; endl;
    cout &lt;&lt; " )  ( \')" &lt;&lt; endl;
    cout &lt;&lt; "(  /  ) " &lt;&lt; endl;
    cout &lt;&lt; " \\(__)|" &lt;&lt; endl;
    return 0;
}</code></pre>

<p>백슬래시(\), 작은따옴표('), 큰 따옴표(") 등의 문자는 문자열 내에서 별도의 기능을 가질 수 있는 문자들은 문자 자체로 사용하기 위해서는 앞에 백슬래시를 추가해서 이스케이프 시퀀스를 사용해야 한다.</p>

<h2>C#</h2>
<pre class="csharp"><code>using System;
class Program{
    static void Main(string[] args){
        Console.WriteLine("\\    /\\");
        Console.WriteLine(" )  ( \')");
        Console.WriteLine("(  /  )");
        Console.WriteLine(" \\(__)|");
    }
}</code></pre>

<p>C#도 동일하게 이스케이프 시퀀스를 사용해서 표현한다.</p>

<h2>Python</h2>
<pre class="python"><code>print("\\    /\\")
print(" )  ( \')")
print("(  /  )")
print(" \\(__)|")</code></pre>

<p>이스케이프 시퀀스는 여러 프로그래밍 언어에서 비슷한 목적을 가지고 사용되지만, 모든 언어에서 동일하게 사용되지는 않는다. 대부분의 경우 C 언어에서 유래한 이스케이프 표준을 따르면서 각 언어마다 고유한 확장이나 차이를 가지고 있다.</p>

<h2>13번 개</h2>
<p>",&nbsp;`,&nbsp;\&nbsp;등의&nbsp;문자에&nbsp;주의하며&nbsp;개를&nbsp;출력하는&nbsp;문제</p>

<p><b>문제</b></p>
<p>아래&nbsp;예제와&nbsp;같이&nbsp;개를&nbsp;출력하시오.<b></b></p>

<p><b>입력</b></p>
<p>없음.</p>

<p><b>출력</b></p>
<p>개를&nbsp;출력한다.</p>
<pre class="cpp"><code>|\_/|
|q p|   /}
( 0 )"""\
|"^"`    |
||_/=\\__|</code></pre>

<h2>C++</h2>
<pre class="csharp"><code>#include &lt;iostream&gt;
using namespace std;
int main(){
    cout &lt;&lt; "|\\_/|" &lt;&lt; endl;
    cout &lt;&lt; "|q p|   /}" &lt;&lt; endl;
    cout &lt;&lt; "( 0 )\"\"\"\\" &lt;&lt; endl;
    cout &lt;&lt; "|\"^\"`    |" &lt;&lt; endl;
    cout &lt;&lt; "||_/=\\\\__|" &lt;&lt; endl;
    return 0;
}</code></pre>


<h2>C#</h2>
<pre class="csharp"><code>using System;
class Program{
    static void Main(string[] args){
        Console.WriteLine("|\\_/|");
        Console.WriteLine("|q p|   /}");
        Console.WriteLine("( 0 )\"\"\"\\");
        Console.WriteLine("|\"^\"`    |");
        Console.WriteLine("||_/=\\\\__|");
    }
}</code></pre>

<h2>Python</h2>
<pre class="python"><code>print("|\\_/|");
print("|q p|   /}");
print("( 0 )\"\"\"\\");
print("|\"^\"`    |");
print("||_/=\\\\__|");</code></pre>
