local dlg = Dialog {title = "Choose Folder to Import"}
local spriteOG = app.editor.sprite
-- Filepath, Name
local files = {}
local extensionNames = {"None",".ase",".aseprite",".bmp",".css",".flc",".fli",".gif",".ico",".jpeg",".jpg",".pcx",".pcc",".png",".qoi",".svg",".tga",".webp"}
local allowedExt = {}
local path, folderName

local function entryCheck()
    if next(allowedExt) and path and path ~= "" then
        dlg:modify{id = "mImport", enabled = true}
    else
        dlg:modify{id = "mImport", enabled = false}
    end
end

local function addRemove(ext)
    local dext = ext:gsub("%.", "")
    if allowedExt[dext] == nil then
        dlg:modify{id = "extText", text = string.format("%s%s ", dlg.data["extText"], ext)}
        allowedExt[dext] = true

    elseif allowedExt[dext] then
        dlg:modify{id = "extText", text = dlg.data["extText"]:gsub(ext.."(%s)", "")}
        allowedExt[dext] = nil
    end
end

dlg:label{id = "extText", label = "Allowed Type(s):"}

dlg:combobox{ id = "extensionPick", label = "Pick the allowed file type(s).",
              options = extensionNames,
              onchange = function()
                if dlg.data["extensionPick"] ~= extensionNames[1] then
                    addRemove(dlg.data["extensionPick"])
                    entryCheck()
                end
            end
}

-- get folder name
dlg:file{ id = "import", label = "Import Folder",
        basepath = app.fs.currentPath,
        open = true,
        save = false,
        title = "Select a File in Folder of Choice",
        entry = true,
        onchange = function()
            path = dlg.data["import"]
            path = app.fs.filePath(path)
            folderName = string.match(path, "[\\/]([^/\\]+)$")
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

local function import()
    local layerGroup = spriteOG:newGroup()
    layerGroup.name = folderName

    for _,f in ipairs(files) do
        local newLayer = spriteOG:newLayer()
        newLayer.name = f[2]
        newLayer.parent = layerGroup
        local imageS = Image{fromFile=f[1]}
        spriteOG:newCel(newLayer, 1, imageS)
    end
end

local function getFiles()
    for _, f in ipairs(app.fs.listFiles(path)) do
        if allowedExt[app.fs.fileExtension(f)] then
            table.insert(files, {app.fs.joinPath(path, f), app.fs.fileTitle(f)})
        end
    end
end

-- cancel button
dlg:button{ id = "cancel", text = "Cancel",
    onclick = function()
        dlg:close()
    end
}

-- Importing section
dlg:button{ id = "mImport", text = "Mass Import", enabled = false,
    onclick = function()
        getFiles()
        import()
        app.refresh()
        dlg:close()
    end
}

dlg:show{wait = false}