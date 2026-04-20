# fzf-git-each-ref.sh: WIP

if [ -n "$_fzf_git_each_ref_included" ]; then
    return;
fi
readonly _fzf_git_each_ref_included=x

function _include {
  local -r _dir="$(dirname "${BASH_SOURCE[0]}")"
  source "$_dir/fzf-git-check.sh"
  source "$_dir/fzf-git-color.sh"
  source "$_dir/fzf-git-functions.sh"
}
_include
unset -f _include

function _fzf_git-list-refs {
    git for-each-ref "$@" --sort=-creatordate --sort=-HEAD --color=$(__fzf_git_color) --format=$'%(if:equals=refs/remotes)%(refname:rstrip=-2)%(then)%(color:magenta)remote-branch%(else)%(if:equals=refs/heads)%(refname:rstrip=-2)%(then)%(color:brightgreen)branch%(else)%(if:equals=refs/tags)%(refname:rstrip=-2)%(then)%(color:brightcyan)tag%(else)%(if:equals=refs/stash)%(refname:rstrip=-2)%(then)%(color:brightred)stash%(else)%(color:white)%(refname:rstrip=-2)%(end)%(end)%(end)%(end)\t%(color:yellow)%(refname:short) %(color:green)(%(creatordate:relative))\t%(color:blue)%(subject)%(color:reset)' |
        column -ts$'\t'
}

function _fzf_git-list-refs-all {
    echo 'CTRL-O (open in browser) ╱ ALT-E (examine in editor) ╱ ALT-ENTER (accept without remote)'
    _fzf_git-list-refs
}
export -f _fzf_git-list-refs _fzf_git-list-refs-all

_fzf_git_each_ref() {
    _fzf_git_check || return

    (
      echo 'CTRL-O (open in browser) ╱ ALT-E (examine in editor) ╱ ALT-A (show all refs)'
      _fzf_git-list-refs --exclude='refs/remotes'
    ) |
    _fzf_git_fzf --ansi \
    --nth 2,2.. \
    --tiebreak begin \
    --border-label '☘️  Each ref ' \
    --header-lines 1 \
    --preview-window down,border-top,40% \
    --color hl:underline,hl+:underline \
    --no-hscroll \
    --bind 'ctrl-/:change-preview-window(down,70%|hidden|)' \
    --bind "ctrl-o:execute-silent(navigate_github_each_ref {1} {2})" \
    --bind "alt-e:execute:${EDITOR:-vim} <(git show {2}) < /dev/tty > /dev/tty" \
    --bind "alt-a:change-border-label(🍀 Every ref)+reload(_fzf_git-list-refs-all)" \
    --bind "alt-enter:become:printf '%s\n' {+2} | sed 's@[^/]*/@@'" \
    --preview "git log --oneline --graph --date=short --color=$(__fzf_git_color .) --pretty='format:%C(auto)%cd %h%d %s' {2} --" \
    --accept-nth 2 \
    "$@"
}
