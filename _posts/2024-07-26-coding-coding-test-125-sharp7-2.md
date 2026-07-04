---
title: "백준 코딩테스트 #7. 조건문 2"
excerpt: "백준 코딩테스트 #7. 조건문 2"
categories:
  - CodingTest
permalink: /coding/coding-test/125-sharp7-2/
tags:
  - "Coding Test"
  - "Baekjoon"
  - "C#"
  - "c++"
  - "If"
  - "node.js"
  - "Python"
toc: true
toc_sticky: true
date: 2024-07-26
last_modified_at: 2024-07-26
source_url: https://b-note.tistory.com/125
---

<h2>2번 시험 성적</h2>
<p><b>문제</b></p>
<p>시험&nbsp;점수를&nbsp;입력받아&nbsp;90&nbsp;~&nbsp;100점은&nbsp;A,&nbsp;80&nbsp;~&nbsp;89점은&nbsp;B,&nbsp;70&nbsp;~&nbsp;79점은&nbsp;C,&nbsp;60&nbsp;~&nbsp;69점은&nbsp;D,&nbsp;나머지&nbsp;점수는&nbsp;F를&nbsp;출력하는&nbsp;프로그램을&nbsp;작성하시오.</p>

<p><b>입력</b></p>
<p>첫째&nbsp;줄에&nbsp;시험&nbsp;점수가&nbsp;주어진다.&nbsp;시험&nbsp;점수는&nbsp;0보다&nbsp;크거나&nbsp;같고,&nbsp;100보다&nbsp;작거나&nbsp;같은&nbsp;정수이다.</p>

<p><b>출력</b></p>
<p>시험&nbsp;성적을&nbsp;출력한다.</p>

<h2>C++</h2>
<pre class="cpp"><code>#include &lt;iostream&gt;
using namespace std;
int main(){
    int score;
    cin &gt;&gt; score;
    char result;
    if (score &gt;= 90) {
        result = 'A';
    }
    else if (score &gt;= 80){
        result = 'B';
    }
    else if (score &gt;= 70){
        result = 'C';
    }
    else if (score &gt;= 60){
        result = 'D';
    }
    else {
        result = 'F';
    }
    cout &lt;&lt; result;
    return 0;
}</code></pre>

<h2>C#</h2>
<pre class="csharp"><code>using System;
class Program{
    static void Main(string[] args){
        int score = int.Parse(Console.ReadLine());
        char result;
        if (score &gt;= 90)
            result = 'A';
        else if (score &gt;= 80)
            result = 'B';
        else if (score &gt;= 70)
            result = 'C';
        else if (score &gt;= 60)
            result = 'D';
        else
            result = 'F';
        Console.WriteLine(result);
    }
}</code></pre>

<h2>Python</h2>
<pre class="python"><code>score = int(input());
if score &gt;= 90: 
    result = 'A'
elif score &gt;= 80:
    result = 'B'
elif score &gt;= 70:
    result = 'C'
elif score &gt;= 60:
    result = 'D'
else:
    result = 'F'
print(result);</code></pre>

<p>파이썬에서 조건문을 사용할 때는 들여 쓰기에 주의해야 한다.</p>

<h2>Node.js</h2>
<pre class="javascript"><code>const fs = require('fs');
const inputData = fs.readFileSync('/dev/stdin').toString().trim();
const score = parseInt(inputData, 10);
let result;
if (score &gt;= 90)
    result = 'A';
else if (score &gt;= 80)
    result = 'B';
else if (score &gt;= 70)
    result = 'C';
else if (score &gt;= 60)
    result = 'D';
else 
    result = 'F';

console.log(result);</code></pre>

<p>'fs' 모듈 사용해서 입력 처리</p>
