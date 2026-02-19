# Collect Judge scores from all experiments
$base = "c:\Project\demo-app\experiments"
$files = @(
    @{Name="R1-1 (24%)"; Path="$base\exp1_result.json"},
    @{Name="R2 tuned (47.6%)"; Path="$base\exp3_tuned_result.json"},
    @{Name="R3 model5mini (61.9%)"; Path="$base\exp3_model5mini_result.json"},
    @{Name="FINAL (71.4%)"; Path="$base\exp3_final_result.json"},
    @{Name="Phase3-2 (81%)"; Path="$base\exp4_parsing_result.json"},
    @{Name="B-1 Board Write detail"; Path="$base\board\exp_b1_result.json"},
    @{Name="B-2 Board List+Detail"; Path="$base\board\exp_b2_result.json"},
    @{Name="B-4 Board Write simple (62.5%)"; Path="$base\board\exp_b4_result.json"},
    @{Name="H-1 Home+Nav (42.9%)"; Path="$base\home\exp_h1_result.json"},
    @{Name="C-1 Board+Clarify (87.5%)"; Path="$base\clarify\exp_c1_result.json"},
    @{Name="C-2 Todo+Clarify (90.5%)"; Path="$base\clarify\exp_c2_result.json"},
    @{Name="J-1 Judge v2 Board (62.5%)"; Path="$base\judge\exp_j1_result.json"},
    @{Name="J-3 Judge v2 Todo simple"; Path="$base\judge\exp_j3_result.json"}
)

Write-Host ("{0,-35} {1,6} {2,6} {3,6} {4,6} {5,6} {6,6} {7,6}" -f "Experiment","qlty","trust","clar","feas","comp","effi","trace")
Write-Host ("-" * 90)

foreach ($item in $files) {
    if (Test-Path $item.Path) {
        $data = Get-Content $item.Path | ConvertFrom-Json
        $tc = $data.testCases
        Write-Host ("{0,-35} {1,6} {2,6} {3,6} {4,6} {5,6} {6,6} {7,6}" -f $item.Name, $tc.qltyIndex, $tc.trust, $tc.clarity, $tc.feasibility, $tc.completeness, $tc.efficiency, $tc.traceability)
    } else {
        Write-Host ("{0,-35} FILE NOT FOUND" -f $item.Name)
    }
}
