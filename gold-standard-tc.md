# DemoApp Gold Standard Test Cases

> GENQ TC 생성 품질 평가를 위한 기준선 문서
> 작성 기준: demo-app 전체 소스코드 분석 결과
> 총 TC 수: **68개**

---

## 메타정보 (GENQ 출력 검증용)

| 항목 | 기대값 |
|------|--------|
| serviceName | DemoApp |
| URL (Todo) | http://localhost:5174/todo |
| URL (Board) | http://localhost:5174/board |
| URL (Board Write) | http://localhost:5174/board/write |
| URL (Home) | http://localhost:5174/ |

---

## A. Todo 페이지 (/todo) - 21개 TC

### A-1. 정상 시나리오 (8개)

| ID | TC명 | 사전조건 | 테스트 스텝 | 기대결과 |
|----|-------|---------|------------|---------|
| TODO-001 | Todo 추가 (전체 필드) | Todo 페이지 접속 | 1. 제목 "회의 준비" 입력 (data-testid=todo-title) 2. 설명 "발표 자료 준비" 입력 (todo-desc) 3. 우선순위 "높음" 선택 (todo-priority) 4. "추가" 버튼 클릭 (todo-add-btn) | 목록에 새 항목 추가됨. 제목="회의 준비", 우선순위="높음" 빨간색 표시. 토스트 "Todo가 추가되었습니다" 표시 |
| TODO-002 | Todo 추가 (제목만) | Todo 페이지 접속 | 1. 제목 "간단한 메모" 입력 2. 설명 비움 3. 우선순위 기본값(보통) 유지 4. 추가 버튼 클릭 | 목록에 항목 추가됨. 설명 없음, 우선순위="보통" 노란색 표시 |
| TODO-003 | Todo 완료 토글 | 미완료 Todo 1개 존재 | 1. 체크박스 클릭 (todo-check-{id}) | 체크박스 체크됨. 제목에 취소선(line-through) + 회색(text-gray-400) 스타일. 배경 bg-gray-50 |
| TODO-004 | Todo 완료 해제 | 완료된 Todo 1개 존재 | 1. 체크된 체크박스 클릭 | 체크 해제됨. 취소선 제거, 원래 스타일(text-gray-800) 복원 |
| TODO-005 | Todo 수정 | Todo 1개 존재 | 1. 수정 버튼 클릭 (todo-edit-{id}) 2. 제목을 "수정된 제목"으로 변경 3. 우선순위 "낮음"으로 변경 4. "수정" 버튼 클릭 | 폼에 기존값 로드됨 → 변경값 반영. 버튼 텍스트 "수정"으로 변경. 토스트 "Todo가 수정되었습니다" 표시 |
| TODO-006 | Todo 수정 취소 | 수정 모드 진입 상태 | 1. "취소" 버튼 클릭 (todo-cancel-btn) | 폼 초기화(제목/설명 비움, 우선순위 '보통'). 수정 모드 해제, 버튼 "추가"로 복원 |
| TODO-007 | Todo 삭제 확인 | Todo 1개 존재 | 1. 삭제 버튼 클릭 (todo-delete-{id}) 2. 확인 다이얼로그에서 "확인" 클릭 (confirm-ok) | 확인 다이얼로그 표시 ("정말 삭제하시겠습니까?"). 확인 후 목록에서 항목 제거. 토스트 "Todo가 삭제되었습니다" |
| TODO-008 | Todo 삭제 취소 | Todo 1개 존재 | 1. 삭제 버튼 클릭 2. 확인 다이얼로그에서 "취소" 클릭 (confirm-cancel) | 다이얼로그 닫힘. 항목 유지 |

### A-2. 필터 & 검색 (6개)

| ID | TC명 | 사전조건 | 테스트 스텝 | 기대결과 |
|----|-------|---------|------------|---------|
| TODO-009 | 필터: 전체 | 완료/미완료 Todo 혼합 존재 | 1. "전체" 필터 클릭 (filter-all) | 모든 Todo 표시. 전체 탭 활성화 스타일 (bg-white text-blue-600 shadow-sm) |
| TODO-010 | 필터: 진행중 | 완료/미완료 Todo 혼합 존재 | 1. "진행중" 필터 클릭 (filter-active) | 미완료(completed=false) 항목만 표시 |
| TODO-011 | 필터: 완료 | 완료/미완료 Todo 혼합 존재 | 1. "완료" 필터 클릭 (filter-completed) | 완료(completed=true) 항목만 표시 |
| TODO-012 | 검색 - 매칭 | Todo "회의 준비", "보고서 작성" 존재 | 1. 검색창에 "회의" 입력 (todo-search) | "회의 준비" 항목만 표시 (제목 기준 대소문자 무시 매칭) |
| TODO-013 | 검색 - 결과 없음 | Todo 존재 | 1. 검색창에 "존재하지않는키워드" 입력 | "검색 결과가 없습니다" 메시지 표시 (todo-empty) |
| TODO-014 | 검색 + 필터 조합 | 완료/미완료 Todo 혼합 + 검색 키워드 매칭 항목 존재 | 1. "진행중" 필터 선택 2. 검색창에 키워드 입력 | 필터 AND 검색 조건 모두 만족하는 항목만 표시 |

### A-3. 유효성 검사 & 경계값 (4개)

| ID | TC명 | 사전조건 | 테스트 스텝 | 기대결과 |
|----|-------|---------|------------|---------|
| TODO-015 | 빈 제목 제출 | Todo 페이지 접속 | 1. 제목 비우고 추가 버튼 클릭 | "제목을 입력해주세요" 에러 메시지 (error-title). 항목 추가 안 됨 |
| TODO-016 | 제목 maxLength 50 | Todo 페이지 접속 | 1. 50자 초과 텍스트 입력 시도 | HTML maxLength=50 속성으로 50자 이상 입력 불가 |
| TODO-017 | 에러 메시지 클리어 | 빈 제목 제출 → 에러 표시 상태 | 1. 제목 필드에 텍스트 입력 | 에러 메시지 즉시 사라짐 (onChange에서 setError('') 호출) |
| TODO-018 | 우선순위 전수 확인 | Todo 페이지 접속 | 1. 우선순위 "높음" 선택 → Todo 추가 2. 우선순위 "보통" 선택 → Todo 추가 3. 우선순위 "낮음" 선택 → Todo 추가 | 각각 "높음"(text-red-500), "보통"(text-yellow-500), "낮음"(text-gray-400) 색상/라벨 표시 |

### A-4. UI 상태 (3개)

| ID | TC명 | 사전조건 | 테스트 스텝 | 기대결과 |
|----|-------|---------|------------|---------|
| TODO-019 | 빈 목록 상태 | Todo 0개 (초기 또는 전부 삭제) | 1. Todo 페이지 접속 | "Todo가 없습니다. 새로운 할 일을 추가해보세요!" 메시지 (todo-empty) |
| TODO-020 | 수정 모드 UI 변경 | Todo 1개 존재 | 1. 수정 버튼 클릭 | 추가 버튼 텍스트 "추가"→"수정" 변경. "취소" 버튼(todo-cancel-btn) 표시됨 |
| TODO-021 | localStorage 영속성 | Todo 추가 완료 상태 | 1. 페이지 새로고침 | 추가한 Todo가 그대로 유지됨 (localStorage 기반) |

---

## B. 게시판 - 글 작성 (/board/write) - 16개 TC

### B-1. 정상 시나리오 (6개)

| ID | TC명 | 사전조건 | 테스트 스텝 | 기대결과 |
|----|-------|---------|------------|---------|
| WRITE-001 | 정상 글 등록 (자유) | 글쓰기 페이지 접속 | 1. 제목 "테스트 글" 입력 (post-title) 2. 작성자 "테스터" 입력 (post-author) 3. 카테고리 "자유" 선택 (post-category) 4. 내용 "이것은 테스트 글입니다 열자이상" 입력 (post-content) 5. 등록 버튼 클릭 (post-save-btn) | 글 등록 후 /board 목록으로 이동. 토스트 "글이 등록되었습니다" |
| WRITE-002 | 공지 카테고리 등록 | 글쓰기 페이지 접속 | 1. 필수 필드 입력 2. 카테고리 "공지" 선택 3. 등록 | 목록에서 공지 뱃지(bg-red-100 text-red-600) 표시 |
| WRITE-003 | 질문 카테고리 등록 | 글쓰기 페이지 접속 | 1. 필수 필드 입력 2. 카테고리 "질문" 선택 3. 등록 | 목록에서 질문 뱃지(bg-green-100 text-green-600) 표시 |
| WRITE-004 | 비밀글 등록 | 글쓰기 페이지 접속 | 1. 필수 필드 입력 2. 비밀글 체크박스 체크 (post-secret) 3. 등록 | 목록에서 자물쇠(Lock) 아이콘 표시. 상세에서 "비밀글" 라벨 표시 |
| WRITE-005 | 글 수정 | /board/write/:id 접속 | 1. 기존 값 로드 확인 2. 제목 "수정된 제목"으로 변경 3. 수정 버튼 클릭 | 폼에 기존 제목/작성자/내용/카테고리/비밀글 로드. 버튼 텍스트 "수정". 수정 후 /board/{id} 상세로 이동. 토스트 "글이 수정되었습니다" |
| WRITE-006 | 취소 버튼 | 글쓰기 페이지에서 입력 중 | 1. 취소 버튼 클릭 (post-cancel-btn) | 이전 페이지로 이동 (navigate(-1)) |

### B-2. 유효성 검사 (7개)

| ID | TC명 | 사전조건 | 테스트 스텝 | 기대결과 |
|----|-------|---------|------------|---------|
| WRITE-007 | 제목 빈값 | 글쓰기 페이지 | 1. 제목 비움 2. 등록 버튼 클릭 | "제목을 입력해주세요" 에러 (error-title). 제목 필드 빨간 테두리(border-red-400) |
| WRITE-008 | 작성자 빈값 | 글쓰기 페이지 | 1. 작성자 비움 2. 등록 버튼 클릭 | "작성자를 입력해주세요" 에러 (error-author) |
| WRITE-009 | 내용 빈값 | 글쓰기 페이지 | 1. 내용 비움 2. 등록 버튼 클릭 | "내용을 입력해주세요" 에러 (error-content) |
| WRITE-010 | 내용 9자 (경계값 미만) | 글쓰기 페이지 | 1. 제목/작성자 입력 2. 내용 "123456789" (9자) 입력 3. 등록 | "내용을 10자 이상 입력해주세요" 에러 |
| WRITE-011 | 내용 10자 (경계값 통과) | 글쓰기 페이지 | 1. 제목/작성자 입력 2. 내용 "1234567890" (10자) 입력 3. 등록 | 정상 등록 성공. 에러 없음 |
| WRITE-012 | 에러 클리어 (입력 시) | 빈 제목 제출 → 에러 표시 | 1. 제목 필드에 텍스트 입력 | 제목 에러 메시지 사라짐. 다른 필드 에러는 유지 (필드별 독립 클리어) |
| WRITE-013 | 다중 에러 동시 표시 | 글쓰기 페이지 | 1. 모든 필드 비움 2. 등록 버튼 클릭 | 제목/작성자/내용 에러 메시지 3개 동시 표시 |

### B-3. UI 상태 (3개)

| ID | TC명 | 사전조건 | 테스트 스텝 | 기대결과 |
|----|-------|---------|------------|---------|
| WRITE-014 | 글자수 카운터 | 글쓰기 페이지 | 1. 내용 "안녕하세요" (5자) 입력 | 내용 아래 "5자" 표시 (실시간 업데이트) |
| WRITE-015 | 제목 maxLength 100 | 글쓰기 페이지 | 1. 100자 초과 텍스트 입력 시도 | HTML maxLength=100으로 100자 이상 입력 불가 |
| WRITE-016 | 페이지 제목 구분 | 신규/수정 모드 | 1. /board/write 접속 → "글 작성" 제목 2. /board/write/:id 접속 → "글 수정" 제목 | 신규: h1="글 작성", 버튼="등록". 수정: h1="글 수정", 버튼="수정" |

---

## C. 게시판 - 목록 (/board) - 10개 TC

| ID | TC명 | 사전조건 | 테스트 스텝 | 기대결과 |
|----|-------|---------|------------|---------|
| LIST-001 | 목록 조회 | 시드 데이터 6건 존재 | 1. /board 접속 | 테이블에 게시글 목록 표시 (board-table). 컬럼: 번호/분류/제목/작성자/작성일/조회 |
| LIST-002 | 최신순 정렬 | 시드 데이터 존재 | 1. /board 접속 | 최신 글이 상단 (reverse sort). 번호는 역순 (6,5,4,3,2 → 1페이지에 5개) |
| LIST-003 | 글쓰기 버튼 | /board 접속 | 1. "글쓰기" 버튼 클릭 (board-write-btn) | /board/write 페이지로 이동 |
| LIST-004 | 제목 클릭 → 상세 | 게시글 존재 | 1. 게시글 제목 클릭 (board-title-{id}) | /board/{id} 상세 페이지로 이동 |
| LIST-005 | 카테고리 뱃지 색상 | 공지/자유/질문 글 존재 | 1. /board 접속 | 공지=bg-red-100+text-red-600, 자유=bg-blue-100+text-blue-600, 질문=bg-green-100+text-green-600 |
| LIST-006 | 비밀글 자물쇠 아이콘 | 비밀글 존재 (id=4) | 1. /board 접속 | 비밀글 제목 앞에 Lock 아이콘 표시 |
| LIST-007 | 페이지네이션 표시 | 6건 존재 (PAGE_SIZE=5) | 1. /board 접속 | 페이지네이션 표시 (pagination). 1페이지=5건, 2페이지=1건 |
| LIST-008 | 페이지 전환 | 6건 이상 존재 | 1. 2페이지 버튼 클릭 (page-2) | 2페이지 게시글 표시. 2페이지 버튼 활성화 (bg-blue-600 text-white) |
| LIST-009 | 이전/다음 버튼 비활성화 | 1페이지 상태 | 1. 이전 버튼(page-prev) 상태 확인 2. 마지막 페이지에서 다음 버튼(page-next) 상태 확인 | 1페이지에서 이전 버튼 disabled (opacity-30). 마지막 페이지에서 다음 버튼 disabled |
| LIST-010 | 빈 목록 | 게시글 0건 | 1. /board 접속 | "게시글이 없습니다." 메시지 (board-empty). 페이지네이션 미표시 |

---

## D. 게시판 - 상세 (/board/:id) - 9개 TC

| ID | TC명 | 사전조건 | 테스트 스텝 | 기대결과 |
|----|-------|---------|------------|---------|
| DETAIL-001 | 상세 조회 | 게시글 존재 | 1. /board/{id} 접속 | 제목(post-detail-title), 작성자(post-detail-author), 작성일(post-detail-date), 조회수(post-detail-views), 내용(post-detail-content) 표시 |
| DETAIL-002 | 조회수 증가 | 게시글 views=5 | 1. /board/{id} 접속 | 조회수 6으로 표시 (+1 증가). localStorage에도 반영 |
| DETAIL-003 | 카테고리 뱃지 | 공지/자유/질문 글 | 1. 상세 페이지 접속 | 카테고리에 맞는 라벨 뱃지 표시 (bg-gray-100 text-gray-600) |
| DETAIL-004 | 비밀글 라벨 | 비밀글 상세 | 1. 비밀글 상세 접속 | "비밀글" 텍스트 + Lock 아이콘 표시 |
| DETAIL-005 | 수정 버튼 | 상세 페이지 | 1. 수정 버튼 클릭 (post-edit-btn) | /board/write/{id} 수정 페이지로 이동 |
| DETAIL-006 | 삭제 확인 | 상세 페이지 | 1. 삭제 버튼 클릭 (post-delete-btn) 2. "확인" 클릭 | 확인 다이얼로그 표시 → 확인 → /board 목록 이동. 토스트 "글이 삭제되었습니다" |
| DETAIL-007 | 삭제 취소 | 상세 페이지 | 1. 삭제 버튼 클릭 2. "취소" 클릭 | 다이얼로그 닫힘. 상세 페이지 유지 |
| DETAIL-008 | 목록으로 버튼 | 상세 페이지 | 1. "목록으로" 버튼 클릭 (post-list-btn) | /board 목록 페이지로 이동 |
| DETAIL-009 | 존재하지 않는 글 | 없는 ID로 접속 | 1. /board/invalid-id 접속 | /board 목록으로 자동 리다이렉트 |

---

## E. 홈/대시보드 (/) - 7개 TC

| ID | TC명 | 사전조건 | 테스트 스텝 | 기대결과 |
|----|-------|---------|------------|---------|
| HOME-001 | Todo 통계 - 전체 | Todo 3개 (완료1, 미완료2) | 1. / 접속 | "전체 Todo"=3 (stat-total), "진행중"=2 (stat-active), "완료"=1 (stat-completed) |
| HOME-002 | Todo 통계 - 초기 | Todo 0개 | 1. / 접속 | 전체=0, 진행중=0, 완료=0 |
| HOME-003 | 최근 게시글 표시 | 게시글 6건 존재 | 1. / 접속 | 최신 3개 표시 (reverse + slice(-3)). 제목과 날짜 표시 |
| HOME-004 | 최근 게시글 클릭 | 게시글 존재 | 1. 게시글 제목 클릭 (recent-post-{id}) | /board/{id} 상세 페이지로 이동 |
| HOME-005 | Todo 시작하기 버튼 | / 접속 | 1. "Todo 시작하기" 클릭 (btn-start) | /todo 페이지로 이동 |
| HOME-006 | 게시판 가기 버튼 | / 접속 | 1. "게시판 가기" 클릭 (btn-board) | /board 페이지로 이동 |
| HOME-007 | 게시글 없을 때 | 게시글 0건 | 1. / 접속 | "아직 게시글이 없습니다." 메시지 표시 |

---

## F. 네비게이션 & 레이아웃 - 5개 TC

| ID | TC명 | 사전조건 | 테스트 스텝 | 기대결과 |
|----|-------|---------|------------|---------|
| NAV-001 | 로고 → Home | 어느 페이지든 | 1. "DemoApp" 로고 클릭 (logo) | / (Home) 페이지로 이동 |
| NAV-002 | Home 탭 활성화 | / 접속 | 1. Home 네비 확인 (nav-home) | Home 탭 활성화 스타일 (bg-blue-50 text-blue-600) |
| NAV-003 | Todo 탭 이동+활성화 | 어느 페이지든 | 1. Todo 탭 클릭 (nav-todo) | /todo 이동. Todo 탭 활성화, 다른 탭 비활성화 |
| NAV-004 | Board 탭 이동+활성화 | 어느 페이지든 | 1. Board 탭 클릭 (nav-board) | /board 이동. Board 탭 활성화 |
| NAV-005 | 푸터 표시 | 어느 페이지든 | 1. 페이지 하단 확인 (footer) | "DemoApp v1.0 - GENQ Test Target" 텍스트 표시 |

---

## 총 집계

| 영역 | TC 수 | 정상 | 경계값/에러 | UI상태 |
|------|-------|------|-----------|--------|
| A. Todo | 21 | 8 | 4 | 3+6(필터) |
| B. Board Write | 16 | 6 | 7 | 3 |
| C. Board List | 10 | 4 | 0 | 6 |
| D. Board Detail | 9 | 5 | 1 | 3 |
| E. Home | 7 | 4 | 0 | 3 |
| F. Nav/Layout | 5 | 5 | 0 | 0 |
| **합계** | **68** | **32** | **12** | **24** |

---

## GENQ TC 비교 기준

### 1. 커버리지 스코어 (Coverage Score)
- Gold Standard 68개 TC 중 GENQ가 생성한 TC가 몇 개에 대응되는지
- 매칭 기준: 테스트 의도가 동일하면 대응으로 간주
- 목표: 60% 이상 (41/68개)

### 2. 정확도 스코어 (Accuracy Score)
- GENQ TC의 testStep이 실제 UI 동작과 일치하는지
- data-testid 또는 정확한 CSS 셀렉터 포함 여부
- 목표: 80% 이상

### 3. 기대결과 스코어 (Expected Result Score)
- expectedResult가 실제 앱 동작과 일치하는지
- 구체적인 메시지 문구, 스타일 변경, 네비게이션 경로 정확성
- 목표: 70% 이상

### 4. 경계값 스코어 (Boundary Score)
- 12개 경계값/에러 TC 중 GENQ가 커버한 비율
- 목표: 50% 이상 (6/12개)

### 5. 중복도 (Duplication Rate)
- 의미적으로 동일한 TC 비율 (낮을수록 좋음)
- 목표: 20% 미만

### 6. 추가 가치 (Bonus)
- Gold Standard에 없지만 GENQ가 유의미하게 추가한 TC
- 예: 브라우저 호환성, 반응형 테스트, 접근성 테스트 등

---

## data-testid 전수 목록 (Auto Script 검증용)

### 공통
- `header`, `logo`, `nav`, `nav-home`, `nav-todo`, `nav-board`, `footer`
- `toast-container`, `toast-message`, `toast-close`
- `confirm-dialog`, `confirm-message`, `confirm-ok`, `confirm-cancel`

### Home (/)
- `home-page`, `page-title`
- `stat-total`, `stat-active`, `stat-completed`
- `btn-start`, `btn-board`
- `recent-posts-title`, `recent-post-{id}`

### Todo (/todo)
- `todo-page`, `todo-form`
- `todo-title`, `todo-desc`, `todo-priority`, `todo-add-btn`, `todo-cancel-btn`
- `error-title`
- `filter-all`, `filter-active`, `filter-completed`
- `todo-search`, `todo-empty`
- `todo-item-{id}`, `todo-check-{id}`, `todo-priority-{id}`, `todo-edit-{id}`, `todo-delete-{id}`

### Board List (/board)
- `board-list-page`, `board-write-btn`, `board-table`, `board-empty`
- `board-row-{id}`, `board-title-{id}`
- `pagination`, `page-prev`, `page-next`, `page-{n}`

### Board Write (/board/write)
- `board-write-page`, `post-form`
- `post-title`, `post-author`, `post-category`, `post-secret`, `post-content`
- `post-cancel-btn`, `post-save-btn`
- `error-title`, `error-author`, `error-content`

### Board Detail (/board/:id)
- `board-detail-page`
- `post-list-btn`, `post-edit-btn`, `post-delete-btn`
- `post-detail-title`, `post-detail-author`, `post-detail-date`, `post-detail-views`, `post-detail-content`
