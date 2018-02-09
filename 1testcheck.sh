#!/bin/bash


#Version 1.0

#This line makes my answers green
green=`tput setaf 2`
#This line makes my answers red
red=`tput setaf 1`
##This line resets the color
reset=`tput sgr0`


#This line checks if the root password is correct
SUCCESS=$(ansible testmachine1  -m ping  --user=root --extra-vars "ansible_ssh_pass=rootadm" | awk -F "|" '{print $2}'  | awk '{print $1}' | tr -s [:space:]) 2> /dev/null
if [ $SUCCESS == "SUCCESS" ]
then
	echo "${green}The password set properly${reset}"
else
	echo "${red}The password is incorrect${reset}"
fi

#This line gets the information from remote host
IP=$(ansible testmachine1  -m setup  -a "filter=ansible_eth0 " --user=root --extra-vars "ansible_ssh_pass=redhat1"  |tail -26 | head -4) 2> /dev/null


#This line checks if the IP address is correct
IPADDRESS=$(echo $IP |  awk -F ":" '{print $2}' | awk -F ',' '{print $1}' |sed 's/"192.168.122.140"/192.168.122.140/g') 2> /dev/null
if [ $IPADDRESS == "192.168.122.140" ]
then
	echo "${green}The IP address is correct${reset}"
else
	echo "${red}The IP is not correct${reset}"
fi


#This line checks if the Netmask is correct
NETMASK=$(echo $IP | awk -F "," '{print $3}' | awk -F ":" '{print $2}' | sed 's/"255.255.255.0"/255.255.255.0/g')  2> /dev/null
if [ $NETMASK == "255.255.255.0" ] 
then
	echo "${green}The NETMASK is correct${reset}"

else
	echo "${red}The NETMASK is not correct${reset}"
fi

#This line check if the Gateway is correct
GATEWAY=$(echo $IP  | awk -F "," '{print $4}' | awk '{print $2}' | sed 's/"192.168.122.0"/192.168.122.0/g') 2> /dev/null
if [ $GATEWAY == "192.168.122.0" ]
then
	echo "${green}The Gateway is correct${reset}"
else
	echo "${red}The Gateway is not correct${reset}"
fi

#___________________________________________________________________________________________________________________________________________________

#This line checks for proper kernel line
KERNEL=$(ansible testmachine1  -m setup  -a "filter=ansible_kernel" --user=root --extra-vars "ansible_ssh_pass=redhat1" | grep kernel | awk '{print $2}' | sed 's/"3.10.0-693.17.1.el7.x86_64"/3.10.0-693.17.1.el7.x86_64/g') 2> /dev/null
if [ $KERNEL == "3.10.0-693.17.1.el7.x86_64" ]
then
	echo "${grep}The kernel version is good${reset}"
else
	echo "${red}The kernel version is old${reset}"
fi

#This line checks for selinux 
SELINUX=$(ansible testmachine1  -m setup  -a "filter=*selinux*" --user=root --extra-vars "ansible_ssh_pass=redhat1"  | grep config | awk '{print $2}' | sed 's/"enforcing",/enforcing/g') 2> /dev/null
if [ $SELINUX == "enforcing" ]
then
	echo "${green}The selinux is enforcing${reset}"
else
	echo "${red}The selinux is not enforcing${reset}"
fi


#This line check for Hostname
HOSTNAME=$(ansible testmachine1 -m shell -a "hostname "   --user=root --extra-vars "ansible_ssh_pass=redhat1" | grep net) 2> /dev/null
if [ $HOSTNAME == "net7.example.com" ]
then
	echo "${green}The hostname is set properly${reset}"
else
	echo "${red}The hostname is not set properly${reset}"
fi


#this line checks if sysusers group is created
GROUP=$(ansible testmachine1  -m shell -a "cat /etc/group" --user=root --extra-vars "ansible_ssh_pass=redhat1"    |  grep sysusers | awk -F ':' '{print $1}') 2> /dev/null
if [ $GROUP == "sysusers" ] 2> /dev/null
then
	echo "${green}The Group  has been created${reset}"
else
	echo "${red}The Group has not been created${reset}"
fi


#This line checks if Andrew is part of sysusers
ANDREW=$(ansible testmachine1  -m shell -a "id andrew | grep sysuser" --user=root --extra-vars "ansible_ssh_pass=redhat1"    | grep sysusers | cut -d "," -f2 | sed 's/1001(sysusers)/sysusers/g')2>/dev/null
if [ $ANDREW == "sysusers" ] 2>/dev/null
then
	echo "${green}The user ANDREW is created and part of sysusers${reset}"
else
	echo "${red}This user ANDREW is not part of sysusers${reset}"
fi



#This line checks if user susan is part of sysu
SUSAN=$(ansible testmachine1  -m shell -a "id susan | grep sysuser" --user=root --extra-vars "ansible_ssh_pass=redhat1"    | grep sysusers | cut -d "," -f2 | sed 's/1001(sysusers)/sysusers/g') 2> /dev/null
if [ $SUSAN == "sysusers" ] 2>/dev/null
then
	echo "${green}The user SUSAN is part of sysusers${reset}"
else
	echo "${red}The user SUSAN is not part of sysusers${reset}"
fi


# #This line checks for Brad users shell
BRAD=$(ansible testmachine1  -m shell -a "grep brad /etc/passwd" --user=root --extra-vars "ansible_ssh_pass=redhat1"    | grep brad  |awk -F ":" '{print $7}' | awk -F "/" '{print $3}') 2>/dev/null
if [ $BRAD == "false" ] 2>/dev/null
then
	echo "${green}The Brad user does not have interactive shell${reset}"
else
 	echo "${red}The brad user is not properly added${reset}"
fi


# This line checks if the common folder is created
COMMON=$(ansible testmachine1  -m shell -a "ls  /" --user=root --extra-vars "ansible_ssh_pass=redhat1"  | grep common) 2> /dev/null
if [ $COMMON == "common" ]
then
	echo "${green}The common directory is created${reset}"
else
	echo "${red}The common directory is not created${reset}"
fi


# This line checks for SGID bit of the folder
SETGID=$(ansible testmachine1  -m shell -a "file  /common/sysusers" --user=root --extra-vars "ansible_ssh_pass=redhat1"   | grep -v "^$" | awk '/set/{print $2}') 2>/dev/null
if [ $SETGID == "setgid" ] 
then
		echo "${green}The SGID bit is set properly${reset}"
else
		echo "${red}The SGID bit is not set properly${reset}"
fi



#----------------------------------------------------------------------------------------------------------------
#The below scripts checks the following commands
#10. Copy the file /etc/fstab to /var/tmp. Configure the permissions of /var/tmp/fstab so that:
		#1. The file /var/tmp/fstab is owned by the root user.
		#2. The file /var/tmp/fstab is belongs to the group root.
		#3. The file /var/tmp/fstab should not be executable by anyone.
		#4. The user andrew is able to read and write /var/tmp/fstab.
		#5. The user susan can neither write nor read /var/tmp/fstab.
		#6. All other users have the ability to read /var/tmp/fstab
------------------------------------------------------------------------------------------------------------------
# This line checks if the fstab file copied to /var/tmp
# 		1. The file /var/tmp/fstab is owned by the root user.
FSTAB=$(ansible testmachine1  -m shell -a "ls -l /var/tmp/fstab" --user=root --extra-vars "ansible_ssh_pass=redhat1"  | grep fstab | awk -F "/" '{print $4}') 2> /dev/null
if [ $FSTAB == "fstab" ]
then
	echo "${green}The file fstab is copied to /var/tmp${reset}"
else
	echo "${red}The file fstab has not been copied to /var/tmp${reset}"
fi

# This line below checks for Fstab ownership
# 		2. The file /var/tmp/fstab is belongs to the group root.
FSTABOWNERSHIP=$(ansible testmachine1  -m shell -a "ls -l /var/tmp/fstab" --user=root --extra-vars "ansible_ssh_pass=redhat1"  | awk '/root/{print $3}') 2> /dev/null
if [ $FSTABOWNERSHIP == "root" ]
then
	echo "${green}The fstab ownership belongs to root${reset}"
else
	echo "${green}The fstab ownership does not belong to root${reset}"
fi


 # This line below checks for Fstab ownership
# 		2. The file /var/tmp/fstab is belongs to the group root.
FSTABGROUPOWNERSHIP=$(ansible testmachine1  -m shell -a "ls -l /var/tmp/fstab" --user=root --extra-vars "ansible_ssh_pass=redhat1"  | awk '/root/{print $4}') 2> /dev/null
if [ $FSTABGROUPOWNERSHIP == "root" ]
then
	echo "${green}The fstab group ownership belongs to root${reset}"
else
	echo "${green}The fstab group ownership does not belong to root${reset}"
fi


# 		3. The file /var/tmp/fstab should not be executable by anyone.
----------------------------------------------------------------------------------------------------------------
# This line checks if the file is not executable be someone
FSTABEXEC=$(ansible testmachine1  -m shell -a "ls -l /var/tmp/fstab" --user=root --extra-vars "ansible_ssh_pass=redhat1"  |grep x ) 2> /dev/null
if [  -z $FSTABEXEC  ]
then
	echo "${green}The file is not executable by no one${reset}"
else
	echo "${red}The file is executable by someone${reset}"
fi


# 4. The user andrew is able to read and write /var/tmp/fstab.
ANDREWACL=$(ansible testmachine1  -m shell -a "getfacl /var/tmp/fstab | grep andrew" --user=root --extra-vars "ansible_ssh_pass=redhat1"  | grep andrew | awk -F ":" '/andrew/{print $2}') 2> /dev/null
if [ $ANDREWACL == "andrew" ]
then
	echo "${green}The file is accessible by andrew${reset}"
else
	echo "${red}The file is not accessible by ANDREW${reset}"
fi





























