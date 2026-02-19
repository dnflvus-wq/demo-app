#!/usr/bin/env python3
"""Smart Clarify v2 API Test"""
import requests, json, sys

BASE = "http://localhost:8088/api/v1/testcases/clarify"

def test_clarify(name, prompt, urls=None):
    print(f"\n{'='*60}")
    print(f"TEST: {name}")
    print(f"Prompt: {prompt}")
    if urls:
        print(f"URLs: {urls}")
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

    # Save result
    fname = f"{name}_result.json"
    with open(fname, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"Saved: {fname}")

    # Check questions
    questions = data.get("questions", [])
    print(f"\nSummary: {data.get('summary', 'N/A')}")
    print(f"Questions: {len(questions)}")

    has_text = False
    for q in questions:
        qtype = q.get("questionType", "?")
        opts = len(q.get("options", []))
        hint = q.get("freeTextHint", "")
        print(f"  [{qtype}] {q.get('question', '?')} (options={opts}, hint={'YES' if hint else 'NO'})")
        if qtype == "text":
            has_text = True
            print(f"    freeTextHint: {hint}")

    # Check recommendedCounts
    counts = data.get("recommendedCounts", [])
    print(f"\nRecommendedCounts: {counts}")

    # Check complexityFactors
    cf = data.get("complexityFactors")
    if cf:
        print(f"ComplexityFactors: formCount={cf.get('formCount')}, fieldCount={cf.get('fieldCount')}, "
              f"actionCount={cf.get('actionCount')}, hasValidation={cf.get('hasValidation')}, "
              f"hasNavigation={cf.get('hasNavigation')}")
    else:
        print("ComplexityFactors: MISSING!")

    # Verdict
    checks = []
    checks.append(("has_text_question", has_text))
    checks.append(("has_complexityFactors", cf is not None))
    checks.append(("has_recommendedCounts", len(counts) >= 2))
    checks.append(("no_abstract_terms", not any(
        term in json.dumps(data, ensure_ascii=False)
        for term in ["비정상 시나리오", "경계값 조건", "보안 관련"]
    )))

    all_pass = all(v for _, v in checks)
    for check_name, check_val in checks:
        print(f"  {'PASS' if check_val else 'FAIL'}: {check_name}")

    print(f"\n{'PASS' if all_pass else 'FAIL'}: {name}")
    return data

if __name__ == "__main__":
    # Test 1: 로그인 (MODE A)
    test_clarify("V2-1", "로그인 TC 생성해줘")

    # Test 2: 게시판 글쓰기 (MODE A)
    test_clarify("V2-2", "게시판 글쓰기 TC")

    # Test 3: 할일 관리 (MODE A)
    test_clarify("V2-3", "할일 관리 TC")

    print("\n" + "="*60)
    print("ALL TESTS COMPLETE")
