@echo off
cd z_gup
node gerar_min.js 
cd ..
py atu_min.py %1 %2 %3
if %4X neq NX pause
