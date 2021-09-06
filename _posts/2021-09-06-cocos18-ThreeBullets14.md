---
title:  "ThreeBullets #14"
excerpt: "cocos, myproject, threebullets, googleconsole"

categories:
  - ThreeBullets
tags:
  - [cocos, myproject, threebullets, googleconsole]

toc: true
toc_sticky: true
 
date: 2021-09-06 
last_modified_at: 2021-09-06
---  

***

### 플레이 스토어에 출시하기
플레이 스토어에 출시하기 위해서는 우선 ![Google Playe Console](https://play.google.com/console)의 계정을 만들어야한다.  
개발자를 등록하기 위해서는 2.5$의 비용이 발생한다.  

그리고 구글에서 정한 지켜야할 양식들이 있다.  

<br/>

### 타겟 API 수준  
앱을 등록하기 위해서는 ![Google Play의 타겟 API 수준 요구사항](https://developer.android.com/distribute/best-practices/develop/target-sdk?hl=ko) 
을 충족해 주어야한다. 안드로이드 버전에 따라 요구되는 수준이 다르지만 앞으로 계속해서 변화되는 부분이기 때문에 최신버전에 맞춰서 설정해 놓는게 나은 선택일 것이다.  

안드로이드 스튜디오에서 Tools > SDK Manager를 열어서 SKD Platforms를 보면 안드로이드 버전에 따른 API Level들을 알 수 있고 
자신의 앱이 지원할 최소 버전부터 타겟 버전까지 설치가 필요하다.

![NDK_API](/assets/images/20210906_Posting_cocos/1.png)

안드로이드 스튜디오에서 Gradle Scripts에 build.gradle (Module: proj.MyApp...)를 보면  

```
// build.gradle
    defaultConfig {
        applicationId "com.bakcoding.proj"
        minSdkVersion PROP_MIN_SDK_VERSION
        targetSdkVersion PROP_TARGET_SDK_VERSION
		.
		.
		.
	}

```
여기서 minSdkVersion은 내 앱이 지원하는 최소 버전을 말하며 targetSdkVersion은 내가 목표해서 만든 버전을 말한다. 
값으로 들어가 있는 PROP_MIN_SDK_VERSION와 PROP_TARGET_SDK_VERSION는 gradle.properties에서 정의한 매크로 상수이며 
이 값들을 바로 원하는 상수로 바꿔도 되지만 보기 좋은 코드를 위해서 gradle.properties에서 상수로 정의한 것들의 값을 바꾸어 주도록한다.  

```
// gradle.properties
# Android SDK version that will be used as the compile project
PROP_COMPILE_SDK_VERSION=30

# Android SDK version that will be used as the earliest version of android this application can run on
PROP_MIN_SDK_VERSION=16

# Android SDK version that will be used as the latest version of android this application has been tested on
PROP_TARGET_SDK_VERSION=30
```

최소 버전을 따로 설정했다면 SDK Manager에서 타겟 최소 버전부터 타겟 버전 SDK를 모두 설치해 주어야한다.  
최소 버전의 경우 원하는대로 설정하면 되지만 타겟 API의 경우 안드로이드 업데이트시 구글 플레이에서 요구하는 최소 타겟 값이 바뀌므로 확인해 주어야한다.  

<br/>

### 64비트 아키텍처  
2019년 8월 1일부터 구글 플레이는 ![64비트만 지원](https://developer.android.com/distribute/best-practices/develop/64-bit#test-64-bit-hardware) 하게 된다.  
페이지에 들어가서 보면 그 이유와 방법들을 잘 설명해 놓았다.  

우선 내 프로젝트에서도 수정해 주어야할 부분들이 있다. gradle.properties 파일을 열어서 PROP_APP_ABI를 수정해준다.  

```
// gradle.properties
# List of CPU Archtexture to build that application with
# Available architextures (armeabi-v7a | arm64-v8a | x86)
# To build for multiple architexture, use the `:` between them
# Example - PROP_APP_ABI=armeabi-v7a:arm64-v8a:x86
PROP_APP_ABI=armeabi-v7a:arm64-v8a
```

arm64-v8a가 64비트, x86가 32비트 아키텍처를 말하며 64비트만을 지원하기 때문에 x86은 적으면 나중에 앱을 등록할 때 오류가 발생한다.  

<br/>

### 빌드하기  

Build > Generate Signed Bundle or APK를 눌러 Android App Bundle을 선택해서 번들을 생성해 준다.  
경로를 잘 보이는 곳으로 해주고 key가 없다면 새로 생성을 해주며 비밀번호는 까먹지 않도록 한다.  

![build_1](/assets/images/20210906_Posting_cocos/2.png)  

finish를 누르면 빌드가 시작되는데 시간이 좀 걸린다. 알림이 뜰 때 까지 기다려 주도록한다.  

빌드가 끝나고 설정한 경로를 찾아가면 .abb 파일이 보인다. 플레이 스토어에 등록하기 위해서는 이 확장자로 해주어야한다.  

<br/>

### 등록하기  
플레이 콘솔로 간 다음 앱 만들기를 눌러서 본인의 앱에 해당하는 사항을 체크해 준다.  

![build_1](/assets/images/20210906_Posting_cocos/2.png)  

기본적인 체크가 끝났다면 프로덕션 탭으로 가서 .abb 파일을 업로드 해주고 에러가 없는지 확인이 끝났다면 출시를 한다.  

![build_1](/assets/images/20210906_Posting_cocos/4.png)  

출시를 누른다고 바로 출시가 되지는 않고 약 7일 정도의 검토를 거친 후에 플레이 스토어에 등록이 된다.  
앱을 새로 업로드 할 때 마다 버전을 갱신해 주어야하는데 

```
// build.gradle
        versionCode 7
        versionName "1.7"
```

여기서 버전을 바꿔 주어야하며 동일 버전은 업로드시 사용된 버전이라고 에러를 띄우기 때문에 업로드 전에 확인을 해준다.  
업로드할 때 마다 에러가 하나씩 나는걸 고치다 보니 7까지 와버렸다.  

이제 7일 후에 출시가 되기만을 기다려본다.  

