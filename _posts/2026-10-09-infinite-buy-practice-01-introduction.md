---
title: '무한매수법 실제 적용기 1편: 매수보다 먼저 이해해야 할 사이클'
date: '2026-10-09T00:00:00+09:00'
last_modified_at: '2026-10-09T00:00:00+09:00'
classes: wide
toc: false
toc_sticky: true
toc_label: 목차
categories:
- Python
tags:
- 무한매수법
- 자동매매
- 토스증권
- OpenAPI
- 파이썬
- 사이클관리
- 분할매수
- 레버리지ETF
- 미국주식
- 투자리스크
description: 무한매수법을 적용한 운영 화면으로 사이클과 매수 진행·매도 대기·완료 상태를 짧게 소개합니다.
canonical_url: https://choco0908.github.io/python/infinite-buy-practice-01-introduction/
header:
  teaser: /assets/images/python/20261009_infinite-buy-practice-01-introduction_screen_redacted.png
---

토스증권 API 연결은 [이전 글의 인증·계좌 조회](https://choco0908.tistory.com/101)에서 다뤘어요. 이번에는 그 프로그램으로 운용 중인 무한매수법을 소개하려고 합니다.

## 무한매수법, 어떻게 적용했나요?

**무한매수법은 자금을 나누어 반복 매수하고 매도 기준에 따라 투자 구간을 마치는 방식이에요.** 출발점은 라오어 작가의 모델입니다. 나는 소수점 매수와 수익 목표 관리, 여러 사이클 구분을 더해 운용하고 있어요.

![운용 중인 Cycle Map을 바탕으로 수치를 가린 공개용 편집본](/assets/images/python/20261009_infinite-buy-practice-01-introduction_screen_redacted.png)

운용 화면의 종목·상태를 남긴 공개용 편집본이에요. 금액·수량 등은 가렸습니다.

## 같은 SOXL에 왜 카드가 여러 개일까요?

**사이클은 매수부터 보유·청산까지 묶어 보는 운영 단위예요.** 같은 SOXL도 매수를 이어가는 사이클과 매도를 기다리는 사이클이 함께 있습니다. 계좌의 종목별 합계만 볼 때는 놓치기 쉬운 차이죠.

### 화면의 상태, 이렇게 읽어요

| 질문 | 답변 |
| --- | --- |
| 매수 진행은 무엇인가요? | 매수를 이어가는 사이클이에요. |
| 매도 대기는 매도가 끝났다는 뜻인가요? | 보유분의 매도를 기다리는 상태예요. 실제 체결과는 구분합니다. |
| 완료 카드는 수익을 냈다는 뜻인가요? | 종료된 사이클이에요. 손익은 따로 확인해야 합니다. |

화면의 SOXL에는 세 상태가 함께 보입니다. TECL·TQQQ·UPRO도 진행 중인 카드와 완료 카드가 나뉘어 있어요.

사이클을 나눠도 같은 종목의 하락 영향을 함께 받습니다. **완료 카드뿐 아니라 아직 묶여 있는 자금도 같이 봐야 해요.**

실주문 전에는 아래 항목을 확인합니다.

- 새 주문형 전략은 `dry_run=True` 기본값으로 검증. 기존 운용 모드와는 구분
- 매수 가능 금액·미체결 주문·매도 가능 수량 확인
- 주문 접수와 실제 체결 구분

관련 구현은 [주문 정정·취소 편](https://choco0908.tistory.com/119)과 [실주문 없는 dry-run 검증 편](https://choco0908.github.io/python/toss-openapi-07-dry-run-strategy/)에 정리해뒀어요.

다음 편에서는 백테스트로 수익률과 낙폭, 자금 부담을 함께 살펴보겠습니다.

이 글은 투자 권유가 아닙니다. 원금 손실 가능성이 있고 과거 성과는 미래 수익을 보장하지 않습니다. 투자 결정과 손익의 책임은 투자자 본인에게 있습니다.

참고: [시공사 도서 소개](https://www.sigongsa.com/books/bookView.php?bookcode=SB006976&catecode=01010501), [SOXL](https://www.direxion.com/product/daily-semiconductor-bull-bear-3x-etfs), [TECL](https://www.direxion.com/product/daily-technology-bull-bear-3x-etfs), [TQQQ](https://www.proshares.com/our-etfs/leveraged-and-inverse/tqqq), [UPRO](https://www.proshares.com/our-etfs/leveraged-and-inverse/upro). 네 상품은 일간 3배 목표 ETF이며 장기 수익의 3배를 보장하지 않습니다. 기준 시점: 2026-10-09.

#무한매수법 #자동매매 #토스증권 #OpenAPI #파이썬 #사이클관리 #분할매수 #레버리지ETF #미국주식 #투자리스크
