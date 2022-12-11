@echo off
color 0b

:: Settings
:: Permenant configuration file coming... soon? I am not sure.

:: Here you can disable/enable automatic updates, true/false (default is true)
set automaticupdatecheck=true
:: Here you can disable/enable backing up the old Atlas folder, true/false (default is true)
set backup=true

:: You shouldn't need to change anything from here
set version=1.4
title Atlas Update Script - Made by he3als - Version: %version%

where curl >nul 2>&1
if not %errorlevel%==0 (
	echo cURL is not found, please install it by adding the executable to PATH.
	echo Alternatively, you can install it with the Scoop package manager.
	echo]
	echo cURL should be installed by default on Windows 10 1803 and above.
	pause
	exit /b 1
)

fltmc >nul 2>&1 || (
    echo Administrator privileges are required.
    PowerShell -NoProfile Start -Verb RunAs '%0' 2> nul || (
        echo Right-click on the script and select 'Run as administrator'.
        pause & exit 1
    )
    exit 0
)

:checkforupdates1
if %automaticupdatecheck%==false set updated=disabled && goto versiondisplay
del /f /q "%TEMP%\VERSIONATLASUPDATER" >nul 2>&1
curl -s "https://raw.githubusercontent.com/he3als/AtlasUpdater/main/VERSIONATLASUPDATER" -o "%TEMP%\VERSIONATLASUPDATER" > nul
if %errorlevel%==0 (goto checkforupdates2) else (
	cls
	set updated=failed
	echo Failed checking for updates!
	echo]
	echo You could be offline or the repo may be inaccessible.
	echo You can disable update checking by editing the variables at the top of the batch script.
	pause
	goto versiondisplay
)

:checkforupdates2
:: Check if there was an error like '404: Not found'
findstr /r /c:[a-z] /c:":" "%TEMP%\VERSIONATLASUPDATER" >nul 2>&1
if %errorlevel%==0 (
	set updated=failed
	echo Failed checking for updates!
	echo]
	echo The repository is seemingly inaccessible.
	echo You can disable update checking by editing the variables at the top of the batch script.
	pause
	goto versiondisplay
)
findstr /c:"%version%" "%TEMP%\VERSIONATLASUPDATER" >nul 2>&1
if %errorlevel%==0 (
	set updated=true
	del /f /q "%TEMP%\VERSIONATLASUPDATER" >nul 2>&1
	goto versiondisplay
) else (goto updateavaliable)

:updateavaliable
for /f %%a in (%TEMP%\VERSIONATLASUPDATER) do set newversionnumber=%%a
set updated=false
echo Tip: You can disable automatic update checking by changing the value at the top of this script.
echo An update was found!
echo]
choice /n /c:YN /m "Would you like to download the latest version of the script and output it to your Downloads folder? [Y/N]"
if %errorlevel%==1 goto update
if %errorlevel%==2 goto versiondisplay

:update
cls
setlocal enabledelayedexpansion
if exist "%userprofile%\Downloads\AtlasUpdaterScript_%newversionnumber%.bat" (
	echo It seems like the updated script already is in your Downloads folder.
	echo]
	choice /n /c:yn /m "Would you like to replace it? [Y/N] "
	if !errorlevel!==1 (del /f /q "%userprofile%\Downloads\AtlasUpdaterScript_%newversionnumber%.bat")
)
setlocal disabledelayedexpansion
curl -s "https://raw.githubusercontent.com/he3als/AtlasUpdater/main/AtlasUpdaterScript.bat" -o "%userprofile%\Downloads\AtlasUpdaterScript_%newversionnumber%.bat"
if %errorlevel%==0 (echo Downloaded new script...) ELSE (
	echo Failed downloading the new script!
	pause
	exit /b 1
)

:downloadFinished
echo Finished updating!
echo]
echo What would you like to do?
echo 1) Execute the new script and exit
echo 2) Exit
choice /n /c:12 /m "Please input your answer ->"
if %errorlevel%==1 start "" "%userprofile%\Downloads\AtlasUpdaterScript_%newversionnumber%.bat" & exit /b 0
if %errorlevel%==2 exit /b 0

:versiondisplay
cls
color 0b
if %updated%==true (echo Up to date!) else (echo Outdated version!)
if %updated%==false (echo New Version: %newversionnumber%)
if %updated%==failed (echo Checking for updates failed!)
if %updated%==disabled (echo Checking for updates disabled!)
echo Current Version: %version%
echo]

:menu
echo WARNING: You are responsible for your actions with this script.
echo]
echo This script is for https://github.com/Atlas-OS/Atlas - a Windows modification.
echo]
echo What would you like to do?
echo 1) Run the post-install script again (unsupported)
echo 2) Update the Atlas desktop folder and AtlasModules folder
echo 3) Visit the Atlas GitHub repository
echo 4) Visit the AtlasUpdater GitHub repostiory
echo 5) Exit
choice /n /c:12345 /m "Please input your answer here ->"
if %errorlevel%==1 goto postinstall
if %errorlevel%==2 goto updatefolders
if %errorlevel%==3 start "" "https://github.com/Atlas-OS/Atlas" & cls & goto versiondisplay
if %errorlevel%==4 start "" "https://github.com/he3als/AtlasUpdater" & cls & goto versiondisplay
if %errorlevel%==5 exit /b 0

:postinstall
if not exist "%windir%\AtlasModules\atlas-config.bat" (
	echo]
	echo 'atlas-config.bat' is not found.
	echo You can not continue.
	pause
	goto versiondisplay
)
cls
echo You should update Atlas' folders before doing this, doing this is dangerous and can cause issues!
choice /n /c:YN /m "Continue? [Y/N]"
if %errorlevel%==2 goto versiondisplay

cls
color 4F
echo Are you 100% sure? 
echo]
echo This will re-run the post install script that first runs when you install Atlas, and this is potentially dangerous to do.
echo The post install script is not intended to be used in this way, so this is at your own risk. It should be fine though.
echo]
echo This is like updating Atlas in a way, except from that it mostly updates the tweaks. It does NOT update:
echo - Windows (updates, anticheat compatibility)
echo - Components (adding/removing, etc)
echo - Anything, if you have not updated AtlasModules and the desktop folder (check the main menu of the script)
echo]
echo Waiting 4 seconds to read, then you will be prompted to continue or not...
timeout /T 4 /NOBREAK > nul
choice /n /c:YN /m "Continue? [Y/N]"
if %errorlevel%==1 start "" "nsudo.exe -U:T -P:E -Wait %windir%\AtlasModules\atlas-config.bat /start"
if %errorlevel%==2 goto versiondisplay

:updatefolders
cls
if %backup%==true (
	echo Warning: Your current Atlas folder will be backed up and renamed.
	echo If there is a previous backup, it will be renamed to something like Atlas_Backup_1.
) else (
	echo Warning: Your current Atlas folder on your desktop and AtlasModules will be deleted permenantly!
)
choice /n /c:YN /m "Continue? [Y/N]"
if %errorlevel%==1 goto updatefolders1
if %errorlevel%==2 goto versiondisplay

:updatefolders1
echo]
rd /s /q %TEMP%\tempatlas >nul 2>&1
del /f %TEMP%\tempatlas.zip >nul 2>&1
echo Downloading the Atlas repository...
curl -L -s "https://github.com/Atlas-OS/Atlas/archive/refs/heads/main.zip" -o "%TEMP%\tempatlas.zip"
if %errorlevel%==0 (echo Downloaded Atlas zip successfully.) else (echo Failed downloading Atlas zip. & pause & exit /b 1)
where 7z >nul 2>&1
if not %errorlevel%==0 (
	powershell -NoProfile -Command "Expand-Archive '%TEMP%\tempatlas.zip' -DestinationPath '%TEMP%\tempatlas' -Force"
) else (
	7z x "%TEMP%\tempatlas.zip" -o"%TEMP%\tempatlas" -y > nul
)
if not %errorlevel%==0 (echo Failed extracting Atlas zip. & pause & exit /b 1) ELSE (echo Expanded the Atlas zip successfully.)
if not exist "%windir%\AtlasModules" goto copyfolders
if %backup%==true (goto backupfolders) else (goto delfolders)

:backupfolders
if exist "%windir%\AtlasModules_Backup" (set counter=1 & goto renameAtlasModulesBackup)
if exist "%userprofile%\Desktop\Atlas_Backup" (set counter=1 & goto renameAtlasDesktopBackup)

ren "%userprofile%\Desktop\Atlas" "Atlas_Backup"
if %errorlevel%==0 (
	echo Renamed old Atlas desktop folder.
) ELSE (
	echo Failed renaming old Atlas desktop folder, it may not exist.
	echo Things might break if you continue!
	pause
)

ren "%windir%\AtlasModules" "AtlasModules_Backup"
if %errorlevel%==0 (
	echo Renamed old AtlasModules folder.
) ELSE (
	echo Failed renaming old AtlasModules folder, it may not exist.
	echo Things might break if you continue!
	pause
)
goto copyfolders

:delfolders
rd /s /q %userprofile%\Desktop\Atlas > nul
if %errorlevel%==0 (
	echo Deleted Atlas desktop folder.
) ELSE (
	echo Failed deleting Atlas desktop folder, it may not exist.
	echo Things might break if you continue!
	pause
)
rd /s /q %windir%\AtlasModules
if %errorlevel%==0 (
	echo Deleted AtlasModules folder.
) ELSE (
	echo Failed deleting AtlasModules folder, it may not exist.
	echo Things might break if you continue!
	pause
)
goto copyfolders

:copyfolders
xcopy "%TEMP%\tempatlas\Atlas-main\src\AtlasModules" "%windir%\AtlasModules" /e /i /h /k /y /q > nul
if %errorlevel%==0 (echo Copied AtlasModules folder) ELSE (echo Failed copying the AtlasModules folder. & pause & exit /b 1)
xcopy "%TEMP%\tempatlas\Atlas-main\src\Desktop\Atlas" "%userprofile%\Desktop\Atlas" /e /i /h /k /y /q > nul
if %errorlevel%==0 (echo Copied Atlas desktop folder) ELSE (echo Failed copying the Atlas desktop folder. & pause & exit /b 1)

rd /s /q "%TEMP%\tempatlas" > nul
if %errorlevel% NEQ 0 (echo Failed deleting temporary Atlas folder!)
del /f /q "%TEMP%\tempatlas.zip" > nul
color 0a
echo]
echo Completed!
pause
goto versiondisplay

:renameAtlasModulesBackup
if not exist "%windir%\AtlasModules_Backup_%counter%" (
	ren "%windir%\AtlasModules_Backup" "AtlasModules_Backup_1"
	echo Attempted to rename old AtlasModules backup to AtlasModules_Backup_%counter%...
	goto backupfolders
) else (
	set /a counter=%counter%+1 > nul
	goto renameAtlasModulesBackup
)

:renameAtlasDesktopBackup
if not exist "%userprofile%\Desktop\Atlas_Backup_%counter%" (
	ren "%userprofile%\Desktop\Atlas_Backup" "Atlas_Backup_%counter%"
	echo Attempted to rename old Atlas desktop backup to Atlas_Backup_%counter%...
	goto backupfolders
) else (
	set /a counter=%counter%+1 > nul
	goto renameAtlasDesktopBackup
)