# fzf-git-branches.sh: WIP

if [ -n "$_fzf_git_branches_included" ]; then
    return;
fi
readonly _fzf_git_branches_included=x

source "$(dirname "${BASH_SOURCE[0]}")/fzf-git-color.sh"

function _fzf_git-list-branches {
    git branch "$@" --sort=-committerdate --sort=-HEAD --format=$'%(HEAD) %(color:yellow)%(refname:short) %(color:green)(%(committerdate:relative))\t%(color:blue)%(subject)%(color:reset)' --color=$(__fzf_git_color) |
        column -ts$'\t'
}

function _fzf_git-list-branches-all {
    echo 'CTRL-O (open in browser) ╱ ALT-ENTER (accept without remote)'
    echo 'ALT-H (list commit hashes)'
    _fzf_git-list-branches -a
}

_fzf_git_branches() {
  _fzf_git_check || return

  # Note:
  # cut -c3- ...: to extract the branch name without the leading "* " or "  "
  # (two spaces).
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
    --bind "alt-h:become:LIST_OPTS=\$(cut -c3- <<< {} | cut -d' ' -f1) _fzf_git_hashes" \
    --bind "alt-enter:become:printf '%s\n' {+} | cut -c3- | sed 's@[^/]*/@@'" \
    --preview "git log --oneline --graph --date=short --color=$(__fzf_git_color .) --pretty='format:%C(auto)%cd %h%d %s' \$(cut -c3- <<< {} | cut -d' ' -f1) --" "$@" |
      sed 's/^\* //' | awk '{print $1}' # Slightly modified to work with hashes as well
}
