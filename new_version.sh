#!/bin/bash

newVersion=$2

# Get the last branch
lastGitBranch=$1

#  Checkout it
git checkout $lastGitBranch

rm -rf cli/js/*
wget -P cli/js/ "https://raw.githubusercontent.com/denoland/deno/v${newVersion}/cli/js/lib.deno.ns.d.ts"
wget -P cli/js/ "https://raw.githubusercontent.com/denoland/deno/v${newVersion}/cli/js/lib.deno.shared_globals.d.ts"
wget -P cli/js/ "https://raw.githubusercontent.com/denoland/deno/v${newVersion}/cli/js/lib.deno.window.d.ts"
wget -P cli/js/ "https://raw.githubusercontent.com/denoland/deno/v${newVersion}/cli/js/lib.deno.worker.d.ts"

# Create and checkout a new branch
git checkout -b $newVersion

# Add modified files to commit
git add cli/js

# Commit
git commit -m "deno version ${newVersion}"

## Save the stats
diffStat=`git --no-pager diff HEAD~1 --shortstat`

# Print diff
git --no-pager diff HEAD~1

# Print all branches (inspired from the oh-my-zsh shortcut: "glola")
git --no-pager log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --all

# Ask for confirmation before pushing
echo -e "\nIs that OK ? (Yn)"
read confirmation

if [ -z $confirmation ] || [ $confirmation = "y" ] || [ $confirmation = "Y" ]
then
  echo -e "Push branch..."

  # Push the branch
  git push origin $newVersion
fi

# Come back to master branch
git checkout master

# Update README.md
diffUrl="[${lastGitBranch}...${newVersion}](https://github.com/justjavac/deno_diff/compare/${lastGitBranch}...${newVersion})"
patchUrl="[${lastGitBranch}...${newVersion}](https://github.com/justjavac/deno_diff/compare/${lastGitBranch}...${newVersion}.diff)"

# Insert a row in the version table
## Insert a new line (a bit tricky but compatible with either OSX sed and GNU sed)
sed -i '' 's/----|----|----|----/----|----|----|----\
NEWLINE/g' README.md
## Edit the new line with the version info
sed -i "" "s@NEWLINE@${newVersion}|${diffUrl}|${patchUrl}|${diffStat}@" README.md

# Ask for confirmation before pushing master
echo -e "\nDo push master branch automatically? (Yn)"
read confirmation

if [ -z $confirmation ] || [ $confirmation = "y" ] || [ $confirmation = "Y" ]
then
  git commit -a -m 'add deno version ${newVersion}'
  echo -e "Push branch..."

  # Push the branch
  git push origin master
fi
