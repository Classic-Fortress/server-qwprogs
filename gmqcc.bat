@echo off
for /f "delims=" %%i in ('git rev-parse --short HEAD') do set output=%%i
@echo on
gmqcc -std=fteqcc -fvariadic-args -funtyped-nil -DVER=\"%output%\" -DREV=\"%output%\"
@cp qwprogs.dat "C:\Users\Niclas\Dropbox\Projects\Classic Fortress\Game\server\fortress\qwprogs.dat"
@taskkill /f /im mvdsv.exe 2>nul
@taskkill /f /im ezquake-dev.exe 2>nul
@cd "C:\Users\Niclas\Dropbox\Projects\Classic Fortress\Game\server"
@call "cmd /c start mvdsv.exe"
