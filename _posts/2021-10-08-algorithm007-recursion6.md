---
title:  "[영리한 프로그래밍을 위한 알고리즘] #6 순환_N-Queens 문제"
excerpt: "algorithm, recursion, inflearn, java"

categories:
  - Algorithm
tags:
  - [algorithm, recursion, inflearn, java]

toc: true
toc_sticky: true
 
date: 2021-10-08 
last_modified_at: 2023-06-04
---  

***

### N-Queens 

N * N 크기의 2차원 좌표상에 N개의 말을 놓을 때 각 말들은 같은 행과 열 그리고 대각선 방향에 다른말이 존재하지 않게 배치할 수 있는지에 대한 문제이다.  

![n_queen](/assets/images/posting/20211008/n_queen.png)  

알고리즘을 생각해보면  
하나의 말을 배치한다음 조건에 맞는 다음 말을 배치해 본다. 그리고 다시 다음 말을 배치할 때 행이 끝날 때 까지 조건을 만족하는 위치가 없다면 최근에 배치한 말을 무르고 조건을 만족하는 또다른 위치에 배치시키는 방식으로 진행한다.  

![n_4](/assets/images/posting/20211008/n_4.png)

이런 방식의 문제 해결법을 backtracking 이라고 한다.  

이 과정을 체계화시켜서 시각적 구조로 표현한 것을 상태공간트리(state-space tree)라고 한다.  


![sst](/assets/images/posting/20211008/sst.png)

즉 이구조는 말을 놓을 수 있는 모든 경우의 수를 나타낸 것이기 때문에 원하는 답이 반드시 포함하게 되는 것이다. 

그렇기 때문에 모든 트리를 탐색하지 않으면서 원하는 노드를 찾는 탐색 방법이 필요하게 된다.    



### 되추적 기법(backtracking)
상태공간 트리를 깊이 우선 탐색(DFS, depth-first search)하여 답을 찾는 알고리즘을 말한다.  

![dfs](/assets/images/posting/20211008/dfs.png)

(1, 1)에 1번 말이 위치할 때 2번 말이 (2, 1) (2, 2)에 위치한 경우는 살펴볼 필요도 없는 infeasible이기 때문에 (2, 3)으로 넘어가게 되고 (2, 3)에 위치한 경우는 그림에서 확인한거 처럼 다음 말이 위치할 곳이 없기 때문에 (2, 4) 노드로 탐색이 넘어가는 방식이다.  

되추적 알고리즘을 구현하는 방식으로는 대표적으로 recursion과 stack이 있는데 간단하고 쉽게 표현가능한 recursion이 일반적으로 많이 쓰인다.  

<br/>

### 코드로 만들기
design recursion

```java
//매개변수 arguments 를 고려할 때 내가 현재 트리의 어떤 노드에 있는지를 지정해야한다. 
return-type queens( arguments )
{
  // 우선 현재 노드를 더 탐색할 필요가 있는지 확인한다.
  // 조건에 맞지 않다면 더 이상 탐색할 필요없이 종료
  if non-promising
    report failure and return;
  // 지금 노드가 찾는 노드가 맞으면 답을 출력한다.  
  else if success
    report answer and return;
  // 현재 노드가 답은 아니지만 꽝도 아니라면 그 자식 노드를 탐색하게 된다.  
  else
    visit children recursively;
}
```

* 매개변수   
recursion을 호출할 때 현재 위치한 노드를 파악하기 위한 매개변수  

  ```java
  // 현재 level을 저장하기 위한 변수
  int [] cols = new int [N+1];
  // 현재 노드레벨 int level
  return-type queens( int level) {
    ~
  }
  ```

  현재 노드를 표현하기 위해서 int level로 표현하고 이를 배열 cols에 저장하여 관리한다.    

  cols[i] = j 는 i번 말이 (i행, j열)에 놓였음을 의미한다.  


* 반환형  
  boolean 타입으로 탐색의 성공 실패 여부를 파악한다.  

  ```java
  if (!promising(level))
    return false;
  ```

* 성공 판단
  success 여부를 판단하기 위한 방법을 정한다.  

  ```java
  else if (level == N)
    return true;
  ```
  promising 테스트를 통과했다는 가정하에  
  N은 놓아야할 말의 개수로 level == N은 모든 말이 놓인 상태를 뜻한다.  


* 자식 노드 방문
  level + 1번말을 1 ~ N번 열 사이 어디에 놓을지 결정  

  ```java
  // level + 1번 말을 놓을 수 있는 위치가 N가지
  for (int i = 1; i <= N; i++) {
    // 각 위치마다 말을 놓을 수 있는지 확인
    cols[levle+1] = i;
    if (queens(level + 1))
      // level + 1의 자식들 중에 말을 놓을 수 있는 경우가 있다면 다른 경우 확인할 필요도 없으므로 return true
      return true;
  }
  // 모든 위치가 말을 놓을 수 없으면 false
  return false;
  ```


* promising test  

  위에서 정한대로 현재 level의 값만큼 말이 배치되어있고 이 말들의 위치 정보는 배열 cols에 저장되어있다.

  ![cols](/assets/images/posting/20211008/cols.png)

  코드에서 promsing test를 가장 먼저 진행하기 때문에 순환함수가 호출되면서 이 테스트가 통과되어야 말이 놓이게 된다.  

  즉 이미 배치된 말들의 위치는 충돌이 없음이 보장되어 있는 상태로 마지막에 놓인 말이 이전에 놓인 다른 말들과 충돌하는지 검사하는 것으로 충분하다.  

  1 ~ level - 1말들을 level말 과 충돌 검사

  ```java
  boolean promising( int level)
  {
    // i는 1 ~ level-1까지 반복
    for (int i = 1; i < level; i++) {
      // 같은 열에 놓였는지 검사
      if (cols[i] == cols[level])
        return false;
      // 같은 대각선에 놓였는지 검사
      else if on the same diagonal
        return false;
    }
    return true;
  }
  ```

  **동일 대각선 검사**  
  같은 대각선에 위치한다는 것은 행과 열의 거리가 같다고 볼 수 있다.  

    ![cross_distance](/assets/images/posting/20211008/cross_distance.png)

  즉 ```level - i = |cols[level] - cols[i]|``` 로 볼 수 있고 대각선의 방향에 따라 값이 바뀌는 걸 고려해 절대값으로 해준다.  

    ```java
    boolean promising( int level)
    { 
      {
        ~
        // 같은 대각선에 놓였는지 검사
        else if (level - i == Math.abs(cols[level] - cols[i])
          return false;
      }
      return true;
    }
    ```

  <br/>

### 최종 코드

  ```java
  int [] cols = new int [N+1];
  boolean queens( int level)
  {
    if (!promising(level))
      return false;
    // success의 경우
    else if (level==N) {
      for (int i = 1; i <=N i++)
        // 말들의 위치를 출력해준다.  
        System.out.printIn("(" + i + ", " + cols[i] + ")");
      return true;
    }
    for (int i = 1; i <= N; i++) {
      cols[level+1] = i;
      if (queens(level+1))
        return true;
    }
    return false;
  }
  ```