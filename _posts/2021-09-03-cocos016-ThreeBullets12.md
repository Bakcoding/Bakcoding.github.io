---
title:  "ThreeBullets #12"
excerpt: "cocos, myproject, threebullets, androidstudio"

categories:
  - ThreeBullets
tags:
  - [cocos, myproject, threebullets, androidstudio]

toc: true
toc_sticky: true
 
date: 2021-09-03 
last_modified_at: 2023-06-04
---  

***

### 안드로이드로 포팅하기  
완성된 게임을 안드로이드에서 플레이하기 위해서 안드로이드 스튜디오를 통한 포팅이 필요한데 그 전에 준비가 필요하다. 
cocos2dx 프로젝트 폴더를 CMakeLists 문서 파일이 보인다. 이 파일은 CMake로 cocos2d 프로젝트를 만들 때 참고하는 근거가 되는데 처음 프로젝트를 
생성할 때 사용했고 이제 안드로이드로 포팅할 때 다시 필요하다.  

문서를 내리다 보면 중간 쯤에 이런 코드들이 보인다.

```
# add cross-platforms source files and header files 
list(APPEND GAME_SOURCE
	Classes/AppDelegate.cpp
	Classes/HelloWorld.cpp
     )
list(APPEND GAME_HEADER
	Classes/AppDelegate.h
	Classes/HelloWorld.h
     )
```

수정하지 않은 초기상태라면 위와 같은 코드이며 이는 프로젝트를 생성할 때 사용할 소스파일의 경로와 이름을 나타낸다. 위는 cpp 아래는 h 구분을 하며 
여기다 내가 만든 파일들을 추가해주면 된다. HelloWorld의 경우 지웠을 경우 여기서도 지워줘야한다. 

수정이 끝나고 프로젝트 폴더를 다시보면 proj.운영체제 이름 의 폴더들이 있는데 이 폴더들이 cocos2dx가 멀티플랫폼에 대응하기 위해 지원하는 것들이다.  
안드로이드 스튜디오를 켜고 import project를 눌러 이 폴더에 있는 proj.android 폴더를 선택해서 열어주면 된다.  

![import](/assets/images/posting/20210903/android_studio_project_compile.png)

안드로이드 스튜디오는 기반 언어가 java이지만 JNI(java native interface)를 사용해서 다른 언어들도 실행이 가능하게 된다. 독자적인 언어인 kotlin도 사용하기 때문에 조만간 알아보기로 한다. 
우선 내가 사용할 ndk와 sdk를 설정해주는 과정이 필요하다.  

Tools > SDK Manager를 열어준다.

![android_studio_sdk_manager](/assets/images/posting/20210903/android_studio_sdk_manager.png)  

sdk는 필요에 따라서 버전을 골라서 받으면 된다. 우선 이것저것 다운받아 놓았다.

![android_studio_sdk_import](/assets/images/posting/20210903/android_studio_sdk_import.png)  

옆에 카테고리 sdk tools에서 ndk(side by sied)와 cmake는 프로젝트 실행을 위해서 꼭 필요하고 나머지는 부가적인 기능들로 검색해보고 필요에 따라서 설치한다.  

망치 아이콘을 눌러 프로젝트를 생성해보니 에러가 발생했다. 에러는 붉은 글씨로 gradle과 java null이 보였는데  
File > Project Structure > Project의 gradle 버전을 최신으로 바꾸어 보니 위의 에러는 해결이 됐지만 
다음은 내가 작성한 코드에서 에러들이 발생했다. 비주얼 스튜디오에서는 에러로 뜨지 않았던 부분들이라 놓치고 지나갔지만 큰 문제는 아니여서 금방 해결이 됐다.  
bool 반환형 함수에서 return true를 안하거나 상속받은 함수를 재정의 할 대 override를 쓰지 않았던 부분들  

에러들을 고치고 핸드폰을 연결해서 실행시켜보니

![device_play_resolution_issue](/assets/images/posting/20210903/device_play_resolution_issue.jpg)

 
해상도가 달라서 이미지 스케일이 다 바뀌게 되었는데 이걸 수정하기 위해서 직접 보정 코드를 만든다.  

```cpp
     Size visibleSize = Director::getInstance()->getVisibleSize();

     if (visibleSize.height < smallResolutionSize.height)
     {
         director->setContentScaleFactor(smallResolutionSize.height / visibleSize.height);
     }
     else if (visibleSize.width < smallResolutionSize.width)
     {
         director->setContentScaleFactor(smallResolutionSize.width / visibleSize.width);
     }

     if (visibleSize.height > smallResolutionSize.height)
     {
         director->setContentScaleFactor(visibleSize.height / smallResolutionSize.height);
     }
     else if (visibleSize.width > smallResolutionSize.width)
     {
         director->setContentScaleFactor(visibleSize.width / smallResolutionSize.width);
     }
```

![play_test](/assets/images/posting/20210903/play_test.gif)

잘 적용되었다.  
 

