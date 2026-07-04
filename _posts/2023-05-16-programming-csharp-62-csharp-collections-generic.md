---
title: "C# 라이브러리 Collections, Generic"
excerpt: "C# 라이브러리 Collections, Generic"
categories:
  - CSharp
permalink: /programming/csharp/62-csharp-collections-generic/
tags:
  - "CSharp"
  - "arraylist"
  - "C#"
  - "CLASS"
  - "collections"
  - "generic"
  - "library"
  - "list"
toc: true
toc_sticky: true
date: 2023-05-16
last_modified_at: 2023-05-16
source_url: https://b-note.tistory.com/62
---

<h3>Collections</h3>
<p>. Net Framework에서 사용되던 라이브러리이다. Generic 기능이 도입되기 이전에 사용되었으며 Collections의 클래스들은 모든 요소를 object 타입으로 처리하여&nbsp; 요소를 다룰 때에 형변환을 필요로 한다.</p>

<p>대표적의로 ArrayList, Hashtable, sortedList, Stack, Queue 등이 있다.</p>

<h3>Generic</h3>
<p>Collections의 클래스들은 형변환이 필요하기 때문에 잘못된 타입을 사용할 경우 에러가 발생하게 된다.&nbsp;</p>
<p>이 문제를 해결하기 위해서 안정성을 제공하는 새로운 클래스들이 Generic 네임스페이스로 추가되었다.</p>

<p>대표적으로 List, Dictionary, Queue &lt;T&gt;, Stack &lt;T&gt; 등이 있다.</p>


<table style="border-collapse: collapse; width: 100%;" border="1">
<tbody>
<tr>
<td style="width: 50%;"><b>Collections</b></td>
<td style="width: 50%;"><b>Generic</b></td>
</tr>
<tr>
<td style="width: 50%;">ArrayList</td>
<td style="width: 50%;">List&lt;T&gt;</td>
</tr>
<tr>
<td style="width: 50%;">Hashtable</td>
<td style="width: 50%;">Dictionary&lt;TKey, TValue&gt;</td>
</tr>
<tr>
<td style="width: 50%;">Queue</td>
<td style="width: 50%;">Queue&lt;T&gt;</td>
</tr>
<tr>
<td style="width: 50%;">Stack</td>
<td style="width: 50%;">Stack&lt;T&gt;</td>
</tr>
</tbody>
</table>

<h3>Compare</h3>
<p>옛날부터 작성된 코드인 경우에는 Collections 라이브러리를 사용하기 위해서 해당 네임스페이스를 선언해 주는 경우가 많다. 거기다 새로 추가된 Generic도 사용하기 위해서 두 라이브러리를 모두 선언하는 경우가 많은데 공식 문서에 따르면 Collections에서 사용하는 클래스들은 Generic에 안정성이 추가된 대체할 수 있는 클래스들이 있기 때문에 되도록이면 Generic만 사용하기를 권장한다.</p>

<p>대표적으로 ArrayList와 List&lt;T&gt;를 비교해 본다.&nbsp;</p>
<pre class="csharp"><code>using System;
using System.Collections;
using System.Collections.Generic;

class Program
{
    static void Main()
    {
        // ArrayList
        ArrayList arrayList = new ArrayList();

        // 요소 추가
        arrayList.Add("Hello");
        arrayList.Add(30);
        arrayList.Add(true);

        // 요소 접근
        string str = (string)arrayList[0];
        int num = (int)arrayList[1];
        bool flag = (bool)arrayList[2];

        Console.WriteLine(str);  // 출력: Hello
        Console.WriteLine(num);  // 출력: 30
        Console.WriteLine(flag); // 출력: True
        
        // List&lt;T&gt;
        List&lt;object&gt; list = new List&lt;object&gt;();

        // 요소 추가
        list.Add("Hello");
        list.Add(30);
        list.Add(true);

        // 요소 접근
        string str = list[0];
        int num = list[1];
        bool flag = list[2];

        Console.WriteLine(str);  // 출력: Hello
        Console.WriteLine(num);  // 출력: 30
        Console.WriteLine(flag); // 출력: True
    }
}</code></pre>
<p>arrayList와 list 변수 모두 가변 배열로 요소를 추가하고 인덱스로 접근하여 값을 사용하고 있다.</p>
<p>하지만 사용법에서 차이가 발생한다.</p>

<p>ArrayList는 Add 메서드를 사용하여 요소를 추가하고 접근할 때에는 형변환을 수행해야 한다. 모든 요소를 object 타입으로 처리하므로 요소를 사용하기 전에 타입을 캐스팅해야 한다.</p>

<p>하지만 List 요소의 타입은 컴파일 시점에 검사 되기 때문에 추가한 요소에 접근할 때 형변환이 따로 필요하지 않다.&nbsp;</p>
<p>즉 Generic을 사용하게 되면 타입의 안정성이 보장되고 컴파일러가 타입을 검사를 수행하기 때문에 타입으로 인해 발생하는 문제를 사전에 발견할 수 있으며 형변환 코드를 작성할 필요가 없기 때문에 코드가 간결해진다.</p>
