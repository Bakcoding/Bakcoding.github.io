---
title: "백준 코딩테스트 #19. 1차원 배열 3"
excerpt: "백준 코딩테스트 #19. 1차원 배열 3"
categories:
  - CodingTest
permalink: /coding/coding-test/137-sharp19-1-3/
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
date: 2024-08-03
last_modified_at: 2024-08-03
source_url: https://b-note.tistory.com/137
---

<h2>3번 최소, 최대</h2>
<p><b>문제</b></p>
<p>N개의&nbsp;정수가&nbsp;주어진다.&nbsp;이때,&nbsp;최솟값과&nbsp;최댓값을&nbsp;구하는&nbsp;프로그램을&nbsp;작성하시오.</p>

<p><b>입력</b></p>
<p>첫째&nbsp;줄에&nbsp;정수의&nbsp;개수&nbsp;N&nbsp;(1&nbsp;&le;&nbsp;N&nbsp;&le;&nbsp;1,000,000)이&nbsp;주어진다.&nbsp;둘째&nbsp;줄에는&nbsp;N개의&nbsp;정수를&nbsp;공백으로&nbsp;구분해서&nbsp;주어진다.&nbsp;모든&nbsp;정수는&nbsp;-1,000,000보다&nbsp;크거나&nbsp;같고,&nbsp;1,000,000보다&nbsp;작거나&nbsp;같은&nbsp;정수이다.</p>

<p><b>출력</b></p>
<p>첫째&nbsp;줄에&nbsp;주어진&nbsp;정수&nbsp;N개의&nbsp;최솟값과&nbsp;최댓값을&nbsp;공백으로&nbsp;구분해&nbsp;출력한다.</p>

<h3>C++</h3>
<p>vector를 사용해서 풀어본다.</p>
<pre class="cpp"><code>#include &lt;iostream&gt;
#include &lt;vector&gt;
#include &lt;algorithm&gt;
using namespace std;
int main(){
    int n;
    cin &gt;&gt; n;
    vector&lt;int&gt; vec(n);
    for (int i = 0; i &lt; n; i++){
        cin &gt;&gt; vec[i];
    }
    vector&lt;int&gt;::iterator min_iter = min_element(vec.begin(), vec.end());
    vector&lt;int&gt;::iterator max_iter = max_element(vec.begin(), vec.end());
    cout &lt;&lt; *min_iter &lt;&lt; " " &lt;&lt; *max_iter;
    return 0;
}</code></pre>

<p>vector는 가변 배열이지만 사이즈를 특정해서 고정 크기로 사용할 수 있다.</p>
<p>algorithm을 사용해서 배열 안에서 min, max 요소를 찾아서 반복자를 반환받아서 값을 출력한다.</p>
<p>min, max_element 함수가 반복자를 반환하는 이유는 중복된 값을 저장할 필요 없이 컨테이너의 요소를 직접 참조할 수 있으며 컨테이너의 종류에 상관없이 유연하게 사용할 수 있기 때문이다. 또한 반복자에 접근해서 컨테이너의 요소를 직접 조작할 수도 있다.</p>

<pre class="cpp"><code>#include &lt;iostream&gt;
#include &lt;vector&gt;
#include &lt;algorithm&gt;
using namespace std;
int main(){
    int n;
    cin &gt;&gt; n;
    vector&lt;int&gt; vec;
    for (int i = 0; i &lt; n; i++){
        int val;
        cin &gt;&gt; val;
        vec.push_back(val);
    }
    vector&lt;int&gt;::iterator min_iter = min_element(vec.begin(), vec.end());
    vector&lt;int&gt;::iterator max_iter = max_element(vec.begin(), vec.end());
    cout &lt;&lt; *min_iter &lt;&lt; " " &lt;&lt; *max_iter;
    return 0;
}</code></pre>

<p>가변적으로 사용할 때는 push_back을 사용하면 된다.</p>

<h3>C#</h3>
<pre class="csharp"><code>using System;
using System.Collections.Generic;
using System.Linq;
class Program{
    static void Main(string[] args){
        int n = int.Parse(Console.ReadLine());
        string[] input_arr = Console.ReadLine().Split(' ');
        List&lt;int&gt; num_list = new List&lt;int&gt;();
        for (int i = 0; i &lt; n; i++){
            num_list.Add(int.Parse(input_arr[i]));
        }
        int min = num_list.Min();
        int max = num_list.Max();
        Console.WriteLine($"{min} {max}");
    }
}</code></pre>

<p>C#에서는 List &lt;T&gt;를 사용할 수 있다. List는 Collections.Generic에 포함되어 있고 Min, Max를 사용하기 위해서 Linq도 사용한다.</p>

<p>리스트에 값을 넣는 과정도 Select와 ToList를 사용하면 한 번에 초기화할 수 있다.</p>
<pre class="csharp"><code>string[] input_arr = Console.ReadLine().Split(' ');
List&lt;int&gt; num_list = new List&lt;int&gt;();
for (int i = 0; i &lt; n; i++){
    num_list.Add(int.Parse(input_arr[i]));
}

//================================================
List&lt;int&gt; numbers = Console.ReadLine().Split(' ').Select(int.Parse).ToList();</code></pre>

<p><span style="text-align: start">Linq는 이외에도 배열이나 컬렉션 등을 처리할 때 유용한 기능들을 제공하기 때문에 함께 사용하는 경우가 많다. 하지만 강력한 기능인만큼 많은 메모리를 사용하기 때문에 주의해야 한다.</span><span style="text-align: start"></span></p>

<h3><span style="text-align: start">Python</span></h3>
<pre class="python"><code>n = int(input())
num_list = list(map(int, input().split()))
min_val = min(num_list)
max_val = max(num_list)
print(f"{min_val} {max_val}")</code></pre>

<p><span style="text-align: start">파이썬은 list()를 사용할 수 있다.</span></p>
<p><span style="letter-spacing: 0px">map은 해당 함수가 반복 가능한 객체의 각 요소에 대해 적용된 결과를 반환하는 map객체를 생성하는데 이 객체는 필요에 따라 리스트나 튜플로 변환하여 사용할 수 있다.</span></p>
<p style="text-align: start">map을 사용해서 입력되는 값을 공백으로 구분하고 각 문자열을 정수로 변환하여 반환되는 map으로 list를 초기화한다.</p>

<h3>Node.js</h3>
<pre class="javascript"><code>const fs = require('fs');
const input = fs.readFileSync('/dev/stdin','utf8').split('\n');
const n = parseInt(input[0]);
const nums = input[1].split(' ').map(Number);
let min_val = nums[0];
let max_val = nums[0];
for (int i = 1; i &lt; n; i++){
    if (nums[i] &lt; min_val)
        min_val = nums[i]
    else if (nums[i] &gt; max_val)
        max_val = nums[i]
}
console.log(`${min_val} ${max_val}`);</code></pre>

<p>js도 map을 사용해서 배열을 초기화시킬 수 있다. 입력받은 값을 Number함수로 각 요소를 숫자로 변환한 map을 반환한다.</p>

<p>최대 최소를 구하는 방법은 함수를 쓰지 않고 각 요소들의 크기를 작으면 min, 크면 max로 비교하여 구할 수 있다.</p>

<p>js에서도 최대 최솟값을 구하는 Math.min, Math.max를 지원한다.</p>

<pre class="javascript"><code>const fs = require('fs');
const input = fs.readFileSync('/dev/stdin','utf8').split('\n');
const n = parseInt(input[0]);
const nums = input[1].split(' ').map(Number);
const min_val = Math.min(...nums);
const max_val = Math.max(...nums);
console.log(`${min_val} ${max_val}`);</code></pre>
