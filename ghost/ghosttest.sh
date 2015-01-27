#!/bin/sh
# tests for CVE-2015-0235 (GHOST)
# http://www.openwall.com/lists/oss-security/2015/01/27/9
# exploit code taken from: https://gist.github.com/koelling/ef9b2b9d0be6d6dbab63

cd /tmp
curl -O https://raw.githubusercontent.com/cdorros/scripts/master/ghost/ghosttest.c -k
gcc ghosttest.c -o ghosttest
chmod +x ghosttest
./ghosttest
rm ghosttest.c ghosttest
