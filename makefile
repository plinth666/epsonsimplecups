VPATH = src:ppd:bin

ppds = EpsonTMT20Simple.ppd.gz

DEFS=
LIBS=-lcupsimage -lcups

ifdef RPMBUILD
DEFS=-DRPMBUILD
LIBS=-ldl
endif

define dependencies
@if [ ! -e /usr/include/cups ]; then echo "CUPS headers not available - exiting"; exit 1; fi
endef

define init
@if [ ! -e bin ]; then echo "mkdir bin"; mkdir bin; fi
endef

define sweep
@if [ -e bin ]; then echo "rm -f bin/*"; rm -f bin/*; rmdir bin; fi
@if [ -e install ]; then echo "rm -f install/*"; rm -f install/*; rmdir install; fi
endef

install/setup: rastertoepsonsimple $(ppds) setup
	# packaging
	@if [ -e install ]; then rm -f install/*; rmdir install; fi
	mkdir install
	cp bin/rastertoepsonsimple install
	cp bin/*.ppd.gz install
	cp bin/setup install

.PHONY: install
install:
	@if [ ! -e install ]; then echo "Please run make package first."; exit 1; fi
	# installing
	cd install; exec ./setup

.PHONY: remove
remove:
	#removing from default location (other locations require manual removal)
	@if [ -e /usr/lib/cups/filter/rastertoepsonsimple ]; then echo "Removing rastertoepsonsimple"; rm -f /usr/lib/cups/filter/rastertoepsonsimple; fi
	@if [ -d /usr/share/cups/model/star ]; then echo "Removing dir .../cups/model/star"; rm -rf /usr/share/cups/model/star; fi

.PHONY: rpmbuild
rpmbuild:
	@if [ ! -e install ]; then echo "Please run make package first."; exit 1; fi
	# installing
	RPMBUILD="true"; export RPMBUILD; cd install; exec ./setup

.PHONY: help
help:
	# Help for starcupsdrv make file usage
	#
	# command          purpose
	# ------------------------------------
	# make              compile all sources and create the install directory
	# make install      execute the setup shell script from the install directory [require root user permissions]
	# make remove       removes installed files from your system (assumes default install lication) [requires root user permissions]
	# make clean        deletes all compiles files and their folders

rastertoepsonsimple: rastertoepsonsimple.c bufferedscanlines.o
	$(dependencies)
	$(init)
	# compiling rastertoepsonsimple filter
	gcc -Wl,-rpath,/usr/lib -Wall -fPIC -O2 $(DEFS) -o bin/rastertoepsonsimple bufferedscanlines.o src/rastertoepsonsimple.c $(LIBS)


$(ppds): %.ppd.gz: %.ppd
	# gzip ppd file
	gzip -c $< >> bin/$@

setup: setup.sh
	$(dependencies)
	$(init)
	# create setup shell script
	cp src/setup.sh bin/setup
	chmod +x bin/setup

.PHONY: clean
clean:
	# cleaning
	$(sweep)

