#!/bin/bash

export PROJECT_ROOT="$(pwd)"
. $PROJECT_ROOT/config  

# configure SSH
printf "[\e[0;34mNOTICE\e[0m] Setting up SSH access to server for rsync usage.\n"
cd $PROJECT_ROOT
export PROJECT_ROOT="$(pwd)"
export GITHUB_BRANCH=${GITHUB_REF##*heads/}
SSH_DIR="$HOME/.ssh"

mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"
touch "$SSH_DIR/id_rsa1"
touch "$SSH_DIR/config"
mkdir -p ~/.ssh && echo "Host *" > ~/.ssh/config && echo " StrictHostKeyChecking no" >> ~/.ssh/config
cd ~
echo "$PANTHEON_PRIVATE_KEY" > "$SSH_DIR/id_rsa1"
chmod 600 "$SSH_DIR/id_rsa1"
chmod 600 "$SSH_DIR/config"
eval "$(ssh-agent -s)"
eval `ssh-agent -s`
ssh-add "$SSH_DIR/id_rsa1"
ssh-add -l
ssh-keygen -R hostname
sudo cat ~/.ssh/ssh_config
printf "[\e[0;34mNOTICE\e[0m] SSH keys configured!\n"

cd $PROJECT_ROOT

#Set Defaults
if [ -z ${PANTHEONENV+x} ]; 
	then 
		echo "PANTHEONENV is unset";
		export PANTHEONENV=dev
	else 
		echo "This will deploy to this environment '$PANTHEONENV'"; 
fi

terminus connection:set $PANTHEONSITENAME.$PANTHEONENV sftp
# deploy all files in root
rsync -rLvzc --size-only --ipv4 --progress -e 'ssh -p 2222' . --temp-dir=~/tmp/ $PANTHEONENV.$PANTHEONSITEUUID@appserver.$PANTHEONENV.$PANTHEONSITEUUID.drush.in:code/ --exclude='*.git*' --exclude node_modules/ --exclude gulp/ --exclude source/ --exclude .github/ --exclude .vscode/

#deploy pantheon yml file
#rsync -rLvzc --size-only --ipv4 --progress -e 'ssh -p 2222' ./pantheon.yml --temp-dir=~/tmp/ $PANTHEONENV.$PANTHEONSITEUUID@appserver.$PANTHEONENV.$PANTHEONSITEUUID.drush.in:code/ --exclude='*.git*' --exclude node_modules/ --exclude gulp/ --exclude source/ --exclude .github/ --exclude .vscode/
printf "[\e[0;34mNOTICE\e[0m] Deployed pantheon.yml file\n"

# deploy all files in nested docroot
#rsync -rLvzc --size-only --ipv4 --progress -e 'ssh -p 2222' ./web/. --temp-dir=~/tmp/ $PANTHEONENV.$PANTHEONSITEUUID@appserver.$PANTHEONENV.$PANTHEONSITEUUID.drush.in:code/web/ --exclude='*.git*' --exclude node_modules/ --exclude gulp/ --exclude source/ --exclude .github/ --exclude .vscode/ --exclude='pantheon*.yml'
printf "[\e[0;34mNOTICE\e[0m] Deployed web files\n"

# deploy private folder for quicksilver scripts
#rsync -rLvzc --ipv4 --progress -e 'ssh -p 2222' ./web/. --temp-dir=~/tmp/ $PANTHEONENV.$PANTHEONSITEUUID@appserver.$PANTHEONENV.$PANTHEONSITEUUID.drush.in:code/web/ --exclude='*.git*' --exclude node_modules/ --exclude gulp/ --exclude source/
printf "[\e[0;34mNOTICE\e[0m] Deployed all code in nested docroot\n"

# deploy plugins and themes
#rsync -rLvzc --size-only --ipv4 --progress -e 'ssh -p 2222' ./web/wp-content/. --temp-dir=~/tmp/ $PANTHEONENV.$PANTHEONSITEUUID@appserver.$PANTHEONENV.$PANTHEONSITEUUID.drush.in:code/web/wp-content/ --exclude='*.git*' --exclude node_modules/ --exclude gulp/ --exclude source/
printf "[\e[0;34mNOTICE\e[0m] Deployed plugin and themes\n"

# deploy core via rsync + wp-config
# rsync -rLvzc --size-only --ipv4 --progress -e 'ssh -p 2222' ./web/wp/. --temp-dir=~/tmp/ $PANTHEONENV.$PANTHEONSITEUUID@appserver.$PANTHEONENV.$PANTHEONSITEUUID.drush.in:code/web/wp/ --exclude='*.git*' --exclude node_modules/ --exclude wp-content/ --exclude gulp/ --exclude source/

#dont forget to elete the config to avoid redirect loop
#rm $PROJECT_ROOT/web/wp/wp-config.php

# deploy core and root files
#rsync -rLvzc --size-only --ipv4 --progress -e 'ssh -p 2222' ./web/. --temp-dir=~/tmp/ $PANTHEONENV.$PANTHEONSITEUUID@appserver.$PANTHEONENV.$PANTHEONSITEUUID.drush.in:code/web/ --exclude='*.git*' --exclude node_modules/ --exclude wp-content/ --exclude gulp/ --exclude source/

#terminus art



MSG1="$GH_REF2"
export MSG1
#echo ${{ github.event.head_commit.message }}
#terminus site:info  --format list --field name -- $PANTHEONSITEUUID

#echo terminus site:info  --format list --field name -- $PANTHEONSITEUUID

DEPLOYMSG="#Deployed from GitHub commit: $GH_COMMITID - $GH_COMMITMSG"
export DEPLOYMSG
echo "$GH_REF3"
echo "$DEPLOYMSG"
#echo ::set-env name=PULL_NUMBER::$(echo "$GH_REF2" | awk -F / '{print $3}')
export SITENAME="$(terminus site:info  --format list --field name -- $PANTHEONSITEUUID)"


terminus env:commit --message "$DEPLOYMSG" --force -- $SITENAME.$PANTHEONENV

printf "[\e[0;34mNOTICE\e[0m] Deployed core"

# setup backstop script
# sh $PROJECT_ROOT/scripts/github/setup-backstop