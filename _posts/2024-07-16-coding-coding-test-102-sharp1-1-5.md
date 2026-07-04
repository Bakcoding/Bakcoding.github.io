---
title: "백준 코딩테스트 #1. 입출력과 사칙연산 (1 ~ 5)"
excerpt: "백준 코딩테스트 #1. 입출력과 사칙연산 (1 ~ 5)"
categories:
  - CodingTest
permalink: /coding/coding-test/102-sharp1-1-5/
tags:
  - "Coding Test"
  - "Baekjoon"
  - "C#"
  - "c++"
  - "output"
  - "Python"
  - "코딩 테스트"
toc: true
toc_sticky: true
date: 2024-07-16
last_modified_at: 2024-07-16
source_url: https://b-note.tistory.com/102
---

<h2>1번</h2>
<p style="color: #333333; text-align: start;"><b>문제</b></p>
<p style="color: #333333; text-align: start;">Hello&nbsp;World! 를&nbsp;출력하시오.</p>
<p style="color: #333333; text-align: start;">&nbsp;</p>
<p style="color: #333333; text-align: start;"><b>출력</b></p>
<p style="color: #333333; text-align: start;">Hello&nbsp;World! 를&nbsp;출력하시오.</p>

<h3>C++</h3>
<pre class="cpp"><code>#include &lt;iostream&gt;
using namespace std;
int main(){
    cout &lt;&lt; "Hello World!";
    return 0;
}</code></pre>

<p>C++ 너무 오랜만에 하다 보니 처음에 입출력 라이브러리 이름이 기억이 안 났다.</p>
<p>iosteam (input/output stream) 입력과 출력의 기능을 사용할 수 있는 라이브러리이다.&nbsp;</p>
<p>cout을 사용하려면 std:: 네임스페이스를 사용해야 하는데 이걸 생략하기 위해서 using으로 네임스페이스를 선언한다.</p>

<h3>C#</h3>
<pre class="csharp"><code>using System;
class Program{
    static void Main(string[] args){
        Console.WriteLine("Hello World!");
    }
}</code></pre>
<p><br />System&nbsp;네임스페이스에&nbsp;포함된&nbsp;Console&nbsp;클래스의&nbsp;함수인&nbsp;WirteLine을&nbsp;사용해서&nbsp;문자를&nbsp;출력한다.</p>

<h3>Python</h3>
<pre class="csharp"><code>print("Hello World!")</code></pre>
<p><br />이렇게&nbsp;보니&nbsp;파이썬의&nbsp;간단함에&nbsp;새삼스럽게&nbsp;놀란다.</p>

<h2>2번</h2>
<p style="color: #333333; text-align: start;"><b>문제</b></p>
<p style="color: #333333; text-align: start;">두&nbsp;정수&nbsp;A와&nbsp;B를&nbsp;입력받은&nbsp;다음,&nbsp;A+B를&nbsp;출력하는&nbsp;프로그램을&nbsp;작성하시오.</p>
<p style="color: #333333; text-align: start;">&nbsp;</p>
<p style="color: #333333; text-align: start;"><b>입력</b></p>
<p style="color: #333333; text-align: start;">첫째&nbsp;줄에&nbsp;A와&nbsp;B가&nbsp;주어진다.&nbsp;(0&nbsp;&lt;&nbsp;A,&nbsp;B&nbsp;&lt;&nbsp;10)</p>
<p style="color: #333333; text-align: start;">&nbsp;</p>
<p style="color: #333333; text-align: start;"><b>출력</b></p>
<p style="color: #333333; text-align: start;">첫째 줄에 A+B를 출력한다.</p>
<p style="color: #333333; text-align: start;">&nbsp;</p>
<h3>C++</h3>
<div style="background-color: #ffffff; color: #333333; text-align: start;">
<pre class="python"><code>#include &lt;iostream&gt;
using namespace std;
int main(){
    int a, b;
    cin &gt;&gt; a;
    cin &gt;&gt; b;
    cout &lt;&lt; a + b;
}</code></pre>
</div>

<p>입력받은 값을 저장하기 위한 변수 a, b 선언 후 합을 출력</p>

<h3>C#</h3>
<pre class="cpp"><code>using System;
class Program
{
    static void Main(string[] args)
    {
        string str = Console.ReadLine();
        string[] arr = str.Split(' ');
        int a = int.Parse(arr[0]);
        int b = int.Parse(arr[1]);
        Console.WriteLine(a + b);
    }
}</code></pre>

<p>채점 시 한 줄에 두 값을 모두 주기 때문에 Read 사용 시 입력을 제대로 받지 못한다.</p>
<p>따라서 문자열로 받은 다음 값을 잘라서 정수로 변환하여 출력하여야 한다.</p>

<h3>Python</h3>
<pre class="csharp"><code>str = input()
arr = str.split(' ')
a = int(arr[0])
b = int(arr[1])
print(a+b)</code></pre>

<p>파이썬도 마찬가지로 문자로 입력받은 다음 값을 잘라서 처리한다.</p>

<p>4번 문제까지는 연산 기호만 달라서 문제만 풀고 따로 남기지 않는다.</p>

<h2>5번</h2>
<p style="color: #333333; text-align: start;"><b>문제</b></p>
<p style="color: #333333; text-align: start;">두&nbsp;정수&nbsp;A와&nbsp;B를&nbsp;입력받은&nbsp;다음,&nbsp;A/B를&nbsp;출력하는&nbsp;프로그램을&nbsp;작성하시오.</p>
<p style="color: #333333; text-align: start;">&nbsp;</p>
<p style="color: #333333; text-align: start;"><b>입력</b></p>
<p style="color: #333333; text-align: start;">첫째&nbsp;줄에&nbsp;A와&nbsp;B가&nbsp;주어진다.&nbsp;(0&nbsp;&lt;&nbsp;A,&nbsp;B&nbsp;&lt;&nbsp;10)</p>
<p style="color: #333333; text-align: start;">&nbsp;</p>
<p style="color: #333333; text-align: start;"><b>출력</b></p>
<p style="color: #333333; text-align: start;">첫째 줄에 A/B를 출력한다. 실제 정답과 출력값의 절대오차 또는 상대오차가 10의 -9승 이하이면 정답이다.</p>
<p style="color: #333333; text-align: start;">&nbsp;</p>
<h3 style="color: #333333; text-align: start;">C++</h3>
<pre class="cpp"><code>#include &lt;iostream&gt;
using namespace std;
int main(){
    double a, b;
    cin &gt;&gt; a;
    cin &gt;&gt; b;
    double res = a/b;
    cout.precision(10);
    cout &lt;&lt; res;
}</code></pre>

<p>소수점 자릿수를 정확하게 출력하기 위해서 추가 작업이 필요하다.</p>

<p>오차를 인정하는 범위가 있기 때문에 소수점 9자리까지 구해야 한다.</p>

<p>cout.precision(n)은 n자리까지 정수부+소수부의 n개까지의 수를 표시해 준다.</p>

<p>문제에서 대입하는 수의 범위는 나누었을 때 정수부가 1자리 이하이기 때문에 precision(10)을 하면 소수점 9자리까지 나오게 된다.</p>

<h3>C#</h3>
<pre class="cpp"><code>using System;
class Program
{
    static void Main(string[] args)
    {
        string str = Console.ReadLine();
        string[] arr = str.Split(' ');
        double a = double.Parse(arr[0]);
        double b = double.Parse(arr[1]);
        Console.WriteLine(a / b);
    }
}</code></pre>

<p>float의 정확도는 7번째 자리이기 때문에 double을 사용한다.</p>

<h3>Python</h3>
<pre class="cpp"><code>str = input()
arr = str.split(' ')
a = float(arr[0])
b = float(arr[1])
print(a/b)</code></pre>

<p>파이썬의 경우 double은 따로 없으며 float이 C의 double을 기반으로 15자리까지의 정확도를 가진다.</p>

<p>그 이상의 자릿수를 사용하기 위해서는 별도의 모듈인 decimal을 사용해야 한다.</p>
