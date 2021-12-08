---
title:  "[레트로의 유니티] 좀비서바이벌5 - 인터페이스"
excerpt: "unity3d, retro, example, zombie, interface"

categories:
  - UnityExample
tags:
  - [unity3d, retro, example, zombie, interface]

toc: true
toc_sticky: true
 
date: 2021-12-06 
last_modified_at: 2021-12-06
---  

***  

다양한 타입의 오브젝트들의 동작을 구현하기 위해서는 각 타입을 조건문으로 비교하여 서로 다른 반응을 구현할 수 있다.  

더 좋은 방법은 다양한 타입의 오브젝트를 하나의 추상화 인터페이스로 다루는 방법이 있다.  

<br>

### 인터페이스

외부와 통신하는 공개 통로이며 통로의 규격이다.  

인터페이스는 통로의 규격은 강제하지만 그 아래에서 발생하는 일은 관여하지 않는다.  

C# 인터페이스도 마찬가지로 어떤 메서드를 구현하도록 강제하는 계약으로 이를 상속하는 클래스는 해당 인터페이스의 메서드를 반드시 구현해야한다. 하지만 그 메서드의 정의에 대해서는 관여하지 않는다.  

<br>

#### 인터페이스 예시  

IItem 는 아이템 클래스를 상속하는 인터페이스이다. 일반적으로 인터페이스는 I접두사로 표현한다.  

```cs
public interface IItem {
  void Use (GameObject target);
}
```
IItem의 Use() 메서드는 아이템을 사용하는 메서드이다. 아이템을 사용할 대상을 매개변수로 GameObject 타입으로 받는다. 

인터페이스의 메서드는 선언만 존재하고 구현은 없다. 즉 메서드 형태만 결정하고 메서드 구현 방법은 자신을 상속하는 클래스에 맡긴다.  

인터페이스를 상속한 클래스는 인터페이스에 선언된 메서드를 반드시 public으로 구현해야한다. 

```cs
public class AmmoPack : MonoBehaviour, IItem {
  public in ammo = 30;

  public void Use(GameObject target) {
    // target에 탄알을 추가하는 처리
    Debug.Log("탄알이 증가 : " + ammo);
  }
}

public class HealthPack : MonoBehaviour, IItem {
  public float health = 50;

  public void Use(GameObject target) {
    // target의 체력을 회복하는 처리
    Debug.Log("체력을 회복 : " + health);
  }
}
```

IItem을 상속한 클래스는 Use() 메서드를 반드시 구현해야 하고 내부 구현은 클래스마다 달라도 상관없다.  

<br>

### 느슨한 커플링  

외부에서 IItem 인터페이스를 상속한 클래스로부터 생성된 오브젝트에 접근했다고 가정할 때 상속한 클래스는 Use() 메서드를 구현했음이 보장되고 어떤 오브젝트가 IItem 타입으로 취급 가능하다면 구체적인 타입을 검사하지 않고 Use()메서드를 실행할 수 있다.  

```cs
void OnTriggerEnter(Collider other) {
  AmmoPack ammoPack = other.GetComponent<AmmoPack>();
  if (ammoPack != null) {
    ammoPack.Use();
  }
  HealthPack healthPack = other.GetComponent<HealthPack>();
  if (healthPack != null) {
    healthPack.Use();
  }
}
```

위 코드는 충돌한 상대방의 컴포넌트가 AmmoPack 타입인지 HealthPack 타입인지 모르기 때문에 충돌한 상대방 컴포넌트를 가능한 모든 아이템 타입으로 검사한다.  

만약 아이템이 수백 개가 존재한다면 검사해야할 타입의 수도 증가하는 문제가 발생한다.  

인터페이스를 사용하면 이 문제를 해결할 수 있다.  

```cs
void OnTriggerEnter(Collider other) {
  IItem item = other.GetComponent<IItem>();
  if (item != null) {
    item.Use();
  }
}
```

인터페이스를 사용하면 상속한 클래스의 오브젝트는 IItem 타입으로 취급할 수 있게 된다. (다형성) 따라서 이를 상속한 수백 가지의 아이템이 존재하더라도 IItem 타입 하나만을 검사해서 처리할 수 있게 되고 이 객체의 Use()메서드를 동작시켜도 상속받은 각 클래스들은 내부에서 구현한 메서드대로 동작하기 때문에 일괄적으로 처리할 수 있다.

이렇게 어떤 코드가 특정 클래스의 구현에 결합되지 않아 유연하게 변경 가능한 상태를 느슨한 커플링(loose coupling)이라고 한다.  