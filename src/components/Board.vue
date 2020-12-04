<template>
  <div id="holder">
    <table class="center">
      <tr v-for="(row, i) in prob" :key="i">
        <td v-for="(cell, j) in row" :key="j"
            :style="{
              color: (i === lastChanged.x && j === lastChanged.y) ? 'white' : 'black',
            }"
            :class="{
              far: i === lastChanged.x && j === lastChanged.y
            }"
            @click="clicked(i, j)"
        >
          {{cell.toFixed(2)}}
        </td>
      </tr>
    </table>
    <button @click="changeRandom" :disabled="running">
      Change Random
    </button>
  </div>
</template>

<script>
export default {
  name: "Board",
  props: {
    rows: {
      type: Number,
      default: 9
    },
    cols: {
      type: Number,
      default: 9
    }
  },
  data () {
    return {
      prob: Array(this.rows).fill(0).map(x => Array(this.cols).fill(x)),
      lastChanged: {x: 0, y: 0},
      running: false
    }
  },
  methods: {
    updateCell (x, y, value) {
      this.lastChanged = {x, y}
      this.running = true
      setTimeout(() => {
        this.prob[x][y] = value
        this.$set(this.prob, x, this.prob[x])
        this.running = false
      }, 500)
    },
    changeRandom () {
      const x = Math.floor(Math.random() * this.rows)
      const y = Math.floor(Math.random() * this.cols)
      this.updateCell(x, y, Math.random())
    },
    clicked (x, y) {
      this.updateCell(x, y, 0)
    }
  },
  watch: {
    rows () {
      this.prob = Array(this.rows).fill(0).map(x => Array(this.cols).fill(x))
    },
    cols () {
      this.prob = Array(this.rows).fill(0).map(x => Array(this.cols).fill(x))
    }
  }
}
</script>

<style scoped>
#holder {

}
table {
  border: 1px solid black;
  margin-top: 20px;
  margin-bottom: 20px;
}
table td {
  width: 50px;
  height: 50px;
  border: 1px solid black;
}
.near {
  background-color: red;
  color: white;
}
.medium {
  background-color: orange;
  color: black;
}
.far {
  background-color: limegreen;
  color: white;
}
</style>