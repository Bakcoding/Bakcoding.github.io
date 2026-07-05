---
title: "[게임으로 배우는 파이썬] 데이터 타입"
excerpt: "[게임으로 배우는 파이썬] 데이터 타입"
categories:
  - Python
permalink: /programming/python/69-post/
tags:
  - "Python"
  - "bool"
  - "Data Type"
  - "float"
  - "INT"
  - "String"
  - "게음으로 배우는 파이썬"
toc: true
toc_sticky: true
date: 2023-08-13
last_modified_at: 2023-08-13
source_url: https://b-note.tistory.com/69
---

<h3>데이터 타입</h3>
<p>파이썬에서 다룰 수 있는 가장 기본적인 데이터의 종류는 정수, 부동소수점, 문자열, 부울값이 있다.</p>
<table style="border-collapse: collapse; width: 58.3721%; height: 132px" border="1">
<tbody>
<tr>
<td style="width: 50%">정수 int</td>
<td style="width: 50%">소수점이 없는 수치</td>
</tr>
<tr>
<td style="width: 50%">부동소수점 float</td>
<td style="width: 50%">소수가 있는 수치</td>
</tr>
<tr>
<td style="width: 50%">문자열 string</td>
<td style="width: 50%">문자의 나열</td>
</tr>
<tr>
<td style="width: 50%">부울값 bool</td>
<td style="width: 50%">True, False</td>
</tr>
</tbody>
</table>

<p>이러한 타입들은 엄밀하게 구분되는데 type() 함수를 사용하여 변수나 값의 타입에 대한 정보를 알 수 있다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="159" data-origin-height="159"><span><img src="/assets/images/posts/2023/08/13/69-1.png" loading="lazy" width="159" height="159" data-origin-width="159" data-origin-height="159"/></span></figure>
</p>
<p>연산 과정이 있어도 결과 값으로 타입이 결정된다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="134" data-origin-height="146"><span><img src="/assets/images/posts/2023/08/13/69-2.png" loading="lazy" width="134" height="146" data-origin-width="134" data-origin-height="146"/></span></figure>
</p>
<p>문자열을 값을 할당할 때는 큰 따옴표("") 또는 작은따옴표('')로 문자를 감싼다.</p>
<p>일반적인 문자열을 감쌀 때는 두 부호가 동일하게 동작을 하지만 특수한 상황에서 다르게 사용한다.</p>

<p>만약 문자열 안에 부호가 포함되어 있는 상황에서는 문자열의 범위를 표현하려던 부호가 의도와 다르게 적용될 수 있다.</p>
<blockquote>Hello "Python"!<br />I'm Bak</blockquote>
<p>a = <span style="color: var(--bc-emphasis-danger)">"Hello "</span>Python<span style="color: var(--bc-emphasis-danger)">"!"</span></p>
<p><span>b = <span style="color: var(--bc-emphasis-danger)">'I'</span>m Bak'</span></p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="205" data-origin-height="64"><span><img src="/assets/images/posts/2023/08/13/69-3.png" loading="lazy" width="205" height="64" data-origin-width="205" data-origin-height="64"/></span></figure>
</p>
<p><span>이런 경우에는 문자열을 해석할 때 오류가 발생하지 않도록 두 종류의 방식을 모두 사용할 수 있도록 한다.</span></p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="198" data-origin-height="92"><span><img src="/assets/images/posts/2023/08/13/69-4.png" loading="lazy" width="198" height="92" data-origin-width="198" data-origin-height="92"/></span></figure>
</p>

<h3>형변환</h3>
<p>type casting</p>
<p>데이터형을 다른 데이터 형으로 변환하는 것을 뜻한다.</p>
<h4>Int</h4>
<p>int() : 데이터 타입을 정수로 변환시킨다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="109" data-origin-height="116"><span><img src="/assets/images/posts/2023/08/13/69-5.png" loading="lazy" width="109" height="116" data-origin-width="109" data-origin-height="116"/></span></figure>
</p>

<h4>Float</h4>
<p>float() : 데이터 타입을 부동소수점으로 변환한다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="127" data-origin-height="146"><span><img src="/assets/images/posts/2023/08/13/69-6.png" loading="lazy" width="127" height="146" data-origin-width="127" data-origin-height="146"/></span></figure>
</p>

<h4>String</h4>
<p>str() : 데이터 타입을 문자열로 변환한다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="146" data-origin-height="130"><span><img src="/assets/images/posts/2023/08/13/69-7.png" loading="lazy" width="146" height="130" data-origin-width="146" data-origin-height="130"/></span></figure>
</p>

<h4 style="text-align: start">Bool</h4>
<p style="text-align: start">bool은 어떤 조건이 성립했는지 아닌지 처리를 바꾸면서 실행된다.&nbsp;</p>
<p style="text-align: start">True와 False 둘 중 하나로 존재한다.</p>
<p style="text-align: start">&nbsp;</p>
<p style="text-align: start">bool()을 사용하면 입력된 식이나 값을 평가해서 bool 타입의 값으로 출력한다. 이때 0의 경우 false 그 외의 값들은 모두 true로 평가된다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="148" data-origin-height="92"><span><img src="/assets/images/posts/2023/08/13/69-8.png" loading="lazy" width="148" height="92" data-origin-width="148" data-origin-height="92"/></span></figure>
</p>
