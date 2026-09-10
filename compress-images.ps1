# 直接定义变量，不依赖 $PSScriptRoot
$assetsDir = "c:\Users\wjw\AppData\Local\Temp\luoluo-pages\assets"
$backupDir = "c:\Users\wjw\AppData\Local\Temp\luoluo-pages\backup\images-originals"
if (-not (Test-Path $backupDir)) { New-Item -ItemType Directory -Path $backupDir -Force | Out-Null }

# 加载 System.Drawing
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")

$targets = @(
    @{name='doubao.png'; w=64},
    @{name='avatar.jpg'; w=128},
    @{name='dy.png'; w=64},
    @{name='wx.png'; w=64},
    @{name='qq.jpg'; w=64},
    @{name='wxtx.png'; w=64},
    @{name='Python.png'; w=64},
    @{name='x.png'; w=64},
    @{name='qqyx.png'; w=64},
    @{name='weibo.jpg'; w=64},
    @{name='github.png'; w=64},
    @{name='twitch.png'; w=64},
    @{name='bb.webp'; w=64},
    @{name='wyy.webp'; w=64}
)

Write-Host "========================================"
Write-Host "  Image compression started"
Write-Host "========================================"
Write-Host ""

$compressed = 0
$skipped = 0

foreach ($t in $targets) {
    $name = $t.name
    $targetW = $t.w
    $src = "$assetsDir\$name"
    if (-not (Test-Path $src)) {
        Write-Host "  SKIP $name (not found)"
        $skipped++
        continue
    }
    $beforeSize = (Get-Item $src).Length
    $beforeKB = [math]::Round($beforeSize/1KB, 1)

    Copy-Item $src "$backupDir\$name" -Force -ErrorAction SilentlyContinue

    $tmp = "$src.tmp"
    $ok = $false
    try {
        $original = [System.Drawing.Image]::FromFile($src)
        $srcW = $original.Width
        $srcH = $original.Height
        if ($srcW -le $targetW) {
            $original.Dispose()
            Write-Host "  $name : SKIP (already small)"
            $skipped++
            continue
        }
        $newW = $targetW
        $newH = [int]($srcH * ($targetW / $srcW))
        $bmp = New-Object System.Drawing.Bitmap($newW, $newH)
        $bmp.SetResolution(72, 72)
        $g = [System.Drawing.Graphics]::FromImage($bmp)
        $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
        $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $g.Clear([System.Drawing.Color]::Transparent)
        $g.DrawImage($original, 0, 0, $newW, $newH)
        $g.Dispose()

        $ext = [System.IO.Path]::GetExtension($src).ToLower()
        if ($ext -eq '.jpg') {
            $jpegCodec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
            $encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
            $encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, 82L)
            $bmp.Save($tmp, $jpegCodec, $encoderParams)
        } else {
            $bmp.Save($tmp, [System.Drawing.Imaging.ImageFormat]::Png)
        }
        $bmp.Dispose()
        $original.Dispose()
        $ok = $true
    } catch {
        Write-Host "  $name : ERROR $_"
    }

    if ($ok -and (Test-Path $tmp)) {
        Move-Item $tmp $src -Force
        $afterSize = (Get-Item $src).Length
        $afterKB = [math]::Round($afterSize/1KB, 1)
        $saved = [math]::Round(($beforeSize - $afterSize)/1KB, 1)
        $pct = [math]::Round(($afterSize/$beforeSize)*100)
        Write-Host "  $name : $beforeKB KB -> $afterKB KB (-$saved KB, $pct%)"
        $compressed++
    } else {
        if (Test-Path $tmp) { Remove-Item $tmp -Force -ErrorAction SilentlyContinue }
        $skipped++
    }
}

Write-Host ""
Write-Host "Done: $compressed compressed, $skipped skipped"
Write-Host "Originals: $backupDir"
