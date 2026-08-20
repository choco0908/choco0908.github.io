---
title: "부팅없이 Vanguard 오류해결: 리그 오브 레전드 '게임을 플레이하려면 시스템을 다시 시작해야 합니다' 해결 방법"
classes: wide
toc: true
toc_sticky: true
toc_label: "목차"
categories:
  - Life
  - Game
tags:
  - 리그오브레전드
  - 롤오류
  - Vanguard
  - RiotVanguard
  - 뱅가드재설치
  - VAN오류
  - 롤재부팅오류
  - RiotClient
  - vgc서비스
  - 게임오류해결
description: "결론부터 말하면 이 오류는 Vanguard가 정상 실행되지 않을 때 뜹니다. 바로 재부팅하기 전에 먼저 할 일은 Riot Client 완전 종료 → Vanguard 서비스 확인 → Riot Vanguard..."
last_modified_at: 2026-08-20T09:00:00+09:00
canonical_url: "https://choco0908.github.io/life/lol_vanguard_restart/"
---
![리그 오브 레전드 Vanguard 재시작 오류 화면](/assets/images/life/20260820_lol_vanguard_error.png)
*출처: 사용자 제공 캡처 / 캡션: 리그 오브 레전드 클라이언트에서 플레이 버튼이 막히고 시스템 재시작 안내가 뜬 상태*

결론부터 말하면 이 오류는 **Vanguard가 정상 실행되지 않을 때** 뜹니다. 바로 재부팅하기 전에 먼저 할 일은 **Riot Client 완전 종료 → Vanguard 서비스 확인 → Riot Vanguard 삭제 후 클라이언트 재설치**입니다. 다만 Riot Vanguard는 윈도우 시작 단계에서 드라이버가 올라가는 구조라, 재설치 후에도 마지막 1회 재부팅이 필요한 경우가 있습니다.

---

## 오류 메시지 뜻

화면에 뜨는 문구는 다음과 같습니다.

> 게임을 플레이하려면 시스템을 다시 시작해야 합니다. 컴퓨터를 다시 시작해 주세요.

이 문구는 롤 클라이언트 문제가 아니라 **Riot Vanguard 실행 상태 문제**로 보는 게 맞습니다. Vanguard가 꺼져 있거나, 설치가 꼬였거나, `vgc` 서비스가 시작되지 않으면 플레이 버튼이 비활성화됩니다.

| 증상 | 원인 가능성 | 먼저 할 조치 |
| :--- | :--- | :--- |
| 플레이 버튼 비활성화 | Vanguard 미실행 | Riot Client 완전 종료 후 재실행 |
| 계속 재시작 안내 | `vgc` 서비스 중지 | 서비스에서 `vgc` 시작 |
| 재실행해도 반복 | Vanguard 설치 손상 | Riot Vanguard 삭제 후 재설치 |
| VAN 코드 동반 | 네트워크·보안 설정 문제 | 방화벽, 보안 부팅, 관리자 권한 확인 |

---

## 1단계: 재부팅 전에 Riot Client를 완전히 끄기

먼저 롤 창만 닫지 말고 **Riot Client까지 완전히 종료**해야 합니다.

1. 작업 표시줄 오른쪽 아래에서 Riot 아이콘을 찾습니다.
2. 마우스 오른쪽 버튼을 누르고 **종료**를 선택합니다.
3. `Ctrl + Shift + Esc`로 작업 관리자를 엽니다.
4. `Riot Client`, `League of Legends`, `RiotClientServices`가 남아 있으면 **작업 끝내기**를 누릅니다.
5. Riot Client를 **관리자 권한으로 실행**합니다.

이 단계에서 바로 플레이 버튼이 살아나면 재부팅 없이 해결된 것입니다. 그래도 같은 안내가 뜨면 다음 단계로 넘어갑니다.

---

## 2단계: vgc 서비스 시작 상태 확인

Vanguard의 핵심 서비스 이름은 **vgc**입니다. 이 서비스가 꺼져 있으면 롤이 Vanguard를 인식하지 못합니다.

| 확인 위치 | 입력값 또는 메뉴 | 설정값 |
| :--- | :--- | :--- |
| 실행 창 | `Win + R` → `services.msc` | 서비스 목록 열기 |
| 서비스 이름 | `vgc` | Riot Vanguard 서비스 |
| 시작 유형 | 속성 → 시작 유형 | 자동 |
| 서비스 상태 | 속성 → 서비스 상태 | 시작 |

`vgc`가 중지되어 있으면 **시작**을 누릅니다. 시작 유형이 수동이면 **자동**으로 바꿉니다. 적용 후 Riot Client를 다시 실행해 플레이 버튼을 확인합니다.

이 방법은 재부팅 없이 풀릴 수 있는 대표 조치입니다. 단, 서비스 시작 자체가 실패하면 설치 파일이 깨졌거나 보안 프로그램이 막고 있을 가능성이 큽니다.

---

## 3단계: Riot Vanguard 삭제

![Windows 설치된 앱에서 Riot Vanguard 삭제](/assets/images/life/20260820_lol_vanguard_uninstall.png)
*출처: 사용자 제공 캡처 / 캡션: Windows 설정의 설치된 앱 검색창에서 Riot Vanguard를 찾은 화면*

서비스 확인으로 해결되지 않으면 **Riot Vanguard만 삭제**합니다. 롤 전체를 지울 필요는 없습니다.

1. Windows 설정을 엽니다.
2. **앱 → 설치된 앱**으로 이동합니다.
3. 검색창에 `van` 또는 `Riot Vanguard`를 입력합니다.
4. **Riot Vanguard** 오른쪽의 점 세 개 메뉴를 누릅니다.
5. **제거**를 선택합니다.

삭제 후 Riot Client를 실행하면 필요한 Vanguard 구성요소를 다시 설치합니다. 이때 클라이언트가 재시작 또는 재부팅을 요구하면 안내를 따르는 것이 가장 빠릅니다.

---

## 4단계: 롤 클라이언트에서 Vanguard 재설치

![리그 오브 레전드 클라이언트 정상 플레이 버튼](/assets/images/life/20260820_lol_vanguard_reinstall.png)
*출처: 사용자 제공 캡처 / 캡션: Vanguard 재설치 후 리그 오브 레전드 클라이언트의 플레이 버튼이 정상 표시된 상태*

Vanguard 삭제 후에는 Riot Client를 다시 실행합니다. 롤 클라이언트가 필요한 파일을 감지하면 Vanguard 설치를 다시 진행합니다.

정상 흐름은 다음과 같습니다.

- Riot Client 실행
- League of Legends 선택
- Vanguard 구성요소 재설치
- 플레이 버튼 확인
- 필요 시 마지막 1회 재부팅

여기서 중요한 점은 **Vanguard만 재설치**한다는 것입니다. 롤 전체 재설치보다 시간이 짧고, 설정 파일이나 게임 데이터 손상 가능성도 낮습니다.

---

## 추가 오류 해결 방법

아래 방법은 Vanguard 재설치 후에도 오류가 반복될 때 적용합니다.

| 해결 방법 | 적용 상황 | 실행 방법 |
| :--- | :--- | :--- |
| 관리자 권한 실행 | 클라이언트 권한 문제 | Riot Client 우클릭 → 관리자 권한으로 실행 |
| Windows 업데이트 | 보안 드라이버 충돌 | 설정 → Windows 업데이트 → 최신 업데이트 적용 |
| 보안 프로그램 예외 | 백신이 Vanguard 차단 | 보안 프로그램에서 Riot Client와 Vanguard 예외 등록 |
| 방화벽 허용 | 접속 오류 동반 | Windows 보안 → 방화벽 → 앱 허용 |
| 보안 부팅 확인 | VAN 9001류 오류 | BIOS/UEFI에서 Secure Boot, TPM 2.0 확인 |
| 네트워크 재설정 | VAN 68, 접속 오류 | 공유기 재시작, DNS 변경, 네트워크 초기화 |

Vanguard는 치트 방지 프로그램이라 일반 앱보다 윈도우 보안 설정과 충돌을 더 민감하게 받습니다. 특히 **Secure Boot**, **TPM**, **방화벽**, **백신 실시간 감시**가 꼬이면 재설치만으로 해결되지 않습니다.

---

## 부팅 없이 해결되는 경우와 안 되는 경우

| 구분 | 부팅 없이 가능 | 이유 |
| :--- | :---: | :--- |
| Riot Client만 멈춘 경우 | 가능 | 클라이언트 재실행으로 해결 |
| `vgc` 서비스만 꺼진 경우 | 가능 | 서비스 수동 시작으로 해결 |
| Vanguard 설치 손상 | 일부 가능 | 삭제·재설치 후 재부팅 요구 가능 |
| Vanguard 드라이버 미로드 | 어려움 | 드라이버는 부팅 단계에서 올라감 |
| 보안 부팅/TPM 설정 문제 | 불가 | BIOS 설정 변경 후 재부팅 필요 |

따라서 이 글의 핵심은 “무조건 재부팅하지 않는다”가 아닙니다. **재부팅 전에 시간을 아끼는 순서로 점검하고, 재부팅이 필요한 케이스를 빨리 구분하는 것**입니다.

---

## 바로 따라 하는 체크리스트

1. Riot Client와 LoL 관련 프로세스를 모두 종료합니다.
2. Riot Client를 관리자 권한으로 다시 실행합니다.
3. `services.msc`에서 `vgc` 서비스를 자동/시작 상태로 바꿉니다.
4. 그래도 안 되면 Windows 설정에서 **Riot Vanguard만 제거**합니다.
5. Riot Client를 다시 열어 Vanguard를 재설치합니다.
6. 계속 뜨면 재부팅 후 Secure Boot, TPM, 방화벽, 백신 예외를 확인합니다.

가장 빠른 해결 루트는 **클라이언트 완전 종료 → vgc 서비스 확인 → Vanguard 삭제·재설치**입니다. 이 순서로 해결되지 않으면 재부팅이 필요한 드라이버 또는 보안 설정 문제로 보는 편이 정확합니다.

## 참고 자료 및 출처

- [League of Legends Support - Network logs, peering partners, & other tech](https://support-leagueoflegends.riotgames.com/hc/en-us/sections/115002164588-Network-logs-peering-partners-other-tech)
- [League of Legends Support - Uninstalling and Disabling Vanguard](https://support-leagueoflegends.riotgames.com/hc/pt-br/articles/24169961916691-Desinstala%25C3%25A7%25C3%25A3o-e-desativa%25C3%25A7%25C3%25A3o-do-Riot-Vanguard)
- [Riot Games - A Message About Vanguard From Our Security & Privacy Teams](https://www.riotgames.com/en/news/a-message-about-vanguard-from-our-security-privacy-teams)
- [Riot Games - Vanguard On-Demand Anti-Cheat Update](https://www.riotgames.com/en/news/vanguard-on-demand)

## 구글 SEO 태그

리그오브레전드 오류, 롤 Vanguard 오류, 부팅없이 vanguard 오류해결, 게임을 플레이하려면 시스템을 다시 시작해야 합니다, Riot Vanguard 재설치, 뱅가드 삭제, vgc 서비스, VAN 오류 해결, 롤 플레이 버튼 비활성화, 리그오브레전드 재부팅 오류
