# An Assortment of Aseprite Lua Scripts
Random Aseprite scripts I made. I either couldn't figure out how to do what I wanted in normal Aseprite; couldn't find a script with my exact needs; or a script that did have what I wanted, gave me too many tabs and options all at once. Or it cost money.

If you've never used scripts before, make a folder named scripts in Aseprite's main folder. Then put your scripts in that new folder. Renaming the script's filename also renames it within Aseprite, but shouldn't break anything.

If you submit a bug report on github I'll respond eventually. This is my first time making a serious Lua script.

I have no idea if these scripts work on Mac or Linux. Feel free to let me know if they don't. I encourage you to tweak the script if it doesn't meet your needs. I made these scripts on Aseprite version v1.3.2-dev.

[Aseprite Api](https://www.aseprite.org/api "https://www.aseprite.org/api")

**Intructions for each file is below:**
<details>
    <summary>Export Folder</summary>
    <ol>
        <li>File > Scripts > ExportFolder</li>
        <li>Select an Aseprite folder group to export from the dropdown list.</li>
        <li>Click the triple dots and navigate to the computer folder where you want to save all the layers.</li>
        <li>Type in anything you want in the save name field (both name and file type don't matter) or click an already existing file in the folder.</li>
        <li>Click save. Note, files with the same name as an exported layer will be overwritten.</li>
        <ul>
            <li>Alternatively, you can copy and paste your output folder path into the text entry field. Make sure the last character is `\` if on Windows, or `/` on any other platform. Example: `.../files/folder/path/`</li>
        </ul>
        <li>Select the file type you want the layers exported as.</li>
        <li>Select the frames you want exported.</li>
        <ul>
            <li>Current = The frame your sprite window is currently on. FYI, you can change the current active frame from the app window while the prompt is open.</li>
            <li>Specific = Choose a specific frame. Useful for when you know the number but can't find it on the timeline.
            <li>Range = A range of frames. Putting the same number for the start and end frame will act like "Specific".</li>
            <li>All = All frames in the sprite.</li>
        </ul>
        <li>Ignore empty cels option = Ignores any cel that has no pixel data if checked.</li>
        <ul>
            <li>For multi-frame exports, don't worry if Aseprite tells you that it's still exporting all the non-empty frames. That's just a baked in warning for the user.</li>
        </ul>
    </ol>
    Why did you make this?
    <ul>
        <li>I wanted to export a folder in Aseprite to a folder on my computer.</li>
        <li>I realised that sometimes I only needed specific frames exported per layer in my folder.</li>
        <li>I wanted every cel from each layer, not the full frame with all the cels merged into one image.</li>
        <li>I hated deleting all the empty exported cels just because one layer in a folder had a lot of cels.</li>
        <li>I wanted to type in the frame range to export, instead of fighting with the frame selection system because my mouse ghost clicks.</li>
        <li>I wanted something that grabbed invisible layers.</li>
        <li>I wanted something that grabbed layers that were in folders that were in folders that were in folders...</li>
        <li>I wanted something that supported tilemap layers since I use tilemaps like stickers.</li>
        <li>I wanted to choose my file type option once. The quality option will still pop up but those are toggle-able.</li>
    </ul>
</details>

<details>
    <summary>Import Folder</summary>
    <ol>
        <li>File > Scripts > ImportFolder</li>
        <li>Select a file within the computer folder that you plan to import and click "Open".</li>
        <ul>
            <li>Alternatively, you can copy and paste your input folder path into the text entry field. Make sure the last character is `\` if on Windows, or `/` on any other platform. Example: `.../files/folder/path/`</li>
        </ul>
        <li>Pick which file types you want imported.</li>
        <ul>
            <li>You can choose multiple types to import at once.</li>
            <li>You can choose an already selected file type and it will be removed from the import list.</li>
            <li>Due to a quirk with Aseprite dropdown menus, if you select a file type but immediately want it removed, you'll have to click on another option and then re-click the type again. This is why I added the "None" option since it will not add any file types and refreshes the dropdown menu.</li>
        </ul>
    </ol>
    Why did you make this?
    <ul>
        <li>I want to mass import all images in a folder to a folder of the same name in Aseprite.</li>
        <li>I wanted to select which file types got imported since sometimes I have duplicate images in different file types.</li>
        <li>I want all my imports to go into my current sprite rather than the image opening in a new sprite that I then have to copy into my sprite. This function seems to be added in later versions of Aseprite.</li>
    </ul>
</details>

<details>
    <summary>Layered Cards</summary>
    <ol>
        <li>File > Scripts > LayeredCards</li>
        <li>Select a group or layer to be the foreground.</li>
        <li>Select a group or layer to be the background.</li>
        <ul>
            <li>If a group is selected, every layer in the group will be used. So if I have four background layers in my background group, and one foreground layer, then I will get four images.</li>
        </ul>
        <li>Click the triple dots and navigate to the folder where you want to save all the cards.</li>
        <li>Type in anything you want in the save name field (both name and file type don't matter) or click an already existing file in the folder.</li>
        <li>Click save. Note, files with the same name as an exported card (background layer name + foreground layer name) will be overwritten.</li>
        <ul>
            <li>Alternatively, you can simply copy and paste your output folder path into the text entry field. Make sure the last character is `\` if on Windows, or `/` on any other platform. Example: `.../files/folder/path/`</li>
        </ul>
        <li>Select the file type you want the cards exported as.</li>
        <li>Select the frames you want exported.</li>
        <ul>
            <li>Current = The frame your sprite window is currently on. FYI, you can change the current active frame from the app window while the prompt is open.</li>
            <li>Specific = Choose a specific frame. Useful for when you know the number but can't find it on the timeline.
            <li>Range = A range of frames. Putting the same number for the start and end frame will act like "Specific".</li>
            <li>All = All frames in the sprite.</li>
        </ul>
        <li>Ignore empty cels option = When checked, skips creating a card for a frame if either its background OR foreground contains no pixel data.</li>
        <ul>
            <li>Example: You export two frames to cards but the second frame doesn't have a foreground cel or the cel is empty. That second frame won't produce a card.</li>
            <li>For multi-frame exports, don't worry if Aseprite tells you that it's still exporting all the non-empty frames. That's just a baked in warning for the user.</li>
        </ul>
        <li>Background(s) is one frame = True by default, it will take the first(1) frame of the selected background layer(s) and use that for every foreground frame.</li>
        <ul>
            <li>This means you don't have to copy paste the background cel under the foreground cels. Even if you use "Range" and select a range that doesn't include the first frame.</li>
            <li>Conversely, this also means you'll have to uncheck this feature if you have multiple backgrounds you want to use for specific frames.</li>
            <li>If you find yourself unchecking this option a lot, go in the script and change `dlg:check{id = "oneFrame", label = "Background(s) is one frame:", selected = true}` from `true` to `false`.</li>
        </ul>
    </ol>
    Why did you make this?:
    <ul>
        <li>I like making cards. I wanted a fast way to export cards in a way that complimented my work flow.</li>
        <ul>
            <li>I often make the images that go in the foreground on their own layers. So I may have a bunch of face and number cards in their own group. Then each frame in those layers may be its own suit. Then I make my backgrounds for each suit on a different layer and match the cel with the proper frame for the suit. Or if I'm feeling lazy, all the suits get the same background.</li>
            <li>I typically use this in conjunction with "Import Folder" and "Layers 2 Cels" to quickly make my cards and then turn them into sprite sheets that support duplicates.
        </ul>
        <li>I wanted something that grabbed invisible layers.</li>
        <li>I wanted something that grabbed layers that were in folders that were in folders that were in folders...</li>
        <li>I wanted to choose my layers without having to position them. You can choose a layer that's below your background's layer for your foreground, and it'll still export the image as if the foreground layer is on top. No pre-positioning required.</li>
        <li>I didn't like that some save options didn't check the foreground and background cels individually for being blank. I've had many cards with missing backgrounds that get exported because the foreground had pixel data.
        <li>I wanted something that supported tilemap layers since I use tilemaps like stickers and modular templates.</li>
        <li>In the future I'd like to add an option that somehow lets the person choose as many groups and layers to stack as they like. But my mouse ghost clicks too much now so I stopped coding. For now this is all I have.</li>
        <li>I know I called it "Layered Cards" but this can be used for non-card purposes too. I just mostly use it for card making. I am curious to know what else this could possibly be used for.</li>
    </ul>
</details>

<details>
    <summary>Layers 2 Cels</summary>
    <ol>
        <li>Organize the layers in the order you want them imported to your layer.</li>
        <li>Select all the layers you want to turn into cels.</li>
        <li>File > Scripts > Layers2Cels</li>
        <ul>
            <li>Selection Order = The order the layers will be imported in. Bottom to Top (default) or Top to Bottom. Relative to their order in the layer menu.</li>
            <li>Frame # = Which frame to grab your cels from.</li>
            <li>Target Cel = The cel number your layers will start to be inserted from (inclusive).</li>
            <li>Target Layer = The layer the selected layers will be inserted.</li>
        </ul>
    </ol>
    Why did you make this?:
    <ul>
        <li>I wanted to export a packed sprite sheet of all my layers, but you're not allowed to have duplicates for packed sheets. So I wanted a non-destructive way to quickly put the cels from each layer I want into one layer. By doing things this way, I can copy and paste the cels in groups within the layer once they're imported. Versus manually copy and pasting each cel into the layer first. Then I can export my layer as a sprite sheet with rows/columns, which supports duplicates.</li>
    </ul>
</details>