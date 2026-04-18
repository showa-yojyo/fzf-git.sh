# fzf-git-hashes.sh: WIP

if [ -n "$_fzf_git_hashes_included" ]; then
    return;
fi
readonly _fzf_git_hashes_included=x

function _fzf_git-list-hashes {
    git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --graph --color=$(__fzf_git_color) "$@" $LIST_OPTS
}

function _fzf-git-list-hashes-all {
    echo 'CTRL-O (open in browser) ╱ CTRL-D (diff)'
    echo 'CTRL-S (toggle sort) ╱ ALT-F (list files)'
    _fzf_git-list-hashes --all
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
