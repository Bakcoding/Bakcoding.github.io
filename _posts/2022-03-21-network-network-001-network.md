---
title:  "네트워크 - 웹 브라우저"
excerpt: "Network, Web-browser, http"

categories:
  - Network
tags:
  - [Network, Web-browser, http]

toc: true
toc_sticky: true
 
date: 2022-03-21
last_modified_at: 2023-06-05
---  

***

<br>

### 네트워크

브라우저에서 웹 서버에 액세스한다고 할 때 전체적인 작동 모습은 다음과 같다.

![network](/assets/images/posting/20220321/network.png)
<br>

브라우저에서 데이터를 요청하면 웹 서버는 요청에 따라 결과를 브라우저로 보낸다.  

이 애플리케이션의 상호작용을 실현하기 위해서는 주고 받는 데이터를 운반하는 구조가 필요하다.

네트워크에는 수 많은 컴퓨터 등이 연결되어 있으므로 통신 상대를 정확하게 식별하고 데이터를 전송해야한다. 이 과정에서 리퀘스트나 응답이 삭제되거나 파괴될 수 있는 상황도 고려해야한다. 즉 어떠한 상황에서도 리퀘스트나 응답을 확실하게 상대에게 넘겨주는 구조가 필요하다. 

이 데이터는 모두 0과 1로 이루어진 디지털 데이터로 이 디지털 데이터를 목적지까지 운반하는 구조라 할 수 있다.

이 구조는 OS에 내장된 네트워크 소프트웨어나 스위치, 라우터같은 기기가 역할을 분담하며 실현된다. 여기에서 디지털 데이터를 작은 덩이리로 분할한 패킷이라는 형태로 운반한다. 

<br>

### 웹 브라우저

웹 브라우저와 네트워크가 상호작용하는 시작점은 URL을 입력하는 주소창이다. 여기에 입력된 URL을 해독하는 것으로 브라우저의 동작이 시작된다. 

<br>

### URL

Uniform Resource Locator

URL은 http://, file:, mailto: 등 다양한것으로 시작한다. 브라우저는 웹 서버에 엑세스하는 클라이언트로 사용하는 경우가 많지만 뿐만 아니라 파일의 다운로드/업로드하는 FTP(File Transfer Protocol) 클라이언트나 메일의 클라이언트 기능도 가지고 있다. 즉 브라우저는 몇 개의 클라이언트 기능을 겸비한 복합적인 클라이언트 소프트웨어라고 할 수 있다. 

<br>

URL에는 서버의 도메인명이나 액세스하는 파일의 경로 등을 포함시키며, 메일의 경우 보내는 상대의 메일 주소를 포함시키는 방식이다. 필요에 따라 사용자명이나 패스워드, 서버의 포트 번호 등을 쓸 수도 있다.

이처럼 다양한 방법으로 사용되지만 모든 URL의 공통점은 맨 앞에 문자열인 http:, ftp:, file; 등의 부분에서 액세스하는 방법을 나타낸다는 점이다. 액세스 대상이 웹 서버라면 HTTP 프로토콜을 사용하고, FTP 서버라면 FTP 프로토콜을 사용한다. 즉 URL의 가장 앞 문자열은 액세스할 프로토콜의 종류가 작성된다. 

```cmd
// 프로토콜, 사용자명, 패스워드, 웹 서버의 도메인, 포트 번호, 파일 경로
http://user:password@www.cyber.co.kr:80/dir/file.html

// 프로토콜, 사용자명, 패스워드, FTP 서버의 도메인, 포트 번호, 파일 경로
ftp://user:password@ftp.cyber.co.kr:21/dir/file.html
```

<br>

브라우저가 가장 처음 하는 일은 웹 서버에 보내는 리퀘스트의 메시지를 작성하기 위해 URL을 해독하는 것이다. 

*   http:

    URL의 맨 앞, 데이터 출처에 액세스하는 방법 즉 프로토콜을 기록

*   //

    뒤에 이어지는 문자열이 서버의 이름임을 나타낸다.

*   <a style="color:black">www.cyber.co.kr</a>

    웹 서버의 이름을 나타낸다.

*   /dir/file.html

    데이터 출처의 경로를 나타내며 생략이 가능하다. URL 마지막이 /로 끝나는 경우 생략된걸 의미한다.

데이터 경로를 생략하게 되면 어떤 파일에 액세스해야할지 모르기 때문에 이에 대비해서 서브측에 미리 설정을 한다. 이 설정은 서버에 따라 다르지만 대부분의 서버가 index.html 또는 default.html 이라는 파일명으로 설정한다. 

<br>

### HTTP

HTTP 프로토콜은 클라이언트와 서버가 주고받는 메시지의 내용이나 순서를 정한 것이다. 

클라이언트에서 서버를 향해 보내지는 리퀘스트 메시지의 안에는 '무엇을' '어떻게' 하겠다는 내용이 담겨있다. 여기서 '무엇을' 에 해당하는 것을 URI(Uniform Resource Identifier)라고 하는데 보통 페이지 데이터를 저장한 파일의 이름이나 CGI 프로그램의 파일명을 사용하거나 http:로 시작하는 URL을 그대로 쓸 수도 있다. 이러한 액세스 대상을 통칭하는 말이 URI이다.

*   CGI 프로그램

    웹 서버 소프트웨어에서 프로그램을 호출할 때의 규칙을 정한것이 CGI이며 CGI의 규칙에 맞게 움직이는 프로그램을 CGI 프로그램이라고 한다.

'어떻게'에 해당하는 것은 메서드이다. 이 메서드에 의해 웹 서버에 어떤 동작을 하고 싶은지를 전달한다. URI로 나타낸 데이터를 읽거나 클라이언트측에서 입력한 데이터를 전달하고 싶다는 식의 동작이 대표적이다. 

|메서드|의미|
|----|----|
|GET|URI로 지정한 정보를 도출한다. 파일의 경우 해당 파일의 내용을 되돌려 보내고 CGI 프로그램의 경우 해당 프로그램의 출력 데이터를 그대로 반송한다.|
|POST|클라이언트에서 서버로 데이터를 송신한다. 폼에 입력한 데이터를 송신하는 경우에 사용한다.|
|HEAD|GET과 거의 동일하다. 단 HTTP 메시지 헤더만 반송하고 데이터의 내용을 돌려보내지 않는다. 파일의 최종 갱신 일시와 같은 속성 정보를 조사할 때 사용한다.|
|OPTIONS|통신 옵션을 통지하거나 조사할 때 사용한다.|
|PUT|URI로 지정한 서버의 파일을 치환한다. URI로 지정한 파일이 없는 경우에는 새로 파일을 작성한다.|
|DELETE|URI로 지정한 서버의 파일을 삭제한다.|
|TRACE|서버측에서 받은 리퀘스트 라인과 헤더를 그대로 클라이언트에 반송한다. 프록시 서버 등을 사용하는 환경에서 리퀘스트가 치환되는 상태를 조사할 때 사용한다.|
|CONNECT|암호화된 메시지를 프록시로 전송할 때 이용하는 메소드이다.|

<br>

*   헤더 파일 

    보충 정보를 나타낸다.


웹 서버에 도착한 리퀘스트 메시지가 해독된 후 결과 데이터를 응답 메시지에 저장한다. 응답 메시지의 맨 앞부분에는 실행 결과가 정상 종료되었는지 또는 이상이 발생했는지를 나타내는 스테이터스 코드가 있으며 대표적으로 액세스할 파일이 발견되지 않을 때 뜨는 404 Not Found가 있다.

헤더 파일과 페이지의 데이터가 이어지면 이 응답 메시지를 클라이언트에 반송한다. 그러면 클라이언트에 도착하고 브라우저가 메시지의 안에서 데이터를 추출하여 화면에 표시하면서 HTTP의 동작이 끝난다.

<br>

#### 리퀘스트 메시지

```c
<메서드><공백><URI><공백><HTTP 버전>    // 리퀘스트 라인
// *********
<필드명>:<필드값>
.
.                   //  메시지 헤더
.
// *********
<공백 행>
<메시지 본문>   //  메시지 본문
```

*   리퀘스트 라인

    한 행으로 리퀘스트의 대략적인 내용을 알 수 있다.

*   메시지 헤더

    한 행에 한 개의 헤더 필드를 쓴다. 리퀘스트의 부가적인 정보를 나타내며 행 수는 상황에 따라 달라진다.

*   메시지 본문

    클라이언트에서 서버에 송신하는 데이터이다.

<br>

메시지 헤더를 쓰면 그 뒤에 아무 것도 쓰지 않은 하나의 공백 행을 넣고 그 뒤에 송신할 데이터를 쓴다. 이 부분을 메시지 본문이라 하며 이것이 메시지의 실제 내용이 된다. 단 메소드가 GET인 경우에는 메소드와 UIR만으로 웹 서버가 무엇을 할지 판단할 수 있으므로 메시지 본문에 쓰는 송신 데이터는 없다.  따라서 메세지 헤더가 끝난 곳에서 메시지는 끝난다.

<br>

#### 응답 메시지

```c
<HTTP 버전><공백><스테이터스 코드><공백><응답 문구> // 스테이터스 라인
// *********
<필드명>:<필드값>
.
.                   // 메시지 헤더
.
// *********
<공백 행>
<메시지 본문>   // 메시지 본문
```

*   스테이터스 라인

    코드의 내용을 나타내는 짧은 설명이다.

*   메시지 본문

    서버에서 클라이언트에 송신하는 데이터이다. 파일에서 읽은 데이터나 CGI 애플리케이션이 출력한 데이터가 들어간다.


<br>

응답의 경우 정상 종료했는지 오류가 발생했는지 실행 결과를 나타내는 스테이터스 코드와 응답 문구를 첫 번째 행에 써야 한다. 

스테이터스 코드는 숫자로 쓴 것이며 주로 프로그램 등에 실행 결과를 알려주는 것이 목적이고 응답 문구는 문장으로 쓰여있으며 사람이 알아볼 수 있게 하는것이 목적이다.

응답 메시지가 되돌아오면 그때부터 데이터를 추출한 후 화면에 표시하여 웹 페이지를 볼 수 있게 된다.

|코드값|설명|
|----|----|
|1xx|처리의 경과 상황 등을 통지한다.|
|2xx|정상 종료|
|3xx|무언가 다른 조치가 필요함을 나타낸다.|
|4xx|클라이언트측의 오류|
|5xx|서버측의 오류|


리퀘스트 메시지에 쓰는 URI는 한 개만으로 결정되어 있으므로 파일을 한번에 한 개씩만 읽을 수 있기 때문에 파일을 따로따로 읽어야한다. 만약 한 문장에 3개의 영상이 포함되어 있다면 문장 파일을 읽는 리퀘스트와 영상 파일을 읽는 리퀘스트로 총 4회 리퀘스트 메시지를 웹 서버에 보낸다.

필요한 파일을 판단하고 해독한 후 레이아웃을 정하여 홤ㄴ에 표시하는 상태로 전체의 동작을 조정하는 것도 브라우저의 역할이다.

<br>

#### 헤더 필드

|헤더 필드의 종류|설명|
|----|----|
|제너럴 헤더|리퀘스트와 응답 양쪽에 모두 사용하는 헤더 필드|
|Date|리퀘스트나 응답이 작성된 날짜를 나타낸다.|
|Pragma|데이터의 캐시를 허용할지의 여부를 나타내는 통신 옵션을 지정한다.|
|Cache-Control|캐시를 제어하기 위한 정보|
|Connection|응답 송신 후에 TCP에 계속 접속할지, 아니면 연결을 끊을지를 나타내는 통신 옵션을 지정한다.|
|Transfer-Encoding|메시지 본문의 인코딩 방식을 나타낸다.|
|Via|도중에 경유한 프록시나 게이트웨이를 기록한다.|
|리퀘스트 헤더|리퀘스트의 부가 정보로 사용하는 헤더 필드|
|Authorization|사용자 인증용 데이터|
|From|리퀘스트 발신자의 메일 주소|
|If-Modified-Since|지정한 날짜 이후 정보가 갱신된 경우에만 리퀘스트를 실행하려고 필드값으로 이 날짜를 지정한다. 보통 클라이언트측에서 캐시에 저장한 정보를 비교하고 이것이 오래된 경우에 새 정보를 받으려고 할 때 사용한다.|
|Referer|하이퍼링크를 거쳐 어느 페이지를 읽은 경우 등에 링크 대상인 URI를 나타낸다.|
|User-Agent|클라이언트 소프트웨어의 명칭이나 버전에 관한 정보|
|Accept|클라이언트측이 Content-Type으로 받는 데이터의 종류, MIME 사양의 데이터 타입으로 표현한 것이다.|
|Accpet-Charset|클라이언트측이 받은 문자 코드 세트|
|Accept-Encoding|클라이언트측이 Content-Encoding으로 받은 인코딩 방식, 보통 데이터 압축 형식을 나타낸다.|
|Accept-Language|클라이언트측이 받는 언어의 종류, 한국어는 ko, 영어는 en이다.|
|Host|리퀘스트를 받는 서버의 IP 주소와 포트 번호|
|If-Match|Etag 참조|
|If-None-Match|Etag 참조|
|If-Unmodified-Since|지정한 날짜 이후 갱신되지 않은 경우에만 리퀘스트를 실행한다.|
|Range|데이터의 전체가 아니라 일부만 읽을 때 해당 범위를 지정한다.|
|응답헤더|응답의 부가 정보로 사용되는 헤더 필드|
|Location|정보의 정확한 장소를 나타낸다. 리퀘스트의 URI가 상대 이름(relative name)으로 지정된 경우 절대 이름으로 했을 때의 정보의 위치를 통지하기 위해 사용한다.|
|Server|서버 소프트웨어의 명칭이나 버전에 관한 정보|
|WWW-Authenticate|리퀘스트한 정보에 대한 액세스가 제한되어 있는 경우 사용자 인증용 데이터를 반송한다.|
|Accept-Ranges|데이터의 일부만 리퀘스트하는 Range를 지정한 경우 서버가 해당 기능을 가지고 있는지의 여부를 클라이언트에 통지한다.|
|엔티티 헤더|엔티티(메시지 본문)의 부가 정보로 사용하는 헤더 필드|
|Allow|지정한 URI로 사용 가능한 메서드를 나타낸다.|
|Content-Encoding|메시지 본문에 압축 등의 인코딩 처리가 되어 있는 경우 해당 방식을 나타낸다.|
|Content-Length|메시지 본문의 길이를 나타낸다.|
|Content-Type|메시지 본문이 어떤 데이터인지 종류를 나타낸다. MIME 사양으로 정의된 데이터 타입으로 데이터의 종류를 나타낸다.|
|Expires|메시지 본문의 유효 기간을 나타낸다.|
|Last-Modified|정보를 최종 변경한 일시|
|Content-Language|메시지 본문의 언어를 나타낸다. 한국어의 경우 ko, 영어의 경우 en이다.|
|Content-Location|메시지 본문이 서버의 어디에 놓여 있는지 위치를 URI로 나타낸다.|
|Content-Range|데이터의 전체가 아니라 일부가 리퀘스트된 경우 메시지 본문에 어느 범위의 데이터가 포함되어 있는지를 나타낸다.|
|Etag|갱신 처리 등에서 이전 리퀘스트의 응답을 바탕으로 한 갱신 데이터를 다음 리퀘스트에서 송신하는 경우가 있는데 이때 이전 응답과 다음 리퀘스트를 관련시키기 위해 사용하는 정보이다. 이전 응답에서 서버가 Etag에 따라 고유한 값을 클라이언트에 건네주고 다음 번 리퀘스트의 If-Match, If-None-Match, If-Range 필드에서 값을 서버에 통지하면 서버는 이전 회의 계속이라고 인식한다. 쿠키라는 필드와 역할이 같은데 쿠키는 넷스케이프의 독자적인 사양이며 Etag는 이것을 표준화한 것이다.

<br>


