# #!/bin/bash


# #Version 1.0

# #This line makes my answers green
 green=`tput setaf 2`
# #This line makes my answers red
 red=`tput setaf 1`
# ##This line resets the color
 reset=`tput sgr0`


# #This line checks if the root password is correct
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
	echo "${green}The kernel version is good${reset}"
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
#------------------------------------------------------------------------------------------------------------------
# This line checks if the fstab file copied to /var/tmp
# 		1. The file /var/tmp/fstab is owned by the root user.
FSTAB=$(ansible testmachine1  -m shell -a "ls -l /var/tmp/fstab" --user=root --extra-vars "ansible_ssh_pass=redhat1"  | grep fstab | awk -F "/" '{print $4}') 2> /dev/null
if [ $FSTAB == "fstab" ] 2> /dev/null
then
	echo "${green}The file fstab is copied to /var/tmp${reset}"
else
	echo "${red}The file fstab has not been copied to /var/tmp${reset}"
fi

# This line below checks for Fstab ownership
# 		2. The file /var/tmp/fstab is belongs to the group root.
FSTABOWNERSHIP=$(ansible testmachine1  -m shell -a "ls -l /var/tmp/fstab" --user=root --extra-vars "ansible_ssh_pass=redhat1"  | awk '/root/{print $3}') 2> /dev/null
if [ $FSTABOWNERSHIP == "root" ] 2> /dev/null
then
	echo "${green}The fstab ownership belongs to root${reset}"
else
	echo "${green}The fstab ownership does not belong to root${reset}"
fi


 # This line below checks for Fstab ownership
# 		2. The file /var/tmp/fstab is belongs to the group root.
FSTABGROUPOWNERSHIP=$(ansible testmachine1  -m shell -a "ls -l /var/tmp/fstab" --user=root --extra-vars "ansible_ssh_pass=redhat1"  | awk '/root/{print $4}') 2> /dev/null
if [ $FSTABGROUPOWNERSHIP == "root" ] 2> /dev/null
then
	echo "${green}The fstab group ownership belongs to root${reset}"
else
	echo "${green}The fstab group ownership does not belong to root${reset}"
fi


# 		3. The file /var/tmp/fstab should not be executable by anyone.
#----------------------------------------------------------------------------------------------------------------
# This line checks if the file is not executable be someone
FSTABEXEC=$(ansible testmachine1  -m shell -a "ls -l /var/tmp/fstab" --user=root --extra-vars "ansible_ssh_pass=redhat1"  |grep x ) 2> /dev/null
if [  -z $FSTABEXEC  ] 2> /dev/null
then
	echo "${green}The file is not executable by no one${reset}"
else
	echo "${red}The file is executable by someone${reset}"
fi


# 4. The user andrew is able to read and write /var/tmp/fstab.
ANDREWACL=$(ansible testmachine1  -m shell -a "getfacl /var/tmp/fstab | grep andrew" --user=root --extra-vars "ansible_ssh_pass=redhat1"  | grep andrew | awk -F ":" '/andrew/{print $2}') 2> /dev/null
if [ $ANDREWACL == "andrew" ] 2> /dev/null
then
	echo "${green}The file is accessible by andrew${reset}"
else
	echo "${red}The file is not accessible by ANDREW${reset}"
fi


#Create a collaborative directory /home/materials with the following characteristic.
#1. Group ownership of /home/materials should be sysadmin group.
MATERIALS=$(ansible testmachine1  -m shell -a "ls -l /home | grep mater " --user=root --extra-vars "ansible_ssh_pass=redhat"  | awk '/sys/{print $4}') 2> /dev/null 
if [ $MATERIALS == "sysadmins" ] 2> /dev/null
then
	echo "${green}The groupownership is set properly for /home/materials file${reset}"
else
	echo "${red}The groupownership is not set properly for /home/materials file${reset}"
fi


#Create a user ‘jean’ having user identity as 4032 and his home directory should be in /india/redhat.
HOMEDIR=$(ansible testmachine1  -m shell -a "grep jean /etc/passwd" --user=root --extra-vars "ansible_ssh_pass=redhat"   | awk -F ':' '{print $6}' | awk -F "/" '{print $2}' | grep -v ^$) 2> /dev/null
REDHAT=$(ansible testmachine1  -m shell -a "grep jean /etc/passwd" --user=root --extra-vars "ansible_ssh_pass=redhat"   | awk -F ':' '{print $6}' | awk -F "/" '{print $3}' | grep -v ^$) 2> /dev/null
if [ $HOMEDIR == "india" ] && [ $REDHAT == "redhat" ]  2> /dev/null
then
	echo "${green}The home directory is good${reset}"
else
	echo "${red}The home directory is not good${reset}"
fi
USERID=$(ansible testmachine1  -m shell -a "id jean" --user=root --extra-vars "ansible_ssh_pass=redhat"   | awk '/jean/{print $1}' | cut -c5-8) 2> /dev/null
if [ $USERID == 4032 ] 2> /dev/null
then
	echo "${green}The user id of Jean correct${reset}"
else
	echo "${red}The user id of Jean is not correct${reset}"
fi

#13. Find the file which owned by user jean and copy the file into /findresults directory if needed please create the directory.
FINDRESULTS=$(ansible testmachine1  -m shell -a "ls / | grep -x findresults" --user=root --extra-vars "ansible_ssh_pass=redhat"   | grep findresults) 2> /dev/null
FILES=$(ansible testmachine1  -m shell -a "ls /findresults | grep -x files" --user=root --extra-vars "ansible_ssh_pass=redhat"   | grep files) 2> /dev/null
if [ $FINDRESULTS == "findresults" ] && [ $FILES == "files" ] 2> /dev/null
then
	echo "${green}The folder findresults created and the files of Jean copied${reset}"
else
	echo "${red}The folder findresults is not created and the files of Jean is not copied${reset}"
fi

	#14. Search the string cbsp in the /etc/services file and save the output in /tmp/grepoutput.
CBSP=$(ansible testmachine1  -m shell -a "grep cbsp /tmp/grepoutput " --user=root --extra-vars "ansible_ssh_pass=redhat"   | awk '/cbsp/{print $1}') 2> /dev/null
if [ $CBSP == "3gpp-cbsp" ] 2> /dev/null
then
	echo "${green}The /etc/services content is good${reset}"
else
	echo "${red}The /etc/services content is not good${reset}"
fi

#	15. Create an archive file /root/local.tar.gz gzip.
 GZIPFILE=$(ansible testmachine1  -m shell -a "file /root/local.tar.gz " --user=root --extra-vars "ansible_ssh_pass=redhat"    | awk '/gzip/{print $2}') 2> /dev/null
 if [ $GZIPFILE == "gzip" ] 2> /dev/null
 then
 	echo "${green}The file is zipped properly${reset}" 
 else
 	echo "${red}The file is not zipped properly${reset}"
 fi


# #16. Create a bzip2 compression of /etc directory. Name the compression file as etc.tar.bz2 and put this file in /root 		directory.

 BZIP2=$(ansible testmachine1  -m shell -a "file /root/etc.tar.bz2 " --user=root --extra-vars "ansible_ssh_pass=redhat"    | awk '/bzip2/{print $2}') 2> /dev/null
 if [ $BZIP2 == "bzip2" ] 2> /dev/null
 then
 	echo "${green}The Bzip2 file is created${reset}"
 else
 	echo "${red}The Bzip2 files is not created${reset}"
 fi

#--------------------------------------------------------------------------------------------------------------------------------------------------
#	21. Create 1 GB ext4 file system on second disk persistent mounted at /archive
FILESYSTEM=$(ansible testmachine1  -m shell -a "blkid " --user=root --extra-vars "ansible_ssh_pass=redhat"   | grep vdb | awk -F "=" '{print $3}' | sed 's/"ext4"/ext4/g') 2> /dev/null
if [ $FILESYSTEM == "ext4" ] 2> /dev/null
then
	echo "${green}The filesystem is good${reset}"
else
	echo "${red}The filesystem is not good${reset}"
fi

#	21. Create 1 GB ext4 file system on second disk persistent mounted at /archive
DEVICE=$(ansible testmachine1  -m shell -a "df -h" --user=root --extra-vars "ansible_ssh_pass=redhat"   | grep vdb | cut  -c6-8) 2> /dev/null
MOUNTPOINT=$(ansible testmachine1  -m shell -a "df -h" --user=root --extra-vars "ansible_ssh_pass=redhat"   | grep vdb | cut -c49-55) 2> /dev/null
if [ $DEVICE == "vdb" ] 2> /dev/null && [ $MOUNTPOINT == "archive" ] 2> /dev/null
then
	echo "${green}The mounted vbd is good${reset}"
else
	echo "${red}The mounted device is not good${reset}"
fi
FSTABDEVICE=$(ansible testmachine1  -m shell -a "grep vdb /etc/fstab" --user=root --extra-vars "ansible_ssh_pass=redhat"   | awk '/vdb/{print $1}' | cut -c6-8) 2> /dev/null
if [ $FSTABDEVICE == "vdb" ] 2> /dev/null
then
	echo "${green}The device is in fstab${reset}"
else
	echo "${red}The device is not in fstab${reset}"
fi
#	21. Create 1 GB ext4 file system on second disk persistent mounted at /archive
FSTABMOUNTPOINT=$(ansible testmachine1  -m shell -a "grep vdb /etc/fstab" --user=root --extra-vars "ansible_ssh_pass=redhat"   | awk '/vdb/{print $2}' | cut -c2-8) 2>  /dev/null
if [ $FSTABMOUNTPOINT == "archive" ] 2> /dev/null
then
	echo "${green}The MOUNTPOINT is good${reset}"
else
	echo "${red}The MOUNTPOINT is not good ${reset}"
fi
#--------------------------------------------------------------------------------------------------------------------------------------------------------




