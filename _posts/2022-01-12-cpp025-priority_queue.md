---
title:  "우선순위 큐"
excerpt: "cpp, algorithm, queue"

categories:
  - Cpp
tags:
  - [cpp, algorithm, queue]

toc: true
toc_sticky: true
 
date: 2022-01-12
last_modified_at: 2022-01-12
---  

***

### 큐 라이브러리

```cpp
#include <queue>
```

우선순위 큐는 queue의 한 종류이다.  

<br>

#### 선언

```cpp
// 선언한 자료형 변수들을 비교함수에 따라 정렬한다. 
priority_queue<자료형, Container, 비교함수> 변수명

// 선언한 자료형 변수들을 내림차순에 따라 정렬한다. 
priority_queue<자료형> 변수명

// 예)
// int형 변수들을 cmp 우선순위에 따라 정렬하는 q라는 이름의 Priority_queue 선언
priority_queue<int, vector<int>, cmp> q

// 함수
// 데이터 삽입
q.push(data);
// 맨앞에 있는 원소를 반환
q.top();
// 비어있으면 true, 아니면 false 반환
q.empty();
// 크기를 반환
q.size();
```

priority_queue는 기본적으로 내림차순으로 데이터가 정렬된다. 

<br>

#### 예제

* 내림차순

	```cpp
	#include<iostream>
	#include<queue>

	using namespace std;

	int main() {
		priority_queue<int> q;
		q.push(3);
		q.push(1);
		q.push(2);
		for(int i = 0; i < 3; i++) {
			cout << q.top() << " ";
			q.pop();
		}
	}
	```

	```
	출력
	3 2 1
	```

* 오름차순

	```cpp
	#include<iostream>
	#include<queue>

	using namespace std;

	int main() {
		priority_queue<int, vector<int>, greater<int>> q;
		q.push(3);
		q.push(1);
		q.push(2);
		for(int i = 0; i < 3; i++) {
			cout << q.top() << " ";
			q.pop();
		}
	}
	```

	```
	출력
	1 2 3
	```

	비교함수 greater\<type\>을 사용하면 오름차순으로 정렬할 수 있다.  

비교함수는 연산자 오버로딩을 통해 원하는 우선순위대로 구현할 수 있다.  

* 오버로딩

	```cpp
	#include<iostream>
	#include<queue>

	using namespace std;

	// 구조체 오버로딩
	struct cmp {
		~
	};

	int main() {
		priority_queue<int, vector<int>, cmp> q;
	}
	```


