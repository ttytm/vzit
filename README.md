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

- #### Use tabs for indentation, format with zig fmt

  https://github.com/ttytm/vzit/assets/34311583/b990a7c2-1863-403f-8274-6718b77ea968

- #### View diffs with your preferred tool

  <!-- prettier-ignore -->
  |   |   |
  | - | - |
  | <img width=506 src="https://github.com/ttytm/vzit/assets/34311583/9a42d2ff-f172-4859-b039-b0c2934092b1"> | <img width=506 src="https://github.com/ttytm/vzit/assets/34311583/79e85cf1-02c0-4a06-825c-279c60d6c38a"> |
  | _Automatically detected (e.g., `delta`)_ | _Or explicitly set (e.g., `diff`)_ |

- #### Usage

  ```
  Usage: vzit [flags] [commands] <path>

  Formatter and diff viewer utilizing zig fmt.
  By default, formatted output is written to stdout.

  Flags:
    -w  --write         Modifies non-conforming files in-place.
    -l  --list          Prints paths of non-conforming files. Exits with an error if any are found.
    -d  --diff          Prints differences of non-conforming files. Exits with an error if any are found.
        --use-spaces    [TODO] Allows usage when kept in custody in a space-indented codebase.
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
