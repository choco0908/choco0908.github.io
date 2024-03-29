---
title: "Express 모듈 설치하기"
toc: true
toc_sticky: true
toc_label: "목차"
categories:
  - JavaScript
tags:
  - javascript
  - node.js
last_modified_at: 2020-01-05T19:20:00+09:00
---
Express 프레임워크 설치

---
## WEB 애플리케이션 폴더 만들기
cmd 창에서 아래 명령어를 입력합니다.

```
E:\WEB                                                                                 
λ mkdir myapp

E:\WEB                                                                                 
λ cd myapp                                                                             

```

* * *


## 애플리케이션 config 파일 생성하기
테스트용으로는 package name과 entry point만 설정해 주시면 됩니다.

```
E:\WEB\myapp
λ npm init

This utility will walk you through creating a package.json file.                       
It only covers the most common items, and tries to guess sensible defaults.

Press ^C at any time to quit.         
package name: (myapp) myapp                                                            
entry point: (index.js) app.js                                                         
                                                                            
About to write to E:\WEB\myapp\package.json:       
{                                                                                      
  "name": "myapp",                                                                     
  "version": "1.0.0",                                                                  
  "description": "",                                                                   
  "main": "app.js",                                                                    
  "scripts": {                                                                         
    "test": "echo \"Error: no test specified\" && exit 1"                              
  },                                                                                   
  "author": "",                                                                        
  "license": "ISC"                                                                     
}   
                                                                    
Is this OK? (yes) yes                                                                  
```

* * *


## 해당 애플리케이션에서 사용할 express 모듈 설치
--save 옵션을 통해 config 파일에 기본적으로 express를 설치하도록 dependency를 설정합니다.

```
E:\WEB\myapp  (myapp@1.0.0)
λ npm install express --save
npm notice created a lockfile as package-lock.json. You should commit this file.
npm WARN myapp@1.0.0 No description
npm WARN myapp@1.0.0 No repository field.

+ express@4.17.1
added 50 packages from 37 contributors and audited 126 packages in 1.998s
found 0 vulnerabilities

λ cat package.json
{
  "name": "myapp",
  "version": "1.0.0",
  "description": "",
  "main": "app.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "author": "",
  "license": "ISC",
  "dependencies": {
    "express": "^4.17.1"
  }
}
```

[Express 설치 참고](http://expressjs.com/ko/)


<img src='{{ "/assets/images/javascript/nodejs-express-install-1.png" | absolute_url }}'>

