**PatchDBTool Description**
* * * * * * * *
**Read all instructions before running any patches on the database**
**Don't run the patches if you are not sure what is going to happen**
**Be sure your backup is valid**


This sections describes how to set up and use the PatchDBTool. The PatcDBTool contains 3 bash scripts to deploy postgres patches to an existing database. The tools
are:
- BackupTool
- PatchDB
- Restore

**Some important informations**
- Running the BackupTool will create a backup for the given database and store it on the folder **/BackupTool/Backups**
- Running the PatchDB will runs the patches located on the **/PatchDBTool/PatchDB/ToBePatched**. Once the patch file was successful installed, the file is going to be moved to **/PatchDBTool/PatchDB/Archive**. In error case the file won't be moved.

**VERY IMPORTANT: Patch files MUST follow the naming convention below:**
- Name convention for Patch Files: **projectname_databasename_VpatchnumberV_executiondate.sql**
- Example: iuno_marketplacecore_V0001V_20170915.sql
- The patchnumber MUST be placed between an initial and a final V (this is the delimiter for the script file)
- The patchnumber should be increased by 1 for the next patch.
- A Change-Log needs to be created for each database
    - MarketplaceCore [Change-Log](https://github.com/IUNO-TDM)
    - OAuthDB [Change-Log](https://github.com/IUNO-TDM)
- The initial patch file is a special case and has a different naming convention.

* * * * * * * * *
**SET UP**

1. Step - Copy the .tar file to your system
2. Step - un zip the file to your system
3. Set the PATHS in the Configuration Section for each Tool
    - BackupTool
    - PatchDB
    - RestoreDB

* * * * * * * * *

**Running the PatchDBTool**
1. STEP - RUN Backup Script (BackupDatabase.sh)
- Open Bash Terminal
- copy containerid for the db container (e.g. 33d2881d4537)
- run command "chmod +x <pathToBackupScript> (e.g. /BackupTool/BackupDatabase.sh)"
- run command "<pathToBackupScript> (e.g. ./BackupTool/BackupDatabase.sh)"
- enter docker containerid and press ENTER
- enter Databasename and press ENTER
* * * * * * * * *
2. STEP - Check Database Backup
- Check if the backup exists and file size is plausible
* * * * * * * * *
3. STEP - Copy the patch files
- Copy the patch files from local system to: ../PatchDBTool/PathDB/ToBePatched folder
* * * * * * * * *
4. STEP - RUN Patch Script (PatchDB.sh)
- Open Bash Terminal
- run command "chmod +x <pathToPatchDBTool> (e.g. /PatchDB/PatchDB.sh)"
- run command ./PatchDB.sh
- Proof if all Patches were installed and moved to the /PatchDB/Archive folder
* * * * * * * * *
**RECOVER the Database - If any problem occurs, you may restore the old database**
1. STEP - RUN the RESTORE Script (RestoreDB.sh)
- Open Bash Terminal
- run command "docker ps -a"
- copy containerid for the db container (e.g. tdmdocker_core-db)
- run command "chmod +x /RestoreDB/RestoreDB.sh"
- set containerid as parameter as well as the databasename and the Backup path and press ENTER
- Proof if the database was restored correctly

