---
title: "백준 코딩테스트 #16. 반복문 (7~10)"
excerpt: "백준 코딩테스트 #16. 반복문 (7~10)"
categories:
  - CodingTest
permalink: /coding/coding-test/134-sharp16-7-10/
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
source_url: https://b-note.tistory.com/134
---

<h2>7번 A+B - 7</h2>
<p><b>문제</b></p>
<p>두&nbsp;정수&nbsp;A와&nbsp;B를&nbsp;입력받은&nbsp;다음,&nbsp;A+B를&nbsp;출력하는&nbsp;프로그램을&nbsp;작성하시오.</p>

<p><b>입력</b></p>
<p>첫째&nbsp;줄에&nbsp;테스트&nbsp;케이스의&nbsp;개수&nbsp;T가&nbsp;주어진다.&nbsp;</p>
<p>각&nbsp;테스트&nbsp;케이스는&nbsp;한&nbsp;줄로&nbsp;이루어져&nbsp;있으며,&nbsp;각&nbsp;줄에&nbsp;A와&nbsp;B가&nbsp;주어진다.&nbsp;(0&nbsp;&lt;&nbsp;A,&nbsp;B&nbsp;&lt;&nbsp;10)</p>

<p><b>출력</b></p>
<p>각&nbsp;테스트&nbsp;케이스마다&nbsp;"Case&nbsp;#x:&nbsp;"를&nbsp;출력한&nbsp;다음,&nbsp;A+B를&nbsp;출력한다.&nbsp;테스트&nbsp;케이스&nbsp;번호는&nbsp;1부터&nbsp;시작한다.</p>

<h3>C++</h3>
<pre class="cpp"><code>#include &lt;iostream&gt;
using namespace std;
int main(){
    int t;
    cin.tie(NULL);
    ios_base::sync_with_stdio(false);
    cin &gt;&gt; t;
    for (int i = 0; i &lt; t; i++){
        int a, b;
        cin &gt;&gt; a &gt;&gt; b;
        cout &lt;&lt; "Case #" &lt;&lt; i + 1 &lt;&lt; ": " &lt;&lt; a + b &lt;&lt; "\n";
    }
    
    return 0;
}</code></pre>

<h3>C#</h3>
<pre class="csharp"><code>using System;
class Program{
    static void Main(string[] args){
        int t = int.Parse(Console.ReadLine());
        Console.SetOut(new StreamWriter(Console.OpenStandardOutput()));
        for (int i = 0; i &lt; t; i++){
            int a, b;
            string input = Console.ReadLine();
            string[] arr = input.Split(' ');
            a = int.Parse(arr[0]);
            b = int.Parse(arr[1]);
            Console.WriteLine($"Case #{i+1}: {a+b}");
        }
        Console.Out.Flush();
    }
}</code></pre>

<h3>Python</h3>
<pre class="python"><code>import sys
t = int(input());
for i in range(t):
    input_str = sys.stdin.readline().rstrip()
    arr = input_str.split(' ');
    a = int(arr[0])
    b = int(arr[1])
    print(f"Case #{i+1}: {a+b}")</code></pre>

<h3>Node.js</h3>
<pre class="javascript"><code>const fs = require('fs');
const input = fs.readFileSync('/dev/stdin','utf8').trim().split('\n');
const t = parseInt(input[0], 10);
const output = [];
for (let i = 1; i &lt;= t; i++){
    const[a,b] = input[i].split(' ').map(Number);
    output.push(`Case #${i}: ${a+b}`);
}
console.log(output.join('\n'));</code></pre>

<p>readFileSync에서 utf8로 명시적으로 인코딩해주지 않으면 반환되는 데이터가 기본적으로 Buffer 객체이므로 문자열 메서드와 함께 사용할 때 에러가 발생할 수 있다.</p>

<h2>8번 A+B - 8</h2>
<p><b>문제</b></p>
<p>두&nbsp;정수&nbsp;A와&nbsp;B를&nbsp;입력받은&nbsp;다음,&nbsp;A+B를&nbsp;출력하는&nbsp;프로그램을&nbsp;작성하시오.</p>

<p><b>입력</b></p>
<p>첫째&nbsp;줄에&nbsp;테스트&nbsp;케이스의&nbsp;개수&nbsp;T가&nbsp;주어진다.&nbsp;</p>
<p>각&nbsp;테스트&nbsp;케이스는&nbsp;한&nbsp;줄로&nbsp;이루어져&nbsp;있으며,&nbsp;각&nbsp;줄에&nbsp;A와&nbsp;B가&nbsp;주어진다.&nbsp;(0&nbsp;&lt;&nbsp;A,&nbsp;B&nbsp;&lt;&nbsp;10)</p>

<p><b>출력</b></p>
<p>각&nbsp;테스트&nbsp;케이스마다&nbsp;"Case&nbsp;#x:&nbsp;A&nbsp;+&nbsp;B&nbsp;=&nbsp;C"&nbsp;형식으로&nbsp;출력한다.&nbsp;x는&nbsp;테스트&nbsp;케이스&nbsp;번호이고&nbsp;1부터&nbsp;시작하며,&nbsp;C는&nbsp;A+B이다.</p>

<h3>C++</h3>
<pre class="cpp"><code>#include &lt;iostream&gt;
using namespace std;
int main(){
    int t;
    cin.tie(NULL);
    ios_base::sync_with_stdio(false);
    cin &gt;&gt; t;
    for (int i = 0; i &lt; t; i++){
        int a, b;
        cin &gt;&gt; a &gt;&gt; b;
        cout &lt;&lt; "Case #" &lt;&lt; i + 1 &lt;&lt; ": " &lt;&lt; a &lt;&lt; " + " &lt;&lt; b &lt;&lt; " = " &lt;&lt; a+b &lt;&lt; "\n";
    }
    return 0;
}</code></pre>

<h3>C#</h3>
<pre class="csharp"><code>using System;
class Program{
    static void Main(string[] args){
        int t = int.Parse(Console.ReadLine());
        Console.SetOut(new StreamWriter(Console.OpenStandardOutput()));
        for (int i = 0; i &lt; t; i++){
            string input = Console.ReadLine();
            string[] arr = input.Split(' ');
            int a = int.Parse(arr[0]);
            int b = int.Parse(arr[1]);
            Console.WriteLine($"Case #{i+1}: {a} + {b} = {a+b}");
        }
        Console.Out.Flush();
    }
}</code></pre>

<h3>Python</h3>
<pre class="python"><code>import sys
t = int(input())
for i in range(t):
    input_str = sys.stdin.readline().rstrip()
    arr = input_str.split()
    a = int(arr[0])
    b = int(arr[1])
    print(f"Case #{i+1}: {a} + {b} = {a+b}")</code></pre>

<h3>Node.js</h3>
<pre class="javascript"><code>const fs = require('fs');
const input = fs.readFileSync('/dev/stdin', 'utf8').trim().split('\n');
const t = parseInt(input[0], 10);
const output = [];
for (let i = 1; i &lt;= t; i++){
    const[a,b] = input[i].split(' ').map(Number);
    output.push(`Case #${i}: ${a} + ${b} = ${a+b}`);
}
console.log(output.join('\n'));</code></pre>

<p>7, 8번 문제들은 출력 형식만 다르고 앞에 풀었던 문제와 동일한 방식으로 해결되기 때문에 크게 설명할 내용은 없다.</p>

<h2>9번 별 찍기 - 1&nbsp;</h2>
<p><b>문제</b></p>
<p>첫째&nbsp;줄에는&nbsp;별&nbsp;1개,&nbsp;둘째&nbsp;줄에는&nbsp;별&nbsp;2개,&nbsp;N번째&nbsp;줄에는&nbsp;별&nbsp;N개를&nbsp;찍는&nbsp;문제</p>

<p><b>입력</b></p>
<p>첫째&nbsp;줄에&nbsp;N(1&nbsp;&le;&nbsp;N&nbsp;&le;&nbsp;100)이&nbsp;주어진다.</p>

<p><b>출력</b></p>
<p>첫째&nbsp;줄부터&nbsp;N번째&nbsp;줄까지&nbsp;차례대로&nbsp;별을&nbsp;출력한다.</p>

<h3>C++</h3>
<p>string(size_t count, char ch)를 사용해서 count 만큼 문자를 출력하도록 만들어 본다.</p>
<pre class="cpp"><code>#include &lt;iostream&gt;
#include &lt;string&gt;
using namespace std;
int main() {
    int n;
    cin.tie(NULL);
    ios_base::sync_with_stdio(false);
    cin &gt;&gt; n;
    for (int i = 1; i &lt;= n; i++) {
        string stars(i, '*');
        cout &lt;&lt; stars &lt;&lt; "\n";
    }
    return 0;
}</code></pre>

<h3>C#</h3>
<pre class="csharp"><code>using System;
class Program{
    static void Main(string[] args){
        int n = int.Parse(Console.ReadLine());
        using(StreamWriter writer = new StreamWriter(Console.OpenStandardOutput())){
            for (int i = 1; i &lt;= n; i++){
                string stars = new string('*', i);
                Console.WriteLine(stars);
            }
        }
    }
}</code></pre>

<p>C#은 new string(char, count)로 사용이 가능하다. 단일 문자를 반복하는 것이기 때문에 문자열이 아닌 문자를 사용해야 한다는 걸 유의한다.</p>

<p>기존 코드를 좀 더 깔끔하게 정리하기 위해서 using을 사용해서 내부에서 동작이 끝나면 자동으로 객체가 해제되도록 한다. 자세히 정리하자면 StreamWriter의 객체의 Dipose 메서드는 내부적으로 Flush를 호출하는데 using을 사용할 경우 객체가 해제될 때 Dispose 메서드가 자동으로 호출되면서 Flush도 처리된다. 따라서 별도로 Flush를 해줄 필요가 없어진다.</p>

<h3>Python</h3>
<pre class="python"><code>n = int(input())
for i in range(1, n + 1):
    stars = '*' * i;
    print(stars)</code></pre>

<p>파이썬은 문자에 횟수만큼 곱연산을 해서 개수만큼 표기가 가능하다.</p>

<h3>Node.js</h3>
<pre class="javascript"><code>const fs = require('fs');
const input = fs.readFileSync('/dev/stdin','utf8').trim();
const count = parseInt(input);
for (let i = 1; i &lt;= count; i++){
    const stars = '*'.repeat(i);
    console.log(stars);
}</code></pre>

<p>자바스크립트에서는 char.repeat으로 문자를 개수만큼 입력할 수 있다.</p>

<h2>10번 별 찍기 - 2</h2>
<p><b>문제</b></p>
<p>첫째 줄에는 별 1개, 둘째 줄에는 별 2개, N번째 줄에는 별 N개를 찍는 문제</p>
<p>하지만, 오른쪽을 기준으로 정렬한 별(예제 참고)을 출력하시오.</p>

<p><b>입력</b></p>
<p>첫째&nbsp;줄에&nbsp;N(1&nbsp;&le;&nbsp;N&nbsp;&le;&nbsp;100)이&nbsp;주어진다.</p>

<p><b>출력</b></p>
<p>첫째&nbsp;줄부터&nbsp;N번째&nbsp;줄까지&nbsp;차례대로&nbsp;별을&nbsp;출력한다.</p>

<p>9번 문제의 변형이다. N만큼 찍힌 별을 기준으로 이전 별들에게 공백이 추가로 필요하며 이 공백은 n - i 개가 된다.</p>

<h3>C++</h3>
<pre class="cpp"><code>#include &lt;iostream&gt;
#include &lt;string&gt;
using namespace std;
int main(){
    int n;
    cin &gt;&gt; n;
    for (int i = 1; i &lt;= n; i++){
        string space(n - i, ' ');
        string stars(i, '*');
        string result = space + stars;
        cout &lt;&lt; result &lt;&lt; "\n";
    }
    return 0;
}</code></pre>

<h3>C#</h3>
<pre class="csharp"><code>using System;
class Program{
    static void Main(string[] args){
        int n = int.Parse(Console.ReadLine());
        using(StreamWriter writer = new StreamWriter(Console.OpenStandardOutput())){
            for (int i = 1; i &lt;= n; i++){
                string space = new string(' ', n - i);
                string stars = new string('*', i);
                string result = space + stars;
                Console.WriteLine(result);
            }     
        }
    }
}</code></pre>

<h3>Python</h3>
<pre class="python"><code>n = int(input())
for i in range(1, n+1):
    space = ' ' * (n - i);
    stars = '*' * i;
    result = space + stars;
    print(result);</code></pre>

<h3>Node.js</h3>
<pre class="javascript"><code>const fs = require('fs');
const input = fs.readFileSync('/dev/stdin', 'utf8').trim();
const n = parseInt(input);
for (let i = 1; i &lt;= n; i++){
    const space = ' '.repeat(n - i);
    const stars = '*'.repeat(i);
    const result = space + stars;
    console.log(result);
}</code></pre>
