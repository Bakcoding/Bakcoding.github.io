---
title:  "[왕초보도 할 수 있는 VR] 타워디펜스 9 - 빌드"
excerpt: "unity3d, vr, build"

categories:
  - UnityExample
tags:
  - [unity3d, vr, build]

toc: true
toc_sticky: true
 
date: 2022-01-12 
last_modified_at: 2022-01-12
---  

***  
<a href="https://www.gseek.kr/member/rl/studyRoom/studyRoomMain.do?courseSeq=2069&courseCsSeq=1&stuSeq=&subjSeq=5&pageNum=1">VR 강의</a>

Unity version 2018.1.1f1

### 안드로이드 빌드

안드로이드 빌드를 위해서 SDK가 필요하다. 

#### SDK 준비

* 안드로이드 SDK


	Edit > Preferences > External Tools 에서 Android 탭을 보면 확인할 수 있다.  

	Download를 누르면 다운받을 수 있는 페이지로 연결된다. 

	용량이 크기 때문에 필요한 버전을 골라서 다운 받는다. 

	다운을 완료했다면 Download 버튼 옆의 Browse를 클릭하면 자동으로 설치된 경로를 잡아준다. 

* 자바 SDK(JDK)

	JDK는 자동으로 경로를 잡아주지 않기 때문에 설치 경로를 잘 기억해 둔 다음 Browse를 클릭하고 직접 경로를 잡아준다. 

<br>

### 빌드 세팅

File > Build Settings > Player Settings 로 인스펙터 창을 연다. 

* Identification
	
	* Package Name 

		>com.Company.ProductName
		>com.회사명/개발자명.프로젝트명
	
		기본 값으로 설정되어있으면 빌드가 되지 않는다. 


* Configuration

	* Target Architectures

		프로세서 타입을 선택한다. 
		
		기본적으로 ARMv7, x86 모두 체크되어있으며 용량에 큰 영향을 미친다.  

		요즘의 안드로이드는 x86을 사용하지 않기 때문에 ARMv7만 사용해도 무방하다.  


