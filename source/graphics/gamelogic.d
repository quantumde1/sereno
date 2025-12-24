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
module graphics.gamelogic;

import raylib;
import variables;
import graphics.effects;
import std.string;
import std.math;
import dialogs.dialogbox;
import system.abstraction;
import std.conv;
 
void gameInit()
{
    circle = LoadTexture(systemSettings.dialogBoxEndIndicator.toStringz());
    dialogBackgroundTex = LoadTexture(systemSettings.dialogBoxBackground.toStringz());
    if (WindowShouldClose()) {
        currentGameState = GameState.Exit;
    } else {
        debugWriteln("Game initializing.");
        scriptPath = systemSettings.scriptPath;
    }
    return;
}

void unloadResourcesOnExit() {
    UnloadMusicStream(music);
    resetAllScriptValues();
    UnloadTexture(circle);
    UnloadTexture(dialogBackgroundTex);
    if (textFont.texture.id != 0) {
        UnloadFont(textFont);
    }
}

void texturesLogic(TextureEngine[] textures) {
    for (int i = 0; i < textures.length; i++) {
        if (textures[i].drawTexture) {
            if (textures[i].alpha < 1.0f) {
                textures[i].alpha += GetFrameTime() * textures[i].fadeSpeed;
                if (textures[i].alpha > 1.0f) textures[i].alpha = 1.0f;
            }
        } else {
            if (textures[i].alpha > 0.0f) {
                textures[i].alpha -= GetFrameTime() * textures[i].fadeSpeed;
                if (textures[i].alpha < 0.0f) textures[i].alpha = 0.0f;
            }
        }

        if (textures[i].alpha > 0.0f) {
            float centeredX = textures[i].x - (textures[i].width * textures[i].scale / 2);
            float centeredY = textures[i].y - (textures[i].height * textures[i].scale / 2);
            
            Color tint = textures[i].color;
            tint.a = cast(ubyte)(255 * textures[i].alpha);
            
            DrawTextureEx(textures[i].texture,
                Vector2(centeredX, centeredY),
                0.0,
                textures[i].scale,
                tint
            );
        }
    }
}

void effectsLogic() {
    UpdateMusicStream(music);
    playUIAnimation(framesUI, animationAlpha);
}

void backgroundLogic() {
    texturesLogic(backgroundTextures);
}

void characterLogic() {
    texturesLogic(characterTextures);
}

void dialogLogic() {
    if (showDialog) {
        dialogBox();
    }
}