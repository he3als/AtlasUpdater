@echo off
color 0b

:: Settings
:: Permenant configuration file coming... soon? I am not sure.

:: Here you can disable/enable automatic updates, true/false (default is true)
set automaticupdatecheck=true
:: Here you can disable/enable backing up the old Atlas folder, true/false (default is true)
set backup=true

:: You shouldn't need to change anything from here
set version=1.0
title Atlas Update Script - Made by he3als - Version: %version%
fltmc >nul 2>&1 || (
    echo Administrator privileges are required.
    PowerShell -NoProfile Start -Verb RunAs '%0' 2> nul || (
        echo Right-click on the script and select "Run as administrator".
        pause & exit 1
    )
    exit 0
)

:checkforupdatesa
if %automaticupdatecheck%==false set updated=disabled && goto versiondisplay
del /f %TEMP%\Downloads\VERSIONATLASUPDATER >nul 2>&1
Powershell.exe -NoProfile -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/he3als/AtlasUpdater/main/VERSIONATLASUPDATER' -OutFile %TEMP%\VERSIONATLASUPDATER"
if %ERRORLEVEL%==0 (
	echo Downloaded VERSIONATLASUPDATER file to check if there's updates...
	echo.
	goto checkforupdatesb
) ELSE (
	cls
	set updated=failed
	echo Failed checking for updates!
	echo You could be offline or the repository may be inaccessable.
	echo You can disable update checking by editing the batch script.
	echo You will now be taken to the menu.
	pause
	goto versiondisplay
)

:checkforupdatesb
findstr /c:"%version%" "%TEMP%\VERSIONATLASUPDATER"
if %ERRORLEVEL%==0 (
	set updated=true
	del /f %TEMP%\Downloads\VERSIONATLASUPDATER
	goto versiondisplay
) ELSE (
	goto updateavaliable
)

:updateavaliable
for /f %%i in ('Powershell.exe -NoProfile -NoLogo -Command "Get-Content %TEMP%\Downloads\VERSIONATLASUPDATER -First 1"') do set newversionnumber=%%i
set updated=false
echo Tip: You can disable automatic update checking by easily editing the batch script.
echo An update was found!
CHOICE /N /C:YN /M "Would you like to download the latest version of the script and output it to your Downloads folder? [Y/N]"
IF %ERRORLEVEL%==1 goto update
IF %ERRORLEVEL%==2 goto versiondisplay

:update
cls
set %ERRORLEVEL%==0
for /f %%i in ('Powershell.exe -NoProfile -NoLogo -Command "Get-Content %TEMP%\Downloads\VERSIONATLASUPDATER -First 1"') do set newversionnumber=%%i
:: Error detection always fails here? Not sure why, the rest of the script seemingly works fine...
:: if %ERRORLEVEL%==0 (echo Set version number in PowerShell...
:: ) ELSE (echo Failed setting version number in PowerShell^!&pause&exit)
Powershell.exe -NoProfile -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/he3als/AtlasUpdater/main/AtlasUpdaterScript.bat' -OutFile %TEMP%\Downloads\AtlasUpdaterScript_$env:newversionnumber.bat"
if %ERRORLEVEL%==0 (
	echo Downloaded new script...
) ELSE (
	echo Failed downloading the new script!
	pause
	exit
)
echo.
echo Finished updating!
echo What would you like to do?
echo 1. Execute the new script and exit
echo 2. Exit
CHOICE /N /C:12 /M "Please input your answer here ->"
IF %ERRORLEVEL%==1 goto openupdatedscript
IF %ERRORLEVEL%==2 goto exit

:openupdatedscript
start "" %TEMP%\AtlasUpdaterScript_%newversionnumber%.bat
color 0a
echo Executed the new script!
exit

:versiondisplay
cls
color 0b
if %updated%==true (echo Up to date!) else (echo Outdated version!)
if %updated%==false (echo New Version: %newversionnumber%)
if %updated%==failed (echo Checking for updates failed!)
if %updated%==disabled (echo Checking for updates disabled!)
echo Current Version: %version%
echo.

:menu
echo Warning: This script can do un-wanted changes to your computer, use with caution and review the script first!
echo This script is for https://github.com/Atlas-OS/Atlas - a Windows mod for mainly gaming.
echo What would you like to do?
echo 1. Run the post-install script again ^(dangerous^)
echo 2. Update the Atlas desktop folder and AtlasModules folder
echo 3. Visit the Atlas repository
echo 4. Visit the Atlas Updater repostiory
echo 5. Exit
CHOICE /N /C:12345 /M "Please input your answer here ->"
IF %ERRORLEVEL%==1 goto postinstall
IF %ERRORLEVEL%==2 goto updatefolders
IF %ERRORLEVEL%==3 start "" "https://github.com/Atlas-OS/Atlas" & cls & goto versiondisplay
IF %ERRORLEVEL%==4 start "" "https://github.com/he3als/AtlasUpdater" & cls & goto versiondisplay
IF %ERRORLEVEL%==5 exit

:postinstall
cls
echo You should update Atlas^' folders before doing this, doing this is dangerous and can cause issues!
CHOICE /N /C:YN /M "Continue? [Y/N]"
IF %ERRORLEVEL%==1 goto postinstallconfirm
IF %ERRORLEVEL%==2 goto versiondisplay

:postinstallconfirm
cls
color 4F
echo Are you 100^% sure? 
echo This will run the post install script that first runs when you install Atlas and this is potentially dangerous to do.
timeout /T 10 /NOBREAK
CHOICE /N /C:YN /M "Continue? [Y/N]"
IF %ERRORLEVEL%==1 start "" "C:\Windows\AtlasModules\nsudo.exe -U:T -P:E -Wait C:\Windows\AtlasModules\atlas-config.bat /start"
IF %ERRORLEVEL%==2 goto versiondisplay

:updatefolders
cls
if %backup%==true (
	echo Warning: Your current Atlas folder will be backed up and renamed.
	echo If there is a previous backup, it will be deleted.
) ELSE (
	echo Warning: Your current Atlas folder on your desktop and AtlasModules will be deleted permenantly!
)
CHOICE /N /C:YN /M "Continue? [Y/N]"
IF %ERRORLEVEL%==1 goto updatefoldersconfirmed
IF %ERRORLEVEL%==2 goto versiondisplay

:updatefoldersconfirmed
echo.
:: No error detection as they may not exist
rd /s /q %TEMP%\tempatlas >nul 2>&1
del /f %TEMP%\tempatlas.zip >nul 2>&1
Powershell.exe -NoProfile -Command "Invoke-WebRequest -Uri 'https://github.com/Atlas-OS/Atlas/archive/refs/heads/main.zip' -OutFile '%TEMP%\tempatlas.zip'"
if %ERRORLEVEL%==0 (echo Downloaded Atlas zip successfully.) ELSE (echo Failed downloading Atlas zip.&pause&exit)
Powershell.exe -NoProfile -Command "Expand-Archive '%TEMP%\tempatlas.zip' -DestinationPath '%TEMP%\tempatlas' -Force"
if %ERRORLEVEL%==0 (echo Expanded the Atlas zip successfully.) ELSE (echo Failed extracting Atlas zip.&pause&exit)
if %backup%==true (goto backupfolders) else (goto delfolders)

:backupfolders
rd /s /q %USERPROFILE%\Desktop\Atlas_Backup >nul 2>&1
rd /s /q C:\Windows\AtlasModules_Backup >nul 2>&1
echo Attempted to delete previous backups...
ren %USERPROFILE%\Desktop\Atlas Atlas_Backup
if %ERRORLEVEL%==0 (
	echo Renamed old Atlas desktop folder
) ELSE (
	echo Failed renaming old Atlas desktop folder, it may not exist.
	echo Things might break if you continue^!
	pause
)
ren C:\Windows\AtlasModules AtlasModules_Backup
if %ERRORLEVEL%==0 (
	echo Renamed old AtlasModules folder
) ELSE (
	echo Failed renaming old AtlasModules folder, it may not exist.
	echo Things might break if you continue^!
	pause
)
goto copyfolders

:delfolders
rd /s /q %USERPROFILE%\Desktop\Atlas
if %ERRORLEVEL%==0 (
	echo Deleted Atlas desktop folder
) ELSE (
	echo Failed deleting Atlas desktop folder, it may not exist.
	echo Things might break if you continue^!
	pause
)
rd /s /q C:\Windows\AtlasModules
if %ERRORLEVEL%==0 (
	echo Deleted AtlasModules folder
) ELSE (
	echo Failed deleting AtlasModules folder, it may not exist.
	echo Things might break if you continue^!
	pause
)
goto copyfolders

:copyfolders
xcopy "%TEMP%\tempatlas\Atlas-main\src\AtlasModules" "C:\Windows\AtlasModules" /e /i /h /k /y /q
if %ERRORLEVEL%==0 (echo Copied AtlasModules folder) ELSE (echo Failed copying the AtlasModules folder.&pause&exit)
xcopy "%TEMP%\tempatlas\Atlas-main\src\Desktop\Atlas" "%TEMP%\Desktop\Atlas" /e /i /h /k /y /q
if %ERRORLEVEL%==0 (echo Copied Atlas desktop folder) ELSE (echo Failed copying the Atlas desktop folder.&pause&exit)
goto deletetemp

:deletetemp
rd /s /q "%TEMP%\tempatlas"
if %ERRORLEVEL% NEQ 0 (echo Failed deleting temporary Atlas folder!)
del /f "%TEMP%\tempatlas.zip"
color 0a
echo.
echo Completed!
pause
goto versiondisplay