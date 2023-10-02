﻿local data = _G.data
local data_util = require("data_util")
--=================================================================================================
local itemBoxName
for _, item in pairs(data.raw["tool"]) do
    local txt = item.name
    local recipe = data_util.getRecipe(item.name)
    local icon
    if item.icons then
        icon = item.icons[1]["icon"] or item.icons[1]
    else
        icon = item.icon
    end
    if recipe and icon then
        txt = txt .. ",recipe found"
        local category = recipe.category or "none"
        txt = category .. ":" .. txt
        itemBoxName = "crate-of-" .. item.name
        ---------------------------------------------------------------------------------------
        log(item.name .. " --> " .. itemBoxName .. "(" .. (icon) .. ")")
        local newItem = data.raw.item[itemBoxName]
        if newItem then
            txt = txt .. ",box found"
            newItem.order = "zz" .. item.order
            local overlayIcon = {
                icon = "__nco-SpaceScienceDelivery__/graphics/icons/icon_P.png",
                icon_size = 64
            }
            if item.icons then
                newItem.icons = util.table.deepcopy(item.icons)
                table.insert(newItem.icons, overlayIcon)
            else
                local baseIcon = {
                    icon = icon,
                    icon_size = item.icon_size
                }
                newItem.icons = {baseIcon, overlayIcon}
            end
            newItem.icon = nil
            data.raw.item[itemBoxName] = newItem
            ---------------------------------------------------------------------------------------
            local bulletRecipeName = "se-delivery-cannon-pack-" .. "crate-of-" .. item.name
            local bulletRecipe = data.raw.recipe[bulletRecipeName]

            if bulletRecipe then
                bulletRecipe.icon = nil
                bulletRecipe.icon_mipmaps = nil
                bulletRecipe.icons = newItem.icons
                data.raw.recipe[bulletRecipeName] = bulletRecipe
            end
            ---------------------------------------------------------------------------------------
            local boxRecipe = util.table.deepcopy(recipe)
            boxRecipe.name = "pack-" .. itemBoxName
            boxRecipe.results = nil
            boxRecipe.icon = nil
            boxRecipe.localised_name = nil
            boxRecipe.icons = newItem.icons
            boxRecipe.result = nil
            boxRecipe.result_count = nil
            boxRecipe.main_product = itemBoxName
            local results = {{amount = 1, name = itemBoxName, type = "item"}}
            local extraIngredient = {type = "item", name = "se-heat-shielding", amount = 1}
            if boxRecipe.normal then
                table.insert(boxRecipe.normal.ingredients, extraIngredient)
                boxRecipe.normal.result = nil
                boxRecipe.normal.result_count = nil
                boxRecipe.normal.results = results
            end
            if boxRecipe.expensive then
                table.insert(boxRecipe.expensive.ingredients, extraIngredient)
                boxRecipe.expensive.result = nil
                boxRecipe.expensive.result_count = nil
                boxRecipe.expensive.results = results
            end
            if boxRecipe.normal == nil then
                boxRecipe.results = results
                if boxRecipe.ingredients then
                    table.insert(boxRecipe.ingredients, extraIngredient)
                end
            end

            data:extend({boxRecipe})
            ---------------------------------------------------------------------------------------
            for k, v in pairs(data.raw.module) do
                if v.limitation then
                    if data_util.has_value(v.limitation, recipe.name) then
                        table.insert(v.limitation, boxRecipe.name)
                        log("added recipe " .. boxRecipe.name .. " to  " .. v.name .. " limitations")
                    end
                end
            end
            ---------------------------------------------------------------------------------------
            local unboxRecipe = util.table.deepcopy(recipe)
            unboxRecipe.name = "unbox-" .. itemBoxName
            unboxRecipe.ingredients = {{type = "item", name = itemBoxName, amount = 1}}
            if unboxRecipe.expensive then
                unboxRecipe.result = unboxRecipe.expensive.result
                unboxRecipe.results = unboxRecipe.expensive.results
                unboxRecipe.energy_required = unboxRecipe.expensive.energy_required
                unboxRecipe.result_count = unboxRecipe.expensive.result_count
            end
            unboxRecipe.expensive = nil
            unboxRecipe.normal = nil
            unboxRecipe.category = "space-manufacturing"
            unboxRecipe.icon = nil
            local unboxOverlayIcon = {
                icon = "__nco-SpaceScienceDelivery__/graphics/icons/icon_U.png",
                icon_size = 64
            }
            if item.icons then
                unboxRecipe.icons = util.table.deepcopy(item.icons)
                table.insert(unboxRecipe.icons, unboxOverlayIcon)
            else
                local baseIcon = {
                    icon = icon,
                    icon_size = item.icon_size
                }
                unboxRecipe.icons = {baseIcon, unboxOverlayIcon}
            end
            data:extend({unboxRecipe})
            local tech = data_util.getTechnologyForRecipe(recipe.name)
            if tech then
                table.insert(tech.effects, {type = "unlock-recipe", recipe = boxRecipe.name})
                table.insert(tech.effects, {type = "unlock-recipe", recipe = unboxRecipe.name})
                data.raw["technology"][tech.name] = tech
            else
                txt = txt .. "tech not found"
            end
        end
    else
        txt = txt .. ",recipe or icon not found"
        log("icon: " .. serpent.block(icon))
        log("recipe: " .. serpent.block(recipe))
    end
    log(txt)
end