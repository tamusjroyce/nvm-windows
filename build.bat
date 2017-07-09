@echo off
SET INNOSETUP=%~dp0\nvm.iss
SET ORIG=%~dp0
REM SET GOPATH=%~dp0\src
SET GOBIN=%~dp0\bin
SET GOARCH=386
SET version=1.1.6

REM Get the version number from the setup file
REM for /f "tokens=*" %%i in ('findstr /n . %INNOSETUP% ^| findstr ^4:#define') do set L=%%i
REM set version=%L:~24,-1%

REM Get the version number from the core executable
REM for /f "tokens=*" %%i in ('findstr /n . %GOPATH%\nvm.go ^| findstr ^NvmVersion^| findstr ^21^') do set L=%%i
REM set goversion=%L:~19,-1%

REM IF NOT %version%==%goversion% GOTO VERSIONMISMATCH

SET DIST=%~dp0\dist\%version%

REM Build the executable
echo "Building NVM for Windows"
REM del %GOBIN%\nvm.exe
REM cd %GOPATH%
echo "=========================================>"
REM echo %GOBIN%
REM goxc -arch="386" -os="windows" -n="nvm" -d="%GOBIN%" -o="%GOBIN%\nvm{{.Ext}}" -tasks-=package

REM cd %ORIG%
REM del %GOBIN%\src.exe
REM del %GOPATH%\src.exe
REM del %GOPATH%\nvm.exe

REM Clean the dist directory
if exist "%DIST%" (
  rmdir /S /Q "%DIST%"
)
mkdir "%DIST%"

echo "Creating distribution in %DIST%"

if exist src\nvm.exe (
  del src\nvm.exe
)

echo "Building nvm.exe...."

go build src\nvm.go
move nvm.exe %GOBIN% >nul

echo "Building noinstall zip..."
for /d %%a in (%GOBIN%) do (buildtools\zip -j -9 -r "%DIST%\nvm-noinstall.zip" "%~dp0\LICENSE" "%%a\*" -x "%GOBIN%\nodejs.ico")

echo "Building the primary installer..."
buildtools\iscc %INNOSETUP% "/o%DIST%" "/dProjectRoot=%ORIG%"
buildtools\zip -j -9 -r "%DIST%\nvm-setup.zip" "%DIST%\nvm-setup.exe"
echo "Generating Checksums for release files..."

for /r "%DIST%" %%b in (*.zip *.exe) do (CertUtil -hashfile %%b SHA256 >> %%b.sha256.txt)
echo "Distribution created. Now cleaning up...."
del "%GOBIN%\nvm.exe"

echo "Done."
@echo on
