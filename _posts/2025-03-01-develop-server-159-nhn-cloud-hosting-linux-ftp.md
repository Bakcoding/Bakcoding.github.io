---
title: "[NHN Cloud Hosting - Linux] FTP 연결"
excerpt: "[NHN Cloud Hosting - Linux] FTP 연결"
categories:
  - Server
permalink: /develop/server/159-nhn-cloud-hosting-linux-ftp/
tags:
  - "Server"
  - "Linux"
  - "filezilla"
  - "ftp"
  - "php"
toc: true
toc_sticky: true
date: 2025-03-01
last_modified_at: 2025-03-01
source_url: https://b-note.tistory.com/159
---

<p>디렉터리 구조나 파일의 위치, 이동, 삭제 등을 좀 편하게 하기 위해서 FTP를 연결해 로컬에서 관리할 수 있도록 한다.</p>

<p>FTP 툴은 FileZilla를 사용한다.</p>

<p><a href="https://filezilla-project.org/" target="_blank" rel="noopener">FileZilla</a></p>

<p><figure class="imageblock alignCenter" data-ke-mobileStyle="widthOrigin" data-origin-width="810" data-origin-height="78"><span><img src="/assets/images/posts/2025/03/01/159-1.png" loading="lazy" width="810" height="78" data-origin-width="810" data-origin-height="78"/></span></figure>
</p>

<p>FileZilla를 실행하고 필요한 정보를 채운다.</p>

<p>호스트는 서버의 ip 주소, 사용자명과 비밀번호는 서버를 만들 때 입력했던 정보를 쓰면 된다.</p>

<p>포트는 FTP의 경우 기본적으로 21번 포트를 사용한다.</p>

<p>모든 정보를 입력하고 연결을 하면 디렉터리를 직관적으로 확인할 수 있다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="555" data-origin-height="332"><span><img src="/assets/images/posts/2025/03/01/159-2.png" loading="lazy" width="555" height="332" data-origin-width="555" data-origin-height="332"/></span></figure>
</p>

<p>이제 GUI로 계층 구조를 직관적으로 확인할 수 있다.</p>

<p>FTP 사용을 하게 되면 파일을 관리하기 위해서는 읽기 뿐만 아니라 쓰기 권한도 필요하다. 서버에서 생성했던 파일은 소유자와 그룹 모두 서버에서만 사용할 수 있는 상태인데 일단 test.php를 로컬에서 변경할 것 이기 때문에 이 파일의 권한 중 그룹을 변경하고 쓰기 권한도 추가해 본다.</p>

<p>일단 파일들이 계속 추가될 것을 대비해서 폴더를 세분화해 둔다.</p>

<p>dev 경로를 생성해서 release 루트와 구분되도록 한다.</p>

<pre class="bash"><code>$sudo mkdir /home/username/html/dev</code></pre>


<p>해당 경로로 test.php 이동</p>

<pre class="bash"><code>$sudo mv /home/username/html/test.php /home/username/html/dev/</code></pre>

<p>test.php 권한 수정</p>

<pre class="bash"><code>// 읽기/쓰기 권한 부여
sudo chmod 664 /home/username/html/dev/test.php
// 소유자 , 그룹 수정
sudo chown apache:username /home/username/html/dev/test.php</code></pre>


<p>php의 수정된 내용은 기존에 페이지가 열릴 때마다 테이블에 인서트 되던 것을 버튼 입력으로 처리 후 결괏값을 페이지에 반영하도록 수정했다.</p>

<pre class="bash"><code>&lt;?php
// MySQL Connection
$servername = "localhost";
$username = "name";
$password = "password";
$dbname = "testdb";

//conn
$conn = new mysqli($servername, $username, $password, $dbname);

//conn check
if ($conn-&gt;connect_error){
	die("Connection failed: " . $conn-&gt;connect_error);
}
echo "Connected successfully";

// data insert test (폼에서 제출 버튼 클릭 시 실행)
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $sql = "INSERT INTO users (username, email) VALUES ('testuser', 'test@example.com')";
    if ($conn-&gt;query($sql) === TRUE) {
        echo "New record created successfully&lt;br&gt;";

        // 테이블 데이터 출력
        echo "&lt;h3&gt;Users Table:&lt;/h3&gt;";
        $result = $conn-&gt;query("SELECT * FROM users");
        if ($result-&gt;num_rows &gt; 0) {
            echo "&lt;table border='1'&gt;&lt;tr&gt;&lt;th&gt;ID&lt;/th&gt;&lt;th&gt;Username&lt;/th&gt;&lt;th&gt;Email&lt;/th&gt;&lt;/tr&gt;";
            while($row = $result-&gt;fetch_assoc()) {
                echo "&lt;tr&gt;&lt;td&gt;" . $row["id"]. "&lt;/td&gt;&lt;td&gt;" . $row["username"]. "&lt;/td&gt;&lt;td&gt;" . $row["email"]. "&lt;/td&gt;&lt;/tr&gt;";
            }
            echo "&lt;/table&gt;";
        } else {
            echo "0 results";
        }
    } else {
        echo "Error: " . $sql . "&lt;br&gt;" . $conn-&gt;error;
    }
}

$conn-&gt;close();
?&gt;

&lt;!-- 폼 추가 --&gt;
&lt;form method="POST" action=""&gt;
    &lt;button type="submit"&gt;Submit&lt;/button&gt;
&lt;/form&gt;</code></pre>

<p>로컬에서 수정한 test.php를 ftp를 사용해서 파일을 덮어쓰기 해본다.</p>

<p>이전에는 권한이 없어서 해당 동작이 실패했지만 권한 수정 후 문제없이 동작이 실행되었고 서버에서 vim으로 파일을 열어 변경된 내용을 확인해 보면 잘 바뀐 것을 확인할 수 있다.</p>

<p>이제 수정된 test.php 페이지를 열어본다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="193" data-origin-height="81"><span><img src="/assets/images/posts/2025/03/01/159-3.png" loading="lazy" width="193" height="81" data-origin-width="193" data-origin-height="81"/></span></figure>
</p>

<p>&nbsp;submit 클릭 시</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="450" data-origin-height="285"><span><img src="/assets/images/posts/2025/03/01/159-4.png" loading="lazy" width="450" height="285" data-origin-width="450" data-origin-height="285"/></span></figure>
</p>

<p>FTP 연결까지 이상 없이 완료되었다.</p>
