VERSION = 5.3
PREFIX = /usr/local
BINDIR = ${PREFIX}/bin
LIBDIR = $(PREFIX)/lib/lua/${VERSION}
INCDIR = $(PREFIX)/include/lua
MANDIR = $(PREFIX)/man
MAN1DIR = $(MANDIR)/man1
PKGCFGDIR = $(PREFIX)/lib/pkgconfig
PKGCFGFILE = luaprompt.pc

# Modify these as needed, if there are missing header files or
# libraries.

LUA_CFLAGS = $(shell pkg-config --cflags lua${VERSION})
LUA_LDFLAGS = $(shell pkg-config --libs-only-L lua${VERSION})

CFLAGS = -g -fPIC
CFLAGS += -Wall -Wextra -Wno-unused-parameter -DHAVE_ASPRINTF
CFLAGS += -DHAVE_LIBREADLINE -DHAVE_READLINE_HISTORY -D_GNU_SOURCE

# Comment out the following to suppress completion of certain kinds of
# symbols.

CFLAGS += -DCOMPLETE_KEYWORDS     # Keywords such as for, while, etc.
CFLAGS += -DCOMPLETE_MODULES      # Module names.
CFLAGS += -DCOMPLETE_TABLE_KEYS   # Table keys, including global variables.
CFLAGS += -DCOMPLETE_METATABLE_KEYS # Keys in the __index metafield, if
                                          # it exists and is a table.
CFLAGS += -DCOMPLETE_FILE_NAMES   # File names.

# Comment out the following to disable tracking of results.  When
# enabled each returned value, that is, each value the prompt prints
# out, is also added to a table for future reference.

CFLAGS += '-DSAVE_RESULTS'

# The name of the table holding the results can be configured below.

CFLAGS += '-DRESULTS_TABLE_NAME="_"'

# The table holding the results, can also be made to have weak values,
# so as not to interfere with garbage collection.  To enable this
# uncomment the second line below.

# CFLAGS += '-DWEAK_RESULTS'

# Uncomment the following line and customize the prefix as desired to
# keep the auto-completer from considering certain table keys (and
# hence global variables) for completion.

# CFLAGS += '-DHIDDEN_KEY_PREFIX="_"'

# When completing certain kinds of values, such as tables or
# functions, the completer also appends certain useful suffixes such
# as '.', '[' or '('. Normally these are appended only when the
# value's name has already been fully entered, or previously fully
# completed, so that one can still complete the name without the
# suffix.  In order to append the suffix one then only has to press
# the completion key one more time.
#
# Uncomment the following line to make the completer always append
# these suffixes.

# CFLAGS += -DALWAYS_APPEND_SUFFIXES

# The autocompleter can complete module names as if they were already
# require'd and available as a global variable.  Once the module name
# is fully completed a further tab press loads the module and exports
# it as a global variable so that all further tab-completions now
# apply to the module's table.
#
# Uncomment the following line to disable this functionality.  Module
# names will then only be completed inside strings (for use with
# require).

# CFLAGS += -DNO_MODULE_LOAD

# Uncomment to make the auto-completer ask for confirmation before
# loading or globalizing a module.

# CFLAGS += -DCONFIRM_MODULE_LOAD

LDFLAGS=-lreadline -lhistory
INSTALL=/usr/bin/install

all: prompt.so $(PKGCFGFILE)

prompt.so: module.c prompt.c prompt.h
	$(CC) -o prompt.so -shared ${CFLAGS} ${LUA_CFLAGS} module.c prompt.c ${LDFLAGS} ${LUA_LDFLAGS}

luaprompt.pc: pkg-config

dist: luap
	if [ -e /tmp/prompt ]; then rm -rf /tmp/prompt; fi
	mkdir /tmp/prompt
	cp luap.c Makefile prompt.c prompt.h README ChangeLog /tmp/prompt
	cd /tmp; tar zcf luaprompt.tar.gz prompt/

install: prompt.so
	mkdir -p $(BINDIR)
	$(INSTALL) luap.lua $(BINDIR)/luap
	mkdir -p $(INCDIR)
	$(INSTALL) -m 644 prompt.h $(INCDIR)/prompt.h
	mkdir -p $(LIBDIR)
	$(INSTALL) -m 644 prompt.so $(LIBDIR)/prompt.so
	mkdir -p $(MAN1DIR)
	$(INSTALL) -m 644 luap.1 $(MAN1DIR)/luap.1
	mkdir -p $(PKGCFGDIR)
	$(INSTALL) -m 644 $(PKGCFGFILE) $(PKGCFGDIR)/$(PKGCFGFILE)

uninstall:
	rm -f $(BINDIR)/luap $(LIBDIR)/prompt.so $(MAN1DIR)/luap.1 $(PKGCFGDIR)/$(PKGCFGFILE)

clean:
	rm -f prompt.so luaprompt.pc *~

.ONESHELL:
pkg-config: Makefile
	cat > $(PKGCFGFILE) << "_EOF"
	prefix=$(PREFIX)
	exec_prefix=$${prefix}
	lua_version=5.3
	includedir=$${prefix}/include/lua
	libdir=$${exec_prefix}/lib/lua/$${lua_version}
	Name: luaprompt
	Description: A Lua command prompt with pretty-printing and auto-completion
	Version: 0.7.12
	URL: https://github.com/dpapavas/luaprompt
	Libs: $${libdir}/prompt.so
	Libs.private: -lreadline -lhistory
	Cflags: $(LUA_CFLAGS) -I$${includedir}
	$(LUA_LDFLAGS)
	_EOF
