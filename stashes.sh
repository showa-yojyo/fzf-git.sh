# stashes.sh: WIP

if [ -n "$_fzf_git_stashes_included" ]; then
    return;
fi
readonly _fzf_git_stashes_included=x

function _include {
  local -r _dir="$(dirname "${BASH_SOURCE[0]}")"
  source "$_dir/check.sh"
  source "$_dir/color.sh"
  source "$_dir/pager.sh"
}
_include
unset -f _include

_fzf_git_stashes() {
  _fzf_git_check || return
  git stash list | _fzf_git_fzf \
    --border-label '🥡 Stashes ' \
    --header 'CTRL-X (drop stash)' \
    --bind 'ctrl-x:reload(git stash drop -q {1}; git stash list)' \
    -d: --preview "git show --first-parent --color=$(__fzf_git_color .) {1} | $(__fzf_git_pager)" "$@" |
  cut -d: -f1
}
