@echo off
chcp 65001 >nul
set "start_time="
set "end_time="
set /p "start_time=Начало (формат 00:00:00, Enter = с начала): "
set /p "end_time=Конец (формат 00:00:00, Enter = до конца): "
set "ff_opts="
if defined start_time set "ff_opts=%ff_opts% -ss %start_time%"
if defined end_time set "ff_opts=%ff_opts% -to %end_time%"
set "gop=60"
set /p "gop=Интервал ключевых кадров (по умолчанию Enter = 60; меньше = больше ключевых кадров и лучше перемотка, больше = меньше ключевых кадров и лучше сжатие): "
ffmpeg -i "%~1" %ff_opts% -c:v hevc_nvenc -preset p6 -tune hq -rc vbr_hq -cq 30 -b:v 0 -g %gop% -c:a aac -q:a 2 "%~dpn1_cut.mp4"
echo.
echo Готово! Файл сохранён рядом с оригиналом.
pause