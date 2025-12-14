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