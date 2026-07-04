---
title: "언리얼 엔진 - 에디터 개인설정 - 일반 기타 (1)"
excerpt: "언리얼 엔진 - 에디터 개인설정 - 일반 기타 (1)"
categories:
  - Unreal
permalink: /develop/unreal/88-1/
tags:
  - "Unreal"
  - "Game Development"
  - "editor setting"
  - "UE"
  - "Unreal Engine"
  - "언리얼 엔진"
  - "에디터 설정"
toc: true
toc_sticky: true
date: 2024-05-18
last_modified_at: 2024-05-18
source_url: https://b-note.tistory.com/88
---

<h2>Developer Tools</h2>
<p>에디터에서 개발자를 위한 설정들이 제공된다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="722" data-origin-height="119"><span data-alt="Unreal Engine - Editor Settings&amp;nbsp;Miscellaneous"><img src="/assets/images/posts/2024/05/18/88-1.png" loading="lazy" width="722" height="119" data-origin-width="722" data-origin-height="119"/></span><figcaption>Unreal Engine - Editor Settings&nbsp;Miscellaneous</figcaption>
</figure>
</p>


<h3>UI 익스텐션 포인트 디스플레이</h3>
<p>이 설정을 활성화하면 에디터에서 추가적인 UI 정보가 표시된다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="631" data-origin-height="93"><span data-alt="Unreal Engine - UI Extension Pointer Display"><img src="/assets/images/posts/2024/05/18/88-2.png" loading="lazy" width="631" height="93" data-origin-width="631" data-origin-height="93"/></span><figcaption>Unreal Engine - UI Extension Pointer Display</figcaption>
</figure>
</p>

<h3>문서 링크 디스플레이</h3>
<p>해당 설정을 활성화하면 마우스 호버시 보이는 툴팁에 추가로 문서 페이지가 제공된다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="683" data-origin-height="122"><span data-alt="Unreal Engine - Docs link display"><img src="/assets/images/posts/2024/05/18/88-3.png" loading="lazy" width="683" height="122" data-origin-width="683" data-origin-height="122"/></span><figcaption>Unreal Engine - Docs link display</figcaption>
</figure>
</p>

<h3>프로젝트 배지에 엔진 버전 번호 디스플레이</h3>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="335" data-origin-height="63"><span data-alt="Unreal Engine - Engine version number display"><img src="/assets/images/posts/2024/05/18/88-4.png" loading="lazy" width="335" height="63" data-origin-width="335" data-origin-height="63"/></span><figcaption>Unreal Engine - Engine version number display</figcaption>
</figure>
</p>

<p>엔진 버전 번호가 추가로 표시된다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="343" data-origin-height="116"><span data-alt="Unreal Engine - Engine version number display"><img src="/assets/images/posts/2024/05/18/88-5.png" loading="lazy" width="343" height="116" data-origin-width="343" data-origin-height="116"/></span><figcaption>Unreal Engine - Engine version number display</figcaption>
</figure>
</p>

<h2>AI</h2>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="701" data-origin-height="86"><span data-alt="Unreal Engine - Engine AI"><img src="/assets/images/posts/2024/05/18/88-6.png" loading="lazy" width="701" height="86" data-origin-width="701" data-origin-height="86"/></span><figcaption>Unreal Engine - Engine AI</figcaption>
</figure>
</p>

<h3>비헤이비어 트리 디버거 데이터 항상 수집</h3>
<p>이 설정은 특정 디버깅 기능과 관련된 옵션으로 AI 컴포넌트의 일부인 비헤이비어 트리(Behaviour Tree)의 동작을 실시간으로 모니터링하고 분석하는 데 사용할 수 있다. 비헤이비어 트리는 주로 NPC나 기타 게임 내 인공지능 캐릭터의 행동을 제어하는 데 사용된다.</p>

<p>설정을 활성화하면 에디터나 게임이 실행되는 동안 비헤이비어 트리의 모든 활동과 상태 변화가 지속적으로 기록되는데 이는 개발자가 AI의 행동 패턴을 더 잘 이해하고 문제를 진단하는데 도움 받을 수 있다.</p>

<p>유용한 기능이지만 데이터를 항상 수집하기 때문에 성능에 영향을 줄 수 있다. 데이터 수집 과정에서 추가적인 처리가 필요하기 때문에 특히 대규모 AI 시스템을 사용하는 게임에서는 성능 저하에 유의해야 한다.</p>

<p>일반적으로 이 설정은 개발 중이나 테스트 단계에서 문제를 해결하기 위한 디버깅 용도로 사용되며 성능을 위해서 릴리즈 버전에서는 비활성화하는 것이 좋다. 수집된 데이터는 언리얼 엔진의 디버거 도구를 통해 시각적으로 표현될 수 있으며 이를 통해 개발자는 비헤이비어 트리의 각 노드에서 발생하는 결정과 변경사항을 보다 쉽게 추적할 수 있다.</p>

<h3>블랙보드 키를 알파벳 순으로 디스플레이</h3>
<p>비헤이비어 트리의 블랙보드에서 사용되는 키들을 알파벳 순서로 정렬하여 표시하도록 설정하는 기능으로 블랙보드의 데이터를 관리하고 검토할 때 편의성을 높이기 위해 사용된다.</p>

<p>많은 수의 키가 있을 때 알파벳 순으로 정렬하면 필요한 키를 빠르고 쉽게 찾을 수 있고 키들을 체계적으로 정리하여 블랙보드를 보다 효과적으로 관리할 수 있어 가독성과 관리 용이성을 향상할 수 있다.&nbsp;</p>

<p>비헤이비어 트리 디버거 데이터 항상 수집과 블랙보드 키를 알파벳 순으로 디스플레이 설정은 사용 중인 트리와 블랙보드의 수가 많을 때 유의미한 결과를 확인할 수 있기 때문에 어떤 식으로 표시되는지 정보에 대한 확인은 이후에 다시 작성하도록 한다.</p>

<h2>Simplygon Swarm</h2>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="724" data-origin-height="217"><span data-alt="Unreal Engine - Engine Simply Swarm"><img src="/assets/images/posts/2024/05/18/88-7.png" loading="lazy" width="724" height="217" data-origin-width="724" data-origin-height="217"/></span><figcaption>Unreal Engine - Engine Simply Swarm</figcaption>
</figure>
</p>

<p>언리얼 엔진에서는 3D 모델 최적화와 자동 LOD 생성을 위한 소프트웨어인 Simplygon을 사용한다.</p>
<p>Simplygon을 통해서 게임 내에서 3D 모델의 성능을 향상하기 위해 다양한 디테일 레벨을 자동으로 생성하고 관리할 수 있다.&nbsp;</p>

<p>Simplygon Swarm은 이러한 Simplygon과 관련된 데이터를 분산처리하는 시스템이다. Simplygon은 주로 3D 모델의 폴리곤 수를 줄이는 데 사용되며, 고품질의 LOD(Level of Detail) 모델을 생성하는 데 이러한 최적화 작업을 여러 대의 컴퓨터에 분산시켜 작업 효율성을 극대화한다.</p>

<h3>Simplygon 배포 프록시 서버 사용</h3>
<p>Simplygon Swarm은 위 작업을 위해서 제안된 기능으로 해당 설정을 활성화하면 작업 처리와 데이터 관리에 있어 중앙 집중화된 접근 방식을 취하게 된다. 배포되기 전 개발 단계에서 사용되는 도구이며 개발 단계에서 자원의 효율성을 증가시키기 위해서 사용한다. 이 설정을 활성화해야 관련된 다른 설정들도 활성화된다.</p>

<h3>Simplygon 배포 프록시 서버 IP</h3>
<p>분산처리 작업을 위한 프록시 서버 IP를 설정한다.</p>
<p>프록시 서버는 Simplygon Swarm의 네트워크 통신 허브로 작업을 여러 에이전트(작업을 실제로 수행하는 컴퓨터)에게 분산하는 중추 역할을 한다. 이 서버는 각 에이전트의 상태를 모니터링하고 최적의 분산 전략을 수립하여 작업을 효율적으로 할당한다.&nbsp;</p>

<p>프록시 서버는 각 에이전트의 리소스 사용 상태를 파악하여 특정 에이전트에 과부하가 걸리지 않도록 작업을 분산하여 전체 시스템의 효율성을 높이고 작업 시간을 최소화하는 데 도움을 준다.</p>

<h3>스웜 디버깅 활성화</h3>
<p>Simplygon Swarm에서 분산 처리 작업을 진행할 때 발생하는 다양한 이벤트와 오류를 모니터링하고 로깅하는 기능이다.</p>
<p>이 설정을 활성화하면 시스템의 동작을 보다 상세하게 이해할 수 있으며 발생하는 문제들을 신속하게 진단하고 해결하는데 도움을 준다.</p>

<p>- 작업 중 발생하는 네트워크 문제, 데이터 처리 오류, 작업 실행 실패 등의 오류를 기록하여 오류를 추적한다.</p>
<p>- 작업 할당, 데이터 전송, 작업 완료 등의 이벤트가 발생할 때마다 로그에 기록되는 이벤트 로깅을 통해서 시스템의 전반적인 흐름과 작업 처리 상태를 확인할 수 있다.</p>
<p>- 시스템의 성능을 실시간으로 모니터링하면서 성능 지표를 기록하여 시스템 최적화와 자원 할당에 중요한 정보를 얻을 수 있다.</p>
<p>- 디버깅 데이터를 분석하여 시스템의 성능을 향상하거나 잠재적인 문제를 사전에 파악하고 수정하는 데 사용할 수 있다.</p>

<h3>MS 단위 시간 json 요청 간 딜레이</h3>
<p>Simplygon Swarm의 각 노드 간에 발생하는 JSON 데이터 요청들 사이에 설정된 딜레이를 의미한다. 밀리 세컨드 단위로 설정할 수 있으며(기본 5000ms) 네트워크 트래픽을 조절하고 서버의 부하를 관리할 수 있다.</p>

<p>효율적인 시스템 관리와 최적의 성능 유지를 위한 설정 중 하나로 데이터 처리와 네트워크 통신의 안정성을 보장하고 전체적인 시스템 운영의 효율성을 높일 수 있다.</p>

<p>Swarm 시스템에서는 다수의 노드가 서로 데이터를 요청하고 응답하는 과정에서 네트워크 트래픽이 급격히 증가할 수 있는데 이때 딜레이를 설정함으로써 요청이 일정한 간격으로 이루어지게 하여 네트워크의 과부하를 방지한다. 딜레이를 통해 각 요청이 처리되기까지의 시간을 일정하게 하여 서버가 한꺼번에 많은 요청을 처리해야 하는 부담을 줄인다. 이는 서버의 안정적인 운영을 도와주고 시스템의 전반적인 응답성을 개선한다.</p>

<p>너무 많은 요청이 짧은 시간 내에 발생할 경우 일부 요청이 실패할 가능성이 있어 딜레이를 적절히 설정하여 요청 실패율을 줄일 수 있다. 네트워크와 서버의 처리 능력을 고려하여 딜레이를 설정해야 하며 너무 짧은 딜레이는 시스템에 과부하를 주며 너무 긴 딜레이는 전체 작업의 처리 속도를 저하시킨다. 딜레이 설정 후에도 시스템의 성능과 안정성을 지속적으로 모니터링하고 필요에 따라 딜레이 값을 조정하는 것이 중요하다.</p>

<h3>Simplygon 그리드 서버에 제출할 동시 작업 수</h3>
<p>서버에서 동시에 처리할 수 있는 작업의 수를 지정하는 설정이다. 이 설정은 Simplygon Swarm의 작업 분산 및 처리 효율성을 관리한다. 서버의 리소스를 효율적으로 활용하기 위해 동시에 실행할 수 있는 작업의 수를 조정하여 서버의 처리 능력과 메모리 사용을 고려하여 작업의 처리 속도를 타협하여 균형 있게 조절할 수 있다.&nbsp;</p>

<h3>Simplygon 스웜 zip 파일 최대 업로드 용량(MB)</h3>
<p>Simplygon 그리드 서버로 업로드할 수 있는 zip 파일의 최대 크기를 제한하는 설정이다.</p>
<p>이는 서버의 데이터 처리 능력과 네트워크의 대역폭 저장 공간 등을 고려하여 설정하여 네트워크 트래픽과 서버의 저장 공간을 효율적으로 관리한다. 최대 용량보다 큰 파일은 청크로 분할된다.</p>

<p>서버가 한 번에 처리할 수 있는 데이터 양을 제한하여 서버의 과부하를 방지하고 데이터 처리 효율을 유지하며 대용량 파일의 업로드가 네트워크에 미치는 영향을 최소화한다. 시스템의 안정성을 유지하기 위해 각 사용자가 업로드할 수 있는 파일의 크기를 제한함으로써 서버에 발생할 수 있는 예기치 않은 문제들을 사전에 방지한다.</p>

<h3>Simplygon 스웜 Intermediate 폴더</h3>
<p>작업의 중간 데이터를 저장하는 경로를 지정하는 설정이다. 3D 모델 최적화 프로세스 동안 생성되는 임시 파일들이나 처리 중인 데이터를 보관하는 장소로 사용되며 스웜에 업로드되는 중간 텍스처와 메시 데이터가 저장된다.</p>

<p>처리 중인 3D 모델의 데이터를 체계적으로 관리하여 프로세스의 효율성을 높이고 데이터 접근성을 개선하여 데이터를 조직화하고 프로세스 중 생성되는 임시 파일들을 별도의 위치에 저장함으로써 최종 출력 파일과 중간 파일을 명확히 구분할 수 있어 이는 작업의 명확성과 추적성을 향상해 작업의 효율성을 향상한다. 대용량 데이터의 경우 처리 시 시스템의 리소스를 효과적으로 활용하고 서버의 부하를 분산시키는 역할을 한다.</p>
