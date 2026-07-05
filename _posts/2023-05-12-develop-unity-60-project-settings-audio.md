---
title: "Project Settings - Audio"
excerpt: "Project Settings - Audio"
categories:
  - Unity
permalink: /develop/unity/60-project-settings-audio/
tags:
  - "Unity"
  - "Game Development"
  - "audio"
  - "project settings"
  - "unity"
toc: true
toc_sticky: true
date: 2023-05-12
last_modified_at: 2023-05-12
source_url: https://b-note.tistory.com/60
---

<p><span style="text-align: start">에디터 버전 : 2021.3.28f1 (LTS) </span></p>

<h2>Audio</h2>
<p>오디오 시스템을 구성하는 데 사용되는 설정으로 모든 Audio 컴포넌트에 영향을 미치는 전역적인 설정을 제공한다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="483" data-origin-height="306"><span data-alt="Unity Project Settings - Audio"><img src="/assets/images/posts/2023/05/12/60-1.png" loading="lazy" width="483" height="306" data-origin-width="483" data-origin-height="306"/></span><figcaption>Unity Project Settings - Audio</figcaption>
</figure>
</p>

<h3>Global Volume</h3>
<p>오디오 시스템의 볼륨을 전역으로 적용한다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="286" data-origin-height="37"><span data-alt="Audio - Global Volume"><img src="/assets/images/posts/2023/05/12/60-2.png" loading="lazy" width="286" height="37" data-origin-width="286" data-origin-height="37"/></span><figcaption>Audio - Global Volume</figcaption>
</figure>
</p>
<p>볼륨의 초기값에 곱해주는 수로 AudioListner.volume과 동일하다.</p>

<h3>Volume Rolloff Scale</h3>
<p>볼륨이 감쇠되는 정도를 전역으로 조절한다.&nbsp;</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="297" data-origin-height="67"><span data-alt="Audio Volume Rolloff Scale"><img src="/assets/images/posts/2023/05/12/60-3.png" loading="lazy" width="297" height="67" data-origin-width="297" data-origin-height="67"/></span><figcaption>Audio Volume Rolloff Scale</figcaption>
</figure>
</p>
<p>단 Logarithmic Volume Curves 인 경우에만 적용된다.</p>
<p>Logarithmic Volume Curves는 로그 함수 곡선형태로 사운드가 감쇠되는 경우에만 적용되는데 이 사운드는&nbsp;Audio Source 컴포넌트의 속성값 중에 3D Sound Settings의 Volume Rolloff에서 선택할 수 있는 옵션이다.</p>
<p>( 기본으로 Logarithmic Rolloff 설정 )</p>

<p>값은 기본적으로 1로 되어있는데 이 값이 현실에 가장 가까운 수치이다.</p>

<h3>Doppler Factor</h3>
<p>소리에 도플러 효과(Doppler Effect)를 적용시키기 위한 수치이다.&nbsp;</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="305" data-origin-height="57"><span data-alt="Audio Doppler Factor"><img src="/assets/images/posts/2023/05/12/60-4.png" loading="lazy" width="305" height="57" data-origin-width="305" data-origin-height="57"/></span><figcaption>Audio Doppler Factor</figcaption>
</figure>
</p>
<p>원하는 도플러 효과를 얻기 위해서 해당 수치를 조절할 수 있다.</p>

<h4>Doppler Effect</h4>
<p>도플러 효과란 파동의 진동수가 왜곡되는 현상이다. 음원(소리의 근원지)가 움직이면서 파원이 다가오고 있을 때 정지한 관찰자에게는 파동의 파장이 실제보다 짧게 느껴지고 다시 멀어지게 되면 파장이 실제보다 길게 느껴지는 것이다.</p>

<p>예를 들어 멀리서부터 소방차가 사이렌을 켜고 달려오고 있다. 이때 멀리서부터 나에게 가까워지는 동안에는 사이렌의 소리가 점점 높아지는 것처럼 들리다가 내 옆을 지나쳐 멀어질 때는 낮아지는 것처럼 느껴진다. 하지만 <span style="text-align: start"><span>&nbsp;</span>이는 상대적인 효과로 관찰자만 느끼는 현상이고 소방차에 탑승한 사람에게는 일정한 소리로 들린다.</span></p>

<p><span style="text-align: start">유니티의 프로젝트 세팅에서 Doppler Factor 수치는 기본적으로 1이다. 이 수치는 소리의 움직임이 실제 도플러 효과와 거의 동일하게 시뮬레이션되며 값이 0에 가까워질수록 도플러 효과가 감소하고 값이 높아질수록 강조된다.</span></p>

<h3><span style="text-align: start">Default Speaker Mode</span></h3>
<p><span style="text-align: start">프로젝트의 오디오 출력을 설정할 수 있는 옵션이다. 유니티 엔진에서 오디오가 재생될 때 사용되는 스피커의 타입을 지정할 수 있다.</span></p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="326" data-origin-height="78"><span data-alt="Audio - Default Speaker Mode"><img src="/assets/images/posts/2023/05/12/60-5.png" loading="lazy" width="326" height="78" data-origin-width="326" data-origin-height="78"/></span><figcaption>Audio - Default Speaker Mode</figcaption>
</figure>
</p>
<p>옵션의 종류는 다음과 같다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="173" data-origin-height="178"><span data-alt="Default Speaker Mode - Option"><img src="/assets/images/posts/2023/05/12/60-6.png" loading="lazy" width="173" height="178" data-origin-width="173" data-origin-height="178"/></span><figcaption>Default Speaker Mode - Option</figcaption>
</figure>
</p>

<p><b>Mono</b></p>
<p>채널 개수가 1개이다.</p>
<p>오디오를 단일 스피커에서 재생한다. 오디오 소스는 좌우 채널이 결합된 단일 스피커로 재생된다.&nbsp;</p>
<p>주로 모노 오디오 효과나 음성 등 단일 채널 오디오를 재생하는 데 사용된다.</p>

<p><b>Stereo</b></p>
<p>채널 개수가 2개이다.</p>
<p>좌우 스피커에서 각각의 채널이 재생된다. 대부분의 오디오에서 사용되는 일반적인 스테레오 효과를 재생할 때 사용되며 기본으로 선택된 설정이다.</p>

<p><b>Quad</b></p>
<p>채널 개수가 4개이다.</p>
<p>전후좌우&nbsp; 4개의 스피커에 각각의 채널이 재생되며 3D 오디오 효과를 표현할 수 있다.</p>

<p><b>Surround</b></p>
<p>채널 개수는 5개이다.</p>
<p>전면 좌우, 중앙, 후면 좌우 5개의 스피커를 사용한다. 더 입체적인 공간 음향 효과를 재생할 수 있다.</p>

<p><b>Surround 5.1/7.1</b></p>
<p>채널 개수는 5개 이상이다.</p>
<p>전면 좌우, 중앙, 후면 좌우 + 서브 우퍼 채널을 통해 사운드가 재생된다.</p>

<p><b>Prologic DTS(Digital Theater System)</b></p>
<p>채널 개수는 2개이다.</p>
<p>스피커는 스테레오로 출력되지만 데이터는 Prologic/Prologic2 디코더에서 인식하고 5.1 채널 스피커로 분리되도록 인코딩 된다.</p>

<h3>System Sample Rate</h3>
<p>출력되는 샘플 레이트를 설정한다. 해당 수치를 조절하면 오디오 주파수의 표현 범위를 조정할 수 있다. 0으로 설정하면 시스템의 샘플 레이트를 사용하고 0 이외의 값을 설정하면 입력한 값을 샘플 레이트로 사용하게 된다. iOS나 Android와 같은 특정 플랫폼에서 샘플 레이트를 변경할 수 있는 경우에만 해당한다.</p>

<h4>Sample Rate<b></b></h4>
<p>샘플의 빈도수 즉, 1초당 추출되는 샘플의 개수를 뜻한다. 샘플 레이트의 수치가 높을수록 정확한 음원을 저장할 수 있지만 그만큼 용량이 기하급수적으로 증가한다. 이에 따라 적당한 타협선인 44.1kHz의 샘플 레이트가 일반적으로 사용된다.&nbsp;</p>

<h3>DSP Buffer Size</h3>
<p>Digital Signal Processing 버퍼 크기</p>
<p>실시간으로 들어오는 오디오 데이터를 처리하고 재생하기 위해서 일시적으로 저장하는 공간의 크기를 설정한다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="305" data-origin-height="62"><span data-alt="Audio - DSP Buffer Size"><img src="/assets/images/posts/2023/05/12/60-7.png" loading="lazy" width="305" height="62" data-origin-width="305" data-origin-height="62"/></span><figcaption>Audio - DSP Buffer Size</figcaption>
</figure>
</p>
<p>해당 저장공간이 작으면 오디오 데이터가 빠르게 처리되지만 CPU 부하가 증가하고 지연 시간이 감소한다. 반면에 공간이 큰 경우에는 한 번에 더 많은 오디오 데이터가 처리되므로 CPU부하가 감소하고 지연 시간이 증가한다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="184" data-origin-height="110"><span data-alt="DSP Buffer Size"><img src="/assets/images/posts/2023/05/12/60-8.png" loading="lazy" width="184" height="110" data-origin-width="184" data-origin-height="110"/></span><figcaption>DSP Buffer Size</figcaption>
</figure>
</p>
<p><b>Default</b></p>
<p>유니티의 기본 DSP 버퍼 크기를 사용한다. 대부분의 경우 적절한 응답성과 지연 시간을 제공하는 안정적인 설정이다.</p>

<p><b>Best</b> <b>latency</b></p>
<p>지연 시간을 고려하여 성능을 절충한다. 더 낮은 지연 시간이 요구되는 실시간 애플리케이션에 적합하다. CPU 부하가 증가할 수 있고 낮은 CPU 성능에서는 문제가 발생할 수 있다.</p>

<p><b>Good latency</b></p>
<p>지연 시간과 CPU 성능의 균형을 유지한다. 일반적인 오디오 처리 요구 사항을 충족하는데 적합하다.</p>

<p><b>Best performance</b></p>
<p>CPU 성능을 유리하도록 지연시간을 맞춘다. 높은 오디오 처리 요구 사항이 있거나 더 많은 CPU 성능을 활용해야 하는 경우에 적합하며 지연 시간이 증가할 수 있다.</p>

<h3>Max Virtual Voices</h3>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="312" data-origin-height="104"><span data-alt="Audio - Max Virtual Voices"><img src="/assets/images/posts/2023/05/12/60-9.png" loading="lazy" width="312" height="104" data-origin-width="312" data-origin-height="104"/></span><figcaption>Audio - Max Virtual Voices</figcaption>
</figure>
</p>
<p>오디오 시스템이 관리할 수 있는 최대 사운드의 개수를 설정한다. Real Voices의 수보다 크게 설정되어야 하며 그렇지 않은 경우 콘솔에서 경고 메시지가 표시된다. 가장 큰 소리들 중에서 Max Real Voices 수만큼만 실제로 재생되고 나머지 소리들은 재생 위치만 업데이트된다.</p>

<h3>Max Real Voices</h3>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="300" data-origin-height="51"><span data-alt="Audio - Max Real Voices"><img src="/assets/images/posts/2023/05/12/60-10.png" loading="lazy" width="300" height="51" data-origin-width="300" data-origin-height="51"/></span><figcaption>Audio - Max Real Voices</figcaption>
</figure>
</p>
<p>게임에서 동시에 재생 가능한 실제 음성의 수를 설정한다. 매 프레임마다 가장 큰 음성이 선택된다.</p>

<h3>Spatializer Plugin</h3>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="300" data-origin-height="62"><span data-alt="Audio - Spactializer Plugin"><img src="/assets/images/posts/2023/05/12/60-11.png" loading="lazy" width="300" height="62" data-origin-width="300" data-origin-height="62"/></span><figcaption>Audio - Spactializer Plugin</figcaption>
</figure>
</p>
<p>공간화된 오디오 처리를 수행하기 위한 플러그인이다. 오디오를 공간적으로 위치시키고 음향 효과를 적용하여 3D 소리의 현실감을 높이는 데 사용된다.</p>

<p>일반적으로 게임 엔진이나 오디오 미들웨어에서 제공되며 다양한 기능과 설정을 제공한다. 오디오 원본의 위치, 방향, 거리 등을 고려하여 소리를 공간 내에서 정확하게 재생할 수 있으며 일반 스피커 시스템이나 헤드폰을 사용하는 경우, 소리가 사용자 주변에서 움직이거나 공간의 특정 위치에서 들리는 것처럼 느껴지게 된다.</p>

<p>해당 기능을 사용하기 위해서는 해당 플러그인의 최신 SDK 설치가 필요하다.</p>
<p>현재 버전을 기준으로 공식문서에서 안내되는 플러그인 <a href="https://github.com/Unity-Technologies/NativeAudioPlugins" target="_blank" rel="noopener">다운링크</a></p>

<h3>Ambisonic Decoder Plugin</h3>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="274" data-origin-height="55"><span data-alt="Audio - Ambisonic Decoder Plugin"><img src="/assets/images/posts/2023/05/12/60-12.png" loading="lazy" width="274" height="55" data-origin-width="274" data-origin-height="55"/></span><figcaption>Audio - Ambisonic Decoder Plugin</figcaption>
</figure>
</p>
<p>Ambisonic을 Binaural 필터링하기 위한 플러그인을 설정할 수 있다.</p>
<p>유니티에서 제공되는 빌트인 디코더는 없으며 일부 VR 하드웨어 제조사의 경우 오디오 SDK에 유니티용 빌트인 디코더가 있다. 타깃 플랫폼 제조사의 문서를 통해 프로젝트에 적합한지 확인할 수 있다.</p>

<p>Ambisonic 오디오 클립을 임포트 하려면 임포트 한 파일의 Ambisonic 옵션을 체크해야 한다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="251" data-origin-height="156"><span data-alt="Import Ambisonic Audio Clip"><img src="/assets/images/posts/2023/05/12/60-13.png" loading="lazy" width="251" height="156" data-origin-width="251" data-origin-height="156"/></span><figcaption>Import Ambisonic Audio Clip</figcaption>
</figure>
</p>
<p>Ambisonic 클립을 사용하기 위해서는 Audio Source 컴포넌트의 Spatialize 옵션을 비활성화해야 하고 해당 클립이 재생될 때 자동으로 프로젝트에서 선택된 플러그인을 통해서 디코딩된다.</p>

<h4>Ambisonic</h4>
<p>다중 마이크로폰 배열을 사용하여 소리의 공간 정보를 캡처하는 방법이다. 소리의 방향, 거리, 공간 위치 등을 캡처하여 공간적으로 정확한 사운드 재생을 가능하게 한다. 일반적으로 360도 환경 음향을 재현하거나 VR 및 3D 오디오 환경에서 사용된다. 다중 채널 포맷으로 저장되고 Ambisonic을 사용하면 각 채널을 특정 스피커에 매핑하지 않고 사운드필드가 더 전체적인 방법으로 표현된다.&nbsp;</p>
<h4>Binaural</h4>
<p>인간의 이중귀를 모방하여 소리를 전달하는 기술이다. 두 개의 이어폰 또는 헤드폰을 사용해서 소리를 개별적으로 각 귀에 전달함으로 공간적인 사운드 경험을 제공한다. 3D 오디오를 더욱 현실적이고 공간적으로 인지할 수 있도록 한다.</p>

<h3>Disable Unity Audio</h3>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="303" data-origin-height="79"><span data-alt="Disable Unity Audio"><img src="/assets/images/posts/2023/05/12/60-14.png" loading="lazy" width="303" height="79" data-origin-width="303" data-origin-height="79"/></span><figcaption>Disable Unity Audio</figcaption>
</figure>
</p>
<p>런타임에 출력 장치를 할당하지 않도록 설정한다. 내장된 오디오 시스템 이외의 다른 사운드 시스템을 사용하는 경우에 활성화하는 옵션이다.&nbsp;</p>

<h3>Enable Output Suspension (editor only)</h3>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="306" data-origin-height="116"><span data-alt="Enable Output Suspension"><img src="/assets/images/posts/2023/05/12/60-15.png" loading="lazy" width="306" height="116" data-origin-width="306" data-origin-height="116"/></span><figcaption>Enable Output Suspension</figcaption>
</figure>
</p>
<p>출력이 오랜 시간 동안 정지된 것이 감지되면 자동으로 오디오 출력을 일시 중단시킨다. 오디오 시스템을 중단하면 컴퓨터가 절전 모드로 전환되는 것을 방지하는 운영 체제의 기능이 비활성화되고 이를 통해 오랜 시간 동안 정지된 오디오 출력으로 인해 컴퓨터가 절전 모드로 전환되는 것을 방지할 수 있다. 주로 배터리 수명을 연장하거나 오디오가 정지된 상태에서 시스템의 에너지 소비를 최소화하기 위해 사용된다.</p>

<p>해당 설정은 기본적으로 활성화되어 있다.</p>

<h3>Visualize Effects</h3>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="349" data-origin-height="78"><span><img src="/assets/images/posts/2023/05/12/60-16.png" loading="lazy" width="349" height="78" data-origin-width="349" data-origin-height="78"/></span></figure>
</p>
<p>컬링 되는 오브젝트의 Audio Source에서 Spatializer를 동적으로 비활성화하여 CPU를 절약한다.&nbsp;</p>
<p>즉 카메라에 의해 렌더링 되지 않는 오브젝트에 대한 오디오 처리를 제한시킨다.</p>
