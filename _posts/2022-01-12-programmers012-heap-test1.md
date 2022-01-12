---
title:  "[힙] 주식가격"
excerpt: "coding, test, programmers, stack"

categories: 
  - Programmers
tags:
  - [coding, test, programmers, stack]

toc: true
toc_sticky: true
 
date: 2022-01-12
last_modified_at: 2022-01-12
---  

***

### 문제

매운 것을 좋아하는 Leo는 모든 음식의 스코빌 지수를 K 이상으로 만들고 싶다. 모든 음식의 스코빌 지수를 K 이상으로 만들기 위해 Leo는 스코빌 지수가 가장 낮은 두 개의 음식을 아래와 같이 특별한 방법으로 섞어 새로운 음식을 만든다.

>섞은 음식의 스코빌 지수 = 가장 맵지 않은 음식의 스코빌 지수 + (두 번째로 맵지 않은 음식의 스코빌 지수 * 2)

Leo는 모든 음식의 스코빌 지수가 K 이상이 될 때까지 반복하여 섞는다.  
Leo가 가진 음식의 스코빌 지수를 담은 배열 scoville과 원하는 스코빌 지수 K가 주어질 때, 모든 음식의 스코빌 지수를 K 이상으로 만들기 위해 섞어야 하는 최소 횟수를 return 하도록 solution함수를 작성하여라.


<br>

### 제한사항

* scoville의 길이는 2 이상 10,000,000 이하이다.

* K는 0 이상 1,000,000,000 이하이다.

* scoville의 원소는 각각 0이상 1,000,000 이하이다.

* 모든 음식의 스코빌 지수를 K 이상으로 만들 수 없는 경우에는 -1을 return 한다.

<br>

### 나의 풀이

스코빌 지수를 담은 배열을 오름차순 정렬 시킨다.

0번째 인덱스부터 요소의 크기를 K와 비교한다. 

* K보다 클 때 다음 인덱스의 요소(두 번째로 작은 수)와 섞어준다.

* 위 결과가 K보다 크거나 같을 때 까지 반복한다.

* 모두 섞어도 기준에 못미치면 -1을 반환

* 가장 맵기가 낮은 음식이 기준보다 높다면 섞을 필요가 없다.

queue 라이브러리의 우선순위 큐를 사용한다.

```cpp
#include <string>
#include <vector>
#include <queue>

using namespace std;

int solution(vector<int> scoville, int K) {
	int answer = 0;
	// 우선순위 큐
	priority_queue<int, vector<int>, greater<int>> pq;

	// 큐에 음식 담기
	for (int e : scoville) {
		pq.push(e);
	}

	// 가장 맵지않은 음식이 기준보다 큰 경우는 동작X
	while (pq.top() < K) {
		// 음식을 섞기 위해서 최소 2개 이상의 음식이 있어야한다.
		if (pq.size() > 1) {
			// 가장 맵기가 낮은 음식
			int sumScoville = pq.top();
			pq.pop();
			// 두번째로 낮은 음식과 섞기
			sumScoville += (2 * pq.top());
			pq.pop();
			// 섞은 횟수 증가
			answer++;
			// 섞은 음식 큐에 저장
			pq.push(sumScoville);
		}
		// 음식이 하나 남음
		else {
			// 모든 음식을 섞어도 기준에 못미치는 경우
			if (pq.top() < K) {
				return -1;
			}
			// 기준 달성했다면 반복문 종료
			else {
				break;
			}
		}
	}

	return answer;
}
```