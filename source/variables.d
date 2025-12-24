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
module variables;

import std.typecons;
import raylib;
import system.abstraction;

nothrow void resetAllScriptValues() {
    debugWriteln("cleaning all values!");
    selectedChoice = 0;
    debugWriteln("unloading animations");
    for (int i = 0; i < framesUI.length; i++) {
        if (framesUI[i].id != 0) UnloadTexture(framesUI[i]);
    }
    debugWriteln("unloading characters");
    for (int i = 0; i < characterTextures.length; i++) {
        characterTextures[i].drawTexture = false;
        if (characterTextures[i].texture.id != 0) UnloadTexture(characterTextures[i].texture);
    }
    debugWriteln("unloading backgrounds");
    for (int i = 0; i < backgroundTextures.length; i++) {
        backgroundTextures[i].drawTexture = false;
        if (backgroundTextures[i].texture.id != 0) UnloadTexture(backgroundTextures[i].texture);
    }
    debugWriteln("resetting characterTextures and backgroundTextures");
    characterTextures = [];
    backgroundTextures = [];
}

/* system */

struct SystemSettings {
    string scriptPath;
    string menuScriptPath;
    string windowTitle;
    string iconPath;
    string dialogBoxEndIndicator;
    string dialogBoxBackground;
    string fallbackFont;
    int defaultScreenWidth;
    int defaultScreenHeight;
    int screenWidth;
    int screenHeight;
    bool defaultFullscreen;
}

struct TextureEngine {
    bool drawTexture;
    bool justDrawn;
    float width;
    float height;
    float x;
    float y;
    Texture2D texture;
    float scale;
    Color color = Colors.WHITE;
    float alpha = 0.0f;
    float targetAlpha = 0.0f;
    float fadeSpeed = 9.0f;
    bool isFading = false;
}

enum GameState {
    MainMenu = 1,
    InGame = 2,
    Exit = 3
}

enum EngineExitCodes {
    EXIT_FILE_NOT_FOUND = 2,
    EXIT_SCRIPT_ERROR = 3,
    EXIT_OK = 0,
}

TextureEngine[] characterTextures;

TextureEngine[] backgroundTextures;

SystemSettings systemSettings;

Font textFont;

Music music;

/* booleans */

bool pauseParser = false;

bool showDialog = false;

bool videoFinished = false;

bool playAnimation = false;

/* strings */

string[] messageGlobal;

string[] choices;

string scriptPath;


/* floats */

float baseWidth;

float baseHeight;

float frameDuration = 0.016f;

float typingSpeed = 0.6f;

float scale = 1.0f;

/* textures */

Texture2D[] framesUI;

Texture2D dialogBackgroundTex;

Texture2D circle;

/* integer values */

int button;

int selectedChoice = 0;

int choicePage = -1;

int currentGameState = 1;

int currentFrame = 0;

int currentChoiceCharIndex = 0;

int renderTextureWidth;

int renderTextureHeight;

/* ubyte values */

ubyte animationAlpha = 127;