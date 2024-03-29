---
title:  "Cocos2d-x 4.0 시작하기"
excerpt: "cocos, 2dx, 4.0, python"

categories:
  - Cocos
tags:
  - [cocos, 2dx, python]

toc: true
toc_sticky: true
 
date: 2021-08-19
last_modified_at: 2023-06-04
---  

***

### cocos2d-x
멀티 플랫폼을 지원하는 프레임워크이다. 이름이 2d가 들어가다 보니 3d는 지원을 안하겠구나 생각이 들지만 3.0버전부터 3d가 추가되었다.

장점
* 작은 용량으로 게임 개발에 필요한 대부분의 기능을 제공한다.
* 오픈소스로 무료로 이용이 가능하다.
* 최적화가 잘되어 있어 속도가 빠르다.
* 멀티 플랫폼을 지원한다.

단점
* 에디터 없이 코드로 모든 작업이 이루어진다.
* 자료의 양이 적은 편이고 한국어 자료는 더 없다.
* 3d 작업의 난이도가 있다. 

cocos는 에디터가 지원되는 cocos creater가 개발되면서  cocos2d의 업데이트는 더이상 이루어지고 있지 않다.  


그래도 개발 언어가 c++이고 코드를 작성할게 많기 때문에 공부하는데 많은 도움이 될거라 생각한다.  

<br/>

### 설치하기
cocos2d를 실행하기 앞서 몇 가지 준비물이 필요하다.  

<br/>

### 1. 비주얼스튜디오를 설치 해준다.  
[visual studio](https://visualstudio.microsoft.com/ko/vs/whatsnew/) 버전은 최신버전으로 해준다. 

<br/>

### 2. python 설치  
cocos2dx는 파이썬을 기반으로 만들어진 프레임워크이기 때문에 기본적으로 python 설치가 필요하다. 주의할 점은 cocos2dx에서 사용된건 python2이기 때문에 2.x 버전 중 가장 높은걸로 운영체제에 맞춰서 설치해 준다.  

[python 2.7.18](https://www.python.org/downloads/release/python-2718/) 작성일 기준 최신버전

python 설치가 끝났다면 환경 변수 설정이 필요하다. 

 ![environment_setting](/assets/images/posting/20210819/environment_setting.png)

리스트에 위 처럼 추가되었다면 제대로 설치되었는지 확인하기 위해 프롬프트 창을 켜서 명령어를 입력한다.  
  ```cmd
  cd c:\    --python설치된 경로로 이동, 기본적으로 c:\에 설치됨 
  python    --python 실행
  ```

 ![check_python_install](/assets/images/posting/20210819/check_python_install.png)

실행 결과 위와 같다면 성공적으로 설치가 완료된것이다.

만약 명령어를 실행시키지 못한다면 환경변수가 제대로 적용이 제대로 안됐을 수 있다. python의 설치 경로를 확인하고 올바르게 환경변수에 경로가 등록되었는지 확인해 볼 필요가 있다. 

만약 위 경우가 아니라면 직접 겪었던 문제 중 c드라이브 권한 문제 때문에 접근이 안됐던 상황이 있었다. 컴퓨터 로그인시 관리자 권한이 있는 계정으로 접속했는지 확인을 해본다.

<br/>

### 3. CMake 설치  
CMake는 makefile 즉, 빌드 스크립트를 만들어주는 툴로 이 툴을 사용해서 cocos2d 솔루션 파일을 만들어 사용한다.  

makefile은 incremental build 방식을 사용하는데 이 방식은 규모가 큰 프로젝트를 처음에 모두 빌드한 다음 이후에는 수정된 파일에 대해서는 그와 연관된 것들만 빌드하여 빌드 시간을 줄여준다.
    
[CMake](https://cmake.org/download/) 버전은 3.1 이상이 요구되므로 최신버전으로 설치해주면 된다.

설치를 진행하다보면 환경 설정에 대한 선택창이 나온다.  

 ![python](/assets/images/posting/20210819/install_cmake.png)

<br/>

### 4. Cocos2d 설치  

[Cocos2d-x 4.0](https://www.cocos.com/en/)를 설치해준다.  

명령 프롬프트 창에서 작업이 필요하기 때문에 설치 경로는 c드라이브로 해주는 것이 편하다.  

설치가 끝나고 폴더를 열어 확인해보면 setup.py가 보인다. 이 파일을 설치하기 위해서 python이 필요했던 것이다.

* cocos2d-x-4.0 설치  
  명령 프롬프트 창을 켜고 cocos2d-x-4.0 폴더로 이동하고 해당 설치 파일을 실행 시켜준다.

    ```cmd
    cd cocos2d-x-4.0    --설치된 경로로 이동
    python setup.py     --파일을 python으로 실행
    ```

  ![install_cocos2dx_framework](/assets/images/posting/20210819/install_cocos2dx_framework.png)

  중간에 SDK, NDK 경로에 대해서 묻는데 엔터로 스킵해준다.  

  이제 cocos2d-x-4.0의 설치는 끝났고 프로젝트를 생성하는 일만 남았다.  

* 프로젝트 생성  

    ```cmd
    cd c:\     --생성할 위치로 이동, 찾기 쉬운 곳으로
    cocos new HelloCocos -p com.bakcoding -l cpp --새 프로젝트 생성
    ```
  ![create_project](/assets/images/posting/20210819/create_project.png)

  **HelloCocos** 부분에 원하는 이름으로 작성한다.
        
  **-p com.pjy.hello**는 패키지명을 만드는 부분으로 생략해도 무방하다. 패키지명은 프로그램이 업데이트가 될 때 이미 설치된 경우 패키지명을 보고 찾아가서 갱신시킬 수 있는 역할을 한다. 보통 -p com.회사명.프로젝트명 으로 만들어지는데 폰으로 게임을 받아서 파일관리자로 경로를 찾아가보면 위 와 같은 파일명을 볼 수 도 있을 것이다. 

  **-l cpp**는 언어를 선택하는 것으로 반드시 써주어야한다.  

  해당 경로에 가보면 HelloCocos 폴더가 생성된걸 볼 수 있다. 하지만 폴더를 열어봐도 프로젝트를 열만한 파일이 보이지 않는다. 여기서 CMake로 솔루션 파일을 생성해 주는 과정이 필요하다.

* 솔루션 생성  
  다시 명령 프롬프트 창으로 돌아가서 HelloCocos 폴더로 이동한 다음 관리를 편하게 하기 위해서 폴더를 하나 생성해 준 다음 그 안에서 솔루션 생성을 진행한다.  

    ```cmd
    cd HelloCocos   --HelloCocos 폴더로 이동
    md win32-build  --win32-build 폴더 생성
    cd win32-build  --win32-build 폴더로 이동
    cmake .. -G"Visual Studio 16 2019" -A win32
    ```
  ![create_project_complete](/assets/images/posting/20210819/create_project_complete.png)

  **cmake ..**  현재 폴더에서 상위 폴더인 HelloCocos에 있는 CMakeLists.txt를 참조하여 makefile을 생성한다.  
        
  **-G"Visual Studio 16 2019"** G는 generator로 무엇으로 구동할 것인지 정하는 것이다. Visual Studio로 실행할 것이고 설치된 버전과 년도를 확인하여 입력해준다.  
        
    **-A win32** 프로젝트에서 사용될 플랫폼 이름(architecture)을 명시한다. 32bit 작업할 것이기 때문에 win32로 해준다.

<br/>

### 실행

솔루션 파일을 실행시켜서 기본적인 세팅과 테스트를 해본다.

![projcet_solution](/assets/images/posting/20210819/projcet_solution.png)


cocos의 기능들이 포함된 비주얼스튜디오가 열린다. 

많은 파일들이 보이는데 이 상태로 빌드를 돌리면 시간이 오래걸리게 되므로 빌드할 프로젝트를 설정해준다.

![set_as_startup_project](/assets/images/posting/20210819/set_as_startup_project.png)

세팅을 하고 나서 빌드를 돌려보면

![project_result](/assets/images/posting/20210819/project_result.png)

기본값으로 세팅되어있는 cocos2d의 창이 뜨는걸 확인할 수 있다. 

cocos2d를 사용할 준비가 완료된 상태로 이제 코드를 작성하여 게임을 만들 수 있다.