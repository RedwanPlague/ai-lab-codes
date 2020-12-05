<template>
  <div>
    <label>rows:
      <input v-model="rows.string" name="rows" type="number" @input="handleInputChange(rows)" :min="rows.min" :max="rows.max"/>
    </label>
    <label>cols:
      <input v-model="cols.string" name="cols" type="number" @input="handleInputChange(cols)" :min="cols.min" :max="cols.max"/>
    </label>
    <label>ghosts:
      <input v-model="ghosts.string" name="ghosts" type="number" @input="handleInputChange(ghosts)" :min="ghosts.min" :max="ghosts.max"/>
    </label>
    <Board :rows="rows.value" :cols="cols.value" :ghosts="ghosts.value"/>
  </div>
</template>

<script>
import Board from "@/components/Board";

export default {
  name: "Game",
  components: {
      Board
  },
  data () {
    return {
      rows: {
        string: '9',
        value: 9,
        min: 1,
        max: 10
      },
      cols: {
        string: '9',
        value: 9,
        min: 1,
        max: 20
      },
      ghosts: {
        string: '1',
        value: 1,
        min: 1,
        max: 10
      }
    }
  },
  methods: {
    handleInputChange (input) {
      if (input.string === '') {
        this.$set(input, 'value', input.min)
      }
      else {
        const value = Math.max(input.min, Math.min(input.max, parseInt(input.string)))
        this.$set(input, 'value', value)
        this.$set(input, 'string', value.toString())
      }
    },
  }
}
</script>

<style scoped>
label {
  margin: 10px;
}
</style>