# The jupython function allow to execute a jupyter notebook file as a python script.
# Usage: 
# jupython print-a.ipynb # Simple execution of the ipynb
# jupython --venv st-venv print-a.ipynb # Specify the venv
# jupython --no-nn print-a.ipynb # Do not use nohup and nice (defaut is true)
# jupython -o print-a.out -n 10 print-a.ipynb # Specify the output file and the niceness for nohup and nice
jupython()
{
    # We get all options:
    venvName=""
    outName=""
    doNN=1
    niceness=10
    while [ $(isIn $1 "--no-nn --venv -o -n") = 1 ] ; do
        if [[ $1 = "-o" ]] ; then
            outName="$2"
            shift;
            shift;
        elif [[ $1 = "--no-nn" ]] ; then
            doNN=0
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
        # We observe the output file:
        tail -f $outName
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
    rm $pyPath
} 
