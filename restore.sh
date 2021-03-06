#!/bin/bash
#TODO: Error handling!


echo "$(tput bold)""$(tput setaf 1)"'Get Docker containerid: RUNNING docker ps -a'"$(tput sgr0)"
#GET ALL CONTAINERID
docker ps -a
echo -n "$(tput bold)""$(tput setaf 3)""Done! Copy and Enter ContainerID: " 
read containerid

echo -n "Enter absolute path to backup file that should be restored: "
read FILENAME

echo -n "Enter Database name: "
read databaseName

echo -n "Enter username: "
read userName


echo "$(tput setaf 2)"'Restore Database for Docker ContainerID: ' "$(tput setaf 3)" $containerid "$(tput setaf 2)" ' and Database: ' "$(tput setaf 3)"${databaseName} "$(tput sgr0)"

#GET DATE AND TIME FOR FILENAME
DATE=`date +%Y-%m-%d`
TIME=`date +%H:%M:%S` 


#RESTORE DATABASE
echo "$(tput setaf 2)"'Restore Database with filename: ' "$(tput setaf 3)""$FILENAME""$(tput sgr0)"

#Get the database password
echo -n $"$(tput setaf 3)""Enter Database Password:""$(tput sgr0)"  $'\n'
read -s password 

echo -n $"$(tput bold)""$(tput setaf 1)""POINT OF NO RETURN! Are you really sure?""$(tput sgr0)"  $'\n'
read -p "(y/n):" result
		if [ "$result" != "y" ];then		
			exit
		fi
#Cut all connections
echo Revoke other connections to the database: ${databaseName}
docker exec -i -e PGPASSWORD="$password" "$containerid" psql -U "$userName" -d "$databaseName" -t -c "REVOKE CONNECT ON DATABASE "\"${databaseName}\"" FROM public;"
echo Close all connections to database except our own
docker exec -i -e PGPASSWORD="$password" "$containerid" psql -U "$userName" -d "$databaseName" -t -c "SELECT pid, pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = "\'${databaseName}\'" AND pid <> pg_backend_pid();"
 
#Drop DB
echo Drop old Database
docker exec -i -e PGPASSWORD="$password" "$containerid" dropdb -U "$userName" "$databaseName"
if [ $? != 0 ]; then
	exit
fi
#Create DB
echo Create new Database
docker exec -i -e PGPASSWORD="$password" "$containerid" createdb -U "$userName" "$databaseName"
if [ $? != 0 ]; then
	exit
fi
#Restore database
echo Restore Database
docker exec -i -e PGPASSWORD="$password" "$containerid" pg_restore -U "$userName" -d "$databaseName" < "$FILENAME"
if [ $? != 0 ]; then
	exit
fi
echo "$(tput setaf 6)"DONE: "$(tput setaf 3)""$(tput bold)"'Restore Database done!' "$(tput sgr0)"

