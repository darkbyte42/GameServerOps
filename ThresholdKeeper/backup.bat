@echo off
setlocal

rem Path to the configuration file
set "configFile=backup-settings.conf"

rem Default values in case they are not set in the config file
set "gamePath="
set "backupPath="
set "prefix="
set "suffix="

rem Load settings from the configuration file
for /f "tokens=1* delims==" %%a in ('type "%configFile%" ^| findstr /i "gamePath backupPath prefix suffix"') do (
    set "%%a=%%b"
)

rem Verify if critical settings are set
if "%gamePath%"=="" echo Game path is not set in the config file & goto end
if "%backupPath%"=="" echo Backup path is not set in the config file & goto end

rem Get current date and time to create a timestamp
for /f "tokens=1-4 delims=/. " %%a in ('date /t') do (
    for /f "tokens=1-3 delims=: " %%A in ('time /t') do (
        set "timestamp=%%a-%%b-%%c_%%A%%B%%C"
    )
)

rem Create the backup directory if it doesn't exist
if not exist "%backupPath%" mkdir "%backupPath%"

rem Create the backup folder with timestamp, prefix, and suffix
set "backupFolder=%backupPath%\%prefix%%timestamp%%suffix%"
mkdir "%backupFolder%"

rem Copy game files to the backup folder
xcopy /s /e "%gamePath%" "%backupFolder%"

rem Zip up the backup folder and delete the folder after zipping
powershell -nologo -noprofile -command "& {Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::CreateFromDirectory('%backupFolder%', '%backupFolder%.zip'); Remove-Item -Path '%backupFolder%' -Recurse -Force; }"

echo Backup successfully created at %backupFolder%.zip

:end
endlocal
