---
title: "백준 코딩테스트 #13. 반복문 (1 ~ 3)"
excerpt: "백준 코딩테스트 #13. 반복문 (1 ~ 3)"
categories:
  - CodingTest
permalink: /coding/coding-test/131-sharp13-1-3/
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
date: 2024-07-29
last_modified_at: 2024-07-29
source_url: https://b-note.tistory.com/131
---

<h2>1번 구구단</h2>
<p><b>문제</b></p>
<p>N을&nbsp;입력받은&nbsp;뒤,&nbsp;구구단&nbsp;N단을&nbsp;출력하는&nbsp;프로그램을&nbsp;작성하시오.&nbsp;출력&nbsp;형식에&nbsp;맞춰서&nbsp;출력하면&nbsp;된다.</p>

<p><b>입력</b></p>
<p>첫째&nbsp;줄에&nbsp;N이&nbsp;주어진다.&nbsp;N은&nbsp;1보다&nbsp;크거나&nbsp;같고,&nbsp;9보다&nbsp;작거나&nbsp;같다.</p>

<p><b>출력</b></p>
<p>출력형식과&nbsp;같게&nbsp;N*1부터&nbsp;N*9까지&nbsp;출력한다.</p>

<p>반복문을 사용하는 문제가 시작되었다. 입력받은 N 값을 1부터 9까지 차례로 곱하고 결과를 출력한다.</p>

<p>출력 형식은&nbsp;</p>
<p>n * 1 = n</p>
<p>n * 2 = 2n&nbsp;</p>
<p>...</p>
<p>n* 9 = 9n</p>
<h3>C++</h3>
<pre class="cpp"><code>#include &lt;iostream&gt;
using namespace std;
int main(){
    int n;
    cin &gt;&gt; n;
    for(int i = 1; i &lt; 10; i++){
        cout &lt;&lt; n &lt;&lt; " * " &lt;&lt; i &lt;&lt; " = "&lt;&lt; n * i &lt;&lt; endl;
    }
    return 0;
}</code></pre>

<p><span style="text-align: start"><span>&nbsp;</span>띄어쓰기와 줄 바꿈</span> 등 출력 형식에 주의한다.</p>

<h3>C#</h3>
<pre class="csharp"><code>using System;
class Program{
    static void Main(string[] args){
        string input = Console.ReadLine();
        int n = int.Parse(input);
        for (int i = 1; i &lt; 10; i++){
            int result = n * i;
            Console.WriteLine($"{n} * {i} = {result}");
        }
    }
}</code></pre>

<h3>Python</h3>
<pre class="python"><code>inputStr = input()
n = int(inputStr);
for i in range(1, 10):
    print(f"{n} * {i} = {n*i}");</code></pre>

<p>파이썬의 반복문 for i in range()를 사용한다.&nbsp;</p>
<p>range는 i의 범위로 range(1, 10) 은 i는 1부터 i &lt; 10까지 증가하면서 반복된다.</p>

<h3>Node.js</h3>
<pre class="javascript"><code>const readline = require('readline');
const rl = readline.createInterface({
    input : process.stdin,
    output : process.stdout
});
rl.question('', (answer)=&gt;{
   let n = parseInt(answer);
    for(let i = 1; i &lt; 10; i++){
        console.log(`${n} * ${i} = ${n*i}`);
    }
    rl.close();
});</code></pre>

<p>템플릿 리터럴 사용 숙지하기 `` 백틱 내부에서 변수는 ${var}로 문자열과 혼합 표기하면 된다.</p>
<p>반복문에서 i 선언 시 let을 사용해야 한다.</p>

<h2>2번 A+B-3</h2>
<p><b>문제</b></p>
<p>두&nbsp;정수&nbsp;A와&nbsp;B를&nbsp;입력받은&nbsp;다음,&nbsp;A+B를&nbsp;출력하는&nbsp;프로그램을&nbsp;작성하시오.</p>

<p><b>입력</b></p>
<p>첫째&nbsp;줄에&nbsp;테스트&nbsp;케이스의&nbsp;개수&nbsp;T가&nbsp;주어진다.&nbsp;각&nbsp;테스트&nbsp;케이스는&nbsp;한&nbsp;줄로&nbsp;이루어져&nbsp;있으며,&nbsp;각&nbsp;줄에&nbsp;A와&nbsp;B가&nbsp;주어진다.&nbsp;(0&nbsp;&lt;&nbsp;A,&nbsp;B&nbsp;&lt;&nbsp;10)</p>

<p><b>출력</b></p>
<p>각&nbsp;테스트&nbsp;케이스마다&nbsp;A+B를&nbsp;출력한다.</p>

<p>처음 입력은 반복 횟수, 다음 줄부터는 A, B의 입력이 한 줄씩 묶어서 여러 묶음이 들어온다.</p>

<p>배열과 반복문을 잘 사용해야 할 것 같다. 그런데 제목에는 -3이 있는데 문제와 상관이 없어 보인다.</p>

<h3>C++</h3>
<pre class="cpp"><code>#include &lt;iostream&gt;
using namespace std;
int main(){
    int count;
    cin &gt;&gt; count;
    for (int i = 0; i &lt; count; i++){
        int a, b;
        cin &gt;&gt; a &gt;&gt; b;
        cout &lt;&lt; a + b &lt;&lt; endl;
    }
    return 0;
}</code></pre>

<p>입력받은 값만큼 반복을 한다.</p>

<p>반복할 때마다 두 번의 입력을 처리해서 출력하고 다음 루프를 진행한다.</p>

<h3>C#</h3>
<pre class="csharp"><code>using System;
class Program{
    static void Main(string[] args){
        int count = int.Parse(Console.ReadLine());
        for (int i = 0; i &lt; count; i++){
            string input = Console.ReadLine();
            string[] inputArr = input.Split(' ');
            int a = int.Parse(inputArr[0]);
            int b = int.Parse(inputArr[1]);
            Console.WriteLine(a+b);
        }
    }
}</code></pre>

<p>문제에서 입력이 한 줄씩 들어온다는 점과 Console.ReadLine이 한 줄씩 처리한다는 걸 이해하면 간단하다.</p>

<p>이 방법은 반복 횟수가 확정되어 있기 때문에 가능하며 각 줄을 입력받고 연산해서 출력하고 다음 줄로 넘어가는 방식이다.</p>

<h3>Python</h3>
<pre class="python"><code>count = int(input())
for i in range(count):
    inputStr = input()
    arr = inputStr.split(' ')
    a = int(arr[0])
    b = int(arr[1])
    print(f"{a + b}")</code></pre>

<p>range에 인수를 하나만 넣으면 i = 0부터 시작해서 &lt; count까지 반복한다.</p>

<p>input은 문자열이기 때문에 int로 변환해 주는 걸 유의한다.</p>

<p><span style="color: var(--bc-emphasis-danger)"><b>오답</b></span></p>
<pre class="javascript"><code>const readline = require('readline');
const rl = readline.createInterface({
    input : process.stdin,
    output : process.stdout
});
rl.question('', (answerCount)=&gt;{
   const count = parseInt(answerCount);
    for (let i = 0; i &lt; count; i++){
        rl.question('', (case)=&gt;{
           const [a, b] = case.split(' ').map(Number);
            console.log(a + b);
        });
    };
    rl.close();
});</code></pre>

<p>rl.question 은 비동기 함수라서 반복문 안에서 이를 실행시키면 각 케이스가 독립적으로 처리되지 않기 때문에 위 코드는 제대로 동작하지 않는다.</p>

<p>그리고 case는 이미 사용 중인 키워드이기 때문에 이름을 다른 걸 써야 한다.</p>

<pre class="javascript"><code>const readline = require('readline');
const rl = readline.createInterface({
    input : process.stdin,
    output : process.stdout
});
rl.question('', (answerCount)=&gt;{
    const count = parseInt(answerCount);
    const results = [];
    let index = 0;
    const ask = ()=&gt;{
        if (index &lt; count){
            rl.question('', (caseInput) =&gt;{
                const [a, b] = caseInput.split(' ').map(Number);
                results.push(a+b);
                index++;
                ask();
            });
        } else{
            results.forEach(result=&gt; console.log(result));
            rl.close();
        }
    };
    ask();
});</code></pre>

<p>오답 코드를 개선하여 한 번에 하나씩 케이스를 처리하고, 모든 질문이 완료되면 question을 종료하고 결과를 출력한다.</p>

<p>ask 메서드를 변수로 선언하여 각 케이스마다 처리한 결과를 results에 저장해 두고 이 함수를 재귀적으로 호출한다.</p>

<p>count까지의 횟수를 체크하기 위해서 index를 사용하여 현재 진행된 반복 횟수를 체크하고 모든 반복이 끝났을 때 저장해 둔 results의 요소들을 모두 출력한다.</p>

<p>그리고 이 동작을 실행시키기 위해서 한 번 ask를 실행시켜주어야 한다.</p>

<p>더 간단한 방법을 찾아보니 process.stdin을 활용하면 전체 입력을 한 번에 읽고 처리할 수 있는 방법이 있었다.</p>

<pre class="javascript"><code>const readline = require('readline');
const rl = readline.createInterface({
    input : process.stdin,
    output : process.stdout
});

let input = [];
rl.on('line', (line)=&gt;{
    input.push(line);
}).on('close', () =&gt; {
    const count = parseInt(input[0]);
    for (let i = 1; i &lt;= count; i++){
        const [a, b] = input[i].split(' ').map(Number);
        console.log(a + b);
    }
    process.exit(0);
});</code></pre>

<p>input 배열을 선언하고</p>

<p>rl.on('line; ~&nbsp; 각 줄을 입력받을 때마다 input에 저장한다.</p>

<p>rl.on('close' ~ 입력이 종료되면 반복문으로 input에 저장된 값들을 처리한다.</p>

<p>처음 입력 값인 count 만큼 반복을 실행하며 이를 제외한 i = 1부터 인덱스를 순회한다.</p>

<p>1부터 시작되는 input 에는 케이스들이 저장되어 있기 때문에 이 요소를 공백으로 구분하고 맵으로 만들어서 출력해 주면 된다.</p>

<p>앞서 풀었던 문제들도 이렇게 풀면 더 간단했던 문제도 있던 거 같았는데 이번에 이 기능들을 제대로 파악하고 가야겠다.</p>

<h2>3번 합</h2>
<p><b>문제</b></p>
<p>n이&nbsp;주어졌을&nbsp;때,&nbsp;1부터&nbsp;n까지&nbsp;합을&nbsp;구하는&nbsp;프로그램을&nbsp;작성하시오.</p>

<p><b>입력&nbsp;</b></p>
<p>첫째&nbsp;줄에&nbsp;n&nbsp;(1&nbsp;&le;&nbsp;n&nbsp;&le;&nbsp;10,000)이&nbsp;주어진다.</p>

<p><b>출력</b></p>
<p>1부터&nbsp;n까지&nbsp;합을&nbsp;출력한다.</p>

<p>n까지의 합계를 구하는 문제이다.</p>

<p>수학 공식을 활용하면 간단하게 n * (n + 1) / 2의 결과와 동일하다.</p>

<h3>C++</h3>
<pre class="cpp"><code>#include &lt;iostream&gt;
using namespace std;
int main(){
    int n;
    cin &gt;&gt; n;
    int result = 0;
    for (int i = 1; i &lt;= n; i++){
        result += i;
    }
    cout &lt;&lt; result;
    return 0;
}</code></pre>

<p>먼저 문제의 주제에 맞게 반복문을 사용하여 처리해 본다.</p>

<p>수학 공식으로 처리해도 동일한 결과라는 것을 확인한다.</p>

<pre class="cpp"><code>#include &lt;iostream&gt;
using namespace std;
int main(){
    int n;
    cin &gt;&gt; n;
    int result = n * (n + 1) / 2;
    cout &lt;&lt; result;
    return 0;
}</code></pre>

<p>반복문 챕터이기 때문에 공식은 아껴두고 반복문으로만 풀어보도록 한다.</p>

<h3>C#</h3>
<pre class="csharp"><code>using System;
class Program{
    static void Main(string[] args){
        int n = int.Parse(Console.ReadLine());
        int result = 0;
        for (int i = 1; i &lt;= n; i++){
            result += i;
        }
        Console.WriteLine(result);
    }
}</code></pre>

<h3>Python</h3>
<pre class="python"><code>n = int(input())
result = 0
for i in range(1, n+1):
    result += i
print(result);</code></pre>

<h3>Node.js</h3>
<pre class="javascript"><code>const fs = require('fs');
const n = parseInt(fs.readFileSync('dev/stdin').toString().trim());
let result = 0;
for (let i = 1; i &lt;= n; i++){
    result += i;
}
console.log(result);</code></pre>
