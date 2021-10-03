---
title:  "셔플"
excerpt: "cpp, algorithm, shuffle"

categories:
  - Cpp
tags:
  - [cpp, algorithm, shuffle]

toc: true
toc_sticky: true
 
date: 2021-10-01
last_modified_at: 2021-10-01
---  

***

### 셔플(shuffle)  
값이 정해진 배열안의 요스들을 무작위로 순서를 바꾸는 알고리즘이다.  

* 배열을 만들고 값을 넣어준다.  
* 배열의 인덱스를 난수를 생성해 정하여 무작위로 배치한다.

```cpp
#include <iostream>
#include <ctime>

using namespace std;

void Swap(int* _lhs, int* _rhs)
{
	int tmp = *_lhs;
	*_lhs = *_rhs;
	*_rhs = tmp;
}

int main()
{
	srand((int)time(NULL));
	// 무작위로 섞을 배열
	int arr[10] = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
	int randIdx;
	int count = 0;

	while (1)
	{

		for (int i = 0; i < 10; i++)
		{
			// 0 ~ 9 난수생성
			randIdx = rand() & 9;
			Swap((arr + i), (arr + randIdx));
		}

		for (int j = 0; j < 10; j++)
		{
			arr[j];
			printf("%d ", arr[j]);
		}

		printf("\n");

		if (count == 2) break;
		count++;
	}

	return 0;
}
```