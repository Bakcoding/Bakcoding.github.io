---
title: "백준 코딩테스트 #10. 조건문 5"
excerpt: "백준 코딩테스트 #10. 조건문 5"
categories:
  - CodingTest
permalink: /coding/coding-test/128-sharp10-5/
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
date: 2024-07-26
last_modified_at: 2024-07-26
source_url: https://b-note.tistory.com/128
---

<h2>5번 알람 시계</h2>
<p><b>문제</b></p>
<p>상근이는&nbsp;매일&nbsp;아침&nbsp;알람을&nbsp;듣고&nbsp;일어난다.&nbsp;알람을&nbsp;듣고&nbsp;바로&nbsp;일어나면&nbsp;다행이겠지만,&nbsp;항상&nbsp;조금만&nbsp;더&nbsp;자려는&nbsp;마음&nbsp;때문에&nbsp;매일&nbsp;학교를&nbsp;지각하고&nbsp;있다.&nbsp;상근이는&nbsp;모든&nbsp;방법을&nbsp;동원해 보았지만,&nbsp;조금만&nbsp;더&nbsp;자려는&nbsp;마음은&nbsp;그&nbsp;어떤&nbsp;것도&nbsp;없앨&nbsp;수가&nbsp;없었다.&nbsp;이런&nbsp;상근이를&nbsp;불쌍하게&nbsp;보던&nbsp;창영이는&nbsp;자신이&nbsp;사용하는&nbsp;방법을&nbsp;추천해&nbsp;주었다.&nbsp;바로&nbsp;"45분&nbsp;일찍&nbsp;알람&nbsp;설정하기"이다.&nbsp;이&nbsp;방법은&nbsp;단순하다.&nbsp;원래&nbsp;설정되어&nbsp;있는&nbsp;알람을&nbsp;45분&nbsp;앞서는&nbsp;시간으로&nbsp;바꾸는&nbsp;것이다.&nbsp;어차피&nbsp;알람&nbsp;소리를&nbsp;들으면,&nbsp;알람을&nbsp;끄고&nbsp;조금&nbsp;더&nbsp;잘&nbsp;것이기&nbsp;때문이다.&nbsp;이&nbsp;방법을&nbsp;사용하면,&nbsp;매일&nbsp;아침&nbsp;더&nbsp;잤다는&nbsp;기분을&nbsp;느낄&nbsp;수&nbsp;있고,&nbsp;학교도&nbsp;지각하지&nbsp;않게&nbsp;된다.&nbsp;현재&nbsp;상근이가&nbsp;설정한&nbsp;알람&nbsp;시각이&nbsp;주어졌을&nbsp;때,&nbsp;창영이의&nbsp;방법을&nbsp;사용한다면,&nbsp;이를&nbsp;언제로&nbsp;고쳐야&nbsp;하는지&nbsp;구하는&nbsp;프로그램을&nbsp;작성하시오.</p>

<p><b>입력</b></p>
<p>첫째&nbsp;줄에&nbsp;두&nbsp;정수&nbsp;H와&nbsp;M이&nbsp;주어진다.&nbsp;(0&nbsp;&le;&nbsp;H&nbsp;&le;&nbsp;23,&nbsp;0&nbsp;&le;&nbsp;M&nbsp;&le;&nbsp;59)&nbsp;그리고&nbsp;이것은&nbsp;현재&nbsp;상근이가&nbsp;설정한&nbsp;알람&nbsp;시간&nbsp;H시&nbsp;M분을&nbsp;의미한다.&nbsp;입력&nbsp;시간은&nbsp;24시간&nbsp;표현을&nbsp;사용한다.&nbsp;24시간&nbsp;표현에서&nbsp;하루의&nbsp;시작은&nbsp;0:0(자정)이고,&nbsp;끝은&nbsp;23:59(다음날&nbsp;자정&nbsp;1분&nbsp;전)이다.&nbsp;시간을&nbsp;나타낼&nbsp;때,&nbsp;불필요한&nbsp;0은&nbsp;사용하지&nbsp;않는다.</p>

<p><b>출력</b></p>
<p>첫째&nbsp;줄에&nbsp;상근이가&nbsp;창영이의&nbsp;방법을&nbsp;사용할&nbsp;때,&nbsp;설정해야&nbsp;하는&nbsp;알람&nbsp;시간을&nbsp;출력한다.&nbsp;(입력과&nbsp;같은&nbsp;형태로&nbsp;출력하면&nbsp;된다.)</p>

<p>상근이의 아침은 나의 아침과 비슷해 보인다. 문제는 시간과 분이 입력될 때 45분 전의 시간을 출력하면 된다.</p>
<p>24시간 표현을 사용하고, 하루의 시작은 0:0 끝은 23:59인 점을 유의한다. 그리고 표기 시 불필요한 0은 생략</p>

<h2>C++</h2>
<pre class="cpp"><code>#include &lt;iostream&gt;
using namespace std;
int main(){
    int input_h, input_m;
    cin &gt;&gt; input_h;
    cin &gt;&gt; input_m;
    int m = input_m - 45;
    int h = input_h;
    if (m &lt; 0){
        h = input_h - 1;
        m = 60 + m;
        if (h &lt; 0)
        {
            h = 24 + h;
        }
    }
    cout &lt;&lt; h &lt;&lt; " " &lt;&lt; m;
    return 0;
}</code></pre>

<h2>C#</h2>
<pre class="cpp"><code>using System;
class Program{
    static void Main(string[] args){
        string input = Console.ReadLine();
        string[] arr = input.Split(' ');
        int input_h = int.Parse(arr[0]);
        int input_m = int.Parse(arr[1]);
        int m = input_m - 45;
        int h = input_h;
        if (m &lt; 0){
            h = input_h - 1;
            m = 60 + m;
            if (h &lt; 0) {
                h = 24 + h;
            }
        }
        Console.WriteLine($"{h} {m}");
    }
}</code></pre>

<h2>Python</h2>
<pre class="python"><code>inputData = input();
inputArr = inputData.split(' ');
inputH = int(inputArr[0]);
inputM = int(inputArr[1]);
h = inputH;
m = inputM - 45;
if m &lt; 0:
    h = inputH - 1;
    m = 60 + m;
    if h &lt; 0:
        h = 24 + h;
print(f"{h} {m}");</code></pre>

<p>파이썬에서 문자열에 변수를 사용하는 법</p>

<p><b>1. 문자열 변환</b></p>
<pre class="python"><code>print(str(h) + " " + str(m))</code></pre>

<p><b>2. f-string&nbsp;</b></p>
<p>파이썬 3.6 이상부터</p>
<pre class="python"><code>print(f"{h} {m}")</code></pre>

<p><b>3. format</b></p>
<p>print 함수는 여러 인수를 받을 경우 공백으로 구분해서 문자열을 출력한다.</p>
<pre class="python"><code>print(h, m)</code></pre>

<h2>Node.js</h2>
<pre class="javascript"><code>const fs = require('fs');
const input = fs.readFileSync('/dev/stdin').toString().trim().split(' ');
const inputH = parseInt(input[0]);
const inputM = parseInt(input[1]);
let h = inputH;
let m = inputM - 45;
if (m &lt; 0){
    m = 60 + m;
    h = h - 1;
    if (h &lt; 0){
        h = 24 + h;
    }
}
console.log(`${h} ${m}`);</code></pre>

<p>자바스크립트에서 리터럴 템플릿을 사용할 때는 백틱을 사용해야 하며 각각의 중괄호 앞에 $ 표기를 해야 한다.</p>
