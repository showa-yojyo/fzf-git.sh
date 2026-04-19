# The MIT License (MIT)
#
# Copyright (c) 2024 Junegunn Choi
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# shellcheck disable=SC2039
[[ $0 == - ]] && return

__fzf_git_cat() {
  if [[ -n $FZF_GIT_CAT ]]; then
    echo "$FZF_GIT_CAT"
    return
  fi

  # Sometimes bat is installed as batcat
  _fzf_git_bat_options="--style='${BAT_STYLE:-full}' --color=$(__fzf_git_color .) --pager=never"
  if command -v batcat > /dev/null; then
    echo "batcat $_fzf_git_bat_options"
  elif command -v bat > /dev/null; then
    echo "bat $_fzf_git_bat_options"
  else
    echo cat
  fi
}
export -f __fzf_git_cat

__fzf_git_pager() {
  local pager
  pager="${FZF_GIT_PAGER:-${GIT_PAGER:-$(git config --get core.pager 2> /dev/null)}}"
  echo "${pager:-cat}"
}
export -f __fzf_git_pager

if [[ $- =~ i ]]; then
  if [[ $__fzf_git_fzf ]]; then
    eval "$__fzf_git_fzf"
  else
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
    export -f _fzf_git_fzf
  fi

  __fzf_git=$(readlink -f "${BASH_SOURCE[0]}" 2> /dev/null || /usr/bin/ruby --disable-gems -e 'puts File.expand_path(ARGV.first)' "$__fzf_git" 2> /dev/null)

  set -a
  fzf_git_dir="$(dirname "$__fzf_git")"
  source "$fzf_git_dir/fzf-git-check.sh"
  source "$fzf_git_dir/fzf-git-branches.sh"
  source "$fzf_git_dir/fzf-git-hashes.sh"
  source "$fzf_git_dir/fzf-git-refs.sh"
  source "$fzf_git_dir/fzf-git-functions.sh"
  source "$fzf_git_dir/fzf-git-files.sh"
  source "$fzf_git_dir/fzf-git-tree.sh"
  source "$fzf_git_dir/fzf-git-tags.sh"
  source "$fzf_git_dir/fzf-git-reflog.sh"
  source "$fzf_git_dir/fzf-git-remotes.sh"
  source "$fzf_git_dir/fzf-git-stashes.sh"
  source "$fzf_git_dir/fzf-git-each-ref.sh"
  source "$fzf_git_dir/fzf-git-worktree.sh"
  set +a

  __fzf_git_init() {
    bind -m emacs-standard '"\er":  redraw-current-line'
    bind -m emacs-standard '"\C-z": vi-editing-mode'
    bind -m vi-command     '"\C-z": emacs-editing-mode'
    bind -m vi-insert      '"\C-z": emacs-editing-mode'

    local o c
    for o in "$@"; do
      c=${o:0:1}
      bind -m emacs-standard '"\C-xg'$c'": " \C-u \C-a\C-k`_fzf_git_'$o'`\e\C-e\C-y\C-a\C-y\ey\C-h\C-e\er \C-h"'
      bind -m vi-command     '"\C-xg'$c'": "\C-z\C-g'$c'\C-z"'
      bind -m vi-insert      '"\C-xg'$c'": "\C-z\C-g'$c'\C-z"'
    done
  }
  __fzf_git_init files branches tags remotes hashes stashes lreflogs each_ref worktrees
fi
