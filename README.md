# Terminal Oracle Game

This project contains a small PowerShell game inspired by classic top-down RPGs like RuneScape. The game is implemented using WPF for simple 2D graphics and demonstrates several PowerShell capabilities.

## Structure

- `src/TerminalOracleGame.psm1` – PowerShell module that implements the game logic. The module is organized into small helper functions for window setup, map generation, player movement and drawing.
- `src/Start-Game.ps1` – script that imports the module and starts the game.

## Running

To play the game, open a PowerShell session on Windows and run:

```powershell
cd path\to\repository\src
powershell -ExecutionPolicy Bypass -File .\Start-Game.ps1
```

This will launch a window titled *The Terminal Oracle* where you can move the player using the **W**, **A**, **S**, and **D** keys.
