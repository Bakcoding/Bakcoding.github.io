---
title:  "PHP 태그"
excerpt: "php, tag"

categories:
  - PHP
tags:
  - [php, tag]

toc: true
toc_sticky: true
 
date: 2022-04-08 
last_modified_at: 2022-04-08
---

***

<br>

### PHP 태그

php 코드를 작성할 때 여기서부터 php로 작성되었다는걸 알려주는 것이 필요하다.

그 방식에는 몇 가지가 있다.

<br>

#### XML

```php
<?php ~ ?>
```

가장 기본적인 방식으로 어떤 환경에서든 대부분 지원되기 때문에 일반적으로 권장되는 방식이다.

위 방식을 줄여서 쓰는것도 가능하지만

```php
<? ~ ?>
```

기본적으로 지원이 안되는 환경이 많기 때문에 권장되지 않는다.


<br>

#### Script

```html
<script language='php'> ~ </script>
```

JavaScript, VBScript 에서 사용되는 방식이다. HTML 편집기에서 다른 태그의 사용이 불가능할 경우에 사용된다.

<br>

#### ASP

```php
<% ~ %>
```

ASP나 ASPNET 에서 사용되는 방식이다. config 파일에서 asp_tags를 활성화하면 사용이 가능하다. ASP 편집기를 사용하는 것이 아니면 사용할 일이 없다.

<br>

### 기본 규칙

php 코드는 php 코드를 열어서 시작하고 끝날 때 닫아서 마침을 표시한다. 

php 태그 내에서 코드들은 세미콜론으로 문장의 끝을 구분한다. 마지막 문장이 세미콜론으로 끝나고 더 이상 코드가 없다면 php를 닫는 태그는 생략이 가능하다.

```php
<?php
  echo "No Error"; // 이렇게 끝나도 에러가 없다.
```

또한 마지막 문장은 php 태그를 닫는다면 세미콜론을 생략할 수 있다.

```php
<?php
  echo "No Error"
?>
```

생략이 가능하긴 하지만 일반적으로 모든 문장이 끝날 때 세미콜론을 붙이고 php가 끝날 때 닫아주는것을 권장한다.

