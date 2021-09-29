---
title:  "[자료구조]클래스로 큐, 스택 구현"
excerpt: "cpp, structure, linear, linked-list"

categories:
  - Cpp
tags:
  - [cpp, structure, linear, linked-list]

toc: true
toc_sticky: true
 
date: 2021-09-28
last_modified_at: 2021-09-28
---  

***

### 스택(stack)
```cpp
#include <iostream>

using namespace std;

class Node
{
public:
	int data;
	Node* next;

	Node(int _num, Node* _node) : data(_num), next(_node) {}
}

// 기준 헤드 노드
Node* head;
// 마지막 노드
Node* end;

// 항상 마지막에 추가
void Push(int _data)
{
	// 새로 동적할당하고 현재 마지막 노드의 다음 노드로 지정
	end->next = new Node(_data, NULL);
	// 마지막 노드를 다시 지정해준다.
	end = end->next;

}

// 항상 마지막을 삭제
void Pop()
{
	// 헤드 노드에서 시작
	Node* curr = head;
	Node* preCurr;

	// 노드가 NULL이 아닐 때 까지 반복
	while (curr != NULL)
	{
		// 마지막 노드일 때
		if (curr->next == NULL)
		{
			// 마지막 노드 지운다.
			delete curr;
			// 
			preCurr->next = NULL;
			break;
		}
		else
		{
			// 다음이 NULL인 노드가 될 때 까지 진행
			// 다음 노드가 NULL이 아니면 노드를 저장
			preCurr = curr;
			curr = curr->next;
		}

	}
}

// 노드 순회 출력
void Print(Node* _node)
{
	Node* curr = _node;

	while (curr->next != NULL)
	{
		printf("%d", curr->data);
		curr = curr->next;
	}
	printf("%d\n", curr->data);
}
```

마지막 노드를 지우기 위해서는 마지막 직전의 노드를 저장해 둘 필요가 있다. 따라서 preCurr에 curr->next가 NULL을 만난다면 해당 노드를 삭제하고 preCurr에 저장한 노드의 next를 NULL로 바꾸어 준다.

<br/>

### 큐(Queue)
한 쪽에서 삽입만 다른 쪽에서는 삭제만 이루어진다.
```cpp
#include <iostream>

using namespace std;

class Node
{
public:
	int data;
	Node* next;

	Node(int _num, Node* _node) : data(_num), next(_node) {}
};

// 기준 헤드 노드
Node* head;
// 마지막 노드
Node* back;

void Push(int _data)
{
	Node* curr = new Node(_data, NULL);
	Node* preCurr = head->next;

	if (curr == NULL)
	{
		return;
	}

	head->next = curr;
	curr->next = preCurr;
}

void Pop()
{
	Node* curr = head;
	Node* preCurr = head;

	while (curr != NULL)
	{
		if (curr->next == NULL)
		{
			delete curr;
			preCurr->next = NULL;
			break;
		}
		else
		{
			preCurr = curr;
			curr = curr->next;
		}
	}
}

void Print(Node* _node)
{
	Node* curr = _node;

	while (curr->next != NULL)
	{
		printf("%d ", curr->data);
		curr = curr->next;
	}

	printf("%d\n", curr->data);
}
```  