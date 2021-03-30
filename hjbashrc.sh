########## HAYJ ##########

# Splinter and Selenium :

export PATH="$PATH:/home/hayj/.local/bin/"
export PATH="$PATH:/home/hayj/Programs/browserdrivers/"
export PATH="$PATH:/usr/lib/firefox"
export PATH="$PATH:/home/hayj/Programs/headlessbrowsers/phantomjs-2.1.1-linux-x86_64/bin/"
export PATH="/home/hayj/.local/bin:$PATH"
export PATH="/home/hayj/Programs/waterfox/:$PATH"
export PATH="/home/hayj/lib/node-v14.15.1-linux-x64/bin/:$PATH"

export PATH="/home/hayj/lib/idea-IC-203.5981.155/bin:$PATH"

export PATH="/home/hayj/lib/apache-maven-3.6.3/bin:$PATH"

export PATH="/home/hayj/Programs/anaconda3//bin:$PATH"



# export PYTHONPATH="/home/hayj/wm-dist-tmp/WebCrawler/":$PYTHONPATH # Attention cela provoque des conflit dans les venv puisu'elle ont aussi un dossier du meme nom


# Prompt user (http://bashrcgenerator.com/):
# Pls create short hostname like "hjlat" for the Dell Latitude computer..., to change the hostname, : "sudo gedit /etc/hostname" and restart
# export PS1="\[\033[38;5;77m\]\u@\h:\W\\$ \[$(tput sgr0)\]" # HJLAT before Ubuntu 20
# Prompt root:
# export PS1="\[\033[38;5;9m\]\u@\h:\W\\$ \[$(tput sgr0)\]" # to past in /root/.bashrc


# Instead of a custom PS1, replace \w by \W in ~/.bashrc. See <https://superuser.com/questions/60555/show-only-current-directory-name-not-full-path-on-bash-prompt>


function extract-pdf-range {
    pdftk $1 cat $2-$3 output $1-from-p$2-to-p$3.pdf
}

function rotate-pdf {
    mv $1 $1_copy.pdf
    pdftk $1_copy.pdf cat 1-enddown output $1
    rm $1_copy.pdf
}


# http://sametmax.com/tu-vas-crever-oui/
# Usage to see which ones will be killed : killbill -t toto
# Puis : killbill toto
function killbill {
    BAK=$IFS
    IFS=$'\n'
    for id in $(ps aux | grep -P -i $1 | grep -v "grep" | awk '{printf $2" "; for (i=11; i<NF; i++) printf $i" "; print $NF}'); do 
        if [[ $id = *"killbill"* ]]; then
            # Because it does not detect itself when executing a remote command like `ssh hayj@address "source ~/.bashrc ; killbill sklearn"`
            # echo "I don't kill myself..."
            :
        elif [[ $id = *"oomstopper"* ]]; then
            # Because we don't kill the OOM Stopper (python script)
            :
        else
            service=$(echo $id | cut -d " " -f 1)
            if [[ $2 == "-t" ]]; then
                echo $service \"$(echo $id | cut -d " " -f 2-)\" "would be killed"
            else
     
                echo $service \"$(echo $id | cut -d " " -f 2-)\" "killed"
                kill -9 $service
            fi
        fi
    done
    IFS=$BAK
}


extract() {
    if [ -f $1 ]
    then
        case $1 in
            (*.7z) 7z x $1 ;;
            (*.lzma) unlzma $1 ;;
            (*.rar) unrar x $1 ;;
            (*.tar) tar xvf $1 ;;
            (*.tar.bz2) tar xvjf $1 ;;
            (*.bz2) bunzip2 -k $1 ;;
            (*.tar.gz) tar xvzf $1 ;;
            (*.gz) gunzip -k $1 ;;
            (*.tar.xz) tar Jxvf $1 ;;
            (*.xz) xz -d $1 ;;
            (*.tbz2) tar xvjf $1 ;;
            (*.tgz) tar xvzf $1 ;;
            (*.zip) unzip $1 ;;
            (*.Z) uncompress ;;
            (*) echo "don't know how to extract '$1'..." ;;
        esac
    else
        echo "Error: '$1' is not a valid file!"
        exit 0
    fi
}


findall() {
    echo "----- Directories ------"
    finddir $1
    echo "----- Files ------"
    findfile $1
}

# https://stackoverflow.com/questions/8063228/how-do-i-check-if-a-variable-exists-in-a-list-in-bash
isIn()
{
    [[ $2 =~ (^|[[:space:]])$1($|[[:space:]]) ]] && echo 1 || echo 0
}

# Nohup nice low priority:
# Usages:
# s=silent, o=outputFile, n=niceness
# nn 9 touch test1.txt
# nn -o nohup-test.out touch test2.txt
# nn -o nohup-test.out -n 9 touch test3.txt
# nn 9 -o nohup-test.out touch test4.txt
# nn 9 -s touch test5.txt
# nn -s -n 9 touch test6.txt
# https://stackoverflow.com/questions/46412011/bash-how-to-use-a-function-which-is-a-string-param-in-an-other-function
nn()
{
    niceness="15" # Default niceness
    regexInteger='^[0-9]+$'
    outputPath="nohup.out"
    optionExists=1
    silent=0
    if [[ $1 =~ $regexInteger ]] ; then
        niceness=$1
        shift;
    fi
    while [ $(isIn $1 "-n -o -s") = 1 ] ; do
        if [[ $1 = "-o" ]] ; then
            outputPath="$2"
            shift;
            shift;
        elif [[ $1 = "-n" ]] ; then
            niceness="$2"
            shift;
            shift;
        elif [[ $1 = "-s" ]] ; then
            silent=1
            shift;
        fi
    done
    
    echo "niceness: "$niceness
    echo "outputPath: "$outputPath
    
    if [[ $(type -t "$1") == function ]]; then
        export -f "$1"
        set -- bash -c '"$@"' -- "$@"
    fi
    if [[ $silent = 0 ]] ; then
        nohup nice -n "$niceness" "$@" &> $outputPath&
    else
        # nohup nice -n "$niceness" "$@" > $outputPath 2>&1&
        nohup nice -n "$niceness" "$@" >/dev/null 2>&1 &
    fi
}


tipi()
{
    if [ -z "$1" ]
    then
        id="58"
    else
        id="$1"
    fi
    ssh hayj@tipi"$id".lri.fr
}


briss()
{
    mkdir -p briss-output
    files="$@"
    if [ $# -eq 0 ]
    then
        files="*.pdf"
    fi
    for var in $files
    do
        name=$(echo $var | cut -f 1 -d '.')
        outputPath="./briss-output/"$name"_cropped.pdf"
        if [ ! -f $outputPath ]; then
            java -jar /home/hayj/Programs/briss-0.9/briss-0.9.jar -s $var -d $outputPath
        fi
    done
}

hjpush()
(
    a=$(pwd)
    cd /home/hayj/Workspace/Python/Crawling/WebCrawler/
    wm-dist
    gitpush
    cd $a
)

# address=pl-ssh.lri.fr
# port=22
# if [ $(isReachable $address) = 1 ] ;
# then
#     echo "==> SUCCESS: The host $address is reachable <=="
#     rsync -a -e ssh /home/hayj/.bash_aliases hayj@$address:~
# else
#     echo "==> ERROR: The host $address is unreachable <=="
# fi
isReachable()
{
    address=$1
    if [ -z "$2" ];
    then    
        port=22
    else
        port=$2
    fi
    if [ -z "$3" ];
    then    
        user=$USER
    else
        user=$3
    fi

    status=$(ssh -o BatchMode=yes -o ConnectTimeout=6 -p "$port" "$user"@"$address" echo "_CONNEXION_SUCCESS_" 2>&1)
    if [[ $status = *"_CONNEXION_SUCCESS_"* ]]
    then
        echo 1
    else
        echo 0
    fi
}

ipynb2py()
{
    if [ -z "$1" ];
    then
        echo "Please provide an ipynb file."
    else
        file=$1
        if [ -z "$2" ];
        then
            jupyter nbconvert --to script $file --output $file
        else
            pew in $2 jupyter nbconvert --to script $file --output $file
        fi
    fi
}

# The jupython function allow to execute a jupyter notebook file as a python script.
# Usage: 
# jupython print-a.ipynb # Simple execution of the ipynb
# jupython --venv st-venv print-a.ipynb # Specify the venv
# jupython --no-nn print-a.ipynb # Do not use nohup and nice (defaut is true)
# jupython --no-tail print-a.ipynb # Do not use tail -f when using nn (default is False)
# jupython -o print-a.out -n 10 print-a.ipynb # Specify the output file and the niceness for nohup and nice
jupython()
{
    # We get all options:
    venvName=""
    outName=""
    doNN=1
    doTail=1
    niceness=10
    while [ $(isIn $1 "--no-nn --no-tail --venv -o -n") = 1 ] ; do
        if [[ $1 = "-o" ]] ; then
            outName="$2"
            shift;
            shift;
        elif [[ $1 = "--no-nn" ]] ; then
            doNN=0
            shift;
        elif [[ $1 = "--no-tail" ]] ; then
            doTail=0
            shift;
        elif [[ $1 = "--venv" ]] ; then
            venvName="$2"
            shift;
            shift;
        elif [[ $1 = "-n" ]] ; then
            niceness="$2"
            doNN=1
            shift;
            shift;
        fi
    done
    # We get the ipynb path:
    ipynbPath=""
    if [ -z "$1" ];
    then
        echo "Please provide at least an ipynb file."
        return
    else
        ipynbPath="$1"
    fi
    # We compute all path:
    fullName=$(basename -- "$ipynbPath")
    fileName="${fullName%.*}"
    pyPath=$ipynbPath.py
    if [ -z "$outName" ];
    then    
        outName=nohup-$fileName.out
    fi
    # We convert the ipynb file:
    if [ -z "$venvName" ];
    then
        ipynb2py $ipynbPath
    else
        ipynb2py $ipynbPath $venvName
    fi
    # if we use nn:
    if [[ $doNN = 1 ]]; then
        # We execute the py file with nn:
        if [ -z "$venvName" ];
        then
            nn $niceness -o $outName python $pyPath "$@"
        else
            nn $niceness -o $outName pew in $venvName python $pyPath "$@"
        fi
        # We wait for the output file:
        sleep 1
        # We remove the generated py file:
        echo $pyPath
        rm -f $pyPath
        if [[ $doTail = 1 ]]; then
            # We observe the output file:
            tail -f $outName
        fi
    # Else we just execute it:
    else
        if [ -z "$venvName" ];
        then
            python $pyPath "$@"
        else
            pew in $venvName python $pyPath "$@"
        fi
    fi
    # We remove the generated py file:
    rm -f $pyPath
}

githubpushmagic()
{
    DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    gitDirs=$(find ~/Workspace/Python/ ~/Workspace/Bash/ -name ".git")
    for gitDir in $gitDirs;
    do
        projectDir="$(dirname "$gitDir")"
        cd $projectDir
        remoteUrl=$(git config --get remote.origin.url)
        if [[ $remoteUrl = *"github.com"* ]]; then
            echo "Doing "$projectDir"..."
            # git rm -r --cached .
            git add .
            git commit -m "minor updates"
            git push -u origin master
        fi
    done
    cd $DIR
}




##########################

# This alias function combo will disable the pathname auto expansion
# to prevent *.out to be convert in a file path which exists on the
# local computer. See https://stackoverflow.com/questions/11456403/stop-shell-wildcard-character-expansion?answertab=votes#answer-22945024
# alias rsync-from-octods='set -o noglob ; rsync-from-octods'
# rsync-from-octods()
# {
#     rsync -avhuP -e "ssh -p 2222" hayj@octods:$1 $2
#     set +o noglob
# }

# alias rsync-from-tipi='set -o noglob ; rsync-from-tipi'
# rsync-from-tipi()
# {
#     rsync -avhuP hayj@tipi58.lri.fr:$1 $2
#     set +o noglob
# }

# alias rsync-to-octods='set -o noglob ; rsync-to-octods'
# rsync-to-octods()
# {
#     rsync -avhuP -e "ssh -p 2222" $1 hayj@octods:$2
#     set +o noglob
# }

# alias rsync-to-tipi='set -o noglob ; rsync-to-tipi'
# rsync-to-tipi()
# {
#     rsync -avhuP $1 hayj@tipi58.lri.fr:$2
#     set +o noglob
# }


condain()
{
    # source ~/.hjbashrc
    # source ~/.bash_aliases
    venvName=$1
    shift
    source activate $venvName
    $@
    conda deactivate
}

killscreen()
{
    screen -X -S $1 quit
}

screenin()
{
    # We get the screen name:
    screenName=$1
    shift
    # We set the log path:
    if [ -z "$1" ];
    then    
        DIR=$(pwd)
        logPath=$DIR"/"$screenName".screen.out"
    else
        logPath=$1
        shift
    fi
    # We create the conf file:
    confDir="$HOME/tmp/screen-confs"
    mkdir -p $confDir
    confPath=$confDir"/"$screenName".conf"
    rm -f $confPath
    touch $confPath
    echo "logfile $logPath" >> $confPath
    echo "logfile flush 1" >> $confPath
    echo "log on" >> $confPath
    echo "logtstamp after 1" >> $confPath
    echo 'logtstamp string "[ %t: %Y-%m-%d %c:%s ]\012"' >> $confPath
    echo "logtstamp on" >> $confPath
    # We create the screen:
    screen -c $confPath -S $screenName -d -m -L
    # We source all:
    # screen -r $screenName -X stuff $'source ~/.hjbashrc\n'
    # screen -r $screenName -X stuff $'source ~/.bash_aliases\n'
    # And we send stuff:
    NL=$'\n'
    for param in "$@"
    do
        screen -r $screenName -X stuff "$param "
    done
    screen -r $screenName -X stuff "$NL"
    
    # screen -r $screenName -X stuff "extract TD1-BigData-2019.zip$NL"


    # TODO check if the screen already exists to do not create it but send command...
}


AmISudoer()
{
    sudoers=$(grep "^sudo:.*$" /etc/group | cut -d: -f4)
    if [[ $sudoers = *"$USER"* ]]; then
        echo 1
    else
        echo 0
    fi
}

getTipiAddresses()
{
    allTipiNumbers=$(echo {00..07})
    allTipiNumbers=$allTipiNumbers" "$(echo {56..82})
    allTipiNumbers=$allTipiNumbers" "$(echo {85..87})
    allTipiNumbers=$allTipiNumbers" "$(echo {89..91})
    allTipiNumbers=$allTipiNumbers" "$(echo {93..94})
    adresses=
    for i in $allTipiNumbers
    do
        address=tipi"$i".lri.fr
        port=22
        adresses+=" $address"
    done
    echo $adresses
}

tunnel()
{
    screen -X -S ssh-tunnel-$1 quit
    screenin ssh-tunnel-$1 ~/tmp/ssh-tunnel-$1-screen.out ssh -L $1:localhost:$1 hayj@$2
}


# mobserve()
# {
#     multitail -Q 1 "*.$1" -du --mergeall --mark-change *.$1
# }


# Usage:
# mobserve extension [otherExtension...]
# Examples:
# mobserve log out
# mobserve_TODO()
# {
#     # multitail -Q 1 "*.log" -Q 1 "./*/*.out" -Q 1 "./*/*.log" -du --mergeall --mark-change *.txt *.out */*.out
#     # multitail -Q 1 "*.txt" -du --mergeall --mark-change *.txt

#     # while [ -z "$1" ]
#     # while [ -z "$1" ] ; do
#     #     echo "eeee"
#     #     shift
#     # done
    
#     qString=""
#     for currentParam in "$@"
#     do
#         qString="$qString -Q 1 \"*.$currentParam\""
#     done

#     for i in $(seq 1 20);
#     do
#         path=""
#         for currentParam in "$@"
#         do
#             # path=$path" "$(expandPath *.$currentParam)
#             path="$path "$(expandPath "*.$currentParam")
#         done
#         echo "$path"
#         if [[ $(allFilesExist $path) = 1 ]]; then
#             echo multitail $qString -du --mergeall --mark-change $path
#             return 1
#         else
#             echo "All files for $path not found, we sleep and retry..."
#             sleep 1
#         fi
#     done
# }

# https://stackoverflow.com/questions/3963716/how-to-manually-expand-a-special-variable-ex-tilde-in-bash/29310477#29310477
expandPath()
{
    case $1 in
        ~[+-]*)
            local content content_q
            printf -v content_q '%q' "${1:2}"
            eval "content=${1:0:2}${content_q}"
            printf '%s\n' "$content"
            ;;
        ~*)
            local content content_q
            printf -v content_q '%q' "${1:1}"
            eval "content=~${content_q}"
            printf '%s\n' "$content"
            ;;
        *)
            printf '%s\n' "$1"
            ;;
      esac
}

allFilesExist()
{
    found=1
    for currentParam in "$@"
    do
        if ! [ -f $currentParam ]
        then
            found=0
        fi
    done
    echo $found
}


windows-reboot()
{
    WINDOWS_TITLE=`grep -i 'windows' /boot/grub/grub.cfg|cut -d"'" -f2`
    sudo grub-reboot "$WINDOWS_TITLE"
    sudo reboot
}


# This function allows to prevent out of memory
# Usage:
# > oomstopper oomsimulator
# > oomstopper --no-tail tfidf
oomstopper()
{

    doTail=1
    while [ $(isIn $1 "--no-nn --no-tail --venv -o -n") = 1 ] ; do
        if [[ $1 = "--no-tail" ]] ; then
            doTail=0
            shift;
        fi
    done
    mkdir -p ~/tmp/oomstopper
    path=~/tmp/oomstopper/nohup-oomstopper-$HOSTNAME-$(date +%Y-%m-%d-%H.%M.%S).out
    nn -o $path pew in st-venv python ~/Workspace/Python/Utils/MemoryWatcher/memorywatcher/oomstopper.py $1
    if [[ $doTail = 1 ]]; then
        sleep 1
        # We observe the output file:
        tail -f $path
    fi
}
