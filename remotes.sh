# fzf-git-remotes.sh: WIP

if [ -n "$_fzf_git_remotes_included" ]; then
    return;
fi
readonly _fzf_git_remotes_included=x

function _include {
  local -r _dir="$(dirname "${BASH_SOURCE[0]}")"
  source "$_dir/check.sh"
  source "$_dir/color.sh"
  source "$_dir/functions.sh"
}
_include
unset -f _include

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
