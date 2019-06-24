@ECHO OFF & CLS & ECHO.

IF "%1"=="" (
  set /P NVM_PATH="Enter the absolute path where the zip file is extracted/copied to: "
) ELSE (
  set NVM_PATH=%1
)
mkdir %NVM_PATH% && echo "%NVM_PATH% was created!" || echo "%NVM_PATH% was unable to be created."

set DRIVE=%NVM_PATH:~0,2%
IF "%DRIVE:~1,1%"==":" (
  %DRIVE%
)

REM Sets PROGRAMS directory as NVM_PATH parent directory
REM   Example: "C:\Programs" from "C:\Programs\nvm" (if %NVM_PATH% is equal to "C:\Programs\nvm")
REM
SET CURRENTDIR=%CD%
CD %NVM_PATH%
CD ..
SET PROGRAMS=%CD%
CD %CURRENTDIR%

REM Check if running with admin rights (https://stackoverflow.com/a/12264592/458321)
NET FILE 1>NUL 2>NUL & IF ERRORLEVEL 1 (set ISADMIN=1)

IF "%ISADMIN%"=="1" (
  GOTO ADMIN
) ELSE (
  GOTO NONADMIN
)

:ADMIN
  REM Set environment variables to machine level (admin rights required)
  set SETENVVAR=set /M
GOTO FINISH
:NONADMIN
  echo "Check if nvm path requires admin writes to create file" > %NVM_PATH%\checkpermissions.txt || elevate.cmd install.cmd %NVM_PATH%
  REM Set environment variables to local user (no admin rights required)
  set SETENVVAR=set
:FINISH

%SETENVVAR% NVM_PATH=%NVM_PATH%

set NVM_HOME=%NVM_PATH%
%SETENVVAR% NVM_HOME=%NVM_PATH%

set NVM_SYMLINK=%PROGRAMS%\nodejs
%SETENVVAR% NVM_SYMLINK=%PROGRAMS%\nodejs

IF "%ISADMIN%"=="1" (
  for /f "skip=2 tokens=2,*" %%A in ('reg query "HKLM\System\CurrentControlSet\Control\Session Manager\Environment" /v Path 2^>nul') do (
    %SETENVVAR% PATH "%%B;%%NVM_HOME%%;%%NVM_SYMLINK%%"
  )
) ELSE (
  echo.%PATH%|findstr /C:"%NVM_PATH%" >nul 2>&1 || %SETENVVAR% PATH=%PATH%;%NVM_PATH%
)

if exist "%SYSTEMDRIVE%\Program Files (x86)\" (
  set SYS_ARCH=64
) else (
  set SYS_ARCH=32
)
(echo root: %NVM_HOME% && echo path: %NVM_SYMLINK% && echo arch: %SYS_ARCH% && echo proxy: none) > %NVM_HOME%\settings.txt

start "" %NVM_HOME%\settings.txt || explorer %NVM_HOME%\settings.txt || notepad %NVM_HOME%\settings.txt
@echo on
