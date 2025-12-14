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