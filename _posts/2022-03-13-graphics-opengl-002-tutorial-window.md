---
title:  "OpenGL tutorial #1 창띄우기"
excerpt: "Graphics, OpenGL"

categories:
  - OpenGL
tags:
  - [Graphics, OpenGL]

toc: true
toc_sticky: true
 
date: 2022-03-13
last_modified_at: 2022-03-13
---  

***

<br>

## OpenGL 튜토리얼 

<a href="http://www.opengl-tutorial.org/kr/beginners-tutorials/tutorial-1-opening-a-window/">OpenGL Tutorial</a>


### 창띄우기


#### 의존성 

먼저 의존성을 짚고간다. 의존성이란 코드에서 두 모듈, 라이브러리 등이 서로 연결된 관계를 말한다.
콘솔에 메시지를 띄우기 위해서는 몇 가지 기본적인 것들이 필요하다.

C언어를 사용하기 위해서 표준 헤더를 포함시킨다.

```c
// Include standard headers
#include <stdio.h>
#include <stdlib.h>
```

<br>

#### GLEW 라이브러리

GLEW 라이브러리 포함, OpenGL Extension Wrngler Library로 크로스 플랫폼 오픈소스 C/C++ 확장 라이브러리이다.
OpenGL의 새로운 기능을 제공하는 헤더파일로 기본적으로 제공하는 기능들이 아니기 때문에 모든 환경에서 잘 작동한다는 보장은 없지만
상당히 유용한 기능들을 제공하고 있다.

사용하는 가장 큰 이유는 OpenGL은 하나의 라이브러리가 아니기 때문에 프로젝트에 간단하게 연결시킬 수 없다.
GLEW를 사용하면 glew.h와 같은 헤더파일 include하는것만으로 OpenGL의 기능들을 쉽게 사용할 수 있게된다.

<a href="http://glew.sourceforge.net/index.html">GLEW</a>

```c
// Include GLEW
#include <GL/glew.h>
```

<br>

#### GLFW 라이브러리

OpenGL은 라이브러리를 구현할 때 플랫폼에 따른 종속성을 배제하기 위해서 UI와 Context를 위한 API는 제외하고
구현하였다. 따라서 이런 문제를 보완하기 위해서 사용되는 라이브러리에는 GLUT, GLFW 등이 있으며
이중 GLFW는 윈도우 창을 생성하거나 키보드 마우스 입력 등 다양한 콜백 함수들을 사용하기위해 포함시킨다.

<a href="https://www.glfw.org/">GLFW</a>

```c
// Include GLFW
#include <GLFW/glfw3.h>
GLFWwindow* window;
```

<br>

#### GLM 라이브러리


OpenGL Mathematics의 약자로 GLSL을 기반으로하는 그래픽 소프트웨어에 사용 가능한 C++ 수학 라이브러리이다.
해당 라이브러리는 다양한 수학 함수들을 내포하고 있어 GLSL과 기능적 문법적 내용이 유사하여 쉽게 사용이 가능하다.

<a href="https://github.com/g-truc/glm">GLM</a>

GLM을 포함시키고 코드작성의 편의를 위해서 namespace를 선언해준다.

```c
// Include GLM
#include <glm/glm.hpp>
using namespace glm;
```

<br>

### Main 함수

메인함수 작성

```c
int main( void ) {
```

<br>

GLFW를 초기화 한다. 

```c
// Initialise GLFW
// glfwInit() 함수는 초기화가 성공하면 GLFW_TRUE, 실패하면 GLFW_FALSE를 반환한다.
if( !glfwInit() )
{
	fprintf( stderr, "Failed to initialize GLFW\n" );
	getchar();
	return -1;
}

//================================================
// glfwInit()
GLFWAPI int glfwInit()
{
    if (_glfwInitialized)
        return GL_TRUE;

    memset(&_glfw, 0, sizeof(_glfw));

    if (!_glfwPlatformInit())
    {
        _glfwPlatformTerminate();
        return GL_FALSE;
    }

    _glfw.monitors = _glfwPlatformGetMonitors(&_glfw.monitorCount);
    _glfwInitialized = GL_TRUE;

    // Not all window hints have zero as their default value
    glfwDefaultWindowHints();

    return GL_TRUE;
}
//================================================
```

<br>

#### Context

context를 생성하기 전에는 반드시 단서가 필요하다.
최소 버전이 컴퓨터에 맞지 않는다면 윈도우 창 생성이 실패할 수 있다.

glfwWindowHint() 함수로 전달되는 인자는 구현하는 API의 configure에 대한 정보를 전달한다.
첫 번째 인자는 매크로 상수로 glfw안에서 정의된 수 많은 상수에 대한 정보이다.
두 번째 인자에서 정수값은 매크로 상수 중 어떤 것을 사용할지 지정한다.
함수 내부에서는 switch 문을 통해서 동작한다.

```c
glfwWindowHint(GLFW_SAMPLES, 4);	// 4x antialiasing
glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);	// We want OpenGL 3.3
glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE); // To make MacOS happy; should not be needed
glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE); // We don't want the old OpenGL 

//================================================
// macro const
.
.
.
#define GLFW_CONTEXT_VERSION_MAJOR  0x00022002
#define GLFW_CONTEXT_VERSION_MINOR  0x00022003
.
.
.
//================================================

//================================================
// glfwWindowHint()
GLFWAPI void glfwWindowHint(int target, int hint)
{
    _GLFW_REQUIRE_INIT();

    switch (target)
    {
        .
        .
        .
        case GLFW_CONTEXT_VERSION_MAJOR:
            _glfw.hints.context.major = hint;
            break;
        case GLFW_CONTEXT_VERSION_MINOR:
            _glfw.hints.context.minor = hint;
            break;
        .
        .
        .
    }
}
//================================================
```

윈도우와 OpenGl의 context는 위의 함수를 호출하는 것으로 생성되고
glfwCreateWindow() 함수를 통해서 window와 context object는 생성되어 결합하고 handle을 반환한다.


```c
// Open a window and create its OpenGL context
window = glfwCreateWindow( 1024, 768, "Tutorial 01", NULL, NULL);
if( window == NULL ){
	fprintf( stderr, "Failed to open GLFW window. If you have an Intel GPU, they are not 3.3 compatible. Try the 2.1 version of the tutorials.\n" );
	getchar();
	glfwTerminate();
	return -1;
}
```
 
OpenGL API를 사용하기 전에 반드시 context를 가져와야한다. Window와 OpenGL context의 묶음인 handle을
전달하는 것으로 현재의 context를 가져올 수 있다.

```c
glfwMakeContextCurrent(window);

// Initialize GLEW
if (glewInit() != GLEW_OK) {
	fprintf(stderr, "Failed to initialize GLEW\n");
	getchar();
	glfwTerminate();
	return -1;
}
```

여기까지 작성을 하고 실행해보면 창이 뜨는것을 확인할 수 있다. 하지만 창은 곧바로 꺼지게 되므로 
ESC입력을 받을 때 까지 창이 대기하도록 만든다.

```c
// Ensure we can capture the escape key being pressed below
glfwSetInputMode(window, GLFW_STICKY_KEYS, GL_TRUE);
```

창의 바탕색을 변경하고 버퍼를 정리한다.

```c
// Dark blue background
glClearColor(0.0f, 0.0f, 0.4f, 0.0f);

do{
	// Clear the screen. It's not mentioned before Tutorial 02, but it can cause flickering, so it's there nonetheless.
	glClear( GL_COLOR_BUFFER_BIT );

	// Draw nothing, see you in tutorial 2 !

		
	// Swap buffers
	glfwSwapBuffers(window);
	glfwPollEvents();

} // Check if the ESC key was pressed or the window was closed
while( glfwGetKey(window, GLFW_KEY_ESCAPE ) != GLFW_PRESS &&
	   glfwWindowShouldClose(window) == 0 );

// Close OpenGL window and terminate GLFW
glfwTerminate();

return 0;
}
```