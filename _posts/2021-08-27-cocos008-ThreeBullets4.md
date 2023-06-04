---
title:  "ThreeBullets #4"
excerpt: "cocos, myproject, threebullets, button"

categories:
  - ThreeBullets
tags:
  - [cocos, myproject, threebullets, button]

toc: true
toc_sticky: true
 
date: 2021-08-27 
last_modified_at: 2023-06-04
---  

***

### 재정비
클래스 분류를 다시해서 코드를 쓴다.  
파일 분류는 크게 씬으로 분류하고 거기에 사용할 클래스들은 크게 레이어로 나누어서 담는다.

현재 타이틀 씬에서 게임씬으로 넘어가고 플레이어를 움직이는 동작까지 구현되었다.

[Classes](https://github.com/Bakcoding/ThreeBullets/tree/main/Classes)

<br/>

### ui::Button  
터치나 클릭의 입력을 처리하기 위해서 Button 클래스를 활용한다.  
버튼을 사용하기 위해서는 ui/CocosGUI.h 헤더파일이 필요하며 Button은 ui네임스페이스에 있다.
Button은 함수를 콜백할 때 매개변수로 sender와 type을 받는다.
Button 튜토리얼

```cpp
auto button = Button::create("normal_image.png", "selected_image.png", "disabled_image.png");

button->setTitleText("Button Text");

button->addTouchEventListener([&](Ref* sender, Widget::TouchEventType type){
        switch (type)
        {
                case ui::Widget::TouchEventType::BEGAN:
                        break;
                case ui::Widget::TouchEventType::ENDED:
                        std::cout << "Button 1 clicked" << std::endl;
                        break;
                default:
                        break;
        }
});

this->addChild(button);
```

<br/>

### Button 클래스 상속  
Button을 편하게 만들어서 사용하기 위해서 기존의 버튼을 상속한 클래스를 만든다.

```cpp
// CreateButton.h
#ifndef _CREATE_BUTTON_H_
#define _CREATE_BUTTON_H_
#include "cocos2d.h"
#include "ui/CocosGUI.h"
USING_NS_CC;
using namespace std;
using namespace ui;

class CreateButton : public Button
{
private:
	//Button* button;
public:
	CreateButton();
	CREATE_FUNC(CreateButton);
	bool init();
	bool init(string _file[], Widget::ccWidgetTouchCallback _callback, Vec2 _pos);

	void alignmentHorizontal(Button* _target, float _padding);
	void alignmentVertical(Button* _target, float _padding);
};

#endif
```

```cpp
#include "CreateButton.h"

CreateButton::CreateButton() /*: button(NULL)*/ {}

bool CreateButton::init()
{
	if (!Button::init())
	{
		return false;
	}

	return true;
}

bool CreateButton::init(string _file[], Widget::ccWidgetTouchCallback _callback, Vec2 _pos)
{
	if (!Button::init())
	{
		return false;
	}

	Button* button = Button::create(
		_file[0], _file[1], _file[2]
	);

	button->setPosition(_pos);
	button->addTouchEventListener(_callback);

	this->addChild(button);

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

타이틀씬의 메뉴나 게임씬의 조작키에서 활용을 할 생각이다.

![play_test](/assets/images/posting/20210827/play_test.gif)




