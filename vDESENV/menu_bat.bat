echo off

set pasta_plb=z_plb/

REM ----------------------------------------------------------------------------------------------------------
REM   menu PRINCIPAL 
REM ----------------------------------------------------------------------------------------------------------
:menu_principal
cls
color 71
echo .
echo   Usuario: %username%   Data: %date%   
echo  -------------------------------------
echo  !           OPCOES                  !
echo  -------------------------------------
echo  !    0. Sair                        !
echo  !                                   !
echo  !    1. BRUNO                       !
echo  !                                   !
echo  !    2. IVANOR                      !
echo  !                                   !
echo  !    3. GIOVANNI                    !
echo  !                                   !
echo  !                                   !
echo  !    9. HOMOLOGA                    !
echo  !                                   !
echo  -------------------------------------

set /p opcao0=. Escolha uma opcao: 
echo ___
if %opcao0% equ 0 goto sair
if %opcao0% equ 1 ( 
	set desenv=DESENV01
	goto menu_desenv
)	
if %opcao0% equ 2 (
	set desenv=IVANOR
	goto menu_desenv
)	
if %opcao0% equ 3 (
	set desenv=DESENV02
	goto menu_desenv
)	
if %opcao0% equ 9 ( 
	set desenv=HOMOLOGA
	goto menu_homologa
)	
if %opcao0% geq 4 goto erro_principal




REM ----------------------------------------------------------------------------------------------------------
REM   menu desenv
REM ----------------------------------------------------------------------------------------------------------
:menu_desenv
cls
color 71
echo .
echo  -------------------------------------
echo  !      %desenv% - %username%        !
echo  -------------------------------------
echo  !    0. Sair                        !
echo  !    1. Gerar PLBs                  !
echo  !    2. Compilar PKGs               !
echo  !    3. Gerar MIN + Upload          !
echo  !    4. TODOS (1 + 2 +3 )           !  
echo  !                                   !
echo  !    5. Iniciar GUP default         !
echo  !    6. Listar PLBs e MIN           !
echo  -------------------------------------

set /p opcao=. Escolha uma opcao: 
echo ___
if %opcao% equ 0 goto menu_principal
if %opcao% equ 1 goto gerar_plb
if %opcao% equ 2 goto atu_pkg
if %opcao% equ 3 goto atu_min 
if %opcao% equ 4 goto todos
if %opcao% equ 5 goto gup_min
if %opcao% equ 6 goto listar_plb
if %opcao% geq 7 goto erro


REM ----------------------------------------------------------------------------------------------------------
REM   menu HOMOLOGA
REM ----------------------------------------------------------------------------------------------------------

:menu_homologa
cls
color 71
echo .
echo  -------------------------------------
echo  !      %desenv% - %username%        !
echo  -------------------------------------
echo  !    0. Sair                        !
echo  !    1. Gerar PLBs                  !
echo  !    2. Gerar MIN                   !
echo  !    3. Listar PLBs e MINs          !
echo  !                                   !
echo  !    9. Subir AUTOUPDATE HOMOLOGA   !  
echo  !                                   !
echo  -------------------------------------

set /p opcao=. Escolha uma opcao: 
echo ___
if %opcao% equ 0 goto menu_principal 
if %opcao% equ 1 goto gerar_plb
if %opcao% equ 2 goto gerar_min
if %opcao% equ 3 goto listar_plb
if %opcao% equ 9 goto update_h

if %opcao% equ 4 goto erro
if %opcao% equ 5 goto erro
if %opcao% equ 6 goto erro
if %opcao% equ 7 goto erro
if %opcao% equ 8 goto erro
if %opcao% geq 10 goto erro

REM ----------------------------------------------------------------------------------------------------------
REM   chamadas das BATs 
REM ----------------------------------------------------------------------------------------------------------

:sair
exit

:erro_principal 
echo Opcao invalida, Escolha outra opcao 
pause 
goto menu_principal

:erro
echo Opcao invalida, Escolha outra opcao 
pause 
if %desenv% equ HOMOLOGA  (goto menu_homologa) else (goto menu_desenv)

:gerar_plb
start "" cmd /c wrap_tudo.bat
if %desenv% equ HOMOLOGA  (goto menu_homologa) else (goto menu_desenv)

:gerar_min
start "" cmd /c gerar_min.bat
if %desenv% equ HOMOLOGA  (goto menu_homologa) else (goto menu_desenv)


:atu_pkg
if %desenv% equ DESENV01    start "" cmd /c atu_pkg.bat DWU1 DWU1 DESENV_PDB
if %desenv% equ IVANOR      start "" cmd /c atu_pkg.bat DWU2 DWU2 DESENV_PDB
if %desenv% equ DESENV02    start "" cmd /c atu_pkg.bat DWU3 DWU3 DESENV_PDB
if %desenv% equ HOMOLOGA    start "" cmd /c atu_pkg.bat DWU  DWU  HOMOLOGA
if %desenv% equ HOMOLOGA  (goto menu_homologa) else (goto menu_desenv)

:atu_min
if %desenv% equ DESENV01    start "" cmd /c atu_min.bat DWU1 DWU1 DESENV_PDB
if %desenv% equ IVANOR      start "" cmd /c atu_min.bat DWU2 DWU2 DESENV_PDB
if %desenv% equ DESENV02    start "" cmd /c atu_min.bat DWU3 DWU3 DESENV_PDB
if %desenv% equ HOMOLOGA    start "" cmd /c atu_min.bat DWU  DWU  HOMOLOGA
if %desenv% equ HOMOLOGA  (goto menu_homologa) else (goto menu_desenv)

:todos
if %desenv% equ DESENV01    start "" cmd /c atu_tudo.bat DWU1 DWU1 DESENV_PDB
if %desenv% equ IVANOR      start "" cmd /c atu_tudo.bat DWU2 DWU2 DESENV_PDB
if %desenv% equ DESENV02    start "" cmd /c atu_tudo.bat DWU3 DWU3 DESENV_PDB
if %desenv% equ HOMOLOGA    start "" cmd /c atu_tudo.bat DWU  DWU  HOMOLOGA
if %desenv% equ HOMOLOGA  (goto menu_homologa) else (goto menu_desenv)


:update_h
start "" cmd /c atu_autoupdate_desenv.bat
if %desenv% equ HOMOLOGA  (goto menu_homologa) else (goto menu_desenv)

:gup_min
start "" cmd /c gulp_default.bat
if %desenv% equ HOMOLOGA  (goto menu_homologa) else (goto menu_desenv)

:listar_plb
start "" cmd /c lista_plb_min.bat
if %desenv% equ HOMOLOGA  (goto menu_homologa) else (goto menu_desenv)

