@echo off
if not exist "build\%~1.vcd" (echo No existe build\%~1.vcd - corre primero: sim %~1 & exit /b 1)
gtkwave build\%~1.vcd
