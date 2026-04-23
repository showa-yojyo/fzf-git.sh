fzf-git.sh
==========

bash functions for Git objects, powered by [fzf].

<img width="1680" alt="image" src="https://user-images.githubusercontent.com/700826/185568470-20d70937-eea4-4274-aec5-14dfe7ee2de6.png">

[fzf]: https://github.com/junegunn/fzf

Installation
------------

* Install the latest version of [fzf]
    * (Optional) Install [bat](https://github.com/sharkdp/bat) for
      syntax-highlighted file previews
    * Git v2.42.0 or later is required for the `git for-each-ref`
* Update your shell configuration file
    * bash
        * Source [fzf-git.sh](https://raw.githubusercontent.com/junegunn/fzf-git.sh/main/fzf-git.sh) file from your .bashrc

Usage
-----

### Inside fzf

* <kbd>TAB</kbd> or <kbd>SHIFT-TAB</kbd> to select multiple objects
* <kbd>CTRL-/</kbd> to change preview window layout
* <kbd>CTRL-O</kbd> to open the object in the web browser (in GitHub URL scheme)

Customization
-------------

```sh
# Redefine this function to change the options
fzf_git_fzf() {
  fzf --height 50% --tmux 90%,70% \
    --layout reverse --multi --min-height 20+ --border \
    --no-separator --header-border horizontal \
    --border-label-pos 2 \
    --color 'label:blue' \
    --preview-window 'right,50%' --preview-border line \
    --bind 'ctrl-/:change-preview-window(down,50%|hidden|)' "$@"
}
```

Defining shortcut commands
--------------------------

Each binding is backed by `fzf_git_*` function so you can do something like
this in your shell configuration file.

```sh
gco() {
  fzf_git_each_ref --no-multi | xargs git checkout
}

gswt() {
  cd "$(fzf_git_worktrees --no-multi)"
}
```

Environment Variables
---------------------

| Variable                | Description                                              | Default                                         |
| ----------------------- | -------------------------------------------------------- | ----------------------------------------------- |
| `BAT_STYLE`             | Specifies the style for displaying files using `bat`     | `full`                                          |
| `FZF_GIT_CAT`           | Defines the preview command used for displaying the file | `bat --style=$BAT_STYLE --color=$FZF_GIT_COLOR` |
| `FZF_GIT_COLOR`         | Set to `never` to suppress colors in the list            | `always`                                        |
| `FZF_GIT_PAGER`         | Specifies the pager command for the preview window       | `$(git config --get core.pager)`                |
| `FZF_GIT_PREVIEW_COLOR` | Set to `never` to suppress colors in the preview window  | `always`                                        |
