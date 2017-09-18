#!/bin/sh
#echo arguments to the shell
#TODO: Error handling!
#TODO: Config for PATH and others

#CONSTANTS 
userName='docker'
hostName='localhost'
port=5433

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
FILENAME="/home/ubuntu/PatchDBTool/BackupTool/Backups/MarketplaceCore_2017-09-15_07:46:12.backup"

#CREATE DATABASE BACKUP
echo "$(tput setaf 2)"'Create Backup with filename: ' "$(tput setaf 3)""$FILENAME""$(tput sgr0)"

create database "$databaseName"
docker exec -i "$containerid" pg_restore --clean --no-owner -U docker --create -d "$databaseName" < "$FILENAME"
 
echo "$(tput setaf 6)"DONE: "$(tput setaf 3)""$(tput bold)"'Please Check Backup file before carrying on!' "$(tput sgr0)"

