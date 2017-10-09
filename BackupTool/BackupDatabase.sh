#!/bin/bash
#echo arguments to the shell 

#CONFIGURATION
. ./BackupDatabase.config

echo "$(tput bold)""$(tput setaf 1)"'Get Docker containerid: RUNNING docker ps -a'"$(tput sgr0)"
#GET ALL CONTAINERID
docker ps -a
echo -n "$(tput bold)""$(tput setaf 3)""Done! Copy and Enter ContainerID: " 
read containerid

echo -n "Enter Database name: "
read databaseName

echo "$(tput setaf 2)"'Create Backup for Docker ContainerID: ' "$(tput setaf 3)" $containerid "$(tput setaf 2)" ' and Database: ' "$(tput setaf 3)"$databaseName "$(tput sgr0)"

#GET DATE AND TIME FOR FILENAME
DATE=`date +%Y-%m-%d`
TIME=`date +%H:%M:%S` 
FILENAME="$databaseName"_"$DATE"_"$TIME"".backup"

#CREATE DATABASE BACKUP
echo "$(tput setaf 2)"'Create Backup with filename: ' "$(tput setaf 3)""$FILENAME""$(tput sgr0)"


#Get the database password
echo -n $"$(tput setaf 3)""Enter Database Password:""$(tput sgr0)"  $'\n'
read -s password 

#Create backup 
docker exec -i -e PGPASSWORD="$password" "$containerid" pg_dump -U "$userName" -F t "$databaseName" > "$Path""$FILENAME" 
if [ $? != 0 ]; then
	exit
fi
 
echo "$(tput setaf 6)"DONE: "$(tput setaf 3)""$(tput bold)"'Please Check Backup file before carrying on!' "$(tput sgr0)"



