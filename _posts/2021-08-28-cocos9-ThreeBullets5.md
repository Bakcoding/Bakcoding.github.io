---
title:  "ThreeBullets #5"
excerpt: "cocos, myproject, threebullets, update, init"

categories:
  - ThreeBullets
tags:
  - [cocos, myproject, threebullets, update, init]

toc: true
toc_sticky: true
 
date: 2021-08-28 
last_modified_at: 2021-08-28
---  

***

### 재정비
기능을 추가할 때 마다 전체 코드를 정비하고 있다.  
이번엔 총알을 발사하는 기능을 추가하면서 전체적으로 코드를 수정했다.  

버튼을 만들기 위해서 만들었던 클래스를 정돈했다.
```cpp
// CreateButton.cpp
bool CreateButton::init(const string _file[], Widget::TextureResType _type)
{
	if (!Button::init(_file[0],	_file[1], _file[2], _type))
	{
		return false;
	}

	fileName[0] = _file[0];
	fileName[1] = _file[1];
	fileName[2] = _file[2];
	type = _type;

	return true;
}

void CreateButton::alignmentHorizontal(Button* _target, float _padding)
{
	Vec2 targetPos = _target->getPosition();
	Vec2 newPos = Vec2(targetPos.x + _padding, targetPos.y);
	this->setPosition(newPos);
}

void CreateButton::alignmentVertical(Button* _target, float _padding)
{
	Vec2 targetPos = _target->getPosition();
	Vec2 newPos = Vec2(targetPos.x, targetPos.y - _padding);
	this->setPosition(newPos);
}
```

Button의 init함수 중에서 매개변수를 받는걸 찾았고 그 함수를 오버라이딩해서 사용했다.  
Button::init으로 초기화와 예외처리를 할 수 있다.
 
<br/>

플레이어 스프라이트 출력코드 수정
```cpp
//PlayerSprite.cpp
bool PlayerSprite::init(const char* _fileName, Vec2 _pos)
{
	if (!Sprite::initWithFile(_fileName))
	{
		return false;
	}

	playerPos = _pos;

	return true;
}

void PlayerSprite::moveLeft()
{
	Vec2 newPos = this->getPosition();
	newPos -= Vec2(visibleSize.width * 0.2f, 0);
	this->setPosition(newPos);
}

void PlayerSprite::moveRight()
{
	Vec2 newPos = this->getPosition();
	newPos += Vec2(visibleSize.width * 0.2f, 0);
	this->setPosition(newPos);
}
```
버튼과 마찬가지로 init으로 초기화와 예외처리 한다. 플레이어 스프라이트를 움직일 함수를 만들었다.

<br/>

### 총알 구현
버튼입력을 받아서 총알을 쏘는걸 구현한다.  
```cpp
// BulletSprite.cpp
bool BulletSprite::init(EType _type, Vec2 _dir, float _speed)
{
	if (!Sprite::initWithFile(bulletFileName[_type]))
	{
		return false;
	}

	moveDir = _dir;
	moveSpeed = _speed;
	eType = _type;

	this->scheduleUpdate();
	
	return true;
}

void BulletSprite::update(float _dt)
{
	if (isBulletDead)
	{
		return;
	}

	Size visibleSize = Director::getInstance()->getVisibleSize();
	Vec2 newPos = this->getPosition();
	newPos += moveSpeed * moveDir * _dt;
	this->setPosition(newPos);
	newPos = this->getPosition();

	if (newPos.y > visibleSize.height)
	{
		isBulletDead = true;
	}
}
```

총알이 생성되면 바로 위로 이동하게 만든다. bool을 사용해서 우선 총알이 화면 끝에 도달하면 멈추도록한다. 
이후 작업에서 총알을 처리하는 방식을 추가할 예정이다.  

코드가 너무 방대하지 않도록 가능한 기능별로 클래스를 구분해서 만들기로 한다.

```cpp
// BulletLayer.cpp
bool BulletLayer::initButton()
{
	Vec2 xPos = Vec2(visibleSize.width * 0.6225f, visibleSize.height * 0.0575f);

	xButton = CreateButton::create();

	if (xButton == nullptr || !xButton->init(strXButton, Widget::TextureResType::LOCAL))
	{
		return false;
	}

	xButton->addTouchEventListener(CC_CALLBACK_2(BulletLayer::touchXButton, this));
	
	xButton->setPosition(xPos);

	this->addChild(xButton);
}

void BulletLayer::touchXButton(Ref* _sender, Widget::TouchEventType _type)
{
	switch(_type)
	{
	case Widget::TouchEventType::BEGAN:
		bullet = shootBullet(BulletSprite::EType::kX);
		this->addChild(bullet);
		break;
	case Widget::TouchEventType::ENDED:
		break;
	default:
		break;
	}
}

BulletSprite* BulletLayer::shootBullet(BulletSprite::EType _type)
{
	bullet = BulletSprite::create();
	bullet->init(_type, moveDir, moveSpeed);
	bullet->setPosition(playerPos);

	return bullet;
}

void BulletLayer::setBulletPos(Vec2 _pos)
{
	playerPos = _pos;
}
```
이 클래스에서 총알을 발사하기 위한 버튼과 총알을 발사하는 기능을 구현한다.  
총알이 발사되는 위치는 플레이어의 위치와 같아야하는데 이 부분에서 잠시 헤맸다.  
결국 PlayerLayer에서 BulletLayer를 생성했다. 생성된 플레이어의 위치를 움직일 때 마다 받아와서 총알이 생성될 위치로 만들어 줄 방법이 딱히 떠오르지않아서 
update로 플레이어의 현재 위치를 받아서 발사위치를 갱신하기로 했다. 나중에 더 좋은 방법이 떠오르면 바꾸고 싶은 부분이다. 

[Classes](https://github.com/Bakcoding/ThreeBullets.git)

![play](/assets/images/20210828_Posting_cocos/1.gif)

수정할 부분) 플레이어 화면밖으로 이동안되게, 총알이 화면 끝 도달시 지우기



