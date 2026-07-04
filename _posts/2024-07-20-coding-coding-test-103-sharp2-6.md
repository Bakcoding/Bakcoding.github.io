---
title: "백준 코딩테스트 #2. 입출력과 사칙연산 6"
excerpt: "백준 코딩테스트 #2. 입출력과 사칙연산 6"
categories:
  - CodingTest
permalink: /coding/coding-test/103-sharp2-6/
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
source_url: https://b-note.tistory.com/103
---

<h2>6번</h2>
<p><b>문제</b></p>
<p>두&nbsp;자연수&nbsp;A와&nbsp;B가&nbsp;주어진다.&nbsp;이때,&nbsp;A+B,&nbsp;A-B,&nbsp;A*B,&nbsp;A/B(몫),&nbsp;A% B(나머지)를&nbsp;출력하는&nbsp;프로그램을&nbsp;작성하시오.</p>

<p><b>입력</b></p>
<p>두&nbsp;자연수&nbsp;A와&nbsp;B가&nbsp;주어진다.&nbsp;(1&nbsp;&le;&nbsp;A,&nbsp;B&nbsp;&le;&nbsp;10,000)</p>

<p><b>출력</b></p>
<p>첫째&nbsp;줄에&nbsp;A+B,&nbsp;둘째&nbsp;줄에&nbsp;A-B,&nbsp;셋째&nbsp;줄에&nbsp;A*B,&nbsp;넷째&nbsp;줄에&nbsp;A/B,&nbsp;다섯째&nbsp;줄에&nbsp;A%B를&nbsp;출력한다.</p>

<h3>C++</h3>
<pre class="cpp"><code>#include &lt;iostream&gt;
using namespace std;
int main(){
    int a,b;
    cin &gt;&gt; a;
    cin &gt;&gt; b;
    cout &lt;&lt; a+b &lt;&lt; endl;
    cout &lt;&lt; a-b &lt;&lt; endl;
    cout &lt;&lt; a*b &lt;&lt; endl;
    cout &lt;&lt; a/b &lt;&lt; endl;
    cout &lt;&lt; a%b &lt;&lt; endl;
    
    return 0;
}</code></pre>

<p>줄바꾸기 endl 사용</p>

<h3>C#</h3>
<pre class="cpp"><code>using System;
class Program{
    static void Main(string[] args){
        string input = Console.ReadLine();
        string[] arr_input = input.Split(' ');
        int a = int.Parse(arr_input[0]);
        int b = int.Parse(arr_input[1]);
        Console.WriteLine(a+b);
        Console.WriteLine(a-b);
        Console.WriteLine(a*b);
        Console.WriteLine(a/b);
        Console.WriteLine(a%b);
    }
}</code></pre>

<p>ReadLine으로 입력을 한 줄로 받고 string.Split을 사용해서 공백으로 두 값을 구분하여 사용한다.</p>

<h3>Python</h3>
<pre class="python"><code>str = input()
arr = str.split(' ')
a = int(arr[0])
b = int(arr[1])
print(a+b, a-b, a*b, a//b, a%b, sep='\n')</code></pre>

<p>파이썬의 경우 '/' , '//' 연산자가 존재한다.</p>
<p>앞의 두 언어들은 연산하는 두 값이 모두 int 타입이기 때문에 / 연산자를 사용하여 계산하게 되면 결과도 정수형으로 반환되기 때문에 소수점은 버려지게 된다. 하지만 파이썬의 경우 정수형간의 나눗셈은 float으로 반환하기 때문에 문제에서 몫만을 출력해야 하고 이를 위해서는 몫을 구하는 연산자 '//'를 사용해야 한다.</p>
