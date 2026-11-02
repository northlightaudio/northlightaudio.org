---
template: splash
title: Northlight 0.1.0 beta 2, now on Linux
description: The second beta adds an experimental Linux version, as an AppImage. Here's how to run it and what doesn't work yet.
date: 2026-11-02
---

Northlight 0.1.0-beta.2 adds a version for Linux. It's experimental: it builds, its
tests pass and it runs, but far fewer people have used it than the Windows version,
and some parts are still missing. If you make music on Linux, try it and tell us how it
goes.

There's nothing new for Windows in this release. If you have beta 1, you don't need to
update.

[Download the AppImage](https://github.com/northlightaudio/northlight/releases/download/v0.1.0-beta.2/Northlight-0.1.0-beta.2-x86_64.AppImage),
or see everything on the
[release page](https://github.com/northlightaudio/northlight/releases/tag/v0.1.0-beta.2).

## Running it

Northlight for Linux is one file, an AppImage, with nothing to install. Make it
executable and run it:

```sh
chmod +x Northlight-0.1.0-beta.2-x86_64.AppImage
./Northlight-0.1.0-beta.2-x86_64.AppImage
```

It needs a 64-bit PC and a distribution from 2022 or later: Ubuntu 22.04 or newer, or
anything with glibc 2.35 or newer. If it doesn't start, run it with
`--appimage-extract-and-run`, and please [tell us](https://github.com/northlightaudio/northlight/issues)
which distribution you're on. To check your download, compare it with the checksums
in `SHA256SUMS.txt` on the release page.

## Audio

Northlight plays through JACK when a JACK server is running, and that includes
PipeWire through its JACK layer (`pipewire-jack` on most distributions). Otherwise it
uses ALSA. You can change the device in Audio Setup.

For steady playback at small buffer sizes, Northlight runs its audio threads at
real-time priority. It can do that when your user is in a group allowed real-time
priority (usually `audio`), or through rtkit, which most desktop distributions
already run. Diagnostics shows whether it worked.

## What doesn't work yet

- CLAP plugins run, but their windows don't open, so they have no editor. VST3
  plugins' windows should work but haven't been tested much.
- A plugin that crashes takes Northlight down with it. On Windows, Northlight catches
  the crash and keeps running. Plugin scanning is safe on both, because it runs in a
  separate process.
- Crash reports aren't made, and the high contrast and reduce motion settings don't
  follow the system's. You can still set them in Preferences.

Everything else in [the first beta](/news/northlight-0-1-0-beta-1/) is there: the
instruments, the effects, recording, mixing, editing and export.

## Tell us what you find

- **Bugs:** [open an issue](https://github.com/northlightaudio/northlight/issues) on
  GitHub. For Linux, say which distribution you use and whether you're on JACK,
  PipeWire or ALSA.
- **Questions and ideas:** ask in
  [Discussions](https://github.com/northlightaudio/northlight/discussions) or on
  [Discord](https://discord.gg/dkW3NSenhP).

There's still no version for Mac.
