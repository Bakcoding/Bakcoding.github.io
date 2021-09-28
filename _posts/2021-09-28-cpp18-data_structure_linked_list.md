---
title:  "[자료구조] 연결 리스트"
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

### 연결 리스트(linked-list)  
노드가 데이터와 포인터를 가지고 선형 구조로 데이터를 저장하는 자료구조로 노드의 포인터가 다음이나 이전의 노드와의 연결을 해주는 역할을 한다.  

배열과 달리 가변적인 구조로 삽입과 삭제가 효율적인 시간내에 가능하지만 포인터를 이용한 접근이기 때문에 검색은 오래걸린다는 단점도 갖고 있다.

<br/>

### 연결 리스트 구현  
연결리스트는 배열처럼 실제로 연속하는 메모리 구조가 아니고 각 각의 메모리들을 포인터를 통해 연결시킨 구조이다.  

* 구조체 선언  

	```cpp
	struct Node{
		struct Node *next;
		int data;
	}
	```

	* 노드는 구조체를 통해 변수와 다음 노드의 주소를 저장할 포인터를 선언한다. 
	* 다음 노드도 같은 구조체를 사용하기 때문에 struct Node의 포인터로 선언한다. 
	* 데이터를 저장할 변수는 임의로 int를 선언한다.


* head 노드 선언  
	기준이 되는 노드를 head 노드라고 한다.  
	다른 노드들을 생성하고 포인터를 통해 각 노드들의 주소를 저장해 연결시켜준다.  

	```cpp
	// head 노드
	struct Node* head = malloc(sizeof(struct Node));

	// 노드1
	struct Node* node1 = malloc(sizeof(struct Node));
	head->next = node1;		// 주소 저장
	node1->data = 10;		// 데이터 저장

	// 노드2
	struct Node* node2 = malloc(sizeof(struct Node));
	node1->next = node2;
	node2->data = 20;
	```


* 마지막 노드의 next 포인터는 NULL로 초기화해서 끝을 표시한다.  

	```cpp
	node2->next = NULL;
	```


* 순회용 Node를 선언하고 포인터에 첫 번째 노드의 주소를 저장한다.  
	
	만들어진 연결리스트가 연속적인 메모리상에 저장된 것처럼 접근할 수 있는지 반복문을 통해 접근해본다.  

	```cpp
	struct Node* curr = head->next;

	while (curr != NULL)
	{
		printf("%d\n", curr->data);
		// 계속해서 다음 주소를 가리키게 된다.
		curr = curr->next;
	}
	```

* 마지막엔 동적할당한 메모리는 해제해 준다.

	```cpp
	free(node2);
	free(node1);
	free(head);
	```

	해제할 때 앞의 노드를 먼저 삭제한다면 더 이상 뒤의 노드들은 접근할 수 없는 상태가 되어 에러를 발생시킬 수 있기 때문에 역순으로 해주어야한다.  

	만약 모든 노드를 일괄적으로 해제한다면 노드가 많을 경우 하나씩 해제해주는 일은 아주 번거로울 수 있는데 이 문제는 반복문으로 처리할 수 있다.  

	```cpp
	while (curr != NULL)
	{
		// 현재 노드를 해제하기 전에 다음 노드의 주소를 임시 저장
		struct Node* next = curr->next;
		// 현재 노드를 해제하고
		free(curr);
		// 다음 노드로 넘어간다.
		curr = next;
	}
	```

	현재 노드를 삭제하고 다음 노드로 넘어가는 작업을 반복한다. 

<br/>

### 노드 삽입
노드를 추가하는 방법은 next에 저장할 주소만 바꾸어주면 된다.  

이전 노드의 next에 새로생성한 노드의 주소를 넣어주고 새로생성한 노드의 next는 다음 노드의 주소를 저장해주면 된다.  

하지만 이처럼 반복해서 필요한 경우가 많은 작업은 함수로 만들어 주는게 좋다.  

```cpp
void addNode(struct Node* _target, int _data)
{
	// 대상 노드가 NULL인지부터 확인
	if (target == NULL)
	{
		return;
	}

	struct Node* newNode = malloc(sizeof(struct Node));

	// 동적할당 제대로 됐는지 확인
	if (newNode == NULL)
	{
		return;
	}

	// 새로 만든 노드의 다음 노드를 대상 노드의 다음 노드로 저장
	newNode->next = target->next;
	// 데이터 저장
	newNode->data = data;
	// 대상 노드의 다음 노드를 새 노드로 저장
	target->next = newNode;
}
```
중요한점은 매개변수로 받은 노드가 NULL인지 부터 확인하는 것이다. 만약 NULL이라면 더 이상 함수가 진행되지 않게 종료시켜주어야 하고 또 동적할당을 했을 때도 제대로 할당이 됐는지 검사를 해주도록한다.  

동적할당은 에러가나면 전체적으로 문제가 발생하기 때문에 이런 확인작업은 중요하다.


<br/>

### 노드 삭제
중간에 노드를 삭제한다면 삭제된 노드의 앞 뒤의 노드를 다시 연결해주는 작업을 해주어야한다.  

```cpp
// 삭제할 노드의 이전 노드를 매개변수로 받는다.
void removeNode(struct Node* _target)
{	
	if (target == NULL)
	{
		return;
	}
	// 삭제할 노드는 매개변수로 받은 노드의 다음 노드이다. 
	struct Node* remove = _target->next;
	
	if (newNode == NULL)
	{
		return;
	}

	// 매개변수 노드의 다음 노드를 삭제할 노드의 다음 노드로 이어준다. 삭제할 노드의 연결은 이제 끊기게 된다.  
	_target->next = remove->next;
	// 연결 끊긴 노드, 삭제된 노드를 해제
	free(remove);
}
```

삽입이나 삭제 비슷하게 동작한다.  

임시로 저장할 노드를 선언하여 값을 저장하고 이어주거나 끊어주는 방식이다.  



