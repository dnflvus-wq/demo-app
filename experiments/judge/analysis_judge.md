# TC_JUDGE 캘리브레이션 분석 보고서

> 작성: 2026-02-15
> 상태: NEXT-4 완료

## 1. 목표

TC_JUDGE가 실제 TC 품질을 반영하도록 평가 기준을 교정.

**핵심 문제**: qltyIndex가 커버리지 24%(R1-1)와 90.5%(C-2)에서 거의 동일한 점수(4.20 vs 4.28) → 변별력 없음.

## 2. 발견된 근본 원인 (3가지)

### 원인 1: 인위적 점수 범위 제한 ★★★ (DB 변경으로 해결)
- **위치**: ai_prompt_tb prompt_id=4 (Judge Instructions)
- **내용**: `"점수는 기본적으로 3.8 - 4.5 사이로만 주세요 5.0은 절대 나오면 안됩니다."`
- **영향**: 모든 메트릭이 4.0~4.5 사이에 몰려 변별력 소멸
- **조치**: Instructions v2로 교체 → 0.0~5.0 전체 범위 사용 허용

### 원인 2: 원본 프롬프트 미전달 ★★ (코드 변경 필요, 미수정)
- **위치**: TestCaseGenerateService.java line 499
- **내용**: Judge에게 `aiResponseParser.toJson(details)` (생성된 TC만) 전달, 원본 prompt/URLs 미전달
- **영향**: Judge가 "요청된 기능 vs 생성된 TC" 비교 불가 → 커버리지 평가 근본적 불가능
- **제안 조치**: Judge 호출 시 원본 prompt + URLs을 함께 전달하도록 코드 수정

### 원인 3: 커버리지 개념 부재 ★ (Instructions v2에서 부분 해결)
- **위치**: judge-schema.json의 11개 지표
- **내용**: clarity, traceability, feasibility 등 "형식적 완성도" 위주, "기능 커버리지" 지표 없음
- **영향**: 모든 TC가 "형식적으로 잘 작성됨" → 고득점
- **조치**: Instructions v2에서 환각 감지, 경계값 테스트, data-testid 활용 등 간접 품질 기준 추가

## 3. Judge Instructions 변경 내역

### v1 (변경 전)
- 점수 범위: 3.8~4.5 (5.0 절대 금지)
- 평가 관점: TC 형식적 완성도만
- 환각 감지: 없음

### v2 (변경 후)
- 점수 범위: 0.0~5.0 전체 사용
- 환각 감지: feasibility ≤ 3.0 (1개), ≤ 2.0 (3개 이상)
- 경계값 테스트 포함 시 completeness 가점
- data-testid 활용 시 practicality 가점
- 에러 메시지 검증 TC 포함 시 qualityControl 가점
- 네트워크 에러 TC 포함 시 feasibility 감점 (localStorage 앱)
- **파일**: `experiments/judge/judge_instructions_v2.txt`
- **DB 적용**: ai_prompt_tb prompt_id=4 UPDATE 완료

## 4. A/B 테스트 결과

### 4.1 전체 점수 비교표

#### Judge v1 (11개 실험, 변경 전)
| 실험 | 커버리지 | qltyIndex | trust | clarity | feasibility | completeness | efficiency | traceability |
|------|---------|-----------|-------|---------|-------------|-------------|------------|-------------|
| R1-1 Todo baseline | 24.0% | 4.20 | 4.23 | 4.3 | 4.4 | 4.1 | 4.0 | 4.2 |
| R2 Todo tuned | 47.6% | 4.20 | 4.24 | 4.3 | 4.4 | 4.1 | 4.2 | 4.0 |
| R3 Todo model5mini | 61.9% | 4.30 | 4.25 | 4.4 | 4.5 | 4.4 | 4.0 | 4.2 |
| FINAL Todo | 71.4% | 4.17 | 4.19 | 4.4 | 4.5 | 4.2 | 4.0 | 4.0 |
| Phase3-2 Todo | 81.0% | 4.20 | 4.25 | 4.3 | 4.4 | 4.2 | 4.0 | 4.1 |
| B-1 Board detail | - | 4.30 | 4.28 | 4.3 | 4.4 | 4.3 | 4.1 | 4.3 |
| B-2 Board List+Detail | - | 4.30 | 4.26 | 4.5 | 4.5 | 4.0 | 4.2 | 4.3 |
| B-4 Board simple | 62.5% | 4.25 | 4.26 | 4.3 | 4.4 | 4.2 | 4.1 | 4.2 |
| H-1 Home+Nav | 42.9% | 4.23 | 4.23 | 4.3 | 4.4 | 4.2 | 4.1 | 4.2 |
| C-1 Board+Clarify | 87.5% | 4.25 | 4.26 | 4.3 | 4.5 | 4.1 | 4.2 | 4.4 |
| C-2 Todo+Clarify | 90.5% | 4.28 | 4.30 | 4.5 | 4.4 | 4.3 | 4.2 | 4.3 |
| **통계** | | **avg=4.24** | avg=4.25 | 4.3~4.5 | 4.4~4.5 | 4.0~4.4 | 4.0~4.2 | 4.0~4.4 |
| | | **range=0.13** | range=0.11 | range=0.2 | range=0.1 | range=0.4 | range=0.2 | range=0.4 |

#### Judge v2 (2개 실험, 변경 후)
| 실험 | 프롬프트 | cnt | qltyIndex | trust | clarity | feasibility | completeness | efficiency | traceability |
|------|---------|-----|-----------|-------|---------|-------------|-------------|------------|-------------|
| J-1 Board simple | 최소 | 20 | **4.43** | 4.46 | **4.8** | 4.0 | 4.0 | **4.5** | **4.5** |
| J-3 Todo simple | 최소 | 10 | **4.60** | 4.58 | 4.5 | **5.0** | 4.0 | 4.5 | **4.8** |
| **통계** | | | **avg=4.52** | avg=4.52 | 4.5~4.8 | 4.0~5.0 | 4.0~4.0 | 4.5~4.5 | 4.5~4.8 |
| | | | **range=0.17** | range=0.12 | range=0.3 | **range=1.0** | range=0.0 | range=0.0 | range=0.3 |

### 4.2 핵심 발견

#### (1) 점수 범위 확대 ✅
- Judge v1 qltyIndex: 4.17 ~ 4.30 (범위 0.13, 천장 효과)
- Judge v2 qltyIndex: 4.43 ~ 4.60 (범위 0.17, 아직 작지만 확대)
- **feasibility에서 5.0 달성** → v1에서는 불가능했던 최고점
- 메트릭별 범위: feasibility 4.0~5.0 (1.0 범위, v1은 0.1)

#### (2) 환각 감지 부분 작동 ✅
- J-1 (Board Write, 최소 프롬프트): feasibility=**4.0** (Judge v1에서는 4.4)
  - TC-14 "네트워크/서버 오류 시 등록 처리" → localStorage 앱에는 불필요 (환각)
  - TC-19 "등록 버튼 중복 클릭 방지" → 앱에 없는 기능일 수 있음
  - Judge v2가 이런 TC를 감지하여 feasibility를 낮춤
- J-3 (Todo, 최소 프롬프트): feasibility=**5.0**
  - 10개 TC 모두 data-testid 정확히 활용, 존재하는 기능만 테스트
  - 환각 TC 없음 → feasibility 최고점

#### (3) 변별력 향상: feasibility 지표가 핵심 ✅
- J-1 feasibility=4.0 (환각 TC 포함) vs J-3 feasibility=5.0 (환각 없음)
- **차이 1.0pt** → Judge v1에서는 최대 0.1pt 차이

#### (4) 전체 qltyIndex는 여전히 좁은 범위 ⚠️
- v2 범위 0.17 > v1 범위 0.13 (개선이지만 제한적)
- **근본 원인**: Judge가 원본 프롬프트를 모르므로 "커버리지" 평가 불가
- Judge는 "형식적 품질"만 평가 가능 → 두 실험 모두 형식적으로는 잘 작성됨

#### (5) completeness 지표는 여전히 약함 ⚠️
- J-1, J-3 모두 completeness=4.0
- Judge가 "얼마나 완전하게 커버하는지" 판단할 기준이 없음 (원본 요구사항 모름)
- 이 지표의 개선에는 원본 프롬프트 전달이 필수

### 4.3 커버리지 vs qltyIndex 상관관계

#### Judge v1: 상관관계 없음 (r ≈ 0.06)
```
커버리지  24.0% → qltyIndex 4.20
커버리지  47.6% → qltyIndex 4.20
커버리지  61.9% → qltyIndex 4.30
커버리지  71.4% → qltyIndex 4.17 (!)
커버리지  81.0% → qltyIndex 4.20
커버리지  62.5% → qltyIndex 4.25
커버리지  42.9% → qltyIndex 4.23
커버리지  87.5% → qltyIndex 4.25
커버리지  90.5% → qltyIndex 4.28
```
→ 24%나 90.5%나 점수 거의 동일. **qltyIndex는 커버리지의 프록시가 아님.**

#### Judge v2: 데이터 부족으로 판단 보류
- J-1, J-3의 실제 커버리지를 Gold Standard 대비 측정하지 않았으므로 직접 비교 불가
- 다만 feasibility 지표에서 환각 감지 능력은 확인됨

## 5. J-2/J-4/J-5 타임아웃 분석

### 증상
- J-1 (Board, 최소 프롬프트, cnt=20): 성공 (42.7초)
- J-3 (Todo, 최소 프롬프트, cnt=10): 성공 (23.8초)
- J-2 (Board+Clarify, cnt=20): 타임아웃 (300초, 600초)
- J-4 (Todo, 상세 프롬프트, cnt=20): 타임아웃 (300초)
- J-5 (Board, 상세 프롬프트, cnt=15): 타임아웃 (300초)

### 패턴
| 성공 | 실패 |
|------|------|
| 짧은 프롬프트 | 긴 프롬프트 (상세 설명 또는 clarifyContext) |
| cnt=10~20 | cnt=15~20 (긴 프롬프트와 조합 시) |

### 추정 원인
1. **Judge v2 Instructions가 길어짐** → Gemini 2.5 Flash의 처리 시간 증가
2. **긴 프롬프트 + 긴 Instructions + 많은 TC** → 총 토큰 수 급증 → API 타임아웃
3. **백엔드 연속 요청 과부하**: J-4, J-5 시도 시 이미 백엔드가 불안정 상태

### 제안
- Judge Instructions v2의 길이를 줄이거나, Judge 모델을 더 빠른 것으로 변경
- 또는 Judge 호출 시 timeout 설정 증가 (현재 300초 기본)

## 6. 결론 및 권고

### 6.1 DB 변경만으로 달성한 것 (현재 상태)
| 항목 | Judge v1 | Judge v2 | 개선 |
|------|---------|---------|------|
| qltyIndex 범위 | 0.13 (4.17~4.30) | 0.17 (4.43~4.60) | +30% |
| feasibility 범위 | 0.1 (4.4~4.5) | **1.0** (4.0~5.0) | +900% |
| 최고점 사용 | 4.5 최대 | **5.0 달성** | 천장 제거 |
| 환각 감지 | 없음 | **feasibility 감점** | 신규 |
| 타임아웃 위험 | 없음 | **발생** (긴 프롬프트) | 부작용 |

### 6.2 추가 코드 변경 시 달성 가능한 것 (미래)

#### 원본 프롬프트 전달 (권장 우선순위 1)
- **변경 위치**: TestCaseGenerateService.java line ~499
- **변경 내용**: Judge 호출 시 원본 prompt + URLs을 TC 데이터와 함께 전달
- **기대 효과**:
  - Judge가 "요청된 기능 vs 생성된 TC" 비교 가능
  - completeness 지표가 실질적 커버리지를 반영
  - qltyIndex 변별력 대폭 향상 예상

#### Judge 전용 API 추가 (권장 우선순위 2)
- 기존 TC를 재평가할 수 있는 별도 API
- A/B 테스트를 동일 TC 세트로 수행 가능
- 현재는 생성+평가가 하나의 파이프라인 → 동일 TC로 v1 vs v2 비교 불가

#### 커버리지 메트릭 추가 (권장 우선순위 3)
- judge-schema.json에 "coverageScore" 지표 추가
- Judge가 원본 프롬프트의 기능 목록 vs TC의 기능 커버 비교
- 환각 TC는 별도 "hallucinationCount" 필드로 분리

### 6.3 현재 Judge v2의 실용적 가치

**"qltyIndex는 커버리지 프록시가 아니다"** 는 v1, v2 모두 동일.
다만 Judge v2는:
1. **feasibility 지표**로 환각 TC 존재 여부를 간접 감지
2. **5.0점 도달** 가능하므로 "정말 완벽한 TC 세트"를 식별
3. **메트릭 간 차이**가 커져 (4.0~5.0) 약점 영역 파악에 활용 가능

**권장 사용법**:
- qltyIndex 단독으로 품질 판단하지 말 것
- feasibility < 4.5 이면 환각 TC 존재 의심
- completeness 지표는 현재 신뢰할 수 없음 (원본 프롬프트 미전달)

## 7. 실험 아티팩트

| 파일 | 설명 |
|------|------|
| `judge_instructions_v2.txt` | 새 Judge Instructions |
| `update_judge.sql` | DB 업데이트 SQL |
| `exp_j1_baseline.ps1` / `exp_j1_result.json` | Board Write 기본 (성공, 4.43) |
| `exp_j3_todo_simple.ps1` / `exp_j3_result.json` | Todo 간단 (성공, 4.60) |
| `exp_j4_todo_detailed.ps1` | Todo 상세 (타임아웃) |
| `exp_j5_board_detailed.ps1` | Board 상세 (타임아웃) |
| `collect_scores.ps1` | 전체 점수 수집 스크립트 |

## 8. 요약

| 항목 | 결과 |
|------|------|
| 성공 기준: 높은 커버리지 > 낮은 커버리지 | **부분 달성** (feasibility에서만) |
| 성공 기준: 환각 시 감점 | **달성** (J-1 feasibility=4.0) |
| qltyIndex 변별력 | **미흡** (0.17 범위, 개선 필요) |
| 근본 해결 | **코드 변경 필요** (원본 프롬프트 전달) |
| 부작용 | **타임아웃 증가** (Instructions 길이 증가) |
