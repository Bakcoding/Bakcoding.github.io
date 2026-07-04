---
title: "백준 코딩테스트 #9. 조건문 4"
excerpt: "백준 코딩테스트 #9. 조건문 4"
categories:
  - CodingTest
permalink: /coding/coding-test/127-sharp9-4/
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
source_url: https://b-note.tistory.com/127
---

<h2>3번 사분면 고르기</h2>
<p><b>문제</b></p>
<p>흔한&nbsp;수학&nbsp;문제&nbsp;중&nbsp;하나는&nbsp;주어진&nbsp;점이&nbsp;어느&nbsp;사분면에&nbsp;속하는지&nbsp;알아내는&nbsp;것이다.&nbsp;사분면은&nbsp;아래&nbsp;그림처럼&nbsp;1부터&nbsp;4까지&nbsp;번호를&nbsp;갖는다.&nbsp;"Quadrant&nbsp;n"은&nbsp;"제 n사분면"이라는&nbsp;뜻이다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="552" data-origin-height="400"><span data-alt="https://www.acmicpc.net/problem/14681"><img src="/assets/images/posts/2024/07/26/127-1.png" loading="lazy" width="309" height="224" data-origin-width="552" data-origin-height="400"/></span><figcaption>https://www.acmicpc.net/problem/14681</figcaption>
</figure>
</p>

<p>예를&nbsp;들어,&nbsp;좌표가&nbsp;(12,&nbsp;5)인&nbsp;점&nbsp;A는&nbsp;x좌표와&nbsp;y좌표가&nbsp;모두&nbsp;양수이므로&nbsp;제1사분면에&nbsp;속한다.&nbsp;점&nbsp;B는&nbsp;x좌표가&nbsp;음수이고&nbsp;y좌표가&nbsp;양수이므로&nbsp;제2사분면에&nbsp;속한다.&nbsp;점의&nbsp;좌표를&nbsp;입력받아&nbsp;그&nbsp;점이&nbsp;어느&nbsp;사분면에&nbsp;속하는지&nbsp;알아내는&nbsp;프로그램을&nbsp;작성하시오.&nbsp;단,&nbsp;x좌표와&nbsp;y좌표는&nbsp;모두&nbsp;양수나&nbsp;음수라고&nbsp;가정한다.</p>

<p><b>입력</b></p>
<p>첫&nbsp;줄에는&nbsp;정수&nbsp;x가&nbsp;주어진다.&nbsp;(&minus;1000&nbsp;&le;&nbsp;x&nbsp;&le;&nbsp;1000;&nbsp;x&nbsp;&ne;&nbsp;0)&nbsp;다음&nbsp;줄에는&nbsp;정수&nbsp;y가&nbsp;주어진다.&nbsp;(&minus;1000&nbsp;&le;&nbsp;y&nbsp;&le;&nbsp;1000;&nbsp;y&nbsp;&ne;&nbsp;0)</p>

<p><b>출력</b></p>
<p>점&nbsp;(x,&nbsp;y)의&nbsp;사분면&nbsp;번호(1,&nbsp;2,&nbsp;3,&nbsp;4&nbsp;중&nbsp;하나)를&nbsp;출력한다.</p>

<p>x 가 양수인지 음수인지, y가 양수인지 음수인지 구분해서 조건</p>

<h2>C++</h2>
<pre class="javascript"><code>#include &lt;iostream&gt;
using namespace std;
int main(){
    int x, y;
    cin &gt;&gt; x;
    cin &gt;&gt; y;
    char result;
    if (x &gt; 0)
    {
        if (y &gt; 0)
            result = '1';
        else 
            result = '4';
    }
    else{
        if (y &gt; 0)
            result = '2';
        else
            result = '3';
    }
    cout &lt;&lt; result;
    return 0;
}</code></pre>


<h2>C#</h2>
<pre class="javascript"><code>using System;
class Program{
    static void Main(string[] args){
        string inputX = Console.ReadLine();
        string inputY = Console.ReadLine();
        int x = int.Parse(inputX);
        int y = int.Parse(inputY);
        char result;
        if (x &gt; 0)
        {
            if (y &gt; 0)
                result = '1';
            else 
                result = '4';
        }
        else{
            if (y &gt; 0)
                result = '2';
            else
                result = '3';
        }
        Console.WriteLine(result);
    }
}</code></pre>

<p>앞의 문제들과 다르게 각 줄에 값들이 들어온다. 따라서 입력을 따로 두 번 받아서 값을 저장한다.</p>

<h2>Python</h2>
<pre class="javascript"><code>x = int(input());
y = int(input());
if x &gt; 0:
    if y &gt; 0:
        result = '1';
    else:
        result = '4';
else:
    if y &gt; 0:
        result = '2';
    else:
        result = '3';
print(result);</code></pre>

<p>파이썬에서 중첩 조건문을 쓸 때는 들여 쓰기로 구분한다.</p>

<h2>Node.js</h2>
<pre class="javascript"><code>const readline = require('readline');
const rl = readline.createInterface({
    input : process.stdin,
    output : process.stdout
});
let x, y;
let result;
rl.question('', (answerX)=&gt;{
    x = parseInt(answerX, 10);
    rl.question('', (answerY)=&gt;{
    y = parseInt(answerY, 10);
        if (x &gt; 0){
            if (y &gt; 0)
                result = '1';
            else
                result = '4';
        }
        else{
            if (y &gt; 0)
                result = '2';
            else
                result = '3';   
        }
        console.log(result);
        rl.close();
    });
});</code></pre>

<p>각 각의 입력을 받고 처리한다.</p>
<p>rl.close()가 호출되면 입력된 값을 사용할 수 없기 때문에 호출 전에 결과를 출력해야 한다.</p>
