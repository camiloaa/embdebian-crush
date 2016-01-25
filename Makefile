
all:
	po4a-build
	find doc/pdebuild-cross -name emvendor.1 -delete
	find doc/pdebuild-cross -name embuilddeps.1 -delete
	find doc/pdebuild-cross -name xapt.1 -delete
	find doc/emdebian-crush -name xapt.1 -delete
	find doc/emdebian-crush -name embuilddeps.1 -delete
	find doc/emdebian-crush -name '*pdebuild-cross*.1' -delete
	find doc/xapt -name emvendor.1 -delete
	find doc/xapt -name '*pdebuild-cross*.1' -delete
	$(MAKE) -C po

install:
	$(MAKE) -C po install DESTDIR=../debian/xapt

clean:
	$(RM) *tar.gz.cdbs-config_list
	$(RM) *.1 *.3
	$(RM) doc/po4a.config

check:

test:

# adds the POT file to the source tarball
native-dist: Makefile
	po4a-build --pot-only
	$(MAKE) -C po pot
