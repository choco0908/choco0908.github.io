---
layout: default
title: Troubleshooting
parent: Android
date:   2020-05-21 15:47:00 +0900
nav_order: 99
---

# Troubleshooting
{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## Error #1 [ Nox Player 로딩 시 99%에서 멈춤 ]

```
OS : macOS Catalina 10.15.4
NoxPlayer : 3.0.2.0
```

Nox Player가 업데이트 되고 로딩 중 **99%에서 멈추는 현상**이 발생했습니다.

에러 로그를 보니 아래 내용이 반복적으로 출력 되면서 진행이 되지 않습니다.

```
NoxClient::executeShellCommand: open nox socket failed!
NoxClient shell output:  "Agile_Client_Error"
send PING to copypastetunnel = 4
wait_for_data_timeout
Failed to connect to VM (TcpStream) for main host connection, IP:Port=127.0.0.1:25000!!!
```

Nox Player는 정상적으로 설치 되고 config도 잘 불러 지고 있으나 원인을 파악 할 수 없어

구글 서치도 해봤지만 도움이 되는 내용이 없었습니다.

파일을 읽어오거나 쓰는 과정에서 문제가 생기는것 처럼 보여 권한 문제로 판단하고

**루트 권한**으로 앱을 실행하니 정상적으로 작동하는것을 확인했습니다.

```
/Applications/NoxAppPlayer.app/Contents/MacOS > ls
Nox.app       NoxAppPlayer  aapt          adb           conf          data          language      nox-tool      noxplayer.rcc
/Applications/NoxAppPlayer.app/Contents/MacOS > sudo ./NoxAppPlayer
```

한번 로딩 된 후에는 재부팅시에 **sudo 없이** 앱을 실행시키니 잘 동작하였습니다.

<img src='{{ "/assets/images/android/android_trouble_1.png" | absolute_url }}'>