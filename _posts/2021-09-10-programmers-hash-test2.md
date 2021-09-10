---
title:  "[해시] 전화번호 목록"
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
전화번호부에 적힌 전화번호 중, 한 번호가 다른 번호의 접두어인 경우가 있는지 확인하려 합니다. 전화번호가 다음과 같을 경우, 구조대 전화번호는 영석이의 전화번호의 접두사입니다.

* 구조대 : 119
* 박준영 : 97 674 223
* 지영석 : 11 9552 4421

전화번호부에 적힌 전화번호를 담은 배열 phone_book이 solutuon 함수의 매개변수로 주어질 때, 어떤 번호가 다른 번호의 접두어인 경우가 있으면 false를 그렇지 않으면 true를 return 하도록 solution 함수를 작성해 주세요.

<br/>

### 제한 사항
* phone_book의 길이는 1 이상 1,000,000 이하입니다.  
  * 각 전화번호의 길이는 1 이상 20 이하입니다.
  * 같은 전화번호가 중복해서 들어있지 않습니다. 

### 풀이

내 풀이

```cpp
#include <string>
#include <vector>
#include <algorithm>
#include <unordered_set>
using namespace std;

bool solution(vector<string> phone_book) {
    bool answer = true;
    sort(phone_book.begin(), phone_book.end());
    unordered_set<string> setList;

    setList.insert(phone_book[0]);
    for (int i = 1; i < phone_book.size(); i++)
    {
        string str = "";

        for (int j = 0; j < phone_book[i].length(); j++)
        {
            str += phone_book[i][j];
            if (setList.find(str) != setList.end())
            {
                answer = false;
                return answer;
            }
        }
        setList.insert(phone_book[i]);
    }

    answer = true;
    return answer;
}
```

결과  

```
// 정확성 테스트
테스트 1 〉	통과 (0.01ms, 4.19MB)
테스트 2 〉	통과 (0.01ms, 3.61MB)
테스트 3 〉	통과 (0.01ms, 4.27MB)
테스트 4 〉	통과 (0.01ms, 4.25MB)
테스트 5 〉	통과 (0.01ms, 3.61MB)
테스트 6 〉	통과 (0.01ms, 4.33MB)
테스트 7 〉	통과 (0.01ms, 4.26MB)
테스트 8 〉	통과 (0.01ms, 4.31MB)
테스트 9 〉	통과 (0.01ms, 4.26MB)
테스트 10 〉	통과 (0.01ms, 4.26MB)
테스트 11 〉	통과 (0.01ms, 3.61MB)
테스트 12 〉	통과 (0.01ms, 4.32MB)
테스트 13 〉	통과 (0.01ms, 4.28MB)
테스트 14 〉	통과 (0.73ms, 3.71MB)
테스트 15 〉	통과 (0.81ms, 4.32MB)
테스트 16 〉	통과 (1.75ms, 4MB)
테스트 17 〉	통과 (2.11ms, 4.32MB)
테스트 18 〉	통과 (2.59ms, 4.3MB)
테스트 19 〉	통과 (1.08ms, 4.31MB)
테스트 20 〉	통과 (2.29ms, 4.27MB)

// 효율성 테스트
테스트 1 〉	통과 (3.73ms, 4.46MB)
테스트 2 〉	통과 (3.50ms, 4.43MB)
테스트 3 〉	통과 (242.63ms, 55.8MB)
테스트 4 〉	통과 (267.49ms, 43.5MB)
```

해시를 쓰는 방식으로 풀이하기 위해 unordered_ 를 사용했고 값의 존재 여부만 필요하고 중복은 허용되지 않기 때문에 set을 사용한다.  

해시맵에 저장하기전 정렬을 통해서 접두어가 더 빨리 검색되도록한다.  

첫 번째 인덱스는 비교할 대상이 없기 때문에 그냥 삽입을 해주고 두 번째 인덱스 부터 문자를 하나씩 검색하면서 존재한다면 false를 반환한다.  

조건문에서 반환이 없다면 문자열을 해시맵에 삽입하고 다음 문자열을 비교한다.  

반복문이 끝나면 접두어가 없는 경우기 때문에 true를 반환시킨다.


<br/>

다른풀이

* 해시를 쓰지 않는 방법

  ```cpp
  #include <string>
  #include <vector>
  #include <algorithm>

  using namespace std;

  bool solution(vector<string> phone_book) {
      sort(phone_book.begin(), phone_book.end());
      for(unsigned int i = 0; i< phone_book.size()-1; i++){
          if(to_string(stoi(phone_book[i])+1)>phone_book[i+1]) return false;
      }
      return true;
  }
  ```

  해시를 사용하지 않고 바로 문자열을 비교한다.  
  정렬해서 문자열을 배치 시킨 다음 매개변수로 들어오는 vector안의 문자열을 하나씩 비교한다.  

  stoi(string to int)로 문자열을 정수로 변환시킨 다음 값을 1더하고 다시 문자로 바꾼 다음 인덱스의 문자열과 크기를 비교한다.  

  **문자열의 크기비교**  
  문자열의 크기비교는 각 자리수마다 비교하여 크기가 같다면 다음 자리수로 넘어간다.

  예) "1231" 과 "124" 두 문자열의 크기를 비교한다고 했을 때 앞에서 부터 비교하여 같은 문자인 1, 2는 넘어가고 세 번째 3과 4를 아스키코드 값을 비교하여 더 큰 4가 포함된 문자열 "124"가 더 큰 값을 가지게 된다.  

  다시 풀이로 돌아가서  
  i의 문자열이 i + 1의 접두사로 포함되어 있다면 i 문자열의 정수값에 1을 더한 문자열 크기는 항상 i + 1 보다 크게 되고, 만약 이 조건을 만족하지 못한다면 접두사로 포함하지 않는 경우인 것이 된다.  

  다만 문자열을 정렬 했다는 전제 조건이 필요한 조건문이다.  

