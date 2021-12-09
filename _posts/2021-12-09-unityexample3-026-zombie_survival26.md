---
title:  "[레트로의 유니티] 좀비서바이벌25 - 네트워크 - 적 생성기"
excerpt: "unity3d, retro, example, zombie, multiplayer, photon"

categories:
  - UnityExample
tags:
  - [unity3d, retro, example, zombie, multiplayer, photon]

toc: true
toc_sticky: true
 
date: 2021-12-09 
last_modified_at: 2021-12-09
---  

***  

### Enemy Spawner

컴포넌트 추가

* Photon View

    Observed Components에는 EnemySpawner 스크립트가 추가된다. 


<br>

### EnemySpawner

MonoBehaviour 대신 MonoBehaviourPun, IPunObservable 를 상속받는다.

네트워크상에서 적을 생성하고 남은 적을 동기화한다.  

#### enemyCount 

남은 적과 현재 웨이브를 UI로 표시한다.

적은 enemies 리스트에 추가하여 등록된 수로 남은 적의 수를 알 수 있다.  

하지만 리스트에 생성한 적을 등록하는 절차는 호스트의 EnemySpawner 에서만 실행되고 다른 클라이언트에서는 실행되지 않는다.  

따라서 추가 변수 enemyCount를 선언하고 enemies.Count 값을 리모트의 enemyCount로 전달하는 방식을 통해 남은 적 수를 다른 클라이언트에서 알 수 있게 한다.  

즉 남은 적 수 enemyCount와 현재 웨이브 wave 값은 OnPhotonSerializeView() 메서드를 구현하여 동기화한다. 

<br>

#### OnPhotonSerializeView() 

Enemy Spawner 게임 오브젝트를 로컬로 가지고 있는 호스트에서는 enemies.Count를 남은 적 수를 파악하는데 사용 가능하지만 다른 클라이언트에서는 enemyCount를 대신 사용해야한다.  

```cs
// 주기적으로 자동 실행되는, 동기화 메서드
public void OnPhotonSerializeView(PhotonStream stream, PhotonMessageInfo info) {
    // 로컬 오브젝트라면 쓰기 부분이 실행됨
    if (stream.IsWriting)
    {
        // 적의 남은 수를 네트워크를 통해 보내기
        stream.SendNext(enemies.Count);
        // 현재 웨이브를 네트워크를 통해 보내기
        stream.SendNext(wave);
    }
    else
    {
        // 리모트 오브젝트라면 읽기 부분이 실행됨
        // 적의 남은 수를 네트워크를 통해 받기
        enemyCount = (int) stream.ReceiveNext();
        // 현재 웨이브를 네트워크를 통해 받기 
        wave = (int) stream.ReceiveNext();
    }
}
```

따라서 현재 웨이브와 남은 적 수를 표시하던 UpdateUI() 메서드도 다음과 같이 변경한다.  

<br>

#### UpdateUI()

```cs
// 웨이브 정보를 UI로 표시
private void UpdateUI() {
    if (PhotonNetwork.IsMasterClient)
    {
        // 호스트는 직접 갱신한 적 리스트를 통해 남은 적의 수를 표시함
        UIManager.instance.UpdateWaveText(wave, enemies.Count);
    }
    else
    {
        // 클라이언트는 적 리스트를 갱신할 수 없으므로, 호스트가 보내준 enemyCount를 통해 적의 수를 표시함
        UIManager.instance.UpdateWaveText(wave, enemyCount);
    }
}
```

호스트는 enemies.Count를 통해 갱신하고 다른 클라이언트들은 호스트가 보내준 enemyCount를 통해 갱신한다.

<br>

#### CreateEnemy()

네트워크상의 모든 클라이언트에서 같은 적을 생성해야한다.   

```cs
// 적을 생성하고 생성한 적에게 추적할 대상을 할당
private void CreateEnemy(float intensity) {
    // intensity를 기반으로 적의 능력치 결정
    float health = Mathf.Lerp(healthMin, healthMax, intensity);
    float damage = Mathf.Lerp(damageMin, damageMax, intensity);
    float speed = Mathf.Lerp(speedMin, speedMax, intensity);

    // intensity를 기반으로 하얀색과 enemyStrength 사이에서 적의 피부색 결정
    Color skinColor = Color.Lerp(Color.white, strongEnemyColor, intensity);

    // 생성할 위치를 랜덤으로 결정
    Transform spawnPoint = spawnPoints[Random.Range(0, spawnPoints.Length)];

    // 적 프리팹으로부터 적을 생성, 네트워크 상의 모든 클라이언트들에게 생성됨
    GameObject createdEnemy = PhotonNetwork.Instantiate(enemyPrefab.gameObject.name,
        spawnPoint.position,
        spawnPoint.rotation);
    
    // 생성한 적을 셋업하기 위해 Enemy 컴포넌트를 가져옴
    Enemy enemy = createdEnemy.GetComponent<Enemy>();

    // 생성한 적의 능력치와 추적 대상 설정
    enemy.photonView.RPC("Setup", RpcTarget.All, health, damage, speed,
        skinColor);

    // 생성된 적을 리스트에 추가
    enemies.Add(enemy);

    // 적의 onDeath 이벤트에 익명 메서드 등록
    // 사망한 적을 리스트에서 제거
    enemy.onDeath += () => enemies.Remove(enemy);
    // 사망한 적을 10 초 뒤에 파괴
    enemy.onDeath += () => StartCoroutine(DestroyAfter(enemy.gameObject, 10f));
    // 적 사망시 점수 상승
    enemy.onDeath += () => GameManager.instance.AddScore(100);
    }
```

CreateEnemy() 메서드에서 Instantiate()를 사용하여 enemyPrefab의 복제본을 생성하던 부븐을 PhotonNetwork.Instantiate()로 사용하도록 변경한다. 

생성한 적 enemy에서 Setup() 메서드를 실행하여 적의 능력치를 설정한다. 단 현재 호스트 로컬에서만 Setup()을 실행한 경우 다른 클라이언트에는 변경된 적의 능력치가 적용되지 않는다.  

따라서 호스트뿐만 아니라 모든 클라이언트에서 동시에 생성한 적의 Setup() 메서드를 원격 실행하여 모든 클라이언트가 동일한 적을 생성하도록 한다.  

마지막에 생성된 적이 사망할 경우 실행될 메서드를 등록한다. 

OnDeath 이벤트에 이벤트 리스너를 등록하는 위 코드는 호스트에서만 실행된다. 따라서 적 사망 시 사망한 적을 리스트에서 제거하고 사망한 적을 10초 뒤에 파괴하며 게임 매니저에 100점을 추가하는 처리는 호스트에서만 실행된다.  

게임 점수와 남은 적의 수는 호스트에서 변경시 자동으로 모든 클라이언트에도 반영이되지만 적이 파괴되는 처리는 자동 반영되지 않기 때문에 PhotonNetwork.Destroy()를 사용하여 모든적이 파괴되도록하고 지연시간을 적용시키기 위해 코루틴으로 한번 감싼다음 호출하는 방법을 사용한다.  

<br>

#### DestroyAfter()

```cs
// 포톤의 Network.Destroy()는 지연 파괴를 지원하지 않으므로 지연 파괴를 직접 구현함
IEnumerator DestroyAfter(GameObject target, float delay) {
    // delay 만큼 쉬고
    yield return new WaitForSeconds(delay);

    // target이 아직 파괴되지 않았다면
    if (target != null)
    {
        // target을 모든 네트워크 상에서 파괴
        PhotonNetwork.Destroy(target);
    }
}
```

<br>

#### Awake()

PUN은 RPC로 원격 실행할 메서드에 함께 첨부할 수 있는 입력 타입에 제약이 있으며 대표적으로 byte, bool, int, float, string, Vector3, Quaternion이 있다. 이들은 직렬화/역직렬화가 PUN에 의해 자동으로 이루어진다. 

Color 타입의 값은 RPC 메서드의 입력으로 첨부할 수 없기 때문에 CreateEnemy()메서드에서 Setup() 메서드의 RPC 실행에 Zombie의 색상인 skinColor를 입력으로 넘겨 줄 수 없다.  

하지만 기존에 RPC에서 지원하지 않는 타입을 직접 지원하도록 정의할 수 있다.  

```cs
void Awake() {
        PhotonPeer.RegisterType(typeof(Color), 128, ColorSerialization.SerializeColor,
            ColorSerialization.DeserializeColor);
    }
```

추상적인 오브젝트는 물리적인 통신 회선을 통해 그냥 전송할 수 없다. 따라서 오브젝트를 물리적인 회선으로 전송하려면 해당 오브젝트를 날것 그대로의 타입입 바이트 데이터로 변경해야한다.  

직렬화는 어떤 오브젝트를 바이트 데이터로 변환하는 처리이고 역직렬화는 바이트 데이터를 다시 원본으로 변환하는 처리이다.  

송신 측은 직렬화한 바이트 데이터로 변경하여 보내고 수신 측은 받은 바이트 데이터를 역직렬화해 원본 데이터로 복구한다.  

전달인자 값 중 128은 이미 등록된 다른 타입과 겹치지 않도록 무작위로 선택한 숫자이며 사용할 수 있는 커스텀 타입은 255개까지 등록가능하며 각각의 타입은 고유 번호를 할당 받아야한다. 


ColorSerialization.SerializeColor, ColorSerialization.DeserializeColor 메서드는 미리 구현해 놓은 메서드이다. 

Scritps > ColorSerialization

<br>

### ColorSerialization

```cs
using ExitGames.Client.Photon;
using UnityEngine;

public class ColorSerialization {
    public static byte[] SerializeColor(object targetObject) {
        Color color = (Color) targetObject;

        Quaternion colorToQuaterinon = new Quaternion(color.r, color.g, color.b, color.a);
        byte[] bytes = Protocol.Serialize(colorToQuaterinon);

        return bytes;
    }

    public static object DeserializeColor(byte[] bytes) {
        Quaternion quaterinon = (Quaternion) Protocol.Deserialize(bytes);

        Color color = new Color(quaterinon.x, quaterinon.y, quaterinon.z, quaterinon.w);

        return color;
    }
}
```

