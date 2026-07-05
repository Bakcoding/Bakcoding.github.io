---
title: "네트워크의 시작"
excerpt: "네트워크의 시작"
categories:
  - Network
permalink: /computer-science/network/80-post/
tags:
  - "Network"
  - "Computer Science"
  - "iSP"
  - "LAN"
  - "Man"
  - "network"
  - "TSS"
  - "WAN"
toc: true
toc_sticky: true
date: 2024-04-16
last_modified_at: 2024-04-16
source_url: https://b-note.tistory.com/80
---

<h3>네트워크</h3>
<p>네트워크를 간단히 설명하자면, 우리가 일상적으로 인터넷에 접속하여 SNS, 뉴스, 동영상 등의 서비스를 사용하는 것과 같은 막연한 것들만 떠오르는데요. 간단하게 네트워크의 개념에 대해서 설명하자면 그물처럼 서로 연결된 노드들의 집합으로 정보와 자원을 공유하며 데이터를 교환하는 것입니다.&nbsp;</p>
<p><figure class="imageblock alignCenter" data-ke-mobileStyle="widthOrigin" data-origin-width="1024" data-origin-height="1024"><span><img src="/assets/images/posts/2024/04/16/80-1.webp" loading="lazy" width="404" height="404" data-origin-width="1024" data-origin-height="1024"/></span></figure>
</p>


<p>먼저 네트워크란 개념이 어떻게 시작되었는지 과거로 돌아가봅니다.</p>
<p>1960년대 컴퓨터의 성능은 어느정도 발전을 이루었지만 여전히 비싼 가격대로 아무나 사용할 수 없는 장치였습니다. 이 당시 하나의 컴퓨터를 여러 사용자가 공유할 수 있는 시스템이 제안됩니다. 이때 제안된 게 시분할 시스템(TSS, Time Sharing System)으로 한 명의 사람의 입력만 받고 처리하기에는 컴퓨터에게는 너무나 쉬운 작업이었기 때문에 이를 활용하여 여러 사람의 입력을 받고 처리하도록 최대한 컴퓨터의 능력을 활용하기 위해서 제안되었습니다. 여기서 각 사용자들에게 컴퓨터 자원을 시간적으로 분할하고 사용하게 하며 대화식 인터페이스를 통해서 출력이 사용자에게 표시되고 키보드를 통해 입력된 정보를 처리합니다. 그러나 이 아이디어는 시연까지는 되었지만 구축이 어렵고 비용이 많이 들었기 때문에 보편화되지 못했으나 아이디어를 활용해서 현재의 컴퓨터에서 동작하는 여러 가지의 시스템이 이러한 방식을 따르고 있습니다.</p>
<p><figure class="imageblock alignCenter" data-ke-mobileStyle="widthOrigin" data-origin-width="1024" data-origin-height="1024"><span data-alt="시분할 시스템 (TSS, Time Share System)"><img src="/assets/images/posts/2024/04/16/80-2.webp" loading="lazy" width="479" height="479" data-origin-width="1024" data-origin-height="1024"/></span><figcaption>시분할 시스템 (TSS, Time Share System)</figcaption>
</figure>
</p>

<p>TSS는 보급에는 실패했지만 현대에서도 사용되는 중요한 개념들을 정립하는 계기가 되었습니다.</p>
<p>- 자원공유 : 하나의 컴퓨터에 여러 사용자가 작업 할 수 있도록 하드웨어 자원의 효율적 사용</p>
<p>- 동시접근 : 여러 사용자가 동시에 컴퓨터에 접근 하고 데이터를 교환하는 상호작용할 수 있는 환경</p>
<p>- 분산처리 : 데이터와 처리 작업을 여러 컴퓨터 사이에서 나누어 처리</p>
<p>- 통신 프로토콜 : 여러 터미널과 중앙 컴퓨터 간의 효율적인 데이터 전송을 위한 규칙</p>

<p>이러한 개념들은 네트워크의 초석이 되기도했습니다.</p>

<h3>ARPANET(Advanced&nbsp; Research Projects Agency Network)</h3>
<p>알파넷은 냉전 시대의 군사적 요구와 과학 연구의 필요성에 의해 만들어졌습니다.</p>
<p>개발 당시 미국 정부는 소련과의 기술 경쟁에서 우위를 점하기 위해 정보 기술의 발전을 꾀했으며 여러 연구 기관 간의 효율적인 정보 교류가 필요했습니다. 이 알파넷의 주요 혁신 기술은 패킷 스위칭 기술입니다. 이는 대용량 데이터를 작은 패킷으로 나누어 각각을 다른 경로로 전송하고 목적지에서 재조립하는 방식입니다. 이 기술은 데이터 전송의 신뢰성과 효율성을 크게 향상하게 되었습니다.</p>

<p>알파넷은 처음에는 UCLA, 스탠퍼드 연구소(SRI), UC 샌타바버라, 유타 대학교 네 개의 노드를 연결하여 운영을 시작했습니다. 이 초기 네트워크는 매우 기본적인 구조로 컴퓨터 과학자들에게 네트워킹 기술을 실험하고 개발할 수 있는 플랫폼을 제공하는 역할을 했습니다.&nbsp;</p>

<p>그리고 네트워크 통신의 기본인 TCP/IP 프로토콜이 처음 개발되기도 했습니다. 이는 이후 인터넷 표준 프로토콜로 채택되어 현재까지도 전 세계적으로 사용되고 있습니다. 이 프로토콜은 복잡한 네트워크 구조를 상호 간의 연결을 가능하게 하는 기본적인 규칙에 대한 정의입니다.&nbsp;</p>

<p>이외에도 최초의 전자 메일 시스템의 도입과 같은 다양한 혁신을 가져왔습니다. 네트워크를 통한 정보의 자유로운 교환은 학문적 공동체와 연구의 방식을 변화시켰고 현대의 인터넷 문화와 디지털 통신의 기반이 되는 등 ARPANET 그 자체로 사회적, 기술적으로 막대한 변화를 촉진하는데 기여하였습니다.&nbsp;</p>

<h3>Telenet</h3>
<p>텔레넷은 알파넷의 주요 설계자 중 한 명인 Lawrence Roberts가 창립한 것으로 1970년대에 설립된 미국 최초의 상업적 패킷 스위칭 네트워크입니다. 알파넷이 군사적인 용도로 개발되었다면 텔레넷은 알파넷의 기술을 기반으로 하여 개발되었으며 일반 기업 및 개인 사용자들에게 네트워크 서비스를 상업적으로 제공하는 것을 목표로 하였습니다.&nbsp;</p>


<p>텔레넷에서도 패킷 스위칭 기술이 사용되었으며 당시 사용되는 여러 프로토콜들을 계층구조의 개념을 도입하여 체계화시킨 x.25 표준을 도입하여 다양한 네트워크와의 호환성을 보장했습니다.&nbsp;</p>

<p>특히 금융기관, 대학, 그리고 대기업들 사이에서 인기를 끌었으며 사용자들에게 원격으로 데이터베이스에 접근하고 파일을 전송하며 다른 네트워크 서비스를 이용할 수 있는 기능을 제공했습니다. 이 서비스는 정보의 접근성을 크게 향상하고 데이터 통신 비용을 줄이는데 크게 기여하기도 했습니다.</p>

<p>텔레넷은 상업적인 패킷 스위칭 네트워크로서의 성공이 증명되었으며 이후 다른 많은 상업 네트워크들의 등장에 큰 영향을 미쳤으며 기술적인 혁신뿐만 아니라 군사적 용도가 아닌 일반 사업 및 개인용으로도 널리 활용될 수 있음을 보여주면서 비즈니스 모델에서도 중요한 전환점을 제공하여 인터넷이 전 세계적으로 확산되기 이전에 디지털 통신의 가능성을 넓히는 데 중요한 역할을 했습니다.&nbsp;</p>

<h3>Ethernet</h3>
<p>이더넷은 로컬 에리어 네트워크(LAN) 기술의 한 형태로 오늘날 가장 널리 사용되는 네트워킹 기술 중 하나입니다. 이더넷은 1973년에 제록스 PARC(Xerox Palo Alto Research Center)의 로버트 메트칼프(Robert Metcalfe)와 그의 동료들에 의해 처음 개발되었으며 이 기술은 컴퓨터들이 데이터 패킷을 공유 미디어를 통해 서로 전송할 수 있도록 하는 데 초점을 맞추었습니다.&nbsp;</p>

<p>1970년대 초 제록스 PARC에서는 Alto라는 개인용 컴퓨터의 네트워킹 필요성을 인식하고 이를 해결하기 위한 방안으로 이더넷을 개발하기 시작했습니다. 메트칼프는 하와이 대학교의 ALOHAnet 무선 패킷 네트워크에서 영감을 받아 유선 환경에 적합한 네트워크를 설계하게 되었습니다.</p>
<p><figure class="imageblock alignCenter" data-ke-mobileStyle="widthOrigin" data-origin-width="220" data-origin-height="293"><span data-alt="PARC - Xerox Alto"><img src="/assets/images/posts/2024/04/16/80-3.jpg" loading="lazy" width="220" height="293" data-origin-width="220" data-origin-height="293"/></span><figcaption>PARC - Xerox Alto</figcaption>
</figure>
</p>
<p><i><span style="color: var(--bc-emphasis-muted)">제록스 알토는 데스크톱 메타포와 그래픽 사용자 인터페이스를 이용한 최초의 컴퓨터로 상업적인 프로젝트는 아니었지만 수십 년에 걸쳐 개인용 컴퓨터 특히 매킨토시와 썬 워크스테이션의 설계에 큰 영향을 주었습니다.</span></i></p>

<p>이더넷 기술은 계속해서 발전하여 초기 10 Mbps에서 기가비트 오늘날에는 10 기가비트 이상의 속도로 데이터를 전송할 수 있는 기술로 발전하였으며 또한 트위스티드 페어 케이블과 광섬유 케이블(Fiber-optic cable) 같은 다양한 전송 매체가 도입되기도 했습니다.</p>
<p><figure class="imageblock alignCenter" data-ke-mobileStyle="widthOrigin" data-origin-width="250" data-origin-height="250"><span data-alt="Twisted pair cable"><img src="/assets/images/posts/2024/04/16/80-4.jpg" loading="lazy" width="250" height="250" data-origin-width="250" data-origin-height="250"/></span><figcaption>Twisted pair cable</figcaption>
</figure>
<figure class="imageblock alignCenter" data-ke-mobileStyle="widthOrigin" data-origin-width="225" data-origin-height="225"><span data-alt="Fiber-optic cable"><img src="/assets/images/posts/2024/04/16/80-5.jpg" loading="lazy" width="225" height="225" data-origin-width="225" data-origin-height="225"/></span><figcaption>Fiber-optic cable</figcaption>
</figure>
</p>

<p>현대에서 이더넷은 <span style="text-align: start">표준화와 호환성이 높아 다양한 네트워크 장비와 시스템에서 손쉽게 구현할 수 있어</span> 광범위한 기업 환경은 물론 가정과 학교 등 다양한 곳에서 LAN을 구축할 때 기본적으로 사용되는 기술입니다. 간단한 개념과 구현의 용이성으로 인해 수십 년 동안 기술의 중심에 있었으며 네트워킹의 가장 기본적이고 중요한 기술 중 하나로 자리 잡게 되었습니다.</p>

<h3>네트워크 케이블</h3>
<p>이러한 네트워크의 연결을 위해서는 정보를 주고받을 수 있도록 물리적인 장치가 필요합니다.&nbsp;</p>

<h4>FLAG (Fiber-Optic Link Around the Globe) = FEA(Fiber-Optic Europe-Asia)</h4>
<p>1990년대 후반 FLAG 해저 케이블 시스템은 아시아, 중동을 연결하는 글로벌 통신망 프로젝트로 1997년에 완공되었습니다. 이 케이블 시스템은 주로 대륙 간 데이터 통신 수요를 충족시키기 위해 설계되었으며 여러 국가와 대륙을 연결하는 역할을 합니다. 이 중 한국 또한 이 케이블 시스템의 주요 노드 중 하나가 되었습니다.</p>

<p>약 28,000 킬로미터에 달하는 광섬유 케이블로 구성되어 있으며 영국에서 출발하여 유럽, 중동, 아시아를 거쳐 일본까지 이어지는 것으로 북아메리카와 아시아를 연결하는 주요 노선 중 하나입니다. 주요 연결 지점(Node)으로는 영국, 프랑스, 이탈리아, 이집트, 사우디아라비아, 아랍에미리트, 인도, 태국, 말레이시아, 싱가포르, 홍콩, 대만, 한국, 일본 등의 해안 도시들과 연결되어 있습니다.</p>

<p>현재는 FEA로 초기 FLAG 시스템이 더 많은 국가와 지역을 포괄하였지만 <span style="text-align: start">경제적 중요성에 따라서<span> </span></span>유럽과 아시아 지역 간의 특정 연결성의 강화에 의해서 FEA로 변경되기도 했습니다.</p>

<p>이외에도 아시아 태평양 지역의 여러 국가들을 연결하는 APCN(Asia Pacific Cable Network) 등 필요와 기술의 발전에 따라서 추가로 케이블들이 설치되기도 했습니다.</p>

<p>통신망은 규모에 따라 다양하게 분류됩니다.</p>
<h4>LAN(Local Area Network)</h4>
<p>근거리 통신망으로 가까운 거리에 있는 단말 간의 네트워크를 말합니다. 한정된 공간 내에 분산 설치되어 있는 단말을 통신회선 연결을 통해 상호작용 가능하게 한 네트워크로 단일 구성은 거리적으로 한정되지만 복수의 근거리 통신망을 설치하여 대형 네트워크를 형성하게 됩니다. 이때 다른 종류의 LAN은 게이트워이라는 통로를 통해서 연결되어 사용하게 됩니다.</p>

<h4>MAN(Metropolitan Area Network)</h4>
<p>도시권 통신망으로 근거리 통신망이 1개 기업의 범위 또는 빌딩 전체를 연결하는 네트워크라면 도시권 통신망은 이를 확장하여 하나의 도시 내로 확장한 네트워크입니다. 초기 통신망이 구축되었을 때는 존재하지 않았지만 휴대전화의 보급으로 인해서 각 도시마다 네트워크를 구축할 필요가 생기게 되어서 기지국이 생기게 되었는데 이 기지국을 칭하는 개념으로 생겨나게 되었습니다. 도시권 통신망은 다른 도시권 통신망과 직접적으로 연결되어 있습니다.</p>

<h3>WAN(Wide Area Network)</h3>
<p>광역 통신망으로 도시 간 또는 국가 간 등을 연결하는 통신망입니다. 대부분 통신사가 전국에 회선을 깔아서 구축한 통신망으로 가장 최상위 규모의 통신망입니다. 일반적으로 개인이 네트워크에 연결될 때는 대부분 LAN을 통해 이루어집니다. 그리고 연결하고자 하는 네트워크의 범위에 따라서 MAN을 거치거나 WAN을 거쳐 목적지에 도착하게 되는데 이때 ISP를 거치게 됩니다. 우리가 특정 사이트를 방문하다 보면 연결이 차단되기도 하는데 이것은 ISP에 의해서 관리를 받기 때문입니다.</p>

<p><figure class="imageblock alignCenter" data-ke-mobileStyle="widthOrigin" data-origin-width="550" data-origin-height="316"><span><img src="/assets/images/posts/2024/04/16/80-6.png" loading="lazy" width="550" height="316" data-origin-width="550" data-origin-height="316"/></span></figure>
</p>

<p>이외에도 기업에서 통신사로부터 회선을 임대받아 광역 통신망 간의 직접 연결한 경우도 있으며 대표적으로 인트라넷이 이러한 경우입니다.&nbsp;</p>
<h4>&nbsp;</h4>
<h4>ISP(Internet Service Provider)</h4>
<p>인터넷 서비스 제공자로 개인, 기업, 정부 등 고객을 대상으로 인터넷 접속 서비스를 제공하는 회사나 조직을 말합니다. 대한민국의 경우 KT, SKT, LG 등의 통신사들의 인터넷 서비스를 ISP라고 볼 수 있습니다.</p>
