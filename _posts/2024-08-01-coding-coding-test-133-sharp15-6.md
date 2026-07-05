---
title: "백준 코딩테스트 #15. 반복문 6"
excerpt: "백준 코딩테스트 #15. 반복문 6"
categories:
  - CodingTest
permalink: /coding/coding-test/133-sharp15-6/
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
date: 2024-08-01
last_modified_at: 2024-08-01
source_url: https://b-note.tistory.com/133
---

<h2>6번 빠른 A+B</h2>
<p><b>문제</b></p>
<p>본격적으로&nbsp;for문&nbsp;문제를&nbsp;풀기&nbsp;전에&nbsp;주의해야&nbsp;할&nbsp;점이&nbsp;있다.&nbsp;입출력&nbsp;방식이&nbsp;느리면&nbsp;여러&nbsp;줄을&nbsp;입력받거나&nbsp;출력할&nbsp;때&nbsp;시간초과가&nbsp;날&nbsp;수&nbsp;있다는&nbsp;점이다.&nbsp;</p>

<p>C++을&nbsp;사용하고&nbsp;있고&nbsp;cin/cout을&nbsp;사용하고자&nbsp;한다면,&nbsp;cin.tie(NULL)과&nbsp;sync_with_stdio(false)를&nbsp;둘&nbsp;다&nbsp;적용해&nbsp;주고,&nbsp;endl&nbsp;대신&nbsp;개행문자(\n)를&nbsp;쓰자.&nbsp;단,&nbsp;이렇게&nbsp;하면&nbsp;더&nbsp;이상&nbsp;scanf/printf/puts/getchar/putchar&nbsp;등&nbsp;C의&nbsp;입출력&nbsp;방식을&nbsp;사용하면&nbsp;안&nbsp;된다.&nbsp;</p>

<p>Java를&nbsp;사용하고&nbsp;있다면,&nbsp;Scanner와&nbsp;System.out.println&nbsp;대신&nbsp;BufferedReader와&nbsp;BufferedWriter를&nbsp;사용할&nbsp;수&nbsp;있다.&nbsp;BufferedWriter.flush는&nbsp;맨&nbsp;마지막에&nbsp;한&nbsp;번만&nbsp;하면&nbsp;된다.&nbsp;</p>

<p>Python을&nbsp;사용하고&nbsp;있다면,&nbsp;input&nbsp;대신&nbsp;sys.stdin.readline을&nbsp;사용할&nbsp;수&nbsp;있다.&nbsp;단,&nbsp;이때는&nbsp;맨&nbsp;끝의&nbsp;개행문자까지&nbsp;같이&nbsp;입력받기&nbsp;때문에&nbsp;문자열을&nbsp;저장하고&nbsp;싶을&nbsp;경우. rstrip()을&nbsp;추가로&nbsp;해&nbsp;주는&nbsp;것이&nbsp;좋다.&nbsp;</p>

<p>또한&nbsp;입력과&nbsp;출력&nbsp;스트림은&nbsp;별개이므로,&nbsp;테스트케이스를&nbsp;전부&nbsp;입력받아서&nbsp;저장한&nbsp;뒤&nbsp;전부&nbsp;출력할&nbsp;필요는&nbsp;없다.&nbsp;테스트케이스를&nbsp;하나&nbsp;받은&nbsp;뒤&nbsp;하나&nbsp;출력해도&nbsp;된다.&nbsp;자세한&nbsp;설명&nbsp;및&nbsp;다른&nbsp;언어의&nbsp;경우는&nbsp;<a href="https://docs.google.com/document/d/17OUl9nU9i7vTkhk2q_qy4Q5Vl0HHE9bTLUHwbLp56WM/edit#heading=h.mwvd9fqamd6" target="_blank" rel="noopener">이&nbsp;글</a>에&nbsp;설명되어&nbsp;있다.&nbsp;<a href="https://www.acmicpc.net/blog/view/55" target="_blank" rel="noopener">이&nbsp;블로그&nbsp;글</a>에서&nbsp;BOJ의&nbsp;기타&nbsp;여러&nbsp;가지&nbsp;팁을&nbsp;볼&nbsp;수&nbsp;있다.</p>

<p><b>입력</b></p>
<p>첫&nbsp;줄에&nbsp;테스트케이스의&nbsp;개수&nbsp;T가&nbsp;주어진다.&nbsp;T는&nbsp;최대&nbsp;1,000,000이다.&nbsp;다음&nbsp;T 줄에는&nbsp;각각&nbsp;두&nbsp;정수&nbsp;A와&nbsp;B가&nbsp;주어진다.&nbsp;A와&nbsp;B는&nbsp;1&nbsp;이상,&nbsp;1,000&nbsp;이하이다.</p>

<p><b>출력</b></p>
<p>각&nbsp;테스트케이스마다&nbsp;A+B를&nbsp;한&nbsp;줄에&nbsp;하나씩&nbsp;순서대로&nbsp;출력한다.</p>

<p>입출력 시 발생할 수 있는 문제를 해결하여 테스트케이스를 통과해야 하는 문제이다.</p>
<p>친절하게 문제에서 해결방법을 제시해 주었기 때문에 위 방법들을 고려하여 테스트케이스를 통과해 본다.</p>

<h3>C++</h3>
<p><span style="color: var(--bc-emphasis-danger)"><b>오답</b></span></p>
<pre class="cpp"><code>#include &lt;iostream&gt;
using namespace std;
int main(){
    int t;
    cin &gt;&gt; t;
    for (int i = 0; i &lt; t; i++){
        int a, b;
        cin &gt;&gt; a &gt;&gt; b;
        cout &lt;&lt; a + b &lt;&lt; "\n";
    }
    return 0;
}</code></pre>

<p>확인을 위해 제시된 방법을 사용하지 않고 코드를 작성하여 테스트해 보니 '시간 초과' 결과가 나타난다.</p>

<p>위 방법들을 사용해서 다시 풀어본다.</p>

<pre class="cpp"><code>#include &lt;iostream&gt;
using namespace std;
int main(){
    int t;
    cin.tie(NULL);
    ios_base::sync_with_stdio(false);
    cin &gt;&gt; t;
    for (int i = 0; i &lt; t; i++){
        int a, b;
        cin &gt;&gt; a &gt;&gt; b;
        cout &lt;&lt; a + b &lt;&lt; "\n";
    }
    return 0;
}</code></pre>

<p>cin.tie(NULL)은 cin과 cout의 묶음을 풀어주는 기능을 한다.</p>
<p>기본적으로 cin으로 읽을 때 먼저 출력 버퍼를 비우는 작업이 먼저 처리되는데 이 작업을 통해서 출력이 즉시 화면에 표시되도록 한다. 하지만 이렇게 수만 번의 입력과 출력이 반복해서 처리되는 작업에서는 출력 버퍼를 비우는 작업은 고려하지 않아도 되기 때문에 테스트 케이스를 통과하기 위해서는 이런 부가적인 작업이 발생하지 않도록 해야 타임오버가 되지 않는다.</p>

<p>ios_base::sync_with_stdio(false)는 C와 C++의 버퍼를 분리한다.</p>
<p>C++은 C의 기능을 포함하고 있으므로 cin과 cout 사용 시 C의 입출력 라이브러리인 stdin, stdout과 연결된 스트림 객체 상태이다. 따라서 sync_with_stdio(false)를 선언하면 cin/cout은 더 이상 stdin/stdout과 동기화되지 않기 때문에 C++의 스트림 입출력 성능이 향상될 수 있지만 비활성화된 상태에서는 C의 scanf, printf와 함께 사용 시에는 문제가 발생한다.</p>

<p>개행문자 endl 은 줄 바꿈을 출력할 뿐만 아니라 출력 버퍼를 비우는 역할까지 하기 때문에 이 작업 역시 테스트케이스를 실행하게 되면 속도를 느리게 하기 때문에 단순 줄 바꿈만 하는 \n 개행문자를 사용하는 것이 속도측면에서 유리하다.</p>

<h3>C#</h3>
<p>C#의 경우 문제에서 해결방법이 제시되지 않아서 추가 정보글의 설명을 먼저 읽어 보았다.</p>
<p>Console.Write, WriteLine은 사용할 때마다 화면으로 내보내는 작업인 flush(C++의 출력버퍼를 비우는 작업)이 발생하는데 해결 방법으로는 StringBuilder에 출력할 내용을 모아둔 뒤 한 번에 출력하거나 auto flush를 하지 않는 output stream을 Console에 연결하는 방법이 있다.</p>

<p><b>StringBuilder</b></p>
<pre class="csharp"><code>using System;
using System.Text;
class Program{
    static void Main(string[] args){
        StringBuilder sb = new StringBuilder();
        int t = int.Parse(Console.ReadLine());
        for (int i = 0; i &lt; t; i++){
            int a, b;
            string input = Console.ReadLine();
            string[] arr = input.Split(' ');
            a = int.Parse(arr[0]);
            b = int.Parse(arr[1]);
            sb.AppendLine((a+b).ToString());
        }
        Console.WriteLine(sb.ToString());
    }
}</code></pre>

<p>StringBuilder를 사용해서 문자열을 저장하고 한 번에 출력하여 flush로 인한 속도 저하를 방지한다. string이 아닌 StringBuilder를 사용하는 이유는 문자열 연결 작업에서 불변 특성을 가지기 때문에 더 효율적인 처리가 가능하고 string의 문자열을 추가하는 + 연산 작업은 새로운 문자열 객체가 생성되고 이 과정에서 메모리 사용량과 실행 시간이 증가할 수 있다.</p>

<p>Append : 문자열만 추가한다.</p>
<p>AppendLine : 문자열 추가하고 줄 바꿈 문자를 자동으로 추가한다.</p>
<p>AppendFormat : 형식 문자열을 추가한다.</p>

<p><b>output stream</b></p>
<pre class="csharp"><code>using System;
class Program{
    static void Main(string[] args){
        int t = int.Parse(Console.ReadLine());
        Console.SetOut(new StreamWriter(Console.OpenStandardOutput()));
        for (int i = 0; i &lt; t; i++){
            int a, b;
            string input = Console.ReadLine();
            string[] arr = input.Split(' ');
            a = int.Parse(arr[0]);
            b = int.Parse(arr[1]);
            Console.WriteLine(a + b);
        }
        Console.Out.Flush();
    }
}</code></pre>

<p>출력 전 자동으로 flush 하는 기능을 비활성화한다. 이 기능을 사용하고 나서 코드 종료 전에 출력 버퍼를 지우는 Flush()를 호출해 주어야 한다.</p>

<p><b>추가로 StreamReader와 StreamWriter를 사용하는 방법</b></p>
<pre class="csharp"><code>using System;
using System.IO;

class Program {
    private const int bufferSize = 131072;
    public static readonly StreamReader input = new(new BufferedStream(Console.OpenStandardInput(), bufferSize));
    public static readonly StreamWriter output = new(new BufferedStream(Console.OpenStandardOutput(), bufferSize));

    static void Main(string[] args) {
        int t = int.Parse(input.ReadLine());

        for (int i = 0; i &lt; t; i++) {
            string[] arr = input.ReadLine().Split(' ');
            int a = int.Parse(arr[0]);
            int b = int.Parse(arr[1]);
            output.WriteLine(a + b);
        }
        output.Flush();
    }
}</code></pre>

<p>input과 output을 구현하여 처리한다.</p>
<p>마찬가지로 코드가 종료되기 전에 출력버퍼를 비워준다.</p>

<h3>Python</h3>
<p>파이썬에서는 입력을 받는 함수인 input 대신 sys.stdin.readline을 사용하면 된다. 이 경우 문자열 끝에 개행문자까지 같이 입력받게 되므로. rstrip()으로 문자열만 저장하도록 한다.</p>
<pre class="python"><code>import sys
t = int(input())
for i in range(t):
    input_str = sys.stdin.readline().rstrip()
    arr = input_str.split(' ');
    a = int(arr[0])
    b = int(arr[1])
    print(a+b)</code></pre>

<p>먼저 sys를 사용하기 위해서 모듈을 임포트 해준다.</p>

<p>입력받은 문자열을 저장할 때 변수명을 str로 사용했었는데 이 키워드는 파이썬에서 내장 타입으로 사용되고 있기 때문에 문제가 되는 걸 방지하기 위해서 input_str로 사용했다.</p>

<p>input을 사용하게 되면 시간초과가 발생한다.&nbsp;</p>
<p>sys.stdin.readline()은 C 표준 라이브러리의 fgets 함수에 가깝게 동작하는데 이는 입력 스트림에서 한 줄을 읽어오고 문자열로 반환한다. 따라서 직접적으로 표준 입력에서 빠르게 읽어오기 때문에 input보다 더 빠른 속도로 처리할 수 있다.</p>

<p>print의 경우 기존 방식을 사용해도 문제가 없다. print 함수는 기본적으로 출력 버퍼링을 사용하긴 하지만 매번 호출할 때마다 버퍼를 flush 하지 않는 게 기본 상태이다. 그리고 이를 수동으로 flush 하도록 변경할 수 있다.</p>
<pre class="python"><code>print("Something print", flush=true)</code></pre>

<h3>Node.js</h3>
<p><b>fs</b></p>
<pre class="javascript"><code>const fs = require('fs');
const input = fs.readFileSync('/dev/stdin', 'utf8').trim().split('\n');
const t = parseInt(input[0], 10);
const output = [];

for (let i = 1; i &lt;= t; i++) {
    const [a, b] = input[i].split(' ').map(Number);
    output.push(a + b);
}

process.stdout.write(output.join('\n'));</code></pre>

<p>반복문에서 출력할 정보를 저장해 놓고 마지막에 한 번에 출력한다.&nbsp;</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="595" data-origin-height="110"><span data-alt="위)console.log"><img src="/assets/images/posts/2024/08/01/133-1.png" loading="lazy" width="595" height="110" data-origin-width="595" data-origin-height="110"/></span><figcaption>위)console.log</figcaption>
</figure>
</p>

<p>이때 console.log를 사용해도 성공했는데 process.stdout.write를 사용하는 게 조금 더 빠르게 처리되었다.</p>


<p><b>readline</b></p>
<pre class="javascript"><code>const readline = require('readline');
const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
});
let input = [];
let lineIndex = 0;
rl.on('line', (line) =&gt; {
    input.push(line);
});
rl.on('close', () =&gt; {
    const t = parseInt(input[lineIndex++], 10);
    let output = [];
    for (let i = 0; i &lt; t; i++) {
        const [a, b] = input[lineIndex++].split(' ').map(Number);
        output.push(a + b);
    }
    process.stdout.write(output.join('\n'));
});</code></pre>

<p>readline 사용한 게 기본적으로 fs보다 느렸다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="594" data-origin-height="96"><span data-alt="아래)console.log"><img src="/assets/images/posts/2024/08/01/133-2.png" loading="lazy" width="594" height="96" data-origin-width="594" data-origin-height="96"/></span><figcaption>아래)console.log</figcaption>
</figure>
</p>

<p>앞으로 문제들은 단순히 해결하는 것뿐만 아니라 더 나은 방법에 대해서도 알 필요가 있는 내용들이 나올듯하다.</p>
