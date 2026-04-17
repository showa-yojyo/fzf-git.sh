# fzf-git-branches.sh: WIP

if [ -n "$_fzf_git_branches_included" ]; then
    return;
fi
readonly _fzf_git_branches_included=x

function _fzf_git-list-branches {
    git branch "$@" --sort=-committerdate --sort=-HEAD --format=$'%(HEAD) %(color:yellow)%(refname:short) %(color:green)(%(committerdate:relative))\t%(color:blue)%(subject)%(color:reset)' --color=$(__fzf_git_color) |
        column -ts$'\t'
}

function _fzf_git-list-branches-all {
    echo 'CTRL-O (open in browser) ╱ ALT-ENTER (accept without remote)'
    echo 'ALT-H (list commit hashes)'
    _fzf_git-list-branches -a
}
