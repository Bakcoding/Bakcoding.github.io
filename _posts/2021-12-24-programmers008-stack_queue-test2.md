---
title:  "[큐] 프린터"
excerpt: "coding, test, programmers, queue"

categories: 
  - Programmers
tags:
  - [coding, test, programmers, queue]

toc: true
toc_sticky: true
 
date: 2021-12-24 
last_modified_at: 2021-12-24
---  

***

### 문제

일반적인 프린터는 인쇄 요청이 들어온 순서대로 인쇄한다. 그렇기 때문에 중요한 문서가 나중에 인쇄될 수 있다. 이런 무제를 보완하기 위해 중요도가 높은 문서를 먼저 인쇄하는 프린터를 개발했다.  

이 새롭게 개발한 프린터는 아래와 같은 방식으로 인쇄 작업을 수행한다. 

1. 인쇄 대기목록의 가장 앞에 있는 문서(J)를 대기목록에서 꺼낸다.

2. 나머지 인쇄 대기목록에서 J보다 중요도가 높은 문서가 한 개라도 존재하면 J를 대기목록의 가장 마지막에 넣는다.

3. 그렇지 않으면 J를 인쇄한다.

<br>

### 제한사항

* 현재 대기목록에는 1개 이상 100개 이하의 문서가 있다.

* 인쇄 작업의 중요도는 1~9로 표현하며 숫자가 클수록 중요하다.

* location은 0이상 (현재 대기목록에 있는 작업 수 - 1) 이하의 값을 가지며 대기목록의 가장 앞에 있으면 0, 두 번째에 있으면 1로 표현한다.

<br>

### 나의 풀이

컨테이너를 큐만 사용해서 풀기 위해 여러개를 사용했다. location을 pair로 우선도와 같이 나중에 key값으로 사용해서 답을 구했다. 

```c++
#include <string>
#include <vector>
#include <queue>
#include <algorithm>

using namespace std;

// 우선 순위 내림차순 정렬
bool SortSecCol(const int& v1, const int& v2)
{
	return v1 > v2;
}

int solution(vector<int> priorities, int location) {
	int answer = 0;
	// 큐에 데이터 넣어서 관리
	// 우선순위, 키 값 같이 저장
	queue<pair<int, int>> docs;
	// 우선 순위로 정렬된 큐
	queue<int> sorted;
	// 프린트 순서 큐
	queue<pair<int, int>> print;
	int key = 0;
	int idx = 0;
	int length = priorities.size();

	// key == location
	// 내 문서 찾기위해 키값할당
	for (int e : priorities) {
		docs.push(make_pair(e, key));
		key++;
	}

	// 우선 순위 정렬 시키고 큐에 담기
	sort(priorities.begin(), priorities.end(), &SortSecCol);
	for (int i = 0; i < length; i++) {
		sorted.push(priorities[i]);
	}



	// 중요도 비교, 우선 순위 높은게 젤 앞에 오게되면 인쇄, 목록에서 제거
	// 다음 중요도 비교
	while (!sorted.empty()) {
		if (docs.front().first < sorted.front()) {
			docs.push(docs.front());
			docs.pop();
		}
		else {
			print.push(docs.front());
			docs.pop();
			sorted.pop();
		}
	}

	// location 찾기
	for (int k = 0; k < length; k++) {
		// front에 저장된 second가 key값
		if (print.front().second == location) {
			// 즉시 함수가 종료되기 때문에 k값이 증가되지않고 끝난다. 그렇기 때문에 + 1
			answer = k + 1;
			break;
		}
		else {
			print.pop();
		}
	}
	
	return answer;
}
```

이번에는 어렵지않게 풀었다. 우선순위를 정렬해서 큐와 비교해 다시 큐를 정렬한것을 저장하여 최종 출력 순서를 구한 뒤, 같이 저장한 key 값으로 내 문서를 찾아냈다.

<br>

### 다른 풀이

```c++
#include <string>
#include <vector>
#include <queue>
#include <algorithm>

using namespace std;

int solution(vector<int> priorities, int location) {
    queue<int> printer;                         //queue에 index 삽입.
    vector<int> sorted;                         //정렬된 결과 저장용
    for(int i=0; i<priorities.size(); i++) {
        printer.push(i);
    }
    while(!printer.empty()) {
        int now_index = printer.front();
        printer.pop();
        if(priorities[now_index] != *max_element(priorities.begin(),priorities.end())) {
            //아닌경우 push
            printer.push(now_index);
        } else {
            //맞는경우
            sorted.push_back(now_index);
            priorities[now_index] = 0;
        }
    }
    for(int i=0; i<sorted.size(); i++) {
        if(sorted[i] == location) return i+1;
    }
}
```

내가 푼 방법과 큰 흐름은 같지만 불필요한 과정을 최대한 줄여서 단축시켜 놓았다. 큐를 활용하는 문제라고 큐만 사용하려다보니 오히려 코드가 더 길어진듯하다. 