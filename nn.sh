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