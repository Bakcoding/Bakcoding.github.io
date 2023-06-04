---
title:  "ThreeBullets #11"
excerpt: "cocos, myproject, threebullets, hiteffect, onaction"

categories:
  - ThreeBullets
tags:
  - [cocos, myproject, threebullets, hiteffect, onaction]

toc: true
toc_sticky: true
 
date: 2021-09-02 
last_modified_at: 2023-06-04
---  

***

### 효과 추가  
허전한 느낌을 채우기 위해서 효과를 추가해준다.  
효과는 재미를 더 해주는 요소가 될 수 도 있고 시각적인 정보를 줄 수 도 있다.  

<br/>

### 피격효과  
피해를 받았을 때 플레이어가 알아채기 쉽도록 시각적인 정보를 준다. 플레이에 방해되지 않으면서 충분히 알 수 있는 위치와 색을 활용한다.  

하나의 생성된 이미지의 투명도를 조절하는 방식으로 재사용하기로 한다.  

```cpp
	hitEffect = Sprite::create(fileName);
	hitEffect->setAnchorPoint(Vec2::ZERO);
	hitEffect->setPosition(0, visibleSize.height * 0.21f);
	hitEffect->setOpacity(0);
	this->addChild(hitEffect);
```

이펙트로 사용할 이미지는 생성되자 마자 투명도를 0으로 해준다.  

```cpp
// EffectSprite.cpp
void EffectSprite::setOpacity()
{
	if (isHit)
	{
		hitEffect->setOpacity(255);
		isHit = false;
	}
}
```

bool 값으로 피격을 확인해서 피격을 당했다면 이미지가 보이도록한다.  

```cpp
void EffectSprite::effectProcess(float _dt)
{
	int opacity = hitEffect->getOpacity();
	
	if (opacity <= 0)
	{
		opacity = 0;
		return;
	}
	
	opacity -= destroySpeed * _dt;
	hitEffect->setOpacity(opacity);
}
```

이미지가 보였다면 다시 투명도를 서서히 줄여서 자연스럽게 사라지도록 한다.  

<br/>

### 적의 액션  
직선으로 심심하게 내려오는 적의 움직임에 액션을 주기로 한다.  
너무 과한 액션은 게임에 방해가 되기 때문에 단순한 동작만 하기로 한다.  

```cpp
// EnemySprite.cpp
void EnemySprite::OnAction()
{
	Action* rotate = RotateBy::create(3.0f, 500.0f);
	this->runAction(rotate);
}

```

회전 동작을 추가해주는 RotateBy를 사용한다. 이 동작을 세팅한 함수를 적이 생성되는 곳에서 호출해준다.  

![play](/assets/images/posting/20210902/play_test_2.gif)
  