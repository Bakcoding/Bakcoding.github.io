---
title: "유니티 프로젝트 창 검색 활용"
excerpt: "유니티 프로젝트 창 검색 활용"
categories:
  - Unity
permalink: /develop/unity/92-post/
tags:
  - "Unity"
  - "Game Development"
  - "assets"
  - "search"
  - "unity"
  - "에셋 검색"
  - "유니티"
toc: true
toc_sticky: true
date: 2024-06-30
last_modified_at: 2024-06-30
source_url: https://b-note.tistory.com/92
---

<p>유니티에서 개발을 하면서 에셋을 이것저것 가져와서 필요한 걸 골라서 사용하기도 한다.</p>

<p>여러 가지 사운드 리소스를 틀어가면서 적당한 걸 고르는 경우나 이미지를 돌려가며 잘 어울리는 걸 선택하는 경우가 있다.</p>

<p>하지만 에셋을 여러 경로에서 다운로드하다 보면 폴더의 경로나 파일의 네이밍이 제각각이기 때문에 하나씩 틀어보는 게 쉽지 않다.</p>

<p>이럴 때 특정 유형의 리소스만 모아서 보는 게 편한데 프로젝트 창의 검색 기능을 활용하여 특정 유형의 파일만 모아서 볼 수 있다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="529" data-origin-height="318"><span data-alt="Unity - Project Window"><img src="/assets/images/posts/2024/06/30/92-1.png" loading="lazy" width="529" height="318" data-origin-width="529" data-origin-height="318"/></span><figcaption>Unity - Project Window</figcaption>
</figure>
</p>


<p>- 텍스처 파일 검색 : 't:Texture2 D'</p>
<p>- 오디오 파일 검색 : 't:AudioClip'</p>
<p>- 프리팹 검색 : 't:Prefab'</p>
<p>- 스크립트 파일 검색 : 't:Script'</p>
<p>- 머티리얼 검색 : 't:Material'</p>
<p>- 애니메이션 검색 : 't:AnimationClip'</p>
<p>- 모델 검색 : 't:Model'</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="526" data-origin-height="210"><span data-alt="Unity - Project Window / Sreaching"><img src="/assets/images/posts/2024/06/30/92-2.png" loading="lazy" width="526" height="210" data-origin-width="526" data-origin-height="210"/></span><figcaption>Unity - Project Window / Sreaching</figcaption>
</figure>
</p>


<p><b>'t:&lt;타입&gt;'은</b> 특정 타입의 에셋을 검색하는 키워드이다.</p>
<p>&lt;타입&gt;에 원하는 유형으로 검색하여 원하는 에셋을 찾기 쉽다.</p>

<p>그 밖에도 유니티 검색창에서 사용할 수 있는 특정 키워드가 존재한다.</p>

<p><b>'l:&lt;레이블&gt;' :</b> 특정 레이블이 있는 에셋을 검색한다.</p>
<p>레이블은 에셋을 그룹화하는 데 사용할 수 있는 태그 같은 것으로 에셋을 선택하고 인스펙터 창의 하단에 있는 UI를 통해서 레이블을 확인하고 변경하거나 추가할 수 있다.</p>

<p>새로운 레이블을 추가하는 방법은 원하는 이름을 작성하고 엔터를 입력하면 추가된다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="277" data-origin-height="342"><span data-alt="Assets Labels"><img src="/assets/images/posts/2024/06/30/92-3.png" loading="lazy" width="277" height="342" data-origin-width="277" data-origin-height="342"/></span><figcaption>Assets Labels</figcaption>
</figure>
</p>

<p>이 기능들은 검색창의 옆에 있는 토글들을 통해서도 사용할 수 있다.</p>

<p><figure class="imagegridblock">
  <div class="image-container"><span data-origin-width="466" data-origin-height="353" data-is-animation="false" style="width: 61.3619%; margin-right: 10px;" data-widthpercent="62.08"><img src="/assets/images/posts/2024/06/30/92-4.png" loading="lazy" width="466" height="353"/></span><span data-origin-width="233" data-origin-height="289" data-is-animation="false" style="width: 37.4753%;" data-widthpercent="37.92"><img src="/assets/images/posts/2024/06/30/92-5.png" loading="lazy" width="233" height="289"/></span></div>
  <figcaption>Unity - Search by Type / Search by Label</figcaption>
</figure>
</p>
