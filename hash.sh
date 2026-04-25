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

if [ -n "$_fzf_git_hash_included" ]; then
    return;
fi
readonly _fzf_git_hash_included=x

function _include {
  local -r _dir="$(dirname "${BASH_SOURCE[0]}")"
  source "$_dir/cat.sh"
  source "$_dir/check.sh"
  source "$_dir/color.sh"
  source "$_dir/navigate.sh"
  source "$_dir/pager.sh"
}
_include
unset -f _include

function _fzf_git-list-hashes {
    git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --graph --color=$(__fzf_git_color) "$@" $LIST_OPTS
}
export -f _fzf_git-list-hashes

function _fzf-git-list-hashes-all {
    echo 'CTRL-O (open in browser) ╱ CTRL-D (diff)'
    echo 'CTRL-S (toggle sort) ╱ ALT-F (list files)'
    _fzf_git-list-hashes --all
}
export -f _fzf-git-list-hashes-all

function _fzf_git_tree_files {
  _fzf_git_check || return

  local treeish
  for treeish in "$@"; do
    git diff-tree --no-commit-id --name-only "$treeish" -r
  done | sort -u |
    fzf_git_fzf -m \
      --border-label "📂 Files in $* " \
      --header 'CTRL-O (open in browser) ╱ ALT-E (open in editor)' \
      --bind "ctrl-o:execute-silent(navigate_github_from_file {})" \
      --bind "alt-e:execute:${EDITOR:-vim} {}" \
      --preview "git -c core.quotePath=false diff --no-ext-diff --color=$(__fzf_git_color .) -- {} | $(__fzf_git_pager); $(__fzf_git_cat) {}"
}
export -f _fzf_git_tree_files

function fzf_git_hash {
  _fzf_git_check || return

  (
    echo 'CTRL-O (open in browser) ╱ CTRL-D (diff) ╱ CTRL-S (toggle sort)'
    echo 'ALT-R (toggle raw mode) ╱ ALT-F (list files) ╱ ALT-A (show all hashes)'
    _fzf_git-list-hashes
  ) |
  fzf_git_fzf --ansi --no-sort --bind 'ctrl-s:toggle-sort,alt-r:toggle-raw' \
    --border-label '🍡 Hashes ' \
    --header-lines 2 \
    --bind "ctrl-o:execute-silent(navigate_github_from_commit {})" \
    --bind "ctrl-d:execute:grep -o '[a-f0-9]\{7,\}' <<< {} | head -n 1 | xargs git diff --color=$(__fzf_git_color) > /dev/tty" \
    --bind "alt-a:change-border-label(🍇 All hashes)+reload(_fzf_git-list-hashes-all)" \
    --bind "alt-f:become:echo ::tree_files;
      awk 'match(\$0, /[a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9]*/) {
        print substr(\$0, RSTART, RLENGTH)
      }' {+f} |
        xargs -n1 -I @@@ bash -c '_fzf_git_tree_files @@@'" \
    --color hl:underline,hl+:underline \
    --preview "grep -o '[a-f0-9]\{7,\}' <<< {} | head -n 1 | xargs git show --color=$(__fzf_git_color .) | $(__fzf_git_pager)" "$@" |
      awk '
        NR==1 && $0=="::tree_files" {
          mode="tree_files"
          next
        }
        mode=="tree_files" {
          print
          next
        }
        match($0, /[a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9]*/) {
          print substr($0, RSTART, RLENGTH)
        }
      '
}
export -f fzf_git_hash
