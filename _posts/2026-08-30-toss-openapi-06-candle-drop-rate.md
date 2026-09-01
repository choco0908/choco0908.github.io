---
title: "토스증권 Open API 시작하기 (6) - 캔들 데이터로 전일 대비 하락률 계산하기"
classes: wide
toc: true
toc_sticky: true
toc_label: "목차"
categories:
  - Python
tags:
  - 토스증권 Open API
  - TossInvest
  - Python 자동매매
  - 캔들 데이터
  - 일봉 조회
  - 전일 종가
  - 현재가 조회
  - 조건부 매수
header:
  teaser: "/assets/images/python/20260830_toss-openapi-06-candle-drop-rate_01_cover.svg"
description: "토스증권 Open API의 현재가 조회와 일봉 캔들 조회를 이용해 삼성전자의 전일 종가 대비 하락률을 계산하고 매수 후보 조건으로 분리합니다."
last_modified_at: 2026-08-30T09:00:00+09:00
---

![토스증권 Open API 6편 캔들 데이터 하락률 계산](/assets/images/python/20260830_toss-openapi-06-candle-drop-rate_01_cover.svg)

지난 5편에서는 아주 단순한 조건을 만들어봤습니다.

> 삼성전자 현재가가 60,000원 이하이면 1주 매수한다.

처음 자동매매 코드를 만들 때는 이런 가격 조건이 가장 이해하기 쉽습니다. 그런데 막상 전략처럼 쓰려고 하면 조금 아쉬운 부분이 생깁니다. 60,000원이라는 숫자는 고정된 기준이라, 시장 상황이 바뀌어도 그대로 남아 있습니다.

그래서 이번 글에서는 가격을 하나 더 가져와보려고 합니다.

> 오늘 현재가가 전일 종가보다 몇 % 하락했는지 계산한다.

이렇게 하면 "무조건 60,000원 이하"가 아니라 "어제보다 얼마나 밀렸는가"를 기준으로 조건을 만들 수 있습니다. 자동매매다운 조건문으로 한 걸음 더 들어가는 셈입니다.

---

## 1. 왜 전일 종가가 필요했나

5편의 조건은 단순했습니다.

```text
현재가 <= 60,000원
```

이 조건은 읽기 쉽지만, 종목의 최근 흐름을 반영하지 못합니다. 예를 들어 삼성전자가 어제 70,000원이었는데 오늘 67,000원이 되었다면 약 4.3% 하락입니다. 반대로 어제 60,500원이었는데 오늘 60,000원이 되었다면 하락률은 1%도 되지 않습니다.

둘 다 "60,000원 근처"라는 말로 묶을 수 있지만, 가격이 내려온 맥락은 다릅니다.

> 현재가는 지금의 가격이고, 전일 종가는 오늘 움직임을 해석하는 기준점입니다.

---

## 2. 사용할 API 확인하기

이번에 사용할 API는 두 가지입니다.

| API | 용도 |
| :--- | :--- |
| `GET /api/v1/prices` | 현재가 조회 |
| `GET /api/v1/candles` | 캔들 차트 조회 |

캔들 조회 API의 주요 파라미터는 `symbol`, `interval`, `count`, `before`, `adjusted`입니다. 전일 종가를 구하려면 일봉이 필요하므로 `interval="1d"`를 사용합니다.

현재 명세 기준 캔들 주기는 `1m`, `1d`를 지원하고, 최대 200개 봉을 조회할 수 있습니다. 응답의 `closePrice`가 종가입니다.

---

## 3. SDK로 일봉 조회하기

현재 SDK에서는 캔들 조회를 `client.market.candles()`로 호출할 수 있고, 일봉은 `daily_candles()`로 조금 더 간단하게 호출할 수 있습니다.

```python
from tossinvestsdk import TossClient

client = TossClient()

candles = client.market.daily_candles(
    "005930",
    count=5,
)

for candle in candles:
    print(candle.timestamp, candle.close_price)
```

`CandlesResult`는 반복 가능한 모델로 만들어두었기 때문에 `for candle in candles`처럼 사용할 수 있습니다.

| 속성 | 의미 |
| :--- | :--- |
| `open_price` | 시가 |
| `high_price` | 고가 |
| `low_price` | 저가 |
| `close_price` | 종가 |
| `volume` | 거래량 |
| `change_percent` | 해당 봉의 시가 대비 종가 등락률 |

여기서 주의할 점이 하나 있습니다. `change_percent`는 "전일 대비 등락률"이 아니라 **해당 봉의 시가 대비 종가 등락률**입니다.

우리가 원하는 건 현재가와 전일 종가의 비교이므로 직접 계산해야 합니다.

---

## 4. 전일 종가 고르는 함수 만들기

장중에 코드를 실행하면 최신 일봉이 오늘 날짜일 수 있습니다. 이 경우 전일 종가는 그 다음 캔들입니다.

반대로 주말이나 장 시작 전에 실행하면 최신 일봉이 이미 전 거래일일 수 있습니다. 이 경우 최신 캔들의 종가가 기준이 됩니다.

그래서 "오늘 날짜보다 과거인 가장 최신 일봉"을 찾는 방식으로 작성했습니다.

```python
from datetime import datetime
from zoneinfo import ZoneInfo


def candle_date(candle):
    return datetime.fromisoformat(candle.timestamp).date()


def find_previous_close(candles):
    today = datetime.now(ZoneInfo("Asia/Seoul")).date()

    for candle in candles:
        if candle_date(candle) < today:
            return candle.close_price

    raise RuntimeError("전 거래일 종가를 찾지 못했습니다.")
```

조금 돌아가는 것처럼 보이지만, 자동매매 코드에서는 이런 방어적인 처리가 마음을 편하게 해줍니다. 캔들 데이터는 장중, 장마감 후, 휴장일에 따라 최신 봉의 의미가 조금씩 달라질 수 있습니다.

---

## 5. 현재가와 전일 종가 비교하기

이제 현재가와 전일 종가를 함께 가져와서 하락률을 계산해보겠습니다.

![전일 종가 대비 하락률 계산식](/assets/images/python/20260830_toss-openapi-06-candle-drop-rate_02_formula.svg)

```python
from decimal import Decimal
from datetime import datetime
from zoneinfo import ZoneInfo

from tossinvestsdk import TossClient


def candle_date(candle):
    return datetime.fromisoformat(candle.timestamp).date()


def find_previous_close(candles):
    today = datetime.now(ZoneInfo("Asia/Seoul")).date()

    for candle in candles:
        if candle_date(candle) < today:
            return candle.close_price

    raise RuntimeError("전 거래일 종가를 찾지 못했습니다.")


def change_rate(current_price, previous_close):
    return (
        (current_price - previous_close)
        / previous_close
        * Decimal("100")
    )


client = TossClient()

symbol = "005930"

current = client.market.price(symbol).get(symbol)
candles = client.market.daily_candles(symbol, count=5)

previous_close = find_previous_close(candles)
current_price = current.last_price
drop_rate = change_rate(current_price, previous_close)

print(f"현재가: {current_price}원")
print(f"전일 종가: {previous_close}원")
print(f"전일 대비 등락률: {drop_rate:.2f}%")
```

예를 들어 전일 종가가 70,000원이고 현재가가 67,900원이라면 계산은 이렇게 됩니다.

```text
(67,900 - 70,000) / 70,000 * 100 = -3.00%
```

이 값이 바로 전략 조건으로 사용할 수 있는 하락률입니다.

---

## 6. 하락률 조건을 매수 후보로 바꾸기

5편의 조건은 고정 가격이었습니다.

```text
삼성전자가 60,000원 이하이면 매수
```

이번에는 기준을 이렇게 바꿉니다.

```text
삼성전자가 전일 종가 대비 3% 이상 하락하면 매수 후보로 본다
```

바로 실주문을 넣기보다, 이번 글에서는 후보 판정까지만 해보겠습니다.

```python
target_drop_rate = Decimal("-3")

if drop_rate <= target_drop_rate:
    print("매수 후보 조건 충족")
else:
    print("아직 매수 후보가 아닙니다")
```

전일 대비 3% 하락했다고 무조건 좋은 매수 기회는 아닙니다. 시장 전체가 밀리는 날인지, 종목 자체 악재가 있는지, 거래량이 충분한지, 이미 미체결 주문이 있는지 등을 함께 봐야 합니다.

> 자동매매에서 좋은 조건문은 바로 주문을 넣는 문장이 아니라, 다음 확인 단계로 넘겨주는 문장에 가깝습니다.

---

## 7. 실거래 코드로 옮기기 전 체크

이번 글의 코드는 아직 실주문 코드가 아닙니다.

![자동매매 실거래 전 안전 체크](/assets/images/python/20260830_toss-openapi-06-candle-drop-rate_03_safety.svg)

나중에 주문과 연결한다면 최소한 아래 항목은 확인해야 합니다.

| 확인 항목 | 이유 |
| :--- | :--- |
| 매수 가능 금액 | 주문 가능 여부 확인 |
| 미체결 주문 | 같은 종목 중복 주문 방지 |
| 장 시간 | 장전/장중/장후 주문 가능 여부 확인 |
| 거래량 | 가격만 보고 들어가는 실수 방지 |
| dry-run 결과 | 실제 주문 전 신호 품질 점검 |

특히 새 주문형 전략은 `dry_run=True`를 기본값으로 두고 검증하는 것이 안전합니다. Dry-run에서는 실제 주문 API를 호출하지 않고, 신호 판단과 가상 체결, 수수료, 포지션, 손익, 로그까지 먼저 확인합니다.

---

## 8. 마무리

이번 글에서는 캔들 데이터를 이용해 전일 종가를 구하고, 현재가가 전일 종가 대비 몇 % 움직였는지 계산해봤습니다.

| 단계 | 내용 |
| :--- | :--- |
| 1 | 현재가 조회 |
| 2 | 일봉 캔들 조회 |
| 3 | 전 거래일 종가 선택 |
| 4 | 현재가와 전일 종가 비교 |
| 5 | 하락률 기준으로 매수 후보 판단 |

5편에서는 고정 가격을 기준으로 조건을 만들었습니다. 6편에서는 전일 종가라는 기준 가격을 추가했습니다.

작은 차이지만 전략 입장에서는 꽤 큰 변화입니다. 이제 코드는 "얼마 이하인가"뿐만 아니라 "어제와 비교해서 얼마나 움직였는가"를 볼 수 있게 됐습니다.

다음 글에서는 이 조건을 바로 실주문으로 연결하지 않고, 먼저 **dry-run으로 주문 없이 전략을 검증하는 구조**를 만들어보겠습니다.

## 참고 자료

- [토스증권 Open API 문서](https://developers.tossinvest.com/docs)
- [토스증권 OpenAPI latest openapi.json](https://openapi.tossinvest.com/openapi-docs/latest/openapi.json)
- [Python datetime 공식 문서](https://docs.python.org/3/library/datetime.html)
- [Python zoneinfo 공식 문서](https://docs.python.org/3/library/zoneinfo.html)
