---
title:  "야구게임"
excerpt: "c, baseball, rand, srand, game"

categories:
  - C
tags:
  - [c, baseball, rand, srand, game]

toc: true
toc_sticky: true
 
date: 2021-08-13
last_modified_at: 2021-08-13
---  

***
<br/>

### 야구게임 만들기
학창시절 노트에 임의로 숫자를 적고 그 숫자를 맞추는 게임을 해본적이 있을 것이다. 친구와 했던 게임을 컴퓨터를 상대로 즐겨보기로 한다.

<br/>

1. 컴퓨터는 중복되지 않는 무작위 숫자 3개를 생성한다. ( 1 ~ 9 )
2. 숫자만 맞추면 볼, 숫자와 위치를 맞추면 스트라이크로 힌트를 준다.
3. 5번의 기회안에 숫자를 맞추면 승리, 못 맞추면 패배한다.


```c
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int main()
{
	printf("**** 야구게임을 시작합니다! ****\n\n");
	printf("컴퓨터가 숫자를 정했습니다.\n");
	printf("숫자를 입력하세요.\n");

	int inputNum[3] = { 0 };
	int randNum[3] = { 0 };
	int overlap = 1;
	int isGameover = 1;
	int life = 5;

	srand(unsigned int(time(NULL)));

	while (overlap)
	{
		for (int i = 0; i < 3; i++)
		{
			randNum[i] = rand() % 9 + 1;
		}
		
		if (randNum[0] == randNum[1] || randNum[0] == randNum[2] || randNum[1] == randNum[2])
		{
			printf("숫자가 중복되어 다시 선택합니다.");
			overlap = 1;
		}
		else
		{
			overlap = 0;
		}
	}


	while (isGameover)
	{
		scanf_s("%d %d %d", &inputNum[0], &inputNum[1], &inputNum[2]);
		int ball = 0;
		int strike = 0;

		for (int i = 0; i < 3; i++)
		{
			for (int j = 0; j < 3; j++)
			{
				if (randNum[i] == inputNum[j])
				{
					if (i == j)
					{
						strike++;
					}
					else
					{
						ball++;
					}
				}
			}
		}

		if (strike == 3)
		{
			printf("정답입니다. 플레이어 승리!\n");
			isGameover = 0;
		}
		else
		{
			printf("%d 스트라이크, %d 볼\n", strike, ball);
			life--;
			printf("남은 기회 : %d\n\n", life);

			if (life <= 0)
			{
				printf("패배했습니다. 정답 : %d %d %d\n\n", randNum[0], randNum[1], randNum[2]);
				isGameover = 0;
			}
		}
	}
}
```



![baseball](/assets/images/20210813_Posting/baseball.gif)

숫자 중복을 방지하는 방법이 마음에 들지 않는다. 좀 더 깔끔하게 할 수 있는 방법이 없나 생각해봐야겠다.