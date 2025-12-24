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
module system.config;

import std.stdio;
import std.file;
import std.string;
import std.range;
import variables;
import std.conv;
import system.abstraction;

nothrow string parseConf(string type, string filename) {
    try
    {
        auto file = File(filename);
        auto config = file.byLineCopy();
        
        static immutable typeMap = [
            "script": "SCRIPT:",
            "menu_script": "MENU_SCRIPT:",
            "title": "TITLE:",
            "icon": "ICON:",
            "dialog_end_indicator": "DIALOG_END_INDICATOR:",
            "dialog_box": "DIALOG_BOX:",
            "fallback_font": "FALLBACK_FONT:",
            "default_screen_width": "DEV_SCREEN_WIDTH:",
            "default_screen_height": "DEV_SCREEN_HEIGHT:",
            "screen_width": "SCREEN_WIDTH:",
            "screen_height": "SCREEN_HEIGHT:",
            "default_fullscreen": "DEFAULT_FULLSCREEN:",
        ];

        if (type in typeMap)
        {
            auto prefix = typeMap[type];
            foreach (line; config)
            {
                auto trimmedLine = strip(line);
                if (trimmedLine.startsWith(prefix))
                {
                    auto value = trimmedLine[prefix.length .. $].strip();
                    debug debugWriteln("Value for ", type, ": ", value);
                    return value;
                }
            }
        }
    }
    catch (Exception e)
    {
        debugWriteln(e.msg);
    }
    return "";
}

SystemSettings loadSettingsFromConfigFile(string confName) {
    return SystemSettings(
        parseConf("script", confName),
        parseConf("menu_script", confName),
        parseConf("title", confName),
        parseConf("icon", confName),
        parseConf("dialog_end_indicator", confName),
        parseConf("dialog_box", confName),
        parseConf("fallback_font", confName),
        parseConf("default_screen_width", confName).to!int,
        parseConf("default_screen_height", confName).to!int,
        parseConf("screen_width", confName).to!int,
        parseConf("screen_height", confName).to!int,
        parseConf("default_fullscreen", confName).to!bool
    );
}