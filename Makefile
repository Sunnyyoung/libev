SRCDIR=src/libev-4.33
INCLUDE_FILES=$(SRCDIR)/ev++.h	\
			$(SRCDIR)/ev.h		\
    		$(SRCDIR)/ev_vars.h	\
    		$(SRCDIR)/ev_wrap.h	\
    		$(SRCDIR)/event.h 

.PHONY: all clean libev

all: libev

libev:
	-mkdir bin
	-mkdir lib
	-mkdir include
	-cp $(INCLUDE_FILES) include
	sh $(CURDIR)/build.sh

clean:
	-$(MAKE) -C $(SRCDIR) distclean
	-rm -rf bin
	-rm -rf lib
	-rm -rf include
