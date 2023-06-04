---
title:  "[스택] 주식가격"
excerpt: "coding, test, programmers, stack"

categories: 
  - Programmers
tags:
  - [coding, test, programmers, stack]

toc: true
toc_sticky: true
 
date: 2022-01-10
last_modified_at: 2023-06-05
---  

***

### 문제

초 단위로 기록된 주식가격이 담긴 배열 prices가 매개변수로 주어질 때, 가격이 떨어지지 않은 기간은 몇 초이지를 return 하도록 solution 함수를 완성해라

<br>

### 제한사항

* prices의 각 가격은 1 이상 10,000 이하인 자연수이다.

* prices의 길이는 2 이상 100,000 이하이다.

<br>

### 나의 풀이

풀이1)

입력 받은 배열의 요소를 다음 인덱스와 크기를 비교한다.  

* 반복문으로 모든 인덱스를 순회하며 비교한다.

* 현재 인덱스 요소 크기가 다음 인덱스 요소의 크기보도 크다면 감소하게 된 경우

조건만 봤을 때 이중 반복문으로 처리하는 방법이 먼저 떠올랐다.  

```cpp
#include <string>
#include <vector>

using namespace std;

vector<int> solution(vector<int> prices) {
	vector<int> answer;

	for (int i = 0; i < prices.size(); i++) {
		int sec = 0;
		for (int j = i + 1; j < prices.size(); j++) {
			// 시간 증가
			sec++;
			// 가격이 떨이진 경우
			if (prices[i] > prices[j]) {
				// 더 이상 가격비교 필요 없음
				break;
			}
		}
		// 시간 저장
		answer.push_back(sec);
	}

	return answer;
}
```

<br>
<img src="/assets/images/posting/20220110/result1.png" title="result1" width="300px">
<br>

테스트는 통과했지만 스택이나 큐를 사용하지 않았고 아무래 이번 테스트에서 효율성 테스트가 있기 때문에 비용이 좋지않은 이중 반복문을 사용하지 않는 방법이 필요하다.  

<br>

풀이2)

가격이 감소하는 시점의 인덱스의 차가 시간이 된다. 2번 인덱스의 값이 바로 다음 인덱스에서 감소하면 3 - 2의 결과인 1이 구하려는 시간이된다.  

* 값이 변동하는 인덱스를 저장하기 위한 컨테이너를 정한다. 

  저장한 마지막 값을 사용하기 위해서 stack을 사용하여 top으로 접근한다.

```cpp
#include <string>
#include <vector>
#include <stack>

using namespace std;

vector<int> solution(vector<int> prices) {
	int length = prices.size();
	// answer 를 미리 prices 길이만큼 초기화
	vector<int> answer(length);
	// 다음 값과 비교위해 top 사용
	stack<int> s;
	queue<int> q;

	// prices 값이 감소하는 인덱스 파악
	for (int i = 0; i < length; i++) {
		// 스택이 비어있지 않고 현재 값이 앞의 값보다 작으면
		// while 처음 값의 변동이 생긴 시점을 기준으로 그 앞의 시간들이 결정됨
		while (!s.empty() && prices[i] < prices[s.top()]) {
			// 값의 변동이 생긴 경우, 인덱스 차 (감소까지 걸린시간) 을 저장
			answer[s.top()] = i - s.top();
			// 값의 변동이 생긴 인덱스 정보는 제
			s.pop();
		}
		// 현재 인덱스 저장
		s.push(i);
	}

	// 변동이 없는 경우
	while (!s.empty()) {
		// 해당 인덱스 부터 끝까지가 걸린 시간이 된다.
		// 자신의 인덱스 제외 -1
		answer[s.top()] = length - s.top() - 1;
		// 다음 인덱스 진행
		s.pop();
	}

	return answer;
}
```

크게 값의 변동이 발생하는 경우와 아닌 경우를 나눈다. 

값의 변동이 생기는 시점을 발견하면 그 뒤의 변동이 없던 값들도 시간이 결정되게 된다.  

그리고 스택에는 값의 변동이 없던 인덱스만 남게되고 그 값들은 해당 인덱스부터 끝까지 진행되는데 걸리는 시간이다.

<br>
<img src="/assets/images/posting/20220110/result2.png" title="result2" width="300px">
<br>

for문을 통해 전체를 조회면서 검사하는 방법보다. 더 빠르다는걸 확인할 수 있다.

