# Sereno engine
Reimplementation of MAGES./KID Engine on top of [Himmel Engine](https://underlevel.ddns.net/git/quantumde1/himmel_engine).

## Getting Started

### Getting needed components

Build system currently assumes POSIX like system. For building, you need first install next components on:

1. __FreeBSD:__
```
sudo pkg install ldc vlc dub
```

2. __Alpine:__
```
doas apk add ldc2 dub vlc-dev vlc
```

3. __Debian:__
```
sudo apt install dub ldc libvlc-dev vlc build-essential
```

Next, run
```./build.sh```
. Everything will be done automatically!

## Features

now engine supports only text drawing and sometimes playing BGM from Remember11 BIP(sc3 compressed in LZSS) format.

## License

raylib([raylib.com](https://raylib.com)) uses zlib/libpng license

sereno uses CDDL license

libVLC([libVLC github](https://github.com/videolan/vlc)) uses LGPL license, dynamically linked with sereno