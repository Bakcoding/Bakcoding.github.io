---
title:  "PHP header()"
excerpt: "php, header"

categories:
  - PHP
tags:
  - [php, eheader]

toc: true
toc_sticky: true
 
date: 2022-04-08 
last_modified_at: 2022-04-08
---

***

<br>

### 재정의

웹 개발을 할 때 경우에 따라서 서버의 기본 내용을 text, json, xml 등으로 유형을 재정의하여 내보내야 할 때가 있다. 

<br>

### header

```php
header(string $header, bool $replace = true, int $response_code = 0): void
```

* string

  송신하는 HTTP status 코드를 표시하거나 브라우저를 리다이렉트할 문자열

* replace

  이전에 송신된 비슷한 헤더를 바꿀지 아니면 같은 형식의 두번째 헤더를 추가할지를 지정


<br>

header() 함수는 원시 HTTP 헤더를 전송할 수 있다.

그리고 Content-Type 을 추가하여 브라우저에 전송하는 컨텐츠에 대해서 알릴 수 있다.

```php
<?php
  // 일반적인 텍스트 문서
  header("Content-Type: text/plain");
  echo "Hello World";
  // Hello World

  // JSON
  header("Content-Type: application/json");
  $data = ["response" => "Hello PHP!"];
  echo json_encode($data);
  // {"response":"Hello World"}
?>
```

<br>

### 매개변수

#### string

* HTTP status

  HTTP status 코드를 표시한다. 문자열 HTTP/로 시작하는 모든 헤더를 말하며 대표적으로 누란된 파일에 대한 요청을 처리하는데 사용된다.

  ```php
  <?php
    // 404 페이지 에러
    header("HTTP/1.1 404 Not Found");
  ?>
  ```

  <br>

* 브라우저 리다이렉트

  'Location : 헤더' 형식으로 쓴다.

  ```php
  <?php 
    header('Location: https://bakcoding.github.io');
  ?>
  ```

  리다이렉트 후 다음 코드는 실행되지 않는다.

#### replace

선택사항으로 디폴트 값은 true, false 인 경우 같은 타입의 복수 헤더를 강제적으로 생성한다. 즉 헤더가 이전에 송신된 비슷한 헤더를 바꿀지 또는 같은 형식의 두 번째 헤더를 추가할지를 지정한다.

```php
<?php 
  header("WWW-Authenticate: Negotiate");
  header("WWW-Authenticate: NTLM", false);
?>
```

<br>

#### http_response_code

HTTP response 코드를 강제적으로 지정하며 리턴하지는 않는다.

<br>

**주의할 점**

* php가 출력을 생성하기 이전에 header() 함수를 호출해야한다. 그렇지 않으면 웹 서버는 이미 헤더를 보냈기 때문에 에러가 발생한다.

* header의 출력은 서버에서 보낸 첫 번째 바이트여야 한다. 따라서 php 태그가 열리기 전에 공백이나 빈 줄이 없어야 한다. 

* 같은 이유로 php만 포함하는 파일이나 파일의 맨 끝에 있는 경우 php 닫기 태그를 생략하는 것이 좋다.

<br>

### 사용예시

#### 강제적으로 캐시 무효화

php 스크립트는 대부분 동적으로 html을 생성하는데 사용한다. 이럴때 서버와 클라이언트 브라우저 사이에 있는 브라우저 캐시나 프록시 캐시에 의해서 캐싱되는것을 방지해야한다.

```php
<?php 
  header("Cache-Control: no-cache");
  header("Pragma:no-cache");
  
  // 또는
  header("Expires: Mon, 26 Jul 1997 05:00:00 GMT"); // 과거의 날짜
  header("Last-Modified: " . gmdate("D, d M Y H:i:s");  // 항상 변경
  header("Cache-Control: no-cache, must-revalidate"); // HTTP/1.1
  header("Pragma: no-cache"); //HTTP/1.0
?>
```

<br>

#### 다운로드

사용자에게 데이터를 저장하라는 메시지를 표시하려면 생성된 PDF 파일과 같은 전송은 Content-Disposition 헤더를 사용하여 권장 파일 이름을 제공하고 브라우저에 강제로 저장 다이어로그를 표시한다.

```php
<?php
// 콘텐츠 타입 지정
header('Content-Type: application/pdf');
// 저장시 파일이름
header('Content-Disposition: attachment; filename="downloaded.pdf"');
// 원본 소스 파일
readfile('original.pdf');
?>
```

<br>

#### 다른 포트로 넘기기

기본 포트 80번이 아닌 다른 포트로 넘긴다.

예에서는 8080에 지정된 Web 사이트에 접근한다.

```php
<?php
  if ($_SERVER["SERVER_PORT"] == "80")  // 코드 최상단
  {
    header("Location : http://bakcoding.github.io:8080/");
  }
?>
```

<br>

#### charset 변경

```php
<?php
  header("Content-Type : text/html; charset=UTF-8");
  header("Content-Type : text/html; charset=euc-kr");
?>
```