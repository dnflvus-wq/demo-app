"""
Smart Clarify v2 - Gold Standard A/B Comparison Test
Target: demo-app /board/write (WRITE-001~016, 16 gold-standard TCs)

Condition A: No clarifyContext (prompt only)
Condition B: With clarifyContext (simulated Clarify answers)
"""
import requests
import json
import time
import os

BASE_URL = "http://localhost:8088"

# Gold Standard TCs for /board/write
GOLD_STANDARD = [
    "WRITE-001: 정상 글 등록 (자유) - 제목/작성자/카테고리/내용 입력 후 등록",
    "WRITE-002: 공지 카테고리 등록 - 공지 뱃지 표시",
    "WRITE-003: 질문 카테고리 등록 - 질문 뱃지 표시",
    "WRITE-004: 비밀글 등록 - 비밀글 체크박스, 자물쇠 아이콘",
    "WRITE-005: 글 수정 - 기존값 로드, 수정 후 상세 이동",
    "WRITE-006: 취소 버튼 - 이전 페이지 이동",
    "WRITE-007: 제목 빈값 유효성 검사 - 에러 메시지",
    "WRITE-008: 작성자 빈값 유효성 검사 - 에러 메시지",
    "WRITE-009: 내용 빈값 유효성 검사 - 에러 메시지",
    "WRITE-010: 내용 9자 경계값 미만 - 10자 미만 에러",
    "WRITE-011: 내용 10자 경계값 통과 - 정상 등록",
    "WRITE-012: 에러 클리어 - 입력 시 에러 메시지 사라짐",
    "WRITE-013: 다중 에러 동시 표시 - 모든 필드 빈값",
    "WRITE-014: 글자수 카운터 - 실시간 글자수 표시",
    "WRITE-015: 제목 maxLength 100 - 100자 제한",
    "WRITE-016: 페이지 제목 구분 - 신규=글작성, 수정=글수정",
]

# Simulated clarifyContext (what a user would answer in ClarifyModal for board/write)
CLARIFY_CONTEXT = """이 페이지에 어떤 입력 요소가 있나요?: 제목 입력란, 작성자 입력란, 카테고리 선택, 내용 텍스트영역, 비밀글 체크박스
등록 버튼 클릭 후 성공/실패 시 피드백은?: 성공 시 목록으로 이동 + 토스트 메시지, 실패 시 각 필드별 에러 메시지 표시
입력 필드의 유효성 규칙은?: 제목 필수(maxLength 100), 작성자 필수, 내용 필수(최소 10자), 카테고리 선택(자유/공지/질문)
[추가 설명] 글 수정 모드에서는 기존 값이 폼에 로드되며, 페이지 제목이 '글 수정'으로 바뀜. 내용 입력 시 글자수 카운터 실시간 표시."""


def generate_tc(prompt, clarify_context=None, tc_count=30):
    """Generate TCs via GENQ API"""
    url = f"{BASE_URL}/api/v1/testcases/generate/file"

    # Query params (same as FE)
    params = {
        "prompt": prompt,
        "cnt": str(tc_count),
    }
    if clarify_context:
        params["clarifyContext"] = clarify_context

    # Must send as multipart/form-data
    # Use a dummy multipart field to force Content-Type: multipart/form-data
    try:
        # All params as multipart form fields (not query params)
        multipart_data = {k: (None, v) for k, v in params.items()}
        resp = requests.post(url, files=multipart_data, timeout=120)
        if resp.status_code == 200:
            return resp.json()
        else:
            print(f"  ERROR: HTTP {resp.status_code}")
            print(f"  Body: {resp.text[:300]}")
            return None
    except Exception as e:
        print(f"  EXCEPTION: {e}")
        return None


def count_coverage(tcs, gold_standard):
    """
    Simple keyword-based coverage scoring.
    For each gold TC, check if any generated TC covers it.
    """
    coverage = {}
    keywords_map = {
        "WRITE-001": ["정상", "등록", "제목", "작성자", "카테고리", "내용"],
        "WRITE-002": ["공지", "카테고리"],
        "WRITE-003": ["질문", "카테고리"],
        "WRITE-004": ["비밀글", "체크", "자물쇠"],
        "WRITE-005": ["수정", "기존", "로드"],
        "WRITE-006": ["취소", "이전", "이동"],
        "WRITE-007": ["제목", "빈", "에러", "유효"],
        "WRITE-008": ["작성자", "빈", "에러", "유효"],
        "WRITE-009": ["내용", "빈", "에러", "유효"],
        "WRITE-010": ["9자", "경계", "미만", "10자 미만", "최소"],
        "WRITE-011": ["10자", "경계", "통과", "정상"],
        "WRITE-012": ["클리어", "사라짐", "입력 시", "에러 제거"],
        "WRITE-013": ["다중", "동시", "모든 필드"],
        "WRITE-014": ["글자수", "카운터", "실시간"],
        "WRITE-015": ["maxLength", "100자", "제한", "최대"],
        "WRITE-016": ["페이지 제목", "글 작성", "글 수정", "신규", "수정 모드"],
    }

    tc_texts = []
    if isinstance(tcs, list):
        for tc in tcs:
            if isinstance(tc, dict):
                parts = []
                for key in ["testcaseName", "testStep", "expectedResult", "precondition",
                             "functionCategory1", "functionCategory2", "serviceName"]:
                    if key in tc and tc[key]:
                        parts.append(str(tc[key]))
                tc_texts.append(" ".join(parts))

    for gold_id, keywords in keywords_map.items():
        matched = False
        for tc_text in tc_texts:
            # Check if at least 2 keywords match
            keyword_hits = sum(1 for kw in keywords if kw in tc_text)
            if keyword_hits >= 2:
                matched = True
                break
        coverage[gold_id] = matched

    return coverage


def run_test(condition_name, prompt, clarify_context=None, tc_count=30, runs=2):
    """Run test multiple times and aggregate results"""
    print(f"\n{'='*60}")
    print(f"Condition {condition_name}")
    print(f"  prompt: {prompt[:50]}...")
    print(f"  clarifyContext: {'YES' if clarify_context else 'NO'}")
    print(f"  tcCount: {tc_count}")
    print(f"  runs: {runs}")
    print(f"{'='*60}")

    all_coverages = []
    all_tc_counts = []

    for run in range(runs):
        print(f"\n  --- Run {run+1}/{runs} ---")
        result = generate_tc(prompt, clarify_context, tc_count)

        if result is None:
            print("  FAILED - skipping")
            continue

        # Parse TC list from result
        tcs = []
        if isinstance(result, dict):
            tcs = result.get("tcDetailList", [])
            if not tcs:
                tcs = result.get("testCases", result.get("tcList", []))
                if isinstance(tcs, dict):
                    tcs = []  # testCases is the parent TC object, not the list
        elif isinstance(result, list):
            tcs = result

        tc_count_actual = len(tcs) if isinstance(tcs, list) else 0
        all_tc_counts.append(tc_count_actual)
        print(f"  Generated {tc_count_actual} TCs")

        if tc_count_actual > 0:
            coverage = count_coverage(tcs, GOLD_STANDARD)
            matched = sum(1 for v in coverage.values() if v)
            total = len(coverage)
            pct = matched / total * 100
            all_coverages.append(pct)
            print(f"  Coverage: {matched}/{total} = {pct:.1f}%")

            # Show which gold TCs were missed
            missed = [k for k, v in coverage.items() if not v]
            if missed:
                print(f"  Missed: {', '.join(missed)}")
        else:
            all_coverages.append(0)
            print("  No TCs to evaluate")

        # Wait between runs to avoid rate limiting
        if run < runs - 1:
            print("  Waiting 5s...")
            time.sleep(5)

    # Aggregate
    avg_coverage = sum(all_coverages) / len(all_coverages) if all_coverages else 0
    avg_tc_count = sum(all_tc_counts) / len(all_tc_counts) if all_tc_counts else 0

    return {
        "condition": condition_name,
        "avg_coverage": avg_coverage,
        "coverages": all_coverages,
        "avg_tc_count": avg_tc_count,
        "tc_counts": all_tc_counts,
        "runs": len(all_coverages),
    }


def main():
    prompt = "게시판 글 작성 페이지 테스트케이스를 생성해주세요. URL: http://localhost:5174/board/write"

    print("Smart Clarify v2 - Gold Standard A/B Test")
    print(f"Target: /board/write (16 gold-standard TCs)")
    print(f"Time: {time.strftime('%Y-%m-%d %H:%M:%S')}")

    # Condition A: No clarifyContext
    result_a = run_test("A (Baseline - no clarify)", prompt, clarify_context=None, tc_count=30, runs=2)

    time.sleep(5)

    # Condition B: With clarifyContext
    result_b = run_test("B (Clarify v2)", prompt, clarify_context=CLARIFY_CONTEXT, tc_count=30, runs=2)

    # Summary
    print("\n" + "="*60)
    print("SUMMARY")
    print("="*60)
    print(f"\nCondition A (Baseline):")
    print(f"  Avg Coverage: {result_a['avg_coverage']:.1f}%")
    print(f"  Coverages: {result_a['coverages']}")
    print(f"  Avg TC Count: {result_a['avg_tc_count']:.0f}")

    print(f"\nCondition B (Clarify v2):")
    print(f"  Avg Coverage: {result_b['avg_coverage']:.1f}%")
    print(f"  Coverages: {result_b['coverages']}")
    print(f"  Avg TC Count: {result_b['avg_tc_count']:.0f}")

    delta = result_b['avg_coverage'] - result_a['avg_coverage']
    print(f"\nDelta (B - A): {delta:+.1f}%p")
    print(f"Pass criteria: B >= 60% AND B > A")

    b_pass = result_b['avg_coverage'] >= 60
    delta_pass = delta > 0
    overall = "PASS" if (b_pass and delta_pass) else "FAIL"
    print(f"Result: {overall} (B>=60%: {'Y' if b_pass else 'N'}, B>A: {'Y' if delta_pass else 'N'})")

    # Save results
    results = {
        "timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
        "target": "/board/write",
        "gold_standard_count": 16,
        "condition_a": result_a,
        "condition_b": result_b,
        "delta": delta,
        "result": overall,
    }

    output_path = os.path.join(os.path.dirname(__file__), "ab_test_result.json")
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(results, f, ensure_ascii=False, indent=2)
    print(f"\nResults saved to: {output_path}")


if __name__ == "__main__":
    main()
