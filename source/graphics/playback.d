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
module graphics.playback;

import std.stdio;
import raylib;
import raylib.rlgl;
import core.stdc.stdlib;
import core.stdc.string;
import variables;
import core.sync.mutex;
import system.abstraction;
import std.string;

extern (C)
{
    struct libvlc_instance_t;
    struct libvlc_media_t;
    struct libvlc_media_player_t;
    struct libvlc_event_t;
    
    libvlc_instance_t* libvlc_new(int argc, const(char)** argv);
    void libvlc_release(libvlc_instance_t* instance);
    
    libvlc_media_t* libvlc_media_new_path(libvlc_instance_t* instance, const(char)* path);
    void libvlc_media_release(libvlc_media_t* media);
    
    libvlc_media_player_t* libvlc_media_player_new_from_media(libvlc_media_t* media);
    void libvlc_media_player_release(libvlc_media_player_t* player);
    void libvlc_media_player_play(libvlc_media_player_t* player);
    void libvlc_media_player_stop(libvlc_media_player_t* player);
    int libvlc_media_player_get_state(libvlc_media_player_t* player);
    
    void libvlc_video_set_callbacks(libvlc_media_player_t* player,
        void* function(void*, void**),
        void function(void*, void*, void*),
        void* function(void*),
        void* opaque);
    
    void libvlc_video_set_format(libvlc_media_player_t* player,
        const(char)* chroma,
        uint width,
        uint height,
        uint pitch);
    
    void libvlc_video_get_size(libvlc_media_player_t* player,
        uint num,
        uint* px,
        uint* py);
}

struct Video
{
    uint texW, texH;
    float scale;
    Mutex mutex;
    Texture2D texture;
    ubyte* buffer;
    bool needUpdate;
    libvlc_media_player_t* player;
}

extern (C) void* begin_vlc_rendering(void* data, void** p_pixels)
{
    auto video = cast(Video*) data;
    video.mutex.lock();
    *p_pixels = video.buffer;
    return null;
}

extern (C) void end_vlc_rendering(void* data, void* id, void* p_pixels)
{
    auto video = cast(Video*) data;
    video.needUpdate = true;
    video.mutex.unlock();
}

Video* createVideo(libvlc_instance_t* libvlc, const(char)* filepath)
{
    auto video = new Video;
    video.mutex = new Mutex;
    
    auto media = libvlc_media_new_path(libvlc, filepath);
    if (media is null)
    {
        debug debugWriteln("Failed to create media.");
        free(video);
        return null;
    }
    
    video.player = libvlc_media_player_new_from_media(media);
    libvlc_media_release(media);
    
    if (video.player is null)
    {
        debug debugWriteln("Failed to create media player.");
        free(video);
        return null;
    }
    
    video.needUpdate = false;
    video.texW = 0;
    video.texH = 0;
    video.buffer = null;
    video.texture.id = 0;
    
    libvlc_video_set_callbacks(video.player, &begin_vlc_rendering, &end_vlc_rendering, null, video);
    
    return video;
}

void destroyVideo(Video* video)
{
    if (video is null)
        return;
    
    libvlc_media_player_stop(video.player);
    libvlc_media_player_release(video.player);
    
    if (video.texture.id != 0)
    {
        UnloadTexture(video.texture);
    }
    
    if (video.buffer !is null)
    {
        MemFree(video.buffer);
    }
    
    video.mutex.destroy();
    free(video);
}

void playVideo(string filename)
{
    const(char)*[] vlcArgs = ["--no-xlib", "--drop-late-frames"];
    auto libvlc = libvlc_new(cast(int) vlcArgs.length, cast(const(char)**) vlcArgs.ptr);
    
    if (libvlc is null)
    {
        debug debugWriteln("Failed to initialize libvlc.");
        return;
    }
    
    auto video = createVideo(libvlc, toStringz(filename));
    if (video is null)
    {
        libvlc_release(libvlc);
        return;
    }
    
    libvlc_media_player_play(video.player);
    
    while (!WindowShouldClose())
    {
        if (video.buffer is null && libvlc_media_player_get_state(video.player) == 4) // Playing
        {
            libvlc_video_get_size(video.player, 0, &video.texW, &video.texH);
            
            if (video.texW > 0 && video.texH > 0)
            {
                float screenWidth = cast(float) GetScreenWidth();
                float screenHeight = cast(float) GetScreenHeight();
                float videoAspectRatio = cast(float) video.texW / cast(float) video.texH;
                float screenAspectRatio = screenWidth / screenHeight;
                
                video.scale = (videoAspectRatio < screenAspectRatio) 
                    ? (screenHeight / cast(float) video.texH) 
                    : (screenWidth / cast(float) video.texW);
                
                if (video.texture.id == 0)
                {
                    libvlc_video_set_format(video.player, "RV24", video.texW, video.texH, video.texW * 3);
                    video.mutex.lock();
                    
                    video.texture.id = rlLoadTexture(null, video.texW, video.texH, 
                        PixelFormat.PIXELFORMAT_UNCOMPRESSED_R8G8B8, 1);
                    video.texture.width = video.texW;
                    video.texture.height = video.texH;
                    video.texture.format = PixelFormat.PIXELFORMAT_UNCOMPRESSED_R8G8B8;
                    video.texture.mipmaps = 1;
                    
                    video.buffer = cast(ubyte*) MemAlloc(video.texW * video.texH * 3);
                    video.needUpdate = false;
                    video.mutex.unlock();
                }
            }
        }
        else if (video.buffer !is null)
        {
            if (video.needUpdate)
            {
                video.mutex.lock();
                UpdateTexture(video.texture, video.buffer);
                video.needUpdate = false;
                video.mutex.unlock();
            }
            
            BeginDrawing();
            ClearBackground(Colors.BLACK);
            
            Vector2 position = {
                (GetScreenWidth() - video.texW * video.scale) * 0.5f, 
                (GetScreenHeight() - video.texH * video.scale) * 0.5f
            };
            
            SetTextureFilter(video.texture, TextureFilter.TEXTURE_FILTER_BILINEAR);
            DrawTextureEx(video.texture, position, 0, video.scale, Colors.WHITE);
            
            EndDrawing();
        }
        
        if (IsKeyPressed(KeyboardKey.KEY_ENTER) || IsMouseButtonPressed(MouseButton.MOUSE_BUTTON_LEFT))
        {
            break;
        }
    }
    
    destroyVideo(video);
    libvlc_release(libvlc);
}