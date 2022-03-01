---
title:  "배칭"
excerpt: "unity3d, engine, batching"

categories:
  - Unity3D
tags:
  - [unity3d, engine, batching]

toc: true
toc_sticky: true
 
date: 2021-03-01
last_modified_at: 2021-03-01
---  

***

<br>

### 배칭

batching 

동일한 머티리얼을 공유하는 복수의 드로우 콜을 하나로 묶어서 드로우 콜하는 기법이다. 

유니티에서 배칭의 수는 = draw call + setpass calls 라고 볼 수 있다. 

<br>

### 드로우 콜

draw call

![draw-call-flow](/assets/images/20220301_Posting/draw-call-flow.png)

<br>

CPU에서 처리한 연산결과를 GPU에 보내 오브젝트를 그려라 요청하는 것이다.  

드로우 콜 간에는 머티리얼의 전환등의 스테이트 변경으로 인해 그래픽 드라이버에서 리소스가 많이 사용되는 확인 및 이동 단계를 수행해야 하기 때문에 종종 리소스가 많이 사용되고 그래픽스 API가 모든 드로우 콜에 중요 작업을 수행함에 따라서 CPU 성능이 많이 사용될 수 있다.  

**드로우 콜 발생**  

* 하나의 오브젝트에 메시가 여러 개인 경우

* 하나의 오브젝트에 여러개의 머티리얼이 있는 경우

* 하나의 셰이더에 멀티 패스가 정의된 경우

<br>

### 셋패스 콜

setpass call

머티리얼의 설정(shader, texture, blending 등)에 따라서 카운트된다.  

**셋패스 콜 발생**

* 셰이더로 인한 렌더링 패스 횟수

* 메시, 텍스쳐, 셰이더, 라이트 등의 정보

* 하나의 셰이더 내에서 multi-pass를 통해 2번 이상의 렌더링을 거치면 사용하면 2번의 드로우 콜이 발생한다. 

<br>

### 배칭 종류

유니티의 배칭 방식은 두 가지가 있다. 

Edit > ProjectSetting > Player > OtherSettings 

<br>

#### 정적 배칭

static batching

정적으로 체크된 오브젝트 대상으로 적용되며 자동으로 로딩타임에 배칭된다.  

정보를 메모리에 올리기 때문에 CPU 부담을 메모리로 옮긴다고 볼 수 있다.  

동적 배칭보다는 효과가 좋지만 과도하게 많은 오브젝트를 사용하게 되면 메모리 부담이 높아지기 때문에 역효과가 발생할 수 있다.  

<br>

#### 동적 배칭

dynamic batching

게임 오브젝트의 정적으로 체크되지 않은 오브젝트 대상으로 유니티가 처리한다. 

정점이 너무 많은 메시의 경우 정점을 수집하면서 오버헤드가 드로우 콜 보다 높아져 대상에서 제외된다.  

조건이 까다롭기 때문에 일반적인 드로우 콜로 처리되는 것보다 효율이 안좋은 경우도 발생할 수 있다.  