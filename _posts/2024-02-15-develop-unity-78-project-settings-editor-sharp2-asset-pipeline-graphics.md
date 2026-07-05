---
title: "Project Settings - Editor #2 (Asset Pipeline ~ Graphics)"
excerpt: "Project Settings - Editor #2 (Asset Pipeline ~ Graphics)"
categories:
  - Unity
permalink: /develop/unity/78-project-settings-editor-sharp2-asset-pipeline-graphics/
tags:
  - "Unity"
  - "Game Development"
toc: true
toc_sticky: true
date: 2024-02-15
last_modified_at: 2024-02-15
source_url: https://b-note.tistory.com/78
---

<p>에디터 버전 : 2021.3.28f1 (LTS)</p>
<h2>Asset Pipeline</h2>
<p>예전 에디터 버전에서는 Asset Pipeline 은 version 1, 2를 구분하여 선택하여 사용할 수 있었지만 최근 버전에서부터는 Asset Pipeline 2로 자동설정되며 선택할 수 없다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="300" data-origin-height="130"><span data-alt="Asset Pipeline"><img src="/assets/images/posts/2024/02/15/78-1.png" loading="lazy" width="300" height="130" data-origin-width="300" data-origin-height="130"/></span><figcaption>Asset Pipeline</figcaption>
</figure>
</p>

<p>에셋을 처리하는 과정에 대한 설정을 관리하는 항목들이다.</p>

<h3>Remove unused Artifacts on Restart</h3>
<p><span style="text-align: start">재실행시 사용하지 않는 아티팩트들을 삭제할지 여부에 대한 토글로<span>&nbsp;</span></span>기본으로 활성화된 상태이다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="306" data-origin-height="160"><span data-alt="Remove unused Artifacts on Restart"><img src="/assets/images/posts/2024/02/15/78-2.png" loading="lazy" width="306" height="160" data-origin-width="306" data-origin-height="160"/></span><figcaption>Remove unused Artifacts on Restart</figcaption>
</figure>
</p>

<p>유니티는 에디터가 실행될 때 라이브러리 폴더의 artifact 파일과 에셋 데이터베이스 엔트리에서 제거한다.</p>
<p>가비지 콜렉션의 형태로 이 설정을 비활성화하면 에셋 데이터베이스의 가비지 컬렉션이 비활성화된다.</p>
<p>즉 더 이상 사용하지 않는 수정된 아티팩트가 에디터가 재실행될 때에도 계속 보존되기 때문에 예상하지 못한 임포트 결과를 디버그 할 때 유용하다.</p>

<p>하지만 계속해서 사용하지 않는 데이터들이 쌓여갈 수 있기 때문에 일반적인 상황에서는 활성화해두는게 나을 것 같다.</p>
<hr contenteditable="false" />
<p><i><b>라이브러리 폴더</b></i></p>
<p>유니티에 임포트 된 에셋은 두 가지 버전으로 구분된다. 하나는 사용자가 사용하기 위한 것이고 다른 하나는 유니티가 사용하기 위한 것이다. 이 유니티가 사용하기 위한 에셋은 프로젝트의 라이브러리 폴더에 캐시로 생성된다. 즉 라이브러리 폴더 내의 캐시들은 로컬에서 에디터가 빠르게 작업을 처리하기 위해 사용하는 정보들로 많은 정보들을 계속해서 저장하기 때문에 용량이 큰 편이다.</p>

<p>로컬에서만 필요한 이 정보들은 프로젝트가 켜질 때마다 확인하는 과정을 거치며 폴더가 없으면 다시 생성하기 때문에 프로젝트를 공유하는 경우에는 제외시켜도 되는 파일들이다.</p>
<hr contenteditable="false" />

<h3>Parallel Import</h3>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="316" data-origin-height="95"><span data-alt="Parallel Import"><img src="/assets/images/posts/2024/02/15/78-3.png" loading="lazy" width="316" height="95" data-origin-width="316" data-origin-height="95"/></span><figcaption>Parallel Import</figcaption>
</figure>
</p>

<p>에셋을 임포트 할 때 동시에 진행하도록 하는 설정이다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="314" data-origin-height="84"><span data-alt="Parallel Import tip"><img src="/assets/images/posts/2024/02/15/78-4.png" loading="lazy" width="314" height="84" data-origin-width="314" data-origin-height="84"/></span><figcaption>Parallel Import tip</figcaption>
</figure>
</p>

<p>해당옵션은 기본으로 비활성화되어있고 이 경우 에셋을 순차적으로 임포트 하게 된다.</p>

<p><span style="text-align: start">이 기능은 특정 유형의 에셋에서만 지원되며&nbsp;</span> 에디터가 프로젝트 폴더에서 에셋이 새로 임포트 되거나 수정된 에셋을 감지하고 자동으로 임포트 할 때 발생하는 에셋 데이터베이스가 새로고침을 수행할 때만 실행된다. 이때 에셋은 하위 프로세스에서 임포트가 실행된다.</p>

<p><b>특정유형</b></p>
<p>- Texture Importer로 가져온 이미지 파일</p>
<p>- Model Importer 로 가져온 모델 파일</p>

<p>특정 유형은 임포트 시간이 오래 걸리는 두 가지로만 구성되며 현재 버전까지는 별도의 스크립터블이 가능한 API는 마련된</p>
<p>지 않은 상태이다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="934" data-origin-height="181"><span data-alt="Parallel Import"><img src="/assets/images/posts/2024/02/15/78-5.png" loading="lazy" width="633" height="123" data-origin-width="934" data-origin-height="181"/></span><figcaption>Parallel Import</figcaption>
</figure>
</p>

<p>이외의 유형은 해당 설정이 활성화되어 있어도 순차적으로 임포트 된다.</p>

<p><b>Desired Import Worker Count</b></p>
<p>병렬 임포트에서 사용할 작업 프로세스의 최적의 수</p>

<p><b>Standby Import Worker Count</b></p>
<p>쉬고 있는 상태에서도 유지시킬 최소의 작업 프로세스의 수</p>
<p>에디터에서 작업에 필요한 프로세스의 수가 최소보다 큰 경우 쉬고있는 프로세스를 중지시키고 시스템 리소스를 확보하도록 한다.&nbsp;</p>

<p><b>Idle Import Worker Shutdown Delay</b></p>
<p>쉬는 상태의 작업 프로세스를 종료할 때 대기하는 시간</p>

<p>또한 Edit &gt; Preferences &gt; Asset Pipeline에서 새 프로젝트에서 필요한 작업 프로세스의 기본 값을 제어할 수 있다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="749" data-origin-height="311"><span data-alt="Preferences &amp;gt; Asset Pipeline"><img src="/assets/images/posts/2024/02/15/78-6.png" loading="lazy" width="677" height="281" data-origin-width="749" data-origin-height="311"/></span><figcaption>Preferences &gt; Asset Pipeline</figcaption>
</figure>
</p>

<p>Import Worker Count % 의 값을 사용하여 Desired Import Worker Count 값을 할당할 수 있다.</p>
<p>이때 할당되는 값은 시스템에서 사용할 수 있는 논리 코어 수의 비율에 해당한다.</p>
<p>(16개의 논리 코어가 있다면 이중 25%를 할당하여 <span style="text-align: start"><span>&nbsp;</span></span>Desired Import Worker Count 값은 4가 할당된다.)</p>

<h2><s>Cache Server (project specific)</s></h2>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="508" data-origin-height="66"><span data-alt="Cache Server"><img src="/assets/images/posts/2024/02/15/78-7.png" loading="lazy" width="508" height="66" data-origin-width="508" data-origin-height="66"/></span><figcaption>Cache Server</figcaption>
</figure>
</p>
<p>Asset Pipeline 1 일 때 사용한 기능으로 버전 2에서는 기본으로 비활성화되어 있고 활성화할 수 없고&nbsp;Unity Accelerator로 대체되었다.</p>

<h2>Accelerator</h2>
<p>팀 작업 속도를 높이기 위한 기능이다.</p>
<p>임포트 한 에셋의 사본을 유지하는 캐싱 프락시 에이전트이다. 팀이 동일한 네트워크에서 작업할 때 프로젝트 일부를 다시 임포트 할 필요가 없도록 하여 반복 시간을 줄일 수 있도록 돕는다.</p>

<p><a href="https://docs.unity3d.com/kr/current/Manual/UnityAccelerator.html" target="_blank" rel="noopener&nbsp;noreferrer">Unity Accelerator</a></p>

<h2>Prefab Mode</h2>
<p>프리팹 관련 설정</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="429" data-origin-height="105"><span data-alt="Prefab Mode"><img src="/assets/images/posts/2024/02/15/78-8.png" loading="lazy" width="429" height="105" data-origin-width="429" data-origin-height="105"/></span><figcaption>Prefab Mode</figcaption>
</figure>
</p>

<h3>Allow Auto Save</h3>
<p>프리팹 설정 시 자동으로 저장되는 기능을 활성화할지 여부를 정할 수 있다.</p>
<p>활성화된 경우 프리팹 수정 씬에서 자동 저장 기능을 사용할 수 있는 상태가 된다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="135" data-origin-height="46"><span data-alt="Prefab Scene Auto Save - Enable"><img src="/assets/images/posts/2024/02/15/78-9.png" loading="lazy" width="176" height="60" data-origin-width="135" data-origin-height="46"/></span><figcaption>Prefab Scene Auto Save - Enable</figcaption>
</figure>
</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="69" data-origin-height="47"><span data-alt="Prefab Scene Auto Save - Disable"><img src="/assets/images/posts/2024/02/15/78-10.png" loading="lazy" width="69" height="47" data-origin-width="69" data-origin-height="47"/></span><figcaption>Prefab Scene Auto Save - Disable</figcaption>
</figure>
</p>

<h3>Editing Environments</h3>
<p>프리팹을 수정하는 환경을 편집하는 기능을 제공한다.</p>

<p><b>Regular Environment</b></p>
<p>일반 프리팹을 편집하는 환경에서 사용하고자 하는 신을 할당하면 배경으로 사용할 수 있다.</p>
<p><figure class="imagegridblock">
  <div class="image-container"><span data-origin-width="1030" data-origin-height="712" data-is-animation="false" width="534" height="369" data-widthpercent="49.81" style="width: 49.2335%; margin-right: 10px"><img src="/assets/images/posts/2024/02/15/78-11.png" loading="lazy" width="1030" height="712"/></span><span data-origin-width="1029" data-origin-height="706" data-is-animation="false" style="width: 49.6037%" data-widthpercent="50.19"><img src="/assets/images/posts/2024/02/15/78-12.png" loading="lazy" width="1029" height="706"/></span></div>
  <figcaption>Regular Environment</figcaption>
</figure>
</p>

<p><b>UI Envrionment</b></p>
<p>UI 프리팹의 편집하는 환경에서 사용할 수 있다.</p>
<p><figure class="imagegridblock">
  <div class="image-container"><span data-origin-width="1026" data-origin-height="706" data-is-animation="false" style="width: 49.5743%; margin-right: 10px" data-widthpercent="50.16"><img src="/assets/images/posts/2024/02/15/78-13.png" loading="lazy" width="1026" height="706"/></span><span data-origin-width="1021" data-origin-height="707" data-is-animation="false" style="width: 49.2629%" data-widthpercent="49.84"><img src="/assets/images/posts/2024/02/15/78-14.png" loading="lazy" width="1021" height="707"/></span></div>
  <figcaption>UI Environment</figcaption>
</figure>
</p>

<h2>Graphics</h2>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="310" data-origin-height="93"><span data-alt="Graphics"><img src="/assets/images/posts/2024/02/15/78-15.png" loading="lazy" width="310" height="93" data-origin-width="310" data-origin-height="93"/></span><figcaption>Graphics</figcaption>
</figure>
</p>

<p><b>Show Lightmap Resolution Overlay</b></p>
<p>씬의 드로우 모드 중에서 Baked Lightmap 모드에 체커보드 오버레이를 그린다.&nbsp;</p>
<p>여기서 타일 하나는 텍셀에 해당하며 라이트매핑 작업 시 씬의 텍셀 밀도를 확인할 수 있다.</p>
<p><figure class="imagegridblock">
  <div class="image-container"><span data-origin-width="1024" data-origin-height="729" data-is-animation="false" width="629" height="448" style="width: 47.1821%; margin-right: 10px" data-widthpercent="47.74"><img src="/assets/images/posts/2024/02/15/78-16.png" loading="lazy" width="1024" height="729"/></span><span data-origin-width="935" data-origin-height="608" data-is-animation="false" style="width: 51.6551%" data-widthpercent="52.26"><img src="/assets/images/posts/2024/02/15/78-17.png" loading="lazy" width="935" height="608"/></span></div>
  <figcaption>Draw Mode - Baked Lightmap / left enable</figcaption>
</figure>
</p>

<p><b>Use legacy Light Probe sample counts</b></p>
<p>활성화 시&nbsp;Progressive Lightmapper를 사용하여 베이크 할 때 고정된 라이트 프로브 샘플 수를 사용한다.&nbsp;</p>
<p>Direct Sample 64, Indirect Sample 2048, Environment Sample 2048</p>
<p><figure class="imagegridblock">
  <div class="image-container"><span data-origin-width="458" data-origin-height="219" data-is-animation="false" style="width: 56.6788%; margin-right: 10px" data-widthpercent="57.35"><img src="/assets/images/posts/2024/02/15/78-18.png" loading="lazy" width="458" height="219"/></span><span data-origin-width="462" data-origin-height="297" data-is-animation="false" style="width: 42.1584%" data-widthpercent="42.65"><img src="/assets/images/posts/2024/02/15/78-19.png" loading="lazy" width="462" height="297"/></span></div>
  <figcaption>Lighjtmapping - right enable</figcaption>
</figure>
</p>

<p><b>Enable baked cookies support</b></p>
<p>2020.1 이상의 프로젝트는 기본적으로 베이크 된 쿠키가 Progressive Lightmapper의 베이크된 광원과 혼합 광원에 대해 활성화된다. 이전의 경우 해당 부분이 비활성화되는데 이 옵션은 이전 버전과의 호환성을 위해서 제공되는 기능이다.</p>

<p><i><b>Cookie</b></i></p>
<p>특정 모양이나 색상의 그림자를 만들기 위해 광원에 배치하는 마스크로 광원의 모양과 강도를 변경한다.</p>
<p>쿠키를 통해 런타임 성능에 최소한 또는 전혀 영향을 미치지 않는 선에서 복잡한 조명 효과를 효율적으로 사용할 수 있다.</p>
<p><figure class="imagegridblock">
  <div class="image-container"><span data-origin-width="1027" data-origin-height="495" data-is-animation="false" style="width: 51.0084%; margin-right: 10px" data-widthpercent="51.61"><img src="/assets/images/posts/2024/02/15/78-20.png" loading="lazy" width="1027" height="495"/></span><span data-origin-width="998" data-origin-height="513" data-is-animation="false" style="width: 47.8288%" data-widthpercent="48.39"><img src="/assets/images/posts/2024/02/15/78-21.png" loading="lazy" width="998" height="513"/></span></div>
  <figcaption>Light cookie</figcaption>
</figure>
</p>
