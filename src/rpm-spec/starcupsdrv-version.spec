%define name starcupsdrv
%define version 3.5.0
%define release 1

Name:		%{name}
Summary:	Star Micronics SP, TSP, HSP, TUP and FVP model CUPS printer drivers.
Version:	%{version}
Release:	%{release}
License:	GPL
Group:		Hardware/Printing
Source:	http://www.star-m.jp/service/s_print/bin/%{name}-3.5.0.tar.gz
URL:		http://www.star-m.jp/service/s_print/starcupsdrv_linux86_yyyymmdd.htm
Vendor:		Star Micronics Co., Ltd.
Packager:	Yusuke Hara <yusuke.hara@star-m.jp>
BuildRoot:	%{_tmppath}/%{name}-%{version}-%{release}-buildroot

%description
The StarCUPSDrv package contains CUPS based printer drivers
for the following models:

SP500
SP700
TSP100
TSP100GT
TSP650
TSP650II
TSP700II
TSP800II
TSP828L
TSP1000
TUP500
TUP900
HSP7000
FVP10

These drivers allow for printing from all applications that use the
standard printing path (CUPS).

After installing this package, go to http://localhost:631 (aka http://127.0.0.1:631)
or use your favorite CUPS print manager to add a new queue for your printer.

%prep
%setup

%build
make RPMBUILD=true

%install
rm -rf $RPM_BUILD_ROOT
make DESTDIR=$RPM_BUILD_ROOT rpmbuild

%clean
rm -rf $RPM_BUILD_ROOT

%pre
LDCONFIGREQ=0
if [ ! -e /usr/lib/libcups.so ]
then
    for libcups in $(ls /usr/lib/libcups.so*)
    do
        if [ -x $libcups ]
        then
            LDCONFIGREQ=1
            ln -s $libcups /usr/lib/libcups.so
            break
        fi
    done
fi
if [ ! -x /usr/lib/libcups.so ]
then
    echo "required library libcups.so not available"
    exit 1
fi
if [ ! -e /usr/lib/libcupsimage.so ]
then
    for libcupsimage in $(ls /usr/lib/libcupsimage.so*)
    do
        if [ -x $libcupsimage ]
        then
            LDCONFIGREQ=1
            ln -s $libcupsimage /usr/lib/libcupsimage.so
            break
        fi
    done
fi
if [ ! -x /usr/lib/libcupsimage.so ]
then
    echo "required library libcupsimage.so not available"
    exit 1
fi
if [ "$LDCONFIGREQ" = "1" ]
then
    ldconfig
fi
exit 0

%post
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
    killall -HUP cupsd
fi
exit 0

%preun
for ppd in $(ls '/etc/cups/ppd')
do
    if grep "SP500\|SP700\|TSP100\|TSP100GT\|TSP650\|TSP700II\|TSP800II\TSP828L\|TSP1000\|TUP500\|TUP900\|FVP10"  "/etc/cups/ppd/$ppd"; then exit 127; fi
done
exit 0

%files
%attr(755, root, root) /usr/lib/cups/filter/rastertostar
%attr(755, root, root) /usr/lib/cups/filter/rastertostarlm
%attr(755, root, root) %dir /usr/share/cups/model/star/
%attr(644, root, root) /usr/share/cups/model/star/sp512.ppd.gz
%attr(644, root, root) /usr/share/cups/model/star/sp542.ppd.gz
%attr(644, root, root) /usr/share/cups/model/star/sp712.ppd.gz
%attr(644, root, root) /usr/share/cups/model/star/sp742.ppd.gz
%attr(644, root, root) /usr/share/cups/model/star/sp717.ppd.gz
%attr(644, root, root) /usr/share/cups/model/star/sp747.ppd.gz
%attr(644, root, root) /usr/share/cups/model/star/tsp113.ppd.gz
%attr(644, root, root) /usr/share/cups/model/star/tsp143.ppd.gz
%attr(644, root, root) /usr/share/cups/model/star/tsp113gt.ppd.gz
%attr(644, root, root) /usr/share/cups/model/star/tsp143gt.ppd.gz
%attr(644, root, root) /usr/share/cups/model/star/tsp651.ppd.gz
%attr(644, root, root) /usr/share/cups/model/star/tsp654.ppd.gz
%attr(644, root, root) /usr/share/cups/model/star/tsp700II.ppd.gz
%attr(644, root, root) /usr/share/cups/model/star/tsp800II.ppd.gz
%attr(644, root, root) /usr/share/cups/model/star/tsp828l.ppd.gz
%attr(644, root, root) /usr/share/cups/model/star/tsp1000.ppd.gz
%attr(644, root, root) /usr/share/cups/model/star/tup542.ppd.gz
%attr(644, root, root) /usr/share/cups/model/star/tup592.ppd.gz
%attr(644, root, root) /usr/share/cups/model/star/tup942.ppd.gz
%attr(644, root, root) /usr/share/cups/model/star/tup992.ppd.gz
%attr(644, root, root) /usr/share/cups/model/star/hsp7000r.ppd.gz
%attr(644, root, root) /usr/share/cups/model/star/hsp7000s.ppd.gz
%attr(644, root, root) /usr/share/cups/model/star/hsp7000v.ppd.gz
%attr(644, root, root) /usr/share/cups/model/star/fvp10.ppd.gz

%changelog
* Thu Jan 15 2015 Yusuke Hara <yusuke.hara@star-m.jp>
- Version 3.5.0
- Support Bluetooth Printer for Mac

* Mon Feb 3 2014 Yusuke Hara <yusuke.hara@star-m.jp>
- Version 3.4.2
- Fixed bug that cannot print by using cupsfilter command.

* Tue Jan 28 2014 Yusuke Hara <yusuke.hara@star-m.jp>
- Version 3.4.1
- Fixed bug that it may cayse extremely slow printing or
  data lost when using CUPS drivers
  V3.4.0 or older with Mac OS X 10.9 (Mavericks).

* Fri Dec 14 2012 Yusuke Hara <yusuke.hara@star-m.jp>
- Version 3.4.0 release
- Added TSP650II
- Modified File Permission (Mac OS X)

* Fri Feb 25 2011 Yusuke Hara <yusuke.hara@star-m.jp>
- Version 3.2.1 release
- Added "cupsSNMPSupplies is False" in PPD file.
- Modified NSB Invalid command sending in only USB interface of Mac OS X. 

* Tue Aug 31 2010 Yusuke Hara <yusuke.hara@star-m.jp>
- Version 3.2.0 release
- Added dataTreatmentRecoverFromError Function of TSP700II, TSP600 and SP700

* Thu Apr 20 2010 Yusuke Hara <yusuke.hara@star-m.jp>
- Version 3.1.1 release
- Added FVP10

* Fri Feb 19 2010 Yusuke hara <yuseuke.hara@star-m.jp>
- Version 3.0.2 release
- Added Tips.(TSP100IIU BackFeed script and Vertical Compression script)

* Thu Jun 30 2009 Yusuke Hara <yusuke.hara@star-m.jp>
- Version 3.1.0 release
- Added TSP800II

* Thu Oct 15 2008 Kazumasa Hosozawa <k-hoso@star-m.jp>
- Version 3.0.0 release
- Added TUP500

* Fri Mar 23 2008 Kazumasa Hosozawa <k-hoso@star-m.jp>
- Version 2.10.0 release
- Added HSP7000

* Wed Dec 12 2007 Kazumasa Hosozawa <k-hoso@star-m.jp>
- Version 2.9.0 release
- Added TSP100GT

* Wed Dec 3 2007 Kazumasa Hosozawa <k-hoso@star-m.jp>
- Version 2.8.2 release
- Bug fix. Dot-Printer's Print Speed.(SP700, SP500)

* Wed Sep 9 2007 Kazumasa Hosozawa <k-hoso@star-m.jp>
- Version 2.8.1 release
- Modified File Permission (Mac OS X)

* Fri Jun 26 2007 Kazumasa Hosozawa <k-hoso@star-m.jp>
- Version 2.8.0 release
- Added TSP650

* Thu Feb 8 2007 Toshiharu Takada <takada@star-m.jp>
- Version 2.7.0 release
- Added TSP700II

* Fri Dec 1 2006 Toshiharu Takada <takada@star-m.jp>
- Version 2.6.0 release
- Added SP700

* Fri Feb 24 2006 Kenichi Nagai <nagai@star-m.jp>
- Version 2.4.0 release
- Added TSP828L

* Fri Aug 19 2005 Dwayne Harris
- Version 2.3.0 release
- Added TSP100

* Mon Feb 14 2005 Albert Kennis
- Version 2.2.0 release
- Fixed bug - cash drawer setting not working

* Tue Oct 19 2004 Albert Kennis
- Version 2.1.0 release
- Added TSP1000
- Added USB device ID support to PPD files
- Fixed bug in support of custom page sizes

* Fri Jul 16 2004 Albert Kennis
- Version 2.0.0 initial release

