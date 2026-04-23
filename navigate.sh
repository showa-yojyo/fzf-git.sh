# MIT License
#
# Copyright (c) 2024 Junegunn Choi
# Copyright (c) 2026 プレハブ小屋
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

if [ -n "$_fzf_git_navigate_included" ]; then
    return;
fi
readonly _fzf_git_navigate_included=x

# XXX: This file is for functions that are shared across multiple .sh files. It
# is not intended to be sourced directly.
set -a

# Return e.g. "https://github.com/USER/REPO" from branch
function navigate_github {
    local OPTIND r o
    while getopts ":b:r:" o; do
        case "$o" in
            b)
                r=$(git config "branch.${OPTARG}.remote" || echo origin)
                break
                ;;
            r)
                r="${OPTARG}"
                break
                ;;
        esac
    done
    shift $((OPTIND-1))

    if [[ -z $r ]]; then
        r=$(git config "branch.$(git branch --show-current).remote" || echo origin)
    fi

    local -r remote_url=$(git remote get-url $r)

    case "$remote_url" in
      git@*)
        # Remove "git@" and ".git"
        local -r output=${remote_url:4:-4}
        # Remove the colon
        echo https://${output/://}
      ;;
      https*)
        echo ${remote_url%.git}
      ;;
    esac
}

# fzf-git.sh::branch|remote-branch
function navigate_github_from_branch {
    local -r branch=$(sed 's/^[* ]*//' <<< "$1" | cut -d' ' -f1)
    local -r github_url=$(navigate_github -b $branch)
    wslview "${github_url}/tree/${branch}"
}

# fzf-git.sh::commit
function navigate_github_from_commit {
    local -r sha=$(grep -o "[a-f0-9]\{7,\}" <<< "$1" | head -n 1)
    local -r github_url=$(navigate_github)
    wslview "${github_url}/commit/$sha"
}

# fzf-git.sh::each_ref
function navigate_github_each_ref {
    case "$1" in
      branch|remote-branch)
        navigate_github_from_branch $2
        ;;
      remote)
        navigate_github_from_remote $2
        ;;
      tag)
        navigate_github_from_tag $2
        ;;
      *)
        # exit 1
        ;;
    esac
}

# fzf-git.sh::file
function navigate_github_from_file {
    local -r file=$1
    local -r branch=$(git branch --show-current)
    local -r github_url=$(navigate_github -b $branch)
    wslview "${github_url}/blob/${branch}/$(git rev-parse --show-prefix)${file}"
}

# fzf-git.sh::remote
function navigate_github_from_remote {
    local -r remote=$1
    local -r branch=$(git branch --show-current)
    local -r github_url=$(navigate_github -b $branch)
    wslview "${github_url}/tree/${branch}"
}

# fzf-git.sh::tag
function navigate_github_from_tag {
    local -r tag="$1"
    local -r github_url=$(navigate_github)
    wslview "${github_url}/releases/tag/${tag}"
}

# XXX: See above.
set +a
