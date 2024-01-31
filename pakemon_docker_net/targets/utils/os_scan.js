onEvent('endpoint.new', function(event){
  run('!nmap -F -O --osscan-guess -T4 ' + event.data.ipv4)
}
