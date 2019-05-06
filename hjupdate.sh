#!/bin/bash - 

# To use this script:
# 1. create the script in `~/.local/bin/hjupdate` and do `chmod +x ~/.local/bin/hjupdate`
# 2. now you can update packages using `hjupdate` (use `hjupdate -a` to update all packages and `hjupdate -p datatools` to update only one package)
# 3. you can also do it in a python venv: `pew in test-venv hjupdate` (python 3)

# Global vars:
before="==> "
after=" <=="

# Getting all parameters:
installAll=0
packageToInstall=
while test $# -gt 0; do
    case "$1" in
        -h|--help)
            echo "Install hj python packages, by default only main pakages"
            echo "options:"
            echo "-a, --all    Install all available packages (instead of the minimal)"
            echo "-p, --package    Install only the specified package"
            exit 0
            ;;
        -a|--all)
            installAll=1
            shift
            ;;
        -p|--package)
            shift
            packageToInstall=$1
            shift
            ;;
        *)
            break
            ;;
    esac
done


iAmSudoer()
{
    sudoers=$(grep "^sudo:.*$" /etc/group | cut -d: -f4)
    if [[ $sudoers = *"$USER"* ]]; then
        echo 1
    else
        echo 0
    fi
}

packageToInstallLength=${#packageToInstall}
if [[ $packageToInstallLength > 0 ]]; then
    installAll=1
fi

isToInstall()
{
    if [[ $packageToInstallLength > 0 ]]; then
        if [ "$1" == "$packageToInstall" ]; then
            echo 1
        else
            echo 0
        fi
    else
        echo 1
    fi
}

# Installing some apt-get packages:
# jq git htop rsync pandoc tree unzip p7zip-full vim python-pip tk
aptUpdateDone=0
if [[ $(iAmSudoer) = 1 ]]; then
    for current in git htop rsync libenchant1c2a ; do
        commandResult=$(command -v $current)
        isInstalled=$(echo -n $commandResult | wc -c)
        if [[ $isInstalled = 0 ]]; then
            if [[ $aptUpdateDone = 0 ]]; then
                echo "Updating apt-get..."
                sudo apt-get update
                aptUpdateDone=1
            fi
            echo "$current will be installed..."
              sudo apt-get -y install $current
        else
            echo "$current is already installed."
        fi
    done
fi

# Installing some pip packages:
# for current in pew workspacemanager ; do
#     if [[ $(sudo pip freeze | grep $current) != *"$current=="* ]]; then
#         echo "$current will be installed..."
#         sudo pip install $current
#     else
#         echo "$current is already installed."
#     fi
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
    if [ $(isToInstall "$package") == "1" ]; then
        echo $before"Installing $package..."$after
        if [[ $package = *"hj"* ]]; then
            gzPattern=${gzPattern:2}
        fi
        gzPattern=*$gzPattern*.tar.gz
        if [[ $package = *"webbrowser"* ]]; then
        	pip uninstall -y hjwebbrowser
        else
        	pip uninstall -y $package
        fi
        pip install $webcrawlerWmdistPath/$gzPattern
    else
        echo $before"We don't install $package..."$after
    fi
}

# We create a funct to insall from github:
installFromGithub()
{
    currentDir=$(pwd)
    projectName=$1
    package=$(echo $projectName | tr '[:upper:]' '[:lower:]')
    if [ $(isToInstall "$package") == "1" ]; then
        echo $before"Installing $package..."$after
        packagePath=$tmpDir/$projectName
        git clone -q https://github.com/hayj/$projectName.git $packagePath
        pip uninstall -y $package
        cd $packagePath
        python setup.py install
        cd $currentDir
    fi
}

# We download packages in tar.gz:
webcrawlerPath=$tmpDir/WebCrawler
webcrawlerWmdistPath=$webcrawlerPath/wm-dist
url="https://github.com/hayj/WebCrawler.git"
echo "Downloading $url..."
git clone -q $url $webcrawlerPath

# For all main packages:
for i in "hjsystemtools" "datastructuretools" "databasetools" "datatools" "newstools" "nlptools" "sparktools" "networktools"; do
    installGz $i
done

# For all others packages:
if [[ $installAll = 1 ]]; then
    for i in "domainduplicate" "error404detector" "honeypotdetector" "machinelearning" "unshortener" "webbrowser" "webcrawler" "scroller"; do
        installGz $i
    done
    # Other packages:
    # for i in "NewsTools" "Scroller"; do
    #     installFromGithub $i
    # done
fi

# Removing the tmp dir:
rm -rf $tmpDir



