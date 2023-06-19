---
title: "node.js 프록시 설정"
toc: true
toc_sticky: true
toc_label: "목차"
categories:
  - JavaScript
tags:
  - javascript
  - node.js
last_modified_at: 2020-01-05T23:20:00+09:00
---
내 PC가 회사컴일 경우

---
## node proxy 설정

npm 으로 모듈 설치시 회사 컴일 경우 잘 설치가 안될때가 있습니다. 모두의 적 **프록시!!**

그럴때는 프록시 서버 확인후에 아래 명령어를 입력합니다.

```
λ npm config set proxy http://111.111.111.111:2222
λ npm config set https-proxy http://111.111.111.111:2222

// 위 명령어로 안된다면 권고
λ npm config set strict-ssl false
```