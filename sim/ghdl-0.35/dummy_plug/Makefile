GHDL=ghdl
GHDLFLAGS=--mb-comments
WORK=dummy_plug
SRC_MAIN_VHDL_PATH=../../../src/main/vhdl

CORE_SRC_PATH = $(SRC_MAIN_VHDL_PATH)/core
CORE_PACKAGE  = util.o reader.o sync.o vocal.o core.o mt19937ar.o tinymt32.o
CORE          = $(CORE_PACKAGE) marchal.o

AXI4_SRC_PATH = $(SRC_MAIN_VHDL_PATH)/axi4
AXI4_PACKAGE  = axi4_types.o axi4_models.o
AXI4          = $(AXI4_PACKAGE)              \
                axi4_master_player.o         \
                axi4_slave_player.o          \
                axi4_signal_printer.o        \
                axi4_stream_master_player.o  \
                axi4_stream_slave_player.o   \
                axi4_stream_signal_printer.o \
                axi4_memory_player.o         \
                $(END_LIST)

all: $(CORE) $(AXI4)

clean:
	rm -f *.o *.cf

%.o : %.vhd
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

core.o                     : reader.o vocal.o sync.o util.o
marchal.o                  : reader.o vocal.o sync.o util.o core.o

util.o                     : $(CORE_SRC_PATH)/util.vhd
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

vocal.o                    : $(CORE_SRC_PATH)/vocal.vhd
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

reader.o                   : $(CORE_SRC_PATH)/reader.vhd
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

sync.o                     : $(CORE_SRC_PATH)/sync.vhd
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

core.o                     : $(CORE_SRC_PATH)/core.vhd
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

marchal.o                  : $(CORE_SRC_PATH)/marchal.vhd
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

mt19937ar.o                : $(CORE_SRC_PATH)/mt19937ar.vhd
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

tinymt32.o                 : $(CORE_SRC_PATH)/tinymt32.vhd
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

axi4_core.o                  : axi4_types.o $(CORE_PACKAGE)
axi4_models.o                : axi4_types.o $(CORE_PACKAGE)
axi4_signal_printer.o        : axi4_types.o $(CORE_PACKAGE)
axi4_stream_signal_printer.o : axi4_types.o $(CORE_PACKAGE)
axi4_channel_player.o        : axi4_types.o axi4_core.o 
axi4_master_player.o         : axi4_types.o axi4_core.o axi4_channel_player.o
axi4_slave_player.o          : axi4_types.o axi4_core.o axi4_channel_player.o
axi4_stream_master_player.o  : axi4_types.o axi4_core.o axi4_stream_player.o
axi4_stream_slave_player.o   : axi4_types.o axi4_core.o axi4_stream_player.o

axi4_types.o                 : $(AXI4_SRC_PATH)/axi4_types.vhd
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

axi4_core.o                  : $(AXI4_SRC_PATH)/axi4_core.vhd   
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

axi4_models.o                : $(AXI4_SRC_PATH)/axi4_models.vhd
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

axi4_channel_player.o        : $(AXI4_SRC_PATH)/axi4_channel_player.vhd 
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

axi4_master_player.o         : $(AXI4_SRC_PATH)/axi4_master_player.vhd 
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

axi4_slave_player.o          : $(AXI4_SRC_PATH)/axi4_slave_player.vhd  
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

axi4_signal_printer.o        : $(AXI4_SRC_PATH)/axi4_signal_printer.vhd  
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

axi4_stream_player.o         : $(AXI4_SRC_PATH)/axi4_stream_player.vhd 
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

axi4_stream_master_player.o  : $(AXI4_SRC_PATH)/axi4_stream_master_player.vhd 
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

axi4_stream_slave_player.o   : $(AXI4_SRC_PATH)/axi4_stream_slave_player.vhd  
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

axi4_stream_signal_printer.o : $(AXI4_SRC_PATH)/axi4_stream_signal_printer.vhd  
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

axi4_memory_player.o         : $(AXI4_SRC_PATH)/axi4_memory_player.vhd 
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

