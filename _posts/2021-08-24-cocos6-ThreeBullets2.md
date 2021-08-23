---
title:  "ThreeBullets #2"
excerpt: "cocos, myproject, threebullets"

categories:
  - ThreeBullets
tags:
  - [cocos, myproject, threebullets]

toc: true
toc_sticky: true
 
date: 2021-08-24  
last_modified_at: 2021-08-24
---  

***

### 화면의 크기  
플랫폼은 모바일로 정하고 프로그램이 실행되는 창의 크기를 정한다.  
테스트를 위해서 내 스마트폰 기준 18.5 : 9의 화면크기로 만든다. 다른 화면 비율에 대응하기 위한 스케일 팩터 기능을 제공하는데 이건 나중에 다루기로 한다. 

```cpp
// AppDelegate.cpp
// 나중에 시작화면 호출을 위해서 TitleScene.h를 include 해준다.

// 18.5 : 9 화면 비율
// 재사용이나 수정 편의를 위해 변수로 만들어 놓음
float widthRate = 9.0f;
float heightRate = 18.5f;
static cocos2d::Size mySize = cocos2d::Size(widthRate * 50, heightRate * 50);

// 실제 화면에 반영되는 부분, 여기서 처음 화면 호출도 함
bool AppDelegate::applicationDidFinishLaunching() {

	~

        // createWithRect("프로그램 이름", 크기(전달인자에 내가만든 사이즈를 넣어준다.)) 
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32) || (CC_TARGET_PLATFORM == CC_PLATFORM_MAC) || (CC_TARGET_PLATFORM == CC_PLATFORM_LINUX)
        glview = GLViewImpl::createWithRect("ThreeBullets", cocos2d::Rect(0, 0, mySize.width, mySize.height));

	~

    // create a scene. it's an autorelease object
    auto scene = TitleScene::createScene();

    // run
    director->runWithScene(scene);

    return true;
}
```

### 타이틀 씬  
게임을 시작했을 때 보이는 처음 화면을 만든다.  
타이틀 씬은 게임의 타이틀과 시작, 종료 버튼으로 구성한다.  

```cpp
// TitleScene.h
#ifndef _TITLE_SCENE_
#define _TITLE_SCENE_
#include "cocos2d.h"
#include "GameScene.h"
USING_NS_CC;

class TitleScene : public Scene
{
public:
	// 차일드에 태그를 붙이는 용도
	enum ETag {kStart = 0, kExit = 1};

	static TitleScene* createScene();
	CREATE_FUNC(TitleScene);
	virtual bool init() override;

	void initTitle();
	void initButton();

	void titlesceneCallBack(Ref* _sender);
};

#endif
```

```cpp
//TitleScene.cpp
#include "TitleScene.h"

TitleScene* TitleScene::createScene() {
	return create();	
}

bool TitleScene::init()
{
	if (!Scene::init())
	{
		return false;
	}

	initTitle();
	initButton();


	return true;
}

// 게임 타이틀 로고
void TitleScene::initTitle()
{
	// 화면의 크기를 가져옴
	Size winSize = Director::getInstance()->getWinSize();
	float positonX = winSize.width * 0.5f;
	float positionY = winSize.height * 0.7f;

	Sprite* title = Sprite::create("Title/Logo.png");
	// 위치 조정
	title->setPosition(positonX, positionY);
	// 이미지 크기 조정
	title->setScale(1.5f);
	this->addChild(title);
}

// 시작 버튼
void TitleScene::initButton()
{
	Size winSize = Director::getInstance()->getWinSize();
	float positionX = winSize.width * 0.5f;
	float positionY = winSize.height * 0.3f;
	
	// 시작 버튼 상호작용
	MenuItemImage* start = MenuItemImage::create(
		// 파일 경로 Resources 폴더
		// 이미지 두 개 : 일반상태와 클릭시
		"Title/StartButtonNormal.png",
		"Title/StartButtonSelect.png",
		// 입력 처리하는 콜백 함수
		CC_CALLBACK_1(TitleScene::titlesceneCallBack, this));

	// 종료 버튼 상호작용
	MenuItemImage* exit = MenuItemImage::create(
		"Title/ExitButtonNormal.png",
		"Title/ExitButtonSelect.png",
		CC_CALLBACK_1(TitleScene::titlesceneCallBack, this));

	// 이미지 크기 조정
	start->setScale(2.0f);
	exit->setScale(2.0f);

	// 버튼 위치, Menu로 만들어서 묶어서 관리, 마지막 전달인자 NULL로 끝 표시
	Menu* menu = Menu::create(start, exit, NULL);
	// 메뉴로 만든 객체 수직 정렬
	menu->alignItemsVertically();
	// 위치 조정
	menu->setPosition(positionX, positionY);
	// 객체 태그 설정
	start->setTag(ETag::kStart);
	exit->setTag(ETag::kExit);

	this->addChild(menu);
}

// 버튼 구분
void TitleScene::titlesceneCallBack(Ref* _sender)
{
	// MenuItem 만든 객체 태그로 구분
	switch (((MenuItemImage*)_sender)->getTag())
	{
	// 시작
	case ETag::kStart:
		// 씬 전환
		Director::getInstance()->replaceScene(TransitionFade::create(1.0f, GameScene::create()));
		break;
	// 종료		
	case ETag::kExit:
		// 프로그램 종료
		Director::getInstance()->end();
		break;
	}
}
```

씬 전환 확인을 위해 임시로 아무기능 없는 GameScene 파일 생성한다.
실행 결과 정상적으로 화면에 TitleScene이 표시되고 버튼도 동작한다.