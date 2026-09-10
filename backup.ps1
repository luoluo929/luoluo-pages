# ============================================================
#  luoluo-pages one-click backup script
#  Usage: double-click "one-click-backup.bat"
#         or run:  powershell -ExecutionPolicy Bypass -File backup.ps1
#
#  What it does:
#   1. Creates folder  backup\<yyyyMMdd_HHmmss>\
#   2. Copies index-improved.html, snake.html and assets\ into it
#      (the CHANGELOG update-log lives inside the html, so it is
#       backed up together with the program)
#   3. Appends one line to backup\backup-log.txt
# ============================================================

$root  = $PSScriptRoot
$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$dest  = Join-Path $root ("backup\" + $stamp)

# 1. create the snapshot folder
New-Item -ItemType Directory -Path $dest -Force | Out-Null

# 2. copy program files
Copy-Item (Join-Path $root 'index.html')          $dest
Copy-Item (Join-Path $root 'snake.html')          $dest
Copy-Item (Join-Path $root 'assets')              $dest -Recurse

# 3. append a record to the backup log
$log  = Join-Path $root 'backup\backup-log.txt'
$line = "{0}  ->  backup\{1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $stamp
Add-Content -Path $log -Value $line -Encoding UTF8

Write-Host ""
Write-Host "==============================" -ForegroundColor Green
Write-Host " Backup OK!" -ForegroundColor Green
Write-Host " Location: $dest" -ForegroundColor Green
Write-Host " Log:      $log" -ForegroundColor Green
Write-Host "==============================" -ForegroundColor Green
Write-Host ""
