---
title: "백준 코딩테스트 #20. 1차원 배열 (4 ~ 6)"
excerpt: "백준 코딩테스트 #20. 1차원 배열 (4 ~ 6)"
categories:
  - CodingTest
permalink: /coding/coding-test/138-sharp20-1-4-6/
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
source_url: https://b-note.tistory.com/138
---

<h2>4번 최댓값</h2>
<p><b>문제</b></p>
<p>9개의&nbsp;서로&nbsp;다른&nbsp;자연수가&nbsp;주어질&nbsp;때,&nbsp;이들&nbsp;중&nbsp;최댓값을&nbsp;찾고&nbsp;그&nbsp;최댓값이&nbsp;몇&nbsp;번째&nbsp;수인지를&nbsp;구하는&nbsp;프로그램을&nbsp;작성하시오.&nbsp;</p>

<p>예를&nbsp;들어,&nbsp;서로&nbsp;다른&nbsp;9개의&nbsp;자연수&nbsp;3,&nbsp;29,&nbsp;38,&nbsp;12,&nbsp;57,&nbsp;74,&nbsp;40,&nbsp;85,&nbsp;61&nbsp;이&nbsp;주어지면,&nbsp;이들&nbsp;중&nbsp;최댓값은&nbsp;85이고,&nbsp;이&nbsp;값은&nbsp;8번째&nbsp;수이다.</p>

<p><b>입력</b></p>
<p>첫째&nbsp;줄부터&nbsp;아홉&nbsp;번째&nbsp;줄까지&nbsp;한&nbsp;줄에&nbsp;하나의&nbsp;자연수가&nbsp;주어진다.&nbsp;주어지는&nbsp;자연수는&nbsp;100&nbsp;보다&nbsp;작다.</p>

<p><b>출력</b></p>
<p>첫째&nbsp;줄에&nbsp;최댓값을&nbsp;출력하고,&nbsp;둘째&nbsp;줄에&nbsp;최댓값이&nbsp;몇&nbsp;번째&nbsp;수인지를&nbsp;출력한다.</p>

<h3>C++</h3>
<pre class="cpp"><code>#include &lt;iostream&gt;
#include &lt;vector&gt;
#include &lt;algorithm&gt;
using namespace std;
int main(){
    int n;
    vector&lt;int&gt; vec;
    while(cin &gt;&gt; n){
        vec.push_back(n);
    }
    auto iter = max_element(vec.begin(), vec.end());
    int index = distance(vec.begin(), iter);
    cout &lt;&lt; *iter &lt;&lt; "\n" &lt;&lt; index + 1;
    return 0;
}</code></pre>

<p>distance 함수를 사용해서 iter가 해당 벡터에서 몇 번째 인덱스인지 구한다.</p>

<h3>C#</h3>
<pre class="csharp"><code>using System;
using System.Collections.Generic;
using System.Linq;
class Program{
    static void Main(string[] args){
        List&lt;int&gt; num_list = new List&lt;int&gt;();
        for (int i = 0; i &lt; 9; i++){
            int val = int.Parse(Console.ReadLine());
            num_list.Add(val);
        }
        int max = num_list.Max();
        int index = num_list.IndexOf(max);
        Console.WriteLine($"{max}\n{index+1}");
    }
}</code></pre>

<h3>Python</h3>
<pre class="python"><code>num_list = []
for i in range(9):
    num_list.append(int(input()))
max_val = max(num_list)
index = num_list.index(max_val)
print(max_val)
print(index + 1)</code></pre>

<p>[]로 가변 배열을 선언한다. 이 배열은 기본 타입인 list와 동일한 타입의 객체이다.</p>
<p><span style="text-align: start"><span>&nbsp;</span>num_list = list()</span>와 동일한 객체</p>
<p>이 객체는 apeend를 사용해서 값을 추가할 수 있고 index로 요소의 인덱스를 검색할 수 있다.</p>

<h3>Node.js</h3>
<pre class="javascript"><code>const fs = require('fs');
const num_list = fs.readFileSync('/dev/stdin', 'utf8').trim().split('\n').map(Number);
const max_num = Math.max(...num_list);
const index = num_list.indexOf(max_num);
console.log(max_num);
console.log(index + 1);</code></pre>

<p>indexOf 메서드로 최댓값의 인덱스를 찾을 수 있다.</p>

<h2>5번 공 넣기</h2>
<p><b>문제</b></p>
<p>도현이는&nbsp;바구니를&nbsp;총&nbsp;N개&nbsp;가지고&nbsp;있고,&nbsp;각각의&nbsp;바구니에는&nbsp;1번부터&nbsp;N번까지&nbsp;번호가&nbsp;매겨져&nbsp;있다.&nbsp;또,&nbsp;1번부터&nbsp;N번까지&nbsp;번호가&nbsp;적혀있는&nbsp;공을&nbsp;매우&nbsp;많이&nbsp;가지고&nbsp;있다.&nbsp;가장&nbsp;처음&nbsp;바구니에는&nbsp;공이&nbsp;들어있지&nbsp;않으며,&nbsp;바구니에는&nbsp;공을&nbsp;1개만&nbsp;넣을&nbsp;수&nbsp;있다.</p>

<p>도현이는 앞으로 M번 공을 넣으려고 한다. 도현이는 한 번 공을 넣을 때, 공을 넣을 바구니 범위를 정하고, 정한 바구니에 모두 같은 번호가 적혀있는 공을 넣는다. 만약, 바구니에 공이 이미 있는 경우에는 들어있는 공을 빼고, 새로 공을 넣는다. 공을 넣을 바구니는 연속되어 있어야 한다.</p>

<p>공을 어떻게 넣을지가 주어졌을 때, M번 공을 넣은 이후에 각 바구니에 어떤 공이 들어 있는지 구하는 프로그램을 작성하시오.</p>

<p><b>입력</b></p>
<p>첫째&nbsp;줄에&nbsp;N&nbsp;(1&nbsp;&le;&nbsp;N&nbsp;&le;&nbsp;100)과&nbsp;M&nbsp;(1&nbsp;&le;&nbsp;M&nbsp;&le;&nbsp;100)이&nbsp;주어진다.</p>

<p>둘째 줄부터 M개의 줄에 걸쳐서 공을 넣는 방법이 주어진다. 각 방법은 세 정수 i j k로 이루어져 있으며, i번 바구니부터 j번 바구니까지에 k번 번호가 적혀 있는 공을 넣는다는 뜻이다. 예를 들어, 2 5 6은 2번 바구니부터 5번 바구니까지에 6번 공을 넣는다는 뜻이다. (1 &le; i &le; j &le; N, 1 &le; k &le; N)</p>

<p>도현이는 입력으로 주어진 순서대로 공을 넣는다.</p>

<p><b>출력</b></p>
<p>1번&nbsp;바구니부터&nbsp;N번&nbsp;바구니에&nbsp;들어있는&nbsp;공의&nbsp;번호를&nbsp;공백으로&nbsp;구분해&nbsp;출력한다.&nbsp;공이&nbsp;들어있지&nbsp;않은&nbsp;바구니는&nbsp;0을&nbsp;출력한다.</p>

<p>나열된 바구니들을 배열 각 바구니들 인덱스로 보면 된다. 공에는 번호가 지정되어 있고 규칙에 맞춰 공을 바구니에 넣는다.</p>

<p>입력의 첫 줄에서 바구니의 개수 N과 바구니에 공을 담는 규칙 M개가 들어온다.</p>

<p>그다음에 M개의 줄에 각각 규칙이 들어오는데 순서대로 i j k 각 수는 i , j는 바구니의 범위, k는 넣을 공의 번호이다.</p>

<h3>C++</h3>
<pre class="cpp"><code>#include &lt;iostream&gt;
#include &lt;vector&gt;
#include &lt;algorithm&gt;
using namespace std;
int main(){
    int n, m, i, j, k;
    cin &gt;&gt; n;
    cin &gt;&gt; m;
    vector&lt;int&gt; num_vec(n, 0);
    for (int l = 0; l &lt; m; l++){
        cin &gt;&gt; i &gt;&gt; j &gt;&gt; k;
        fill(num_vec.begin() + i - 1, num_vec.begin() + j, k);
    }
     for (int num : num_vec) {
        cout &lt;&lt; num &lt;&lt; " ";
    }
    return 0;
}</code></pre>

<p>컨테이너는 바구니의 개수만큼 사이즈를 만들고 값은 0으로 초기화해서 값이 없을 때 0으로 출력되도록 한다.</p>
<p>컨테이너의 범위 내에 특정 값을 채우기 위해서 fill 함수를 사용한다.</p>
<p>시작과 끝 범위, 채울 값을 인자로 받는다.</p>

<h3>C#</h3>
<pre class="csharp"><code>using System;
using System.Collections.Generic;
using System.Linq;
class Program{
    static void Main(string[] args){
        int[] input = Console.ReadLine().Split().Select(int.Parse).ToArray();
        int n, m, i, j, k;
        n = input[0];
        m = input[1];
        List&lt;int&gt; num_list = new List&lt;int&gt;(new int[n]);
        for (int l = 0; l &lt; m; l++){
            int[] rules = Console.ReadLine().Split().Select(int.Parse).ToArray();
            i = rules[0] - 1;
            j = rules[1] - 1;
            k = rules[2];
            for (int o = i; o &lt;= j; o++){
                num_list[o] = k;
            }
        }
        
        foreach(int val in num_list){
            Console.Write($"{val} ");
        }
    }
}</code></pre>

<p>리스트의 경우 특정 범위 내의 요소에 값을 넣을 때 사용할만한 메서드가 없어 이중 반복문으로 처리했다.</p>

<h3>Python</h3>
<pre class="python"><code>input_val = list(map(int, input().split()))
n = input_val[0]
m = input_val[1]
num_list = [0] * n
for l in range(m):
    rules = list(map(int, input().split()))
    i = rules[0]
    j = rules[1]
    k = rules[2]
    for index in range(i - 1, j):
        num_list[index] = k
print(" ".join(map(str, num_list)))</code></pre>

<h3>Node.js</h3>
<pre class="javascript"><code>const fs = require('fs');
const input = fs.readFileSync('/dev/stdin','utf8').split('\n');
const [n, m] = input[0].split(' ').map(Number);
let num_list = Array(n).fill(0);
for (let l = 1; l &lt;= m; l++){
    const [i, j, k] = input[l].split(' ').map(Number);
    for (let idx = i - 1; idx &lt; j; idx++){
        num_list[idx] = k;
    }
}
console.log(num_list.join(' '));</code></pre>

<p>Array(n)로 n크기의 배열을 선언하고 fill(0)으로 값을 0으로 초기화한다.</p>

<h2>6번 공 바꾸기</h2>
<p><b>문제</b></p>
<p>도현이는&nbsp;바구니를&nbsp;총&nbsp;N개&nbsp;가지고&nbsp;있고,&nbsp;각각의&nbsp;바구니에는&nbsp;1번부터&nbsp;N번까지&nbsp;번호가&nbsp;매겨져&nbsp;있다.&nbsp;바구니에는&nbsp;공이&nbsp;1개씩&nbsp;들어있고,&nbsp;처음에는&nbsp;바구니에&nbsp;적혀있는&nbsp;번호와&nbsp;같은&nbsp;번호가&nbsp;적힌&nbsp;공이&nbsp;들어있다.&nbsp;</p>

<p>도현이는&nbsp;앞으로&nbsp;M번&nbsp;공을&nbsp;바꾸려고&nbsp;한다.&nbsp;도현이는&nbsp;공을&nbsp;바꿀&nbsp;바구니&nbsp;2개를&nbsp;선택하고,&nbsp;두&nbsp;바구니에&nbsp;들어있는&nbsp;공을&nbsp;서로&nbsp;교환한다.&nbsp;</p>

<p>공을&nbsp;어떻게&nbsp;바꿀지가&nbsp;주어졌을&nbsp;때,&nbsp;M번&nbsp;공을&nbsp;바꾼&nbsp;이후에&nbsp;각&nbsp;바구니에&nbsp;어떤&nbsp;공이&nbsp;들어있는지&nbsp;구하는&nbsp;프로그램을&nbsp;작성하시오.</p>

<p><b>입력</b></p>
<p>첫째&nbsp;줄에&nbsp;N&nbsp;(1&nbsp;&le;&nbsp;N&nbsp;&le;&nbsp;100)과&nbsp;M&nbsp;(1&nbsp;&le;&nbsp;M&nbsp;&le;&nbsp;100)이&nbsp;주어진다.&nbsp;</p>

<p>둘째&nbsp;줄부터&nbsp;M개의&nbsp;줄에&nbsp;걸쳐서&nbsp;공을&nbsp;교환할&nbsp;방법이&nbsp;주어진다.&nbsp;각&nbsp;방법은&nbsp;두&nbsp;정수&nbsp;i&nbsp;j로&nbsp;이루어져&nbsp;있으며,&nbsp;i번&nbsp;바구니와&nbsp;j번&nbsp;바구니에&nbsp;들어있는&nbsp;공을&nbsp;교환한다는&nbsp;뜻이다.&nbsp;(1&nbsp;&le;&nbsp;i&nbsp;&le;&nbsp;j&nbsp;&le;&nbsp;N)&nbsp;</p>

<p>도현이는&nbsp;입력으로&nbsp;주어진&nbsp;순서대로&nbsp;공을&nbsp;교환한다.</p>

<p><b>출력</b></p>
<p>1번&nbsp;바구니부터&nbsp;N번&nbsp;바구니에&nbsp;들어있는&nbsp;공의&nbsp;번호를&nbsp;공백으로&nbsp;구분해&nbsp;출력한다.</p>

<p>N 사이즈의 배열에 요소들은 index+1 값으로 초기화한 상태로 시작된다.</p>

<h3>C++</h3>
<pre class="cpp"><code>#include &lt;iostream&gt;
#include &lt;vector&gt;
#include &lt;numeric&gt;
#include &lt;algorithm&gt;
using namespace std;
int main(){
    int n, m, i, j;
    cin &gt;&gt; n &gt;&gt; m;
    vector&lt;int&gt; num_vec(n);
    iota(num_vec.begin(), num_vec.end(), 1);
    for (int k = 0; k &lt; m; k++){
        cin &gt;&gt; i &gt;&gt; j;
        swap(num_vec[i - 1], num_vec[j - 1]);
    }
    for (int num : num_vec){
        cout &lt;&lt; num &lt;&lt; " ";
    }
    return 0;
}</code></pre>

<p>iota 함수를 사용해서 컨테이너의 각 요소를 인덱스&nbsp; + 1의 값으로 초기화한다.</p>
<p>algorithm의 swap 함수를 사용해서 컨테이너의 두 인덱스의 값을 교환한다.</p>

<h3>C#</h3>
<pre class="csharp"><code>using System;
using System.Collections.Generic;
using System.Linq;
class Program{
    static void Main(string[] args){
        int[] input = Console.ReadLine().Split().Select(int.Parse).ToArray();
        int n = input[0];
        int m = input[1];
        List&lt;int&gt; num_list = new List&lt;int&gt;(Enumerable.Range(1, n));
        
        for (int l = 0; l &lt; m; l++){
            int[] data = Console.ReadLine().Split().Select(int.Parse).ToArray();
            int i = data[0] - 1;
            int j = data[1] - 1;
            int tmp = num_list[i];
            num_list[i] = num_list[j];
            num_list[j] = tmp;
        }
        foreach(int num in num_list){
            Console.Write(num + " ");
        }
    }
}</code></pre>

<p>new List &lt;int&gt;(Enumerable.Range(1, n)) 으로 각 요소를 1부터 n으로 초기화한다.</p>

<h3>Python</h3>
<pre class="python"><code>input_str = list(map(int, input().split()))
n = input_str[0]
m = input_str[1]
num_list = list(range(1, n + 1))
for _ in range(m):
    i, j = map(int, input().split())
    num_list[i - 1], num_list[j - 1] = num_list[j - 1], num_list[i - 1]
print(" ".join(map(str, num_list)))</code></pre>

<p>파이썬에서 리스트를 초기화할 때 range(1, n + 1) 초기화 시 값을 인덱스 + 1로 값을 넣는다.</p>

<p>출력 시 현재 리스트는 정수타입이므로 문자열로 변환 후 값마다 띄어쓰기를 추가해서 출력한다.</p>

<h3>Node.js</h3>
<pre class="javascript"><code>const fs = require('fs');
const input = fs.readFileSync('/dev/stdin', 'utf8').split('\n');
const [n, m] = input[0].split(' ').map(Number);
let num_list = Array.from({ length : n }, (_, i) =&gt; i + 1);
for (let k = 1; k &lt;= m; k++){
    const [i, j] = input[k].split(' ').map(Number);
    [num_list[i - 1], num_list[j - 1]] = [num_list[j - 1], num_list[i - 1]];
}
console.log(num_list.join(' '));</code></pre>

<p>Array.from({length : n}, (_, i) =&gt; i+1) 이렇게 인덱스 + 1로 각 요소들의 값을 초기화할 수 있다.</p>
<p>값을 교환하는 코드는 파이썬과 동일한 문법으로 우선 좌항과 우항의 오른쪽에 위치한 배열들의 값이 평가되면서 추출된다. 그리고 추출된 값들이 왼쪽에 대응하는 변수에 할당되면서 요소의 교환이 이루어진다.&nbsp;</p>
