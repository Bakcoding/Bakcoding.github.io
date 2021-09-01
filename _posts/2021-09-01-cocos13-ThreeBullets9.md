---
title:  "ThreeBullets #9"
excerpt: "cocos, myproject, threebullets, scroll"

categories:
  - ThreeBullets
tags:
  - [cocos, myproject, threebullets, scroll]

toc: true
toc_sticky: true
 
date: 2021-09-01 
last_modified_at: 2021-09-01
---  

***

### 세부 사항 수정
적의 이미지 크기를 조금 줄이고 소멸되는 위치를 더 이상 총알에 맞을 수 없는 위치에 올 때 사라지도록 바꾸었다.    
총알의 크기도 적당히 줄이고 생성되는 위치를 플레이어 끝부분에 오도록 맞추었다.  

<br/>

### 배경  

* 적 소멸 라인  
적이 소멸되는 위치를 나타내주는 라인을 만들어 준다. 선만 그으면 되기 때문에 이미지를 따로 준비하기 보단 cocos2dx의 기능을 사용한다.  

```cpp
// BackgroundSprite.cpp
void BackgroundSprite::drawEndLine()
{
	Vec2 originPoint = Vec2(0, visibleSize.height * 0.21f);
	Vec2 destPoint = Vec2(visibleSize.width, visibleSize.height * 0.21f);
	DrawNode* endLine = DrawNode::create();
	endLine->drawLine(originPoint, destPoint, Color4F::RED);
	endLine->setLineWidth(0.5f);
	this->addChild(endLine);
}
```

DrawNode 클래스를 사용하면 drawLine 함수를 통해 원하는 위치에 선을 그리고 색도 정할 수 있다.  

* 배경 이미지
우주 공간 느낌을 주기 위해서 별을 몇 개 그려놓은 이미지를 그려서 사용한다.  
그리고 속도감을 주기위해서 이미지를 종스크롤 방식으로 움직여 준다.  

```cpp
// BackgroundSprite.cpp
void BackgroundSprite::initBackground()
{
	for (int imgCount = 0; imgCount < ECount::kImage; ++imgCount)
	{
		backgroundImage[imgCount] = Sprite::create("Background/BackgroundSprite.png");
		imgHeight = backgroundImage[imgCount]->getContentSize().height * backgroundImage[imgCount]->getScale();
		backgroundImage[imgCount]->setAnchorPoint(Vec2::ZERO);
		backgroundImage[imgCount]->setPosition(Vec2(0.0f, imgCount * imgHeight));
		this->addChild(backgroundImage[imgCount]);
	}
}
```

이미지를 배열에 저장한다 두 개가 필요한 이유는 하나의 이미지가 끝나는 지점에 새로운 이미지를 이어 붙이는 방식으로 끝없이 화면이 움직이는 효과를 준다.  

```cpp
// BackgroundSprite.cpp
void BackgroundSprite::scrollBackground(float _dt)
{
	for (int imgCount = 0; imgCount < ECount::kImage; ++imgCount)
	{
		Vec2 currentPos = backgroundImage[imgCount]->getPosition();
		currentPos.y -= imgScrollSpeed * _dt;
		backgroundImage[imgCount]->setPosition(currentPos);
	}
}
```

화면을 움직이는 함수이다. float을 매개변수로 받아서 update에 추가해 움직이도록 해준다. 

```cpp
// BackgroundSprite.cpp
void BackgroundSprite::repositionImage()
{
	for (int imgCount = 0; imgCount < ECount::kImage; imgCount++)
	{
		Vec2 currentPos = backgroundImage[imgCount]->getPosition();
		
		if (currentPos.y < -imgHeight)
		{
			int lastIdx = getImageLastIndex();
			currentPos.y = backgroundImage[lastIdx]->getPosition().y + imgHeight;
		}

		backgroundImage[imgCount]->setPosition(currentPos);
	}
}
```

현재 이미지의 y축 위치가 길이보다 작은 경우는 화면밖으로 이미지가 완전히 사라지면 위치를 뒤에 이미지에 이어 붙이는 방식으로 무한 재생시키기 위한 함수이다.  

```cpp
int BackgroundSprite::getImageLastIndex()
{
	int lastIdx = 0;
	for (int imgCount = 0; imgCount < ECount::kImage; imgCount++)
	{
		if (backgroundImage[lastIdx]->getPosition().y < backgroundImage[imgCount]->getPosition().y)
		{
			lastIdx = imgCount;
		}
	}
	
	return lastIdx;
}
``` 

화면에 보이는 이미지를 기준으로 더 많이 보이는걸 현재 이미지의 인덱스로 값을 반환시킨다. 이 반환값을 이용해서 현재 인덱스를 계속 바꿔주어 이어붙이는게 반복된다.  

<br/>

![play](/assets/images/20210901_Posting_cocos/1.gif)

