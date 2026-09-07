local MOD_VERSION = "1.0.0"
local DEFAULT_LANGUAGE = "EN"
local CUSTOM_LOCATION_PATH = "o8sume/teleport/custom_location.json"

local character_manager = sdk.get_managed_singleton("app.CharacterManager")
local ferry_stone_flow_controller = sdk.get_managed_singleton("app.FerrystoneFlowController")

local locations = require("data/locations")
local seeker_stone_locations = require("data/seeker_stone_locations")
local golden_trove_beetle_locations = require("data/golden_trove_beetle_locations")

local load_seeker_stone_locations = true
local load_golden_trove_beetle_locations = true
local show_teleport_window = false

local DEFAULT_HOTKEYS = {
    ["Teleport Window Show Key"] = "T",
    ["Teleport Hotkey 1"] = "F1",
    ["Teleport Hotkey 2"] = "F2",
    ["Teleport Hotkey 3"] = "F3",
    ["Teleport Hotkey 4"] = "F4",
    ["Teleport Hotkey 5"] = "F5",
    ["Teleport Hotkey 6"] = "F6",
    ["Teleport Hotkey 7"] = "F7",
    ["Teleport Hotkey 8"] = "F8",
    ["Teleport Hotkey 9"] = "F9",
    ["Teleport Hotkey 10"] = "F10",
    ["Teleport Hotkey 11"] = "F11",
    ["Teleport Hotkey 12"] = "F12",
}

local config = {
    language = DEFAULT_LANGUAGE,
    load_seeker_stone_locations = load_seeker_stone_locations,
    load_golden_trove_beetle_locations = load_golden_trove_beetle_locations,
    hotkeys = DEFAULT_HOTKEYS,
    custom_location = {},
}

local function log_error(error_message)
    log.error("o8sume -> Teleport: " .. error_message)
end

local function log_info(info_message)
    log.info("o8sume -> Teleport: " .. info_message)
end

-- カスタムロケーションをJSONに保存
local function save_custom_location()
    local success, result = pcall(json.dump_file, CUSTOM_LOCATION_PATH, config.custom_location)
    if not success then
        log_error("Failed to save custom locations: " .. tostring(result))
        return
    end

    log_info("Custom locations saved successfully")
end

-- プレイヤーの現在位置を取得して返す
local function get_player_position()

    local character = character_manager:get_field("<ManualPlayer>k__BackingField")
    if not character then
        log_error("Failed to retrieve the currently controlled character")
        return
    end

    local game_object = character:get_GameObject()
    if not game_object then
        log_error("Failed to retrieve the character's game object")
        return
    end

    local transform = game_object:get_Transform()
    if not transform then
        log_error("Failed to retrieve the transform")
        return
    end

    local universal_position = transform:get_UniversalPosition()
    if not universal_position then
        log_error("Failed to retrieve world coordinates")
        return
    end

    local x = universal_position:get_field("x")
    if x == nil then
        log_error("Failed to retrieve the X coordinate from world position")
        return
    end

    local y = universal_position:get_field("y")
    if y == nil then
        log_error("Failed to retrieve the Y coordinate from world position")
        return
    end

    local z = universal_position:get_field("z")
    if z == nil then
        log_error("Failed to retrieve the Z coordinate from world position")
        return
    end

    return x, y, z
end

-- カスタムロケーションを保存
local function add_custom_location(location_name)

    if location_name == "" then
        log_error("No name has been set for the custom location.")
        return
    end

    if location_name == nil then
        log_error("No name has been set for the custom location.")
        return
    end

    local x, y, z = get_player_position()
    if x == nil or y == nil or z == nil then
        return
    end

    table.insert(config.custom_location, {
        name = location_name,
        position = {
            x = x,
            y = y,
            z = z
        }
    })

    save_custom_location()
end