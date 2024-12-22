_addon.author   = 'Sargonnas'
_addon.name     = 'invscan'
_addon.version  = '1.5'

require 'common'
require 'ffxi.enums'

----------------------------------------------------------------------------------------------------
-- Configuration
----------------------------------------------------------------------------------------------------
local export_folder = _addon.path
local csv_filename = 'inventory_export.csv'

-- Inventory containers to scan
local inventories = {
    Containers.Inventory,
    Containers.Safe,
    Containers.Storage,
    Containers.Locker,
    Containers.Satchel,
    Containers.Sack,
    Containers.Case,
    Containers.Wardrobe,
    Containers.Wardrobe2,
    Containers.Wardrobe3,
    Containers.Wardrobe4,
}

local inventory_names = {
    [Containers.Inventory]  = "Inventory",
    [Containers.Safe]       = "Safe",
    [Containers.Storage]    = "Storage",
    [Containers.Locker]     = "Locker",
    [Containers.Satchel]    = "Satchel",
    [Containers.Sack]       = "Sack",
    [Containers.Case]       = "Case",
    [Containers.Wardrobe]   = "Wardrobe",
    [Containers.Wardrobe2]  = "Wardrobe2",
    [Containers.Wardrobe3]  = "Wardrobe3",
    [Containers.Wardrobe4]  = "Wardrobe4",
}

-- Full job list:
local job_names = {
    'WAR', 'MNK', 'WHM', 'BLM', 'RDM', 'THF', 'PLD', 'DRK', 'BST', 'BRD',
    'RNG', 'SAM', 'NIN', 'DRG', 'SMN', 'BLU', 'COR', 'PUP', 'DNC', 'SCH',
    'GEO', 'RUN'
}

-- Slot bitmask mapping
local slot_map = {
    { bit = 0x0001, name = 'Main' },
    { bit = 0x0002, name = 'Sub' },
    { bit = 0x0004, name = 'Range' },
    { bit = 0x0008, name = 'Ammo' },
    { bit = 0x0010, name = 'Head' },
    { bit = 0x0020, name = 'Body' },
    { bit = 0x0040, name = 'Hands' },
    { bit = 0x0080, name = 'Legs' },
    { bit = 0x0100, name = 'Feet' },
    { bit = 0x0200, name = 'Neck' },
    { bit = 0x0400, name = 'Waist' },
    { bit = 0x0800, name = 'Left Ear' },
    { bit = 0x1000, name = 'Right Ear' },
    { bit = 0x2000, name = 'Left Ring' },
    { bit = 0x4000, name = 'Right Ring' },
    { bit = 0x8000, name = 'Back' },
}

----------------------------------------------------------------------------------------------------
-- Utility Functions
----------------------------------------------------------------------------------------------------
local function write_to_log(message)
    local log_path = export_folder .. '\\inventory_export.log'
    local f, err = io.open(log_path, 'a')
    if f then
        f:write(os.date('%Y-%m-%d %H:%M:%S') .. ' - ' .. message .. '\n')
        f:close()
    end
    print('[invscan] ' .. message)
end

local function quote_field(field)
    if field:find(',') then
        return '"' .. field .. '"'
    end
    return field
end

local function decode_slots(slotmask)
    if not slotmask or slotmask == 0 then
        return ''
    end

    local slots_used = {}
    for _, slotinfo in ipairs(slot_map) do
        if bit.band(slotmask, slotinfo.bit) ~= 0 then
            table.insert(slots_used, slotinfo.name)
        end
    end

    return table.concat(slots_used, '/')
end

----------------------------------------------------------------------------------------------------
-- Export Function
----------------------------------------------------------------------------------------------------
local function export_inventory()
    local csv_path = export_folder .. '\\' .. csv_filename
    write_to_log('Starting inventory export to: ' .. csv_path)

    local f, err = io.open(csv_path, 'w')
    if not f then
        write_to_log('Error opening CSV file for writing: ' .. tostring(err))
        return
    end

    -- Changed order of columns:
    -- Location,ItemName,Description,Slots,LevelRequirement,JobsCanUse,Count
    f:write('Location,ItemName,Description,Slots,LevelRequirement,JobsCanUse,Count\n')

    local inventory = AshitaCore:GetDataManager():GetInventory()
    local resourceManager = AshitaCore:GetResourceManager()

    if not inventory or not resourceManager then
        write_to_log('Error: Inventory or ResourceManager not available.')
        f:close()
        return
    end

    for _, invId in ipairs(inventories) do
        local containerMax = inventory:GetContainerMax(invId)
        if containerMax and containerMax > 0 then
            for slot = 0, containerMax - 1 do
                local inv_entry = inventory:GetItem(invId, slot)
                -- Check if there's a valid item
                if inv_entry and inv_entry.Id ~= 0 and inv_entry.Id ~= 65535 and inv_entry.Count > 0 then
                    local itemRes = resourceManager:GetItemById(inv_entry.Id)
                    if itemRes then
                        local itemName = itemRes.Name[0] or 'Unknown'
                        local count = inv_entry.Count or 1
                        local invName = inventory_names[invId] or 'Unknown'
                        local itemDescription = (itemRes.Description[0] or ''):gsub('[\r\n]', ' ')

                        -- Jobs
                        local jobMask = itemRes.Jobs or 0
                        local jobsCanUseList = {}
                        for i, jobname in ipairs(job_names) do
                            local bitval = bit.lshift(1, i-1)
                            if bit.band(jobMask, bitval) ~= 0 then
                                table.insert(jobsCanUseList, jobname)
                            end
                        end
                        local jobsCanUse = table.concat(jobsCanUseList, '/')

                        -- Level requirement
                        local levelRequirement = itemRes.Level or 0

                        -- Slots
                        local slotsStr = decode_slots(itemRes.Slots)

                        -- Print to chat
                        print(string.format('[%s] %s x%d | Jobs:%s | Lv:%d | Slots:%s', invName, itemName, count, jobsCanUse, levelRequirement, slotsStr))

                        -- Write to CSV in new order:
                        -- Location,ItemName,Description,Slots,LevelRequirement,JobsCanUse,Count
                        f:write(
                            quote_field(invName) .. ',' ..
                            quote_field(itemName) .. ',' ..
                            quote_field(itemDescription) .. ',' ..
                            quote_field(slotsStr) .. ',' ..
                            quote_field(tostring(levelRequirement)) .. ',' ..
                            quote_field(jobsCanUse) .. ',' ..
                            quote_field(tostring(count)) .. '\n'
                        )
                    end
                end
            end
        end
    end

    f:close()
    write_to_log('Inventory exported successfully: ' .. csv_path)
end

----------------------------------------------------------------------------------------------------
-- Events
----------------------------------------------------------------------------------------------------
ashita.register_event('load', function()
    write_to_log('invscan addon loaded. Default export folder: ' .. export_folder)
end)

ashita.register_event('unload', function()
    write_to_log('invscan addon unloaded.')
end)

ashita.register_event('command', function(cmd, nType)
    local args = cmd:args()
    if (#args == 0) then
        return false
    end

    if (args[1]:lower() == '/invscan') then
        if (#args == 1) then
            write_to_log('Usage:\n/invscan run - Export inventory listing with the updated column order.')
            return true
        end

        if (args[2]:lower() == 'run') then
            export_inventory()
            return true
        else
            write_to_log('Unknown argument: ' .. args[2])
            return true
        end
    end

    return false
end)
