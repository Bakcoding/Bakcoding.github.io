---
title: "SSH와 RDP"
excerpt: "SSH와 RDP"
categories:
  - Server
permalink: /develop/server/152-ssh-rdp/
tags:
  - "Server"
  - "Linux"
  - "rdp"
  - "SSH"
toc: true
toc_sticky: true
date: 2025-03-01
last_modified_at: 2025-03-01
source_url: https://b-note.tistory.com/152
---

<p>서버가 만들어지고 가장 처음 해야 할 작업은 내 서버에 접속을 하는 것이다.</p>

<p>접속하는 방법에는 SSH와 RDP 크게 두 가지 방식이 있다.</p>

<h3>RDP (Remote Dsktop Protocol)</h3>
<p>원격 데스크톱 프로토콜&nbsp;</p>
<p>다양한 종류의 RDP 소프트웨어들이 있는데 Microsoft에서 개발한 RDP 프로토콜을 확장하거나 개선한 형태로 제공되며 기본적으로 원격 컴퓨터의 화면을 클라이언트에게 전송하고 클라이언트의 입력을 서버로 전달한다.</p>

<p>사용자가 그래픽 환경을 원격으로 사용할 수 있도록 즉, 데스크톱 화면을 그대로 보면서 마우스와 키보드로 제어할 수 있는 방식으로 <span style="color: #333333; text-align: start;">일반적으로 윈도우 환경에서 많이 사용된다.</span><span style="letter-spacing: 0px;"> GUI를 그대로 볼 수 있기 때문에 사용이 편리하고 직관적이라 원격으로 그래픽 환경이 필요한 작업을 할 때 유용하다.</span></p>

<h3><span style="letter-spacing: 0px;">SSH (Sercure Shell)</span><span style="letter-spacing: 0px;"></span><span style="letter-spacing: 0px;"></span></h3>
<p><span style="letter-spacing: 0px;">보안 쉘</span></p>

<p><span style="letter-spacing: 0px;">주로 터미널 기반의 명령어를 사용하여 원격 시스템에 접속하는 데 사용되며 이는 </span><span style="letter-spacing: 0px;">GUI가 따로 없으며 명령줄 인터페이스(CLI)만을 사용하여 서버에 접속하여 제어할 수 있다.</span></p>

<p><span style="letter-spacing: 0px;">SSH는 암호화된 통신을 제공하는 프로토콜이며, 서버와 클라이언트 간에 안전한 데이터 전송을 보장한다. 이 접속 방식은 서버의 텍스트 기반 셸에 접근할 수 있으며 일반적으로 리눅스나 유닉스 시스템에서 많이 사용된다.</span></p>

<p><span style="letter-spacing: 0px;">결론적으로 두 방식의 가장 큰 차이점은 GUI 유무에 있고 그 안에서 각각의 장단점이 존재하게 된다.</span></p>
