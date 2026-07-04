---
title: "백준 코딩테스트 #11. 조건문 6"
excerpt: "백준 코딩테스트 #11. 조건문 6"
categories:
  - CodingTest
permalink: /coding/coding-test/129-sharp11-6/
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
date: 2024-07-26
last_modified_at: 2024-07-26
source_url: https://b-note.tistory.com/129
---

<h2>6번 오븐 시계</h2>
<p><b>문제</b></p>
<p>KOI&nbsp;전자에서는&nbsp;건강에&nbsp;좋고&nbsp;맛있는&nbsp;훈제오리구이&nbsp;요리를&nbsp;간편하게&nbsp;만드는&nbsp;인공지능&nbsp;오븐을&nbsp;개발하려고&nbsp;한다.&nbsp;인공지능&nbsp;오븐을&nbsp;사용하는&nbsp;방법은&nbsp;적당한&nbsp;양의&nbsp;오리&nbsp;훈제&nbsp;재료를&nbsp;인공지능&nbsp;오븐에&nbsp;넣으면&nbsp;된다.&nbsp;그러면&nbsp;인공지능&nbsp;오븐은&nbsp;오븐구이가&nbsp;끝나는&nbsp;시간을&nbsp;분&nbsp;단위로&nbsp;자동적으로&nbsp;계산한다.&nbsp;또한,&nbsp;KOI&nbsp;전자의&nbsp;인공지능&nbsp;오븐&nbsp;앞면에는&nbsp;사용자에게&nbsp;훈제오리구이&nbsp;요리가&nbsp;끝나는&nbsp;시각을&nbsp;알려&nbsp;주는&nbsp;디지털시계가&nbsp;있다.&nbsp;훈제오리구이를&nbsp;시작하는&nbsp;시각과&nbsp;오븐구이를&nbsp;하는&nbsp;데&nbsp;필요한&nbsp;시간이&nbsp;분단위로&nbsp;주어졌을&nbsp;때,&nbsp;오븐구이가&nbsp;끝나는&nbsp;시각을&nbsp;계산하는&nbsp;프로그램을&nbsp;작성하시오.</p>

<p><b>입력</b><br />첫째&nbsp;줄에는&nbsp;현재&nbsp;시각이&nbsp;나온다.&nbsp;현재&nbsp;시각은&nbsp;시&nbsp;A&nbsp;(0&nbsp;&le;&nbsp;A&nbsp;&le;&nbsp;23)와&nbsp;분&nbsp;B&nbsp;(0&nbsp;&le;&nbsp;B&nbsp;&le;&nbsp;59)가&nbsp;정수로&nbsp;빈칸을&nbsp;사이에&nbsp;두고&nbsp;순서대로&nbsp;주어진다.&nbsp;두&nbsp;번째&nbsp;줄에는&nbsp;요리하는&nbsp;데&nbsp;필요한&nbsp;시간&nbsp;C&nbsp;(0&nbsp;&le;&nbsp;C&nbsp;&le;&nbsp;1,000)가&nbsp;분&nbsp;단위로&nbsp;주어진다.</p>

<p><b>출력</b></p>
<p>첫째&nbsp;줄에&nbsp;종료되는&nbsp;시각의&nbsp;시와&nbsp;분을&nbsp;공백을&nbsp;사이에&nbsp;두고&nbsp;출력한다.&nbsp;(단,&nbsp;시는&nbsp;0부터&nbsp;23까지의&nbsp;정수,&nbsp;분은&nbsp;0부터&nbsp;59까지의&nbsp;정수이다.&nbsp;디지털시계는&nbsp;23시&nbsp;59분에서&nbsp;1분이&nbsp;지나면&nbsp;0시&nbsp;0분이&nbsp;된다.)</p>

<p>훈제오리구이 맛있겠다.</p>
<p>입력은 두 번 들어오고 처음에 현재 시각, 두 번째 조리에 필요한 시간이다.</p>
<p>종료되는 시간은 현재 시각에서 조리 시간을 더한 결과이다. 주의할 점은 조리에 필요한 값은 분 단위로 들어온다는 것으로 이를 시간과 분으로 구분하는 게 계산하기 편할 것 같다.</p>

<h2>C++</h2>
<pre class="cpp"><code>#include &lt;iostream&gt;
using namespace std;
int main(){
    int currH, currM, needM;
    cin &gt;&gt; currH;
    cin &gt;&gt; currM;
    cin &gt;&gt; needM;
    int endH, endM;
    int needH = needM / 60;
    needM = needM - needH * 60;
    endH = currH + needH;
    endM = currM + needM;
    if (endM &gt;= 60){
        endM = endM - 60;
        endH++;
    }
    if (endH &gt;= 24)
        endH = endH - 24;
    cout &lt;&lt; endH &lt;&lt; " " &lt;&lt; endM;
    return 0;
}</code></pre>

<h2>C#</h2>
<pre class="csharp"><code>using System;
class Program{
    static void Main(string[] args){
        string input_first = Console.ReadLine();
        string input_second = Console.ReadLine();
        string[] arr_input_first = input_first.Split(' ');
        int currH = int.Parse(arr_input_first[0]);
        int currM = int.Parse(arr_input_first[1]);
        int needM = int.Parse(input_second);
        int endH, endM;
        int needH = needM / 60;
        needM = needM % 60;
        endH = currH + needH;
        endM = currM + needM;
        if (endM &gt;= 60){
            endM = endM - 60;
            endH++;
        }
        if (endH &gt;= 24)
            endH = endH - 24;
        Console.WriteLine($"{endH} {endM}");
    }
}</code></pre>

<p>조리시간을 시간과 분으로 구분할 때 분은 몫으로 계산하면 간략하게 표현할 수 있다.</p>

<h2>Python</h2>
<pre class="python"><code>inputFirst = input();
inputSecond = input();
arrInputFirst = inputFirst.split(' ');
currH = int(arrInputFirst[0]);
currM = int(arrInputFirst[1]);
needM = int(inputSecond);
needH = needM // 60;
needM = needM % 60;
endH = currH + needH;
endM = currM + needM;
if endM &gt;= 60:
    endM -= 60
    endH += 1
if endH &gt;= 24:
    endH -= 24
print(endH, endM)</code></pre>

<p>파이썬 사용 시 정수 나눗셈에 유의한다. '//'</p>
<p>그리고 증감 연산자 '++' , '--'는 사용하지 못한다.</p>

<h2>Node.js</h2>
<pre class="javascript"><code>const readline = require('readline');
const rl = readline.createInterface({
    input : process.stdin,
    output : process.stdout
});
rl.question('', (answer_first)=&gt;{
    const [currH, currM] = answer_first.split(' ').map(Number);
    rl.question('', (answer_second)=&gt;{
        let needM = parseInt(answer_second);
        let needH = Math.floor(needM / 60);
        needM = needM % 60;
        let endH = currH + needH;
        let endM = currM + needM;
        if (endM &gt;= 60){
            endM -= 60;
            endH++;
        }
        if (endH &gt;= 24){
            endH -= 24;
        }
        console.log(`${endH} ${endM}`);
        rl.close();
    });
});</code></pre>

<p>endH의 초기값을 구할 때 Math.floor를 사용해서 정수값을 구한다.</p>
