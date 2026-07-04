---
title: "[NHN Cloud Hosting - Linux] 로컬에서 DB 접속"
excerpt: "[NHN Cloud Hosting - Linux] 로컬에서 DB 접속"
categories:
  - Server
permalink: /develop/server/158-nhn-cloud-hosting-linux-db/
tags:
  - "Server"
  - "Linux"
  - "HeidiSQL"
  - "MySQL"
toc: true
toc_sticky: true
date: 2025-03-01
last_modified_at: 2025-03-01
source_url: https://b-note.tistory.com/158
---

<p>리눅스 서버에서 db를 사용하기에는 불편함이 많아서 로컬에서 클라이언트 툴을 연결해서 사용하기로 한다.</p>

<p>툴은 평소에 자주 쓰던 HeidiSQL을 쓰기로 한다.</p>

<p>NHN에서 서버의 보안 그룹 관련된 내용을 보면 my_sql은 기본적으로 허용하지 않기 때문에 직접 서버의 콘솔 페이지에서 보안그룹에 들어가서 포트와 접근 ip에 대한 설정을 해주어야 한다.</p>

<p>대시보드 &gt; 자세히 보기 &gt; 프로젝트 명 선택</p>

<p>보안 그룹 관리에서 추가하여 상태를 변경해 준다.</p>

<p>수신 / 사용자 정의 TCP / 3306 (MY-SQL) / IPv4 / 내 로컬 주소 (CIDR)</p>

<p>CIDR은 IP 주소 범위를 지정하는 방법인데 0.0.0.0/0은 모든 IP 주소를 허용하는데 내 로컬 주소만 허용하기로 한다.</p>

<p><a href="https://ipinfo.io/" target="_blank" rel="noopener&nbsp;noreferrer">https://ipinfo.io/</a> 에서 확인하여 내 IP를 특정하여 입력해 준다.</p>

<p>이렇게 하면 콘솔에서 보안은 해결되었고 이제 서버의 mysql에 로그인해서 로컬에서 사용할 계정을 따로 추가하도록 한다.</p>

<pre class="bash"><code>CREATE USER 'user_id'@'user_ip' IDENTIFIED BY 'user_password';</code></pre>

<p>계정은 접속할 수 있는 IP를 지정(내 로컬 ip)하여 생성한다.</p>

<p>그리고 이 계정에 권한을 준다.</p>

<pre class="bash"><code>GRANT ALL PRIVILEGES ON testdb.* TO 'user_id'@'user_ip';
FLUSH PRIVILEGES</code></pre>

<p>위에서 만든 계정에 database_name 데이터베이스에 대한 모든 권한(.*)을 준다.</p>

<p>이제 이렇게 만든 계정으로 HeidiSQL에 로그인하면&nbsp;</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="580" data-origin-height="142"><span data-alt="HeidiSQL"><img src="/assets/images/posts/2025/03/01/158-1.png" loading="lazy" width="580" height="142" data-origin-width="580" data-origin-height="142"/></span><figcaption>HeidiSQL</figcaption>
</figure>
</p>

<p>서버의 db를 GUI로 확인할 수 있어 편한 게 관리할 수 있게 되었다.</p>
