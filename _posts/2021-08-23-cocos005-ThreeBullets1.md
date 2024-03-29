---
title:  "ThreeBullets #1"
excerpt: "cocos, myproject, threebullets, proposal"

categories:
  - ThreeBullets
tags:
  - [cocos, myproject, threebullets, proposal]

toc: true
toc_sticky: true
 
date: 2021-08-23  
last_modified_at: 2023-06-04
---  

***

### 게임 개발
Cocos를 다루는데 익숙해지기 위해서 간단한 게임을 개발해본다.  

공부를 목적으로 하지만 기획부터 출시까지를 목표로 한다.

<br/>

### 장르선택
고전 게임에 대해서 알아보던 중 히트를 쳤던 \<Missile Command\>와 \<Space Invaders\>를 보면서 직관적이면서 재미도 있고 개발 난이도 측면에서도 적당한 슈팅 장르의 게임을 만들기로 한다.  

|\<Missile Command\>|\<Space Invaders\>|
|:----:|:----:|
|![missile_command](/assets/images/posting/20210823/missile_command.png)|![space_invaders](/assets/images/posting/20210823/space_invaders.png)|

<br/>

### 콘셉트 기획
**개요**
***
세 가지 총알을 발사해 내려오는 적들을 제거하는 슈팅 게임  

게임 이름 : Three Bullets  

장  르 : 슈팅

플랫폼 : 아케이드, AOS  

개발환경 : cocos2d-x-4.o

등  급 : All

\<모바일로 구현했을 경우\>

![plan_game_play](/assets/images/posting/20210823/plan_game_play.png)

<br/>

***
**기획의도**  
* 슈팅게임  
  직관적이며 심플한 플레이방식으로 누구나 쉽게 접할 수 있다.  

* 하이스코어  
  성취감과 경쟁심은 플레이어가 다시 게임을 플레이하게 만드는 중요한 요소이다. 하이스코어는 그 욕구를 만족시켜주는 방법 중 하나이다.

* 상성관계  

  ![counter_system](/assets/images/posting/20210823/counter_system.png)  

  단조로울 수 있는 슈팅게임의 공격 방식에 플레이어로 하여금 판단의 여지를 주고 게임이 끝날 때 까지 몰입할 수 있게 만든다.  

  가위바위보와 같은 간단하고 직관적인 구조의 상성관계는 적을 처치해야하는 짧은 순간에도 충분히 판단이 가능하게 한다. 

<br/>

***
**게임진행**  
* 5개의 라인에서 3가지 종류의 적들이 무작위로 계속해서 내려온다.  

* 플레이어는 인접한 라인으로 칸칸이 움직이며 내려오는 적들의 종류에 따라서 상성의 총알을 발사해서 적을 제거한다.  

* 적을 제거하면 점수를 얻고 적이 바닥에 도달하면 목숨이 깎인다.  

* 상성규칙  
  적은 우위의 총알을 맞아야만 제거되며 같은 종류라면 아무일도 일어나지 않고 하위의 총알을 맞추면 목숨이 감소된다.  

* 높은 점수를 목표로 게임을 진행하며 목숨이 0이되면 게임이 종료된다.

<br/>

### 클래스 다이어그램
구체적인 설계는 못하겠지만 대략적으로 구조를 만들어 보면

![class_diagram](/assets/images/posting/20210823/class_diagram.png)

게임에 필요한 씬들은 하나의 매니저를 통해 관리한다. 게임씬에서 사용되는 클래스가 많을 것인데 크게 player, enemy, bullet으로 나누고 셋을 묶어서 게임매니저에서 관리한다. 게임오버씬에서 스코어를 표시하고 싶기 때문에 게임매니저에서 스코어를 스태틱으로 두고 정보를 가져다 쓸 수 있도록 해야겠다.

게임을 만들다보면 기획했던것에서 바뀌는 부분이 있겠지만 대략적인 그림을 그려놓으면 나중에 꼬이는 일을 줄일 수 있다.