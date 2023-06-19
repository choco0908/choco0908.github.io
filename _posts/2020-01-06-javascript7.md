---
title: "node.js 스케쥴러 설정"
toc: true
toc_sticky: true
toc_label: "목차"
categories:
  - JavaScript
tags:
  - javascript
  - node.js
last_modified_at: 2020-01-06T00:20:00+09:00
---
주기적으로 node 서버가 작업을 해야할때

---
## node cron 설정

node 서버를 사용하다 보면 주기적으로 javascript로 어떤 행위를 해야할 경우가 있습니다.

주기적으로 파일을 읽고 쓴다거나 알림을 받는 등 스케쥴러를 윈도우에서 해야 할 필요 없이

nodejs에서 cron 모듈을 사용하여 쉽게 구현이 가능합니다.

GNU crontab 기능을 기반으로 만들어져 crontab 사용경험이 있으면 손쉽게 사용이 가능합니다.

### 설치

```
λ npm install --save node-cron
```

### 사용법

```
var cron = require('node-cron');
 
cron.schedule('* * * * *', () => {
  console.log('running a task every minute');
});
```

### [cron syntax](https://www.npmjs.com/package/node-cron)

```
───────────────── field ─────────── value
# ┌────────────── second (optional) (0-59)
# │ ┌──────────── minute            (0-59)
# │ │ ┌────────── hour              (0-23)
# │ │ │ ┌──────── day of month      (1-31)
# │ │ │ │ ┌────── month             (1-12 or names)
# │ │ │ │ │ ┌──── day of week       (0-7 or names)
# │ │ │ │ │ │
# │ │ │ │ │ │
# * * * * * *
```

### 예제 ( 외부 서버의 TEXT를 30분 마다 주기적으로 받는 서비스 )

```
var cron = require('node-cron');
var https = require('https');

var options_cor = {
    hostname: 'test.site',
    path: '/javascripts/needfilepath'
}

cron.schedule('*/30 * * * *',function(){
    https.request(options_cor, function (response) {
        handleResponse(response);
    }).end();    
})

function handleResponse(response) {
    var serverData = '';
    response.on('data', function (chunk) {
        serverData += chunk;
    });
    response.on('end', function () {
        fs.writeFileSync('downloaedfile',serverData,'utf-8');
    });
}
```