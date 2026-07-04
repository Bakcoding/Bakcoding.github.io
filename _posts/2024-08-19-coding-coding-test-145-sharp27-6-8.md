---
title: "백준 코딩테스트 #27. 심화 ( 6 ~ 8 )"
excerpt: "백준 코딩테스트 #27. 심화 ( 6 ~ 8 )"
categories:
  - CodingTest
permalink: /coding/coding-test/145-sharp27-6-8/
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
date: 2024-08-19
last_modified_at: 2024-08-19
source_url: https://b-note.tistory.com/145
---

<h2>6번 크로아티아 알파벳</h2>
<p><b>문제</b></p>
<p>예전에는&nbsp;운영체제에서&nbsp;크로아티아&nbsp;알파벳을&nbsp;입력할&nbsp;수가&nbsp;없었다.&nbsp;따라서,&nbsp;다음과&nbsp;같이&nbsp;크로아티아&nbsp;알파벳을&nbsp;변경해서&nbsp;입력했다.</p>

<table style="border-collapse: collapse; width: 37.7907%; height: 291px;" border="1">
<tbody>
<tr style="height: 17px;">
<td style="width: 50%; height: 17px;"><b>크로아티아&nbsp;알파벳</b></td>
<td style="width: 50%; height: 17px;"><b>변경</b></td>
</tr>
<tr style="height: 17px;">
<td style="width: 50%; height: 17px;">č</td>
<td style="width: 50%; height: 17px;">c=</td>
</tr>
<tr style="height: 17px;">
<td style="width: 50%; height: 17px;">ć</td>
<td style="width: 50%; height: 17px;">c-</td>
</tr>
<tr style="height: 17px;">
<td style="width: 50%; height: 17px;">dž</td>
<td style="width: 50%; height: 17px;">dz=</td>
</tr>
<tr style="height: 17px;">
<td style="width: 50%; height: 17px;">đ</td>
<td style="width: 50%; height: 17px;">d-</td>
</tr>
<tr style="height: 17px;">
<td style="width: 50%; height: 17px;">lj</td>
<td style="width: 50%; height: 17px;">lj</td>
</tr>
<tr style="height: 17px;">
<td style="width: 50%; height: 17px;">nj</td>
<td style="width: 50%; height: 17px;">nj</td>
</tr>
<tr style="height: 17px;">
<td style="width: 50%; height: 17px;">&scaron;</td>
<td style="width: 50%; height: 17px;">s=</td>
</tr>
<tr style="height: 17px;">
<td style="width: 50%; height: 17px;">ž</td>
<td style="width: 50%; height: 17px;">z=</td>
</tr>
</tbody>
</table>

<p>예를&nbsp;들어,&nbsp;ljes=njak은&nbsp;크로아티아&nbsp;알파벳&nbsp;6개(lj,&nbsp;e,&nbsp;&scaron;,&nbsp;nj,&nbsp;a,&nbsp;k)로&nbsp;이루어져&nbsp;있다.&nbsp;단어가&nbsp;주어졌을&nbsp;때,&nbsp;몇&nbsp;개의&nbsp;크로아티아&nbsp;알파벳으로&nbsp;이루어져&nbsp;있는지&nbsp;출력한다.&nbsp;dž는&nbsp;무조건&nbsp;하나의&nbsp;알파벳으로&nbsp;쓰이고,&nbsp;d와&nbsp;ž가&nbsp;분리된&nbsp;것으로&nbsp;보지&nbsp;않는다.&nbsp;lj와&nbsp;nj도&nbsp;마찬가지이다.&nbsp;위&nbsp;목록에&nbsp;없는&nbsp;알파벳은&nbsp;한&nbsp;글자씩&nbsp;센다.</p>

<p><b>입력</b></p>
<p>첫째&nbsp;줄에&nbsp;최대&nbsp;100글자의&nbsp;단어가&nbsp;주어진다.&nbsp;알파벳&nbsp;소문자와&nbsp;'-',&nbsp;'='로만&nbsp;이루어져&nbsp;있다.</p>

<p>단어는 크로아티아 알파벳으로 이루어져 있다. 문제 설명의 표에 나와있는 알파벳은 변경된 형태로 입력된다.</p>

<p><b>출력</b></p>
<p>입력으로&nbsp;주어진&nbsp;단어가&nbsp;몇&nbsp;개의&nbsp;크로아티아&nbsp;알파벳으로&nbsp;이루어져&nbsp;있는지&nbsp;출력한다.</p>

<p>입력되는 문자열에서 대응하는 크로아티아 문자열이 있는지 확인하여 글자 수를 구한다.</p>

<h3>C++</h3>
<pre class="cpp"><code>#include &lt;iostream&gt;
#include &lt;string&gt;
using namespace std;
int main(){
    string input;
    cin &gt;&gt; input;
    int char_cnt = 0;
    string str_arr[8] = {"c=", "c-", "dz=", "d-", "lj", "nj", "s=", "z="};
    for (int i = 0; i &lt; input.length(); i++){
        bool matched = false;
        for (int j = 0; j &lt; 8; j++){
            string croatian_char = str_arr[j];
            if (input.substr(i, croatian_char.length()) == croatian_char){
                char_cnt++;
                i += croatian_char.length() - 1;
                matched = true;
                break;
            }
        }
        if (!matched){
            char_cnt++;
        }
    }
    cout &lt;&lt; char_cnt;
    return 0;
}</code></pre>

<p>크로아티아 문자를 배열에 저장해 두고 입력된 문자열을 순회하면서 크로아티아 문자가 포함되어 있는지 검사한다.</p>

<p>검사할 때 크로아티아 문자 배열을 순회하면서 하나씩 입력된 문자열의 인덱스를 기준으로 동일한지 검사한다.</p>

<h3>C#</h3>
<pre class="csharp"><code>using System;
class Program{
    static void Main(string[] args){
        string[] str_arr = {"c=", "c-", "dz=", "d-", "lj", "nj", "s=", "z="};
        string input = Console.ReadLine();
        int char_cnt = 0;
        for (int i = 0; i &lt; input.Length; i++){
            bool char_matched = false;
            for (int j = 0; j &lt; str_arr.Length; j++){
                string croatian_char = str_arr[j];
                if (i + croatian_char.Length &lt;= input.Length &amp;&amp;
                    input.Substring(i, croatian_char.Length) == croatian_char){
                    char_cnt++;
                    i += croatian_char.Length - 1;
                    char_matched = true;
                    break;
                }
            }
            if (!char_matched) char_cnt++;
        }
        Console.WriteLine(char_cnt);
    }
}</code></pre>


<h3>Python</h3>
<pre class="python"><code>input_str = input()
str_arr = ["c=", "c-", "dz=", "d-", "lj", "nj", "s=", "z="]
char_cnt = 0
i = 0
while i &lt; len(input_str):
    is_char_matched = False
    for croatian_char in str_arr:
        if input_str[i:i+len(croatian_char)] == croatian_char:
            char_cnt += 1
            i += len(croatian_char)
            is_char_matched = True
            break
    if not is_char_matched:
        char_cnt += 1
        i += 1
print(char_cnt)</code></pre>
<h3>&nbsp;</h3>
<h3>Node.js</h3>
<pre class="javascript"><code>const fs = require('fs');
const input = fs.readFileSync('/dev/stdin','utf8').trim();
const croatian_chars = ["c=", "c-", "dz=", "d-", "lj", "nj", "s=", "z="];
let char_cnt = 0;
for (let i = 0; i &lt; input.length; i++){
    let is_char_matched = false;
    for (let j = 0; j &lt; croatian_chars.length; j++){
        const croatian_char = croatian_chars[j];
        if (input.slice(i, i + croatian_char.length) === croatian_char){
            char_cnt += 1;
            i += croatian_char.length - 1;
            is_char_matched = true;
            break;
        }
    }
    if (!is_char_matched){
        char_cnt += 1;
    }
}
console.log(char_cnt);</code></pre>

<h2>7번 그룹 단어 체커</h2>
<p><b>문제</b></p>
<p>그룹&nbsp;단어란&nbsp;단어에&nbsp;존재하는&nbsp;모든&nbsp;문자에&nbsp;대해서,&nbsp;각&nbsp;문자가&nbsp;연속해서&nbsp;나타나는&nbsp;경우만을&nbsp;말한다.&nbsp;예를&nbsp;들면,&nbsp;ccazzzzbb는&nbsp;c,&nbsp;a,&nbsp;z,&nbsp;b가&nbsp;모두&nbsp;연속해서&nbsp;나타나고,&nbsp;kin도&nbsp;k,&nbsp;i,&nbsp;n이&nbsp;연속해서&nbsp;나타나기&nbsp;때문에&nbsp;그룹&nbsp;단어이지만,&nbsp;aabbbccb는&nbsp;b가&nbsp;떨어져서&nbsp;나타나기&nbsp;때문에&nbsp;그룹&nbsp;단어가&nbsp;아니다.&nbsp;</p>

<p>단어&nbsp;N개를&nbsp;입력으로&nbsp;받아&nbsp;그룹&nbsp;단어의&nbsp;개수를&nbsp;출력하는&nbsp;프로그램을&nbsp;작성하시오.</p>

<p><b>입력</b></p>
<p>첫째&nbsp;줄에&nbsp;단어의&nbsp;개수&nbsp;N이&nbsp;들어온다.&nbsp;N은&nbsp;100보다&nbsp;작거나&nbsp;같은&nbsp;자연수이다.&nbsp;둘째&nbsp;줄부터&nbsp;N개의&nbsp;줄에&nbsp;단어가&nbsp;들어온다.&nbsp;단어는&nbsp;알파벳&nbsp;소문자로만&nbsp;되어있고&nbsp;중복되지&nbsp;않으며,&nbsp;길이는&nbsp;최대&nbsp;100이다.</p>

<p><b>출력</b></p>
<p>첫째&nbsp;줄에&nbsp;그룹&nbsp;단어의&nbsp;개수를&nbsp;출력한다.</p>

<p>N개의 입력을 받아서 해당 단어가 연속되는 문자인지 확인을 해야 한다. 연속은 동일한 문자 사이에 다른 문자가 등장했을 때 연속성이 깨진다.</p>

<h3>C++</h3>
<pre class="cpp"><code>#include &lt;iostream&gt;
#include &lt;string&gt;
using namespace std;
int main(){
    int n;
    cin &gt;&gt; n;
    
    string word;
    int word_cnt = 0;
    while(cin &gt;&gt; word){
        bool is_seq_word = true;
        int char_arr[26] = {0};
        char last_char = '\0';
        for (char c : word){
            if (c != last_char){
                if (char_arr[c - 'a'] != 0){
                    is_seq_word = false;
                    break;
                }
                char_arr[c - 'a'] = 1;
            }
            last_char = c;
        }
        if (is_seq_word) 
            word_cnt++;
    }
    cout &lt;&lt; word_cnt;
    return 0;
}</code></pre>



<h3>C#</h3>
<pre class="csharp"><code>using System;
class Program{
    static void Main(string[] args){
        int n = int.Parse(Console.ReadLine());
        int word_cnt = 0;
        for (int i = 0; i &lt; n; i++){
            char last_char = '\0';
            int[] char_arr = new int[26];
            string word = Console.ReadLine();
            bool is_seq_word = true;
            foreach (char c in word){
                if (c != last_char){
                    if (char_arr[c - 'a'] != 0){
                        is_seq_word = false;
                        break;
                    }
                    char_arr[c - 'a'] = 1;
                }
                last_char = c;
            }
            if (is_seq_word)
                word_cnt++;
        }
        Console.WriteLine(word_cnt);
    }
}</code></pre>

<h3>Python</h3>
<pre class="python"><code>n = int(input())
word_cnt = 0;
for i in range(n):
    word = input();
    is_seq_word = True
    last_char = '\0'
    char_arr = [0] * 26
    for c in word:
        if c != last_char:
            if char_arr[ord(c) - ord('a')] != 0:
                is_seq_word = False
                break
            char_arr[ord(c) - ord('a')] = 1
        last_char = c
    if is_seq_word:
        word_cnt += 1
print(word_cnt)</code></pre>
<h3>&nbsp;</h3>
<h3>Node.js</h3>
<pre class="javascript"><code>const fs = require('fs');
const input = fs.readFileSync('/dev/stdin','utf8').trim().split('\n');
const n = parseInt(input[0]);
let word_cnt = 0;
for (let i = 1; i &lt;= n; i++){
    const char_arr = Array(26).fill(0);
    const word = input[i];
    let is_seq_word = true;
    let last_char = '\0';
    for (const c of word){
        if (c !== last_char){
            if (char_arr[c.charCodeAt(0) - 'a'.charCodeAt(0)]){
                is_seq_word = false;
                break;
            }
            char_arr[c.charCodeAt(0) - 'a'.charCodeAt(0)] = 1;
        }
        last_char = c;
    }
    if (is_seq_word){
        word_cnt++;
    }
}
console.log(word_cnt);</code></pre>

<h2>8번 너의 평점은</h2>
<p><b>문제</b></p>
<p>인하대학교&nbsp;컴퓨터공학과를&nbsp;졸업하기&nbsp;위해서는,&nbsp;전공평점이&nbsp;3.3&nbsp;이상이거나&nbsp;졸업고사를&nbsp;통과해야&nbsp;한다.&nbsp;그런데&nbsp;아뿔싸,&nbsp;치훈이는&nbsp;깜빡하고&nbsp;졸업고사를&nbsp;응시하지&nbsp;않았다는&nbsp;사실을&nbsp;깨달았다!&nbsp;</p>

<p>치훈이의&nbsp;전공평점을&nbsp;계산해 주는&nbsp;프로그램을&nbsp;작성해 보자.&nbsp;</p>

<p>전공평점은&nbsp;전공과목별&nbsp;(학점&nbsp;&times;&nbsp;과목평점)의&nbsp;합을&nbsp;학점의&nbsp;총합으로&nbsp;나눈&nbsp;값이다.&nbsp;</p>

<p>인하대학교&nbsp;컴퓨터공학과의&nbsp;등급에&nbsp;따른&nbsp;과목평점은&nbsp;다음&nbsp;표와&nbsp;같다.</p>

<table style="background-color: #ffffff; color: #333333; text-align: start; border-collapse: collapse; width: 18.8372%; height: 270px;" border="1">
<tbody>
<tr>
<td style="text-align: center;">A+</td>
<td style="text-align: center;">4.5</td>
</tr>
<tr>
<td style="text-align: center;">A0</td>
<td style="text-align: center;">4.0</td>
</tr>
<tr>
<td style="text-align: center;">B+</td>
<td style="text-align: center;">3.5</td>
</tr>
<tr>
<td style="text-align: center;">B0</td>
<td style="text-align: center;">3.0</td>
</tr>
<tr>
<td style="text-align: center;">C+</td>
<td style="text-align: center;">2.5</td>
</tr>
<tr>
<td style="text-align: center;">C0</td>
<td style="text-align: center;">2.0</td>
</tr>
<tr>
<td style="text-align: center;">D+</td>
<td style="text-align: center;">1.5</td>
</tr>
<tr>
<td style="text-align: center;">D0</td>
<td style="text-align: center;">1.0</td>
</tr>
<tr>
<td style="text-align: center;">F</td>
<td style="text-align: center;">0.0</td>
</tr>
</tbody>
</table>

<p>P/F&nbsp;과목의&nbsp;경우&nbsp;등급이&nbsp;P 또는&nbsp;F로&nbsp;표시되는데,&nbsp;등급이&nbsp;P인&nbsp;과목은&nbsp;계산에서&nbsp;제외해야&nbsp;한다.&nbsp;</p>

<p>과연&nbsp;치훈이는&nbsp;무사히&nbsp;졸업할&nbsp;수&nbsp;있을까?</p>

<p><b>입력</b></p>
<p>20줄에&nbsp;걸쳐&nbsp;치훈이가&nbsp;수강한&nbsp;전공과목의&nbsp;과목명,&nbsp;학점,&nbsp;등급이&nbsp;공백으로&nbsp;구분되어&nbsp;주어진다.</p>

<p><b>출력</b></p>
<p>치훈이의&nbsp;전공평점을&nbsp;출력한다.&nbsp;</p>

<p>정답과의&nbsp;절대오차&nbsp;또는&nbsp;상대오차가&nbsp;\(10^{-4}\)&nbsp;이하이면&nbsp;정답으로&nbsp;인정한다.</p>

<p><b>제한</b></p>
<p>- 1 &le; 과목명의 길이 &le; 50</p>
<p>- 과목명은 알파벳 대소문자 또는 숫자로만 이루어져 있으며, 띄어쓰기 없이 주어진다. 입력으로 주어지는 모든 과목명은 서로 다르다.</p>
<p>- 학점은 1.0,2.0,3.0,4.0중 하나이다.</p>
<p>- 등급은 A+, A0, B+, B0, C+, C0, D+, D0, F, P 중 하나이다.</p>
<p>- 적어도 한 과목은 등급이 P가 아님이 보장된다.</p>

<p>20과목 정보가 이름, 점수, 등급으로 각 줄에 입력된다.</p>

<p>P가 아닌 등급일 때만 점수를 계산한다.</p>

<h3>C++</h3>
<pre class="cpp"><code>#include &lt;iostream&gt;
#include &lt;iomanip&gt;
#include &lt;string&gt;
using namespace std;
int main(){
    float total_score = 0.0f;
    float sum_score = 0.0f;
    for (int i = 0; i &lt; 20; i++){
        string name;
        float score;
        string grade;
        float grade_score;
        cin &gt;&gt; name &gt;&gt; score &gt;&gt; grade;
        if (grade == "A+"){
            grade_score = 4.5;
        }
        else if (grade == "A0"){
            grade_score = 4.0;
        }
        else if (grade == "B+"){
            grade_score = 3.5;
        }
        else if (grade == "B0"){
            grade_score = 3.0;
        }
        else if (grade == "C+"){
            grade_score = 2.5;
        }
        else if (grade == "C0"){
            grade_score = 2.0;
        }
        else if (grade == "D+"){
            grade_score = 1.5;
        }
        else if (grade == "D0"){
            grade_score = 1.0;
        }
        else if (grade == "F"){
            grade_score = 0.0;
        }
        
        if (grade != "P"){
            sum_score += score;
            total_score += score * grade_score;
        }
    }
    float result = total_score / sum_score;
    cout &lt;&lt; fixed &lt;&lt; setprecision(6) &lt;&lt; result;
    return 0;
}</code></pre>

<h3>C#</h3>
<pre class="csharp"><code>using System;
class Program{
    static void Main(string[] args){
        float sum_score = 0f;
        float total_score = 0f;
        for (int i = 0; i &lt; 20; i++){
            string str = Console.ReadLine();
            string[] str_arr = str.Split();
            string name = str_arr[0];
            float score = float.Parse(str_arr[1]);
            string grade = str_arr[2];
            float grade_score = 0f;
            if (grade == "A+"){
                grade_score = 4.5f;
            }
            else if (grade == "A0"){
                grade_score = 4.0f;
            }
            else if (grade == "B+"){
                grade_score = 3.5f;
            }
            else if (grade == "B0"){
                grade_score = 3.0f;
            }
            else if (grade == "C+"){
                grade_score = 2.5f;
            }
            else if (grade == "C0"){
                grade_score = 2.0f;
            }
            else if (grade == "D+"){
                grade_score = 1.5f;
            }
            else if (grade == "D0"){
                grade_score = 1.0f;
            }
            else if (grade == "F"){
                grade_score = 0.0f;
            }
            if (grade != "P"){
                sum_score += score;
                total_score += score * grade_score;
            }
        }
        float result = total_score / sum_score;
        Console.WriteLine(result);
    }
}</code></pre>

<h3>Python</h3>
<pre class="csharp"><code>import sys
sum_score = 0;
total_score = 0;
for i in range(20):
    name, score, grade = sys.stdin.readline().strip().split()
    score = float(score)
    grade_score = 0;
    if grade != "P":
        if grade == "A+":
            grade_score = 4.5
        elif grade == "A0":
            grade_score = 4.0
        elif grade == "B+":
            grade_score = 3.5
        elif grade == "B0":
            grade_score = 3.0
        elif grade == "C+":
            grade_score = 2.5
        elif grade == "C0":
            grade_score = 2.0
        elif grade == "D+":
            grade_score = 1.5
        elif grade == "D0":
            grade_score = 1.0
        elif grade == "F":
            grade_score = 0.0
        sum_score += score
        total_score += score * grade_score
result = total_score / sum_score
print(f"{result:.6f}")</code></pre>

<h3>Node.js</h3>
<pre class="javascript"><code>const fs = require('fs');
const input = fs.readFileSync('/dev/stdin','utf8').trim().split('\n');
let total_score = 0.0;
let sum_score = 0.0;
for (let i = 0; i &lt; 20; i++){
    const str = input[i].split(' ');
    const name = str[0];
    const score = parseFloat(str[1]);
    const grade = str[2];
    let grade_score = 0.0;
    if (grade === "A+")
    {
        grade_score = 4.5;
    }
    else if (grade === "A0")
    {
        grade_score = 4.0;
    }
    else if (grade === "B+")
    {
        grade_score = 3.5;
    }
    else if (grade === "B0")
    {
        grade_score = 3.0;
    }
    else if (grade === "C+")
    {
        grade_score = 2.5;
    }
    else if (grade === "C0")
    {
        grade_score = 2.0;
    }
    else if (grade === "D+")
    {
        grade_score = 1.5;
    }
    else if (grade === "D0")
    {
        grade_score = 1.0;
    }
    else if (grade === "F")
    {
        grade_score = 0.0;
    }
    if (grade != "P"){
        sum_score += score;
        total_score += score * grade_score;
    }
}
const result = total_score / sum_score;
console.log(result.toFixed(6));</code></pre>
