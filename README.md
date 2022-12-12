# Atlas Updater
**⚠ Make sure to read all the warnings as you advance through the batch script and on this README.**

Atlas Updater is a simple batch script to update [Atlas](https://github.com/Atlas-OS/Atlas) (a free and performant modification to Windows 10) folders (the [AtlasModules](https://github.com/Atlas-OS/Atlas/tree/main/src/AtlasModules) and [Atlas Desktop](https://github.com/Atlas-OS/Atlas/tree/main/src/Desktop/Atlas) folders). Useful to contributors, general testers or people that are curious. Tested on Windows 10 21H2 with latest PowerShell. 

Feel free to make a pull request to improve the script! :)

**View the [Changelog](https://github.com/he3als/AtlasUpdater/blob/main/changelog.md)**

## Showcase

https://user-images.githubusercontent.com/65787561/158027428-1521010f-6d53-44cd-ae27-09b98cc6af2f.mp4

## Download
1. Open [this link](https://raw.githubusercontent.com/he3als/AtlasUpdater/main/AtlasUpdaterScript.bat) in a new tab
2. Right click and click 'Save As' and save it as a `.bat` file

https://user-images.githubusercontent.com/65787561/158017652-45312dc0-bbfd-4e15-b7cf-e45e51232519.mp4

**Note: Your browser may save it as a `.txt` and if that is the case, then just rename it to `.bat`.**

**If you can not download it directly, [download the .zip](https://github.com/he3als/AtlasUpdater/archive/refs/heads/main.zip) and extract it.**

## Features
- Updating the AtlasModules and Atlas desktop folder
- Ability to update itself (can be easily toggled by editing the batch script)
- Easily accessing the Atlas and AtlasUpdater repositories
- Running the Atlas post-installation script (dangerous to do)

## Dependancies
- cURL - default on 1803+, Atlas is 1803
- Basic Windows utilities (`findstr`, `fltmc`, etc...)
- 7-Zip and PowerShell
