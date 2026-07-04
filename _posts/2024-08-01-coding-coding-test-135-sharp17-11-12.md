---
title: "백준 코딩테스트 #17. 반복문 (11, 12)"
excerpt: "백준 코딩테스트 #17. 반복문 (11, 12)"
categories:
  - CodingTest
permalink: /coding/coding-test/135-sharp17-11-12/
tags:
  - "Coding Test"
  - "Baekjoon"
  - "C#"
  - "c++"
  - "node.js"
  - "Python"
  - "백준"
  - "코딩 테스트"
toc: true
toc_sticky: true
date: 2024-08-01
last_modified_at: 2024-08-01
source_url: https://b-note.tistory.com/135
---

<h2>11번 A+B - 5</h2>
<p><b>문제</b></p>
<p>두&nbsp;정수&nbsp;A와&nbsp;B를&nbsp;입력받은&nbsp;다음,&nbsp;A+B를&nbsp;출력하는&nbsp;프로그램을&nbsp;작성하시오.</p>

<p><b>입력</b></p>
<p>입력은&nbsp;여러&nbsp;개의&nbsp;테스트&nbsp;케이스로&nbsp;이루어져&nbsp;있다.&nbsp;</p>
<p>각&nbsp;테스트&nbsp;케이스는&nbsp;한&nbsp;줄로&nbsp;이루어져&nbsp;있으며,&nbsp;각&nbsp;줄에&nbsp;A와&nbsp;B가&nbsp;주어진다.&nbsp;(0&nbsp;&lt;&nbsp;A,&nbsp;B&nbsp;&lt;&nbsp;10)&nbsp;</p>
<p>입력의&nbsp;마지막에는&nbsp;0&nbsp;두&nbsp;개가&nbsp;들어온다.</p>

<p><b>출력</b></p>
<p>각&nbsp;테스트&nbsp;케이스마다&nbsp;A+B를&nbsp;출력한다.</p>

<p>이번에는 얼마나 반복할지 횟수를 정해주지 않고 마지막 케이스를 통해 루프를 종료하는 조건으로 사용하면 된다.</p>

<h3>C++</h3>
<pre class="cpp"><code>#include &lt;iostream&gt;
using namespace std;
int main(){
    cin.tie(NULL);
    ios_base::sync_with_stdio(false);
    while(true){
        int a, b;
        cin &gt;&gt; a &gt;&gt; b;
        if (a + b == 0) break;
        else
            cout &lt;&lt; a + b &lt;&lt; "\n";
    }
}</code></pre>

<p>두 값이 모두 0인 경우 반복문을 종료한다.</p>

<h3>C#</h3>
<pre class="csharp"><code>using System;
class Program{
    static void Main(string[] args){
        using (StreamWriter writer = new StreamWriter(Console.OpenStandardOutput())){
            while(true){
                int a, b;
                string input = Console.ReadLine();
                string[] arr = input.Split(' ');
                a = int.Parse(arr[0]);
                b = int.Parse(arr[1]);
                if (a + b == 0) break;
                else
                    Console.WriteLine(a + b);
            }
        }
    }
}</code></pre>

<h3>Python</h3>
<pre class="python"><code>while True:
    input_str = input()
    arr = input_str.split(' ')
    a = int(arr[0])
    b = int(arr[1])
    if a + b == 0:
        break
    print(a + b)</code></pre>

<p>파이썬의 while문 사용법을 숙지한다.</p>

<h3>Node.js</h3>
<pre class="javascript"><code>const fs = require('fs');
const input = fs.readFileSync('/dev/stdin', 'utf8').trim().split('\n');
for (const line of input){
    const [a, b] = line.split(' ').map(Number);
    if (a + b === 0) break;
    console.log(a + b);
}</code></pre>

<p>js는 입력을 한 번에 받은 다음 줄 별로 처리해야 하기 때문에 while이 아닌 for를 사용해서 처리한다.</p>

<h2>12번 A+B - 4</h2>
<p><b>문제</b></p>
<p>두&nbsp;정수&nbsp;A와&nbsp;B를&nbsp;입력받은&nbsp;다음,&nbsp;A+B를&nbsp;출력하는&nbsp;프로그램을&nbsp;작성하시오.</p>

<p><b>입력</b></p>
<p>입력은&nbsp;여러&nbsp;개의&nbsp;테스트&nbsp;케이스로&nbsp;이루어져&nbsp;있다.&nbsp;</p>
<p>각&nbsp;테스트&nbsp;케이스는&nbsp;한&nbsp;줄로&nbsp;이루어져&nbsp;있으며,&nbsp;각&nbsp;줄에&nbsp;A와&nbsp;B가&nbsp;주어진다.&nbsp;(0&nbsp;&lt;&nbsp;A,&nbsp;B&nbsp;&lt;&nbsp;10)</p>

<p><b>출력</b></p>
<p>각&nbsp;테스트&nbsp;케이스마다&nbsp;A+B를&nbsp;출력한다.</p>

<p>반복문 챕터의 마지막 문제이다. 종료 조건을 어떠한 것도 주지 않은 상태로 입력이 끝날 때까지 반복하여 처리해야 한다.</p>

<h3>C++</h3>
<pre class="cpp"><code>#include &lt;iostream&gt;
using namespace std;
int main(){
    int a, b;
    cin.tie(NULL);
    ios_base::sync_with_stdio(false);
    while(cin &gt;&gt; a &gt;&gt; b){
        if (a + b == 0)
            break;
        cout &lt;&lt; a + b &lt;&lt; "\n";
    }
    return 0;
}</code></pre>

<p>cin &gt;&gt; a &gt;&gt; b를 조건으로 체크하여 입력이 더 이상 없는 경우를 판단한다.</p>

<p>조건으로 사용하게 되면 EOF(End of File)에 도달하여 더 이상 입력이 없거나 잘못된 값이 입력된 경우 반복문이 종료된다.</p>

<pre class="csharp"><code>using System;
class Program{
    static void Main(string[] args){
        using (StreamWriter writer = new StreamWriter(Console.OpenStandardOutput())){
            while (true){
                string input = Console.ReadLine();
                if (input == null) break;
                string[] arr = input.Split(' ');
                int a = int.Parse(arr[0]);
                int b = int.Parse(arr[1]);
                Console.WriteLine(a+b);
            }
        }
    }
}</code></pre>
<p><br />C#에서 string의 초기화값은 null이기 때문에 input이 없는지 확인하기 위해서 null과 비교하여 검사한다.</p>

<h3>Python</h3>
<pre class="python"><code>import sys
input = sys.stdin.read
arr = input().splitlines()
for line in arr:
    a, b = map(int, line.split())
    print(a+b)</code></pre>

<p>기존 input 함수를 표준 입력으로 변경하여 전체 입력된 정보를 저장한 다음 배열을 읽어서 처리하여 입력된 값들만 처리한다.</p>

<p>또 다른 방법으로는 입력이 더 이상 없을 때 발생하는 에러를 체크해서 루프를 종료시킬 수 있다.</p>

<pre class="python"><code>while True:
    try:
        input_str = input()
    except EOFError:
        break
    arr = input_str.split()
    a = int(arr[0]);
    b = int(arr[1]);
    print(a+b)</code></pre>

<p>에러가 발생하는 지점을 예외처리하기 위해서 try ~ except를 사용한다. 입력이 더 이상 없을 때는 EOFError를 리턴한다.</p>

<h3>Node.js</h3>
<pre class="javascript"><code>const fs = require('fs');
const input = fs.readFileSync('/dev/stdin', 'utf8').trim().split('\n');
for (const line of input){
    const[a, b] = line.split(' ').map(Number);
    console.log(a+b);
}</code></pre>

<p>모든 입력을 줄 바꿈으로 끊어서 배열로 저장한다. 그리고 이 배열을 순회하면서 각각의 케이스를 처리한다.</p>
