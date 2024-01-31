#!/bin/bash
nmap -O $1 | grep "OS details" | sed 's/OS details: //'
