@echo off
setlocal EnableDelayedExpansion
set "a=%*"
set "a=!a:pc-windows-msvc=windows-gnu!"
zig cc !a!
exit /b %ERRORLEVEL%
