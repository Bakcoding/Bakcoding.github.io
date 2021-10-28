---
title:  "[자료구조] 스택"
excerpt: "cpp, structure, linear, stack"

categories:
  - Cpp
tags:
  - [cpp, structure, linear, stack]

toc: true
toc_sticky: true
 
date: 2021-09-27
last_modified_at: 2021-09-27
---  

***

### 스택(stack)
뜻처럼 데이터를 차곡 차곡 쌓는 느낌이다.  
순차적으로 데이터를 저장하기 때문에 먼저 넣은것이 마지막에 나오고 마지막에 넣은것이 가장 먼저 나오는 후입선출 방식이다.  

![stack](/assets/images/20210927_Posting/3.png) 

C++ 에서는 \<stack\> 헤더 파일을 추가하면 stack 함수를 사용할 수 있다. 

```cpp
#include <stack>

int main()
{
  std::stack<int> s;
  s.push(10);
  s.pop();

  return 0;
}
```

<br/>

### 함수 구현  
stack 함수가 동작하는 방식을 구현해본다.  
1. 배열을 선언한다.  
2. push함수로 데이터를 순차적으로 삽입한다. 
3. pop함수로 마지막에 삽입한 데이터를 삭제한다. 
4. 배열이 비어있거나 크기를 벗어나면 경고 메시지를 띄운다.  

```cpp
#include <stdio.h>

int top = -1;
int stack[10] = { 0 };

bool FullStack();
bool EmptyStack();
void Push(int _num);
int Pop();
void Print();

int main()
{
	Push(10); Push(20); Push(30); Push(40);
	Print();

	Pop();
	Print();

	Pop(); Pop(); Pop(); Pop();

	return 0;
}

bool FullStack()
{
	if (top >= 9)
	{
		printf("Stack is Full\n");

		return true;
	}

	return false;
}

bool EmptyStack()
{
	if (top < 0)
	{
		printf("Stack is Empty\n");

		return true;
	}

	return false;
}

void Push(int _num)
{
	if (!FullStack())
	{
		top++;
		stack[top] = _num;
	}
}

int Pop()
{
	if (!EmptyStack())
	{
		int tmp = stack[top];
		top--;
		return tmp;
	}
	else
	{
		return 0;
	}
}

void Print()
{
	if (!EmptyStack())
	{
		for (int i = 0; i < top + 1; i++)
		{
			printf("index %d : %d\n", i, stack[i]);
		}
	}
}
```