# Lee Spray

A Fork from the Password Spraying tool for Active Directory Credentials by Jacob Wilkin(Greenwolf)

## Getting Started

These instructions will show you the requirements for and how to use Spray.

### Prerequisites

All requirements come preinstalled on Kali Linux, to run on other flavors or Mac
just make sure curl(owa & lync) and rpcclient(smb) are installed using apt-get or brew.

```
rpcclient
curl
```

## Using Spray

Simply use the "startspray.sh" script to use the preset usernames and passwords lists. You will need to update the ip and domain specified in start script for your domain.


This script will password spray a target over a period of time
It requires password policy as input so accounts are not locked out

Accompanying this script are a series of hand crafted password files for 
multiple languages. These have been crafted from the most common active 
directory passwords in various languages and all fit in the complex 
(1 Upper, 1 lower, 1 digit) catagory. 

### SMB

To password spray a SMB Portal, a userlist, password list, attempts 
per lockout period, lockout period length and the domain must be provided

```
Useage: spray.sh -smb <targetIP> <usernameList> <passwordList> <AttemptsPerLockoutPeriod> <LockoutPeriodInMinutes> <DOMAIN>
Example: spray.sh -smb 192.168.0.1 users.txt passwords.txt 1 35 SPIDERLABS
```

## Authors

* **Jacob Wilkin** - *Research and Development* - [Trustwave SpiderLabs](https://github.com/SpiderLabs)

## License

Spray
Created by Jacob Wilkin
Copyright (C) 2017 Trustwave Holdings, Inc.
 
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

## Acknowledgments

* Thanks to insidetrust for their great [statistically likely usernames](https://github.com/insidetrust/statistically-likely-usernames) project which I have included in the name-lists folder
