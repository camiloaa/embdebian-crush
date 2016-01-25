# The default profile for Emdebian Crush
Profile: emdebian-crush/main
Extends: emdebian-grip/main
Enable-Tags-From-Check: emdebian
Disable-Tags: binary-or-shlib-defines-rpath,
 binary-without-manpage,
 build-depends-indep-without-arch-indep,
 no-copyright-file,
 python-script-but-no-python-dep,
 debian-rules-missing-required-target,
 debian-files-list-in-source,
 native-package-with-dash-version,
 source-nmu-has-incorrect-version-number,
 changelog-should-mention-nmu,
 extended-description-is-empty,
 no-shlibs-control-file,
 postinst-must-call-ldconfig
