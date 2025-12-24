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
module scripts.sc3_r11.lzss;

import core.stdc.string;

enum N = 4096;
enum F = 18;
enum THRESHOLD = 2;

int decompressLZSS(ubyte[] dst, ubyte[] src) 
{
    ubyte[N + F - 1] text_buf;
    ubyte* dst_ptr = dst.ptr;
    ubyte* src_ptr = src.ptr;
    ubyte* src_end = src_ptr + src.length;
    
    int r = N - F;
    ubyte c;
    uint flags = 0;
    int i, j, k;
    
    memset(text_buf.ptr, 0, r);
    
    while (true) {
        if (((flags >>= 1) & 0x100) == 0) {
            if (src_ptr < src_end) {
                c = *src_ptr++;
            } else {
                break;
            }
            flags = c | 0xFF00;
        }
        
        if (flags & 1) {
            if (src_ptr < src_end) {
                c = *src_ptr++;
            } else {
                break;
            }
            *dst_ptr++ = c;
            text_buf[r++] = c;
            r &= (N - 1);
        } else {
            if (src_ptr < src_end) {
                i = *src_ptr++;
            } else {
                break;
            }
            if (src_ptr < src_end) {
                j = *src_ptr++;
            } else {
                break;
            }
            
            i |= ((j & 0xF0) << 4);
            j = (j & 0x0F) + THRESHOLD;
            
            for (k = 0; k <= j; k++) {
                c = text_buf[(i + k) & (N - 1)];
                *dst_ptr++ = c;
                text_buf[r++] = c;
                r &= (N - 1);
            }
        }
    }
    
    return cast(int)(dst_ptr - dst.ptr);
}

ubyte[] decompressLzss(ubyte[] src, int expectedSize = -1) 
{
    if (expectedSize <= 0) {
        expectedSize = cast(int)src.length * 2;
    }
    
    ubyte[] result = new ubyte[expectedSize];
    int actualSize = decompressLZSS(result, src);
    
    if (actualSize < expectedSize) {
        result.length = actualSize;
    }
    
    return result;
}