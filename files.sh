# fzf-git-files.sh: WIP

if [ -n "$_fzf_git_files_included" ]; then
    return;
fi
readonly _fzf_git_files_included=x

function _include {
  local -r _dir="$(dirname "${BASH_SOURCE[0]}")"
  source "$_dir/cat.sh"
  source "$_dir/check.sh"
  source "$_dir/color.sh"
  source "$_dir/functions.sh"
  source "$_dir/pager.sh"
}
_include
unset -f _include

_fzf_git_files() {
  _fzf_git_check || return
  local root query extract_file_name
  root=$(git rev-parse --show-toplevel)
  [[ -n "$(git rev-parse --show-prefix)" ]] && query='!../ '

  read -r -d "" extract_file_name <<'EOF'
"$(cut -c4- <<< {} | sed 's/.* -> //;s/^"//;s/"$//;s/\\"/"/g')"
EOF

  (
    git -c core.quotePath=false -c color.status=$(__fzf_git_color) status --short --no-branch --untracked-files=all
    git -c core.quotePath=false ls-files "$root" | grep -vxFf <(
      git -c core.quotePath=false status --short --untracked-files=no |
        cut -c4- | sed -e 's/.* -> //' -e '/^"[^"\\]*"$/ { s/^"//;s/"$//; }'
      echo :
    ) | sed 's/^/   /'
  ) |
    _fzf_git_fzf -m --ansi --nth 2..,.. \
      --border-label '📁 Files ' \
      --header 'CTRL-O (open in browser) ╱ ALT-E (open in editor)' \
      --bind "ctrl-o:execute-silent(navigate_github_from_file $extract_file_name)" \
      --bind "alt-e:execute:${EDITOR:-vim} $extract_file_name" \
      --query "$query" \
      --preview "git -c core.quotePath=false diff --no-ext-diff --color=$(__fzf_git_color .) -- $extract_file_name | $(__fzf_git_pager); $(__fzf_git_cat) $extract_file_name" "$@" |
    cut -c4- | sed 's/.* -> //'
}
