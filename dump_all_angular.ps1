# dump_all_files.ps1
param(
  [string]$SrcPath = "./lib",                 # المسار الذي تريد تفريغه (مثلاً "." = كامل المشروع)
  [string]$OutDirName = "DUMPS_PROJECT",
  [string]$OutFileName = "lib.txt",
  [int]$MaxBytesToDump = 2097152,         # 2MB لكل ملف (لتجنب تضخم ملف الدَمب)
  [switch]$IncludeBinary                  # إذا فعّلتها سيضع Base64 للملفات الثنائية
)

$ProjectRoot = (Get-Location).Path

# خلي المسار نسبي دائماً (حل مشكلة / أو \ في البداية)
$SrcPath = $SrcPath.TrimStart('\','/')
$SrcDir  = Join-Path $ProjectRoot $SrcPath

$OutDir  = Join-Path $ProjectRoot $OutDirName
$OutFile = Join-Path $OutDir $OutFileName

if (-not (Test-Path $SrcDir)) {
  Write-Host "ERROR: Path not found: $SrcDir"
  exit 1
}

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
Remove-Item $OutFile -ErrorAction SilentlyContinue

# StreamWriter ثابت وأسرع للملفات الكبيرة
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$sw = New-Object System.IO.StreamWriter($OutFile, $false, $utf8NoBom)

function Test-IsBinary([byte[]]$bytes) {
  if ($bytes.Length -eq 0) { return $false }
  $limit = [Math]::Min($bytes.Length, 8000)
  for ($i=0; $i -lt $limit; $i++) {
    if ($bytes[$i] -eq 0) { return $true }   # وجود NULL غالباً يعني Binary
  }
  return $false
}

try {
  $Files = Get-ChildItem -Path $SrcDir -Recurse -File | Sort-Object FullName

  $sw.WriteLine("DUMP: All files")
  $sw.WriteLine("ROOT: $ProjectRoot")
  $sw.WriteLine("SOURCE: $SrcDir")
  $sw.WriteLine("FILES: $($Files.Count)")
  $sw.WriteLine(("=" * 80))
  $sw.WriteLine()

  foreach ($f in $Files) {
    $rel = $f.FullName.Substring($ProjectRoot.Length).TrimStart('\','/')
    $sw.WriteLine()
    $sw.WriteLine(("=" * 80))
    $sw.WriteLine("FILE: $rel")
    $sw.WriteLine("FULL: $($f.FullName)")
    $sw.WriteLine("SIZE: $($f.Length) bytes")
    $sw.WriteLine("LAST: $($f.LastWriteTime)")
    $sw.WriteLine(("=" * 80))
    $sw.WriteLine()

    # اقرأ bytes (مع قص عند الحاجة)
    $bytes = [System.IO.File]::ReadAllBytes($f.FullName)
    $truncated = $false
    if ($bytes.Length -gt $MaxBytesToDump) {
      $bytes = $bytes[0..($MaxBytesToDump-1)]
      $truncated = $true
    }

    $isBinary = Test-IsBinary $bytes

    if ($isBinary -and -not $IncludeBinary) {
      $sw.WriteLine("[BINARY FILE] Skipped content (use -IncludeBinary to dump as Base64).")
      if ($truncated) { $sw.WriteLine("[NOTE] Content would be truncated at $MaxBytesToDump bytes.") }
      continue
    }

    if ($isBinary -and $IncludeBinary) {
      $sw.WriteLine("[BINARY FILE] Dumped as Base64" + ($(if ($truncated) { " (TRUNCATED)" } else { "" })))
      $sw.WriteLine([Convert]::ToBase64String($bytes))
      continue
    }

    # ملف نصي: حاول UTF-8 أولاً، ولو فشل استخدم StreamReader مع detect BOM
    try {
      $text = [System.Text.Encoding]::UTF8.GetString($bytes)
    } catch {
      $sr = New-Object System.IO.StreamReader($f.FullName, $true)
      $text = $sr.ReadToEnd()
      $sr.Close()
    }

    if ($truncated) {
      $sw.WriteLine("[NOTE] TEXT TRUNCATED at $MaxBytesToDump bytes.")
      $sw.WriteLine()
    }
    $sw.WriteLine($text)
  }
}
finally {
  $sw.Close()
}

Write-Host "DONE -> $OutFile"
Write-Host "DUMPED -> $OutDir"
