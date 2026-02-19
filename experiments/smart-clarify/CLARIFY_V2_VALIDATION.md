# Smart Clarify v2 - Validation Report

> Date: 2026-02-19
> Target: demo-app /board/write (16 gold-standard TCs)

## Summary

**PASS** - Clarify v2가 TC 품질을 유의미하게 향상시킴을 확인.

## A/B Test Results

| Condition | Coverage | TC Count | Missed Gold TCs |
|-----------|----------|----------|-----------------|
| A (Baseline - prompt only) | 10/16 = **62.5%** | 30 | WRITE-003,004,010,012,013,014 |
| B (Clarify v2 - with context) | 14/16 = **87.5%** | 30 | WRITE-012,013 |
| **Delta (B - A)** | **+25.0%p** | - | 4 TCs recovered |

## Pass Criteria

| Criteria | Target | Result | Status |
|----------|--------|--------|--------|
| B Coverage >= 60% | 60% | 87.5% | PASS |
| B > A | positive delta | +25.0%p | PASS |

## Clarify Context Effect Analysis

### B가 추가로 커버한 TC (4개)
- **WRITE-003** (질문 카테고리): clarifyContext에 "카테고리 선택(자유/공지/질문)" 명시
- **WRITE-004** (비밀글): clarifyContext에 "비밀글 체크박스" 명시
- **WRITE-010** (9자 경계값): clarifyContext에 "최소 10자" 규칙 명시
- **WRITE-014** (글자수 카운터): clarifyContext에 "글자수 카운터 실시간 표시" 명시

### 둘 다 실패한 TC (2개)
- **WRITE-012** (에러 클리어): "입력 시 에러 사라짐" 패턴 - AI가 잘 생성 못 하는 영역
- **WRITE-013** (다중 에러 동시): "모든 필드 빈값 동시 에러" - 복합 시나리오

## v2 Feature Validation

| Feature | Status | Notes |
|---------|--------|-------|
| 주관식 textarea | PASS | 항상 하단에 표시, placeholder + 글자수 카운터 |
| sanitizeCounts() | PASS | AI의 비정상 counts [3,5,7] → [30,50,70] 보정 |
| recalculateTcCount() | PASS | 선택 비율 기반 재계산, "(추천)" 버튼 표시 |
| buildClarifyContext() | PASS | 선택 + freeText → clarifyContext 문자열 |
| Browser UI | PASS | ClarifyModal 정상 렌더링, 옵션 선택/해제, TC개수 변경 |

## Architecture Decision

- **v1 AI 스키마 유지**: gpt-4o-mini가 새 필드(freeTextHint, complexityFactors) 미준수
- **FE에서 구조 보강**: sanitizeCounts(), recalculateTcCount(), always-visible textarea
- **결과**: AI=콘텐츠 품질 담당, FE=구조 보정 담당 → 더 안정적

## clarifyContext Used in Test B

```
이 페이지에 어떤 입력 요소가 있나요?: 제목 입력란, 작성자 입력란, 카테고리 선택, 내용 텍스트영역, 비밀글 체크박스
등록 버튼 클릭 후 성공/실패 시 피드백은?: 성공 시 목록으로 이동 + 토스트 메시지, 실패 시 각 필드별 에러 메시지 표시
입력 필드의 유효성 규칙은?: 제목 필수(maxLength 100), 작성자 필수, 내용 필수(최소 10자), 카테고리 선택(자유/공지/질문)
[추가 설명] 글 수정 모드에서는 기존 값이 폼에 로드되며, 페이지 제목이 '글 수정'으로 바뀜. 내용 입력 시 글자수 카운터 실시간 표시.
```
