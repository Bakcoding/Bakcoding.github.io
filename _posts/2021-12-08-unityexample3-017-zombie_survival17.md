---
title:  "[레트로의 유니티] 좀비서바이벌16 - 마무리"
excerpt: "unity3d, retro, example, zombie, item, spawner"

categories:
  - UnityExample
tags:
  - [unity3d, retro, example, zombie, item, spawner]

toc: true
toc_sticky: true
 
date: 2021-12-08 
last_modified_at: 2021-12-08
---  

***  

### 마무리

게임의 시스템은 완성됐다. 마지막으로 포스트 프로세싱 스택을 사용하여 게임에 영상미를 추가한다.  

<br>

#### 포스트 프로세싱 스택  

post processing 

후처리

게임 화면이 최종 출력되기 전에 카메라의 이미지 버퍼에 삽입하는 추가 처리이다.  

카메라의 필터를 사용하는 것과 비슷한 것으로 렌더링 파이프라인의 주요 과정에서 적용되지 않고 마지막 부분에 적용된다.  

유니티에서는 쉽게 사용할 수 있도록 패키지로 제공된다.  

<br>

#### 렌더링 경로

최선의 품질을 얻기 위해 카메라의 렌더 설정을 변경한다.  

**Hierarchy > Main Camera**

* Camera 컴포넌트 

  * Rendering Path : Defferred 

    렌더링이 처리되는 순서와 방법을 결정한다.  
    
    기본값 Use Graphics Settings는 프로젝트 설정에 맞춰 자동으로 렌더링 경로를 결정하며 일반적으로 Forward Renderring 옵션으로 설정한다.  

    Forward Renderring은 성능이 가볍지만 라이팅 표현이 실제보다 간략화되고 왜곡되는데 이것을 Diferred Shading 으로 바꾸면 빛이 온전하게 표현된다.

  * MSAA : Off

    안티앨리어싱


  **Forward Renderring**  
  각각의 오브젝트를 그릴 때마다 해당 오브젝트에 영향을 주는 모든 라이팅도 함께 계산하는 전통적인 방식이다. 메모리 사용량이 적고 저사양에서도 비교적 잘 동작한다.  
  하지만 연산 속도가 느리며, 오브젝트와 광원이 움직이거나 수가 많아질수록 연산량이 급증하여 사용하기 힘들다.  

  포워드 렌더링은 하나의 오브젝트에 대해 최대 4개의 광원만 제대로 개별 연산한다. 나머지 중요하지 않은 광원과 라이팅 효과는 부하를 줄이기 위해 합쳐서 한 번에 연산한다. 따라서 라이팅 효과가 실제와 다르게 표현될 수 있다. 

  **Diferred Shading**  
  라이팅 연산을 미뤄서 실행하는 방식이다. 첫 번째 패스에서는 오브젝트의 메시를 그리되 라이팅을 계싼하거나 색을 채우지 않는다. 대신 오브젝트의 여러 정보를 종류별로 버퍼에 저장한다. 두번째 패스에서 첫번째 패스의 정보를 활용해 라이팅을 계산하고 최종 컬러를 결정한다.  

  유니티의 디퍼드 셰이딩은 개수 제한 없이 광원을 표현할 수 있다. 또한 모든 광원 효과가 올바르게 표현된다. 하지만 MSAA 같은 일부 안티앨리어싱 설정은 제대로 지원되지 않는다.

<br>

#### 포스트 프로세싱 적용

먼저 씬의 카메라에 포스트 프로세스 레이어 컴포넌트를 할당해야 한다.

* 컴포넌트 추가   

  Main Camera > Post-process Layer > Add Component > Rendering > Post-process Layer

* Post-process Layer 설정  

  * Layer : PostProcessing  

    레이어를 가진 오브젝트에 대해서만 포스트 프로세싱 불륨을 감지한다. 

  * Anti-aliasing > Mode : FXAA

    Fast Approximate Anti-Aliasing은 전반적인 품질은 높지 않지만 성능 저하가 가장 적고 연산이 빠르다.

<br>

#### 포스트 프로세스 볼륨 추가

* Post-process Volume 오브젝트 생성

  Create > 3D Object > Post-process Volume

* 오브젝트 
  
  이름 : PostProcessing

  레이어 : PostProcessing

* 컴포넌트 설정 

  Is Global 체크

* 프로파일 할당

  Post Process Volume > Profile > Global Profile 할당


#### 포스트 프로세스 효과 

**Motion Blur**  

빠르게 움직이는 물체에 대한 잔상

**Bloom**  

밝은 물체의 경계에서 빛이 산란되는 효과, 뽀샤시

**Color Grading**  

최종 컬러, 대비, 감마 등을 교정

**Chromatic Aberration**  

일명 방사능 중독 효과, 이미지의 경계가 번지고 삼원색이 분리되는 효과

**Vignette**  

화면 가장자리의 채도와 명도를 낮추는 효과  

화면 중심에 포커스를 주고 차분한 느낌을 줄 때 사용

**Grain**

화면에 입자 노이즈 추가  

필름 영화 같은 효과를 내거나, 공포 분위기를 강화할 때 사용

<br>

### 빌드하기  

마지막으로 배경음을 추가하고 게임을 빌드한다.  

* 배경음 추가  

  * Audio > Music 클립을 Game Manager로 드래그앤드롭

  * Game Manager 오브젝트의 Audio Source 컴포넌트 Loop 체크  

* 빌드  

  * File > Build Settings > Add Open Scenes

    현재 씬을 빌드 목록에 등록한다.  

  * Build and Run 경로 선택하고 빌드 시작