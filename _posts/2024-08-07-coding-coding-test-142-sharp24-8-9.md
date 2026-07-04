---
title: "백준 코딩테스트 #24. 문자열 (8, 9)"
excerpt: "백준 코딩테스트 #24. 문자열 (8, 9)"
categories:
  - CodingTest
permalink: /coding/coding-test/142-sharp24-8-9/
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
source_url: https://b-note.tistory.com/142
---

<h2>8번 단어의 개수</h2>
<p><b>문제</b></p>
<p>영어&nbsp;대소문자와&nbsp;공백으로&nbsp;이루어진&nbsp;문자열이&nbsp;주어진다.&nbsp;이&nbsp;문자열에는&nbsp;몇&nbsp;개의&nbsp;단어가&nbsp;있을까?&nbsp;이를&nbsp;구하는&nbsp;프로그램을&nbsp;작성하시오.&nbsp;단,&nbsp;한&nbsp;단어가&nbsp;여러&nbsp;번&nbsp;등장하면&nbsp;등장한&nbsp;횟수만큼&nbsp;모두&nbsp;세어야&nbsp;한다.</p>

<p><b>입력</b></p>
<p>첫&nbsp;줄에&nbsp;영어&nbsp;대소문자와&nbsp;공백으로&nbsp;이루어진&nbsp;문자열이&nbsp;주어진다.&nbsp;이&nbsp;문자열의&nbsp;길이는&nbsp;1,000,000을&nbsp;넘지&nbsp;않는다.&nbsp;단어는&nbsp;공백&nbsp;한&nbsp;개로&nbsp;구분되며,&nbsp;공백이&nbsp;연속해서&nbsp;나오는&nbsp;경우는&nbsp;없다.&nbsp;또한&nbsp;문자열은&nbsp;공백으로&nbsp;시작하거나&nbsp;끝날&nbsp;수&nbsp;있다.</p>

<p><b>출력</b></p>
<p>첫째&nbsp;줄에&nbsp;단어의&nbsp;개수를&nbsp;출력한다.</p>

<p>공백으로 이루어진 문자열에서 단어의 개수를 찾는 문제이다.</p>

<p>문자열을 공백으로 끊어서 배열에 저장하고 배열의 사이즈를 구하면 해결되지 않을까 생각이 든다.</p>

<p>문자열이 공백으로 시작하거나 끝날 수 있다고 하니 문자열 양끝의 공백을 제거해 주는 동작이 필요할 거 같다.</p>

<h3>C++</h3>
<pre class="cpp"><code>#include &lt;iostream&gt;
#include &lt;string&gt;
#include &lt;vector&gt;
using namespace std;
int main(){
    vector&lt;string&gt; vec_str;
    string s;
    while(cin &gt;&gt; s){
        vec_str.push_back(s);
    }
    cout &lt;&lt; vec_str.size();
    return 0;
}</code></pre>

<p>C++의 입력은 단어 단위이다. 따라서 공백, 줄 바꿈 등의 입력이 발생하면 입력이 끊기고 다음 입력을 받게 된다.</p>

<p>따라서 이 문제의 경우 입력이 없을 때까지 받으면서 배열에 저장하고 길이만 출력하면 단어의 개수를 구할 수 있게 된다.</p>

<h3>C#</h3>
<pre class="csharp"><code>using System;
class Program{
    static void Main(string[] args){
        string s = Console.ReadLine();
        string[] str_arr = s.Trim().Split(' ', StringSplitOptions.RemoveEmptyEntries);
        Console.WriteLine(str_arr.Length);
    }
}</code></pre>

<p>Split을 옵션 없이 사용했을 경우 채점에서 틀렸다는 결과가 나왔다.</p>

<p>아마도 문제에서 문자열의 시작과 끝이 공백인 경우가 있다고 했는데 아예 공백만 있는 문자열이 입력으로 들어오는 경우도 있는 것 같다. " "</p>

<p>이 경우 그냥 Split을 하게 되면 빈 문자열이 배열에 포함되기 때문에 이를 제외시켜 주는 StringSplitoptions.RemoveEmptyEntries를 해주어야 한다.</p>

<h3>Python</h3>
<pre class="python"><code>s = input()
arr = s.strip().split()
print(len(arr))</code></pre>

<h3>Node.js</h3>
<pre class="javascript"><code>const fs = require('fs');
const input = fs.readFileSync('/dev/stdin','utf8').trim().split(' ');
const words = input.filter(word =&gt; word !== '');
console.log(words.length);</code></pre>

<p>js에서도 마찬가지로 split을 할 경우 빈 문자열도 배열에 추가되기 때문에 배열을 만든 다음 빈 문자열을 제거해 주는 작업을 한다.</p>

<h2>9번 상수</h2>
<p><b>문제</b></p>
<p>상근이의&nbsp;동생&nbsp;상수는&nbsp;수학을&nbsp;정말&nbsp;못한다.&nbsp;상수는&nbsp;숫자를&nbsp;읽는데&nbsp;문제가&nbsp;있다.&nbsp;이렇게&nbsp;수학을&nbsp;못하는&nbsp;상수를&nbsp;위해서&nbsp;상근이는&nbsp;수의&nbsp;크기를&nbsp;비교하는&nbsp;문제를&nbsp;내주었다.&nbsp;상근이는&nbsp;세&nbsp;자릿수&nbsp;두&nbsp;개를&nbsp;칠판에&nbsp;써주었다.&nbsp;그다음에&nbsp;크기가&nbsp;큰&nbsp;수를&nbsp;말해보라고&nbsp;했다.&nbsp;</p>

<p>상수는&nbsp;수를&nbsp;다른&nbsp;사람과&nbsp;다르게&nbsp;거꾸로&nbsp;읽는다.&nbsp;예를&nbsp;들어,&nbsp;734와&nbsp;893을&nbsp;칠판에&nbsp;적었다면,&nbsp;상수는&nbsp;이&nbsp;수를&nbsp;437과&nbsp;398로&nbsp;읽는다.&nbsp;따라서,&nbsp;상수는&nbsp;두&nbsp;수중&nbsp;큰&nbsp;수인&nbsp;437을&nbsp;큰&nbsp;수라고&nbsp;말할&nbsp;것이다.&nbsp;</p>

<p>두&nbsp;수가&nbsp;주어졌을&nbsp;때,&nbsp;상수의&nbsp;대답을&nbsp;출력하는&nbsp;프로그램을&nbsp;작성하시오.</p>

<p><b>입력</b></p>
<p>첫째&nbsp;줄에&nbsp;상근이가&nbsp;칠판에&nbsp;적은&nbsp;두&nbsp;수&nbsp;A와&nbsp;B가&nbsp;주어진다.&nbsp;두&nbsp;수는&nbsp;같지&nbsp;않은&nbsp;세&nbsp;자릿수이며,&nbsp;0이&nbsp;포함되어&nbsp;있지&nbsp;않다.</p>

<p><b>출력</b></p>
<p>첫째&nbsp;줄에&nbsp;상수의&nbsp;대답을&nbsp;출력한다.</p>

<p>입력된 두 수를 뒤집은 후 크기를 비교하여 큰 값을 출력해야 상근이의 대답과 동일하다.</p>

<h3>C++</h3>
<pre class="cpp"><code>#include &lt;iostream&gt;
#include &lt;string&gt;
#include &lt;algorithm&gt;
using namespace std;
int main(){
    string n1, n2;
    cin &gt;&gt; n1 &gt;&gt; n2;
    reverse(n1.begin(), n1.end());
    reverse(n2.begin(), n2.end());
    int i_n1 = stoi(n1);
    int i_n2 = stoi(n2);
    if (i_n1 &gt; i_n2)
        cout &lt;&lt; i_n1;
    else
        cout &lt;&lt; i_n2;
    return 0;
}</code></pre>

<p>reverse로 문자열을 뒤집고 stoi로 숫자문자를 정수형으로 변환해서 값 비교 후 큰 값을 출력한다.</p>

<h3>C#</h3>
<pre class="csharp"><code>using System;
class Program{
    static void Main(string[] args){
        string[] input = Console.ReadLine().Trim().Split();
        string n1 = input[0];
        string n2 = input[1];
        char[] char_arr1 = n1.ToCharArray();
        Array.Reverse(char_arr1);
        n1 = new string(char_arr1);
        char[] char_arr2 = n2.ToCharArray();
        Array.Reverse(char_arr2);
        n2 = new string(char_arr2);
        int i_n1 = int.Parse(n1);
        int i_n2 = int.Parse(n2);
        if (i_n1 &gt; i_n2)
            Console.WriteLine(i_n1);
        else
            Console.WriteLine(i_n2);
    }
}</code></pre>


<p>문자열 뒤집기를 간단하게 처리하기 위해서 Array.Reverse 함수를 사용할 수 있다.</p>

<p>먼저 이 함수를 사용하기 위해서 배열이 아닌 불변타입인 string을 char [] 배열로 변환을 해야 한다. ToCharArray를 사용해서 문자열을 문자 배열로 변환 후 Array.Reverse로 배열을 역순으로 만든다. 그리고 뒤집어진 배열을 다시 문자열로 할당하여 원하는 문자열을 만든다.</p>


<h3>Python</h3>
<pre class="python"><code>input_arr = input().split()
str_1 = input_arr[0]
str_2 = input_arr[1]
str_1 = str_1[::-1]
str_2 = str_2[::-1]
val_1 = int(str_1);
val_2 = int(str_2);
if val_1 &gt; val_2:
    print(val_1)
else:
    print(val_2)</code></pre>

<p>파이썬에서도 문자열은 배열이 아닌 불변 타입이다. 따라서 배열에서 사용가능한 reverse 메서드가 없기 때문에 문자열을 리스트로 바꾸고 뒤집은 다음 다시 문자열로 바꾸는 방법도 있지만 문자열에서 슬라이싱을 사용하여 역순으로 정렬할 수 있다.</p>

<h3>Node.js</h3>
<pre class="javascript"><code>const fs = require('fs');
const input = fs.readFileSync('/dev/stdin','utf8').split(' ');
const val_1 = parseInt(input[0].split('').reverse().join(''), 10);
const val_2 = parseInt(input[1].split('').reverse().join(''), 10);
if (val_1 &gt; val_2)
    console.log(val_1);
else
    console.log(val_2);</code></pre>

<p>문자열을 바로 reverse 할 수 없기 때문에 split으로 배열로 만든 다음 뒤집고 join으로 이어 붙인다. 그리고 정수형으로 변환하여 비교 후 출력한다.</p>

<p>이렇게 이어서 쓰면 순차적으로 동작해서 한 번에 처리가 가능하다.</p>
