# fzf-git-reflog.sh: WIP

if [ -n "$_fzf_git_reflog_included" ]; then
    return;
fi
readonly _fzf_git_reflog_included=x

# TODO: rename
_fzf_git_lreflogs() {
  _fzf_git_check || return
  git reflog --color=$(__fzf_git_color) --format="%C(blue)%gD %C(yellow)%h%C(auto)%d %gs" |
    _fzf_git_fzf --ansi \
      --border-label '📒 Reflogs ' \
      --bind 'alt-r:toggle-raw' \
      --header "ALT-R (toggle raw mode)" \
      --preview "git show --color=$(__fzf_git_color .) {1} |
        $(__fzf_git_pager)" "$@" |
          awk '{print $1}'
}
