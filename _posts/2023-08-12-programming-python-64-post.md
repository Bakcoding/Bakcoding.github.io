---
title: "[게임으로 배우는 파이썬] 기본세팅"
excerpt: "[게임으로 배우는 파이썬] 기본세팅"
categories:
  - Python
permalink: /programming/python/64-post/
tags:
  - "Python"
  - "Anaconda"
  - "pygame"
  - "게임으로 배우는 파이썬"
toc: true
toc_sticky: true
date: 2023-08-12
last_modified_at: 2023-08-12
source_url: https://b-note.tistory.com/64
---

<p>파이썬은 읽고 쓰기 쉽고 프로그래머의 작업 효율을 높이도록 디자인된 프로그래밍 언어이다.</p>
<p>윈도우, 맥 os, 리눅스는 물론 라즈베리 파이 등 다양한 운영체제를 지원한다. 이러한 장점들이 수많은 사용자를 이끌었고 거기에 따라서 자료도 찾기 쉬워 접근성이 더 높아지면서 그에 따라 더욱더 성장할 가능성이 있는 언어라고 볼 수 있다.</p>

<h3>라이브러리</h3>
<p>파이썬의 가장 큰 특징은 풍부한 라이브러리이다.&nbsp;</p>
<p>문법이 간단해서 코드를 작성하는 데는 어려움이 없지만 무언가를 만들기 위해서는 목적에 맞는 라이브러리를 사용할 필요가 있다.&nbsp;</p>

<p>파일을 읽고 쓰고, 네트워크에 접근하는 등 표준으로 준비돼 있는 것뿐만 아니라 서드파티가 공개하는 것도 많다.</p>

<p>대표적으로 유명한 라이브러리들이 있다.</p>
<blockquote>NumPy&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; 수치 계산 라이브러리<br />SciPy&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;과학 기술 계산 라이브러리<br />PIL&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;영상처리 라이브러리<br />Tkinter&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; GUI 라이브러리<br />Beautiful Soup&nbsp; &nbsp; &nbsp; HTML 정보 수집(스크래핑) 라이브러리<br />PyGame&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;게임 작성용 라이브러리</blockquote>

<h2>PyGame</h2>
<p>python 3.8 버전을 기준으로 작업한다.&nbsp;</p>
<p>게임을 개발하는데 필요한 라이브러리를 설치한다.</p>
<h3 style="text-align: start">Anaconda</h3>
<p style="text-align: start">아나콘다는 파이썬에서 자주 쓰이는 패키지를 일괄적으로 설치할 수 있도록 한다.</p>
<p style="text-align: start"><a style="background-color: var(--bc-emphasis-mark-bg); color: var(--bc-emphasis-info); text-align: start" href="https://www.anaconda.com/download">Free Download | Anaconda</a></p>
<p style="text-align: start">&nbsp;</p>
<p style="text-align: start">경로에 한글이 포함되어 있으면 에러가 발생할 수 있기 때문에 아나콘다를 설치하는 경로에는 한글이 포함되지 않도록 해주는 것이 좋다.</p>
<p style="text-align: start">&nbsp;</p>
<p style="text-align: start">이때 환경변수를 Anaconda 폴더 내의 python.exe 가 실행되도록 경로를 맞춰야 한다.</p>
<p style="text-align: start">&nbsp;</p>
<p style="text-align: start">게임에서 사용할 패키지를 설치한다.</p>
<p style="text-align: start">&nbsp;</p>
<blockquote>pip install pygame</blockquote>
<h4 style="text-align: start">&nbsp;</h4>
<h4 style="text-align: start">Error</h4>
<p>다음과 같은 에러가 발생하면&nbsp; pip이 설치되지 않아서 발생할 수 있기 때문에 직접 설치한다.</p>
<blockquote>'pip'은(는) 내부 또는 외부 명령, 실행할 수 있는 프로그램, 또는 배치&nbsp;파일이&nbsp;아닙니다.</blockquote>
<p>pip은 보통 파이썬을 설치된다. 만약 이때 설치되지 못했다면 직접 명령어를 통해서 설치한다.</p>
<blockquote>curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py<br />python get-pip.py</blockquote>

<p>명령어를 입력하는 방법 외에도 python 인스톨러를 다시 실행시켜서 pip 설치에 대한 체크를 하고 파이썬 설치를 진행해도 된다.</p>

<p>pip 설치 후 다시 pygame 명령어 실행 시 제대로 설치가 된다.</p>
<p><figure class="imageblock alignCenter" data-ke-mobileStyle="widthOrigin" data-origin-width="965" data-origin-height="140"><span><img src="/assets/images/posts/2023/08/12/64-1.png" loading="lazy" width="965" height="140" data-origin-width="965" data-origin-height="140"/></span></figure>
</p>

<p>완료된 패키지 파일을 실행시켜 설치한다.</p>
<blockquote>python<br />import pygame</blockquote>
<p><figure class="imageblock alignCenter" data-ke-mobileStyle="widthOrigin" data-origin-width="917" data-origin-height="102"><span><img src="/assets/images/posts/2023/08/12/64-2.png" loading="lazy" width="917" height="102" data-origin-width="917" data-origin-height="102"/></span></figure>
</p>

<p>설치가 완료되면 다음 경로에 샘플이 생성된 것을 확인할 수 있다.</p>
<blockquote>'[Anaconda 설치 경로]\Lib\site-packages\pygame\examples'</blockquote>

<p>세팅 끝</p>
