# tags.sh: WIP

if [ -n "$_fzf_git_tags_included" ]; then
    return;
fi
readonly _fzf_git_tags_included=x

function _include {
  local -r _dir="$(dirname "${BASH_SOURCE[0]}")"
  source "$_dir/check.sh"
  source "$_dir/color.sh"
  source "$_dir/navigate.sh"
  source "$_dir/pager.sh"
}
_include
unset -f _include

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
