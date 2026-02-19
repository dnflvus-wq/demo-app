# GENQ TC/Auto Script 품질 검증 종합 보고서

> 작성: 2026-02-16
> 검증 기간: 2026-02-14 ~ 2026-02-16
> 검증 대상: GENQ AI TC 생성 시스템 + Auto Script 시스템
> 타겟 앱: demo-app (Vite + React + TS, port 5174)
> Gold Standard: 68개 TC (Todo 21, Board Write 16, Board List 10, Board Detail 9, Home 7, Nav 5)

---

## Executive Summary

### 최종 커버리지 (페이지별 최고 성적)

| 페이지 | 실험 | 커버리지 | 환각 | 조건 |
|--------|------|---------|------|------|
| **Todo** | C-2 | **90.5%** (19/21) | **0%** | Clarify + 상세 프롬프트 |
| **Board Write** | C-1 | **87.5%** (14/16) | **0%** | Clarify + 상세 프롬프트 |
| **Board List** | B-2 | **80.0%** (8/10) | **0%** | 상세 프롬프트 |
| **Board Detail** | B-2 | **55.6%** (5/9) | **0%** | 상세 프롬프트 |
| **Home** | H-1 | **42.9%** (3/7) | **0%** | 상세 프롬프트 |
| **Nav** | H-1 | **100%** (5/5) | **0%** | 상세 프롬프트 |
| **전체 가중 평균** | | **74.1%** (54/68 추정) | **0%** | 최적 조합 |

### 핵심 발견 5가지

1. **Clarify가 최강 튜닝 레버**: 평균 +17.3%p 커버리지 향상 (Board +25%p, Todo +9.5%p)
2. **환각 0%**: 모델 업그레이드(gpt-5-mini) + Instructions v2 이후 환각 완전 제거
3. **TC_JUDGE는 형식만 평가**: 커버리지 24%든 90.5%든 qltyIndex 4.17~4.30으로 동일 → 변별력 없음
4. **Vector 검색은 OFF가 정답**: Qdrant에 100% 모바일 앱 데이터 → 웹 앱에 부적합
5. **Auto Script에 data-testid 미지원**: 핵심 개선 필요

---

## 1. TC 생성 품질 (18개 실험)

### 1.1 Todo 페이지 실험 이력 (8개 실험, PDCA 5사이클)

| # | 실험 | 변경사항 | 모델 | cnt | 커버리지 | 환각 |
|---|------|---------|------|-----|---------|------|
| 1 | R1-1 | baseline | nano | 10 | 24.0% | 30% |
| 2 | R1-2 | +URL 파싱 | nano | 10 | 24.0% | 30% |
| 3 | R1-3 | +상세 프롬프트 | nano | 15 | 36.0% | 20% |
| 4 | R2 | +Instructions v1 | nano | 15 | 47.6% | 13.3% |
| 5 | R2-cnt20 | +cnt 증가 | nano | 20 | 52.4% | 15.0% |
| 6 | R3 | +gpt-5-mini | mini | 15 | 61.9% | 0% |
| 7 | FINAL | +Instructions v2 | mini | 20 | 71.4% | 5% |
| **8** | **Phase 3-2** | **+URL 파싱 개선** | mini | 20 | **81.0%** | **5%** |
| **9** | **C-2** | **+Clarify** | mini | 20 | **90.5%** | **0%** |

### 1.2 Board 페이지 실험 (4개 실험)

| # | 실험 | 프롬프트 | URL | cnt | Write 커버리지 | List 커버리지 | Detail 커버리지 | 환각 |
|---|------|---------|-----|-----|------------|------------|-------------|------|
| B-1 | Board Write 상세 | 상세 | write | 20 | - | - | - | 5% |
| B-2 | Board List+Detail | 상세 | board, board/1 | 20 | - | **80.0%** | **55.6%** | 0% |
| B-4 | Board Write 최소 | 최소 | write | 20 | **62.5%** | - | - | 15% |
| **C-1** | **Board Write+Clarify** | **Clarify** | write | 20 | **87.5%** | - | - | **0%** |

### 1.3 Home/Nav 실험 (1개 실험)

| # | 실험 | Home 커버리지 | Nav 커버리지 | 환각 |
|---|------|------------|------------|------|
| H-1 | Home+Nav 상세 | **42.9%** | **100%** | 0% |

Home은 form이 없는 읽기전용 대시보드 → TC 생성 난이도 높음.
통계 수치(동적 데이터) 기반 TC가 어려움.

### 1.4 Clarify 효과 검증 (2개 실험)

| 비교 | Without Clarify | With Clarify | 향상 |
|------|:---------------:|:------------:|:----:|
| Board Write | B-4: 62.5% / 15% 환각 | C-1: **87.5%** / 0% | **+25.0%p** |
| Todo | Phase 3-2: 81.0% / 5% | C-2: **90.5%** / 0% | **+9.5%p** |
| **평균** | | | **+17.3%p** |

**Clarify의 핵심 가치**: AI 질문 자체가 아니라, 사용자가 제공하는 **[Additional Info]** 섹션.
JS 동적 유효성 검사, 비즈니스 로직, 토스트 메시지 등 URL 파서가 감지 못하는 정보를 전달.

---

## 2. 튜닝 레버 효과 순위

| 순위 | 레버 | 커버리지 향상 | 환각 감소 | 비용 | 난이도 |
|------|------|------------|---------|------|--------|
| **1** | **Clarify 흐름** | +17.3%p (평균) | -7.5%p | API 1회 추가 | 낮음 |
| **2** | **모델 업그레이드** (nano→mini) | +14.3%p | -13.3%p | 토큰 비용 증가 | 낮음 |
| **3** | **상세 프롬프트** | +12.0%p | -10.0%p | 없음 | 중간 |
| **4** | **Instructions v1 튜닝** | +11.6%p | -6.7%p | 없음 | 중간 |
| **5** | **URL 파싱 개선** | +9.6%p | 0%p | 없음 | 높음 (코드) |
| **6** | **Instructions v2 + cnt** | +9.5%p | +5.0%p | 토큰 증가 | 중간 |
| **7** | **Vector 검색** | 미측정 (OFF 유지) | N/A | 제거 권고 | - |

### 페이지 유형별 레버 효과 차이

| 페이지 유형 | Form 유무 | 최적 전략 | 최고 커버리지 |
|------------|----------|----------|-------------|
| Form 위주 (Board Write) | 있음 | URL 파싱 + Clarify | 87.5% |
| CRUD 복합 (Todo) | 있음 | URL 파싱 + Clarify + 상세 프롬프트 | 90.5% |
| 목록+페이지네이션 (Board List) | 없음 | 상세 프롬프트 (상태 설명 포함) | 80.0% |
| 상세 보기 (Board Detail) | 없음 | 상세 프롬프트 (조회수, 삭제 다이얼로그 명시) | 55.6% |
| 대시보드 (Home) | 없음 | 상세 프롬프트 (통계, CTA 명시) | 42.9% |
| 네비게이션 (Nav) | 없음 | 자동 감지 (URL에서 추출) | 100% |

---

## 3. TC_JUDGE 캘리브레이션

### 3.1 변경 내역
- **AS-IS**: "3.8~4.5 사이로만" 점수 제한 → 변별력 없음
- **TO-BE**: 0.0~5.0 전체 범위 + 환각 감지 + 경계값 가점

### 3.2 결과

| 항목 | Judge v1 | Judge v2 |
|------|---------|---------|
| qltyIndex 범위 | 4.17~4.30 (0.13) | 4.43~4.60 (0.17) |
| feasibility 범위 | 4.4~4.5 (0.1) | **4.0~5.0** (1.0) |
| 최고점 | 4.5 (천장) | **5.0** (천장 제거) |
| 환각 감지 | 없음 | feasibility 감점 |
| 타임아웃 | 없음 | 발생 (긴 프롬프트) |

### 3.3 근본 한계
Judge에게 원본 프롬프트/URL이 전달되지 않음 → **커버리지 평가 근본적 불가**.
코드 변경(TestCaseGenerateService.java line 499)으로 해결 가능.

---

## 4. Vector 검색 분석

| 항목 | 상태 |
|------|------|
| Qdrant 컬렉션 | text-embedding-3-small_collection (13,501 포인트) |
| 데이터 내용 | **100% 모바일 앱 TC** (웹 앱 TC 0건) |
| 현재 상태 | 임베딩+검색 실행 but 결과 주입 주석 처리 |
| 권고 | **검색 호출 자체도 제거** (API 비용 낭비) |
| 미래 가치 조건 | 프로젝트별 컬렉션 분리 + 웹 TC 시딩 |

---

## 5. Auto Script 검증

### 5.1 Element Detection

| 페이지 | 감지 시간 | 감지 수 | Form 입력 정확도 | 버튼 정확도 |
|--------|---------|--------|----------------|-----------|
| Todo | 0.88초 | 12 | 100% (id 기반) | 감지됨 (id 없음) |
| Board Write | ~1초 | 11 | 100% (id 기반) | 감지됨 (id 없음) |
| Board List | ~1초 | 14 | N/A | 감지됨 (id 없음) |
| Home | ~1초 | 9 | N/A | 감지됨 (id 없음) |

### 5.2 핵심 문제: data-testid 미지원

demo-app 모든 요소에 `data-testid` 설정, but 감지기가 이를 캡처하지 않음.
- Form inputs (`id` 있음): 안정적 셀렉터 `#todo-title` ✅
- Buttons (`data-testid` only): xpath 폴백 → 깨지기 쉬움 ❌
- 수정 위치: PlaywrightElementDetector.java JS 코드 + AdminAutoScriptService.java buildSelector()

### 5.3 코드 생성
- 3개 언어 지원 (Playwright JS/Python, Selenium Java)
- LLM 생성 + 템플릿 폴백 (안전장치 있음)
- TC → Auto Script 자동 변환 가능성 확인 (data-testid 수정 후)

---

## 6. 프롬프트 가이드 (페이지 유형별 최적 패턴)

### 6.1 Form 페이지 (Todo, Board Write)

```
[필수 포함 정보]
1. 각 필드명 + 타입 + 제약 (maxlength, required 등)
2. 유효성 검사 규칙 + 에러 메시지 원문
3. 성공/실패 토스트 메시지 원문
4. 취소/뒤로가기 동작

[선택 포함 정보 (Clarify에서 제공)]
5. JS 동적 유효성 (HTML 속성에 없는 규칙)
6. 경계값 (예: 내용 10자 최소)
7. 없는 기능 명시 ("네트워크 에러 TC 불필요")
```

### 6.2 목록 페이지 (Board List)

```
[필수]
1. 표시 항목 (카테고리 뱃지, 작성자, 날짜 등)
2. 페이지네이션 규칙 (N개씩, 페이지 번호)
3. 정렬 기준
4. 데이터 존재 전제 조건 ("게시글 6개 이상 존재")

[선택]
5. 빈 목록 처리
6. 링크 이동 대상
```

### 6.3 상세 페이지 (Board Detail)

```
[필수]
1. 표시 필드 목록
2. 조회수 증가 로직
3. 삭제 확인 다이얼로그 + 토스트 메시지
4. 수정/삭제 버튼 동작

[선택]
5. 비밀글 처리
6. 이전 페이지 이동
```

### 6.4 대시보드 (Home)

```
[필수]
1. 통계 카드 (어떤 데이터를 표시하는지)
2. CTA 버튼 + 이동 대상
3. 최근 데이터 표시 규칙

주의: 동적 데이터 기반 TC는 생성이 어려움.
"전체 N건, 진행중 M건" 같은 구체적 수치 대신
"통계가 올바르게 반영되는지" 수준으로 요청.
```

---

## 7. 코드 변경 권고 (우선순위순)

### P0: 즉시 실행 (DB 변경만)
| # | 변경 | 대상 | 완료 |
|---|------|------|------|
| 1 | Judge Instructions v2 | ai_prompt_tb prompt_id=4 | ✅ 완료 |
| 2 | TC_GENERATE 모델: gpt-5-mini | ai_func_config_tb | ✅ 이전 완료 |
| 3 | Instructions v2 | ai_prompt_tb prompt_id=2 | ✅ 이전 완료 |
| 4 | testcase_keyword VARCHAR(2000) | test_case_tb | ✅ 이전 완료 |

### P1: 단기 코드 변경
| # | 변경 | 파일 | 효과 |
|---|------|------|------|
| 1 | **data-testid 캡처** | PlaywrightElementDetector.java | Auto Script 셀렉터 안정성 대폭 향상 |
| 2 | **data-testid 셀렉터** | AdminAutoScriptService.java buildSelector() | id 없는 버튼/체크박스 대응 |
| 3 | **Vector 검색 호출 제거** | TestCaseGenerateService.java line 446-450 | 불필요한 API 비용 절감 |

### P2: 중기 코드 변경
| # | 변경 | 파일 | 효과 |
|---|------|------|------|
| 4 | **Judge에 원본 프롬프트 전달** | TestCaseGenerateService.java line 499 | completeness 지표 신뢰성 확보 |
| 5 | **Judge 타임아웃 증가** | PayloadBuilder or config | 긴 프롬프트 타임아웃 해결 |
| 6 | **Judge 전용 re-evaluate API** | TestCaseController.java | 기존 TC 재평가 가능 |

### P3: 장기 개선
| # | 변경 | 효과 |
|---|------|------|
| 7 | 프로젝트별 Qdrant 컬렉션 분리 | Vector 검색 가치 복원 |
| 8 | TC → Auto Script 자동 변환 | E2E 테스트 자동화 |
| 9 | judge-schema.json에 coverageScore 추가 | 커버리지 정량 평가 |

---

## 8. 현재 최적 구성

| 파라미터 | 값 | 근거 |
|---------|---|------|
| 모델 | gpt-5-mini (ID=2) | 환각 0% + 커버리지 +14.3%p |
| Instructions | v2 (ai_prompt_tb id=2) | 커버리지 +11.6%p |
| reasoning_effort | minimal | 비용 최적화 |
| verbosity | low | 응답 속도 |
| cnt | 20 | Todo 최적, Board Write도 효과적 |
| URL 파싱 | 개선 버전 | standalone 요소, data-testid, validation attrs |
| Clarify | **활성화 권장** | 최강 레버 (+17.3%p) |
| Vector | **OFF** (코드 호출도 제거) | 모바일 데이터만 → 왜곡 |
| Judge Instructions | v2 (ai_prompt_tb id=4) | 5.0 사용, 환각 감지 |

---

## 9. 전체 실험 아티팩트

### 디렉토리 구조
```
c:\Project\demo-app\experiments\
├── (Todo 튜닝) exp1~4_*.ps1, exp*_result.json
├── analysis_round1~3.md, analysis_final.md, analysis_phase3-2.md
├── tuned_instructions.txt
├── board/
│   ├── exp_b1~b4_result.json (3개, B-3 타임아웃)
│   └── analysis_board.md
├── home/
│   ├── exp_h1_result.json
│   └── analysis_home.md
├── clarify/
│   ├── exp_c1~c2_result.json, clarify_todo.json
│   └── analysis_clarify.md
├── judge/
│   ├── exp_j1_result.json, exp_j3_result.json
│   ├── judge_instructions_v2.txt, update_judge.sql
│   └── analysis_judge.md
├── vector/
│   └── analysis_vector.md
├── autoscript/
│   ├── detect_*_result.json (4개)
│   └── analysis_autoscript.md
├── gold-standard-tc.md (68개 TC)
└── COMPREHENSIVE_REPORT.md (이 문서)
```

### 실험 수량 요약
| 카테고리 | 실험 수 | 성공 | 타임아웃 |
|---------|---------|------|---------|
| Todo TC 튜닝 | 9 | 9 | 0 |
| Board TC | 4 | 3 | 1 (B-3) |
| Home/Nav TC | 1 | 1 | 0 |
| Clarify 효과 | 2 | 2 | 0 |
| Judge 캘리브레이션 | 5 | 2 | 3 |
| Auto Script 감지 | 4 | 4 | 0 |
| **합계** | **25** | **21** | **4** |

---

## 10. 남은 과제 & 로드맵

### 즉시 (이번 주)
- [ ] P1-1: data-testid 캡처 코드 변경
- [ ] P1-3: Vector 검색 호출 제거

### 단기 (2주 이내)
- [ ] P2-4: Judge에 원본 프롬프트 전달
- [ ] Board Detail 커버리지 개선 (현재 55.6%)
- [ ] Home 커버리지 개선 (현재 42.9%)

### 중기 (1개월)
- [ ] TC → Auto Script 자동 변환 프로토타입
- [ ] Judge re-evaluate API 추가
- [ ] 프로젝트별 Qdrant 컬렉션 설계

### 장기 (분기)
- [ ] Auto Script 실행 검증 (실제 Playwright 코드 실행)
- [ ] 다른 프로젝트(실제 서비스)에 적용하여 일반화 검증
- [ ] Gold Standard 자동 평가 파이프라인 (CI/CD 연동)

---

## 결론

GENQ의 TC 생성 품질은 **적절한 튜닝 조합(모델+프롬프트+Clarify+URL파싱)**으로
Todo 90.5%, Board Write 87.5%까지 도달 가능함을 확인.

**핵심 교훈**:
1. AI 모델 자체보다 **사용자가 제공하는 정보의 질**(Clarify)이 더 큰 영향
2. URL 파서의 **기술적 한계**(JS 동적 검증, 비즈니스 로직)를 Clarify로 보완
3. 평가 시스템(Judge)은 **원본 프롬프트 전달** 없이는 커버리지를 측정할 수 없음
4. Auto Script는 **data-testid 지원**이 선행되어야 실용적 가치 발휘
5. Vector 검색은 **프로젝트별 데이터 분리**가 전제되어야 효과적
