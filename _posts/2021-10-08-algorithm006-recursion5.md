---
title:  "[영리한 프로그래밍을 위한 알고리즘] #5 순환_블랍 셀 카운팅 문제"
excerpt: "algorithm, recursion, inflearn, java"

categories:
  - Algorithm
tags:
  - [algorithm, recursion, inflearn, java]

toc: true
toc_sticky: true
 
date: 2021-10-08 
last_modified_at: 2021-10-08
---  

***

### 블랍 셀 개수 세기(counting cells in a blob)

binary 이미지에서 각 픽셀이 background pixel 또는 image pixel 일 때 서로 연결된 image pixel들의 집합을 blob이라고 부른다.  

상하좌우 및 대각방향으로 인접한 경우에 픽셀은 연결된 것으로 간주한다.  

![binary_image](/assets/images/20211008_Posting/1.png)

블랍 셀 개수 세기 문제는 이미지상에 임의의 한 점의 좌표가 주어졌을 위치에 포함된 블랍의 크기를 세는 것이다.  

**문제 형태**  

* 입력  
  N * N 크기의 2차원 그리드상에 하나의 좌표 (x, y)가 주어졌을 때  

* 출력  
  픽셀 (x, y)가 포함된 blob의 크기를 구하시오 만약 (x, y)가 어떤 blob에도 속하지 않는 경우에는 0을 출력한다.

**recursive thinking**

* 현재 픽셀이 속한 blob의 크기를 카운트하려고한다. 

* 현재 픽셀이 image color가 아니라면 0을 반환한다.  

* 현재 픽셀이 image color라면 먼저 현재 픽셀을 카운트한다. count = 1  

* 현재 픽셀이 중복 카운트되는 것을 방지하기 위해 다른 색으로 칠한다.  

* 현재 픽셀에 이웃한 모든 픽셀들에 대해서 그 픽셀이 속한 blob의 크기를 카운트에 더해준다.  


알고리즘
```
if the pixel (x, y) is outside the grid
    the result is 0;

else if pixel (x, y) is not an image pixel or already counted 
    the result is 0;

else 
    set the colour of the pixel (x, y) to a red colour;
    the result is 1 plus the number of cells in each piece of the blob that includes a nearest neighbour;
```

코드로 표현  

```java
// 매크로 상수
private static int BACKGROUND_COLOR = 0;
private static int IMAGE_COLOR = 1;
private static int ALREADT_COUNTED = 2;

public int countCells(int x, int y) {
  // 좌표가 그리드 범위 안에 있는지 확인
  if (x < 0 || x >= N || y < 0 || y >= N)
    return 0;
  // 현재 좌표가 이미지 픽셀인지 확인
  else if (grid[x][y] != IMAGE_COLOR)
    return 0;
  // 인접한 픽셀 검사
  else {
    // 현재 위치 색 변경
    grid[x][y] = ALREADY_COUNTED;
    // 인접한 셀을 모두 순환함수로 호출해서 카운트 반환
    return 1 + countCells(x-1, y+1) + countCells(x, y+1)
      + countCells(x+1, y+1) + countCells(x-1, y)
      + countCells(x+1, y) + countCells(x-1, y-1)
      + countCells(x, y-1) + countCells(x+1, y-1);
  }
}
```