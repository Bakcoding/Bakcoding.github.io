---
title:  "[큐] 다리를 지나는 트럭"
excerpt: "coding, test, programmers, queue"

categories: 
  - Programmers
tags:
  - [coding, test, programmers, queue]

toc: true
toc_sticky: true
 
date: 2021-12-25 
last_modified_at: 2021-12-25
---  

***

### 문제

트럭 여러 대가 강을 가로지르는 일차선 다리를 정해진 순으로 건너려 한다. 모든 트럭이 다리를 건너려면 최소 몇 초가 걸리는지 알아내야 한다. 다리에는 최대 bridge_length대 올라갈 수 있으며, 다리는 weight 이하까지의 무게를 견딜 수 있다. 단, 다리에 완전히 오르지 않은 트럭의 무게는 무시한다. 

예를 들어, 트럭 2대가 올라갈 수 있고 무게를 10kg까지 견디는 다리가 있다. 무게가 [7, 4, 5, 6]kg인 트럭이 순서대로 최단 시간 안에 다리를 건너려면 다음과 같이 건너야한다.  


|경과 시간|다리를 지난 트럭|다리를 건너는 트럭|대기 트럭|
|:-------|:---------------|:-----------------|:--------|
|	0		|	[]		|	[]		|		[7,4,5,6]	|
|	1~2		|	[]		|	[7]		|		[4,5,6]		|
|	3		|	[7]		|	[4]		|		[5,6]		|
|	4		|	[7]		|	[4,5]	|		[6]			|
|	5		|	[7,4]	|	[5]		|		[6]			|
|	6~7		|	[7,4,5]	|	[6]		|		[]			|
|	8		|	[7,4,5,6]	|	[]	|		[]			|

따라서, 모든 트럭이 다리를 지나려면 최소 8초가 걸린다. 

solution 함수의 매개변수로 다리에 올라갈 수 있는 트럭 수 bridge_length, 다리가 견딜 수 있는 무게 weight, 트럭 벼 무게 truck_weights가 주어진다. 이때 모든 트럭이 다리를 건너려면 최소 몇 초가 걸리는지 return 하도록 solution 함수를 완성하여라.

<br>

### 제한사항

* bridge_length는 1 이상 10000 이하이다.

* weight는 1 이상 10000 이하이다.

* truck_weights의 길이는 1 이상 10000 이하이다.

* 모든 트럭의 무게는 1 이상 weight 이하이다.

<br>

### 나의 풀이

풀이1)

컨테이너에 거리와 무게를 저장하고 반복문으로 진행시켜서 해결하면 쉽게 풀릴것같다.  

하지만 문제를 보면 트럭의 동작 방식이 고정되어있어 굳이 컨테이너를 순회하며 값을 증가시키면서 확인하는 방식이 필요없다고 생각했다.

<br>
<img src="/assets/images/20211227_Posting/pattern1.png" title="pattern1" width="300px">
<br>

* 모든 트럭은 1초마다 1만큼 이동하며 다리를 건너는데 걸리는 시간은 다리의 길이만큼이다. 

  즉 다리에 오르는 순간 걸리는 시간은 확정이되기 때문에 직접 트럭을 움직이는 연산이 필요없다. 

* 다음 트럭과 현재 다리위의 트럭 무게의 합이 다리 하중을 넘지 않으면 바로 이어서 출발이 가능한 상태가 되고 이러한 상태는 1만큼의 추가 시간만 필요하다.  

<br>
<img src="/assets/images/20211227_Posting/pattern2.png" title="pattern2" width="300px">
<br>

* 차량을 하나씩 보내면서 들어오는 차량에 대한 시간계산이 필요하다.


```c++
int solution(int bridge_length, int weight, vector<int> truck_weights) {
	printf("Bridge Length : %d / Bridge Weight : %d / Truck Length : %d\n\n\n\n", bridge_length, weight, truck_weights.size());
	int answer = 0;

	// 대기중 트럭
	queue<int> waitingTruck;
	// 다리위 진입한 트럭
	queue<int> onBridgeTruck;
	// 끝지점 트럭
	queue<int> endBridgeTruck;

	// 대기중 트럭 큐에 저장
	for (int e : truck_weights) {
		waitingTruck.push(e);
	}

	int onBridgeTruckWeight = 0;
	bool isWait = false;
	int interval = 0;
	bool isTruckChain = true;
	bool isEmptyIndex = false;
	bool canCreateEmpty = false;

	// 대기중인 트럭이 없을 때 까지 반복
	while (!waitingTruck.empty()) {

		// 다리위에 트럭이 없는 경우
		if (onBridgeTruck.size() == 0 && endBridgeTruck.size() == 0) {
			// 대기중인 트럭을 다리위로
			onBridgeTruck.push(waitingTruck.front());
			// 대기중인 트럭 목록에서 제거
			waitingTruck.pop();
			// 다리위 트럭 무게 추가
			onBridgeTruckWeight += onBridgeTruck.front();
			// 다리를 건너는데 걸리는 시간 추가
			answer += bridge_length;
			isTruckChain = true;
		}
		// 다리위에 트럭 있다면
		// 다음 트럭의 무게를 합해서 하중 비교
		else {
			// 트럭의 수는 다리의 길이를 넘을 수 없다.
			int totalTruck = endBridgeTruck.size() + onBridgeTruck.size();
			// 다음 트럭 무게
			int nextTruckWeight = waitingTruck.front();
			// 다리의 하중이 더 크면
			if (weight >= onBridgeTruckWeight + nextTruckWeight && bridge_length > totalTruck) {
				// 이어서 출발
				onBridgeTruck.push(nextTruckWeight);
				// 대기열에서 삭제
				waitingTruck.pop();
				// 다리위 트럭 무게 추가
				onBridgeTruckWeight += nextTruckWeight;

				// 연속해서 출발하는 경우면
				if (onBridgeTruck.size() > 1 && isTruckChain) {
					// 간격
					// 바로 뒤따라 출발
					if (interval == 0) {
						answer += 1;
						if (endBridgeTruck.size() != 0) {
							onBridgeTruckWeight -= endBridgeTruck.front();
							endBridgeTruck.pop();
						}
					}
					else {
						// endBridgeTruck의 트럭이 건너야 출발가능한 경우
						answer += interval + 1;
						interval = 0;
					}
				}
				// 연속하지 않은경우 또는 새로 출발
				else {
					// 연속 가능한 상태로
					isTruckChain = true;
					// 앞의 트럭 수 만큼 걸리는 시간 제외
					int truckCount = endBridgeTruck.size();
					answer += bridge_length - truckCount;
					interval = 0;
				}
			}
			// 하중을 넘게되는 무게라면, 현재 다리위 트럭들 끝에 배치하고 한대씩 제거하면서 무게확인
			else {
				// 다리위에 있는 트럭들 끝지점 배치
				// 끝지점 트럭없으면
				if (endBridgeTruck.size() == 0) {
					interval = 0;
					// 트럭의 연속성이 끊기게됨
					isTruckChain = false;
					// 다리위 트럭 전부 끝으로
					endBridgeTruck = onBridgeTruck;
					// 진입한 트럭 초기화
					onBridgeTruck = queue<int>();
					// 선두 차량 건너기
					onBridgeTruckWeight -= endBridgeTruck.front();
					endBridgeTruck.pop();
				}
				else {
					// endBridgeTruck의 첫번째 트럭을 제거한다.
					int headTruckWeight = endBridgeTruck.front();
					onBridgeTruckWeight -= headTruckWeight;
					endBridgeTruck.pop();
					// 제거 후 처리
					// 빈 공간 계산될 조건
					// 다리에 진입한 차량이 있을 때
					if (endBridgeTruck.size() != 0 && onBridgeTruck.size() > 0) {
						// 다음 차량이 출발할 수 있다면
						if (weight >= onBridgeTruckWeight + waitingTruck.front()) {
							isTruckChain = true;
						}
						// 출발 할 수 없는 무게
						else if (weight >= onBridgeTruck.front() + waitingTruck.front()){
							// 간격 증가
							interval++;
							onBridgeTruck.push(0);
						}
					}
				}
			}
		}
	}

	return answer + 1;
}
```

<br>
<img src="/assets/images/20211227_Posting/result.png" title="result" width="300px">
<br>

처음 생각보다 고려할 부분이 더 있었던거 같다. 뭔가 한 부분만 해결하면 될거같은데 오히려 계속 붙잡고 있다보니 더 꼬이게 되어 그냥 시간을 증가시키는 방식을 사용했다. 

<br>

풀이2)

트럭의 무게를 비교해 다리를 건너게 만들어 시간을 계산한다. 

```cpp
#include <string>
#include <vector>
#include <queue>

using namespace std;

int solution(int bridge_length, int weight, vector<int> truck_weights) {
	int answer = 0;
	// 트럭 무게 합
	int sum = 0;
	// 큐에 대기중인 트럭들 하나씩 제거
	queue<int> waitTruck;
	// 벡터에 이동거리와 무게를 저장
	vector<pair<int, int>> trucks;

	// 큐에 트럭 정보 저장
	for (int e : truck_weights) {
		waitTruck.push(e);
	}

	// 진행
	while (true) {

		// 트럭 추가
		if (!waitTruck.empty() && weight >= sum + waitTruck.front()) {
			trucks.push_back(make_pair(0, waitTruck.front()));
			sum += waitTruck.front();
			waitTruck.pop();
		}

		// 다리 위 트럭 이동
		for (int i = 0; i < trucks.size(); i++) {
			trucks[i].first += 1;

		}

		// 시간 증가
		answer += 1;

		// 맨 앞 트럭 다리 건너면 제거
		if (trucks[0].first >= bridge_length) {
			sum -= trucks[0].second;
			trucks.erase(trucks.begin());
		}

		// 종료 시점
		if (waitTruck.empty() && trucks.empty()) {
			break;
		}

	}

	// 마지막 트럭 트럭 완전히 건너는 시간 추가 +1
	return answer + 1;
}
```

채점은 통과했지만 처음 생각했던 방식이 막혀서 시원찮은 기분이다. 
