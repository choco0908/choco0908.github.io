---
title: "node.js SSL 적용하기"
toc: true
toc_sticky: true
toc_label: "목차"
categories:
  - JavaScript
tags:
  - javascript
  - node.js
last_modified_at: 2020-01-05T22:20:00+09:00
---
내 서버에 OpenSSL 적용하기

---
## private, public key 만들기

node 서버에 SSL을 적용하기 위해서는 key 파일을 생성해야합니다.

다음명령어로 pri, pub key 파일을 생성합니다.

```
λ openssl genrsa 1024 > private.pem
λ openssl req -x509 -new -key private.pem -out public.pem
```
아래는 테스트를 위해 임시로 생성한 key 파일입니다.

```
λ openssl genrsa 1024 > private.pem
Generating RSA private key, 1024 bit long modulus
...++++++
............++++++
e is 65537 (0x10001)

λ openssl req -x509 -new -key private.pem -out public.pem
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) []:KR
State or Province Name (full name) []:ARTest
Locality Name (eg, city) []:ARTest
Organization Name (eg, company) []:ARTest
Organizational Unit Name (eg, section) []:ARTest
Common Name (eg, fully qualified host name) []:ARTest
Email Address []:ARTest@gmail.com
```

## 인증서 내용 확인

```
E:\WEB\tmp                                                                                                                     
λ openssl x509 -noout -text -in public.pem

Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            09:58:d0:c4:20:b0:2d:dc:08:81:c1:00:2c:a0:8f:d3:a3:29:3c:f5
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: C = KR, ST = ARTest, L = ARTest, O = ARTest, OU = ARTest, CN = ARTest, emailAddress = ARTest@gmail.com
        Validity
            Not Before: Apr 10 05:10:59 2020 GMT                                                                               
            Not After : May 10 05:10:59 2020 GMT                                                                               
        Subject: C = KR, ST = ARTest, L = ARTest, O = ARTest, OU = ARTest, CN = ARTest, emailAddress = ARTest@gmail.com        
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                RSA Public-Key: (1024 bit)
                Modulus:
                    00:cd:8b:fb:27:9f:5b:e1:e4:dd:0c:2a:28:1f:0e:
                    aa:c7:7c:53:f3:99:7e:8f:f3:76:ba:9f:c6:d5:1f:
                    02:8e:70:f3:df:fe:76:0b:b8:83:80:3d:be:01:16:
                    3a:ef:d2:a2:42:55:1d:cb:b3:10:a9:34:2f:83:6c:
                    73:a1:74:af:4a:aa:7d:c6:f2:1e:44:37:10:01:84:
                    38:c0:61:cb:0e:f7:b3:68:fa:75:51:57:91:bd:ac:
                    e2:76:e1:fe:b8:a8:60:96:17:04:8e:07:84:55:fe:
                    92:1e:2f:d6:80:b9:72:56:84:36:d3:0f:9d:d1:ec:
                    48:21:77:c4:ec:fe:8d:6e:87
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Subject Key Identifier:
                3D:A6:B4:5C:11:8D:1F:7E:4F:C3:E1:C2:A8:7A:BA:30:40:22:C5:8F
            X509v3 Authority Key Identifier:
                keyid:3D:A6:B4:5C:11:8D:1F:7E:4F:C3:E1:C2:A8:7A:BA:30:40:22:C5:8F

            X509v3 Basic Constraints: critical
                CA:TRUE
    Signature Algorithm: sha256WithRSAEncryption
         55:54:92:ce:60:24:be:c9:c8:6a:1d:4d:a4:da:61:b8:b6:68:
         f9:4a:48:1d:de:92:51:ff:c4:fe:1b:ad:99:f8:31:69:d2:da:
         a9:2b:2b:1f:97:02:db:93:ec:1f:cb:de:89:a1:9c:4d:77:7f:
         32:e3:a8:eb:38:05:4b:db:6e:9f:fb:e3:4d:05:ad:6e:21:7c:
         81:3f:8e:35:7b:13:5d:f5:df:86:35:d2:bf:83:39:3f:ee:c2:
         b2:bc:79:22:d8:06:38:b8:4b:85:d4:50:90:01:d9:68:e3:0b:
         37:70:2a:a9:ed:da:fc:29:84:91:7e:d3:61:f9:77:3d:e4:b5:
         f0:8d
```


***

## https 서버 생성 코드 작성

https 모듈을 적용하기 위해서는 총 3개의 코드 블록을 추가하여합니다.

1. https 모듈 로딩
1. key 파일 로딩
1. https 서버 구동

```js
// 1. https 모듈 로딩
const https = require('https')

// 2. 생성한 openssl key 파일 로딩
// Linux/Mac 환경에서는 fs.readFileSync('serverpem/private.pem')
var options = {
    key : fs.readFileSync('serverpem\\private.pem','utf-8'),
    cert : fs.readFileSync('serverpem\\public.pem','utf-8')
}

// 3. https 443 포트로 서버 구동
var https_server = https.createServer( options,(req,res) => {
    fs.readFile('artest.html',function(error,data){
        if(error){
            console.log(error);
        }
        else{
            res.writeHead(200);
            res.end(data);
        }
    })
}).listen(443);
```

[https://localhost](https://localhost)에 접속하여 정상 작동하는지 테스트