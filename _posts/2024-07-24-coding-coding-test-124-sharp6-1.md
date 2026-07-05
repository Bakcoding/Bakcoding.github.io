---
title: "백준 코딩테스트 #6. 조건문 1"
excerpt: "백준 코딩테스트 #6. 조건문 1"
categories:
  - CodingTest
permalink: /coding/coding-test/124-sharp6-1/
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
date: 2024-07-24
last_modified_at: 2024-07-24
source_url: https://b-note.tistory.com/124
---

<h2>1번 두 수 비교하기</h2>
<p><b>문제</b></p>
<p>두&nbsp;정수&nbsp;A와&nbsp;B가&nbsp;주어졌을&nbsp;때,&nbsp;A와&nbsp;B를&nbsp;비교하는&nbsp;프로그램을&nbsp;작성하시오.</p>

<p><b>입력</b></p>
<p><span>첫째&nbsp;줄에&nbsp;A와&nbsp;B가&nbsp;주어진다.&nbsp;A와&nbsp;B는&nbsp;공백&nbsp;한&nbsp;칸으로&nbsp;구분되어&nbsp;있다.</span></p>
<p style="text-align: start">&nbsp;</p>
<p style="text-align: start"><b>출력</b></p>
<p style="text-align: start">첫째&nbsp;줄에&nbsp;다음&nbsp;세&nbsp;가지&nbsp;중&nbsp;하나를&nbsp;출력한다.&nbsp;</p>
<p style="text-align: start">-&nbsp;A가&nbsp;B보다&nbsp;큰&nbsp;경우에는&nbsp;'&gt;'를&nbsp;출력한다.&nbsp;</p>
<p style="text-align: start">-&nbsp;A가&nbsp;B보다&nbsp;작은&nbsp;경우에는&nbsp;'&lt;'를&nbsp;출력한다.&nbsp;</p>
<p style="text-align: start">-&nbsp;A와&nbsp;B가&nbsp;같은&nbsp;경우에는&nbsp;'=='를&nbsp;출력한다.</p>
<p style="text-align: start">&nbsp;</p>
<h2>C++</h2>
<pre class="cpp"><code>#include &lt;iostream&gt;
#include &lt;string&gt;
using namespace std;
int main(){
    int a, b;
    cin &gt;&gt; a;
    cin &gt;&gt; b;
    string result = "";
    if (a &gt; b)
        result = "&gt;";
    else if (a &lt; b)
        result = "&lt;";
    else
        result = "==";
    cout &lt;&lt; result;
    return 0;
}</code></pre>

<h2>C#</h2>
<pre class="cpp"><code>using System;
class Program{
    static void Main(string[] args){
        string input = Console.ReadLine();
        string[] arr = input.Split(' ');
        int a = int.Parse(arr[0]);
        int b = int.Parse(arr[1]);
        if (a &gt; b) input = "&gt;";
        else if (a &lt; b) input = "&lt;";
        else input = "==";
        Console.WriteLine(input);
    }
}</code></pre>

<h2>Python</h2>
<pre class="cpp"><code>strInput = input()
arrInput = strInput.split(' ')
a = int(arrInput[0])
b = int(arrInput[1])
if a &gt; b: 
    c = "&gt;"
elif a &lt; b: 
    c = "&lt;"
else: 
    c = "=="
print(c);</code></pre>

<p>파이썬의 경우 조건문 작성 시</p>
<p><b>if 조건 :</b></p>
<p><b>elif 조건 :</b></p>
<p><b>else :</b></p>

<p>방식으로 작성한다. 그리고 중요한 점은 파이썬의 변수의 범위는 함수 단위로 이루어지기 때문에 조건문 내부에서 선언된 c는 외부에서도 접근이 가능하다. 하지만 함수 내에서 변수를 선언했다면 외부에서 접근할 수 없다.</p>

<h2>Node.js</h2>
<pre class="javascript"><code>const readline = require('readline');
const rl = readline.createInterface({
    input:process.stdin,
    output:process.stdout
});

rl.question('', (answer) =&gt;{
    let input = answer;
    let arr = input.split(' ');
    let a = parseInt(arr[0], 10);
    let b = parseInt(arr[1], 10);
    let result;
    if (a &gt; b) {
        result = "&gt;";   
    }
    else if (a &lt; b) {
        result = "&lt;";    
    }
    else {
        result = "==";  
    } 
    process.stdout.write(result);
    rl.close();
});</code></pre>

<p>node.js 에서 입력은 모듈을 사용하여 처리한다.</p>

<p>1. 'readline' 모듈을 사용하여 입력 인터페이스를 생성한다.</p>
<p>2. 'rl.question'을 사용하여 사용자로부터 숫자를 입력받는다.</p>

<p>더 축약한 코드</p>
<pre class="javascript"><code>const readline = require('readline');
const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

rl.question('', (answer) =&gt; {
    const [a, b] = answer.split(' ').map(Number);
    const result = (a &gt; b) ? '&gt;' : (a &lt; b) ? '&lt;' : '==';
    process.stdout.write(result);
    rl.close();
});</code></pre>

<p>map을 사용하여 입력된 값을 저장하고 삼항 연산자로 조건을 비교하여 코드를 단축시켰다.</p>
