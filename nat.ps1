<#
nat.ps1 - Windows wrapper to run nat.bash reliably (handles CRLF/LF).
Requirements: Git Bash (bash in PATH) OR WSL bash.
#>

param(
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]] $Args
)

function Find-Bash {
  $candidates = @(
    "bash.exe",
    "$env:ProgramFiles\Git\bin\bash.exe",
    "$env:ProgramFiles\Git\usr\bin\bash.exe",
    "$env:ProgramFiles(x86)\Git\bin\bash.exe",
    "$env:ProgramFiles(x86)\Git\usr\bin\bash.exe"
  )

  foreach ($c in $candidates) {
    try {
      if (Test-Path $c) { return $c }
      $cmd = Get-Command $c -ErrorAction SilentlyContinue
      if ($cmd) { return $cmd.Source }
    } catch {}
  }
  return $null
}

$bash = Find-Bash
if (-not $bash) {
  Write-Error "bash.exe not found. Install Git for Windows (Git Bash) or use WSL."
  exit 127
}

$scriptPath = Join-Path $PSScriptRoot "nat.bash"
if (-not (Test-Path $scriptPath)) {
  Write-Error "nat.bash not found next to nat.ps1: $scriptPath"
  exit 2
}

# Convert to LF into a temp file (in case the checkout used CRLF)
$tmp = [System.IO.Path]::ChangeExtension([System.IO.Path]::GetTempFileName(), ".bash")
$content = Get-Content -Raw -Encoding UTF8 $scriptPath
$content = $content -replace "`r`n", "`n"
[System.IO.File]::WriteAllText($tmp, $content, [System.Text.UTF8Encoding]::new($false))

try {
  & $bash $tmp @Args
  exit $LASTEXITCODE
} finally {
  Remove-Item -Force -ErrorAction SilentlyContinue $tmp
}
