---
title:  "[레트로의 유니티] 좀비서바이벌8 - 다형성"
excerpt: "unity3d, retro, example, zombie, polymorphism"

categories:
  - UnityExample
tags:
  - [unity3d, retro, example, zombie, polymorphism]

toc: true
toc_sticky: true
 
date: 2021-12-07 
last_modified_at: 2021-12-07
---  

***  

### 게임내 모든 생명체가 상속하는 클래스  

Assets > Scripts > LivingEntity  

적과 플레이어 캐릭터를 포함한 모든 게임 속 생명체들은 몇 가지 공통적인 기능을 가져야하기 때문에 하나의 클래스를 만들고 상속해서 사용한다.  

* 체력을 가진다.  

* 체력을 회복할 수 있다.

* 공격을 받을 수 있다. 

* 살거나 죽을 수 있다.  

이렇게 생명체가 가져야할 공통적인 특징을 기반으로 LivingEntity 클래스를 구성한다.  

### 다형성  

다형성을 활용하면 일괄적으로 처리하면서도 개별적으로 적용할 수 있는 유연한 프로그래밍이 가능해진다.  

앞에서 나온 느슨한 커플링도 다형성이 적용된것 중 하나이며 그 외에도 다양하게 적용될 수 있는 개념이다.  


<br>

### 오버라이드  

상속받은 부모의 메서드를 그대로 사용할 수 도 있지만 자식이 재정의해서 사용할수도 있는데 이를 오버라이드라고 한다.

게임 속 모든 몬스터는 공격 기능의 기본 동작은 동일하지만 공격 대사는 다르게 구현한다고 가정해본다.  

```cs
public class Monster : MonoBehaviour {
    public virtual void Attack() {
        Debug.Log("Attack!");
    }
}

public class Orc : Monster {
    public override void Attack() {
        base.Attack();
        Debug.Log("lok'tar ogar!");
    }
}

public class Dragon : Monster {
    public override void Attack() {
        base.Attack();
        Debug.Log("fire breath!");
    }
}
```

virtual 키워드로 지정된 메서드는 가상 메서드가 된다. 가상 메서드는 자식 클래스가 오버라이드할 수 있도록 허용된 메서드이다. 자식 클래스는 override 키워드를 사용해 부모 클래스의 가상 메서드를 재정의할 수 있다.  

Orc 타입의 오브젝트를 Monster 타입의 변수에 저장하고 Attack() 메서드를 실행하면 로그는 Attack!과 lok'tar ogar!가 순서대로 출력되지만 실제로는 재정의한 메서드가 실행된다.  

오버라이드할 때는 부모 메서드의 원형을 유지하면서 확장할 수 있고 완전히 처음부터 메서드를 다시 만들 수도 있다. 

base.Attack()은 부모 클래스의 Attack() 메서드를 실행한다. base 키워드는 부모 클래스를 지칭하며, base를 사용해 오버라이드되기 전의 원형 메서드로 접근할 수 있다.  

<br>

### 오버라이드 활용  

느슨한 커플링과 메서드의 재정의를 통해서 상속받은 자식들을 일괄적으로 같은 동작을 실행 시킬 수 있다.  

```cs
Monster[] monsters = FindObjectsOfType<Monster>();
for (int i = 0; i < monsters.Length; i++) {
    monsters[i].Attack();
}
```

위 코드에서 monsters에는 상속받은 모든 자식들이 할당되며 어떤 타입이든지 각자가 재정의한 Attack() 메서드를 실행하게 된다.  