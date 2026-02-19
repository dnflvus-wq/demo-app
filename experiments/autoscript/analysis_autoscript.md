# Auto Script 검증 분석 보고서

> 작성: 2026-02-16
> 상태: NEXT-6 완료

## 1. 목표

TASK_010에서 구현된 Auto Script 시스템의 실제 동작 품질을 검증.
Element Detection → Selector Building → Code Generation 3단계 각각 검증.

## 2. 시스템 아키텍처 요약

### 2.1 핵심 컴포넌트
| 파일 | 역할 | 줄수 |
|------|------|------|
| PlaywrightElementDetector.java | Headless Chromium으로 요소 감지+실행 | 335줄 |
| AdminAutoScriptService.java | CRUD + 코드 생성 + 실행 관리 | 1,065줄 |
| AdminAutoScriptController.java | 30+ REST API 엔드포인트 | 296줄 |

### 2.2 DB 상태
- auto_script_tb: 1건 (DRAFT, 스텝 0개)
- auto_script_step_tb: 0건
- auto_script_element_tb: 0건

### 2.3 API 엔드포인트 (30+)
| 카테고리 | 엔드포인트 | 수 |
|---------|----------|---|
| Script CRUD | list, create, detail, update, delete, pin, duplicate | 7 |
| Step 관리 | add, update, delete, reorder, duplicate | 5 |
| Element 감지 | detect-elements, re-detect, apply-redetect | 3 |
| 실행 | execute, execute-step, cancel, batch-execute | 4 |
| 코드 생성 | generate-code, download, download-project | 3 |
| 폴더 | list, create, rename, delete, move | 5 |
| 환경변수 | list, create, update, delete, activate | 5 |

## 3. Element Detection 검증

### 3.1 실험 결과

#### Todo 페이지 (`http://localhost:5174/todo`)
- 감지 시간: **0.88초**
- 감지 요소: **12개** (link:4, input:3, select:1, button:4)

| # | Type | Tag | ID | Name/Text | 실제 data-testid | 매칭 |
|---|------|-----|-----|-----------|----------------|------|
| 1 | LINK | a | - | DemoApp | logo | ✅ |
| 2 | LINK | a | - | Home | nav-home | ✅ |
| 3 | LINK | a | - | Todo | nav-todo | ✅ |
| 4 | LINK | a | - | Board | nav-board | ✅ |
| 5 | INPUT | input | todo-title | todo-title | todo-title | ✅ |
| 6 | INPUT | textarea | todo-desc | todo-desc | todo-desc | ✅ |
| 7 | SELECT | select | todo-priority | todo-priority | todo-priority | ✅ |
| 8 | BUTTON | button | **null** | 추가 | todo-add-btn | ⚠️ |
| 9 | BUTTON | button | **null** | 전체 | filter-all | ⚠️ |
| 10 | BUTTON | button | **null** | 진행중 | filter-active | ⚠️ |
| 11 | BUTTON | button | **null** | 완료 | filter-completed | ⚠️ |
| 12 | INPUT | input | **null** | **null** | todo-search | ❌ |

**미감지 요소** (동적 - Todo 아이템이 없어서):
- todo-cancel-btn (수정 모드에서만 표시)
- todo-edit-{id}, todo-delete-{id}, todo-check-{id} (아이템별 버튼)
- error-title (유효성 오류 시에만 표시)
- todo-empty (비대화형 텍스트 → selectors에 미포함)

#### Board Write 페이지 (`http://localhost:5174/board/write`)
- 감지 요소: **11개** (link:4, input:3, select:1, checkbox:1, button:2)

| # | Type | Tag | ID | Name/Text | 실제 data-testid | 매칭 |
|---|------|-----|-----|-----------|----------------|------|
| 5 | INPUT | input | post-title | post-title | post-title | ✅ |
| 6 | INPUT | input | post-author | post-author | post-author | ✅ |
| 7 | SELECT | select | post-category | post-category | post-category | ✅ |
| 8 | CHECKBOX | input | **null** | **null** | post-secret | ❌ |
| 9 | INPUT | textarea | post-content | post-content | post-content | ✅ |
| 10 | BUTTON | button | **null** | 등록 | post-save-btn | ⚠️ |
| 11 | BUTTON | button | **null** | 취소 | post-cancel-btn | ⚠️ |

#### Board List 페이지 (`http://localhost:5174/board`)
- 감지 요소: **14개** (link:4, button:10)
- 게시글 제목 버튼 6개 + 글쓰기 버튼 + 페이지네이션 2개 + 네비 4개

#### Home 페이지 (`http://localhost:5174/`)
- 감지 요소: **9개** (link:4, button:5)
- "Todo 시작하기", "게시판 가기" 버튼 + 최근 게시글 3개

### 3.2 감지 정확도 종합

| 페이지 | 전체 요소 | 감지됨 | 정확 ID | ID 없음 | 완전 미식별 | 정확도 |
|--------|---------|--------|---------|---------|-----------|--------|
| Todo | 12+ | 12 | 3 | 8 | 1 | **25%** (ID 기준) |
| Board Write | 7+ | 7 | 4 | 2 | 1 | **57%** (ID 기준) |
| Board List | 10+ | 10 | 0 | 10 | 0 | **0%** (ID 기준) |
| Home | 5+ | 5 | 0 | 5 | 0 | **0%** (ID 기준) |

**참고**: "정확 ID"는 `elementId`가 제대로 캡처된 경우. Form 입력만 `id` 속성을 가짐.

### 3.3 핵심 문제: data-testid 미지원 ★★★

**현상**: demo-app의 모든 요소에 `data-testid`가 설정되어 있으나, 감지기가 이를 캡처하지 않음.

**코드 위치**: PlaywrightElementDetector.java line 73-136 (JS 코드)

```javascript
// 현재 캡처하는 속성:
results.push({
    elementId: el.id || null,           // HTML id 속성만
    elementName: el.name || el.getAttribute('aria-label') || text,
    attributes: JSON.stringify({
        type, placeholder, class, href, value   // data-testid 없음!
    })
});
```

**영향**:
- Form inputs (`id=todo-title`): `#todo-title` 셀렉터 → 안정적 ✅
- Buttons (id 없음, `data-testid=todo-add-btn`): xpath 폴백 → 깨지기 쉬움 ❌
- Checkboxes (id/name 없음): xpath 폴백 → 매우 불안정 ❌
- Search input (id/name 없음): 완전 미식별 ❌

**수정 제안** (JS 코드 변경):
```javascript
// 추가: data-testid 캡처
const testId = el.getAttribute('data-testid');
results.push({
    elementId: el.id || testId || null,  // data-testid를 id 대안으로
    // attributes에도 추가
    attributes: JSON.stringify({
        type, placeholder, class, href, value,
        'data-testid': testId           // 속성에도 포함
    })
});
```

**셀렉터 빌딩 수정** (AdminAutoScriptService.java):
```java
// 현재: id → name+tag → xpath
// 개선: id → data-testid → name+tag → xpath
private String buildSelector(AutoScriptElementDto el) {
    if (el.getElementId() != null && !el.getElementId().isBlank()) {
        return "#" + el.getElementId();
    }
    // 새로 추가: data-testid 지원
    String testId = extractDataTestId(el.getAttributes());
    if (testId != null && !testId.isBlank()) {
        return "[data-testid=\"" + testId + "\"]";
    }
    // 기존 폴백
    ...
}
```

## 4. Selector Building 분석

### 4.1 현재 셀렉터 우선순위

```
buildSelector() (AdminAutoScriptService.java line 1056-1064):
1. elementId → "#elementId"          (CSS id 셀렉터)
2. elementName + elementTag → "tag[name='name']"  (CSS 속성 셀렉터)
3. elementXpath → "xpath=..."        (XPath)
4. elementTag → "button"             (태그명만, 최후 수단)
```

### 4.2 셀렉터 품질 평가

| 전략 | 안정성 | 고유성 | 적용 범위 | 현재 사용 |
|------|--------|--------|----------|---------|
| `#id` | ★★★★★ | ★★★★★ | Form inputs만 | ✅ |
| `[data-testid="x"]` | ★★★★★ | ★★★★★ | 모든 요소 | ❌ 미지원 |
| `tag[name="x"]` | ★★★☆☆ | ★★★☆☆ | name 있는 요소 | ✅ |
| `text=추가` | ★★★★☆ | ★★☆☆☆ | 텍스트 있는 요소 | ❌ 미지원 |
| `xpath=...` | ★☆☆☆☆ | ★★★★★ | 모든 요소 | ✅ (폴백) |

### 4.3 buildPlaywrightSelector 비교

| 위치 | 용도 | id | data-testid | name | xpath |
|------|------|-----|-------------|------|-------|
| PlaywrightElementDetector.java line 281-289 | 실행 시 | ✅ | ❌ | ✅ | ✅ |
| AdminAutoScriptService.java line 1056-1064 | 코드 생성 시 | ✅ | ❌ | ✅ | ✅ |

두 곳 모두 동일한 문제 (data-testid 미지원).

## 5. Code Generation 분석

### 5.1 생성 방식

```
generateCode(scriptSeq):
1. LLM 생성 시도 (AUTO_SCRIPT_CODE_GEN 함수)
   → ResolvedAiConfig → AI 모델로 코드 생성
2. 실패 시 → 템플릿 폴백 (generateFullTemplateCode)
   → 3개 언어 지원: PLAYWRIGHT_JS, PLAYWRIGHT_PYTHON, SELENIUM_JAVA
```

### 5.2 템플릿 코드 품질

**장점**:
- 3개 언어 모두 올바른 보일러플레이트 생성
- 셀렉터를 상수로 분리 (UPPER_SNAKE_CASE)
- 적절한 waitForLoadState 삽입
- 7개 액션 타입 모두 지원 (CLICK, FILL, CHECK, SELECT, ASSERT_TEXT, ASSERT_VISIBLE, WAIT)

**단점**:
- 에러 핸들링 없음 (try-catch 미생성)
- 재시도 로직 없음
- 스크린샷 캡처 미포함
- 각 스텝 간 wait 없음 (타이밍 이슈 가능)

### 5.3 LLM 코드 생성

- AUTO_SCRIPT_CODE_GEN 함수 설정 여부 미확인 (DB 조회 필요)
- 입력: 스텝별 URL + 요소 액션 목록 (텍스트 형식)
- 출력: 완전한 테스트 스크립트 코드
- 실패 시 템플릿 폴백 (안전장치 있음 ✅)

## 6. TC → Auto Script 연계 가능성

### 6.1 현재 상태
TC 생성 결과에 `data-testid` 정보가 포함됨 (Phase 3-2 URL 파싱 개선 이후):
```
testStep: "1. 입력란(todo-title)에 '쇼핑하기' 입력 (data-testid=todo-title)"
```

### 6.2 변환 가능성
```
TC: "(data-testid=todo-title)" → Auto Script: [data-testid="todo-title"] FILL "쇼핑하기"
TC: "[추가] 버튼 클릭 (data-testid=todo-add-btn)" → Auto Script: [data-testid="todo-add-btn"] CLICK
```

### 6.3 구현 필요사항
1. TC testStep 파싱: `(data-testid=xxx)` 패턴 추출
2. 액션 타입 추론: "입력" → FILL, "클릭" → CLICK, "선택" → SELECT
3. 액션 값 추출: "'쇼핑하기'" → "쇼핑하기"
4. Auto Script 스텝/요소 자동 생성

**우선순위**: 중기 (data-testid 감지 수정 후)

## 7. 권고 사항

### P0: data-testid 캡처 (즉시, 코드 변경)
- **PlaywrightElementDetector.java** line 73-136: JS 코드에 `data-testid` 추가
- **AdminAutoScriptService.java** line 1056-1064: `buildSelector()`에 data-testid 우선순위 추가
- **PlaywrightElementDetector.java** line 281-289: `buildPlaywrightSelector()`도 동일하게 수정
- **기대 효과**: 버튼/체크박스 셀렉터 안정성 대폭 향상

### P1: 동적 요소 감지 (단기)
- Todo 아이템이 없을 때 edit/delete/check 버튼 미감지
- **해결**: 감지 전 테스트 데이터 삽입 또는, 페이지 상호작용 후 재감지
- re-detect API가 이미 구현되어 있음 → 워크플로우에 반영

### P2: 셀렉터 전략 다양화 (중기)
- `text=추가` (Playwright text 셀렉터) 지원 추가
- `role=button` (role 셀렉터) 지원 추가
- `>> nth=0` (Playwright nth 셀렉터) 지원 추가

### P3: TC → Auto Script 자동 변환 (장기)
- TC의 testStep에서 data-testid + 액션 추출
- Auto Script 스텝/요소 자동 생성
- Gold Standard TC → 완전 자동화된 E2E 테스트

## 8. 실험 아티팩트

| 파일 | 설명 |
|------|------|
| detect_todo.ps1 | Todo 페이지 요소 감지 스크립트 |
| detect_all.ps1 | Board/Home 페이지 요소 감지 스크립트 |
| detect_todo_result.json | Todo 감지 결과 (12요소) |
| detect_Board_Write_result.json | Board Write 감지 결과 (11요소) |
| detect_Board_List_result.json | Board List 감지 결과 (14요소) |
| detect_Home_result.json | Home 감지 결과 (9요소) |

## 9. 요약

| 항목 | 결과 |
|------|------|
| Element Detection 속도 | **0.88초** (우수) |
| Form 입력 감지 | **100%** (id 속성 존재) |
| 버튼 감지 | **감지됨** (but ID 없음 → 셀렉터 불안정) |
| data-testid 지원 | **미지원** ★ 핵심 개선 필요 |
| 동적 요소 감지 | **미감지** (데이터 없는 초기 상태) |
| 코드 생성 | **3개 언어 지원** (JS, Python, Java) |
| TC → Auto Script 연계 | **가능** (data-testid 수정 후) |
| 스크립트 실행 | **미검증** (스텝 데이터 없음) |
