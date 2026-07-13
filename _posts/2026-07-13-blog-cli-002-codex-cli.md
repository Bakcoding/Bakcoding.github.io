---
title: "OpenAI Codex CLI 써보기"
excerpt: "codex cll, github blog"
categories:
  - Blog
tags:
  - General
permalink: /blog/codex-cli/
toc: true
toc_sticky: true
date: 2026-07-13
last_modified_at: 2026-07-13
---

## Codex CLI
Codex를 데스크톱 앱으로 사용중에 있었다. 그러다 Github 블로그를 AI로 관리하기 위해서 데스크톱앱을 설치하려고 했는데 해당 작업을 맥북으로 하려고 했고 데스크톱 앱을 설치하려 했지만 실행이 되지 않아서 방법을 찾다 CLI로 사용해보기로 했다. 

## OpenAI Codex CLI vs 일반 Codex CLI
패키지를 설치할 때 가장 주의해야 할 점은 서비스 명칭의 혼동이다. 이름이 비슷하지만 완전히 다른 역할을 하는 두 가지 패키지가 존재하므로 목적에 맞게 설치해야 한다.

### OpenAI Codex CLI (@openai/codex)
특징: OpenAI에서 공식 제공하는 ChatGPT 연동형 코딩 에이전트 CLI 툴이다.

용도: 터미널 환경에서 ChatGPT와 직접 연동하여 AI 기반의 코드 생성, 오류 수정, 터미널 명령어 추천 등의 개발 보조 기능을 수행한다.

설치 명령어: ```npm install -g @openai/codex```

### 일반 Codex CLI (@codex/cli)
특징: OpenAI와 관련이 없는 독립적인 협업 툴 또는 특정 클라우드 서비스(예: 문서/태스크 관리 등)의 전용 CLI이다.

용도: 해당 플랫폼의 프로젝트 파일을 업로드하거나 터미널을 통해 데이터를 동기화(codex push 등)할 때 사용한다.

설치 명령어: ```npm install -g @codex/cli```

따라서 ChatGPT의 코딩 에이전트 기능을 터미널에서 활용하고 싶다면 반드시 **OpenAI 공식 패키지명(@openai/codex)**을 확인하고 설치해야 한다.

## Node.js
먼저 Node.js 설치를 해준다.
Codex CLI는 TypeScript 기반으로 개발되었기 때문에 Node.js 런타임 환경에서 작동한다. 따라서 Node.js 설치가 필수적이며 공식 홈페이지에서 설치를 한다.

### 방법 1. 공식 홈페이지에서 다운로드
- 새로 설치하는 경우: Node.js 공식 홈페이지에서 OS 환경에 맞는 최신 LTS 버전을 다운로드하여 설치한다.

- 기존 버전이 있는 경우: 버전 충돌이나 환경이 꼬이는 것을 방지하기 위해 기존 버전을 완전히 삭제한 후 재설치하는 것을 권장한다.

### 방법 2. nvm(Node Version Manager) 사용
이미 PC에 다른 버전의 Node.js가 설치되어 있다면 nvm을 설치하여 명령어로 관리하는 것이 훨씬 효율적이다.

nvm 사용 시 장점 (관리 편의성):
- 자유로운 버전 전환: 삭제 후 재설치할 필요 없이 명령어 한 줄로 원하는 Node.js 버전을 자유롭게 바꿀 수 있다. (nvm use <버전>)

- 독립된 환경 제공: 프로젝트마다 요구하는 Node.js 버전이 다를 때 발생할 수 있는 환경 충돌을 방지한다.

- 간편한 업데이트: 새 버전이 나왔을 때 기존 환경을 건드리지 않고 추가 설치가 가능하다. (nvm install <버전>)
이미 설치된 상태라면 버전을 최신화 해준다.

## CLI 설치 및 로그인
Node.js 환경이 준비되었다면 터미널(또는 명령 프롬프트)을 열고 OpenAI Codex CLI를 설치한다. ChatGPT 계정과 연동하여 터미널에서 직접 코딩 에이전트를 구동할 수 있다.

### Codex CLI 설치
각 운영체제에 맞는 명령어를 터미널에 입력하여 전역(Global)으로 설치한다. Node.js 버전은 22 이상(LTS)을 권장한다.

- macOS: 권한 오류(Permission Denied)를 방지하기 위해 명령어 앞에 sudo를 붙여 관리자 권한으로 설치한다. (또는 공식 안내에 따라 Homebrew를 통해 brew install codex로도 설치 가능하다.)
```sudo npm install -g @openai/codex```

- Windows: 기본 npm 명령어로 설치를 진행한다. 오류가 발생할 경우 명령 프롬프트(CMD)를 '관리자 권한으로 실행'한 뒤 입력한다.
```npm install -g @openai/codex```

### 초기 설정 및 로그인
설치가 완료되면 서비스 사용을 위해 ChatGPT 계정 인증 과정을 거쳐야 한다. 터미널에 아래 명령어를 입력한다.

```codex```

명령어를 실행하면 터미널에 로그인 메뉴가 나타난다. 1. Sign in with ChatGPT를 선택하고 엔터를 누르면 자동으로 웹 브라우저가 열리며 OpenAI 인증 화면이 나타난다. 브라우저에서 로그인을 완료하고 터미널로 돌아와 엔터를 치면 정상적으로 연동이 완료된다.

## 윈도우 환경 주요 경고 및 해결 명령어
### npm 설치 시 발생하는 권한 경고 (EACCES 또는 에러)
Windows에서 ```npm install -g @openai/codex``` 명령어를 입력했을 때, 시스템 권한 문제로 설치가 차단되며 빨간색 에러 글씨가 뜨는 경우가 있다.

원인: 일반 명령 프롬프트(CMD)나 PowerShell 환경에서는 시스템 전역(-g)에 패키지를 저장할 권한이 부족하기 때문이다.

해결 방법:

시작 메뉴에서 명령 프롬프트(CMD) 또는 PowerShell을 검색한다.

마우스 우클릭 후 '관리자 권한으로 실행'을 선택하여 창을 연다.

명령어를 다시 입력하여 설치를 진행한다.

### 스크립트 실행 권한 경고 (Execution Policy 오류)
설치를 마치고 터미널에 codex를 입력해 실행하려고 할 때, 인증 메뉴로 넘어가지 않고 *"이 시스템에서 스크립트를 실행할 수 없으므로..."*라는 보안 경고가 뜨는 경우가 있다. Windows PowerShell의 기본 보안 정책 때문에 발생하는 현상이다.

원인: Windows 정책상 검증되지 않은 스크립트 실행을 기본적으로 차단(Restricted)하고 있기 때문이다.

해결 명령어: 관리자 권한으로 PowerShell을 열고 아래 명령어를 입력해 권한을 풀어주어야 정상적으로 인증 및 실행 단계로 진입할 수 있다.

```Set-ExecutionPolicy RemoteSigned -Scope CurrentUser```
(위 명령어를 입력한 후 Y를 누르면 현재 사용자 계정에 한해 실행 권한이 허용된다.)
