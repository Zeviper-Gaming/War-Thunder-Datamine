let { addOptionMode, addUserOption, setGuiOptionsMode, getGuiOptionsMode
} = ::require_native("guiOptions")

global enum optionControlType {
  LIST
  BIT_LIST
  SLIDER
  CHECKBOX
  EDITBOX
  HEADER
  BUTTON
}

global enum AIR_MOUSE_USAGE {
  NOT_USED    = 0x0001
  AIM         = 0x0002
  JOYSTICK    = 0x0004
  RELATIVE    = 0x0008
  VIEW        = 0x0010
}

local options_mode_names = [
    "OPTIONS_MODE_GAMEPLAY",
    "OPTIONS_MODE_TRAINING",
    "OPTIONS_MODE_CAMPAIGN",
    "OPTIONS_MODE_SINGLE_MISSION",
    "OPTIONS_MODE_DYNAMIC",
    "OPTIONS_MODE_USER_MISSION",
    "OPTIONS_MODE_MP_DOMINATION",
    "OPTIONS_MODE_MP_SKIRMISH",
    "OPTIONS_MODE_SEARCH",
]

local user_option_names = [
    "USEROPT_LANGUAGE",
    "USEROPT_VIEWTYPE",
    "USEROPT_INGAME_VIEWTYPE",
    ///_INSERT_OPTIONS_HERE_
    "USEROPT_SPEECH_TYPE",
    "USEROPT_USE_TRACKIR_ZOOM",
    "USEROPT_INDICATED_SPEED_TYPE",
    "USEROPT_INVERTY",
    "USEROPT_INVERTY_TANK",
    "USEROPT_INVERTY_SHIP",
    "USEROPT_INVERTY_HELICOPTER",
    "USEROPT_INVERTY_HELICOPTER_GUNNER",
    //



    "USEROPT_INVERTY_SUBMARINE",
    "USEROPT_INVERTX",
    "USEROPT_GAMEPAD_ENGINE_DEADZONE",
    "USEROPT_GAMEPAD_VIBRATION_ENGINE",
    "USEROPT_GAMEPAD_GYRO_TILT_CORRECTION",
    "USEROPT_JOY_MIN_VIBRATION",
    "USEROPT_FIX_GUN_IN_MOUSE_LOOK",
    "USEROPT_INVERTY_SPECTATOR",
    "USEROPT_JOYFX",
    "USEROPT_INVERTCAMERAY",
    "USEROPT_AUTOMATIC_TRANSMISSION_TANK",
    "USEROPT_WHEEL_CONTROL_SHIP",
    "USEROPT_SEPERATED_ENGINE_CONTROL_SHIP",
    "USEROPT_BULLET_FALL_INDICATOR_SHIP",
    "USEROPT_BULLET_FALL_SOUND_SHIP",
    "USEROPT_SINGLE_SHOT_BY_TURRET",
    "USEROPT_SHIP_COMBINE_PRI_SEC_TRIGGERS",
    "USEROPT_AUTO_TARGET_CHANGE_SHIP",
    "USEROPT_REALISTIC_AIMING_SHIP",
    "USEROPT_FOLLOW_BULLET_CAMERA",
    "USEROPT_ZOOM_FOR_TURRET",
    "USEROPT_SUBTITLES",
    "USEROPT_SUBTITLES_RADIO",
    "USEROPT_VOICE_MESSAGE_VOICE",
    "USEROPT_MEASUREUNITS_SPEED",
    "USEROPT_MEASUREUNITS_ALT",
    "USEROPT_MEASUREUNITS_DIST",
    "USEROPT_MEASUREUNITS_CLIMBSPEED",
    "USEROPT_MEASUREUNITS_TEMPERATURE",
    "USEROPT_MEASUREUNITS_WING_LOADING",
    "USEROPT_MEASUREUNITS_POWER_TO_WEIGHT_RATIO",
    "USEROPT_AUTOSAVE_REPLAYS",
    "USEROPT_HIDE_MOUSE_SPECTATOR",
    "USEROPT_XRAY_DEATH",
    "USEROPT_XRAY_KILL",
    "USEROPT_CAMERA_SHAKE_MULTIPLIER",
    "USEROPT_VR_CAMERA_SHAKE_MULTIPLIER",
    "USEROPT_VIBRATION",
    "USEROPT_SOUND_ENABLE",
    "USEROPT_SOUND_SPEAKERS_MODE",
    "USEROPT_VOLUME_MASTER",
    "USEROPT_VOLUME_MUSIC",
    "USEROPT_VOLUME_MENU_MUSIC",
    "USEROPT_VOLUME_SFX",
    "USEROPT_VOLUME_GUNS",
    "USEROPT_VOLUME_TINNITUS",
    "USEROPT_HANGAR_SOUND",
    "USEROPT_VOLUME_RADIO",
    "USEROPT_VOLUME_DIALOGS",
    "USEROPT_VOLUME_ENGINE",
    "USEROPT_VOLUME_MY_ENGINE",
    "USEROPT_VOLUME_VOICE_IN",
    "USEROPT_VOLUME_VOICE_OUT",
    "USEROPT_AAA_TYPE",
    "USEROPT_SITUATION",
    "USEROPT_CLIME",
    "USEROPT_TIME",
    "USEROPT_ALTITUDE",
    "USEROPT_AIRCRAFT",
    "USEROPT_WEAPONS",
    "USEROPT_BULLETS0",
    "USEROPT_BULLETS1",
    "USEROPT_BULLETS2",
    "USEROPT_BULLETS3",
    "USEROPT_BULLETS4",
    "USEROPT_BULLETS5",
    "USEROPT_BULLET_COUNT0",
    "USEROPT_BULLET_COUNT1",
    "USEROPT_BULLET_COUNT2",
    "USEROPT_BULLET_COUNT3",
    "USEROPT_BULLET_COUNT4",
    "USEROPT_BULLET_COUNT5",
    "USEROPT_SKIN",
    "USEROPT_USER_SKIN",
    "USEROPT_TANK_SKIN_CONDITION",
    "USEROPT_TANK_CAMO_SCALE",
    "USEROPT_TANK_CAMO_ROTATION",
    "USEROPT_DIFFICULTY",
    "USEROPT_NUM_FRIENDLIES",
    "USEROPT_NUM_ENEMIES",
    "USEROPT_TIME_LIMIT",
    "USEROPT_KILL_LIMIT",
    "USEROPT_NUM_PLAYERS",
    "USEROPT_YEAR",
    "USEROPT_TIME_SPAWN",
    "USEROPT_MP_MAP_UNUSED", //!!can be removed from list only with minor / major
    "USEROPT_DMP_MAP",
    "USEROPT_DYN_MAP",
    "USEROPT_DYN_ZONE",
    "USEROPT_DYN_ALLIES",
    "USEROPT_DYN_ENEMIES",
    "USEROPT_DYN_SURROUND",
    "USEROPT_DYN_FL_ADVANTAGE",
    "USEROPT_DYN_WINS_TO_COMPLETE",
    "USEROPT_NUM_ATTEMPTS",
    "USEROPT_LIMITED_FUEL",
    "USEROPT_LIMITED_AMMO",
    "USEROPT_FRIENDLY_SKILL",
    "USEROPT_ENEMY_SKILL",
    "USEROPT_MODIFICATIONS",
    "USEROPT_MP_TEAM",
    "USEROPT_MP_TEAM_COUNTRY",
    "USEROPT_MP_TEAM_COUNTRY_RAND",
    "USEROPT_TICKETS",
    "USEROPT_GAME_HUD",
    "USEROPT_FONTS_CSS",
    "USEROPT_ENABLE_CONSOLE_MODE",
    "USEROPT_SEARCH_GAMEMODE",
    "USEROPT_SEARCH_GAMEMODE_CUSTOM",
    "USEROPT_SEARCH_DIFFICULTY",
    "USEROPT_CONTROLS_PRESET",
    "USEROPT_AILERONS_MULTIPLIER",
    "USEROPT_ELEVATOR_MULTIPLIER",
    "USEROPT_RUDDER_MULTIPLIER",
    "USEROPT_GAMMA",
    "USEROPT_TIME_BETWEEN_RESPAWNS",
    "USEROPT_OPTIONAL_TAKEOFF",
    "USEROPT_LOAD_FUEL_AMOUNT",
    "USEROPT_GUN_TARGET_DISTANCE",
    "USEROPT_BOMB_ACTIVATION_TIME",
    "USEROPT_BOMB_SERIES",
    "USEROPT_DEPTHCHARGE_ACTIVATION_TIME",
    "USEROPT_COUNTERMEASURES_SERIES",
    "USEROPT_COUNTERMEASURES_SERIES_PERIODS",
    "USEROPT_COUNTERMEASURES_PERIODS",
    "USEROPT_USE_PERFECT_RANGEFINDER",
    "USEROPT_ROCKET_FUSE_DIST",
    "USEROPT_FRIENDS_ONLY",
    "USEROPT_ALLOW_JIP",
    "USEROPT_QUEUE_JIP",
    "USEROPT_AUTO_SQUAD",
    "USEROPT_ORDER_AUTO_ACTIVATE",
    "USEROPT_FORCE_GAIN",
    "USEROPT_COOP_MODE",
    "USEROPT_SEARCH_PLAYERMODE",
    "USEROPT_GUNNER_INVERTY",
    "USEROPT_XCHG_STICKS",
    "USEROPT_ZOOM_SENSE",
    "USEROPT_GUNNER_VIEW_SENSE",
    "USEROPT_GUNNER_VIEW_ZOOM_SENS",
    "USEROPT_MOUSE_SENSE",
    "USEROPT_MOUSE_AIM_SENSE",
    "USEROPT_MOUSE_SMOOTH",
    "USEROPT_LB_MODE",
    "USEROPT_LB_TYPE",
    "USEROPT_HUD_COLOR",
    "USEROPT_HUD_INDICATORS",
    "USEROPT_AI_GUNNER_TIME",
    "USEROPT_OFFLINE_MISSION",
    "USEROPT_VERSUS_NO_RESPAWN",
    "USEROPT_VERSUS_RESPAWN",
    "USEROPT_INVERT_THROTTLE",
    "USEROPT_COUNTRY",
    "USEROPT_RANDB_CLUSTER",
    "USEROPT_CLUSTER",
    "USEROPT_PLAY_INACTIVE_WINDOW_SOUND",
    "USEROPT_PILOT",
    "USEROPT_IS_BOTS_ALLOWED",
    "USEROPT_USE_TANK_BOTS",
    "USEROPT_USE_SHIP_BOTS",
    "USEROPT_KEEP_DEAD",
    "USEROPT_AUTOBALANCE",
    "USEROPT_MIN_PLAYERS",
    "USEROPT_MAX_PLAYERS",
    "USEROPT_DEDICATED_REPLAY",
    "USEROPT_SESSION_PASSWORD",
    "USEROPT_TAKEOFF_MODE",
    "USEROPT_LANDING_MODE",
    "USEROPT_ROUNDS",
    "USEROPT_DISABLE_AIRFIELDS",
    "USEROPT_ALLOW_EMPTY_TEAMS",
    "USEROPT_SPAWN_AI_TANK_ON_TANK_MAPS",
    "USEROPT_GUN_VERTICAL_TARGETING",
    "USEROPT_AEROBATICS_SMOKE_TYPE",
    "USEROPT_AEROBATICS_SMOKE_LEFT_COLOR",
    "USEROPT_AEROBATICS_SMOKE_RIGHT_COLOR",
    "USEROPT_AEROBATICS_SMOKE_TAIL_COLOR",
    "USEROPT_SHOW_PILOT",
    "USEROPT_AUTO_SHOW_CHAT",
    "USEROPT_CHAT_MESSAGES_FILTER",
    "USEROPT_CHAT_FILTER",
    "USEROPT_DAMAGE_INDICATOR_SIZE",
    "USEROPT_TACTICAL_MAP_SIZE",
    "USEROPT_CROSSHAIR_DEFLECTION",
    "USEROPT_CROSSHAIR_SPEED",
    "USEROPT_SHOW_INDICATORS",
    "USEROPT_HUD_SCREENSHOT_LOGO",
    "USEROPT_SAVE_ZOOM_CAMERA",
    "USEROPT_HUD_SHOW_BONUSES",
    "USEROPT_HUD_SHOW_FUEL",
    "USEROPT_HUD_SHOW_AMMO",
    "USEROPT_HUD_SHOW_TEMPERATURE",
    "USEROPT_MENU_SCREEN_SAFE_AREA",
    "USEROPT_HUD_SCREEN_SAFE_AREA",
    "USEROPT_SHOW_INDICATORS_TYPE",
    "USEROPT_SHOW_INDICATORS_NICK",
    "USEROPT_SHOW_INDICATORS_TITLE",
    "USEROPT_SHOW_INDICATORS_AIRCRAFT",
    "USEROPT_SHOW_INDICATORS_DIST",
    "USEROPT_MISSION_COUNTRIES_TYPE",
    "USEROPT_BIT_COUNTRIES_TEAM_A",
    "USEROPT_BIT_COUNTRIES_TEAM_B",
    "USEROPT_COUNTRIES_SET",
    "USEROPT_BIT_UNIT_TYPES",
    "USEROPT_BR_MIN",
    "USEROPT_BR_MAX",
    "USEROPT_REPLAY_ALL_INDICATORS",
    "USEROPT_REPLAY_LOAD_COCKPIT",
    "USEROPT_USE_KILLSTREAKS",
    "USEROPT_BIT_CHOOSE_UNITS_TYPE",
    "USEROPT_BIT_CHOOSE_UNITS_RANK",
    "USEROPT_BIT_CHOOSE_UNITS_OTHER",
    "USEROPT_BIT_CHOOSE_UNITS_SHOW_UNSUPPORTED_FOR_GAME_MODE",
    "USEROPT_BIT_CHOOSE_UNITS_SHOW_UNSUPPORTED_FOR_CUSTOM_LIST",
    "USEROPT_COMPLAINT_CATEGORY",
    "USEROPT_BAN_PENALTY",
    "USEROPT_BAN_TIME",
    "USEROPT_USERLOG_FILTER",
    "USEROPT_AUTOLOGIN",
    "USEROPT_PRELOADER_SETTINGS",
    "USEROPT_REVEAL_NOTIFICATIONS",
    "USEROPT_HDR_SETTINGS",
    "USEROPT_POSTFX_SETTINGS",
    "USEROPT_ONLY_FRIENDLIST_CONTACT",
    "USEROPT_MARK_DIRECT_MESSAGES_AS_PERSONAL",
    "USEROPT_SKIP_WEAPON_WARNING",
    "USEROPT_SKIP_LEFT_BULLETS_WARNING",
    "USEROPT_AUTOPILOT_ON_BOMBVIEW",
    "USEROPT_AUTOREARM_ON_AIRFIELD",
    "USEROPT_ENABLE_LASER_DESIGNATOR_ON_LAUNCH",
    "USEROPT_AUTO_AIMLOCK_ON_SHOOT",
    "USEROPT_ACTIVATE_AIRBORNE_RADAR_ON_SPAWN",
    "USEROPT_USE_RECTANGULAR_RADAR_INDICATOR",
    "USEROPT_RADAR_TARGET_CYCLING",
    "USEROPT_RADAR_AIM_ELEVATION_CONTROL",
    "USEROPT_USE_RADAR_HUD_IN_COCKPIT",
    "USEROPT_ACTIVATE_AIRBORNE_ACTIVE_COUNTER_MEASURES_ON_SPAWN",
    "USEROPT_SAVE_AI_TARGET_TYPE",
    "USEROPT_DEFAULT_AI_TARGET_TYPE",
    "USEROPT_DEFAULT_TORPEDO_FORESTALL_ACTIVE",
    "USEROPT_ACTIVATE_AIRBORNE_WEAPON_SELECTION_ON_SPAWN",

    "USEROPT_PTT",
    "USEROPT_VOICE_CHAT",
    "USEROPT_VOICE_DEVICE_IN",
    "USEROPT_VOICE_DEVICE_OUT",
    "USEROPT_SOUND_DEVICE_OUT",
    "USEROPT_CROSSHAIR_TYPE",
    "USEROPT_CROSSHAIR_COLOR",

    "USEROPT_RACE_LAPS",
    "USEROPT_RACE_WINNERS",
    "USEROPT_RACE_CAN_SHOOT",

    "USEROPT_HELPERS_MODE",
    "USEROPT_MOUSE_USAGE",
    "USEROPT_MOUSE_USAGE_NO_AIM",
    "USEROPT_INSTRUCTOR_ENABLED",
    "USEROPT_AUTOTRIM",

    "USEROPT_INSTRUCTOR_GROUND_AVOIDANCE",
    "USEROPT_INSTRUCTOR_GEAR_CONTROL",
    "USEROPT_INSTRUCTOR_FLAPS_CONTROL",
    "USEROPT_INSTRUCTOR_ENGINE_CONTROL",
    "USEROPT_INSTRUCTOR_SIMPLE_JOY",

    "USEROPT_HELPERS_MODE_GM",
    "USEROPT_MAP_ZOOM_BY_LEVEL",
    "USEROPT_SHOW_COMPASS_IN_TANK_HUD",

    "USEROPT_TTV_USER_NAME",
    "USEROPT_TTV_PASSWORD",
    "USEROPT_TTV_USE_AUDIO",
    "USEROPT_TTV_VIDEO_SIZE",
    "USEROPT_TTV_VIDEO_BITRATE",

    "USEROPT_INTERNET_RADIO_ACTIVE",
    "USEROPT_INTERNET_RADIO_STATION",

    "USEROPT_CONTENT_ALLOWED_PRESET_ARCADE",
    "USEROPT_CONTENT_ALLOWED_PRESET_REALISTIC",
    "USEROPT_CONTENT_ALLOWED_PRESET_SIMULATOR",
    "USEROPT_CONTENT_ALLOWED_PRESET",

    "USEROPT_CD_ENGINE",
    "USEROPT_CD_GUNNERY",
    "USEROPT_CD_DAMAGE",
    "USEROPT_CD_STALLS",
    "USEROPT_CD_REDOUT",
    "USEROPT_CD_MORTALPILOT",
    "USEROPT_CD_FLUTTER",
    "USEROPT_CD_BOMBS",
    "USEROPT_CD_BOOST",
    "USEROPT_CD_TPS",
    "USEROPT_CD_AIM_PRED",
    "USEROPT_CD_MARKERS",
    "USEROPT_CD_ARROWS",
    "USEROPT_CD_AIRCRAFT_MARKERS_MAX_DIST",
    "USEROPT_CD_INDICATORS",
    "USEROPT_CD_SPEED_VECTOR",
    "USEROPT_CD_TANK_DISTANCE",
    "USEROPT_CD_MAP_AIRCRAFT_MARKERS",
    "USEROPT_CD_MAP_GROUND_MARKERS",
    "USEROPT_CD_RADAR",
    "USEROPT_CD_DAMAGE_IND",
    "USEROPT_CD_LARGE_AWARD_MESSAGES",
    "USEROPT_CD_WARNINGS",
    "USEROPT_CD_AIR_HELPERS",
    "USEROPT_CD_COLLECTIVE_DETECTION",
    "USEROPT_CD_MARKERS_BLINK",
    "USEROPT_CD_ALLOW_CONTROL_HELPERS",
    "USEROPT_CD_FORCE_INSTRUCTOR",
    "USEROPT_CD_DISTANCE_DETECTION",
    "USEROPT_GRASS_IN_TANK_VISION",
    "USEROPT_PITCH_BLOCKER_WHILE_BRACKING",
    "USEROPT_COMMANDER_CAMERA_IN_VIEWS",
    "USEROPT_SAVE_DIR_WHILE_SWITCH_TRIGGER",


    "USEROPT_HEADTRACK_ENABLE",
    "USEROPT_HEADTRACK_SCALE_X",
    "USEROPT_HEADTRACK_SCALE_Y",

    "USEROPT_HUE_ALLY",
    "USEROPT_HUE_ENEMY",
    "USEROPT_STROBE_ALLY",
    "USEROPT_STROBE_ENEMY",
    "USEROPT_HUE_SQUAD",
    "USEROPT_HUE_SPECTATOR_ALLY",
    "USEROPT_HUE_SPECTATOR_ENEMY",
    "USEROPT_HUE_RELOAD",
    "USEROPT_HUE_RELOAD_DONE",
    "USEROPT_AIR_DAMAGE_DISPLAY",
    "USEROPT_GUNNER_FPS_CAMERA",

    "USEROPT_HUE_HELICOPTER_PARAM_HUD",
    "USEROPT_HUE_HELICOPTER_CROSSHAIR",
    "USEROPT_HUE_HELICOPTER_HUD",
    "USEROPT_HUE_HELICOPTER_HUD_ALERT",
    "USEROPT_HUE_HELICOPTER_MFD",

    "USEROPT_HUE_AIRCRAFT_PARAM_HUD",
    "USEROPT_HUE_AIRCRAFT_HUD",
    "USEROPT_HUE_AIRCRAFT_HUD_ALERT",

    "USEROPT_HUE_ARBITER_HUD",

    "USEROPT_HUE_TANK_THERMOVISION",
    "USEROPT_HORIZONTAL_SPEED",
    "USEROPT_HELICOPTER_HELMET_AIM",
    "USEROPT_HELICOPTER_AUTOPILOT_ON_GUNNERVIEW",

    "USEROPT_MISSION_NAME_POSTFIX",
    "USEROPT_SHOW_DESTROYED_PARTS",
    "USEROPT_ACTIVATE_GROUND_RADAR_ON_SPAWN",
    "USEROPT_GROUND_RADAR_TARGET_CYCLING",
    "USEROPT_ACTIVATE_GROUND_ACTIVE_COUNTER_MEASURES_ON_SPAWN",
    "USEROPT_FPS_CAMERA_PHYSICS",
    "USEROPT_FPS_VR_CAMERA_PHYSICS",
    "USEROPT_FREE_CAMERA_INERTIA",
    "USEROPT_REPLAY_CAMERA_WIGGLE",

    "USEROPT_USE_CONTROLLER_LIGHT",

    "USEROPT_SHOW_DECORATORS",

    "USEROPT_CLAN_REQUIREMENTS_MIN_AIR_RANK",
    "USEROPT_CLAN_REQUIREMENTS_MIN_TANK_RANK",
    "USEROPT_CLAN_REQUIREMENTS_ALL_MIN_RANKS",
    "USEROPT_CLAN_REQUIREMENTS_MIN_ARCADE_BATTLES",
    "USEROPT_CLAN_REQUIREMENTS_MIN_SYM_BATTLES",
    "USEROPT_CLAN_REQUIREMENTS_MIN_REAL_BATTLES",
    "USEROPT_CLAN_REQUIREMENTS_AUTO_ACCEPT_MEMBERSHIP",

    "USEROPT_TANK_GUNNER_CAMERA_FROM_SIGHT",
    "USEROPT_TANK_ALT_CROSSHAIR",

    "USEROPT_GAMEPAD_CURSOR_CONTROLLER",

    "USEROPT_RANK",
    "USEROPT_QUEUE_EVENT_CUSTOM_MODE",

    "USEROPT_PS4_CROSSPLAY",
    "USEROPT_PS4_CROSSNETWORK_CHAT",
    "USEROPT_PS4_ONLY_LEADERBOARD",
    //



    "USEROPT_DISPLAY_MY_REAL_NICK",
    "USEROPT_SHOW_SOCIAL_NOTIFICATIONS",
    "USEROPT_ALLOW_ADDED_TO_CONTACTS",
    "USEROPT_ALLOW_ADDED_TO_LEADERBOARDS",

    "USEROPT_ENABLE_SOUND_SPEED",
    "USEROPT_SOUND_RESET_VOLUMES",
    "USEROPT_AIR_RADAR_SIZE",
    "USEROPT_ATGM_AIM_SENS_HELICOPTER",
    "USEROPT_ATGM_AIM_ZOOM_SENS_HELICOPTER",

    "USEROPT_TORPEDO_DIVE_DEPTH",
    "USEROPT_DELAYED_DOWNLOAD_CONTENT",
    "USEROPT_REPLAY_SNAPSHOT_ENABLED",
    "USEROPT_RECORD_SNAPSHOT_PERIOD",

    "USEROPT_BULLET_FALL_SPOT_SHIP",
    "USEROPT_HOLIDAYS",
    //



    "USEROPT_ALTERNATIVE_TPS_CAMERA",
]

::user_option_name_by_idx <- {}

foreach(idx, modeName in options_mode_names)
{
  let res = addOptionMode(modeName)
  let realIdx = (res != null) ? res : idx
  ::getroottable()[modeName] <- realIdx
}
options_mode_names = null // warning disable: -assigned-never-used

foreach(idx, useropt in user_option_names)
{
  let res = addUserOption(useropt)
  let realIdx = (res != null) ? res : idx
  ::getroottable()[useropt] <- realIdx
  ::user_option_name_by_idx[realIdx] <- useropt
}
user_option_names = null // warning disable: -assigned-never-used


::get_option_in_mode <- function get_option_in_mode(optionId, mode)
{
  let mainOptionsMode = getGuiOptionsMode()
  setGuiOptionsMode(mode)
  let res = ::get_option(optionId)
  setGuiOptionsMode(mainOptionsMode)
  return res
}

::get_gui_option_in_mode <- function get_gui_option_in_mode(optionId, mode, defaultValue = null)
{
  let mainOptionsMode = getGuiOptionsMode()
  setGuiOptionsMode(mode)
  let res = ::get_gui_option(optionId)
  if (mainOptionsMode >= 0)
    setGuiOptionsMode(mainOptionsMode)
  if (defaultValue != null && res == null)
    return defaultValue
  return res
}

::set_gui_option_in_mode <- function set_gui_option_in_mode(optionId, value, mode)
{
  let mainOptionsMode = getGuiOptionsMode()
  setGuiOptionsMode(mode)
  ::set_gui_option(optionId, value)
  setGuiOptionsMode(mainOptionsMode)
}
