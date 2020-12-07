<template>
  <div id="holder">
    <table class="center">
      <tr v-for="(row, x) in probabilities" :key="x">
        <td v-for="(probability, y) in row" :key="y"
          :style="cellStyles(x, y, probability)"
          @click="senseCell(x, y)"
        >
          <span v-if="tryResult > 0 && x === lastSensed.x && y === lastSensed.y">
            <span v-if="tryResult === 1" :style="{color: 'green', fontSize: (allAtOnce ? 25 : 30) + 'px'}">
              &#x2714;<span v-if="allAtOnce">{{caughtCount}}</span>
            </span>
            <span v-else-if="tryResult === 2" style="color: red; font-size: 30px">
              &#x2717;
            </span>
          </span>
          <span v-else>
<!--            {{closestGhostDistanceFromCell(x, y)}}-->
            {{(100*probability).toFixed(2)}}
<!--            {{ghostCountOfCell(x, y)}}-->
          </span>
        </td>
      </tr>
    </table>
    <div id="caught">
<!--      <span v-if="tryResult === 1" style="color: green">-->
<!--        Caught {{caughtCount}} Ghost{{caughtCount > 1 ? 's' : ''}}-->
<!--      </span>-->
<!--      <span v-else-if="tryResult === 2" style="color: red">-->
<!--        No Ghost There-->
<!--      </span>-->
<!--      <span v-else>-->
        Caught Ghosts: {{ghosts - ghostPositions.length}}
<!--      </span>-->
    </div>
    <div id="done" v-if="ghostPositions.length === 0">
      {{ghosts === 1 ? 'Ghost' : 'All ghosts'}} caught, you can sleep at peace now. Yay!
    </div>
    <div class="center" style="width: fit-content;">
      <button @click="advanceTime" v-if="ghostPositions.length > 0">Advance Time</button>
      <button @click="reveal" v-if="ghostPositions.length > 0">{{revealed ? 'Hide' : 'Reveal'}}</button>
      <button @click="catchMode" v-if="ghostPositions.length > 0">{{catching ? 'Find' : 'Catch'}}</button>
    </div>
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
    },
    splits: {
      type: Array,
      default () {
        return [2, 7]
      }
    }
  },
  data () {
    return {
      bgColors: ['red', 'orange', 'green'],
      fontColors: ['white', 'black', 'white'],
      // side, diagonal, stay
      cornerProbabilities: [0.48, 0.018, 0.004],
      sideProbabilities: [0.32, 0.012, 0.004],
      midProbabilities: [0.24, 0.009, 0.004],
      probabilities: [[]],
      ghostPositions: [],
      tryResult: 0,
      allAtOnce: false,
      caughtCount: 0,
      lastSensed: {x: -1, y: -1},
      currentlySensed: [],
      revealed: false,
      catching: false
    }
  },
  methods: {
    initialize () {
      const N = this.rows * this.cols
      // const value = 1 - Math.pow(1 - 1 / N, this.ghosts)
      const value = this.ghosts / N
      this.probabilities = Array(this.rows).fill(value).map(x => Array(this.cols).fill(x))
      this.ghostPositions = Array(this.ghosts)
      for (let i = 0; i < this.ghosts; i++) {
        this.ghostPositions[i] = this.getRandomCell()
      }
      this.tryResult = 0
      this.lastSensed = {x: -1, y: -1}
      this.currentlySensed = []
      // this.revealed = false
      this.catching = false
    },
    cellStyles (x, y, probability) {
      if (this.tryResult > 0 && x === this.lastSensed.x && y === this.lastSensed.y) {
        return {
          backgroundColor: 'white'
        }
      }
      else if (this.isCurrentlySensed(x, y) || this.revealed) {
        const distClass = this.getDistClass(this.closestGhostDistanceFromCell(x, y))
        return {
          backgroundColor: this.bgColors[distClass],
          color: this.fontColors[distClass]
        }
      }
      else {
        const depth = (this.ghostPositions.length === 0 ? 0 : Math.sqrt(probability/this.ghostPositions.length))
        return {
          backgroundColor: `rgba(0, 0, 255, ${depth})`,
          color: depth > .5 ? 'white' : 'black'
        }
      }
    },
    withinBoard (x, y) {
      return (x >= 0 && x < this.rows && y >= 0 && y < this.cols)
    },
    getRandomCell () {
      return {
        x: Math.floor(Math.random() * this.rows),
        y: Math.floor(Math.random() * this.cols)
      }
    },
    getDistClass (dist) {
      for (let i = 0; i < this.splits.length; i++) {
        if (dist <= this.splits[i]) return i;
      }
      return this.splits.length
    },
    getDistClassCount (x, y, distClass) {
      let count = 0
      for (let i = 0; i < this.rows; i++) {
        for (let j = 0; j < this.cols; j++) {
          if (this.getDistClass(Math.abs(x - i) + Math.abs(y - j)) === distClass) count++
        }
      }
      return count
    },
    ghostCountOfCell (x, y) {
      return this.ghostPositions.reduce((count, cell) => (x === cell.x && y === cell.y) ? ++count : count, 0)
    },
    closestGhostDistanceFromCell (px, py) {
      return this.ghostPositions.reduce(
          (minDist, {x, y}) => {
            return Math.min(minDist, Math.abs(x - px) + Math.abs(y - py))
          },
          (this.rows + this.cols)
      )
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
    getMoveProbabilities (x, y) {
      if (this.isCornerCell(x, y)) {
        return this.cornerProbabilities
      }
      else if (this.isSideCell(x, y)) {
        return this.sideProbabilities
      }
      return this.midProbabilities
    },
    updateArray (tempArray, x, y, value) {
      if (this.withinBoard(x, y)) {
        tempArray[x][y] += value
      }
    },
    spreadSelf (tempArray, x, y, value, moveProbabilities) {
      this.updateArray(tempArray, x+1, y, value * moveProbabilities[0])
      this.updateArray(tempArray, x-1, y, value * moveProbabilities[0])
      this.updateArray(tempArray, x, y+1, value * moveProbabilities[0])
      this.updateArray(tempArray, x, y-1, value * moveProbabilities[0])
      this.updateArray(tempArray, x+1, y+1, value * moveProbabilities[1])
      this.updateArray(tempArray, x+1, y-1, value * moveProbabilities[1])
      this.updateArray(tempArray, x-1, y+1, value * moveProbabilities[1])
      this.updateArray(tempArray, x-1, y-1, value * moveProbabilities[1])
      this.updateArray(tempArray, x, y, value * moveProbabilities[2])
    },
    advanceProbabilities () {
      const tempProbabilities = Array(this.rows).fill(0).map(x => Array(this.cols).fill(x))
      for (let i = 0; i < this.rows; i++) {
        for (let j = 0; j < this.cols; j++) {
          this.spreadSelf(tempProbabilities, i,  j, this.probabilities[i][j], this.getMoveProbabilities(i, j))
        }
      }
      this.probabilities = tempProbabilities
    },
    goRandomDirection ({x, y}) {
      const moveProbabilities = this.getMoveProbabilities(x, y)
      const random = Math.random()
      let current = 0
      if (this.withinBoard(x+1, y)) {
        current += moveProbabilities[0]
        if (random < current) return {x:x+1, y:y}
      }
      if (this.withinBoard(x-1, y)) {
        current += moveProbabilities[0]
        if (random < current) return {x:x-1, y:y}
      }
      if (this.withinBoard(x, y+1)) {
        current += moveProbabilities[0]
        if (random < current) return {x:x, y:y+1}
      }
      if (this.withinBoard(x, y-1)) {
        current += moveProbabilities[0]
        if (random < current) return {x:x, y:y-1}
      }
      if (this.withinBoard(x+1, y+1)) {
        current += moveProbabilities[1]
        if (random < current) return {x:x+1, y:y+1}
      }
      if (this.withinBoard(x+1, y-1)) {
        current += moveProbabilities[1]
        if (random < current) return {x:x+1, y:y-1}
      }
      if (this.withinBoard(x-1, y+1)) {
        current += moveProbabilities[1]
        if (random < current) return {x:x-1, y:y+1}
      }
      if (this.withinBoard(x-1, y-1)) {
        current += moveProbabilities[1]
        if (random < current) return {x:x-1, y:y-1}
      }
      return {x, y}
    },
    advanceGhosts () {
      for (let i = 0; i < this.ghostPositions.length; i++) {
        this.$set(this.ghostPositions, i, this.goRandomDirection(this.ghostPositions[i]))
      }
    },
    advanceTime () {
      this.currentlySensed = []
      this.advanceProbabilities()
      this.advanceGhosts()
    },
    updateCell (x, y, value) {
      this.probabilities[x][y] = value
      this.$set(this.probabilities, x, this.probabilities[x])
    },
    tryToCatch (x, y) {
      this.caughtCount = this.ghostCountOfCell(x, y)
      if (this.caughtCount > 0) {
        if (this.allAtOnce) {
          this.caughtCount = 1
        }

        this.currentlySensed = []

        if (this.allAtOnce) {
          // if all ghosts in this cell are caught at once
          this.ghostPositions = this.ghostPositions.filter(cell => x !== cell.x || y !== cell.y)
          this.updateCell(x, y, 0)
        }
        else {
          // if only one of the ghosts in this cell are caught at once
          for (let i = 0; i < this.ghostPositions.length; i++) {
            if (this.ghostPositions[i].x === x && this.ghostPositions[i].y === y) {
              this.ghostPositions.splice(i, 1)
              break;
            }
          }
        }
        this.normalize()

        if (this.ghostPositions.length === 0) {
          this.probabilities = Array(this.rows).fill(0).map(x => Array(this.cols).fill(x))
        }
        this.tryResult = 1
        setTimeout(() => {
          this.tryResult = 0
        }, 1000)
      }
      else {
        this.updateCell(x, y, 0)
        this.normalize()
        this.tryResult = 2
        setTimeout(() => {
          this.tryResult = 0
        }, 500)
      }
    },
    reWeight (x, y) {
      const sensedClass = this.getDistClass(this.closestGhostDistanceFromCell(x, y))

      // number of cells that have distClass < sensedClass
      let A = 0
      for (let i = 0; i < sensedClass; i++) {
        A += this.getDistClassCount(x, y, i)
      }
      // number of cells that have distClass === sensedClass
      const B = this.getDistClassCount(x, y, sensedClass)

      const N = this.rows * this.cols
      const useN = Math.pow(N, this.ghostPositions.length)
      const useN1 = Math.pow(N - 1, this.ghostPositions.length)
      const useNA = Math.pow(N - A, this.ghostPositions.length)
      const useNA1 = Math.pow(N - A - 1, this.ghostPositions.length)
      const useNAB = Math.pow(N - A - B, this.ghostPositions.length)
      const useNAB1 = Math.pow(N - A - B - 1, this.ghostPositions.length)
      const weightForEqual = (useNA - useNA1) / (useN - useN1)
      const weightForLarger = (useNA - useNA1 - useNAB + useNAB1) / (useN - useN1)

      const tempArray = JSON.parse(JSON.stringify(this.probabilities))
      for (let i = 0; i < this.rows; i++) {
        for (let j = 0; j < this.cols; j++) {
          const curClass = this.getDistClass(Math.abs(x - i) + Math.abs(y - j))
          if (curClass < sensedClass) {
            tempArray[i][j] = 0
          }
          else if (curClass === sensedClass) {
            tempArray[i][j] *= weightForEqual
          }
          else {
            tempArray[i][j] *= weightForLarger
          }
        }
      }
      this.probabilities = tempArray
    },
    normalize () {
      let sum = this.probabilities.reduce((tempSum, rowArray) => tempSum + rowArray.reduce((tempRowSum, cell) => tempRowSum + cell, 0), 0)
      // console.log(sum)
      sum /= this.ghostPositions.length
      const tempArray = JSON.parse(JSON.stringify(this.probabilities))
      for (let i = 0; i < this.rows; i++) {
        for (let j = 0; j < this.cols; j++) {
          tempArray[i][j] /= sum
        }
      }
      this.probabilities = tempArray
    },
    senseCell (x, y) {
      if (this.tryResult > 0 || this.ghostPositions.length === 0) return;

      this.lastSensed = {x, y}

      if (this.catching) {
        this.tryToCatch(x, y)
      }
      else if (!this.isCurrentlySensed(x, y)) {
        this.currentlySensed.push({x, y})
        this.reWeight(x, y)
        this.normalize()
      }
    },
    isCurrentlySensed (x, y) {
      for (let cell of this.currentlySensed) {
        if (x === cell.x && y === cell.y) return true
      }
      return false
    },
    reveal () {
      this.revealed = !this.revealed
    },
    catchMode () {
      this.currentlySensed = []
      this.catching = !this.catching
    }
  },
  watch: {
    rows () {
      this.initialize()
    },
    cols () {
      this.initialize()
    },
    ghosts () {
      this.initialize()
    },
    splits () {
      this.currentlySensed = []
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
#caught {
  margin-bottom: 20px;
  font-size: 20px;
}
#done {
  margin-bottom: 20px;
  font-size: 20px;
  color: limegreen;
  font-weight: bold;
}
button {
  border-radius: 5px;
  margin-left: 10px;
  margin-right: 10px;
  font-size: 16px;
  width: 100px;
  height: 50px;
  cursor: pointer;
  float: left;
}
button:hover {
  background-color: lightgrey;
}
</style>