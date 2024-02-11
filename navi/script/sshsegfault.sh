#!/bin/sh

sshpass -p 'segfault' ssh root@segfault.net 'msfrpcd -P pakemon -U pakemon -S no -p 55552 && bettercap --eval "set api.rest.password pakemon; set api.rest.username pakemon; api.rest on; " && env`

