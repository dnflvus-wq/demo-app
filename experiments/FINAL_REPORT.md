# GENQ TC 생성 품질 검증 & 튜닝 종합 보고서

> 프로젝트 기간: 2026-02-15
> 작성자: PM/PL
> 대상 시스템: GENQ AI TC 생성 파이프라인
> 검증 대상: DemoApp (Todo + 게시판, c:\Project\demo-app\)

---

## 1. Executive Summary

GENQ의 AI 기반 TC(테스트케이스) 생성 품질을 정량적으로 검증하고, 체계적 튜닝을 통해 **커버리지 24% → 81%, 환각 30% → 5%**로 개선했다.

| 지표 | 튜닝 전 | 튜닝 후 | 개선폭 |
|------|---------|---------|--------|
| Gold Standard 커버리지 | 24% (5/21) | **81% (17/21)** | **+57% (3.4배)** |
| 환각(Hallucination) 비율 | 30% (3/10) | **5% (1/20)** | **-25% (6배 감소)** |
| data-testid 활용률 | 0% | **60%+** | **신규** |
| 생성 시간 (cnt=20) | - | ~49s | 허용 범위 |

---

## 2. 검증 방법론

### 2.1 Gold Standard 접근법
1. 데모앱의 **모든 기능을 직접 파악**하여 "이상적인 TC" 문서 작성
2. GENQ API로 동일 페이지에 대한 TC를 생성
3. 생성된 TC와 Gold Standard를 **1:1 매칭**하여 커버리지/환각 측정
4. 파라미터를 **1개씩 변경**하며 A/B 테스트 (PDCA 사이클)

### 2.2 Gold Standard TC (Todo 페이지, 21개)
| 카테고리 | TC 수 | 예시 |
|---------|------|------|
| CRUD (추가/수정/삭제) | 8 | 전체 필드 추가, 제목만 추가, 수정 저장/취소, 삭제 확인/취소 |
| 필터/검색 | 5 | 전체/진행중/완료 필터, 검색 매칭/미매칭, 검색+필터 조합 |
| 상태변경 | 2 | 완료 토글, 완료 해제 |
| 유효성/경계값 | 4 | 빈 제목, maxLength 50, 우선순위 전수, 에러 클리어 |
| 기타 | 2 | 빈 목록 상태, localStorage 영속성 |

### 2.3 평가 기준
- **커버리지**: Gold Standard TC 중 생성된 TC가 의미적으로 매칭되는 비율
- **환각**: 앱에 존재하지 않는 기능에 대한 TC 비율
- **정확도**: testStep/expectedResult가 실제 앱 동작과 일치하는 정도
- **data-testid 활용**: TC에서 정확한 셀렉터를 참조하는 비율

---

## 3. 전체 실험 진행 (8개 실험)

| # | 실험 | 변경사항 | 모델 | cnt | 커버리지 | 환각 | 시간 |
|---|------|---------|------|-----|---------|------|------|
| 1 | R1-1 기본 | baseline | nano | 10 | 24% | 30% | 22s |
| 2 | R1-2 URL | +URL 파싱 | nano | 10 | 24% | 30% | 27s |
| 3 | R1-3 상세 | +상세 프롬프트 | nano | 15 | 36% | 20% | 41s |
| 4 | R2 튜닝 | +Instructions v1 | nano | 15 | 47.6% | 13.3% | 22s |
| 5 | R2 cnt=20 | +cnt 증가 | nano | 20 | 52.4% | 15.0% | 34s |
| 6 | R3 모델 | +gpt-5-mini | mini | 15 | 61.9% | 0% | 33s |
| 7 | FINAL | +Instructions v2 | mini | 20 | 71.4% | 5% | 40s |
| **8** | **Phase 3-2** | **+URL 파싱 개선** | mini | 20 | **81.0%** | **5%** | **49s** |

---

## 4. 튜닝 레버별 기여도 분석

### 4.1 개별 기여도

| 순위 | 튜닝 레버 | 커버리지 기여 | 환각 감소 | 난이도 |
|:---:|----------|:-----------:|:--------:|:-----:|
| 1 | **모델 업그레이드** (nano→mini) | +14.3% | -13.3% | LOW |
| 2 | **상세 프롬프트** | +12.0% | -10.0% | LOW |
| 3 | **Instructions v1 튜닝** | +11.6% | -6.7% | LOW |
| 4 | **URL 파싱 개선** | +9.6% | 0% | MEDIUM |
| 5 | **Instructions v2 + cnt** | +9.5% | +5% | LOW |

### 4.2 핵심 발견

#### A. 모델이 가장 큰 단일 효과
gpt-5-nano → gpt-5-mini 변경만으로 커버리지 +14.3%, 환각 -13.3%.
같은 Instructions를 주어도 mini는 환각 0%인 반면 nano는 13.3%.
**모델의 지시사항 준수 능력이 TC 품질에 결정적.**

#### B. URL 파싱이 필터 문제의 근본 원인
6개 실험 모두에서 필터 TC가 일관되게 누락되었는데, 이는 **필터 버튼이 `<form>` 외부에 있어서 파서가 감지하지 못했기 때문**.
파싱 개선 후 필터 3종이 즉시 완전 커버됨 (0/3 → 3/3).

#### C. Attention Budget 현상
nano 모델에서 cnt를 늘리면 검색↔필터가 교환되는 현상 발견.
AI가 제한된 "주의력 예산" 내에서 기능을 커버하므로, 한 영역을 추가하면 다른 영역이 빠지는 trade-off.
mini 모델에서는 이 현상이 크게 완화됨.

#### D. TC_JUDGE는 신뢰도 낮음
qltyIndex가 24% 커버리지(4.20)와 81% 커버리지(4.20)에서 **동일한 점수**.
TC_JUDGE는 TC의 "형식적 완성도"만 평가하고, 실제 커버리지나 정확도를 반영하지 못함.

---

## 5. 코드 변경 상세

### 5.1 ResponsesPayloadBuilder.java - buildUiSpecJson() 개선

**변경 전**: `<form>` 내부 요소만 추출 (fields + buttons + links)
**변경 후**: 3가지 추가

| 추가 항목 | 설명 | 영향 |
|----------|------|------|
| `standalone_inputs` | form 외부 input/select/textarea | 검색 input, 체크박스 감지 |
| `standalone_buttons` | form 외부 button/[role=button] | 필터 버튼, 수정/삭제 버튼 감지 |
| `data_testid` | 모든 요소의 data-testid 속성 | TC에서 정확한 셀렉터 참조 |
| validation attrs | maxlength, minlength, min, max, pattern | 경계값 TC 정확도 향상 |
| select options | option value/text 목록 | 우선순위 옵션 인식 |

### 5.2 buildFieldMap() 메서드 추출
form 내부와 standalone 요소 모두에서 동일한 필드 추출 로직을 공유하도록 리팩토링.

### 5.3 DB 변경
| 변경 | 대상 | 값 |
|------|------|---|
| ai_prompt_tb prompt_id=2 | content | Instructions v2 (튜닝) |
| ai_func_config_tb TC_GENERATE | modelId | 1→2 (gpt-5-mini) |
| test_case_tb | testcase_keyword | VARCHAR(500)→VARCHAR(2000) |

---

## 6. 최종 권장 설정

### 6.1 운영 설정 (적용 완료)
| 파라미터 | 값 | 근거 |
|---------|---|------|
| 모델 | **gpt-5-mini** (ID=2) | 커버리지+환각 최고 균형 |
| Instructions | **v2 (튜닝)** | 필수 커버 항목 + 반환각 |
| reasoning_effort | **minimal** | 충분한 품질, 비용 절감 |
| verbosity | **low** | 간결한 출력 |
| cnt | **15~20** | 15: 효율적(62%), 20: 포괄적(81%) |
| URL 파싱 | **개선 버전** | standalone + data-testid + validation |

### 6.2 사용자 프롬프트 가이드
좋은 TC를 얻기 위한 프롬프트 작성 팁:

1. **기능별 상세 나열**: "추가/수정/삭제/필터/검색 기능 있음" 식으로 구체적으로
2. **토스트/에러 메시지 원문 포함**: "추가 시 'Todo가 추가되었습니다' 토스트 표시"
3. **없는 기능 명시**: "서버 API 없음, 페이지네이션 없음" 등
4. **유효성 규칙 명시**: "제목 필수, 최대 50자, 내용 10자 이상" 등
5. **URL 제공**: data-testid가 있는 페이지는 URL 제공 시 data-testid가 TC에 포함됨

---

## 7. 남은 과제

### 7.1 미달 항목 (4/21, 19%)
| TC | 누락 원인 | 해결 가능성 |
|----|----------|-----------|
| TODO-002 제목만 입력 | "최소 입력" 시나리오 | Instructions 강화 |
| TODO-014 검색+필터 조합 | 복합 시나리오 | 프롬프트 직접 명시 |
| TODO-017 에러 클리어 | 미세한 UI 상태 | 프롬프트 직접 명시 |
| TODO-018 우선순위 전수 | options 전수 확인 | Instructions 강화 |

### 7.2 추가 검증 필요
- **게시판 페이지**: Todo 외 다른 페이지에서도 동일 품질인지 (유효성 검사 등)
- **실제 사용자 피드백**: 생성된 TC의 실무 활용성 평가
- **TC_JUDGE 캘리브레이션**: qltyIndex가 실제 품질을 반영하도록 개선

### 7.3 Auto Script 연계
Phase 3-2에서 data-testid가 TC에 포함되므로, Auto Script 생성 시:
- TC의 `(data-testid=xxx)` → Playwright `[data-testid="xxx"]` 셀렉터로 변환 가능
- TC → Auto Script 변환 정확도 대폭 향상 예상

---

## 8. 실험 아티팩트 목록

| 파일 | 내용 |
|------|------|
| `gold-standard-tc.md` | Gold Standard TC 문서 (68개, Todo 21개) |
| `experiments/tuned_instructions.txt` | Instructions v2 (최종 버전) |
| `experiments/analysis_round1.md` | Round 1 분석 (기본/URL/상세 프롬프트) |
| `experiments/analysis_round2.md` | Round 2 분석 (Instructions 튜닝) |
| `experiments/analysis_round3.md` | Round 3 분석 (모델 변경) |
| `experiments/analysis_final.md` | FINAL 분석 (최적 구성) |
| `experiments/analysis_phase3-2.md` | Phase 3-2 분석 (URL 파싱 개선) |
| `experiments/exp*.ps1` | 실험 스크립트 (8개) |
| `experiments/exp*_result.json` | 실험 결과 JSON (8개) |

---

## 9. 결론

GENQ의 TC 생성 품질은 **체계적 튜닝으로 실무 수준에 근접**할 수 있음을 입증했다.

- **24% → 81%** 커버리지 달성 (3.4배 향상)
- **30% → 5%** 환각 감소 (6배 감소)
- 5개 튜닝 레버 중 **모델 업그레이드 + URL 파싱 개선**이 가장 효과적
- **form 외부 요소 미추출**이 필터 TC 누락의 근본 원인이었으며, 코드 수정으로 완전 해결
- data-testid 추출로 **Auto Script와의 연계 기반 마련**

이 검증 프레임워크(Gold Standard + PDCA 사이클)는 향후 TC 생성 모델/프롬프트 변경 시에도 재사용 가능하다.
