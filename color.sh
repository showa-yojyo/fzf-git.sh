# color.sh: WIP

if [ -n "$_fzf_git_color_included" ]; then
    return;
fi
readonly _fzf_git_color_included=x

# Determine the color mode for git previews.
__fzf_git_color() {
  if [[ -n $NO_COLOR ]]; then
    echo never
  elif [[ $# -gt 0 ]] && [[ -n $FZF_GIT_PREVIEW_COLOR ]]; then
    echo "$FZF_GIT_PREVIEW_COLOR"
  else
    echo "${FZF_GIT_COLOR:-always}"
  fi
}
export -f __fzf_git_color
