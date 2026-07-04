---
title: "언리얼 엔진 - 에디터 개인설정 - 일반 글로벌"
excerpt: "언리얼 엔진 - 에디터 개인설정 - 일반 글로벌"
categories:
  - Unreal
permalink: /develop/unreal/84-post/
tags:
  - "Unreal"
  - "Game Development"
  - "3S"
  - "aws"
  - "DDC"
  - "editor settings"
  - "Unreal Engine"
  - "언리얼 엔진"
  - "파생 데이터 캐시"
toc: true
toc_sticky: true
date: 2024-05-05
last_modified_at: 2024-05-05
source_url: https://b-note.tistory.com/84
---

<h3>일반 - 글로벌</h3>
<p><figure class="imageblock alignCenter" data-ke-mobileStyle="widthOrigin" data-origin-width="1612" data-origin-height="391"><span data-alt="Unreal Engine - Editor Settings General Global"><img src="/assets/images/posts/2024/05/05/84-1.png" loading="lazy" width="1612" height="391" data-origin-width="1612" data-origin-height="391"/></span><figcaption>Unreal Engine - Editor Settings General Global</figcaption>
</figure>
</p>

<p>모든 에디터에 영향을 끼치는 글로벌 설정이다.</p>
<p>이 설정 내용은 익스포터 하여 저장할 수 있으며 또한 저장된 파일을 임포트 하여 설정값을 불러올 수 있다.</p>
<p>변경된 설정은 프로젝트 폴더의 Saved &gt; Config 폴더에 저장된다.</p>

<h4>파생 데이터 캐시</h4>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="814" data-origin-height="169"><span data-alt="Unreal Engine - Editor Settings &amp;gt; DDC"><img src="/assets/images/posts/2024/05/05/84-2.png" loading="lazy" width="814" height="169" data-origin-width="814" data-origin-height="169"/></span><figcaption>Unreal Engine - Editor Settings &gt; DDC</figcaption>
</figure>
</p>

<p>파생 데이터 캐시(Derived Data Cache, DDC)는 개발 과정에서 생성되는 파생 데이터를 저장하는 시스템이다.</p>
<p>파생 데이터에는 텍스처의 압축된 버전, 셰이더의 컴파일된 버전 등을 말하여 이 캐시는 데이터의 재계산이나 재생성 없이 빠르게 로드할 수 있도록 도와줌으로 에디터 및 게임의 런타임 성능을 향상하고 전반적인 컴파일 시간을 단축하는 역할을 한다.</p>

<p>즉 에셋을 처음 처리할 때 필요한 계산을 수행하고 결과를 DDC에 저장하는데 이후 동일한 에셋을 다시 로드할 필요가 있을때 DDC에 저장된 경우 미리 계산된 이 데이터를 즉시 사용할 수 있어 시간을 단축할 수 있다.</p>

<p>빌드 시 재사용 가능한 데이터가 DDC에 존재하면 셰이더 컴파일이나 에셋 변환과 같은 시간 소모적인 작업을 생략할 수 있기 때문에 규모가 큰 프로젝트 같은 경우 작업 시간을 절약할 수 있다.</p>

<p>또한 DDC는 로컬뿐만 아니라 네트워크 상에서도 위치할 수 있기 때문에 이를 통해서 동일한 DDC를 공유할 수 있어 협업에서 모든 팀원이 동일한 파생 데이터에 접근이 가능하며 데이터의 일관성을 유지할 수 있다.</p>

<p>따라서 글로벌 로컬 DDC 패스, 글로벌 공유 DCC 경로 설정을 통해서 필요한 데이터를 더 빠르게 재구성할 수 있기 때문에 프로젝트의 이전 및 이식성의 효율성을 높일 수 있다.</p>

<p>글로벌로 설정하면 모든 에디터에서 공통적으로 적용되며 고급 설정을 확장하여 현재 프로젝트에서만 적용되는 설정을 할 수 있다.</p>

<h4>파생 데이터 캐시 알림</h4>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="766" data-origin-height="132"><span data-alt="Unreal Engine - Editor Settings &amp;gt; DDC Notification"><img src="/assets/images/posts/2024/05/05/84-3.png" loading="lazy" width="766" height="132" data-origin-width="766" data-origin-height="132"/></span><figcaption>Unreal Engine - Editor Settings &gt; DDC Notification</figcaption>
</figure>
</p>

<p>DDC와 관련된 작업이 수행될 때 알림을 받을 수 있도록 하는 기능으로 이 설정을 통해서 개발자가 DDC의 상태를 더 잘 파악하고 이해할 수 있도록 하여 관리를 돕는다.</p>

<p>이 기능은 수로 DDC 작업의 시작과 완료 과정에서 발생하는 에러 등을 실시간으로 알려주기 때문에 캐시가 올바르게 작동하고 있는지 또는 문제가 발생했는지를 즉시 파악할 수 있도록 모니터링할 수 있다.</p>

<p>DDC 작업의 모니터링을 통해서 성능에 미치는 영향을 파악하고 캐시된 데이터의 손상여부 확인이나 진단을 할 수 있어 문제의 원인을 빠르게 파악할 수 있기 때문에 성능 최적화와 작업의 효율성을 향상할 수 있다.</p>

<h4>파생 데이터 캐시 S3</h4>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="800" data-origin-height="82"><span data-alt="Unreal Engine - Editor Settings &amp;gt; DDC S3"><img src="/assets/images/posts/2024/05/05/84-4.png" loading="lazy" width="800" height="82" data-origin-width="800" data-origin-height="82"/></span><figcaption>Unreal Engine - Editor Settings &gt; DDC S3</figcaption>
</figure>
</p>

<p>DDC를 Amazon S3와 함께 사용하는 설정으로 대규모 게임 개발 프로젝트에서 주로 사용되는 설정이다.</p>
<p>S3는 Amazon Simple Storage Services로 AWS에서 제공하는 객체 스토리지 서비스로 인터넷을 통해 데이터를 저장하고 검색할 수 잇는 확장 가능한 스토리지 솔루션이다.</p>

<p>이 기능을 사용하면 어느 위치에서나 접근 가능한 중앙 집중식 DDC를 구축할 수 있기 때문에 전 세계에 분산된 팀원들이 동일한 파생 데이터에 액세스 하고 공유할 수 있다.</p>

<p>이 서비스는 높은 확정성을 제공하고 사용량에 따라 자동으로 저장 용량이 조정되기 때문에 대규모 데이터를 처리하는 상황에서도 안정적인 성능을 유지할 수 있다. 또한 데이터의 내구성과 가용성을 보장하기 위해 여러 지리적 위치에 데이터를 자동으로 복제하여 관리하기 때문에 게임 자산의 안전을 보장하며 데이터 손실의 위험을 최소화할 수 있다.</p>

<p>실제로 사용한 만큼의 비용을 지불하는 요금제를 제공하기 때문에 초기 투자 비용 없이 필요에 따라 스토리지를 조정할 수 있게 하여 비용의 효율성과 아마존의 네트워크 최적화와 캐싱 전략을 통해 빠른 데이터 액세스 속도를 제공한다.</p>

<p>이 설정을 사용하기 위해서는 우선 AWS 계정의 설정이 필요하다.</p>

<p><a href="https://aws.amazon.com/ko/pm/serv-s3/?trk=919c3162-c8f1-4d4c-baec-33fb3fcc1988&amp;sc_channel=ps&amp;ef_id=CjwKCAjw3NyxBhBmEiwAyofDYZ6i6XqYU7pWhrE39jq9azYVgbsWwgKXTOF1WMjDHH_MJqI_QGZcnRoC_AkQAvD_BwE:G:s&amp;s_kwcid=AL!4422!3!536452699328!e!!g!!aws%20s3!11547526035!116491964390" target="_blank" rel="noopener">AWS S3</a></p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="795" data-origin-height="267"><span data-alt="AWS 3S"><img src="/assets/images/posts/2024/05/05/84-5.png" loading="lazy" width="795" height="267" data-origin-width="795" data-origin-height="267"/></span><figcaption>AWS 3S</figcaption>
</figure>
</p>

<p>AWS S3에서 계정을 생성하고 언리얼에서 설정을 통해서 필요한 데이터를 3S 버킷에 저장하여 사용할 수 있다.</p>

<p>글로벌 로컬 S3DDC 패스에서 다운로드 패키지 번들의 로컬 캐시 위치를 설정할 수 있다. 이 설정은 컴퓨터의 전체 프로젝트에 영향을 미친다.</p>
