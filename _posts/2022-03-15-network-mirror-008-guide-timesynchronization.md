---
title:  "Mirror Guide Time Synchronization"
excerpt: "Network, Mirror, Time-Synchronization"

categories:
  - Mirror
tags:
  - [Network, Mirror, Time-Synchronization]

toc: true
toc_sticky: true
 
date: 2022-03-15
last_modified_at: 2022-03-15
---  

***

<br>

### Time Synchronization

시간 동기

대부분의 알고리즘에서는 클라이언트와 서버 간에 클럭을 동기화 해야하는데 Mirror는 자동으로 해준다.

현재 시간을 얻으려면 다음의 코드를 사용한다.

```cs
double now = NetworkTime.time;
```

클라이언트와 서버에 같은 값이 반환된다. 서버가 시작될 때 0부터 시작한다.

주의할 점은 시간은 double이기 때문에 float을 사용할 경우 시간이 지날수록 클럭의 정밀도가 떨어지게 된다.

* after 1 day, accuracy goes down to 8ms

* after 10 days, accuracy is 62ms

* after 30 days, accuracy is 250ms

* after 60 days, accuracy is 500ms

또한 Mirror에서는 애플리케이션에서 볼 수 있는 RTT(Round Trip Time)을 계산한다.

```cs
double rtt = NetworkTime.rtt;
```

<br>

정확도를 측정할 수 있다.

```cs
double time_standard_deviation = NetworkTime.timeSd;
```

예를 들어 0.2를 반환하는 경우 이것은 시간 측정값이 약 0.2초 위 아래로 오차가 있다는 것을 의미한다.

이 네트워크 딸꾹질은 EMA(Exponential Moving Average, 이동평균법)를 사용하여 값을 평활하게 함으로 보정된다.

<br>

ping을 송신하는 빈도를 설정할 수  있다.

```cs
NetworkTime.PingFrequency = 2;
```

계산에 사용되는 ping 결과의 수를 설정할 수도 있다.

```cs
NetworkTime.PingWindowSize = 10;
```