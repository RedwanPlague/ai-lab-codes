<template>
  <div id="holder">
    <div>
      <div id="caught">
        <span style="float: left; position: relative; left: 100px">Caught Ghosts: {{ghosts - ghostPositions.length}}</span>
        <span style="float: right; position: relative; right: 100px">Attempts: {{attempts}}</span>
      </div>
      <table class="center">
        <tr v-for="(row, x) in probabilities" :key="x">
          <td v-for="(probability, y) in row" :key="y"
            :style="cellStyles(x, y, probability)"
            @click="senseCell(x, y)"
          >
            <span v-if="tryResult > 0 && x === lastClicked.x && y === lastClicked.y">
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
    </div>
    <div id="done" v-if="ghostPositions.length === 0">
      {{ghosts === 1 ? 'Ghost' : 'All ghosts'}} caught, you can sleep at peace now. Yay!
    </div>
    <div class="center" style="width: fit-content">
      <button @click="advanceTime" v-if="ghostPositions.length > 0">Advance Time</button>
      <button @click="reveal" v-if="ghostPositions.length > 0">{{revealed ? 'Hide' : 'Reveal'}}</button>
      <button @click="catchMode" v-if="ghostPositions.length > 0">{{catching ? 'Find' : 'Catch'}}</button>
    </div>
    <button id="undo" @click="popHistory" v-if="ghostPositions.length > 0 && history.length > 0">Undo</button>
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
    },
    allAtOnce: {
        type: Boolean,
        default: false
    },
    sensorAccuracies: {
      type: Array,
      default () {
          return [];
      }
    },
    uniform: {
      type: Boolean,
      default: true
    },
    moveUniform: {
      type: Object,
      default () {
        return {}
      }
    },
    move: {
      type: Object,
      default () {
        return {}
      }
    }
  },
  data () {
    return {
      bgColors: ['red', 'orange', 'green'],
      fontColors: ['white', 'black', 'white'],
      // U, D, R, L, UR, UL, DR, DL, S
      // moveUniform : {
      //   cornerProbabilities: [0.48, 0.48, 0.48, 0.48, 0.036, 0.036, 0.036, 0.036, 0.004],
      //   sideProbabilities: [0.32, 0.32, 0.32, 0.32, 0.018, 0.018, 0.018, 0.018, 0.004],
      //   midProbabilities: [0.24, 0.24, 0.24, 0.24, 0.009, 0.009, 0.009, 0.009, 0.004]
      // },
      // move: {
      //   cornerUR: [0.00, 0.00, 0.00, 0.96, 0.036, 0.036, 0.036, 0.036, 0.004],
      //   cornerUL: [0.00, 0.00, 0.00, 0.00, 0.036, 0.036, 0.036, 0.036, 0.964],
      //   cornerDR: [0.00, 0.00, 0.00, 0.96, 0.036, 0.036, 0.036, 0.036, 0.004],
      //   cornerDL: [0.00, 0.00, 0.00, 0.00, 0.036, 0.036, 0.036, 0.036, 0.964],
      //   sideU: [0.00, 0.00, 0.00, 0.96, 0.018, 0.018, 0.018, 0.018, 0.004],
      //   sideD: [0.00, 0.00, 0.00, 0.96, 0.018, 0.018, 0.018, 0.018, 0.004],
      //   sideL: [0.00, 0.00, 0.00, 0.00, 0.018, 0.018, 0.018, 0.018, 0.964],
      //   sideR: [0.00, 0.00, 0.00, 0.96, 0.018, 0.018, 0.018, 0.018, 0.004],
      //   mid: [0.00, 0.00, 0.00, 0.96, 0.009, 0.009, 0.009, 0.009, 0.004]
      // },
      // U, D, R, L, UR, UL, DR, DL, S
      dx: [-1, +1,  0,  0, +1, +1, -1, -1,  0],
      dy: [ 0,  0, +1, -1, +1, -1, +1, -1,  0],
      // states
      probabilities: [[]],
      ghostPositions: [],
      tryResult: 0,
      attempts: 0,
      caughtCount: 0,
      lastClicked: {x: -1, y: -1},
      currentlySensed: [],
      revealed: false,
      catching: false,
      history: []
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
      this.attempts = 0
      this.lastClicked = {x: -1, y: -1}
      this.currentlySensed = []
      // this.revealed = false
      this.catching = false
      this.history = []
    },
    pushHistory () {
      if (this.history.length >= 100) {
        this.history.splice(0, 1)
      }
      this.history.push(JSON.parse(JSON.stringify({
        probabilities: this.probabilities,
        ghostPositions: this.ghostPositions,
        currentlySensed: this.currentlySensed,
        attempts: this.attempts
      })))
    },
    popHistory () {
      const lastState = this.history.pop()
      this.probabilities = lastState.probabilities
      this.ghostPositions = lastState.ghostPositions
      this.currentlySensed = lastState.currentlySensed
      this.attempts = lastState.attempts
    },
    cellStyles (x, y, probability) {
      if (this.tryResult > 0 && x === this.lastClicked.x && y === this.lastClicked.y) {
        return {
          backgroundColor: 'white'
        }
      }
      else if (!this.catching && this.isCurrentlySensed(x, y)) {
        const distClass = this.currentlySensed.find(data => x === data.x && y === data.y).distClass
        return {
          backgroundColor: this.bgColors[distClass],
          color: this.fontColors[distClass]
        }
      }
      else if (this.revealed) {
        const distClass = this.getDistClass(this.closestGhostDistanceFromCell(x, y))
        return {
          backgroundColor: this.bgColors[distClass],
          color: this.fontColors[distClass]
        }
      }
      else {
        const depth = (this.ghostPositions.length === 0 ? 0 : Math.sqrt(probability/this.ghostPositions.length))
        return {
          backgroundColor: `rgba(100, 0, 255, ${depth})`,
          color: depth > .6 ? 'white' : 'black'
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
      if (this.uniform) {
        if (this.isCornerCell(x, y)) {
          return this.moveUniform.cornerProbabilities
        } else if (this.isSideCell(x, y)) {
          return this.moveUniform.sideProbabilities
        }
        return this.moveUniform.midProbabilities
      }
      else {
        if (x === 0 && y === 0) {
          return this.move.cornerUL
        }
        if (x === 0 && y === this.cols-1) {
          return this.move.cornerUR
        }
        if (x === this.rows-1 && y === 0) {
          return this.move.cornerDL
        }
        if (x === this.rows-1 && y === this.cols-1) {
          return this.move.cornerDR
        }
        if (x === 0) {
          return this.move.sideU;
        }
        if (x === this.rows-1) {
          return this.move.sideD;
        }
        if (y === 0) {
          return this.move.sideL;
        }
        if (y === this.cols-1) {
          return this.move.sideR;
        }
        return this.move.mid
      }
    },
    spreadSelf (tempArray, x, y, value, moveProbabilities) {
      let sum = 0
      for (let i = 0; i < this.dx.length; i++) {
        const nx = x + this.dx[i]
        const ny = y + this.dy[i]
        if (this.withinBoard(nx, ny)) {
          tempArray[nx][ny] += value * moveProbabilities[i]
          sum += moveProbabilities[i]
        }
      }
      tempArray[x][y] += value * Math.max(0, 1 - sum)
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
      for (let i = 0; i < this.dx.length; i++) {
        if (this.withinBoard(x+this.dx[i], y+this.dy[i])) {
          current += moveProbabilities[i]
          if (random < current) return {x: x+this.dx[i], y: y+this.dy[i]}
        }
      }
      return {x, y}
    },
    verifySum () {
      let sum = 0
      for (let i = 0; i < this.rows; i++) {
        for (let j = 0; j < this.cols; j++) {
          sum += this.probabilities[i][j]
        }
      }
      if (Math.abs(sum - this.ghostPositions.length) > 0.0001) {
        alert("Stop using incorrect probabilities :3")
        this.initialize()
      }
    },
    advanceGhosts () {
      for (let i = 0; i < this.ghostPositions.length; i++) {
        this.$set(this.ghostPositions, i, this.goRandomDirection(this.ghostPositions[i]))
      }
    },
    advanceTime () {
      this.pushHistory()
      this.currentlySensed = []
      this.advanceProbabilities()
      this.verifySum()
      this.advanceGhosts()
    },
    updateCell (x, y, value) {
      this.probabilities[x][y] = value
      this.$set(this.probabilities, x, this.probabilities[x])
    },
    tryToCatch (x, y) {
      this.attempts++
      this.caughtCount = this.ghostCountOfCell(x, y)
      if (this.caughtCount > 0) {
        if (!this.allAtOnce) {
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
        }, this.allAtOnce ? 500 : 200)
      }
      else {
        this.updateCell(x, y, 0)
        this.normalize()
        this.tryResult = 2
        setTimeout(() => {
          this.tryResult = 0
        }, 200)
      }
    },
    reWeight (x, y, sensedClass) {
      const A = Array(this.bgColors.length)
      for (let i = 0; i < A.length; i++) {
        A[i] = this.getDistClassCount(x, y, i)
      }

      const N = this.rows * this.cols
      const useN = Math.pow(N, this.ghostPositions.length)
      const useN1 = Math.pow(N - 1, this.ghostPositions.length)
      const hor = useN - useN1

      const whenSmaller = Array(A.length)
      const whenEqual = Array(A.length)
      let sumA = 0
      for (let i = 0; i < A.length; i++) {
        const useNA = Math.pow(N - sumA, this.ghostPositions.length)
        const useNA1 = Math.pow(N - sumA - 1, this.ghostPositions.length)
        whenEqual[i] = (useNA - useNA1) / hor
        sumA += A[i]
        const useNAB = Math.pow(N - sumA, this.ghostPositions.length)
        const useNAB1 = Math.pow(N - sumA - 1, this.ghostPositions.length)
        whenSmaller[i] = (useNA - useNA1 - useNAB + useNAB1) / hor
      }

      const tempArray = JSON.parse(JSON.stringify(this.probabilities))
      for (let i = 0; i < this.rows; i++) {
        for (let j = 0; j < this.cols; j++) {
          const curClass = this.getDistClass(Math.abs(x - i) + Math.abs(y - j))
          let weight = whenEqual[curClass] * this.sensorAccuracies[curClass][sensedClass]
          for (let k = 0; k < curClass; k++) {
            weight += whenSmaller[k] * this.sensorAccuracies[k][sensedClass]
          }
          tempArray[i][j] *= weight
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
    sense (x, y) {
      const distClass = this.getDistClass(this.closestGhostDistanceFromCell(x, y))
      const random = Math.random()
      let cur = 0
      const errorChances = this.sensorAccuracies[distClass]
      for (let i = 0; i < errorChances.length; i++) {
        cur += errorChances[i]
        if (random < cur) return i
      }
      return errorChances[errorChances.length-1]
    },
    senseCell (x, y) {
      if (this.tryResult > 0 || this.ghostPositions.length === 0) return;

      this.pushHistory()
      this.lastClicked = {x, y}

      if (this.catching) {
        this.tryToCatch(x, y)
      }
      else if (!this.isCurrentlySensed(x, y)) {
        const distClass = this.sense(x, y)
        this.currentlySensed.push({x, y, distClass})
        this.reWeight(x, y, distClass)
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
      // this.currentlySensed = []
      this.catching = !this.catching
    },
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
  position: relative;
  top: 15px;
  /*margin-top: 20px;*/
  margin-bottom: 35px;
  clear: both;
}
table td {
  width: 50px;
  height: 50px;
  border: 1px solid black;
  cursor: pointer;
}
#caught {
  margin-top: 20px;
  font-size: 20px;
  color: black;
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
#undo {
  position: absolute;
  float: right;
  width: 80px;
}
</style>
