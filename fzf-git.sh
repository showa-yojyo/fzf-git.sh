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

__fzf_git_color() {
  if [[ -n $NO_COLOR ]]; then
    echo never
  elif [[ $# -gt 0 ]] && [[ -n $FZF_GIT_PREVIEW_COLOR ]]; then
    echo "$FZF_GIT_PREVIEW_COLOR"
  else
    echo "${FZF_GIT_COLOR:-always}"
  fi
}
export -f __fzf_git_color

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

__fzf_git_pager() {
  local pager
  pager="${FZF_GIT_PAGER:-${GIT_PAGER:-$(git config --get core.pager 2> /dev/null)}}"
  echo "${pager:-cat}"
}

if [[ $- =~ i ]] || [[ $1 = --run ]]; then # ----------------------------------
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
  fi

  _fzf_git_check() {
    git rev-parse > /dev/null 2>&1 && return

    [[ -n $TMUX ]] && tmux display-message "Not in a git repository"
    return 1
  }

  __fzf_git=$(readlink -f "${BASH_SOURCE[0]}" 2> /dev/null || /usr/bin/ruby --disable-gems -e 'puts File.expand_path(ARGV.first)' "$__fzf_git" 2> /dev/null)

  # source ./fzf-git-functions.sh
  set -a
  fzf_git_dir="$(dirname "$__fzf_git")"
  source "$fzf_git_dir/fzf-git-branches.sh"
  source "$fzf_git_dir/fzf-git-hashes.sh"
  source "$fzf_git_dir/fzf-git-refs.sh"
  source "$fzf_git_dir/fzf-git-functions.sh"
  set +a

  _fzf_git_files() {
    _fzf_git_check || return
    local root query extract_file_name
    root=$(git rev-parse --show-toplevel)
    [[ -n "$(git rev-parse --show-prefix)" ]] && query='!../ '

    read -r -d "" extract_file_name <<'EOF'
"$(cut -c4- <<< {} | sed 's/.* -> //;s/^"//;s/"$//;s/\\"/"/g')"
EOF

    (
      git -c core.quotePath=false -c color.status=$(__fzf_git_color) status --short --no-branch --untracked-files=all
      git -c core.quotePath=false ls-files "$root" | grep -vxFf <(
        git -c core.quotePath=false status --short --untracked-files=no |
          cut -c4- | sed -e 's/.* -> //' -e '/^"[^"\\]*"$/ { s/^"//;s/"$//; }'
        echo :
      ) | sed 's/^/   /'
    ) |
      _fzf_git_fzf -m --ansi --nth 2..,.. \
        --border-label '📁 Files ' \
        --header 'CTRL-O (open in browser) ╱ ALT-E (open in editor)' \
        --bind "ctrl-o:execute-silent(navigate_github_from_file $extract_file_name)" \
        --bind "alt-e:execute:${EDITOR:-vim} $extract_file_name" \
        --query "$query" \
        --preview "git -c core.quotePath=false diff --no-ext-diff --color=$(__fzf_git_color .) -- $extract_file_name | $(__fzf_git_pager); $(__fzf_git_cat) $extract_file_name" "$@" |
      cut -c4- | sed 's/.* -> //'
  }

  _fzf_git_tree_files() {
    _fzf_git_check || return

    local treeish
    for treeish in "$@"; do
      git diff-tree --no-commit-id --name-only "$treeish" -r
    done | sort -u |
      _fzf_git_fzf -m \
        --border-label "📂 Files in $* " \
        --header 'CTRL-O (open in browser) ╱ ALT-E (open in editor)' \
        --bind "ctrl-o:execute-silent(navigate_github_from_file {})" \
        --bind "alt-e:execute:${EDITOR:-vim} {}" \
        --preview "git -c core.quotePath=false diff --no-ext-diff --color=$(__fzf_git_color .) -- {} | $(__fzf_git_pager); $(__fzf_git_cat) {}"
  }

  _fzf_git_branches() {
    _fzf_git_check || return

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
      --bind "alt-h:become:LIST_OPTS=\$(cut -c3- <<< {} | cut -d' ' -f1) bash \"$__fzf_git\" --run hashes" \
      --bind "alt-enter:become:printf '%s\n' {+} | cut -c3- | sed 's@[^/]*/@@'" \
      --preview "git log --oneline --graph --date=short --color=$(__fzf_git_color .) --pretty='format:%C(auto)%cd %h%d %s' \$(cut -c3- <<< {} | cut -d' ' -f1) --" "$@" |
    sed 's/^\* //' | awk '{print $1}' # Slightly modified to work with hashes as well
  }

  _fzf_git_tags() {
    _fzf_git_check || return
    git tag --sort -version:refname |
    _fzf_git_fzf --preview-window right,70% \
      --border-label '📛 Tags ' \
      --header 'CTRL-O (open in browser)' \
      --bind "ctrl-o:execute-silent(navigate_github_from_tag {})" \
      --bind 'alt-r:toggle-raw' \
      --preview "git show --color=$(__fzf_git_color .) {} | $(__fzf_git_pager)" "$@"
  }

  _fzf_git_hashes() {
    _fzf_git_check || return

    (
      echo 'CTRL-O (open in browser) ╱ CTRL-D (diff) ╱ CTRL-S (toggle sort)'
      echo 'ALT-R (toggle raw mode) ╱ ALT-F (list files) ╱ ALT-A (show all hashes)'
      _fzf_git-list-hashes
    ) |
    _fzf_git_fzf --ansi --no-sort --bind 'ctrl-s:toggle-sort,alt-r:toggle-raw' \
      --border-label '🍡 Hashes ' \
      --header-lines 2 \
      --bind "ctrl-o:execute-silent(navigate_github_from_commit {})" \
      --bind "ctrl-d:execute:grep -o '[a-f0-9]\{7,\}' <<< {} | head -n 1 | xargs git diff --color=$(__fzf_git_color) > /dev/tty" \
      --bind "alt-a:change-border-label(🍇 All hashes)+reload(_fzf_git-list-hashes-all)" \
      --bind "alt-f:become:echo ::tree_files;
        awk 'match(\$0, /[a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9]*/) { print substr(\$0, RSTART, RLENGTH) }' {+f} |
          xargs bash \"$__fzf_git\" --run tree_files" \
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

  _fzf_git_remotes() {
    _fzf_git_check || return
    git remote -v | awk '{print $1 "\t" $2}' | uniq |
    _fzf_git_fzf --tac \
      --border-label '📡 Remotes ' \
      --header 'CTRL-O (open in browser)' \
      --bind "ctrl-o:execute-silent(navigate_github_from_remote {})" \
      --preview-window right,70% \
      --preview "git log --oneline --graph --date=short --color=$(__fzf_git_color .) --pretty='format:%C(auto)%cd %h%d %s' '{1}/$(git rev-parse --abbrev-ref HEAD)' --" "$@" |
    cut -d$'\t' -f1
  }

  _fzf_git_stashes() {
    _fzf_git_check || return
    git stash list | _fzf_git_fzf \
      --border-label '🥡 Stashes ' \
      --header 'CTRL-X (drop stash)' \
      --bind 'ctrl-x:reload(git stash drop -q {1}; git stash list)' \
      -d: --preview "git show --first-parent --color=$(__fzf_git_color .) {1} | $(__fzf_git_pager)" "$@" |
    cut -d: -f1
  }

  _fzf_git_lreflogs() {
    _fzf_git_check || return
    git reflog --color=$(__fzf_git_color) --format="%C(blue)%gD %C(yellow)%h%C(auto)%d %gs" | _fzf_git_fzf --ansi \
      --border-label '📒 Reflogs ' \
      --bind 'alt-r:toggle-raw' \
      --preview "git show --color=$(__fzf_git_color .) {1} | $(__fzf_git_pager)" "$@" |
    awk '{print $1}'
  }

  _fzf_git_each_ref() {
    _fzf_git_check || return

    (
      echo 'CTRL-O (open in browser) ╱ ALT-E (examine in editor) ╱ ALT-A (show all refs)'
      _fzf_git-list-refs --exclude='refs/remotes'
    ) |
      _fzf_git_fzf --ansi \
      --nth 2,2.. \
      --tiebreak begin \
      --border-label '☘️  Each ref ' \
      --header-lines 1 \
      --preview-window down,border-top,40% \
      --color hl:underline,hl+:underline \
      --no-hscroll \
      --bind 'ctrl-/:change-preview-window(down,70%|hidden|)' \
      --bind "ctrl-o:execute-silent(navigate_github_each_ref {1} {2})" \
      --bind "alt-e:execute:${EDITOR:-vim} <(git show {2}) < /dev/tty > /dev/tty" \
      --bind "alt-a:change-border-label(🍀 Every ref)+reload(_fzf_git-list-refs-all)" \
      --bind "alt-enter:become:printf '%s\n' {+2} | sed 's@[^/]*/@@'" \
      --preview "git log --oneline --graph --date=short --color=$(__fzf_git_color .) --pretty='format:%C(auto)%cd %h%d %s' {2} --" \
      --accept-nth 2 \
      "$@"
  }

  _fzf_git_worktrees() {
    _fzf_git_check || return
    git worktree list | _fzf_git_fzf \
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

fi # --------------------------------------------------------------------------

if [[ $1 = --run ]]; then
  shift
  type=$1
  shift
  eval "_fzf_git_$type" "$@"

elif [[ $- =~ i ]]; then # ------------------------------------------------------
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

fi # --------------------------------------------------------------------------
