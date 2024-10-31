from "%rGui/globals/ui_library.nut" import *

let { rwrTargetsComponent, rwrPriorityTargetComponent } = require("rwrAnAlr56Components.nut")

function scope(scale, style) {
  return {
    size = [pw(scale), ph(scale)]
    vplace = ALIGN_CENTER
    hplace = ALIGN_CENTER
    children = [
      rwrTargetsComponent(style.object),
      rwrPriorityTargetComponent(style.object)
    ]
  }
}

let function tws(posWatched, sizeWatched, scale, style) {
  return @() {
    watch = [posWatched, sizeWatched]
    size = sizeWatched.get()
    pos = posWatched.get()
    halign = ALIGN_CENTER
    valign = ALIGN_CENTER
    children = scope(scale, style.__merge( {object = style.object.__merge({ scale = style.object.scale * 0.75}) }))
  }
}

return tws