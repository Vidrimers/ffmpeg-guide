<template>
  <div>
    <b-form-row>
      <b-col>
        <b-form-group label="Доп. флаги:">
          <b-form-checkbox
            v-for="option in extraOptions"
            v-model="extra"
            :key="option.value"
            :value="option.value"
            @input="update('extra', $event)"
            switch
          >
            <span class="desc">{{ option.text }}</span>
          </b-form-checkbox>
        </b-form-group>
      </b-col>
    </b-form-row>

    <b-form-row>
      <b-col cols="4">
        <b-form-group label="Уровень логирования: " label-for="loglevel">
          <b-form-select
            class="u-full-width"
            v-model="loglevel"
            @change="update('loglevel', $event)"
          >
            <option :value="null" disabled>-- Выберите параметр --</option>
            <option v-for="o in logLevels" :key="o.id" :value="o.value">{{o.name}}</option>
          </b-form-select>
        </b-form-group>
      </b-col>
    </b-form-row>
    <hr />

    <b-form-row>
      <b-col>
        <b-form-group label="FFmpegd:">
          <b-form-checkbox
            v-model="ffmpegd"
            @input="update('ffmpegd', $event)"
            switch
          >
            <span class="desc">
              Разрешить отправку задач кодирования на <code>ffmpegd</code> (экспериментально).
              <p class="small text-muted">*Для подключения необходим запущенный <strong>ffmpegd</strong>.</p>
            </span>
          </b-form-checkbox>
        </b-form-group>
      </b-col>
    </b-form-row>
    <p>⚠️ Настройки будут сохранены в локальное хранилище для удобства.</p>
  </div>
</template>

<script>
import form from '@/form';
import storage from '@/storage';

const {
  extraOptions,
  logLevels,
} = form;

export default {
  name: 'Filters',
  props: ['value'],
  data() {
    return {
      extra: [],
      loglevel: 'none',
      extraOptions,
      logLevels,
      ffmpegd: false,
    };
  },
  async created() {
    this.extra = storage.getItem('options') || [];
    this.loglevel = storage.getItem('loglevel') || 'none';
    this.ffmpegd = storage.getItem('ffmpegd');
    await this.update('extra', this.extra);
    await this.update('loglevel', this.loglevel);
    await this.update('ffmpegd', this.ffmpegd);

    // Start ffmpegd if option enabled and no ws connection.
    if (this.ffmpegd && !this.$ws.conn) {
      this.$ws.start();
    }
  },
  methods: {
    setSettingsStorage() {
      storage.setItem('options', this.extra);
      storage.setItem('loglevel', this.loglevel);
      storage.setItem('ffmpegd', this.ffmpegd);
      this.$store.setFfmpegdEnabled(this.ffmpegd);
    },
    update(key, value) {
      this.setSettingsStorage();
      this.$emit('input', { ...this.value, [key]: value });

      // Toggle ffmpegd.
      if (key === 'ffmpegd') {
        if (this.ffmpegd && !this.$ws.conn) {
          this.$ws.start();
        } else if (!this.ffmpegd && this.$ws.conn) {
          this.$ws.stop();
        }
      }
    },
  },
};
</script>

<style scoped>
.desc {
  text-transform: none !important;
}
</style>
