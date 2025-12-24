/*CDDL HEADER START

The contents of this file are subject to the terms of the
Common Development and Distribution License (the "License").
You may not use this file except in compliance with the License.

You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
or http://www.opensolaris.org/os/licensing.
See the License for the specific language governing permissions
and limitations under the License.

When distributing Covered Code, include this CDDL HEADER in each
file and include the License file at usr/src/OPENSOLARIS.LICENSE.
If applicable, add the following below this CDDL HEADER, with the
fields enclosed by brackets "[]" replaced with your own identifying
information: Portions Copyright [yyyy] [name of copyright owner]

CDDL HEADER END

Copyright (c) 2025 quantumde1 
*/
module ui.menu;

import raylib;
import variables;
import std.stdio;
import system.abstraction;
import graphics.playback;
import graphics.gamelogic;
import std.conv : to;

int showMainMenu() {
    /*int luaExecutionCode = luaInit(systemSettings.menuScriptPath);
    if (luaExecutionCode != EngineExitCodes.EXIT_OK) {
        writeln("[ERROR] Engine stops Lua execution according to error code: ", 
        luaExecutionCode.to!EngineExitCodes);
        currentGameState = GameState.Exit;
        return luaExecutionCode;
    }
    luaReload = false;
    while (currentGameState == GameState.MainMenu)
    {
        ClearBackground(Colors.WHITE);
        if (IsKeyPressed(KeyboardKey.KEY_F11)) {
            ToggleFullscreen();
        }
        UpdateMusicStream(music);
        BeginDrawing();
        backgroundLogic();
        effectsLogic();
        luaEventLoopPost2D();
        EndDrawing();
    }
    debugWriteln("menu assets unloading");
    StopMusicStream(music);
    UnloadMusicStream(music);
    music = Music();
    luaReload = true;*/
    currentGameState = GameState.InGame;
    return EngineExitCodes.EXIT_OK;
}