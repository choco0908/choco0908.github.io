---
layout: default
title: Troubleshooting
parent: macOS
date:   2022-07-07 12:10:00 +0900
nav_order: 99
---

# Troubleshooting 모음
{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## Homebrew 설치할때 Error

기본적으로 Mac에서 여러 패키지를 쉽게 설치하기 위해 

아래와 같이 [Homebrew](https://brew.sh/index_ko) 설치를 진행 하지만

```sh
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

아래와 같은 에러가 발생할때 

### SSL certificate problem : unable to get local issuer certificate

```
curl: (60) SSL certificate problem: unable to get local issuer certificate

More details here: http://curl.haxx.se/docs/sslcerts.html
```

맥 환경이 Proxy가 적용된 환경인 경우 Proxy 옵션과 함께 설치합니다.

```sh
$ /bin/bash -c "$(curl -x {http://user:password@some.proxy.com:port} -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## Ruby gem Error

Jekyll 블로그, xcpretty 등 Ruby로 만든 패키지를 설치하기 위해 gem이 필요하며 기본적으로 ruby가 설치가 되어있지만

없다면 Homebrew를 통해 설치합니다.

### gem install 시 Time out error

Proxy가 적용된 환경에서 gem install 할 때 time out이 주로 발생합니다.

```sh
gem install --http-proxy {http://user:password@some.proxy.com:port} {packagename}
```

### gem install 시 PermissionError

gem으로 설치할 때 아래와 같이 에러가 발생하는 이유는 root 권한이 아니어서

root권한으로 설치하라는 에러지만 보안적으로 권장하는 방법이 아닙니다.

```sh
$ gem install jekyll bundler
ERROR:  While executing gem ... (Gem::FilePermissionError)
You don't have write permissions for the /Library/Ruby/Gems/2.6.0 directory.
```

그래서 ruby 패키지를 rbenv라는 가상환경을 통해 관리하도록 권장하고 있습니다.

rbenv를 설치합니다.

```sh
$ brew update
$ brew install rbenv ruby-build
```

rbenv 설치 가능한 버전 목록을 확인합니다.

```sh
$ rbenv install -l

2.6.9
2.7.5
3.0.3
jruby-9.3.2.0
mruby-3.0.0
rbx-5.0
truffleruby-21.3.0
truffleruby+graalvm-21.3.0
```

필요한 버전을 설치하고 버전을 확인합니다.

```sh
$ rbenv install 3.0.3

$ rbenv version
3.0.3 (set by /Users/sds-ces/.rbenv/version)
```

정상적으로 설치가 되었다면 아래 명령어로 Default 버전을 설정합니다.

```sh
$ rbenv global 3.0.3
```

각자 환경에 맞는 쉘 설정파일에 아래 내용을 추가한 후 저장합니다.

ex) vim ~/.zshrc, vim ~/.bash_profile, vim ~/.bashrc

```
[[ -d ~/.rbenv  ]] && \
  export PATH=${HOME}/.rbenv/bin:${PATH} && \
  eval "$(rbenv init -)"
```

위 스크립트를 추가한 후 source로 쉘에 해당 내용 적용하면

PermissionErro없이 설치가 되는것을 확인 할 수 있습니다.

```sh
$ source ~/.zshrc
```