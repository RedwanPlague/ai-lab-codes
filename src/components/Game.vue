<template>
  <div>
    <label>rows:
      <input v-model="rowString" name="rows" type="number" @input="handleRowChange" :min="rowMin" :max="rowMax"/>
    </label>
    <label>cols:
      <input v-model="colString" name="cols" type="number" @input="handleColChange" :min="colMin" :max="colMax"/>
    </label>
    <Board :rows="rows" :cols="cols"/>
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
      rowString: '9',
      colString: '9',
      rows: 9,
      cols: 9,
      rowMin: 1,
      colMin: 1,
      rowMax: 10,
      colMax: 20
    }
  },
  methods: {
    handleRowChange () {
      if (this.rowString === '') {
        this.rows = this.rowMin
      }
      else {
        this.rows = Math.max(this.rowMin, Math.min(this.rowMax, parseInt(this.rowString)))
        this.rowString = this.rows.toString();
      }
    },
    handleColChange () {
      if (this.colString === '') {
        this.cols = this.colMin
      }
      else {
        this.cols = Math.max(this.colMin, Math.min(this.colMax, parseInt(this.colString)))
        this.colString = this.cols.toString();
      }
    }
  }
}
</script>

<style scoped>
label {
  margin: 10px;
}
</style>