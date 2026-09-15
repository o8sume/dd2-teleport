**English** | [日本語](README_JA.md)

# Dragon's Dogma 2 - Teleport Mod

A lightweight teleport mod for Dragon's Dogma 2 using REFramework.

## Features

- Teleport to predefined locations
- Save and use custom locations
- Optional Seeker's Token locations
- Optional Golden Trove Beetle locations
- Configurable teleport hotkeys
- Teleport window for quick access to registered locations

## Requirements

- Dragon's Dogma 2
- REFramework
- _ScriptCore

## Installation

Copy the following files and folders into your REFramework `autorun` directory:

- `teleport.lua`
- `data/`

The resulting directory structure should look like this:

```text
reframework/
└── autorun/
    ├── teleport.lua
    └── data/
```

## Usage

Open the REFramework UI and expand the **Teleport** section to access the mod.

Select a location from **Locations** and press **Teleport** to teleport to that location.

You can also use the teleport window for quick access to predefined locations. By default, press `T` to toggle the teleport window. `F1` through `F12` teleport to the corresponding locations displayed in the window.

Hotkeys can be changed through _ScriptCore's hotkey configuration.

## Custom Locations

Enter a name in the **Name** field and press **Add Custom Location** to save your current position.

Saved custom locations are added to the **Locations** list and can be used in the same way as predefined locations.

Custom locations can be removed from **Delete Custom Locations**.

## Extra Locations

The **Extra Locations** section provides additional teleport destinations for collectibles:

- Seeker's Token locations
- Golden Trove Beetle locations

These location sets can be enabled or disabled from **Options**.

## Options

- **Load Seeker Stone Locations** — Show or hide Seeker's Token locations.
- **Load Golden Beetle Locations** — Show or hide Golden Trove Beetle locations.

These options apply to the current game session and are not persisted between restarts.

## Compatibility

Developed and tested with:

- Dragon's Dogma 2 TU3.2
- REFramework Nightly 01414
- TDB Version 83
- ScriptCore 1.2.07

Compatibility with other versions is not guaranteed. Game or REFramework updates may require an update to this mod.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.