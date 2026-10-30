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
# Each scene opens the demo song, Window Seat, plays it silently for a few seconds so
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
# window shot. An effect's editor window is cropped to the effect's own body, without
# the window's title, presets, Bypass, Mix and latency line (InsertEditor::resized in
# the app). The sizes come from the design tokens.
$statusBar = 24
$space = @{ sm = 8; md = 12; lg = 16 }
$control = 28; $controlCompact = 24
if ($App -and (Test-Path (Join-Path $App 'docs\design\tokens.json'))) {
    $tokens = Get-Content -Raw (Join-Path $App 'docs\design\tokens.json') | ConvertFrom-Json
    if ($tokens.size.statusBar) { $statusBar = [int]$tokens.size.statusBar }
    foreach ($k in @('sm', 'md', 'lg')) { if ($tokens.space.$k) { $space[$k] = [int]$tokens.space.$k } }
    if ($tokens.size.control) { $control = [int]$tokens.size.control }
    if ($tokens.size.controlCompact) { $controlCompact = [int]$tokens.size.controlCompact }
}
$editorTop = $space.md + $control + $space.sm + $controlCompact + $space.md
$editorBottom = $space.md + $controlCompact
$editorSide = $space.lg
$scale = 2

$work = Join-Path $env:TEMP "northlight-screenshots-$PID"
New-Item -ItemType Directory -Force $work | Out-Null
$song = Join-Path $work 'demo\Window Seat.northlight'

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
# Copies a capture into the site, optionally trimming pixels off the bottom, the top
# and both sides.
function Keep([string]$from, [string]$to, [int]$trimBottom = 0, [int]$trimTop = 0, [int]$trimSides = 0) {
    if (-not (Test-Path $from)) { throw "Missing capture: $from" }
    $target = Join-Path $shots $to
    if ($trimBottom -le 0 -and $trimTop -le 0 -and $trimSides -le 0) {
        Copy-Item $from $target -Force
    } else {
        $image = [System.Drawing.Image]::FromFile($from)
        $width = $image.Width - 2 * $trimSides
        $height = $image.Height - $trimTop - $trimBottom
        $bitmap = New-Object System.Drawing.Bitmap $width, $height
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
        $graphics.DrawImage($image, (New-Object System.Drawing.Rectangle 0, 0, $width, $height),
            (New-Object System.Drawing.Rectangle $trimSides, $trimTop, $width, $height),
            [System.Drawing.GraphicsUnit]::Pixel)
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
    $effectSong = "`"$(Join-Path $work "demo-$type\Window Seat.northlight")`""
    $shot = Capture $type @('--demo-song', $effectSong, '--master-insert', "northlight.$type",
        '--insert-editor', "northlight.$type", '--play') $Seconds
    $window = Get-ChildItem $shot -Filter 'window-*.png' | Select-Object -First 1
    if (-not $window) { throw "The '$type' capture has no editor window." }
    Keep $window.FullName "$($effects[$type]).png" ($editorBottom * $scale) ($editorTop * $scale) ($editorSide * $scale)
}

# The guitar pedals, as one pedalboard: all five open at once, each editor cut to its
# patch of carpet (the face is scaled to fit and centred, with the window's canvas
# round it), then set side by side in signal order.
$pedals = @('polaris', 'gravity', 'flare', 'tide', 'comet')
$pedalSong = "`"$(Join-Path $work 'demo-pedals\Window Seat.northlight')`""
$flags = @('--demo-song', $pedalSong)
foreach ($p in $pedals) { $flags += @('--master-insert', "northlight.$p") }
foreach ($p in $pedals) { $flags += @('--insert-editor', "northlight.$p") }
$board = Capture 'pedals' ($flags + @('--play')) $Seconds

# The carpet's bounds in an editor's body: where the pixels stop matching the canvas,
# found along the body's middle row and column.
function CarpetBounds([System.Drawing.Bitmap]$image) {
    $left = $editorSide * $scale; $top = $editorTop * $scale
    $right = $image.Width - $left - 1; $bottom = $image.Height - $editorBottom * $scale - 1
    $canvas = $image.GetPixel($left + 2, $top + 2)
    $differs = {
        param($x, $y)
        $c = $image.GetPixel($x, $y)
        [Math]::Abs($c.R - $canvas.R) + [Math]::Abs($c.G - $canvas.G) + [Math]::Abs($c.B - $canvas.B) -gt 12
    }
    $midY = [int](($top + $bottom) / 2); $midX = [int](($left + $right) / 2)
    $x0 = $left; while ($x0 -lt $right -and -not (& $differs $x0 $midY)) { $x0++ }
    $x1 = $right; while ($x1 -gt $x0 -and -not (& $differs $x1 $midY)) { $x1-- }
    $y0 = $top; while ($y0 -lt $bottom -and -not (& $differs $midX $y0)) { $y0++ }
    $y1 = $bottom; while ($y1 -gt $y0 -and -not (& $differs $midX $y1)) { $y1-- }
    return New-Object System.Drawing.Rectangle $x0, $y0, ($x1 - $x0 + 1), ($y1 - $y0 + 1)
}

$parts = foreach ($p in $pedals) {
    $file = Get-ChildItem $board -Filter "window-*-$p.png" | Select-Object -First 1
    if (-not $file) { throw "The pedals capture has no $p window." }
    $image = New-Object System.Drawing.Bitmap $file.FullName
    [pscustomobject]@{ Image = $image; Bounds = CarpetBounds $image }
}
$height = [int]($parts | ForEach-Object { $_.Bounds.Height } | Measure-Object -Minimum).Minimum
$width = [int]($parts | ForEach-Object { $_.Bounds.Width } | Measure-Object -Sum).Sum
$pedalboard = New-Object System.Drawing.Bitmap $width, $height
$graphics = [System.Drawing.Graphics]::FromImage($pedalboard)
$x = 0
foreach ($part in $parts) {
    $b = $part.Bounds
    $graphics.DrawImage($part.Image, (New-Object System.Drawing.Rectangle $x, 0, $b.Width, $height),
        (New-Object System.Drawing.Rectangle $b.X, $b.Y, $b.Width, $height), [System.Drawing.GraphicsUnit]::Pixel)
    $x += $b.Width
    $part.Image.Dispose()
}
$graphics.Dispose()
$pedalboard.Save((Join-Path $shots 'pedals.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$pedalboard.Dispose()
Write-Host '  -> src/assets/screenshots/pedals.png'

# Lumen and Cirrus, each from its track in the demo song, in a dock tall enough to show
# its face at full size. The rows count every track, channel and folder in the arrange
# view. A face narrower or shorter than the dock leaves a plain border, which is cut off.
function TrimPlain([string]$file) {
    $image = New-Object System.Drawing.Bitmap $file
    # A row or column is plain when it is one colour, leaving out the rounded corners
    # at its ends.
    $plain = {
        param([bool]$row, [int]$i)
        $n = if ($row) { $image.Width } else { $image.Height }
        $corner = 24
        $first = if ($row) { $image.GetPixel($corner, $i) } else { $image.GetPixel($i, $corner) }
        for ($j = $corner; $j -lt $n - $corner; $j += 4) {
            $c = if ($row) { $image.GetPixel($j, $i) } else { $image.GetPixel($i, $j) }
            if ([Math]::Abs($c.R - $first.R) + [Math]::Abs($c.G - $first.G) + [Math]::Abs($c.B - $first.B) -gt 12) { return $false }
        }
        return $true
    }
    $x0 = 0; while ($x0 -lt $image.Width - 1 -and (& $plain $false $x0)) { $x0++ }
    $x1 = $image.Width - 1; while ($x1 -gt $x0 -and (& $plain $false $x1)) { $x1-- }
    $y0 = 0; while ($y0 -lt $image.Height - 1 -and (& $plain $true $y0)) { $y0++ }
    $y1 = $image.Height - 1; while ($y1 -gt $y0 -and (& $plain $true $y1)) { $y1-- }
    # Where the face's own background carries on past the cut (padding, not the dock),
    # keep a margin of it.
    $margin = 32; $c = 4
    $same = {
        param($a, $b)
        [Math]::Abs($a.R - $b.R) + [Math]::Abs($a.G - $b.G) + [Math]::Abs($a.B - $b.B) -le 12
    }
    # Each side is checked at a point just inside the kept area.
    $left = $x0 -gt 0 -and (& $same $image.GetPixel($x0 - 1, $y0 + $c) $image.GetPixel($x0, $y0 + $c))
    $right = $x1 -lt $image.Width - 1 -and (& $same $image.GetPixel($x1 + 1, $y0 + $c) $image.GetPixel($x1, $y0 + $c))
    $top = $y0 -gt 0 -and (& $same $image.GetPixel($x0 + $c, $y0 - 1) $image.GetPixel($x0 + $c, $y0))
    $bottom = $y1 -lt $image.Height - 1 -and (& $same $image.GetPixel($x0 + $c, $y1 + 1) $image.GetPixel($x0 + $c, $y1))
    if ($left) { $x0 = [Math]::Max(0, $x0 - $margin) }
    if ($right) { $x1 = [Math]::Min($image.Width - 1, $x1 + $margin) }
    if ($top) { $y0 = [Math]::Max(0, $y0 - $margin) }
    if ($bottom) { $y1 = [Math]::Min($image.Height - 1, $y1 + $margin) }
    $width = $x1 - $x0 + 1; $height = $y1 - $y0 + 1
    $trimmed = New-Object System.Drawing.Bitmap $width, $height
    $graphics = [System.Drawing.Graphics]::FromImage($trimmed)
    $graphics.DrawImage($image, (New-Object System.Drawing.Rectangle 0, 0, $width, $height),
        (New-Object System.Drawing.Rectangle $x0, $y0, $width, $height), [System.Drawing.GraphicsUnit]::Pixel)
    $graphics.Dispose(); $image.Dispose()
    $trimmed.Save($file, [System.Drawing.Imaging.ImageFormat]::Png)
    $trimmed.Dispose()
}

$instruments = [ordered]@{ 'lumen' = 8; 'cirrus' = 10 }
foreach ($name in $instruments.Keys) {
    $row = $instruments[$name]
    $instrumentSong = "`"$(Join-Path $work "demo-$name\Window Seat.northlight")`""
    $shot = Capture $name @('--demo-song', $instrumentSong, '--select-tracks', "$row", "$row",
        '--panel', 'editor', '--dock-height', '620', '--play') $Seconds
    $target = Join-Path $shots "$name.png"
    Keep (Join-Path $shot 'instrument.png') "$name.png"
    TrimPlain $target
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
