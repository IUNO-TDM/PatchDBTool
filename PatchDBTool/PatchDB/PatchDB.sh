#!/bin/bash

#Get Config file
. ./PatchDB.config

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
updatePatchTable="INSERT INTO patches (patchname,patchnumber,executedat) VALUES "

#FUNCTIONS
function getPatchVersion() { 
	 echo "Check Patch Version"
	 #Check if Patch Table exists. If don't Patch initial needs to be used	 	 
	 patchTable=$(PGPASSWORD=$password psql --host "$hostName" --port "$port" -U "$userName" -d "$databaseName" -t -c "$checkPatchTable")
	 if [ $? != 0 ]; then
		exit
	 fi

	#Does the patch table exists? AND is the patchNumber <> initial?
	if [[ $patchTable = 1 && $patchNumber = 'initial' ]]; then
		echo 'Patch table already exists'
		exit
	fi

	#Does the patch table exists? IF not just created - require initial patch	
	if [[ $patchTable != 0  && $patchNumber = "initial" ]]; then
		echo 'Run initial patch'
		PGPASSWORD=$password psql --host "$hostName" --port "$port" -U "$userName" -d "$databaseName" -f "$toBePatched""$filename"
		mv "$toBePatched""$filename" "$archiveFolder""$filename"
		echo 'Created patches tables'
	fi
	

	#Check Version Number
	if [[ $patchTable != 0 && $patchNumber != 'initial' ]]; then	
	resultValue=$(PGPASSWORD=$password psql --host "$hostName" --port "$port" -U "$userName" -d "$databaseName" -t -c "$checkCurrPatchNumber""$patchNumber")

		if [[ $(($patchNumber+0)) -lt $resultValue || $(($patchNumber+0)) -eq $resultValue ]]; then
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
         query=$(PGPASSWORD=$password psql --host "$hostName" --port "$port" -U "$userName" -d "$databaseName" -f "$toBePatched""$filename")

	#Error Handling
 	if [ -z "$query" ]; then
	    echo "$(tput bold)""$(tput setaf 1)"' FAIL'"$(tput setaf 3)" 'to run patch patch file: ' "$filename" '. Verify your patch file or RESTORE your database.'"$(tput sgr0)"
	    exit
	    else updatePatchTable
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

function updatePatchTable() {
	# 4 - Update Patch Table
	date=`date +%Y-%m-%d`
	time=`date +%H:%M:%S`
	datetime="'${date} ${time}'"
	query="${updatePatchTable}('${filename}',${patchNumber},${datetime})"

	PGPASSWORD=$password psql --host "$hostName" --port "$port" -U "$userName" -d "$databaseName" -t -c "$query"

	echo "$(tput setaf 2)"'UpdatePatchTable done - OK'"$(tput sgr0)"
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

# 2 - Once Backup is there, check the Patch files and dependecies
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