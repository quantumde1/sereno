// quantumde1 developed software, licensed under MIT license.
module system.init;

import raylib;

//dlang imports
import std.stdio;
import std.string;
import std.conv;

//graphics
import graphics.gamelogic;
import ui.menu;
import ui.effects;

//dialogs
import dialogs.dialogbox;

//scripting imports

//engine internal functions
import system.config;
import system.abstraction;
import variables;
import std.algorithm;
import system.mainloop;

void engineLoader()
{
    systemSettings = loadSettingsFromConfigFile("conf/settings.conf");
    baseWidth = systemSettings.defaultScreenWidth;
    baseHeight = systemSettings.defaultScreenHeight;
    int screenWidth = systemSettings.screenWidth;
    int screenHeight = systemSettings.screenHeight;
    scale = min(cast(float)(screenWidth/baseWidth), cast(float)(screenHeight/baseHeight));
    debugWriteln("scale: ", scale);
    // Initialization
    Image icon = LoadImage(systemSettings.iconPath.toStringz());
    // Window and Audio Initialization
    InitWindow(screenWidth, screenHeight, systemSettings.windowTitle.toStringz());
    if (systemSettings.defaultFullscreen == true) {
        ToggleFullscreen();
    }
    SetWindowIcon(icon);
    UnloadImage(icon);
    //ToggleFullscreen();
    SetTargetFPS(60);
    //fallback font?
    textFont = LoadFont(systemSettings.fallbackFont.toStringz());
    // Fade In and Out Effects
    InitAudioDevice();
    helloScreen();
    EndDrawing();
    mainLoop();
}