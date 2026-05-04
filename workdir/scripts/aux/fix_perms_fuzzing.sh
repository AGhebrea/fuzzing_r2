#!/usr/bin/bash

sudo chown -R $(whoami) $1
find $1 -type d -exec chmod 755 {} +
find $1 -type f -exec chmod 644 {} +