---
title: "Hello World!"
toc: true
toc_sticky: true
toc_label: "목차"
categories:
  - JavaScript
tags:
  - javascript
  - node.js
last_modified_at: 2020-01-05T20:20:00+09:00
---
Express 테스트

---
## 애플리케이션 작성하기
생성한 애플리케이션의 entry point 였던 app.js를 아래 내용으로 작성합니다.

<script src="https://gist.github.com/choco0908/502733f463efa7a1b4a95c26baee727d.js"></script>

```
E:\WEB\myapp  (myapp@1.0.0)
λ ls
app.js  node_modules/  package.json  package-lock.json

E:\WEB\myapp  (myapp@1.0.0)
λ node app.js
Example app listening on port 3000!
```
app.js 애플리케이션을 실행시킨후 [http://localhost:3000](http://localhost:3000) 으로 접속합니다.

<img src='{{ "/assets/images/javascript/nodejs-express-start-1.png" | absolute_url }}'>

그림과 같이 Hello World 문구를 확인하셨으면 끝!
