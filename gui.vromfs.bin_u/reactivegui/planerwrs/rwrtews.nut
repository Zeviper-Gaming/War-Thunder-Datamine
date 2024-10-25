from "%rGui/globals/ui_library.nut" import *

let math = require("math")
let { degToRad } = require("%sqstd/math_ex.nut")

let { color, rwrTargetsComponent, rwrPriorityTargetComponent } = require("rwrAnAlr56Components.nut")

function makeGridCommands() {
  let commands = [
    [VECTOR_LINE, -10, 0, 10, 0],
    [VECTOR_LINE, 0, -10, 0, 10] ]
  for (local az = 0.0; az < 360.0; az += 30)
    commands.append([VECTOR_ELLIPSE, math.sin(degToRad(az)) * 90.0, math.cos(degToRad(az)) * 90.0, 2, 2])
  return commands
}

let gridCommands = makeGridCommands()

function createGrid() {
  return {
    pos = [pw(50), ph(50)]
    size = flex()
    color = color
    rendObj = ROBJ_VECTOR_CANVAS
    lineWidth = hdpx(4)
    fillColor = color
    commands = gridCommands
  }
}

function scope(scale, fontSizeMult) {
  return {
    size = [pw(scale), ph(scale)]
    vplace = ALIGN_CENTER
    hplace = ALIGN_CENTER
    children = [
      createGrid(),
      rwrTargetsComponent(0.5, fontSizeMult),
      rwrPriorityTargetComponent(0.5)
    ]
  }
}

let function tws(posWatched, sizeWatched, scale, fontSizeMult) {
  return @() {
    watch = [posWatched, sizeWatched]
    size = sizeWatched.get()
    pos = posWatched.get()
    halign = ALIGN_CENTER
    valign = ALIGN_CENTER
    children = scope(scale, fontSizeMult)
  }
}

return tws