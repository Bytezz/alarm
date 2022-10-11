#!/usr/bin/make

SHELL = /bin/sh

APP_NAME     = alarm
APP_ID       = com.github.bytezz.alarm
program      = alarm
package_name = alarm
description  = Alarm App for GNOME which wakes from suspend
APP_VERSION  = $(shell grep -P "VERSION = \"\d+.\d+.\d+\"" ${APP_NAME} | sed -E 's/.*"(.+)".*/\1/')

CC ?= gcc

MAKE ?= make

INSTALL ?= install
INSTALL_PROGRAM = $(INSTALL) -D -o $(USER) -g $(USER) -m 755
INSTALL_DATA    = $(INSTALL) -D -o $(USER) -g $(USER) -m 644

srcdir = src

TMPDIR ?= /tmp
prefix = /usr
exec_prefix = $(prefix)
bindir = $(exec_prefix)/bin
datarootdir = $(prefix)/share
datadir = $(datarootdir)/$(APP_NAME)
docdir = $(datarootdir)/doc/$(APP_NAME)
sysconfdir = /etc
hicolordir = /usr/share/icons/hicolor
applicationsdir = /usr/share/applications

all: set-user-alarm

set-user-alarm: set-user-alarm.c
	$(CC) ${CFLAGS} ${LDFLAGS} -o set-user-alarm set-user-alarm.c

check: set-user-alarm.c
	gcc -o out.o -c -fanalyzer -Werror -Wall -Wextra set-user-alarm.c
	rm out.o
	scan-build clang -o out.o -c -Werror -Wall -Wextra set-user-alarm.c # may add -Weverything
	rm out.o


install: all
	$(INSTALL_DATA) system-wake-up.service ${DESTDIR}/lib/systemd/system/system-wake-up.service
	$(INSTALL_DATA) system-wake-up.timer ${DESTDIR}/lib/systemd/system/system-wake-up.timer
	install -D -o root -g root -m 4755 set-user-alarm ${DESTDIR}/usr/lib/${APP_NAME}/libexec/set-user-alarm
	$(INSTALL_PROGRAM) play-alarm-sound ${DESTDIR}/usr/lib/${APP_NAME}/libexec/play-alarm-sound
	$(INSTALL_PROGRAM) ${APP_NAME} ${DESTDIR}${bindir}/${APP_NAME}
	$(INSTALL_DATA) app.ui ${DESTDIR}${datadir}/app.ui
	$(INSTALL_DATA) alarm.ogg ${DESTDIR}${datadir}/alarm.ogg
	$(INSTALL_DATA) copyright ${DESTDIR}${docdir}/copyright
	$(INSTALL_DATA) ${APP_ID}.desktop ${DESTDIR}$(applicationsdir)/${APP_ID}.desktop
	$(INSTALL_DATA) ${APP_ID}.service ${DESTDIR}/usr/share/dbus-1/services/${APP_ID}.service
	$(INSTALL_DATA) ${APP_ID}.svg ${DESTDIR}${hicolordir}/scalable/apps/${APP_ID}.svg
	gtk-update-icon-cache

uninstall:
	rm -rf ${DESTDIR}/lib/systemd/system/system-wake-up.service
	rm -rf ${DESTDIR}/lib/systemd/system/system-wake-up.timer
	rm -rf ${DESTDIR}/lib/systemd/system/timers.target.wants/system-wake-up.timer
	rm -rf ${DESTDIR}${bindir}/set-user-alarm
	rm -rf ${DESTDIR}${bindir}/${APP_NAME}
	rm -rf ${DESTDIR}/usr/lib/${APP_NAME}
	rm -rf ${DESTDIR}${datadir}
	rm -rf ${DESTDIR}${docdir}
	rm -rf ${DESTDIR}${applicationsdir}/${APP_ID}.desktop
	rm -rf ${DESTDIR}/usr/share/dbus-1/services/${APP_ID}.service
	rm -rf ${DESTDIR}${hicolordir}/scalable/apps/${APP_ID}.svg

clean:
	rm -f set-user-alarm

install-deb: set-user-alarm
	checkinstall "--requires=systemd, pulseaudio-utils, libglib2.0-bin, python3-psutil, python3-gi, gir1.2-glib-2.0, gir1.2-gtk-3.0" --pkgname=${APP_NAME} --pkglicense=GPL-2+ --nodoc --pkgversion=${APP_VERSION} --pkgrelease=0 --include=listfile --deldesc=yes --backup=no -y

dist:
	rm -rf $(TMPDIR)/$(APP_NAME)-$(APP_VERSION)
	cp -r . $(TMPDIR)/$(APP_NAME)-$(APP_VERSION)
	tar -cf $(APP_NAME)-$(APP_VERSION).tar --directory=$(TMPDIR) $(APP_NAME)-$(APP_VERSION)
	gzip $(APP_NAME)-$(APP_VERSION).tar
	rm -rf $(TMPDIR)/$(APP_NAME)-$(APP_VERSION)

dist-deb: all
	rm -rf debian
	mkdir debian
	$(MAKE) DESTDIR=./debian prefix=/usr install
	mkdir debian/DEBIAN
	cp build-aux/debiancontrol debian/DEBIAN/control
	sed -i "s/Package: /Package: $(package_name)/" debian/DEBIAN/control
	sed -i "s/Version: /Version: $(APP_VERSION)/" debian/DEBIAN/control
	sed -i "s/Architecture: /Architecture: `uname -m | sed "s/x86_64/amd64/" | sed "s/aarch64/arm64/"`/" debian/DEBIAN/control
	sed -i "s/Description: /Description: $(APP_NAME)\n $(description)/" debian/DEBIAN/control
	dpkg-deb -b debian $(APP_NAME)-$(APP_VERSION)-`uname -m`.deb
