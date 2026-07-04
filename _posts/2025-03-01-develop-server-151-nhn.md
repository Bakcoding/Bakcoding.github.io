---
title: "NHN 리눅스 서버 개설"
excerpt: "NHN 리눅스 서버 개설"
categories:
  - Server
permalink: /develop/server/151-nhn/
tags:
  - "Server"
  - "Linux"
  - "NHN"
toc: true
toc_sticky: true
date: 2025-03-01
last_modified_at: 2025-03-01
source_url: https://b-note.tistory.com/151
---

<p>항상 무료 플랜만 찾아다니며 사용했는데 그러다 보니 제약도 많고 내가 원하는 것들을 써보지도 못하고 끝나는 경우가 많았다.</p>

<p>그래서 테스트나 간단하게 사용하기 위한 용도로 저렴한 서버를 찾다가 NHN에 적당한 가격을 찾게 되어 사용해 보기로 한다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="406" data-origin-height="465"><span><img src="/assets/images/posts/2025/03/01/151-1.png" loading="lazy" width="406" height="465" data-origin-width="406" data-origin-height="465"/></span></figure>
</p>

<p>서버의 사양은 가격만큼 낮지만 간단하게 개발용으로 쓰면서 공부하기에는 부족하지 않을 것이라고 생각된다.</p>

<p>일단 큰 금액이 아니기 때문에 즉시 결제하고 바로 활용해 보기로 한다.</p>

<p><figure class="imageblock alignCenter" data-ke-mobileStyle="widthOrigin" data-origin-width="1168" data-origin-height="481"><span><img src="/assets/images/posts/2025/03/01/151-2.png" loading="lazy" width="1168" height="481" data-origin-width="1168" data-origin-height="481"/></span></figure>
</p>

<p>웹 환경은 php가 필요하기 때문에 선택한다. 그에 필요한 Apache도 함께 설치된다.</p>

<p><figure class="imageblock alignCenter" data-ke-mobileStyle="widthOrigin" data-origin-width="1174" data-origin-height="295"><span><img src="/assets/images/posts/2025/03/01/151-3.png" loading="lazy" width="1174" height="295" data-origin-width="1174" data-origin-height="295"/></span></figure>
</p>

<p>접근 포트를 미리 선택해 놓으면 기본 보안 그룹 설정이 반영된다고 하는데 리눅스 터미널은 무조건 필요하지 않을까 싶어서 선택해 주었고 FTP 포트는 쓰긴 할 것 같아서 선택했다.</p>

<p>이 부분은 나중에 보안그룹에서 변경이나 추가해서 설정이 가능하다고 하니 일단 이렇게 진행하기로 한다.</p>

<p>이후로 FTP 정보, DB 정보를 입력하고 혹시 모르니 따로 메모해 둔다.</p>

<p><figure class="imageblock alignCenter" data-ke-mobileStyle="widthOrigin" data-origin-width="1135" data-origin-height="337"><span><img src="/assets/images/posts/2025/03/01/151-4.png" loading="lazy" width="1135" height="337" data-origin-width="1135" data-origin-height="337"/></span></figure>
</p>

<p>마지막으로 키페어(서버 접속 인증 키)에 대한 안내가 나오는데 이게 있어야 서버에 SSH 연결을 할&nbsp; 수 있고 보안을 위해서 신청 시 잘 보관하지 않았다가 이걸 잃어버리면 서버에 연결할 수 없기 때문에 주의해야 한다.</p>

<p>기존 키페어가 없으니 적당한 이름을 넣어주고 새로 만들어 생성된 키를 다운로드하여서 잘 보관하도록 한다.</p>


<p><figure class="imageblock alignCenter" data-ke-mobileStyle="widthOrigin" data-origin-width="1328" data-origin-height="353"><span><img src="/assets/images/posts/2025/03/01/151-5.png" loading="lazy" width="1328" height="353" data-origin-width="1328" data-origin-height="353"/></span></figure>
</p>

<p>신청하고 나면 5분 이내로 서버가 생성되고 클라우드 호스팅 콘솔 페이지에서 서버의 ip나 사용량 등 세부적인 사항들을 확인할 수 있다.</p>

<p>윈도우 서버를 사용해 본 경험이 있긴 하지만 그건 이미 세팅이 완료된 상태에서 원격으로 접속한 것뿐이었다.</p>
<p>이렇게 서버를 열어본 게 처음이고 거기다 리눅스를 사용해 본 적도 없기 때문에 앞으로 서버를 사용하면서 다양하고 새로운 정보와 문제들과 마주할&nbsp;것으로 생각되는데 나중에 이 정보들이 다시 필요한 상황이 왔을 때 참고가 되도록 자세하게 잘 정리해 보도록 해야겠다.</p>
