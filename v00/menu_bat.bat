echo off
:menu1
cls
color 71

echo .
echo   Usuario: %username%   Data: %date%   

echo  -------------------------------------
echo  !           OPCOES                  !
echo  -------------------------------------
echo  !    0. Sair                        !
echo  !    1. Gerar PLBs                  !
echo  !    2. Gerar MIN                   !
echo  !    3. Listar PLBs e MIN           !
echo  !                                   !
echo  !      -- TESTAR DEV 2 --           !
echo  !    4. Compilar PKGs               !
echo  !    5. Upload MIN                  !
echo  !                                   !
echo  !     -- SUBIR PARA UPDATE --       !
echo  !    6. Comparar/Testar UPDATE      !
echo  !    7. Subir UPDATE                !
echo  !                                   !
echo  -------------------------------------

set /p opcao=. Escolha uma opcao: 
echo ___
if %opcao% equ 0 goto sair
if %opcao% equ 1 goto gerar_plb
if %opcao% equ 2 goto gerar_min 
if %opcao% equ 3 goto lista_plb

if %opcao% equ 4 goto atu_pkg
if %opcao% equ 5 goto atu_min

if %opcao% equ 6 goto check_update
if %opcao% geq 7 goto atualiza_update
if %opcao% geq 8 goto erro

:erro
msg Opcao invalida
echo ----------------------------------------
echo Opcao invalida, Escolha outra opcao 
echo ----------------------------------------
pause 
goto menu1

:sair
exit

:gerar_plb
start "" cmd /c wrap_tudo.bat
goto menu1

:gerar_min
start "" cmd /c gerar_min.bat
goto menu1

:lista_plb
start "" cmd /c lista_plb_min.bat
goto menu1

:atu_pkg
start "" cmd /c atu_pkg.bat DWU2 DWU2 DESENV_PDB
goto menu1

:atu_min
start "" cmd /c atu_min.bat DWU2 DWU2 DESENV_PDB
goto menu1



:check_update
start "" cmd /c update_check.bat
goto menu1

:atualiza_update
start "" cmd /c update_atualiza.bat
goto menu1


