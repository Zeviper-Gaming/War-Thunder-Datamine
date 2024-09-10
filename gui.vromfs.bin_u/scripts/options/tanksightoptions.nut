from "%scripts/dagui_library.nut" import *

let { color4ToDaguiString } = require("%sqDagui/daguiUtil.nut")
let { TSI_RANGE_TEXT_COLOR, TSI_RANGE_BACK_COLOR, TSI_RANGE_NV_TEXT_COLOR, TSI_RANGE_NV_BACK_COLOR, TSI_RANGE_LTEXT_COLOR,
  TSI_RANGE_LBACK_COLOR, TSI_RANGE_TEXT_SIZE, TSI_TURRET_VISIBLE, TSI_TURRET_COLOR, TSI_TURRET_LIGHT_COLOR,
  TSI_TURRET_NV_COLOR, TSI_FOV_VISIBLE, TSI_FOV_COLOR, TSI_FOV_LIGHT_COLOR, TSI_FOV_NV_COLOR, TSI_GUN_READY_VISIBLE,
  TSI_GUN_READY_TEXT_SIZE, TSI_GUN_READY_COLOR, TSI_GUN_READY_LIGHT_COLOR, TSI_GUN_READY_NV_COLOR, TSO_RANGEFINDER,
  TSO_TURRET, TSO_FOV, TSO_GUN_READY, TSI_RANGE_TH_TEXT_COLOR, TSI_RANGE_TH_BACK_COLOR, TSI_TURRET_TH_COLOR,
  TSI_FOV_THERMAL_COLOR, TSI_GUN_READY_TH_COLOR, TSI_CROSSHAIR, TSO_CROSSHAIR, TSI_RANGEFINDER_VISIBLE, TSI_RANGEFINDER_FONT,
  TSI_CROSSHAIR_COLOR, TSI_CROSSHAIR_L_COLOR, TSI_CROSSHAIR_NV_COLOR, TSI_CROSSHAIR_TH_COLOR, TSI_GUN_READY_FONT
} = require("tankSightSettings")
let { crosshair_colors } = require("%scripts/options/optionsExt.nut")
let { isEqual } = require("%globalScripts/isEqual.nut")
let { has_forced_crosshair, get_user_alt_crosshairs } = require("crosshair")
let unitOptions = require("%scripts/options/tankSightUnitOptions.nut")
let { doesLocTextExist } = require("dagor.localize")
let { Color4 } = require("dagor.math")

let tankSightOptionsSections = [
  {
    id = TSO_CROSSHAIR
    title = "#tankSight/sight"
    options = [TSI_CROSSHAIR,
     TSI_CROSSHAIR_COLOR, TSI_CROSSHAIR_L_COLOR, TSI_CROSSHAIR_NV_COLOR, TSI_CROSSHAIR_TH_COLOR]
  }
  {
    id = TSO_RANGEFINDER
    title = "#hotkeys/ID_RANGEFINDER"
    options = [
      TSI_RANGEFINDER_VISIBLE, TSI_RANGE_TEXT_COLOR, TSI_RANGE_BACK_COLOR, TSI_RANGE_NV_TEXT_COLOR, TSI_RANGE_NV_BACK_COLOR,
      TSI_RANGE_LTEXT_COLOR, TSI_RANGE_LBACK_COLOR, TSI_RANGE_TH_TEXT_COLOR, TSI_RANGE_TH_BACK_COLOR,
      TSI_RANGE_TEXT_SIZE, TSI_RANGEFINDER_FONT
    ]
  }
  {
    id = TSO_TURRET
    title = "#tankSight/turret"
    options = [TSI_TURRET_VISIBLE, TSI_TURRET_COLOR, TSI_TURRET_LIGHT_COLOR, TSI_TURRET_NV_COLOR, TSI_TURRET_TH_COLOR]
  }
  {
    id = TSO_FOV
    title = "#tankSight/fov"
    options = [TSI_FOV_VISIBLE, TSI_FOV_COLOR, TSI_FOV_LIGHT_COLOR, TSI_FOV_NV_COLOR, TSI_FOV_THERMAL_COLOR]
  }
  {
    id = TSO_GUN_READY
    title = "#tankSight/gunReady"
    options = [
      TSI_GUN_READY_VISIBLE, TSI_GUN_READY_TEXT_SIZE, TSI_GUN_READY_FONT, TSI_GUN_READY_COLOR, TSI_GUN_READY_LIGHT_COLOR,
      TSI_GUN_READY_NV_COLOR, TSI_GUN_READY_TH_COLOR
    ]
  }
]

let visibilityOpts = [
  {value = true, text = "#controls/on"}
  {value = false, text = "#controls/off"}
]
let textSizeOpts = [
  {value = 20, text = "#options/small_text"}
  {value = 30, text = "#options/medium_text"}
  {value = 40, text = "#options/large_text"}
]
let mkFontOpts = @() ["digital", "hud", "tiny_text_hud", "ils31", "ussr_ils", "usa_ils", "mirage_ils", "ah64", "f14_ils"]
  .map(function(fontType) {
    let fontTypeLoc = doesLocTextExist($"tankSight/fontType/{fontType}")
      ? loc($"tankSight/fontType/{fontType}")
      : fontType
    return {
      value = fontType
      text = loc("tankSight/fontType" , { fontType = fontTypeLoc })
    }
  })

let colorOpts = persist("tankSightColorOpts", @() [])
let tankSightOptionsMap = persist("tankSightOptionsMap", @() {})

function getCrosshairOpts() {
  let options = get_user_alt_crosshairs(unitOptions.UNIT.value ?? "", unitOptions.COUNTRY.value ?? "")
    .map(@(preset) {
      value = preset,
      text = doesLocTextExist($"tankSight/{preset}") ? loc($"tankSight/{preset}") : preset
    })

  if (!has_forced_crosshair())
    options.insert(0, { value = "", text = loc("options/defaultSight") })

  return { idx = 0, options }
}

let getVisibilityOpts = @(idx = 0) { idx, options = visibilityOpts }
let getTextSizeOpts = @(idx = 0) { idx, options = textSizeOpts }
let getFontOpts = @(idx = 0) { idx, options = mkFontOpts() }
let getColorOpts = @(options, text = "", idx = 9) { idx, options = options.map(@(opt) opt.__merge({ text })) }

let transparentColorOption = {
  hueColor = "00000000"
  value = Color4(0, 0, 0, 0)
}

function mkTankSightOptionsMap(params) {
  let bgColorOpts = [].extend(params.colorOpts, [transparentColorOption])

  return {
    [TSI_CROSSHAIR]             = getCrosshairOpts(),
    [TSI_CROSSHAIR_COLOR]       = getColorOpts(params.colorOpts, "#tankSight/crosshairColor"),
    [TSI_CROSSHAIR_L_COLOR]     = getColorOpts(params.colorOpts, "#tankSight/crosshairLightColor"),
    [TSI_CROSSHAIR_NV_COLOR]    = getColorOpts(params.colorOpts, "#tankSight/crosshairNvColor"),
    [TSI_CROSSHAIR_TH_COLOR]    = getColorOpts(params.colorOpts, "#tankSight/crosshairThColor"),

    [TSI_RANGEFINDER_VISIBLE]   = getVisibilityOpts(),
    [TSI_RANGE_TEXT_COLOR]      = getColorOpts(params.colorOpts, "#options/show_indicators_type"),
    [TSI_RANGE_BACK_COLOR]      = getColorOpts(bgColorOpts, "#tankSight/bgColor"),
    [TSI_RANGE_NV_TEXT_COLOR]   = getColorOpts(params.colorOpts, "#tankSight/nightVisionTextColor"),
    [TSI_RANGE_NV_BACK_COLOR]   = getColorOpts(bgColorOpts, "#tankSight/nightVisionBgColor"),
    [TSI_RANGE_LTEXT_COLOR]     = getColorOpts(params.colorOpts, "#tankSight/backlightTextColor"),
    [TSI_RANGE_LBACK_COLOR]     = getColorOpts(bgColorOpts, "#tankSight/backlightBgColor"),
    [TSI_RANGE_TH_TEXT_COLOR]   = getColorOpts(params.colorOpts, "#tankSight/thermalTextColor"),
    [TSI_RANGE_TH_BACK_COLOR]   = getColorOpts(bgColorOpts, "#tankSight/thermalBgColor"),
    [TSI_RANGE_TEXT_SIZE]       = getTextSizeOpts(1),
    [TSI_RANGEFINDER_FONT]      = getFontOpts(),

    [TSI_TURRET_VISIBLE]        = getVisibilityOpts(1),
    [TSI_TURRET_COLOR]          = getColorOpts(params.colorOpts, "#tankSight/color"),
    [TSI_TURRET_LIGHT_COLOR]    = getColorOpts(params.colorOpts, "#tankSight/backlightColor"),
    [TSI_TURRET_NV_COLOR]       = getColorOpts(params.colorOpts, "#tankSight/nightVisionColor"),
    [TSI_TURRET_TH_COLOR]       = getColorOpts(params.colorOpts, "#tankSight/thermalColor"),

    [TSI_FOV_VISIBLE]           = getVisibilityOpts(1),
    [TSI_FOV_COLOR]             = getColorOpts(params.colorOpts, "#tankSight/color"),
    [TSI_FOV_LIGHT_COLOR]       = getColorOpts(params.colorOpts, "#tankSight/backlightColor"),
    [TSI_FOV_NV_COLOR]          = getColorOpts(params.colorOpts, "#tankSight/nightVisionColor"),
    [TSI_FOV_THERMAL_COLOR]     = getColorOpts(params.colorOpts, "#tankSight/thermalColor"),

    [TSI_GUN_READY_VISIBLE]     = getVisibilityOpts(1),
    [TSI_GUN_READY_TEXT_SIZE]   = getTextSizeOpts(1),
    [TSI_GUN_READY_FONT]        = getFontOpts(),
    [TSI_GUN_READY_COLOR]       = getColorOpts(params.colorOpts, "#tankSight/color"),
    [TSI_GUN_READY_LIGHT_COLOR] = getColorOpts(params.colorOpts, "#tankSight/backlightColor"),
    [TSI_GUN_READY_NV_COLOR]    = getColorOpts(params.colorOpts, "#tankSight/nightVisionColor"),
    [TSI_GUN_READY_TH_COLOR]    = getColorOpts(params.colorOpts, "#tankSight/thermalColor")
  }
}


function initTankSightOptions() {
  colorOpts.clear()
  tankSightOptionsMap.clear()

  colorOpts.extend(crosshair_colors.map(@(col) {
    hueColor = color4ToDaguiString(col.color)
    value = col.color
  }))
  tankSightOptionsMap.__update(mkTankSightOptionsMap({ colorOpts }))
}

let getSightOptionValueIdx = @(optType, value)
  tankSightOptionsMap?[optType].options.findindex(@(opt) isEqual(opt.value, value))

return {
  tankSightOptionsMap,
  tankSightOptionsSections,
  getSightOptionValueIdx,
  getCrosshairOpts
  initTankSightOptions
}