#!/usr/bin/bash

gcc -shared -fPIC -g -o build/catchsegv.so catchsegv.c