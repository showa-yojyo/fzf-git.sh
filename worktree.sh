# MIT License
#
# Copyright (c) 2024 Junegunn Choi
# Copyright (c) 2026 プレハブ小屋
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

if [ -n "$_fzf_git_worktree_included" ]; then
    return;
fi
readonly _fzf_git_worktree_included=x

function _include {
  local -r _dir="$(dirname "${BASH_SOURCE[0]}")"
  source "$_dir/check.sh"
  source "$_dir/color.sh"
}
_include
unset -f _include

function fzf_git_worktrees {
    _fzf_git_check || return
    git worktree list | fzf_git_fzf \
      --border-label '🌴 Worktrees ' \
      --header 'CTRL-X (remove worktree)' \
      --bind 'ctrl-x:reload(git worktree remove {1} > /dev/null; git worktree list)' \
      --preview "
        git -c color.status=$(__fzf_git_color .) -C {1} status --short --branch
        echo
        git log --oneline --graph --date=short --color=$(__fzf_git_color .) --pretty='format:%C(auto)%cd %h%d %s' {2} --
      " "$@" |
    awk '{print $1}'
}
