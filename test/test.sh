#!/bin/sh
# Copyright 2020, Alisa Bedard
OS=`uname -s`
CF=config.mk
echo "# Configuration for $OS" > $CF
echo "CFLAGS=${CFLAGS}" >> $CF
echo "LDFLAGS=${LDFLAGS}" >> $CF
echo "DESTDIR=${DESTDIR}" >> $CF
echo "PREFIX=${PREFIX}" >> $CF
DEBUG=false USE_GDB=false SMALL=false XFT=false
while getopts 'dgSsx' opt; do
    case $opt in
        d) DEBUG=true ;;
        g) USE_GDB=true ;;
        S) USE_GDB=true SMALL=true ;;
        s) SMALL=true ;;
        x) XFT=true ;;
        ?) for line in \
                '-d enable debugging with verbose log output' \
                '-g enable debug symbols' \
                '-S optimize for size with symbols' \
                '-s optimize for size' \
                '-x use Xft fonts' \
                '-? show usage'; \
        do echo $line; done ;;
    esac
done
case $OS in
    FreeBSD) cat >> $CF <<- EOF
        # FreeBSD:
        jbwm_cflags+=-I/usr/local/include
        jbwm_ldflags+=-L/usr/local/lib
        EOF
        ;;
    NetBSD) cat >> $CF <<- EOF
        # Old NetBSD:
        jbwm_ldflags+=-Wl,-R/usr/X11R6/lib
        # NetBSD:
        jbwm_cflags+=-I/usr/X11R7/include
        jbwm_cflags+=-I/usr/X11R7/include/freetype2
        jbwm_cflags+=-Wno-missing-field-initializers
        jbwm_ldflags+=-L/usr/X11R7/lib
        jbwm_ldflags+=-Wl,-R/usr/X11R7/lib
        EOF
        ;;
    OpenBSD)
        cat >> $CF <<- EOF
        # OpenBSD:
        CC=clang
        jbwm_cflags+=-I/usr/X11R6/include
        jbwm_cflags+=-I/usr/X11R6/include/freetype2
        jbwm_ldflags+=-L/usr/X11R6/lib
        EOF
        ;;
    Linux|?)
        cat >> $CF <<- EOF
        EOF
        ;;
esac
if [ -n "`which pkg-config`" ]; then
    echo "jbwm_ldflags+=`pkg-config --libs-only-L x11`" >> $CF
fi
if [ -d /usr/X11R6/lib ]; then
    echo 'jbwm_ldflags+=-L/usr/X11R6/lib' >> $CF
fi
if [ -d /usr/lib64 ]; then
    echo 'jbwm_ldflags+=-L/usr/lib64' >> $CF
fi
if [ -d /opt/X11/lib ]; then
    echo 'jbwm_ldflags+=-L/opt/X11/lib' >> $CF
fi
if $SMALL; then
    echo SMALL
    echo 'jbwm_cflags+=-DJBWM_SMALL -Os' >> $CF
fi
if $DEBUG; then
    echo DEBUG
    echo 'include debug.mk' >> $CF
fi
if $USE_GDB; then
    echo USE_GDB
    echo 'jbwm_cflags+=-ggdb -O0' >> $CF
    echo 'include debug_gcc.mk' >> $CF
fi
if $XFT; then
    echo 'include xft.mk' >> $CF
fi
