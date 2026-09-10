<#
  harness.ps1 — Portable Second Brain v2 scaffolder (Windows / PowerShell)
  ========================================================================
  Copy tất định template vào memory hub + tạo/merge CLAUDE.md trong codebase.
  Không cần AI. Không hardcode path — resolve qua $env:SECOND_BRAIN_ROOT.

  USAGE
    harness init                     # L0, tên = tên folder hiện tại
    harness init --level L1
    harness init --name my-app --path D:\code\my-app
    harness help

  Xem README.md + docs/INSTALL.md.
#>

$ErrorActionPreference = "Stop"

# ---- paths của package ----
$PackageRoot   = Split-Path -Parent $PSScriptRoot
$TemplatesRoot = Join-Path $PackageRoot "templates"

function Write-Utf8NoBom([string]$Path, [string]$Content) {
    $enc = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $enc)
}

function Read-Text([string]$Path) {
    return [System.IO.File]::ReadAllText($Path, (New-Object System.Text.UTF8Encoding($false)))
}

function Resolve-Root {
    if ($env:SECOND_BRAIN_ROOT -and $env:SECOND_BRAIN_ROOT.Trim()) {
        return $env:SECOND_BRAIN_ROOT.Trim()
    }
    $rc = Join-Path $HOME ".harnessrc"
    if (Test-Path $rc) {
        $line = (Get-Content $rc | Where-Object { $_.Trim() } | Select-Object -First 1)
        if ($line) { return $line.Trim() }
    }
    Write-Host ""
    Write-Host "❌ SECOND_BRAIN_ROOT chưa được set." -ForegroundColor Red
    Write-Host "   Set 1 lần:  setx SECOND_BRAIN_ROOT `"D:\SecondBrain`"  (mở lại terminal)" -ForegroundColor Yellow
    Write-Host "   Hoặc tạo file ~/.harnessrc với 1 dòng là đường dẫn hub." -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

function Expand-Tokens([string]$Text, [hashtable]$Tok) {
    foreach ($k in $Tok.Keys) { $Text = $Text.Replace("{{$k}}", $Tok[$k]) }
    return $Text
}

# Copy 1 template file → đích, thay token. Không overwrite (chỉ tạo phần thiếu).
function Copy-Tpl([string]$Src, [string]$Dst, [hashtable]$Tok, [System.Collections.ArrayList]$Created, [System.Collections.ArrayList]$Skipped) {
    if (Test-Path $Dst) { [void]$Skipped.Add($Dst); return }
    $content = Expand-Tokens (Read-Text $Src) $Tok
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Dst) | Out-Null
    Write-Utf8NoBom $Dst $content
    [void]$Created.Add($Dst)
}

function Show-Help {
    Write-Host @"
harness — portable Second Brain v2 scaffolder

Lệnh:
  harness init [options]   Khởi tạo harness cho dự án
  harness help             In trợ giúp

Options cho init:
  --name <name>    Tên project (mặc định: tên folder hiện tại)
  --path <path>    Path codebase (mặc định: thư mục hiện tại)
  --level <L0..L4> Cấp trưởng thành (mặc định: L0)

Yêu cầu: env var SECOND_BRAIN_ROOT (hoặc file ~/.harnessrc).
Chi tiết: README.md, docs/INSTALL.md
"@
}

# ---- parse args ----
if ($args.Count -eq 0) { Show-Help; exit 0 }
$cmd = $args[0]
if ($cmd -eq "help" -or $cmd -eq "-h" -or $cmd -eq "--help") { Show-Help; exit 0 }
if ($cmd -ne "init") {
    Write-Host "❌ Lệnh không hợp lệ: $cmd" -ForegroundColor Red
    Show-Help; exit 1
}

$Name = $null; $Path = $null; $Level = "L0"
for ($i = 1; $i -lt $args.Count; $i++) {
    switch ($args[$i]) {
        "--name"  { $i++; $Name  = $args[$i] }
        "--path"  { $i++; $Path  = $args[$i] }
        "--level" { $i++; $Level = $args[$i] }
        default   { Write-Host "⚠ Bỏ qua tham số lạ: $($args[$i])" -ForegroundColor DarkYellow }
    }
}

if (-not $Path) { $Path = (Get-Location).Path }
if (-not $Name) { $Name = Split-Path -Leaf $Path }
if ($Level -notmatch '^L[0-4]$') {
    Write-Host "❌ --level phải là L0..L4 (nhận: $Level)" -ForegroundColor Red; exit 1
}
$LvlNum = [int]$Level.Substring(1)

$Root = Resolve-Root
$Base = Join-Path (Join-Path $Root "_projects") $Name
$Today = Get-Date -Format "yyyy-MM-dd"

$Tok = @{
    "PROJECT_NAME"      = $Name
    "PROJECT_PATH"      = $Path
    "DATE"              = $Today
    "SECOND_BRAIN_ROOT" = $Root
    "STACK"             = "[TBD — điền sau]"
}

$Created = New-Object System.Collections.ArrayList
$Skipped = New-Object System.Collections.ArrayList

# ---- tạo thư mục hub ----
foreach ($d in @(
    $Base,
    (Join-Path $Base "MEMORY"),
    (Join-Path $Base "MEMORY\sessions"),
    (Join-Path $Base "HARNESS"),
    (Join-Path $Base "HARNESS\stories"),
    (Join-Path $Base "HARNESS\decisions"),
    (Join-Path $Base "HARNESS\templates")
)) { New-Item -ItemType Directory -Force -Path $d | Out-Null }

# ---- L0 artifacts ----
Copy-Tpl (Join-Path $TemplatesRoot "AGENTS.md")                     (Join-Path $Base "AGENTS.md")                          $Tok $Created $Skipped
Copy-Tpl (Join-Path $TemplatesRoot "memory\CONTEXT.md")             (Join-Path $Base "MEMORY\CONTEXT.md")                  $Tok $Created $Skipped
Copy-Tpl (Join-Path $TemplatesRoot "memory\DECISIONS.md")           (Join-Path $Base "MEMORY\DECISIONS.md")                $Tok $Created $Skipped
Copy-Tpl (Join-Path $TemplatesRoot "memory\MISTAKES.md")            (Join-Path $Base "MEMORY\MISTAKES.md")                 $Tok $Created $Skipped
Copy-Tpl (Join-Path $TemplatesRoot "harness\FEATURE_INTAKE.md")     (Join-Path $Base "HARNESS\FEATURE_INTAKE.md")          $Tok $Created $Skipped
Copy-Tpl (Join-Path $TemplatesRoot "harness\TEST_MATRIX.md")        (Join-Path $Base "HARNESS\TEST_MATRIX.md")             $Tok $Created $Skipped
Copy-Tpl (Join-Path $TemplatesRoot "harness\templates\story-template.md")         (Join-Path $Base "HARNESS\templates\story-template.md")         $Tok $Created $Skipped
Copy-Tpl (Join-Path $TemplatesRoot "harness\templates\adr-template.md")           (Join-Path $Base "HARNESS\templates\adr-template.md")           $Tok $Created $Skipped
Copy-Tpl (Join-Path $TemplatesRoot "harness\templates\feature-intake-template.md")(Join-Path $Base "HARNESS\templates\feature-intake-template.md")$Tok $Created $Skipped

# ---- L1+ ----
if ($LvlNum -ge 1) {
    Copy-Tpl (Join-Path $TemplatesRoot "harness\TOOL_REGISTRY.md")  (Join-Path $Base "HARNESS\TOOL_REGISTRY.md")           $Tok $Created $Skipped
}
# ---- L2+ ----
if ($LvlNum -ge 2) {
    Copy-Tpl (Join-Path $TemplatesRoot "harness\stories\story.contract.md") (Join-Path $Base "HARNESS\stories\EXAMPLE.contract.md") $Tok $Created $Skipped
}
# ---- L3+ ----
if ($LvlNum -ge 3) {
    Copy-Tpl (Join-Path $TemplatesRoot "harness\BOARD.md")         (Join-Path $Base "HARNESS\BOARD.md")                   $Tok $Created $Skipped
}
# ---- L4 ----
if ($LvlNum -ge 4) {
    Copy-Tpl (Join-Path $TemplatesRoot "harness\MATURITY.md")      (Join-Path $Base "HARNESS\MATURITY.md")                $Tok $Created $Skipped
    Copy-Tpl (Join-Path $TemplatesRoot "harness\AUDIT.md")         (Join-Path $Base "HARNESS\AUDIT.md")                   $Tok $Created $Skipped
    Copy-Tpl (Join-Path $TemplatesRoot "harness\IMPROVEMENT.md")   (Join-Path $Base "HARNESS\IMPROVEMENT.md")             $Tok $Created $Skipped
}

# ---- CLAUDE.md trong codebase (merge-aware, idempotent) ----
$claudeTgt   = Join-Path $Path "CLAUDE.md"
$block       = Expand-Tokens (Read-Text (Join-Path $TemplatesRoot "CLAUDE.md")) $Tok
$pattern     = '(?s)<!-- SECOND-BRAIN-V2:START.*?SECOND-BRAIN-V2:END -->'
$evaluator   = [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $block }
if (-not (Test-Path $claudeTgt)) {
    Write-Utf8NoBom $claudeTgt ("# $Name`r`n`r`n" + $block + "`r`n")
    [void]$Created.Add($claudeTgt)
} else {
    $cur = Read-Text $claudeTgt
    if ([regex]::IsMatch($cur, $pattern)) {
        $new = [regex]::Replace($cur, $pattern, $evaluator)
        Write-Utf8NoBom $claudeTgt $new
        [void]$Skipped.Add("$claudeTgt (block cập nhật)")
    } else {
        Write-Utf8NoBom $claudeTgt ($cur.TrimEnd() + "`r`n`r`n" + $block + "`r`n")
        [void]$Skipped.Add("$claudeTgt (đã chèn block, giữ nội dung cũ)")
    }
}

# ---- báo cáo ----
Write-Host ""
Write-Host "✅ Harness đã init cho [$Name] — cấp $Level" -ForegroundColor Green
Write-Host "   Memory hub: $Base" -ForegroundColor Gray
Write-Host "   Codebase  : $Path" -ForegroundColor Gray
Write-Host ""
if ($Created.Count -gt 0) {
    Write-Host "Đã tạo:" -ForegroundColor Cyan
    $Created | ForEach-Object { Write-Host "  + $_" }
}
if ($Skipped.Count -gt 0) {
    Write-Host "Bỏ qua / cập nhật (đã tồn tại):" -ForegroundColor DarkYellow
    $Skipped | ForEach-Object { Write-Host "  · $_" }
}
Write-Host ""
Write-Host "👉 Bước tiếp (tuỳ chọn): mở AI agent trong dự án, nhờ điền placeholder [...] trong MEMORY\CONTEXT.md từ codebase thực." -ForegroundColor Yellow
Write-Host ""
