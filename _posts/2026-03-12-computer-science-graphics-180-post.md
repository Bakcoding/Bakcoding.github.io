---
title: "드로우 콜에 대해서"
excerpt: "드로우 콜에 대해서"
categories:
  - Graphics
permalink: /computer-science/graphics/180-post/
tags:
  - "Graphics"
  - "Computer Science"
  - "DrawCall"
  - "드로우콜"
toc: true
toc_sticky: true
date: 2026-03-12
last_modified_at: 2026-03-12
source_url: https://b-note.tistory.com/180
---

<h2>드로우 콜이란?</h2>
<p>CPU만으로 그래픽을 그리던 시절이 있었다.&nbsp;</p>
<p>초기 PC에서는 GPU가 없었기 때문에 모든 렌더링을 CPU가 직접 처리하였다.</p>
<p>(폴리곤, 픽셀, 텍스처, 조명 등의 작업 대표적으로 DOOM이나 Quake 초기 버전)</p>

<p>단순 처리를 넘어서 게임의 발전에 따라 더 많은 그래픽 작업이 요구되기 시작했고,</p>
<p>CPU에서만 이 작업들을 처리하기에는 부하가 매우 커지기 시작했다.</p>

<h3>CPU와 GPU</h3>
<p>그런 CPU의 부하를 대신하기 위해 GPU가 등장했다.</p>
<p>CPU가 복잡한 논리 연산을 순차적으로 빠르게 처리하는 소수의 지휘관이라면 GPU는 단순하지만 엄청난 양의 계산을 동시에 처리하는 부대급 작업원으로 각자의 역할을 분담하기 시작했다.</p>> 용량 문제로 해당 이미지는 [원문](/computer-science/graphics/180-post/)에서 확인한다.
</p>

<p>이렇게 분담한 역할을 자세히 나열하면 다음과 같다.</p>

<p><b>CPU -&gt; 무엇을 그릴지 결정</b></p>
<p>- 오브젝트 위치 계산</p>
<p>- 애니메이션</p>
<p>- 게임 로직</p>
<p>- 렌더 명령 생성</p>

<p><b>GPU -&gt; 실제 픽셀 계산</b></p>
<p>- 버텍스 변환</p>
<p>- 삼각형 생성</p>
<p>- 픽셀 계산</p>
<p>- 텍스처 샘플링</p>

<p>지휘관인 CPU와 부대원인 GPU는 상명하복 관계에 있다.</p>
<p>CPU는 GPU에게 작업을 내린다.</p>
<p>"이 메쉬를 이 머티리얼로 이 위치에 그려라"</p>

<p>이 명령 하나가 바로 <b>DrawCall</b>이다.</p>

<h3>Draw Call</h3>
<p>CPU는 화면을 그리기 위한 명령(Draw Call)을 GPU에게 전달하기 위해 다음 작업 과정을 거치게 된다.</p>

<p><b>CPU 작업</b></p>
<p>1. Render State 설정</p>
<p>렌더 상태 설정 -&gt; 버퍼 바인딩 -&gt; 셰이더 설정 -&gt; 텍스처 설정</p>

<p>2. Draw Call 호출</p>
<p>CPU가 그래픽 API(glDrawElements, DrawIndexedPrimitive 등)를 통해 "그려라"는 단일 명령을 내리는 단계로 이 API 호출 하나를 좁은 의미의 Draw Call이라 한다.</p>

<p>3. Driver 번역</p>
<p>그래픽 드라이버가 API 명령의 유효성을 검사하고, GPU 전용 명령어로 번역하는 단계</p>

<p>4. GPU Command Buffer 기록</p>
<p>번역된 명령들을 GPU가 읽을 수 있도록 메모리에 기록하는 단계로 이 시점에서 CPU의 역할은 끝난다.</p>

<p>위 CPU의 작업이 끝난 후 GPU가 Command Buffer의 명령을 CPU와 비동기적으로 처리하며 실제 픽셀을 그리며 CPU 작업과 독립적으로 진행된다.</p>

<p><span style="letter-spacing: 0px">1 ~ 4까지의 전체 과정을 넓은 의미에서 Draw Call이라 하며, 이 과정에서 발생하는 CPU 비용은 주로 다음에서 발생한다.</span></p>
<p>- Render State 변경에 따른 오버헤드 (특히 셰이더/파이프라인 전환)</p>
<p>- 드라이버의 유효성 검사 및 상태 추적</p>
<p>- API 명령의 GPU 명령어 번역</p>
<p>- Command Buffer 메모리 기록 및 CPU-GPU 간 동기화</p>
