---
title:  "ThreeBullets #7"
excerpt: "cocos, myproject, threebullets, enemy"

categories:
  - ThreeBullets
tags:
  - [cocos, myproject, threebullets, enemy]

toc: true
toc_sticky: true
 
date: 2021-08-30 
last_modified_at: 2021-08-30
---  

***

### 적 생성
총알이 생성되는 것과 비슷한 구조이다. 적의 경우 게임이 시작되는 순간부터 
끝날 때 까지 생성되며 위치와 종류를 무작위로 해준다.

* 이미지 생성  

```cpp
// EnemySprite.cpp
bool EnemySprite::init(EType _type, float _speed, Vec2 _dir)
{
	if (!Sprite::initWithFile(fileName[_type]))
	{
		return false;
	}

	moveSpeed = _speed;
	moveDir = _dir;
	enemyType = _type;
	this->setScale(0.4f);

	this->scheduleUpdate();

	return true;
}

void EnemySprite::update(float _dt)
{
	enemyDeadline(_dt);
}

void EnemySprite::enemyDeadline(float _dt)
{
	if (isEnemyDead)
	{
		return;
	}

	Vec2 enemyPos = this->getPosition();
	Vec2 newPos = enemyPos;
	
	newPos += moveSpeed * moveDir * _dt;
	this->setPosition(newPos);

	if (this->getPosition().y < 0)
	{
		isEnemyDead = true;
	}
}
```  

외부에서 init함수를 호출하면서 매개변수를 받아서 그 정보로 적이 설정되고 생성되는 동시에 업데이트를 통해서 위에서 아래로 이동하게 된다. 

<br/>

적이 생성될 때 위치와 타입에 대한 정보가 필요하다.

* 적의 타입을 랜덤하게 설정  
적의 종류는 3가지이다. 

```cpp
// EnemyLayer.cpp
void EnemyLayer::setEnemyType()
{
	int randType = rand() % 3 + 1;

	if (randType == 1)
	{
		enemyType = EnemySprite::EType::kXEnemy;
	}
	.
	.
	.
}
```
* 적이 생성되는 위치 랜덤  
화면을 5등분해서 각 라인의 중간이 적이 생성될 위치이다.  

```cpp
// EnemyLayer.cpp
void EnemyLayer::enemySpawn(float _dt)
{
	setEnemyType();
	initEnemy();

	int randLane = rand() % 5;
	
	switch(randLane)
	{
		case 0:
			pEnemySprite->setPosition(refLane + (laneInterval * randLane));
			enemyList.pushBack(pEnemySprite);
			this->addChild(pEnemySprite);
			break;
	.
	.
	.
	}
}
```

* 생성된 적 관리  
적 또한 Vector에 저장해서 일괄적으로 관리할 수 있도록 만든다.  

```cpp
void EnemyLayer::removeEnemy()
{
	for (int i = 0; i < enemyList.size(); i++)
	{
		if (enemyList.at(i)->isDead())
		{
			this->removeChild(enemyList.at(i));
			enemyList.erase(i);
		}
	}
}
```

![play](/assets/images/20210830_Posting_cocos/1.gif)

* 일정 간격으로 적을 생성하는 방법  
특정 동작을 간격을 두고 반복하기 위해서 CC_SCHEDULE_SELECTOR를 활용한다.  

```cpp
this->schedule(CC_SCHEDULE_SELECTOR(EnemyLayer::enemySpawn), 0.8f, CC_REPEAT_FOREVER, 0);
```

CC_SCHEDULE_SELECTOR(반복하려는 함수, 동작 간격, 언제까지 반복할건지, 딜레이)  



<br/>

이제 총알과 적의 충돌 판정만 해주면 게임의 전반적 기능은 끝이난다.  
