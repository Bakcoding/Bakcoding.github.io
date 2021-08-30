---
title:  "ThreeBullets #6"
excerpt: "cocos, myproject, threebullets"

categories:
  - ThreeBullets
tags:
  - [cocos, myproject, threebullets]

toc: true
toc_sticky: true
 
date: 2021-08-29 
last_modified_at: 2021-08-29
---  

***

### 플레이어 이동제한  
플레이어가 화면 밖으로 이동하지 못하게 막는다.

```cpp
// PlayerSprite.cpp
void PlayerSprite::moveLeft()
{
	if (this->getPosition().x > visibleSize.width * 0.2f)
	{
		Vec2 newPos = this->getPosition();
		newPos -= Vec2(visibleSize.width * 0.2f, 0);
		this->setPosition(newPos);
	}
}

void PlayerSprite::moveRight()
{
	if (this->getPosition().x < visibleSize.width * 0.8f)
	{
		Vec2 newPos = this->getPosition();
		newPos += Vec2(visibleSize.width * 0.2f, 0);
		this->setPosition(newPos);
	}
}
```

이동하는 함수부분에서 조건문 추가, 양 끝에 도달한 경우 그 방향으로 더 못 이동하게 막는다.  

<br/>

### 총알 관리하기  
발사한 총알을 일괄적으로 관리하기 위해서 vector에 저장한다. vector도 cocos에서 제공하는 Vector가 있으니 사용해본다.  

```cpp
// BulletLayer.cpp
void BulletLayer::touchXButton(Ref* _sender, Widget::TouchEventType _type)
{
	switch(_type)
	{
	case Widget::TouchEventType::BEGAN:
		bullet = shootBullet(BulletSprite::EType::kX);
		bulletList.pushBack(bullet);
		this->addChild(bullet);
		break;
	case Widget::TouchEventType::ENDED:
		break;
	default:
		break;
	}
}
```

총알을 발사하면서 생성된 객체를 Vector에 담아준다. 이렇게 저장한 총알 데이터를 업데이트로 관리한다.

```cpp
BulletLayer.cpp
void BulletLayer::bulletProcess()
{
	for (int i = 0; i < bulletList.size(); i++)
	{
		if (bulletList.at(i)->isDead())
		{
			this->removeChild(bulletList.at(i));
			bulletList.erase(i);
		}
	}
}
```

BulletSprite에서 화면밖으로 나가는걸 확인하는 bool값을 이용해서 나간경우 제거를 해준다. 이 때 removeChild를 먼저해주어야 에러가 발생하지 않는다.  


<br/>

![play](/assets/images/20210829_Posting-cocos/1.git)

