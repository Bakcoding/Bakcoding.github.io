---
title: "[NHN Cloud Hosting - Linux] SSH로 서버 접속"
excerpt: "[NHN Cloud Hosting - Linux] SSH로 서버 접속"
categories:
  - Server
permalink: /develop/server/153-nhn-cloud-hosting-linux-ssh/
tags:
  - "Server"
  - "Linux"
  - "CentOS"
  - "SSH"
toc: true
toc_sticky: true
date: 2025-03-01
last_modified_at: 2025-03-01
source_url: https://b-note.tistory.com/153
---

<p>리눅스에서도 Xrdp를 사용하면 GUI가 있는 RDP를 사용할 수 있다고 한다.</p>

<p>그럼에도 SSH를 사용하기로 한 이유는 서버 사양을 고려한 부분이 크고 다른 이유는 다양한 명령어들을 이번 기회에 공부할 수 있을 것 같아서이다.</p>

<h3>PuTTY</h3>
<p>SSH 클라이언트로 사용할 프로그램은 대표적인 PuTTY로 정했다.</p>

<p><a href="https://www.chiark.greenend.org.uk/~sgtatham/putty/releases/0.83.html" target="_blank" rel="noopener">PuTTY</a></p>
<figure id="og_1740773082164" contenteditable="false" data-og-type="website" data-og-title="Download PuTTY: release 0.83" data-og-description="0.83, released on 2025-02-08, is the latest release. You can also find it at the Latest Release page, which will update when new releases are made (and so is a better page to bookmark or link to). Release versions of PuTTY are versions we think are reasona" data-og-host="www.chiark.greenend.org.uk" data-og-source-url="https://www.chiark.greenend.org.uk/~sgtatham/putty/releases/0.83.html" data-og-url="https://www.chiark.greenend.org.uk/~sgtatham/putty/releases/0.83.html"><a href="https://www.chiark.greenend.org.uk/~sgtatham/putty/releases/0.83.html" target="_blank" rel="noopener" data-source-url="https://www.chiark.greenend.org.uk/~sgtatham/putty/releases/0.83.html">
<div class="og-image" style="background-image: url();">&nbsp;</div>
<div class="og-text">
<p class="og-title">Download PuTTY: release 0.83</p>
<p class="og-desc">0.83, released on 2025-02-08, is the latest release. You can also find it at the Latest Release page, which will update when new releases are made (and so is a better page to bookmark or link to). Release versions of PuTTY are versions we think are reasona</p>
<p class="og-host">www.chiark.greenend.org.uk</p>
</div>
</a></figure>

<p>PuTTY 최신 버전을 다운로드하여 설치하고 puttygen.exe 도 다운로드해&nbsp;놓는다.</p>

<p><span style="color: #333333; text-align: start;">SSH로 접속할 때 서버 접속 인증키가 필요한데 NHN에서 서버를 생성할 때 만든 키 파일은. pem 확장자로<span>&nbsp;</span></span>PuTTY에서는 이 파일을 그대로 사용할 수 없기 때문에. ppk로 변환하는 과정이 필요하다.</p>

<p>먼저 서버를 신청할 때 생성하고 다운해 놓은 서버 접속 인증키를 준비해 놓고 puttygen.exe를 실행시킨다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="594" data-origin-height="463"><span data-alt="puttygen.exe"><img src="/assets/images/posts/2025/03/01/153-1.png" loading="lazy" width="594" height="463" data-origin-width="594" data-origin-height="463"/></span><figcaption>puttygen.exe</figcaption>
</figure>
</p>

<p>Load 버튼을 클릭하면 탐색기가 열리는데 여기서 All Files 설정으로 모든 파일이 보이게 한 다음 내 서버 접속 인증키. pem 파일을 불러온다.&nbsp;</p>

<p>불러온 후에 알림 창이 뜨는데 성공적으로 불러오게 되면 Successfully imported ~ 내용을 확인할 수 있다.</p>

<p>이제 활성화된 버튼 Save private key를 클릭하고 알아볼 수 있는 이름으로 저장한다.</p>

<p>이제 putty를 실행한 다음 서버와 연결에 필요한 정보들을 채워 넣는다.</p>

<p>Session 항목</p>
<p>Host Name (or IP address) : 서버 이름이나 주소</p>
<p>Port : 기본 22</p>
<p>Connection type : SSH</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="451" data-origin-height="438"><span data-alt="PuTTY - configration"><img src="/assets/images/posts/2025/03/01/153-2.png" loading="lazy" width="451" height="438" data-origin-width="451" data-origin-height="438"/></span><figcaption>PuTTY - configration</figcaption>
</figure>
</p>


<p>Connection &gt; SSH &gt; Auth &gt; Credential 항목에서 Private key file for authentication에 생성해 놓은. ppk 파일을 선택한다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="449" data-origin-height="440"><span data-alt="PuTTY - configration"><img src="/assets/images/posts/2025/03/01/153-3.png" loading="lazy" width="449" height="440" data-origin-width="449" data-origin-height="440"/></span><figcaption>PuTTY - configration</figcaption>
</figure>
</p>

<p>이렇게 세팅해 놓고 다시 Session 항목으로 이동해서 현재 설정해 놓은 session 정보를 저장해 두면 나중에 다시 접속할 때 편하다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="277" data-origin-height="175"><span data-alt="PuTTY - session save"><img src="/assets/images/posts/2025/03/01/153-4.png" loading="lazy" width="277" height="175" data-origin-width="277" data-origin-height="175"/></span><figcaption>PuTTY - session save</figcaption>
</figure>
</p>

<p>Saved Sessions 아래에 세션이름을 입력하고 Save 클릭하면 해당 이름으로 세션이 저장된다.</p>

<p>이제 내 서버에 SSH 연결할 준비가 끝났다.</p>

<p>Open을 눌러주면 터미널 창이 뜬다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="649" data-origin-height="206"><span data-alt="PuTTY - login as :"><img src="/assets/images/posts/2025/03/01/153-5.png" loading="lazy" width="649" height="206" data-origin-width="649" data-origin-height="206"/></span><figcaption>PuTTY - login as :</figcaption>
</figure>
</p>

<p>창에는 login as :라는 문구만 보이고 무언가 입력을 기다리고 있다.</p>

<p>이는 어떤 사용자 계정으로 로그인할지에 대한 입력을 기다리는 것으로 이 계정은 서버에 따라 다르기 때문에 확인을 해서 입력한다.</p>

<p>내가 사용 중인 서버는 CentOS이며 사용자 계정이름은 centos이다.</p>

<p>centos를 입력하고 엔터를 치면</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="458" data-origin-height="89"><span data-alt="PuTTY"><img src="/assets/images/posts/2025/03/01/153-6.png" loading="lazy" width="458" height="89" data-origin-width="458" data-origin-height="89"/></span><figcaption>PuTTY</figcaption>
</figure>
</p>

<p>성공적으로 서버에 접속했다.</p>
