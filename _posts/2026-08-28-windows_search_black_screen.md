---
title: "윈도우 검색창 먹통 해결법: 검은 화면·빈 화면에서 SearchHost 재설정까지"
classes: wide
toc: true
toc_sticky: true
toc_label: "목차"
categories:
  - Life
  - Windows
tags:
  - 윈도우검색창먹통
  - 윈도우검색창검은화면
  - WindowsSearch
  - SearchHost
  - 윈도우11검색오류
  - DISM
  - SFC
  - WindowsSearch초기화
  - MicrosoftWindowsClientCBS
  - 윈도우문제해결
description: "Win + S를 눌렀을 때 검색창 테두리만 뜨고 내부가 검거나 비어 있으면, 단순 인덱싱 지연이 아니라 Windows Search의 사용자 구성 또는 시스템 파일 문제일 수 있습니다. 이 글은 가벼운 조치부..."
last_modified_at: 2026-08-28T09:00:00+09:00
canonical_url: "https://choco0908.github.io/life/windows_search_black_screen/"
---
`Win + S`를 눌렀을 때 검색창 테두리만 뜨고 내부가 검거나 비어 있으면, 단순 인덱싱 지연이 아니라 **Windows Search의 사용자 구성 또는 시스템 파일 문제**일 수 있습니다. 이 글은 가벼운 조치부터 DISM/SFC 검사, 마지막으로 Windows 11의 Search 패키지와 레지스트리를 재생성하는 공식 절차까지 순서대로 정리한 기록입니다. 제 PC에서는 마지막 초기화 뒤 재부팅으로 검색창이 정상 복구됐습니다.

![검색 내용이 보이지 않는 검은 Windows 검색창](/assets/images/life/20260828_windows_search_black_screen.png)
*출처: 사용자 제공 캡처 / 캡션: 검색창 창은 열리지만 내부 콘텐츠가 검게 비어 있는 증상*

## 먼저 증상을 구분하기

검색 오류는 모두 같은 문제가 아닙니다. 파일 검색 결과만 늦는 경우와 검색창 UI 자체가 검거나 빈 경우는 접근 순서가 다릅니다.

| 증상 | 먼저 볼 항목 | 권장 순서 |
| :--- | :--- | :--- |
| 검색 결과가 늦거나 일부 파일만 안 나옴 | 인덱싱·검색 범위 | 검색 및 인덱싱 문제 해결사, 인덱스 재구성 |
| `Win + S`가 열리지 않음 | SearchHost·Windows Search 서비스 | 작업 관리자, 서비스 재시작 |
| 검색창이 검거나 빈 화면 | SearchHost·시스템 파일·CBS 사용자 데이터 | SearchHost 확인 → DISM/SFC → Search 초기화 |
| 새 Windows 계정에서도 같은 증상 | 시스템 전체 구성 | DISM/SFC, Windows 업데이트, 고급 초기화 |

이 글에서 다루는 핵심은 세 번째 증상입니다. 검색창이 떴는데 추천 항목과 입력 영역이 전혀 보이지 않는 경우입니다.

---

## 1단계: 작업 관리자에서 SearchHost.exe 확인

`Ctrl + Shift + Esc`로 작업 관리자를 열고 상단 검색창에 `sea` 또는 `SearchHost`를 입력합니다. `검색` 그룹 아래에 **SearchHost.exe**가 보이면 검색 프로세스 자체는 실행 중인 상태입니다.

![작업 관리자에서 확인한 SearchHost.exe](/assets/images/life/20260828_windows_searchhost_task_manager.png)
*출처: 사용자 제공 캡처 / 캡션: 작업 관리자 검색 결과에서 실행 중인 SearchHost.exe를 확인한 화면*

SearchHost.exe가 멈춘 것처럼 보이거나 검색창이 계속 비어 있으면 해당 프로세스를 선택해 **작업 끝내기**를 누른 뒤 `Win + S`를 다시 엽니다. Windows가 검색 프로세스를 다시 올리면서 일시 오류가 풀리는 경우가 있습니다.

여기서 중요한 판단 기준은 간단합니다. SearchHost.exe가 다시 생성돼도 화면이 계속 검다면, 프로세스 하나를 재시작하는 수준을 넘어 다음 단계로 가야 합니다.

---

## 2단계: Windows Search 서비스 상태 확인

관리자 권한 PowerShell을 열어 Windows Search 서비스의 상태를 확인합니다. 작업 관리자에서 **새 작업 실행**을 누르고 `cmd`를 입력한 다음, `관리자 권한으로 이 작업 실행`을 체크하면 관리자 명령 프롬프트를 열 수 있습니다.

![작업 관리자에서 관리자 권한 명령 프롬프트 실행](/assets/images/life/20260828_windows_search_admin_cmd.png)
*출처: 사용자 제공 캡처 / 캡션: 작업 관리자의 새 작업 실행 창에서 관리자 권한으로 명령 프롬프트를 여는 방법*

```powershell
Get-Service WSearch
Restart-Service WSearch
```

`Status`가 `Running`이면 서비스는 실행 중입니다. 다만 서비스가 실행 중이라고 검색창 UI까지 정상이라는 뜻은 아닙니다. 검은 화면 증상에서는 서비스를 재시작한 뒤에도 그대로라면 시스템 파일 검사로 넘어가는 편이 빠릅니다.

---

## 3단계: DISM 다음 SFC 순서로 시스템 파일 복구

Microsoft는 손상된 시스템 파일을 점검할 때 **DISM을 먼저 실행하고 SFC를 다음에 실행**하는 순서를 안내합니다. DISM이 복구에 필요한 구성 요소를 준비하고, SFC가 보호된 시스템 파일을 검사·교체하는 방식입니다.

관리자 권한 명령 프롬프트 또는 PowerShell에서 아래 두 명령을 순서대로 실행합니다. 두 번째 명령은 첫 번째 명령이 끝난 뒤 실행합니다.

```powershell
DISM.exe /Online /Cleanup-Image /RestoreHealth
```

```powershell
sfc /scannow
```

![DISM과 SFC 검사·복구 완료 화면](/assets/images/life/20260828_windows_search_dism_sfc.png)
*출처: 사용자 제공 캡처 / 캡션: DISM 복구 완료와 SFC가 손상 파일을 찾아 복구한 결과*

제 경우 SFC에서 "손상된 파일을 발견하고 성공적으로 복구했습니다"라는 결과가 나왔습니다. 이 문구가 나왔다면 바로 검색창을 확인해 볼 수 있지만, 검은 화면이 계속되면 Windows Search 자체를 초기화해야 합니다.

> DISM과 SFC는 검색 기능만 고치는 도구가 아닙니다. Windows 구성 요소가 손상돼 시작 메뉴·검색·파일 탐색기처럼 여러 기능이 흔들릴 때 함께 점검하는 기본 복구 절차입니다.

---

## 4단계: Microsoft의 Windows Search 재설정 스크립트

Windows 11과 Windows 10 1903 이상에서는 Microsoft가 **ResetWindowsSearchBox.ps1** 스크립트를 이용한 검색 재설정 방법을 안내합니다. 검색창은 열리지만 반응이 없거나 결과가 비정상일 때, 고급 초기화 전에 먼저 시도할 수 있는 공식 방법입니다.

관리자 PowerShell에서 현재 실행 정책을 확인합니다.

```powershell
Get-ExecutionPolicy
```

실행 정책 때문에 스크립트가 막히는 경우에만, 현재 사용자 범위에서 다음 명령을 실행합니다. 기존 값을 먼저 기록해 두고, 스크립트 실행이 끝나면 원래 값으로 되돌립니다.

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted
```

그다음 [Microsoft Learn의 Windows Search 문제 해결 문서](https://learn.microsoft.com/ko-kr/troubleshoot/windows-client/shell-experience/fix-problems-in-windows-search)에서 `ResetWindowsSearchBox.ps1`을 내려받아 파일을 마우스 오른쪽 버튼으로 클릭하고 **PowerShell로 실행**합니다.

---

## 5단계: Windows 11 CBS 검색 구성 재생성

위 단계에서도 검색창이 검다면, Windows 11에서는 `MicrosoftWindows.Client.CBS_cw5n1h2txyewy` 사용자 패키지 폴더와 현재 사용자 Search 레지스트리 키를 다시 생성하는 방법이 남습니다. 제 PC에서 검은 검색창을 복구한 단계도 이 방법이었습니다.

이 작업은 개인 문서·사진을 지우지 않습니다. 대신 **현재 사용자의 검색 설정과 패키지 데이터가 재생성**되고, 검색 인덱싱이 다시 시작됩니다. Microsoft는 레지스트리 수정 전 백업을 권장하며, 사용자 패키지 폴더 삭제는 Windows 복구 환경 또는 다른 관리자 계정에서 진행하도록 안내합니다.

### 5-1. 대상 경로와 레지스트리 키 확인

Windows 11 대상 폴더는 아래 경로입니다. Windows 10은 `Microsoft.Windows.Search_cw5n1h2txyewy`라는 다른 폴더를 사용하므로 같은 명령을 그대로 쓰면 안 됩니다.

```text
Windows 11
%LOCALAPPDATA%\Packages\MicrosoftWindows.Client.CBS_cw5n1h2txyewy

현재 사용자 레지스트리
HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Search
```

### 5-2. 현재 사용자 Search 키 내보내기

영향을 받은 계정으로 로그인한 상태에서 `regedit`를 열고 아래 키로 이동합니다. `Search` 키를 마우스 오른쪽 버튼으로 클릭해 **내보내기**로 백업한 뒤 삭제합니다.

```text
HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Search
```

명령으로 처리할 경우에는 관리자 PowerShell에서 아래 명령을 사용합니다. 이 명령은 현재 사용자 Search 키만 제거합니다.

```powershell
Remove-Item "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Recurse -Force
```

### 5-3. CBS 사용자 패키지 폴더 삭제 후 재등록

다른 관리자 계정 또는 Windows 복구 환경에서 영향을 받은 계정의 CBS 사용자 패키지 폴더를 삭제합니다. 같은 계정에서 진행해야 한다면 SearchHost를 먼저 종료한 뒤 실행합니다.

```powershell
Stop-Process -Name SearchHost -Force -ErrorAction SilentlyContinue
Remove-Item "$env:LOCALAPPDATA\Packages\MicrosoftWindows.Client.CBS_cw5n1h2txyewy" -Recurse -Force
```

마지막으로 관리자 PowerShell에서 Windows 11 CBS 패키지를 다시 등록합니다.

```powershell
Add-AppxPackage -Path "C:\Windows\SystemApps\MicrosoftWindows.Client.CBS_cw5n1h2txyewy\AppxManifest.xml" -DisableDevelopmentMode -Register
```

명령에 빨간 오류가 없으면 PC를 재부팅합니다. 재부팅 뒤 검색 인덱싱과 Search 레지스트리 키, AppData 폴더가 다시 만들어집니다.

---

## 실제로 복구됐는지 확인하는 방법

재부팅 뒤 `Win + S`를 눌러 검색창에 추천 검색어, 최근 항목, 인기 앱이 나타나는지 확인합니다. 아래처럼 검색창 내부 콘텐츠가 보이고 입력할 수 있으면 복구된 상태입니다.

![정상적으로 표시된 Windows 검색창](/assets/images/life/20260828_windows_search_restored.png)
*출처: 사용자 제공 캡처 / 캡션: CBS 검색 구성 초기화와 재부팅 후 정상적으로 표시된 Windows 검색창*

| 확인 항목 | 정상 상태 |
| :--- | :--- |
| 검색창 열기 | `Win + S`를 누르면 바로 표시 |
| 입력 | 검색어가 즉시 입력됨 |
| 화면 구성 | 최근 항목, 인기 앱, 추천 검색어가 표시됨 |
| 파일 검색 | 로컬 파일·앱 결과가 반환됨 |

검색 인덱싱은 초기화 직후 다시 진행될 수 있으므로, 파일 검색 결과의 완성도는 잠시 시간이 걸릴 수 있습니다. 검색창 UI가 정상으로 돌아왔는지와 모든 파일 인덱싱이 끝났는지는 별개의 확인 항목입니다.

## 가장 짧은 해결 순서

1. 작업 관리자에서 SearchHost.exe를 종료한 뒤 검색창을 다시 엽니다.
2. 관리자 PowerShell에서 `WSearch` 서비스를 확인하고 재시작합니다.
3. `DISM.exe /Online /Cleanup-Image /RestoreHealth`를 실행합니다.
4. `sfc /scannow`를 실행합니다.
5. Microsoft의 `ResetWindowsSearchBox.ps1`을 실행합니다.
6. Windows 11이라면 CBS 사용자 패키지·현재 사용자 Search 키를 재생성하고 재부팅합니다.

검은 검색창처럼 UI가 완전히 비는 증상은 `WSearch` 서비스가 실행 중이어도 남을 수 있습니다. 제 경우에는 SearchHost, WebView2 실행 여부와 시스템 파일을 확인한 뒤, 마지막 CBS 패키지·Search 레지스트리 초기화로 해결됐습니다.

## 참고 자료 및 출처

- [Microsoft Learn - Windows Search에서 문제 해결](https://learn.microsoft.com/ko-kr/troubleshoot/windows-client/shell-experience/fix-problems-in-windows-search)
- [Microsoft Support - 시스템 파일 검사기 도구로 손상된 시스템 파일 복구](https://support.microsoft.com/ko-kr/windows/experience/backup-recovery/use-the-system-file-checker-tool-to-repair-missing-or-corrupted-system-files)
- [Microsoft Learn - Windows Search 서비스를 시작할 수 없음](https://learn.microsoft.com/ko-kr/troubleshoot/windows-client/shell-experience/windows-search-service-not-starting)
- 사용자 제공 캡처: 검색창 오류, 작업 관리자, DISM/SFC 결과, 복구 완료 화면

## 구글 SEO 태그

윈도우 검색창 먹통, 윈도우 검색창 검은 화면, Windows Search 오류, SearchHost.exe, 윈도우11 검색창 복구, DISM SFC, Windows Search 재설정, MicrosoftWindows Client CBS, 윈도우 검색 안됨, 윈도우 문제 해결
