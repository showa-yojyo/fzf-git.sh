# fzf-git-hashes.sh: WIP

function _fzf_git-list-hashes {
    git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --graph --color=$(__fzf_git_color) "$@" $LIST_OPTS
}

function _fzf-git-list-hashes-all {
    echo 'CTRL-O (open in browser) ╱ CTRL-D (diff)'
    echo 'CTRL-S (toggle sort) ╱ ALT-F (list files)'
    list-git-hashes --all
}
