---
title: "백준 코딩테스트 #14. 반복문 (4, 5)"
excerpt: "백준 코딩테스트 #14. 반복문 (4, 5)"
categories:
  - CodingTest
permalink: /coding/coding-test/132-sharp14-4-5/
tags:
  - "Coding Test"
  - "Baekjoon"
  - "C#"
  - "c+="
  - "node.js"
  - "Python"
  - "백준"
  - "코딩 테스트"
toc: true
toc_sticky: true
date: 2024-07-31
last_modified_at: 2024-07-31
source_url: https://b-note.tistory.com/132
---

<h2>4번 영수증</h2>
<p><b>문제</b></p>
<p>준원이는&nbsp;저번&nbsp;주에&nbsp;살면서&nbsp;처음으로&nbsp;코스트코를&nbsp;가&nbsp;봤다.&nbsp;정말&nbsp;멋졌다.&nbsp;그런데,&nbsp;몇&nbsp;개&nbsp;담지도&nbsp;않았는데&nbsp;수상하게&nbsp;높은&nbsp;금액이&nbsp;나오는&nbsp;것이다!&nbsp;준원이는&nbsp;영수증을&nbsp;보면서&nbsp;정확하게&nbsp;계산된&nbsp;것이&nbsp;맞는지&nbsp;확인해보려&nbsp;한다.&nbsp;</p>
<p>영수증에&nbsp;적힌,&nbsp;</p>

<p>- 구매한 각 물건의 가격과 개수</p>
<p>- 구매한 물건들의 총금액</p>

<p>을 보고, 구매한 물건의 가격과 개수로 계산한 총금액이 영수증에 적힌 총금액과 일치하는지 검사해 보자.</p>

<p><b>입력</b></p>
<p>첫째 줄에는 영수증에 적힌 총금액 X가 주어진다.&nbsp;</p>
<p>둘째 줄에는 영수증에 적힌 구매한 물건의 종류의 수 N이 주어진다.&nbsp;</p>
<p>이후 N개의 줄에는 각 물건의 가격 a와 개수 b가 공백을 사이에 두고 주어진다.</p>

<p><b>출력</b></p>
<p>구매한&nbsp;물건의&nbsp;가격과&nbsp;개수로&nbsp;계산한&nbsp;총금액이&nbsp;영수증에&nbsp;적힌&nbsp;총금액과&nbsp;일치하면&nbsp;Yes를&nbsp;출력한다.&nbsp;일치하지&nbsp;않는다면&nbsp;No를&nbsp;출력한다.</p>

<p><b>제한</b></p>
<p>- 1 &le; X &le; 1,000,000,000</p>
<p>- 1 &le; N &le; 100</p>
<p>- 1 &le; a &le; 1,000,000</p>
<p>- 1 &le; b &le; 10</p>

<p>첫째 입력 영수증에 적힌 총금액 X,&nbsp;</p>
<p>두 번째 입력 물건의 종류의 수 N,</p>
<p>이후 각 물건의 가격 a, 개수 b 입력된다.</p>

<p>N번 반복문을 돌려서 각 물건의 개수와 가격을 합산하여 X와 비교하여 Yes 또는 No를 출력하면 된다.</p>

<h3>C++</h3>
<pre class="cpp"><code>#include &lt;iostream&gt;
using namespace std;
int main(){
    int total_price;
    int total_count;
    int result = 0;
    cin &gt;&gt; total_price &gt;&gt; total_count;
    for (int i = 0; i &lt; total_count; i++){
        int a, b;
        cin &gt;&gt; a &gt;&gt; b;
        result += a * b;
    }
    if (total_price == result){
        cout &lt;&lt; "Yes";
    }
    else cout &lt;&lt; "No";
    return 0;
}</code></pre>

<p>result 변수 += 연산자 사용 전 값 초기화 필요</p>

<h3>C#</h3>
<pre class="csharp"><code>using System;
class Program{
    static void Main(string[] args){
        int total_price = int.Parse(Console.ReadLine());
        int total_count = int.Parse(Console.ReadLine());
        int result = 0;
        for (int i = 0; i &lt; total_count; i++){
            string input = Console.ReadLine();
            string[] arr = input.Split(' ');
            int a = int.Parse(arr[0]);
            int b = int.Parse(arr[1]);
            result += a * b;
        }
        if (result == total_price){
            Console.WriteLine("Yes");
        }
        else{
            Console.WriteLine("No");
        }
    }
}</code></pre>

<h3>Python</h3>
<pre class="python"><code>total_price = int(input())
total_count = int(input())
result = 0;
for i in range(total_count):
    str = input()
    arr = str.split(' ')
    a = int(arr[0])
    b = int(arr[1])
    result += a * b
if result == total_price:
    print("Yes")
else:
    print("No")</code></pre>

<h3>Node.js</h3>
<pre class="javascript"><code>const readline = require('readline');
const rl = readline.createInterface({
    input : process.stdin,
    output : process.stdout
});
let input = [];
let result = 0;
rl.on('line', (line) =&gt; {
    input.push(line);
}).on('close', () =&gt; {
    const total_price = parseInt(input[0]);
    const total_count = parseInt(input[1]);
    for(let i = 2; i &lt; total_count + 2; i++){
        const[a,b] = input[i].split(' ').map(Number);
        result += a * b;
    }
    if (result === total_price){
        console.log("Yes");
    }else{
        console.log("No");
    }
});</code></pre>

<p>모든 입력을 저장하고 인덱스로 끊어서 처리한다.</p>

<p>여기서 루프는 처음과 두 번째 값으로 2부터 시작하기 때문에 total_count +&nbsp; 2를 해주어야 전체 값을 처리할 수 있다.</p>

<h2>5번 코딩은 체육과목입니다.</h2>
<p><b>문제</b></p>
<p>오늘은&nbsp;혜나의&nbsp;면접&nbsp;날이다.&nbsp;면접&nbsp;준비를&nbsp;열심히&nbsp;해서&nbsp;앞선&nbsp;질문들을&nbsp;잘&nbsp;대답한&nbsp;혜아는&nbsp;이제&nbsp;마지막으로&nbsp;칠판에&nbsp;직접&nbsp;코딩하는&nbsp;문제를&nbsp;받았다.&nbsp;</p>

<p>혜아가&nbsp;받은&nbsp;문제는&nbsp;두&nbsp;수를&nbsp;더하는&nbsp;문제였다.&nbsp;C++&nbsp;책을&nbsp;열심히&nbsp;읽었던&nbsp;혜아는&nbsp;간단히&nbsp;두&nbsp;수를&nbsp;더하는&nbsp;코드를&nbsp;칠판에&nbsp;적었다.&nbsp;코드를&nbsp;본&nbsp;면접관은&nbsp;다음&nbsp;질문을&nbsp;했다.&nbsp;</p>

<p>&ldquo;만약,&nbsp;입출력이&nbsp;$N$바이트&nbsp;크기의&nbsp;정수라면&nbsp;프로그램을&nbsp;어떻게&nbsp;구현해야&nbsp;할까요?&rdquo;&nbsp;</p>

<p>혜아는 책에 있는 정수 자료형과 관련된 내용을 기억해 냈다. 책에는 long int는 4바이트 정수까지 저장할 수 있는 정수 자료형이고 long long int는 8바이트 정수까지 저장할 수 있는 정수 자료형이라고 적혀 있었다.</p>

<p>혜아는 이런 생각이 들었다. &ldquo;int 앞에 long을 하나씩 더 붙일 때마다 4바이트씩 저장할 수 있는 공간이 늘어나는 걸까? 분명 long long long int는 12바이트, long long long long int는 16바이트까지 저장할 수 있는 정수 자료형일 거야!&rdquo; 그렇게 혜아는 당황하는 면접관의 얼굴을 뒤로한 채 칠판에 정수 자료형을 써 내려가기 시작했다. 혜아가 N바이트 정수까지 저장할 수 있다고 생각해서 칠판에 쓴 정수 자료형의 이름은 무엇일까?</p>

<p><b>입력</b></p>
<p>첫 번째 줄에는 문제의 정수 N이 주어진다. (4 <span style="text-align: start">&le;<span> </span></span>N <span style="text-align: start">&le;<span>&nbsp;</span></span> 1, 000; N은 4의 배수)</p>

<p><b>출력</b></p>
<p>혜아가 N바이트 정수까지 저장할 수 있다고 생각하는 정수 자료형의 이름을 출력하여라.</p>

<p>일리가 있는 생각이다. 혜아는 long이 붙을 때마다 4바이트씩 늘어난다고 생각하여 N바이트를 저장하려면 N/4 * long을 사용하면 N 바이트를 저장할 수 있을 것이라도 추론했다.</p>

<p>여기서 N%4가 0이 아니면 N/4 + 1을 해주어야 할 것이지만 N은 4의 배수라고 하니 따로 처리할 필요는 없을 것 같다.</p>

<p>물론 실제로는 long long int 까지만 존재하며 그 이상의 크기의 정수를 사용하기 위해서는 __int128_t 또는 gmp 같은 라이브러리를 사용해야 한다. __int128_t는 128비트 정수 자료형으로 16바이트 즉, long long long long int 만큼의 정수를 사용할 수 있다. gmp는 임의 정밀도 연산을 지원하는 라이브러리로 이론적으로 메모리가 허용하는 한 무한히 큰 숫자를 저장할 수 있다.</p>
<p>__int128_t는 &lt;stdint&gt; gmp는 &lt;gmp.h&gt;</p>

<h3>C++</h3>
<pre class="cpp"><code>#include &lt;iostream&gt;
#include &lt;string&gt;
using namespace std;
int main(){
    int n;
    cin &gt;&gt; n;
    int count = n/4;
    string result;
    for (int i = 0; i &lt; count; i++){
        result += "long ";
    }
    result += "int";
    cout &lt;&lt; result;
    return 0;
}</code></pre>

<h3>C#</h3>
<pre class="csharp"><code>using System;
class Program{
    static void Main(string[] args){
        int n = int.Parse(Console.ReadLine());
        string result = "";
        int count = n / 4;
        for (int i = 0; i &lt; count; i++){
            result += "long ";
        }
        result += "int";
        Console.WriteLine(result);
    }
}</code></pre>

<p>C++의 경우 string 선언 시 빈 문자열로 초기화가 되지만 C#은 null로 초기화되기 때문에 바로 += 연산을 사용하기 위해서는 빈문자열로 초기화해 주는 게 필요하다.</p>

<h3>Python</h3>
<pre class="python"><code>n = int(input())
result = "";
for i in range(n//4):
    result += "long "
result += "int"
print(result)</code></pre>

<p>몫을 정확히 구하기 위해서 // 을 사용해야 한다.</p>

<h3>Node.js</h3>
<pre class="javascript"><code>const readline = require('readline');
const rl = readline.createInterface({
    input : process.stdin,
    output : process.stdout
});
rl.question('', (answer)=&gt;{
    const n = parseInt(answer);
    let result = "";
    for (let i = 0; i &lt; n / 4; i++){
        result += "long ";
    }
    result += "int";
    console.log(result);
    rl.close();
});</code></pre>

<p>자바스크립트에서 습관적으로 for 문의 변수를 int로 선언하게 되는데 let으로 써야 하는 걸 유의한다.</p>
