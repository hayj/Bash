#!/bin/bash - 

# To use this script:
# 1. add it in "~/.local/bin/" as "hjupdate"
# 2. do "chmod +x ~/.local/bin/hjupdate"
# 3. enter in a python venv, for example "pew workon test-venv" (python 3)
# 4. execute the update using "hjupdate" (will install main hj packages) or "hjupdate -a" (will install ALL hj packages)

# Global vars:
before="==> "
after=" <=="

# Getting all parameters:
installAll=0
while test $# -gt 0; do
        case "$1" in
                -h|--help)
                        echo "Install hj python packages"
                        echo "options:"
                        echo "-a, --all=ALL       Install all available package (instead of the minimal)"
                        exit 0
                        ;;
                -a|--all)
                        installAll=1
                        shift
                        ;;
                *)
                        break
                        ;;
        esac
done

# Installing some apt-get packages:
# aptUpdateDone=0
# for current in jq htop rsync ; do
# 	commandResult=$(command -v $current)
# 	isInstalled=$(echo -n $commandResult | wc -c)
# 	if [[ $isInstalled = 0 ]]; then
# 		if [[ $aptUpdateDone = 0 ]]; then
#                     echo "Updating apt-get..."
#                     sudo apt-get update
#                 fi
# 		aptUpdateDone=1
# 		echo "$current will be installed..."
# 	  	sudo apt-get -y install $current
# 	else
# 		echo "$current is already installed."
# 	fi
# done

# Installing some pip packages:
# for current in pew workspacemanager ; do
# 	if [[ $(sudo pip freeze | grep $current) != *"$current=="* ]]; then
# 		echo "$current will be installed..."
# 		sudo pip install $current
# 	else
# 		echo "$current is already installed."
# 	fi
# done

# Print param infos:
if [[ $installAll = 0 ]]; then
    echo $before"Installing hj main packages..."$after
else
    echo $before"Installing all hj packages..."$after
fi  

# Creating a tmp directory:
tmpDirName="hjupdate-tmp"
# currentDir=$(pwd)
currentDir=~
tmpDir=$currentDir/$tmpDirName
rm -rf $tmpDir
mkdir -p $tmpDir

# We create the install funct:
installGz()
{
    package=$1
    gzPattern=$1
    echo $before"Installing $package..."$after
    if [[ $package = *"hj"* ]]; then
        gzPattern=${gzPattern:2}
    fi
    gzPattern=*$gzPattern*.tar.gz
    pip uninstall -y $package
    pip install $webcrawlerWmdistPath/$gzPattern
}

# We create a funct to insall from github:
installFromGithub()
{
    projectName=$1
    package=$(echo $projectName | tr '[:upper:]' '[:lower:]')
    echo $before"Installing $package..."$after
    packagePath=$tmpDir/$projectName
    echo $packagePath
    git clone -q https://github.com/hayj/$projectName.git $packagePath
    pip uninstall -y $package
    python $packagePath/setup.py install
}

# We download packages in tar.gz:
webcrawlerPath=$tmpDir/WebCrawler
webcrawlerWmdistPath=$webcrawlerPath/wm-dist
git clone -q https://github.com/hayj/WebCrawler.git $webcrawlerPath

# For all main packages:
for i in "hjsystemtools" "datastructuretools" "databasetools" "datatools"; do
    installGz $i
done

# For all others packages:
if [[ $installAll = 1 ]]; then
    for i in "domainduplicate" "error404detector" "honeypotdetector" "machinelearning" "nlptools" "unshortener" "webbrowser" "webcrawler"; do
        installGz $i
    done
    # Other packages:
    for i in "NewsTools" "Scroller"; do
        installFromGithub $i
    done
fi

# Removing the tmp dir:
rm -rf $tmpDir



