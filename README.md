**PatchDBTool Description**
* * * * * * * *
**Read all instructions before running any patches on the database**
**Don't run the patches if you are not sure what is going to happen**
**Be sure your backup is valid**


This sections describes how to set up and use the PatchDBTool. The PatchDBTool contains 3 bash scripts to deploy postgres patches to an existing database. The tools
are:
- backup
- patch
- restore

**Some important informations**
- Running the backup will create a backup for the given database and store it on the folder **/backups**
- Running the PatchDB will runs the patches located on the **/patches**. Once the patch file was successful installed, the file is going to be moved to **/archive**. In error case the file won't be moved.

**VERY IMPORTANT: Patch files MUST follow the naming convention below:**
- Name convention for Patch Files: **projectname_databasename_VpatchnumberV_executiondate.sql**
- Example: iuno_marketplacecore_V0001V_20170915.sql
- The patchnumber MUST be placed between an initial and a final V (this is the delimiter for the script file)
- The patchnumber should be increased by 1 for the next patch.
- A Change-Log needs to be created for each database
    - MarketplaceCore [Change-Log](https://github.com/IUNO-TDM/MarketplaceCore/tree/master/database/patches)
    - OAuthDB [Change-Log (Coming soon...)](https://github.com/IUNO-TDM)
- The initial patch file is a special case and has a different naming convention.
- Create Patch files using the [SQL_Template_for_Patches.sql](https://github.com/IUNO-TDM/PatchDBTool/blob/master/PatchDBTool/SQL_Template_for_Patches.sql) file

* * * * * * * * *

**Running the PatchDBTool**
1. STEP - RUN Backup Script (backup.sh)
- Open Bash Terminal
- run command "chmod +x backup.sh"
- run command "./backup.sh"
- ** follow the instructions **
* * * * * * * * *
2. STEP - Check Database Backup
- Check if the backup exists and file size is plausible
* * * * * * * * *
3. STEP - Copy the patch files
- Copy the patch files from local system to your target system **/patches** folder
* * * * * * * * *
4. STEP - RUN Patch Script (patch.sh)
- Open Bash Terminal
- run command "chmod +x patch.sh"
- run command ./patch.sh
- ** follow the instructions **
- Check if all Patches were installed and moved to the **/archive** folder
* * * * * * * * *
**RECOVER the Database - If any problem occurs, you may restore the old database**
1. STEP - RUN the RESTORE Script (restore.sh)
- Open Bash Terminal
- run command "chmod +x restore.sh"
- run command ./restore.sh
- ** follow the instructions **
- Check if the database was restored correctly

