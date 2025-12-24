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
module scripts.hbs.main;

import std.file;
import std.stdio;
import std.conv;
import variables;
import system.abstraction;
import raylib;
import std.string;

size_t currentPosition = 0;

enum OpCodes : byte {
    NOP = 0x00,
    DIALOGBOX = 0x01,
    LOADBACKGROUND = 0x02,
    DRAWBACKGROUND = 0x03,
    LOADCHARACTER = 0x04,
    DRAWCHARACTER = 0x05,
    BRE = 0x06,
    BRNE = 0x07,
    LOADMUSIC = 0x08,
    PLAYMUSIC = 0x09,
    STOPMUSIC = 0x10,
    UNLOADMUSIC = 0x11,
    TEXTPAGEEND = cast(byte)0xFD,
    TEXTEND = cast(byte)0xFE,
    END = cast(byte)0xFF,
}

byte[] readBytesFromFile(string filename) {
    byte[] file = cast(byte[])read(filename);
    return file;
}

void scriptParser(byte[] bytes) {
    if (pauseParser == true) return;
    debugWriteln(currentPosition);
    debugWriteln(bytes.length);
    byte opcode = bytes[currentPosition];
    switch (opcode) {
        case OpCodes.NOP:
            writeln("NOP, currentPosition: ", currentPosition);
            currentPosition++;
            //pauseParser = true;
            break;
        case OpCodes.DIALOGBOX:
            string[] pages;
            int pageIndex = 0;
            pages.length = 1;
            writeln("DIALOGBOX, currentPosition: ", currentPosition);
            currentPosition++;
            while (true) {
                char symbol;
                if (bytes[currentPosition] == OpCodes.TEXTPAGEEND) {
                    if (bytes[currentPosition+1] == OpCodes.TEXTEND) {
                        currentPosition+=1;
                        break;
                    } else {
                        pageIndex += 1;
                        pages.length += 1;
                    }
                }
                else if (bytes[currentPosition] == OpCodes.TEXTEND) {
                    break;
                } else {
                    symbol = bytes[currentPosition].to!char;
                    pages[pageIndex] ~= symbol;
                }
                currentPosition++;
            }
            writeln(pages);
            currentPosition++;
            pauseParser = true;
            messageGlobal = pages;
            showDialog = true;
            break;
        case OpCodes.END:
            writeln("END of script, currentPosition: ", currentPosition);
            pauseParser = true;
            return;
        case OpCodes.LOADMUSIC:
            string filename;
            currentPosition++;
            while (true) {
                char symbol;
                if (bytes[currentPosition] == OpCodes.TEXTEND) {
                    currentPosition++;
                    break;
                } else {
                    symbol = bytes[currentPosition].to!char;
                    filename ~= symbol;
                }
                currentPosition++;
            }
            music = LoadMusicStream(toStringz(filename));
            break;
        case OpCodes.PLAYMUSIC:
            PlayMusicStream(music);
            currentPosition++;
            break;
        case OpCodes.STOPMUSIC:
            StopMusicStream(music);
            currentPosition++;
            break;
        case OpCodes.UNLOADMUSIC:
            UnloadMusicStream(music);
            currentPosition++;
            break;
        default:
            break;
    }
}