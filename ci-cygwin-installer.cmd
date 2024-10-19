@echo off

:: Copyright 2023 by userdocs and contributors for LFTP4WIN installer derived from https://github.com/vegardit/cygwin-portable-installer
:: Copyright 2017-2023 by Vegard IT GmbH (https://vegardit.com) and the cygwin-portable-installer contributors.
::
:: LFTP4WIN installer derived from cygwin-portable-installer
:: SPDX-FileCopyrightText: © userdocs and contributors
:: SPDX-FileContributor: userdocs
:: SPDX-License-Identifier: Apache-2.0
::
:: cygwin-portable-installer
:: SPDX-FileCopyrightText: © Vegard IT GmbH (https://vegardit.com) and contributors
:: SPDX-FileContributor: Sebastian Thomschke, Vegard IT GmbH
:: SPDX-License-Identifier: Apache-2.0

:: ABOUT
:: =====
:: LFTP4WIN installer
::
:: A heavily modified and re-targeted version of this project https://github.com/vegardit/cygwin-portable-installer
:: Original code has been 1: removed where not relevant 2: Modified to work with LFTP4WIN CORE 3: Unmodified where applicable.
:: It installs a portable Cygwin installation to be used specifically with the https://github.com/userdocs/LFTP4WIN-CORE skeleton.
:: The LFTP4WIN-CORE is applied to the Cygwin installation with minimal modification to the Cygwin environment or core files.
:: This provides a a fully functional Cygwin portable platform for use with the LFTP4WIN project.
:: Environment customization is no longer designed to be fully self contained and is partially provided via the LFTP4WIN-CORE
:: There are still some critical configuration options available below for the installation.
:: if executed with "--debug" print all executed commands
for %%a in (%*) do (
  if [%%~a]==[--debug] echo on
)

:: ============================================================================================================
:: CONFIG CUSTOMIZATION START
:: ============================================================================================================

:: You can customize the following variables to your needs before running the batch file:

:: set proxy if required (unfortunately Cygwin setup.exe does not have commandline options to specify proxy user credentials)
set PROXY_HOST=
set PROXY_PORT=8080

:: Choose a user name that will be used to configure Cygwin. This user will be a clone of the account running the installation script renamed as the setting chosen.
set LFTP4WIN_USERNAME=IPERF3_BUILD

:: Show the packet manager if you need to specify a program version during installation instead of using the current release (default), like openssh 7.9 instead of 8.0 for Lftp.
set CYGWIN_PACKET_MANAGER=

:: Packages are loaded from the packages_basic.cmd and packages_openssl.cmd. The action matrix copies the one it needs to ci-cygwin-installer-packages.cmd
echo Loading package dependencies from ci-cygwin-installer-packages.cmd
set /p CYGWIN_PACKAGES=<ci-cygwin-installer-packages.cmd

:: Install the LFTP4WIN Skeleton files to use lftp via WinSCP and Conemu. Installs Conemu, kitty, WinSCP, notepad++ and makes a few minor modifications to the default cygin installation.
set INSTALL_LFTP4WIN_CORE=no

:: change the URL to the closest mirror https://cygwin.com/mirrors.html
set CYGWIN_MIRROR=https://www.mirrorservice.org/sites/sourceware.org/pub/cygwin/

:: one of: auto,64,32 - specifies if 32 or 64 bit version should be installed or automatically detected based on current OS architecture
set CYGWIN_ARCH=auto

:: add more path if required, but at the cost of runtime performance (e.g. slower forks)
set CYGWIN_PATH=""

:: if set to 'yes' the local package cache created by cygwin setup will be deleted after installation/update
set DELETE_CYGWIN_PACKAGE_CACHE=yes

:: ============================================================================================================
:: CONFIG CUSTOMIZATION END
:: ============================================================================================================

echo.
echo ###########################################################
echo # Installing [Cygwin Portable]
echo ###########################################################
echo.

set LFTP4WIN_BASE=%~dp0
set LFTP4WIN_ROOT=%~dp0cygwin
set INSTALL_TEMP=%~dp0cygwin\tmp

set USERNAME=%LFTP4WIN_USERNAME%
set GROUP=None
set GRP=
set SHELL=/bin/bash

if not exist "%INSTALL_TEMP%" (
  md "%LFTP4WIN_ROOT%"
  md "%LFTP4WIN_ROOT%\etc"
  md "%INSTALL_TEMP%"
)

:: https://blogs.msdn.microsoft.com/david.wang/2006/03/27/howto-detect-process-bitness/
if "%CYGWIN_ARCH%" == "auto" (
  if "%PROCESSOR_ARCHITECTURE%" == "x86" (
    if defined PROCESSOR_ARCHITEW6432 (
      set CYGWIN_ARCH=64
    ) else (
      set CYGWIN_ARCH=32
    )
  ) else (
    set CYGWIN_ARCH=64
  )
)

:: download Cygwin 32 or 64 setup exe depending on detected architecture
if "%CYGWIN_ARCH%" == "64" (
  set CYGWIN_SETUP_EXE=setup-x86_64.exe
) else (
  set CYGWIN_SETUP_EXE=setup-x86.exe
)

:: Cygwin command line options: https://cygwin.com/faq/faq.html#faq.setup.cli
if "%PROXY_HOST%" == "" (
  set CYGWIN_PROXY=
) else (
  set CYGWIN_PROXY=--proxy "%PROXY_HOST%:%PROXY_PORT%"
)

if exist "%INSTALL_TEMP%\%CYGWIN_SETUP_EXE%" (
  del "%INSTALL_TEMP%\%CYGWIN_SETUP_EXE%" || goto :fail
)

if "%CYGWIN_PACKET_MANAGER%" == "yes" (
  set CYGWIN_PACKET_MANAGER=--package-manager
)

echo Downloading some files, it can take a minute or two
echo.

call :download "https://cygwin.org/%CYGWIN_SETUP_EXE%" "%INSTALL_TEMP%\%CYGWIN_SETUP_EXE%"

if "%INSTALL_LFTP4WIN_CORE%" == "yes" (
  call :download "https://github.com/userdocs/LFTP4WIN-CORE/archive/master.zip" "%INSTALL_TEMP%\lftp4win_core.zip"
)

echo Running Cygwin setup
echo.

"%INSTALL_TEMP%\%CYGWIN_SETUP_EXE%" --no-admin ^
  --site "%CYGWIN_MIRROR%" ^
  --root "%LFTP4WIN_ROOT%" ^
  --local-package-dir "%LFTP4WIN_ROOT%\.pkg-cache" ^
  --no-shortcuts ^
  --no-desktop ^
  --delete-orphans ^
  --upgrade-also ^
  --no-replaceonreboot ^
  --quiet-mode ^
  --packages %CYGWIN_PACKAGES% %CYGWIN_PACKET_MANAGER% || goto :fail

if "%DELETE_CYGWIN_PACKAGE_CACHE%" == "yes" (
  rd /s /q "%LFTP4WIN_ROOT%\.pkg-cache"
)

(
  echo # /etc/fstab
  echo # IMPORTANT: this files is recreated on each start by LFTP4WIN-terminal.cmd
  echo #
  echo #    This file is read once by the first process in a Cygwin process tree.
  echo #    To pick up changes, restart all Cygwin processes.  For a description
  echo #    see https://cygwin.com/cygwin-ug-net/using.html#mount-table
  echo #
  echo none /cygdrive cygdrive binary,noacl,posix=0,sparse,user 0 0
) > "%LFTP4WIN_ROOT%\etc\fstab"

:: Configure our Cygwin Environment
"%LFTP4WIN_ROOT%\bin\mkgroup.exe" -c > cygwin/etc/group || goto :fail
"%LFTP4WIN_ROOT%\bin\bash.exe" -c "echo ""$USERNAME:*:1001:$(cygwin/bin/mkpasswd -c | cygwin/bin/cut -d':' -f 4):$(cygwin/bin/mkpasswd -c | cygwin/bin/cut -d':' -f 5):$(cygwin/bin/cygpath.exe -u ""%~dp0""):/bin/bash""" > cygwin/etc/passwd || goto :fail
:: Fix a symlink bug in Cygwin
"%LFTP4WIN_ROOT%\bin\ln.exe" -fsn '../usr/share/terminfo' '/lib/terminfo' || goto :fail

if "%INSTALL_LFTP4WIN_CORE%" == "yes" (
  "%LFTP4WIN_ROOT%\bin\bsdtar.exe" -xmf "%INSTALL_TEMP%\lftp4win_core.zip" --strip-components=1 -C "%LFTP4WIN_BASE%\" || goto :fail
  "%LFTP4WIN_ROOT%\bin\touch.exe" "%LFTP4WIN_ROOT%\.core-installed"
)

set Init_sh=%LFTP4WIN_ROOT%\portable-init.sh
echo Creating [%Init_sh%]
echo.
(
  echo #!/usr/bin/env bash
  echo.
  echo ## Map Current Windows User to root user
  echo.
  echo unset HISTFILE
  echo.
  echo rm -f /etc/{passwd,group}
  echo sed -ri "s@# db_home: (.*)@db_home: ${HOME}@" /etc/nsswitch.conf
  echo.
  echo ## Adjust the Cygwin packages cache path
  echo.
  echo pkg_cache_dir=$(cygpath -w "$LFTP4WIN_ROOT/.pkg-cache"^)
  echo.
  echo sed -ri 's#(.*^)\.pkg-cache$#'"\t${pkg_cache_dir//\\/\\\\}"'#' /etc/setup/setup.rc
  echo.
  echo set HISTFILE
) > "%Init_sh%" || goto :fail

"%LFTP4WIN_ROOT%\bin\sed" -i 's/\r$//' "%Init_sh%" || goto :fail

IF EXIST "%LFTP4WIN_ROOT%\etc\fstab" "%LFTP4WIN_ROOT%\bin\sed" -i 's/\r$//' "%LFTP4WIN_ROOT%\etc\fstab"

IF EXIST "%LFTP4WIN_ROOT%\portable-init.sh" "%LFTP4WIN_ROOT%\bin\bash" -li "%LFTP4WIN_ROOT%\portable-init.sh"

echo ###########################################################
echo # Installing [LFTP4WIN Portable] succeeded.
echo ###########################################################
echo.

del /q "%INSTALL_TEMP%\%CYGWIN_SETUP_EXE%" "%LFTP4WIN_ROOT%\Cygwin.bat" "%LFTP4WIN_ROOT%\Cygwin.ico" "%LFTP4WIN_ROOT%\Cygwin-Terminal.ico"

if "%INSTALL_LFTP4WIN_CORE%" == "yes" (
  DEL /Q "%LFTP4WIN_BASE%\.gitattributes" "%LFTP4WIN_BASE%\README.md" "%LFTP4WIN_BASE%\LICENSE.txt" "%INSTALL_TEMP%\lftp4win_core.zip"
  RMDIR /S /Q "%LFTP4WIN_BASE%\docs"
)

goto :eof

:fail
  set exit_code=%ERRORLEVEL%
  if exist "%DOWNLOADER%" (
    del "%DOWNLOADER%"
  )
  echo.
  echo ###########################################################
  echo # Installing [LFTP4WIN Portable] FAILED!
  echo ###########################################################
  echo.
  exit /B %exit_code%

:download
  if exist "%2" (
    echo Deleting existing [%2]
    del "%2" || goto :fail
  )

  where /q curl
  if %ERRORLEVEL% EQU 0 (
    call :download_with_curl "%1" "%2"
  )

  if errorlevel 1 (
    call :download_with_powershell "%1" "%2"
  )

  if errorlevel 1 (
    call :download_with_vbs "%1" "%2" || goto :fail
  )

  exit /B 0

:download_with_curl
  if "%PROXY_HOST%" == "" (
    set "http_proxy="
    set "https_proxy="
  ) else (
    set http_proxy=http://%PROXY_HOST%:%PROXY_PORT%
    set https_proxy=http://%PROXY_HOST%:%PROXY_PORT%
  )
  echo Downloading %1 to %2 using curl
  curl -sL %1 -# -o %2 || exit /B 1
  exit /B 0

:download_with_vbs
  :: create VB script that can download files
  :: not using PowerShell which may be blocked by group policies
  set DOWNLOADER=%INSTALL_ROOT%downloader.vbs
  echo Creating [%DOWNLOADER%] script
  if "%PROXY_HOST%" == "" (
    set DOWNLOADER_PROXY=.
  ) else (
    set DOWNLOADER_PROXY= req.SetProxy 2, "%PROXY_HOST%:%PROXY_PORT%", ""
  )

  (
    echo url = Wscript.Arguments(0^)
    echo target = Wscript.Arguments(1^)
    echo On Error Resume Next
    echo reqType = "WinHttp.WinHttpRequest.5.1"
    echo Set req = CreateObject(reqType^)
    echo If req Is Nothing Then
    echo   reqType = "MSXML2.XMLHTTP.6.0"
    echo   Set req = CreateObject(reqType^)
    echo End If
    echo WScript.Echo "Downloading '" ^& url ^& "' to '" ^& target ^& "' using '" ^& reqType ^& "'"
    echo%DOWNLOADER_PROXY%
    echo req.Open "GET", url, False
    echo req.Send
    echo If Err.Number ^<^> 0 Then
    echo   WScript.Quit 1
    echo End If
    echo If req.Status ^<^> 200 Then
    echo   WScript.Echo "FAILED to download: HTTP Status " ^& req.Status
    echo   WScript.Quit 1
    echo End If
    echo Set buff = CreateObject("ADODB.Stream"^)
    echo buff.Open
    echo buff.Type = 1
    echo buff.Write req.ResponseBody
    echo buff.Position = 0
    echo buff.SaveToFile target
    echo buff.Close
    echo.
  ) >"%DOWNLOADER%" || goto :fail

  cscript //Nologo "%DOWNLOADER%" %1 %2 || exit /B 1
  del "%DOWNLOADER%"
  exit /B 0

:download_with_powershell
  if "%PROXY_HOST%" == "" (
    set "http_proxy="
    set "https_proxy="
  ) else (
    set http_proxy=http://%PROXY_HOST%:%PROXY_PORT%
    set https_proxy=http://%PROXY_HOST%:%PROXY_PORT%
  )
  echo Downloading %1 to %2 using powershell
  powershell "[Net.ServicePointManager]::SecurityProtocol = 'tls12, tls11, tls'; (New-Object Net.WebClient).DownloadFile('%1', '%2')" || exit /B 1
  exit /B 0
