---
title: "백준 코딩테스트 #28.  2차원 배열"
excerpt: "백준 코딩테스트 #28.  2차원 배열"
categories:
  - CodingTest
permalink: /coding/coding-test/166-sharp28-2/
tags:
  - "Coding Test"
  - "Baekjoon"
  - "2d arr"
  - "baejoon"
toc: true
toc_sticky: true
date: 2025-04-11
last_modified_at: 2025-04-11
source_url: https://b-note.tistory.com/166
---

<h3>1번 행렬 덧셈</h3>
<h4>문제</h4>
<p>N * M 크기의 두 행렬 A와 B가 주어졌을 때, 두 행렬을 더하는 프로그램을 작성하시오.</p>

<h4>입력</h4>
<p>첫째 줄에 행렬의 크기 N과 M이 주어진다. 둘째 줄부터 N개의 줄에 행렬 A의 원소 M개가 차례대로 주어진다.</p>
<p>이어서 N개의 줄에 행렬 B의 원소 M개가 차례대로 주어진다. N과 M은 100보다 작거나 같고, 행렬의 원소는 절댓값이 100보다 작거나 같은 정수이다.</p>

<h4>출력</h4>
<p>첫째 줄부터 N개의 줄에 행렬 A와 B를 더한 행렬을 출력한다. 행렬의 각 원소는 공백으로 구분한다.</p>

<h4>C++</h4>
<pre class="cpp"><code>#include &lt;iostream&gt;
#include &lt;vector&gt;
using namespace std;
int main(){
    int n, m;
    cin &gt;&gt; n &gt;&gt; m;
    vector&lt;vector&lt;int&gt;&gt; arr_2d(n, vector&lt;int&gt;(m));
    
    for (int i = 0; i &lt; n; i++){
        for(int j = 0; j &lt; m; j++){
            cin &gt;&gt; arr_2d[i][j];
        }
    }
    for (int i = 0; i &lt; n; i++){
        for(int j = 0; j &lt; m; j++){
            int val = 0;
            cin &gt;&gt; val;
            cout &lt;&lt; arr_2d[i][j] + val &lt;&lt; " ";
        }
        cout &lt;&lt; "\n";
    }
}</code></pre>

<h4>C#</h4>
<pre class="csharp"><code>using System;
using System.Collections;
using System.Collections.Generic;
class Program{
    static void Main(string[] args){
        string input = Console.ReadLine();
        string[] input_arr = input.Split();
        int n = int.Parse(input_arr[0]);
        int m = int.Parse(input_arr[1]);
        int[][] arr_2d = new int[n][];
        
        for (int i = 0; i &lt; n; i++){
            arr_2d[i] = new int[m];
        }
        
        for (int i = 0; i &lt; n; i++)
        {
            string[] arr_val = Console.ReadLine().Split();
            for (int j = 0; j &lt; m; j++)
            {
                arr_2d[i][j] = int.Parse(arr_val[j]);
            }
        }
        for (int i = 0; i &lt; n; i++)
        {
            string[] arr_val = Console.ReadLine().Split();
            for (int j = 0; j &lt; m; j++)
            {
                arr_2d[i][j] += int.Parse(arr_val[j]);
                Console.Write(arr_2d[i][j] + " ");
            }
            Console.WriteLine();
        }
    }
}</code></pre>

<h4>Python</h4>
<pre class="python"><code>n, m = map(int, input().split())
arr_2d_1 = [list(map(int, input().split())) for _ in range(n)]
arr_2d_2 = [list(map(int, input().split())) for _ in range(n)]
result = [[arr_2d_1[i][j] + arr_2d_2[i][j] for j in range(m)] for i in range(n)]
for row in result:
    print(' '.join(map(str, row)))</code></pre>

<h4>Node.js</h4>
<pre class="javascript"><code>const fs = require('fs');
const input = fs.readFileSync('/dev/stdin', 'utf8').trim().split('\n');
const [n, m] = input[0].split(' ').map(Number);
const arr1 = [];
const arr2 = [];

for (let i = 1; i &lt;= n; i++){
    arr1.push(input[i].split(' ').map(Number));
}

for (let i = n + 1; i &lt;= 2 * n; i++){
    arr2.push(input[i].split(' ').map(Number));
}

var result = [];
for (let i = 0; i &lt; n; i++){
    const row = [];
    for (let j = 0; j &lt; m; j++){
        row.push(arr1[i][j] + arr2[i][j]);
    }
    result.push(row);
}

result.forEach(row =&gt; console.log(row.join(' ')));</code></pre>

<h3>2번 최댓값</h3>
<h4>문제</h4>
<p>&lt;그림&nbsp;1&gt;과&nbsp;같이&nbsp;9&times;9&nbsp;격자판에&nbsp;쓰인&nbsp;81개의&nbsp;자연수&nbsp;또는&nbsp;0이&nbsp;주어질&nbsp;때,&nbsp;이들&nbsp;중&nbsp;최댓값을&nbsp;찾고&nbsp;그&nbsp;최댓값이&nbsp;몇&nbsp;행&nbsp;몇&nbsp;열에&nbsp;위치한&nbsp;수인지&nbsp;구하는&nbsp;프로그램을&nbsp;작성하시오.&nbsp;예를&nbsp;들어,&nbsp;다음과&nbsp;같이&nbsp;81개의&nbsp;수가&nbsp;주어지면</p>
<p><figure class="imageblock alignCenter" data-ke-mobileStyle="widthOrigin" data-origin-width="354" data-origin-height="632"><span data-alt="https://www.acmicpc.net/problem/2566"><img src="/assets/images/posts/2025/04/11/166-1.png" loading="lazy" width="263" height="470" data-origin-width="354" data-origin-height="632"/></span><figcaption>https://www.acmicpc.net/problem/2566</figcaption>
</figure>
</p>

<p>이들&nbsp;중&nbsp;최댓값은&nbsp;90이고,&nbsp;이&nbsp;값은&nbsp;5행&nbsp;7열에&nbsp;위치한다.</p>

<h4>입력</h4>
<p>첫째&nbsp;줄부터&nbsp;아홉&nbsp;번째&nbsp;줄까지&nbsp;한&nbsp;줄에&nbsp;아홉&nbsp;개씩&nbsp;수가&nbsp;주어진다.&nbsp;주어지는&nbsp;수는&nbsp;100보다&nbsp;작은&nbsp;자연수&nbsp;또는&nbsp;0이다.</p>

<h4>출력</h4>
<p>첫째&nbsp;줄에&nbsp;최댓값을&nbsp;출력하고,&nbsp;둘째&nbsp;줄에&nbsp;최댓값이&nbsp;위치한&nbsp;행&nbsp;번호와&nbsp;열&nbsp;번호를&nbsp;빈칸을&nbsp;사이에&nbsp;두고&nbsp;차례로&nbsp;출력한다.&nbsp;최댓값이&nbsp;두&nbsp;개&nbsp;이상인&nbsp;경우&nbsp;그중&nbsp;한&nbsp;곳의&nbsp;위치를&nbsp;출력한다.</p>

<p>이차원 배열에 저장하고 순회하면서 가장 큰 숫자를 찾고 그 숫자와 인덱스를 출력하면 되는 문제다. 그런데 이차원 배열을 굳이 만들지 않아도 입력을 처리할 때 바로 큰 수와 인덱스를 찾을 수 있긴 하다. 처음 풀이는 의도에 맞게 풀고 그 이후는 간단한 방법을 사용해 본다.</p>

<h4>C++</h4>
<pre class="cpp"><code>#include &lt;iostream&gt;
#include &lt;vector&gt;
using namespace std;
int main(){
    int n = 9;
    vector&lt;vector&lt;int&gt;&gt; arr_2d(n, vector&lt;int&gt;(n, 0));
    for (int i = 0; i &lt; n; i++) {
        for (int j = 0; j &lt; n; j++) {
            cin &gt;&gt; arr_2d[i][j];
        }
    }
    
    
    int max_val = arr_2d[0][0];
    int max_row = 0;
    int max_col = 0;
    for (int i = 0; i &lt; n; i++) {
        for (int j = 0; j &lt; n; j++) {
            if (arr_2d[i][j] &gt; max_val) {
                max_val = arr_2d[i][j];
                max_row = i;
                max_col = j;
            }
        }
    }
    cout &lt;&lt; max_val &lt;&lt; "\n";
    cout &lt;&lt; max_row + 1 &lt;&lt; " " &lt;&lt; max_col + 1;
    
    return 0;
}</code></pre>

<h4>C#</h4>
<pre class="csharp"><code>using System;
class Program{
    static void Main(string[] args){
        int n = 9;
        int maxVal = 0;
        int row = 0;
        int col = 0;
        for (int i = 0; i &lt; n; i++){
            string[] strArr = Console.ReadLine().Split();
            for (int j = 0; j &lt; n; j++){
                int tmpVal = int.Parse(strArr[j]);
                if (tmpVal &gt; maxVal){
                    maxVal = tmpVal;
                    row = i;
                    col = j;
                }
            }
        }
        Console.WriteLine($"{maxVal}");
        Console.WriteLine($"{row + 1} {col + 1}");
    }
}</code></pre>

<h4>Python</h4>
<pre class="python"><code>max_val = 0;
col = 0;
row = 0;
for i in range(9):
    arr = list(map(int, input().split()))
    for j in range(9):
        tmp_val = arr[j]
        if max_val &lt; tmp_val:
            max_val = tmp_val
            row = i;
            col = j;
print(f"{max_val}\n{row + 1} {col + 1}")</code></pre>

<h4>Node.js</h4>
<pre class="javascript"><code>const fs = require('fs');
const input = fs.readFileSync('/dev/stdin', 'utf8').trim().split('\n');
let col = 0;
let row = 0;
let max_val = 0;
for (let i = 0; i &lt; 9; i++){
    const arr = input[i].split(' ').map(Number);
    for (let j = 0; j &lt; 9; j++){
        if (arr[j] &gt; max_val){
            max_val = arr[j];
            row = i;
            col = j;
        }
    }
}
console.log(`${max_val}\n${row + 1} ${col + 1}`);</code></pre>

<h3>3번 세로 읽기</h3>
<h4>문제</h4>
<p>아직&nbsp;글을&nbsp;모르는&nbsp;영석이가&nbsp;벽에&nbsp;걸린&nbsp;칠판에&nbsp;자석이&nbsp;붙어있는&nbsp;글자들을&nbsp;붙이는&nbsp;장난감을&nbsp;가지고&nbsp;놀고&nbsp;있다.&nbsp;이&nbsp;장난감에&nbsp;있는&nbsp;글자들은&nbsp;영어&nbsp;대문자&nbsp;&lsquo;A&rsquo;부터&nbsp;&lsquo;Z&rsquo;,&nbsp;영어&nbsp;소문자&nbsp;&lsquo;a&rsquo;부터&nbsp;&lsquo;z&rsquo;,&nbsp;숫자&nbsp;&lsquo;0&rsquo;부터&nbsp;&lsquo;9&rsquo;이다.&nbsp;영석이는&nbsp;칠판에&nbsp;글자들을&nbsp;수평으로&nbsp;일렬로&nbsp;붙여서&nbsp;단어를&nbsp;만든다.&nbsp;다시&nbsp;그&nbsp;아래쪽에&nbsp;글자들을&nbsp;붙여서&nbsp;또&nbsp;다른&nbsp;단어를&nbsp;만든다.&nbsp;이런&nbsp;식으로&nbsp;다섯&nbsp;개의&nbsp;단어를&nbsp;만든다.&nbsp;아래&nbsp;그림&nbsp;1은&nbsp;영석이가&nbsp;칠판에&nbsp;붙여&nbsp;만든&nbsp;단어들의&nbsp;예이다.</p>
<pre class="bash"><code>A A B C D D
a f z z 
0 9 1 2 1
a 8 E W g 6
P 5 h 3 k x
&lt;그림 1&gt;</code></pre>

<p>한&nbsp;줄의&nbsp;단어는&nbsp;글자들을&nbsp;빈칸&nbsp;없이&nbsp;연속으로&nbsp;나열해서&nbsp;최대&nbsp;15개의&nbsp;글자들로&nbsp;이루어진다.&nbsp;또한&nbsp;만들어진&nbsp;다섯&nbsp;개의&nbsp;단어들의&nbsp;글자&nbsp;개수는&nbsp;서로&nbsp;다를&nbsp;수&nbsp;있다.&nbsp;심심해진&nbsp;영석이는&nbsp;칠판에&nbsp;만들어진&nbsp;다섯&nbsp;개의&nbsp;단어를&nbsp;세로로&nbsp;읽으려&nbsp;한다.&nbsp;세로로&nbsp;읽을&nbsp;때,&nbsp;각&nbsp;단어의&nbsp;첫&nbsp;번째&nbsp;글자들을&nbsp;위에서&nbsp;아래로&nbsp;세로로&nbsp;읽는다.&nbsp;다음에&nbsp;두&nbsp;번째&nbsp;글자들을&nbsp;세로로&nbsp;읽는다.&nbsp;이런&nbsp;식으로&nbsp;왼쪽에서&nbsp;오른쪽으로&nbsp;한&nbsp;자리씩&nbsp;이동하면서&nbsp;동일한&nbsp;자리의&nbsp;글자들을&nbsp;세로로&nbsp;읽어&nbsp;나간다.&nbsp;위의&nbsp;그림&nbsp;1의&nbsp;다섯&nbsp;번째&nbsp;자리를&nbsp;보면&nbsp;두&nbsp;번째&nbsp;줄의&nbsp;다섯&nbsp;번째&nbsp;자리의&nbsp;글자는&nbsp;없다.&nbsp;이런&nbsp;경우처럼&nbsp;세로로&nbsp;읽을&nbsp;때&nbsp;해당&nbsp;자리의&nbsp;글자가&nbsp;없으면,&nbsp;읽지&nbsp;않고&nbsp;그다음&nbsp;글자를&nbsp;계속&nbsp;읽는다.&nbsp;그림&nbsp;1의&nbsp;다섯&nbsp;번째&nbsp;자리를&nbsp;세로로&nbsp;읽으면&nbsp;D1gk로&nbsp;읽는다.&nbsp;그림&nbsp;1에서&nbsp;영석이가&nbsp;세로로&nbsp;읽은&nbsp;순서대로&nbsp;글자들을&nbsp;공백&nbsp;없이&nbsp;출력하면&nbsp;다음과&nbsp;같다:&nbsp;Aa0aPAf985Bz1EhCz2W3D1gkD6x&nbsp;칠판에&nbsp;붙여진&nbsp;단어들이&nbsp;주어질&nbsp;때,&nbsp;영석이가&nbsp;세로로&nbsp;읽은&nbsp;순서대로&nbsp;글자들을&nbsp;출력하는&nbsp;프로그램을&nbsp;작성하시오.</p>

<h4>입력</h4>
<p>총&nbsp;다섯 줄의&nbsp;입력이&nbsp;주어진다.&nbsp;각&nbsp;줄에는&nbsp;최소&nbsp;1개,&nbsp;최대&nbsp;15개의&nbsp;글자들이&nbsp;빈칸&nbsp;없이&nbsp;연속으로&nbsp;주어진다.&nbsp;주어지는&nbsp;글자는&nbsp;영어&nbsp;대문자&nbsp;&lsquo;A&rsquo;부터&nbsp;&lsquo;Z&rsquo;,&nbsp;영어&nbsp;소문자&nbsp;&lsquo;a&rsquo;부터&nbsp;&lsquo;z&rsquo;,&nbsp;숫자&nbsp;&lsquo;0&rsquo;부터&nbsp;&lsquo;9&rsquo;&nbsp;중&nbsp;하나이다.&nbsp;각&nbsp;줄의&nbsp;시작과&nbsp;마지막에&nbsp;빈칸은&nbsp;없다.</p>

<h4>출력</h4>
<p>영석이가&nbsp;세로로&nbsp;읽은&nbsp;순서대로&nbsp;글자들을&nbsp;출력한다.&nbsp;이때,&nbsp;글자들을&nbsp;공백&nbsp;없이&nbsp;연속해서&nbsp;출력한다.</p>

<h4>C++</h4>
<pre class="cpp"><code>#include &lt;iostream&gt;
#include &lt;sstream&gt;
#include &lt;string&gt;
#include &lt;vector&gt;
using namespace std;
int main(){
    int max_col = 15;
    string line;
    vector&lt;vector&lt;char&gt;&gt; matrix;
    for (int i = 0; i &lt; 5; i++){
        getline(cin, line);
        vector&lt;char&gt; row(line.begin(), line.end());
        matrix.push_back(row);
    }
    for (int col = 0; col &lt; max_col; col++){
        for (int row = 0; row &lt; matrix.size(); row++){
            if (col &lt; matrix[row].size()){
                cout &lt;&lt; matrix[row][col];
            }
        }
    }
    return 0;
}</code></pre>

<h4>C#</h4>
<pre class="csharp"><code>using System;
using System.Collections.Generic;
using System.Linq;
class Program{
    static void Main(string[] args){
        int max_col = 15;
        string line;
        List&lt;List&lt;char&gt;&gt; matrix = new List&lt;List&lt;char&gt;&gt;();
        
        while((line = Console.ReadLine()) != null){
            matrix.Add(line.ToList());
        }

        for (int col = 0; col &lt; max_col; col++){
            for (int row = 0; row &lt; matrix.Count; row++){
                if (matrix[row].Count &gt; col){
                    Console.Write(matrix[row][col]);
                }
            }
        }
    }
}</code></pre>

<h4>Python</h4>
<pre class="python"><code>max_row = 5;
max_col = 15;
matrix = [list(input()) for _ in range(max_row)]
for col in range(max_col):
    for row in range(max_row):
        if col &lt; len(matrix[row]):
            print(matrix[row][col], end="")</code></pre>

<h4>Node.js</h4>
<pre class="javascript"><code>const fs = require('fs');
const max_row = 5;
const max_col = 15;
const input = fs.readFileSync('/dev/stdin', 'utf8').trim().split('\n');
for (let col = 0; col &lt; max_col; col++){
    for (let row = 0; row &lt; max_row; row++){
        if (col &lt; input[row].length) {
            process.stdout.write(input[row][col]);    
        }
    }
}</code></pre>

<h3>4번 색종이</h3>
<h4>문제</h4>
<p>가로,&nbsp;세로의&nbsp;크기가&nbsp;각각&nbsp;100인&nbsp;정사각형&nbsp;모양의&nbsp;흰색&nbsp;도화지가&nbsp;있다.&nbsp;이&nbsp;도화지&nbsp;위에&nbsp;가로,&nbsp;세로의&nbsp;크기가&nbsp;각각&nbsp;10인&nbsp;정사각형&nbsp;모양의&nbsp;검은색&nbsp;색종이를&nbsp;색종이의&nbsp;변과&nbsp;도화지의&nbsp;변이&nbsp;평행하도록&nbsp;붙인다.&nbsp;이러한&nbsp;방식으로&nbsp;색종이를&nbsp;한&nbsp;장&nbsp;또는&nbsp;여러&nbsp;장&nbsp;붙인&nbsp;후&nbsp;색종이가&nbsp;붙은&nbsp;검은&nbsp;영역의&nbsp;넓이를&nbsp;구하는&nbsp;프로그램을&nbsp;작성하시오.</p>
<p><figure class="imageblock alignCenter" data-ke-mobileStyle="widthOrigin" data-origin-width="536" data-origin-height="430"><span data-alt="https://www.acmicpc.net/problem/2563"><img src="/assets/images/posts/2025/04/11/166-2.png" loading="lazy" width="357" height="286" data-origin-width="536" data-origin-height="430"/></span><figcaption>https://www.acmicpc.net/problem/2563</figcaption>
</figure>
</p>

<p>예를&nbsp;들어&nbsp;흰색&nbsp;도화지&nbsp;위에&nbsp;세&nbsp;장의&nbsp;검은색&nbsp;색종이를&nbsp;그림과&nbsp;같은&nbsp;모양으로&nbsp;붙였다면&nbsp;검은색&nbsp;영역의&nbsp;넓이는&nbsp;260이&nbsp;된다.</p>

<h4>입력</h4>
<p>첫째 줄에 색종이의 수가 주어진다. 이어 둘째 줄부터 한 줄에 하나씩 색종이를 붙인 위치가 주어진다. 색종이를 붙인 위치는 두 개의 자연수로 주어지는데 첫 번째 자연수는 색종이의 왼쪽 변과 도화지의 왼쪽 변 사이의 거리이고, 두 번째 자연수는 색종이의 아래쪽 변과 도화지의 아래쪽 변 사이의 거리이다. 색종이의 수는 100 이하이며, 색종이가 도화지 밖으로 나가는 경우는 없다.</p>

<h4>출력</h4>
<p>첫째&nbsp;줄에&nbsp;색종이가&nbsp;붙은&nbsp;검은&nbsp;영역의&nbsp;넓이를&nbsp;출력한다.</p>

<p>2차원 배열 카테고리의 마지막 문제라서 그런가 단순 값 처리가 아닌 응용이 필요한 문제이다.</p>
<p>100 x 100 크기의 도화지란 배열의 최대 크기를 정한 것으로 [100][100] 크기의 2차원 배열 안에서 이루어지는 작업이다.</p>
<p>색종이는 모두 동일한 크기로 최대 100개까지 붙인다. 색종이 크기는 모두 일정한 10 x 10이며 왼쪽 하단의 꼭짓점에 대한 좌표가 주어진다.</p>

<p>당장은 두 가지 방법이 떠오른다.</p>
<p>1. 도화지에서 색종이가 없는 영역 구하기</p>
<p>2. 전체 색종이 개수의 영역에서 겹치는 부분 제외하기</p>

<p>2차원 배열의 구조를 기준으로 생각해 본다.</p>
<p>100 x 100 크기에서 입력된 색종이 범위만큼 인덱스를 체크해 놓고 최종적으로 체크한 부분만 계산하면 색종이가 덮은 영역이 나온다.<br></p>
<h4>C++</h4>
<pre class="cpp"><code>#include &lt;iostream&gt;
#include &lt;vector&gt;
using namespace std;
int main(){
    int count = 0;
    int matrix[100][100] = {0};
    cin &gt;&gt; count;
    for (int i = 0; i &lt; count; i++){
        int x1, y1, x2, y2 = 0;
        cin &gt;&gt; x1;
        cin &gt;&gt; y1;
        x2 = x1 + 10;
        y2 = y1 + 10;
        for (int x = x1; x &lt; x2; x++){
            for (int y = y1; y &lt; y2; y++){
                matrix[x][y] = -1;
            }
        }
    }
    
    int area = 0;
    for (int row = 0; row &lt; 100; row++){
        for (int col = 0; col &lt; 100; col++){
            if (matrix[row][col] == -1){
                area++;
            }
        }
    }
    cout &lt;&lt; area;
    return 0;
}</code></pre>


<p>중복으로 겹쳐진 부분을 체크하는 부분을 조건을 주고 확인하는 걸 추가해도 될 것 같다.</p>

<h4>C#</h4>
<p>C++로 코드를 쓰면서 방식에 문제가 없으니 좀 더 정리해서 작성해 본다.</p>
<pre class="csharp"><code>using System;
class Program{
    static void Main(string[] args){
        int[,] matrix = new int[100, 100];
        int count = int.Parse(Console.ReadLine()!);
        
        for (int i = 0; i &lt; count; i++){
            string? input = Console.ReadLine();
            if (string.IsNullOrEmpty(input)) return;
            string[] xy = input.Split();
            int x = int.Parse(xy[0]);
            int y = int.Parse(xy[1]);
            
            for (int dx = x; dx &lt; x + 10; dx++){
                for (int dy = y; dy &lt; y + 10; dy++){
                    matrix[dx, dy] = -1;
                }
            }
        }
        
        int area = 0;
        for (int row = 0; row &lt; 100; row++){
            for (int col = 0; col &lt; 100; col++){
                if (matrix[row, col] == -1){
                    area++;
                }
            }
        }
        Console.WriteLine(area);
    }
}</code></pre>

<h4>Python</h4>
<pre class="python"><code>count = int(input());
matrix = [[0] * 100 for _ in range(100)]
for _ in range(count):
    x, y = map(int, input().split())
    for dx in range(x, x + 10):
        for dy in range(y, y + 10):
            matrix[dx][dy] = 1
area = sum(row.count(1) for row in matrix)
print(area)</code></pre>

<h4>Node.js</h4>
<pre class="javascript"><code>const fs = require('fs');
const input = fs.readFileSync('/dev/stdin', 'utf8').trim().split('\n');
const count = parseInt(input[0]);
let matrix = Array.from({length : 100 }, () =&gt; Array(100).fill(0));
for (let i = 1; i &lt;= count; i++){
    const xy = input[i].split(" ").map(Number);
    const x = xy[0];
    const y = xy[1];
    for (let dx = x; dx &lt; x + 10; dx++){
        for (let dy = y; dy &lt; y + 10; dy++){
            matrix[dx][dy] = 1;
        }
    }
}
let area = 0;
for (let row = 0; row &lt; 100; row++){
    for (let col = 0; col &lt; 100; col++){
        if (matrix[row][col] == 1){
            area++;
        }
    }
}
console.log(area);</code></pre>
