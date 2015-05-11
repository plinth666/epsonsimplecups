#!/bin/sh

echo "EpsonTMT20Simple"
echo "cups driver installer"
echo "---------------------------------------"

ROOT_UID=0

if [ -z $RPMBUILD ] && [ "$UID" -ne "$ROOT_UID" ]
then
    echo "This script requires root user access."
    echo "Re-run as root user."
    exit 1
fi

if [ ! -z $DESTDIR ]
then
    echo "DESTDIR set to $DESTDIR"
    echo ""
fi

SERVERROOT=$(grep '^ServerRoot' /etc/cups/cupsd.conf | awk '{print $2}')

if [ -z $FILTERDIR ] || [ -z $PPDDIR ]
then
    echo "Searching for ServerRoot, ServerBin, and DataDir tags in /etc/cups/cupsd.conf"
    echo ""

    if [ -z $FILTERDIR ]
    then
        SERVERBIN=$(grep '^ServerBin' /etc/cups/cupsd.conf | awk '{print $2}')

        if [ -z $SERVERBIN ]
        then
            echo "ServerBin tag not present in cupsd.conf - using default"
            FILTERDIR=usr/lib/cups/filter
        elif [ ${SERVERBIN:0:1} = "/" ]
        then
            echo "ServerBin tag is present as an absolute path"
            FILTERDIR=$SERVERBIN/filter
        else
            echo "ServerBin tag is present as a relative path - appending to ServerRoot"
            FILTERDIR=$SERVERROOT/$SERVERBIN/filter
        fi
    fi

    echo ""

    if [ -z $PPDDIR ]
    then
        DATADIR=$(grep '^DataDir' /etc/cups/cupsd.conf | awk '{print $2}')

        if [ -z $DATADIR ]
        then
            echo "DataDir tag not present in cupsd.conf - using default"
            PPDDIR=/usr/share/cups/model/epson
        elif [ ${DATADIR:0:1} = "/" ]
        then
            echo "DataDir tag is present as an absolute path"
            PPDDIR=$DATADIR/model/epson
        else
            echo "DataDir tag is present as a relative path - appending to ServerRoot"
            PPDDIR=$SERVERROOT/$DATADIR/model/epson
        fi
    fi

    echo ""

    echo "ServerRoot = $SERVERROOT"
    echo "ServerBin  = $SERVERBIN"
    echo "DataDir    = $DATADIR"
    echo ""
fi

echo "Copying rastertoepsonsimple filter to $DESTDIR/$FILTERDIR"
mkdir -p $DESTDIR/$FILTERDIR
chmod +x rastertoepsonsimple
cp rastertoepsonsimple $DESTDIR/$FILTERDIR
echo ""

echo "Copying model ppd files to $DESTDIR/$PPDDIR"
mkdir -p $DESTDIR/$PPDDIR
cp *.gz $DESTDIR/$PPDDIR
echo ""

if [ -z $RPMBUILD ]
then
    echo "Restarting CUPS"
    if [ -x /etc/software/init.d/cups ]
    then
        /etc/software/init.d/cups stop
        /etc/software/init.d/cups start
    elif [ -x /etc/rc.d/init.d/cups ]
    then
        /etc/rc.d/init.d/cups stop
        /etc/rc.d/init.d/cups start
    elif [ -x /etc/init.d/cups ]
    then
        /etc/init.d/cups stop
        /etc/init.d/cups start
    elif [ -x /sbin/init.d/cups ]
    then
        /sbin/init.d/cups stop
        /sbin/init.d/cups start
    elif [ -x /etc/software/init.d/cupsys ]
    then
        /etc/software/init.d/cupsys stop
        /etc/software/init.d/cupsys start
    elif [ -x /etc/rc.d/init.d/cupsys ]
    then
        /etc/rc.d/init.d/cupsys stop
        /etc/rc.d/init.d/cupsys start
    elif [ -x /etc/init.d/cupsys ]
    then
        /etc/init.d/cupsys stop
        /etc/init.d/cupsys start
    elif [ -x /sbin/init.d/cupsys ]
    then
        /sbin/init.d/cupsys stop
        /sbin/init.d/cupsys start
    else
        echo "Could not restart CUPS"
    fi
    echo ""
fi

echo "Install Complete"
echo "Add printer queue using OS tool, http://localhost:631, or http://127.0.0.1:631"
echo ""

