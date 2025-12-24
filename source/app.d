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