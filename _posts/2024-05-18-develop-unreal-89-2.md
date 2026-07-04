---
title: "언리얼 엔진 - 에디터 개인설정 - 일반 기타 (2)"
excerpt: "언리얼 엔진 - 에디터 개인설정 - 일반 기타 (2)"
categories:
  - Unreal
permalink: /develop/unreal/89-2/
tags:
  - "Unreal"
  - "Game Development"
  - "editor setting"
  - "Unreal Engine"
  - "언리얼 엔진"
toc: true
toc_sticky: true
date: 2024-05-18
last_modified_at: 2024-05-18
source_url: https://b-note.tistory.com/89
---

<h2 style="color: #000000; text-align: start;">Hot Reload</h2>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="723" data-origin-height="91"><span data-alt="Unreal Engine - Editor Setting, Hot Reload"><img src="/assets/images/posts/2024/05/18/89-1.png" loading="lazy" width="723" height="91" data-origin-width="723" data-origin-height="91"/></span><figcaption>Unreal Engine - Editor Setting, Hot Reload</figcaption>
</figure>
</p>


<h3>새로 추가된 C++ 클래스 자동 컴파일</h3>
<p>코드를 수정하고 저장하게 되면 로드시간이 발생하게 된다. 이 시간 동안 변경된 사항을 프로젝트에 반영하게 되는데 기본적으로 Hot Load의 새로 추가된 C++ 클래스 자동 컴파일 설정이 활성화되어 있기 때문이다.&nbsp;</p>

<p>이 설정을 통해서 프로젝트는 변경된 사항을 바로 반영하게 되어 게임이나 애플리케이션을 다시 시작하지 않아도 변경된 내용을 즉시 확인할 수 있어 반복적인 빌드 및 실행 시간을 절약해서 <span style="color: #333333; text-align: start;">개발 속도를 크게 향상시킬<span> 수 있다.</span></span></p>

<p>프로젝트의 규모가 크며 코드의 수정이 많아 저장을 빈번히 하게 되면 매번 컴파일이 실행되기 때문에 작업이 지연될 수 있는데 이런 상황에서는 비활성화를 해두는 방법도 있다.</p>



<h3>컴파일 오류 시 컴파일러 로그 표시</h3>
<p>에디터에서 컴파일 중 오류가 발생할 때 로그를 표시하여 문제를 빠르게 확인하는데 도움을 준다.</p>

<p>컴파일러 로그에는 오류 메시지 경고, 문제가 발생한 코드상 위치에 대한 정보가 포함되어 있다.&nbsp;</p>

<h2>임포트</h2>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="836" data-origin-height="138"><span data-alt="Unreal Engine - Editor Setting - Import"><img src="/assets/images/posts/2024/05/18/89-2.png" loading="lazy" width="836" height="138" data-origin-width="836" data-origin-height="138"/></span><figcaption>Unreal Engine - Editor Setting - Import</figcaption>
</figure>
</p>

<p>리소스를 프로젝트에 가져올 때 관련된 설정들이다.</p>

<h3>Fbx 네임스페이스 유지</h3>
<p>활성화하면 fbx 파서가 fbx 네임스페이스를 유지하고, 비활성화하면 fbx 노드에 네임스페이스를 덧붙인다.</p>
<p>fbx 파일은 3D 모델, 애니메이션, 재질 등을 저장하고 교환하기 위해 널리 사용되는 파일 형식이다.</p>

<p>이 fbx 파일에는 다양한 3D 소프트웨어 간에 데이터를 전송하기 위한 복잡한 계층 구조와 네임스페이스가 포함될 수 있는데 네임스페이스를 유지하게 되면 이름 충돌을 피하고, 객체를 논리적으로 그룹화하며 특정 객체를 고유하게 식별하는 데 사용된다.</p>

<h3>리임포트 시 임포트 대화창 표시</h3>
<p>사용자가 fbx를 리임포트 할 때 fbx 옵션 대화창이 표시된다.</p>
<p>리임포트는 이미 가져온 파일을 다시 가져올 때 임포트 대화창을 표시할지 여부를 결정하는 옵션이다.&nbsp;</p>

<p>리임포트는 한번 가져온 외부 파일을 다시 가져오는 과정으로 외부에서 파일이 수정되었을 때 변경된 내용을 언리얼 엔진 프로젝트에 반영하기 위해 사용된다. 임포트 대화창은 파일을 언리얼 엔진으로 가져올 때 다양한 임포트 옵션을 설정할 수 있는 인터페이스를 제공한다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="449" data-origin-height="614"><span data-alt="Unreal Engine - Editor Setting - Reimport"><img src="/assets/images/posts/2024/05/18/89-3.png" loading="lazy" width="393" height="537" data-origin-width="449" data-origin-height="614"/></span><figcaption>Unreal Engine - Editor Setting - Reimport</figcaption>
</figure>
</p>

<p>리임포트 시 임포트 대화창 표시를 활성화했을 때 리임포트 시 보이는 창</p>

<h3>데이터 소스 폴더&nbsp;</h3>
<p>리임포트 프로세스를 편하게 하기 위해 상대 소스 파일 경로를 저장할 프로젝트 데이터 소스 폴더를 지정한다.</p>
<p>특정 폴더를 지정하게 되면 언리얼 엔진에서는 이 폴더를 소스 데이터의 기본 위치로 인식하게 되고 텍스처, 모델, 오디오 파일 등 다양한 에셋을 위치한 폴더에 저장하게 된다.</p>

<h3>애니메이션 리임포트 경고</h3>
<p>애니메이션의 시퀀스 길이와 커브를 예전 데이터와 비교하고 변경사항이 있을 경우 사용자에게 알려준다.</p>

<h2>익스포트</h2>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="753" data-origin-height="56"><span data-alt="Unreal Engine - Editor Setting - Export"><img src="/assets/images/posts/2024/05/18/89-4.png" loading="lazy" width="753" height="56" data-origin-width="753" data-origin-height="56"/></span><figcaption>Unreal Engine - Editor Setting - Export</figcaption>
</figure>
</p>

<h3>어태치 계층구조 유지</h3>
<p>활성화 시 어태치먼트 계층 구조도 익스포트 한다.</p>
<p>어태치먼트 계층구조란 오브젝트 간의 부모-자식 관계를 말한다. 이는 오브젝트를 서로 연결하여 한 오브젝트의 변환(위치, 회전, 크기)이 다른 오브젝트에 영향을 미치도록 설정하는 기능이다.</p>

<p>모델을 언리얼 엔진에 익스포트 할 때 어태치먼트 계층구조를 유지하면 원본 모델의 부모-자식 관계가 언리얼 엔진에서도 동일하게 적용된다. 이는 외부 3D 소프트웨어에서 설정한 계층구조가 언리얼 엔진에서도 동일하게 유지되도록 한다.</p>

<p>어태치먼트 계층구조는 오브젝트 간의 부모-자식 관계를 설정하여 변환 상속 및 조직화를 용이하게 한다. 이를 통해 씬의 복잡한 구조를 간단하게 관리하고 애니메이션이나 움직임을 쉽게 구현할 수 있다. 익스포트 시에도 이 계층구조를 유지하면 외부 소프트웨어와의 호환성을 높일 수 있다.</p>

<h2>Unreal Automation Tool(UAT)</h2>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="687" data-origin-height="82"><span data-alt="Unreal Engine - Editor Setting - Automation Tool"><img src="/assets/images/posts/2024/05/18/89-5.png" loading="lazy" width="687" height="82" data-origin-width="687" data-origin-height="82"/></span><figcaption>Unreal Engine - Editor Setting - Automation Tool</figcaption>
</figure>
</p>

<h3>UAT 완료 파악</h3>
<p>에디터는 UAT 작업(쿠킹 및 패키징)을 완료할 때마다 사용자에게 알릴 시도를 한다.</p>


<h3>UAT 항상 빌드</h3>
<p>게임을 실행하기 전에 UAT/UBT를 언제나 빌드한다. 비활성화될 경우 반복 소요 시간이 줄어든다.</p>
