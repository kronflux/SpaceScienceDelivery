local data = _G.data
local se_delivery_cannon_recipes = _G.se_delivery_cannon_recipes
local data_util = require("data_util")
--=================================================================================================
local newItem
for _, item in pairs(data.raw["tool"]) do
    local txt = item.name
    local icon
    local recipe
    recipe = data_util.getRecipe(item.name)
    if item.icons then
        icon = item.icons[1]["icon"] or item.icons[1]
    else
        icon = item.icon
    end
    if recipe and icon then
        local category = recipe.category or "none"
        txt = category .. ":" .. txt .. ",recipe found"
        newItem = {
            type = "item",
            name = "crate-of-" .. item.name,
            icon = icon,
            icon_size = item.icon_size,
            stack_size = 200,
            subgroup = item.subgroup or "other",
            order = item.order or ("zzz[" .. item.name .. "]")
        }
        -- Ensure the item has an order tag on the subgroup as SE requires this
        local item_subgroup = data.raw["item-subgroup"][newItem.subgroup]
        item_subgroup.order = item_subgroup.order or ("zzz[" .. item_subgroup.name .. "]")
        -- Ensure the item also has an order tag on the group
        local item_group = data.raw["item-group"][item_subgroup.group]
        item_group.order = item_group.order or ("zzz[" .. item_group.name .. "]")
        data:extend({newItem})
        se_delivery_cannon_recipes[newItem.name] = {name = newItem.name, type = "item"}
    else
        txt = txt .. ",recipe or icon not found"
        log("icon: " .. serpent.block(icon))
        log("recipe: " .. serpent.block(recipe))
    end
    log(txt)
end