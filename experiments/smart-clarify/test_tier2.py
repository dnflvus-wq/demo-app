#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Smart Clarify Tier 2 Tests - URL-based (Playwright HTML parsing)"""
import urllib.request
import urllib.parse
import json
import os

URI = "http://localhost:8088/api/v1/testcases/clarify"
OUT_DIR = r"c:\Project\demo-app\experiments\smart-clarify"

tests = [
    ("S-6", "이 페이지 TC 생성해줘", ["http://localhost:5174/todo"]),
    ("S-7", "이 페이지 TC 생성해줘", ["http://localhost:5174/board/write"]),
]

for name, prompt, urls in tests:
    print(f"\n========== {name}: prompt={prompt}, urls={urls} ==========")
    try:
        params = [("prompt", prompt)]
        for u in urls:
            params.append(("urls", u))
        data = urllib.parse.urlencode(params).encode("utf-8")
        req = urllib.request.Request(URI, data=data, method="POST")
        req.add_header("Content-Type", "application/x-www-form-urlencoded; charset=utf-8")
        with urllib.request.urlopen(req, timeout=120) as resp:
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

print("\n========== All Tier 2 tests complete ==========")
