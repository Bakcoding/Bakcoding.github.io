---
title:  "이차원 벡터 정렬"
excerpt: "cpp, algorithm, 2d, vector, sort"

categories:
  - Cpp
tags:
  - [cpp, algorithm, 2d, vector, sort]

toc: true
toc_sticky: true
 
date: 2021-12-22
last_modified_at: 2021-12-22
---  

***

### 이차원 벡터

이차원 배열의 경우 sort 함수를 사용하면 에러가 발생한다. 따라서 정렬이 필요한 이차원 컨테이너가 필요할 때는 이차원 벡터를 사용한다.  

#### 이차원 벡터 선언  

```cpp
vector<vector<int>> v = {
		{4, 3},
		{1, 2},
		{5, 4},
		{2, 1},
		{3, 5}
	};
```

벡터를 이중으로 사용하면 이차원 벡터가 선언된다.  

<br>

#### 반복자 접근  

반복자를 통해 접근하려면 인덱스를 명시해주어야한다.  

```cpp
for (iter = v.begin(); iter != v.end(); iter++) {
		cout << (*iter)[0] << " " << (*iter)[1] << "\n";
	}
```

<br>

### 정렬

이차원 벡터를 sort함수로 정렬 시켜보면  

```cpp
#include <iostream>
#include <algorithm>
#include <vector>

using namespace std;

int main() {

	vector<vector<int>>::iterator iter;
	vector<vector<int>> v = {
		{4, 3},
		{1, 2},
		{5, 4},
		{2, 1},
		{3, 5}
	};
	cout << "before sort\n";
	for (iter = v.begin(); iter != v.end(); iter++) {
		cout << (*iter)[0] << " " << (*iter)[1] << "\n";
	}

	cout << "\n";
	sort(v.begin(), v.end());

	cout << "after sort\n";
	for (iter = v.begin(); iter != v.end(); iter++) {
		cout << (*iter)[0] << " " << (*iter)[1] << "\n";
	}

	return 0;
}
```
정렬 후 출력된 결과를 보면 정상적으로 동작하긴 한다.  

```
출력 결과

before sort
4 3
1 2
5 4
2 1
3 5

after sort
1 2
2 1
3 5
4 3
5 4
```

하지만 기본적으로 1열을 기준으로 정렬시키는데 2열을 기준으로 정렬시키기 위해서는 sort 함수의 인자를 통해서 함수의 기준을 정해준다.  

```cpp
// 기준 함수
bool SortSecCol(const vector<int>& v1, const vector<int>& v2)
{
	// [1]열을 비교한다.
    return v1[1] < v2[1];
}
.
.
.
int main() 
{
	.
	.
	.
	sort(v.begin(), v.end(), &SortSecCol);
}
```

결과

```
after sort
2 1
1 2
4 3
5 4
3 5
```

이렇게 함수의 기준을 재설정하여 인자로 참조해주면 원하는 값을 비교하여 정렬시킬 수 있다. 