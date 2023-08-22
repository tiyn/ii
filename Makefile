.POSIX:

VERSION = 2.0

# paths
PREFIX    = /usr/local
MANPREFIX = $(PREFIX)/share/man
DOCPREFIX = $(PREFIX)/share/doc

SRC = ii.c
OBJ = $(SRC:.c=.o)

# use system flags.
II_CFLAGS = $(CFLAGS)
II_LDFLAGS = $(LDFLAGS)

# on systems which provide strlcpy(3),
# remove NEED_STRLCPY from CPPFLAGS and
# remove strlcpy.o from LIBS
II_CPPFLAGS = $(CPPFLAGS) -DVERSION=\"$(VERSION)\" -D_DEFAULT_SOURCE -DNEED_STRLCPY
LIBS        = strlcpy.o

all: ii

options:
	@echo ii build options:
	@echo "CFLAGS   = $(CFLAGS)"
	@echo "LDFLAGS  = $(LDFLAGS)"
	@echo "CC       = $(CC)"

.c.o:
	$(CC) -c $< $(II_CFLAGS) $(II_CPPFLAGS)

ii: $(OBJ) $(LIBS)
	$(CC) -o $@ $(OBJ) $(LIBS) $(II_LDFLAGS)

$(OBJ): arg.h

install: all
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	mkdir -p $(DESTDIR)$(MANPREFIX)/man1
	mkdir -p $(DESTDIR)$(DOCPREFIX)/ii
	install -m 644 README FAQ LICENSE $(DESTDIR)$(DOCPREFIX)/ii
	install -m 775 ii $(DESTDIR)$(PREFIX)/bin
	sed "s/VERSION/$(VERSION)/g" < ii.1 > $(DESTDIR)$(MANPREFIX)/man1/ii.1
	chmod 644 $(DESTDIR)$(MANPREFIX)/man1/ii.1

uninstall: all
	rm -f $(DESTDIR)$(MANPREFIX)/man1/ii.1 $(DESTDIR)$(PREFIX)/bin/ii
	rm -rf $(DESTDIR)$(DOCPREFIX)/ii

dist: clean
	mkdir -p ii-$(VERSION)
	cp -R Makefile README FAQ LICENSE strlcpy.c arg.h \
		ii.c ii.1 ii-$(VERSION)
	tar -cf - ii-$(VERSION) | gzip -c > ii-$(VERSION).tar.gz
	rm -rf ii-$(VERSION)

clean:
	rm -f ii *.o
