---
template: splash
title: Northlight 0.1.0 beta 1, the first release
description: The first public release of Northlight is out, as a beta for Windows. Here's what's in it and what to expect.
date: 2026-11-01
---

Northlight 0.1.0-beta.1 is the first public release. It's a beta: it's ready to
make music with, but it hasn't yet been used by many people on many computers, and
that's what this release is for. Download it, make something with it, and tell us what breaks.

[Get it from the release page on GitHub](https://github.com/northlightaudio/northlight/releases/tag/v0.1.0-beta.1).

## What's in it

- **Recording** from any number of inputs, mono or stereo, over ASIO or Windows
  Audio, with input monitoring, latency calibration through a loopback cable, loop
  and punch recording into take lanes with comping, and recovery of recordings cut off
  by a crash.
- **Mixing** with buses, FX tracks, sends, fader groups, sidechains and delay
  compensation, and a channel strip on every channel: gate, EQ, compressor, de-esser,
  saturation and limiter.
- **Plugins:** VST3 and CLAP instruments and effects, scanned in a separate process
  so a bad plugin can't take Northlight down with it. A plugin that crashes can be
  reloaded from its last state without restarting.
- **Instruments:** Pulsar drums, Aurora, Nebula, Starbit, the Lumen electric piano,
  the Cirrus FM synth and a sampler, with a piano roll, MIDI file import and export,
  and twelve MIDI effects, from an arpeggiator to Chord Pads.
- **Effects** for every job, from the EQ and compressors to Vesper, a reverb that
  gets out of the way of the singing; Orbit, a tape machine for the mix bus; the Corona
  guitar amp; and five guitar pedals, including a tuner.
- **Editing:** a tempo track, clip time-stretch and transposition, vocal pitch
  editing note by note, automation in Read, Touch, Latch and Write, markers, regions,
  folders and freezing.
- **Export** to WAV, AIFF, FLAC and Ogg Vorbis, with loudness normalisation and dither.

The [manual](/manual/) covers how to use all of it, and the
[changelog](https://github.com/northlightaudio/northlight/blob/main/CHANGELOG.md)
lists every change.

## Installing it

There are two downloads: an installer, and a portable zip that runs from any folder.
The installer doesn't need administrator rights unless you install for everyone on the
computer. Neither needs anything else installed first. You need Windows 10 or 11,
64-bit.

Northlight isn't code-signed yet, so the first time you run it Windows SmartScreen
warns that the publisher is unknown. Choose **More info**, then **Run anyway**. To
check your download, compare it with the checksums in `SHA256SUMS.txt` on the release
page.

## What a beta means here

Expect bugs. Save often; Northlight autosaves, and keeps the previous version of a
project beside it each time you save, but a beta is a good time to keep your own
copies too. Projects made with this beta should open in later versions, but until 1.0
that isn't a promise.

There's no version for Mac or Linux yet.

## Tell us what you find

- **Bugs:** [open an issue](https://github.com/northlightaudio/northlight/issues) on
  GitHub. Say what you did, what you expected and what happened instead; your audio
  interface and its driver help too.
- **Questions and ideas:** ask in
  [Discussions](https://github.com/northlightaudio/northlight/discussions) or on
  [Discord](https://discord.gg/dkW3NSenhP).

What comes next, longer tests, more audio interfaces and design polish, is on the
[roadmap](https://github.com/northlightaudio/northlight/blob/main/docs/roadmap.md).
