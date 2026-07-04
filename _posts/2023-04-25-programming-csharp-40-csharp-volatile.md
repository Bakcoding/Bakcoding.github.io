---
title: "C# 변수 동기화 키워드 : volatile"
excerpt: "C# 변수 동기화 키워드 : volatile"
categories:
  - CSharp
permalink: /programming/csharp/40-csharp-volatile/
tags:
  - "CSharp"
  - "C#"
  - "keyword"
  - "volatile"
toc: true
toc_sticky: true
date: 2023-04-25
last_modified_at: 2023-04-25
source_url: https://b-note.tistory.com/40
---

<h3>volatile</h3>
<p>변수의 값을 캐시에 저장하지 않고 항상 메모리에서 값을 읽어오도록 한다.</p>
<p>멀티 스레딩 환경에서 여러 스레드가 동시에 하나의 변수에 접근할 때 캐시에 저장된 값과 메모리의 실제 값이 일치하지 않아서 오류가 발생할 수 있다.</p>

<pre class="csharp"><code>int counter = 0;

void IncrementCounter()
{
    for (int i = 0; i &lt; 100000; i++)
    {
        counter++;
    }
}

void DecrementCounter()
{
    for (int i = 0; i &lt; 100000; i++)
    {
        counter--;
    }
}

void Main()
{
    Thread t1 = new Thread(IncrementCounter);
    Thread t2 = new Thread(DecrementCounter);

    t1.Start();
    t2.Start();

    t1.Join();
    t2.Join();

    Console.WriteLine("Counter value: " + counter);
}</code></pre>

<p>위 코드에서 counter변수에 서로 다른 스레드에서 거의 동시에 접근하여 값을 변경하고 있다.</p>
<p>이때 counter는 항상 0이 아니며 일정하지 않은 값들로 출력된다.</p>

<p>이러한 상황에서 volatile 키워드로 변수를 선언하면 항상 일정한 값이 들어오게 된다.</p>

<pre class="csharp"><code>int volatile counter = 0;</code></pre>
