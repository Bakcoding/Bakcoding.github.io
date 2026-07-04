---
title: "리눅스 명령어 - ls"
excerpt: "리눅스 명령어 - ls"
categories:
  - Server
permalink: /develop/server/156-ls/
tags:
  - "Server"
  - "Linux"
  - "linuc"
  - "LS"
toc: true
toc_sticky: true
date: 2025-03-01
last_modified_at: 2025-03-01
source_url: https://b-note.tistory.com/156
---

<p>자주 사용되는 명령어를 생각날 때마다 정리하기로 한다.</p>

<h3>ls</h3>
<pre class="bash"><code>ls</code></pre>

<p>list의 약자로 디렉터리 내의 파일과 폴더 목록을 나열하는 데 사용된다.</p>

<p>기본 사용법인 ls는 현재 디렉터리의 파일과 폴더 목록을 나열한다.</p>

<p>다른 디렉터리의 목록을 보려면</p>

<pre class="bash"><code>ls /path/to/directory</code></pre>

<p>ls 뒤에 확인하고자 하는 경로를 입력한다.</p>

<h3>옵션</h3>
<pre class="bash"><code>ls -l</code></pre>
<p>파일의 권한, 소유자, 크기, 수정 시간 등 상세 정보와 함께 목록을 표시한다.</p>

<pre class="bash"><code>ls -a</code></pre>
<p>숨겨진 파일(점으로 시작하는 파일)도 포함하여 모든 파일을 나열한다.</p>

<pre class="bash"><code>ls -lh</code></pre>
<p>파일 크기를 사람이 읽기 쉬운 형식으로 표시한다.</p>

<pre class="bash"><code>ls -R</code></pre>
<p>하위 디렉터리까지 재귀적으로 목록을 나열한다.</p>

<pre class="bash"><code>ls -lt</code></pre>
<p>수정 시간을 기준으로 파일을 정렬 (최근 수정된 파일 우선)</p>

<pre class="bash"><code>ls -lS</code></pre>
<p>파일 크기를 기준으로 정렬 (큰 파일이 우선)</p>

<pre class="bash"><code>ls -lr</code></pre>
<p>역순으로 정렬</p>

<pre class="bash"><code>ls -d */</code></pre>
<p>디렉터리 자체만 표시 (디렉터리 내의 파일 목록은 표시되지 않음)</p>

<pre class="bash"><code>ls -1</code></pre>
<p>한 줄에 하나의 파일만 표시</p>
<p>기본적으로 여러 열로 표시되지만, -1 옵션을 사용하면 한 줄에 하나씩 표시</p>

<pre class="bash"><code>man ls</code></pre>
<p>이 외의 옵션들에 대한 매뉴얼을 확인할 수 있다.</p>
