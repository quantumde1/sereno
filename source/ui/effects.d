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
module ui.effects;

import raylib;
import std.stdio;
import variables;
import std.string;
import system.abstraction;
import std.file;

void fadeEffect(float alpha, bool fadeIn, void delegate(float alpha) renderer)
{
    const float FadeIncrement = 0.02f;

    while (fadeIn ? alpha < 2.0f : alpha > 0.0f)
    {
        alpha += fadeIn ? FadeIncrement : -FadeIncrement;
        BeginDrawing();
        ClearBackground(Colors.BLACK);
        renderer(alpha);
        EndDrawing();
    }
}

void renderText(float alpha, immutable(char)* text)
{
    DrawTextEx(textFont, text,
        Vector2(GetScreenWidth() / 2 - MeasureText(text, 40) / 2,
            GetScreenHeight() / 2), 40, 0, Fade(Colors.WHITE, alpha)
    );
}

void helloScreen()
{
    debug
    {
        bool play = false;
        debugWriteln("hello screen showing");
        if (play == false) {
            videoFinished = true;
        }
    } else {
        fadeEffect(0.0f, true, (float alpha) {
            renderText(alpha, "powered by\n\nHimmel Engine");
        });

        fadeEffect(2.0f, false, (float alpha) {
            renderText(alpha, "powered by\n\nHimmel Engine");
        });
    }
}