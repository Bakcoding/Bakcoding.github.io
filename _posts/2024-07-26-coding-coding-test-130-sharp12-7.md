---
title: "백준 코딩테스트 #12. 조건문 7"
excerpt: "백준 코딩테스트 #12. 조건문 7"
categories:
  - CodingTest
permalink: /coding/coding-test/130-sharp12-7/
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
source_url: https://b-note.tistory.com/130
---

<h2>7번 주사위 세 개</h2>
<p><b>문제</b></p>
<p>1에서부터&nbsp;6까지의&nbsp;눈을&nbsp;가진&nbsp;3개의&nbsp;주사위를&nbsp;던져서&nbsp;다음과&nbsp;같은&nbsp;규칙에&nbsp;따라&nbsp;상금을&nbsp;받는&nbsp;게임이&nbsp;있다.&nbsp;같은&nbsp;눈이&nbsp;3개가&nbsp;나오면&nbsp;10,000원+(같은&nbsp;눈) &times;1,000원의&nbsp;상금을&nbsp;받게&nbsp;된다.&nbsp;같은&nbsp;눈이&nbsp;2개만&nbsp;나오는&nbsp;경우에는&nbsp;1,000원+(같은&nbsp;눈) &times;100원의&nbsp;상금을&nbsp;받게&nbsp;된다.&nbsp;모두&nbsp;다른&nbsp;눈이&nbsp;나오는&nbsp;경우에는&nbsp;(그중&nbsp;가장&nbsp;큰&nbsp;눈) &times;100원의&nbsp;상금을&nbsp;받게&nbsp;된다.&nbsp;예를&nbsp;들어,&nbsp;3개의&nbsp;눈&nbsp;3,&nbsp;3,&nbsp;6이&nbsp;주어지면&nbsp;상금은&nbsp;1,000+3 &times;100으로&nbsp;계산되어&nbsp;1,300원을&nbsp;받게&nbsp;된다.&nbsp;또&nbsp;3개의&nbsp;눈이&nbsp;2,&nbsp;2,&nbsp;2로&nbsp;주어지면&nbsp;10,000+2 &times;1,000으로&nbsp;계산되어&nbsp;12,000원을&nbsp;받게&nbsp;된다.&nbsp;3개의&nbsp;눈이&nbsp;6,&nbsp;2,&nbsp;5로&nbsp;주어지면&nbsp;그중&nbsp;가장&nbsp;큰&nbsp;값이&nbsp;6이므로&nbsp;6 &times;100으로&nbsp;계산되어&nbsp;600원을&nbsp;상금으로&nbsp;받게&nbsp;된다.&nbsp;3개&nbsp;주사위의&nbsp;나온&nbsp;눈이&nbsp;주어질&nbsp;때,&nbsp;상금을&nbsp;계산하는&nbsp;프로그램을&nbsp;작성하시오.</p>

<p><b>입력</b></p>
<p>첫째&nbsp;줄에&nbsp;3개의&nbsp;눈이&nbsp;빈칸을&nbsp;사이에&nbsp;두고&nbsp;각각&nbsp;주어진다.</p>

<p><b>출력</b></p>
<p>첫째&nbsp;줄에&nbsp;게임의&nbsp;상금을&nbsp;출력한다.</p>

<p>입력받은 주사위 눈을 조건에 맞게 검사해서 상금을 출력하면 된다.</p>

<h2>C++</h2>
<pre class="cpp"><code>#include &lt;iostream&gt;
#include &lt;algorithm&gt;
using namespace std;
int main(){
    int a, b, c;
    cin &gt;&gt; a;
    cin &gt;&gt; b;
    cin &gt;&gt; c;
    int reward;
    if (a == b &amp;&amp; b == c){
        reward = 10000 + a * 1000;
    }
    else if (a == b || b == c || a == c){
        int val = a == b ? a : b == c ? b : c;
        reward =  1000 + val * 100;
    }
    else{
        int max_val = max({a, b, c});
        reward = max_val * 100;
    }
    cout &lt;&lt; reward;
    return 0;
}</code></pre>

<p>세 개의 값 중 가장 큰 값을 구할 때 &lt;algorithm&gt; 헤더의 std::max를 사용하여 간략하게 작성한다.</p>

<h2>C#</h2>
<pre class="csharp"><code>using System;
class Program{
    static void Main(string[] args){
        string input = Console.ReadLine();
        string[] arr_input = input.Split(' ');
        int a = int.Parse(arr_input[0]);
        int b = int.Parse(arr_input[1]);
        int c = int.Parse(arr_input[2]);
        int reward;
        if (a == b &amp;&amp; b == c){
            reward = 10000 + a * 1000;
        }
        else if (a == b || b == c || a == c){
            int val = a == b ? a : b == c ? b : c;
            reward = 1000 + val * 100;
        }
        else {
            int val = Math.Max(a, (Math.Max(b, c)));
            reward = 100 * val;
        }
        Console.WriteLine(reward);
    }
}</code></pre>

<p>C#은&nbsp;최댓값을 구하기 위해서 Math.Max를 중첩해서 사용했다.</p>

<p>다른 방법으로는 System.Linq의 Enumerable.Max를 사용할 수&nbsp; 있다.</p>
<pre class="csharp"><code>using System.Linq;
~

	int [] nums = {a, b, c};
	int max_val = nums.Max();

~</code></pre>

<p>두 방식을 비교해 보니 메모리면에서 전자의 방법이 더 나았다.</p>

<h2>Python</h2>
<pre class="python"><code>inputData = input();
arrData = inputData.split(' ');
a = int(arrData[0]);
b = int(arrData[1]);
c = int(arrData[2]);
if a == b and b == c:
    reward = 10000 + a * 1000
elif a == b or b == c or a == c:
    val = a if a == b or a == c else b
    reward = 1000 + val * 100;
else:
    val = max(a, b, c)
    reward = 100 * val
print(reward)</code></pre>

<p>파이썬에서 삼항 연산자는 if - else로 표현된다.</p>
<p>max 함수는 가장 큰 수를 반환한다.</p>

<h2>Node.js</h2>
<pre class="javascript"><code>const readline = require('readline');
const rl = readline.createInterface({
    input : process.stdin,
    output : process.stdout
});

rl.question('', (answer)=&gt;{
    const [a,b,c] = answer.split(' ').map(Number);
    let reward;
    if (a == b &amp;&amp; b == c){
        reward = 10000 + a * 1000;
    }
    else if (a == b || b == c || a == c){
        let val = a == b ? a : b == c ? b : c;
        reward = 1000 + val * 100;
    }
    else{
        val = Math.max(a, b, c);
        reward = 100 * val;
    }
    console.log(reward);
    rl.close();
});</code></pre>

<p>node.js는 Math.max로 세 값 중 가장 큰 값을 구할 수 있다.</p>
