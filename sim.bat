@echo off
setlocal
if "%~1"=="" (echo Uso: sim tb_nombre & exit /b 1)
if not exist "tb\%~1.v" (echo No existe tb\%~1.v & exit /b 1)
if not exist build mkdir build
dir /b /s rtl\*.v > build\srcs.txt 2>nul
dir /b /s tb\%~1.v >> build\srcs.txt
iverilog -g2005 -o build\%~1.vvp -s %~1 -c build\srcs.txt
if errorlevel 1 (echo. & echo COMPILACION FALLIDA - revisa los errores de arriba & exit /b 1)
echo.
vvp build\%~1.vvp