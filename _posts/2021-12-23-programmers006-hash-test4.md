---
title:  "[해시] 베스트앨범"
excerpt: "coding, test, programmers, hash"

categories: 
  - Programmers
tags:
  - [coding, test, programmers, hash]

toc: true
toc_sticky: true
 
date: 2021-12-23 
last_modified_at: 2021-12-23
---  

***

### 문제

스트리밍 사이트에서 장르 별로 가장 많이 재생된 노래를 두 개씩 모아 베스트 앨범을 출시하려 한다. 노래는 고유 번호로 구분하며, 노래를 수록하는 기준은 다음과 같다.  

* 속한 노래가 많이 재생된 장르를 먼저 수록한다.

* 장르 내에서 많이 재생된 노래를 먼저 수록한다.

* 장르 내에서 재생 횟수가 같은 노래 중에서는 고유 번호가 낮은 노래를 먼저 수록한다.  

<br>

### 제한사항

* genres\[i\]는 고유번호가 i인 노래의 장르이다.

* plays\[i\]는 고유번호가 i인 노래가 재생된 횟수이다.

* 장르 종류는 100개 미만이다.

* 장르에 속한 곡이 하나라면, 하나의 곡만 선택한다.

* 모든 장르는 재생된 횟수가 다르다.

<br>

### 나의 풀이

입력받는 데이터는 문자열 장르, 정수값 재생 횟수이다.  

* 입력 데이터를 해시로 만들고 키값을 할당한다.  

* 정렬을 통해 원하는 값을 도출해낸다.

```c++
#include <string>
#include <vector>
#include <unordered_map>
#include <algorithm>

using namespace std;

// 정렬는데 사용하는 기준 함수
bool SortSecCol(const vector<int>& v1, const vector<int>& v2)
{
    return v1[0] > v2[0];
}

bool SortSecCol2(const pair<int, int>& v1, const pair<int, int>& v2)
{
    return v1.first > v2.first;
}

vector<int> solution(vector<string> genres, vector<int> plays) {
    vector<int> answer;
    // 방법
    // 인풋 데이터를 묶는다.
    // 같은 장르의 곡들의 플레이 횟수 총합 계산
    // 총 횟수 내림차순 정렬, 이 정보로 앨범 구성
    
    // 데이터 정리
    // 곡 장르, 각 재생 횟수, 고유 키 정보 저장
    unordered_map<string, vector<pair<int, int>>> inputData;
    // 장르별 재생 횟수 합계
    unordered_map<string, int> totalPlay;

    for (int i = 0; i < genres.size(); i++) {
        inputData[genres[i]].push_back(make_pair(plays[i], i));
        totalPlay[genres[i]] += plays[i];
    }

    // 총 재생 횟수 내림차순 정렬을 위한 벡터
    vector<int> v;

    for (auto e : totalPlay) {
        v.push_back(e.second);
    }

    // 내림차순 정렬
    sort(v.begin(), v.end(), greater<int>());

    // 앨범 채우기
    // 정렬된 총 재생 횟수를 기준으로 장르를 비교하고 모든 정보가 담긴 해시에서 키값을 꺼내온다.
    for (int j = 0; j < v.size(); j++) {
        // 장르를 저장할 변수
        string gerne;
       
        // 장르의 총 재생 횟수 비교하기위한 반복자
        auto iter = totalPlay.begin();
        
        // 총 재생 횟수 순회 
        for (iter = totalPlay.begin(); iter != totalPlay.end(); iter++) {
            
            // 총 재생 횟수 같은 값 비교
            if (iter->second == v[j]) {
                // 해당 장르 값을 저장
                gerne = iter->first;
                
                // 모든 정보가 저장된 해시에서 장르 문자열을 통해 정보를 가져온다.
                auto tmp = inputData[gerne];
                
                // 가져온 장르의 각 재생 횟수 내림차순으로 정렬
                sort(tmp.begin(), tmp.end(), &SortSecCol2);
                
                // 앨범에 정보 저장하기
                // 곡이 하나일 때는 하나만, 두 개 상이라면 두개까지만 정보 저장
                if (tmp.size() < 2) {
                    answer.push_back(tmp[0].second);
                }
                else {
                    answer.push_back(tmp[0].second);
                    answer.push_back(tmp[1].second);
                }
            }
        }
    }
    return answer;
}
```

필요한 값을 찾고 정렬하는 부분에서 상당히 거슬리게 처리를 해버렸다. 

```
sort(tmp.begin(), tmp.end(), &SortSecCol2);
```

map을 써서 정렬된 상태의 해시를 사용했어도 될 것 같다.

* unordered_map 해시 정렬하는 방법 찾아보기