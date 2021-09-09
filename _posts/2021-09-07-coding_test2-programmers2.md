---
title:  "[해시] 완주하지 못한 선수"
excerpt: "coding, test, programmers, hash"

categories: 
  - Programmers
tags:
  - [coding, test, programmers, hash]

toc: true
toc_sticky: true
 
date: 2021-09-10 
last_modified_at: 2021-09-10
---  

***

### 문제
수많은 마라톤 선수들이 마라톤에 참여하였습니다. 단 한 명의 선수를 제외하고는 모든 선수가 마라톤을 완주하였습니다.

마라톤에 참여한 선수들의 이름이 담긴 배열 participant와 완주한 선수들의 이름이 담긴 배열 completion이 주어질 때, 완주하지 못한 선수의 이름을 return 하도록 solution 함수를 작성해주세요.

<br/>

### 제한 사항
* 마라톤 경기에 참여한 선수의 수는 1명 이상 100,000명 이하입니다.

* completion의 길이는 participant의 길이보다 1 작습니다.

* 참가자의 이름은 1개 이상 20개 이하의 알파벳 소문자로 이루어져 있습니다.

* 참가자 중에는 동명이인이 있을 수 있습니다.

### 풀이

* 나의 풀이
  ```cpp
  string solution(vector<string> participant, vector<string> completion) {
      string answer = "";

      for (int i = 0; i < participant.size(); i++)
      {
          for (int j = 0; j < completion.size(); j++)
          {
              if (participant.at(i) == completion.at(j))
              {
                  participant.at(i).erase();
                  completion.at(j).erase();
              }
          }

          if (participant.at(i) != "")
          {
              answer = participant.at(i);
          }
      }

      return answer;
  }
  ```

  결과  

  ```
  // 정확성 테스트
  테스트 1 〉	통과 (0.01ms, 4.32MB)
  테스트 2 〉	통과 (0.01ms, 3.67MB)
  테스트 3 〉	통과 (1.01ms, 3.76MB)
  테스트 4 〉	통과 (4.49ms, 4.2MB)
  테스트 5 〉	통과 (3.72ms, 4.33MB)

  // 효율성 테스트
  테스트 1 〉	실패 (시간 초과)
  테스트 2 〉	실패 (시간 초과)
  테스트 3 〉	실패 (시간 초과)
  테스트 4 〉	실패 (시간 초과)
  테스트 5 〉	실패 (시간 초과)
  ```

  두 컨테이너의 인덱스를 전부 비교하다 보니 정확성은 통과했지만 연산이 너무 느려 효율성 테스트는 통과하지 못한다.  

* 개선한 풀이

  ```cpp
  #include <string>
  #include <vector>
  #include <algorithm>
  using namespace std;

  string solution(vector<string> participant, vector<string> completion) {
      string answer = "";
      
      sort(participant.begin(), participant.end());
      sort(completion.begin(), completion.end());

      for (int i = 0; i < completion.size(); i++)
      {
          if (participant[i] != completion[i])
          {
              answer = participant[i];
              return answer;
          }
      }
      // 조건문이 끝나면 배열의 마지막 인덱스가 미완주자
      return participant.back();
  }
  ```

  sort 함수를 사용해서 두 컨테이너를 정렬 시킨 다음 인덱스 순서대로 비교하여 차이가 나는 부분의 인덱스 값을 반환한다. 조건문이 리턴이 없이 종료되면 참가자의 마지막 인덱스가 미완주자이기 때문에 조건문이 끝나면 마지막 인덱스를 반환한다.  

  결과  
  ```
  // 정확성 테스트
  테스트 1 〉	통과 (0.01ms, 3.66MB)
  테스트 2 〉	통과 (0.01ms, 3.66MB)
  테스트 3 〉	통과 (0.26ms, 3.84MB)
  테스트 4 〉	통과 (0.52ms, 4.33MB)
  테스트 5 〉	통과 (0.69ms, 4.34MB)

  // 효율성 테스트
  테스트 1 〉	통과 (37.78ms, 14.3MB)
  테스트 2 〉	통과 (54.49ms, 19.8MB)
  테스트 3 〉	통과 (72.19ms, 23.3MB)
  테스트 4 〉	통과 (74.94ms, 25.4MB)
  테스트 5 〉	통과 (74.44ms, 25.4MB)
  ```

  정렬만 했을 뿐인데도 속도에서 상당한 차이가 생겼다.  

  하지만 문제의 카테고리가 해시이기 때문에 해시를 사용하는게 출제자의 의도일 것이다.  


* unordered_set 활용

  ```cpp
  #include <string>
  #include <vector>
  #include <unordered_set>
  using namespace std;

  string solution(vector<string> participant, vector<string> completion) {
    string answer = "";
    unordered_multiset<string> names;

    for (int i = 0; i < participant.size(); i++)
    {
      names.insert(participant[i]);
    }

    for (int j = 0; j < completion.size(); j++)
    {
      unordered_multiset<string>::iterator iter = names.find(completion[j]);
      names.erase(iter);
    }
    answer = *names.begin();

    return answer;
  }
  ```

  결과

  ```
  // 정확성 테스트
  테스트 1 〉	통과 (0.01ms, 3.65MB)
  테스트 2 〉	통과 (0.02ms, 3.7MB)
  테스트 3 〉	통과 (0.16ms, 4.25MB)
  테스트 4 〉	통과 (0.30ms, 3.83MB)
  테스트 5 〉	통과 (0.34ms, 3.78MB)

  // 효율성 테스트
  테스트 1 〉	통과 (18.71ms, 18.2MB)
  테스트 2 〉	통과 (28.63ms, 25.7MB)
  테스트 3 〉	통과 (35.19ms, 30.5MB)
  테스트 4 〉	통과 (39.21ms, 33.2MB)
  테스트 5 〉	통과 (41.83ms, 33.2MB)
  ```

  해시를 사용하니 더 빠른 속도로 결과를 냈다.  

  하지만 이렇게 간단한 데이터 처리의 경우 정렬도 해시도 쓰지않고 효율을 뽑아낼 수 있다.  

* 다른 풀이

  ```cpp
  #include <string>
  #include <vector>
  using namespace std;

  string solution(vector<string> a, vector<string> b) {
    string answer = "";
    char c[29];
    for (int i = 0; i < 21; i++)
    {
      c[i] = 0;
    }

    for (int i = 0; i < a.size(); i++)
    {
      for (int j = 0; j < a[i].size(); j++)
      {
        c[j] ^= a[i][j];
      }
    }

    for (int i = 0; i < b.size(); i++)
    {
      for (int j = 0; j < b[i].size(); j++)
      {
        c[j] ^= b[i][j];
      }
    }

    answer = string(c);

      return answer;
  }
  ```

  비트 연산자를 사용해서 각 문자를 비교하는 방식이다. 연산 속도와 효율성을 비교해보면 상당히 차이가 큰게 보인다.  

  ```
  // 정확도 테스트
  테스트 1 〉	통과 (0.01ms, 4.26MB)
  테스트 2 〉	통과 (0.01ms, 4.22MB)
  테스트 3 〉	통과 (0.06ms, 4.27MB)
  테스트 4 〉	통과 (0.12ms, 4.27MB)
  테스트 5 〉	통과 (0.12ms, 4.29MB)

  // 효율성 테스트
  테스트 1 〉	통과 (5.68ms, 14.1MB)
  테스트 2 〉	통과 (7.81ms, 19.7MB)
  테스트 3 〉	통과 (9.88ms, 23.3MB)
  테스트 4 〉	통과 (10.37ms, 25.4MB)
  테스트 5 〉	통과 (9.72ms, 25.3MB)
  ```

  비트 연산자를 사용하는건 생각도 안해봤는데 코딩할 땐 항상 다양한 방식으로 사고하는 연습이 필요하다고 느꼈다.