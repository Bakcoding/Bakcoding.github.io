---
title:  "스레드"
excerpt: "cpp, algorithm, thread"

categories:
  - Cpp
tags:
  - [cpp, algorithm, thread]

toc: true
toc_sticky: true
 
date: 2021-10-03
last_modified_at: 2021-10-03
---  

***

### 스레드(thread)  
프로그램이 동시에 여러 작업을 진행하는 것처럼 동작하게 만드는 함수이다. 병렬식으로 보이지만 실제로는 특정 코드의 연산이 끝날 때까지 코드의 실행을 멈추지 않고 순차적으로 다음 코드를 실행한다.  

```cpp
#include <iostream>
#include <thread>
#include <Windows.h>

using namespace std;

void function1()
{
	for (int i = 0; i < 10; i++)
	{
		printf("thread 1 call %d\n", i);
		// 흐름을 파악하기 위한 딜레이
		Sleep(1000);
	}
}

void function2()
{
	for (int i = 0; i < 10; i++)
	{
		printf("thread 2 call %d\n", i);
		Sleep(1000);
	}
}

void function3()
{
	while(1)
	{
		printf("thread 3 call\n");
		Sleep(1000);
	}
}

int main()
{
	thread t1(function1);
	thread t2(function2);
	thread t3(function3);

	t1.join();
	t2.join();
	t3.join();
	
	return 0;
}
```
실행해보면 function 1, 2, 3이 동시에 출력되는게 보인다. 실제로는 동시가 아닌 순차적으로 진행되는 것이고 일반 함수라면 절차지향에 따라서 작성한 순서로 출력되겠지만 불규칙한 순서로 함수가 출력되는걸 볼 수 있다.  

스레드는 함수가 종료되기 전에 다음 함수로 넘어가는 방식이라 메인함수에서 스레드 함수를 다 끝내기 전에 return 코드를 읽게되면 프로세스가 종료됐는데도 끝나지 않은 함수가 남게되어 오류가 발생하기도 한다.  

join() 함수는 스레드 함수가 종료될 때 까지 프로세스가 종료되지 않도록해준다.  
