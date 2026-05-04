#!/usr/bin/sh

gcc -shared -fPIC -g -o build/catchsegv.so catchsegv.c