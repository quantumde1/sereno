module scripts.sc3_r11.sc3;

import std.file;
import std.stdio;
import std.conv;
import variables;
import system.abstraction;
import raylib;
import std.string;
import scripts.sc3_r11.lzss;

size_t currentPosition = 0;
size_t textOffsetPosition = 0;

enum OpCodes : byte {
    NOP = 0x00,
    END = cast(byte)0x01,
    DIALOGBOX = 0x73,
    FILE_READ = 0x0F,
    SE_SET = 0x3D,
}

enum FileType {
    MAC,
    BG,
    EV,
    CHR,
    BGM,
    SE
}

ushort readUInt16(ref ubyte[] bytes, size_t offset) {
    size_t internalCurrentPosition = currentPosition+=2;
    ubyte lowByte = bytes[internalCurrentPosition];
    debugWriteln("low byte: ", lowByte);
    internalCurrentPosition+=1;
    ubyte highByte = bytes[internalCurrentPosition];
    debugWriteln("high byte: ", highByte);
    ushort twoBytesHighByte = cast(ushort)(highByte << 8);
    ushort result = cast(ushort)(twoBytesHighByte + lowByte);
    return result;
}


ubyte[] readCompressedBytesFromFile(string filename) {
    ubyte[] file = cast(ubyte[])read(filename);
    ubyte[] dest = decompressLzss(file[4..$]);
    return dest;
}

/*
        bgm_set = 0x37,
        bgm_req = 0x39,
        bgm_wait = 0x3A,
        se_set = 0x3D,
        se_req = 0x3F,
        se_wait = 0x40,
*/

string getAdxFilename(int bgmId) {
    return format!"%03d_BGM%02d.ADX.ogg"(bgmId, bgmId - 1);
}

int scriptParser(ubyte[] bytes) {
    if (pauseParser == true) return 2;
    if (currentPosition > bytes.length) return 1;
    debugWriteln("current position: ", currentPosition);
    byte opcode = bytes[currentPosition];
    debugWriteln("current opcode: ", opcode);
    switch (opcode) {
        case 0x37:
            messageGlobal ~= "";
            messageGlobal[0] = "bgm_set";
            PlayMusicStream(music);
            showDialog = true;
            pauseParser = true;
            currentPosition++;
            break;
        case 0x39:
            messageGlobal ~= "";
            messageGlobal[0] = "bgm_req";
            showDialog = true;
            pauseParser = true;
            currentPosition++;
            break;
        case 0x3A:
            messageGlobal ~= "";
            messageGlobal[0] = "bgm_wait";
            showDialog = true;
            pauseParser = true;
            currentPosition++;
            break;
        case 0x3D:
            messageGlobal ~= "";
            messageGlobal[0] = "se_set";
            showDialog = true;
            pauseParser = true;
            currentPosition++;
            break;
        case 0x40:
            messageGlobal ~= "";
            messageGlobal[0] = "se_req";
            showDialog = true;
            pauseParser = true;
            currentPosition++;
            break;
        case 0x3F:
            messageGlobal ~= "";
            messageGlobal[0] = "se_wait";
            showDialog = true;
            pauseParser = true;
            currentPosition++;
            break;
        case 0x38:
            StopMusicStream(music);
            messageGlobal ~= "";
            messageGlobal[0] = "bgm_del";
            showDialog = true;
            pauseParser = true;
            currentPosition+=2;
            break;
        case OpCodes.NOP:
            debugWriteln("NOP, currentPosition: ", currentPosition);
            currentPosition++;
            //pauseParser = true;
            break;
        case OpCodes.FILE_READ:
            debugWriteln("FILE_READ command");
            byte lowByte = bytes[currentPosition + 2];
            byte highByte = bytes[currentPosition + 3];
            ushort value = cast(ushort)((highByte << 8) | lowByte);
            int typeValue = value >> 12;
            int fileNumber = value & 0x0FFF;
            if (typeValue == FileType.BGM) {
                string path = getAdxFilename(fileNumber);
                music = LoadMusicStream(("res/bgmpc-en/"~path).toStringz());
            }
            messageGlobal ~= "";
            messageGlobal[0] = "file_read file type: "~typeValue.to!string~" fileNumber: "~fileNumber.to!string;
            showDialog = true;
            pauseParser = true;
            currentPosition += 4;
            break;
        case OpCodes.DIALOGBOX:
            string text;
            ushort result = readUInt16(bytes, currentPosition+2);
            debugWriteln(result);
            textOffsetPosition = result.to!int;
            ubyte[] rawBytes;
            while (textOffsetPosition < bytes.length && bytes[textOffsetPosition] != 0x00) {
                if (bytes[textOffsetPosition].to!char == '%') {
                    textOffsetPosition+=2;
                    continue;
                }
                else {
                    rawBytes ~= bytes[textOffsetPosition];
                }
                textOffsetPosition++;
            }
            textOffsetPosition++;
            for (size_t i = 0; i < rawBytes.length; i++) {
                if (rawBytes[i] == 0x81 && i + 1 < rawBytes.length) {
                    if (rawBytes[i + 1] == 0x75) {
                        string finalText = "["~text;
                        finalText ~= "]\"";
                        text = finalText;
                        i++;
                        continue;
                    } else if (rawBytes[i + 1] == 0x76) {
                        text ~= '\"';
                        i++;
                        continue;
                    }
                }
                if (rawBytes[i] >= 0x20 && rawBytes[i] <= 0x7E) {
                    text ~= cast(char)rawBytes[i];
                }
                else {
                    text ~= '?';
                    debugWriteln("Non-ASCII byte: ", format!"0x%02X"(rawBytes[i]));
                }
            }
            debugWriteln("Acquired text: ", text);
            messageGlobal ~= "";
            messageGlobal[0] = text;
            showDialog = true;
            pauseParser = true;
            break;
        default:
            debugWriteln("Unknown opcode/not implemented: ", bytes[currentPosition]);
            currentPosition++;
            break;
    }
    return 0;
}