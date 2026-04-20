# fzf-git-worktree.sh: WIP

if [ -n "$_fzf_git_worktree_included" ]; then
    return;
fi
readonly _fzf_git_worktree_included=x

_dir="$(dirname "${BASH_SOURCE[0]}")"
source "$_dir/fzf-git-check.sh"
source "$_dir/fzf-git-color.sh"
unset _dir

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
