#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Smart Clarify Tier 1 Tests - Python (UTF-8 native)"""
import urllib.request
import urllib.parse
import json
import os

URI = "http://localhost:8088/api/v1/testcases/clarify"
OUT_DIR = r"c:\Project\demo-app\experiments\smart-clarify"

tests = [
    ("S-1", "로그인 TC 생성해줘"),
    ("S-2", "게시판 글쓰기 TC"),
    ("S-3", "할일 관리 TC"),
    ("S-4", "대시보드 TC"),
    ("S-5", "회원가입 TC"),
]

for name, prompt in tests:
    print(f"\n========== {name}: {prompt} ==========")
    try:
        data = urllib.parse.urlencode({"prompt": prompt}).encode("utf-8")
        req = urllib.request.Request(URI, data=data, method="POST")
        req.add_header("Content-Type", "application/x-www-form-urlencoded; charset=utf-8")
        with urllib.request.urlopen(req, timeout=60) as resp:
            body = resp.read().decode("utf-8")

        result = json.loads(body)
        out_file = os.path.join(OUT_DIR, f"{name}_result.json")
        with open(out_file, "w", encoding="utf-8") as f:
            json.dump(result, f, ensure_ascii=False, indent=2)

        print(f"Summary: {result.get('summary', 'N/A')}")
        questions = result.get("questions", [])
        print(f"Questions: {len(questions)}")
        for q in questions:
            qt = q.get("questionType", "?")
            print(f"  Q({qt}): {q.get('question', '')}")
            for opt in q.get("options", []):
                print(f"    - {opt.get('label', '')}")
        rc = result.get("recommendedCounts", [])
        print(f"RecommendedCounts: {', '.join(map(str, rc))}")
    except Exception as e:
        print(f"ERROR: {e}")

print("\n========== All Tier 1 tests complete ==========")
