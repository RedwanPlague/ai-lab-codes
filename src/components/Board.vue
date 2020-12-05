<template>
  <div id="holder">
    <table class="center">
      <tr v-for="(row, x) in probabilities" :key="x">
        <td v-for="(probability, y) in row" :key="y"
            @click="senseCell({x, y})"
        >
          {{(100*probability).toFixed(1)}}
        </td>
      </tr>
    </table>
    <button @click="advanceTime">Advance Time</button>
    <button @click="catchGhost">Catch Ghost</button>
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
    },
    ghosts: {
      type: Number,
      default: 1
    }
  },
  data () {
    return {
      probabilities: [[]],
      ghostPositions: [],
    }
  },
  methods: {
    initialize () {
      this.probabilities = Array(this.rows).fill(1/this.rows/this.cols).map(x => Array(this.cols).fill(x))
      this.ghostPositions = Array(this.ghosts)
      for (let i = 0; i < this.ghosts; i++) {
        this.ghostPositions[i] = this.getRandomCell()
      }
    },
    getRandomCell () {
      return {
        x: Math.floor(Math.random() * this.rows),
        y: Math.floor(Math.random() * this.cols)
      }
    },
    ghostCountOfCell (x, y) {
      return this.ghostPositions.reduce((count, {ix, iy}) => (ix === x && iy === y) ? ++count : count, 0)
    },
    closestGhostDistanceFromCell (x, y) {
      return this.ghostPositions.reduce(
          (minDist, {ix, iy}) => Math.min(minDist, Math.abs(x - ix) + Math.abs(y - iy)),
          (this.rows + this.cols)
      )
    },
    updateCell (cell, value) {
      this.probabilities[cell.x][cell.y] = value
      this.$set(this.probabilities, cell.x, this.probabilities[cell.x])
    },
    senseCell (cell) {
      this.updateCell(cell, 0)
    },
    getCurrentProbability (x, y) {
      return (x >= 0 && x < this.rows && y >= 0 && y < this.cols) ? this.probabilities[x][y] : 0
    },
    isCornerCell (x, y) {
      return (x === 0 || x === this.rows-1) && (y === 0 || y === this.cols-1)
    },
    isMidCell (x, y) {
      return (x > 0 && x < this.rows-1 && y > 0 && y < this.cols-1)
    },
    isSideCell (x, y) {
      return !this.isCornerCell(x, y) && !this.isMidCell(x, y)
    },
    getAdvancedProbability (x, y) {
      if (this.isCornerCell(x, y)) {
        console.log("haha")
      }
      else if (this.isSideCell(x, y)) {
        console.log("haha")
      }
    },
    advanceTime () {
      for (let i = 0; i < this.rows; i++) {
        for (let j = 0; j < this.cols; j++) {
          this.getAdvancedProbability(i, j)
        }
      }
    },
    catchGhost () {

    }
  },
  watch: {
    $props: {
      handler () {
        this.initialize()
      },
      deep: true,
      immediate: true
    }
  },
  created () {
    this.initialize()
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
  cursor: pointer;
}
</style>