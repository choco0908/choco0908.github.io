---
title: "토스증권 Open API 시작하기 (7) - dry-run으로 실제 주문 없이 전략 검증하기"
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
  - dry-run
  - 종이 주문
description: "토스증권 Open API와 Python으로 자동매매 전략을 만들 때 실제 주문 전에 dry-run으로 신호, 종이 주문, 상태 저장을 검증하는 과정을 정리합니다."
last_modified_at: 2026-09-06T19:55:00+09:00
---

![토스증권 Open API 7편 dry-run 전략 검증](/assets/images/python/20260906_toss-openapi-07-dry-run-strategy_01_cover.png)

지난 6편에서는 삼성전자의 현재가를 전일 종가와 비교해서 하락률을 계산했습니다.

> 삼성전자가 전일 종가 대비 3% 이상 하락하면 매수 후보로 본다.

조건을 숫자로 만들고 나면 다음 단계는 자연스럽게 주문입니다. 그런데 자동매매에서는 이 지점에서 한 번 멈추는 편이 좋습니다.

코드가 처음으로 실제 계좌와 연결되는 순간부터는 단순한 if 문도 주문 버튼이 됩니다. 가격 조회는 몇 번 틀려도 다시 고치면 되지만, 주문은 한 번 나가면 체결, 취소, 정정, 잔고 반영까지 따라옵니다.

그래서 이번 글에서는 6편에서 만든 하락률 조건을 바로 실주문으로 연결하지 않고, 먼저 dry-run으로 검증하는 구조를 만들어보겠습니다.

> 오늘의 목표: 전일 대비 3% 이상 하락 신호가 나오면 실제 주문 대신 PAPER 주문을 기록한다.

이번 글 역시 투자 권유가 아니라 토스증권 Open API와 Python으로 자동매매 프로그램을 안전하게 만들어가는 개발 기록입니다.

---

## 1. 왜 바로 주문하지 않았나

6편의 마지막 코드는 이렇게 끝났습니다.

```python
target_drop_rate = Decimal("-3")

if drop_rate <= target_drop_rate:
    print("매수 후보 조건 충족")
else:
    print("아직 매수 후보가 아닙니다")
```

여기서 `print()` 대신 주문 코드를 넣으면 일단 동작은 만들어집니다.

```python
if drop_rate <= target_drop_rate:
    client.order.buy_market(
        symbol="005930",
        quantity=1,
    )
```

하지만 이렇게 바로 붙이면 확인할 수 있는 것이 너무 적습니다.

정말 내가 생각한 시점에 신호가 발생했는지, 같은 종목에 이미 미체결 주문이 있는지, 장 시간이 맞는지, 주문 가능 금액이 충분한지, 기록 파일에는 어떤 값이 남는지 알기 어렵습니다.

자동매매 코드는 수익을 내기 전에 먼저 "내가 의도한 대로만 움직이는지"를 보여줘야 합니다. 그래서 저는 새 주문형 전략을 만들 때 실주문보다 dry-run을 먼저 붙이는 쪽으로 기준을 잡았습니다.

---

## 2. dry-run, mock, backtest 구분하기

처음에는 dry-run, mock, backtest가 비슷해 보였습니다. 전부 실제 주문을 하지 않는다는 점에서는 같으니까요.

그런데 자동매매 프로그램을 만들다 보면 세 가지의 역할이 조금씩 다릅니다.

| 구분 | 쓰는 시점 | 핵심 |
| :--- | :--- | :--- |
| mock | 테스트 코드에서 API 응답을 가짜로 바꿀 때 | 특정 상황을 재현한다 |
| backtest | 과거 데이터로 전략 규칙을 돌려볼 때 | 규칙의 과거 동작을 비교한다 |
| dry-run | 실제 실행 흐름에서 주문만 종이 주문으로 바꿀 때 | 실시간에 가까운 운영 흐름을 확인한다 |

mock은 단위 테스트에 가깝습니다. 예를 들어 현재가가 59,900원일 때 조건이 참이 되는지 확인할 수 있습니다.

backtest는 과거 데이터를 많이 넣고 전략을 반복 재생합니다. 어떤 조건이 너무 자주 발생하는지, 손절과 익절 기준이 어느 정도 영향을 주는지 볼 때 좋습니다.

dry-run은 조금 더 운영에 가깝습니다. 실제 실행 시간, 실제 API 응답, 실제 상태 저장 흐름을 사용하되 마지막 주문만 `PAPER` 주문으로 남깁니다.

![dry-run 실행 흐름](/assets/images/python/20260906_toss-openapi-07-dry-run-strategy_02_flow.png)

이 차이를 분리해두면 글을 쓰는 입장에서도, 코드를 고치는 입장에서도 훨씬 덜 헷갈립니다.

---

## 3. 프로젝트의 dry-run 기준

현재 프로젝트에서는 새 주문형 전략의 설정 기준을 `DryRunStrategyConfig`로 잡았습니다.

핵심은 단순합니다.

```python
from dataclasses import dataclass

from tossinvestsdk.strategy.base_config import BaseStrategyConfig


@dataclass(slots=True)
class DryRunStrategyConfig(BaseStrategyConfig):
    dry_run: bool = True
```

새 전략은 기본값이 `dry_run=True`입니다. 실주문을 하려면 설정에서 명시적으로 `dry_run=False`를 넣어야 합니다.

실수하기 쉬운 부분도 하나 있습니다. 설정 파일에서는 boolean이 문자열로 들어오는 경우가 있습니다.

```json
{
  "dry_run": "false"
}
```

Python에서 문자열 `"false"`는 truthy 값입니다. 그냥 `bool("false")`로 처리하면 `True`가 되어버립니다. 그래서 현재 구현에서는 `"true"`, `"false"`, `"on"`, `"off"`, `1`, `0`처럼 허용할 값만 명확히 파싱하고, 애매한 값은 예외로 막습니다.

```python
@staticmethod
def coerce_dry_run(value: bool | int | str) -> bool:
    if isinstance(value, bool):
        return value
    if isinstance(value, int) and value in (0, 1):
        return bool(value)
    if isinstance(value, str):
        normalized = value.strip().lower()
        if normalized in {"true", "1", "yes", "on"}:
            return True
        if normalized in {"false", "0", "no", "off"}:
            return False
    raise ValueError("dry_run must be a boolean value")
```

작은 코드지만 자동매매에서는 이런 부분이 꽤 중요합니다. 설정 하나 잘못 읽어서 실주문 경로가 열리면 안 되기 때문입니다.

---

## 4. 6편의 조건을 종이 주문으로 바꾸기

이제 6편에서 만든 하락률 조건을 dry-run 흐름으로 바꿔보겠습니다.

먼저 주문처럼 기록할 작은 모델을 만듭니다.

```python
from dataclasses import dataclass
from decimal import Decimal


@dataclass(slots=True)
class PaperOrder:
    order_id: str
    symbol: str
    side: str
    quantity: int
    reference_price: Decimal
    reason: str
    dry_run: bool = True
```

실제 주문 API 응답과 완전히 같을 필요는 없습니다. 이 단계에서 중요한 것은 "왜 이 주문이 만들어졌는지"를 나중에 다시 볼 수 있게 남기는 것입니다.

그다음 신호를 주문 후보로 바꿉니다.

```python
from datetime import datetime
from decimal import Decimal


def make_paper_order(
    *,
    symbol: str,
    current_price: Decimal,
    drop_rate: Decimal,
    quantity: int,
) -> PaperOrder:
    now = datetime.now().strftime("%Y%m%d%H%M%S")
    return PaperOrder(
        order_id=f"PAPER-drop-buy-{symbol}-{now}",
        symbol=symbol,
        side="BUY",
        quantity=quantity,
        reference_price=current_price,
        reason=f"전일 대비 {drop_rate:.2f}% 하락",
    )
```

그리고 조건문은 이렇게 바뀝니다.

```python
target_drop_rate = Decimal("-3")

if drop_rate <= target_drop_rate:
    order = make_paper_order(
        symbol="005930",
        current_price=current_price,
        drop_rate=drop_rate,
        quantity=1,
    )
    print(order)
else:
    print("아직 매수 후보가 아닙니다")
```

이 코드의 핵심은 주문 함수가 호출되지 않는다는 점입니다. 조건은 실제로 판단하지만, 결과는 종이 주문으로만 남깁니다.

---

## 5. 상태 파일에 남겨보기

콘솔 출력만으로는 나중에 확인하기 어렵습니다. dry-run은 기록까지 남겨야 의미가 있습니다.

가장 단순한 형태로 JSON 파일에 저장해보겠습니다.

```python
import json
from dataclasses import asdict
from pathlib import Path


def save_paper_order(order: PaperOrder, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    payload = asdict(order)
    payload["reference_price"] = str(order.reference_price)

    path.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
```

저장되는 값은 이런 모양입니다.

```json
{
  "order_id": "PAPER-drop-buy-005930-20260906103000",
  "symbol": "005930",
  "side": "BUY",
  "quantity": 1,
  "reference_price": "67900",
  "reason": "전일 대비 -3.00% 하락",
  "dry_run": true
}
```

실제 프로젝트의 가격·거래량 전략은 여기서 한 단계 더 나아가 `pending_orders`, `positions`, `trade_history`, `audit_log`를 따로 관리합니다.

처음부터 그 구조를 전부 따라 만들 필요는 없습니다. 다만 dry-run을 "주문을 안 하는 옵션" 정도로만 두면 나중에 검증할 정보가 부족해집니다.

제가 생각하는 최소 기록은 네 가지입니다.

| 기록 | 이유 |
| :--- | :--- |
| 신호 발생 시각 | 언제 조건이 참이 되었는지 확인 |
| 기준 가격 | 어떤 가격을 보고 판단했는지 확인 |
| 주문 방향과 수량 | 실제 주문으로 바꿀 때의 영향 확인 |
| 판단 사유 | 나중에 로그만 보고도 맥락 확인 |

---

## 6. 실주문 경로는 명시적으로만 열기

dry-run 코드가 생겼다면 이제 실주문 경로도 안전하게 분기할 수 있습니다.

```python
def submit_buy_signal(
    *,
    client,
    config,
    symbol: str,
    current_price: Decimal,
    drop_rate: Decimal,
    quantity: int,
):
    if config.dry_run:
        order = make_paper_order(
            symbol=symbol,
            current_price=current_price,
            drop_rate=drop_rate,
            quantity=quantity,
        )
        save_paper_order(order, Path("strategy_state") / f"{symbol}.paper.json")
        return order

    return client.order.buy_market(
        symbol=symbol,
        quantity=quantity,
    )
```

이렇게 두면 기본 실행은 종이 주문으로 끝납니다.

실제 주문을 하려면 설정에서 직접 꺼야 합니다.

```python
config = DryRunStrategyConfig(
    dry_run=False,
)
```

물론 이 한 줄을 넣기 전에 할 일이 많습니다. 매수 가능 금액 조회, 미체결 주문 조회, 장 시간 확인, 주문 수량 제한, 예외 처리, 체결 확인, 상태 저장 실패 시 중단 같은 안전장치가 먼저 있어야 합니다.

![실주문 전 안전 게이트](/assets/images/python/20260906_toss-openapi-07-dry-run-strategy_03_safety.png)

---

## 7. 테스트로 확인한 부분

dry-run 설정은 단순해 보여도 테스트를 꼭 두는 편이 좋습니다.

예를 들어 현재 프로젝트에는 이런 테스트가 있습니다.

```python
def test_dry_run_config_defaults_to_paper_mode():
    assert DryRunStrategyConfig().dry_run is True
```

기본값이 종이 주문 모드인지 확인합니다.

문자열 설정도 확인합니다.

```python
@pytest.mark.parametrize(
    ("value", "expected"),
    [(False, False), (0, False), ("off", False), ("false", False), ("on", True)],
)
def test_dry_run_config_parses_explicit_mode(value, expected):
    assert DryRunStrategyConfig(dry_run=value).dry_run is expected
```

그리고 애매한 값은 거부합니다.

```python
def test_dry_run_config_rejects_ambiguous_values():
    with pytest.raises(ValueError, match="dry_run"):
        DryRunStrategyConfig(dry_run="paper")
```

`"paper"`라는 말은 사람이 보기에는 dry-run처럼 느껴질 수 있습니다. 하지만 프로그램 입장에서는 공식적으로 허용한 값이 아니므로 막는 편이 낫습니다.

자동매매 설정은 친절한 추측보다 명확한 실패가 더 안전합니다.

---

## 8. 실거래 전에 확인할 것

이번 글의 코드는 실제 주문을 넣지 않습니다. 그래도 나중에 실주문과 연결하려면 아래 항목을 dry-run 로그에서 먼저 확인해야 합니다.

| 확인 항목 | 봐야 하는 이유 |
| :--- | :--- |
| 신호 빈도 | 조건이 너무 자주 발생하지 않는지 확인 |
| 중복 주문 | 같은 종목에 종이 주문이 여러 번 생기지 않는지 확인 |
| 미체결 처리 | 주문 후 체결 전 상태를 관리할 수 있는지 확인 |
| 매수 가능 금액 | 실제 주문 가능 금액 안에서 수량이 계산되는지 확인 |
| 예외 처리 | API 실패나 저장 실패가 조용히 묻히지 않는지 확인 |

특히 저장 실패는 가볍게 보면 안 됩니다. 주문은 나갔는데 상태 파일 저장이 실패하면, 다음 실행에서 프로그램은 자신이 무엇을 했는지 모를 수 있습니다.

dry-run 단계에서 이런 실패 흐름을 먼저 겪어보는 것이 좋습니다. 실제 돈이 움직이지 않을 때 발견한 버그가 가장 싸게 고친 버그입니다.

---

## 9. 마무리

이번 글에서는 6편의 하락률 조건을 실제 주문으로 연결하지 않고, dry-run으로 종이 주문을 남기는 구조를 만들어봤습니다.

흐름은 이렇게 정리할 수 있습니다.

| 단계 | 내용 |
| :--- | :--- |
| 1 | 현재가와 전일 종가로 하락률 계산 |
| 2 | 하락률 조건으로 매수 후보 판단 |
| 3 | 실제 주문 대신 `PAPER` 주문 생성 |
| 4 | 주문 사유와 기준 가격을 상태 파일에 저장 |
| 5 | 실주문은 `dry_run=False`를 명시한 경우에만 검토 |

자동매매를 만들다 보면 빨리 주문까지 연결하고 싶어집니다. 저도 그랬습니다. 그런데 막상 코드를 오래 굴릴수록, 주문보다 기록이 먼저라는 생각이 강해집니다.

기록이 있어야 신호를 믿을 수 있고, 신호를 믿을 수 있어야 주문을 검토할 수 있습니다.

다음 글에서는 이 흐름을 한 단계 더 넓혀서 WebSocket으로 실시간 체결과 호가 데이터를 받아보겠습니다. 현재가를 한 번 조회하는 방식에서 벗어나, 장중에 가격이 움직이는 모습을 프로그램이 계속 따라가게 만드는 단계입니다.

## 참고 자료

- [토스증권 Open API 문서](https://developers.tossinvest.com/docs)
- [토스증권 OpenAPI latest openapi.json](https://openapi.tossinvest.com/openapi-docs/latest/openapi.json)
- [Python dataclasses 공식 문서](https://docs.python.org/3/library/dataclasses.html)
- [Python json 공식 문서](https://docs.python.org/3/library/json.html)
- 프로젝트 기준: `tossinvestsdk/strategy/dry_run.py`, `tests/test_dry_run_config.py`
