---
title: "Sync, Async"
excerpt: "Sync, Async"
categories:
  - ProgrammingBasic
permalink: /programming/programming-basics/15-sync-async/
tags:
  - "Programming"
  - "Programming Basics"
  - "async"
  - "Sync"
  - "동기"
  - "비동기"
toc: true
toc_sticky: true
date: 2023-01-26
last_modified_at: 2023-01-26
source_url: https://b-note.tistory.com/15
---

<p>동기와 비동기는 데이터를 주고 받는 방식에 대한 개념이다.&nbsp;</p>
<h2>동기(Synchronous)</h2>
<p>동시에 일어나다.</p>
<p>요청과 결과가 동시에 일어난다는 의미를 가진다. 즉 요청을 하게되면 시간이 얼마나 걸리던지 요청한 자리에서 대기한 후 결과가 주어져야 다음으로 넘어가게된다.</p>

<p>- 설계가 간단하고 직관적이다.</p>
<p>- 결과가 주어질 때까지 대기해야한다.</p>

<h2>비동기(Asynchronous)</h2>
<p>동시에 일어나지 않는다.</p>
<p>요청과 결과가 동시에 일어나지 않는다는 의미이다. 즉 요청한 자리에서 결과가 주어지지 않으며 작업 처리 단위를 동시에 맞추지 않아도 된다.</p>

<p>- 동기보다 복잡하다.</p>
<p>- 결과가 주어지는 시간 동안 다른 작업을 할 수 있다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-filename="sync_async.png" data-origin-width="465" data-origin-height="438"><span><img src="/assets/images/posts/2023/01/26/15-1.png" loading="lazy" width="399" height="376" data-filename="sync_async.png" data-origin-width="465" data-origin-height="438"/></span></figure>
</p>

<p>동기는 요청 이후 확실하게 결과 확인이 필요한 상황에서 사용되고 비동기 방식은 요청 이후 결과가 언제 들어오든 상관이 없는 경우에 사용된다.</p>
