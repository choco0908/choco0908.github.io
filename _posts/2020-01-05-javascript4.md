---
title: "node.js 자동 재시작"
toc: true
toc_sticky: true
toc_label: "목차"
categories:
  - JavaScript
tags:
  - javascript
  - node.js
last_modified_at: 2020-01-05T21:20:00+09:00
---
JavaScript 파일 변화감지

---
## nodemon 설치
실행한 애플리케이션 파일에 수정할 코드가 있다면 node 데몬을 종료했다가 다시 실행해야하는 번거로움이 있습니다.

그래서 node에서 자동으로 소스코드가 수정이 되면 데몬을 재시작해주는 nodemon이 모듈이 있고 npm으로 쉽게 설치가 가능합니다.
-g 옵션을 추가하여 cmd창에서 사용가능하도록 할 수 있습니다.


```
λ npm install nodemon -g
```
<img src='{{ "/assets/images/javascript/nodemon-install-1.png" | absolute_url }}'>


## nodemon 실행
```
λ nodemon app.js
```
nodemon 실행시 디렉토리 내 파일 변화를 감지하기 시작합니다.

<img src='{{ "/assets/images/javascript/nodemon-install-2.png" | absolute_url }}'>

소스코드의 Hello World! 를 Hello World!!!!으로 변경해 봤습니다.

<img src='{{ "/assets/images/javascript/nodemon-install-3.png" | absolute_url }}'>

node를 수동으로 재시작 하지않고 정상적으로 반영이 되는것을 확인할 수 있었습니다.

<img src='{{ "/assets/images/javascript/nodemon-install-4.png" | absolute_url }}'>