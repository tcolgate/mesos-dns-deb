TARGET=deb
PACKAGE_NAME=mesos-dns
PACKAGE_VERSION=0.6.0
HASH="a84227844d74abd2b0cb37f32975b324694f4ac8eaa3f55a640647c92af8eec0  mesos-dns"

PACKAGE_REVISION=1
PACKAGE_ARCH=amd64
PACKAGE_MAINTAINER=tristan@qubit.com
PACKAGE_FILE=$(PACKAGE_NAME)_$(PACKAGE_VERSION)-$(PACKAGE_REVISION)_$(PACKAGE_ARCH).$(TARGET)

GITHUB_URL=https://github.com/mesosphere/mesos-dns/releases/download/v$(PACKAGE_VERSION)/mesos-dns-v$(PACKAGE_VERSION)-linux-amd64
URL=$(GITHUB_URL)

BINNAME=mesos-dns

PWD=$(shell pwd)
CURL=/usr/bin/curl

.PHONY: package clean binary

all: package

binary: clean-bianry
	mkdir -p dist/usr/local/bin
	mkdir -p build
	echo $(HASH) > build/sum
	$(CURL) -L -o build/$(BINNAME) $(URL)
	cd build && sha256sum -c ./sum
	install -m755 build/$(BINNAME) dist/usr/local/bin/$(BINNAME)
	mkdir -p dist/etc/init
	mkdir -p dist/etc/default
	install -m644 $(BINNAME).conf dist/etc/init/$(BINNAME).conf
	install -m644 $(BINNAME).defaults dist/etc/default/$(BINNAME)

clean-bianry:
	rm -f dist/*
	rm -f build/*

package: clean binary
	cd dist && \
	  fpm \
	  -t $(TARGET) \
	  -m $(PACKAGE_MAINTAINER) \
	  -n $(PACKAGE_NAME) \
	  -a $(PACKAGE_ARCH) \
	  -v $(PACKAGE_VERSION) \
	  --iteration $(PACKAGE_REVISION) \
	  -s dir \
	  -p ../$(PACKAGE_FILE) \
	  .


clean:
	rm -f $(PACKAGE_FILE)
	rm -rf dist
	rm -rf build
