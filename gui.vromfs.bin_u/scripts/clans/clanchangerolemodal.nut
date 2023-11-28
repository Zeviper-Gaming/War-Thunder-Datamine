//-file:plus-string
from "%scripts/dagui_library.nut" import *

let { move_mouse_on_child, loadHandler } = require("%scripts/baseGuiHandlerManagerWT.nut")
let { gui_handlers } = require("%sqDagui/framework/gui_handlers.nut")
let { format } = require("string")
let { broadcastEvent } = require("%sqStdLibs/helpers/subscriptions.nut")
let { getPlayerName } = require("%scripts/user/remapNick.nut")
let { handlerType } = require("%sqDagui/framework/handlerType.nut")
let lbDataType = require("%scripts/leaderboard/leaderboardDataType.nut")
let { userName } = require("%scripts/user/myUser.nut")
let { addTask } = require("%scripts/tasker.nut")

::gui_start_change_role_wnd <- function gui_start_change_role_wnd(contact, clanData) {
  if (!::clan_get_admin_editor_mode()) {
    let myClanRights = ::g_clans.getMyClanRights()
    let leadersCount = ::g_clans.getLeadersCount(clanData)
    if (contact.name == userName.value
        && isInArray("LEADER", myClanRights)
        && leadersCount <= 1)
      return ::g_popups.add("", loc("clan/leader/cant_change_my_role"))
  }

  local changeRolePlayer = {
    uid = contact.uid,
    name = contact.name,
    rank = ::g_clans.getClanMemberRank(clanData, contact.name)
  }

  loadHandler(gui_handlers.clanChangeRoleModal,
    {
      changeRolePlayer = changeRolePlayer,
      owner = this,
      clanType = clanData.clanType
    })
}

gui_handlers.clanChangeRoleModal <- class extends gui_handlers.BaseGuiHandlerWT {
  wndType = handlerType.MODAL
  sceneBlkName = "%gui/clans/clanChangeRoleWindow.blk"
  changeRolePlayer = null
  roles = []
  adminMode = false
  clanType = ::g_clan_type.UNKNOWN

  function initScreen() {
    this.roles = [];
    this.adminMode = ::clan_get_admin_editor_mode()
    local roleOptions = "";
    let roleListObj = this.scene.findObject("change_role_list");
    let titleObj = this.scene.findObject("title_text");
    let myRole = this.adminMode ? ECMR_CLANADMIN : ::clan_get_my_role()
    let myRank = ::clan_get_role_rank(myRole)

    if (checkObj(titleObj))
      titleObj.setValue("{0} {1}".subst(loc("clan/changeRoleTitle"), getPlayerName(this.changeRolePlayer.name)))

    for (local role = 0; role < ECMR_MAX_TOTAL; role++) {
       let roleName = ::clan_get_role_name(role);
       if (!roleName)
         continue;
       let rank = ::clan_get_role_rank(role);
       if (rank != 0 && (role != ECMR_LEADER || this.adminMode)
           && !isInArray("HIDDEN", ::clan_get_role_rights(role))
           && this.clanType.isRoleAllowed(role))
         this.roles.append({
           name = roleName,
           rank = rank,
           id = role,
           current = rank == this.changeRolePlayer.rank,
           enabled = rank < myRank || this.adminMode
         })
    }
    this.roles.sort(this.sortRoles)

    local curIdx = 0
    foreach (idx, role in this.roles) {
      roleOptions += format("shopFilter { id:t='role_%d'; shopFilterText { id:t='text'; width:t='pw'; %s } %s } \n",
        idx,
        role.current ? "style:t='color:@mainPlayerColor'; " : "",
        role.enabled ? "" : "enable:t='no'; "
      )
      if (role.current)
        curIdx = idx
    }

    this.guiScene.replaceContentFromText(roleListObj, roleOptions, roleOptions.len(), this)
    foreach (idx, role in this.roles) {
      let option = this.scene.findObject("role_" + idx)
      option.findObject("text").setValue(loc("clan/" + role.name))
      option.tooltip = (role.current ? (loc("clan/currentRole") + "\n\n") : "") + lbDataType.ROLE.getPrimaryTooltipText(role.id)
    }
    roleListObj.setValue(curIdx)
    move_mouse_on_child(roleListObj, curIdx)
  }

  function sortRoles(role1, role2) {
    let rank1 = getTblValue("rank", role1, -1)
    let rank2 = getTblValue("rank", role2, -1)
    if (rank1 != rank2)
      return rank1 > rank2 ? 1 : -1
    return 0
  }

  function onApply() {
    let roleListObj = this.scene.findObject("change_role_list");
    let newRoleIdx = roleListObj.getValue();

    if (!(newRoleIdx in this.roles))
      return;

    if (this.roles[newRoleIdx].current) {
      this.goBack();
      return;
    }

    let msg = loc("clan/roleChanged") + " " + loc("clan/" + this.roles[newRoleIdx].name)
    let taskId = ::clan_request_change_member_role(this.changeRolePlayer.uid, this.roles[newRoleIdx].name)

    if (taskId >= 0 && !this.adminMode)
      ::sync_handler_simulate_signal("clan_info_reload")

    let onTaskSuccess = function() {
      broadcastEvent("ClanMemberRoleChanged")
      ::g_popups.add(null, msg)
    }

    addTask(taskId, { showProgressBox = true }, onTaskSuccess)
    this.goBack()
  }
}
