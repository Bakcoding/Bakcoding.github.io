---
title: "백준 코딩테스트 #18. 1차원 배열 (1, 2)"
excerpt: "백준 코딩테스트 #18. 1차원 배열 (1, 2)"
categories:
  - CodingTest
permalink: /coding/coding-test/136-sharp18-1-1-2/
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
source_url: https://b-note.tistory.com/136
---

<h2>1번 개수 세기</h2>
<p><b>문제&nbsp;</b></p>
<p>총&nbsp;N개의&nbsp;정수가&nbsp;주어졌을&nbsp;때,&nbsp;정수&nbsp;v가&nbsp;몇&nbsp;개인지&nbsp;구하는&nbsp;프로그램을&nbsp;작성하시오.</p>

<p><b>입력</b></p>
<p>첫째&nbsp;줄에&nbsp;정수의&nbsp;개수&nbsp;N(1&nbsp;&le;&nbsp;N&nbsp;&le;&nbsp;100)이&nbsp;주어진다.&nbsp;둘째&nbsp;줄에는&nbsp;정수가&nbsp;공백으로&nbsp;구분되어 있다.&nbsp;셋째&nbsp;줄에는&nbsp;찾으려고&nbsp;하는&nbsp;정수&nbsp;v가&nbsp;주어진다.&nbsp;입력으로&nbsp;주어지는&nbsp;정수와&nbsp;v는&nbsp;-100보다&nbsp;크거나&nbsp;같으며,&nbsp;100보다&nbsp;작거나&nbsp;같다.</p>

<p><b>출력</b></p>
<p>첫째&nbsp;줄에&nbsp;입력으로&nbsp;주어진&nbsp;N개의&nbsp;정수&nbsp;중에&nbsp;v가&nbsp;몇&nbsp;개인지&nbsp;출력한다.</p>

<p>배열에 저장하고 조건에 맞는 값을 출력한다.</p>

<h3>C++</h3>
<pre class="cpp"><code>#include &lt;iostream&gt;
using namespace std;
int main(){
    int n, v, count;
    cin &gt;&gt; n;
    int arr[n];
    for (int i = 0; i &lt; n; i++){
        cin &gt;&gt; arr[i];
    }
    
    cin &gt;&gt; v;
    for (int i = 0; i &lt; n; i++){
        if (arr[i] == v)
            count++;
    }
    cout &lt;&lt; count;
    return 0;
}</code></pre>

<p>입력될 크기인 n 만큼의 크기의 배열을 선언하고 반복문으로 배열에 값들을 저장한다.</p>

<p>그리고 v의 입력을 받아 반복문으로 배열을 순회하면서 같은 값인 경우 count를 증가시키고 최종 개수를 출력한다.</p>

<h3>C#</h3>
<pre class="csharp"><code>using System;
class Program{
    static void Main(string[] args){
        int n = int.Parse(Console.ReadLine());
        int[] arr = new int[n];
        string input = Console.ReadLine().Trim();
        string[] input_arr = input.Split(' ');
        for (int i = 0; i &lt; n; i++){
            arr[i] = int.Parse(input_arr[i]);
        }
        int v = int.Parse(Console.ReadLine());
        int count = 0;
        for (int i = 0; i &lt; n; i++){
            if (arr[i] == v)
                count++;
        }
        Console.WriteLine(count);
    }
}</code></pre>

<h3>Python</h3>
<pre class="python"><code>n = int(input())
values = input().strip().split(' ')
arr = [0] * n
for i in range(n):
    arr[i] = int(values[i]);
v = int(input())
count = 0;
for i in range(n):
    if arr[i] == v:
        count += 1
print(count)</code></pre>

<h3>Node.js</h3>
<pre class="javascript"><code>const fs = require('fs');
const input = fs.readFileSync('/dev/stdin','utf8').split('\n');
const n = parseInt(input[0]);
const values = input[1].split(' ');
const v = parseInt(input[2]);
let count = 0;
const val_arr = new Array(n);
for (let i = 0; i &lt; n; i++){
    val_arr[i] = parseInt(values[i]);
}
for (let i = 0; i &lt; n; i++){
    if (val_arr[i] === v)
        count++;
}
console.log(count);</code></pre>

<p>더 효율적인 방법도 있지만 1차원 배열을 사용해서 푸는걸 중점으로 두었기 때문에 불필요한 변수와 반복문이 사용되기도 한다.</p>

<h2>2번 X보다 작은 수</h2>
<p><b>문제</b></p>
<p>정수&nbsp;N개로&nbsp;이루어진&nbsp;수열&nbsp;A와&nbsp;정수&nbsp;X가&nbsp;주어진다.&nbsp;이때,&nbsp;A에서&nbsp;X보다&nbsp;작은&nbsp;수를&nbsp;모두&nbsp;출력하는&nbsp;프로그램을&nbsp;작성하시오.</p>

<p><b>입력</b></p>
<p>첫째&nbsp;줄에&nbsp;N과&nbsp;X가&nbsp;주어진다.&nbsp;</p>
<p>(1&nbsp;&le;&nbsp;N,&nbsp;X&nbsp;&le;&nbsp;10,000)&nbsp;둘째&nbsp;줄에&nbsp;수열&nbsp;A를&nbsp;이루는&nbsp;정수&nbsp;N개가&nbsp;주어진다.&nbsp;주어지는&nbsp;정수는&nbsp;모두&nbsp;1보다&nbsp;크거나&nbsp;같고,&nbsp;10,000보다&nbsp;작거나&nbsp;같은&nbsp;정수이다.</p>

<p><b>출력</b></p>
<p>X보다&nbsp;작은&nbsp;수를&nbsp;입력받은&nbsp;순서대로&nbsp;공백으로&nbsp;구분해&nbsp;출력한다.&nbsp;X보다&nbsp;작은&nbsp;수는&nbsp;적어도&nbsp;하나&nbsp;존재한다.</p>

<p>1번을 풀었던 것처럼 배열을 사용하는데 중점을 둔다.</p>

<h3>C++</h3>
<pre class="cpp"><code>#include &lt;iostream&gt;
using namespace std;
int main(){
    cin.tie(NULL);
    ios_base::sync_with_stdio(false);
    int n, x;
    cin &gt;&gt; n;
    cin &gt;&gt; x;
    int arr[n];
    for (int i = 0; i &lt; n; i++){
        cin &gt;&gt; arr[i];
    }
    for (int a : arr){
        if (a &lt; x){
            cout &lt;&lt; a &lt;&lt; " ";
        }
    }
    return 0;
}</code></pre>

<p>배열의 모든 요소를 순회할 때는 for (int a : arr)를 사용할 수 있다.</p>

<h3>C#</h3>
<pre class="csharp"><code>using System;
class Program{
    static void Main(string[] args){
        string input = Console.ReadLine();
        string[] input_arr = input.Split(' ');
        int n = int.Parse(input_arr[0]);
        int x = int.Parse(input_arr[1]);
        input = Console.ReadLine();
        input_arr = input.Split(' ');
        int[] arr = new int[n];
        for (int i = 0; i &lt; n; i++){
            arr[i] = int.Parse(input_arr[i]);
        }
        
        foreach(int a in arr){
            if (a &lt; x){
                Console.Write($"{a} ");
            }
        }
    }
}</code></pre>

<h3>Python</h3>
<pre class="python"><code>n, x = map(int, input().split())
str_arr = input().split();
arr = [0] * n;
for i in range(n):
    arr[i] = int(str_arr[i])
for i in range(n):
    if arr[i] &lt; x :
        print(f"{arr[i]} ", end="")</code></pre>

<p>출력 시 print는 기본적으로 줄 바꿈을 실행하므로 end=""로 설정해서 줄 바꿈을 제거한다.</p>


<h3>Node.js</h3>
<pre class="javascript"><code>const fs = require('fs');
const input = fs.readFileSync('/dev/stdin','utf8').split('\n');
const [n, x] = input[0].split(' ').map(Number);
const values = input[1].split(' ').map(Number);
let result = [];
values.forEach(value =&gt; {
    if (value &lt; x) {
        result.push(value);
    }
});

console.log(result.join(' '));</code></pre>

<p>각각의 입력 값들을 정리하고 결과를 따로 배열에 저장한 뒤 일괄적으로 출력한다.</p>

<p>1, 2번 문제들은 고정 크기의 배열을 사용해서 풀었지만 가변 배열인 vector 나 list 등을 사용하면 더 간단하게 처리할 수 있는 문제이기 때문에 이후에는 가변 배열을 사용해서 풀어보기로 한다.</p>
