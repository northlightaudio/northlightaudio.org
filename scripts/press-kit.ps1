# Builds the press kit in public/press: the logo files and app icons from the
# Northlight repository, PNG renders of the logos, the site's screenshots, and a zip
# of all of it. Run it after a brand change (with the app checked out beside this
# repository) or after replacing a screenshot, then commit the result.
#
#   powershell -File scripts/press-kit.ps1
#   powershell -File scripts/press-kit.ps1 -App path\to\northlight
#
# The PNGs are rendered by Microsoft Edge in headless mode, on a transparent background.

param([string]$App = '')

$ErrorActionPreference = 'Stop'
$site = Split-Path -Parent $PSScriptRoot
if (-not $App) {
    $App = @('..\northlight', '..\aural') | ForEach-Object { Join-Path $site $_ } |
        Where-Object { Test-Path (Join-Path $_ 'assets\brand') } | Select-Object -First 1
}
if (-not $App -or -not (Test-Path (Join-Path $App 'assets\brand'))) {
    throw 'No Northlight checkout found beside this repository. Pass -App.'
}
$brand = Join-Path (Resolve-Path $App) 'assets\brand'
$edge = @("${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
          "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe") |
    Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $edge) { throw 'Microsoft Edge is needed to render the PNGs.' }

$press = Join-Path $site 'public\press'
if (Test-Path $press) { Remove-Item -Recurse -Force $press }
$logo = New-Item -ItemType Directory -Force (Join-Path $press 'northlight-press-kit\logo')
$icon = New-Item -ItemType Directory -Force (Join-Path $press 'northlight-press-kit\icon')
$shots = New-Item -ItemType Directory -Force (Join-Path $press 'northlight-press-kit\screenshots')

Copy-Item (Join-Path $brand 'northlight-*.svg') $logo
foreach ($size in 256, 1024) { Copy-Item (Join-Path $brand "northlight-icon-$size.png") $icon }
Copy-Item (Join-Path $site 'src\assets\screenshots\*') $shots

# Renders one SVG to a PNG of the given width, keeping its aspect ratio.
function Render([string]$svg, [string]$png, [int]$width) {
    $text = Get-Content -Raw $svg
    if ($text -notmatch 'viewBox="0 0 ([\d.]+) ([\d.]+)"') { throw "No viewBox in $svg" }
    $height = [int][math]::Round($width * [double]$Matches[2] / [double]$Matches[1])
    $page = Join-Path $env:TEMP "northlight-render-$PID.html"
    $data = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($text))
    Set-Content -Encoding utf8 $page ("<!doctype html><html><body style=`"margin:0;background:transparent`">" +
        "<img src=`"data:image/svg+xml;base64,$data`" style=`"display:block;width:${width}px;height:${height}px`"></body></html>")
    $profile = Join-Path $env:TEMP "northlight-render-profile-$PID"
    # Edge reports what it wrote on stderr, which is not an error.
    $ErrorActionPreference = 'Continue'
    & $edge --headless=new --disable-gpu --hide-scrollbars --force-device-scale-factor=1 `
        --default-background-color=00000000 --user-data-dir="$profile" `
        --window-size="$width,$height" --screenshot="$png" "file:///$($page -replace '\\','/')" 2>&1 | Out-Null
    $ErrorActionPreference = 'Stop'
    $deadline = (Get-Date).AddSeconds(20)
    while (-not (Test-Path $png) -and (Get-Date) -lt $deadline) { Start-Sleep -Milliseconds 200 }
    Remove-Item $page -ErrorAction SilentlyContinue
    if (-not (Test-Path $png)) { throw "Edge did not render $png" }
    Write-Output "  $(Split-Path -Leaf $png) ${width}x$height"
}

Write-Output "From $brand"
foreach ($variant in '', '-on-light') {
    Render (Join-Path $logo "northlight-lockup$variant.svg") (Join-Path $logo "northlight-lockup$variant.png") 2400
    Render (Join-Path $logo "northlight-mark$variant.svg") (Join-Path $logo "northlight-mark$variant.png") 1024
    Render (Join-Path $logo "northlight-wordmark$variant.svg") (Join-Path $logo "northlight-wordmark$variant.png") 2000
}

$zip = Join-Path $press 'northlight-press-kit.zip'
Compress-Archive -Path (Join-Path $press 'northlight-press-kit') -DestinationPath $zip -CompressionLevel Optimal
Write-Output "  northlight-press-kit.zip $([math]::Round((Get-Item $zip).Length / 1MB, 1)) MB"
