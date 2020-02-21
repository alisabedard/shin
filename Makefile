INSTALL=install
PREFIX=/usr/local
dest=${DESTDIR}${PREFIX}
bindir=${dest}/bin
all:
	chmod 755 shin
install:
	${INSTALL} -d ${bindir}
	${INSTALL} shin ${bindir}

