# NEXT-3: Clarify 흐름 효과 검증 분석

> 실험일: 2026-02-15
> 분석 대상: C-1 (Board Write) + C-2 (Todo)
> 핵심 비교: Clarify 없음 vs Clarify 있음 (동일 프롬프트/URL/cnt)

---

## 1. 실험 설계

### 1.1 Clarify 흐름 개요

```
[Step 1] POST /api/v1/testcases/clarify?prompt="DemoApp board write page test"
         → AI가 구조화된 질문 3개 생성 (gpt-4o-mini, TC_CLARIFY 함수)

[Step 2] 사용자가 질문에 정확한 답변 제공

[Step 3] POST /api/v1/testcases/generate/file
         prompt: "DemoApp 게시판 글 작성 페이지의 기능 테스트" (B-4와 동일!)
         urls: ["http://localhost:5174/board/write"]
         clarifyContext: Step 2의 답변
         cnt: 20
```

**핵심**: B-4와 동일한 최소 프롬프트 + 동일 URL + 동일 cnt. 유일한 차이는 `clarifyContext`.

### 1.2 Clarify AI가 생성한 질문 (3개)

| # | 질문 유형 | 질문 내용 | 선택지 |
|---|----------|----------|--------|
| Q1 | multi-select | "어떤 비정상 시나리오를 중점적으로 테스트하시겠습니까?" | 1.필수 필드 누락 2.최대 길이 초과 3.특수문자 입력 4.네트워크 오류 |
| Q2 | multi-select | "어떤 경계 조건을 확인하시겠습니까?" | 1.빈 값 입력 2.최대 허용 길이 3.최소 길이 제한 4.특수문자/이모지 |
| Q3 | single-select | "어떤 사용자 유형을 고려하시겠습니까?" | 1.일반 사용자 2.관리자 3.비인증 사용자 4.여러 동시 사용자 |

### 1.3 제공한 clarifyContext (정확한 답변)

```
[User Answers]
Q1: Focus on required field missing, max length exceeded, content minimum length violation.
    No network error testing needed (localStorage app).
Q2: Include empty title/content, max title length 100, content minimum 10 chars boundary
    (9 chars fail, 10 chars pass), special characters.
Q3: Single user type only, no admin distinction.

[Additional Info]
- Edit mode exists at /board/write/{id} with pre-loaded data and button text changes to modify.
- Toast messages: registration success shows toast, edit success shows toast.
- Cancel button navigates back.
- Category select has 3 options.
- Secret post checkbox available.
- Character counter shows below content field.
- Page title differs between new and edit mode.
- Error messages clear when user starts typing in the field.
- Multiple validation errors can show simultaneously.
```

---

## 2. C-1 결과 개요

| 지표 | 값 |
|------|---|
| TC 수 | 20 |
| 생성 시간 | 48.64초 |
| qltyIndex | 4.25 |
| trust | 4.26 |
| serviceName | DemoApp (정확) |

---

## 3. C-1 Gold Standard 매칭 (Board Write 16개)

### 3.1 매칭 상세

| Gold Standard | ID | C-1 매칭 TC | 결과 | 비고 |
|---------------|-----|-------------|------|------|
| 정상 글 등록 (자유) | WRITE-001 | TC-2 "정상 입력 후 등록 성공 및 등록 토스트" | **O** | 자유 선택, data-testid 완벽, 토스트 언급 |
| 공지 카테고리 등록 | WRITE-002 | - | **X** | TC-13이 옵션 3개 목록만 확인, 실제 공지 등록+뱃지 확인 안 함 |
| 질문 카테고리 등록 | WRITE-003 | - | **X** | TC-13에서 질문 존재는 확인하나, 등록+뱃지 미검증 |
| 비밀글 등록 | WRITE-004 | TC-12 "비밀글 체크박스 체크/해제" | **O** | post-secret 정확, 토글 동작 |
| 글 수정 | WRITE-005 | TC-14 "기존값 로드+버튼명" + TC-15 "수정 저장+토스트" | **O** | 진입+저장 2개 TC로 완전 커버 |
| 취소 버튼 | WRITE-006 | TC-11 "취소 → 이전 페이지 이동" | **O** | post-cancel-btn 정확 |
| 제목 빈값 | WRITE-007 | TC-3 "제목 빈값 제출 시 필수 오류" | **O** | post-title 정확 |
| 작성자 빈값 | WRITE-008 | TC-20 "작성자 빈값 등록 시 동작" | **O** | post-author 정확 (양쪽 기대결과 제시) |
| 내용 빈값 | WRITE-009 | TC-4 "내용 빈값 제출 시 필수 오류" | **O** | post-content 정확 |
| 내용 9자 경계값 | WRITE-010 | TC-5 "9자 입력 시 최소 길이 오류 (경계값 -1)" | **O** | "정확히 9자" 명시, functionCategory3="유효성경계" |
| **내용 10자 통과** | **WRITE-011** | **TC-6 "10자 입력 시 정상 등록 가능 (경계값 통과)"** | **O ★** | **최초 달성! "정확히 10자" + 등록 성공 확인** |
| **에러 클리어** | **WRITE-012** | **TC-10 "오류 메시지 입력 시 자동 사라짐" + TC-17 "특정 오류만 해소"** | **O ★** | **최초 달성! 기본+고급 2개 TC** |
| **다중 에러 동시** | **WRITE-013** | **TC-16 "여러 필드 동시 오류 메시지 노출"** | **O ★** | **제목 빈값+내용 9자 조합** |
| **글자수 카운터** | **WRITE-014** | **TC-9 "내용 입력 시 문자 수 카운터 갱신"** | **O ★** | **최초 달성! 실시간 갱신 확인** |
| 제목 maxLength 100 | WRITE-015 | TC-7 "101자 초과 입력 시 잘림 또는 오류" | **O** | maxlength=100 적용 확인 |
| **페이지 제목 구분** | **WRITE-016** | **TC-1 "페이지 타이틀 '글 작성'" + TC-14 "편집 모드 버튼명"** | **O ★** | **최초 달성! 신규/수정 구분** |

### 3.2 C-1 커버리지 결과

| 지표 | 값 |
|------|---|
| **커버리지** | **14/16 = 87.5%** |
| **환각** | **0/20 = 0.0%** |
| **data-testid 활용률** | **95% (18/19 유효 TC)** |
| **유효 TC** | **19/20 (TC-19는 "건너뜀" 선언)** |

---

## 4. C-1 vs B-4 비교: Clarify 효과 정량화

### 4.1 핵심 비교 (동일 프롬프트, 동일 URL, 동일 cnt)

| 지표 | B-4 (Clarify 없음) | C-1 (Clarify 있음) | **차이** |
|------|:------------------:|:------------------:|:--------:|
| 커버리지 | 62.5% (10/16) | **87.5% (14/16)** | **+25.0%p** |
| 환각 | 5.0% (1/20) | **0.0% (0/20)** | **-5.0%p** |
| data-testid | 80% | **95%** | +15%p |
| qltyIndex | 4.25 | 4.25 | 0 (무변별) |
| 생성 시간 | 51.3s | 48.6s | -2.7s |

### 4.2 Clarify가 새로 열어준 TC (B-4에 없고 C-1에 있음)

| Gold Standard | ID | Clarify 기여 메커니즘 |
|---------------|-----|----------------------|
| 내용 10자 통과 | WRITE-011 | clarifyContext: "9 chars fail, 10 chars pass" → 양방향 경계값 |
| 에러 클리어 | WRITE-012 | clarifyContext: "Error messages clear when user starts typing" |
| 다중 에러 동시 | WRITE-013 | clarifyContext: "Multiple validation errors can show simultaneously" |
| 글자수 카운터 | WRITE-014 | clarifyContext: "Character counter shows below content field" |
| 페이지 제목 구분 | WRITE-016 | clarifyContext: "Page title differs between new and edit mode" |

**5개 TC 모두 clarifyContext에 직접 명시한 정보에서 생성됨** → Clarify 인과관계 확인.

### 4.3 B-4에 있고 C-1에 없는 TC

| Gold Standard | ID | B-4 매칭 TC | C-1 상태 |
|---------------|-----|-------------|---------|
| 공지 카테고리 등록 | WRITE-002 | TC-18 "카테고리별 선택 - 공지" | TC-13에서 옵션 확인만, 등록 미수행 |

**B-4 → C-1에서 1개 TC만 퇴보 (WRITE-002)**. Clarify에서 카테고리별 등록 시나리오를 언급하지 않았기 때문.

### 4.4 합산 커버리지 (B-4 ∪ C-1)

| Gold Standard | B-4 | C-1 | 합산 |
|---------------|:---:|:---:|:----:|
| WRITE-001 | O | O | O |
| WRITE-002 | O | X | **O** |
| WRITE-003 | X | X | **X** |
| WRITE-004 | O | O | O |
| WRITE-005 | O | O | O |
| WRITE-006 | O | O | O |
| WRITE-007 | O | O | O |
| WRITE-008 | O | O | O |
| WRITE-009 | O | O | O |
| WRITE-010 | O | O | O |
| WRITE-011 | X | **O** | **O** |
| WRITE-012 | X | **O** | **O** |
| WRITE-013 | X | **O** | **O** |
| WRITE-014 | X | **O** | **O** |
| WRITE-015 | O | O | O |
| WRITE-016 | X | **O** | **O** |

**B-4 ∪ C-1 합산: 15/16 = 93.8%** — WRITE-003 (질문 카테고리)만 미달.

---

## 5. 환각 완전 제거 분석

### 5.1 B-4의 환각 vs C-1

| 실험 | 환각 수 | 환각 내용 |
|------|:------:|----------|
| B-4 | 1 (5%) | TC-14 "서버 오류(500) 발생 처리" |
| **C-1** | **0 (0%)** | **환각 없음** |

### 5.2 C-1에서 환각이 사라진 원인

1. **clarifyContext의 "No network error testing needed (localStorage app)"** → 서버 에러 환각 방지
2. **구체적인 테스트 범위 명시** → AI가 명시된 시나리오에 집중, 추측 감소
3. **"Single user type only, no admin distinction"** → 사용자 유형 관련 불필요 TC 방지

### 5.3 주목할 TC-19 ("건너뜀" 선언)

```
TC-19: "빈 목록 상태(관련 없음) — 빈 목록 안내 메시지 확인 불필요"
testStep: "해당 화면은 글작성 화면으로 빈 목록 상태 관련 없음"
expectedResult: "해당 테스트는 건너뜀"
```

**B-1에서는 "빈 목록 상태 안내문구 표시"를 환각으로 생성했으나, C-1에서는 "이것은 글작성 화면이므로 관련 없음"으로 자체 인식.**

이는 Clarify의 범위 명확화 효과. AI가 "무엇을 테스트해야 하는지"뿐 아니라 "무엇을 테스트하지 말아야 하는지"도 학습.

---

## 6. 개별 TC 품질 분석

### 6.1 최초 달성 TC 상세

#### WRITE-011: 내용 10자 통과 (★ C-1 TC-6)

```
testStep: "내용에 정확히 10자 입력 (data-testid=post-content) → [등록] 선택"
expectedResult: "등록 동작이 완료되고 이전 페이지 또는 목록으로 이동 + '등록 성공' 토스트"
```

- **B-1/B-4 모두 9자(미달)만 생성, 10자(통과)는 미생성** → Clarify "9 chars fail, 10 chars pass"가 직접 트리거
- Gold Standard와 거의 완벽 일치
- **이것이 양방향 경계값 테스트의 핵심** — Clarify 없이는 달성 불가

#### WRITE-012: 에러 클리어 (★ C-1 TC-10 + TC-17)

TC-10 (기본):
```
precondition: "필수값 누락으로 오류 상태가 화면에 표시되어 있어야 함"
testStep: "오류가 표시된 필드에 한 글자 입력"
expectedResult: "해당 필드의 오류 메시지가 입력 시작과 함께 사라짐"
```

TC-17 (고급 - 필드별 독립 클리어):
```
precondition: "제목과 내용 모두 오류 상태"
testStep: "제목 필드에 한 글자 입력, 내용은 그대로 둠"
expectedResult: "제목 오류 사라지고, 내용 오류는 계속 표시"
```

- **2개 TC로 기본+고급 시나리오 모두 커버** — Gold Standard(WRITE-012)보다 깊이 있는 테스트!
- Clarify "Error messages clear when user starts typing" + "Multiple validation errors simultaneously"의 복합 효과

#### WRITE-014: 글자수 카운터 (★ C-1 TC-9)

```
testStep: "내용 필드에 텍스트 입력 시작, 한 글자씩 입력/삭제하며 하단 문자수 카운터 확인"
expectedResult: "내용 필드 아래 문자수 카운터가 입력 길이에 맞게 실시간 갱신되어 표시"
```

- **JS 동적 동작 TC** — URL 파서가 감지 불가능한 기능
- Clarify "Character counter shows below content field"가 직접 트리거
- **Clarify 없이는 원천적으로 생성 불가능한 TC**

#### WRITE-016: 페이지 제목 구분 (★ C-1 TC-1 + TC-14)

TC-1: 신규 모드에서 "글 작성" 타이틀
TC-14: 편집 모드에서 기존값 로드 + 버튼명 "수정"

- Clarify "Page title differs between new and edit mode" + "Edit mode at /board/write/{id}"의 효과
- 2개 TC로 신규/수정 양쪽 모두 검증

### 6.2 data-testid 활용 품질

| TC | 사용된 data-testid | 정확도 |
|----|-------------------|:------:|
| TC-1 | post-form, post-title, post-author, post-category, post-secret, post-content, post-cancel-btn, post-save-btn | 100% |
| TC-2 | post-title, post-author, post-category, post-secret, post-content, post-save-btn | 100% |
| TC-3~6 | post-title, post-author, post-content, post-save-btn | 100% |
| TC-9 | post-content | 100% |
| TC-10 | post-title, post-content | 100% |
| TC-11 | post-cancel-btn | 100% |
| TC-12 | post-secret | 100% |
| TC-13 | post-category | 100% |
| TC-15~17 | post-title, post-content, post-save-btn | 100% |
| TC-18 | post-title, post-content, post-cancel-btn | 100% |
| TC-20 | post-title, post-author, post-content, post-save-btn | 100% |

**data-testid 정확도: 100% (잘못된 testid 0건)**

---

## 7. Clarify 질문의 질 분석

### 7.1 질문이 커버리지 갭을 메울 수 있었는가?

| 커버리지 갭 (B-4 미달) | Clarify 질문에서 다루는가? | 답변으로 해결? |
|----------------------|:---------------------:|:----------:|
| WRITE-003 질문 카테고리 | X (카테고리별 테스트 미질문) | **X** |
| WRITE-011 10자 통과 | **O** (Q2 "최소 길이 제한") | **O** |
| WRITE-012 에러 클리어 | X (직접 질문 없음) | **O** (답변에서 추가 정보로 제공) |
| WRITE-013 다중 에러 | X (직접 질문 없음) | **O** (답변에서 추가 정보로 제공) |
| WRITE-014 글자수 카운터 | X (직접 질문 없음) | **O** (답변에서 추가 정보로 제공) |
| WRITE-016 페이지 제목 구분 | X (직접 질문 없음) | **O** (답변에서 추가 정보로 제공) |

### 7.2 핵심 발견: 질문보다 [Additional Info]가 더 중요

Clarify 질문(Q1~Q3) 자체는 **일반적인 QA 질문** (비정상 시나리오, 경계 조건, 사용자 유형).
이 질문들은 WRITE-011 (경계값 통과)만 직접 트리거.

**진짜 효과는 [Additional Info] 섹션에서 사용자가 자발적으로 추가한 정보**:
- "Edit mode exists at /board/write/{id}" → WRITE-005, 016
- "Character counter shows below content field" → WRITE-014
- "Error messages clear when user starts typing" → WRITE-012
- "Multiple validation errors can show simultaneously" → WRITE-013

### 7.3 시사점: Clarify 흐름의 진짜 가치

Clarify의 가치는 AI 질문 자체가 아니라, **사용자에게 "추가 정보를 제공할 기회"를 주는 것**.

AI 질문 → 사용자가 "그렇지, 이것도 있었지" 하고 추가 정보 기입 → 파서가 감지 불가능한 JS 동작/비즈니스 로직 전달.

---

## 8. 전체 실험 이력 비교 (Board Write)

| # | 실험 | 프롬프트 | Clarify | 커버리지 | 환각 | 핵심 변화 |
|---|------|---------|:-------:|:-------:|:----:|----------|
| B-1 | 상세 | 상세 (유효성 규칙 포함) | X | 56.3% (9/16) | 15.0% | baseline (상세) |
| B-4 | 최소 | "기능 테스트" 1줄 | X | 62.5% (10/16) | 5.0% | 상세 < 최소 발견 |
| **C-1** | **최소+Clarify** | **"기능 테스트" 1줄** | **O** | **87.5% (14/16)** | **0.0%** | **Clarify +25%p** |

### 8.1 누적 향상 추이

```
B-1 (상세)     ███████████░░░░░░░░░  56.3%  환각 15.0%
B-4 (최소)     ████████████░░░░░░░░  62.5%  환각  5.0%
C-1 (Clarify)  █████████████████░░░  87.5%  환각  0.0%
                                              ↑
                                     Clarify 효과: +25%p 커버리지, -5%p 환각
```

### 8.2 Todo 최적 결과와 비교

| 지표 | Todo (Phase 3-2, 최적) | Board Write C-1 |
|------|:---------------------:|:--------------:|
| 커버리지 | 81.0% (17/21) | **87.5% (14/16)** |
| 환각 | 5.0% (1/20) | **0.0% (0/20)** |
| 실험 횟수 | 8회 (PDCA 5사이클) | 4회 (B-1,B-4,C-1 + B-2참고) |

**C-1이 Todo 최적 결과를 능가!** 그리고 훨씬 적은 실험 횟수로 달성.

---

## 9. Clarify 효과 메커니즘 정리

### 9.1 Clarify가 해결한 문제 유형

| 문제 유형 | 예시 | URL 파서 | 프롬프트 | Clarify |
|----------|------|:--------:|:-------:|:-------:|
| HTML 속성 기반 | maxlength, required | O | 불필요 | 불필요 |
| 인터랙션 패턴 | 클릭→이동, 입력→제출 | O | 불필요 | 불필요 |
| JS 유효성 규칙 | content 10자 최소 | **X** | △ (명시 필요) | **O** |
| JS 동적 UI | 글자수 카운터, 에러 클리어 | **X** | △ (명시 필요) | **O** |
| 비즈니스 로직 | 수정 모드, 페이지 제목 구분 | **X** | △ | **O** |
| 없는 기능 명시 | 검색 없음, 서버 에러 없음 | **X** | **O** | **O** |

**Clarify의 핵심 영역: "URL 파서가 감지 불가능한 JS 동작/비즈니스 로직"**

### 9.2 최적 TC 생성 공식

```
최적 결과 = 최소 프롬프트 + URL 파싱 + Clarify 컨텍스트
         = (1줄 기능 설명) + (자동 UI spec 추출) + (사용자 추가 정보)
```

상세 프롬프트가 아닌 Clarify로 정보를 전달하면:
- AI의 "주의력 편향" 방지 (상세 프롬프트의 문제)
- 구조화된 정보 전달 (Q&A 형식)
- 사용자가 "빠진 것"을 자연스럽게 보충

---

## 10. Clarify 비용 대비 효과

### 10.1 추가 비용

| 항목 | 값 |
|------|---|
| Clarify API 호출 | 1회 (gpt-4o-mini, 저비용) |
| 사용자 답변 시간 | ~2분 (질문 읽고 답변) |
| TC 생성 시간 | 48.6s (B-4 51.3s보다 오히려 빠름) |

### 10.2 효과

| 항목 | 값 |
|------|---|
| 커버리지 향상 | +25.0%p (62.5% → 87.5%) |
| 환각 제거 | -5.0%p (5.0% → 0.0%) |
| 새로 달성한 TC | 5개 (WRITE-011,012,013,014,016) |
| data-testid 향상 | +15%p (80% → 95%) |

### 10.3 ROI 계산

- **추가 비용**: gpt-4o-mini 1회 (~$0.001) + 사용자 2분
- **추가 가치**: 5개 TC × 수동 작성 비용(~10분/TC) = ~50분 절약
- **ROI**: 2분 투자 → 50분 절약 = **25배 ROI**

---

## 11. 남은 미달 항목 분석

### 11.1 C-1에서도 미달인 2개

| ID | TC명 | 미달 원인 | 해결 가능성 |
|----|------|----------|-----------|
| WRITE-002 | 공지 카테고리 등록 | Clarify에서 카테고리별 테스트를 언급 안 함 | Clarify 답변에 "각 카테고리(공지/자유/질문)별 등록 TC 필요" 추가 시 해결 가능 |
| WRITE-003 | 질문 카테고리 등록 | 동일 | 동일 |

### 11.2 이론적 최대 달성 가능 커버리지

Clarify에서 "공지/자유/질문 각각 등록 후 뱃지 확인" 정보를 추가하면:
→ **16/16 = 100% 달성 가능**

현재 미달은 Clarify "답변의 완전성" 문제이지, 시스템 한계가 아님.

---

## 12. 결론

### 12.1 핵심 결론

1. **Clarify는 가장 강력한 단일 튜닝 레버**: +25%p 커버리지 향상 (모델 업그레이드 +14.3%p의 약 1.8배)
2. **환각 완전 제거**: Clarify 컨텍스트가 AI의 추측 범위를 제한
3. **"URL 파서 한계"를 완전 보완**: JS 동적 동작, 비즈니스 로직, 경계값 양방향 → Clarify로 전달
4. **사용자 2분 투자로 50분 절약**: 극도로 높은 ROI
5. **TC_JUDGE는 여전히 무변별**: C-1(87.5%) = B-4(62.5%) = 4.25점

### 12.2 튜닝 레버 종합 순위 (업데이트)

| 순위 | 레버 | 커버리지 기여 | 환각 기여 |
|:---:|------|:-----------:|:--------:|
| **1** | **Clarify 컨텍스트** | **+25.0%p** | **-5.0%p** |
| 2 | 모델 업그레이드 (nano→mini) | +14.3%p | -13.3%p |
| 3 | 상세 프롬프트 | +12.0%p | -10.0%p |
| 4 | Instructions v1 | +11.6%p | -6.7%p |
| 5 | URL 파싱 개선 | +9.6%p | 0%p |
| 6 | Instructions v2 + cnt | +9.5%p | +5.0%p |

### 12.3 최적 TC 생성 전략 (Board 기준)

```
1. 최소 프롬프트: "DemoApp 게시판 글 작성 페이지의 기능 테스트" (1줄)
2. URL 제공: 해당 페이지 URL (파서가 UI spec 자동 추출)
3. Clarify 흐름 사용: AI 질문 + [Additional Info]로 JS 동작/비즈니스 로직 전달
4. cnt=20: 충분한 TC 슬롯
5. 없는 기능 명시: "검색 없음", "서버 에러 없음" (환각 방지)
```

→ 이 전략으로 Board Write **87.5% 커버리지 + 0% 환각** 달성.
→ Clarify 답변 보완 시 **이론적 100% 가능**.

---

## 13. C-2: Todo + Clarify 실험

### 13.1 실험 설계

| 항목 | Phase 3-2 (baseline) | C-2 (Clarify) |
|------|:-------------------:|:-------------:|
| 프롬프트 | 상세 | "DemoApp Todo management page test" (최소) |
| URL | http://localhost:5174/todo | 동일 |
| Clarify | 없음 | **있음** |
| 모델/Instructions | gpt-5-mini + v2 | 동일 |
| cnt | 20 | 20 |

### 13.2 Clarify 질문 및 답변

**AI 질문 (3개)**:
- Q1 (multi): "집중적으로 테스트할 비정상 시나리오는 무엇인가요?"
- Q2 (multi): "입력값 경계 조건 중 포함할 항목은 무엇인가요?"
- Q3 (single): "사용자 역할에 따른 테스트가 필요한가요?"

**제공한 Additional Info (핵심)**:
- Description is optional (can be empty)
- Priority: 높음(red)/보통(yellow)/낮음(gray), default=보통
- Edit mode: cancel resets form + priority to 보통 + button "추가" restore
- Delete: confirm dialog → toast
- Filter + Search: AND logic combination
- Completed: strikethrough + gray + bg-gray-50
- Empty list: encouragement message
- localStorage persistence: survives page refresh
- Toast messages for add/edit/delete

### 13.3 Gold Standard 매칭 (Todo 21개)

| Gold Standard | ID | C-2 매칭 TC | 결과 | 비고 |
|---------------|-----|-------------|------|------|
| Todo 추가 (전체 필드) | TODO-001 | TC-1 | **O** | 제목+설명+우선순위+토스트+localStorage |
| Todo 추가 (제목만) | TODO-002 | - | **X** | 설명 비움 독립 TC 미생성 |
| Todo 완료 토글 | TODO-003 | TC-4 | **O** | line-through, text-gray-400, bg-gray-50 명시 |
| Todo 완료 해제 | TODO-004 | TC-5 | **O** | 스타일 복원 확인 |
| Todo 수정 | TODO-005 | TC-6 | **O** | 기존값 로드+수정+토스트+모드 복원 |
| **Todo 수정 취소** | **TODO-006** | **TC-7** | **O ★** | **폼 초기화+우선순위 보통+버튼 '추가' 복원** |
| Todo 삭제 확인 | TODO-007 | TC-8 | **O** | 확인→제거+토스트+localStorage 삭제 |
| Todo 삭제 취소 | TODO-008 | TC-9 | **O** | 취소→유지 |
| 필터: 전체 | TODO-009 | TC-10 | **O** | 활성 스타일(bg-white, text-blue-600, shadow) |
| 필터: 진행중 | TODO-010 | TC-11 | **O** | |
| 필터: 완료 | TODO-011 | TC-12 | **O** | |
| 검색 - 매칭 | TODO-012 | TC-13 | **O** | 대소문자 무시 |
| 검색 - 결과 없음 | TODO-013 | TC-14 | **O** | |
| **검색 + 필터 조합** | **TODO-014** | **TC-15** | **O ★** | **"두 조건 모두 적용" AND 로직** |
| 빈 제목 제출 | TODO-015 | TC-2 | **O** | |
| 제목 maxLength 50 | TODO-016 | TC-3 | **O** | |
| 에러 메시지 클리어 | TODO-017 | - | **X** | Clarify 답변에 미포함 |
| 우선순위 전수 확인 | TODO-018 | TC-16 | **O** | 3색 모두 확인 |
| 빈 목록 상태 | TODO-019 | TC-17 | **O** | |
| 수정 모드 UI 변경 | TODO-020 | TC-6+TC-7 | **O** | 버튼 '수정' 변경 + 취소 버튼 |
| **localStorage 영속성** | **TODO-021** | **TC-20** | **O ★** | **새로고침 후 유지 확인** |

### 13.4 C-2 커버리지 결과

| 지표 | 값 |
|------|---|
| **커버리지** | **19/21 = 90.5%** |
| **환각** | **0/20 = 0.0%** |
| **data-testid 활용률** | **70% (14/20 TC)** |
| **중복 TC** | 2/20 (TC-18≈TC-4+5, TC-19≈TC-7) |

### 13.5 Phase 3-2 vs C-2 비교

| 지표 | Phase 3-2 (Clarify 없음) | C-2 (Clarify 있음) | 차이 |
|------|:----------------------:|:------------------:|:----:|
| 커버리지 | 81.0% (17/21) | **90.5% (19/21)** | **+9.5%p** |
| 환각 | 5.0% (1/20) | **0.0% (0/20)** | **-5.0%p** |
| 생성 시간 | ~40s | 38.8s | 유사 |
| qltyIndex | 4.20 | 4.28 | +0.08 (무의미) |

### 13.6 Clarify가 새로 열어준 TC (Phase 3-2에서 누락)

| Gold Standard | ID | Clarify 기여 메커니즘 |
|---------------|-----|----------------------|
| 수정 취소 | TODO-006 | "Cancel resets form, priority to 보통, button back to 추가" |
| 검색+필터 조합 | TODO-014 | "both conditions apply simultaneously (AND logic)" |
| localStorage 영속성 | TODO-021 | "data persists across page refresh" |
| 수정 모드 UI | TODO-020 | TC-6의 "버튼 텍스트 '수정'" + TC-7의 "버튼 '추가' 복원" |

### 13.7 C-2 미달 분석

| ID | TC명 | 미달 원인 | 해결 방법 |
|----|------|----------|----------|
| TODO-002 | Todo 추가 (제목만) | "description optional" 정보는 있으나 독립 TC 미생성 | Clarify에 "설명 비움 시나리오 TC 필요" 명시 |
| TODO-017 | 에러 메시지 클리어 | Clarify 답변에 에러 클리어 동작 미포함 | Clarify에 "에러 입력 시 사라짐" 추가 시 해결 가능 |

**두 미달 모두 Clarify 답변의 누락이 원인** — 시스템 한계가 아닌 답변 완전성 문제.

---

## 14. C-1 + C-2 종합: Clarify 효과 최종 정리

### 14.1 두 실험의 일관된 결과

| 지표 | C-1 (Board Write) | C-2 (Todo) | 평균 |
|------|:-----------------:|:----------:|:----:|
| 커버리지 향상 | +25.0%p | +9.5%p | **+17.3%p** |
| 환각 감소 | -5.0%p | -5.0%p | **-5.0%p** |
| 최종 커버리지 | 87.5% | 90.5% | **89.0%** |
| 최종 환각 | 0.0% | 0.0% | **0.0%** |

### 14.2 Clarify 효과가 Board Write(+25%p)에서 더 큰 이유

1. **Board Write는 baseline이 낮았음** (62.5% vs 81%) → 개선 여지가 더 많음
2. **Board Write에 JS 동적 동작이 더 많음**: 글자수 카운터, 에러 클리어, 페이지 제목 구분 → Clarify 없이는 불가
3. **Todo는 이미 8회 실험+튜닝** → Instructions가 Todo에 최적화되어 baseline이 높음

### 14.3 Clarify 답변 완전성 vs 커버리지 상관관계

| 답변에 포함 | C-1 효과 | C-2 효과 |
|-----------|:--------:|:--------:|
| 경계값 양방향 (9자 실패/10자 통과) | WRITE-011 ★ | N/A (Todo에 해당 없음) |
| 에러 클리어 | WRITE-012 ★ | TODO-017 **미포함→미달** |
| 다중 에러 동시 | WRITE-013 ★ | N/A |
| 글자수 카운터 | WRITE-014 ★ | N/A |
| 페이지 제목 구분 | WRITE-016 ★ | N/A |
| 수정 취소 (폼 초기화) | 이미 커버 | TODO-006 ★ |
| 필터+검색 AND | N/A | TODO-014 ★ |
| localStorage 영속성 | N/A | TODO-021 ★ |

**핵심 패턴: Clarify 답변에 명시한 것 → TC 생성됨. 누락한 것 → TC 미생성.**

이것은 Clarify 시스템이 **충실하게 사용자 정보를 반영**한다는 증거.

### 14.4 최종 튜닝 레버 순위 (전체 실험 기반)

| 순위 | 레버 | Board Write 기여 | Todo 기여 | 종합 |
|:---:|------|:---------------:|:--------:|:----:|
| **1** | **Clarify 컨텍스트** | **+25.0%p** | **+9.5%p** | **최강** |
| 2 | 모델 업그레이드 | +14.3%p | - | 강 |
| 3 | 상세 프롬프트 | +12.0%p | - | 중 |
| 4 | Instructions v1 | +11.6%p | - | 중 |
| 5 | URL 파싱 개선 | +9.6%p | - | 중 |
| 6 | Instructions v2 + cnt | +9.5%p | - | 중 |

### 14.5 이론적 100% 달성 경로

**Board Write**: C-1(87.5%) + "각 카테고리(공지/자유/질문)별 등록 TC" 답변 추가 → **16/16 = 100%**

**Todo**: C-2(90.5%) + "에러 입력 시 클리어" + "설명 비움 시나리오" 답변 추가 → **21/21 = 100%**

**두 페이지 모두 Clarify 답변 보완만으로 이론적 100% 가능** — 시스템 한계가 아닌 답변 완전성 문제.

---

## 15. NEXT 단계 제안

- **NEXT-4 (TC_JUDGE 캘리브레이션)**: qltyIndex가 90.5%와 62.5%를 구분 못함 → 가장 시급
- **Instructions v3**: Clarify 없이도 에러 클리어, 경계값 양방향 등 자동 생성 → 비 Clarify 경로 품질 향상
- **Clarify 답변 가이드**: 사용자가 빠뜨리기 쉬운 항목 체크리스트 제공 (에러 클리어, localStorage, 수정 모드 등)
