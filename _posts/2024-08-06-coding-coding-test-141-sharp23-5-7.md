---
title: "백준 코딩테스트 #23. 문자열 (5 ~ 7)"
excerpt: "백준 코딩테스트 #23. 문자열 (5 ~ 7)"
categories:
  - CodingTest
permalink: /coding/coding-test/141-sharp23-5-7/
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
date: 2024-08-06
last_modified_at: 2024-08-06
source_url: https://b-note.tistory.com/141
---

<h2>5번 숫자의 합</h2>
<p><b>문제</b></p>
<p>N개의&nbsp;숫자가&nbsp;공백&nbsp;없이&nbsp;쓰여있다.&nbsp;이&nbsp;숫자를&nbsp;모두&nbsp;합해서&nbsp;출력하는&nbsp;프로그램을&nbsp;작성하시오.</p>

<p><b>입력</b></p>
<p>첫째&nbsp;줄에&nbsp;숫자의&nbsp;개수&nbsp;N&nbsp;(1&nbsp;&le;&nbsp;N&nbsp;&le;&nbsp;100)이&nbsp;주어진다.&nbsp;둘째&nbsp;줄에&nbsp;숫자&nbsp;N개가&nbsp;공백 없이&nbsp;주어진다.</p>

<p><b>출력</b></p>
<p>입력으로&nbsp;주어진&nbsp;숫자&nbsp;N개의&nbsp;합을&nbsp;출력한다.</p>

<p>숫자의 입력을 받고 합산을 하는 문제이다. 문자열 챕터인 이유는 공백 없이 주어지는 숫자를 문자열로 받아서 인덱스로 접근하여 숫자를 하나씩 처리하는 걸 의도한 거 같다.</p>

<h3>C++</h3>
<p>문제를 풀기 전 문자에 대한 내용을 정리한다.</p>
<p>문자를 저장하는 char 타입은 실제로 저장되는 정보는 아스키코드로 정수형이다. 이 정보가 IDE나 콘솔의 출력 메커니즘에 의해서 우리가 볼 수 있는 문자형태로 치환되어 보이게 된다.</p>

<p>따라서 정수 데이터를 char에 저장하면 문자로, 문자 데이터를 int에 저장하면 정수형으로 서로 암시적으로 형변환이 발생하여 값이 저장된다.</p>

<p>대부분의 언어에서 char 타입에 대한 개념은 유사하지만 문자 인코딩과 처리 방식이 다를 수 있다.</p>

<pre class="cpp"><code>char c = '1' - 0 - 1; 
// '1' - 0 여기서 정수 연산을 시도함에 따라서 정수 타입으로 변환된다.
// '1' 의 아스키코드인 49, 0을 뺀 값은 49이다.
// 따라서 숫자 문자에 - 0을 하면 해당문자의 아스키코드값이 반환되는 것이다.
// 49 - 1 = 48, 이 정수를 다시 char 타입에 저장하면 
// 해당 정수값은 아스키코드로 변환되어 '0'이 된다.
cout &lt;&lt; c; // '0' 출력

int i = '1' - '0';
// 이 경우 연산을 시도하면서 '1'과 '0'은 각각 대응하는 아스키코드 값으로 변환되고
// 49 - 48 = 1, 따라서 i 에는 1의 값이 저장되면서 
// 숫자 문자에 - '0'을 연산하게되면 해당 숫자문자를 정수로 얻을 수 있게된다.
cout &lt;&lt; i; // 1 출력

// 정수형을 바로 저장할 수 있다.
char c = 126;
cout &lt;&lt; c; // '~' 출력</code></pre>

<p>만약 char 타입에 정수를 저장하는데 해당 정수에 대응하는 아스키코드의 값이 없다면 시스템에 따라서 다를 수 있지만 잘못된 문자 또는 빈 문자가 표시되거나 컴파일 에러가 발생할 수 있다.</p>

<p>string도 내부 구조는 char의 배열이기 때문에 char와 동일하게 연산을 사용할 수 있다.</p>

<pre class="cpp"><code>#include &lt;iostream&gt;
#include &lt;string&gt;
using namespace std;
int main(){
    int n;
    int sum = 0;
    string nums;
    cin &gt;&gt; n &gt;&gt; nums;
    for (int i = 0; i &lt; n; i++){
        int num = nums[i] - '0';
        sum += num;
    }
    cout &lt;&lt; sum;
    return 0;
}</code></pre>

<h3>C#</h3>
<pre class="csharp"><code>using System;
class Program{
    static void Main(string[] args){
        int sum = 0;
        int n = int.Parse(Console.ReadLine());
        string nums = Console.ReadLine();
        for (int i = 0; i &lt; n; i++){
            int num = nums[i] - '0';
            sum += num;
        }
        Console.WriteLine(sum);
    }
}</code></pre>

<h3>Python</h3>
<pre class="python"><code>n = int(input())
nums = input()
result = 0
for i in range(n):
    num = int(nums[i])
    result += num;
print(f"{result}");</code></pre>

<p>파이썬에서는 - '0'&nbsp; 방법은 사용할 수 없고 대신 문자를 int()를 사용해서 변환하면 해당 문자를 그대로 숫자로 변환한다.</p>

<p>아스키코드로 변환하는 함수 ord()가 별도로 존재하는 이유와 연관이 있는듯하다.</p>

<h3>Node.js</h3>
<pre class="javascript"><code>const fs = require('fs');
const input = fs.readFileSync('/dev/stdin','utf8').trim().split('\n');
const n = parseInt(input[0], 10);
const nums = input[1];
let sum = 0;
for (let i = 0; i &lt; n; i++){
    const num = nums[i] - '0';
    // const num = parseInt(num[i]);
    sum += num;
}
console.log(sum);</code></pre>

<p>js에서는 - '0'을 사용해서 문자를 정수로 변환할 수 있고 parseInt로 타입을 변환해도 정수로 변환된 값을 얻을 수 있다.</p>

<p>js도 별도의 아스키코드를 얻는 함수 charCodeAt()가 있기 때문에 타입 변환 시 숫자 문자 그대로의 정수로 변환되는듯하다.</p>

<h2>6번 알파벳 찾기</h2>
<p><b>문제</b></p>
<p>알파벳&nbsp;소문자로만&nbsp;이루어진&nbsp;단어&nbsp;S가&nbsp;주어진다.&nbsp;각각의&nbsp;알파벳에&nbsp;대해서,&nbsp;단어에&nbsp;포함되어&nbsp;있는&nbsp;경우에는&nbsp;처음&nbsp;등장하는&nbsp;위치를,&nbsp;포함되어&nbsp;있지&nbsp;않은&nbsp;경우에는&nbsp;-1을&nbsp;출력하는&nbsp;프로그램을&nbsp;작성하시오.</p>

<p><b>입력</b></p>
<p>첫째&nbsp;줄에&nbsp;단어&nbsp;S가&nbsp;주어진다.&nbsp;단어의&nbsp;길이는&nbsp;100을&nbsp;넘지&nbsp;않으며,&nbsp;알파벳&nbsp;소문자로만&nbsp;이루어져&nbsp;있다.</p>

<p><b>출력</b></p>
<p>각각의&nbsp;알파벳에&nbsp;대해서,&nbsp;a가&nbsp;처음&nbsp;등장하는&nbsp;위치,&nbsp;b가&nbsp;처음&nbsp;등장하는&nbsp;위치,...&nbsp;z가&nbsp;처음&nbsp;등장하는&nbsp;위치를&nbsp;공백으로&nbsp;구분해서&nbsp;출력한다.&nbsp;</p>

<p>만약,&nbsp;어떤&nbsp;알파벳이&nbsp;단어에&nbsp;포함되어&nbsp;있지&nbsp;않다면&nbsp;-1을&nbsp;출력한다.&nbsp;단어의&nbsp;첫&nbsp;번째&nbsp;글자는&nbsp;0번째&nbsp;위치이고,&nbsp;두&nbsp;번째&nbsp;글자는&nbsp;1번째&nbsp;위치이다.</p>

<p>단어에서 알파벳이 등장하는 위치를 저장해야 하는데 알파벳의 총개수는 26개이므로 26 사이즈의 배열을 만들어서 각 인덱스마다 알파벳을 대응시킨다. 그리고 입력받은 문자열을 검사해서 처음 등장하는 위치를 배열에 저장해 두고 출력한다.</p>

<p>알파벳을 인덱스를 특정하는 것이 문제인데 입력되는 단어가 소문자로만 이루어졌기 때문에 아스키코드를 활용해서 특정할 수 있을 것 같다. 'a' ~ 'z'는 아스키코드의 97 ~ 122까지이다.</p>

<p>따라서 문자에서 - 97을 하면 a 정보를 0 인덱스에 저장할 수 있다.</p>

<h3>C++</h3>
<pre class="cpp"><code>#include &lt;iostream&gt;
#include &lt;string&gt;
#include &lt;algorithm&gt;
using namespace std;
int main(){
    string s;
    int arr[26];
    fill(arr, arr+26, -1);
    cin &gt;&gt; s;
    int len = s.length();
    for (int i = 0; i &lt; len; i++){
        int n = s[i] - 97;
        if (arr[n] == -1){
            arr[n] = i;
        }
        else{
            continue;
        }
    }
    for (int i : arr){
        cout &lt;&lt; i &lt;&lt; " ";
    }
    return 0;
}</code></pre>

<p>알파벳의 배열인 arr을 26 사이즈로 선언하고 -1로 초기화해 둔다.</p>

<p>그리고 입력된 문자열 s의 문자를 순회하면서 배열에 상태를 검사해서 이미 등장한 경우에는 넘어가고 첫 등장인 경우만 저장한다.</p>

<h3>C#</h3>
<pre class="csharp"><code>using System;
using System.Linq;
class Program{
    static void Main(string[] args){
        int[] arr = Enumerable.Repeat(-1, 26).ToArray();
        string s = Console.ReadLine();
        for (int i = 0; i &lt; s.Length; i++){
            int n = s[i] - 'a';
            if (arr[n] == -1)
                arr[n] = i;
            else
                continue;
        }
        Console.WriteLine("{0}", string.Join(" ", arr));
    }
}</code></pre>

<p>- 97은 - 'a'와 동일하다.</p>

<h3>Python</h3>
<pre class="python"><code>s = input()
arr = [-1] * 26;
for i in range(len(s)):
    n = ord(s[i]) - 97
    if arr[n] == -1:
        arr[n] = i
print(" ".join(map(str, arr)))</code></pre>

<p>배열의 접근하는 방식에 따라 아스키코드로 변환해서 인덱스를 찾는다.</p>

<h3>Node.js</h3>
<pre class="javascript"><code>const fs = require('fs');
const input = fs.readFileSync('/dev/stdin','utf8').trim();
const arr = Array(26).fill(-1);
for (let i = 0; i &lt; input.length; i++){
    const c = input[i].charCodeAt(0) - 97; // - 'a'.charCodeAt(0) 가능
    if (arr[c] === -1)
        arr[c] = i;
}
console.log(arr.join(' '));</code></pre>

<p>js에서는 - 'a'를 사용할 경우 charCodeAt(0)으로 아스키코드 값으로 변환하고 사용하면 같은 결과를 얻을 수 있다.</p>

<h2>7번 문자열 반복</h2>
<p><b>문제</b></p>
<p>문자열&nbsp;S를&nbsp;입력받은&nbsp;후에,&nbsp;각&nbsp;문자를&nbsp;R번&nbsp;반복해&nbsp;새&nbsp;문자열&nbsp;P를&nbsp;만든&nbsp;후&nbsp;출력하는&nbsp;프로그램을&nbsp;작성하시오.&nbsp;즉,&nbsp;첫&nbsp;번째&nbsp;문자를&nbsp;R번&nbsp;반복하고,&nbsp;두&nbsp;번째&nbsp;문자를&nbsp;R번&nbsp;반복하는&nbsp;식으로&nbsp;P를&nbsp;만들면&nbsp;된다.&nbsp;S에는&nbsp;QR&nbsp;Code&nbsp;"alphanumeric"&nbsp;문자만&nbsp;들어있다.&nbsp;</p>

<p>QR&nbsp;Code&nbsp;"alphanumeric"&nbsp;문자는&nbsp;0123456789 ABCDEFGHIJKLMNOPQRSTUVWXYZ\$%*+-./:이다.</p>

<p><b>입력</b></p>
<p>첫째&nbsp;줄에&nbsp;테스트&nbsp;케이스의&nbsp;개수&nbsp;T(1&nbsp;&le;&nbsp;T&nbsp;&le;&nbsp;1,000)가&nbsp;주어진다.&nbsp;각&nbsp;테스트&nbsp;케이스는&nbsp;반복&nbsp;횟수&nbsp;R(1&nbsp;&le;&nbsp;R&nbsp;&le;&nbsp;8),&nbsp;문자열&nbsp;S가&nbsp;공백으로&nbsp;구분되어&nbsp;주어진다.&nbsp;S의&nbsp;길이는&nbsp;적어도&nbsp;1이며,&nbsp;20글자를&nbsp;넘지&nbsp;않는다.</p>

<p><b>출력</b></p>
<p>각&nbsp;테스트&nbsp;케이스에&nbsp;대해&nbsp;P를&nbsp;출력한다.</p>

<h3>C++</h3>
<pre class="cpp"><code>#include &lt;iostream&gt;
#include &lt;string&gt;
using namespace std;
int main(){
    int t;
    cin &gt;&gt; t;
    for (int i = 0; i &lt; t; i++){
        int r;
        string s;
        cin &gt;&gt; r &gt;&gt; s;
        string result;
        for (int j = 0; j &lt; s.length(); j++){
            for (int k = 0; k &lt; r; k++){
                result += s[j];
            }
        }
        cout &lt;&lt; result &lt;&lt; "\n";
    }
    return 0;
}</code></pre>

<p>문자마다 여러 번 작성하기 위해서 반복문이 여러 번 중첩되는데 이런 경우에는 append() 함수를 사용하면 더 간략하게 표현할 수 있다.</p>

<pre class="cpp"><code>#include &lt;iostream&gt;
#include &lt;string&gt;
using namespace std;
int main(){
    int t;
    cin &gt;&gt; t;
    for (int i = 0; i &lt; t; i++){
        int r;
        string s;
        cin &gt;&gt; r &gt;&gt; s;
        string result;
        for (char c : s){
            result.append(r, c);
        }
        cout &lt;&lt; result &lt;&lt; "\n";
    }
    return 0;
}</code></pre>


<p>append를 사용해서 result 문자열에 r만큼 c 문자를 이어 붙인다. 이렇게 한 번의 반복문을 줄여서 표현할 수 있다.</p>

<h3>C#</h3>
<pre class="csharp"><code>using System;
using System.Text;
class Program{
    static void Main(string[] args){
        int t = int.Parse(Console.ReadLine());
        for (int i = 0; i &lt; t; i++){
            string[] input = Console.ReadLine().Split();
            int r = int.Parse(input[0]);
            string s = input[1];
            StringBuilder sb = new StringBuilder();
            foreach(char c in s){
                sb.Append(c, r);
            }
            Console.WriteLine(sb.ToString());
        }
    }
}</code></pre>

<p>Append를 사용하기 위해서 StringBuilder를 사용한다.</p>

<h3>Python</h3>
<pre class="python"><code>t = int(input())
for _ in range(t):
    data = input().split()
    r = int(data[0])
    s = data[1]
    result = ''.join(c * r for c in s)
    print(result)</code></pre>

<p>result를 생성하는 방법으로 join을 활용해서 표현이 가능하다.</p>
<p>c를 r만큼 문자열에 추가하는데 for c in s를 통해서 <span style="color: #333333; text-align: start;">s 문자열 안의 c 문자는 순차적으로 다음 문자를 가리킨다.</span></p>

<h3><span style="color: #333333; text-align: start;">Node.js</span></h3>
<pre class="javascript"><code>const fs = require('fs');
const input = fs.readFileSync('/dev/stdin', 'utf8').trim().split('\n');
const t = parseInt(input[0]);
for (let i = 1; i &lt;= t; i++) {
    const [r, s] = input[i].split(' ');
    const repeatCount = parseInt(r, 10);
    let result = '';
    for (const c of s) {
        result += c.repeat(repeatCount);
    }
    console.log(result);
}</code></pre>

<p>char.repeat(count)를 사용해서 문자를 반복해서 작성할 수 있다.</p>
