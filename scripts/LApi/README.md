# ITB-LApi
 LApi is a mod loader extender for Into the Breach, intended to add functionality for mods - mainly via memory manipulation. It will add or alter existing functions for Pawn and Board, among other things.

# How to use
 In order to add the functions, all you need to do is to download the latest [release](../../releases), and drop the LApi folder into your mod, and use `require` on the file `LApi.lua`.

*Note: This project uses submodules. If you want to download the `master` branch, the easiest way is to use `git clone --recurse-submodules [repo-path]`. Alternatively if you downloaded the branch and forgot to use `--recurse-submodules`, you can fetch the submodules with `git submodule update --init --recursive`*

&nbsp;

For example if you place LApi into `../Into the Breach/mods/[my mod]/scripts/ITB-LApi/`, then your mod's `init.lua` should look like this:
```lua
local function init(self)
    require(self.scriptPath .."ITB-LApi/LApi")
end
```

# Documentation
 See the [wiki](../../wiki) for documentation on the functions added by this library.

&nbsp;
