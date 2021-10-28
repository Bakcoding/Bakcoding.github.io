---
title:  "ThreeBullets #3"
excerpt: "cocos, myproject, threebullets, resolution"

categories:
  - ThreeBullets
tags:
  - [cocos, myproject, threebullets, resolution]

toc: true
toc_sticky: true
 
date: 2021-08-25  
last_modified_at: 2021-08-25
---  

***

### cocos2d 화면
화면의 크기는 기기마다 다양하기 때문에 특정 사이즈에 맞춰서 작업을 했을 때 다른 크기의 화면에서 이미지가 잘리거나 빈공간이 생기는 등 문제가 발생한다.  
이런 문제를 해결하기 위해서 화면의 크기에 대응해서 이미지들을 보정하는 작업이 필요하다.  

cocos2d에서는 이런 보정에 관련된 기능들이 제공된다.  

**ResolutionPolicy::EXACT_FIT**  
화면에 꽉 채운다. 화면에 맟줘서 늘리고 줄이기 때문에 비율이 달라질 수 있다.

**ResolutionPolicy::NO_BORDER**  
가장자리, 경계가 없다. 작업할 때 원본의 크기가 유지되지만 해상도가 다를 경우 화면을 벗어나는 부분이 잘릴 수 있다.
 
**ResolutionPolicy::SHOW_ALL**  
원본의 비율을 유지해서 어플리케이션 전체를 보여주지만 가장자리 비는 공간이 생길 수 있다.  

**ResolutionPolicy::FIXED_HEIGT**  
높이를 고정한다.  

**ResolutionPolicy::FIXED_WIDTH**  
너비를 고정한다.    


<br/>

### 프로젝트 화면 세팅
앞에서 화면의 사이즈를 따로 만들었다. 사이즈를 실제로 반영하는 함수 부분의 아래에 보정에 관한 부분이 있다.  

```cpp
// Set the design resolution
glview->setDesignResolutionSize(designResolutionSize.width, designResolutionSize.height, ResolutionPolicy::NO_BORDER);

auto frameSize = glview->getFrameSize();
// if the frame's height is larger than the height of medium size.
if (frameSize.height > mediumResolutionSize.height)
{        
    director->setContentScaleFactor(MIN(largeResolutionSize.height/designResolutionSize.height, largeResolutionSize.width/designResolutionSize.width));
}
// if the frame's height is larger than the height of small size.
else if (frameSize.height > smallResolutionSize.height)
{        
    director->setContentScaleFactor(MIN(mediumResolutionSize.height/designResolutionSize.height, mediumResolutionSize.width/designResolutionSize.width));
}
// if the frame's height is smaller than the height of medium size.
else
{        
    director->setContentScaleFactor(MIN(smallResolutionSize.height/designResolutionSize.height, smallResolutionSize.width/designResolutionSize.width));
}
```
* glview->setDesignResolutionSize(designResolutionSize.width, designResolutionSize.height, ResolutionPolicy::NO_BORDER);  
	이 부분에서 ResolutionPolicy의 설정대로 어느정도 보정이 이루어진다. 
사이즈를 받는 부분에서 위에서 정해놓은 변수를 가져다 쓰기 때문에 이 부분도 내가 만든 변수로 바꿔야 제대로 동작할것같다.

* auto frameSize = glview->getFrameSize();  
	실행중인 프로그램의 화면을 가져온다. 이 정보를 가지고 화면에 대응해서 스케일을 조절한다.  

그 밑으로 조건문 부분은 제대로 동작하지도 않고 지워도 문제가 없다. 정밀한 보정을 하려면 위 정보를 가지고 직접 만드는게 좋을것 같다.