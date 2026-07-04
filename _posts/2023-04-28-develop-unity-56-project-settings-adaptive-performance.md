---
title: "Project Settings - Adaptive Performance"
excerpt: "Project Settings - Adaptive Performance"
categories:
  - Unity
permalink: /develop/unity/56-project-settings-adaptive-performance/
tags:
  - "Unity"
  - "Game Development"
  - "adaptive performance"
  - "OPTIMIZE"
  - "provider"
  - "Simulator"
  - "unity"
  - "유니티"
  - "프로젝트 세팅"
toc: true
toc_sticky: true
date: 2023-04-28
last_modified_at: 2023-04-28
source_url: https://b-note.tistory.com/56
---

<p>에디터 버전 : 2021.3.28f1 (LTS)</p>

<h3>Adaptive Performance</h3>
<p>모바일 장치와 같은 저사양의 플랫폼에서 자동으로 프레임률을 관리하고 최적화할 수 있도록 기능을 제공한다.</p>
<p>기능이 활성화되면 하드웨어 자원을 최대한 활용하여 최적의 성능을 얻을 수 있다.&nbsp;</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="352" data-origin-height="244"><span><img src="/assets/images/posts/2023/04/28/56-1.png" loading="lazy" width="352" height="244" data-origin-width="352" data-origin-height="244"/></span></figure>
</p>
<p>기능을 사용하기 위해서는 Adaptive Performance 패키지부터 설치해야 한다. 아래의 인스톨 버튼을 클릭하면 해당 패키지의 최신 버전의 설치가 진행된다.</p>

<p>패키지 설치가 끝나면 다음과 같이 화면이 변경된다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="482" data-origin-height="377"><span><img src="/assets/images/posts/2023/04/28/56-2.png" loading="lazy" width="482" height="377" data-origin-width="482" data-origin-height="377"/></span></figure>
</p>

<h4>Adaptive Performance Docs</h4>
<p>공식 문서부터 살펴본다.</p>
<p><a href="https://docs.unity3d.com/Packages/com.unity.adaptiveperformance@5.0/manual/index.html" target="_blank" rel="noopener">view documentation</a></p>

<p>해당 패키지의 설명은 이렇다.</p>

<blockquote>Adaptive Performance allows you to get feedback about the thermal and power state of your mobile device and react appropriately.<br />(Adaptive Performance를 사용하면 모바일 장치의 발열과 전원 상태에 대한 피드백을 가지고 적절하게 대응할 수 있다.)</blockquote>

<p>여기서 전원 상태란 모바일 장치의 전력 상태를 의미한다.</p>
<p>(전력이 낮은지, 충분한지 또는 충전 중인지 등의 상태)<br></p>
<blockquote>For example, you can create applications that react to temperature trends and events on the device, to ensure constant frame rates over a longer period of time and prevent thermal throttling.<br />(장치의 온도 추세나 이벤트에 반응해서 일관된 프레임률을 장기간 유지하고 열 제한을 방지하는 애플리케이션을 만들 수 있다.)</blockquote>

<p>온도 추세는 모바일 장치의 온도 변화를 뜻한다. 모바일 장치는 사용자가 앱을 실행하거나 다양한 작업을 수행할 때 온도가 상승할 수 있다. 이벤트는 앱의 실행과 종료, 배터리 잔량 변화, 충전 상태 변화, 네트워크 상태, 알림, 회전 등과 같이 여러 상태 변화를 뜻한다.&nbsp;</p>

<p>열 제한은 모바일 장치가 과열될 때 발생하는 현상으로 온도가 높아짐에 따라 장치의 성능이 저하되거나 충전이 중단되는 등의 문제가 발생한다. 따라서 열 제한을 방지한다는 것은 장치의 온도가 올라가서&nbsp;<span style="color: #333333; text-align: start;">열 제한을 발생시켜 성능이 저하되지 않도록</span><span style="color: #333333; text-align: start;"><span>&nbsp;</span></span><span style="color: #333333; text-align: start;">온도추세와 이벤트에 반응하여<span>&nbsp;</span></span>프레임률 관리를 통해서 모바일 장치의 과열을 방지하는 것을 의미한다.</p>

<p><a href="https://technolobe.com/2020/04/24/thermal-throttling-in-smartphones-a-mere-problem/" target="_blank" rel="noopener">Thermal Throttling&nbsp;</a></p>

<h4>Provider</h4>
<p>Adaptive Performance를 활용하기 위해서는 정보를 제공할 장치가 필요하다. 이 장치를 Provider라고 하며 빌드 대상에 맞는 Provider가 제공된다. PC 플랫폼인 경우 별도의 Provider는 제공되지 않으며 Simulator라는 가상 장치를 사용할 수 있다. Simulator는 Adaptive Performance 패키지가 설치될 때 함께 다운로드되며 Provider의 경우 선택될 때 패키지 설치가 진행된다. 하지만 선택을 해제해도 해당 패키지가 삭제되진 않으며 삭제하고 싶은 경우 패키지 매니저를 사용해야 한다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="485" data-origin-height="364"><span><img src="/assets/images/posts/2023/04/28/56-3.png" loading="lazy" width="359" height="269" data-origin-width="485" data-origin-height="364"/></span></figure>
</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="475" data-origin-height="108"><span><img src="/assets/images/posts/2023/04/28/56-4.png" loading="lazy" width="475" height="108" data-origin-width="475" data-origin-height="108"/></span></figure>
<figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="482" data-origin-height="118"><span><img src="/assets/images/posts/2023/04/28/56-5.png" loading="lazy" width="359" height="88" data-origin-width="482" data-origin-height="118"/></span></figure>
<figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="484" data-origin-height="479"><span><img src="/assets/images/posts/2023/04/28/56-6.png" loading="lazy" width="349" height="345" data-origin-width="484" data-origin-height="479"/></span></figure>
</p>
<p>Simulator = PC, Provider = Mobile (android, ios)&nbsp;</p>
