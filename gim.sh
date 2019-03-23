#!/bin/bash

usage() {
    echo "        feature: crea un branch feature"
    echo "        hotfix: crea un branch di hotfix"
    echo "        bugfix: crea un branch di bugfix"
    echo "        release: crea un branch di release"
    echo "        commit: committa tutte le modifiche"
    echo "        finish: mergia ed elimina il branch"
    echo "        published: pusha il branch in remoto"
    echo "        delete: elimina branch corrente"
    echo "        deleteRemoteBranch: tool pulizia branch remoti"
    echo "        deleteLocalBranch: tool pulizia branch locali"
    exit
}
if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]  || [[ -z "$1" ]]; then
    usage
fi
actualBranch=$(git branch | grep \* | cut -d ' ' -f2)
actualBranchType=$(git branch | grep \* | cut -d ' ' -f2 | cut -d '/' -f1)
branchName=$(git branch | grep \* | cut -d ' ' -f2 | cut -d '/' -f2)

major=$(git describe --tags `git rev-list --tags --max-count=1` | cut -d '.' -f1)
major="${major//v/}"
minor=$(git describe --tags `git rev-list --tags --max-count=1` | cut -d '.' -f2)
patch=$(git describe --tags `git rev-list --tags --max-count=1` | cut -d '.' -f3)

if [[ -z "$major" ]]; then
    major=1
fi
if [[ -z "$minor" ]]; then
    minor=0
fi
if [[ -z "$patch" ]]; then
    patch=0
fi

prev=""
consoleTaskId="0"
releaseMajor="0"
pullRequest="0"

if [[ "$1" == "init" ]]; then
    git flow init -d
fi

for var in "$@"
do
    if [[ "$prev" == "-t" ]]; then
        consoleTaskId="$var"
    fi
    if [[ "$var" == "-m" ]]; then
        releaseMajor="1"
    fi
    prev="$var"
done
# create feature or hotfix branch
if [[ "$1" == "feature" ]] || [[ "$1" == "bugfix" ]]; then
    newBranch=$(gim-get-granch-name "$consoleTaskId")
    git flow "$1" start "$newBranch"
fi

if [[ "$1" == "hotfix" ]]
then
    git flow "$1" start "v$major"."$minor"."$((patch + 1))"
fi

if [[ "$1" == "release" ]]
then
    releaseName="v$major"."$((minor +1))".0
    if [[ "$releaseMajor" == "1" ]]; then
        releaseName="v$((major + 1))".0.0
    fi
    git flow release start "$releaseName"
fi

if [[ "$1" == "finish" ]] || [[ "$1" == "publish" ]]; then
    git flow "$actualBranchType" "$1" "$branchName"
fi

if [[ "$1" == "delete" ]]; then
    git flow delete
fi

# menage commit
if [[ "$1" == "commit" ]]; then
    gim-commit "$actualBranchType" "$branchName"
fi

# menage delete remote branch
if [[ "$1" == "deleteRemoteBranch" ]]; then
    gim-delete-remote-branch
fi

# menage delete local branch
if [[ "$1" == "deleteLocalBranch" ]]; then
    delete-local-branch
fi