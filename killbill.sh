# http://sametmax.com/tu-vas-crever-oui/
# Usage to see which ones will be killed : killbill -t toto
# Puis : killbill toto
function killbill {
    BAK=$IFS
    IFS=$'\n'
    for id in $(ps aux | grep -P -i $1 | grep -v "grep" | awk '{printf $2" "; for (i=11; i<NF; i++) printf $i" "; print $NF}'); do 
        service=$(echo $id | cut -d " " -f 1)
        if [[ $2 == "-t" ]]; then
            echo $service \"$(echo $id | cut -d " " -f 2-)\" "would be killed"
        else
 
            echo $service \"$(echo $id | cut -d " " -f 2-)\" "killed"
            kill -9 $service
        fi
    done
    IFS=$BAK
}

