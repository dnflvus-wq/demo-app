#!/usr/bin/env python3
"""Smart Clarify v2 Final API Test - v1 schema with FE enhancements"""
import requests, json

BASE = "http://localhost:8088/api/v1/testcases/clarify"

def test_clarify(name, prompt, urls=None):
    print(f"\n{'='*60}")
    print(f"TEST: {name}")
    print(f"{'='*60}")

    params = {"prompt": prompt}
    if urls:
        params["urls"] = urls

    try:
        resp = requests.post(BASE, params=params, timeout=60)
        resp.raise_for_status()
        data = resp.json()
    except Exception as e:
        print(f"FAIL: {e}")
        return None

    with open(f"{name}_result.json", "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    questions = data.get("questions", [])
    counts = data.get("recommendedCounts", [])

    print(f"Summary: {data.get('summary', 'N/A')}")
    print(f"Questions: {len(questions)}")
    for q in questions:
        qtype = q.get("questionType", "?")
        opts = len(q.get("options", []))
        print(f"  [{qtype}] {q.get('question', '?')} ({opts} options)")

    print(f"RecommendedCounts: {counts}")

    # Checks
    checks = {
        "question_count_ok": 2 <= len(questions) <= 6,
        "has_counts": len(counts) >= 2,
        "counts_reasonable": all(c >= 10 for c in counts) if counts else False,
        "no_abstract": not any(
            t in json.dumps(data, ensure_ascii=False)
            for t in ["비정상 시나리오", "경계값 조건", "보안 관련"]
        ),
        "options_min_3": all(len(q.get("options", [])) >= 3 for q in questions),
    }

    all_pass = all(checks.values())
    for k, v in checks.items():
        print(f"  {'PASS' if v else 'FAIL'}: {k}")
    print(f"\n{'PASS' if all_pass else 'PARTIAL'}: {name}")
    return data

if __name__ == "__main__":
    test_clarify("V2F-1", "로그인 TC 생성해줘")
    test_clarify("V2F-2", "게시판 글쓰기 TC")
    test_clarify("V2F-3", "할일 관리 TC")
    print("\n" + "="*60)
    print("ALL TESTS COMPLETE")
