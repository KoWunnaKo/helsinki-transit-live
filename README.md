Helsinki Transit Live
=====================

[![Build Status](https://travis-ci.org/otsaloma/helsinki-transit-live.svg)](
https://travis-ci.org/otsaloma/helsinki-transit-live)

Helsinki Transit Live is an application for Sailfish OS to view
real-time locations of Helsinki Region Transport (HSL) public
transportation vehicles. It uses the [HSL Live API][1] and should
display data matching the [official web interface][2].

[1]: http://developer.reittiopas.fi/pages/en/other-apis.php
[2]: http://live.mattersoft.fi/hklkartta/

Helsinki Transit Live is free software released under the GNU General
Public License (GPL), see the file `COPYING` for details.

For testing purposes you can just run `/usr/lib/qt5/bin/qmlscene
qml/helsinki-transit-live.qml`. For installation, you probably want an
RPM-package; for instructions on building that, see relevant parts from
the file `RELEASING.md`.
