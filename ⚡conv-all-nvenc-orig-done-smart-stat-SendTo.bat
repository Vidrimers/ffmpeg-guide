@echo off
chcp 65001 >nul
setlocal disabledelayedexpansion

:checkArgs
if "%~1"=="" (
    echo Ошибка: нужно передать папку или файл.
    echo Положите ярлык этого скрипта в папку shell:sendto и выбирайте папку правой кнопкой.
    pause
    exit /b 1
)

set "target=%~1"
if exist "%target%\*" (
    set "folder=%~1"
) else if exist "%target%" (
    for %%F in ("%~1") do set "folder=%%~dpF"
) else (
    echo Ошибка: путь не найден: %~1
    pause
    exit /b 1
)

echo.
echo Скрипт запускается из: %~dp0
echo Целевая папка для обработки: %folder%
for /f %%x in ('dir /a:-d /b "%folder%" ^| find /c /v ""') do set "total_files_count=%%x"
set "mp4_count=0"
pushd "%folder%"
for %%f in (*.mp4) do set /a mp4_count+=1
popd

echo Всего файлов в папке: %total_files_count%
echo Всего MP4 файлов: %mp4_count%
if %mp4_count% equ 0 (
    echo Нет MP4 файлов для обработки.
    pause
    exit /b 0
)

echo.
set "gop=60"
set /p "gop=Интервал ключевых кадров (меньше = больше ключевых кадров и лучше перемотка, больше = меньше ключевых кадров и лучше сжатие / Enter = 60): "
set "shutdown_choice=n"
set /p "shutdown_choice=Выключить ПК после завершения? (y - сразу / n - не выключать / число - через N минут, Enter = n): "
set /p "overwrite_choice=Если файл уже существует в converted (y - перезаписать все / n - пропускать все / Enter = спрашивать каждый раз): "

echo.
if /i "%shutdown_choice%"=="y" (
    echo ВНИМАНИЕ: после завершения конвертации ПК будет выключен.
) else if /i "%shutdown_choice%"=="n" (
    echo ВНИМАНИЕ: ПК НЕ будет выключаться после завершения.
) else (
    echo ВНИМАНИЕ: ПК будет выключен через %shutdown_choice% минут после завершения.
)

echo.
set "overwrite_flag="
if /i "%overwrite_choice%"=="y" set "overwrite_flag=-y"
if /i "%overwrite_choice%"=="n" set "overwrite_flag=-n"

:processNext
if "%~1"=="" goto end

set "target=%~1"
if exist "%target%\*" (
    set "folder=%~1"
) else if exist "%target%" (
    for %%F in ("%~1") do set "folder=%%~dpF"
) else (
    echo Пропускаю несуществующий путь: %~1
    shift
    goto processNext
)

pushd "%folder%"
setlocal enabledelayedexpansion
mkdir converted 2>nul
mkdir done 2>nul

set "log=conversion_report.txt"
set "total_files=0"
set "skipped_files=0"
set "skipped_list="

:: Время начала
set "start_time=%time%"
for /f "tokens=1-3 delims=:," %%a in ("%time%") do (
    set /a start_h=%%a
    set /a start_m=%%b
    set /a start_s=%%c
)
set /a start_total=start_h*3600+start_m*60+start_s

echo ===================================== > %log%
echo  Отчёт конвертации FFmpeg NVENC >> %log%
echo ===================================== >> %log%
echo Начало: %date% %start_time% >> %log%
echo. >> %log%
echo Файлы: >> %log%
echo --------------------------------------- >> %log%

for %%f in (*.mp4) do (
    set /a total_files+=1
    for %%a in ("%%f") do set "original_size=%%~za"

    rem first try avg_frame_rate (more reliable); fallback to r_frame_rate if avg is empty or 0/0
    ffprobe -v quiet -select_streams v:0 -show_entries stream=avg_frame_rate -of csv="p=0" "%%f" > "%temp%\fps_tmp.txt"
    set /p fps_raw= < "%temp%\fps_tmp.txt"
    if "!fps_raw!"=="" (
        ffprobe -v quiet -select_streams v:0 -show_entries stream=r_frame_rate -of csv="p=0" "%%f" > "%temp%\fps_tmp.txt"
        set /p fps_raw= < "%temp%\fps_tmp.txt"
    )
    if "!fps_raw!"=="0/0" (
        ffprobe -v quiet -select_streams v:0 -show_entries stream=r_frame_rate -of csv="p=0" "%%f" > "%temp%\fps_tmp.txt"
        set /p fps_raw= < "%temp%\fps_tmp.txt"
    )
    set "fps_decimal="
    set "fps_int=0"
    rem compute integer fps via PowerShell to handle fractions reliably
    for /f "usebackq delims=" %%F in (`powershell -NoProfile -Command "$s = Get-Content -LiteralPath '%temp%\fps_tmp.txt' -Raw; $s = $s.Trim(); if ($s -match '/'){ $p = $s -split '/'; if ([double]$p[1] -ne 0){ [math]::Floor([double]$p[0]/[double]$p[1]) } else { [math]::Floor([double]$p[0]) } } elseif ($s -match '^[0-9]+(\.[0-9]+)?$'){ [math]::Floor([double]$s) } else { 30 }"`) do set "fps_int=%%F"
    for /f "usebackq delims=" %%G in (`powershell -NoProfile -Command "$s = Get-Content -LiteralPath '%temp%\fps_tmp.txt' -Raw; $s = $s.Trim(); if ($s -match '/'){ $p = $s -split '/'; if ([double]$p[1] -ne 0){ $v=[double]$p[0]/[double]$p[1] } else { $v=[double]$p[0] } } elseif ($s -match '^[0-9]+(\.[0-9]+)?$'){ $v=[double]$s } else { $v=30 }; '{0:F3}' -f $v"`) do set "fps_decimal=%%G"
    if not defined fps_decimal set "fps_decimal=!fps_int!"

    if !fps_int! gtr 30 (
        set "fps_flag=-r 30"
        set "fps_info=!fps_decimal!fps -^> 30fps"
    ) else (
        set "fps_flag="
        set "fps_info=!fps_decimal!fps оставлен"
    )

    ffmpeg %overwrite_flag% -i "%%f" !fps_flag! -c:v hevc_nvenc -preset p6 -tune hq -rc vbr_hq -cq 30 -b:v 0 -g !gop! -c:a aac -q:a 2 "converted\%%f"
    for %%b in ("converted\%%f") do set "converted_size=%%~zb"

    set /a orig_kb=!original_size!/1024
    set /a conv_kb=!converted_size!/1024
    set /a orig_mb=!orig_kb!/1024
    set /a conv_mb=!conv_kb!/1024

    if !orig_kb! gtr 1023 (
        set "orig_fmt=!orig_mb! МБ"
    ) else (
        set "orig_fmt=!orig_kb! КБ"
    )

    if !conv_kb! gtr 1023 (
        set "conv_fmt=!conv_mb! МБ"
    ) else (
        set "conv_fmt=!conv_kb! КБ"
    )

    if !converted_size! gtr !original_size! (
        set /a skipped_files+=1
        set "skipped_list=!skipped_list! "%%f""
        del "converted\%%f" 2>nul
        copy "%%f" "converted\%%~nf_skip%%~xf" >nul
        move "%%f" "done\%%f" >nul
        echo %%f >> %log%
        echo   FPS:         !fps_info! >> %log%
        echo   Raw FPS:     !fps_raw! >> %log%
        echo   Оригинал:    !orig_fmt! >> %log%
        echo   Результат:   !conv_fmt! >> %log%
        echo   Статус:      ПРОПУЩЕН >> %log%
        echo. >> %log%
    ) else (
        move "%%f" "done\%%f" >nul
        echo %%f >> %log%
        echo   FPS:         !fps_info! >> %log%
        echo   Raw FPS:     !fps_raw! >> %log%
        echo   Оригинал:    !orig_fmt! >> %log%
        echo   Результат:   !conv_fmt! >> %log%
        echo   Статус:      OK >> %log%
        echo. >> %log%
    )
)

:: Время конца
set "end_time=%time%"
for /f "tokens=1-3 delims=:," %%a in ("%time%") do (
    set /a end_h=%%a
    set /a end_m=%%b
    set /a end_s=%%c
)
set /a end_total=end_h*3600+end_m*60+end_s
set /a elapsed=end_total-start_total
set /a elapsed_h=elapsed/3600
set /a elapsed_m=(elapsed%%3600)/60
set /a elapsed_s=elapsed%%60

for /f "delims=" %%s in ('powershell -command "$s=(Get-ChildItem done -Recurse -ErrorAction SilentlyContinue|Measure-Object -Property Length -Sum).Sum; if($s -ge 1GB){'{0:N2} GB' -f ($s/1GB)}elseif($s -ge 1MB){'{0:N0} MB' -f ($s/1MB)}else{'{0:N0} KB' -f ($s/1KB)}"') do set "done_fmt=%%s"
for /f "delims=" %%s in ('powershell -command "$s=(Get-ChildItem converted -Recurse -ErrorAction SilentlyContinue|Measure-Object -Property Length -Sum).Sum; if($s -ge 1GB){'{0:N2} GB' -f ($s/1GB)}elseif($s -ge 1MB){'{0:N0} MB' -f ($s/1MB)}else{'{0:N0} KB' -f ($s/1KB)}"') do set "conv_fmt=%%s"

if not defined done_fmt set "done_fmt=0 KB"
if not defined conv_fmt set "conv_fmt=0 KB"

echo --------------------------------------- >> %log%
echo  Итог >> %log%
echo --------------------------------------- >> %log%
echo Начало:             %start_time% >> %log%
echo Конец:              %end_time% >> %log%
echo Затрачено:          %elapsed_h%ч %elapsed_m%м %elapsed_s%с >> %log%
echo. >> %log%
echo Всего файлов:       %total_files% >> %log%
echo Пропущено:          %skipped_files% >> %log%
echo. >> %log%
echo Оригиналы (done):   %done_fmt% >> %log%
echo Сжатые (converted): %conv_fmt% >> %log%
echo. >> %log%
if not "!skipped_list!"=="" echo Пропущенные файлы: >> %log%
if not "!skipped_list!"=="" echo !skipped_list! >> %log%
echo ===================================== >> %log%

echo.
echo Готово! Отчёт сохранён в %log%
endlocal
popd
shift
goto processNext

:end
if /i "%shutdown_choice%"=="y" goto shutdown_now
if /i "%shutdown_choice%"=="n" goto no_shutdown
goto shutdown_timer

:shutdown_now
echo ПК выключится через 10 секунд...
shutdown /s /t 10
goto end2

:shutdown_timer
if not defined shutdown_choice (
    echo Неправильное значение для выключения: пусто. ПК не будет выключен.
    goto no_shutdown
)
echo %shutdown_choice% | findstr /r "^[0-9][0-9]*$" >nul
if errorlevel 1 (
    echo Неправильное значение для выключения: %shutdown_choice%. ПК не будет выключен.
    goto no_shutdown
)
set /a shutdown_seconds=%shutdown_choice%*60
echo ПК выключится через %shutdown_choice% минут...
shutdown /s /t %shutdown_seconds%
goto end2

:no_shutdown
echo ПК не будет выключен.

:end2
echo Для отмены выключения выполните: shutdown /a
pause