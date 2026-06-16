# `ffmpeg-commander`

Простой веб-интерфейс для генерации типовых операций кодирования FFmpeg.

https://ffmpeg-commander.com

> 💡 Нравится ffmpeg-commander, но хотите настольное приложение? <strong><a href="https://video-commander.com" target="_blank" rel="noopener">Video Commander</a></strong> — полноценное десктопное приложение для инженеров по видео. <strong><a href="https://video-commander.com" target="_blank" rel="noopener">video-commander.com</a> →

[![github pages](https://github.com/alfg/ffmpeg-commander/actions/workflows/github-pages.yml/badge.svg)](https://github.com/alfg/ffmpeg-commander/actions/workflows/github-pages.yml)
[![Node.js CI](https://github.com/alfg/ffmpeg-commander/actions/workflows/node.js.yml/badge.svg)](https://github.com/alfg/ffmpeg-commander/actions/workflows/node.js.yml)

![screenshot](https://user-images.githubusercontent.com/702541/146104964-3aaccb1a-08c8-47df-b4b9-e21a6c8c80ab.png)

Читайте статью: https://dev.to/alfg/ffmpeg-the-easy-way-4a0h

Попробуйте [docker-ffmpeg](https://github.com/alfg/docker-ffmpeg) для сборки FFmpeg в Docker.

## Зачем?

`FFmpeg` имеет множество простых и сложных опций, что сначала может быть напугать. Этот инструмент создан для создания простого интерфейса генерации типовых операций кодирования видео и аудио, по вдохновению [HandBrake](https://handbrake.fr/).

Этот инструмент НЕ покрывает все опции FFmpeg и делает некоторые предположения при генерации вывода. Возможно, потребуется корректировка. Сгенерированные опции также могут различаться в зависимости от версии FFmpeg и конфигурации сборки.

Если вы считаете, что какие-то опции можно улучшить, создайте issue или pull request.

## Разработка

`ffmpeg-commander` создан на [Vue.js](https://vuejs.org) и [Bootstrap Vue](https://bootstrap-vue.org/).

### Поддерживаемые версии Node [LTS](https://nodejs.org/en/about/releases/)

* v12
* v14
* v16

Для быстрой установки и использования разных версий Node.js рекомендуется [NVM](https://github.com/nvm-sh/nvm).

### Установка

```bash
npm install
npm run serve
```

* Откройте `http://localhost:8080/` в веб-браузере.

### Сборка и минификация для продакшена

```
npm run build
```

### Деплой

Деплой на [Github Pages](https://pages.github.com/)

```
npm run deploy
```

### Docker

```
docker build -t ffmpeg-commander .
docker run -it -p 8080:80 --rm ffmpeg-commander
```

## `ffmpegd`

`ffmpegd` — опциональное вспомогательное приложение, которое связывает `ffmpeg-commander` с `ffmpeg` через WebSocket-сервер для отправки задач кодирования и получения обновлений прогресса в реальном времени в браузере. Это позволяет использовать ffmpeg-commander как GUI для ffmpeg.

См.: https://github.com/alfg/ffmpegd

### Планы

* Поддержка нескольких входов и опции map
* Расширение фильтров

## Лицензия

MIT
