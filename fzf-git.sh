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

__fzf_git_init() {
  unset -f __fzf_git_init

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

  local -r fzf_git_dir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}" ||
    echo "${BASH_SOURCE[0]}")")"
  source "$fzf_git_dir/branches.sh"
  source "$fzf_git_dir/each-ref.sh"
  source "$fzf_git_dir/files.sh"
  source "$fzf_git_dir/hashes.sh"
  source "$fzf_git_dir/reflog.sh"
  source "$fzf_git_dir/remotes.sh"
  source "$fzf_git_dir/stashes.sh"
  source "$fzf_git_dir/tags.sh"
  source "$fzf_git_dir/worktree.sh"
}

[[ $- =~ i ]] && __fzf_git_init "$@"
