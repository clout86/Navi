#!/bin/sh
apt update -y && apt upgrade -y && apt install -y metasploit-framework &&  msfrpcd -P badpass -U msf -S false -p 55552 && sh 
