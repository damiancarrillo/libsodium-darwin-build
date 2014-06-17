.PHONY: all clean osx ios
export CFLAGS LDFLAGS

OSX_SDK_VERSION = 10.9
OSX_MIN_VERSION = 10.9
OSX_ARCH = MacOSX-x86_64
OSX_TARGET = $(patsubst %,build/%/lib/libsodium.a,$(OSX_ARCH))
IOS_SDK_VERSION = 7.1
IOS_MIN_VERSION = 7.0
IOS_ARCH = iPhoneSimulator-i386 iPhoneSimulator-x86_64 iPhoneOS-armv7 iPhoneOS-armv7s iPhoneOS-arm64
IOS_TARGET = $(patsubst %,build/%/lib/libsodium.a,$(IOS_ARCH))
ALL_TARGET = libsodium-osx.a libsodium-ios.a
XCODEDIR = $(shell xcode-select -p)

all: $(ALL_TARGET)
osx: libsodium-osx.a
ios: libsodium-ios.a

libsodium-osx.a: $(OSX_TARGET)
libsodium-ios.a: $(IOS_TARGET)
libsodium-%.a :
	lipo -create -output $@ $^

build/%: OS_ARCH = $(word 2,$(subst /, ,$@))
build/%: OS = $(firstword $(subst -, ,$(OS_ARCH)))
build/%: ARCH = $(word 2,$(subst -, ,$(OS_ARCH)))
build/%: BASEDIR = $(XCODEDIR)/Platforms/$(OS).platform/Developer
build/%: PATH = $(BASEDIR)/usr/bin:$(BASEDIR)/usr/sbin:$(shell echo $$PATH)
build/MacOSX-%: SDK = $(BASEDIR)/SDKs/MacOSX$(OSX_SDK_VERSION).sdk
build/MacOSX-%: CONFIGURE_HOST = --host=$(ARCH)-apple-darwin
build/MacOSX-%: CFLAGS = -mmacosx-version-min=$(OSX_MIN_VERSION)
build/MacOSX-%: LDFLAGS = -mmacosx-version-min=$(OSX_MIN_VERSION)
build/iPhoneSimulator-%: SDK = $(BASEDIR)/SDKs/iPhoneSimulator$(IOS_SDK_VERSION).sdk
build/iPhoneSimulator-%: CONFIGURE_HOST = --host=$(ARCH)-apple-darwin
build/iPhoneOS-%: SDK = $(BASEDIR)/SDKs/iPhoneOS$(IOS_SDK_VERSION).sdk
build/iPhoneOS-%: CONFIGURE_HOST = --host=arm-apple-darwin
build/iPhone%: CFLAGS = -miphoneos-version-min=$(IOS_MIN_VERSION)
build/iPhone%: LDFLAGS = -miphoneos-version-min=$(IOS_MIN_VERSION)
build/%: CFLAGS += -Oz -arch $(ARCH) -isysroot $(SDK)
build/%: LDFLAGS += -arch $(ARCH) -isysroot $(SDK)
build/%/lib/libsodium.a: PREFIX = $(patsubst %/lib/libsodium.a,$(PWD)/%,$@)
build/%/lib/libsodium.a: libsodium
	mkdir -p $(PREFIX)
	rsync -r --delete libsodium $(PREFIX)
	cd $(PREFIX)/libsodium && \
		./autogen.sh && \
		./configure $(CONFIGURE_HOST) --disable-shared --prefix=$(PREFIX) && \
		$(MAKE) clean && \
		$(MAKE) install

clean:
	rm -fr $(ALL_TARGET) build
