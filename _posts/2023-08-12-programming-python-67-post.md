---
title: "[게임으로 배우는 파이썬] 변수"
excerpt: "[게임으로 배우는 파이썬] 변수"
categories:
  - Python
permalink: /programming/python/67-post/
tags:
  - "Python"
  - "Variable"
  - "게임으로 배우는 파이썬"
toc: true
toc_sticky: true
date: 2023-08-12
last_modified_at: 2023-08-12
source_url: https://b-note.tistory.com/67
---

<h3>변수명</h3>
<p>파이썬에서 변수명으로 사용이 가능한 문자는 다음과 같다.</p>
<p>대소 영문자, 숫자, 언더스코어이다. 여기서 숫자는 맨 앞에 올 수 없다.</p>

<p>이외에 예약어로 지정되어 있는 키워드들도 변수명으로 사용이 불가능하다.</p>

<h3>대입 간이 기법</h3>
<p>변수의 값이 자주 갱신되는 프로그래밍에서 값을 증가시키고 감소시키는 처리에서는 간이 기법을 사용한다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="144" data-origin-height="125"><span><img src="/assets/images/posts/2023/08/12/67-1.png" loading="lazy" width="144" height="125" data-origin-width="144" data-origin-height="125"/></span></figure>
</p>
<p>수학에서는 적용되지 않는 a = a + 1과 같은 서식을 사용할 수 있다.&nbsp;</p>
<p>동작은 우변을 먼저 계산하고 결과를 좌변의 변수에 대입한다.</p>

<p>연산을 하고 다시 자신에게 대입하는 처리보다 더 간단한 기술방법이 있다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="119" data-origin-height="159"><span><img src="/assets/images/posts/2023/08/12/67-2.png" loading="lazy" width="119" height="159" data-origin-width="119" data-origin-height="159"/></span></figure>
</p>

<table style="border-collapse: collapse; width: 69.8834%; height: 69px" border="1">
<tbody>
<tr style="height: 45px">
<td style="width: 10%; height: 45px">+=</td>
<td style="width: 50%; height: 45px">자기 자신에게 우변값을 더하고, 그 결과를 자기 자신에 대입한다.</td>
</tr>
<tr style="height: 17px">
<td style="width: 10%; height: 17px">-=</td>
<td style="width: 50%; height: 17px">자기 자신에서 우변값을 빼고, 그 결과를 자기 자신에게 대입한다.</td>
</tr>
<tr style="height: 17px">
<td style="width: 10%; height: 17px">*=</td>
<td style="width: 50%; height: 17px">자기 자신에게 우변값을 곱하고, 그 결과를 자기 자신에게 대입한다.</td>
</tr>
<tr style="height: 17px">
<td style="width: 10%; height: 17px">/=</td>
<td style="width: 50%; height: 17px">자기 자신을 우변값으로 나누고, 그 결과를 자기 자신에게 대입한다.</td>
</tr>
</tbody>
</table>
