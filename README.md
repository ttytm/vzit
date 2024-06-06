# VZiT

[badge__build]: https://img.shields.io/github/actions/workflow/status/ttytm/vzit/ci.yml?branch=main&logo=github&logoColor=C0CAF5&labelColor=333
[badge__version]: https://img.shields.io/github/v/release/ttytm/vzit?logo=task&logoColor=C0CAF5&labelColor=333

[![][badge__build]](https://github.com/ttytm/vzit/actions?query=branch%3Amain)
[![][badge__version]](https://github.com/ttytm/vzit/releases/latest)

Simple tool that enables the use of tabs in Zig projects and allows to view formatting diffs while still utilizing `zig fmt`. Written in V.

## Quick Start

- [Installation](https://github.com/ttytm/vzit/wiki/Installation)
- [Editor Setup](https://github.com/ttytm/vzit/wiki/Editor-Setup)
  - [Neovim](https://github.com/ttytm/vzit/wiki/Editor-Setup#neovim)
  - [VS Code / Codium](https://github.com/ttytm/vzit/wiki/Editor-Setup#vs-code--codium)

## Feature Overview

- Use tabs for indentation while using zig fmt (we don't want to miss out on the amazing work that goes into zig format).
- View diffs with your preferred tool.

https://github-production-user-asset-6210df.s3.amazonaws.com/34311583/337395033-be5d0270-713f-495a-9f91-15665841eb64.mp4?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAVCODYLSA53PQK4ZA%2F20240606%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20240606T184324Z&X-Amz-Expires=300&X-Amz-Signature=2df83e6313c9b80dfaab603825d552c4858a2876cbb7331afea85da1547f8097&X-Amz-SignedHeaders=host&actor_id=34311583&key_id=0&repo_id=802144933

## Usage

```
Usage: vzit [flags] [commands] <path>

Formatter and diff viewer utilizing zig fmt.
By default, formatted output is written to stdout.

Flags:
  -w  --write         Modifies non-conforming files in-place.
  -l  --list          Prints paths of non-conforming files. Exits with an error if any are found.
  -d  --diff          Prints differences of non-conforming files. Exits with an error if any are found.
  -i  --indentation   [possible values: 'tabs', 'smart', '<num>'(spaces)].
                      - tabs: used by default.
                      - smart: detects the indentation style.
                      - <num>: number of spaces.
  -h  --help          Prints help information.
  -v  --version       Prints version information.

Commands:
  update              Updates vizit to the latest version.
  help                Prints help information.
  version             Prints version information.
```

## Disclaimer

Maintaining quality throughout development will be paramount.
However, it is still an early release. Until a stable 1.0 release is available, minor versions (`0.<minor>.*`) may contain breaking changes.

This is a spare time project. Please take it easy if there are delays in replying.
