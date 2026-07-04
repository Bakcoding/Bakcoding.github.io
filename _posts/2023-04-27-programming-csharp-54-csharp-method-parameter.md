---
title: "C# Method Parameter 키워드"
excerpt: "C# Method Parameter 키워드"
categories:
  - CSharp
permalink: /programming/csharp/54-csharp-method-parameter/
tags:
  - "CSharp"
  - "C#"
  - "keyword"
  - "method parameter"
  - "out"
  - "Params"
  - "Ref"
toc: true
toc_sticky: true
date: 2023-04-27
last_modified_at: 2023-04-27
source_url: https://b-note.tistory.com/54
---

<h3>params</h3>
<p>메서드의 매개 변수로 배열을 받을 수 있게 해주는 키워드이다.</p>
<p>params 키워드를 사용하면 메서드 호출 시 각각의 인자를 전달해서 배열형식으로 전달할 수 있다.</p>

<p>만약 배열이나 리스트와 같은 타입을 인수로 전달해야 하는 경우 리스트나 배열로 선언해서 값을 넣어줘야 한다.</p>
<pre class="csharp"><code>public void Main(string[] args)
{
	int[] arrI = new int[4]{1,2,3,4}
    MyMethod(arrI);
}

public void MyMethod(int[] values){}</code></pre>


<p>이럴 때 호출할 함수의 매계변수를 params로 선언하면 따로 배열로 묶어줄 필요가 없어진다.</p>

<pre class="csharp"><code>public void Main(string[] args)
{
	MyMethod(1, 2, 3, 4);
}

public void MyMethod(params int[] values)
{
	foreach (int value in values)
    {
    	Console.WriteLine(value);
    }
}</code></pre>


<p>params 키워드를 통해서 인자를 각각의 인덱스에 값을 넣는 형식으로 받아서 사용이 가능하다.</p>

<h3>ref</h3>
<p>reference 즉, 참조를 뜻하는 키워드이다.</p>
<p>이 키워드를 사용해서 값 타입을 참조 타입처럼 사용할 수 있다.</p>

<pre class="csharp"><code>static void Swap(int a, int b)
{
	int temp = a;
    a = b;
    b = temp;
}</code></pre>
<p>인자로 받은 두 값을 서로 바꾸는 메서드이다.</p>
<p>int는 값 형식으로 값의 복사만 이루어지기 때문에 위 메서드는 a와 b의 값이 바뀌지 않는다.</p>

<p>이때 ref 키워드를 사용하면 참조를 하게 되므로 본래의 변수들의 값이 수정된다,</p>
<pre class="csharp"><code>static void Swap(ref int a, ref int b)
{
	int temp = 4;
    a = b;
    b = temp;
}</code></pre>
<p>이렇게 ref 키워드를 사용해서 메서드를 정의하게 되면 호출하는 곳에서도 ref 키워드를 붙여서 인자를 전달해야 한다.</p>

<pre class="csharp"><code>int x = 1;
int y = 2;
Swap(ref x, ref y);</code></pre>
<p>C++의 포인터와 비슷한 개념이다.</p>
<p>하지만 포인터는 메모리 주소를 가리키는 변수이고 ref는 메모리 위치를 직접 가리키는 것이 아닌 해당 객체에 대한 참조를 가리키게 된다.</p>

<p>따라서 ref 키워드를 사용하면 참조형식 변수를 함수에 전달하여 함수 내에서 해당 변수가 참조하는 메모리 위치를 직접 조작할 수 있다. 이를 통해 함수 내에서 해당 변수가 가리키는 객체를 직접 수정하는 것이 가능하다.</p>

<h3>out&nbsp;</h3>
<p>메서드에서 값을 반환하는 것 외에도 메서드 호출 이후에 값을 전달할 수 있는 방법을 제공한다,</p>
<p>즉 out 키워드를 사용하면 메서드 내부에서 매개변수 값을 수정할 수 있고, 수정된 값을 호출한 곳에서 가져다 쓸 수 있다.</p>

<p>키워드는 메서드의 매개변수 앞에 붙여서 사용한다.&nbsp;</p>
<pre class="csharp"><code>public void Calculate(int x, int y, out int sum, out int product)
{
	sum = x + y;
    product = x * y;
}</code></pre>
<p>Calculate 메서드는 x, y 두 매개변수를 받는다. 그리고 out 키워드를 사용해서 sum, product 두 개의 매개변수를 추가로 받고 있다.</p>

<p>해당 메서드 내부에서는 전달받은 x, y를 이용해서 sum, product를 계산한 후 각각의 매개변수에 값을 할당한다.</p>
<p>이후 메서드를 호출할 때 sum, product를 담을 변수를 선언하고 이 변수를 매개변수로 넘겨주어야 한다.</p>

<pre class="csharp"><code>int a = 5;
int b = 10;
int totalSum = 0;
int totalProduct = 0;

Calculate(a, b, out totalSum, out totalProduct);

Console,WriteLine(totalSum + " " + totalProduct);</code></pre>

<p>메서드가 호출되면 Calculate 내부에서는 전달받은 a와 b의 가지고 각각 totalSum의 값과 totalProduct의 값을 계산하여 저장한다. 따라서 함수의 호출 이후에 totalSum과 totalProduct의 값은 계산 결과가 담기게 된다.</p>
