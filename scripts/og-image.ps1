# Renders scripts/og-image.html to public/og-image.jpg (1200 x 630), the image shown
# when a page of the site is shared. Needs Microsoft Edge. Run it after changing the
# template, the lockup or the photograph, then commit the JPEG.
#
#   powershell -File scripts/og-image.ps1

$ErrorActionPreference = 'Stop'
$site = Split-Path -Parent $PSScriptRoot
$edge = @("${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
          "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe") |
    Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $edge) { throw 'Microsoft Edge is needed to render the image.' }

$page = Join-Path $PSScriptRoot 'og-image.html'
$png = Join-Path $env:TEMP "northlight-og-$PID.png"
$jpg = Join-Path $site 'public\og-image.jpg'
if (Test-Path $png) { Remove-Item $png }
$profile = Join-Path $env:TEMP "northlight-og-profile-$PID"

# Edge reports what it wrote on stderr, which is not an error.
$ErrorActionPreference = 'Continue'
& $edge --headless=new --disable-gpu --hide-scrollbars --force-device-scale-factor=1 `
    --allow-file-access-from-files --user-data-dir="$profile" --virtual-time-budget=3000 `
    --window-size=1200,630 --screenshot="$png" "file:///$($page -replace '\\','/')" 2>&1 | Out-Null
$ErrorActionPreference = 'Stop'

$deadline = (Get-Date).AddSeconds(20)
while (-not (Test-Path $png) -and (Get-Date) -lt $deadline) { Start-Sleep -Milliseconds 200 }
if (-not (Test-Path $png)) { throw 'Edge did not render the image.' }

# A photograph is far smaller as a JPEG, and link previews load faster.
Add-Type -AssemblyName System.Drawing
$image = [System.Drawing.Image]::FromFile($png)
$codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
$params = New-Object System.Drawing.Imaging.EncoderParameters 1
$params.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter ([System.Drawing.Imaging.Encoder]::Quality, [long]88)
$image.Save($jpg, $codec, $params)
$image.Dispose()
Remove-Item $png
Write-Output "  public/og-image.jpg $([math]::Round((Get-Item $jpg).Length / 1KB)) KB"
