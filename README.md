# fzf-git.sh Learning Version

> [!important]
> This repository is for my personal study only. The original and official
> [README] of [fzf-git.sh] is available here:
> <https://github.com/junegunn/fzf-git.sh/blob/main/README.md>

**Table of Contents**

* [fzf-git.sh Learning Version](#fzf-gitsh-learning-version)
  * [Installation](#installation)
  * [Usage](#usage)
    * [List of bindings](#list-of-bindings)
    * [Inside fzf](#inside-fzf)
  * [Customization](#customization)
  * [Defining shortcut commands](#defining-shortcut-commands)
  * [Environment Variables](#environment-variables)

## Installation

See the original [README].

## Usage

### List of bindings

All the original bindings in `fzf-git.sh` were removed. To reproduce the
original bindings, set as follows in `.inputrc`:

```raw
# .inputrc

$if mode=emacs
  set keymap emacs-ctlx

  # \e[0n: redraw-current-line
  "gb": " \C-u \C-a\C-k`fzf_git_branch`\e\C-e\C-y\C-a\C-y\ey\C-h\C-e\e[0n \C-h"
  "ge": " \C-u \C-a\C-k`fzf_git_each_ref`\e\C-e\C-y\C-a\C-y\ey\C-h\C-e\e[0n \C-h"
  "gf": " \C-u \C-a\C-k`fzf_git_file`\e\C-e\C-y\C-a\C-y\ey\C-h\C-e\e[0n \C-h"
  "gh": " \C-u \C-a\C-k`fzf_git_hash`\e\C-e\C-y\C-a\C-y\ey\C-h\C-e\e[0n \C-h"
  "gl": " \C-u \C-a\C-k`fzf_git_reflog`\e\C-e\C-y\C-a\C-y\ey\C-h\C-e\e[0n \C-h"
  "gr": " \C-u \C-a\C-k`fzf_git_remote`\e\C-e\C-y\C-a\C-y\ey\C-h\C-e\e[0n \C-h"
  "gs": " \C-u \C-a\C-k`fzf_git_stash`\e\C-e\C-y\C-a\C-y\ey\C-h\C-e\e[0n \C-h"
  "gt": " \C-u \C-a\C-k`fzf_git_tag`\e\C-e\C-y\C-a\C-y\ey\C-h\C-e\e[0n \C-h"
  "gw": " \C-u \C-a\C-k`fzf_git_worktree`\e\C-e\C-y\C-a\C-y\ey\C-h\C-e\e[0n \C-h"
$endif
```

Of course `bind -m` can also be used.

For example, <kbd>Ctrl</kbd>+<kbd>X</kbd>, <kbd>G</kbd>, <kbd>B</kbd> invokes
fzf-git.sh command `fzf_git_branch`.

> [!tip]
> `bind -S | grep fzf_git` shows fzf-git.sh-related key bindings.

### Inside fzf

<kbd>Tab</kbd>/<kbd>Shift</kbd>+<kbd>Tab</kbd>, <kbd>Ctrl</kbd>+<kbd>/</kbd>,
and <kbd>Ctrl</kbd>+<kbd>O</kbd> are also available in my version.

## Customization

See the original [README]. `_fzf_git_fzf` is now renamed to `fzf_git_fzf`.

## Defining shortcut commands

See the original [README]. Available functions are slightly renamed.

## Environment Variables

See the original [README].

[fzf-git.sh]: <https://github.com/junegunn/fzf-git.sh>
[README]: <https://github.com/junegunn/fzf-git.sh/blob/main/README.md>
