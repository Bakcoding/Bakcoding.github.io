---
title:  "오브젝트 움직이기"
excerpt: "unity3d, engine, move"

categories:
  - Unity
tags:
  - [unity3d, engine, move]

toc: true
toc_sticky: true
 
date: 2021-10-20 
last_modified_at: 2023-06-04
---  

***

### 움직이는 방식  
유니티에서 오브젝트를 움직이는 방법에는 다양하게 있지만 크게 위치값을 변경하거나 물리적 작용으로 이동시키는 방법들이 있다.  

위치값을 변경하는 방식은 프레임단위로 위치값을 조금씩 변경시켜서 움직이는것처럼 보이게하는 방식이다. 

물리적 작용으로 이동시키는 방식은 유니티에서 구현해놓은 물리적인 동작을 이용하는 것이다. 특정 방향으로 힘을 주거나 물체의 가속도를 조작하여 실제 움직임과 가깝게 동작한다.  

<br/>

### 1. 위치값 변경  
오브젝트의 Transform 컴퍼넌트의 Position값을 변경한다.  

```c#
inputX = Input.GetAxis("Horizontal");
inputZ = Input.GetAxis("Vertical");

Vector3 newPos = tr.position;
newPos += inputX * speed * tr.forward * Time.deltaTime;
tr.position = newPos;
```

위치를 이동시키는 함수  

**Translation**  

위 코드를 함수화시킨것과 같다.  

```c#
Vector3 newPos2 = Vector3.zero;
newPos2.z = inputZ * speed * Time.deltaTime;
tr.Translate(newPos2);
```  

**MoveToward**  

Vector3에 포함된 메서드로 목표를 향해서 이동하게 한다.  

```c#
tr.position = Vector3.MoveTowards(tr.position, target.position, speed * Time.deltaTime);
```

하지만 위치를 이동시키는 방식은 미세하게 순간이동 시키는 것과 같은 동작으로 벽에 파묻히거나 너무 빠른 속도라면 벽을 통과하기도 한다. 따라서 간단하게 움직이는것만 필요한게 아니라면 물리적으로 움직이는게 낫다.  

![position_move](/assets/images/posting/20211020/position_move.gif)

<br/>

### 2. 물리작용

Rigidbody 컴포넌트를 통해 접근한다.  

**AddForce**  

```c#
rb.AddForce(Vector3.forward * inputX * power);
```

특정 방향으로 힘을 가한다. 방향이 필요하므로 Vector3 인자가 필요하다. 

**Velocity**

```c#
rb.velocity = Vector3.forward * inputX * power;
```

함수가 아닌 리지드바디의 velocity 변수에 값을 대입한다.  

AddForce의 경우 관성이 작용하고 velocity는 관성이 없다.  

따라서 상황에 따라 적절한 방식을 사용하면된다.  

![velocity_move](/assets/images/posting/20211020/velocity_move.gif)

물리를 통해 물체를 이동시키면 벽에 파묻히진 않는다. 다만 너무 빠른속도의 경우 통과하는 문제는 여전히 존재하며 어떤 방식을 사용해도 이런 문제는 보완이 필요하다.  