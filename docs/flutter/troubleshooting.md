---
layout: default
title: Troubleshooting
parent: Flutter
date:   2023-02-22 22:45:00 +0900
nav_order: 99
---

# Troubleshooting 모음
{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## Flutter Android Licenses UnsupportedClassVersionError 해결

Window/Mac 개발 환경을 맞추기 위해서 윈도우에도 Flutter 환경을 구성하는중에

아래와 같은 에러가 발생했습니다.

```
Exception in thread "main" java.lang.UnsupportedClassVersionError: com/android/prefs/AndroidLocationsProvider has been compiled by a more recent version of the Java Runtime (class file version 55.0), this version of the Java Runtime only recognizes class file versions up to 52.0
```

<img src='{{ "/assets/images/flutter/flutter_window_install_error_1" | absolute_url }}'>

대부분 Java와 Javac 버전이 안 맞아서 뜨는 에러라고 검색이 되는데

버전이 달라서 생기는 문제는 아니었고, Java 버전이 너무 낮아서 발생하는 문제였습니다.

<img src='{{ "/assets/images/flutter/flutter_window_install_error_3" | absolute_url }}'>

[Java 1.9](https://www.oracle.com/java/technologies/downloads/#jdk19-windows)에서 installer를 다운받아 설치하였고

<img src='{{ "/assets/images/flutter/flutter_window_install_error_2" | absolute_url }}'>

위와 같이 환경변수에 1.8 버전을 1.9버전으로 교체를 한 후에

다시 **flutter doctor --android-licenses**를 실행해 보았습니다.

<img src='{{ "/assets/images/flutter/flutter_window_install_error_4" | absolute_url }}'>

Java 버전 변경 후에 정상적으로 licenses 체크가 완료되었고 doctor로 확인했을때

체크 표시를 확인할 수 있었습니다.

```
PS C:\Users\hg90> flutter doctor
Doctor summary (to see all details, run flutter doctor -v):
[√] Flutter (Channel stable, 3.3.9, on Microsoft Windows [Version 10.0.19044.2604], locale ko-KR)
[√] Android toolchain - develop for Android devices (Android SDK version 33.0.2)
[√] Chrome - develop for the web
[!] Visual Studio - develop for Windows (Visual Studio Community 2022 17.5.0)
    X The current Visual Studio installation is incomplete. Please reinstall Visual Studio.
[√] Android Studio (version 2022.1)
[√] VS Code (version 1.75.1)
[√] Connected device (3 available)
[√] HTTP Host Availability

! Doctor found issues in 1 category.
```
