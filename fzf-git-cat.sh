# fzf-git-cat.sh: WIP

if [ -n "$_fzf_git_cat_included" ]; then
    return;
fi
readonly _fzf_git_cat_included=x

function _include {
  local -r _dir="$(dirname "${BASH_SOURCE[0]}")"
  source "$_dir/fzf-git-color.sh"
}
_include
unset -f _include

# Determine the command to use for displaying file contents in git previews.
__fzf_git_cat() {
  if [[ -n $FZF_GIT_CAT ]]; then
    echo "$FZF_GIT_CAT"
    return
  fi

  declare -r _fzf_git_bat_options="--style='${BAT_STYLE:-full}' --color=$(__fzf_git_color .) --pager=never"
  if command -v bat > /dev/null; then
    echo "bat $_fzf_git_bat_options"
  else
    echo cat
  fi
}
export -f __fzf_git_cat
