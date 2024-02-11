store=generate_host_list.txt

for (( i = 1; i <= 33; i++ )); do 
    echo "    Host${i}:" >> $store
    echo "        image: library/alpine" >> $store
    echo "        hostname: Host${i}" >> $store
    echo "        tty: true " >> $store
    echo "        stdin_open: true " >> $store
    echo "        networks:" >> $store
    echo "            - pakemon" >> $store


done
