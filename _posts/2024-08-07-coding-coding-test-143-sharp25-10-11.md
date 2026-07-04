---
title: "백준 코딩테스트 #25. 문자열 (10, 11)"
excerpt: "백준 코딩테스트 #25. 문자열 (10, 11)"
categories:
  - CodingTest
permalink: /coding/coding-test/143-sharp25-10-11/
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
date: 2024-08-07
last_modified_at: 2024-08-07
source_url: https://b-note.tistory.com/143
---

<h2>10번 다이얼</h2>
<p><b>문제</b></p>
<p>상근이의&nbsp;할머니는&nbsp;아래&nbsp;그림과&nbsp;같이&nbsp;오래된&nbsp;다이얼&nbsp;전화기를&nbsp;사용한다.</p>
<p><figure class="imageblock alignCenter" data-ke-mobileStyle="widthOrigin" data-origin-width="534" data-origin-height="530"><span data-alt="https://www.acmicpc.net/problem/5622"><img src="/assets/images/posts/2024/08/07/143-1.png" loading="lazy" width="232" height="230" data-origin-width="534" data-origin-height="530"/></span><figcaption>https://www.acmicpc.net/problem/5622</figcaption>
</figure>
</p>

<p>전화를&nbsp;걸고&nbsp;싶은&nbsp;번호가&nbsp;있다면,&nbsp;숫자를&nbsp;하나를&nbsp;누른&nbsp;다음에&nbsp;금속&nbsp;핀이&nbsp;있는&nbsp;곳까지&nbsp;시계방향으로&nbsp;돌려야&nbsp;한다.&nbsp;숫자를&nbsp;하나&nbsp;누르면&nbsp;다이얼이&nbsp;처음&nbsp;위치로&nbsp;돌아가고,&nbsp;다음&nbsp;숫자를&nbsp;누르려면&nbsp;다이얼을&nbsp;처음&nbsp;위치에서&nbsp;다시&nbsp;돌려야&nbsp;한다.</p>

<p>숫자&nbsp;1을&nbsp;걸려면&nbsp;총&nbsp;2초가&nbsp;필요하다.&nbsp;1보다&nbsp;큰&nbsp;수를&nbsp;거는 데&nbsp;걸리는&nbsp;시간은&nbsp;이보다&nbsp;더&nbsp;걸리며,&nbsp;한&nbsp;칸&nbsp;옆에&nbsp;있는&nbsp;숫자를&nbsp;걸기&nbsp;위해선&nbsp;1초씩&nbsp;더&nbsp;걸린다.</p>

<p>상근이의&nbsp;할머니는&nbsp;전화번호를&nbsp;각&nbsp;숫자에&nbsp;해당하는&nbsp;문자로&nbsp;외운다.&nbsp;즉,&nbsp;어떤&nbsp;단어를&nbsp;걸&nbsp;때,&nbsp;각&nbsp;알파벳에&nbsp;해당하는&nbsp;숫자를&nbsp;걸면&nbsp;된다.&nbsp;예를&nbsp;들어,&nbsp;UNUCIC는&nbsp;868242와&nbsp;같다.</p>

<p>할머니가&nbsp;외운&nbsp;단어가&nbsp;주어졌을&nbsp;때,&nbsp;이&nbsp;전화를&nbsp;걸기&nbsp;위해서&nbsp;필요한&nbsp;최소&nbsp;시간을&nbsp;구하는&nbsp;프로그램을&nbsp;작성하시오.</p>

<p><b>입력</b></p>
<p>첫째&nbsp;줄에&nbsp;알파벳&nbsp;대문자로&nbsp;이루어진&nbsp;단어가&nbsp;주어진다.&nbsp;단어의&nbsp;길이는&nbsp;2보다&nbsp;크거나&nbsp;같고,&nbsp;15보다&nbsp;작거나&nbsp;같다.</p>

<p><b>출력</b></p>
<p>첫째&nbsp;줄에&nbsp;다이얼을&nbsp;걸기&nbsp;위해서&nbsp;필요한&nbsp;최소&nbsp;시간을&nbsp;출력한다.</p>

<p>문제가 좀 복잡해 보인다. 2번부터 알파벳이 들어가 있고 7, 9에는 4개, 나머지 번호는 3개씩 번호가 있다.</p>



<p>단어가 주어질 때 걸리는 시간을 출력해야 하므로 대응하는 번호를 누르는 데 걸리는 시간을 계산해야 한다.</p>

<p>65 - 90</p>
<h3>C++</h3>
<pre class="cpp"><code>#include &lt;iostream&gt;
#include &lt;string&gt;
using namespace std;
int main(){
    string s;
    cin &gt;&gt; s;
    int sum_time = 0;
    for (int i = 0; i &lt; s.length(); i++){
        int n = s[i] - 'A';
        if (n &lt; 3) //2
            sum_time += 3;
        else if (n &lt; 6) //3
            sum_time += 4;
        else if (n &lt; 9) // 4
            sum_time += 5;
        else if (n &lt; 12) // 5
            sum_time += 6;
        else if (n &lt; 15) // 6
            sum_time += 7;
        else if (n &lt; 19) // 7
            sum_time += 8;
        else if (n &lt; 22) // 8
            sum_time += 9;
        else             // 9
            sum_time += 10;
    }
    cout &lt;&lt; sum_time;
    return 0;
}</code></pre>

<p>일단 조건에 맞춰서 코드를 작성해 본다.</p>

<p>조금 더 간소화시켜서 다이얼의 걸리는 시간 정보를 배열에 모두 담고 이 배열에서 걸리는 시간을 꺼내 쓰는 방법으로 풀어본다.</p>

<pre class="cpp"><code>#include &lt;iostream&gt;
#include &lt;string&gt;
using namespace std;
int main(){
    string s;
    cin &gt;&gt; s;
    int dial_times[26] = {
        3, 3, 3,  // 2)A, B, C
        4, 4, 4,  // 3)D, E, F
        5, 5, 5,  // 4)G, H, I
        6, 6, 6,  // 5)J, K, L
        7, 7, 7,  // 6) M, N, O
        8, 8, 8, 8,  // 7) P, Q, R, S
        9, 9, 9,  // 8) T, U, V
        10, 10, 10, 10  // 9) W, X, Y, Z
    };
        
    int sum_time = 0;
    for (char c : s){
        sum_time += dial_times[c - 'A'];
    }
    cout &lt;&lt; sum_time;
    return 0;
}</code></pre>

<p>알파벳마다 대응하는 배열의 인덱스에 걸리는 시간 정보를 저장해서 조건문 없이 걸리는 시간을 가져와서 사용할 수 있다.</p>

<p>배열로 표현한 게 좀 더 보기 쉽고 수정도 편할 거 같아 보인다.</p>

<h3>C#</h3>
<pre class="python"><code>using System;
class Program{
    static void Main(string[] args){
        string s = Console.ReadLine();
        int[] dial_times = new int[26]{
            3, 3, 3,       // 2) A, B, C
            4, 4, 4,       // 3) D, E, F
            5, 5, 5,       // 4) G, H, I
            6, 6, 6,       // 5) J, K, L
            7, 7, 7,       // 6) M, N, O
            8, 8, 8, 8,    // 7) P, Q, R, S
            9, 9, 9,       // 8) T, U, V
            10, 10, 10, 10 // 9) W, X, Y, Z
        };
        int sum_time = 0;
        foreach(char c in s){
            sum_time += dial_times[c - 'A'];
        }
        Console.WriteLine(sum_time);
    }
}</code></pre>

<p>떠오른 방법 중에는 이렇게 하는 게 제일 간단한 거 같아서 다른 언어들도 동일한 방식으로 진행해 본다.</p>

<h3>Python</h3>
<pre class="python"><code>s = input()
dial_times = [
    3, 3, 3,       # 2) A, B, C
    4, 4, 4,       # 3) D, E, F
    5, 5, 5,       # 4) G, H, I
    6, 6, 6,       # 5) J, K, L
    7, 7, 7,       # 6) M, N, O
    8, 8, 8, 8,    # 7) P, Q, R, S
    9, 9, 9,       # 8) T, U, V
    10, 10, 10, 10 # 9) W, X, Y, Z
]
sum_time = 0
for c in s:
    sum_time += dial_times[ord(c) - ord('A')]
print(sum_time)</code></pre>

<h3>Node.js</h3>
<pre class="javascript"><code>const fs = require('fs');
const input = fs.readFileSync('/dev/stdin','utf8').trim().split('');
const dial_times = [
    3, 3, 3,       // 2) A, B, C
    4, 4, 4,       // 3) D, E, F
    5, 5, 5,       // 4) G, H, I
    6, 6, 6,       // 5) J, K, L
    7, 7, 7,       // 6) M, N, O
    8, 8, 8, 8,    // 7) P, Q, R, S
    9, 9, 9,       // 8) T, U, V
    10, 10, 10, 10 // 9) W, X, Y, Z
];
let sum_time = 0;
input.forEach(c =&gt; {
    sum_time += dial_times[c.charCodeAt(0) - 'A'.charCodeAt(0)];
});
console.log(sum_time);</code></pre>

<h2>11번 그대로 출력하기</h2>
<p><b>문제</b></p>
<p>입력받은&nbsp;대로&nbsp;출력하는&nbsp;프로그램을&nbsp;작성하시오.</p>

<p><b>입력</b></p>
<p>입력이&nbsp;주어진다.&nbsp;입력은&nbsp;최대&nbsp;100줄로&nbsp;이루어져&nbsp;있고,&nbsp;알파벳&nbsp;소문자,&nbsp;대문자,&nbsp;공백,&nbsp;숫자로만&nbsp;이루어져&nbsp;있다.&nbsp;각&nbsp;줄은&nbsp;100글자를&nbsp;넘지&nbsp;않으며,&nbsp;빈&nbsp;줄은&nbsp;주어지지&nbsp;않는다.&nbsp;또,&nbsp;각&nbsp;줄은&nbsp;공백으로&nbsp;시작하지&nbsp;않고,&nbsp;공백으로&nbsp;끝나지&nbsp;않는다. 은&nbsp;대로&nbsp;출력하는&nbsp;프로그램을&nbsp;작성하시오.</p>

<p><b>출력</b></p>
<p>입력받은&nbsp;그대로&nbsp;출력한다.</p>

<p>이번엔 상당히 간단한 문제가 주어진다. 입력받은 문자를 그대로 출력해야 한다.&nbsp;</p>

<h3>C++</h3>
<pre class="cpp"><code>#include &lt;iostream&gt;
#include &lt;string&gt;
using namespace std;
int main(){
    string s;
    while (getline(cin, s)){
        cout &lt;&lt; s &lt;&lt; "\n";
    }
    return 0;
}</code></pre>

<p>입력을 줄 단위로 구분해서 그대로 출력해야 하기 때문에 getline() 함수를 사용한다.</p>

<p>getline() 사용하면 줄 단위로 입력을 처리할 수 있다.</p>

<h3>C#</h3>
<pre class="csharp"><code>using System;
class Program{
    static void Main(string[] args){
        string s;
        while ((s = Console.ReadLine()) != null){
            Console.WriteLine(s);
        }
    }
}</code></pre>

<p>ReadLine()은 기본적으로 줄 단위로 입력받기 때문에 입력이 없을 때까지 받고 출력하고를 반복하면 된다.</p>

<h3>Python</h3>
<pre class="python"><code>while True:
    try:
        s = input()
        if s == '':
            break
        print(s)
    except EOFError:
        break</code></pre>

<p>입력이 없을 때 발생하는 EOFError를 처리하기 위해서 try ~ except를 사용한다.</p>

<h3>Node.js</h3>
<pre class="javascript"><code>const fs = require('fs');
const input = fs.readFileSync('/dev/stdin', 'utf8').trim().split('\n');
input.forEach(s =&gt; {
   console.log(s); 
});</code></pre>

<p>문자열 챕터의 마지막 문제였는데 상당히 간단했다.</p>
