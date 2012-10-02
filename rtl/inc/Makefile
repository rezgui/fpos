include ../../make.rules

all: ctypes fpintres charset matrix strings ucomplex

ctypes:
	$(FPC) $(FPCOPT) $(RTLOUTDIR) ctypes

fpintres:
	$(FPC) $(FPCOPT) $(RTLOUTDIR) fpintres

charset:
	$(FPC) $(FPCOPT) $(RTLOUTDIR) charset

matrix:
	$(FPC) $(FPCOPT) $(RTLOUTDIR) matrix

strings:
	$(FPC) $(FPCOPT) $(RTLOUTDIR) -Fi../i386 strings

ucomplex:
	$(FPC) $(FPCOPT) $(RTLOUTDIR) ucomplex
