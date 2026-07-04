---
title: "백준 코딩테스트 #8. 조건문 3"
excerpt: "백준 코딩테스트 #8. 조건문 3"
categories:
  - CodingTest
permalink: /coding/coding-test/126-sharp8-3/
tags:
  - "Coding Test"
  - "Baekjoon"
  - "C#"
  - "c++"
  - "If"
  - "node.js"
  - "Python"
  - "백준"
  - "코딩 테스트"
toc: true
toc_sticky: true
date: 2024-07-26
last_modified_at: 2024-07-26
source_url: https://b-note.tistory.com/126
---

<h2>3번 윤년</h2>
<p><b>문제</b></p>
<p>연도가&nbsp;주어졌을&nbsp;때,&nbsp;윤년이면&nbsp;1,&nbsp;아니면&nbsp;0을&nbsp;출력하는&nbsp;프로그램을&nbsp;작성하시오.&nbsp;윤년은&nbsp;연도가&nbsp;4의&nbsp;배수이면서,&nbsp;100의&nbsp;배수가&nbsp;아닐&nbsp;때&nbsp;또는&nbsp;400의&nbsp;배수일&nbsp;때이다.&nbsp;예를&nbsp;들어,&nbsp;2012년은&nbsp;4의&nbsp;배수이면서&nbsp;100의&nbsp;배수가&nbsp;아니라서&nbsp;윤년이다.&nbsp;1900년은&nbsp;100의&nbsp;배수이고&nbsp;400의&nbsp;배수는&nbsp;아니기&nbsp;때문에&nbsp;윤년이&nbsp;아니다.&nbsp;하지만,&nbsp;2000년은&nbsp;400의&nbsp;배수이기&nbsp;때문에&nbsp;윤년이다.</p>

<p><b>입력</b></p>
<p>첫째&nbsp;줄에&nbsp;연도가&nbsp;주어진다.&nbsp;연도는&nbsp;1보다&nbsp;크거나&nbsp;같고,&nbsp;4000보다&nbsp;작거나&nbsp;같은&nbsp;자연수이다.</p>

<p><b>출력</b></p>
<p>첫째&nbsp;줄에&nbsp;윤년이면&nbsp;1,&nbsp;아니면&nbsp;0을&nbsp;출력한다.</p>

<p>연도가 4의 배수 &amp;&amp; (100의 배수가 아닐 때&nbsp; || 400의 배수일 때)</p>

<h2>C++</h2>
<pre class="cpp"><code>#include &lt;iostream&gt;
using namespace std;
int main(){
    int input;
    cin &gt;&gt; input;
    char result;
    if ((input % 4) == 0 &amp;&amp; ((input % 100) != 0 || (input % 400) == 0))
        result = '1';
    else
        result = '0';
    cout &lt;&lt; result;
    return 0;
}</code></pre>

<p>배수인지 확인할 때는 나머지가 0인지를 확인하면 된다.</p>

<h2>C#</h2>
<pre class="python"><code>using System;
class Program{
    static void Main(string[] args){
        int input = int.Parse(Console.ReadLine());
        char result;
        if ((input % 4) == 0 &amp;&amp; ((input % 100) != 0 || (input % 400) == 0))
            result = '1';
        else
            result = '0';
        Console.WriteLine(result);
    }
}</code></pre>

<h2>Python</h2>
<pre class="python"><code>inputData = int(input());
if inputData % 4 == 0 and (inputData % 100 != 0 or inputData % 400 == 0):
    result = '1';
else:
    result = '0';
print(result);</code></pre>

<p>파이썬의 논리 연산자는 and, or, not으로 작성한다.</p>

<h2>Node.js</h2>
<pre class="javascript"><code>const fs = require('fs');
const input = fs.readFileSync('/dev/stdin').toString().trim();
const year = parseInt(input, 10);
let result;
if ((input % 4) == 0 &amp;&amp; ((input % 100) != 0 || (input % 400) == 0))
    result = '1';
else
    result = '0';
console.log(result);</code></pre>
