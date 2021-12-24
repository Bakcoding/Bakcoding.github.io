---
title:  "[큐] 기능개발"
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

프로그래머스 팀은 기능 개선을 수행중이다. 각 기능은 진도가 100%일 때 서비스에 반영할 수 있다.  

또, 각 기능의 개발속도는 모두 다르기 때문에 뒤에 있는 기능이 앞에 있는 기능보다 먼저 개발될 수 있고, 이때 뒤에 있는 기능은 앞에 있는 기능이 배포될 때 함께 배포된다.  

<br>

### 제한사항

* 작업의 개수(progress, speeds 배열의 길이)는 100개 이하이다.

* 작업 진도는 100 미만의 자연수이다.

* 작업 속도는 100 이하이다.

* 배포는 하루에 한 번만 할 수 있으며, 하루의 끝에 이루어진다고 가정한다.  

    예를 들어 진도율이 95%인 작업의 개발 속도가 하루에 4%라면 배포는 2일 뒤에 이루어진다.

<br>

### 나의 풀이

모든 작업을 동시에 진행할 필요는 없다고 생각했다. 어차피 배포되는건 앞의 작업이 완료되어야 진행되기 때문에 앞의 요소들부터 작업이 완료되면 뒤의 작업도 검사하는 방식으로 풀었다. 


```c++
#include <string>
#include <vector>
#include <queue>

using namespace std;

vector<int> solution(vector<int> progresses, vector<int> speeds) {
	vector<int> answer;
	// 배열의 앞에있는 요소가 완료되어야 뒤에도 배포
	// 개발되는 순서는 상관없음
	// 진도는 100을 넘게되는날 배포가능 상태
	
	// 입력 데이터 길이
	int length = progresses.size();
	// 인덱스
	int i = 0;
	// 작업횟수
	int time = 1;
	// 반복횟수 카운트
	int count = 1;
	// 작업 완료된 갯수
	int complete = 0;
	// 모든 작업 완료
	bool end = false;

	// 선입선출 해야하므로 큐 사용
	queue<int> q;

	// 앞에 작업이 끝나야 뒤에도 배포된다. 
	while (!end) {
		// 작업 진행
		progresses[i] += (speeds[i] * time);
		// 작업 완료
		if (progresses[i] >= 100) {
			// 다음 인덱스 
			i++;
			// 완료된 수 증가
			complete++;
			// 동일한 작업일 수를 반영하기 위함
			time = count;
			// 마지막 작업 완료
			if (i == length) {
				q.push(complete);
			}

		}
		// 작업 완료안된 경우
		else {
			// 완료된 횟수가 0이아니면 q에 저장
			if (complete != 0) {
				q.push(complete);
			}
			// 반복 횟수 초기화
			time = 1;
			count++;
			complete = 0;
		}
		// 완료된 작업 처리
		if (!q.empty()) {
			// 반환 값에 추가
			answer.push_back(q.front());
			// 등록 후 삭제
			q.pop();
		}
		// 모든 요소 확인 끝
		if (i >= length) {
			end = true;
			break;
		}
	}
	return answer;
}
```

작업 횟수 time은 작업이 완료될 때 까지 1로 진행된다. 작업이 완료되고 다음 작업이 진행될 때 작업일 수를 카운트하는 변수 count 값을 대입해서 동일한 작업일 수가 반영되도록 만든다.  

지금보니 count 변수명은 day가 나았을거같다.

그리고 코딩을 하다보니 반복문 한 번만에 끝내는데 신경쓰게되었고 결국 큐는 억지로 사용하게 되면서 저 자리에 굳이 큐가 아니어도되는 상황과 조건문이 덕지덕지 붙게된 코드가 만들어졌다.  

<br>

### 다른 풀이

```c++
#include <string>
#include <vector>
#include <iostream>
using namespace std;

vector<int> solution(vector<int> progresses, vector<int> speeds) {
    vector<int> answer;

    int day;
    int max_day = 0;
    for (int i = 0; i < progresses.size(); ++i)
    {
        // 남은 작업 일수(day) = 
        // 완료직전 진도 - 완료된 작업 진도 / 진행속도 + 1 
        day = (99 - progresses[i]) / speeds[i] + 1;
        // 작업일수를 비교해서 처음에는 그냥 삽입하고 
        if (answer.empty() || max_day < day)
            answer.push_back(1);
        // 이후에는 값을 증가 시킨다.
        else
            ++answer.back();
        // 작업 일수가 더 큰 경우를 만나면 갱신
        if (max_day < day)
            max_day = day;
    }

    return answer;
}
```

이런 방법은 생각도 못했다. 작업을 끝내는데만 집중했고 남은 일수를 비교하여 각 작업들이 끝났는지 아닌지를 판단하는 방법이다.  

현재 작업이 다음 작업보다 남은 작업일 수가 크다면 다음 작업은 무조건 끝나있는 상태이다. 그리고 그 작업일 수를 기준으로 더 큰 작업일 수를 만날 때 까지 삽입된 값을 증가시켜준다. 

큐를 사용하지 않았지만 남은 일수를 통해 문제를 해결했다는 점이 좋은 아이디어라고 생각했다.