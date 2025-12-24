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