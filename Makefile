CXX?=g++
CC?=gcc
CC_PERMISIVE?=gcc
CXX_PERMISIVE?=g++
OPTFLAGS?=-g3 -ggdb -O0

PACKAGES=#libevent cppunit
LIBS=-pthread

#CXXFLAGS+=-std=c++11 -rdynamic -fPIC -MMD -Wall -pthread -I/usr/local/include -I. -I./src `pkg-config --cflags ${PACKAGES}` $(OPTFLAGS)
CXXFLAGS+=-std=c++11 -rdynamic -fPIC -MMD -Wall -pthread -I/usr/local/include -I. -I./src $(OPTFLAGS)
CFLAGS+=-MMD -Wall $(OPTFLAGS)
#LDFLAGS+= `pkg-config --libs ${PACKAGES}` ${LIBS}
LDFLAGS+= ${LIBS}

all: debug
#unittest

debug: CXXFLAGS += -DDEBUG
debug: CFLAGS += -DDEBUG
debug: ssdp

release: OPTFLAGS=-g0 -O3
release: ssdp

SRC =	src/tools.o \
			src/ssdp.o \
			src/ssdpdb.o \
			src/ssdpdbdevice.o \
			src/ssdphttp.o \
			src/ssdpmessage.o \
			src/ssdpmsearch.o \
			src/ssdpnotify.o \
			src/ssdpnotifyalive.o \
			src/ssdpnotifybye.o \
			src/ssdpnotifyupdate.o \
			src/ssdpparser.o \
			src/ssdpsearchreq.o \
			src/ssdpsearchresp.o \
			src/ssdptools.o \
			src/upnp.o

SSDP_SRC = $(SRC) \
      src/main.o


UTEST_SRC = $(SRC) \
			src/utest/main.o \
			src/utest/testadc.o

OBJECTDIR = build

makedirs:
	mkdir -p $(OBJECTDIR)/src
	mkdir -p $(OBJECTDIR)/src/utest
	
OBJS=$(patsubst %,$(OBJECTDIR)/%,$(SSDP_SRC))
OBJS_UTEST=$(patsubst %,$(OBJECTDIR)/%,$(UTEST_SRC))

-include $(OBJECTDIR)/*.d 

ssdp: makedirs $(OBJS)
	$(CXX) $(OBJS) $(LDFLAGS) -o ssdp-search

unittest: makedirs $(OBJS_UTEST)
	$(CXX) $(OBJS_UTEST) $(LDFLAGS) -o ssdp-search-test 


$(OBJECTDIR)/%.o: %.c
	$(CC_PERMISIVE) $(CFLAGS) -c -o $@ $<

$(OBJECTDIR)/%.o: %.cpp
	$(CXX_PERMISIVE) $(CXXFLAGS) -c -o $@ $<

$(OBJECTDIR)/%.o: %.cc
	$(CXX_PERMISIVE) $(CXXFLAGS) -c -o $@ $<




-include $(EXAMPLES_OBJECTDIR)/*.d

$(EXAMPLES_OBJECTDIR)/%.o: %.c
	$(CC_PERMISIVE) $(CFLAGS) -c -o $@ $<

$(EXAMPLES_OBJECTDIR)/%.o: %.cpp
	$(CXX_PERMISIVE) $(CXXFLAGS) -c -o $@ $<

$(EXAMPLES_OBJECTDIR)/%.o: %.cc
	$(CXX_PERMISIVE) $(CXXFLAGS) -c -o $@ $<


clean:
	rm -rf build/* || true
	rm -f ssdp-search || true
	rm -f ssdp-search-utest || true

PREFIX ?= /usr


install: all
	install ssdp-search  $(PREFIX)/bin


dependencies:
	#apt install rapidjson-dev libevent-dev libcppunit-dev libboost-all-dev


.PHONY: clean all ssdp install
