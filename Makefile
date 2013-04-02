VERSION=1.0.0

build-all:
	echo nothing to be done.

pacifica-test-data.spec: pacifica-test-data.spec.in
	sed 's/@VERSION@/'${VERSION}'/g' pacifica-test-data.spec.in > pacifica-test-data.spec

dist: pacifica-test-data.spec
	rm -f pacifica-test-data-${VERSION}.tar.gz
	rm -rf pacifica-test-data-${VERSION}
	mkdir -p pacifica-test-data-${VERSION}
	ln -s ../data pacifica-test-data-${VERSION}/data
	cp pacifica-test-data.spec* pacifica-test-data-${VERSION}/
	cp Makefile pacifica-test-data-${VERSION}/
	tar --dereference --exclude '.git' -zcvf pacifica-test-data-${VERSION}.tar.gz pacifica-test-data-${VERSION}/*

rpm: dist
	rm -rf `pwd`/packages
	mkdir -p `pwd`/packages/src
	mkdir -p `pwd`/packages/bin
	rpmbuild -ta pacifica-test-data-${VERSION}.tar.gz --define '_rpmdir '`pwd`'/packages/bin' --define '_srcrpmdir '`pwd`'/packages/src'

rpms: rpm

MOCKOPTS=
MOCKDIST=fedora-18-x86_64
MOCK=/usr/bin/mock

mock: dist
	rm -rf packages/"$(MOCKDIST)"
	mkdir -p packages/"$(MOCKDIST)"/srpms
	mkdir -p packages/"$(MOCKDIST)"/bin
	$(MOCK) -r "$(MOCKDIST)" --buildsrpm --spec pacifica-test-data-${VERSION}/pacifica-test-data.spec $(MOCKOPTS) --sources "`pwd`"
	mv "/var/lib/mock/$(MOCKDIST)/result/"*.src.rpm packages/"$(MOCKDIST)"/srpms/
	$(MOCK) -r "$(MOCKDIST)" --result "$(CURDIR)"/packages/"$(MOCKDIST)"/bin $(MOCKOPTS) "$(CURDIR)"/packages/"$(MOCKDIST)"/srpms/*.src.rpm
