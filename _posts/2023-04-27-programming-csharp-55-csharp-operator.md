---
title: "C# Operator 키워드"
excerpt: "C# Operator 키워드"
categories:
  - CSharp
permalink: /programming/csharp/55-csharp-operator/
tags:
  - "CSharp"
  - "as"
  - "C#"
  - "checked"
  - "is"
  - "keyword"
  - "sizeof"
  - "typeof"
  - "unchecked"
toc: true
toc_sticky: true
date: 2023-04-27
last_modified_at: 2023-04-27
source_url: https://b-note.tistory.com/55
---

<h3>is</h3>
<p>주어진 값이 특정 클래스 혹은 구조체의 인스턴스인지 아닌지를 판별하는 연산자이다.</p>
<p>즉, is 연산자는 해당 값이 주어진 클래스 또는 구조체로부터 상속되었거나 해당 구조체와 일치하는지를 판별하는 데 사용된다.</p>

<pre class="csharp"><code>object obj = "Hello World!";
if (obj is string)
{
	Console.WriteLine("obj is a string");
}</code></pre>

<p>is 키워드는 obj 변수가 string 타입에 해당하는지 검사한다.</p>
<p>만약 obj가 string 타입이면 로그가 출력되는데 string은 object의 파생 클래스이기 때문에 object 형식으로 형변환이 가능하며 해당 조건문은 true로 로그가 출력이 된다.</p>

<h3>as</h3>
<p>참조 타입의 변수에서 형식 변환을 수행하는 연산자이다.</p>
<p>as 연산자를 사용하면 형식 변환 작업을 수행하면서 실패한 경우 null을 반환한다.</p>

<pre class="csharp"><code>object obj = "Hello World!";
string str = obj as string;
if (str != null)
{
	Console.WriteLine(str,ToUpper());
}
else
{
	Console.WriteLine("obj is not a string");
}</code></pre>

<p>object 타입인 obj를 as를 사용해서 string으로 형변환을 하였다.&nbsp;</p>
<p>당연히 object는 string으로 형변환이 가능하기 때문에 해당 결과는 true로 결과가 출력된다.</p>

<p>is 만 사용할 경우 암시적으로 형변환이 일어나는데 이때 예외처리 에러가 발생할 수 있다. as를 사용해서 형변환을 시도한 결과를 null 예외처리를 할 수 있기 때문에 is와 as는 함께 많이 사용된다.</p>

<h3>sizeof</h3>
<p>피연산자의 크기를 바이트 단위로 계산하여 반환하는 연산자이다.</p>
<p>이 연산자는 컴파일 타임에 실행되며 모든 유형과 식을 피연산자로 취급이 가능하다.</p>
<pre class="csharp"><code>// sizeof(type)
int size = sizeof(int);</code></pre>
<p>sizeof 연산자는 스택에 메모리를 할당할 때 유용하다. 정확한 크기를 알고 있는 배열을 만들 때 sizeof 연산자를 사용하여 각 요소의 크기를 계산하고 이를 기반으로 배열의 크기를 계산할 수 있다.</p>

<p>하지만 sizeof 연산자는 값 형식의 객체에 대해서만 사용할 수 있으며 참조 형식에 대해서는 사용이 불가능하다.</p>
<p>참조 타입의 경우 인스턴스 크기를 얻기 위해서는 Marshal.Sizeof() 메서드를 사용할 수 있지만 이 메서드는 해당 인스턴스가 저장된 메모리의 크기를 반환하므로 실제 인스턴스의 크기와는 다를 수 있다.</p>

<h3>typeof&nbsp;</h3>
<p>특정 타입의 System.Type 객체를 반환하는데 이를 통해 코드에서 지정한 타입에 대한 정보를 얻을 수 있다.&nbsp;</p>
<p>컴파일 타임에 타입을 검사하기 때문에 코드의 안정성과 가독성을 높일 수 있으며 객체의 타입을 확인하고 이에 따라 적절한 작업을 수행하는 코드를 작성할 수 있다.</p>

<pre class="csharp"><code>// typeof(Type)
Type t = typeof(int);</code></pre>
<p>해당 타입의 System.Type 객체를 반환한다. C#에서 사용되는 모든 타입에 대한 정보를 담고 있으며 해당 타입에 대한 모든 메타데이터를 포함하고 있다.</p>

<p>t 변수는 int 타입의 System.Type 객체를 참조하게 되며 이를 통해 int 타입에 대한 정보를 얻을 수 있다.</p>
<p>이외에도 다양한 타입에 대한 정보를 typeof 연산자를 통해 얻을 수 있다.</p>



<h3>stackalloc</h3>
<p>고정 크기의 메모리 블록을 동적으로 할당하기 위해서 사용한다.</p>
<p>메모리 할당과 해제가 매우 빠르고 GC에 의해서 관리되는 힙 메모리를 사용하지 않으므로 애플리케이션의 성능을 향상할 수 있다. C/C++의 alloca() 함수와 비슷한 역할을 한다.&nbsp;</p>

<p>하지만 alloca과 다르게 stackalloc은 호출된 함수의 실행이 종료될 때 자동으로 메모리가 해제되게 된다.</p>

<pre class="csharp"><code>Span&lt;int&gt; numbers = stackalloc[] { 1, 2, 3, 4, 5 };
var idx = numbers.IndexOfAny(stackalloc[] { 2, 4, 6, 8 });
Console.WriteLine(idx);</code></pre>

<p>포인터 형식으로도 메모리 할당이 가능하다.</p>

<pre class="csharp"><code>unsafe
{
	int length = 3;
    int* numbers = stackalloc int[lenth];
    for (var i = 0; i &lt; length; i++)
    {
    	numbers[i] = i;
    }
}</code></pre>
<p>포인터 형식을 사용할 경우 지역 변수에서만 stackalloc을 사용하여 변수를 초기화 할 수 있다.</p>

<p>루프 내부에서는 stackalloc을 사용하지 않아야하며 루프 외부에서 메모리 블록을 할당하고 루프 내부에서 사용하는 방식으로 가야 한다.</p>

<p>스택에서 사용 가능한 메모리는 제한적이기 때문에 너무 많은 메모리를 할당하게 되면 스택오버플로우 에러가 발생한다.</p>
<p>이 문제를 방지하기 위해서는 할당하려는 버퍼의 크기가 특정 한도 내에서만 할당되도록 제한을 두어야 한다.</p>
<pre class="csharp"><code>const int MaxStackLimit = 1024;
Span&lt;byte&gt; buffer = inputLength &lt;= MaxStackLimit ? 
					stackalloc byte[inputLength] : new byte[MaxStackLimit];</code></pre>
<p>입력한 버퍼의 크기가 최대 크기보다 작으면 입력한 만큼의 버퍼를 할당하고 최대를 벗어날 경우에는 최대크기만큼만 버퍼를 할당하도록 한다.</p>

<p>새로 할당된 메모리는 반드시 사용 전에 초기화가 필요하다. 이때 모든 형식의 기본값으로 설정할 수 있는 Span&lt;T&gt;.Clear 메서드를 사용할 수 있다.</p>


<h3>checked/unchecked</h3>
<p>정수 연산 시 overflow 발생 여부를 처리하는 데 사용한다.</p>
<p>기본적으로 C#에서 정수형 연산은 오버플로우가 생기면 예외가 발생한다. 이 예외를 처리하기 위해서는 try-catch 문을 사용해야 하는데 이는 코드를 복잡하게 만들 수 있기 때문에 이런 상황에서는 checked와 unchecked 키워드를 사용할 ㅅ ㅜ있다.</p>

<pre class="csharp"><code>int x = int.MaxValue;
int y = 1;

checked
{
	int z = x + y;
}

unchecked
{
	int z = x + y;
}</code></pre>
<p>&nbsp;위 코드는 int의 최댓값이 1을 더하는 것으로 OverflowException이 발생하는 코드이다.</p>
<p>이때 checked를 사용하면 계산과정에서 overflow가 나기 때문에 예외가 발생한다.</p>
<p>unchecked를 사용할 경우에는 overflow가 발생해도 예외를 발생시키지 않고 결과를 진행한다.</p>
<pre class="csharp"><code>int a = int.MaxValue;
int b = unchecked(a + 1);
int c = checked(a + 1); // System.OverflowException 예외 발생</code></pre>
