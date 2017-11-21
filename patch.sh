#!/bin/bash

#PATCH_FOLDERS
toBePatched="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/patches/"
archiveFolder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/archive/"

#MESSAGES 
backupOk='Great!'
noBackup='Oh oh!'
invalidInput='invalid input'
backupDone='Did you created a BACKUP?'
checkDep='Checking patch number and dependencies for'
runPatches='All patches are going to be installed. Wait till the processed is stopped!'

#SQL Statements 
checkPatchTable="SELECT 1 FROM   information_schema.tables WHERE  table_schema = 'public' AND table_name = 'patches';"
checkCurrPatchNumber="SELECT max(patchnumber) as patchnumber from patches where patchnumber<=" 

#FUNCTIONS
function getPatchVersion() { 
	 echo "Check Patch Version"
	 #Check if Patch Table exists. If don't Patch initial needs to be used
	 patchTable=$(docker exec -i -e PGPASSWORD=$password "$containerid" psql -U "$userName" -d "$databaseName" -t -c "$checkPatchTable")
	 if [ $? != 0 ]; then
		exit
	 fi

	#Does the patch table exists? AND is the patchNumber <> initial?
	if [[ $patchTable = 1 && $patchNumber = 'initial' ]]; then
		echo 'Patch table already exists'
		exit
	fi

    #Copy all patches in container

    docker exec -i "$containerid" rm -rf patches
	docker cp "$toBePatched" "$containerid":/patches/

	#Does the patch table exists? IF not just created - require initial patch	
	if [[ $patchTable != 0  && $patchNumber = "initial" ]]; then
		echo 'Run initial patch'
		docker exec -i -e PGPASSWORD=$password "$containerid" psql -U "$userName" -d "$databaseName" -f "/patches/""$filename"
		mv "$toBePatched""$filename" "$archiveFolder""$filename"
		echo 'Created patches tables'
	fi
	

	#Check Version Number
	if [[ $patchTable != 0 && $patchNumber != 'initial' ]]; then	
	resultValue=$(docker exec -i -e PGPASSWORD=$password "$containerid" psql -U "$userName" -d "$databaseName" -t -c "$checkCurrPatchNumber""$patchNumber")

		if [[ $((10#$patchNumber)) -lt $resultValue || $((10#$patchNumber)) -eq $resultValue ]]; then
			echo "ERROR: verify your patch number. Patch number is lower or equal than the latest!" 	
			exit 
		fi 
	fi
	echo "$(tput setaf 2)"'GetPatchVersion done - OK'"$(tput sgr0)"

}

function runPatches() {	
	for file in "$toBePatched"*; do
  	 filename=${file##*/}  
	 patchNumber="$(echo $filename|cut -d'V' -f 2)"
         query=$(docker exec -i -e PGPASSWORD=$password "$containerid" psql -U "$userName" -d "$databaseName" -f "/patches/""$filename")

	#Error Handling
 	if [ -z "$query" ]; then
	    echo "$(tput bold)""$(tput setaf 1)"' FAIL'"$(tput setaf 3)" 'to run patch patch file: ' "$filename" '. Verify your patch file or RESTORE your database.'"$(tput sgr0)" 
	    exit	 
	 fi
	done
	
	echo "$(tput setaf 2)"'RunPatches done - OK'"$(tput sgr0)"

}

function moveFilesToArchive() {	
	for file in "$toBePatched"*; do
  	 filename=${file##*/}   
         mv "$toBePatched""$filename" "$archiveFolder""$filename"
 
	#Error Handling
 	 if [ $? -ne 0 ]; then
	    echo FAIL to move files to Archive
	    exit
	  fi	
	 done
	
 	echo "$(tput setaf 2)"'MoveFilesToArchive done - OK'"$(tput sgr0)"

}
 
#PROGRAM FLOW
# 1 - Is the Backup done?
echo $backupDone
	read -p "(y/n):" result
		if [ "$result" == "y" ];then
			echo $backupOk
		elif [ "$result" == "n" ];then
			echo $noBackup
			exit
		else
			echo $invalidInput
			exit
	fi

# 2 - Get config parameters

echo "$(tput bold)""$(tput setaf 1)"'Get Docker containerid: RUNNING docker ps -a'"$(tput sgr0)"
#GET ALL CONTAINERID
docker ps -a
echo -n "$(tput bold)""$(tput setaf 3)""Done! Copy and Enter ContainerID: "
read containerid

echo -n "Enter Database name: "
read databaseName

echo -n "Enter username: "
read userName


# 3 - Once Backup is there, check the Patch files and dependecies
echo $checkDep
	#Get the database password
	echo -n $"$(tput setaf 3)""Enter Database Password:""$(tput sgr0)"  $'\n'
	read -s password 
	PGAPASSWORD=$password;
	
	 #Proof if password isn't null
 	 if [ -z $password ]; then
		echo 'Password is null'
		exit
	 fi

	#Iterate over files
	for file in "$toBePatched"*; do
	  filename=${file##*/}  
	  echo "$(tput setaf 3)"$filename"$(tput sgr0)"
	  patchNumber="$(echo $filename|cut -d'V' -f 2)"

	  #Check the patchnumber against the current installed patch
	  getPatchVersion $patchNumber	  
	done


# 3 - IF all patches are OK, then start running the patches
echo $runPatches
	read -p "(y/n):" result
		if [ "$result" == "y" ];then
			#Run the patches
			runPatches
			#Move the patch files to the Archive
			moveFilesToArchive				
		elif [ "$result" == "n" ];then	
			exit
		else
			echo $invalidInput
			exit
	fi
	echo "$(tput setaf 3)"'All done - OK'"$(tput sgr0)"	
exit 1




