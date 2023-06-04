---
title:  "ThreeBullets #8"
excerpt: "cocos, myproject, threebullets, boundingbox"

categories:
  - ThreeBullets
tags:
  - [cocos, myproject, threebullets, boundingbox]

toc: true
toc_sticky: true
 
date: 2021-08-31 
last_modified_at: 2023-06-04
---  

***

### 충돌 처리  
적과 총알의 생성이 끝났고 이제 서로 충돌을 체크하고 경우를 나눠 결과를 도출한다.  

<br/>

```cpp
// GameScene.cpp
void GameScene::collisionProcess()
{
	bulletList = pBulletLayer->getBulletList();
	enemyList = pEnemy->getEnemyList();

	if (bulletList.empty() || enemyList.empty())
	{
		return;
	}

	for (int enemyCount = 0; enemyCount < enemyList.size(); enemyCount++)
	{
		enemyBox = enemyList.at(enemyCount)->getBoundingBox();

		for (int bulletCount = 0; bulletCount < bulletList.size(); bulletCount++)
		{
			bulletBox = bulletList.at(bulletCount)->getBoundingBox();

			if (enemyBox.intersectsRect(bulletBox))
			{
				int result = compareType(enemyList.at(enemyCount), bulletList.at(bulletCount));
				matchResult(result, enemyCount, bulletCount);
			}
		}
	}
}
```
* 적과 총알을 Vector에 담아서 저장했기 때문에 쉽게 관리할 수 있었다. 각 Vector를 검사해서 비어있지 않을 경우 충돌 판정을 진행한다.  
	적을 기준으로 총알을 비교하기로 했기 때문에 우선 반복문으로 enemy가 담긴 Vector를 순회하면서 이중 반복문으로 bullet의 Vector를 순회한다.  

* AABB방식 사용  
내가 사용하는 이미지는 모양이 단순하기 때문에 사각형을 씌워도 크게 문제되지 않기 때문에 이 방식을 사용하기로 한다.  
충돌 판정을 위해서 이미지의 크기에 맞춰 사각형을 만들어 주는 getBoundingBox함수를 사용한다.  

* 적과 총알에 씌워진 사각형의 충돌을 검사하는 intersectsRect함수를 사용해서 결과를 도출한다.  

<br/>

### 결과 도출
총알과 적의 상성관계에 따라 조건문으로 검사해 결과를 도출한다.  

```cpp
int GameScene::compareType(EnemySprite* _enemy, BulletSprite* _bullet)
{
	if (_enemy->getEnemyType() == EnemySprite::EType::kXEnemy)
	{
		if (_bullet->getBulletType() == BulletSprite::EType::kX)
		{
			// draw
			return 0;
		}

		else if (_bullet->getBulletType() == BulletSprite::EType::kC)
		{
			// win
			return 1;
		}

		else if (_bullet->getBulletType() == BulletSprite::EType::kS)
		{
			// lose
			return 2;
		}
		
		else
		{
			// error
			return 3;
		}
	}
	.
	.
	.
}
```

경우의 수가 많다보니 코드가 길어져서 각 기능별로 따로 함수화 시켰다.  
적과 총알의 타입을 비교해서 정수 값을 반환하는 함수이다. 반환 받은 정수 값은 실제 결과를 반영하는 함수에 사용한다.  

```cpp
void GameScene::matchResult(int _val, int _eCount, int _bCount)
{
	if (_val == EType::kDraw)
	{
		pBulletLayer->removeBullet(_bCount);
	}
	else if (_val == EType::kLose)
	{
		pBulletLayer->removeBullet(_bCount);
	}
	else if (_val == EType::kWin)
	{
		pEnemy->removeEnemy(_eCount);
		pBulletLayer->removeBullet(_bCount);
	}
	else
	{
		CCLOG("Error");
		return;
	}
}
```

실제로 결과를 반영하는 기능을 한다. 위에서 반환 받은 결과 값과 적, 총알 Vector의 인덱스를 매개변수로 가진다.  
결과 값에 따라서 무승부, 패배, 승리가 결정되고 각 결과에 따라서 총알과 적이 지워진다.  

<br/>

![play](/assets/images/posting/20210831/play_test.gif)

