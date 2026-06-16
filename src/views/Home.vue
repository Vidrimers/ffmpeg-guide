<template>
  <main class="home">
    <header class="home-hero">
      <h1>Генератор FFmpeg-команд для типовых задач кодирования</h1>
      <p class="lead">
        FFmpeg Commander помогает собирать FFmpeg-команды для конвертации видео, кодирования аудио,
        фильтров и настроек контейнера без запоминания каждого флага.
      </p>
      <p class="home-summary">
        Выберите пресет, настройте параметры формата и кодека, затем скопируйте сгенерированную
        команду в ваш локальный FFmpeg-процесс.
      </p>
    </header>

    <section aria-labelledby="builder-heading">
      <h2 id="builder-heading" class="section-heading">Конструктор команд</h2>
      <Editor @onEncode="onEncode" />
    </section>

    <section class="home-copy" aria-labelledby="about-heading">
      <h2 id="about-heading" class="section-heading">Что можно настроить</h2>
      <p>
        Конструктор поддерживает основные параметры FFmpeg: пути ввода и вывода, формат контейнера,
        пресеты H.264 и VP9, настройку битрейта и CRF, параметры аудио, масштабирование и фильтры
        такие как деинтерлейсинг и шумоподавление.
      </p>
      <p>
        Инструмент создан для быстрой генерации команд, а не для полного
        покрытия всех возможностей FFmpeg — начните с готового базового
        варианта и доработайте команду под вашу среду и медиафайлы.
      </p>
    </section>
  </main>
</template>

<script>
import Editor from '@/components/Editor.vue';

export default {
  name: 'Home',
  components: {
    Editor,
  },
  methods: {
    onEncode() {
      this.$emit('onEncode');
    },
  },
};
</script>

<style scoped>
.home {
  display: block;
}

.home-hero {
  margin-bottom: 2rem;
}

.home-hero h1 {
  font-size: 2.2rem;
  line-height: 1.2;
  margin-bottom: 0.75rem;
}

.lead,
.home-summary,
.home-copy p {
  max-width: 52rem;
}

.section-heading {
  font-size: 1.35rem;
  margin-bottom: 1rem;
}

.home-copy {
  margin-top: 2.5rem;
}
</style>
