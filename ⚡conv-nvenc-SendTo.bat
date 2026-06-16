@echo off
chcp 65001 >nul
setlocal DISABLEDELAYEDEXPANSION

echo.
set "gop=60"
set /p "gop=Интервал ключевых кадров (меньше = больше ключевых кадров и лучше перемотка, больше = меньше ключевых кадров и лучше сжатие / Enter = 60): "
if "%gop%"=="" set "gop=60"

set "file=%~1"
set "fps_int=0"
set "fps_value="
set "desired_fps="
ffprobe -v quiet -select_streams v:0 -show_entries stream=r_frame_rate -of csv="p=0" "%file%" > "%temp%\fps_tmp.txt"
for /f "usebackq delims=" %%A in ("%temp%\fps_tmp.txt") do set "fps_raw=%%A"

setlocal ENABLEDELAYEDEXPANSION
set "fps_raw=!fps_raw: =!"
if not "!fps_raw!"=="" (
    if not "!fps_raw:/=!"=="!fps_raw!" (
        for /f "tokens=1,2 delims=/" %%n in ("!fps_raw!") do (
            set /a fps_num=%%n
            set /a fps_den=%%o
        )
        if !fps_den! equ 0 set "fps_den=1"
        set /a fps_int=!fps_num!/!fps_den!
        set "fps_value=!fps_int!"
    ) else if not "!fps_raw:.=!"=="!fps_raw!" (
        set "tmp_fps=!fps_raw:.=!"
        echo !tmp_fps! | findstr /r "^[0-9][0-9]*$" >nul
        if not errorlevel 1 set "fps_value=!fps_raw!"
    ) else (
        echo !fps_raw! | findstr /r "^[0-9][0-9]*$" >nul
        if not errorlevel 1 set "fps_value=!fps_raw!"
    )
)

if defined fps_value (
    set /p "desired_fps=Обнаружено !fps_value! fps. Введите другое значение или нажмите Enter для подтверждения: "
    if "!desired_fps!"=="" set "desired_fps=!fps_value!"
) else (
    set /p "desired_fps=Не удалось определить FPS. Введите желаемый FPS (Enter = 30): "
    if "!desired_fps!"=="" set "desired_fps=30"
)

powershell -NoProfile -Command "$fps='!desired_fps!'; if ($fps -match '^\d+(\.\d+)?$' -and [double]$fps -gt 0) { exit 0 } else { exit 1 }"
if errorlevel 1 (
    echo Неверный ввод fps, будет использован 30.
    set "desired_fps=30"
)

endlocal & set "desired_fps=%desired_fps%"

:: --- Определение разрешения ---
set "res_raw="
ffprobe -v quiet -select_streams v:0 -show_entries stream=width,height -of csv="p=0:s=x" "%file%" > "%temp%\res_tmp.txt" 2>nul
for /f "usebackq delims=" %%A in ("%temp%\res_tmp.txt") do set "res_raw=%%A"

setlocal ENABLEDELAYEDEXPANSION
echo.
echo -----------------------------------------------
if defined res_raw (
    echo  Текущее разрешение видео: !res_raw!
) else (
    echo  Текущее разрешение: не удалось определить
)
echo -----------------------------------------------
echo  Как изменить разрешение:
echo   1920        — только ширина, высота подбирается
echo                 автоматически с сохранением пропорций
echo   1920x1080   — точное разрешение (может обрезать или
echo                 растянуть, если пропорции не совпадают)
echo   Enter       — оставить разрешение без изменений
echo.
set "desired_res="
set /p "desired_res=Новое разрешение (Enter = без изменений): "

set "scale_filter="
if not "!desired_res!"=="" (
    echo !desired_res! | findstr /r "[xX]" >nul
    if not errorlevel 1 (
        set "scale_wh=!desired_res!"
        set "scale_wh=!scale_wh:x=:!"
        set "scale_wh=!scale_wh:X=:!"
        set "scale_filter=-vf scale=!scale_wh!"
    ) else (
        set "scale_filter=-vf scale=!desired_res!:-2"
    )
)

endlocal & set "desired_fps=%desired_fps%" & set "scale_filter=%scale_filter%"

echo.
ffmpeg -i "%file%" %scale_filter% -c:v hevc_nvenc -preset p6 -tune hq -rc vbr_hq -cq 30 -b:v 0 -g %gop% -r %desired_fps% -c:a aac -q:a 2 "%~dpn1_converted.mp4"
echo.
echo Готово! Файл сохранён рядом с оригиналом.
pause