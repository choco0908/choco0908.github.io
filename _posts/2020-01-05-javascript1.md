---
title: "Node.js 설치하기 (Windows)"
toc: true
toc_sticky: true
toc_label: "목차"
categories:
  - JavaScript
tags:
  - javascript
  - node.js
last_modified_at: 2020-01-05T18:20:00+09:00
---
초간단 Node.js 설치

---
## Node.js 다운로드 및 설치

먼저 Node.js로 웹서버를 구동하기위해 설치를 진행합니다.

<img src='{{ "/assets/images/javascript/nodejs-main-home.PNG" | absolute_url }}'>
[Node.js 다운로드](https://nodejs.org/ko/)

테스트용으로는 LTS 버전으로 설치하시면 됩니다.

<img src='{{ "/assets/images/javascript/nodejs-install-1.PNG" | absolute_url }}'>

라이센스 계약에 동의후 Next.

<img src='{{ "/assets/images/javascript/nodejs-install-2.PNG" | absolute_url }}'>

설치 원하는 경로 지정후 Next.

<img src='{{ "/assets/images/javascript/nodejs-install-3.PNG" | absolute_url }}'>

따로 설정을 건드리지 않고 Next를 한다면 자동으로 환경변수에 PATH까지 추가합니다.

<img src='{{ "/assets/images/javascript/nodejs-install-4.PNG" | absolute_url }}'>

윈도우 버전은 Node.js 설치시 Dependency 관련 이슈가 있었다고 하네요.
어떤 모듈이 필요하게 될지 모르니 미리 설치해두는것도 좋을것같습니다.

* * *

## Node.js 실행

설치가 완료되고 환경변수에 잘 등록이 되었다면 cmd 창에서 다음 명령어를 실행합니다.

<img src='{{ "/assets/images/javascript/nodejs-install-5.PNG" | absolute_url }}'>

정상적으로 내가 설치한 버전이 출력이 된다면 설치 성공!