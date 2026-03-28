fzf-git.sh
==========

bash, zsh, and fish key bindings for Git objects, powered by [fzf].

<img width="1680" alt="image" src="https://user-images.githubusercontent.com/700826/185568470-20d70937-eea4-4274-aec5-14dfe7ee2de6.png">

Each binding will allow you to browse through Git objects of a certain type,
and select the objects you want to paste to your command-line.

[fzf]: https://github.com/junegunn/fzf

Installation
------------

* Install the latest version of [fzf]
    * (Optional) Install [bat](https://github.com/sharkdp/bat) for
      syntax-highlighted file previews
    * Git v2.42.0 or later is required for the `git for-each-ref` binding
* Update your shell configuration file
    * bash or zsh
        * Source [fzf-git.sh](https://raw.githubusercontent.com/junegunn/fzf-git.sh/main/fzf-git.sh) file from your .bashrc or .zshrc
    * fish
        * Source [fzf-git.fish](https://raw.githubusercontent.com/junegunn/fzf-git.sh/main/fzf-git.fish) from your config.fish

Usage
-----

### List of bindings

| Key Stroke | Command |
|------------|---------|
| <kbd>C-x g ?</kbd> | Show this list |
| <kbd>C-x g f</kbd> | **F**iles |
| <kbd>C-x g b</kbd> | **B**ranches |
| <kbd>C-x g t</kbd> | **T**ags |
| <kbd>C-x g r</kbd> | **R**emotes |
| <kbd>C-x g h</kbd> | commit **H**ashes |
| <kbd>C-x g s</kbd> | **S**tashes |
| <kbd>C-x g l</kbd> | ref**l**ogs |
| <kbd>C-x g w</kbd> | **W**orktrees |
| <kbd>C-x g e</kbd> | **E**ach ref (`git for-each-ref`) |

> [!WARNING]
> If zsh's `KEYTIMEOUT` is too small (e.g. 1), you may not be able
> to hit two keys in time.

### Inside fzf

* <kbd>TAB</kbd> or <kbd>SHIFT-TAB</kbd> to select multiple objects
* <kbd>CTRL-/</kbd> to change preview window layout
* <kbd>CTRL-O</kbd> to open the object in the web browser (in GitHub URL scheme)

Customization
-------------

```sh
# Redefine this function to change the options
_fzf_git_fzf() {
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

Each binding is backed by `_fzf_git_*` function so you can do something like
this in your shell configuration file.

```sh
gco() {
  _fzf_git_each_ref --no-multi | xargs git checkout
}

gswt() {
  cd "$(_fzf_git_worktrees --no-multi)"
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
