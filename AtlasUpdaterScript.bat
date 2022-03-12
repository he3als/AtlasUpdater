@echo off
color 03
:: Here you can disable/enable automatic updates, true/false
set automaticupdatecheck=true
set version=Version: 1.0
set menucls=true
title Atlas Update Script - made by he3als - %version%
fltmc >nul 2>&1 || (
    echo Administrator privileges are required.
    PowerShell -NoProfile Start -Verb RunAs '%0' 2> nul || (
        echo Right-click on the script and select "Run as administrator".
        pause & exit 1
    )
    exit 0
)

:checkforupdatesa
if %automaticupdatecheck%==false goto menu
Powershell.exe -NoProfile -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/he3als/AtlasUpdater/main/VERSION' -OutFile '%USERPROFILE%\Downloads\VERSION'"
if %ERRORLEVEL%==0 (
echo Downloaded VERSION file to check if there's updates...
goto checkforupdatesb
) ELSE (
set updated=failed
echo Failed checking for updates!
echo You could be offline or the repository may be inaccessable.
echo You can disable update checking by editing the batch script.
echo You will now be taken to the menu.
pause
goto menu
)

:checkforupdatesb
findstr /c:"%version%" "%USERPROFILE%\Downloads\VERSION" && (
  set updated=true
  del /f %USERPROFILE%\Downloads\VERSION
  goto versiondisplay
) || (
  for /f %%i in ('findstr /c:"Version" "%USERPROFILE%\Downloads\VERSION"') do set newversion=%%i
  set updated=false
  del /f %USERPROFILE%\Downloads\VERSION
  echo Tip: You can disable automatic update checking by easily editing the batch script.
  echo An update was found!
  echo CHOICE /N /C:YN /M "Would you like to download the latest version of the script and output it to your Downloads folder? [Y/N]"
  IF %ERRORLEVEL%==1 goto update
  IF %ERRORLEVEL%==2 goto menu
)

:update
Powershell.exe -NoProfile -Command "$regex = '[0-9]+.[0-9]+'; select-string -Path %USERPROFILE%\Downloads\VERSION -Pattern $regex -AllMatches | % { $_.Matches } | % { $_.Value } > $env:versionnumberexact"
if %ERRORLEVEL%==0 (echo Set version number in PowerShell...
) ELSE (echo Failed setting version number in PowerShell!&pause&exit)
Powershell.exe -NoProfile -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/he3als/AtlasUpdater/main/AtlasUpdaterScript.bat' -OutFile '%USERPROFILE%\Downloads\AtlasUpdaterScript $env:versionnumberexact.bat'"
if %ERRORLEVEL%==0 (echo Downloaded new script...
) ELSE (echo Failed downloading the new script!&pause&exit)
echo Finished updating!
echo CHOICE /N /C:12 /M "Would you like to exit or execute and exit the updated script? [1/2]"
IF %ERRORLEVEL%==1 goto exit
IF %ERRORLEVEL%==2 goto openupdatedscript

:openupdatedscript
start "" "%USERPROFILE%\Downloads\AtlasUpdaterScript %versionnumberexact%.bat"
if %ERRORLEVEL%==0 (echo Executed the new script!
) ELSE (echo Failed executing the new script!&pause&exit)
pause
exit

:versiondisplay
color 03
cls
set menucls=false
if %updated%==true (echo Up to date!) else (echo Outdated version!)
if %updated%==false (echo New %newversion%)
if %updated%==failed (echo Checking for updates failed!)

:menu
color 03
if %menucls%==true (cls)
echo Current %version%
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
IF %ERRORLEVEL%==3 start "" "https://github.com/Atlas-OS/Atlas" & goto menu
IF %ERRORLEVEL%==4 start "" "https://github.com/he3als/AtlasUpdater" & goto menu
IF %ERRORLEVEL%==5 exit

:postinstall
cls
echo You should update Atlas^' folders before doing this, doing this is dangerous and can cause issues!
CHOICE /N /C:YN /M "Continue? [Y/N]"
IF %ERRORLEVEL%==1 goto postinstallconfirma
IF %ERRORLEVEL%==2 goto menu

:postinstallconfirma
cls
color 4F
echo Are you 100% sure? This will run the post install script that first runs when you install Atlas and this is potentially dangerous to do.
timeout /T 10 /NOBREAK
CHOICE /N /C:YN /M "Continue? [Y/N]"
IF %ERRORLEVEL%==1 start "C:\Windows\AtlasModules\nsudo.exe -U:T -P:E -Wait C:\Windows\AtlasModules\atlas-config.bat /start"
IF %ERRORLEVEL%==2 goto menu

:updatefolders
cls
echo Warning: Your current Atlas folder on your desktop and AtlasModules will be deleted permenantly!
CHOICE /N /C:YN /M "Continue? [Y/N]"
IF %ERRORLEVEL%==1 goto updatefoldersconfirmed
IF %ERRORLEVEL%==2 goto menu

:updatefoldersconfirmed
Powershell.exe -NoProfile -Command "Invoke-WebRequest -Uri 'https://github.com/Atlas-OS/Atlas/archive/refs/heads/main.zip' -OutFile '%USERPROFILE%\Downloads\tempatlas.zip'"
if %ERRORLEVEL%==0 (echo Downloaded Atlas zip successfully.
) ELSE (echo Failed downloading Atlas zip.&pause&exit)
Powershell.exe -NoProfile -Command "Expand-Archive '%USERPROFILE%\Downloads\tempatlas.zip' -DestinationPath '%USERPROFILE%\Downloads\tempatlas' -Force"
if %ERRORLEVEL%==0 (echo Expanded the Atlas zip successfully.
) ELSE (echo Failed extracting Atlas zip.&pause&exit)
goto delfolders

:delfolders
rd /s %USERPROFILE%\Desktop\Atlas
if %ERRORLEVEL%==0 (echo Deleted Atlas desktop folder
) ELSE (echo Failed deleting Atlas desktop folder.&pause&exit)
rd /s C:\Windows\AtlasModules
if %ERRORLEVEL%==0 (echo Deleted AtlasModules folder
) ELSE (echo Failed deleting AtlasModules folder.&pause&exit)
goto copyfolders

:copyfolders
xcopy "%USERPROFILE%\Downloads\tempatlas\Atlas-main\src\AtlasModules" "C:\Windows\AtlasModules" /e /i /h
if %ERRORLEVEL%==0 (echo Copied AtlasModules folder
) ELSE (echo Failed copying the AtlasModules folder.&pause&exit)
xcopy "%USERPROFILE%\Downloads\tempatlas\Atlas-main\src\Desktop\Atlas" "%USERPROFILE%\Desktop\Atlas" /e /i /h
if %ERRORLEVEL%==0 (echo Copied Atlas desktop folder
) ELSE (echo Failed copying the Atlas desktop folder.&pause&exit)
goto deletetemp

:deletetemp
rd /s /q "%USERPROFILE%\Downloads\tempatlas"
del /f "%USERPROFILE%\Downloads\tempatlas.zip"
color 0a
echo Completed without errors!
pause
goto menu