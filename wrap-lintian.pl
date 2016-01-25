#!/usr/bin/perl

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

use Cwd;
use File::Basename;
use strict;
use warnings;
use Term::ANSIColor qw(:constants);
use vars qw/$source $changes $arch $vopts $verbose $vendor $emvers
 $build $dosign $addsource $buildArea $msg $epochvers $dir /;
$addsource = "";
$verbose = 0;
$dir = "../";
$source=$ENV{"PACKAGE"};
$emvers=$ENV{"non_epoch_version"};
$epochvers=$ENV{"debian_version"};
$buildArea=$ENV{"buildArea"};
$arch=`dpkg-architecture -qDEB_HOST_ARCH_CPU`;
chomp ($arch);
$msg = "Unable to parse svn-buildpackage environment variables!\n";
die ("$msg") if (not defined $source or not defined $emvers);
$changes = "${source}_${emvers}_${arch}.changes";
$vendor = $ENV{"DEB_VENDOR"}
	if (defined $ENV{"DEB_VENDOR"} and (not defined $vendor));
$vendor = "emdebian-crush" if (not defined $vendor);
chomp ($vendor);
$vopts = `dpkg-vendor --vendor $vendor --query grip-build-option`;
$msg = "Unable to retrieve dpkg-vendor settings for grip-build-option!\n";
chomp ($vopts) if (defined $vopts);
die ($msg)
	if (not defined $vopts or ("" eq $vopts));

if (($emvers =~ /em1$/) and ("emdebian-crush" eq $vendor))
{
	my $orig_msg = "New emdebian release detected, using '-sa' to include .orig.tar.gz\n";
	print GREEN, wrap('','',$orig_msg), RESET if ($verbose >=2);
	$addsource = '-sa';
}
# run the cross-built package through emgrip
print GREEN, "Postprocessing cross-built $source for Emdebian Crush.\n", RESET;
my $gripdir = "$dir/${source}.grip";
(-d $gripdir) ? system ("rm -f $gripdir/*") : mkdir ($gripdir);
my $test="emgrip -o $gripdir ${dir}/$changes";
my $env = "dpkg-architecture -a$arch -c";

print CYAN, "$env 'DEB_BUILD_OPTIONS=\"$vopts\" $test '\n", RESET
	if ($verbose >= 2);
system ("$env 'DEB_BUILD_OPTIONS=\"$vopts\" $test '");
opendir (GRIP, $gripdir);
my @gripped=grep(!/^\.\.?/, readdir(GRIP));
closedir(GRIP);
foreach my $g (@gripped)
{
	system ("cp -u $gripdir/$g $dir/$g")
		if ($g !~ /\.tar\.gz$/ and $g !~ /\.dsc$/);
	unlink ("$gripdir/$g");
}
rmdir ($gripdir);
# clean up the .gmo files
system ("find . -name '*.gmo'|xargs rm -f");
my $allow = "--allow-root";
print GREEN, "Running lintian checks for Emdebian only.\n", RESET;
system ("lintian $allow --color auto -ioC em ${buildArea}/$changes");
die "\n"
	if ($? != 0);
print GREEN, "INF: Generating changes file for $arch\n", RESET;
system ("DEB_HOST_ARCH=$arch dpkg-genchanges $addsource 2>/dev/null 1> ${buildArea}/$changes");
print "dpkg-genchanges $addsource > ${buildArea}/$changes\n";
my $tdebchg = "${source}_${emvers}tdeb_$arch.changes";
# lintian errors in TDebs are not fatal.
system ("lintian $allow --color auto -iC em $dir/$tdebchg") if (-f "$dir/$tdebchg");
print GREEN, "Finished running lintian.\n", RESET;
print GREEN, "\nSuccessful build.\n", RESET;
chomp($changes);
my $manual_check = "Please check the package manually before uploading. e.g.\n";
$manual_check .= "'debc -a $arch $dir/${changes}'\n'deb-gview $dir/build-area/${changes}'.\n";
print CYAN, $manual_check, RESET if ($verbose >= 2);
exit 0;

=pod

=head1 Name

wrap-lintian.pl - Emdebian Crush helper for svn-buildpackage

=head1 Description

Passes a normal or cross-build of a Debian package through the Grip
process and runs lintian against the final binaries to check
compliance with Emdebian Policy (which differs from Debian Policy).

=head1 Usage

svn-buildpackage --svn-postbuild=/usr/share/emdebian-crush/wrap-lintian.pl

=head1 Alias

 alias svn-bpem='svn-buildpackage -us -uc --svn-download-orig --svn-postbuild=/usr/share/emdebian-crush/wrap-lintian.pl'

=cut
