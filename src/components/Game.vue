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
    <button id="edit" @click="editToggle">{{editing ? 'Play' : 'Edit'}}</button>
    <div id="data" v-show="editing">
      <table class="center" style="margin-top: 50px">
        <caption>Sensor Probabilities</caption>
        <tr>
          <td v-for="(color, i) in colors" :key="i">
            {{color}}
          </td>
        </tr>
        <tr v-for="i in 3" :key="i">
          <td :style="{
            color: (sumOk(sensorAccuracies[i-1]) ? 'black' : 'red'),
            textAlign: 'left'
          }">
            {{colors[i]}}
          </td>
          <td v-for="j in 3" :key="j">
            <label>
              <input
                  v-model="sensorAccuracies[i-1][j-1]"
                  type="number"
                  step="0.01"
                  :min="0"
                  :max="1"
                  @blur="changeValue(sensorAccuracies, i-1, j-1)"
              />
            </label>
          </td>
        </tr>
      </table>
      <button id="uniform" @click="uniformToggle">
        {{uniform ? 'Flexible' : 'Uniform'}}
      </button>
      <table class="center">
        <caption>Transition Probabilities</caption>
        <tr>
          <td></td>
          <td v-for="(direction, i) in directions" :key="i">
            {{direction}}
          </td>
        </tr>
        <tr v-for="(value, key, i) in useMove" :key="i">
          <td style="text-align: left">{{key}}</td>
          <td v-for="(p, j) in value" :key="j">
            <label>
              <input
                  v-model="useMove[key][j]"
                  type="number"
                  step="0.01"
                  :min="0"
                  :max="1"
                  @blur="changeValue(useMove, key, j)"
              />
            </label>
          </td>
        </tr>
      </table>
    </div>
    <Board v-show="!editing"
      :rows="rows.value"
      :cols="cols.value"
      :ghosts="ghosts.value"
      :splits="[near.value, near.value + far.value]"
      :all-at-once="allAtOnce"
      :sensor-accuracies="sensorAccuracies"
      :uniform="uniform"
      :move-uniform="moveUniform"
      :move="move"
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
      allAtOnce: false,
      editing: false,
      // sensor
      colors: ['', 'red', 'orange', 'green'],
      sensorAccuracies: [
        // red, orange, green
        [1.00, 0.00, 0.00], // red
        [0.00, 1.00, 0.00], // orange
        [0.00, 0.00, 1.00]  // green
      ],
      uniform: true,
      directions: ['U', 'D', 'R', 'L', 'UR', 'UL', 'DR', 'DL', 'S'],
      moveUniform : {
        cornerProbabilities: [0.48, 0.48, 0.48, 0.48, 0.036, 0.036, 0.036, 0.036, 0.004],
        sideProbabilities: [0.32, 0.32, 0.32, 0.32, 0.018, 0.018, 0.018, 0.018, 0.004],
        midProbabilities: [0.24, 0.24, 0.24, 0.24, 0.009, 0.009, 0.009, 0.009, 0.004]
      },
      move: {
        cornerUR: [0.00, 0.00, 0.00, 0.96, 0.036, 0.036, 0.036, 0.036, 0.004],
        cornerUL: [0.00, 0.00, 0.00, 0.00, 0.036, 0.036, 0.036, 0.036, 0.964],
        cornerDR: [0.00, 0.00, 0.00, 0.96, 0.036, 0.036, 0.036, 0.036, 0.004],
        cornerDL: [0.00, 0.00, 0.00, 0.00, 0.036, 0.036, 0.036, 0.036, 0.964],
        sideU: [0.00, 0.00, 0.00, 0.96, 0.018, 0.018, 0.018, 0.018, 0.004],
        sideD: [0.00, 0.00, 0.00, 0.96, 0.018, 0.018, 0.018, 0.018, 0.004],
        sideL: [0.00, 0.00, 0.00, 0.00, 0.018, 0.018, 0.018, 0.018, 0.964],
        sideR: [0.00, 0.00, 0.00, 0.96, 0.018, 0.018, 0.018, 0.018, 0.004],
        mid: [0.00, 0.00, 0.00, 0.96, 0.009, 0.009, 0.009, 0.009, 0.004]
      },
      useMove: {}
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
    editToggle () {
      this.editing = ! this.editing;
    },
    changeValue (who, i, j) {
      who[i][j] = Math.max(0, Math.min(1, parseFloat('0' + who[i][j])))
      this.$set(who, i, who[i])
      this.$forceUpdate()
    },
    uniformToggle () {
      this.uniform = ! this.uniform
      this.useMove = this.uniform ? this.moveUniform : this.move
    },
    sumOk (array) {
      let sum = 0
      for (const value of array) {
        sum += value
      }
      return Math.abs(sum - 1) < 0.00001
    }
  },
  created () {
    this.useMove = this.moveUniform
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
#edit {
  font-size: 14px;
  margin-left: 20px;
  width: 45px;
  cursor: pointer;
}
#data > label > input {
  width: 55px;
}
table {
  border: 1px solid black;
  padding-left: 10px;
}
table > caption {
  margin-bottom: 5px;
}
td {
  width: 60px;
  height: 30px;
}
input {
  width: 55px;
}
#uniform {
  font-size: 14px;
  width: 70px;
  height: 30px;
  margin-top: 50px;
  margin-bottom: 20px;
  cursor: pointer;
}
</style>
