//-file:plus-string
from "%scripts/dagui_natives.nut" import get_name_by_unlock_type
from "%scripts/dagui_library.nut" import *
from "%scripts/items/itemsConsts.nut" import itemType
from "%scripts/mainConsts.nut" import SEEN
let getShipFlags = require("%scripts/customization/shipFlags.nut")
let { LayersIcon } = require("%scripts/viewUtils/layeredIcon.nut")
let { format, split_by_chars } = require("string")
let { ceil } = require("math")
let { number_of_set_bits, round_by_value } = require("%sqstd/math.nut")
let { buildDateStrShort, buildDateTimeStr } = require("%scripts/time.nut")
let { processUnitTypeArray } = require("%scripts/unit/unitClassType.nut")
let { getRoleText } = require("%scripts/unit/unitInfoTexts.nut")
let { isLoadingBgUnlock, getLoadingBgName,
  getLoadingBgIdByUnlockId } = require("%scripts/loading/loadingBgData.nut")
let { getEntitlementConfig, getEntitlementName } = require("%scripts/onlineShop/entitlements.nut")
let { shopCountriesList } = require("%scripts/shop/shopCountriesList.nut")
let { loadCondition, isBitModeType, getMainProgressCondition, isNestedUnlockMode, isTimeRangeCondition,
  getRangeString, getUnlockConditions, getDiffNameByInt, isStreak, getProgressBarData
} = require("%scripts/unlocks/unlocksConditions.nut")
let { getUnlockById } = require("%scripts/unlocks/unlocksCache.nut")
let { getUnlockCost, isUnlockComplete, getUnlockType, isUnlockOpened, canClaimUnlockReward,
  isUnlockVisibleByTime, debugLogVisibleByTimeInfo
} = require("%scripts/unlocks/unlocksModule.nut")
let { getDecoratorById, getDecorator } = require("%scripts/customization/decorCache.nut")
let { getPlaneBySkinId } = require("%scripts/customization/skinUtils.nut")
let { cutPrefix } = require("%sqstd/string.nut")
let { getLocIdsArray } = require("%scripts/langUtils/localization.nut")
let { getUnlockProgressSnapshot } = require("%scripts/unlocks/unlockProgressSnapshots.nut")
let { season, seasonLevel, getLevelByExp } = require("%scripts/battlePass/seasonState.nut")
let { getUnitName } = require("%scripts/unit/unitInfo.nut")
let { getMissionTimeText } = require("%scripts/missions/missionsUtils.nut")
let { hasActiveUnlock, getUnitListByUnlockId } = require("%scripts/unlocks/unlockMarkers.nut")
let { getTypeByResourceType } = require("%scripts/customization/types.nut")
let { placePriceTextToButton } = require("%scripts/viewUtils/objectTextUpdate.nut")
let { makeConfigStr } = require("%scripts/seen/bhvUnseen.nut")
let { getShopDiffCode } = require("%scripts/shop/shopDifficulty.nut")

let customLocTypes = ["gameModeInfoString", "missionPostfix"]

let conditionsOrder = [
  "beginDate", "endDate", "battlepassProgress", "battlepassLevel",
  "missionsWon", "mission", "char_mission_completed",
  "missionType", "atLeastOneUnitsRankOnStartMission", "maxUnitsRankOnStartMission",
  "unitExists", "additional", "unitClass",
  "gameModeInfoString", "missionPostfix", "missionEnvironment", "modes", "events", "tournamentMode",
  "location", "operationMap", "weaponType", "ammoMass", "bulletCaliber", "difficulty",
  "playerUnit", "playerType", "playerExpClass", "playerUnitRank", "playerUnitMRank", "playerTag", "playerCountry",
  "offenderUnit", "offenderType", "offenderUnitRank", "offenderUnitMRank", "offenderTag", "offenderSpeed",
  "targetUnit", "targetType", "targetTag",
  "crewsUnit", "crewsUnitRank", "crewsUnitMRank", "crewsTag", "usedPlayerUnit", "lastPlayerUnit",
  "activity", "minStat", "statPlaceInSession", "statScoreInSession", "statAwardDamageInSession",
  "statKillsPlayerInSession", "statKillsAirInSession", "statKillsAirAiInSession",
  "statKillsGroundInSession", "statKillsGroundAiInSession",
  "statKillsNavalInSession", "statKillsNavalAiInSession",
  "statKillsSurfaceInSession", "statKillsSurfaceAiInSession",
  "targetIsPlayer", "eliteUnitsOnly", "noPremiumVehicles", "era", "country",
  "targets", "targetDistance", "higherBR"
]

let condWithValuesInside = [
  "atLeastOneUnitsRankOnStartMission", "eliteUnitsOnly"
]

let mapConditionUnitType = {
  aircraft          = "unit_aircraft"
  tank              = "unit_tank"
  typeLightTank     = "type_light_tank"
  typeMediumTank    = "type_medium_tank"
  typeHeavyTank     = "type_heavy_tank"
  typeSPG           = "type_tank_destroyer"
  typeSPAA          = "type_spaa"
  typeTankDestroyer = "type_tank_destroyer"
  typeFighter       = "type_fighter"
  typeDiveBomber    = "type_dive_bomber"
  typeBomber        = "type_bomber"
  typeAssault       = "type_strike_aircraft"
  typeStormovik     = "type_strike_aircraft"
  typeTransport     = "type_transport"
  typeStrikeFighter = "type_strike_fighter"
  typeDestroyer     = "type_destroyer"
  typeTorpedoBoat   = "type_torpedo_boat"
}

let function findPreviewablePrize(unlockCfg) {
  if (unlockCfg.userLogId == null)
    return null

  let itemId = unlockCfg.unlockType == UNLOCKABLE_INVENTORY
    ? unlockCfg.userLogId.tointeger()
    : unlockCfg.userLogId
  let item = ::ItemsManager.findItemById(itemId)
  if (item == null)
    return null

  if (item.iType == itemType.VEHICLE
      || item.iType == itemType.ATTACHABLE
      || item.iType == itemType.SKIN
      || item.iType == itemType.DECAL)
    return item

  if (item.iType == itemType.TROPHY) {
    if (item.getContent().len() != 1)
      return null

    let prize = item.getTopPrize()
    if (prize?.unit != null)
      return getAircraftByName(prize.unit)

    if (prize?.resourceType != null && prize?.resource != null) {
      let decType = getTypeByResourceType(prize.resourceType)
      return getDecorator(prize.resource, decType)
    }
  }

  return null
}

let canPreviewUnlockPrize = @(unlockCfg) findPreviewablePrize(unlockCfg)?.canPreview() ?? false
let doPreviewUnlockPrize = @(unlockCfg) findPreviewablePrize(unlockCfg)?.doPreview()

let function getUnlockBeginDateText(unlock) {
  let isBlk = unlock?.mode != null
  let conds = isBlk ? getUnlockConditions(unlock.mode) : unlock?.conditions
  local timeCond = conds?.findvalue(@(c) isTimeRangeCondition(c.type))
  if (isBlk)
    timeCond = loadCondition(timeCond, unlock)
  return (timeCond?.beginTime != null)
    ? buildDateStrShort(timeCond.beginTime).replace(" ", nbsp)
    : ""
}

let function getUnlockLocName(config, key = "locId") {
  let isRawBlk = (config?.mode != null)
  local num = (isRawBlk ? config.mode?.num : config?.maxVal) ?? 0
  if (num > 0)
    num = isBitModeType(isRawBlk ? config.mode.type : config.type) ? number_of_set_bits(num) : num
  local numRealistic = (isRawBlk ? config.mode?.mulRealistic : config?.conditions[0].multiplier.HistoricalBattle) ?? 1
  local numHardcore = (isRawBlk ? config.mode?.mulHardcore : config?.conditions[0].multiplier.FullRealBattles) ?? 1
  numRealistic = ceil(num.tofloat() / numRealistic)
  numHardcore = ceil(num.tofloat() / numHardcore)

  return "".join(getLocIdsArray(config?[key]).map(@(locId) locId.len() == 1 ? locId :
    loc(locId, { num, numRealistic, numHardcore, beginDate = getUnlockBeginDateText(config) })))
}

let function getSubUnlockLocName(config) {
  let subUnlockBlk = getUnlockById(config?.mode.unlock ?? config?.conditions[0].values[0] ?? "")
  if (subUnlockBlk)
    return subUnlockBlk.locId ? getUnlockLocName(subUnlockBlk) : loc($"{subUnlockBlk.id}/name")
  else
    return ""
}

let function getUnlockRewardsText(config) {
  let textsList = []
  if ("reward" in config)
    textsList.append(config.reward.tostring())
  if ("rewardWarbonds" in config)
    textsList.append(::g_warbonds.getWarbondPriceText(config.rewardWarbonds.wbAmount))
  return ", ".join(textsList, true)
}

let function getUnlockTypeText(unlockType, id = null) {
  if (unlockType == UNLOCKABLE_AUTOCOUNTRY)
    return loc("unlocks/country")

  if (id && ::g_battle_tasks.isBattleTask(id))
    return loc("unlocks/battletask")

  if (id && isLoadingBgUnlock(id))
    return loc("unlocks/loading_bg")

  return loc($"unlocks/{get_name_by_unlock_type(unlockType)}")
}

let function getDifficultyLocalizationText(difficulty) {
  return difficulty == "hardcore"  ? loc("difficulty2")
    : difficulty == "realistic" ? loc("difficulty1")
    : loc("difficulty0")
}

function isFlagUnlock(id) {
  return id in getShipFlags()
}

function getSubunlockOrUnlockName(id) {
  let unlockBlk = getUnlockById(id)
  if (unlockBlk?.useSubUnlockName)
    return getSubUnlockLocName(unlockBlk)
  if (unlockBlk?.locId)
    return getUnlockLocName(unlockBlk)
  return loc($"{id}/name")
}

let unlockTypeToGetNameFunc = {
  [UNLOCKABLE_AIRCRAFT] = @(id) getUnitName(id),
  [UNLOCKABLE_SKIN] = function(id) {
    let unitName = getPlaneBySkinId(id)
    let res = getDecoratorById(id)?.getDesc() ?? ""
    return unitName != ""
      ? "".concat(res, loc("ui/parentheses/space", { text = getUnitName(unitName) }))
      : res
  },
  [UNLOCKABLE_DECAL] = @(id) loc($"decals/{id}"),
  [UNLOCKABLE_ATTACHABLE] = @(id) loc($"attachables/{id}"),
  [UNLOCKABLE_WEAPON] = @(_) "",
  [UNLOCKABLE_ACHIEVEMENT] = @(id) getSubunlockOrUnlockName(id),
  [UNLOCKABLE_CHALLENGE] = @(id) getSubunlockOrUnlockName(id),
  [UNLOCKABLE_INVENTORY] = @(id) getSubunlockOrUnlockName(id),
  [UNLOCKABLE_DIFFICULTY] = @(id) getDifficultyLocalizationText(id),
  [UNLOCKABLE_ENCYCLOPEDIA] = function(id) {
    let index = id.indexof("/")
    return (index != null)
      ? loc($"encyclopedia/{id.slice(index + 1)}")
      : loc($"encyclopedia/{id}")
  },
  [UNLOCKABLE_SINGLEMISSION] = function(id) {
    let index = id.indexof("/")
    return (index != null)
      ? loc($"missions/{id.slice(index + 1)}")
      : loc($"missions/{id}")
  },
  [UNLOCKABLE_TITLE] = @(id) loc($"title/{id}"),
  [UNLOCKABLE_PILOT] = @(id) loc($"{id}/name", ""),
  [UNLOCKABLE_STREAK] = function(id) {
    let unlockBlk = getUnlockById(id)
    if (unlockBlk?.useSubUnlockName)
      return getSubUnlockLocName(unlockBlk)
    if (unlockBlk?.locId)
      return getUnlockLocName(unlockBlk)

    let res = loc($"streaks/{id}")
    return res.indexof("%d") != null
      ? loc($"streaks/{id}/multiple")
      : res
  },
  [UNLOCKABLE_AWARD] = function(id) {
    if (isLoadingBgUnlock(id))
      return getLoadingBgName(getLoadingBgIdByUnlockId(id))
    if (isFlagUnlock(id))
      return loc($"{id}/name")
    return loc($"award/{id}")
  },
  [UNLOCKABLE_ENTITLEMENT] = @(id) getEntitlementName(getEntitlementConfig(id)),
  [UNLOCKABLE_COUNTRY] = @(id) loc(id),
  [UNLOCKABLE_AUTOCOUNTRY] = @(_) loc("award/autocountry"),
  [UNLOCKABLE_SLOT] = @(_) loc("options/crew"),
  [UNLOCKABLE_DYNCAMPAIGN] = function(id) {
    let parts = split_by_chars(id, "_")
    local countryId = (parts.len() > 1) ? $"country_{parts[parts.len() - 1]}" : null
    if (isInArray(countryId, shopCountriesList))
      parts.pop()
    else
      countryId = null

    let locId = $"dynamic/{"_".join(parts, true)}"
    return countryId
      ? "".concat(loc(locId), loc("ui/parentheses/space", { text = loc(countryId) }))
      : loc(locId)
  },
  [UNLOCKABLE_TROPHY] = function(id) {
    let unlockBlk = getUnlockById(id)
    if (unlockBlk?.locId)
      return getUnlockLocName(unlockBlk)
    let item = ::ItemsManager.findItemById(id, itemType.TROPHY)
    return item ? item.getName(false) : loc($"item/{id}")
  },
  [UNLOCKABLE_YEAR] = @(id) (id.len() > 4) ? id.slice(id.len() - 4, id.len()) : "",
  [UNLOCKABLE_MEDAL] = function(id) {
    let unlockBlk = getUnlockById(id)
    if (getTblValue("subType", unlockBlk) == "clan_season_reward") {
      let unlock = ::ClanSeasonPlaceTitle.createFromUnlockBlk(unlockBlk)
      return unlock.name()
    }
  }
}

// unlockType = -1 finds type by id, so better to use correct unlock type if it's already known
let function getUnlockNameText(unlockType, id) {
  if (::g_battle_tasks.isBattleTask(id))
    return ::g_battle_tasks.getBattleTaskNameById(id)

  if (unlockType == -1)
    unlockType = getUnlockType(id)

  return unlockTypeToGetNameFunc?[unlockType](id) ?? loc($"{id}/name")
}

let function getUnlockTitle(unlockConfig) {
  local name = unlockConfig.useSubUnlockName ? getSubUnlockLocName(unlockConfig)
    : unlockConfig.locId != "" ? getUnlockLocName(unlockConfig)
    : getUnlockNameText(unlockConfig.unlockType, unlockConfig.id)
  if (name == "")
    name = getUnlockTypeText(unlockConfig.unlockType, unlockConfig.id)

  let hasStages = unlockConfig.stages.len() > 0
  let stage = (unlockConfig.needToAddCurStageToName && hasStages && (unlockConfig.curStage >= 0))
    ? unlockConfig.curStage + (isUnlockOpened(unlockConfig.id) ? 0 : 1)
    : 0
  return $"{name} {::roman_numerals[stage]}"
}

let function getUnlockChapterAndGroupText(unlockBlk) {
  let chapterAndGroupText = []
  if ("chapter" in unlockBlk)
    chapterAndGroupText.append(loc($"unlocks/chapter/{unlockBlk.chapter}"))
  if ((unlockBlk?.group ?? "") != "") {
    local locId = $"unlocks/group/{unlockBlk.group}"
    let parentUnlock = getUnlockById(unlockBlk.group)
    if (parentUnlock?.chapter == unlockBlk?.chapter)
      locId = $"{parentUnlock.id}/name"
    chapterAndGroupText.append(loc(locId))
  }
  return chapterAndGroupText.len() > 0
    ? $"({", ".join(chapterAndGroupText, true)})"
    : ""
}

let function getLocForBitValues(modeType, values, hasCustomUnlockableList = false) {
  let valuesLoc = []
  if (hasCustomUnlockableList || isNestedUnlockMode(modeType))
    foreach (name in values)
      valuesLoc.append(getUnlockNameText(-1, name))
  else if (modeType == "char_unit_exist")
    foreach (name in values)
      valuesLoc.append(getUnitName(name))
  else if (modeType == "char_resources")
    foreach (id in values) {
      let decorator = getDecoratorById(id)
      valuesLoc.append(decorator?.getName?() ?? id)
    }
  else {
    local nameLocPrefix = ""
    if (modeType == "char_mission_list" || modeType == "char_mission_completed")
      nameLocPrefix = "missions/"
    else if (modeType == "char_buy_modification_list")
      nameLocPrefix = "modification/"

    foreach (name in values)
      valuesLoc.append(loc("".concat(nameLocPrefix, name)))
  }
  return valuesLoc
}

let function getUnlockStagesDesc(cfg) {
  if (cfg == null)
    return ""

  let hasStages = cfg.stages.len() > 1
  let hideDesc = isUnlockComplete(cfg) && !cfg.useLastStageAsUnlockOpening
  if (!hasStages || hideDesc)
    return ""

  if (cfg.locStagesDescId != "")
    return "".concat(
      loc(cfg.locStagesDescId),
      loc("ui/colon"),
      colorize("unlockActiveColor", loc($"{cfg.curStage}/{cfg.stages.len()}")))

  return loc("challenge/stage", {
    stage = colorize("unlockActiveColor", cfg.curStage + 1)
    totalStages = colorize("unlockActiveColor", cfg.stages.len())
  })
}

let function getAdditionalStagesDesc(cfg) {
  if (cfg == null)
    return ""

  let itemId = cfg.additionalStagesDescAsItemCountId
  if (itemId <= 0)
    return ""

  let textId = cfg.additionalStagesDescAsItemCountLocId
  let curCount = ::ItemsManager.getRawInventoryItemAmount(itemId)
  let maxCount = cfg.additionalStagesDescAsItemCountMax

  return "".concat(
    loc(textId),
    loc("ui/colon"),
    colorize("unlockActiveColor", loc($"{curCount}/{maxCount}")))
}

let function getUnlockDesc(cfg) {
  let desc = [getUnlockStagesDesc(cfg), getAdditionalStagesDesc(cfg)]

  let hasDescInConds = cfg?.conditions.findindex(@(c) "typeLocIDWithoutValue" in c) != null
  if (!hasDescInConds)
    if ((cfg?.locDescId ?? "") != "") {
      let isBitMode = isBitModeType(cfg.type)
      let num = isBitMode ? number_of_set_bits(cfg.maxVal) : cfg.maxVal
      desc.append(loc(cfg.locDescId, { num }))
    }
    else if ((cfg?.desc ?? "") != "")
      desc.append(cfg.desc)

  return "\n".join(desc, true)
}

let function addValueToGroup(groupsList, group, value) {
  if (group not in groupsList)
    groupsList[group] <- []
  groupsList[group].append(value)
}

let function addTextToCondTextList(condTextsList, group, valuesData, params = null) {
  local groupLocId = $"conditions/{group}"

  if (group == "battlepassLevel")
    groupLocId = "conditions/battlepassProgress"
  else if (group == "missionEnvironment")
    groupLocId = "options/time"

  local valuesText = loc("ui/comma").join(valuesData, true)
  if (valuesText != "") {
    let isExpired = group == "endDate" && params?.isExpired
    valuesText = colorize(isExpired ? "red" : "unlockActiveColor", valuesText)
  }

  local text = !isInArray(group, customLocTypes)
    ? loc(groupLocId, { value = valuesText })
    : params?.customLocGroupText ?? ""

  if (!isInArray(group, condWithValuesInside))
    if (valuesText != "")
      text = $"{text}{(text.len() ? loc("ui/colon") : "")}{valuesText}"
    else
      text = ""

  condTextsList.append(text)
}

let unitCondType = {
  playerUnit = true
  offenderUnit = true
  targetUnit = true
  crewsUnit = true
  unitExists = true
  usedInSessionUnit = true
  lastInSessionUnit = true
}

let playerCondType = {
  playerType = true
  targetType = true
  usedInSessionType = true
  lastInSessionType = true
  offenderType = true
}

let playerClassCondType = {
  playerExpClass = true
  unitClass = true
  usedInSessionClass = true
  lastInSessionClass = true
}

let playerTagCondType = {
  playerTag = true
  offenderTag = true
  crewsTag = true
  targetTag = true
  country = true
  playerCountry = true
  usedInSessionTag = true
  lastInSessionTag = true
}

let ammoCondType = {
  ammoMass = true
  bulletCaliber = true
  offenderSpeed = true
}

let rankCondType = {
  activity = true
  playerUnitRank = true
  offenderUnitRank = true
  playerUnitMRank = true
  offenderUnitMRank = true
  crewsUnitRank = true
  crewsUnitMRank = true
  minStat = true
  higherBR = true
}

let missionCondType = {
  mission = true
  char_mission_completed = true
  missionType = true
}

let eraAndRnakCondType = {
  era = true
  maxUnitsRankOnStartMission = true
}

let function getUsualCondValueText(condType, v, condition) {
  if (condType in unitCondType)
    return getUnitName(v)
  if (condType in playerCondType)
    return loc($"unlockTag/{getTblValue(v, mapConditionUnitType, v)}")
  if (condType in playerClassCondType)
    return getRoleText(cutPrefix(v, "exp_", v))
  if (condType in playerTagCondType)
    return loc($"unlockTag/{v}")
  if (condType == "targetDistance")
    return format(loc($"conditions/{condition.gt ? "min" : "max"}_limit"), v.tostring())
  if (condType in ammoCondType)
    return format(loc(v.notLess ? "conditions/min_limit" : "conditions/less"), v.value.tostring())
  if (condType in rankCondType)
    return v.tostring()
  if (condType in missionCondType)
    return loc($"missions/{v}")
  if (condType == "missionEnvironment")
    return getMissionTimeText(v)
  if (condType in eraAndRnakCondType)
    return get_roman_numeral(v)
  if (condType == "events")
    return ::events.getNameByEconomicName(v)
  if (condType == "offenderIsSupportGun")
    return loc(v)
  if (condType == "operationMap")
    return loc($"worldWar/map/{v}")
  if (condType == "difficulty") {
    local text = getDifficultyLocalizationText(v)
    if (!getTblValue("exact", condition, false) && v != "hardcore")
      text = $"{text} {loc("conditions/moreComplex")}"
    return text
  }
  if (condType == "battlepassProgress") {
    let reqLevel = getLevelByExp(v)
    if (condition.season != season.value)
      return $"{reqLevel}"
    let curLevelText = loc("conditions/battlepassProgress/currentLevel", { level = seasonLevel.value })
    return reqLevel <= seasonLevel.value
      ? $"{reqLevel} {curLevelText}"
      : $"{reqLevel} {colorize("red" ,curLevelText)}"
  }
  if (condType == "battlepassLevel") {
    if (condition.season != season.value)
      return $"{v}"
    let curLevelText = loc("conditions/battlepassProgress/currentLevel", { level = seasonLevel.value })
    return v <= seasonLevel.value
      ? $"{v} {curLevelText}"
      : $"{v} {colorize("red" ,curLevelText)}"
  }
  return condType ? loc($"{condType}/{v}") : ""
}

let function addUsualConditionsText(groupsList, condition) {
  let condType = condition.type
  let group = getTblValue("locGroup", condition, condType)
  local values = condition.values
  local text = ""

  if (values == null)
    return addValueToGroup(groupsList, group, text)

  if (type(values) != "array")
    values = [values]

  values = processUnitTypeArray(values)
  foreach (v in values)
    addValueToGroup(groupsList, group, getUsualCondValueText(condType, v, condition))
}

let function addUniqConditionsText(groupsList, condition) {
  let condType = condition.type

  if (isTimeRangeCondition(condType)) {
    foreach (key in ["beginDate", "endDate"])
      if (key in condition)
        addValueToGroup(groupsList, key, condition[key])
    return true
  }

  if (condType == "atLeastOneUnitsRankOnStartMission") {
    let valuesTexts = condition.values?.map(get_roman_numeral) ?? []
    addValueToGroup(groupsList, condType, "-".join(valuesTexts, true))
    return true
  }

  if (condType == "eliteUnitsOnly") {
    addValueToGroup(groupsList, condType, "")
    return true
  }

  return false
}

let function addDataToCustomGroup(groupsList, condType, data) {
  if (condType not in groupsList)
    groupsList[condType] <- []

  let customData = groupsList[condType]
  foreach (conditionData in customData)
    if (data.groupText == getTblValue("groupText", conditionData)) {
      conditionData.descText.append(getTblValue("descText", data)[0])
      return
    }

  groupsList[condType].append(data)
}

let function addCustomConditionsTextData(groupsList, condition) {
  local values = condition.values
  if (values == null)
    return

  if (type(values) != "array")
    values = [values]

  let condType = condition.type
  let desc = []
  local group = ""

  foreach (v in values) {
    if (condType == "gameModeInfoString") {
      group = condition?.locParamName
        ? loc(condition.locParamName)
        : loc($"conditions/gameModeInfoString/{condition.name}")

      let locValuePrefix = condition?.locValuePrefix ?? "conditions/gameModeInfoString/"
      desc.append(loc($"{locValuePrefix}{v}"))
    }
    else if (condType == "missionPostfix") {
      group = loc($"conditions/{condition.locGroup}")

      let locValuePrefix = condition?.locValuePrefix ?? "options/"
      desc.append(loc($"{locValuePrefix}{v}"))
    }
  }

  addDataToCustomGroup(groupsList, condType, {
    groupText = group
    descText = [desc]
  })
}

let function getUnlockCondsDesc(conditions, isExpired = false) {
  let descByLocGroups = {}
  let customDataByLocGroups = {}
  foreach (condition in conditions)
    if (!isInArray(condition.type, customLocTypes)) {
      if (!addUniqConditionsText(descByLocGroups, condition))
        addUsualConditionsText(descByLocGroups, condition)
    }
    else
      addCustomConditionsTextData(customDataByLocGroups, condition)

  let condTextsList = []
  foreach (group in conditionsOrder) {
    if (!isInArray(group, customLocTypes)) {
      let data = getTblValue(group, descByLocGroups)
      if (data == null || data.len() == 0)
        continue

      addTextToCondTextList(condTextsList, group, data, { isExpired })
    }
    else {
      let customData = getTblValue(group, customDataByLocGroups)
      if (customData == null || customData.len() == 0)
        continue

      foreach (condCustomData in customData)
        foreach (descText in condCustomData.descText)
          addTextToCondTextList(condTextsList, group, descText, {
            customLocGroupText = condCustomData.groupText
            isExpired
          })
    }
  }

  return "\n".join(condTextsList, true)
}

let function getUnlockCondsDescByCfg(cfg) {
  if (!cfg?.conditions)
    return ""
  return getUnlockCondsDesc(cfg.conditions, cfg.isExpired)
}

let function getUnlockSnapshotText(unlockCfg) {
  let snapshot = getUnlockProgressSnapshot(unlockCfg.id)
  if (!snapshot)
    return ""

  let date = buildDateTimeStr(snapshot.timeSec)
  let delta = isBitModeType(unlockCfg.type)
    ? number_of_set_bits(unlockCfg.curVal) - number_of_set_bits(snapshot.progress)
    : unlockCfg.curVal - snapshot.progress
  return colorize("darkGreen", loc("unlock/progress_snapshot", { delta = max(delta, 0), date }))
}

let function getUnlockCostText(cfg) {
  if (!cfg)
    return ""

  let cost = getUnlockCost(cfg.id)
  if (cost > ::zero_money)
    return "".concat(
      loc("ugm/price"),
      loc("ui/colon"),
      colorize("unlockActiveColor", cost.getTextAccordingToBalance()))

  return ""
}

let singleAttachmentList = {
  unlockOpenCount = "unlock"
  unlockStageCount = "unlock"
}

let function isCheckedBySingleAttachment(modeType) {
  return modeType in singleAttachmentList || isBitModeType(modeType)
}

let function getSingleAttachmentConditionText(condition, curValue, maxValue) {
  let modeType = getTblValue("modeType", condition)
  let locNames = getLocForBitValues(modeType, condition.values)
  let valueText = colorize("unlockActiveColor", $"\"{loc("ui/comma").join(locNames, true)}\"")
  let progress = colorize("unlockActiveColor", curValue != null
    ? $"{curValue}/{maxValue}"
    : $"{maxValue}")
  return loc($"conditions/{modeType}/single", { value = valueText, progress })
}

// curValue - current value to show in the text (if null, do not show)
// maxValue - overrides progress value from mode if maxValue != null
// param locEnding - ending for main condition loc key
//   if such a loc is not found, usual locId is used
let function getUnlockMainCondDesc(condition, curValue = null, maxValue = null, params = null) {
  let modeType = condition?.modeType
  if (!modeType)
    return ""

  let typeLocIDWithoutValue = getTblValue("typeLocIDWithoutValue", condition)
  if (typeLocIDWithoutValue)
    return loc(typeLocIDWithoutValue)

  let bitMode = isBitModeType(modeType)
  let haveModeTypeLocID = "modeTypeLocID" in condition

  if (maxValue == null)
    maxValue = getTblValue("rewardNum", condition) || getTblValue("num", condition)

  if (is_numeric(curValue)) {
    if (bitMode)
      curValue = number_of_set_bits(curValue)
    else if (is_numeric(maxValue) && curValue > maxValue) // validate values if numeric
      curValue = maxValue
  }

  if (bitMode && is_numeric(maxValue))
    maxValue = number_of_set_bits(maxValue)

  if (isCheckedBySingleAttachment(modeType)
      && !haveModeTypeLocID
      && condition.values
      && condition.values.len() == 1
      && (!isStreak(condition.values[0]) || !!params?.showSingleStreakCondText))
    return getSingleAttachmentConditionText(condition, curValue, maxValue)

  local textId = $"conditions/{modeType}"
  let textParams = {}

  local progressText = ""
  let showValueForBitList = params?.showValueForBitList
  if (bitMode && (params?.bitListInValue || showValueForBitList)) {
    if (curValue == null || params?.showValueForBitList)
      progressText = ", ".join(getLocForBitValues(modeType, condition.values), true)

    if (is_numeric(maxValue) && maxValue != condition.values.len()) {
      textId = $"{textId}/withValue"
      textParams.value <- colorize("unlockActiveColor", maxValue)
    }
  }
  else if (modeType == "maxUnitsRankOnStartMission") {
    let valuesText = condition.values?.map(get_roman_numeral) ?? []
    progressText = "-".join(valuesText, true)
  }
  else if (modeType == "amountDamagesZone") {
    if (is_numeric(curValue) && is_numeric(maxValue)) {
      let a = round_by_value(curValue * 0.001, 0.001)
      let b = round_by_value(maxValue * 0.001, 0.001)
      progressText = $"{a}/{b}"
    }
  }
  else // usual progress text
    progressText = "/".join([curValue, maxValue], true)

  if (params?.isProgressTextOnly)
    return progressText

  if (haveModeTypeLocID)
    textId = condition.modeTypeLocID

  else if (modeType == "rank" || modeType == "char_country_rank") {
    let country = getTblValue("country", condition)
    textId = country ? $"mainmenu/rank/{country}" : "mainmenu/rank"
  }
  else if (modeType == "unlockCount")
    textId = $"conditions/{getTblValue("unlockType", condition, "")}"
  else if (modeType == "char_static_progress")
    textParams.level <- loc($"crew/qualification/{getTblValue("level", condition, 0)}")
  else if (modeType == "landings" && getTblValue("carrierOnly", condition))
    textId = "conditions/carrierOnly"
  else if (getTblValue("isShip", condition)) // really strange exclude, because this flag is used with various modeTypes
    textId = "conditions/isShip"
  else if (modeType == "killedAirScore")
    textId = "conditions/statKillsAir"
  else if (modeType == "sessionsStarted")
    textId = "conditions/missionsPlayed"
  else if (modeType == "char_resources_count")
    textId = $"conditions/char_resources_count/{getTblValue("resourceType", condition, "")}"
  else if (modeType == "amountDamagesZone")
    textId = "debriefing/Damage"
  else if (modeType == "totalMissionScore")
    textId = "conditions/statScore"

  local res = ""

  if ("locEnding" in params)
    res = loc($"{textId}{params.locEnding}", textParams)

  if (res == "")
    res = loc(textId, textParams)

  if ("reason" in condition) {
    let reason = loc($"{textId}/{condition.reason}")
    res = $"{res} {reason}"
  }

  // if condition lang is empty and max value == 1 no need to show progress text
  if (progressText != "" && (res != "" || maxValue != 1))
    res = $"{res}{loc("ui/colon")}{colorize("unlockActiveColor", progressText)}"

  return res
}

let function getUnlockMainCondDescByCfg(cfg, params = null) {
  if (!cfg?.conditions)
    return ""

  let mainCond = getMainProgressCondition(cfg.conditions)
  if (!mainCond)
    return ""

  let hideCurVal = isUnlockComplete(cfg) && !cfg.useLastStageAsUnlockOpening
  let curVal = params?.curVal ?? (hideCurVal ? null : cfg.curVal)
  return getUnlockMainCondDesc(mainCond, curVal, cfg.maxVal, params)
}

let function getUnlockMultDesc(condition) {
  let multiplierTable = condition?.multiplier ?? {}
  let rankMultiplierTable = condition?.rankMultiplier ?? {}
  if (multiplierTable.len() == 0 && rankMultiplierTable.len() == 0)
    return ""

  local mulText = ""

  if ((multiplierTable?.WWBattleForOwnClan ?? 1) > 1)
    return "{0}{1}{2}".subst(
      loc("conditions/mulWWBattleForOwnClan"),
      loc("ui/colon"),
      colorize("unlockActiveColor", format("x%d", multiplierTable.WWBattleForOwnClan)))

  let isMultipliersByDiff = multiplierTable?.ArcadeBattle != null
  foreach (param, num in multiplierTable) {
    if (num == 1 && isMultipliersByDiff)
      continue

    if (mulText.len() > 0)
      mulText = $"{mulText}, "

    let mulLocParam = isMultipliersByDiff
      ? loc($"clan/short{param}")
      : loc($"missions/{getDiffNameByInt(param)}_short")
    mulText = $"{mulText}{mulLocParam}{nbsp}(x{num})"
  }

  let mulRanks = []
  if (rankMultiplierTable.len() > 0) {
    local lastAddedRank = 0
    for (local rank = 1; rank <= ::max_country_rank; rank++) {
      let curRankMul = rankMultiplierTable[rank]
      let nextRankMul = rankMultiplierTable?[rank + 1]
      if (!curRankMul || (nextRankMul && curRankMul == nextRankMul))
        continue

      let rankText = (rank - 1 == lastAddedRank)
        ? get_roman_numeral(rank)
        : getRangeString(get_roman_numeral(lastAddedRank + 1), get_roman_numeral(rank))

      mulRanks.append($"{rankText}{nbsp}(x{curRankMul})")
      lastAddedRank = rank
    }
  }
  local mulRankText = ", ".join(mulRanks)

  mulText = mulText.len() > 0
    ? "{0}{1}{2}".subst(loc("conditions/multiplier"), loc("ui/colon"), mulText)
    : ""
  if (mulText.len() > 0 && mulRankText.len() > 0)
    mulText = $"{mulText}\n"

  mulRankText = mulRankText.len() > 0
    ? "{0}{1}{2}".subst(loc("conditions/rankMultiplier"), loc("ui/colon"), mulRankText)
    : ""
  return colorize("fadedTextColor", "{0}{1}".subst(mulText, mulRankText))
}

let function getUnlockMultDescByCfg(cfg) {
  if (!cfg?.conditions)
    return ""

  if (cfg.locMultDescId != "")
    return loc(cfg.locMultDescId, {
      mulArcade = cfg.mulArcade
      mulRealistic = cfg.mulRealistic
      mulHardcore = cfg.mulHardcore
    })

  let mainCond = getMainProgressCondition(cfg.conditions)
  return getUnlockMultDesc(mainCond)
}

let function getFullUnlockDesc(cfg, params = {}) {
  return "\n".join([
    getUnlockDesc(cfg),
    getUnlockMainCondDescByCfg(cfg, params),
    getUnlockCondsDescByCfg(cfg),
    getUnlockMultDescByCfg(cfg)], true)
}

let function getFullUnlockDescByName(unlockName, forUnlockedStage = -1, params = {}) {
  let unlock = getUnlockById(unlockName)
  if (!unlock)
    return ""

  let config = ::build_conditions_config(unlock, forUnlockedStage)
  return getFullUnlockDesc(config, params)
}

let function getFullUnlockCondsDesc(conds, curVal = null, maxVal = null, params = null) {
  if (!conds)
    return ""

  let mainCond = getMainProgressCondition(conds)
  return "\n".join([
    getUnlockMainCondDesc(mainCond, curVal, maxVal, params),
    getUnlockCondsDesc(conds),
    getUnlockMultDesc(mainCond)
  ], true)
}

let function getFullUnlockCondsDescInline(conds) {
  if (!conds)
    return ""

  let mainCond = getMainProgressCondition(conds)
  let mainCondText = getUnlockMainCondDesc(mainCond)
  let condsText = getUnlockCondsDesc(conds)
  return ", ".join([
    mainCondText,
    (condsText != "" ? $"({condsText})" : ""),
    getUnlockMultDesc(mainCond)
  ], true)
}

let function getUnitRequireUnlockText(unit) {
  let desc = getFullUnlockDescByName(unit.reqUnlock, -1, { showValueForBitList = true })
  return "\n".concat(loc("mainmenu/needUnlock"), desc)
}

let function getUnitRequireUnlockShortText(unit) {
  let unlockBlk = getUnlockById(unit.reqUnlock)
  let cfg = ::build_conditions_config(unlockBlk)
  let mainCond = getMainProgressCondition(cfg.conditions)
  return getUnlockMainCondDesc(
    mainCond, cfg.curVal, cfg.maxVal, { isProgressTextOnly = true })
}

function buildUnlockDesc(item) {
  let mainCond = getMainProgressCondition(item.conditions)
  let progressText = getUnlockMainCondDesc(mainCond, item.curVal, item.maxVal)
  item.showProgress <- progressText != ""
  return item
}

function fillUnlockManualOpenButton(cfg, obj) {
  let btnObj = obj.findObject("manual_open_button")
  if (!btnObj?.isValid())
    return

  let needShow = cfg.manualOpen && canClaimUnlockReward(cfg.id)
  btnObj.unlockId = cfg.id
  btnObj.show(needShow)
}

function getRewardText(unlockConfig, stageNum) {
  if (("stages" in unlockConfig) && (stageNum in unlockConfig.stages))
    unlockConfig = unlockConfig.stages[stageNum]

  let reward = getTblValue("reward", unlockConfig, null)
  let text = reward ? reward.tostring() : ""
  if (text != "")
    return $"{loc("challenge/reward")} <color=@activeTextColor>{text}</color>"
  return ""
}

function updateUnseenIcon(cfg, obj) {
  let unseenCfg = cfg.manualOpen && canClaimUnlockReward(cfg.id)
    ? makeConfigStr(SEEN.MANUAL_UNLOCKS, cfg.id)
    : ""
  obj.findObject("unseen_icon").setValue(unseenCfg)
}

function getUnlockTypeFromConfig(unlockConfig) {
  return unlockConfig?.unlockType ?? unlockConfig?.type ?? -1
}

function updateProgress(unlockCfg, unlockObj) {
  let progressData = unlockCfg.getProgressBarData()
  let hasProgress = progressData.show && !isUnlockOpened(unlockCfg.id)

  let snapshot = getUnlockProgressSnapshot(unlockCfg.id)
  let hasSnapshot = (snapshot != null) && hasProgress
  let snapshotObj = unlockObj.findObject("progress_snapshot")
  snapshotObj.show(hasSnapshot)
  if (hasSnapshot) {
    let storedProgress = getProgressBarData(unlockCfg.type, snapshot.progress, unlockCfg.maxVal).value
    snapshotObj.setValue(min(storedProgress, progressData.value))
  }

  let progressObj = unlockObj.findObject("progress_bar")
  progressObj.show(hasProgress)
  if (hasProgress) {
    progressObj.hasSnapshot = hasSnapshot ? "yes" : "no"
    progressObj.setValue(progressData.value)
  }

  unlockObj.findObject("snapshotBtn").show(hasProgress)
}

function needShowLockIcon(cfg) {
  if (cfg.lockStyle == "none")
    return false

  if (cfg?.isTrophyLocked)
    return true

  let unlockType = getUnlockTypeFromConfig(cfg)
  let isUnlocked = isUnlockOpened(cfg.id, unlockType)
  if (isUnlocked)
    return false

  return cfg.lockStyle == "lock"
    || unlockType == UNLOCKABLE_DECAL
    || unlockType == UNLOCKABLE_PILOT
}

function updateLockStatus(cfg, obj) {
  let needLockIcon = needShowLockIcon(cfg)
  let lockObj = obj.findObject("lock_icon")
  lockObj.show(needLockIcon)
}

function getUnlockImageConfig(unlockConfig) {
  let unlockType = getUnlockTypeFromConfig(unlockConfig)
  let isUnlocked = isUnlockOpened(unlockConfig.id, unlockType)
  local iconStyle = unlockConfig?.iconStyle ?? ""
  let image = unlockConfig?.image ?? ""

  if (iconStyle == "" && image == "")
    iconStyle = "".concat(
      (isUnlocked ? "default_unlocked" : "default_locked"),
      (isUnlocked || unlockConfig.curStage < 1) ? "" : $"_stage_{unlockConfig.curStage}")

  let effect = isUnlocked || unlockConfig.lockStyle == "none" || needShowLockIcon(unlockConfig) ? ""
    : unlockConfig.lockStyle != "" ? unlockConfig.lockStyle
    : unlockType == UNLOCKABLE_MEDAL ? "darkened"
    : "desaturated"

  return {
    style = iconStyle
    image = unlockType == UNLOCKABLE_PILOT ? (unlockConfig?.descrImage ?? image) : image
    ratio = unlockConfig?.imgRatio ?? 1.0
    params = unlockConfig?.iconParams
    effect
  }
}

function fillUnlockImage(unlockConfig, unlockObj) {
  let iconObj = unlockObj.findObject("achivment_ico")
  let imgConfig = getUnlockImageConfig(unlockConfig)
  iconObj.effectType = imgConfig.effect

  if (unlockConfig?.iconData) {
    LayersIcon.replaceIconByIconData(iconObj, unlockConfig.iconData)
    return
  }

  LayersIcon.replaceIcon(
    iconObj,
    imgConfig.style,
    imgConfig.image,
    imgConfig.ratio,
    null /*defStyle*/ ,
    imgConfig.params
  )
}

function fillUnlockProgressBar(unlockConfig, unlockObj) {
  let obj = unlockObj.findObject("progress_bar")
  let data = unlockConfig.getProgressBarData()
  obj.show(data.show)
  if (data.show)
    obj.setValue(data.value)
}

function fillUnlockDescription(unlockConfig, unlockObj) {
  unlockObj.findObject("description").setValue(getUnlockDesc(unlockConfig))
  unlockObj.findObject("main_cond").setValue(getUnlockMainCondDescByCfg(unlockConfig))
  unlockObj.findObject("mult_desc").setValue(getUnlockMultDescByCfg(unlockConfig))
  unlockObj.findObject("conditions").setValue(getUnlockCondsDescByCfg(unlockConfig))

  let showUnitsBtnObj = unlockObj.findObject("show_units_btn")
  showUnitsBtnObj.show(hasActiveUnlock(unlockConfig.id, getShopDiffCode())
    && getUnitListByUnlockId(unlockConfig.id).len() > 0)
  showUnitsBtnObj.unlockId = unlockConfig.id

  let showPrizesBtnObj = unlockObj.findObject("show_prizes_btn")
  showPrizesBtnObj.show(unlockConfig?.trophyId != null)
  showPrizesBtnObj.trophyId = unlockConfig?.trophyId

  let previewPrizeBtnObj = unlockObj.findObject("preview_prize_btn")
  previewPrizeBtnObj.show(canPreviewUnlockPrize(unlockConfig))
  previewPrizeBtnObj.unlockId = unlockConfig.id
}

function fillReward(unlockConfig, unlockObj) {
  let rewardObj = unlockObj.findObject("reward")
  if (!checkObj(rewardObj))
    return

  let { rewardText, tooltipId } = ::g_unlock_view.getRewardConfig(unlockConfig)

  let tooltipObj = rewardObj.findObject("tooltip")
  if (checkObj(tooltipObj))
    tooltipObj.tooltipId = tooltipId

  rewardObj.show(rewardText != "")
  rewardObj.setValue(rewardText)
}

function fillUnlockTitle(unlockConfig, unlockObj) {
  let title = getUnlockTitle(unlockConfig)
  unlockObj.findObject("achivment_title").setValue(title)
}

function fillUnlockPurchaseButton(unlockData, unlockObj) {
  let purchButtonObj = unlockObj.findObject("purchase_button")
  if (!checkObj(purchButtonObj))
    return

  let unlockId = unlockData.id
  purchButtonObj.unlockId = unlockId
  let isUnlocked = isUnlockOpened(unlockId)
  let haveStages = getTblValue("stages", unlockData, []).len() > 1
  let cost = getUnlockCost(unlockId)
  let canSpendGold = cost.gold == 0 || hasFeature("SpendGold")
  let isPurchaseTime = isUnlockVisibleByTime(unlockId, false)
  let canOpenManually = unlockData.manualOpen && canClaimUnlockReward(unlockId)

  let show = isPurchaseTime && canSpendGold && !haveStages && !isUnlocked
    && !canOpenManually && !cost.isZero()

  purchButtonObj.show(show)
  if (show)
    placePriceTextToButton(unlockObj, "purchase_button", loc("mainmenu/btnBuy"), cost)

  if (!show && !cost.isZero()) {
    let cantPurchase = $"UnlocksPurchase: can't purchase {unlockId}:"
    if (canOpenManually)
      log($"{cantPurchase} can open manually")
    else if (!canSpendGold)
      log($"{cantPurchase} can't spend gold")
    else if (haveStages)
      log($"{cantPurchase} has stages = {unlockData.stages.len()}")
    else if (isUnlocked)
      log($"{cantPurchase} already unlocked")
    else if (!isPurchaseTime) {
      debugLogVisibleByTimeInfo(unlockId)
      log($"{cantPurchase} not purchase time. see time before.")
    }
  }
}

return {
  getUnlockRewardsText
  getUnlockTypeText
  getUnlockLocName
  getUnlockTitle
  getUnlockChapterAndGroupText
  getSubUnlockLocName
  getUnlockNameText
  getLocForBitValues
  getFullUnlockDesc
  getFullUnlockDescByName
  getFullUnlockCondsDesc
  getFullUnlockCondsDescInline
  getUnlockDesc
  getUnlockMainCondDesc
  getUnlockMainCondDescByCfg
  getUnlockCondsDesc
  getUnlockCondsDescByCfg
  getUnlockMultDesc
  getUnlockMultDescByCfg
  getUnlockSnapshotText
  getUnlockCostText
  getUnitRequireUnlockText
  getUnitRequireUnlockShortText
  buildUnlockDesc
  fillUnlockManualOpenButton
  getRewardText
  updateUnseenIcon
  getUnlockTypeFromConfig
  updateProgress
  needShowLockIcon
  updateLockStatus
  getUnlockImageConfig
  fillUnlockImage
  fillUnlockProgressBar
  doPreviewUnlockPrize
  fillUnlockDescription
  fillReward
  fillUnlockTitle
  fillUnlockPurchaseButton
}