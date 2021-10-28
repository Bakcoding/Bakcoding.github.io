---
title:  "HelloWorld"
excerpt: "cocos, 2dx, hello"

categories:
  - Cocos
tags:
  - [cocos, 2dx, hello]

toc: true
toc_sticky: true
 
date: 2021-08-20  
last_modified_at: 2021-08-20
---  

***

### 프로젝트 살펴보기
기본으로 HelloWorldScene 파일이 생성되어있다.
파일경로는 HelloCocos > Source Files > Classes 이다.
새로 파일을 생성할 때도 이 위치로 경로를 잡아주어야 빌드시 문제가 생기지 않는다.

Resources 폴더도 열어보면 처음 실행창에 사용된 이미지들이 있다. 이 위치가 리소스를 불러오는 경로로 사용된다.

<br/>

### HelloWorldScene.h

```c++
#ifndef __HELLOWORLD_SCENE_H__
#define __HELLOWORLD_SCENE_H__

#include "cocos2d.h"

class HelloWorld : public cocos2d::Scene
{
public:
    static cocos2d::Scene* createScene();

    virtual bool init();
    
    // a selector callback
    void menuCloseCallback(cocos2d::Ref* pSender);
    
    // implement the "static create()" method manually
    CREATE_FUNC(HelloWorld);
};

#endif // __HELLOWORLD_SCENE_H__
```

**#ifndef / #define / #endif**  
중복 컴파일 방지 코드를 사용했다.

**#include "cocos2d.h"**  
cocos2d에서 지원하는 기능을 사용하기 위한 헤더파일 
c++의 기본적인 라이브러도 포함하고 있다.

**cocosd::Scene**  
Scene을 상속받은 클래스이다. 
cocos2d의 기능을 사용할 때 마다 cocos2d::를 써줘야하기 때문에 using을 사용해주는게 편하다.
using namespace cocos2d 이걸 줄여서 만든 매크로 USING_NS_CC 가 있다.

**static cocos2d::Scene\* createScene()**  
Scene을 반환하는 정적 함수, static 정적 선언은 객체를 만들지 않아도 호출이 가능하다.
cpp파일에서 함수 내부를 보면 HelloWorld::create()를 리턴한다. 그런데 헤더 파일을 살펴보아도 create()함수는 보이지 않는다. 가장 아래에 있는 함수를 보면
매크로 형태로 만들어진 함수가 있다.

**CREATE_FUCN(HelloWorld)**  
클래스를 만들 때 필수적으로 만들어야하는 함수들이 있다. create()가 그 중 하나로
메모리를 자동으로 할당하고 해제하는 기능을 사용하기 위해서인데 이 함수를 직접작성
하려면 코드의 양이 많고 번거롭기 때문에 매크로를 지원한다.

원형
```cpp
static HelloWorld* create()
{
	HelloWorld* pHelloWorld = new HelloWorld;

	if (pHelloWorld != nullptr && pHelloWorld->init())
	{
		pHelloWorld->autorelease();
		return pHelloWorld;
	}

	else
	{
		if (pHelloWorld != nullptr)
		{
			delete pHelloWorld;
			pHelloWorld = nullptr;
		}
	}
	return nullptr;
{
```

이 함수는 호출시 자동으로 객체를 동적할당 하고 해제까지 한다.  
여기서 사용되는 방식은 참조 횟수 계산 방식(reference count)으로 메모리를 제어한다. 

create() 함수내에 있는 auto release()는 호출 될 때 참조값을 감소시키고 반대로
할당될 때는 retain()함수가 호출되면서 참조값을 증가 시키며 
이 참조값이 0이 될 때 메모리는 삭제된다.

클래스를 새로 만들 때 create()는 반드시 작성해 주어야하는 코드이며 이 때 호출되는 init() 또한 필수로 작성이 필요하다.

<br/>

**virtual bool init()**  
가상 함수이기 때문에 자식 클래스에서 완성시켜서 사용해야한다.  
init은 initialize, 즉 초기화 하는 기능을 가진다. cpp로 가서 함수 내부를 보면

```cpp
    if ( !Scene::init() )
    {
        return false;
    }
```

Scene에서 init() 을 체크해서 scene이 생성되었는지 확인 후 다음 코드를 진행한다.
그 아래 코드들을 보면 화면에 출력되었던 이미지, 버튼, 글자가 만들어지는걸 볼 수 있다.
Menu 에서 버튼, Label에서 Hello World 문장, Sprite에서 이미지 객체를 각 각 생성하는걸
볼 수 있다. 그리고 공통적으로 객체들을 addChild를 해준다. 이 함수는 호출될 때 함수
내부적으로 retain() 함수가 호출되면서 참조값을 증가 시키게 된다. 

**void menuCloseCallback(cocos2d::Ref* pSender);**
프로젝트를 실행시켰을 때 화면 구석에 종료버튼이 있었다. 이 버튼이 동작하기 위한 함수로
함수 내용을 보면 scene을 관리하는 Director에서 end()를 호출해서 프로그램이 종료되는 기능을 한다.
이 함수 역시 실제로 화면에 반영되기 위해서는 init() 영역에서 호출이 필요하고
init() 안에서 create()를 통해 객체를 생성하는걸 볼 수 있다.

<br/>

### AppDelegate.cpp
이 파일은 애플리케이션의 실행과 기타 설정에 관련된 코드들이 있다.
include 부분을 보면 HelloWorldScene.h를 포함시키고 있는데  최종적으로
Scene이 화면에 출력되기 위해서는 여기서 호출되어야 한다.

코드가 기본상태라면 111번 줄에서 HelloWorld 객체를 생성하는게 보인다.
생성된 객체는 director에서 runWithScene()라는 함수에 전달인자로 사용한다. 
함수 이름을 보면 대충 시작시 출력할 화면을 정하는거 같다.

다시 처음으로 가서 살펴 보면 화면의 크기로 보이는 코드가 있다.

```cpp
// Size(width, height)
static cocos2d::Size designResolutionSize = cocos2d::Size(480, 320);
static cocos2d::Size smallResolutionSize = cocos2d::Size(480, 320);
static cocos2d::Size mediumResolutionSize = cocos2d::Size(1024, 768);
static cocos2d::Size largeResolutionSize = cocos2d::Size(2048, 1536);
```
Size의 매개변수를 확인해보면 앞의 숫자가 너비, 뒤가 높이를 나타낸다.
일반적으로 많이 쓰이는 규격을 만들어 놓은거 같은데 이 사이즈를 필요에 따라서 바꿔 쓰면될 것 같다.

이제 이걸 가져다 쓰는 곳이 어딘지 찾아보면 applicationDidFinishLaunching() 함수 안에서

```cpp
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32) || (CC_TARGET_PLATFORM == CC_PLATFORM_MAC) || (CC_TARGET_PLATFORM == CC_PLATFORM_LINUX)
        glview = GLViewImpl::createWithRect("HelloCocos", cocos2d::Rect(0, 0, designResolutionSize.width, designResolutionSize.height));
#else
        glview = GLViewImpl::create("HelloCocos");
#endif
        director->setOpenGLView(glview);
    }
```

플랫폼을 확인하고 화면을 생성한다.  


**createWithRect("HelloCocos", cocos2d::Rect(0, 0, designResolutionSize.width, designResolutionSize.height))**  
맨 앞 문자열은 실행된 창의 이름 부분, 그리고 사각형을 전달인자로 넣는데 여기서 위에서 봤던 사이즈 들이 사용된다.
자신이 사용할 사이즈를 따로 만들어서 여기서 변수를 가져다 쓰는게 편할 것 같다.


