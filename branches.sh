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

if [ -n "$_fzf_git_branches_included" ]; then
    return;
fi
readonly _fzf_git_branches_included=x

function _include {
  local -r _dir="$(dirname "${BASH_SOURCE[0]}")"
  source "$_dir/color.sh"
  source "$_dir/check.sh"
  source "$_dir/navigate.sh"
}
_include
unset -f _include

function _fzf_git-list-branches {
    git branch "$@" --sort=-committerdate --sort=-HEAD --format=$'%(HEAD) %(color:yellow)%(refname:short) %(color:green)(%(committerdate:relative))\t%(color:blue)%(subject)%(color:reset)' --color=$(__fzf_git_color) |
        column -ts$'\t'
}
export -f _fzf_git-list-branches

function _fzf_git-list-branches-all {
    echo 'CTRL-O (open in browser) ╱ ALT-ENTER (accept without remote)'
    echo 'ALT-H (list commit hashes)'
    _fzf_git-list-branches -a
}
export -f _fzf_git-list-branches-all

_fzf_git_branches() {
  _fzf_git_check || return

  # Note:
  # cut -c3- ...: to extract the branch name without the leading "* " or "  "
  # (two spaces).
  (
    echo 'CTRL-O (open in browser) ╱ ALT-A (show all branches)'
    echo 'ALT-H (list commit hashes)'
    _fzf_git-list-branches
  ) |
  __fzf_git_fzf=$(declare -f _fzf_git_fzf) _fzf_git_fzf --ansi \
    --border-label '🌲 Branches ' \
    --header-lines 2 \
    --tiebreak begin \
    --preview-window down,border-top,40% \
    --color hl:underline,hl+:underline \
    --no-hscroll \
    --bind 'ctrl-/:change-preview-window(down,70%|hidden|)' \
    --bind "ctrl-o:execute-silent(navigate_github_from_branch {})" \
    --bind "alt-a:change-border-label(🌳 All branches)+reload(_fzf_git-list-branches-all)" \
    --bind "alt-h:become:LIST_OPTS=\$(cut -c3- <<< {} | cut -d' ' -f1) _fzf_git_hashes" \
    --bind "alt-enter:become:printf '%s\n' {+} | cut -c3- | sed 's@[^/]*/@@'" \
    --preview "git log --oneline --graph --date=short --color=$(__fzf_git_color .) --pretty='format:%C(auto)%cd %h%d %s' \$(cut -c3- <<< {} | cut -d' ' -f1) --" "$@" |
      sed 's/^\* //' | awk '{print $1}' # Slightly modified to work with hashes as well
}
