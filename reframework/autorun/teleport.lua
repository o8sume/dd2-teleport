local MOD_VERSION = "1.0.0"
local DEFAULT_LANGUAGE = "EN"
local CUSTOM_LOCATION_PATH = "o8sume/teleport/custom_location.json"
local SHOW_DEBUG_LOG = true

local character_manager = sdk.get_managed_singleton("app.CharacterManager")
if not character_manager then
    return
end

local item_manager = sdk.find_type_definition("app.ItemManager")
if not item_manager then
    return
end

local delete_item = item_manager:get_method("deleteItem")
if not delete_item then
    return
end

local position_type = sdk.find_type_definition("via.Position")
if not position_type then
    return
end

local ferrystone_flow_controller = sdk.get_managed_singleton("app.FerrystoneFlowController")
if not ferrystone_flow_controller then
    return
end
---@cast ferrystone_flow_controller app.FerrystoneFlowController

local Hotkeys = require("Hotkeys/Hotkeys")

local locations = require("data/locations")
local seeker_stone_locations = require("data/seeker_stone_locations")
local golden_trove_beetle_locations = require("data/golden_trove_beetle_locations")

local teleport_position_offset = 0x30
local select_location_index = 1
local select_custom_location_index = 1
local select_extra_location_index = 1

local location_names = {}
local custom_location_names = {}
local extra_location_names = {}

local extra_location_positions = {}

local skip_ferrystone_consumption = false
local require_teleport_window = true
local load_seeker_stone_locations = true
local load_golden_trove_beetle_locations = true
local show_teleport_window = false
local window_init = false
local new_custom_location_name = ""

local teleport_hotkey = {
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
    hotkeys = teleport_hotkey,
    custom_location = {},
    require_teleport_window = require_teleport_window,
}

Hotkeys.setup_hotkeys(config.hotkeys, teleport_hotkey)

local function log_error(error_message)
    log.error("o8sume -> Teleport: " .. error_message)
end

local function log_info(info_message)
    log.info("o8sume -> Teleport: " .. info_message)
end

local function log_debug(debug_message)
    if SHOW_DEBUG_LOG then
        log.debug("o8sume -> Teleport: " .. debug_message)
    end
end

-- カスタムロケーションをJSONに保存
local function save_custom_location()

    log_debug("save_custom_location: start")
    local success, result = pcall(json.dump_file, CUSTOM_LOCATION_PATH, config.custom_location)
    if not success then
        log_error("Failed to save custom locations: " .. tostring(result))
        return
    end

    log_info("Custom locations saved successfully.")
end

-- プレイヤーの現在位置を取得して返す
local function get_player_position()

    log_debug("get_player_position: start")
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

    log_debug("add_custom_location: start")
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

    log_debug("location_name: " .. location_name)
    log_debug("location_position: x=" .. x .. ", y=" .. y .. ", z=" .. z)

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

-- カスタムロケーションファイルを読み込み、設定へ反映
local function load_custom_location_file()
    
    local file = io.open(CUSTOM_LOCATION_PATH, "r")
    if not file then
        log_info("Custom location file has not been created.")
        return
    end

    file:close()
    local success, result = pcall(json.load_file, CUSTOM_LOCATION_PATH)
    if not success then
        log_error("Failed to load custom location file: " .. tostring(result))
        return
    end

    if not result then
        log_error("The file was retrieved, but no valid data was found.")
        return
    end

    if type(result) ~= "table" then
        log_error("Something other than a table was loaded.")
        return
    end

    config.custom_location = result
    log_info("load_custom_location_file: successfully.")
end

local function update_location_names()
    
    log_debug("update_location_names: start")

    location_names = {}
    custom_location_names = {}

    for _, location in ipairs(locations) do
        table.insert(location_names, location.name)
    end

    for _, location in ipairs(config.custom_location) do
        table.insert(location_names, location.name)
        table.insert(custom_location_names, location.name)
    end

    log_debug("update_location_names: successfully.")
end

local function update_extra_location_names()

    log_debug("update_extra_location_names: start")
    
    extra_location_names = {}

    if load_seeker_stone_locations then
        for _, location in ipairs(seeker_stone_locations) do
            table.insert(extra_location_names, location.name)
        end
    end

    if load_golden_trove_beetle_locations then
        for _, location in ipairs(golden_trove_beetle_locations) do
            table.insert(extra_location_names, location.name)
        end
    end

    log_debug("update_extra_location_names: successfully.")
end

local function update_extra_location_positions()

    log_debug("update_extra_location_positions: start")

    extra_location_positions = {}

    if load_seeker_stone_locations then
        for _, location in ipairs(seeker_stone_locations) do
            table.insert(extra_location_positions, location.position)
        end
    end

    if load_golden_trove_beetle_locations then
        for _, location in ipairs(golden_trove_beetle_locations) do
            table.insert(extra_location_positions, location.position)
        end
    end

    log_debug("update_extra_location_positions: successfully.")
end

load_custom_location_file()
update_location_names()
update_extra_location_names()
update_extra_location_positions()

local function create_position(x, y, z)

    log_debug("create_position: start")
    local position = ValueType.new(position_type)

    position:set_field("x", x)
    position:set_field("y", y)
    position:set_field("z", z)

    return position
end

local function write_value(target, offset, value)

    log_debug("write_value: start")
    for i = 0, value.type:get_valuetype_size() -1 do
        target:write_byte(offset + i, value:read_byte(i))
    end
end

local function initialize_teleport_window()

    log_debug("initialize_teleport_window: start")
    local display_size = imgui.get_display_size()
    if not display_size then
        return
    end

    local window_width = 380
    local window_height = 420
    local center_x = display_size.x / 2
    local center_y = display_size.y / 2
    
    imgui.set_next_window_pos(Vector2f.new(center_x, center_y), 0, Vector2f.new(0.5, 0.5))
    imgui.set_next_window_size(Vector2f.new(window_width, window_height), 0)

    window_init = true
end

local function add_spacing(count)

    for _ = 1, count do
        imgui.spacing()
    end
end

local function add_group_spacing()
    
    add_spacing(2)

end

local function add_section_spacing()

    add_spacing(3)

end

local function teleport(position)

    log_debug("teleport: start")
    skip_ferrystone_consumption = true

    local via_position = create_position(position.x, position.y, position.z)

    write_value(ferrystone_flow_controller, teleport_position_offset, via_position)

    -- ポーンと一緒にテレポートを行う
    ferrystone_flow_controller:gatherTeleportCharactersAndLostDeadPawns()
    ferrystone_flow_controller:activateFlow()
end

sdk.hook(
    delete_item,
    function(args)
        if skip_ferrystone_consumption then
            local item_deleted = sdk.to_int64(args[3])
            local ferrystone_id = 80
            if item_deleted == ferrystone_id then
                skip_ferrystone_consumption = false
                return sdk.PreHookResult.SKIP_ORIGINAL
            end
        end
    end,
    function(retval)
        return retval
    end,
    false
)

-- 毎フレーム、Teleport Window切り替えを確認
re.on_frame(function()
    -- Teleport Window Show Keyが押されたら状態を反転(トグル処理)
    if Hotkeys.check_hotkey("Teleport Window Show Key", false) then
        show_teleport_window = not show_teleport_window
    end

    -- デフォルトではTeleport Window表示中のみTeleport Hotkeyを有効化する
    -- 設定で制限を無効化した場合はWindow非表示時もHotkeyを許可する
    if show_teleport_window or not config.require_teleport_window then
        local count = math.min(12, #locations)
        for i = 1, count do
            if Hotkeys.check_hotkey("Teleport Hotkey " .. tostring(i), false) then
                teleport(locations[i].position)
                show_teleport_window = false
                break
            end
        end
    end

    if show_teleport_window then
        -- Teleport windowを初期化
        if not window_init then
            initialize_teleport_window()
        end

        show_teleport_window = imgui.begin_window("Teleportation", true)
        imgui.indent(10)
        add_section_spacing()

        imgui.text("Pressing the hotkey will teleport you to the specified location.")
        add_section_spacing()

        local success = imgui.begin_table("1", 2, 1 << 7, Vector2f.new(325.0, 100.0), 10.0)
        if success then
            imgui.table_setup_column("Hotkey")
            imgui.table_setup_column("Location")
            imgui.table_headers_row()

            local count = math.min(12, #locations)
            for index = 1, count do
                local location = locations[index]
                local key = config.hotkeys["Teleport Hotkey " .. tostring(index)]

                imgui.table_next_column()
                add_spacing(1)
                imgui.text(key)
                add_spacing(1)

                imgui.table_next_column()
                add_spacing(1)
                imgui.text(location.name)
                add_spacing(1)
            end
            
            imgui.table_next_column()
            add_spacing(1)
            imgui.text(config.hotkeys["Teleport Window Show Key"])
            add_spacing(1)

            imgui.table_next_column()
            add_spacing(1)
            imgui.text("Window Visibility")
            add_spacing(1)

            imgui.end_table()
        else
            log_error("Failed to start the table.")
        end
        imgui.end_window()
    end
end)

re.on_draw_ui(function()

    if imgui.tree_node("Teleport") then
        add_spacing(1)

        imgui.text("Locations")
        imgui.push_item_width(190)

        _, select_location_index = imgui.combo("##select_location", select_location_index, location_names)

        imgui.same_line()
        add_spacing(1)
        imgui.same_line()

        if imgui.button(" Teleport ##location") then
            local location

            if select_location_index <= #locations then
                location = locations[select_location_index]
            else
                location = config.custom_location[select_location_index - #locations]
            end

            teleport(location.position)
        end

        imgui.pop_item_width()

        add_group_spacing()

        imgui.text("Name")
        imgui.push_item_width(190)
        _, new_custom_location_name = imgui.input_text("##custom_location_name", new_custom_location_name, 32)
        imgui.pop_item_width()

        imgui.same_line()
        if imgui.button("Add Custom Location") and new_custom_location_name ~= "" then
            add_custom_location(new_custom_location_name)
            update_location_names()
            new_custom_location_name = ""
        end

        add_group_spacing()

        if #custom_location_names > 0 then
            if imgui.tree_node("Delete Custom Locations") then
                add_group_spacing()

                imgui.text("Once deleted, items cannot be restored.")

                add_group_spacing()

                imgui.push_item_width(190)
                _, select_custom_location_index = imgui.combo("##custom_location", select_custom_location_index, custom_location_names)
                imgui.pop_item_width()

                imgui.same_line()
                if imgui.button("Delete") then
                    table.remove(config.custom_location, select_custom_location_index)
                    save_custom_location()
                    update_location_names()

                    if select_custom_location_index > #custom_location_names then
                        select_custom_location_index = 1
                    end
                end

                add_spacing(1)
                imgui.tree_pop()
            end
        end

        if #extra_location_names > 0 then
            if imgui.tree_node("Extra Locations") then
                add_group_spacing()

                imgui.push_item_width(190)
                _, select_extra_location_index = imgui.combo("##extra_location", select_extra_location_index, extra_location_names)
                imgui.pop_item_width()

                imgui.same_line()
                add_spacing(1)
                imgui.same_line()

                if imgui.button(" Teleport ##extra_location") then
                    teleport(extra_location_positions[select_extra_location_index])
                end

                add_spacing(1)
                imgui.tree_pop()
            end
        end

        if imgui.tree_node("Options") then
            add_group_spacing()

            local seeker_stone_changed, seeker_stone_value = imgui.checkbox("Load Seeker Stone Locations", load_seeker_stone_locations)
            -- チェック状態が更新されたとき
            if seeker_stone_changed then
                load_seeker_stone_locations = seeker_stone_value
                update_extra_location_names()
                update_extra_location_positions()

                if select_extra_location_index > #extra_location_names then
                    select_extra_location_index = 1
                end
            end

            add_group_spacing()

            local golden_beetle_changed, golden_beetle_value = imgui.checkbox("Load Golden Beetle Locations", load_golden_trove_beetle_locations)
            -- チェック状態が更新されたとき
            if golden_beetle_changed then
                load_golden_trove_beetle_locations = golden_beetle_value
                update_extra_location_names()
                update_extra_location_positions()

                if select_extra_location_index > #extra_location_names then
                    select_extra_location_index = 1
                end
            end

            add_spacing(1)
            imgui.tree_pop()
        end
        imgui.tree_pop()
    end
end)