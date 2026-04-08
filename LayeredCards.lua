local dlg = Dialog {title = "Choose Output Folder"}
local sprite = app.editor.sprite
local layers = {}
local layerNames = {}
local tiles = {}
local selectedfg = {}
local selectedbg = {}
local extensions = {".ase",".aseprite",".bmp",".css",".flc",".fli",".gif",".ico",".jpeg",".jpg",".pcx",".pcc",".png",".qoi",".svg",".tga",".webp"}
local ext, path
local totalFrames = #sprite.frames
local currentFrame = app.frame.frameNumber
local validRange = true

local deLayer, deGroup -- pre-makes the functions so they're useable

function deLayer(layer)
    if layer.isReference then

    elseif layer.isGroup then
        deGroup(layer)
    else
        local name = layer.name
        table.insert(layerNames, name)
        layers[name] = layer
    end
end

function deGroup(layer)
    local nameG
    nameG = string.format("Group: %s", layer.name)
    table.insert(layerNames, nameG)
    layers[nameG] = layer

    for _,subLayer in ipairs(layer.layers) do
        deLayer(subLayer)
    end
end

local layerSelect, layerGroup

function layerSelect(selectedLayer, who)
    if selectedLayer.isGroup then
        layerGroup(selectedLayer, who)
    else
        table.insert(who, selectedLayer)
    end
end

function layerGroup(selectedLayer, who)
    for _,layer in ipairs(selectedLayer.layers) do
        layerSelect(layer, who)
    end
end

for _,layer in ipairs(sprite.layers) do
    deLayer(layer)
end

local function entryCheck()
    if validRange and path and path ~= "" then
        dlg:modify{id = "mExport", enabled = true}
    else
        dlg:modify{id = "mExport", enabled = false}
    end
end

-- forground selection
dlg:combobox{id = "foreground", label="Foreground Layer/Group", options = layerNames}

-- background selection
dlg:combobox{id = "background", label="Background Layer/Group", options = layerNames}

-- output folder location
dlg:file{ id = "output", label = "Output Folder",
          basepath = app.fs.currentPath,
          open = false,
          save = true,
          title = "Create File in Folder of Choice",
          entry = true,
          onchange = function()
            path = dlg.data["output"]
            path = app.fs.filePath(path)
            if app.fs.isDirectory(path) == false then
                path = nil
                dlg:modify{id = "warningPath", text = "Warning: Invalid file path."}
            else
                dlg:modify{id = "warningPath", text = ""}
            end
            entryCheck()
        end
}

dlg:separator{id = "warningPath", text = ""}

-- extension selection
dlg:combobox{id = "extension", label = "File Type: ", options = extensions}

local function bounds(f1, f2)
    if f1 > f2 or f1 < 1 or f1 > totalFrames or f2 > totalFrames then
        validRange = false
        dlg:modify{id = "rangeWarn", text = "Warning: Invalid Frame Range"}
    else
        validRange = true
        dlg:modify{id = "rangeWarn", text = ""}
    end
    entryCheck()
end

-- frame selection
dlg:combobox{ id = "frames", label = "Frames to Export:",
              option = "Current",
              options = {"Current", "Specific", "Range", "All"},
              onchange = function()
                local what = dlg.data["frames"]
                if what == "Current" or what == "All" then
                    bounds(currentFrame, currentFrame)
                    dlg:modify{id = "frameNumber", visible = false}
                    dlg:modify{id = "frameRange1", visible = false}
                    dlg:modify{id = "frameRange2", visible = false}
                    dlg:modify{id = "rangeWarn", visible = false}
                elseif what == "Specific" then
                    bounds(dlg.data["frameNumber"], dlg.data["frameNumber"])
                    dlg:modify{id = "frameNumber", visible = true}
                    dlg:modify{id = "frameRange1", visible = false}
                    dlg:modify{id = "frameRange2", visible = false}
                elseif what == "Range" then
                    bounds(dlg.data["frameRange1"], dlg.data["frameRange2"])
                    dlg:modify{id = "frameNumber", visible = false}
                    dlg:modify{id = "frameRange1", visible = true}
                    dlg:modify{id = "frameRange2", visible = true}
                end
            end
}

dlg:check{id = "ignore", label = "Ignore empty cels:", selected = true}

dlg:check{id = "oneFrame", label = "Background(s) is one frame:", selected = true}

dlg:number{ id = "frameNumber", label = "Frame #:", text = tostring(currentFrame),
            decimals = 0, visible = false,
            onchange = function()
                bounds(dlg.data["frameNumber"], dlg.data["frameNumber"])
            end
}

dlg:number{ id = "frameRange1", label = "Start Frame:", text = tostring(currentFrame),
            decimals = 0, visible = false,
            onchange = function()
                bounds(dlg.data["frameRange1"], dlg.data["frameRange2"])
            end
}

dlg:number{ id = "frameRange2", label = "End Frame:", text = tostring(currentFrame),
            decimals = 0, visible = false,
            onchange = function()
                bounds(dlg.data["frameRange1"], dlg.data["frameRange2"])
            end
}

dlg:separator{id = "rangeWarn", text = ""}

-- cancel button
dlg:button{ id = "cancel", text = "Cancel",
    onclick = function()
        dlg:close()
    end
}

local function celCheck(layer, frame)
    local newCel, newPosi
    if layer:cel(frame) == nil then
        if layer.isTilemap then
            newCel = Image(sprite.width, sprite.height, ColorMode.TILEMAP)
        else
            newCel = Image(sprite.width, sprite.height, sprite.colorMode)
        end
        newPosi = Point()
    else
        newCel = layer:cel(frame).image
        newPosi = layer:cel(frame).position
    end
    return {newCel, newPosi}
end

local function tileMaker(tSet, spr)
    local newSet = spr:newTileset(tSet.grid, #tSet)
    for i = 1, #tSet-1, 1 do
        newSet:tile(i).image = tSet:tile(i).image
    end
    tiles[tSet.name] = newSet
end

local function layerCheck(layer, spr)
    local newLayer
    if layer.isTilemap then
        app.command.NewLayer{tilemap = true, ask = false}
        newLayer = spr.layers[#spr.layers]
        if tiles[layer.tileset.name] == nil then
            tileMaker(layer.tileset, spr)
        end

        newLayer.tileset = tiles[layer.tileset.name]
        newLayer.tileset.name = layer.tileset.name
    else
        newLayer = spr:newLayer()
    end
    return newLayer
end

-- mass exporting section
local function stack()
    local frameMatch = dlg.data["frames"]
    local f1, f2
    local frameName = ""
    if frameMatch == "Current" then
        f1 = currentFrame
        f2 = f1
    elseif frameMatch == "Specific" then
        f1 = dlg.data["frameNumber"]
        f2 = f1
    elseif frameMatch == "Range" then
        f1 = dlg.data["frameRange1"]
        f2 = dlg.data["frameRange2"]
    else
        f1 = 1
        f2 = totalFrames
    end

    local newSprite = Sprite(sprite.width, sprite.height, sprite.colorMode)
    local layer1
    local layer2

    for frame = f1, f2, 1 do
        if f1 ~= f2 then
            frameName = string.format("-%d", frame)
        end

        for _,b in ipairs(selectedbg) do
            local bFrame = frame

            if dlg.data["oneFrame"] then
                bFrame = 1
            end

            local bCel = celCheck(b, bFrame)

            if dlg.data["ignore"] == false or (dlg.data["ignore"] and bCel[1]:isEmpty() == false) then
                layer1 = layerCheck(b, newSprite)

                for _,f in ipairs(selectedfg) do
                    local fCel = celCheck(f, frame)

                    if dlg.data["ignore"] == false or (dlg.data["ignore"] and fCel[1]:isEmpty() == false) then
                        layer2 = layerCheck(f, newSprite)
                        local pName = string.format("%s%s%s%s", b.name, f.name, frameName, ext)
                        pName = app.fs.joinPath(path, pName)

                        newSprite:newCel(layer1, 1, bCel[1], bCel[2])
                        newSprite:newCel(layer2, 1, fCel[1], fCel[2])
                        newSprite:saveAs(pName)
                        newSprite:deleteLayer(layer2)
                    end
                end
                newSprite:deleteLayer(layer1)
            end
        end
    end
    newSprite:close()
end

dlg:button{ id = "mExport", text = "Mass Export", enabled = false,
    onclick = function()
        local fg = layers[dlg.data["foreground"]]
        local bg = layers[dlg.data["background"]]
        ext = dlg.data["extension"]
        currentFrame = app.frame.frameNumber
        layerSelect(fg, selectedfg)
        layerSelect(bg, selectedbg)
        stack()
        dlg:close()
    end
}

dlg:show{wait = false}