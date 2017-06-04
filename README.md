# arm7_tdmi

[![Build Status](https://travis-ci.org/matanlurey/arm7_tdmi.svg?branch=master)](https://travis-ci.org/matanlurey/arm7_tdmi)
[![Coverage Status](https://coveralls.io/repos/github/matanlurey/arm7_tdmi/badge.svg)](https://coveralls.io/github/matanlurey/arm7_tdmi)

An emulator for the ARM7/TDMI processor.

This project is primarily academic/educational, and prefers idiomatic Dart and
readability over performance. After completion it should be executable on any
major platform, including the web, standalone VM, and Flutter.

## Progress

**WARNING**: Largely incomplete and not ready for use.

Goals (*subject to change*):

- [ ] Be able to run (emulated) programs compiled for the ARM7/TDMI
- [ ] A web and command-line interface for testing/debugging compiled programs
- [ ] Use in other emulator projects (educational only)
- [ ] An end-to-end example of a large/complex cross-platform library for Dart
- [ ] A test suite for others to write their own processor implementations

## Learning more about the ARM7/TDMI

Notable uses of this processor include:

* Microsoft Zune HD
* Nintendo DS
* Nintendo GameBoy Advance
* Nokia 6110
* Sega Dreamcast

* [Wikipedia for ARM7/TDMI][wiki]
* [ARM7/TDMI Manual][manual]
* [Official ARM7/TDMI Documentation][docs]

[wiki]: https://en.wikipedia.org/wiki/ARM7#ARM7TDMI
[manual]: http://www.atmel.com/images/ddi0029g_7tdmi_r3_trm.pdf
[docs]: https://www.scss.tcd.ie/~waldroj/3d1/arm_arm.pdf
