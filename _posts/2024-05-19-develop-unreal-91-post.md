---
title: "언리얼 엔진 - 에디터 개인설정 - 일반 로드&저장"
excerpt: "언리얼 엔진 - 에디터 개인설정 - 일반 로드&저장"
categories:
  - Unreal
permalink: /develop/unreal/91-post/
tags:
  - "Unreal"
  - "Game Development"
  - "editor setting"
  - "load&save"
  - "Unreal Engine"
  - "불러오기&저장"
  - "언리얼 엔진"
  - "에디터 세팅"
toc: true
toc_sticky: true
date: 2024-05-19
last_modified_at: 2024-05-19
source_url: https://b-note.tistory.com/91
---

<h2>로드&amp;저장</h2>
<p>에디터의 파일 로드 및 저장 방식을 변경한다.</p>

<h2>시작</h2>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="830" data-origin-height="138"><span data-alt="Unreal Engine - Editor Setting - Load&amp;amp;Save - Start"><img src="/assets/images/posts/2024/05/19/91-1.png" loading="lazy" width="830" height="138" data-origin-width="830" data-origin-height="138"/></span><figcaption>Unreal Engine - Editor Setting - Load&amp;Save - Start</figcaption>
</figure>
</p>

<p>에디터가 시작될 때의 동작을 제어하는 옵션이다.&nbsp;</p>
<p>이 설정들은 에디터가 시작될 때 어떤 프로젝트를 로드할지, 초기 상태를 어떻게 설정할지를 결정한다.</p>

<h3>시작 시 가장 최근에 로드했던 프로젝트 로드</h3>
<p>에디터가 시작될 때 자동으로 가장 최근에 로드한 프로젝트를 불러온다.</p>
<p>개발자는 매번 프로젝트를 수동으로 선택할 필요 없이 가장 최근에 작업한 프로젝트를 즉시 로드할 수 있다.</p>

<h3>시작 시 레벨 로드</h3>
<p>에디터가 시작될 때 특정 레벨을 자동으로 로드하는 기능을 제공한다.</p>
<p>작업 중인 레벨을 설정하여 자동으로 해당 레벨을 로드하게 할 수 있어 편의를 제공한다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="126" data-origin-height="75"><span data-alt="Save &amp;amp; Load - Start Level Option"><img src="/assets/images/posts/2024/05/19/91-2.png" loading="lazy" width="126" height="75" data-origin-width="126" data-origin-height="75"/></span><figcaption>Save &amp; Load - Start Level Option</figcaption>
</figure>
</p>

<p>옵션에는 세 가지가 있다.</p>

<p><b>None</b></p>
<p>에디터 시작 시 어떠한 레벨도 자동으로 로드하지 않는다.</p>

<p><b>Project Default&nbsp;</b></p>
<p>프로젝트 설정에서 기본으로 지정한 맵을 로드 한다.</p>
<p>편집 &gt; 프로젝트 세팅 &gt; 맵 &amp; 모드에서 설정할 수 있다.</p>

<p><b>Last Opened</b></p>
<p>기본 설정된 옵션으로 에디터가 시작될 때 마지막으로 열었던 맵을 자동으로 로드한다.</p>
<p>마지막으로 작업하던 맵을 자동으로 불러오기 때문에 이어서 작업하기에 유용하다.</p>

<h3>시작 시 강제 컴파일</h3>
<p>에디터가 시작될 때 블루 프린트를 자동으로 컴파일하는 기능을 제공한다. 이를 통해 블루 프린트의 최신 상태를 유지하고, 에디터가 시작될 때 컴파일 오류를 미리 발견할 수 있다. 블루 프린트를 자주 수정하는 경우 유용하다.</p>

<h3>재시작 시 에셋 열기 탭 복원</h3>
<p>에디터를 재시작할 때 이전에 열려 있던 에셋 탭을 자동으로 복원하는 기능이다.</p>
<p>이전 작업 환경을 그대로 유지하고 다시 시작할 때 동일한 상태에서 작업을 이어갈 수 있도록 한다.</p>

<h2>Auto Reimport</h2>
<p><figure class="imageblock alignCenter" data-ke-mobileStyle="widthOrigin" data-origin-width="896" data-origin-height="321"><span data-alt="Unreal Engine - Editor Setting - Load&amp;amp;Save - Auto Reimport"><img src="/assets/images/posts/2024/05/19/91-3.png" loading="lazy" width="896" height="321" data-origin-width="896" data-origin-height="321"/></span><figcaption>Unreal Engine - Editor Setting - Load&amp;Save - Auto Reimport</figcaption>
</figure>
</p>

<p>에디터가 프로젝트 디렉터리에서 파일 변화를 자동으로 감지하고 외부에서 변경된 파일을 자동으로 다시 임포트 하여 개발자의 작업 효율성을 높이는 데 사용되는 설정이다.</p>

<h3>콘텐츠 디렉터리 모니터</h3>
<p>디렉터리의 변화를 감지하고 외부에서 파일이 변경될 때 자동으로 해당 파일을 다시 임포트 하도록 설정하는 기능이다.</p>

<h3>고급</h3>
<p>고급탭을 펼치면 추가 세부 설정이 가능하다.</p>

<h4>모니터링할 디렉터리</h4>
<p>모니터링할 디렉터리를 배열로 추가할 수 있다.</p>

<h4>인덱스<b></b></h4>
<p>인덱스는 모니터링할 디렉터리 배열에서 특정 디렉터리를 식별할 수 있는 인덱스이다.</p>
<p>여러 디렉터리를 모니터링할 때 각 디렉터리를 구분하고 관리하는 데 사용되며 다수의 디렉터리를 모니터링할 때 특정 디렉터리 설정을 식별하고 수정할 필요가 있을 때 유용하다.&nbsp;</p>

<h4>와일드카드 포함/제외</h4>
<p>특정 파일 패턴을 포함하거나 제외하도록 지정하는 옵션이다.</p>
<p>와일드카드는 파일 이름 패턴을 지정할 때 사용되는 특수 문자로 다양한 파일 이름을 일괄 처리할 수 있다.</p>

<p><b>한계치 시간 임포트</b></p>
<p>파일 변경 후 일정 시간이 지나야 만 자동 임포트가 시작되도록 지연 시간을 설정한다.</p>
<p>파일이 완전히 저장되기 전에 임프토가 시작되는 것을 방지할 수 있으며 대형 파일이나 복잡한 에셋을 저장할 때 완전히 저장되지 않은 상태에서 임포트가 시작되지 않도록 하고자 할 때 유용하다.</p>
<p>시간은 초 단위로 설정할 수 있다.</p>

<p><b>에셋 자동 생성</b></p>
<p>모니터링하는 디렉터리에 새로운 파일이 추가되면 자동으로 해당 파일을 임포트 하여 에셋을 생성하는 기능이다.</p>
<p>새로운 파일이 자주 추가되는 프로젝트에서 파일을 수동으로 임포트 하는 시간을 절약할 수 있다.</p>

<p><b>에셋 자동 삭제</b></p>
<p>모니터링하는 디렉터리에서 파일이 삭제되면 해당 파일에 대응하는 에셋을 자동으로 삭제하는 기능이다. 프로젝트 파일 구조를 정리하고 불필요한 에셋을 자동으로 정리할 때 유용하다.</p>

<p><b>시작 시 변경 사항 탐지</b></p>
<p>에디터가 시작될 때 모니터링하는 디렉터리의 파일 변화를 감지하고 불필요한 경우 자동으로 임포트를 수행한다.</p>

<p><b>행동 전에 알림 표시</b></p>
<p>자동 임포트, 자동 삭제 등의 작업을 수행하기 전에 사용자에게 확인을 요청하는 알림을 표시한다.</p>
<p>이를 통해 사용자는 자동으로 수행될 작업을 확인하고 승인할 수 있어 임포트나 삭제 작업이 중요한 상황에서 실수로 인한 작업 손실을 방지할 수 있다.</p>

<h2>블루프린트</h2>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="724" data-origin-height="50"><span data-alt="Unreal Engine - Editor Setting - Load&amp;amp;Save - BluePrint"><img src="/assets/images/posts/2024/05/19/91-4.png" loading="lazy" width="724" height="50" data-origin-width="724" data-origin-height="50"/></span><figcaption>Unreal Engine - Editor Setting - Load&amp;Save - BluePrint</figcaption>
</figure>
</p>

<p>블루프린트가 변경되었음을 인식하고 이러한 변경 사항을 추적하여 필요에 따라 블루프린트를 다시 저장하거나 다른 블루프린트로 변경 사항을 전달하는 데 사용된다.</p>

<h3>더티 이주 블루프린트(Dirty Migration Blueprint)</h3>
<p><b>더티 상태(Dirty State)</b></p>
<p>블루프린트가 수정되었지만 아직 저장되지 않은 상태를 더티 상태라고 한다.&nbsp;</p>
<p>이 상태에서는 블루프린트에 변경 사항이 있지만 파일이 저장되어있지 않기 때문에 다른 블루프린트나 시스템에 반영되지 않는다.</p>

<p><b>이주(Migration)</b></p>
<p>블루프린트의 변경 사항을 다른 관련 블루프린트나 시스템으로 전하는 과정을 의미한다. 블루프린트 간의 의존성을 관리하고 변경된 내용을 일관되게 유지하기 위해 중요하다.</p>

<p>이 설정의 주요 목적은 블루프린트가 변경되었을 때 이를 추적하여 변경 사항이 있는 블루프린트를 저장하도록 한다.</p>
<p>이를 통해서 작업 도중 발생할 수 있는 데이터 손실을 방지하고 항상 최신 상태의 블루프린트를 유지할 수 있다.</p>

<p>한 블루프린트의 변경 사항이 다른 관련 블루프린트에도 반영되도록 의존성을 관리하여 부모 블루프린트가 변경되었을 때 이를 상속하는 자식 블루프린트에도 변경 사항을 전달한다.</p>

<h2>자동저장</h2>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="800" data-origin-height="276"><span data-alt="Unreal Engine - Editor Setting - Load&amp;amp;Save - Auto Save"><img src="/assets/images/posts/2024/05/19/91-5.png" loading="lazy" width="800" height="276" data-origin-width="800" data-origin-height="276"/></span><figcaption>Unreal Engine - Editor Setting - Load&amp;Save - Auto Save</figcaption>
</figure>
</p>

<p>작업하는 동안 프로젝트 파일과 에디터 상태를 주기적으로 자동 저장하여 예상치 못한 데이터 손실을 방지하고 작업 효율성을 높일 수 있다.</p>

<h3>자동 저장 활성화</h3>
<p>자동 저장 기능을 켜거나 끈다. 활성화 시 설정된 주기마다 자동으로 저장 작업을 수행한다.</p>

<h3>맵 저장</h3>
<p>자동 저장 시 맵 파일을 저장할지 여부를 설정한다.</p>

<h3>콘텐츠 저장</h3>
<p>자동 저장 시 콘텐츠 파일을 저장할지 여부를 설정한다.</p>

<h3>분 단위 주파수</h3>
<p>자동 저장이 실행되는 간격을 분단위로 설정한다.</p>

<h3>인터랙션 딜레이 초&nbsp;</h3>
<p>경고 창의 대기 시간을 초 단위로 설정한다.</p>

<h3>초 단위 경고</h3>
<p>자동 저장 시작 전에 사용자에게 경고를 표시하는 시간을 초 단위로 설정한다.</p>

<h3>최대 자동 저장 수</h3>
<p>자동 저장 파일의 최대 개수를 설정한다.</p>

<h3>저장 방식</h3>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="150" data-origin-height="76"><span data-alt="Unreal Engine - Editor Setting - Load&amp;amp;Save - Auto Save - Save Method
 
자"><img src="/assets/images/posts/2024/05/19/91-6.png" loading="lazy" width="150" height="76" data-origin-width="150" data-origin-height="76"/></span><figcaption>Unreal Engine - Editor Setting - Load&amp;Save - Auto Save - Save Method
 
자</figcaption>
</figure>
</p>
<p>자동 저장 시 사용되는 저장 방식을 설정한다.&nbsp;</p>
<p>Backup and Restore과 Backup and Overwrite 선택 옵션이 있다.</p>

<p><b>Backup and Restore </b></p>
<p>저장할 파일의 백업을 생성하고 필요시 백업을 복원하는 방식이다. 자동 저장이 수행되기 전에 현재 파일의 백업을 생성하고 필요시 백업 파일을 사용하여 이전 상태로 복원할 수 있다.&nbsp;</p>

<p><b> Backup and Overwrite </b></p>
<p>기존 파일의 백업을 생성한 후 변경된 파일로 기존 파일을 덮어쓰는 방식이다. 주로 변경된 내용을 빠르게 저장하면서도 기본적인 백업을 유지하려는 목적으로 사용된다. 변경된 파일을 직접 덮어쓰기 때문에 저장 속도가 빠르지만 복원 가능한 버진이 한정적이다.</p>

<h2>소스 컨트롤</h2>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="824" data-origin-height="160"><span data-alt="Unreal Engine - Editor Setting - Load&amp;amp;Save - Auto Save"><img src="/assets/images/posts/2024/05/19/91-7.png" loading="lazy" width="824" height="160" data-origin-width="824" data-origin-height="160"/></span><figcaption>Unreal Engine - Editor Setting - Load&amp;Save - Auto Save</figcaption>
</figure>
</p>

<p>프로젝트 파일의 버전 관리 및 협업을 용이하게 하기 위한 여러 옵션을 제공한다. 이 설정들은 소스 컨트롤 시스템과 통합하여 파일 변경 사항을 관리하고 개발자 간의 충돌을 방지하는 데 도움을 준다.&nbsp;</p>

<h3>에셋 수정 시 자동 체크 아웃</h3>
<p>에셋을 수정할 때 자동으로 소스 컨트롤에서 해당 에셋을 체크 아웃하는 기능을 제공한다. 체크 아웃은 파일을 수정 가능 상태로 만들고 다른 사용자가 동시에 동일한 파일을 수정하지 못하도록 한다. 활성화 시 에셋을 수정할 때 자동으로 소스 컨트롤에서 체크 아웃이 수행된다.&nbsp;</p>

<h3>에셋 수정 시 자동 체크 아웃 알림 표시</h3>
<p>에셋을 수정하고 자동 체크 아웃이 발생할 때 사용자에게 알림을 표시한다.&nbsp;</p>

<h3>변경 시 새 파일 추가</h3>
<p>프로젝트 내에서 새 파일이 생성될 때 자동으로 소스 컨트롤에 추가하는 기능을 제공한다. 새로운 파일이 변경되거나 생성될 때 소스 컨트롤 시스템에 자동으로 추가된다. 옵션을 활성화하면 새로운 파일이 생성될 때 자동으로 소스 컨트롤 시스템에 추가된다.&nbsp;</p>

<h3>글로벌 세팅 사용</h3>
<p>프로젝트별 소스 컨트롤 설정 대신 전역 설정을 사용하도록 설정한다. 전역 설정은 여러 프로젝트에 걸쳐 동일한 소스 컨트롤 설정을 적용하는 데 유용하다.</p>


<h3>텍스트 비교 툴</h3>
<p>텍스트 파일을 diffing(비교) 하는 데 사용할 도구의 파일 경로를 지정한다.&nbsp;</p>
<p>즉 시스템에서 파일의 변경 사항을 비교하고 시각화하는 데 사용할 도구를 지정하는 설정이며 사용자가 원하는 외부 텍스트 비교 도구의 실행 파일을 지정할 수 있다.</p>
