# check.sh: WIP

if [ -n "$_fzf_git_check_included" ]; then
    return;
fi
readonly _fzf_git_check_included=x

# Check if the current directory is a git repository.
_fzf_git_check() {
  git rev-parse > /dev/null 2>&1 && return

  [[ -n $TMUX ]] && tmux display-message "Not in a git repository"
  return 1
}
export -f _fzf_git_check
