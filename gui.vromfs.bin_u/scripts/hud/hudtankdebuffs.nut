//-file:plus-string
from "%scripts/dagui_library.nut" import *

//checked for explicitness
#no-root-fallback
#explicit-this
let { handyman } = require("%sqStdLibs/helpers/handyman.nut")

let { getConfigValueById } = require("%scripts/hud/hudTankStates.nut")

::g_hud_tank_debuffs <- {
  scene    = null
  guiScene = null


  tooltips = {
    horizontalDriveBroken = "hud_tank_turret_drive_h_broken"
    verticalDriveBroken   = "hud_tank_turret_drive_v_broken"
    barrelDamaged         = "hud_gun_barell_malfunction"
    breechDamaged         = "hud_gun_breech_malfunction"
    barrelBroken          = "hud_gun_barrel_exploded"
    breechBroken          = "hud_gun_breech_malfunction"
    transmissionBroken    = "hud_tank_transmission_damaged"
    engineBroken          = "hud_tank_engine_damaged"
    trackBroken           = "hud_tank_track_damaged"
  }


  function init(nest) {
    if (!hasFeature("TankDetailedDamageIndicator"))
      return

    this.scene = nest.findObject("tank_debuffs")

    if (!this.scene && !checkObj(this.scene))
      return

    this.guiScene = this.scene.getScene()
    let blk = handyman.renderCached("%gui/hud/hudTankDebuffs.tpl",
        {
          stabilizerValue = getConfigValueById("stabilizer"),
          lwsValue = getConfigValueById("lws"),
          ircmValue = getConfigValueById("ircm")
          firstStageAmmoValue = getConfigValueById("first_stage_ammo")
        }
      )
    this.guiScene.replaceContentFromText(this.scene, blk, blk.len(), this)

    ::g_hud_event_manager.subscribe("TankDebafs:Fire",
      function (debuffs_data) {
        this.scene.findObject("fire_status").show(debuffs_data.burns)
      }, this)

    ::g_hud_event_manager.subscribe("TankDebafs:TurretDrive",
      function (debuffs_data) {
        this.updateDebufSate(debuffs_data, this.scene.findObject("turret_drive_state"))
      }, this)

    ::g_hud_event_manager.subscribe("TankDebafs:Gun",
      function (debuffs_data) {
        this.updateDebufSate(debuffs_data, this.scene.findObject("gun_state"))
      }, this)

    ::g_hud_event_manager.subscribe("TankDebafs:Engine",
      function (debuffs_data) {
        this.updateDebufSate(debuffs_data, this.scene.findObject("engine_state"))
      }, this)

    ::g_hud_event_manager.subscribe("TankDebafs:Tracks",
      function (debuffs_data) {
        this.updateDebufSate(debuffs_data, this.scene.findObject("tracks_state"))
      }, this)

    ::hud_request_hud_tank_debuffs_state()
  }

  function reinit() {
    ::hud_request_hud_tank_debuffs_state()
  }

  function updateDebufSate(debuffs_data, obj) {
    obj.tooltip = this.getTooltip(debuffs_data)
    foreach (on in debuffs_data)
      if (on) {
        obj.state = (("engineDead" in debuffs_data && debuffs_data.engineDead) || ("horizontalDriveDead" in debuffs_data && debuffs_data.horizontalDriveDead)
          || ("barrelDead" in debuffs_data && debuffs_data.barrelDead) || ("breechDead" in debuffs_data && debuffs_data.breechDead))
          ? "dead" : "bad"
        return
      }
    obj.state = "ok"
  }

  function getTooltip(debuffs_data) {
    local res = ""
    foreach (debuffName, on in debuffs_data) {
      if (on && debuffName in this.tooltips)
        res += (res.len() ? "\n\n" : "") + loc(this.tooltips[debuffName])
    }
    return res
  }

  function isValid() {
    return checkObj(this.scene)
  }
}
