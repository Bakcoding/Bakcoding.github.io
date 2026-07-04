---
title: "백준 코딩테스트 #26. 심화 ( 1 ~ 5 )"
excerpt: "백준 코딩테스트 #26. 심화 ( 1 ~ 5 )"
categories:
  - CodingTest
permalink: /coding/coding-test/144-sharp26-1-5/
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
date: 2024-08-15
last_modified_at: 2024-08-15
source_url: https://b-note.tistory.com/144
---

<h2>1번 새싹</h2>
<p><b>문제</b></p>
<p>아래&nbsp;예제와&nbsp;같이&nbsp;새싹을&nbsp;출력하시오.</p>

<p><b>입력</b></p>
<p>입력은&nbsp;없다.</p>

<p><b>출력</b></p>
<p>새싹을&nbsp;출력한다.</p>

<pre class="bash"><code>         ,r'"7
r`-_   ,'  ,/
 \. ". L_r'
   `~\/
      |
      |</code></pre>

<p>예제 출력의 모양대로 출력을 한다.</p>

<h3>C++</h3>
<pre class="cpp"><code>#include &lt;iostream&gt;
using namespace std;
int main(){
    cout &lt;&lt; "         ,r\'\"7" &lt;&lt; "\n";
    cout &lt;&lt; "r`-_   ,\'  ,/" &lt;&lt; "\n";
    cout &lt;&lt; " \\. \". L_r\'" &lt;&lt; "\n";
    cout &lt;&lt; "   `~\\/" &lt;&lt; "\n";
    cout &lt;&lt; "      |" &lt;&lt; "\n";
    cout &lt;&lt; "      |" &lt;&lt; "\n";
    return 0;
}</code></pre>
<h2>&nbsp;</h2>
<h3>&nbsp;</h3>
<h3>C#</h3>
<pre class="csharp"><code>using System;
class Program{
    static void Main(string[] args){
        Console.WriteLine("         ,r\'\"7");
        Console.WriteLine("r`-_   ,\'  ,/");
        Console.WriteLine(" \\. \". L_r\'");
        Console.WriteLine("   `~\\/");
        Console.WriteLine("      |");
        Console.WriteLine("      |");
    }
}</code></pre>

<h3>Python</h3>
<pre class="python"><code>print("         ,r\'\"7")
print("r`-_   ,\'  ,/")
print(" \\. \". L_r\'")
print("   `~\\/")
print("      |")
print("      |")</code></pre>

<h3>Node.js</h3>
<pre class="javascript"><code>console.log("         ,r\'\"7");
console.log("r`-_   ,\'  ,/");
console.log(" \\. \". L_r\'");
console.log("   `~\\/");
console.log("      |");
console.log("      |");</code></pre>

<h2>2번 킹, 퀸, 룩, 비숍, 나이트, 폰</h2>
<p><b>문제</b></p>
<p>동혁이는&nbsp;오래된&nbsp;창고를&nbsp;뒤지다가&nbsp;낡은&nbsp;체스판과&nbsp;피스를&nbsp;발견했다.&nbsp;</p>

<p>체스판의&nbsp;먼지를&nbsp;털어내고&nbsp;걸레로&nbsp;닦으니&nbsp;그럭저럭&nbsp;쓸만한&nbsp;체스판이&nbsp;되었다.&nbsp;하지만,&nbsp;검은색&nbsp;피스는&nbsp;모두&nbsp;있었으나,&nbsp;흰색&nbsp;피스는&nbsp;개수가&nbsp;올바르지&nbsp;않았다.&nbsp;</p>

<p>체스는&nbsp;총&nbsp;16개의&nbsp;피스를&nbsp;사용하며,&nbsp;킹&nbsp;1개,&nbsp;퀸&nbsp;1개,&nbsp;룩&nbsp;2개,&nbsp;비숍&nbsp;2개,&nbsp;나이트&nbsp;2개,&nbsp;폰&nbsp;8개로&nbsp;구성되어&nbsp;있다.&nbsp;</p>

<p>동혁이가&nbsp;발견한&nbsp;흰색&nbsp;피스의&nbsp;개수가&nbsp;주어졌을&nbsp;때,&nbsp;몇&nbsp;개를&nbsp;더하거나&nbsp;빼야&nbsp;올바른&nbsp;세트가&nbsp;되는지&nbsp;구하는&nbsp;프로그램을&nbsp;작성하시오.</p>

<p><b>입력</b></p>
<p>첫째&nbsp;줄에&nbsp;동혁이가&nbsp;찾은&nbsp;흰색&nbsp;킹,&nbsp;퀸,&nbsp;룩,&nbsp;비숍,&nbsp;나이트,&nbsp;폰의&nbsp;개수가&nbsp;주어진다.&nbsp;이&nbsp;값은&nbsp;0보다&nbsp;크거나&nbsp;같고&nbsp;10보다&nbsp;작거나&nbsp;같은&nbsp;정수이다.</p>

<p><b>출력</b></p>
<p>첫째&nbsp;줄에&nbsp;입력에서&nbsp;주어진&nbsp;순서대로&nbsp;몇&nbsp;개의&nbsp;피스를&nbsp;더하거나&nbsp;빼야&nbsp;되는지를&nbsp;출력한다.&nbsp;만약&nbsp;수가&nbsp;양수라면&nbsp;동혁이는&nbsp;그&nbsp;개수만큼&nbsp;피스를&nbsp;더해야&nbsp;하는&nbsp;것이고,&nbsp;음수라면&nbsp;제거해야&nbsp;하는&nbsp;것이다.</p>

<p>입력된 체스말의 개수가 한 세트가 될 수 있도록 개수를 맞춘다.</p>

<h3>C++</h3>
<pre class="cpp"><code>#include &lt;iostream&gt;
using namespace std;
int main(){
    int chess_set[] = {1, 1, 2, 2, 2, 8 };
    int need_val[6];
    int count;
    for (int i = 0; i &lt; 6; i++){
        cin &gt;&gt; count;
        need_val[i] = chess_set[i] - count;
    }
    for (int i : need_val){
        cout &lt;&lt; i &lt;&lt; " ";
    }
    return 0;
}</code></pre>

<h3>C#</h3>
<pre class="csharp"><code>using System;
class Program{
    static void Main(string[] args){
        int[] chess_set = { 1, 1, 2, 2, 2, 8 };
        string[] input_arr = Console.ReadLine().Split();
        for (int i = 0; i &lt; 6; i++){
            int val = int.Parse(input_arr[i]);
            int need_val = chess_set[i] - val;
            Console.Write($"{need_val} ");
        }
    }
}</code></pre>

<h3>Python</h3>
<pre class="python"><code>chess_set = [1, 1, 2, 2, 2, 8]
input_set = list(map(int, input().split()))
for i in range(6):
    val = chess_set[i] - input_set[i]
    print(f'{val} ', end='')</code></pre>

<h3>Node.js</h3>
<pre class="javascript"><code>const fs = require('fs');
const input_set = fs.readFileSync('/dev/stdin','utf8').split(' ').map(Number);
const chess_set = [1, 1, 2, 2, 2, 8]
for (let i = 0; i &lt; 6; i++){
    const val = chess_set[i] - input_set[i];
    process.stdout.write(`${val} `);
}</code></pre>

<h2>3번 별 찍기 - 7</h2>
<p><b>문제</b></p>
<p>예제를&nbsp;보고&nbsp;규칙을&nbsp;유추한&nbsp;뒤에&nbsp;별을&nbsp;찍어&nbsp;보세요.</p>

<p><b>입력</b></p>
<p>첫째&nbsp;줄에&nbsp;N(1&nbsp;&le;&nbsp;N&nbsp;&le;&nbsp;100)이&nbsp;주어진다.</p>

<p><b>출력</b></p>
<p>첫째&nbsp;줄부터&nbsp;2 &times;N-1번째&nbsp;줄까지&nbsp;차례대로&nbsp;별을&nbsp;출력한다.</p>

<pre class="bash"><code>    *
   ***
  *****
 *******
*********
 *******
  *****
   ***
    *</code></pre>

<p>입력된 숫자와 규칙을 적용해서 별을 찍는 문제이다. 입력된 N을 사용해서 2N -1줄에 별을 찍는다.</p>

<p>각 줄에는 시행 횟수 i의 2i - 1 개의 별을 찍고 i가 N보다 클 때부터 2i - N 개의 별을 찍는다.</p>

<p>공백도 필요한데 공백은 N - i, i가 N보다 커지면 i - N 이 된다.</p>

<h3>C++</h3>
<pre class="cpp"><code>#include &lt;iostream&gt;
#include &lt;string&gt;
using namespace std;
int main(){
    cin.tie(NULL);
    ios_base::sync_with_stdio(false);
    int n;
    cin &gt;&gt; n;
    for (int i = 1; i &lt;= 2 * n - 1; i++){
        int space_count = n - i;
        int star_count = 2 * i - 1;
        if (i &gt; n){
            space_count = i - n;
            star_count = 2 * (2 * n - i) - 1;
        }
        string space(space_count, ' ');
        string star(star_count, '*');
        cout &lt;&lt; space &lt;&lt; star &lt;&lt; "\n";
    }
    return 0;
}</code></pre>
<h3>&nbsp;</h3>
<h3>C#</h3>
<pre class="csharp"><code>using System;
class Program{
    static void Main(string[] args){
        int n = int.Parse(Console.ReadLine());
        int line = 2 * n;
        for (int i = 1; i &lt; line; i++){
            int space_cnt = n - i;
            int star_cnt = 2 * i - 1;
            if (i &gt; n){
                space_cnt = i - n;
                star_cnt = 2 * (line - i) - 1;
            }
            string space = new string(' ', space_cnt);
            string star = new string('*', star_cnt);
            Console.WriteLine($"{space}{star}");
        }
    }
}</code></pre>

<h3>Python</h3>
<pre class="python"><code>n = int(input())
line = 2 * n
for i in range(1, line):
    if i &gt; n:
        space_cnt = i - n
        star_cnt = 2 * (line - i) - 1
    else:
        space_cnt = n - i
        star_cnt = 2 * i - 1
    space = ' ' * space_cnt
    star = '*' * star_cnt
    print(f"{space}{star}")</code></pre>
<h3>&nbsp;</h3>
<h3>Node.js</h3>
<pre class="javascript"><code>const fs = require('fs');
const n = parseInt(fs.readFileSync('/dev/stdin','utf8'));
const line = 2 * n;
for (let i = 1; i &lt; line; i++){
    let space_cnt;
    let star_cnt;
    if (i &gt; n){
        space_cnt = i - n;
        star_cnt = 2 * (line - i) - 1;
    }
    else{
        space_cnt = n - i;
        star_cnt = 2 * i - 1;
    }
    const space = ' '.repeat(space_cnt);
    const star = '*'.repeat(star_cnt);
    console.log(`${space}${star}`);
}</code></pre>

<h2>4번 팰린드롬인지 확인하기</h2>
<p><b>문제</b></p>
<p>알파벳&nbsp;소문자로만&nbsp;이루어진&nbsp;단어가&nbsp;주어진다.&nbsp;이때,&nbsp;이&nbsp;단어가&nbsp;팰린드롬인지&nbsp;아닌지&nbsp;확인하는&nbsp;프로그램을&nbsp;작성하시오.&nbsp;</p>

<p>팰린드롬이란&nbsp;앞으로&nbsp;읽을&nbsp;때와&nbsp;거꾸로&nbsp;읽을&nbsp;때&nbsp;똑같은&nbsp;단어를&nbsp;말한다.&nbsp;</p>

<p>level,&nbsp;noon은&nbsp;팰린드롬이고,&nbsp;baekjoon,&nbsp;online,&nbsp;judge는&nbsp;팰린드롬이&nbsp;아니다.</p>

<p><b>입력</b></p>
<p>첫째&nbsp;줄에&nbsp;단어가&nbsp;주어진다.&nbsp;단어의&nbsp;길이는&nbsp;1보다&nbsp;크거나&nbsp;같고,&nbsp;100보다&nbsp;작거나&nbsp;같으며,&nbsp;알파벳&nbsp;소문자로만&nbsp;이루어져&nbsp;있다.</p>

<p><b>출력</b></p>
<p>첫째&nbsp;줄에&nbsp;팰린드롬이면&nbsp;1,&nbsp;아니면&nbsp;0을&nbsp;출력한다.</p>

<p>팰린드롬이란 기러기, 역삼역, 스위스 같은 건가 보다.&nbsp;</p>

<p>입력된 문자열을 뒤집었을 때와 비교해서 동일하면 1, 아니면 0을 출력한다.</p>

<h3>C++</h3>
<pre class="cpp"><code>#include &lt;iostream&gt;
#include &lt;string&gt;
#include &lt;algorithm&gt;
using namespace std;
int main(){
    string str;
    cin &gt;&gt; str;
    string rev_str = str;
    reverse(str.begin(), str.end());
    int result = 0;
    if (str == rev_str)
        result = 1;
    else
        result = 0;
    cout &lt;&lt; result;
    return 0;
}</code></pre>

<p>reverse는 값을 반환하지 않기 때문에 rev_str에 str을 할당 후에 이 문자열을 뒤집어 준다.</p>

<h3>C#</h3>
<pre class="csharp"><code>using System;
class Program{
    static void Main(string[] args){
        string str = Console.ReadLine();
        char[] rev_str_arr = str.ToCharArray();
        Array.Reverse(rev_str_arr);
        string rev_str = new string(rev_str_arr);
        int result = 0;
        if (str == rev_str)
            result = 1;
        else
            result = 0;
        Console.Write(result);
    }
}</code></pre>

<h3>Python</h3>
<pre class="python"><code>input_str = input()
rev_str = input_str[::-1]
result = 0
if input_str == rev_str:
    result = 1
else:
    result = 0
print(result)</code></pre>

<h3>Node.js</h3>
<pre class="javascript"><code>const fs = require('fs');
const input = fs.readFileSync('/dev/stdin','utf8').trim();
const rev_input = input.split('').reverse().join('');
let result = 0;
if (input === rev_input)
    result = 1;
else
    result = 0;
console.log(result);</code></pre>

<h2>5번 단어 공부</h2>
<p><b>문제</b></p>
<p>알파벳&nbsp;대소문자로&nbsp;된&nbsp;단어가&nbsp;주어지면,&nbsp;이&nbsp;단어에서&nbsp;가장&nbsp;많이&nbsp;사용된&nbsp;알파벳이&nbsp;무엇인지&nbsp;알아내는&nbsp;프로그램을&nbsp;작성하시오.&nbsp;단,&nbsp;대문자와&nbsp;소문자를&nbsp;구분하지&nbsp;않는다.</p>

<p><b>입력</b></p>
<p>첫째&nbsp;줄에&nbsp;알파벳&nbsp;대소문자로&nbsp;이루어진&nbsp;단어가&nbsp;주어진다.&nbsp;주어지는&nbsp;단어의&nbsp;길이는&nbsp;1,000,000을&nbsp;넘지&nbsp;않는다.</p>

<p><b>출력</b></p>
<p>첫째&nbsp;줄에&nbsp;이&nbsp;단어에서&nbsp;가장&nbsp;많이&nbsp;사용된&nbsp;알파벳을&nbsp;대문자로&nbsp;출력한다.&nbsp;단,&nbsp;가장&nbsp;많이&nbsp;사용된&nbsp;알파벳이&nbsp;여러&nbsp;개&nbsp;존재하는&nbsp;경우에는&nbsp;?를&nbsp;출력한다.</p>

<p>알파벳 개수만큼 배열을 선언하고 해당 알파벳이 나올 때 인덱스에 값을 증가시키면 될 듯하다.</p>

<h3>C++</h3>
<pre class="cpp"><code>#include &lt;iostream&gt;
#include &lt;string&gt;
#include &lt;algorithm&gt;
#include &lt;cctype&gt;
using namespace std;
int main(){
    int str_count[26] = {0};
    string str;
    cin &gt;&gt; str;
    transform(str.begin(), str.end(), str.begin(), ::toupper);
    for (char c : str){
        int idx = c - 'A';
        str_count[idx]++;
    }
    int* max_iter = max_element(str_count, str_count + 26);
    int max_index = distance(str_count, max_iter);
    int max_count = *max_iter;
    char max_char = max_index + 'A';
    int duplicate_count = 0;
    for (int i : str_count){
        if (i == max_count){
            duplicate_count++;
            if (duplicate_count &gt; 1)
                break;
        }
    }
    if (duplicate_count &gt; 1)
        cout &lt;&lt; "?";
    else
        cout &lt;&lt; max_char;
    return 0;
}</code></pre>

<p>입력에 대소문자가 모두 들어오기 때문에 문자열을 소문자 또는 대문자로 통일시킨 다음 비교를 진행한다.</p>

<p>대문자로 변환시키기 위해서 algorithm의 transform과 cctype의 ::toupper를 사용한다. 소문자는 ::tolower</p>

<p>각 문자의 등장 횟수 중 가장 큰 수를 구한 다음 해당 횟수가 또 존재하는지 검사하여 ? 또는 해당 문자의 대문자를 출력한다.</p>

<h3>C#</h3>
<pre class="csharp"><code>using System;
using System.Linq;
class Program{
    static void Main(string[] args){
        string str = Console.ReadLine().ToUpper();
        int[] char_count = new int[26];
        foreach(char c in str){
            char_count[c - 'A']++;
        }
        int max_count = char_count.Max();
        int max_count_index = Array.IndexOf(char_count, max_count);
        int duplicate_count = char_count.Count(x =&gt; x == max_count);
        if (duplicate_count &gt; 1){
            Console.WriteLine("?");
        }
        else{
            Console.WriteLine((char)(max_count_index + 'A'));
        }
    }
}</code></pre>

<h3>Python</h3>
<pre class="python"><code>s = input().upper()
str_cnt = [0] * 26
for c in s:
    idx = ord(c) - ord('A')
    str_cnt[idx] += 1
max_cnt = max(str_cnt)
max_idx = 0
duplicate_cnt = 0
for i in range(26):
    if str_cnt[i] == max_cnt:
        duplicate_cnt += 1
        max_idx = i
        if duplicate_cnt &gt; 1:
            break
if duplicate_cnt &gt; 1:
    print("?")
else:
    print(chr(max_idx + ord('A')))</code></pre>

<h3>Node.js</h3>
<pre class="javascript"><code>const fs = require('fs');
const input = fs.readFileSync('/dev/stdin', 'utf8').toUpperCase();
const str_cnt = new Array(26).fill(0);
for (const c of input){
    const i = c.charCodeAt(0) - 'A'.charCodeAt(0);
    str_cnt[i]++;
}
const max = Math.max(...str_cnt);
let max_idx = 0;
let duplicate_cnt = 0;
for (let i = 0; i &lt; 26; i++){
    if (str_cnt[i] === max){
        duplicate_cnt++;
        max_idx = i;
        if (duplicate_cnt &gt; 1)
            break;
    }
}
if (duplicate_cnt &gt; 1)
    console.log("?");
else
    console.log(String.fromCharCode(max_idx + 'A'.charCodeAt(0)));</code></pre>
