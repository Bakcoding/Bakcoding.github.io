---
title:  "[해시] 위장"
excerpt: "coding, test, programmers, hash"

categories: 
  - Programmers
tags:
  - [coding, test, programmers, hash]

toc: true
toc_sticky: true
 
date: 2021-12-22 
last_modified_at: 2021-12-22
---  

***

### 문제

스파이들은 매일 다른 옷을 조합하여 입어 자신을 위장한다.

예)

|종류|이름|
|----|----|
|얼굴|동그란 안경, 검정 선글라스|
|상의|파란색 티셔츠|
|하의|청바지|
|겉옷|긴 코트|

스파이가 가진 의상들이 담긴 2차원 배열 clothes가 주어질 때 서로 다른 옷의 조합의 수를 return 하도록 solution 함수를 작성한다.  

<br>

### 제한사항

* clothes의 각 행은 [의상의 이름, 의상의 종류]로 이루어져 있다.

* 스파이가 가진 의상의 수는 1개 이상 30개 이하이다.

* 같은 이름을 가진 의상은 존재하지 않는다.

* clothes의 모든 원소는 문자열로 이루어져 있다.

* 모든 문자열의 길이는 1이상 20이하인 자연수이고 알파벳 소문자 또는 '_'로만 이루어져 있다.  

* 스파이는 하루에 최소 한 개의 의상은 입는다.  

<br>

### 나의 풀이

주어진 의상으로 만들 수 있는 경우의 수를 반환하는 문제 

아직 해시함수에 익숙하지 않아서 조건문과 반복문만 활용하여 풀었다.

```c++
#include <string>
#include <vector>
#include <algorithm>

using namespace std;

// sort 함수의 기준을 정해준다.
// 의상 배열의 두 번째 열에 종류가 오기 때문에 같은 종류로 정렬하기 위함
bool SortSecCol(const vector<string>& v1, const vector<string>& v2)
{
    return v1[1] < v2[1];
}

int solution(vector<vector<string>> clothes) {
    int answer = 0;
    // clothes 2차원 배열 [의상 이름][의상 종류] 이렇게 주어진다.
    // 중복되지 않는 모든 경우의 수, 즉 하나 이상은 입어야한다.
    // 종류별로 개수구해서 곱하면 모든 경우의 수 나옴

    // 정렬부터
    sort(clothes.begin(), clothes.end(), &SortSecCol);
    
    // 사용할 변수
    // 배열의 길이
    int length = clothes.size();
    // 요소의 개수, 기본값 1
    int n = 1;
    // 계산된 결과를 저장할 변수
    int result = 0;
    // 배열의 정보를 저장할 컨테이너
    vector<int> count;

    // 각 의상 종류마다 선택지 개수 + 안입는 경우
    // 하지만 반드시 하나 이상은 착용해야한다. => 결과 - 1 (모두 안입은 경우 제외)

    // 1. 의상마다 개수 구하기
    // 배열 길이 - 1만큼 반복
    for (int i = 0; i < length - 1; i++) {
        // 해당 인덱스와 다음 인덱스 비교
        // 정렬된 상태이기 때문에 같은 종류의 의상은 이웃함
        if (clothes[i][1] == clothes[i + 1][1]) {
            // 같은 종류의 개수를 저장하는 변수 증가
            n++;
        }
        else {
            // 같지 않은 경우
            // 각 의상 정보를 컨테이너에 저장
            count.push_back(n);
            // 개수 초기화
            n = 1;
        }
    }
    count.push_back(n);

    // 정보가 저장된 컨테이너 각 인덱스를 곱함
    // 안입은 경우 포함시키기 위해 각 요소 값 +1
    for (int val : count) {
        // 처음 값은 그냥 대입해준다.
        if (result == 0) {
            result += val + 1;
        }
        // 이후 값을 곱해서 대입한다.
        else {
            result *= val + 1;
        }
    }

    // 모두 벗은 경우 제외
    answer = result - 1;

    return answer;
}
```

경우의 수를 직접 구하기 위해서 중복되는 의상의 개수를 각 각 구하여 계산하였다.  

* 의상의 종류가 중복될 수 없기 때문에 각 종류의 의상 개수를 곱하면 모든 경우의 수가 나온다.  

* 중요한 점은 의상을 안입는 선택지도 있기 때문에 각 개수마다 + 1한 값을 곱해야한다.  

* 마지막으로 하나 이상의 의상은 반드시 착용해야하기 때문에 모두 벗은 경우를 제외시킨다. 

<br>

### 해시를 활용한 풀이

```c++
#include <string>
#include <vector>
// 순서 없이 삽입
#include <unordered_map>

using namespace std;

int solution(vector<vector<string>> clothes) {
    // 1부터 시작
    int answer = 1;

    // 해시로 만든다.
    unordered_map <string, int> attributes;
    for(int i = 0; i < clothes.size(); i++)
        // 해시에 의상 정보에 키값을 할당한다.
        // 중복되는 의상이 들어오면 키 값은 1 씩 증가
        // 각 의상의 키 값은 같은 종류의 의상의 개수의 값을 가지게 된다.
        attributes[clothes[i][1]]++;

    // 해시를 순회
    for(auto it = attributes.begin(); it != attributes.end(); it++)
        // 키 값에 1을 더한값을 결과에 계산한다.
        answer *= (it->second+1);

    // 모두 벗은 경우 제외
    answer--;

    return answer;
}
```

<br>

### 정리 

나의 풀이와 차이점은 중복되는 의상의 개수를 카운트하는 방법에 차이가 있었다. 

해시를 사용하니 직접 계산하는 과정이 필요없이 두 번째열의 값을 비교해 같은 종류일 때 키 값을 증가시켜 같은 종류의 의상 수를 구하여 전체적인 코드가 단축되었다.  

해시 활용법

```c++
attributes[clothes[i][1]]++;
```