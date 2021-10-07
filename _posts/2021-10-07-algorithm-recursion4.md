---
title:  "[영리한 프로그래밍을 위한 알고리즘] #4 순환4"
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

### 미로찾기 문제  
2차원 좌표에서 통과할 수 있는 길과 막혀있는 벽이 존재하고 입구와 출구가 주어졌을 때 길을 찾는 문제이다.  

**recursive thinking**  
현재 위치에서 출구까지 가는 경로가 있으려면  
현재 위치가 출구이거나 또는 이웃한 경로에서 현재 위치를 지나지 않고 출구까지 가능 경로가 있어야한다.  

쉽게 이해하기 위해서 우선 문장처럼 만들어 본다.  

```
boolean findPath(x, y)
if (x, y) is the exit
  return true

else 
  for each neighbouring cell (x', y') of (x, y) do
    if (x', y') is on the pathway 
      if findPath (x', y')
          return true;
  return false;
```

우선 현재 위치를 확인하여 출구라면 true를 반환하고 아니라면 이웃하는 경로들을 검사하고 현재위치를 옮기고 검사하고를 반복해준다.  

하지만 이 경우 두 경로 사이를 오가면서 무한루프에 빠지는 경우가 생기게 되므로 이를 예외처리할 방법이 필요하다.  

```
boolean findPath(x, y)
if (x, y) is the exit
  return true

else 
  mark (x, y) as a visited cell;
  for each neighbouring cell (x', y') of (x, y) do
    if (x', y') is on the pathway and not visited
     if findPath(x', y')
       return true;
  return false;
```

이미 방문한 위치는 표시해서 다시 방문하지 않게 처리해주는 작업이 필요하다.  

이 예외처리는 순환함수 호출전에 확인하거나 함수의 처음에서 예외처리하는 방법이 있다.  

```
boolean findPath(x, y)
  if (x, y) is either on the wall or a visited cell
    return false;
  else if (x, y) is the exit
    return true;
  else
      mark (x, y) as a visited cell;
      for each neighbouring cell (x', y') of (x, y) do
        if findPath(x', y')
          return true;
      return false;
```


### 코드  
미로의 좌표는 2차원 배열로 설정하고 경로의 종류를 임의의 정수로 지정해 배열에 채우도록 한다.  

출발위치는 0, 0 출구는 7, 7로 정한다.  

미로를 설정하는 함수

```java
public class Maze {
  private static int N=8;
  private static int [][] maze = {
    {0, 0, 0, 0, 0, 0, 0, 1},
    {0, 1, 1, 0, 1, 1, 0, 1},
    {0, 0, 0, 1, 0, 0, 0, 1},
    {0, 1, 0, 0, 1, 1, 0, 0},
    {0, 1, 1, 1, 0, 0, 1, 1},
    {0, 1, 0, 0, 0, 1, 0, 1},
    {0, 0, 0, 1, 0, 0, 0, 1},
    {0, 1, 1, 1, 0, 1, 0, 0}
  };

  // 경로를 직관적으로 표현하기위한 매크로상수
  private static final int PATHWAY_COLOUR = 0;
  private static final int WALL_COLOUR = 1;
  // 방문했으며 출구까지의 경로상에 있지 않은게 밝혀진 위치
  private static final int BLOCKED_COLOUR = 2;  
  // 방문했지만 아직 출구로 가는 경로가 될 가능성이 있는 위치
  private static final int PATH_COLOUR = 3; 
}
```

미로를 탐색하는 함수

```java
public static boolean findMazePath(int x, int y) {
  // 우선 좌표의 범위가 유효한지 확인한다. 0 ~ 7
  if (x < 0 || y < 0 || x >= N || y >= N)
    return false;
  // 나머지 다시 검사할 필요가 없는 경로를 처리한다.  
  else if (maze[x][y] != PATHWAY_COLOUR)
    return false;
  // 현재위치가 출구인 경우 현재 위치를 방문위치로 변경하고 true 반환
  else if (x == N-1 && y == N-1) {
    maze[x][y] = PATH_COLOUR;
    return true;
  }
  // 아직 출구는 아닌경우
  else {
    // 방문한 위치로 표시
    maze[x][y] = PATH_COLOUR;
    // 현재와 인접한 네개의 경로를 검사한다.   
    if (findMazePath(x-1, y) || findMazePath(x, y+1)
      || findMazePath(x+1, y) || findMazePath(x, y-1)) {
        return true;
    }
    // 이웃하는 경로를 검사해서 true가 없는 경우로 출구까지 경로가 될 수 없는 위치로 표시해준다음 false반환 
    maze[x][y] = BLOCKED_COLOUR;
    return false;
  }
}
```

메인 함수에서 현재위치를 전달인자로 호출한다.

```java
public static void main(String [] args) {
  printMaze();
  // 현재위치에서 시작
  findMazePath(0, 0);
  printMaze();
}
```

