#!/bin/sh

#--------------------------------------------------------------
# This shell script was made for rpmbuild.
#
#   Before using this script you have to finish
#   to make cups driver without RPMBUILD.
#
#   This scirpt is avalable on Red Hat Enterprise Linux 5
#                       and uses "rpmbuild ver.4.4.3".
# 
#    Since     2006/02/25 10:00:00 by K.Nagai
#    Last Mod. 2015/01/15 15:00:00 by Y.Hara
#--------------------------------------------------------------

PROJNAME=starcupsdrv-3.5.0
PROJDIRNAME=epsonsimplecupsdrv
RPMROOT=~/RPM
RPMBUILD=$RPMROOT/BUILD
RPMRPMS=$RPMROOT/RPMS
RPMSOURCES=$RPMROOT/SOURCES
RPMSPECS=$RPMROOT/SPECS
RPMSRPMS=$RPMROOT/SRPMS
DESTDIR=$RPMSOURCES/$PROJNAME

#--------------------------------
# -- Make .rpmmacros file
#--------------------------------
if [ -e ~/.rpmmacros ]
then :
  echo "This pc already has .rpmmaros file."
  echo "If you cannot make rpm file, please comfirm that"
  echo "is the existing .rpmmacros correct ?"
else
  cp ./src/rpm-spec/.rpmmacros ~
fi

#--------------------------------
# -- Make RPM Directory
#--------------------------------
# -- RPM root
if [ -d $RPMROOT ]
then : # do nothing
else
  mkdir $RPMROOT
fi

# -- BUILD
if [ -d $RPMBUILD ]
then : # do nothing
else
  mkdir $RPMBUILD
fi

# -- RPMS
if [ -d $RPMRPMS ]
then : # do nothing
else
  mkdir $RPMRPMS
fi

# -- SOURCES
if [ -d $RPMSOURCES ]
then : # do nothing
else
  mkdir $RPMSOURCES
fi

# -- SPECS
if [ -d $RPMSPECS ]
then : # do nothing
else
  mkdir $RPMSPECS
fi

# -- SRPMS
if [ -d $RPMSRPMS ]
then : # do nothing
else
  mkdir $RPMSRPMS
fi

#--------------------------------
# -- Make [source].tar.gz
#--------------------------------
if [ -d $DESTDIR ]
then : # do nothing
else
  mkdir $DESTDIR
fi

# -- copy make files
cp ./makefile 	$DESTDIR
cp ./LICENSE.txt  	$DESTDIR
cp ./rpmbuild_support.sh $DESTDIR

# -- copy src files
if [ -d $DESTDIR/src ]
then : # do nothing
else
  mkdir $DESTDIR/src
fi
cp ./src/*.c  $DESTDIR/src
cp ./src/*.sh $DESTDIR/src

# -- copy ppd files
if [ -d $DESTDIR/ppd ]
then : # do nothing
else
  mkdir $DESTDIR/ppd
fi
cp ./ppd/*.ppd  $DESTDIR/ppd

RETURNPATH=$PWD
cd $RPMSOURCES
tar cvzf ./$PROJNAME.tar.gz $PROJNAME/
cd $RETURNPATH
rpmbuild -bb ./src/rpm-spec/starcupsdrv-version.spec
