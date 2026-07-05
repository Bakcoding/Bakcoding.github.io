---
title: "백준 코딩테스트 #22. 문자열 (1 ~ 4)"
excerpt: "백준 코딩테스트 #22. 문자열 (1 ~ 4)"
categories:
  - CodingTest
permalink: /coding/coding-test/140-sharp22-1-4/
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
date: 2024-08-05
last_modified_at: 2024-08-05
source_url: https://b-note.tistory.com/140
---

<h2>1번 문자와 문자열</h2>
<p><b>문제</b></p>
<p>단어 S와 정수 i가 주어졌을 때, S의 i번째 글자를 출력하는 프로그램을 작성하시오.</p>

<p><b>입력</b></p>
<p>첫째 줄에 영어 소문자와 대문자로만 이루어진 단어 S가 주어진다. 단어의 길이는 최대 1,000이다. 둘째 줄에 정수 i가 주어진다. ( 1 <span style="text-align: start">&le;</span> i <span style="text-align: start">&le;</span> |S|)</p>

<p><b>출력</b></p>
<p>S의 i번째 글자를 출력한다.</p>

<p>주어진 문자열에서 i번째 문자가 무엇인지 출력한다.</p>

<h3>C++</h3>
<pre class="cpp"><code>#include &lt;iostream&gt;
#include &lt;string&gt;
using namespace std;
int main(){
    string s;
    int i;
    cin &gt;&gt; s;
    cin &gt;&gt; i;
    cout &lt;&lt; s[i - 1];
    return 0;
}</code></pre>

<p>string도 문자 배열처럼 접근해서 사용할 수 있다.</p>

<h3>C#</h3>
<pre class="csharp"><code>using System;
class Program{
    static void Main(string[] args){
        string s = Console.ReadLine();
        int i = int.Parse(Console.ReadLine());
        Console.Write($"{s[i - 1]}");
    }
}</code></pre>

<p>C#의 string도 마찬가지로 배열식으로 접근이 가능하다.</p>

<h3>Python</h3>
<pre class="python"><code>s = input()
i = int(input())
print(s[i - 1])</code></pre>

<h3>Node.js</h3>
<pre class="javascript"><code>const fs = require('fs');
const input = fs.readFileSync('/dev/stdin','utf8').split('\n');
const s = input[0];
const i = parseInt(input[1]);
console.log(s[i - 1]);</code></pre>

<h2>2번 단어 길이 재기</h2>
<p><b>문제</b></p>
<p>알파벳으로만&nbsp;이루어진&nbsp;단어를&nbsp;입력받아,&nbsp;그&nbsp;길이를&nbsp;출력하는&nbsp;프로그램을&nbsp;작성하시오.</p>

<p><b>입력</b></p>
<p>첫째&nbsp;줄에&nbsp;영어&nbsp;소문자와&nbsp;대문자로만&nbsp;이루어진&nbsp;단어가&nbsp;주어진다.&nbsp;단어의&nbsp;길이는&nbsp;최대&nbsp;100이다.</p>

<p><b>출력</b></p>
<p>첫째&nbsp;줄에&nbsp;입력으로&nbsp;주어진&nbsp;단어의&nbsp;길이를&nbsp;출력한다.</p>

<h3>C++</h3>
<pre class="cpp"><code>#include &lt;iostream&gt;
#include &lt;string&gt;
using namespace std;
int main(){
    string s;
    cin &gt;&gt; s;
    cout &lt;&lt; s.length();
    return 0;
}</code></pre>

<p>length 함수를 사용해서 문자열의 길이를 구할 수 있다.</p>

<h3>C#</h3>
<pre class="csharp"><code>using System;
class Program{
    static void Main(string[] args){
        string s = Console.ReadLine();
        Console.Write(s.Length);
    }
}</code></pre>

<p>C#은 Length 프로퍼티로 문자열의 길이에 접근할 수 있다.</p>

<h3>Python</h3>
<pre class="python"><code>s = input()
print(len(s))</code></pre>

<p>len(string)으로 문자열의 길이를 반환할 수 있다.</p>

<h3>Node.js</h3>
<pre class="javascript"><code>const fs = require('fs');
const s = fs.readFileSync('/dev/stdin','utf8').trim();
console.log(s.length);</code></pre>

<p>trim()은 입력된 문자열 양 끝의 공백을 제거하는데 이걸 사용하지 않았을 때 틀렸다는 채점 결과가 나왔다.</p>
<p>정확한 입력을 받기 위해서 trim을 사용해 주는 게 좋을 것 같다.</p>

<p>js에서는 string.length 프로퍼티로 길이를 구할 수 있다.</p>

<h2>3번 문자열</h2>
<p><b>문제</b></p>
<p>문자열을&nbsp;입력으로&nbsp;주면&nbsp;문자열의&nbsp;첫&nbsp;글자와&nbsp;마지막&nbsp;글자를&nbsp;출력하는&nbsp;프로그램을&nbsp;작성하시오.</p>

<p><b>입력</b></p>
<p>입력의&nbsp;첫&nbsp;줄에는&nbsp;테스트&nbsp;케이스의&nbsp;개수&nbsp;T(1&nbsp;&le;&nbsp;T&nbsp;&le;&nbsp;10)가&nbsp;주어진다.&nbsp;각&nbsp;테스트&nbsp;케이스는&nbsp;한&nbsp;줄에&nbsp;하나의&nbsp;문자열이&nbsp;주어진다.&nbsp;문자열은&nbsp;알파벳&nbsp;A~Z&nbsp;대문자로&nbsp;이루어지며&nbsp;알파벳&nbsp;사이에&nbsp;공백은&nbsp;없으며&nbsp;문자열의&nbsp;길이는&nbsp;1000보다&nbsp;작다.</p>

<p><b>출력</b></p>
<p>각&nbsp;테스트&nbsp;케이스에&nbsp;대해서&nbsp;주어진&nbsp;문자열의&nbsp;첫&nbsp;글자와&nbsp;마지막&nbsp;글자를&nbsp;연속하여&nbsp;출력한다.</p>

<p>케이스의 문자열의 처음과 끝 문자를 출력해 준다. 문자가 하나인 경우는 한 문자가 두 번 출력된다.</p>

<h3>C++</h3>
<pre class="cpp"><code>#include &lt;iostream&gt;
#include &lt;string&gt;
using namespace std;
int main(){
    int t;
    cin &gt;&gt; t;
    string s;
    for (int i = 0; i &lt; t; i++){
        cin &gt;&gt; s;
        int len = s.length();
        cout &lt;&lt; s[0] &lt;&lt; s[len - 1] &lt;&lt; "\n";
    }
    return 0;
}</code></pre>

<p>문자열의 길이를 사용해서 마지막 인덱스를 구할 수 있다.</p>

<h3>C#</h3>
<pre class="csharp"><code>using System;
class Program{
    static void Main(string[] args){
        int t = int.Parse(Console.ReadLine());
        for (int i = 0; i &lt; t; i++){
            string s = Console.ReadLine();
            int len = s.Length;
            Console.WriteLine($"{s[0]}{s[len-1]}");
        }
    }
}</code></pre>

<h3>Python</h3>
<pre class="python"><code>t = int(input())
for i in range(t):
    s = input()
    l = len(s)
    print(f"{s[0]}{s[l - 1]}")</code></pre>

<h3>Node.js</h3>
<pre class="javascript"><code>const fs = require('fs');
const input = fs.readFileSync('/dev/stdin','utf8').trim().split('\n');
const t = parseInt(input[0]);
for (let i = 1; i &lt;= t; i++){
    const s = input[i];
    const l = s.length;
    console.log(`${s[0]}${s[l - 1]}`);
}</code></pre>

<h2>4번 아스키코드</h2>
<p style="text-align: start"><b>문제</b></p>
<p style="text-align: start">알파벳&nbsp;소문자,&nbsp;대문자,&nbsp;숫자&nbsp;0-9중&nbsp;하나가&nbsp;주어졌을&nbsp;때,&nbsp;주어진&nbsp;글자의&nbsp;아스키코드값을&nbsp;출력하는&nbsp;프로그램을&nbsp;작성하시오.</p>
<p style="text-align: start">&nbsp;</p>
<p style="text-align: start"><b>입력</b></p>
<p style="text-align: start">알파벳&nbsp;소문자,&nbsp;대문자,&nbsp;숫자&nbsp;0-9&nbsp;중&nbsp;하나가&nbsp;첫째&nbsp;줄에&nbsp;주어진다.</p>
<p style="text-align: start">&nbsp;</p>
<p style="text-align: start"><b>출력</b></p>
<p style="text-align: start">입력으로&nbsp;주어진&nbsp;글자의&nbsp;아스키코드&nbsp;값을&nbsp;출력한다.</p>
<p style="text-align: start">&nbsp;</p>
<p style="text-align: start">입력된 문자를 아스키코드로 출력한다.</p>
<p style="text-align: start">&nbsp;</p>
<h3 style="text-align: start">C++</h3>
<pre class="cpp"><code>#include &lt;iostream&gt;
using namespace std;
int main(){
    char c;
    cin &gt;&gt; c;
    int ascii_val = static_cast&lt;int&gt;(c);
    cout &lt;&lt; ascii_val;
    return 0;
}</code></pre>
<p style="text-align: start">&nbsp;</p>
<p style="text-align: start">문자를 int로 타입을 변경하면 아스키코드로 치환된다.</p>
<p style="text-align: start">&nbsp;</p>
<p style="text-align: start">또는&nbsp;</p>
<p style="text-align: start">&nbsp;</p>
<pre class="cpp"><code>#include &lt;iostream&gt;
using namespace std;
int main(){
    char c;
    cin &gt;&gt; c;
    int ascii_val = c - 0;
    cout &lt;&lt; ascii_val;
    return 0;
}</code></pre>

<p>C++에서는 문자에 정수 0을 빼주면 해당 문자의 아스키코드를 얻을 수 있다.</p>

<h3>C#</h3>
<pre class="csharp"><code>using System;
class Program{
    static void Main(string[] args){
        char c = (char)Console.Read();
        int ascii_val = (int)c;
        Console.Write(ascii_val);
    }
}</code></pre>

<p>Console.ReadLine/Read()는 문자열로만 반환되기 때문에 문자로 할당할 때 char 캐스트를 해야 한다.</p>
<p>(int)로 문자를 정수형으로 변환하면 아스키코드를 구할 수 있다.</p>

<h3>Python</h3>
<pre class="python"><code>c = input();
print(ord(c));</code></pre>

<p>파이썬은 문자를 아스키코드로 변환하는 함수 ord()가 제공된다.</p>

<h3>Node.js</h3>
<pre class="javascript"><code>const readline = require('readline').createInterface({
    input: process.stdin,
    output: process.stdout
});

readline.question('', c =&gt; {
    const ascii_val = c.charCodeAt(0);
    console.log(`${ascii_val}`);
    readline.close();
});</code></pre>

<p>js에서는 char.charCodeAt(0)으로 문자를 아스키코드로 변환할 수 있다.</p>
