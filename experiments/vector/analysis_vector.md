# Vector 검색 튜닝 분석 보고서

> 작성: 2026-02-15
> 상태: NEXT-5 완료 (코드 분석 + Qdrant 데이터 분석, 라이브 실험 미실시)

## 1. 목표

현재 DISABLED된 Vector 검색을 분석하고, TC 생성 품질에 미치는 잠재적 효과를 평가.

## 2. 현재 상태

### 2.1 코드 흐름

```
TestCaseGenerateService.java (line 446-450):
  1. prompt를 OpenAI text-embedding-3-small로 임베딩
  2. Qdrant에서 MMR 검색 (diversity=0.5, limit=15)
  3. 유사 TC 텍스트 목록 반환

ResponsesPayloadBuilder.java (line 99-102):
  // Vector 유사 TC: AI 생성 방향을 왜곡시킬 수 있어 비활성화 (2026-02-15)
  // if (similarTestcases != null && !similarTestcases.isEmpty()) {
  //     inputMessages.add(buildUserMessage("[참고용 유사 테스트케이스]\n" + ...));
  // }
```

**핵심**: 임베딩 + Qdrant 검색은 **매번 실행됨** (API 비용 발생), 결과만 **주입 안 됨**.

### 2.2 Qdrant 컬렉션 상태

| 항목 | 값 |
|------|---|
| 서버 | 61.75.21.224:6333 (알파서버) |
| 컬렉션 | text-embedding-3-small_collection |
| 포인트 수 | 13,501 |
| 벡터 차원 | 1,536 (text-embedding-3-small) |
| 거리 함수 | Cosine |
| 인덱스 상태 | green (12,200/13,501 인덱싱) |

### 2.3 데이터 분석

**샘플링 결과** (id 0, 1000, 5000, 10000):

| offset | PLATFORM | SERVICE_NAME | 내용 |
|--------|----------|-------------|------|
| 0 | **모바일 앱** | 마이페이지 | 리뷰 작성 |
| 1000 | **모바일 앱** | 메인 | 수강현황 Q&A |
| 5000 | **모바일 앱** | 메인 | 비밀번호 재설정 |
| 10000 | **모바일 앱** | 메인 | 수강현황 Q&A (1000과 동일!) |

**결론: 13,501개 전부 "모바일 앱" TC. 웹 앱 TC는 0건.**

### 2.4 데이터 품질 이슈
1. **중복**: id 1000~1004와 id 10000~10004가 완전 동일 → 데이터 정리 필요
2. **플랫폼 편향**: 100% 모바일 앱 → 웹 앱 TC 생성에 부적합
3. **형식 차이**: 모바일 TC는 "화면 진입", "탭 선택" 패턴 vs 웹 TC는 "URL 접속", "data-testid" 패턴

## 3. 분석 결론

### 3.1 현재 Vector 검색이 비활성화된 것은 올바른 판단 ✅

**이유**:
1. 모바일 앱 TC를 웹 앱 TC 생성 시 참고로 제공하면 AI가 혼동
2. "1. 로그인 상태 2. 수강중인강좌 페이지 진입" 같은 모바일 패턴이 Todo/Board TC에 반영될 위험
3. data-testid 기반 셀렉터 대신 모바일 UI 패턴이 혼입될 가능성

### 3.2 즉시 개선 필요: 불필요한 API 호출 제거 ⚠️

현재 **매 TC 생성마다**:
1. OpenAI Embedding API 호출 (비용: ~$0.0001/요청)
2. Qdrant 검색 실행 (네트워크 비용)
3. 결과를 **사용하지 않고 버림**

**권장 조치**: Vector 검색 호출 자체도 주석 처리

```java
// TestCaseGenerateService.java line 446-450
// 현재: 실행하지만 결과 미사용 (비용 낭비)
// if(effectiveKeyword != null && effectiveKeyword != "") {
//     embeddingVector = embeddingAdapter.embedKeywords(List.of(effectiveKeyword));
//     similarTestcases = vectorDbAdapter.search(embeddingVector);
// }
```

### 3.3 Vector 검색이 가치를 발휘하려면 (미래 개선안)

#### Option A: 프로젝트별 컬렉션 분리 (권장)
- 현재: 모든 프로젝트의 TC가 하나의 컬렉션에 혼재
- 개선: 프로젝트별 컬렉션 (예: `demo-app_collection`, `mobile-app_collection`)
- 검색 시 해당 프로젝트 컬렉션만 조회

#### Option B: Gold Standard TC 시딩 (실험적)
- demo-app Gold Standard 68개 TC를 Qdrant에 임베딩 삽입
- AI가 고품질 TC를 few-shot 예시로 참고
- 기대 효과: TC 형식 일관성 + 커버리지 개선
- 리스크: AI가 Gold Standard를 그대로 복사하여 다양성 감소

#### Option C: 메타데이터 필터링
- 각 TC에 `platform`, `project` 메타데이터 추가
- Qdrant 검색 시 `filter: { must: [{ key: "platform", match: { value: "웹" }}] }` 적용
- 현재 데이터에는 메타데이터 필터링 필드 없음 → 스키마 변경 필요

#### Option D: 하이브리드 검색 (장기)
- Vector 유사도 + 키워드 필터 결합
- 예: "Todo 추가" 검색 시 → Vector로 의미 유사 TC 찾되, platform="웹" 필터 적용
- Qdrant의 payload 필터 기능 활용 가능

## 4. 라이브 실험 미실시 사유

| 실험 | 상태 | 사유 |
|------|------|------|
| V-1: Vector 활성화 + Todo | 미실시 | 백엔드 500 (J-4/J-5 타임아웃 후) |
| V-2: scoreThreshold 튜닝 | 미실시 | 백엔드 불안정 |
| V-3: Gold Standard 시딩 | 미실시 | 백엔드 + Qdrant 데이터 삽입 필요 |

**참고**: 라이브 실험 없이도 결론은 명확함:
- 100% 모바일 앱 데이터 → 웹 앱 TC에 주입하면 왜곡 확실
- 코드 분석으로 충분히 판단 가능

## 5. 즉시 실행 권고 (우선순위순)

### P0: 불필요한 API 호출 중단
- TestCaseGenerateService.java line 446-450 주석 처리
- 예상 절감: 매 TC 생성당 OpenAI Embedding API 1회 + Qdrant 쿼리 1회

### P1: 모바일 앱 중복 데이터 정리
- 13,501개 중 중복 제거 (id 1000~1004 = id 10000~10004 등)
- Qdrant collection 정리 또는 재생성

### P2: 프로젝트별 컬렉션 설계 (중기)
- `{project}_{embedding-model}_collection` 네이밍
- TC 저장 시 프로젝트 식별자 포함

### P3: Gold Standard 시딩 실험 (장기, Optional)
- 소규모 실험: Todo Gold Standard 21개를 별도 컬렉션에 삽입
- Vector 검색으로 유사 TC 참조 후 생성 품질 비교
- 양방향 확인 필수 (도움 vs 왜곡)

## 6. 요약

| 항목 | 결과 |
|------|------|
| 현재 Vector 비활성화 | **올바른 판단** (100% 모바일 데이터) |
| 불필요한 API 호출 | **즉시 제거 필요** (비용 낭비) |
| Vector가 가치 발휘 조건 | 프로젝트별 컬렉션 분리 + 웹 TC 시딩 |
| 라이브 실험 | 미실시 (코드+데이터 분석으로 충분) |
| 최적 구성 | Vector OFF 유지 (API 호출도 제거) |
