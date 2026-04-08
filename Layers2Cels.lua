local dlg = Dialog {title = "Convert Layers to Cels"}
local sprite = app.editor.sprite
local layers = {}
local layerNames = {"Select a Layer."}
-- layer index, layer uuid
local layerIndex = {}
local sort = true
local busy = false

local sorty, celly

local function numbers()
    if dlg.data["targetFrame"] > #sprite.frames or dlg.data["targetFrame"] <= 0 then
        dlg:modify{id = "warning3", text = "Warning: Invalid frame."}
        dlg:modify{id = "cellify", enabled = false}
    else
        dlg:modify{id = "warning3", text = ""}
        if layers[dlg.data["targetLayer"]] and busy == false then
            dlg:modify{id = "cellify", enabled = true}
        end
    end
end

dlg:separator{ id = "warning",text = ""}
    :button{ id = "sort", label = "Selection Order: ", text = "Unavailable", onclick = function() sorty() end}
    :number{id = "targetFrame", label = "Frame # to Grab Cels From:", text = "1", decimals = 0, onchange = function() numbers() end}
    :separator{id = "warning3", text = ""}
    :number{id = "startCel", label = "Target Cel # to Start At:", text = "1", decimals = 0}
    :separator{id = "warning2", text = "Warning: If target layer's cels contain data, data will be overwritten."}
    :combobox{id = "targetLayer", label = "Target Layer", onchange = function() numbers() end}
    :button {id = "cancel", text = "Cancel", onclick = function() dlg:close() end}
    :button{id = "cellify", enabled = false, text = "Make Cels", onclick = function() celly() end}

local deLayer, deGroup

function deLayer(layer)
    if layer.isReference or layer.isTilemap then

    elseif layer.isGroup then
        deGroup(layer)
    else
        local name = layer.name
        table.insert(layerNames, name)
        layers[name] = layer
    end
end

function deGroup(layer)
    for _,subLayer in ipairs(layer.layers) do
        deLayer(subLayer)
    end
end

local function indexer(layer, idx, stringI)
    if layer.isGroup then
        if stringI == "" then
            stringI = string.format("%s.", layer.stackIndex)
        else
            stringI = string.format("%s.%d", stringI, idx)
        end

        for _, l in ipairs(layer.layers) do
            indexer(l, l.stackIndex, stringI)
        end

    elseif layer.isTilemap then
    else
        table.insert(layerIndex, {string.format("%s%d", stringI, idx), layer})
    end
end

local function parentCatcher(layer, str)
    if layer.parent.layers and layer.parent ~= sprite then
        if str == "" then
            str = string.format("%s.",layer.parent.stackIndex)
        else
            str = string.format("%s.%s",layer.parent.stackIndex,str)
        end
        str = parentCatcher(layer.parent, str)
    end
    return str
end

local function tSorty(a, b)
    a = a[1]
    b = b[1]
    local int1 = tonumber(string.match(a, "%d+"))
    local int2 = tonumber(string.match(b, "%d+"))

    if int1 == int2 then
        local aTable = {}
        local bTable = {}
        for aNum in a:gmatch("(%d+)") do
            table.insert(aTable, tonumber(aNum))
        end

        for bNum in b:gmatch("(%d+)") do
            table.insert(bTable, tonumber(bNum))
        end

        local aTN = #aTable
        local bTN = #bTable
        local min = aTN < bTN and aTN or bTN

        for i = 1, min, 1 do
            if aTable[i] ~= bTable[i] then
                int1 = aTable[i]
                int2 = bTable[i]
            end
        end
    end

    if sort then
        return int1 < int2
    else
        return int1 > int2
    end
end

local function buttonState(what)
    if what then
        busy = false
        numbers()
    else
        busy = true
        numbers()
    end
end

function sorty()
    if not busy then
        buttonState(false)
        if sort then
            dlg:modify{id = "sort", text = "Bottom to Top"}
            table.sort(layerIndex, tSorty)
            sort = false
        else
            dlg:modify{id = "sort", text = "Top to Bottom"}
            table.sort(layerIndex, tSorty)
            sort = true
        end
        buttonState(true)
    end
end

if app.range.type ~= RangeType.LAYERS then
    dlg:modify{id = "warning", text = "Warning: No layers selected. Click Cancel and try again."}
    dlg:modify{id = "sort", enabled = false}
    dlg:modify{id = "targetFrame", enabled = false}
    dlg:modify{id = "startCel", enabled = false}
    dlg:modify{id = "targetLayer", enabled = false}
    dlg:modify{id = "warning2", text = ""}
else
    for _,rlayer in ipairs(app.range.layers) do
        local parent = parentCatcher(rlayer, "")
        indexer(rlayer, rlayer.stackIndex, parent)
    end

    for _,layer in ipairs(sprite.layers) do
        deLayer(layer)
    end
    sorty()
end

-- Layer selection
dlg:modify{ id = "targetLayer",
              option = "Select a Layer.",
              options = layerNames
}

-- mass move cels into one layer
local function stack(targetLayer, totalFrames, startCel, targetFrame)
    local frameExcess = totalFrames - startCel + 1
    local framesNeeded = frameExcess - #layerIndex

    if framesNeeded < 0 then
       for _ = totalFrames+1, -framesNeeded+totalFrames, 1 do
            sprite:newEmptyFrame()
        end
    end

    local count = startCel
    for _,n in pairs(layerIndex) do
        local image, posi
        if n[2]:cel(targetFrame) == nil then
            image = Image(sprite.width, sprite.height, sprite.colorMode)
            posi = Point()
        else
            image = n[2]:cel(targetFrame).image
            posi = n[2]:cel(targetFrame).position
        end
        sprite:newCel(targetLayer, count, image, posi)
        count = count + 1
    end
end

function celly()
    local targetLayer = layers[dlg.data["targetLayer"]]
    local totalFrames = #sprite.frames
    local startCel = dlg.data["startCel"]
    local targetFrame = dlg.data["targetFrame"]
    stack(targetLayer, totalFrames, startCel, targetFrame)
    app.refresh()
    dlg:close()
end

dlg:show {wait = false}