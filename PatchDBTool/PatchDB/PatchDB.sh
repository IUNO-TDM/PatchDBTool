#!/bin/bash

#CONSTANTS
databaseName='MarketplaceCore'
userName='docker'
hostName='localhost'
port=5433

#PATHS
toBePatched=/home/ubuntu/PatchDBTool/PatchDB/ToBePatched/
archiveFolder=/home/ubuntu/PatchDBTool/PatchDB/Archive/

#MESSAGES 
backupOk='Great!'
noBackup='Oh oh!'
invalidInput='invalid input'
backupDone='Did you created a BACKUP?'
checkDep='Checking patch number and dependencies for'
runPatches='All patches are going to be installed. Wait till the processed is stopped!'

#SQL Statements
initialPatch=/home/ubuntu/PatchDBTool/PatchDB/ToBePatched/iuno_marketplacecore_VinitialV_20170914.sql
checkPatchTable="SELECT 1 FROM   information_schema.tables WHERE  table_schema = 'public' AND table_name = 'patches';"
checkCurrPatchNumber="SELECT max(patchnumber) as patchnumber from patches where patchnumber<="
updatePatchTable="INSERT INTO patches (patchid,patchname,patchnumber,createdat) VALUES"

#FUNCTIONS
function getPatchVersion() {
	
	 #Check if Patch Table exists. If don't Patch initial needs to be used
	 patchTable=$(psql --host "$hostName" --port "$port" -U "$userName" -d "$databaseName" -t -c "$checkPatchTable")
	 echo $patchTable ' ' $patchNumber
	
	#Does the patch table exists? AND is the patchNumber <> initial?
	if [[ $patchTable = 1 && $patchNumber = 'initial' ]]; then
		echo 'Patch table already exists'
		exit
	fi

	#Does the patch table exists? IF not just created - require initial patch
	if [[ $patchTable != 0  && $patchNumber = "initial" ]]; then
		echo 'Run initial patch'
		psql --host "$hostName" --port "$port" -U "$userName" -d "$databaseName" -f "$toBePatched""$filename"
		mv "$toBePatched""$filename" "$archiveFolder""$filename"
		echo 'Created patches tables'
	fi

	#If patch table available, run patches and patch <> inital
	if [[ $patchTable = 1 && $patchNumber != "initial" ]]; then
	local resultValue=$(psql --host "$hostName" --port "$port" -U "$userName" -d "$databaseName" -t -c "$checkCurrPatchNumber""$patchNumber")
	echo "$resultValue"	 		
		 if [ "$patchNumber" <= "$resultValue" ]; then
			echo "ERROR: verify your patch number. Patch number is lower then current!" 		
		 fi
		 if [ $? -ne 0 ]; then
		    echo FAIL
		    exit
		  fi	 
	fi

}

function runPatches() {	
	for file in "$toBePatched"*; do
  	 filename=${file##*/}  
	 patchNumber="$(echo $filename|cut -d'V' -f 2)"
         query="$(psql --host localhost --port 5433 -U docker -d MarketplaceCore -f "$toBePatched""$filename")"	 
	 echo 'QUERY: '$query
	#Error Handling
 	if [ -z "$query" ]; then
	    echo "$(tput bold)""$(tput setaf 1)"' FAIL'"$(tput setaf 3)" 'to run patch patch file: ' "$filename" '. Verify your patch file or RESTORE your database.'"$(tput sgr0)" 
	    exit	
	    else updatePatchTable	 
	 fi
  done

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

}

function updatePatchTable() {	 
	# 4 - Update Patch Table
	date=`date +%Y-%m-%d`
	time=`date +%H:%M:%S`
	datetime="'${date} ${time}'"
	echo $datetime
	patchid=1
	query="${updatePatchTable}(${patchid},'${filename}',${patchNumber},${datetime})"
	echo $query
	psql --host "$hostName" --port "$port" -U "$userName" -d "$databaseName" -t -c "$query"
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
			runPatches
			#Update patch table
			updatePatchTable
			#Move the patch files to the Archive
			moveFilesToArchive
		elif [ "$result" == "n" ];then	
			exit
		else
			echo $invalidInput
			exit
	fi
exit 1




