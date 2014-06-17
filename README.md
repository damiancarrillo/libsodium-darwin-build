# libsodium-darwin-build

You will need autoconf, automake, and libtool to build this package. You can install
them with something like Homebrew or download them from:

- [http://ftp.gnu.org/gnu/autoconf/](http://ftp.gnu.org/gnu/autoconf/)
- [http://ftp.gnu.org/gnu/automake/](http://ftp.gnu.org/gnu/automake/)
- [http://ftpmirror.gnu.org/gnu/libtool/](http://ftpmirror.gnu.org/gnu/libtool/)


When I set out to build libsodium, I ran into a couple of issues. I'm listing them here
for future reference.

#### C compiler cannot create executables, Error 77

	configure: error: C compiler cannot create executables
	See `config.log' for more details
	make: *** [build/iPhoneOS-armv7/lib/libsodium.a] Error 77

Adjust the SDK version in the Makefile. Find your SDK version with the following command:

	ls $(xcode-select -p)/Platforms/iPhoneOS.platform/Developer/SDKs | cut -c 9-11

#### Error during linking on arm64: malformed object (unknown load command 1)

See [this page](http://lists.cs.uiuc.edu/pipermail/llvmbugs/2014-March/033269.html) a
similar issue, but with OpenSSL instead of NaCL. The solution in
[this page](http://lists.cs.uiuc.edu/pipermail/llvmbugs/2014-March/033328.html) worked
for me.
