<!--
Component Layout:

App
  GithubCorner            Github Badge and link to repository.
  router-view
    Editor                Container component.
      Presets             Pre-defined and user-saved presets.
      FileIO              Source and destination inputs.
      Format              FFmpeg format options.
      Video               FFmpeg video options.
      Audio               FFmpeg audio options.
      Filters             FFmpeg filter options.
      Options             FFmpeg general options and logging. Saves to localstorage.
      Command             Command building and rendering logic.
        CommandFragment   Builds command fragments with tooltips.
      Toolbar             User controls for copying command output and managing presets.
      JsonViewer          View JSON formatted options.
  Queue                   Queue manager for ffmpegd encodes.
-->
<template>
  <div>
    <b-navbar type="dark" variant="dark">
      <div class="container">
        <b-navbar-nav>
          <b-nav-item to="/">
            <img src="https://avatars.githubusercontent.com/u/46764919?v=4" height="50" width="50" alt="FFmpeg Commander" style="border-radius: 50%;" />
            FFmpeg Commander RUS
          </b-nav-item>
        </b-navbar-nav>
      </div>
    </b-navbar>

    <GitHubCorner />

    <div id="app-content" class="container">
      <b-tabs align="right" content-class="mt-4" v-model="tabIndex">
        <b-tab title="Конструктор">
          <router-view @onEncode="onEncode" />
        </b-tab>
        <b-tab title="Очередь" v-if="ffmpegdEnabled">
          <template #title>
            <b-spinner small v-if="isEncoding" /> Очередь
          </template>
          <Queue />
        </b-tab>
        <b-tab v-if="ffmpegdEnabled" disabled>
          <template #title>
            <code v-if="wsReady"><span class="small">🟢</span> ffmpegd онлайн</code>
            <code v-else><span class="small">🔴</span> ffmpegd офлайн</code>
          </template>
        </b-tab>
      </b-tabs>
    </div>

    <footer class="container mt-4 mb-4 text-center">
      <hr />
      <div class="text-muted d-flex flex-column align-items-center gap-2">
        <div>{{ name }}-{{ version }} | ffmpeg-commander-RUS-1.0</div>
        <div>
          <a href="https://github.com/alfg/ffmpeg-commander/issues">Сообщить об ошибке</a> |
          <a href="https://github.com/Vidrimers/ffmpeg-guide/issues/new?title=%5BBug%5D%20%5BLocalization%5D%20&body=%23%23%20%D0%9E%D0%BF%D0%B8%D1%81%D0%B0%D0%BD%D0%B8%D0%B5%20%D0%B2%20%D0%BB%D0%BE%D0%BA%D0%B0%D0%BB%D0%B8%D0%B7%D0%B0%D1%86%D0%B8%D0%B8%0A%0A%23%23%20%D0%A1%D1%82%D1%80%D0%B0%D0%BD%D0%B8%D1%86%D0%B0%20%2F%20%D1%8D%D0%BB%D0%B5%D0%BC%D0%B5%D0%BD%D1%82%0A%0A%23%23%20%D0%9D%D0%B5%D0%B2%D0%B5%D1%80%D0%BD%D1%8B%D0%B9%20%D0%BF%D0%B5%D1%80%D0%B5%D0%B2%D0%BE%D0%B4%0A%0A%23%23%20%D0%9F%D1%80%D0%B0%D0%B2%D0%B8%D0%BB%D1%8C%D0%BD%D1%8B%D0%B9%20%D0%BF%D0%B5%D1%80%D0%B5%D0%B2%D0%BE%D0%B4%20%28%D0%B5%D1%81%D0%BB%D0%B8%20%D0%B8%D0%B7%D0%B2%D0%B5%D1%81%D1%82%D0%B5%D0%BD%29%0A&labels=localization">Сообщить об ошибке в локализации</a> |
          <a href="https://ffmpeg.org/ffmpeg.html">Документация FFmpeg</a>
        </div>
        <div>Создано с ❤ автором <a href="https://github.com/alfg">alfg</a>. Переведено: <a href="https://github.com/Vidrimers">Vidrimers</a></div>
      </div>
    </footer>
  </div>
</template>

<script>
import pkgInfo from '../package.json';
import GitHubCorner from './components/GitHubCorner.vue';
import Queue from './components/Queue.vue';

export default {
  name: 'app',
  components: {
    GitHubCorner,
    Queue,
  },
  computed: {
    wsReady() {
      return this.$store.state.wsConnected;
    },
    isEncoding() {
      return this.$store.state.isEncoding;
    },
    ffmpegdEnabled() {
      return this.$store.state.ffmpegdEnabled;
    },
  },
  data() {
    return {
      name: pkgInfo.name,
      version: pkgInfo.version,
      tabIndex: 0,
    };
  },
  methods: {
    onEncode() {
      // eslint-disable-next-line no-plusplus
      this.tabIndex++;
    },
  },
};
</script>

<style>
#app-content {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  color: #2c3e50;
  margin-top: 30px;
}

#app-content a.router-link-exact-active {
  color: #495057;
  background-color: #fff;
  border-color: #dee2e6 #dee2e6 #fff;
}

.label {
  text-transform: capitalize;
}

footer ul {
  display: inline-block;
  padding-left: 0;
  text-align: left;
  width: 100%;
}

footer ul li {
  display: inline;
  margin: 0 6px;
  list-style: none;
}
</style>
