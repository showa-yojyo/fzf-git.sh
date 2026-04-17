# fzf-git-hashes.sh: WIP

if [ -n "$_fzf_git_hashes_included" ]; then
    return;
fi
readonly _fzf_git_hashes_included=x


function _fzf_git-list-hashes {
    git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --graph --color=$(__fzf_git_color) "$@" $LIST_OPTS
}

function _fzf-git-list-hashes-all {
    echo 'CTRL-O (open in browser) ╱ CTRL-D (diff)'
    echo 'CTRL-S (toggle sort) ╱ ALT-F (list files)'
    _fzf_git-list-hashes --all
}
