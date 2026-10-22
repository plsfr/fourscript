@echo off
setlocal DisableDelayedExpansion
title FourScript
color 0B
mode con: cols=100

rem ================= SETTINGS =================
set "OUTDIR=W:\Raw videos"
set "DEFAULT_LINKS=%~dp0links.txt"
set "MAXLINKS=100"
rem YouTube "confirm you're not a bot" fix. Use ONE of these:
rem   1) put cookies.txt (Netscape format) next to the script - used automatically
rem   2) or set a browser name here: firefox / chrome / edge / brave / opera
set "COOKIES_FILE=%~dp0cookies.txt"
set "COOKIES_BROWSER="
set "FMT=bv*[height>=720][height<=1080]+ba[abr<=320]/bv*[height>=720][height<=1080]+ba/b[height>=720][height<=1080]"
rem ============================================

rem Allow yt-dlp.exe / ffmpeg.exe lying next to the script
set "PATH=%~dp0;%PATH%"

set "COOKIEARGS="
if exist "%COOKIES_FILE%" set "COOKIEARGS=--cookies "%COOKIES_FILE%""
if not defined COOKIEARGS if defined COOKIES_BROWSER set "COOKIEARGS=--cookies-from-browser %COOKIES_BROWSER%"

set /a TOTAL=0
set /a OKCOUNT=0
set /a FAILCOUNT=0
set /a N=0
set "FAILED="
set "LIMIT="
set "LIMIT2="
set "URL="
set "LINKS="

cls
echo.
echo   +----------------------------------------------+
echo   ^|                                              ^|
echo   ^|            F O U R S C R I P T               ^|
echo   ^|        sequential video downloader           ^|
echo   ^|     yt-dlp + ffmpeg  /  1080p-720p  /  mp4   ^|
echo   ^|                                              ^|
echo   +----------------------------------------------+
echo.

rem ---------- Checks ----------
where yt-dlp >nul 2>&1
if errorlevel 1 (
    echo   [ ERROR ] yt-dlp not found. Install it or put yt-dlp.exe next to the script.
    goto :end
)
where ffmpeg >nul 2>&1
if errorlevel 1 (
    echo   [ ERROR ] ffmpeg not found. Install it or put ffmpeg.exe next to the script.
    goto :end
)
if not exist "W:\" (
    echo   [ ERROR ] Drive W: is not available.
    goto :end
)
if not exist "%OUTDIR%" mkdir "%OUTDIR%"
if not exist "%OUTDIR%" (
    echo   [ ERROR ] Cannot create folder: %OUTDIR%
    goto :end
)

if defined COOKIEARGS (echo   Cookies : enabled) else (echo   Cookies : none)
echo.

rem ---------- Mode selection ----------
echo   Choose mode:
echo.
echo     [1]  One link  - paste a YouTube link
echo     [2]  TXT file  - many links (2 to %MAXLINKS%), one per line
echo.
choice /c 12 /n /m "  Your choice (1 or 2): "
if errorlevel 2 goto :mode_file
goto :mode_single

rem ====================== MODE 1: SINGLE LINK ======================
:mode_single
echo.
set "URL="
set /p "URL=  Paste link and press Enter: "
if not defined URL (
    echo.
    echo   [ ERROR ] No link entered.
    goto :end
)
set /a TOTAL=1
echo.
echo   Save folder : %OUTDIR%
echo   Quality     : 1080p (fallback 720p, never lower) + best audio up to 320 kbps -^> mp4
echo.
call :download
goto :done

rem ====================== MODE 2: TXT FILE ======================
:mode_file
echo.
echo   Drag and drop your .txt file into this window, or type its path.
echo   Press Enter with no input to use links.txt next to the script.
echo.
set "LINKS="
set /p "LINKS=  File: "
if not defined LINKS set "LINKS=%DEFAULT_LINKS%"
set "LINKS=%LINKS:"=%"
if not exist "%LINKS%" (
    echo.
    echo   [ ERROR ] File not found:
    echo             %LINKS%
    goto :end
)

rem ---------- Count links (max 100) ----------
for /f "usebackq tokens=* delims= " %%L in ("%LINKS%") do (
    call :count
    if defined LIMIT goto :counted
)
:counted
if %TOTAL% LSS 1 (
    echo.
    echo   [ ERROR ] The file is empty.
    goto :end
)

echo.
echo   File        : %LINKS%
echo   Links       : %TOTAL%  (limit: %MAXLINKS%)
echo   Save folder : %OUTDIR%
echo   Quality     : 1080p (fallback 720p, never lower) + best audio up to 320 kbps -^> mp4
echo.

rem ---------- Strict sequential queue ----------
for /f "usebackq tokens=* delims= " %%L in ("%LINKS%") do (
    set "URL=%%L"
    call :download
    if defined LIMIT2 goto :done
)

:done
echo.
echo   ==============================================
echo    FINISHED
echo    Successful : %OKCOUNT%
echo    Failed     : %FAILCOUNT%
if defined FAILED echo    Failed items: %FAILED%
echo   ==============================================
goto :end

rem ====================== SUBROUTINES ======================

:count
set /a TOTAL+=1
if %TOTAL% GEQ %MAXLINKS% set "LIMIT=1"
exit /b

:download
set /a N+=1
setlocal EnableDelayedExpansion
echo   ----------------------------------------------
echo    [video !N! of %TOTAL%]
echo    Link   : !URL!
echo    Status : DOWNLOADING...
echo   ----------------------------------------------
yt-dlp --no-playlist --windows-filenames --merge-output-format mp4 ^
  -f "%FMT%" ^
  %COOKIEARGS% ^
  -P "%OUTDIR%" ^
  -o "%%(title).150B [%%(id)s].%%(ext)s" ^
  "!URL!"
set "RC=!errorlevel!"
endlocal & set "LASTRC=%RC%"

if "%LASTRC%"=="0" (
    set /a OKCOUNT+=1
    echo.
    echo    Status : [ OK ]  video %N% of %TOTAL% downloaded
) else (
    set /a FAILCOUNT+=1
    set "FAILED=%FAILED% %N%"
    echo.
    echo    Status : [ FAILED ]  video %N% of %TOTAL% - see the error above.
    echo             Skipping to the next one.
)
echo.
if %N% GEQ %TOTAL% set "LIMIT2=1"
exit /b

:end
echo.
echo   Press any key to close this window...
pause >nul
endlocal
exit /b
