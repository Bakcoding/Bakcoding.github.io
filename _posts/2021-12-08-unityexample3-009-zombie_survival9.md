---
title:  "[레트로의 유니티] 좀비서바이벌9 - 이벤트"
excerpt: "unity3d, retro, example, zombie, event"

categories:
  - UnityExample
tags:
  - [unity3d, retro, example, zombie, event]

toc: true
toc_sticky: true
 
date: 2021-12-08 
last_modified_at: 2023-06-05
---  

***  

### 이벤트  

연쇄 동작을 이끌어내는 사건이다.  

이벤트 자체적으로는 기능을 하지 않지만 이벤트가 발생하면 이벤트를 구독하는 처리들이 연쇄적으로 실행된다.  

이벤트를 사용하면 어떤 클래스에서 특정 사건이 발생했을 때 다른 클래스에서 그것을 감지하고 관련된 처리를 실행하게 된다.  

이벤트를 구현할 때는 이벤트와 이벤트에 관심이 있는 이벤트 리스너로 오브젝트를 구분한다.  

![event](/assets/images/posting/20211208/event.png)  

c#에서 이벤트를 구현하는 대표적인 방법은 델리게이트를 클래스 외부로 공개하는 것이다.  

외부로 공개된 델리게이트는 클래스 외부의 메서드가 등록될 수 있는 명단이자 이벤트가 된다. 그리고 이벤트가 발동하면 이벤트에 등록된 메서드들이 모두 실행된다.  

여기서 이벤트를 항상 감지하고 있다가 이벤트가 신호를 보낼 때 실행되는 메서드들을 이벤트 리서너라고 하며 이벤트 리스너를 이벤트에 등록하는 것을 이벤트 리스너가 이벤트를 구독한다고 표현한다.

<br>

### 견고한 커플링 

이벤트는 자신을 구독하는 메서드의 구현과 상관없이 동작하므로 견고한 커플링 문제를 해소할 수 있다.  

>**견고한 커플링?**  
특정 클래스가 다른 클래스의 구현에 강하게 결합되어 코드를 유연하게 변경할 수 없는 상태를 말한다.  

```cs
public class Player : MonoBehaviour {
    public GameData gameData;
    public void Die() {
        // 실제 사망 처리
        gameData.Save();
    }
}
public class GameData : MonoBehaviour {
    public void Save() {
        Debug.Log("게임 저장");
    }
}
```

위 코드는 Player 클래스가 자신과 상관없는 GameData 클래스와 강하게 결합되어 있다.  

Player 클래스는 플레이어에 관한 기능만 처리하면 되므로 GameData 클래스의 기능이 필요하지 않지만 GameData클래스는 Player 클래스의 Die()가 발생할 때 Save()를 실행해야 하므로 Player 클래스에서 GameData 클래스에 관한 코드가 필요하게된다.  

여기서 Player 클래스에서 이벤트를 제공하는 방식으로 개선이 가능하다.  

```cs
public class Player : MonoBehaviour {
    public Action onDeath;
    public void Die() {
        onDeath();
    }
}
public class GameData : MonoBehaviour {
    void Start() {
        Player player = FindObjectOfType<Player>();
        player.onDeath += Save;
    }
    public void Save() {
        Debug.Log("게임 저장");
    }
}
```

변경한 코드는 Player 클래스가 GameData 타입의 오브젝트를 비롯해 자신의 사망 사건에 관심 있는 상대방 오브젝트를 파악할 필요가 없고 Player의 사망 사건에 관심 있는 오브젝트는 Player의 onDeath 이벤트를 구독하면 된다.

<br>

**event keyword**

델리게이트 타입의 변수는 event 키워드를 붙여 선언이 가능하고 어떤 델리게이트 변수를 event로 선언하면 클래스 외부에서는 해당 델리게이트를 실행할 수 없게 되어 이벤트를 소유하지 않은 측에서 멋대로 이벤트를 발동하는 것을 방지할 수 있다.  

```cs
public class Player : MonoBehaviour {
    public event Action onDeath;
    public void Die() {
        onDeath();
    }
}
public class GameData : MonoBehaviour {
    void Start() {
        Player player = FindObjectOfType<Player>();
        player.onDeath += Save;
        player.onDeath(); // 에러, Player 외부에서 이벤트 발동 불가능
    }

    public void Save() {
        Debug.Log("게임 저장");
    }
}
```



