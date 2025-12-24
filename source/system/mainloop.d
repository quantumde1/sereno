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
module system.mainloop;

import variables;
import ui.menu;
import system.abstraction;
import graphics.gamelogic;
import raylib;
import std.stdio;
import std.conv;
import std.algorithm;

import scripts.sc3_r11.sc3;

void mainLoop() {
    while (true)
    {
        switch (currentGameState)
        {
            case GameState.MainMenu:
                debugWriteln("Showing menu.");
                showMainMenu();
                break;
            case GameState.InGame:
                gameInit();
                ubyte[] bytes = readCompressedBytesFromFile("res/mac/000_PR_01.BIP");
                while (!WindowShouldClose())
                {
                    int x = scriptParser(bytes);
                    if (x == 1) {
                        debugWriteln("EOF script, exit");
                        currentGameState = GameState.Exit;
                    }
                    SetExitKey(KeyboardKey.KEY_F11);
                    BeginDrawing();
                    ClearBackground(Colors.BLACK);

                    // background display logic
                    backgroundLogic();
                    // character display logic
                    characterLogic();
                    // effects logic
                    effectsLogic();
                    //drawing dialogs
                    dialogLogic();
                    EndDrawing();
                }
                break;
            case GameState.Exit:
                unloadResourcesOnExit();
                CloseAudioDevice();
                debugWriteln("closing window!");
                CloseWindow();
                return;
            default:
                break;
        }
    }
}