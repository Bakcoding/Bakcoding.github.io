---
title: "백준 코딩테스트 #4. 입출력과 사칙연산 (8 ~ 10)"
excerpt: "백준 코딩테스트 #4. 입출력과 사칙연산 (8 ~ 10)"
categories:
  - CodingTest
permalink: /coding/coding-test/105-sharp4-8-10/
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
source_url: https://b-note.tistory.com/105
---

<h2>8번 "1998년생인 내가 태국에서는 2541년생?!"</h2>
<p>식을&nbsp;직접&nbsp;세워서&nbsp;계산하는&nbsp;문제</p>

<p><b>문제</b></p>
<p>ICPC&nbsp;Bangkok&nbsp;Regional에&nbsp;참가하기&nbsp;위해&nbsp;수완나품&nbsp;국제공항에&nbsp;막&nbsp;도착한&nbsp;팀&nbsp;레드시프트&nbsp;일행은&nbsp;눈을&nbsp;믿을&nbsp;수&nbsp;없었다.&nbsp;공항의&nbsp;대형&nbsp;스크린에&nbsp;올해가&nbsp;2562년이라고&nbsp;적혀&nbsp;있던&nbsp;것이었다.&nbsp;불교&nbsp;국가인&nbsp;태국은&nbsp;불멸기원(佛滅紀元),&nbsp;즉&nbsp;석가모니가&nbsp;열반한&nbsp;해를&nbsp;기준으로&nbsp;연도를&nbsp;세는&nbsp;불기를&nbsp;사용한다.&nbsp;반면,&nbsp;우리나라는&nbsp;서기&nbsp;연도를&nbsp;사용하고&nbsp;있다.&nbsp;불기&nbsp;연도가&nbsp;주어질&nbsp;때&nbsp;이를&nbsp;서기&nbsp;연도로&nbsp;바꿔&nbsp;주는&nbsp;프로그램을&nbsp;작성하시오.</p>

<p><b>입력</b></p>
<p>서기&nbsp;연도를&nbsp;알아보고&nbsp;싶은&nbsp;불기&nbsp;연도&nbsp;y가&nbsp;주어진다.&nbsp;(1000&nbsp;&le;&nbsp;y&nbsp;&le;&nbsp;3000)</p>

<p><b>출력</b></p>
<p>불기&nbsp;연도를&nbsp;서기&nbsp;연도로&nbsp;변환한&nbsp;결과를&nbsp;출력한다.</p>

<p>문제를 풀기 위해서는 불기와 서기의 차이에 대한 정보가 필요한데 제목에 힌트가 있다. 두 값의 차인 543의 값을 사용해서 불기를 서기로 표시할 수 있다.</p>

<p>"불기 - 543 = 서기"</p>

<h2>C++</h2>
<pre class="cpp"><code>#include &lt;iostream&gt;
using namespace std;
int main(){
    int input;
    cin &gt;&gt; input;
    cout &lt;&lt; input - 543;
}</code></pre>

<h2>C#</h2>
<pre class="cpp"><code>using System;
class Program{
    static void Main(string[] args){
        string input = Console.ReadLine();
        int val = int.Parse(input);
        Console.WriteLine(val - 543);
    }
}</code></pre>

<h2>Python</h2>
<pre class="python"><code>str = input()
val = int(str)
print(val - 543)</code></pre>

<p>C#과 Python의 경우에는 입력은 문자열로만 반환되기 때문에 이를 정수계산하기 위해서는 타입 변환의 과정이 필요하다.</p>

<h2>9번 "나머지"</h2>
<p><b>문제</b></p>
<p>(A+B)%C는&nbsp;((A%C)&nbsp;+&nbsp;(B%C))%C&nbsp;와&nbsp;같을까?&nbsp;(A&times;B)%C는&nbsp;((A%C)&nbsp;&times;&nbsp;(B%C))%C&nbsp;와&nbsp;같을까?&nbsp;세&nbsp;수&nbsp;A,&nbsp;B,&nbsp;C가&nbsp;주어졌을&nbsp;때,&nbsp;위의&nbsp;네&nbsp;가지&nbsp;값을&nbsp;구하는&nbsp;프로그램을&nbsp;작성하시오.</p>

<p><b>입력</b></p>
<p>첫째&nbsp;줄에&nbsp;A,&nbsp;B,&nbsp;C가&nbsp;순서대로&nbsp;주어진다.&nbsp;(2&nbsp;&le;&nbsp;A,&nbsp;B,&nbsp;C&nbsp;&le;&nbsp;10000)</p>

<p><b>출력</b></p>
<p>첫째&nbsp;줄에&nbsp;(A+B)%C,&nbsp;둘째&nbsp;줄에&nbsp;((A%C)&nbsp;+&nbsp;(B%C))%C,&nbsp;셋째&nbsp;줄에&nbsp;(A&times;B)%C,&nbsp;넷째&nbsp;줄에&nbsp;((A%C)&nbsp;&times;&nbsp;(B%C))%C를&nbsp;출력한다.</p>

<h2>C++</h2>
<pre class="cpp"><code>#include &lt;iostream&gt;
using namespace std;
int main(){
    int a, b, c;
    cin &gt;&gt; a;
    cin &gt;&gt; b;
    cin &gt;&gt; c;
    cout &lt;&lt; (a+b)%c &lt;&lt; endl;
    cout &lt;&lt; ((a%c)+(b%c))%c &lt;&lt; endl;
    cout &lt;&lt; (a*b)%c &lt;&lt; endl;
    cout &lt;&lt; ((a%c)*(b%c))%c &lt;&lt; endl;
    return 0;
}</code></pre>

<h2>C#</h2>
<pre class="csharp"><code>using System;
class Program{
    static void Main(string[] args){
        string input = Console.ReadLine();
        string[] arr = input.Split(" ");
        int a = int.Parse(arr[0]);
        int b = int.Parse(arr[1]);
        int c = int.Parse(arr[2]);
        
        Console.WriteLine((a+b)%c);
        Console.WriteLine(((a%c)+(b%c))%c);
        Console.WriteLine((a*b)%c);
        Console.WriteLine(((a%c)*(b%c))%c);
    }
}</code></pre>

<h2>Python</h2>
<pre class="python"><code>str = input();
arr = str.split(" ");
a = int(arr[0]);
b = int(arr[1]);
c = int(arr[2]);
print((a+b)%c);
print(((a%c)+(b%c))%c);
print((a*b)%c);
print(((a%c)*(b%c))%c);</code></pre>

<p>이 문제는 받아쓰기만 틀리지 않고 잘하면 어려움이 없는 문제였다.</p>

<h2>10번 "곱셈"</h2>
<p><b>문제</b></p>
<p>(세&nbsp;자리&nbsp;수)&nbsp;&times;&nbsp;(세&nbsp;자리&nbsp;수)는&nbsp;다음과&nbsp;같은&nbsp;과정을&nbsp;통하여&nbsp;이루어진다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="306" data-origin-height="183"><span data-alt="https://www.acmicpc.net/problem/2588"><img src="/assets/images/posts/2024/07/20/105-1.png" loading="lazy" width="306" height="183" data-origin-width="306" data-origin-height="183"/></span><figcaption>https://www.acmicpc.net/problem/2588</figcaption>
</figure>
</p>

<p>(1)과&nbsp;(2)위치에&nbsp;들어갈&nbsp;세&nbsp;자리&nbsp;자연수가&nbsp;주어질&nbsp;때&nbsp;(3),&nbsp;(4),&nbsp;(5),&nbsp;(6)위치에&nbsp;들어갈&nbsp;값을&nbsp;구하는&nbsp;프로그램을&nbsp;작성하시오.</p>

<p><b>입력</b></p>
<p>첫째&nbsp;줄에&nbsp;(1)의&nbsp;위치에&nbsp;들어갈&nbsp;세&nbsp;자리&nbsp;자연수가,&nbsp;둘째&nbsp;줄에&nbsp;(2)의&nbsp;위치에&nbsp;들어갈&nbsp;세 자리&nbsp;자연수가&nbsp;주어진다.</p>

<p><b>출력</b></p>
<p>첫째&nbsp;줄부터&nbsp;넷째&nbsp;줄까지&nbsp;차례대로&nbsp;(3),&nbsp;(4),&nbsp;(5),&nbsp;(6)에&nbsp;들어갈&nbsp;값을&nbsp;출력한다.</p>

<p>우선 입력받은 두 값을 곱셈하여 저장해 놓고 첫 번째 입력받은 값을 기준으로 하고 두 번째 입력값을 자릿수별로 잘라서 변수에 저장한다. 그리고 각 자릿수마다 기준 값과 곱한 값을 출력하고 처음 계산한 곱셈을 출력하면 될듯하다.</p>

<h2>C++</h2>
<pre class="cpp"><code>#include &lt;iostream&gt;
#include &lt;string&gt;
using namespace std;
int main(){
    int val1;
    int val2;
    cin &gt;&gt; val1;
    cin &gt;&gt; val2;
    int result4 = val1*val2;
    
    string str = to_string(val2);
    int a = str[2] - '0';
    int b = str[1] - '0';
    int c = str[0] - '0';
    
    int result1 = val1*a;
    int result2 = val1*b;
    int result3 = val1*c;
    
    cout &lt;&lt; result1 &lt;&lt; endl;
    cout &lt;&lt; result2 &lt;&lt; endl;
    cout &lt;&lt; result3 &lt;&lt; endl;
    cout &lt;&lt; result4 &lt;&lt; endl;
    
    return 0;
}</code></pre>

<h2>C#</h2>
<pre class="cpp"><code>using System;
class Program{
    static void Main(string[] args){
        string str_1 = Console.ReadLine();
        string str_2 = Console.ReadLine();
        
        int val_1 = int.Parse(str_1);
        int val_2 = int.Parse(str_2);
        int a = (int)char.GetNumericValue(str_2[2]);
        int b = (int)char.GetNumericValue(str_2[1]);
        int c = (int)char.GetNumericValue(str_2[0]);
        
        int result_1 = val_1 * a;
        int result_2 = val_1 * b;
        int result_3 = val_1 * c;
        int result_4 = val_1 * val_2;
        
        Console.WriteLine(result_1);
        Console.WriteLine(result_2);
        Console.WriteLine(result_3);
        Console.WriteLine(result_4);
    }
}</code></pre>

<p>C#에서 단일 문자의 경우 int.Parse는 에러가 발생한다. 따라서 문자를 정수로 전환하기 위해서 char.GetNumericValue를 사용한다.&nbsp;</p>

<p>또는 문자가 숫자일 경우에는 아스키코드를 활용해서 정수로 변환할 수 있다.</p>
<p>아스키코드에서 '0' 문자는 48이다. 그리고 그 뒤로 연속으로 값이 증가하는데 즉 '1' - '0' = 49 - 48 이므로 결과는 1로 정수 값을 구할 수 있게 된다.</p>

<pre class="cpp"><code>int a = (int)char.GetNumericValue(str_2[2]);
int b = (int)char.GetNumericValue(str_2[1]);
int c = (int)char.GetNumericValue(str_2[0]);

// ASCII
int a = str_2[2] - '0';
int b = str_2[1] - '0';
int c = str_2[0] - '0';</code></pre>

<h2>Python</h2>
<pre class="cpp"><code>str_1 = input()
str_2 = input()
val_1 = int(str_1)
val_2 = int(str_2)
a = int(str_2[2])
b = int(str_2[1])
c = int(str_2[0])
result_1 = val_1 * a
result_2 = val_1 * b
result_3 = val_1 * c
result_4 = val_1 * val_2
print(result_1)
print(result_2)
print(result_3)
print(result_4)</code></pre>
