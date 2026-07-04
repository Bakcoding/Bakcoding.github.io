---
title: "백준 코딩테스트 #3. 입출력과 사칙연산 7"
excerpt: "백준 코딩테스트 #3. 입출력과 사칙연산 7"
categories:
  - CodingTest
permalink: /coding/coding-test/104-sharp3-7/
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
source_url: https://b-note.tistory.com/104
---

<h2>7번 사칙연산 응용</h2>
<p><b>문제</b></p>
<p>준하는&nbsp;사이트에&nbsp;회원가입을&nbsp;하다가&nbsp;joonas라는&nbsp;아이디가&nbsp;이미&nbsp;존재하는&nbsp;것을&nbsp;보고&nbsp;놀랐다.&nbsp;준하는&nbsp;놀람을??!로&nbsp;표현한다.&nbsp;준하가&nbsp;가입하려고&nbsp;하는&nbsp;사이트에&nbsp;이미&nbsp;존재하는&nbsp;아이디가&nbsp;주어졌을&nbsp;때,&nbsp;놀람을&nbsp;표현하는&nbsp;프로그램을&nbsp;작성하시오.</p>

<p><b>입력</b></p>
<p>첫째&nbsp;줄에&nbsp;준하가&nbsp;가입하려고&nbsp;하는&nbsp;사이트에&nbsp;이미&nbsp;존재하는&nbsp;아이디가&nbsp;주어진다.&nbsp;아이디는&nbsp;알파벳&nbsp;소문자로만&nbsp;이루어져&nbsp;있으며,&nbsp;길이는&nbsp;50자를&nbsp;넘지&nbsp;않는다.</p>

<p><b>출력</b></p>
<p>첫째&nbsp;줄에&nbsp;준하의&nbsp;놀람을&nbsp;출력한다.&nbsp;놀람은&nbsp;아이디&nbsp;뒤에&nbsp;??!를&nbsp;붙여서&nbsp;나타낸다.</p>

<p>문제를 정리하면 채점시 이미 존재하는 아이디가 입력되고, 입력한 값 뒤에 ??! 를 붙여서 출력하면 된다.</p>

<h2>C++</h2>
<pre class="cpp"><code>#include &lt;iostream&gt;
#include &lt;string&gt;
using namespace std;
int main(){
    string id;
    cin &gt;&gt; id;
    cout &lt;&lt; id+"??!";
    return 0;
}</code></pre>

<p>입력받은 문자열 뒤에 "??!"를 붙여서 출력한다.</p>

<h2>C#</h2>
<pre class="csharp"><code>using System;
class Program{
    static void Main(string[] args){
        string id = Console.ReadLine();
        Console.WriteLine(id+"??!");
    }
}</code></pre>
<h2><br />Python</h2>
<pre class="csharp"><code>id = input();
print(id+"??!")</code></pre>
