---
title: "[게임으로 배우는 파이썬] 함수"
excerpt: "[게임으로 배우는 파이썬] 함수"
categories:
  - Python
permalink: /programming/python/68-post/
tags:
  - "Python"
  - "function"
  - "MAX"
  - "Min"
  - "게임으로 배우는 파이썬"
toc: true
toc_sticky: true
date: 2023-08-13
last_modified_at: 2023-08-13
source_url: https://b-note.tistory.com/68
---

<p>함수는 여러 개의 처리를 기능별로 모아 놓은 것이다.&nbsp;</p>
<p>사용할 때는 함수가 어떤 기능을 하는지만 알아도 되며 내부에서 처리되는 과정들은 알 필요가 없다.</p>

<p>이때 함수에 전달하는 데이터를 인수, 함수로부터 돌아오는 값을 반환값이라고 한다.</p>

<p>필요에 따라 직접 함수를 구현해서 사용할 수 있지만 파이썬에는 미리 준비된 함수도 많이 제공된다.</p>

<p>예를 들어서 두 개의 값을 비교해서 더 크거나 또는 작은 값을 구하는 처리가 필요한 경우가 빈번하게 사용되는 상황일 때, 매번 값을 비교하는 과정을 작성하는 것은 비효율적이다. 이럴 때 함수를 만들어서 처리하면 코드가 간결해진다.&nbsp;</p>
<p>만약 필요한 함수가 파이썬에서 제공되는 것이라면 직접 구현하는 과정도 생략이 될 수 있다.</p>

<p>예시에서 처리하는 기능의 경우 파이썬에서 max(), min() 함수가 있다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="163" data-origin-height="132"><span><img src="/assets/images/posts/2023/08/13/68-1.png" loading="lazy" width="163" height="132" data-origin-width="163" data-origin-height="132"/></span></figure>
</p>
<p>max(a, b)&nbsp; : a와 b 중 큰 값을 반환</p>
<p>min(a, b) : a와 b 중 작은 값을 반환&nbsp;</p>

<p>함수는 기본적으로 함수명() 형태로 선언되며 실행할 때 괄호를 붙여 실행한다. 어떠한 값을 입력해야 한다면 괄호 안에 변수나 값을 넣는다.</p>
