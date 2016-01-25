#!/bin/sh

set -e

#  Copyright (C) 2010  Neil Williams <codehelp@debian.org>
#
#  This package is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.

# depends on libparse-debianchangelog-perl, sudo, dpkg-dev,
# subversion and svn-buildpackage
# meant to run on amd64 to build the others.

WRAP=/usr/share/emdebian-crush/wrap-lintian.pl
# fail if parsechangelog fails
dpkg-parsechangelog >/dev/null 2>&1
SRC=`LC_ALL=C dpkg-parsechangelog |grep Source|sed -e 's/Source: //';`
VER=`LC_ALL=C dpkg-parsechangelog |grep Version|sed -e 's/Version: \(.*\)\(em1\)*$/\1/'|sed -e 's/\-.*//'`
# call our own build-dep check based on dpkg-checkbuilddeps
embuilddeps
if [ ! -d ../tarballs/ ]; then
	svn mkdir ../tarballs
	svn propset svn:ignore * ../tarballs/
fi
ORIG=
if [ ! -f "../tarballs/${SRC}_${VER}*orig.tar.gz" ]; then
	ORIG=--svn-download-orig
fi
# this script always builds with the source
DEB_BUILD_OPTIONS=nocheck svn-buildpackage -sa -uc -us ${ORIG} --svn-postbuild=${WRAP} --svn-ignore --svn-rm-prev-dir
