<template>
  <div id="app">
    <Game/>
  </div>
</template>

<script>
import Game from "./components/Game";

export default {
  name: 'App',
  components: {
    Game
  }
}
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: black;
  margin-top: 20px;
}
input {
  font-size: 14px;
  width: 40px;
}
.center {
  margin-left: auto;
  margin-right: auto;
}
</style>
