---
title: "유니티 렌더링 최적화"
excerpt: "유니티 렌더링 최적화"
categories:
  - Unity
permalink: /develop/unity/181-post/
tags:
  - "Unity"
  - "Game Development"
  - "렌더링최적화"
  - "유니티"
toc: true
toc_sticky: true
date: 2026-03-12
last_modified_at: 2026-03-12
source_url: https://b-note.tistory.com/181
---

<h2>렌더링이란</h2>
<p>3D 씬의 데이터(오브젝트, 조명, 카메라 등)를 계산하여 2D 화면에 픽셀로 출력하는 전체 과정을 의미한다.</p>

<p>유니티에서 렌더링은 매 프레임마다 반복되며, CPU와 GPU가 역할을 분담하여 처리한다.</p>

<h3>CPU와 GPU의 역할 분담</h3>
<p>CPU : 씬 데이터 준비, Render State 설정, Draw Call 호출, 드라이버 명령 전달</p>
<p>GPU : 버텍스 처리, 래스터화, 픽셀 셰이딩, 최종 화면 출력</p>

<h3>렌더링 파이프라인 흐름</h3>
<p>CPU와 GPU 사이에서 매 프레임 다음 흐름이 반복된다.</p>
<p>- Render State 설정 : 버퍼 바인딩, 셰이더 설정, 텍스처 설정 등 GPU가 그리기 위한 상태를 준비</p>
<p>- Draw Call 호출 : CPU가 그래픽 API를 통해 화면을 그려라는 명령을 내림</p>
<p>- 드라이버 번역 : 드라이버가 API 명령을 유효성 검사 후 GPU 전용 명령어로 번역</p>
<p>- GPU Command Buffer 기록 : 번역된 명령을 메모리에 기록, 이 시점에서 CPU 역할 종료&nbsp;</p>
<p>- GPU 실행 : CPU와 비동기적으로 Command Buffer를 처리하여 픽셀을 출력</p>

<p>＊ Draw Call 이 많을수록 CPU의 상태 설정, 드라이버 호출, 명령 번역 오버헤드가 누적되어 성능 저하가 발생한다.</p>
<p style="color: #333333; text-align: start;"><a href="https://b-note.tistory.com/180">https://b-note.tistory.com/180</a></p>
<figure id="og_1773282032333" contenteditable="false" data-og-type="article" data-og-title="드로우 콜에 대해서" data-og-description="드로우 콜이란?CPU만으로 그래픽을 그리던 시절이 있었다. 초기 PC에서는 GPU가 없었기 때문에 모든 렌더링을 CPU가 직접 처리하였다.(폴리곤, 픽셀, 텍스처, 조명 등의 작업 대표적으로 DOOM이나 Quak" data-og-host="b-note.tistory.com" data-og-source-url="https://b-note.tistory.com/180" data-og-url="https://b-note.tistory.com/180"><a href="https://b-note.tistory.com/180" target="_blank" rel="noopener" data-source-url="https://b-note.tistory.com/180">
<div class="og-image">&nbsp;</div>
<div class="og-text">
<p class="og-title">드로우 콜에 대해서</p>
<p class="og-desc">드로우 콜이란?CPU만으로 그래픽을 그리던 시절이 있었다. 초기 PC에서는 GPU가 없었기 때문에 모든 렌더링을 CPU가 직접 처리하였다.(폴리곤, 픽셀, 텍스처, 조명 등의 작업 대표적으로 DOOM이나 Quak</p>
<p class="og-host">b-note.tistory.com</p>
</div>
</a></figure>


<h3>렌더링 관련 주요 동작들</h3>
<p>Culling : 카메라 시야 밖의 오브젝트를 렌더링 대상에서 제외</p>
<p>Shadow Casting : 오브젝트가 그림자를 생성하는 과정(추가 Draw Call 발생)</p>
<p>라이팅 계산 : 조명이 오브젝트 표면에 미치는 영향 계산</p>
<p>포스트 프로세싱 : 렌더링 완료 후 화면 전체에 적용하는 효과 처리 (Bloom, DOF 등)</p>
<p>UI 렌더링 : Canvas 기반 UI 요소를 별도로 렌더링</p>


<h2>렌더링 최적화</h2>
<p>렌더링 최적화는 동일한 시각적 품질을 유지하면서 CPU와 GPU의 처리 부하를 줄여 목표 프레임 레이트(FPS)를 안정적으로 달성하는 작업이다.</p>

<h3>CPU 병목 vs GPU 병목</h3>
<p>최적화 방향을 결정하려면 병목 지점을 먼저 파악해야 한다. 원인이 다르기 때문에 접근 방식도 다르다.</p>

<table style="border-collapse: collapse; width: 99.184%;" border="1">
<tbody>
<tr>
<td style="width: 11.0465%;">구분</td>
<td style="width: 38.6047%;">주요 원인</td>
<td style="width: 27.1303%;">증장</td>
<td style="width: 22.5226%;">해결 방향</td>
</tr>
<tr>
<td style="width: 11.0465%;">CPU 병목</td>
<td style="width: 38.6047%;">Draw Call 과다, 드라이버 오버헤드</td>
<td style="width: 27.1303%;">CPU 사용률 높음, GPU 대기 발생</td>
<td style="width: 22.5226%;">배칭, Draw Call 감소</td>
</tr>
<tr>
<td style="width: 11.0465%;">GPU 병목</td>
<td style="width: 38.6047%;">고해상도 텍스처, 복잡한 셰이더, 과도한 픽셀 연산</td>
<td style="width: 27.1303%;">GPU 사용률 높음, 프레임 드롭</td>
<td style="width: 22.5226%;">텍스처 압축, 셰이더 최적화, 해상도 조정</td>
</tr>
</tbody>
</table>

<p>＊ Unity의 Profiler와 Frame Debugger를 통해 병목이 CPU 인지 GPU 인지 먼저 확인한 뒤 최적화 방향을 결정해야 한다.</p>

<h2>렌더링 최적화 방법</h2>
<h3>Draw Call&nbsp; 최적화 - 배칭(Batching)</h3>
<h4 style="color: #000000; text-align: start;">배칭</h4>
<p style="color: #333333; text-align: start;">배칭은 CPU가 GPU에게 전달해야 할 여러 개의 개별적인 명령인 Draw Call을 하나의 그룹으로 묶어서 처리하는 기술을 의미한다.</p>
<p style="color: #333333; text-align: start;">CPU가 Draw Call 명령을 내리기 전 수행하는 과정에서 상당한 CPU 자원을 소모하게 되는데 배칭은 이 과정을 최소화하기 위해 동일한 속성(머티리얼, 셰이더 등)을 가진 물체들을 모아 단 한 번의 명령으로 처리하도록 만들어 CPU의 오버헤드를 줄여 전체 프레임 레이트를 높이고, CPU와 GPU 사이의 통신 병목 현상을 해결하는데 목적이 있다.</p>
<p style="color: #333333; text-align: start;">&nbsp;</p>
<p style="color: #333333; text-align: start;">※오버헤드</p>
<p style="color: #333333; text-align: start;">목적을 수행하는 데 필요한 부가적인 비용</p>
<p style="color: #333333; text-align: start;">예) 함수를 호출할 때, 함수 내부 로직 실행이라는 실제 작업을 위해 거치는 일련의(함수 호출 준비 -&gt; 스택 메모리 할당 -&gt; 인자 전달 -&gt; 반환값 처리 -&gt; 스택 정리) 부가 작업들이 오버헤드이다.</p>
<p style="color: #333333; text-align: start;">&nbsp;</p>
<h4 style="color: #000000; text-align: start;">배칭의 종류</h4>
<p style="color: #333333; text-align: start;">유니티는 물체의 특성에 따라 크게 세 가지 방식의 배칭을 지원한다.</p>
<p style="color: #333333; text-align: start;">&nbsp;</p>
<p style="color: #333333; text-align: start;"><b>정적 배칭(Static Batching)</b></p>
<p style="color: #333333; text-align: start;">움직이지 않는 정적 오브젝트(배경, 건물 등)를 위한 방식이다.</p>
<p style="color: #333333; text-align: start;">게임 시작 시, 서로 다른 메쉬들을 하나의 거대한 메쉬로 합쳐서 GPU 메모리에 저장한다.</p>
<p style="color: #333333; text-align: start;">런타임 중에 메쉬를 합치는 CPU 연산이 필요 없어 성능 향상이 가장 확실하다. 대신 합쳐진 메시를 위한 추가적인 메모리가 필요하며, 데이터가 크면 메모리 부적을 유발할 수 있다.</p>
<p style="color: #333333; text-align: start;">&nbsp;</p>
<p style="color: #333333; text-align: start;"><b>동적 배칭(Dynamic Batching)</b></p>
<p style="color: #333333; text-align: start;">매 프레임 위치가 변하는 움직이는 물체들을 위한 방식이다.</p>
<p style="color: #333333; text-align: start;">CPU가 실시간으로 비슷한 속성의 작은 메쉬들을 하나의 공유 버퍼에 모아 전송한다.</p>
<p style="color: #333333; text-align: start;">움직이는 오브젝트도 드로우 콜을 줄일 수 있게 되지만 CPU가 매 프레임 메쉬를 재구성해야 하므로 CPU 연산 부하가 발생하기 때문에 정점 수가 적은 물체에만 제한적으로 적용된다.&nbsp;</p>
<p style="color: #333333; text-align: start;">&nbsp;</p>
<p style="color: #333333; text-align: start;">※ 적용 기준</p>
<p style="color: #333333; text-align: start;">1. 정점 속성의 수 300개</p>
<p style="color: #333333; text-align: start;">예) 셰이더가 위치, 법선, UV 세 가지 속성을 사용한다면, 정점 하나당 3개의 속성을 가진다. 이 경우 300 / 3 = 100개, 즉 정점 100개까지만 동적 배칭이 가능하다.</p>
<p style="color: #333333; text-align: start;">&nbsp;</p>
<p style="color: #333333; text-align: start;">2. 스케일의 일관성</p>
<p style="color: #333333; text-align: start;">오브젝트의 스케일 x, y, z 각 축별로 다른 스케일을 가지는 비균등 스케일 오브젝트들이 있다면 유니티는 이를 배칭 하지 않을 가능성이 높으며, 최신 유니티 버전에서는 동일하게 비균등 스케일을 가진 오브젝트끼리 묶어주기도 하지만 여전히 스케일이 제각각이라면 배칭 효율이 급격히 떨어지게 된다.</p>
<p style="color: #333333; text-align: start;">&nbsp;</p>
<p style="color: #333333; text-align: start;">3. 머티리얼 및 라이트맵 인스턴스</p>
<p style="color: #333333; text-align: start;">동일한 머티리얼 인스턴스를 사용해야 한다.</p>
<p style="color: #333333; text-align: start;">(renderer.material에 접근하면 복사본 머티리얼이 생성되어 배칭이 깨지므로 renderer.sharedMaterial을 사용해야 한다.)</p>
<p style="color: #333333; text-align: start;">오브젝트들이 가리키는 라이트맵 인덱스가 같아야 한다. 같은 위치에 모여있는 물체들이라도 각자 다른 라이트맵 텍스처 영역을 참조하면 배칭 되지 않는다.</p>
<p style="color: #333333; text-align: start;">&nbsp;</p>
<p style="color: #333333; text-align: start;"><b>GPU Instancing</b></p>
<p style="color: #333333; text-align: start;">동일한 메쉬와 머티리얼을 대량으로 렌더링 하는 오브젝트(나무, 풀, 군중 등)</p>
<p style="color: #333333; text-align: start;">동일 메쉬, 머티리얼, 셰이더의 Enable GPU Instancing 활성화 시 동작</p>
<p style="color: #333333; text-align: start;">메쉬 데이터는 한 번만 GPU에 전달하고, 위치/회전/색상 등 인스턴스별 데이터만 별도로 넘겨 GPU</p>
<p style="color: #333333; text-align: start;">가 반복 처리한다. 동일 메쉬 대량 렌더링에 매우 효율적이지만 메쉬와 머티리얼이 완전히 동일해야 동작한다.</p>
<p style="color: #333333; text-align: start;">&nbsp;</p>
<p style="color: #333333; text-align: start;"><b>SRP 배처(SRP Batcher)</b></p>
<p style="color: #333333; text-align: start;">현대적인 유니티 파이프라인(URP, HDRP)의 표준 배칭 방식이다.</p>
<p style="color: #333333; text-align: start;">SRP Compatible 셰이더 사용(Shader Graph, URP Lit) 시 동작한다.</p>
<p style="color: #333333; text-align: start;">메쉬를 직접 합치지 않는 대신 GPU 메모리에 머티리얼 데이터를 미리 상주시키고, CPU는 데이터가 변경된 부분만 GPU에 알려주어 렌더링 상태 설정 비용을 극단적으로 낮춰 Draw Call 수보다 Draw Call 당 CPU 오버헤드를 줄이는 방식이다. 메쉬의 형태가 달라도 같은 셰이더를 공유한다면 모두 묶을 수 있어 효율이 매우 높지만 기존의 Built-in 렌더 파이프라인에서는 지원되지 않는다.</p>
<p style="color: #333333; text-align: start;">&nbsp;</p>
<p style="color: #333333; text-align: start;">여기서 다이나믹 배칭의 경우 조건이 까다로운데 그 이유는 물체가 조금이라도 복잡해지면 계산해서 합친 후(배칭) 보내는 것보다 개별적으로 드로우콜을 보내는 것이 더 빠르다고 판단하기 때문이다.</p>
<p style="color: #333333; text-align: start;">&nbsp;</p>
<p style="color: #333333; text-align: start;">따라서 최근에는 SRP Batcher나 GPU Instancing이 훨씬 효율적이기 때문에 동적 배칭은 사실상 권장되지 않는 추세이다. 특히 모바일 환경에서는 CPU 부하를 줄이는 것이 발열과 배터리 관리에 유리하기 때문이다.</p>
<p style="color: #333333; text-align: start;">&nbsp;</p>
<p style="color: #333333; text-align: start;">유니티 개발자는 Draw Call을 직접 줄이는 것이 아니라, 배칭 시스템이 작동할 수 있는 조건을 설계 단계부터 갖춰야 한다.</p>
<p style="color: #333333; text-align: start;">&nbsp;</p>
<h3 style="color: #333333; text-align: start;">라이팅 최적화</h3>
<p style="color: #333333; text-align: start;">라이팅은 렌더링에서 가장 비용이 큰 연산 중 하나다. 특히 Forward Rendering에서는 라이트 수에 비례해 Draw Call 이 증가한다.</p>
<p style="color: #333333; text-align: start;">&nbsp;</p>
<p style="color: #333333; text-align: start;"><b>Baked Lighting (라이트맵)</b></p>
<p style="color: #333333; text-align: start;">정적 오브젝트의 조명 결과를 텍스처(라이트맵)에 미리 구워 저장한다.</p>
<p style="color: #333333; text-align: start;">런타임 라이팅 연산이 없어 성능 부담이 없지만 동적 오브젝트에는 적용되지 않으며 라이트맵 메모리를 사용한다.</p>
<p style="color: #333333; text-align: start;">&nbsp;</p>
<p style="color: #333333; text-align: start;"><b>Realtime Light 최소화</b></p>
<p style="color: #333333; text-align: start;">Realtime Light는 매 프레임 연산이 발생하므로 수를 최소화한다.</p>
<p style="color: #333333; text-align: start;">- Forward Rendering에서 Realtime Light 가 n 개면 영향받는 오브젝트마다 Draw Call 이 n 배 증가&nbsp;</p>
<p style="color: #333333; text-align: start;">가능하면 Baked Light를 사용하고 보조적으로 Realtime Light 조합을 권장한다.</p>
<p style="color: #333333; text-align: start;">&nbsp;</p>
<p><b>Shadow 최적화</b></p>
<p>Shadow Casting 은 그림자를 생성하는 모든 오브젝트에 추가 Draw Call을 유발한다.</p>
<p>- Mesh Renderer의 Cast Shadows를 불필요한 오브젝트에서 Off 처리</p>
<p>- Shadow Distance를 줄여 원거리 오브젝트의 그림자 연산 제거</p>
<p>- Shadow Resolution을 낮춰 GPU 메모리 및 연산 절감</p>

<h3>컬링 최적화</h3>
<p>컬링은 렌더링 할 필요가 없는 오브젝트를 사전에 제외하여 GPU 부하를 줄이는 기법이다.</p>

<p><b>Frustum Culling</b></p>
<p>카메라의 시야각(Frustum) 밖에 있는 오브젝트는 렌더링 하지 않는다.</p>
<p>Unity에서 기본적으로 자동 적용된다.</p>

<p><b>Occlusion Culling</b></p>
<p>다른 오브젝트에 완전히 가려진 오브젝트를 렌더링 대상에서 제외한다.</p>
<p>Window &gt; Rendering &gt; Occlusion Culling에서 Bake 필요</p>
<p>실내 공간, 밀집된 환경에서 효과적이다.</p>
<p>단, Occlusion Culling 데이터를 Bake 하는 비용이 발생하므로 단순한 씬에서는 오히려 비효율적일 수 있다.</p>

<p><b>LOD (Level of Detail)</b></p>
<p>카메라와의 거리에 따라 메쉬의 폴리곤 수를 단계적으로 줄이는 기법이다.</p>
<p>LOD Group 컴포넌트로 설정하며, 원거리 오브젝트의 GPU 버텍스 처리 부하를 감소시킨다.</p>
<p>예) LOD0 (5000 폴리) -&gt; LOD1 (1500 폴리) -&gt; LOD2 (300 폴리) -&gt; Culled</p>

<h3>텍스처 최적화</h3>
<p><b>Texture Atlas (텍스처 아틀라스)</b></p>
<p>여러 텍스처를 하나의 큰 텍스처로 합치는 기법</p>
<p>머티리얼 수를 줄여 배칭 조건 충족에 직접 기여</p>
<p>Sprite Atlas (UI/2D), 수동 아틀라스 방식으로 적용</p>

<p><b>텍스처 압축</b></p>
<p>텍스처를 플랫폼에 맞는 압축 포맷으로 설정하여 GPU 메모리 절감</p>
<p>- Android : ETC2, ASTC</p>
<p>- iOS : ASTC, PVRTC</p>
<p>- PC : DXT (BC1/BC3)</p>

<p>Texture Import Settings의 Max Size를 실제 필요 해상도 이상으로 설정하지 않도록 한다.</p>

<p><b>Mipmap</b></p>
<p>- 원거리 오브젝트에 저해상도 텍스처를 자동 적용하여 GPU 메모리 접근 비용 감소</p>
<p>- 3D 오브젝트에는 Mipmap을 활성화, 고정 크기 UI 텍스처에는 비활성화</p>

<h3>UI(Canvas) 최적화</h3>
<p>Unity UI는 Canvas 단위로 렌더링 된다. Canvas 내 UI 요소가 변경되면 Canvas 전체가 재빌드되어 Draw Call 이 재생성된다.</p>

<p><b>Canvas 분리</b></p>
<p>자주 변경되는 UI(HP 바, 타이머 등)와 정적 UI (배경 패널, 버튼 레이아웃 등)를 별도 Canvas로 분리하여,</p>
<p>변경이 발생해도 해당 Canvas 만 리빌드 되어 전체 재빌드를 방지한다.</p>

<p>※ Canvas - Canvas 계층 관계에 있을 때&nbsp;</p>
<p>자식 Canvas에서 변경 발생 시 부모 Canvas는 재빌드 되지 않는다.</p>
<p>- 자식 오브젝트에 Canvas 컴포넌트가 추가되면 해당 지점부터 부모 캔버스의 렌더링 루프에서 분리되어 별도의 레이어가 된다.</p>
<p>부모 Canvas가 재빌드 시 자식 Canvas는 재빌드 되지 않는다.</p>
<p>- 부모 Canvas가 재빌드될 때 자식들 중 캔버스의 내부 요소들까지는 다시 계산하지 않는다.</p>
<p>- 다만, 부모 Canvas의 재빌드로 인해 전체적인 드로우 콜 순서나 렌더링 상태는 다시 체크될 수 있다.</p>

<p><b>UI 요소 머티리얼 공유</b></p>
<p>같은 Atlas 텍스처를 사용하는 UI 요소는 자동으로 배칭 되므로 Sprite Atlas를 활용해 UI 텍스처를 통합하면 Draw Call 이 감소한다.</p>

<p><b>Raycast Target 설정</b></p>
<p>클릭/터치 반응이 필요 없는 UI 요소는 Raycast Target을 비활성화하면 Raycast 검사 대상이 줄어들어 매 프레임 UI 입력 처리 비용 감소한다.</p>

<h3>셰이더 최적화</h3>
<p>- 복잡한 셰이더는 GPU 픽셀 연산 비용을 직접 올린다.</p>
<p>- 모바일 환경에서는 Unlit, Mobile 셰이더를 우선 사용한다.</p>
<p>- 버텍스 셰이더보다 픽셀(프래그먼트) 셰이더 연산을 최소화한다.</p>
<p>- 불필요한 텍스처 샘플링과 분기문은 제거한다.</p>
<p>- Shader Variant 수 관리 : 키워드 조합이 많을수록 컴파일 시간과 메모리가 증가한다.</p>

<h3>포스트 프로세싱 최적화</h3>
<p>포스트 프로세싱 효과는 화면 전체에 적용되므로 GPU 비용이 크기 때문에&nbsp;모바일에서는 Bloom, Ambient Occlusion, Depth of Field 등 고비용 효과 사용 시 주의가 필요하다.</p>

<p>URP의 Render Feature를 활용해 필요한 효과만 선택적으로 적용하고 효과별 Intensity와 Quality 설정을 플랫폼에 맞게 조정한다.</p>
