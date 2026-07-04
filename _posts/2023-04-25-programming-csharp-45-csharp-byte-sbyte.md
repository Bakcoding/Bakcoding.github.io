---
title: "C# 데이터 처리 키워드 : byte, sbyte"
excerpt: "C# 데이터 처리 키워드 : byte, sbyte"
categories:
  - CSharp
permalink: /programming/csharp/45-csharp-byte-sbyte/
tags:
  - "CSharp"
  - "byte"
  - "C#"
  - "type_keyword"
toc: true
toc_sticky: true
date: 2023-04-25
last_modified_at: 2023-04-25
source_url: https://b-note.tistory.com/45
---

<h3>byte</h3>
<p>8비트 부호 없는 정수형 데이터 타입이다.</p>
<p>0 ~ 255까지의 값을 표현할 수 있으며 메모리의 크기가 작아서 주로 이미지나 음악 파일 등의 바이너리 데이터를 다룰 때 사용한다.&nbsp;</p>

<p>또한 비트 연산을 처리할 때에도 byte 데이터 타입이 자주 사용된다.</p>
<pre class="csharp"><code>byte b = 255;
byte b2 = (byte)128;</code></pre>

<p>파일이나 이미지 등의 경우 0과 1로 이루어진 이진 데이터이기 때문에 각각의 비트는 0 또는 1의 값을 가진다. 이진 데이터를 다룰 때 byte 단위로 처리해야 하므로 해당 타입이 자주 사용되는 것이다.</p>

<p>예를 들어 이미지 파일을 읽어와서 메모리에 저장한다고 할 때 메모리에 저장하기 위해서는 파일의 크기만큼의 바이트 배열을 선언하고 파일에서 바이트 단위로 읽어와서 배열에 저장해야 한다. 이때 각각의 바이트는 0에서 255까지의 값을 가질 수 있기 때문에 byte 타입으로 배열을 선언한다.&nbsp;</p>

<pre class="csharp"><code>using System;
using System.IO;

class Program
{
    static void Main(string[] args)
    {
        // 파일 경로
        string filePath = "C:\\images\\test.jpg";

        // 파일을 바이트 배열로 읽어오기
        byte[] fileBytes = File.ReadAllBytes(filePath);

        // 바이트 배열의 크기 출력
        Console.WriteLine("File size: " + fileBytes.Length + " bytes");

        // 첫 번째 바이트 값 출력
        Console.WriteLine("First byte: " + fileBytes[0]);
    }
}</code></pre>

<h3>sbyte</h3>
<p>부호가 있는 정수형 데이터 타입이다. byte와 달리 부호 비트를 가지기 때문에 음수 값을 표현할 수 있다.</p>
<p>주로 바이너리 파일 처리나 기계어 처리와 같은 곳에서 사용되는데 컴퓨터 메모리의 물리적 한계로 인해 값의 범위가 중요한 상황에서는 sbyte를 사용해서 적절하게 범위를 다룰 수도 있다.</p>

<p>C#에서는 보통 byte와 함께 사용하면서 비트 연산을 수행하기도 한다.</p>
