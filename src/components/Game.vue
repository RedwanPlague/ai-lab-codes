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
    <label>near:
      <input v-model="near.string" name="near" type="number" @input="handleInputChange(near)" :min="near.min" :max="near.max"/>
    </label>
    <label>far:
      <input v-model="far.string" name="far" type="number" @input="handleInputChange(far)" :min="far.min" :max="far.max"/>
    </label>
    <label>catch:
      <select v-model="allAtOnce" style="font-family: monospace">
        <option :value="true">all ghosts in a cell at once</option>
        <option :value="false">one ghost at a time</option>
      </select>
    </label>
    <Board
      :rows="rows.value"
      :cols="cols.value"
      :ghosts="ghosts.value"
      :splits="[near.value, near.value + far.value]"
      :all-at-once="allAtOnce"
    />
  </div>
</template>

<script>
import Board from "./Board";

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
      },
      near: {
        string: '2',
        value: 2,
        min: 0,
        max: 3
      },
      far: {
        string: '3',
        value: 3,
        min: 0,
        max: 5
      },
      allAtOnce: true
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
select {
  font-size: 14px;
  width: 50px;
}
</style>
