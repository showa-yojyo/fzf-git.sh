# fzf-git-pager.sh: WIP

if [ -n "$_fzf_git_pager_included" ]; then
    return;
fi
readonly _fzf_git_pager_included=x

# Determine the pager command to use for git previews.
__fzf_git_pager() {
  local pager="${FZF_GIT_PAGER:-${GIT_PAGER:-$(git config --get core.pager 2> /dev/null)}}"
  echo "${pager:-cat}"
}
export -f __fzf_git_pager
