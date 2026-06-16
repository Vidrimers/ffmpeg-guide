# 🎬 FFmpeg — Полное руководство

> **Интерактивная шпаргалка с конструктором команд:** [ffmpeg-commander.com](https://ffmpeg-commander.com/)

> **Веб-интерфейс ffmpeg-commander** — простой GUI для генерации типовых операций кодирования FFmpeg (по мотивам HandBrake). Подробнее: [readme-ffcommander.md](./readme-ffcommander.md)

---

## Содержание

1. [Что такое FFmpeg](#что-такое-ffmpeg)
2. [Установка](#установка)
   - [Windows](#windows)
   - [macOS](#macos)
   - [Linux](#linux)
3. [Основные концепции](#основные-концепции)
4. [Синтаксис команд](#синтаксис-команд)
5. [Глобальные параметры](#глобальные-параметры)
6. [Кодеки и форматы](#кодеки-и-форматы)
7. [Конвертация видео](#конвертация-видео)
8. [Конвертация аудио](#конвертация-аудио)
9. [Работа с изображениями](#работа-с-изображениями)
10. [Фильтры и обработка видео](#фильтры-и-обработка-видео)
11. [Обрезка и монтаж](#обрезка-и-монтаж)
12. [Водяные знаки и субтитры](#водяные-знаки-и-субтитры)
13. [Сжатие и качество](#сжатие-и-качество)
14. [Аппаратное ускорение](#аппаратное-ускорение)
15. [Запись экрана и стриминг](#запись-экрана-и-стриминг)
16. [Пакетная обработка](#пакетная-обработка)
17. [Диагностика и анализ файлов](#диагностика-и-анализ-файлов)
18. [Частые ошибки и решения](#частые-ошибки-и-решения)
19. [Лайфхак для Windows: запуск через правую кнопку мыши](#лайфхак-для-windows-запуск-через-правую-кнопку-мыши)

---

## Что такое FFmpeg

FFmpeg — бесплатный кроссплатформенный инструмент с открытым исходным кодом для записи, конвертации и стриминга аудио и видео. Он поддерживает практически любые форматы и кодеки и является «движком» под капотом у огромного числа приложений: OBS Studio, VLC, Handbrake, YouTube, FFmpeg используют крупнейшие стриминговые платформы.

**Три основных компонента:**

- `ffmpeg` — основной инструмент конвертации и обработки медиафайлов
- `ffprobe` — анализатор медиафайлов (получение информации о потоках)
- `ffplay` — простой медиаплеер на базе FFmpeg

**Актуальная версия (2025):** FFmpeg 8.0 "Huffman"

---

## Установка

### Windows

#### Способ 1: Через пакетный менеджер (рекомендуется)

```powershell
# Через winget (встроен в Windows 10/11)
winget install "FFmpeg (Essentials Build)"

# Через Chocolatey
choco install ffmpeg           # Essentials-сборка
choco install ffmpeg-full      # Полная сборка со всеми кодеками

# Через Scoop
scoop install ffmpeg
scoop install ffmpeg-gyan-nightly  # Ежедневные сборки с Git
```

#### Способ 2: Ручная установка

1. Скачайте архив с [gyan.dev](https://www.gyan.dev/ffmpeg/builds/):
   
   - `ffmpeg-release-essentials.zip` — базовые кодеки (~27 МБ)
   - `ffmpeg-release-full.zip` — все кодеки

2. Распакуйте в папку, например `C:\ffmpeg\`

3. Добавьте `C:\ffmpeg\bin` в переменную PATH:

```powershell
# В PowerShell с правами администратора
$ffmpeg = 'C:\ffmpeg\bin'
$path = [Environment]::GetEnvironmentVariable('Path', 'Machine').TrimEnd([Char]';')
[Environment]::SetEnvironmentVariable("Path", "$path;$ffmpeg", 'Machine')
```

4. Проверьте установку (откройте новое окно командной строки):

```cmd
ffmpeg -version
```

---

### macOS

#### Через Homebrew (рекомендуется)

```bash
# Установка Homebrew (если не установлен)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Установка FFmpeg
brew install ffmpeg

# С дополнительными кодеками (fdk-aac и др.)
brew tap homebrew-ffmpeg/ffmpeg
brew install homebrew-ffmpeg/ffmpeg/ffmpeg --with-fdk-aac

# Обновление
brew update && brew upgrade ffmpeg

# Проверка
ffmpeg -version
```

#### Ручная установка (статическая сборка)

```bash
curl -O https://evermeet.cx/ffmpeg/ffmpeg-latest.zip
unzip ffmpeg-latest.zip
sudo cp ffmpeg /usr/local/bin/
sudo chmod +x /usr/local/bin/ffmpeg
```

---

### Linux

#### Debian / Ubuntu

```bash
# Из официальных репозиториев
sudo apt update
sudo apt install ffmpeg

# Последняя версия через PPA
sudo add-apt-repository ppa:savoury1/ffmpeg4
sudo apt update && sudo apt install ffmpeg

# Через Snap
sudo snap install ffmpeg
```

#### Fedora / CentOS / RHEL

```bash
# Подключаем RPM Fusion
sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Устанавливаем FFmpeg
sudo dnf install ffmpeg ffmpeg-devel
```

#### Arch Linux

```bash
sudo pacman -S ffmpeg
```

#### Статическая сборка (для любого дистрибутива)

```bash
wget https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz
tar -xf ffmpeg-release-amd64-static.tar.xz
sudo cp ffmpeg-*-static/ffmpeg /usr/local/bin/
sudo cp ffmpeg-*-static/ffprobe /usr/local/bin/
sudo chmod +x /usr/local/bin/ffmpeg /usr/local/bin/ffprobe

# Проверка
ffmpeg -version
```

---

## Основные концепции

### Контейнеры и кодеки

**Контейнер** — формат файла, который содержит один или несколько потоков (видео, аудио, субтитры):

| Контейнер | Расширение | Применение                                   |
| --------- | ---------- | -------------------------------------------- |
| MP4       | `.mp4`     | Универсальная совместимость, веб, устройства |
| MKV       | `.mkv`     | Гибкий формат, поддерживает любые кодеки     |
| WebM      | `.webm`    | Открытый формат для веб (VP8/VP9 + Opus)     |
| MOV       | `.mov`     | Формат Apple, Final Cut Pro                  |
| AVI       | `.avi`     | Устаревший формат, широкая совместимость     |
| TS        | `.ts`      | Транспортный поток, IPTV, вещание            |
| FLV       | `.flv`     | Flash-видео, устаревший                      |

**Видеокодеки** — алгоритмы сжатия видео:

| Кодек      | Параметр FFmpeg | Описание                                 |
| ---------- | --------------- | ---------------------------------------- |
| H.264      | `libx264`       | Наиболее совместимый, хорошее сжатие     |
| H.265/HEVC | `libx265`       | Вдвое лучше сжатие, меньше совместимость |
| VP9        | `libvpx-vp9`    | Открытый аналог H.265, YouTube           |
| AV1        | `libaom-av1`    | Новейший, отличное сжатие, медленный     |
| ProRes     | `prores_ks`     | Профессиональный, Apple, постобработка   |
| MPEG-4     | `mpeg4`         | Устаревший, xvid/divx                    |

**Аудиокодеки:**

| Кодек  | Параметр FFmpeg | Описание                            |
| ------ | --------------- | ----------------------------------- |
| AAC    | `aac`           | Современный, широко поддерживается  |
| MP3    | `libmp3lame`    | Устаревший, универсальный           |
| Opus   | `libopus`       | Лучшее качество при низком битрейте |
| FLAC   | `flac`          | Без потерь, архивирование           |
| AC3    | `ac3`           | Dolby Digital, DVD/Blu-ray          |
| Vorbis | `libvorbis`     | Открытый, для WebM                  |

### Типы потоков

- `v` — видео поток
- `a` — аудио поток
- `s` — субтитры
- `d` — данные (data)

### Выбор потоков (Stream Specifiers)

```
0:0      # Первый поток первого входного файла
0:v:0    # Первый видеопоток первого входного файла
0:a:1    # Второй аудиопоток первого входного файла
1:a      # Все аудиопотоки второго входного файла
```

---

## Синтаксис команд

Базовая структура любой команды FFmpeg:

```bash
ffmpeg [глобальные_параметры] {[параметры_входа] -i входной_файл} ... {[параметры_выхода] выходной_файл} ...
```

**Важные правила:**

- Параметры применяются к **следующему** указанному файлу
- **Порядок важен**: параметры входа — до `-i`, параметры выхода — перед именем выходного файла
- Поддерживается несколько входных и выходных файлов

```bash
# Простейшая конвертация
ffmpeg -i input.mp4 output.avi

# Полная команда с параметрами
ffmpeg -y -hide_banner -i input.mp4 -c:v libx264 -crf 23 -c:a aac -b:a 128k output.mp4

# Несколько входных файлов
ffmpeg -i video.mp4 -i audio.mp3 -c copy output.mkv
```

---

## Глобальные параметры

```bash
-y                    # Перезаписать выходные файлы без подтверждения
-n                    # Не перезаписывать выходные файлы
-hide_banner          # Скрыть баннер (версию и конфигурацию)
-loglevel quiet       # Только ошибки
-loglevel verbose     # Подробный вывод
-loglevel debug       # Отладочный вывод
-stats                # Показывать прогресс кодирования
-threads 0            # Автоматически выбрать число потоков
-threads 4            # Использовать 4 потока
-progress pipe:1      # Вывод прогресса в stdout (для скриптов)
```

---

## Кодеки и форматы — справочник параметров

### Управление качеством видео

```bash
# CRF (Constant Rate Factor) — качество от 0 до 51, меньше = лучше
-crf 18      # Визуально без потерь (H.264)
-crf 23      # По умолчанию (H.264)
-crf 28      # По умолчанию (H.265)
-crf 51      # Минимальное качество

# Фиксированный битрейт
-b:v 2M      # 2 Мбит/с для видео
-b:v 500k    # 500 кбит/с для видео

# Двупроходное кодирование (лучше при фиксированном битрейте)
ffmpeg -i input.mp4 -c:v libx264 -b:v 2M -pass 1 -f null /dev/null
ffmpeg -i input.mp4 -c:v libx264 -b:v 2M -pass 2 output.mp4
```

### Управление качеством аудио

> ⚠️ **Важно: не используйте `-b:a` (ABR) для аудио без необходимости**, особенно с кодеком AAC. В режиме ABR кодек гонится за битрейтом, а не за качеством. Результат — при одинаковом битрейте качество может быть вдвое хуже (в дБ пиковых искажений), чем при VBR.

**ABR (Average Bitrate) — плохо для AAC:**

```bash
# ❌ Так делать не стоит — ABR, кодек думает о битрейте, не о качестве
ffmpeg -i input.mp4 -c:a aac -b:a 256k output.mp4
```

**VBR (`-q:a`) — правильный способ:**

```bash
# ✅ Так правильно — VBR, кодек думает о качестве
ffmpeg -i input.mp4 -c:a aac -q:a 2 output.mp4
```

Кодек сам решает, сколько бит выделить на каждый момент: на тихих участках тратит меньше, на сложных — больше. Итоговый битрейт будет примерно таким же, как при ABR, но качество — значительно выше.

**Шкала `-q:a` для разных кодеков:**

| Кодек                | Параметр | Диапазон | Рекомендация                              |
| -------------------- | -------- | -------- | ----------------------------------------- |
| AAC (`aac`)          | `-q:a`   | 0.1–2    | `-q:a 1` — высокое, `-q:a 2` — хорошее    |
| MP3 (`libmp3lame`)   | `-q:a`   | 0–9      | `-q:a 0` — лучшее, `-q:a 4` — стандартное |
| Vorbis (`libvorbis`) | `-q:a`   | -1–10    | `-q:a 6` — хорошее, `-q:a 8` — высокое    |

**Сравнение аудиокодеков:**

| Кодек      | Сильные стороны             | Когда использовать                                                       |
| ---------- | --------------------------- | ------------------------------------------------------------------------ |
| **AAC**    | Широкая совместимость       | MP4, универсально, с `-q:a`                                              |
| **MP3**    | Универсальность             | Совместимость со старыми устройствами, с `-q:a 0` даёт отличное качество |
| **Opus**   | Лучший на низких битрейтах  | До 128 кбит/с — вне конкуренции                                          |
| **Vorbis** | Недооценённый, отличный VBR | WebM, OGG, хорош при `-q:a 6–8`                                          |
| **FLAC**   | Без потерь                  | Архивирование, мастер-копии                                              |

> **Нюанс:** MP3 с правильным VBR (`-q:a 0`) на битрейтах до 320 кбит/с может звучать лучше, чем Opus или AAC с неправильно заданными параметрами. Opus раскрывается именно на низких битрейтах (64–128 кбит/с), а не на высоких.

```bash
-ar 44100    # Частота дискретизации 44100 Гц (CD)
-ar 48000    # Частота дискретизации 48000 Гц (профессиональная)
-ac 2        # Стерео
-ac 1        # Моно
```

### Скорость кодирования (preset)

```bash
# Только для libx264 и libx265
-preset ultrafast   # Быстрее всего, большой размер файла
-preset superfast
-preset veryfast
-preset faster
-preset fast
-preset medium      # Баланс (по умолчанию)
-preset slow
-preset slower
-preset veryslow    # Медленнее всего, минимальный размер файла
```

### Копирование без перекодирования

```bash
-c copy          # Копировать все потоки без перекодирования
-c:v copy        # Копировать только видеопоток
-c:a copy        # Копировать только аудиопоток
-vn              # Убрать видео из выхода
-an              # Убрать аудио из выхода
-sn              # Убрать субтитры из выхода
```

---

## Конвертация видео

### Базовые конвертации форматов

```bash
# MKV → MP4 (копирование потоков, без перекодирования, мгновенно)
ffmpeg -i input.mkv -c copy output.mp4

# MKV → MP4 (перекодирование для совместимости)
ffmpeg -i input.mkv -c:v libx264 -crf 23 -c:a aac -movflags +faststart output.mp4

# MOV → MP4
ffmpeg -i input.mov -c copy output.mp4

# AVI → MP4
ffmpeg -i input.avi -c:v libx264 -crf 23 -c:a aac output.mp4

# WebM → MP4
ffmpeg -i input.webm -c:v libx264 -preset slow -crf 22 -c:a aac -b:a 128k output.mp4

# MP4 → WebM (для веб)
ffmpeg -i input.mp4 -c:v libvpx-vp9 -crf 30 -b:v 0 -c:a libopus output.webm

# MP4 → GIF (анимированный)
ffmpeg -i input.mp4 -vf "fps=15,scale=480:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" output.gif

# MP4 → MKV
ffmpeg -i input.mp4 -c copy output.mkv

# Конвертация с изменением разрешения
ffmpeg -i input.mp4 -c:v libx264 -crf 23 -vf scale=1280:720 -c:a copy output.mp4
```

### Конвертация в H.265/HEVC (лучшее сжатие)

```bash
# Базовая конвертация
ffmpeg -i input.mp4 -c:v libx265 -crf 28 -c:a aac -b:a 128k output.mp4

# -b:a 128k — фиксированный битрейт, кодек думает о цифре.
# -q:a 2 — переменный битрейт, кодек думает о качестве.
# Размер файла примерно одинаковый, качество звука лучше.
ffmpeg -i input.mp4 -c:v libx265 -crf 28 -c:a aac -q:a 2 output.mp4

# С тегами для совместимости с Apple
ffmpeg -i input.mp4 -c:v libx265 -crf 28 -tag:v hvc1 -c:a aac output.mp4

# Высокое качество
ffmpeg -i input.mp4 -c:v libx265 -crf 18 -preset slow -c:a copy output.mp4
```

### Конвертация в AV1 (новейший кодек)

```bash
# libaom-av1 (медленный, но лучшее качество)
ffmpeg -i input.mp4 -c:v libaom-av1 -crf 30 -b:v 0 -c:a libopus output.mp4

# SVT-AV1 (быстрее)
ffmpeg -i input.mp4 -c:v libsvtav1 -crf 30 -c:a libopus output.mp4
```

### Изменение разрешения и соотношения сторон

```bash
# Масштабирование до конкретного разрешения
ffmpeg -i input.mp4 -vf "scale=1920:1080" output.mp4

# Масштабирование с сохранением пропорций (авто высота)
ffmpeg -i input.mp4 -vf "scale=1280:-1" output.mp4

# Масштабирование с сохранением пропорций (кратно 2, для кодека)
ffmpeg -i input.mp4 -vf "scale=1280:-2" output.mp4

# Масштабирование до 50% от оригинала
ffmpeg -i input.mp4 -vf "scale=iw*0.5:ih*0.5" output.mp4

# 4K → 1080p
ffmpeg -i input_4k.mp4 -vf "scale=1920:1080" -c:v libx264 -crf 20 -c:a copy output_1080p.mp4

# Вертикальное видео для Instagram (9:16)
ffmpeg -i input.mp4 -vf "scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2" output_vertical.mp4
```

### Алгоритмы масштабирования (flags)

> ⚠️ **Важно: не используйте bicubic при увеличении.** Это алгоритм по умолчанию в FFmpeg, и он даёт замыливание — особенно заметное при увеличении изображения. Это распространённая ошибка при кодировании.

FFmpeg позволяет явно указать алгоритм через `flags=`:

| Алгоритм   | Когда использовать                                                            |
| ---------- | ----------------------------------------------------------------------------- |
| `lanczos`  | ✅ Лучший выбор для **уменьшения** — резкий, минимум артефактов                |
| `spline`   | ✅ Хорош для **увеличения** — меньше замыливания чем bicubic                   |
| `bicubic`  | ⚠️ По умолчанию — допустим только при уменьшении высококонтрастной 3D-графики |
| `bilinear` | Быстрый, но низкое качество — только для превью                               |
| `neighbor` | Пиксельный (без сглаживания) — для pixel-art                                  |

```bash
# ✅ Рекомендуется для уменьшения (4K → 1080p и т.д.)
ffmpeg -i input.mp4 -vf "scale=1280:720:flags=lanczos" output.mp4

# ✅ Для увеличения
ffmpeg -i input.mp4 -vf "scale=3840:2160:flags=spline" output.mp4

# Pixel-art без сглаживания
ffmpeg -i input.mp4 -vf "scale=1920:1080:flags=neighbor" output.mp4

# С сохранением пропорций + lanczos
ffmpeg -i input.mp4 -vf "scale=1280:-2:flags=lanczos" output.mp4
```

### Изменение частоты кадров

```bash
# Изменить FPS
ffmpeg -i input.mp4 -r 30 output.mp4

# С интерполяцией (плавное замедление/ускорение)
ffmpeg -i input.mp4 -vf "fps=60,minterpolate=fps=60:mi_mode=mci" output.mp4

# 60fps → 30fps без перекодирования (дропать кадры)
ffmpeg -i input.mp4 -vf "fps=30" -c:a copy output.mp4
```

### Изменение скорости воспроизведения

```bash
# Ускорить видео в 2 раза
ffmpeg -i input.mp4 -vf "setpts=0.5*PTS" -af "atempo=2.0" output.mp4

# Замедлить в 2 раза
ffmpeg -i input.mp4 -vf "setpts=2.0*PTS" -af "atempo=0.5" output.mp4

# Ускорить в 4 раза (аудио — каскад фильтров, т.к. atempo работает только 0.5–2.0)
ffmpeg -i input.mp4 -vf "setpts=0.25*PTS" -af "atempo=2.0,atempo=2.0" output.mp4
```

---

## Конвертация аудио

### Извлечение аудио из видео

```bash
# Извлечь аудио как MP3
ffmpeg -i input.mp4 -vn -c:a libmp3lame -b:a 192k output.mp3

# Извлечь аудио без перекодирования (быстро)
ffmpeg -i input.mp4 -vn -c:a copy output.aac

# Извлечь аудио как WAV (без потерь)
ffmpeg -i input.mp4 -vn -c:a pcm_s16le output.wav

# Извлечь аудио как FLAC
ffmpeg -i input.mp4 -vn -c:a flac output.flac
```

### Конвертация аудиоформатов

```bash
# WAV → MP3
ffmpeg -i input.wav -c:a libmp3lame -b:a 320k output.mp3

# MP3 → AAC (M4A)
ffmpeg -i input.mp3 -c:a aac -b:a 256k output.m4a

# WAV → FLAC (без потерь)
ffmpeg -i input.wav -c:a flac -compression_level 12 output.flac

# Любой формат → Opus (современный, компактный)
ffmpeg -i input.wav -c:a libopus -b:a 128k output.opus

# MP3 → OGG Vorbis
ffmpeg -i input.mp3 -c:a libvorbis -q:a 6 output.ogg

# Конвертация нескольких аудиодорожек в стерео
ffmpeg -i input.mp4 -ac 2 output.mp4
```

### Обработка аудио

```bash
# Нормализация громкости
ffmpeg -i input.mp3 -af "loudnorm=I=-16:TP=-1.5:LRA=11" output.mp3

# Усиление громкости в 2 раза
ffmpeg -i input.mp3 -af "volume=2.0" output.mp3

# Убрать шум (высокочастотный фильтр)
ffmpeg -i input.mp3 -af "highpass=f=200,lowpass=f=3000" output.mp3

# Слияние видео и отдельного аудио
ffmpeg -i video.mp4 -i audio.mp3 -c:v copy -c:a aac -map 0:v:0 -map 1:a:0 output.mp4

# Задержка аудио на 1 секунду (синхронизация)
ffmpeg -i input.mp4 -af "adelay=1000|1000" output.mp4
```

---

## Работа с изображениями

### Конвертация изображений

```bash
# PNG → JPEG
ffmpeg -i input.png -q:v 2 output.jpg

# JPEG → PNG
ffmpeg -i input.jpg output.png

# JPEG → WebP
ffmpeg -i input.jpg -quality 80 output.webp

# BMP → PNG
ffmpeg -i input.bmp output.png

# Конвертация с изменением размера
ffmpeg -i input.jpg -vf "scale=800:600" output.jpg

# Resize с сохранением пропорций
ffmpeg -i input.jpg -vf "scale=800:-1" output.jpg
```

### Видео → Изображения (покадровое извлечение)

```bash
# Извлечь все кадры как PNG
ffmpeg -i input.mp4 frame_%04d.png

# Извлечь каждую секунду (1 кадр в секунду)
ffmpeg -i input.mp4 -vf "fps=1" frame_%04d.jpg

# Извлечь один кадр в конкретный момент (например, в 00:01:30)
ffmpeg -i input.mp4 -ss 00:01:30 -vframes 1 screenshot.jpg

# Извлечь миниатюру (первый кадр)
ffmpeg -i input.mp4 -vframes 1 thumbnail.jpg

# Извлечь кадры с высоким качеством
ffmpeg -i input.mp4 -vf "fps=1" -q:v 1 frame_%04d.jpg
```

### Изображения → Видео (слайдшоу)

```bash
# Из пронумерованных файлов (frame_0001.jpg, frame_0002.jpg...)
ffmpeg -r 24 -i frame_%04d.jpg -c:v libx264 -pix_fmt yuv420p output.mp4

# Слайдшоу: 5 секунд на каждое изображение
ffmpeg -framerate 1/5 -i frame_%04d.jpg -c:v libx264 -r 30 -pix_fmt yuv420p output.mp4

# Слайдшоу с фоновой музыкой
ffmpeg -framerate 1/5 -i frame_%04d.jpg -i audio.mp3 -c:v libx264 -c:a aac -shortest -pix_fmt yuv420p output.mp4

# Из списка файлов (разные имена)
# Создайте файл list.txt:
# file 'photo1.jpg'
# duration 5
# file 'photo2.jpg'
# duration 5
ffmpeg -f concat -safe 0 -i list.txt -c:v libx264 -pix_fmt yuv420p output.mp4
```

### Изменение формата и качества изображений

```bash
# Изменить качество JPEG (2-31, меньше = лучше)
ffmpeg -i input.jpg -q:v 2 output.jpg    # Высокое качество
ffmpeg -i input.jpg -q:v 10 output.jpg   # Среднее качество

# Конвертировать в WebP с заданным качеством
ffmpeg -i input.png -quality 85 output.webp

# Batch-конвертация PNG → JPEG
for f in *.png; do ffmpeg -i "$f" "${f%.png}.jpg"; done
```

---

## Фильтры и обработка видео

Фильтры применяются через параметр `-vf` (video filter) или `-filter_complex` (для сложных цепочек).

### Кадрирование (crop)

```bash
# Обрезать до 1280x720, начиная с позиции (100, 50)
ffmpeg -i input.mp4 -vf "crop=1280:720:100:50" output.mp4

# Обрезать по центру
ffmpeg -i input.mp4 -vf "crop=1280:720:(iw-1280)/2:(ih-720)/2" output.mp4

# Квадратный кроп (для Instagram)
ffmpeg -i input.mp4 -vf "crop=ih:ih" output.mp4
```

### Поворот и отражение

```bash
# Повернуть на 90° по часовой
ffmpeg -i input.mp4 -vf "transpose=1" output.mp4

# Повернуть на 90° против часовой
ffmpeg -i input.mp4 -vf "transpose=2" output.mp4

# Повернуть на 180°
ffmpeg -i input.mp4 -vf "transpose=1,transpose=1" output.mp4
# или
ffmpeg -i input.mp4 -vf "rotate=PI" output.mp4

# Отразить по горизонтали (зеркало)
ffmpeg -i input.mp4 -vf "hflip" output.mp4

# Отразить по вертикали
ffmpeg -i input.mp4 -vf "vflip" output.mp4
```

### Цветокоррекция и фильтры

```bash
# Яркость, контраст, насыщенность
ffmpeg -i input.mp4 -vf "eq=brightness=0.1:contrast=1.2:saturation=1.5" output.mp4

# Оттенки серого (чёрно-белое)
ffmpeg -i input.mp4 -vf "hue=s=0" output.mp4

# Сепия
ffmpeg -i input.mp4 -vf "colorchannelmixer=.393:.769:.189:0:.349:.686:.168:0:.272:.534:.131" output.mp4

# Настройка гаммы
ffmpeg -i input.mp4 -vf "eq=gamma=1.5" output.mp4

# Фильтр резкости (sharpen)
ffmpeg -i input.mp4 -vf "unsharp=5:5:1.0:5:5:0.0" output.mp4

# Размытие (blur)
ffmpeg -i input.mp4 -vf "boxblur=5:1" output.mp4

# Гауссово размытие
ffmpeg -i input.mp4 -vf "gblur=sigma=5" output.mp4
```

### Денойзинг и улучшение качества

```bash
# Подавление шума (hqdn3d)
ffmpeg -i input.mp4 -vf "hqdn3d=4:3:6:4.5" output.mp4

# Подавление шума (nlmeans, медленнее но качественнее)
ffmpeg -i input.mp4 -vf "nlmeans" output.mp4

# Deinterlace (устранение чересстрочности)
ffmpeg -i input.mp4 -vf "yadif" output.mp4

# Стабилизация видео (двухпроходная)
ffmpeg -i input.mp4 -vf "vidstabdetect=shakiness=10:accuracy=15:result=transform.trf" -f null -
ffmpeg -i input.mp4 -vf "vidstabtransform=input=transform.trf:zoom=1:smoothing=30,unsharp=5:5:0.8:3:3:0.4" output.mp4
```

### Наложение и сложные фильтры (filter_complex)

```bash
# Наложение одного видео на другое (картинка в картинке)
ffmpeg -i main.mp4 -i overlay.mp4 \
  -filter_complex "[1:v]scale=320:-1[ovr];[0:v][ovr]overlay=W-w-10:H-h-10" \
  output.mp4

# Наложение с временным окном (только 5-10 секунд)
ffmpeg -i main.mp4 -i overlay.mp4 \
  -filter_complex "[0:v][1:v]overlay=10:10:enable='between(t,5,10)'" \
  output.mp4

# Разделить экран (side by side)
ffmpeg -i left.mp4 -i right.mp4 \
  -filter_complex "[0:v][1:v]hstack=inputs=2[v]" \
  -map "[v]" output.mp4

# Вертикальная укладка
ffmpeg -i top.mp4 -i bottom.mp4 \
  -filter_complex "[0:v][1:v]vstack=inputs=2[v]" \
  -map "[v]" output.mp4

# 2×2 сетка
ffmpeg -i 1.mp4 -i 2.mp4 -i 3.mp4 -i 4.mp4 \
  -filter_complex "[0:v][1:v]hstack[top];[2:v][3:v]hstack[bot];[top][bot]vstack[v]" \
  -map "[v]" output.mp4
```

---

## Обрезка и монтаж

### Вырезка фрагмента

```bash
# Вырезать с 00:01:00 продолжительностью 30 секунд
ffmpeg -i input.mp4 -ss 00:01:00 -t 30 -c copy output.mp4

# Вырезать с 00:01:00 до 00:02:30
ffmpeg -i input.mp4 -ss 00:01:00 -to 00:02:30 -c copy output.mp4

# Быстрая обрезка (ввод -ss до -i, но может быть неточным на ключевых кадрах)
ffmpeg -ss 00:01:00 -i input.mp4 -t 30 -c copy output.mp4

# Обрезка с перекодированием (точная, но медленная)
ffmpeg -i input.mp4 -ss 00:01:00 -t 30 -c:v libx264 -c:a aac output.mp4
```

### Объединение видео

```bash
# Создайте файл concat_list.txt:
# file 'part1.mp4'
# file 'part2.mp4'
# file 'part3.mp4'

ffmpeg -f concat -safe 0 -i concat_list.txt -c copy output.mp4

# Автоматическое создание списка (Linux/macOS)
ls *.mp4 | sed "s/^/file '/; s/$/'/" > concat_list.txt
ffmpeg -f concat -safe 0 -i concat_list.txt -c copy output.mp4

# Объединение с перекодированием (если разные параметры)
ffmpeg -i part1.mp4 -i part2.mp4 \
  -filter_complex "[0:v][0:a][1:v][1:a]concat=n=2:v=1:a=1[v][a]" \
  -map "[v]" -map "[a]" output.mp4
```

### Удаление аудио, замена аудио

```bash
# Убрать аудио
ffmpeg -i input.mp4 -an -c:v copy output_nosound.mp4

# Заменить аудио дорожку
ffmpeg -i video.mp4 -i new_audio.mp3 -c:v copy -c:a aac -map 0:v:0 -map 1:a:0 output.mp4

# Добавить тишину к немому видео
ffmpeg -i input.mp4 -f lavfi -i anullsrc=channel_layout=stereo:sample_rate=48000 \
  -c:v copy -c:a aac -shortest output.mp4
```

---

## Водяные знаки и субтитры

### Текстовый водяной знак

```bash
# Текст в правом нижнем углу
ffmpeg -i input.mp4 \
  -vf "drawtext=text='Мой канал':fontcolor=white:fontsize=36:x=W-tw-10:y=H-th-10" \
  output.mp4

# Текст с тенью
ffmpeg -i input.mp4 \
  -vf "drawtext=text='Мой канал':fontcolor=white:fontsize=36:shadowcolor=black:shadowx=2:shadowy=2:x=10:y=10" \
  output.mp4

# Полупрозрачный фон под текстом
ffmpeg -i input.mp4 \
  -vf "drawtext=text='Пример':fontcolor=white:fontsize=36:box=1:boxcolor=black@0.5:x=10:y=10" \
  output.mp4

# Текущее время в кадре
ffmpeg -i input.mp4 \
  -vf "drawtext=text='%{pts\:hms}':fontcolor=yellow:fontsize=24:x=10:y=10" \
  output.mp4
```

### Изображение-водяной знак

```bash
# Логотип в правом верхнем углу
ffmpeg -i input.mp4 -i logo.png \
  -filter_complex "[1:v]scale=150:-1[logo];[0:v][logo]overlay=W-w-10:10" \
  output.mp4

# Логотип с прозрачностью (PNG с альфа-каналом)
ffmpeg -i input.mp4 -i logo.png \
  -filter_complex "[1:v]scale=150:-1,format=rgba,colorchannelmixer=aa=0.5[logo];[0:v][logo]overlay=W-w-10:10" \
  output.mp4

# Логотип по центру
ffmpeg -i input.mp4 -i logo.png \
  -filter_complex "[1:v]scale=200:-1[logo];[0:v][logo]overlay=(W-w)/2:(H-h)/2" \
  output.mp4
```

### Субтитры

```bash
# Добавить субтитры (SRT) — мягкие (переключаемые)
ffmpeg -i input.mp4 -i subtitles.srt -c copy -c:s mov_text output.mp4

# Встроить субтитры в видео (hard subtitles, нельзя отключить)
ffmpeg -i input.mp4 -vf "subtitles=subtitles.srt" output.mp4

# Добавить субтитры из ASS-файла
ffmpeg -i input.mp4 -vf "ass=subtitles.ass" output.mp4

# Извлечь субтитры из MKV
ffmpeg -i input.mkv -map 0:s:0 output.srt
```

---

## Сжатие и качество

### Стратегии сжатия

```bash
# 1. CRF — постоянное качество (рекомендуется)
ffmpeg -i input.mp4 -c:v libx264 -crf 23 output.mp4

# 2. Фиксированный битрейт (для стриминга)
ffmpeg -i input.mp4 -c:v libx264 -b:v 2M -bufsize 4M output.mp4

# 3. Максимальный битрейт (для совместимости с устройствами)
ffmpeg -i input.mp4 -c:v libx264 -crf 23 -maxrate 4M -bufsize 8M output.mp4

# 4. Двухпроходное кодирование (точный размер файла)
ffmpeg -i input.mp4 -c:v libx264 -b:v 1.5M -pass 1 -f null /dev/null
ffmpeg -i input.mp4 -c:v libx264 -b:v 1.5M -pass 2 output.mp4
```

### Таблица настроек качества H.264

| CRF | Качество             | Размер        | Применение          |
| --- | -------------------- | ------------- | ------------------- |
| 0   | Без потерь           | Очень большой | Архив               |
| 18  | Визуально без потерь | Большой       | Мастер-копия        |
| 23  | По умолчанию         | Средний       | Общее использование |
| 28  | Приемлемое           | Малый         | Веб, мобильные      |
| 35+ | Плохое               | Очень малый   | Не рекомендуется    |

### Оптимизация для веба

```bash
# -movflags +faststart перемещает метаданные в начало файла
# Это позволяет видео воспроизводиться до окончания загрузки
ffmpeg -i input.mp4 -c:v libx264 -crf 23 -c:a aac -movflags +faststart output.mp4

# Конвертация для стриминга (HLS)
ffmpeg -i input.mp4 \
  -c:v libx264 -crf 20 -c:a aac -b:a 128k \
  -hls_time 10 -hls_list_size 0 \
  playlist.m3u8
```

---

## Аппаратное ускорение

### NVIDIA NVENC/NVDEC

Если у вас видеокарта NVIDIA — используйте кодеки `h264_nvenc` или `hevc_nvenc`. Кодирование будет выполнять GPU, а не процессор, что значительно быстрее.

> ⚠️ **Важно: CRF не работает с кодеками NVIDIA.** Параметр `-crf` — это функция программных кодеков (libx264/libx265). Для NVENC управление качеством осуществляется через `-cq` в связке с `-rc vbr_hq`.

**Аналог CRF для NVENC — параметр `-cq`:**

- Диапазон: 0–51, меньше = лучше качество (аналогично CRF)
- Рекомендуемые значения: **24–28** для обычного использования
- `-cq 26` — хороший баланс качества и размера
- `-cq 30` — меньше качество, меньше размер файла

**Пресеты NVENC (`-preset`):**

| Пресет | Скорость        | Качество |
| ------ | --------------- | -------- |
| `p1`   | Быстрее всего   | Ниже     |
| `p4`   | Баланс          | Среднее  |
| `p7`   | Медленнее всего | Выше     |

```bash
# H.265 (HEVC) — рекомендуемая команда для 1440p/4K видео
ffmpeg -i "Replay.mp4" \
  -c:v hevc_nvenc \
  -preset p7 \
  -tune hq \
  -rc vbr_hq \
  -cq 26 \
  -b:v 0 \
  -c:a copy \
  "output.mp4"

# То же, но с большим сжатием (меньше качество, меньше файл)
ffmpeg -i "Replay.mp4" \
  -c:v hevc_nvenc -preset p7 -tune hq -rc vbr_hq -cq 30 -b:v 0 -c:a copy \
  "output_small.mp4"

# Быстрее, баланс скорость/качество
ffmpeg -i input.mp4 -c:v hevc_nvenc -preset p6 -tune hq -rc vbr_hq -cq 26 -b:v 0 -c:a aac -q:a 2 output.mp4

# Медленнее, максимальное качество от GPU
ffmpeg -i input.mp4 -c:v hevc_nvenc -preset p7 -tune hq -rc vbr_hq -cq 26 -b:v 0 -c:a aac -q:a 2 output.mp4

# Создать папку converted и конвертировать все mp4 файлы
mkdir -p converted && for f in *.mp4; do ffmpeg -i "$f" -c:v hevc_nvenc -preset p7 -tune hq -rc vbr_hq -cq 26 -b:v 0 -c:a aac -q:a 2 "converted/$f"; done

# p6 и сжатие звука (несущественное) для домашнего архива
mkdir -p converted && for f in *.mp4; do ffmpeg -i "$f" -c:v hevc_nvenc -preset p6 -tune hq -rc vbr_hq -cq 30 -b:v 0 -c:a aac -b:a 128k "converted/$f"; done

# H.264 на NVIDIA (лучше совместимость)
ffmpeg -i input.mp4 \
  -c:v h264_nvenc \
  -preset p4 \
  -rc vbr_hq \
  -cq 26 \
  -b:v 0 \
  -c:a copy \
  output.mp4

# С аппаратным декодированием (максимальная скорость)
ffmpeg -hwaccel cuda -hwaccel_output_format cuda -i input.mp4 \
  -c:v hevc_nvenc -preset p4 -rc vbr_hq -cq 26 -b:v 0 \
  output.mp4

# Проверить, что NVENC доступен в вашей сборке FFmpeg
ffmpeg -encoders | grep nvenc
```

**Что означают параметры в команде NVENC:**

| Параметр          | Значение                                   |
| ----------------- | ------------------------------------------ |
| `-c:v hevc_nvenc` | Кодек H.265 через GPU NVIDIA               |
| `-preset p7`      | Максимальное качество кодирования GPU      |
| `-tune hq`        | Режим высокого качества                    |
| `-rc vbr_hq`      | Переменный битрейт с высоким качеством     |
| `-cq 26`          | Целевое качество (аналог CRF, 0–51)        |
| `-b:v 0`          | Без ограничения битрейта (GPU сам выберет) |
| `-c:a copy`       | Аудио копировать без перекодирования       |

### AMD AMF

```bash
# H.264 на GPU AMD
ffmpeg -i input.mp4 -c:v h264_amf output.mp4

# H.265 на GPU AMD
ffmpeg -i input.mp4 -c:v hevc_amf output.mp4
```

### Intel Quick Sync (QSV)

```bash
# H.264 на Intel GPU
ffmpeg -i input.mp4 -c:v h264_qsv output.mp4

# H.265 на Intel GPU
ffmpeg -i input.mp4 -c:v hevc_qsv output.mp4
```

### Apple VideoToolbox (macOS)

```bash
# H.264 через VideoToolbox
ffmpeg -i input.mp4 -c:v h264_videotoolbox -b:v 5M output.mp4

# H.265 через VideoToolbox
ffmpeg -i input.mp4 -c:v hevc_videotoolbox -b:v 5M output.mp4
```

### Проверка поддерживаемых аппаратных кодеков

```bash
ffmpeg -encoders | grep nvenc    # NVIDIA
ffmpeg -encoders | grep amf      # AMD
ffmpeg -encoders | grep qsv      # Intel
ffmpeg -encoders | grep videotoolbox  # Apple
```

---

## Запись экрана и стриминг

### Запись экрана

```bash
# Linux (X11)
ffmpeg -f x11grab -r 30 -s 1920x1080 -i :0.0 -c:v libx264 -crf 20 output.mp4

# Linux с аудио (PulseAudio)
ffmpeg -f x11grab -r 30 -s 1920x1080 -i :0.0 \
       -f pulse -i default \
       -c:v libx264 -crf 20 -c:a aac output.mp4

# macOS
ffmpeg -f avfoundation -framerate 30 -i "1:0" -c:v libx264 -crf 20 output.mp4

# Windows (GDI grab)
ffmpeg -f gdigrab -framerate 30 -i desktop -c:v libx264 -crf 20 output.mp4
```

### Стриминг на YouTube/Twitch

```bash
# YouTube Live (замените YOUR_STREAM_KEY)
ffmpeg -re -i input.mp4 \
  -c:v libx264 -preset veryfast -b:v 4500k -maxrate 4500k -bufsize 9000k \
  -pix_fmt yuv420p -g 60 \
  -c:a aac -b:a 128k -ar 44100 \
  -f flv rtmp://a.rtmp.youtube.com/live2/YOUR_STREAM_KEY

# Twitch (замените YOUR_STREAM_KEY)
ffmpeg -re -i input.mp4 \
  -c:v libx264 -preset veryfast -b:v 3000k -maxrate 3000k -bufsize 6000k \
  -c:a aac -b:a 160k -ar 44100 \
  -f flv rtmp://live.twitch.tv/live/YOUR_STREAM_KEY

# Трансляция с камеры
ffmpeg -f v4l2 -i /dev/video0 -f alsa -i hw:0 \
  -c:v libx264 -preset veryfast -b:v 3M \
  -c:a aac -b:a 128k \
  -f flv rtmp://live.twitch.tv/live/YOUR_STREAM_KEY
```

---

## Пакетная обработка

### Windows PowerShell

```powershell
# Конвертировать все MKV в MP4
Get-ChildItem *.mkv | ForEach-Object {
    $out = $_.BaseName + ".mp4"
    & ffmpeg -i $_.Name -c copy $out
    Write-Host "Готово: $($_.Name) -> $out"
}

# Конвертировать с перекодированием
Get-ChildItem *.avi | ForEach-Object {
    $out = $_.BaseName + ".mp4"
    & ffmpeg -i $_.Name -c:v libx264 -crf 23 -c:a aac $out
}
```

### Linux / macOS (Bash)

```bash
#!/bin/bash
# Конвертировать все MKV в MP4
for file in *.mkv; do
    [ -f "$file" ] || continue
    output="${file%.*}.mp4"
    ffmpeg -i "$file" -c copy "$output"
    echo "Готово: $file → $output"
done
```

```bash
#!/bin/bash
# Конвертировать все JPEG в WebP
for file in *.jpg *.jpeg; do
    [ -f "$file" ] || continue
    output="${file%.*}.webp"
    ffmpeg -i "$file" -quality 85 "$output"
done
```

```bash
#!/bin/bash
# Параллельная обработка (4 файла одновременно)
ls *.mp4 | xargs -P 4 -I {} ffmpeg -i {} -c:v libx264 -crf 23 -c:a aac "conv_{}"
```

---

## Диагностика и анализ файлов

### ffprobe — анализатор медиафайлов

```bash
# Общая информация о файле
ffprobe input.mp4

# Краткая сводка
ffprobe -v quiet -pretty -show_format input.mp4

# Информация о потоках
ffprobe -v quiet -show_streams input.mp4

# Информация в JSON
ffprobe -v quiet -print_format json -show_format -show_streams input.mp4

# Продолжительность видео
ffprobe -v quiet -show_entries format=duration -of csv="p=0" input.mp4

# Разрешение видео
ffprobe -v quiet -show_entries stream=width,height -of csv="p=0" input.mp4

# Частота кадров
ffprobe -v quiet -show_entries stream=r_frame_rate -of csv="p=0" input.mp4

# Кодек видеопотока
ffprobe -v quiet -show_entries stream=codec_name -select_streams v -of csv="p=0" input.mp4
```

### Проверка списка кодеков и форматов

```bash
# Все поддерживаемые форматы
ffmpeg -formats

# Все кодеки
ffmpeg -codecs

# Только энкодеры
ffmpeg -encoders

# Только декодеры
ffmpeg -decoders

# Все фильтры
ffmpeg -filters

# Информация о конкретном кодеке
ffmpeg -h encoder=libx264
ffmpeg -h decoder=h264

# Список поддерживаемых пикселных форматов
ffmpeg -pix_fmts
```

---

## Частые ошибки и решения

### «Invalid data found when processing input»

```bash
# Попробуйте указать формат вручную
ffmpeg -f mp4 -i input.mp4 output.avi

# Или попробуйте исправить файл
ffmpeg -i input.mp4 -c copy -err_detect ignore_err fixed.mp4
```

### «height not divisible by 2»

```bash
# Использовать scale с кратным 2
ffmpeg -i input.mp4 -vf "scale=1280:-2" output.mp4
# Или явно указать чётное число
ffmpeg -i input.mp4 -vf "scale=1280:720" output.mp4
```

### «Encoder not found» (кодек не поддерживается)

```bash
# Проверьте, что кодек есть в вашей сборке
ffmpeg -encoders | grep x265

# Если нет — установите full-сборку (Windows: ffmpeg-release-full.zip)
# macOS: brew install ffmpeg --with-libx265
```

### Видео не синхронизировано с аудио

```bash
# Добавить задержку аудио (в миллисекундах)
ffmpeg -i input.mp4 -af "adelay=500|500" output.mp4

# Или задержать видео
ffmpeg -i input.mp4 -vf "setpts=PTS+0.5/TB" -af "atempo=1.0" output.mp4
```

### Файл слишком большой

```bash
# Увеличить CRF (снижает качество, но уменьшает размер)
ffmpeg -i input.mp4 -c:v libx264 -crf 28 -preset slow output.mp4

# Или понизить разрешение
ffmpeg -i input.mp4 -vf "scale=1280:-2" -c:v libx264 -crf 23 output.mp4
```

### Ускорение обработки

```bash
# Отключить видеопоток (если нужно только аудио)
ffmpeg -i input.mp4 -vn -c:a libmp3lame output.mp3

# Использовать -c copy где возможно (не перекодировать)
ffmpeg -i input.mkv -c copy output.mp4

# Аппаратное декодирование
ffmpeg -hwaccel auto -i input.mp4 -c:v libx264 output.mp4
```

---

## Шпаргалка по ключевым параметрам

| Параметр       | Описание                       | Пример                  |
| -------------- | ------------------------------ | ----------------------- |
| `-i`           | Входной файл                   | `-i video.mp4`          |
| `-c:v`         | Видеокодек                     | `-c:v libx264`          |
| `-c:a`         | Аудиокодек                     | `-c:a aac`              |
| `-c copy`      | Копировать без перекодирования | `-c copy`               |
| `-crf`         | Качество (0–51)                | `-crf 23`               |
| `-b:v`         | Битрейт видео                  | `-b:v 2M`               |
| `-b:a`         | Битрейт аудио                  | `-b:a 128k`             |
| `-vf`          | Видеофильтр                    | `-vf scale=1280:720`    |
| `-af`          | Аудиофильтр                    | `-af volume=2.0`        |
| `-ss`          | Начало (seek)                  | `-ss 00:01:30`          |
| `-t`           | Продолжительность              | `-t 00:00:30`           |
| `-to`          | Конечная точка                 | `-to 00:02:00`          |
| `-r`           | FPS                            | `-r 30`                 |
| `-s`           | Размер кадра                   | `-s 1280x720`           |
| `-vn`          | Без видео                      | `-vn`                   |
| `-an`          | Без аудио                      | `-an`                   |
| `-preset`      | Скорость/качество кодека       | `-preset slow`          |
| `-y`           | Перезаписать без вопросов      | `-y`                    |
| `-hide_banner` | Скрыть баннер                  | `-hide_banner`          |
| `-map`         | Выбор потоков                  | `-map 0:v:0 -map 1:a:0` |

---

## Лайфхак для Windows: запуск через правую кнопку мыши

В Windows можно запускать FFmpeg-конвертацию прямо из проводника — через правый клик на файле → **«Отправить»**, без открытия командной строки.

### Как это работает

Папка **SendTo** — системная папка Windows, содержимое которой появляется в меню «Отправить» при правом клике на любом файле. Если положить туда `.bat`-файл, он будет запускаться с выбранным файлом в качестве аргумента.

**Открыть папку SendTo:** нажмите `Win+R` и введите `shell:sendto`

### Переменные в bat-файлах

| Переменная | Что содержит             | Пример                |
| ---------- | ------------------------ | --------------------- |
| `%1`       | Полный путь к файлу      | `C:\Videos\movie.mkv` |
| `%~d1`     | Только диск              | `C:`                  |
| `%~p1`     | Только папка             | `\Videos\`            |
| `%~n1`     | Имя файла без расширения | `movie`               |
| `%~x1`     | Только расширение        | `.mkv`                |
| `%~dp1`    | Диск + папка             | `C:\Videos\`          |
| `%~dpn1`   | Диск + папка + имя       | `C:\Videos\movie`     |

### Синтаксис cmd в bat-файлах

| Конструкция                   | Что делает                                                                                             |
| ----------------------------- | ------------------------------------------------------------------------------------------------------ |
| `@echo off`                   | Не выводить сами команды в окно, только результат                                                      |
| `echo.`                       | Пустая строка в выводе                                                                                 |
| `echo Текст`                  | Вывести текст в окно консоли                                                                           |
| `pause`                       | Ждать нажатия клавиши перед закрытием окна                                                             |
| `chcp 65001 >nul`             | Переключить консоль в UTF-8, чтобы русские буквы отображались корректно. Ставить сразу после @echo off |
| `2>nul`                       | Подавить сообщение об ошибке (например, если папка уже существует)                                     |
| `mkdir converted 2>nul`       | Создать папку, не ругаться если она уже есть                                                           |
| `for %%f in (*.mp4) do (...)` | Перебрать все MP4 файлы в папке и выполнить команду для каждого                                        |
| `%%f`                         | Переменная цикла в bat-файле (в cmd-строке пишется `%f`, в bat — `%%f`)                                |
| `%%~za`                       | Размер файла в байтах                                                                                  |
| `"converted\%%f"`             | Путь к выходному файлу в папке converted с тем же именем                                               |

### Готовые bat-файлы для SendTo

**1. Конвертировать в MP4 (H.264)**
Сохраните как `📹 Конвертировать в MP4.bat`:

```bat
@echo off
chcp 65001 >nul
ffmpeg -i %1 -c:v libx264 -crf 23 -c:a aac "%~dpn1_converted.mp4"
echo.
echo Готово! Файл сохранён рядом с оригиналом.
pause
```

***

**2. Сжатие видео MP4 через NVIDIA GPU** 

Файл сохранён рядом с оригиналом:

```bat
Код в файле "⚡conv-nvenc-SendTo.bat"
```

***

**2.1. Сжатие видео MP4 через NVIDIA GPU (умное сжатие + статистика)** 

Все сжатые файлы сохранены в папке converted, а оригинал в папку done.
после завершения создаёт файл `conversion_report.txt` с подробной статистикой: размер каждого файла до и после, время обработки, список пропущенных файлов

```bat
Код в файле ⚡conv-all-nvenc-orig-done-smart-stat.bat
```

***

**2.2. ⚡ Сжатие видео MP4 через NVIDIA GPU (умное сжатие + статистика)**
***Не подходит для SendTo, только батник в папку с видео***

То же что и 2.1, но файл нужно закидывать в папку с видео (не ярлык)

```bat
Код в файле ⚡conv-all-nvenc-orig-done-smart-stat-SendTo.bat
```

***

**3. Извлечь аудио как MP3**
Сохраните как `🎵 Извлечь аудио MP3.bat`:

```bat
@echo off
chcp 65001 >nul
ffmpeg -i %1 -vn -c:a libmp3lame -b:a 192k "%~dpn1.mp3"
echo.
echo Готово! MP3 сохранён рядом с оригиналом.
pause
```

***

**4. Сжать видео (уменьшить размер)**
Сохраните как `🗜 Сжать видео.bat`:

```bat
@echo off
chcp 65001 >nul
ffmpeg -i %1 -c:v libx264 -crf 28 -preset slow -c:a aac -b:a 128k "%~dpn1_small.mp4"
echo.
echo Готово! Сжатый файл сохранён рядом с оригиналом.
pause
```

***

**5. Конвертировать в MP3 (для музыки)**
Сохраните как `🎵 В MP3 320k.bat`:

```bat
@echo off
chcp 65001 >nul
ffmpeg -i %1 -c:a libmp3lame -b:a 320k "%~dpn1.mp3"
echo.
pause
```

***

**6. Извлечь кадр-превью (скриншот в начале видео)**
Сохраните как `📷 Сделать скриншот.bat`:

```bat
@echo off
chcp 65001 >nul
ffmpeg -i %1 -ss 00:00:05 -vframes 1 "%~dpn1_preview.jpg"
echo.
echo Готово! Превью сохранено рядом с видео.
pause
```

***

**7. Конвертировать MKV → MP4 без перекодирования (мгновенно)**
Сохраните как `⚡ MKV в MP4 (быстро).bat`:

```bat
@echo off
ffmpeg -i %1 -c copy "%~dpn1.mp4"
echo.
echo Готово! Конвертация без перекодирования завершена.
pause
```

***

**8. Вырезать фрагмент видео (с вводом времени)**
Сохраните как `✂️ Вырезать фрагмент.bat`:

После запуска консоль спросит начало и конец фрагмента — вводишь время в формате `00:01:30` и жмёшь Enter.

```bat
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
```

### Как установить

1. Создайте `.bat`-файл с нужным содержимым (любой текстовый редактор → сохранить с расширением `.bat`)
2. Нажмите `Win+R`, введите `shell:sendto`, нажмите Enter
3. Скопируйте `.bat`-файл или ярлык в открывшуюся папку
4. Готово! Теперь при правом клике на любом медиафайле в меню **«Отправить»** появится ваш пункт

> **Совет:** Называйте файлы с эмодзи или заглавной буквы — они будут выше в списке и нагляднее.

---

## Полезные ссылки

- 🔧 **Интерактивная шпаргалка:** [ffmpeg-commander.com](https://ffmpeg-commander.com/)
- 📖 **Официальная документация:** [ffmpeg.org/documentation.html](https://ffmpeg.org/documentation.html)
- 📦 **Сборки для Windows:** [gyan.dev/ffmpeg/builds](https://www.gyan.dev/ffmpeg/builds/)
- 🍺 **Сборки для macOS:** [evermeet.cx/ffmpeg](https://evermeet.cx/ffmpeg/)
- 🐧 **Статические сборки Linux:** [johnvansickle.com/ffmpeg](https://johnvansickle.com/ffmpeg/)
- 💬 **Сообщество:** [trac.ffmpeg.org](https://trac.ffmpeg.org)
- 🎥 **Видео на русском — «FFmpeg: бесплатный видеоконвертер из командной строки»** (канал Tech Talk): [youtu.be/AoV4tmf4x-c](https://youtu.be/AoV4tmf4x-c)

---

*Руководство актуально для FFmpeg 7.x–8.x (2025). Версию можно проверить командой `ffmpeg -version`.*
