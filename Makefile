SRCDIR=src/libev-4.33
INCLUDE_FILES=$(SRCDIR)/ev++.h	\
			$(SRCDIR)/ev.h		\
    		$(SRCDIR)/ev_vars.h	\
    		$(SRCDIR)/ev_wrap.h	\
    		$(SRCDIR)/event.h 

.PHONY: all ios macos clean

all: ios macos

ios:
	-mkdir -p bin
	-mkdir -p lib
	-mkdir -p include
	-cp $(INCLUDE_FILES) include
	sh $(CURDIR)/build-iOS.sh

macos:
	-mkdir -p bin
	-mkdir -p lib
	-mkdir -p include
	-cp $(INCLUDE_FILES) include
	sh $(CURDIR)/build-macOS.sh

clean:
	-$(MAKE) -C $(SRCDIR) distclean
	-rm -rf bin
	-rm -rf lib
	-rm -rf include
