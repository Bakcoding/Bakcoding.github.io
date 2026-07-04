---
title: "[NHN Cloud Hosting - Linux] mysql 테스트"
excerpt: "[NHN Cloud Hosting - Linux] mysql 테스트"
categories:
  - Server
permalink: /develop/server/154-nhn-cloud-hosting-linux-mysql/
tags:
  - "Server"
  - "Linux"
  - "MySQL"
  - "NHN"
toc: true
toc_sticky: true
date: 2025-03-01
last_modified_at: 2025-03-01
source_url: https://b-note.tistory.com/154
---

<p>이번에는 mysql에 로그인하고 테스트해본다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="746" data-origin-height="673"><span data-alt="제품 설명"><img src="/assets/images/posts/2025/03/01/154-1.png" loading="lazy" width="616" height="556" data-origin-width="746" data-origin-height="673"/></span><figcaption>제품 설명</figcaption>
</figure>
</p>

<p>내가 결제한 서버의 설명을 보면 DB는 MySQL 8.0이라고 표기되어있다.</p>

<p>먼저 mysql이 잘 설치되어 있는지와 버전도 일치하는지 확인해 본다.</p>

<pre class="bash"><code>$mysql --version</code></pre>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="564" data-origin-height="32"><span><img src="/assets/images/posts/2025/03/01/154-2.png" loading="lazy" width="564" height="32" data-origin-width="564" data-origin-height="32"/></span></figure>
</p>

<p>문제가 없어 보이니 이제 서버 신청 시 입력했던 DB 계정으로 로그인해본다.</p>

<pre class="bash"><code>$mysql -u 'userid' -p</code></pre>

<p>userid에 db 계정을 입력하고 엔터를 치면 패스워드를 입력하는 단계로 넘어가고 패스워드까지 문제없이 입력하고 나면 명령어 창이 mysql&gt;로 바뀌고 mysql 명령어를 입력할 수 있는 상태로 된다.</p>

<p>테스트 용으로 데이터베이스를 하나 만들어 본다.</p>

<pre class="bash"><code>CREATE DATABASE testdb;</code></pre>

<p>명령어를 입력하니 권한이 없다는 에러가 발생한다.</p>

<p>일단 mysql 콘솔창을 나간다. 이때 명령어 창에 quit 또는 exit을 입력하면 나올 수 있다.</p>

<p>이번엔 root 계정으로 로그인한 다음 내 계정에 권한을 주기로 한다.</p>
<pre class="bash"><code>GRANT ALL PRIVILEGES ON *.* TO 'userid'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;</code></pre>

<p>권한을 준 다음 즉시 변경 사항이 반영되도록 한다.</p>

<p>그리고 다시 내 계정으로 로그인 후 testdb를 생성하고 잘 생성됐는지 목록도 뽑아 본다.</p>

<pre class="bash"><code>SHOW DATABASES;</code></pre>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="206" data-origin-height="181"><span><img src="/assets/images/posts/2025/03/01/154-3.png" loading="lazy" width="206" height="181" data-origin-width="206" data-origin-height="181"/></span></figure>
</p>

<p>이번엔 해당 데이터베이스에 테이블도 만들어 본다.</p>

<pre class="bash"><code>USE testdb;
CREATE TABLE users (
	id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL
);</code></pre>



<p>생성된 테이블을 목록에 뽑아 본다.</p>

<pre class="bash"><code>SHOW TABLES;</code></pre>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="203" data-origin-height="100"><span><img src="/assets/images/posts/2025/03/01/154-4.png" loading="lazy" width="203" height="100" data-origin-width="203" data-origin-height="100"/></span></figure>
</p>

<p>생성한 users 테이블이 잘 보이는 게 확인된다.</p>

<p>테이블의 자세한 정보도 확인한다.</p>

<pre class="bash"><code>DESCRIBE users;</code></pre>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="548" data-origin-height="131"><span><img src="/assets/images/posts/2025/03/01/154-5.png" loading="lazy" width="548" height="131" data-origin-width="548" data-origin-height="131"/></span></figure>
</p>

<p>입력한 대로 잘 만들어졌다.</p>
