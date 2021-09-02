---
title:  "ThreeBullets #10"
excerpt: "cocos, myproject, threebullets, static, gameover"

categories:
  - ThreeBullets
tags:
  - [cocos, myproject, threebullets, static, gameover]

toc: true
toc_sticky: true
 
date: 2021-09-02 
last_modified_at: 2021-09-02
---  

***

### 진행도
배경화면이 눈이 아파서 수정을 했다. 이제 게임이라고 할 수 있는 시작, 플레이 그리고 끝이 완성됐다.  
적을 처치할 때 마다 점수를 얻고 목숨을 전부 잃으면 게임이 끝나게 된다.  

<br/>

### 라이프

목숨은 Label 클래스를 사용해서 문자를 출력시키기로 했다.

```cpp
	Size winSize = Director::getInstance()->getWinSize();
	float factorX = winSize.width / 360.0f;
	float factorY = winSize.height / 740.0f;

	lifeLabel = Label::createWithTTF("0", "fonts/arial.ttf", 20);
	lifeLabel->setAnchorPoint(Vec2::ZERO);
	lifeLabel->setPosition(visibleSize.width * 0.01f, visibleSize.height * 0.18f);
	lifeLabel->setTextColor(Color4B::WHITE);
	lifeLabel->setScaleX(factorX);
	lifeLabel->setScaleY(factorY);
```

label로 생성한 폰트에도 스케일 팩터가 적용되는지 몰라서 임의로 조절해주는 코드를 넣어준다. 폰트는 cocos2d 기본으로 깔려있는 폰트를 사용했다. 

```cpp
void BackgroundLayer::setLabelString(int _life)
{
	string strLife = StringUtils::format("LIFE : %d", _life);
	lifeLabel->setString(strLife);
}
```
외부에서 호출하여 사용하기 위해서 매개변수로 정수 life를 받는 함수를 만들어 사용한다.  

<br/>

### 점수  
플레이 중에 실시간으로 점수가 증가하는걸 확인할 수 있으며 게임오버화면에서 마지막 점수를 표시해주기 위해서 
점수만을 관리하는 하나의 클래스를 따로 생성하기로한다. 이 클래스는 static으로 선언해 값이 유지될 수 있도록 한다.  

```cpp
class ScoreManager
{
private:
	static int totalScore;
public:
	ScoreManager();
	static void setTotalScore(int _score);
	static int getTotalScore();
	static void addTotalScore(int _score);
};
```

게임씬에서 게임오버씬으로 넘어가도 값을 유지할 수 있는 변수를 만들기 위해서 사용했는데 더 좋은 방법이 있는지 찾아봐야할 부분이다. 

<br/>

### 게임오버  
게임씬에서 life를 확인해서 0이 될 때 씬 전환이 호출된다. 게임오버씬은 ScoreManager에서 점수를 받아와서 표시하고 
다시하기와 종료 버튼이 있다. 다시하기는 GameScene을 호출하기 때문에 GameScene에서 값을 초기화 할 때 신경써야한다.  

<br/>

![play](/assets/images/20210902_Posting_cocos/1.gif)


게임을 동작시키기 위해서 코드를 연결시키다 보니 전체적으로 지저분해진 느낌이 든다. 정리를 한번 해야되겠다.  
