#!/usr/bin/bash

gcc -DHOOK_FILE_OPERATIONS -DHOOK_WRITING -g3 -shared -fPIC -Wl,--version-script=version.map -o build/libc.so libc.c
gcc -DHOOK_WRITING -g3 -shared -fPIC -Wl,--version-script=version.map -o build/libc_noprint.so libc.c
gcc -DHOOK_FILE_OPERATIONS -g3 -shared -fPIC -Wl,--version-script=version.map -o build/libc_print.so libc.c