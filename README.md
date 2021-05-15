## A repository with thousands of pre defined color presets for ReShade 
**What is it?** <br />

LUTs (Color Lookup Table) is a baked color preset that can be used on any game that ReShade can be installed to. <br />

### **What do I need to get it working?** <br />

 [ReShade](reshade.me)

The _BaseLUT.fxh, ReShade.fxh and ReShadeUI.fxh files that comes with this repository.

The .fx and .png files with matching file names.

### **Installation**

[Download](https://github.com/TheGordinho/MLUT/archive/refs/heads/master.zip) the repository.

Move the .fx files that you want (you don't need them all, just the ones you want) to the Shaders folder inside your reshade install folder.

Move the matching .png files to the Textures folder inside your reshade install folder.

Done!

### **Tips and Tricks**

You can mix and match as many luts as you want, but be aware that you will start to see heavy color banding with 2 or more LUTs active at the same time.

Change the load order of the shader so you get diferent results.

Place the luts sandwitched between the 2 PCGI shaders to change the GI colors

