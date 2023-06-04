---
title:  "[자료구조] 큐"
excerpt: "cpp, structure, linear, queue"

categories:
  - Cpp
tags:
  - [cpp, structure, linear, queue]

toc: true
toc_sticky: true
 
date: 2021-09-27
last_modified_at: 2023-06-04
---  

***

### 큐(queue)
스택처럼 선형의 자료구조로 동일하게 push와 pop으로 삽입, 삭제가 가능하다. 

스택과 차이점은 큐는 front와 back 두 개의 포인터를 가지고 있으며 한쪽으로는 삽입만 한쪽으로는 삭제만 이루어지기 때문에 먼저 넣은 것이 먼저 나오는 선입선출로 동작한다.

![queue](/assets/images/posting/20210927/queue.png) 

C++ 에서는 \<queue\> 헤더 파일을 추가하면 queue 함수를 사용할 수 있다. 

```cpp
#include <queue>

int main()
{
  std::queue<int> s;
  s.push(10);
  s.pop();

  return 0;
}
```

<br/>

### 함수 구현  
queue 함수가 동작하는 방식을 구현해본다.  
크기가 정해진 배열을 사용하여 구현할 것이기 때문에 데이터를 저장하는 가장 뒤의 위치와 삭제하는 가장 앞의 위치가 수시로 변한다는 점을 유의해야한다.  

1. 배열을 선언한다.  
2. push함수로 데이터를 배열의 가장 뒤에 삽입한다. 
3. pop함수로 배열의 가장 앞의 데이터를 삭제한다. 
4. 배열이 비어있거나 크기를 벗어나면 경고 메시지를 띄운다.  

```cpp
#include <stdio.h>

int queue[10];
int length = sizeof(queue) / sizeof(int);
int front, back = 0;
bool isEmpty = true;
bool reversal;

bool CheckIndex()
{
	if (back > length - 1)
	{
		back = 0;
	}

	if (front > length - 1)
	{
		front = 0;
	}

	if (front == back)
	{
		return true;
	}

	return false;
}

void Push(int* _arr, int _num)
{
	if (!CheckIndex() || isEmpty)
	{
		_arr[back] = _num;
		printf("front = %d, back = %d\n", front, back);
		back++;
		isEmpty = false;
	}

	else
	{
		printf("Queue is Full\n");
	}
}

void Pop(int* _arr)
{
	if (!CheckIndex() || !isEmpty)
	{
		_arr[front] = 0;
		printf("front = %d, back = %d\n", front, back);
		front++;

		if (CheckIndex())
		{
			printf("Queue is Empty\n");
			isEmpty = true;
		}
	}
}

void Print(int* _arr)
{
	int start = front; 
	int end = back;

	// 시작과 끝이 같고 비어있지 않을 때, 한바퀴 돈 상태
	if (front == back && !isEmpty)
	{
		reversal = false;
		start = 0;
		end = length;
	}
	else if (front > back)
	{
		reversal = true;
		end = front;
		start = back;
	}

	// 한바퀴 돌기전과 돈 후 출력다르게
	if (!reversal)
	{
		for (int i = start; i < end; i++)
		{
			printf("%d ", _arr[i]);
		}
		printf("\n");
	}

	else
	{
		for (int i = 0; i < start; i++)
		{
			printf("%d ", _arr[i]);
		}

		for (int j = end; j < length; j++)
		{
			printf("%d ", _arr[j]);
		}
		printf("\n");
	}
}
```

아무래도 배열은 크기가 가변적이지 않고 정해진 크기이다 보니 구현한게 실제 동작과는 차이가 많이 날것같다.  