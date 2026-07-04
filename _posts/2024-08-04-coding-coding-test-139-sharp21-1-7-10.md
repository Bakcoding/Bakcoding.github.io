---
title: "백준 코딩테스트 #21. 1차원 배열 (7 ~ 10)"
excerpt: "백준 코딩테스트 #21. 1차원 배열 (7 ~ 10)"
categories:
  - CodingTest
permalink: /coding/coding-test/139-sharp21-1-7-10/
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
date: 2024-08-04
last_modified_at: 2024-08-04
source_url: https://b-note.tistory.com/139
---

<h2>7번 과제 안 내신 분</h2>
<p><b>문제</b></p>
<p>X대학&nbsp;M교수님은&nbsp;프로그래밍&nbsp;수업을&nbsp;맡고&nbsp;있다.&nbsp;교실엔&nbsp;학생이&nbsp;30명이&nbsp;있는데,&nbsp;학생&nbsp;명부엔&nbsp;각&nbsp;학생별로&nbsp;1번부터&nbsp;30번까지&nbsp;출석번호가&nbsp;붙어&nbsp;있다.&nbsp;</p>

<p>교수님이&nbsp;내준&nbsp;특별과제를&nbsp;28명이&nbsp;제출했는데,&nbsp;그중에서&nbsp;제출&nbsp;안&nbsp;한&nbsp;학생&nbsp;2명의&nbsp;출석번호를&nbsp;구하는&nbsp;프로그램을&nbsp;작성하시오.</p>

<p><b>입력</b></p>
<p>입력은&nbsp;총&nbsp;28줄로&nbsp;각&nbsp;제출자(학생)의&nbsp;출석번호&nbsp;n(1&nbsp;&le;&nbsp;n&nbsp;&le;&nbsp;30)가&nbsp;한&nbsp;줄에&nbsp;하나씩&nbsp;주어진다.&nbsp;출석번호에&nbsp;중복은&nbsp;없다.</p>

<p><b>출력</b></p>
<p>출력은&nbsp;2줄이다.&nbsp;1번째&nbsp;줄엔&nbsp;제출하지&nbsp;않은&nbsp;학생의&nbsp;출석번호&nbsp;중&nbsp;가장&nbsp;작은&nbsp;것을&nbsp;출력하고,&nbsp;2번째&nbsp;줄에선&nbsp;그다음&nbsp;출석번호를&nbsp;출력한다.</p>

<p>배열 사이즈는 학생 수만큼, 각 인덱스에는 다음 입력에서 들어오는 과제를 제출한 학생의 출석번호 - 1의 인덱스에 체크를 해준다.</p>

<h3>C++</h3>
<pre class="cpp"><code>#include &lt;iostream&gt;
#include &lt;vector&gt;
using namespace std;
int main(){
    vector&lt;int&gt; num_vec(30);
    for (int i = 0; i &lt; 28; i++){
        int num;
        cin &gt;&gt; num;
        num_vec[num - 1] = 1;
    }
    int count = 1;
    for (int i : num_vec){
        if (i != 1){
            cout &lt;&lt; count &lt;&lt; "\n";
        }
        count++;
    }
    return 0;
}</code></pre>

<p>과제를 제출한 학생의 인덱스는 1의 값으로 체크해 두고 출력 시 확인한다.</p>

<h3>C#</h3>
<pre class="csharp"><code>using System;
using System.Collections.Generic;
class Program{
    static void Main(string[] args){
        List&lt;int&gt; num_list = new List&lt;int&gt;(new int[30]);
        for (int i = 0; i &lt; 28; i++){
            int num = int.Parse(Console.ReadLine());
            num_list[num - 1] = 1;
        }
        int count = 1;
        foreach(int i in num_list){
            if (i != 1)
                Console.WriteLine(count);
            count++;
        }
    }
}</code></pre>

<h3>Python</h3>
<pre class="python"><code>num_list = [0] * 30
for i in range(28):
    num = int(input())
    num_list[num - 1] = 1
count = 1
for i in range(30):
    if num_list[i] != 1:
        print(f"{count}")
    count += 1</code></pre>

<h2>8번 나머지</h2>
<p><b>문제</b></p>
<p>두&nbsp;자연수&nbsp;A와&nbsp;B가&nbsp;있을&nbsp;때,&nbsp;A% B는&nbsp;A를&nbsp;B로&nbsp;나눈&nbsp;나머지이다.&nbsp;예를&nbsp;들어,&nbsp;7,&nbsp;14,&nbsp;27,&nbsp;38을&nbsp;3으로&nbsp;나눈&nbsp;나머지는&nbsp;1,&nbsp;2,&nbsp;0,&nbsp;2이다.&nbsp;</p>

<p>수&nbsp;10개를&nbsp;입력받은&nbsp;뒤,&nbsp;이를&nbsp;42로&nbsp;나눈&nbsp;나머지를&nbsp;구한다.&nbsp;그다음&nbsp;서로&nbsp;다른&nbsp;값이&nbsp;몇&nbsp;개&nbsp;있는지&nbsp;출력하는&nbsp;프로그램을&nbsp;작성하시오.</p>

<p><b>입력</b></p>
<p>첫째&nbsp;줄부터&nbsp;열 번째&nbsp;줄&nbsp;까지&nbsp;숫자가&nbsp;한&nbsp;줄에&nbsp;하나씩&nbsp;주어진다.&nbsp;이&nbsp;숫자는&nbsp;1,000보다&nbsp;작거나&nbsp;같고,&nbsp;음이&nbsp;아닌&nbsp;정수이다.</p>

<p><b>출력</b></p>
<p>첫째&nbsp;줄에,&nbsp;42로&nbsp;나누었을&nbsp;때,&nbsp;서로&nbsp;다른&nbsp;나머지가&nbsp;몇&nbsp;개&nbsp;있는지&nbsp;출력한다.</p>

<p>입력받은 수를 42로 나누고 나머지를 저장해 둔다. 이 나머지 중에서 서로 다른 것들만 출력한다.</p>
<p>입력되는 수의 범위는 0이 아닌 1000 이하의 정수이다. 배열에 나머지를 저장할 때 요소에 해당 나머지가 없을 때만 저장해 둔다.</p>

<h3>C++</h3>
<pre class="cpp"><code>#include &lt;iostream&gt;
#include &lt;vector&gt;
#include &lt;algorithm&gt;
using namespace std;
int main(){
    int num, remain;
    vector&lt;int&gt; num_vec;
    for (int i = 0; i &lt; 10; i++){
        cin &gt;&gt; num;
        remain = num % 42;
        if (find(num_vec.begin(), num_vec.end(), remain) == num_vec.end()){
            num_vec.push_back(remain);
        }
    }
    cout &lt;&lt; num_vec.size();
    return 0;
}</code></pre>

<p>find를 사용해서 배열에 해당 요소가 있는지 검색 후 없으면 추가한다.</p>

<h3>C#</h3>
<pre class="csharp"><code>using System;
using System.Collections.Generic;
class Program{
    static void Main(string[] args){
        List&lt;int&gt; num_list = new List&lt;int&gt;();
        for (int i = 0; i &lt; 10; i++){
            int num = int.Parse(Console.ReadLine());
            int remain = num % 42;
            if (!num_list.Contains(remain)){
                num_list.Add(remain);
            }
        }
        Console.WriteLine(num_list.Count);
    }
}</code></pre>

<p>List는 Contains를 사용해서 요소를 포함하고 있는지 확인할 수 있다.</p>

<h3>Python</h3>
<pre class="python"><code>num_list = []
for i in range(10):
    num = int(input());
    remain = num % 42
    if remain not in num_list:
        num_list.append(remain)
print(len(num_list))</code></pre>

<p>파이썬의 경우 조건문의 문법에서 리스트의 요소를 검색해 볼 수 있다.</p>

<h3>Node.js</h3>
<pre class="javascript"><code>const fs = require('fs');
const input = fs.readFileSync('/dev/stdin','utf8').split('\n').map(Number);
const list = [];
for (let i = 0; i &lt; 10; i++){
    const num = input[i];
    const remain = num % 42;
    if (!list.includes(remain)){
        list.push(remain);
    }
}
console.log(list.length);</code></pre>

<p>includes를 사용해서 배열을 탐색하고 push로 값을 넣는다.</p>

<h2>9번 바구니 뒤집기</h2>
<p><b>문제</b></p>
<p>도현이는&nbsp;바구니를&nbsp;총&nbsp;N개&nbsp;가지고&nbsp;있고,&nbsp;각각의&nbsp;바구니에는&nbsp;1번부터&nbsp;N번까지&nbsp;번호가&nbsp;순서대로&nbsp;적혀&nbsp;있다.&nbsp;바구니는&nbsp;일렬로&nbsp;놓여&nbsp;있고,&nbsp;가장&nbsp;왼쪽&nbsp;바구니를&nbsp;1번째&nbsp;바구니,&nbsp;그다음&nbsp;바구니를&nbsp;2번째&nbsp;바구니,...,&nbsp;가장&nbsp;오른쪽&nbsp;바구니를&nbsp;N번째&nbsp;바구니라고&nbsp;부른다.&nbsp;</p>

<p>도현이는&nbsp;앞으로&nbsp;M번&nbsp;바구니의&nbsp;순서를&nbsp;역순으로&nbsp;만들려고&nbsp;한다.&nbsp;도현이는&nbsp;한&nbsp;번&nbsp;순서를&nbsp;역순으로&nbsp;바꿀&nbsp;때,&nbsp;순서를&nbsp;역순으로&nbsp;만들&nbsp;범위를&nbsp;정하고,&nbsp;그&nbsp;범위에&nbsp;들어있는&nbsp;바구니의&nbsp;순서를&nbsp;역순으로&nbsp;만든다.&nbsp;</p>

<p>바구니의&nbsp;순서를&nbsp;어떻게&nbsp;바꿀지&nbsp;주어졌을&nbsp;때,&nbsp;M번&nbsp;바구니의&nbsp;순서를&nbsp;역순으로&nbsp;만든&nbsp;다음,&nbsp;바구니에&nbsp;적혀있는&nbsp;번호를&nbsp;가장&nbsp;왼쪽&nbsp;바구니부터&nbsp;출력하는&nbsp;프로그램을&nbsp;작성하시오.</p>

<p><b>입력</b></p>
<p>첫째&nbsp;줄에&nbsp;N&nbsp;(1&nbsp;&le;&nbsp;N&nbsp;&le;&nbsp;100)과&nbsp;M&nbsp;(1&nbsp;&le;&nbsp;M&nbsp;&le;&nbsp;100)이&nbsp;주어진다.&nbsp;</p>

<p>둘째&nbsp;줄부터&nbsp;M개의&nbsp;줄에는&nbsp;바구니의&nbsp;순서를&nbsp;역순으로&nbsp;만드는&nbsp;방법이&nbsp;주어진다.&nbsp;방법은&nbsp;i&nbsp;j로&nbsp;나타내고,&nbsp;왼쪽으로부터&nbsp;i번째&nbsp;바구니부터&nbsp;j번째&nbsp;바구니의&nbsp;순서를&nbsp;역순으로&nbsp;만든다는&nbsp;뜻이다.&nbsp;(1&nbsp;&le;&nbsp;i&nbsp;&le;&nbsp;j&nbsp;&le;&nbsp;N)&nbsp;</p>

<p>도현이는&nbsp;입력으로&nbsp;주어진&nbsp;순서대로&nbsp;바구니의&nbsp;순서를&nbsp;바꾼다.</p>

<p><b>출력</b></p>
<p>모든&nbsp;순서를&nbsp;바꾼&nbsp;다음에,&nbsp;가장&nbsp;왼쪽에&nbsp;있는&nbsp;바구니부터&nbsp;바구니에&nbsp;적혀있는&nbsp;순서를&nbsp;공백으로&nbsp;구분해&nbsp;출력한다.</p>

<p>N크기의 배열의 특정 인덱스 범위의 순서를 M번 뒤집는 작업을 하고 최종 출력한다.</p>

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
        reverse(num_vec.begin() + i - 1, num_vec.begin() + j);
    }
    for (int l : num_vec){
        cout &lt;&lt; l &lt;&lt; " ";
    }
    return 0;
}</code></pre>

<p>reverse를 사용해서 배열의 특정 인덱스 범위에서 요소를 뒤집는다.</p>

<h3>C#</h3>
<pre class="csharp"><code>using System;
using System.Collections.Generic;
using System.Linq;
class Program{
    static void Main(string[] args){
        int n, m, i, j;
        int[] info = Console.ReadLine().Split().Select(int.Parse).ToArray();
        n = info[0];
        m = info[1];
        List&lt;int&gt; num_list = Enumerable.Range(1, n).ToList();
        for (int k = 0; k &lt; m; k++){
            int[] data = Console.ReadLine().Split().Select(int.Parse).ToArray();
            i = data[0] - 1;
            j = data[1] - 1;
            num_list.Reverse(i, j - i + 1);
        }
        Console.WriteLine(string.Join(" ", num_list));
    }
}</code></pre>

<p>Reverse 함수를 사용해서 특정한 범위의 인덱스 값을 뒤지어준다. 이때 인수는 시작 인덱스와 개수이다.&nbsp;</p>

<h3>Python</h3>
<pre class="python"><code>info_list = list(map(int, input().split()))
n = info_list[0]
m = info_list[1]
num_list = list(range(1, n + 1))
for k in range(m):
    idxs = list(map(int, input().split()))
    i = idxs[0] - 1
    j = idxs[1] - 1
    num_list[i:j+1] = num_list[i:j+1][::-1]
print(" ".join(map(str, num_list)))</code></pre>

<p>num_list [i:j+1] = num_list [i:j+1][::-1]&nbsp;</p>

<p>파이썬의 슬라이싱을 사용해서 배열의 인덱스를 특정해서 순서를 바꾸는 방법이다.</p>

<p>배열의 순서를 뒤집는 방법에는 몇 가지 있다.</p>

<p><b>reverse()</b></p>
<pre class="python"><code># reverse()
num_list = [1, 2, 3, 4, 5]
num_list.reverse()
print(num_list)  # [5, 4, 3, 2, 1]</code></pre>

<p>reverse를 사용하면 원본 리스트의 요소가 뒤집어진다.</p>

<p><b>슬라이싱</b></p>
<pre class="python"><code># Slicing
num_list = [1, 2, 3, 4, 5]
reversed_list = num_list[::-1]
print(reversed_list)  # [5, 4, 3, 2, 1]</code></pre>

<p><span style="color: #333333; text-align: start;">슬라이싱을 사용하면 해당 리스트의 요소를 뒤집은 새로운 리스트를 생성한다.</span></p>

<p><b><span style="color: #333333; text-align: start;">reversed()</span></b></p>
<pre class="python"><code>num_list = [1, 2, 3, 4, 5]
reversed_list = list(reversed(num_list))
print(reversed_list)  # [5, 4, 3, 2, 1]</code></pre>

<p>reversed 함수를 사용하면 리스트의 역순으로 정렬된 반복자를 반환한다. 이 반환값을 다시 리스트로 변환하면 뒤집어진 리스트를 만들 수 있다.</p>

<h3>Node.js</h3>
<pre class="javascript"><code>const fs = require('fs');
const info_list = fs.readFileSync('/dev/stdin','utf8').split('\n');
const [n,m] = info_list[0].split(' ').map(Number);
let num_list = Array.from({ length: n }, (_, index) =&gt; index + 1);
for (k = 1; k &lt;= m; k++){
    const [i, j] = info_list[k].split(' ').map(Number);
    const start = i - 1;
    const end = j - 1; 
    num_list.splice(start, end - start + 1, ...num_list.slice(start, end + 1).reverse());
}
console.log(num_list.join(' '));</code></pre>


<p>splice 함수는 배열의 특정 범위를 제거하거나 추가할 때 사용한다.&nbsp;</p>
<pre class="javascript"><code>array.splice(start, deleteCount, item1, item2, ...)</code></pre>

<p>start는 필수 매개변수로 deleteCount를 따로 지정하지 않으면 start부터 인덱스 끝까지 제거한다.</p>

<p>item 매개변수들은 선택 사항으로 start 인덱스 뒤에 item을 배열에 추가한다.</p>

<h2>10번 평균</h2>
<p><b>문제</b></p>
<p>세준이는 기말고사를 망쳤다. 세준이는 점수를 조작해서 집에 가져가기로 했다. 일단 세준이는 자기 점수 중에 최댓값을 골랐다. 이 값을 M이라고 한다. 그러고 나서 모든 점수를 '점수/M*100'으로 고쳤다.&nbsp;</p>

<p>예를&nbsp;들어,&nbsp;세준이의&nbsp;최고점이&nbsp;70이고,&nbsp;수학점수가&nbsp;50이었으면&nbsp;수학점수는&nbsp;50/70*100이&nbsp;되어&nbsp;71.43점이&nbsp;된다.&nbsp;</p>

<p>세준이의&nbsp;성적을&nbsp;위의&nbsp;방법대로&nbsp;새로&nbsp;계산했을&nbsp;때,&nbsp;새로운&nbsp;평균을&nbsp;구하는&nbsp;프로그램을&nbsp;작성하시오.</p>

<p><b>입력</b></p>
<p>첫째&nbsp;줄에&nbsp;시험&nbsp;본&nbsp;과목의&nbsp;개수&nbsp;N이&nbsp;주어진다.&nbsp;이&nbsp;값은&nbsp;1000보다&nbsp;작거나&nbsp;같다.&nbsp;둘째&nbsp;줄에&nbsp;세준이의&nbsp;현재&nbsp;성적이&nbsp;주어진다.&nbsp;이&nbsp;값은&nbsp;100보다&nbsp;작거나&nbsp;같은&nbsp;음이&nbsp;아닌&nbsp;정수이고,&nbsp;적어도&nbsp;하나의&nbsp;값은&nbsp;0보다&nbsp;크다.</p>

<p><b>출력</b></p>
<p>첫째 줄에 새로운 평균을 출력한다. 실제 정답과 출력값의 절대오차 또는 상대오차가 10^-2 이하이면 정답이다.</p>

<p>기말고사를 망친 세준이의 성적을 조작한다.</p>

<p>최고 점수를 사용해서 점수를 조작하고 조작된 점수들의 평균을 내서 출력한다.</p>
<h3>C++</h3>
<pre class="cpp"><code>#include &lt;iostream&gt;
#include &lt;vector&gt;
#include &lt;algorithm&gt;
#include &lt;numeric&gt;
using namespace std;
int main(){
    int n;
    cin &gt;&gt; n;
    vector&lt;float&gt; num_vec(n);
    for (int i = 0; i &lt; n; i++){
        float score;
        cin &gt;&gt; score;
        num_vec[i] = score;
    }
    auto max_iter = max_element(num_vec.begin(), num_vec.end());
    float max_val = *max_iter;
    for (int i = 0; i &lt; n; i++){
        num_vec[i] = num_vec[i] / max_val * 100;
    }
    float sum = accumulate(num_vec.begin(), num_vec.end(), 0.0f);
    cout &lt;&lt; sum / n;
    return 0;
}</code></pre>

<p>본래의 성적을 저장하고 최대 값을 구한 뒤 조작한 성적을 다시 배열에 저장하고 합산하여 평균을 구한다.</p>

<p>accumulate 함수를 사용해서 배열 요소들의 합을 구한다.</p>

<h3>C#</h3>
<pre class="csharp"><code>using System;
using System.Collections.Generic;
using System.Linq;
class Program{
    static void Main(string[] args){
        int n = int.Parse(Console.ReadLine());
        List&lt;float&gt; num_list = Console.ReadLine().Split().Select(float.Parse).ToList();
        float max_val = num_list.Max();
        for (int i = 0; i &lt; n; i++){
            num_list[i] = num_list[i] / max_val * 100;
        }
        float sum = num_list.Sum();
        Console.WriteLine(sum / n);
    }
}</code></pre>

<p>List.Sum() 함수는 요소의 합산을 구할 수 있다.</p>

<h3>Python</h3>
<pre class="python"><code>n = int(input())
num_list = map(float, input().split(' '))
max_val = max(num_list);
for i in range(n):
    num_list[i] = num_list[i] / max_val * 100
sum_val = sum(num_list)
print(f"{sum_val / n}")</code></pre>

<h3>Node.js</h3>
<pre class="javascript"><code>const fs = require('fs');
const input = fs.readFileSync('/dev/stdin','utf8').split('\n');
const n = parseInt(input[0]);
const num_list = input[1].split(' ').map(Number);
const max = Math.max(...num_list);
for (let i = 0; i &lt; n; i++){
    num_list[i] = num_list[i] / max * 100;
}
const sum = num_list.reduce((acc, curr) =&gt; acc + curr, 0);
console.log(sum / n);</code></pre>

<p>Math.max를 사용할 때는 스프레드 연산자로 매개변수를 전달해야 한다.</p>
