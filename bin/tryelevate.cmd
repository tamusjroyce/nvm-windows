@setlocal
@echo off
set CMD=%*
set APP=%1

REM tries to run any script passed first without admin rights
%* || start wscript //nologo "%~dpn0.vbs" %*
