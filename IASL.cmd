@echo off
setlocal EnableDelayedExpansion
set iasver=2.5.5

::============================================================================
:: Skrip Aktivasi IDM (Aktivator + Pembersih Registri)
::============================================================================

mode con: cols=120 lines=40
title Coporton IDM Activation Script (Activator + Registry Cleaner) v%iasver%

:: Ensure Admin Privileges
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B
)

:: Set paths
set "SCRIPT_DIR=%~dp0"
set "SRC_DIR=%SCRIPT_DIR%src\"
set "DATA_FILE=%SRC_DIR%data.bin"
set "DATAHLP_FILE=%SRC_DIR%dataHlp.bin"
set "REGISTRY_FILE=%SRC_DIR%registry.bin"
set "EXTENSIONS_FILE=%SRC_DIR%extensions.bin"
set "ascii_file=%SRC_DIR%banner_art.txt"

:: Temp files
set "tempfile_html=%temp%\idm_news.html"

:: Output colors
set "RESET=[0m"
set "GREEN=[32m"
set "RED=[31m"
set "YELLOW=[33m"

chcp 65001 >nul

:: Define the number of spaces for padding
set "padding=   "

:: Loop through each line in the ASCII art file and add spaces
for /f "delims=" %%i in (%ascii_file%) do (
    echo !padding!%%i
)

:: Internet connection check
call :check_internet

:: Verify Script Version
echo Checking for script updates...

set "SCRIPT_VERSION=v%iasver%"
set "API_URL=https://api.github.com/repos/coporton/IDM-Activation-Script/releases/latest"

curl -s "%API_URL%" -o "%temp%\latest_release.json"

:: Verify that the JSON file was downloaded correctly
if not exist "%temp%\latest_release.json" (
    echo Failed to download release information from GitHub.
    pause
    exit /B
)

:: Extract LATEST_VERSION from JSON
set "LATEST_VERSION="
for /f "tokens=2 delims=:" %%a in ('findstr /i "tag_name" "%temp%\latest_release.json"') do (
    set "line=%%a"
    set "line=!line:~2,-2!"
    for /f "delims=" %%v in ("!line!") do set "LATEST_VERSION=%%v"
)

if not defined LATEST_VERSION (
    echo Failed to extract version from the release information.
    pause
    exit /B
)

:: Strip 'v' prefix for numeric comparison
set "SCRIPT_VERSION_NUM=%SCRIPT_VERSION:v=%"
set "LATEST_VERSION_NUM=%LATEST_VERSION:v=%"

:: Compare Versions
call :CompareVersions "%SCRIPT_VERSION_NUM%" "%LATEST_VERSION_NUM%"

if "%is_newer%"=="1" (
    echo %GREEN% A new script version is available! %RESET%
    echo Current version: %SCRIPT_VERSION%
    echo Latest version : %LATEST_VERSION%
    goto ask_download
) else (
    echo %GREEN% Skrip Anda sudah diperbarui. Versi: %SCRIPT_VERSION% %RESET%
    goto continue_script
)

::--------------------------
:: Version Comparison Logic
::--------------------------
:CompareVersions
setlocal EnableDelayedExpansion
set "current=%~1"
set "latest=%~2"

for /f "tokens=1-3 delims=." %%a in ("!current!") do (
    set "cur1=%%a"
    set "cur2=%%b"
    set "cur3=%%c"
)
for /f "tokens=1-3 delims=." %%a in ("!latest!") do (
    set "lat1=%%a"
    set "lat2=%%b"
    set "lat3=%%c"
)

if !lat1! GTR !cur1! (endlocal & set "is_newer=1" & exit /b)
if !lat1! LSS !cur1! (endlocal & set "is_newer=0" & exit /b)
if !lat2! GTR !cur2! (endlocal & set "is_newer=1" & exit /b)
if !lat2! LSS !cur2! (endlocal & set "is_newer=0" & exit /b)
if !lat3! GTR !cur3! (endlocal & set "is_newer=1" & exit /b)
if !lat3! LSS !cur3! (endlocal & set "is_newer=0" & exit /b)

endlocal & set "is_newer=0"
exit /b

::--------------------------
:: Minta untuk mengunduh versi baru
::--------------------------
:ask_download
echo %GREEN% ========================================================================
echo %GREEN%    :                                                                :
echo %GREEN%    :  Apakah Anda ingin mengunduh skrip versi terbaru?    : 
echo %GREEN%    :                       (1 = Ya / 2 = Tidak)                       :
echo %GREEN% =======================================================================%RESET%
echo.

set "choice="
set /p choice=" Choose an option (1 = Yes / 2 = No): "

if "%choice%"=="1" (
    call :DownloadLatestScript
) else if "%choice%"=="2" (
    goto continue_script
) else (
    echo %RED% Invalid input. Please type 1 or 2 only.%RESET%
    timeout /t 2 >nul
    goto ask_download
)
goto :eof

:continue_script
echo Getting the latest version information...
curl -s "https://www.internetdownloadmanager.com/news.html" -o "%tempfile_html%"
set "online_version="

:: Find the first occurrence of the version
for /f "tokens=1* delims=<>" %%a in ('findstr /i "<H3>What's new in version" "%tempfile_html%" ^| findstr /r /c:"Build [0-9]*"') do (
    set "line=%%b"
    set "line=!line:What's new in version =!"
    set "line=!line:</H3>=!"
    set "online_version=!line!"
    goto :got_version
)

:got_version
if not defined online_version (
    echo %RED% Failed to retrieve online version.%RESET%
    exit /b
)

echo %GREEN% Latest version: !online_version! %RESET%

:: Scan the online version and generate the download code
for /f "tokens=1,2,4 delims=. " %%a in ("!online_version!") do (
    set "o_major=%%a"
    set "o_minor=%%b"
    set "o_build=%%c"
)

set "downloadcode=!o_major!!o_minor!build!o_build!"
set "downloadurl=https://mirror2.internetdownloadmanager.com/idman%downloadcode%.exe"

:: Check installed version
echo Checking installed version...
set "installed="
for /f "tokens=3" %%a in ('reg query "HKCU\Software\DownloadManager" /v idmvers 2^>nul') do set "installed=%%a"
if not defined installed (
    for /f "tokens=3" %%a in ('reg query "HKLM\SOFTWARE\Internet Download Manager" /v Version 2^>nul') do set "installed=%%a"
)

timeout /t 1 >nul
if defined installed (
    set "installed=!installed:v=!"
    set "installed=!installed:Full=!"
    set "installed=!installed: =!"
    set "installed=!installed:b= Build !"
    echo %GREEN% Internet Download Manager ditemukan. Versi terinstal: !installed!%RESET%
) else (
    setlocal disabledelayedexpansion
    echo %RED% Error: Tidak dapat menemukan direktori instalasi Internet Download Manager.%RESET%
    echo %YELLOW% Pastikan Internet Download Manager terpasang dengan benar. Lalu jalankan skrip ini lagi..%RESET%
    echo.
    echo %GREEN% Anda dapat mengunduh versi terbaru dari sini: %downloadurl%%RESET%
    echo.
    echo Loading Menu . . .
    goto :menu
)

:: Parse installed version
for /f "tokens=1,2,4 delims=. " %%a in ("!installed!") do (
    set "i_major=%%a"
    set "i_minor=%%b"
    set "i_build=%%c"
)

:: Compare versions
set /a i_total = 10000 * !i_major! + 100 * !i_minor! + !i_build!
set /a o_total = 10000 * !o_major! + 100 * !o_minor! + !o_build!

echo.
if !i_total! GEQ !o_total! (
    echo %GREEN% Anda sudah memiliki versi terbaru Internet Download Manager.%RESET%
) else (
    echo %YELLOW% Versi IDM yang lebih baru tersedia!%RESET%
    echo %GREEN% Harap perbarui ke versi terbaru: !online_version!%RESET%
)
echo.

:: Cleaning
del "%tempfile_html%" >nul 2>&1
del "%temp%\latest_release.json" >nul 2>&1

:: Main menu
:menu
timeout /t 1 >nul
echo.
echo %GREEN%  ======================================================
echo %GREEN%    :                                                :
echo %GREEN%    :  [1] Unduh IDM Versi Terbaru               :
echo %GREEN%    :  [2] Activate Internet Download Manager        :
echo %GREEN%    :  [3] Extra FileTypes Extensions                :
echo %GREEN%    :  [4] Lakukan Segalanya (2 + 3)                     :
echo %RED%    :  [5] Hapus Entri Registri IDM Sepenuhnya    :
echo %GREEN%    :  [6] KELUAR                                      :
echo %GREEN%    :                                                :
echo %GREEN%  ======================================================%RESET%
echo.
set "choice="
set /p choice=" Choose an option (1-6): "
if not defined choice goto :menu

if "%choice%"=="1" call :DownloadLatestIDM & goto :menu
if "%choice%"=="2" call :ActivateIDM & goto :menu
if "%choice%"=="3" call :AddExtensions & goto :menu
if "%choice%"=="4" call :DoEverything & goto :menu
if "%choice%"=="5" call :CleanRegistry & goto :menu
if "%choice%"=="6" call :quit

echo %RED% Invalid option. Please enter a number from 1 to 6.%RESET%
timeout /t 2 >nul
goto :menu

::----------------------
:: Download function for the latest script
:DownloadLatestScript
set "DOWNLOAD_URL="

:: Extract download URL from JSON file
for /f "tokens=1,* delims=:" %%a in ('findstr /i "browser_download_url" "%temp%\latest_release.json"') do (
    set "line=%%b"
    set "line=!line:~2!"
    set "line=!line: =!"
    set "line=!line:~0,-1!"
    set "DOWNLOAD_URL=!line!"
)

:: Verify that the download URL was extracted correctly
if not "!DOWNLOAD_URL!"=="" (
    echo %GREEN% Membuka peramban Anda untuk mengunduh skrip terbaru..%RESET%
    echo.
    start "" "!DOWNLOAD_URL!"
    echo %YELLOW% Jika unduhan Anda tidak dimulai secara otomatis, salin dan tempel URL ini ke browser Anda:%RESET%
    echo %YELLOW% !DOWNLOAD_URL!%RESET%
) else (
    echo %RED% Gagal mengambil unduhan URL.%RESET%
)
exit

::----------------------
:DownloadLatestIDM
call :check_internet

if /i "!online_version!"=="Unknown" (
    echo %RED% Tidak ada informasi versi yang tersedia. Coba periksa pembaruan terlebih dahulu..%RESET%
    exit /b
)
echo %GREEN% Membuka browser Anda untuk mengunduh IDM terbaru...%RESET%
echo.
start "" "%downloadurl%"
echo %YELLOW% Jika unduhan Anda tidak dimulai secara otomatis, salin dan tempel URL ini ke browser Anda:%RESET%
echo.
exit /b

::----------------------
:: Internet check subroutine
:check_internet
echo Memeriksa konektivitas internet...
ping -n 1 google.com >nul 2>&1
if errorlevel 1 (
    echo %RED% Internet tidak tersedia. Silakan periksa koneksi Anda..%RESET%
    pause
    exit /b
)
exit /b

::----------------------
:ActivateIDM
:: Check IDM installation directory from the registry

for /f "tokens=2*" %%A in ('reg query "HKCU\SOFTWARE\DownloadManager" /v ExePath 2^>nul') do (
    set "DEFAULT_DEST_DIR=%%B"
)

if defined DEFAULT_DEST_DIR (
    for %%A in ("%DEFAULT_DEST_DIR%") do set "DEFAULT_DEST_DIR=%%~dpA"
    timeout /t 1 >nul
) else (
    setlocal disabledelayedexpansion
    echo %RED% Error: Unable to find IDM installation directory.%RESET%
    echo %YELLOW% Please install IDM and try again.%RESET%
    echo %GREEN% Download it here: !downloadurl!%RESET%
    pause
    exit /b
)

call :verifyFile "%DATA_FILE%" "data.bin"
call :verifyFile "%DATAHLP_FILE%" "dataHlp.bin"
call :verifyFile "%REGISTRY_FILE%" "registry.bin"
call :verifyDestinationDirectory
call :terminateProcess "IDMan.exe"
regedit /s "%REGISTRY_FILE%"
copy "%DATA_FILE%" "%DEFAULT_DEST_DIR%IDMan.exe" >nul
copy "%DATAHLP_FILE%" "%DEFAULT_DEST_DIR%IDMGrHlp.exe" >nul

:: ——— PROMPT FOR USER INPUT ———
echo.
SET /P FName=Masukkan Nama Depan Anda: 
SET /P LName=Masukkan Nama Belakang Anda: 
echo.

:: ——— FALLBACK TO DEFAULTS IF BLANK ———
if "%FName%"=="" set "FName=Coporton"
if "%LName%"=="" set "LName=WorkStation"

:: Re-register user info using the values the user just entered
reg add "HKCU\SOFTWARE\DownloadManager" /v FName /t REG_SZ /d "%FName%" /f >nul
reg add "HKCU\SOFTWARE\DownloadManager" /v LName /t REG_SZ /d "%LName%" /f >nul

echo %GREEN% Internet Download Manager Diaktifkan.%RESET%
exit /b

:verifyFile
if not exist "%~1" echo %RED% Missing: %~2%RESET% & pause & exit /b
exit /b

:verifyDestinationDirectory
if not exist "%DEFAULT_DEST_DIR%" echo %RED% Destination not found.%RESET% & pause & exit /b
exit /b

:terminateProcess
taskkill /F /IM %~1 >nul 2>&1
exit /b

::----------------------
:AddExtensions
regedit /s "%EXTENSIONS_FILE%"
echo %GREEN% Extra FileTypes Extensions updated.%RESET%
exit /b

::----------------------
:DoEverything
call :ActivateIDM
call :AddExtensions
echo.
echo [%DATE% %TIME%] Activated IDM >> %SCRIPT_DIR%log.txt
echo %GREEN% Selamat. Semua tugas telah diselesaikan dengan sukses.!%RESET%
echo.
exit /b

::----------------------
:askReturn
set /p back=" Kembali ke menu utama? (Y/N): "
if not defined back goto :askReturn
if /i "%back%"=="Y" set "choice=" & goto :menu
if /i "%back%"=="N" call :quit

echo %RED% Input tidak valid. Silakan ketik Y atau N..%RESET%
goto :askReturn


::----------------------
:CleanRegistry
:: Full registry cleaning logic

call :terminateProcess "IDMan.exe"
echo %YELLOW% Membersihkan Entri Registri terkait IDM...%RESET%

for %%k in (
    "HKLM\Software\Classes\CLSID\{7B8E9164-324D-4A2E-A46D-0165FB2000EC}"
    "HKLM\Software\Classes\CLSID\{6DDF00DB-1234-46EC-8356-27E7B2051192}"
    "HKLM\Software\Classes\CLSID\{D5B91409-A8CA-4973-9A0B-59F713D25671}"
    "HKLM\Software\Classes\CLSID\{5ED60779-4DE2-4E07-B862-974CA4FF2E9C}"
    "HKLM\Software\Classes\CLSID\{07999AC3-058B-40BF-984F-69EB1E554CA7}"
    "HKLM\Software\Classes\CLSID\{E8CF4E59-B7A3-41F2-86C7-82B03334F22A}"
    "HKLM\Software\Classes\CLSID\{9C9D53D4-A978-43FC-93E2-1C21B529E6D7}"
    "HKLM\Software\Classes\CLSID\{79873CC5-3951-43ED-BDF9-D8759474B6FD}"
    "HKLM\Software\Classes\CLSID\{E6871B76-C3C8-44DD-B947-ABFFE144860D}"
    "HKLM\Software\Classes\Wow6432Node\CLSID\{7B8E9164-324D-4A2E-A46D-0165FB2000EC}"
    "HKLM\Software\Classes\Wow6432Node\CLSID\{6DDF00DB-1234-46EC-8356-27E7B2051192}"
    "HKLM\Software\Classes\Wow6432Node\CLSID\{D5B91409-A8CA-4973-9A0B-59F713D25671}"
    "HKLM\Software\Classes\Wow6432Node\CLSID\{5ED60779-4DE2-4E07-B862-974CA4FF2E9C}"
    "HKLM\Software\Classes\Wow6432Node\CLSID\{07999AC3-058B-40BF-984F-69EB1E554CA7}"
    "HKLM\Software\Classes\Wow6432Node\CLSID\{E8CF4E59-B7A3-41F2-86C7-82B03334F22A}"
    "HKLM\Software\Classes\Wow6432Node\CLSID\{9C9D53D4-A978-43FC-93E2-1C21B529E6D7}"
    "HKLM\Software\Classes\Wow6432Node\CLSID\{79873CC5-3951-43ED-BDF9-D8759474B6FD}"
    "HKLM\Software\Classes\Wow6432Node\CLSID\{E6871B76-C3C8-44DD-B947-ABFFE144860D}"
    "HKCU\Software\Classes\CLSID\{7B8E9164-324D-4A2E-A46D-0165FB2000EC}"
    "HKCU\Software\Classes\CLSID\{6DDF00DB-1234-46EC-8356-27E7B2051192}"
    "HKCU\Software\Classes\CLSID\{D5B91409-A8CA-4973-9A0B-59F713D25671}"
    "HKCU\Software\Classes\CLSID\{5ED60779-4DE2-4E07-B862-974CA4FF2E9C}"
    "HKCU\Software\Classes\CLSID\{07999AC3-058B-40BF-984F-69EB1E554CA7}"
    "HKCU\Software\Classes\CLSID\{E8CF4E59-B7A3-41F2-86C7-82B03334F22A}"
    "HKCU\Software\Classes\CLSID\{9C9D53D4-A978-43FC-93E2-1C21B529E6D7}"
    "HKCU\Software\Classes\CLSID\{79873CC5-3951-43ED-BDF9-D8759474B6FD}"
    "HKCU\Software\Classes\CLSID\{E6871B76-C3C8-44DD-B947-ABFFE144860D}"
    "HKCU\Software\Classes\Wow6432Node\CLSID\{7B8E9164-324D-4A2E-A46D-0165FB2000EC}"
    "HKCU\Software\Classes\Wow6432Node\CLSID\{6DDF00DB-1234-46EC-8356-27E7B2051192}"
    "HKCU\Software\Classes\Wow6432Node\CLSID\{D5B91409-A8CA-4973-9A0B-59F713D25671}"
    "HKCU\Software\Classes\Wow6432Node\CLSID\{5ED60779-4DE2-4E07-B862-974CA4FF2E9C}"
    "HKCU\Software\Classes\Wow6432Node\CLSID\{07999AC3-058B-40BF-984F-69EB1E554CA7}"
    "HKCU\Software\Classes\Wow6432Node\CLSID\{E8CF4E59-B7A3-41F2-86C7-82B03334F22A}"
    "HKCU\Software\Classes\Wow6432Node\CLSID\{9C9D53D4-A978-43FC-93E2-1C21B529E6D7}"
    "HKCU\Software\Classes\Wow6432Node\CLSID\{79873CC5-3951-43ED-BDF9-D8759474B6FD}"
    "HKCU\Software\Classes\Wow6432Node\CLSID\{E6871B76-C3C8-44DD-B947-ABFFE144860D}"
    "HKU\.DEFAULT\Software\Classes\CLSID\{7B8E9164-324D-4A2E-A46D-0165FB2000EC}"
    "HKU\.DEFAULT\Software\Classes\CLSID\{6DDF00DB-1234-46EC-8356-27E7B2051192}"
    "HKU\.DEFAULT\Software\Classes\CLSID\{D5B91409-A8CA-4973-9A0B-59F713D25671}"
    "HKU\.DEFAULT\Software\Classes\CLSID\{5ED60779-4DE2-4E07-B862-974CA4FF2E9C}"
    "HKU\.DEFAULT\Software\Classes\CLSID\{07999AC3-058B-40BF-984F-69EB1E554CA7}"
    "HKU\.DEFAULT\Software\Classes\CLSID\{E8CF4E59-B7A3-41F2-86C7-82B03334F22A}"
    "HKU\.DEFAULT\Software\Classes\CLSID\{9C9D53D4-A978-43FC-93E2-1C21B529E6D7}"
    "HKU\.DEFAULT\Software\Classes\CLSID\{79873CC5-3951-43ED-BDF9-D8759474B6FD}"
    "HKU\.DEFAULT\Software\Classes\CLSID\{E6871B76-C3C8-44DD-B947-ABFFE144860D}"
    "HKU\.DEFAULT\Software\Classes\Wow6432Node\CLSID\{7B8E9164-324D-4A2E-A46D-0165FB2000EC}"
    "HKU\.DEFAULT\Software\Classes\Wow6432Node\CLSID\{6DDF00DB-1234-46EC-8356-27E7B2051192}"
    "HKU\.DEFAULT\Software\Classes\Wow6432Node\CLSID\{D5B91409-A8CA-4973-9A0B-59F713D25671}"
    "HKU\.DEFAULT\Software\Classes\Wow6432Node\CLSID\{5ED60779-4DE2-4E07-B862-974CA4FF2E9C}"
    "HKU\.DEFAULT\Software\Classes\Wow6432Node\CLSID\{07999AC3-058B-40BF-984F-69EB1E554CA7}"
    "HKU\.DEFAULT\Software\Classes\Wow6432Node\CLSID\{E8CF4E59-B7A3-41F2-86C7-82B03334F22A}"
    "HKU\.DEFAULT\Software\Classes\Wow6432Node\CLSID\{9C9D53D4-A978-43FC-93E2-1C21B529E6D7}"
    "HKU\.DEFAULT\Software\Classes\Wow6432Node\CLSID\{79873CC5-3951-43ED-BDF9-D8759474B6FD}"
    "HKU\.DEFAULT\Software\Classes\Wow6432Node\CLSID\{E6871B76-C3C8-44DD-B947-ABFFE144860D}"
    "HKLM\Software\Internet Download Manager"
    "HKLM\Software\Wow6432Node\Internet Download Manager"
    "HKCU\Software\Download Manager"
    "HKCU\Software\Wow6432Node\Download Manager"
) do reg delete %%k /f >nul 2>&1

:: Clean license values
for %%v in ("FName" "LName" "Email" "Serial" "CheckUpdtVM" "tvfrdt" "LstCheck" "scansk" "idmvers") do (
    reg delete "HKCU\Software\DownloadManager" /v %%v /f >nul 2>&1
)

echo %GREEN% Pembersihan registri selesai.%RESET%
exit /b

::----------------------
:quit
echo.
echo %GREEN% Terima kasih telah menggunakan Skrip Aktivasi IDM . Semoga harimu menyenangkan... %RESET%
timeout /t 2 >nul
exit
