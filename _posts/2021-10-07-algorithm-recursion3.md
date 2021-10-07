---
title:  "[영리한 프로그래밍을 위한 알고리즘 강좌] #2 순환 3"
excerpt: "algorithm, recursion, inflearn, java"

categories:
  - Algorithm
tags:
  - [algorithm, recursion, inflearn, java]

toc: true
toc_sticky: true
 
date: 2021-10-07 
last_modified_at: 2021-10-07
---  

***

### 순환 알고리즘 설계(designing recursion)
순환 함수는 코드의 단축이 가능한 만큼 구현하기 위해서 긴 코드를 짧게 표현할 수 있는 요령이 필요하다.  

<br/>

### 1. base case와 recursion case

가장 기본적으로 base case와 recursion case의 존재이다.  

* 적어도 하나의 base case가 존재해야한다.  

* 모든 recursion case는 결국 base case로 수렴해야한다.

<br/>

### 2. 암시적 매개변수를 명시적 매개변수로 변경

함수의 매개변수 상에서 직접 표현되지 않지만 코드진행에 방해되지 않고 동작이 가능한걸 암시적 매개변수라 하며 반대로 직접 표시되는 매개변수를 명시적 매개변수라 한다.  

코드를 통해 확인해보면  

```java
int search(int [] data, int n, int target) {
  for (int i = 0; i < n; i++)
    if (data[i] == target)
      return i;
  return -1;
}
```
반복문으로 순차탐색을 하는 함수이다. 반복문을 통해  배열의 n - 1 번 인덱스까지 순회하면서 target을 검색한다.  

여기서 배열의 범위는 0부터 n - 1까지이다. 즉 배열의 시작 범위인 0을 명시적으로 표현하지 않고 생략해도 코드 진행상 문제가 없으며 이런경우를 암시적 매개변수라 하며 n - 1 처럼 직접 매개변수로 받아온 것을 명시적 매개변수라 한다.  

순환함수에서는 일반적으로 이런 암시적 매개변수를 명시적으로 바꾸어주는게 권장된다.  


```java
// 인덱스의 시작 begin, 끝 end 명시적 표기
// 범위내의 요소들만 탐색한다.  
int search(int [] data, int begin, int end, int target) {
  // 데이터가 없는 경우 함수 종료
  if (begin > end)
    return -1;
  // target과 배열의 begin의 값 비교해서 같으면 begin을 반환한다.  
  else if (target == data[begin])
    return begin;
  // 같은걸 찾을 때 까지 begin 인덱스를 한 칸씩 올린다.
  else
    return search(data, begin+1, end, target);
}
```
이렇게 매개변수를 명시적으로 표현함으로서 함수내에서 다시 함수를 호출할 때 표현이 용이하다.  

즉 순환함수를 설계에서 매개변수는 함수를 호출하는 곳에서 받아올 전달인자가 아닌 함수내에서 호출할 때 표현에 필요한 매개변수를 고려하는게 일반적인 형태이다.  

**순차탐색 다른 방법**  
* begin을 옮기는게 아닌 end를 옮겨 배열의 뒤에서부터 앞으로 검색하는 방법

  ```java
  int search(int [] data, int begin, int end, int target) {
    if (begin > end)
      return -1;
    else if (target == data[end])
      return end;
    else
      return search(data, begin, end-1, target);
  }
  ```

* 배열을 반으로 나누고 middle 인덱스의 값을 비교하여 같을 때 까지 반으로 나누고 검사를 반복한다.  

  ```java
  int search(int [] data, int begin, int end, int target) {
    if (begin > end)
      return -1;
    else {
      // middle 중간지점 인덱스
      int middle = (begin + end) / 2;
      // middle부터 검사
      if (data[middle] == target)
        return middle;
      // 반으로 나눈 앞 부분을 다시 나누고 검사
      int index = search(data, begin, middle-1, target);
      if (index != -1)
        return index;
      // 앞쪽에서 못찾았으면 자른 반의 뒤를 검사
      else
        return search(data, middle+1, end, target);
    }
  }
  ```

  이진 탐색과는 다름

* 최대값 찾기 1  
   맨 앞의 인덱스를 제외한 나머지를 비교 후 더 큰 값을 구한다. 맨 앞의 기준을 한칸씩 뒤로 옮긴다.  

  ```java
  int findMax(int [] data, int begin, int end) {
    // 데이터가 하나이거나, begin의 이동이 끝에 도착한 경우 루프 종료
    if (begin == end)
      return data[begin];
    else
      // Math.max 두 인자 중 큰 값을 반환한다.  
      // 순환함수로 begin 인덱스를 한 칸씩 옮기면서 end 사이의 최대값 찾기
      return Math.max(data[begin], findMax(data, begin+1, end));
  }
  ```  


* 최대값 찾기 2  
  반을 나누고 middle의 값을 검사하는 방식을 활용  

  ```java
  int findMax(int [] data, int begin, int end) { 
    if (begin == end)
      return data[begin];
    else {
      int middle = (begin+end) / 2;
      // 반으로 나눈 앞을 다시 나누고 중간값 저장 
      int max1 = findMax(data, begin, middle);
      // 반으로 나눈 뒤를 다시 나누고 중간값 저장
      int max2 = findMax(data, middle+1, end);
      // 저장한 값 비교해서 최대값 탐색
      return Math.max(max1, max2);
    }
  }
  ``` 

* 이진 탐색
  기본적으로 데이터들은 정렬된 상태이다.  
  우선 가운데 데이터와 비교할 데이터를 비교한 뒤에 일치하지 않으면 대소를 비교하여 작으면 가운데 앞, 크면 가운데 뒤를 탐색하여 범위의 반을 계속 줄여가는 방식이다.  

  ```java
  public static int binarySearch(String[] items, String target, int begin, int end) {
    // 데이터 없는 경우
    if (begin > end)
      return -1;
    else {
      int middle = (begin+end) / 2;
      // 문자열비교 compareTo함수 같으면 0, 크면 양수, 작으면 음수 반환한다.  
      int compResult = target.compareTo(items[middle]);
      if (compResult == 0)
        return middle;
      else if (compResult < 0)
        return binarySearch(items, target, begin, middle-1);
      else
        return binarySearch(items, target, middle+1, end);
    }
  }
  ```



