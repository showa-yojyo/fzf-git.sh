# fzf-git-refs.sh: WIP

if [ -n "$_fzf_git_refs_included" ]; then
    return;
fi
readonly _fzf_git_refs_included=x

source "$(dirname "${BASH_SOURCE[0]}")/fzf-git-color.sh"

function _fzf_git-list-refs {
    git for-each-ref "$@" --sort=-creatordate --sort=-HEAD --color=$(__fzf_git_color) --format=$'%(if:equals=refs/remotes)%(refname:rstrip=-2)%(then)%(color:magenta)remote-branch%(else)%(if:equals=refs/heads)%(refname:rstrip=-2)%(then)%(color:brightgreen)branch%(else)%(if:equals=refs/tags)%(refname:rstrip=-2)%(then)%(color:brightcyan)tag%(else)%(if:equals=refs/stash)%(refname:rstrip=-2)%(then)%(color:brightred)stash%(else)%(color:white)%(refname:rstrip=-2)%(end)%(end)%(end)%(end)\t%(color:yellow)%(refname:short) %(color:green)(%(creatordate:relative))\t%(color:blue)%(subject)%(color:reset)' |
        column -ts$'\t'
}

function _fzf_git-list-refs-all {
    echo 'CTRL-O (open in browser) ╱ ALT-E (examine in editor) ╱ ALT-ENTER (accept without remote)'
    _fzf_git-list-refs
}
