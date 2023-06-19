---
title: "Troubleshooting - Argumented Reality"
toc: true
toc_sticky: true
toc_label: "목차"
categories:
  - Augmented Reality
tags:
  - augmented reality
  - troubleshooting
last_modified_at: 2020-01-06T17:05:00+09:00
---
# 에러 한줄에 한시간..
해당 프로젝트를 진행하면서 발생했던 Issue 들을 정리 해봤습니다.

---
## Error #1 [ Webcam Error ( WebRTC issue ) ]

Remote 환경에서 개발을 진행하기 위해 핫스팟으로 서버를 호스팅하고 웹페이지에 접속을 시도하였습니다.

<img src='{{ "/assets/images/ar/arjs/geoar-troubleshooting-1.png" | absolute_url }}'>

호스팅중인 로컬 PC 에서 접속할때는 웹캠이 정상적으로 작동하나 

모바일에서 접속 할때는 위 그림에서 보는것처럼 WebRTC 에러가 발생하며 Camera 권한을 받지 못합니다.

```
Webcam Error
Name: 
Message: WebRTC issue-! navigator.mediaDevices not present in your browser
```
<br/>
노드서버의 문제인지 노트북의 문제인지 가늠이 안되서 계속 삽질을 하던 찰나에.. 세상엔 똑똑한 사람이 너무 많다는걸 깨닫게 해주는 문구가 있네요 **HTTPS!!!!**

<img src='{{ "/assets/images/ar/arjs/geoar-troubleshooting-2.png" | absolute_url }}'>

[https://github.com/jeromeetienne/AR.js/issues/463#issuecomment-503552278](https://github.com/jeromeetienne/AR.js/issues/463#issuecomment-503552278)

[**Google Developer**](https://developers.google.com/web/fundamentals/media/capturing-images?hl=ko) 사이트에서도 내용을 찾을 수 있었습니다.

<img src='{{ "/assets/images/ar/arjs/geoar-troubleshooting-3.png" | absolute_url }}'>

[**도츠의 무상지식 - Node.js HTTPS 적용하기 포스팅 바로가기**](https://choco0908.github.io/javascript/javascript5/)