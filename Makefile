# -*- coding: us-ascii-unix -*-

NAME       = harbour-helsinki-transit-live
VERSION    = 1.6
RELEASE    = $(NAME)-$(VERSION)
DESTDIR    =
PREFIX     = /usr
DATADIR    = $(DESTDIR)$(PREFIX)/share/$(NAME)
DESKTOPDIR = $(DESTDIR)$(PREFIX)/share/applications
ICONDIR    = $(DESTDIR)$(PREFIX)/share/icons/hicolor

check:
	pyflakes htl trackers

clean:
	rm -rf dist
	rm -rf __pycache__ */__pycache__ */*/__pycache__
	rm -rf .cache */.cache */*/.cache
	rm -f rpm/*.rpm

dist:
	$(MAKE) clean
	mkdir -p dist/$(RELEASE)
	cp -r `cat MANIFEST` dist/$(RELEASE)
	tar -C dist -cJf dist/$(RELEASE).tar.xz $(RELEASE)

install:
	@echo "Installing Python files..."
	mkdir -p $(DATADIR)/htl
	cp htl/*.py $(DATADIR)/htl
	mkdir -p $(DATADIR)/paho/mqtt
	cp paho/*.py $(DATADIR)/paho
	cp paho/mqtt/*.py $(DATADIR)/paho/mqtt
	@echo "Installing QML files..."
	mkdir -p $(DATADIR)/qml/icons
	cp qml/helsinki-transit-live.qml $(DATADIR)/qml/$(NAME).qml
	cp qml/[ABCDEFGHIJKLMNOPQRSTUVXYZ]*.qml $(DATADIR)/qml
	cp qml/icons/*.png $(DATADIR)/qml/icons
	@echo "Installing trackers..."
	mkdir -p $(DATADIR)/trackers
	cp trackers/*.json $(DATADIR)/trackers
	cp trackers/*.py $(DATADIR)/trackers
	@echo "Installing desktop file..."
	mkdir -p $(DESKTOPDIR)
	cp data/$(NAME).desktop $(DESKTOPDIR)
	@echo "Installing icons..."
	mkdir -p $(ICONDIR)/86x86/apps
	mkdir -p $(ICONDIR)/108x108/apps
	mkdir -p $(ICONDIR)/128x128/apps
	mkdir -p $(ICONDIR)/256x256/apps
	cp data/helsinki-transit-live-86.png  $(ICONDIR)/86x86/apps/$(NAME).png
	cp data/helsinki-transit-live-108.png $(ICONDIR)/108x108/apps/$(NAME).png
	cp data/helsinki-transit-live-128.png $(ICONDIR)/128x128/apps/$(NAME).png
	cp data/helsinki-transit-live-256.png $(ICONDIR)/256x256/apps/$(NAME).png

rpm:
	$(MAKE) dist
	mkdir -p $$HOME/rpmbuild/SOURCES
	cp dist/$(RELEASE).tar.xz $$HOME/rpmbuild/SOURCES
	rm -rf $$HOME/rpmbuild/BUILD/$(RELEASE)
	rpmbuild -ba --nodeps rpm/$(NAME).spec
	cp $$HOME/rpmbuild/RPMS/noarch/$(RELEASE)-*.rpm rpm
	cp $$HOME/rpmbuild/SRPMS/$(RELEASE)-*.rpm rpm

test:
	py.test htl trackers

.PHONY: check clean dist install rpm test
