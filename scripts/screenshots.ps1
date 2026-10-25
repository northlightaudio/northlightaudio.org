# Regenerates the site's screenshots (src/assets/screenshots) from the app itself, then
# rebuilds the press kit. Run it whenever the app's design changes, check the images,
# and commit them.
#
#   powershell -File scripts/screenshots.ps1
#   powershell -File scripts/screenshots.ps1 -App ..\northlight
#   powershell -File scripts/screenshots.ps1 -Vocal path\to\sung-take.wav -Key 9
#
# It needs a build of Northlight with --capture (the app's capture mode): the newest
# Northlight.exe under the app checkout's build folder, or the one given with -Exe.
# Each scene opens the demo song, Northern Drift, plays it silently for a few seconds so
# the meters and displays have something to show, and the app saves its window and
# named parts of it at 2x. Capture mode keeps its own settings, so your layout,
# plugins and device choice are not used or changed.
#
# The vocal pitch editing shot needs a recording of a voice, which the demo song does not
# have: pass one with -Vocal (and the song's key with -Key, a pitch class 0 = C to 11 = B)
# to regenerate it. Without -Vocal that screenshot is left as it is.

param(
    [string]$App = '',
    [string]$Exe = '',
    [string]$Vocal = '',
    [string]$Key = '',
    [int]$Seconds = 14,
    [switch]$SkipPressKit
)

$ErrorActionPreference = 'Stop'
$site = Split-Path -Parent $PSScriptRoot
$shots = Join-Path $site 'src\assets\screenshots'

if (-not $App) {
    $App = @('..\northlight', '..\aural') | ForEach-Object { Join-Path $site $_ } |
        Where-Object { Test-Path (Join-Path $_ 'docs\design\tokens.json') } | Select-Object -First 1
}
if (-not $Exe) {
    if (-not $App) { throw 'No Northlight checkout found beside this repository. Pass -App or -Exe.' }
    $Exe = Get-ChildItem (Join-Path $App 'build') -Recurse -Filter Northlight.exe -ErrorAction SilentlyContinue |
        Where-Object { $_.DirectoryName -like '*northlight_artefacts*' } |
        Sort-Object LastWriteTime -Descending | Select-Object -First 1 -ExpandProperty FullName
}
if (-not $Exe -or -not (Test-Path $Exe)) { throw 'No Northlight.exe found. Build the app, or pass -Exe.' }
Write-Output "Capturing with $Exe"

# The status bar shows the capturing machine's audio device, so it is trimmed off the
# window shot. Its height comes from the design tokens.
$statusBar = 24
if ($App -and (Test-Path (Join-Path $App 'docs\design\tokens.json'))) {
    $tokens = Get-Content -Raw (Join-Path $App 'docs\design\tokens.json') | ConvertFrom-Json
    if ($tokens.size.statusBar) { $statusBar = [int]$tokens.size.statusBar }
}
$scale = 2

$work = Join-Path $env:TEMP "northlight-screenshots-$PID"
New-Item -ItemType Directory -Force $work | Out-Null
$song = Join-Path $work 'demo\Northern Drift.northlight'

# Runs the app with the flags, waits for it to save its captures and quit, and returns
# the folder they are in.
function Capture([string]$name, [string[]]$flags, [int]$wait) {
    $out = Join-Path $work $name
    $all = @('--no-splash', '--window-size', '1600x1000') + $flags +
        @('--capture-scale', "$scale", '--capture', "`"$out`"", "$wait")
    $process = Start-Process $Exe -ArgumentList $all -PassThru
    if (-not $process.WaitForExit(($wait + 60) * 1000)) {
        $process.Kill()
        throw "The app did not finish the '$name' capture."
    }
    if (-not (Test-Path (Join-Path $out 'window.png'))) {
        throw "The '$name' capture saved nothing. Is this a build with --capture?"
    }
    Write-Host "  $name`: $((Get-ChildItem $out -Filter *.png).Name -join ', ')"
    return $out
}

Add-Type -AssemblyName System.Drawing
# Copies a capture into the site, optionally trimming pixels off the bottom.
function Keep([string]$from, [string]$to, [int]$trimBottom = 0) {
    if (-not (Test-Path $from)) { throw "Missing capture: $from" }
    $target = Join-Path $shots $to
    if ($trimBottom -le 0) {
        Copy-Item $from $target -Force
    } else {
        $image = [System.Drawing.Image]::FromFile($from)
        $bitmap = New-Object System.Drawing.Bitmap $image.Width, ($image.Height - $trimBottom)
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
        $graphics.DrawImage($image, 0, 0)
        $graphics.Dispose(); $image.Dispose()
        $bitmap.Save($target, [System.Drawing.Imaging.ImageFormat]::Png)
        $bitmap.Dispose()
    }
    Write-Host "  -> src/assets/screenshots/$to"
}

$song = "`"$song`""
$mixer = Capture 'mixer' @('--demo-song', $song, '--panel', 'mixer', '--play') $Seconds
$editor = Capture 'editor' @('--demo-song', $song, '--strip', 'demo', '--panel', 'editor', '--play') $Seconds

Keep (Join-Path $mixer 'window.png') 'arrange-and-mixer.png' ($statusBar * $scale)
Keep (Join-Path $mixer 'mixer.png') 'mixer.png'
Keep (Join-Path $editor 'channel-strip.png') 'channel-strip.png'
Keep (Join-Path $editor 'instrument.png') 'pulsar-drum-synth.png'

# The hero effects, each on the master so its displays have the whole song to show.
# The demo song is written fresh for each run, so each gets its own folder.
$effects = [ordered]@{
    'glue' = 'glue-compressor'; 'orbit' = 'orbit'; 'patina' = 'patina'; 'tapeecho' = 'tape-echo'
    'bloom' = 'bloom'; 'vesper' = 'vesper'; 'amp' = 'corona'
}
foreach ($type in $effects.Keys) {
    $effectSong = "`"$(Join-Path $work "demo-$type\Northern Drift.northlight")`""
    $shot = Capture $type @('--demo-song', $effectSong, '--master-insert', "northlight.$type",
        '--insert-editor', "northlight.$type", '--play') $Seconds
    $window = Get-ChildItem $shot -Filter 'window-*.png' | Select-Object -First 1
    if (-not $window) { throw "The '$type' capture has no editor window." }
    Keep $window.FullName "$($effects[$type]).png"
}

if ($Vocal) {
    if (-not (Test-Path $Vocal)) { throw "No such file: $Vocal" }
    $flags = @('--import', "`"$((Resolve-Path $Vocal).Path)`"")
    if ($Key) { $flags += @('--key', $Key) }
    $flags += @('--audio-editor', 'pitch', '--correct-pitch')
    $pitch = Capture 'pitch' $flags ($Seconds + 10)
    Keep (Join-Path $pitch 'audio-editor.png') 'vocal-pitch-editing.png'
} else {
    Write-Output '  vocal-pitch-editing.png left as it is (pass -Vocal to regenerate it)'
}

Remove-Item -Recurse -Force $work -ErrorAction SilentlyContinue

if (-not $SkipPressKit) {
    & (Join-Path $PSScriptRoot 'press-kit.ps1') -App $App
}
