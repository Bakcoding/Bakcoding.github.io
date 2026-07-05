---
title: "다짜고짜 만들어 보기 #7 - 탄환, 적 충돌처리"
excerpt: "다짜고짜 만들어 보기 #7 - 탄환, 적 충돌처리"
categories:
  - Unreal
permalink: /develop/unreal/100-sharp7/
tags:
  - "Unreal"
  - "Game Development"
  - "collision"
  - "on component hit"
  - "Unreal Engine"
  - "언리얼 엔진"
  - "충돌 처리"
toc: true
toc_sticky: true
date: 2024-07-16
last_modified_at: 2024-07-16
source_url: https://b-note.tistory.com/100
---

<h2>충돌 처리</h2>
<p>BP_Bullet의 Event Graph로 넘어가서 충돌을 처리하는 로직을 만든다.</p>

<p>OnComponentHit 이벤트를 추가하고 Other Actor에서 BP_Enemy를 찾아 충돌한 적을 제거하고 총알도 제거한다.</p>

<p><figure class="imageblock alignCenter" data-ke-mobileStyle="widthOrigin" data-origin-width="859" data-origin-height="224"><span data-alt="Unreal Engine - BP_Bullet On Component Hit"><img src="/assets/images/posts/2024/07/16/100-1.png" loading="lazy" width="859" height="224" data-origin-width="859" data-origin-height="224"/></span><figcaption>Unreal Engine - BP_Bullet On Component Hit</figcaption>
</figure>
</p>

<p>추가로 총알이 충돌하지 않으면 계속 남아 있게 되는데 일정시간 지나면 알아서 제거되도록 한다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="802" data-origin-height="288"><span data-alt="Unreal Engine - BP_Bullet Event BeginPlay"><img src="/assets/images/posts/2024/07/16/100-2.png" loading="lazy" width="802" height="288" data-origin-width="802" data-origin-height="288"/></span><figcaption>Unreal Engine - BP_Bullet Event BeginPlay</figcaption>
</figure>
</p>

<p>총알은 생성되고 3초 뒤에 사라지게 된다.</p>
<p><figure class="imageblock alignLeft"><span data-alt="Unreal Engine - Test Play"><img src="/assets/images/posts/2024/07/16/100-3.gif" loading="lazy" width="360" height="376"/></span><figcaption>Unreal Engine - Test Play</figcaption></figure></p>

<p>기초적인 게임 플레이는 구현이 된듯하다.</p>
