// quantumde1 developed software, licensed under MIT license.
import raylib;

//local imports
import system.init;
import scripts.sc3_r11.sc3;
import std.conv;
import system.abstraction;

void main(string[] args)
{
//    validateRaylibBinding();
    debug {
        SetTraceLogLevel(0);
    } else {
        SetTraceLogLevel(7);
    }
    if (args.length == 2) {
        debugWriteln("args length: ", args.length);
        currentPosition = args[1].to!int;
        debugWriteln("pos selected: ", args[1]);
    }
    engineLoader();
}