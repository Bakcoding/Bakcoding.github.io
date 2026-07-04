---
title: "[NHN Cloud Hosting - Linux] php 테스트"
excerpt: "[NHN Cloud Hosting - Linux] php 테스트"
categories:
  - Server
permalink: /develop/server/155-nhn-cloud-hosting-linux-php/
tags:
  - "Server"
  - "Linux"
  - "php"
  - "vim"
toc: true
toc_sticky: true
date: 2025-03-01
last_modified_at: 2025-03-01
source_url: https://b-note.tistory.com/155
---

<p>이번에는 test.php 파일을 만들어서 잘 동작하는지 테스트해본다.</p>

<p>먼저 리눅스에서 텍스트 파일을 사용하기 위해서 텍스트 편집기가 필요한데 일반적으로 vim이나 nano를 사용한다.</p>

<p>vim이 좀 더 복잡하지만 기능이 많고 nano가 더 단순하면서 간단하게 쓰는 도구라고 하는데&nbsp;</p>

<p>일단 서버에 깔려있는 건 vim이라서 그대로 vim을 쓰기로 한다.</p>

<p>vim 버전확인</p>
<pre class="bash"><code>vim --version</code></pre>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="539" data-origin-height="81"><span><img src="/assets/images/posts/2025/03/01/155-1.png" loading="lazy" width="539" height="81" data-origin-width="539" data-origin-height="81"/></span></figure>
</p>

<p>파일을 생성하기 위해서는 경로가 필요한데 생각해 보니 아직 리눅스 서버의 폴더 구조를 모른다.</p>

<p>일단 폴더가 뭐가 있는지 확인해 본다.</p>

<pre class="bash"><code>ls /</code></pre>

<p>ls 명령어는 자주 사용되는 것 중 하나로 list를 의미한다.</p>

<p>리눅스의 ls는 디렉터리 내의 파일과 폴더 목록을 나열하는 데 사용되며 / 를 통해서 루트 디렉터리에서 목록을 나열해 본다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="464" data-origin-height="29"><span><img src="/assets/images/posts/2025/03/01/155-2.png" loading="lazy" width="464" height="29" data-origin-width="464" data-origin-height="29"/></span></figure>
</p>

<p>- bin : 시스템 부팅 및 작업에 필수적인 명령어들이 위치한다.&nbsp;</p>
<p>- dev : 하드웨어 장치와 관련된 파일들이 들어 있다.</p>
<p>- home : 일반 사용자 계정의 홈 디렉터리가 위치한다. 각 사용자의 개인 디렉토리</p>
<p>- lib64 : 64비트 시스템 및 프로그램에 필요한 라이브러리&nbsp; 위치</p>
<p>- mnt : 일반적으로 임시로 다른 파일 시스템을 마운트 하는 디렉터리</p>
<p>- proc : 가상 파일 시스템으로, 시스템 상태나 프로세스 정보를 제공</p>
<p>- run : 시스템의 현재 실행 중인 프로세스와 관련된 정보가 저장</p>
<p>- srv : 서버가 제공하는 서비스에 관련된 데이터를 저장 (웹 서버, FTP 서버 등)</p>
<p>- tmp : 임시 파일들이 저장되는 경로, 시스템이 재부팅되면 지워진다.</p>
<p>- var : 로그 파일, 캐시 파일, 스풀 파일 등 변동하는 데이터가 저장되는 경로</p>
<p>- boot : 커널 파일 및 부트로더 관련 파일이 있다.</p>
<p>- etc : 시스템 설정 파일들이 모여 있는 경로이며 네트워크 설정, 사용자 설정 등이 포함된다.</p>
<p>- lib : 32비트 프로그램 실행에 필요한 필수적인 라이브러리 파일</p>
<p>- media : usb 드라이브나 cd/dvd 등 이동식 미디어 장치가 마운트 되는 곳</p>
<p>- opt : 추가적인 소프트웨어 패키지들이 설치되는 디렉터리</p>
<p>- root : 시스템의 루트 사용자 홈 디렉토리</p>
<p>- sbin : 시스템 관리자용 명령어들이 위치하는 경로</p>
<p>- sys : 시스템 관련 정보를 제공하는 가상 파일 시스템</p>
<p>- usr : 사용자 프로그램과 관련된 파일들이 위치로 프로그램, 라이브러리, 문서 등이 포함</p>

<p>Apache 웹 서버의 경우 보통 /var/www/html/ 경로에서 파일을 처리한다고 하는데 먼저 이 경로에서 파일을 만들고 테스트했을 파일을 못 찾는 문제가 있었다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-filename="image.png" data-origin-width="468" data-origin-height="149"><span><img src="/assets/images/posts/2025/03/01/155-3.png" loading="lazy" width="468" height="149" data-filename="image.png" data-origin-width="468" data-origin-height="149"/></span></figure>
</p>

<p>어떤 문제인지 찾아보면서 Apache 설치와 실행 상태, 찾으려는 파일의 디렉터리 권한도 변경해보고 했지만 해결이 안 되었다.</p>

<p>그리고 Apache 로그를 조회해 보았는데 경로에 문제가 있었다는 걸 알게 되었다.</p>

<pre class="bash"><code>$sudo tail -f /var/log/httpd/error_log</code></pre>

<p>/var/www/html/ 가 아닌 /home/bakcoding/html/ 에서 test.php 파일을 찾고 있어서 Not Found 에러가 뜬 것</p>

<p>서버 환경이나 세팅에 따라서 달라지는 부분인가 보다.</p>

<p>처음부터 에러 로그를 찾았다면 더 빨리 해결됐을 문제였다.</p>

<p>이제 정확한 경로를 알게 됐으니 다시 파일 생성으로 돌아간다.</p>

<p>vim을 사용해서 파일을 생성해 보기로 한다.</p>

<pre class="bash"><code>$sudo vim /home/username/html/index.php</code></pre>

<p>sudo는 Super Do로 이걸 붙이면 관리자 권한으로 실행과 마찬가지로 볼 수 있다.</p>

<p>권한에 따라 sudo 없이 vim만 실행하면 파일을 열어볼 수 만 있으므로 sudo를 붙여서 명령어를 실행해 준다.</p>

<p>위 명령어를 실행하면 파일이 있는 경우 해당 파일이 열리고 없으면 새로 생성되면서 콘솔창이 vim 창으로 바뀐다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="645" data-origin-height="382"><span><img src="/assets/images/posts/2025/03/01/155-4.png" loading="lazy" width="404" height="239" data-origin-width="645" data-origin-height="382"/></span></figure>
</p>

<p>이 상태에서는 특정 키워드를 입력하면 동작으로 이어지게 되는데 먼저 파일을 작성할 때는 명령어 입력 상태에서 i를 입력하면 된다.</p>

<p>그리고 php 내용을 채워주는데 간단하게 db에 연결하고 성공과 실패 시 리턴 그리고 테이블에 값도 넣어보도록 한다.</p>

<pre class="php"><code>&lt;?php
// MySQL Connection
$servername = "localhost";
$username = "userid";
$password = "password";
$dbname = "testdb";

//conn
$conn = new mysqli($servername, $username, $password, $dbname);

//conn check
if ($conn-&gt;connect_error){
        die("Connection failed: " . $conn-&gt;connect_error);
}
echo "Connected successfully";

// data insert test
$sql = "INSERT INTO users (username, email) VALUES ('testuser', 'test@example.com')";
if ($conn-&gt;query($sql) === TRUE){
        echo "New record created successfully";
} else{
        echo "Error: " . $sql . "&lt;br&gt;" . $conn-&gt;error;      
}
$conn-&gt;close();
?&gt;</code></pre>

<p>이렇게만 해놓고&nbsp;</p>

<p>이제 http://내 서버 주소/test.php를 주소창에 입력했을 때 아무 문제가 없다면 성공했다는 텍스트가 뜨고 db에 값이 제대로 들어가 있는지 보면 된다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="488" data-origin-height="58"><span><img src="/assets/images/posts/2025/03/01/155-5.png" loading="lazy" width="488" height="58" data-origin-width="488" data-origin-height="58"/></span></figure>
</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="320" data-origin-height="120"><span><img src="/assets/images/posts/2025/03/01/155-6.png" loading="lazy" width="320" height="120" data-origin-width="320" data-origin-height="120"/></span></figure>
</p>

<p>php 테스트 일단은 문제가 없는 것으로 보인다.</p>
